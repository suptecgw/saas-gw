<%-- 
    Document   : formula
    Created on : 28/02/2018, 06:08:16
    Author     : KALUNGA
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${param.tema}.css?v=${random.nextInt()}"/>
        <link href="${homePath}/gwTrans/cadastros/css/formula.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <div class="container-formula">
            <div class="topo-formula"><img src="${homePath}/assets/img/logo.png" class="logo-gwsistemas">Editar Fórmula<img src="${homePath}/assets/img/sair.png" class="img-sair-formula" onclick="window.parent.fecharFormula($('#grupoID').val())"></div>
            <div class="corpo-formula">
                <div class="nome-formula zebra">Peso:</div>
                <div class="formula zebra">@@peso</div>
                <div class="nome-formula zebra">Valor Mercadoria:</div>
                <div class="formula zebra">@@mercadoria</div>
                <div class="nome-formula">Volumes:</div>
                <div class="formula">@@volume</div>
                <div class="nome-formula">Tipo Frete:</div>
                <div class="formula">@@tipoFrete</div>
                <div class="nome-formula zebra">Quantidade KM:</div>
                <div class="formula zebra">@@km</div>
                <div class="nome-formula zebra">Paletts:</div>
                <div class="formula zebra">@@pallets</div>
                <div class="nome-formula">Tipo de veículo:</div>
                <div class="formula">@@tipoVeiculo</div>
                <div class="nome-formula">Qtd de Entregas:</div>
                <div class="formula">@@entregas</div>
                <div class="nome-formula zebra">Peso Cubado:</div>
                <div class="formula zebra">@@cubado</div>
                <div class="nome-formula zebra">Total Frete sem TDE:</div>
                <div class="formula zebra">@@totalFrete</div>
                <div class="nome-formula">Frete Peso:</div>
                <div class="formula">@@fretePeso</div>
                <div class="nome-formula">Frete Valor:</div>
                <div class="formula">@@freteValor</div>
            </div>
            <div class="container-text-area">
                <textarea  name="text-formula" type="text" id="text-formula" class="text-formula"></textarea>
            </div>
            <div class="fim-formula">
                <input type="hidden" id="grupoID">
                <input type="button" value="Confirmar" class="bt-confirmar-formula" onclick="window.parent.popularFormula($('#grupoID').val(), $('#text-formula').val());">
                <input type="button" value="Cancelar" class="bt-cancelar-formula" onclick="window.parent.fecharFormula()">
            </div>
        </div>
        <script src="../js/jquery-3.2.1.min.js" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/cadastros/js/formula.js" type="text/javascript"></script>
    </body>
</html>
