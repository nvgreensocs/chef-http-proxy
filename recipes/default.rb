

bash "Set HTTP_PROXY " do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH


  cd /vagrant/
  echo "export http_proxy=\'#{Chef::Config[:http_proxy]}\'" > /etc/bash.bashrc.http_proxy
  echo "source /etc/bash.bashrc.http_proxy" >> /etc/bash.bashrc
  echo 'Defaults env_keep = "http_proxy https_proxy ftp_proxy"' >> /etc/sudoers
  echo "Acquire::http::Proxy \"#{Chef::Config[:http_proxy]}\";" > /etc/apt/apt.conf.d/30proxy

  
  environment { 'http_proxy' => Chef::Config[:http_proxy] }


  EOH
  creates "/etc/bash.bashrc.http_proxy"
end


