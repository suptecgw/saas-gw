
//Visualizar os dados da nota fiscal
function visualizarNota(idNotaFiscal) {
    if (idNotaFiscal != 0) {
        window.open("NotaFiscalControlador?acao=carregar&idNota=" + idNotaFiscal + "&visualizar=true",
                "visualizarNota", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
    } else {
        alert("Nota fiscal ainda não foi salva!");
    }
}

//Abrir tela de importacao de XML e/ou DANFE
function abrirPopImport() {
    tryRequestToServer(function () {
        var url = "ConhecimentoControlador?acao=novaImportacao&tipoImportacao=unico&filialId=" + $("idfilial").value
                + "&ufFilial=" + $("fi_uf").value;
        window.open(url, 'importarCtrcNFe', 'width=1000, height=700,scrollbars=1');
    });
}

function abrirPopAuditoria() {
    tryRequestToServer(function () {
        var url = "ConhecimentoControlador?acao=auditoriacte&idConhecimento=" + $("idConhecimento").value;
        window.open(url, 'auditoriaCte', 'toolbar=no,left=0,top=0,location=no,status=no,menubar=no,scrollbars=yes,resizable=no');
    });
}

//Localizar CFOP
function localizacfop() {
    post_cad = window.open('./localiza?acao=consultar&idlista=2', 'cfop',
            'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

//Localizar Endereco Entrega
function localizaEndereco() {
    var dest_id = $('iddestinatario').value;
    if (dest_id == "0") {
        alert("Informe o Destinatario!");
    } else {
        popLocate(71, "Endereço_Entrega", "", "paramaux=" + $('iddestinatario').value);
    }
}

//Localizar Endereco Coleta
function localizaEnderecoColeta() {
    var remet_id = $('idremetente').value;
    if (remet_id == "0") {
        alert("Informe o Remetente!");
    } else {
        popLocate(76, "Endereco_Coleta", "", "paramaux=" + remet_id);
    }
}

//Exportar o XML do CT-e
function popXml(idCte, chaveAcesso, isCanc) {
    if (idCte == null)
        return null;
    window.open("./" + chaveAcesso + "-cte.xml?acao=gerarXmlCliente&idCte=" + idCte + "&isCanc=" + isCanc, "xmlCTe" + idCte, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
}

//Voltar para tela de consulta
function consulta() {
    tryRequestToServer(function () {
        parent.document.location.replace("./consultaconhecimento?acao=iniciar")
    });
}

//Excluir CTRC
function excluirconhecimento(idmovimento) {
    if (confirm("Deseja mesmo excluir este conhecimento de transporte?"))
        parent.document.location.replace("./consultaconhecimento?acao=excluir&id=" + idmovimento);
}

////Localizar CTRC para ser aproveitado
//function localizaCtrc(isCancelado) {
//    var tipoConhecimento = $("tipoConhecimento").value;
//    tryRequestToServer(function() {
//        window.open('./pops/localiza_conhecimento.jsp?acao=consultar&tipoConhecimento=' + tipoConhecimento + '&isCancelado=' + isCancelado, 'CTRC',
//                'top=80,left=50,height=400,width=900,resizable=yes,status=1,scrollbars=1')
//    });
//}


//Localizar CTRC para ser aproveitado
var windowCtrc = null;
function localizaCtrc(isCancelado) {
    var tipoConhecimento = $("tipoConhecimento").value;
    var filialId = $("idfilial").value;

    windowCtrc = window.open('./pops/localiza_conhecimento.jsp?acao=iniciar&tipoConhecimento=' + tipoConhecimento + '&isCancelado=' + isCancelado + '&filialId=' + filialId, 'CTRC',
            'top=80,left=50,height=400,width=900,resizable=yes,status=1,scrollbars=1');
    return windowCtrc;
}

//Limpar dados do destinatario
function limpaDestinatarioCodigo() {
    $('iddestinatario').value = '0';
    $('des_codigo').value = '';
    $('dest_rzs').value = '';
    $('dest_cidade').value = '';
    $('dest_uf').value = '';
    $('dest_cnpj').value = '';
    $('dest_pgt').value = '0';
    $('dest_tipotaxa').value = '-1';
    $('idvendestinatario').value = '0';
    $('vendestinatario').value = '0';
    $('vlvendestinatario').value = '0';
    $('desttipofpag').value = 'v';
    $('aliquota').value = '0';
    $('obs_desc').value = '';
    $('desttipoorigem').value = 'r';
    $('desttabelaproduto').value = 'f';
    $('reducao_base_icms').value = '0.00';
    $('dest_endereco').value = '';
    $('des_analise_credito').value = 'f';
    $('des_valor_credito').value = '0';
    $('des_is_bloqueado').value = 'f';
    $('des_tabela_remetente').value = 'n';
    $('des_inclui_tde').value = 'f';
    $('pauta_destinatario').value = 'f';
    $('des_inclui_peso_container').value = 'f';
    $('des_st_icms').value = '0';
    $('dest_insc_est').value = '';
    $("des_reducao_icms").value = "0";
    $("des_is_in_gsf_598_03_go").value = "f";
}

function limpaColeta() {
    $("numcoleta").innerHTML = "";
    $("idcoleta").value = "0";
    $("coleta").value = "";
    $("entrega").value = "";
}

function limpaRedespachante(tipo) {

    switch (tipo) {
        case "e":
            $('repr_entrega_id').value = "";
            $('repr_entrega').value = "";
            $('repr_entrega_vlsobfrete').value = "";
            $('repr_entrega_vlfreteminimo').value = "";
            $('repr_entrega_vlsobpeso').value = "";
            $('repr_entrega_vlkgate').value = "";
            $('repr_entrega_vlprecofaixa').value = "";
            $('repr_entrega_valor').value = "0.00";
            $('repr_entrega_tipo_taxa').value = "2";
            break;
        case "c":
            $('repr_coleta_id').value = "";
            $('repr_coleta').value = "";
            $('repr_coleta_vlsobfrete').value = "";
            $('repr_coleta_vlfreteminimo').value = "";
            $('repr_coleta_vlsobpeso').value = "";
            $('repr_coleta_vlkgate').value = "";
            $('repr_coleta_vlprecofaixa').value = "";
            $('repr_coleta_valor').value = "0.00";
            $('repr_coleta_tipo_taxa').value = "2";
            break;
        case "c2":
            $('repr_coleta2_id').value = "";
            $('repr_coleta2').value = "";
            $('repr_coleta2_valor').value = "0.00";
            break;
        case "e2":
            $('repr_entrega2_id').value = "";
            $('repr_entrega2').value = "";
            $('repr_entrega2_valor').value = "0.00";
            break;
    }
}

function limpaVendedor() {
    $("idvendedor").value = "0";
    $("ven_rzs").value = "";
}

function limpaRemetenteCodigo() {
    $('idremetente').value = '0';
    $('rem_codigo').value = '';
    $('rem_rzs').value = '';
    $('rem_cidade').value = '';
    $('rem_uf').value = '';
    $('rem_cnpj').value = '';
    $('rem_pgt').value = '0';
    $('rem_tipotaxa').value = '-1';
    $('idvenremetente').value = '0';
    $('venremetente').value = '';
    $('idcidadeorigem').value = '0';
    $('vlvenremetente').value = '0';
    $('remtipofpag').value = 'v';
    $('remtipoorigem').value = 'r';
    $('rem_endereco').value = '';
    $('remtabelaproduto').value = 'f';
    $('rem_analise_credito').value = 'f';
    $('rem_valor_credito').value = '0';
    $('rem_is_bloqueado').value = 'f';
    $('rem_tabela_remetente').value = 'n';
    $('pauta_remetente').value = 'f';
    $('rem_inclui_peso_container').value = 'f';
    $('rem_st_mg').value = 'f';
    $('rem_st_icms').value = "0";
    $("rem_reducao_icms").value = "0";
    $("rem_is_in_gsf_598_03_go").value = "f";
//    Limpando também os dados consignatário
    $('idconsignatario').value = '0';
    $('con_rzs').value = '';
    $('con_codigo').value = '';
    $('con_cidade').value = '';
    $('con_uf').value = '';
    $('con_cnpj').value = '';

}
/**
 *Sempre que alterar alguam coisa nessa funcao, deve ser revista a rotina de importacao de chave de acesso
 */

function replaceAllCnpj(cnpj) {



}

function localizaRemetenteCodigo(campo, valor, isAlteraTipoTaxa) {
    try{
    isAlteraTipoTaxa = (isAlteraTipoTaxa == null || isAlteraTipoTaxa == undefined ? true : isAlteraTipoTaxa);
    if (campo == 'cnpj') {
        valor = valor.replace(".", "").replace(".", "").replace("/", "").replace("-", "");
    }

    if (isBloqueaAlteracao) {
        return null;
    }
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport) {
        var resp = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (resp == 'null') {
            alert('Erro ao localizar cliente.');
            return false;
        } else if (resp == 'INA') {
            limpaRemetenteCodigo();
            alert('Cliente inativo.');
            return false;
        } else if (resp == '') {
            limpaRemetenteCodigo();
            if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
            }
            return false;
        } else {

            var cliControl = eval('(' + resp + ')');
            $('idremetente').value = cliControl.idcliente;
            $('rem_codigo').value = cliControl.idcliente;
            $('rem_rzs').value = cliControl.razao;
            $('rem_cidade').value = cliControl.cidade;
            $('rem_uf').value = cliControl.uf;
            $('rem_cnpj').value = cliControl.cnpj;
            $('rem_pgt').value = cliControl.pgt;
            $('rem_tipotaxa').value = cliControl.tipotaxa;
            $('idvenremetente').value = cliControl.idvendedor;
            $('venremetente').value = cliControl.vendedor;
            $('idcidadeorigem').value = cliControl.idcidade;
            $('vlvenremetente').value = cliControl.vlvendedor;
            $('rem_unificada_modal_vendedor').value = cliControl.unificada_modal_vendedor;
            $('rem_comissao_rodoviario_fracionado_vendedor').value = cliControl.comissao_rodoviario_fracionado_vendedor;
            $('rem_comissao_rodoviario_lotacao_vendedor').value = cliControl.comissao_rodoviario_lotacao_vendedor;
            $('remtipofpag').value = cliControl.tipofpag;
            $('remtipoorigem').value = cliControl.tipo_origem_frete;
            $('rem_endereco').value = cliControl.endereco_cliente;
            $('remtabelaproduto').value = cliControl.is_tabela_apenas_produto;
            $('rem_analise_credito').value = cliControl.is_analise_credito;
            $('rem_valor_credito').value = cliControl.valor_credito;
            $('rem_is_bloqueado').value = cliControl.is_bloqueado;
            $('rem_tabela_remetente').value = cliControl.tipo_tabela_remetente;
            $('id_rota_viagem').value = cliControl.id_rota_viagem;
            $('rota_viagem').value = cliControl.rota_viagem;
            $('distancia_km').value = cliControl.distanciakm;
            $('prazo_rota').value = cliControl.prazo_rota;
            $('tipo_prazo_rota').value = cliControl.tipo_prazo_rota;
            $('taxa_roubo').value = cliControl.taxa_roubo;
            $('taxa_roubo_urbano').value = cliControl.taxa_roubo_urbano;
            $('taxa_tombamento').value = cliControl.taxa_tombamento;
            $('taxa_tombamento_urbano').value = (cliControl.taxa_tombamento_urbano != undefined ? cliControl.taxa_tombamento_urbano : "0");
            $('pauta_remetente').value = cliControl.is_utiliza_pauta_fiscal;
            $('rem_inclui_peso_container').value = cliControl.is_acrescenta_peso_container;
            $('rem_tipo_cfop').value = cliControl.tipo_cfop;
            $('rem_st_icms').value = cliControl.st_icms;
            $('rem_obs').value = cliControl.obs;
            $('rem_st_mg').value = cliControl.st_mg;
            $("utilizatipofretetabelarem").value = cliControl.is_utilizar_tipo_frete_tabela;
            $("is_utilizar_tipo_frete_tabela").value = cliControl.is_utilizar_tipo_frete_tabela;
            //será utilizado para gerar o hash, quando o usuario precisa da autorização do supervisor.
            $("codigo_ibge_origem").value = cliControl.cod_ibge;
            $("cod_ibge").value = cliControl.cod_ibge;
            $("st_icms").value = cliControl.st_icms;
            $("rem_st_icms").value = cliControl.st_icms;
            $("rem_reducao_icms").value = cliControl.reducao_icms;
            $("rem_is_in_gsf_598_03_go").value = cliControl.is_in_gsf_598_03_go;
            $("rem_is_in_gsf_1298_16_go").value = cliControl.is_in_gsf_1298_16_go;
            $('st_rem_credito_presumido').value = cliControl.percentual_credito_presumido;
            $("mensagem_usuario_cte_rem").value = cliControl.mensagem_usuario_cte === null || cliControl.mensagem_usuario_cte === undefined ? "" : cliControl.mensagem_usuario_cte;
            $("tipo_arredondamento_peso_rem").value = cliControl.tipo_arredondamento_peso === null || cliControl.tipo_arredondamento_peso === undefined ? "n" : cliControl.tipo_arredondamento_peso;
            $("rem_insc_est").value = cliControl.incricao_estadual;
            $("lbRemetenteIE").innerHTML = cliControl.incricao_estadual;
            $("is_frete_dirigido").value = cliControl.is_frete_dirigido;
            $("rem_tipo_tributacao").value = cliControl.tipo_tributacao;
            $("rem_obs_fisco").value = cliControl.obs_fisco;
            $("rem_is_especie_serie_modal").value = cliControl.is_especie_serie_modal;
            $("rem_especie_cliente").value = cliControl.especie_cliente;
            $("rem_serie_cliente").value = cliControl.serie_cliente;
            $("rem_modal_cliente").value = cliControl.modal_cliente;
            aoClicarNoLocaliza('Remetente', isAlteraTipoTaxa);
            //o campo abaixo deve ficar abaixo do "aoclicarnolocaliza" caso contrario sera substituido;
            $('tipoPadraoDocumento').value = cliControl.documentoPadrao;
            if (campo == 'c.razaosocial') {
                getObj('dest_rzs').focus();
            }else{
                getObj('dest_cnpj').focus();
            }
            if(cliControl.json_taxas){
                $("json_taxas").value = cliControl.json_taxas;
            }
        }
    }//funcao e()

    if (valor != '') {
        ufRemetenteAnterior = $('rem_uf').value;
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial="+$('idfilial').value+"&destUF=" + $('dest_uf').value + "&campo=" + campo + "&idcidadedestino=" + $('idcidadedestino').value + "&idfilialctrc=getStIcmsCliente(" + $('idfilial').value + " , c.idcliente)", {
                method: 'post',
                asynchronous: false,
                onSuccess: e,
                onError: e
            });
        });
    }
    }catch(e){
        console.log(e);
    }
}


/**
 *Sempre que alterar alguam coisa nessa funcao, deve ser revista a rotina de importacao de chave de acesso
 */
