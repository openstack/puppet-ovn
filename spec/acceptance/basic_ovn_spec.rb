require 'spec_helper_acceptance'

describe 'basic ovn deployment' do

  context 'default parameters' do
    pp= <<-EOS
    include openstack_integration
    include openstack_integration::repos

    include ovn::northd
    class { 'ovn::controller':
      ovn_remote   => 'tcp:127.0.0.1:6642',
      ovn_encap_ip => '127.0.0.1',
    }
    EOS

    it 'should work with no errors' do
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe 'test openvswitch-ovn CLI' do
      it 'list virtual ports' do
        expect(shell('ovn-nbctl show').exit_code).to be_zero
      end
    end
  end

end
