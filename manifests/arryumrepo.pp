define lightblue::arryumrepo( $all_repos=[] ) {
  $repo_data = $all_repos[inline_template("<%=all_repos.index { |x| x['name']==name }%>")]
  yumrepo{ $name:
    baseurl  => $repo_data[baseurl],
    descr    => $repo_data[description],
    enabled  => $repo_data[enabled],
    gpgcheck => $repo_data[gpgcheck],
    gpgkey   => $repo_data[gpgkey],
  }
}