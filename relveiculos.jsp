<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("cadveiculo") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    String nomeprop = request.getParameter("nome");
    String idprop = request.getParameter("idproprietario");

    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        
        java.util.Map param = new java.util.HashMap(15);
        param.put("TIPO_FROTA", (request.getParameter("tipo_frota").equals("") ? "'%%'" : "'%" + request.getParameter("tipo_frota") + "%'"));
        param.put("ORDENACAO", request.getParameter("ordenacao"));
        param.put("OPCOES", "Todos os veículos");
        param.put("IDPROPRIETARIO", request.getParameter("nome").equals("") ? "" : "and idproprietario= " + request.getParameter("idproprietario"));
        param.put("ANO", request.getParameter("anoFabricacao").equals("") ? "" : "and ano= '" + request.getParameter("anoFabricacao") + "'");
        param.put("ANOMODELO", request.getParameter("anoModelo").equals("") ? "" : "and anomodelo= '" + request.getParameter("anoModelo") + "'");
        param.put("UF_EMPLAC", request.getParameter("uf").equals("") ? "" : "and ufemplac= '" + request.getParameter("uf") + "'");
        param.put("MODELO", request.getParameter("modeloVei").equals("") ? "" : "and modelo= '" + request.getParameter("modeloVei") + "'");
        param.put("IDCLIENTE", request.getParameter("idconsignatario").equals("0") ? "" : "and id_alocado_cliente=" + request.getParameter("idconsignatario"));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));

        request.setAttribute("map", param);
        request.setAttribute("rel", "veiculosmod" + request.getParameter("modelo"));

    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
    }else if (acao.equals("iniciar")){
       request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_VEICULO_RELATORIO.ordinal());
    }

%>


