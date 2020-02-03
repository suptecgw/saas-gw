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
    <c:set var = "s" scope = "session" value = "${random.nextInt(1000)}"/>
    <div class="col-md-12" data-gw-grupo-serializado="dom-tabela-preco${s}">
        <script>
            var indexAtual = 0;

            function toLocalizar(i) {
                indexAtual = i;

                $('.cobre-tudo').show();
                controlador.acao('abrirLocalizar', 'localizarTabelaPreco');
            }
            
            function getColunas(colunas){
                
                
                if (colunas.isDesativada == 't' || colunas.isDesativada == 'true') {
                    chamarAlert("Erro: Tabela de preço desativada.");
                    return false;
                } else if (colunas.isVencida == 't' || colunas.isVencida == 'true') {
                    chamarAlert("Erro: Tabela de preço vencida.");
                    return false;
                }
                
                removerValorInput('tabela' + indexAtual);
                removerValorInput('origem' + indexAtual);
                removerValorInput('destino' + indexAtual);
                removerValorInput('tipoProduto' + indexAtual);
                removerValorInput('valorFrete' + indexAtual);
                removerValorInput('porcentagemNF' + indexAtual);
                removerValorInput('freteMinimo' + indexAtual);

                addValorAlphaInput('tabela' + indexAtual, colunas.cliente, colunas.codigo);
                addValorAlphaInput('origem' + indexAtual, colunas.origem);
                addValorAlphaInput('destino' + indexAtual, colunas.destino);
                addValorAlphaInput('tipoProduto' + indexAtual, colunas.tipoProduto);
                addValorAlphaInput('valorFrete' + indexAtual, colunas.valorFrete);
                addValorAlphaInput('porcentagemNF' + indexAtual, colunas.porcentagemNF);
                addValorAlphaInput('freteMinimo' + indexAtual, colunas.porcentagemNF);
            }
        </script>
        <div class="localiza" style="">
            <iframe id="localizarTabelaPreco" input="getColunas" name="localizarTabelaPreco" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarTabelaPreco&tema=${param.tema}" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <!--<input class="input-localizar-gw">-->
        <div style="width: 45px;float: left;">&nbsp;</div>
        <div class="col-md-2 ativa-helper1">
            <span class="container-input-form-gw input-width-80">
                <input class="input-width-100" id="tabela${s}" name="tabela${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}" type="text" placeholder="Campo obrigatório!" />
                <input type="hidden" id="idTabelaContrato${s}" name="idTabelaContrato${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}"/>
            </span>
            <img src="${homePath}/gwTrans/cadastros/img/icon-more.png" alt="" class="inp-localizar" onclick="checkSession(function () {toLocalizar('${s}');}, false);"/>
            <img src="${homePath}/img/edit.png" class="inp-open-register" onclick="checkSession(function () {editar('${s}');}, false);"/>
        </div>
        <div class="col-md-2">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100 input-readonly ativa-helper2" name="origem${s}" id="origem${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}" type="text" readonly="readonly"/>
            </span>
        </div>
        <div class="col-md-2">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100 input-readonly ativa-helper2" name="destino${s}" id="destino${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}"  type="text" readonly="readonly"/>
            </span>
        </div>
        <div class="col-md-1">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100 input-readonly ativa-helper2" name="tipoProduto${s}" id="tipoProduto${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}" type="text" readonly="readonly"/>
            </span>
        </div>
        <div class="col-md-1">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100 input-readonly ativa-helper2" name="valorFrete${s}" id="valorFrete${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}" type="text" readonly="readonly"/>
            </span>
        </div>
        <div class="col-md-1">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100 input-readonly ativa-helper2" name="porcentagemNF${s}" id="porcentagemNF${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}" type="text" readonly="readonly"/>
            </span>
        </div>
        <div class="col-md-1">
            <span class="container-input-form-gw input-width-100">
                <input class="input-dom-gw input-width-100 input-readonly ativa-helper2" name="freteMinimo${s}" id="freteMinimo${s}" data-gw-campo-grupo-serializado="dom-tabela-preco${s}" type="text" readonly="readonly"/>
            </span>
        </div>
        <div class="col-md-1" >
            <img src="${homePath}/gwTrans/cadastros/img/excluir.png" class="bt-excluir" onclick="excluirDom(this, 'idTabelaContrato${s}');">
        </div>
    </div>
    <script>
        jQuery('#tabela${s}').inputMultiploGw({
            readOnly: 'true',
            width: '97%'
        });

        $(".ativa-helper2").hover(
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

        $(".ativa-helper1").hover(
            function () {
                t = $(this);
                $(".campo-helper h2").html($($(this).context).find('input[type=hidden]')[2].value);
                $(".descri-helper h3").html($($(this).context).find('input[type=hidden]')[1].value);
            },
            function () {
                $('.campo-helper h2').html('Ajuda');
                $(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
            }
        );

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
                            addAjudaLabel(jsonCampos.name + ${s}, jsonCampos.label, jsonCampos.observacao);
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

        $('.block').css('background', 'rgb(210,210,210)');
        $('.block').parent().css('background', 'rgb(210,210,210)');
        $('.block').attr('disabled', true);
        
        carregarAjuda();
        
        function editar(index){
            if (jQuery("#tabela"+index)) {
                var id = jQuery("#tabela"+index).val().split("#@#")[1];
                var href = ("./cadtabela_preco.jsp?acao=editar&id="+id);
                window.open(href, "editarTabelaPreco", "toolbar=yes,scrollbars=yes,resizable=yes,top=200,left=500,width=800,height=600");
            }
        }
    </script>
</body>
