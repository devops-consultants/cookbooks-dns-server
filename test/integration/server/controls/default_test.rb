%w[bind].each do |pkg|
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