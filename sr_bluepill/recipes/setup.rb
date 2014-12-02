
# install bluepill
gem_package "bluepill" do
  version "0.0.68"
  action :install
end

# Fixup screwed version of bluepill on the instance
if (node[:opsworks])
  template "/usr/local/lib/ruby/gems/2.0.0/gems/bluepill-0.0.68/lib/bluepill.rb" do
    source 'bluepill.rb.erb'
    mode '0660'
    user 'root'
    group 'root'
  end
end


# chmod 0755 #{install_path}/current/bluepill.rb
# mv #{install_path}/current/bluepill.rb /usr/local/lib/ruby/gems/2.0.0/gems/bluepill-0.0.68/lib/bluepill.rb