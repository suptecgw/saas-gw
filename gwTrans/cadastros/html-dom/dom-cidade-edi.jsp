<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="col-md-12" data-gw-grupo-serializado="dom-cidade${param.qtdDom}" style="padding-left: 10px">
    <div class="col-md-10">
        <input type="hidden" id="idCidade${param.qtdDom}" name="idCidade${param.qtdDom}" value="${param.idEstado}" data-gw-campo-grupo-serializado="dom-cidade${param.qtdDom}" data-type="text">
        <select name="slc-cidade${param.qtdDom}" id="slc-cidade${param.qtdDom}" data-gw-campo-grupo-serializado="dom-cidade${param.qtdDom}" data-type="text" data-ajuda="cidade">
            todas as cidades EDIs
        </select>
    </div>
    <div class="col-md-1" >
        <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir ativa-helper-data-ajuda" onclick="excluirDom(this, 'idCidade${param.qtdDom}');" data-ajuda="icone-excluir-cidade">
    </div>
</div>

<script>
    $(document).ready(function () {
        jQuery("#slc-cidade${param.qtdDom}").each(function () {
            var objeto = $(this);

            if ('${param.valorCampo}' !== '') {
                objeto.val(decodeURI('${param.valorCampo}'));
            }

            objeto.selectmenu().selectmenu("option", "position", {
                my: "top+15",
                at: "top center"
            }).selectmenu("menuWidget").addClass("selects-ui");
        });
        jQuery("span[class*='-button']").hover(
                function () {
                    var t = $(this);
                    var attr = t.parent().find('select').attr('data-ajuda');
                    var elemento = $('#' + attr);
                    $(".campo-helper h2").html(elemento.find('input[type=hidden]')[1].value);
                    $(".descri-helper h3").html(elemento.find('input[type=hidden]')[0].value);
                },
                function () {
                    $('.campo-helper h2').html('Ajuda');
                    $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                }
        );
        carregarAjudaData();
    });
</script>
