var settings = null;
(function ($) {
    $.fn.gwTelaCadastro = function (opt) {
        //Caso nao envie nenhuma configuracao existe a default
        var config_padrao = {
            //Nome da tela
            "nome_tela": "Cadastro",
            "identificacao_bt_abas": ".btn-aba",
            "section_geral": ".section-geral",
            "section_bt": ".section-bt",
            //Abas
            abas: {
                1: {
                    "identificacao_aba": "[col-ajuda]",
                    "bt_aba": ".btn-aba-ajuda",
                    "texto_aba": "Ajuda",
                    "texto_aba_oculta": "Exibir Ajuda",
                    "texto_aba_visivel": "Ocultar Ajuda",
                    "largura_max_aba": "25%",
                    "largura_min_aba": "-4%",
                    "cor_aba": "var(--tonalidade19)",
                    "velocidade": 200,
                    "is_ativa": false,
                    "ativa": true
                },
                2: {
                    "identificacao_aba": "[col-auditoria]",
                    "bt_aba": ".btn-aba-auditoria",
                    "texto_aba": "Auditoria",
                    "texto_aba_oculta": "Exibir Auditoria",
                    "texto_aba_visivel": "Ocultar Auditoria",
                    "largura_max_aba": "40%",
                    "largura_min_aba": "-4%",
                    "cor_aba": "var(--tonalidade21)",
                    "velocidade": 200,
                    "is_ativa": false,
                    "ativa": true
                }
            }
        };

        settings = $.extend({}, config_padrao, opt);

        //Abas
        jQuery.each(settings.abas, function (count, aba) {
            if (aba.ativa && !$(aba.identificacao_aba)[0]) {
                alert('A aba de "' + aba.texto_aba + '" não foi encontrada. A funcionalidade da aba está comprometida.');
            } else {
                if (aba.is_ativa === false) {
                    $(aba.identificacao_aba).hide();
                }
                $(aba.identificacao_aba).css('background', aba.cor_aba);

                adicionarOuvinteClick(aba);
            }
        });

        if (qs['modulo'] === 'editar') {
            $('.btn-aba-auditoria').show();
        } else {
            $('.btn-aba-auditoria').hide();
        }


    };
    jQuery(".ativa-helper").hover(
            function () {
                try {
                    jQuery(".campo-helper h2").html($($(this).context).find('input')[1].value);
                    jQuery(".descri-helper h3").html(jQuery(this).context.firstElementChild.value);
                } catch (exception) {
                    console.error('Error : Não foi possivel mostrar o texto de ajuda do campo selecionado.');
                }
            },
            function () {
                jQuery('.campo-helper h2').html('Ajuda');
                jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
            }
    );

})(jQuery);


function adicionarOuvinteClick(aba) {
    $(aba.bt_aba).click(function () {
//        if (qs['modulo'] === 'consulta' && aba.texto_aba === 'Auditoria' || qs['modulo'] === 'cadastro' && aba.texto_aba === 'Auditoria') {
//            chamarAlert('Não é possivel acessar a aba de auditoria no modo de cadastro.');
//            return false;
//        }
        if (aba.is_ativa) {
            ocultarAba(aba, true);
        } else {
            //Recarregando os videos
            recarregarVideos();
            var ocultandoAba = false;
            jQuery.each(settings.abas, function (count, valida_aba) {
                if (aba !== valida_aba && valida_aba.is_ativa === true) {
                    ocultandoAba = true;
                    ocultarAba(valida_aba);
                }
            });
            if (ocultandoAba) {
                setTimeout(function () {
                    abrirAba(aba);
                }, aba.velocidade + 20);
            } else {
                abrirAba(aba);
            }
        }
    });
}

function abrirAba(aba) {
    if (aba.is_ativa === false) {
        $(aba.identificacao_aba).show();
        aba.is_ativa = true;

        $(aba.identificacao_aba).animate({
            'width': aba.largura_max_aba
        }, aba.velocidade);

        let w_section = 'calc(75% - 70px)';
        if (parseInt(aba.largura_max_aba.replace('%', '')) > 25) {
            w_section = 'calc(60% - 70px)';
        }
        $(settings.section_geral).css('width', w_section);
        $(settings.section_bt).css('width', w_section);
        $(aba.bt_aba).text(aba.texto_aba_visivel);
        $('.btn-aba-ajuda').addClass('btn-aba-ajuda-on');
        $('.btn-aba-ajuda-on').removeClass('btn-aba-ajuda');
    }
}

