
define servicegroup{
  file { "nagios_servicegroup_$title" :
    path                                                    => "/etc/nagios3/resources.d/servicegroup-$title.cfg",
    require                                         => File['nagios_resource_dir'],
    ensure                                  => present,
    owner                           => nagios,
    mode                    => 640,
    notify          => Service['nagios3'],
    content => "define servicegroup  { \n servicegroup_name  $title\n alias $title\n}\n",
  }
}

