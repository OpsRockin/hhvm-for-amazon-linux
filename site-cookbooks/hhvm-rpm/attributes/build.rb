default[:hhvm_rpm][:build] = {
  name: "hhvm",
  src: "https://github.com/facebook/hhvm.git",
  version: '3.6.0',
  release: 1,
  cmake_opts: %w[
    -DENABLE_ZEND_COMPAT=ON
    -DMYSQL_UNIX_SOCK_ADDR=/var/lib/mysql/mysql.sock
  ]
}
default[:hhvm_rpm][:build][:ref] = "HHVM-#{node[:hhvm_rpm][:build][:version]}"
