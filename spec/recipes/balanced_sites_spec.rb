
require 'spec_helper'

describe 'balanced_sites recipe' do

  before :all do
    # obtain config
    @c = JSON.parse File.read "spec/spec_config.json"
    puts! @c, "Config"
    
    @prefix = "/home/piousbox/projects/rails-quick-start"
    @sudo = "echo #{@c['password']} | sudo -S "

    # what's the run list of this node?
    `knife node run_list set #{@c['node_name']} "role[balanced_sites_spec]"`
    
    @data_bag = JSON.parse File.read "#{@prefix}/data_bags/load_balancers/balanced_sites.json"

    out = `knife search node "name:#{@c['node_name']}"`

    # Only one node should be found
    result = out.match( "1 items found" )
    result = !!result
    puts( "Not exactly 1 node found:", out ) if !result
    result.should eql true

    # The run list of this node should be exactly role[balanced_sites_spec]
    result = out.match( "Run List:\s*role\\[balanced_sites_spec\\]" )
    result = !!result
    puts( "Run list mismatch:", out ) if !result
    result.should eql true
    
  end
  
  it 'creates a new site' do
    # ssh into target
    Net::SSH.start @c['ip_addr'], @c['user'], :password => @c['password'] do |ssh|
      # remove possible sites
      @data_bag['balanced_sites'].each do |balanced_site|
        out = ssh.exec! "#{@sudo} rm -rfv /etc/apache2/sites-available/#{balanced_site['name']}.conf"
      end
      
      # configure apache
      ` #{@sudo} a2enmod proxy `
      ` #{@sudo} a2enmod proxy_http `
      ` #{@sudo} a2enmod proxy_balancer `
      ` #{@sudo} service apache2 restart `
      ` #{@sudo} service apache2 reload `
      ` #{@sudo} service apache2 restart `
    end

    # run recipe
    out = `sshpass -p '#{@c['password']}' ssh #{@c['user']}@#{@c['node_ip']} "echo #{@c['password']} | sudo -S chef-client && echo $?"`
    puts( "Output of recipe run", out ) if out.lines.last != "0\n"
    out.lines.last.should eql "0\n"

    # asserts
    Net::SSH.start @c['ip_addr'], @c['user'], :password => @c['password'] do |ssh|
      # for all sites
      @data_bag['balanced_sites'].each do |balanced_site|
        # All the domains should be wired
        balanced_site['domains'].each do |domain|
          out = ssh.exec! "cat /etc/apache2/sites-available/#{balanced_site['name']}.conf | grep #{domain} && echo $?"
          out.lines.last.should eql "0\n"
        end
      end
    end
    
  end

  it 'sanity' do
    true.should eql true
  end

end

