package com.ganesan.reports.adapter;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Streams a ResultSet as JSON.
 * 
 * @author Ganesan
 */
public class JdbcToJson {

  public static enum ColumnNameConversion {
    CONVERT_TO_UPPERCASE, CONVERT_TO_LOWERCASE, CONVERT_NOTHING
  };

  public static Long extractData(final ResultSet rs, final OutputStream os, ColumnNameConversion conv) throws SQLException, IOException {

    final ObjectMapper objectMapper = new ObjectMapper();
    JsonGenerator jg = null;
    long rowcount = 0L;

    try {

      jg = objectMapper.getFactory().createGenerator(os, JsonEncoding.UTF8);
      rowcount = writeResultSetToJson(rs, jg, conv);
      jg.flush();
    } finally {
      JdbcUtil.close(jg);
      JdbcUtil.close(os);
    }

    return rowcount;

  }

  private static long writeResultSetToJson(final ResultSet rs, final JsonGenerator jg, ColumnNameConversion conv) throws SQLException, IOException {
    final ResultSetMetaData rsmd = rs.getMetaData();
    // String tableName = "DATA";
    final int columnCount = rsmd.getColumnCount();
    long rowcount = 0L;
    System.out.printf("COLUMN COUNT=%d%n", columnCount);

    jg.writeStartArray();
    //jg.writeStartObject();
    // System.out.printf("TABLENAME=%s", tableName);
    // jg.writeFieldName(tableName);
    // jg.writeStartArray();

    while (rs.next()) {

      rowcount++;

      jg.writeStartObject();
      switch ( conv ) {
        case CONVERT_TO_UPPERCASE : {
          for (int i = 1; i <= columnCount; i++) {
            jg.writeObjectField(rsmd.getColumnName(i).toUpperCase(), rs.getObject(i));
            // System.out.printf("COL Name=%s, Value=%s%n", rsmd.getColumnName(i),
            // ""+rs.getObject(i));
          }
        }
        break;

        case CONVERT_TO_LOWERCASE : {
          for (int i = 1; i <= columnCount; i++) {
            jg.writeObjectField(rsmd.getColumnName(i).toLowerCase(), rs.getObject(i));
            // System.out.printf("COL Name=%s, Value=%s%n", rsmd.getColumnName(i),
            // ""+rs.getObject(i));
          }
        }
        break;

        default : {
          for (int i = 1; i <= columnCount; i++) {
            jg.writeObjectField(rsmd.getColumnName(i), rs.getObject(i));
            // System.out.printf("COL Name=%s, Value=%s%n", rsmd.getColumnName(i),
            // ""+rs.getObject(i));
          }
        }
        break;
      }

      jg.writeEndObject();
    }

   

    jg.writeEndArray();
    //jg.writeEndObject();

    System.out.printf("Total Rows from JDBC to JSON=%d%n", rowcount);

    return rowcount;

  }
}