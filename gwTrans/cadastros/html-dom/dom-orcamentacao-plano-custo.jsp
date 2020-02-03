<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=ISO-8859-1" %>
<div data-nivel="${param['nivel']}" data-analitica="${param['isAnalitica']}" data-plano-pai="${param['planoPai']}"
     data-conta="${param['conta']}" data-qtd-dom="${param['qtdDom']}"
     data-gw-grupo-serializado="dom-plano-custo${param.qtdDom}" data-gw-grupo-name="planos"
>
    <div class="coluna-plano-custo fixo" data-ajuda="plano_custo_ajuda">
        <input type="hidden" name="id${param.qtdDom}" id="id${param.qtdDom}" value="${param['id']}"
               data-gw-campo-grupo-serializado="dom-plano-custo${param.qtdDom}">
        <input type="hidden" name="id-plano${param.qtdDom}" id="id-plano${param.qtdDom}" value="${param['idPlano']}"
               data-gw-campo-grupo-serializado="dom-plano-custo${param.qtdDom}">
        <input type="hidden" name="analitica${param.qtdDom}" id="analitica${param.qtdDom}"
               value="${param['isAnalitica']}"
               data-gw-campo-grupo-serializado="dom-plano-custo${param.qtdDom}">

        <span style="padding-left: ${10 * param['nivel']}px">
            <i class="fas fa-plus-square expandir-icone"
               style="${param['isAnalitica'] eq 'true' ? 'visibility: hidden;' : ''}"></i>
            <label id="label-plano-custo${param.qtdDom}"></label>
        </span>
    </div>
    <div class="coluna-tipo fixo" data-ajuda="tipo_ajuda">
        <span ${param['isAnalitica'] eq 'true' ? '' : 'style="visibility: hidden"'}>
            <input type="radio" name="plano-tipo${param['qtdDom']}" id="plano-tipo-geral${param['qtdDom']}" value="g"
            ${param['tipo'] eq 'g' ? 'checked' : ''} data-gw-campo-grupo-serializado="dom-plano-custo${param.qtdDom}"
            ${param['podeAlterar'] eq 'true' ? "" : "readonly disabled"}>
            <label for="plano-tipo-geral${param['qtdDom']}">Geral</label>
            <input type="radio" name="plano-tipo${param['qtdDom']}" id="plano-tipo-unidade-custo${param['qtdDom']}"
            ${param['tipo'] eq 'u' ? 'checked' : ''} value="u"
                   data-gw-campo-grupo-serializado="dom-plano-custo${param.qtdDom}"
                   ${param['podeAlterar'] eq 'true' ? "" : "readonly disabled"}>
            <label for="plano-tipo-unidade-custo${param['qtdDom']}">Por Unidade Custo</label>
        </span>
    </div>
    <div class="coluna-valor-total fixo" data-ajuda="valor_total_ajuda">
        <span class="container-input-form-gw">
            <input class="input-form-gw" name="valor-total${param['qtdDom']}"
                   id="valor-total${param['qtdDom']}"
                   type="text" value="${param['valor']}" required
                   data-gw-campo-grupo-serializado="dom-plano-custo${param.qtdDom}"
                   data-mask="#.##0,00"
                   data-mask-reverse="true" ${param['isAnalitica'] eq 'true' and param['podeAlterar'] eq 'true' ? '' : 'readonly disabled'}>
        </span>
    </div>
    <div class="unidades" id="div-unidades${param['qtdDom']}">
    </div>

    <script>
        $(document).ready(function () {
            let conta = decodeURIComponent('${param['conta']}').split('.');
            let contaSemNegrito = conta.slice(0, conta.length - 1).join('.');
            let negrito = '<strong>' + conta[conta.length - 1] + '</strong>';

            $('#label-plano-custo${param.qtdDom}')
                .html((contaSemNegrito === '' ? '' : contaSemNegrito + '.') + negrito + ' - ' + decodeURIComponent('${param['descricao']}'))
                .attr('title', decodeURIComponent('${param['conta']}') + ' - ' + decodeURIComponent('${param['descricao']}'));

            let json = JSON.parse(sessionStorage.getItem("unidades_${param['qtdDom']}"));
            let divUnidades = $("#div-unidades${param['qtdDom']}");

            $.each(json, function (index, unidade) {
                adicionarColunaUnidade(divUnidades, '${param['qtdDom']}', index, unidade, "${param['isAnalitica']}");
            });

            if (parseInt('${param['qtdDom']}') >= qtdDom) {
                $.applyDataMask('input[data-mask!=""]');

                jQuery('.coluna-valor-total input[type="text"], span[data-gw-grupo-lista="unidades"] input[type="text"]').each(function (index, e) {
                    let elemento = $(e);
                    let valor = elemento.attr('value');

                    if (elemento.masked === undefined) {
                        for (let i = 1; i <= 10; i++) {
                            setTimeout(function() {
                                elemento.val(elemento.masked(parseFloat(valor).toFixed(2).replace(/\./g, '')));
                            }, 500 * i);
                        }
                    } else {
                        elemento.val(elemento.masked(parseFloat(valor).toFixed(2).replace(/\./g, '')));
                    }
                });

                atualizarValoresTotaisOrcamentacao();

                setTimeout(function () {
                    $(window).trigger('resize');

                    setTimeout(function () {
                        $('.container-tela-pl-custo').css('visibility', 'visible');
                    }, 500);
                }, 500);

                $('.bloqueio-tela').hide();
                $('.gif-bloq-tela').hide();

                if (atualizar) {
                    chamarAlert('Atualizado com sucesso!');
                    atualizar = false;
                }
            }
        });
    </script>
</div>