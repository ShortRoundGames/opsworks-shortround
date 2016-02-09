
# Compile
bash "compile proxy_server" do
  user "root"
  cwd "/mnt/raknet/source/Source"

  code <<-EOS
    mkdir -p /mnt/raknet/bin
    g++ -o /mnt/raknet/bin/proxy_server.out -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/UDPProxyServer/main.cpp *.cpp
  EOS
end
