#! /usr/bin/perl -w

# The MIT License (MIT)
# 
# Copyright (c) 2014, Cathal Garvey, ALL RIGHTS RESERVED.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


use strict;
use Term::ReadKey;

# Config...
my( $sManagedObjectName ) = "mo"; #The NSManagedObject instance name
my( $sConstPrefix ) = "kDBKey"; # has Model class name appended to it and then the camel-case field name.

if( $#ARGV == 2 ) {
	if( -r( $ARGV[0] ) ) {
		open( fileIn, $ARGV[0] ) or die( "Couldn't open $ARGV[0].\n" );
		open( fileOutInstFromJSON, ">./out-inst-from-json.txt" ) or die( "Couldn't open out-inst-from-json.txt for writing.\n" );
		open( fileOutInstFromMO, ">./out-inst-from-mo.txt" ) or die( "Couldn't open out-inst-from-mo.txt for writing.\n" );
		open( fileOutMOSet, ">./out-mo-set.txt" ) or die( "Couldn't open out-mo-set.txt for writing.\n" );
		open( fileOutModelH, ">./out-model-h.txt" ) or die( "Couldn't open out-model-h.txt for writing.\n" );
		open( fileOutModelM, ">./out-model-m.txt" ) or die( "Couldn't open out-model-m.txt for writing.\n" );
		open( fileOutConsts, ">./out-consts.txt" ) or die( "Couldn't open out-consts.txt for writing.\n" );
		open( fileOutCoreData, ">./out-core-data.txt" ) or die( "Couldn't open out-core-data.txt for writing.\n" );

		my( $line );
		my( $iCount ) = 0;

		print fileOutInstFromMO "$ARGV[1] *$ARGV[2] = [[$ARGV[1] alloc] init];\n\n";
		print fileOutInstFromJSON "$ARGV[1] *$ARGV[2] = [[$ARGV[1] alloc] init];\n\n";
		print fileOutCoreData "\t<entity name=\"$ARGV[1]\" syncable=\"YES\">\n";

		while( defined( $line=<fileIn> ) ) {
			$line =~ s/[\r\n]//g;
			$line =~ s/\t$//g;

			if( $line eq "" || $line =~ /^#.*/ ) { next; } #skip comments / empty lines

			my( @parts ) = split( "\t", $line );
			if( $#parts >= 2 ) {
				my( $fieldInst ) = $parts[0];
				$fieldInst =~ s/_([a-z])/uc($1)/ge;
				$fieldInst =~ s/Id$/ID/g; # ID should be capitalised
				my( $fieldConst ) = $fieldInst;
				$fieldConst =~ s/^([a-z])/uc($1)/ge;

				if( $parts[2] =~ /Bool/i ) {
					print fileOutInstFromJSON "$ARGV[2].$fieldInst = [safeJSONForKey(dic$ARGV[1], \@\"$parts[1]\") boolValue];\n";
					print fileOutInstFromMO "$ARGV[2].$fieldInst = [[$sManagedObjectName valueForKey:$sConstPrefix$ARGV[1]$fieldConst] boolValue];\n";
					print fileOutMOSet "[$sManagedObjectName setValue:[NSNumber numberWithBool:$ARGV[2].$fieldInst] forKey:kDBKey$ARGV[1]$fieldConst];\n";
					print fileOutConsts "#define kDBKey$ARGV[1]$fieldConst \@\"$parts[0]\"\n";
					print fileOutModelH "\@property (nonatomic) BOOL $fieldInst;\n";
					print fileOutModelM "\@synthesize $fieldInst;\n";
					print fileOutCoreData "\t\t<attribute name=\"$parts[0]\" optional=\"YES\" attributeType=\"Boolean\" syncable=\"YES\"/>\n";
				}
				elsif( $parts[2] =~ /string/i ) {
					print fileOutInstFromJSON "$ARGV[2].$fieldInst = safeJSONForKey(dic$ARGV[1], \@\"$parts[1]\");\n";
					print fileOutInstFromMO "$ARGV[2].$fieldInst = [$sManagedObjectName valueForKey:$sConstPrefix$ARGV[1]$fieldConst];\n";
					print fileOutMOSet "[$sManagedObjectName setValue:$ARGV[2].$fieldInst forKey:kDBKey$ARGV[1]$fieldConst];\n";
					print fileOutConsts "#define kDBKey$ARGV[1]$fieldConst \@\"$parts[0]\"\n";
					print fileOutModelH "\@property (nonatomic) NSString *$fieldInst;\n";
					print fileOutModelM "\@synthesize $fieldInst;\n";
					print fileOutCoreData "\t\t<attribute name=\"$parts[0]\" optional=\"YES\" attributeType=\"String\" syncable=\"YES\"/>\n";
				}
				elsif( $parts[2] =~ /integer/i ) {
					print fileOutInstFromJSON "$ARGV[2].$fieldInst = [safeJSONForKey(dic$ARGV[1], \@\"$parts[1]\") integerValue];\n";
					print fileOutInstFromMO "$ARGV[2].$fieldInst = [[$sManagedObjectName valueForKey:$sConstPrefix$ARGV[1]$fieldConst] integerValue];\n";
					print fileOutMOSet "[$sManagedObjectName setValue:[NSNumber numberWithInteger:$ARGV[2].$fieldInst] forKey:kDBKey$ARGV[1]$fieldConst];\n";
					print fileOutConsts "#define kDBKey$ARGV[1]$fieldConst \@\"$parts[0]\"\n";
					print fileOutModelH "\@property (nonatomic) NSInteger $fieldInst;\n";
					print fileOutModelM "\@synthesize $fieldInst;\n";
					print fileOutCoreData "\t\t<attribute name=\"$parts[0]\" optional=\"YES\" attributeType=\"Integer 32\" defaultValueString=\"0\" syncable=\"YES\"/>\n";
				}
				elsif( $parts[2] =~ /double/i ) {
					print fileOutInstFromJSON "$ARGV[2].$fieldInst = [safeJSONForKey(dic$ARGV[1], \@\"$parts[1]\") doubleValue];\n";
					print fileOutInstFromMO "$ARGV[2].$fieldInst = [[$sManagedObjectName valueForKey:$sConstPrefix$ARGV[1]$fieldConst] doubleValue];\n";
					print fileOutMOSet "[$sManagedObjectName setValue:[NSNumber numberWithDouble:$ARGV[2].$fieldInst] forKey:kDBKey$ARGV[1]$fieldConst];\n";
					print fileOutConsts "#define kDBKey$ARGV[1]$fieldConst \@\"$parts[0]\"\n";
					print fileOutModelH "\@property (nonatomic) double $fieldInst;\n";
					print fileOutModelM "\@synthesize $fieldInst;\n";
					print fileOutCoreData "\t\t<attribute name=\"$parts[0]\" optional=\"YES\" attributeType=\"Double\" defaultValueString=\"0.0\" syncable=\"YES\"/>\n";
				}
				elsif( $parts[2] =~ /date/i ) {
					print fileOutInstFromJSON "$ARGV[2].$fieldInst = [self dateFromJSON:safeJSONForKey(dic$ARGV[1], \@\"$parts[1]\")];\n";
					print fileOutInstFromMO "$ARGV[2].$fieldInst = [$sManagedObjectName valueForKey:$sConstPrefix$ARGV[1]$fieldConst];\n";
					print fileOutMOSet "[$sManagedObjectName setValue:$ARGV[2].$fieldInst forKey:kDBKey$ARGV[1]$fieldConst];\n";
					print fileOutConsts "#define kDBKey$ARGV[1]$fieldConst \@\"$parts[0]\"\n";
					print fileOutModelH "\@property (nonatomic) NSDate *$fieldInst;\n";
					print fileOutModelM "\@synthesize $fieldInst;\n";
					print fileOutCoreData "\t\t<attribute name=\"$parts[0]\" optional=\"YES\" attributeType=\"Date\" syncable=\"YES\"/>\n";
				}
				else {
					print "Unhandled type for $parts[0] ($parts[2])\n";
				}

				$iCount += 1;
			}
		}
		print fileOutCoreData "\t</entity>\n";

		close( fileOutCoreData );
		close( fileOutConsts );
		close( fileOutModelM );
		close( fileOutModelH );
		close( fileOutMOSet );
		close( fileOutInstFromMO );
		close( fileOutInstFromJSON );
		close( fileIn );

		print "\n";
		print "Processed $iCount fields.\n";
	}
	else { print "Could not read specified file ($ARGV[0])\n"; }
}
else {
	print "iOS CoreData Code Generator.\n";
	print "\n";
	print "Usage: generate.pl <File Path> <Model Class Name> <Model Instance Var>\n";
	print "   File Path\t\tThe path to the tab-separated (CSV) text file to parse\n\t\t\tfor field names. Col A is the SQL name to be used as\n\t\t\tCoreData field name, and is used to derive the class\n\t\t\tproperty name.\n";
	print "   Model Class Name\tThe custom ORM class name (e.g. User or Car)\n";
	print "   Model Instance Var\tThe instance of that class whose properties will be set\n\t\t\t(e.g. usr or car)\n";
	print "\n";
	print "Output: generates 3 files in the current directory:\n";
	print "   out-inst-set.txt\tCode to set the instance properties of each field.\n";
	print "   out-model-h.txt\tHeader file content for the class model.\n";
	print "   out-model-m.txt\tImplementation file content for the class model.\n";
	print "\n";
}

exit;