function localizaDestinatarioCodigo(campo, valor, isAlteraTipoTaxa, isSetFretePago, consignatarioTerceiro) {
    isAlteraTipoTaxa = (isAlteraTipoTaxa == null || isAlteraTipoTaxa == undefined ? true : isAlteraTipoTaxa);
    isSetFretePago = (isSetFretePago == null || isSetFretePago == undefined ? false : isSetFretePago);
    consignatarioTerceiro = (consignatarioTerceiro == null || consignatarioTerceiro == undefined ? false : consignatarioTerceiro);
    if (campo == 'cnpj') {
        valor = valor.replace(".", "").replace(".", "").replace("/", "").replace("-", "");
    }

    if (isBloqueaAlteracao) {
        return null;
    }
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport) {
        var resp = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (resp == 'null') {
            alert('Erro ao localizar cliente.');
            return false;
        } else if (resp == 'INA') {
            limpaDestinatarioCodigo();
            alert('Cliente inativo.');
            return false;
        } else if (resp == '') {
            limpaDestinatarioCodigo();
            if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
            }
            return false;
        } else {
            var cliControl = eval('(' + resp + ')');

            $('iddestinatario').value = cliControl.idcliente;
            $('des_codigo').value = cliControl.idcliente;
            $('dest_rzs').value = cliControl.razao;
            $('dest_cidade').value = cliControl.cidade;
            $('dest_uf').value = cliControl.uf;
            $('dest_cnpj').value = cliControl.cnpj;
            $('dest_pgt').value = cliControl.pgt;
            $('dest_tipotaxa').value = cliControl.tipotaxa;
            $('idvendestinatario').value = cliControl.idvendedor;
            $('vendestinatario').value = cliControl.vendedor;
            $('des_unificada_modal_vendedor').value = cliControl.unificada_modal_vendedor;
            $('des_comissao_rodoviario_fracionado_vendedor').value = cliControl.comissao_rodoviario_fracionado_vendedor;
            $('des_comissao_rodoviario_lotacao_vendedor').value = cliControl.comissao_rodoviario_lotacao_vendedor;
            $('cidade_destino_id').value = cliControl.idcidade;
            $('cid_destino').value = cliControl.cidade;
            $('uf_destino').value = cliControl.uf;
            $('vlvendestinatario').value = cliControl.vlvendedor;
            $('desttipofpag').value = cliControl.tipofpag;
            //$('aliquota').value = cliControl.aliquota;
            //$('obs_desc').value = cliControl.obs;
            //$('reducao_base_icms').value = cliControl.reducao_icms;
            //$('aliquota_aereo').value = cliControl.aliquota_aereo;
            $('desttipoorigem').value = cliControl.tipo_origem_frete;
            $('dest_endereco').value = cliControl.endereco_cliente;
            $('desttabelaproduto').value = cliControl.is_tabela_apenas_produto;
            $('des_analise_credito').value = cliControl.is_analise_credito;
            $('des_valor_credito').value = cliControl.valor_credito;
            $('des_is_bloqueado').value = cliControl.is_bloqueado;
            $('des_tabela_remetente').value = cliControl.tipo_tabela_remetente;
            $('des_inclui_tde').value = cliControl.is_cobrar_tde;
            $('des_tipo_cfop').value = cliControl.tipo_cfop;
            $('id_rota_viagem').value = cliControl.id_rota_viagem;
            $('rota_viagem').value = cliControl.rota_viagem;
            $('distancia_km').value = cliControl.distanciakm;
            $('prazo_rota').value = cliControl.prazo_rota;
            $('tipo_prazo_rota').value = cliControl.tipo_prazo_rota;
            $('taxa_roubo').value = cliControl.taxa_roubo;
            $('taxa_roubo_urbano').value = cliControl.taxa_roubo_urbano;
            $('taxa_tombamento').value = cliControl.taxa_tombamento;
            $('taxa_tombamento_urbano').value = (cliControl.taxa_tombamento_urbano != undefined ? cliControl.taxa_tombamento_urbano : "0");
            $('pauta_destinatario').value = cliControl.is_utiliza_pauta_fiscal;
            $('des_inclui_peso_container').value = cliControl.is_acrescenta_peso_container;
            $('dest_insc_est').value = cliControl.incricao_estadual;
            $('des_st_icms').value = cliControl.st_icms;
            $('dest_obs').value = cliControl.obs;
            $("utilizatipofretetabeladest").value = cliControl.is_utilizar_tipo_frete_tabela;
            $("is_utilizar_tipo_frete_tabela").value = cliControl.is_utilizar_tipo_frete_tabela;
            //será utilizado para gerar o hash, quando o usuario precisa da autorização do supervisor.
            $("codigo_ibge_destino").value = cliControl.cod_ibge;
            $("cod_ibge").value = cliControl.cod_ibge;
            $("st_icms").value = cliControl.st_icms;
            $("des_st_icms").value = cliControl.st_icms;
            $("des_reducao_icms").value = cliControl.reducao_icms;
            $("des_is_in_gsf_598_03_go").value = cliControl.is_in_gsf_598_03_go;
            $("des_is_in_gsf_1298_16_go").value = cliControl.is_in_gsf_1298_16_go;
            $("st_des_credito_presumido").value = cliControl.percentual_credito_presumido;
            $("mensagem_usuario_cte_des").value = cliControl.mensagem_usuario_cte === null || cliControl.mensagem_usuario_cte === undefined ? "" : cliControl.mensagem_usuario_cte;
            $("tipo_arredondamento_peso_dest").value = cliControl.tipo_arredondamento_peso === null || cliControl.tipo_arredondamento_peso === undefined ? "n" : cliControl.tipo_arredondamento_peso;
            $("lbDestinatarioIE").innerHTML = cliControl.incricao_estadual;
            $("dest_tipo_tributacao").value = cliControl.tipo_tributacao;
            $("tipo_produto_destinatario_id").value = cliControl.tipo_produto_destinatario_id;
            $("dest_obs_fisco").value = cliControl.obs_fisco;
            $("dest_is_especie_serie_modal").value = cliControl.is_especie_serie_modal;
            $("dest_especie_cliente").value = cliControl.especie_cliente;
            $("dest_serie_cliente").value = cliControl.serie_cliente;
            $("dest_modal_cliente").value = cliControl.modal_cliente;
            if(cliControl.json_taxas){
                $("json_taxas").value = cliControl.json_taxas;
            }
            aoClicarNoLocaliza('Destinatario', isAlteraTipoTaxa);
            if (isSetFretePago && !consignatarioTerceiro) {
                setFretePago(false);
            }
            if (!isAlteraTipoTaxa) {
                setTimeout(function () {
                    recalcular(false)
                }, 1000);
            }
        }
    }//funcao e()

    if (valor != '') {
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=" + $('idfilial').value + "&campo=" + campo + "&remUF=" + $('uf_origem').value + "&idcidadeorigem=" + $('idcidadeorigem').value + "&idfilialctrc=getStIcmsCliente(" + $('idfilial').value + " , c.idcliente)", {
                method: 'post',
                onSuccess: e,
                onError: e
            });
        });
    }
}



function limpaConsignatarioCodigo() {
    $('idconsignatario').value = '0';
    $('con_codigo').value = '';
    $('con_rzs').value = '';
    $('con_cidade').value = '';
    $('con_uf').value = '';
    $('con_cnpj').value = '';
    $('con_pgt').value = '0';
    $('tipotaxa').value = '-1';
    $('con_tipotaxa').value = '-1';
    $('idvendedor').value = '0';
    $('ven_rzs').value = '';
    $('comissao_vendedor').value = '0';
    $('contipofpag').value = 'v';
    $('tipofpag').value = 'v';
    $('contipoorigem').value = 'n';
    $('contabelaproduto').value = 'f';
    $('con_analise_credito').value = 'f';
    $('con_valor_credito').value = '0';
    $('con_is_bloqueado').value = 'f';
    $('con_tabela_remetente').value = 'n';
    $('pauta_consignatario').value = 'f';
    $('con_inclui_peso_container').value = 'f';
    $('con_st_icms').value = '0';
    $("con_reducao_icms").value = "0";
    $("con_is_in_gsf_598_03_go").value = "f";
}
/**
 *Sempre que alterar alguam coisa nessa funcao, deve ser revista a rotina de importacao de chave de acesso
 */
function localizaConsignatarioCodigo(campo, valor) {
    try {

        if (campo == 'cnpj') {
            valor = valor.replace(".", "").replace(".", "").replace("/", "").replace("-", "");
        }

        if (isBloqueaAlteracao) {
            return null;
        }
        function e(transport) {
            var resp = transport.responseText;
            espereEnviar("", false);
            //se deu algum erro na requisicao...
            if (resp == 'null') {
                alert('Erro ao localizar cliente.');
                return false;
            } else if (resp == 'INA') {
                limpaConsignatarioCodigo();
                alert('Cliente inativo.');
                return false;
            } else if (resp == '') {
                limpaConsignatarioCodigo();
                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                    window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            } else {
                var cliControl = eval('(' + resp + ')');
                $("con_tipo_tributacao").value = cliControl.tipo_tributacao;

                $('idconsignatario').value = cliControl.idcliente;
                $('con_codigo').value = cliControl.idcliente;
                $('con_rzs').value = cliControl.razao;
                $('con_cidade').value = cliControl.cidade;
                $('con_uf').value = cliControl.uf;
                $('con_cnpj').value = cliControl.cnpj;
                $('con_pgt').value = cliControl.pgt;
                $('tipotaxa').value = cliControl.tipotaxa;
                $('con_tipotaxa').value = cliControl.tipotaxa;
                $('idvendedor').value = cliControl.idvendedor;
                $('ven_rzs').value = cliControl.vendedor;
                $('vlvenconsignatario').value = cliControl.vlvendedor;
                $('comissao_vendedor').value = getValorComissaoVendedor(cliControl.unificada_modal_vendedor, $("tipoTransporte").value, $("modalConhecimento").value == "f",
                        cliControl.vlvendedor, cliControl.vlvendedor, cliControl.comissao_rodoviario_fracionado_vendedor, cliControl.comissao_rodoviario_lotacao_vendedor);
                $('contipofpag').value = cliControl.tipofpag;
                $('tipofpag').value = cliControl.tipofpag;
                $('contipoorigem').value = cliControl.tipo_origem_frete;
                $('contabelaproduto').value = cliControl.is_tabela_apenas_produto;
                $('con_analise_credito').value = cliControl.is_analise_credito;
                $('con_valor_credito').value = cliControl.valor_credito;
                $('con_is_bloqueado').value = cliControl.is_bloqueado;
                $('con_tabela_remetente').value = cliControl.tipo_tabela_remetente;
                $('pauta_consignatario').value = cliControl.is_utiliza_pauta_fiscal;
                $('con_inclui_peso_container').value = cliControl.is_acrescenta_peso_container;
                $('con_tipo_cfop').value = cliControl.tipo_cfop;
                $('con_st_icms').value = cliControl.st_icms;
                $('con_obs').value = cliControl.obs;
                $("utilizatipofretetabelaconsig").value = cliControl.is_utilizar_tipo_frete_tabela;
                $("is_utilizar_tipo_frete_tabela").value = cliControl.is_utilizar_tipo_frete_tabela;
                $("cod_ibge").value = cliControl.cod_ibge;
                $("st_icms").value = cliControl.st_icms;
                $("con_st_icms").value = cliControl.st_icms;
                $("con_reducao_icms").value = cliControl.reducao_icms;
                $("con_is_in_gsf_598_03_go").value = cliControl.is_in_gsf_598_03_go;
                $("con_is_in_gsf_1298_16_go").value = cliControl.is_in_gsf_1298_16_go;
                $("st_cli_credito_presumido").value = cliControl.percentual_credito_presumido;
                $("mensagem_usuario_cte").value = cliControl.mensagem_usuario_cte === null || cliControl.mensagem_usuario_cte === undefined ? "" : cliControl.mensagem_usuario_cte;
                $("tipo_arredondamento_peso_con").value = cliControl.tipo_arredondamento_peso === null || cliControl.tipo_arredondamento_peso === undefined ? "n" : cliControl.tipo_arredondamento_peso;
                $("con_insc_est").innerHTML = cliControl.incricao_estadual;
                $("con_obs_fisco").value = cliControl.obs_fisco;
                $("con_is_especie_serie_modal").value = cliControl.is_especie_serie_modal;
                $("con_especie_cliente").value = cliControl.especie_cliente;
                $("con_serie_cliente").value = cliControl.serie_cliente;
                $("con_modal_cliente").value = cliControl.modal_cliente;
                aoClicarNoLocaliza('Consignatario');
            }
        }//funcao e()

        if (valor != '') {
            espereEnviar("", true);
            tryRequestToServer(function () {
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial="+$('idfilial').value+"&campo=" + campo + "&idfilialctrc=getStIcmsCliente(" + $('idfilial').value + " , c.idcliente)", {
                    method: 'post',
                    onSuccess: e,
                    onError: e
                });
            });
        }
    } catch (e) {
        alert(e);
    }
}



function limpaRedespachoCodigo() {
    $('idredespacho').value = '0';
    $('red_codigo').value = '';
    $('red_rzs').value = '';
    $('red_cidade').value = '';
    $('red_uf').value = '';
    $('red_cnpj').value = '';
    $('red_pgt').value = '0';
    $('red_tipotaxa').value = '-1';
    $('idvenredespacho').value = '0';
    $('venredespacho').value = '';
    $('vlvenredespacho').value = '0';
    $('redtipofpag').value = 'v';
    $('redtipoorigem').value = 'r';
    $('redtabelaproduto').value = 'f';
    $('red_analise_credito').value = 'f';
    $('red_valor_credito').value = '0';
    $('red_is_bloqueado').value = 'f';
    $('red_tabela_remetente').value = 'n';
    $('pauta_redespacho').value = 'f';
    $('red_inclui_peso_container').value = 'f';
    $("red_reducao_icms").value = "0";
    $("red_is_in_gsf_598_03_go").value = "f";
}
/**
 *Sempre que alterar alguam coisa nessa funcao, deve ser revista a rotina de importacao de chave de acesso
 */
function localizaRedespachoCodigo(campo, valor) {
    if (campo == 'cnpj') {
        valor = valor.replace(".", "").replace(".", "").replace("/", "").replace("-", "");
    }

    if (isBloqueaAlteracao) {
        return null;
    }
    function e(transport) {
        var resp = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (resp == 'null') {
            alert('Erro ao localizar cliente.');
            return false;
        } else if (resp == 'INA') {
            limpaRedespachoCodigo();
            alert('Cliente inativo.');
            return false;
        } else if (resp == '') {
            limpaRedespachoCodigo();
            if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
            }
            return false;
        } else {
            var cliControl = eval('(' + resp + ')');
            
            $('idredespacho').value = cliControl.idcliente;
            $('red_codigo').value = cliControl.idcliente;
            $('red_rzs').value = cliControl.razao;
            $('red_cidade').value = cliControl.cidade;
            $('red_uf').value = cliControl.uf;
            $('red_cidade_id').value = cliControl.idcidade;
            $('red_cnpj').value = cliControl.cnpj;
            $('red_pgt').value = cliControl.pgt;
            $('red_tipotaxa').value = cliControl.tipotaxa;
            $('idvenredespacho').value = cliControl.idvendedor;
            $('venredespacho').value = cliControl.vendedor;
            $('red_unificada_modal_vendedor').value = cliControl.unificada_modal_vendedor;
            $('red_comissao_rodoviario_fracionado_vendedor').value = cliControl.comissao_rodoviario_fracionado_vendedor;
            $('red_comissao_rodoviario_lotacao_vendedor').value = cliControl.comissao_rodoviario_lotacao_vendedor;
            $('vlvenredespacho').value = cliControl.vlvendedor;
            $('redtipofpag').value = cliControl.tipofpag;
            //$('aliquota').value = cliControl.aliquota;
            $('redtipoorigem').value = cliControl.tipo_origem_frete;
            $('redtabelaproduto').value = cliControl.is_tabela_apenas_produto;
            $('red_analise_credito').value = cliControl.is_analise_credito;
            $('red_valor_credito').value = cliControl.valor_credito;
            $('red_is_bloqueado').value = cliControl.is_bloqueado;
            $('red_tabela_remetente').value = cliControl.tipo_tabela_remetente;
            $('pauta_redespacho').value = cliControl.is_utiliza_pauta_fiscal;
            $('red_inclui_peso_container').value = cliControl.is_acrescenta_peso_container;
            $('red_tipo_cfop').value = cliControl.tipo_cfop;
            $("cod_ibge").value = cliControl.cod_ibge;
            $("st_icms").value = cliControl.st_icms;
            $("red_reducao_icms").value = cliControl.reducao_icms;
            $("red_is_in_gsf_598_03_go").value = cliControl.is_in_gsf_598_03_go;
            $("red_is_in_gsf_1298_16_go").value = cliControl.is_in_gsf_1298_16_go;
            $("st_red_credito_presumido").value = cliControl.percentual_credito_presumido;
            $('red_rota_viagem_id').value = cliControl.id_rota_viagem;
            $('red_rota_viagem').value = cliControl.rota_viagem;
            if(cliControl.json_taxas){
                $("red_rota_taxas").value = cliControl.json_taxas;
            }
            $("tipo_arredondamento_peso_red").value = cliControl.tipo_arredondamento_peso === null || cliControl.tipo_arredondamento_peso === undefined ? "n" : cliControl.tipo_arredondamento_peso;
            $("red_insc_est").innerHTML = cliControl.incricao_estadual;
            $("red_tipo_tributacao").value = cliControl.tipo_tributacao;
            $("red_obs_fisco").value = cliControl.obs_fisco;
            $("red_is_especie_serie_modal").value = cliControl.is_especie_serie_modal;
            $("red_especie_cliente").value = cliControl.especie_cliente;
            $("red_serie_cliente").value = cliControl.serie_cliente;
            $("red_modal_cliente").value = cliControl.modal_cliente;
            
//            $("stIcmsRed").value = cliControl.st_icms;
              //tava chamando a validação novamente quando é um redespacho, sendo que a validação abaixo já é para redespacho - Historia 2994 - Daniel Cassimiro
//            aoClicarNoLocaliza('Redespacho');
            if ($("rec").checked) {
                validarCidadeDestinoRecebedorRedespacho(true);
            }
            if ($("exp").checked) {
                validarCidadeOrigemExpedidorRedespacho(true);
            }
            pagouRedespacho($("is_redespacho_pago").checked);
        }
    }//funcao e()
    if ($('dest_uf').value == '') {
        alert('Informe o destinatário corretamente.');
        return null;
    } else if (valor != '') {
        $('aliquota_rodoviario').value = $('aliquota').value;
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&campo=" + campo + "&idfilial=" + $('idfilial').value + "&destUF=" + $('dest_uf').value + '&idDestinatarioRed=' + $('iddestinatario').value + "&idfilialctrc=getStIcmsCliente(" + $('idfilial').value + " , c.idcliente)&idcidadeorigem="+$("idcidadeorigem").value+"&idCidadeDestino="+$("idcidadedestino").value, {
                method: 'post',
                onSuccess: e,
                onError: e
            });
        });
    }
}

function limpaExpedidorCodigo() {
    $('idexpedidor').value = '0';
    $('exp_codigo').value = '';
    $('exp_rzs').value = '';
    $('exp_cidade').value = '';
    $('exp_uf').value = '';
    $('exp_cnpj').value = '';
    $('exp_endereco').value = '';
    $('pauta_expedidor').value = 'f';
    $('exp_inclui_peso_container').value = 'f';
    $('exp_st_mg').value = 'f';
}



function limpaRecebedorCodigo() {
    $('idexpedidor').value = '0';
    $('exp_codigo').value = '';
    $('exp_rzs').value = '';
    $('exp_cidade').value = '';
    $('exp_uf').value = '';
    $('exp_cnpj').value = '';
    $('exp_endereco').value = '';
    $('pauta_expedidor').value = 'f';
    $('exp_inclui_peso_container').value = 'f';
    $('exp_st_mg').value = 'f';
}



