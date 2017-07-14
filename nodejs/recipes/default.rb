#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2010, Promet Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "build-essential"

case node[:platform]
  when "centos","redhat","fedora"
    package "openssl-devel"
  when "debian","ubuntu"
    package "libssl-dev"
    package "xz-utils"
end

ver = node[:nodejs][:version]

if node['nodejs']['method'] == 'source'
  bash "install nodejs from source" do
    cwd "/usr/local/src"
    user "root"
    code <<-EOH
      wget http://nodejs.org/dist/v#{node[:nodejs][:version]}/node-v#{node[:nodejs][:version]}.tar.gz && \
      tar zxf node-v#{ver}.tar.gz && \
      cd node-v#{ver} && \
      ./configure --prefix=#{node[:nodejs][:dir]} && \
      make && \
      make install
    EOH
    not_if "#{node[:nodejs][:dir]}/bin/node -v 2>&1 | grep 'v#{ver}'"
  end
else
  bash "install nodejs from binaries" do
    cwd "/tmp"
    user "root"
    code <<-EOH
  	  wget https://nodejs.org/dist/v#{node[:nodejs][:version]}/node-v#{node[:nodejs][:version]}-linux-x64.tar.xz && \
  	  tar -C /usr/local --strip-components 1 -xJf node-v#{ver}-linux-x64.tar.xz && \
  	  rm /tmp/node-v#{ver}-linux-x64.tar.xz
    EOH
    not_if "#{node[:nodejs][:dir]}/bin/node -v 2>&1 | grep 'v#{ver}'"
  end
