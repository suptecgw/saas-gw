/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function ContratoFreteDocumento(id, numero, serie, data, origem,destino, qtd, peso, valorFrete, tipo, origemId, 
    destinoId, valorNota, volumes, clienteId, qtdEntregas, isMostraRotaCliente, valorFreteCte, valorPesoCte, clienteNegociacao, filialOrigem, filialDestino, totalCteCIF, totalCteFOB, totalCteTerceiro, totalFilialPagamento, idFilialDestino,
                                valorPedagio){
    //validação
    this.id=(id==null || id==undefined?"0":id);
    this.numero=(numero==null || numero==undefined?"":numero);
    this.serie=(serie==null || serie==undefined?"":serie);
    this.data=(data==null || data==undefined?"":data);
    this.origem=(origem==null || origem==undefined?"":origem);
    this.destino=(destino==null || destino==undefined?"":destino);
    this.qtd=(qtd==null || qtd==undefined?"":qtd);
    this.peso=(peso==null || peso==undefined?"":peso);
    this.tipo=(tipo==null || tipo==undefined?"":tipo);
    this.valorFrete=(valorFrete==null || valorFrete==undefined?"0":valorFrete);
    this.origemId=(origemId==null || origemId==undefined?"0":origemId);
    this.destinoId=(destinoId==null || destinoId==undefined?"0":destinoId);
    this.valorNota=(valorNota==null || valorNota==undefined?"0":valorNota);
    this.volumes=(volumes==null || volumes==undefined?"0":volumes);
    this.clienteId=(clienteId==null || clienteId==undefined?"0":clienteId);
    this.qtdEntregas=(qtdEntregas==null || qtdEntregas==undefined?"0":qtdEntregas);
    this.isMostraRotaCliente=(isMostraRotaCliente==null || isMostraRotaCliente==undefined?false:isMostraRotaCliente);
    this.valorFreteCte = (valorFreteCte == null || valorFreteCte == undefined ? "0" : valorFreteCte);
    this.valorPesoCte = (valorPesoCte == null || valorPesoCte == undefined ? "0" : valorPesoCte);
    this.clienteNegociacao = (clienteNegociacao == null || clienteNegociacao == undefined ? "0" : clienteNegociacao);
    this.filialOrigem = (filialOrigem == null || filialOrigem == undefined ? "0" : filialOrigem);
    this.idFilialDestino = (idFilialDestino == null || idFilialDestino == undefined ? "0" : idFilialDestino);
    this.filialDestino = (filialDestino == null || filialDestino == undefined ? "0" : filialDestino);
    this.totalCteCIF = (totalCteCIF == null || totalCteCIF == undefined ? "0" : totalCteCIF);
    this.totalCteFOB = (totalCteFOB == null || totalCteFOB == undefined ? "0" : totalCteFOB);
    this.totalCteTerceiro = (totalCteTerceiro == null || totalCteTerceiro == undefined ? "0" : totalCteTerceiro);
    this.totalFilialPagamento = (totalFilialPagamento == null || totalFilialPagamento == undefined ? "0" : totalFilialPagamento);
    this.valorPedagio = (valorPedagio == null || valorPedagio == undefined ? "0" : valorPedagio);
    
    
    
    
}
