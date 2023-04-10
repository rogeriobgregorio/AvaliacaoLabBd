package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import persistence.TimeDao;

import java.io.IOException;

@WebServlet("/SorteioServlet")
public class SorteioServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		TimeDao dao = new TimeDao();
		try {
			dao.sortearGrupos();
			request.setAttribute("mensagem", "Sorteio realizado com sucesso!");
		} catch (Exception e) {
			e.printStackTrace();
			request.setAttribute("mensagem", "Erro ao realizar o sorteio: " + e.getMessage());
		}
		request.getRequestDispatcher("dividirTimes.jsp").forward(request, response);
	}
}
