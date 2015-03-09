define nagios::unmanaged_host ($ipadd, $use = 'generic-host', $parent = '', $icon = 'base/linux40'){
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

