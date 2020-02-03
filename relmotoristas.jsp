<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.ArrayList"%>
<%@page import="filial.BeanFilial"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="nucleo.imagem.ImagemControlador"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         nucleo.imagem.*,
         java.util.Date,
         java.io.File,
         nucleo.Apoio" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("cadmotorista") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));


    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        String modelo = request.getParameter("modelo"); // 19/08/13 mudança do tipo da variável modelo de int para String.
        String filial = "";
        String tipo = "";
        String idMotorista = "";
        String desligado = "";
        String cliente = "";
        String mes = request.getParameter("mes") == null ? "0" : request.getParameter("mes");
        if (modelo.equals("2")) {
            String caminho = (String) request.getSession().getAttribute("dir_home") + "img/motorista".replace('/', File.separatorChar);
            ImagemBO imagemBO = new ImagemBO(Apoio.getUsuario(request), caminho);
            MotoristaImagem imagem = new MotoristaImagem();
            imagem.setMotoristaId(Integer.parseInt(request.getParameter("idmotorista")));
            imagemBO.carregar(imagem);
            /*
             BeanCadImagem img = new BeanCadImagem(Apoio.getUsuario(request).getConexao().getConexao());
             img.getMotoristaImagem().setMotoristaId(Integer.parseInt(request.getParameter("idmotorista")));
             img.setCaminhoImagem( (String) request.getSession().getAttribute("dir_home") + "img/motorista".replace('/', File.separatorChar));
             //img.setConexao(Apoio.getUsuario(request).getConexao());
             //img.setExecutor(Apoio.getUsuario(request));

             img.LoadAllPropertys();
             * */
        }
        if (modelo.equals("6")) {
            filial = (request.getParameter("filial").equals("0") ? "" : " AND mot.filial_id=" + request.getParameter("filial"));
        } else {
            filial = (request.getParameter("filial").equals("0") ? "" : " AND filial_id=" + request.getParameter("filial"));
        }

        if (modelo.equals("2")|| modelo.equals("3") ||modelo.equals("4")) {
            if (modelo.equals("2")) {
                tipo = (request.getParameter("tipoMotorista") == null || request.getParameter("tipoMotorista").equals("todos") ? "" : " AND v.tipo_motorista2 = '" + request.getParameter("tipoMotorista") + "'");
            } else {
                tipo = (request.getParameter("tipoMotorista") == null || request.getParameter("tipoMotorista").equals("todos") ? "" : " AND tipo_motorista2 = '" + request.getParameter("tipoMotorista") + "'");
            }
        } else {
            tipo = (request.getParameter("tipoMotorista") == null || request.getParameter("tipoMotorista").equals("todos") ? "" : " AND tipo = '" + request.getParameter("tipoMotorista") + "'");
        }
        if (modelo.equals("2")) {
            idMotorista = (!request.getParameter("idmotorista").equals("0") ? " AND v.idmotorista=" + request.getParameter("idmotorista") : "");
        } else {
            idMotorista = (!request.getParameter("idmotorista").equals("0") ? " AND idmotorista=" + request.getParameter("idmotorista") : "");
        }

        desligado = (request.getParameter("desligado").equals("") ? "" : (request.getParameter("desligado").equals("true") ? " AND is_desligado = true" : "AND is_desligado = false"));
        cliente = (request.getParameter("idCliente") != null ? (request.getParameter("idCliente").equals("0") ? "" : " AND cliente_id= " + request.getParameter("idCliente")) : "");
        java.util.Map param = new java.util.HashMap(8);

        param.put("OPCOES", "Todos os motoristas");

        param.put("ID_MOTORISTA", idMotorista);
        //param.put("IDMOTORISTA", (request.getParameter("idmotorista").equals("0") ? ">0" : "=" + request.getParameter("idmotorista")));
        //param.put("FILIAL_ID", (Apoio.getUsuario(request).getFilial().getIdfilial()));
        param.put("ID_FILIAL", filial);
        param.put("TIPO_MOTORISTA", tipo);
        param.put("DESLIGADO", desligado);
        param.put("CLIENTE_ID", cliente);
        param.put("EMAIL_RETORNO", Apoio.getUsuario(request).getEmail());
        param.put("MES", !mes.equals("0") ? "and extract(month from datanasc)='" + mes + "'" : "");
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));

        request.setAttribute("map", param);
        request.setAttribute("rel", "motoristasmod" + modelo);
        if (modelo.startsWith("doc_Motorista_personalizado")) {//Verificando se o nome começa por como personalizado.
            request.setAttribute("rel", modelo);
        }

    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
        
        
    }else if(acao.equals("iniciar")){
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_MOTORISTA_RELATORIO.ordinal());
    }
    
