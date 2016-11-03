# copy files into tmp for cookbook

if node['platform'] == 'windows'
  tmp_dir = "C:/Windows/Temp"
else
  tmp_dir = "/tmp"
end

cookbook_file File.join(tmp_dir, 'public.pub') do
  content 'public.pub'
  action :create
end

cookbook_file File.join(tmp_dir, 'private.pem') do
  content 'private.pem'
  action :create
end

%w(chef automate compliance).each do |f|
  %w(crt key).each do |ext|
    cookbook_file File.join(tmp_dir, "#{f}.crt") do
      content "#{f}.#{ext}"
      action :create
      sensitive true
    end
  end
end
