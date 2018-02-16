#!/usr/bin/perl -w

use warnings;
use strict;
use XML::DOM;
use Data::Dumper;
use DBI;


## DATABASE INFO ###
open(ACCESS_INFO, "/home/zschreib/Project/viral_dark_matter/.accessDB") || die "Can't access login credentials";
# assign the values in the accessDB file to the variables
my $userid = <ACCESS_INFO>;
my $passwd = <ACCESS_INFO>;
# the chomp() function will remove any newline character from the end of a string
chomp ($userid, $passwd);
# close the accessDB file
close(ACCESS_INFO);

my $libID = $ARGV[0];
my $db = $ARGV[1];

my @databases = ("ACLAME","COG","GO","KEGG","SEED","PHGSEED");
my $xfile;
my $ifile;
my $parser;
my $xdoc;
my $idoc;
my $err;
my @log;
my $par;
my $outfile = "/home/zschreib/Project/viral_dark_matter/";
my $filename = $libID . "_" . $db;
my $dir = "/home/zschreib/Project/viral_dark_matter/" . $db . "/" . $filename;

open(OUTPUT, '>', $dir) or die "Could not open file '$filename' $!";

$xfile = "/data/wwwroot/virome/app/xDocs/" . $db . "_XMLDOC_$libID.xml";
$ifile = "/data/wwwroot/virome/app/xDocs/" . $db . "_IDDOC_$libID.xml";
 
if (-e $xfile){
  $parser = new XML::DOM::Parser;
  $xdoc = $parser->parsefile($xfile);
  $idoc = $parser->parsefile($ifile);
  &traverse_XML_tree2( $xdoc, "root" );
 }

 else {
    $err = print STDERR "No $xfile file for database $db and library ID[$libID]. \n";
  }

close OUTPUT;

#########################################################################
sub traverse_XML_tree2 {
    my ( $doc, $startingTag ) = @_;    #load passed in parameters.

    #### find all the <p> elements
    my $paras = $doc->getElementsByTagName($startingTag);

    for ( my $i = 0 ; $i < $paras->getLength ; $i++ ) {
        my $para = $paras->item($i);
        &traverse_XML_tree_recursive($para, "");
    }
}

#########################################################################
# Looking at a recursive way to traverse the XML::DOM tree.
sub traverse_XML_tree_recursive {
    my ($para, $str) = @_;                   # Reading in the parameters.
    $str .= "\t".$para->getAttribute('NAME');
    #### for each child of a <p>, if it is a text node, process it
    #### See (http://cpan.uwinnipeg.ca/htdocs/XML-DOM/XML/DOM.html)for constant definitions
    my @children = $para->getChildNodes;

    #### I'm checking to see if there's nothing in the array -- no children -- by counting the array size.
   my $numberOfChildren = ($#children) + 1;
   if ($db eq "GO"){
	$db = "UNIREF100P";
   }
   if ( $numberOfChildren <= 0 ) {
        my $idList = $idoc->getElementsByTagName($para->getAttribute('TAG'))->item(0)->getAttribute('IDLIST');
             foreach my $i (split /,/, $idList) {
	      my $additional_info = MySQL("select b.query_name, b.e_value, hd.description from blastp_tophit b inner join blast_database_lookup bdl on b.blast_db_lookup_id=bdl.id inner join hit_description hd on b.hit_description_id=hd.id where sequenceId=$i and fxn_topHit=1 and bdl.db_name='" .$db. "'");
	      #print $additional_info . "\n";
              $par = $additional_info . "\t" . $i . $str . "\n";
	      $par =~ s/\t{2,}/\t/g;
	      print OUTPUT $par;
        }
        
        return; 
 }

    foreach my $node (@children) {
        if ( $node->getNodeType eq ELEMENT_NODE ) {
            my $nodeTagName = $node->getTagName;
            &traverse_XML_tree_recursive($node, $str);
        }
    }
}

#########################################################################


sub MySQL
{
    # establish connection with 'serverDNA' database
    my $connection = DBI->connect("DBI:mysql:vir_data_devel",$userid,$passwd);
    my $query = shift;  #assign argument to string
    my $statement = $connection->prepare($query);   #prepare query

    $statement->execute();   #execute query

    #loop to print MySQL results
    while (my @row = $statement->fetchrow_array)
    {       local $" = "\t";
            return "@row";
    }
}

########################################################################


