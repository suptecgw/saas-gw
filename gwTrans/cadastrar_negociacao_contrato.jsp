<%-- 
    Document   : cadastrar_negociacao_contrato
    Created on : 15/09/2016, 19:48:25
    Author     : Marcos Paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>

<script type="text/javascript" language="JavaScript">  
    jQuery.noConflict();
    
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
     arAbasGenerico[1] = new stAba('tdAbaRegras','tbRegras');
     var listaFPagamento = new Array();;
     var index = 0;
     
function carregar(){
    var form = document.getElementById('formulario');
    var acao = '<c:out value="${param.acao}"/>'
    <c:forEach var="fpgto" varStatus="status" items="${fpag}">
            listaFPagamento[${status.count - 1}] = new Option('${fpgto.idFPag}', '${fpgto.descFPag}');
    </c:forEach>

    if(acao == 2){
        form.id.value = '<c:out value="${negociacao.id}"/>';
        form.descricao.value = '<c:out value="${negociacao.descricao}"/>';
        form.dataDeAuditoria.value = '<c:out value="${param.dataAtual}"/>';
        form.dataAteAuditoria.value = '<c:out value="${param.dataAtual}"/>';
            $("idtipoCalculo").value = '<c:out value="${negociacao.tipoCalculo}"/>';

        
        "<c:forEach  var="regras" items='${negociacao.regrasFrete}'>"
                    var regras = new RegrasFrete();
                    regras.id = "${regras.id}";
                    regras.percentual = "${regras.percentual}";
                    regras.tipo = "${regras.tipo}";
                    regras.diasPag = "${regras.diasPag}";
                    regras.pagamentoCfe = "${regras.pagamentoCfe}";
                    regras.tipoFav = "${regras.tipoFav}";
                    regras.idFpag = "${regras.formaPagamento.idFPag}";
                    regras.vlEditavel = "${regras.flagValorEditavel}";
                    montarDomRegras(regras);
         "</c:forEach>"
         
    }
    
}

