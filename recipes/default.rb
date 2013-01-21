
#  -------    CHEF-HTTP_PROXY --------

# LICENSETEXT
# 
#   Copyright (C) 2012 : GreenSocs Ltd
#       http://www.greensocs.com/ , email: info@greensocs.com
# 
# The contents of this file are subject to the licensing terms specified
# in the file LICENSE. Please consult this file for restrictions and
# limitations that may apply.
# 
# ENDLICENSETEXT


ENV['http_proxy'] = Chef::Config[:http_proxy]

ruby_block "HTTP Proxy Report" do
  block do
     if Chef::Config[:http_proxy]
       Chef::Log.info("Your HTTY Proxy seems to be working, and is set to "+Chef::Config[:http_proxy])
    else
       Chef::Log.info("You seem to have a good connection to the internet with no proxy")
    end
  end
end

# We will always run these, just in case the user changes their proxy, it's not exactly long to do.
bash "Set HTTP_PROXY " do
  code <<-EOH
  echo 'export http_proxy="#{Chef::Config[:http_proxy]}"' > /etc/bash.bashrc.http_proxy
  echo 'Acquire::http::Proxy "#{Chef::Config[:http_proxy]}";' > /etc/apt/apt.conf.d/30proxy
  EOH
end


bash "Add LC_MESSAGE" do
    code <<-EOH
       grep -v 'export LC_MESSAGE="C"' /home/vagrant/.profile > /tmp/tmp.profile.$$
       echo 'export LC_MESSAGE="C"' >> /tmp/tmp.profile.$$
       mv -f /tmp/tmp.profile.$$ /home/vagrant/.profile
  EOH
end

#only do this once.
bash "Set sudoers and bashrc" do
  code <<-EOH
    echo "source /etc/bash.bashrc.http_proxy" >> /etc/bash.bashrc
    echo 'Defaults env_keep = "http_proxy https_proxy ftp_proxy"' >> /etc/sudoers
    touch /etc/http_proxy_setup
  EOH
  creates "/etc/http_proxy_setup"
end
