
#
# cookbook   ish_apache
# recipe     install_apache
#
# _vp_ 20151227
#

include_recipe "apache2::default"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_rewrite"



