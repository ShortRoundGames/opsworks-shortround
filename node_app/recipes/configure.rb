# Create opsworks.js
if (node[:deploy])
  node[:deploy].each do |application, deploy|
    if deploy[:application_type] != 'nodejs'
      Chef::Log.debug("Skipping deploy::nodejs application #{application} as it is not a node.js app")
      next
    end

    template "/mnt/server/current/opsworks.js" do
      source 'opsworks.js.erb'
      mode '0660'
      user deploy[:user]
      group deploy[:group]
      variables(:database => deploy[:database], :memcached => deploy[:memcached], :layers => node[:opsworks][:layers])
    end
  end
end


# Switch pill name based on the instance's layer
layerName = "default";
if (node[:opsworks])
  layerName = node["opsworks"]["instance"]["layers"][0]
end
pillName = node[:app][layerName][:pill]


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
      bluepill load /mnt/server/current/#{pillName}
    EOS
  end

end
