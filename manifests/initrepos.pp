# Initializes additional repositories using the global variable yum_repos
# yum_repos is expected to be a yaml array, containing at least a name, 
# description, baseurl for each repo that needs to be installed on the host
class lightblue::initrepos {
  if $::yum_repos {
    yumrepos { 'yumrepos' :
      repos => $::yum_repos
    }
  }
}
