# copy files into tmp for cookbook

cookbook_file 'C:/Windows/Temp/public.pub' do
  content 'public.pub'
  action :create
end

cookbook_file 'C:/Windows/Temp/private.pem' do
  content 'private.pem'
  action :create
end

%w(chef-server delivery compliance).each do |f|
  %w(crt key).each do |ext|
    cookbook_file "C:/Windows/Temp/#{f}.#{ext}" do
      content "#{f}.#{ext}"
      action :create
      sensitive true
    end
  end
end
