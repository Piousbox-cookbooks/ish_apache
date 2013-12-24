
include_recipe "ish::base_apache"

app = data_bag_item('apps', node[:apache2][:app_server_role])

template "/etc/apache2/sites-available/#{app['id']}" do
  source "site_simple.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0664"
  
  variables(
            :server_name => app["domain"],
            :server_names => app["domains"] || [],
            :cloud_ip => (app['ip_address'] || node.ipaddress),
            :cloud_port => app["port"],
            :listen_port => app["listen_port"] || '80'
            )
end

execute "enable site" do
  command %{ a2ensite #{app['id']} }
end

