<%-- 
    Document   : cadastro-cidade(icescrum Story 126, sprint 3)
    Created on : 12/07/2018, 10:01:19
    Author     : manasses
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="ISO-8859-1">
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript" type="text/javascript"></script>
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/gwTrans/cadastros/css/cadastro-cidade.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
        <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet">
    </head>   
    <body>
        <div class="container-form">
            <form method="POST" id="formCadastro" name="formCadastro">
                <div class="col-md-12 celula-zebra">
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Cidade</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input type="hidden" id="acao" name="acao" value="cadastrar" data-serialize-campo="acao"/>
                                <input type="hidden" id="idCidade" name="idCidade" val="" data-serialize-campo="idCidade"/>
                                <input type="hidden" id="excluidosDOMCidadeEDI" name="excluidosDOMCidadeEDI" data-serialize-campo="excluidosDOMCidadeEDI">
                                <input class="input-form-gw input-width-100 ativa-helper2" id="cidade" name="cidade"
                                       required="required" type="text" maxlength="40"
                                       placeholder="Nome da Cidade" data-validar="true" data-type="text"
                                       data-erro-validacao="Nome da Cidade" 
                                       data-serialize-campo="cidade">
                            </span>
                        </div>
                        <div class="col-md-1">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">UF</div>
                            </div>
                            <span class="input-width-100">
                                <select name="uf" id="uf" class="ativa-helper2" data-erro-validacao="UF da Cidade" data-serialize-campo="uf">                            
                                    <option value="AC">AC</option>
                                    <option value="AL">AL</option>
                                    <option value="AM">AM</option>
                                    <option value="AP">AP</option>
                                    <option value="BA">BA</option>
                                    <option value="CE">CE</option>
                                    <option value="DF">DF</option>
                                    <option value="ES">ES</option>
                                    <option value="GO">GO</option>
                                    <option value="MA">MA</option>
                                    <option value="MG">MG</option>
                                    <option value="MS">MS</option>
                                    <option value="MT">MT</option>
                                    <option value="PA">PA</option>
                                    <option value="PB">PB</option>
                                    <option value="PE">PE</option>
                                    <option value="PI">PI</option>
                                    <option value="PR">PR</option>
                                    <option value="RJ">RJ</option>
                                    <option value="RN">RN</option>
                                    <option value="RO">RO</option>
                                    <option value="RR">RR</option>
                                    <option value="RS">RS</option>
                                    <option value="SC">SC</option>
                                    <option value="SE">SE</option>
                                    <option value="SP">SP</option>
                                    <option value="TO">TO</option>
                                    <option value="EX">EX</option>
                                </select>    
                            </span>
                        </div>
                        <div class="col-md-2">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Pais</div>
                            </div>
                            <span class="input-width-100">
                                <select name="idpais" id="idpais" class="ativa-helper2 ativa-helper" data-erro-validacao="Pa&iacute;s da Cidade" data-serialize-campo="idpais">                          
                                    <c:forEach items="${paises}" var="paises">
                                        <option value="${paises.id}">${paises.descricao}</option>
                                    </c:forEach>
                                </select>    
                            </span>
                        </div>
                    </div>
                </div>
                <div class="container-dom">
                    <div class="container-abas noselect">
                        <div class="aba aba01 aba-selecionada">Integra&ccedil;&atilde;o Fiscal/SEFAZ</div>
                        <div class="aba aba02">Configura&ccedil;&otilde;es EDI</div>
                        <div class="aba aba03">Informa&ccedil;&otilde;es Operacionais</div>
                        <div class="aba aba04">&Aacute;reas</div>
                    </div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba1">
                    <div class="container-dom">
                        <div class="col-md-12 celula-zebra">
                            <div class="col-md-3">
                                <div class="identificacao-campo" id="identificacao-campo">
                                    <div class="label-campo-identificacao">C&oacute;digo do Munic&iacute;pio</div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper2" id="cod-municipio" name="cod-municipio"
                                           required="" type="text" maxlength="6"
                                           placeholder="" data-validar="true" data-type="text"
                                           data-erro-validacao="C&oacute;digo do municipio para integra&ccedil;&atilde;o com a SEFAZ/Receita Federal."
                                           data-serialize-campo="cod-municipio">
                                </span>
                            </div>
                            <div class="col-md-3">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">C&oacute;digo SRF</div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper2" id="cod-srf" name="cod-srf"
                                           required="" type="text" maxlength="4"
                                           placeholder="" data-validar="true" data-type="text"
                                           data-erro-validacao="C&oacute;digo na Receita Federal para integra&ccedil;&atilde;o com a SEFAZ/Receita Federal."
                                           data-serialize-campo="cod-srf">
                                </span>
                            </div>
                            <div class="col-md-3">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">C&oacute;digo IBGE</div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper2" id="cod-ibge" name="cod-ibge"
                                           required="" type="text" maxlength="7"
                                           placeholder="" data-validar="true" data-type="text"
                                           data-erro-validacao="C&oacute;digo da cidade no IBGE para integra&ccedil;&atilde;o com a SEFAZ/Receita Federal/CT-e/NF-e/MDF-e/NFS-e/CIOT."
                                           data-serialize-campo="cod-ibge">
                                    <img height="25" src="img/ibge.jpg" border="0" title="Clique aqui para consultar o c&oacute;digo IBGE da cidade." 
                                         align="absbottom" class="imagemLink" id="imagemLink" onClick="javascript:getCodigoIBGE();">
                                </span>
                            </div>
                        </div>
                        <div class="col-md-12"> 
                            <div class="col-md-3">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">C&oacute;digo sistema NG Fiscal (Mastermaq)</div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper2" id="cod-mastermaq" name="cod-mastermaq"
                                           required="" type="text" maxlength="6"
                                           placeholder="" data-validar="true" data-type="text"
                                           data-erro-validacao="C&oacute;digo da cidade para integra&ccedil;&atilde;o com o sistema NG Fiscal da empresa Mastermaq."
                                           data-serialize-campo="cod-mastermaq">
                                </span>
                            </div>
                            <div class="col-md-3">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">C&oacute;digo SIAFI</div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper2" id="cod-siafi" name="cod-siafi"
                                           required="" type="text" maxlength="7"
                                           placeholder="" data-validar="true" data-type="text"
                                           data-erro-validacao="Sistema Integrado de Administra&ccedil;&atilde;o Financeira do Governo Federal - SIAFI é um sistema contábil que tem por finalidade realizar todo o processamento,
                                           controle e execu&ccedil;&atilde;o financeira, patrimonial e contábil do governo federal brasileiro. Esse c&oacute;digo será utilizado na integra&ccedil;&atilde;o com a Receita Federal."
                                           data-serialize-campo="cod-siafi">
                                </span>
                            </div>
                            <div class="col-md-3">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">C&oacute;digo DIPAM</div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper2" id="cod-dipam" name="cod-dipam"
                                           required="" type="text" maxlength="4"
                                           placeholder="" data-validar="true" data-type="text"
                                           data-erro-validacao="A DIPAM, Declara&ccedil;&atilde;o para o &Iacute;ndice de Participa&ccedil;&atilde;o dos Munic&iacute;pios, consiste na declara&ccedil;&atilde;o dos contribuintes informando, à Fazenda Estadual, 
                                           os valores das opera&ccedil;&otilde;es relativas à circula&ccedil;&atilde;o de mercadorias e das presta&ccedil;&otilde;es de servi&ccedil;os de transporte ou de comunica&ccedil;&atilde;o. Esse c&oacute;digo será utilizado na integra&ccedil;&atilde;o com a SEFAZ/NFS-e."
                                           data-serialize-campo="cod-dipam">
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba2">
                    <div id="container-dom-cidade">
                        <div class="container-campos">
                            <div class="top-dom ativa-helper-data-ajuda" data-ajuda="header-dom-estado">
                                <div style="margin-bottom: 0px;width: 45px;float: left;">
                                    <div class="header-dom">
                                        <img src="${homePath}/gwTrans/cadastros/img/plus-dom.png" alt="Novo CidadeEDI"/> 
                                    </div>
                                </div>
                                <div class="col-md-11" style="margin-bottom: 0px;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Outras nomenclaturas para importa&ccedil;&atilde;o EDI/XML</label>
                                    </div>
                                </div>
                            </div>
                            <div class="body">
                            </div>
                        </div>
                    </div>    
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba3">
                    <div class="col-md-12">
                        <div class="col-md-4">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Qtd. de Horas para baixar o Comprovante de entrega</div>
                            </div>
                            <span class="container-input-form-gw input-width-50">
                                <input class="input-form-gw input-width-100 ativa-helper2" id="qtd-horas" name="qtd-horas"
                                       required="" type="text" maxlength="" value="0"
                                       placeholder="" data-validar="true" data-type="text"
                                       data-erro-validacao="Campo utilizado para medir a performance de baixa de canhoto no sistema, essas informa&ccedil;&otilde;es poder&atilde;o ser encontradas nos relat&oacute;rios de análises de entrega."
                                       data-serialize-campo="qtd-horas">
                            </span>
                        </div>
                        <div class="col-md-12">
                            <div class="col-md-3">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">Aeroporto</div>
                                </div>
                                <span class="container-campo-aeroporto input-width-100">
                                    <label class="input-form-gw input-width-100 ativa-helper2" name="aeroporto" id="aeroporto"
                                           type="text" readonly="readonly"
                                           data-erro-validacao="Aeroporto de atendimento definidono cadastro de aeroportos."/>
                                </span>
                            </div>
                        </div>
                        <div class="col-md-12">
                            <div class="col-md-7">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao">Serviço para lançamento de NFS-e na tela de importação de conhecimento em lote</div>
                                </div>
                                <div>
                                    <span class="container-input-form-gw input-width-50">
                                        <input class="input-form-gw input-width-100 ativa-helper2" name="servico-nfse-padrao" id="servico-nfse-padrao" type="text" data-serialize-campo="servico-nfse-padrao">
                                    </span>
                                    <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" class="inp-localizar" onclick="controlador.acao('abrirLocalizar', 'localizarServico');">
                                    <span onclick="removerValorInput('servico-nfse-padrao');" class="inp-localizar btnDelete" style="margin-top: 30px; margin-left: 56px;"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>                                   
                <div class="col-md-8 conteudo-aba" id="conteudo-aba4">
                    <div class="container-dom" id="conteiner-areas">
                        <div class="container-campos">
                            <div class="top-dom ativa-helper-data-ajuda">
                                <div class="col-md-12">
                                    <div class="body-dom">
                                        <label class="title-dom" id="title-dom-areas">&Aacute;reas que essa cidade faz parte</label>
                                    </div>
                                </div>
                            </div>
                            <div class="areas col-md-12">
                                <div class="col-dom-area col-md-2">
                                    Sigla
                                </div>
                                <div class="col-dom-area col-md-5">
                                    Descri&ccedil;&atilde;o
                                </div>
                                <div class="col-dom-area col-md-5">
                                    Cliente
                                </div>
                                <hr/>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
        <div class="localiza">
            <iframe id="localizarServico" input="servico-nfse-padrao" name="localizarServico" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarServico&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
        <script src="${homePath}/gwTrans/cadastros/js/cadastro-cidade.js?v=${random.nextInt()}" type="text/javascript"></script>
    </body>
</html>