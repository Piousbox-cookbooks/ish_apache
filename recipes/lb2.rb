include_recipe "ish::base_apache"

# definition of puts!
def puts! args
  puts '+++ +++'
  puts args.inspect
end

app = data_bag_item('apps', node[:apache2][:app_server_role])

app_nodes = search( :node, "role:#{node[:apache2][:app_server_role]}" )
app_node = app_nodes[0]

# puts! app_node

template "/etc/apache2/sites-available/#{app['id']}" do
  source "proxy_simple.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0664"
  
  variables(
            :server_name => app["domain"],
            :server_names => app["domains"],
            :cloud_ip => ( app_node.ipaddress ),
            :cloud_port => app["appserver_port"],
            :listen_port => app["lb_listen_port"] || '80'
            )
end

execute "enable site" do
  command %{ a2ensite #{app['id']} }
end

