# Amigrind #
Amigrind is a tool for constructing Amazon Machine Images (AMIs) for use within Amazon AWS. Building upon the [Packer](http://packer.io) tool, Amigrind goes beyond Packer to provide a humane, pleasant experience for its users that couples AWS awareness with strong conventions that allow you to easily build base and application-specific images, with a heavy emphasis on the Immutable Server approach that lends itself to elasticity and responsiveness to load.

## Installation ##
Amigrind is distributed as an application, wrapped in a Rubygem. So to do the needful:

```bash
gem install amigrind
```

That'll provide you with the `amigrind` executable, but won't provide you the `sample_repo` or `sample_config` directories. So you may want to still check out the Git repo, or at least take a peek on Github.

**Please note:** Amigrind is tested only against Ruby 2.3.x. Bugs due to failures in earlier versions of Ruby will not be considered.

## Usage ##
Amigrind works on _blueprints_ and _environments_, stored in its _repo_, to create AMIs that populate its _inventory_. AMIs in your inventory are tagged in such a way as to create _channels_, reflective of your workflow, from which AMIs can be selected.

This is more of a step-by-step guide to a basic usage of Amigrind than a full set of documentation. Help with this is welcomed (I'll get to it eventually otherwise).

### 1. Create A Repo ###
You'll need to create a _repo_, which is a collection of blueprints and environments. You should put this repo into source control. In the future, the repo will also include a configuration file that can be shared across your entire development team. (If you're familiar with pre-Berkshelf Chef repos, you can think of this as similar. A little less crazy, though.)

To do this:

```bash
amigrind repo init DIRECTORY_NAME # directory must not exist!
```

Alternatively, copy `sample_repo` out of the Amigrind repo and create a Git repo with it. Either way is fine.

### 2. Create an Environment ###
An environment can be thought of as a set of channels, AWS configuration details, and a set of arbitrary properties usable in AMI blueprints. Take a look at `sample_repo/environments/development.yaml.example` for an exhaustive example, and mimic it to do thou likewise in your own repo. We recommend at least two channels in your environment, for reasons that will be made clear a little later.

One useful note: unlike the underlying Packer, Amigrind accepts multiple subnets into which AMI builder instances can be launched. The one to be used on any given build will be randomly selected.

### 3. Optional: Set Up Your Configuration File ###
Take a look at `sample_config/config.yaml` and park that in `~/.amigrind/config.yaml`. It'll save you some typing later (otherwise you'll need to pass in `--environment` a lot).

### 4. Create a Blueprint ###
A _blueprint_ is a Ruby class that, under the hood, is transformed into a Packer template based on the settings that you provide. Some of those are AWS-specific, such as the instance size that should be used to generate the instance, but others are more general, i.e. the provisioning steps necessary to run a Chef Solo job.

Take a look at `sample_repo/blueprints` to see examples of blueprints in action. `simple_ubuntu` initializes first; `dependent_ubuntu` then depends on `simple_ubuntu`. You'll notice that the blueprints have `build_channel` directives, which determines which channel a created AMI is placed into. Our sample AMIs are placed into `prerelease`; we'll need to promote `simple_ubuntu` to `live` in order to build `dependent_ubuntu`, which we will do later.

### 5. Build an AMI ###
So let's build an AMI, with your environment file and your blueprint (and this will cost you money, but you should know that, and it's not my fault either way!):

```bash
$ amigrind build execute [--environment development] simple_ubuntu
```

Go get a coffee. It will take a little while. At the end of it, you'll have `simple_ubuntu-000001` in your AWS account, in whatever region you have selected.

### 6. Check your Inventory ###
The _inventory_ is the collection of AMIs created from the blueprint collection. These are used both by the builders for dependent AMIs as well as consuming services that need to launch AMIs (for example, through a dynamic lookup into a CloudFormation template powered by [Cfer](https://github.com/seanedwards/cfer)).

We need to promote our AMI to the `live` channel. This would ordinarily be done by your CI environment, but for now we'll assume that our super-complicated AMI passes our acceptance tests. (You have acceptance tests, right?)

```bash
$ amigrind inventory add-to-channel simple_ubuntu 1 live
```

(You can then do an `amigrind build execute` for `dependent_ubuntu`, as you've satisfied that dependency in the channel.)

### 7. Query the Inventory for Your AMI ###
This can be done through `amigrind` or the `amigrind-lookup` helper in the `amigrind-core` gem. `amigrind` will use your repo and environment to derive your AWS region and your credentials; `amigrind-lookup` doesn't require the full dependency set of `amigrind` itself but requires you to provide it credentials through the standard AWS methods.

When querying a channel, `latest` is a valid option that, instead of searching a named channel, will return images in descending order of creation time. The `--steps-back` option (or `STEPS_BACK` in `amigrind-lookup`) allows you to traverse the list backwards, i.e. in case of rollbacks.

```bash
$ amigrind inventory get-image [--steps-back=STEPS_BACK] simple_ubuntu live
```

```bash
$ amigrind-lookup simple_ubuntu live [STEPS_BACK]
```

### 8. You're Done. Go Do Stuff. ###
You've seen the basics of Amigrind in a pretty short span of time. The commands in `amigrind` are decently documented inline via `--help` and you should be able to hit the ground running from here.

While this has been used internally and for some of my clients, I won't claim it's bug-free and that it won't eat your lunch. Use at your own risk, and file issues if you encounter nasal demons.

## Future Work/Contribution Suggestions ##
- The command line interface is a little janky and unfinished; there are TODOs that should be TODOed.
- Amigrind likes just spitting out JSON blobs to stdout (and much more helpful information to stderr, because I am a mostly competent programmer who mostly understands how Unix streams are supposed to be used, _looking at you almost every DevOps tool ever_) right now. We should provide better formats, including streaming-friendly ones, to make using Amigrind in command-line pipelines easier.
- Extend Amigrind's configuration system to respect a configuration file in the repo, falling back to `~/.amigrind/config.yaml` afterwards.
- Provide support for all Packer provisioners. (I use Chef, but without the Packer provisioner, so LocalShell and RemoteShell are all I've needed!)
- Be a better Windows citizen; don't put Amigrind config files in `~/.amigrind`, but rather somewhere in %APPDATA%.
- Speaking of, Windows testing.
- JRuby testing? If anyone cares?
- Improve logging and error reporting across the board.
- Mock out AWS and Packer externals to better test the build process.
- Integration tests using live AWS/Packer externals.

## Contributing ##
Bug reports and pull requests are welcome on GitHub at https://github.com/eropple/amigrind. Please be advised that this project operates under the conventions of [gitflow-avh](https://github.com/petervanderdoes/gitflow-avh), which you can install on OS X via `brew install git-flow-avh`.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct. (The inevitable whines about this can be directed at the whiner's mirror, not to me.)

## License ##
Copyright 2016 Ed Ropple (ed+amigrind@edropple.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
