<%-- 
    Document   : dom-cidade-edi2
    Created on : 27/07/2018, 09:29:32
    Author     : manasses
--%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="col-md-12" data-gw-grupo-serializado="dom-cidade${param.qtdDom}" style="padding-left: 10px">
    <input type="hidden" id="idCidadeEDI${param.qtdDom}" name="idCidadeEDI${param.qtdDom}" value="${param.idCidadeEDI}" data-gw-campo-grupo-serializado="dom-cidade${param.qtdDom}" data-type="text">
    <div class="col-md-3">
        <span class="container-input-form-gw input-width-100">
            <input class="input-form-gw input-width-100 ativa-helper2" name="cidadeEDI${param.qtdDom}" id="cidadeEDI${param.qtdDom}" 
                   data-gw-campo-grupo-serializado="dom-cidade${param.qtdDom}" value="${param.valorCampo}" data-type="text" maxlength="40" data-ajuda="cidade EDI"
                   data-erro-validacao="Outro nome que a cidade possa ter, tanto por questão cultura como por erro de preenchimento. Exemplo: Para Cidade &quot;Jaboatao dos Guararapes&quot;, no XML ou NOTFIS é muito comum vir &quot;Jab. Guararapes&quot; ou &quot;Jaboatao Guararapes&quot;, ou por erro de digitação vir &quot;Jabotao do Guararapes&quot;.">
        </span>
    </div>
    <div class="col-md-1 input-width-90" >
        <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir ativa-helper-data-ajuda" onclick="excluirDom(this, 'idCidadeEDI${param.qtdDom}');" data-ajuda="icone-excluir-cidade">
    </div>
</div>
<script>
    jQuery("#cidadeEDI${param.qtdDom}").hover(
            function () {
                jQuery(".campo-helper h2").text("Nome da Cidade");
                jQuery(".descri-helper h3").html($(this).attr("data-erro-validacao"));
            },
            function () {
                jQuery('.campo-helper h2').html('Ajuda');
                jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
            }
    );
</script>