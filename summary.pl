#!/usr/bin/perl -w

use strict;

my $file = shift;

my %ref;
my $data;

my $n = 0;
open FILE, "$file";
while(<FILE>){
  s/^\s+//;
  s/\s+$//;
  my $line = $_;

  $n++;
  my @tmp = split/\,/, $line;
  if($n == 1){
    for(my $i = 1; $i <= $#tmp; $i++){
      $ref{$i} = $tmp[$i];
    }
  }
  else{
    for(my $i = 1; $i <= $#tmp; $i++){
      if(! exists $data->{$i}->{$tmp[$i]}){
        $data->{$i}->{$tmp[$i]} = 0;
      }
      $data->{$i}->{$tmp[$i]} = $data->{$i}->{$tmp[$i]} + 1;
    }
  }
}
close FILE;

printf "REF,\n";
foreach my $i (sort {$main::a <=> $main::b} keys %ref){

  printf "%d,%s,,", $i, $ref{$i};

  foreach my $j (sort {$data->{$i}->{$main::b} <=> $data->{$i}->{$main::a}} keys %{$data->{$i}}){
    printf "%s,%d,%.2f,", $j, $data->{$i}->{$j}, $data->{$i}->{$j}/($n-1)*100;
  }
  print "\n";
}
