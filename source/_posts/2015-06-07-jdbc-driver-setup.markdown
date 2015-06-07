---
layout: post
title: "JDBC Driver Setup"
date: 2015-06-07 16:20
comments: true
categories: jboss wildfly console jdbc
---
The installation of JDBC drivers and the setup of (xa)datasources is a common task for every JEE developer and administrator. This post describes the installation and setup of a MySQL driver and datasource using WildFly 9 in both standalone and domain mode. If you use another database, you'll probably go through the same steps, but using different parameters.<!-- more -->
 
 When installing a driver you basically have two options: install it as module or deploy it like any other application package. However when running domain mode you should choose to install the driver as module. Otherwise the driver won't be recognized by the `:installed-drivers-list` operation. Drivers deployed as application packages need a running server, which cannot be guaranteed in domain mode. Thus the recommendation is to *always* use the module option in domain mode. For standalone mode you are free to choose between module and deployment since both options will work. 
 
# Install as Module

1. Download the driver from the [MySQL website](https://dev.mysql.com/downloads/connector/j/)
1. Go to `WILDFLY_HOME/modules/system/layers/base/com` and create the folder `mysql/main`
1. Unzip the downloaded file and copy the file `mysql-connector-java-5.1.23-bin.jar` to the new folder `WILDFLY_HOME/modules/system/layers/base/com/mysql/main`
1. Create the file `module.xml` in the same folder with the following content:

```xml
<module xmlns="urn:jboss:module:1.3" name="com.mysql">
    <resources>
        <resource-root path="mysql-connector-java-5.1.35-bin.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>
```
        
The name of the driver file may vary, so make sure you declare exactly the same name in the `resource-root` tag. After restarting WildFly the module is available and can be referenced to create a JDBC driver. Open the CLI and execute the following command for standalone mode:

```
[standalone@localhost:9990 /] /subsystem=datasources/jdbc-driver=mysql:add(\
    driver-name=mysql,\
    driver-module-name=com.mysql,\
    driver-class-name=com.mysql.jdbc.Driver,\
    driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource\
)
``` 

and this command if you're using domain mode: 


```
[domain@localhost:9990 /] /profile=full/subsystem=datasources/jdbc-driver=mysql:add(\
    driver-name=mysql,\
    driver-module-name=com.mysql,\
    driver-class-name=com.mysql.jdbc.Driver,\
    driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource\
)
``` 

# Install as Deployment

Please note that this option is only valid for JDBC4 compliant drivers. For none JDBC4 compliant drivers you should install the driver as a module. Furthermore it's not recommended for the domain mode.     

1. Download the driver from the [MySQL website](https://dev.mysql.com/downloads/connector/j/)
1. Unzip the downloaded file and deploy and enable the file `mysql-connector-java-5.1.23-bin.jar`
 
The contained JDBC drivers will be automatically detected and registered (no need to execute additional management operations).

# Setup a Datasource

In order to setup a datasource open the management console and navigate to "Configuration / (Profile ...) / Datasources" and click "Add" to bring up the wizard for creating a (XA) datasource. The console already contains templates for the most common databases. The templates combine settings like connection url, validation checker and exception sorter implementations. Choose "MySQL Datasource" and adjust the settings as necessary. You should see the JDBC driver you've installed as module or deployment in the "JDBC Driver" step under "Detected Driver".  Before you exit the wizard you can test the connection using the button on the final step.  

If you prefer to use the CLI to create the datasource use a command like this one (leave out `/profile=full` for standalone mode):

```
[domain@localhost:9990 /] /profile=full/subsystem=datasources/data-source=MySqlDS:add(\
    jndi-name=java:/MySqlDS,\
    driver-name=mysql,\
    connection-url=jdbc:mysql://localhost:3306/test
)
```

However please note that you have to configure database specific settings like validation checker et al by yourself. 

# Use the Datasource

When running domain mode, the datasource is always bound to a profile and thus accessible by servers which are part of a server group which in turn uses that profile. 

To access the datasource in your JEE app, use the JNDI name. Here's an example of a JPA configuration:

```xml
<persistence-unit name="app-pu" transaction-type="JTA">
    <jta-data-source>java:/MySqlDS</jta-data-source>
    <exclude-unlisted-classes>false</exclude-unlisted-classes>
    <properties/>
</persistence-unit>
```

and here an example for a resource injection:

```java
public class SomeClass {
    @Resource(name = "java:/MySqlDS")
    private javax.sql.DataSource dataSource;
}
```
