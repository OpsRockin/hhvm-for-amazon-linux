
remote_file File.join("/home", node[:hhvm_rpm][:user], 'rpmbuild/SOURCES', "glog-#{node[:glog][:version]}.tar.gz") do
  source "http://google-glog.googlecode.com/files/glog-#{node[:glog][:version]}.tar.gz"
  checksum node[:glog][:shasum]

end

template File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/SPECS', "glog.spec") do
  source "glog.spec.erb"
  owner node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  variables node[:glog]
end

execute "rpmbuild -bb --clean SPECS/glog.spec" do
  timeout 9600
  environment "HOME" => File.join('/home', node[:hhvm_rpm][:user])
  user node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  cwd File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild')
  action node[:glog][:action].to_sym
  creates File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/RPMS/x86_64', "glog-#{node[:glog][:version]}-#{node[:glog][:release]}.amzn1.x86_64.rpm")
end

