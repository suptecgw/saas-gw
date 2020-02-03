
<%-- 
    Document   : dom-detalhes-ocorrencia
    Created on : 13/06/2018, 13:43:29
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<div class="col-md-12">
    <label class="font-sublinhada" title="Nº da nota fiscal">Nota Fiscal: <span class="font-bold numero-nota${param.count}"></span></label>
</div>
<div class="col-md-12">
    <label class="font-sublinhada">Itens</label>
</div>
<div class="col-md-12 topo-dom-mercadoria-nota">
    <div class="col-add-dom">
        <span class="add-novo-item-nota" id="add-novo-item-nota${param.count}" title="Adicionar um item a nota fiscal"></span>
    </div>
    <div class="col-dom-mercadoria col-dom-mercadorial-245">
        <label title="Código do produto.">Código</label>
    </div>
    <div class="col-dom-mercadoria col-dom-mercadorial-200">
        <label title="Descrição do produto.">Descrição</label>
    </div>
    <div class="col-dom-mercadoria">
        <label title="Quantidade do item que teve avaria. ATENÇÃO! Não é a quantidade transportada é a quantidade que teve avaria.">Qtd Avariada</label>
    </div>
    <div class="col-dom-mercadoria">
        <label title="Valor unitário do item.">Valor Unitário</label>
    </div>
    <div class="col-dom-mercadoria col-dom-mercadorial-120">
        <label>Total</label>
    </div>
    <div class="col-dom-mercadoria col-dom-mercadorial-50 no-border-right"></div>
</div>
<div class="col-md-12 corpo-dom-mercadoria-nota no-border-radius" data="itens${param.count}" style="width: 872px;"></div>
<div class="col-md-12 corpo-dom-mercadoria-nota">
    <div class="container-nota-item-dom bg-white">
        <div class="col-add-dom item-nota-dom no-border-right"></div>
        <div class="col-dom-mercadoria item-nota-dom no-border-right col-dom-mercadorial-245"></div>
        <div class="col-dom-mercadoria col-dom-mercadorial-200 item-nota-dom text-right font-bold">Total:</div>
        <div class="col-dom-mercadoria item-nota-dom font-bold" data="total-avaria"></div>
        <div class="col-dom-mercadoria item-nota-dom"></div>
        <div class="col-dom-mercadoria col-dom-mercadorial-120 item-nota-dom font-bold" data="total"></div>
        <div class="col-dom-mercadoria col-dom-mercadorial-50 no-border-right item-nota-dom font-bold"></div>
    </div>
