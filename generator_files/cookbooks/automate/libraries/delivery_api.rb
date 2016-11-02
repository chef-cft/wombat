#
# Cookbook Name:: automate
# Libraries:: delivery_api
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#
require 'net/http'
require 'json'
require 'logger'

module Delivery

  # Delivery API
  #
  # @author Salim Afiune <afiune@chef.io>
  #
  class API

    attr_accessor :logger
    attr_accessor :hostname
    attr_accessor :token
    attr_accessor :username
    attr_accessor :password
    attr_accessor :enterprise
    attr_accessor :organization

    # @example Instance a Delivery API
    # => Delivery::API.new('delivery-server', 'my_user', 'my_password', 'my_enterprise')
    #
    # @example [block usage for multiple requests] Create multiple projects
    # => Delivery::API.new('delivery-server', 'my_user', 'my_password', 'marvel') do |api|
    #       %W{
    #           thor
    #           hulk
    #           ironman
    #           hawkeye
    #           BlackWidow
    #           CaptainAmerica
    #       }.each do |project|
    #         api.post('/e/marvel/orgs/avengers/projects',
    #                    {
    #                      "name": project
    #                    }
    #                  )
    #       end
    #   end
    #
    # @yield [self] if a block is given then the constructed object yields
    def initialize (hostname, username, password, enterprise = nil, organization = nil)
      @hostname     = hostname
      @username     = username
      @password     = password
      @enterprise   = enterprise
      @organization = organization
      token
      if block_given?
        yield self
      end
    end

    def delivery_url
      "https://#{@hostname}/api/v0"
    end

    def headers
      {
        "chef-delivery-token" => token,
        "chef-delivery-user" => @username
      }
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def get_delivery_endpoint(endpoint)
      if endpoint.start_with?('/e')
        URI("#{delivery_url}#{endpoint}")
      else
        URI("#{delivery_url}/e/#{enterprise}#{endpoint}")
      end
    end

    def enterprise=(enterprise)
      @enterprise = enterprise
      @token = nil
    end

    def http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def token
      @token ||= begin
        resp = post("/e/#{@enterprise}/get-token", {'username'=> @username, 'password'=> @password})
        resp['token']
      end
    end

    # POST Method
    # Perform a POST to a Delivery Endpoint
    #
    # @example Create an organization. [Using Data::String]
    # => post(
    #         '/e/marvel/orgs',
    #         '{ "name": "Stark Industries" }'
    #    )
    #
    # @example Create a pipeline. [Using Data::Hash]
    # => post(
    #         '/e/marvel/orgs/Stark Industries/projects/hulkbuster/pipelines',
    #         {
    #           "name" => "v2",
    #           "base" => "master"
    #         }
    #    )
    #
    # @param endpoint [String] The Delivery Endpoint
    # @param data [String][Hash] The Body of the request
    # @return [Hash]
    def post(endpoint, data)
      uri = get_delivery_endpoint(endpoint)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "application/json"
      request.body = data.class.eql?(Hash) ? JSON.unparse(data) : data
      headers.keys.each do |key|
        request[key] = headers[key]
      end unless endpoint =~ /get-token/
      response = http(uri).request(request)
      response_error(response)
      JSON.parse(response.body) if response.body
    end

    # GET Method
    # Perform a GET to a Delivery Endpoint
    #
    # @example List all users.
    # => get('/e/marvel/users')
    #
    # @example List Organizations.
    # => get('/e/marvel/orgs')
    #
    # @param endpoint [String] The Delivery Endpoint
    # @return [Hash]
    def get(endpoint)
      uri = get_delivery_endpoint(endpoint)
      response = http(uri).get(uri.path, headers)
      response_error(response)
      JSON.parse(response.body) if response.body
    end

    # PUT Method
    # Perform a PUT to a Delivery Endpoint
    #
    # @param endpoint [String] The Delivery Endpoint
    # @param data [String][Hash] The Body of the request
    # @return [Hash]
    def put(endpoint, data)
      uri = get_delivery_endpoint(endpoint)
      request = Net::HTTP::Put.new(uri.request_uri)
      request.content_type = "application/json"
      request.body = data.class.eql?(Hash) ? JSON.unparse(data) : data
      headers.keys.each do |key|
        request[key] = headers[key]
      end
      response = http(uri).request(request)
      response_error(response)
      JSON.parse(response.body) if response.body
    end

    # DELETE Method
    # Perform a DELETE to a Delivery Endpoint
    #
    # @param endpoint [String] The Delivery Endpoint
    # @return [Hash]
    def delete(endpoint)
      uri = get_delivery_endpoint(endpoint)
      response = http(uri).delete(uri.path, headers)
      response_error(response)
      JSON.parse(response.body) if response.body
    end

    def response_error(response)
      if  '200' <= response.code && response.code <= '301'
        logger.debug(response.body) if Chef::Log.level == :debug
      else
        case response.code
        when '409', '404'
          logger.debug(response.body)  if Chef::Log.level == :debug
        else
          logger.error(response.body)
          response.error!
        end
      end
    end
  end
end