//remover a minuta
function removerCTRCDist(idx) {
    if (confirm("Deseja mesmo apagar o CTRC da lista")) {
        removerNFMinuta(idx);//antes de remover da tela é chamada a função
        Element.remove('trDistribuicao_' + idx);//apos a funcao ser executada, removerá a TR
        countCTRC--;//e da quantidade de MINUTAS será reduzido 1.
        getTotaisCTRC();//alterei a função original para setar o valor também em Valor Frete.
    }
}

function removerNFMinuta(indexMinuta) {
    //id para verificacao
    var idMinuta = ($("ctrcId_" + indexMinuta).value == null || $("ctrcId_" + indexMinuta).value == undefined ? "" : $("ctrcId_" + indexMinuta).value);
    var idCtNf = "";//sera armazenado o id do conhecimento da nota.
    var quantidadeNF = getNextIndexFromTableRoot("0", "tableNotes0");//retorna o proximo numero das nf onde coleta for "0", pois conhecimento não usa coletas.

    for (var i = 1; i < quantidadeNF; i++) {//varrerá as notas em busca do id da minuta na qual ela é vinculada.
        if ($("minutaId_" + i + "_id0") != null && $("minutaId_" + i + "_id0") != undefined) { // se o elemento existir
            idCtNf = ($("minutaId_" + i + "_id0").value == null || $("minutaId_" + i + "_id0").value == undefined ? "" : $("minutaId_" + i + "_id0").value);
            //cada interação com o for, o id do ctrc da nf deve ser atualizado conforme o for prossegue..
            if (idCtNf == idMinuta && idCtNf != "") {//a ultima verificacao anularia a possibilidade dos 2 serem vazio, 
                //uma vez que no ternario podem ser retornados como vazio.
                //esses IFs é verificando se as TR's estao nulas. 
                if ($('trNote' + i + '_id0') != null || $('trNote' + i + '_id0') != undefined) {
                    Element.remove('trNote' + i + '_id0');
                }//fim do if
                if ($('trNoteCte' + i + '_id0') != null || $('trNoteCte' + i + '_id0') != undefined) {
                    Element.remove('trNoteCte' + i + '_id0');
                }//fim do if
                if ($('nf_tr2_' + i + '_id0') != null || $('nf_tr2_' + i + '_id0') != undefined) {
                    Element.remove('nf_tr2_' + i + '_id0');
                }//fim do if
                //aqui não pode ficar o ajax. foi solicitado que faça-o apenas uma vez...e não a cada interação do for.
            }//fim se forem iguais
        }// fim se o elemento existir
    }//fim for
    excluirNFMinuta(idCtNf);//função que exclui por ajax baseado no id da minuta
}//fim funçãos


function excluirNFMinuta(id) {
    tryRequestToServer(function () {
        new Ajax.Request("NotaFiscalControlador?acao=excluirNFMinuta&id=" + id, {
            method: 'post',
            onSuccess: "",
            onError: ""
        });
    });
}



var countCTRC = 0;
function addCTRC(idCTRC, numero_ctrc, emissao_ctrc, valor_ctrc, destinatario, bairro_destino, cidade_destino, numero_nota, isAtualiza, isCalcular, isLiberarNota) {
    
    var tr_ = Builder.node("TR", {
        className: "CelulaZebra" + (countCTRC % 2 == 0 ? 2 : 1),
        id: "trDistribuicao_" + countCTRC,
        name: "trDistribuicao_" + countCTRC
    });
    var td1_ = Builder.node("TD");
    var img1_ = Builder.node("IMG", {
        src: "img/lixo.png",
        title: "Apagar o CTRC de distribuição " + numero_ctrc + " da lista.",
        className: "imagemLink",
        onClick: "removerCTRCDist(" + countCTRC + ");"
    });
    var inp1_ = Builder.node("INPUT", {
        type: "hidden",
        name: "ctrcId_" + countCTRC,
        id: "ctrcId_" + countCTRC,
        value: idCTRC
    });
    var inp2_ = Builder.node("INPUT", {
        type: "hidden",
        name: "ctrcValor_" + countCTRC,
        id: "ctrcValor_" + countCTRC,
        value: valor_ctrc
    });
    td1_.appendChild(img1_);
    td1_.appendChild(inp1_);
    td1_.appendChild(inp2_);



    //if(<%= request.getParameter("is_Conhecimento") %> == true){
    //aqui só entrará quando a tela que chama o seleciona_ctrc.. for is_Conhecimento = true
    //< % NotaFiscal nf = new NotaFiscal();
    //    NotaFiscalControlador nfc = new NotaFiscalControlador();
    //    //nf = nfc.notaPorConhecimento();
    //%>
    //window.open("/NotaFiscalControlador?acao=notaPorConhecimento&idConhecimento="+$('id_ctrc_'+i).value,
    //                              "notasPorCT" , 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');

    isAtualiza = (isAtualiza != undefined || isAtualiza != null ? isAtualiza : true);

    if (!isAtualiza) {

        //new Ajax.Request("NotaFiscalControlador?acao=notaPorConhecimento&idConhecimento="+$('id_ctrc_'+i).value,
        new Ajax.Request("NotaFiscalControlador?acao=notaPorConhecimento&idConhecimento=" + idCTRC,
                {
                    method: 'get',
                    onSuccess:
                            function e(transport) {
                                var response = transport.responseText;
                                var resposta = response;
                                var lista = jQuery.parseJSON(response);
                                var listaNF = lista.list[0].notasFiscais;
                                var length = (listaNF != undefined && listaNF.length != undefined ? listaNF.length : 1);
                                var nota;

                                if (length > 1) {
                                    for (var i = 0; i < length; i++) {
                                        nota = listaNF[i];
                                        
                                        addNota(nota.idconhecimento
                                                , "tableNotes0", ''//3
                                                , nota.numero
                                                , nota.serie
                                                , nota.emissaoStr//6
                                                , nota.valor
                                                , nota.vl_base_icms
                                                , nota.vl_icms//9
                                                , nota.vl_icms_st
                                                , nota.vl_icms_frete
                                                , nota.peso//12
                                                , nota.volume
                                                , nota.embalagem
                                                , nota.conteudo//15
                                                , nota.idconhecimento
                                                , nota.pedido
                                                , true//18
                                                , nota.largura
                                                , nota.altura
                                                , nota.comprimento//21
                                                , nota.metroCubico
                                                , nota.marcaVeiculo.idmarca
                                                , nota.marcaVeiculo.descricao//24
                                                , nota.modeloVeiculo
                                                , nota.anoVeiculo
                                                , nota.corVeiculo//27
                                                , nota.chassiVeiculo
                                                , ""
                                                , ""//30
                                                , nota.cfop.idcfop
                                                , nota.cfop.cfop
                                                , nota.chaveNFe//33
                                                , nota.agendado
                                                , nota.dataAgenda
                                                , nota.horaAgenda//36
                                                , nota.observacaoAgenda
                                                , ""
                                                , nota.PrevisaoEm
                                                , nota.PrevisaoAs //40
                                                , nota.destinatario.idcliente
                                                , nota.destinatario.razaosocial
                                                , (isLiberarNota == true || isLiberarNota == 't' || isLiberarNota == 'true' ? false : nota.importadaEdi)
                                                , ""
                                                , idCTRC
                                                ,nota.tipoDocumento);//45

                                    }
                                } else if (length == 1) {
                                    nota = listaNF;
                                    /*function addNote(idColeta,idTableRoot, idnota_fiscal,3
                                     numero, serie, emissao,6
                                     valor, vl_base_icms,vl_icms,9
                                     vl_icms_st,vl_icms_frete,peso,12
                                     volume, embalagem, conteudo,15
                                     idCTRC, pedido, readOnly,18
                                     largura, altura, comprimento,21
                                     metroCubico, idMarcaVeiculo, marcaVeiculo,24
                                     modeloVeiculo, anoVeiculo, corVeiculo,27
                                     chassiVeiculo,maxItens,isPossuiItens,30
                                     cfopId,cfop,chaveNFe,33
                                     isAgendado, dataAgenda, horaAgenda,36
                                     obsAgenda, isBaixaNota, previsaoEntrega, previsaoAs,40
                                     idDestinatario, destinatario, isEdi,maxItensMetro)44*/

                                    addNota(nota.idconhecimento, "tableNotes0", ''//3
                                            , nota.numero, nota.serie, nota.emissaoStr//6
                                            , nota.valor, nota.vl_base_icms, nota.vl_icms//9
                                            , nota.vl_icms_st, nota.vl_icms_frete, nota.peso//12
                                            , nota.volume, nota.embalagem, nota.conteudo//15
                                            , nota.idconhecimento, nota.pedido, true//18
                                            , nota.largura, nota.altura, nota.comprimento//21
                                            , nota.metroCubico, nota.marcaVeiculo.idmarca, nota.marcaVeiculo.descricao//24
                                            , nota.modeloVeiculo, nota.anoVeiculo, nota.corVeiculo//27
                                            , nota.chassiVeiculo, "", ""//30
                                            , nota.cfop.idcfop, nota.cfop.cfop, nota.chaveNFe//33
                                            , nota.agendado, nota.dataAgenda, nota.horaAgenda//36
                                            , nota.observacaoAgenda, "", nota.PrevisaoEm, nota.PrevisaoAs //40
                                            , nota.destinatario.idcliente, nota.destinatario.razaosocial, (isLiberarNota ? false : nota.importadaEdi), "", idCTRC,nota.tipoDocumento);//45
                                }
                                $("volume").value = sumVolumeNotes('0');
                                $("peso").value = sumPesoNotes('0');
                                $("vlmercadoria").value = sumValorNotes('0');

                                // Essa linha abaixo foi adicionada para calcular o peso taxado do CTe CASO for entrega local.
                                if ($('tipoConhecimento').value === 'l') {
                                    calculaPesoTaxadoCtrc();
                                }
                            }


                    ,
                    onFailure: function () {
                        alert('deu erro')
                    }
                });
    }

    var td2_ = Builder.node("TD", numero_ctrc);
    var td3_ = Builder.node("TD", emissao_ctrc);
    var td4_ = Builder.node("TD", {
        align: "right"
    }, valor_ctrc);
    var td5_ = Builder.node("TD", destinatario);
    var td6_ = Builder.node("TD", bairro_destino);
    var td7_ = Builder.node("TD", cidade_destino);
    var td8_ = Builder.node("TD", numero_nota);

    tr_.appendChild(td1_);
    tr_.appendChild(td2_);
    tr_.appendChild(td8_);
    tr_.appendChild(td3_);
    tr_.appendChild(td4_);
    tr_.appendChild(td5_);
    tr_.appendChild(td6_);
    tr_.appendChild(td7_);

    $('tbDistribuicao').appendChild(tr_);

    countCTRC++;
    isCalcular = (isCalcular != undefined || isCalcular != null ? isCalcular : true);


    getTotaisCTRC(isCalcular);
}


function selecionaCTRC() {
    if ($('idconsignatario').value == 0) {
        alert('Informe o Cliente Corretamente!');
    } else {
        window.open('./pops/seleciona_ctrc_distribuicao.jsp?acao=iniciar&idconsignatario=' + $('idconsignatario').value + "&is_Conhecimento=true" +
                '&con_rzs=' + $('con_rzs').value + '&marcados=' + getCTRCMarcados(), 'CTRC', 'top=0,width=800,resizable=yes,status=1,scrollbars=1');
    }
}

function getCTRCMarcados() {
    var qtd = countCTRC;
    var marcados = "0";
    for (i = 0; i <= qtd; ++i) { //Percorra todos os serviços
        if ($('ctrcId_' + i) != null) {
            marcados += ',' + $('ctrcId_' + i).value;
        }
    }
    return marcados;
}

function getTotaisCTRC(isCalcular) {
    var qtd = countCTRC;
    var marcados = "0";
    var totalValor = 0;
    var qtdCTRC = 0;
    for (i = 0; i <= qtd; ++i) { //Percorra todos os serviços
        if ($('ctrcId_' + i) != null) {
            totalValor += parseFloat($('ctrcValor_' + i).value);
            qtdCTRC++;
        }
    }
    $('lbTotalDistribuicao').innerHTML = formatoMoeda(totalValor);
    $('lbQtdDistribuicao').innerHTML = qtdCTRC + ' CTRC(s)';
    if (isCalcular) {
        $('valor_frete').value = formatoMoeda(totalValor);
        recalcular(false);
    }
}

function popCTe(id) {
    var tipoUtiApisul = $("tipoUtilizacaoApisul").value;
    var wName = 'dacte';
    var modelo = $("modDacte").value;

    var imprimir = 'false';
    if (id == "" || id == null) {
        return null;
    }

    if (tipoUtiApisul != 'N' && tipoUtiApisul != '') {
        if ($("isAverbacao") != null && $("isAverbacao").value != undefined) {
            if ($("isAverbacao").value == 'true') {
                imprimir = 'true';

            }
        }
    } else {
        imprimir = 'true';
    }

    if (imprimir == 'true') {
        launchPDF('./ConhecimentoControlador?acao=exportarDacte&modelo=' + modelo + '&idCte=' + id, wName);
    } else {
        alert("CTRC não averbado!");
    }
}

function escondeMostraCancelamento(check) {
    if (check) {
        $("lbTitleCancelado").style.display = "";
        $("lbDataCancelado").style.display = "";
        $("dataCancelado").style.display = "";
        $("motivoCancelamento").style.display = "";
    } else {
        $("lbTitleCancelado").style.display = "none";
        $("lbDataCancelado").style.display = "none";
        $("dataCancelado").style.display = "none";
        $("motivoCancelamento").style.display = "none";
    }
}
function showFields(idtaxa) {
    Element.hide("tipoveiculo");
    Element.hide("imgCombinado");
    mostraCalculoCombinado(false);
    if ((idtaxa == "0")) {
        Element.show("tipoveiculo");
        Element.show("lbCidadeOrigem");
        Element.show("lbCidadeDestino");
        Element.show("cid_origem");
        Element.show("uf_origem");
        Element.show("btn_origem");
        Element.show("cid_destino");
        Element.show("uf_destino");
        Element.show("btn_destino");
        //Element.show("calculado_entre");
    } else if (idtaxa == "1") {
        Element.show("tipoveiculo");
        Element.show("lbCidadeOrigem");
        Element.show("cid_origem");
        Element.show("uf_origem");
        Element.show("btn_origem");
        Element.show("lbCidadeDestino");
        Element.show("cid_destino");
        Element.show("uf_destino");
        Element.show("btn_destino");
        //Element.show("calculado_entre");
    } else if (idtaxa == "2") {
        Element.show("lbCidadeOrigem");
        Element.show("cid_origem");
        Element.show("uf_origem");
        Element.show("btn_origem");
        Element.show("lbCidadeDestino");
        Element.show("cid_destino");
        Element.show("uf_destino");
        Element.show("btn_destino");
        //Element.show("calculado_entre");
    } else if (idtaxa == "3") {
        Element.show("tipoveiculo");
        Element.show("lbCidadeOrigem");
        Element.show("cid_origem");
        Element.show("uf_origem");
        Element.show("btn_origem");
        Element.show("lbCidadeDestino");
        Element.show("cid_destino");
        Element.show("uf_destino");
        Element.show("btn_destino");
        Element.show("imgCombinado");
        if (parseFloat($('valor_peso_unitario').value) > 0) {
            mostraCalculoCombinado(true);
        }
        //Element.show("calculado_entre");
    } else if (idtaxa == "4") {
        Element.show("lbCidadeOrigem");
        Element.show("cid_origem");
        Element.show("uf_origem");
        Element.show("btn_origem");
        Element.show("lbCidadeDestino");
        Element.show("cid_destino");
        Element.show("uf_destino");
        Element.show("btn_destino");
        //Element.show("calculado_entre");
    } else if (idtaxa == "5") {
        Element.show("tipoveiculo");
        Element.show("distancia_km");
        Element.show("lbKm");
    }
}

function preencheRedespacho() {
    if ($("ck_redespacho").checked) {
        
        if ($("exp").checked) {
            $("idexpedidor").value = $("idredespacho").value;
            $("exp_rzs").value = $("red_rzs").value;
            $("exp_codigo").value = $("red_codigo").value;
            $("pauta_expedidor").value = $("pauta_redespacho").value;
            $("exp_inclui_peso_container").value = $("red_inclui_peso_container").value;
            $("exp_tipo_cfop").value = $("red_tipo_cfop").value;
            $("exp_cidade").value = $("red_cidade").value;
            $("exp_uf").value = $("red_uf").value;
            $("exp_cnpj").value = $("red_cnpj").value;
            $("localiza_rec").disabled = false;
            $("localiza_exp").disabled = false;
            if($("idredespacho") != null && $("idredespacho").value != "" && $("idredespacho").value != 0){
                //a função anterior esta sendo chamado novamente, pois ele já é chamdada no lacalizar, apenas chamando o limpaRecebedor para trocar o expedidor por recebedor - Historia 2994 - Daniel Cassimri
                limpaRecebedor();
            }
        }
        
        if ($("rec").checked) {
            $("idrecebedor").value = $("idredespacho").value;
            $("rec_rzs").value = $("red_rzs").value;
            $("rec_codigo").value = $("red_codigo").value;
            $("pauta_recebedor").value = $("pauta_redespacho").value;
            $("rec_inclui_peso_container").value = $("red_inclui_peso_container").value;
            $("rec_tipo_cfop").value = $("red_tipo_cfop").value;
            $("rec_cidade").value = $("red_cidade").value;
            $("rec_uf").value = $("red_uf").value;
            $("rec_cnpj").value = $("red_cnpj").value;
            $("localiza_exp").disabled = false;
            $("localiza_rec").disabled = false;
            if($("idredespacho") != null && $("idredespacho").value != "" && $("idredespacho").value != 0){
                //a função anterior esta sendo chamado novamente, pois ele já é chamdada no lacalizar, apenas chamando o limpaExpedidor para trocar o expedidor por recebedor - Historia 2994 - Daniel Cassimri
                limpaExpedidor();
            }
        }
    }
}

