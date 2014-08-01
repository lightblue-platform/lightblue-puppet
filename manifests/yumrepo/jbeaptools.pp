class lightblue::yumrepo::jbeaptools (
    $descr='JBEAP-TOOLS repo',
    $enabled=1,
    $gpgcheck=0,
    $gpgkey=absent,
    $metadata_expire=absent,
) {

  $baseurl = hiera('lightblue::yumrepo::jbeaptools::baseurl', 'http://pulp-gca03.util.phx1.redhat.com/pulp/repos/re/JBEAP6-TOOLS')

  yumrepo { 'JBEAP-TOOLS':
    baseurl         => $baseurl,
    descr           => $descr,
    enabled         => $enabled,
    gpgcheck        => $gpgcheck,
    gpgkey          => $gpgkey,
    metadata_expire => $metadata_expire,
  }
}
