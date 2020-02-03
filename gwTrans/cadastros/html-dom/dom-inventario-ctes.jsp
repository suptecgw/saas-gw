<%-- 
    Document   : dom-inventario-ctes
    Created on : 22/05/2018, 14:22:43
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="item-lista-cte ${param.isCompleto ? 'item-completo' : 'item-incompleto'}" data-gw-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}">
    <div class="col-md-2 ativa-helper1 coluna-numero-cte" data="numeroCte"><label class="lb-link link-cte${param.qtdDomNFe}" id="lb-link-cte${param.qtdDomNFe}">${param.numeroCte}</label></div>
    <div class="col-md-3 ativa-helper1 coluna-clientes" data="destinatario" title="${param.destinatario}" style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap">${param.destinatario}</div>
    <div class="col-md-3 ativa-helper1 coluna-clientes" data="consignatario" title="${param.consignatario}" style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap">${param.consignatario}</div>
    <div class="col-md-2 ativa-helper1 coluna-nota" data="numeroNota"><label class="lb-link" id="lb-link-nota${param.qtdDomNFe}">${param.numeroNota}</label></div>
    <div class="col-md-1 ativa-helper1" data="vol${param.qtdDomNFe}"><label class="lb-qtd-notas-bipadas">${param.bipadas}</label>/<span class="lb-qtd-volumes">${param.volumeTotal}</span><span class="icon-status-cte" id="icon-status-cte${param.qtdDomNFe}"></span></div>
    <div class="col-md-1">
        <input type="hidden" value="true" name="status-item${param.qtdDomNFe}" id="status-item${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.id}" name="id${param.qtdDomNFe}" id="id${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.idCte}" name="idcte${param.qtdDomNFe}" id="idcte${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.numeroCte}" name="numeroCte${param.qtdDomNFe}" id="numeroCte${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.idNota}" name="idNota${param.qtdDomNFe}" id="idNota${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.numeroNota}" name="numeroNota${param.qtdDomNFe}" id="numeroNota${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.destinatario}" name="destinatario${param.qtdDomNFe}" id="destinatario${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.volumeTotal}" name="volumeTotal${param.qtdDomNFe}" id="volumeTotal${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.etiquetas}" name="etiquetas${param.qtdDomNFe}" id="etiquetas${param.qtdDomNFe}" >
        <input type="hidden" value="${param.isExcluido}" name="isExcluido${param.qtdDomNFe}" id="isExcluido${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">
        <input type="hidden" value="${param.motivoFalta}" name="motivoFalta${param.qtdDomNFe}" id="motivoFalta${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">

        <input type="hidden" value="0" name="volumeBipado${param.qtdDomNFe}" id="volumeBipado${param.qtdDomNFe}" data-gw-campo-grupo-serializado="dom-inventario-cte${param.qtdDomNFe}" data-type="text">

        <img src="${homePath}/img/edit.png" class="img-editar-cte" id="img-editar-cte${param.qtdDomNFe}" alt="Adicionar Justificativa" title="Adicionar uma justificativa de falta/sobra.">
        <span class="img-excluir-cte" id="img-excluir-cte${param.qtdDomNFe}"></span>
    </div>
    <script>
        $('.link-cte${param.qtdDomNFe}').on('click', function () {
            if ($(this).hasClass('lb-link')) {
                window.open("${homePath}/frameset_conhecimento?acao=editar&id=${param.idCte}", "", "width=1200,height=700");
            }
        });
//        idNota
        $('#lb-link-nota${param.qtdDomNFe}').on('click', function () {
            if ($(this).hasClass('lb-link')) {
                window.open("${homePath}/NotaFiscalControlador?acao=carregar&idNota=${param.idNota}", "", "width=1200,height=700");
            }
        });


        $('#img-excluir-cte${param.qtdDomNFe}').on('click', function (e) {
            var container = $(e.target).parents().parent('.container-item-dom-cte');
            var is_ativo = $('#status-item${param.qtdDomNFe}').val();
            if (is_ativo === 'true') {
                $(container).css('background', 'rgba(0,0,0,0.8)');
                $('#isExcluido${param.qtdDomNFe}').val('true');
                $('#status-item${param.qtdDomNFe}').val('false');
                $('#img-excluir-cte${param.qtdDomNFe}').css('background-position-x', '73px');
                $('#icon-status-cte${param.qtdDomNFe}').css('opacity', '0').css('cursor', 'default');
                $('#img-editar-cte${param.qtdDomNFe}').css('opacity', '0').css('cursor', 'default');
                $('[data="vol${param.qtdDomNFe}"]').css('opacity', '0').css('cursor', 'default');
                $('#lb-link-cte${param.qtdDomNFe}').removeClass('lb-link').addClass('lb-no-link');
                $('#lb-link-nota${param.qtdDomNFe}').removeClass('lb-link').addClass('lb-no-link');
            } else {
                container.css('background', '');
                $('#isExcluido${param.qtdDomNFe}').val('false');
                $('#status-item${param.qtdDomNFe}').val('true');
                $('#img-excluir-cte${param.qtdDomNFe}').css('background-position-x', '');
                $('#icon-status-cte${param.qtdDomNFe}').css('opacity', '').css('cursor', '');
                $('#img-editar-cte${param.qtdDomNFe}').css('opacity', '').css('cursor', '');
                $('[data="vol${param.qtdDomNFe}"]').css('opacity', '').css('cursor', '');
                $('#lb-link-cte${param.qtdDomNFe}').removeClass('lb-no-link').addClass('lb-link');
                $('#lb-link-nota${param.qtdDomNFe}').removeClass('lb-no-link').addClass('lb-link');
            }
        });


        $('#img-editar-cte${param.qtdDomNFe}').on('click', function () {
            if ($(this).css('opacity') !== '0') {
                sessionStorage.setItem('justificativa-falta','motivoFalta${param.qtdDomNFe}');
                $('.model-justificativa-falta-cte').show();
                $('.cobre-tudo').show();
            }
        });

        $(function () {
            if ($('#isExcluido${param.qtdDomNFe}').val() === 'true') {
                $('#img-excluir-cte${param.qtdDomNFe}').trigger('click');
            }

            $(".ativa-helper1,.img-editar-cte,.img-excluir-cte").hover(
                function () {
                    t = $(this);
                    var attr = t.attr('data');

                    if (attr) {
                        attr = attr.replace(/\d/g, '');
                    } else if (!attr || attr === '') {
                        attr = t.attr('id');

                        if (attr) {
                            attr = attr.replace(/\d/g, '');
                        }
                    }

                    var elemento = $('#' + attr);
                    $(".campo-helper h2").html(elemento.find('input[type=hidden]')[1].value);
                    $(".descri-helper h3").html(elemento.find('input[type=hidden]')[0].value);
                },
                function () {
                    $('.campo-helper h2').html('Ajuda');
                    $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                }
            );
        });
    </script>
</div>