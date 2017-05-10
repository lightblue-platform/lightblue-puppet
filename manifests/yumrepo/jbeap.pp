#class for defining jboss eap yum repo
class lightblue::yumrepo::jbeap (
    $baseurl,
    $descr='JBEAP repo',
    $enabled=1,
    $gpgcheck=0,
    $gpgkey=absent,
    $metadata_expire=absent,
) {
  yumrepo { 'JBEAP':
    baseurl         => $baseurl,
    descr           => $descr,
    enabled         => $enabled,
    gpgcheck        => $gpgcheck,
    gpgkey          => $gpgkey,
    metadata_expire => $metadata_expire,
  }
}
