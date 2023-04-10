package persistence;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Time;

public class GrupoDao {
    private GenericDao genericDao;

    public GrupoDao() {
        this.genericDao = new GenericDao();
    }

    public List<Time> mostrarGrupos(char grupo) {
        List<Time> times = new ArrayList<>();

        String sql = "SELECT cod_time, nome_time FROM fn_gerarTabelaGrupo(?)";

        try (Connection conn = genericDao.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, String.valueOf(grupo));
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Time time = new Time();
                time.setCodigoTime(rs.getInt("cod_time"));
                time.setNomeTime(rs.getString("nome_time"));
                times.add(time);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Erro ao buscar os times do grupo " + grupo, e);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Não foi possível carregar o driver JDBC", e);
        }

        return times;
    }
}
