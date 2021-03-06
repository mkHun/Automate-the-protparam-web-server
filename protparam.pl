use warnings;
use strict;
use WWW::Mechanize;
my $mech = WWW::Mechanize->new;
print "Enter your input filename: ";
chomp(my $input = <STDIN>);
print "OUtput file format is 'some_file_name.out.txt'";
my $hypn = "*" x 100;
open my $fh, "<:crlf", $input or die "File not found $!";

open my $wh, ">","$input.out.txt";
my ($header,$sequence);
while(<$fh>)
{
	chomp;
	if(/^>/)
	{
		$header//= "0";
		$sequence//="0";
		hussain();
		$header = $_;
		$sequence = "";
	}
	else
	{
		$sequence.=$_;
	}
	END
	{
		hussain();
	}
}

sub hussain
{
	return if($sequence eq "0");
	print $wh  "$header\n";
	$mech->get('http://web.expasy.org/protparam/');
	$mech->submit_form(
		form_number => 1,
		fields => {
			'sequence' => $sequence,
		},
	);
	my $za = $mech->content;
	my ($aacd) = $za =~m/(Number of amino acids:\D+\d+)/g;
	my ($wt) = $za =~m/(Molecular weight:\D+.+)/g;
	my ($pi) = $za =~m/(Theoretical pI:\D+.+)/g;
	my ($asp_glu)= $za =~m/\(Asp \+ Glu\):\D+(.+)/g;
	my ($arg_lys) = $za =~m/\(Arg \+ Lys\):\D+(.+)/g;
	my ($form)= $za =~m/cgi-bin\/protparam\/export_protparam\.pl(.+?)<\/form/sg;
	my @amino_composition = $form =~m/(\w+\s+\(\w+\)[^%]+%)/g;
	my ($formula) = $za =~m/Formula(.+?)Total number of atoms/sg;
	$formula =~s/<\/?B>//g;
	my ($atoms) = $za =~m/(Total number of negatively charged residues \(Asp \+ Glu.+\(GRAVY\):[^\d]+\d+\.?\d+)/s;
	$aacd=~s/<\/B>//g;
	$wt=~s/<\/B>//g;
	$pi=~s/<\/B>//g;
	$asp_glu=~s/<\/B>//g;
	$arg_lys=~s/<\/B>//g;
	$atoms=~s/<B>(\w+\s\w+:)<\/B>\n/"$1\n"."-" x length($1)/seg;
	$atoms =~s/Estimated half-life:/Estimated half-life:\n--------------------/;
	$atoms=~s/(<B>|<\/B>)//g;
	$atoms=~s/\n/\r\n/g;
	print $wh "$aacd\n$wt\n$pi";
	print $wh  "\r\n\r\nAmino acid composition: \r\n-----------------------\r\n";
	print $wh  join"\n",@amino_composition,"\n";
	print $wh  "$atoms\r\n\r\n\r\n$hypn\r\n\r\n\r\n";
	print "$header-----Finished\r\n";
}