%>


<script language="javascript" type="text/javascript">

    function modelos(modelo){
        getObj("modelo1").checked = false;
        getObj("modelo2").checked = false;
        getObj("modelo3").checked = false;
        getObj("modelo4").checked = false;
        getObj("modelo5").checked = false;
        getObj("modelo6").checked = false;
        getObj("modelo7").checked = false;
    
        getObj("modelo"+modelo).checked = true;

        $("trTipo").style.display = "";
            
        if(modelo==7){
            $("trMes").style.display = "";
        }else{
            $("trMes").style.display = "none";
        }

        if (modelo==5){
            $("trFiltros").style.display = "";
            $("trTipo").style.display = "";
        }
        
        
    }

    function popRel(){
        var modelo;
        if ($("modelo1").checked)
            modelo = 1;
        else if ($("modelo2").checked)
            modelo = 2;
        else if($("modelo3").checked)
            modelo = 3;
        else if($("modelo4").checked)
            modelo = 4;
        else if($("modelo5").checked)
            modelo = 5;
        else if($("modelo6").checked)
            modelo = 6;
        else if($("modelo7").checked)
            modelo = 7;
        
    
        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";
        
        launchPDF('./relmotoristas?acao=exportar&modelo='+modelo+'&impressao='+impressao+ '&filial='+$("filial").value 
            + '&tipoMotorista='+$("tipoMotorista").value + '&idmotorista=' + $("idmotorista").value + '&desligado=' + $("desligado").value
            + '&idCliente=' + $("idconsignatario").value + '&mes=' + $("mes").value );
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

        <title>Webtrans - Relatório de Motoristas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="modelos('1');AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
        </div>
       <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Motoristas</b></td>
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
                <tr class="tabela">
                    <td height="18" colspan="3"><div align="center">Modelos</div></td>
                </tr>
            <tr>
                <td width="50%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo1" id="modelo1" type="radio" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de
                    motoristas com dados da habilita&ccedil;&atilde;o e libera&ccedil;&atilde;o.</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo2" id="modelo2" type="radio" value="2" onClick="javascript:modelos(2);">
                        Modelo 2</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da ficha completa dos
                    motoristas</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo3" id="modelo3" type="radio" value="3" onClick="javascript:modelos(3);">
                        Modelo 3</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da ficha completa dos
                    motoristas com informações adicionais de frete</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo4" id="modelo4" type="radio" value="4" onClick="javascript:modelos(4);">
                        Modelo 4</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da ficha completa dos
                    motoristas com informações adicionais de frete</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo5" id="modelo5" type="radio" value="5" onClick="javascript:modelos(5);">
                        Modelo 5</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o da ficha completa dos
                    motoristas (Buonny).</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo6" id="modelo6" type="radio" value="6" onClick="javascript:modelos(6);">
                        Modelo 6</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de
                    motoristas com dados do cavalo e da carreta.</td>
            </tr>
            <tr>
                <td width="23%" height="24" class="TextoCampos"> <div align="left">
                        <input name="modelo7" id="modelo7" type="radio" value="7" onClick="javascript:modelos(7);">
                        Modelo 7</div></td>
                <td width="77%" colspan="2" class="CelulaZebra2"> Rela&ccedil;&atilde;o de
                    motoristas aniversariantes.</td>
            </tr>
            <tr class="tabela">
                <td colspan="3">
                    <div align="center">Filtros</div> 
                </td>

            </tr>
            <tr id="trTipo" name="trTipo">
                <td class="TextoCampos"><div align="right">Filiais:</div></td>
                <td class="CelulaZebra2">
                    <strong>
                        <select id="filial" name="filial" class="inputtexto" style="width: 90px">
                            <option value="0" selected>Todos</option>
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                                while (rsFl.next()) {%>
                            <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                        </select>
                    </strong>
                </td>
            </tr>
            <tr id="trTipo" name="trTipo">
                <td class="TextoCampos"><div align="right">Apenas o tipo:</div></td>
                <td class="CelulaZebra2">
                    <strong>
                        <select id="tipoMotorista" name="tipoMotorista" class="inputtexto" style="width: 90px">
                            <option value="todos" selected>Todos</option>
                            <option value="f">Funcionários</option>
                            <option value="a">Agregados</option>
                            <option value="c">Carreteiros</option>
                        </select>
                    </strong>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"><div align="right">Apenas o motorista:</div></td>
                <td class="CelulaZebra2">
                    <input name="idmotorista" type="hidden" class="inputReadOnly" id="idmotorista" value="0">
                    <input name="motor_nome" type="text" class="inputReadOnly" id="motor_nome" size="40" >
                    <input name="btMoto" id="btMoto" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                    <strong>
                        <img src="img/borracha.gif" border="0" id="lixoMoto" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';"> 
                    </strong>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"><div align="right">Apenas os:</div></td>
                <td class="CelulaZebra2">
                    <strong>
                        <select id="desligado" name="desligado" class="inputtexto" style="width: 90px">
                            <option value="" selected>Todos</option>
                            <option value="true">Desligados</option>
                            <option value="false">N&atilde;o Desligados</option>
                        </select>
                    </strong>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"><div align="right">Alocados no cliente:</div></td>
                <td class="CelulaZebra2">
                    <input name="idconsignatario" type="hidden" class="inputReadOnly" id="idconsignatario" value="0">
                    <input name="con_rzs" type="text" class="inputReadOnly" id="con_rzs" size="40" >
                    <input name="btMoto" id="btMoto" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=59','Cliente')" value="...">
                    <strong>
                        <img src="img/borracha.gif" border="0" id="lixoMoto" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:getObj('idconsignatario').value = 0;javascript:getObj('con_rzs').value = '';">
                    </strong>
                </td>
            </tr>
            <tr id="trMes" name="trMes">
                <td class="TextoCampos"><div align="right">Mês:</div></td>
                <td class="CelulaZebra2">
                    <strong>
                        <select id="mes" name="mes" class="inputtexto" style="width: 90px">
                            <option value="01" selected>Janeiro</option>
                            <option value="02">Fevereiro</option>
                            <option value="03">Março</option>
                            <option value="04" >Abril</option>
                            <option value="05">Maio</option>
                            <option value="06">Junho</option>
                            <option value="07" >Julho</option>
                            <option value="08">Agosto</option>
                            <option value="09">Setembro</option>
                            <option value="10" >Outubro</option>
                            <option value="11">Novembro</option>
                            <option value="12">Dezembro</option>
                        </select>
                    </strong>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <table width="100%" border="0" >
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
                                </div></td>
                        </tr>
                        <tr>
                            <td colspan="3" class="TextoCampos"> <div align="center">
                                    <% if (temacesso) {%>
                                    <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                                    <%}%>
                                </div></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
            
        
        </div>
       
                                
        <div id="tabDinamico">
            
          
        </div>
       
    </body>
</html>
