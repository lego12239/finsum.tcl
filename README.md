Overview
========

A util lib for financial sum convertion from a representation for view(22.38 - 
i.e. floating value) to representation for processing(2238 - i.e. integer
value). An integer value is used in integer arithmetic to eliminate floating
point errors.

Synopsis
========

finsum::parse SUM [FPDQ] [FPS]

finsum::fmt SUM [FPDQ\_IN] [FPDQ\_OUT] [FPS]

finsum::is\_correct SUM [FPDQ\_IN] [FPS]

Description
===========

parse routine is used to parse SUM(in a representation for view) to 
integer value for processing.
FPDQ - a fractional part digits quantity to be returned(2 by default)
FPS - a fractional part separators(, and . by default)

If finsum::ignore\_errors is set to 1, then there are no errors on
too large fractional part(it simply truncated).

fmt routine is used to format SUM(in a representation for processing) to
representation for view.
FPDQ\_IN - a fractional part digits quantity in SUM(2 by default)
FPDQ\_OUT - a fractional part digits quantity in a result(2 by default)
FPS - a fractional part separator in a result(. by default)

is\_correct routine is used to check a SUM(in a representation for view).

If your parameters values are differ from defaults, then the the more
convenient way to use lib is to redefine parse, fmt and is\_correct
procs(this procs actually just wrappers for \_parse, \_fmt and \_is\_correct).
For example:

```
proc finsum::parse {sum {fpdq 4} {fps ",."}} {
	return [finsum::_parse $sum $fpdq $fps]
}

proc finsum::fmt {sum {fpdq_in 4} {fpdq_out 2} {fps ",."}} {
	return [finsum::_fmt $sum $fpdq_in $fpdq_out $fps]
}
```

Examples
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
