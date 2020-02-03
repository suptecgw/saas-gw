<%-- 
    Document   : cadastrar_feriado
    Created on : 26/08/2014, 18:48:02
    Author     : anderson
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script type="text/javascript" language="JavaScript">

    jQuery.noConflict();

    var arAbasFeriado = new Array();
    arAbasFeriado[0] = new setAba('tdAbaAuditoria', 'divAuditoria');

    function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    function AlternarAbasGenerico(menu, conteudo) {
        if (arAbasFeriado != null) {
            for (i = 0; i < arAbasFeriado.length; i++) {
                if (arAbasFeriado[i] != null && arAbasFeriado[i] != undefined) {
                    m = document.getElementById(arAbasFeriado[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasFeriado[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasFeriado[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasFeriado[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasFeriado[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    }
    function aoClicarNoLocaliza(idjanela) {
        try {
            if (idjanela == "Municipios") {
                $("inputMunicipio_" + $("linhaMunicipio").value).value = $("cid_origem").value;
                $("hdnIdCidade_" + $("linhaMunicipio").value).value = $("idcidadeorigem").value;
            }
        } catch (e) {
            alert(e)
        }
    }


    function carregar() {
        var action = '<c:out value="${param.acao}"/>';
        var form = document.formulario;
        var estado;
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        var feriado = new Feriado();
        var municipio = new Municipio();
        if (action == 2) {
            feriado.id = '<c:out value="${feriado.id}"/>'
            feriado.descricao = '<c:out value="${feriado.descricao}"/>';
            feriado.dia = '<c:out value="${feriado.dia}"/>';
            feriado.mes = '<c:out value="${feriado.mes}"/>';
            feriado.ano = '<c:out value="${feriado.ano}"/>';
            feriado.tipoFeriado = '<c:out value="${feriado.tipoFeriado}"/>';
            feriado.isFeriadoFinanceiro = '<c:out value="${feriado.feriadoFinanceiro}"/>';
            feriado.isFeriadoOperacional = '<c:out value="${feriado.feriadoOperacional}"/>';

            addFeriado(feriado);
    <c:forEach items="${feriado.estado}" var="estados">
            estado = new Estado();
            estado.id = '${estados.id}';
            estado.uf = '${estados.uf}';
            addEstado(estado, 1);//estou passando 1 direto pois a tela foi feita como um dom mas depois foi visto que nao era um dom.
    </c:forEach>

    <c:forEach items="${feriado.municipio}" var="municipios">
            municipio = new Municipio();
            municipio.id = '${municipios.idFeriadoMunicipio}';
            municipio.idCidade = '${municipios.cidade.idcidade}';
            municipio.cidade = '${municipios.cidade.descricaoCidade}';
            addMunicipios(municipio, 1);//estou passando 1 direto pois a tela foi feita como um dom mas depois foi visto que nao era um dom.
    </c:forEach>

        } else {
            addFeriado();
        }

    }

    function voltar() {
        tryRequestToServer(function () {
            (window.location = "FeriadoControlador?acao=listar&modulo=gwTrans")
        });
    }

    function salvar() {
        if ($("inputDescricao_1").value.trim() == "") {
            alert("a Descrição do feriado não pode ser vazia ou nula");
            return false;
        }

        var formu = document.formulario;



        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        formu.submit();
        return true;

    }





    function Feriado(id, dia, mes, ano, descricao, tipoFeriado, isFeriadoFinanceiro, isFeriadoOperacional) {
        this.id = (id != undefined && id != null ? id : 0);
        this.dia = (dia != undefined && dia != null ? dia : 0);
        this.mes = (mes != undefined && mes != null ? mes : 0);
        this.ano = (ano != undefined && ano != null ? ano : 0);
        this.descricao = (descricao != undefined && descricao != null ? descricao : "");
        this.tipoFeriado = (tipoFeriado != undefined && tipoFeriado != null ? tipoFeriado : "n");
        this.isFeriadoFinanceiro = (isFeriadoFinanceiro != undefined && isFeriadoFinanceiro != null ? isFeriadoFinanceiro : false);
        this.isFeriadoOperacional = (isFeriadoOperacional != undefined && isFeriadoOperacional != null ? isFeriadoOperacional : false);
    }


    var listaMeses = new Array();
    listaMeses[1] = "Janeiro";
    listaMeses[2] = "Fevereiro";
    listaMeses[3] = "Março";
    listaMeses[4] = "Abril";
    listaMeses[5] = "Maio";
    listaMeses[6] = "Junho";
    listaMeses[7] = "Julho";
    listaMeses[8] = "Agosto";
    listaMeses[9] = "Setembro";
    listaMeses[10] = "Outubro";
    listaMeses[11] = "Novembro";
    listaMeses[12] = "Dezembro";

    var contFeriados = 0;

    function addFeriado(feriado) {

        if (feriado == null || feriado == undefined) {
            feriado = new Feriado();
        }

        //ALTERAR O NOME DAS VARIAVEIS
        contFeriados++;
        $("maxFeriados").value = contFeriados;
        var tabelaBase = $("tabelaFeriados");

        var tr = Builder.node("tr", {
            className: "TextoCampos",
            id: "idLinha_" + contFeriados
        });

        var tdImg = Builder.node("td", {
            id: "idTD",
            className: ""
        });
        var tdImg2 = Builder.node("td", {
            id: "idTD",
            className: ""
        });
        var tdImg3 = Builder.node("td", {
            id: "idTD",
            className: ""
        });

        var tdDia = Builder.node("td", {
            id: "idTD"
        });

        var selectDia = Builder.node("select", {
            id: "selectDia_" + contFeriados,
            name: "selectDia_" + contFeriados,
            className: "inputtexto"
        });

        var tdMes = Builder.node("td", {
            id: "idTD"
        });

        var selectMes = Builder.node("select", {
            id: "selectMes_" + contFeriados,
            name: "selectMes_" + contFeriados,
            className: "inputtexto",
            index: "1",
            onChange: "quantidadeDiasFeriado(" + contFeriados + ")"
        });

        var tdAno = Builder.node("td", {
            id: "idTD"
        });

        var selectAno = Builder.node("select", {
            id: "selectAno_" + contFeriados,
            name: "selectAno_" + contFeriados,
            className: "inputtexto",
            onChange: "quantidadeDiasFeriado(" + contFeriados + ")"
        });

        var tdDescricao = Builder.node("td", {
            id: "idTD"
        });

        var inputDescricao = Builder.node("input", {
            id: "inputDescricao_" + contFeriados,
            name: "inputDescricao_" + contFeriados,
            className: "inputtexto",
            size: "30",
            maxLength: "30",
            value: feriado.descricao
        });

        var optionsMesVazio = Builder.node("option", {
            value: ""
        });
        Element.update(optionsMesVazio, "Selecione");
        selectMes.appendChild(optionsMesVazio);

        for (var meses = 1; meses <= 12; meses++) {
            var optionsMes = Builder.node("option", {
                value: meses
            });
            Element.update(optionsMes, listaMeses[meses]);
            selectMes.appendChild(optionsMes);
        }

        var data = new Date();
        var anoAtual = parseInt(data.getFullYear());

        var optionAnoVazio = Builder.node("option", {value: ""});
        Element.update(optionAnoVazio, "Todos os anos.")
        selectAno.appendChild(optionAnoVazio);

        for (var ano = (anoAtual - 5); ano <= (anoAtual + 5); ano++) {
            var optionsAno = Builder.node("option", {
                value: ano
            });
            Element.update(optionsAno, ano);
            selectAno.appendChild(optionsAno);
        }

        var tdTipoFeriado = Builder.node("td", {
        });

        // n=Nacional, e=Estadual e m=Municipal;
        var selectTipoFeriado = Builder.node("select", {
            id: "selectTipoFeriado_" + contFeriados,
            name: "selectTipoFeriado_" + contFeriados,
            onchange: "tipoFeriado(this.value," + contFeriados + ")",
            className: "inputtexto"
        });
        var optionTipoN = Builder.node("option", {value: "n"});
        Element.update(optionTipoN, "Nacional");
        var optionTipoE = Builder.node("option", {value: "e"});
        Element.update(optionTipoE, "Estadual");
        var optionTipoM = Builder.node("option", {value: "m"});
        Element.update(optionTipoM, "Municipal");

        selectTipoFeriado.appendChild(optionTipoN);
        selectTipoFeriado.appendChild(optionTipoE);
        selectTipoFeriado.appendChild(optionTipoM);

        var tdFinanceiro = Builder.node("td", {});
        var labelIsFinanceiro = Builder.node("label", "Financeiro: ");
        var checkIsFinanceiro = Builder.node("input", {
            type: "checkbox",
            id: "checkFeriadoFinanceiro_" + contFeriados,
            name: "checkFeriadoFinanceiro_" + contFeriados
        });
        checkIsFinanceiro.checked = (feriado.isFeriadoFinanceiro == "true" ? "checked" : "");

        var tdOperacional = Builder.node("td", {});
        var labelIsOperacional = Builder.node("label", "Operacional: ");
        var checkIsOperacional = Builder.node("input", {
            type: "checkbox",
            name: "checkFeriadoOperacional_" + contFeriados,
            id: "checkFeriadoOperacional_" + contFeriados
        });
        checkIsOperacional.checked = (feriado.isFeriadoOperacional == "true" ? "checked" : "");



        //hiddens:
        var hidnIdFeriado = Builder.node("input", {
            type: "hidden",
            id: "idFeriado_" + contFeriados,
            name: "idFeriado_" + contFeriados,
            value: feriado.id
        });
        var hidnMaxMunicipios = Builder.node("input", {
            type: "hidden",
            id: "maxMunicipios_" + contFeriados,
            name: "maxMunicipios_" + contFeriados,
            value: 0
        });
        var hidnMaxEstados = Builder.node("input", {
            type: "hidden",
            id: "maxEstados_" + contFeriados,
            name: "maxEstados_" + contFeriados,
            value: 0
        });


        //Estados:

        //como montar a tabela: TABLE < TBODY < TR < TD < INPUT

        var trEstado = Builder.node("tr", {
            id: "trEstado_" + contFeriados,
            className: "TextoCampos"
        });

        var tdEstado = Builder.node("td", {
            id: "tdEstado_" + contFeriados,
            colspan: "8"
        });

        var tableEstado = Builder.node("table", {
            id: "tabelaEstados_" + contFeriados,
            name: "tabelaEstados_" + contFeriados,
            width: "100%",
            className: "tabelaZerada"
        });

        var tbodyEstado = Builder.node("tbody", {
            id: "tbodyEstado_" + contFeriados,
            name: "tbodyEstado_" + contFeriados
        });

        var trEstadoBase = Builder.node("tr", {
            className: "celulaZebra2"
        });
        var tdAddEstados = Builder.node("td", {
            width: "2%"
        });
        var imgAddEstado = Builder.node("img", {
            src: "img/add.gif",
            id: "imgAddEstado_" + contFeriados,
            name: "imgAddEstado_" + contFeriados,
            onclick: "addEstado(null," + contFeriados + ")"
        });

        var tdEstadual = Builder.node("td", {
            colSpan: "2"
        });
        var labelEstadual = Builder.node("label", "Estados");
        tdEstadual.appendChild(labelEstadual);



        tdAddEstados.appendChild(imgAddEstado);
        tdAddEstados.appendChild(hidnMaxEstados);
        trEstadoBase.appendChild(tdAddEstados);
        trEstadoBase.appendChild(tdEstadual);
        tbodyEstado.appendChild(trEstadoBase);
        tableEstado.appendChild(tbodyEstado);
        tdEstado.appendChild(tableEstado);
        trEstado.appendChild(tdImg3);
        trEstado.appendChild(tdEstado);

        //Municipal:

        //como montar a tabela: TABLE < TBODY < TR < TD < INPUT

        var trMunicipal = Builder.node("tr", {id: "trMunicipal_" + contFeriados, className: "TextoCampos"});

        var tdMunicipal = Builder.node("td", {id: "tdMunicipal_" + contFeriados, colspan: "8"});

        var tableMunicipal = Builder.node("table", {
            id: "tabelaMunicipal_" + contFeriados,
            name: "tabelaMunicipal_" + contFeriados,
            width: "100%",
            className: "tabelaZerada"
        });

        var tbodyMunicipal = Builder.node("tbody", {
            id: "tbodyMunicipal_" + contFeriados,
            name: "tbodyMunicipal_" + contFeriados
        });

        var trMunicipalBase = Builder.node("tr", {className: "celulaZebra2"});
        var tdAdd = Builder.node("td", {width: "2%"});
        var imgAddMunicipios = Builder.node("img", {
            src: "img/add.gif",
            id: "imgAddMucipio_" + contFeriados,
            name: "imgAddMucipio_" + contFeriados,
            onclick: "addMunicipios(null," + contFeriados + ")"
        });

        var tdMunicipio = Builder.node("td", {
            colSpan: "2"
        });
        var labelMunicipio = Builder.node("label", "Municipios");
        tdMunicipio.appendChild(labelMunicipio);

        tdAdd.appendChild(imgAddMunicipios);
        tdAdd.appendChild(hidnMaxMunicipios);
        trMunicipalBase.appendChild(tdAdd);
        trMunicipalBase.appendChild(tdMunicipio);
        tbodyMunicipal.appendChild(trMunicipalBase);
        tableMunicipal.appendChild(tbodyMunicipal);
        tdMunicipal.appendChild(tableMunicipal);
        trMunicipal.appendChild(tdImg2);
        trMunicipal.appendChild(tdMunicipal);




        //montando o DOM na tela
        tdDia.appendChild(hidnIdFeriado);
        tdDia.appendChild(selectDia);
        tdMes.appendChild(selectMes);
        tdAno.appendChild(selectAno);
        tdDescricao.appendChild(inputDescricao);
        tdTipoFeriado.appendChild(selectTipoFeriado);
        tdFinanceiro.appendChild(labelIsFinanceiro);
        tdFinanceiro.appendChild(checkIsFinanceiro);
        tdOperacional.appendChild(labelIsOperacional);
        tdOperacional.appendChild(checkIsOperacional);

        tr.appendChild(tdImg);
        tr.appendChild(tdDia);
        tr.appendChild(tdMes);
        tr.appendChild(tdAno);
        tr.appendChild(tdDescricao);
        tr.appendChild(tdTipoFeriado);
        tr.appendChild(tdFinanceiro);
        tr.appendChild(tdOperacional);

        tabelaBase.appendChild(tr);
        tabelaBase.appendChild(trMunicipal);
        tabelaBase.appendChild(trEstado);
        quantidadeDiasFeriado(contFeriados);
        $("selectTipoFeriado_" + contFeriados).value = feriado.tipoFeriado;
        tipoFeriado($("selectTipoFeriado_" + contFeriados).value, contFeriados);
        selectDia.options.selectedIndex = feriado.dia;
        selectMes.options.selectedIndex = feriado.mes;
        //selectAno.options.selectedIndex = feriado.ano;
        $("selectAno_" + contFeriados).value = (feriado.ano == 0 ? "" : feriado.ano);

    }

    var listaUfs = new Array(29);
    listaUfs[0] = new Option("AC", "Acre");
    listaUfs[1] = new Option("AL", "Alagoas");
    listaUfs[2] = new Option("AP", "Amapá");
    listaUfs[3] = new Option("AM", "Amazonas");
    listaUfs[4] = new Option("BA", "Bahia");
    listaUfs[5] = new Option("CE", "Ceará");
    listaUfs[6] = new Option("DF", "Distrito Federal");
    listaUfs[7] = new Option("ES", "Espirito Santo");
    listaUfs[8] = new Option("GO", "Goiás");
    listaUfs[9] = new Option("MA", "Maranhão");
    listaUfs[10] = new Option("MT", "Mato Grosso");
    listaUfs[11] = new Option("MS", "Mato Grosso do Sul");
    listaUfs[12] = new Option("MG", "Minas Gerais");
    listaUfs[13] = new Option("PA", "Pará");
    listaUfs[14] = new Option("PB", "Paraiba");
    listaUfs[15] = new Option("PR", "Paraná");
    listaUfs[16] = new Option("PE", "Pernambuco");
    listaUfs[17] = new Option("PI", "Piauí");
    listaUfs[18] = new Option("RJ", "Rio de Janeiro");
    listaUfs[19] = new Option("RN", "Rio Grande do Norte");
    listaUfs[20] = new Option("RS", "Rio Grande do Sul");
    listaUfs[21] = new Option("RO", "Rondônia");
    listaUfs[22] = new Option("RR", "Roraima");
    listaUfs[23] = new Option("SC", "Santa Catarina");
    listaUfs[24] = new Option("SP", "São Paulo");
    listaUfs[25] = new Option("SE", "Sergipe");
    listaUfs[26] = new Option("TO", "Tocantins");
    listaUfs[27] = new Option("EX", "Exterior");
    listaUfs[28] = new Option("FN", "FN");

    function Estado(id, idFeriado, uf) {
        this.id = (id != undefined && id != null ? id : 0);
        this.idFeriado = (idFeriado != undefined && idFeriado != null ? id : 0);
        this.uf = (uf != undefined && uf != null ? uf : "");
    }

    function Municipio(id, idFeriado, cidade, idCidade) {
        this.id = (id != undefined && id != null ? id : 0);
        this.idFeriado = (idFeriado != undefined && idFeriado != null ? id : 0);
        this.cidade = (cidade != undefined && cidade != null ? cidade : "");
        this.idCidade = (idCidade != undefined && idCidade != null ? idCidade : 0);

    }

    function addEstado(estado, contFeriado) {

        if (estado == null || estado == undefined) {
            estado = new Estado();
        }


        $("maxEstados_" + contFeriado).value = parseInt($("maxEstados_" + contFeriado).value) + 1;
        var contEstado = $("maxEstados_" + contFeriado).value;
        var complemento = contFeriado + "_" + contEstado;
        var tabelaBase = $("tabelaEstados_" + contFeriado);
        var trEstadoDOM = Builder.node("tr", {
            id: "trEstadoDOM_" + contEstado,
            className: "celulaZebra2"
        });
        var tdVaziaDOM = Builder.node("td");
        var tdEstadoDOM = Builder.node("td");
        var hdnIdEstado = Builder.node("input", {
            type: "hidden",
            id: "hdnIdEstado_" + complemento,
            name: "hdnIdEstado_" + complemento,
            value: estado.id
        });


        var selectEstado = Builder.node("select", {
            name: "selectEstado_" + complemento,
            id: "selectEstado_" + complemento,
            className: "fieldMin"
        });

        var optionEstado = null;
        for (var i = 0; i < listaUfs.length; i++) {
            optionEstado = Builder.node("option", {
                value: listaUfs[i].valor
            }, listaUfs[i].descricao);

            selectEstado.appendChild(optionEstado);
        }
        selectEstado.value = estado.uf;

        var tdImg = Builder.node("td");

        var imgExcluir = Builder.node("img", {
            src: "img/cancelar.png",
            id: "imgAddExcluir_" + contEstado,
            name: "imgAddExcluir_" + contEstado,
            onclick: "excluirEstado(" + estado.id + "," + contEstado + ")"
        });


        tdEstadoDOM.appendChild(hdnIdEstado);
        tdEstadoDOM.appendChild(selectEstado);
        tdImg.appendChild(imgExcluir);
        trEstadoDOM.appendChild(tdVaziaDOM);
        trEstadoDOM.appendChild(tdEstadoDOM);
        trEstadoDOM.appendChild(tdImg);
        tabelaBase.appendChild(trEstadoDOM);

    }

    function addMunicipios(municipio, contFeriado) {

        if (municipio == null || municipio == undefined) {
            municipio = new Municipio();
        }

        $("maxMunicipios_" + contFeriado).value = parseInt($("maxMunicipios_" + contFeriado).value) + 1;
        var contMunicipios = $("maxMunicipios_" + contFeriado).value;
        var complemento = contFeriado + "_" + contMunicipios;
        var tabelaBase = $("tabelaMunicipal_" + contFeriado);
        var trMunicipioDOM = Builder.node("tr", {
            id: "trMunicipioDOM_" + contMunicipios,
            className: "celulaZebra2"
        });
        var tdVaziaDOM = Builder.node("td");
        var tdMunicipioDOM = Builder.node("td");

        var hdnIdMunicipio = Builder.node("input", {
            type: "hidden",
            id: "hdnIdMunicipio_" + complemento,
            name: "hdnIdMunicipio_" + complemento,
            value: municipio.id
        });
        var hdnIdCidade = Builder.node("input", {
            type: "hidden",
            id: "hdnIdCidade_" + complemento,
            name: "hdnIdCidade_" + complemento,
            value: municipio.idCidade
        });
        var inputMunicipioDOM = Builder.node("input", {
            id: "inputMunicipio_" + complemento,
            name: "inputMunicipio_" + complemento,
            className: "inputReadOnly",
            value: municipio.cidade
        });
        var buttonLocalizarMunicipio = Builder.node("input", {
            type: "button",
            onclick: "popupCidades('" + complemento + "');",
            value: "...",
            className: "botoes"
        });

        var tdImg = Builder.node("td");

        var imgExcluir = Builder.node("img", {
            src: "img/cancelar.png",
            id: "imgMunicipioExcluir_" + contMunicipios,
            name: "imgMunicipioExcluir_" + contMunicipios,
            onclick: "excluirMunicipio(" + municipio.id + "," + contMunicipios + ")"
        });

        tdMunicipioDOM.appendChild(hdnIdMunicipio);
        tdMunicipioDOM.appendChild(hdnIdCidade);
        tdMunicipioDOM.appendChild(inputMunicipioDOM);
        tdMunicipioDOM.appendChild(buttonLocalizarMunicipio);
        tdImg.appendChild(imgExcluir);
        trMunicipioDOM.appendChild(tdVaziaDOM);
        trMunicipioDOM.appendChild(tdMunicipioDOM);
        trMunicipioDOM.appendChild(tdImg);
        tabelaBase.appendChild(trMunicipioDOM);

    }

    function popupCidades(complemento) {
        $("linhaMunicipio").value = complemento;
        launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Municipios')
    }

    function 1quantidadeDiasFeriado(index) {
        var qtdDias = 0;
        var selectDia = $("selectDia_" + index);
        var selectMes = $("selectMes_" + index);
        var selectAno = ($("selectAno_" + index) == 0 ? new Date() : $("selectAno_" + index));
        var auxiliarDiaSelecionado = $("selectDia_" + index).value;

        var dd = new Date(selectAno.value, selectMes.value, 0);

        removeOptionSelected(selectDia);
        var options;

        var optionVazio = Builder.node("option", {value: ""});
        selectDia.appendChild(optionVazio);
        Element.update(optionVazio, "Selecione");

        for (var i = 1; i <= dd.getDate(); i++) {
            options = Builder.node("option", {
                value: i
            });

            Element.update(options, (i <= 9 ? "0" + i : i));
            selectDia.appendChild(options);
        }

        $("selectDia_" + index).value = auxiliarDiaSelecionado;
    }

    function tipoFeriado(tipo, index) {

        if (tipo == "e") {
            $("trEstado_" + index).style.display = "";
            $("trMunicipal_" + index).style.display = "none";
        } else if (tipo == "m") {
            $("trMunicipal_" + index).style.display = "";
            $("trEstado_" + index).style.display = "none";
        } else {
            $("trEstado_" + index).style.display = "none";
            $("trMunicipal_" + index).style.display = "none";
        }
    }


    function excluirEstado(id, index) {
        if (confirm("Deseja excluir o estado?")) {
            if (confirm("Tem certeza?")) {
                if (id != 0) {
                    new Ajax.Request("FeriadoControlador?acao=excluirEstado&idEstado=" + id + "&modulo=webtrans&",
                            {
                                method: 'get',
                                onSuccess: function () {
                                    Element.remove($("trEstadoDOM_" + index));
                                    alert('removido com sucesso!')
                                },
                                onFailure: function () {
                                    alert('Erro ao excluir...')
                                }
                            });
                } else {
                    Element.remove($("trEstadoDOM_" + index));
                }
            }
        }
    }

    function excluirMunicipio(id, index) {
        if (confirm("Deseja excluir o Municipio?")) {
            if (confirm("Tem certeza?")) {
                if (id != 0) {
                    new Ajax.Request("FeriadoControlador?acao=excluirMunicipio&idMunicipio=" + id + "&modulo=webtrans&",
                            {
                                method: 'get',
                                onSuccess: function () {
                                    Element.remove($("trMunicipioDOM_" + index));
                                    alert('removido com sucesso!')
                                },
                                onFailure: function () {
                                    alert('Erro ao excluir...')
                                }
                            });
                } else {
                    Element.remove($("trMunicipioDOM_" + index));
                }
            }
        }
    }
    function pesquisarAuditoria() {
        if (countLog != null && countLog != undefined) {
            for (var i = 1; i <= countLog; i++) {
                if ($("tr1Log_" + i) != null) {
                    Element.remove(("tr1Log_" + i));
                }
                if ($("tr2Log_" + i) != null) {
                    Element.remove(("tr2Log_" + i));
                }
            }
        }
        countLog = 0;
        var rotina = "feriados";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = '<c:out value="${feriado.id}"/>';
        console.log(id);
        consultarLog(rotina, id, dataDe, dataAte);

    }



</script>

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Cadastro de Feriado </title>
    </head>
    <body onload="carregar()">
        <img src="img/banner.gif" width="30%" height="44">

        <table class="bordaFina" width="76%" align="center">
            <tr>
                <td width="76%" align="left"> <span class="style4">Cadastro de Feriado</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <form action="FeriadoControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}"  id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" id="linhaMunicipio">
            <input type="hidden" id="cid_origem" name="cid_origem" value="">
            <input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="">
            <input type="hidden" id="linhaEstado">
            <input type="hidden" id="maxFeriados" name="maxFeriados">
            <input type="hidden" id="modulo" name="modulo" value="webtrans">
            <table width="76%" align="center" class="bordaFina" >

                <tr>
                    <td colspan="4" align="center" class="tabela" >Dados principais</td>
                </tr>
                <tr>
                    <td>

                        <table width="100%" border="0" class="bordaFina" align="center" id="tabelaFeriados">
                            <tr class="celula">
                                <td width="2%">
                                </td> 
                                <td width="10%">
                                    Dia
                                </td>
                                <td width="10%">
                                    Mes
                                </td>
                                <td width="10%">
                                    Ano
                                </td>
                                <td width="28%">
                                    Descrição
                                </td>
                                <td width="15%">
                                    Tipo Feriado
                                </td>
                                <td width="23%" colspan="2">
                                    Setor
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
             <table align="center" width="76%" >
                        <tr>
                            <td width="100%">
                                <table align="left">
                                    <tr>
                                       <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                                    </tr>
                                </table>
                            </td> 
                        </tr>
                    </table>
            <table width="76%" border="0" class="bordaFina" align="center" id="tabelaFeriados" id="divAuditoria" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                    <tr>
                        <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
                    </tr>
                    <tr>
                        <td colspan="8"> 
                            <table width="100%" align="center" class="bordaFina">
                                <td class="TextoCampos" width="15%"> Incluso:</td>

                                <td width="35%" class="CelulaZebra2"> em: <c:out value="${feriado.criadoEm}"></c:out><br>
                                    por: <c:out value="${feriado.criadoPor.nome}"></c:out>
                                    </td>

                                    <td width="15%" class="TextoCampos"> Alterado:</td>
                                    <td width="35%" class="CelulaZebra2"> em: <c:out value="${feriado.atualizadoEm}"></c:out><br>
                                    por: <c:out value="${feriado.atualizadoPor.nome}"></c:out>
                                    </td>
                                </table>                  
                            </td>
                        </tr>

            </table>
                                    <br/>
            <table width="76%" border="0" class="bordaFina" align="center" id="tabelaFeriados">                        
                <tr>
                    <c:if test="${param.nivel >= param.bloq}">
                        <td colspan="8" class="CelulaZebra2" ><div align="center">
                                <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function () {
                                            salvar()
                                        })"/>
                            </div></td>
                        </c:if>  

                </tr>
            </table>
        </form>

    </body>
</html>

