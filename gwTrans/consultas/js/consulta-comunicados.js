let myConfObj = {
    iframeMouseOver: false
};

let containerVideo = null;

window.addEventListener('blur', function () {
    if (myConfObj.iframeMouseOver) {
        jQuery(containerVideo).trigger('change');
    }
});

function consulta() {
    jQuery("#formConsulta").submit();
}

function reload() {
    window.location.reload();
}

jQuery(document).ready(function () {
    jQuery('.cobre-tudo').click(function () {
        let container = jQuery('.container-salvar-filtros');
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

    let iframe = document.getElementById('iframeSalvarFiltros');
    srcSalvarFiltroOriginal = iframe.src;
    
    // Ocultar checks
    jQuery('#tabela-gwsistemas thead th:first-child, #tabela-gwsistemas tbody td:first-child').hide();
    
    jQuery('.corpo-container-menu > ul').empty().each(function () {
        let elemento = jQuery(this);
        
        elemento.append(jQuery('<li>', {'class': 'assistir_comunicado'}).html('<img src="' + homePath + '/img/icone-duplicata.png" width="20px"><span>Visualizar Comunicado</span>'));
    });
    
    let divImagemEditar = jQuery('img[title="Editar"]').parent();
    
    divImagemEditar.empty().append('<img title="Visualizar Comunicado" style="cursor: pointer;" class="visualizar_comunicado" src="' + homePath + '/img/icone-duplicata.png" width="15px" height="15px">')
    
    jQuery('#tabela-gwsistemas').on('click', '.visualizar_comunicado', function () {
        let primeiraTd = jQuery(this).parent().parent().parent().find('td').first();
        
        chamarAnuncio(primeiraTd.find('input[name*="id"]').val(), primeiraTd.find('input[name*="local_arquivo_html"]').val());
    }).on('click', '.assistir_comunicado', function () {
        let primeiraTd = jQuery(this).parent().parent().parent().parent().parent().parent().find('td').first();

        chamarAnuncio(primeiraTd.find('input[name*="id"]').val(), primeiraTd.find('input[name*="local_arquivo_html"]').val());
    });
});

function chamarAnuncio(id, html) {
    jQuery('.iframe-anuncio-escolhido').attr('src', homePath + '/anuncios/container-anuncios.jsp?&idAnuncio=' + id + '&htmlAnuncio=' + html + '&tema=' + tema);

    jQuery('.cobre-anuncio-escolhido').show(250, function () {
        jQuery('.iframe-anuncio-escolhido').show(250);
    });
}

function salvarAcao() {
    fecharAnuncio();
}

function fecharAnuncio() {
    jQuery('.cobre-anuncio').hide(250);
    jQuery('.iframe-anuncio').hide(250);
    jQuery('.cobre-anuncio-escolhido').hide(250);
    jQuery('.iframe-anuncio-escolhido').hide(250);
}

let srcSalvarFiltroOriginal = null;
let objCompleto;

function alerarFiltroPesquisa() {
    let iframe = document.getElementById('iframeSalvarFiltros');

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
                removerValorInput('inpSelectVal');

                objCompleto = jQuery.parseJSON(jQuery.parseJSON(data));

                let ordenarPor = objCompleto.ordenacao.trim().split(" ")[0];
                let tipoOrd = objCompleto.ordenacao.trim().split(" ")[1];

                let limiteResultados = objCompleto.limiteResultado;
                let operador = objCompleto.operador1;

                //seta o id da preferencia na variavel, (usada para update)
                idPreferencia = objCompleto.idPreferencia;

                //Operador
                jQuery('#select-oper option[value=' + operador + ']').prop('selected', true);
                jQuery("#select-oper").selectmenu("refresh");

                //Limite
                jQuery('#select-limite option[value=' + limiteResultados + ']').prop('selected', true);
                jQuery("#select-limite").selectmenu("refresh");

                //Ordenar por e se é crescente ou nao
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

                    let valor1 = objCompleto.valor1.replace(/\[+/g, '').replace(/]+/g, '');
                    valor1 = valor1.split(',');

                    for (let i = 0; i < valor1.length; i++) {
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
        if (nome === 'data' || nome === 'dt_inicio' || nome === 'dt_final') {
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

            valor = valor.replace(/\[+/g, '').replace(/]+/g, '');
            valor = valor.split(",");

            for (let i = 0; i < valor.length; i++) {
                addValorAlphaInput('inpSelectVal', valor[i].trim());
            }
        }
    }
}

(function (i, s, o, g, r, a, m) {
    i['GoogleAnalyticsObject'] = r;
    i[r] = i[r] || function () {
        (i[r].q = i[r].q || []).push(arguments)
    }, i[r].l = 1 * new Date();
    a = s.createElement(o),
        m = s.getElementsByTagName(o)[0];
    a.async = 1;
    a.src = g;
    m.parentNode.insertBefore(a, m)
})(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');
ga('create', 'UA-86105277-1', 'auto');
ga('send', 'pageview');