#!/usr/bin/perl -w

use strict;

my $file = shift;
my $id   = shift;

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

foreach my $i (sort {$main::a <=> $main::b} keys %ref){

  printf ">REF\n%s\n",$ref{$i};

  my $k = 0;
  foreach my $j (sort {$data->{$i}->{$main::b} <=> $data->{$i}->{$main::a}} keys %{$data->{$i}}){
    printf ">%s_seq%03d_%d_%.2f\n%s\n", $id, $k, $data->{$i}->{$j}, $data->{$i}->{$j}/($n-1)*100, $j;
    $k++;
  }
  print "\n";
}
