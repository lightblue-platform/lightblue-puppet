class lightblue::yumrepo::lightblue (
    $baseurl,
    $descr='lightblue repo',
    $enabled=1,
    $gpgcheck=0,
    $gpgkey=absent,
    $metadata_expire=absent,
) {
  yumrepo { 'lightblue':
    baseurl         => $baseurl,
    descr           => $descr,
    enabled         => $enabled,
    gpgcheck        => $gpgcheck,
    gpgkey          => $gpgkey,
    metadata_expire => $metadata_expire,
  }
}
