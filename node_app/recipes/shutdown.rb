# Just stop the bluepill process
bash "stop bluepill" do
  user "root"
  cwd "/tmp"
  code <<-EOS
    /opt/chef/embedded/bin/bluepill stop node1
  EOS
end


log "That's all folks!"
