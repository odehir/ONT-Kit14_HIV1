#!/usr/bin/perl -w

use strict;

my $file = shift;
my $id   = shift;


my %seq;
my $ref = "";

my $n = 0;
open FILE, "$file";
while(<FILE>){
  s/^\s+//;
  s/\s+$//;
  my $line = $_;

  if(/^\>/){
    $n++;
    if($n == 1){
      ;
    }
  }else{
    if($n == 1){
      $ref = $line;
    }else{
      if(! exists $seq{$line}){
        $seq{$line} = 1;
      }else{
        $seq{$line} = $seq{$line} + 1;
      }
    }
  }
}
close FILE;

printf ">REF_%d\n", $n-1;
printf "%s\n", $ref;
my $k = 0;
foreach my $i (sort {$seq{$main::b} <=> $seq{$main::a}} keys %seq){

  printf ">%s_seq%d_%d\n", $id, $k, $seq{$i};
  printf "%s\n", $i;
  $k++;
}

