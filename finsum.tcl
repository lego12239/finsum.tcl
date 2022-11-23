# Copyright (c) 2021 Oleg Nemanov <lego12239@yandex.ru>
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package provide finsum 1.0

namespace eval finsum {
variable ignore_errors 0

# Check a sum in a representation-for-view for correctness.
#  sum - a sum in representation-for-view
#  fpdq_in - a maximum fractional part digits quantity for sum
#  fps - fractional part separators
# ret:
#  0 - if not correct
#  1 - if correct
#
# Leading and trailing spaces are removed before checking.
# Trailing zeroes are also removed before checking.
proc is_correct {sum {fpdq_in 2} {fps ",."}} {
	return [[namespace current]::_is_correct $sum $fpdq_in $fps]
}
proc _is_correct {sum fpdq_in fps} {
	set p [split [string trim [string trim $sum] 0] $fps]
	if {[llength $p] > 2} {
		return 0
	}
	if {![regexp {^[\+\-]?[0-9]*$} [lindex $p 0]]} {
		return 0
	}
	if {[string length [lindex $p 1]] > $fpdq_in} {
		return 0
	}
	if {![regexp {^[0-9]*$} [lindex $p 1]]} {
		return 0
	}
	return 1
}

# This is a default parse function, which can be replaced
# by package user with a function which calls _parse() with needed
# parameters.
proc parse {sum {fpdq 2} {fps ",."}} {
	return [[namespace current]::_parse $sum $fpdq $fps]
}

# Convert a money sum represented in fractional form to integer form.
# prms:
#  sum  - a money sum to convert (in format: [+-]INT[.INT], for fps with .)
#  fpdq - a fractional part digits quantity(to be returned)
#  fps  - fractional part separators
# ret:
#  INTEGER - a converted sum
proc _parse {sum fpdq fps} {
	variable ignore_errors

	set p [split [string trim $sum] $fps]
	if {![regexp {^[+-]?[0-9]+$} [lindex $p 0]]} {
		error "integer part is not an integer: [lindex $p 0]"
	}
	if {[llength $p] == 1} {
		lset p 1 0
	} elseif {[llength $p] > 2} {
		error "sum isn't a number: $sum"
	}
	set fract [lindex $p 1]
	if {![regexp {^[0-9]+$} $fract]} {
		error "fractional part is not an unsigned integer: $fract"
	}
	set fract [string trimright $fract 0]
	set zero_cnt [expr {$fpdq - [string length $fract]}]
	if {(!$ignore_errors) && ($zero_cnt < 0)} {
		error "fractional part is too large: $fract"
	}
	append fract [string repeat "0" $zero_cnt]
	return [scan [format "%s%.${fpdq}s" [lindex $p 0] $fract] %d]
}

# This is a default fmt function, which can be replaced
# by package user with a function which calls _fmt() with needed
# parameters.
proc fmt {sum {fpdq 2} {fps "."}} {
	return [[namespace current]::_fmt $sum $fpdq $fps]
}

# Format a sum represented in integer form as a fractional form sum.
# prms:
#  sum  - a sum to format
#  fpdq - a fractional part digits quantity for sum
#  fps  - fractional part separators
# ret:
#  STRING - a sum in the fractional form
proc _fmt {sum fpdq fps} {
	if {![string is entier -strict $sum]} {
		error "sum isn't an integer: $sum"
	}
	if {$sum < 0} {
		set sign "-"
		set sum [expr {$sum * -1}]
	} else {
		set sign ""
	}
	set int [expr {int($sum) / 10**$fpdq}]
	set fract [expr {int($sum) % 10**$fpdq}]
	return [format "%s%d.%0${fpdq}.${fpdq}s" $sign $int $fract]
}
}
