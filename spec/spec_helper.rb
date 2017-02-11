require 'bundler/setup'
Bundler.require

require 'fakefs/spec_helpers'
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

  def silence_stdout(&block)
    capture(:stdout, &block)
  end

  def tmp_dir
    @tmp_dir ||= begin
      Pathname('/fakefs/ec2ssh').tap do |path|
        FileUtils.mkdir_p path
      end
    end
  end

  alias :silence :capture
end
