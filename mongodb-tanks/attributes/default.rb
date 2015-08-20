
case node['platform_family']
when "freebsd"
  default[:mongodb][:package_name] = "mongodb"

when "rhel","fedora"
  default[:mongodb][:package_name] = "mongo-10gen-server"

else
  default[:mongodb][:package_name] = "mongodb-10gen"
  default[:mongodb][:apt_repo] = "debian-sysvinit"

end

default[:mongodb][:package_version] = nil
