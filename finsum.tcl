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

proc parse {sum {fpdq 2} {fps ",."}} {
	return [[namespace current]::_parse $sum $fpdq $fps]
}

# Convert a money sum represented in fractional form to integer form.
# sum - a money sum
# fpdq - a fractional part digits quantity(to be returned)
# fps - fractional part separators
proc _parse {sum fpdq fps} {
	variable ignore_errors

	set p [split [string trim $sum] $fps]
	set fract [string trimright [lindex $p 1] 0]
	set zero_cnt [expr {$fpdq - [string length $fract]}]
	if {(!$ignore_errors) && ($zero_cnt < 0)} {
		error "fractional part is too large: $fract"
	}
	append fract [string repeat "0" $zero_cnt]
	return [scan [format "%s%.${fpdq}s" [lindex $p 0] $fract] %d]
}

proc fmt {sum {fpdq_in 2} {fpdq_out 2} {fps "."}} {
	return [[namespace current]::_fmt $sum $fpdq_in $fpdq_out $fps]
}

proc _fmt {sum fpdq_in fpdq_out fps} {
	if {$sum < 0} {
		set sign "-"
		set sum [expr {$sum * -1}]
	} else {
		set sign ""
	}
	set int [expr {int($sum) / 10**$fpdq_in}]
	set fract [expr {int($sum) % 10**$fpdq_in}]
	return [format "%s%d.%0${fpdq_out}.${fpdq_out}s" $sign $int $fract]
}
}
