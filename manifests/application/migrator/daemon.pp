# == Class: lightblue::application::migrator::daemon
#
# Installs the lightblue migrator as a Service.
#
# === Parameters
#
# $jsvc_version            - Version of apache-commons-daemon-jsvc to ensure is installed. Defaults to 'latest'.
# $owner                   - The user to whom the file should belong. Defaults to 'root'.
# $group                   - The group to whom the file should belong. Defaults to 'root'.
# $service_name            - Name of the service
# $jsvc_exec               - Absolute path to jsvc executable. Default to '$(which jsvc)'.
# $java_home               - Path to java physical home directory. Defaults to JAVA_HOME (represented by undef).
# $service_out_logfile     - File path for standard out logging.
# $service_err_logfile     - File path for standard err logging. Hint: can be the same as $service_out_logfile.
# $lib_dir                 - (optional) Jar lib directory if one exists.
# $jar_path                - Path to jar file to be executed.
# $mainClass               - Java classpath to Main method to be executed upon startup.
#                            Defaults to com.redhat.lightblue.migrator.consistency.CompareLightblueToLegacyCLI
# $arguments               - Additional CLI arguments to pass into the application. Defaults to {}.
# $jvmOptions              - Options to pass to the JVM (No need to include leading X). Defaults to {}.
#
# === Variables
#
# Module requires no global variables.
#
# === Example
#
# class { 'lightblue::application::migrator::daemon':
#   #parameters
# }
#
# Example Jar execution from CLI:
# java -jar consistency-checker-1.0.0-alldeps.jar
#  --name checker_0
#  --host lightblue.io
#  --ip 127.0.0.1
#  --config=lightblue-client.properties
#  --configversion=1.0.0
#  --jobversion=1.0.0
#
class lightblue::application::migrator::daemon (
    $jsvc_version = 'latest',
    $owner = 'root',
    $group = 'root',
    $jsvc_exec = '$(which jsvc)',
    $java_home = undef,
    $lib_dir = undef,
    $arguments = {},
    $jvmOptions = {},
    $service_name,
    $service_out_logfile,
    $service_err_logfile,
    $jar_path,
    $mainClass,
) {
    case $::osfamily {
        'RedHat', 'Linux': {
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                $jsvc_package_name = 'jakarta-commons-daemon-jsvc'
            }
            else{
                $jsvc_package_name = 'apache-commons-daemon-jsvc'
            }
        }
        default: {
            fail( "Unsupported OS family: ${::osfamily}" )
        }
    }

    package { $jsvc_package_name:
        ensure  => $jsvc_version,
        notify  => [Service[$service_name]],
    } ->
    file { "/etc/init.d/${service_name}":
        ensure  => 'file',
        content => template('lightblue/application/migrator/lightblue-migrator-daemon.sh.erb'),
        mode    => '0744',
        owner   => $owner,
        group   => $group,
        notify  => [Service[$service_name]],
    }
}
