package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import persistence.JogoDao;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/BuscarRodadaServlet")
public class BuscarRodadaServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String dataStr = request.getParameter("data");
		if (dataStr == null) {
			response.sendRedirect("buscarRodada.jsp");
			return;
		}

		try {
			Date data = Date.valueOf(LocalDate.parse(dataStr));
			JogoDao jogoDao = new JogoDao();
			List<String[]> jogos = jogoDao.buscarRodada(data);
			request.setAttribute("jogos", jogos);
			request.getRequestDispatcher("buscarRodada.jsp").forward(request, response);
		} catch (DateTimeParseException | SQLException e) {
			request.setAttribute("errorMessage", "Erro ao buscar rodada.");
			request.getRequestDispatcher("buscarRodada.jsp").forward(request, response);
		}
	}

}
