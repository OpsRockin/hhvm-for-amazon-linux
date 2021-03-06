git File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/SOURCES', "hhvm-#{node[:hhvm_rpm][:build][:version]}") do
  action :export
  repository node[:hhvm_rpm][:build][:src]
  revision "HHVM-#{node[:hhvm_rpm][:build][:version]}"
  enable_submodules true
  notifies :run, 'bash[archive_hhvm]', :immediately
end

bash 'archive_hhvm' do
  cwd File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/SOURCES')
  code <<-EOL
  tar czf hhvm-#{node[:hhvm_rpm][:build][:version]}.tar.gz hhvm-#{node[:hhvm_rpm][:build][:version]}
  EOL
  action :nothing
  creates File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/SOURCES', "hhvm-#{node[:hhvm_rpm][:build][:version]}.tar.gz")
end

template File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/SPECS', "hhvm.spec") do
  source "hhvm.spec.erb"
  owner node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  variables node[:hhvm_rpm][:build]
end

execute "eval `opam config env` ; rpmbuild -bb --clean SPECS/hhvm.spec" do
  timeout 9600
  environment "HOME" => File.join('/home', node[:hhvm_rpm][:user])
  user node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  cwd File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild')
  action node[:hhvm_rpm][:build][:action].to_sym
  creates File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/RPMS/x86_64', "hhvm-#{node[:hhvm_rpm][:build][:version]}-#{node[:hhvm_rpm][:build][:release]}.amzn1.x86_64.rpm")
end

