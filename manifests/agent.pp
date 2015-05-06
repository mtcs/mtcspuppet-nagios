class nagios::agent(
  $hname = $hostname, 
  $server_ip = '127.0.0.1',
  $mon_group, 
  $mon_profile = 'generic-host', 
  $parent = '',
  $icon,
){
  include nagios::agent_resources

  #$pkgs = [ 
  #'nagios-nrpe-server', 'nagios-plugins', 'nagios-plugins-standard', 
  #'nagios-plugins-basic', 'nagios-plugins-extra', 'bc'
  #]
  $pkgs = [ 
  'nagios-plugins', 'nagios-plugins-standard', 
  'nagios-plugins-basic', 'nagios-plugins-extra', 'bc'
  ]

  package { $pkgs : ensure => present }

  $custom_plugins = [ 
    'check_cpu.sh',  'check_gputemp.sh',  'check_hadoop',  'check_iftraffic3.pl',  
    'check_ifutil.pl',  'check_io',  'check_io_all',  'check_io_scratch',  'check_jps',  
    'check_memory',  'check_proc',  'check_restart', 'check_scratch',  
    'check_temp.pl',  'check_userprocs.pl', 
  ] 

  # Install new custom plugins
  #nagios::agent_resources::plugin { $custom_plugins : path =>  '/modules/nagios/plugins'}

  #file { 'nrpe.cfg':
  #  path    => '/etc/nagios/nrpe.cfg',
  #  ensure  => present,
  #  require => Package['nagios-nrpe-server'],
  #  content => template("nagios/nrpe.cfg.erb"),
  #}

  #file { '/etc/nagios/nrpe.d':
  #  ensure  => directory,
  #  require => Package['nagios-nrpe-server'],
  #  purge   => true,
  #  recurse => true,
  #}
  #file { 'band.cfg':
    #path    => '/etc/nagios/nrpe.d/band.cfg',
    #replace => no,
    #ensure  => present,
    #require => Package['nagios-nrpe-server'],
    #content => '
    #command[check_bandw_eth0]=/usr/lib/nagios/plugins/check_ifutil.pl -i eth0 -w 85 -c 95 -p -b 1000m
    #command[check_bandw_eth1]=/usr/lib/nagios/plugins/check_ifutil.pl -i eth1 -w 85 -c 95 -p -b 1000m '
    #}

    #service { 'nagios-nrpe-server':
    #name      => 'nagios-nrpe-server',
    #enable    => true,
    #ensure    => running,
    #subscribe => File [ [ 'nrpe.cfg' ] ],
    #}

  @@nagios::server_resources::host { $hname :
    name   => $fqdn,
    ipadd  => $ipaddress,
    use    => $mon_profile,
    groups => $mon_group,
    parent => $parent,
    os     => $operatingsystem,
    icon   => $icon,
  }
}


