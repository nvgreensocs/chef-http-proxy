
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


bash "mkdir bash.profile.d" do
  code <<-EOH
    mkdir -p "#{node[:prefix]}/bash.profile.d"
    touch "#{node[:prefix]}/bash.profile.d/empty"
    echo 'for i in #{node[:prefix]}/bash.profile.d/*; do . $i; done' > /etc/profile.d/platform.bash.env.sh
  EOH
end


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
  echo 'export http_proxy="#{Chef::Config[:http_proxy]}"' > "#{node[:prefix]}/bash.profile.d/http_proxy.profile"
  echo 'export http_proxy="#{Chef::Config[:http_proxy]}"' > /etc/profile.d/http_proxy.sh
  echo 'Acquire::http::Proxy "#{Chef::Config[:http_proxy]}";' > /etc/apt/apt.conf.d/30proxy
  EOH
end


# these are only helpful for the VM setup, dont put them in the platform bash profile....
bash "Add LC_LANG" do
    code <<-EOH
       echo 'export LANG="en"' > /etc/profile.d/lc_lang.sh
       echo 'export LC_MESSAGES="C"' >> /etc/profile.d/lc_lang.sh
  EOH
end


# only do this once.
bash "Set sudoers and bashrc" do
  code <<-EOH
    echo 'Defaults env_keep = "http_proxy https_proxy ftp_proxy"' >> /etc/sudoers
    touch /etc/http_proxy_setup
  EOH
  creates "/etc/http_proxy_setup"
end

bash "Set sudoers and bashrc" do
  if Chef::Config[:http_proxy]
    http_raw = Chef::Config[:http_proxy]
    http_raw.slice!("http://")
    http_host = http_raw.split(":").first
    http_port = http_raw.split(":").last
    code <<-EOH
       mkdir -p /usr/local/bin
       cat  > /usr/local/bin/gitproxy <<_EOF
#!/bin/sh
exec /usr/bin/corkscrew #{http_host} #{http_port} \\$\*
_EOF
      chmod +x /usr/local/bin/gitproxy;

      echo 'export GIT_PROXY_COMMAND=/usr/local/bin/gitproxy' > /etc/profile.d/git_proxy.sh
      echo 'export GIT_PROXY_COMMAND=/usr/local/bin/gitproxy' > "#{node[:prefix]}/bash.profile.d/git_proxy.profile"

    EOH
    creates "/usr/local/bin/gitproxy"
  end
end
