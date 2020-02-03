<%-- 
    Document   : grid-default
    Created on : 19/07/2016, 10:05:25
    Author     : gleidson
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<link href="${homePath}/gwTrans/consultas/css/style-grid-coleta.css" rel="stylesheet" type="text/css"/>
<c:if test="${lista != null && lista.rows != null}">
    <div class="panel datagrid datagrid-wrap panel-body panel-body-noheader" id="paneConsulta" name="paneConsulta">

    </div>
    <div class="datagrid-pager pagination" style="margin-right: 25px;float: right;margin-top: 10px;">
        <div align="right" style="float: right;">
            <span>Página </span>
            <input type="text" size="2" value="${paginaAtual}" onkeyup="verificaCaracterePagina(this,${paginas+1});" onchange="verificaPagina(this,${paginas+1});" onkeypress="paginaEnter(event, this.value);" class="pagination-num">
            <!--<input type="text" size="2"  class="pagination-num">-->
            <span>de ${paginas}</span>
            <a href="javascript:${paginaAtual > 1 ? 'anterior();':''};" class="${paginaAtual > 1 ? 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain' : 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled'}" group="" id="" style="margin-right: -13px;">
                <span class="l-btn-left l-btn-icon-left">
                    <span class="l-btn-text l-btn-empty">&nbsp;</span>
                    <span class="l-btn-icon pagination-prev">&nbsp;</span>
                </span>
            </a>
            <a href="javascript:${paginas >= 1 && paginaAtual < paginas ? 'proxima();' : ''};" class="${paginas >= 1 && paginaAtual < paginas ? 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain' : 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled'}" style="z-index: 999999;" group="" id="">
                <span class="l-btn-left l-btn-icon-left">
                    <span class="l-btn-text l-btn-empty">&nbsp;</span>
                    <span class="l-btn-icon pagination-next">&nbsp;</span>
                </span>
            </a>
        </div>
    </div>