function ocultarAba(aba, redimensionarSection) {
    if (aba.is_ativa === true) {
        aba.is_ativa = false;
        $(aba.identificacao_aba).animate({
            'width': aba.largura_min_aba
        }, aba.velocidade, function () {
            $(aba.identificacao_aba).hide();
        });
        if (redimensionarSection) {
            let w_section = 'calc(100% - 70px)';
            $(settings.section_geral).css('width', w_section);
            $(settings.section_bt).css('width', w_section);
        }
        $(aba.bt_aba).text(aba.texto_aba_oculta);
        $('.btn-aba-ajuda-on').addClass('btn-aba-ajuda');
        $('.btn-aba-ajuda').removeClass('btn-aba-ajuda-on');
    }
}


function GetQueryString(a) {
    a = a || window.location.search.substr(1).split('&').concat(window.location.hash.substr(1).split("&"));

    if (typeof a === "string")
        a = a.split("#").join("&").split("&");

    // se nï¿½o hï¿½ valores, retorna um objeto vazio
    if (!a)
        return {};

    var b = {};
    for (var i = 0; i < a.length; ++i)
    {
        // obtem array com chave/valor
        var p = a[i].split('=');

        // se nï¿½o houver valor, ignora o parametro
        if (p.length != 2)
            continue;

        // adiciona a propriedade chave ao objeto de retorno
        // com o valor decodificado, substituindo `+` por ` `
        // para aceitar URLs codificadas com `+` ao invï¿½s de `%20`
        b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
    }
    // retorna o objeto criado
    return b;
}

var qs = GetQueryString();

function addAjudaLabel(name, lb, valueInputAjuda) {
    var label = jQuery('#' + name);

    var createInputAjuda = "<input type=\"hidden\" value='" + valueInputAjuda + "'>";
    var createNameAjuda = "<input type=\"hidden\" value='" + lb + "'>";

    label.append(createInputAjuda);
    label.append(createNameAjuda);
}

function addPermissoesTela(codigo, descricao, observacao) {
    jQuery('.table_permissao tbody').append('<tr><td>' + codigo + '</td><td>' + descricao + '</td><td>' + observacao + '</td></tr>');
}

function semPermissao() {
    jQuery('.table_permissao tbody').append('<tr><td colspan="3">Não existe permissões para esta tela.</td></tr>');
}


function getCodTela() {
//    qs['codigo']

    var len = qs['codTela'].length;
    var cod = qs['codTela'];
    var codigo = '';

    switch (len) {
        case 1:
            codigo = 'T0000' + cod;
            break;
        case 2:
            codigo = 'T000' + cod;
            break;
        case 3:
            codigo = 'T00' + cod;
            break;
        default:
            codigo = 0;
            break;
    }
    return codigo;

}

function carregarAjuda() {
    jQuery.ajax({
        url: "UsuarioControlador?acao=ativarAjuda&codigoTela=" + getCodTela(),
        type: 'POST',
        dataType: 'text/html',
        beforeSend: function () {
            if (jQuery('.aguarde') !== undefined) {
                jQuery('.cobre-left').show('fast');
                jQuery('.aguarde').show('fast');
            }
        },
        complete: function (retorno) {
            if (jQuery('.aguarde') !== undefined) {
                jQuery('.aguarde').hide('fast');
                jQuery('.cobre-left').hide('fast');
            }

            if (retorno.responseText !== '') {

                var camposAjuda = JSON.parse(retorno.responseText.split(']')[0] + ']');
                var permissoes = JSON.parse(retorno.responseText.split(']')[1] + ']');


                for (var i = 0; i < camposAjuda.length; i++) {
                    var jsonCampos = camposAjuda[i];
                    addAjudaLabel(jsonCampos.name, jsonCampos.label, jsonCampos.observacao);
                }

                for (var i = 0; i < permissoes.length; i++) {
                    var jsonPerm = permissoes[i];
                    addPermissoesTela(jsonPerm.codigo, jsonPerm.descricao, jsonPerm.observacao);
                }
                if (permissoes.length === 0) {
                    semPermissao();
                }

            } else {
                semPermissao();
            }
        }
    });
}

carregarAjuda();
//FUNCOES DE ABRIR ABAS COM F
shortcut.add("f1", function (e) {
    $('.btn-aba-ajuda').trigger('click');
});

shortcut.add("f8", function (e) {
    $('.bt-salvar').trigger('click');
});

function ativarMascaraCampoData() {
    setTimeout(function () {
        if (document.getElementById('dataDe') !== null) {
            jQuery('#dataDe').datebox('textbox').bind('focusout', function (e) {
                completarData(this, e, 'dataDe');
            });

            jQuery('#dataAte').datebox('textbox').bind('focusout', function (e) {
                completarData(this, e, 'dataAte');
            });
        }
    }, 1000);
}

$(document).ready(function() {
    jQuery('#dataDe,#dataAte').gwDatebox({
        'funcao_apos_criacao': function (elemento) {
            elemento.parent().find('.datebox').css('width', '93%');
            elemento.parent().find('.textbox-text').css('width', '93%').css('font-size', '14px');
        }
    });
});