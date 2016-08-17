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
  %w(crt key).each do |ext|
    cookbook_file "/tmp/#{f}.#{ext}" do
      content "#{f}.#{ext}"
      action :create
      sensitive true
    end
  end
end