function voltar(){
        tryRequestToServer(function(){(window.location  = "ConsultaControlador?codTela=46")});
    }


    function salvar(){
       var max = $("maximo").value;
        //var formu = document.formulario;
        for(var i = 1; i < max ; i++){
            if($("trRegraFrete_"+i) != null && $("trRegraFrete_"+i).style.display != "none"){
            console.log($("vaiDeletar_"+i).value);
                var percentual = $("percentual_"+i).value;
               if(parseFloat(percentual) < 0.01 || parseFloat(percentual) > 100.00){
                  alert("Informe os percentuais Corretamente!");
                   return false;
               }
               }
            }
        var totPercentual = 0.00;
        for (var i = 1; i <= max; i++) {
            if ($("percentual_" + i) != undefined && $("percentual_" + i) != null) {
                totPercentual =  parseFloat(totPercentual) +parseFloat($("percentual_"+i).value);
                console.log(totPercentual);
            }
        }
               if(totPercentual != 100.00){
                   alert("A soma dos percentuais deve ser igual a 100%");
                   return false;
               }
        if($("descricao").value == ""){
            alert("Favor preencher o campo de Descrição");  
            $("descricao").focus();
            return false;
        }   
        window.open('about:blank', 'pop', 'width=210, height=100');

        $("formulario").submit();
        return true;
    }
    
    
    function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "negociacaoAdiantamento";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    function RegrasFrete(id,tipo, percentual,pagamentoCfe, diasPag, tipoFav,idFpag,vlEditavel){
        this.id = id;
        this.tipo = tipo;
        this.percentual = percentual;
        this.pagamentoCfe = pagamentoCfe;
        this.diasPag = diasPag;
        this.tipoFav = tipoFav;
        this.idFpag = idFpag;
        this.vlEditavel = vlEditavel;
    }
    
    function deletarRegra(index){
       if(confirm("Deseja deletar a negociação?")){
           $("vaiDeletar_"+index).value = "true";
           $("percentual_"+index).value = 0;
           invisivel($("trRegraFrete_"+index));
       }
    }
    
    function montarDomRegras(regrasfrete){
    index++;
    if(regrasfrete == undefined | regrasfrete == null ){//Caso o objeto não esteja instanciado.
            regrasfrete = new RegrasFrete();
        }
        
        var classeSty = (index % 2 == 0 ? "CelulaZebra2" : "CelulaZebra1");
        var _tr = Builder.node("tr",{
            class: classeSty,
            id: "trRegraFrete_"+index,
            name: "trRegraFrete_"+index
        });
        
        var _tdAcao = Builder.node("td",{   width:"3%" });
        var _img = Builder.node("img",{
            src: "img/lixo.png",
            onclick: "deletarRegra("+index+")",
            class: "imagemLinkSpc"
        });
        
        var _tdFormaPagto = Builder.node ("td",{   width:"10%", align: "left"
        });
        
        var _tdPercentual = Builder.node ("td",{  width:"5%", align: "left"});
        var _inpt = Builder.node("input",{
            id: "percentual_"+index,
            name: "percentual_"+index,
            value: regrasfrete.percentual == null || regrasfrete.percentual == undefined ? "0,00" : colocarVirgula(regrasfrete.percentual),
            type: "text",
            class: "inputtexto",
            onchange: "seNaoFloatReset(this, '0,00')",
            size: "5",
            maxlength: "6",
            onkeypress:"mascara(this, reais)",
            style: "text-align: right"
        });
        
        var _idRegra = Builder.node("input",{
            id: "idregra_"+index,
            name: "idregra_"+index,
            value: regrasfrete.id == null || regrasfrete.id == undefined ? "0" : regrasfrete.id ,
            type: "hidden"
        });
        _tdAcao.appendChild(_img);
        
        _tdPercentual.appendChild(_inpt);
        _tdPercentual.appendChild(_idRegra);

        var _td3 = Builder.node ("td",{   width:"5%", align: "right"});
        var _tdTipo = Builder.node ("td",{
              width:"7%",
              align: "left"
        });
        
        var inpt2 = Builder.node ("select",{
            id: "tipo_"+index,
            name: "tipo_"+index,
            class: "inputtexto"
        });
        
        var opt1 = Builder.node("option",{
            value: "a"
        });
        
        var opt2 = Builder.node("option",{
            value: "s"
        });
        opt1.innerHTML = "Adiantamento";
        opt2.innerHTML = "Saldo";

        var _td5 = Builder.node ("td",{  width:"13%", align: "right"});
        var _tdPgtoCFe = Builder.node ("td",{  width:"10%", align: "left"});
        var inpt3 = Builder.node ("select",{
            id: "pagamentoCfe_"+index,
            name: "pagamentoCfe_"+index,
            class: "inputtexto"
        });
        
        var opt31 = Builder.node("option",{
            value: "M"
        });
        opt31.innerHTML = "Manual";
        
        var opt32 = Builder.node("option",{
            value: "A"
        });
        opt32.innerHTML = "Automático";
        
        var _td7 = Builder.node ("td",{  width:"10%", align: "right"});
        
        var _tdFavorecido = Builder.node ("td",{  width:"10%", align: "left"});
        var inpt4 = Builder.node ("select",{
            id: "tipoFavorecido_"+index,
            name: "tipoFavorecido_"+index,
            class: "inputtexto"
        });
        
        var opt41 = Builder.node("option",{
            value: "p"
        });
        
        var opt42 = Builder.node("option",{
            value: "m"
        });
        opt41.innerHTML = "Proprietário";
        opt42.innerHTML = "Motorista";
        

        var _tdDiasPagto = Builder.node ("td",{  width:"10%", align: "left"});
        var _inpt5 = Builder.node("input",{
            id: "diasPag_"+index,
            name: "diasPag_"+index,
            value: regrasfrete.diasPag == null || regrasfrete.diasPag == undefined ? "0" : regrasfrete.diasPag,
            type: "text",
            class: "inputtexto",
            onchange: "seNaoIntReset(this, '0')",
            size: "5",
            maxlength: "6",
            style: "text-align: right"
        });
        
        var vaiDeletar = Builder.node("input",{
            id: "vaiDeletar_"+index,
            name: "vaiDeletar_"+index,
            value: "false",
            type: "hidden"
        });
        
        
        var inputselectFormaPagamento = Builder.node ("select",{
            id: "formaPagamento_"+index,
            name: "formaPagamento_"+index,
            class: "inputtexto"
        });
        var optPgto = null;
        for (var i = 0; i < listaFPagamento.length; i++) {
            
            optPgto = Builder.node("option", {value: listaFPagamento[i].valor});
            Element.update(optPgto, listaFPagamento[i].descricao);
            inputselectFormaPagamento.appendChild(optPgto);
        }
        
        var _tdValorEdital = Builder.node ("td",{width:"7%", align: "left"});
        
        var _inptValorEditavel = Builder.node("input",{
            id: "valorEditavel_"+index,
            name: "valorEditavel_"+index,
            type: "checkbox"
        });

        _tdValorEdital.appendChild(_inptValorEditavel);
        
        inpt2.appendChild(opt1);
        inpt2.appendChild(opt2);
        _tdTipo.appendChild(inpt2);
        
        inpt3.appendChild(opt31);
        inpt3.appendChild(opt32);
        _tdPgtoCFe.appendChild(inpt3);
        
        inpt4.appendChild(opt41);
        inpt4.appendChild(opt42);
        _tdFavorecido.appendChild(inpt4);
       
       //Forma de pagamento
        _tdFormaPagto.appendChild(inputselectFormaPagamento);
        
        _tdDiasPagto.appendChild(_inpt5);
        _tdDiasPagto.appendChild(vaiDeletar);
        
        _tr.appendChild(_tdAcao);
        _tr.appendChild(_tdPercentual);
        _tr.appendChild(_tdTipo);
        _tr.appendChild(_tdFormaPagto);
        _tr.appendChild(_tdPgtoCFe);
        _tr.appendChild(_tdFavorecido);
        _tr.appendChild(_tdDiasPagto);
        _tr.appendChild(_tdValorEdital);
        
        $('tabelaRegras').appendChild(_tr);
        $('maximo').value = parseFloat(index);
        
        console.log(regrasfrete.vlEditavel);
        
        if (regrasfrete.vlEditavel == "true") {
            $("valorEditavel_"+index).checked = true;
        }
        
        
        $("formaPagamento_"+index).value = regrasfrete.idFpag;
        
        
        inpt3.value = regrasfrete.pagamentoCfe == null || regrasfrete.pagamentoCfe == undefined ? 'A': regrasfrete.pagamentoCfe;
        inpt4.value = regrasfrete.tipoFav == undefined || regrasfrete.tipoFav == null ? 'p' : regrasfrete.tipoFav;
        inpt2.value = regrasfrete.tipo == null || regrasfrete.tipo == undefined ? 'a' : regrasfrete.tipo;
    }
