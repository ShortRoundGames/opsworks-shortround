
#Output the monit log file to 
template "/etc/monit/conf.d/proxy_coordinator.monitrc" do
    source 'proxy_coordinator.monitrc.erb'
    owner 'root'
    group 'root'
    mode '0700'
end

# Reload monit
bash "reload monit" do
	user "root"
	cwd "/tmp"
	code <<-EOS
		monit reload
	EOS
end