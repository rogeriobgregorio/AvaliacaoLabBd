package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Time;
import persistence.GrupoDao;

import java.io.IOException;
import java.util.List;

@WebServlet("/MostrarGruposServlet")
public class MostrarGruposServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private GrupoDao grupoDao;

	public MostrarGruposServlet() {
		super();
		this.grupoDao = new GrupoDao();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		char[] grupos = { 'A', 'B', 'C', 'D' };
		try {
			for (char grupo : grupos) {
				List<Time> times = grupoDao.mostrarGrupos(grupo);
				request.setAttribute("grupo" + grupo, times);
			}
			request.getRequestDispatcher("exibirGrupos.jsp").forward(request, response);
		} catch (Exception e) {
			request.setAttribute("mensagem", "Erro ao exibir os grupos!");
			request.getRequestDispatcher("exibirGrupos.jsp").forward(request, response);
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}