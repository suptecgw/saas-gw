$(function () {
    var btnSalvar = $('button[class="bt-salvar"]');
    var btnAuditoria = $('button[data-label="Pesquisar"]');
    switch (qs['codTela']) {
        case '76':
            btnSalvar.click(function (e) {
                var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': $('#formCadastro').gwFormToJson()};
                acaoBtSalvar(this, '/CategoriaCargaControlador', obj_envio, false);
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'categoria_carga', qs['id'], dataDe, dataAte);
            });
            $('.lb-name-page').text('Cadastro de Categoria de Carga');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=72";
            });

            break;
        case '77':
            btnSalvar.click(function (e) {
                var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': $('#formCadastro').gwFormToJson()};
                acaoBtSalvar(this, '/ConferenteControlador', obj_envio, false);
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'conferente', qs['id'], dataDe, dataAte);
            });
            $('.lb-name-page').text('Cadastro de Conferente');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=73";
            });
            break;
        case '78':
            btnSalvar.click(function (e) {
                var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': $('#formCadastro').gwFormToJson()};
                acaoBtSalvar(this, '/TabelaAdicionalTdeControlador', obj_envio, false);
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'tde', qs['id'], dataDe, dataAte);
            });
            $('.lb-name-page').text('Cadastro TDE');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=70";
            });
            break;
        case '80':
            btnSalvar.click(function (e) {
                if (beforeSave !== undefined) {
                    if (!(beforeSave())) {
                        return false;
                    }
                }
                var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': $('#formCadastro').gwFormToJson()};
                acaoBtSalvar(this, '/ContratoComercialControlador', obj_envio, false);
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'contrato_comercial', qs['id'], dataDe, dataAte);
            });
            $('.lb-name-page').text('Cadastro de Contrato Comercial');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=79";
            });
            break;
        case '83':
            btnSalvar.click(function (e) {
                var element = this;
                checkSession(function () {
                    var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': $('#formCadastro').gwFormToJson(), id: qs['id']};
                    acaoBtSalvar(element, '/NatControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de NAT');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=82";
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'Nat', qs['id'], dataDe, dataAte);
            });
            break;
        case '84':
            btnSalvar.on('click', function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson()
                    };
                    acaoBtSalvar(btn, '/FTPControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de FTP');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=71";
            });
            btnAuditoria.on('click', function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'ftp', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '86':
            btnSalvar.click(function (e) {
                var formSerializado = JSON.parse($('#formCadastro').gwFormToJson());

                $.each(objetosNota, function (index, elemento) {
                    if (!formSerializado['container-grupos'].some(e => e.idNota == elemento['idNota'])) {
                        // se o form não tem a nota fiscal, adicionar no form
                        formSerializado['container-grupos'].push({
                            'id': elemento['id'],
                            'idNota': elemento['idNota'],
                            'isExcluido': elemento['excluido'],
                            'motivoFalta': elemento['motivoFalta'],
                        });
                    }
                });

                var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': JSON.stringify(formSerializado), id: qs['id']};
                acaoBtSalvar(this, '/InventarioControlador', obj_envio, false);
            });
            $('.lb-name-page').text('Cadastro de Inventário');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=85";
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'inventario', qs['id'], dataDe, dataAte);
            });
            break;
        case '91':
            btnSalvar.click(function (e) {
                var element = this;
                checkSession(function () {
                    var obj_envio = {'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'), 'form': $('#formCadastro').gwFormToJson(), id: qs['id']};
                    acaoBtSalvar(element, '/CfopControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de CFOP');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=92";
            });
            btnAuditoria.click(function (e) {
                this.classList.add('loading');
                this.setAttribute('disabled', 'disabled');
                var dataDe = jQuery('#dataDe').datebox('getValue');
                var dataAte = jQuery('#dataAte').datebox('getValue');
                acaoBtAuditoria(this, 'cfop', qs['id'], dataDe, dataAte);
            });
            break;
        case '95':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        id: qs['id']
                    };
                    acaoBtSalvar(btn, '/LayoutEDIControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Layouts EDI');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=94";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'layout_edi', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '97':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        id: qs['id']
                    };
                    acaoBtSalvar(btn, '/FeriadoControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Feriados');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=96";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'feriados', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '99':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/CaixaPostalSeguradoraControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Caixas Postais de Seguradoras');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=98";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'caixa_postal_seguradora', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;

        case '101':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/ImpressoraControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Impressora Matriciais');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=100";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'printers', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '102':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/CidadeControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Cidade');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=64";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'cidade', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '125':
            btnSalvar.click(function () {
                var botao = this;
                
                checkSession(function() {
                    $('.bloqueio-tela').show();
                    $('.gif-bloq-tela').show();

                    setTimeout(function () {
                        var obj_envio = {
                            'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                            'duplicar_orcamentacoes': $('#chk-ao-salvar').is(':checked'),
                            'qtd_salvar_orcamentacoes': $('#qtd_salvar_orcamentacoes').val(),
                            'form': $('#formCadastro').gwFormToJson()
                        };

                        $('.bloqueio-tela').hide();
                        $('.gif-bloq-tela').hide();

                        acaoBtSalvar(botao, '/OrcamentacaoControlador', obj_envio, false);
                    }, 500);
                });
            });
            btnAuditoria.click(function (e) {
               this.classList.add('loading');
               this.setAttribute('disabled', 'disabled');
               var dataDe = jQuery('#dataDe').datebox('getValue');
               var dataAte = jQuery('#dataAte').datebox('getValue');
               acaoBtAuditoria(this, 'orcamentacao', qs['id'], dataDe, dataAte);
            });
            $('.lb-name-page').text('Lançamento de Orçamentação');
            
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=124";
            });
            break;
        case '123':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/UnidadeCustoControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Unidades de Custos ');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=17";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'coust_types', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '128':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/MovimentacaoPalletsControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Movimentação Pallet');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=126";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'movimentacao_pallets', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '130':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/CertificadoDigitalControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Certificados Digitais');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=129";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'certificados_digitais', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        case '139':
            btnSalvar.click(function () {
                var btn = this;

                checkSession(function () {
                    var obj_envio = {
                        'acao': (qs['modulo'] === 'editar' ? 'editar' : 'cadastrar'),
                        'form': $('#formCadastro').gwFormToJson(),
                        'id': qs['id']
                    };
                    acaoBtSalvar(btn, '/IscaControlador', obj_envio, false);
                }, false);
            });
            $('.lb-name-page').text('Cadastro de Iscas');
            $('.bt-voltar').on('click', function () {
                window.location = "./ConsultaControlador?codTela=138";
            });
            btnAuditoria.click(function () {
                var btn = this;

                checkSession(function () {
                    btn.classList.add('loading');
                    btn.setAttribute('disabled', 'disabled');
                    var dataDe = jQuery('#dataDe').datebox('getValue');
                    var dataAte = jQuery('#dataAte').datebox('getValue');
                    acaoBtAuditoria(btn, 'iscas', qs['id'], dataDe, dataAte);
                }, false);
            });
            break;
        default:
            break;
    }

    if (qs['modulo'] === 'editar') {
        $('.section-check').hide();
    }
});

