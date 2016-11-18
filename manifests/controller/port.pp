# ovn controller bridge-port settings
# == Define: ovn::controller::port
#
# Bridge-interface setting for ovn bridge mapping
# $name should be the mapping in the format <bridge-name>:<interface-name>
#
define ovn::controller::port {
  $map_split = split($name, ':')
  $bridge    = $map_split[0]
  $iface     = $map_split[1]
  vs_port { $iface:
    ensure => present,
    bridge => $bridge
  }
}
