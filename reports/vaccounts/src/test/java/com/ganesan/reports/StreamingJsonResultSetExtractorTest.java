package com.ganesan.reports;

//import static com.sharfah.util.hamcrest.IsEqualJSON.*;
import static org.junit.Assert.*;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ganesan.reports.adapter.JdbcToJson;
import com.ganesan.reports.adapter.JdbcToJson;

import org.junit.Test;

public class StreamingJsonResultSetExtractorTest {

 // @Test
  public void testExtractData() throws SQLException, IOException {
    final ByteArrayOutputStream bos = new ByteArrayOutputStream();

    final ResultSet rs = MockResultSet
        .create(new String[] { "name", "age" },
        new Object[][] {
          { "Alice", 20 },
          { "Bob", 35 },
          { "Charles", 50 }
      });

    JdbcToJson.extractData(rs, bos, JdbcToJson.ColumnNameConversion.CONVERT_NOTHING);


    final String json = new String(bos.toByteArray());
    final ObjectMapper mapper = new ObjectMapper();
    assertEquals(mapper.readTree(json), 
    mapper.readTree(
      "[" 
      + "{\"name\":\"Alice\",\"age\":20}," 
      + "{\"name\":\"Bob\",\"age\":35},"
      + "{\"name\":\"Charles\",\"age\":50}" 
      + "]"));

    /* assertThat(json, equalToJSON("["
        + "{\"name\":\"Alice\",\"age\":20},"
        + "{\"name\":\"Bob\",\"age\":35},"
        + "{\"name\":\"Charles\",\"age\":50}"
        + "]")); */
  }

  //@Test
  public void testEmptyResultSet() throws SQLException, IOException  {
    final ByteArrayOutputStream bos = new ByteArrayOutputStream();

    final ResultSet rs = MockResultSet.create(new String[] { "name", "age" },
        new Object[][] {});
    JdbcToJson.extractData(rs, bos, JdbcToJson.ColumnNameConversion.CONVERT_NOTHING);

    final String json = new String(bos.toByteArray());
    final ObjectMapper mapper = new ObjectMapper();
    assertEquals(mapper.readTree(json), mapper.readTree("[]"));
  }
}