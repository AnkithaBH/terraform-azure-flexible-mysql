<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AZURE FLEXIBLE MYSQL
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create flexible-mysql resource on AZURE.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.1.7-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-azure-flexible-mysql'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AZURE+FLEXIBLE+MYSQL&url=https://github.com/clouddrove/terraform-azure-flexible-mysql'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AZURE+FLEXIBLE+MYSQL&url=https://github.com/clouddrove/terraform-azure-flexible-mysql'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-azure-flexible-mysql/releases).


### Simple Example
Here is an example of how you can use this module in your inventory structure:
```hcl
module "flexible-mysql" {
 source                          = "clouddrove/flexible-mysql/azure"
 name                            = "app"
 environment                     = "test"
 label_order                     = ["environment", "name"]
 resource_group_name             = module.resource_group.resource_group_name
 location                        = module.resource_group.resource_group_location
 virtual_network_id              = module.vnet.vnet_id[0]
 delegated_subnet_id             = module.subnet.default_subnet_id[0]
 mysql_version                   = "8.0.21"
 mysql_server_name               = "testmysqlserver"
 private_dns                     = true
 zone                            = "1"
 admin_username                  = "mysqlusername"
 admin_password                  = "ba5yatgfgfhdsv6A3ns2lu4gqzzc"
 sku_name                        = "GP_Standard_D8ds_v4"
 db_name                         = "maindb"
 charset                         = "utf8"
 collation                       = "utf8_unicode_ci"
 server_configuration_name       = "interactive_timeout"
 auto_grow_enabled               = true
 iops                            = 360
 size_gb                         = "20"
 }
  ```
