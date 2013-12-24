
include_recipe "ish::base_apache"

app = data_bag_item('apps', 'sedux_staging')

template "/etc/apache2/sites-available/#{app['id']}" do
  source "site_static.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0664"
  
  variables(
            :server_name => app["domain"],
            :server_names => app["domains"] || [],
            :cloud_ip => (app['ip_address'] || node.ipaddress),
            :cloud_port => app["appserver_port"],
            :listen_port => app["listen_port"] || '80',
            :document_root => "#{app['deploy_to']}/current/public"
            )
end

execute "enable site" do
  command %{ a2ensite #{app['id']} }
end

