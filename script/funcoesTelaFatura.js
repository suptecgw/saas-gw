var countOcorrencia = 0;
function addRelacionamento(descricao, protocolo, fone, contato, data, hora, numeroOrcamento,usuario, id){
        countOcorrencia++;
        
        var _table = Builder.node("TABLE", {width: "100%", className: "bordaFina", id: "tbRelacionamento_"+ countOcorrencia, name:"tbRelacionamento_"+ countOcorrencia});
        var _tBody = Builder.node("TBODY", {id: "tBodyPlano_" + countOcorrencia});
        
        
        var _ip1a = Builder.node("img", {
            id: "imgPlus",
            src: "img/plus.jpg",
            onclick: "escEspDivCont('trContaDespesa_" + countOcorrencia + "',this);escEspDivCont('trPlanoCusto_" + countOcorrencia + "',this)"
        });

        var _tr1 = Builder.node("TR", {id: "tr_" + countOcorrencia});//tr
        var _tr2 = Builder.node("TR", {id: "trContaDespesa_" + countOcorrencia, style: "display:none" });//tr
        
        var _tr3_1 = Builder.node("TR", {id: "tr_" + countOcorrencia, className: "celula"});//tr
        var _tr3 = Builder.node("TR", {id: "trPlanoCusto_" + countOcorrencia, style: "display:none"});//trPlanoCusto_
        //td's
        var _td0 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", width: "3%"});
        var _td1 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", width: "8%"});
        var _td2 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", width: "10%"});
        var _td3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", width: "5%"});
        var _td4 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", width: "15%"});
        var _td5 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", width: "10%"});
        var _td6 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colspan: 1});
        var _td7 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colspan: 4});

        var _lbProduto = Builder.node('label', {name: 'lbProtocolo_' + countOcorrencia, id: 'lbProtocolo_' + countOcorrencia});
        _lbProduto.innerHTML = "Protocolo:";
        
        var _dProtocolo = Builder.node('label', {name: 'dprotocolo_' + countOcorrencia, id: 'dprotocolo_' + countOcorrencia});
        _dProtocolo.innerHTML = protocolo;
        
        var _lbData = Builder.node('label', {name: 'lbdata_' + countOcorrencia, id: 'lbdata_' + countOcorrencia});
        _lbData.innerHTML = "Data:";
        
        var _dData = Builder.node("label", {name: "ddata_" + countOcorrencia, id: "ddata_" + countOcorrencia, onKeyPress:"fmtDate(this, event)", onKeyDown:"fmtDate(this, event)", onKeyUp:"fmtDate(this, event)"});
        _dData.innerHTML = data;
        _dData.innerHTML += " às ";
        _dData.innerHTML += hora;
        
        
        var _lbHora = Builder.node('label', {name: 'lbHora_' + countOcorrencia, id: 'lbhora_' + countOcorrencia});
        _lbHora.innerHTML = "Usuário:";
        
        var _dHora = Builder.node("label", {name: "dhora_" + countOcorrencia, id: "dhora_" + countOcorrencia});
        _dHora.innerHTML = (usuario ? usuario : '');
        
        var _inpLixo = Builder.node("img", {
            id: "relacionamentoLixo_" + countOcorrencia,
            name: "relacionamentoLixo_" + countOcorrencia,
            type: "button",
            className: "imagemLink",
            src: "img/lixo.png",
            onclick: "javascript:tryRequestToServer(function(){excluirRelacionamento(" + countOcorrencia + ")});"
        });       
        var _idRelacionamento = Builder.node("input", {
            id: "idRelacionamento_" + countOcorrencia,
            name: "idRelacionamento_" + countOcorrencia,
            value: id,
            type:"hidden"
        });       
        _td0.appendChild(_ip1a);
        
        _td1.appendChild(_lbProduto);
        _td2.appendChild(_dProtocolo);
        
        _td3.appendChild(_lbData);
        _td4.appendChild(_dData);
        
        _td5.appendChild(_lbHora);
        _td6.appendChild(_dHora);
        
        _td7.appendChild(_inpLixo);
        _td7.appendChild(_idRelacionamento);
        
        _tr1.appendChild(_td0);
        _tr1.appendChild(_td1);
        _tr1.appendChild(_td2);
        _tr1.appendChild(_td3);
        _tr1.appendChild(_td4);
        _tr1.appendChild(_td5);
        _tr1.appendChild(_td6);
        _tr1.appendChild(_td7);
        
        _tBody.appendChild(_tr3_1);
        _table.appendChild(_tBody);

        var _td00 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left" });
        var _td11 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td22 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", style:"overflow-x: hidden;text-overflow: ellipsis;max-width:120px;"});
        var _td33 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td44 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td55 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td66 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colspan:"3"});
        var _td77 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td88 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        
        var _lbContato = Builder.node('label', {name: 'lbContato_' + countOcorrencia, id: 'lbContato_' + countOcorrencia});
        _lbContato.innerHTML = "Contato:";
        
        var _dContato = Builder.node('label', {name: 'dpContato_' + countOcorrencia, id: 'dContato_' + countOcorrencia});
        _dContato.innerHTML = contato;
        
        var _lbFone = Builder.node('label', {name: 'lbFone_' + countOcorrencia, id: 'lbFone_' + countOcorrencia});
        _lbFone.innerHTML = "Fone:";
        
        var _dFone = Builder.node("label", {name: "dFone_" + countOcorrencia, id: "dFone_" + countOcorrencia});
        _dFone.innerHTML = fone;
        
        var _lbNumeroOco = Builder.node('label', {name: 'lbNumeroOco_' + countOcorrencia, id: 'lbNumeroOco_' + countOcorrencia});
        _lbNumeroOco.innerHTML = "N. Ocorrencia:";
        
        var _dNumeroOco = Builder.node("label", {name: "dNumeroOco_" + countOcorrencia, id: "dNumeroOco_" + countOcorrencia});
        _dNumeroOco.innerHTML = numeroOrcamento;
        
