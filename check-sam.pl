#!/usr/bin/perl -w

use strict;

my $file = shift;


my $ll = 0;
my %seq;


open FILE, "$file";
while(<FILE>){
  s/^\s+//;
  s/\s+$//;
  my $line = $_;

  if(/^\@/){ 
    my @tmp = split /\s+/, $line;
    for(my $i = 0; $i <= $#tmp; $i++){
      if($tmp[$i] =~ /^LN\:(\d+)$/){
        $ll = $1;
      }
    }
    printf "%s\n", $line;
  }
  else{
#seq0001 16      AF324493.2      4146    60      52S63M1I26M1D5M1I24M1D1M2I24M1I73M1I30M3I21M2D1M1D6M1D2M3I3M5I11M2D48M1I13M1D8M1I165M1I39M1D101M1I1M1I49M1D12M1I8M1D18M3D3M3D14M1D18M2D11M1D6M1D23M1D152M1I2M1D66M3D62M2D63M1D14M2I28M2D2M1I4M1I11M2I9M2D5M2I13M1D13M3I19M1D37M1I4M2I35M1I21M1I71M2D24M2I1M2I3M2D52M2D20M1I7M7D13M1D6M1D68M1D10M1D81M2I2M2D56M1D1M1D23M1I1M2D40M3I169M2D2M1D1M3D265M1D4M1I4M1I9M2D2M1I2M4I59M1D18M9D24M2I2M6I3M1I3M1I12M1D54M4D2M1I39M9I4M1D4M3I5M1D1M4I2M1I2M4I6M1I3M2D41M1D49M1D14M1I2M1D79M3D21M4D15M1D4M1I98M1I2M3D4M3D20M3D8M3I73M1D7M2I4M1D9M6D10M2I12M2D7M4I29M1D36M2D38M6I5M2D1M1D10M1I2M1D50M2I3M1I3M1D19M1I2M1I10M1D23M2I50M1D7M2D15M1D24M1D51M2I27M1D2M2D21M2D13M2D23M1D32M1I86M1D8M1I60M1I6M1D80M3I5M3D110M1I152M1D22M1I100M3D8M2I1M1I21M1D75M2D3M3D5M1I2M2D5M1D82M2I28M2I2M1I7M1D3M1D73M1D21M9D53M6D37M1I3M1D5M3D3M3D72M1D13M1I16M1D11M1I7M2I10M1D8M1D27M1D16M1I14M1I12M3D6M1D13M1I3M1D83M1I76M3D22M2D2M1I2M3I1M1I7M2I39M4I3M2I2M8I4M9I32M1I79M2D16M71S    *       0       0       AGTTACGTATTGCTACATAAATAGACGACTACAAACGGAATCGACAGCACCTCTGGCATGGGTACCAGCACACAAAGGAATTGGAGGGAATGACCAAGTAGATAAATTAGTCAGTAATTGGAATCAGGAGAGTATTATTTTTGAAGGAAATAGATAAGGCCCAAGAAGAACAGCAAAAAATACCACAGTAATTGGAGAGAAAATGGCCAGTGATTTTAACCTACCACCTGTAATTGCAAAAGAAATAGTAGCCAGCTGTGATAAATGTCAGCTGGTAAGGAGAAGCCATGCATGGACAAGTAGACTTCTGTAGTCCAGGAATATGGCATGATCATCAGGCCATACTGCTTAGAAGGTAATTATCCTGGCAGCAGTTCATGTAGCCAGTGGATAGCCTGAAGCAGAAGCTGGCTCCAGCAGAAGAGGACAGGGAAACAGCATACTTTATCTTAAAGTTAGCAGGAAGATGGCCAGTAAAAACAATACATACAGATAATGGCAGTAATTTCACCAGTGTTACTGCAAAGGCTGCTTGTTGGTGGGCAGGGATCAAGCAGGAATTTGGCATTCCCTACAATCCCCAAAGTCAGGGAGTGGGTGGAATCTATGAATAATGAATTAAAGAAAATTATAGGCAGGTAAGAGATCAGGCTGAACATCTTAGGACAGCAGTACAAATGGCAGTATTCATCCACAATTTTAAGAGAAAAGGGGGGATTGGGGGATACAGTGCAGGAGAGAAAGGATAGTAGACATAATAACAACAGACATACAAACTAAAGAACTACAAAACAAATTACAAAAAATTCAAATTTTTTGGTTTATTAGGACAGAGATCCACTTTGAAAGGACCAGCAAAACTTCTGGAAAGGTATGTTGTGTGGTA
    my @tmp = split /\s+/, $line;

    if($tmp[2] eq "*"){ next; }

    my $name = $tmp[0];
    if(! exists $seq{$name}){
      $seq{$name} = 1;

      if(!($tmp[3] =~ /^\d+$/)){ next; }
      my $pos   = (sprintf "%d", $tmp[3]);
      if($pos > 1){ next; }

      my $cigar = $tmp[5];
      my $ss    = $tmp[9];

      my @cigd = split /[A-Z]/, $cigar;
      my @cigs = split /\d+/, $cigar;

      my $j = 0;
      for(my $i = 0; $i <= $#cigd; $i++){
        if($cigs[$i+1] eq "S"){
          ;
        }elsif($cigs[$i+1] eq "M"){
          $j = $j + $cigd[$i];
        }elsif($cigs[$i+1] eq "I"){
           ;
        }elsif($cigs[$i+1] eq "D"){
          $j = $j + $cigd[$i];
        }
      }
      # 302 - 3
      if($j >= ($ll - 302)){
        printf "%s\n", $line;
      }
    }
  }
}
close FILE;

