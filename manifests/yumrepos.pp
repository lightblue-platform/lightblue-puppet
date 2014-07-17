# Initializes additional repositories using hiera array lightblue::yum_repos
# lightblue::yum_repos is expected to be a yaml array, containing at least a name,
# description, baseurl for each repo that needs to be installed on the host
class lightblue::yumrepos {
  yumrepo { 'JBEAP':
    baseurl         => hiera('lightblue::yumrepo::jbeap::baseurl'),
    descr           => 'JBEAP repo',
    enabled         => hiera('lightblue::yumrepo::jbeap::enabled', 1),
    gpgcheck        => hiera('lightblue::yumrepo::jbeap::gpgcheck', 0),
    gpgkey          => hiera('lightblue::yumrepo::jbeap::gpgkey', absent),
    metadata_expire => hiera('lightblue::yumrepo::jbeap::metadata_expire', absent),
  }

  yumrepo { 'JBEAP-TOOLS':
    baseurl         => hiera('lightblue::yumrepo::jbeaptools::baseurl'),
    descr           => 'JBEAP-TOOLS repo',
    enabled         => hiera('lightblue::yumrepo::jbeaptools::enabled', 1),
    gpgcheck        => hiera('lightblue::yumrepo::jbeaptools::gpgcheck', 0),
    gpgkey          => hiera('lightblue::yumrepo::jbeaptools::gpgkey', absent),
    metadata_expire => hiera('lightblue::yumrepo::jbeaptools::metadata_expire', absent),
  }

  yumrepo { 'lightblue':
    baseurl         => hiera('lightblue::yumrepo::lightblue::baseurl'),
    descr           => 'lightblue repo',
    enabled         => hiera('lightblue::yumrepo::lightblue::enabled', 1),
    gpgcheck        => hiera('lightblue::yumrepo::lightblue::gpgcheck', 0),
    gpgkey          => hiera('lightblue::yumrepo::lightblue::gpgkey', absent),
    metadata_expire => hiera('lightblue::yumrepo::lightblue::metadata_expire', absent),
  }
}
