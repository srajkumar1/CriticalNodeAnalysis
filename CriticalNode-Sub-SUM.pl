####
####	CriticalNode-Sub-SUM.pl
####
####	From ND to SUM file
####	
#	From ND Fields:
#		F1	Collector	
#		F2	Node
#		F3	Next Node
#		F4	HOPS
#		F5	RX_RSSI
#		F6	TX_RSSI
#		F7	GATE_DOWNLOAD_Date
#		
#	To SUM Fields:
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
#		
	use List::MoreUtils qw(uniq);
	my $col= $ARGV[0];
	my $gdate = $ARGV[1];
	my $colsmp = $ARGV[2];
	my $DIRout="C:\\Scripts\\1-out\\";
	my $ndfile=$DIRout.$col.".nd";	
	my $sum=$DIRout.$col.".sum";
	my $gate,$dev,$nextdev,$hops,$rxrssi,$txrssi,$gd;
	my @z=qw();
	my %hy,%hh,%hr,%ht;
	open(SUM, ">>$sum");
	open(NEXTDEV, $ndfile);	
	while(<NEXTDEV>)
	{
		chomp;
		($gate,$dev,$nextdev,$hops,$rxrssi,$txrssi,$gd) = split /\t/, $_;	
		if ( $gdate=~ /$gd/ )
		{
			# create z array containing device names
			push @z, $dev;
			push @$nextdev, $dev;
			# create new arrays with nextdevice as array name
			push @{$hy{$dev}},$nextdev;
			push @{$hh{$dev}},$hops;
			push @{$hr{$dev}},$rxrssi;
			push @{$ht{$dev}},$txrssi;
		}
	}
	close NEXTDEV;
	my @y = uniq @z;
	my @yc = uniq @zc;
	my @yy=qw();
	# assigning hopcount to hash $hc
	my %hc;
	# going thru the device list, looping 16 iterations for each device against nextdevice array
	foreach $i (0 ..$#y)
	{
		if ( $colsmp =~ $y[$i] )
		{ 
			#print TREE  "[0] $y[$i]\n";
			$hc{$y[$i]}=0;
		}
		my @x1 = @{$y[$i]};
		push @{$yy[$i]}, @x1;
		foreach $i1 (0 .. $#x1)
		{
			if ( $colsmp =~ $y[$i] )
			{ 
				#print TREE  " [1] $x1[$i1]\n"; 
				$hc{$x1[$i1]}=1;
			}	
			my @x2 = @{$x1[$i1]};
			push @{$yy[$i]}, @x2;
			foreach $i2 (0 .. $#x2)
			{      
				if ( $colsmp =~ $y[$i] ) 
				{ 
					#print TREE  "  [2] $x2[$i2]\n";				
					$hc{$x2[$i2]}=2;
				}	
				my @x3 = @{$x2[$i2]};
				push @{$yy[$i]}, @x3;
				foreach $i3 (0 .. $#x3)
				{
					if ( $colsmp =~ $y[$i] ) 
					{ 
						#print TREE  "   [3] $x3[$i3]\n";
						$hc{$x3[$i3]}=3;
					}				
					my @x4 = @{$x3[$i3]};
					push @{$yy[$i]}, @x4;
					foreach $i4(0 .. $#x4)
					{
						if ( $colsmp =~ $y[$i] ) 
						{ 
							#print TREE  "    [4] $x4[$i4]\n"; 
							$hc{$x4[$i4]}=4;
						}						
						my @x5 = @{$x4[$i4]};
						push @{$yy[$i]}, @x5;
						foreach $i5(0 .. $#x5)
						{
							if ( $colsmp =~ $y[$i] ) 
							{ 
								#print TREE  "     [5] $x5[$i5]\n";
								$hc{$x5[$i5]}=5;
							}							
							my @x6 = @{$x5[$i5]};
							push @{$yy[$i]}, @x6;
							foreach $i6(0 .. $#x6)
							{
								if ( $colsmp =~ $y[$i] ) 
								{ 
									#print TREE  "      [6] $x6[$i6]\n"; 
									$hc{$x6[$i6]}=6;
								}								
								my @x7 = @{$x6[$i6]};
								push @{$yy[$i]}, @x7;
								foreach $i7(0 .. $#x7)
								{
									if ( $colsmp =~ $y[$i] )  
									{ 
										#print TREE  "       [7] $x7[$i7]\n"; 
										$hc{$x7[$i7]}=7;
									}								
									my @x8 = @{$x7[$i7]};
									push @{$yy[$i]}, @x8;
									foreach $i8(0 .. $#x8)
									{
										if ( $colsmp =~ $y[$i] )  
										{ 
											#print TREE  "        [8] $x8[$i8]\n";
											$hc{$x8[$i8]}=8;
										}										
										my @x9 = @{$x8[$i8]};
										push @{$yy[$i]}, @x9;
										foreach $i9(0 .. $#x9)
										{
											if ( $colsmp =~ $y[$i] )  
											{ 
												#print TREE  "         [9] $x9[$i9]\n";
												$hc{$x9[$i9]}=9;
											}												
											my @x10 = @{$x9[$i9]};
											push @{$yy[$i]}, @x10;
											foreach $i10(0 .. $#x10)
											{
												if ( $colsmp =~ $y[$i] )  
												{ 
													#print TREE  "          [10] $x10[$i10]\n";
													$hc{$x10[$i10]}=10;
												}		
												my @x11 = @{$x10[$i10]};	
												push @{$yy[$i]}, @x11;
												foreach $i11(0 .. $#x11)
												{
													if ( $colsmp =~ $y[$i] )  
													{ 
														#print TREE  "           [11] $x11[$i11]\n";
														$hc{$x11[$i11]}=11;
													}		
													my @x12 = @{$x11[$i11]};	
													push @{$yy[$i]}, @x12;
													foreach $i12(0 .. $#x12)
													{
														if ( $colsmp =~ $y[$i] )  
														{
															#print TREE  "            [12] $x12[$i12]\n";
															$hc{$x12[$i12]}=12;
														}	
														my @x13 = @{$x12[$i12]};	
														push @{$yy[$i]}, @x13;
														foreach $i13(0 .. $#x13)
														{
															if ( $colsmp =~ $y[$i] )  
															{ 
																#print TREE  "             [13] $x13[$i13]\n"; 
																$hc{$x13[$i13]}=13;
															}	
															my @x14 = @{$x13[$i13]};	
															push @{$yy[$i]}, @x14;
															foreach $i14(0 .. $#x14)
															{
																if ( $colsmp =~ $y[$i] )  
																{ 
																	#print TREE  "              [14] $x14[$i14]\n"; 
																	$hc{$x14[$i14]}=14;
																}	
																my @x15 = @{$x14[$i14]};	
																push @{$yy[$i]}, @x15;
																foreach $i15(0 .. $#x15)
																{
																	if ( $colsmp =~ $y[$i] )  
																	{ 
																		#print TREE  "               [15] $x15[$i15]\n"; 
																		$hc{$x15[$i15]}=15;
																	}	
																	my @x16 = @{$x15[$i15]};	
																	push @{$yy[$i]}, @x16;
																	foreach $i16(0 .. $#x16)
																	{
																		if ( $colsmp =~ $y[$i] )  
																		{ 
																			#print TREE  "                [16] $x16[$i16]\n"; 
																			$hc{$x16[$i16]}=16;
																		}	
																	}	
																}
															}
														}
													}
												}												
											}
										}
									}
								}
							}							
							
						}
					}
				}
			}
		}
	}
	my $count = 0;
	my $max=0;
	my $hop=0;
	foreach $i (0 .. $#yy)
	{
		@uyy = uniq @{$yy[$i]};
		$count = scalar @uyy;
		if ($count > $max){
			$max=$count;
		}
	}
	foreach $i (0 .. $#yy)
	{
		@uyy = uniq @{$yy[$i]};
		$count = scalar @uyy;
		$hop = 	$hc{$y[$i]}-1;
		$per=0;
		if ($count > 0){
			$per = $count*100/$max;
		}	
		$per=sprintf "%.1f", $per;
		$dev = $y[$i];
		($nextdev) = @{$hy{$dev}};
		($hops) = @{$hh{$dev}};
		($rxrssi) = @{$hr{$dev}};
		($txrssi) = @{$ht{$dev}};		
		print SUM "$gate,$dev,$nextdev,$hops,$hop,$count,$per,$rxrssi,$txrssi,$gdate\n";
	}
	#
	@yy=qw();
	@yyh=qw();
	close SUM;
	#close TREE;
	exit 0;	
#
#