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
# [*hostname*]
#   (optional) The hostname to use with the external id
#   Defaults to $::fqdn
#
# [*ovn_bridge*]
#   (optional) Name of the integration bridge.
#   Defaults to 'br-int'
#
# [*enable_hw_offload*]
#   (optional) Configure OVS to use
#   Hardware Offload. This feature is
#   supported from ovs 2.8.0.
#   Defaults to False.
#
# [*mac_table_size*]
#  Set the mac table size for the provider bridges if defined in ovn_bridge_mappings
#  Defaults to 50000
#
# [*ovn_remote_probe_interval*]
#  (optional) Set probe interval, based on user configuration, value is in ms
#  Defaults to 60000
#

class ovn::controller(
  $ovn_remote,
  $ovn_encap_ip,
  $ovn_encap_type            = 'geneve',
  $ovn_bridge_mappings       = [],
  $bridge_interface_mappings = [],
  $hostname                  = $::fqdn,
  $ovn_bridge                = 'br-int',
  $enable_hw_offload         = false,
  $mac_table_size            = 50000,
  $ovn_remote_probe_interval = 60000,
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
    'external_ids:ovn-remote'                => { 'value' => $ovn_remote },
    'external_ids:ovn-encap-type'            => { 'value' => $ovn_encap_type },
    'external_ids:ovn-encap-ip'              => { 'value' => $ovn_encap_ip },
    'external_ids:hostname'                  => { 'value' => $hostname },
    'external_ids:ovn-bridge'                => { 'value' => $ovn_bridge },
    'external_ids:ovn-remote-probe-interval' => { 'value' => "${ovn_remote_probe_interval}" },
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

  if $enable_hw_offload {
    $hw_offload = { 'other_config:hw-offload' => { 'value' => bool2str($enable_hw_offload) } }
  }else {
    $hw_offload = {}
  }

  create_resources('vs_config', merge($config_items, $bridge_items, $hw_offload))
  Service['openvswitch'] -> Vs_config<||> -> Service['controller']

  if !empty($ovn_bridge_mappings) {
    # For each provider bridge, set the mac table size.
    $ovn_bridge_mappings.each |String $mappings| {
      $mapping = split($mappings, ':')
      $br = $mapping[1]
      if !empty($br) {
        # TODO(numans): Right now puppet-vswitch's vs_bridge doesn't support
        # setting the column 'other-config' for the Bridge table.
        # Switch to using vs_bridge once the support is available.
        exec { $br:
          command => "ovs-vsctl --timeout=5 set Bridge ${br} other-config:mac-table-size=${mac_table_size}",
          unless  => "ovs-vsctl get bridge ${br} other-config:mac-table-size | grep -q -w ${mac_table_size}",
          path    => '/usr/sbin:/usr/bin:/sbin:/bin',
          require => [ Service['openvswitch'], Vs_bridge[$br] ],
        }
      }
    }
  } else {
    # ovn-bridge-mappings is not defined. Clear the existing value if configured.
    vs_config { 'external_ids:ovn-bridge-mappings':
      ensure  => absent,
      require => Service['openvswitch']
    }
  }
}
