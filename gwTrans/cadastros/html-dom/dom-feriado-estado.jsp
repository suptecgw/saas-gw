<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="col-md-12" data-gw-grupo-serializado="dom-estado${param.qtdDom}" style="padding-left: 10px">
    <div class="col-md-10">
        <input type="hidden" id="idEstado${param.qtdDom}" name="idEstado${param.qtdDom}" value="${param.idEstado}" data-gw-campo-grupo-serializado="dom-estado${param.qtdDom}" data-type="text">

        <select name="slc-estados${param.qtdDom}" id="slc-estados${param.qtdDom}" data-gw-campo-grupo-serializado="dom-estado${param.qtdDom}" data-type="text" data-ajuda="estado">
            <option value="AC" selected>Acre</option>
            <option value="AL">Alagoas</option>
            <option value="AP">Amapá</option>
            <option value="AM">Amazonas</option>
            <option value="BA">Bahia</option>
            <option value="CE">Ceará</option>
            <option value="DF">Distrito Federal</option>
            <option value="ES">Espírito Santo</option>
            <option value="GO">Goiás</option>
            <option value="MA">Maranhão</option>
            <option value="MT">Mato Grosso</option>
            <option value="MS">Mato Grosso do Sul</option>
            <option value="MG">Minas Gerais</option>
            <option value="PA">Pará</option>
            <option value="PB">Paraíba</option>
            <option value="PR">Paraná</option>
            <option value="PE">Pernambuco</option>
            <option value="PI">Piauí</option>
            <option value="RJ">Rio de Janeiro</option>
            <option value="RN">Rio Grande do Norte</option>
            <option value="RS">Rio Grande do Sul</option>
            <option value="RO">Rondônia</option>
            <option value="RR">Roraima</option>
            <option value="SC">Santa Catarina</option>
            <option value="SP">São Paulo</option>
            <option value="SE">Sergipe</option>
            <option value="TO">Tocantins</option>
        </select>
    </div>
    <div class="col-md-1" >
        <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir ativa-helper-data-ajuda" onclick="excluirDom(this, 'idEstado${param.qtdDom}');" data-ajuda="icone-excluir-estado">
    </div>
</div>

<script>
    $(document).ready(function () {
        jQuery("#slc-estados${param.qtdDom}").each(function () {
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
