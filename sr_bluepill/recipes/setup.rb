
# install a specific version of this dependency, that we know works ok with Ruby 2.0.0
gem_package "activesupport" do
  version "4.2.1"
  action :install
end

# install bluepill
gem_package "bluepill" do
  version "0.1.1"
  action :install
end

# Fixup screwed version of bluepill on the instance
#if (node[:opsworks])
#  template "/usr/local/lib/ruby/gems/2.0.0/gems/bluepill-0.0.68/lib/bluepill.rb" do
#    source 'bluepill.rb.erb'
#    mode '0755'
#    user 'root'
#    group 'root'
#  end
#end
