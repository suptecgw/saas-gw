let countItensIscas = 0;

function ItemIsca(idmovimentacao, data_saida, data_chegada, numero_isca) {
    this.idmovimentacao = (idmovimentacao != undefined && idmovimentacao != null ? idmovimentacao : 0);
    this.data_saida = (data_saida != undefined ? data_saida : $("dtromaneio").value);
    this.data_chegada = (data_chegada != undefined && data_chegada != 'null' ? data_chegada : "");
    this.numero_isca = (numero_isca != undefined ? numero_isca : "");
}

function addIscas(itensIscas) {
    $("trIscas").style.display = "";
    try {
        if (itensIscas == null || itensIscas == undefined) {
            itensIscas = new ItemIsca();
        }

        countItensIscas++;
        //var homePath = $("homePath").value;
        var tabelaBase = $("tbIscas");

        var tr = Builder.node("tr", {
            className: "CelulaZebra2",
            id: "idLinhaIscas_" + countItensIscas
        });

        var td0 = Builder.node("td", {
            align: "center"
        });
        var img0 = Builder.node("img", {
            className: "imagemLink",
            src: "img/lixo.png",
            onClick: "excluirIscas(" + itensIscas.idmovimentacao + "," + countItensIscas + ");"

        });

        td0.appendChild(img0);

        var td1 = Builder.node("td", {
            align: "center"

        });

        var td2 = Builder.node("td", {
            align: "center"

        });

        var td3 = Builder.node("td", {
            align: "center"

        });


        var inpId = Builder.node("input", {
            type: "hidden",
            name: "idIsca_" + countItensIscas,
            id: "idIsca_" + countItensIscas,
            value: "0"
        });

        var inpMovId = Builder.node("input", {
            type: "hidden",
            name: "idMovimentacaoIsca_" + countItensIscas,
            id: "idMovimentacaoIsca_" + countItensIscas,
            value: itensIscas.idmovimentacao
        });

        var inp1 = Builder.node("input", {
            id: "idIscaInput_" + countItensIscas,
            name: "idIscaInput_" + countItensIscas,
            className: "inputtexto",
            type: "text",
            size: "20",
            maxLength: "10",
            value: itensIscas.numero_isca
        });

        readOnly(inp1);

        var inp2 = Builder.node("input", {
            id: "data_isca_saida_" + countItensIscas,
            name: "data_isca_saida_" + countItensIscas,
            className: "fieldDateMin",
            type: "text",
            size: "12",
            onBlur: "alertInvalidDate(this,true)",
            maxLength: "10",
            value: itensIscas.data_saida
        });

        readOnly(inp2)

        var text6 = Builder.node("input", {
            id: "data_isca_chegada_" + countItensIscas,
            name: "data_isca_chegada_" + countItensIscas,
            className: "fieldDateMin",
            type: "text",
            size: "12",
            onBlur: "alertInvalidDate(this,true);validarDataChegada(" + countItensIscas + ")",
            maxLength: "10",
            value: itensIscas.data_chegada
        });


        td1.appendChild(inpId);
        td1.appendChild(inpMovId);
        td1.appendChild(inp1);

        td2.appendChild(inp2);

        td3.appendChild(text6);

        tr.appendChild(td0);
        tr.appendChild(td1);
        tr.appendChild(td2);
        tr.appendChild(td3);


        tabelaBase.appendChild(tr);
        $("maxIsca").value = countItensIscas;
        applyFormatter();
    } catch (ex) {
        alert(ex);
    }
}

function limparIsca(id) {
    $("idIsca_" + id).value = 0;
    $("idIscaInput_" + id).value = "";
}

function addNewIsca() {
    var newIndex = $("maxIsca").value;
    localizaIsca(++newIndex, $("numIsca").value);
}

function localizaIsca(index, valor) {
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(isca) {
        var resp = JSON.parse(isca.responseText);
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (resp["message"] != null) {
            alert(resp["message"]);
            $("numIsca").value = "";
            return false;
        } else if (resp['numero_isca'] === null) {
            alert('Isca não Localizada.');
            $("numIsca").value = "";
            return false;
        } else if (!resp["is_ativo"]) {
            alert('Isca inativa.');
            $("numIsca").value = "";
            return false;
        } else {
            if (validarIscas(resp["isca_id"], index)) {
                $("numIsca").value = "";
                alert("Isca Encontrada!");
                var item = new ItemIsca(null, null, null, resp["numero_isca"]);
                addIscas(item);
                $('idIsca_' + index).value = resp["isca_id"];
            }
        }
    }//funcao e()

    if (valor != '') {
        espereEnviar("", true);
        tryRequestToServer(function () {
            new Ajax.Request("./MovimentacaoIscasControlador?acao=localizar&valor=" + encodeURIComponent(valor), {
                method: 'get',
                onSuccess: e,
                onError: e
            });
        });
    }
}

function excluirIscas(id, index) {
    var idmanif = $("id").value;
    if (confirm("Deseja excluir esta isca?")) {
        if (confirm("Tem certeza?")) {
            new Ajax.Request("MovimentacaoIscasControlador?acao=excluir&id=" + id,
                {
                    method: 'get',
                    onSuccess: function () {
                        alert('Isca removida com sucesso!');
                        $("idLinhaIscas_" + index).style.display = "none";
                        limparIsca(index)
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
        }
    }
}

function validarIscas(id, index) {
    var max = $("maxIsca").value;
    for (var i = 1; i <= max; i++) {
        if ($('idIsca_' + i).value == id && index != i) {
            $("numIsca").value = "";
            alert("Esta isca não pode ser selecionada pois já está associada a um manifesto ou romaneio.");
            limparIsca(index);
            return false;
        }
    }
    return true;
}

function validarDataChegada(index) {
    var data_saida = $("data_isca_saida_" + index).value;
    var data_chegada = $("data_isca_chegada_" + index).value;
    if (data_chegada != undefined && data_chegada != null && data_chegada != "") {
        if (data_chegada < data_saida) {
            alert("A data de chegada não pode ser menor que a data de saída");
            $("data_isca_chegada_" + index).value = "";
            return false;
        }
    }
}