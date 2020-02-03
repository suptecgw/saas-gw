<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-unidade-custo.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css?v=${random.nextInt()}"   rel="stylesheet">
</head>
<body>
    <div class="container-form">
        <input type="hidden" id="id" name="id" value="0" data-serialize-campo="id">

        <div class="col-md-12">
            <div class="container-campos">
                <div class="col-md-1">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Sigla</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="sigla" name="sigla"
                               required="required" type="text" maxlength="8"
                               placeholder="Sigla" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Sigla é de preenchimento obrigatório!" 
                               data-serialize-campo="sigla">
                    </span>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Descrição</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="40"
                               placeholder="Descrição" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!"
                               data-serialize-campo="descricao">
                    </span>
                </div>
                <div class="col-md-2">
                    <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                        <div class="section-check-cadastro">
                            <input id="ativo" name="ativo" type="checkbox" data-serialize-campo="ativo" class="chk-save" checked>
                            <label for="ativo">
                                <span></span>
                                Ativo
                            </label>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                        <div class="section-check-cadastro">
                            <input id="visualizar_orcamentacao" name="visualizar_orcamentacao" type="checkbox" data-serialize-campo="visualizar_orcamentacao" class="chk-save" checked>
                            <label for="visualizar_orcamentacao">
                                <span></span>
                                Visualizar na Orçamentação
                            </label>
                        </div>
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="col-md-6">
                        <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                            <div class="section-check-cadastro">
                                <input id="integra_contabil" name="integra_contabil" type="checkbox" data-serialize-campo="integra_contabil"  class="chk-save" checked>
                                <label for="integra_contabil">
                                    <span></span>
                                    Ativar integração contábil por unidade de custo
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Código na contabilidade</div>
                    </div>
                    <div class="col-md-2">
                        <span class="container-input-form-gw input-width-100">
                            <input class="input-form-gw input-width-100 ativa-helper" id="codigo_contabil" name="codigo_contabil"
                                   required="required" type="text" maxlength="8"
                                   placeholder="Codigo" data-validar="true" data-type="text"
                                   data-erro-validacao="O campo Sigla é de preenchimento obrigatório!" 
                                   data-serialize-campo="codigo_contabil">
                        </span>
                    </div>
                </div>
                </div>
                
            </div>
        </div>
    </div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-unidade-custo.js?v=${random.nextInt()}"></script>
</body>