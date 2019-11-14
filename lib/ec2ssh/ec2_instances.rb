require 'aws-sdk'
require 'ec2ssh/exceptions'

module Ec2ssh
  class Ec2Instances
    attr_reader :ec2s, :aws_keys

    class InstanceWrapper
      class TagsWrapper
        def initialize(tags)
          @tags = tags
        end

        # simulate
        def [](key)
          if key.is_a? ::String
            raise DotfileValidationError, <<-MSG
`tags[String]` syntax in the dotfile has been deleted since v4.0. Use `tag(String)` instead.
See: https://github.com/mirakui/ec2ssh#how-to-upgrade-from-3x
            MSG
          end
          super
        end

        private

        def method_missing(name, *args, &block)
          @tags.public_send(name, *args, &block)
        end

        def respond_to_missing?(symbol, include_private)
          @tags.respond_to?(symbol, include_private)
        end
      end

      def initialize(ec2_instance)
        @ec2_instance = ec2_instance
        @_tags ||= @ec2_instance.tags.each_with_object({}) {|t, h| h[t.key] = t.value }
      end

      def tag(key)
        @_tags[key]
      end

      def tags
        TagsWrapper.new(super)
      end

      private

      def method_missing(name, *args, &block)
        @ec2_instance.public_send(name, *args, &block)
      end

      def respond_to_missing?(symbol, include_private)
        @ec2_instance.respond_to?(symbol, include_private)
      end
    end

    def initialize(aws_keys, filters)
      @aws_keys = aws_keys
      @filters = filters
    end

    def make_ec2s
      _ec2s = {}
      aws_keys.each_pair do |name, keys|
        _ec2s[name] = {}
        keys.each_pair do |region, key|
          client = Aws::EC2::Client.new region: region, credentials: key
          _ec2s[name][region] = Aws::EC2::Resource.new client: client
        end
      end
      _ec2s
    end

    def ec2s
      @ec2s ||= make_ec2s
    end

    def instances(key_name)
      aws_keys[key_name].each_key.map {|region|
        ec2s[key_name][region].instances(
          filters: @filters
        ).
        map {|ins| InstanceWrapper.new(ins) }.
        sort_by {|ins| ins.tag('Name').to_s }
      }.flatten
    end

    def self.expand_profile_name_to_credential(profile_name, region)
      client = Aws::STS::Client.new(profile: profile_name, region: region)
      client.config.credentials
    end
  end
end
