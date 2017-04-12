# Defines access log pattern for 'default-host' virtual-server
class lightblue::eap::access_log (
    $pattern = '\%h \%l \%u \%t \\\u0034\%r\\\u0034 \%s \%b \\\u0034\%{Referer}i\\\u0034 \\\u0034\%{User-Agent}i\\\u0034 \%D \%S',
    $rotate  = true,
    $prefix  = 'access_log',
    $resolve_hosts = false
) {
    lightblue::jcliff::config { 'web-access-log.conf':
        content => template('lightblue/web-access-log.conf.erb'),
    }
    logrotate::file { 'jboss-access-logs':
        ensure => absent,
    }

    file { '/etc/logrotate.d/jboss-access-logs':
        ensure => absent,
    }

    # The next is just to flush out old logs prior to changing over to
    # log rotate can't use logrotate::tmpwatch because it checks atime
    # which gets reset on updatedb
    cron { 'tmpwatch-jboss-access-logs':
        command => '/usr/sbin/tmpwatch -m 3d /var/log/jbossas/standalone/default-host',
        hour    => '4',
        minute  => '0',
    }
}
