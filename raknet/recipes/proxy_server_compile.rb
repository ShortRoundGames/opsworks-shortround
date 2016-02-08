
# Compile
bash "compile proxy_server" do
  user "root"
  cwd "/mnt/raknet/Source"

  code <<-EOS
    g++ -o ../bin/proxy_server.out -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/UDPProxyServer/main.cpp *.cpp
  EOS
end
