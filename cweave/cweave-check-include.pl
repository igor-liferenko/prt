#!/bin/perl -lwn
# there must be at least one identifier after each #include and
# each identifier after #include must be preceded by @! and
# must occur more than once in index
BEGIN { $idx = pop ; @b = `cat $idx` }
unless (/^#include/ && /\/\*/) {
  die "ERROR: remove $_";
}
if (/^#include/ .. /\*\//) {
  /^#include ([^ ]+)/ and $w = $1;
  while (/\|(.+?)\|/g) {
    $x = $1;
    if ($x =~ /^\@!(.*)/) {
      $y = $z = $1;
      $y =~ s/_/\\\\_/g;
      ($f) = grep /{$y}/, @b;
      unless ($f =~ /,.+,/) {
        print STDERR "WARNING: remove |@!$z| from #include $w";
      }
    }
    else {
      print STDERR "WARNING: no \@! for |$x| in #include $w";
    }
  }
}
