# 
#	CriticalNode-Sub-SAT.pl
#
#	From SUM to STAT file
#
#
#	SUM Fields:
#		F1	Collector
#		F2	Node
#		F3	Next Node
#		F4	HOPS
#		F5	HOPS_Calculated
#		F6	Child Count
#		F7	Child Count Percentage
#		F8	RX_RSSI
#		F9	TX_RSSI
#		F10	GATE_DOWNLOAD_Date	
#		
#	STAT Fields:
#		F1	Collector
#		F2	Node
#		F3	Ave Child Count
#		F4	Max Child Count
#		F5	Min Child Count
#		F6	StdDev Child Count
#		F7	Ave Child Count Percentage
#		F8	Ave Hop Count (from calculated value)
#		F9	Max Hop Count (from calculated value)
#		F10	Min Hop Count (from calculated value)
#		F11	StdDev Hop Count (from calculated value)
#		F12	Ave RX_RSSI
#		F13	Max RX_RSSI
#		F14	Min RX_RSSI
#		F15	StdDev RX_RSSI
#		F16	Ave TX_RSSI
#		F17	Max TX_RSSI
#		F18	Min TX_RSSI
#		F19	StdDev TX_RSSI
#		F20	highest percentage next hop
#		F21	Total Sample Count		
#
#
use List::MoreUtils qw(uniq);
use List::Util qw< min max >;
my $col= $ARGV[0];
my $DIRout="C:\\Scripts\\1-out\\";
my $DIRin="C:\\Scripts\\1-in\\";
my $log=$DIRout."LOG.txt";
my $sum=$DIRout.$col.".sum";
my $t4=$DIRout."t4.out";
my $t5=$DIRout."t5.out";
my $var=$DIRout."cn-var.csv";
my $stat=$DIRout."cn-stat.csv";
my $colsmpfile=$DIRin."col-smp.txt";
my $rc,$dev,$nextdev,$hops,$hopcal,$count,$ratio,$rxrssi,$txrssi,$gdate,$f1,$f2,$path;
open(LOG,">>$log") || die "Cann't open file: $log";
open(COLSMP,$colsmpfile)|| die "Cann't open file: $colsmpfile";
my $colsmp="nomatch";
while (<COLSMP>)
{
	chomp;
	($f1,$f2) = split /,/, $_;
	if ($f2 =~ $col) {
		$colsmp = $f1;
		$colsmp =~ s/\s+//;
		$colsmp =~ s/'//g;
		last;
	}
}
close COLSMP;
#
open(T5, $t5);
while (<T5>)
{
	chomp;
	my $line = $_;
	my ($gate,$dev,$path) = split /,/, $line;
	my $devpath="p".$dev;
	push @{$devpath},$path;
}
#
#
#
open(SUM, $sum);
my $i=0;
while (<SUM>)
{
	chomp;
	my $line = $_;
	my ($gate,$dev,$nextdev,$hops,$hop,$count,$ratio,$rxrssi,$txrssi,$gdate) = split /,/, $line;
	$xlist[$i] = $dev;
	push @{$dev}, $dev;
	$i++;
}
my @xlist = sort(@xlist);
my @xxlist = uniq @xlist;
close SUM;
open(SUM, $sum);
while (<SUM>)
{
	chomp;
	$line = $_;
	($gate,$dev,$nextdev,$hops,$hop,$count,$ratio,$rxrssi,$txrssi,$gdate) = split /,/, $line;
	foreach $i (0 ..$#xxlist)
	{
		if ($dev =~ $xxlist[$i]) 
		{
			$devsd="s".$dev;
			push @{$devsd},$count;
			$devhsd="hs".$dev;
			push @{$devhsd},$hops;
			$devhd="h".$dev;
			push @{$devhd},$hop;
			$devrd="r".$dev;
			push @{$devrd},$ratio;
			$devrsd="rs".$dev;
			push @{$devrsd},$rxrssi;
			$devtsd="ts".$dev;
			push @{$devtsd},$txrssi;
		}			
	}
}
close SUM;
open(STAT, ">>$stat") || die "Cann't open file: $stat";
foreach $i (0 ..$#xxlist)
{
	$dev=$xxlist[$i];
	$cnt = scalar @$dev;
	$devsd="s".$dev;
	$devhd="h".$dev;
	$devrd="r".$dev;
	$devrsd="rs".$dev;
	$devtsd="ts".$dev;
	#
	$devpath="p".$dev;
	@patharray=@$devpath;
	$path=$patharray[0];
	#	
	my ($cmax,$cmin,$cmean,$cstd) = statsub(@$devsd);
	my ($hmax,$hmin,$hmean,$hstd) = hstatsub(@$devhd);	
	my ($rmax,$rmin,$rmean,$rstd) = statsub(@$devrd);	
	my ($rsmax,$rsmin,$rsmean,$rsstd) = statsub(@$devrsd);
	my ($tsmax,$tsmin,$tsmean,$tsstd) = statsub(@$devtsd);
	print STAT "$col,$dev,";
	printf STAT "%.0f,%.0f,%.0f,%.0f", $hmean,$hmax,$hmin,$hstd;
	print STAT ",";		
	printf STAT "%.0f,%.0f,%.0f,%.0f,%.1f", $cmean,$cmax,$cmin,$cstd,$rmean;
	print STAT ",";	
	printf STAT "%.0f,%.0f,%.0f,%.0f", $rsmean,$rsmax,$rsmin,$rsstd;	
	print STAT ",";	
	printf STAT "%.0f,%.0f,%.0f,%.0f", $tsmean,$tsmax,$tsmin,$tsstd;
	print STAT ",";		
	printf STAT "%.1f", $path;
	print STAT ",$cnt\n";
}		
close STAT;
exit;
#
#
sub statsub {
	my (@values) = @_;
	my $n = 0;
	my $sum = 0;
	my %seen = ();
	foreach my $i (0..$#values)
	{ 
		$n++;
		my $num = 0; 
		$sum += $values[$i];
		$seen{$num}++;
	}
	my $mean = $sum / $n;
	my $sqsum = 0;
	for (@values) {
		$sqsum += ( $_ ** 2 );
	} 
	$sqsum /= $n;
	$sqsum -= ( $mean ** 2 );
	if ($sqsum < 0) { $sqsum=0; }
	my $stdev = sqrt($sqsum);
	my $max_seen_count = max values %seen;
	my $median;
	my $mid = int @values/2;
	my @sorted_values = sort @values;
	if (@values % 2) {
		$median = $sorted_values[ $mid ];
	} else {
		$median = ($sorted_values[$mid-1] + $sorted_values[$mid])/2;
	} 
	my $min = min @values;
	my $max = max @values;
	my @result = ($max,$min,$mean,$stdev);
	return @result;
}
#
sub hstatsub {
	my (@values) = @_;
	my $n = 0;
	my $sum = 0;
	my %seen = ();
	foreach my $i (0..$#values)
	{ 
		$n++;
		my $num = 0; 
		$sum += $values[$i];
		$seen{$num}++;
	}
	my $mean = $sum / $n;
	my $sqsum = 0;
	for (@values) {
		$sqsum += ( $_ ** 2 );
	} 
	$sqsum /= $n;
	$sqsum -= ( $mean ** 2 );
	my $stdev = sqrt($sqsum);
	my $max_seen_count = max values %seen;
	my $median;
	my $mid = int @values/2;
	my @sorted_values = sort @values;
	if (@values % 2) {
		$median = $sorted_values[ $mid ];
	} else {
		$median = ($sorted_values[$mid-1] + $sorted_values[$mid])/2;
	} 
	my $min = 16;
	my $max = 0;
	#
	foreach my $i (0..$#values)
	{ 
		my $check = $values[$i];
		if (length($check) > 0)
		{
			if ( $check > $max) { $max = $check;}
			if ( $check < $min) { $min = $check;}
		}	
	}
	#
	my @result = ($max,$min,$mean,$stdev);
	return @result;
}
