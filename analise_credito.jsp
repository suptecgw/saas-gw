<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         cliente.BeanCadCliente,
         conhecimento.ocorrencia.*,
         java.text.*,
         java.util.Date,
         java.util.Calendar,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>

<% 
   
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  SimpleDateFormat formatadorHora = new SimpleDateFormat("HH:mm");
%>  


<jsp:useBean id="conCli" class="cliente.BeanConsultaCliente" />

<%
            if (acao.equals("consultar")) {
                conCli.setConexao(Apoio.getUsuario(request).getConexao());
            } else if (acao.equals("carregarCtrcAberto")) {
                //carrega os ctrcs em aberto do cliente
                String resultado = "";
                //int idx = 1;
                conCli.setConexao(Apoio.getUsuario(request).getConexao());                
                
                //Ctrc em aberto tipo
                if (conCli.consultarCtrc(request.getParameter("tipo"),Integer.parseInt(request.getParameter("idfatura")),Integer.parseInt(request.getParameter("idconsignatario")))){
                    resultado =
                     "<table width='100%' border='0' class='bordaFina'>" +
                        "<tr class='tabela'>" +
                            "<td width='8%'><strong>CTRC</strong></td> " +
                            "<td width='4%'><strong>Tipo</strong></td> " +
                            "<td width='10%'><strong>Emissão</strong></td> " +
                            "<td width='24%'><strong>Remetente</strong></td> " +
                            "<td width='24%'><strong>Destinatário</strong></td>" +
                            "<td width='9%'><div align='right'>Valor</div></td>" +
                            "<td width='11%'>Nº Fatura</td>" +
                            "<td width='10%'><strong>Vencimento</strong></td>" +
                        "</tr>";
                    ResultSet rs = conCli.getResultado();
                    boolean retornaResultSet = false;
                    int i = 0;

                    while (rs.next()) {
                        i++;
                        retornaResultSet = true;

                        resultado += 
                                "<tr class="+((i % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td>";
                        if (rs.getString("tipo").equals("NF")){
                            resultado +=
                                    "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verNotaFiscal(" + rs.getInt("id")+");});'>";
                        }else{
                            resultado +=
                                    "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verCtrc(" + rs.getInt("id")+");});'>";
                        }
                        resultado +=  rs.getString("ctrc") +
                                    "</div>" +
                                "</td>"+
                                "<td>"+ rs.getString("tipo") + "</td>"+
                                "<td>"+ (rs.getDate("emissao_sales") == null ? "" : formatador.format(rs.getDate("emissao_sales"))) + "</td>" +
                                "<td>"+rs.getString("nome_remetente")+"</td>" +
                                "<td>"+rs.getString("nome_destinatario")+"</td>" +
                                "<td align='right'>"+ "<div "+ (rs.getBoolean("is_atraso") ? "style='color:red'":"")+">" +new DecimalFormat("#,##0.00").format(rs.getDouble("valor"))+"</div>"+"</td>" +
                                "<td>";
                                if(!rs.getString("fatura").equals("/")){
                                    resultado +="<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verFatura(" + rs.getInt("fatura_cobranca_id")+");});'>"+
                                                    rs.getString("fatura")+
                                                "</div>";
                                }
                        resultado +="</td>" +
                                "<td>"+ (rs.getDate("vence_em") == null ? "" : formatador.format(rs.getDate("vence_em"))) + "</td>";
                        resultado +="</tr>";
                    }

                    if(!retornaResultSet){
                        resultado +=
                                "<tr class="+((i % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td colspan='8'>Não há Ctrcs/NF em aberto para esta fatura</td>";
                        resultado +="</tr>";
                    }
                }
                        resultado +=    "</table>";

                response.getWriter().append(resultado);
                response.getWriter().close();

            } else if (acao.equals("carregarFaturasEmAberto")) {
                //carrega os ctrcs em aberto do cliente
                String resultado = "";
                String tipo = request.getParameter("tipo");
                //int idx = 1;
                conCli.setConexao(Apoio.getUsuario(request).getConexao());

                //Faturas em aberto
                if (conCli.consultarFaturas(Integer.parseInt(request.getParameter("idconsignatario")),tipo)){
                    resultado =
                     "<table width='100%' border='0' class='bordaFina'>" +
                        "<tr class='tabela'>"+
                            "<td colspan='10'align='center'>" +
                            (request.getParameter("tipo").equals("vencer")? "Apenas faturas a vencer e em aberto":
                             request.getParameter("tipo").equals("atraso")? "Apenas faturas em atraso e em aberto" :
                                 "Todas as faturas em aberto") +
                            "</td> " +
                        "</tr>" +
                        "<tr class='tabela'>" +
                            "<td width='2%'></td> " +
                            "<td width='8%'><strong>Fatura</strong></td> " +
                            "<td width='10%'><strong>Emissão</strong></td> " +
                            "<td width='10%'><strong>Vencimento</strong></td> " +
                            "<td width='8%'><div align='right'>Atraso</div></td> " +
                            "<td width='9%'><div align='right'>Valor</div></td>" +
                            "<td width='9%'><div align='right'>Desconto</div></td>" +
                            "<td width='9%'><div align='right'>Juros+Multa</div></td>" +
                            "<td width='9%'><div align='right'>Líquido</div></td>" +
                            "<td width='26%'><strong>Situação</strong></td> " +
                        "</tr>";
                    ResultSet rs = conCli.getResultado();
                    boolean retornaResultSet = false;
                    int i = 0;

                    //variaveis necessárias para calculo de liquido, dias em atraso e multa
                    double valor,desconto,juros,multa,liquido,jurosMulta;
                    int diasAtraso;

                    while (rs.next()) {
                        i++;
                        retornaResultSet = true;

                        resultado +=
                                "<tr class="+((i % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";

                        if (rs.getString("num_fatura") != null){
                            //se o ctrc tive na fatura
                        diasAtraso = 0;
                        
                        //caso vencimento seja null não pode fazer a subtração e o seu atraso e 0
                        if (rs.getDate("vence_em") != null){
                            if (Apoio.incDias(rs.getDate("vence_em"),new Date()) > 0){
                                diasAtraso = Apoio.incDias(rs.getDate("vence_em"),new Date());
                            }
                        }

                        valor = rs.getDouble("valor");
                        desconto = rs.getDouble("valor_desconto");
                        juros = rs.getDouble("juros_acrescimo");
                        multa = rs.getDouble("multa_acrescimo");
                        jurosMulta = 0;

                        //calculo do liquido
                        liquido = valor - desconto;
                        if (diasAtraso > 0){
                            //se tiver atraso implementa multa
                            jurosMulta = (juros/30 * diasAtraso * valor / 100) + (multa * valor / 100);
                            liquido += jurosMulta;
                        }

                        resultado +=
                            "<td align='center'>" +
                                "<img src='img/plus.jpg' id='plus_"+i+"' name='plus_"+i+"' " +
                                "title='Mostrar mais detalhes' class='imagemLink' align='right' " +
                                "onclick=\"javascript:tryRequestToServer(function(){carregarDetalhesCtrc('plus','"+i+"','"+rs.getInt("id")+"','"+tipo+"');});\">" +
                                "<img style='display:none' src='img/minus.jpg' id='minus_"+i+"' name='minus_"+i+"' " +
                                "title='Mostrar mais detalhes' class='imagemLink' align='right' " +
                                "onclick=\"javascript:tryRequestToServer(function(){carregarDetalhesCtrc('minus','"+i+"','"+rs.getInt("id")+"','"+tipo+"');});\">" +
                            "</td>" +
                            "<td>"+
                                "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verFatura(" + rs.getInt("id")+");});'>"+
                                        rs.getString("num_fatura") +
                                "</div>" +
                            "</td>"+
                                "<td>"+ (rs.getDate("emissao_em") == null ? "" : formatador.format(rs.getDate("emissao_em"))) + "</td>" +
                                "<td>"+ (rs.getDate("vence_em") == null ? "" : formatador.format(rs.getDate("vence_em"))) + "</td>" +
                                "<td align='right'>"+ diasAtraso + "</td>" +
                                "<td align='right'>"+new DecimalFormat("#,##0.00").format(valor)+"</td>" +
                                "<td align='right'>"+new DecimalFormat("#,##0.00").format(desconto)+"</td>" +
                                "<td align='right'>"+new DecimalFormat("#,##0.00").format(jurosMulta)+"</td>" +
                                "<td align='right'>"+new DecimalFormat("#,##0.00").format(liquido)+"</td>" +
                                "<td>" + rs.getString("situacao") + "</td>";
                        }else{
                            // se os ctrcs não tiverem em faturas
                            //id da fatura = 0
                            resultado +=
                            "<td align='center'>" +
                                "<img src='img/plus.jpg' id='plus_"+i+"' name='plus_"+i+"' " +
                                "title='Mostrar mais detalhes' class='imagemLink' align='right' " +
                                "onclick=\"javascript:tryRequestToServer(function(){carregarDetalhesCtrc('plus','"+i+"','0','"+tipo+"');});\">" +
                                "<img style='display:none' src='img/minus.jpg' id='minus_"+i+"' name='minus_"+i+"' " +
                                "title='Mostrar mais detalhes' class='imagemLink' align='right' " +
                                "onclick=\"javascript:tryRequestToServer(function(){carregarDetalhesCtrc('minus','"+i+"','0','"+tipo+"');});\">" +
                            "</td>" +
                            "<td colspan = 9>"+
                                "<b>CTRCs sem fatura</b>" +
                            "</td>";
                        }
                        resultado +="</tr>";

                        resultado +=
                            "<tr name='trCtrc_"+i+"' id='trCtrc_"+i+"' style='display:none'>" +
                                "<td rowspan='1' class='"+((i % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+"'>" +
                                "</td>" +
                                "<td colspan='9'>--</td>" +
                            "</tr>";
                    }

                    if(!retornaResultSet){
                        resultado +=
                                "<tr class="+((i % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td >" +
                                    "<img src='img/plus.jpg' id='plus_"+i+"' name='plus_"+i+"' " +
                                    "title='Mostrar mais detalhes' class='imagemLink' align='right' " +
                                    "onclick=\"javascript:tryRequestToServer(function(){carregarDetalhesCtrc('plus','"+i+"','0','"+tipo+"');});\">" +
                                    "<img style='display:none' src='img/minus.jpg' id='minus_"+i+"' name='minus_"+i+"' " +
                                    "title='Mostrar mais detalhes' class='imagemLink' align='right' " +
                                    "onclick=\"javascript:tryRequestToServer(function(){carregarDetalhesCtrc('minus','"+i+"','0','"+tipo+"');});\">" +
                                "</td>"+

                            "<td colspan = 9>"+
                                "<b>Não há faturas (clique no '+' para ver mais detalhes)</b>" +
                        "</td>";
                        resultado +="</tr>";
                    }
                }
                        resultado +=    "</table>";

                response.getWriter().append(resultado);
                response.getWriter().close();
            }
%>

<script language="javascript" type="text/javascript">
    var ctrcAux = '0';
    var zebraAux = '1'
    var idxOco = 0;

    shortcut.add("Alt+V",function() {visualiza();});

    function visualiza(){
        var filtros = "";

        if ($("idconsignatario").value == "0") {
            alert("Informe o cliente.")
            return false;
        }

        filtros = concatFieldValue("idconsignatario,"+
            "con_rzs,con_cnpj");

        //Apenas se os filtros estiverem corretos
            location.replace("./analise_credito.jsp?acao=consultar&"+filtros);
    }

    function localizaConsignatarioCodigo(campo, valor){
	//objeto funcao usado na requisicao Ajax(uma espécie de evento)
	function e(transport){
		var resp = transport.responseText;
		espereEnviar("",false);
		//se deu algum erro na requisicao...
		if (resp == 'null'){
			alert('Erro ao localizar cliente.');
			return false;
		}else if(resp == ''){
			$('idconsignatario').value = '0';
			$('con_cnpj').value = '';
			$('con_rzs').value = '';

                        if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                            window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                        }
			return false;
		}else{
			var cliControl = eval('('+resp+')');
			$('idconsignatario').value = cliControl.idcliente;
			$('con_cnpj').value = cliControl.cnpj;
			$('con_rzs').value = cliControl.razao;
		}
	}//funcao e()
     if (valor != ''){
        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
        });
     }
  }

    function carregarDetalhesFatura(nome,botao){
        if ($("idconsignatario").value == "0") {
            alert("Informe o cliente.")
            return false;
        }
        // [-] em todos
            $("tbFatura").style.display = "none";
            //todos
            $("plus_total").style.display = "";
            $("minus_total").style.display = "none";
            //vencer
            $("plus_vencer").style.display = "";
            $("minus_vencer").style.display = "none";
            //atraso
            $("plus_atraso").style.display = "";
            $("minus_atraso").style.display = "none";

        if (botao == "plus"){
            $("tbFatura").style.display = "";
            $("plus_" + nome).style.display = "none";
            $("minus_" + nome).style.display = "";
            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport){
                var textoresposta = transport.responseText;
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0"){
                    return false;
                }else{
                    Element.show("trFatura");
                    $("trFatura").childNodes[(isIE()? 0 : 1)].innerHTML = textoresposta;                    
                }
            }//funcao e()
            espereEnviar("",true);

            tryRequestToServer(function(){
                new Ajax.Request("./analise_credito.jsp?acao=carregarFaturasEmAberto&tipo="+nome+
                                 "&idconsignatario=" + $("idconsignatario").value ,
                {method:'post', onSuccess: e, onError: e});});
        }
    }

    function carregarDetalhesCtrc(nome,posicao,fatura,tipo){

if ($("idconsignatario").value == "0"){
            alert("Informe o cliente");
            return false;
        }

        // [-] em todos
        if ($("trCtrc_"+posicao) != null){
            $("trCtrc_"+posicao).style.display = "none";
        }

        $("plus_" + posicao).style.display = "";
        $("minus_" + posicao).style.display = "none";
        
        if (nome == "plus"){
            if ($("trCtrc_"+posicao) != null){
                $("trCtrc_"+posicao).style.display = "";
            }
            $("plus_" + posicao).style.display = "none";
            $("minus_" + posicao).style.display = "";
            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function j(transport){
                var textoresposta = transport.responseText;
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0"){
                    return false;
                }else{
                    Element.show("trCtrc_"+posicao);
                    $("trCtrc_"+posicao).childNodes[(isIE()? 1 : 1)].innerHTML = textoresposta;
                }
            }//funcao j()
            espereEnviar("",true);

            tryRequestToServer(function(){
                new Ajax.Request("./analise_credito.jsp?acao=carregarCtrcAberto&tipo="+tipo+
                                 "&idconsignatario=" + $("idconsignatario").value +"&idfatura=" + fatura,
                {method:'post', onSuccess: j, onError: j});});
        }
    }

  function fechar(){
        window.close();
  }

  function verNotaFiscal(id){
      window.open("./cadvenda.jsp?acao=editar&id="+id, "NotaFiscal" , "top=0,resizable=yes");
  }
  
  function verFinanceiro(id){
      window.open("VendaControlador?acao=iniciarEditarFinan&id="+id, "Receita Financeira" , "top=0,resizable=yes");
  }

  function verCtrc(id){
      window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "Conhecimento" , "top=0,resizable=yes");
  }

  function verRomaneio(id){
      window.open("./cadromaneio?acao=editar&id="+id, "Romaneio" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
  }

  function verFatura(id){
      window.open("./fatura_cliente?acao=editar&id="+id, "Romaneio" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
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

        <title>Webtrans - Análise de crédito</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body >
        <form method="post" id="formBx" >
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0")%>">
        </div>
        <table width="85%" height="28" align="center" class="bordaFina" >
            <tr>
                <td width="86%" height="22"><b>An&aacute;lise de crédito</b></td>
                <td width="14%">
                    <b>
                        <input  name="Button" type="button" class="botoes" value="Fechar" onClick="fechar()">
                    </b>
                </td>
            </tr>
        </table>

        <br>
        <table width="85%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td height="18" colspan="9"><div align="center">Filtros </div></td>
            </tr>
            <tr>
                <td width="25%" class="TextoCampos">Apenas o Consignat&aacute;rio:</td>
                <td width="75%" class="CelulaZebra2"><strong>
                        <input name="con_cnpj" type="text" id="con_cnpj" size="20" class="inputReadOnly8pt" value="<%=(request.getParameter("con_cnpj") != null ? request.getParameter("con_cnpj") : "")%>"
                               onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj', this.value)">
                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly8pt" value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>"
                               size="40" maxlength="80" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('c.razaosocial', this.value)">

                        <input name="localiza_rem2" type="button" class="botoes" id="localiza_rem2" value="..." onClick="javascript:window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
                        'top=80,left=150,height=500,width=700,resizable=yes,status=3,scrollbars=1');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('con_rzs').value='';getObj('con_cnpj').value='';getObj('idconsignatario').value='0';"></strong></td>
            </tr>
            <tr>
                <td colspan="2" class="TextoCampos">
                    <div align="center">
                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="   Visualizar [Alt+V]  " onClick="javascript:tryRequestToServer(function(){visualiza();});">
                    </div>
                </td>
            </tr>
        </table>
        
            <% //variaveis da paginacao
            if ( acao.equals("consultar") ){%>
                <table width="85%" border="0" class="bordaFina" align="center">

                    <%
                    //Ultima compra
                    if ( conCli.ultimaCompra(Integer.parseInt(request.getParameter("idconsignatario"))) ) {
                        ResultSet rs = conCli.getResultado();
                        if (rs.next()) {
                    %>
                    <tr >
                        <td colspan="2" class="TextoCampos">
                            Ultima compra:
                        </td>
                        <td class="CelulaZebra2">
                            <% if (rs.getString("categoria").equals("ns")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verNotaFiscal('<%=rs.getString("id")%>');});">
                            <%}else if (rs.getString("categoria").equals("fn")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verFinanceiro('<%=rs.getString("id")%>');});">
                            <% }else { %>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("id")%>');});">
                            <% } %>
                                <%=rs.getString("ctrc")%>
                            </div>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Valor:
                        </td>
                        <td class="CelulaZebra2">
                            <%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor"))%>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Data:
                        </td>
                        <td class="CelulaZebra2">
                            <%=(rs.getDate("pago_em") == null ? "" : formatador.format(rs.getDate("pago_em")))%>
                        </td>
                    </tr>
                    <%
                        }
                    }
                    %>


                    <%
                    //Maior compra
                    if ( conCli.compraMaiorMenor(Integer.parseInt(request.getParameter("idconsignatario")), "desc") ) {
                        ResultSet rs = conCli.getResultado();
                        if (rs.next()) {
                    %>
                    <tr >
                        <td colspan="2" class="TextoCampos">
                            Maior compra:
                        </td>
                        <td class="CelulaZebra2">
                            <% if (rs.getString("categoria").equals("ns")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verNotaFiscal('<%=rs.getString("id")%>');});">
                            <% }else if (rs.getString("categoria").equals("fn")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verFinanceiro('<%=rs.getString("id")%>');});">
                            <% }else{ %>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("id")%>');});">
                            <% } %>
                                <%=rs.getString("ctrc")%>
                            </div>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Valor:
                        </td>
                        <td class="CelulaZebra2">
                            <%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor"))%>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Data:
                        </td>
                        <td class="CelulaZebra2">
                            <%=(rs.getDate("pago_em") == null ? "" : formatador.format(rs.getDate("pago_em")))%>
                        </td>
                    </tr>
                    <%
                        }
                    }
                    %>

                <%
                //Menor compra
                if ( conCli.compraMaiorMenor(Integer.parseInt(request.getParameter("idconsignatario")), "asc") ) {
                    ResultSet rs = conCli.getResultado();
                    if (rs.next()) {
                %>
                    <tr >
                        <td colspan="2" class="TextoCampos">
                            Menor compra:
                        </td>
                        <td class="CelulaZebra2">
                            <% if (rs.getString("categoria").equals("ns")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verNotaFiscal('<%=rs.getString("id")%>');});">
                            <% }else if (rs.getString("categoria").equals("fn")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verFinanceiro('<%=rs.getString("id")%>');});">
                            <% }else{ %>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("id")%>');});">
                            <% } %>
                                <%=rs.getString("ctrc")%>
                            </div>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Valor:
                        </td>
                        <td class="CelulaZebra2">
                            <%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor"))%>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Data:
                        </td>
                        <td class="CelulaZebra2">
                            <%=(rs.getDate("pago_em") == null ? "" : formatador.format(rs.getDate("pago_em")))%>
                        </td>
                    </tr>
                    <%
                        }
                    }
                    %>

                <%
                //Maior atraso
                if ( conCli.maiorAtraso(Integer.parseInt(request.getParameter("idconsignatario"))) ) {
                    ResultSet rs = conCli.getResultado();
                    if (rs.next()) {
                %>
                    <tr >
                        <td colspan="2" class="TextoCampos">
                            Maior Atraso
                            <script>
                                var dtVencimento = "<%=(rs.getDate("vence_em") == null ? "" : formatador.format(rs.getDate("vence_em")))%>";
                                var dtPgto = "<%=(rs.getDate("pago_em") == null ? "" : formatador.format(rs.getDate("pago_em")))%>";
                                
                                document.write(incDias(dtPgto,dtVencimento) + " dias:");
                            </script>
                        </td>
                        <td class="CelulaZebra2">
                            <% if (rs.getString("categoria").equals("ns")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verNotaFiscal('<%=rs.getString("id")%>');});">
                            <% }else if (rs.getString("categoria").equals("fn")){%>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verFinanceiro('<%=rs.getString("id")%>');});">
                            <% }else{ %>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("id")%>');});">
                            <% } %>
                                <%=rs.getString("ctrc")%>
                            </div>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Valor:
                        </td>
                        <td class="CelulaZebra2">
                            <%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor"))%>
                        </td>
                        <td colspan="2" class="TextoCampos">
                            Data:
                        </td>
                        <td class="CelulaZebra2">
                            <%=(rs.getDate("pago_em") == null ? "" : formatador.format(rs.getDate("pago_em")))%>
                        </td>
                    </tr>
                    <%
                        }
                    }
                    %>

                    <%
                    if ( conCli.analiseCredito(Integer.parseInt(request.getParameter("idconsignatario"))) ){
                    ResultSet rs = conCli.getResultado();
                    if (rs.next()) {
                    %>
                <tr class="tabela" >
                    <td width="2%" align="center">
                        <img src="img/plus.jpg" id="plus_total" name="plus_total" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhesFatura('total','plus');});">
                        <img style="display:none" src="img/minus.jpg" id="minus_total" name="minus_total" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhesFatura('total','minus');});">
                    </td>
                    <td width="15%" align="right">
                        Total em aberto: 
                    </td>
                    <td width="18%" >
                        <%=new DecimalFormat("#,##0.00").format(rs.getDouble("total"))%>
                    </td>
                    <td width="2%" align="center">
                        <img src="img/plus.jpg" id="plus_vencer" name="plus_vencer" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhesFatura('vencer','plus');});">
                        <img style="display:none" src="img/minus.jpg" id="minus_vencer" name="minus_vencer" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhesFatura('vencer','minus');});">
                    </td>
                    <td width="14%" align="right">
                        Total a vencer:
                    </td>
                    <td width="17%" >
                        <%=new DecimalFormat("#,##0.00").format(rs.getDouble("total_vencer"))%>
                    </td>
                    <td width="2%" align="center">
                        <img src="img/plus.jpg" id="plus_atraso" name="plus_atraso" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhesFatura('atraso','plus');});">
                        <img style="display:none" src="img/minus.jpg" id="minus_atraso" name="minus_atraso" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhesFatura('atraso','minus');});">
                    </td>
                    <td width="15%" align="right">
                        Total em atraso: 
                    </td>
                    <td width="17%" >
                        <div style="color:red"><%=new DecimalFormat("#,##0.00").format(rs.getDouble("total_atraso"))%></div>
                    </td>
                </tr>
            </table>
            <%
                    }
                }
            }
            %>
            <br>
            
            <table width="85%" border="0" class="bordaFina" align="center" style="display:none" id="tbFatura">
                <tr name="trFatura" id="trFatura" >
                    <td width="100%" colspan="8">
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>