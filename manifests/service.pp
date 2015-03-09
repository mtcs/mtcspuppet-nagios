define nagios::service ($check, $use = 'generic-service', $members = 'all-servers', $groups ){
  file { "nagios_service_$title" :
    path                                                    => "/etc/nagios3/resources.d/service-$title.cfg",
    require                                         => File['nagios_resource_dir'],
    ensure                                  => present,
    owner                           => nagios,
    mode                    => 640,
    notify          => Service['nagios3'],
    content => "define service {\n service_description $title\n use $use\n hostgroup_name $members \n check_command check_nrpe_1arg!$check\n servicegroups $groups\n contact_groups admins\n}\n",
  }
}

