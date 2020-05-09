# Change Log

## Unreleased
* Remove `--aws-key` option and add `--path` option in shellcomp (#56)
* Use aws-sdk v3 and stop using v2 (#54)
* Delete `rubyforge_project=` in gemspec (#51)
* Relax thor and highline versions (#49)
* CI against Ruby 2.5, 2.6 and 2.7 (#45, #55)
* Drop support outdated Ruby 2.2 and 2.3 (#59)

## 4.0.0
* Use aws-sdk v2 and stop using v1 (#44)
* Support AssumeRole with `~/.aws/credentials` (#44)
* `aws_keys` requires region (#44)
  Thanks to @yujideveloper
* Support `filters` for listing ec2 instances (#43)
  Thanks to @satotakumi

## 3.1.1
* Fix a bug in `--verbose` option (#41)
  Thanks to @adamlazz

## 3.1.0
* Use credentials from `~/.aws/credentials` as default. Credential profiles are set as `profiles` in dotfile.
* Revive path option for changing ssh config path (#34)
  Thanks to @cynipe

## 3.0.3
* Use "%-" for ERB's trim\_mode at `host\_line` in dotfile (#29)
* Add 'shellcomp' command: loading completion functions easily in bash/zsh (#27)
  Thanks to @hayamiz

## 3.0.2
* Add zsh completion file (#26)
  Thanks to @hayamiz

## 3.0.1
* Ignore unnamed instances as default (#22, #24, #25)
  Thanks to @r7kamura and @kainoku

## 3.0.0
* Dotfile (.ec2ssh) format has been changed from YAML to Ruby DSL.
* Refactored

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
