<%-- 
    Document   : dom-inventario-etiqueta
    Created on : 23/05/2018, 11:54:45
    Author     : mateus
--%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<div class="item-lista-etiqueta">

    <div class="col-md-4 no-padding ativa-helper2" data="numeroEtiqueta" style="${param.status == 'Ok' ? '':'color:darkred;'}">${param.etiqueta}</div>
    <div class="col-md-4 no-padding ativa-helper2" data="usuario" style="${param.status == 'Ok' ? '':'color:darkred;'}">${param.nomeUsuario}</div>
    <div class="col-md-4 no-padding ativa-helper2" data="status" style="${param.status == 'Ok' ? '':'color:darkred;'}">${param.status}</div>

    <script>
        $(document).ready(function () {
            $(".ativa-helper2").hover(
                function () {
                    var t = $(this);
                    var attr = t.attr('data');
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