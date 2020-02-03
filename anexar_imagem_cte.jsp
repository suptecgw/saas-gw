<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<script>
    var dataAtual = '${param.dataAtual}';
    var horaAtual = '${param.horaAtual}';
    var podeProcurarOcorrencia = ${podeProcurarOcorrencia};
    var podeBaixar = ${podeBaixar};
    let obrigarOcorrenciaConfiguracao = "${obrigarOcorrenciaConfiguracao}";
</script>
<script src="script/builder.js?v=${random.nextInt()}"></script>
<script src="script/prototype.js?v=${random.nextInt()}"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script src="script/funcoes.js?v=${random.nextInt()}"></script>
<script src="${homePath}/script/funcoesTelaAnexarImagemCTe.js?v=${random.nextInt()}"></script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link rel="stylesheet" href="${homePath}/estilo.css?v=${random.nextInt()}">
        <link rel="stylesheet" href="${homePath}/assets/css/anexar_imagem_cte.css?v=${random.nextInt()}">
        <title>Webtrans - Anexar Imagens CT-e</title>
        <script>
            let homePath = "${homePath}";
            let linkGwOCR = "${linkGwOCR}";
        </script>
        <style>
            #btnSalvar, #btnAnexar, #btnRepetir, #btnLocalizarOcorrencia {
                cursor: pointer;
            }
        </style>
    </head>
    <body onload="carregar();">
        <img src="${homePath}/img/banner.gif"> 
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="100%" align="left">
                    <span class="style4">Anexar Imagens CT-e</span>
                </td>            
            </tr>
        </table>
        <br/>
        <form id="formAnexarImagem" name="formAnexarImagem" action="AnexarImagemControlador?acao=anexarImagemCte" method="post" target="pop" enctype="multipart/form-data">
            <table class="bordaFina" width="80%" align="center">
                <tr class="CelulaZebra2NoAlign">
                    <td width="10%" class="TextoCampos">
                        <label>Localizar por:</label>                        
                    </td>
                    <td width="40%" class="CelulaZebra2">
                        <input type="radio" id="tipoDocumentoChaveAcessoNFe" name="tipoDocumento" value="chaveAcessoNFe" checked>
                        <label for="tipoDocumentoChaveAcessoNFe">Chave de acesso da NF-e</label>
                        <input type="radio" id="tipoDocumentoChaveAcessoCTe" name="tipoDocumento" value="chaveAcessoCTe">
                        <label for="tipoDocumentoChaveAcessoCTe">Chave de acesso do CT-e</label>
                        <input type="radio" id="tipoDocumentoNumeroCanhotoNFe" name="tipoDocumento" value="numeroCanhotoNFe"> 
                        <label for="tipoDocumentoNumeroCanhotoNFe">Número da NF-e no canhoto</label>
                    </td>
                    <td width="10%" class="TextoCampos">
                        <label>Arquivo:</label>
                    </td>
                    <td width="25%">
                        <input name="inputAnexarArquivos[]" id="inputAnexarArquivos" type="file" multiple class="inputTexto" size="50" accept="image/*">
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign" style="display: none;" id="localizarRemetenteTR">
                    <td class="TextoCampos">
                        <label>Remetente:</label>
                    </td>
                    <td colspan="3">
                        <div align="left">
                            <input id="rem_rzs" name="rem_rzs" class="inputReadOnly" value="" type="text" size="52" readonly>
                            <input id="idremetente" name="idremetente" type="hidden" value="0">
                            <input id="btLocalizaRemetente" name="btLocalizaRemetente" type="button" onclick="abrirLocalizarRemetente()" class="inputBotaoMin" value="...">
                        </div>
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td class="CelulaZebra2" colspan="4">
                        <div align="center">
                            <input type="button" id="btnAnexar" name="btnAnexar" value="  Anexar  " class="inputbotao" onclick="tryRequestToServer(function(){anexarCte()});">
                        </div>
                    </td>
                </tr>
            </table>            
        </form>
        <form id="formRedefinir" name="formRedefinir" action="" method="post">
            <table class="bordaFina" width="80%" align="center">
                <tr class="CelulaZebra2NoAlign">
                    <td class="TextoCampos">
                        <label>Descrição da Imagem:</label>
                    </td>
                    <td class="CelulaZebra2" colspan="4">
                        <input type="text" id="descricaoImagem" name="descricaoImagem" class="inputtexto">
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign" ${not podeBaixar ? 'style="display: none;"' : ''}>
                    <td class="TextoCampos">
                        <label>
                            <input type="checkbox" id="chkBaixarEntrega" name="chkBaixarEntrega" value="true">                    
                            Baixar Entrega
                        </label>
                    </td>
                    <td class="TextoCampos">
                        <label>
                            Data Entrega:                        
                        </label>
                    </td>
                    <td class="CelulaZebra2">
                        <input type="text" id="dataEntrega" name="dataEntrega" size="10" maxlength="10" class="inputtexto"
                               onblur="alertInvalidDate(this, true)" onkeydown="fmtDate(this, event)" onkeyup="fmtDate(this, event)"
                               onkeypress="fmtDate(this, event)">
                        às
                        <input type="text" id="horaEntrega" name="horaEntrega" value="" onblur="" size="5" maxlength="5" class="inputtexto"
                               onkeyup="mascaraHora(this)">                    
                    </td>
                    <td class="TextoCampos">
                        <div ${not podeProcurarOcorrencia ? 'style="visibility: hidden;"' : ''}>
                            <label>
                                Ocorrência:                        
                            </label>
                        </div>
                    </td>
                    <td class="CelulaZebra2">
                        <div ${not podeProcurarOcorrencia ? 'style="visibility: hidden;"' : ''}>
                            <input type="text" id="codigoOcorrencia" name="codigoOcorrencia" class="inputtexto" size="5" maxlength="3" onChange="seNaoIntReset(this,'');" onKeyUp="if (event.keyCode==13) localizarOcorrenciaCodigo(this);">
                            <input type="text" id="descricaoOcorrencia" name="descricaoOcorrencia" class="inputReadOnly" size="25" value="" readonly>
                            <input type="hidden" id="idOcorrencia" name="idOcorrencia" value="0">
                            <input type="button" id="btnLocalizarOcorrencia" name="btnLocalizarOcorrencia" value="..." class="inputbotao" title="Localizar Ocorrência" onclick="tryRequestToServer(function(){abrirLocalizaOcorrencia()});">
                        </div>
                    </td>                        
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td class="TextoCampos">
                        <label>
                            <input type="checkbox" id="chkComprovanteEntrega" name="chkComprovanteEntrega" value="true">
                            Baixar Comprovante
                        </label>
                    </td>
                    <td class="TextoCampos">
                        <label>
                            Chegada Comprovante:
                        </label>
                    </td>
                    <td class="celulaZebra2">
                        <input type="text" id="dataComprovante" name="dataComprovante" size="10" maxlength="10" class="inputtexto"
                               onblur="alertInvalidDate(this, true)" onkeydown="fmtDate(this, event)" onkeyup="fmtDate(this, event)"
                               onkeypress="fmtDate(this, event)">
                        às
                        <input type="text" id="horaComprovante" name="horaComprovante" value="" onblur="" size="5" maxlength="5" class="inputtexto"
                               onkeyup="mascaraHora(this)">
                    </td>
                    <td class="CelulaZebra2"></td>
                    <td class="CelulaZebra2"></td>
                    <td class="CelulaZebra2"></td>
            </tr>

                <tr>
                    <td class="TextoCampos">
                        <label>
                            Observação:                        
                        </label>
                    </td>
                    <td class="CelulaZebra2" colspan="4">
                        <textarea id="obsEntrega" name="obsEntrega" class="inputtexto" cols="90" rows="4"></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra2" colspan="5">
                        <div align="center">
                            <input type="button" id="btnRepetir" name="btnRepetir" value="  Repetir  " onclick="tryRequestToServer(function(){repetir();})" class="inputbotao">                        
                        </div>
                    </td>
                </tr>
            </table>
        </form>
        <form id="formSalvar" name="formSalvar">
            <input type="hidden" id="ocorrencia_id" value="0">
            <input type="hidden" id="ocorrencia" value="">
            <input type="hidden" id="descricao_ocorrencia" value="">
            <input type="hidden" id="index" name="index" value="0">
            <input type="hidden" id="id" name="id" value="0">
            <input type="hidden" id="numero" name="nfiscal" value="">
            <input type="hidden" id="chave_acesso_cte" name="chave_acesso_cte" value="">
            <input type="hidden" id="remetente" name="remetente" value="">
            <input type="hidden" id="destinatario" name="destinatario" value="">
            <input type="hidden" id="consignatario" name="consignatario" value="">
            <input type="hidden" id="filial" name="filial" value="">
            <input type="hidden" id="cidade_destino" name="cidade_destino" value="">
            <input type="hidden" id="cidade_origem" name="cidade_origem" value="">
            <input type="hidden" id="baixa_em" name="baixa_em" value="">
            <input type="hidden" id="numero_nf" name="numero_nf" value="">
            <input type="hidden" id="uf_origem" name="uf_origem" value="">
            <input type="hidden" id="uf_destino" name="uf_destino" value="">
