# Create Users through the API
ruby_block "Create Delivery Users" do
  block do
    # Per User
    node['demo']['users'].each do |username, info|
      # Get SSH-KEY wheter is the actual key or a path
      ssh_pub_key = return_key(info['ssh_key'])

      # Create User
      if username == "admin"
        delivery_api.put("/users/admin",
          {
            "name"        => username,
            "first"       => info['first'],
            "last"        => info['last'],
            "email"       => info['email'],
            "user_type"   => "internal",
            "ssh_pub_key" => ssh_pub_key
          })
      else
        delivery_api.put("/users/#{username}",
          {
            "name"        => username,
            "first"       => info['first'],
            "last"        => info['last'],
            "email"       => info['email'],
	          "user_type"   => "internal",
            "ssh_pub_key" => ssh_pub_key
          })
      end

      # Grant Roles
      delivery_api.post("/authz/users/#{username}", { "grant" => info['roles'] })

      # Set Password
      if info['password']
        delivery_api.post("/internal-users/#{username}/change-password", { "password" => info['password'] })
      end
    end
  end
end

# Create Organization
ruby_block "Create #{node['demo']['org']} organization" do
  block do
    delivery_api.post("/e/#{node['demo']['enterprise']}/orgs", { "name" => node['demo']['org'] })
  end
end
