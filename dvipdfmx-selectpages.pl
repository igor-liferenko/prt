#!/bin/perl -lw
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
