define lightblue::yumrepos ( $repos=[] ) {
  $repo_names=split(inline_template("<%= repos.collect { |n| n['name'] } . join(',') %>"),',')
  arryumrepo{ $repo_names:
    all_repos => $repos
  }
}
