
# Compile
bash "compile proxy_coordinator" do
  user "root"
  cwd "/mnt/raknet/Source"

  code <<-EOS
  mkdir -p ../bin
    g++ -o ../Source/proxy_coordinator.out -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/UDPProxyCoordinator/main.cpp *.cpp
  EOS
end
