<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="col-md-12" data-gw-grupo-serializado="dom-municipio${param.qtdDom}" style="padding-left: 10px">
    <input type="hidden" id="idMunicipio${param.qtdDom}" name="idMunicipio${param.qtdDom}" value="${param.idMunicipio}" data-gw-campo-grupo-serializado="dom-municipio${param.qtdDom}" data-type="text">

    <div class="col-md-10">
        <span class="container-input-form-gw input-width-90">
            <input class="input-width-100 ativa-helper" name="municipio${param.qtdDom}" id="municipio${param.qtdDom}" data-gw-campo-grupo-serializado="dom-municipio${param.qtdDom}" data-type="text">
        </span>
        <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarCidade', 'municipio${param.qtdDom}')"/>
    </div>
    <div class="col-md-1" >
        <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir ativa-helper-data-ajuda" onclick="excluirDom(this, 'idMunicipio${param.qtdDom}');" data-ajuda="icone-excluir-municipio">
    </div>
</div>
<script>
    $(document).ready(function () {
        $('#municipio${param.qtdDom}').inputMultiploGw({
            readOnly: 'true',
            width: '97%',
            isSimples: 'true',
            notX:'true'
        });
        

        if ('${param.valorCampo}' !== '') {
            var split = decodeURI('${param.valorCampo}').split("!!");
            // primeiro par�metro � o input, segundo � o que mostrar no input e terceiro � o id
            addValorAlphaInput('municipio${param.qtdDom}', split[0], split[1]);

        }

        carregarAjudaData();
    });
</script>