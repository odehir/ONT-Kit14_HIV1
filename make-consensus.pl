#!/usr/bin/perl -w

use strict;

my $file = shift;
my $label = shift;

printf ">%s\n", $label;

open FILE, "$file";
while(<FILE>){
  s/^\s+//;
  s/\s+$//;
#1,t,,t,2596,99.92,-,1,0.04,g,1,0.04,
  my $line = $_;

  if(/^$/){ ; }
  elsif(/^REF/){ ; }
  else{
    my @tmp = split /\,/, $line;
    my %na;
    my $nn = $tmp[3];
    for(my $i = 3; $i <= $#tmp; $i = $i + 3){
      if($tmp[$i+2] > 10.0){
        my $s = $tmp[$i];
        if(length($s) == 1){
          $na{$s} = 1;
        }
      }
    }

    if($nn eq "-"){ printf "-"; }
    else{
      if(length($nn) > 1){
        printf "%s", $nn; 
      }else{
        if(exists $na{a} && exists $na{g} && exists $na{t} && exists $na{c}){ printf "N"; }
        if(!exists $na{a} && exists $na{g} && exists $na{t} && exists $na{c}){ printf "B"; }
        if(exists $na{a} && !exists $na{g} && exists $na{t} && exists $na{c}){ printf "H"; }
        if(exists $na{a} && exists $na{g} && !exists $na{t} && exists $na{c}){ printf "V"; }
        if(exists $na{a} && exists $na{g} && exists $na{t} && !exists $na{c}){ printf "D"; }
        if(!exists $na{a} && !exists $na{g} && exists $na{t} && exists $na{c}){ printf "Y"; }
        if(!exists $na{a} && exists $na{g} && !exists $na{t} && exists $na{c}){ printf "S"; }
        if(!exists $na{a} && exists $na{g} && exists $na{t} && !exists $na{c}){ printf "K"; }
        if(exists $na{a} && !exists $na{g} && !exists $na{t} && exists $na{c}){ printf "M"; }
        if(exists $na{a} && !exists $na{g} && exists $na{t} && !exists $na{c}){ printf "W"; }
        if(exists $na{a} && exists $na{g} && !exists $na{t} && !exists $na{c}){ printf "R"; }
        if(exists $na{a} && !exists $na{g} && !exists $na{t} && !exists $na{c}){ printf "A"; }
        if(!exists $na{a} && exists $na{g} && !exists $na{t} && !exists $na{c}){ printf "G"; }
        if(!exists $na{a} && !exists $na{g} && exists $na{t} && !exists $na{c}){ printf "T"; }
        if(!exists $na{a} && !exists $na{g} && !exists $na{t} && exists $na{c}){ printf "C"; }
      }
    }
  }
}
close FILE;
print "\n";


