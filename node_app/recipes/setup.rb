include_recipe "nodejs"

# DEPRECATED: install npm and forever package
# include_recipe "nodejs::npm"
# nodejs_npm "forever"

gem_package "activesupport" do
  version "4.2.1"
  action :install
end

gem_package "bluepill" do
  version "0.1.1"
  action :install
end
