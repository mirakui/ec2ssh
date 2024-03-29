[![Gem Version](https://badge.fury.io/rb/ec2ssh.svg)](https://badge.fury.io/rb/ec2ssh)
[![Build Status](https://github.com/mirakui/ec2ssh/actions/workflows/main.yml/badge.svg)](https://github.com/mirakui/ec2ssh/actions/workflows/main.yml)

# Introduction
ec2ssh is a ssh_config manager for Amazon EC2.

`ec2ssh` command adds `Host` descriptions to ssh_config (~/.ssh/config default). 'Name' tag of instances are used as `Host` descriptions.

# How to use
### 1. Set 'Name' tag to your instances
eg. Tag 'app-server-1' as 'Name' to an instance i-xxxxx in us-west-1 region.

### 2. Write ~/.aws/credentials
```
# ~/.aws/credentials

[default]
aws_access_key_id=...
aws_secret_access_key=...

[myprofile]
aws_access_key_id=...
aws_secret_access_key=...
```

If you need more details about `~/.aws/credentials`, check [A New and Standardized Way to Manage Credentials in the AWS SDKs](http://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs)

### 3. Install ec2ssh

```
$ gem install ec2ssh
```

### 4. Execute `ec2ssh init`

```
$ ec2ssh init
```

### 5. Edit `.ec2ssh`

```
$ vi ~/.ec2ssh
---
profiles 'default', 'myprofile', ...
regions 'us-east-1', 'ap-northeast-1', ...

# Ignore unnamed instances
reject {|instance| !instance.tag('Name') }

# You can specify filters on DescribeInstances (default: lists 'running' instances only)
filters([
  { name: 'instance-state-name', values: ['running', 'stopped'] }
])

# You can use methods of AWS::EC2::Instance and tag(key) method.
# See https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/EC2/Instance.html
host_line <<END
Host <%= tag('Name') %>.<%= placement.availability_zone %>
  HostName <%= public_dns_name || private_ip_address %>
END
```

### 6. Execute `ec2ssh update`

```
$ ec2ssh update
```
Then host-names of your instances are generated and wrote to .ssh/config

### 7. And you can ssh to your instances with your tagged name.

```
$ ssh app-server-1.us-east-1a
```

# Commands
```
$ ec2ssh help [TASK]  # Describe available tasks or one specific task
$ ec2ssh init         # Add ec2ssh mark to ssh_config
$ ec2ssh update       # Update ec2 hosts list in ssh_config
$ ec2ssh remove       # Remove ec2ssh mark from ssh_config
```

## Options
### --dotfile
Each command can use `--dotfile` option to set dotfile (.ec2ssh) path. `~/.ec2ssh` is default.

```
$ ec2ssh init --dotfile /path/to/ssh_config
```

# ssh_config and mark lines
`ec2ssh init` command inserts mark lines your `.ssh/config` such as:

```
### EC2SSH BEGIN ###
# Generated by ec2ssh http://github.com/mirakui/ec2ssh
# DO NOT edit this block!
# Updated Sun Dec 05 00:00:14 +0900 2010
### EC2SSH END ###
```

`ec2ssh update` command inserts 'Host' descriptions between 'BEGIN' line and 'END' line.

```
### EC2SSH BEGIN ###
# Generated by ec2ssh http://github.com/mirakui/ec2ssh
# DO NOT edit this block!
# Updated Sun Dec 05 00:00:14 +0900 2010

# section: default
Host app-server-1.us-west-1
  HostName ec2-xxx-xxx-xxx-xxx.us-west-1.compute.amazonaws.com
Host db-server-1.ap-southeast-1
  HostName ec2-xxx-xxx-xxx-xxx.ap-southeast-1.compute.amazonaws.com
    :
    :
### EC2SSH END ###
```

`ec2ssh remove` command removes the mark lines.

# How to upgrade from 3.x
Dotfile (`.ec2ssh`) format has been changed from 3.x.

* A instance tag access I/F has been changed from `tags['Name']` to `tag('Name')`
* `Aws::EC2::Instance` methods have been changed to AWS SDK v3
* The `aws_keys` structure has been changed
  * `aws_keys[profile_name][region] # => Aws::Credentials`
  * For example:

```
aws_keys(
  my_prof1: {
    'ap-northeast-1' => Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  }
)
```

# Notice
`ec2ssh` command updates your `.ssh/config` file default. You should make a backup of it.

# Zsh completion support
Use `zsh/_ec2ssh`.

# License
Copyright (c) 2022 Issei Naruta. ec2ssh is released under the MIT license.
