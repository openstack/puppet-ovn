# ovn controller bridge settings
# == Define: ovn::controller::bridge
#
# Bridge settings for ovn controller bridge mappings
# $name is OVN bridge mapping in the format network-name:bridge-name
#
# === Parameters:
#
# [*mac_table_size*]
#  Set the mac table size for the provider bridges
#  Defaults to undef
#
define ovn::controller::bridge(
  Optional[Integer[0]] $mac_table_size = undef,
){
  $map_split = split($name, ':')
  $bridge    = $map_split[1]

  vs_bridge { $bridge:
    ensure         => present,
    mac_table_size => $mac_table_size,
    external_ids   => "bridge-id=${bridge}",
  }
}
