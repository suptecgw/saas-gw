<%-- 
    Document   : cadastrar_ftp
    Created on : 19/06/2017, 10:41:47
    Author     : dcassimiro
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">

    jQuery.noConflict();

    var arAbasLayout = new Array();
    arAbasLayout[0] = new setAba('tdAbaAuditoria', 'divAuditoria');

    function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    function AlterneAba(menu, conteudo) {

        if (arAbasLayout != null) {
            for (i = 0; i < arAbasLayout.length; i++) {
                if (arAbasLayout[i] != null && arAbasLayout[i] != undefined) {
                    m = document.getElementById(arAbasLayout[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasLayout[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasLayout[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasLayout[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasLayout[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    }


    function carregar() {
        var action = '<c:out value="${param.acao}"/>';
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        if (action == 2) {
            $("idConfTransf").value = '<c:out value="${cadFtp.id}"/>';
            $("descricao").value = '<c:out value="${cadFtp.descricao}"/>';
            $("tipoProtocolo").value = '<c:out value="${cadFtp.tipoProtocolo}"/>';
            $("tipoCriptografia").value = '<c:out value="${cadFtp.tipoCriptografia}"/>';
            $("host").value = '<c:out value="${cadFtp.host}"/>';
            $("porta").value = '<c:out value="${cadFtp.porta}"/>';
            $("login").value = '<c:out value="${cadFtp.login}"/>';
            $("senha").value = '<c:out value="${cadFtp.senha}"/>';
            $("caminhoRemoto").value = '<c:out value="${cadFtp.caminhoArquivoRemoto}"/>';
            $("observacao").value = '<c:out value="${cadFtp.observacao}"/>';
        }
    }
    
    function escondeCriptografia(){
        if ($("tipoProtocolo") != null && $("tipoProtocolo").value == "sftp") {
            invisivel($("lbCriptografia"));
            invisivel($("tipoCriptografia"));
        }else{
            visivel($("lbCriptografia"));
            visivel($("tipoCriptografia"));
        }
    }

    function voltar() {
        tryRequestToServer(function () {
            (window.location = "ConsultaControlador?codTela=71");
        });
    }

    function salvar() {
        var formu = document.formulario;
        if ($("descricao").value.trim() == "") {
            return showErro("Informe a descrição!", $("descricao"));
        }
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        formu.submit();
        return true;
    }
    
    function testeConexao(){
        var user = $("login").value;
        var senha = $("senha").value;
        var porta = $("porta").value;
        var ip = $("host").value;
        var protocolo = $("tipoProtocolo").value;
        var criptografia = $("tipoCriptografia").value;
        jQuery.ajax({
                    url: '<c:url value="/FTPControlador" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        ftpServidor : user,
                        ip : ip,
                        porta : porta,
                        senha : senha,
                        tipoProtocolo: protocolo,
                        tipoCriptografia: criptografia,
                        acao : "testeConexao"
                    },
                    success: function(data) {
                        var ftp = JSON.parse(data);
                        if (ftp.boolean == true) {
                            alert("Conectado com sucesso!");
                        }else{
                            alert("Não foi Conectado!");
                        }
                    }
                });
    }

    function pesquisarAuditoria() {
        if (countLog != null && countLog != undefined) {
            for (var i = 1; i <= countLog; i++) {
                if ($("tr1Log_" + i) != null) {
                    Element.remove(("tr1Log_" + i));
                }
                if ($("tr2Log_" + i) != null) {
                    Element.remove(("tr2Log_" + i));
                }
            }
        }
        countLog = 0;
        var rotina = "Cadastrar FTP";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = $("idFtp").value;
        consultarLog(rotina, id, dataDe, dataAte);
    }

</script> 

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Cadastro FTP</title>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="65%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de FTP</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <form action="FTPControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}" id="formulario" name="formulario" method="post" target="pop">
            <table width="65%" align="center" class="bordaFina" >
                <tr>
                    <td align="center" class="CelulaZebra2" width="100%">
                        <fieldset>
                            <legend>Dados Principais</legend>
                            <table width="100%" class="tabelaZerada">
                                <tr>          
                                    <td class="TextoCampos">Descrição:</td>                        
                                    <td class="CelulaZebra2">
                                        <input name="descricao" id="descricao" type="text" class="fieldMin" size="50" maxlength="50"/>
                                        <input type="hidden" name="idConfTransf" id="idConfTransf"/>
                                    </td> 
                                    <td class="TextoCampos">
                                        Tipo Protocolo:</td>                        
                                    <td class="CelulaZebra2">
                                        <select class="fieldMin" id="tipoProtocolo" name="tipoProtocolo" onclick="escondeCriptografia();">
                                            <option value="ftp" selected>FTP</option>
                                            <option value="sftp">SFTP</option>
                                        </select>
                                    </td>
                                    <td class="TextoCampos" id="tdCriptografia" name="tdCriptografia">
                                        <label id="lbCriptografia" name="lbCriptografia">
                                            Tipo Criptografia:
                                        </label>
                                    </td>                        
                                    <td class="CelulaZebra2">
                                        <select class="fieldMin" id="tipoCriptografia" name="tipoCriptografia">
                                            <option value="1">Use FTP explícito sobre TLS se disponível</option>
                                            <option value="2">Requer FTP sobre TLS explícito</option>
                                            <option value="3">Requer FTP sobre TLS implícito</option>
                                            <option value="4" selected>Usar somente FTP simples (inseguro)</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="TextoCampos">Host:</td>                        
                                    <td class="CelulaZebra2" colspan="3">
                                        <input name="host" id="host" type="text" class="fieldMin" size="100" maxlength="100"/>
                                    </td>
                                    <td class="TextoCampos">Porta:</td>                        
                                    <td class="CelulaZebra2">
                                        <input name="porta" id="porta" type="text" class="fieldMin" size="5" maxlength="5"/>
                                    </td>
                                </tr>
                                <tr> 
                                <td class="TextoCampos">Login:</td>                        
                                <td class="CelulaZebra2">
                                    <input name="login" id="login" type="text" class="fieldMin" size="50" maxlength="50" />
                                </td>
                                <td class="TextoCampos">Senha:</td>                        
                                <td class="CelulaZebra2">
                                    <input name="senha" id="senha" type="password" class="fieldMin" size="50" maxlength="50"/>
                                </td>
                                <td class="TextoCampos">Caminho Remoto:</td>                        
                                <td class="CelulaZebra2">
                                    <input name="caminhoRemoto" id="caminhoRemoto" type="text" class="fieldMin" size="30" maxlength="30"/>
                                <td/>
                                </tr>
                                <tr>
                                <td class="TextoCampos">Observação:</td>
                                <td class="CelulaZebra2" colspan="4">
                                    <textarea name="observacao" cols="85" rows="3" class="fieldMin" id="observacao"></textarea>
                                </td>
                                <td class="TextoCampos">
                                    <input type="button" value="  TESTAR CONEXÃO  " id="botTestar" class="inputbotao">
                                </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
            </table>
            <table align="center" width="65%" >
                <tr>
                    <td width="100%">
                        <table align="left">
                            <tr>
                                <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>

                            </tr>
                        </table>
                    </td> 
                </tr>
            </table>
            <table width="65%" align="center" class="bordaFina" id="divAuditoria" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                </tr>
                <tr>
                    <td colspan="8"> 
                        <table width="100%" align="center" class="bordaFina">
                            <tr class="CelulaZebra2">
                                <td class="TextoCampos" width="15%"> Incluso:</td>

                                <td width="35%" class="CelulaZebra2"> em: ${cadFtp.dtInclusao} <br>
                                    por: ${cadFtp.usuarioInclusao.nome} 
                                </td>

                                <td width="15%" class="TextoCampos"> Alterado:</td>
                                <td width="35%" class="CelulaZebra2"> em: ${cadFtp.dtAlteracao} <br>
                                    por: ${cadFtp.usuarioAlteracao.nome}
                                </td>
                            </tr>   
                        </table>                  
                    </td>
                </tr>
            </table>
            <br/>
            <table width="65%" align="center" class="bordaFina" >                        
                <tr>
                    <c:if test="${param.nivel >= param.bloq}">
                        <td class="CelulaZebra2" ><div align="center">
                                <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function () {
                                            salvar();
                                        })"/>
                            </div></td>
                        </c:if>  
                </tr>
            </table>
        </form>
    </body>
</html>
