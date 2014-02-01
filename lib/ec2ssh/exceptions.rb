module Ec2ssh
  class DotfileNotFound < StandardError; end
  class InvalidDotfile < StandardError; end
  class MarkNotFound < StandardError; end
  class MarkAlreadyExists < StandardError; end
  class AwsKeyNotFound < StandardError; end
end
