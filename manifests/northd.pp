# ovn northd
# == Class: ovn::northd
#
# installs ovn package starts the ovn-northd service
#
# [*package_ensure*]
#   (Optional) State of the openvswitch package
#   Defaults to 'present'.
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
# [*ovn_northd_nb_db*]
#   NB DB address(es)
#   Defaults to undef
#
# [*ovn_northd_sb_db*]
#   SB DB address(es)
#   Defaults to undef
#
# [*ovn_northd_ssl_key*]
#   OVN Northd SSL private key file
#   Defaults to undef
#
# [*ovn_northd_ssl_cert*]
#   OVN Northd SSL certificate file
#   Defaults to undef
#
# [*ovn_northd_ssl_ca_cert*]
#   OVN Northd SSL CA certificate file
#   Defaults to undef
#
# [*ovn_nb_db_ssl_key*]
#   OVN NB DB SSL private key file
#   Defaults to undef
#
# [*ovn_nb_db_ssl_cert*]
#   OVN NB DB SSL certificate file
#   Defaults to undef
#
# [*ovn_nb_db_ssl_ca_cert*]
#   OVN NB DB SSL CA certificate file
#   Defaults to undef
#
# [*ovn_sb_db_ssl_key*]
#   OVN SB DB SSL private key file
#   Defaults to undef
#
# [*ovn_sb_db_ssl_cert*]
#   OVN SB DB SSL certificate file
#   Defaults to undef
#
# [*ovn_sb_db_ssl_ca_cert*]
#   OVN SB DB SSL CA certificate file
#   Defaults to undef
#
# [*ovn_northd_extra_opts*]
#   Additional command line options for ovn-northd service
#   Defaults to []
#
class ovn::northd(
  String $package_ensure = 'present',
  String $dbs_listen_ip = '0.0.0.0',
  Optional[String] $dbs_cluster_local_addr = undef,
  Optional[String] $dbs_cluster_remote_addr = undef,
  Optional[Variant[String, Array[String]]] $ovn_northd_nb_db = undef,
  Optional[Variant[String, Array[String]]] $ovn_northd_sb_db = undef,
  Optional[Stdlib::Absolutepath] $ovn_northd_ssl_key = undef,
  Optional[Stdlib::Absolutepath] $ovn_northd_ssl_cert = undef,
  Optional[Stdlib::Absolutepath] $ovn_northd_ssl_ca_cert = undef,
  Optional[Stdlib::Absolutepath] $ovn_nb_db_ssl_key = undef,
  Optional[Stdlib::Absolutepath] $ovn_nb_db_ssl_cert = undef,
  Optional[Stdlib::Absolutepath] $ovn_nb_db_ssl_ca_cert = undef,
  Optional[Stdlib::Absolutepath] $ovn_sb_db_ssl_key = undef,
  Optional[Stdlib::Absolutepath] $ovn_sb_db_ssl_cert = undef,
  Optional[Stdlib::Absolutepath] $ovn_sb_db_ssl_ca_cert = undef,
  Array[String] $ovn_northd_extra_opts = [],
) {
  include ovn::params
  include vswitch::ovs

  $dbs_listen_ip_real = normalize_ip_for_uri($dbs_listen_ip)

  $ovn_northd_opts_addr = [
    "--db-nb-addr=${dbs_listen_ip_real}",
    "--db-sb-addr=${dbs_listen_ip_real}",
  ]

  # NOTE(tkajinam): --db-(n|s)b-create-insecure-remote enables remote without
  #                 ssl ( ptcp:<port>:<ip> ).
  $ovn_northd_opts_nb_create_insecure_remote = $ovn_nb_db_ssl_key ? {
    undef   => ['--db-nb-create-insecure-remote=yes'],
    default => ['--db-nb-create-insecure-remote=no']
  }
  $ovn_northd_opts_sb_create_insecure_remote = $ovn_sb_db_ssl_key ? {
    undef   => ['--db-sb-create-insecure-remote=yes'],
    default => ['--db-sb-create-insecure-remote=no']
  }

  if $dbs_cluster_local_addr {
    $ovn_northd_opts_nb_cluster_local_proto = $ovn_nb_db_ssl_key ? {
      undef   => [],
      default => ['--db-nb-cluster-local-proto=ssl'],
    }
    $ovn_northd_opts_sb_cluster_local_proto = $ovn_nb_db_ssl_key ? {
      undef   => [],
      default => ['--db-sb-cluster-local-proto=ssl'],
    }
    $ovn_northd_opts_cluster_local_addr = [
      "--db-nb-cluster-local-addr=${dbs_cluster_local_addr}",
      "--db-sb-cluster-local-addr=${dbs_cluster_local_addr}"
    ]
  } else {
    $ovn_northd_opts_nb_cluster_local_proto = []
    $ovn_northd_opts_sb_cluster_local_proto = []
    $ovn_northd_opts_cluster_local_addr = []
  }

  if $dbs_cluster_remote_addr {
    $ovn_northd_opts_nb_cluster_remote_proto = $ovn_nb_db_ssl_key ? {
      undef   => [],
      default => ['--db-nb-cluster-remote-proto=ssl']
    }
    $ovn_northd_opts_sb_cluster_remote_proto = $ovn_sb_db_ssl_key ? {
      undef   => [],
      default => ['--db-sb-cluster-remote-proto=ssl']
    }
    $ovn_northd_opts_cluster_remote_addr = [
      "--db-nb-cluster-remote-addr=${dbs_cluster_remote_addr}",
      "--db-sb-cluster-remote-addr=${dbs_cluster_remote_addr}"
    ]
  } else {
    $ovn_northd_opts_nb_cluster_remote_proto = []
    $ovn_northd_opts_sb_cluster_remote_proto = []
    $ovn_northd_opts_cluster_remote_addr = []
  }

  $ovn_northd_nb_db_opts = $ovn_northd_nb_db ? {
    String        => ["--ovn-northd-nb-db=${ovn_northd_nb_db}"],
    Array[String] => ["--ovn-northd-nb-db=${join($ovn_northd_nb_db, ',')}"],
    undef         => [],
    default       => fail('ovn_northd_nb_db_opts must be of type String or Array[String]'),
  }

  $ovn_northd_sb_db_opts = $ovn_northd_sb_db ? {
    String        => ["--ovn-northd-sb-db=${ovn_northd_sb_db}"],
    Array[String] => ["--ovn-northd-sb-db=${join($ovn_northd_sb_db, ',')}"],
    undef         => [],
    default       => fail('ovn_northd_sb_db_opts must be of type String or Array[String]'),
  }

  if $ovn_northd_ssl_key and $ovn_northd_ssl_cert and $ovn_northd_ssl_ca_cert {
    $ovn_northd_ssl_opts = [
      "--ovn-northd-ssl-key=${ovn_northd_ssl_key}",
      "--ovn-northd-ssl-cert=${ovn_northd_ssl_cert}",
      "--ovn-northd-ssl-ca-cert=${ovn_northd_ssl_ca_cert}"
    ]
  } elsif ! ($ovn_northd_ssl_key or $ovn_northd_ssl_cert or $ovn_northd_ssl_ca_cert) {
    $ovn_northd_ssl_opts = []
  } else {
    fail('The ovn_northd_ssl_key, cert and ca_cert are required to use SSL.')
  }

  if $ovn_nb_db_ssl_key and $ovn_nb_db_ssl_cert and $ovn_nb_db_ssl_ca_cert {
    $ovn_nb_db_ssl_opts = [
      "--ovn-nb-db-ssl-key=${ovn_nb_db_ssl_key}",
      "--ovn-nb-db-ssl-cert=${ovn_nb_db_ssl_cert}",
      "--ovn-nb-db-ssl-ca-cert=${ovn_nb_db_ssl_ca_cert}"
    ]
  } elsif ! ($ovn_nb_db_ssl_key or $ovn_nb_db_ssl_cert or $ovn_nb_db_ssl_ca_cert) {
    $ovn_nb_db_ssl_opts = []
  } else {
    fail('The ovn_nb_db_ssl_key, cert and ca_cert are required to use SSL.')
  }

  if $ovn_sb_db_ssl_key and $ovn_sb_db_ssl_cert and $ovn_sb_db_ssl_ca_cert {
    $ovn_sb_db_ssl_opts = [
      "--ovn-sb-db-ssl-key=${ovn_sb_db_ssl_key}",
      "--ovn-sb-db-ssl-cert=${ovn_sb_db_ssl_cert}",
      "--ovn-sb-db-ssl-ca-cert=${ovn_sb_db_ssl_ca_cert}"
    ]
  } elsif ! ($ovn_sb_db_ssl_key or $ovn_sb_db_ssl_cert or $ovn_sb_db_ssl_ca_cert) {
    $ovn_sb_db_ssl_opts = []
  } else {
    fail('The ovn_sb_db_ssl_key, cert and ca_cert are required to use SSL.')
  }

  $ovn_northd_opts = join($ovn_northd_opts_addr +
                          $ovn_northd_opts_nb_create_insecure_remote +
                          $ovn_northd_opts_sb_create_insecure_remote +
                          $ovn_northd_opts_nb_cluster_local_proto +
                          $ovn_northd_opts_sb_cluster_local_proto +
                          $ovn_northd_opts_cluster_local_addr +
                          $ovn_northd_opts_nb_cluster_remote_proto +
                          $ovn_northd_opts_sb_cluster_remote_proto +
                          $ovn_northd_opts_cluster_remote_addr +
                          $ovn_northd_nb_db_opts +
                          $ovn_northd_sb_db_opts +
                          $ovn_northd_ssl_opts +
                          $ovn_nb_db_ssl_opts +
                          $ovn_sb_db_ssl_opts +
                          $ovn_northd_extra_opts,
                          ' ')

  augeas { 'config-ovn-northd':
    context => $::ovn::params::ovn_northd_context,
    changes => "set ${$::ovn::params::ovn_northd_option_name} '\"${ovn_northd_opts}\"'",
    require => Package[$::ovn::params::ovn_northd_package_name],
    before  => Service['northd'],
  }

  service { 'northd':
    ensure  => true,
    enable  => true,
    name    => $::ovn::params::ovn_northd_service_name,
    require => Service['openvswitch']
  }

  package { $::ovn::params::ovn_northd_package_name:
    ensure  => $package_ensure,
    name    => $::ovn::params::ovn_northd_package_name,
    notify  => Service['northd'],
    require => Package[$::vswitch::params::ovs_package_name]
  }

  # NOTE(tkajinam): We have to escapte [ and ] otherwise egrep intereprets
  #                 these wrongly.
  $dbs_listen_ip_reg = regsubst(regsubst($dbs_listen_ip_real, '\]$', '\\]'), '^\[', '\\[')

  if $ovn_nb_db_ssl_key {
    exec { 'ovn-nb-set-connection':
      command => "ovn-nbctl set-connection pssl:6641:${dbs_listen_ip_real}",
      path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
      unless  => "ovn-nbctl get-connection | egrep -e '^pssl:6641:${dbs_listen_ip_reg}$'",
      tag     => 'ovn-db-set-connections',
      require => Service['northd']
    }
  }
  if $ovn_sb_db_ssl_key {
    exec { 'ovn-sb-set-connection':
      command => "ovn-sbctl set-connection pssl:6642:${dbs_listen_ip_real}",
      path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
      unless  => "ovn-sbctl get-connection | egrep -e ' pssl:6642:${dbs_listen_ip_reg}$'",
      tag     => 'ovn-db-set-connections',
      require => Service['northd']
    }
  }
}
