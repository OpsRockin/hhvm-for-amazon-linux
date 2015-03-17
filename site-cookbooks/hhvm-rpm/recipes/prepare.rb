# Ref https://github.com/facebook/hhvm/wiki/Building%20and%20installing%20HHVM%20on%20Amazon%20Linux%202014.03

%w[
git
rpm-build
rpmdevtools
mysql-server
ImageMagick-devel
automake
binutils-devel
boost-devel
bzip2-devel
chrpath
cmake
cpp
elfutils-libelf-devel
expat-devel
gd-devel
jemalloc-devel
libIDL-devel
libc-client-devel
libcap-devel
libcurl-devel
libevent-devel
libicu-devel
libmcrypt-devel
libmemcached-devel
libtool
libxml2-devel
libxslt-devel
memcached
mysql-devel
oniguruma-devel
openldap-devel
pam-devel
pcre-devel
readline-devel
subversion
].map do|pkg|
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
