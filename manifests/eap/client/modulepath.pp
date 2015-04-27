# Setting up common module path for lightblue::eap::client resource
class lightblue::eap::client::modulepath {

    $module_path = '/usr/share/jbossas/modules/com/redhat/lightblue/client'

    exec { $module_path:
        command => "mkdir -p $module_path",
        user    => 'jboss',
    }

    # Certificate and password should be readable only by root and jboss
    exec { "chmod_$module_path":
       command => "chmod -R 440 $module_path",
       require => Exec[$module_path]
    }

    # The standard puppet way to create dirs recursively does not work when paths overlap
    # They do, because many modules are created in /usr/share/jbossas/modules/com...

    #$module_base = [ '/usr/share/jbossas/modules/com',
    #    '/usr/share/jbossas/modules/com/redhat',
    #    '/usr/share/jbossas/modules/com/redhat/lightblue',
    #    '/usr/share/jbossas/modules/com/redhat/lightblue/client']

    #file { $module_base :
    #    ensure   => 'directory',
    #    owner    => 'jboss',
    #    group    => 'jboss',
    #    mode     => '0440',
    #}

}
