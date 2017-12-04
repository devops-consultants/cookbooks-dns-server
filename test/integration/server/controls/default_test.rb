%w[bind bind-utils].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
end

describe file('/etc/named.conf') do
    it { should exist }
    its('content') { should match /zone "consul" IN {(.*)forwarders { 127.0.0.1 port 8600; };(.*)};/m }
    its('content') { should match /zone "example.org" IN {(.*)file "primary\/db.example.org";(.*)};/m }
end
  
describe file('/var/named/primary/db.example.org') do
    it { should exist }
    its('content') { should match /\$TTL 200/ }
    its('content') { should match /@\s+IN SOA\s+example.org. hostmaster.example.org. \(/ }
end

describe command('dig -t any www.example.org @localhost') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /;; ANSWER SECTION:\s+www.example.org.\s+20\s+IN\s+A\s+10.5.0.1/m }
    its('stdout') { should match /;; SERVER: 127.0.0.1#53\(127.0.0.1\)/ }
end

describe command('dig bbc.co.uk @localhost') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match /;; ANSWER SECTION:\s+bbc.co.uk.\s+\d+\s+IN\s+A/m }
end