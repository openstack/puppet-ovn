require 'spec_helper'

describe 'ovn::controller' do

  let :params do
    {
      :ovn_remote   => 'tcp:x.x.x.x:5000',
      :ovn_encap_ip => '1.2.3.4',
    }
  end

  shared_examples_for 'ovn controller' do
    it 'includes controller' do
      is_expected.to contain_class('ovn::controller')
    end

    it 'starts controller' do
      is_expected.to contain_service('controller').with(
        :ensure => true,
        :name   => platform_params[:ovn_controller_service_name],
        :enable => true,
        )
    end

    it 'installs controller package' do
      is_expected.to contain_package('ovn-controller').with(
        :ensure => 'present',
        :name   => platform_params[:ovn_controller_package_name],
        :notify => 'Service[controller]'
      )
    end

    it 'creates systemd conf' do
      is_expected.to contain_augeas('config-ovn-controller').with({
        :context => platform_params[:ovn_controller_context],
        :changes => "set " + platform_params[:ovn_controller_opts_envvar_name] + " '\"\"'",
      })
    end

    context 'with required parameters' do
      it 'configures ovsdb' do
        is_expected.to contain_vs_config('external_ids:ovn-remote').with(
          :value => params[:ovn_remote],
        )
        is_expected.to contain_vs_config('external_ids:ovn-encap-type').with(
          :value => 'geneve',
        )
        is_expected.to contain_vs_config('external_ids:ovn-encap-ip').with(
          :value => params[:ovn_encap_ip],
        )
        is_expected.to contain_vs_config('external_ids:hostname').with(
          :value => 'foo.example.com',
        )
        is_expected.to contain_vs_config('external_ids:ovn-bridge').with(
          :value => 'br-int',
        )
        is_expected.to contain_vs_config('external_ids:ovn-cms-options').with(
          :ensure => 'absent',
        )
        is_expected.to contain_vs_config('external_ids:ovn-encap-tos').with(
          :ensure => 'absent',
        )
        is_expected.to contain_vs_config('external_ids:ovn-remote-probe-interval').with(
          :value => 60000,
        )
        is_expected.to contain_vs_config('external_ids:ovn-openflow-probe-interval').with(
          :value => 60,
        )
        is_expected.to contain_vs_config('external_ids:ovn-monitor-all').with(
          :value => false,
        )
        is_expected.to contain_vs_config('external_ids:ovn-transport-zones').with(
          :ensure => 'absent'
        )
        is_expected.to contain_vs_config('external_ids:ovn-match-northd-version').with(
          :value => false,
        )
        is_expected.to contain_vs_config('external_ids:ovn-chassis-mac-mappings').with(
          :ensure => 'absent'
        )
        is_expected.to contain_vs_config('external_ids:ovn-ofctrl-wait-before-clear').with(
          :value => 8000
        )
      end

      it 'configures bridge mappings' do
        is_expected.to contain_vs_config('external_ids:ovn-bridge-mappings').with(
          :ensure  => 'absent'
        )
      end
    end

    context 'with parameters' do
      before do
        params.merge!({
          :ovn_encap_type              => 'vxlan',
          :ovn_encap_tos               => 0,
          :ovn_bridge_mappings         => ['physnet-1:br-1'],
          :ovn_bridge                  => 'br-custom',
          :bridge_interface_mappings   => ['br-1:eth1'],
          :hostname                    => 'server1.example.com',
          :ovn_cms_options             => ['cms_option1', 'cms_option2:foo'],
          :ovn_remote_probe_interval   => 30000,
          :ovn_openflow_probe_interval => 8,
          :ovn_monitor_all             => true,
          :ovn_transport_zones         => ['tz1'],
          :enable_ovn_match_northd     => false,
          :ovn_chassis_mac_map         => ['physnet1:aa:bb:cc:dd:ee:ff',
                                           'physnet2:bb:aa:cc:dd:ee:ff'],
          :ovn_ofctrl_wait_before_clear => 9000
        })
      end

      it 'configures ovsdb' do
        is_expected.to contain_vs_config('external_ids:ovn-remote').with(
          :value => params[:ovn_remote],
        )
        is_expected.to contain_vs_config('external_ids:ovn-encap-type').with(
          :value => params[:ovn_encap_type],
        )
        is_expected.to contain_vs_config('external_ids:ovn-encap-ip').with(
          :value => params[:ovn_encap_ip],
        )
        is_expected.to contain_vs_config('external_ids:hostname').with(
          :value => 'server1.example.com',
        )
        is_expected.to contain_vs_config('external_ids:ovn-bridge').with(
          :value => params[:ovn_bridge],
        )
        is_expected.to contain_vs_config('external_ids:ovn-cms-options').with(
          :value => 'cms_option1,cms_option2:foo',
        )
        is_expected.to contain_vs_config('external_ids:ovn-encap-tos').with(
          :value => 0,
        )
        is_expected.to contain_vs_config('external_ids:ovn-remote-probe-interval').with(
          :value => params[:ovn_remote_probe_interval],
        )
        is_expected.to contain_vs_config('external_ids:ovn-openflow-probe-interval').with(
          :value => params[:ovn_openflow_probe_interval],
        )
        is_expected.to contain_vs_config('external_ids:ovn-monitor-all').with(
          :value => params[:ovn_monitor_all],
        )
        is_expected.to contain_vs_config('external_ids:ovn-transport-zones').with(
          :value => params[:ovn_transport_zones],
        )
        is_expected.to contain_vs_config('external_ids:ovn-match-northd-version').with(
          :value => params[:enable_ovn_match_northd],
        )
        is_expected.to contain_vs_config('external_ids:ovn-chassis-mac-mappings').with(
          :value => 'physnet1:aa:bb:cc:dd:ee:ff,physnet2:bb:aa:cc:dd:ee:ff',
        )
        is_expected.to contain_vs_config('external_ids:ovn-ofctrl-wait-before-clear').with(
          :value => params[:ovn_ofctrl_wait_before_clear],
        )
      end

      it 'configures bridge mappings' do
        is_expected.to contain_vs_config('external_ids:ovn-bridge-mappings').with(
          :value => 'physnet-1:br-1',
        )

        params[:ovn_bridge_mappings].each do |mapping|
          is_expected.to contain_ovn__controller__bridge(mapping).with(
            :before  => 'Service[controller]',
            :require => 'Service[openvswitch]'
          )
        end

        params[:bridge_interface_mappings].each do |mapping|
          is_expected.to contain_ovn__controller__port(mapping).with(
            :before  => 'Service[controller]',
            :require => 'Service[openvswitch]'
          )
        end
      end
    end

    context 'when ovn_chassis_mac_map is a hash' do
      before :each do
        params.merge!({
          :ovn_chassis_mac_map => {
            'physnet1' => 'aa:bb:cc:dd:ee:ff',
            'physnet2' => 'bb:aa:cc:dd:ee:ff' }
        })
      end

      it 'configures ovsdb' do
        is_expected.to contain_vs_config('external_ids:ovn-chassis-mac-mappings').with(
          :value    => 'physnet1:aa:bb:cc:dd:ee:ff,physnet2:bb:aa:cc:dd:ee:ff',
        )
      end
    end

    context 'when setting mac_table_size' do
      before :each do
        params.merge!({
          :ovn_bridge_mappings => ['physnet-1:br-1'],
          :mac_table_size      => 20000
        })
      end

      it 'configures mac_table_size' do
        params[:ovn_bridge_mappings].each do |mapping|
          is_expected.to contain_ovn__controller__bridge(mapping).with(
            :mac_table_size => 20000,
            :before         => 'Service[controller]',
            :require        => 'Service[openvswitch]'
          )
        end
      end
    end

    context 'when manage_ovs_bridge is false' do
      before :each do
        params.merge!({
          :ovn_bridge_mappings       => ['physnet-1:br-1'],
          :bridge_interface_mappings => ['br-1:eth1'],
          :manage_ovs_bridge         => false,
        })
      end

      it 'does not manage ovs bridge' do
        params[:ovn_bridge_mappings].each do |mapping|
          is_expected.to_not contain_ovn__controller__bridge(mapping)
        end
        params[:bridge_interface_mappings].each do |mapping|
          is_expected.to_not contain_ovn__controller__port(mapping)
        end
      end
    end

    context 'with ovn controller ssl' do
      before :each do
        params.merge!({
          :ovn_controller_ssl_key     => '/path/to/key.pem',
          :ovn_controller_ssl_cert    => '/path/to/cert.pem',
          :ovn_controller_ssl_ca_cert => '/path/to/cacert.pem',
        })
      end

      it 'creates systemd conf' do
        is_expected.to contain_augeas('config-ovn-controller').with({
          :context => platform_params[:ovn_controller_context],
          :changes => "set " + platform_params[:ovn_controller_opts_envvar_name] + " '\"" +
                      "--ovn-controller-ssl-key=/path/to/key.pem --ovn-controller-ssl-cert=/path/to/cert.pem --ovn-controller-ssl-ca-cert=/path/to/cacert.pem" +
                      "\"'",
        })
      end
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
        let :platform_params do
          {
            :ovn_controller_package_name     => 'ovn-host',
            :ovn_controller_service_name     => 'ovn-host',
            :ovn_controller_context          => '/files/etc/default/ovn-host',
            :ovn_controller_opts_envvar_name => 'OVN_CTL_OPTS'
          }
        end
        it_behaves_like 'ovn controller'
      when 'RedHat'
        let :platform_params do
          {
            :ovn_controller_package_name     => 'openvswitch-ovn-host',
            :ovn_controller_service_name     => 'ovn-controller',
            :ovn_controller_context          => '/files/etc/sysconfig/ovn-controller',
            :ovn_controller_opts_envvar_name => 'OVN_CONTROLLER_OPTS'
          }
        end
        it_behaves_like 'ovn controller'
      end
    end
  end
end
