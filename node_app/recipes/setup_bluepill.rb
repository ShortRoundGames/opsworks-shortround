
# Install Bluepill package
gem_package "bluepill" do
  version "0.0.68"
  action :install
end

# Overwrite main ruby file with a fixed version
template "/usr/local/lib/ruby/gems/2.0.0/gems/bluepill-0.0.68/lib/bluepill.rb" do
  source 'bluepill.rb.erb'
  mode '0755'
  user 'root'
  group 'root'
end
