class nagios::server(
  $omit_default_servicegroup = false,
  $default_service_members = 'Default',
){
  class {'nagios::server_resources': 
    omit_default_servicegroup => $omit_default_servicegroup,
    default_service_members   => $default_service_members,
  }
  include nagios::nagiosgrapher

  $nagios_server_pkgs = [ 'nagios3', 'nagios-nrpe-plugin' ]
  package { $nagios_server_pkgs : ensure => present }

  $nagios_server_resource_configfiles = [ 'generic-host_nagios2.cfg', 'generic-switch_nagios2.cfg', 'generic-service_nagios2.cfg', 'custom_cmds.cfg' ]
  $nagios_server_configfiles = [ 'nagios.cfg', 'apache2.conf', 'cgi.cfg' ]
  $nagios_server_configfiles_purge = ['hostgroups_nagios2.cfg', 'localhost_nagios2.cfg', 'services_nagios2.cfg', 'extinfo_nagios2.cfg' ]

  file { 'nagios_resource_dir':
    path     => '/etc/nagios3/resources.d',
    ensure   => 'directory',
    owner    => 'nagios',
    purge   => true,
    #recurse => true,
    mode     => 750,
  }

  define nagios_configfile($path = '/etc/nagios3'){
    file{"nagios_config_$title":
      path                           => "$path/$title",
      require                  => Package['nagios3'],
      ensure             => present,
      source       => "puppet://nagios/files/conf/$title",
      notify => Service['nagios3'],
    }
  }
  define nagios_configfile_purge{
    file {"nagios_config_$title":
      path   => "/etc/nagios3/conf.d/$title",
      ensure => absent,
      notify => Service['nagios3'],
    }
  }

  nagios_configfile{ $nagios_server_configfiles :}
  nagios_configfile{ $nagios_server_resource_configfiles : path => '/etc/nagios3/conf.d'}
  nagios_configfile_purge{ $nagios_server_configfiles_purge :}

  # The default hostgroup
  if ( $omit_default_servicegroup ){
    nagios::servicegroup { 'Default' : }
  }

  Nagios::Host <<| |>>

  service { 'nagios3':
    enable          => true,
    ensure      => running,
    #notify =>  Service['nagiosgrapher'],
    }

}
                                                                                                                                                                                  
