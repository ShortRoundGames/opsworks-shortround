include_recipe "nodejs"

# DEPRECATED: install npm and forever package
# include_recipe "nodejs::npm"
# nodejs_npm "forever"

gem_package "bluepill" do
  version "0.0.68"
  action :install
end
