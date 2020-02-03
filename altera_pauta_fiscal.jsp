<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanLocaliza,
         nucleo.Apoio"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
            // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("configpautafiscal") : 0);
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
            //fim da MSA
%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>



<script language="Javascript" type="text/javascript">
    function voltar(){
        document.location.replace("./menu");
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function salva(){
        document.getElementById("salvar").disabled = true;
        document.getElementById("salvar").value = "Enviando...";
        $('countFaixa').value = countFaixa;
        var formu = document.formulario;
        window.open('about:blank', 'pop', 'width=210, height=100');
        formu.submit();
    }

    function mostrar(){
        var url = "./PautaFiscalControlador?acao=carregar&idfilial="+$("idfilial").value+"&filial="+$('fi_abreviatura').value;
        document.location.replace(url);
    }

    function aoClicarNoLocaliza(idjanela){
        if (idjanela == "Filial"){
            tryRequestToServer(function(){mostrar();});
        }
    }

    var countFaixa = 0;
    function addFaixa(id,kmInicial,kmFinal,valorPauta){
        var classe = ((countFaixa % 2) != 0 ? 'CelulaZebra2' : 'CelulaZebra1');

        var TR = Builder.node("TR",{className:classe, id:"trFaixa_"+countFaixa});
        //Coluna Lixeira
        var TD1 = Builder.node("TD");
        var _inp1 = Builder.node("INPUT",{type:"hidden",id:"idFaixa_"+countFaixa, name:"idFaixa_"+countFaixa, value: id});
        var _img1 = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerFaixa("+countFaixa+");"});
        TD1.appendChild(_inp1);
        TD1.appendChild(_img1);

        //Coluna KM Inicial
        var TD2 = Builder.node("TD");
        var _inp2 = Builder.node("INPUT",{type:"text",id:"kmInicial_"+countFaixa, name:"kmInicial_"+countFaixa, size:"8", maxLength:"8", value: kmInicial, className:"inputtexto", onchange: "seNaoIntReset(this, 0);"});
        TD2.appendChild(_inp2);

        //Coluna KM Final
        var TD3 = Builder.node("TD");
        var _inp3 = Builder.node("INPUT",{type:"text",id:"kmFinal_"+countFaixa, name:"kmFinal_"+countFaixa, size:"8", maxLength:"8", value: kmFinal, className:"inputtexto", onchange: "seNaoIntReset(this, 0);"});
        TD3.appendChild(_inp3);

        //Coluna Valor Pauta
        var TD4 = Builder.node("TD");
        var _inp4 = Builder.node("INPUT",{type:"text",id:"valor_"+countFaixa, name:"valor_"+countFaixa, size:"8", maxLength:"8", value: formatoMoeda(valorPauta), className:"inputtexto", onchange: "seNaoFloatReset(this, '0.00');"});
        TD4.appendChild(_inp4);

        TR.appendChild(TD1);
        TR.appendChild(TD2);
        TR.appendChild(TD3);
        TR.appendChild(TD4);

        $('tabPauta').appendChild(TR);
        countFaixa++;
    }


    function removerFaixa(idx){
        if (confirm("Deseja mesmo apagar essa faixa?")){
            Element.remove('trFaixa_'+idx);
        }
    }

    function Carregar(){
        var action = '<c:out value="${param.acao}"/>';
        if(action == 'carregar'){
            <c:forEach var="pautas" items="${pautasFilial}">
                addFaixa('<c:out value="${pautas.id}"/>','<c:out value="${pautas.kmInicial}"/>','<c:out value="${pautas.kmFinal}"/>','<c:out value="${pautas.valorPauta}"/>');
            </c:forEach>
            $('idfilial').value = '<c:out value="${param.idFilialEscolhida}"/>';
            $('fi_abreviatura').value = '<c:out value="${param.filialEscolhida}"/>';
        }
    }

</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Pauta Fiscal de ICMS</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onLoad="Carregar();">
        <form id="formulario" action="./PautaFiscalControlador?acao=cadastrar" name="formulario" method="post" target="pop">
        <img src="img/banner.gif">
        <br>
        <table width="40%" align="center" class="bordaFina" >
            <tr>
                <td><div align="left"><b>Pauta Fiscal de ICMS</b></div></td>
            </tr>
        </table>
        <br>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="2"><div align="center">Filial selecionada</div></td>
            </tr>
            <tr class="CelulaZebra2">
                <td width="70%"> <div align="center">
                        <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="" size="15" readonly>
                        <input type="hidden" name="idfilial" id="idfilial" value="0">
                        <input type="hidden" name="countFaixa" id="countFaixa" value="0">
                        <input  name="localiza_filial" type="button" class="botoes" id="localiza_filial" onClick="javascript:localizafilial();" value="...">
                    </div></td>
                <td width="30%"><div align="center">
                        <input name="mostrar" type="button" class="botoes" id="mostrar" value="Mostrar" onClick="javascript:tryRequestToServer(function(){mostrar();});">
                    </div></td>
            </tr>
            <tr>
                <td colspan="2">
                    <table width="100%">
                        <tbody id="tabPauta">
                            <tr class="tabela">
                                <td width="10%">
                                    <img src="img/add.gif" border="0" class="imagemLink " title="Adicionar uma nova faixa" onClick="addFaixa(0,0,0,'0.00');">
                                </td>
                                <td width="30%">Km Inicial</td>
                                <td width="30%">Km Final</td>
                                <td width="30%">Valor</td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>
        <%if (nivelUser >= 2) {%>
        <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2">
                <td colspan="7">
                    <center>
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva();});">
                    </center>
                </td>
            </tr>
        </table>
        <%}%>
    </form>

    </body>
</html>
