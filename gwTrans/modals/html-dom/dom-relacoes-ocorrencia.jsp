
<%-- 
    Document   : dom-relacoes-ocorrencia
    Created on : 14/06/2018, 16:37:54
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<div class="container-relacoes-ocorrencia" data-gw-grupo-name="dom-item-relacoes" data-gw-grupo-serializado="dom-item-relacoes${param.count}">
    <div class="col-add-dom item-nota-dom">
    </div>
    <div class="col-dom-mercadoria col-dom-mercadorial-270 item-nota-dom">
        <label data="data-ocorrencia"></label>
        <span class="container-input-form-gw input-width-95">
            <input class="input-form-gw input-width-100" type="text" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="dataR${param.count}" id="dataR${param.count}" value="${cg:getDataAtual()}">
        </span>
        <span class="container-input-form-gw input-width-60 margin-left-40">
            <input class="input-form-gw input-width-100" type="text" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="hora" id="hora${param.count}">
        </span>
    </div>
    <div class="col-dom-mercadoria col-dom-mercadorial-150 item-nota-dom">
        <label data="contato-ocorrencia"></label>
        <span class="container-input-form-gw input-width-100">
            <input class="input-form-gw input-width-100" type="text" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="contato" id="contato${param.count}">
        </span>
    </div>
    <div class="col-dom-mercadoria item-nota-dom col-dom-mercadoria-125">
        <label data="fone-ocorrencia"></label>
        <span class="container-input-form-gw input-width-100">
            <input class="input-form-gw input-width-100" type="text" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="fone" id="fone${param.count}">
        </span>
    </div>
    <div class="col-dom-mercadoria col-dom-mercadoria-150 item-nota-dom">
        <label data="observacao-ocorrencia"></label>
        <span class="container-input-form-gw input-width-100">
            <input class="input-form-gw input-width-100" type="text" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="observacao" id="observacao${param.count}">
        </span>
    </div>
    <div class="col-dom-mercadoria item-nota-dom">
        <label data="usuario-ocorrencia" id="usuario${param.count}" name="usuario${param.count}"></label>
        <!--<span class="container-input-form-gw input-width-100">-->
            <!--<input class="input-form-gw input-width-100" type="text" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="usuario" id="usuario${param.count}">-->
        <input type="hidden" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="idUsuario" id="idUsuario${param.count}" value="${sessionScope.usuario.idusuario}">
        <input type="hidden" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="idRelacionamento" id="idRelacionamento${param.count}" value="0">
        <input type="hidden" data-gw-campo-grupo-serializado="dom-item-relacoes${param.count}" data-type="text" name="isExcluido" id="isExcluido${param.count}" value="false">
        <!--</span>-->
    </div>
    <div class="col-dom-mercadoria col-dom-mercadoria-25 no-border-right item-nota-dom">
        <span class="span-lixeira" onclick="chamarApagarItemRelacoes(${param.count});"></span>
    </div>
</div>
<script>
    $(function () {
        $('#dataR${param.count}').gwDatebox({
            'icone_classe': 'combo-arrow-escuro-cte-auditoria',
            'funcao_apos_criacao': function (elemento) {
                elemento.parent().find('.datebox').css('width', '93%');
                elemento.parent().find('.textbox-text').css('width', '93%').css('font-size', '14px');
                
            }
        });

        //se for é carregando
        $('#hora${param.count}').mask('00:00', {placeholder: '__:__'});
        if ('${param.acao}' === 'carregando') {
            var json_relacionamentos = JSON.parse(sessionStorage.getItem('jsonRelacionamentos' + '${param.count}'));
            sessionStorage.removeItem('jsonRelacionamentos' + '${param.count}');
            var hr = converterTimeStamp(json_relacionamentos.data).split(' ')[1];
            if (hr === '00:00') {
                hr = '';
            }

            $('#dataR${param.count}').val(converterTimeStamp(json_relacionamentos.data).split(' ')[0]);
            $('#hora${param.count}').val(hr);
            $('#contato${param.count}').val(json_relacionamentos.contato);
            $('#fone${param.count}').val(json_relacionamentos.fone);
            $('#observacao${param.count}').val(json_relacionamentos.observacao);
            $('#usuario${param.count}').html(json_relacionamentos.nome);
            $('#idUsuario${param.count}').val(json_relacionamentos.idusuario);
            $('#idRelacionamento${param.count}').val(json_relacionamentos.id_relacionamento);
        }
    });

    function chamarApagarItemRelacoes(e) {
        chamarConfirm('Deseja excluir o relacionamento?', 'apagarItemRelacoes(' + e + ')');
    }

    function apagarItemRelacoes(e) {
        $('[data-gw-grupo-serializado=dom-item-relacoes' + e + ']').hide();
        $("#isExcluido${param.count}").val("true");
    }

    function converterTimeStamp(timeStamp) {
        let split = timeStamp.split("T");

        let d = split[0].split(/\D/g);
        let h = split[1].split(":");
        let data = [d[2], d[1], d[0]].join("/");
        let hora = [h[0], h[1]].join(":");
        return data + ' ' + hora;
    }

</script>