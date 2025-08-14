# ovn controller
# == Class: ovn::controller
#
# installs ovn and starts the ovn-controller service
#
# === Parameters:
#
# [*package_name*]
#   (required) Name of ovn-controller package.
#
# [*service_name*]
#   (required) Name of ovn-controller service.
#
# [*environment_file_path*]
#   (required) File path of the ovn-controller environment file
#
# [*opts_envvar_name*]
#   (required) Name of the environment variable to customize options to launch
#   the ovn-controller service.
#
# [*ovn_remote*]
#   (Required) URL of the remote ovn southbound db.
#   Example: 'tcp:127.0.0.1:6642'
#
# [*ovn_encap_ip*]
#   (Required) IP address of the hypervisor(in which this module is installed)
#   to which the other controllers would use to create a tunnel to this
#   controller
#
# [*package_ensure*]
#   (Optional) State of the openvswitch package
#   Defaults to 'present'.
#
# [*ovn_encap_type*]
#   (Optional) The encapsulation type to be used
#   Defaults to 'geneve'
#
# [*ovn_encap_ip_default*]
#   (Optional) When ovn-encap-ip contains multiple IPs, this field indicates
#   the default one.
#
# [*ovn_encap_tos*]
#   (Optional) The value to be applied to OVN tunnel interface's option:tos.
#   Defaults to undef
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
#   Defaults to $facts['networking']['fqdn']
#
# [*ovn_bridge*]
#   (optional) Name of the integration bridge.
#   Defaults to 'br-int'
#
# [*mac_table_size*]
#  Set the mac table size for the provider bridges if defined in ovn_bridge_mappings
#  Defaults to undef
#
# [*datapath_type*]
#   (optional) Datapath type for ovs bridges
#   Defaults to undef
#
# [*enable_dpdk*]
#   (optional) Enable or not DPDK with OVS
#   Defaults to false.
#
# [*ovn_cms_options*]
#   (optional) A list of options that will be consumed by the CMS Plugin and
#   which specific to this particular chassis.
#   Defaults to undef
#
# [*ovn_remote_probe_interval*]
#  (optional) Set probe interval, based on user configuration, value is in ms
#  Defaults to 60000
#
# [*ovn_transport_zones*]
#  (optional) List of the transport zones to which the chassis belongs to.
#  Defaults to empty list
#
# [*enable_ovn_match_northd*]
#  (optional) When set to true, enable update of ovn_controller after
#  ovn-northd by blocking new message from the ovn-northd to be
#  accepted by the ovn_controller until they have the same version.
#  This need >= ovn2.13-20.09.0-17.
#  Default to false (keep the original behavior)
#
# [*ovn_chassis_mac_map*]
#  (optional) A list or a hash of key-value pairs that map a chassis specific mac to
#  a physical network name. An example value mapping two chassis macs to
#  two physical network names would be:
#  physnet1:aa:bb:cc:dd:ee:ff,physnet2:a1:b2:c3:d4:e5:f6 or
#  {
#    physnet1 => aa:bb:cc:dd:ee:ff,
#    physnet2 => a1:b2:c3:d4:e5:f6
#  }
#  These are the macs that ovn-controller will replace a router port
#  mac with, if packet is going from a distributed router port on
#  vlan type logical switch.
#  Defaults to empty list
#
# [*ovn_monitor_all*]
#  (optional) A boolean value that tells if ovn-controller should monitor all
#  records of tables in ovs-database. If set to false, it will conditionally
#  monitor the records that is needed in the current chassis.
#  Default to false (keep the original behavior)
#
# [*manage_ovs_bridge*]
#  (optional) Create ovs bridges according to ovn_bridge_mappings.
#  Defaults to true
#
# [*ovn_ofctrl_wait_before_clear*]
#  (optional) Time (ms) to wait at startup before clearing openflow rules and
#  install new ones.
#  Defaults to 8000
#
# [*ovn_controller_ssl_key*]
#   OVN Controller SSL private key file
#   Defaults to undef
#
# [*ovn_controller_ssl_cert*]
#   OVN Controller SSL certificate file
#   Defaults to undef
#
# [*ovn_controller_ssl_ca_cert*]
#   OVN Controller SSL CA certificate file
#   Defaults to undef
#
# [*ovn_controller_extra_opts*]
#   Additional command line options for ovn-controller service
#   Defaults to []
#
# DEPRECATED PARAMETERS
#
# [*ovn_openflow_probe_interval*]
#  (optional) The inactivity probe interval of the OpenFlow
#  connection to the OpenvSwitch integration bridge, in
#  seconds. If the value is zero, it disables the connection keepalive feature.
#  If the value is nonzero, then it will be forced to a value of at least 5s.
#  Defaults to undef
#
class ovn::controller(
  String[1] $service_name,
  String[1] $package_name,
  Stdlib::Absolutepath $environment_file_path,
  String[1] $opts_envvar_name,
  String $ovn_remote,
  Variant[Stdlib::IP::Address, Array[Stdlib::IP::Address]] $ovn_encap_ip,
  String $package_ensure                                            = 'present',
  Variant[Ovn::EncapType, Array[Ovn::EncapType]] $ovn_encap_type    = 'geneve',
  Optional[Stdlib::IP::Address] $ovn_encap_ip_default               = undef,
  Optional[Variant[String, Integer]] $ovn_encap_tos                 = undef,
  Ovn::BridgeMappings $ovn_bridge_mappings                          = [],
  Array[String[1]] $bridge_interface_mappings                       = [],
  String[1] $hostname                                               = $facts['networking']['fqdn'],
  String[1] $ovn_bridge                                             = 'br-int',
  Optional[Integer[0]] $mac_table_size                              = undef,
  Optional[String[1]] $datapath_type                                = undef,
  Boolean $enable_dpdk                                              = false,
  Optional[Variant[String[1], Array[String[1]]]] $ovn_cms_options   = undef,
  Integer[0] $ovn_remote_probe_interval                             = 60000,
  Array[String[1]] $ovn_transport_zones                             = [],
  Boolean $enable_ovn_match_northd                                  = false,
  Variant[Array[String], Hash[String, String]] $ovn_chassis_mac_map = [],
  Boolean $ovn_monitor_all                                          = false,
  Boolean $manage_ovs_bridge                                        = true,
  Integer[0] $ovn_ofctrl_wait_before_clear                          = 8000,
  Optional[Stdlib::Absolutepath] $ovn_controller_ssl_key            = undef,
  Optional[Stdlib::Absolutepath] $ovn_controller_ssl_cert           = undef,
  Optional[Stdlib::Absolutepath] $ovn_controller_ssl_ca_cert        = undef,
  Array[String[1]] $ovn_controller_extra_opts                       = [],
  # DEPRECATED PARAMETERS
  Optional[Integer[0]] $ovn_openflow_probe_interval                 = undef,
) {

  if $enable_dpdk and ! $datapath_type {
    fail('Datapath type must be set when DPDK is enabled')
  }

  if $enable_dpdk {
    require vswitch::dpdk
  } else {
    require vswitch::ovs
  }

  include stdlib

  service { 'controller':
    ensure    => true,
    name      => $service_name,
    enable    => true,
    subscribe => Vs_config['external_ids:ovn-remote'],
    tag       => 'ovn',
  }

  package { 'ovn-controller':
    ensure => $package_ensure,
    notify => Service['controller'],
    name   => $package_name,
    tag    => 'ovn',
  }

  if $ovn_controller_ssl_key and $ovn_controller_ssl_cert and $ovn_controller_ssl_ca_cert {
    $ovn_controller_ssl_opts = [
      "--ovn-controller-ssl-key=${ovn_controller_ssl_key}",
      "--ovn-controller-ssl-cert=${ovn_controller_ssl_cert}",
      "--ovn-controller-ssl-ca-cert=${ovn_controller_ssl_ca_cert}"
    ]
  } elsif ! ($ovn_controller_ssl_key or $ovn_controller_ssl_cert or $ovn_controller_ssl_ca_cert) {
    $ovn_controller_ssl_opts = []
  } else {
    fail('The ovn_controller_ssl_key, cert and ca_cert are required to use SSL.')
  }

  $ovn_controller_opts = join($ovn_controller_ssl_opts + $ovn_controller_extra_opts, ' ')

  augeas { 'config-ovn-controller':
    context => "/files${environment_file_path}",
    changes => "set ${opts_envvar_name} '\"${ovn_controller_opts}\"'",
    require => Package['ovn-controller'],
    notify  => Service['controller'],
  }

  $config_items = {
    'external_ids:ovn-remote'                   => { 'value' => $ovn_remote },
    'external_ids:ovn-encap-type'               => { 'value' => join(any2array($ovn_encap_type), ',') },
    'external_ids:ovn-encap-ip'                 => { 'value' => join(any2array($ovn_encap_ip), ',') },
    'external_ids:hostname'                     => { 'value' => $hostname },
    'external_ids:ovn-bridge'                   => { 'value' => $ovn_bridge },
    'external_ids:ovn-remote-probe-interval'    => { 'value' => $ovn_remote_probe_interval },
    'external_ids:ovn-monitor-all'              => { 'value' => $ovn_monitor_all },
    'external_ids:ovn-ofctrl-wait-before-clear' => { 'value' => $ovn_ofctrl_wait_before_clear },
  }

  if $ovn_openflow_probe_interval != undef {
    warning("The ovn_openflow_probe_interval parameter was deprecated and \
will be removed in a future release.")

    $of_probe_interval = {
      'external_ids:ovn-openflow-probe-interval' => { 'value' => $ovn_openflow_probe_interval },
    }
  } else {
    $of_probe_interval = {
      'external_ids:ovn-openflow-probe-interval' => { 'ensure' => 'absent' },
    }
  }

  if $ovn_encap_ip_default {
    $encap_ip_default = {
      'external_ids:ovn-encap-ip-default' => { 'value' => $ovn_encap_ip_default }
    }
  } else {
    $encap_ip_default = {
      'external_ids:ovn-encap-ip-default' => { 'ensure' => 'absent' }
    }
  }

  if $ovn_cms_options {
    $cms_options = {
      'external_ids:ovn-cms-options' => { 'value' => join(any2array($ovn_cms_options), ',') }
    }
  } else {
    $cms_options = {
      'external_ids:ovn-cms-options' => { 'ensure' => 'absent' }
    }
  }

  if $ovn_encap_tos {
    $encap_tos = {
      'external_ids:ovn-encap-tos' => { 'value' => $ovn_encap_tos }
    }
  } else {
    $encap_tos = {
      'external_ids:ovn-encap-tos' => { 'ensure' => 'absent' }
    }
  }

  if !empty($ovn_chassis_mac_map) {
    if $ovn_chassis_mac_map =~ Hash {
      $chassis_mac_map = {
        'external_ids:ovn-chassis-mac-mappings' => { 'value' => join(join_keys_to_values($ovn_chassis_mac_map, ':'), ',') }
      }
    } else {
      $chassis_mac_map = {
        'external_ids:ovn-chassis-mac-mappings' => { 'value' => join(any2array($ovn_chassis_mac_map), ',') }
      }
    }
  } else {
    $chassis_mac_map = {
      'external_ids:ovn-chassis-mac-mappings' => { 'ensure' => 'absent' }
    }
  }

  if !empty($ovn_bridge_mappings) {

    $ovn_bridge_mappings_real = $ovn_bridge_mappings ? {
      Hash    => join_keys_to_values($ovn_bridge_mappings, ':'),
      String  => $ovn_bridge_mappings.split(',').strip(),
      default => $ovn_bridge_mappings,
    }

    $bridge_items = {
      'external_ids:ovn-bridge-mappings' => { 'value' => join(any2array($ovn_bridge_mappings_real), ',') }
    }

    if $manage_ovs_bridge {
      ovn::controller::bridge { $ovn_bridge_mappings_real:
        mac_table_size => $mac_table_size,
        before         => Service['controller'],
        require        => Service['openvswitch']
      }
      ovn::controller::port { $bridge_interface_mappings:
        before  => Service['controller'],
        require => Service['openvswitch']
      }
    }
  } else {
    $bridge_items = {
      'external_ids:ovn-bridge-mappings' => { 'ensure' => 'absent' }
    }
  }

  if !empty($ovn_transport_zones) {
    $tz_items = {
      'external_ids:ovn-transport-zones' => { 'value' => join(any2array($ovn_transport_zones), ',') }
    }
  } else {
    $tz_items = {
      'external_ids:ovn-transport-zones' => { 'ensure' => 'absent' }
    }
  }

  if $datapath_type {
    $datapath_config = {
      'external_ids:ovn-bridge-datapath-type' => { 'value' => $datapath_type }
    }
  } else {
    $datapath_config = {
      'external_ids:ovn-bridge-datapath-type' => { 'ensure' => 'absent' }
    }
  }

  $ovn_match_northd = {
    'external_ids:ovn-match-northd-version' => { 'value' => $enable_ovn_match_northd }
  }
  create_resources(
    'vs_config',
    stdlib::merge(
      $config_items,
      $of_probe_interval,
      $encap_ip_default,
      $cms_options,
      $encap_tos,
      $chassis_mac_map,
      $bridge_items,
      $tz_items,
      $datapath_config,
      $ovn_match_northd
    )
  )

  Vs_config<||> -> Service['controller']
}
