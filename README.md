# hhvm-for-amazon-linux RPM

Stable: [![Package repository](https://img.shields.io/badge/install%20via-packagecloud.io-green.svg?style=flat-square)](https://packagecloud.io/opsrock-hhvm/hhvm-stable)
Test: [![Package repository](https://img.shields.io/badge/install%20via-packagecloud.io-green.svg?style=flat-square)](https://packagecloud.io/opsrock-hhvm/hhvm-test)

Building rpm-package of [hiphop-php(hhvm)](http://hhvm.com) from source for Amazon Linux .


## Runtime Requrements

- hop5 Package Repository [http://www.hop5.in](http://www.hop5.in)
    - Google glog
    - Intel tbb (> 2.4)
- mysql or its alternatives such as below.
    - mysql-server
    - mariadb-server
    - percona-server

## How to install from packagecloud

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


## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-zero/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Licensed under the GPL

