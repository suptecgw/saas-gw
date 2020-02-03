var myConfObj = {
    iframeMouseOver: false
};

var containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});

function editar(position) {
    var id = jQuery("#hi_row_id_" + position).val();
    location.replace("UsuarioControlador?acao=iniciarEditar&idUsuario=" + id);
}

function consulta() {
    jQuery("#formConsulta").submit();
}
/*
 function launchPDF(url, idname) {
 var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
 var pdf = window.open(url, idname, cf);
 pdf.window.resizeTo(screen.width, screen.height - 20);
 pdf.focus();
 }
 
 function popRel(position) {
 var id = jQuery("#hi_row_id_" + position).val();
 var modelo = jQuery('#cbmodelo').val();
 launchPDF('./relmotoristas?acao=exportar&modelo=' + modelo + '&filial=0&desligado=&idmotorista=' + id + '&impressao=1&tipoMotorista=todos');
 }
 */
function excluir(item) {
    var index = 0;
    var ids = '';
    var nomes = '';
    if (item == undefined) {
        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {

            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_id_' + val).val();
            var nome = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().find('#hi_row_nome_' + val).val();

            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                ids += id + ',';
            } else {
                ids += id;
            }

            nomes += '<li>' + nome + '</li>';

            index++;
        }
    } else if (item) {
        ids = jQuery('#hi_row_id_' + item).val();
        nomes = jQuery('#hi_row_descricao_' + item).val();
    }

    var texto = "";
    if (index > 1) {
        texto = "Deseja excluir os usuários abaixo?";
    } else {
        texto = "Deseja excluir o usuário abaixo?";
    }
    chamarConfirm(texto, 'aceitouExcluirUsuario("' + ids + '")', '', 1, '<ul class="square">' + nomes + '</ul>');

}

function aceitouExcluirUsuario(ids) {
    jQuery.ajax({
        url: 'UsuarioControlador?acao=excluir&ids=' + ids,
        success: function (data, textStatus, jqXHR) {
            chamarAlert(data, reload);
        }
    });
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {

    jQuery('#select-tipo-usuario').selectGrupoMultiploGw({
        input: 'select-tipo-usuario',
        grupos: {
            Tipo: {
                1: 'Ativo!!ativo!!Sim!!IGUAL',
                2: 'Inativo!!ativo!!Não!!IGUAL'
            }
        }
    });

    jQuery('#select-exceto-apenas-tipo-usuario').selectExcetoApenasGw({
        width: '170px'
    });
    
    jQuery('#select-exceto-apenas-filial').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#select-exceto-apenas-grupo-usuario').selectExcetoApenasGw({
        width: '170px'
    });

    jQuery('#inptFilial').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery('#inptGrupoUsuario').inputMultiploGw({
        width: '96%',
        readOnly: 'true'
    });

    jQuery("#paneConsulta").css('height', jQuery(window).height() - 300);

    jQuery('.cobre-tudo').click(function () {
        var container = jQuery('.container-salvar-filtros');
        if (jQuery('.container-salvar-filtros').css('display') == 'block') {
            jQuery('.cobre-tudo').hide('low');
            //Alterando cor
            jQuery('.salvarPesquisaContainer').css('background', 'rgba(12,37,62,0.4)');

            container.animate({
                'width': '0px'
            }, 200, function () {
                container.hide();
                container.animate({
                    'height': '0px'
                }, 1);
            });
        }

    });


    jQuery('.salvarPesquisaContainer').click(function () {
        var top = parseInt(jQuery('.salvarPesquisaContainer').offset().top) - 335;
//                    var top = 0;
        var container = jQuery('.container-salvar-filtros');

        if (container.css('width') == '0px') {
            container.show();

            
            jQuery('.cobre-tudo').show('low');
            container.css('margin-top', top + 'px');
            container.animate({
                'height': '315px'
            }, 200, function () {
                container.animate({
                    'width': '400px'
                }, 200);
            });


        } else {
            jQuery('.cobre-tudo').hide('low');
            //Alterando cor
            jQuery('.salvarPesquisaContainer').css('background', 'rgba(12,37,62,0.4)');

            container.animate({
                'width': '0px'
            }, 200, function () {
                container.hide();
                container.animate({
                    'height': '0px'
                }, 1);
            });

        }

    });

    var iframe = document.getElementById('iframeSalvarFiltros');
    srcSalvarFiltroOriginal = iframe.src;

});

var srcSalvarFiltroOriginal = null;
var objCompleto;

