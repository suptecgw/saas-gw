/**
 * 
 * @type type
 * @author Mateus
 * @description Funcao responsavel por pegar todos elementos com a tag 'acessoMenu' e validar se existe permissao ou não
 * caso nao tenha permissao ela tira seu href, seta a classe sem permissao e oculta ou nao o li
 */
jQuery(document).ready(function () {
    var qt = 0;
    while (jQuery('li[acessoMenu]')[qt] !== undefined) {
        if (jQuery(jQuery('li[acessoMenu]')[qt]).attr('acessoMenu') == 'false') {
            jQuery(jQuery('li[acessoMenu]')[qt]).attr('href', '');
            jQuery(jQuery('li[acessoMenu]')[qt]).addClass('menu-sem-acesso');
            jQuery(jQuery('li[acessoMenu]')[qt]).find('img').remove();
            if (isOcultarMenuSemPermissao) {
                jQuery(jQuery('li[acessoMenu]')[qt]).hide();
            }
        }
        qt++;
    }

    qt = 0;
    while (jQuery('a[acessoModulo]')[qt] !== undefined) {
        if (jQuery(jQuery('a[acessoModulo]')[qt]).attr('acessoModulo') == 'false') {
            jQuery(jQuery('a[acessoModulo]')[qt]).removeAttr('href');

            if (jQuery('a[acessoModulo]')[qt].className.indexOf('finan') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW Finan',true,'gwFinan');");
            } else if (jQuery('a[acessoModulo]')[qt].className.indexOf('logis') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW Logis',true,'gwLogis');");
            } else if (jQuery('a[acessoModulo]')[qt].className.indexOf('trans') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW Trans',true,'gwTrans');");
            } else if (jQuery('a[acessoModulo]')[qt].className.indexOf('frota') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW Frota',true,'gwFrota');");
            } else if (jQuery('a[acessoModulo]')[qt].className.indexOf('mobile') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW Mobile',true,'gwMob');");
            } else if (jQuery('a[acessoModulo]')[qt].className.indexOf('loc') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW Loc');");
            } else if (jQuery('a[acessoModulo]')[qt].className.indexOf('crm') !== -1) {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', "semAcessoModulo('GW CRM');");
            } else {
                jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', 'semAcessoModulo();');
            }
        } else {
            var link = jQuery(jQuery('a[acessoModulo]')[qt]).attr('href');
            jQuery(jQuery('a[acessoModulo]')[qt]).removeAttr('href');
//            jQuery(jQuery('a[acessoModulo]')[qt]).attr('onclick', 'window.open("' + link + '","","width=400,height=300")');
        }
        qt++;
    }

    qt = 0;
    while (jQuery('li[acessocadMenu]')[qt]) {
        if (jQuery(jQuery('li[acessocadMenu]')[qt]).attr('acessocadMenu') == 'false') {
            jQuery(jQuery('li[acessocadMenu]')[qt]).find('img').remove();
        }
        qt++;
    }
});

function semAcessoModulo(nome, isTemPagina, parametroPagina) {
    "use strict";
//            alert("Você não tem licença para uso do modulo "+nome+". \nPara mais informações você poderá ligar no número 81 2125-3752 ou enviar um e-mail para comercial@gwsistemas.com.br.");
    var funcao = function () {
        if (isTemPagina) {
            window.open("http://www.gwsistemas.com.br/solutions.html?gwIten=" + parametroPagina);
        }
    }
    chamarAlert("Você não tem licença para uso do modulo " + nome + ". \nPara mais informações você poderá ligar no número 81 2125-3752 ou enviar um e-mail para comercial@gwsistemas.com.br.", funcao);
}