# Lay down a jcliff config file, and schedule execution of config update
# name gives the name of the file, without directory
define lightblue::jcliff::config (
    $content
) {
  include lightblue::jcliff

  file{ "${lightblue::jcliff::jcliff_config_dir}/${name}":
    mode    => '0644',
    owner   => 'jboss',
    group   => 'jboss',
    content => $content,
    notify  => Exec['configure-eap6'],
    require => [ Package['jcliff'], Exec['clean-eap6-configs'] ],
  }
}
