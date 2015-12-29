deppkgs = "glog,tbb"

yum_repository 'opsrock-hhvm-depends' do
  description "Opsrock hhvm dependency packages for Amazon Linux Repository"
  baseurl "https://packagecloud.io/opsrock-hhvm/hhvm-depends/el/6/$basearch"
  gpgkey 'https://packagecloud.io/gpg.key'
  action :create
  gpgcheck false
  priority '9'
  includepkgs deppkgs
end

## install from hhvm-depends
deppkgs.split(',').map do |pkg|
  yum_package pkg do
    action :install
    options '-y --nogpgcheck'
  end
end
