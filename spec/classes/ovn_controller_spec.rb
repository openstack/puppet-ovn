require 'spec_helper'

describe 'ovn::controller' do

  let :params do
    { :ovn_remote                => 'tcp:x.x.x.x:5000',
      :ovn_encap_type            => 'geneve',
      :ovn_encap_ip              => '1.2.3.4',
      :ovn_bridge_mappings       => ['physnet-1:br-1'],
      :ovn_bridge                => 'br-int',
      :bridge_interface_mappings => ['br-1:eth1'],
      :hostname                  => 'server1.example.com',
      :enable_hw_offload         => false,
      :mac_table_size            => 20000
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
      when 'Redhat'
        let :platform_params do
          {
            :ovn_controller_package_name    => 'openvswitch-ovn-host',
            :ovn_controller_service_name    => 'ovn-controller',
            :ovn_controller_service_status  => true,
            :ovn_controller_service_pattern => 'undef'
          }
        end
        it_behaves_like 'ovn controller'
      end
    end
  end
end
