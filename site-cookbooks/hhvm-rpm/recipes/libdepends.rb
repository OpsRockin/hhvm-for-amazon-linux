# Ref: https://github.com/facebook/hhvm/wiki/Building%20and%20installing%20HHVM%20on%20Amazon%20Linux%202014.03

depend_packages = node[:hhvm_rpm][:packages][:build_deps_from_fedora].concat(node[:hhvm_rpm][:packages][:run_deps_from_fedora])
epelpkgs = node[:hhvm_rpm][:packages][:build_deps_from_epel]

yum_repository 'opsrock-hhvm-depends' do
  description "Opsrock hhvm dependency packages for Amazon Linux Repository"
  baseurl "https://packagecloud.io/opsrock-hhvm/hhvm-depends/el/6/$basearch"
  gpgkey 'https://packagecloud.io/gpg.key'
  action :create
  gpgcheck false
  priority '9'
  includepkgs depend_packages.join(",")
end

yum_repository 'home_ocaml' do
  description "opam (CentOS_6)"
  baseurl "http://download.opensuse.org/repositories/home:/ocaml/CentOS_6/"
  gpgkey "http://download.opensuse.org/repositories/home:/ocaml/CentOS_6/repodata/repomd.xml.key"
  action :create
  enabled false
end

## install from epel
epelpkgs.map do |pkg|
  yum_package pkg do
    action :install
    options '--enablerepo=epel'
  end
end

## install opam
yum_package "opam" do
  action :install
  options '--enablerepo=home_ocaml'
end

## install from hhvm-depends
depend_packages.map do |pkg|
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

bash 'install ocaml' do
  environment "HOME" => File.join('/home', node[:hhvm_rpm][:user])
  user node[:hhvm_rpm][:user]
  group node[:hhvm_rpm][:group]
  code <<-EOL
  opam init --comp=#{node[:ocaml][:version]} -y
  EOL
  creates File.join('/home', node[:hhvm_rpm][:user], '.opam', node[:ocaml][:version], "bin/ocaml")
end