function acaoBtAuditoria(button, rotina, tabelaId, dataDe, dataAte) {
    $.ajax({
        url: 'AuditoriaControlador?dataDe=' + dataDe + '&dataAte=' + dataAte,
        data: {
            'acao': 'listarAuditoria',
            'rotina': rotina,
            'tabelaId': tabelaId
        },
        complete: function (jqXHR, textStatus) {
            try {
                var tbody = jQuery('.tb-auditoria > tbody');
                //Limpando o tbody
                tbody.html('');
                var logAcoes = JSON.parse(jqXHR.responseText).list[0].logAcoesWebtrans;
                var src_img = homePath + '/assets/img/icones/visualizar_documentos.png';
                if (logAcoes && logAcoes.length > 0) {
                    $.each(logAcoes, function (i, e) {
                        addLogAction(tbody, src_img, e);
                    });
                } else if (logAcoes) {
                    addLogAction(tbody, src_img, logAcoes);
                }
            } catch (exception) {
                chamarAlert('Nenhuma alteração foi encontrada');
            } finally {
                setTimeout(function () {
                    button.classList.remove('loading');
                    button.removeAttribute('disabled');
                }, 1000);
            }
        }
    });
}


function addLogAction(tbody, src_img, e) {
    var tr = jQuery('<tr>');
    var td = jQuery('<td>').text(e.nomeUsuario);
    var inputHidden = jQuery('<input type="hidden">').val(JSON.stringify(e.logAcao.campos[0].campos));
    td.append(inputHidden);

    tr.append(td);
    tbody.append(tr);

    td = jQuery('<td>').text(e.dataAcao);
    tr.append(td);
    tbody.append(tr);

    switch (e.logAcao.action) {
        case 'I':
            td = jQuery('<td>').text('Incluiu');
            tr.append(td);
            tbody.append(tr);
            break;
        case 'U':
            td = jQuery('<td>').text('Atualizou');
            tr.append(td);
            tbody.append(tr);
            break;
    }

    td = jQuery('<td>').text(e.logAcao.clientAddr);
    tr.append(td);
    tbody.append(tr);


    var img = jQuery('<img>').attr('src', src_img);
    td = jQuery('<td>').html(img);
    tr.append(td);
    tbody.append(tr);

    img.click(function () {
        detalhesAuditoria(this);
    });
}

