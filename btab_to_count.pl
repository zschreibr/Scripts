#!/usr/bin/perl

=head1 NAME
	btab_to_count.pl  

=head1 SYNOPSIS

    USAGE: batb_to_count.pl -i=btab file

=head1 OPTIONS

B<--input, -i>
	btab file containing annotated ORFs

B<--help,-h>
 
=head1  DESCRIPTION
	Takes the ORFs in a btab file and counts how many ORFs have a position differnce  

=head1  INPUT
	Btab file of called ORFs        

=head1  OUTPUT
        Tab file showing ORF distance and how many times and ORF is distributed across a contig
        
=head1  CONTACT
        Zach Schreiber @ zschreib[at]gmail[dot]com

=head1 EXAMPLE
         btab_to_count.pl

=cut

use strict;
use warnings;
use Pod::Usage;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use List::Util qw(min max);

my %options = ();
my $results = GetOptions (\%options,
                                                  'input|i=s',
                                                  'help|h') || pod2usage();
#### display documentation
if( $options{'help'} ) {
  pod2usage( {-exitval => 0, -verbose => 2, -output => \*STDERR} );
}

##user input error flags
die "Missing input cluster file! -i1\n" unless $options{input};
##end error


##user input
my $infile = $options{input};
my (@a,@id,$ctgid,$position,$orf_id,$function);
my %hoh = ();
##end input

my $rHoH = \%hoh;

print "ORF Position\t Count of occurrence\n";

open(IN,"<$infile") || die "\n Cannot open the infile: $infile\n";

while (<IN>){
	chomp $_;
	$orf_id = (split /\t/, $_)[0];
	$function = (split /\t/, $_)[-1];

	@a = (split /_/, $orf_id);
	$position = pop @a;

	@id = split(/_/, $orf_id);
	pop @id, pop @id, pop @id;
	$ctgid = join("_", @id); 
	$hoh{$ctgid}{'POSITION'}[$position-1] = $position;
	$hoh{$ctgid}{'FUNCTION'}[$position-1] = $function;
}

my %counter = ();

foreach my $ctgid (keys %$rHoH){
        for (my $i=0; $i < scalar(@{$rHoH->{$ctgid}->{'POSITION'}}); $i++){
		if(exists $rHoH->{$ctgid}->{'POSITION'}[$i]){
			my $ab = $rHoH->{$ctgid}->{'POSITION'}[$i] - $rHoH->{$ctgid}->{'POSITION'}[$i];
			$counter{$ab}++;
		}	
                	if(exists $rHoH->{$ctgid}->{'POSITION'}[$i]){
                		for (my $j = $i+1; $j < scalar(@{$rHoH->{$ctgid}->{'POSITION'}}); $j++) {
					if(exists $rHoH->{$ctgid}->{'POSITION'}[$j]){
							my $bc = $rHoH->{$ctgid}->{'POSITION'}[$j] - $rHoH->{$ctgid}->{'POSITION'}[$i];
                        				$counter{$bc}++;
                			}
                                }
                        }
			for (my $j = $i-1; $j >= 0; $j--) {
                		if(exists $rHoH->{$ctgid}->{'POSITION'}[$i]){
                      			if(exists $rHoH->{$ctgid}->{'POSITION'}[$j]){
                       				if(exists $rHoH->{$ctgid}->{'POSITION'}[$i]){
						      my $ab = $rHoH->{$ctgid}->{'POSITION'}[$i] - $rHoH->{$ctgid}->{'POSITION'}[$j];
						      $counter{$ab}++;
                				}

                      			}
                		}

	        	}
	}
}

foreach my $counter (sort keys %counter){
	print "$counter\t$counter{$counter}\n";
}

exit 0;
