<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.text.*,
         java.util.Date,
         nucleo.*" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("cadcliente") > 0);
            if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
                response.sendError(response.SC_FORBIDDEN);
            }

            String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

            if (acao.equals("exportar")) { 
                String modelo = request.getParameter("modelo");
                SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
                Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
                Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
                String opcoes = "Realiza entre " + request.getParameter("dtinicial") + " e " + request.getParameter("dtfinal");
                String status = "";
                String vendedor = (request.getParameter("idvendedor") != null && !request.getParameter("idvendedor").equals("0") 
                                   ? " AND o.vendedor_id = " +  request.getParameter("idvendedor")
                                   : " ");
                if (request.getParameter("status").equals("")){
                    status = "Todos";
                }else if (request.getParameter("status").equals("0")){
                    status = "Em aberto";
                }else if (request.getParameter("status").equals("1")){
                    status = "Aprovado";
                }else{
                    status = "Não aprovado";
                }

                java.util.Map param = new java.util.HashMap(6);
                param.put("IDCLIENTE", (request.getParameter("idremetente").equals("0") ? "" : " and  o.cliente_id =" + request.getParameter("idremetente")));
                param.put("STATUS", request.getParameter("status").equals("") ?"": (" and o.status = " + request.getParameter("status")));
                param.put("DATA_INI", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtinicial)+"'");
                param.put("DATA_FIM", "'"+new SimpleDateFormat("MM/dd/yyyy").format(dtfinal)+"'");
                param.put("ID_VENDEDOR", vendedor);
                param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                
                opcoes += (request.getParameter("idremetente").equals("0") ? "" :". Cliente: " + request.getParameter("rem_rzs"));
                opcoes += ". Status:" + status;

                param.put("OPCOES", opcoes);

                request.setAttribute("map", param);
                request.setAttribute("rel", "orcamentomod" + modelo);

                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
                dispacher.forward(request, response);
            }else if(acao.equals("iniciar")){
                request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_ORCAMENTO_RELATORIO.ordinal());
            }
%>


<script language="javascript" type="text/javascript">

    function modelos(modelo){
        getObj("modelo1").checked = false;

        getObj("modelo"+modelo).checked = true;
    }

    function popRel(){
        var modelo;
        if (getObj("modelo1").checked)
            modelo = '1';


        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";
        
        launchPDF('./relorcamento.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+"&idvendedor="+$("idvendedor").value +'&'+concatFieldValue("idremetente,status,dtinicial,dtfinal,rem_rzs"));
    }

    //  -- inicio localiza rematente pelo codigo
    function localizaRemetenteCodigo(campo, valor){

        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function y(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if(resp == ''){
                $('idremetente').value = '0';
                $('rem_codigo').value = '';
                $('rem_rzs').value = '';
                $('rem_cnpj').value = resp.split('!=!')[4];

                alert("Cliente não encontrado.")
                return false;
            }else{
			var cliControl = eval('('+resp+')');
                $('idremetente').value = cliControl.idcliente;
                $('rem_codigo').value = cliControl.idcliente;
                $('rem_rzs').value = cliControl.razao;
                $('rem_cnpj').value = cliControl.cnpj;
            }
        }//funcao y()

        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: y, onError: y});
            });
        }
    }

    function limpaCliente(){
            $("rem_codigo").value = "";
            $("rem_cnpj").value = "";
            $("idremetente").value = "0";
            $("rem_rzs").value = "";
    }
    function limpaVendedor(){
            $("idvendedor").value = "0";
            $("ven_rzs").value = "";
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

        <title>Webtrans - Relatório de Orçamento</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idvendedor" id="idvendedor" value="0">
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Orçamento </b></td>
            </tr>
        </table>
        <br>

<table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                            <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
                        </tr>
                    </table>
                </td>
            </tr>
</table>
        
        <div id="tabPrincipal">
            <table width="90%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td colspan="3"><div align="center">Modelos</div></td>
            </tr>
            <tr>
                <td width="50%" height="24" class="TextoCampos"> <div align="left">
                        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos('1');">
                        Modelo 1 </div></td>
                <td width="80%" class="CelulaZebra2">Relação dos orçamentos </td>
            </tr>
            <tr class="tabela">
    <td colspan="3"><div align="center">Crit&eacute;rio de datas</div></td>
  </tr>
  <tr>
    <td height="24" class="TextoCampos">Lançamento entre:</td>
    <td class="CelulaZebra2"> 
      <strong>
      <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
	   		 onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong>e<strong>
      <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
	  		 onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong></td>
  </tr>
            <tr class="tabela">
                <td height="18" colspan="3">
                    <div align="center">Filtros</div></td>
            </tr>
            
                        <tr>
                            <td class="TextoCampos">Apenas o Cliente:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="rem_codigo" type="text" id="rem_codigo" size="1" value="" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value)" class="inputtexto">
                                    <input name="rem_cnpj" type="text" class="inputReadOnly" id="rem_cnpj" maxlength="23" size="18" value="" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value)">
                                    <input class="required inputReadOnly" type="text" size="30" name="rem_rzs" id="rem_rzs" value="" />
                                    <input type="button" class="botoes"
                                           onClick="launchPopupLocate('./localiza?acao=consultar&idlista=3','Cliente')" value="..." />
                                    <input type="hidden"  id="idremetente" name="idremetente"  value="0"  />
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaCliente()">
                                </strong>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Apenas o Vendedor:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <input name="ven_rzs" type="text" class="inputReadOnly" id="ven_rzs" maxlength="23" size="35" value="" >
                                    <input type="button" class="botoes"
                                           onClick="launchPopupLocate('./localiza?acao=consultar&idlista=27','Vendedor')" value="..." />
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaVendedor()">
                                </strong>
                            </td>
                        </tr>
                        <tr>
                            <td class="TextoCampos">Status:</td>
                            <td class="CelulaZebra2">
                                <strong>
                                    <select name="status" id="status" class="inputTexto" >
                                        <option value="" selected>Todos</option>
                                        <option value="0" >Em aberto</option>
                                        <option value="1" >Aprovado</option>
                                        <option value="2" >Não aprovado</option>
                                    </select>
                                </strong>
                            </td>
                        </tr>
            <tr>
                <td colspan="3" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
            </tr>
            <tr>
                <td colspan="3" class="TextoCampos"><div align="center">
                        <input type="radio" name="impressao" id="pdf" value="1" checked/>
                        <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                        <input type="radio" name="impressao" id="excel" value="2" />
                        <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                        <input type="radio" name="impressao" id="word" value="3" />
                        <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="TextoCampos"> <div align="center">
                        <%if (temacesso) {%>
                        <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                        <%}%>
                    </div></td>
            </tr>
        </table>
            
        </div>
        
                    <div id="tabDinamico">
                        
                    </div>
        
    </body>
</html>