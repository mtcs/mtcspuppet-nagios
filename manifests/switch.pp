define nagios::switch($parent = '', $ipadd, $use = 'generic-switch', $icon = 'base/switch40'){
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

