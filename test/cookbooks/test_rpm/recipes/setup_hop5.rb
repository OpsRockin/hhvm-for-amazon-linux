hoppkgs = "glog,tbb"

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
