
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
  echo "export http_proxy=\'#{Chef::Config[:http_proxy]}\'" > /etc/bash.bashrc.http_proxy
  echo "Acquire::http::Proxy \'#{Chef::Config[:http_proxy]}\';" > /etc/apt/apt.conf.d/30proxy
  EOH
end

#only do this once.
base "Set sudoers and bashrc" do
  code <<-EOH
    echo "source /etc/bash.bashrc.http_proxy" >> /etc/bash.bashrc
    echo 'Defaults env_keep = "http_proxy https_proxy ftp_proxy"' >> /etc/sudoers
    touch /etc/http_proxy_setup
  EOH
  creates "/etc/http_proxy_setup"
end
