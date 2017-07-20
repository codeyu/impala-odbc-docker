# impala-odbc-docker

Impala在线文档介绍了 Impala ODBC接口安装和配置

http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/Impala/Installing-and-Using-Impala/ciiu_impala_odbc.html

Impala ODBC 驱动下载地址：

http://www.cloudera.com/content/support/en/downloads/connectors.html

本文详细讲解了CentOS-6.5-x86_64环境下 Impala ODBC的安装和使用。

### 检查unixODBC是否安装

如果没有安装，使用下面的命令安装：
```sh
yum install unixODBC

yum install unixODBC-devel
```
使用odbcinst命令查看unixODBC配置文件路径，不同版本的unixODBC配置文件路径是不同的，如果是源代码方式安装unixODBC，也可以通过编译参数--sysconfdir指定。
```sh
[root@h1 ~]# odbcinst -j
unixODBC 2.2.14
DRIVERS............: /etc/odbcinst.ini
SYSTEM DATA SOURCES: /etc/odbc.ini
FILE DATA SOURCES..: /etc/ODBCDataSources
USER DATA SOURCES..: /root/.odbc.ini
SQLULEN Size.......: 8
SQLLEN Size........: 8
SQLSETPOSIROW Size.: 8
```
### 安装Impala ODBC驱动

下载 ClouderaImpalaODBC-2.5.15.1015-1.el6.x86_64.rpm，保存到：/home/soft 目录，并进行安装：
```sh
[root@h1 soft]# ll
total 16232
-rw-r--r--. 1 root root 16619934 Aug 24 06:37 ClouderaImpalaODBC-2.5.15.1015-1.el6.x86_64.rpm
[root@h1 soft]# rpm -ivh ClouderaImpalaODBC-2.5.15.1015-1.el6.x86_64.rpm 
Preparing...                ########################################### [100%]
   1:ClouderaImpalaODBC     ########################################### [100%]
[root@h1 soft]#
```
安装完成后的文件在：/opt/cloudera/impalaodbc 目录，这个目录包含了安装文档、lib包、配置文件示例。
```sh
[root@h1 impalaodbc]# pwd
/opt/cloudera/impalaodbc
[root@h1 impalaodbc]# ll
total 1016
-rwxr-xr-x. 1 root root 1007048 Apr 21 12:21 Cloudera ODBC Driver for Impala Install Guide.pdf
-rwxr-xr-x. 1 root root   12003 Apr 21 12:21 Cloudera-EULA.txt
drwxr-xr-x. 3 root root    4096 Aug 24 07:15 ErrorMessages
-rwxr-xr-x. 1 root root    3261 Apr 21 12:21 Readme.txt
-rwxr-xr-x. 1 root root    2350 Apr 21 12:21 Release Notes.txt
drwxr-xr-x. 2 root root    4096 Aug 24 07:15 Setup
drwxr-xr-x. 3 root root    4096 Aug 24 07:15 lib
[root@h1 impalaodbc]#
```
设置驱动的环境变量：

在 `/etc/profile` 最后添加：
```sh
export LD_LIBRARY_PATH=/usr/local/lib:/opt/cloudera/impalaodbc/lib/64
```
然后执行：`source /etc/profile`

使修改的脚本立即生效。

拷贝：`cloudera.impalaodbc.ini` 到 `/etc/`目录：
```sh
[root@h1 Setup]# pwd
/opt/cloudera/impalaodbc/Setup
[root@h1 Setup]# cp cloudera.impalaodbc.ini /etc/
[root@h1 Setup]#
```
修改：`/etc/cloudera.impalaodbc.ini` 中的如下条目：
```
# Generic ODBCInstLib
#   iODBC
#ODBCInstLib=libiodbcinst.so

#   SimbaDM / unixODBC
ODBCInstLib=libodbcinst.so
```
也就是说不使用iODBC , 使用 unixODBC

### 修改/etc/odbc.ini 文件

参照 /opt/cloudera/impalaodbc/Setup/odbc.ini ,修改：/etc/odbc.ini 文件。修改后的odbc.ini如下：
```
[impalaodbc]

# Description: DSN Description.
# This key is not necessary and is only to give a description of the data source.
Description=Cloudera ODBC Driver for Impala (64-bit) DSN

# Driver: The location where the ODBC driver is installed to.
Driver=/opt/cloudera/impalaodbc/lib/64/libclouderaimpalaodbc64.so

# The DriverUnicodeEncoding setting is only used for SimbaDM
# When set to 1, SimbaDM runs in UTF-16 mode.
# When set to 2, SimbaDM runs in UTF-8 mode.
#DriverUnicodeEncoding=2

# Values for HOST, PORT, KrbFQDN, and KrbServiceName should be set here.
# They can also be specified on the connection string.
HOST=172.16.230.152
PORT=21050
Database=default

# The authentication mechanism.
# 0 - no authentication.
# 1 - Kerberos authentication
# 2 - Username authentication.
# 3 - Username/password authentication.
# 4 - Username/password authentication with SSL.
AuthMech=0

# Kerberos related settings.
KrbFQDN=
KrbRealm=
KrbServiceName=

# Username/password authentication with SSL settings.
UID=
PWD=
CAIssuedCertNamesMismatch=1
TrustedCerts=/opt/cloudera/impalaodbc/lib/64/cacerts.pem

# Specify the proxy user ID to use.
#DelegationUID=

# General settings
TSaslTransportBufSize=1000
RowsFetchedPerBlock=1000
SocketTimeout=0
StringColumnLength=32767
UseNativeQuery=0
```
### 验证安装是否成功

执行 `isql -v impalaodbc`
```sh
[root@h1 ~]# isql -v impalaodbc
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL> select * from tab1;
[S1000][unixODBC][Cloudera][ImpalaODBC] (110) Error while executing a query in Impala: [HY000] : Error: Error: could not match input
[ISQL]ERROR: Could not SQLPrepare
SQL> select * from tab1 
+------------+------+-------------------------+------------------------------+
| id         | col_1| col_2                   | col_3                        |
+------------+------+-------------------------+------------------------------+
| 1          | 1    | 123.123                 | 2012-10-24 08:55:00          |
| 2          | 0    | 1243.5                  | 2012-10-25 13:40:00          |
| 3          | 0    | 24453.325               | 2008-08-22 09:33:21.123000000|
| 4          | 0    | 243423.325              | 2007-05-12 22:32:21.334540000|
| 5          | 1    | 243.325                 | 1953-04-22 09:11:33          |
+------------+------+-------------------------+------------------------------+
SQLRowCount returns -1
5 rows fetched
```
注意：执行的sql最后不要加封号。

这样配置后，C/C++程序就可以通过unixODBC访问Impala中的数据了。

### License问题

默认安装的Impala ODBC是评估版的，需要购买license，参见安装文档 Cloudera ODBC Driver for Impala Install Guide.pdf 中的这样一段话：

> If you are installing a driver with an evaluation license and you have purchased a perpetual license, then copy the License.lic file you received via e-mail into the /opt/cloudera/impalaodbc/lib/32 or /opt/cloudera/impalaodbc/lib/64 folder, depending on the version of the driver you installed.

评估时为多长时间，目前还没找到答案。或者让你一直评估吧：）