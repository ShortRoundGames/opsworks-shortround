# Find the attributes for this layer
attribs = "";
if (node[:opsworks])
  node["opsworks"]["instance"]["layers"].each do |layerName|
    if (node[:app][layerName])
      attribs = node[:app][layerName]
	end
  end
end

install_path = attribs[:install_path] + "/current"

# Create opsworks.js
if (node[:deploy])
  template "#{install_path}/opsworks.js" do
    source 'opsworks.js.erb'
    mode '0660'
    user 'root'
    group 'root''
    variables(:layers => node[:opsworks][:layers])
  end
end

# Switch pill name based on the instance's layer
pillName = attribs[:pill];

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
      bluepill restart node1
    EOS
  end

else

  # Bluepill is not running, so start server running now through bluepill
  bash "start bluepill" do
    user "root"
    cwd "/tmp"
    code <<-EOS
      bluepill load #{install_path}/#{pillName}
    EOS
  end

end
