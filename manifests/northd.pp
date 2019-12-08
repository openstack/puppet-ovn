# ovn northd
# == Class: ovn::northd
#
# installs ovn package starts the ovn-northd service
#
# [*dbs_listen_ip*]
#   The IP-Address where OVN DBs should be listening
#   Defaults to '0.0.0.0'
#
class ovn::northd($dbs_listen_ip = '0.0.0.0') {
  include ovn::params
  include vswitch::ovs

  if $::osfamily == 'RedHat' {
    augeas { 'sysconfig-ovn-northd':
      context =>  '/files/etc/sysconfig/ovn-northd',
      changes =>  "set OVN_NORTHD_OPTS '\"--db-nb-addr=${dbs_listen_ip} --db-sb-addr=${dbs_listen_ip} \
--db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes\"'",
      before  =>  Service['northd'],
    }
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
