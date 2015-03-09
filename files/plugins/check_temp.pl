#!/usr/bin/perl
################################################################################
#                                                                              #
#  Copyright (C) 2011 Chad Columbus <ccolumbu@hotmail.com>                     #
#  Special thanks to Jack-Benny Persson <jake@cyberinfo.se>                    #
#                                                                              #
#   This program is free software; you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation; either version 2 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program; if not, write to the Free Software                #
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  #
#                                                                              #
################################################################################

###############################################################################
#                                                                             #
# Nagios plugin to monitor CPU and M/B temperature with sensors.              #
# Written in Perl (and uses Getopt::Std module).                              #
# Special thanks to Jack-Benny Persson as this whole program is based on his  #
# Bash version of this script.                                                #
#                                                                             #
###############################################################################

###############################################################################
# To get the Temps from each core one per line:
# Be sure to edit /etc/nagios/objects/commands.cfg and change notify-service-by-email to this:
# command_line    /usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$\n$LONGSERVICEOUTPUT$\n" | /bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$
# notice the addition of $LONGSERVICEOUTPUT$\n to the end of the message.
###############################################################################

use strict;
use Getopt::Std;

my $VERSION = "Version 1.1";
my $AUTHOR = '(c) 2011 Chad Columbus <ccolumbu@hotmail.com>';
my %opts;
getopts('hw:c:s:t:', \%opts);

# Sensor program
my $SENSORPROG = "/usr/bin/sensors";

# Exit codes
my $STATE_OK = 0;
my $STATE_WARNING = 1;
my $STATE_CRITICAL = 2;
my $STATE_UNKNOWN = 3;

# Default values:
my $sensor_regex = 'Core .';
my $sensor_regex2 = 'temp1';
my $error = 0;
my $default_thresh_warn = 80;
my $default_thresh_crit = 100;
my $thresh_warn = '';
my $thresh_crit = '';
my $matched_pattern = '';
my $message = '';
my %temp_hash;
my %sensor_hash;
my $temp_list = '';
my $temp_perflist = '';
my $mean_temp = '';
my $i = '';

# See if we have sensors program installed and can execute it
if (! -x "$SENSORPROG") {
        print "\nIt appears you don't have sensors installed in $SENSORPROG\n";
        exit($STATE_UNKNOWN);
}

# Parse command line options
if ($opts{'h'}) {
	&print_help();
	exit($STATE_OK);
}

if (! defined $opts{'w'}) {
	# Warning not provided
	$thresh_warn = $default_thresh_warn;
} elsif ($opts{'w'} =~ /^\d+$/) {
	# Warning is an integer
	$thresh_warn = $opts{'w'};
} else {
	# Warning is not an integer
	print "Warning must be an integer\n";
}

if (! defined $opts{'c'}) {
	# Critical not provided
	$thresh_crit = $default_thresh_crit;
} elsif ($opts{'c'} =~ /^\d+$/) {
	# Critical is an integer
	if ($opts{'c'} <= $opts{'w'}) {
		print "Critical -c must be greater than Warning -w\n";
		exit($STATE_UNKNOWN);
	} else {
		$thresh_crit = $opts{'c'};
	}
} else {
	# Critical is not an integer
	print "Critical must be an integer\n";
}

if (defined $opts{'s'}) {
	if ($opts{'s'} ne '') {
		# Sensor argument provided:
		$sensor_regex = $opts{'s'};
	}
}

if (defined $opts{'t'}) {
	if ($opts{'t'} ne '') {
		# Sensor argument provided:
		$sensor_regex2 = $opts{'t'};
	}
}

my $sensors_output = `export LANG=C;$SENSORPROG`;
my $pattern = "($sensor_regex)" . '\:[\s\n\r]{1,}[\+\-]{0,1}(\d{1,3}(?:\.\d{1,2}){0,1}).[CF]';
if ($sensors_output !~ m/$pattern/imsg){
	$pattern = "($sensor_regex2)" . '\:[\s\n\r]{1,}[\+\-]{0,1}(\d{1,3}(?:\.\d{1,2}){0,1}).[CF]';
}

my $matched_sensor;
my $hold_temp;
my $loop = 0;
foreach $matched_pattern ($sensors_output =~ m/$pattern/imsg) {
	if ($matched_pattern =~ m/$sensor_regex/) {
		$matched_sensor = $matched_pattern;
	} else {
		$hold_temp = $matched_pattern;

		# Check that the regex returned a number:
		if ($hold_temp =~ /^\d{1,3}(?:\.\d{1,2}){0,1}$/) {
			# Sucess, we got what looks like a temp!
			if ($hold_temp > 0){
			$temp_hash{$loop} = $hold_temp;
			$sensor_hash{$loop} = $matched_sensor;
			$sensor_hash{$loop} =~ s/ //;
			if ($hold_temp > $thresh_crit) {
				$message .= "CRITICAL - $matched_sensor Temperature is $hold_temp ### \n";
				$error = $STATE_CRITICAL;
			} elsif ($hold_temp > $thresh_warn) {
				$message .= "WARNING - $matched_sensor Temperature is $hold_temp ### \n";
				if ($error == 0 || $error == 3) {
					$error = $STATE_WARNING;
				}
			} else {
				$message .= "$matched_sensor Temperature OK $hold_temp ### \n";
			}
			}
		}
		$matched_sensor = '';
		$hold_temp = '';
	}
	$loop++;
}

if ($message eq '') {
	print "Error: I did not get a temp from the sensor data matching REGEX = \/$pattern\:\/\n";
	exit($STATE_UNKNOWN);
}

$mean_temp=0;
foreach my $key (sort keys %temp_hash) {
	$temp_list .= "$sensor_hash{$key}: $temp_hash{$key} ";
	$temp_perflist .= "Core$key=$temp_hash{$key};$thresh_warn;$thresh_crit;0;90 ";
	$mean_temp+=$temp_hash{$key};
	$i++;
}
$mean_temp/=$i;
$temp_list =~ s/, $//;
if ($error>0) {
	if ($error == $STATE_CRITICAL) {
		$message = "CRITICAL - TEMP: $mean_temp $temp_list | TEMP=$mean_temp;$temp_perflist\n$message";
	} elsif ($error == $STATE_WARNING) {
		$message = "WARNING -  TEMP: $mean_temp $temp_list | TEMP=$mean_temp;$temp_perflist\n$message";
	}
	print "$message\n";
	exit($error);
}

# If we get here the temperature is ok
#print "Temperature OK - $temp_list\n$message\n";
print "Temperature OK -  TEMP: $mean_temp $temp_list | TEMP=$mean_temp;$temp_perflist\n$message\n";
#print "$temp_list\n";
exit($STATE_OK);

####################################
# Start Subs:
####################################
sub print_help() {
        print << "EOF";
Monitor temperature with the use of $SENSORPROG
$VERSION
$AUTHOR

Options:
-h
   Print detailed help screen
-s 'REGEX'
   Set what to monitor. This looks for REGEX followed by a ':' for example CPU would look for 'CPU:'. Default is CPU.
-w INTEGER
   If not set default is $default_thresh_warn
-c INTEGER
   if not set default is $default_thresh_crit

EOF
}