<script language="javascript" type="text/javascript">

    function popRel(){
        var modelo; 
        if (document.getElementById("modelo1").checked)
            modelo = 1;
        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";
    
        launchPDF('./relveiculos.jsp?acao=exportar&modelo='+modelo+'&impressao='+impressao+'&tipo_frota='+$('tipo_frota').value+'&ordenacao='+$('ordenacao').value+'&nome='+$('nome').value+'&idproprietario='+$('idproprietario').value+'&idconsignatario='+$('idconsignatario').value+'&modeloVei='+$('modeloVei').value+'&anoFabricacao='+$('anoFabricacao').value+'&anoModelo='+$('anoModelo').value+'&uf='+$('uf').value);
       
    }
    
    
    
    function localizaprop(){
           
        post_cad = window.open('./localiza?acao=consultar&idlista=1','proprietario',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
    function limparCliente(){
       $("con_rzs").value = "";
       $("idconsignatario").value = "0";
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

        <title>Webtrans - Relatório de Veículos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onload="AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Veículos</b></td>
            </tr>
        </table>

        <br>
        
        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
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
            <tr class="tabela" width="50%"> 
                <td colspan="4" ><div align="center">Modelos</div></td>
            </tr>
            <tr> 
                <td width="50%" height="24" class="TextoCampos"> <div align="left"> 
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked>
                        Modelo 1</div></td>
                <td width="100%" class="CelulaZebra2"> Rela&ccedil;&atilde;o de 
                    veículos.</td>
            </tr>
            <tr>
                <td colspan="4" class="tabela" ><div align="center">Filtros</div></td>
            </tr>
            <tr>
                <td class="TextoCampos">Tipo da frota: </td>
                <td class="CelulaZebra2" width="100%"><label>
                        <select name="tipo_frota" id="tipo_frota" class="inputtexto">
                            <option value="">Todos</option>
                            <option value="AGR">Agregada</option>
                            <option value="CAR">Carreteiro</option>
                            <option value="PR">Pr&oacute;pria</option>
                        </select>
                    </label></td>
            </tr>
            <tr>
                <td colspan="4" class="tabela"><div align="center">Ordenação</div></td>
            </tr>
            <tr>
                <td class="TextoCampos">Ordenar por: </td>
                <td class="CelulaZebra2" width="150%" ><label>
                        <select name="ordenacao" id="ordenacao" class="inputtexto">
                            <option value="placa">Placa</option>
                            <option value="numero_frota">Nº Frota</option>
                        </select>
                    </label></td>
            </tr>
            <tr>
                <td class="TextoCampos" >Apenas o Proprietário:</TD>
                <td colspan="3" class="CelulaZebra2" width="150%">
                    <input name="nome" type="text" readonly id="nome"  size="40" maxlength="50" class="inputReadOnly8pt">
                    <input  name="localiza_proprietario" type="button" class="botoes" id="localiza_proprietario" onClick="javascript:localizaprop('p')" value="...">
                    <input name="idproprietario" type="hidden" id="idproprietario"> 
                    <img src="img/borracha.gif" border="0" value="0" align="absbottom" class="imagemLink" onClick="javascript:$('idproprietario').value = '0';javascript:$('nome').value = '';">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas veiculos alocados no cliente: </td>
                  <td colspan="3" class="CelulaZebra2" width="150%">
                    <input name="idconsignatario" id="idconsignatario" type="hidden" value="0" value="">
                    <input name="con_rzs" id="con_rzs" size="40" class="inputReadOnly8pt" maxlength="50" value="" class="inputtexto" readonly >
                    <input name="localizar_cliente" type="button" class="botoes" id="localizar_cliente" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=59','Cliente')" value="...">
                    <strong>
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="limparCliente()">
                    </strong>   
                 </td>
            </tr>
            <tr>
                <td width="78" class="TextoCampos">Modelo:</td>
                <td width="127" class="CelulaZebra2"> 
                    <input name="modeloVei" type="text" id="modeloVei" size="20" maxlength="30" style="font-size:8pt;"  class="inputtexto" value="">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Ano de Fabricação:</td>
                <td class="CelulaZebra2">
                    <input name="anoFabricacao" id="anoFabricacao" maxlength="4" type="text" class="inputtexto" size="5" value=""/>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Ano do Modelo:</td>
                <td class="CelulaZebra2">
                    <input name="anoModelo" id="anoModelo" maxlength="4" type="text" class="inputtexto" size="5" value="" />
                </td>
            </tr>
            <tr>

                <td class="TextoCampos">*UF:</td>
                <td class="CelulaZebra2">                    

                    <select  name="uf" class="inputtexto" id="uf"  >
                        <option value="">Todos</option>
                        <option value="AC">AC</option>
                        <option value="AL">AL</option>
                        <option value="AM">AM</option>
                        <option value="AP">AP</option>
                        <option value="BA">BA</option>
                        <option value="CE">CE</option>
                        <option value="DF">DF</option>
                        <option value="ES">ES</option>
                        <option value="GO">GO</option>
                        <option value="MA">MA</option>
                        <option value="MG">MG</option>
                        <option value="MS">MS</option>
                        <option value="MT">MT</option>
                        <option value="PA">PA</option>
                        <option value="PB">PB</option>
                        <option value="PE" selected>PE</option>
                        <option value="PI">PI</option>
                        <option value="PR">PR</option>
                        <option value="RJ">RJ</option>
                        <option value="RN">RN</option>
                        <option value="RO">RO</option>
                        <option value="RR">RR</option>
                        <option value="RS">RS</option>
                        <option value="SC">SC</option>
                        <option value="SE">SE</option>
                        <option value="SP">SP</option>
                        <option value="TO">TO</option>
                        <option value="EX">EX</option>
                    </select>                       
                </td>
            </tr>

            <tr>
                <td colspan="4" class="tabela"><div align="center">Formato do relat&oacute;rio </div></td>
            </tr>
            <tr>
                <td colspan="4" class="TextoCampos"><div align="center">
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
                <td colspan="4" class="TextoCampos"> <div align="center">
                        <% if (temacesso) {%>
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
