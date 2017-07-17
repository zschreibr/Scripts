#!/usr/bin/perl

=head1 NAME
   matchCluster.pl

=head1 SYNOPSIS

    USAGE: matchMgOl.pl -i1=clusterfile.clstr -i2=reference.fasta

=head1 OPTIONS

B<--input_cluster, -i1>
    Required. cd-hit cluster file output.

B<--input_ref, -i2>
    Required. Reference database file.

B<--help,-h>
 
=head1  DESCRIPTION
        Generates an output file containing sequence data of MgOl members that shared a Uniref reference
	header. 

=head1  INPUT
        Cd-hit cluster file along with a refrence database fasta file

=head1  OUTPUT
	Fasta file that containing MgOl sequences that had a representative Uniref cluster member.  	
	
=head1  CONTACT
        Zach Schreiber @ zschreib[at]gmail[dot]com

=head1 EXAMPLE
         matchCluster.pl -i1=MgOl100.clstr -i2=Uniref100.fasta

=cut

use strict;
use warnings;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use List::Util qw(min max);

my %options = ();
my $results = GetOptions (\%options,
                                                  'input_cluster|i1=s',
                                                  'input_ref|i2=s',
                                                  'help|h') || pod2usage();
#### display documentation
if( $options{'help'} ) {
  pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}

##user input
my $infile = $options{input_cluster};
my $Uniref = $options{input_ref};

#<---------------------------------------------------------------------->

# Variables #

my $outfile = "$infile" . "_members"; 
my $var;
my $newvar;
my %myhash = ();

##########

open (FILE, $infile) or die "No infile found for $infile";

while (my $line = <FILE>)
{ 
    if ($line =~ /^0/)
    {             
       $var = $line;
       $var =~ /^.+(>UniRef\S+)\.\.\./;
       $newvar= $1;
    }
    if ($line =~ />..._/)
    {
       $myhash{$newvar} = 1;
    }
}

close FILE;

# <-------------------------------------------------------------------------->
my $name;
my $flag = 0;
my $count = 0;

open (OUT, "> $outfile");
open (FILE2, $Uniref) or die "No Refrence database file found for $Uniref";

        while (<FILE2>)
            { 
               $_ =~ /^(\S+)/;
               $name = $1;
                  
               if($flag == 1)
               {
                  if($_ =~/^>/)
                  { 
                     $flag = 0;
                  }
                  else
                  {
                     print OUT $_;
                  }
               }
               
               if($myhash{$name})
              {  
                if($flag == 0)
               {
                print OUT $_;
                $flag = 1; 
               }
              }
              
             if($myhash{$name}){
                 $count ++;
           }
           }
close OUT;
close FILE2;

print "$count matches found";
print "\n\n ==============  D O N E =============== \n\n\n";


