# Ref: https://github.com/facebook/hhvm/wiki/Building%20and%20installing%20HHVM%20on%20Amazon%20Linux%202014.03
# http://www.hop5.in/yum/el6/repoview/

hoppkgs = "glog,glog-devel,tbb,tbb-devel"

yum_repository 'hop5' do
  description "www.hop5.in Centos Repository"
  baseurl "http://www.hop5.in/yum/el6/"
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HOP5'
  action :create
  priority '9'
  includepkgs hoppkgs
end

## install from hop5
hoppkgs.split(',').map do |pkg|
  yum_package pkg do
    action :install
    options '-y --nogpgcheck'
  end
end

yum_package "libdwarf"
yum_package "libdwarf-devel"

ark 'cmake' do
  url 'http://www.cmake.org/files/v3.2/cmake-3.2.1-Linux-x86_64.tar.gz'
  has_binaries %w[
bin/ccmake
bin/cmake
bin/cmake-gui
bin/cpack
bin/ctest
  ]
end

