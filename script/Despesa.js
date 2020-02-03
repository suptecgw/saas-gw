/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function Despesa(id, tipo, especie, especieId, serie, nf, data, venc, idFornecedor, fornecedor, idHistorico, historico, valor, doc, idConta, isCheque, index){
    //validação
    this.index=(index==null || index==undefined?0:index);
    this.id=(id==null || id==undefined?"0":id);
    this.tipo=(tipo==null || tipo==undefined?"":tipo);
    this.especie=(especie==null || especie==undefined?"":especie);
    this.especieId=(especieId==null || especieId==undefined?0:especieId);
    this.serie=(especie==null || serie==undefined?"":serie);
    this.nf=(nf==null || nf==undefined?"":nf);
    this.data=(data==null || data==undefined?"":data);
    this.venc=(venc==null || venc==undefined?"":venc);
    this.idFornecedor=(idFornecedor==null || idFornecedor==undefined?0:idFornecedor);
    this.fornecedor=(fornecedor==null || fornecedor==undefined?"":fornecedor);
    this.historico=(historico==null || historico==undefined?"":historico);
    this.idHistorico=(idHistorico==null || idHistorico==undefined?0:idHistorico);
    this.valor=(valor==null || valor==undefined?0:valor);
    this.doc=(doc==null || doc==undefined?"":doc);
    this.idConta=(idConta==null || idConta==undefined?0:idConta);    
    this.isCheque=(isCheque==null || isCheque==undefined?false:isCheque);    
}
