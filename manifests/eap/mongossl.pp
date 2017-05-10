#creates mongoSSL keystore file with certificates passed as a parameter
class lightblue::eap::mongossl (
    $java_ks_password,
    $certificates = undef,
) {
    create_resources(lightblue::eap::mongo_keystore_file, $certificates)
}
