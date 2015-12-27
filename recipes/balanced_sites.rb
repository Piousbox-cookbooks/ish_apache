
#
# Recipe ish_apache::balanced_sites
#
# Sends traffic between a load balancer and virtual sites via proxy.
#

include_recipe "ish_apache::install_apache"

def puts! args, label=""
  puts "+++ +++ #{label}"
  puts args.inspect
end

# config
sites = data_bag_item('load_balancers', 'balanced_sites')['balanced_sites']
sites = node['balanced_sites'] || sites

puts! sites, "sites are"

sites.each do |site|
  template "/etc/apache2/sites-available/#{site['name']}.conf" do
    source "etc/apache2/sites-available/balanced_site.conf.erb"
    owner site['user']
    group site['user']
    mode "0664"

    variables(
      :server_names => site['domains'],
      :cloud_ip => (site['app_ip'] || node.ipaddress),
      :cloud_port => site['port'],
      :listen_port => site['listen_port'] || "80"
    )
  end

  execute "enable site" do
    command %{ a2ensite #{site['name']}.conf }
  end
end

execute "restart apache2" do
  command %{ service apache2 reload }
end



