require 'spec_helper'

describe 'ovn::controller' do

  let :params do
    { :ovn_remote                  => 'tcp:x.x.x.x:5000',
      :ovn_encap_type              => 'geneve',
      :ovn_encap_ip                => '1.2.3.4',
      :ovn_encap_tos               => 0,
      :ovn_bridge_mappings         => ['physnet-1:br-1'],
      :ovn_bridge                  => 'br-int',
      :bridge_interface_mappings   => ['br-1:eth1'],
      :hostname                    => 'server1.example.com',
      :ovn_cms_options             => ['cms_option1', 'cms_option2:foo'],
      :ovn_remote_probe_interval   => 30000,
      :ovn_openflow_probe_interval => 8,
      :ovn_monitor_all             => true,
      :ovn_transport_zones         => ['tz1'],
      :enable_ovn_match_northd     => false,
      :ovn_chassis_mac_map         => ['physnet1:aa:bb:cc:dd:ee:ff',
                                       'physnet2:bb:aa:cc:dd:ee:ff']
    }
  end

  shared_examples_for 'ovn controller' do
    it 'includes params' do
      is_expected.to contain_class('ovn::params')
    end

    it 'includes controller' do
      is_expected.to contain_class('ovn::controller')
    end

    it 'starts controller' do
      is_expected.to contain_service('controller').with(
        :ensure    => true,
        :name      => platform_params[:ovn_controller_service_name],
        :enable    => true,
        :hasstatus => platform_params[:ovn_controller_service_status],
        :pattern   => platform_params[:ovn_controller_service_pattern],
        )
    end

    it 'installs controller package' do
      is_expected.to contain_package(platform_params[:ovn_controller_package_name]).with(
        :ensure => 'present',
        :name   => platform_params[:ovn_controller_package_name],
        :before => 'Service[controller]'
      )
    end

    it 'configures ovsdb' do
      is_expected.to contain_vs_config('external_ids:ovn-remote').with(
        :value   => params[:ovn_remote],
      )

      is_expected.to contain_vs_config('external_ids:ovn-encap-type').with(
        :value   => params[:ovn_encap_type],
      )

      is_expected.to contain_vs_config('external_ids:ovn-encap-ip').with(
        :value   => params[:ovn_encap_ip],
      )

      is_expected.to contain_vs_config('external_ids:hostname').with(
        :value   => 'server1.example.com',
      )

      is_expected.to contain_vs_config('external_ids:ovn-bridge').with(
        :value   => params[:ovn_bridge],
      )

      is_expected.to contain_vs_config('external_ids:ovn-cms-options').with(
        :value   => 'cms_option1,cms_option2:foo',
      )

      is_expected.to contain_vs_config('external_ids:ovn-encap-tos').with(
        :value   => 0,
      )

      is_expected.to contain_vs_config('external_ids:ovn-remote-probe-interval').with(
        :value   => params[:ovn_remote_probe_interval],
      )

      is_expected.to contain_vs_config('external_ids:ovn-openflow-probe-interval').with(
        :value   => params[:ovn_openflow_probe_interval],
      )

      is_expected.to contain_vs_config('external_ids:ovn-monitor-all').with(
        :value   => params[:ovn_monitor_all],
      )

      is_expected.to contain_vs_config('external_ids:ovn-transport-zones').with(
        :value   => params[:ovn_transport_zones],
      )

      is_expected.to contain_vs_config('external_ids:ovn-match-northd-version').with(
        :value   => params[:enable_ovn_match_northd],
      )
      is_expected.to contain_vs_config('external_ids:ovn-chassis-mac-mappings').with(
        :value    => 'physnet1:aa:bb:cc:dd:ee:ff,physnet2:bb:aa:cc:dd:ee:ff',
      )
      is_expected.to contain_vs_config('external_ids:ovn-ofctrl-wait-before-clear').with(
        :value    => "8000"
      )
    end

    it 'configures bridge mappings' do
      is_expected.to contain_vs_config('external_ids:ovn-bridge-mappings').with(
        :value    => 'physnet-1:br-1',
      )

      is_expected.to contain_ovn__controller__bridge(params[:ovn_bridge_mappings].join(',')).with(
        :before  => 'Service[controller]',
        :require => 'Service[openvswitch]'
      )

      is_expected.to contain_ovn__controller__port(params[:bridge_interface_mappings].join(',')).with(
        :before  => 'Service[controller]',
        :require => 'Service[openvswitch]'
      )
    end

    it 'clears mac_table_size' do
      is_expected.to contain_exec('br-1').with(
        :command => 'ovs-vsctl --timeout=5 remove Bridge br-1 other-config mac-table-size',
        :path    => '/usr/sbin:/usr/bin:/sbin:/bin',
        :onlyif  => [ 'ovs-vsctl br-exists br-1', 'ovs-vsctl get bridge br-1 other-config:mac-table-size'],
        :require => [ 'Service[openvswitch]', 'Vs_bridge[br-1]' ],
      )
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
          :mac_table_size => 20000
        })
      end

      it 'configures mac_table_size' do
        is_expected.to contain_exec('br-1').with(
          :command => 'ovs-vsctl --timeout=5 set Bridge br-1 other-config:mac-table-size=20000',
          :unless  => 'ovs-vsctl get bridge br-1 other-config:mac-table-size | grep -q -w 20000',
          :path    => '/usr/sbin:/usr/bin:/sbin:/bin',
          :onlyif  => [ 'ovs-vsctl br-exists br-1' ],
          :require => [ 'Service[openvswitch]', 'Vs_bridge[br-1]' ],
        )
      end
    end

    context 'when manage_ovs_bridge is false' do
      before :each do
        params.merge!({
          :manage_ovs_bridge => false,
        })
      end

      it 'does not manage ovs bridge' do
        is_expected.to_not contain_ovn__controller__bridge(params[:ovn_bridge_mappings].join(','))
        is_expected.to_not contain_ovn__controller__port(params[:bridge_interface_mappings].join(','))
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
        }))
      end

      case facts[:osfamily]
      when 'Debian'
        let :platform_params do
          {
            :ovn_controller_package_name    => 'ovn-host',
            :ovn_controller_service_name    => 'ovn-host',
            :ovn_controller_service_status  => false,
            :ovn_controller_service_pattern => 'ovn-controller'
          }
        end
        it_behaves_like 'ovn controller'
      when 'RedHat'
        let :platform_params do
          {
            :ovn_controller_package_name    => 'openvswitch-ovn-host',
            :ovn_controller_service_name    => 'ovn-controller',
            :ovn_controller_service_status  => true,
            :ovn_controller_service_pattern => nil
          }
        end
        it_behaves_like 'ovn controller'
      end
    end
  end
end
