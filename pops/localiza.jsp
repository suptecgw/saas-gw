<%@page import="java.util.Map"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
                 java.text.SimpleDateFormat,
                 nucleo.BeanLocaliza,
                 nucleo.Apoio" errorPage="" %>
                 
<%  BeanLocaliza bean = null;
    String acao = request.getParameter("acao");
    int idlista = Apoio.parseInt(request.getParameter("idlista"));
    String telaConsulta = request.getParameter("telaConsulta");

    String categ = (request.getParameter("categoria")==null?"":request.getParameter("categoria"));
    String campoConsulta = "";
    Cookie localiza = null;
    if (!categ.equals("")){//Só entra se estiver usando Cookie
	    Cookie cookies[] = request.getCookies();
    	if (cookies != null){
	    	for(int i = 0; i < cookies.length; i++){
				if(cookies[i].getName().equals(categ)){
					localiza = cookies[i];
					break;
				}
				if (i == cookies.length - 1){
					localiza = new Cookie(categ,"");
				}
			}
    	}
        localiza.setMaxAge(60 * 60 * 24 * 90); 
       	campoConsulta = (request.getParameter("campoConsulta") != null && !request.getParameter("campoConsulta").trim().equals("") 
       					? request.getParameter("campoConsulta") 
       					: (localiza.getValue().equals("")?"0::texto":localiza.getValue()));
		localiza.setValue(campoConsulta);
        response.addCookie(localiza);
    }else{
    	campoConsulta = (request.getParameter("campoConsulta") != null && !request.getParameter("campoConsulta").trim().equals("") ? 
                request.getParameter("campoConsulta") : "0::texto");
    }
    
    String valor    = (request.getParameter("valor") != null ? request.getParameter("valor") : "");
    
    int paginaResultados = Integer.parseInt((request.getParameter("pag") != null ? request.getParameter("pag") : "1"));
    String paramaux = (request.getParameter("paramaux") != null ? request.getParameter("paramaux") : "");
    String paramaux2 = (request.getParameter("paramaux2") != null ? request.getParameter("paramaux2") : "");
    if (paramaux2.equals("") && (idlista == 7 || idlista == 9 || idlista == 10)){
        paramaux2 = " =0 ";
    }
    String paramaux3 = (request.getParameter("paramaux3") != null ? request.getParameter("paramaux3") : "");
    String paramaux4 = (request.getParameter("paramaux4") != null ? request.getParameter("paramaux4") : "");
    String paramaux5 = (request.getParameter("paramaux5") != null ? request.getParameter("paramaux5") : "");
    String fecharJanela = (request.getParameter("fecharJanela") != null ? request.getParameter("fecharJanela") : "true");
    boolean isConsulta = (request.getParameter("isConsulta") == null ? false : true);
    boolean consultou = false;
    int nivelUser = 0;
	String suffix = (request.getParameter("suffix") != null? request.getParameter("suffix") : "");
    
    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) != null) {
        bean = new BeanLocaliza();
        bean.setIdlista(idlista);
        nivelUser = Apoio.getUsuario(request).getAcesso(bean.getSiglapermissao());
        if (nivelUser == 0){
            // se o usuário não tem permissão, buscar no context que o menu.jsp também usa para buscar o código da permissão e colocar a mesma mensagem.
           String codigo = ((Map<String, String>) getServletContext().getAttribute("todasPermissoes")).get(bean.getSiglapermissao());
           response.sendError(response.SC_FORBIDDEN, "Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar a permissão '"+codigo+"' ao usuário administrador de sua empresa");
        }
    }else{
        //lancando o prompt para resgate de sessao e fechando o popup(jah que a sessao esta nula)
        %><script>window.opener.tryRequestToServer(function(){});</script><%
    }

    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);

    if (acao.equals("consultar") || acao.equals("proxima")) {
        bean.setConexao( Apoio.getUsuario(request).getConexao() );
        
        if (request.getParameter("paramaux") != null){
          if (!request.getParameter("paramaux").equals("")){
            bean.setParamaux(paramaux);
          }else{
            bean.setParamaux("0");
          }
        }else{
          bean.setParamaux("0");
        }
        if (request.getParameter("paramaux2") != null){
          if (!request.getParameter("paramaux2").equals("")){
            bean.setParamaux2(paramaux2);
          }else{
            bean.setParamaux2("0");
          }
        }else{
          bean.setParamaux2("0");
          if (idlista == 7 || idlista == 9 || idlista == 10){ //Apenas no localizar Veiculo, carreta e motorista
              bean.setParamaux2("=0");
          }
        }
        if (request.getParameter("paramaux3") != null){
          if (!request.getParameter("paramaux3").equals("")){
            bean.setParamaux3(paramaux3);
          }else{
            bean.setParamaux3("0");
          }
        }else{
          bean.setParamaux3("0");
        }
        if (request.getParameter("paramaux4") != null){
          if (!request.getParameter("paramaux4").equals("")){
            bean.setParamaux4(paramaux4);
          }else{
            bean.setParamaux4("");
          }
        }else{
          bean.setParamaux4("");
        }
        if (request.getParameter("paramaux5") != null){
          if (!request.getParameter("paramaux5").equals("")){
            bean.setParamaux5(paramaux5);
          }else{
            bean.setParamaux5("");
          }
        }else{
          bean.setParamaux5("");
        }
        bean.setValorconsulta(valor);
        bean.setPaginaResultados(paginaResultados);
        bean.setCampoConsulta(Integer.parseInt(campoConsulta.split("::")[0]));
        if (idlista == 3 || idlista == 4 || idlista == 5 || idlista == 6 || idlista == 10 || idlista == 59 || idlista == 91){
            if (isConsulta){
                consultou = bean.Consultar();
            }
        }else{
            consultou = bean.Consultar();
        }
    }
