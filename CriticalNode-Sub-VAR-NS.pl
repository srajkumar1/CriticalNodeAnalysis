# 
#	CriticalNode-Sub-VAR-NS.pl
#	(For Non-Summer Months)
#
#	From SUM to VAR file
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
#	VAR Fields:
#		F1	Collector
#		F2	Node
#		F3	Next Node
#		F4	Ave Hop Count (from calculated value)
#		F5	Ave Child Count
#		F6	Ave Child Count Percentage
#		F7	Next Node Count
#		F8	Total Sample Count
#		F9	Percentage of Next Node 
#		F10	Year
#
#
use List::MoreUtils qw(uniq);
use List::Util qw< min max >;
my $col= $ARGV[0];
my $DIRout="C:\\Scripts\\1-out\\";
my $DIRin="C:\\Scripts\\1-in\\";
my $log=$DIRout."LOG.txt";
my $sum=$DIRout.$col.".sum";
my $varns=$DIRout."cn-var-ns.csv";
my $t4=$DIRout."t4.out";
my $summer="06 07 08 09";
#
# t5 content to be used by CriticalNode-Sub-SUM.pl
### not using t5 and SAT files in new analysis
#my $t5=$DIRout."t5.out";
#
open(LOG,">>$log")|| die "Cann't open file: $log";
my $colsmpfile=$DIRin."col-smp.txt";
my $rc,$dev,$nextdev,$hops,$hopcal,$count,$ratio,$rxrssi,$txrssi,$gdate,$f1,$f2;
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
$cmd="C:\\GnuWin32\\bin\\sort.exe -k2,2 -k3,3 -k10,10 $sum > $t4"; 
print "$cmd\n";
system($cmd);
#
# 1st loop, calculate:	
#		- total sample count per device	[$totcnt]
#		- total sample count per device.nextdevice	[$cnt]
#
# 2nd loop, calculate:
#		- ave hop count per next device 
#		- ave child count per next device 
#		- ave child count percentage per next device 
#		- percentage of next device sample count 
#
######################
# Output to VAR file for non-summer months ( excluding June, July, Aug, Sept)
#
my $i=0;
open(T4, $t4)|| die "Cann't open file: $t4";
while (<T4>)
{
	chomp;
	$line = $_;
	($gate,$dev,$nextdev,$hops,$hop,$count,$ratio,$rxrssi,$txrssi,$gdate) = split /,/, $line;
	($gdyear,$gdmth,$gdday) = split /-/, $gdate;
	if ($summer !~ /$gdmth/)
	{
		$xlist[$i] = $dev;
		push @{$dev}, $dev;
		$devnd=$dev.",".$nextdev;
		push @{$devnd},$nextdev;
		$i++;
	}		
}	
my @xlist = sort(@xlist);
my @xxlist = uniq @xlist;
close T4;
#
#	Assign array h.device.nextdevice and add hop count to array content
#	Assign array c.device.nextdevice and add child count to array content
#	Assign array r.device.nextdevice and add child count percentage to array content
#
$i=0;
open(T4, $t4)|| die "Cann't open file: $t4";
while (<T4>)
{
	chomp;
	$line = $_;
	($gate,$dev,$nextdev,$hops,$hop,$count,$ratio,$rxrssi,$txrssi,$gdate) = split /,/, $line;
	($gdyear,$gdmth,$gdday) = split /-/, $gdate;
	if ($summer !~ /$gdmth/)
	{
		$devnd=$dev.",".$nextdev;
		$ylist[$i]=$devnd;
		$i++;
		$devndhop="h".$devnd;
		$devndchild="c".$devnd;	
		$devndratio="r".$devnd;
		push @{$devndhop},$hop;
		push @{$devndchild},$count;
		push @{$devndratio},$ratio;	
	}	
}
close T4;
open (VARNS, ">>$varns") || die "Cann't open file: $varns";
# not using T5 and SAT files in new analysis
#open (T5, ">$t5") || die "Cann't open file: $t5";
my @ylist = sort(@ylist);
my @yylist = uniq @ylist;
foreach $i (0 ..$#yylist)
{
	$devnd=$yylist[$i];
	($dev,$nextdev)= split /,/,$devnd;
	$devndhop="h".$devnd;
	$devndchild="c".$devnd;	
	$devndratio="r".$devnd;
	my ($hmax,$hmin,$hmean,$hstd) = statsub(@$devndhop);
	my ($cmax,$cmin,$cmean,$cstd) = statsub(@$devndchild);	
	my ($rmax,$rmin,$rmean,$rstd) = statsub(@$devndratio);
	$totcnt = scalar @$dev;
	$cnt = scalar @$devnd;	
	$avepath=100*$cnt/$totcnt;	
	if ($i = 0) { $tdev=$dev; $maxpath=0;}
# 	output $maxpath	to T5 when change of $dev
#	if ($dev !~ $tdev) 
#	{
#		print T5 "$col,$tdev,";
#		printf T5 "%.1f", $maxpath;
#		print T5 "\n";	
#		$maxpath=0;
#	}	
	if ($avepath > $maxpath) {$maxpath=$avepath;}
	$tdev=$dev;
	print VARNS "$col,$dev,$nextdev,";
	printf VARNS "%.0f,%.0f,%.0f,%.0f,%.0f,%.1f",$hmean,$cmean,$rmean,$cnt,$totcnt,$avepath;
	print VARNS "\n";		
}
close VARNS;
#print T5 "$col,$tdev,";
#printf T5 "%.1f", $maxpath;
#print T5 "\n";	
#close T5;

exit 0;
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
#