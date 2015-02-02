define lightblue::service::cors::configure (
    $url_patterns = undef,
    $allowed_origins = undef,
    $allowed_methods = undef,
    $allowed_headers = undef,
    $exposed_headers = undef,
    $allow_credentials = undef,
    $preflight_max_age = undef,
    $enable_logging = undef,
    $owner = 'root',
    $group = 'root',
    $before = [],
    $notify = [],
    $require = [],
) {
    file { $title:
        ensure  => 'file',
        mode    => '0644',
        owner   => $owner,
        group   => $group,
        content => template('lightblue/properties/lightblue-cors.json.erb'),
        before  => $before,
        notify  => $notify,
        require => $require,
    }

}
