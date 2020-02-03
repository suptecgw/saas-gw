<%-- 
    Document   : cadastro-inventario
    Created on : 28/12/2017, 12:01:19
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="ISO-8859-1">
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
        <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
        <link href="${homePath}/gwTrans/cadastros/css/cadastro-inventario.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css"   rel="stylesheet">
    </head>
    <body>
        <div class="container-form">
            <div class="col-md-12 ">
                <div class="container-campos">
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Nº Inventário</div>
                        </div>
                        <span class="container-input-form-gw input-width-100">
                            <input class="input-form-gw input-width-100 ativa-helper input-readonly" readonly="readonly"
                                   name="numero" id="numero" type="text" value="${numeroIventario}" data-validar="true"
                                   data-serialize-campo="numero" data-type="text"
                                   data-erro-validacao="O campo número inventário é de preenchimento obrigatório!">
                        </span>
                    </div>
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Filial</div>
                        </div>
                        <select id="filial" name="filial">
                            <c:forEach items="${filiais}" var="filial">
                                <option value="${filial.idfilial}" <c:if test="${userFilial.idfilial == filial.idfilial}">selected</c:if> >${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                        <input type="hidden" name="id-filial" id="id-filial" value="${userFilial.idfilial}" data-serialize-campo="id-filial">
                    </div>
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Data Inicial</div>
                        </div>
                        <span class="container-input-form-gw input-width-80">
                            <input class="input-form-gw input-width-100 ativa-helper" name="data-inicial" id="data-inicial"
                                   required="required" type="text"
                                   placeholder=""
                                   data-serialize-campo="data-inicial"
                                   value="${dataAtual}" data-validar="true"
                                   data-type="text" data-erro-validacao="O campo data inicial é de preenchimento obrigatório!">
                        </span>
                    </div>
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Hora Inicial</div>
                        </div>
                        <span class="container-input-form-gw input-width-100">
                            <input class="input-form-gw input-width-100 ativa-helper" name="hora-inicial" id="hora-inicial"
                                   maxlength="40" required="required" type="text"
                                   placeholder=""
                                   data-serialize-campo="hora-inicial"
                                   value="${horaAtual}" data-validar="true"
                                   data-type="text" data-erro-validacao="O campo hora inicial é de preenchimento obrigatório!">
                        </span>
                    </div>
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Data Final</div>
                        </div>
                        <span class="container-input-form-gw input-width-80">
                            <input class="input-form-gw input-width-100 ativa-helper" name="data-final" id="data-final"
                                   maxlength="40" type="text"
                                   placeholder=""
                                   data-serialize-campo="data-final"
                                   value="" 
                                   data-type="text" >
                        </span>
                    </div>
                    <div class="col-md-2">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Hora Final</div>
                        </div>
                        <span class="container-input-form-gw input-width-100">
                            <input class="input-form-gw input-width-100 ativa-helper" name="hora-final" id="hora-final"
                                   maxlength="40" type="text"
                                   placeholder=""
                                   data-serialize-campo="hora-final"
                                   value="" 
                                   data-type="text">
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-md-12 ">
                <div class="container-campos">
                    <div class="col-md-4">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Descrição</div>
                        </div>
                        <span class="container-input-form-gw input-width-100">
                            <textarea rows="1" placeholder="" class="text-auto-ajuste" 
                                      id="descricao" name="descricao" data-validar="true" 
                                      data-serialize-campo="descricao" data-type="text-area" 
                                      maxlength="50"
                                      data-erro-validacao="O campo descrição é de preenchimento obrigatório!" ></textarea>
                        </span>
                    </div>
                    <div class="col-md-4">
                        <div class="identificacao-campo">
                            <div class="label-campo-identificacao">Observação</div>
                        </div>
                        <span class="container-input-form-gw input-width-100 overflow-hidden">
                            <textarea rows="1" placeholder="" class="text-auto-ajuste" 
                                      id="observacao" name="observacao" data-validar="true" 
                                      data-serialize-campo="observacao" data-type="text-area" 
                                      data-erro-validacao="O campo observação é de preenchimento obrigatório!" ></textarea>
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-md-12 " style="padding: 0;">
                <div class="container-abas noselect">
                    <div class="aba aba01 aba-selecionada">Lista de CT-e(s)</div>
                    <div class="aba aba02 ">Arquivos Importados</div>
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba1">
                    <div class="cobre-etiqueta"></div>
                    <div class="col-md-3">
                        <div class="bt-adicionar-filtros">Visualizar Filtros</div>
                    </div>
                    <div class="col-md-3">
                        <div class="bt-expandir">Expandir</div>
                    </div>
                    <div class="col-md-6">
                        <div class="container-lista topo-etiquetas" style="overflow: hidden;visibility: hidden">
                            <div class="col-md-3 padding-top-bottom">
                                <div class="label-campo-identificacao-ctes" style="margin-bottom: 5px;font-size: 14px;font-weight: bold;color: #444;">Layout:</div>
                                <select id="select-layout">
                                    <option value="padraoTxt">Padrão TXT</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <div class="label-campo-identificacao-ctes" style="margin-bottom: 5px;font-size: 14px;font-weight: bold;color: #444;">Código de Barras:</div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100 ativa-helper" name="input-etiqueta" id="input-etiqueta" value="">
                                </span>
                            </div>
                            <div class="col-md-2">
                                <div class="bt-pesquisar-etiqueta ativa-helper" id="bt-pesquisar-etiqueta">Pesquisar</div>
                            </div>
                            <div class="col-md-3">
                                <div class="container-input-file-layout">
                                    <input type="file" name="file" id="file" class="input-file-layout">
                                    <label for="file" class="btn btn-tertiary js-labelFile">
                                        <i class="icon fa fa-check"></i>
                                        <span class="js-fileName">Importar TXT</span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="container-lista container-dom-cte" style="height: 235px;overflow-y: hidden;" id="lista-cte">
                        <div class="item-lista-cte title-item-lista">
                            <div class="col-md-2 coluna-numero-cte">Nº do CT-e</div>
                            <div class="col-md-3 coluna-clientes">Destinatário</div>
                            <div class="col-md-3 coluna-clientes">Consignatário</div>
                            <div class="col-md-2 coluna-nota">Nota Fiscal</div>
                            <div class="col-md-1">Vol(s)</div>
                            <div class="col-md-1"></div>
                        </div>
                        <div id="container-dom-cte" style="float: left;
    height: calc(100% - 57px);
    overflow-y: auto;
    overflow-x: hidden;">
                            
                        </div>
                        <div class="container-campos qtd_nfe" id="label-cte">
                            <label><strong>Qtd nfs: </strong><span id="qtd_nfe">0</span></label>
                            <label><strong>Qtd vols conferidos: </strong><span id="qtd_vlmc">0</span></label>
                            <label><strong>Qtd vols restantes: </strong><span id="qtd_vlmr">0</span></label>
                        </div>
                    </div>
                    <div class="container-lista container-dom-etiqueta" style="visibility: hidden">
                        <div class="item-lista-cte title-item-lista">
                            <div class="col-md-4 no-padding">Nº Etiqueta</div>
                            <div class="col-md-4 no-padding">Usuário</div>
                            <div class="col-md-4 no-padding">Status</div>
                        </div>
                        <div class="etiquetas"></div>
                    </div>
                    
                </div>
                <div class="col-md-12 conteudo-aba" id="conteudo-aba2" style="display: none;">
                    <div class="container-lista-arquivos container-dom-arquivos">
                        <div class="item-lista-arquivos title-item-lista">
                            <div class="col-md-1">
                                &nbsp;
                            </div>
                            <div class="col-md-3">
                                Arquivo
                            </div>
                            <div class="col-md-3">
                                Usuário de Inclusão
                            </div>
                            <div class="col-md-3">
                                Data de Inclusão
                            </div>
                            <div class="col-md-2">
                                Hora de Inclusão
                            </div>
                            <%-- Inputs hidden para as ajudas --%>
                            <input id="nome_arquivo_importado" name="nome_arquivo_importado" type="hidden">
                            <input id="icone_download_arquivo" name="icone_download_arquivo" type="hidden">
                            <input id="numeroEtiqueta" name="numeroEtiqueta" type="hidden">
                            <input id="usuario" name="usuario" type="hidden">
                            <input id="status" name="status" type="hidden">
                            <input id="numeroCte" name="numeroCte" type="hidden">
                            <input id="destinatario" name="destinatario" type="hidden">
                            <input id="numeroNota" name="numeroNota" type="hidden">
                            <input id="vol" name="vol" type="hidden">
                            <input id="img-editar-cte" name="img-editar-cte" type="hidden">
                            <input id="img-excluir-cte" name="img-excluir-cte" type="hidden">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="model-justificativa-falta-cte">
            <div class="topo-model-justificativa-falta-cte">
                <img src="${homePath}/assets/img/logo.png" alt="Logo GW SISTEMAS">
                <img src="${homePath}/assets/img/sair.png" alt="Logo GW SISTEMAS" id="img-fechar-justificativa-falta-cte">
                <label>Justificativa de Falta/Sobra</label>
            </div>
            <div class="corpo-model-justificativa-falta-cte">
                <div class="col-md-12">
                    <span class="container-input-form-gw input-width-100 overflow-hidden">
                        <textarea rows="1" placeholder="" class="text-auto-ajuste" id="justificativa-falta-etiqueta"></textarea>
                    </span>
                </div>
            </div>
            <div class="col-md-12">
                <div class="bt-justificar-falta-cte">Salvar</div>
            </div>
        </div>
        <div class="model-filtros-ctes">
            <div class="topo-model-filtros-ctes">
                <img src="${homePath}/assets/img/logo.png" alt="Logo GW SISTEMAS">
                <img src="${homePath}/assets/img/sair.png" alt="Logo GW SISTEMAS" id="img-fechar-filtros-ctes">
                <label>Visualizar Filtros</label>
            </div>
            <div class="container-filtros">
                <div class="col-md-12">
                    <label class="lb-title-radio">Mostrar CT-e(s):</label>
                    <div class="div-container-radio-cte">
                        <div class="radio">
                            <input id="radio-filial-ctes-1" name="radio-filial-ctes" type="radio"  value="emitidos-pela-filial" checked>
                            <label for="radio-filial-ctes-1" class="radio-label">Emitidos pela minha filial</label>
                        </div>
                        <div class="radio">
                            <input id="radio-filial-ctes-2" name="radio-filial-ctes" type="radio" value="responsabilidade-da-filial">
                            <label for="radio-filial-ctes-2" class="radio-label">Responsabilidade de entrega da filial</label>
                        </div>
                        <div class="radio">
                            <input id="radio-filial-ctes-3" name="radio-filial-ctes" type="radio" value="ambos-filial">
                            <label for="radio-filial-ctes-3" class="radio-label">Ambos</label>
                        </div>
                        <div class="radio">
                            <input id="radio-filial-ctes-4" name="radio-filial-ctes" type="radio" value="todas-filial">
                            <label for="radio-filial-ctes-4" class="radio-label">Todas as filiais</label>
                        </div>
                    </div>
                    <div class="div-container-radio-cte">
                        <div class="radio">
                            <input id="inp-cte-emitido-em-1" name="inp-cte-emitido-em" value="tudo" type="radio" checked>
                            <label for="inp-cte-emitido-em-1" class="radio-label">Tudo</label>
                        </div>
                        <div class="radio">
                            <input id="inp-cte-emitido-em-2" name="inp-cte-emitido-em" value="data" type="radio">
                            <label  for="inp-cte-emitido-em-2" class="radio-label">CT-e(s) emitidos entre:</label>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="col-md-6 cte-emitido-em">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao-ctes">Data de:</div>
                            </div>
                            <span class="container-input-form-gw input-width-cte">
                                <input class="input-form-gw input-width-100 ativa-helper" name="cte-de" id="cte-de" type="text" value="${dataAtual}" data-type="text">
                            </span>
                        </div>
                        <div class="col-md-6 cte-emitido-em">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao-ctes">Data até:</div>
                            </div>
                            <span class="container-input-form-gw input-width-cte">
                                <input class="input-form-gw input-width-100 ativa-helper" name="cte-ate" id="cte-ate" type="text" value="${dataAtual}" data-type="text">
                            </span>
                        </div>
                        <div class="col-md-6">
                            <div class="identificacao-campo">                              
                                <select id="select-apenas-exceto-cliente" name="select-apenas-exceto-cliente">
                                    <option value="apenas">Apenas</option>
                                    <option value="exceto">Exceto</option>
                                </select>
                                <label for="select-apenas-exceto-cliente" class="label-select">o(s) cliente(s):</label>
                            </div>
                            <span class="container-input-form-gw input-width-90">
                                <input class="input-width-100" id="apenas-ctes-clientes" name="apenas-ctes-clientes" type="text" />  
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarCliente')"/>
                        </div>
                        <div class="col-md-6">
                            <div class="identificacao-campo">
                                <select id="select-apenas-exceto-remetente" name="select-apenas-exceto-remetente">
                                    <option value="apenas">Apenas</option>
                                    <option value="exceto">Exceto</option>
                                </select>
                                <label for="select-apenas-exceto-remetente" class="label-select">o(s) remetente(s):</label>
                            </div>
                            <span class="container-input-form-gw input-width-90">
                                <input class="input-width-100" id="apenas-ctes-remetente" name="apenas-ctes-remetente" type="text" />
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarRemetente')"/>
                        </div>
                        <div class="col-md-6">
                            <div class="identificacao-campo">
                                <select id="select-apenas-exceto-destino" name="select-apenas-exceto-destino">                                   
                                    <option value="apenas">Apenas</option>
                                    <option value="exceto">Exceto </option>
                                </select>
                                <label for="select-apenas-exceto-destino" class="label-select">o(s) destino(s):</label>
                            </div>
                            <span class="container-input-form-gw input-width-90">
                                <input class="input-width-100" id="apenas-ctes-destino" name="apenas-ctes-destino" type="text" />  
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarCidade')"/>
                        </div>
                        <div class="col-md-6">
                            <div class="identificacao-campo">
                                <select id="select-apenas-exceto-area-destino" name="select-apenas-exceto-area-destino">                                   
                                    <option value="apenas">Apenas</option>
                                    <option value="exceto">Exceto</option>
                                </select>
                                <label for="select-apenas-exceto-area-destino" class="label-select">o a(s) área(s) de destino:</label>
                            </div>
                            <span class="container-input-form-gw input-width-90">
                                <input class="input-width-100" id="apenas-ctes-areas-destino" name="apenas-ctes-areas-destino" type="text" />  
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarArea')"/>
                        </div>
                        <div class="col-md-6">
                            <div class="identificacao-campo">
                                <select id="select-apenas-exceto-ultima-ocorrencia" name="select-apenas-exceto-ultima-ocorrencia">                                   
                                    <option value="apenas">Apenas</option>
                                    <option value="exceto">Exceto</option>
                                </select>
                                <label for="select-apenas-exceto-ultima-ocorrencia" class="label-select">com a última ocorrência:</label>
                            </div>
                            <span class="container-input-form-gw input-width-90">
                                <input class="input-width-100" id="apenas-ultima-ocorrencia" name="apenas-ultima-ocorrencia" type="text" />  
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarOcorrencia')"/>
                        </div>
                        <div class="col-md-6">
                            <div class="identificacao-campo">
                                <select id="select-apenas-exceto-setor-entrega" name="select-apenas-exceto-setor-entrega">
                                    <option value="apenas">Apenas</option>
                                    <option value="exceto">Exceto</option>
                                </select>
                                <label for="select-apenas-exceto-setor-entrega" class="label-select">com o(s) setor(es) de entrega:</label>
                            </div>
                            <span class="container-input-form-gw input-width-90">
                                <input class="input-width-100" id="apenas-setor-entrega" name="apenas-setor-entrega" type="text" />  
                            </span>
                            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('localizarSetorEntrega')"/>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-12">
                <button data-label="Pesquisar CT-e(s)" class="bt-pesquisar-cte">Pesquisar CT-e(s)</button>
            </div>
        </div>
        <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
        <div class="bloqueio-tela"></div>
        <div class="cobre-tudo-1"></div>
        <div class="localiza">
            <iframe id="localizarCliente" input="apenas-ctes-clientes" name="localizarCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCliente&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarCidade" input="apenas-ctes-destino" name="localizarCidade" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidade&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarArea" input="apenas-ctes-areas-destino" name="localizarArea" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarArea&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza"> 
            <iframe id="localizarOcorrencia" input="apenas-ultima-ocorrencia" name="localizarOcorrencia" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarOcorrencia&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza"> 
            <iframe id="localizarSetorEntrega" input="apenas-setor-entrega" name="localizarSetorEntrega" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarSetorEntrega&tema=${tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
    </body>
    <script>
        var home_path = '${homePath}';
        var nome_usuario = '${nomeUsuario}';
    </script>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-inventario.js?v=${random.nextInt()}" type="text/javascript"></script>
</html>