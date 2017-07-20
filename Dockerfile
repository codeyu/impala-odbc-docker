FROM ubuntu:14.04

MAINTAINER codeyu@gmail.com
//https://downloads.cloudera.com/connectors/impala_odbc_2.5.39.1020/Linux/SLES11/ClouderaImpalaODBC-2.5.39.1020-1.x86_64.rpm
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install unixodbc
RUN apt-get install unixodbc-dev
RUN apt-get install alien dpkg-dev debhelper build-essential
ADD ClouderaImpalaODBC-2.5.26.1027-1.x86_64.rpm 
RUN alien ClouderaImpalaODBC-2.5.26.1027-1.x86_64.rpm
RUN adpkg -i clouderaimpalaodbc_2.5.26.1027-2_amd64.deb

ADD impala_env.sh /etc/profile.d/

RUN source /etc/profile.d/impala_env.sh

RUN odbcinst -j

ADD odbc.ini /etc/

ADD odbcinst.ini /etc/

RUN isql -v Sample_Cloudera_Impala_DSN_64


