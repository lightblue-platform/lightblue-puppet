# Setting up common module path for lightblue::eap::client resource
class lightblue::eap::client::modulepath {

    # Pretty sure many of those paths will conflicts with something else...
    # Perhaps better use mkdir -p ?
    $module_base = [ '/usr/share/jbossas/modules/com',
        '/usr/share/jbossas/modules/com/redhat',
        '/usr/share/jbossas/modules/com/redhat/lightblue',
        '/usr/share/jbossas/modules/com/redhat/lightblue/client']

    file { $module_base :
        ensure   => 'directory',
        owner    => 'jboss',
        group    => 'jboss',
        mode     => '0755',
    }

}
