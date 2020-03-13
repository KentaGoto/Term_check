use strict;
use warnings;
use utf8;
use Encode qw/encode decode/;

binmode STDIN, ':encoding(cp932)';
binmode STDOUT, ':encoding(cp932)';
binmode STDERR, ':encoding(cp932)';


# loading target file
printf "Tab-delimited bilingual text file (* .txt): ";
chomp( my $data = <STDIN> );
open ( DATA, "<:utf8", $data ) or die "$!:$data";
my @data = <DATA>;

# loading term list file
printf "Tab-delimited glossary text file (* .txt): ";
chomp( my $term = <STDIN> );
open ( TERM, "<:utf8", $term ) or die "$!:$term";
my @term = <TERM>;

# Date
my $times = time();
my ($sec, $min, $hour, $mday, $month, $year, $wday, $stime) = localtime($times);
$month++;
my $datetime = sprintf '%04d%02d%02d%02d%02d%02d', $year + 1900, $month, $mday, $hour, $min, $sec;

# log header
my $header  = <<__HEAD__;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="ja" lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style Type="text/css">
	body{
		font-family: 'Arial', 'MS PGothic';
		}
	table{
		table-layout: fixed;
		width:100%;
	}
	.pink{background-color:pink;
		 font-weight:bold;}
	.gray{color:#CCCCCC;}
</style>
<title>Matched Term</title>
<body>
<table border="3">

__HEAD__

# generate log file1(html)
open( OUT, ">>:utf8", "!After_check_$datetime.html" ) or die "$!:!After_check$datetime.html";
print OUT "$header\n";
print OUT qq{<tr bgcolor="#90ee90"><td><p><b>Source segment</b></p></td><td><p><b>Target segment</b></p></td><td><p><b>Source term</b></p></td><td><p><b>Target term</b></p></td></tr>}."\n";

# Main
my %output;
foreach my $i ( @data ){
	my $data_source = ( split(/\t/, $i) )[0];
	$data_source =~ s{^\s*(.*?)\s*$}{$1}; #不要な空白があったら削除
	my $data_target = ( split(/\t/, $i) )[1];
	$data_target =~ s{^\s*(.*?)\s*$}{$1}; #不要な空白があったら削除
	foreach my $j ( @term ){
			my $term_source = ( split( /\t/, $j ) )[0];
			$term_source =~ s{^\s*(.*?)\s*$}{$1}; #不要な空白があったら削除
			my $term_target = ( split( /\t/, $j ) )[1];
			$term_target =~ s{^\s*(.*?)\s*$}{$1}; #不要な空白があったら削除
			if ( $data_source =~ m{\Q$term_source\E} and $data_target !~ m{\Q$term_target\E}){
				$data_source =~ s{&}{&amp;}g;
				$data_source =~ s{<}{&lt;}g;
				$data_source =~ s{>}{&gt;}g;
				$data_source =~ s{"}{&quot;}g;
				$data_source =~ s{'}{&apos;}g;
				$data_source =~ s{($term_source)}{<span class=\"pink\">$1</span>}g;
				$output{"$data_source"."\t"."$data_target"."\t"."$term_source"."\t"."$term_target"}++; #Main log 出力用
				}
		}
}

# 重複したセグメントはユニークにして対訳表で出力(html)。順不同。
for my $key ( keys %output ){
	my $data_source_key = ( split( /\t/, $key ) )[0];
	my $data_target_key = ( split( /\t/, $key ) )[1];
	my $term_source_key = ( split( /\t/, $key ) )[2];
	my $term_target_key = ( split( /\t/, $key ) )[3];
	print  OUT "<tr><td><p>$data_source_key</p></td><td><p>$data_target_key</p></td><td><p>$term_source_key</p></td><td><p>$term_target_key</p></td></tr>"."\n";
}

# log footer
my$footer = <<__FOOT__;
</table>
</body>
</html>
__FOOT__

open( OUT, ">>:utf8", "!After_check_$datetime.html" ) or die "$!:!After_check$datetime.html";
print OUT "$footer\n";

print "\nDone!\n";

close (DATA);
close (TERM);
close (OUT);
