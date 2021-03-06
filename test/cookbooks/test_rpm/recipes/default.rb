#
# Cookbook Name:: test_rpm
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "#{cookbook_name}::setup_depends"

yum_repository 'opsrock-hhvm' do
  description "Opsrock hhvm for Amazon Linux Repository"
  baseurl "https://packagecloud.io/opsrock-hhvm/hhvm-develop/el/6/$basearch"
  gpgkey 'https://packagecloud.io/gpg.key'
  action :create
  includepkgs 'hhvm'
  gpgcheck false
end

yum_package 'mysql-server'
yum_package 'hhvm' do
  action :install
  # options '-y --nogpgcheck'
end

service 'hhvm' do
  action [:enable, :start]
end
