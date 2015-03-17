local_mode true
chef_repo_path File.expand_path("../../", __FILE__)
cookbook_path [File.expand_path("../../cookbooks/", __FILE__), File.expand_path("../../site-cookbooks/", __FILE__)]

knife[:ssh_user] = ENV['AWS_EC2_USER']
knife[:identity_file] = File.expand_path("~/.ssh/#{ENV['AWS_SSH_KEY_ID']}")
knife[:use_sudo] = true
knife[:ssh_attribute] = 'name'

