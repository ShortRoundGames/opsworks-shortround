# Add all rabbitmq nodes to the hosts file with their short name.
#instances = node[:opsworks][:layers][:rabbitmq][:instances]


layer = search("aws_opsworks_layer").first 
rabbit_layer_id = layer[:layer_id]

# Get the instances on this layer
instances = []

search("aws_opsworks_instance").each do |instance|
  Chef::Log.info("********** The instance's hostname is '#{instance['hostname']}' **********")
  Chef::Log.info("********** The instance's ID is '#{instance['instance_id']}' **********")
  
  instance[:layer_ids].each do |layer_id|
	Chef::Log.info("********** The instance's layer is '#{layer_id}' **********")
	if (layer_id == rabbit_layer_id)
	   Chef::Log.info("********** ADDED' **********")
	   instances.push(instance)
	end
  end
end

instances.each do |name, attrs|
  hostsfile_entry attrs['private_ip'] do
    hostname  name
    unique    true
  end
end

rabbit_nodes = instances.map{ |name, attrs| "rabbit@#{name}" }
node.set['rabbitmq']['cluster_disk_nodes'] = rabbit_nodes

include_recipe 'rabbitmq'

execute "chown -R rabbitmq:rabbitmq /var/lib/rabbitmq"

rabbitmq_user "guest" do
  action :delete
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  password node['rabbitmq_cluster']['password']
  action :add
end

rabbitmq_user node['rabbitmq_cluster']['user'] do
  vhost "/"
  permissions ".* .* .*"
  action :set_permissions
end
