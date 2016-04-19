require 'spec_helper_acceptance'

describe 'basic ovn deployment' do

  context 'default parameters' do
    pp= <<-EOS
    include ::openstack_integration
    include ::openstack_integration::repos

    # TODO: use rdo-ovn repository once available
    if $::osfamily == 'RedHat' {
      yumrepo { 'dpdk-snapshot':
        enabled    => '1',
        baseurl    => 'https://copr-be.cloud.fedoraproject.org/results/pmatilai/dpdk-snapshot/epel-7-x86_64/',
        descr      => 'Repository for dpdk-snapshot',
        mirrorlist => 'absent',
        gpgcheck   => '1',
        gpgkey     => 'https://copr-be.cloud.fedoraproject.org/results/pmatilai/dpdk-snapshot/pubkey.gpg',
        notify     => Exec[yum_refresh],
      }
      # TODO: see if packaging is available in Ubuntu Trusty
      # otherwise, add conditional to test only on Red Hat.
      include ::ovn::northd
      class { '::ovn::controller':
        ovn_remote   => '127.0.0.1',
        ovn_encap_ip => '127.0.0.1',
      }
    }
    EOS

    it 'should work with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe 'test openvswitch-ovn-host' do
        it 'should start northd process' do
          expect(shell('/usr/share/openvswitch/scripts/ovn-ctl start_northd').exit_code).to be_zero
        end
      end
      describe 'test openvswitch-ovn-central' do
        it 'should start controller process' do
          expect(shell('/usr/share/openvswitch/scripts/ovn-ctl start_controller').exit_code).to be_zero
        end
      end
    end
  end
end
