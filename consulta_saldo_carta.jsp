<%@page import="br.com.gwsistemas.cfe.pagbem.PagBemBO"%>
<%@page import="filial.BeanFilial"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  conhecimento.cartafrete.*,
                  fpag.*,
                  java.text.*,
                  nucleo.Apoio" errorPage="" %>
<%@ page import="org.apache.commons.lang3.StringUtils" %>

<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type="text/javascript"></script>
<script language="JavaScript"  src="script/<%=Apoio.noCacheScript("prototype.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_6.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("funcoes_gweb.js")%>" type="text/javascript"></script>
<%
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("consaldocarta") : 0);
   int nivelUserCarta = (Apoio.getUsuario(request) != null
        ? Apoio.getUsuario(request).getAcesso("lancartafrete") : 0);
   int nivelUserDespesa = (Apoio.getUsuario(request) != null
	        ? Apoio.getUsuario(request).getAcesso("caddespesa") : 0);
   int nivelUserCtrc = (Apoio.getUsuario(request) != null
	        ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
   int nivelLiberaSaldo = (Apoio.getUsuario(request) != null
	        ? Apoio.getUsuario(request).getAcesso("liberasaldocarta") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser==0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA
  int nivelUserBaixarDespesa = Apoio.getUsuario(request).getAcesso("bxpagarviagem");
  int nivelUserBaixarCTRC = Apoio.getUsuario(request).getAcesso("bxctrc");
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  
  String cnpjContratantePamcard = Apoio.getUsuario(request).getFilial().getCnpjContratantePamcard();
  //permissao para confirmar pagamento do saldo na NDD
  int nivelConfirmarPgtoNDD = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("confirmarPagamentoNDD") : 0);
  boolean filialConfirmarPgtoNDD = Apoio.getUsuario(request).getFilial().isConfirmarPagamentoNDD();
  char stUtilizacaoCFe = Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe();
  boolean emissaoGratuita = Apoio.getUsuario(request).getFilial().isEmissaoGratuita();
  
  
%>
  <jsp:useBean id="conCf" class="conhecimento.cartafrete.BeanConsultaCartaFrete" />
<%
  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("consultar")){
      conCf.setConexao(Apoio.getUsuario(request).getConexao());
      conCf.setData(Apoio.paraDate(request.getParameter("dtinicial")));
      conCf.setData2(Apoio.paraDate(request.getParameter("dtfinal")));
      conCf.setMotoristaId(Integer.parseInt(request.getParameter("idmotorista")));
      conCf.setProprietarioId(Integer.parseInt(request.getParameter("idproprietario")));
      conCf.setCtrc(request.getParameter("ctrc"));
      conCf.setVeiculoId(Integer.parseInt(request.getParameter("idveiculo")));
      conCf.setClienteId(request.getParameter("idconsignatario") != null ? Integer.parseInt(request.getParameter("idconsignatario")): 0);
      conCf.setConsultarTodasFiliais(Apoio.parseInt(request.getParameter("idConsultarFiliais")));
      conCf.setMostrarApenasSaldosAberto(Apoio.parseBoolean(request.getParameter("chk_saldo")));
      conCf.setIdCartaFrete(request.getParameter("idcfe"));
      conCf.setApenasSaldosAutorizados(request.getParameter("apenasSaldosAutorizados") != null ? request.getParameter("apenasSaldosAutorizados") : "");
      conCf.setNotaFiscalCliente(request.getParameter("notaFiscalCliente"));
  }else if (acao.equals("carregar_ctrcs")){
      conCf.setConexao(Apoio.getUsuario(request).getConexao());
	  if (conCf.mostraCtrcConsultaSaldo(Integer.parseInt(request.getParameter("idcarta")))){;
   	      ResultSet ctrc = conCf.getResultado();
   	      int row = 0;
   	      boolean finalizado = false;
   	      String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'"+ request.getParameter("idcarta") +">"+
   	                         "<tr class='tabela'>"+
          	                 "<td width='8%'>CTRC</td>"+
          	                 "<td width='7%'>Filial</td>"+
          	                 "<td width='7%'>Data</td>"+
          	                 "<td width='18%'>Remetente</td>"+
          	                 "<td width='18%'>Destinatário</td>"+
          	                 "<td width='8%'>Entregas</td>"+
                                 "<td width='7%'>Entrega</td>"+
          	                 "<td width='7%'>Dt Comp.</td>"+
          	                 "<td width='5%'><div align='right'>Avaria</div></td>"+
          	                 "<td width='16%'>OBS</td>"+
   	                         "</tr>";
              double totalReceita = 0;
              double totalPeso = 0;
   	      while (ctrc.next()){
                  totalReceita += ctrc.getDouble("total_receita");
                  totalPeso += ctrc.getDouble("total_peso");
   	    	  finalizado = ctrc.getDate("baixa_em") != null;
   	    	  resultado += "<tr class="+((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+">";
   	    	  resultado += "<td> <div" +
   	    	               (nivelUserCtrc == 0 ?
   	    	               "" :
   	    	               " class='linkEditar' onClick='javascript:tryRequestToServer(function(){verCtrc("+ctrc.getString("id")+");});'")
   	    	               + ">"+ ctrc.getString("numero")+"-"+ctrc.getString("serie")+"</div></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>" + ctrc.getString("fi_abreviatura")+"</font></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+formatador.format(ctrc.getDate("emissao_em"))+"</font></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+ctrc.getString("remetente")+"</font></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+ctrc.getString("destinatario")+"</font></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+ctrc.getString("quantidade_entregas")+" <br>"+new DecimalFormat("#,##0").format(ctrc.getFloat("total_peso"))+" Kg </font></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+(ctrc.getString("baixa_em") == null ? "Não" : formatador.format(ctrc.getDate("baixa_em")))+"</font></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+(ctrc.getString("baixado_no_dia") == null ? "" : formatador.format(ctrc.getDate("baixado_no_dia")))+"</font></td>";
   	    	  resultado += "<td><div align='right'><font color='" + (finalizado ? "" : "#CC0000") + "'>"+new DecimalFormat("#,##0.00").format(ctrc.getFloat("valor_avaria"))+"</font></div></td>";
   	    	  resultado += "<td><font color='" + (finalizado ? "" : "#CC0000") + "'>"+ctrc.getString("observacao_baixa")+"</font></td>";
   	    	  resultado += "</tr>";
   	    	  row++;
   	      }
              resultado += "<tr class='tabela'  class='bordaFina'><td colspan='9'>" +
                      "<table><tr>" +
                      "<td width='12%'>Total Frete:</td>" +
                      "<td width='10%'>"+new DecimalFormat("#,##0.00").format(totalReceita)+"</td>" +
                      "<td width='10%'>Total Peso:</td>" +
                      "<td width='15%'>"+new DecimalFormat("#,##0.000").format(totalPeso)+"Kg(s)</td>"+
                       "<td width='53%'></td>"+
                      "</tr></table></td>";
                        if(nivelUserBaixarCTRC == 4){                          
                            resultado += "<td> <a href='#' onclick='verContratoFrete("+request.getParameter("idcarta")+")' >Abrir tela de baixa de CT-e/Manifesto</a> </td>";
                        }else{
                            resultado += "<td></td>";
                        }
                      resultado +="</tr></table>";
          response.getWriter().append(resultado);
      }else{
   		response.getWriter().append("load=0");
	  }
      response.getWriter().close();
  }else if (acao.equals("carregar_pagamentos")){
      conCf.setConexao(Apoio.getUsuario(request).getConexao());
	  if (conCf.mostraPagtosConsultaSaldo(Integer.parseInt(request.getParameter("idcarta")))){;
   	      ResultSet pag = conCf.getResultado();
              DecimalFormat moeda = new DecimalFormat("#,##0.00");
              SimpleDateFormat fmtData = new SimpleDateFormat("dd/MM/yyyy");
   	      int row = 0;
              BeanConsultaFPag fpag = new BeanConsultaFPag();
              fpag.setConexao(Apoio.getUsuario(request).getConexao());
              StringBuilder resultado = new StringBuilder();
   	      resultado.append("<table width='100%' border='0' class='bordaFina' id='trid_'"+ request.getParameter("idcarta") +">"+
   	                         "<tr class='tabela'>"+
          	                 "<td width='9%'>Tipo</td>"+
          	                 "<td width='7%'>Valor</td>"+
          	                 "<td width='14%'>Forma/Agente Pagto</td>"+
          	                 "<td width='7%'>Despesa</td>"+
          	                 "<td width='8%'>Saldo Aut.</td>"+
          	                 "<td width='6%'>Avaria</td>"+
          	                 "<td width='6%'>Acréscimo</td>"+
          	                 "<td width='6%'>Valor Pagto</td>"+
          	                 "<td width='11%'>Usuário Aut.</td>"+
          	                 "<td width='9%'>Data Aut.</td>"+
                                 "<td width='9%'>Vencimento</td>"+
                                 "<td width='8%'baixar>Pago em</td>"+
                                 "<td width='3%'></td>"+
                                 "<td width='3%'></td>"+
   	                         "</tr>");
   	      while (pag.next()){
   	    	  resultado.append("<tr class="+((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")+">");
   	    	  resultado.append("<td>"+ pag.getString("tipo_fpag")+"");
   	    	  resultado.append("<input type='hidden' id='tipoPgto_"+pag.getString("id")+"' name='tipoPgto_"+pag.getString("id")+"' value='"+ pag.getString("tipo_fpag")+"'/>");
   	    	  resultado.append("</td>");
   	    	  resultado.append("<td>" +
                                   "<input type='hidden' name='idcarta_"+pag.getString("id")+"' id='idcarta_"+pag.getString("id")+"' value='"+pag.getString("carta_frete_id")+"' />" +
                                   "<input type='hidden' name='ciot_"+pag.getString("id")+"' id='ciot_"+pag.getString("id")+"' value='"+pag.getString("ciot")+"' />" +
                                   "<input type='hidden' name='ciotCodVerificador_"+pag.getString("id")+"' id='ciotCodVerificador_"+pag.getString("id")+"' value='"+pag.getString("ciot_cod_verificador")+"' />" +
                                   "<input type='hidden' name='guidHeaderNdd_"+pag.getString("id")+"' id='guidHeaderNdd_"+pag.getString("id")+"' value='"+pag.getString("guid_header_ndd")+"' />" +
                                   "<input type='hidden' name='nota_fiscal_"+pag.getString("id")+"' id='nota_fiscal_"+pag.getString("id")+"' value='"+pag.getString("nota_fiscal")+"' />" +
                                   "<input type='hidden' name='iddespesa_"+pag.getString("id")+"' id='iddespesa_"+pag.getString("id")+"' value='"+pag.getString("despesa_id")+"' />" +
                                   "<input type='hidden' name='idfilial_"+pag.getString("id")+"' id='idfilial_"+pag.getString("id")+"' value='"+pag.getString("idfilial")+"' />" +
                                   "<input type='hidden' name='historicoDespesa_"+pag.getString("id")+"' id='historicoDespesa_"+pag.getString("id")+"' value='"+pag.getString("historico_despesa")+"' />" +
                                   "<input type='hidden' name='idHistorico_"+pag.getString("id")+"' id='idHistorico_"+pag.getString("id")+"' value='"+pag.getString("historico_id")+"' />" +
                                   "<input type='hidden' name='idContaNdd_"+pag.getString("id")+"' id='idContaNdd_"+pag.getString("id")+"' value='"+pag.getString("conta_cfe_id")+"' />" +
                                   "<input type='hidden' name='idDuplDespesa_"+pag.getString("id")+"' id='idDuplDespesa_"+pag.getString("id")+"' value='"+pag.getString("id_dupl_despesa")+"' />" +                                   
                                   "<input type='text' size='5' maxlenght='12' name='valorPagto_"+pag.getString("id")+"' id='valorPagto_"+pag.getString("id")+"' value='"+pag.getString("valor_pagto")+"' onChange='seNaoFloatReset(this,0.00);' class='inputtexto' disabled/>" +
                                   "<input type='hidden' name='stUtilizacaoCfe_"+pag.getString("id")+"' id='stUtilizacaoCfe_"+pag.getString("id")+"' value='"+pag.getString("st_utilizacao_cfe")+"' />"+        
                                   "</td>");
   	    	  resultado.append("<td><SELECT name='fpagPagto_"+pag.getString("id")+"' id='fpagPagto_"+pag.getString("id")+"' DISABLED class='inputtexto' style='width:120px' >");
		  fpag.MostrarTudo();
                  ResultSet rs = fpag.getResultado();
                  while (rs.next()){
                      resultado.append("<OPTION value='"+rs.getString("idfpag")+"' "+(rs.getString("idfpag").equals(pag.getString("forma_pagamento_id"))?"SELECTED":"")+">"+rs.getString("descfpag")+"</OPTION>");
                  }
                  rs.close();
                  String agentePagador = (pag.getString("agente_pagador")== null?"":pag.getString("agente_pagador"));
                  resultado.append("</SELECT>");
                  if(pag.getString("forma_pagamento_id").equals("8")){
                  resultado.append("<br/><input type='text' name='agentePgto_"+pag.getString("id")+"' id='agentePgto_"+pag.getString("id")+"' class='inputReadOnly8pt'  value='"+agentePagador+"' style='width:80px' readonly /><input type='hidden' name='idAgentePgto_"+pag.getString("id")+"' id='idAgentePgto_"+pag.getString("id")+"'> <input type='button' class='inputBotaoMin' value='...' onclick='abrirLocalizaAgente("+pag.getString("id")+")'>");
                  }
                  resultado.append("</td>");
   	    	  resultado.append("<td><div" +
   	    	               (nivelUserDespesa == 0 ? "" :
   	    	               " class='linkEditar' onClick='javascript:tryRequestToServer(function(){verDespesa("+pag.getString("despesa_id")+");});'")
   	    	               + ">"+(pag.getString("despesa_id").equals("0")?"":pag.getString("despesa_id"))+"</div></td>");
                  String exibirJustificativa = (pag.getBoolean("is_saldo_autorizado")?"none":"");
                  String saldoAutorizadoJustifica = (pag.getString("justificativa_saldo_nao_autorizado") != null? pag.getString("justificativa_saldo_nao_autorizado"): "");
   	    	  resultado.append("<td><SELECT  class='inputtexto' name='libPagto_"+pag.getString("id")+"' id='libPagto_"+pag.getString("id")+"' onChange='exibirJustificativa(this,"+pag.getString("id")+");' "+(pag.getString("tipo_pagamento").equals("a")? "" /*"style='display:none;'"*/:"")+" "+(pag.getBoolean("baixado")?"DISABLED":"")+">" +
                          "<OPTION value='true' "+(pag.getBoolean("is_saldo_autorizado")?"SELECTED":"")+">SIM</OPTION>" +
                          "<OPTION value='false' "+(pag.getBoolean("is_saldo_autorizado")?"":"SELECTED")+">NÃO</OPTION>" +
                          "</SELECT>"+
                          "<input type='text' name='saldoAutorizadoJustifica_"+pag.getString("id")+"' id='saldoAutorizadoJustifica_"+pag.getString("id")+"' class='inputtexto' size='10' maxlength='50' style='display:"+exibirJustificativa+"' value='"+saldoAutorizadoJustifica+"' "+(pag.getBoolean("baixado")?"DISABLED":"")+"/> </td>");
   	    	  resultado.append("<td><input type='text' size='5' maxlenght='12' name='avariaPagto_"+pag.getString("id")+"' id='avariaPagto_"+pag.getString("id")+"' value='0.00' "+(pag.getString("tipo_pagamento").equals("a")?"style='display:none;'":"")+" onChange='seNaoFloatReset(this,0.00);' onBlur='calculaLiquido("+pag.getString("id")+")'  class='inputtexto' style='color: red ' /></td>");
   	    	  resultado.append("<td><input type='text' size='5' maxlenght='12' name='acrescimoPagto_"+pag.getString("id")+"' id='acrescimoPagto_"+pag.getString("id")+"' value='0.00' "+(pag.getString("tipo_pagamento").equals("a")?"style='display:none;'":"")+" onChange='seNaoFloatReset(this,0.00);' onBlur='calculaLiquido("+pag.getString("id")+")' class='inputtexto' /></td>");
                  resultado.append("<td><input type='text' size='5' maxlenght='12' name='valorLiqPagto_"+pag.getString("id")+"' id='valorLiqPagto_"+pag.getString("id")+"' value='"+pag.getString("valor_pagto")+"' "+(pag.getString("tipo_pagamento").equals("a")?"style='display:none;'":"")+" onChange='seNaoFloatReset(this,0.00);' class='inputtexto' disabled/></td>");
   	    	  resultado.append("<td>"+pag.getString("usuario_autorizacao")+"</td>");
   	    	  resultado.append("<td>"+(pag.getDate("autorizado_em") == null ? "" : fmtData.format(pag.getDate("autorizado_em")))+"</td>");
   	    	  resultado.append("<td><input type='text' size='8' maxlenght='10' name='vencPagto_"+pag.getString("id")+"' id='vencPagto_"+pag.getString("id")+"'   onkeypress='fmtDate(this, event)' onkeyup='fmtDate(this, event)' onkeydown='fmtDate(this, event)' onblur='alertInvalidDate(this)' value='"+(pag.getDate("dtvenc") == null ? "" : fmtData.format(pag.getDate("dtvenc")))+"' "+(pag.getString("tipo_pagamento").equals("a")? "" /*"style='display:none;'"*/:"")+" class='inputtexto' size='10'/></td>");
   	    	  resultado.append("<td>"+(pag.getDate("dtpago") == null ? "Em Aberto" : fmtData.format(pag.getDate("dtpago")))+"</td>");
   	    	  if (nivelLiberaSaldo == 4 && !pag.getString("valor_pagto").equals("0.00")){                      
                      resultado.append("<td><img src='img/save.gif' border='0' align='absbottom' class='imagemLink' title='Autorizar pagamento do saldo.' onClick='javascript:autorizarSaldo("+pag.getString("id")+");' "+(/*pag.getString("tipo_pagamento").equals("a")||*/pag.getBoolean("baixado")?"style='display:none;'":"")+" /></td>");
                  }else{
                      resultado.append("<td></td>");
                  }
   	    	  if (nivelUserBaixarDespesa == 4 && pag.getDate("dtpago") == null && pag.getInt("forma_pagamento_id")!=8 && !pag.getString("valor_pagto").equals("0.00")){
                    resultado.append("<td><img src='img/baixar.gif' border='0' align='absbottom' class='imagemLink' title='Baixar este ").append(pag.getString("tipo_fpag")).append(" .' onClick='javascript:baixar("+pag.getString("id")+");' /></td>");
                  }else{
                      resultado.append("<td></td>");
                  }
   	    	  resultado.append("</tr>");
   	    	  row++;
   	      }
     	  resultado.append("</table>");
          response.getWriter().append(resultado.toString());
      }else{
   		response.getWriter().append("load=0");
	  }
      response.getWriter().close();
  }else if (acao.equals("autoriza_saldo")){
      BeanCartaFrete cFrete = new BeanCartaFrete();
      cFrete.setIdcartafrete(Integer.parseInt(request.getParameter("id_carta")));
      cFrete.setVlAvaria(Float.parseFloat(request.getParameter("avaria_carta")));
      cFrete.setOutrosdescontos(Apoio.parseFloat(request.getParameter("valorAcrescimo")));
      BeanPagamentoCartaFrete[] arrayPags = new BeanPagamentoCartaFrete[1];
      BeanPagamentoCartaFrete pg = new BeanPagamentoCartaFrete();
      pg.setId(Integer.parseInt(request.getParameter("id")));
      pg.setValor(Float.parseFloat(request.getParameter("valor_saldo")));
      pg.setSaldoAutorizado(Boolean.parseBoolean(request.getParameter("saldo_autorizado")));
      pg.getDespesa().setDtEntrada(Apoio.paraDate(request.getParameter("vencimento_saldo")));
      pg.getDespesa().setIdmovimento(Integer.parseInt(request.getParameter("id_despesa")));
      pg.getAgente().setNomeFantasia(request.getParameter("agente_pagador").equals("")?"":request.getParameter("agente_pagador"));
      pg.getAgente().setIdfornecedor(Apoio.parseInt(request.getParameter("agente_pagador_id")));
      pg.setSaldoAutorizadoJustifica(request.getParameter("saldo_autorizado_justifica"));
      arrayPags[0] = pg;
      cFrete.setPagamento(arrayPags);

      BeanCadCartaFrete cadCarta = new BeanCadCartaFrete();
      cadCarta.setConexao(Apoio.getUsuario(request).getConexao());
      cadCarta.setExecutor(Apoio.getUsuario(request));
      cadCarta.setCFrete(cFrete);

      boolean erroAuto = !cadCarta.AutorizaSaldo();
      
      
      boolean erroPagBem = false;
      boolean enviarPagBem = Apoio.parseBoolean(request.getParameter("enviarPagBem"));
      if(!erroAuto && enviarPagBem){
        int cartaID = Apoio.parseInt(request.getParameter("id_carta"));
        String valorAcrescimo = request.getParameter("valorAcrescimo");

        PagBemBO pagBemBO = new PagBemBO(Apoio.getUsuario(request));
        erroPagBem = pagBemBO.ajusteFinanceiro(cartaID, valorAcrescimo, cadCarta);
      }

      String scr = "";
      if (erroAuto || (enviarPagBem && erroPagBem)){
          scr = "<script>alert('" + cadCarta.getErros().replace("\r", " " ) + "');"+
                 "window.close();" +
                 "</script>";
      }else if(enviarPagBem && !erroPagBem){
           scr = "<script>alert('Ajuste Realizado com Sucesso!');"+
                 "window.close();" +
                 "</script>";
      }else{
          scr = "<script>";
          scr += "window.opener.document.getElementById('visualizar').onclick();" +
                 "window.close();" +
                 "</script>";
      }


        response.getWriter().append(scr);
        response.getWriter().close();

      
      
  } else if (acao.equals("salvar")) {
      BeanCartaFrete cFrete = new BeanCartaFrete();
      cFrete.setIdcartafrete(Integer.parseInt(request.getParameter("idcartafrete")));
      cFrete.getOcorrencia().setId(Integer.parseInt(request.getParameter("ocorrencia")));

      BeanCadCartaFrete cadCarta = new BeanCadCartaFrete();
      cadCarta.setConexao(Apoio.getUsuario(request).getConexao());
      cadCarta.setExecutor(Apoio.getUsuario(request));
      cadCarta.setCFrete(cFrete);
      boolean erroAoSalvarOcorrencia = !cadCarta.SalvarOcorrencia();
      String scr = "";
      if (erroAoSalvarOcorrencia) {
          scr = "<script>alert('" + StringUtils.normalizeSpace(cadCarta.getErros()) + "');" +
                  "window.close();" +
                  "</script>";
      } else {
          // Deverá verificar se irá salvar a ocorrência para o motorista, e para o proprietário
          if (Apoio.parseBoolean(request.getParameter("is_motorista"))) {
              int motoristaId = Apoio.parseInt(request.getParameter("motorista_id"));

              if (!cadCarta.cadastrarOcorrenciaMotoristaFornecedor(motoristaId, false)) {
                  scr = "<script>alert('" + StringUtils.normalizeSpace(cadCarta.getErros()) + "');" +
                          "window.close();" +
                          "</script>";

                  erroAoSalvarOcorrencia = true;
              }
          }

          if (Apoio.parseBoolean(request.getParameter("is_fornecedor"))) {
              int proprietarioId = Apoio.parseInt(request.getParameter("fornecedor_id"));

              if (!cadCarta.cadastrarOcorrenciaMotoristaFornecedor(proprietarioId, true)) {
                  scr = "<script>alert('" + StringUtils.normalizeSpace(cadCarta.getErros()) + "');" +
                          "window.close();" +
                          "</script>";

                  erroAoSalvarOcorrencia = true;
              }
          }

          if (!erroAoSalvarOcorrencia) {
              scr = "<script>";
              scr += "alert('Cadastro efetuado com sucesso ! ');";
              scr += "window.opener.document.getElementById('visualizar').onclick();";
              scr += "window.close();";
              scr += "</script>";
          }
      }

      response.getWriter().append(scr);
      response.getWriter().close();
  }
  
      
%>


<script language="javascript" type="text/javascript">
  var nivelBxDespesaViagem = <%=nivelUserBaixarDespesa%>;
  var dataAtual = '<%=Apoio.getDataAtual()%>';
  
  jQuery.noConflict();
  
  function baixar(idx){
      
    var notaFiscal = $("nota_fiscal_"+idx).value;
    var idFilial = $("idfilial_"+idx).value;
    var cnpjContratantePamcard = $("cnpjContratantePamcard").value;
    var tipoPgto = $("tipoPgto_"+idx).value;
    var ciot = $("ciot_"+idx).value;
    var ciotCodVerificador = $("ciotCodVerificador_"+idx).value;
    var guidHeaderNdd = $("guidHeaderNdd_"+idx).value;
    var idDespesa = $("iddespesa_"+idx).value;
    var fpagPgto = $("fpagPagto_"+idx).value;
    var valorPagto = $("valorPagto_"+idx).value;
    var idDuplDespesa = $("idDuplDespesa_"+idx).value;
    var historicoDespesa = $("historicoDespesa_"+idx).value;
    var contaNDD = $("idContaNdd_"+idx).value;
    var valorAvaria = $("avariaPagto_"+idx).value;
    
    var valorLiquido = $("valorLiqPagto_"+idx).value;

    var idcartaFrete = $("idcarta_"+idx).value;
    var saldo_autorizado = $('libPagto_'+idx).value;
    var vencimento_saldo = $('vencPagto_'+idx).value;
    var saldo_autorizado_justifica = $('saldoAutorizadoJustifica_'+idx).value;
    var valorAcrescimo = $('acrescimoPagto_'+idx).value;
    
    var agente = $('agentePgto_'+idx) != null ? $('agentePgto_'+idx).value : "''";
    var stUtilizacaoCFe = $('stUtilizacaoCfe_'+idx).value;

    //nova validação para baixa do saldo, o usuario poderá sincronizar com a ndd, de acordo com as permissões
    if (<%=nivelConfirmarPgtoNDD == 4%> && <%=filialConfirmarPgtoNDD == true%> && tipoPgto == 'Saldo' && stUtilizacaoCFe == 'D'){

        if(contaNDD == "null"){
            alert("A 'Conta NDD' não está preenchida no cadastro da 'Filial', aba 'Integrações'!");
            return false;
        }
        espereEnviar("Aguarde...",true);
        if (ciot != 0 && ciotCodVerificador != 0) {    
            function e(transport){
                var textoresposta = transport.responseText;
                if (textoresposta == "-1") {
                    alert('Atenção: Houve algum problema ao requistar a confirmação do pagamento de saldo pela Ndd, favor tente novamente.');
                    return false;
                }else{
                    var retornoNdd = jQuery.parseJSON(textoresposta).retornoNddPagamentoSaldo;
                    
                    if (retornoNdd.codigoRetorno == 200 && retornoNdd.pagamentoRetorno == true) {
                        alert("Pagamento realizado com sucesso!");
                        location.reload();
                    }else if (retornoNdd.pagamentoRetorno == false && retornoNdd.codigoRetorno == 200){
                        alert(retornoNdd.mensagemRetorno);
                    }else if (retornoNdd.codigoRetorno != 200){
                        alert('Atenção: Houve algum problema ao requistar a confirmação do pagamento de saldo pela Ndd, favor tente novamente.');
                    }
                    espereEnviar("Aguarde...",false);
                }
            }
            var textoObservacao = prompt("Observação pagamento do saldo NDD?" ,"");
            var textoObservacao = (textoObservacao != null ? textoObservacao : "");
            new Ajax.Request("NddControlador?acao=pagamentoImediatoSaldoNDD&cnpjContratantePamcard="+cnpjContratantePamcard
                    +"&observacao="+textoObservacao+"&ciot="+ciot+"&ciotCodVerificador="+ciotCodVerificador+"&guidHeaderNdd="+guidHeaderNdd
            +"&notaFiscal="+notaFiscal+"&idFilial="+idFilial+"&idDespesa="+idDespesa+"&fpagPgto="+fpagPgto+"&valorPagto="+valorPagto
            + "&idDuplDespesa="+idDuplDespesa+"&contaNDD="+contaNDD+"&historicoDespesa="+historicoDespesa,{method:'post',onSuccess:e,onError: e});
        }else{
            espereEnviar("Aguarde...",false);
            alert("Atenção: Favor confirmar contrato com a NDD!");
            return false;
        }
    }else if(<%=nivelConfirmarPgtoNDD == 4%> && <%=filialConfirmarPgtoNDD == true%> && tipoPgto == 'Saldo' && stUtilizacaoCFe == 'E' && <%=!emissaoGratuita%> && fpagPgto==16){
        espereEnviar("Aguarde...",true);
        if (ciot != 0 && ciotCodVerificador != 0) {
         
            function efrete(transport){
                //alert("oi");
                //   location.reload();
                var textoresposta = transport.responseText;
                if (textoresposta == "-1") {
                    alert('Atenção: Houve algum problema ao requistar a confirmação do pagamento de saldo pela E-Frete, favor tente novamente.');
                    espereEnviar("Aguarde...",false);
                    return false;
                }else{
                    var retornoEfrete = jQuery.parseJSON(textoresposta).registrarPagamentoQuitacaoResponse;
                    if (retornoEfrete.localSucesso == "true") {
                        alert("Pagamento realizado com sucesso!");
                        location.reload();
                    }else {
                        alert("Atenção! Mensagem do servidor e­Frete: "+retornoEfrete.localExcecao.localMensagem);
                    }
                    location.reload();
                    espereEnviar("Aguarde...",false);
                }
            }
            var textoObservacao = prompt("Observação pagamento do saldo E-Frete?" ,"");
            var textoObservacao = (textoObservacao != null ? textoObservacao : "");
            new Ajax.Request("EFreteControlador?acao=pagamentoImediatoSaldo&observacao="+textoObservacao+"&ciot="+ciot+"&ciotCodVerificador="
                    +ciotCodVerificador+"&idFilial="+idFilial+"&idDespesa="+idDespesa+"&fpagPgto="+fpagPgto+"&valorPagto="+valorPagto
            + "&idDuplDespesa="+idDuplDespesa+"&contaNDD="+contaNDD+"&historicoDespesa="+historicoDespesa,{method:'post',onSuccess:efrete,onError: efrete});
     }else{
            espereEnviar("Aguarde...",false);
            alert("Atenção: Favor confirmar contrato com a E-Frete!");
            return false;
        }
    }else if(<%=nivelConfirmarPgtoNDD == 4%> && <%=filialConfirmarPgtoNDD == true%> && tipoPgto == 'Saldo' && stUtilizacaoCFe == 'X'  && fpagPgto==17){
        espereEnviar("Aguarde...",true);
        if (ciot != 0 && ciotCodVerificador != 0) {
         
            function expers(transport){
                //alert("oi");
                //   location.reload();
                var textoresposta = transport.responseText;
                if (textoresposta == "-1") {
                    alert('Atenção: Houve algum problema ao requistar a confirmação do pagamento de saldo pela ExpeRS, favor tente novamente.');
                    espereEnviar("Aguarde...",false);
                    return false;
                }else{
                    var retornoExpers = jQuery.parseJSON(textoresposta).operacaoTransporteResposta;
                  
                    if (retornoExpers.localSucesso == 'true' || retornoExpers.localSucesso == true) {
                        alert("Pagamento realizado com sucesso!");  
                        location.reload();
                    }else {
                        alert("Atenção! Mensagem do servidor ExpeRS: "+retornoExpers.localExcecao.localCodigo+"-"+retornoExpers.localExcecao.localMensagem); //localCodigo
                    }
                    location.reload();
                    espereEnviar("Aguarde...",false);
                }
            }
            
              new Ajax.Request("ExpersControlador?acao=pagamentoImediatoSaldo&ciot="+ciot+"&ciotCodVerificador="
                    +ciotCodVerificador+"&idFilial="+idFilial+"&idDespesa="+idDespesa+"&fpagPgto="+fpagPgto
                    +"&valorPagto="+valorPagto+"&valorAvaria="+valorAvaria+"&idcartaFrete="+idcartaFrete
                    + "&saldo_autorizado="+saldo_autorizado+"&vencimento_saldo="+vencimento_saldo
                    + "&saldo_autorizado_justifica="+saldo_autorizado_justifica+"&valorAcrescimo="+valorAcrescimo
                    + "&valorAcrescimo="+valorAcrescimo+ "&agente_pagador="+agente+"&id="+idx+"&valorLiquido="+valorLiquido
                    + "&idDuplDespesa="+idDuplDespesa+"&contaNDD="+contaNDD+"&historicoDespesa="+historicoDespesa,{method:'post',onSuccess:expers,onError: expers});      
        }else{
            espereEnviar("Aguarde...",false);
            alert("Atenção: Favor confirmar contrato com a ExpeRS!");
            return false;
        }       
    
    }else if(<%=nivelConfirmarPgtoNDD == 4%> && <%=filialConfirmarPgtoNDD == true%> && tipoPgto == 'Saldo' && stUtilizacaoCFe == 'G'  && fpagPgto==18){
        espereEnviar("Aguarde...",true);
        if (ciot != 0 && ciotCodVerificador != 0) {
         
            function pagbem(transport){
                //alert("oi");
                //   location.reload();
                var textoresposta = transport.responseText;
                if (textoresposta == "-1") {
                    alert('Atenção: Houve algum problema ao requistar a confirmação do pagamento de saldo pela PagBem, favor tente novamente.');
                    espereEnviar("Aguarde...",false);
                    return false;
                }else{
                    var retornoQuitacaoSaldo = jQuery.parseJSON(textoresposta).retornoQuitacaoSaldo;
                    if (retornoQuitacaoSaldo.isSucesso == true) {
                        alert("Pagamento realizado com sucesso!");
                      //  location.reload();
                    }else {
                        var mensagem = "";
                        var listErros = retornoQuitacaoSaldo.erros[0]["br.com.gwsistemas.gwpagbem.excecao.Erros"];
                            var length = (listErros != undefined && listErros.length != undefined ? listErros.length : 1);
                            
                            var mensagens = " Atenção! Mensagem do servidor PagBem: \n";
                            for (var i = 0; i < length; i++) {
                                if (length > 1) {
                                    mensagens += listErros[i].codigo+ "-"+listErros[i].mensagem;    
                                    mensagens +="\n";
                                } else {                                
                                    mensagens += listErros[0].codigo+ "-"+listErros[0].mensagem;
                                }                                
                            } 
                        alert(mensagens);   
                //alert("Atenção! Mensagem do servidor PagBem: "+retornoQuitacaoSaldo.localExcecao.localCodigo+"-"+retornoQuitacaoSaldo.localExcecao.localMensagem); //localCodigo
                         //location.reload();
                    }
                    location.reload();
                    espereEnviar("Aguarde...",false);
                }
            }
     
            new Ajax.Request("PagBemControlador?acao=pagamentoImediatoSaldo&ciot="+ciot+"&ciotCodVerificador="
                    +ciotCodVerificador+"&idFilial="+idFilial+"&idDespesa="+idDespesa+"&fpagPgto="+fpagPgto+"&valorPagto="+valorPagto
            + "&idDuplDespesa="+idDuplDespesa+"&contaNDD="+contaNDD+"&historicoDespesa="+historicoDespesa+"&idcartaFrete="+idcartaFrete,{method:'post',onSuccess:pagbem,onError: pagbem});
        }else{
            espereEnviar("Aguarde...",false);
            alert("Atenção: Favor confirmar contrato com a PagBem!");
            return false;
        }
        
     }else if(<%=nivelConfirmarPgtoNDD == 4%>  && tipoPgto == 'Saldo' && stUtilizacaoCFe == 'R'  && fpagPgto==12){
       // autorizarSaldo(idx)
        espereEnviar("Aguarde...",true);
           
         if (ciot != 0) {
            
            function repom(transport){
                let textoresposta = transport.responseText;
                if (textoresposta == "-1") {
                    alert('Atenção: Houve algum problema ao requisitar a quitação de contrato na Repom, favor tente novamente.');
                    espereEnviar("Aguarde...",false);
                    return false;
                }else{           
                    
                    try{
                        let retorno = jQuery.parseJSON(textoresposta);
                        
                    if(retorno.retornoQuitacaoSaldo.reciboQuitacao){
                        alert("Baixa de Saldo realizada com sucesso!");
                        location.reload();
                        espereEnviar("Aguarde...",false);
                       
                        return false;
                    }else{
                        let retornoErro = retorno.retornoQuitacaoSaldo.retornoErro;
                        let erro = retornoErro.erros[0].erros[0].erro[0].erro;
                          
                            let mensagens = " Atenção! Mensagem do servidor Repom: \n";
                            erro.forEach(function(er) {
                                mensagens += er.erroCodigo+ "-"+er.erroDescricao;    
                                mensagens +="\n";
                            });
                            for (let i = 0; i < length; i++) {
                                
                            } 
                            alert(mensagens);
                        location.reload();
                        espereEnviar("Aguarde...",false);
                    }
                    //textoresposta: {"retornoQuitacaoSaldo":{"reciboQuitacao":"",
                    //"retornoErro":{"erros":
                    //[{"@class":"list","br.com.gwsistemas.cfe.repom.bean.ErrosRepom":{"erro":[{"br.com.gwsistemas.cfe.repom.bean.ErroRepom":
                    //{"erroCodigo":605,"erroDescricao":"Express: O contrato nao esta em transito ou pendente"}}]}}]}}}
                        
                    
                    //alert(textoresposta); 
                    }catch(e){
                        
                        alert(textoresposta);
                        location.reload();
                        espereEnviar("Aguarde...",false);
                    }
                    
                }
            }
     
            if (vencimento_saldo === "") {
                alert("Preencha a data de vencimento!");
                espereEnviar("Aguarde...",false);
                return null;
            }
     
           new Ajax.Request("RepomControlador?acao=pagamentoImediatoSaldo&ciot="+ciot+"&ciotCodVerificador="+ciotCodVerificador
            + "&idFilial="+idFilial+"&idDespesa="+idDespesa+"&fpagPgto="+fpagPgto+"&valorAvaria="+valorAvaria+"&valorPagto="+valorPagto
            + "&idDuplDespesa="+idDuplDespesa+"&contaNDD="+contaNDD+"&historicoDespesa="+historicoDespesa+"&idcartaFrete="+idcartaFrete
            + "&saldo_autorizado="+saldo_autorizado+"&vencimento_saldo="+vencimento_saldo
            + "&saldo_autorizado_justifica="+saldo_autorizado_justifica+"&valorAcrescimo="+valorAcrescimo
            + "&valorAcrescimo="+valorAcrescimo+ "&agente_pagador="+agente+"&id="+idx+"&valorLiquido="+valorLiquido
        ,{method:'post',onSuccess:repom,onError: repom});
        }else{
            alert("Contrato não possui CIOT!"); espereEnviar("Aguarde...",false);}
        
    } else if(<%=nivelConfirmarPgtoNDD == 4%> && tipoPgto == 'Saldo' && stUtilizacaoCFe == 'A' && fpagPgto == 20) {
        espereEnviar("Aguarde...",true);
           
         if (ciot != 0 && ciotCodVerificador != 0) {
            function target(transport){
                var textoresposta = transport.responseText;

                if (textoresposta == "-1") {
                    alert('Atenção: Houve algum problema ao requisitar a quitação de contrato na Target, favor tente novamente.');
                    espereEnviar("Aguarde...", false);

                    return false;
                } else {           
                    try {
                        var retorno = jQuery.parseJSON(textoresposta).finalizacaoOperacaoTransporte;

                        if (retorno.erro != undefined) {
                            alert(retorno.erro.mensagemErro);
                            espereEnviar("Aguarde...", false);

                            return false;
                        } else {
                            alert(retorno.mensagemRetorno);
                            
                            espereEnviar("Aguarde...", false);
                        }
                    } catch(e) {
                        alert(textoresposta);
                        location.reload();
                        espereEnviar("Aguarde...",false);
                    }
                }
            }

            new Ajax.Request("TargetControlador?acao=pagamentoImediatoSaldo&ciot="+ciot+"&ciotCodVerificador="+ciotCodVerificador
                + "&idFilial="+idFilial+"&idDespesa="+idDespesa+"&fpagPgto="+fpagPgto+"&valorAvaria="+valorAvaria+"&valorPagto="+valorPagto
                + "&idDuplDespesa="+idDuplDespesa+"&contaNDD="+contaNDD+"&historicoDespesa="+historicoDespesa+"&idcartaFrete="+idcartaFrete
                + "&saldo_autorizado="+saldo_autorizado+"&vencimento_saldo="+vencimento_saldo
                + "&saldo_autorizado_justifica="+saldo_autorizado_justifica+"&valorAcrescimo="+valorAcrescimo
                + "&valorAcrescimo="+valorAcrescimo+ "&agente_pagador="+agente+"&id="+idx+"&valorLiquido="+valorLiquido
        , { method: 'post', onSuccess: target, onError: target });
        } else {
            alert("Contrato não possui CIOT!"); espereEnviar("Aguarde...",false);
        }
    } else {
       
          tryRequestToServer(function(){window.open("./bxcontaspagar?acao=consultar&"+
            "idfornecedor="+$('idproprietario').value+"&"+
   		    "dtinicial="+dataAtual+"&dtfinal="+dataAtual+"&baixado=false"+"&idfilial="+idFilial+
  		    "&mostrarSaldo=true"+"&nf="+notaFiscal+"&valor1=0.00&valor2=0.00&tipoData=dtvenc", "Despesa" , "top=8,resizable=yes,status=1,scrollbars=1")});
        
    }

}
</script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>Webtrans - Consulta saldo contrato de frete</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<script src="${homePath}/script/funcoesTelaConsultaSaldoCarta.js?v=${random.nextInt()}"></script>
</head>

<body>
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="idmotorista" id="idmotorista" value="<%=(request.getParameter("idmotorista") != null?request.getParameter("idmotorista"):"0")%>">
  <input type="hidden" name="idproprietario" id="idproprietario" value="<%=(request.getParameter("idproprietario") != null?request.getParameter("idproprietario"):"0")%>">
  <input type="hidden" id="idveiculo" value="<%=(request.getParameter("idveiculo") != null?request.getParameter("idveiculo"):"0")%>">
  <input type="hidden" name="agente" id="agente" value="" size="10" class="inputtexto" /> 
  <input type="hidden" name="idagente" id="idagente" value="0" size="10" class="inputtexto" /> 
  <input type="hidden" name="cnpjContratantePamcard" id="cnpjContratantePamcard" value="<%=cnpjContratantePamcard%>" /> 
                              
</div>
<table width="70%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Consultar saldo de contrato de frete </b><b>
    </b></td>
  </tr>
</table>

<br>

<table width="100%" border="0" class="bordaFina" align="center">
  <tr class="tabela">
    <td height="18" colspan="6"> <div align="center">Filtros </div>
      <div align="center"></div></td>
  </tr>
  <tr>
    <td width="9%" class="TextoCampos">Per&iacute;odo entre: </td>
    <td width="15%" class="CelulaZebra2"><strong>
      <input name="dtinicial" type="text" id="dtinicial" value="<%=(request.getParameter("dtinicial")==null?Apoio.getDataAtual():request.getParameter("dtinicial"))%>" size="11" maxlength="10"
      		 onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
    </strong>e<strong>
    <input name="dtfinal" type="text" id="dtfinal" value="<%=(request.getParameter("dtfinal")==null?Apoio.getDataAtual():request.getParameter("dtfinal"))%>" size="11" maxlength="10"
    		onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
    </strong></td>
    <td width="13%" class="TextoCampos">Apenas o CTRC:</td>
    <td width="15%" class="CelulaZebra2"><span class="Celulazebra2"><strong>
      <input name="ctrc" type="text" id="ctrc" class="fieldMin" value="<%=(request.getParameter("ctrc") != null?request.getParameter("ctrc"):"")%>" size="10" maxlength="80">
    </strong>
    </span></td>
    <td class="TextoCampos">Apenas a Filial:</td>
    <td class="CelulaZebra2">
        <select id="idConsultarFiliais" name="idConsultarFiliais" class="fieldMin">
           <% BeanFilial consultarFiliais = new BeanFilial();
            ResultSet rsConsultarFiliais = consultarFiliais.all(Apoio.getUsuario(request).getConexao());
            %>
            
            <option value="0" selected>TODAS AS FILIAIS</option>
            
            <% while (rsConsultarFiliais.next()){
                
            
            %>
            <option value="<%= rsConsultarFiliais.getString("idfilial") %>" <%= request.getParameter("idConsultarFiliais") != null && request.getParameter("idConsultarFiliais").equals(rsConsultarFiliais.getString("idfilial")) ? "selected" : ""%> >
               APENAS A <%= rsConsultarFiliais.getString("abreviatura") %>
            <% } %>
            </option>
        </select>
    </td>
   
  </tr>
  <tr>
    <td class="TextoCampos">Apenas o Motorista:</td>
    <td class="CelulaZebra2"><strong>
      <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" value="<%=(request.getParameter("motor_nome") != null?request.getParameter("motor_nome"):"")%>" size="30" maxlength="80" readonly="true">
      <input name="localiza_rem" type="button" class="inputBotaoMin" id="localiza_rem" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:$('motor_nome').value = '';javascript:$('idmotorista').value = '0';">
      </strong></td>
    <td class="TextoCampos">Apenas o Propriet&aacute;rio:</td>
    <td class="CelulaZebra2"><strong>
      <input name="nome" type="text" id="nome" class="inputReadOnly8pt" value="<%=(request.getParameter("nome") != null?request.getParameter("nome"):"")%>" size="30" maxlength="80" readonly="true">
      <input name="localiza_dest" type="button" class="inputBotaoMin" id="localiza_dest" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=1&paramaux=1','Proprietario')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar proprietário" onClick="javascript:$('nome').value = '';javascript:$('idproprietario').value = '0';">
    </strong></td>
    <td width="11%" class="TextoCampos">Apenas o ve&iacute;culo:</td>
    <td width="14%" class="CelulaZebra2"><input name="vei_placa" type="text" class="inputReadOnly8pt" id="vei_placa" value="<%=(request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "")%>" size="10" readonly="true" class="inputReadOnly8pt">
      <input name="localiza_veiculo" type="button" class="inputBotaoMin" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ve&iacute;culo" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';"></td>
  </tr>
  <tr>
    <td class="TextoCampos">Apenas o Cliente:</td>
    <td class="CelulaZebra2"><strong>
      <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly8pt" size="30" maxlength="80" readonly="true" value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>">
      <input name="localiza_clifor" type="button" class="inputBotaoMin" id="localiza_clifor" value="..." onClick="javascript:localizacliente();">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparclifor();">
      <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0")%>">
      </strong>
    </td>
    <td class="TextoCampos" colspan="2">
        <div align="center">
            <input name="chk_saldo" type="checkbox" id="chk_saldo" <%=(request.getParameter("chk_saldo") != null && Apoio.parseBoolean(request.getParameter("chk_saldo")) ? "checked" : "")%>>
            Mostrar apenas contratos com saldo em aberto
        </div>
    </td>
    <td class="TextoCampos">Apenas o CF-e: </td>
    <td class="CelulaZebra2"><strong>
            <input name="idcfe" type="text" id="idcfe" class="inputTexto" size="15" maxlength="15" value="<%=(request.getParameter("idcfe") != null ? request.getParameter("idcfe") : "")%>">
        </strong></td>
  </tr>
  <tr>
      <td class="TextoCampos">Apenas saldos com Status:</td>
      <td class="CelulaZebra2">
          <select id="apenasSaldosAutorizados" name="apenasSaldosAutorizados" class="fieldMin">
              <option value=""  <%= (request.getParameter("apenasSaldosAutorizados") != null && request.getParameter("apenasSaldosAutorizados").equals("") ? "selected" : "")%>>Ambos</option>
              <option value="t" <%= (request.getParameter("apenasSaldosAutorizados") != null && request.getParameter("apenasSaldosAutorizados").equals("t") ? "selected" : "")%> >Autorizado</option>
              <option value="f" <%= (request.getParameter("apenasSaldosAutorizados") != null && request.getParameter("apenasSaldosAutorizados").equals("f") ? "selected" : "")%>>Não Autorizado</option>
          </select>
      </td>
      <td class="textoCampos">
          Apenas a NF do cliente:
      </td>
      <td colspan="3" class="CelulaZebra2">
          <input type="text" id="notaFiscalCliente" name="notaFiscalCliente" class="fieldMin" size="10" maxlength="10" value="<%=(request.getParameter("notaFiscalCliente") != null?request.getParameter("notaFiscalCliente"):"")%>">
      </td>
  </tr>
  <tr>
      <td height="22" colspan="6" class="TextoCampos"><div align="center">
        <input name="visualizar" type="button" class="botoes"  id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
      </div></td>
  </tr>
</table>
<table width="100%" border="0" class="bordaFina">
  <tr class="tabela">
    <td width="4%"><strong>Nº</strong></td>
    <td width="5%"><strong>CTRC</strong></td>
    <td width="14%"><strong>Destino</strong></td>
    <td width="6%"><strong>Filial/Data</strong></td>
    <td width="14%"><strong>Motorista</strong></td>
    <td width="6%"><strong>Veículo(s)</strong></td>
    <td width="18%"><strong>Proprietário</strong></td>
    <td width="7%"><div align="right"><strong>Valor</strong></div></td>
    <td width="7%"><div align="right"><strong>Adiant.</strong></div></td>
    <td width="7%"><div align="right"><strong>Saldo</strong></div></td>
    <td width="10%"><div align="right"><strong>Ocorrência</strong></div></td>
    <td width="2%"></td>
  </tr>
   <% //variaveis da paginacao
      float adiant_aberto = 0;
      float adiant_pago = 0;
      float saldo_aberto = 0;
      float saldo_pago = 0;
      int linha = 0;
      // se conseguiu consultar
      if ( (acao.equals("consultar")) && (conCf.ConsultaSaldo())){
          //Apenas as duplicatadas agora
          ResultSet rs = conCf.getResultado();
   	      while (rs.next()){
%>            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" ><td><font size="1">
<%              if (nivelUserCarta > 0){%>
                   <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCarta(<%=rs.getString("idcartafrete")%>,'<%=rs.getString("st_utilizacao_cfe")%>');});">
	               <%=rs.getString("idcartafrete")%></div>
<%              }else{%>
	               <%=rs.getString("idcartafrete")%>
<%              }%>
	          </td>
              <td>
                  <div align="right" class="linkEditar" onClick="javascript:tryRequestToServer(function(){viewCtrc(<%=rs.getString("idcartafrete")%>);});">
			         <%=rs.getString("ctrc")%>
			      </div>
			  </td>
              <td><%=rs.getString("ctrc_destino")%></td>
              <td><%=rs.getString("abreviatura")%><br><%=formatador.format(rs.getDate("data"))%></td>
              <td><%=rs.getString("motorista")%></td>
              <td><%=rs.getString("veiculo")+ (rs.getString("carreta").equals("") ? "" : "<br> Carr:"+rs.getString("carreta"))%></td>
              <td><%=rs.getString("proprietario")%></td>
              <td><b><div align="right"><%=new DecimalFormat("#,##0.00").format(rs.getFloat("valor_contrato"))%></div></b></td>
              <td>
<%                if (nivelUserCarta > 0){%>
                      <div align="right" class="linkEditar" onClick="javascript:tryRequestToServer(function(){liberaSaldo('<%=rs.getString("idcartafrete")%>');});">
                      <font color="<%=(rs.getDouble("adiantamento_pago") >= rs.getDouble("adiantamento") ? "#000000" : "#CC3333") %>">
	                  <%=new DecimalFormat("#,##0.00").format(rs.getFloat("adiantamento"))%></font></div>
<%                }else{%>
                      <div align="right">
                      <font color="<%=(rs.getDouble("adiantamento_pago") >= rs.getDouble("adiantamento") ? "#000000" : "#CC3333") %>">
                      <%=new DecimalFormat("#,##0.00").format(rs.getFloat("adiantamento"))%>
                      </font></div>
<%                }%>
              </td>
              <td>
<%                if (nivelUserCarta > 0){%>
                      <div align="right" class="linkEditar" onClick="javascript:tryRequestToServer(function(){liberaSaldo('<%=rs.getString("idcartafrete")%>');});">
                      <font color="<%=(rs.getDouble("saldo_pago") >= rs.getDouble("saldo") ? "#000000" : "#CC3333") %>">
	                  <%=new DecimalFormat("#,##0.00").format(rs.getFloat("saldo"))%></font></div>
<%                }else{%>
                      <div align="right">
                      <font color="<%=(rs.getDouble("saldo_pago") >= rs.getDouble("saldo") ? "#000000" : "#CC3333") %>">
                      <%=new DecimalFormat("#,##0.00").format(rs.getFloat("saldo"))%>
                      </font>
                      </div>
<%                }%>                
              </td>
              <td>
                  <div align="center">
                      <input name="ocorrencia_id_<%=linha%>" type="hidden" id="ocorrencia_id_<%=linha%>" value="<%=rs.getInt("ocorrencia_id")%>">
                      <input name="is_motorista_ocorrencia_<%=linha%>" type="hidden" id="is_motorista_ocorrencia_<%=linha%>" value="false">
                      <input name="is_fornecedor_ocorrencia_<%=linha%>" type="hidden" id="is_fornecedor_ocorrencia_<%=linha%>" value="false">
                      <input name="codigo_ocorrencia_<%=linha%>" type="text" id="codigo_ocorrencia_<%=linha%>" value="<%=(rs.getString("codigo_ocorrencia") != null ? rs.getString("codigo_ocorrencia") : "")%>" class="inputReadOnly8pt" size="4" readonly="true" >
                      <img src="img/add.gif" border="0" align="absbottom" class="imagemLink" title="Pesquisar ocorrência" onClick="localizaOcorrencia(<%=linha%>);">
                      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar ocorrência" onClick="apagaOcorrencia(<%=linha%>);">
                      
                      <input type="hidden" id="proprietario_id_<%=linha%>" name="proprietario_id_<%=linha%>" value="<%= rs.getInt("idproprietario") %>">
                      <input type="hidden" id="motorista_id_<%=linha%>" name="motorista_id_<%=linha%>" value="<%= rs.getInt("idmotorista") %>">
                  </div>
              </td>
              <td>
                  <div align="center">
                      <img src="img/save.gif" border="0" align="absbottom" class="imagemLink" title="Salvar ocorrência" onClick="salvar('<%=rs.getString("idcartafrete")%>',<%=linha%>);">
                  </div>
              </td>
	          </tr>
	          <tr style="display:none" id="cf_<%=rs.getString("idcartafrete")%>">
	          	<td rowspan="1" class='CelulaZebra1'></td>
	          	<td rowspan="1" colspan="11">--</td>
	          </tr>
	          <tr style="display:none" id="cf2_<%=rs.getString("idcartafrete")%>">
	          	<td rowspan="1" class='CelulaZebra1'></td>
	          	<td rowspan="1" colspan="11">--</td>
	          </tr>
<%            linha++;
              //totais
            	 adiant_pago += rs.getFloat("adiantamento_pago");
             	 adiant_aberto += rs.getFloat("adiantamento_aberto");
             	 saldo_pago += rs.getFloat("saldo_pago");
              	 saldo_aberto += rs.getFloat("saldo_aberto");
          }
   	      rs.close();
   	  }%>
</table>
<br>
<table width="37%"  border="0" class="bordaFina">
  <tr class="tabela">
    <td colspan="4"><div align="center">Totais</div></td>
  </tr>
  <tr class="celula">
    <td width="34%" class="celula"><div align="center"></div></td>
    <td width="22%"><div align="right"><strong>Em aberto </strong></div></td>
    <td width="22%"><div align="right"><strong>Pago</strong></div></td>
    <td width="22%"><div align="right"><strong>Total</strong></div></td>
  </tr>
  <tr>
    <td class="celula"><div align="right"><strong>Adiantamento</strong></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(adiant_aberto)%></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(adiant_pago)%></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(adiant_aberto + adiant_pago)%></div></td>
  </tr>
  <tr>
    <td class="celula"><div align="right"><strong>Saldo</strong></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(saldo_aberto)%></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(saldo_pago)%></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(saldo_aberto + saldo_pago)%></div></td>
  </tr>
  <tr>
    <td class="celula"><div align="right"><strong>Contratos de Fretes </strong></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(adiant_aberto + saldo_aberto)%></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(adiant_pago + saldo_pago)%></div></td>
    <td class="CelulaZebra2"><div align="right"><%=new DecimalFormat("#,##0.00").format(adiant_aberto + saldo_aberto + adiant_pago + saldo_pago)%></div></td>
  </tr>
</table>
<input type="hidden" id="indexAux" name="indexAux" value="">
<input type="hidden" id="ocorrencia_id" name="ocorrencia_id" value="">
<input type="hidden" id="descricao_ocorrencia" name="descricao_ocorrencia" value="">
<input type="hidden" id="ocorrencia" name="ocorrencia" value="">
<input type="hidden" id="is_fornecedor_ocorrencia" name="is_fornecedor_ocorrencia" value="false">
<input type="hidden" id="is_motorista_ocorrencia" name="is_motorista_ocorrencia" value="false">
</body>
</html>
