bind_service 'default' do
    action [:create, :start]
end
  
bind_config 'default' do
    ipv6_listen true
    options [
        'recursion no',
        'allow-query { any; }',
        'allow-transfer { external-private-interfaces; external-dns; }',
        'allow-notify { external-private-interfaces; external-dns; localhost; }',
        'listen-on-v6 { any; }'
    ]
end
  
bind_acl 'external-private-interfaces' do
    entries [
    ]
end
  
bind_acl 'external-dns' do
    entries [
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
