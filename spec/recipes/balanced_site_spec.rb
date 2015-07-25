
require 'spec_helper'

describe 'balanced_site recipe' do

  before :all do
    # obtain config
    @c = JSON.parse File.read "spec/spec_config.json"
    puts! @c, "Config"
    
    @prefix = "/home/piousbox/projects/rails-quick-start"
    @sudo = "echo #{@c['password']} | sudo -S "

    # what's the run list of this node?
    `knife node run_list set #{@c['node_name']} "role[balanced_site]"`
    
    @data_bag = JSON.parse File.read "#{@prefix}/data_bags/load_balancers/balanced_site.json"
    @site_name = @data_bag['balanced_site']['name']

    # @TODO: check that node exists, bootstrapped
    out = `knife search node "name:#{@c['node_name']}"`
    # puts "+++ +++ knife search", out

    # Only one node should be found
    result = out.match( "1 items found" )
    result = !!result
    result.should eql true

    # The run list of this node should be exactly role[balanced_site], same name as the recipe
    result = out.match( "Run List:\s*role\\[balanced_site\\]" )
    # puts! result
    result = !!result
    result.should eql true
    
  end
  
  it 'creates a new site' do
    # ssh into target
    Net::SSH.start @c['ip_addr'], @c['user'], :password => @c['password'] do |ssh|
      # remove possible site
      out = ssh.exec! "#{@sudo} rm -rfv /etc/apache2/sites-available/#{@site_name}.conf"

      # configure apache
      ` #{@sudo} a2enmod proxy `
      ` #{@sudo} service apache2 restart `
    end

    # run recipe
    out = `sshpass -p '#{@c['password']}' ssh #{@c['user']}@#{@c['node_ip']} "echo #{@c['password']} | sudo -S chef-client && echo $?"`
    puts("Output of recipe run", out) if out.lines.last != "0\n"
    out.lines.last.should eql "0\n"

    # asserts
    Net::SSH.start @c['ip_addr'], @c['user'], :password => @c['password'] do |ssh|
      # All the domains should be wired
      @data_bag['balanced_site']['domains'].each do |domain|
        out = ssh.exec! "cat /etc/apache2/sites-available/#{@site_name}.conf | grep #{domain} && echo $?"
        out.lines.last.should eql "0\n"
      end
    end
    
  end

  it 'sanity' do
    true.should eql true
  end

end

