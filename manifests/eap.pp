# Installs EAP6 
class lightblue::eap ($eap_version = '1.6.0') {

  include lightblue::initrepos

  package { 'jbossas-ha' :
    require => [ Class['lightblue::openjdk'], User['jboss'] ],
  }
}
