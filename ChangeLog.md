# Change Log
## 2.0.8

* Update EC2 API endpoint (#16, #20)
  Thanks to @a2ikm and @wnoguchi

## 2.0.7

* Add ssh_options (#11)
  Thanks to @frsyuki

## 2.0.6

* Change thor version specifier from 0.14.6 to 0.14 (#13)
  Thanks to @memerelics

## 2.0.5

* Updated README.md along with fixing a bug at version 2.0.4 (#9)

## 2.0.4

* Store multiple hosts info per `--aws_key` (#8)

## 2.0.3

* Fix bug: Fix undefined method `empty?` when aws keys not set
  Thanks to @2get #6

## 2.0.2

* Fix bug: Raises nil.empty? exception on ec2ssh update
  if there're ec2 instances which have empty Name tag.
  Thanks to @chiastolite #4

## 2.0.1

* Fix bugs around initializing dotfile.

## 2.0.0

* Add dotfile (.ec2ssh); supports multiple aws keys with `$ ec2ssh update --aws-key keyname` option.
  Thanks to @kentaro #3

* Replace a gem `ktheory-right_aws` with `aws-sdk`.

* Write tests.

## 1.0.3

* Surpress thor warnings. Thanks to @mururu #1, @sanemat #2

## 1.0.2

* Fix bug: Blank HostName is created if there're some "stopped" instances.

## 1.0.1

* First Release.
