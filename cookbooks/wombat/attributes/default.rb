default['demo']['domain'] = 'chordata.biz'
default['demo']['enterprise'] = 'mammalia'
default['demo']['org'] = 'diprotodontia'
default['demo']['admin-user'] = 'ubuntu'
default['demo']['admin-user'] = 'ubuntu'
default['demo']['versions'].tap do |pkg|
  pkg['chefdk'] = '0.14.25'
  pkg['delivery'] = '0.4.317'
  pkg['compliance'] = '1.3.1'
end


default['demo']['hosts'] = {
  'chef-server' => '172.31.54.10',
  'delivery' => '172.31.54.11',
  'build-node-1' => '172.31.54.12'
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
  }
}