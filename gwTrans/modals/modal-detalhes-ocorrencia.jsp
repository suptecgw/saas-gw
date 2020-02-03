<%-- 
    Document   : modal-detalhes-ocorrencia
    Created on : 11/06/2018, 10:15:35
    Author     : mateus
--%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>GW Sistemas - Detalhes da Ocorrência</title>
        <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css"   rel="stylesheet">
        <link href="${homePath}/assets/css/consulta.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/easyui.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/jquery-ui-min.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/estilo-input-form-gw.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/cadastro.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/modals/css-modals/modal-detalhes-ocorrencia.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/estilo-input-form-gw.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/modals/css-modals/estilo-ajuda-modal.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <div class="container-geral-modal-detalhes-ocorrencia">
            <header>
                <img class="logo" src="${homePath}/assets/img/logo.png">
                <label class="lb-title">Detalhes da ocorrência</label>
                <div class="sair"></div>
            </header>
            <section>
                <div class="topo-inf-ocorrencias">
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia campo-ajuda-modal" title="Nº do CT-e que a ocorrência foi vinculada.">N° CT-e:</label><label class="identificacao-valor-ocorrencia" data="numeroCte"></label>
                    </div>
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">

                        <label class="identificacao-campo-ocorrencia" title="Filial do CT-e que a ocorrência foi vinculada.">Filial:</label><label class="identificacao-valor-ocorrencia" data="filial"></label>
                    </div>
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Emissão do CT-e que a ocorrência foi vinculada.">Emissão:</label><label class="identificacao-valor-ocorrencia" data="emissao"></label>
                    </div>
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Remetente do CT-e que a ocorrência foi vinculada.">Remetente:</label><label class="identificacao-valor-ocorrencia" data="remetente"></label>
                    </div>
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Destinatário do CT-e que a ocorrência foi vinculada.">Destinatário:</label><label class="identificacao-valor-ocorrencia" data="destinatario"></label>
                    </div>
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Origem do CT-e que a ocorrência foi vinculada.">Origem:</label><label class="identificacao-valor-ocorrencia" data="origem"></label>
                    </div>
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Destino do CT-e que a ocorrência foi vinculada.">Destino:</label><label class="identificacao-valor-ocorrencia" data="destino"></label>
                    </div>
                </div>
                <div class="corpo-inf-ocorrencias">
                    <div class="col-dados-ocorrencia-4 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Código da ocorrência.">Código:</label><label class="identificacao-valor-ocorrencia" data="codOcorrencia"></label>
                    </div>
                    <div class="col-dados-ocorrencia-552 container-campos-ocorrencias">
                        <label class="identificacao-campo-ocorrencia" title="Descrição da ocorrência.">Ocorrência:</label><label class="identificacao-valor-ocorrencia" data="ocorrencia"></label>
                    </div>
                    <div class="col-md-12 " style="padding: 0;">
                        <div class="container-abas noselect">
                            <div class="aba aba01 aba-selecionada">Principal</div>
                            <div class="aba aba02 ">Mercadoria</div>
                            <div class="aba aba03 ">Relacionamentos</div>
                        </div>
                        <div class="conteudo-aba conteudo-aba-ocorrencia" id="conteudo-aba1">
                            <div class="col-md-12">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao-sem-cor">
                                        <label title="Campo para informar a causa da ocorrência.">Causa da ocorrência:</label>
                                    </div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100" type="text" data="causa" data-serialize-campo="causa_ocorrencia" data-type="text" name="causaOcorrencia" id="causaOcorrencia">
                                </span>
                            </div>
                            <div class="col-md-12">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao-sem-cor">
                                        <label title="Campo para informar a consequência que a ocorrência gerou.">Consequência:</label>
                                    </div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100" type="text" data="consequencia" data-serialize-campo="consequencia" data-type="text" name="consequencia" id="consequencia">
                                </span>
                            </div>
                            <div class="col-md-12">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao-sem-cor">
                                        <label title="Campo para informar se a ocorrência terá ou não indenização.">Tipo de negociação:</label>
                                    </div>
                                </div>
                                <select id="tipoNegociacao" name="tipoNegociacao" data-serialize-campo="tipo_negociacao" data-type="text">
                                    <option value="0" selected>Não informado</option>
                                    <option value="1">Indenização</option>
                                    <option value="2">Indenização parcial</option>
                                    <option value="3">Sem indenização</option>
                                </select>
                            </div>
                            <div class="col-md-12">
                                <div class="identificacao-campo">
                                    <div class="label-campo-identificacao-sem-cor">
                                        <label title="Campo para informar o valor da receita gerada.">Valor da receita gerada por essa ocorrência:</label>
                                    </div>
                                </div>
                                <span class="container-input-form-gw input-width-100">
                                    <input class="input-form-gw input-width-100" type="text" data="valorReceita"
                                           data-serialize-campo="valor_receita" data-type="text" name="valorReceita"
                                           id="valorReceita" data-mask="#.##0,00" data-mask-reverse="true"
                                           data-mask-selectonfocus="true" maxlength="20">
                                </span>
                            </div>
                        </div>
                        <div class="conteudo-aba conteudo-aba-ocorrencia" id="conteudo-aba2" style="display: none;">
                            <div class="dom-mercadoria-nota"></div>
                        </div>
                        <div class="conteudo-aba conteudo-aba-ocorrencia" id="conteudo-aba3" style="display: none;">
                            <div class="dom-relacionamentos-nota">
                                <div class="item-dom-relacionamentos-nota">
                                    <div class="col-md-12 topo-dom-relacionamentos-nota">
                                        <div class="col-add-dom">
                                            <span class="add-novo-relacionamento" id="add-novo-relacionamento" title="Adicionar um relacionamento"></span>
                                        </div>
                                        <div class="col-dom-mercadoria col-dom-mercadorial-270">
                                            Data / Hora
                                        </div>
                                        <div class="col-dom-mercadoria col-dom-mercadorial-150">
                                            Contato
                                        </div>
                                        <div class="col-dom-mercadoria col-dom-mercadoria-125">
                                            Fone
                                        </div>
                                        <div class="col-dom-mercadoria col-dom-mercadoria-150">
                                            Observação
                                        </div>
                                        <div class="col-dom-mercadoria">
                                            Usuário
                                        </div>
                                        <div class="col-dom-mercadoria col-dom-mercadoria-25 no-border-right">
                                        </div>
                                    </div>
                                    <div class="col-md-12 corpo-dom-mercadoria-nota container-item-relacionamento"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
            <div class="footer">
                <button data-label="Salvar [F8]" class="bt-salvar">Salvar [F8]</button>
            </div>
        </div>
        <div class="cobre-tudo"></div>
    </body>
    <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
    <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
    <jsp:include page="/importAlerts.jsp">
        <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-trans.png"/>
        <jsp:param name="nomeUsuario" value="${sessionScope.usuario.nome}"/>
    </jsp:include>
    <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="${homePath}/assets/js/jquery.mask.min.js" type="text/javascript"></script>
    <script src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js" type="text/javascript"></script>
    <script src="${homePath}/gwTrans/modals/js-modals/script-ajuda-modal.js" type="text/javascript"></script>
    <script>
        var homePath = '${homePath}';
        jQuery(function () {
            jQuery('.sair').click(function () {
                parent.finalizarOcorrencia();
            });

            jQuery('.aba').click(function () {
                jQuery('.aba-selecionada').removeClass('aba-selecionada');
                jQuery(this).addClass('aba-selecionada');
                if (jQuery(this).hasClass('aba01')) {
                    if (!jQuery('#conteudo-aba1').is(':visible')) {
                        jQuery('.conteudo-aba').hide();
                        jQuery('#conteudo-aba1').show(250);
                    }
                } else if (jQuery(this).hasClass('aba02')) {
                    if (!jQuery('#conteudo-aba2').is(':visible')) {
                        jQuery('.conteudo-aba').hide();
                        jQuery('#conteudo-aba2').show(250);
                    }
                } else if (jQuery(this).hasClass('aba03')) {
                    if (!jQuery('#conteudo-aba3').is(':visible')) {
                        jQuery('.conteudo-aba').hide();
                        jQuery('#conteudo-aba3').show(250);
                    }
                }
            });

            jQuery('.bt-salvar').click(function () {
                var save = true;
                $.each($('[name*="dataR"]'), (i, e) => {
                    if (e.value.trim() === '') {
                        chamarAlert('O campo data do relacionamento é obrigatório.');
                        save = false;
                    }
                });

                if (save) {
                    jQuery.ajax({
                        url: '${homePath}/OcorrenciaControlador',
                        data: {
                            acao: 'cadastrar_detalhes_ocorrencia',
                            idOcorrencia: '${param.idOcorrencia}',
                            idCte: '${param.idCte}',
                            form: jQuery('.corpo-inf-ocorrencias').gwFormToJson()
                        },
                        complete: function (jqXHR, textStatus) {
                            if (jqXHR.responseText === 'true') {
                                parent.finalizarOcorrencia();
                            } else {
                                chamarAlert(jqXHR.responseText);
                            }
                        }
                    });
                }
            });

            jQuery('#tipoNegociacao')
                    .selectmenu()
                    .selectmenu({width: '79px'})
                    .selectmenu('option', 'position', {my: 'top+15', at: 'top center'})
                    .selectmenu('menuWidget').addClass('selects-ui').addClass('select');

            montarTela('${param.idCte}', '${param.idOcorrencia}', '${param.idOcorrenciaCtrc}');
            jQuery('#add-novo-relacionamento').click(function () {
                var i = 0;
                if ($('.container-item-relacionamento .container-zebra').length > 0) {
                    i = $('.container-item-relacionamento .container-zebra').length;
                }
                var div = jQuery('<div class="container-zebra">');
                div.load('${homePath}/gwTrans/modals/html-dom/dom-relacoes-ocorrencia.jsp', {count: i, acao: 'cadastro'});
                jQuery('.container-item-relacionamento').append(div);
            });
        });

        function montarTela(id_cte, id_ocorrencia, id_ocorrencia_ctrc) {
            $.ajax({
                'url': '${homePath}/OcorrenciaControlador',
                data: {
                    acao: 'carregar_detalhes_ocorrencia',
                    idCte: id_cte,
                    idOcorrencia: id_ocorrencia,
                    idOcorrenciaCtrc: id_ocorrencia_ctrc
                },
                complete: function (jqXHR, textStatus) {
                    const json = JSON.parse(jqXHR.responseText);
                    jQuery('[data=codOcorrencia]').text(json.ocorrencia.codigo);
                    jQuery('[data=ocorrencia]').text(json.ocorrencia.descricao);
                    jQuery('[data=numeroCte]').text(json.ocorrencia.numero);
                    jQuery('[data=filial]').text(json.ocorrencia.filial);
                    jQuery('[data=emissao]').text(convertDate(json.ocorrencia.emissaoEm));
                    jQuery('[data=remetente]').text(json.ocorrencia.remetente).attr('title', json.ocorrencia.remetente);
                    jQuery('[data=destinatario]').text(json.ocorrencia.destinatario).attr('title', json.ocorrencia.destinatario);
                    jQuery('[data=origem]').text(json.ocorrencia.origem);
                    jQuery('[data=destino]').text(json.ocorrencia.destino);

                    jQuery('[data=causa]').val(json.ocorrencia.causa);
                    jQuery('[data=consequencia]').val(json.ocorrencia.consequencia);
                    jQuery('[data=valorReceita]').val(jQuery('#valorReceita').masked(parseFloat(json.ocorrencia.valor_receita).toFixed(2).replace(/\./g, '')));

                    jQuery('#tipoNegociacao option[value=' + json.ocorrencia.tipo_negociacao + ']').prop('selected', true);
                    jQuery("#tipoNegociacao").selectmenu("refresh");

                    jQuery.each(json.notas, function (i, e) {
                        sessionStorage.setItem('jsonNotas' + i, JSON.stringify(e));
                        jQuery('.dom-mercadoria-nota').append(jQuery('<div class="item-dom-mercadoria-nota">').load('${homePath}/gwTrans/modals/html-dom/dom-detalhes-ocorrencia.jsp', {count: i, idRemetente: json.ocorrencia.id_remetente}));
                    });

                    jQuery.each(json.relacionamentos, function (i, e) {
                        sessionStorage.setItem('jsonRelacionamentos' + i, JSON.stringify(e));
                        var div = jQuery('<div class="container-zebra">');
                        div.load('${homePath}/gwTrans/modals/html-dom/dom-relacoes-ocorrencia.jsp', {count: i, acao: 'carregando'});
                        jQuery('.container-item-relacionamento').append(div);
                    });

                }
            });

        }

        function convertDate(dateString) {
            var p = dateString.split(/\D/g)
            return [p[2], p[1], p[0]].join("/");
        }

    </script>
</html>
