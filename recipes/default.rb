
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


bash "Add LC_LANG" do
    code <<-EOH
       grep -v 'export LANG="en"' /etc/profile > /tmp/tmp.profile.$$
       echo 'export LANG="en"' >> /tmp/tmp.profile.$$
       mv -f /tmp/tmp.profile.$$ /etc/profile
  EOH
end
bash "Add LC_MESSAGE" do
    code <<-EOH
       grep -v 'export LC_MESSAGES="C"' /etc/profile > /tmp/tmp.profile.$$
       echo 'export LC_MESSAGES="C"' >> /tmp/tmp.profile.$$
       mv -f /tmp/tmp.profile.$$ /etc/profile
  EOH
end

bash "Add http proxy to profile" do
    code <<-EOH
       grep -v "source /etc/bash.bashrc.http_proxy" /etc/profile > /tmp/tmp.profile.$$
       echo "source /etc/bash.bashrc.http_proxy" >> /tmp/tmp.profile.$$
       mv -f /tmp/tmp.profile.$$ /etc/profile
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
    EOH

    grep -v 'export http_proxy' /etc/profile > /tmp/tmp.profile.$$
    echo 'export http_proxy=#{Chef::Config[:http_proxy]}' >> /tmp/tmp.profile.$$
    mv -f /tmp/tmp.profile.$$ /etc/profile    

    grep -v 'GIT_PROXY_COMMAND'
    grep -v 'export GIT_PROXY_COMMAND' /etc/profile > /tmp/tmp.profile.$$
    echo 'export GIT_PROXY_COMMAND=/usr/local/bin/gitproxy' >> /tmp/tmp.profile.$$
    mv -f /tmp/tmp.profile.$$ /etc/profile    

    creates "/usr/local/bin/gitproxy"
  end
end
