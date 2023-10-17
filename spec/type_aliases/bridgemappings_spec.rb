require 'spec_helper'

describe 'Ovn::BridgeMappings' do
  describe 'valid types' do
    context 'with valid types' do
      [
        '',
        'datacentre:br-ex',
        [],
        ['datacentre:br-ex'],
        {},
        {'datacentre' => 'br-ex'}
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        true,
        false,
        1,
        [''],
        {'' => 'br-ex'},
        {'datacentre' => ''}
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end

