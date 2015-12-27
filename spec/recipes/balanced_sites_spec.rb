
require 'spec_helper'

describe 'ish_apache::balanced_sites' do
  before :all do
    stubbed_default_balanced_site = {
      :id => 'default_balanced_site',
      :port => 80
    }
    stubbed_balanced_sites = []
    # stub_data_bag_item("load_balancers", "default_balanced_site").and_return(stubbed_default_balanced_site)
    stub_data_bag_item("load_balancers", "balanced_sites").and_return(stubbed_balanced_sites)
    stub_command("/usr/sbin/apache2 -t").and_return(true)
  end
  
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.default['balanced_site'] = {
        'name'          => 'some_name',
        'user'          => ENV['USER'],
        'domains'       => [],
        'listen_port'   => 80
      }
    end.converge(described_recipe)
  end

  it 'installs packages' do
    %w{ apache2 }.each do |pkg|
      expect(chef_run).to install_package(pkg)
    end
  end

  
end
