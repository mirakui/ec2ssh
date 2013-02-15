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

    def [](key)
      @config[key]
    end
  end
end