%> 

<script language="javascript" type="text/javascript" >
  function aoCarregar(){
    //atribuindo ao titulo o nome da janela(informado no "window.open()"
    document.title = window.name;
    document.getElementById("rotulo").innerHTML += window.name;
    getObj("campoConsulta").value  = "<%=campoConsulta%>";
    document.getElementById('valor_consulta').focus();
    onChangeCampoConsulta();
    //testando se existe algum campo alternativo para consulta
    getObj("tdCampoConsulta").style.display = (getObj("campoConsulta").length == 0? "none" : "");
  }

  function consulta(numeroPagina){
     var vlConsulta = (getObj("campoConsulta").value.split("::")[1] == "datas" ?
                          getObj("data1").value + "," + getObj("data2").value
                         :getObj("valor_consulta").value);
     location.replace("./localiza?categoria=<%=categ%>&valor="+vlConsulta+"&fecharJanela=<%=fecharJanela%>"+
                      "&acao="+(numeroPagina > 1? "proxima" : "consultar")+"&idlista=<%=idlista%>&pag="+numeroPagina+"&isConsulta=true"+
                      "&paramaux=<%=paramaux%>&paramaux2=<%=paramaux2%>&paramaux3=<%=paramaux3%>&paramaux4=<%=paramaux4%>&paramaux5=<%=paramaux5%>&"+concatFieldValue("campoConsulta")+"&suffix=<%=suffix%>"+"&telaConsulta=<%=telaConsulta%>");
  }

  var registro_selecionado = "";
  //Criado mais um parametro para deixar usar cliente inativos numa consulta;
  //Para consultar, passar como parametro o nome da tela que pode escolher o cliente mesmo inativo.
  function selecionaRegistro(id, clienteInativo,telaConsulta){
     //Esse filtro foi feito exclusivamente para não deixar o usuário escolher um cliente Inativo.
     if (clienteInativo == 'CLIENTE_INATIVO' && telaConsulta != "baixaCtrcManifesto"){
         if (window.name != 'Consignatario_Fatura' && window.name != 'Consignatario_' && window.name != 'Remetente_' && window.name != 'Destinatario_'){
             alert('Esse cliente está inativo, não pode ser utilizado nessa rotina.');
             return null;
         }
     }
     var pai = window.opener.document;
<%   if (consultou)
     {
	//atribuindo o id(sempre vai ser o 1º campo)
        String campoid = bean.getResultado().getMetaData().getColumnName(1);
        %>if (pai.getElementById("<%=campoid+suffix%>") != null)
                pai.getElementById("<%=campoid+suffix%>").value = id;
          /*if (pai.getElementById("<%=campoid%>") != null)
             pai.getElementById("<%=campoid%>").value = id;*/   
        <%

        /*Vai ate o penultimo campo, pois o ultimo eh o campo "qtde_linhas", q eh a
          subconsulta q retorna a qtde de tuplas(sem a restricao da paginacao) */
        for (int co = 2; co < bean.getResultado().getMetaData().getColumnCount(); co++) {
                 String campo = bean.getResultado().getMetaData().getColumnName(co);
                 %><%='\n'%>if(document.getElementById("<%=campo%>"+id) != null && pai.getElementById("<%=campo+suffix%>") != null)
                               pai.getElementById("<%=campo+suffix%>").value = document.getElementById("<%=campo%>"+id).innerHTML.trim();
        <%}%>
    
    registro_selecionado = id;        
            
    //ATENCAO! Esse if existe para, caso deseje
	//executar algum algoritmo depois que o usuário 
	//clicar no registro.
	if (window.opener.aoClicarNoLocaliza != null){
   	     window.opener.aoClicarNoLocaliza(window.name);
    }
    
   <%}%>
   
   var waitClosing = eval('window.opener.waitClosing'+window.name);

   if (<%=fecharJanela.equals("false")%>){
       Element.remove("tr_"+id);
   }

   //se a janela pai quiser ter controle do fechamento
   if (!(waitClosing != null && waitClosing == true) && <%=fecharJanela.equals("true")%>){
   		window.close();
   }
}
 
