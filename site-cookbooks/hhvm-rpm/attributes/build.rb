default[:hhvm_rpm][:build] = {
  name: "hhvm",
  src: "https://github.com/facebook/hhvm.git",
  version: '3.12.12',
  release: 1,
  cmake_opts: %w[
    -DENABLE_ZEND_COMPAT=ON
    -DMYSQL_UNIX_SOCK_ADDR=/var/lib/mysql/mysql.sock
  ]
}
default[:hhvm_rpm][:build][:ref] = "HHVM-#{node[:hhvm_rpm][:build][:version]}"
default[:hhvm_rpm][:build][:action] = :nothing  # For debug
