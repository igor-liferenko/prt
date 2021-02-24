#!/bin/perl -lwn
BEGIN { $idx = pop }
if (/\@s ([^ ]+)/) {
  $x = $y = $1;
  $x =~ s/_/\\\\_/g;
  if (system("grep -q '{$x}' $idx") != 0) {
    print STDERR "WARNING: remove \@s $y ...";
  }
}
