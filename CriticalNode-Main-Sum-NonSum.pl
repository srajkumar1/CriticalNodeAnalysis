#
#	CriticalNode-Main.pl
#
#Data Extraction from DataLake to RAW file
#	Input Parameters:
#		StartDate
#		EndDate
#		Collector List	
#		
#	RAW Fields:
#		F1	TX_DEVICE_ID
#		F2	TX_RC_SMP
#		F3	TX_HOPS
#		F4	TX_LQI
#		F5	TX_MIN_LQI
#		F6	TX_PARENT
#		F7	TX_RX_RSSI
#		F8	TX_TX_RSSI
#		F9	TX_REPORTING
#		F10	DT_ROW_STAT
#		F11	CD_ROW_STAT
#		F12	DT_INSERTED
#		F13	DT_GATE_DOWNLOAD
#		F14	EXT_ETLTIME
#
#	Changes:
#	2018-06-01:	Changed the sort date from F13 to F10 at CriticalNode-Main.pl & CriticalNode-Sub-ND.pl
#				Disabled CriticalNode-Sub-SAT.pl from CriticalNode-Main.pl
#
#
my $DIRout="C:\\Scripts\\1-out\\";
my $DIRin="C:\\Scripts\\1-in\\";
my $log=$DIRout."LOG.txt";
my $input=$DIRin."CNparameter.txt";
my $var=$DIRout."cn-var.csv";
my $vars=$DIRout."cn-var-s.csv";
my $varns=$DIRout."cn-var-ns.csv";
my $stat=$DIRout."cn-stat.csv";
my $PIQ="C:\\PROGRA~1\\SYBASEIQ\\IQ-16_0\\Bin32\\dbisql.com -c ";
my $DB="\"UID=UA273896\;PWD=St0p2\@1899\;DBN=PIQ\;ASTART=No\;host=Milp7716,hydroone.com\" ";
my $SQL1="\"select * from MRD.TS_IRTT_NETWORK_STATS_CMOM where TX_RC_SMP = ";
open (LOG, ">$log")|| die "Cann't open file: $log";
print LOG "CriticalNode-Main.pl:	Script Starttime = ".(localtime),"\n";
close LOG;
open(IN, $input)|| die "Cann't open file: $input";
while (<IN>)
{	
	chmop;
	my $line=$_;
	if ( $line =~ /StartDate=/)
	{
		($f1,$f2) = split /=/, $line;
		$startdate=substr $f2,0,10;
	}
	if ( $line =~ /EndDate=/)
	{
		($f1,$f2) = split /=/, $line;
		$enddate=substr $f2,0,10;
	}
}
close IN;
#
open (VAR, ">$var")|| die "Cann't open file: $var";
close VAR;
open (VARS, ">$vars")|| die "Cann't open file: $vars";
close VARS;
open (VARNS, ">$varns")|| die "Cann't open file: $varns";
close VARNS;
#open (STAT, ">$stat")|| die "Cann't open file: $stat";
#close STAT;
open(IN, $input)|| die "Cann't open file: $input";
while (<IN>)
{
	chomp;
	my $col = $_;
	if ( $col =~ /RC-/ )
	{
		my $SQL2="'".$col."' ";
		my $SQL3="and DT_ROW_STAT > '".$startdate."' and DT_ROW_STAT < '".$enddate."'\;";
		my $SQL4="OUTPUT TO C:\\Scripts\\1-out\\".$col.".raw FORMAT TEXT\"";
		my $cmd=$PIQ.$DB.$SQL1.$SQL2.$SQL3.$SQL4;
		open (LOG, ">>$log")|| die "Cann't open file: $log";
		print LOG "CriticalNode-Main.pl:	$cmd\n";
		close LOG;
		system($cmd);
		$cmd="perl C:\\Scripts\\1-perl\\CriticalNode-Sub-ND.pl $col";
		print  "\n$cmd\n";
		system($cmd);
		$cmd="perl C:\\Scripts\\1-perl\\CriticalNode-Sub-VAR.pl $col";
		print  "\n$cmd\n";
		system($cmd);		
		$cmd="perl C:\\Scripts\\1-perl\\CriticalNode-Sub-VAR-S.pl $col";
		print  "\n$cmd\n";
		system($cmd);
		$cmd="perl C:\\Scripts\\1-perl\\CriticalNode-Sub-VAR-NS.pl $col";
		print  "\n$cmd\n";
		system($cmd);
#		$cmd="perl C:\\Scripts\\1-perl\\CriticalNode-Sub-SAT.pl $col";
#		print  "\n$cmd\n";
#		system($cmd);
	}	
}
close IN;
open (LOG, ">>$log")|| die "Cann't open file: $log";
print LOG "CriticalNode-Main.pl:	Script Endtime = ".(localtime),"\n";
close LOG;
exit 0;	
#
#	