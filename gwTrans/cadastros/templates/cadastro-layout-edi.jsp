<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-layout-edi.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
</head>
<body>
<div class="container-form">
    <div class="col-md-12">
        <div class="container-campos">
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Descrição</div>
                </div>
                <span class="container-input-form-gw input-width-100">
                    <input type="hidden" id="acao" name="acao" value="cadastrar" data-serialize-campo="acao">
                    <input type="hidden" id="id" name="id" data-serialize-campo="id" value="0">
                    <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                           required="required" type="text" maxlength="100" data-serialize-campo="descricao"
                           placeholder="Descrição do Layout." data-validar="true" data-type="text"
                           data-erro-validacao="O campo Descrição é de preenchimento obrigatório!">
                </span>
            </div>
            <div class="col-md-3">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Tipo</div>
                </div>
                <select name="tipoEDI" id="tipoEDI" class="ativa-helper" data-serialize-campo="tipoProtocolo">
                    <option value="c" selected>Conhecimento (CONEMB)</option>
                    <option value="f">Faturas (DOCCOB)</option>
                    <option value="o">Entrega (OCOREN)</option>
                </select>
            </div>
            <div class="col-md-2">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Extensão do arquivo</div>
                </div>
                <select name="extensaoArquivo" id="extensaoArquivo" class="ativa-helper"
                        data-serialize-campo="extensaoArquivo">
                    <option value="txt" selected>TXT</option>
                    <option value="env">ENV</option>
                    <option value="csv">CSV</option>
                </select>
            </div>
            <div class="col-md-3" style="width: 33.3%;">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Função</div>
                </div>
                <select name="funcao" id="funcao" class="ativa-helper" data-serialize-campo="funcao">
                    <option value="0" selected>Não Informado</option>
                    <c:forEach var="funcao" varStatus="status" items="${listaFuncoes}">
                        <option value="${funcao.funcao}">EDI <c:out value="${funcao.descricao}"/></option>
                    </c:forEach>
                </select>
            </div>
        </div>
    </div>
    <div class="col-md-12">
        <div class="container-campos">
            <div class="col-md-6">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Nome do Arquivo</div>
                </div>
                <span class="container-input-form-gw input-width-100">
                    <input class="input-form-gw input-width-100 ativa-helper" id="nomeArquivo" name="nomeArquivo"
                           required="required" type="text" maxlength="60" data-serialize-campo="nomeArquivo"
                           placeholder="Nome do Arquivo" data-validar="true" data-type="text"
                           data-erro-validacao="O campo Nome do Arquivo é de preenchimento obrigatório!">
                </span>
            </div>
        </div>
    </div>
    <div class="col-md-12">
        <div class="container-campos">
            <div class="col-md-11">
                <div class="identificacao-campo">
                    <div class="label-campo-identificacao">Variáveis para o nome do arquivo</div>
                </div>
                <div class="container-input-form-gw input-width-100 div_variaveis">
                    <ul style="float: left;">
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@dia</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@mes</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@ano</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@hora</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@minuto</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@segundo</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@numero_CTE</span></li>
                        <li class="celula-zebra-variaveis"><span class="lb-link variaveis">@@data_Emissao_CTE</span></li>
                    </ul>
                    <ul style="float: left;">
                        <li class="celula-zebra-variaveis-2">Dia atual do mês</li>
                        <li class="celula-zebra-variaveis-2">Mês atual</li>
                        <li class="celula-zebra-variaveis-2">Ano atual</li>
                        <li class="celula-zebra-variaveis-2">Hora atual</li>
                        <li class="celula-zebra-variaveis-2">Minuto atual</li>
                        <li class="celula-zebra-variaveis-2">Segundo atual</li>
                        <li class="celula-zebra-variaveis-2">Número do CT-e</li>
                        <li class="celula-zebra-variaveis-2">Data de Emissão do CT-e</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="${homePath}/gwTrans/cadastros/js/cadastro-layout-edi.js?v=${random.nextInt()}"
        type="text/javascript"></script>
</body>