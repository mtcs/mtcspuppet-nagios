class nagios::agent_resources(){
  define plugin($path){
    file{ "/usr/lib/nagios/plugins/$title" :
      ensure  => present,
      require => Package[ 'nagios-plugins' ],
      source  => "puppet://$path/$title",
    }
  }
  define nrpe_command($command){
    file{ "/usr/lib/nagios/plugins/$title" :
      ensure  => present,
      require => Package[ 'nagios-nrpe-server' ],
      content => "command[$title]=/usr/lib/nagios/plugins/$command",
    }
  }
}