function localizaRecebedorCodigo(campo, valor) {

    if (isBloqueaAlteracao) {
        return null;
    }
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport) {
        var resp = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (resp == 'null') {
            alert('Erro ao localizar cliente.');
            return false;
        } else if (resp == 'INA') {
            limpaRecebedor();
            alert('Cliente inativo.');
            return false;
        } else if (resp == '') {
            limpaRecebedor();
            if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
            }
            return false;
        } else {
            var cliControl = eval('(' + resp + ')');
            $('idrecebedor').value = cliControl.idcliente;
            $('rec_codigo').value = cliControl.idcliente;
            $('rec_rzs').value = cliControl.razao;
            $('rec_cidade').value = cliControl.cidade;
            $('rec_uf').value = cliControl.uf;
            $('rec_cnpj').value = cliControl.cnpj;
            $('rec_idcidade').value = cliControl.idcidade;

            aoClicarNoLocaliza('Recebedor');
            if (campo == 'c.razaosocial') {
                getObj('rec_rzs').focus();
            }
        }
    }//funcao e()

    if (valor != '') {
        ufRemetenteAnterior = $('rec_uf').value;
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=0&destUF=" + $('rec_uf').value + "&campo=" + campo + "&idcidadedestino=" + $('idcidadedestino').value, {
                method: 'post',
                onSuccess: e,
                onError: e
            });
        });
    }
}

function localizaExpedidorCodigo(campo, valor) {
    if (isBloqueaAlteracao) {
        return null;
    }
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport) {
        var resp = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (resp == 'null') {
            alert('Erro ao localizar cliente.');
            return false;
        } else if (resp == 'INA') {
            limpaExpedidor();
            alert('Cliente inativo.');
            return false;
        } else if (resp == '') {
            limpaExpedidor();
            
            a
            if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
            }
            return false;
        } else {
            var cliControl = eval('(' + resp + ')');
            $('idexpedidor').value = cliControl.idcliente;
            $('exp_codigo').value = cliControl.idcliente;
            $('exp_rzs').value = cliControl.razao;
            $('exp_cidade').value = cliControl.cidade;
            $('exp_uf').value = cliControl.uf;
            $('exp_cnpj').value = cliControl.cnpj;
            $("exp_idcidade").value = cliControl.idcidade;

            aoClicarNoLocaliza('Expedidor');
            if (campo == 'c.razaosocial') {
                getObj('exp_rzs').focus();
            }
        }
    }//funcao e()

    if (valor != '') {
        ufRemetenteAnterior = $('exp_uf').value;
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=0&destUF=" + $('exp_uf').value + "&campo=" + campo + "&idcidadedestino=" + $('idcidadedestino').value, {
                method: 'post',
                onSuccess: e,
                onError: e
            });
        });
    }
}

function habilitaSalvar(opcao) {
    parent.frameAbaixo.document.getElementById("salvar").disabled = !opcao;
    parent.frameAbaixo.document.getElementById("salvar").value = (opcao ? "Salvar [F8]" : "Enviando...");
    if (parent.frameAbaixo.document.getElementById("salvar2") != null) {
        parent.frameAbaixo.document.getElementById("salvar2").disabled = !opcao;
        parent.frameAbaixo.document.getElementById("salvar2").value = (opcao ? "Salvar e imprimir [F10]" : "Enviando...");
    }
    if (parent.frameAbaixo.document.getElementById("salvar3") != null) {
        parent.frameAbaixo.document.getElementById("salvar3").disabled = !opcao;
        parent.frameAbaixo.document.getElementById("salvar3").value = (opcao ? "Salvar e digitar novo [F9]" : "Enviando...");
    }
}



function fechar() {
    window.close();
}

function abrirLocalizacaoMapa(latitude, longitude, precisao) {
    if (latitude == null || latitude == 0 || longitude == null || longitude == 0)
        return null;
    //https://maps.google.com.br/maps?q=-30.03306,+-51.23&hl=pt-PT&sll=-23.570033,-46.660695&sspn=0.089212,0.169086&t=m&z=16
    var url = "http://maps.google.com/maps?q=" + longitude + ",+" + latitude;
    window.open(url, "googMaps", "toolbar=no,location=no,scrollbars=no,resizable=no");
}

function removerNotaFiscalAjax(idNota) {
    tryRequestToServer(function () {
        new Ajax.Request("./cadvenda.jsp?acao=removerNotaFiscalAjax&idNota=" + idNota, {
            method: 'post',
            onSuccess: ""
            ,
            onError: ""
        });
    });
}

function addNota(idColeta, idTableRoot, idnota_fiscal,
        numero, serie, emissao,
        valor, vl_base_icms, vl_icms,
        vl_icms_st, vl_icms_frete, peso,
        volume, embalagem, descricao_produto,
        idCTRC, pedido, readOnly,
        largura, altura, comprimento,
        metroCubico, idMarcaVeiculo, marcaVeiculo,
        modeloVeiculo, anoVeiculo, corVeiculo,
        chassiVeiculo, maxItens, isPossuiItens,
        cfopId, cfop, chaveNFe,
        isAgendado, dataAgenda, horaAgenda,
        obsAgenda, isBaixaNota, previsaoEntrega, previsaoAs,
        idDestinatario, destinatario, isEdi, maxItensMetro, minutaId,tipoDoc) {
    if (countIdxNotes < 200) {
        countIdxNotes++;

        addNote(0, "tableNotes0", ''
                , numero, serie, emissao
                , valor, ""/*vl_base_icms*/, ""//vl_icms //esses 2 quebram 
                , ""/*vl_icms_st*/, ""/*vl_icms_frete*/, peso
                , volume, embalagem, descricao_produto
                , idCTRC, pedido, false
                , largura, altura, comprimento
                , metroCubico, idMarcaVeiculo, marcaVeiculo
                , modeloVeiculo, anoVeiculo, corVeiculo
                , chassiVeiculo, maxItens, 'false'
                , cfopId, cfop, chaveNFe
                , isAgendado, ""/*dataAgenda*/, horaAgenda//essa data esta quebrando
                , obsAgenda, isBaixaNota, ""/*previsaoEntrega*/, previsaoAs //outra data quebrando
                , idDestinatario, destinatario, isEdi, maxItensMetro, minutaId,tipoDoc
                );
    }
}

function getObs() {
    //se preencheu obs
    if (replaceAll($('con_obs').value, "<BR>", "") == '') {
        if ($v('obs_desc') != "") {
            var newObs = replaceAll($('obs_desc').value, "<br>", "<BR>");
            var array_obs = newObs.split("<BR>");
            $('obs_lin1').value = (array_obs.length >= 1 ? array_obs[0] : "");
            $('obs_lin2').value = (array_obs.length >= 2 ? array_obs[1] : "");
            $('obs_lin3').value = (array_obs.length >= 3 ? array_obs[2] : "");
            $('obs_lin4').value = (array_obs.length >= 4 ? array_obs[3] : "");
            $('obs_lin5').value = (array_obs.length >= 5 ? array_obs[4] : "");
            $('obs_desc').value = "";
        }
    }
}

function obsAliquota() {
    if ($("obs_lin1").value == '' && $("obs_lin2").value == '' && $("obs_lin3").value == '' && $("obs_lin4").value == '' && $("obs_lin5").value == '') {
        if ($("obs_desc").value != '') {
            var obs = $("obs_desc").value != undefined ? $("obs_desc").value : "";

            obs = replaceAll(obs, "<br>", "<BR>");
            //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
            $("obs_lin1").value = obs.split("<BR>")[0];
            $("obs_lin2").value = obs.split("<BR>")[1];
            $("obs_lin3").value = obs.split("<BR>")[2];
            $("obs_lin4").value = obs.split("<BR>")[3];
            $("obs_lin5").value = obs.split("<BR>")[4];
        }
    }
}

function definirComissaoVendedor() {
    $("comissao_vendedor").value = getValorComissaoVendedor($("con_unificada_modal_vendedor").value, $("tipoTransporte").value, $("modalConhecimento").value == "f",
            $("vlvenconsignatario").value, $("vlvenconsignatario").value, $("con_comissao_rodoviario_fracionado_vendedor").value, $("con_comissao_rodoviario_lotacao_vendedor").value);
}

function localizaconsignatario() {
    var idfilial = $("idfilial").value;
    // var param = 'AND ( csif.filial_id=1 or filial_id is null )';
    windowConsignatario = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5&paramaux4=' + idfilial, 'Consignatario',
            'top=80,left=70,height=500,width=700,resizable=yes,status=1,scrollbars=1');
}

function getStIcmsConsig() {
    try {
        if ($("idconsignatario").value == $("idremetente").value) {
            
            $("con_st_icms").value = $("rem_st_icms").value;
            $("con_reducao_icms").value = $("rem_reducao_icms").value;
            $("con_is_in_gsf_598_03_go").value = $("rem_is_in_gsf_598_03_go").value;
            $("con_obs").value = $("rem_obs").value;
            $("st_cli_credito_presumido").value = $("st_rem_credito_presumido").value;
            $("con_is_in_gsf_1298_16_go").value = $("rem_is_in_gsf_1298_16_go").value;
            $("con_tipo_tributacao").value = $("rem_tipo_tributacao").value;
            $("con_obs_fisco").value = $("rem_obs_fisco").value;
        } else if ($("idconsignatario").value == $("iddestinatario").value && $("idconsignatario").value != 0) {
            $("con_st_icms").value = $("des_st_icms").value;
            $("con_obs").value = $("dest_obs").value;
            $("con_reducao_icms").value = $("des_reducao_icms").value;
            $("con_is_in_gsf_598_03_go").value = $("des_is_in_gsf_598_03_go").value;
            $("st_cli_credito_presumido").value = $("st_des_credito_presumido").value;
            $("con_is_in_gsf_1298_16_go").value = $("des_is_in_gsf_1298_16_go").value;
            $("con_tipo_tributacao").value = $("dest_tipo_tributacao").value;
            $("con_obs_fisco").value = $("dest_obs_fisco").value;
        }
        
        if (parseInt($("con_st_icms").value, 10) == 0) {
            if(parseInt($("stIcmsConfig").value, 10) != 0){
                $("stIcms").disabled = false;
                $("stIcms").value = $("stIcmsConfig").value;
                $("reducao_base_icms").value = $("config_reducao_base_icms").value;
                $("stIcms").disabled = ($("perm_altera_icms").value == 'true' ? false : true);//Variável perm_altera_icms criada para armazenar o valor da permissão de sticms do usuário.
            }
        } else {
            $("stIcms").disabled = false;
            $("stIcms").value = $("con_st_icms").value;
            $("reducao_base_icms").value = $("con_reducao_icms").value;
            $("is_in_gsf_598_03_go").value = $("con_is_in_gsf_598_03_go").value;
            $("is_in_gsf_1298_16_go").value = $("con_is_in_gsf_1298_16_go").value;
            $("stIcms").disabled = ($("perm_altera_icms").value == 'true' ? false : true);//Variável perm_altera_icms criada para armazenar o valor da permissão de sticms do usuário.
        }
        
        $("is_in_gsf_1298_16_go").value = $("con_is_in_gsf_1298_16_go").value;
        $("st_credito_presumido").value = $("st_cli_credito_presumido").value;

        var obs = replaceAll($('con_obs').value, "\r\n", "<BR>");
        obs = replaceAll(obs, "<br>", "<BR>");
        obs = replaceAll(obs, "<br/>", "<BR>");
        if (obs != null && obs != "") {
            if (replaceAll(obs, "<BR>", "") != undefined || replaceAll(obs, "<BR>", "") != '') {
                //Tratamento das observações por motivo de estar vindo andefined e hoje tem duas formas de vim a separação com <BR> e <br>.
                $('obs_lin1').value = obs.split('<BR>')[0] != undefined ? (obs.split('<BR>').length >= 0 ? obs.split('<BR>')[0] : "") : "";
                $('obs_lin2').value = obs.split('<BR>')[1] != undefined ? (obs.split('<BR>').length >= 1 ? obs.split('<BR>')[1] : "") : "";
                $('obs_lin3').value = obs.split('<BR>')[2] != undefined ? (obs.split('<BR>').length >= 2 ? obs.split('<BR>')[2] : "") : "";
                $('obs_lin4').value = obs.split('<BR>')[3] != undefined ? (obs.split('<BR>').length >= 3 ? obs.split('<BR>')[3] : "") : "";
                $('obs_lin5').value = obs.split('<BR>')[4] != undefined ? (obs.split('<BR>').length >= 4 ? obs.split('<BR>')[4] : "") : "";
            }
        } else {
            if ($("obs_desc").value != '') {
                var obs = $("obs_desc").value != undefined ? $("obs_desc").value : "";
                obs = replaceAll(obs, "<br>", "<BR>");
                //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
                $("obs_lin1").value = obs.split("<BR>")[0];
                $("obs_lin2").value = obs.split("<BR>")[1];
                $("obs_lin3").value = obs.split("<BR>")[2];
                $("obs_lin4").value = obs.split("<BR>")[3];
                $("obs_lin5").value = obs.split("<BR>")[4];
            }else if($("obs_orcamento_hidden").value != ""){
                //Adcionando observação do orçamento caso não tenha nenhuma observação no conhecimento
                $("obs_lin1").value = $("obs_orcamento_hidden").value;
            }
        }

        if ($("obs_fisco_lin1").value == "" && $("obs_fisco_lin2").value == "" && $("obs_fisco_lin3").value == "" && $("obs_fisco_lin4").value == "" && $("obs_fisco_lin5").value == "") {
            getStIcmsConsigFisco();
        }
    } catch (e) {
        console.log(e);
        alert(e);
    }
}

function getCarregarObs() {
    try {
        
        if ($("obs_lin1").value == '' && $("obs_lin2").value == '' && $("obs_lin3").value == '' && $("obs_lin4").value == '' && $("obs_lin5").value == '') {
            if ($("obs_desc").value != '') {
                var obs = $("obs_desc").value != undefined ? $("obs_desc").value : "";
                obs = replaceAll(obs, "<br>", "<BR>");
                //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
                $("obs_lin1").value = obs.split("<BR>")[0];
                $("obs_lin2").value = obs.split("<BR>")[1];
                $("obs_lin3").value = obs.split("<BR>")[2];
                $("obs_lin4").value = obs.split("<BR>")[3];
                $("obs_lin5").value = obs.split("<BR>")[4];
            }else
                if($("obs_orcamento_hidden").value != ""){
                //Adcionando observação do orçamento caso não tenha nenhuma observação no conhecimento
                $("obs_lin1").value = $("obs_orcamento_hidden").value;
            }
        }
    } catch (e) {
        alert(e);
    }
}

function getObservacao() {

    var ob = "";
    for (i = 1; i < 6; ++i)
        ob += $('obs_lin' + i).value + (i != 5 ? '<br>' : '');
    return ob;
}

function disableFields(fields, isDisable) {
    var arrayFields = fields.split(",");
    for (i = 0; i < fields.split(",").length; ++i)
        $(arrayFields[i]).disabled = isDisable;
}

