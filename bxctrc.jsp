<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.*,
         com.sagat.bean.NotaFiscal,
         conhecimento.ocorrencia.*,
         java.text.*,
         java.util.Date,
         nucleo.BeanConfiguracao,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<!--<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>-->
<script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>

<!--<script src="${homePath}/assets/js/jquery-1.9.1.min.js" type="text/javascript"></script>-->

<%
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelUserBaixa = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("bxctrc") : 0);
    int nivelUserFl = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelUserProtocolo = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadprotocolo") : 0);
    int nivelExcluirOcorrencia = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("excluirocorrencia") : 0);

     int nivelUserMarcarComprovanteBaixaEntradaCte = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("marcarComprovBaixaEntradaCte") : 0);
     
     int nivelAlterarCTeEntregue = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("alterarcteentregue") : 0);
     
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUserBaixa == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat formatadorHora = new SimpleDateFormat("HH:mm");

    BeanConfiguracao cfg = Apoio.getConfiguracao(request);
    boolean emAberto = false;
    boolean isCancelado = false;
    boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
    boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
    boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();

%>  
<jsp:useBean id="ctrc" class="conhecimento.BeanConhecimento" />
<jsp:useBean id="cadCtrc" class="conhecimento.BeanCadConhecimento" />
<jsp:useBean id="conCtrc" class="conhecimento.BeanConsultaConhecimento" />
<%
    //exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("consultar")) {
        conCtrc.setConexao(Apoio.getUsuario(request).getConexao());
        conCtrc.setDtEmissao1(Apoio.paraDate(request.getParameter("dtinicial")));
        conCtrc.setDtEmissao2(Apoio.paraDate(request.getParameter("dtfinal")));
        conCtrc.setSerieNF((request.getParameter("serie_nf") == null ? "" : request.getParameter("serie_nf") ));
        conCtrc.setNumeroCarga((request.getParameter("numeroCarga") == null ? "" : request.getParameter("numeroCarga") ));
    } else if (acao.equals("removerOcorrenciaAjax")) {
        Auditoria auditoria = new Auditoria();
        String mensagem = "";

        auditoria.setAcao("Excluida a ocorrencia de ID = " + request.getParameter("idOcorrencia") + ".");
        auditoria.setIp(request.getRemoteHost());
        auditoria.setModulo("webtrans");
        auditoria.setRotina("Exclusão de ocorrencias");
        auditoria.setUsuario(Apoio.getUsuario(request));
        
        mensagem = Ocorrencia.removerOcorrencia(Apoio.parseInt(request.getParameter("idOcorrencia")), auditoria, Apoio.parseInt(request.getParameter("nivel")));
            
        response.getWriter().append(mensagem);
        response.getWriter().close();       
        
    } else if (acao.equals("baixar")) {
        cadCtrc.setConexao(Apoio.getUsuario(request).getConexao());
        cadCtrc.setExecutor(Apoio.getUsuario(request));
        String dtEntrega = "";
        String dtInicioDescarrego = "";
        String dtFechamento = "";
        String dtBaixadoNoDia = "";
        String chegadaAs = "";
        String entregaAs = "";
        String descarregoAs = "";
        boolean comprovanteEntrega = false;
        //Preenchendo o array das coletas
        String valor = request.getParameter("dados");
        int qtdCols = Apoio.parseInt(request.getParameter("qtdLinha"));
        BeanConhecimento[] arCtrc = new BeanConhecimento[qtdCols];
        Ocorrencia[] arOcorrencia;
        int qtdOcorrencias = Integer.parseInt(request.getParameter("qtdOco"));
        int id = 0;
        String dtFimDescarrego = "";
        String fimDescarregoAs = "";
        
        for (int k = 0; k < qtdCols; ++k) {
            // if(request.getParameter("chk_"+k) != null){

            BeanConhecimento ct = new BeanConhecimento();
            ct.setId(Integer.parseInt(valor.split(";")[k].split("_")[0]));
            ct.setObservacaoBaixa(valor.split(";")[k].split("_")[1]);
            dtFechamento = valor.split(";")[k].split("_")[2];
            dtEntrega = valor.split(";")[k].split("_")[3];
            ct.setChegadaEm(dtEntrega.equals("") ? null : formatador.parse(valor.split(";")[k].split("_")[3]));
            ct.getOcorrencia().setCodigo(valor.split(";")[k].split("_")[4]);
            ct.setValorAvaria(Float.parseFloat(valor.split(";")[k].split("_")[5]));
            dtInicioDescarrego = valor.split(";")[k].split("_")[11];
            ct.setBaixaEm(dtFechamento.equals("") ? null : formatador.parse(dtFechamento));
            //novos campos a partir de 27/01/2010
            chegadaAs = valor.split(";")[k].split("_")[6].trim();
            entregaAs = valor.split(";")[k].split("_")[7].trim();
            dtBaixadoNoDia = valor.split(";")[k].split("_")[8].trim();
            comprovanteEntrega = Boolean.parseBoolean(valor.split(";")[k].split("_")[9].trim());
            ct.setInicioDescarregoEm(dtInicioDescarrego.equals("") ? null : formatador.parse(valor.split(";")[k].split("_")[11]));
            descarregoAs = valor.split(";")[k].split("_")[12].trim();
            ct.setInicioDescarregoAs(descarregoAs.equals("") ? "0:00" : descarregoAs);
            ct.setCobrouDescarrego((valor.split(";")[k].split("_")[13].trim().equals("true")));
            if (comprovanteEntrega && !dtFechamento.equals("") && !dtBaixadoNoDia.equals("")) {
                ct.setBaixadoNoDia(formatador.parse(dtBaixadoNoDia));
            }else{
                ct.setBaixadoNoDia(null);            
            }
            ct.setChegadaAs(chegadaAs.equals("") ? "0:00" : chegadaAs);
            ct.setEntregaAs(entregaAs.equals("") ? "0:00" : entregaAs);
            dtFimDescarrego = (valor.split(";")[k].split("_").length > 14 ? valor.split(";")[k].split("_")[14].trim() : "");
            ct.setFimDescarregoEm(dtFimDescarrego.equals("") ? null : formatador.parse(dtFimDescarrego));
            fimDescarregoAs = (valor.split(";")[k].split("_").length > 15 ? valor.split(";")[k].split("_")[15].trim() : "");
            ct.setFimDescarregoAs((fimDescarregoAs).equals("") ? "0:00" : fimDescarregoAs);
            //setando as ocorrências
            arOcorrencia = new Ocorrencia[qtdOcorrencias];
            int pp = 0;
            for (int o = 0; o < qtdOcorrencias; ++o) {
                Ocorrencia oc = new Ocorrencia();
                if (request.getParameter("ctrcId_Ct" + ct.getId() + "idx" + o) != null) {
                    oc.setId(Integer.parseInt(request.getParameter("id_Ct" + ct.getId() + "idx" + o)));
                    oc.getOcorrencia().setId(Integer.parseInt(request.getParameter("ocorrenciaId_Ct" + ct.getId() + "idx" + o)));
                    oc.getCtrc().setId(ct.getId());
                    oc.setOcorrenciaEm(request.getParameter("ocorrenciaEm_Ct" + ct.getId() + "idx" + o).equals("") ? null : formatador.parse(request.getParameter("ocorrenciaEm_Ct" + ct.getId() + "idx" + o)));
                    oc.setOcorrenciaAs(request.getParameter("ocorrenciaAs_Ct" + ct.getId() + "idx" + o).equals("") ? null : formatadorHora.parse(request.getParameter("ocorrenciaAs_Ct" + ct.getId() + "idx" + o)));
                    oc.setObservacaoOcorrencia(request.getParameter("obsOcorrencia_Ct" + ct.getId() + "idx" + o));
                    oc.setResolvido(request.getParameter("isResolvido_Ct" + ct.getId() + "idx" + o) != null);
                    oc.setResolucaoEm(request.getParameter("resolvidoEm_Ct" + ct.getId() + "idx" + o).equals("") ? null : formatador.parse(request.getParameter("resolvidoEm_Ct" + ct.getId() + "idx" + o)));
                    oc.setResolucaoAs(request.getParameter("resolvidoAs_Ct" + ct.getId() + "idx" + o).equals("") ? null : formatadorHora.parse(request.getParameter("resolvidoAs_Ct" + ct.getId() + "idx" + o)));
                    oc.setObservacaoResolucao(request.getParameter("obsResolucao_Ct" + ct.getId() + "idx" + o));
                    oc.setOcorrenciaAs(request.getParameter("ocorrenciaAs_Ct"+ ct.getId() + "idx" + o) != null && !request.getParameter("ocorrenciaAs_Ct"+ ct.getId() + "idx" + o).equals("") ? formatadorHora.parse(request.getParameter("ocorrenciaAs_Ct"+ ct.getId() + "idx" + o)) : null);
                    arOcorrencia[pp] = oc;
                    pp++;
                }
            }
            ct.setOcorrenciaCtrc(arOcorrencia);
            arCtrc[k] = ct;
            //}
                    /*
             if (cfg.isObrigarOcorrenciaBaixCtrc() && (qtdOcorrencias == 0)){
             throw new Exception("É necessario incluir pelo menos uma ocorrência.");
             }*/
        }
        cadCtrc.setArrayBCtrc(arCtrc);


        boolean erroBaixar = !cadCtrc.atualizaFechamento(1, cfg);

        if (erroBaixar) {
            response.getWriter().append("<script>"
                    + "alert('" + cadCtrc.getErros() + "');"
                    + "window.opener.habilitaSalvar(true);"
                    + "window.close();"
                    + "</script>");
        } else {
            String scr = "<script>"
                    + "window.opener.document.location.replace(window.opener.document.location);"
                    + "window.close();"
                    + "</script>";

            response.getWriter().append(scr);
        }
        response.getWriter().close();
    } else if (acao.equals("baixarNotas")) {
        cadCtrc.setConexao(Apoio.getUsuario(request).getConexao());
        cadCtrc.setExecutor(Apoio.getUsuario(request));
        int idCtrc = Integer.parseInt(request.getParameter("idCtrc"));
        //BeanConhecimento[] arCtrc = new BeanConhecimento[1];
        //arCtrc[1].setId(idCtrc);


        int qtdNotas = Integer.parseInt(request.getParameter("qtdNotas"));

        int totalNF = Integer.parseInt(request.getParameter("totalNF_" + idCtrc));
        NotaFiscal[] arNf = new NotaFiscal[qtdNotas];

        NotaFiscal nf = null;

        int k = 0;
        for (int n = 0; n < totalNF; ++n) {
            if (request.getParameter("ckNf_" + idCtrc + "_" + n) != null) {
                nf = new NotaFiscal();
                nf.setIdconhecimento(idCtrc);
                nf.setIdnotafiscal(Integer.parseInt(request.getParameter("idNota_" + idCtrc + "_" + n)));//idNota_
                String dtChegada = request.getParameter("dtchegada_" + idCtrc + "_" + n);
                nf.setChegadaEm(dtChegada.equals("") ? null : formatador.parse(dtChegada)); //dtchegada_
                nf.setObservacaoBaixa(request.getParameter("obs_" + idCtrc + "_" + n)); //obs_
                String dtEntrega = request.getParameter("dtEntrega_" + idCtrc + "_" + n);
                nf.setEntregaEm(dtEntrega.equals("") ? null : formatador.parse(dtEntrega)); //dtEntrega_
                //nf.setValorAvaria(Float.parseFloat(valor.split(";")[k].split("_")[5]));
                nf.getOcorrencia().setId(Integer.parseInt(request.getParameter("idOcorrencia_" + idCtrc + "_" + n))); //idOcorrencia_
                String chegadaAs = request.getParameter("chegadaAs_" + idCtrc + "_" + n).trim();
                nf.setChegadaAs(chegadaAs.equals("") ? "0:00" : chegadaAs); //chegadaAs_
                String entregaAs = request.getParameter("entregaAs_" + idCtrc + "_" + n).trim();
                nf.setEntregaAs(entregaAs.equals("") ? "0:00" : entregaAs); //entregaAs_

                arNf[k] = nf;
                k++;
            }
        }
        cadCtrc.setArrayBNF(arNf);
        cadCtrc.setQtdNFBaixaIndividual(totalNF);
        //cadCtrc.setArrayBCtrc(arCtrc);

        boolean erroBaixar = !cadCtrc.atualizaFechamento(2, cfg);

        if (erroBaixar) {
            response.getWriter().append("<script>alert('" + cadCtrc.getErros() + "');</script>");
        } else {
            String scr = "<script>"
                    + "window.opener.document.location.replace(window.opener.document.location);"
                    + "window.close();"
                    + "</script>";

            response.getWriter().append(scr);
        }
        response.getWriter().close();

    } else if (acao.equals("excluir")) {
        cadCtrc.setConexao(Apoio.getUsuario(request).getConexao());
        cadCtrc.setExecutor(Apoio.getUsuario(request));
        ctrc.setId(Integer.parseInt(request.getParameter("id")));
        cadCtrc.setConhecimento(ctrc);

        boolean erroExcluir = cadCtrc.atualizaFechamento(2, cfg);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroExcluir) {
            response.getWriter().append("err<=>" + cadCtrc.getErros());
        } else {
            response.getWriter().append("err<=>");
        }
        response.getWriter().close();
    } else if (acao.equals("carregarOcorrencia")) {
        String resultado = "";
        BeanConsultaConhecimento conCt = new BeanConsultaConhecimento();
        conCt.setConexao(Apoio.getUsuario(request).getConexao());
        conCt.consultarOcorrencias(Integer.parseInt(request.getParameter("ctrcId")));
        ResultSet rs = conCt.getResultado();
        while (rs.next()) {
            resultado += (resultado.equals("") ? "" : "!!000!!")
                    + rs.getString("id") + "!!999!!"
                    + rs.getString("ocorrencia_ctrc_id") + "!!999!!"
                    + rs.getString("codigo_ocorrencia") + "-" + rs.getString("descricao_ocorrencia") + "!!999!!"
                    + (rs.getDate("ocorrencia_em") == null ? "" : formatador.format(rs.getDate("ocorrencia_em"))) + "!!999!!"
                    + (rs.getTime("ocorrencia_as") == null ? "" : formatadorHora.format(rs.getTime("ocorrencia_as"))) + "!!999!!"
                    + rs.getString("usuario_ocorrencia") + "!!999!!"
                    + rs.getString("observacao_ocorrencia") + "!!999!!"
                    + rs.getString("is_resolvido") + "!!999!!"
                    + (rs.getDate("resolucao_em") == null ? "" : formatador.format(rs.getDate("resolucao_em"))) + "!!999!!"
                    + (rs.getTime("resolucao_as") == null ? "" : formatadorHora.format(rs.getTime("resolucao_as"))) + "!!999!!"
                    + rs.getString("usuario_resolucao") + "!!999!!"
                    + rs.getString("observacao_resolucao") + "!!999!!"
                    + rs.getString("sale_id") + "!!999!!"
                    + rs.getBoolean("obriga_resolucao");

        }
        response.getWriter().append(resultado);
        response.getWriter().close();

    } else if (acao.equals("carregarNF")) {
        int idctrc = Integer.parseInt(request.getParameter("ctrcId"));
        String resultado = "<table width='100%' border='0' class='bordaFina'>"
                + "<tr class='tabela'>"
                + "<td width=\"2%\"><input name='ckNfTodos_" + idctrc + "' type='checkbox' id='ckNfTodos_" + idctrc + "' value='checkbox' onclick='marcarDemarcarNF(" + idctrc + ")';/></td>"
                + "<td width=\"6%\"><strong>N Fiscal</strong></td>"
                + "<td width=\"4%\"><strong>Série</strong></td>"
                + "<td width=\"7%\"><strong>Emissão</strong></td>"
                + "<td width=\"6%\"><strong>Valor</strong></td>"
                + "<td width=\"6%\"><strong>Peso</strong></td>"
                + "<td width=\"6%\"><strong>Volume</strong></td>"
                + "<td width=\"16%\"><strong>Chegada</strong></td>"
                + "<td width=\"21%\"><strong>OBS entrega</strong></td>"
                + "<td width=\"10%\"><strong>Ocorrência</strong></td>"
                + "<td width=\"16%\"><strong>Entrega</strong></td>"
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
            resultado += "<td> "
                    + "<input name='ckNf_" + idxNf + "' type='checkbox' id='ckNf_" + idxNf + "' value='checkbox'  " + (rs.getDate("entrega_em") != null ? "checked" : "") + "/>"
                    + "<input type='hidden' name='idNota_" + idxNf + "' id='idNota_" + idxNf + "' value='" + rs.getString("idnota_fiscal") + "' />"
                    + "<input type='hidden' name='idOcorrencia_" + idxNf + "' id='idOcorrencia_" + idxNf + "' value='" + rs.getString("ocorrencia_id") + "'/>"
                    + "<input type='hidden' name='baixaEm_" + idxNf + "' id='baixaEm_" + idxNf + "' value='" + (rs.getDate("baixado_no_dia") != null ? formatador.format(rs.getDate("baixado_no_dia")) : "") + "'/>"
                    + "<input type='hidden' name='baixaPor_" + idxNf + "' id='baixaPor_" + idxNf + "' value='" + rs.getString("usuario_baixa_id") + "'/>"
                    + "</td>"
                    + "<td>" + rs.getString("numero") + "</td>"
                    + "<td>" + rs.getString("serie") + "</td>"
                    + "<td>" + (rs.getDate("emissao") != null ? formatador.format(rs.getDate("emissao")) : "") + "</td>"
                    + "<td>" + Apoio.to_curr(rs.getFloat("valor")) + "</td>"
                    + "<td>" + Apoio.to_curr(rs.getFloat("peso")) + "</td>"
                    + "<td>" + Apoio.to_curr(rs.getFloat("volume")) + "</td>"
                    + "<td>"
                    + "<input class='fieldDate' name='dtchegada_" + idxNf + "' id='dtchegada_" + idxNf + "' "
                    + "value='" + (rs.getDate("chegada_em") != null ? formatador.format(rs.getDate("chegada_em")) : "") + "' "
                    + "type='text' size='9' style='font-size:8pt;'  maxlength='12' align='Right' onblur='alertInvalidDate(this, true)' onKeyDown='fmtDate(this, event)' onkeyUp='fmtDate(this, event)' onKeyPress='fmtDate(this, event)' />"
                    + " às "
                    + " <input class='inputtexto' name='chegadaAs_" + idxNf + "' type='text' id='chegadaAs_" + idxNf + "' "
                    + "style='font-size:8pt;' onkeyup='mascaraHora(this)' size='4' maxlength='5'  "
                    + "value='" + (rs.getString("chegada_as") != null ? rs.getString("chegada_as").substring(0, 5) : "") + "'/>"
                    + "</td>"
                    + "<td>"
                    + " <input class='inputtexto' name='obs_" + idxNf + "' id='obs_" + idxNf + "' "
                    + "value='" + rs.getString("observacao_entrega") + "' type='text' size='26' style='font-size:8pt;' maxlength='150' onBlur=\"javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');\">"
                    + "</td>"
                    + "<td>"
                    + " <input class='inputtexto' name='oco_" + idxNf + "' id='oco_" + idxNf + "' value='" + rs.getString("ocorrencia") + "' type='text' size='2' style='font-size:8pt;' maxlength='2' onChange=\"javascript:seNaoIntReset(this,'00');\">"
                    + " <font size='1'>"
                    + " <input name='botao_oco_" + idxNf + "' type='button' class='botoes' id='botao_oco_" + idxNf + "' value='...' onClick=\"javascript:localizaOcorrenciaNF(this,'" + idxNf + "');\">"
                    + " </font> "
                    + "</td>"
                    + "<td>"
                    + "<input class='fieldDate' name='dtEntrega_" + idxNf + "' id='dtEntrega_" + idxNf + "' "
                    + "value='" + (rs.getDate("entrega_em") != null ? formatador.format(rs.getDate("entrega_em")) : "") + "' "
                    + "type='text' size='9' style='font-size:8pt;'  maxlength='12' "
                    + "align='Right' onblur='alertInvalidDate(this, true)' "
                    + "onKeyDown='fmtDate(this, event)' "
                    + "onkeyUp='fmtDate(this, event)' onKeyPress='fmtDate(this, event)' />"
                    + " às "
                    + " <input class='inputtexto' name='entregaAs_" + idxNf + "' type='text' "
                    + "id='entregaAs_" + idxNf + "' style='font-size:8pt;' "
                    + "onkeyup='mascaraHora(this)' size='4' maxlength='5'  "
                    + "value='" + (rs.getString("entrega_as") != null ? rs.getString("entrega_as").substring(0, 5) : "") + "'/>"
                    + "</td>"
                    + "</tr>";
            row++;
        }
        resultado += "<tr>"
                + "<td colspan='11' class='CelulaZebra1'><div align='center'>"
                + "<input type='hidden' name='totalNF_" + idctrc + "' id='totalNF_" + idctrc + "' value='" + row + "' />"
                + "<input  name='Button' type='button' class='botoes' value='Baixar Notas Fiscais do CT-e' onClick='baixarNF(" + idctrc + ")'>"
                + "</div></td>"
                + "</tr>";
        resultado += "</table>";
        response.getWriter().append(resultado);
        response.getWriter().close();
    }

