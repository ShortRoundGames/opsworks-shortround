# This recipe will deploy a Coordinator with a single Proxy server running on the same instance

# Compile the Coordinator
bash "compile proxy_coordinator" do
  user "root"
  cwd "/mnt/raknet/source/Source"

  code <<-EOS
    mkdir -p /mnt/raknet/bin
    g++ -o /mnt/raknet/bin/proxy_coordinator.out -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/UDPProxyCoordinator/main.cpp *.cpp
  EOS
end

# Compile the Proxy server
bash "compile proxy_server" do
  user "root"
  cwd "/mnt/raknet/source/Source"

  code <<-EOS
    mkdir -p /mnt/raknet/bin
    g++ -o /mnt/raknet/bin/proxy_server.out -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/UDPProxyServer/main.cpp *.cpp
  EOS
end

# Create bluepill 'pill' file for running Coordinator and Proxy server
template "/mnt/raknet/bin/proxy_coord_server_pair.pill" do
    source 'proxy_coord_server_pair.pill.erb'
    owner 'root'
    group 'root'
    mode '0700'
end

# TODO: we should run a service that keeps us registered as an active Coordinator (via Redis or something)
