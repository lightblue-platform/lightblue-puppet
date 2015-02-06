# == Class: lightblue::service::cors::configure
#
# Lays down a templated property file at $title which can be read as a
# CorsConfiguration in lightblue-rest.
#
# === Parameters
#
# [*url_patterns*]
#
# Array of URL patterns within the service which are opened up to CORS requests.
#
# [*allowed_origins*]
#
# Array of hosts which are allowed to make cross origin requests. Client browsers
# making cross-origin requests pass their current URL's host as an Origin header.
#
# [*allowed_methods*]
#
# Array of HTTP methods which are allowed to make cross origin requests.
#
# [*allowed_headers*]
#
# Array of allowed headers. Allowed headers are sent with preflight response to
# indicate what headers a browser can use to make the actual request.
#
# [*exposed_headers*]
#
# Array of exposed headers which the browser can read in the cross-origin response.
#
# [*allow_credentials*]
#
# True or false to enable processing credentials sent cross-origin.
#
# [*preflight_max_age*]
#
# The amount of time in seconds a preflight response may be cached in the browser.
#
# [*enable_logging*]
#
# True or false to enable implementation specific logging inside the CORS filter
# if supported.
#
# [*owner*]
#
# User to own the configuration file.
#
# [*group*]
#
# Group to own the configuration file.
#
# [*before*]
#
# [*notify*]
#
# [*require*]
#
# === Variables
#
# None
#
# === Examples
#
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
) {
    file { $title:
        ensure  => 'file',
        mode    => '0644',
        owner   => $owner,
        group   => $group,
        content => template('lightblue/properties/lightblue-cors.json.erb'),
    }

}
