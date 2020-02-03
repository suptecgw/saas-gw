<%-- 
    Document   : cadastrar_bairro
    Created on : 13/04/2015, 16:58:52
    Author     : marcus
--%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>

<html>

    <head>

        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">

    <!--<link rel="stylesheet" href="../estilo.css" type="text/css">-->
    <script language="javascript" type="text/javascript" src="script/builder.js"></script>
    <script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
    <script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
    <script language="javascript" type="text/javascript" src="script/sessao.js"></script>
    <script language="javascript" type="text/javascript" src="script/jquery.js"></script>
    <script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
    <script type="text/javascript" language="JavaScript">   
jQuery.noConflict();
    function carregarBairro(){
            var acao = '<c:out value="${param.acao}"/>';

            if (acao == 2) {
                $("idBairro").value = '<c:out value="${bairro.idBairro}"/>';
                $("descricao").value = '<c:out value="${bairro.descricao}"/>';
                $("cidadeOrigem").value = '<c:out value="${bairro.cidadeBairro.descricaoCidade}"/>';
                $("ufCidade").value = '<c:out value="${bairro.cidadeBairro.uf}"/>';
                $("idCidadeOrigem").value = '<c:out value="${bairro.cidadeBairro.idcidade}"/>';
                $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
                $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
                
                 var bairroEdi;
            <c:forEach var="listaBairroEDI" varStatus="status" items="${bairro.listaBairroEDI}">

                bairroEdi = new nomenclaturaDiferente();
                bairroEdi.descricaoNomenclatura = "${listaBairroEDI.descricao}";
                bairroEdi.idNomenclatura = "${listaBairroEDI.id}";
                bairroEdi.idBairro = "${listaBairroEDI.bairro.idBairro}";

                addNomenclaturaDiferente(bairroEdi);

            </c:forEach>
            }
        }

        function voltarBairro() {
            tryRequestToServer(function () {
                (window.location = "ConsultaControlador?codTela=65");
            });
        }

        function salvarBairro() {
            var formulario = $("formulario");
            var descricao = $("descricao").value;
            var cidade = $("idCidadeOrigem").value;
            var max = $("maxNomenclaturas").value;

            if (descricao == "") {
                alert("O campo 'Bairro' não pode ficar em branco!");
                $("descricao").focus();
                return false;
            }
            if (cidade == "0") {
                return alert("O campo 'Cidade' não pode ficar em branco!");
            }
            
            for (var i = 1; i <= max; i++) {
                if ($("descricaoNomenclatura_" + i) != null && $("descricaoNomenclatura_" + i).value == "") {
                    alert("Informe a nomenclatura EDI do bairro na linha " + i);
                    return false;
                }
            }

            window.open('about:blank', 'pop', 'width=210, height=100');

            formulario.submit();

            return true;
        }       

        function localizarCidade() {
            window.open('./localiza?acao=consultar&idlista=11', 'Cidade', 'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
        }

        function aoClicarNoLocaliza(idJanela) {

            if (idJanela == "Cidade") {
                $('cidadeOrigem').value = $('cid_origem').value;
                $('ufCidade').value = $('uf_origem').value;
                $('idCidadeOrigem').value = $('idcidadeorigem').value;
            }
        }
        
        function nomenclaturaDiferente(descricaoNomenclatura, idNomenclatura, idBairro) {
            this.idNomenclatura = (idNomenclatura != undefined ? idNomenclatura : 0);
            this.descricaoNomenclatura = (descricaoNomenclatura != undefined ? descricaoNomenclatura : "");
            this.idBairro = (idBairro != undefined ? idBairro : 0);
        }

        var countNomenclatura = 0;
        function addNomenclaturaDiferente(nomenclatura) {
            $("trNomenclaturas").style.display = "";
            
            if (nomenclatura == null || nomenclatura == undefined) {

                nomenclatura = new nomenclaturaDiferente();

            }
            
            countNomenclatura++;
            var tabela = $("tbNomenclatura");

            var tr_0 = Builder.node("tr", {
                id: "trNomenclatura_" + countNomenclatura,
                name: "trNomenclatura_" + countNomenclatura,
                className: "CelulaZebra2",
                align: "center"

            });

            var imagemExcluir = Builder.node("img", {
                src: "img/lixo.png",
                title: "Excluir nomenclatura",
                className: "imagemLink",
                onClick: "excluirNomenclatura(" + nomenclatura.idNomenclatura + "," + countNomenclatura + ");"

            });

            //TODAS AS TD'S
            var tdImagemLixo = Builder.node("td", {
                align: "center"

            });

            var tdNomenclatura = Builder.node("td", {
                align: "center"
            });

            //TODOS OS INPUTS
            var inputNomenclatura = Builder.node("input", {
                id: "descricaoNomenclatura_" + countNomenclatura,
                name: "descricaoNomenclatura_" + countNomenclatura,
                type: "text",
                size: "30",
                className: "inputtexto",
                value: nomenclatura.descricaoNomenclatura
            });

            var inputHiddenIdNomenclatura = Builder.node("input", {
                id: "idNomenclatura_" + countNomenclatura,
                name: "idNomenclatura_" + countNomenclatura,
                type: "hidden",
                value: nomenclatura.idNomenclatura

            });

            var inputHiddenIdBairro = Builder.node("input", {
                id: "idBairroNomenclatura_" + countNomenclatura,
                name: "idBairroNomenclatura_" + countNomenclatura,
                type: "hidden",
                value: nomenclatura.idBairro


            });

            //POVOANDO AS TD's
            tdImagemLixo.appendChild(imagemExcluir);
            tdNomenclatura.appendChild(inputNomenclatura);
            tdNomenclatura.appendChild(inputHiddenIdNomenclatura);
            tdNomenclatura.appendChild(inputHiddenIdBairro);


            //POVOANDO AS TR's
            tr_0.appendChild(tdImagemLixo);
            tr_0.appendChild(tdNomenclatura);

            tabela.appendChild(tr_0);

            $("maxNomenclaturas").value = parseInt($("maxNomenclaturas").value) + 1;


        }

        function excluirNomenclatura(idNomenclatura, index) {
            var existe = false;
            if (confirm("Deseja excluir esta Nomenclatura?")) {
                if (confirm("Tem Certeza?")) {
                    if (idNomenclatura != 0) {
                        new Ajax.Request("./BairroControlador?acao=excluirNomenclaturaDiferente&idNomenclatura=" + idNomenclatura,
                                {
                                    method: 'get',
                                    onSuccess: function () {
                                        alert('Nomenclatura excluida com sucesso!')
                                        Element.remove("trNomenclatura_" + index);
                                    },
                                    onFailure: function () {
                                        alert('Erro ao tentar excluir a Nomenclatura!')
                                    }
                                });
                    } else {
                        Element.remove("trNomenclatura_" + index);
                    }
                    var i;
                    for (i = 1; i <= countNomenclatura; i++) {
                        if ($("trNomenclatura_" + i) != null) {
                            existe = true;
                        }
                    }
                    if (!existe) {
                        $("trNomenclaturas").style.display = "";
                    }
                }
            }

        }
            
              var abasBairro = new Array();
            abasBairro[0] = new stAba('tdAuditoria','tbAuditoria');
    
            function stAba(menu, conteudo) {
                this.menu = menu;
                this.conteudo = conteudo;
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
            var rotina = "bairro";
            var dataDe =  $("dataDeAuditoria").value;
            var dataAte =  $("dataAteAuditoria").value;
            var id = $("idBairro").value;
            
            consultarLog(rotina, id, dataDe, dataAte);

        }
    </script>


    <style type="text/css">
        <!--
        .style3{color: #333333}
        .style4{font-size: 14px; font-weight: bold;}
        -->
    </style>

    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>WebTrans - Cadastro de Bairro</title>        
    <link href="estilo.css" rel="stylesheet" type="text/css"/>
</head>

<body onload="carregarBairro();">
    <img width="" src="img/banner.gif" height="44" align="middle"/>
    <table width="30%" class="bordaFina" align="center">
        <tr>
            <td width="82%" align="left">
                <span class="style4">
                    Cadastro de Bairro
                </span>
            </td>
            <td>
                <input type="button" class="inputbotao" onclick="voltarBairro();" value=" Voltar "/>
            </td>
        </tr>
    </table>
    <br/>
    <!--Se na tag form a ação for 2 vai editar caso não...vai cadastrar-->
    <form id="formulario" name="formulario" action="BairroControlador?acao=${param.acao == 2 ? 'editar' : 'cadastrar'}" target="pop" method="post">

        <input id="cid_origem" name="cid_origem" type="hidden"/>
        <input id="uf_origem" name="uf_origem" type="hidden"/>
        <input id="idcidadeorigem" name="idcidadeorigem" type="hidden"/>

        <input id="idBairro" name="idBairro" type="hidden" value="0"/>
        <input id="maxNomenclaturas" name="maxNomenclaturas" type="hidden" value="0"/>
        <table align="center" class="bordaFina" width="30%">
            <tr>
                <td class="tabela" colspan="6">
                    Dados Principais
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"  width="40%">
                    *Bairro:
                </td>
                <td class="CelulaZebra2" width="60%" colspan="4">
                    <input id="descricao" name="descricao" class="inputtexto" type="text" maxlength="40" size="40"/>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    *Cidade:
                </td>
                <td class="CelulaZebra2">
                    <input id="cidadeOrigem" name="cidadeOrigem" class="inputReadOnly" type="text" size="17" readonly/>
                    <input id="idCidadeOrigem" name="idCidadeOrigem" type="hidden" value="0"/>
                    <input id="ufCidade" name="ufCidade" type="text" class="inputReadOnly" size="2"/>
                    <input id="botaoCidade" type="button" class="inputbotao" value="..." onclick="localizarCidade();"/>                 
                </td> 
            </tr>
        </table>
        <table id="nomenclaturas" width="30%" align="center" cellpadding="" cellspacing="" class="bordaFina">
            <tbody id="tbNomenclaturaEDI" name="tbNomenclaturaEDI">
                <tr>
                    <td colspan="3">
                        <table width="100%">
                            <tr class="celula">
                                <td width=""> 
                                    <img src="img/add.gif" border="0" title="Adicionar Nomenclaturas" class="imagemLink" style="vertical-align:middle;" onClick="addNomenclaturaDiferente();">
                                </td>
                                <td> 
                                    <div align="left">Adicionar Nomenclaturas diferentes</div>
                                </td>
                            </tr>
                            <tr name="trNomenclaturas" id="trNomenclaturas" style="display: none">
                                <td colspan="2">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tbody id="tbNomenclatura" name="tbNomenclatura">
                                            <tr class="CelulaZebra1">
                                                <td width="10%"></td>
                                                <td align="center">Nomenclatura</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
        <table class="bordaFina" width="30%"  align="center"  style='display: ${(param.acao == 2 && param.nivel == 4 ? "" : "none" )}'>
                <tr>
                    <td>
                        <table class="bordaFina" width="30%"  align="left">
                                <tr>
                                    <td id="tdAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAuditoria','tbAuditoria');">Auditoria</td>
                                </tr>
                        </table>
                </td>
        </tr>
    </table>
            <table id="tbAuditoria" width="30%" align="center" cellpadding="" cellspacing="" class="bordaFina" style='display: ${(param.acao == 2 && param.nivel >= 2? "" : "none" )}'>
                <tr>
                    <td width="40%" align="center" cellpadding="2" cellspacing="1" id="tableAuditoria" >
                       <%@include file="/gwTrans/template_auditoria.jsp" %>

                    </td>
                </tr>
                <tr>
                    <td colspan="6">
                        <table class="bordaFina" align="center" width="100%">
                            <tr class="CelulaZebra2">
                                <td class="TextoCampos" width="15%">
                                    Incluso:
                                </td>
                                <td class="CelulaZebra2" width="35%"> 
                                    em: ${bairro.criadoEm} <br/> por: ${bairro.criadoPor.nome}
                                </td>
                                <td class="TextoCampos" width="15%">
                                    Alterado: 
                                </td>
                                <td class="CelulaZebra2" width="35%">
                                    em: ${bairro.alteradoEm} <br/> por: ${bairro.alteradoPor.nome}
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
        </table>        
        
        <table width="30%" align="center" cellpadding="" cellspacing="" class="bordaFina">        
            <tr>
                <c:if test="${((param.acao == 1 && param.nivel >= 3 )|| (param.acao == 2 && param.nivel >= 2))}">
                    <td class="CelulaZebra2" colspan="6">
                        <div align="center">
                            <input id="botaoSalvar" name="botaoSalvar" type="button" class="inputbotao" value=" Salvar " onclick="salvarBairro();"/>
                        </div>
                    </td>
                </c:if>
            </tr>
        </table>
    </form>
</body>
</html>
