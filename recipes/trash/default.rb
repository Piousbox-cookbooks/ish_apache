
#
# recipe ish_apache::default
#
# @OBSOLETE!
# I don't even know what it does.
# _vp_ 20151226
#

def puts! args
  puts '+++ +++'
  puts args.inspect
end

app = data_bag_item( 'apps', node['apache2']['app_server_role'] )
puts! app

pool_members = search("node", "role:#{node['apache2']['app_server_role']} AND chef_environment:#{node.chef_environment}") || []

# load balancer may be in the pool
pool_members << node if node.run_list.roles.include?(node['apache2']['app_server_role'])

puts! pool_members

# we prefer connecting via local_ipv4 if 
# pool members are in the same cloud
# TODO refactor this logic into library...see COOK-494
pool_members.map! do |member|
  server_ip = begin
                if member.attribute?('cloud')
                  if node.attribute?('cloud') && (member['cloud']['provider'] == node['cloud']['provider'])
                    member['cloud']['local_ipv4']
                  else
                    member['cloud']['public_ipv4']
                  end
                else
                  member['ipaddress']
                end
              end
  { :ip_address => server_ip, :port => member['appserver_port'] }
end

puts! pool_members

template "/etc/apache2/sites-available/default" do
  source "sites-available/default.erb"
  owner 'root'
  group 'root'
  mode 0644
  variables(
            :server_name => app['domain'],
            :server_names => app['domains'],
            :virtual_sites => pool_members
            )
end

service "apache2" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
