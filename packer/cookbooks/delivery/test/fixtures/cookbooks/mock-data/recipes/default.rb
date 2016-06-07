# copy files into tmp for cookbook

cookbook_file '/tmp/public.pub' do
  content 'public.pub'
  action :create
end

cookbook_file '/tmp/private.pem' do
  content 'private.pem'
  action :create
end 

%w(chef-server delivery compliance).each do |f|
  %w(crt key).each do |ext|
    cookbook_file "/tmp/#{f}.#{ext}" do
      content "#{f}.#{ext}"
      action :create
      sensitive true
    end
  end
end

# you need to copy this in place
cookbook_file '/tmp/delivery.license' do
  content 'delivery.license'
  action :create
end 