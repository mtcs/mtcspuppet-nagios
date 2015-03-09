class nagios::nagiosgrapher{
  $nagiosgr_server_pkgs = [ 'nagiosgrapher' ]
  package { $nagiosgr_server_pkgs : ensure => present }

  file {'ngraph.ncfg':
    path               => '/etc/nagiosgrapher/ngraph.ncfg',
    require        => Package['nagiosgrapher'],
    ensure     => present,
    source => "puppet:///files/nagios/ngraph.ncfg",
  }
  file {'ngraph.d':
    path                    => '/etc/nagiosgrapher/ngraph.d',
    require             => Package['nagiosgrapher'],
    ensure          => present,
    source      => "puppet:///files/nagios/ngraph.d",
    recurse => true
  }
  service { 'nagiosgrapher':
    enable => true,
  }
}


