class nagios::agent_resources(){
  define plugins {
    file{ "$title" :
      path    => "/usr/lib/nagios/plugins/$title",
      ensure  => present,
      require => Package[ 'nagios-plugins' ],
      source  => "puppet://$path/$title"
    }
  }
}

