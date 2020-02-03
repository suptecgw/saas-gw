
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="JavaScript" type="text/javascript" src="script/situacaoPessoa.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>

<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    var campos;
    function consultar() {
        if (!window.gwsistemas) {
            if (navigator.userAgent.indexOf('Chrome') != -1) {
                alert('Atenção, é necessário ter a extensão da GW Sistemas instalada para utilizar essa rotina, você pode encontrar nossa extensão na Chrome Web Store ou no botão "Ir para webstore".');
                jQuery('.trBt').show();
                jQuery('#irWebStore').show();
                return;
            } else {
                alert('Atenção, é necessário ter a extensão da GW Sistemas instalada para utilizar essa rotina, você pode encontrar nossa extensão na Firefox Add-ons ou no botão "Ir para firefox add-ons".');
                jQuery('.trBt').show();
                jQuery('#irFirefox').show();
                return;
            }
        } else {
            jQuery('.trBt').hide();
            jQuery('#irFirefox').hide();
            jQuery('#irWebStore').hide();
        }

        var cnpj = jQuery('#cnpj').val();
        var popChave = window.open('http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/cnpjreva_solicitacao2.asp?cnpj=' + cnpj, '', 'width=1000, height=700,scrollbars=1');
        jQuery('.block-tela').show();

        var pai = window.opener;
        var textErro = "Não foi possivel realizar a consulta, verifique os dados e tente novamente!";
        localStorage.setItem("cnpj",cnpj);
        var interval = setInterval(function () {
            if (localStorage.getItem(cnpj) && localStorage.getItem(cnpj) !== 'undefined') {
                try {
                    jQuery.ajax({
                        'url': 'ConsultaSituacaoControlador?acao=consultarPessoaJuridica',
                        data: {
                            'html': localStorage.getItem(cnpj),
                            'cnpj': cnpj
                        },
                        'method': 'post',
                        complete: function (data, textStatus, jqXHR) {
                            if (data != null && data.responseText != "") {
                                var lista = jQuery.parseJSON(data.responseText);
                                var pj = lista.pessoaJuridica;
                                var cep = replaceAll(replaceAll(pj.cep, ".", ""), "-", "");
                                pai.getCidadeAjax(pj.municipio, pj.uf);
                                campos = eval(decodeURI('${param.campos}'));
                                if (campos != null && campos != undefined) {
                                    if (campos.idRazaoSocial != "") {
                                        pai.$(campos.idRazaoSocial).value = pj.razaoSocial;
                                    }
                                    if (campos.idNomeFantasia != "") {
                                        pai.$(campos.idNomeFantasia).value = pj.nomeFantasia;
                                    }
                                    if (campos.idLogradouro != "") {
                                        pai.$(campos.idLogradouro).value = pj.logradouro;
                                    }
                                    if (campos.idLogradouroNumero != "") {
                                        pai.$(campos.idLogradouroNumero).value = pj.numero;
                                    }
                                    if (campos.idComplemento != "") {
                                        pai.$(campos.idComplemento).value = pj.complemento;
                                    }
                                    if (campos.idCep != "") {
                                        pai.$(campos.idCep).value = cep;
                                    }
                                    if (campos.idBairro != "") {
                                        pai.$(campos.idBairro).value = pj.bairro;
                                    }
                                }
                                jQuery('.block-tela').hide();
                                popChave.close();
                                clearInterval(interval);
                                alert("Consulta realizada com sucesso!");
                                window.close();
                                localStorage.clear();

                            } else {
                                jQuery('.block-tela').hide();
                                popChave.close();
                                clearInterval(interval);

                                alert(textErro);
                                recarregar();
                                localStorage.clear();
                            }
                        }
                    });
                } catch (ex) {
                    jQuery('.block-tela').hide();
                    popChave.close();
                    clearInterval(interval);

                    localStorage.clear();
                    alert(textErro);
                    recarregar();
                }
            }
        }, 1000);
    }

    function recarregar() {
        document.location.reload();
    }

    function imprimir() {
        var formu = document.formulario;
        janela = window.open('about:blank', 'pop', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
        formu.submit();
        return true;
    }

    function carregar() {
        try {
            $("cnpj").value = "${param.cnpj}";
        } catch (ex) {
            alert(ex);
        }
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
        <title>Webtrans - Consultar Cadastro de Pessoa Juridica</title>
    </head>
    <body onload="carregar();">
        <!--body onload="applyFormatter();carregar();">-->
        <form action="ConsultaSituacaoControlador?acao=consultarPessoaJuridica" id="formulario" name="formulario" method="post" target="pop">
            <img src="img/banner.gif"  align="middle">

            <input type="hidden" name="idCliente" id="idCliente" value="0">
            <input type="hidden" name="campos" id="campos" value="0">

            <table width="55%" height="28" align="center" class="bordaFina" >
                <tr>
                    <td width="82%" align="left">
                        <img src="./img/receita.png" height="25" border="0" align="absbottom" />
                        <span class="style4">Consultar Cadastro de Pessoa Juridica</span></td>
                    <td>
                        <input type="button" value=" Fechar " class="inputbotao" onclick="window.close();"/>
                    </td>
                </tr>
            </table>
            <br>

            <table width="55%" border="0" class="bordaFina" align="center">
                <tr>
                    <td width="30%" class="textoCampos">
                        CNPJ:
                    </td>
                    <td width="25%" class="CelulaZebra2"> 
                        <input type="text" name="cnpj" readonly id="cnpj" class="inputReadOnly" size="20" maxlength="14" onkeypress="mascara(this, soNumeros);"/>
                    </td>
                    <td width="45%" class="textoCampos"></td>
                </tr>
                <tr class="trBt" style="display: none;">
                    <td class="CelulaZebra2" colspan="3">
                        <center>
                            <input type="button" value="Ir para webstore" id="irWebStore" style="display:none;" onclick="window.open('https://chrome.google.com/webstore/detail/gw-sistemas/eegmcpafdbgpjdjocjfffnkjihijhagb','','height=650, width=800, scrollbars=yes,resizable=yes');return false;" class="inputBotao">
                            <input type="button" value="Ir para firefox add-ons" id="irFirefox" style="display:none;" onclick="window.open('https://addons.mozilla.org/pt-BR/firefox/addon/gw-sistemas/','','height=650, width=800, scrollbars=yes,resizable=yes');" class="inputBotao">
                        </center>
                    </td>
                </tr>
                <tr>
                    <td colspan="3" class="TextoCampos">
                        <div align="center">
                            <input name="botConsultar" type="button" class="inputbotao" id="botConsultar" value="  CONSULTAR  " onClick="tryRequestToServer(function () {
                                        consultar()
                                    })"/>
                        </div>
                    </td>
                </tr>
            </table>
        </form>
    <style>
        .block-tela{
            position: absolute;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            top: 0;
            left: 0;
            z-index: 99999;
            display: none;
        }
    </style>
    <div class="block-tela"></div>
</body>
</html>
