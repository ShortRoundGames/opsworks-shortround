include_recipe "nodejs"

# DEPRECATED: install npm and forever package
# include_recipe "nodejs::npm"
# nodejs_npm "forever"

package 'ruby2.3' do
  action :install
end

gem_package "activesupport" do
  version "4.2.1"
  action :install
end

gem_package "bluepill" do
  version "0.1.1"
  action :install
end

# Install GCC 5.x (required to build some Node modules under Node 6)
bash "install gcc 5.x" do
  user "root"
  cwd "/tmp"

  code <<-EOS
    add-apt-repository -y ppa:ubuntu-toolchain-r/test
    apt-get update
    apt-get -y install gcc-5 g++-5
    rm /usr/bin/g++
    ln -s /usr/bin/g++-5 /usr/bin/g++
  EOS
end
