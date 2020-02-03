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
<link href="${homePath}/css/style-grid-default.css" rel="stylesheet" type="text/css"/>
<link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
<c:if test="${lista != null && lista.rows != null}">
    <div class="panel datagrid datagrid-wrap panel-body panel-body-noheader" id="paneConsulta" name="paneConsulta">
        <script>
            var heightDoc = jQuery(window).height();
            jQuery("#paneConsulta").css('height', heightDoc - 250);
            jQuery(".heightDoc").css('height', heightDoc);
            jQuery(".contentMap").css('height', heightDoc - 200);

            jQuery(document).ready(function () {

                jQuery('.conteudo-colunas .col-md-12').click(function (event) {
                    event.preventDefault;
                });

                jQuery('.tabela-gwsistemas > thead > tr > th').hover(
                        function () {
                            jQuery($(this).find('img')).css('opacity', '1.0');
                        },
                        function () {
                            jQuery($(this).find('img')).css('opacity', '0.0');
                        }
                );

                jQuery('.tabela-gwsistemas > thead > tr > th > img').hover(
                        function (i) {
                            var img = $(this)[0];

                            var lugarHorizontal = i.clientX;
                            var tamanhoTela = jQuery(window).width();
                            var tamanhoMenu = jQuery(img.nextElementSibling).width();
                            var menu = jQuery(img.nextElementSibling);

                            if (tamanhoTela - lugarHorizontal > tamanhoMenu) {
                                jQuery(img.nextElementSibling).css('display', 'block');
                                jQuery(img.nextElementSibling).css('top', '17px');
                                jQuery(img.nextElementSibling).css('left', img.offsetLeft + 'px');
                            } else {
                                jQuery(img.nextElementSibling).css('display', 'block');
                                jQuery(img.nextElementSibling).css('top', '17px');
                                jQuery(img.nextElementSibling).css('left', img.offsetLeft - 160 + 'px');
                            }
                        },
                        function () {
                            var img = $(this)[0];
                            if (!jQuery(img.nextElementSibling).hasClass('active')) {
                                jQuery(img.nextElementSibling).css('display', 'none');
                            }
                        }
                );

                jQuery('.menu-span-dropdown-content').hover(
                        function () {
                            $(this).css("display", "block");
                        },
                        function () {
                            if (!jQuery(this).hasClass('active')) {
                                $(this).css("display", "none");
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
            });

            function ocultarColumn(element) {
                var index = jQuery(jQuery(element).parents('th')).index() + 1;
                jQuery('.tabela-gwsistemas').children().find('> tr > th:nth-child(' + index + ')').attr('oculta', 'true');
                jQuery('.tabela-gwsistemas').children().find('> tr > td:nth-child(' + index + ')').hide('show');
                jQuery('.tabela-gwsistemas').children().find('> tr > th:nth-child(' + index + ')').hide('show');
            }

            function ordenar(elemento) {
                jQuery(jQuery(elemento).parents('th')[0]).trigger('click');
            }

            function redefinirColunas() {
                jQuery.ajax({
                    url: 'ConsultaControlador',
                    type: 'POST',
                    async: false,
                    data: {
                        acao: 'redefinirColunas',
                        codigoTela: '${param.codTela}'
                    },
                    success: function (data, textStatus, jqXHR) {
                        location.reload();
                    },
                    error: function (jqXHR, textStatus, errorThrown) {
                        chamarAlert('Ocorreu um erro ao tentar redefinir as colunas.');
                    }
                });
            }

        </script>

        <style>
            .conteudo-colunas{
                display: none;
                background: #FFF;
                width: 170px;
                top: 50px;
                cursor: pointer;
                /*margin-left: 95px;*/
                position: absolute;
                overflow: auto;
                box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
                padding: 2px;
                text-align: left;
                cursor: pointer;
                font-size: 11px;
                color:#000;
                z-index: 99999999;
                border-radius: 5px 5px 5px 5px;
                /*margin-left: 400px;*/
                overflow: hidden;
                height: auto;
            }

            .conteudo-colunas .col-md-12{
                height: auto;
                padding: 0;
                margin: 0;
                border: 1px dotted #999;
                margin-bottom: 3px;
                background: rgba(255,255,255,0.8);
                border-radius: 3px;
                padding-bottom: 5px;
                padding-top: 5px;
            }

            .conteudo-colunas .col-md-12:hover{
                background: #ccc;
            }

            .conteudo-colunas .col-md-12 img{
                float: left;
                margin-left: 10px;
            }

            .conteudo-colunas label{
                cursor: pointer;
                margin-left: 5px;
            }
        </style>
        <table cellspacing="0" class="tabela-gwsistemas"  id="tabela-gwsistemas">
            <thead>
                <c:if test="${tela != null && tela.columns != null}">
                    <tr>
                        <th largura="30px" class="nao">
                            <input type="checkbox" onclick="marcarTodos(this);">
                            <c:forEach var="col" items="${tela.columns}" varStatus="colStatus" >
                                <input type="hidden"  name="hi_row_${col.nome}" id="hi_row_${col.nome}"  />
                            </c:forEach>
                        </th>
                        <th largura="30px" class="nao">
                        </th>
                        <c:forEach var="col" items="${tela.columns}" varStatus="colTelaStatus" >
                            <th id="${colTelaStatus.count}" style="" largura="${col.largura != null && col.largura != "" ? col.largura : col.colXml.width}" class="${col.fixo ? 'nao' : ''} pode-setar-ordem" nome="${fn:toUpperCase(col.colXml.name)}">
                                <!-- é de extrema importancia essa classe ( nome-coluna ) para o funcionamento correto no JS | Autor: Mateus -->
                                <label class="nome-coluna" >${col.colXml.label}</label>
                                <img src="img/th-menu.png">
                                <div class="menu-span-dropdown-content" onclick="">
                                    <ul>
                                        <li class="ad-rm-col add-col">
                                            <a><div><label>Adicionar Coluna</label></div></a>
                                        </li>
                                        <c:if test="${!col.fixo}">
                                            <li class="ad-rm-col" onclick="ocultarColumn(this);">
                                                <a><div><label>Ocultar Coluna</label></div></a>
                                            </li>
                                        </c:if>
                                        <li class="ad-rm-col" onclick="ordenar(this);">
                                            <a><div><label>Ordem Crescente</label></div></a>
                                        </li>
                                        <li class="ad-rm-col" onclick="ordenar(this);">
                                            <a><div><label>Ordem Decrescente</label></div></a>
                                        </li>
                                        <li class="ad-rm-col" onclick="chamarConfirm('Tem certeza que deseja redefinir todas as colunas para o padrão original do sistema?', 'redefinirColunas()', null);">
                                            <a><div><label>Redefinir Colunas</label></div></a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="conteudo-colunas">
                                    <c:set var="idTh" value="${colTelaStatus.count + 1}" />
                                    <c:forEach var="column" items="${tela.targetXml.column}" varStatus="rowStatus" >
                                        <c:set var="podeAdicionar" value="true" />
                                        <c:forEach var="col" items="${tela.columns}" varStatus="colTelaStatus" >
                                            <c:if test="${col.nome == column.name}">
                                                <c:set var="podeAdicionar" value="false" />
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${column.visivel && podeAdicionar}">
                                            <div class="col-md-12" onclick="adicionarColuna('${column.name}', '${column.label}', this);
                                                    event.preventDefault();
                                                    event.stopPropagation();">
                                                <img src="${homePath}/assets/img/plus_col.png">
                                                <label name="${column.name}">${column.label}</label>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </th>
                        </c:forEach>
                    </tr>
                </c:if>
            </thead>
            <tbody>
                <c:forEach var="row" items="${lista.rows}" varStatus="rowStatus" >
                    <tr>
                        <td>
                            <input type="checkbox" id="nCheck${rowStatus.count}" name="nCheck${rowStatus.count}" value="${rowStatus.count}" onclick="trChecked(this,${rowStatus.count})"/>
                            <c:forEach var="col" items="${row.columns}" varStatus="colStatus" >
                                <input type="hidden"  name="hi_row_${col.nome}_${rowStatus.count}" id="hi_row_${col.nome}_${rowStatus.count}" value="${cg:removeQuebraLinha(col)}" />
                            </c:forEach>
                        </td>
                        <td class="imagemEditar" >
                        </td>
                        <c:forEach var="col" items="${tela.columns}" varStatus="colStatus" >
                            <c:set var="indice" value="${cg:indexOf(row.columns, col.nome)}" />
                            <c:set var="colResult" value="${row.columns[indice]}" />
                            <c:if test="${indice > -1}">
                                <td style="">
                                    <label title="${colResult.label}: ${colResult}" style="">${cg:formatCampoConsulta(colResult)}</label>
                                </td>
                            </c:if>
                        </c:forEach>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    <div class="datagrid-pager pagination" style="margin-right: 25px;">
        <div align="right" style="float: right;">
            <span>Página </span>
            <input type="text" size="2" value="${consulta.paginacao.paginaAtual}" onkeyup="verificaCaracterePagina( this,${consulta.paginacao.paginas+1});" onchange="verificaPagina(this,${consulta.paginacao.paginas+1});" onkeypress="paginaEnter(event, this.value);" class="pagination-num">
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
</c:if>
<script type="text/javascript">
    var resultList = `${cg:resultListToJson(lista)}`;
    function getColumnValue(nome) {
        var valorRetorno = '';
        var listaJson = jQuery.parseJSON(resultList);
        var index = 0;
        while (listaJson.resultList.rows[0].resultRow[index]) {
            var i = 0;
            while (listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i] != undefined) {
                if (listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i].nome == nome) {
                    if (listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i].valor) {
                        valorRetorno += listaJson.resultList.rows[0].resultRow[index].columns[0].resultCol[i].valor.$ + '!#!';
                    }
                }
                i++;
            }
            index++;
        }

        return valorRetorno;
    }

    function adicionarColuna(nomeColuna, labelColuna, elemento) {
        var posicaoColuna = jQuery(jQuery(elemento).parents()[1])[0].cellIndex;
        var i = 0;
        while (jQuery('#tabela-gwsistemas thead tr th .nome-coluna')[i] != undefined) {
            if (jQuery(jQuery('#tabela-gwsistemas thead tr th .nome-coluna')[i]).html() == labelColuna) {
                chamarAlert('A coluna já existe na tabela.');
                return false;
            }
            i++;
        }
        var tr = jQuery('<th style="min-width: 180px;width:180px;" class="pode-setar-ordem" nome="' + nomeColuna.toUpperCase() + '">');
        var label = jQuery('<label class="nome-coluna">').append(labelColuna);
        tr.append(label);
        var img = jQuery('<img src="img/th-menu.png">');
        tr.append(img);
        tr.append(criarMenuColunas());
        tr.append(criarMenuAddColunas());
        jQuery('#tabela-gwsistemas thead tr th:eq(' + posicaoColuna + ')').after(tr);
        var i = 0;
        while (jQuery('#tabela-gwsistemas tbody tr')[i] != undefined) {
            var colunas = getColumnValue(nomeColuna);
            var td = jQuery('<td>').append(colunas.split('!#!')[i]);
            jQuery('#tabela-gwsistemas tbody tr:eq(' + i + ') td:eq(' + posicaoColuna + ')').after(td);
            i++;
        }

        var i = 0;
        while (jQuery('#tabela-gwsistemas thead tr .pode-setar-ordem')[i]) {
            var cellI = jQuery('#tabela-gwsistemas thead tr .pode-setar-ordem')[i].cellIndex - 1;
            jQuery(jQuery('#tabela-gwsistemas thead tr .pode-setar-ordem')[i]).attr('ordem', cellI);
            i++;
        }

        criarHoverTheadTr();
    }

    function criarMenuColunas() {
        var div = jQuery('<div class="menu-span-dropdown-content">');
        div.append(jQuery(jQuery('.menu-span-dropdown-content')[1]).html());
        return div;
    }

    function criarMenuAddColunas() {
        var div = jQuery('<div class="conteudo-colunas">');
        div.append(jQuery(jQuery('.conteudo-colunas')[1]).html().trim());
        return div;
    }

    function criarHoverTheadTr() {

        jQuery('.tabela-gwsistemas > thead > tr > th').hover(
                function () {
                    jQuery($(this).find('img')).css('opacity', '1.0');
                },
                function () {
                    jQuery($(this).find('img')).css('opacity', '0.0');
                }
        );
        jQuery('.tabela-gwsistemas > thead > tr > th > img').hover(
                function () {
                    var img = $(this)[0];
                    jQuery(img.nextElementSibling).css('display', 'block');
                    jQuery(img.nextElementSibling).css('left', img.offsetLeft + 'px');
                },
                function () {
                    var img = $(this)[0];
                    if (!jQuery(img.nextElementSibling).hasClass('active')) {
                        jQuery(img.nextElementSibling).css('display', 'none');
                    }
                }
        );
        jQuery('.menu-span-dropdown-content').hover(
                function () {
                    $(this).css("display", "block");
                },
                function () {
                    if (!jQuery(this).hasClass('active')) {
                        $(this).css("display", "none");
                    }
                }
        );
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
    }





    jQuery('.menu-span-dropdown-content').on('click', function (event) {
        event.stopPropagation();
    });
    var homePath = '${homePath}';
    jQuery(document).ready(function () {
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
//        $('#myTable').tabelaGwDraggable({
//            redimensionavel:true,
//            draggable:true,
//            ordenacao:true,
//            notDraggableClass: 'not-draggable',
//            notResizableClass: 'nao-redimensionar',
//            notOrderClass: 'nao-ordenar',
//            idImgOrder: 'img-order',
//            caminhoImagemUp: homePath+'/img/ordenar_with_up01.png',
//            caminhoImagemDown : homePath+'/img/ordenar_with_down01.png'
//            
//        });


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


        let c = 0;
        while (jQuery('.imagemEditar')[c] !== undefined) {
            var status = jQuery('#hi_row_status_' + (c+1)).val();
            switch (status.trim()) {
                case 'Enviado':
                    jQuery(jQuery('.tabela-gwsistemas tbody tr .imagemEditar')[c]).append(
                            jQuery('<center><img width="20px" height="20px" src="${homePath}/img/email_ok.png"></center>'));
                    break;
                case 'Pendente':
                    jQuery(jQuery('.tabela-gwsistemas tbody tr .imagemEditar')[c]).append(
                            jQuery('<center><img width="20px" height="20px" src="${homePath}/img/email_pendencia.png"></center>'));
                    break;
                default:
                    jQuery(jQuery('.tabela-gwsistemas tbody tr .imagemEditar')[c]).append(
                            jQuery('<center><img width="20px" height="20px" src="${homePath}/img/email_erro.png"></center>'));
                    break
            }
            c++;
        }

    });
    function trChecked(elemento, position) {
        addRemoveClassTr(jQuery(jQuery(elemento).parents("tr")));
        jQuery("input[type=checkbox][name*=nCheck]").each(
                function (f, a) {
                    var isExist = false;
                    if (a.checked) {
                        isExist = true;
                    }
                    if (isExist) {
                        jQuery('#removeCte').removeClass("removeCteOff").addClass("removeCteOn");
                        jQuery('#removeCte').prop('disabled', '');
                        return false;
                    } else {
                        jQuery('#removeCte').removeClass("removeCteOn").addClass("removeCteOff");
                        jQuery('#removeCte').prop('disabled', 'true');
                    }


                });
    }

    function addRemoveClassTr(elemento) {
//        $(elemento).toggleClass("datagrind-row-checked datagrid-row-selected");
        if (jQuery(jQuery(elemento).find("input[type=checkbox][name*=nCheck]")).is(':checked')) {
            jQuery(elemento).addClass("datagrid-row-checked").addClass("datagrid-row-selected");
        } else {
            jQuery(elemento).removeClass("datagrid-row-checked").removeClass("datagrid-row-selected");
        }

    }

    function marcarTodos(element) {
        if (element.checked) {
            jQuery("input[type=checkbox][name*=nCheck]").each(
                    function (f, a) {
                        f = f + 1;
//                $($(a).parents("tr")).removeClass("datagrid-row").addClass("datagrid-row datagrid-row-checked datagrid-row-selected");
//                $($(a).parents("tr")).css("background","#ADC4E5");
//                $($(a).parents("tr")).css("background","#87A7D6");
//                $($(a).parents("tr")).css("font-weight","bold");
                        a.checked = true;
                        addRemoveClassTr($($(a).parents("tr")));
                        jQuery('#removeCte').removeClass("removeCteOff").addClass("removeCteOn");
                    });
        } else {
            jQuery("input[type=checkbox][name*=nCheck]").each(
                    function (f, a) {
                        f = f + 1;
                        a.checked = false;
                        addRemoveClassTr($($(a).parents("tr")));
//                $($(a).parents("tr")).css("background","");
//                $($(a).parents("tr")).css("font-weight","");
//                $($(a).parents("tr")).removeClass("datagrid-row datagrid-row-checked datagrid-row-selected").addClass("datagrid-row");
                        jQuery('#removeCte').removeClass("removeCteOn").addClass("removeCteOff");
                    });
        }
    }

    //Validar o caractere de pagina
    function verificaCaracterePagina(element, paginas) {
        element.value = element.value.replace(/[^0-9,]/g, "");
        if (element.value != null && element.value != "" && parseFloat(element.value) > parseFloat(paginas)) {
            element.value = "";
            return true;
        }

        //nao enviar pagina caso seja 0 - já que 0 é menor
        // que a quantidade de paginas sempre e passa das validacoes acima
        if (element.value == "0" || element.value == 0) {
            element.value = "";
        }
    }
</script>
