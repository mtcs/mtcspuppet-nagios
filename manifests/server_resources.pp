class nagios::server_resources(
  $omit_default_servicegroup = $nagios::server::omit_default_servicegroup,
  $default_service_members = $nagios::server::default_smembers,
){
  define host ($ipadd, $use = 'generic-host', $groups = 'all-servers', $parent = 'switch_0', $icon = 'ubuntu' ){
    file { "nagios_host_$title" :
      path                            => "/etc/nagios3/resources.d/host_$title.cfg",
      require                     => File['nagios_resource_dir'],
      ensure                  => present,
      owner               => nagios,
      mode            => 640,
      notify      => Service['nagios3'],
      content => "define host {
        use $use
        host_name $title
        alias $name
        address $ipadd
        hostgroups all-servers,$groups
        parents $parent 
        icon_image $icon.png
        icon_image_alt  $title
        statusmap_image  $icon.gd2
        }\n",
    }
  }

  define hostgroup ($parentgroup = ''){
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

  define remote_service (
    $check, $use = 'generic-service', 
  ){
    if ( $members != 'all-servers,unmanaged-servers' ){
      nagios::hostgroup { "$members" : }
    }
    file { "nagios_rservice_$title" :
      path    => "/etc/nagios3/resources.d/rservice-$title.cfg",
      require => File['nagios_resource_dir'],
      ensure  => present,
      owner   => nagios,
      mode    => 640,
      notify  => Service['nagios3'],
      content => "define service {\n service_description $title\n use $use\n hostgroup_name $members \n check_command $check\n servicegroups $groups\n contact_groups admins\n}\n",
    }

    define service (
      $check, $use = 'generic-service', 
    ){
      file { "nagios_service_$title" :
        path    => "/etc/nagios3/resources.d/service-$title.cfg",
        require => File['nagios_resource_dir'],
        ensure  => present,
        owner   => nagios,
        mode    => 640,
        notify  => Service['nagios3'],
        content => "define service {\n service_description $title\n use $use\n hostgroup_name $members \n check_command check_nrpe_1arg!$check\n servicegroups $groups\n contact_groups admins\n}\n",
      }
    }

    define servicegroup{
      file { "nagios_servicegroup_$title" :
        path    => "/etc/nagios3/resources.d/servicegroup-$title.cfg",
        require => File['nagios_resource_dir'],
        ensure  => present,
        owner   => nagios,
        mode    => 640,
        notify  => Service['nagios3'],
        content => "define servicegroup  { \n servicegroup_name  $title\n alias $title\n}\n",
      }

      define switch(
        $parent = '', $ipadd, 
        $use = 'generic-switch', 
        $icon = 'base/switch40'
      ){
        if ($parent == ''){
          file { "nagios_switch_$title" :
            path                                                    => "/etc/nagios3/resources.d/switch_$title.cfg",
            require                                         => File['nagios_resource_dir'],
            ensure                                  => present,
            owner                           => nagios,
            mode                    => 640,
            notify          => Service['nagios3'],
            content => "define host {\n use $use\n host_name switch_$title\n alias Switch $name\n address $ipadd\n hostgroups switches\n   icon_image $icon.png\n icon_image_alt  $name \n statusmap_image  $icon.gd2\n }\n",
          }
          }else{
            file { "nagios_switch_$title" :
              path                                                    => "/etc/nagios3/resources.d/switch_$title.cfg",
              require                                         => File['nagios_resource_dir'],
              ensure                                  => present,
              owner                           => nagios,
              mode                    => 640,
              notify          => Service['nagios3'],
              content => "define host {\n use $use\n host_name switch_$title\n alias Switch $name\n address $ipadd\n hostgroups switches\n parents $parent\n   icon_image $icon.png\n icon_image_alt  $name \n statusmap_image  $icon.gd2\n }\n",
            }
          }
      }

    }

    define unmanaged_host (
      $ipadd, 
      $use = 'generic-host', 
      $parent = '', $
      icon = 'base/linux40'
    ){
      if ($parent == ''){
        file { "nagios_host_$title" :
          path                                                    => "/etc/nagios3/resources.d/uhost_$title.cfg",
          require                                         => File['nagios_resource_dir'],
          ensure                                  => present,
          owner                           => nagios,
          mode                    => 640,
          notify          => Service['nagios3'],
          content => "define host {\n use $use\n host_name $title\n alias $name\n address $ipadd\n hostgroups unmanaged-servers\n  icon_image $icon.png\n icon_image_alt  $name \n statusmap_image  $icon.gd2\n }\n",
        }
        }else{
          file { "nagios_host_$title" :
            path                                                    => "/etc/nagios3/resources.d/uhost_$title.cfg",
            require                                         => File['nagios_resource_dir'],
            ensure                                  => present,
            owner                           => nagios,
            mode                    => 640,
            notify          => Service['nagios3'],
            content => "define host {\n use $use\n host_name $title\n alias $name\n address $ipadd\n hostgroups unmanaged-servers\n parents $parent\n  icon_image $icon.png\n icon_image_alt  $name \n statusmap_image  $icon.gd2\n }\n",
          }
        }
    }

  }
