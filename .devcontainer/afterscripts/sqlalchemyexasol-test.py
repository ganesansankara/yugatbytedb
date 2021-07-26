import pyodbc
import pyexasol
from sqlalchemy import create_engine

def listODBCDrivers():
    print("List of ODBC Drivers:")
    dlist = pyodbc.drivers()
    for drvr in dlist:
        print(drvr)
    print("End of List")

def testExasol():
    C = pyexasol.connect(dsn='DEMODB.EXASOL.COM:8563', user='PUB3715', password='NbMCCidzA', compression=True)
    df = C.export_to_pandas("SELECT * FROM EXA_ALL_USERS")
    print(df.head())


def testSQLAlchemyExasol():
    e = create_engine("exa+pyodbc://PUB3715:NbMCCidzA@DEMODB.EXASOL.COM:8563/PUB3715?CONNECTIONLCALL=en_US.UTF-8&DRIVER=/usr/lib/x86_64-linux-gnu/libexaodbc-uo2214lv2.so")
    r = e.execute("select 42 from dual").fetchall()
    print ( r )

#testExasol()
listODBCDrivers()
testSQLAlchemyExasol()