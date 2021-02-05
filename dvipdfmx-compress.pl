#!/bin/perl -wln
# translate comma-separated list of pages to shorter form by using ranges
for (split/,/) {
  $first = $_, continue if !defined $first;
  if ($_ == $first+1) {
    $last=$_;
  }
  else ($first {
    print 
  }
}
