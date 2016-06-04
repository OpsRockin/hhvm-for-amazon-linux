# hhvm-for-amazon-linux RPM

Building rpm-package of [hiphop-php(hhvm)](http://hhvm.com) from source for Amazon Linux .

## Packages

RPMs are provided via package_cloud.

- Stable: [![Package repository](https://img.shields.io/badge/install%20via-packagecloud.io-green.svg?style=flat-square)](https://packagecloud.io/opsrock-hhvm/hhvm-stable2)
- Test: [![Package repository](https://img.shields.io/badge/install%20via-packagecloud.io-green.svg?style=flat-square)](https://packagecloud.io/opsrock-hhvm/hhvm-test)

## Current Status of this branch

- HHVM 3.12.2

special options

- `-DENABLE_ZEND_COMPAT=ON`
- `-DMYSQL_UNIX_SOCK_ADDR=/var/lib/mysql/mysql.sock`

### Runtime Requrements

- my hhvm-depends Package Repository [/opsrock-hhvm/hhvm-depends](https://packagecloud.io/opsrock-hhvm/hhvm-depends)
    - Google glog 3.3
    - Intel tbb 4.3, 4.4
- mysql or its alternatives such as below.
    - mysql-server
    - mariadb-server
    - percona-server

## How to install from packagecloud

### Shell example

```
## Add opsrock-hhvm-depends
cat <<'EOL'  > /etc/yum.repos.d/opsrock-hhvm-depends.repo
[opsrock-hhvm-depens]
name=Opsrock hhvm depends for Amazon Linux Repository
baseurl=https://packagecloud.io/opsrock-hhvm/hhvm-depends/el/6/$basearch
enabled=1
gpgcheck=1
gpgkey=https://packagecloud.io/gpg.key
includepkgs=glog,tbb
sslverify=true
EOL

## Add OpsRock
cat <<'EOL' > /etc/yum.repos.d/opsrock-hhvm.repo
[opsrock-hhvm]
name=Opsrock hhvm for Amazon Linux Repository
baseurl=https://packagecloud.io/opsrock-hhvm/hhvm-stable2/el/6/$basearch
enabled=1
gpgcheck=1
gpgkey=https://packagecloud.io/gpg.key
includepkgs=hhvm
sslverify=true
EOL

yum update -y
yum install -y glog tbb mysql-server

yum install -y hhvm --nogpg

chkconfig hhvm on
service start hhvm
```

### Chef Recipe example

- Notice: depens on `cookbook[yum]`

```
hoppkgs = "glog,tbb"

yum_repository 'hop5' do
  description "www.hop5.in Centos Repository"
  baseurl "http://www.hop5.in/yum/el6/"
  gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-HOP5'
  action :create
  priority '9'
  includepkgs hoppkgs
end

## install depends from hop5
hoppkgs.split(',').map do |pkg|
  yum_package pkg do
    action :install
    options '-y --nogpgcheck'
  end
end

yum_repository 'opsrock-hhvm' do
  description "Opsrock hhvm for Amazon Linux Repository"
  baseurl "https://packagecloud.io/opsrock-hhvm/hhvm-stable/el/6/$basearch"
  gpgkey 'https://packagecloud.io/gpg.key'
  action :create
  includepkgs 'hhvm'
end

yum_package 'mysql-server'
yum_package 'hhvm' do
  action :install
  options '-y --nogpgcheck'
end

service 'hhvm' do
  action [:enable, :start]
end
```

## Development

Please set requirements to ENV. (see `.kitchen.yml`)

```
$ bundle install
$ bundle exec kitchen converge default
```

It takes about...

```
real	22m32.427s
user	0m4.240s
sys	0m0.564s
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-zero/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This package is licensed under the HHVM license(under the BSD) except as otherwise noted.

- https://github.com/facebook/hhvm#license

