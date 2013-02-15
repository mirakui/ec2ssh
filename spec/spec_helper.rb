require 'bundler/setup'
Bundler.require

require 'webmock/rspec'
require 'pathname'
require 'stringio'

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

  def base_dir
    Pathname('../..').expand_path(__FILE__)
  end

  alias :silence :capture
end
