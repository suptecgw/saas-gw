<%@ page contentType="text/html; charset=iso-8859-1" 
         language="java" 
         import="nucleo.Apoio,java.io.*, java.util.* " %>
         
<%
   String dir = Apoio.getDirDrivers(request) + File.separatorChar;
   String filePath = request.getParameter("filePath");
   String fileIndex = request.getParameter("fileIndex");
   
 Vector drivers = Apoio.listFiles(dir, "*");
 for (int i=0; i < drivers.size(); ++i)
 {
     String driv = (String)drivers.get(i);     
%>   <a href="./driverEditor.jsp?fileIndex=<%=i%>"><%=driv%></a>&nbsp;&nbsp;&nbsp;<% 
 }

 //salvar
 if (request.getParameter("acao") != null && request.getParameter("acao").equals("salvar") ){
    FileOutputStream fos1 = new FileOutputStream(filePath);
    fos1.write(((String)request.getParameter("editorTx")).getBytes());
    fos1.close(); 
 }
 
 String tx = "";
 if (fileIndex != null)
 {
    FileReader file = new FileReader( Apoio.getDirDrivers(request) + File.separatorChar + drivers.get(Integer.parseInt(fileIndex)) );
    Scanner in = new Scanner( file );
    while( in.hasNext() )
 	tx += in.nextLine() + "\n";
 	
 }     
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Editor de Driver matrixPrint</title>
</head>

<body>

<form action="./driverEditor.jsp?acao=salvar" method="post"> 
<center>
	<input type="hidden" name="filePath" value="<%=(fileIndex != null? dir+drivers.get(Integer.parseInt(fileIndex)) : "")%>">
	<textarea name="editorTx" rows="30" wrap="OFF" style="width:96% "><%=tx%></textarea>
	<input type="submit" value="salvar">
</center>
</form>

</body>
</html>
