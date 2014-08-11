class lightblue::eap::mongossl (
    $certificate_content,
    $certificate_file,
    $java_ks_password,
) {
    file { $certificate_file:
        ensure      => file,
        content     => $certificate_content,
        owner       => 'jboss',
        group       => 'jboss',
        mode        => '0600',
        require     => Package[$lightblue::eap::package_name],
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