##for mysql replication
  ```hcl
module "flexible-mysql" {
 source                          = "clouddrove/flexible-mysql/azure"
 name                            = "app"
 environment                     = "test"
 label_order                     = ["environment", "name"]
 main_rg_name                    = data.azurerm_resource_group.main.name
 resource_group_name             = module.resource_group.resource_group_name
 location                        = module.resource_group.resource_group_location
 virtual_network_id              = module.vnet.vnet_id[0]
 delegated_subnet_id             = module.subnet.default_subnet_id[0]
 mysql_version                   = "8.0.21"
 mysql_server_name               = "testmysqlserver"
 zone                            = "1"
 admin_username                  = "mysqlusern"
 admin_password                  = "ba5yatgfgfhdsvvc6A3ns2lu4gqzzc"
 sku_name                        = "GP_Standard_D8ds_v4"
 db_name                         = "maindb"
 charset                         = "utf8"
 collation                       = "utf8_unicode_ci"
 server_configuration_name       = "interactive_timeout"
 auto_grow_enabled               = true
 iops                            = 360
 size_gb                         = "20"
 existing_private_dns_zone       = true
 existing_private_dns_zone_id    = data.azurerm_private_dns_zone.main.id
 existing_private_dns_zone_name  = data.azurerm_private_dns_zone.main.name
 }
  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | The password associated with the admin\_username user | `string` | `null` | no |
| admin\_username | The administrator login name for the new SQL Server | `any` | `null` | no |
| auto\_grow\_enabled | Should Storage Auto Grow be enabled? Defaults to true. | `bool` | `false` | no |
| backup\_retention\_days | The backup retention days for the MySQL Flexible Server. Possible values are between 1 and 35 days. Defaults to 7 | `number` | `7` | no |
| charset | Specifies the Charset for the MySQL Database, which needs to be a valid MySQL Charset. Changing this forces a new resource to be created. | `string` | `""` | no |
| collation | Specifies the Collation for the MySQL Database, which needs to be a valid MySQL Collation. Changing this forces a new resource to be created. | `string` | `""` | no |
| create\_mode | The creation mode. Can be used to restore or replicate existing servers. Possible values are `Default`, `Replica`, `GeoRestore`, and `PointInTimeRestore`. Defaults to `Default` | `string` | `"Default"` | no |
| db\_name | Specifies the name of the MySQL Database, which needs to be a valid MySQL identifier. Changing this forces a new resource to be created. | `string` | `""` | no |
| delegated\_subnet\_id | The resource ID of the subnet | `string` | `""` | no |
| enable\_private\_endpoint | Manages a Private Endpoint to Azure database for MySQL | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| end\_ip\_address | n/a | `string` | `""` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| existing\_private\_dns\_zone | Name of the existing private DNS zone | `bool` | `false` | no |
| existing\_private\_dns\_zone\_id | n/a | `string` | `""` | no |
| existing\_private\_dns\_zone\_name | The name of the Private DNS zone (without a terminating dot). Changing this forces a new resource to be created. | `string` | `""` | no |
| geo\_redundant\_backup\_enabled | Should geo redundant backup enabled? Defaults to false. Changing this forces a new MySQL Flexible Server to be created. | `bool` | `false` | no |
| iops | The storage IOPS for the MySQL Flexible Server. Possible values are between 360 and 20000. | `number` | `360` | no |
| key\_vault\_id | Specifies the URL to a Key Vault Key (either from a Key Vault Key, or the Key URL for the Key Vault Secret | `string` | `""` | no |
| key\_vault\_key\_id | The URL to a Key Vault Key | `string` | `null` | no |
| label\_order | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | `[]` | no |
| location | The Azure Region where the MySQL Flexible Server should exist. Changing this forces a new MySQL Flexible Server to be created. | `string` | `""` | no |
| main\_rg\_name | n/a | `string` | `""` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| mysql\_server\_name | n/a | `string` | `""` | no |
| mysql\_version | The version of the MySQL Flexible Server to use. Possible values are 5.7, and 8.0.21. Changing this forces a new MySQL Flexible Server to be created. | `string` | `"5.7"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| point\_in\_time\_restore\_time\_in\_utc | The point in time to restore from creation\_source\_server\_id when create\_mode is PointInTimeRestore. Changing this forces a new MySQL Flexible Server to be created. | `string` | `null` | no |
| private\_dns | n/a | `bool` | `false` | no |
| registration\_enabled | Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled | `bool` | `false` | no |
| replication\_role | The replication role. Possible value is None. | `string` | `null` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | A container that holds related resources for an Azure solution | `string` | `""` | no |
| server\_configuration\_name | Specifies the name of the MySQL Flexible Server Configuration, which needs to be a valid MySQL configuration name. Changing this forces a new resource to be created. | `string` | `""` | no |
| size\_gb | The max storage allowed for the MySQL Flexible Server. Possible values are between 20 and 16384. | `string` | `"20"` | no |
| sku\_name | The SKU Name for the MySQL Flexible Server. | `string` | `"GP_Standard_D8ds_v4"` | no |
| source\_server\_id | The resource ID of the source MySQL Flexible Server to be restored. Required when create\_mode is PointInTimeRestore, GeoRestore, and Replica. Changing this forces a new MySQL Flexible Server to be created. | `string` | `null` | no |
| start\_ip\_address | n/a | `string` | `""` | no |
| value | Specifies the value of the MySQL Flexible Server Configuration. See the MySQL documentation for valid values. Changing this forces a new resource to be created. | `string` | `"600"` | no |
| virtual\_network\_id | The name of the virtual network | `string` | `""` | no |
| zone | Specifies the Availability Zone in which this MySQL Flexible Server should be located. Possible values are 1, 2 and 3. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_mysql\_flexible\_server\_configuration\_id | The ID of the MySQL Flexible Server Configuration. |
| azurerm\_private\_dns\_zone\_id | The Private DNS Zone ID. |
| azurerm\_private\_dns\_zone\_virtual\_network\_link\_id | The ID of the Private DNS Zone Virtual Network Link. |
| existing\_private\_dns\_zone\_virtual\_network\_link\_id | The ID of the Private DNS Zone Virtual Network Link. |
| mysql\_flexible\_server\_id | The ID of the MySQL Flexible Server. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-azure-flexible-mysql/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-azure-flexible-mysql)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
