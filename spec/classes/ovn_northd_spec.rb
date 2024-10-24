require 'spec_helper'

describe 'ovn::northd' do

  shared_examples_for 'systemd env' do
    context 'with default parameters' do
      let :params do
        {}
      end
      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] + " '\"" +
                      "--db-nb-addr=0.0.0.0 --db-sb-addr=0.0.0.0" +
                      " --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes" +
                      "\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'ptcp:6641:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^ptcp:6641:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'ptcp:6642:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' ptcp:6642:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with ipv6' do
      let :params do
        {
          :dbs_listen_ip => '::1'
        }
      end
      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] +
                      " '\"--db-nb-addr=[::1] --db-sb-addr=[::1] --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'ptcp:6641:[::1]'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^ptcp:6641:\\[::1\\]$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'ptcp:6642:[::1]'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' ptcp:6642:\\[::1\\]$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with parameters' do
      let :params do
        {
          :ovn_northd_nb_db       => 'ssl:192.0.2.1:6645,ssl:192.0.2.2:6645,ssl:192.0.2.3:6645',
          :ovn_northd_sb_db       => ['ssl:192.0.2.1:6646', 'ssl:192.0.2.2:6646', 'ssl:192.0.2.3:6646'],
          :ovn_northd_ssl_key     => '/path/to/key.pem',
          :ovn_northd_ssl_cert    => '/path/to/cert.pem',
          :ovn_northd_ssl_ca_cert => '/path/to/cacert.pem',
        }
      end

      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] + " '\"" +
                      "--db-nb-addr=0.0.0.0 --db-sb-addr=0.0.0.0" +
                      " --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes" +
                      " --ovn-northd-nb-db=ssl:192.0.2.1:6645,ssl:192.0.2.2:6645,ssl:192.0.2.3:6645" +
                      " --ovn-northd-sb-db=ssl:192.0.2.1:6646,ssl:192.0.2.2:6646,ssl:192.0.2.3:6646" +
                      " --ovn-northd-ssl-key=/path/to/key.pem --ovn-northd-ssl-cert=/path/to/cert.pem --ovn-northd-ssl-ca-cert=/path/to/cacert.pem" +
                      "\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'ptcp:6641:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^ptcp:6641:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'ptcp:6642:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' ptcp:6642:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with nb db ssl enabled' do
      let :params do
        {
          :ovn_nb_db_ssl_key     => '/path/to/dbkey.pem',
          :ovn_nb_db_ssl_cert    => '/path/to/dbcert.pem',
          :ovn_nb_db_ssl_ca_cert => '/path/to/dbcacert.pem',
        }
      end

      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] + " '\"" +
                      "--db-nb-addr=0.0.0.0 --db-sb-addr=0.0.0.0" +
                      " --db-nb-create-insecure-remote=no --db-sb-create-insecure-remote=yes" +
                      " --ovn-nb-db-ssl-key=/path/to/dbkey.pem --ovn-nb-db-ssl-cert=/path/to/dbcert.pem --ovn-nb-db-ssl-ca-cert=/path/to/dbcacert.pem" +
                      "\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'pssl:6641:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^pssl:6641:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'ptcp:6642:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' ptcp:6642:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with ipv6 and nb db ssl enabled' do
      let :params do
        {
          :dbs_listen_ip         => '::1',
          :ovn_nb_db_ssl_key     => '/path/to/dbkey.pem',
          :ovn_nb_db_ssl_cert    => '/path/to/dbcert.pem',
          :ovn_nb_db_ssl_ca_cert => '/path/to/dbcacert.pem',
        }
      end

      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] + " '\"" +
                      "--db-nb-addr=[::1] --db-sb-addr=[::1]" +
                      " --db-nb-create-insecure-remote=no --db-sb-create-insecure-remote=yes" +
                      " --ovn-nb-db-ssl-key=/path/to/dbkey.pem --ovn-nb-db-ssl-cert=/path/to/dbcert.pem --ovn-nb-db-ssl-ca-cert=/path/to/dbcacert.pem" +
                      "\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'pssl:6641:[::1]'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^pssl:6641:\\[::1\\]$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'ptcp:6642:[::1]'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' ptcp:6642:\\[::1\\]$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with sb db ssl enabled' do
      let :params do
        {
          :ovn_sb_db_ssl_key     => '/path/to/dbkey.pem',
          :ovn_sb_db_ssl_cert    => '/path/to/dbcert.pem',
          :ovn_sb_db_ssl_ca_cert => '/path/to/dbcacert.pem',
        }
      end

      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] + " '\"" +
                      "--db-nb-addr=0.0.0.0 --db-sb-addr=0.0.0.0" +
                      " --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=no" +
                      " --ovn-sb-db-ssl-key=/path/to/dbkey.pem --ovn-sb-db-ssl-cert=/path/to/dbcert.pem --ovn-sb-db-ssl-ca-cert=/path/to/dbcacert.pem" +
                      "\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'ptcp:6641:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^ptcp:6641:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'pssl:6642:0.0.0.0'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' pssl:6642:0.0.0.0$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with ipv6 and sb db ssl enabled' do
      let :params do
        {
          :dbs_listen_ip         => '::1',
          :ovn_sb_db_ssl_key     => '/path/to/dbkey.pem',
          :ovn_sb_db_ssl_cert    => '/path/to/dbcert.pem',
          :ovn_sb_db_ssl_ca_cert => '/path/to/dbcacert.pem',
        }
      end

      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-northd').with({
          :context => platform_params[:ovn_northd_context],
          :changes => "set " + platform_params[:ovn_northd_opts_envvar_name] + " '\"" +
                      "--db-nb-addr=[::1] --db-sb-addr=[::1]" +
                      " --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=no" +
                      " --ovn-sb-db-ssl-key=/path/to/dbkey.pem --ovn-sb-db-ssl-cert=/path/to/dbcert.pem --ovn-sb-db-ssl-ca-cert=/path/to/dbcacert.pem" +
                      "\"'",
        })
      end
      it 'configures db connections' do
        is_expected.to contain_exec('ovn-nb-set-connection').with({
          :command => ['ovn-nbctl', 'set-connection', 'ptcp:6641:[::1]'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-nbctl get-connection | egrep -e \'^ptcp:6641:\\[::1\\]$\'',
          :tag     => 'ovn-db-set-connections',
        })
        is_expected.to contain_exec('ovn-sb-set-connection').with({
          :command => ['ovn-sbctl', 'set-connection', 'pssl:6642:[::1]'],
          :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          :unless  => 'ovn-sbctl get-connection | egrep -e \' pssl:6642:\\[::1\\]$\'',
          :tag     => 'ovn-db-set-connections',
        })
      end
    end

    context 'with bad northd ssl parameters' do
      let :params do
        {
          :ovn_northd_ssl_key => '/path/to/key.pem',
        }
      end

      it { should raise_error(Puppet::Error, /The ovn_northd_ssl_key, cert and ca_cert are required to use SSL/) }
    end

    context 'with bad nb db ssl parameters' do
      let :params do
        {
          :ovn_nb_db_ssl_key => '/path/to/key.pem',
        }
      end

      it { should raise_error(Puppet::Error, /The ovn_nb_db_ssl_key, cert and ca_cert are required to use SSL/) }
    end

    context 'with bad sb db ssl parameters' do
      let :params do
        {
          :ovn_sb_db_ssl_key => '/path/to/key.pem',
        }
      end

      it { should raise_error(Puppet::Error, /The ovn_sb_db_ssl_key, cert and ca_cert are required to use SSL/) }
    end
  end

  shared_examples_for 'ovn northd' do
    context 'with defaults' do
      it 'starts northd' do
        is_expected.to contain_service('northd').with(
          :ensure => true,
          :name   => platform_params[:ovn_northd_service_name],
          :enable => true,
        )
      end

      it 'installs package' do
        is_expected.to contain_package('ovn-northd').with(
          :ensure => 'present',
          :name   => platform_params[:ovn_northd_package_name],
          :notify => 'Service[northd]'
        )
      end

      it 'should not manage inactivity probe' do
        is_expected.to_not contain_exec('ovn-nb-set-inactivity-probe')
        is_expected.to_not contain_exec('ovn-sb-set-inactivity-probe')
      end
    end

    context 'with nb db inactivity probe' do
      let :params do
        {
          :ovn_nb_db_inactivity_probe => 60000,
        }
      end

      it { is_expected.to contain_exec('ovn-nb-set-inactivity-probe').with(
        :command => ['ovn-nbctl', 'set', 'connection', '.', 'inactivity_probe=60000'],
        :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
        :unless  => 'test "$(sudo ovn-nbctl get connection . inactivity_probe)" = "60000"',
        :tag     => 'ovn-db-set-inactivity-probe',
      ) }
      it { is_expected.to_not contain_exec('ovn-sb-set-inactivity-probe') }
    end

    context 'with sb db inactivity probe' do
      let :params do
        {
          :ovn_sb_db_inactivity_probe => 60000,
        }
      end

      it { is_expected.to_not contain_exec('ovn-nb-set-inactivity-probe') }
      it { is_expected.to contain_exec('ovn-sb-set-inactivity-probe').with(
        :command => ['ovn-sbctl', 'set', 'connection', '.', 'inactivity_probe=60000'],
        :path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
        :unless  => 'test "$(sudo ovn-sbctl get connection . inactivity_probe)" = "60000"',
        :tag     => 'ovn-db-set-inactivity-probe',
      ) }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      case facts[:os]['family']
      when 'Debian'
        let(:platform_params) do
          {
            :ovn_northd_package_name     => 'ovn-central',
            :ovn_northd_service_name     => 'ovn-central',
            :ovn_northd_context          => '/files/etc/default/ovn-central',
            :ovn_northd_opts_envvar_name => 'OVN_CTL_OPTS'
          }
        end
        it_behaves_like 'ovn northd'
        it_behaves_like 'systemd env'
      when 'RedHat'
        let(:platform_params) do
          {
            :ovn_northd_package_name     => 'openvswitch-ovn-central',
            :ovn_northd_service_name     => 'ovn-northd',
            :ovn_northd_context          => '/files/etc/sysconfig/ovn-northd',
            :ovn_northd_opts_envvar_name => 'OVN_NORTHD_OPTS'
          }
        end
        it_behaves_like 'ovn northd'
        it_behaves_like 'systemd env'
      end
    end
  end
end
