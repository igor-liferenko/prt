#!/bin/perl -wln
# make comma-separated list of pages shorter by using ranges
for ( ( split /,/ ), 0 ) { # (add one extra element)
  unless (defined $l) { # Only on the first line.
    $l = $p = $_;
    next;
  }
  # If present line ($_) follows previous line ($p), continue.
  if ( $_ == $p+1 ) { $p = $_; next }
  # Starting a new range ($_>$p+1): print the previous range.
  push @r, ( $l==$p ? $l : $l . '-' . $p );
  # Save values in the variables left ($l) and previous ($p).
  $l = $p = $_;
}
print join ',', @r;
