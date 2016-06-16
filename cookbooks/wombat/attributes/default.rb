default['demo']['domain'] = 'chordata.biz'
default['demo']['enterprise'] = 'mammalia'
default['demo']['org'] = 'diprotodontia'
default['demo']['build-nodes'] = 1
default['demo']['infranodes'] = {}
default['demo']['admin-user'] = 'ubuntu'
default['demo']['versions'].tap do |pkg|
  pkg['chefdk'] = '0.14.25'
  pkg['chef-server'] = '12.6.0'
  pkg['delivery'] = '0.4.317'
  pkg['compliance'] = '1.3.1'
  pkg['chef'] = '12.11.18'
end


default['demo']['hosts'] = {
  'chef-server' => '172.31.54.10',
  'delivery' => '172.31.54.11',
  'compliance' => '172.31.54.12'
}

default['demo']['users'] = {
  "admin" => {
    "first"     => "admin",
    "last"      => "istratator",
    "email"     => "administrator@mammalia.biz",
    "password"  => "eval4me!",
    "roles"     => ["admin"],
    "ssh_key"   => "/tmp/public.pub",
    "pem"       => "/tmp/private.pem"
  },
  "delivery" => {
    "first"     => "delivery",
    "last"      => "user",
    "email"     => "delivery@mammalia.biz",
    "password"  => "delivery!",
    "roles"     => ["admin"],
    "ssh_key"   => "/tmp/public.pub",
    "pem"       => "/tmp/private.pem"
  },
  "workstation" => {
    "first"     => "work",
    "last"      => "station",
    "email"     => "workstation@mammalia.biz",
    "password"  => "workstation!",
    "roles"     => ["admin"],
    "ssh_key"   => "/tmp/public.pub",
    "pem"       => "/tmp/private.pem"
  }
}
