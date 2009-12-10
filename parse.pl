#!/usr/bin/perl

# run flow
# 1.load user assign projectname + "-packagelist.txt", and get field
# 2.export projectname + "wget.sh"
# 3.replace keyword for script, and export install.sh

$parseid = $ARGV[0] || '';

if( $parseid eq '' ) {
    die 'ERROR: parse.pl PROJECTNAME'."\n";
}

$parseid = $parseid . '-';

$packagelist = $parseid . 'packagelist.txt';

$template = $parseid . 'template.txt';

unless( -f $packagelist ){
	die $packagelist.' does not exist'."\n";
}

unless( -f $template ){
	die $template.' does not exist'."\n";
}


# load txt to variable
open(FH,$packagelist);
while(<FH>){
	next if $_=~/^#/;
	next unless $_ =~ /^(.*)\,(.*)\,(.*)\,(.*)$/;
	#push @wgets,$3;
	$Package{$1}  = $2;
	$Unzipdir{$1} = $3;
	$Url{$1}      = $4;
}# end while FH
close FH;

$wgetfile = $parseid . 'wget.sh';

# export wget.sh file 
open(FH,'>'.$wgetfile);
print FH '# This file is auto generate,dont modify it!!'."\n";
while( ($key,$value) = each(%Url) ){
	#print $value."\n";
    #print FH 'wget --recursive --tries=1 ' . $value . "\n";
	print FH 'wget --tries=1 ' . $value . "\n";
}# end while Url
print FH '# End generate';
close FH;

print 'parse ' . $wgetfile . ' success'."\n";

# load install script to variable(array)
open(FH,$template);
while(<FH>){
	$_ =~ s/\n$//;
	next if( ($_ =~ /^#/) and ($_ !~ /^#!\//) );
	next if $_ eq '';
	push @installs,$_;
}# end while
close FH;

$runscript = $parseid . 'runscript.sh';

# replace keyword, and export script file
open(FH,'>'.$runscript);
for $install ( @installs ){
	while( ($key,$value)=each(%Package) ){
				
		# compare keyword for "package"
		$condition = '%'.$key.'_package'.'%';		
		if( $install =~ /$condition/ ){
			$install =~ s/$condition/$value/;
		}# end if install
		
		# compare keyword for "unzipdir"
		$condition = '%'.$key.'_unzipdir'.'%';		
		if( $install =~ /$condition/ ){
			# if "unzipdir" field is empty, then cut package-name's .tar.gz
			if( $Unzipdir{$key} eq '' ){
				$unzipdir = $value;
				$unzipdir =~ s/\.tar\.gz$//;
			} else {
			  $unzipdir = $Unzipdir{$key};
			}# end if Unzipdir
			$install =~ s/$condition/$unzipdir/;
		}# end if install		
		
	}# end while key value
	print FH $install."\n";
}# end for installs
close FH;

# ok~ success
print 'parse ' . $runscript . ' success'."\n";
