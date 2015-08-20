case node['platform_family']
when "debian"
  default[:mongodb][:apt_repo] = "debian-sysvinit"
end
