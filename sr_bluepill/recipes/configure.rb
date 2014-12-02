# Find the attributes for this layer
attribs = "";
if (node[:opsworks])
  node["opsworks"]["instance"]["layers"].each do |layerName|
    if (node[:app][layerName])
      attribs = node[:bluepill][layerName]
	end
  end
end

# Switch pill name based on the instance's layer
pill_path = attribs[:pill_path];
process_name = attribs[:process_name];

# Determine if server is running
status_command = "bluepill status"
shell = Mixlib::ShellOut.new("#{status_command} 2>&1")
shell.run_command

if shell.exitstatus == 0

  # Bluepill is running, so we need to restart it
  bash "restart bluepill" do
    user "root"
    cwd "/tmp"
    code <<-EOS
      bluepill restart #{process_name}
    EOS
  end

else

  # Bluepill is not running, so start server running now through bluepill
  bash "start bluepill" do
    user "root"
    cwd "/tmp"
    code <<-EOS
      bluepill load #{pill_path}
    EOS
  end

end