</c:if>
<script defer type="text/javascript">
    /*Define a altura da grid*/
    var heightDoc = jQuery(window).height();
    jQuery("#paneConsulta").css('height', heightDoc - 320);
    jQuery(".heightDoc").css('height', heightDoc - 70);
    jQuery(".contentMap").css('height', heightDoc - 270);
    /*Define a altura da grid*/


    var homePath = '${homePath}';
    var resultList = `${cg:resultListToJson(lista)}`;
    var codTela = '${param.codTela}';
    jQuery(document).ready(function () {
        setTimeout(function () {
            var th, tr, td, span, center, lb, img, div, div2, ul, li, a, input, nav = null;
            //Criação da tabela
            var table = jQuery('<table cellspacing="0" class="tabela-gwsistemas"  id="tabela-gwsistemas">');
            //Criação da thead
            var thead = jQuery('<thead>');
            /*
             * Inicio do codigo da THEAD
             */
            if (${tela != null && tela.columns != null ? true:false}) {
                tr = jQuery('<tr>');
                /*
                 * Primeira TH
                 */
                th = jQuery('<th largura="30px" class="nao">');
                center = jQuery('<center>');
                var inputCheck = jQuery('<input type="checkbox" onclick="marcarTodos(this);">');
                center.append(inputCheck);
                th.append(center);
    <c:forEach var="col" items="${tela.columns}" varStatus="colStatus" >
                var inptH = jQuery('<input type="hidden" name="hi_row_${col.nome}" id="hi_row_${col.nome}">');
                th.append(inptH);
    </c:forEach>
                tr.append(th);
                /*
                 * Segunda TH e Terceira TH
                 */
                th = jQuery('<th largura="30px" class="nao">');
                tr.append(th);
                th = jQuery('<th largura="30px" class="nao">');
                tr.append(th);
                /*
                 * TH Dinamica
                 */

    <c:forEach var="col" items="${tela.columns}" varStatus="colTelaStatus" >
                th = jQuery('<th id="${colTelaStatus.count}" style="" largura="${col.largura != null && col.largura != "" ? col.largura : col.colXml.width}" class="${col.fixo ? 'nao' : ''} pode-setar-ordem" nome="${fn:toUpperCase(col.colXml.name)}">');
                lb = jQuery('<label class="nome-coluna" >${col.colXml.label}</label>');
                th.append(lb);
                img = jQuery('<img src="img/th-menu.png">');
                th.append(img);
                div = jQuery('<div class="menu-span-dropdown-content" onclick="">');
                ul = jQuery('<ul>');
                li = jQuery('<li class="ad-rm-col add-col">');
                a = jQuery('<a>');
                div2 = jQuery('<div>');
                lb = jQuery('<label>').text('Adicionar Coluna');
                li.append(a.append(div2.append(lb)));
                ul.append(li);
                div.append(ul);
        <c:if test="${!col.fixo}">
                li = jQuery('<li class="ad-rm-col" onclick="ocultarColumn(this);">');
                a = jQuery('<a>');
                div2 = jQuery('<div>');
                lb = jQuery('<label>').text('Ocultar Coluna');
                li.append(a.append(div2.append(lb)));
                ul.append(li);
                div.append(ul);
        </c:if>
                ul = jQuery('<ul>');
                li = jQuery('<li class="ad-rm-col" onclick="ordenar(this);">');
                a = jQuery('<a>');
                div2 = jQuery('<div>');
                lb = jQuery('<label>').text('Ordem Crescente');
                li.append(a.append(div2.append(lb)));
                ul.append(li);
                div.append(ul);
                ul = jQuery('<ul>');
                li = jQuery('<li class="ad-rm-col" onclick="ordenar(this);">');
                a = jQuery('<a>');
                div2 = jQuery('<div>');
                lb = jQuery('<label>').text('Ordem Decrescente');
                li.append(a.append(div2.append(lb)));
                ul.append(li);
                div.append(ul);
                ul = jQuery('<ul>');
                li = jQuery('<li class="ad-rm-col" onclick="chamarConfirm(\'Tem certeza que deseja redefinir todas as colunas para o padrão original do sistema?\', \'redefinirColunas()\', null);">');
                a = jQuery('<a>');
                div2 = jQuery('<div>');
                lb = jQuery('<label>').text('Redefinir Colunas');
                li.append(a.append(div2.append(lb)));
                ul.append(li);
                div.append(ul);
                th.append(div);
                div = jQuery('<div class="conteudo-colunas">');
        <c:set var="idTh" value="${colTelaStatus.count + 1}" />
        <c:forEach var="column" items="${tela.targetXml.column}" varStatus="rowStatus" >
            <c:set var="podeAdicionar" value="true" />
            <c:forEach var="col" items="${tela.columns}" varStatus="colTelaStatus" >
                <c:if test="${col.nome == column.name}">
                    <c:set var="podeAdicionar" value="false" />
                </c:if>
            </c:forEach>
            <c:if test="${column.visivel && podeAdicionar}">
                div2 = jQuery('<div class="col-md-12" onclick="adicionarColuna(\'${column.name}\', \'${column.label}\', this);event.preventDefault();event.stopPropagation();">');
                lb = jQuery('<label name="${column.name}">').text('${column.label}');
                div2.append(lb);
                div.append(div2);
            </c:if>
        </c:forEach>
                th.append(div);
                //Add a th na tr
                tr.append(th);
                thead.append(tr);
                table.append(thead);
    </c:forEach>
            }
            //Criação da tbody
            var tbody = jQuery('<tbody>');
            /*
             * Inicio do codigo da TBODY
             */
    <c:forEach var="row" items="${lista.rows}" varStatus="rowStatus" >
            tr = jQuery('<tr>');
            td = jQuery('<td>');
            center = jQuery('<center>');
            input = jQuery('<input type="checkbox" id="nCheck${rowStatus.count}" name="nCheck${rowStatus.count}" value="${rowStatus.count}" onclick="trChecked(this,${rowStatus.count});recalcularTotais();"/>');
            center.append(input);
            td.append(center);
        <c:forEach var="col" items="${row.columns}" varStatus="colStatus" >
            input = jQuery('<input type="hidden"  name="hi_row_${col.nome}_${rowStatus.count}" id="hi_row_${col.nome}_${rowStatus.count}" value="${col}" />');
            td.append(input);
        </c:forEach>
            tr.append(td);
            td = jQuery('<td>');
            center = jQuery('<center>');
            img = jQuery('<img class="img-menu-coleta" src="${homePath}/img/th-menu-escuro.png">');
            center.append(img);
            nav = jQuery('<nav class="container-menu-coleta">');
            div = jQuery('<div class="topo-container-menu" menu-coleta="${rowStatus.count}">').html('Nº CT-e - ');
            nav.append(div);
            div = jQuery('<div>');
            ul = jQuery('<ul>');

            li = jQuery('<li onclick="checkSession(function () {visualizar(${rowStatus.count},${nivelFilial},' + '\'' + '${userFilialAbrev}' + '\'' + ');}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/visualizar_documentos.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Visualizar CT-e');
            li.append(span);
            ul.append(li);

            div.append(ul);
            nav.append(div);
            center.append(nav);
            td.append(center);
            tr.append(td);
            td = jQuery('<td>');
            center = jQuery('<center>');
            img = jQuery('<img width="15px" height="15px" title="Visualizar CT-e" style="cursor: pointer;" onclick="checkSession(function () {visualizar(${rowStatus.count}, ${nivelFilial}, ' + '\'' + '${userFilialAbrev}' + '\'' + ');}, false);" src="assets/img/icones/visualizar_documentos.png">');
            center.append(img);
            td.append(center);
            tr.append(td);
        <c:forEach var="col" items="${tela.columns}" varStatus="colStatus" >
            <c:set var="indice" value="${cg:indexOf(row.columns, col.nome)}" />
            <c:set var="colResult" value="${row.columns[indice]}" />
            <c:if test="${indice > -1}">
            td = jQuery('<td>');
            lb = jQuery('<label title="${colResult.label}: ${colResult}" style="">${cg:formatCampoConsulta(colResult)}</label>');
            td.append(lb);
            tr.append(td);
            </c:if>
        </c:forEach>
            tbody.append(tr);
    </c:forEach>
            table.append(tbody);
            //Adicionando a tabela no pane
            jQuery('#paneConsulta').append(table);

            verifyPesoKg();

            /*
             * FUNCOES TABELA 
             */

            jQuery('.conteudo-colunas .col-md-12').click(function (event) {
                event.preventDefault;
            });
            jQuery('.tabela-gwsistemas > thead > tr > th').hover(
                    function () {
                        jQuery(jQuery(this).find('img')).css('opacity', '1.0');
                    },
                    function () {
                        jQuery(jQuery(this).find('img')).css('opacity', '0.0');
                    }
            );
            jQuery('.tabela-gwsistemas > thead > tr > th > img').hover(
                    function () {
                        var img = jQuery(this)[0];
                        jQuery(img.nextElementSibling).css('display', 'block');
                        jQuery(img.nextElementSibling).css('left', img.offsetLeft + 'px');
                    },
                    function () {
                        var img = jQuery(this)[0];
                        if (!jQuery(img.nextElementSibling).hasClass('active')) {
                            jQuery(img.nextElementSibling).css('display', 'none');
                        }
                    }
            );
            jQuery('.menu-span-dropdown-content').hover(
                    function () {
                        jQuery(this).css("display", "block");
                    },
                    function () {
                        if (!jQuery(this).hasClass('active')) {
                            jQuery(this).css("display", "none");
                        }
                    }
            );
            //Responsavel por manter os tamanhos das ths predefinidos
            var ths = jQuery('.tabela-gwsistemas thead th');
            var i = 0;
            while (ths[i]) {
                var w = jQuery(ths[i]).attr('largura');
                jQuery(ths[i]).css('min-width', w);
                jQuery(ths[i]).css('width', w);
                //                    jQuery(ths[i]).css('max-width',w);
                i++;
            }

            var ii = 0;
            var thsOrd = jQuery('.pode-setar-ordem');
            while (thsOrd[ii]) {
                jQuery(thsOrd[ii]).attr('ordem', ii + 1);
                ii++;
            }

            jQuery('.conteudo-colunas').hover(
                    function () {
                        jQuery(this).css('display', 'block');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).addClass('active');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).css('display', 'block');
                        jQuery('.add-col').css('background', '#CCC');
                    },
                    function () {
                        jQuery(this).css('display', 'none');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).css('display', 'none');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).removeClass('active');
                        jQuery('.add-col').css('background', '#FFF');
                    }
            );
            jQuery('.add-col').hover(
                    function (e) {
                        jQuery('.add-col').css('background', '#CCC');
                        var w = jQuery(this).parents('th').css('width');
                        w = w.replace('px', '');
                        var conteudoColunas = jQuery(this).parent().parent().parent().find('.conteudo-colunas');
                        jQuery(conteudoColunas).css('display', 'block');
                        jQuery(conteudoColunas).css('margin-left', parseInt(parseInt(w) + 155) + 'px');
                    },
                    function (e) {
                        if (!jQuery(this).parent().parent().hasClass('active')) {
                            jQuery(this).parent().parent().parent().find('.conteudo-colunas').css('display', 'none');
                        }
                        jQuery('.add-col').css('background', '#FFF');
                    }
            );
            /*
             * FUNCOES DA TABELA
             */

            jQuery('.conteudo-colunas .col-md-12').click(function (event) {
                event.preventDefault;
            });
            jQuery('.tabela-gwsistemas > thead > tr > th').hover(
                    function () {
                        jQuery(jQuery(this).find('img')).css('opacity', '1.0');
                    },
                    function () {
                        jQuery(jQuery(this).find('img')).css('opacity', '0.0');
                    }
            );
            jQuery('.tabela-gwsistemas > thead > tr > th > img').hover(
                    function () {
                        var img = jQuery(this)[0];
                        jQuery(img.nextElementSibling).css('display', 'block');
                        jQuery(img.nextElementSibling).css('left', img.offsetLeft + 'px');
                    },
                    function () {
                        var img = jQuery(this)[0];
                        if (!jQuery(img.nextElementSibling).hasClass('active')) {
                            jQuery(img.nextElementSibling).css('display', 'none');
                        }
                    }
            );
            jQuery('.menu-span-dropdown-content').hover(
                    function () {
                        jQuery(this).css("display", "block");
                    },
                    function () {
                        if (!jQuery(this).hasClass('active')) {
                            jQuery(this).css("display", "none");
                        }
                    }
            );
            //Responsavel por manter os tamanhos das ths predefinidos
            var ths = jQuery('.tabela-gwsistemas thead th');
            var i = 0;
            while (ths[i]) {
                var w = jQuery(ths[i]).attr('largura');
                jQuery(ths[i]).css('min-width', w);
                jQuery(ths[i]).css('width', w);
                //                    jQuery(ths[i]).css('max-width',w);
                i++;
            }

            var ii = 0;
            var thsOrd = jQuery('.pode-setar-ordem');
            while (thsOrd[ii]) {
                jQuery(thsOrd[ii]).attr('ordem', ii + 1);
                ii++;
            }

            jQuery('.conteudo-colunas').hover(
                    function () {
                        jQuery(this).css('display', 'block');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).addClass('active');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).css('display', 'block');
                        jQuery('.add-col').css('background', '#CCC');
                    },
                    function () {
                        jQuery(this).css('display', 'none');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).css('display', 'none');
                        jQuery(jQuery(this).parent().find('.menu-span-dropdown-content')).removeClass('active');
                        jQuery('.add-col').css('background', '#FFF');
                    }
            );
            jQuery('.add-col').hover(
                    function (e) {
                        jQuery('.add-col').css('background', '#CCC');
                        var w = jQuery(this).parents('th').css('width');
                        w = w.replace('px', '');
                        var conteudoColunas = jQuery(this).parent().parent().parent().find('.conteudo-colunas');
                        jQuery(conteudoColunas).css('display', 'block');
                        jQuery(conteudoColunas).css('margin-left', parseInt(parseInt(w) + 155) + 'px');
                    },
                    function (e) {
                        if (!jQuery(this).parent().parent().hasClass('active')) {
                            jQuery(this).parent().parent().parent().find('.conteudo-colunas').css('display', 'none');
                        }
                        jQuery('.add-col').css('background', '#FFF');
                    }
            );
            jQuery('#tabela-gwsistemas').tabelaGwDraggable({
                redimensionavel: true,
                draggable: true,
                ordenacao: true,
                notDraggableClass: 'nao',
                notResizableClass: 'nao',
                notOrderClass: 'nao',
                armazenarValoresWidth: true,
                callBackResize: monitorarPreferenciaUsuario,
                callBackDraggable: monitorarPreferenciaUsuario,
                //Classe responsavel por liberar o setar ordem das colunas que tem a mesma
                setaOrdemClass: 'pode-setar-ordem'

            });
            jQuery(".tb-topo-colunas tr th").hover(
                    function () {
                        var menu = jQuery(this).children()[1];
                        if (menu != null && menu != undefined) {
                            jQuery(menu).css("display", "block");
                        }
                    }, function () {
                var menu = jQuery(this).children()[1];
                if (menu != null && menu != undefined) {
                    jQuery(menu).css("display", "none");
                }
            }
            );
            var c = 0;
            while (jQuery("[menu-coleta]")[c] !== undefined) {
                var index = jQuery(jQuery("[menu-coleta]")[c]).attr('menu-coleta');
                jQuery(jQuery("[menu-coleta]")[c]).html(jQuery(jQuery("[menu-coleta]")[c]).html() + jQuery("[name=hi_row_num_manifesto_" + index + "]").val());
                c++;
            }

            jQuery('.img-menu-coleta').click(function () {
                jQuery('.container-menu-coleta').hide();
                jQuery(this).parent().find('nav').fadeToggle("fast");
            });
        }, 1);


        setTimeout(function () {
            atualizarValoresTotais();
        }, 350);
    });

    function atualizarValoresTotais() {

        let volumes = 0.0;
        let cubagem = 0.0;
        let pesoReal = 0.0;
        let pesoTaxado = 0.0;
        let valorMercadoria = 0.0;
        let rsKG = 0.0;


        let qtdCif = 0;
        let qtdFob = 0;
        let qtdTerceiro = 0;
        let qtdRsKG = 0;

        let valorFreteFob = 0.0;
        let valorFreteCif = 0.0;
        let valorFreteTerceiro = 0.0;
        let valorRsKG = 0.0;

        let valorRsKgCif = 0.0;
        let valorRsKgFob = 0.0;
        let valorRsKgTerceiro = 0.0;
        let qtdRsKgCif = 0;
        let qtdRsKgFob = 0;
        let qtdRsKgTerceiro = 0;
        
        console.log('${valoresJson}');
        
        let c = 0;
        while (jQuery.parseJSON('${valoresJson}')[c]) {
            var json = jQuery.parseJSON('${valoresJson}')[c];
            let valor_notas_fiscais = json.valor_notas_fiscais;
            let volume_notas_fiscais = json.volume_notas_fiscais;
            let cubagem = json.cubagem;
            let peso_notas_fiscais = json.peso_notas_fiscais;
            let peso_taxado = json.peso_taxado;
            let tipo_pagto = json.tipo_pagto;
            let preco_kilo = json.preco_kilo;
            let valor_frete = json.valor_frete;
            let qtd = json.qtd;

            volumes += Number(volume_notas_fiscais);
            cubagem += Number(cubagem);
            pesoReal += Number(peso_notas_fiscais);
            pesoTaxado += Number(peso_taxado);
            valorMercadoria += Number(valor_notas_fiscais);

            rsKG += Number(preco_kilo);

            switch (tipo_pagto) {
                case 'FOB':
                    valorFreteFob += Number(valor_frete);
                    qtdFob = qtd;
                    valorRsKgFob += Number(preco_kilo);
                    break;
                case 'CIF':
                    valorFreteCif += Number(valor_frete);
                    qtdCif = qtd;
                    valorRsKgCif += Number(preco_kilo);
                    break;
                case 'Terceiro':
                    valorFreteTerceiro += Number(valor_frete);
                    qtdTerceiro = qtd;
                    valorRsKgTerceiro += Number(preco_kilo);
                    break;
            }

            c++;
        }

        jQuery('[volumes]').text(colocarVirgula(volumes, 4));
        jQuery('[cubagem]').text(colocarVirgula(cubagem, 4));
        jQuery('[pesoReal]').text(colocarVirgula(pesoReal, 3));
        jQuery('[pesoTaxado]').text(colocarVirgula(pesoTaxado, 3));
        jQuery('[valorMercadoria]').text(colocarVirgula(valorMercadoria, 2));
        jQuery('[rsKG]').text(colocarVirgula(isNaN(rsKG / parseInt(qtdFob + qtdCif + qtdTerceiro)) ? 0 : rsKG / parseInt(qtdFob + qtdCif + qtdTerceiro)));

        jQuery('[qtdCif]').text(qtdCif);
        jQuery('[qtdFob]').text(qtdFob);
        jQuery('[qtdTerceiro]').text(qtdTerceiro);
        

        jQuery('[valorrskgcif]').text(colocarVirgula((isNaN(valorRsKgCif / qtdCif) ? 0 : valorRsKgCif / qtdCif), 2));
        jQuery('[valorrskgfob]').text(colocarVirgula((isNaN(valorRsKgFob / qtdFob) ? 0 : valorRsKgFob / qtdFob), 2));
        jQuery('[valorrskgterceiro]').text(colocarVirgula((isNaN(valorRsKgTerceiro / qtdTerceiro) ? 0 : valorRsKgTerceiro / qtdTerceiro), 2));

        jQuery('[valorFreteCif]').text(colocarVirgula(valorFreteCif, 2));
        jQuery('[valorFreteFob]').text(colocarVirgula(valorFreteFob, 2));
        jQuery('[valorFreteTerceiro]').text(colocarVirgula(valorFreteTerceiro, 2));

        jQuery('[valorRsKG]').text(colocarVirgula(valorRsKG, 2));

        setTimeout(function () {
            changeValueGraficos(valorFreteCif, valorFreteFob, valorFreteTerceiro);
        }, 2000);

    }

    function recalcularTotais() {
        let volumes = 0.0;
        let cubagem = 0.0;
        let pesoReal = 0.0;
        let pesoTaxado = 0.0;
        let valorMercadoria = 0.0;

        let qtdCif = 0;
        let qtdFob = 0;
        let qtdTerceiro = 0;

        let valorFreteFob = 0.0;
        let valorFreteCif = 0.0;
        let valorFreteTerceiro = 0.0;

        let i = 0;
        while (jQuery('[name*=nCheck]:checked')[i]) {
            var pos = jQuery('[name*=nCheck]:checked')[i].value;
            volumes += Number(jQuery('#hi_row_volume_notas_fiscais_' + pos).val());
            cubagem += Number(jQuery('#hi_row_cubagem_' + pos).val());
            pesoReal += Number(jQuery('#hi_row_peso_notas_fiscais_' + pos).val());
            pesoTaxado += Number(jQuery('#hi_row_peso_taxado_' + pos).val());
            valorMercadoria += Number(jQuery('#hi_row_valor_notas_fiscais_' + pos).val());

            switch (jQuery('#hi_row_tipo_pagto_' + i).val()) {
                case 'FOB':
                    valorFreteFob += Number(jQuery('#hi_row_valor_frete_' + i).val());
                    qtdFob++;
                    break;
                case 'CIF':
                    valorFreteCif += Number(jQuery('#hi_row_valor_frete_' + i).val());
                    qtdCif++;
                    break;
                case 'Terceiro':
                    valorFreteTerceiro += Number(jQuery('#hi_row_valor_frete_' + i).val());
                    qtdTerceiro++;
                    break;
            }

            i++;
        }

        jQuery('[volumes]').text(colocarVirgula(volumes, 4));
        jQuery('[cubagem]').text(colocarVirgula(cubagem, 4));
        jQuery('[pesoReal]').text(colocarVirgula(pesoReal, 3));
        jQuery('[pesoTaxado]').text(colocarVirgula(pesoTaxado, 3));
        jQuery('[valorMercadoria]').text(colocarVirgula(valorMercadoria, 2));

        jQuery('[qtdCif]').text(qtdCif);
        jQuery('[qtdFob]').text(qtdFob);
        jQuery('[qtdTerceiro]').text(qtdTerceiro);

        jQuery('[valorFreteCif]').text(colocarVirgula(valorFreteCif, 2));
        jQuery('[valorFreteFob]').text(colocarVirgula(valorFreteFob, 2));
        jQuery('[valorFreteTerceiro]').text(colocarVirgula(valorFreteTerceiro, 2));

        changeValueGraficos(valorFreteCif, valorFreteFob, valorFreteTerceiro);

    }

    function colocarVirgula(number, fixed) {
        if (fixed == undefined) {
            fixed = '2';
        }
        number = String(parseFloat(number).toFixed(fixed)).replace(/\./, ',');
        return number;
    }


    function verifyPesoKg() {
        setTimeout(function () {
            let v = 1;
            while (jQuery('#hi_row_valor_kg_ideal_' + v)[0]) {
                var kgIdealFilial = jQuery('#hi_row_valor_kg_ideal_' + v).val();
                var kgIdealCte = jQuery('#hi_row_preco_kilo_' + v).val();
                var colunaPreco = jQuery('[nome=PRECO_KILO]').html();
                if (colunaPreco != undefined && jQuery('[nome=PRECO_KILO]').is(":visible") == true) {
                    if (kgIdealFilial > 0) {
                        if (parseFloat(kgIdealCte) < parseFloat(kgIdealFilial)) {
                            //jQuery('#hi_row_valor_kg_ideal_' + v).parents('tr').css('background', 'red');
                            jQuery('#hi_row_valor_kg_ideal_' + v).parents('tr').find('td').find('label').css('color', 'red');
                            jQuery('#hi_row_valor_kg_ideal_' + v).parents('tr').find('td').css('color', 'red');
                        }
                    }
                } else {
                    jQuery('#hi_row_valor_kg_ideal_' + v).parents('tr').find('td').find('label').css('color', 'black');
                }
                v++;
            }
        }, 2000);
    }

</script>
<script defer src="./gwTrans/consultas/js/funcoes_grid_mercadoria_deposito.js"></script>

