#!/bin/perl -lw
# comma-separated list of pages is given in the first line of input;
# indexes to this list (1-based) are given in the second line of input;
# output [comma-separated list of] pages which have given indexes
$_=<>; chomp;
@p=split/,/;
$_=<>; chomp;
for (split/,/) {
  if (/(\d+)-(\d+)/) {
    for ($i = $1; $i <= $2; $i++) {
      push @idx, $i;
    }
  }
  else {
    push @idx, $_;
  }
}
print join ',', map { $p[$_-1] } @idx;
