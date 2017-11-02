#!/usr/bin/perl

=head1 NAME
	tara_contig_pull.pl  

=head1 SYNOPSIS

    USAGE: tara_contig_pull.pl -i1=headers -i2=tara_db.fasta

=head1 OPTIONS

B<--input_headers, -i1>
   
B<--tara_database, -i2>
 
B<--help,-h>
 
=head1  DESCRIPTION
	Accepts list of tara ocean ORF headers and pulls out all ORFs belonging to those specific headers

=head1  INPUT
        List of tara ocean ORF headers
	
=head1  OUTPUT
        Fasta file of ORFs     
        
=head1  CONTACT
        Zach Schreiber @ zschreibr[at]gmail[dot]com

=head1 EXAMPLE
         tara_contig_pull.pl -i1= -i2= 

=cut

use strict;
use warnings;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use List::Util qw(min max);

my %options = ();
my $results = GetOptions (\%options,
                                                  'input1|i1=s',
                                                  'input2|i2=s',
                                                  'help|h') || pod2usage();
#### display documentation
if( $options{'help'} ) {
  pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}



##user input error flags
die "Missing input tara header file! -i1\n" unless $options{input1};
#die "Missing input tara database file! -i2\n" unless $options{input2};
##end error

##user input
my $header = $options{input1};
my $database = $options{input2};
#end input

## VARS ##
my (@a,@id,$ctgid,$id,$flag);
my %hoh = ();
## end vars


## runs through headers and throws unique values into hash
open(IN,"<$header") || die "\n Cannot open the infile: $header\n";

while (<IN>){
	chomp $_;
	@a = split(' ', $_);
        $id = shift @a;

        @id = split(/_/, $id);
	pop @id, pop @id, pop @id,
        $ctgid = join("_", @id);
	$hoh{$ctgid} = 1;
}

close(IN);

$flag = 0;
##matches above headers to tara database and prints out matches.
open(DB,"<$database") || die "\n Cannot open the infile: $database\n";


while (<DB>){
        chomp $_;
        
	if($flag == 1){
	
		if($_ =~/^>/){
		   $flag = 0;
		}
		else{
		   print $_ . "\n";
		}
       }
	
	if($_ =~ /^>/ && $flag == 0){
		@a = split(' ', $_);
        	$id = shift @a;

        	@id = split(/_/, $id);
        	pop @id, pop @id, pop @id,
        	$ctgid = join("_", @id);
        
		if(exists $hoh{$ctgid}){
		print $_ . "\n";
		$flag = 1;
		}
	}
}

close(DB);
