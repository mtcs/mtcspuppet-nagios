#!/usr/bin/perl -W

use strict ;

open  (FILE, "/etc/ssh/sshd_config")  or die "ERROR: Could not open SSh config file\n";

my @UserList=();
my $bla=0;

while (<FILE>){
	if(/AllowUsers/){
		($bla,@UserList)=split(/\s+/, $_);
	}
}

open (PSOUT, "ps -o pid,pcpu,pmem,suser --sort -pcpu -N -U root|");

my $user;
my %UserCpu;
my %UserMem;
my %UserMaxCpu;
#my %UserCommand;
my $PSDATA="";
my $line;

foreach $user (@UserList){ 
	$UserMaxCpu{"$user"}=-1;
}


while(<PSOUT>){
	$line=$_;
	$PSDATA.=$line;
	foreach $user (@UserList){ 
		if(/$user$/){
			$line=~s/^\s+//;
			my($pid,$cpu,$mem,$command,$id)=split(/\s+/, $line); 
			$UserCpu{"$user"}+=$cpu;
			$UserMem{"$user"}+=$mem;
			if($UserMaxCpu{"$user"}<$cpu){
				$UserMaxCpu{"$user"}=$cpu;
				#$UserCommand{"$user"}=$command;
			}
		}
	}
}
print ("Processes OK - |");
foreach $user (@UserList){ 
	#if(defined $UserCpu{"$user"}){
		if ((defined $UserCpu{"$user"})&&($UserCpu{"$user"}!=0)){
			print("$user-CPU=".$UserCpu{"$user"}."% ");
		}else{
			print("$user-CPU=0.0% ");
		}
		if ((defined $UserMem{"$user"}) && ($UserMem{"$user"}!=0)){
			print("$user-MEM=".$UserMem{"$user"}."% ");
		}else{
			print("$user-MEM=0.0% ");
		}
		#if (defined $UserCommand{"$user"}){
			#print("$user-CMD=\"".$UserCommand{"$user"}."\" ");
		#}else{
			#print("$user-CMD=\"\" ");
		#}
	#}
}
print ("\n");
print ($PSDATA);
exit(0);
