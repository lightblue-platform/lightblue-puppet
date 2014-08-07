# Sets up a base node with java, EAP6, jcliff, and lightblue module
class lightblue::base {
  include lightblue::eap::logging
  include lightblue::eap::module
  include lightblue::eap::webconnector
}
