# ovn controller
# == Class: ovn::controller
#
# installs ovn and starts the ovn-controller service
#
# === Parameters:
#
# [*ovn_remote*]
#   (Required) URL of the remote ovn southbound db.
#   Example: 'tcp:127.0.0.1:6642'
#
# [*ovn_encap_type*]
#   (Optional) The encapsulation type to be used
#   Defaults to 'geneve'
#
# [*ovn_encap_ip*]
#   (Required) IP address of the hypervisor(in which this module is installed) to which
#   the other controllers would use to create a tunnel to this controller
#
# [*ovn_bridge_mappings*]
#   (optional) List of <ovn-network-name>:<bridge-name>
#   Defaults to empty list
#
# [*bridge_interface_mappings*]
#   (optional) List of <bridge-name>:<interface-name> when doing bridge mapping
#   Defaults to empty list
#
class ovn::controller(
  $ovn_remote,
  $ovn_encap_ip,
  $ovn_encap_type            = 'geneve',
  $ovn_bridge_mappings       = [],
  $bridge_interface_mappings = []
) {
  include ::ovn::params
  include ::vswitch::ovs
  include ::stdlib

  validate_string($ovn_remote)
  validate_string($ovn_encap_ip)

  service { 'controller':
    ensure    => true,
    name      => $::ovn::params::ovn_controller_service_name,
    hasstatus => $::ovn::params::ovn_controller_service_status,
    pattern   => $::ovn::params::ovn_controller_service_pattern,
    enable    => true,
    subscribe => Vs_config['external_ids:ovn-remote']
  }

  package { $::ovn::params::ovn_controller_package_name:
    ensure => present,
    name   => $::ovn::params::ovn_controller_package_name,
    before => Service['controller']
  }

  $config_items = {
    'external_ids:ovn-remote'     => { 'value' => $ovn_remote },
    'external_ids:ovn-encap-type' => { 'value' => $ovn_encap_type },
    'external_ids:ovn-encap-ip'   => { 'value' => $ovn_encap_ip },
    'external_ids:hostname'       => { 'value' => $::fqdn },
  }

  if !empty($ovn_bridge_mappings) {
    $bridge_items = {
      'external_ids:ovn-bridge-mappings' => { 'value' => join(any2array($ovn_bridge_mappings), ',') }
    }

    ovn::controller::bridge { $ovn_bridge_mappings:
      before  => Service['controller'],
      require => Service['openvswitch']
    }
    ovn::controller::port { $bridge_interface_mappings:
      before  => Service['controller'],
      require => Service['openvswitch']
    }
  } else {
    $bridge_items = {}
  }

  create_resources('vs_config', merge($config_items, $bridge_items))
  Service['openvswitch'] -> Vs_config<||> -> Service['controller']
}
