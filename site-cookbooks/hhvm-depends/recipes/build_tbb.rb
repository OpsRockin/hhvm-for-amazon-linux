tbb_basename = [
  "tbb",
  node[:tbb][:major],
  node[:tbb][:minor],
  "_",
  node[:tbb][:releasedate],
  "oss"
].join

tbbfiles = %w[
tbb-4.3-dont-snip-Wall.patch
tbb.pc
tbbmalloc.pc
tbbmalloc_proxy.pc
]


remote_file File.join("/home", node[:hhvm_rpm][:user], 'rpmbuild/SOURCES', "#{tbb_basename}_src.tgz") do
  source "http://threadingbuildingblocks.org/sites/default/files/software_releases/source/#{tbb_basename}_src.tgz"
  checksum node[:tbb][:shasum]
end

tbbfiles.map do |filename|
  cookbook_file File.join("/home", node[:hhvm_rpm][:user], 'rpmbuild/SOURCES', filename) do
    source "tbb/#{filename}"
  end
end

template File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/SPECS', "tbb.spec") do
  source "tbb.spec.erb"
  owner node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  variables node[:tbb]
end

execute "rpmbuild -bb --clean SPECS/tbb.spec" do
  timeout 9600
  environment "HOME" => File.join('/home', node[:hhvm_rpm][:user])
  user node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  cwd File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild')
  action node[:tbb][:action].to_sym
  creates File.join('/home', node[:hhvm_rpm][:user], 'rpmbuild/RPMS/x86_64',
                    "tbb-#{node[:tbb][:major]}.#{node[:tbb][:minor]}.u#{node[:tbb][:update]}.#{node[:tbb][:release]}.amzn1.x86_64.rpm"
                   )
end

