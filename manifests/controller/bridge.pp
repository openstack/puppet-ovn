# ovn controller bridge settings
# == Define: ovn::controller::bridge
#
# Bridge settings for ovn controller bridge mappings
# $name is OVN bridge mapping in the format network-name:bridge-name
#
define ovn::controller::bridge {
  $map_split = split($name, ':')
  $bridge    = $map_split[1]
  vs_bridge { $bridge:
    ensure       => present,
    external_ids => "bridge-id=${bridge}"
  }
}
