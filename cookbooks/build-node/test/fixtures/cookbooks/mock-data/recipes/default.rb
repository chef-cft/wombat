# copy files into tmp for cookbook

cookbook_file '/tmp/public.pub' do
  content 'public.pub'
  action :create
end

cookbook_file '/tmp/private.pem' do
  content 'private.pem'
  action :create
end 

%w(chef automate compliance).each do |f|
  cookbook_file "/tmp/#{f}.crt" do
    content "#{f}.crt"
    action :create
  end
end
