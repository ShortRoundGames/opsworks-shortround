
# Compile
bash "compile proxy_coordinator" do
  user "root"
  cwd "/mnt/raknet/source/Source"

  code <<-EOS
    mkdir -p /mnt/raknet/bin
    g++ -o /mnt/raknet/bin/proxy_coordinator.out -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/UDPProxyCoordinator/main.cpp *.cpp
  EOS
end