function onChangeCampoConsulta(){
    var tipo = getObj("campoConsulta").value.split("::")[1];
    console.log(tipo);
    getObj("porTexto").style.display = (tipo == "datas"? "none" : "");
    getObj("porDatas1").style.display = (tipo == "datas"? "" : "none");
    getObj("porDatas2").style.display = (tipo == "datas"? "" : "none");
}

function desativarBotoes(){
    var paginas = '<%=paginaResultados%>';
    var totalPaginas = document.getElementById("qtdPaginas").value;
    if(paginas == "1"){
        getObj("btnAnt").disabled = true;
    }
    if(paginas == totalPaginas){
        getObj("btnProx").disabled = true;
    }
}
</script>

<html>
<head>
<script language="javascript" src="./script/funcoes.js"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />
<title>WebTrans - Consulta</title>
<link href="./estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style3 {font-size: 9px}
.style4 {	font-family: Arial, Helvetica, sans-serif;
	font-size: 13px;
}
-->
</style>
</head>

<body onLoad="javascript:aoCarregar(), desativarBotoes();">
    <br>
    <table width="95%" align="center" class="bordaFina" >
        <tr>
            <td width="846">
                <b>
                    <label style="align:left" id="rotulo">Localizar&nbsp;</label>
                </b>
            </td>
            <td width="66">
                <input name="cancelar" type="button" class="botoes" id="cancelar" value="Fechar" onClick="javascript:window.close();">
            </td>
        </tr>
    </table>
    <br>
    <form action="javascript:getObj('pesquisar').click();" >
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="42"  height="20" align="left" id="tdCampoConsulta">
                    <select name="campoConsulta" id="campoConsulta" onclick="onChangeCampoConsulta();" onChange="getObj('valor_consulta').focus();" class="inputtexto"> 
                <% if (Apoio.getUsuario(request) != null){
                        for (int i = 0; i < bean.getRotulos().length; ++i)  
                            if (bean.getRotulos()[i].indexOf(">") > -1) {
                               String rotulo = bean.getRotulos()[i];
                               
                %>             <option value="<%=i%>::<%=(rotulo.split(">")[1].indexOf("::DATE") < 0 ? "texto" : "datas")%>">
                                  <%=rotulo.split(">")[0]%>
                               </option>
                <%          }
                   }%>
                    </select>
                </td>
                    <%-- as celulas abaixo sao alternadas de acordo com o tipo do campo consultado--%>
                <td id="porTexto" width="240">
                    <input name="valor_consulta" type="text" id="valor_consulta" 
                           value="<%=(campoConsulta.split("::")[1].equals("datas")? "" : valor)%>" size="40" maxlength="40"
                           onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
                </td>
                <%-- consulta por periodos de datas --%>
                <td id="porDatas1" width="89" style="display:none;">   
                    <input name="data1" type="text" id="data1" onBlur="alertInvalidDate(this)" onkeypress="fmtDate(this, event);" value="<%=(consultou && bean.getRotulos()[bean.getCampoConsulta()].indexOf("::DATE") > -1? valor.split(",")[0] : Apoio.getDataAtual())%>" size="10" maxlength="10" class="fieldDate">
                </td>
                <td id="porDatas2" width="61" style="display:none;">
                    <input name="data2" type="text" id="data2" onBlur="alertInvalidDate(this)" onkeypress="fmtDate(this, event);" value="<%=(consultou && bean.getRotulos()[bean.getCampoConsulta()].indexOf("::DATE") > -1? valor.split(",")[1] : Apoio.getDataAtual())%>" class="fieldDate" size="10" maxlength="10">
                </td>
                <%-- --%>
                <td width="172">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                           onClick="javascript:consulta(1);">	  
                    <div align="right">
                    </div>
                </td>
                <td width="101">
                    <input name="novo" type="button" class="botoes" id="novo" value="Novo Cadastro" title="Novo Cadastro" style="<%=(bean != null && (bean.getNovoCadastro()[0].equals("") || nivelUser < 3) ? "display:none;":"")%>"
                           onclick="javascript:window.open('<%=(bean != null ? bean.getNovoCadastro()[0] : "")%>','' , 'top=80,resizable=yes,status=1,scrollbars=1');">
                </td>
            </tr>
        </table>
    </form>
    <table width="95%" align="center" cellspacing="1" class="bordaFina">
        <tr class="tabela">
            <%if (bean != null)  
                for (int y = 0; y < bean.getRotulos().length; ++y)
                    if (!bean.getRotulos()[y].equals("!")) {
        %>	         <td><%=(bean.getRotulos()[y].indexOf(">") > -1? bean.getRotulos()[y].split(">")[0] : bean.getRotulos()[y])%></td>
        <%          }
    %>  </tr>
    <% //variaveis da paginacao
        int linha = 0;
        int linhatotal = 0;
        int qtde_pag = 0;

        String ultima_linha = "";
        // se conseguiu consultar
        if ((acao.equals("consultar") || acao.equals("proxima")) && (consultou)){
            ResultSet rs = bean.getResultado();
            while (rs.next()){
     %>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" id="tr_<%=rs.getString(1)%>" name="tr_<%=rs.getString(1)%>">
                    <%-- o laco começa de 2 pq o indice 1 é o ID de qualquer lista --%>
    <%              for (int w = 2; w < bean.getRotulos().length + 2; ++w)
                        if (bean.getRotulos()[w - 2] != null){
        %>                  <td style="display:<%=(bean.getRotulos()[w - 2].equals("!")? "none" : "")%>;">
                                <%-- concatenandoo nome do campo + o ID do registro --%>             
                                <div id="<%=rs.getMetaData().getColumnName(w)+rs.getString(1)%>" 
                                        <%=(w == 2? " class=\"linkEditar\" onclick=\"javascript:selecionaRegistro('"+rs.getString(1)+"','"+rs.getString(3)+"','" + (request.getParameter("telaConsulta") != null ? request.getParameter("telaConsulta") : "") + "');\"" : "")%>
                                                ><%=(rs.getString(w) == null? 
                                                    "" 
                                                : (bean.getRotulos()[w - 2].indexOf("::DATE") < 0? 
                                                        rs.getString(w).replace("\n","<BR>")  
                                                        : new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate(w))
                                                    )
                                                )%>
                                </div>
                            </td>
                        <%}%>
                </tr>
                <% //se for a ultima linha...
                if (rs.isLast()) {
                    ultima_linha = rs.getString(2);
                    linhatotal = rs.getInt("qtde_linhas");
                }
              linha++;
            }//while
            qtde_pag = (linhatotal / 15) + ((linhatotal % 15) == 0? 0 : 1);

        }//if%>
    </table>
    <br>
    <table width="95%" align="center" cellspacing="1" class="bordaFina">
        <tr class="celula">
            <td width="46%" height="22">
                Registros: 
                <B><%=linha%></B> 
                de 
                <B><%=linhatotal%></B>
            </td>
            <td width="47%" align="center">
                Páginas: 
                <b><%=paginaResultados %> / <%=qtde_pag %></b>
                <input type="hidden" name="qtdPaginas" id="qtdPaginas" value="<%=qtde_pag%>"/>
            </td>
        <%            //se tiver mais pags entao mostre o botao 'proxima'
            if (paginaResultados <= qtde_pag) {
        %>
                <td width="7%">
                    <div align="right">
                        <input name="btnAnt" type="button" class="botoes" id="btnAnt"
                                value="Anterior"  onClick="javascript:consulta('<%=paginaResultados - 1%>');">
                    </div>
                </td>
                <td width="7%">
                    <div align="right">
                        <input name="btnProx" type="button" class="botoes" id="btnProx"
                                value="Próxima"  onClick="javascript:consulta('<%=paginaResultados + 1%>');">
                    </div>
                </td>
        <%  }%>
        </tr> 
    </table>
    <br>
    <br>
    <br>
    <br>
  </body>
</html>
