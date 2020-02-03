<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         conhecimento.manifesto.BeanConsultaManifesto,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio" %> 
<%@page import="filial.BeanFilial"%>
<%@page import="conhecimento.BeanConsultaConhecimento"%>
<script language="javascript" src="../script/funcoes.js" type=""></script>
     <!--<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>-->
<%
    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);
    int nivelUserToFilial = (nivelUser > 0 ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
//ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaConhecimento conCtrc = null;
    String acao = request.getParameter("acao");

    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null) {
        response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
    }

    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA

    //Instanciando o bean pra trazer os CTRC's
    conCtrc = new BeanConsultaConhecimento();
    conCtrc.setConexao(Apoio.getUsuario(request).getConexao());
    conCtrc.setExecutor(Apoio.getUsuario(request));

    int linha = 0;

%>
<script language="javascript" type="text/javascript" >

    function fechar(){
        window.close();
    }

    function seleciona(qtdlinha){
        var retorno = "";
        var ctrcs = "";
        var ctrcsValor = 0;
        for (i = 0; i <= qtdlinha - 1; ++i){
            if ($("chk_"+i).checked){
                if (retorno == ""){
                    retorno += $("chk_"+i).value;
                    ctrcs += $("ctr_"+i).innerHTML;
                }else{
                    retorno += ","+$("chk_"+i).value
                    ctrcs += ","+$("ctr_"+i).innerHTML
                }
                ctrcsValor += parseFloat($("ctrValor_"+i).innerHTML);
            }
        }

        if (window.opener.addCtrc != null)
            window.opener.addCtrc(retorno, ctrcs,ctrcsValor);
       
        fechar();   
    }

    function ctrcSelecionado(id){
        var sels = '<%=request.getParameter("ctrcs")%>';
        for(x=0; x < sels.split(',').length; x++){
            if (sels.split(',')[x] == id)
                return true;
        }
        return false;  
    }

    function pesquisar(){
        document.location.replace("./seleciona_ctrc_viagem.jsp?ctrcs=<%=request.getParameter("ctrcs")%>"+
            "&idmotorista=<%=request.getParameter("idmotorista")%>&isServico="+$('chknf').checked + 
            "&pedido="+$("pedido").value+"&numeroCarga="+$('numeroCarga').value + 
            "&manifesto="+$('manifesto').value+"&idfilial=" + $("filialId").value + "&romaneio=" + $("romaneio").value
            +"&setor="+$("setor").value
            +"&id_setor="+$("id_setor").value
            +"&bairro_setor="+$("bairro_setor").value
            +"&dataDe="+$("dataDe").value
            +"&dataAte="+$("dataAte").value
            +"&cidade_bairro"+$("cidade_setor").value);
    }
    function abrirLocalizaSetorEntrega(){
       launchPopupLocate('../localiza?acao=consultar&idlista=90', 'Setor_Entrega');
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

        <title>WebTrans - Consulta</title>
        <link href="../estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body>

        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <td width="619"><div align="left"><b>Selecionar Ctrcs para a viagem</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <td class="TextoCampos">Apenas a filial: </td>  
                <td class="TextoCampos">
                    <div align="center">
                        <select name="filialId" id="filialId" class="fieldMin">
                            <%BeanFilial fl = new BeanFilial();
              ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                            <option value="0" <%=request.getParameter("idfilial") != null && request.getParameter("idfilial").equals("0") ? "selected" : ""%>>Todas</option>
                            <%
                                while (rsFl.next()) {
                            %>
                            <option value="<%=rsFl.getString("idfilial")%>" <%=request.getParameter("idfilial") != null && request.getParameter("idfilial").equals(rsFl.getString("idfilial")) ? "selected" : ""%>><%=rsFl.getString("abreviatura")%></option>
                            <% %>
                            <%}%>
                        </select>
                    </div>
                </td>  
               
                <td class="TextoCampos">Mostrar CTRCs do manifesto: </td>
                <td class="CelulaZebra2">
                    <input name="manifesto" type="text" id="manifesto" size="8" 
                           value="<%=(request.getParameter("manifesto") == null ? "" : request.getParameter("manifesto"))%>" class="inputtexto">
                </td>
                <td class="TextoCampos">Mostrar CTRCs do Romaneio: </td>
                <td class="CelulaZebra2">
                    <input name="romaneio" id="romaneio" type="text" size="8" class="inputtexto" 
                           value="<%=(request.getParameter("romaneio") == null ? "" : request.getParameter("romaneio"))%>"  />
                </td>
                <td class="CelulaZebra2"><div align="center">
                        <input name="chknf" type="checkbox" id="chknf" value="checkbox" <%=request.getParameter("isServico") == null || request.getParameter("isServico").equals("false") ? "" : "checked"%>>
                        Mostrar notas fiscais de servi&ccedil;os </div></td>
                <td class="textoCampos"  >Pedido:</td>
                <td class="celulaZebra2" >
                    <input type="text" class="fieldMin" name="pedido" id="pedido" size="9" maxlength="10" value="<%=(request.getParameter("pedido") != null ? request.getParameter("pedido") : "")%>" /> 
                </td>
                <td class="textoCampos"  >Nº Carga:</td>
                <td class="celulaZebra2" >
                    <input type="text" class="fieldMin" name="numeroCarga" id="numeroCarga" size="9" maxlength="10" value="<%=(request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga") : "")%>" /> 
                </td>
            </tr>
            <tr>
                <td width="30%" class="CelulaZebra2">
                    <div id="div1">
                        Emitidos entre:
                        <input name="dataDe" type="text" id="dataDe" size="10" maxlength="10" class="fieldDate" onblur="alertInvalidDate(this)" onkeypress="fmtDate(this, event)" 
                               onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" value="<%=(request.getParameter("dataDe") == null ? Apoio.getDataAtual() : request.getParameter("dataDe"))%>">
                        e
                        <input name="dataAte" type="text" id="dataAte" size="10" maxlength="10" onblur="alertInvalidDate(this)" class="fieldDate" onkeypress="fmtDate(this, event)" 
                               onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" value="<%=(request.getParameter("dataAte") == null ? Apoio.getDataAtual() : request.getParameter("dataAte"))%>">
                    </div>
                </td>
                <td class="TextoCampos" colspan="3"> Apenas o setor de entrega: </td>
                <td class="CelulaZebra2" colspan="10">
                    <input type="hidden" id="id_setor" name="id_setor" value="<%=(request.getParameter("id_setor") == null ? "" : request.getParameter("id_setor"))%>">
                    <input type="text" id="setor" name="setor" class="inputReadOnly8pt" value="<%=(request.getParameter("setor") == null ? "" : request.getParameter("setor"))%>">
                    <input type="hidden" id="bairro_setor" name="bairro_setor" value="<%= (request.getParameter("bairro_setor")== null? "": request.getParameter("bairro_setor"))%>">
                    <input type="hidden" id="cidade_setor" name="cidade_setor" value="<%=(request.getParameter("cidade_setor")== null? "" : request.getParameter("cidade_setor"))%>">
                    <input name="localiza_setor" type="button" class="botoes" id="localiza_setor" value="..." onclick="javascript:abrirLocalizaSetorEntrega();">                    
                    <img src="../img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Setor" onClick="javascript: getObj('id_setor').value ='';getObj('setor').value='';getObj('bairro_setor').value='';getObj('cidade_setor').value='';"/>
                    
                </td>
            </tr>
            <tr>
                <td class="CelulaZebra2" colspan="11"><div align="center">
                        <input name="cancelar" type="button" class="botoes" id="cancelar" value="Pesquisar" onClick="javascript:pesquisar();">
                    </div>
                </td>
            </tr>    
        </table>

        <table width="90%" align="center" cellspacing="1" class="bordaFina">
            <tr> 
                <td width="2%" class="tabela">
                    <input name="chkMarcaTodos" type="checkbox" id="chkMarcaTodos" value="" onClick="marcaTodos()">
                </td>
                <td width="8%" class="tabela">Data</td>
                <td width="5%" class="tabela"><div align="center">Série</div></td>
                <td width="5%" class="tabela">CTRC</td>
                <td width="35%" class="tabela">Remetente</td>
                <td width="35%" class="tabela">Destinatário</td>
                <td width="10%" class="tabela">Valor</td>
            </tr>
            <% //variaveis da paginacao
                    String idSetor = (request.getParameter("id_setor")==null? "" : request.getParameter("id_setor"));
                    String bairroSetor = (request.getParameter("bairro_setor")== null ? "": request.getParameter("bairro_setor")); 
                    String cidadeSetor = (request.getParameter("cidade_setor")== null ? "" : request.getParameter("cidade_setor"));
                    String idSetorB = "";
                    String idSetorC = "";
                    Date dataDe = (request.getParameter("dataDe") == null ? new Date() : Apoio.getFormatData(request.getParameter("dataDe")));
                    Date dataAte = (request.getParameter("dataAte") == null ? new Date() : Apoio.getFormatData(request.getParameter("dataAte")));
                    if(bairroSetor != ""){
                        idSetorB = idSetor;
                    } else if (cidadeSetor != ""){
                        idSetorC = idSetor;
                    }

                // se conseguiu consultar
                if (conCtrc.consultarCtrcViagem(Integer.parseInt(request.getParameter("idmotorista")), request.getParameter("ctrcs"),
                        (request.getParameter("isServico") == null ? "false" : request.getParameter("isServico")),
                        (request.getParameter("manifesto") == null ? "" : request.getParameter("manifesto")), Integer.parseInt(request.getParameter("idfilial")),
                        (request.getParameter("pedido") != null ? request.getParameter("pedido") : ""),(request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga") : ""),
                        (request.getParameter("romaneio") == null ? "" : request.getParameter("romaneio")), (idSetorB == "" ? "" : idSetorB), (idSetorC =="" ? "" : idSetorC ), dataDe, dataAte))
                       
                {
                    ResultSet rs = conCtrc.getResultado();
                    while (rs.next()) {
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td>
                    <input name="<%="chk_" + linha%>" type="checkbox" id="<%="chk_" + linha%>" value="<%=rs.getString("id")%>">
                    <Script>$('chk_'+<%=linha%>).checked = ctrcSelecionado(<%=rs.getString("id")%>);</Script> 
                </td>
                <%
                    SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
                %>
                <td><%=formato.format(rs.getDate("emissao_em"))%></td>
                <td><div align="center"><%=rs.getString("serie")%></div></td>
                <td><label name="<%="ctr_" + linha%>" id="<%="ctr_" + linha%>"><%=rs.getString("ctrc")%></label></td>
                <td><%=rs.getString("remetente")%></td>
                <td><%=rs.getString("destinatario")%></td>
                <td><label name="<%="ctrValor_" + linha%>" id="<%="ctrValor_" + linha%>"><%=Apoio.to_curr(rs.getFloat("ct_total"))%></label></td>
            </tr>
            <%          linha++;
                    }
                }
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="11"><div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
                    </div></td>
            </tr>
        </table>

    </body>
</html>

<script>
    function marcaTodos(){
        for(x=0; x <= <%=linha%>; x++){
            if ($('chk_'+x) != null){
                $('chk_'+x).checked = $('chkMarcaTodos').checked;
            }
        }
    }
</script>