bind_service 'default' do
    action [:create, :start]
end
  
bind_config 'default' do
    ipv6_listen false
    options [
        'check-names slave ignore',
        'multi-master yes',
        'provide-ixfr yes',
        'recursive-clients 10000',
        'request-ixfr yes',
        'recursion yes',
        "forwarders { #{node['named']['forwarders'].join("; ")}; }",
        'allow-query { local-subnets; localhost; }',
        'allow-recursion { local-subnets; localhost; }',
        'allow-query-cache { local-subnets; localhost; }',
        'allow-transfer { secondary-dns; }',
        'allow-notify { secondary-dns; localhost; }',
        'allow-update-forwarding { any; }'
    ]
end
  
bind_acl 'local-subnets' do
    entries [
        '10/8',
    ]
end
  
bind_acl 'secondary-dns' do
    entries [
        '193.47.99.3',
        '2001:67c:192c::add:a3',
        '213.133.105.6',
        '2a01:4f8:d0a:2004::2'
    ]
end

search(:dns_records, "*:*").each do |zone|
    dns_zone = zone['id']

    soa = {
        serial: zone['soa serial'],
        mname: zone['soa mname'],
        rname: zone['soa rname'],
        refresh: '1w',
        retry: '15m',
        expire: '52w',
        minimum: 30,
      }
    
    bind_primary_zone_template dns_zone do
        soa soa
        default_ttl zone['default_ttl']
        records zone['records']
    end  
end

bind_forward_zone 'consul' do
    forward 'only'
    forwarders [
      '127.0.0.1 port 8600'
    ]
end

# setsebool -P named_write_master_zones 1