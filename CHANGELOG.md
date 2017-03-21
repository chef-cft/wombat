# Change Log

## [v0.5.0](https://github.com/chef-cft/wombat/tree/v0.5.0) (2017-03-21)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.3...v0.5.0)

**Merged pull requests:**

- no more Administrator [\#319](https://github.com/chef-cft/wombat/pull/319) ([binamov](https://github.com/binamov))
- Select whether to use Managed Disks or not [\#317](https://github.com/chef-cft/wombat/pull/317) ([russellseymour](https://github.com/russellseymour))
- azure enhancements [\#316](https://github.com/chef-cft/wombat/pull/316) ([binamov](https://github.com/binamov))
- Added Azure Provide Tag for Chef to resources [\#314](https://github.com/chef-cft/wombat/pull/314) ([russellseymour](https://github.com/russellseymour))
- Added support for Azure Managed Disks [\#312](https://github.com/chef-cft/wombat/pull/312) ([russellseymour](https://github.com/russellseymour))
- Remove checksum verification for Google Chrome Chocolatey package [\#307](https://github.com/chef-cft/wombat/pull/307) ([nweddle](https://github.com/nweddle))

## [v0.4.3](https://github.com/chef-cft/wombat/tree/v0.4.3) (2017-02-23)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.2...v0.4.3)

**Merged pull requests:**

- More aws namespace fixes, unblocked bjc outputs [\#304](https://github.com/chef-cft/wombat/pull/304) ([binamov](https://github.com/binamov))

## [v0.4.2](https://github.com/chef-cft/wombat/tree/v0.4.2) (2017-02-23)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.1...v0.4.2)

**Merged pull requests:**

- Fixed aws namespace, unblocked bjc deploys [\#302](https://github.com/chef-cft/wombat/pull/302) ([binamov](https://github.com/binamov))

## [v0.4.1](https://github.com/chef-cft/wombat/tree/v0.4.1) (2017-02-23)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.0...v0.4.1)

**Closed issues:**

- can't build infranodes [\#299](https://github.com/chef-cft/wombat/issues/299)
- `wombat outputs` and azure [\#293](https://github.com/chef-cft/wombat/issues/293)

**Merged pull requests:**

- Options not being seen by `base\_image` fixes \#299 [\#300](https://github.com/chef-cft/wombat/pull/300) ([russellseymour](https://github.com/russellseymour))
- Enabled outputs for Azure deployments [\#298](https://github.com/chef-cft/wombat/pull/298) ([russellseymour](https://github.com/russellseymour))
- chef-server-ctl don't work on compliance [\#297](https://github.com/chef-cft/wombat/pull/297) ([binamov](https://github.com/binamov))
- Added support to selectively delete items in the RG [\#296](https://github.com/chef-cft/wombat/pull/296) ([russellseymour](https://github.com/russellseymour))
- uses the password from wombat [\#295](https://github.com/chef-cft/wombat/pull/295) ([binamov](https://github.com/binamov))
- Modified the way in which Azure tags can be set [\#294](https://github.com/chef-cft/wombat/pull/294) ([russellseymour](https://github.com/russellseymour))
- Updating vagrantfile, lower resources and fixed cookbook names [\#292](https://github.com/chef-cft/wombat/pull/292) ([cheeseplus](https://github.com/cheeseplus))

## [v0.4.0](https://github.com/chef-cft/wombat/tree/v0.4.0) (2017-02-10)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.4...v0.4.0)

**Implemented enhancements:**
- Decrease data\_collector timeout during build [\#262](https://github.com/chef-cft/wombat/issues/262)
- Add new command`latest` for getting latest cloud images [\#289](https://github.com/chef-cft/wombat/pull/289) ([cheeseplus](https://github.com/cheeseplus))
- add cli option, env variable, and default wombat.yml [\#266](https://github.com/chef-cft/wombat/pull/266) ([andrewelizondo](https://github.com/andrewelizondo))
- Fixes for changed automate api [\#283](https://github.com/chef-cft/wombat/pull/283) ([binamov](https://github.com/binamov))
- Re-enable .NET speed optimizations [\#264](https://github.com/chef-cft/wombat/pull/264) ([nweddle](https://github.com/nweddle))
- Namespacing and spec tests [\#281](https://github.com/chef-cft/wombat/pull/281) ([cheeseplus](https://github.com/cheeseplus))
- Implement TravisCI [\#290](https://github.com/chef-cft/wombat/pull/290) ([cheeseplus](https://github.com/cheeseplus))
- Refactor how source\_ami/image work [\#288](https://github.com/chef-cft/wombat/pull/288) ([cheeseplus](https://github.com/cheeseplus))
- Lots of Azure support work by ([russellseymour](https://github.com/russellseymour))

## [v0.3.4](https://github.com/chef-cft/wombat/tree/v0.3.4) (2016-12-07)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.3...v0.3.4)

**Merged pull requests:**

- Cmder workaround workstation build [\#257](https://github.com/chef-cft/wombat/pull/257) ([andrewelizondo](https://github.com/andrewelizondo))
- Configure compliance profile asset store for chef-server [\#256](https://github.com/chef-cft/wombat/pull/256) ([andrewelizondo](https://github.com/andrewelizondo))


## [v0.3.3](https://github.com/chef-cft/wombat/tree/v0.3.3) (2016-11-15)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.2...v0.3.3)

**Merged pull requests:**

- The dotnet opimizations are breaking builds, disabling recipe [\#253](https://github.com/chef-cft/wombat/pull/253) ([cheeseplus](https://github.com/cheeseplus))

## [v0.3.2](https://github.com/chef-cft/wombat/tree/v0.3.2) (2016-11-14)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.1...v0.3.2)

**Merged pull requests:**

- Prep 0.3.2 for release and add changelog [\#252](https://github.com/chef-cft/wombat/pull/252) ([cheeseplus](https://github.com/cheeseplus))
- Readme badge hotfix [\#251](https://github.com/chef-cft/wombat/pull/251) ([cheeseplus](https://github.com/cheeseplus))
- Fix examples, update readme [\#247](https://github.com/chef-cft/wombat/pull/247) ([cheeseplus](https://github.com/cheeseplus))

## [v0.3.1](https://github.com/chef-cft/wombat/tree/v0.3.1) (2016-11-04)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.0...v0.3.1)

**Merged pull requests:**

- 0.3.1 release [\#246](https://github.com/chef-cft/wombat/pull/246) ([cheeseplus](https://github.com/cheeseplus))
- Log parsing, like honeybader, does not give... [\#245](https://github.com/chef-cft/wombat/pull/245) ([cheeseplus](https://github.com/cheeseplus))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
