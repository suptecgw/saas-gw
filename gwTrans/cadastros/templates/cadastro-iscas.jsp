<%-- 
    Document   : cadastro-tde
    Created on : 28/12/2017, 12:01:19
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script  src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css"/>
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-iscas.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/css/style-grid-default.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css" rel="stylesheet">
</head>
<body>
    <script>
        const filial_id = '${filial_id}';
        const pode_ver_manifesto_propria_filial = '${pode_ver_manifesto_propria_filial}' === 'true';
        const pode_ver_manifesto_outra_filial = '${pode_ver_manifesto_outra_filial}' === 'true';
        const pode_ver_romaneio_propria_filial = '${pode_ver_romaneio_propria_filial}' === 'true';
        const pode_ver_romaneio_outra_filial = '${pode_ver_romaneio_outra_filial}' === 'true';
    </script>
    <div class="container-form">
        <form method="POST" id="formCadastro" name="formCadastro">
            <div id="editarForm" style="display: none;">
                <input type="hidden" name="id" id="id" value="0" data-serialize-campo>

                <div class="col-md-12">
                    <div class="container-campos">
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Número da Isca</div>
                            </div>
                            <span class="container-input-form-gw input-width-100">
                                <input class="input-form-gw input-width-100 ativa-helper" id="numero" name="numero" data-serialize-campo data-type="text" data-erro-validacao="O campo Número da Isca é de preenchimento obrigatório" data-validar="true" required="required" type="text" placeholder="Número da Isca" data-ajuda="numero_isca_ajuda" maxlength="40">
                            </span>
                        </div>
                        <div class="col-md-3">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Status</div>
                            </div>
                            <div data-ajuda="status_ajuda">
                                <input type="radio" id="statusAtivado" name="is_ativo" data-serialize-campo value="true" checked>
                                <label for="statusAtivado">Ativada</label>
                                <input type="radio" id="statusDesativado" name="is_ativo" data-serialize-campo value="false">
                                <label for="statusDesativado">Desativada</label>
                            </div>
                        </div>
                        <div class="col-md-3" id="divMotivo" style="display: none;">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Motivo</div>
                            </div>
                            <div data-ajuda="motivo_desativacao_ajuda">
                                <select id="motivo_desativacao" name="motivo_desativacao" data-serialize-campo>
                                    <option disabled="disabled" selected value="selecione">Selecione</option>
                                    <option value="p">Perdida</option>
                                    <option value="q">Quebrada</option>
                                    <option value="r">Roubada/Extraviada</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12" style="padding: 0;border-bottom: 2px solid rgba(4, 44, 81,0.3);">
                    <div class="container-abas noselect">
                        <div class="aba aba01 aba-selecionada">Movimentações</div>
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="container-dom" style="line-height: 30px;">
                        <div class="col-md-2" style="text-align: right;margin-right: 10px;">
                            <label>Movimentado entre:</label>
                        </div>
                        <div class="col-md-2">
                            <input class="input-form-gw input-width-100 ativa-helper" name="data-final" id="data-inicial"
                                   maxlength="10" type="text" value="${dataAtual}">
                        </div>
                        <div class="col-md-2 col-md-offset-1">
                            <input class="input-form-gw input-width-100 ativa-helper" name="data-final" id="data-final"
                                   maxlength="10" type="text" value="${dataAtual}">
                        </div>
                        <div class="col-md-3 col-md-offset-1">
                            <button type="button" class="btn btn-tertiary" id="btnVerMovimentacoes">Ver movimentações</button>
                        </div>
                    </div>
                </div>
                <div class="col-md-12" style="width: 99%;">
                    <div class="container-dom">
                        <div class="top-dom" style="height: 40px;padding-left: 15px;">
                            <div class="col-md-11">
                                <div style="margin-bottom: 0px;width: 10%;display: inline-block;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Data Saída</label>
                                    </div>
                                </div>
                                <div style="margin-bottom: 0px;width: 10%;display: inline-block;">
                                    <div class="body-dom" style="">
                                        <label class="title-dom">Data chegada</label>
                                    </div>
                                </div>
                                <div style="margin-bottom: 0px;width: 15%;display: inline-block;">
                                    <div class="body-dom"  style="">
                                        <label class="title-dom">Filial</label>
                                    </div>
                                </div>
                                <div style="margin-bottom: 0px;width: 15%;display: inline-block;">
                                    <div class="body-dom"  style="">
                                        <label class="title-dom">Manifesto/Romaneio</label>
                                    </div>
                                </div>
                                <div style="margin-bottom: 0px;width: 17%;display: inline-block;">
                                    <div class="body-dom"  style="">
                                        <label class="title-dom">Motorista</label>
                                    </div>
                                </div>
                                <div style="margin-bottom: 0px;width: 15%;display: inline-block;">
                                    <div class="body-dom"  style="">
                                        <label class="title-dom">Destino</label>
                                    </div>
                                </div>
                                <div style="margin-bottom: 0px;width: 15%;display: inline-block;">
                                    <div class="body-dom"  style="">
                                        <label class="title-dom">Veículo</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="body" id="movimentacoesBody" style="padding-left: 15px;">
                        </div>
                    </div>
                </div>
            </div>
            <div id="cadastrarForm" style="display: none;">
                <div class="col-md-12">
                    <div class="container-campos">
                        <div class="col-md-4">
                            <div class="identificacao-campo">
                                <div class="label-campo-identificacao">Importar planilha</div>
                            </div>
    
                            <div class="container-input-file-layout ativa-helper-data-ajuda">
                                <input type="file" id="arquivo_planilha" class="input-file-layout">
                                <label for="arquivo_planilha" class="btn btn-tertiary js-labelFile">
                                    <i class="icon fa fa-check"></i>
                                    <span class="js-fileName">Selecionar arquivo</span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="container-campos">
                        <div class="col-md-12" style="overflow-y: scroll;height: 30vw;">
                            <table cellspacing="0" class="tabela-gwsistemas" id="tabela-gwsistemas">
                                <thead>
                                <tr>
                                    <th width="4%" class="nao" style="text-align: center;cursor: pointer;" id="adicionarIsca"><i class="fa fa-plus"></i></th>
                                    <th>Número da Isca</th>
                                </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <input type="hidden" name="numero_isca_ajuda" id="numero_isca_ajuda">
    <input type="hidden" name="status_ajuda" id="status_ajuda">
    <input type="hidden" name="motivo_desativacao_ajuda" id="motivo_desativacao_ajuda">

    <img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
    <div class="bloqueio-tela"></div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-iscas.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.15.1/xlsx.full.min.js"></script>
</body>