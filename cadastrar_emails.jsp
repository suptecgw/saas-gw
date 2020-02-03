<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">   
    
    jQuery.noConflict();
    
    var arAbasEmail = new Array();
    arAbasEmail[0] = new setAba('tdAbaAuditoria','divAuditoria');

function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

   function AlternarAbasGenerico(menu, conteudo) {
    try {
        if (arAbasEmail != null) {
            for (i = 0; i < arAbasEmail.length; i++) {
                if (arAbasEmail[i] != null && arAbasEmail[i] != undefined) {
                    m = document.getElementById(arAbasEmail[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasEmail[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasEmail[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasEmail[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasEmail[i].conteudo.split(",")[j].replace("div", "tr")), false);
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
    } catch (e) {
        alert(e);
    }
}
    
    function voltar(){
        tryRequestToServer(function(){(window.location  = "ConsultaControlador?codTela=67")});
    }
//teste subversion linha 18 =D
    function salvar(){
        var formu = document.formulario;
        if(formu.mailServidor.value == ""){
            alert("O campo 'Servidor' não pode ficar em branco!");
            formu.mailServidor.focus();
            return false;
        }else if(formu.mailPortaSmtp.value == ""){
            alert("O campo 'Porta SMTP' não pode ficar em branco!");
            formu.mailPortaSmtp.focus();
            return false;
        }else if(formu.mailRemetente.value == ""){
            alert("O campo 'Remetente' não pode ficar em branco!");
            formu.mailRemetente.focus();
            return false;
        }else if(formu.mailNomeRemetente.value == ""){
            alert("O campo 'Nome do remetente' não pode ficar em branco!");
            formu.mailNomeRemetente.focus();
            return false;
        }else if(formu.mailUsuario.value == ""){
            alert("O campo 'Usuário' não pode ficar em branco!");
            formu.mailUsuario.focus();
            return false;
        }else if(formu.mailSenha.value == ""){
            alert("O campo 'Senha' não pode ficar em branco!");
            formu.mailSenha.focus();
            return false;
        }else{
       
            window.open('about:blank', 'pop', 'width=210, height=100');

            $("formulario").submit();
            return true;
        }
    }


    function carregar(){
        
        var action = ${param.acao};
        $("dataDeAuditoria").value='<c:out value="${param.dataAtual}"  />'
        $("dataAteAuditoria").value='<c:out value="${param.dataAtual}"  />'
        
   
        if(action == "2"){
            $("id").value = '<c:out value="${email.id}"/>';
            $("mailServidor").value = '<c:out value="${email.mailServidor}"/>';
            $("mailPortaSmtp").value = '<c:out value="${email.mailSmtpPorta}"/>';
            $("mailRemetente").value = '<c:out value="${email.mailRemetente}"/>';
            $("mailNomeRemetente").value = '<c:out value="${email.mailNomeRemetente}"/>';
            $("descricao").value = '<c:out value="${email.descricao}"/>';
            $("mailUsuario").value = '<c:out value="${email.mailUsuario}"/>';
            $("mailSenha").value = '<c:out value="${email.mailSenha}"/>';
            $("mailProtocol").value = '<c:out value="${email.mailEntradaProtocol}"/>';
            $("mailPasta").value = '<c:out value="${email.mailPasta}"/>';
            $("mailPorta").value = '<c:out value="${email.mailEntradaPorta}"/>';
            $("mailServidorEntrada").value = '<c:out value="${email.mailServidorEntrada}"/>';
            
            
            if('${email.mailAutenticado}'=='true'){
                $("MailAutenticado").checked = true;
            }
            if('${email.ssl}' =='true'){
                $("isSSL").checked = true;
            }
            if('${email.starttls}' == 'true'){
                $("isStartTLS").checked = '<c:out value="${email.starttls}"/>';
            }
            if('${email.fatura}'=='true'){
                $("isFatura").checked = true;
            } 
        }
    }   
    
    
    
    function alterarPreferenciaEmail(valor){
       
        if(valor=='b'){
            $('trPreferenciaEmail').style.display = "";
        }else if(valor == 'a'){
            $('trPreferenciaEmail').style.display = "none";
        }
           
    }
    
     function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "config_emails";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    
    function carregarPastasEmails(){
        var conta = $("mailUsuario").value;
        var senha = $("mailSenha").value;
        
        if (conta.trim() == "") {
            alert("A conta deve ser preenchida!.");
            return  false;
        } else if (senha.trim() == ""){
            alert("A senha deve ser preenchida!.");
            return  false;
        }
        
        espereEnviar("", true);
        
        jQuery.ajax({
            url: '<c:url value="/ArquivoImportacaoXMLControlador" />',
            dataType: "text",
            method : "post",
            async : false,
            data: {
                descricao : $("descricao").value,
                mailServidor : $("mailServidor").value, 
                mailPortaSmtp : $("mailPortaSmtp").value, 
                mailRemetente : $("mailRemetente").value, 
                mailNomeRemetente : $("mailNomeRemetente").value, 
                MailAutenticado : $("MailAutenticado").value, 
                isSSL : $("isSSL").checked, 
                isStartTLS : $("isStartTLS").checked, 
                isFatura : $("isFatura").checked, 
                mailUsuario : $("mailUsuario").value, 
                mailSenha : $("mailSenha").value, 
                mailPorta : $("mailPorta").value, 
                mailProtocol : $("mailProtocol").value, 
                mailServidorEntrada : $("mailServidorEntrada").value, 
                acao : "listaPastas"
            },
            success: function(data) {
                if (data.indexOf("ERRO:") > -1) {
                    alert(data);
                } else {
                    var retorn = jQuery.parseJSON(data);
                    var list = retorn.list[0];
                    var strg = list.string;
                    $("selectPasta").update();
                    var selectPastas = jQuery("#selectPasta");

                    selectPastas.append(jQuery('<option>', {
                        value: "",
                        text: "Selecione"
                    }));
                    for(var i = 0; i < strg.length; i++){
                        selectPastas.append(jQuery('<option>', {
                            value: strg[i],
                            text: strg[i]
                        }));
                    }
                    selectPastas.show();
                    jQuery("#mailPasta").hide();
                    jQuery("#isSelect").val("true");
                }
            }
        });
        espereEnviar("", false);
    }
    
</script>

<%@page import="fpag.BeanFPag"%>
<%@page import="java.sql.ResultSet"%>


<html>

    <script src="script/prototype.js" type="text/javascript"></script>
    <script type="text/javascript" src="script/fabtabulous.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="content-language" content="pt" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="pragma" content="no-store" />
    <meta http-equiv="expires" content="0" />
    <meta name="language" content="pt-br" />


    <link href="estilo.css" rel="stylesheet" type="text/css">
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
        <title>Webtrans - Cadastro de E-mails</title>
    </head>
    <body onload="carregar();applyFormatter();">
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de E-mail</span></td>
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <!-- codigo de verificaao de acao editar = 2  ou cadastrar = ?? -->
        <form action="EmailControlador?acao=${param.acao == 2 ? "editar": "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" id="id" name="id" value="0">
            <table width="80%" align="center" class="bordaFina" >
                <tr>
                    <td colspan="5" class="tabela">
                        <div align="center">
                            Configura&ccedil;&atilde;o para Envio de E-mails Autom&aacute;ticos
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">
                        Descrição:
                    </td>
                    <td class="CelulaZebra2">
                        <input name="descricao" id="descricao" type="text" size="30" maxlength="50" class="inputtexto" value="">
                    </td>
                    <td class="TextoCampos">

                    </td>
                    <td class="CelulaZebra2" colspan="2">

                    </td>
                </tr>
                <tr>
                    <td width="20%" class="TextoCampos">
                        Servidor SMTP: 
                    </td>
                    <td width="30%" class="CelulaZebra2">
                        <input name="mailServidor" class="inputtexto" id="mailServidor" type="text" size="30" maxlength="100" value="">
                    </td>
                    <td width="16%" class="TextoCampos">
                        Porta:
                    </td>
                    <td width="34%" class="CelulaZebra2" >
                        <input name="mailPortaSmtp" class="inputtexto" id="mailPortaSmtp" type="text" size="10" value="" maxlength="5" onkeypress="mascara(this, soNumeros)">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">
                        Remetente:
                    </td>
                    <td class="CelulaZebra2">
                        <input name="mailRemetente" id="mailRemetente" type="text" size="30" maxlength="50" class="inputtexto" value="">
                    </td>
                    <td class="TextoCampos">
                        Nome:
                    </td>
                    <td class="CelulaZebra2">
                        <input name="mailNomeRemetente" class="inputtexto" id="mailNomeRemetente" type="text" size="30" maxlength="30" value="">
                    </td>
                </tr>
                <tr>
                    <td width="80%" colspan="5" class="TextoCampos">
                        <table width="80%" >
                            <tr>
                                <td class="TextoCampos">
                                    <div align="center">
                                        <input name="MailAutenticado" type="checkbox" id="MailAutenticado" value="true" >
                                        Servidor Requer Autentica&ccedil;&atilde;o
                                    </div>
                                </td>
                                <td class="TextoCampos">
                                    <div align="center">
                                        <input name="isSSL" type="checkbox" id="isSSL" value="true" >
                                        Utilizar SSL
                                    </div>
                                </td>
                                <td class="TextoCampos">
                                    <div align="center">
                                        <input name="isStartTLS" type="checkbox" id="isStartTLS" value="true" >
                                        Utilizar STARTTLS
                                    </div>
                                </td>
                                <td class="TextoCampos">
                                    <div align="center">
                                        <input name="isFatura" type="checkbox" id="isFatura" value="true" >
                                        E-mail para envio de fatura
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Conta:</td>
                    <td class="CelulaZebra2">
                        <input name="mailUsuario" id="mailUsuario" class="inputtexto" type="text" size="30" maxlength="50" value="">
                    </td>
                    <td class="TextoCampos">
                        Senha:
                    </td>
                    <td class="CelulaZebra2">
                        <input name="mailSenha" id="mailSenha" class="inputtexto" type="password" size="20" maxlength="20" value="">
                    </td>
                </tr>
                <tr>
                    <td width="100%" colspan="8">
                         <table width="100%">
                             <tr>
                                <td colspan="8" class="tabela">
                                    <div align="center">
                                        Configurações de Entrada
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" width="10%">Pasta: </td>
                                <td class="CelulaZebra2" width="20%">
                                    <input id="mailPasta" name="mailPasta" class="inputtexto" type="text" size="15" maxlength="30" value="">
                                    <select id="selectPasta" name="selectPasta" style="display: none" class="inputTexto">
                                        <option value="">Selecione</option>
                                    </select>
                                    <input type="button" name="atualizarPastas" id="atualizarPastas" value="Atualizar pastas" class="inputBotao" onclick="javascript: carregarPastasEmails();">
                                    <input type="hidden" name="isSelect" id="isSelect" value="false">
                                </td>
                                <td class="TextoCampos" width="10%">Servidor de Entrada: </td>
                                <td class="CelulaZebra2" width="10%">
                                    <input id="mailServidorEntrada" name="mailServidorEntrada" class="inputtexto" type="text" size="20" maxlength="100" value="">
                                </td>
                                <td class="TextoCampos" width="10%">Porta do Entrada: </td>
                                <td class="CelulaZebra2" width="20%">
                                    <input id="mailPorta" name="mailPorta" class="inputtexto" type="text" size="10" maxlength="10" value="">
                                </td>
                                <td class="TextoCampos" width="34%">
                                    <div align="center">
                                        Tipo de Protocolo : 
                                        <select id="mailProtocol" name="mailProtocol" class="inputtexto" >
                                            <option value="imap"> IMAP</option>
                                            <option value="imaps"> IMAPS</option>
                                            <option value="pop3"> POP3</option>
                                        </select>
                                    </div>
                                </td>
                            </tr>
                        </table> 
                    </td>
                </tr>
            </table>
                    <table align="center" width="80%">
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
            <table width="80%"  class="bordaFina" align="center" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                    <tr>
                        <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                    </tr>
                    <tr>
                        <td colspan="6">
                            <table width="100%" align="center" class="bordaFina">
                                <tr class="CelulaZebra2">
                                    <td class="TextoCampos" width="15%"> Incluso:</td>

                                    <td width="35%" class="CelulaZebra2"> em: ${email.criadoEm} <br>
                                        por: ${email.criadoPor.nome}
                                    </td>

                                    <td width="15%" class="TextoCampos"> Alterado:</td>
                                    <td width="35%" class="CelulaZebra2"> em: ${email.alteradoEm} <br>
                                        por: ${email.alteradoPor.nome}
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
            </table>
           <br/>
             <table width="80%" border="0" class="bordaFina" align="center" style='display: ${param.nivel >= 2 ? "" : "none"}'>                        
                <tr class="CelulaZebra2">
                    <td >
                        <div align="center">
                            <input name="salvar2" type="button" class="botoes" id="salvar2" value="   Salvar   " onClick="salvar()">
                        </div>
                    </td>
                </tr>
            </table>       
        </form>
    </body>
</html>
