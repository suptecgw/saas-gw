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
                th = jQuery('<th largura="30px" class="nao nao-ordenar">');
                tr.append(th);
                th = jQuery('<th largura="30px" class="nao nao-ordenar">');
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
            div = jQuery('<div class="topo-container-menu" menu-coleta="${rowStatus.count}">').html('N° Coleta - ');
            nav.append(div);
            div = jQuery('<div class="corpo-container-menu">');
            ul = jQuery('<ul>');
            li = jQuery('<li onclick="checkSession(function () {visualizarDocumentos(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/anexar.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Anexar');
            li.append(span);
            ul.append(li);
            li = jQuery('<li onclick="checkSession(function () {abrirImportacao(${rowStatus.count}, 0);}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/barcode-carregamento.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Conferencia no carregamento.');
            li.append(span);
            ul.append(li);
            li = jQuery('<li onclick="checkSession(function () {abrirImportacao(${rowStatus.count}, 1);}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/barcode-descarregamento.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Conferencia no descarregamento.');
            li.append(span);
            ul.append(li);
            li = jQuery('<li onclick="visualizarCteNfe(this,${rowStatus.count});">');
            img = jQuery('<img src="${homePath}/assets/img/icones/visualizar_documentos.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Visualizar CT-e(s) / NFS-e(s)');
            li.append(span);    
            ul.append(li);
            li = jQuery('<li onclick="checkSession(function () {enviarEmailRepresentante(${rowStatus.count});}, false);">');
            // Status de envio do email
            var enviado = tr.find('#hi_row_is_enviado_email_representante_${rowStatus.count}').val();
            if (enviado === 'Sim') {
                img = jQuery('<img src="${homePath}/img/email_ok.png" width="20px">');
            } else {
                img = jQuery('<img src="${homePath}/assets/img/enviar-email.png" width="20px">');
            }
            li.append(img);
            span = jQuery('<span>').html('Enviar para o representante');
            li.append(span);
            ul.append(li);
            li = jQuery('<li onclick="checkSession(function () {popColeta(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/print.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Imprimir');
            li.append(span);
            ul.append(li);
            li = jQuery('<li onclick="checkSession(function () {excluirColetas(${rowStatus.count});}, false);">');
            img = jQuery('<img src="${homePath}/assets/img/icones/excluir.png" width="20px">');
            li.append(img);
            span = jQuery('<span>').html('Excluir');
            li.append(span);
            ul.append(li);
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
            lb = jQuery('<label title="${cg:removeQuebraLinha(colResult.label)}: ${cg:removeQuebraLinha(colResult)}" data-url-cadastro="${colResult.urlCadastro}" data-indice="${rowStatus.count}">${cg:formatCampoConsulta(colResult)}</label>');
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
                jQuery(jQuery("[menu-coleta]")[c]).html(jQuery(jQuery("[menu-coleta]")[c]).html() + jQuery("[name=hi_row_numero_" + index + "]").val());
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

    });



</script>
<script defer src="${homePath}/gwTrans/consultas/js/funcoes_grid_coleta.js"></script>

