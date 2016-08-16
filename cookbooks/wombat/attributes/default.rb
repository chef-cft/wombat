default['demo']['domain_prefix'] = ''
default['demo']['domain'] = 'animals.biz'
default['demo']['enterprise'] = 'mammals'
default['demo']['org'] = 'marsupials'
default['demo']['build-nodes'] = 1
default['demo']['workstations'] = 1
default['demo']['infranodes'] = {}
default['demo']['admin-user'] = 'ubuntu'
default['demo']['versions'].tap do |pkg|
  pkg['chef'] = 'stable-latest'
  pkg['chefdk'] = 'stable-latest'
  pkg['chef-server'] = 'stable-latest'
  pkg['delivery'] = 'stable-latest'
  pkg['compliance'] = 'stable-latest'
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
  }
}

1.upto(node['demo']['workstations'].to_i) do |i|
  default['demo']['users']["workstation-#{i}"] = {
      "first"     => "workstation-#{i}",
      "last"      => "user",
      "email"     => "workstation-#{i}@#{node['demo']['domain']}",
      "password"  => "workstation!",
      "roles"     => ["admin"],
      "ssh_key"   => "/tmp/public.pub",
      "pem"       => "/tmp/private.pem"
  }
end