function limpaExpedidor() {
    $("idexpedidor").value = "0";
    $("exp_rzs").value = "";
    $("exp_codigo").value = "";
    $("exp_cnpj").value = "";
    $("exp_cidade").value = "";
    $("exp_uf").value = "";
}
function limpaRecebedor() {
    $("idrecebedor").value = "0";
    $("rec_rzs").value = "";
    $("rec_codigo").value = "";
    $("rec_cnpj").value = "";
    $("rec_cidade").value = "";
    $("rec_uf").value = "";
}
function localizaexpedidor() {
    windowExpedidor = window.open('./localiza?categoria=loc_cliente&acao=consultar&paramaux2=' + $("dest_uf").value + '&paramaux3=' + $('idcidadedestino').value + '&idlista=78', 'Expedidor',
            'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
}
function localizarecebedor() {
    windowRecebedor = window.open('./localiza?categoria=loc_cliente&acao=consultar&paramaux2=' + $("dest_uf").value + '&paramaux3=' + $('idcidadedestino').value + '&idlista=79', 'Recebedor',
            'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
}


// transferindo JS da tela de jspcadconhecimento, pois não há mais espaços.(19/11/2014)
function tipoDocAnt(valor) {
    if ($("ck_redespacho").checked) {
        if (valor == "c") {
            $("trChaveRedesp").style.display = "";
            $("trOutrosAnt").style.display = "none";
        } else {
            $("trOutrosAnt").style.display = "";
            $("trChaveRedesp").style.display = "none";
        }
    }
}

function compareDate() {
    var teste = eDate.compare($("dtprevisao").value, $("dtemissao").value);
    if (teste < 0) {
        alert("Data de previsão deve ser maior que a emissão!");
        $("dtprevisao").value = "";
    }
}
var countAdiantamento = 0;
function adicionarAdiantamento() {
    if ($("cartaAdiantamentoExtra1").style.display == '') {
        $("cartaAdiantamentoExtra2").style.display = '';
    }
    if ($("cartaAdiantamentoExtra1").style.display == 'none') {
        $("cartaAdiantamentoExtra1").style.display = '';
    }
    $("countAdiantamento").value = countAdiantamento;
}
function averbacao() {
    if ($("ckprotocoloAverbacao").checked == true) {
        $("protocoloAverbacao").disabled = false;
    } else {
        $("protocoloAverbacao").disabled = true;
    }
}
function escondeCTeCancelar(isCancelado) {

    if (isCancelado == null || isCancelado == undefined) {
        isCancelado = false;
    }

    if (isNaN($("serie").value)) {
        $("mostrarCancelado").style.display = "";
    } else if (isCancelado == true) {
        $("mostrarCancelado").style.display = "";
    } else {
        $("mostrarCancelado").style.display = "none";
        $("cancelado").checked = false;
        $("cancelado").value = "false";
        $("lbTitleCancelado").style.display = "none";
        $("motivoCancelamento").style.display = "none";
        $("motivoCancelamento").value = "";
    }
}


function verCarta(idC, stCfe) {
    if (stCfe == 'N') {
        window.open('./cadcartafrete?acao=editar&id=' + idC + '&ex=false', 'Carta_frete', 'top=0,resizable=yes,status=1,scrollbars=1');
    } else {
        window.open("./ContratoFreteControlador?acao=iniciarEditar&id=" + idC, "LocCarta", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
}

function calculaVlRedespachante() {
    var vlRepresentante = 0;
    var totPrest = parseFloat($("total").value);
    var redPeso = getObj("peso").value;
    var red_fretemin = 0;
    var red_vlprecofaixa = 0;
    var red_vlkgate = 0;
    var red_sobfrete = 0;
    var red_sobpeso = 0;
    //Verificando o calculo do Representante de coleta
    var isCalculaReprColeta = true;
    if (parseFloat($('repr_coleta_id').value) > 0) {
        if (isCalculaReprColeta) {
            red_fretemin = parseFloat($('repr_coleta_vlfreteminimo').value);
            red_vlprecofaixa = parseFloat($('repr_coleta_vlprecofaixa').value);
            red_vlkgate = parseFloat($('repr_coleta_vlkgate').value);
            switch (getObj("repr_coleta_tipo_taxa").value) {
                case "2" :
                    $('repr_coleta_valor').readOnly = true;
                    break;
                case "1" :
                    $('repr_coleta_valor').readOnly = true;
                    break;
                case "3" :
                    if ($("comissaoBaixadaColeta").value != '0' && $("comissaoBaixadaColeta").value != '') {
                        $('repr_coleta_valor').readOnly = true;
                    }else{
                        $('repr_coleta_valor').readOnly = false;
                    }
                    break;
            }
            if (parseFloat(vlRepresentante) < parseFloat(red_fretemin)) {
                vlRepresentante = red_fretemin;
            }
        }
    }//Verificando o calculo do Representante de entrega
    var isCalculaReprEntrega = true;
    if (parseFloat($('repr_entrega_id').value) > 0) {
        if (isCalculaReprEntrega) {
            red_fretemin = parseFloat($('repr_entrega_vlfreteminimo').value);
            red_vlprecofaixa = parseFloat($('repr_entrega_vlprecofaixa').value);
            red_vlkgate = parseFloat($('repr_entrega_vlkgate').value);
            switch (getObj("repr_entrega_tipo_taxa").value) {
                case "2" :
                    $('repr_entrega_valor').readOnly = true;
                    break;
                case "1" :
                    $('repr_entrega_valor').readOnly = true;
                    break;
                case "3" :
                    if ($("comissaoBaixada").value != '0' && $("comissaoBaixada").value != '') {
                        $('repr_entrega_valor').readOnly = true;
                    }else{
                        $('repr_entrega_valor').readOnly = false;
                    }
                    break;
            }
            if (parseFloat(vlRepresentante) < parseFloat(red_fretemin)) {
                vlRepresentante = red_fretemin;
            }
        }
    }
}

function bloquearTipoTaxa(alteraTipoFrete) {
    var tp = $("tipoTaxaTabela").value;
    var utiliza = false;
    var utilizaTabelaRemetente = (($("con_tabela_remetente").value == "s" && ($("utilizatipofretetabelarem").value == 't' || $("utilizatipofretetabelarem").value == 'true'))
            || ($("con_tabela_remetente").value == "q" && ($("utilizatipofretetabelarem").value == 't' || $("utilizatipofretetabelarem").value == 'true')));
    if (($("utilizatipofretetabelaconsig").value == 'true') || utilizaTabelaRemetente) {
        utiliza = true;
    }
    var client_tariff_id = $("client_tariff_id").value;
    if ($("tipoTaxaTabela").value != null && $("tipoTaxaTabela").value != undefined && (tp != '-1') && utiliza && (client_tariff_id != '0')) {
        $("tipotaxa").disabled = true;
    } else {
        if (alteraTipoFrete) {
            $("tipotaxa").disabled = false;
        } else {
            $("tipotaxa").disabled = true;
        }
    }
}

function getCidadeOrigem() {
    if ($('contipoorigem').value == 'f') {
        $('cid_origem').value = $('fi_cidade').value;
        $('uf_origem').value = $('fi_uf').value;
        $('idcidadeorigem').value = $('fi_idcidade').value;
        $('codigo_ibge_origem').value = $('cod_ibge').value;

    } else {
        if ($('cliente_coleta_id').value == '0') {
            $("cid_origem").value = $("rem_cidade").value;
            $("uf_origem").value = $("rem_uf").value;
            $("idcidadeorigem").value = $("remidcidade").value;
            $('codigo_ibge_origem').value = $('cod_ibge').value;
        } else {
            $("cid_origem").value = $("cidade_coleta").value;
            $("uf_origem").value = $("uf_coleta").value;
            $("idcidadeorigem").value = $("cidade_coleta_id").value;
            $('codigo_ibge_origem').value = $('cod_ibge').value;
        }
//        validarCidadeOrigemExpedidorRedespachoImportar(true); comentei pq esta sobrescrevendo a cidade de origem
    }



}

function alteraTipoProduto() {
    alteraTipoTaxa($('tipotaxa').value);
}

function limparComposicaoFrete() {
    $('client_tariff_id').value = '0';
    $("valor_taxa_fixa").value = "0.00";
    $("valor_itr").value = "0.00";
    $("valor_despacho").value = "0.00";
    $("valor_ademe").value = "0.00";
    $("valor_peso_unitario").value = "0.00";
    $("valor_peso").value = "0.00";
    $("valor_frete").value = "0.00";
    $("valor_sec_cat").value = "0.00";
    $("valor_outros").value = "0.00";
    $("valor_gris").value = "0.00";
    $("valor_pedagio").value = "0.00";
    $("valor_tde").value = "0.00";
    $("valor_desconto").value = "0.00";
    $("total").value = "0.00";
    $("base_calculo").value = "0.00";
    $("icms").value = "0.00";
    $("pisCofins").value = "0.00";
    //Comentado para não zerar o valor quando não tiver tabela de preço.
//    $("peso_taxado").value = "0.00";
//    $("cobrarTde").checked = false; comentei por causa da historia 2751

}

function testa_numero(obj) {
    var num = virgulaToPonto((obj.value.trim() == "" ? "0" : obj.value.trim()));
    obj.value = (isNaN(num) ? "0" : num);
}

function replaceAll(string, token, newtoken) {
    while (string.indexOf(token) != -1) {
        string = string.replace(token, newtoken);
    }
    return string;
}
function alterouCampoDependente(nomeCampo) {

    var tax = $('tipotaxa').value;
    switch (nomeCampo) {
        //peso/kg
        case "peso":
            if (tax == "0" || tax == "1" || tax == "2" || tax == "3" || tax == "4" || tax == "6") {
                if (tarifas.tipo_frete_peso == "f") {
                    alteraTipoTaxa(tax);
                } else {
                    atribuiVlrsDaTaxa(false, tax);
                }
            }
            break;
            //todos menos combinado
        case "vlmercadoria" :
            atribuiVlrsDaTaxa(false, tax);
            break;
            //cubagem/carreta
        case "cub_metro" :
            if (tax == "0" || tax == "1" || tax == "2" || tax == "4" || tax == "6") {
                if (tarifas.tipo_frete_peso == "f")
                    alteraTipoTaxa(tax);
                else
                    atribuiVlrsDaTaxa(false, tax);
            }
            break;
        case "cub_base"  :
            atribuiVlrsDaTaxa(false, tax);
            break;
        case "cub_altura" :
            calculaCubagemMetro();
            if (parseFloat($("cub_metro").value) > 0)
                atribuiVlrsDaTaxa(false, tax);
            break;
        case "cub_largura" :
            calculaCubagemMetro();
            if (parseFloat($('cub_metro').value) > 0)
                atribuiVlrsDaTaxa(false, tax);
            break;
        case "cub_comprimento" :
            calculaCubagemMetro();
            if (parseFloat($('cub_metro').value) > 0)
                atribuiVlrsDaTaxa(false, tax);
            break;
        case "volume"      :
            if (tax == "4")
                atribuiVlrsDaTaxa(false, tax);
            break;
    }
    calculaPesoTaxadoCtrc();
}//alterouCampoDependente()  >>>>>>> .r12125

function calculaCubagemMetro() {
    var _cubMetro = (parseFloat($('cub_altura').value) * parseFloat($('cub_comprimento').value) * parseFloat($('cub_largura').value) * parseFloat($('volume').value));
    _cubMetro = roundABNT(_cubMetro, 4);
    $('cub_metro').value = _cubMetro;
}
/*Informa se foi/será adicionado o icms no conhecimento*/
function adicionouIcms() {
    return ($("addicms").value == "true");
}
function removeOptionSelected(id) {
    var elSel = $(id);
    for (var i = elSel.length - 1; i >= 0; i--) {
        elSel.remove(i);
    }
}

function calculaPesoTaxadoCtrc() {
    var carregaPesoCubado = 0;
    if ($('tipoTransporte').value == 'a') {
        carregaPesoCubado = (parseFloat($('cub_base').value) == 0 ? 0 : (parseFloat($('cub_metro').value) * parseFloat(1000000)) / parseFloat($('cub_base').value));
    } else {
        carregaPesoCubado = parseFloat($('cub_base').value) * parseFloat($('cub_metro').value);
    }
    carregaPesoCubado = parseFloat(carregaPesoCubado);
    $('cub_peso').value = roundABNT(carregaPesoCubado, 3);
    $('peso_taxado').value = (parseFloat($('peso').value) > parseFloat($('cub_peso').value) ? $('peso').value : $('cub_peso').value);
     if($("tipo_arredondamento_peso_con").value == 'a'){
             $('peso_taxado').value = Math.round( $('peso_taxado').value);
        }else if($("tipo_arredondamento_peso_con").value == 'c'){
             $('peso_taxado').value = Math.ceil( $('peso_taxado').value);
        }
}

function isCalculaPauta() {
    if ($('pauta_consignatario').value == 't' || $('pauta_consignatario').value == 'true' || $('pauta_consignatario').value == true) {
        return true;
    } else {
        return false;
    }
}

function carregarAjaxTalaoCheque(textoresposta, elemento) {
    if (textoresposta == "-1") {
        alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
        return false;
    } else {
        var lista = jQuery.parseJSON(textoresposta);
        var listCheque = lista.list[0].documento;
        var talaoCheque;
        var slct = elemento;
        var isPrimeiro = true;
        var valor = "";
        removeOptionSelected(elemento.id);
        slct.appendChild(Builder.node('OPTION', {value: valor}, valor));
        var length = (listCheque != undefined && listCheque.length != undefined ? listCheque.length : 1);
        for (var i = 0; i < length; i++) {
            if (length > 1) {
                talaoCheque = listCheque[i];
                valor += (isPrimeiro ? talaoCheque : "");
            } else {
                talaoCheque = listCheque;
            }
            if (talaoCheque != null && talaoCheque != undefined) {
                slct.appendChild(Builder.node('OPTION', {value: talaoCheque}, talaoCheque));
            }
            isPrimeiro = false;
        }
        slct.value = valor;
    }
}


function removerDespCarta(idxCarta, isCarta) {
    if (isCarta) {
        if (confirm("Deseja mesmo excluir esta despesa do contrato de frete?")) {
            Element.remove('trDespCarta_' + idxCarta);
            Element.remove('trDespCarta2_' + idxCarta);
        }
    } else {
        if (confirm("Deseja mesmo excluir esta despesa do adiantamento de viagem?")) {
            Element.remove('trDespADV_' + idxCarta);
        }
    }
}
function removerADV(idxADV) {
    if (confirm("Deseja mesmo excluir este adiantamento de viagem?")) {
        Element.remove('trADV_' + idxADV);
    }
}


function localizaPesoContainer(id) {
    var idContainer = id;
    function e(transport) {
        var resp = transport.responseText;
        espereEnviar("", false);
        $("peso_container").value = resp.split("!!")[0];
        $("valor_container").value = resp.split("!!")[1];
        // Element.update($("pesoContainer").value,resp.split("!!")[0]);
    }
    if (idContainer != 0) {
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./jspcadconhecimento.jsp?acao=localizarPesoContainer&idContainer=" + idContainer, {
                method: 'post',
                onSuccess: e,
                onError: e
            });
        });
    }
}
function mostrarEsconde(plusMinus) {
    if (plusMinus == "minus_rep2") {
        $("minus_rep2").style.display = "none";
        $("plus_rep2").style.display = "";
        $("repColeta2").style.display = "none";
        $("repEntrega2").style.display = "none";
    }
    else {
        $("minus_rep2").style.display = "";
        $("plus_rep2").style.display = "none";
        $("repColeta2").style.display = "";
        $("repEntrega2").style.display = "";
    }
}
function nextSelo() {
    function ev(resp, st) {
        if (st == 200) {
            if (resp.split("<=>")[0] == "-1") {
                alert("Erro interno");
                return false;
            }
            if (resp.split("<=>")[1] != "")
                alert(resp.split("<=>")[1]);
            else {
                getObj("numero_selo").value = resp.split("<=>")[0];
            }
        }
        else
            alert("Status " + st + "\n\nNão conseguiu acessar o servidor!");
    }
    if ($('is_controla_sequencia_selo').value == 't' || $('is_controla_sequencia_selo').value == 'true') {
        var seriectrc = getObj("serie").value;
        if (seriectrc == "")
            alert("Digite uma série válida!");
        else
            requisitaAjax("./ConhecimentoControlador?acao=obter_prox_selo&seriectrc=" + seriectrc + "&idfilial=" + $('idfilial').value + "&controlaSelo=" + $('is_controla_sequencia_selo').value, ev);
    } else {
        $('numero_selo').value = '';
    }
}

function mostrarCamposComposicaoFrete(permissaoAlteraPreco){
    if ($("tipotaxa").value == '3' && $("client_tariff_id").value == 0) {
        disableFields("incluirIcms,incluirFederais,valor_taxa_fixa,valor_itr,valor_despacho,valor_ademe,valor_peso,valor_frete,valor_sec_cat,valor_outros,valor_gris,valor_pedagio,cobrarTde,valor_tde,valor_desconto",false);        
    }else if(permissaoAlteraPreco == false){
        disableFields("incluirIcms,incluirFederais,valor_taxa_fixa,valor_itr,valor_despacho,valor_ademe,valor_peso,valor_frete,valor_sec_cat,valor_outros,valor_gris,valor_pedagio,cobrarTde,valor_tde,valor_desconto",true);
    }
}

function rotasNoMaps(index){
    var destinos = "";
    if($("endereco_id").value==0){
        destinos = $("dest_endereco").value+" "+$("dest_cep").value+" "+$("dest_bairro").value+" "+$("dest_cidade").value+" "+$("dest_uf").value;
    }else{
        destinos = $("end_logradouro").value+" "+$("end_num_log").value+" "+$("end_cep").value+" "+$("end_bairro").value+" "+$("end_cidade").value+" "+$("end_uf").value;
    }
    var origem =  $("latitude_"+index).value+","+$("longitude_"+index).value;
    if(origem == undefined || origem == null || origem.indexOf("null") > -1){
        alert("Não foi possível identificar o local da baixa, campos latitude e/ou longitudes não foi encontrado!");
        return false;
    }
   
    if (origem == null || destinos == null)
	    return null;
    var url = "http://maps.google.com/maps?saddr="+origem + "&daddr="+destinos;
    window.open(url,"googMaps","toolbar=no,location=no,scrollbars=no,resizable=no");
     
}

