define nagios::remote_service ($check, $use = 'generic-service', $members = 'all-servers,unmanaged-servers', $groups  ){
  if ( $members != 'all-servers,unmanaged-servers' ){
    nagios::hostgroup { "$members" : }
  }
  file { "nagios_rservice_$title" :
    path                                                    => "/etc/nagios3/resources.d/rservice-$title.cfg",
    require                                         => File['nagios_resource_dir'],
    ensure                                  => present,
    owner                           => nagios,
    mode                    => 640,
    notify          => Service['nagios3'],
    content => "define service {\n service_description $title\n use $use\n hostgroup_name $members \n check_command $check\n servicegroups $groups\n contact_groups admins\n}\n",
  }
}

