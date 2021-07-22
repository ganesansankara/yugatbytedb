package com.ganesan.reports;

import static org.junit.Assert.assertTrue;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

import com.ganesan.reports.adapter.JdbcToJson;
import com.ganesan.reports.adapter.JdbcUtil;
import com.ganesan.reports.util.JasportReportExporter;

import org.junit.Test;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.data.JsonDataSource;

/**
 * Unit test for simple App.
 */
public class JasperReportExporterTest {

        enum DatabaseType {
                EXASOL, POSTGRES, DREMIO
        };

        /**
         * Rigorous Test :-)
         * @throws JRException
         * @throws Exception
         */
        @Test
        public void shouldAnswerWithTrue() throws SQLException, IOException, JRException {
                main(null);
                assertTrue(true);
        }

        public static void main(final String[] args) throws SQLException, IOException, JRException {

                // SimpleReportFiller simpleReportFiller = new SimpleReportFiller();

                ArrayList<String> sqlParams = new ArrayList<String>();
                DatabaseType mydbType = DatabaseType.EXASOL;

                switch (mydbType) {
                        case EXASOL: {
                                int nMaxLimitRows = 10;
                                String dbConfig = "ganesan-exasol";
                                String reportName = "vaaccounts";
                                String jasperReportName = String.format("reports/accounts/%s.jasper", reportName);
                                String jsonOutFile = String.format("/tmp/%s_%s.json", reportName, mydbType);
                                String pdfOutFile = String.format("/tmp/%s_%s.pdf", reportName, mydbType);

                                sqlParams.add("gan9-");
                                String sqlStmt = String.format("SELECT * FROM ACCOUNTS a WHERE %s = ? LIMIT %d",
                                                "REGEXP_SUBSTR(a.ACCT_NO,'[a-z0-9._%+]+-')", nMaxLimitRows);
                                ExtractJDBCToJSon(dbConfig, sqlStmt, sqlParams, jsonOutFile, jasperReportName,
                                                pdfOutFile);
                        }
                        break;
                        case DREMIO: {
                                //int nMaxLimitRows = 10;
                                String dbConfig = "ganesan-dremio";
                                String reportName = "vaaccounts";
                                String jasperReportName = String.format("reports/accounts/%s.jasper", reportName);
                                String jsonOutFile = String.format("/tmp/%s_%s.json", reportName, mydbType);
                                String pdfOutFile = String.format("/tmp/%s_%s.pdf", reportName, mydbType);

                                sqlParams.add("gan9-");
                                String sqlStmt = String.format("SELECT * FROM s2b.vaaccounts.vds_reports WHERE ACCT_NO=?");
                                ExtractJDBCToJSon(dbConfig, sqlStmt, sqlParams, jsonOutFile, jasperReportName,
                                                pdfOutFile);
                        }
                        break;
                        case POSTGRES: {
                                //int nMaxLimitRows = 10;
                                String dbConfig = "ganesan-db";
                                String reportName = "vaaccounts";
                                String jasperReportName = String.format("reports/accounts/%s.jasper", reportName);
                                String jsonOutFile = String.format("/tmp/%s_%s.json", reportName, mydbType);
                                String pdfOutFile = String.format("/tmp/%s_%s.pdf", reportName, mydbType);

                                sqlParams.add("gan9-");
                                String sqlStmt = String.format("SELECT * FROM ACCOUNTS WHERE ACCT_NO=?");
                                ExtractJDBCToJSon(dbConfig, sqlStmt, sqlParams, jsonOutFile, jasperReportName,
                                                pdfOutFile);
                        }
                        break;
                }

                /*
                 * SimpleReportExporter simpleExporter = new SimpleReportExporter();
                 * simpleExporter.setJasperPrint(simpleReportFiller.getJasperPrint());
                 * 
                 * simpleExporter.exportToPdf("vaccounts.pdf", "VACCOUNTS");
                 * simpleExporter.exportToXlsx("vaccounts.xlsx", "VACCOUNTS DATA");
                 * simpleExporter.exportToCsv("vaccounts.csv");
                 * simpleExporter.exportToHtml("vaccounts.html");
                 */

        }

        private static void ExtractJDBCToJSon(final String dbconfig, final String sql,
                        final ArrayList<String> SqlParams, final String outJsonFullFileName,
                        final String jasperReportFile, final String pdfOutFile)
                        throws SQLException, IOException, JRException {

                long currentTime = 0L;

                System.out.printf("SQL Statement=%s%n", sql);

                final Connection conn = JdbcUtil.getJdbcDataSource(dbconfig);
                currentTime = System.currentTimeMillis();

                final ResultSet rs = JdbcUtil.getResultSet(conn, sql, SqlParams);

                final FileOutputStream fos = new FileOutputStream(outJsonFullFileName);

                long rowcount = JdbcToJson.extractData(rs,fos, JdbcToJson.ColumnNameConversion.CONVERT_NOTHING);
                System.out.printf("Generation of JDBC to JSON File: Elapsed Time=%d (ms), Total ROWS=%d%n",
                                System.currentTimeMillis() - currentTime, rowcount);
                JdbcUtil.close(rs);
                JdbcUtil.close(conn);

                final HashMap<String, Object> ReportParams = new HashMap<>();
                ReportParams.put("title", "Employee Report Example");
                ReportParams.put("minSalary", 15000.0);

                final JRDataSource jrd = new JsonDataSource(new FileInputStream(outJsonFullFileName));

                currentTime = System.currentTimeMillis();

                // Maven Plugin to compile jrxml to jasper as part of build to avoid unnecessary
                // compilation at run time
                JasportReportExporter.generateReport(jasperReportFile, pdfOutFile, ReportParams, jrd);

                System.out.printf("Generation of PDF from JSON File: Elapsed Time=%d (ms)%n",
                                System.currentTimeMillis() - currentTime);
        }
}
