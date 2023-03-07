# Copyright (c) 2021-2022 Oleg Nemanov <lego12239@yandex.ru>
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

package provide finsum 2.0

# Some info:
#  - fractional form of sum/number:
#    A text string for human view - a representation for view.
#    E.g. "12.34" or "0.34".
#  - integer form of sum/number:
#    An integer number without fractional part - a representation for
#    processing to eliminate rounding errors. E.g. 1234 or 34.
#  This package do a convertion between fractional form and
#  integer form and vice versa, e.g. convert "12.34" to 1234 and
#  1234 to "12.34".

namespace eval finsum {
variable onerr [list _onerr_throw]

proc _onerr_print {sum} {
	puts stderr "fractional part is too large: '$sum'"
}

proc _onerr_throw {sum} {
	throw {FINSUM PARSE} "fractional part is too large: '$sum'"
}

# This is a default is_correct function, which can be replaced
# by package user with a function which calls _is_correct() with needed
# parameters.
proc is_correct {sum {fpdq 2} {fps ",."}} {
	return [[namespace current]::_is_correct $sum $fpdq $fps]
}

# Check a sum in a fractional form for correctness.
#  sum  - a sum in fractional form
#  fpdq - a maximum fractional part digits quantity for sum
#  fps  - fractional part separators
# ret:
#  0 - if not correct
#  1 - if correct
#
# Leading and trailing spaces are removed before checking.
# Trailing zeroes are also removed before checking.
proc _is_correct {sum fpdq fps} {
	set p [split [string trim $sum] $fps]
	if {![regexp {^[+-]?[0-9]+$} [lindex $p 0]]} {
		return 0
	}
	if {[llength $p] == 1} {
		return 1
	} elseif {[llength $p] > 2} {
		return 0
	}
	set fract [lindex $p 1]
	if {![regexp {^[0-9]+$} $fract]} {
		return 0
	}
	set fract [string trimright $fract 0]
	if {[string length $fract] > $fpdq} {
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
#
# Leading and trailing spaces are removed before work.
# Trailing zeroes are also removed before work.
proc _parse {sum fpdq fps} {
	variable onerr

	set p [split [string trim $sum] $fps]
	if {![regexp {^[+-]?[0-9]+$} [lindex $p 0]]} {
		error "integer part is not an integer: '$sum'"
	}
	if {[llength $p] == 1} {
		lset p 1 0
	} elseif {[llength $p] > 2} {
		error "sum isn't a number: '$sum'"
	}
	set fract [lindex $p 1]
	if {![regexp {^[0-9]+$} $fract]} {
		error "fractional part is not an unsigned integer: '$sum'"
	}
	set fract [string trimright $fract 0]
	set zero_cnt [expr {$fpdq - [string length $fract]}]
	if {([llength $onerr] != 0) && ($zero_cnt < 0)} {
		{*}$onerr $sum
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
#  fps  - a fractional part separator
# ret:
#  STRING - a sum in the fractional form
#
# Leading and trailing spaces are removed before work.
# Trailing zeroes are also removed before work.
proc _fmt {sum fpdq fps} {
	if {![string is entier -strict $sum]} {
		error "sum isn't an integer: '$sum'"
	}
	if {$sum < 0} {
		set sign "-"
		set sum [expr {$sum * -1}]
	} else {
		set sign ""
	}
	set int [expr {int($sum) / 10**$fpdq}]
	set fract [expr {int($sum) % 10**$fpdq}]
	return [format "%s%d${fps}%0${fpdq}.${fpdq}s" $sign $int $fract]
}
}
