package persistence;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class JogoDao {

	private Connection c;

	public JogoDao() {
		GenericDao gDao = new GenericDao();
		try {
			c = gDao.getConnection();
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}
	}

	public void gerarRodadas() {
		String sql = "{call sp_gera_jogos}";
		try (CallableStatement stmt = c.prepareCall(sql)) {
			stmt.execute();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public List<String[]> buscarRodada(Date data) throws SQLException {
		String sql = "SELECT * FROM fn_consultarData(?)";
		List<String[]> jogos = new ArrayList<>();
		try (PreparedStatement stmt = c.prepareStatement(sql)) {
			stmt.setDate(1, data);
			ResultSet rs = stmt.executeQuery();
			while (rs.next()) {
				String[] jogo = { rs.getString("nome_timeA"), rs.getString("nome_timeB") };
				jogos.add(jogo);
			}
		}
		return jogos;
	}

}
