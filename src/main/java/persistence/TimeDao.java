package persistence;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Time;

public class TimeDao {

	private Connection c;

	public TimeDao() {
		GenericDao gDao = new GenericDao();
		try {
			c = gDao.getConnection();
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
	}

	public void sortearGrupos() {
		String sql = "{call sp_sorteia_grupos}";
		try (CallableStatement stmt = c.prepareCall(sql)) {
			stmt.execute();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public List<Time> mostrarTimes() {
	    List<Time> times = new ArrayList<>();
	    String sql = "SELECT * FROM times";
	    try (PreparedStatement stmt = c.prepareStatement(sql)) {
	        ResultSet rs = stmt.executeQuery();
	        while (rs.next()) {
	            int codigo = rs.getInt("codigo_time");
	            String nome = rs.getString("nome_time");
	            String cidade = rs.getString("cidade");
	            String estadio = rs.getString("estadio");
	            String material = rs.getString("material_esportivo");
	            Time time = new Time(codigo, nome, cidade, estadio, material);
	            times.add(time);
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return times;
	}

}
