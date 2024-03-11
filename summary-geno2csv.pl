#!/usr/bin/perl -w

use strict;

my $file = shift;
#my $label = shift;

#printf ">%s\n", $label;

open FILE, "$file";
while(<FILE>){
  s/^\s+//;
  s/\s+$//;
#1,CTRPNNNTRKRIRIQRGPGRAFVTIGKIGNMRQAHC,,CTRPNNNTRKSIHIGPGKAFYTTGDIIGDIRQAHC,2532,97.46,CTRPNNNTRKSIHIGPGKAFYTTGNIIGDIRQAHC,8,0.31,
  my $line = $_;

  if(/^$/){ ; }
  elsif(/^REF/){ ; }
  else{
    my @tmp = split /\,/, $line;
    printf "REF,%s,,,\n", $tmp[1];

    my $n = 1;
    for(my $i = 3; $i <= $#tmp; $i = $i + 3){
      printf "%d,%s,%d,%.2f,\n", $n, $tmp[$i], $tmp[$i+1], $tmp[$i+2];
      $n++;
    }

  }
}
close FILE;
#print "\n";


