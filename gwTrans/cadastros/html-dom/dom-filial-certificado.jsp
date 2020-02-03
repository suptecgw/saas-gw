<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div data-gw-grupo-serializado="dom-filial${param.qtdDom}" data-gw-grupo-name="filiais">
    <div style="margin-bottom: 0;width: 40px;float: left;text-align: center;" data-ajuda="remover_filial_certificado">
        <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir" onclick="excluirDom(this, 'filialId${param.qtdDom}');">
    </div>
    <div class="col-md-11 body-dom-filiais">
        <input type="hidden" id="filialId${param.qtdDom}" name="filialId${param.qtdDom}" value="${param.filialId}" data-gw-campo-grupo-serializado="dom-filial${param.qtdDom}" data-type="text">
        <input type="hidden" id="abreviatura${param.qtdDom}" name="abreviatura${param.qtdDom}" value="${param.abreviatura}">
        <input type="hidden" id="cnpj${param.qtdDom}" name="cnpj${param.qtdDom}" value="${param.cnpj}">

        <label class="col-md-3 label-razao-filial">${param.abreviatura}</label>
        <label class="col-md-3">${param.cnpj}</label>
        <label class="col-md-3">${param.cidade}-${param.uf}</label>
    </div>
</div>
