<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">
    jQuery.noConflict();

    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdPrincipal', 'divBairro');
    arAbasGenerico[1] = new stAba('tdAbaAuditoria', 'divAuditoria');

    function carregar() {
        try {
            var action = '<c:out value="${param.acao}"/>';
            $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            if (action == 2) {

                $("id").value = '<c:out value="${setor.id}"/>';
                $("descricao_setor").value = '<c:out value="${setor.descricao}"/>';


                var setorBairro;

    <c:forEach var="setorEntregaBairro" varStatus="status" items="${setor.setorEntregaBairro}"> //pega os elementos da collection de Bairro e joga em bairroSetor(DOM)
                setorBairro = new SetorBairro();
                setorBairro.idSetorBairro = "${setorEntregaBairro.idSetorBairro}";
                setorBairro.ordemDeEntrega = "${setorEntregaBairro.ordemDeEntrega}";
                setorBairro.idBairro = "${setorEntregaBairro.bairro.idBairro}";
                setorBairro.descricao = "${setorEntregaBairro.bairro.descricao}";
                setorBairro.cidade = "${setorEntregaBairro.cidade.descricaoCidade}";
                setorBairro.idCidade = "${setorEntregaBairro.cidade.idcidade}";
                setorBairro.uf = "${setorEntregaBairro.cidade.uf}";
                <c:if test="${setorEntregaBairro.cepInicial != null}">
                    setorBairro.cepInicial = "${setorEntregaBairro.cepInicial.substring(0, 2)}.${setorEntregaBairro.cepInicial.substring(2, 5)}-${setorEntregaBairro.cepInicial.substring(5)}";
                    setorBairro.cepFinal = "${setorEntregaBairro.cepFinal.substring(0, 2)}.${setorEntregaBairro.cepFinal.substring(2, 5)}-${setorEntregaBairro.cepFinal.substring(5)}";
                </c:if>

                addBairroSetor(setorBairro);
    </c:forEach>

                var maxBairros = $("maxBairros").value;
                for (var index = 1; index <= maxBairros; index++) {
                    if ($("idBairro_" + index).value == "0") {
                        $("botaoBairro_" + index).style.display = 'none';
                        $("descricaoBairro_" + index).value = "Todos os bairros";
                    }

                    if ($("descricaoBairro_" + index).value != "Todos os bairros") {
                        $("botaoCidade_" + index).style.display = 'none';
                    }
                }

            }

        } catch (e) {
            alert(e);
        }

    }

    function salvar() {
        var max = $("maxBairros").value;
        var maxCidade = $("maxCidades").value;
            

        if ($("descricao_setor").value == "") {
            alert("O campo 'Descrição' não pode ficar em branco!");
            $("descricao_setor").focus();
            return false;
        }

        if (maxCidade == 0) {
            alert("Cadastre ao menos um bairro ou cidade a este setor!");
            return false;
        }

        for (var i = 1; i <= max; i++) {
//            if($("idBairro_"+i) != null){

            if ($("idOrdemDeEntrega_" + i) != null && $("idOrdemDeEntrega_" + i).value == 0 || $("idOrdemDeEntrega_" + i) != null && $("idOrdemDeEntrega_" + i).value == "") {
                alert("insira um valor diferente de '0' para a Ordem de Entrega.");
                return false;

            }

            // Validar CEP.
            if (jQuery('[name="tipoLocal_' + i + '"]:checked').val() === 'cep') {
                if ($('cepInicial_' + i).value === '') {
                    alert("O Campo CEP inicial é de preenchimento obrigatório.");
                    return false;
                }
                
                let cepInicial = parseInt($('cepInicial_' + i).value.replace('.', '').replace('-', ''));
                let cepFinal = parseInt($('cepFinal_' + i).value.replace('.', '').replace('-', ''));
                
                if ((cepInicial.toString().length < 8 || cepInicial.toString().length > 8) || (cepFinal.toString().length < 8 || cepFinal.toString().length > 8)) {
                    alert("CEP Inválido");
                    return false;
                }
                
                if (cepInicial > cepFinal) {
                    alert('O campo CEP inicial não poderá ser maior que o CEP Final.');
                    return false;
                }
            } else {
                if ($('cepInicial_' + i) !== null && $('cepFinal_' + i) !== null) {
                    $('cepInicial_' + i).value = '';
                    $('cepFinal_' + i).value = '';
                }
            }
        }
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").submit();
        return true;
    }

    function voltar() {
        tryRequestToServer(function () {(window.location = "ConsultaControlador?codTela=45")});
    }

    function SetorBairro(idBairro, descricao, ordemDeEntrega, idSetorBairro, cidade, idCidade, uf, cepInicial, cepFinal) {
        this.idBairro = (idBairro != undefined ? idBairro : 0);
        this.descricao = (descricao != undefined ? descricao : "");
        this.ordemDeEntrega = (ordemDeEntrega != undefined ? ordemDeEntrega : "0");
        this.idSetorBairro = (idSetorBairro != undefined ? idSetorBairro : "0");
        this.cidade = (cidade != undefined ? cidade : "");
        this.idCidade = (idCidade != undefined ? idCidade : 0);
        this.uf = (uf != undefined ? uf : "");
        this.cepInicial = (cepInicial != undefined ? cepInicial : "");
        this.cepFinal = (cepFinal != undefined ? cepFinal : "");

    }

    var contBairroSetor = 0;
    function addBairroSetor(bairroSetor) {
        if (bairroSetor == null || bairroSetor == undefined) {
            bairroSetor = new SetorBairro();
        }
        contBairroSetor++;

        var tr_0 = Builder.node("tr", {
            id: "trBairro_" + contBairroSetor,
            name: "trBairro_" + contBairroSetor,
            className: "CelulaZebra2",
            align: "center"

        });

        //TODAS AS TD'S
        var tdImagemLixo = Builder.node("td", {
            align: "center"

        });

        var tdRadioTipo = Builder.node("td", {
            align: "left"

        });

        var tdBairro = Builder.node("td", {
            align: "left"

        });

        var tdCidade = Builder.node("td", {
            align: "left"

        });

        var tdOrdemDeEntrega = Builder.node("td", {
            align: "center"

        });

        var imagemExcluir = Builder.node("img", {
            src: "img/lixo.png",
            title: "Excluir bairro",
            className: "imagemLink",
            onClick: "excluirBairroSetor(" + contBairroSetor + ");"

        });

        //LABEL
        var lblBairro = Builder.node("label");
        lblBairro.innerHTML += "&nbsp";

        var lblCidade = Builder.node("label");
        lblCidade.innerHTML += "&nbsp";

        var lblUf = Builder.node("label");
        lblUf.innerHTML += "&nbsp";


        //INPUT
        var labelTipoBairro = Builder.node("label", "Bairro/Cidade");

        var inputTipoBairro = Builder.node("input", {
            id: "tipoBairro_" + contBairroSetor,
            name: "tipoLocal_" + contBairroSetor,
            type: "radio",
            onClick: "toggleRadioTipoBairro("+contBairroSetor+");",
            checked: true,
            value: 'bairro'
        });

        var labelTipoCEP = Builder.node("label", "CEP");

        var inputTipoCEP = Builder.node("input", {
            id: "tipoCEP_" + contBairroSetor,
            name: "tipoLocal_" + contBairroSetor,
            type: "radio",
            onClick: "toggleRadioTipoCEP("+contBairroSetor+");",
            value: 'cep'
        });

        var inputBairro = Builder.node("input", {
            id: "descricaoBairro_" + contBairroSetor,
            name: "descricaoBairro_" + contBairroSetor,
            type: "text",
            size: "20",
            className: "inputReadOnly",
            readonly: "true",
            value: bairroSetor.descricao
        });

        var lblCEPInicial = Builder.node("label", "Inicial:");
        lblCEPInicial.style.display = 'none';
        lblCEPInicial.id = 'lblCEPInicial_' + contBairroSetor;

        var inputCEPInicial = Builder.node("input", {
            id: "cepInicial_" + contBairroSetor,
            name: "cepInicial_" + contBairroSetor,
            type: "text",
            size: "11",
            maxlength: "10",
            className: "inputtexto",
            onKeyPress: "formatar(this, '##.###-###');",
            style: "display:none;",
            value: bairroSetor.cepInicial
        });

        var lblCEPFinal = Builder.node("label", "Final:");
        lblCEPFinal.style.display = 'none';
        lblCEPFinal.id = 'lblCEPFinal_' + contBairroSetor;
        
        var inputCEPFinal = Builder.node("input", {
            id: "cepFinal_" + contBairroSetor,
            name: "cepFinal_" + contBairroSetor,
            type: "text",
            size: "11",
            maxlength: "10",
            className: "inputtexto",
            onKeyPress: "formatar(this, '##.###-###');",
            style: "display:none;",
            value: bairroSetor.cepFinal
        });

        var inputHiddenIdBairro = Builder.node("input", {
            id: "idBairro_" + contBairroSetor,
            name: "idBairro_" + contBairroSetor,
            type: "hidden",
            value: bairroSetor.idBairro
        });

        var inputHiddenIdSetorBairro = Builder.node("input", {
            id: "idSetorBairro_" + contBairroSetor,
            name: "idSetorBairro_" + contBairroSetor,
            type: "hidden",
            value: bairroSetor.idSetorBairro
        });
        
        var inputOrdemDeEntrega = Builder.node("input", {
            id: "idOrdemDeEntrega_" + contBairroSetor,
            name: "idOrdemDeEntrega_" + contBairroSetor,
            type: "text",
            className: "inputtexto",
            onKeyPress: "mascara(this, soNumeros)",
            size: "5",
            maxlength: "5",
//            value: (bairroSetor.ordemDeEntrega != "0" ? bairroSetor.ordemDeEntrega : parseInt($("maxBairros").value) + 1),
            value: gerarOrgemEntrega(bairroSetor.ordemDeEntrega)
        });

        var inputCidade = Builder.node("input", {
            id: "descricaoCidade_" + contBairroSetor,
            name: "descricaoCidade_" + contBairroSetor,
            type: "text",
            className: "inputReadOnly",
            readonly: "true",
            value: bairroSetor.cidade

        });

        var inputUF = Builder.node("input", {
            id: "uf_" + contBairroSetor,
            name: "uf_" + contBairroSetor,
            type: "text",
            size: "2",
            className: "inputReadOnly",
            value: bairroSetor.uf

        });

        var inputHiddenIdCidade = Builder.node("input", {
            id: "idCidade_" + contBairroSetor,
            name: "idCidade_" + contBairroSetor,
            type: "hidden",
            value: bairroSetor.idCidade

        });

        //LOCALIZA

        var pesquisarBairro = Builder.node("input", {
            type: "button",
            className: "botoes",
            id: "botaoBairro_" + contBairroSetor,
            name: "botaoBairro_" + contBairroSetor,
            onclick: "localizaBairro(" + contBairroSetor + ");",
            value: "..."

        });

        var pesquisarCidade = Builder.node("input", {
            type: "button",
            className: "botoes",
            id: "botaoCidade_" + contBairroSetor,
            name: "botaoCidade_" + contBairroSetor,
            onclick: "localizaCidade(" + contBairroSetor + ");",
            value: "..."

        });

        //POVOANDO AS TD's
        tdImagemLixo.appendChild(imagemExcluir);
        tdRadioTipo.appendChild(inputTipoBairro);
        tdRadioTipo.appendChild(labelTipoBairro);
        tdRadioTipo.appendChild(inputTipoCEP);
        tdRadioTipo.appendChild(labelTipoCEP);
        tdBairro.appendChild(lblCEPInicial);
        tdBairro.appendChild(inputCEPInicial);
        tdBairro.appendChild(inputBairro);
        tdBairro.appendChild(inputHiddenIdBairro);
        tdBairro.appendChild(lblBairro);
        tdBairro.appendChild(pesquisarBairro);
        tdBairro.appendChild(inputHiddenIdSetorBairro);
        tdCidade.appendChild(lblCEPFinal);
        tdCidade.appendChild(inputCEPFinal);
        tdCidade.appendChild(inputCidade);
        tdCidade.appendChild(lblCidade);
        tdCidade.appendChild(inputHiddenIdCidade);
        tdCidade.appendChild(inputUF);
        tdCidade.appendChild(lblUf);
        tdCidade.appendChild(pesquisarCidade);
        tdOrdemDeEntrega.appendChild(inputOrdemDeEntrega);

        //POVOANDO AS TR's
        tr_0.appendChild(tdImagemLixo);
        tr_0.appendChild(tdRadioTipo);
        tr_0.appendChild(tdBairro);
        tr_0.appendChild(tdCidade);
        tr_0.appendChild(tdOrdemDeEntrega);



        $("tbBairro").appendChild(tr_0);
        $("maxBairros").value = parseInt($("maxBairros").value) + 1;
        $("maxCidades").value = parseInt($("maxCidades").value) + 1;

        if (bairroSetor.cepInicial !== undefined && bairroSetor.cepInicial !== '') {
            inputTipoCEP.click();
        }
    }

    function excluirBairroSetor(excluirIndex) { //Aqui exclui apenas na tela.
        var excluir = "trBairro_" + excluirIndex;
        var idSetorBairro = $("idSetorBairro_" + excluirIndex).value;
        if (idSetorBairro != null) {
            if (confirm("Deseja realmente excluir este bairro?")) {
                if (confirm("tem certeza?")) {
                    $("idSetorBairroExcluido").value += "," + idSetorBairro;
                    $("maxCidades").value = $("maxCidades").value - 1;
                    Element.remove(excluir);
                }
            }
        }
    }

    function localizaBairro(index) {
        launchPopupLocate('./localiza?acao=consultar&idlista=88', 'Bairro_' + index);
    }

    function localizaCidade(index) {
        launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade_' + index);
    }

    function aoClicarNoLocaliza(idJanela) {
        var index = idJanela.split("_")[1];
        if (idJanela.split("_")[0] == 'Bairro') {

            $("descricaoBairro_" + index).value = $("descricao").value;
            $("idBairro_" + index).value = $("idbairro").value;
            $("descricaoCidade_" + index).value = $("cidade").value;
            $("uf_" + index).value = $("uf").value;            
            $("botaoCidade_" + index).style.display = 'none';

        } else if (idJanela.split("_")[0] == 'Cidade') {
            $("idCidade_" + index).value = $("idcidadeorigem").value;
            $("descricaoCidade_" + index).value = $("cid_origem").value;
            $("uf_" + index).value = $("uf_origem").value;

            $("descricaoBairro_" + index).value = "Todos os bairros";
            $("idBairro_" + index).value = "";
            $("botaoBairro_" + index).style.display = 'none';
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
        var rotina = "setor";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = $("id").value;
        console.log(rotina, id);
        consultarLog(rotina, id, dataDe, dataAte);

    }
    
    function gerarOrgemEntrega(ordemDeEntrega, index){
        var maxBairros = $("maxBairros").value;
        var ultimaOrdem = 0;
        if(ordemDeEntrega != "0"){
            return ordemDeEntrega;
        }else{
            
            for (var qtdBairro = 1; qtdBairro <= maxBairros; qtdBairro++) {
                if ($("idOrdemDeEntrega_"+qtdBairro) != null) {                    
                    if(ultimaOrdem < $("idOrdemDeEntrega_"+qtdBairro).value){
                       ultimaOrdem = parseInt($("idOrdemDeEntrega_"+qtdBairro).value);
                    }
                }
            }            
            
            return ultimaOrdem + 1;                
            
        }
    }
    
    function abrirLocalizarGrupoClientes() {
        launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo')
    }

    function limparGrupoClientes() {
        getObj('grupo').value = '';
        getObj('grupo_id').value = 0;
    }

    function toggleRadioTipoCEP(index) {
        $('cepInicial_'+index).show();
        $('lblCEPInicial_'+index).show();
        $('cepFinal_'+index).show();
        $('lblCEPFinal_'+index).show();
        $('descricaoBairro_'+index).hide();
        $('descricaoCidade_'+index).hide();
        $('botaoBairro_'+index).hide();
        $('botaoCidade_'+index).hide();
        $('uf_'+index).hide();
    }

    function toggleRadioTipoBairro(index) {
        $('cepInicial_'+index).hide();
        $('lblCEPInicial_'+index).hide();
        $('cepFinal_'+index).hide();
        $('lblCEPFinal_'+index).hide();
        $('descricaoBairro_'+index).show();
        $('descricaoCidade_'+index).show();
        $('botaoBairro_'+index).show();
        $('botaoCidade_'+index).show();
        $('uf_'+index).show();
    }

</script>


<html>
    <style>
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
        <title>WebTrans - Cadastro de Setores de Entrega</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css"></style>
    </head>
    <body onLoad="carregar();applyFormatter();AlternarAbasGenerico('tdPrincipal', 'divBairro')">
        <img src="img/banner.gif">
        <br>
        <form action="SetorEntregaControlador?acao=${param.acao == 2 ? "editar": "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" id="id" name="id" value="0">
            <input type="hidden" id="idbairro" name="idbairro" value="0">
            <input type="hidden" id="descricao" name="descricao" value="">
            <input type="hidden" id="idcidade" name="idcidade" value="0">
            <input type="hidden" id="cidade" name="cidade" value="">
            <input type="hidden" id="uf" name="uf"value="">
            <input type="hidden" id="idSetorBairroExcluido" name="idSetorBairroExcluido" value="0">
            <input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="0">
            <input type="hidden" id="cid_origem" name="cid_origem" value="">
            <input type="hidden" id="uf_origem" name="uf_origem" value="">
            <input type="hidden" id="maxCidades" name="maxCidades" value="0">
            <table width="60%" align="center" class="bordaFina" >
                <tr>
                    <td width="82%" align="left"> <span class="style4">Cadastro de Setores de Entrega</span></td>
                    <td width="18%" align="right">
                        <input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/>
                    </td>

                </tr>
            </table>
            <br>

            <table width="60%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td colspan="3" align="center">Dados principais</td>
                </tr>
                <tr>
                    <td class="TextoCampos">Descrição:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="descricao_setor" type="text" id="descricao_setor" value="" size="25" maxlength="25" class="inputtexto">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Grupo de Clientes:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input type="hidden" name="grupo_id" id="grupo_id" value="${setor.grupoClientes.id}">
                        <input name="grupo" type="text" id="grupo" size="25" readonly class="inputReadOnly" value="${setor.grupoClientes.descricao}">
                        <input name="localiza_grupo" type="button" class="inputbotao" id="localiza_grupo" value="..." onClick="abrirLocalizarGrupoClientes()">
                        <img src="img/borracha.gif" border="0" align="bottom" class="imagemLink" onClick="limparGrupoClientes();">
                    </td>
                </tr>
            </table> 
            <table width="60%" align="center" cellpadding="2" cellspacing="1">
                <tr>
                    <td width="100%">
                        <table align="left">
                            <tr>
                                <td id='tdPrincipal' name='divBairro' class="menu" onclick="AlternarAbasGenerico('tdPrincipal', 'divBairro')"> Locais </td>
                                <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>

                            </tr>
                        </table>
                    </td> 
                </tr>
            </table>           
            <div id="divBairro"> 
                <table width="60%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">     
                    <tr class="CelulaZebra2" id="trBairro">
                        <td colspan="5">
                            <input type="hidden" name="maxBairros" id="maxBairros" value="0">
                            <table id="bairros" width="100%" class="bordaFina">
                                <tbody name="tbBairro" id="tbBairro">
                                    <tr class="celula">
                                        <td width="2%">
                                            <img style="vertical-align:middle;" id="" name="" border="0" class="imagemLink" onclick="addBairroSetor(null)" src="img/add.gif" title="Adicionar bairro a este setor"/>
                                        </td>
                                        <td width="25%">Tipo</td>
                                        <td width="25%">Bairro</td>
                                        <td width="25%">Cidade</td>
                                        <td width="25%">Ordem de Entrega</td>
                                    </tr>
                                </tbody>   
                            </table>
                        </td>                                   
                    </tr>                
                </table>                  
            </div> 

            <div id="divAuditoria" name="divAuditoria" style='${param.acao == 2 && param.nivel == 4 ? "" : "none"}' >

                <table width="60%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria">

                    <%@include file = "template_auditoria.jsp" %>
                    <tr>
                        <td colspan="6">
                            <table class="bordaFina" align="center" width="100%">
                                <tr class="CelulaZebra2">
                                    <td class="TextoCampos" width="15%">Incluso:</td>
                                    <td class="CelulaZebra2" width="35%"> 
                                        em: ${setor.criadoEm} <br/> por: ${setor.criadoPor.nome}
                                    </td>
                                    <td class="TextoCampos" width="15%">Alterado:</td>
                                    <td class="CelulaZebra2" width="35%">
                                        em: ${setor.alteradoEm} <br/> por: ${setor.alteradoPor.nome}
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>   
                </table>

            </div> 
            <br/>
            <table class="bordaFina" width="60%" align="center" style='${param.nivel >= param.bloq ? "" : "none" }'>
                <tr>
                    <td colspan="6" class="CelulaZebra2" >
                        <div align="center">
                            <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function () {
                                                    salvar()
                                                })"/>
                        </div>
                    </td>
                </tr>
            </table>
        </form>            
    </body>
</html>