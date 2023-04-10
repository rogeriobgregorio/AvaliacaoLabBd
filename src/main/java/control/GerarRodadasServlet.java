package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import persistence.JogoDao;

import java.io.IOException;

@WebServlet("/GerarRodadasServlet")
public class GerarRodadasServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		JogoDao dao = new JogoDao();
		try {
			dao.gerarRodadas();
			request.setAttribute("mensagem", "Rodadas geradas com sucesso!");
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("mensagem", "Erro ao gerar as rodadas: " + e.getMessage());
		}
		request.getRequestDispatcher("gerarRodadas.jsp").forward(request, response);
	}
}