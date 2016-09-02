require 'erb'
require 'json'
require 'openssl'
require 'net/ssh'
require 'yaml'
require 'parallel'
require 'aws-sdk'

namespace :build do
  desc 'Build an image'
  task :image, :template, :builder do |_t, args|
    sh "bin/wombat build -o #{args[:builder]} #{args[:template]}"
  end

  desc 'Build all images'
  task :images, :builder, :parallel do |_t, args|
    if parallel == 'true'
      sh "bin/wombat build -o #{args[:builder]} --parallel"
    else
      sh "bin/wombat build -o #{args[:builder]}"
    end
  end
end

namespace :deploy do
  desc 'Deploy a stack from template'
  task :create, :stack,:cloud do |_t, args|
    case args[:cloud]
    when "gce", "gcp", "google", "gdm"
      # TODO
    when "aws", "amazon", "jeffbezosband", "cfn"
      sh "bin/wombat deploy --cloud aws #{args[:stack]}"
    end
  end

  desc 'Delete a stack'
  task :delete, :stack, :cloud do |task, args|
    cloud = args[:cloud] == 'gcp' ? 'gcp' : 'aws'
    sh "bin/wombat delete --cloud #{cloud} #{args[:stack]}"
  end

  desc 'List workstation IPs of a stack'
  task :outputs, :stack, :cloud do |task, args|
    cloud = args[:cloud] == 'gcp' ? 'gcp' : 'aws'
    case cloud
    when "gce", "gcp", "google", "gdm"
      puts "do google shit"
    when "aws", "amazon", "jeffbezosband", "cfn"
      sh "bin/wombat outputs --cloud aws #{args[:stack]}"
    end
  end
end
