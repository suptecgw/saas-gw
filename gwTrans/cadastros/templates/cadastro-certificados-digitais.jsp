<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-certificados-digitais.css?v=${random.nextInt()}" rel="stylesheet">
    <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}"></script>
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css?v=${random.nextInt()}"   rel="stylesheet">
    <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}"></script>
    <script src="${homePath}/gwTrans/cadastros/js/download.js?v=${random.nextInt()}"></script>
</head>
<body>
    <div class="container-form">
        <input type="hidden" id="id" name="id" value="0" data-serialize-campo="id">
        <input type="hidden" id="senha" name="senha" value="0" data-serialize-campo="senha">
        <input type="hidden" id="excluidosDOM" name="excluidosDOM"  data-serialize-campo="excluidosDOM">

        <div class="col-md-12">
            <div class="container-campos" style="padding-left: 14px;">
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Descrição</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="50"
                               placeholder="Descrição" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!"
                               data-serialize-campo="descricao" data-ajuda="descricao_certificado">
                    </span>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Certificado</div>
                    </div>
                    <div class="container-input-file-layout">
                        <input type="file" id="certificado" class="input-file-layout form_oferta" >
                        <label for="certificado" id="certificadoBotao" class="btn btn-tertiary js-labelFile" data-ajuda="arquivo_certificado">
                            <i class="icon fa fa-check"></i>
                            <span class="js-fileName">Importar Certificado Digital</span>
                        </label>
                        <input type="hidden" name="certificado" id="certificadoHidden" value=""
                               data-serialize-campo="certificado">
                        <input type="hidden" name="nome_certificado" id="nome_certificado" value=""
                               data-serialize-campo="nome_certificado">

                        <input type="hidden" name="certificadoCadeia" id="certificadoCadeia" value=""
                               data-serialize-campo="certificado_cadeia">

                        <input type="hidden" name="cadeiaAtualizada" id="cadeiaAtualizada" value="false" data-serialize-campo="cadeiaAtualizada">
                    </div>
                    <a href="#" id="baixar_certificado" style="display: none;" data-ajuda="download_certificado"><i class="fa fa-download"></i></a>
                </div>
            </div>
            <div class="container-campos">
                <div class="col-md-12" id="informacoesCertificado" style="display: none;">
                    <div class="container-input-form-gw input-width-100 div_variaveis">
                        <ul style="float: left;">
                            <li class="celula-zebra-variaveis" data-ajuda="razaosocial_certificado"><span class="variaveis">Razão social:</span></li>
                            <li class="celula-zebra-variaveis" data-ajuda="cnpj_certificado"><span class="variaveis">CNPJ:</span></li>
                            <li class="celula-zebra-variaveis" data-ajuda="validade_certificado"><span class="variaveis">Validade do certificado:</span></li>
                        </ul>
                        <ul style="float: left;">
                            <li class="celula-zebra-variaveis-2" id="razaoSocialCertificado" data-serialize-campo="razaoSocialCertificado" data-ajuda="razaosocial_certificado">aaaa</li>
                            <li class="celula-zebra-variaveis-2" id="cnpjCertificado" data-serialize-campo="cnpjCertificado" data-ajuda="cnpj_certificado">aaaa</li>
                            <li class="celula-zebra-variaveis-2" id="validadeCertificado" data-serialize-campo="validadeCertificado" data-ajuda="validade_certificado">aaaa</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="container-campos">
                <div class="col-md-12" id="cadeiaCertificado" style="display: none;">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Cadeia de certificado</div>
                    </div>
                    <div class="col-md-6" style="padding-left: 4px;">
                        <span id="lblCadeiaCertificado" style="font-weight: bolder;" data-ajuda="cadeia_certificado">V2</span>
                        <button class="btn btn-tertiary" id="atualizarCadeiaCertificado" style="width: 10vw;display: inline-block;margin-left: 120px;" data-ajuda="atualizar_cadeia_certificado">
                            Atualizar cadeia
                        </button>
                    </div>
                </div>
            </div>
            <div class="container-campos" id="containerFiliais" style="display: none;">
                <div class="col-md-12">
                    <div class="container-dom">
                        <div class="container-abas noselect">
                            <div class="aba aba01 aba-selecionada">Filiais</div>
                        </div>
                    </div>
                    <div class="col-md-8 conteudo-aba" id="conteudo-aba1">
                        <div id="container-dom-filiais">
                            <div class="container-campos">
                                <div class="top-dom">
                                    <div style="margin-bottom: 0;width: 45px;float: left;">
                                        <div class="header-dom" id="localizarFilialDom" data-ajuda="adicionar_filial_certificado">
                                            <img src="${homePath}/gwTrans/cadastros/img/plus-dom.png" alt="Nova Filial" title="Nova Filial">
                                        </div>
                                    </div>
                                    <div class="col-md-11" style="margin-bottom: 0;">
                                        <div class="body-dom">
                                            <label class="col-md-3 title-dom">Filial</label>
                                            <label class="col-md-3 title-dom">CNPJ</label>
                                            <label class="col-md-3 title-dom">Cidade/UF</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="container-dom-filials">
                                    <div class="body">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <input type="hidden" id="descricao_certificado" name="descricao_certificado">
    <input type="hidden" id="arquivo_certificado" name="arquivo_certificado">
    <input type="hidden" id="download_certificado" name="download_certificado">
    <input type="hidden" id="razaosocial_certificado" name="razaosocial_certificado">
    <input type="hidden" id="cnpj_certificado" name="cnpj_certificado">
    <input type="hidden" id="validade_certificado" name="validade_certificado">
    <input type="hidden" id="cadeia_certificado" name="cadeia_certificado">
    <input type="hidden" id="atualizar_cadeia_certificado" name="atualizar_cadeia_certificado">
    <input type="hidden" id="adicionar_filial_certificado" name="adicionar_filial_certificado">
    <input type="hidden" id="remover_filial_certificado" name="remover_filial_certificado">

    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <div class="localiza">
        <iframe id="localizarFilial" input="inptFilial" name="localizarFilial"
                src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarFilial&tema=${tema}"
                frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
    </div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-certificados-digitais.js?v=${random.nextInt()}"></script>
</body>