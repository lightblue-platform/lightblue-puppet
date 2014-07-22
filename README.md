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
Example hiera configurations are broken into two sections.

1. [lightblue.yaml](https://raw.githubusercontent.com/lightblue-platform/lightblue-puppet/master/docs/hiera/lightblue.yaml) - stuff you can copy and paste as-is
2. [env.yaml](https://raw.githubusercontent.com/lightblue-platform/lightblue-puppet/master/docs/hiera/env.yaml) - stuff you'll have to supply your own values for

## Classes
Simply add the following to your host manifest, however that is done in your environment:
* `lightblue::service::metadata` - Installs the metadata service
* `lightblue::service::data` - Installs the data service


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
