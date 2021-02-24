#!/bin/perl -lwn
# check that each @! after #include occurs more than once in index
BEGIN { $idx = pop ; @b = `cat $idx` }
if (/^#include/ .. /\*\//) {
  /^#include ([^ ]+)/ and $w = $1;
  while (/\|\@!(.+?)\|/g) {
    $x = $y = $1;
    $x =~ s/_/\\\\_/g;
    ($f) = grep /{$x}/, @b;
    unless ($f =~ /,.+,/) {
      print STDERR "WARNING: remove |@!$y| from #include $w";
    }
  }
}
