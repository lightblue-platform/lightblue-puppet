class lightblue::yumrepo::lightblue (
    $descr='lightblue repo',
    $enabled=1,
    $gpgcheck=0,
    $gpgkey=absent,
    $metadata_expire=absent,
) {

  $baseurl = hiera('lightblue::yumrepo::lightblue::baseurl', 'http://pulp-gca03.util.phx1.redhat.com/pulp/repos/re/cos-lightblue-snapshot')

  yumrepo { 'lightblue':
    baseurl         => $baseurl,
    descr           => $descr,
    enabled         => $enabled,
    gpgcheck        => $gpgcheck,
    gpgkey          => $gpgkey,
    metadata_expire => $metadata_expire,
  }
}
