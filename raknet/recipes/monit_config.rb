
#Output the monit log file to 
template "/etc/monit/conf.d/simple_server.monitrc" do
    source 'simple_server.monitrc.erb'
    owner 'root'
    group 'root'
    mode '0700'
end