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

def testSQLAlchemyExasol2():
    e = create_engine("exa+pyodbc://PUB3715:NbMCCidzA@exasolution-uo2214lv2_64")
    r = e.execute("select 42 from dual").fetchall()
    print ( r )

def testSQLAlchemyExasol(odbcurl):
    print(f'Testing odbcurl=={odbcurl}')
    e = create_engine(odbcurl)
    r = e.execute("select 42 from dual").fetchall()
    print ( r )

#testExasol()
listODBCDrivers()

print ('TESTING DSN based URL..DSN to be present in ~/.odbc.ini' )
testSQLAlchemyExasol("exa+pyodbc://PUB3715:NbMCCidzA@exasolution-uo2214lv2_64")
testSQLAlchemyExasol("exa+pyodbc://PUB3715:NbMCCidzA@exasolution-uo2214lv2_64?CONNECTIONLCALL=en_US.UTF-8")

testSQLAlchemyExasol("exa+pyodbc://PUB3715:NbMCCidzA@EXAODBC")
testSQLAlchemyExasol("exa+pyodbc://PUB3715:NbMCCidzA@EXODBC?CONNECTIONLCALL=en_US.UTF-8")



print ('TESTING WITHOUT DSN based URL..')

testSQLAlchemyExasol("exa+pyodbc://PUB3715:NbMCCidzA@DEMODB.EXASOL.COM:8563/PUB3715?CONNECTIONLCALL=en_US.UTF-8&DRIVER=/usr/lib/x86_64-linux-gnu/libexaodbc-uo2214lv2.so")