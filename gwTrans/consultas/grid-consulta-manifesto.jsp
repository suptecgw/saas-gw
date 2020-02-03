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
            <input type="text" size="2" value="${consulta.paginacao.paginaAtual}" onkeyup="verificaCaracterePagina(this,${consulta.paginacao.paginas+1});" onchange="verificaPagina(this,${consulta.paginacao.paginas+1});" onkeypress="paginaEnter(event, this.value);" class="pagination-num">
            <!--<input type="text" size="2"  class="pagination-num">-->
            <span>de ${consulta.paginacao.paginas}</span>
            <a href="javascript:${consulta.paginacao.paginaAtual > 1 ? 'anterior();':''};" class="${consulta.paginacao.paginaAtual > 1 ? 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain' : 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled'}" group="" id="" style="margin-right: -13px;">
                <span class="l-btn-left l-btn-icon-left">
                    <span class="l-btn-text l-btn-empty">&nbsp;</span>
                    <span class="l-btn-icon pagination-prev">&nbsp;</span>
                </span>
            </a>
            <a href="javascript:${consulta.paginacao.paginas >= 1 && consulta.paginacao.paginaAtual < consulta.paginacao.paginas ? 'proxima();' : ''};" class="${consulta.paginacao.paginas >= 1 && consulta.paginacao.paginaAtual < consulta.paginacao.paginas ? 'l-btn l-btn-small l-btn-plain l-btn l-btn-plain' : 'l-btn l-btn-small l-btn-plain l-btn-disabled l-btn-plain-disabled'}" style="z-index: 999999;" group="" id="">
                <span class="l-btn-left l-btn-icon-left">
                    <span class="l-btn-text l-btn-empty">&nbsp;</span>
                    <span class="l-btn-icon pagination-next">&nbsp;</span>
                </span>
            </a>
        </div>
    </div>
    <div class="amount-items">
        Quantidade de resultados <label> : </label> ${consulta.paginacao.qtdResultados}
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
            input = jQuery('<input type="checkbox" id="nCheck${rowStatus.count}" name="nCheck${rowStatus.count}" value="${rowStatus.count}" onclick="trChecked(this,${rowStatus.count})"/>');
            center.append(input);
            td.append(center);
        <c:forEach var="col" items="${row.columns}" varStatus="colStatus" >
            input = jQuery('<input type="hidden"  name="hi_row_${col.nome}_${rowStatus.count}" id="hi_row_${col.nome}_${rowStatus.count}" value="${cg:removeQuebraLinha(col)}" />');
            td.append(input);
        </c:forEach>
            tr.append(td);
            td = jQuery('<td>');
            center = jQuery('<center>');
            img = jQuery('<img class="img-menu-coleta" src="${homePath}/img/th-menu-escuro.png">');
            center.append(img);
            nav = jQuery('<nav class="container-menu-coleta">');
            div = jQuery('<div class="topo-container-menu" menu-coleta="${rowStatus.count}">').html('Nº Manifesto - ');
            nav.append(div);
            div = jQuery('<div class="corpo-container-menu">');
            ul = jQuery('<ul>');

            li = jQuery('<li onclick="checkSession(function () {editar(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/img/edit.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Editar');
            li.append(span);
            ul.append(li);

            li = jQuery('<li onclick="checkSession(function () {excluir(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/excluir.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Excluir');
            li.append(span);
            ul.append(li);

            li = jQuery('<li onclick="checkSession(function () {confirmUnicoRel(${rowStatus.count}); }, false); ">');
            img = jQuery('<img src="${homePath}/assets/img/icones/print.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Imprimir');
            li.append(span);
            ul.append(li);

            li = jQuery('<li onclick="checkSession(function () {enviarEmailManifestoRepresentante(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/enviar-email.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Enviar para o representante');
            li.append(span);
            ul.append(li);

            li = jQuery('<li onclick="checkSession(function () {rotasNoMaps(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/mapa.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Rotas no Mapa');
            li.append(span);
            ul.append(li);

            li = jQuery('<li id="liMobile${rowStatus.count}" onclick="checkSession(function () {sincronizarGwMobile(${rowStatus.count});}, false);">');
            img = jQuery('<img id="telefone" src="${homePath}/img/smartphone.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Sincronizar para o GwMobile');
            li.append(span);
            ul.append(li);

            li = jQuery('<li onclick="checkSession(function () {abrirImportacao(${rowStatus.count}, 1);}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/barcode-descarregamento.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Importação de conferência (Saída)');
            li.append(span);
            ul.append(li);

            li = jQuery('<li onclick="checkSession(function () {abrirImportacao(${rowStatus.count}, 0);}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/barcode-carregamento.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Importação de conferência (Entrada)');
            li.append(span);
            ul.append(li);

            <c:if test="${tipoUtiRiscoGS != 'N'.charAt(0)}">
                <c:choose>
                    <c:when test="${idTipoPGR eq 2}">
                        li = jQuery('<li onclick="checkSession(function () {enviarGerenciadorRisco(${rowStatus.count}, \'G\');}, false);">');
                        img = jQuery('<img src="${homePath}/assets/img/icones/logo-gdservice.png" width="20px">');
                        li.append(img);
                        span = jQuery('<span>').html('Enviar Manifesto para a Golden Service');
                        li.append(span);
                        ul.append(li);
                    </c:when>
                    <c:when test="${idTipoPGR eq 4}">
                        li = jQuery('<li onclick="checkSession(function () {enviarGerenciadorRisco(${rowStatus.count}, \'U\');}, false);">');
                        img = jQuery('<img src="${homePath}/assets/img/parceiros/logo_upper.png" width="20px">');
                        li.append(img);
                        span = jQuery('<span>').html('Enviar Manifesto para a Upper');
                        li.append(span);
                        ul.append(li);
                    </c:when>
                </c:choose>
            </c:if>

            li = jQuery('<li onclick="checkSession(function () {editarCartaFrete(${rowStatus.count}); }, false); ">');
            img = jQuery('<img src="${homePath}/assets/img/icones/icon_contrato.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Visualizar Contrato de frete');
            li.append(span);
            ul.append(li);
            
            // desagrupar manifesto.
            li = jQuery('<li id="agrupar${rowStatus.count}" onclick="checkSession(function(){ desagruparManifestoConfirm(${rowStatus.count});}, false); ">');
            img = jQuery('<img src="${homePath}/assets/img/ungroup.png" width="20px">');
            li.append(img);
            span = jQuery('<span class="desagrupar">').html('Desagrupar do manifesto ');
            li.append(span);
            ul.append(li);

            if (jQuery(tr).find("#hi_row_criado_por_id_${rowStatus.count}").val() == "8888") {
                if (jQuery(tr).find("#hi_row_is_desativado_gwi_${rowStatus.count}").val() == "false") {
                    li = jQuery('<li onclick="checkSession(function () {chamarDesativarGWi(${rowStatus.count}); }, false); ">');
                    img = jQuery('<img src="${homePath}/assets/img/icones/gwi-ativo.png" width="20px">');
                    li.append(img);
                    span = jQuery('<span>').html('Desativar Manifesto do GW-i');
                    li.append(span);
                    ul.append(li);
                } else {
                    li = jQuery('<li>').css('cursor', 'default');
                    img = jQuery('<img src="${homePath}/assets/img/icones/gwi-desativado.png" width="20px">');
                    li.append(img);
                    span = jQuery('<span>').html('Manifesto desativado do GW-i');
                    li.append(span);
                    ul.append(li);
                }
            }

            div.append(ul);
            nav.append(div);
            center.append(nav);
            td.append(center);
            tr.append(td);
            td = jQuery('<td>');
            center = jQuery('<center>');
            img = jQuery('<img width="15px" height="15px" title="Editar" style="cursor: pointer;" onclick="checkSession(function () {editar(${rowStatus.count});}, false);" src="img/edit.png">');
            center.append(img);
            td.append(center);
            tr.append(td);
        <c:forEach var="col" items="${tela.columns}" varStatus="colStatus" >
            <c:set var="indice" value="${cg:indexOf(row.columns, col.nome)}" />
            <c:set var="colResult" value="${row.columns[indice]}" />
            <c:if test="${indice > -1}">
            td = jQuery('<td>');
            lb = jQuery('<label title="${colResult.label}: ${colResult}" data-url-cadastro="${colResult.urlCadastro}" data-indice="${rowStatus.count}">${cg:formatCampoConsulta(colResult)}</label>');
            td.append(lb);
            tr.append(td);
            </c:if>
        </c:forEach>
            tbody.append(tr);
    </c:forEach>
            table.append(tbody);
            //Adicionando a tabela no pane
            jQuery('#paneConsulta').append(table);
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
                    function (i) {
                        var img = jQuery(this)[0];

                        var lugarHorizontal = i.clientX;
                        var tamanhoTela = jQuery(window).width();
                        var tamanhoMenu = jQuery(img.nextElementSibling).width();

                        if (tamanhoTela - lugarHorizontal > tamanhoMenu) {
                            jQuery(img.nextElementSibling).css('display', 'block');
                            jQuery(img.nextElementSibling).css('top', '17px');
                            jQuery(img.nextElementSibling).css('left', img.offsetLeft + 'px');
                        } else {
                            jQuery(img.nextElementSibling).css('display', 'block');
                            jQuery(img.nextElementSibling).css('top', '17px');
                            jQuery(img.nextElementSibling).css('left', img.offsetLeft - 157 + 'px');
                        }
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
                        var imagem = jQuery('.tabela-gwsistemas > thead > tr > th > img');
                        var tamanhoSubMenu = jQuery(imagem.nextElementSibling).width();

                        jQuery('.add-col').css('background', '#CCC');
                        var w = jQuery(this).parents('th').width();
                        var conteudoColunas = jQuery(this).parent().parent().parent().find('.conteudo-colunas');

                        var lugarHorizontal = e.clientX + 150;
                        var tamanhoTela = jQuery(window).width();
                        var tamanhoMenu = conteudoColunas.width();

                        if (tamanhoTela - lugarHorizontal > tamanhoMenu) {
                            jQuery(conteudoColunas).css('display', 'block');
                            jQuery(conteudoColunas).css('top', '18px');
                            jQuery(conteudoColunas).css('margin-left', w + 155 + 'px');
                        } else {
                            if (tamanhoTela - lugarHorizontal > tamanhoSubMenu) {
                                jQuery(conteudoColunas).css('display', 'block');
                                jQuery(conteudoColunas).css('top', '18px');
                                jQuery(conteudoColunas).css('margin-left', w - 180 + 'px');
                            } else {
                                jQuery(conteudoColunas).css('display', 'block');
                                jQuery(conteudoColunas).css('top', '18px');
                                jQuery(conteudoColunas).css('margin-left', w - 345 + 'px');
                            }
                        }
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
                    function (i) {
                        var img = jQuery(this)[0];

                        var lugarHorizontal = i.clientX;
                        var tamanhoTela = jQuery(window).width();
                        var tamanhoMenu = jQuery(img.nextElementSibling).width();

                        if (tamanhoTela - lugarHorizontal > tamanhoMenu) {
                            jQuery(img.nextElementSibling).css('display', 'block');
                            jQuery(img.nextElementSibling).css('top', '17px');
                            jQuery(img.nextElementSibling).css('left', img.offsetLeft + 'px');
                        } else {
                            jQuery(img.nextElementSibling).css('display', 'block');
                            jQuery(img.nextElementSibling).css('top', '17px');
                            jQuery(img.nextElementSibling).css('left', img.offsetLeft - 157 + 'px');
                        }
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
                        var imagem = jQuery('.tabela-gwsistemas > thead > tr > th > img');
                        var tamanhoSubMenu = jQuery(imagem.nextElementSibling).width();

                        jQuery('.add-col').css('background', '#CCC');
                        var w = jQuery(this).parents('th').width();
                        var conteudoColunas = jQuery(this).parent().parent().parent().find('.conteudo-colunas');

                        var lugarHorizontal = e.clientX + 150;
                        var tamanhoTela = jQuery(window).width();
                        var tamanhoMenu = conteudoColunas.width();

                        if (tamanhoTela - lugarHorizontal > tamanhoMenu) {
                            jQuery(conteudoColunas).css('display', 'block');
                            jQuery(conteudoColunas).css('top', '18px');
                            jQuery(conteudoColunas).css('margin-left', w + 155 + 'px');
                        } else {
                            if (tamanhoTela - lugarHorizontal > tamanhoSubMenu) {
                                jQuery(conteudoColunas).css('display', 'block');
                                jQuery(conteudoColunas).css('top', '18px');
                                jQuery(conteudoColunas).css('margin-left', w - 180 + 'px');
                            } else {
                                jQuery(conteudoColunas).css('display', 'block');
                                jQuery(conteudoColunas).css('top', '18px');
                                jQuery(conteudoColunas).css('margin-left', w - 345 + 'px');
                            }
                        }
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
                var sincronizado = jQuery("[name=hi_row_is_sincronizado_mobile_" + index + "]").val();
                var reenvia = jQuery("[name=hi_row_pode_reenviar_" + index + "]").val();
                if (sincronizado == 'Sim' && reenvia == 'false') {
                    jQuery('#liMobile' + index + '').addClass("disabled");
                    jQuery('#liMobile' + index + '').attr('onclick', "");
                    var imagem = jQuery('#liMobile' + index + ' img');
                    imagem.attr('src', "${homePath}/img/smart3.png");
                    imagem.attr('width', "17px;");
                    imagem.attr('height', "23px;");
                }
                jQuery(jQuery("[menu-coleta]")[c]).html(jQuery(jQuery("[menu-coleta]")[c]).html() + jQuery("[name=hi_row_num_manifesto_" + index + "]").val());
                jQuery(jQuery(".desagrupar")[c]).html("Desagrupar do manifesto " + jQuery("[name=hi_row_numero_manifesto_agrupado_" + index + "]").val());
                c++;
            }

            jQuery('.img-menu-coleta').click(function (e) {
                jQuery('.img-menu-coleta').offset().top;
                jQuery('.container-menu-coleta').hide();
                var trPositionTop = $(this).parents('tr').position().top;
                var nav = jQuery(this).parent().find('nav');
                
                nav.css('top', (e.pageY - 57));

                if (nav.height() > (window.heightDoc - (trPositionTop + 80))) {
                    nav.css('margin-top', '-338px');
                }
                nav.fadeToggle("fast");
            });
        }, 1);
            
            var ag = 0;
            while (jQuery("[name*='hi_row_numero_manifesto_agrupado_']")[ag] !== undefined) {
                if (jQuery("#hi_row_numero_manifesto_agrupado_"+(ag+1)).val() === undefined || jQuery("#hi_row_numero_manifesto_agrupado_"+(ag+1)).val() === "") {
                    jQuery("#agrupar"+(ag+1)).hide();
                }
                ag++;
            }
    });</script>
<script defer src="${homePath}/gwTrans/consultas/js/funcoes_grid_coleta.js"></script>

