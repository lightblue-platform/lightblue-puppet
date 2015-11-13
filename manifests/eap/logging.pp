class lightblue::eap::logging (
    $logging_format = '%d [%t] %-5p [%c] %m%n',
    $access_logging_format = '%d [%t] %-5p [%c] %m%n',
    $root_log_level = WARN,
    $lightblue_log_level = WARN,
)
{
    # setup eap6 logging
    lightblue::jcliff::config { 'logging.conf':
        content => template('lightblue/logging.conf.erb'),
    }

    # setup access logging
    include lightblue::eap::access_log
}
