# ovn northd
# == Class: ovn::northd
#
# installs ovn package starts the ovn-northd service
#
# [*dbs_listen_ip*]
#   The IP-Address where OVN DBs should be listening
#   Defaults to '0.0.0.0'
#
# [*dbs_cluster_local_addr*]
#   The IP-Address where OVN Clustered DBs should be listening
#   Defaults to undef
#
# [*dbs_cluster_remote_addr*]
#   The IP-Address where OVN Clustered DBs sync from
#   Defaults to undef
#
class ovn::northd(
  $dbs_listen_ip = '0.0.0.0',
  $dbs_cluster_local_addr = undef,
  $dbs_cluster_remote_addr = undef,
) {
  include ovn::params
  include vswitch::ovs

  $ovn_northd_opts_addr = "--db-nb-addr=${dbs_listen_ip} --db-sb-addr=${dbs_listen_ip} \
--db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes"

  if $dbs_cluster_local_addr {
    $ovn_northd_opts_cluster_local_addr = "--db-nb-cluster-local-addr=${dbs_cluster_local_addr} \
--db-sb-cluster-local-addr=${dbs_cluster_local_addr}"
  }

  if $dbs_cluster_remote_addr {
    $ovn_northd_opts_cluster_remote_addr = "--db-nb-cluster-remote-addr=${dbs_cluster_remote_addr} \
--db-sb-cluster-remote-addr=${dbs_cluster_remote_addr}"
  }

  $ovn_northd_opts = join([$ovn_northd_opts_addr,
                          $ovn_northd_opts_cluster_local_addr,
                          $ovn_northd_opts_cluster_remote_addr],
                          ' ')

  augeas { 'config-ovn-northd':
    context => $::ovn::params::ovn_northd_context,
    changes => "set ${$::ovn::params::ovn_northd_option_name} '\"${ovn_northd_opts}\"'",
    before  => Service['northd'],
  }

  service { 'northd':
    ensure    => true,
    enable    => true,
    name      => $::ovn::params::ovn_northd_service_name,
    hasstatus => $::ovn::params::ovn_northd_service_status,
    pattern   => $::ovn::params::ovn_northd_service_pattern,
    require   => Service['openvswitch']
  }

  package { $::ovn::params::ovn_northd_package_name:
    ensure  => present,
    name    => $::ovn::params::ovn_northd_package_name,
    before  => Service['northd'],
    require => Package[$::vswitch::params::ovs_package_name]
  }
}
