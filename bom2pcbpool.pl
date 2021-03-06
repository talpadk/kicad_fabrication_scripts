#!/usr/bin/perl

use strict;
use File::HomeDir;

my %headerElementLookup = ();
my %supplierUrls = ();

my $dataPath = File::HomeDir->my_data."/kicad_scripts_data/";

my $file;
my $supplierUrlsFilename = $dataPath."supplierLinks.txt";

if (open($file, "<$supplierUrlsFilename")){
    while (<$file>){
	my $line = $_;
	if ($line =~ /^\s*([\w+-_]+\:\:[\w-+_]+)\s*=\s*(\S+)\s*$/){
	    $supplierUrls{lc($1)}=$2;
	}
    }
    close($file);
}


my @headerElements = split(/,/, <STDIN>);
my $index = 0;
foreach my $element (@headerElements){
    $element =~ s/^\s+|\s+$//g;
    $element = lc($element);
    $headerElementLookup{$element}=$index;
    $index++;
}
    
print "Part,Value,Device,Package,Description,Description2,Qty,Place_YES/NO,Provided_by_customer_YES/NO,Distributor,Ordernumber,Weblink,Remarks_customer,Manufacturer,ManufacturerPN\n";

my @elements = ();
my $firstOnLine = 1;

sub output{
    my $name = $_[0];
    our %headerElementsLookup;
    our @elements;
    our $firstOnLine;

    
    my $data;
    if (defined($headerElementLookup{$name})){
	$data = $elements[$headerElementLookup{$name}];
    }
    else {
	$data = "";

	#Attempt to auto fill supplierlink
	if ($name eq "supplierlink"){
	    if (defined($elements[$headerElementLookup{"supplier"}]) &&
		defined($elements[$headerElementLookup{"supplierpn"}])){
		my $supplier = lc($elements[$headerElementLookup{"supplier"}]);
		my $supplierPn = lc($elements[$headerElementLookup{"supplierpn"}]);

		if (defined($supplierUrls{"$supplier\:\:$supplierPn"})){
		    $data = $supplierUrls{"$supplier\:\:$supplierPn"};
		}
	    }
	}	
    }
    $data =~ s/^\s+|\s+$//g;


    if (!$firstOnLine){
	print ',';
    }
    print $data;
    $firstOnLine = 0;
}

sub outputSupplied {
    my $place;
    our %headerElementsLookup;
    our @elements;
    our $firstOnLine;
    
    if (defined($headerElementLookup{'place'})){
	$place = $elements[$headerElementLookup{'place'}];
    }
    else {
	die ("Place information not found\n");
    }
    $place =~ s/^\s+|\s+$//g;

    if (!$firstOnLine){
	print ',';
    }
    $firstOnLine = 0;
    
    if ($place eq "no"){
	print "no";
    }
    else {
	#	print "$place";
	print "no";
    }
}

while (<STDIN>){
    our @elements = split(/,/, $_);
    our $firstOnLine = 1;

    output('reference');
    output('value');
    output('device');
    output('footprint');
    output('description');
    output('description2');
    print ",1";
    output('place');
    outputSupplied();
    output('supplier');
    output('supplierpn');
    output('supplierlink');
    output('remarks');
    output('manufacturer');
    output('manufacturerpn');
    print "\n";
}
