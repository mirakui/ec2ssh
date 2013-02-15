require 'yaml'

module Ec2ssh
  class Dotfile
    def initialize(config={})
      @config = {
        'path' => "#{ENV['HOME']}/.ssh/config",
        'access_key_id' => '',
        'secret_access_key' => '',
        'regions' => %(ap-northeast-1),
      }.merge(config)
    end

    def self.load(path)
      new YAML.load(path)
    end

    def save(path)
      open(path, 'w') {|f| f.write @config.to_yaml }
    end

    def [](key)
      @config[key]
    end
  end
end
