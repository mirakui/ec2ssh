require 'yaml'

module Ec2ssh
  class Dotfile
    def initialize(config={})
      @config = {
        'path' => "~/.ssh/config",
        'access_key_id' => ENV['AMAZON_ACCESS_KEY_ID'],
        'secret_access_key' => ENV['AMAZON_SECRET_ACCESS_KEY'],
        'regions' => %w(ap-northeast-1),
      }.merge(config)
    end

    def self.load(path)
      new YAML.load(open(path).read)
    end

    def save(path)
      open(path, 'w') {|f| f.write @config.to_yaml }
    end

    def self.update_or_create(path, config={})
      dotfile = if File.exist?(path)
        Dotfile.load(path)
      else
        new
      end
      dotfile.update(config)
      dotfile.save(path)
    end

    def [](key)
      @config[key]
    end

    def update(config)
      @config = @config.merge config
    end
  end
end
