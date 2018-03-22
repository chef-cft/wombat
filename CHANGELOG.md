# Change Log

## [v0.7.2](https://github.com/chef-cft/wombat/tree/v0.7.2) (2018-3-22)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.6.2...v0.7.2)

**Merged pull requests:**
- MVP Mixed-Infra support. [\#347](https://github.com/chef-cft/wombat/pull/347)
## [v0.6.2](https://github.com/chef-cft/wombat/tree/v0.6.2) (2017-09-27)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.6.1...v0.6.2)

**Fixed bugs:**

- client\_key in knife.rb needs a relative path to work with berks [\#337](https://github.com/chef-cft/wombat/issues/337)
- Latest Google Chrome \(58\) broke all our SSL [\#328](https://github.com/chef-cft/wombat/issues/328)

**Merged pull requests:**

- Upgrade to Windows Server 2016 for workstation Packer template [\#340](https://github.com/chef-cft/wombat/pull/340) ([nweddle](https://github.com/nweddle))
- adds relative path to client\_key in knife.rb, fixes \#337 [\#338](https://github.com/chef-cft/wombat/pull/338) ([binamov](https://github.com/binamov))
- we should be idempotent right? [\#336](https://github.com/chef-cft/wombat/pull/336) ([andrewelizondo](https://github.com/andrewelizondo))
- my mama told me not to run with knives [\#335](https://github.com/chef-cft/wombat/pull/335) ([binamov](https://github.com/binamov))
- relative paths ftw [\#334](https://github.com/chef-cft/wombat/pull/334) ([binamov](https://github.com/binamov))

## [v0.6.1](https://github.com/chef-cft/wombat/tree/v0.6.1) (2017-04-27)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.6.0...v0.6.1)

**Merged pull requests:**

- adds SAN to certs, missing default attributes [\#332](https://github.com/chef-cft/wombat/pull/332) ([binamov](https://github.com/binamov))

## [v0.6.0](https://github.com/chef-cft/wombat/tree/v0.6.0) (2017-04-24)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.5.0...v0.6.0)

**Closed issues:**

- resource group deletions [\#323](https://github.com/chef-cft/wombat/issues/323)
- ARM template needs wombat version awareness [\#321](https://github.com/chef-cft/wombat/issues/321)
- build on azure appends to logfile [\#318](https://github.com/chef-cft/wombat/issues/318)
- does wombat still need to install git? [\#308](https://github.com/chef-cft/wombat/issues/308)

**Merged pull requests:**

- v0.6.0 [\#330](https://github.com/chef-cft/wombat/pull/330) ([binamov](https://github.com/binamov))
- Pin Chrome to known working version. [\#329](https://github.com/chef-cft/wombat/pull/329) ([scarolan](https://github.com/scarolan))
- Slow and steady wins the overextended metaphor. \(Sleeps for rabbit\) [\#327](https://github.com/chef-cft/wombat/pull/327) ([ChefRycar](https://github.com/ChefRycar))
- remove hardcoded cert import loop [\#326](https://github.com/chef-cft/wombat/pull/326) ([andrewelizondo](https://github.com/andrewelizondo))
- create file to disable telemetry [\#325](https://github.com/chef-cft/wombat/pull/325) ([andrewelizondo](https://github.com/andrewelizondo))
- Stack names and Resource Groups in Azure [\#324](https://github.com/chef-cft/wombat/pull/324) ([russellseymour](https://github.com/russellseymour))

## [v0.5.0](https://github.com/chef-cft/wombat/tree/v0.5.0) (2017-03-21)
[Full Changelog](https://github.com/chef-cft/wombat/compare/release-0.5.0...v0.5.0)

**Merged pull requests:**

- Release 0.5.0 [\#320](https://github.com/chef-cft/wombat/pull/320) ([binamov](https://github.com/binamov))

## [release-0.5.0](https://github.com/chef-cft/wombat/tree/release-0.5.0) (2017-03-20)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.3...release-0.5.0)

**Implemented enhancements:**

- Base image to use in Azure should be in `wombat.yml` file [\#310](https://github.com/chef-cft/wombat/issues/310)
- Add support for Azure Managed Disks [\#309](https://github.com/chef-cft/wombat/issues/309)

**Closed issues:**

- azure-storage a missing gem in gemspec? [\#315](https://github.com/chef-cft/wombat/issues/315)
- Add Chef Tag for Azure Resources [\#313](https://github.com/chef-cft/wombat/issues/313)
- Google Chrome Chocolatey Package Fails Install [\#306](https://github.com/chef-cft/wombat/issues/306)

**Merged pull requests:**

- no more Administrator [\#319](https://github.com/chef-cft/wombat/pull/319) ([binamov](https://github.com/binamov))
- Select whether to use Managed Disks or not [\#317](https://github.com/chef-cft/wombat/pull/317) ([russellseymour](https://github.com/russellseymour))
- azure enhancements [\#316](https://github.com/chef-cft/wombat/pull/316) ([binamov](https://github.com/binamov))
- Added Azure Provide Tag for Chef to resources [\#314](https://github.com/chef-cft/wombat/pull/314) ([russellseymour](https://github.com/russellseymour))
- Added support for Azure Managed Disks [\#312](https://github.com/chef-cft/wombat/pull/312) ([russellseymour](https://github.com/russellseymour))
- Azure base image can now be specified in wombat.yml [\#311](https://github.com/chef-cft/wombat/pull/311) ([russellseymour](https://github.com/russellseymour))
- Remove checksum verification for Google Chrome Chocolatey package [\#307](https://github.com/chef-cft/wombat/pull/307) ([nweddle](https://github.com/nweddle))
- Release 0.4.3 [\#305](https://github.com/chef-cft/wombat/pull/305) ([binamov](https://github.com/binamov))

## [v0.4.3](https://github.com/chef-cft/wombat/tree/v0.4.3) (2017-02-23)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.2...v0.4.3)

**Merged pull requests:**

- namespacery [\#304](https://github.com/chef-cft/wombat/pull/304) ([binamov](https://github.com/binamov))
- Release 0.4.2 [\#303](https://github.com/chef-cft/wombat/pull/303) ([binamov](https://github.com/binamov))

## [v0.4.2](https://github.com/chef-cft/wombat/tree/v0.4.2) (2017-02-23)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.1...v0.4.2)

**Merged pull requests:**

- namespace fix, unblocks bjc pipeline deploys [\#302](https://github.com/chef-cft/wombat/pull/302) ([binamov](https://github.com/binamov))

## [v0.4.1](https://github.com/chef-cft/wombat/tree/v0.4.1) (2017-02-23)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.4.0...v0.4.1)

**Closed issues:**

- can't build infranodes [\#299](https://github.com/chef-cft/wombat/issues/299)
- `wombat outputs` and azure [\#293](https://github.com/chef-cft/wombat/issues/293)

**Merged pull requests:**

- Release 0.4.1 [\#301](https://github.com/chef-cft/wombat/pull/301) ([cheeseplus](https://github.com/cheeseplus))
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

- Templatized kitchen-ec2 setups. [\#280](https://github.com/chef-cft/wombat/issues/280)
- Add Test Kitchen data to visibility [\#279](https://github.com/chef-cft/wombat/issues/279)
- Decrease data\_collector timeout during build [\#262](https://github.com/chef-cft/wombat/issues/262)
- Add in debug support for packer [\#260](https://github.com/chef-cft/wombat/issues/260)
- Add Visual Studio Code to installed programs [\#210](https://github.com/chef-cft/wombat/issues/210)
- AWS: Alias for latest AMI that looks it up [\#208](https://github.com/chef-cft/wombat/issues/208)

**Closed issues:**

- Wombat throws an error when building Infranodes but the packer command is OK [\#284](https://github.com/chef-cft/wombat/issues/284)
- Windows machines cannot be prepared for Azure after running cookbooks [\#278](https://github.com/chef-cft/wombat/issues/278)
- When building for Azure `packer` does not complete properly [\#277](https://github.com/chef-cft/wombat/issues/277)
- posh-git not installing correctly [\#274](https://github.com/chef-cft/wombat/issues/274)
- `wombat build` command should have an option to make AMIs public [\#271](https://github.com/chef-cft/wombat/issues/271)
- wombat.yml shouldn't be a hardcoded name [\#265](https://github.com/chef-cft/wombat/issues/265)
- AWS: Default Windows AMI is deprecated [\#203](https://github.com/chef-cft/wombat/issues/203)
- Azure: verify build process and add ARM template [\#43](https://github.com/chef-cft/wombat/issues/43)

**Merged pull requests:**

- Release 0.4.0 [\#291](https://github.com/chef-cft/wombat/pull/291) ([cheeseplus](https://github.com/cheeseplus))
- Adding Travis config and fixing spec tests [\#290](https://github.com/chef-cft/wombat/pull/290) ([cheeseplus](https://github.com/cheeseplus))
- Add new command`latest` for getting latest cloud images [\#289](https://github.com/chef-cft/wombat/pull/289) ([cheeseplus](https://github.com/cheeseplus))
- Refactor how source\_ami/image work [\#288](https://github.com/chef-cft/wombat/pull/288) ([cheeseplus](https://github.com/cheeseplus))
- Owner now defaults to USER from ENV [\#287](https://github.com/chef-cft/wombat/pull/287) ([russellseymour](https://github.com/russellseymour))
- Azure updates 2017-02-07 [\#286](https://github.com/chef-cft/wombat/pull/286) ([russellseymour](https://github.com/russellseymour))
- Creation and removal of stack within Azure [\#285](https://github.com/chef-cft/wombat/pull/285) ([russellseymour](https://github.com/russellseymour))
- fixes for changed automate api [\#283](https://github.com/chef-cft/wombat/pull/283) ([binamov](https://github.com/binamov))
- Modified IP range in Azure to match Wombat attributes [\#282](https://github.com/chef-cft/wombat/pull/282) ([russellseymour](https://github.com/russellseymour))
- Namespacing, break out crypto, and tests [\#281](https://github.com/chef-cft/wombat/pull/281) ([cheeseplus](https://github.com/cheeseplus))
- Fix posh-git PowerShell module loading [\#275](https://github.com/chef-cft/wombat/pull/275) ([nweddle](https://github.com/nweddle))
- Azure custom images [\#273](https://github.com/chef-cft/wombat/pull/273) ([russellseymour](https://github.com/russellseymour))
- Update Azure templates and add ARM ERB template [\#272](https://github.com/chef-cft/wombat/pull/272) ([cheeseplus](https://github.com/cheeseplus))
- Merging in changes from rjs-azure [\#269](https://github.com/chef-cft/wombat/pull/269) ([cheeseplus](https://github.com/cheeseplus))
- Make files\_dir toggleable and set default consistently [\#268](https://github.com/chef-cft/wombat/pull/268) ([cheeseplus](https://github.com/cheeseplus))
- add conf to infranodes path, remove repetition, fix typo [\#267](https://github.com/chef-cft/wombat/pull/267) ([andrewelizondo](https://github.com/andrewelizondo))
- add cli option, env variable, and default wombat.yml [\#266](https://github.com/chef-cft/wombat/pull/266) ([andrewelizondo](https://github.com/andrewelizondo))
- Re-enable .NET speed optimizations [\#264](https://github.com/chef-cft/wombat/pull/264) ([nweddle](https://github.com/nweddle))
- Rycar/reduce dc timeout [\#263](https://github.com/chef-cft/wombat/pull/263) ([ChefRycar](https://github.com/ChefRycar))
- Fixing path for files dir to be top-level everywhere [\#261](https://github.com/chef-cft/wombat/pull/261) ([cheeseplus](https://github.com/cheeseplus))
- Release 0.3.4 [\#258](https://github.com/chef-cft/wombat/pull/258) ([cheeseplus](https://github.com/cheeseplus))

## [v0.3.4](https://github.com/chef-cft/wombat/tree/v0.3.4) (2016-12-07)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.3...v0.3.4)

**Merged pull requests:**

- Cmder workaround workstation build [\#257](https://github.com/chef-cft/wombat/pull/257) ([andrewelizondo](https://github.com/andrewelizondo))
- aww yeah baby [\#256](https://github.com/chef-cft/wombat/pull/256) ([andrewelizondo](https://github.com/andrewelizondo))

## [v0.3.3](https://github.com/chef-cft/wombat/tree/v0.3.3) (2016-11-15)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.3.2...v0.3.3)

**Merged pull requests:**

- Prep 0.3.3 for release [\#254](https://github.com/chef-cft/wombat/pull/254) ([cheeseplus](https://github.com/cheeseplus))
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

## [v0.3.0](https://github.com/chef-cft/wombat/tree/v0.3.0) (2016-11-03)
[Full Changelog](https://github.com/chef-cft/wombat/compare/v0.2.1...v0.3.0)

**Closed issues:**

- Need ability to specify iam\_profile for the Windows workstation [\#240](https://github.com/chef-cft/wombat/issues/240)
- No multiple WS usernames in Automate server, Chef Server, or Compliance server [\#236](https://github.com/chef-cft/wombat/issues/236)
- ./wombat deploy bjc-demo fails if there are no logs in packer/logs [\#234](https://github.com/chef-cft/wombat/issues/234)
- remove hardcoded template names [\#231](https://github.com/chef-cft/wombat/issues/231)
- wombat-cli in rubygems needs a bump [\#230](https://github.com/chef-cft/wombat/issues/230)

**Merged pull requests:**

- Add init subcommand and become a real gem [\#244](https://github.com/chef-cft/wombat/pull/244) ([cheeseplus](https://github.com/cheeseplus))
- Add update command for lock and template [\#243](https://github.com/chef-cft/wombat/pull/243) ([cheeseplus](https://github.com/cheeseplus))
- Optionally apply IAM roles to workstations. Fix \#240 [\#242](https://github.com/chef-cft/wombat/pull/242) ([cheeseplus](https://github.com/cheeseplus))
- Make configuration truly optional [\#241](https://github.com/chef-cft/wombat/pull/241) ([cheeseplus](https://github.com/cheeseplus))

## [v0.2.1](https://github.com/chef-cft/wombat/tree/v0.2.1) (2016-10-19)
**Implemented enhancements:**

- Generate sample data and node backups for Compliance server [\#172](https://github.com/chef-cft/wombat/issues/172)
- Sort out how to copy license key to Delivery server [\#138](https://github.com/chef-cft/wombat/issues/138)
- Add bookmarks to Learn Chef tutorials on the workstation [\#126](https://github.com/chef-cft/wombat/issues/126)
- all packer templates should have the same variables, simplifying our rake commands [\#124](https://github.com/chef-cft/wombat/issues/124)
- Chef DK now includes Delivery CLI [\#123](https://github.com/chef-cft/wombat/issues/123)
- set FQDN in config for all server products [\#93](https://github.com/chef-cft/wombat/issues/93)

**Fixed bugs:**

- delivery: automate and viz bomb because /etc/hosts file is missing localhost [\#167](https://github.com/chef-cft/wombat/issues/167)
- Infranodes have invalid client config [\#117](https://github.com/chef-cft/wombat/issues/117)
- Extra AMIs are generated [\#116](https://github.com/chef-cft/wombat/issues/116)
- Infranodes aren't available for push jobs [\#110](https://github.com/chef-cft/wombat/issues/110)
- Cannot run push jobs on nodes from Windows workstation [\#108](https://github.com/chef-cft/wombat/issues/108)
- Windows workstation should have a Chef server config [\#99](https://github.com/chef-cft/wombat/issues/99)

**Closed issues:**

- How does this relate to the main Automate documentation? [\#229](https://github.com/chef-cft/wombat/issues/229)
- Support CentOS [\#217](https://github.com/chef-cft/wombat/issues/217)
- Add Cucumber tests [\#215](https://github.com/chef-cft/wombat/issues/215)
- Move keys to top level dir [\#211](https://github.com/chef-cft/wombat/issues/211)
- Building workstation image fails [\#204](https://github.com/chef-cft/wombat/issues/204)
- workstation: Upon first boot, .NET compiles all the things, leading to clunky experience [\#202](https://github.com/chef-cft/wombat/issues/202)
- Extract PSReadLine resource needs a guard [\#196](https://github.com/chef-cft/wombat/issues/196)
- include `keys:create` task in `packer:build\_ami\*` commands [\#188](https://github.com/chef-cft/wombat/issues/188)
- Abstract Common Functions to Wombat [\#182](https://github.com/chef-cft/wombat/issues/182)
- Infranodes have no tests [\#181](https://github.com/chef-cft/wombat/issues/181)
- Whats in a name? [\#180](https://github.com/chef-cft/wombat/issues/180)
- add workstation to hosts file [\#176](https://github.com/chef-cft/wombat/issues/176)
- The Great Automate Renaming [\#175](https://github.com/chef-cft/wombat/issues/175)
- chef-server::cheffish needs support for environments [\#169](https://github.com/chef-cft/wombat/issues/169)
- support multiple workstations [\#163](https://github.com/chef-cft/wombat/issues/163)
- Delivery should NOT delete its license [\#159](https://github.com/chef-cft/wombat/issues/159)
- s/delivery.license/automate.license [\#158](https://github.com/chef-cft/wombat/issues/158)
- Chef Server build breaks on v 12.8.0 [\#153](https://github.com/chef-cft/wombat/issues/153)
- Update Chrome bookmarks [\#150](https://github.com/chef-cft/wombat/issues/150)
- Sorting of infra breaks on an empty array [\#139](https://github.com/chef-cft/wombat/issues/139)
- Build nodes are not using the provided chefdk version attribute. [\#135](https://github.com/chef-cft/wombat/issues/135)
- Chef version not being used in bootstrap process [\#134](https://github.com/chef-cft/wombat/issues/134)
- Push jobs not configured in all environments [\#133](https://github.com/chef-cft/wombat/issues/133)
- workstation\_spec.rb failures [\#127](https://github.com/chef-cft/wombat/issues/127)
- Do initial CCR on infranodes during cloud-init [\#114](https://github.com/chef-cft/wombat/issues/114)
- Windows workstation: knife doesn't know what server\_url is [\#107](https://github.com/chef-cft/wombat/issues/107)
- etc-hosts recipe doesn't respect infranodes on windows [\#101](https://github.com/chef-cft/wombat/issues/101)
- CFN template contains invalid AMI IDs [\#96](https://github.com/chef-cft/wombat/issues/96)
- ordering in /etc/hosts matters for automatically setting FQDN [\#92](https://github.com/chef-cft/wombat/issues/92)
- Support multiple regions [\#91](https://github.com/chef-cft/wombat/issues/91)
- workstation has hardcoded hostsfile [\#84](https://github.com/chef-cft/wombat/issues/84)
- delivery and build-node cookbooks no longer allow for multiple build-nodes [\#75](https://github.com/chef-cft/wombat/issues/75)
- wombat.json is becoming overly complex [\#74](https://github.com/chef-cft/wombat/issues/74)
- Add cloudinit to CloudFormation instance resources [\#70](https://github.com/chef-cft/wombat/issues/70)
- Update Readme to reflect refactoring [\#69](https://github.com/chef-cft/wombat/issues/69)
- Add tests to build-node cookbook [\#67](https://github.com/chef-cft/wombat/issues/67)
- after renaming the delivery server to delivery, the cert is throwing a name mismatch [\#55](https://github.com/chef-cft/wombat/issues/55)
- instead of a cert for chef/delivery separately, we should just create a self signed star cert [\#54](https://github.com/chef-cft/wombat/issues/54)
- The Curious Case of License Keys [\#51](https://github.com/chef-cft/wombat/issues/51)
- Determine how to pre-load data [\#50](https://github.com/chef-cft/wombat/issues/50)
- Add virtualbox builder for packer [\#39](https://github.com/chef-cft/wombat/issues/39)
- Create acceptance node build [\#35](https://github.com/chef-cft/wombat/issues/35)
- Add chef compliance build [\#34](https://github.com/chef-cft/wombat/issues/34)
- Output artifact: CloudFormation template [\#28](https://github.com/chef-cft/wombat/issues/28)
- delivery\_builder: configure with cookbook [\#27](https://github.com/chef-cft/wombat/issues/27)
- Need to cleanup packer logs or not simply append [\#15](https://github.com/chef-cft/wombat/issues/15)

**Merged pull requests:**

- Release 0.2.1 [\#239](https://github.com/chef-cft/wombat/pull/239) ([cheeseplus](https://github.com/cheeseplus))
- Update readme to reflect new options [\#238](https://github.com/chef-cft/wombat/pull/238) ([cheeseplus](https://github.com/cheeseplus))
- Make updating the lock and template optional [\#237](https://github.com/chef-cft/wombat/pull/237) ([cheeseplus](https://github.com/cheeseplus))
- fixes multi-ws, multi-build-node cft generation [\#235](https://github.com/chef-cft/wombat/pull/235) ([binamov](https://github.com/binamov))
- Adjustable timeout [\#226](https://github.com/chef-cft/wombat/pull/226) ([cheeseplus](https://github.com/cheeseplus))
- Workstation builds based on  key [\#225](https://github.com/chef-cft/wombat/pull/225) ([cheeseplus](https://github.com/cheeseplus))
- Fixing parallel builds [\#224](https://github.com/chef-cft/wombat/pull/224) ([cheeseplus](https://github.com/cheeseplus))
- Fix linux infranodes, build, and logic refactor [\#223](https://github.com/chef-cft/wombat/pull/223) ([cheeseplus](https://github.com/cheeseplus))
- Instance resizing [\#222](https://github.com/chef-cft/wombat/pull/222) ([cheeseplus](https://github.com/cheeseplus))
- Windows infranodes GO [\#221](https://github.com/chef-cft/wombat/pull/221) ([cheeseplus](https://github.com/cheeseplus))
- Infranodes cookbook windows support [\#220](https://github.com/chef-cft/wombat/pull/220) ([cheeseplus](https://github.com/cheeseplus))
- Simplify build logic [\#219](https://github.com/chef-cft/wombat/pull/219) ([cheeseplus](https://github.com/cheeseplus))
- Adding CentOS support parity [\#218](https://github.com/chef-cft/wombat/pull/218) ([cheeseplus](https://github.com/cheeseplus))
- Remove errant cookbook [\#216](https://github.com/chef-cft/wombat/pull/216) ([cheeseplus](https://github.com/cheeseplus))
- Wombat has morphed into a RubyGem [\#213](https://github.com/chef-cft/wombat/pull/213) ([cheeseplus](https://github.com/cheeseplus))
- Fixes \#211 [\#212](https://github.com/chef-cft/wombat/pull/212) ([cheeseplus](https://github.com/cheeseplus))
- Update README.md [\#209](https://github.com/chef-cft/wombat/pull/209) ([andrewelizondo](https://github.com/andrewelizondo))
- All Hail Wombat [\#207](https://github.com/chef-cft/wombat/pull/207) ([cheeseplus](https://github.com/cheeseplus))
- Make .NET Great Again [\#206](https://github.com/chef-cft/wombat/pull/206) ([nweddle](https://github.com/nweddle))
- Move authorized keys functionality into Wombat cookbook [\#201](https://github.com/chef-cft/wombat/pull/201) ([cheeseplus](https://github.com/cheeseplus))
- Fix tests [\#200](https://github.com/chef-cft/wombat/pull/200) ([cheeseplus](https://github.com/cheeseplus))
- The PTY, we needs it [\#199](https://github.com/chef-cft/wombat/pull/199) ([cheeseplus](https://github.com/cheeseplus))
- Ask your doctor if Guards are right for you [\#198](https://github.com/chef-cft/wombat/pull/198) ([scarolan](https://github.com/scarolan))
- Adding support for GCE [\#193](https://github.com/chef-cft/wombat/pull/193) ([cheeseplus](https://github.com/cheeseplus))
- ensure we're using the correct local variable name [\#192](https://github.com/chef-cft/wombat/pull/192) ([andrewelizondo](https://github.com/andrewelizondo))
- fixes ssh for workstation-N users [\#190](https://github.com/chef-cft/wombat/pull/190) ([binamov](https://github.com/binamov))
- Fixing more rename fallout because I am a bad man [\#189](https://github.com/chef-cft/wombat/pull/189) ([cheeseplus](https://github.com/cheeseplus))
- add support for chef environments [\#187](https://github.com/chef-cft/wombat/pull/187) ([andrewelizondo](https://github.com/andrewelizondo))
- Suppress crt/key content [\#185](https://github.com/chef-cft/wombat/pull/185) ([cheeseplus](https://github.com/cheeseplus))
- Fixing serial and parallel build\_all tasks [\#184](https://github.com/chef-cft/wombat/pull/184) ([cheeseplus](https://github.com/cheeseplus))
- The road to hell is paved with dashes [\#183](https://github.com/chef-cft/wombat/pull/183) ([cheeseplus](https://github.com/cheeseplus))
- The Great Renaming [\#179](https://github.com/chef-cft/wombat/pull/179) ([cheeseplus](https://github.com/cheeseplus))
- Fix the install command for Windows [\#178](https://github.com/chef-cft/wombat/pull/178) ([cheeseplus](https://github.com/cheeseplus))
- Fixing compliance user [\#177](https://github.com/chef-cft/wombat/pull/177) ([cheeseplus](https://github.com/cheeseplus))
- Cleanup the variables across templates [\#174](https://github.com/chef-cft/wombat/pull/174) ([cheeseplus](https://github.com/cheeseplus))
- waffle.io Badge [\#173](https://github.com/chef-cft/wombat/pull/173) ([waffle-iron](https://github.com/waffle-iron))
- Fixes for multi workstation and cheffish permissions [\#171](https://github.com/chef-cft/wombat/pull/171) ([cheeseplus](https://github.com/cheeseplus))
- Cleaner hostsfile workaround - fixes \#167 [\#170](https://github.com/chef-cft/wombat/pull/170) ([cheeseplus](https://github.com/cheeseplus))
- Support multiple workstations [\#166](https://github.com/chef-cft/wombat/pull/166) ([cheeseplus](https://github.com/cheeseplus))
- Chocolately is enforcing security that not all packages abide by - temp fix [\#165](https://github.com/chef-cft/wombat/pull/165) ([cheeseplus](https://github.com/cheeseplus))
- Since we've changed the default domain, we need to regen keys [\#164](https://github.com/chef-cft/wombat/pull/164) ([cheeseplus](https://github.com/cheeseplus))
- Updating defaults and making naming simpler [\#162](https://github.com/chef-cft/wombat/pull/162) ([cheeseplus](https://github.com/cheeseplus))
- makes ssh\_key in kitchen path agnostic [\#161](https://github.com/chef-cft/wombat/pull/161) ([binamov](https://github.com/binamov))
- does not delete delivery.license, fixes \#159 [\#160](https://github.com/chef-cft/wombat/pull/160) ([binamov](https://github.com/binamov))
- fixes ~/.ssh/config for real this time [\#157](https://github.com/chef-cft/wombat/pull/157) ([binamov](https://github.com/binamov))
- More CloudFormation powers [\#156](https://github.com/chef-cft/wombat/pull/156) ([cheeseplus](https://github.com/cheeseplus))
- Fix rake aborting when infranodes: YAML key value is undefined [\#155](https://github.com/chef-cft/wombat/pull/155) ([nweddle](https://github.com/nweddle))
- add api\_fqdn to chef-server.rb [\#152](https://github.com/chef-cft/wombat/pull/152) ([andrewelizondo](https://github.com/andrewelizondo))
- fixes ~/.ssh/config for delivery [\#151](https://github.com/chef-cft/wombat/pull/151) ([binamov](https://github.com/binamov))
- Delete the license key [\#149](https://github.com/chef-cft/wombat/pull/149) ([tpetchel](https://github.com/tpetchel))
- Add bookmark to Learn Chef tutorial [\#148](https://github.com/chef-cft/wombat/pull/148) ([tpetchel](https://github.com/tpetchel))
- Copy the pub key to workstation [\#147](https://github.com/chef-cft/wombat/pull/147) ([cheeseplus](https://github.com/cheeseplus))
- Use the API [\#146](https://github.com/chef-cft/wombat/pull/146) ([cheeseplus](https://github.com/cheeseplus))
- Lazy load wombat cookbook artifacts [\#145](https://github.com/chef-cft/wombat/pull/145) ([andrewelizondo](https://github.com/andrewelizondo))
- add keys:create task to recipe [\#144](https://github.com/chef-cft/wombat/pull/144) ([andrewelizondo](https://github.com/andrewelizondo))
- simplify kitchen build, output artifacts into shared directory [\#143](https://github.com/chef-cft/wombat/pull/143) ([andrewelizondo](https://github.com/andrewelizondo))
- kitchenize our build process [\#142](https://github.com/chef-cft/wombat/pull/142) ([andrewelizondo](https://github.com/andrewelizondo))
- remove unneeded guards in packer\_build method [\#141](https://github.com/chef-cft/wombat/pull/141) ([andrewelizondo](https://github.com/andrewelizondo))
- Added if to sort to account for empty array. Updated readme with corr… [\#140](https://github.com/chef-cft/wombat/pull/140) ([ChefRycar](https://github.com/ChefRycar))
- sort when reading the rakefile [\#137](https://github.com/chef-cft/wombat/pull/137) ([andrewelizondo](https://github.com/andrewelizondo))
- change the do\_all command to update wombat.lock [\#136](https://github.com/chef-cft/wombat/pull/136) ([andrewelizondo](https://github.com/andrewelizondo))
- Set fqdn compliance [\#132](https://github.com/chef-cft/wombat/pull/132) ([andrewelizondo](https://github.com/andrewelizondo))
- Prepend channel in infranodes.json [\#131](https://github.com/chef-cft/wombat/pull/131) ([tpetchel](https://github.com/tpetchel))
- Use $CHANNEL-$VERSION [\#130](https://github.com/chef-cft/wombat/pull/130) ([cheeseplus](https://github.com/cheeseplus))
- Rycar/add domain prefix [\#129](https://github.com/chef-cft/wombat/pull/129) ([ChefRycar](https://github.com/ChefRycar))
- Fixup data\_collector [\#128](https://github.com/chef-cft/wombat/pull/128) ([tpetchel](https://github.com/tpetchel))
- add version of chefdk to build-node [\#125](https://github.com/chef-cft/wombat/pull/125) ([andrewelizondo](https://github.com/andrewelizondo))
- Update Push Jobs setup on infranodes, include config.d, vendor in infra/build-nodes [\#122](https://github.com/chef-cft/wombat/pull/122) ([andrewelizondo](https://github.com/andrewelizondo))
- move config.d under .chef [\#121](https://github.com/chef-cft/wombat/pull/121) ([andrewelizondo](https://github.com/andrewelizondo))
- quote it in case of spaces :D [\#120](https://github.com/chef-cft/wombat/pull/120) ([andrewelizondo](https://github.com/andrewelizondo))
- remove port and enterprise from data collector [\#119](https://github.com/chef-cft/wombat/pull/119) ([andrewelizondo](https://github.com/andrewelizondo))
- Fix data collector and correct node-name [\#118](https://github.com/chef-cft/wombat/pull/118) ([andrewelizondo](https://github.com/andrewelizondo))
- use grep on the log file to select a matching ami [\#113](https://github.com/chef-cft/wombat/pull/113) ([andrewelizondo](https://github.com/andrewelizondo))
- control admins group in cheffish, conf\_d directory on workstation [\#112](https://github.com/chef-cft/wombat/pull/112) ([andrewelizondo](https://github.com/andrewelizondo))
- we already have the etc-hosts information, make ssh config simpler [\#111](https://github.com/chef-cft/wombat/pull/111) ([andrewelizondo](https://github.com/andrewelizondo))
- Workstation cleanup, atom replaces vscode, remove scripts [\#106](https://github.com/chef-cft/wombat/pull/106) ([cheeseplus](https://github.com/cheeseplus))
- Couple of fixes to get basic vagrant install working [\#105](https://github.com/chef-cft/wombat/pull/105) ([irvingpop](https://github.com/irvingpop))
- Update default.rb [\#104](https://github.com/chef-cft/wombat/pull/104) ([andrewelizondo](https://github.com/andrewelizondo))
- update rake tasks, add auth keys [\#103](https://github.com/chef-cft/wombat/pull/103) ([andrewelizondo](https://github.com/andrewelizondo))
- fixed etc hosts for windows workstation [\#102](https://github.com/chef-cft/wombat/pull/102) ([andrewelizondo](https://github.com/andrewelizondo))
- Fixing knife.rb and a bookmark [\#100](https://github.com/chef-cft/wombat/pull/100) ([cheeseplus](https://github.com/cheeseplus))
- the great infra nodes war of 1812 [\#98](https://github.com/chef-cft/wombat/pull/98) ([andrewelizondo](https://github.com/andrewelizondo))
- Trim workstation install and have chef-server use wombat cookbook users [\#97](https://github.com/chef-cft/wombat/pull/97) ([cheeseplus](https://github.com/cheeseplus))
- Adding cmder config [\#95](https://github.com/chef-cft/wombat/pull/95) ([cheeseplus](https://github.com/cheeseplus))
- Fix fqdn with /etc/hosts ordering and allow user defined source\_amis [\#94](https://github.com/chef-cft/wombat/pull/94) ([cheeseplus](https://github.com/cheeseplus))
- Refactor workstation to indiv recipes [\#90](https://github.com/chef-cft/wombat/pull/90) ([cheeseplus](https://github.com/cheeseplus))
- Adding compliance to CFN template, misc fixes [\#89](https://github.com/chef-cft/wombat/pull/89) ([cheeseplus](https://github.com/cheeseplus))
- Cleanup build node recipes and use wombat cookbook [\#88](https://github.com/chef-cft/wombat/pull/88) ([cheeseplus](https://github.com/cheeseplus))
- Don't let the counting for build and infra nodes be clever, use fixed integer starting points [\#87](https://github.com/chef-cft/wombat/pull/87) ([cheeseplus](https://github.com/cheeseplus))
- Don't let the counting for build and infra nodes be clever, use fixed integer starting points [\#86](https://github.com/chef-cft/wombat/pull/86) ([cheeseplus](https://github.com/cheeseplus))
- Remove redundant .json file extension [\#85](https://github.com/chef-cft/wombat/pull/85) ([tpetchel](https://github.com/tpetchel))
- fixed cheffish for infranodes [\#83](https://github.com/chef-cft/wombat/pull/83) ([andrewelizondo](https://github.com/andrewelizondo))
- Cookbooking Chef-server and some re-org/fixes [\#82](https://github.com/chef-cft/wombat/pull/82) ([cheeseplus](https://github.com/cheeseplus))
- last minute fixes. [\#81](https://github.com/chef-cft/wombat/pull/81) ([andrewelizondo](https://github.com/andrewelizondo))
- All your codebase are belong to us. [\#80](https://github.com/chef-cft/wombat/pull/80) ([andrewelizondo](https://github.com/andrewelizondo))
- Separate out config and lock, refactor rakefile, update README [\#79](https://github.com/chef-cft/wombat/pull/79) ([cheeseplus](https://github.com/cheeseplus))
- Adding gemfile [\#78](https://github.com/chef-cft/wombat/pull/78) ([cheeseplus](https://github.com/cheeseplus))
- Moving cookbooks dir to toplevel, adding compliance cookbook [\#77](https://github.com/chef-cft/wombat/pull/77) ([cheeseplus](https://github.com/cheeseplus))
- Several fixes, wombat.json data reorg and rake cleanup [\#76](https://github.com/chef-cft/wombat/pull/76) ([cheeseplus](https://github.com/cheeseplus))
- Updating docs, fixes \#69 [\#73](https://github.com/chef-cft/wombat/pull/73) ([cheeseplus](https://github.com/cheeseplus))
- Delivery now configured with a cookbook. With tests. Rejoice. [\#72](https://github.com/chef-cft/wombat/pull/72) ([cheeseplus](https://github.com/cheeseplus))
- Now with user-data script action [\#71](https://github.com/chef-cft/wombat/pull/71) ([cheeseplus](https://github.com/cheeseplus))
- Sweet sweet integration tests [\#68](https://github.com/chef-cft/wombat/pull/68) ([cheeseplus](https://github.com/cheeseplus))
- lean into the cookbook [\#66](https://github.com/chef-cft/wombat/pull/66) ([cheeseplus](https://github.com/cheeseplus))
- Refactor the vendoring and fix a comment [\#65](https://github.com/chef-cft/wombat/pull/65) ([cheeseplus](https://github.com/cheeseplus))
- Don't overwrite keys if they already exist [\#64](https://github.com/chef-cft/wombat/pull/64) ([cheeseplus](https://github.com/cheeseplus))
- Removing keys from repo [\#63](https://github.com/chef-cft/wombat/pull/63) ([cheeseplus](https://github.com/cheeseplus))
- Various fixes, adding delivery-cli, moving inline PS to cookbook [\#62](https://github.com/chef-cft/wombat/pull/62) ([cheeseplus](https://github.com/cheeseplus))
- Generating certs/keys with ruby [\#61](https://github.com/chef-cft/wombat/pull/61) ([cheeseplus](https://github.com/cheeseplus))
- More renaming [\#60](https://github.com/chef-cft/wombat/pull/60) ([cheeseplus](https://github.com/cheeseplus))
- Add the ability to generate certs and keypair from rake and fix template [\#59](https://github.com/chef-cft/wombat/pull/59) ([cheeseplus](https://github.com/cheeseplus))
- More renaming for the renaming gods [\#58](https://github.com/chef-cft/wombat/pull/58) ([cheeseplus](https://github.com/cheeseplus))
- More renaming and minor fixes [\#57](https://github.com/chef-cft/wombat/pull/57) ([cheeseplus](https://github.com/cheeseplus))
- Im going to walk away slowly now [\#53](https://github.com/chef-cft/wombat/pull/53) ([andrewelizondo](https://github.com/andrewelizondo))
- update ssh\_config [\#52](https://github.com/chef-cft/wombat/pull/52) ([andrewelizondo](https://github.com/andrewelizondo))
- Cheffish acls and compliance stubs [\#49](https://github.com/chef-cft/wombat/pull/49) ([andrewelizondo](https://github.com/andrewelizondo))
- we spent so long thinking if we could, we never stopped to think if w… [\#48](https://github.com/chef-cft/wombat/pull/48) ([andrewelizondo](https://github.com/andrewelizondo))
- The Great Rename [\#47](https://github.com/chef-cft/wombat/pull/47) ([cheeseplus](https://github.com/cheeseplus))
- I shouldve tested it [\#46](https://github.com/chef-cft/wombat/pull/46) ([andrewelizondo](https://github.com/andrewelizondo))
- Updating docs for new commands and workflow [\#45](https://github.com/chef-cft/wombat/pull/45) ([cheeseplus](https://github.com/cheeseplus))
- Adding timestamps to create stack names [\#44](https://github.com/chef-cft/wombat/pull/44) ([cheeseplus](https://github.com/cheeseplus))
- An attempt to make the rake UX clearer [\#42](https://github.com/chef-cft/wombat/pull/42) ([cheeseplus](https://github.com/cheeseplus))
- Rake can now create a CFN stack, light refactoring [\#41](https://github.com/chef-cft/wombat/pull/41) ([cheeseplus](https://github.com/cheeseplus))
- Use env vars to drive as much as possible for Packer [\#40](https://github.com/chef-cft/wombat/pull/40) ([cheeseplus](https://github.com/cheeseplus))
- Fix apt, jq, and vendor dirs [\#37](https://github.com/chef-cft/wombat/pull/37) ([cheeseplus](https://github.com/cheeseplus))
- preload trusted\_certs and client.rb [\#36](https://github.com/chef-cft/wombat/pull/36) ([andrewelizondo](https://github.com/andrewelizondo))
- Now with 100% more cloudformation [\#33](https://github.com/chef-cft/wombat/pull/33) ([cheeseplus](https://github.com/cheeseplus))
- Fix knife paths [\#32](https://github.com/chef-cft/wombat/pull/32) ([cheeseplus](https://github.com/cheeseplus))
- I only had to sacrifice my firstborn to get it working [\#31](https://github.com/chef-cft/wombat/pull/31) ([andrewelizondo](https://github.com/andrewelizondo))
- remove os type, take the default instead for unix [\#30](https://github.com/chef-cft/wombat/pull/30) ([andrewelizondo](https://github.com/andrewelizondo))
- After manually rotating the heavy machinery, the worker grew very cra… [\#29](https://github.com/chef-cft/wombat/pull/29) ([andrewelizondo](https://github.com/andrewelizondo))
- Fixing missing template\_dir calls [\#26](https://github.com/chef-cft/wombat/pull/26) ([cheeseplus](https://github.com/cheeseplus))
- Don't associate public IPs for anything other than workstation [\#25](https://github.com/chef-cft/wombat/pull/25) ([cheeseplus](https://github.com/cheeseplus))
- Abstracting out versions to common manifest [\#24](https://github.com/chef-cft/wombat/pull/24) ([cheeseplus](https://github.com/cheeseplus))
- Readmes are cool [\#23](https://github.com/chef-cft/wombat/pull/23) ([cheeseplus](https://github.com/cheeseplus))
- removing tfvars and setting defaults in plan [\#22](https://github.com/chef-cft/wombat/pull/22) ([cheeseplus](https://github.com/cheeseplus))
- Updating rakefile to include other TF commands [\#21](https://github.com/chef-cft/wombat/pull/21) ([cheeseplus](https://github.com/cheeseplus))
- ensure mocked data for certs is placed on systems [\#20](https://github.com/chef-cft/wombat/pull/20) ([andrewelizondo](https://github.com/andrewelizondo))
- Adding delivery cert and lying to Root CA [\#19](https://github.com/chef-cft/wombat/pull/19) ([cheeseplus](https://github.com/cheeseplus))
- Making the key copy a common script, fixing user creation on chef-server [\#18](https://github.com/chef-cft/wombat/pull/18) ([cheeseplus](https://github.com/cheeseplus))
- Adding workstation cookbook [\#17](https://github.com/chef-cft/wombat/pull/17) ([cheeseplus](https://github.com/cheeseplus))
- More optimal hostname shenanigans [\#16](https://github.com/chef-cft/wombat/pull/16) ([cheeseplus](https://github.com/cheeseplus))
- Fixed weird BOM in ssh key \(regeneratedd\) and renaming [\#14](https://github.com/chef-cft/wombat/pull/14) ([cheeseplus](https://github.com/cheeseplus))
- Render tfvars [\#13](https://github.com/chef-cft/wombat/pull/13) ([andrewelizondo](https://github.com/andrewelizondo))
- Add azure [\#12](https://github.com/chef-cft/wombat/pull/12) ([andrewelizondo](https://github.com/andrewelizondo))
- The rakening [\#11](https://github.com/chef-cft/wombat/pull/11) ([cheeseplus](https://github.com/cheeseplus))
- Refactoring delivery install and adding keys via API [\#10](https://github.com/chef-cft/wombat/pull/10) ([cheeseplus](https://github.com/cheeseplus))
- Copy the delivery license to packer instance [\#9](https://github.com/chef-cft/wombat/pull/9) ([cheeseplus](https://github.com/cheeseplus))
- updated build [\#8](https://github.com/chef-cft/wombat/pull/8) ([andrewelizondo](https://github.com/andrewelizondo))
- Switching to using Atlas box [\#7](https://github.com/chef-cft/wombat/pull/7) ([cheeseplus](https://github.com/cheeseplus))
- yer a wizard harry [\#6](https://github.com/chef-cft/wombat/pull/6) ([andrewelizondo](https://github.com/andrewelizondo))
- kent geeet [\#5](https://github.com/chef-cft/wombat/pull/5) ([andrewelizondo](https://github.com/andrewelizondo))
- All the things [\#4](https://github.com/chef-cft/wombat/pull/4) ([andrewelizondo](https://github.com/andrewelizondo))
- Packer and terraform - first pass [\#3](https://github.com/chef-cft/wombat/pull/3) ([cheeseplus](https://github.com/cheeseplus))
- Use networks that don't collide with other hypervisors [\#2](https://github.com/chef-cft/wombat/pull/2) ([cheeseplus](https://github.com/cheeseplus))
- add vagrant cachier [\#1](https://github.com/chef-cft/wombat/pull/1) ([andrewelizondo](https://github.com/andrewelizondo))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
