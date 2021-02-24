#!/bin/perl -wn
# remove from index entries created with @s, unless they have underlined item
# (it's like extending the list of 'reserved words' but still having to use @s
# to ensure compatibility of code formatting with original cweave)
BEGIN { $/ = undef ; $^I = '' }
@a = split /^\\I/m;
for (@a[1..$#a]) {
  if (!/\&/ || /\[/) {
    print "\\I$_";
  }
}
