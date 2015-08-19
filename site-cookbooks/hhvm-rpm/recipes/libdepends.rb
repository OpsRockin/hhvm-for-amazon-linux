# Ref: https://github.com/facebook/hhvm/wiki/Building%20and%20installing%20HHVM%20on%20Amazon%20Linux%202014.03
# http://www.hop5.in/yum/el6/repoview/

hoppkgs = node[:hhvm_rpm][:packages][:build_deps_from_hop5].concat(node[:hhvm_rpm][:packages][:run_deps_from_hop5])
epelpkgs = node[:hhvm_rpm][:packages][:build_deps_from_epel]

yum_repository 'hop5' do
  description "www.hop5.in Centos Repository"
  baseurl "http://www.hop5.in/yum/el6/"
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HOP5'
  action :create
  priority '9'
  includepkgs hoppkgs.join(",")
end

## install from epel
epelpkgs.map do |pkg|
  yum_package pkg do
    action :install
    options '--enablerepo=epel'
  end
end

## install from hop5
hoppkgs.map do |pkg|
  yum_package pkg do
    action :install
    options '-y --nogpgcheck'
  end
end

ark 'cmake' do
  url 'http://www.cmake.org/files/v3.2/cmake-3.2.1-Linux-x86_64.tar.gz'
  checksum '81ba51d72946e40fa7e38a9244a5966dc42a8bfae03087a211e28e5243901ea6'
  has_binaries %w[
bin/ccmake
bin/cmake
bin/cmake-gui
bin/cpack
bin/ctest
  ]
end

