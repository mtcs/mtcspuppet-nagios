define nagios::host ($ipadd, $use = 'generic-host', $groups = 'all-servers', $parent = 'switch_0', $icon = 'ubuntu' ){
  file { "nagios_host_$title" :
    path                                        => "/etc/nagios3/resources.d/host_$title.cfg",
    require                               => File['nagios_resource_dir'],
    ensure                          => present,
    owner                     => nagios,
    mode                => 640,
    notify        => Service['nagios3'],
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

