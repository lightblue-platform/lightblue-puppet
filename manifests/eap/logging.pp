class lightblue::eap::logging {
    # setup eap6 logging
    $logging_format = hiera('lightblue::jboss::logging::format', '%d [%t] %-5p [%c] %m%n')
    $root_log_level = hiera('lightblue::jboss::logging::level::root', WARN)
    $com_redhat_log_level = hiera('lightblue::jboss::logging::level::lightblue', $root_log_level)

    lightblue::jcliffconfig { 'logging.conf':
        content => template('lightblue/logging.conf.erb'),
    }
}
