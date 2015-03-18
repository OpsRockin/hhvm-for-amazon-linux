# Ref https://github.com/facebook/hhvm/wiki/Building%20and%20installing%20HHVM%20on%20Amazon%20Linux%202014.03


node[:hhvm_rpm][:packages][:build_deps_from_amzn].map do |pkg|
  package pkg
end

template File.join('/home', node[:hhvm_rpm][:user], '.rpmmacros') do
  source '.rpmmacros.erb'
  action :create
  owner node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
end

remote_directory File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild') do
  source 'rpmbuild'
  recursive true
  owner node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
end
