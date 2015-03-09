class nagios::agent(
  $hname = $hostname, 
  $mon_group, 
  $mon_profile = 'generic-host', 
  $parent = ''
){
  include fan_control
  include nagios

  $pkgs = [ 
  'nagios-nrpe-server', 'nagios-plugins', 'nagios-plugins-standard', 
  'nagios-plugins-basic', 'nagios-plugins-extra'
  ]

  package { $pkgs : ensure => present }

  file { 'nrpe.cfg':
    path               => '/etc/nagios/nrpe.cfg',
    ensure         => present,
    require    => Package['nagios-nrpe-server'],
    source => "puppet://nagios/files/nrpe.cfg"
  }

  #file { 'band.cfg':
    #path                    => '/etc/nagios/nrpe.d/band.cfg',
    #replace             => no,
    #ensure          => present,
    #require     => Package['nagios-nrpe-server'],
    #content => '
    #command[check_bandw_eth0]=/usr/lib/nagios/plugins/check_ifutil.pl -i eth0 -w 85 -c 95 -p -b 1000m
    #command[check_bandw_eth1]=/usr/lib/nagios/plugins/check_ifutil.pl -i eth1 -w 85 -c 95 -p -b 1000m '
    #}

  service { 'nagios-nrpe-server':
    name                  => 'nagios-nrpe-server',
    enable            => true,
    ensure        => running,
    subscribe =>  File [ [ 'nrpe.cfg' ] ], 
  }

  @@nagios::host { "$hname" :
    name   => "$fqdn",
    ipadd  => "$ipaddress",
    use    => "$mon_profile",
    groups => "$mon_group",
    parent => "$parent"
  }
}


