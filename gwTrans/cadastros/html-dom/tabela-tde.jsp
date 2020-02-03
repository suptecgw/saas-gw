<%-- 
    Document   : tabela-tde
    Created on : 28/12/2017, 12:14:43
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
</head>
<body>
    <div style="width: 45px;float: left;">&nbsp;</div>
    <div class="col-md-11" data-gw-grupo-serializado="dom-grupo-tde${param.qtdDomTDe}">
        <input type="hidden" name="tipo${param.qtdDomTDe}" id="tipo${param.qtdDomTDe}" value="cli" data-gw-campo-grupo-serializado="dom-grupo-tde${param.qtdDomTDe}">
        <div class="col-md-2 radio-grupos ativa-helper" id="grupo-cli-dest${param.qtdDomTDe}">
            <label><input type="radio" name="tipoGrupo${param.qtdDomTDe}" id="tipoGrupo${param.qtdDomTDe}" checked="true" value="cli" onchange="tipoGrupo(this, '${param.qtdDomTDe}');">Grupo de Clientes</label>
            <label><input type="radio" name="tipoGrupo${param.qtdDomTDe}" id="tipoGrupo${param.qtdDomTDe}" value="dest" onchange="tipoGrupo(this, '${param.qtdDomTDe}');">Destinatários</label>
        </div>
        <div class="col-md-3">
            <span class="container-input-form-gw input-width-80">
                <input class="input-width-100" id="grupo${param.qtdDomTDe}" name="grupo${param.qtdDomTDe}" type="text" data-gw-campo-grupo-serializado="dom-grupo-tde${param.qtdDomTDe}" placeholder="Campo obrigatório!" data-validar="true" data-erro-validacao="O campo Grupo / Destinatário é de preenchimento obrigatório!" data-type="text"/>  
            </span>
            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="toLocalizar('grupo${param.qtdDomTDe}', '${param.qtdDomTDe}')"/>
        </div>
        <div class="col-md-2">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100" id="valorTDE${param.qtdDomTDe}" name="valorTDE${param.qtdDomTDe}" data-gw-campo-grupo-serializado="dom-grupo-tde${param.qtdDomTDe}" data-dinheiro type="text" value="0,00" placeholder="Campo obrigatório!" data-validar="true" data-erro-validacao="O campo Valor TDE é de preenchimento obrigatório!" data-type="text"/>
            </span>
        </div>
        <div class="col-md-2">
            <select name="selectTipoCalculo${param.qtdDomTDe}" id="selectTipoCalculo${param.qtdDomTDe}" >
                <option value="v">R$ Fixo</option>
                <option value="p">% Sobre o valor do frete</option>
            </select>
            <input type="hidden" id="tipoCalculo${param.qtdDomTDe}" name="tipoCalculo${param.qtdDomTDe}" value="v" data-gw-campo-grupo-serializado="dom-grupo-tde${param.qtdDomTDe}">
        </div>
        <div class="col-md-2">
            <span class="container-input-form-gw input-width-100" style="background: #ccc;">
                <input class="input-dom-gw input-width-100" id="formula${param.qtdDomTDe}" name="formula${param.qtdDomTDe}" data-gw-campo-grupo-serializado="dom-grupo-tde${param.qtdDomTDe}" readonly="true" type="text" style="background: #ccc;cursor: default;" placeholder="" data-validar="false" data-erro-validacao="O campo Fórmula é de preenchimento obrigatório!" data-type="text" />
            </span>
        </div>
        <div class="col-md-1" >
            <img src="${homePath}/img/formula.png" class="bt-excluir" style="padding-right: 10px; " onclick="mostrarFormula('${param.qtdDomTDe}');">
            <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir" onclick="excluirDom(this);">
        </div>
    </div>
    <script>
        $('#grupo${param.qtdDomTDe}').inputMultiploGw({
            readOnly: 'true',
            width: '97%'
        });

        var t;

        $(document).ready(function () {

            $(".ativa-helper").hover(
                    function () {
                        t = $(this);
                        $(".campo-helper h2").html($($(this).context).find('input[type=hidden]')[1].value);
                        $(".descri-helper h3").html($($(this).context).find('input[type=hidden]')[0].value);
                    },
                    function () {
                        $('.campo-helper h2').html('Ajuda');
                        $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
                    }
            );


            $('[data-dinheiro]').mask("#.##0,00", {reverse: true});
            $('[data-dinheiro]').on('focusin focusout', function (e) {
                if (e.type === 'focusout' && this.value === '') {
                    $(this).val('0,00');
                } else if (e.type === 'focusin' && this.value === '0,00') {
                    $(this).val('');
                }
            });

        });

        $('.block').css('background', 'rgb(210,210,210)');
        $('.block').parent().css('background', 'rgb(210,210,210)');
        $('.block').attr('disabled', true);


        function carregarAjuda() {
            $.ajax({
                url: "UsuarioControlador?acao=ativarAjuda&codigoTela=" + getCodTela(),
                type: 'POST',
                dataType: 'text/html',
                beforeSend: function () {
                    if ($('.aguarde') !== undefined) {
                        $('.cobre-left').show('fast');
                        $('.aguarde').show('fast');
                    }
                },
                complete: function (retorno) {
                    if ($('.aguarde') !== undefined) {
                        $('.aguarde').hide('fast');
                        $('.cobre-left').hide('fast');
                    }

                    if (retorno.responseText !== '') {

                        var retornoSplit = retorno.responseText.split(']');
                        var camposAjuda = JSON.parse(retornoSplit[0] + ']');
                        var permissoes = JSON.parse(retornoSplit[1] + ']');


                        for (var i = 0; i < camposAjuda.length; i++) {
                            var jsonCampos = camposAjuda[i];
                            addAjudaLabel(jsonCampos.name +${param.qtdDomTDe}, jsonCampos.label, jsonCampos.observacao);
                        }

                        for (var i = 0; i < permissoes.length; i++) {
                            var jsonPerm = permissoes[i];
//                            addPermissoesTela(jsonPerm.codigo, jsonPerm.descricao, jsonPerm.observacao);
                        }
                        if (permissoes.length === 0) {
//                            semPermissao();
                        }

                    } else {
//                        semPermissao();
                    }
                }
            });
        }

        carregarAjuda();

        jQuery("#selectTipoCalculo${param.qtdDomTDe}").selectmenu({
            change: function () {
                tipoCalculo(this, '${param.qtdDomTDe}');
            },
            open: function (event, ui) {
            },
            close: function (event, ui) {
            }
        }).selectmenu("menuWidget").addClass("selects-ui");
    </script>
</body>