function popImg(idconhecimento, ocorrencia_id){
    window.open('./ImagemControlador?acao=carregar&idconhecimento='+idconhecimento + '&ocorrencia_id=' + ocorrencia_id,
    'imagensConhecimento','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
}

function localizaremetente(){
    ufRemetenteAnterior = $('rem_uf').value; 
    var idfilial= $("idfilial").value;
    windowRemetente = window.open('./localiza?categoria=loc_cliente&acao=consultar&paramaux2='+$("dest_uf").value+'&paramaux3='+$('idcidadedestino').value+'&paramaux4='+idfilial+'&idlista=3','Remetente','top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
}

function localizaaeroportoorigem(){
    post_cad = window.open('./localiza?acao=consultar&idlista=73','Aeroporto_Origem','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1'); 
}
function localizaaeroportodestino(){
    post_cad = window.open('./localiza?acao=consultar&idlista=73','Aeroporto_Destino','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');  
}

function verPontosControle(data){
    numeroCTe = $("nfiscal").value;
    window.open('./PontoControleControlador?acao=visualizarPontoControle&numeroCTe='+numeroCTe+'&tipoPesquisa=cte&dataDe='+data+'&dataAte='+data, 'pontoControle' , 'top=0,resizable=yes,status=1,scrollbars=1');
}

function getPrevisaoEntrega(){
    if ($('prazo_rota').value == '0'){
        if ($('client_tariff_id').value == '0'){
                $("dtprevisao").value = '';
            }
        }else{
            $("dtprevisao").value = incData($('dtemissao').value, $('prazo_rota').value);
        }
}

function isMostraSelo(){
	if ($('is_controla_sequencia_selo').value == 't' || $('is_controla_sequencia_selo').value == 'true'){
		$('numero_selo').style.display = '';
		$('lbSelo').innerHTML = 'Nº Selo:';
	}else{
		$('numero_selo').style.display = 'none';
		$('lbSelo').innerHTML = '';
	}
}

function localizafilial(){
      post_cad = window.open('./localiza?acao=consultar&idlista=8&paramaux='+jQuery("#tipoTransporte").val(),'Filial','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
}
  
function localizahistorico(){
    post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico','top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

function validarCidadeOrigemExpedidor(alteraTipoTax){
    var cidExped = $("exp_cidade").value;
    var ufExped = $("exp_uf").value;
    var cidOrig = $("cid_origem").value;
    var ufOrig = $("uf_origem").value;
    var idCidadeExped = $("exp_idcidade").value;
    setTimeout(function(){
        if(cidExped != cidOrig || ufExped != ufOrig){
           if(confirm("A cidade do expedidor ("+cidExped+"/"+ufExped+") é diferente da cidade de origem ("+cidOrig+"/"+ufOrig+"). Deseja atualizar a cidade de origem do CT-e?")){

               $("cid_origem").value = cidExped;
               $("uf_origem").value = ufExped;
               $("idcidadeorigem").value = idCidadeExped;
               if (alteraTipoTax) {
                   alteraTipoTaxa($("tipotaxa").value);
               }

              getPrevisaoEntrega();
              getPautaFiscalConhecimento();
              atribuiCfopPadrao();            
              getDadosIcms();
              getStIcmsConsig(); 
           }  
        }
   },100);   
}   
function validarCidadeDestinoRecebedor(alteraTipoTax){
    var cidReceb = $("rec_cidade").value;
    var ufReceb = $("rec_uf").value;
    var cidDest = $("cid_destino").value;
    var ufDest = $("uf_destino").value;
    var idCidadeReceb = $("rec_idcidade").value;
     setTimeout(function(){
        if(cidReceb != cidDest || ufReceb != ufDest){
           if(confirm("A cidade do recebedor ("+cidReceb+"/"+ufReceb+") é diferente da cidade de destino ("+cidDest+"/"+ufDest+"). Deseja atualizar a cidade de destino do CT-e?")){

               $("cid_destino").value = cidReceb;
               $("uf_destino").value = ufReceb;
               $("idcidadedestino").value = idCidadeReceb;
               if (alteraTipoTax) {
                   alteraTipoTaxa($("tipotaxa").value);
               }

              getPrevisaoEntrega();
              getPautaFiscalConhecimento();
              atribuiCfopPadrao();            
              getDadosIcms();
              getStIcmsConsig(); 
           } 
        }
     },100);       
}

function validarCidadeOrigemExpedidorRedespacho(alteraTipoTax){
    var cidExp = $("red_cidade").value;
    var ufExp = $("red_uf").value;
    var cidOrigem = $("cid_origem").value;
    var ufOrigem = $("uf_origem").value;
    var idCidadeExp = $("red_cidade_id").value;
    var idRotaViagem = $('red_rota_viagem_id').value;
    var rotaViagem = $('red_rota_viagem').value;
    var rotaTaxas = $('red_rota_taxas').value;
    var redRzs = $("red_rzs").value;
    var redCod = $("red_codigo").value;
    var redCnpj = $("red_cnpj").value;
    var idRedespacho = $("idredespacho").value;
    
     setTimeout(function(){
        if (idCidadeExp != 0) {
            if (cidExp != null || cidExp != "") {
                if(cidExp != cidOrigem || ufExp != ufOrigem){
                   if(confirm("A cidade do expedidor ("+cidExp+"/"+ufExp+") é diferente da cidade de origem ("+cidOrigem+"/"+ufOrigem+"). Deseja atualizar a cidade de origem do CT-e?")){
                       $("cid_origem").value = cidExp;
                       $("uf_origem").value = ufExp;
                       $("idcidadeorigem").value = idCidadeExp;
                       $('id_rota_viagem').value = idRotaViagem;
                       $('rota_viagem').value = rotaViagem;
                       $('json_taxas').value = rotaTaxas;
                   } 
                }
            }
        }
        //informações do expedidor na aba dados do CT-e
        //tirei do if, pois mesmo se o usuario não quiser alterar a cidade as informações nos dados do ct-e serão atualizadas - Historia 2995
        $("exp_rzs").value = redRzs;
        $("exp_codigo").value = redCod;
        $("exp_cnpj").value = redCnpj;
        $("exp_cidade").value = cidExp;
        $("exp_uf").value = ufExp;
        $("idexpedidor").value = idRedespacho;
        $("cid_destino").value = $("dest_cidade").value;
        $("uf_destino").value = $("dest_uf").value;
        $("idcidadedestino").value = ($("cidade_destino_id").value == 0 ? $("idcidadedestino").value : $("cidade_destino_id").value);
        if (alteraTipoTax) {
            alteraTipoTaxa($("tipotaxa").value);
        }

        getPrevisaoEntrega();
        getPautaFiscalConhecimento();
        atribuiCfopPadrao();
        getDadosIcms();
        getStIcmsConsig(); 
        limpaRecebedor();
     },100);       
}

function validarCidadeDestinoRecebedorRedespacho(alteraTipoTax){
    var cidReceb = $("red_cidade").value;
    var ufReceb = $("red_uf").value;
    var cidDest = $("cid_destino").value;
    var ufDest = $("uf_destino").value;
    var idCidadeReceb = $("red_cidade_id").value;
    var idRotaViagem = $('red_rota_viagem_id').value;
    var rotaViagem = $('red_rota_viagem').value;
    var rotaTaxas = $('red_rota_taxas').value;
    var redRzs = $("red_rzs").value;
    var redCod = $("red_codigo").value;
    var redCnpj = $("red_cnpj").value;
    var idRedespacho = $("idredespacho").value;
    
    setTimeout(function(){
        if (idCidadeReceb != 0) {
            if(cidReceb != cidDest || ufReceb != ufDest){
                if(confirm("A cidade do recebedor ("+cidReceb+"/"+ufReceb+") é diferente da cidade de destino ("+cidDest+"/"+ufDest+"). Deseja atualizar a cidade de destino do CT-e?")){
                    $("cid_destino").value = cidReceb;
                    $("uf_destino").value = ufReceb;
                    $("idcidadedestino").value = idCidadeReceb;
                    $('id_rota_viagem').value = idRotaViagem;
                    $('rota_viagem').value = rotaViagem;
                    $('json_taxas').value = rotaTaxas;
                }
            }
        }
        //informações do recebedor na aba dados do CT-e
        //tirei do if, pois mesmo se o usuario não quiser alterar a cidade as informações nos dados do ct-e serão atualizadas - Historia 2995
        $("rec_rzs").value = redRzs;
        $("rec_codigo").value = redCod;
        $("rec_cnpj").value = redCnpj;
        $("rec_cidade").value = cidReceb;
        $("rec_uf").value = ufReceb;
        $("idrecebedor").value = idRedespacho;
        $("cid_origem").value = $("rem_cidade").value;
        $("uf_origem").value = $("rem_uf").value;
        $("idcidadeorigem").value = $("remidcidade").value;
        if (alteraTipoTax) {
            alteraTipoTaxa($("tipotaxa").value);
        }
            getPrevisaoEntrega();
            getPautaFiscalConhecimento();
            atribuiCfopPadrao();            
            getDadosIcms();
            getStIcmsConsig(); 
            limpaExpedidor();
    },100);       
}

function validarCidadeOrigemExpedidorRedespachoImportar(alteraTipoTax){
    var cidExp = $("red_cidade").value;
    var ufExp = $("red_uf").value;
    var cidOrigem = $("cid_origem").value;
    var ufOrigem = $("uf_origem").value;
    var idCidadeExp = $("red_cidade_id").value;
    var idRotaViagem = $('red_rota_viagem_id').value;
    var rotaViagem = $('red_rota_viagem').value;
    if ($("ck_redespacho") != null && $("ck_redespacho").checked){
        setTimeout(function(){
            if (cidExp != null && cidOrigem != null) {
                if(cidExp != cidOrigem || ufExp != ufOrigem){

                   $("cid_origem").value = cidExp;
                   $("uf_origem").value = ufExp;
                   $("idcidadeorigem").value = idCidadeExp;
                   $('id_rota_viagem').value = idRotaViagem;
                   $('rota_viagem').value = rotaViagem;

                   if (alteraTipoTax) {
                       alteraTipoTaxa($("tipotaxa").value);
                   }

                  getPrevisaoEntrega();
                  getPautaFiscalConhecimento();
                  atribuiCfopPadrao();            
                  getDadosIcms();
                  getStIcmsConsig(); 
                }
            }
        },100);       
    }
}

    function validarBloqueioVeiculo(filtrosV){
        var filtros = filtrosV;
        for(var i = 0; i<= filtros.split(",").length ; i++){
            var filtro = filtros.split(",")[i];
            if($("is_bloqueado").value == "t" && filtro == "veiculo"){
                        setTimeout(function(){
                        alert("O veículo " + $("vei_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idveiculo").value = "0";
                        $("vei_placa").value = "";
                        },100);
            }
            if($("is_bloqueado").value == "t" && filtro == "carreta"){
                        setTimeout(function(){
                        alert("A carreta " + $("car_placa").value + " está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idcarreta").value = "0";
                        $("car_placa").value = "";
                        },100);
            }
            if($("is_bloqueado").value == "t" && filtro == "bitrem"){
                        setTimeout(function(){
                        alert("O Bi-trem " + $("bi_placa").value + " está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("motivo_bloqueio").value);
                        $("idbitrem").value = "0";
                        $("bi_placa").value = "";
                        },100);
            }
        }        
    }
    function validarBloqueioVeiculoMotorista(filtrosM){
        var filtros = filtrosM;
        for(var i = 0; i<= filtros.split(",").length ; i++){
            var filtro = filtros.split(",")[i];
        if($("is_moto_veiculo_bloq").value == "t" && filtro == "veiculo_motorista"){
            setTimeout(function (){
                   alert("O veiculo " + $("vei_placa").value + ", vinculado ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_veiculo_bloq_motivo").value);
                   $("idveiculo").value = "0";
                   $("vei_placa").value = "";
            },100);
        }else if($("is_moto_carreta_bloq").value == "t" && filtro == "carreta_motorista"){
                setTimeout(function (){
                    alert("A carreta " + $("car_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueada e não poderá ser utilizada no lançamento. \r\n Motivo: " + $("moto_carreta_bloq_motivo").value);
                    $("idcarreta").value = "0";
                    $("car_placa").value = "";
                 
                },100);
        }else if($("is_moto_bitrem_bloq").value == "t" && filtro == "bitrem_motorista"){
                setTimeout(function (){
                    alert("O bi-trem " + $("bi_placa").value + ", vinculada ao motorista " +$("motor_nome").value+ ", está bloqueado e não poderá ser utilizado no lançamento. \r\n Motivo: " + $("moto_bitrem_bloq_motivo").value);
                    $("idbitrem").value = "0";
                    $("bi_placa").value = "";
                 
                },100);
            }
        }
    }
    function montagemDomChaves(){
        var allChaves = $("chaveAcessoExtraAll").value;
        var max = $("maxChavesAcesso").value;
        var quantidade = 0;
            for(var i = 0; i < allChaves.split(",").length; i++){
                if(allChaves.split(",")[i] != ""){

                addDomChavesAcesso(allChaves.split(",")[i]);
                quantidade ++;
                }
            }
            return quantidade;
    }
    
    var countChaves = 0;
    function salvarChaves(max){
        var chavesAgrupadas = "";
        var contador = ($("red_chave_acesso").value == "" ? 0 : 1);
        for(var i = 0; i<= max; i++){
            
            if($("chaveAcessoExtra_"+i) != null && $("chaveAcessoExtra_"+i).value != ""){
                
                if(i == 0 && $('red_chave_acesso').value.trim() == ''){
                    $("red_chave_acesso").value = $("chaveAcessoExtra_"+i).value;
                }else{   
                    chavesAgrupadas = chavesAgrupadas + $("chaveAcessoExtra_"+i).value + ",";
                    contador++;
                }
                
            }
        }
        $("chaveAcessoExtraAll").value = chavesAgrupadas;
        $("lblChavesAcesso").innerHTML = "QTD chaves : "+contador;
    }    
    function montarDivChaveAcesso(){
        countChaves = 0;
     var promp = document.createElement("DIV");
    promp.id = "promptRedChave";
    document.body.appendChild(promp);
    var obj = document.getElementById("promptRedChave").style;
    obj.zIndex = "3";
    obj.position = "absolute";
    obj.backgroundColor = "#FFFFFF";
    obj.left = "50%";
    obj.top = "20%";
    obj.width = "25%";
    //obj.height = "80%";
    var cmdHtml = "";
    //Criando a tabela
    cmdHtml = 
    "<table width='100%' class='bordaFina'>"+
    "<tr> "
        +"<td class='Tabela' align='center'> Chaves de Acesso de Redespacho"+
        " </td>"+
        "</tr>" +
            "<tr>"+
                "<td class='TextoCampos' id='chavesExtrasRed'>" +
                    "<div id='divChaves' class='conteudo'> " +
                        "<table class='bordaFina' width='100%'>" +
                            "<tr>"+
                                "<td class= 'CelulaZebra2'>"+
                                    "<img src='img/add.gif' class='imagemLink' title='Adicionar uma nova Chave de Acesso' onclick='addDomChavesAcesso("+''+")';>\n\
                                </td>"+
                                "<td class='CelulaZebra2'><label><b> Adicionar Chave de Acesso</b></label>"+
                                "</td>"+ 
                            "</tr>"+
                            "<tr> "+
                                "<td> "+
                                "</td>"+
                                "<td> "+
                                "<div class= 'conteudo'  style='max-height: 250px; overflow: auto; height: 500px;'>"+
                                    "<fieldset>"+
                                    "<table id='tbChavesAcessoRed' name='tbChavesAcessoRed' width='100%' class='bordaFina'>"+
                                    "</table>"+
                                    "</fieldset>"+
                                        "</div>"+
                                "</td>"+
                            "</tr>"+
                        "</table>"+
                    "</div>"+
                "</td>"+
            "</tr>"
        +"</td>"
    +"</tr>"+
    "<tr class='CelulaZebra2' align='center'>" +
    "<td align='center'><input name='salvar_nf' type='button' class='botoes' id='salvar_chaves' value='SALVAR' style='text-align: left'>"+
    "<label>                             </label>"+
    "<input name='fechar_chave' type='button' class='botoes' id='fechar_chave' value='FECHAR' style='text-align: right'></td>" +
    "</tr>" 
    +"</table> "                   
    ;
    blockInterface(true);
    document.getElementById("promptRedChave").innerHTML = cmdHtml;
    document.getElementById("promptRedChave").style.display = "";
    countChaves = montagemDomChaves();
    
     document.getElementById("salvar_chaves").onclick = function(){salvarChaves(countChaves);
        document.getElementById("promptRedChave").style.display='none';
        blockInterface(false);
     }
        document.getElementById("fechar_chave").onclick = function(){
        document.getElementById("promptRedChave").style.display='none';
        blockInterface(false);
        }
    }
    
    function addDomChavesAcesso(chaveAcesso){
//        if (chaveAcesso != "" && chaveAcesso != undefined) {
            var trVariasChaves = Builder.node("tr",{
                name: "trChaveExtra_"+countChaves,
                id: "trChaveExtra_"+countChaves
            });
            var tdVariasChaves = Builder.node("td",{
                name: "tdChaveExtra_"+countChaves,
                id: "tdChaveExtra_"+countChaves,
                class: "CelulaZebra2",
                colspan: "4"
            });
            var lblvariasChaves = Builder.node("label",{});
            var inpVariasChaves =  Builder.node("input",{
                name: "chaveAcessoExtra_"+countChaves,
                id: "chaveAcessoExtra_"+countChaves,
                class: "inputtexto",
                type: "text",
                size: "44",
                maxlength: "44",
                value: (chaveAcesso != undefined ? chaveAcesso : ""),
                onkeypress: "seNaoIntReset(this, '')"
            });

            lblvariasChaves.innerHTML = " Chave : ";
                countChaves++;
                tdVariasChaves.appendChild(lblvariasChaves);
                tdVariasChaves.appendChild(inpVariasChaves);
                trVariasChaves.appendChild(tdVariasChaves);
                $("tbChavesAcessoRed").appendChild(trVariasChaves);
//        }
    }
        function minutaCortesia(){if($('tipoConhecimento').value == 'b'){alert("Atenção: CT-e não aparecerá em contas a receber!");}}
        function verificarCalculoAliquotaInterna(){alert("Cálculo: (Alíquota interna - Alíquota) x Base cálc. / 100");}
        function verificarCalculoAliquotaPobreza(){alert("Cálculo: Alíquota pobreza x Base cálc. / 100");}
        
  function localizaredespacho(){
      if ($('dest_uf').value == ''){alert('Informe o destinatário corretamente.');return null;
      }var idfilial= $("idfilial").value; var idCidadeOrigem = $("idcidadeorigem").value; $('aliquota_rodoviario').value = $('aliquota').value;
      post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=6&paramaux='+$("idfilial").value+'&paramaux2='+$("dest_uf").value+'&paramaux3='+$('iddestinatario').value+'&paramaux4='+idfilial+'&paramaux5='+idCidadeOrigem,'Redespacho','top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
  }

// altera os dados do consignatario quando eh selecionado no campo "pago" SIM ou NAO
function setFretePago(opcao){
     var taxaAlterada = $("idconsignatario").value != (opcao ? $("idremetente").value : $("iddestinatario").value);
     $("fretepago_sim").checked = opcao;
     $("fretepago_nao").checked = !opcao;
     var prefixo = (opcao ? "rem" : "dest");
     $("idconsignatario").value = (opcao ? $("idremetente").value : $("iddestinatario").value);
     $("idvendedor").value = (opcao ? $("idvenremetente").value : $("idvendestinatario").value); 
     $("ven_rzs").value = (opcao ? $("venremetente").value : $("vendestinatario").value);//$("comissao_vendedor").value = (opcao ? $("vlvenremetente").value :$("vlvendestinatario").value);  
     $("con_unificada_modal_vendedor").value = (opcao ? $("rem_unificada_modal_vendedor").value : $("des_unificada_modal_vendedor").value);
     $("con_comissao_rodoviario_fracionado_vendedor").value = (opcao ? $("rem_comissao_rodoviario_fracionado_vendedor").value : $("des_comissao_rodoviario_fracionado_vendedor").value);
     $("con_comissao_rodoviario_lotacao_vendedor").value = (opcao ? $("rem_comissao_rodoviario_lotacao_vendedor").value : $("des_comissao_rodoviario_lotacao_vendedor").value);
     $("vlvenconsignatario").value = (opcao ? $("vlvenremetente").value : $("vlvendestinatario").value);
     $("con_codigo").value = $((opcao?"rem":"des")+"_codigo").value;
     $("con_rzs").value = $(prefixo+"_rzs").value;
     $("con_tipotaxa").value = $(prefixo+"_tipotaxa").value;
     $("con_cidade").value = $(prefixo+"_cidade").value;
     $("con_uf").value = $(prefixo+"_uf").value;
//     $("con_cnpj").value = formatCpfCnpj($(prefixo+"_cnpj").value,true,true); comentei esta linha, pois estava formatando cpf/cnpj sempre fotmato cnpj e os valores ja chegam no formato correta
     $("con_cnpj").value = $(prefixo+"_cnpj").value;
     $("contipofpag").value = ($(prefixo+"tipofpag").value == 'n' ? 'v' : $(prefixo+"tipofpag").value);
     $("tipofpag").value = ($(prefixo+"tipofpag").value == 'n' ? 'v' : $(prefixo+"tipofpag").value);
     $("contipoorigem").value = $(prefixo+"tipoorigem").value;
     $("contabelaproduto").value = $(prefixo+"tabelaproduto").value;
     $("con_analise_credito").value = (opcao?$("rem_analise_credito").value:$("des_analise_credito").value);
     $("con_valor_credito").value = (opcao?$("rem_valor_credito").value:$("des_valor_credito").value);
     $("con_st_icms").value = $((opcao?"rem":"des")+"_st_icms").value;
     $("con_reducao_icms").value = $((opcao?"rem":"des")+"_reducao_icms").value;
     $("con_is_in_gsf_598_03_go").value = $((opcao?"rem":"des")+"_is_in_gsf_598_03_go").value;
     $("con_is_bloqueado").value = (opcao?$("rem_is_bloqueado").value:$("des_is_bloqueado").value);
     $("con_tabela_remetente").value = (opcao?$("rem_tabela_remetente").value:$("des_tabela_remetente").value);
     $("con_inclui_peso_container").value = (opcao?$("rem_inclui_peso_container").value:$("des_inclui_peso_container").value);
     $("pauta_consignatario").value = (opcao?$("pauta_remetente").value:$("pauta_destinatario").value);
     $("con_tipo_cfop").value = (opcao?$("rem_tipo_cfop").value:$("des_tipo_cfop").value);   
     $("tipo_arredondamento_peso_con").value = $("tipo_arredondamento_peso_"+prefixo).value; 
     $("con_insc_est").innerHTML = (opcao ? $("rem_insc_est").value : $("dest_insc_est").value);
     $("is_redespacho_pago").checked = false;
     $("con_obs").value = (opcao?$("rem_obs").value:$("dest_obs").value);     
     $("con_tipo_tributacao").value = $(prefixo+"_tipo_tributacao").value;
     if ($("con_tabela_remetente").value == "n") {
         $("utilizatipofretetabelaconsig").value = (opcao? $("utilizatipofretetabelarem").value : $("utilizatipofretetabeladest").value);          
     }else{
         $("utilizatipofretetabelaconsig").value = ($("utilizatipofretetabelarem").value);  
     }
     $("con_is_especie_serie_modal").value = $(prefixo + "_is_especie_serie_modal").value;
     $("con_especie_cliente").value = $(prefixo + "_especie_cliente").value;
     $("con_serie_cliente").value = $(prefixo + "_serie_cliente").value;
     $("con_modal_cliente").value = $(prefixo + "_modal_cliente").value;
     definirComissaoVendedor();
     getCidadeOrigem();
     getTipoProdutos();
     pagtoAvista();
     getDadosIcms();
     getStIcmsConsig();
     if ($("idconsignatario").value != ""){
	 	$("tipotaxa").value = $(prefixo+"_tipotaxa").value;
                showFields($("tipotaxa").value);
	 	seNaoFloatReset($(prefixo+"_cub_base"), 0);
		$("cub_base").value = $(prefixo+"_cub_base").value;
	 } //se jah tem uma condicao de pagt
     if ($(prefixo+"_pgt") != null && !wasNull($(prefixo+"_pgt").value)){
        $("con_pgt").value = $(prefixo+"_pgt").value;
		parent.frameAbaixo.refazerDtsVenc();
     }
     atribuiCfopPadrao();
     if (taxaAlterada){
         alteraTipoTaxa($('tipotaxa').value);
     }
     $("isCalculaSecCat").checked = true;//tem que vi por default true sempre, so fica falso se desmarcar o botão
     if($("mensagem_usuario_cte_"+(opcao?"rem":"des")).value != null && $("mensagem_usuario_cte_"+(opcao?"rem":"des")).value != "" && $("mensagem_usuario_cte_"+(opcao?"rem":"des")).value != undefined){setTimeout(function(){alert("Mensagem importante para emissão de CT-e do cliente "+ $(prefixo+"_rzs").value+": "+$("mensagem_usuario_cte_"+(opcao?"rem":"des")).value);}),50}
     localizaOrcamento();
     getPautaFiscalConhecimento();
     mudarSerieCliente();
}

function redespacho(houve, carregaCfop) {
    $("is_redespacho_pago").disabled = !houve;
    var estaMarcado = $("ck_redespacho").checked;//limpando se nao tiver checado
    if (!estaMarcado) {
        $('aliquota').value = $('aliquota_rodoviario').value;
        $("is_redespacho_pago").checked = false;
        $("idredespacho").value = "";
        $("red_rzs").value = "";
        $("red_cidade").value = "";
        $("red_uf").value = "";
        $("red_cnpj").value = "";
        $("ctoredespacho").value = "";
        $("redespacho_valor").value = "0.00";
        $("redespacho_valor_icms").value = "0.00";
        $("trChaveRedesp").style.display = "none";
        $("trOutrosAnt").style.display = "none";
        $("trConsigVazia").style.display = "none";
    } else {
        tipoDocAnt($("tpDocAnt").value);
        $("trConsigVazia").style.display = "";
        if ($("idredespacho").value == $("idexpedidor").value) {
            $("exp").checked = true;
        } else
        if ($("idredespacho").value == $("idrecebedor").value) {
            $("rec").checked = true;
        }
    }
    $("localiza_red").disabled = !houve;
    $("ctoredespacho").disabled = !houve;
    $("ctoredespacho").style.background = (!houve ? "#EEEEEE" : "#FFFFFF");
    $("redespacho_valor").disabled = !houve;
    $("redespacho_valor").style.background = (!houve ? "#EEEEEE" : "#FFFFFF");
    $("redespacho_valor_icms").disabled = !houve;
    $("redespacho_valor_icms").style.background = (!houve ? "#EEEEEE" : "#FFFFFF");
    $("red_codigo").disabled = !houve;
    $("red_codigo").style.background = (!houve ? "#EEEEEE" : "#FFFFFF");
    $("red_rzs").disabled = !houve;
    $("red_cnpj").disabled = !houve;
    $("tipoDocRed").disabled = !houve;
    $("red_serie").disabled = !houve;
    $("red_subserie").disabled = !houve;
    $("red_dtemissao").disabled = !houve;
    $("exp").disabled = !houve;
    $("rec").disabled = !houve;
    $("tpDocAnt").disabled = !houve;
    if (carregaCfop || carregaCfop == undefined) {
        atribuiCfopPadrao();
    }
}

  function fechaClientesWindow(){
     if (windowRemetente != null && !windowRemetente.closed)
	 	windowRemetente.close();
	 if (windowDestinatario != null && !windowDestinatario.closed)
	 	windowDestinatario.close();
	 if (windowConsignatario != null && !windowConsignatario.closed)
	 	windowConsignatario.close();
	 if (windowCidade != null && !windowCidade.closed)
	 	windowCidade.close();         
	 window.focus();         
  }
  
var countDespesaADV = 0;
function incluiDespesaADV() {
    var descricaoClassName = ((countDespesaADV % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
    var trDespADV = Builder.node("TR", {name: "trDespADV_" + countDespesaADV, id: "trDespADV_" + countDespesaADV, className: descricaoClassName});
    //TD Lixo
    var tdDespADVLixo = Builder.node("TD", {width: "2%"});
    var imgDespADVLixo = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerDespCarta(" + countDespesaADV + ",false);"});
    tdDespADVLixo.appendChild(imgDespADVLixo);
    //TD Valor
    var tdDespADVValor = Builder.node("TD", {width: "8%"});
    var vlDespADV = Builder.node("INPUT", {type: "text", id: "vlDespADV_" + countDespesaADV, name: "vlDespADV_" + countDespesaADV, size: "5", maxLength: "12", value: "0.00", className: "fieldmin", onchange: "seNaoFloatReset($('vlDespADV_" + countDespesaADV + "'), 0.00);calcularFreteCarreteiro();"});
    tdDespADVValor.appendChild(vlDespADV);
    //TD Fornecedor
    var tdDespFornADV = Builder.node("TD", {width: "45%"});
    var idFornDespADV = Builder.node("INPUT", {type: "hidden", id: "idFornDespADV_" + countDespesaADV, name: "idFornDespADV_" + countDespesaADV, size: "10", maxLength: "60", value: "0", className: "inputReadOnly8pt", readOnly: true});
    var fornDespADV = Builder.node("INPUT", {type: "text", id: "fornDespADV_" + countDespesaADV, name: "fornDespADV_" + countDespesaADV, size: "24", maxLength: "60", value: "Fornecedor", className: "inputReadOnly8pt", readOnly: true});
    var btFornDespADV = Builder.node("INPUT", {className: "botoes", id: "localizaFornecedorDespADV_" + countDespesaADV, name: "localizaFornecedorDespADV_" + countDespesaADV, type: "button", value: "...", onClick: "javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_ADV_" + countDespesaADV + "','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespFornADV.appendChild(idFornDespADV);
    tdDespFornADV.appendChild(fornDespADV);
    tdDespFornADV.appendChild(btFornDespADV);
    //TD Plano
    var tdDespPlanoADV = Builder.node("TD", {width: "45%"});
    var idPlanoDespADV = Builder.node("INPUT", {type: "hidden", id: "idPlanoDespADV_" + countDespesaADV, name: "idPlanoDespADV_" + countDespesaADV, size: "10", maxLength: "60", value: "0", className: "inputReadOnly8pt", readOnly: true});
    var planoDespADV = Builder.node("INPUT", {type: "text", id: "planoDespADV_" + countDespesaADV, name: "planoDespADV_" + countDespesaADV, size: "24", maxLength: "60", value: "Plano Custo", className: "inputReadOnly8pt", readOnly: true});
    var btPlanoDespADV = Builder.node("INPUT", {className: "botoes", id: "localizaPlanoDespADV_" + countDespesaADV, name: "localizaPlanoDespADV_" + countDespesaADV, type: "button", value: "...", onClick: "javascript:window.open('./localiza?acao=consultar&idlista=20','Plano_ADV_" + countDespesaADV + "','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespPlanoADV.appendChild(idPlanoDespADV);
    tdDespPlanoADV.appendChild(planoDespADV);
    tdDespPlanoADV.appendChild(btPlanoDespADV);
    trDespADV.appendChild(tdDespADVLixo);
    trDespADV.appendChild(tdDespADVValor);
    trDespADV.appendChild(tdDespFornADV);
    trDespADV.appendChild(tdDespPlanoADV);
    $("tbDespesaADV").appendChild(trDespADV);
    countDespesaADV++;
}  

function inverterRemDes(idRem, idDes, consignatarioTerceiro){     
   localizaRemetenteCodigo('idcliente', idDes, false); // chama o ajax para carregar o remetente com o id do dest
   inverterDesRem(idRem,consignatarioTerceiro); // chama a função inverterDesRem, passando o id do rem 
 }
function inverterDesRem(idRem, consignatarioTerceiro){
    localizaDestinatarioCodigo('idcliente', idRem, false, false, (consignatarioTerceiro)); // chama o ajax para carregar o destinatário com o id do rem        
}
//Existe mais de uma função com o nome de verCliente, então renomeei verClienteCtrc e vi que só é chamado em jscadconheimento
function verClienteCtrc(tipo) {
        var mostrar = false;
        var idCliente = 0;
        if (tipo == 'R' && $('rem_codigo').value != '') {
            idCliente = $('rem_codigo').value;
            mostrar = true;
        } else if (tipo == 'D' && $('des_codigo').value != '') {
            idCliente = $('des_codigo').value;
            mostrar = true;
        } else if (tipo == 'C' && $('con_codigo').value != '') {
            idCliente = $('con_codigo').value;
            mostrar = true;
        } else if (tipo == 'RD' && $('red_codigo').value != '') {
            idCliente = $('red_codigo').value;
            mostrar = true;
        } else if (tipo == 'E' && $('exp_codigo').value != '') {
            idCliente = $('exp_codigo').value;
            mostrar = true;
        } else if (tipo == 'REC' && $('rec_codigo').value != '') {
            idCliente = $('rec_codigo').value;
            mostrar = true;
        }
        if (mostrar)
            window.open('./cadcliente?acao=editar&id=' + idCliente, 'Cliente', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function localizaCidadeOrigem(){windowCidade = window.open('./localiza?acao=consultar&paramaux='+$('idcidadedestino').value+'&paramaux2='+$('uf_destino').value+'&idlista=11','Cidade','top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');}
    function localizaCidadeDestino(){windowCidade = window.open('./localiza?acao=consultar&paramaux='+$('idcidadeorigem').value+'&paramaux2='+$('uf_origem').value+'&idlista=12','Cidade_Destino','top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');}    
    
    
    function escondeCalculaSecCat(cobraSecCat) {
        if (cobraSecCat == 'p' && $('tipoTransporte').value == 'r') {
            visivel($("isCalculaSecCat"));
            visivel($("lbCalculaSecCat"));
        }else{
            invisivel($("isCalculaSecCat"));
            invisivel($("lbCalculaSecCat"));
        }
    }
    
    function limpaSecCat(){
        if (!$("isCalculaSecCat").checked){
            $("valor_sec_cat").value = "0,00";
        }
    }

/**Atualiza a soma das notas fiscais @syntax updateSum(changedField) @param changedField Flag boolean para invocar "alterouCampoDependente()" se preciso. */
function updateSum(changedField) {
    // cuidado ao alterar algo nessa function pois ela é chamada para tela de conhecimento e nfse pela rotina de entrega local/importar coleta.
    if ($("peso") !== null && $("peso") !== undefined) {
        $("peso").value = sumPesoNotes('0');
    }
    if ($("vlmercadoria") !== null && $("vlmercadoria") !== undefined) {
        $("vlmercadoria").value = sumValorNotes('0');
    }
    if ($("volume") !== null && $("volume") !== undefined) {
        $("volume").value = sumVolumeNotes('0');
    }
    if ($("cub_metro") !== null && $("cub_metro") !== undefined) {
        $("cub_metro").value = sumMetroNotes('0');
    }
    if (changedField) {
        alterouCampoDependente("peso");
        alterouCampoDependente("vlmercadoria");
        calculaVlRedespachante();
    }
}

function zerarContratoImpostos() {
    $('cartaImpostos').value = '0.00';
    $("valorINSS").value = '0.00';
    $("valorSEST").value = '0.00';
    $("valorIR").value = '0.00';
}


function calculaImpostos() {
    calcularRetencoes();
    var isRetencaoImpostoOpeCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "true" ? true :false);
    var isReter = $("chk_reter_impostos").checked;

    if (isReter) {
        var inss = calculaInss();
        calculaSest(inss.baseCalculo);
        calculaIR(inss);
        $('cartaImpostos').value = formatoMoeda(parseFloat($("valorINSS").value) + parseFloat($("valorSEST").value) + parseFloat($("valorIR").value));
    } else {
        zerarContratoImpostos();
    }
    if (isRetencaoImpostoOpeCFe) {
        zerarContratoImpostos();
//        $("chk_reter_impostos").checked = false;
    }
}

function getPautaFiscalConhecimento() {
    if (isCalculaPauta()) {
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport) {
            var resp = transport.responseText;
            espereEnviar("", false);
            //se deu algum erro na requisicao...
            $('valor_pauta_fiscal').value = resp;
            if (resp == -1.0) {
                alert('Não existe pauta fiscal cadastrada, o valor do ICMS não será calculado.');
                return false;
            } else if (resp == 0.0) {
                alert('O valor da pauta fiscal é 0,00, favor verificar se está correto com o setor fiscal da empresa.');
            }
        }//funcao e()
        espereEnviar("", true);
        new Ajax.Request("ConhecimentoControlador?acao=carregaPautaFiscal&km=" + $("distancia_km").value + "&idfilial=" + $("idfilial").value, {
            method: 'post',
            onSuccess: e,
            onError: e
        });
    } else {
        $('valor_pauta_fiscal').value = '0.0';
    }
}

function getDadosIcms() {
    var ufOrigemIcms = $('uf_origem').value;
    var ufDestinoIcms = $('uf_destino').value;
    var idCidadeDestinoCtrc = $('idcidadedestino').value;
    var isDestinatarioIsento = ($('dest_insc_est').value.trim() == '' || $('dest_insc_est').value.trim() == 'ISENTO' || $('dest_insc_est').value.trim() == 'ISENTA');
    var tpTransporteIcms = $('tipoTransporte').value;
    var aliquotaIcmsJs = null;
    var ativarICMSGoias = ($("is_IN_GSF_1298_16_GO").value == "true" || $("is_IN_GSF_1298_16_GO").value == "t");
    var remetenteUf = $("rem_uf").value;
    var filialUf = $("fi_uf").value;
    var isCif = ($("idconsignatario").value == $("idremetente").value);
    var tipoTribCon = $("con_tipo_tributacao").value;
    if (ufOrigemIcms != '' && ufDestinoIcms != '') {
        aliquotaIcmsJs = getUfAliquotaIcmsCtrc(ufOrigemIcms, ufDestinoIcms, idCidadeDestinoCtrc, true, tipoTribCon);
        //Verificando se o destinatário é ISENTO de IE
        if (aliquotaIcmsJs != null) {
            if (tpTransporteIcms == 'a') {
                if (isDestinatarioIsento) {
                    $('aliquota').value = (aliquotaIcmsJs.aliquotaAereoCpf == null || aliquotaIcmsJs.aliquotaAereoCpf == undefined ? aliquotaIcmsJs.aliquotaAereoPessoaFisica : aliquotaIcmsJs.aliquotaAereoCpf);
                    $('aliquota_aereo').value = (aliquotaIcmsJs.aliquotaAereoCpf == null || aliquotaIcmsJs.aliquotaAereoCpf == undefined ? aliquotaIcmsJs.aliquotaAereoPessoaFisica : aliquotaIcmsJs.aliquotaAereoCpf);
                    $('aliquota_rodoviario').value = (aliquotaIcmsJs.aliqCpf == null || aliquotaIcmsJs.aliqCpf == undefined ? aliquotaIcmsJs.aliquotaPessoaFisica : aliquotaIcmsJs.aliqCpf);
                } else {
                    $('aliquota').value = aliquotaIcmsJs.aliquotaAereo;
                    $('aliquota_aereo').value = aliquotaIcmsJs.aliquotaAereo;
                    $('aliquota_rodoviario').value = (aliquotaIcmsJs.aliq == null || aliquotaIcmsJs.aliq == undefined ? aliquotaIcmsJs.aliquota : aliquotaIcmsJs.aliq);
                }
                $('config_reducao_base_icms').value = '0.00';
                $('obs_desc').value = (aliquotaIcmsJs.obs.descricao == undefined ? '' : replaceAll(aliquotaIcmsJs.obs.descricao, "\n", "<BR>"));
                $('obs_desc_fisco').value = (aliquotaIcmsJs.obsFisco.descricao == undefined ? '' : replaceAll(aliquotaIcmsJs.obsFisco.descricao, "\n", "<BR>"));
            } else {
                if (isDestinatarioIsento) {
                    $('aliquota').value = (aliquotaIcmsJs.aliqCpf == null || aliquotaIcmsJs.aliqCpf == undefined ? aliquotaIcmsJs.aliquotaPessoaFisica : aliquotaIcmsJs.aliqCpf);
                    $('aliquota_rodoviario').value = (aliquotaIcmsJs.aliqCpf == null || aliquotaIcmsJs.aliqCpf == undefined ? aliquotaIcmsJs.aliquotaPessoaFisica : aliquotaIcmsJs.aliqCpf);
                    $('aliquota_aereo').value = (aliquotaIcmsJs.aliquotaAereoCpf == null || aliquotaIcmsJs.aliquotaAereoCpf == undefined ? aliquotaIcmsJs.aliquotaAereoPessoaFisica : aliquotaIcmsJs.aliquotaAereoCpf);
                } else {
                    $('aliquota').value = (aliquotaIcmsJs.aliq == null || aliquotaIcmsJs.aliq == undefined ? aliquotaIcmsJs.aliquota : aliquotaIcmsJs.aliq);
                    $('aliquota_rodoviario').value = (aliquotaIcmsJs.aliq == null || aliquotaIcmsJs.aliq == undefined ? aliquotaIcmsJs.aliquota : aliquotaIcmsJs.aliq);
                    $('aliquota_aereo').value = aliquotaIcmsJs.aliquotaAereo;
                }
                $('config_reducao_base_icms').value = aliquotaIcmsJs.reducaoBaseIcms;
                $('obs_desc').value = (aliquotaIcmsJs.obs.descricao == undefined ? '' : replaceAll(aliquotaIcmsJs.obs.descricao, "\n", "<BR>"));
                $('obs_desc_fisco').value = (aliquotaIcmsJs.obsFisco.descricao == undefined ? '' : replaceAll(aliquotaIcmsJs.obsFisco.descricao, "\n", "<BR>"));
                getObs();
            }
            $("stIcmsConfig").value = aliquotaIcmsJs.situacaoTributavel.id;
        } else {
            $('aliquota').value = '-1.00';
            $('aliquota_aereo').value = '-1.00';
            $('aliquota_rodoviario').value = '-1.00';
            $('config_reducao_base_icms').value = '0.00';
            $('obs_desc').value = '';
        }
        if (filialUf.toUpperCase() == "GO" && !ativarICMSGoias && remetenteUf.toUpperCase() == "GO" && isCif) {
            $('aliquota').value = '0.00';
            $('aliquota_aereo').value = '0.00';
            $('aliquota_rodoviario').value = '0.00';
        }
    }
}

function mostraCalculoCombinado(isMostrar) {
    $('divLbCombinado').style.display = "none";
    $('divCombinado').style.display = "none";
    if (isMostrar) {
        $('divLbCombinado').style.display = "";
        $('divCombinado').style.display = "";
    }
}

function submeterConsulta(chaveConsulta) {
    abrirMax('http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=&cte=' + chaveConsulta, 'popConsultaCompleta');
}

function editarPgtoComissao(id, podeExcluir) {
    window.open("./cadpagamento_comissao.jsp?acao=editar&id=" + id + "&podeExcluir=" + podeExcluir, "Comissao", "height=500,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1");
}

function alertMsg(msgText) {
    alert(msgText);
    habilitaSalvar(true);
    return false;
}

function localizadestinatario() {
    if ($('rem_uf').value == '') {
        alert('Informe o remetente corretamente.');
        return null;
    }

    var idfilial = $("idfilial").value;
    // paramaux1 = é utilizado para trazer a aliquota de icms
    // paramaux2 = é utilizado para trazer a aliquota de icms 
    // paramaux3 = é utilizado para trazer a rota                                                      
    windowDestinatario = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=4&paramaux=' + $("idfilial").value + '&paramaux2=' + $("uf_origem").value + '&paramaux3=' + $('idcidadeorigem').value + '&paramaux4=' + idfilial, 'Destinatario', 'top=80,left=150,height=500,width=700,resizable=yes,status=1,scrollbars=1');
}

/*Faz o cálculo do icms e retorna a soma com o total.*/
  function getDiferencaIcms() {
    var podeCalcularIcms = ($("total").value > 0);
    return formatoMoeda((podeCalcularIcms ? $("total").value / ((100 - $("aliquota").value) / 100) : 0));
}
/*Usado nos campos que são dependentes no cálculo, evento "onChange()". Obs.: Veja o arquivo "calculos_opcao-frete.txt" para informacoes adicionais.*/
function pagouRedespacho(pagou) {
    if (!parseInt($("idredespacho").value) > 0) {
        return null;
    }
    $("red_st_icms").value = $("st_icms").value;
    $("idconsignatario").value = (pagou ? $("idredespacho").value : $("idconsignatario").value);
    $("idvendedor").value = (pagou ? $("idvenredespacho").value : $("idvendedor").value);
    $("ven_rzs").value = (pagou ? $("venredespacho").value : $("ven_rzs").value);
    $("con_unificada_modal_vendedor").value = (pagou ? ($("red_unificada_modal_vendedor").value) : $("con_unificada_modal_vendedor").value);
    $("con_reducao_icms").value = (pagou ? ($("rem_reducao_icms").value) : $("con_reducao_icms").value);
    $("con_is_in_gsf_598_03_go").value = (pagou ? ($("red_is_in_gsf_598_03_go").value) : $("con_is_in_gsf_598_03_go").value);
    $("con_comissao_rodoviario_fracionado_vendedor").value = (pagou ? ($("red_comissao_rodoviario_fracionado_vendedor").value) : $("con_comissao_rodoviario_fracionado_vendedor").value);
    $("con_comissao_rodoviario_lotacao_vendedor").value = (pagou ? ($("red_comissao_rodoviario_lotacao_vendedor").value) : $("con_comissao_rodoviario_lotacao_vendedor").value);
    $("vlvenconsignatario").value = (pagou ? ($("vlvenredespacho").value) : $("vlvenconsignatario").value);
    definirComissaoVendedor();
    $("con_rzs").value = (pagou ? $("red_rzs").value : $("con_rzs").value);
    $("con_codigo").value = (pagou ? $("red_codigo").value : $("con_codigo").value);
    $("con_cidade").value = (pagou ? $("red_cidade").value : $("con_cidade").value);
    $("con_uf").value = (pagou ? $("red_uf").value : $("con_uf").value);
    $("con_cnpj").value = formatCpfCnpj((pagou ? $("red_cnpj").value : $("con_cnpj").value), true, true);
    $("con_pgt").value = (pagou ? $("red_pgt").value : $("con_pgt").value);
    $("contipoorigem").value = (pagou ? $("redtipoorigem").value : $("contipoorigem").value);
    $("contabelaproduto").value = (pagou ? $("redtabelaproduto").value : $("contabelaproduto").value);
    $("fretepago_sim").checked = (pagou ? true : $("fretepago_sim").checked);
    $("fretepago_nao").checked = (pagou ? false : $("fretepago_nao").checked);
    $("con_analise_credito").value = (pagou ? $("red_analise_credito").value : $("con_analise_credito").value);
    $("con_st_icms").value = (pagou ? $("red_st_icms").value : $("con_st_icms").value);
    var stRedespacho = ($("red_st_icms").value == 0 || $("red_st_icms").value == '' ? $("stIcms").value : $("red_st_icms").value);
    $("stIcms").value = (pagou ? stRedespacho : $("con_st_icms").value);
    $("con_valor_credito").value = (pagou ? $("red_valor_credito").value : $("con_valor_credito").value);
    $("con_is_bloqueado").value = (pagou ? $("red_is_bloqueado").value : $("con_is_bloqueado").value);
    $("con_tabela_remetente").value = (pagou ? $("red_tabela_remetente").value : $("con_tabela_remetente").value);
    $("pauta_consignatario").value = (pagou ? $("pauta_redespacho").value : $("pauta_consignatario").value);
    $("con_insc_est").innerHTML = (pagou ? $("red_insc_est").innerHTML : $("con_insc_est").innerHTML);
    getCidadeOrigem();
    getTipoProdutos();
    $("con_tipotaxa").value = (pagou ? ($("red_tipotaxa").value == '-1' ? '<%= carregaconh ? conh.getTipoTaxa() : -1%>' : $("red_tipotaxa").value) : $("con_tipotaxa").value);
    $("tipotaxa").value = ($("con_tipotaxa").value == '' || $("con_tipotaxa").value == 'undefined' || $("con_tipotaxa").value == undefined ? '-1' : $("con_tipotaxa").value);
    seNaoFloatReset($("red_cub_base"), 0);
    $("cub_base").value = (pagou ? $("red_cub_base").value : "");
    $("con_tipo_cfop").value = (pagou ? $("red_tipo_cfop").value : $("con_tipo_cfop").value);
    if ($("con_tabela_remetente").value == "n") {
        $("utilizatipofretetabelaconsig").value = (pagou ? $("utilizatipofretetabelared").value : $("utilizatipofretetabelaconsig").value);
    } else {
        $("utilizatipofretetabelaconsig").value = ($("utilizatipofretetabelarem").value);
    }
    $("st_credito_presumido").value = (pagou ? $("st_red_credito_presumido").value : $("st_cli_credito_presumido").value);
    $("con_tipo_tributacao").value = (pagou ? $("red_tipo_tributacao").value : $("con_tipo_tributacao").value);
    $("con_obs_fisco").value = $("red_obs_fisco").value;
    $("tipotaxa").onchange();
    $("con_is_especie_serie_modal").value = $((pagou ? "red" : "con") + "_is_especie_serie_modal").value;
    $("con_especie_cliente").value = $((pagou ? "red" : "con") + "_especie_cliente").value;
    $("con_serie_cliente").value = $((pagou ? "red" : "con") + "_serie_cliente").value;
    $("con_modal_cliente").value = $((pagou ? "red" : "con") + "_modal_cliente").value;
    getDadosIcms();
    getStIcmsConsig();
    parent.frameAbaixo.refazerDtsVenc();
    atribuiCfopPadrao();
    mudarSerieCliente();
}

function getStIcmsConsigFisco() {
    if ($('con_obs_fisco').value != '') {
        var obsFisco = replaceAll($('con_obs_fisco').value, "\r\n", "<BR>");
        obsFisco = replaceAll(obsFisco, "<br>", "<BR>");
        obsFisco = replaceAll(obsFisco, "<br/>", "<BR>");
        if (replaceAll(obsFisco, "<BR>", "") != undefined || replaceAll(obsFisco, "<BR>", "") != '') {
            //Tratamento das observações por motivo de estar vindo andefined e hoje tem duas formas de vim a separação com <BR> e <br>.
            $('obs_fisco_lin1').value = obsFisco.split('<BR>')[0] != undefined ? (obsFisco.split('<BR>').length >= 0 ? obsFisco.split('<BR>')[0] : "") : "";
            $('obs_fisco_lin2').value = obsFisco.split('<BR>')[1] != undefined ? (obsFisco.split('<BR>').length >= 1 ? obsFisco.split('<BR>')[1] : "") : "";
            $('obs_fisco_lin3').value = obsFisco.split('<BR>')[2] != undefined ? (obsFisco.split('<BR>').length >= 2 ? obsFisco.split('<BR>')[2] : "") : "";
            $('obs_fisco_lin4').value = obsFisco.split('<BR>')[3] != undefined ? (obsFisco.split('<BR>').length >= 3 ? obsFisco.split('<BR>')[3] : "") : "";
            $('obs_fisco_lin5').value = obsFisco.split('<BR>')[4] != undefined ? (obsFisco.split('<BR>').length >= 4 ? obsFisco.split('<BR>')[4] : "") : "";
        }
    } else if ($("obs_desc_fisco").value != '') {
        var obsFisco = $("obs_desc_fisco").value != undefined ? $("obs_desc_fisco").value : "";
        obsFisco = replaceAll(obsFisco, "<br>", "<BR>");
        //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
        $("obs_fisco_lin1").value = obsFisco.split("<BR>")[0];
        $("obs_fisco_lin2").value = obsFisco.split("<BR>")[1];
        $("obs_fisco_lin3").value = obsFisco.split("<BR>")[2];
        $("obs_fisco_lin4").value = obsFisco.split("<BR>")[3];
        $("obs_fisco_lin5").value = obsFisco.split("<BR>")[4];
    }
}

function colocarReadOnly(isImportadoEdi) {
    jQuery('#is_importado_edi').val(isImportadoEdi);

    // Verifica se o CT-e foi criado importando o EDI
    if (jQuery('#is_travar_campos').val() === 'true' && isImportadoEdi === 'true') {
        readOnly($('des_codigo'), 'inputReadOnly8pt');
        readOnly($('dest_rzs'), 'inputReadOnly8pt');
        readOnly($('dest_cnpj'), 'inputReadOnly8pt');
        $('localiza_dest').disabled = true;
    }
}

function mudarSerieCliente() {
    if ($("con_is_especie_serie_modal").value === "t" || $("con_is_especie_serie_modal").value === "true") {
        jQuery('#tipoTransporte').val($("con_modal_cliente").value).trigger('change');
        $('especie').value = $("con_especie_cliente").value;
        $('serie').value = $("con_serie_cliente").value;
        // Chama a função para carregar o próximo número do CT-e.
        nextCtrc();
    }
}    

function jsonTaxasCtrc() {    
    var valorInputTaxa = $("json_taxas").value;
    var tabela;
    var taxa_rota = 0;
    if (valorInputTaxa != undefined && valorInputTaxa != '') {
        tabela = JSON.parse($("json_taxas").value);
        if (tabela) {
            for (let i in tabela) {
                if (tabela[i].tipo_veiculo == $("tipo_veiculo_motorista").value) {
                    taxa_rota = parseFloat(tabela[i].valor);
                }
            }
        }
    }
    return taxa_rota;
}
