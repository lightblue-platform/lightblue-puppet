#class for defining jboss eap tools yum repo
class lightblue::yumrepo::jbeaptools (
    $baseurl,
    $descr='JBEAP-TOOLS repo',
    $enabled=1,
    $gpgcheck=0,
    $gpgkey=absent,
    $metadata_expire=absent,
) {

  yumrepo { 'JBEAP-TOOLS':
    baseurl         => $baseurl,
    descr           => $descr,
    enabled         => $enabled,
    gpgcheck        => $gpgcheck,
    gpgkey          => $gpgkey,
    metadata_expire => $metadata_expire,
  }
}
