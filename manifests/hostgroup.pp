define nagios::hostgroup ($parentgroup = ''){
  if ($parent == ''){
    file { "nagios_hostgroup_$title" :
      path                                                    => "/etc/nagios3/resources.d/hostgroup-$title.cfg",
      require                                         => File['nagios_resource_dir'],
      ensure                                  => present,
      owner                           => nagios,
      mode                    => 640,
      notify          => Service['nagios3'],
      content => "define hostgroup  { \n hostgroup_name  $title\n alias $title \n}\n",
    }
    }else{
      file { "nagios_hostgroup_$title" :
        path                                                    => "/etc/nagios3/resources.d/hostgroup-$title.cfg",
        require                                         => File['nagios_resource_dir'],
        ensure                                  => present,
        owner                           => nagios,
        mode                    => 640,
        notify          => Service['nagios3'],
        content => "define hostgroup  { \n hostgroup_name  $title\n alias $title \n}\n",
      }
    }
}

