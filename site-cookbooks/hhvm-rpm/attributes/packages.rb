default[:hhvm_rpm][:packages] = {
  build_deps_from_amzn: %w[
  ],
  build_deps_from_hop5: %w[
glog-devel
tbb-devel
  ],
  run_deps_from_amazon: %w[
  ],
  run_deps_from_hop5: %w[
glog
tbb
  ]
}
