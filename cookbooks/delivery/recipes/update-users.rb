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
           "first"       => info['first'],
           "last"        => info['last'],
           "email"       => info['email']
          })
      else
        delivery_api.post("/internal-users",
          {
            "name"        => username,
            "first"       => info['first'],
            "last"        => info['last'],
            "email"       => info['email'],
            "ssh_pub_key" => ssh_pub_key
          })
      end

      # Grant Roles
      delivery_api.post("/authz/users/#{username}", { "grant" => info['roles'] })

      # Set Password
      if info['password']
        delivery_api.post("/internal-users/#{username}/reset-password", { "password" => info['password'] })
      end
    end
  end
end

# # Create Organization
# ruby_block "Create /orgs/#{info['organization']}/projects/#{project}" do
#   block do
#     delivery_api.post('/orgs', { "name" => info['organization'] })
#   end
# end