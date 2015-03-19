require 'spec_helper'

describe package('hhvm') do
  it { should be_installed }
end

describe service('hhvm') do
  it { should be_enabled }
  it { should be_running }
end

describe port(9001) do
  it { should be_listening }
end

describe command('hhvm --php -r "phpinfo();"') do
  its(:stdout) { should eq "HipHop\n" }
end
