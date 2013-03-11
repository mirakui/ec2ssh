# Change Log
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