function alerarFiltroPesquisa() {
    var iframe = document.getElementById('iframeSalvarFiltros');

    if (jQuery('#select-pesquisa').val() == 0) {
        iframe.src = srcSalvarFiltroOriginal;
    } else {
        iframe.src = srcSalvarFiltroOriginal + '?nomePesquisa=' + jQuery('#select-pesquisa').val() + '&isPrivada=' + true;
    }

    jQuery('.cobre-tudo').css('display', 'block');
    jQuery('.cobre-tudo').css('background', 'rgba(100, 100, 100, 0.4)');
    jQuery('.div-lb-filtros').css('z-index', '99');


    setTimeout(function () {
        jQuery.ajax({
            url: 'ConsultaControlador',
            type: 'POST',
            async: false,
            data: {
                acao: 'alterarFiltroPesquisa',
                nomeFiltro: jQuery('#select-pesquisa').val(),
                codigoTela: codigo_tela
            },
            success: function (data, textStatus, jqXHR) {
                jQuery('#createdMe').prop('checked', false);
                removerValorInput('inpSelectVal');
                removerValorInput('inptFilial');
                removerValorInput('inptGrupoUsuario');
                removerValorInput('select-tipo-usuario');

                objCompleto = jQuery.parseJSON(jQuery.parseJSON(data));

                var ordenarPor = objCompleto.ordenacao.trim().split(" ")[0];
                var tipoOrd = objCompleto.ordenacao.trim().split(" ")[1];

                var limiteResultados = objCompleto.limiteResultado;
                var operador = objCompleto.operador1;

                //seta o id da preferencia na variavel, (usada para update)
                idPreferencia = objCompleto.idPreferencia;

                //Operador
                jQuery('#select-oper option[value=' + operador + ']').prop('selected', true);
                jQuery("#select-oper").selectmenu("refresh");

                //Limite
                jQuery('#select-limite option[value=' + limiteResultados + ']').prop('selected', true);
                jQuery("#select-limite").selectmenu("refresh");


                //Ordenar por e se é rescente ou nao
                //------------------------------------------------------------------------------------------
                jQuery('#select-ordenacao option[value=' + ordenarPor + ']').prop('selected', true);
                jQuery("#select-ordenacao").selectmenu("refresh");

                jQuery('#select-order-tipo option[value=' + tipoOrd + ']').prop('selected', true);
                jQuery("#select-order-tipo").selectmenu("refresh");
                //------------------------------------------------------------------------------------------

                if (objCompleto.valor21 == 'null') {
                    jQuery('.container-campos-select').show();
                    jQuery('.container-data').hide();

                    jQuery("#dataAte").datebox({disabled: true});
                    jQuery("#dataDe").datebox({disabled: true});


                    jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                    jQuery("#select-abrev").selectmenu("refresh");


                    var valor1 = objCompleto.valor1.replace(/\[+/g, '').replace(/\]+/g, '');
                    valor1 = valor1.split(',');

                    for (var i = 0; i < valor1.length; i++) {
                        addValorAlphaInput('inpSelectVal', valor1[i].trim());
                    }

                }

                if (objCompleto.valor1 != null && objCompleto.valor1 != undefined && objCompleto.valor21 != 'null') {
                    jQuery('#select-abrev option[value=' + objCompleto.nome1 + ']').prop('selected', true);
                    jQuery("#select-abrev").selectmenu("refresh");

                    jQuery('.container-campos-select').hide();
                    jQuery('.container-data').show();
                    jQuery("#dataAte").datebox({disabled: false});
                    jQuery("#dataDe").datebox({disabled: false});

                    jQuery('#dataAte').datebox('setValue', objCompleto.valor21);
                    jQuery('#dataDe').datebox('setValue', objCompleto.valor1);

                    jQuery('.datebox').css('width', '93%');
                    jQuery('.textbox-text').css('width', '93%');
                    jQuery('.textbox-text').css('font-size', '14px');
                }


                if (objCompleto.nomeCreatedMe != null && objCompleto.nomeCreatedMe != undefined) {
                    jQuery('#createdMe').prop('checked', true);
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeFilial != null && objCompleto.nomeFilial != undefined) {
                    var filiais = objCompleto.valorFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    filiais = filiais.split(',');

                    var nomeFilial = objCompleto.descricaoFilial.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeFilial = nomeFilial.split(',');

                    for (var i = 0; i < filiais.length; i++) {
                        addValorAlphaInput('inptFilial', nomeFilial[i], filiais[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeGru != null && objCompleto.nomeGru != undefined) {
                    var grupo = objCompleto.valorGru.replace(/\[+/g, '').replace(/\]+/g, '');
                    grupo = grupo.split(',');

                    var nomeGrupo = objCompleto.descricaoGru.replace(/\[+/g, '').replace(/\]+/g, '');
                    nomeGrupo = nomeGrupo.split(',');

                    for (var i = 0; i < grupo.length; i++) {
                        addValorAlphaInput('inptGrupoUsuario', nomeGrupo[i], grupo[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }

                if (objCompleto.nomeAtivo != null && objCompleto.nomeAtivo != undefined) {
                    var valorAtivo = objCompleto.valorAtivo.replace(/\[+/g, '').replace(/\]+/g, '');
                    valorAtivo = valorAtivo.split(',');
                    var descAtivo = objCompleto.descricaoAtivo.replace(/\[+/g, '').replace(/\]+/g, '');
                    descAtivo = descAtivo.split(',');
                    for (var i = 0; i < valorAtivo.length; i++) {
                        gerenciarTipoUsuario(objCompleto.nomeAtivo, valorAtivo[i], objCompleto.condicaoAtivo, descAtivo[i]);
                    }
                    jQuery('#filtros-adicionais-container').show();
                }


            },
            error: function (jqXHR, textStatus, errorThrown) {
                chamarAlert('Ocorreu um erro ao tentar carregar o filtro escolhido.');
            },
            complete: function (jqXHR, textStatus) {
                jQuery('#search').trigger('click');
            }

        });

    }, 500);
}

function gerenciarInpSelectVal(nome, valor, valor2) {
    if (jQuery('#select-abrev option[value=' + nome + ']').size() >= 1) {
        if (nome == 'data_criacao') {
            jQuery('.container-campos-select').hide(250, function () {
                jQuery('.container-data').show(250);
                jQuery("#dataAte").datebox({disabled: false});
                jQuery("#dataDe").datebox({disabled: false});

                jQuery('#dataAte').datebox('setValue', valor2);
                jQuery('#dataDe').datebox('setValue', valor);

                jQuery('.datebox').css('width', '93%');
                jQuery('.textbox-text').css('width', '93%');
                jQuery('.textbox-text').css('font-size', '14px');
            });
        } else if (nome == 'data_ultima_alteracao') {
            jQuery('.container-campos-select').hide(250, function () {
                jQuery('.container-data').show(250);

                jQuery("#dataAte").datebox({disabled: false});
                jQuery("#dataDe").datebox({disabled: false});

                jQuery('#dataAte').datebox('setValue', valor2);
                jQuery('#dataDe').datebox('setValue', valor);

                jQuery('.datebox').css('width', '93%');
                jQuery('.textbox-text').css('width', '93%');
                jQuery('.textbox-text').css('font-size', '14px');
            });
        } else {
            jQuery("#dataAte").datebox({disabled: true});
            jQuery("#dataDe").datebox({disabled: true});
            valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
            valor = valor.split(",");
            for (var i = 0; i < valor.length; i++) {
                addValorAlphaInput('inpSelectVal', valor[i].trim());
            }
        }
    }
}

function gerenciarCheckBox(nome, valor) {
    if (nome == 'criado_por') {
        jQuery('#createdMe').prop('checked', true);
        jQuery('#filtros-adicionais-container').show();
    }
}

function gerenciarTipoUsuario(name, valor, descricao) {
    if (name === 'ativo') {
        if (jQuery('#filtros-adicionais-container').css('display') === 'none') {
            jQuery('#filtros-adicionais').trigger('click');
        }
        addValorSelectMultiploGrupo('status-usuario', valor, descricao);
    }
}

function gerenciarTipoUsuario(name, valor, condicao, descricao) {
    valor = valor.trim();
    if (name == 'ativo') {
        if (valor == 'Sim') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[1]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-usuario option[value="' + condicao + '"]').attr('selected', 'selected');
        } else if (valor == 'Não') {
            jQuery(jQuery('.container-select-multiplo-gw-A').find('li')[2]).trigger('click');
            jQuery('#filtros-adicionais-container').show();
            jQuery('#select-exceto-apenas-tipo-usuario option[value="' + condicao + '"]').attr('selected', 'selected');
        }
    }
    jQuery('.container-li-valores').hide();
}

function gerenciarInpFilial(nome, valor, descricao, condicao) {
    if (nome == 'id_filial') {
        jQuery('#select-exceto-apenas-filial option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptFilial', descricao[i].trim(), valor[i].trim());
        }
    }
}

function gerenciarInpGrupoUsuario(nome, valor, descricao, condicao) {
    if (nome == 'grupo_id') {
        jQuery('#select-exceto-apenas-grupo-usuario option[value="' + condicao + '"]').attr('selected', 'selected');

        valor = valor.replace(/\[+/g, '').replace(/\]+/g, '');
        descricao = descricao.replace(/\[+/g, '').replace(/\]+/g, '');

        valor = valor.split(",");
        descricao = descricao.split(",");

        for (var i = 0; i < valor.length; i++) {
            jQuery('#filtros-adicionais-container').show();
            addValorAlphaInput('inptGrupoUsuario', descricao[i].trim(), valor[i].trim());
        }
    }
}

function popRel(position) {
    var ids = '';
    var impressao = jQuery('input[name="formaImpressao"]:checked').val();
    if (!position) {
        var index = 0;
        var nomes = '';

        while (jQuery('input:checked[type=checkbox][name*=nCheck]')[index] != undefined) {
            var val = jQuery('input:checked[type=checkbox][name*=nCheck]')[index].value;
            var id = jQuery(jQuery('input:checked[type=checkbox][name*=nCheck]')[index]).parent().parent().find('#hi_row_id_' + val).val();

            if (jQuery('input:checked[type=checkbox][name*=nCheck]')[index + 1] != undefined) {
                ids += id + ',';
            } else {
                ids += id;
            }
            index++;
        }
        if (ids == undefined || ids == "") {
            chamarAlert("Selecione pelo menos um manifesto!");
            return null;
        }
    } else {
        ids = jQuery('#hi_row_id_' + position).val();
    }
    window.open("UsuarioControlador?acao=imprimirDocumento" +
            "&id=" + ids + "&impressao=" + impressao,
            "", "titlebar=no, menubar=no, scrollbars=yes," +
            " status=yes,  resizable=yes, left=0, top=0");
}