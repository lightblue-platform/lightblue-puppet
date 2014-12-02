class lightblue::eap::mongossl (
    $certificate_file,
    $java_ks_password,
    $certificate_content='',
    $certificate_source='',
) {

    if ($certificate_source == '') {
        # no source is set, assume content is set
        file { $certificate_file:
            ensure      => file,
            owner       => 'jboss',
            group       => 'jboss',
            mode        => '0600',
            require     => Package[$lightblue::eap::package_name],
            content     => $certificate_content,
        }
    } else {
        file { $certificate_file:
            ensure      => file,
            owner       => 'jboss',
            group       => 'jboss',
            mode        => '0600',
            require     => Package[$lightblue::eap::package_name],
            source      => $certificate_source,
        }
    }

    java_ks { "mongossl:${lightblue::java::java_home}/jre/lib/security/cacerts":
        ensure       => latest,
        certificate  => $certificate_file,
        password     => $java_ks_password,
        target       => "${lightblue::java::java_home}/jre/lib/security/cacerts",
        trustcacerts => true,
        require      => File[$certificate_file],
    }
}
