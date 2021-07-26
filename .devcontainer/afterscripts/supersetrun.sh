#!/bin/bash
superset db upgrade
superset fab create-admin \
               --username admin \
               --password admin \
               --firstname Superset \
               --lastname Admin \
               --email admin@superset.com 
superset init

# Test script
python sqlalchemyexasol-test.py

superset run -h 0.0.0.0 -p 8080

#exa+pyodbc://PUB3715:NbMCCidzA@DEMODB.EXASOL.COM:8563/PUB3715?CONNECTIONLCALL=en_US.UTF-8&driver=/usr/lib/x86_64-linux-gnu/libexaodbc-uo2214lv2.so