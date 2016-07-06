default['demo']['domain_prefix'] = ''
default['demo']['domain'] = 'chordata.biz'
default['demo']['enterprise'] = 'mammalia'
default['demo']['org'] = 'diprotodontia'
default['demo']['build-nodes'] = 1
default['demo']['infranodes'] = {}
default['demo']['admin-user'] = 'ubuntu'
default['demo']['versions'].tap do |pkg|
  pkg['chef'] = 'stable-12.11.18'
  pkg['chefdk'] = 'stable-0.15.15'
  pkg['chef-server'] = 'stable-12.6.0'
  pkg['delivery'] = 'stable-0.4.437'
  pkg['compliance'] = 'stable-1.3.1'
end

default['demo']['hosts'] = {
  'chef-server' => '172.31.54.10',
  'delivery' => '172.31.54.11',
  'compliance' => '172.31.54.12'
}

default['demo']['users'] = {
  "admin" => {
    "first"     => "admin",
    "last"      => "user",
    "email"     => "administrator@#{node['demo']['domain']}",
    "password"  => "eval4me!",
    "roles"     => ["admin"],
    "ssh_key"   => "/tmp/public.pub",
    "pem"       => "/tmp/private.pem"
  },
  "delivery" => {
    "first"     => "delivery",
    "last"      => "user",
    "email"     => "delivery@#{node['demo']['domain']}",
    "password"  => "delivery!",
    "roles"     => ["admin"],
    "ssh_key"   => "/tmp/public.pub",
    "pem"       => "/tmp/private.pem"
  },
  "workstation" => {
    "first"     => "workstation",
    "last"      => "user",
    "email"     => "workstation@#{node['demo']['domain']}",
    "password"  => "workstation!",
    "roles"     => ["admin"],
    "ssh_key"   => "/tmp/public.pub",
    "pem"       => "/tmp/private.pem"
  }
}
