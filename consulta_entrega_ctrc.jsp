<%@page import="nucleo.BeanLocaliza"%>
<%@page import="br.com.gwsistemas.protocolo.Protocolo"%>
<%@page import="java.sql.Connection"%>
<%@page import="nucleo.Conexao"%>
<%@page import="br.com.gwsistemas.protocolo.ProtocoloDAO"%>
<%@page import="filial.BeanFilial"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.*,
         conhecimento.duplicata.fatura.*,
         conhecimento.manifesto.BeanConsultaManifesto,
         conhecimento.romaneio.BeanConsultaRomaneio,
         cliente.BeanCadCliente,
         conhecimento.ocorrencia.*,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<% 
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
   
   int permissaoProtocolo = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadprotocolo") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  SimpleDateFormat formatadorHora = new SimpleDateFormat("HH:mm");
  /* Pegando valores do usuario contido na sessao */
  
  boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
  boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
  boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
%>  

<jsp:useBean id="conCtrc" class="conhecimento.BeanConsultaConhecimento" />
<jsp:useBean id="cfg" class="nucleo.BeanConfiguracao" />
<jsp:useBean id="conColeta" class="conhecimento.coleta.BeanConsultaColeta" />

<%

cfg.setConexao(Apoio.getUsuario(request).getConexao());
cfg.CarregaConfig();

            if (acao.equals("consultar")) {
                conCtrc.setConexao(Apoio.getUsuario(request).getConexao());
                conCtrc.setDtEmissao1(Apoio.paraDate(request.getParameter("dtinicial")));
                conCtrc.setDtEmissao2(Apoio.paraDate(request.getParameter("dtfinal")));
                conCtrc.setLimiteResultados(Integer.parseInt(request.getParameter("limite")));
                conCtrc.setSerieNF((request.getParameter("serie_nf") == null ? "" : request.getParameter("serie_nf") ));
                conCtrc.setSerie((request.getParameter("serie") == null ? "" : request.getParameter("serie")));
                conCtrc.setIdFilialConhecimento(Apoio.parseInt(request.getParameter("filialId")));
            } else if (acao.equals("carregarOcorrencia")) {
                String resultado = "";
                int idxOco = 1;

                BeanConsultaConhecimento conCt = new BeanConsultaConhecimento();
                conCt.setConexao(Apoio.getUsuario(request).getConexao());

                //orcamento
                if (conCt.consultarOcorrencias(Integer.parseInt(request.getParameter("ctrcId")))){
                    resultado =
                     "<table width='100%' border='0' class='bordaFina'>" +
                        "<tr class='tabela' >" +
                            "<td width='24%'>Ocorrência</td>" +
                            "<td width='15%'>Ocorrência em</td>" +
                            "<td width='21%'>Observação ocorrência</td>" +
                            "<td width='18%'>Resolvido em</td>" +
                            "<td width='23%'>Observação resolução</td>" +
                        "</tr>";                
                    ResultSet rsOco = conCt.getResultado();
                    boolean retornaResultSetOco = false;

                    while (rsOco.next()) {
                        retornaResultSetOco = true;

                        resultado += 
                                "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td>"+rsOco.getString("codigo_ocorrencia") + "-" + rsOco.getString("descricao_ocorrencia")+"</td>"+
                                "<td>"+
                                (rsOco.getDate("ocorrencia_em") == null ? "" : formatador.format(rsOco.getDate("ocorrencia_em")) +" às ") +
                                (rsOco.getDate("ocorrencia_as") == null ? "" : formatadorHora.format(rsOco.getTime("ocorrencia_as")))+
                                "</td>"+
                                "<td>"+rsOco.getString("observacao_ocorrencia")+"</td>"+
                                "<td>"+
                                "<input name='isResolvido_Ct"+rsOco.getString("sale_id")+"idx"+idxOco+"' id='isResolvido_Ct"+rsOco.getString("sale_id")+"idx"+idxOco+"' type='checkbox' disabled " +
                                    "value='1' "+(rsOco.getString("is_resolvido").equals("t")? "checked" : "")+">";
                        if(rsOco.getString("is_resolvido").equals("t")){
                                resultado +=(rsOco.getDate("resolucao_em") == null ? "" : formatador.format(rsOco.getDate("resolucao_em"))+" às ") +
                                            (rsOco.getDate("resolucao_as") == null ? "" : formatadorHora.format(rsOco.getTime("resolucao_as")));
                        }                                
                        resultado +="</td>"+
                                "<td>"+rsOco.getString("observacao_resolucao")+"</td>";
                        resultado +="</tr>";

                        idxOco ++;
                    }
                    
                    if(!retornaResultSetOco){
                        resultado +=
                                "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td colspan='5'>Não há ocorrências para este CT-e</td>";
                        resultado +="</tr>";
                    }
                }

                BeanConsultaManifesto conMan = new BeanConsultaManifesto();
                conMan.setConexao(Apoio.getUsuario(request).getConexao());

                if (conMan.consultarEntregaManifesto(request.getParameter("ctrcId"))){
                    // ---- ----- ---- --- --- manifesto ---- --- -  -  --- -- --
                    resultado +=
                     "<table width='100%' border='0' class='bordaFina'>" +
                        "<tr class='tabela' >" +
                            "<td width='18%'>Manifesto</td>" +
                            "<td width='15%'>Saída</td>" +
                            "<td width='15%'>Previsão Chegada</td>" +
                            "<td width='27%'>Motorista</td>" +
                            "<td width='15%'>Veículo / Carreta</td>" +
                            "<td width='10%'>Contrato de Frete</td>" +
                        "</tr>";
                    ResultSet rsMan = conMan.getResultado();
                    boolean retornaResultSetMan = false;
                    boolean isCiot = false;

                    while (rsMan.next()) {
                        retornaResultSetMan = true;
                        isCiot = !rsMan.getString("st_utilizacao_cfe").equals("N");
                        resultado +=
                                "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td>" +
                                   "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verManifesto(" + rsMan.getInt("idmanifesto")+");});'>"+
                                        rsMan.getString("nmanifesto") +
                                   "</div>" +
                                "</td>"+
                                "<td>"+
                                (rsMan.getDate("dtsaida") == null ? "" : formatador.format(rsMan.getDate("dtsaida")) + " às ") +
                                (rsMan.getDate("hrsaida") == null ? "" : formatadorHora.format(rsMan.getTime("hrsaida")))+
                                "</td>"+
                                "<td>"+
                                (rsMan.getDate("dtprevista") == null ? "" : formatador.format(rsMan.getDate("dtprevista"))+ " às ") +
                                (rsMan.getDate("hrprevista") == null ? "" : formatadorHora.format(rsMan.getTime("hrprevista")))+
                                "</td>"+
                                "<td>"+rsMan.getString("motorista")+"</td>"+
                                "<td>"+rsMan.getString("veiculo")+ " / " +
                                       rsMan.getString("carreta") +
                                "</td>"+
                                "<td>"+
                                    "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verCartaFrete(" + rsMan.getString("idcartafrete") + ", "+isCiot+" );});'>"+
                                        rsMan.getString("idcartafrete")+
                                    "</div>" +
                                "</td>";
                        resultado +="</tr>";
                    }

                    if(!retornaResultSetMan){
                        resultado +=
                                "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td colspan='6'>Não há manifestos para este CT-e</td>";
                        resultado +="</tr>";
                    }

                    resultado += "</table>";
                }
                
                // -- Traz romaneio e parcela --
                BeanConsultaRomaneio conRom = new BeanConsultaRomaneio();
                conRom.setConexao(Apoio.getUsuario(request).getConexao());

                    resultado +=
                     "<table width='100%' border='0' class='bordaFina'>" +
                        "<tr>" +
                            "<td width='50%'>" +
                                "<table width='100%' height='100%' border='0' class='bordaFina'>"+
                                         "<tr class='tabela' >" +
                                             "<td width='15%'>" +
                                                    "Romaneio " +
                                             "</td>" +
                                             "<td width='18%'>" +
                                                 "Data " +
                                             "</td>" +
                                             "<td width='49%'>" +
                                                "Motorista " +
                                             "</td>" +
                                             "<td width='18%'>" +
                                                 "Veículo " +
                                             "</td>" +
                                         "</tr>";
                                  // ---- ----- ---- --- --- Romaneio ---- --- -  -
                                  if (conRom.consultarEntregaRomaneio(request.getParameter("ctrcId"))){
                                      ResultSet rsRom = conRom.getResultado();
                                      boolean temRomaneio = false;
                                      while (rsRom.next()){
                                         temRomaneio = true;
                                         resultado +=
                                         "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">" +
                                             "<td>" +
                                                "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verRomaneio(" + rsRom.getInt("idromaneio")+");});'>"+
                                                    rsRom.getString("numromaneio") +
                                                "</div>" +
                                             "</td>" +
                                             "<td>" +
                                                (rsRom.getDate("dtromaneio") == null ? "" : formatador.format(rsRom.getDate("dtromaneio"))) +
                                             "</td>" +
                                             "<td>" +
                                                rsRom.getString("motorista") +
                                             "</td>" +
                                             "<td>" +
                                                rsRom.getString("veiculo") +
                                             "</td>" +
                                         "</tr>";
                                      }

                                      if (!temRomaneio){
                                          resultado +=
                                          "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">" +
                                             "<td colspan='4'>Não há romaneio para este CT-e</td>"+
                                          "</tr>";
                                      }
                                  }
                                resultado +=
                                "</table>" +
                            "</td>" +
                            "<td width='50%'>" +
                                "<table width='100%' height='100%' border='0' class='bordaFina'>"+
                                    "<tr class='tabela'>" +
                                      "<td width='25%'>" +
                                        "Vencimento" +
                                      "</td>"+
                                      "<td width='25%'>" +
                                        "Número fatura" +
                                      "</td>"+
                                      "<td width='25%'>" +
                                        "Valor" +
                                      "</td>"+
                                      "<td width='25%'>" +
                                        "Status" +
                                      "</td>"+
                                    "</tr>";
                
                // -- -- -- --- -- ---- Parcelas -- --- -- -- - -
                BeanConsultaFatura conFatura = new BeanConsultaFatura();
                conFatura.setConexao(Apoio.getUsuario(request).getConexao());

                if (conFatura.consultarEntregaFatura(request.getParameter("ctrcId"))){            
                                
                    ResultSet rsParcela = conFatura.getResultado();
                    boolean retornaResultSetParcela = false;

                    while (rsParcela.next()) {
                        retornaResultSetParcela = true;

                                    resultado +=
                                    "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">"+
                                        "<td>" +
                                           (rsParcela.getDate("vence_em") == null ? "" : formatador.format(rsParcela.getDate("vence_em"))) +
                                        "</td>"+
                                        "<td>"+
                                            rsParcela.getString("numero") +
                                        "</td>"+
                                        "<td>"+
                                            (new DecimalFormat("#,##0.00").format(rsParcela.getDouble("valor"))) +
                                        "</td>"+
                                        "<td>"+
                                            (rsParcela.getBoolean("is_baixado")?"Baixado":"Não baixado")+
                                        "</td>"+
                                    "</tr>";
                    }

                    if (!retornaResultSetParcela){
                                    resultado +=
                                    "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">"+
                                        "<td colspan='4'>" +
                                           "Não existe parcela para este CT-e"+
                                        "</td>"+
                                    "</tr>";
                    }
                }
                                resultado +=
                                "</table>" +
                            "</td>" +
                        "</tr>";
                                
                                
                // -- Trazer o protocolo --
                Connection con = null;
                con = Conexao.getConnection();
                ProtocoloDAO protoDAO = new ProtocoloDAO(con);
                Protocolo pro = new Protocolo();
                pro = protoDAO.consultarProtocolo(Apoio.parseInt(request.getParameter("ctrcId")));
                    resultado +=
                     "<table width='100%' border='0' class='bordaFina'>" +
                        "<tr class='tabela' >" +
                            "<td width='18%'>Protocolo</td>" +
                            "<td width='15%'>Data</td>" +
                            "<td width='13%'>Arquivado</td>" +
                            "<td width='12%'></td>" +
                            "<td width='12%'></td>" +
                            "<td width='15%'></td>" +
                        "</tr>";
                if (pro != null){
                    boolean protocoloArquivado = (pro.getArquivamentoProtocoloId() != 0 ? true : false);
                    String arquivado = "";
                    String link = "";
                    if (permissaoProtocolo > 0){
                        link = "<div class='linkEditar' onClick='javascript:tryRequestToServer(function(){verProtocolo(" + pro.getId() +");});'>";
                    }else{
                        link = "";
                    }
                        if (protocoloArquivado) {
                            arquivado = "Sim";
                        }else{
                            arquivado = "Não";
                        }
                        resultado +=
                                "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td>" + link +
                                       pro.getNumero() +
                                   "</div>" +
                                "</td>"+
                                "<td>"+
                                pro.getData()+
                                "</td>"+
                                "<td>"+arquivado+"</td>"+
                                "<td></td>"+
                                "<td></td>"+
                                "<td></div>" +
                                "</td>";
                        resultado +="</tr>";
//

                    resultado += "</table>";
                }
                    if(pro == null){
                        resultado +=
                                "<tr class="+((Integer.parseInt(request.getParameter("zebra")) % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")+">";
                        resultado +=
                                "<td colspan='6'>Não há protocolo para este CT-e</td>";
                        resultado +="</tr>";
                    }
                
                response.getWriter().append(resultado);
                response.getWriter().close();
                con.close();
            } else if (acao.equals("carregarNF")) {
                DecimalFormat fmtMoeda = new DecimalFormat("#,##0.00");
                DecimalFormat fmtMetro = new DecimalFormat("#,##0.000");
                int idctrc = Integer.parseInt(request.getParameter("ctrcId"));
                String resultado = "<table width='100%' border='0' class='bordaFina'>"
                        + "<tr class='tabela'>"
                        + "<td width=\"5%\"><font size='1'>Número</font></td>"
                        + "<td width=\"3%\"><font size='1'>Sér.</font></td>"
                        + "<td width=\"8%\"><font size='1'>Emissão</font></td>"
                        + "<td width=\"7%\" align='right'><font size='1'>Valor</font></td>"
                        + "<td width=\"7%\" align='right'><font size='1'>Peso</font></td>"
                        + "<td width=\"5%\" align='right'><font size='1'>Vols</font></td>"
                        + "<td width=\"5%\" align='right'><font size='1'>M³</font></td>"
                        + "<td width=\"8%\"><font size='1'>Previsão</font></td>"
                        + "<td width=\"8%\"><font size='1'>Agendada</font></td>"
                        + "<td width=\"20%\"><font size='1'>OBS</font></td>"
                        + "<td width=\"8%\"><font size='1'>"+(cfg.isBaixaEntregaNota()?"Entrega":"")+"</font></td>"
                        + "<td width=\"16%\"><font size='1'>"+(cfg.isBaixaEntregaNota()?"OBS Entrega":"")+"</font></td>"
                        + "</tr>";
                BeanConsultaConhecimento conCt = new BeanConsultaConhecimento();
                conCt.setConexao(Apoio.getUsuario(request).getConexao());
                conCt.consultarNf(idctrc);
                ResultSet rs = conCt.getResultado();
                int row = 0;
                String idxNf = "";
                while (rs.next()) {
                    idxNf = idctrc + "_" + row;
                    resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";
                    resultado += "<td><font size='1'>" + rs.getString("numero") + "</font></td>"
                            + "<td><font size='1'>" + rs.getString("serie_nf") + "</font></td>"
                            + "<td><font size='1'>" + (rs.getDate("emissao") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("emissao")) : "") + "</font></td>"
                            + "<td align='right'><font size='1'>" + fmtMoeda.format(rs.getFloat("valor")) + "</font></td>"
                            + "<td align='right'><font size='1'>" + fmtMetro.format(rs.getFloat("peso")) + "</font></td>"
                            + "<td align='right'><font size='1'>" + fmtMoeda.format(rs.getFloat("volume")) + "</font></td>"
                            + "<td align='right'><font size='1'>" + fmtMetro.format(rs.getFloat("metro_cubico")) + "</font></td>"
                            + "<td><font size='1'>" + (rs.getDate("previsao_entrega_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("previsao_entrega_em")) + " às " + rs.getString("previsao_entrega_as") : "") + "</font></td>"
                            + "<td><font size='1'>" + (rs.getDate("data_agenda") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("data_agenda")) + " às " + rs.getString("hora_agenda") : "") + "</font></td>"
                            + "<td><font size='1'>" + rs.getString("obs_agenda") + "</font></td>";
                            if (cfg.isBaixaEntregaNota()){
                                resultado += "<td><font size='1'>" + (rs.getDate("entrega_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("entrega_em")) + " às " + rs.getString("entrega_as") : "") + "</font></td>"
                                + "<td><font size='1'>" + rs.getString("observacao_entrega") + "</font></td>";
                            }else{
                                resultado += "<td><font size='1'></font></td>"
                                + "<td><font size='1'></font></td>";
                            }
                    resultado += "</tr>";
                    resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";
                    resultado += "<td colspan='7'>"
                            + "<img src='img/pesquisar_cte.png' height='25px' align='middle' border='0' class='imagemLink' title='Abrir Consulta Completa de NF-e no site da SEFAZ.' onclick='consultarNfeSefaz();'/>"
                            + "&nbsp;&nbsp;&nbsp;<font size='1'>Chave de acesso da NF-e: " + rs.getString("chave_acesso") + "</font>"
                            + "</td>";
                    resultado += "<td colspan='5'><font size='1'></font></td>";
                    resultado += "</tr>";
                    row++;
                }
                resultado += "</table>";
                response.getWriter().append(resultado);
                response.getWriter().close();
            }else if (acao.equals("exportar")){

                String idCtrc = request.getParameter("idCtrc");
                String modelo = "1";
                //Verificando qual campo filtrar

                //Exportando
                java.util.Map param = new java.util.HashMap(1);
                param.put("ID_MOVIMENTACAO", idCtrc);
                request.setAttribute("map", param);
                request.setAttribute("rel", "documento_ctrc_mod"+modelo);
                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
                dispacher.forward(request, response);
            }
            

            

%>

<script language="javascript" type="text/javascript">
    var ctrcAux = '0';
    var zebraAux = '1'
    var idxOco = 0;
 jQuery.noConflict();

function consultarNfeSefaz(){
    window.open('http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa', 'pop', '');
}

function popCTRC(id){

     if (id == null)
        return null;
     launchPDF('./consulta_entrega_ctrc.jsp?acao=exportar&impressao=1&modelo=1&idCtrc='+id,'ctrc_'+id);

}

    shortcut.add("Alt+V",function() {visualizar();});
    
    function visualizar(){
        var filtros = "";
        var tipoConsulta = "";
        var consultarNotaPor = $("consultarNotaPor") != null ? $("consultarNotaPor").value : "numero" ;
        
        if ($("tipoFiltro1").checked){
            tipoConsulta = "emissaoCtrc";
        }else if ($("tipoFiltro2").checked){
            tipoConsulta = consultarNotaPor;
        }else if ($("tipoFiltro3").checked){
            tipoConsulta = "ctrc";
        }else if ($("tipoFiltro4").checked){
            tipoConsulta = "ctrcRedespacho";
        }
        filtros = concatFieldValue("idremetente,iddestinatario,valorConsultaNota,ctrc,"+
            "dtinicial,rem_rzs,dest_rzs,dtfinal,ctrc_redespacho,limite,rem_cnpj,"+
            "dest_cnpj,tipoTransporte,endereco_entrega,bairro_entrega,serie_nf,idconsignatario,con_rzs,con_cnpj,serie,filialId, tipoFilial,idmotorista,idveiculo,"+
            "motor_nome,idmotorista,vei_placa,idveiculo");
        //Apenas se os filtros estiverem corretos
            location.replace("./consulta_entrega_ctrc.jsp?acao=consultar&tipoFiltro="+tipoConsulta + "&consultarNotaPor=" + consultarNotaPor
                + "&chkNaoEntregue="+$("chkNaoEntregue").checked
                + "&chkTrazerColeta="+$("chkTrazerColeta").checked+"&"+filtros);
    }

    function carregarDetalhes(ctrcId,zebra,botao){
        if (botao == "minus"){
            $("trOcorrenciaCtrc_" + ctrcId).style.display = "none";
            $("plus_" + ctrcId).style.display = "";
            $("minus_" + ctrcId).style.display = "none";
            return false;
        }else{        
            $("plus_" + ctrcId).style.display = "none";
            $("minus_" + ctrcId).style.display = "";
            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport){
            
                var textoresposta = transport.responseText;
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0"){
                    return false;
                }else{
                    Element.show("trOcorrenciaCtrc_"+ctrcId);
                    $("trOcorrenciaCtrc_"+ctrcId).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
                }
            }//funcao e()
            espereEnviar("",true);
            //$('mostrar_'+ctrcId).style.display = "none";
            zebraAux = zebra;

            idxOco = 0;
            while ($('trCt_'+ctrcId+'idx'+idxOco) != null){
                Element.remove('trCt_'+ctrcId+'idx'+idxOco);
                idxOco++
            }

            tryRequestToServer(function(){
                new Ajax.Request("./consulta_entrega_ctrc.jsp?acao=carregarOcorrencia&ctrcId="+ctrcId +
                    "&zebra="+zebra,
                {method:'post', onSuccess: e, onError: e});});
        }
    }

    function localizaRemetenteCodigo(campo, valor){
	//objeto funcao usado na requisicao Ajax(uma espécie de evento)
	function e(transport){
		var resp = transport.responseText;
		espereEnviar("",false);
		//se deu algum erro na requisicao...
		if (resp == 'null'){
			alert('Erro ao localizar cliente.');
			return false;
		}else if(resp == ''){
			$('idremetente').value = '0';
			$('rem_cnpj').value = '';
			$('rem_rzs').value = '';

                        if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                            window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                        }
			return false;
		}else{
			var cliControl = eval('('+resp+')');
			$('idremetente').value = cliControl.idcliente;
			$('rem_cnpj').value = cliControl.cnpj;
			$('rem_rzs').value = cliControl.razao;
		}
	}//funcao e()
     if (valor != ''){
        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
        });
     }
  }

    function localizaConsignatarioCodigo(campo, valor){
	//objeto funcao usado na requisicao Ajax(uma espécie de evento)
	function e(transport){
		var resp = transport.responseText;
		espereEnviar("",false);
		//se deu algum erro na requisicao...
		if (resp == 'null'){
			alert('Erro ao localizar cliente.');
			return false;
		}else if(resp == ''){
			$('idconsignatario').value = '0';
			$('con_cnpj').value = '';
			$('con_rzs').value = '';
                        if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                            window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                        }
			return false;
		}else{
			var cliControl = eval('('+resp+')');
			$('idconsignatario').value = cliControl.idcliente;
			$('con_cnpj').value = cliControl.cnpj;
			$('con_rzs').value = cliControl.razao;
		}
	}//funcao e()
     if (valor != ''){
        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
        });
     }
  }
    function localizaDestinatarioCodigo(campo, valor){
	//objeto funcao usado na requisicao Ajax(uma espécie de evento)
	function e(transport){
		var resp = transport.responseText;
		espereEnviar("",false);
		//se deu algum erro na requisicao...
		if (resp == 'null'){
			alert('Erro ao localizar cliente.');
			return false;
		}else if(resp == ''){
			$('iddestinatario').value = '0';
			$('dest_cnpj').value = '';
			$('dest_rzs').value = '';
                        if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                            window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                        }
			return false;
		}else{
			var cliControl = eval('('+resp+')');
			$('iddestinatario').value = cliControl.idcliente;
			$('dest_cnpj').value = cliControl.cnpj;
			$('dest_rzs').value = cliControl.razao;
		}
	}//funcao e()
     if (valor != ''){
        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
        });
     }
  }

    function setValorConsulta(obj, tamanhoPadrao){
        if (obj.value == null || obj.value == ""){
            obj.value = tamanhoPadrao;
        }
    }

  function setTipoFiltro(){
      var tipoFiltro = '<%=(request.getParameter("tipoFiltro") != null ? request.getParameter("tipoFiltro").trim() : "0")%>';
      if (tipoFiltro == "ctrcRedespacho"){
          $("tipoFiltro4").checked = true;
      }else if (tipoFiltro == "numero" || tipoFiltro == "pedido" || tipoFiltro == "manifesto" || tipoFiltro == "numeroAWB" || tipoFiltro == "numeroRomaneio" || tipoFiltro == "numeroColeta" || tipoFiltro == "pedidoNF"){
          $("tipoFiltro2").checked = true;
      }else if (tipoFiltro == "ctrc"){
          $("tipoFiltro3").checked = true;
      }else{
          $("tipoFiltro1").checked  = true;
      }
      carregarFiliais($("filialId").value);
      alteraTipoFilial($("tipofilialusada").value);
      validaMostraColeta();
  }

  function validaMostraColeta(){
        if ($("tipoFiltro1").checked){
            $("divColeta").style.display = "";
            //comentei pois toda vez que chama função visualizar executa a função setTipoFiltro por sua vez chama a validaMostraColeta e assim sempre coloca o check de acordo com a pesquisa. Daniel CAssimiro _ Historia 1361
//            $("chkNaoEntregue").checked = true;
        }else if ($("tipoFiltro2").checked){
            $("divColeta").style.display = "none";
//            $("chkNaoEntregue").checked = false;
        }else if ($("tipoFiltro3").checked){
            $("divColeta").style.display = "none";
//            $("chkNaoEntregue").checked = false;
        }else if ($("tipoFiltro4").checked){
            $("divColeta").style.display = "none";
//            $("chkNaoEntregue").checked = false;
        }
  }

  function fechar(){
        window.close();
  }

  function verCtrc(id, tipo){
      if (tipo == 'ns'){
          window.open("./cadvenda.jsp?acao=editar&id="+id+"&ex=false", "NFS" , "top=0,resizable=yes");
      }else{
          window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "Conhecimento" , "top=0,resizable=yes");
      }
  }

  function verColeta(id){
      window.open("./cadcoleta?acao=editar&id="+id, "Coleta" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
  }

  function verManifesto(id){
      window.open("./cadmanifesto?acao=editar&id="+id, "Manifesto" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
  }

  function verCartaFrete(id, isCiot){
      if (!isCiot){
          window.open("./cadcartafrete?acao=editar&id="+id, "CartaFrete" , 'top=80,left=70,height=500,width=1024,resizable=yes,status=1,scrollbars=1');
      }else{
          window.open("./ContratoFreteControlador?acao=iniciarEditar&id="+id, "CartaFrete" , 'top=80,left=70,height=500,width=1024,resizable=yes,status=1,scrollbars=1');
      }    
  }

  function verRomaneio(id){
      window.open("./cadromaneio?acao=editar&id="+id, "Romaneio" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
  }

  function verProtocolo(id){
      window.open("./ProtocoloControlador?acao=iniciarEditar&id="+id, "Protocolo" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
  }
  function verDetalhesNF(ctrcId){
      if ($("plusNF_"+ctrcId).style.display == ""){
          $("plusNF_"+ctrcId).style.display = "none";
          $("minusNF_"+ctrcId).style.display = "";
          function e(transport){
             var textoresposta = transport.responseText;
             espereEnviar("",false);
             //se deu algum erro na requisicao...
             if (textoresposta == "-1"){
                return false;
             }else{
                Element.show("trDetalheNF_"+ctrcId);
                $("trDetalheNF_"+ctrcId).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
             }
          }//funcao e()
          espereEnviar("",true);
          new Ajax.Request("./consulta_entrega_ctrc.jsp?acao=carregarNF&ctrcId="+ctrcId,{method:'post', onSuccess: e, onError: e});
      }else{
          Element.hide("trDetalheNF_"+ctrcId);
          $("plusNF_"+ctrcId).style.display = "";
          $("minusNF_"+ctrcId).style.display = "none";
      }
  }
  
  function popImg(idconhecimento, numero, data,filial){
             //var modelo = $("modelo").value;
             window.open('./ImagemControlador?acao=carregar&idconhecimento='+idconhecimento +
            '&numero='+numero + '&data='+data + "&filial="+filial,
             'imagensConhecimento','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
         }
    function mudarFormaConsulta(){
        if($("consultarNotaPor").value === 'pedidoNF'){
            $("serie_nf").style.display = 'none';
        }else{
            $("serie_nf").style.display = '';
        }
    }
    
    function carregarFiliais(idFilial){
        var tipoFilialSelect = $("tipoFilial").value;
        var filialUsada = $("idfilialusada").value;
        jQuery.ajax({
            url: '<c:url value="/FilialControlador" />',
            dataType: "text",
            method: "post",
            contentType: "application/json; charset=utf-8",
            data: {
                tipoFilialSelect: tipoFilialSelect,
                idFilial: idFilial,
                acao : "listarFilialFranquia"
            },
            success: function(data) {
                var filiais = jQuery.parseJSON(data);
                if (filiais != null) {
                    var selectbox = jQuery("#filialId");
                    selectbox.find('option').remove();
                    var maxFilial = (filiais != undefined && filiais.list[0].filialFranquia.length != undefined ? filiais.list[0].filialFranquia.length : 1);
                    for (var i = 0; i < maxFilial; i++) {
                            if (maxFilial > 1) {
                                    if (i == 0) {
                                        jQuery('<option>').val(0).text("TODAS AS FILIAIS").appendTo(selectbox);
                                    }
                                jQuery('<option>').val(filiais.list[0].filialFranquia[i].id).text("APENAS A " + filiais.list[0].filialFranquia[i].abreviatura).appendTo(selectbox);
                            } else {
                                jQuery('<option>').val(filiais.list[0].filialFranquia.id).text("APENAS A " + filiais.list[0].filialFranquia.abreviatura).appendTo(selectbox);
                            }
                        }    
                    jQuery("#filialId").val(filialUsada);
                    }
            },error: function(){
                alert("Erro ao carregar a lista de filiais!");
            }
        });
    }
    
    function alteraTipoFilial(tipo){
        if (tipo == "entrega") {
            $("tipoFilial").value = "entrega";
        } else{
            $("tipoFilial").value = "emissao";
        }
        carregarFiliais($("filialId").value);
    }
    
    function localizaMotorista(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>','motorista',
        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
     function limpaMotorista(){
        $("idmotorista").value = 0;
        $("motor_nome").value = "";
    }
    
    function limpaVeiculo(){
        $("idveiculo").value = 0;
        $("vei_placa").value = "";
    }
    
    function popRomaneio(id) {
        if (id == null)
	    return null;
        launchPDF('./consultaromaneio?acao=exportar&modelo=<%=cfg.getRelDefaultConsultaRomaneio()%>&campo=idromaneio&valorconsulta=' + id, 'romaneio' + id);
    }
      function popManifesto(id){
            if (id == null)
                return null;
            launchPDF('./consultamanifesto?acao=exportar&modelo=<%=cfg.getRelDefaultManifesto()%>&id='+id, 'manifesto'+id);
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

        <title>Webtrans - Consulta Entrega</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .styleVermelho {color: #FF0000}
            .styleAzul {color: #0000FF}
            -->
        </style>
    </head>

    <body onLoad="setTipoFiltro(); mudarFormaConsulta()">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idremetente" id="idremetente" value="<%=(request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0")%>">
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=(request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0")%>">
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0")%>">
            <input type="hidden" name="idfilialusada" id="idfilialusada" value="<%=(request.getParameter("filialId") != null ? request.getParameter("filialId") : "0")%>">
            <input type="hidden" name="tipofilialusada" id="tipofilialusada" value="<%=(request.getParameter("tipoFilial") != null ? request.getParameter("tipoFilial") : "")%>">
        </div>
        <table width="100%" height="28" align="center" class="bordaFina" >
            <tr>
                <td width="86%" height="22"><b>Consulta entrega</b></td>
                <td width="14%">
                    <b>
                        <input  name="Button" type="button" class="botoes" value="Fechar" onClick="fechar()">
                    </b>
                </td>
            </tr>
        </table>

        <br>

        <table width="100%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td height="18" colspan="9"><div align="center">Filtros </div></td>
            </tr>
           <tr>
                <td width="14%" class="TextoCampos"><label>
                        <input name="tipoConsulta" type="radio" id="tipoFiltro1" value="emissaoCtrc" onClick="validaMostraColeta()">
                        Emissão CT-e</label></td>
                <td width="20%" class="CelulaZebra2"><strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=(request.getParameter("dtinicial") == null ? Apoio.getDataAtual() : request.getParameter("dtinicial"))%>" size="9" maxlength="10"
                              class="fieldDate" onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event); if (event.keyCode==13) visualizar()" />
                    </strong>e<strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=(request.getParameter("dtfinal") == null ? Apoio.getDataAtual() : request.getParameter("dtfinal"))%>" size="9" maxlength="10"
                              class="fieldDate" onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event); if (event.keyCode==13) visualizar()" />
                    </strong></td>
                <td width="12%" class="TextoCampos">
                    
                    <div align="center">
                        <input type="radio" name="tipoConsulta" id="tipoFiltro2" value="notaFiscal" onClick="validaMostraColeta()">
                        <select align="center" name="consultarNotaPor" id="consultarNotaPor" style="font-size:8pt;width:80px;"   class="fieldMin" onchange="mudarFormaConsulta()">
                            <option value="numero" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("numero")) ? "selected" : "" %> >N&ordm; NF</option>
                            <option value="pedido" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("pedido")) ? "selected" : "" %> >N&ordm; Pedido CT-e</option>
                            <option value="manifesto" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("manifesto")) ? "selected" : "" %> >N&ordm; Manifesto</option>
                            <option value="numeroAWB" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("numeroAWB")) ? "selected" : "" %> >N&ordm; AWB</option>
                            <option value="numeroRomaneio" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("numeroRomaneio")) ? "selected" : "" %> >N&ordm; Romaneio</option>
                            <option value="numeroColeta" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("numeroColeta")) ? "selected" : "" %> >N&ordm; Coleta</option>
                            <option value="pedidoNF" <%= (request.getParameter("consultarNotaPor") != null && request.getParameter("consultarNotaPor").equals("pedidoNF")) ? "selected" : "" %> >N&ordm; Pedido da NF</option>
                        </select>
                    </div>
                </td>
                <td width="8%" class="CelulaZebra2"><strong>
                        <input name="valorConsultaNota" type="text" id="valorConsultaNota" value="<%=(request.getParameter("valorConsultaNota") != null ? request.getParameter("valorConsultaNota") : "")%>" class="fieldMin"
                               size="7" maxlength="80" onKeyPress="javascript:if (event.keyCode==13) visualizar()">
                        <input name="serie_nf" type="text" id="serie_nf" value="<%=(request.getParameter("serie_nf") != null ? request.getParameter("serie_nf") : "")%>" class="fieldMin"
                               size="1" maxlength="3" onKeyPress="javascript:if (event.keyCode==13) visualizar()">
                    </strong></td>
                <td width="12%" class="TextoCampos">
                    <input type="radio" name="tipoConsulta" id="tipoFiltro3" value="ctrc" onClick="validaMostraColeta()">
                    N&ordm; CT-e/NFS</td>
                <td width="6%" class="CelulaZebra2">
                    <strong>
                        <input name="ctrc" type="text" id="ctrc" value="<%=(request.getParameter("ctrc") != null ? request.getParameter("ctrc") : "")%>"
                               size="7" class="fieldMin" maxlength="80" onKeyPress="javascript:if (event.keyCode==13) visualizar()">
                    </strong>
                        <strong>
                            <input name="serie" type="text" id="serie" value="<%=(request.getParameter("serie")!= null ? request.getParameter("serie") : "")%>" 
                                 size="1" maxlength="3" class="fieldMin" onKeyPress="javascript:if (event.keyCode==13) visualizar()">
                         </strong>
                    </td>
                <td width="18%" class="TextoCampos">
                    <input type="radio" name="tipoConsulta" id="tipoFiltro4" value="ctrcRedespacho" onClick="validaMostraColeta()">
                    N&ordm; CT-e redespacho</td>
                <td width="10%" class="CelulaZebra2">
                    <input name="ctrc_redespacho" type="text" id="ctrc_redespacho" class="fieldMin" value="<%=(request.getParameter("ctrc_redespacho") != null ? request.getParameter("ctrc_redespacho") : "")%>"
                           size="7" maxlength="80" onKeyPress="javascript:if (event.keyCode==13) visualizar()">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="1">Remetente:</td>
                <td colspan="3" class="CelulaZebra2"><strong>
                        <input name="rem_cnpj" type="text" id="rem_cnpj" size="16" value="<%=(request.getParameter("rem_cnpj") != null ? request.getParameter("rem_cnpj") : "")%>"
                               onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj', this.value)" class="inputReadOnly8pt">
                        <input name="rem_rzs" type="text" id="rem_rzs" value="<%=(request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "")%>" 
                               size="29" maxlength="80" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('c.razaosocial', this.value)" class="inputReadOnly8pt">

                        <input name="localiza_rem2" type="button" class="botoes" id="localiza_rem2" value="..." onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Remetente_')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('rem_rzs').value = '';getObj('idremetente').value = '0';getObj('rem_cnpj').value = '';"></strong></td>
                <td class="TextoCampos"colspan="1">Destinat&aacute;rio:</td>
                <td colspan="3" class="CelulaZebra2"><strong>
                        <input name="dest_cnpj" type="text" id="dest_cnpj" size="16" value="<%=(request.getParameter("dest_cnpj") != null ? request.getParameter("dest_cnpj") : "")%>"
                               onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('cnpj', this.value)" class="inputReadOnly8pt">
                        <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly8pt" value="<%=(request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "")%>"
                               size="25" maxlength="80" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('c.razaosocial', this.value)">
                        <input name="localiza_dest2" type="button" class="botoes" id="localiza_dest2" value="..." onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=4','Destinatario_')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('dest_rzs').value = '';getObj('iddestinatario').value = '0';getObj('dest_cnpj').value = ''"></strong></td>
            </tr>
            <tr>
                <td colspan="" class="TextoCampos">Consignatário: </td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="con_cnpj" type="text" id="con_cnpj" size="16" value="<%=(request.getParameter("con_cnpj") != null ? request.getParameter("con_cnpj") : "")%>"
                               onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj', this.value)" class="inputReadOnly8pt">
                        <input name="con_rzs" type="text" id="con_rzs" class="inputReadOnly8pt" value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>"
                               size="25" maxlength="80" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('c.razaosocial', this.value)">
                        <input name="localiza_cons" type="button" class="botoes" id="localiza_cons" value="..." onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Consignatario_')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('con_rzs').value = '';getObj('idconsignatario').value = '0';getObj('con_cnpj').value = ''">
                    
                </td>
                               
                <td colspan="4" class="CelulaZebra2">
                        Endereço Entrega:<input name="endereco_entrega" type="text" id="endereco_entrega" size="31" value="<%=(request.getParameter("endereco_entrega") != null ? request.getParameter("endereco_entrega") : "")%>" class="fieldMin">
                        Bairro:<input name="bairro_entrega" type="text" id="bairro_entrega" size="17" value="<%=(request.getParameter("bairro_entrega") != null ? request.getParameter("bairro_entrega") : "")%>" class="fieldMin">
                </td>
            </tr>
            <tr>
                <td colspan="2" class="TextoCampos">
                    <div align="center">
                        <input name="chkNaoEntregue" id="chkNaoEntregue" type="checkbox" 
                        value="1" <%=(request.getParameter("chkNaoEntregue") == null || request.getParameter("chkNaoEntregue").equals("true")? "checked" : "")%>>
                            Apenas CT-e(s) não entregues
                    </div>
                </td>
                <td class="TextoCampos">
                    <div align="center" style="display:none" id="divColeta">
                        <input name="chkTrazerColeta" id="chkTrazerColeta" type="checkbox" 
                        value="1" <%=(request.getParameter("chkTrazerColeta") == null || request.getParameter("chkTrazerColeta").equals("false")? "" : "checked")%>>
                           Consultar coletas
                    </div>
                </td>
                <td class="TextoCampos" >
                    <div align="center">
                        <select align="center" name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:'160px';"   class="fieldMin">
                            <%= emiteRodoviario && emiteAereo && emiteAquaviario ?  "<option value='false'" + (request.getParameter("tipoTransporte") == null || request.getParameter("tipoTransporte").equals("false") ? "selected" : "") + ">Todos</option>" : ""  %>
                            <%= emiteRodoviario ?  "<option value='r'" + (request.getParameter("tipoTransporte") != null && request.getParameter("tipoTransporte").equals("r") ? "selected" : "") + ">CTR - Transp. Rodoviário</option>" : ""  %>
                            <%= emiteAereo ? "<option value='a'" + (request.getParameter("tipoTransporte") != null && request.getParameter("tipoTransporte").equals("a") ? "selected" : "") +" >CTA - Transp. A&eacute;reo</option>" : ""  %>
                            <%= emiteAquaviario ? "<option value='q'" +  (request.getParameter("tipoTransporte") != null && request.getParameter("tipoTransporte").equals("q") ? "selected" : "") + ">CTQ - Transp. Aquavi&aacute;rio</option>" : ""  %>
                        </select>
                    </div>
                </td>
                <td class="CelulaZebra2" align="center">
                    <div align="center">
                        <select name="tipoFilial" id="tipoFilial" style="font-size:8pt;" class="inputTexto" onChange="alteraTipoFilial(this.value)">
                            <option value="emissao" selected>FILIAL DE EMISSÃO</option>
                            <option value="entrega">FILIAL DE ENTREGA</option>
                        </select>
                    </div>
                </td>
                <td class="CelulaZebra2" align="center">
                    <div align="center">
                        <select name="filialId" id="filialId" class="fieldMin">
                        </select>
                    </div>
                </td> 
                <td width="18%" class="TextoCampos">
                    Limite de resultados:
                </td>
                <td width="10%" class="CelulaZebra2"colspan="2">
                   <input name="limite" type="text" id="limite"
                    class="fieldMin" value="<%=(request.getParameter("limite") == null ? "50" : request.getParameter("limite"))%>" onChange="setValorConsulta(this, '50')" size="5" maxlength="80">
                </td>
            </tr>
            
            <tr>
                <td colspan="" class="TextoCampos">Motorista:</td>
                <td class="CelulaZebra2">
                    <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" size="28" readonly="true"  value="<%=(request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "")%>" >
                    <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:localizaMotorista();">
                    <input type="hidden" name="idmotorista" id="idmotorista"  value="<%=(request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "")%>"   />
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaMotorista();"/>
                </td>
                <td colspan="" class="TextoCampos">Veículo:</td>
                <td class="CelulaZebra2" colspan="5">
                    <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" size="10" readonly="true" value="<%=(request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "")%>" >
                    <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=7', 'Veiculo', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                    <input type="hidden" name="idveiculo"   id="idveiculo" value="<%=(request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : "")%>">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaVeiculo();"/>
                </td>
            </tr>
            
            <tr>
                <td colspan="9" class="TextoCampos">
                    <div align="center">
                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="   Visualizar [Alt+V]  " onClick="javascript:tryRequestToServer(function(){visualizar();});">
                    </div>
                </td>
            </tr>
        </table>
        <form method="post" id="formBx" >
            <table width="100%" border="0" class="bordaFina">
                <tr class="tabela">
                    <td width="2%">&nbsp;</td>
                    <td width="6%"><strong>CT-e</strong></td>
                    <td width="6%"><strong>Tipo</strong></td>
                    <td width="9%"><strong>Filial</strong></td>
                    <td width="25%"><strong>Remetente</strong></td>
                    <td width="25%"><strong>Destinatário</strong></td>
                    <td width="17%">Destino</td>
                    <td width="6%">Frete</td>
                    <td width="4%"><strong></strong></td>
                </tr>
                <% //variaveis da paginacao
                         int linha = 0;
                         boolean isCancelado = false;
                         // se conseguiu consultar
                         if ((acao.equals("consultar")) && (conCtrc.consultarEntregaCTRC(
                                 Integer.parseInt(request.getParameter("idremetente")),
                                 Integer.parseInt(request.getParameter("iddestinatario")),
                                 request.getParameter("ctrc_redespacho"),
                                 request.getParameter("valorConsultaNota"),
                                 request.getParameter("ctrc"),
                                 request.getParameter("tipoFiltro"),
                                 request.getParameter("chkNaoEntregue"),
                                 (request.getParameter("tipoTransporte") == null ? "false" : request.getParameter("tipoTransporte")),
                                 request.getParameter("endereco_entrega") == null ? "" : request.getParameter("endereco_entrega"),
                                 request.getParameter("bairro_entrega") == null ? "" : request.getParameter("bairro_entrega"),
                                 Integer.parseInt(request.getParameter("idconsignatario")),
                                 request.getParameter("serie"),
                                Apoio.parseInt(request.getParameter("filialId")),
                                 (request.getParameter("tipoFilial") == null ? "false" : request.getParameter("tipoFilial")),
                                 Apoio.parseInt(request.getParameter("idmotorista")),
                                 Apoio.parseInt(request.getParameter("idveiculo"))))) {
                             //Apenas as duplicatadas agora
                             ResultSet rs = conCtrc.getResultado();
                             while (rs.next()) {
                                 isCancelado = rs.getBoolean("is_cancelado");
                 %>
                             
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho":""%>" >
                    <td >
                     <img src="img/plus.jpg" id="plus_<%=rs.getString("id")%>" name="plus_<%=rs.getInt("id")%>" title="Mostrar mais detalhes" class="imagemLink" align="right" 
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhes('<%=rs.getString("id")%>','<%=((linha % 2) == 0 ? "1" : "2")%>','plus');});">
                     <img style="display:none" src="img/minus.jpg" id="minus_<%=rs.getInt("id")%>" name="minus_<%=rs.getInt("id")%>" title="Mostrar mais detalhes" class="imagemLink" align="right"
                             onclick="javascript:tryRequestToServer(function(){carregarDetalhes('<%=rs.getString("id")%>','<%=((linha % 2) == 0 ? "1" : "2")%>','minus');});">
                    </td>
                    <td>
                       <%if (nivelUser>0){ %>
                       <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("id")%>','<%=rs.getString("categoria")%>');});">
 		               <font size="1"><%=rs.getString("numero")+"/"+rs.getString("serie")%></font></div>
 		           <%}else{ %>
 		               <font size="1"><%=rs.getString("numero")+"/"+rs.getString("serie")%></font>
 		       <%} %>
                    </td>
                    <td>
                        <%=rs.getString("descricao_tipo_conhecimento")%>
                    </td>
                    <td>
                        <%=rs.getString("filial")%>
                    </td>
                    <td>
                        <%=rs.getString("nome_remetente")%>
                    </td>
                    <td>
                        <%=rs.getString("nome_destinatario")%>
                    </td>
                    <td > 
                        <%=rs.getString("cid_destino")%>
                    </td>
                    <td >
                        <%=new DecimalFormat("#,##0.00").format(rs.getDouble("total_receita"))%>
                    </td>
                    <td>
                        <%=rs.getString("tipo")%>
                    </td>
                </tr>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho":""%>" >
                    <td>
                        <%if (rs.getInt("qtd_ocorrencias") > 0){%>
                        <img src="img/atencao.gif" width="20" height="20" border="0" align="right" class="imagemLink" title="Existe Ocorrências para esse Conhecimento, clique aqui para visualizá-las."
                         onclick="javascript:tryRequestToServer(function(){carregarDetalhes('<%=rs.getString("id")%>','<%=((linha % 2) == 0 ? "1" : "2")%>','plus');});">
                        <%}%>
                    </td>
                    <td colspan="3">
                        <b>STATUS: <%=rs.getString("status_ctrc")%></b>
                    </td>
                    <td>
                        <b>Notas Fiscais: <img src="img/plus.jpg" id="plusNF_<%=rs.getString("id")%>" name="plusNF_<%=rs.getInt("id")%>" title="Mostrar mais detalhes da nota" class="imagemLink" 
                             onclick="javascript:tryRequestToServer(function(){verDetalhesNF('<%=rs.getString("id")%>');});">
							                      <img style="display:none" src="img/minus.jpg" id="minusNF_<%=rs.getInt("id")%>" name="minusNF_<%=rs.getInt("id")%>" title="Ocultar detalhes" class="imagemLink" 
                             onclick="javascript:tryRequestToServer(function(){verDetalhesNF('<%=rs.getString("id")%>');});">
							 <%=rs.getString("notas_fiscais").replace("{","").replace("}","")%></b>
                    </td>
                    <td colspan="3">
                        Qtd vol.: <%=new DecimalFormat("#,##0").format(rs.getDouble("qtd_volumes"))%>&nbsp;&nbsp;
                        Peso: <%=new DecimalFormat("#,##0.00").format(rs.getDouble("peso"))%>&nbsp;&nbsp;
                        Valor NF: <%=new DecimalFormat("#,##0.00").format(rs.getDouble("vl_nota"))%>&nbsp;&nbsp;
                        M³: <%=new DecimalFormat("#,##0.000").format(rs.getFloat("metro_cubico"))%>
                    </td>
                    <td>
                        <div align="right">
                           <img src="img/pdf.gif" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popCTRC('<%=rs.getString("id")%>');});">
                        </div>
                    </td>
                </tr>
                <tr id="trDetalheNF_<%=rs.getString("id")%>" name="trDetalheNF_<%=rs.getString("id")%>" style="display:none;">
                	<td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" ></td>
                    <td colspan="10" name="tdNotas_<%=rs.getString("id")%>" id="tdNotas_<%=rs.getString("id")%>">--</td>
                </tr>
                <tr>
                    <td colspan="10">
                        <table width="100%">
                            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho":""%>" >
                                <td width="13%">
                                    Coleta: <%=rs.getDate("data_coleta") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("data_coleta")) : ""%>
                                </td>
                                <td width="14%">
                                    Emissão: <%=rs.getDate("emissao_sales") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("emissao_sales")) : ""%>
                                </td>
                                <td width="15%">
                                    Embarque:
                                    <%if (!rs.getString("nmanifesto").equals("")){%>
                                     <%=rs.getDate("dt_saida") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dt_saida")) : ""%>
                                     às:<%=rs.getDate("hr_saida") != null ? new SimpleDateFormat("HH:mm").format(rs.getTime("hr_saida")) : ""%>
                                
                                    <a href="javascript:tryRequestToServer(function(){verManifesto('<%=rs.getString("idmanifesto")%>');});" class="linkEditar">
                                        <%=rs.getString("nmanifesto")%></a>
                                    <% } %>
                                </td>
                                <td width="14%">
                                    Chegada: <%=rs.getDate("chegada_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("chegada_em")) : ""%>
                                    às: <%=rs.getTime("chegada_as") != null ? new SimpleDateFormat("HH:mm").format(rs.getTime("chegada_as")) : ""%>
                                </td>
                                <td width="16%">
                                    Descarrego: <%=rs.getDate("inicio_descarrego_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("inicio_descarrego_em")) : ""%>
                                    às: <%=rs.getTime("inicio_descarrego_as") != null ? new SimpleDateFormat("HH:mm").format(rs.getTime("inicio_descarrego_as")) : ""%>
                                </td>
                                <td width="12%">
                                    Previsão entrega: <%=rs.getDate("previsao_entrega_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("previsao_entrega_em")) : ""%>
                                    <br>
                                    <%= (rs.getDate("baixa_em") == null ?  (rs.getInt("prazo_entrega") >= 0 ? "Restam " + rs.getInt("prazo_entrega") + " Dias" : "Atraso de " + (rs.getInt("prazo_entrega")*(-1)) + " Dias") : "" )%>
                                </td>                                
                                <td width="14%">
                                    Entrega: <%= rs.getDate("baixa_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("baixa_em")) : ""%>
                                    às: <%=rs.getTime("entrega_as") != null ? new SimpleDateFormat("HH:mm").format(rs.getTime("entrega_as")) : ""%>
                                    <%=rs.getString("observacao_baixa") == null ? "" : "OBS: " + rs.getString("observacao_baixa")%> 
                                </td>
                                <td width="12%" align="center">
                                    <img src="img/jpg.png" width="20" height="20" border="0" align="right" class="imagemLink" title="Imagens de documentos"
                         onClick="javascript:tryRequestToServer(function(){popImg('<%=rs.getString("id")%>','<%=rs.getString("numero") + "/" + rs.getString("serie")%>','<%=formatador.format(rs.getDate("emissao_em"))%>','<%=rs.getString("filial")%>');});"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="10">
                        <table width="100%" border="0" class="bordaFina" <%=(rs.getInt("idmanifesto") == 0 ? "style=display:none" : "" )%> >
                            <tr class="tabela">
                                
                                <td width="2%"><strong></strong></td>
                                <td width="10%"><strong>Manifesto</strong></td>
                                <td width="6%"><strong>Saída</strong></td>
                                <td width="9%"><strong>Previsão de chegada</strong></td>
                                <td width="25%"><strong>Motorista</strong></td>
                                <td width="25%"><strong>Veículo</strong></td>
                                
                            </tr>
                             <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho":""%>">
                                 
                                <td width="2%">
                                   <div>
                                      <img src="img/pdf.gif" border="0" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popManifesto('<%=rs.getString("idmanifesto")%>');});">
                                   </div>
                               </td>
                                 <td width="10%">
                                    <%if (!rs.getString("nmanifesto").equals("")){%>
                                        <a href="javascript:tryRequestToServer(function(){verManifesto('<%=rs.getString("idmanifesto")%>');});" class="linkEditar">
                                        <%=rs.getString("nmanifesto")%></a>
                                    <% } %>
                                </td>
                                 <td width="10%">
                                    <%if (!rs.getString("nmanifesto").equals("")){%>
                                        <%=rs.getDate("dt_saida") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dt_saida")) : ""%>
                                        às:<%=rs.getDate("hr_saida") != null ? new SimpleDateFormat("HH:mm").format(rs.getTime("hr_saida")) : ""%>
                                    <% } %>
                                </td>
                                <td width="10%">
                                    Previsão Chegada: <%=rs.getString("previsao_manifesto") != null ? rs.getString("previsao_manifesto") : "" %>
                                </td>
                                <td width="15%">
                                   <%=rs.getString("nome_motorista") == null ? "" : rs.getString("nome_motorista")%>
                                </td>
                                <td width="15%">
                                   <%=rs.getString("placa") == null ? "" : rs.getString("placa")%>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="10">
                        <table width="100%" border="0" class="bordaFina" <%=(rs.getInt("idromaneio") == 0 ? "style=display:none" : "" )%>>
                            <tr class="tabela">
                                <td width="2%"><strong></strong></td>
                                <td width="15%"><strong>Romaneio</strong></td>
                                <td width="15%"><strong>Motorista</strong></td>
                                <td width="15%"><strong>Veiculo</strong></td>
                                <td width="10%"><strong>Data</strong></td>
                                
                            </tr>
                           
                                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho":""%>" >
                                    <td width="2%">
                                        <img src="img/pdf.jpg" width="19" height="19" border="0" class="imagemLink" title="Formato PDF(usado para a impressão)" 
                                             onClick="javascript:tryRequestToServer(function () {popRomaneio('<%=rs.getString("idromaneio")%>');});">
                                    </td>
                                   <td width="15%">
                                       <a href="javascript:tryRequestToServer(function(){verRomaneio('<%=rs.getString("idromaneio")%>');});" class="linkEditar">
                                      <%=rs.getString("numromaneio") == null ? "" : rs.getString("numromaneio")  %>
                                   </td> 
                                   <td width="15%">
                                        <%=rs.getString("roma_moto_nome") == null ? "" : rs.getString("roma_moto_nome")%>
                                   </td>
                                   <td width="15%">
                                        <%=rs.getString("roma_vei_placa") == null ? "" : rs.getString("roma_vei_placa")%>
                                   </td>
                                    <td width="10%">
                                        <%=rs.getDate("dtromaneio") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtromaneio")) : ""%>
                                    </td>
                               </tr>
                        </table>
                    </td>
                </tr>
                <tr name="trOcorrenciaCtrc_<%=rs.getString("id")%>" id="trOcorrenciaCtrc_<%=rs.getString("id")%>" style="display:none">
                    <td rowspan="1" class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>"></td>
                    <td colspan="10">
                        --
                    </td>
                </tr>
                <%
                                    linha++;
                                }
                            }
                %>
            </table>

            <br>
                <% //variaveis da paginacao
                         int linhaColeta = 0;
                         // se conseguiu consultar
                         if ((acao.equals("consultar")) &&
                                 request.getParameter("chkTrazerColeta").equals("true") &&
                                 request.getParameter("tipoFiltro").equals("emissaoCtrc")){
                         %>

            <table width="100%" class="bordaFina" border="0">
                <tr class="tabela">
                    <td width="6%">Coleta</td>
                    <td width="10%">Filial</td>
                    <td width="8%">Dt Solic.</td>
                    <td width="21%">Remetente</td>
                    <td width="23%">Destinatário</td>
                    <td width="12%">Destino</td>
                    <td width="8%">Peso Solic.</td>
                    <td width="8%">Vol Solic.</td>
                    <td width="4%">Tipo</td>
                </tr>
                <%
                            conColeta.setConexao(Apoio.getUsuario(request).getConexao());
                            conColeta.setDtEmissao1(Apoio.paraDate(request.getParameter("dtinicial")));
                            conColeta.setDtEmissao2(Apoio.paraDate(request.getParameter("dtfinal")));
                            conColeta.setLimiteResultados(Integer.parseInt(request.getParameter("limite")));
                         if (conColeta.consultarEntregaColeta(
                                 Integer.parseInt(request.getParameter("idremetente")),
                                 Integer.parseInt(request.getParameter("iddestinatario")))) {
                             //Apenas as duplicatadas agora
                             ResultSet rsCol = conColeta.getResultado();
                             while (rsCol.next()) {%>

                             <tr class="<%=((linhaColeta % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                                    <td >
                                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verColeta(<%=rsCol.getInt("id_pedido")%>);});">
                                            <%=rsCol.getString("numero")%>
                                        </div>
                                        </td>
                                    <td ><%=rsCol.getString("filial")%></td>
                                    <td >
                                        <%=rsCol.getDate("solicitada_em") != null ? new SimpleDateFormat("dd/MM/yyyy").format(rsCol.getDate("solicitada_em")) : ""%>
                                    </td>
                                    <td ><%=rsCol.getString("cliente")%></td>
                                    <td ><%=rsCol.getString("destinatario")%></td>
                                    <td ><%=rsCol.getString("cidade_destino")%></td>
                                    <td ><%=new DecimalFormat("#,##0.00").format(rsCol.getDouble("peso_solicitado"))%></td>
                                    <td ><%=new DecimalFormat("#,##0").format(rsCol.getDouble("volume_solicitado"))%></td>
                                    <td ><%=rsCol.getString("tipo")%></td>
                             </tr>
                           <%}
                          }
            }%>
            </table>
        </form>
    </body>
</html>