<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
                 conhecimento.coleta.*,
                 java.util.Date,
                 java.text.SimpleDateFormat,
                 nucleo.Apoio" %>

<%  //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP

    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null)
      response.sendError(response.SC_FORBIDDEN,"É preciso estar logado no sistema para ter acesso a esta página.");  
    int nivelUserColeta = (Apoio.getUsuario(request) != null ?
		Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);

    ResultSet rs2 = Tributacao.all("id,descricao,codigo", Apoio.getUsuario(request).getConexao());
	String taxes = "";
	while (rs2.next()) {
	  taxes += (taxes.equals("")? "" : "!!-")+rs2.getInt("id")+":.:"+rs2.getString("codigo");
	}
	rs2.close(); 
        
    String taxesGenerico = "";
    rs2 = Tributacao.allGenericos("id,descricao,codigo", Apoio.getUsuario(request).getConexao());
        while (rs2.next()) {
            taxesGenerico += (taxesGenerico.equals("") ? "" : "!!-") + rs2.getInt("id") + ":.:" + rs2.getString("codigo");
        }
    rs2.close();
    
	BeanConsultaColeta conCol = null;
	String acao = request.getParameter("acao");
	String marcados = (request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados") );

    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA
    
    //Instanciando o bean pra trazer os CTRC's
    conCol = new BeanConsultaColeta();
    conCol.setConexao( Apoio.getUsuario(request).getConexao() );
    
%>

<script language="javascript" type="text/javascript" >
    var listaTributos;
  function fechar(){
     window.close();
  }

  function seleciona(qtdlinha){
    for (i = 0; i <= qtdlinha - 1; ++i){
      if ($("chk_"+i).checked){
            listaTributos = new Array();          
            
                listaTributos[0] = new ImpostoServico(parseFloat($('quantidade'+i).innerHTML) * parseFloat($('valor_servico'+i).innerHTML), parseFloat($('iss_servico'+i).innerHTML), $('tax_id'+i).value, $('qtd_dias'+i).value, "iss");
                listaTributos[1] = new ImpostoServico(parseFloat($('quantidade'+i).innerHTML) * parseFloat($('valor_servico'+i).innerHTML), parseFloat($('inss_servico'+i).innerHTML), $('inss_tax_id' + i).value, $('qtd_dias'+i).value, "inss");
                listaTributos[2] = new ImpostoServico(parseFloat($('quantidade'+i).innerHTML) * parseFloat($('valor_servico'+i).innerHTML), parseFloat($('pis_servico'+i).innerHTML), $('pis_tax_id' + i).value, $('qtd_dias'+i).value, "pis");
                listaTributos[3] = new ImpostoServico(parseFloat($('quantidade'+i).innerHTML) * parseFloat($('valor_servico'+i).innerHTML), parseFloat($('cofins_servico'+i).innerHTML), $('cofins_tax_id' + i).value, $('qtd_dias'+i).value, "cofins");
                listaTributos[4] = new ImpostoServico(parseFloat($('quantidade'+i).innerHTML) * parseFloat($('valor_servico'+i).innerHTML), parseFloat($('ir_servico'+i).innerHTML), $('ir_tax_id' + i).value, $('qtd_dias'+i).value, "ir");
                listaTributos[5] = new ImpostoServico(parseFloat($('quantidade'+i).innerHTML) * parseFloat($('valor_servico'+i).innerHTML), parseFloat($('cssl_servico'+i).innerHTML), $('cssl_tax_id' + i).value, $('qtd_dias'+i).value, "cssl");

                window.opener.addServ(listaTributos,
                'node_servs',
                $('sale_service_id'+i).value,
                $('id_servico'+i).value,
                $('servico'+i).innerHTML,
                $('quantidade'+i).innerHTML,
                $('valor_servico'+i).innerHTML,
                '<%=taxes%>',
                '<%=taxesGenerico%>',
                $('id_plano_custo'+i).value,
                $('conta_plano'+i).value,
                $('descricao_plano'+i).value,
                0, 
                $('numero_os'+i).value,
                $('is_usa_dias'+i).value,
                $('qtd_dias'+i).value,
                $("tax_id"+i).value+":.:"+$("codigo_taxa"+i).innerHTML+"!!-",
                "", 
                $('embutirISS_'+i).value,
                false, 
                0, 
                "");
      }
    }
    window.opener.refreshTotal(true, true);
	fechar();   
  }

  function ctrcSelecionado(id){
    var sels = '<%=marcados%>';
    for(x=0; x < sels.split(',').length; x++){
       if (sels.split(',')[x] == id)
          return true;
    }
    return false;  
  }

  function pesquisar(){
      location.replace("./seleciona_os_venda.jsp?acao=consultar&marcados=<%=marcados%>&idconsignatario="+$("idconsignatario").value+
                       "&dtinicial="+$('dtinicial').value+"&dtfinal="+$('dtfinal').value+"&con_rzs=<%=request.getParameter("con_rzs")%>");
  }

  function marcarTodos(check){
    var retorno = "";
    var i = 0;
    while ($("chk_"+i) != null){
       $("chk_"+i).checked = check;
       i++;
    }
  }

</script>

<%@page import="java.text.DecimalFormat"%>
<%@page import="venda.Tributacao"%>
<html>
<head>
<script language="javascript" src="../script/funcoes.js" type=""></script>
<script language="javascript" src="../script/builder.js" type=""></script>
<script language="javascript" src="../script/prototype_1_6.js" type=""></script>
<script language="javascript" src="../script/ImpostoServico.js" type=""></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt-br" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>WebTrans - Selecionar ordens de servi&ccedil;os para nota de servi&ccedil;o</title>
<link href="../estilo.css" rel="stylesheet" type="text/css">
</head>

    <body>
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") == null ? "0" :  request.getParameter("idconsignatario")) %>">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="619"><div align="left"><b>Selecionar ordens de servi&ccedil;os para nota de servi&ccedil;o </b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="113" class="TextoCampos">Emitidos entre: </td>
                <td width="219" class="CelulaZebra2">
                    <input name="dtinicial" type="text" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null?request.getParameter("dtinicial"):Apoio.getDataAtual())%>" size="9" maxlength="10"
                    onblur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                e
                    <input name="dtfinal" type="text" class="fieldDate" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null?request.getParameter("dtfinal"):Apoio.getDataAtual())%>" size="9" maxlength="10"
                            onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                </td>
                <td width="58" class="TextoCampos">Cliente:</td>
                <td width="282" class="CelulaZebra2">
                    <div align="left"></div>
                    <label id="con_rzs" name="con_rzs"><b><%=(request.getParameter("con_rzs")==null?"Cliente não informado":request.getParameter("con_rzs"))%></b></label>
                </td>
                <td width="120" class="CelulaZebra2">
                    <table width="100%" border="0">
                        <tbody id="cid">
                        </tbody>
                    </table>
                </td>
                <td width="107" class="CelulaZebra2">
                    <div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="javascript:pesquisar();">
                    </div>
                </td>
            </tr>
        </table>
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="2%">
                    <div align="center">
                        <input type="checkbox" name="chkTodos" value="chkTodos" onClick="javascript:marcarTodos(this.checked);">
                    </div>
                </td>
                <td width="8%">OS</td>
                <td width="10%">Data</td>
                <td width="40%">Serviço</td>
                <td width="6%"><div align="right" id="lbDias" name="lbDias" style="display:none">Dias</div></td>
                <td width="7%"><div align="right">QTD</div></td>
                <td width="7%"><div align="right">Valor</div></td>
                <td width="8%"><div align="right">Total</div></td>
                <td width="6%"><div align="right">ISS</div></td>
                <td width="6%"><div align="right">INSS</div></td>
                <td width="6%"><div align="right">PIS</div></td>
                <td width="6%"><div align="right">COFINS</div></td>
                <td width="6%"><div align="right">IR</div></td>
                <td width="6%"><div align="right">CSSL</div></td>
                <td width="7%"><div align="center">Valor ISS</div></td>
                <td width="4%">Trib</td>
            </tr>
        <% //variaveis da paginacao
            int linha = 0;
            Date data;
            if ((request.getParameter("dtinicial")!=null)){
                data = Apoio.paraDate(request.getParameter("dtinicial"));
            }else{
                data = Apoio.paraDate(Apoio.getDataAtual());
            }
            conCol.setDtEmissao1(data);    
            if ((request.getParameter("dtfinal")!=null)){
                data = Apoio.paraDate(request.getParameter("dtfinal"));
            }else{
                data = Apoio.paraDate(Apoio.getDataAtual());
            }
            conCol.setDtEmissao2(data);    
            conCol.setClienteId(Apoio.parseInt(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0"));
            // se conseguiu consultar
            if (conCol.loadServicos(marcados)){
                ResultSet rs = conCol.getResultado();
                    while (rs.next()){
        %>
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                        <td>
                            <input name="<%="chk_" + linha %>" type="checkbox" id="<%="chk_" + linha %>" value="<%=rs.getString("sale_service_id")%>">
                            <Script>$('chk_'+<%=linha%>).checked = ctrcSelecionado(<%=rs.getString("sale_service_id")%>);</Script> 
                            <input type="hidden" name="sale_service_id<%=linha%>" id="sale_service_id<%=linha%>" value="<%=rs.getString("sale_service_id")%>">
                            <input type="hidden" name="is_usa_dias<%=linha%>" id="is_usa_dias<%=linha%>" value="<%=rs.getBoolean("is_usa_dias")%>">
                            <input type="hidden" name="qtd_dias<%=linha%>" id="qtd_dias<%=linha%>" value="<%=rs.getInt("qtd_dias")%>">
                        </td>
            <%
                        SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
            %>
                        <td>
                            <%if (nivelUserColeta > 0){%>
                                    <label onClick="window.open('../cadcoleta?acao=editar&id=<%=rs.getString("id_os")%>&ex=false', 'Manifesto' , 'top=0,resizable=yes,status=1,scrollbars=1')" class="linkEditar">
                                            <%=rs.getString("numero_os")%>
                                    </label>
                            <%}else{ %>	
                                    <%=rs.getString("numero_os")%> 
                            <%} %>	
                            <input type="hidden" name="numero_os<%=linha%>" id="numero_os<%=linha%>" value="<%=rs.getString("numero_os")%>">
                        </td>
                        <td><%=formato.format(rs.getDate("data_os"))%></td>
                        <td>
                            <label id="servico<%=linha%>" name="servico<%=linha%>"><%=rs.getString("servico")%></label>
                            <input type="hidden" name="id_servico<%=linha%>" id="id_servico<%=linha%>" value="<%=rs.getString("id_servico")%>">
                        </td>
                        <td>
                            <div align="right">
                                <label id="dias<%=linha%>" name="dias<%=linha%>">
                                    <%=(rs.getBoolean("is_usa_dias") ?  rs.getInt("qtd_dias")+"" : "")%>
                                </label>
                            </div>
                        </td>
                        <td><div align="right"><label id="quantidade<%=linha%>" name="quantidade<%=linha%>"><%=rs.getFloat("quantidade")%></label></div></td>
                        <td><div align="right"><label id="valor_servico<%=linha%>" name="valor_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("valor_servico"))%></label></div></td>
                        <td><div align="right"><label id="total_servico<%=linha%>" name="total_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("total_servico"))%></label></div></td>
                        <td><div align="right"><label id="iss_servico<%=linha%>" name="iss_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("iss_servico"))%></label></div></td>
                        <td><div align="right"><label id="inss_servico<%=linha%>" name="inss_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("inss_servico"))%></label></div></td>
                        <td><div align="right"><label id="pis_servico<%=linha%>" name="pis_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("pis_servico"))%></label></div></td>
                        <td><div align="right"><label id="cofins_servico<%=linha%>" name="cofins_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("cofins_servico"))%></label></div></td>
                        <td><div align="right"><label id="ir_servico<%=linha%>" name="ir_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("ir_servico"))%></label></div></td>
                        <td><div align="right"><label id="cssl_servico<%=linha%>" name="iss_servico<%=linha%>"><%=Apoio.to_curr(rs.getDouble("cssl_servico"))%></label></div></td>
                        <td><div align="right"><label id="valor_iss<%=linha%>" name="valor_iss<%=linha%>"><%=Apoio.to_curr(rs.getDouble("valor_iss"))%></label></div></td>
                        <td>
                            <input type="hidden" name="codigo_taxa<%=linha%>" id="codigo_taxa<%=linha%>" value="<%=rs.getString("codigo_taxa")%>">
                            <input type="hidden" name="tax_id<%=linha%>" id="tax_id<%=linha%>" value="<%=rs.getString("tax_id")%>">
                            <input type="hidden" name="inss_tax_id<%=linha%>" id="inss_tax_id<%=linha%>" value="<%=rs.getString("inss_tax_id")%>">
                            <input type="hidden" name="pis_tax_id<%=linha%>" id="pis_tax_id<%=linha%>" value="<%=rs.getString("pis_tax_id")%>">
                            <input type="hidden" name="cofins_tax_id<%=linha%>" id="cofins_tax_id<%=linha%>" value="<%=rs.getString("cofins_tax_id")%>">
                            <input type="hidden" name="ir_tax_id<%=linha%>" id="ir_tax_id<%=linha%>" value="<%=rs.getString("ir_tax_id")%>">
                            <input type="hidden" name="cssl_tax_id<%=linha%>" id="cssl_tax_id<%=linha%>" value="<%=rs.getString("cssl_tax_id")%>">
                            <input type="hidden" name="id_plano_custo<%=linha%>" id="id_plano_custo<%=linha%>" value="<%=rs.getString("id_plano_custo")%>">
                            <input type="hidden" name="conta_plano<%=linha%>" id="conta_plano<%=linha%>" value="<%=rs.getString("conta_plano")%>">
                            <input type="hidden" name="descricao_plano<%=linha%>" id="descricao_plano<%=linha%>" value="<%=rs.getString("descricao_plano")%>">
                            <input type="hidden" name="embutirISS_<%=linha%>" id="embutirISS_<%=linha%>" value="<%=rs.getString("embutir_iss")%>">
                        </td>
                    </tr>
                    <script language="javascript" type="text/javascript" >
                        if (<%=rs.getBoolean("is_usa_dias")%>){
                            $("lbDias").style.display="";
                        }
                    </script>
        <%          linha++;

                }
            } 
        %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                <td colspan="16">
                    <div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
                    </div>
                </td>
            </tr>
        </table>
    </body>
</html>