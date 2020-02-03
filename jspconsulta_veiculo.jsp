<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
  import="java.sql.ResultSet,
          veiculo.BeanConsultaVeiculo,
          veiculo.BeanCadVeiculo,
          nucleo.Apoio" %>
<% //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    BeanUsuario autenticado = Apoio.getUsuario(request);

    int nivelUser = (autenticado != null
                ? autenticado.getAcesso("cadveiculo") : 0);
    
    if ((autenticado == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    
    /*int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadveiculo") : 0);*/
    int alteraveiculo = (autenticado != null
            ? autenticado.getAcesso("alteraveiculo") : 0);
 
   String campoConsulta = "";
   String valorConsulta = "";
   String operadorConsulta = "";
   String limiteResultados = "";
   Cookie consulta = null;
   Cookie operador = null;
   Cookie limite = null;

   Cookie cookies[] = request.getCookies();
   if (cookies != null){
   	for(int i = 0; i < cookies.length; i++){
            if(cookies[i].getName().equals("consultaVeiculo")){
                    consulta = cookies[i];
            }else if(cookies[i].getName().equals("operadorConsulta")){
                    operador = cookies[i]; 
            }else if(cookies[i].getName().equals("limiteConsulta")){
                    limite = cookies[i]; 
            }
            if (consulta != null && operador != null && limite != null){ //se já encontrou os cookies então saia
                    break;
            }
   	}
   	if (consulta == null){//se não achou o cookieu então inclua
   		consulta = new Cookie("consultaVeiculo","");
   	}
   	if (operador == null){//se não achou o cookieu então inclua
   		operador = new Cookie("operadorConsulta","");
   	}
   	if (limite == null){//se não achou o cookieu então inclua
   		limite = new Cookie("limiteConsulta","");
   	}
       consulta.setMaxAge(60 * 60 * 24 * 90);
       operador.setMaxAge(60 * 60 * 24 * 90);
       limite.setMaxAge(60 * 60 * 24 * 90);

       String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
       String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
      	valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
      	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
   				? request.getParameter("campo") 
   				: (campo.equals("")?"placa":campo));
      	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") 
   				? request.getParameter("ope") 
   				: (operador.getValue().equals("")?"1":operador.getValue()));
      	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") 
   			? request.getParameter("limite")
   			: (limite.getValue().equals("")?"10":limite.getValue()));
   	consulta.setValue(valorConsulta+"!!"+campoConsulta);
   	operador.setValue(operadorConsulta);
   	limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
   }else{
   	campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("") ? 
               request.getParameter("campo") : "placa");
   	valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? 
               request.getParameter("valor") : "");
   	operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? 
               request.getParameter("ope") : "1");
   	limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? 
               request.getParameter("limite") : "10");
   }

%> 

<%  // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaVeiculo beanveiculo = null;
    String acao     = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    //variavel responsavel pela paginacao. Pega o ultimo titulo
    String ultimotitulo = request.getParameter("ultimo");
    String pag      = (request.getParameter("pag") != null ? request.getParameter("pag") : "0");

    if (acao.equals("iniciar")){
      acao = "consultar";
      pag = "1";
    }

    if ((acao.equals("consultar")) || (acao.equals("proxima")) || (acao.equals("anterior"))){
        //instanciando o bean
        beanveiculo = new BeanConsultaVeiculo();
        beanveiculo.setConexao( Apoio.getUsuario(request).getConexao() );
        beanveiculo.setCampoDeConsulta(campoConsulta);
        beanveiculo.setOperador(Apoio.parseInt(operadorConsulta));
        beanveiculo.setValorDaConsulta(valorConsulta);
        beanveiculo.setLimiteResultados(Apoio.parseInt(limiteResultados));
        beanveiculo.setPaginaResultados(Apoio.parseInt(pag));
        // a chamada do método Consultar() está lá em mbaixo
    }

	if ((nivelUser == 4) && (acao.equals("excluir") && request.getParameter("id") != null)){
	    BeanCadVeiculo cadveiculo = new BeanCadVeiculo();
	    cadveiculo.setConexao(Apoio.getUsuario(request).getConexao());
            cadveiculo.setExecutor(Apoio.getUsuario(request));
            cadveiculo.setIdveiculo(Apoio.parseInt(request.getParameter("id")));
            %><script language="javascript"><%
            if (! cadveiculo.Deleta()){
                %>alert("Erro ao tentar excluir!");<%
            }
	    %>
                location.replace("ConsultaControlador?codTela=56");
            </script><%
	}
