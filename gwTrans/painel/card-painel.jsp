<%-- 
    Document   : card-painel
    Created on : 31/12/2018, 11:35:47
    Author     : mateus
--%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<i class="details fa fa-info-circle" id="detail-${param['card[numero]']}"></i>
<i class="move fa fa-arrows-alt"></i>
<span class="tipo-card">${param['card[tipo]']}</span>
<ul style="width: 100%;">
    <li class="card-realizado">
        <label>${param['card[qtd_entregas]']}/${param['card[qtd_entregas_realizadas]']} (${param['card[porcentagem_entregas_realizadas]']}%)</label>
    </li>
    <li class="card-placa">
        <label>${param['card[placa]']}</label>
    </li>
    <li>
        <label>${param['card[nome_motorista]']}</label>
    </li>
    <li style="width: 50%;">
        <label>${param['card[tipo]'] == 'MAN' ? 'Manifesto: ' : 'Romaneio: '}${param['card[numero]']}</label>
    </li>
    <li style="width: 50%;text-align: right;">
        <label>${param['card[emissao_em]']}</label>
    </li>
    <li style="width: 50%;">
        <label>Cap.: ${param['card[capacidade_veiculo]']} Kg</label>
    </li>
    <li style="width: 50%;text-align: right;">
        <label>Peso: ${param['card[peso_carga]']} kg</label>
    </li>
    <li style="width: 100%;">
        <label>Ocupação: ${param['card[ocupacao]'].replace('.',',')}%</label>
    </li>
    <li style="width: 100%;">
        <label>Destino: ${param['card[cidade_destino]']} - ${param['card[uf_destino]']}</label>
    </li>
</ul>
<script>
    $('#detail-${param['card[numero]']}').click(() => {
        var card = {
            id: '${param['card[id]']}',
            tipo: '${param['card[tipo]']}',
            qtd_entregas: '${param['card[qtd_entregas]']}',
            qtd_entregas_realizadas: '${param['card[qtd_entregas_realizadas]']}',
            porcentagem_entregas_realizadas: '${param['card[porcentagem_entregas_realizadas]']}',
            placa: '${param['card[placa]']}',
            nome_motorista: '${param['card[nome_motorista]']}',
            numero: '${param['card[numero]']}',
            emissao_em: '${param['card[emissao_em]']}',
            capacidade_veiculo: '${param['card[capacidade_veiculo]']}',
            peso_carga: '${param['card[peso_carga]']}',
            cidade_destino: '${param['card[cidade_destino]']}',
            uf_destino: '${param['card[uf_destino]']}',
            filial: '${param['card[filial_abreviatura]']}',
            ocupacao: '${param['card[ocupacao]']}',
        };
        
        $('.container-mais-informacao').load('gwTrans/painel/detail-card-painel.jsp', {'card': card});
        $('.container-mais-informacao').show();
        $('.cobre-tudo').show();
    });
    
</script>