/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function pegarImgPessoaJuridica(homePath){
    new Ajax.Request(homePath+"/SituacaoPessoaControlador?acao=iniciarConsultarPessoaJuridica",
    {
        method:'get',
        onSuccess: function(transport){
            alert(transport.responseText);
            alert("Olha o log!");
        },
        onFailure: function(){alert("Ocorreu algum erro ao pegar a imagem!");}
    });
}

function CamposSituacaoPessoa(
    idRazaoSocial
    , idNomeFantasia
    , idCNPJ
    , idLogradouro
    , idLogradouroNumero
    , idComplemento
    , idCep
    , idBairro
    , municipio
    , uf
){
    this.idRazaoSocial = (idRazaoSocial == null || idRazaoSocial == undefined ? "" : idRazaoSocial);
    this.idNomeFantasia = (idNomeFantasia == null || idNomeFantasia == undefined ? "" : idNomeFantasia);
    this.idCNPJ = (idCNPJ == null || idCNPJ == undefined ? "" : idCNPJ);
    this.idLogradouro = (idLogradouro == null || idLogradouro == undefined ? "" : idLogradouro);
    this.idLogradouroNumero = (idLogradouroNumero == null || idLogradouroNumero == undefined ? "" : idLogradouroNumero);
    this.idComplemento = (idComplemento == null || idComplemento == undefined ? "" : idComplemento);
    this.idCep = (idCep == null || idCep == undefined ? "" : idCep);
    this.idBairro = (idBairro == null || idBairro == undefined ? "" : idBairro);
    this.idCidade = (municipio == null || municipio == undefined ? "" : municipio);
    this.idUf = (uf == null || uf == undefined ? "" : uf);
    
    this.toStr = function(){
        try{
            return "({idRazaoSocial:\""+this.idRazaoSocial
            +"\", idNomeFantasia:\""+this.idNomeFantasia
            +"\", idCNPJ:\""+this.idCNPJ
            +"\", idLogradouro:\""+this.idLogradouro
            +"\", idLogradouroNumero:\""+this.idLogradouroNumero
            +"\", idComplemento:\""+this.idComplemento
            +"\", idCep:\""+this.idCep
            +"\", idCidade:\""+this.idCidade
            +"\", idUf:\""+this.idUf
            +"\", idBairro:\""+this.idBairro+"\"})";
        }catch(e){
            alert(e);
        }
    };
}
