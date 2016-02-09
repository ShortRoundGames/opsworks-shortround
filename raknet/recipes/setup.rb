
bash "setup proxy server" do
  user "root"
  cwd "/"

  code <<-EOS
    mkdir -p /mnt/raknet
	mkdir -p /mnt/raknet/bin
	mkdir -p /mnt/raknet/logs
  EOS
end

