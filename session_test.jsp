<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="nucleo.Apoio" %>

<% //testando se a sessao � v�lida...
   if (Apoio.getUsuario(request) == null){
       response.sendError(response.SC_FORBIDDEN);
   }
%>
