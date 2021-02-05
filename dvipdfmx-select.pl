#!/bin/perl -lwn
# comma-separated list of pages is given in input;
# indexes to this list (1-based) are given in argument;
# output [comma-separated list of] pages which have given indexes
BEGIN { $a = shift }
@p = split /,/;
for (split /,/, $a) {
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
