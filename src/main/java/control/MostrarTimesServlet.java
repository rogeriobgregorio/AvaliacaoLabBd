package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Time;
import persistence.TimeDao;

import java.io.IOException;
import java.util.List;

@WebServlet("/MostrarTimesServlet")
public class MostrarTimesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        TimeDao dao = new TimeDao();
        List<Time> times = dao.mostrarTimes();

        request.setAttribute("times", times);
        request.getRequestDispatcher("mostrarTimes.jsp").forward(request, response);
    }
}
