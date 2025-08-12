package com.example;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        resp.getWriter().println("<html><head><title>My CI/CD App</title></head>");
        resp.getWriter().println("<body><h1>Hello from my_cicd_proj</h1>");
        resp.getWriter().println("<p>Built by Jenkins + Kaniko + Terraform</p>");
        resp.getWriter().println("</body></html>");
    }
}
