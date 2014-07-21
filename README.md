This puppet module is a self contained puppet module to configure a
node running lightblue on EAP6. It has bits to install a JDK and EAP6
on the node. Changes that could be done easily:
* update to deploy with WildFly
* change version or distribution of java

The puppet classes also use parameters and assumes use of hiera.  The
simplest way to use this puppet module is to use hiera and puppet 3+.
See [Using Hiera with Puppet](http://docs.puppetlabs.com/hiera/1/puppet.html#puppet-variables-passed-to-hiera).

# Quick Start

Two things are required to get started.  This quick start assumes you are not terminating SSL.

1. Setup hiera data
2. Include the desired top level classes

## Hiera
This is broken into two sections:

1. stuff you can copy and paste as-is
2. stuff you'll have to supply your own values for

The following are reasonable defaults for many parameters.
```
lightblue::eap::module::hystrix::command::default::execution_isolation_strategy: THREAD
lightblue::eap::module::hystrix::command::default::execution_isolation_thread_timeoutInMilliseconds: 60000
lightblue::eap::module::hystrix::command::default::circuitBreaker_enabled: false
lightblue::eap::module::hystrix::command::mongodb::execution_isolation_timeoutInMilliseconds: 50000
lightblue::eap::module::hystrix::threadpool::mongodb::coreSize: 30

lightblue::eap::module::datastore::mongo::noCertValidation: true
lightblue::eap::module::datastore::mongo::auth::mechanism: MONGODB_CR_MECHANISM
lightblue::eap::module::datastore::mongo::auth::source: admin

lightblue::eap::logging::format: %d [%t] %-5p [%c] %m%n
lightblue::eap::logging::level::root: WARN
lightblue::eap::logging::level::lightblue: WARN

lightblue::eap::java::Xms: 786m
lightblue::eap::java::Xmx: 1572m

# package stuff
lightblue::jcliff::package::name: jcliff
lightblue::jcliff::package::ensure: latest
lightblue::service::data::package::name: lightblue-rest-crud
lightblue::service::data::package::ensure: latest
lightblue::service::metadata::package::name: lightblue-rest-metadata
lightblue::service::metadata::package::ensure: latest
lightblue::eap::package::name: jbossas-standalone
lightblue::eap::package::ensure: 7.2.0-8.Final_redhat_8.ep6.el6

# using single server configuration, set the array version to undef so hiera is happy
lightblue::mongo::servers: undef
```

And the following will require you to setup for your environment:
```
lightblue::yumrepo::jbeap::baseurl: <baseurl for JBEAP>
lightblue::yumrepo::jbeaptools::baseurl: <baseurl for JBEAP-TOOLS>
lightblue::yumrepo::lightblue::baseurl: <baseurl for lightblue>

lightblue::eap::module::datastore::mongo::auth::username: <mongo username>
lightblue::eap::module::datastore::mongo::auth::password: <mongo password>
lightblue::mongo::server_host: <mongo server fqdn or ip address>
lightblue::mongo::server_port: 27017
```

## Classes
Simply add the following to your host manifest, however that is done in your environment:
* lightblue::service::metadata : Installs the metadata service
* lightblue::service::data : Installs the data service


# Structure
Bits of the puppet module are broken out into sub-sections to make managing them easier:
* authentication - setup of client certificate
* eap - configuration of JBoss EAP
* jcliff - setup of and define for jcliff, tool for configuring jboss via cli in puppet
* service - bucket for deploying RESTful services
* yumrepo - bucket for deploying yum repositories

![Dependencies](https://raw.githubusercontent.com/lightblue-platform/lightblue-puppet/master/docs/lightblue.png)

The classes with no other dependencies at the top of the image are those that can be directly included in your module.  In addition to `lightblue::service::data` and `lightblue::service::metadata` used in the quick start there are:
* `lightblue::authentication::certificate` - enable client certificates
* `lightblue::eap::ssl` - enable ssl termination in EAP

For full documentation on each of these, see the RDocs included in the source.
* [lightblue::service::metadata](https://github.com/lightblue-platform/lightblue-puppet/blob/master/manifests/service/metadata.pp)
* [lightblue::service::data](https://github.com/lightblue-platform/lightblue-puppet/blob/master/manifests/service/data.pp)
* [lightblue::authentication::certificate](https://github.com/lightblue-platform/lightblue-puppet/blob/master/manifests/authentication/certificate.pp)
* [lightblue::eap::ssl](https://github.com/lightblue-platform/lightblue-puppet/blob/master/manifests/eap/ssl.pp)

# Gotyas

## Use of default empty string
Puppet is pretty bad when handling undefined variables.  Especially when passing to an ERB template.  The rule of thumb has become to set all params to default to '' and check for that in the ERB.  Do not pass nil or undef to anything or it will break.
