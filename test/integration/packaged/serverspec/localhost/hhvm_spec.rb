require 'spec_helper'

describe package('hhvm') do
  it { should be_installed }
end

describe service('hhvm') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/var/tmp/hiphop-php.sock') do
  it { should be_socket }
end

describe command('hhvm --php -r "phpinfo();"') do
  its(:stdout) { should eq "HipHop\n" }
end

describe command('hhvm --version') do
  its(:stdout) { should match /^HipHop VM 3\.6\.5/ }
end

describe command('rpm -q --changelog hhvm') do
  its(:stdout) { should match /sawanoboly\s3\.6\.5-1\n/ }
end
