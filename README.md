OVERVIEW
========

An util lib for financial sum convertion from a representation for view(22.38 -
i.e. floating value, fractional form) to representation for processing(2238 - i.e. integer
value, integer form) and vice versa. An integer value is need to do integer arithmetic to
eliminate calculation errors due to inexact nature of floating point values.

SYNOPSIS
========

finsum::parse SUM [FPDQ] [FPS]

finsum::fmt SUM [FPDQ] [FPS]

finsum::is\_correct SUM [FPDQ] [FPS]

DESCRIPTION
===========

parse routine parses SUM(in a fractional form) and returns integer
representation for this value that will be used for later calculations.
Leading and trailing spaces are removed. The
function args are:
SUM  - a sum(in a fractional form) to convert
FPDQ - a fractional part digits quantity to be returned(2 by default)
FPS  - a fractional part separators(, and . by default)

By default, finsum::onerr proc is thrown an error on too large fractional part.
If this behaviour is undesired, then this proc should be redefined.
To output an error message to stderr without an error throwing(fractional
part is simply truncated) something like this can be done:

```
proc ::finsum::onerr {sum} {
	::finsum::_onerr_print $sum
}

or

interp alias {} ::finsum::onerr {} ::finsum::_onerr_print
```

fmt routine formats SUM(in an integer form) as fractional textual form.
The function args are:
SUM  - a sum(in an integer form) to format
FPDQ - a fractional part digits quantity in SUM and in a result(2 by default)
FPS  - a fractional part separator in a result(. by default)

is\_correct routine checks that a SUM string is a syntactically correct
money sum in a fractional form. Leading and trailing spaces are removed before
checking. The function args are:
SUM  - a sum(in an fractional form) to check
FPDQ - a fractional part digits quantity in SUM(2 by default)
FPS  - a fractional part separator(, and . by default)

If your parameters values are differ from defaults, then the more
convenient way to use lib is to redefine parse, fmt and is\_correct
procs(this procs actually just wrappers for \_parse, \_fmt and \_is\_correct
with predefined parameters).
For example:

```
proc finsum::parse {sum {fpdq 4} {fps ",."}} {
	return [finsum::_parse $sum $fpdq $fps]
}

proc finsum::fmt {sum {fpdq 4} {fps ",."}} {
	return [finsum::_fmt $sum $fpdq $fps]
}
```

RETURN VALUE
============

finsum::parse returns an integer value.

finsum::fmt returns a fractional value.

finsum::is\_correct returns 0 if finsum::parse will thrown an error for
a specified sum. Otherwise, it returns 1.

ERRORS
======

On error finsum routines are throw an error with errorCode
list, where first item equal to 'FINSUM'. Codes:

{FINSUM PARSE} - an error on parsing
{FINSUM FMT}   - an error on formating

EXAMPLES
========

From tclsh:

```
% finsum::parse 1773.23
177323
% finsum::parse 1773
177300
% finsum::parse 1773.3
177330
% finsum::parse 1773.300
177330
% finsum::parse 1773.03
177303
% finsum::parse 1773.003
fractional part is too large: 003
% set finsum::ignore_errors 1
% finsum::parse 1773.003
177300
% finsum::parse 1773.009
177300
```

```
% finsum::is_correct 1773.09
1
% finsum::is_correct 1773.009
0
% finsum::is_correct 0x1773
0
```

```
% finsum::fmt 177330
1773.30
% finsum::fmt 177330 4 2
17.73
```
