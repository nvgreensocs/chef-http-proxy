

bash "Set HTTP_PROXY " do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH

  cd /vagrant/
  cp .http_proxy /etc/bash.bashrc.http_proxy
  echo "source /etc/bash.bashrc.http_proxy" >> /etc/bash.bashrc
  EOH
  creates "/etc/bash.bashrc.http_proxy"
end


