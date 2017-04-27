require 'openssl'
require 'net/ssh'

module Wombat
  module Crypto
    include Wombat::Common

    def gen_x509_cert(hostname)
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      public_key = rsa_key.public_key

      subject = "/C=AU/ST=New South Wales/L=Sydney/O=#{wombat['org']}/OU=wombats/CN=#{wombat['domain_prefix']}#{hostname}.#{wombat['domain']}"

      cert = OpenSSL::X509::Certificate.new
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.public_key = public_key
      cert.serial = 0x0
      cert.version = 2

      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      cert.extensions = [
        ef.create_extension('basicConstraints', 'CA:TRUE', true),
        ef.create_extension('subjectKeyIdentifier', 'hash'),
        ef.create_extension('subjectAltName', "DNS:#{wombat['domain_prefix']}#{hostname}.#{wombat['domain']},DNS:#{hostname}"),
        # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
      ]
      cert.add_extension ef.create_extension('authorityKeyIdentifier',
                                            'keyid:always,issuer:always')

      cert.sign(rsa_key, OpenSSL::Digest::SHA256.new)

      Dir.mkdir(conf['key_dir'], 0755) unless File.exist?(conf['key_dir'])

      if File.exist?("#{conf['key_dir']}/#{hostname}.crt") && File.exist?("#{conf['key_dir']}/#{hostname}.key")
        puts "An x509 certificate already exists for #{hostname}"
      else
        File.open("#{conf['key_dir']}/#{hostname}.crt", 'w') { |file| file.puts cert.to_pem }
        File.open("#{conf['key_dir']}/#{hostname}.key", 'w') { |file| file.puts rsa_key.to_pem }
        puts "Certificate created for #{wombat['domain_prefix']}#{hostname}.#{wombat['domain']}"
      end
    end

    def gen_ssh_key
      rsa_key = OpenSSL::PKey::RSA.new 2048

      type = rsa_key.ssh_type
      data = [rsa_key.to_blob].pack('m0')

      openssh_format = "#{type} #{data}"

      Dir.mkdir(conf['key_dir'], 0755) unless File.exist?(conf['key_dir'])

      if File.exist?("#{conf['key_dir']}/public.pub") && File.exist?("#{conf['key_dir']}/private.pem")
        puts 'An SSH keypair already exists'
      else
        File.open("#{conf['key_dir']}/public.pub", 'w') { |file| file.puts openssh_format }
        File.open("#{conf['key_dir']}/private.pem", 'w') { |file| file.puts rsa_key.to_pem }
        puts 'SSH Keypair created'
      end
    end
  end
end