<%--            <input type="hidden" id="isChaveAcesso" name="isChaveAcesso" value="false">--%>
<%--            <input type="hidden" id="numero_carga" name="numero_carga" value="">--%>
<%--            <input type="hidden" id="pedido_cliente" name="pedido_cliente" value="">--%>
<%--            <input type="hidden" id="tipo" name="tipo" value="">--%>
<%--            <input type="hidden" id="emissao_em" name="emissao_em" value="">--%>
<%--            <input type="hidden" id="id" name="id" value="">--%>
<%--            <input type="hidden" id="id_remetente" name="id_remetente" value="">--%>
<%--            <input type="hidden" id="cnpj_remetente" name="cnpj_remetente" value="">--%>
<%--            <input type="hidden" id="id_destinatario" name="id_destinatario" value="">--%>
<%--            <input type="hidden" id="end_remetente" name="end_remetente" value="">--%>
<%--            <input type="hidden" id="cnpj_destinatario" name="cnpj_destinatario" value="">--%>
<%--            <input type="hidden" id="id_cidade_destino" name="id_cidade_destino" value="">--%>
<%--            <input type="hidden" id="end_destinatario" name="end_destinatario" value="">--%>
<%--            <input type="hidden" id="idfilial" name="idfilial" value="">--%>
<%--            <input type="hidden" id="id_consignatario" name="id_consignatario" value="">--%>

            <input type="hidden" id="maxCte" name="maxCte">

            <table class="bordaFina" width="80%" align="center">            
                <tr class="CelulaZebra1NoAlign" >
                    <td colspan="10">
                        <div align="center">                            
                            Anexar Imagem CT-e                        
                        </div>
                    </td>
                </tr>
                <tbody id="tbImagemCte">
                </tbody>
            </table>
            <br/>
            <table class="bordaFina" width="80%" align="center">
                <tr class="CelulaZebra2NoAlign">
                    <td class="CelulaZebra2" colspan="8">
                        <div align="center">
                            <input type="button" id="btnSalvar" name="btnSalvar" value="  Salvar  " onclick="tryRequestToServer(function(){salvar()});" class="inputbotao">
                        </div>
                    </td>
                </tr>
            </table>
        </form>
        <div class="cobre-tudo"></div>
        <div class="bloqueio-aguarde" style="display: none;">
            <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt="" style="display: inline-block;">
            <strong class="gif-bloq-tela"
                    style="display: inline-block;margin-left:-40px;font-size:20px;margin-top:70px;">
                Aguarde...
            </strong>
        </div>
        <div class="bloqueio-tela"></div>
    </body>
</html>
