require 'bundler/setup'
Bundler.require

require 'fakefs'
require 'webmock/rspec'
require 'pathname'
require 'stringio'
require 'fileutils'

RSpec.configure do |config|
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def tmp_dir
    Pathname('/fakefs/ec2ssh')
  end

  alias :silence :capture

  config.before(:all) do
    unless tmp_dir.directory?
      FileUtils.mkdir_p tmp_dir
    end
  end
end