function detalhesAuditoria(e) {
    var inputHidden = $(e).parents('tr').find('td:first-child').find('input[type="hidden"]');
    var arr = inputHidden.val();
    var tbody = jQuery('.tb-auditoria-detalhes > tbody');
    tbody.html('');
    $.each(JSON.parse(String(arr)), function (i, e) {
        var tr = jQuery('<tr>');
        var td = jQuery('<td>');
        td.text(e.descricao);
        tr.append(td);

        var td = jQuery('<td>');
        td.text(e.antes);
        tr.append(td);

        var td = jQuery('<td>');
        td.text(e.depois);
        tr.append(td);

        tbody.append(tr);

    });
    $('.cobre-tudo').show(100);
    $('.detalhes-auditoria').show(100);
}

function fecharAuditoria() {
    $('.cobre-tudo').hide(100);
    $('.detalhes-auditoria').hide(100);
}

/**
 *
 * Função utilizada para setar a acao do botão salvar
 * @param {Element} button
 * @param {string} url_controlador
 * @param {type} objetos_de_envio ( Exemplo de objeto  :  var obj = {nome_parametro : valor_parametro, nome_parametro2 : valor_parametro3}  )
 * @param {boolean} is_montar_data responsavel por ativar o montar data ou nao
 * @returns {void}
 */
function acaoBtSalvar(button, url_controlador, objetos_de_envio, is_montar_data) {
    var aoSalvarContinuar = $('#chk-ao-salvar').is(':checked');
    
    if (qs['codTela'] === '125') {
        aoSalvarContinuar = false;
    }

    button.classList.add('loading');
    button.setAttribute('disabled', 'disabled');

    var msg_validacao = validarTelaCadastro();
    setTimeout(function () {
        if (msg_validacao === '') {
            $.ajax({
                url: (homePath ? homePath : '') + url_controlador,
                method: 'POST',
                data: (is_montar_data ? montarData(objetos_de_envio) : objetos_de_envio),
                complete: function (jqXHR, textStatus) {
                    setTimeout(function () {
                        button.classList.remove('loading');
                        button.removeAttribute('disabled');
                        if (aoSalvarContinuar) {
                            if (jqXHR.getResponseHeader('sucesso') === 'true') {
                                recarregar();
                                // chamarAlert(jqXHR.responseText, recarregar);
                            } else {
                                chamarAlert(jqXHR.responseText);
                            }
                        } else {
                            if (jqXHR.getResponseHeader('sucesso') === 'true') {
                                //chamarAlert(jqXHR.responseText, function () {
                                $(".bt-voltar").trigger("click");
                                //});
                            } else {
                                chamarAlert(jqXHR.responseText);
                            }
                        }

                    }, 50);
                }
            });
        } else {
            button.classList.remove('loading');
            button.removeAttribute('disabled');
            chamarAlert(msg_validacao);
        }
    }, 500);
}

function montarData(objetos_de_envio) {
    var data = {};
    $.each(objetos_de_envio, function (e1, e2) {
        Object.assign(data, {e1: e2});
    });
    return data;
}

function validarTelaCadastro() {
    var retorno = '';
    $.each($('[data-validar=true]'), function (e1, e2) {
        if (retorno === '') {
            $(e2).parent().css('border', '');
            var type = $(e2).attr('data-type');
            var value = $(e2).val();
            var msg_validacao = $(e2).attr('data-erro-validacao');
            switch (type) {
                case 'text':
                    if (value ? value.trim() === '' : true) {
                        $(e2).parent().css('border', '1px solid red');
                        retorno = (msg_validacao ? msg_validacao : 'Preencha os campos corretamente!');
                    }
                    break;
                case 'text-area':
                    if (value ? value.trim() === '' : true) {
                        $(e2).parent().css('border', '1px solid red');
                        retorno = (msg_validacao ? msg_validacao : 'Preencha os campos corretamente!');
                    }
                    break;
            }
        }
    });
    return retorno;
}

function recarregar() {
    window.location.reload(true);
}

function formatarLocalDate(dt) {
    var s = null;
    try {
        s = String(dt.day).padStart(2, '0') + "/" + String(dt.month).padStart(2, '0') + "/" + dt.year;
    } catch (exception) {
        s = '';
    }
    return s;
}

function criadoAlteradoAuditoria(inclusoPor, inclusoEm, atualizadoPor, atualizadoEm) {
    if (inclusoPor && inclusoEm) {
        $('.incluso_td').show();
        $('#inclusoEm').text(inclusoEm);
        $('#inclusoPor').text(inclusoPor);
    }

    if (atualizadoPor && atualizadoEm) {
        $('.alterado_td').show();
        $('#atualizadoEm').text(atualizadoEm);
        $('#atualizadoPor').text(atualizadoPor);
    }
}
