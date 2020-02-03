/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function Rota(id, descricao, origem, ufOrigem, origemId, destino, ufDestino, destinoId, distancia, prazoEntrega, tipoPrazoEntrega, vlDiariaMotorista, vlPernoiteMotorista, vlAlimentacaoMotorista, tipoRota, areaDestinoId, areaDestino, isRotaColeta, isRotaTransferencia, isRotaEntrega, isRotaAtiva, codigoIntegracaoPedagio, codigoSolicitacaoMonitoramento, prazoEntregaHora){
    //validação
    this.id=(id==null || id==undefined?"0":id);
    this.descricao=(descricao==null || descricao==undefined?"":descricao);
    this.origem=(origem==null || origem==undefined?"":origem);
    this.ufOrigem=(ufOrigem==null || ufOrigem==undefined?"":ufOrigem);
    this.origemId=(origemId==null || origemId==undefined?"0":origemId);
    this.destino=(destino==null || destino==undefined?"":destino);
    this.ufDestino=(ufDestino==null || ufDestino==undefined?"":ufDestino);
    this.destinoId=(destinoId==null || destinoId==undefined?"0":destinoId);
    this.distancia=(distancia==null || distancia==undefined?"0":distancia);
    this.prazoEntrega=(prazoEntrega==null || prazoEntrega==undefined?"0":prazoEntrega);
    this.tipoPrazoEntrega=(tipoPrazoEntrega==null || tipoPrazoEntrega==undefined?"U":tipoPrazoEntrega);
    this.vlDiariaMotorista=(vlDiariaMotorista==null || vlDiariaMotorista==undefined?"0,00":vlDiariaMotorista);
    this.vlPernoiteMotorista=(vlPernoiteMotorista==null || vlPernoiteMotorista==undefined?"0,00":vlPernoiteMotorista);
    this.vlAlimentacaoMotorista=(vlAlimentacaoMotorista==null || vlAlimentacaoMotorista==undefined?"0,00":vlAlimentacaoMotorista);
    this.tipoRota=(tipoRota==null || tipoRota==undefined?"c":tipoRota);
    this.areaDestinoId=(areaDestinoId==null || areaDestinoId==undefined?"0":areaDestinoId);
    this.areaDestino=(areaDestino==null || areaDestino==undefined?"":areaDestino);
    this.isRotaColeta=(isRotaColeta==null || isRotaColeta==undefined?true:isRotaColeta);
    this.isRotaTransferencia=(isRotaTransferencia==null || isRotaTransferencia==undefined?true:isRotaTransferencia);
    this.isRotaEntrega=(isRotaEntrega==null || isRotaEntrega==undefined?true:isRotaEntrega);
    this.isRotaAtiva=(isRotaAtiva==null || isRotaAtiva==undefined?true:isRotaAtiva);
    this.codigoIntegracaoPedagio=(codigoIntegracaoPedagio==null || codigoIntegracaoPedagio==undefined?"":codigoIntegracaoPedagio);
    this.codigoSolicitacaoMonitoramento = (codigoSolicitacaoMonitoramento == null || codigoSolicitacaoMonitoramento == undefined ? 0 : codigoSolicitacaoMonitoramento);
    this.prazoEntregaHora = (prazoEntregaHora == null || prazoEntregaHora == undefined ? 0 : prazoEntregaHora);

}