%>


<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    
    var ctrcAux = '0';
    var zebraAux = '1'
    var idxOco = 0;
    //removendo parametros do session
    window.onbeforeunload = function(e) {
        sessionStorage.removeItem('parametros');
    };

    function marcarDemarcarNF(ctrcId){
        for (ii = 0; ii <= 50 - 1; ++ii){
            if ($('ckNf_'+ctrcId+"_"+ii) != null){
                $('ckNf_'+ctrcId+"_"+ii).checked = $('ckNfTodos_'+ctrcId).checked;
            }
        }
    }

    function removerOcorrenciaAjax(idOco, idxCt, idxI){
        function sucesso(transport){
            var textoresposta = transport.responseText;
            console.log(transport);
            
            if (textoresposta.trim() == "OK"){
                Element.remove('trCt_'+idxCt+'idx'+idxI);
                $("qtdOcorrencia_"+idxCt).value = (parseInt($("qtdOcorrencia_"+idxCt).value)-1);
                alert("Ocorrência removida com sucesso.");
            }else{
                alert(textoresposta);
            }
        }
        function erro(){alert("Não foi possivel remover a ocorrência!");}
        tryRequestToServer(function(){new Ajax.Request("./bxctrc.jsp?acao=removerOcorrenciaAjax&idOcorrencia="+idOco+"&nivel=<%=nivelExcluirOcorrencia%>",{method:'post', onSuccess: sucesso, onError: erro});});
    }

    function consulta(){
        parent.document.location.replace("./consultaconhecimento?acao=iniciar");
    }
    function consultaProtocolo(){
        if (<%=nivelUserProtocolo == 0%>){
            alert('Você não tem privilégios suficientes para executar essa rotina!');
        }else{
            parent.document.location.replace("./ProtocoloControlador?acao=listar");
        }
    }
      
    function habilitaSalvar(opcao){
        getObj("salvar").disabled = !opcao;
        getObj("salvar").value = (opcao ? "Salvar CT-e(s) Selecionados" : "Enviando...");
    }

    function baixarNF(idctrc){
        var deuCerto = true;
        var qtdNotas = 0;

        var j = 0;
        while(getObj("dtEntrega_"+idctrc +"_"+ j) != null){
            
            

            if (getObj("ckNf_"+idctrc +"_"+ j).checked){
                if (getObj("dtEntrega_"+idctrc +"_"+ j).value.trim() != '' && ! validaData(getObj("dtEntrega_"+idctrc +"_"+ j).value) ){
                    deuCerto = false;
                    getObj("dtEntrega_"+idctrc +"_"+ j).style.background ="#FFE8E8";
                }else{
                    qtdNotas++;
                }
            }
            j++;
        }
        
        
        if(qtdNotas == 0){
            return alert("Selecione no mínimo uma nota fiscal.");
        }

    
        if (!deuCerto)
            alert('Informe todos os dados corretamente');
        else{
            $('formBx').action = "./bxctrc?acao=baixarNotas&qtdNotas="+qtdNotas + "&idCtrc="+idctrc;
            //habilitaSalvar(false);
            //submitPopupForm($('formBx'));
            window.open('about:blank', 'pop', 'width=210, height=100');
            $("formBx").submit();
        }
    }

    function salvar(linhas){
        var ids;
        var deuCerto = true;
        var existeCtrcSemOcorrencia = false;
        var emAberto= "";
        var isIncluirOcorrencia = <%=cfg.isObrigarOcorrenciaBaixCtrc()%>;
        var resultado = "";
        var qtdLin = 0;
        var i=0;
        var temNovaOcorrencia = false;
        try{
            
            for (i = 0; i <= linhas - 1; ++i){
                if (getObj("chk_"+i) != null) {
                    ids = getObj("chk_"+i).value
                    //Verificando se o check está marcado
                    if (getObj("chk_"+i).checked){
                        qtdLin++;
                        //verificando se a data de pagamento está válida
                        if (getObj("dtfechamento_"+ids).value.trim() != '' && ! validaData(getObj("dtfechamento_"+ids).value) ){
                            deuCerto = false;
                            getObj("dtfechamento_"+ids).style.background ="#FFE8E8";
                        }else{
                            //Começando a concatenação
                            if (resultado != "")
                                resultado += ";";
                                
                            resultado += ids + "_" + $("obs_"+ids).value + "_" + $("dtfechamento_"+ids).value +
                                "_" + $("dtchegada_"+ids).value + "_" + $("oco_"+ids).value + "_" +
                                $("valor_avaria_"+ids).value + "_" + $("chegadaAs_"+ids).value +
                                "_" + $("entregaAs_"+ids).value + "_"+ $("dtBaixadoNoDia_"+ids).value+ "_"+
                                $("comprovanteEntrega_"+ids).checked+"_"+
                                "_" + $("dtDescarrego_"+ids).value + "_"+ $("descarregoAs_"+ids).value+ "_"+
                                $("descarregoCobrado_"+ids).checked+"_"+ $("dtFimDescarrego_"+ids).value + "_" + $("fimDescarregoAs_"+ids).value;
                                
                            //se for obrigado incluir uma ocorrencia ao baixar, verifica se a mesma existe, desde que o CTRC esteja em aberto     
//                            temNovaOcorrencia == false;
                            for (var qtdCte = 0; qtdCte < idxOco; qtdCte++) {                                    
                                if ($("id_Ct"+ids+"idx"+qtdCte) != null && $("id_Ct"+ids+"idx"+qtdCte).value == 0) {
                                    temNovaOcorrencia = true;
                                    break;
                                }    
                            }                
                            
                            console.log("temNovaOcorrencia : " + temNovaOcorrencia);
                            
                            emAberto = $("emAberto_"+ids).value;
                            if(isIncluirOcorrencia && temNovaOcorrencia == false && emAberto=="t" && $("dtfechamento_"+ids).value.trim() != ''){
                                existeCtrcSemOcorrencia = true;
                            }
                        }
                    }
                }
            }
        }catch(ex){
            alert(ex);
        }
    
        if (!deuCerto)
            alert('Informe todos os dados corretamente!');
        else if(resultado == "")
            alert('Escolha no mínimo um CT-e!');
        else if(existeCtrcSemOcorrencia)
            alert("Não é possível baixar o CT-e sem ocorrência!");
        else{
            $('dados').value = resultado;
            $('qtdLinha').value = qtdLin;
            $('formBx').action = "./bxctrc?acao=baixar&qtdOco="+idxOco+"&"+concatFieldValue("ctrc_redespacho");
            habilitaSalvar(false);
            window.open('about:blank', 'pop', 'width=210, height=100');
            $("formBx").submit();
            //submitPopupForm($('formBx'));
        }
    }

    function mostraCombos(){
        getObj("mostrar").value = '<%=(request.getParameter("mostrar") == null ? "todos" : request.getParameter("mostrar"))%>';
        getObj("tipoNfCliente").value = '<%=(request.getParameter("tipoNfCliente") == null ? "numero" : request.getParameter("tipoNfCliente"))%>';
        getObj("filialOrigem").value = '<%=(request.getParameter("filialOrigem") == null ? "c" : request.getParameter("filialOrigem"))%>';
        getObj("anexos").value = '<%=(request.getParameter("anexos") == null ? "todos" : request.getParameter("anexos"))%>';
    }

    function visualizar(){
       
        var filtros = "";
        filtros = concatFieldValue("idremetente,rem_rzs,iddestinatario,dest_rzs,nmanif,ano,idfilial,fi_abreviatura," +
            "idfilial2,fi_abreviatura2,mostrar,notafiscal,ctrc,dtinicial,dtfinal,"+
            "ctrc_redespacho,idmotorista,motor_nome,tipoNfCliente,tipoTransporte,romaneio,serie_nf,numeroCarga,id_setor,setor,cteOuChave,filialOrigem,anexos,contratoFrete");
    
        //Apenas se os filtros estiverem corretos
        if (filtros.trim()!=''){
            location.replace("./bxctrc?acao=consultar&"+filtros+"&manif="+getObj("manif").checked + "&idconsignatario="+$("idconsignatario").value+"&con_rzs="+$("con_rzs").value);
        }
    }
    function verCtrc(id, tipo){
        if (tipo == 'ns'){
            window.open("./cadvenda.jsp?acao=editar&id="+id+"&ex=false", "Conhecimento" , "top=0,resizable=yes");
        }else{
            window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "Conhecimento" , "top=0,resizable=yes");
        }
    }

    function marcarDesmarcar(){
        var p = 0;
        while ($("chk_"+p) != null){
            $("chk_"+p).checked = $("marcar").checked;
            $("chk_"+p).onclick();
            p++
        }
    }
    function marcarDesmarcarComprovanteEntrega(){
        var p = 0;
            while ($("chk_"+p) != null){
                var campo = $("chk_"+p).value;
                $("comprovanteEntrega_"+campo).checked = $("comprovanteEntrega").checked;
                chkComprovanteEntrega($("comprovanteEntrega_"+campo));
                p++;
            }
        }

    /**
     * checa o campo automaricamente se a data não estiver vazia
     */
    function chkAutoComprovanteEntrega(elemento){
        var nivel = '<%= (nivelUserMarcarComprovanteBaixaEntradaCte) %>';
        if (nivel != 0) {
            var id = elemento.id.split("_")[1];
            var checar = (elemento.value != "");

            $("comprovanteEntrega_"+id).checked = checar;
            $("dtBaixadoNoDia_"+id).value = $("dtfechamento_"+id).value;
        
        }
    }
    
    function chkComprovanteEntrega(elemento){
        var id = elemento.id.split("_")[1];
        if($("comprovanteEntrega_"+id).checked && $("dtfechamento_"+id).value != ""){
            visivel($("divBaixadoNoDia_"+id));
            $("dtBaixadoNoDia_"+id).value = ($("dtBaixadoNoDia_"+id).value!="" ? $("dtBaixadoNoDia_"+id).value : $("dtfechamento_"+id).value);
        }else{
            invisivel($("divBaixadoNoDia_"+id));
            $("dtBaixadoNoDia_"+id).value = ($("dtBaixadoNoDia_"+id).value==""?"":$("dtBaixadoNoDia_"+id).value);
        }
    }

    //Atribuindo os valores para todas as linhas
    function atribuiValores(obj){
                
        var r = 0;
        var idCte = 0;
        while ($("chk_"+r) != null){
            idCte = $("chk_"+r).value;
            if($(obj+'_'+idCte)!=null){
                
                if (<%=nivelAlterarCTeEntregue == 4%> || (<%=nivelAlterarCTeEntregue == 0%> && $("emAberto_"+idCte).value == "t") 
                        || (obj == "dtFimDescarrego" || obj == "fimDescarregoAs" || obj == "dtDescarrego" || obj == "descarregoAs")) {
    
                    $(obj+'_'+$("chk_"+r).value).value=$(obj).value;
                    var id =$("chk_"+r).value;
                    var data = replaceAll(($("dtemissao_"+id).value), "'","")
                    validaDatas(data, id);
                }
                
                
            }
            ++r;
        }
    }
    
    //Atribuindo os valores para todas as linhas
    function atribuiOcorrencia(){
                
        var r = 0;
        var idCte;
        var horaOcorrencia = $("OcorrenciaAs").value+'';
        var dataOcorrencia = $("dtOcorrencia").value;
        
        while ($("chk_"+r) != null){
            idCte = $("chk_"+r).value;
            //Observação
            if($('obs_'+$("chk_"+r).value)!=null){
                if (<%=nivelAlterarCTeEntregue == 4%> || (<%=nivelAlterarCTeEntregue == 0%> && $("emAberto_"+idCte).value == "t")){
                    $('obs_'+$("chk_"+r).value).value=$("obs_topo").value;
                }
            }
            //Ocorrência
            if($('oco_'+$("chk_"+r).value)!=null){
                if (<%=nivelAlterarCTeEntregue == 4%> || (<%=nivelAlterarCTeEntregue == 0%> && $("emAberto_"+idCte).value == "t")){
                    $('oco_'+$("chk_"+r).value).value=$("oco_topo").value;
                    if ($("oco_topo").value != ''){                    
                    
                        addOcorrencia($("chk_"+r).value, 0, $("id_oco_topo").value, $("oco_topo").value + '-' + $("oco_topo_descricao").value,
                                      dataOcorrencia, horaOcorrencia,
                                      '<%=Apoio.getUsuario(request).getLogin()%>',$("obs_topo").value,false,'','','','',$("oco_topo_obriga_resolucao").value);                    
                    }
                }          
            }
            ++r;
        }
    }
 
    function localizaOcorrencia(obj, index){
        if (index == -1){
            $("ctrc_id").value = obj.name;
            post_cad = window.open('./localiza?acao=consultar&idlista=40','Ocorrencia',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');            
        }else{
            ctrcAux = obj.name;
            $("ctrc_id").value = obj.name;
            var paramAux = $("ctrc_id").value;

            if($("isOcorrenciaConsignatario_"+index).value == 'false' || $("isOcorrenciaConsignatario_"+index).value == 'f'){
                post_cad = window.open('./localiza?acao=consultar&idlista=40','Ocorrencia',
                'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');            
            }else if($("isOcorrenciaConsignatario_"+index).value == 'true' || $("isOcorrenciaConsignatario_"+index).value == 't'){
                post_cad = window.open('./localiza?acao=consultar&idlista=85&paramaux='+paramAux,'Ocorrencia_Cliente',
                'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
            }
        }
    }

    function localizaOcorrenciaNF(obj,idx){
        post_cad = window.open('./localiza?acao=consultar&idlista=40','OcorrenciaNF'+idx,
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela)
    {
        try{
            var dataOcorrencia;
            var horaOcorrencia;
        
            if ($("ocorrencia").value !== '001') {
                dataOcorrencia = '<%= Apoio.getDataAtual() %>';
                horaOcorrencia = '<%= Apoio.getHoraAtual() %>';
            } else {
                dataOcorrencia = ($("dtfechamento").value != '' ? $("dtfechamento").value :'<%= Apoio.getDataAtual() %>') ;
                horaOcorrencia = ($("entregaAs").value != '' ? $("entregaAs").value :'<%=new SimpleDateFormat("HH:mm").format(new Date())%>')
            }

            if ((idjanela == "Ocorrencia")){
                if ($("ctrc_id").value == 'bt_oco_topo'){
                    $('id_oco_topo').value = $("ocorrencia_id").value;
                    $('oco_topo').value = $("ocorrencia").value;
                    $('oco_topo_descricao').value = $("descricao_ocorrencia").value;
                    $('oco_topo_obriga_resolucao').value = $("obriga_resolucao").value;
                }else{
                    var campo = "oco_"+$("ctrc_id").value;
                    $(campo).value = $("ocorrencia").value;
                    addOcorrencia(ctrcAux, 0, $("ocorrencia_id").value,
                    $("ocorrencia").value + '-' + $("descricao_ocorrencia").value,
                    dataOcorrencia , horaOcorrencia,
                    '<%=Apoio.getUsuario(request).getLogin()%>',$("obs_"+$("ctrc_id").value).value,false,'','','','',$("obriga_resolucao").value);
                }    
            }else if(idjanela == "Ocorrencia_Ctrc"){
                addOcorrencia(ctrcAux, 0, $("ocorrencia_id").value,
                $("ocorrencia").value + '-' + $("descricao_ocorrencia").value,
                dataOcorrencia, horaOcorrencia,
                '<%=Apoio.getUsuario(request).getLogin()%>','',false,'','','','',$("obriga_resolucao").value);
            }else if(idjanela.split("NF")[0] == "Ocorrencia"){
                var idx = idjanela.split("NF")[1];
                $("oco_"+idx).value = $("ocorrencia").value;
                $("idOcorrencia_"+idx).value = $("ocorrencia_id").value;
            }else if ((idjanela == "Ocorrencia_Cliente")){
                var obsX = '';
                if ($("oco_"+$("ctrc_id").value) != null){
                    var campo = "oco_"+$("ctrc_id").value;
                    $(campo).value = $("ocorrencia").value;
                    obsX = $("obs_"+$("ctrc_id").value).value;
                }    
                addOcorrencia(ctrcAux, 0, $("ocorrencia_id").value,
                $("ocorrencia").value + '-' + $("descricao_ocorrencia").value,
                dataOcorrencia, horaOcorrencia,
                '<%=Apoio.getUsuario(request).getLogin()%>',obsX,false,'','','','',$("obriga_resolucao").value);
            }
        }catch(e){
            console.error(e);
        }
    }

    function mostrarOcorrencias(ctrcId, idx){
        if ($('chk_'+idx).checked){
            $('trOcorrenciaCtrc_'+ctrcId).style.display = "";
        }else{
            $('trOcorrenciaCtrc_'+ctrcId).style.display = "none";
        }
    }
  
    function novaOcorrencia(ctrc, zebra){
        ctrcAux = ctrc;
       
        if($("isOcorrenciaConsignatario_"+zebra).value == 'false' || $("isOcorrenciaConsignatario_"+zebra).value == 'f'){
            post_cad = window.open('./localiza?acao=consultar&idlista=40','Ocorrencia_Ctrc',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
        }else if($("isOcorrenciaConsignatario_"+zebra).value == 'true' || $("isOcorrenciaConsignatario_"+zebra).value == 't'){
            post_cad = window.open('./localiza?acao=consultar&idlista=85&paramaux='+ctrcAux,'Ocorrencia_Cliente',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
        }
    }

    function addOcorrencia(ctrc, id, ocorrencia_id, ocorrencia, ocorrenciaEm, ocorrenciaAs, usuarioOcorrencia,
    observacaoOcorrencia, isResolvido, resolvidoEm, resolvidoAs, usuarioResolucao,
    observacaoResolucao, obrigaResolucao){
        
       
        var isObrigaResolucao = (obrigaResolucao == 't' || obrigaResolucao == "true" || obrigaResolucao == true);
        var _tr = '';
        _tr = Builder.node('TR', {id:'trCt_'+ctrc+'idx'+idxOco, name:'trCt_'+ctrc+'idx'+idxOco, className:'CelulaZebra'+((zebraAux%2)==0 ? "1" : "2")},
        [Builder.node('TD',
            [Builder.node('IMG', {id:'excluirOcorrencia_Ct'+ctrc+'idx'+idxOco, src:'img/lixo.png', title:'Apagar ocorrência do CTRC.', className:'imagemLink',
                    onClick:'removerOcorrencia('+ctrc+','+idxOco+');'}),
                Builder.node('INPUT', {type:'hidden', name:'ocorrenciaId_Ct'+ctrc+'idx'+idxOco, id:'ocorrenciaId_Ct'+ctrc+'idx'+idxOco,
                    value:ocorrencia_id}),
                Builder.node('INPUT', {type:'hidden', name:'id_Ct'+ctrc+'idx'+idxOco, id:'id_Ct'+ctrc+'idx'+idxOco,
                    value:id}),
                Builder.node('INPUT', {type:'hidden', name:'ctrcId_Ct'+ctrc+'idx'+idxOco, id:'ctrcId_Ct'+ctrc+'idx'+idxOco,
                    value:ctrc})
            ]),
            Builder.node('TD',[
                Builder.node('IMG', {src:'img/page_edit.png', style: 'vertical-align:middle;cursor: pointer', onclick: 'montarDetalhesOcorrencia('+ctrc+','+id+','+ ocorrencia_id +');'})
            ]),
            Builder.node('TD',[
                Builder.node('IMG', {src:'img/pdf.jpg', style: 'vertical-align:middle;cursor: pointer', onclick: 'baixarRelatorioOcorrencia(' + id + ');'})
            ]),
            Builder.node('TD',
            [Builder.node('LABEL', {name:'ocorrencia_Ct'+ctrc+'idx'+idxOco, id:'ocorrencia_Ct'+ctrc+'idx'+idxOco}),
            ]),
            Builder.node('TD',
            [Builder.node('INPUT', {type:'text', name:'ocorrenciaEm_Ct'+ctrc+'idx'+idxOco, id:'ocorrenciaEm_Ct'+ctrc+'idx'+idxOco,
                    value:ocorrenciaEm, className:'fieldMin', size:'12', maxLength:'10',
                    onBlur:'alertInvalidDate($(\'ocorrenciaEm_Ct'+ctrc+'idx'+idxOco+'\'));',
                    onKeyDown:'fmtDate($(\'ocorrenciaEm_Ct'+ctrc+'idx'+idxOco+'\') , event);',
                    onKeyUp:'fmtDate($(\'ocorrenciaEm_Ct'+ctrc+'idx'+idxOco+'\') , event);',
                    onKeyPress:'fmtDate($(\'ocorrenciaEm_Ct'+ctrc+'idx'+idxOco+'\') , event);'}),
                Builder.node('BR'),
                Builder.node('INPUT', {type:'text', name:'ocorrenciaAs_Ct'+ctrc+'idx'+idxOco, id:'ocorrenciaAs_Ct'+ctrc+'idx'+idxOco,
                    value:ocorrenciaAs, className:'fieldMin', size:'6', maxLength:'5', onKeyUp:'mascaraHora(this)'})
            ]),
            Builder.node('TD',
            [Builder.node('LABEL', {name:'usuarioOcorrencia_Ct'+ctrc+'idx'+idxOco, id:'usuarioOcorrencia_Ct'+ctrc+'idx'+idxOco}),
            ]),
            Builder.node('TD',
            [Builder.node('TEXTAREA', {name:'obsOcorrencia_Ct'+ctrc+'idx'+idxOco, id:'obsOcorrencia_Ct'+ctrc+'idx'+idxOco,
                    className:'fieldMin', cols:'33', rows:'4'},observacaoOcorrencia)]),
            Builder.node('TD',
            [Builder.node('INPUT', {type:'checkbox', name:'isResolvido_Ct'+ctrc+'idx'+idxOco, id:'isResolvido_Ct'+ctrc+'idx'+idxOco,
                    value:isResolvido, className:'fieldMin',onClick:'resolveuOcorrencia('+ctrc+','+idxOco+');'}),
                Builder.node('BR'),
                Builder.node('INPUT', {type:'text', name:'resolvidoEm_Ct'+ctrc+'idx'+idxOco, id:'resolvidoEm_Ct'+ctrc+'idx'+idxOco,
                    value:resolvidoEm, className:'fieldMin', size:'12', maxLength:'10',
                    onBlur:'alertInvalidDate($(\'resolvidoEm_Ct'+ctrc+'idx'+idxOco+'\'),true);',
                    onKeyDown:'fmtDate($(\'resolvidoEm_Ct'+ctrc+'idx'+idxOco+'\') , event);',
                    onKeyUp:'fmtDate($(\'resolvidoEm_Ct'+ctrc+'idx'+idxOco+'\') , event);',
                    onKeyPress:'fmtDate($(\'resolvidoEm_Ct'+ctrc+'idx'+idxOco+'\') , event);'}),
                Builder.node('BR'),
                Builder.node('INPUT', {type:'text', name:'resolvidoAs_Ct'+ctrc+'idx'+idxOco, id:'resolvidoAs_Ct'+ctrc+'idx'+idxOco,
                    value:resolvidoAs, className:'fieldMin', size:'6', maxLength:'5', onKeyUp:'mascaraHora(this)'}),
            ]),
            Builder.node('TD',
            [Builder.node('LABEL', {name:'usuarioResolucao_Ct'+ctrc+'idx'+idxOco, id:'usuarioResolucao_Ct'+ctrc+'idx'+idxOco}),
            ]),
            Builder.node('TD',
            [Builder.node('TEXTAREA', {name:'obsResolucao_Ct'+ctrc+'idx'+idxOco, id:'obsResolucao_Ct'+ctrc+'idx'+idxOco,
                    className:'fieldMin', cols:'33', rows:'4'},observacaoResolucao)
            ])
        ]);

        $('TbOcorrenciaCtrc_'+ctrc).appendChild(_tr);

        //Atribuindo valores nas labels
        $('ocorrencia_Ct'+ctrc+'idx'+idxOco).innerHTML = ocorrencia;
        $('usuarioOcorrencia_Ct'+ctrc+'idx'+idxOco).innerHTML = usuarioOcorrencia;
        $('usuarioResolucao_Ct'+ctrc+'idx'+idxOco).innerHTML = usuarioResolucao;

        if (isResolvido){
            $('isResolvido_Ct'+ctrc+'idx'+idxOco).checked = true;
            $('obsResolucao_Ct'+ctrc+'idx'+idxOco).readOnly = false;
            $('resolvidoEm_Ct'+ctrc+'idx'+idxOco).readOnly = false;
            $('resolvidoAs_Ct'+ctrc+'idx'+idxOco).readOnly = false;
        }else{
            $('isResolvido_Ct'+ctrc+'idx'+idxOco).checked = false;
            $('obsResolucao_Ct'+ctrc+'idx'+idxOco).readOnly = true;
            $('resolvidoEm_Ct'+ctrc+'idx'+idxOco).readOnly = true;
            $('resolvidoAs_Ct'+ctrc+'idx'+idxOco).readOnly = true;
        }

        if (!isObrigaResolucao){
            $('obsResolucao_Ct'+ctrc+'idx'+idxOco).style.display = 'none';
            $('isResolvido_Ct'+ctrc+'idx'+idxOco).checked = true;
            $('isResolvido_Ct'+ctrc+'idx'+idxOco).style.display = 'none';
            $('resolvidoEm_Ct'+ctrc+'idx'+idxOco).style.display = 'none';
            $('resolvidoAs_Ct'+ctrc+'idx'+idxOco).style.display = 'none';
            $('usuarioResolucao_Ct'+ctrc+'idx'+idxOco).innerHTML = '';
        }
    
        if (id != '0'){
            //$('obsOcorrencia_Ct'+ctrc+'idx'+idxOco).readOnly = true;
            //$('obsOcorrencia_Ct'+ctrc+'idx'+idxOco).style.backgroundColor = '#FFFFF1';
            $('ocorrenciaEm_Ct'+ctrc+'idx'+idxOco).readOnly = true;
            $('ocorrenciaEm_Ct'+ctrc+'idx'+idxOco).style.backgroundColor = '#FFFFF1';
            $('ocorrenciaAs_Ct'+ctrc+'idx'+idxOco).readOnly = true;
            $('ocorrenciaAs_Ct'+ctrc+'idx'+idxOco).style.backgroundColor = '#FFFFF1';
        }
        idxOco++;
        $('qtdOcorrencia_'+ctrc).value = idxOco;
       
        zebraAux++;
        
        
    }
    
    function resolveuOcorrencia(ctrc, idx){
        if ($('isResolvido_Ct'+ctrc+'idx'+idx).checked){
            $('usuarioResolucao_Ct'+ctrc+'idx'+idx).innerHTML = '<%=Apoio.getUsuario(request).getLogin()%>';
            $('obsResolucao_Ct'+ctrc+'idx'+idx).readOnly = false;
            $('resolvidoEm_Ct'+ctrc+'idx'+idx).readOnly = false;
            $('resolvidoEm_Ct'+ctrc+'idx'+idx).value = '<%=Apoio.getDataAtual()%>';
            $('resolvidoAs_Ct'+ctrc+'idx'+idx).readOnly = false;
            $('resolvidoAs_Ct'+ctrc+'idx'+idx).value = '<%=new SimpleDateFormat("HH:mm").format(new Date())%>';
        }else{
            $('usuarioResolucao_Ct'+ctrc+'idx'+idx).innerHTML = '';
            $('obsResolucao_Ct'+ctrc+'idx'+idx).readOnly = true;
            $('resolvidoEm_Ct'+ctrc+'idx'+idx).readOnly = true;
            $('resolvidoEm_Ct'+ctrc+'idx'+idx).value = '';
            $('resolvidoAs_Ct'+ctrc+'idx'+idx).readOnly = true;
            $('resolvidoAs_Ct'+ctrc+'idx'+idx).value = '';
        }
    }

    function carregarOcorrencias(ctrcId,zebra){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var textoresposta = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (textoresposta == "-1"){
                alert('Houve algum problema ao requistar as ocorrências, favor informar manualmente.');
                return false;
            }else{
                var ocor = "";
                for (i = 0; i <= textoresposta.split('!!000!!').length - 1; ++i){
                    ocor =  textoresposta.split('!!000!!')[i];
                    addOcorrencia(ocor.split('!!999!!')[12], ocor.split('!!999!!')[0], ocor.split('!!999!!')[1],
                    ocor.split('!!999!!')[2], ocor.split('!!999!!')[3], ocor.split('!!999!!')[4],
                    ocor.split('!!999!!')[5],ocor.split('!!999!!')[6],
                    (ocor.split('!!999!!')[7] =='f' ? false : true), ocor.split('!!999!!')[8],
                    ocor.split('!!999!!')[9], ocor.split('!!999!!')[10], ocor.split('!!999!!')[11],ocor.split('!!999!!')[13]);
                    bloquearCampos();
                }
            }
        }//funcao e()
        espereEnviar("",true);
        $('mostrar_'+ctrcId).style.display = "none";
        zebraAux = zebra;
        tryRequestToServer(function(){
            new Ajax.Request("./bxctrc.jsp?acao=carregarOcorrencia&ctrcId="+ctrcId,{method:'post', onSuccess: e, onError: e});});
    }

    function carregarNF(ctrcId){
    <%if (cfg.isBaixaEntregaNota()) {%>
            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport){
                var textoresposta = transport.responseText;
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (textoresposta == "-1"){
                    return false;
                }else{
                    Element.show("notas_"+ctrcId);
                    $("notas_"+ctrcId).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
                }
            }//funcao e()

            tryRequestToServer(function(){
                new Ajax.Request("./bxctrc.jsp?acao=carregarNF&ctrcId="+ctrcId,{method:'post', onSuccess: e, onError: e});});

    <%}%>
        }

        function removerOcorrencia(ctrcId, idx){
            if (confirm("Deseja mesmo apagar a ocorrência desse CT-e?")){
                if (<%=nivelExcluirOcorrencia%> == 4){
                    var idOcorrencia = parseInt($("id_Ct"+ctrcId+"idx"+idx).value);
                    if (idOcorrencia != 0) {
                        removerOcorrenciaAjax(idOcorrencia, ctrcId, idx);
                        //Element.remove('trCt_'+ctrcId+'idx'+idx);
                        //$("qtdOcorrencia_"+ctrcId).value = (parseInt($("qtdOcorrencia_"+ctrcId).value)-1);
                    }else{
                        Element.remove('trCt_'+ctrcId+'idx'+idx);
                        $("qtdOcorrencia_"+ctrcId).value = (parseInt($("qtdOcorrencia_"+ctrcId).value)-1);                
                    }
                }else{
                    alert('ATENÇÃO: Você não tem privilégios suficientes para excluir uma ocorrência do CT-e. Para acessar essa rotina você deverá solicitar a permissão 356 ao usuário administrador de sua empresa.');
                }    
            }
        }

        function validaDatas(dtEmissao,id){
          
                
            var dataAtual = '<%=Apoio.getDataAtual()%>';
            dataAtual = new Date(dataAtual.substring(6,10),dataAtual.substring(3,5)-1,dataAtual.substring(0,2));
         
            var dataEmissao = new Date(dtEmissao.substring(6,10),dtEmissao.substring(3,5)-1,dtEmissao.substring(0,2));
         
            var dataEntrega = new Date($('dtfechamento_'+id).value.substring(6,10),$('dtfechamento_'+id).value.substring(3,5)-1,$('dtfechamento_'+id).value.substring(0,2));
         
            var dataChegada = new Date($('dtchegada_'+id).value.substring(6,10),$('dtchegada_'+id).value.substring(3,5)-1,$('dtchegada_'+id).value.substring(0,2));

           
           
            if($("data_menor_"+id).value == "'f'"){
                
                if ($('dtchegada_'+id).value != ''){
                    if (dataChegada.getTime() < dataEmissao.getTime()){
                        alert('A data de chegada não pode ser inferior a data de emissão.');
                        $('dtchegada_'+id).value = '';
                   
                    }else if(dataChegada.getTime() > dataAtual.getTime()){
                        alert('A data de chegada não pode ser superior a data atual.');
                        $('dtchegada_'+id).value = '';
                    
                    }
                }
                if ($('dtfechamento_'+id).value != ''){
             
                    if (dataEntrega.getTime() < dataEmissao.getTime()){
                        alert('A data de entrega não pode ser inferior a data de emissão.');
                        $('dtfechamento_'+id).value = '';
                    }else if (dataEntrega.getTime() < dataChegada.getTime()){
                        alert('A data de entrega não pode ser inferior a data de chegada.');
                        $('dtfechamento_'+id).value = '';
                    }else if (dataEntrega.getTime() > dataAtual.getTime()){
                        alert('A data de entrega não pode ser superior a data atual.');
                        $('dtfechamento_'+id).value = '';
                    }
                }
            }
        }
    
        function popImg(idconhecimento, numero, serie, data,filial, cliente, index){
            //var modelo = $("modelo").value;
            window.open('./ImagemControlador?acao=carregar&idconhecimento=' + idconhecimento + "&index=" + (index ? index : 0),
                'imagensConhecimento', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
        
        function localizaOcorrenciaCodigo(obj,idxCt,index){
        ctrcAux = obj.name;
        $("ctrc_id").value = obj.name;
        var paramAux = $("ctrc_id").value;

            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function e(transport){
                var resp = transport.responseText;
                console.log("resp="+resp);
                espereEnviar("",false);
                //se deu algum erro na requisicao...
                if (resp == 'null'){
                    alert('Erro ao localizar ocorrência!');
                    return false;
                }else if(resp == 'load=0' || resp == ''){
                    alert('Ocorrência Não encontrada!');
                    return false;
                }else{
                    var ocoControl = eval('('+resp+')');
                    
                    addOcorrencia(idxCt, 0, ocoControl.idOcorrencia, ocoControl.codigoOcorrencia + '-' + ocoControl.descricaoOcorrencia,
                                  ($("dtfechamento_"+idxCt)!= null && $("dtfechamento_"+idxCt).value != '' ? $("dtfechamento_"+idxCt).value : '<%= Apoio.getDataAtual() %>'), ($("entregaAs_"+idxCt)!= null && $("entregaAs_"+idxCt).value != ''? $("entregaAs_"+idxCt).value : '<%=new SimpleDateFormat("HH:mm").format(new Date())%>'),
                                  '<%=Apoio.getUsuario(request).getLogin()%>',$("obs_"+idxCt).value,false,'','','','',ocoControl.obrigaResolucaoOcorrencia);
                }
            }//funcao e()
            var carregarTudo;
            carregarTudo = ($("isOcorrenciaConsignatario_"+index).value == 'false' || $("isOcorrenciaConsignatario_"+index).value == 'f' ? "true" : "false");

            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("ConhecimentoControlador?acao=ajaxCarregarOcorrenciaCodigo&ocorrencia="+$('oco_'+idxCt).value+"&idSales="+idxCt+"&carregarTudo="+carregarTudo,{
                    method:'post', 
                    onSuccess: e, 
                    onError: e
                });

            }); 
        }
        
        function abrirLocalizaSetorEntrega(){
            launchPopupLocate('./localiza?acao=consultar&idlista=90', 'Setor_Entrega');
        }
        
        function contarCheckbox(){
            var total = 0;
            var p = 0;
            while ($("chk_"+p) != null){
                if($("chk_"+p).checked == true){
                    total++;
                }
                p++;
            }
            document.getElementById("qntdSelecionada").innerHTML = " Qtd selecionada: "+total;
        }
        
        function bloquearCampos(){
            var qtdCte = 0;
            var idCte;
            var qtdOcorrencia = 0;           
            
            if(<%=nivelAlterarCTeEntregue == 0%>){
                
                while ($("chk_"+qtdCte) != null) {
                    idCte = $("chk_"+qtdCte).value;               

                    if ($("dtfechamento_"+idCte).value != "" && $("emAberto_"+idCte).value == "f") {

                        $("dtfechamento_"+idCte).readOnly = true;
                        $("dtfechamento_"+idCte).className = "inputReadOnly8pt";
                        $("entregaAs_"+idCte).readOnly = true;
                        $("entregaAs_"+idCte).className = "inputReadOnly8pt";
                        $("obs_"+idCte).readOnly = true;
                        $("obs_"+idCte).className = "inputReadOnly8pt";
                        $("oco_"+idCte).readOnly = true;
                        $("oco_"+idCte).className = "inputReadOnly8pt";
                        $(idCte).style.display = "none";
                        $("dtchegada_"+idCte).readOnly = true;
                        $("dtchegada_"+idCte).className = "inputReadOnly8pt";
                        $("chegadaAs_"+idCte).readOnly = true;
                        $("chegadaAs_"+idCte).className = "inputReadOnly8pt";
                        $("addOcorrencia_"+idCte).style.display = "none";

                        if($("qtdOcorrencia_"+idCte) != null){
                            qtdOcorrencia = $("qtdOcorrencia_"+idCte).value;                        
                            for (var qtdOco = 0; qtdOco <= qtdOcorrencia; qtdOco++) {
                                if ($("ocorrenciaId_Ct"+idCte+"idx"+qtdOco) != null) {

                                    $("excluirOcorrencia_Ct"+idCte+"idx"+qtdOco).style.display = "none";    
                                    $("ocorrenciaEm_Ct"+idCte+"idx"+qtdOco).readOnly = true;
                                    $("ocorrenciaEm_Ct"+idCte+"idx"+qtdOco).className = "inputReadOnly8pt";
                                    $('ocorrenciaEm_Ct'+idCte+'idx'+qtdOco).style.backgroundColor = '';
                                    $('ocorrenciaAs_Ct'+idCte+'idx'+qtdOco).style.backgroundColor = '';
                                    $("ocorrenciaAs_Ct"+idCte+"idx"+qtdOco).readOnly = true;
                                    $("ocorrenciaAs_Ct"+idCte+"idx"+qtdOco).className = "inputReadOnly8pt";
                                    $("isResolvido_Ct"+idCte+"idx"+qtdOco).readOnly = true;
                                    $("isResolvido_Ct"+idCte+"idx"+qtdOco).disabled = true;
                                    $("resolvidoEm_Ct"+idCte+"idx"+qtdOco).readOnly = true;
                                    $("resolvidoEm_Ct"+idCte+"idx"+qtdOco).className = "inputReadOnly8pt";
                                    $("resolvidoAs_Ct"+idCte+"idx"+qtdOco).readOnly = true;
                                    $("resolvidoAs_Ct"+idCte+"idx"+qtdOco).className = "inputReadOnly8pt";

                                }
                            }                        
                        }                    
                    }          

                    qtdCte++;                

                }                
            }
        }
        var lastScroll;
        function montarDetalhesOcorrencia(idCte,idOcorrencia, idOcorrenciaCtrc){
//            var data = {
//                numeroCte : 514, filial : 'Matriz', emissao : '28/05/2018',
//                remetente : 'José da Silva', destinatario : 'Casas Bahia', origem : 'Recife/PE',destino: 'Maceió/AL', 
//                ocorrencia : {
//                    codigo: '040',
//                    ocorrencia : 'Teste Ocorrencia',
//                    causa_ocorrencia : 'Teste Causa',
//                    consequencia_ocorrencia : 'Teste Consequencia',
//                    tipo_negociacao_ocorrencia : ''
//                },
//                notas : {
//                    nota1 : {numero:1},
//                    nota2 : {numero:2}
//                }
//            };

//            var r = String(Math.random()).split('.')[1];
//            sessionStorage.setItem(r,JSON.stringify(data));
//            jQuery('.container-detalhes-ocorrencia').load('${homePath}/gwTrans/modals/modal-detalhes-ocorrencia.jsp', {idOcorrencia : id});

            lastScroll = jQuery('body').scrollTop();
            jQuery('body').scrollTop(0);
            
            var object = jQuery('<object>').attr('width','950').attr('height','700').attr('data','${homePath}/gwTrans/modals/modal-detalhes-ocorrencia.jsp?idCte='+idCte+'&idOcorrencia=' + idOcorrencia + '&idOcorrenciaCtrc=' + idOcorrenciaCtrc);
            jQuery('.container-detalhes-ocorrencia').html(object);
            
            jQuery('.cobre-tudo').show();
            jQuery('.container-detalhes-ocorrencia').show();
            jQuery("body").css("overflow", "hidden");
            
        }
        
        function finalizarOcorrencia(){
            jQuery('body').scrollTop(lastScroll);
            jQuery("body").css("overflow", "");
            jQuery('.cobre-tudo').hide();
            jQuery('.container-detalhes-ocorrencia').hide();
            jQuery('.container-detalhes-ocorrencia').html('');
        }

        function launchPDF(url, idname) {
            var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
            var pdf = window.open(url, idname, cf);
            pdf.window.resizeTo(screen.width, screen.height - 20);
            pdf.focus();
        }

        function baixarRelatorioOcorrencia(idOcorrencia) {
            launchPDF('./RelatorioControlador?acao=imprimirRelatorioOcorrencia&modelo=1&id=' + idOcorrencia, 'ocorrencia' + idOcorrencia);
        }
        
        /**
         * Funcao utilziada para atualizar a quantidade de anexos
         * @@param {index} linha a ser alterada 
         * @@param {qtd_anexos} quantidade a ser atualizada
         */
        function atualizarQtdAnexos(index, qtd_anexos) {
            document.getElementById('qtd-anexos-'+index).innerHTML = qtd_anexos;
        }
        
         jQuery(() => {
            <%
                if(acao.equals("baixaCteManifesto")){
            %>
                visualizar();
            <%
                }
            %>
        });
       
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Baixa de CT-e</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .styleVermelho {color: #FF0000}
            .styleAzul {color: #0000FF}
            -->
        </style>
    </head>

    <body onLoad="mostraCombos();$('ctrc').select();bloquearCampos();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idremetente" id="idremetente" value="<%=(request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0")%>">
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=(request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0")%>">
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(request.getParameter("idfilial") != null ? request.getParameter("idfilial") : "0")%>">
            <input type="hidden" name="idfilial2" id="idfilial2" value="<%=(nivelUserFl == 0 ? Apoio.getUsuario(request).getFilial().getIdfilial() + "" : (request.getParameter("idfilial2") != null ? request.getParameter("idfilial2") : "0"))%>">
            <input type="hidden" id="idmotorista" value="<%=(request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0")%>">
            <input type="hidden" id="ctrc_id" name="ctrc_id" value="0">
            <input type="hidden" id="ocorrencia" name="ocorrencia" value="">            
            <input type="hidden" id="ocorrencia_id" name="ocorrencia_id" value="">
            <input type="hidden" id="descricao_ocorrencia" name="descricao_ocorrencia" value="">
            <input type="hidden" id="obriga_resolucao" name="obriga_resolucao" value="">
            <input type="hidden" id="cliente_id" name="cliente_id" value="">
            <input type="hidden" id="consignatario_id" name="consignatario_id" value="">
            <input type="hidden" id="qtde_linhas" name="qtde_linhas" value="">
        </div>
        <table width="70%" height="28" align="center" class="bordaFina" >
            <tr>
                <td width="72%" >
                    <b>Baixar Manifesto e/ou CT-e</b>
                </td>
                <td width="14%">
                    <b>
                        <input  name="ButtonProtocolo" type="button" class="botoes" value="Incluir Protocolo de Entrega" onClick="consultaProtocolo()  ">
                    </b>
                </td>
                <td width="14%">
                    <b>
                        <input  name="Button" type="button" class="botoes" value="Ir Para Consulta de CT-e" onClick="consulta()">
                    </b>
                </td>
            </tr>
        </table>

        <br>

        <table width="100%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td colspan="9"> 
                    <div align="center">Filtros</div>
                    <div align="center"></div>
                </td>
            </tr>
            <tr>
                <td width="10%" class="TextoCampos">Emiss&atilde;o entre: </td>
                <td width="25%" class="Celulazebra2">
                    <span class="CelulaZebra2">
                        <strong>
                            <input name="dtinicial" type="text" id="dtinicial" value="<%=(request.getParameter("dtinicial") == null ? Apoio.getDataAtual() : request.getParameter("dtinicial"))%>" size="9" maxlength="10" class="fieldDate"
                                   onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        </strong>e
                        <strong>
                            <input name="dtfinal" type="text" id="dtfinal" value="<%=(request.getParameter("dtfinal") == null ? Apoio.getDataAtual() : request.getParameter("dtfinal"))%>" size="9" maxlength="10" class="fieldDate"
                                   onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        </strong>
                    </span>
                </td>
                <td width="15%" class="TextoCampos">Mostrar:</td>
                <td colspan="1" class="CelulaZebra2">
                    <span class="Celulazebra2">
                        <select name="mostrar" id="mostrar" class="inputtexto">
                            <option value="todos">Todos CT-e(s)</option>
                            <option value="false">CT-e(s) em aberto</option>
                            <option value="true">CT-e(s) Entregues</option>
                        </select>
                    </span>
                </td>
                <!--History 333 -->
                <td colspan="1" class="TextoCampos">Anexos:</td>
                <td colspan="1" class="CelulaZebra2">
                    <span class="Celulazebra2">
                        <select name="anexos" id="anexos" class="inputtexto">
                            <option value="todos">Todos CT-e(s)</option>
                            <option value="false">Apenas Com Anexo</option>
                            <option value="true">Apenas Sem Anexo</option>
                        </select>
                    </span>
                </td>
                <td colspan="3" class="CelulaZebra2">
                    <div align="center">
                        <input name="manif" type="checkbox" id="manif" value="checkbox" <%=(request.getParameter("manif") == null ? "" : (Boolean.parseBoolean(request.getParameter("manif")) ? "checked" : ""))%>>
                        Mostrar apenas CT-e(s) manifestados
                    </div>
                </td>
            </tr>
            <tr>
                <td width="10%" class="TextoCampos">Remetente:</td>
                <td width="25%" class="Celulazebra2">
                    <strong>
                        <input name="rem_rzs" type="text" class="inputReadOnly8pt" id="rem_rzs"  value="<%=(request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "")%>" size="30" maxlength="80" readonly="true">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=3&telaConsulta=baixaCtrcManifesto','Remetente')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('rem_rzs').value = '';javascript:getObj('idremetente').value = '0';">
                    </strong>
                </td>
                <td width="10%" class="TextoCampos">Destinat&aacute;rio:</td>
                <td width="25%" class="CelulaZebra2">
                    <strong>
                        <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly8pt" value="<%=(request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "")%>" size="30" maxlength="80" readonly="true">
                        <input name="localiza_dest" type="button" class="botoes" id="localiza_dest" value="..." onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=4&telaConsulta=baixaCtrcManifesto','Destinatario')">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('dest_rzs').value = '';javascript:getObj('iddestinatario').value = '0';">
                    </strong>
                </td>
                <td width="15%" class="TextoCampos"> Apenas o setor de entrega : </td>
                <td colspan="5" class="CelulaZebra2">
                    <input name="setor" type="text"  class="inputReadOnly8pt" id="setor" size="20" value="<%=(request.getParameter("setor") != null ? request.getParameter("setor") : "")%>" readonly="true">
                    <input name="bairro_setor" type="hidden" id="bairro_setor" value="<%= (request.getParameter("bairro_setor")!= null ? request.getParameter("bairro_setor") : "") %>">
                    <input name="cidade_setor" type="hidden"  id="cidade_setor" value="<%= (request.getParameter("cidade_setor")!= null ? request.getParameter("cidade_setor") : "") %>">                    
                    <input name="id_setor" type="hidden"  id="id_setor" value="<%= (request.getParameter("id_setor")!= null ? request.getParameter("id_setor") : "") %>">                    
                    <input name="localiza_setor" type="button" class="botoes" id="localiza_setor" value="..." onclick="javascript:tryRequestToServer(function(){abrirLocalizaSetorEntrega()});">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Setor" onClick="javascript:getObj('setor').value = '';javascript:getObj('id_setor').value = '';">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Consignat&aacute;rio:</td>
                <td class="CelulaZebra2">
                    <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0")%>">
                    <input name="con_rzs" type="text"  class="inputReadOnly8pt" id="con_rzs" size="30" value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>" readonly="true">
                    <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=5&telaConsulta=baixaCtrcManifesto','Cliente')" value="...">
                    <strong>
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idconsignatario').value = 0;javascript:getObj('con_rzs').value = '';">
                    </strong>
                </td>
                <td class="TextoCampos">
                    <span class="Celulazebra2">
                        <select name="cteOuChave" id="cteOuChave" class="inputtexto" style="width: 110px">
                            <option value="1" <%=(request.getParameter("cteOuChave") != null ? (request.getParameter("cteOuChave").equals("1") ? "selected" : ""):"selected")%>>Apenas o CT-e</option>
                            <option value="2" <%=(request.getParameter("cteOuChave") != null ? (request.getParameter("cteOuChave").equals("2") ? "selected" : ""):"")%>>Apenas o CT-e (Chave de acesso)</option>
                        </select>:
                    </span>
                </td>
                <td colspan="2" class="CelulaZebra2">
                    <strong>
                        <input name="ctrc" type="text" id="ctrc" onkeyup="javascript:if (event.keyCode==13) $('visualizar').click(); " class="fieldMin" value="<%=(request.getParameter("ctrc") != null ? request.getParameter("ctrc") : "")%>" size="50">
                    </strong>
                </td>
                <td class="TextoCampos">Apenas o Romaneio:</td>
                <td class="Celulazebra2">
                    <input name="romaneio" type="text" id="romaneio" class="fieldMin" value="<%=(request.getParameter("romaneio") != null ? request.getParameter("romaneio") : "")%>" size="7" maxlength="80">
                </td>
            </tr>
            <tr>
                <td width="10%" class="TextoCampos">Motorista:</td>
                <td class="Celulazebra2">
                    <strong>
                        <input name="motor_nome" type="text"  class="inputReadOnly8pt" id="motor_nome" size="30" value="<%=(request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "")%>" readonly="true">
                        <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                        <strong>
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
                        </strong>
                    </strong>
                </td>
                <td width="8%" class="TextoCampos">
                    <span class="Celulazebra2">
                        <select name="tipoNfCliente" id="tipoNfCliente" class="inputtexto">
                            <option value="numero" selected="selected">NF Cliente</option>
                            <option value="pedido">Pedido</option>
                        </select>:
                    </span>
                </td>
                <td width="10%" colspan="2" class="Celulazebra2">
                        <input name="notafiscal" type="text" id="notafiscal" class="fieldMin" value="<%=(request.getParameter("notafiscal") != null ? request.getParameter("notafiscal") : "")%>" size="50" >
                        <input name="serie_nf" type="text" id="serie_nf" class="fieldMin" value="<%=(request.getParameter("serie_nf") != null ? request.getParameter("serie_nf") : "")%>" size="1" maxlength="3">
                </td>
                <td width="15%" class="TextoCampos">CT-e Redespacho:</td>
                <td width="12%" class="CelulaZebra2">
                    <input name="ctrc_redespacho" type="text" id="ctrc_redespacho" class="fieldMin" value="<%=(request.getParameter("ctrc_redespacho") != null ? request.getParameter("ctrc_redespacho") : "")%>" size="7" maxlength="80">
                </td>
            </tr>
            <tr>
                <td height="22" class="TextoCampos">Manifesto:</td>
                <td colspan="3" class="TextoCampos"> 
                    <div align="left">
                        <input name="nmanif" type="text" id="nmanif" class="fieldMin" value="<%=(request.getParameter("nmanif") != null ? request.getParameter("nmanif") : "")%>" size="6" maxlength="6">
                        ano:
                        <strong>
                            <input name="ano" type="text" id="ano" class="fieldMin" value="<%=(request.getParameter("ano") != null ? request.getParameter("ano") : "")%>" size="4" maxlength="80">
                        </strong>
                        <!--Filial Origem:-->
                        <select id="filialOrigem" name="filialOrigem" class="inputtexto" style="width: 130px">
                            <option value="c">Filial Origem CT-e</option>
                            <option value="m">Filial Origem Manifesto</option>
                        </select>
                        <strong>
                            <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly8pt" value="<%=(request.getParameter("fi_abreviatura") != null ? request.getParameter("fi_abreviatura") : "")%>" size="14" maxlength="80" readonly="true">
                            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=8','Filial')">
                        </strong>
                        <strong>
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('fi_abreviatura').value = '';javascript:getObj('idfilial').value = '0';"></strong>Filial
                        Destino:
                        <strong>
                            <input name="fi_abreviatura2" type="text" id="fi_abreviatura2" class="inputReadOnly8pt" value="<%=(nivelUserFl == 0 ? Apoio.getUsuario(request).getFilial().getAbreviatura() : (request.getParameter("fi_abreviatura2") != null ? request.getParameter("fi_abreviatura2") : ""))%>" size="14" maxlength="80" readonly="true">
                            <%if (nivelUserFl > 0) {%>
                            <input name="localiza_filial2" type="button" class="botoes" id="localiza_filial2" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=17','Filial')">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('fi_abreviatura2').value = '';javascript:getObj('idfilial2').value = '0';">
                            <%}%>
                        </strong>
                    </div>
                </td>
                <td class="TextoCampos">
                    Apenas a Carga:
                </td>
                <td class="CelulaZebra2">
                        <input name="numeroCarga" type="text" id="numeroCarga" class="fieldMin" value="<%=(request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga") : "")%>" size="14" maxlength="80">
                </td>        
                <td colspan="3" class="Celulazebra2">
                    <div align="center">
                    <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:'160px';"   class="fieldMin">
                        <%= emiteRodoviario && emiteAereo && emiteAquaviario? "<option value='false'" + (request.getParameter("tipoTransporte") == null || request.getParameter("tipoTransporte").equals("false") ? "selected" : "") + ">Todos os Modais</option>" : ""%>
                        <%= emiteRodoviario ? "<option value='r'" + (request.getParameter("tipoTransporte") != null && request.getParameter("tipoTransporte").equals("r") ? "selected" : "") + ">CTR - Transp. Rodoviário</option>" : ""%>
                        <%= emiteAereo ? "<option value='a'" + (request.getParameter("tipoTransporte") != null && request.getParameter("tipoTransporte").equals("a") ? "selected" : "") + " >CTA - Transp. A&eacute;reo</option>" : ""%>
                        <%= emiteAquaviario ? "<option value='q'" + (request.getParameter("tipoTransporte") != null && request.getParameter("tipoTransporte").equals("q") ? "selected" : "") + ">CTQ - Transp. Aquavi&aacute;rio</option>" : ""%>
                    </select>
                    </div>
                </td>
            </tr>
            <tr>
                <td width="14%" class="TextoCampos ">Apenas o Contrato de Frete:</td>
                <td width="6%" class="CelulaZebra2" colspan="7">
                    <input type="text" name="contratoFrete" id="contratoFrete" class="fieldMin" size="10" 
                           value="<%=(request.getParameter("contratoFrete") != null ? request.getParameter("contratoFrete") : 0)%>">
                </td>
            </tr>
            <tr>
                <td height="22" colspan="9" class="TextoCampos">
                    <div align="center">
                        <% if (nivelUserBaixa >= 1) {%>
                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
        <form method="post" id="formBx" target="pop">
            <table width="100%" border="0" class="bordaFina">
                <tr class="tabela">
                    <td width="2%">
                            <input name="marcar" type="checkbox" id="marcar" value="checkbox" onClick="javascript:marcarDesmarcar();">
                            <input type="hidden" id="dados" name="dados" value="">
                    </td>
                    <td width="2%">&nbsp;</td>
                    <td width="7%"><strong>CT-e</strong></td>
                    <td width="22%"><strong>Remetente/Destinatário</strong></td>
                    <td width="2%"><strong>UF</strong></td>
                    <td width="15%"><strong>Chegada</strong></td>
                    <td width="15%"><strong>Início Descarrego<br/>/ Fim Descarrego</strong></td>
                    <td width="15%"><strong>OBS entrega</strong></td>
                    <td width="15%"><strong>Entrega</strong></td>
                    <td width="5%"><strong>Avaria</strong></td>
                </tr>
                <tr class="tabela">
                    <td colspan="5">
                        <font size="1" class="styleVermelho">
                            <div align="right">Para repetir a Data clique na imagem
                                <img src="img/add.gif" border="0" style="vertical-align:middle;">
                                ao lado do campo:
                            </div>
                        </font>
                    </td>
                    <td>
                        <input name="dtchegada" id="dtchegada" value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin"  maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        <font size="1">
                        às
                        </font>
                        <input name="chegadaAs" type="text" id="chegadaAs" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value=""/>
                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;"
                             onClick="javascript:atribuiValores($('dtchegada').name);atribuiValores($('chegadaAs').name);">
                    </td>
                    <td>
                        <input name="dtDescarrego" id="dtDescarrego" value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin" maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        <font size="1">
                        às
                        </font>
                        <input name="descarregoAs" type="text" id="descarregoAs" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value=""/>
                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink"
                             onClick="javascript:atribuiValores($('dtDescarrego').name);atribuiValores($('descarregoAs').name);" style="vertical-align:middle;">
                        <br/>
                        <!--  Data e hora Fim Descarrego   -->
                        <input name="dtFimDescarrego" id="dtFimDescarrego" value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin" maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        <font size="1">
                        às
                        </font>
                        <input name="fimDescarregoAs" type="text" id="fimDescarregoAs" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value=""/>
                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink"
                             onClick="javascript:atribuiValores($('dtFimDescarrego').name);atribuiValores($('fimDescarregoAs').name);" style="vertical-align:middle;">
                    </td>
                    <td>
                        <input name="obs_topo" id="obs_topo" value="" type="text" size="24" maxlength="150" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');" class="fieldMin">
                        <label>Ocorr&ecirc;ncia:</label>
                        <input name="id_oco_topo" id="id_oco_topo" value="" type="hidden" size="2" class="inputReadOnly8pt" maxlength="3" onChange="javascript:seNaoIntReset(this,'');" onKeyUp="" readonly>
                        <input name="oco_topo_descricao" id="oco_topo_descricao" value="true" type="hidden" size="2" class="inputReadOnly8pt" maxlength="3" onChange="javascript:seNaoIntReset(this,'');" onKeyUp="" readonly>
                        <input name="oco_topo_obriga_resolucao" id="oco_topo_obriga_resolucao" value="true" type="hidden" size="2" class="inputReadOnly8pt" maxlength="3" onChange="javascript:seNaoIntReset(this,'');" onKeyUp="" readonly>
                        <input name="oco_topo" id="oco_topo" value="" type="text" size="2" class="inputReadOnly8pt" maxlength="3" onChange="javascript:seNaoIntReset(this,'');" onKeyUp="" readonly>
                        <font size="1" class="<%=isCancelado ? "styleVermelho" : ""%>">
                        <input type="button" class="botoes" id="bt_oco_topo" name="bt_oco_topo" value="..." onClick="javascript:localizaOcorrencia(this, -1);">
                        <input name="dtOcorrencia" id="dtOcorrencia" value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin" maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                         <font size="1">
                        às
                        </font>
                        <input name="OcorrenciaAs" type="text" id="OcorrenciaAs" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value=""/>
                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink"
                             onClick="javascript:atribuiOcorrencia();" style="vertical-align:middle;">
                    </td>
                    <td>
                        <input name="dtfechamento" id="dtfechamento" value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin" maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                         <font size="1">
                        às
                        </font>
                        <input name="entregaAs" type="text" id="entregaAs" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value=""/> <br/>
                        <label><input type="checkbox" id="comprovanteEntrega" name="comprovanteEntrega" class="checkbox">Comprov. entrega </label>
                        <img src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink"
                             onClick="javascript:atribuiValores($('dtfechamento').name);atribuiValores($('entregaAs').name);marcarDesmarcarComprovanteEntrega()" style="vertical-align:middle;">
                    </td>
                    <td></td>
                    <td></td>
                </tr>
                <% //variaveis da paginacao
                    int linha = 0;
                    // se conseguiu consultar
                    if ((acao.equals("consultar")) && (conCtrc.consultarFechamento(Integer.parseInt(request.getParameter("idremetente")),
                            Integer.parseInt(request.getParameter("iddestinatario")),
                            request.getParameter("nmanif"),
                            request.getParameter("ano"),
                            Integer.parseInt(request.getParameter("idfilial")),
                            Integer.parseInt(request.getParameter("idfilial2")),
                            request.getParameter("mostrar"),
                            Boolean.parseBoolean(request.getParameter("manif")),
                            request.getParameter("notafiscal"),
                            request.getParameter("tipoNfCliente"),
                            request.getParameter("ctrc"),
                            request.getParameter("cteOuChave"),
                            request.getParameter("ctrc_redespacho"),
                            Integer.parseInt(request.getParameter("idmotorista")),
                            request.getParameter("tipoTransporte"),
                            (request.getParameter("idconsignatario") != null ? Integer.parseInt(request.getParameter("idconsignatario")) : 0),
                            request.getParameter("romaneio"),
                            (request.getParameter("id_setor")),
                            request.getParameter("filialOrigem"),
                            request.getParameter("anexos"),
                            Apoio.parseInt(request.getParameter("contratoFrete"))))) {
                        
                        //Apenas as duplicatadas agora
                        ResultSet rs = conCtrc.getResultado();

                        while (rs.next()) {
                            emAberto = rs.getBoolean("emaberto");
                            isCancelado = rs.getBoolean("is_cancelado");
                            //pega o resto da divisao e testa se é par ou impar
                %>          
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <input type="hidden" id="isOcorrenciaConsignatario_<%=linha%>" name="isOcorrenciaConsignatario_<%=linha%>" value="<%=rs.getString("is_ocorrencias_especificas_cliente")%>">
                        
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                        <%if (nivelUserBaixa > 1 && !isCancelado) {%>
                        <input name="chk_<%=linha%>" id="chk_<%=linha%>" type="checkbox" value="<%=rs.getString("id")%>" onClick="javascript:mostrarOcorrencias('<%=rs.getString("id")%>','<%=linha%>'); contarCheckbox();"  <%=((emAberto == false && nivelUserBaixa < 4) ? "disabled=true" : "")%>>

                        <input name="emAberto_<%=rs.getString("id")%>" id="emAberto_<%=rs.getString("id")%>" type="hidden" value="<%=rs.getString("emaberto")%>" >
                        <%}%>   		      
                    </td>
                    <td align="center">
                        <img src="img/jpg.png" width="25" height="25" border="0" align="right" class="imagemLink" title="Imagens de documentos"
                             onClick="tryRequestToServer(function(){popImg('<%=rs.getString("id")%>','<%=rs.getString("numero")%>','<%=rs.getString("serie")%>','<%=formatador.format(rs.getDate("emissao_em"))%>','<%=rs.getString("abreviatura")%>','<%=rs.getString("consignatario")%>','<%=linha%>');});"
                             style="float: unset;">
                        <c:set var="qtd_anexos" value='<%= rs.getInt("qtd_anexos") %>'></c:set>
                        <span id="qtd-anexos-<%=linha%>">${qtd_anexos}</span>
                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho" : ""%>">
                        <font size="1">
                        <%if (nivelUser > 0) {%>
                        <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("id")%>','<%=rs.getString("categoria")%>');});">
                            <font size="1">
                            <%=rs.getString("numero") + "/" + rs.getString("serie")%>
                            </font>
                        </div>
                        <%} else {%>
                        <div>
                            <font size="1">
                            <%=rs.getString("numero") + "/" + rs.getString("serie")%>
                            </font>
                        </div>
                        <%}%>
                        <%=rs.getString("abreviatura")%><br>
                        <%=rs.getString("descricao_tipo_conhecimento")%>
                        <%if (!isCancelado) {%>
                        <%if (emAberto) {%>
                        <%} else {%>
                        <br><b>BAIXADO</b>
                        <%}
                        } else {%>
                        <br>CANCELADO
                        <%}%>
                        </font>
                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%> <%=isCancelado ? "styleVermelho" : ""%>">
                        <font size="1">
                        <b>DATA:</b><%=formatador.format(rs.getDate("emissao_em"))%><br>
                        <b>REM:</b><%=rs.getString("remetente")%><br>
                        <b>DES:</b><%=rs.getString("destinatario")%><br>
                        NF(s):<%=rs.getString("notas")%><%=(rs.getInt("qtd_notas") > 5 ? " ..." : "")%>
                        <%if (cfg.isBaixaEntregaNota() && rs.getInt("qtd_notas") > 1){%>
                        <br>
                        <span class="linkEditar" onClick="javascript:carregarNF('<%=rs.getString("id")%>');" name="carregarNF_<%=rs.getString("id")%>" id="carregarNF_<%=rs.getString("id")%>">Baixar NF(s) individualmente</span>
                        <%}%>
                        </font>
                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                        <font size="1" class="<%=isCancelado ? "styleVermelho" : ""%>"><%=rs.getString("uf_destinatario")%></font>
                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>"<%=isCancelado ? "styleVermelho" : ""%>>
                        <font size="1" class="<%=isCancelado ? "styleVermelho" : ""%>">
                        <input name="dtchegada_<%=rs.getString("id")%>" id="dtchegada_<%=rs.getString("id")%>"
                               class="fieldMin" value="<%=(rs.getString("chegada_em") != null ? formatador.format(rs.getDate("chegada_em")) : "")%>" type="text" size="9"  maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true);validaDatas('<%=formatador.format(rs.getDate("emissao_em"))%>','<%=rs.getString("id")%>');" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        <input name="dtemissao_<%=rs.getString("id")%>" id="dtemissao_<%=rs.getString("id")%>" type="hidden" value="'<%=formatador.format(rs.getDate("emissao_em"))%>'">
                        <input name="idctrc" id="idctrc" type="hidden" value="'<%=rs.getString("id")%>'">
                        <input name="data_menor_<%=rs.getString("id")%>" id="data_menor_<%=rs.getString("id")%>" type="hidden" value="'<%=rs.getString("data_menor")%>'">
                        às
                        <input name="chegadaAs_<%=rs.getString("id")%>" type="text" id="chegadaAs_<%=rs.getString("id")%>" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value="<%=(rs.getString("chegada_as") == null || rs.getString("chegada_as").equals("00:00:00") ? "" : rs.getString("chegada_as").substring(0, 5))%>"/>
                        </font>
                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                        <font size="1" class="<%=isCancelado ? "styleVermelho" : ""%>">
                        <input name="dtDescarrego_<%=rs.getString("id")%>" id="dtDescarrego_<%=rs.getString("id")%>"
                               class="fieldMin" value="<%=(rs.getString("inicio_descarrego_em") != null ? formatador.format(rs.getDate("inicio_descarrego_em")) : "")%>" type="text" size="9"  maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true);" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        às
                        <input name="descarregoAs_<%=rs.getString("id")%>" type="text" id="descarregoAs_<%=rs.getString("id")%>" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value="<%=(rs.getString("inicio_descarrego_as") == null || rs.getString("inicio_descarrego_as").equals("00:00:00") ? "" : rs.getString("inicio_descarrego_as").substring(0, 5))%>"/>
                        <br/>
                        <br/>
                        <input name="dtFimDescarrego_<%=rs.getString("id")%>" id="dtFimDescarrego_<%=rs.getString("id")%>"
                               class="fieldMin" value="<%=(rs.getString("fim_descarrego_em") != null ? formatador.format(rs.getDate("fim_descarrego_em")) : "")%>" type="text" size="9"  maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true);" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        às
                        <input name="fimDescarregoAs_<%=rs.getString("id")%>" type="text" id="fimDescarregoAs_<%=rs.getString("id")%>" class="fieldMin"
                               onkeyup="mascaraHora(this)" size="4" maxlength="5"  value="<%=(rs.getString("fim_descarrego_as") == null || rs.getString("fim_descarrego_as").equals("00:00:00") ? "" : rs.getString("fim_descarrego_as").substring(0, 5))%>"/>
                        <br>
                        <input type="checkbox" id="descarregoCobrado_<%=rs.getString("id")%>" name="descarregoCobrado_<%=rs.getString("id")%>" <%=rs.getBoolean("is_cobrou_descarrego") ? "checked" : ""%> />
                        Cobrou Descarrego
                        </font>
                    </td>

                    <td class="<%=isCancelado ? "styleVermelho" : ""%>">
                        <input name="obs_<%=rs.getString("id")%>" id="obs_<%=rs.getString("id")%>" value="<%=(rs.getString("observacao_baixa") != null ? rs.getString("observacao_baixa") : "")%>" type="text" size="24" maxlength="150" onBlur="javascript:apenasPonto(this,'_',' ');javascript:apenasPonto(this,';',':');" class="fieldMin">
                        Ocorr&ecirc;ncia:
                        <input name="oco_<%=rs.getString("id")%>" id="oco_<%=rs.getString("id")%>" value="<%=(rs.getString("ocorrencia") != null ? rs.getString("ocorrencia") : "")%>" type="text" size="2" class="fieldMin" maxlength="3" onChange="javascript:seNaoIntReset(this,'');" onKeyUp="javascript:if (event.keyCode==13) localizaOcorrenciaCodigo(this,'<%=rs.getString("id")%>',<%=linha%>)">
                        <font size="1" class="<%=isCancelado ? "styleVermelho" : ""%>">
                        <input name="<%=rs.getString("id")%>" type="button" class="botoes" id="<%=rs.getString("id")%>" value="..." onClick="javascript:localizaOcorrencia(this, <%=linha%>);">
                        </font>
                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%><%=isCancelado ? "styleVermelho" : ""%>" >
                        <input name="dtfechamento_<%=rs.getString("id")%>" id="dtfechamento_<%=rs.getString("id")%>" value="<%=(rs.getString("baixa_em") != null ? formatador.format(rs.getDate("baixa_em")) : "")%>" type="text" size="9" class="fieldMin" maxlength="12" align="Right"
                               onblur="alertInvalidDate(this, true);chkAutoComprovanteEntrega(this);validaDatas('<%=formatador.format(rs.getDate("emissao_em"))%>','<%=rs.getString("id")%>');" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        <label class="<%=isCancelado ? "styleVermelho" : ""%>">às</label>
                        <input name="entregaAs_<%=rs.getString("id")%>" type="text" id="entregaAs_<%=rs.getString("id")%>"  class="fieldMin" 
                               onkeyup="mascaraHora(this)" size="4" maxlength="5" value="<%=(rs.getString("entrega_as") == null || rs.getString("entrega_as").equals("00:00:00") ? "" : rs.getString("entrega_as").substring(0, 5))%>"/>
                        <font size="1" class="<%=isCancelado ? "styleVermelho" : ""%>">
                   <div>
                           <input type="checkbox" <%= (nivelUserMarcarComprovanteBaixaEntradaCte == 0 ? "onclick='return false' ReadOnly " : "onclick='chkComprovanteEntrega(this)'" ) %> class="comprovanteEntrega"  id="comprovanteEntrega_<%=rs.getString("id")%>" name="comprovanteEntrega_<%=rs.getString("id")%>" <%=rs.getString("baixado_no_dia") != null ? "checked" : ""%>/>
                            Comprov. Entregue
                        </div>
                        <div  id="divBaixadoNoDia_<%=rs.getString("id")%>"  style="<%= (rs.getString("baixado_no_dia") != null ? "" : "display: none") %>">
                            Data comprov.:
                            <input name="dtBaixadoNoDia_<%=rs.getString("id")%>" id="dtBaixadoNoDia_<%=rs.getString("id")%>" value="<%=(rs.getString("baixado_no_dia") != null ? formatador.format(rs.getDate("baixado_no_dia")) : rs.getString("baixa_em") != null ? formatador.format(rs.getDate("baixa_em")) : "")%>" type="text" size="9" <%= (nivelUserMarcarComprovanteBaixaEntradaCte == 0 ? "class='inputReadOnly' readOnly" : "class='fieldMin'") %> maxlength="10" align="Right"
                                   onblur="alertInvalidDate(this, true);" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        </div>
                        </font>

                    </td>
                    <td class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                        <input name="valor_avaria_<%=rs.getString("id")%>" class="fieldMin" id="valor_avaria_<%=rs.getString("id")%>" value="<%=Apoio.to_curr(rs.getFloat("valor_avaria"))%>" type="text" size="6" onChange="javascript:seNaoFloatReset(this, '0.00');" maxlength="12" align="Right">
                    </td>
                </tr>
                <tr name="trOcorrenciaCtrc_<%=rs.getString("id")%>" id="trOcorrenciaCtrc_<%=rs.getString("id")%>" style="display:none;">
                    <td colspan="12">
                        <%if (cfg.isBaixaEntregaNota()) {%>
                        <table width="100%" border="0" class="bordaFina">                            
                            <tr style="display:none" id="notas_<%=rs.getString("id")%>" >
                                <td rowspan="1" class='CelulaZebra1' width="0%" style="display:none;"></td>
                                <td rowspan="1" width="100%">--</td>
                            </tr>
                        </table>
                        <%}%>
                        <table width="100%" border="0" class="bordaFina">
                            <tbody id="TbOcorrenciaCtrc_<%=rs.getString("id")%>" name="TbOcorrenciaCtrc_<%=rs.getString("id")%>">
                                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                                    <td width="2%"><img id="addOcorrencia_<%=rs.getString("id")%>" src="img/add.gif" border="0" title="atribuir valor &agrave; tabela abaixo" class="imagemLink" style="vertical-align:middle;"
                                                        onClick="javascript:novaOcorrencia('<%=rs.getString("id")%>',<%=linha%>);"></td>
                                    <td width="2%">
                                        <!--<img src="img/page_edit.png" style="vertical-align:middle;cursor: pointer;">-->
                                    </td>
                                    <td width="2%">
                                        <!--<img src="img/pdf.jpg" style="vertical-align:middle;cursor: pointer;">-->
                                    </td>
                                    <td width="20%">Ocorrência&nbsp;<span class="linkEditar" onClick="javascript:carregarOcorrencias('<%=rs.getString("id")%>','<%=((linha % 2) == 0 ? "1" : "2")%>');" name="mostrar_<%=rs.getString("id")%>" id="mostrar_<%=rs.getString("id")%>">(Mostrar Ocorr. desse CT-e)</span></td>
                                    <td width="10%">Ocorrência em</td>
                                    <td width="8%">Usuário</td>
                                    <td width="20%">Observação ocorrência</td>
                                    <td width="10%">Resolvido em</td>
                                    <td width="8%">Usuário</td>
                                    <td width="18%">Observação resolução</td>
                                </tr>
                            </tbody>
                            <input type="hidden" id="qtdOcorrencia_<%=rs.getString("id")%>" name="qtdOcorrencia_<%=rs.getString("id")%>" value = "0">
                        </table>
                    </td>
                </tr>
                <%
                            linha++;
                        }
                    }
                %>
                <tr class="tabela">
                    <td colspan="10">
                        <div>
                            <strong id="qntdSelecionada"> Qtd selecionada: 0</strong>
                        </div>
                    </td>
                </tr>
            </table>
            <input type="hidden" name="qtdLinha" id="qtdLinha" value="<%=linha%>">
        </form>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr>
                <td width="100%" class="TextoCampos"> 
                    <div align="center">
                        <% if (nivelUserBaixa >= 2) {%>
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar CT-e(s) Selecionados" onClick="javascript:tryRequestToServer(function(){salvar(<%=linha%>);});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
        <div class="cobre-tudo"></div>
        <div class="container-detalhes-ocorrencia">
            
        </div>
    </body>
</html>
