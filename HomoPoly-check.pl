#!/usr/bin/perl -w

use strict;

while(<>){
  s/^\s+//;
  s/\s+$//;
  my $line = $_;

  if(/^\>/){
    printf "%s\n", $line;
  }else{
    $line =~ s/([atc])-gaaaa/$1g-aaaa/g;
    $line =~ s/([agc])-taaaa/$1t-aaaa/g;
    $line =~ s/([agt])-caaaa/$1c-aaaa/g;

    $line =~ s/([gtc])-agggg/$1a-gggg/g;
    $line =~ s/([agc])-tgggg/$1t-gggg/g;
    $line =~ s/([agt])-cgggg/$1c-gggg/g;

    $line =~ s/([gtc])-atttt/$1a-tttt/g;
    $line =~ s/([atc])-gtttt/$1g-tttt/g;
    $line =~ s/([agt])-ctttt/$1c-tttt/g;

    $line =~ s/([gtc])-acccc/$1a-cccc/g;
    $line =~ s/([atc])-gcccc/$1g-cccc/g;
    $line =~ s/([agc])-tcccc/$1t-cccc/g;

    printf "%s\n", $line;
  }
}

