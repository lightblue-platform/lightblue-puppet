class lightblue::eap::module::cors::data (
    $directory,
    $config = undef,
)
{
    if $config != undef {
        lightblue::service::cors::configure { "${directory}/lightblue-crud-cors.json":
            url_patterns      => $config[url_patterns],
            allowed_origins   => $config[allowed_origins],
            allowed_methods   => $config[allowed_methods],
            allowed_headers   => $config[allowed_headers],
            exposed_headers   => $config[exposed_headers],
            allow_credentials => $config[allow_credentials],
            preflight_max_age => $config[preflight_max_age],
            enable_logging    => $config[enable_logging],
            notify            => Service['jbossas'],
            require           => File[$directory],
        }
    }
}
