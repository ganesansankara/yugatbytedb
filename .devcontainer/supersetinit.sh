pip3 install apache-superset
pip3 install pyexasol

#SQLALCHEMY needs unixodbc. Please not use apt to install. Do not use apt-get
sudo apt-get update &&  apt update && apt install -y unixodbc unixodbc-dev

#Install exasol ODBC Driver first
export odbcfile=exasol-odbc.tar.gz
curl https://www.exasol.com/support/secure/attachment/155337/EXASOL_ODBC-7.0.11.tar.gz --output ${odbcfile}
( cp ${odbcfile} /tmp; cd /tmp; tar -xzf ${odbcfile})

# Execute the script config_odbc ...
(cd  /tmp/EXASolution_ODBC-*; ./config_odbc --mode config --force --host DEMODB.EXASOL.COM --user PUB3715 --password=NbMCCidzA )
sudo cp EXASolution_ODBC-7.0.11/lib/linux/x86_64/*  /usr/lib/x86_64-linux-gnu/

# Test script
python sqlalchemyexasol-test

# Install sqlalchmey package for exasol next
pip3 install  sqlalchemy-exasol

superset db upgrade
superset fab create-admin \
               --username admin \
               --password admin \
               --firstname Superset \
               --lastname Admin \
               --email admin@superset.com 
superset init

superset run -h 0.0.0.0 -p 8080

#exa+pyodbc://PUB3715:NbMCCidzA@DEMODB.EXASOL.COM:8563/PUB3715?CONNECTIONLCALL=en_US.UTF-8&driver=/usr/lib/x86_64-linux-gnu/libexaodbc-uo2214lv2.so