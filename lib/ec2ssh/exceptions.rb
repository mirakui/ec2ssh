module Ec2ssh
  class DslFileNotFound < StandardError; end
  class MarkNotFound < StandardError; end
  class MarkAlreadyExists < StandardError; end
  class AwsKeyNotFound < StandardError; end
end
