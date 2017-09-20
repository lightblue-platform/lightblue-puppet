class lightblue::eap::mongossl (
    $java_ks_password,
    $certificates,
    $cacerts_path = "${lightblue::java::java_home}/jre/lib/security/cacerts",
) {
    create_resources(lightblue::eap::mongo_keystore_file, $certificates)
}
