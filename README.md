This puppet module is a self contained puppet module to configure a
node running lightblue on EAP6. It has bits to install a JDK and EAP6
on the node. If these are not necessary, it must be edited and
customized for the local setting.

## Public classes

lightblue::service::metadata : Installs the metadata service
lightblue::service::data : Installs the data service

## Hiera
This puppet module makes use of hiera to manage data that can change 
depending on where lightblue is deployed or might need tuning over time.
All hiera keys begin with the class in which they are used.

## Operation

Both lightblue::service::data and lightblue::service::metadata classes
use the lightblue::base class. These classes:
  - install the latest release of the application,
  - install the configuration file to the EAP6 module directory

The lightblue::base class 
  - creates jcliff configuration directory:
  /etc/redhat/lightblue. Configuration file fragments used by jcliff
  are installed under this directory.
  - installs and initialized jcliff
  - sets up properties module under EAP6 
   (/usr/share/jbossas/modules/com/redhat/lightblue/main)
  - installs basic property files
  - configures EAP6

This class depends on packages installed by eap6 and java classes.

lightblue::initrepos class: This is a hack to configure repositories
from the node manifest. Any RPM repositories required to setup the
node should be defined in the node manifest using parameter yum_repos.

Node manifest:

The classes should include one or both of:
    - lightblue::service::data
    - lightblue::service::metadata

The parameters should include:

    yum_repos:
      -
        name: <repo name>
        description: <repo description>
        baseurl: <repo url>
      - 
        ...

Optional hystrix configuration:

    hystrix_command_default_execution_isolation_strategy: THREAD
    hystrix_command_default_execution_isolation_thread_timeoutInMilliseconds: 10000
    hystrix_command_default_circuitBreaker_enabled: false

Hystrix configuration is in
templates/properties/config.properties.erb. Default values for
properties are initialized in hiera and loaded in lightblue::base class.

MongoDB configuration:

Either:
    mongo_server_host: cosmongodb01.cos.redhat.com
    mongo_server_port: 27017

or
    mongo_servers:
      - host: localhost
        port: 27017
      - host: otherhost
        port: 27017
      ...