</script>    
<!DOCTYPE html>
 <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>
<html>
     <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">   
        <title> Cadastro de Negociação do Adiantamento de Frete</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="carregar();applyFormatter();AlternarAbasGenerico('tdAbaRegras','tbRegras')">
        <img src="img/banner.gif" width="20%" height="44" align="middle">
        <table class="bordaFina" width="75%" align="center">
            <tr>
                <td width="82%" align="left"><b><span class="style4">Cadastro de Negociação do Adiantamento de Frete</span></b></td>
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <form action="NegociacaoAdiantamentoFreteControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}"  id="formulario" name="formulario" method="post" target="pop">
             <table width="75%" align="center" class="bordaFina" >
                    <tr>
                        <td colspan="4" align="center" class="tabela" >Dados principais</td>
                    </tr>

                    <tr>
                        <td class="TextoCampos" width="20%">Descrição:</td>                        
                        <td class="CelulaZebra2" width="30%"><input name="descricao" id="descricao" type="text" class="inputtexto" size="30" maxlength="30"  />
                        </td>
                    <input type="hidden" value="" name="id" id ="id">
                    </tr>
                    <tr>
                    <td class="TextoCampos" width="20%">Tipo de cálculo do adiantamento:</td>
                    <td class="CelulaZebra2" width="30%">
                        <select class="inputtexto" style="width:120px" id="idtipoCalculo" name="idtipoCalculo">
                            <option value="pc">Percentual (%)</option>
                            <option value="rf">Percentual com rateio entre as filiais de destino levando em consideração o valor do frete CIF e FOB.</option>
                        </select>
                    </td>
                </tr>
         </table>
            <table align="center" width="75%">
                <tr>
                    <td width="100%">
                        <table align="left">
                            <tr>
                               <td id="tdAbaRegras" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaRegras','tbRegras')"> Regras da Negociação</td>
                               <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                            </tr>
                        </table>
                    </td> 
                </tr>
            </table>
                         <table width="75%" align="center" class="bordaFina" id="tbRegras" name="tbRegras">
                                <tr>
                        <td width="100%" colspan="2">
                            <table width="100%" align="center" class="bordaFina" id="tabelaRegras" name="tabelaRegras">
                                <tr>
                                    <td width="99%" height="16" colspan="11" class="tabela"> 
                                        <div align="center">Regras de Frete</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2" colspan="11">
                                        <input type="hidden" id="maximo" name="maximo" value="0">
                                        <img class="imagemLink" border="0" onclick="javascript: montarDomRegras($('maximo').value)" style="vertical-align:middle;" title="atribuir regra de frete" src="img/add.gif">
                                    </td>
                                </tr>
                                <tr>
                                    <td width="3%" class="tabela"> 
                                        <div align="center"></div>
                                    </td>
                                    <td width="7%" class="tabela"> 
                                        <div align="center">Percentual</div>
                                    </td>
                                    <td class="tabela"> 
                                        <div align="center">Tipo</div>
                                    </td>
                                    <td  class="tabela"> 
                                        <div align="center">Forma Pagamento</div>
                                    </td>
                                    <td class="tabela"> 
                                        <div align="center">Pagamento CF-e</div>
                                    </td>
                                    <td class="tabela"> 
                                        <div align="center">Favorecido</div>
                                    </td>
                                    <td class="tabela"> 
                                        <div align="center">Dias Pagto</div>
                                    </td>
                                    <td class="tabela"> 
                                        <div align="center">Valor Editavel</div>
                                    </td>
                                </tr>
                            </table>         
                        </td>
                    </tr>
                            </table>                
                    <div id="divAuditoria" width="80%" >
                    <table align="center"  width="75%" class="bordaFina" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                        <tr>
                            <td>
                                    <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                     <%@include file="template_auditoria.jsp" %>
                                   </table>
                            </td>    
                        </tr>
                        <tr>
                            <td colspan="8"> 
                                <table width="100%" align="center" class="bordaFina">        
                                   <tr class="CelulaZebra2">
                                       <td class="TextoCampos" width="15%"> Incluso:</td>
                                       <td width="35%" class="CelulaZebra2"> em: ${negociacao.criadoEm} <br>
                                           por: ${negociacao.criadoPor.nome} 
                                       </td>
                                       <td width="15%" class="TextoCampos"> Alterado:</td>
                                       <td width="35%" class="CelulaZebra2"> em: ${negociacao.atualizadoEm} <br>
                                           por: ${negociacao.atualizadoPor.nome}
                                       </td>
                                   </tr>   
                                </table>
                            </td>
                        </tr> 
                    </table>
                    </div> 
                <br/>
               <table align="center"  width="75%" class="bordaFina" style="display: ${param.nivel >= param.bloq ? "" : "none"} ">          
                <tr>
                    <td colspan="6" class="CelulaZebra2" >
                        <div align="center">
                            <input type="button" value="  SALVAR  " class="inputbotao" id="botSalvar" onclick="tryRequestToServer(function(){salvar();})"/>
                        </div>
                    </td>
                </tr>
               </table>  
        </form>
    </body>
</html>
