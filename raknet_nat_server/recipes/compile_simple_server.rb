
# Compile
bash "compile simple_server" do
  user "root"
  cwd "/mnt/raknet/Source"

  code <<-EOS
    g++ -pthread -I./ -I../Samples/CloudServer ../Samples/CloudServer/CloudServerHelper.cpp ../Samples/NATSimpleServer/main.cpp *.cpp
  EOS
end
