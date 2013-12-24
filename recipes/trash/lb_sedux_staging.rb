include_recipe "ish::base_apache"

# definition of puts!
def puts! args
  puts '+++ +++'
  puts args.inspect
end

app = data_bag_item('apps', node[:apache2][:app_server_role])

puts! app

template "/etc/apache2/sites-available/#{app['id']}" do
  source "site_simple.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0664"
  
  variables(
            :server_name => app["domain"],
            :server_names => app["domains"] || [],
            :cloud_ip => (app['app_ip_address'] || node.ipaddress),
            :cloud_port => app["appserver_port"],
            :listen_port => app["lb_listen_port"]
            )
end

execute "enable site" do
  command %{ a2ensite #{app['id']} }
end

