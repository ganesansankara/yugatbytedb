#!/bin/bash

pip3 install apache-superset
pip3 install pyexasol

#SQLALCHEMY needs unixodbc. Please not use apt to install. Do not use apt-get
# already done in dockerfile
#sudo apt-get update &&  sudo apt update && sudo apt install -y unixodbc unixodbc-dev

#Install exasol ODBC Driver first
export odbcfile=exasol-odbc.tar.gz
#curl https://www.exasol.com/support/secure/attachment/155337/EXASOL_ODBC-7.0.11.tar.gz --output ${odbcfile}
#cp ${odbcfile} /tmp;
#.gz file copied in DockerFile

# Execute the script config_odbc ...
tar -xzf ${odbcfile}
(cd  EXASolution_ODBC-*; ./config_odbc --mode config --force --host DEMODB.EXASOL.COM --user PUB3715 --password=NbMCCidzA )
sudo cp EXASolution_ODBC-7.0.11/lib/linux/x86_64/*  /usr/lib/x86_64-linux-gnu/
cp home_odbc.ini ~/.odbc.ini # copy to vscode user home dir

# Install sqlalchmey package for exasol next
pip3 install sqlalchemy-exasol