</div>
<div class="localiza"></div>
<script>
    var parametro = {
        'filtroId': '${param.idRemetente}'
    };
    sessionStorage.setItem('parametros', JSON.stringify(parametro));
    
    var c = 1;
    var lastItem = null;

    $(function () {
        var json = JSON.parse(sessionStorage.getItem('jsonNotas' + ${param.count}));
        sessionStorage.removeItem('jsonNotas' + ${param.count});
        $('#add-novo-item-nota${param.count}').click(function () {
            addItemNota(${param.count}, json.idnota_fiscal);
        });
        $('.abrir-localizar-item-nota').click(function () {
            abrirLocalizarProduto(this);
        });
        $('.numero-nota${param.count}').text(json.numero);
        $.each(json.itens, function (i, e) {
            addItemNota(${param.count}, json.idnota_fiscal, e.codigo, e.idproduto, e.descricao, e.qtd_avariada, e.valor, e.id_item_nota);
        });
        atualizarTotais();
    });

    setTimeout(function () {
        $('.localiza').html('<iframe id="localizarProdutoRemetente" input="editarItemNota" name="localizarProdutoRemetente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarProdutoRemetente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>');
    }, 10);

    function addItemNota(paramCount, idNota, codigo, idproduto, descricao, qtd_avariada, vl_unitario,id_item_nota = "0") {
        console.log(id_item_nota);
        var container = $('<div>').addClass('container-nota-item-dom').attr('id', 'container-dom_' + '${param.count}' + '_' + c).attr('index','_' + '${param.count}' + '_' + c).attr('data-gw-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c), div = null, span = null, input = null;
        div = $('<div>').addClass('col-add-dom item-nota-dom');
        container.append(div);
        input = $('<input>').attr('name', 'notaId').attr('id', 'notaId').attr('type', 'hidden').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val(idNota);
        div.append(input);
        input = $('<input>').attr('name', 'idItemNota').attr('id', 'idItemNota_' + '${param.count}' + '_' + c).attr('type', 'hidden').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val(id_item_nota);
        div.append(input);
        input = $('<input>').attr('name', 'isExcluido').attr('id', 'isExcluido_' + '${param.count}' + '_' + c).attr('type', 'hidden').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val('false');
        div.append(input);
        div = $('<div>').addClass('col-dom-mercadoria col-dom-mercadorial-245 item-nota-dom codigo').text(' ');
        span = $('<span>').addClass('container-input-form-gw input-width-100 input-readonly-modal').css('width', '78%').css('margin-top', '2px').css('float', 'left');
        input = $('<input>').attr('name', 'codigo').attr('type', 'text').addClass('input-form-gw input-readonly-modal').attr('readonly', 'readonly').css('width', '89%').css('border', 'none !important').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val((codigo ? codigo : ''));
        span.append(input);

        input = $('<input>').attr('name', 'idProduto').attr('type', 'hidden').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val((idproduto ? idproduto : '0'));
        span.append(input);
        div.append(span);

        span = $('<span>').addClass('abrir-localizar-item-nota').attr('title', 'Localizar um produto já cadastrado para o remetente.');
        span.click(function () {
            abrirLocalizarProduto(this);
        });
        div.append(span);

        container.append(div);
        div = $('<div>').addClass('col-dom-mercadoria col-dom-mercadorial-200 item-nota-dom descricao').text(' ');
        span = $('<span>').addClass('container-input-form-gw input-width-100').css('width', '90%').css('margin-top', '2px');
        input = $('<input>').attr('name', 'descricao').attr('type', 'text').addClass('input-form-gw').css('width', '89%').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val((descricao ? descricao : ''));
        span.append(input);
        div.append(span);
        container.append(div);

        div = $('<div>').addClass('col-dom-mercadoria item-nota-dom quantidade').text(' ');
        span = $('<span>').addClass('container-input-form-gw input-width-100').css('width', '90%').css('margin-top', '2px');
        input = $('<input>').attr('name', 'qtdAvariada').attr('default', ',00').attr('onkeyup', 'atualizarTotais()').attr('type', 'text').addClass('input-form-gw').css('width', '89%').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val(parseFloat(qtd_avariada).toFixed(2));
        $(input).mask("###0,00", {reverse: true});
        $(input).focusout(verificarNulo);
        span.append(input);
        div.append(span);
        container.append(div);

        div = $('<div>').addClass('col-dom-mercadoria item-nota-dom valor').text(' ');
        span = $('<span>').addClass('container-input-form-gw input-width-100').css('width', '90%').css('margin-top', '2px');
        input = $('<input>').attr('name', 'valorUnitario').attr('default', ',00').attr('onkeyup', 'atualizarTotais()').attr('type', 'text').addClass('input-form-gw').css('width', '89%').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val(parseFloat(vl_unitario).toFixed(2));
        $(input).focusout(verificarNulo);
        $(input).mask("#.##0,00", {reverse: true});
        span.append(input);
        div.append(span);
        container.append(div);

        div = $('<div>').addClass('col-dom-mercadoria col-dom-mercadorial-120 item-nota-dom total').text(' ');
        span = $('<span>').addClass('container-input-form-gw input-width-100 input-readonly-modal').css('width', '90%').css('margin-top', '2px');
        input = $('<input>').attr('name', 'total').attr('readonly', 'readonly').attr('type', 'text').addClass('input-form-gw input-readonly-modal').css('width', '89%').attr('data-gw-campo-grupo-serializado', 'dom-itens-nota' + '_' + '${param.count}' + '_' + c).val('0,00');
        $(input).mask("#.##0,00", {reverse: true});
        span.append(input);
        div.append(span);
        container.append(div);

        div = $('<div>').addClass('col-add-dom item-nota-dom col-dom-mercadorial-50 no-border-right');
        span = $('<span>').addClass('span-lixeira').css('margin-left', '10px');
        span.click(function () {
            chamarConfirm('Deseja excluir o item : ' + codigo + '?', 'excluir("' + $(container).attr('index') + '")');
        });
        div.append(span);
        container.append(div);
        $('[data=itens' + paramCount + ']').append(container);
        c++;
    }

    function excluir(e) {
        $('#container-dom' + e).hide();
        $('#isExcluido' + e).val('true');
    }

    function editarItemNota(obj) {
        var linha = $($(lastItem).parent().parent());
        linha.find('.codigo [name=idProduto]').val(obj.inputId);
        linha.find('.codigo [name=codigo]').val(obj.codigo);
        linha.find('.descricao input').val(obj.descricao);
    }

    function atualizarQtdAvaria(e) {
        let total = 0;
        $.each(($(e).parents('[data*="itens"]').find('[name="qtdAvariada"]')), function (i, e) {
            total += ($(e).val() ? parseFloat($(e).val()) : 0);
        });

        $('[data="total-avaria"]').text(total.toFixed(2).replace('.',','));
    }

    function atualizarValorItem(e) {
        let qtd = $(e).parents('.container-nota-item-dom').find('[name=qtdAvariada]').val();
        let vl_uni = String($(e).parents('.container-nota-item-dom').find('[name=valorUnitario]').val()).replace('.', '').replace(',', '.');
        $(e).parents('.container-nota-item-dom').find('[name=total]').val((qtd * vl_uni).toFixed(2).replace('.',','));
    }

    function atualizarTotais() {
        $.each($('[data*="itens"]'), function (index, itens) {

            let total_qtd_avariada = 0;
            let total_item = 0;
            $.each($(itens).find('[name="qtdAvariada"]'), function (index, qtd) {
                //Adicionando ao total para calcular tudo no final.
                total_qtd_avariada += parseFloat($(qtd).val().replace(',','.'));
                //Calculando total do item
                let vl_uni = String($(qtd).parents('.container-nota-item-dom').find('[name=valorUnitario]').val()).replace('.', '').replace(',', '.');
                let qtd_item = $(qtd).val().replace(',','.');
                $(qtd).parents('.container-nota-item-dom').find('[name=total]').val((qtd_item * vl_uni).toFixed(2).replace('.',','));
                total_item += vl_uni * qtd_item;
            });
            $(itens).parents('.item-dom-mercadoria-nota').find('[data="total-avaria"]').text(total_qtd_avariada.toFixed(2).replace('.',','));
            $(itens).parents('.item-dom-mercadoria-nota').find('[data="total"]').text(total_item.toFixed(2).replace('.',','));

        });
    }

    function verificarNulo() {
        if (!this.value.includes(',') && !this.value.includes('.')) {
            this.value = ((String(this.value).length <= 0 ? '0' : String(this.value)) + this.getAttribute('default'));
        }
    }

    function abrirLocalizarProduto(e) {
        lastItem = e;
        controlador.acao('abrirLocalizar', 'localizarProdutoRemetente');
    }

</script>