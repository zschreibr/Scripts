#!/usr/bin/perl

=head1 NAME
	template.pl  

=head1 SYNOPSIS

    USAGE: template.pl

=head1 OPTIONS

B<--input_cluster, -i1>
   
B<--input_ref, -i2>
 
B<--help,-h>
 
=head1  DESCRIPTION

=head1  INPUT
        
=head1  OUTPUT
             
        
=head1  CONTACT
        Zach Schreiber @ zschreib[at]gmail[dot]com

=head1 EXAMPLE
         template.pl -i1= -i2=

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

