/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Objeto criado para facilitar o calculo dos impostos referentes a serviços
 */
function ImpostoServico(valorServico, aliquota, idTaxa, qtdDias, descricao){
    this.qtdDias = parseFloat(qtdDias == null || qtdDias == undefined) ? 1 : qtdDias;
    this.descricao = (descricao == null || descricao == undefined) ? "" : descricao;
    this.valorServico = parseFloat((valorServico == null || valorServico == undefined) ? 0:valorServico);    
    this.aliquota = parseFloat((aliquota == null || aliquota == undefined) ? 0:aliquota);
    this.idTaxa = (idTaxa == null || idTaxa == undefined) ? 1 : idTaxa;
    this.valor = this.idTaxa == 4 ? 0 : (this.valorServico * this.qtdDias * (this.aliquota/100));
    this.valorRetido = this.idTaxa == 4  ? (this.valorServico * this.qtdDias* (this.aliquota/100)):0;
}