
#Output the monit log file to 
template "/mnt/raknet/bin/proxy_coordinator.pill" do
    source 'proxy_coordinator.pill.erb'
    owner 'root'
    group 'root'
    mode '0700'
end
