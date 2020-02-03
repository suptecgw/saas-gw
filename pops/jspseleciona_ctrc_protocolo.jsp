<%@page import="java.text.DecimalFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="conhecimento.BeanConsultaConhecimento"%>
<%@page import="nucleo.Apoio"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="../script/builder.js"></script>
<script language="javascript" type="text/javascript" src="../script/prototype.js"></script>
<!--<script language="javascript" type="text/javascript" src="../script/sessao.js"></script>-->
<script language="javascript" type="text/javascript" src="../script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="../script/funcoes.js"></script>
<script language="javascript" type="text/javascript" src="../script/mascaras.js"></script>
<script language="JavaScript" src="../script/jquery.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="../script/collection.js"></script>
<script language="JavaScript" type="text/javascript" src="../script/beans/CTRC.js"></script>
<%
    BeanConsultaConhecimento protocoloCtrc = null;
    String acao = request.getParameter("acao");
    
    if(Apoio.getUsuario(request) == null){
        response.sendError(response.SC_FORBIDDEN,"É preciso estar logado no sistema para ter acesso a esta página." );
    }
    acao = ((acao == null) ? "" : acao);
    
    protocoloCtrc = new BeanConsultaConhecimento();
    protocoloCtrc.setConexao(Apoio.getUsuario(request).getConexao());
   // protocoloCtrc.setExecutor(Apoio.getUsuario(request));
    
    int linha = 0;
    String marcados = "";
    boolean mostraTudo = false;
    
    if (acao.equals("iniciar")) {
        marcados = (request.getParameter("marcados") == null ? "0" : request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados"));
        mostraTudo = Boolean.parseBoolean(request.getParameter("mostratudo"));
    }

%>
<script language="javascript" type="text/javascript" >
    // 29-11-2013 - Paulo
function ProtocoloCtrcNovo(protocoloCtrcId,idCtrc,carga,numero,chegadaEm,destinatario,notaFiscal,idFilialCtrc){
        this.protocoloCtrcId = (protocoloCtrcId != undefined && protocoloCtrcId != null ? protocoloCtrcId : 0);
        this.idCtrc = (idCtrc != undefined && idCtrc != null ? idCtrc : 0);
        this.carga = (carga != undefined && carga != null ? carga : 0);
        this.numero = (numero != undefined && numero != null ? numero : 0);
        this.chegadaEm = (chegadaEm != undefined && chegadaEm != null ? chegadaEm :"");
        this.notaFiscal = (notaFiscal != undefined && notaFiscal != null ? notaFiscal :"");
        this.destinatario = (destinatario != undefined && destinatario != null ? destinatario :"");
        this.idFilialCtrc = (idFilialCtrc != undefined && idFilialCtrc != null ? idFilialCtrc :0);
}

   var quant = "";
    function fechar(){
        window.close();
    }
    
    function pesquisar(){
        document.getElementById("formulario").submit();
    }

    function seleciona(){
        var retorno = "";
        var ctrc = null;
        for (var i = 0; i <= quant; ++i){        
            if(document.getElementById("chk-"+i) != null){
                if (document.getElementById("chk-"+i).checked){

                    ctrc = new ProtocoloCtrcNovo(document.getElementById("chk-"+i).value,
                                                    document.getElementById("idCtrc_"+i).value, null, document.getElementById("numCtrc_"+i).value, 
                                                 null, document.getElementById("destinatario_"+i).value, null, document.getElementById("idfilialCtrc_"+i).value);
                    
                        window.opener.addProtolocoAoSelecionar(ctrc);
                    if (retorno == ""){
                        retorno += document.getElementById("chk-"+i).value;         
                    }else  {
                        retorno += ","+document.getElementById("chk-"+i).value;
                    }
                }
            }
        }

        if (retorno == ""){
            return alert("Informe no mínimo um CT-e.");
        }
        
        fechar();   
    }
    
//    function checkCtrc(evento){
//        
//        var pesqCtrc = "";
//        var numeroCtrc = "";
//        pesqCtrc = document.getElementById("selCtrc").value;
//        
//        if( evento.keyCode==13 ) {
//        numeroCtrc = document.getElementById("hidden_ctrc_"+ pesqCtrc).value;
////            for (var i = 0; i <= quant; ++i){
//                if(document.getElementById("hidden_ctrc_"+document.getElementById("selCtrc").value) != null){
////                    console.log("AAAAAAA serir: " + document.getElementById("serie_"+numeroCtrc).value);
//                    document.getElementById("chk-"+numeroCtrc).checked = true;
//                    document.getElementById("selCtrc").value = "";
//                        //break;
//                }else{
//                    alert("CT-e não encontrado.");
//                }
////            }
//        }
//    }
    
    function checkCtrc(evento){
        var pesqCtrc = "";
        if (evento.keyCode == 13) {
            pesqCtrc = document.getElementById("selCtrc").value;
            for (var qtdCte = 0; qtdCte < quant; qtdCte++) {
                if (document.getElementById("numeroCTe_"+qtdCte) != null) {
                    if (pesqCtrc == document.getElementById("numeroCTe_"+qtdCte).value) {
                         document.getElementById("chk-"+qtdCte).checked = true;
                    }    
                }
            }
        }
    }
    
    function checkTodosCtrcs(){
        if(document.getElementById("chkTodos").checked){
            for (var i = 0; i <= quant; ++i){
                document.getElementById("chk-"+i).checked = true;
            }
        }else{
            for (var i = 0; i <= quant; ++i){
                document.getElementById("chk-"+i).checked = false;
            }
        }
    }   
 
function alteraTipoConsulta(){
    document.getElementById('divCtrcs').style.display = "none";
    document.getElementById('divData').style.display = "none";
    document.getElementById('divTipoCte').style.display = "none";
    if (document.getElementById('tipoData').value == 'ctrcs'){
        document.getElementById('divCtrcs').style.display = "";
    }else{
        document.getElementById('divTipoCte').style.display = "";
        document.getElementById('divData').style.display = "";     
    }
}    
 
function carregando(){
    document.getElementById('tipoData').value = '<%=(request.getParameter("tipoData") == null ? "s.emissao_em" : request.getParameter("tipoData"))%>';
    document.getElementById('ctrcs').value = '<%=(request.getParameter("ctrcs") == null ? "" : request.getParameter("ctrcs"))%>';
    document.getElementById('filtrosConsulta').value = '<%=(request.getParameter("tipo") == null ? "" : request.getParameter("tipo"))%>';
}

function checkFiltros(){
    var filtrosSelecionados = "";
    for(var i = 0 ; i < 11 ; i ++){
        if(document.getElementById('checkFil_'+i).checked){
            filtrosSelecionados += "'"+document.getElementById('checkFil_'+i).value+"',";
        } 
    }    
    document.getElementById('filtrosConsulta').value = filtrosSelecionados;
}
function carregaFiltros(){
    var filtros = "";
    for(var i = 0; i < 11; i++ ){
        filtros = document.getElementById('checkFil_'+i).value;
         if(document.getElementById('filtrosConsulta').value.toString().indexOf(filtros) > -1){
             document.getElementById('checkFil_'+i).checked = true;
         }
    }
}
 
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        
        <title>WebTrans - Selecionar CT-e(s) para o protocolo</title>
    </head>
    
    <body onLoad="carregaFiltros();carregando();">
        <form id="formulario" name="formulario" method="post" action="jspseleciona_ctrc_protocolo.jsp?acao=iniciar">
        <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
        <input name="cid_destino"  type="hidden" class="fieldMin" id="cid_destino" style="background-color:#FFFFF1" value="" size="25" readonly="true">
        <input name="uf_destino"   type="hidden" class="fieldMin" id="uf_destino" style="background-color:#FFFFF1" value="" size="2" readonly="true">
        <input type="hidden" id="filtrosConsulta" name="filtrosConsulta" value="<%=(request.getParameter("filtrosConsulta") != null ? request.getParameter("filtrosConsulta") : "")%>">
        <input type="hidden" id="tipoProtocolo" name="tipoProtocolo" value="<%=(request.getParameter("tipoProtocolo") != null || request.getParameter("tipoProtocolo") != "" ? request.getParameter("tipoProtocolo") : "")%>">
        <input type="hidden" id="marcados" name="marcados" value="<%=(request.getParameter("marcados") != null || request.getParameter("marcados") != "" ? request.getParameter("marcados") : "0")%>">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="619"><div align="left"><b>Selecionar CT-e(s) para o protocolo</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr align="center" class="celulaZebra2">
                <td width="30%" class="TextoCampos">
                    Pesquisar por:
                    <select id="tipoData" name="tipoData" class="inputtexto" onchange="alteraTipoConsulta();">
                        <option value="s.emissao_em">Data de Emissão</option>
                        <option value="ct.baixa_em">Data de Entrega</option>
                        <option value="ctrcs">Número CT-e(s)</option>
                    </select>
                </td>
                <td width="70%" class="CelulaZebra2">
                    <div id="divData"> 
                        <TABLE width="100%"> 
                            <tr>
                                <td>
                                    <table width="100%" align="left" cellspacing="0" >
                                        <tr align="center" class="celulaZebra2">
                                            <td>
                                                <table width="100%" align="center" cellspacing="0" >
                                                    <tr align="center" class="celulaZebra2">
                                                        <td>Entre: <input name="dtinicial" class="fieldDate" type="text" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                                                          onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                                                            e: <input name="dtfinal" type="text" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                                                      onBlur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">

                                                        </td>
                                                    </TR>

                                                </TABLE>
                                            </td>
                                        </TR>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>                                            
                    <div id="divCtrcs" style="display: none;">
                        <table width="100%" align="center" cellspacing="0" >
                            <tr align="center" class="celulaZebra2">
                                <TD>
                                    <input name="ctrcs" type="text" style="font-size:8pt;" id="ctrcs" size="60" value="<%=request.getParameter("ctrcs") == null ? "" : request.getParameter("ctrcs")%>" class="inputtexto" >
                                    Exemplo: 000123,000124,000125
                                    <input type="hidden" name="iddestinatario" id="iddestinatario"  value="<%=(request.getParameter("iddestinatario") == null ? "0" : request.getParameter("iddestinatario"))%>">
                                </td>
                        </TABLE>
                    </div>

                </td>
            </tr>
            <tr>
                <td colspan="8">
                    <div id="divTipoCte">
                        <table width="100%" align="center" cellspacing="1" class="bordaFina" >
                            <tr align="center" class="celulaZebra2">
                                <td width="15%" class="TextoCampos" rowspan="2"> Tipos de CT-e: </td>
                                <td><label><input type="checkbox" id="checkFil_0" name="checkFil_0" value="b">Cortesia</label></td>
                                <td><label><input type="checkbox" id="checkFil_1" name="checkFil_1" value="t">Substituído</label></td>
                                <td><label><input type="checkbox" id="checkFil_2" name="checkFil_2" value="d">Devolução</label></td>
                                <td><label><input type="checkbox" id="checkFil_3" name="checkFil_3" value="s">Substituição</label></td>
                                <td colspan="2"><label><input type="checkbox" id="checkFil_4" name="checkFil_1" value="l">Entrega local (cobrança)</label></td>
                            </tr>
                            <tr align="center" class="celulaZebra2">
                                <td><label><input type="checkbox" id="checkFil_5" name="checkFil_5" value="n" <%=request.getParameter("chkNormal") == null ? "" : "checked"%> >Normal</label></td>
                                <td><label><input type="checkbox" id="checkFil_6" name="checkFil_6" value="i">Diárias</label></td>
                                <td><label><input type="checkbox" id="checkFil_7" name="checkFil_7" value="r">Reentrega</label></td>
                                <td><label><input type="checkbox" id="checkFil_8" name="checkFil_8" value="c">Complementar</label></td>
                                <td><label><input type="checkbox" id="checkFil_9" name="checkFil_9" value="p">Pallets </label></td>
                                <td><label><input type="checkbox" id="checkFil_10" name="checkFil_10" value="a">Anulação</label></td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <tr>
                <TD class="CelulaZebra2" colspan="2">
                    <DIV align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="checkFiltros();submit();"/>
                    </DIV>
                </TD>
            </tr>
        </table>            
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr> 
                <td width="2%" class="tabela"><input type="checkbox" id="chkTodos" name="chkTodos" onclick="javascript:checkTodosCtrcs();"></td>
                <td width="7%" class="tabela" align="left">CT-e</td>
                <td width="8%" class="tabela" align="left">Emissão</td>
                <td width="22%" class="tabela" align="left">Remetente</td>
                <td width="22%" class="tabela" align="left">Destinatário</td>
                <td width="8%" class="tabela" align="right">Valor NF</td>
                <td width="6%" class="tabela" align="right">Vol(s)</td>
                <td width="9%" class="tabela" align="right">Peso</td>
                <td width="8%" class="tabela" align="left">Entrega</td>
                <td width="8%" class="tabela" align="right">Frete</td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="3">Informe o CT-e:</td>
                <td class="CelulaZebra2" colspan="7">
                    <input name="selCtrc" type="text" style="font-size:8pt;" id="selCtrc" size="7" value="" class="inputtexto" onKeyPress="checkCtrc(event)">
                    <font color="red">Após digitar o número do CT-e tecle "Enter" para selecioná-lo na lista abaixo.</font>
                </td>
            </tr>
            <%
                protocoloCtrc.setDtInicial(Apoio.paraDate(request.getParameter("dtinicial")));
                protocoloCtrc.setDtFinal(Apoio.paraDate(request.getParameter("dtfinal")));
                if(protocoloCtrc.SelectProtocoloCtrc(marcados,
                        (request.getParameter("iddestinatario") == null || request.getParameter("iddestinatario") == "" ? "0" : request.getParameter("iddestinatario")),
                        (request.getParameter("tipoData") == null ? " s.emissao_em " : request.getParameter("tipoData")),
                        (request.getParameter("ctrcs") == null ? "" : request.getParameter("ctrcs")),
                        (request.getParameter("filtrosConsulta") == null ? "" : request.getParameter("filtrosConsulta")),
                        request.getParameter("tipoProtocolo") == null || request.getParameter("tipoProtocolo") == "" ? "" : request.getParameter("tipoProtocolo"))){
                    ResultSet rs = protocoloCtrc.getResultado();
                    while(rs.next()){                     
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <%boolean encontrou = false;
                    for(int i = 0; i <= marcados.split(",").length - 1; i++){
                        if(marcados.split(",")[i].equals(rs.getString("idCtrc"))) {%>
                    
                        <td align="center"><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("idprotocolo")%>"checked></td>
                    <%encontrou = true;
                        }
                    }
                if(!encontrou) {%>
                <td align="center"><input type="checkbox" name="<%="chk-"+linha%>" id="<%="chk-"+linha%>" value="<%=rs.getString("idprotocolo")%>"/>
                    <%}%>
                    <input type="hidden" name="<%="hidden_ctrc_" + rs.getString("nfiscal")%>" id="<%="hidden_ctrc_" + rs.getString("nfiscal")%>" value="<%=linha%>"/>
                    <input type="hidden" name="idCtrc_<%=linha%>" id="idCtrc_<%=linha%>"  value="<%=rs.getString("idCtrc")%>"/>
                    <input type="hidden" name="numCtrc_<%=linha%>" id="numCtrc_<%=linha%>"  value="<%=rs.getString("nfiscal")%>"/>
                    <input type="hidden" name="destinatario_<%=linha%>" id="destinatario_<%=linha%>"  value="<%=rs.getString("destinatario")%>"/>                
                    <input type="hidden" name="numeroCTe_<%=linha%>" id="numeroCTe_<%=linha%>"  value="<%=rs.getString("numero")%>"/>
                    <input type="hidden" name="idfilialCtrc_<%=linha%>" id="idfilialCtrc_<%=linha%>"  value="<%=rs.getString("idfilial")%>"/>
                </td>
                
                <td align="left"><%=rs.getString("nfiscal")%></td>                
                <td align="left"><%=Apoio.formatData(rs.getDate("emissao_em"),"dd/MM/yyyy")%></td>
                <td align="left"><%=rs.getString("remetente")%></td>
                <td align="left"><%=rs.getString("destinatario")%></td>
                <td align="right"><%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor_mercadoria"))%></td>
                <td align="right"><%=new DecimalFormat("#,##0").format(rs.getDouble("volume"))%></td>
                <td align="right"><%=new DecimalFormat("#,##0.000").format(rs.getDouble("peso"))%></td>
                <td align="left"><%=Apoio.formatData(rs.getDate("data_entrega"),"dd/MM/yyyy")%></td>
                <td align="right"><%=new DecimalFormat("#,##0.00").format(rs.getDouble("valor_frete"))%></td>
             </tr>
             <%linha++;
                }
             }
             %>
             <script language="javascript">
                    quant = <%=linha++%>
             </script>
             <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td colspan="11"><div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona();">
                </div></td>
            </tr>
            </form>
        </table>        
    </body>
</html>
