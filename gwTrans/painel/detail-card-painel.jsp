<%-- 
    Document   : detail-card-painel
    Created on : 07/01/2019, 17:14:13
    Author     : mateus
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<div class="head-detalhes">
    <img src="${homePath}/assets/img/logo.png" class="logo-gw-detalhes">
    <img src="${homePath}/assets/img/sair.png" class="sair-detalhes">
</div>
<div class="body-detalhes">
    <style>
        .cobre-detalhes{
            position: absolute;
            top: 140px;
            width: calc(100% - 18px);
            height: 460px;
            background: url(./img/espere_new.gif) no-repeat center rgba(255, 255, 255, 0.9);
            border-radius: 10px;
            z-index: 3;
        }
    </style>
    <div class="cobre-detalhes"></div>
    <div class="container-realizados">
        <label>${param['card[qtd_entregas]']}/${param['card[qtd_entregas_realizadas]']} (${param['card[porcentagem_entregas_realizadas]']}%)</label>
    </div>
    <div class="container-inf-head-detalhes">
        <ul>
            <li class="li-50 bg-cinza"><label>Nº ${param['card[tipo]'] == 'MAN' ? 'Manifesto: ' : 'Romaneio: '}</label><span>${param['card[numero]']}</span></li>
            <li class="li-50 bg-cinza"><label>${param['card[filial]']}</label></li>
            <li><label>Emissão: </label><span>${param['card[emissao_em]']}</span></li>
            <li class="li-50 bg-cinza"><label>Placa: </label><span>${param['card[placa]']}</span></li>
            <li class="li-50 bg-cinza"><label>Motorista: </label><span>${param['card[nome_motorista]']}</span></li>
            <li><label>Destino: </label><span>${param['card[cidade_destino]']} - ${param['card[uf_destino]']}</span></li>
            <li class="li-33 bg-cinza"><label>Capacidade: </label><span>${param['card[capacidade_veiculo]']} KG</span></li>
            <li class="li-33 bg-cinza"><label>Peso: </label><span>${param['card[peso_carga]']} KG</span></li>
            <li class="li-33 bg-cinza"><label>Ocupação: </label><span>${param['card[ocupacao]']}%</span></li>
        </ul>
    </div>
    <div class="container-title-tab">
        Entregas
    </div>
    <div class="container-inf-tab-detalhes">
        <div class="div-limit-table">
            <table class="table-dados" style="max-height: 170px;overflow: hidden;">
                <thead>
                    <tr>
                        <th width="6%">Nº CT-e</th>
                        <th width="8%">Filial</th>
                        <th width="4%">Tipo</th>
                        <th width="6%">Emissão</th>
                        <th width="15%">Cliente</th>
                        <th width="14%">Destinatário</th>
                        <th width="8%">Cidade / UF</th>
                        <th width="8%">Valor Carga</th>
                        <th width="7%">Peso</th>
                        <th width="6%">Cubagem</th>
                        <th width="8%">Valor CT-e</th>
                        <th width="8%">Realizada</th>
                    </tr>
                </thead>
                <tbody id="tbody-entregas">
                </tbody>
            </table>
        </div>
        <table class="table-dados tb-second-dados" >
            <tbody>
                <tr>
                    <td>Qtd. Entrega: <span id="qtd-entregas">0</span></td>
                </tr>
            </tbody>
        </table>
    </div>
    <c:if test="${param['card[tipo]'] == 'MAN' ? false : true}">
        <div class="container-title-tab">
            Coletas
        </div>
        <div class="container-inf-tab-detalhes">
            <div class="div-limit-table">
                <table class="table-dados" style="max-height: 170px;overflow: hidden;">
                    <thead>
                        <tr>
                            <th width="8%">Nº Coleta</th>
                            <th width="6%">Filial</th>
                            <th width="4%">Emissão</th>
                            <th width="28%">Remetente</th>
                            <th width="8%">Cidade / UF</th>
                            <th width="28%">Destinatário</th>
                            <th width="7%">Valor</th>
                            <th width="7%">Peso</th>
                            <th width="4%">Realizada</th>
                        </tr>
                    </thead>
                    <tbody id="tbody-coleta">
                    </tbody>
                </table>
            </div>
            <table class="table-dados tb-second-dados" >
                <tbody>
                    <tr>
                        <td>Qtd. Coleta: <span id="qtd-coletas">0</span></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </c:if>
    <script>
        $('.cobre-tudo, .sair-detalhes').on('click', () => {
            jQuery('.cobre-tudo').hide();
            jQuery('.container-mais-informacao').hide();
        });

        function getDetails(id, tipo) {
            $.ajax({
                url: 'PainelControlador',
                method: 'GET',
                data: {
                    acao: 'getDetails',
                    id: id,
                    tipo: tipo
                },
                complete: function (jqXHR, textStatus) {
                    var arr = jqXHR.responseText;
                    if (arr !== 'null') {
                        var json = JSON.parse(arr);
                        if (tipo == 'MAN') {
                            $.each(json, (index, element) => {
                                montarTrMan(element)
                            });
                        } else {
                            $.each(json, (index, element) => {
                                montarTrRom(element);
                            });
                        }
                        $('#qtd-entregas').text(json.filter(obj => obj.tipo !== 'COLETA').length);
                        $('#qtd-coletas').text(json.filter(obj => obj.tipo === 'COLETA').length);
                    }
                    $('.cobre-detalhes').hide('clip', 500);
                }
            });
        }

        function montarTrMan(obj) {
            var tr = $('<tr>'), td;
            td = $('<td class="text-link">').text(obj.numero);
            td.on('click', () => {
                verCtrc(obj.id_cte)
            });
            tr.append(td);
            td = $('<td>').text(obj.abreviatura);
            tr.append(td);
            td = $('<td>').text(obj.tipo_do_conhecimento);
            tr.append(td);
            var dt = obj.emissao_em.split('-');
            td = $('<td>').text(dt[2] + '/' + dt[1] + '/' + dt[0]);
            tr.append(td);
            td = $('<td>').text(obj.cliente);
            tr.append(td);
            td = $('<td>').text(obj.destinatario);
            tr.append(td);
            td = $('<td>').text(obj.cidade);
            tr.append(td);
            td = $('<td>').text(obj.valor);
            tr.append(td);
            td = $('<td>').text(obj.peso);
            tr.append(td);
            td = $('<td>').text(obj.cubagem);
            tr.append(td);
            td = $('<td>').text(obj.total_receita);
            tr.append(td);
            td = $('<td>').text(obj.realizada);
            tr.append(td);
            $('#tbody-entregas').append(tr);
        }

        function montarTrRom(obj) {
            if (obj.tipo === 'COLETA') {
                var tr = $('<tr>'), td;
                td = $('<td class="text-link">').text(obj.numero);
                td.on('click', () => {
                    verColeta(obj.idmovimento);
                });
                tr.append(td);
                td = $('<td>').text(obj.filial);
                tr.append(td);
                var dt = obj.dtemissao.split('-');
                td = $('<td>').text(dt[2] + '/' + dt[1] + '/' + dt[0]);
                tr.append(td);
                td = $('<td>').text(obj.remetente);
                tr.append(td);
                td = $('<td>').text(obj.cidade_uf_destino);
                tr.append(td);
                td = $('<td>').text(obj.destinatario);
                tr.append(td);
                td = $('<td>').text(obj.valor_nf);
                tr.append(td);
                td = $('<td>').text(obj.peso);
                tr.append(td);
                td = $('<td>').text(obj.realizada);
                tr.append(td);
                $('#tbody-coleta').append(tr);
            } else {
                var tr = $('<tr>'), td;
                td = $('<td class="text-link">').text(obj.numero);
                td.on('click', () => {
                    verCtrc(obj.idmovimento);
                });
                tr.append(td);
                td = $('<td>').text(obj.filial);
                tr.append(td);
                td = $('<td>').text(obj.tipo);
                tr.append(td);
                var dt = obj.dtemissao.split('-');
                td = $('<td>').text(dt[2] + '/' + dt[1] + '/' + dt[0]);
                tr.append(td);
                td = $('<td>').text(obj.remetente);
                tr.append(td);
                td = $('<td>').text(obj.destinatario);
                tr.append(td);
                td = $('<td>').text(obj.cidade_uf_destino);
                tr.append(td);
                td = $('<td>').text(obj.valor_nf);
                tr.append(td);
                td = $('<td>').text(obj.peso);
                tr.append(td);
                td = $('<td>').text(obj.cubagem);
                tr.append(td);
                td = $('<td>').text(obj.total_receita);
                tr.append(td);
                td = $('<td>').text(obj.realizada);
                tr.append(td);
                $('#tbody-entregas').append(tr);

            }
            
        }

        function verCtrc(id) {
            window.open("./frameset_conhecimento?acao=editar&id=" + id + "&ex=false", "Conhecimento", "top=0,resizable=yes");
        }
        
        function verColeta(id){
            window.open('./cadcoleta.jsp?acao=editar&id='+id+'&ex=false', 'Coleta' , 'top=0,resizable=yes,status=1,scrollbars=1');
        }

        getDetails('${param['card[id]']}', '${param['card[tipo]']}');
    </script>
</div>