//        var _lbUsuario = Builder.node('label', {name: 'lbUsuario_' + countOcorrencia, id: 'lbUsuario_' + countOcorrencia});
//        _lbUsuario.innerHTML = "Usuário:";
//        
//        var _dUsuario = Builder.node("label", {name: "dUsuario_" + countOcorrencia, id: "dUsuario_" + countOcorrencia});
//        _dUsuario.innerHTML = usuario;
        
        
        _td11.appendChild(_lbContato);
        _td22.appendChild(_dContato);
        
        _td33.appendChild(_lbFone);
        _td44.appendChild(_dFone);
        
        _td55.appendChild(_lbNumeroOco);
        _td66.appendChild(_dNumeroOco);
        
//        _td77.appendChild(_lbUsuario);
//        _td88.appendChild(_dUsuario);
        
        _tr2.appendChild(_td00);
        _tr2.appendChild(_td11);
        _tr2.appendChild(_td22);
        _tr2.appendChild(_td33);
        _tr2.appendChild(_td44);
        _tr2.appendChild(_td55);
        _tr2.appendChild(_td66);
//        _tr2.appendChild(_td77);
//        _tr2.appendChild(_td88);

        var _td00_3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td11_3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        var _td22_3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left", colspan: 8});
        var _td33_3 = Builder.node("TD", {className: "textoCamposNoAlign", align: "left"});
        
        var _lbDescricao = Builder.node('label', {name: 'lbDescricao_' + countOcorrencia, id: 'lbDescricao_' + countOcorrencia});
        _lbDescricao.innerHTML = "Descricao:";
        
//        var _dDescricao = Builder.node("label", {name: "dDescricao_" + countOcorrencia, id: "dDescricao_" + countOcorrencia});
        
        
        _td11_3.appendChild(_lbDescricao);
        jQuery(_td22_3).html(descricao.replace(/\n/g,'<br>'));
    
        _tr3.appendChild(_td00_3);
        _tr3.appendChild(_td11_3);
        _tr3.appendChild(_td22_3);
//        _tr3.appendChild(_td33_3);

        $("bodyRelacionamento").appendChild(_tr1);
        $("bodyRelacionamento").appendChild(_tr2);
        $("bodyRelacionamento").appendChild(_tr3);
        $("maxRelacionamento").value = countOcorrencia;
        
        
        if (countOcorrencia == 1) {
            if ($("trContaDespesa_" + countOcorrencia).style.display == '' && $("trPlanoCusto_" + countOcorrencia).style.display == '') {
                $("trContaDespesa_" + countOcorrencia).style.display = 'none';
                $("trPlanoCusto_" + countOcorrencia).style.display == 'none'
                _ip1a.src = "img/plus.jpg";
            } else {
                $("trContaDespesa_" + countOcorrencia).style.display = '';
                $("trPlanoCusto_" + countOcorrencia).style.display = ''
                _ip1a.src = "img/minus.jpg";
            }
        }
}

function aceitouExcluirCTe(id, trId) {
    jQuery.post(homePath + '/FaturaControlador', {
        'acao': 'excluirCTeFatura',
        'fatura_id': faturaId,
        'parcel_id': id
    }, function (data) {
        if (data) {
            var json = JSON.parse(data);
            var tr = jQuery('#' + trId);

            tr.fadeOut(function () {
                tr.remove();

                // Atualizar os valores
                atualizarValorFatura();
                chamarAlert(json['mensagem']);
            });
        }
    });
}

function atualizarValorFatura() {
    var valorFatura = 0;

    var tds = jQuery('div[id^=td_valor_parcel_]');

    tds.each(function () {
        valorFatura += pontoParseFloat(jQuery(this).text());
    });

    var valorFaturaFormatado = valorFatura.toLocaleString('pt-BR', {minimumFractionDigits: 2});

    jQuery('#lbtotal').text(valorFaturaFormatado);
    jQuery('#lbliq').text(valorFatura.toFixed(2));
    jQuery('#lb_qtd').text(tds.size());

    if (jQuery('.excluir-cte-fatura').size() <= 1) {
        jQuery('.excluir-cte-fatura').css('visibility', 'hidden');
    }
}

jQuery(document).ready(function () {
    jQuery('#tbDocs').on('click', '.excluir-cte-fatura', function () {
        var elemento = jQuery(this);
        var tr = elemento.parent().parent();

        var numeroCTe = tr.find('.linkEditar').text();
        var idCTe = tr.find('input[name^=id_]').val();

        chamarConfirm('Deseja remover o CT-e ' + numeroCTe + ' da fatura?', 'aceitouExcluirCTe("' + idCTe + '", "' + tr.attr('id') + '")');
    });
});