%>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" src="script/funcoes.js" type=""></script>
<script language="javascript" type="text/javascript" >
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;

    function seleciona_campos(){
    <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
        if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) )
        {%>
            $("valor_consulta").focus();
            document.getElementById("valor_consulta").value = "<%=valorConsulta %>";
            document.getElementById("campo_consulta").value = "<%=campoConsulta%>";
            document.getElementById("operador_consulta").value = "<%=operadorConsulta %>";
            document.getElementById("limite").value = "<%=limiteResultados %>";
            if(paginaAtual <= 1){
                    desabilitar($("voltar"));
                }
                if(paginaAtual == qtde_pag){
                    desabilitar($("avancar"));
                }
                if(linhatotal <= 10 && qtde_pag <=0){
                    desabilitar($("voltar"));
                    desabilitar($("avancar"));
                }
        <%}%>
    }

    function consulta(campo, operador, valor, limite){
        location.replace("./consultaveiculo?campo="+campo+"&ope="+operador+"&valor="+valor+
                        "&limite="+limite+"&pag=1&acao=consultar");
    }

    function editar(idveiculo, tipofrota){
        if(<%= alteraveiculo%> < 1 && tipofrota == "pr"){
            alert("não tem permissão para editar um veiculo de frota propria");
        }else{
        location.replace("./cadveiculo?acao=editar&id="+idveiculo);
        }
        }

    function novo(){
        location.replace("./cadveiculo?acao=iniciar");
    }

    function proxima(ultimo_titulo){
        <%                                               //Somando a pag atual + 1 para a proxima pagina %>
        location.replace("./consultaveiculo?pag="+<%=(Integer.parseInt(pag) + 1)%>+
                        "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                        "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=proxima");
    }

    function anterior(ultimo_titulo){
        <%                                               //Somando a pag atual + 1 para a proxima pagina %>
        location.replace("./consultaveiculo?pag="+<%=(Integer.parseInt(pag) - 1)%>+
                        "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                        "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=anterior");
    }

    function excluir(idveiculo, tipofrota){ 
        if(<%= alteraveiculo%> != 4 && tipofrota == "pr"){
            alert("não tem permissão para excluir um veiculo de frota propria");
        }else{
        if (confirm("Deseja mesmo excluir esta veículo?"))
            {
                location.replace("./consultaveiculo?acao=excluir&id="+idveiculo);
                }
            } 
        }
    
    function popImg(id, placa){
        window.open('./ImagemControlador?acao=carregar&placa='+placa+'&idveiculo='+id +'&modulo=gwFrota',
        'imagensVeiculo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function enviarVeiculoEfrete(idVeiculo){
        idVeiculo = idVeiculo.split("!!")[0];
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('EFreteControlador?acao=enviarVeiculo&idVeiculo='+idVeiculo,{method:'post', onSuccess: e, onError: e});
        });
    }    
   
    function consultarEfrete(idVeiculoCpfCnpj){
        var idVeiculo = idVeiculoCpfCnpj.split("!!")[0];
        var cpfCnpj = idVeiculoCpfCnpj.split("!!")[1];
        var rntrc = idVeiculoCpfCnpj.split("!!")[2];
        
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            if (textoresposta.trim() != "") {
                alert(textoresposta);
            }else{
                alert("Consulta realizada com sucesso.");
                window.location.reload(true);
            }
        }
        tryRequestToServer(function(){
            new Ajax.Request('EFreteControlador?acao=consultarVeiculoEfrete&idVeiculo='+idVeiculo+'&cpfCnpj='+cpfCnpj+'&rntrc='+rntrc,{method:'post', onSuccess: e, onError: e});
        });
        
    }
    
     function enviarVeiculoExpers(idVeiculo){
        idVeiculo = idVeiculo.split("!!")[0];
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('ExpersControlador?acao=enviarVeiculoExpers&idVeiculo='+idVeiculo,{method:'post', onSuccess: e, onError: e});
        });
    }
    
     function enviarVeiculoPagBem(idVeiculo){
        idVeiculo = idVeiculo.split("!!")[0];
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('PagBemControlador?acao=enviarVeiculoPagBem&idVeiculo='+idVeiculo,{method:'post', onSuccess: e, onError: e});
        });
    }
    
     function consultarSituacaoPagBem(idVeiculoCpfCnpj){
        var idVeiculo = idVeiculoCpfCnpj.split("!!")[0];
        var cpfCnpj = idVeiculoCpfCnpj.split("!!")[1];
        var rntrc = idVeiculoCpfCnpj.split("!!")[2];
        
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            if (textoresposta.trim() != "") {
                alert(textoresposta);
            }else{
                alert("Consulta realizada com sucesso.");
                window.location.reload(true);
            }
        }
        tryRequestToServer(function(){
            new Ajax.Request('PagBemControlador?acao=consultaSituacaoRntrc&idVeiculo='+idVeiculo,{method:'post', onSuccess: e, onError: e});
        });
        
    }
    
    function enviarVeiculoRepom(idVeiculo){
        idVeiculo = idVeiculo.split("!!")[0];
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('RepomControlador?acao=enviarVeiculoRepom&idVeiculo='+idVeiculo,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    
    function getRadioValorVeiculo(name){
        var rads = document.getElementsByName(name);

        for(var i = 0; i < rads.length; i++){
            if(rads[i].checked){
                return rads[i].value;
            }

        }
    }
</script>

<html>
  <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Consulta de Ve&iacute;culo</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
        <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                    font-size: 13px;
            }
        -->
        </style>
  </head>

  <body onLoad="javascript:seleciona_campos();">
    <img src="img/banner.gif"  alt="">
    <br>
    <table width="80%" align="center" class="bordaFina" >
        <tr>
            <td width="461">
                <div align="left">
                    <b>Consulta de Ve&iacute;culo </b>
                </div>
            </td>
            <% if (nivelUser >= 3){%>
                <td width="102">
                    <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function(){novo();});" value="Novo cadastro">
                </td>
            <%}%>
        </tr>
    </table>
    <br>
    <table width="80%" align="center" cellspacing="1" class="bordaFina">
        <tr class="celula">
            <td width="105"  height="20">
                <select name="campo_consulta" id="campo_consulta" class="inputtexto">
                    <option value="placa" selected>Placa</option>
                    <option value="tp.descricao">Tipo</option>
                    <option value="numero_frota">Frota Nº</option>
                    <option value="renavan">Nº Renavan</option>
                    <option value="chassi">Nº Chassi</option>
                    <option value="modelo">Modelo</option>
                    <option value="ano">Ano</option>
                    <option value="razaosocial">Propriet&aacute;rio</option>
                    <option value="m.descricao">Marca</option>
                </select>
            </td>
            <td width="158">
                <select name="operador_consulta" id="operador_consulta" class="inputtexto">
                    <option value="1" selected>Todas as partes com</option>
                    <option value="2">Apenas com in&iacute;cio</option>
                    <option value="3">Apenas com o fim</option>
                    <option value="4">Igual &agrave; palavra/frase</option>
                </select>
            </td>
            <td colspan="2">
                <input name="valor_consulta" type="text" id="valor_consulta" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" class="inputtexto">
            </td>
            <td width="86">
                <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
                       onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});">
            </td>
            <td width="233">
                <div align="right">
                    Por p&aacute;g.:
                    <select name="limite" id="limite" class="inputtexto">
                        <option value="10" selected>10 resultados</option>
                        <option value="20">20 resultados</option>
                        <option value="30">30 resultados</option>
                        <option value="40">40 resultados</option>
                        <option value="50">50 resultados</option>
                    </select>
                </div>
            </td>
        </tr>
    </table>
    <table width="80%" align="center" cellspacing="1" class="bordaFina">
        <tr>
            <td width="3%" class="tabela">&nbsp;</td>
            <td width="2%" class="tabela">&nbsp;</td>
            <td width="9%" class="tabela">Placa</td>
            <td width="7%"  class="tabela">Frota Nº</td>
            <td width="10%"  class="tabela">Tipo</td>
            <td width="10%" class="tabela">Modelo</td>
            <td width="12%" class="tabela">Cor</td>
            <td width="6%" class="tabela">Ano</td>
            <td width="24%" class="tabela">Propriet&aacute;rio</td>
            <td width="14%" class="tabela">Marca</td>
            <td width="3%" class="tabela"></td>
        </tr>
        <% //variaveis da paginacao
            int linha = 0;
            int linhatotal = 0;
            int qtde_pag = 0;

            String ultima_linha = "";
            // se conseguiu consultar
            if ((acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) && (beanveiculo.Consultar( alteraveiculo < 1))){
                ResultSet rs = beanveiculo.getResultado();
                while (rs.next()){
                    //pega o resto da divisao e testa se é par ou impar
                    %> 
                      <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0) || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)
                                || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)|| Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "R".charAt(0)){%>
                        <td>
                            <input type="radio" name="idVeiculo_cpfCnpj" id="idVeiculo_cpfCnpj" value="<%=rs.getString("idveiculo")+"!!"+rs.getString("cpf_cnpj")+"!!"+rs.getString("rntrc")%>">
                        </td>
                        <%}else{%>
                        <td></td>
                        <%}%>
                        <td>
                            <img src="img/jpg.png" width="19" height="19" border="0" align="center" class="imagemLink" title="Imagens de documentos"
                                onClick="javascript: tryRequestToServer(function(){popImg('<%=rs.getString("idveiculo")%>','<%=rs.getString("placa")%>')});">
                        </td>
                        <td>
                            <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=rs.getString("idveiculo")%>, '<%= rs.getString("tipofrota")%>');});">
                                                                <%=rs.getString("placa")%>
                            </div>
                        </td>
                        <td><%=rs.getString("numero_frota")%></td>
                        <td><%=rs.getString("tipo")%></td>
                        <td><%=rs.getString("modelo")%></td>
                        <td><%=rs.getString("cor")%></td>
                        <td><%=rs.getString("ano")%></td>
                        <td><%=rs.getString("proprietario")%></td>
                        <td><%=rs.getString("marca")%></td>

                        <% if(nivelUser == 4 && (!rs.getString("tipofrota").equals("pr") || (rs.getString("tipofrota").equals("pr") && alteraveiculo == 4))){ %>
                            <td width="31">
                                <img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer "
                                    onclick="javascript:tryRequestToServer(function(){excluir(<%=rs.getString("idveiculo")%>, '<%= rs.getString("tipofrota")%>');});"
                                    border="0" align="right">
                            </td>
                        <%}else{%>
                            <td width="24"></td>
                        <%}%>
                        </tr>
                <% //se for a ultima linha................
                    if (rs.isLast()) {
                        ultima_linha = rs.getString("placa");
                        //Quantidade geral de resultados da consulta
                        linhatotal = rs.getInt("qtde_linhas");
                    }
                    linha++;
            }//while
            //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
            qtde_pag = ((linhatotal % Apoio.parseInt(limiteResultados)) == 0
                        ? (linhatotal / Apoio.parseInt(limiteResultados))
                        : (linhatotal / Apoio.parseInt(limiteResultados)) + 1);
        }//if
        pag = ( qtde_pag == 0 ? "0" : pag );
            %>
         <script type="text/javascript" language="javascript" >paginaAtual= <%=beanveiculo== null ? 1 :beanveiculo.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
    </table>
    <br>
    <table width="80%" align="center" cellspacing="1" class="bordaFina">
        <tr class="celula">
            <td width="20%" height="22">
                <center>
                    Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
                </center>
            </td>
            <td width="20%">
            <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
                <input name="consultarEfrete" type="button" class="botoes" id="consultarEfrete"
                value="Consultar Situação(e-Frete)"  onClick="javascript:tryRequestToServer(function(){consultarEfrete(getRadioValorVeiculo('idVeiculo_cpfCnpj'));});">
            <%}%>
            <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)){%>
                <input name="consultarPagBem" type="button" class="botoes" id="consultarPagBem"
                value="Consultar Situação dos Veículos na ANTT (Pagbem)"  onClick="javascript:tryRequestToServer(function(){consultarSituacaoPagBem(getRadioValorVeiculo('idVeiculo_cpfCnpj'));});">
            <%}%>
            </td>
            <td width="20%">
            <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
                <input name="enviarEfrete" type="button" class="botoes" id="enviarEfrete"
                value="Enviar para e-Frete"  onClick="javascript:tryRequestToServer(function(){enviarVeiculoEfrete(getRadioValorVeiculo('idVeiculo_cpfCnpj'));});">
            <%}%>
            <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)){%>
                <input name="enviarExpers" type="button" class="botoes" id="enviarExpers"
                value="Enviar para ExpeRS"  onClick="javascript:tryRequestToServer(function(){enviarVeiculoExpers(getRadioValorVeiculo('idVeiculo_cpfCnpj'));});">
            <%}%>
            <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)){%>
                <input name="enviarPagBem" type="button" class="botoes" id="enviarPagBem"
                value="Enviar para PagBem"  onClick="javascript:tryRequestToServer(function(){enviarVeiculoPagBem(getRadioValorVeiculo('idVeiculo_cpfCnpj'));});">
            <%}%>
             <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "R".charAt(0)){%>
                <input name="enviarRepom" type="button" class="botoes" id="enviarPagBem"
                value="Enviar para Repom"  onClick="javascript:tryRequestToServer(function(){enviarVeiculoRepom(getRadioValorVeiculo('idVeiculo_cpfCnpj'));});">
            <%}%>
            </td>
            <td width="20%" align="center">P&aacute;ginas: <b><%=pag %> / <%=qtde_pag %></b></td>
            <td width="20%">
                <div align="center">
                    <input name="voltar" type="button" class="botoes" id="voltar"
                            value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=ultima_linha%>');});">
                    <input name="avancar" type="button" class="botoes" id="avancar"
                            value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});">
                </div>
            </td>
        </tr>
    </table>
    <br>
    <br>
    <br>
    <br>
  </body>
</html>