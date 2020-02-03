/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function AWB(id, valor, numeroAWB, movimento, numeroVoo, dataEmissao, cidadeOrigem, cidadeOrigemId, cidadeDestino, cidadeDestinoId){
    this.id = (id == null || id== undefined ? 0 : id);
    this.valor = (valor == null || valor== undefined ? 0 : valor);
    this.movimento = (movimento == null || movimento== undefined ? 0 : movimento);
    this.numeroAWB = (numeroAWB == null || numeroAWB== undefined ? 0 : numeroAWB);
    this.numeroVoo = (numeroVoo == null || numeroVoo== undefined ? 0 : numeroVoo);
    this.dataEmissao = (dataEmissao == null || dataEmissao== undefined ? 0 : dataEmissao);
    this.cidadeOrigem = (cidadeOrigem == null || cidadeOrigem== undefined ? "" : cidadeOrigem);
    this.cidadeOrigemId = (cidadeOrigemId == null || cidadeOrigemId== undefined ? 0 : cidadeOrigemId);
    this.cidadeDestino = (cidadeDestino == null || cidadeDestino== undefined ? "" : cidadeDestino);
    this.cidadeDestinoId = (cidadeDestinoId == null || cidadeDestinoId== undefined ? "" : cidadeDestinoId);
}
