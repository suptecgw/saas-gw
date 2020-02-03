<%@page import="br.com.gwsistemas.filial.usuario.UsuarioVendedor"%>
<%@page import="venda.BeanVenda"%>
<%@ page contentType="text/html"
         language="java"
         import="nucleo.*,
         java.util.Date,
         java.util.Collection,
         despesa.pagamentoComissao.*,
         fornecedor.BeanCadFornecedor,
         despesa.duplicata.*,
         despesa.apropriacao.*,
         java.text.DecimalFormat,
         java.text.SimpleDateFormat,
         java.util.Vector" %>

<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="net.sf.json.JSONObject"%>

<%@page import="conhecimento.duplicata.BeanDuplicata"%>
<%@page import="filial.BeanFilial"%>
<%@page import="despesa.especie.Especie"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="despesa.pagamentoComissao.PagamentoComissaoCTRC"%>
<%@page import="filial.BeanFilial"%>

<jsp:useBean id="venda" class="conhecimento.BeanConhecimento" />
<jsp:useBean id="duplicata" class="conhecimento.duplicata.BeanDuplicata" />

<jsp:useBean id="cadCom" class="despesa.pagamentoComissao.CadPagamentoComissao" />
<jsp:useBean id="comissao" class="despesa.pagamentoComissao.PagamentoComissao" />



<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" src="script/funcoes.js" type=""></script>
<script language="JavaScript" type="text/javascript" src="script/jquery.js"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>

<% int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadpgtocomissao") : 0);
    int nivelUserFl = (nivelUser == 0 ? 0 : Apoio.getUsuario(request).getAcesso("landespfl"));
    if (Apoio.getUsuario(request) == null || nivelUser == 0) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    int idFilialUser = (nivelUser > 0 ? Apoio.getUsuario(request).getFilial().getIdfilial() : 0);
    int nivelCombinado = Apoio.getUsuario(request).getAcesso("alteravalorcomissaorepre");

    //Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();

    String acao = (request.getParameter("acao") == null || nivelUser == 0 ? "" : request.getParameter("acao"));
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    boolean carregaComissao = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar") || acao.equals("excluir"));
    boolean baixado = false;
    cadCom = new CadPagamentoComissao();
    cadCom.setConexao(Apoio.getUsuario(request).getConexao());
    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluir")) {
        if (acao.equals("editar")) {
            cadCom.getComissao().setId(Apoio.parseInt(request.getParameter("id")));
            carregaComissao = cadCom.LoadAllPropertys();
            comissao = (carregaComissao ? cadCom.getComissao() : null);
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir") || acao.equals("excluir"))) {
            boolean executou = false;
            cadCom.setExecutor(Apoio.getUsuario(request));

            //setando os atributos que nao podem ser setados dinamicamente(acoes: atualizar/incluir)
            if (acao.equals("atualizar") || acao.equals("incluir")) {
                SimpleDateFormat fmtMesAno = new SimpleDateFormat("MM/yyyy");
                comissao = new PagamentoComissao();
                comissao.setId(Apoio.parseInt(request.getParameter("id")));
                comissao.setDtLancamento(Apoio.paraDate(request.getParameter("dtLancamento")));
                comissao.getFilial().setIdfilial(Apoio.parseInt(request.getParameter("filialIdPrinc")));
                comissao.getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor")));
                //campos consulta
                comissao.setTipoComissao(request.getParameter("tipoComissao"));
                comissao.setTipoDtConsulta(request.getParameter("tipoConsultaPrinc"));
                comissao.setDtConsultaDe(Apoio.paraDate(request.getParameter("dtemissao1Princ")));
                comissao.setDtConsultaAte(Apoio.paraDate(request.getParameter("dtemissao2Princ")));
                comissao.setTipoVinculoConsulta(request.getParameter("tipoVendedorPrinc"));
                comissao.setTipoVinculoConsultaRepresentante(request.getParameter("tipoCalculoRepresentantePrinc"));
                comissao.setTipoCalculoComissao(request.getParameter("calcularComissaoPrinc"));
                comissao.setCriadoEm(new Date());
                comissao.getCriadoPor().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                comissao.setAlteradoEm(new Date());
                comissao.getAlteradoPor().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                comissao.setIcms(Apoio.parseBoolean(request.getParameter("icms")));
                comissao.setPis(Apoio.parseBoolean(request.getParameter("pis")));
                comissao.setCofins(Apoio.parseBoolean(request.getParameter("cofins")));
                comissao.setCssl(Apoio.parseBoolean(request.getParameter("cssl")));
                comissao.setIr(Apoio.parseBoolean(request.getParameter("ir")));
                comissao.setInss(Apoio.parseBoolean(request.getParameter("inss")));
                
                comissao.setPagarComissaoJuros(request.getParameter("valorJuros"));
                comissao.setPagarComissaoDesconto(request.getParameter("valorDesconto"));
                comissao.setRetirarContratoFreteBaseCalculo(Apoio.parseBoolean(request.getParameter("retirarContratoFreteBaseCalculo")));
                //despesa
                comissao.getDespesa().setIdmovimento(Apoio.parseInt(request.getParameter("despesaId")));
                comissao.getDespesa().getFilial().setIdfilial(Apoio.getUsuario(request).getFilial().getIdfilial());
                comissao.getDespesa().setDtEmissao(Apoio.paraDate(request.getParameter("dtLancamento")));
                comissao.getDespesa().setDtEntrada(Apoio.paraDate(request.getParameter("dtLancamento")));
                comissao.getDespesa().setDescHistorico("Pagamento da comissão do " + (comissao.getTipoComissao().equals("v") ? "vendedor " : "representante ") + request.getParameter("fornecedor"));
                comissao.getDespesa().getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor")));
                comissao.getDespesa().setValor(Apoio.parseDouble(request.getParameter("valorTotal")));
                comissao.getDespesa().setAVista(false);
                comissao.getDespesa().setCompetencia(fmtMesAno.format(comissao.getDtLancamento()));
                comissao.getDespesa().getUsuarioLancamento().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                comissao.getDespesa().setDtLancamento(new Date());
                comissao.getDespesa().getUsuarioAlteracao().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                comissao.getDespesa().setDtAlteracao(new Date());
                comissao.getDespesa().setSerie(request.getParameter("serie"));
                comissao.getDespesa().setNfiscal(request.getParameter("notafiscal"));
                comissao.getDespesa().getEspecie_().setEspecie(request.getParameter("especie"));
                
                
                //duplicata
                BeanDuplDespesa dp[] = new BeanDuplDespesa[1];
                BeanDuplDespesa du = new BeanDuplDespesa();
                du.setDtvenc(Apoio.paraDate(request.getParameter("dtVencimento")));
                du.setDuplicata(1);
                du.setVlduplicata(Apoio.parseDouble(request.getParameter("valorTotal")));
                du.setCriaPcs(false);
                du.setIdmovimento(Apoio.parseInt(request.getParameter("despesaId")));
                dp[0] = du;
                comissao.getDespesa().setDuplicatas(dp);

                //apropriacao
                BeanApropDespesa[] aprop = new BeanApropDespesa[1];
                BeanApropDespesa ap = new BeanApropDespesa();
                ap.setIdmovimento(Apoio.parseInt(request.getParameter("despesaId")));
                ap.getPlanocusto().setIdconta(Apoio.parseInt(request.getParameter("idplanocusto_despesa")));
                ap.setValor(Apoio.parseDouble(request.getParameter("valorTotal")));

                String unid = (request.getParameter("id_und").equals("") ? "0" : request.getParameter("id_und"));
                ap.getUndCusto().setId(Apoio.parseInt(unid));
                ap.getFilial().setIdfilial(Apoio.getUsuario(request).getFilial().getIdfilial());
                aprop[0] = ap;
                comissao.getDespesa().setApropriacoes(aprop);

//                int i = 1;
//                PagamentoComissaoCTRC pgtoComissao = null;
//                while (request.getParameter("idVenda_" + i) != null) {
//                    if (request.getParameter("selecionado_" + i) != null) {
//                        pgtoComissao = new PagamentoComissaoCTRC();
//                        pgtoComissao.setId(Integer.parseInt(request.getParameter("idParcelaComissao_" + i)));
//                        pgtoComissao.getConhecimento().setId(Apoio.parseInt(request.getParameter("idVenda_" + i)));
//                        pgtoComissao.setValor(Apoio.parseDouble(request.getParameter("comissao_" + i)));
//                        //pgtoComissao.setTipoCalculoComissao(request.getParameter("tipoCalculoItem_" + i));
//                        pgtoComissao.setTipoCalculoComissao((request.getParameter("chkCombinado_" + i) != null ? "com" : request.getParameter("tipoCalculoItem_" + i)));
//                        pgtoComissao.setTipoRepresentante(request.getParameter("tipoRepresentante_" + i));
//                        comissao.getPagamentoComissaoCTRCs().add(pgtoComissao);
//                    }
//                    i++;
//                }

                int maxVenda = Apoio.parseInt(request.getParameter("maxVenda"));
                PagamentoComissaoCTRC pgtoComissao = null;
                for(int qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++){
                    if(request.getParameter("selecionado_"+qtdVenda) != null){
                        pgtoComissao = new PagamentoComissaoCTRC();
                        pgtoComissao.setId(Integer.parseInt(request.getParameter("idParcelaComissao_" + qtdVenda)));
                        pgtoComissao.getConhecimento().setId(Apoio.parseInt(request.getParameter("idVenda_" + qtdVenda)));
                        pgtoComissao.setValor(Apoio.parseDouble(request.getParameter("comissao_" + qtdVenda)));
                        //pgtoComissao.setTipoCalculoComissao(request.getParameter("tipoCalculoItem_" + i));
                        pgtoComissao.setTipoCalculoComissao((request.getParameter("chkCombinado_" + qtdVenda) != null ? "com" : request.getParameter("tipoCalculoItem_" + qtdVenda)));
                        pgtoComissao.setTipoRepresentante(request.getParameter("tipoRepresentante_" + qtdVenda));
                        comissao.getPagamentoComissaoCTRCs().add(pgtoComissao);                        
                    }
                }

                cadCom.setComissao(comissao);
                if (acao.equals("atualizar")) {
                    executou = cadCom.Atualiza();
                } else if (acao.equals("incluir") && nivelUser >= 3) {
                    executou = cadCom.Inclui();
                }

%>
<script language="javascript" type="text/javascript"><%    if (!executou) {%>
    window.opener.document.getElementById("salvar").disabled = false;
    window.opener.document.getElementById("salvar").value = "Salvar";
    alert('<%=(cadCom.getErros())%>');<%
        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    } else {%>
    if (window.opener != null)
        window.opener.document.getElementById("bt_consultar").onclick();
    <%}%>
    self.close();
</script>

<%} else if (acao.equals("excluir") && nivelUser >= 4) {
    cadCom.setComissao(comissao);
    cadCom.getComissao().setId(Apoio.parseInt(request.getParameter("id")));
//não tava passando o id da movimentacao da despesa - Daniel Cassimiro
    cadCom.getComissao().getDespesa().setIdmovimento(Apoio.parseInt(request.getParameter("idDespesa")));
    executou = cadCom.Deleta();
%>

<script language="javascript" type="text/javascript"><%
    if (!executou) {%>
    var erro = '<%=(cadCom.getErros())%>';
    alert('Erro ao excluir: ' + erro);
    erro = '';
    <%
    } else {%>
    if (window.opener != null)
        window.opener.document.getElementById("pesquisar").onclick();
    <%}%>
    self.close();
</script>
<%}
        }
    } else if (acao.equals("localizaRedespachante")) {
        String resultado = "";
        String campo = request.getParameter("campo");
        String valor = request.getParameter("valor");
        BeanCadFornecedor fo = new BeanCadFornecedor();
        fo.setConexao(Apoio.getUsuario(request).getConexao());
        ResultSet rs = fo.getLocalizaCodigoRedespachante(valor, campo);

        if (rs == null) {
            resultado = "null";
        } else {
            if (rs.next()) {
                resultado = rs.getString("idfornecedor") + "!=!"
                        + rs.getString("razaosocial") + "!=!"
                        + rs.getString("cpf_cnpj") + "!=!"
                        + rs.getString("descricao_historico") + "!=!"
                        + rs.getString("idplcustopadrao") + "!=!"
                        + rs.getString("contaplcusto") + "!=!"
                        + rs.getString("descricaoplcusto") + "!=!"
                        + rs.getString("id_und_forn") + "!=!"
                        + rs.getString("sigla_und_forn") + "!=!";
            }
        }
        response.getWriter().append(resultado);
        response.getWriter().close();
    } else if (acao.equals("localizaVendedor")) {
        String resultado = "";
        String campo = request.getParameter("campo");
        String valor = request.getParameter("valor");
        BeanCadFornecedor fo = new BeanCadFornecedor();
        fo.setConexao(Apoio.getUsuario(request).getConexao());
        ResultSet rs = fo.getLocalizaCodigoVendedor(valor, campo);

        if (rs == null) {
            resultado = "null";
        } else {
            if (rs.next()) {
                resultado = rs.getString("idfornecedor") + "!=!"
                        + rs.getString("razaosocial") + "!=!"
                        + rs.getString("cpf_cnpj") + "!=!"
                        + rs.getString("descricao_historico") + "!=!"
                        + rs.getString("idplcustopadrao") + "!=!"
                        + rs.getString("contaplcusto") + "!=!"
                        + rs.getString("descricaoplcusto") + "!=!"
                        + rs.getString("id_und_forn") + "!=!"
                        + rs.getString("sigla_und_forn") + "!=!";
            }
        }
        response.getWriter().append(resultado);
        response.getWriter().close();
    } else if (acao.equals("localizarCTRCVendedor")) {
        String tipoConsulta = request.getParameter("tipoConsulta");
        Date dtIni = Apoio.paraDate(request.getParameter("dtIni"));
        Date dtFim = Apoio.paraDate(request.getParameter("dtFim"));
        String tipoComissao = request.getParameter("tipoComissao");
        String tipoVendedor = request.getParameter("tipoVendedor");
        String calcularComissao = request.getParameter("calcularComissao");
        String tiposConhecimento = request.getParameter("tiposConhecimento");
        int idForne = Apoio.parseInt(request.getParameter("idForne"));
        int idFilial = Apoio.parseInt(request.getParameter("idFilial"));
        int idComissao = Apoio.parseInt(request.getParameter("id"));

        boolean isIcms = Apoio.parseBoolean(request.getParameter("isIcms"));
        boolean isPis = Apoio.parseBoolean(request.getParameter("isPis"));
        boolean isCofins = Apoio.parseBoolean(request.getParameter("isCofins"));
        boolean isCssl = Apoio.parseBoolean(request.getParameter("isCssl"));
        boolean isIr = Apoio.parseBoolean(request.getParameter("isIr"));
        boolean isInss = Apoio.parseBoolean(request.getParameter("isInss"));        
        String pagarComissaoJuros = request.getParameter("pagarComissaoJuros");


        String pagarComissaoDesconto = request.getParameter("pagarComissaoDesconto");
        boolean isRetirarContratoFreteBaseCalculo = Apoio.parseBoolean(request.getParameter("isRetirarContratoFreteBaseCalculo"));
        
        CadPagamentoComissao pc = new CadPagamentoComissao();
        pc.setConexao(Apoio.getUsuario(request).getConexao());

        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("venda", despesa.pagamentoComissao.PagamentoComissaoCTRC.class);
        xstream.alias("conhecimento", conhecimento.BeanConhecimento.class);
        xstream.alias("duplicata", conhecimento.duplicata.BeanDuplicata.class);

        Collection lista = pc.getPesquisaCTRCVendedor(tipoConsulta, dtIni, dtFim,
                idFilial, idForne, tipoComissao, tipoVendedor, calcularComissao, idComissao, 
                tiposConhecimento, isIcms, isPis, isCofins, isCssl, isIr, isInss, pagarComissaoJuros, pagarComissaoDesconto, isRetirarContratoFreteBaseCalculo);

        String vendasList = xstream.toXML(lista);

        response.getWriter().append(vendasList);
        response.getWriter().close();

    } else if (acao.equals("localizarCTRCRedespachante")) {
        String tipoConsulta = request.getParameter("tipoConsulta");
        Date dtIni = Apoio.paraDate(request.getParameter("dtIni"));
        Date dtFim = Apoio.paraDate(request.getParameter("dtFim"));
        String tipoComissao = request.getParameter("tipoComissao");
        String calcularComissao = request.getParameter("calcularComissao");
        String tipoCalculoRepresentante = request.getParameter("tipoCalculoRepresentante");

        int idForne = Apoio.parseInt(request.getParameter("idForne"));
        int idFilial = Apoio.parseInt(request.getParameter("idFilial"));
        int idComissao = Apoio.parseInt(request.getParameter("id"));

        CadPagamentoComissao pc = new CadPagamentoComissao();
        pc.setConexao(Apoio.getUsuario(request).getConexao());

        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("venda", despesa.pagamentoComissao.PagamentoComissaoCTRC.class);
        xstream.alias("conhecimento", conhecimento.BeanConhecimento.class);
        xstream.alias("duplicata", conhecimento.duplicata.BeanDuplicata.class);

        Collection lista = pc.getPesquisaCTRCRepresentante(tipoConsulta, dtIni, dtFim,
                idFilial, idForne, tipoComissao, tipoCalculoRepresentante, calcularComissao, idComissao);

        String vendasList = xstream.toXML(lista);

        response.getWriter().append(vendasList);
        response.getWriter().close();

    } else if (acao.equals("carregarCtrc")) {
        String calcularComissao = request.getParameter("calcularComissao");
        String tipoCalculoRepresentante = request.getParameter("tipoCalculoRepresentante");
        String tipoComissao = request.getParameter("tipoComissao");

        int idForne = Apoio.parseInt(request.getParameter("idForne"));
        int idComissao = Apoio.parseInt(request.getParameter("id"));
        int idFilial = Apoio.parseInt(request.getParameter("idFilial"));
        String numCtrc = request.getParameter("numCtrc");
        String conh = request.getParameter("conh");

        CadPagamentoComissao pc = new CadPagamentoComissao();
        pc.setConexao(Apoio.getUsuario(request).getConexao());

        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("venda", despesa.pagamentoComissao.PagamentoComissaoCTRC.class);
        xstream.alias("conhecimento", conhecimento.BeanConhecimento.class);
        xstream.alias("duplicata", conhecimento.duplicata.BeanDuplicata.class);

        Collection<PagamentoComissaoCTRC> lista = pc.getPesquisaCTRCRepresentante(idFilial, tipoCalculoRepresentante,
                calcularComissao, idComissao, numCtrc, conh, tipoComissao, idForne);

        String vendasList = xstream.toXML(lista);

        response.getWriter().append(vendasList);
        response.getWriter().close();
    }
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <title>Lan. Pagamento de Comiss&atilde;o - Webtrans</title>
        <style type="text/css">
            <!--
            .style2 {font-family: Verdana, Arial, Helvetica, sans-serif}
            -->
        </style>
        <script language="javascript" type="text/javascript">

            jQuery.noConflict();

            function stAb(menu, conteudo) {
                this.menu = menu;
                this.conteudo = conteudo;
            }
            
            var isPrimeiro = true;
            
            var arAbaPC = new Array();
            arAbaPC[0] = new stAb('tdAbaInfoPesq', 'divAbaInfoPesq');
            arAbaPC[1] = new stAb('tdAbaInfoFinan', 'divAbaInfoFinan');
            arAbaPC[2] = new stAb('tdAbaAuditoria', 'divAbaAuditoria');
//            arAbaPC[3] = new stAb('tdAbaCriterioCalculoComissao', 'divCriterioCalculoComissao');

            function AlterneAb(menu, conteudo) {
                if (arAbaPC != null) {
                    for (i = 0; i < arAbaPC.length; i++) {
                        if (arAbaPC[i] != null && arAbaPC[i] != undefined) {
                            m = document.getElementById(arAbaPC[i].menu);
                            m.className = 'menu';
                            for (var j = 0, max = arAbaPC[i].conteudo.split(",").length; j < max; j++) {
                                c = document.getElementById(arAbaPC[i].conteudo.split(",")[j]);
                                if (c != null) {
                                    invisivel(c, false);
                                } else if ($(arAbaPC[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                                    invisivel($(arAbaPC[i].conteudo.split(",")[j].replace("div", "tr")), false);
                                }
                            }
                        }
                    }
                    m = document.getElementById(menu);
                    m.className = 'menu-sel';
                    for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                        c = document.getElementById(conteudo.split(",")[i]);
                        if (c != null) {
                            visivel(c, false);
                        } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                            visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                        }
                    }
                } else {
                    alert("Inicialize a variavel arAbasGenerico!");
                }
            }

            function popLocate(indice, idlista, nomeJanela) {
                launchPopupLocate("./localiza?acao=consultar&idlista=" + idlista, nomeJanela + indice);
            }

            //exibe uma msg e para a instrucao
            function alertMsg(msgText) {
                alert(msgText);
                return false;
            }

            function salva() {
                if ($("idfornecedor").value == "0" || $("idfornecedor").value == "")
                    return alertMsg("Informe o Fornecedor!");

                if ($("idplanocusto_despesa").value == "0" || $("idplanocusto_despesa").value == "")
                    return alertMsg("Informe o Plano de Custo!");

                if (!validaData($("dtLancamento").value))
                    return alertMsg("A data de Lançamento é Inválida!\nO formato correto é: dd/mm/aaaa");

                if (!validaData($("dtVencimento").value))
                    return alertMsg("A data de Vencimento é Inválida!\nO formato correto é: dd/mm/aaaa");


//                if (wasNull("dtLancamento,dtVencimento,idfornecedor,competencia,idplanocusto_despesa"))
//                     return alertMsg("Preencha os Campos Corretamente!");

//                var j = 1;
//                var podeSalvar = false;
//                while ($("idVenda_" + j) != null) {
//                    if ($("selecionado_" + j).checked) {
//                        $("tipoCalculoItem_" + j).disabled = false;
//                        podeSalvar = true;
//                        //break;
//                    }
//                    j++;
//                }

                var maxVenda = $("maxVenda").value;
                var podeSalvar = false;
                    
                for (var qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++) {
                    if($("selecionado_" + qtdVenda) != null){
                        if($("selecionado_" + qtdVenda).checked){
                            podeSalvar = true;
                            break;
                        }                        
                    }
                }

                if (!podeSalvar) {
                    return alertMsg("Selecione ao menos uma Parcela!");
                }

                habilitaSalvar(false);
                $("acao").value = '<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>';
                $("valorTotal").value = $("totalComissao").innerHTML;

                window.open('about:blank', 'pop', 'width=210, height=100');
                $("formulario").submit();
            }


            function desabilitar() {
                var j = 1;
                while ($("idVenda_" + j) != null) {
                    if ($("tipoCalculoItem_" + j) != null) {
                        $("tipoCalculoItem_" + j).style.display = "none";
                        $("lbPercComissao_" + j).style.display = "none";
                    }
                    j++;
                }
            }

            function aoCarregar() {
                $("totalValor").innerHTML = "0.00";
                $("totalComissao").innerHTML = "0.00";
                $("totalParcela").innerHTML = "0.00";
                $("totalPeso").innerHTML = "0.00";
                $("totalPago").innerHTML = "0.00";
                
                desabilitar();
                esconderCampos();
              
            <%  if (carregaComissao) {%>
                $("id").value = "<%=comissao.getId()%>";
                $("despesaId").value = "<%=comissao.getDespesa().getIdmovimento()%>";
                $("dtLancamento").value = "<%=Apoio.fmt(comissao.getDtLancamento())%>";

                $("filialId").value = "<%=comissao.getFilial().getIdfilial()%>";
                $("filialIdPrinc").value = "<%=comissao.getFilial().getIdfilial()%>";
                $("tipoComissao").value = "<%=comissao.getTipoComissao()%>";

                $("calcularComissaoPrinc").value = "<%=comissao.getTipoCalculoComissao()%>";
                $("calcularComissao").value = "<%=comissao.getTipoCalculoComissao()%>";

                $("tipoConsulta").value = "<%=comissao.getTipoDtConsulta()%>";
                $("tipoConsultaPrinc").value = "<%=comissao.getTipoDtConsulta()%>";

                $("dtemissao1").value = "<%=Apoio.fmt(comissao.getDtConsultaDe())%>";
                $("dtemissao1Princ").value = "<%=Apoio.fmt(comissao.getDtConsultaDe())%>";

                $("dtemissao2").value = "<%=Apoio.fmt(comissao.getDtConsultaAte())%>";
                $("dtemissao2Princ").value = "<%=Apoio.fmt(comissao.getDtConsultaAte())%>";

                $("tipoVendedor").value = "<%=comissao.getTipoVinculoConsulta()%>";
                $("tipoVendedorPrinc").value = "<%=comissao.getTipoVinculoConsulta()%>";


                $("tipoCalculoRepresentante").value = "<%=comissao.getTipoVinculoConsultaRepresentante()%>";
                $("tipoCalculoRepresentantePrinc").value = "<%=comissao.getTipoVinculoConsultaRepresentante()%>";
               // $("notafiscal").value = "<%=comissao.getDespesa().getNFiscal()%>";

            <%for (BeanApropDespesa aprop : comissao.getDespesa().getApropriacoes()) {%>
                $("idplanocusto_despesa").value = "<%=aprop.getPlanocusto().getIdconta()%>";
                $("plcusto_conta_despesa").value = "<%=aprop.getPlanocusto().getConta()%>";
                $("plcusto_descricao_despesa").value = "<%=aprop.getPlanocusto().getDescricao()%>";
                $("id_und").value = "<%=aprop.getUnidadeCusto().getId()%>";
                $("sigla_und").value = "<%=aprop.getUnidadeCusto().getSigla()%>";
                
            <%}%>

            <%for (BeanDuplDespesa dup : comissao.getDespesa().getDuplicatas()) {%>
                $("dtVencimento").value = "<%=Apoio.fmt(dup.getDtvenc())%>";
            <%baixado = dup.isBaixado();%>
            <%}%>

                alteraTipo($("tipoComissao").value);
                $("idfornecedor").value = "<%=comissao.getFornecedor().getIdfornecedor()%>";
                $("fornecedor").value = "<%=comissao.getFornecedor().getRazaosocial()%>";
                $("cpf_cnpj").value = "<%=comissao.getFornecedor().getCpfCnpj()%>";
                $("redspt_vlsobfrete").value = "<%=comissao.getFornecedor().getVlsobfrete()%>";
                $("redspt_vlsobpeso").value = "<%=comissao.getFornecedor().getVlsobpeso()%>";
                $("redspt_vlfreteminimo").value = "<%=comissao.getFornecedor().getVlfreteminimo()%>";
                $("redspt_vlkgate").value = "<%=comissao.getFornecedor().getVlKgAte()%>";
                $("redspt_vlprecofaixa").value = "<%=comissao.getFornecedor().getVlPrecoFaixa()%>";
                $("icms").checked = <%=comissao.isIcms()%>;
                $("pis").checked = <%=comissao.isPis()%>;
                $("cofins").checked = <%=comissao.isCofins()%>;
                $("cssl").checked = <%=comissao.isCssl()%>;
                $("ir").checked = <%=comissao.isIr()%>;
                $("inss").checked = <%=comissao.isInss()%>;                
                $("retirarContratoFreteBaseCalculo").checked = <%=comissao.isRetirarContratoFreteBaseCalculo()%>;
                
                <%if(comissao.getPagarComissaoJuros().equals("rj")){%>
                    $("valorRecebidoJuros").checked = true;  
                <%}else if(comissao.getPagarComissaoJuros().equals("oj")) {%>
                    $("valorOriginalJuros").checked = true;  
                <%}%>
                <%if(comissao.getPagarComissaoDesconto().equals("rd")){%>
                    $("valorRecebidoDesconto").checked = true;  
                <%}else if(comissao.getPagarComissaoDesconto().equals("od")) {%>
                    $("valorOriginalDesconto").checked = true;  
                <%}%>
                <%if(comissao.isIcms() && comissao.isPis() && comissao.isCofins() && comissao.isCssl() && comissao.isIr() && comissao.isInss()){%>
                    $("impostoFederais").checked = true;                    
                <%}%>    
                    
            <%for (PagamentoComissaoCTRC pgto1 : comissao.getPagamentoComissaoCTRCs()) {%>
                var v = new Venda();
                v.idVenda = '<%=pgto1.getConhecimento().getId()%>';
                v.idParcelaComissao = '<%=pgto1.getId()%>';
                v.ctrc = '<%=pgto1.getConhecimento().getNumero()%>';
                v.filial = '<%=pgto1.getConhecimento().getFilial().getAbreviatura()%>';
                v.emissao = '<%=Apoio.fmt(pgto1.getConhecimento().getEmissaoEm())%>';
                v.consignatario = '<%=pgto1.getConhecimento().getCliente().getRazaosocial()%>';
                v.tipoRepre = '<%=pgto1.getConhecimento().getTipoRepre()%>';
                v.categoria = '<%=pgto1.getConhecimento().getCategoria()%>';
            <%BeanDuplicata dup = (BeanDuplicata) pgto1.getConhecimento().getDuplicatas().toArray()[0];%>
                v.valorCtrc = formatoMoeda('<%=pgto1.getConhecimento().getTotalReceita()%>');
                v.percComissao = formatoMoeda('<%=pgto1.getConhecimento().getComissaoVendedor()%>');
                v.vlComissao = formatoMoeda('<%=pgto1.getConhecimento().getComissaoVendedorValor()%>');

                v.dtPagto = '<%=Apoio.fmt(dup.getDtpago())%>';
                v.dtEntrega = '<%=Apoio.fmt(pgto1.getConhecimento().getBaixaEm())%>';
                v.isReadOnly = true;
                v.selecionado = '<%=pgto1.isSelecionado()%>';
//                v.tipoCalculoComissao = '< %=pgto1.getConhecimento().getTipoCalculoComissao()%>';
                v.tipoCalculoComissao = '<%=pgto1.getTipoCalculoComissao()%>';
                //novos campos							
                v.peso = formatoMoeda('<%=pgto1.getConhecimento().getTotalPeso()%>');
                v.vlSobPeso = formatoMoeda('<%=pgto1.getConhecimento().getRedespachoValor()%>');
                v.freteMinimo = formatoMoeda('<%=pgto1.getConhecimento().getRedespachante().getVlfreteminimo()%>');
                v.idFornecedor = '<%=comissao.getFornecedor().getIdfornecedor()%>';

                v.vlKgAte = formatoMoeda('<%=comissao.getFornecedor().getVlKgAte()%>');
                v.vlPrecoFaixa = formatoMoeda('<%=comissao.getFornecedor().getVlPrecoFaixa()%>');
                
                v.valorParcela = formatoMoeda('<%=dup.getVlduplicata()%>');
                v.valorPago = formatoMoeda('<%=dup.getVlpago()%>');
                
                var cli = new Cliente();
                            
                cli.utilizaCriterioPagtComissaoVendedor = <%=pgto1.getConhecimento().getCliente().isUtilizarCriterioPagamentoComissaoVendedor()%>;
                cli.icmsVendedor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalIcmsVendedor()%>;
                cli.pisVendedor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalPisVendedor()%>;
                cli.cofinsVendedor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalCofinsVendedor()%>;
                cli.csslVendedor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalCsslVendedor()%>;
                cli.irVendedor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalIrVendedor()%>;
                cli.inssVendedor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalInssVendedor()%>;                
                cli.calcularComissaoVendedor = '<%=pgto1.getConhecimento().getCliente().getCalcularComissaoVendedor()%>';
                cli.valorJurosVendedor = '<%=pgto1.getConhecimento().getCliente().getPagamentoComissaoJurosVendedor()%>';
                cli.valorDescontoVendedor = '<%=pgto1.getConhecimento().getCliente().getPagamentoComissaoDescontoVendedor()%>';

                cli.utilizaCriterioPagtComissaoSupervisor = <%=pgto1.getConhecimento().getCliente().isUtilizarCriterioPagamentoComissaoSupervisor()%>;
                cli.icmsSupervisor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalIcmsSupervisor()%>;
                cli.pisSupervisor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalPisSupervisor()%>;
                cli.cofinsSupervisor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalCofinsSupervisor()%>;
                cli.csslSupervisor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalCsslSupervisor()%>;
                cli.irSupervisor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalIrSupervisor()%>;
                cli.inssSupervisor = <%=pgto1.getConhecimento().getCliente().isImpostoFederalInssSupervisor()%>;                
                cli.calcularComissaoSupervisor = '<%=pgto1.getConhecimento().getCliente().getCalcularComissaoSupervisor()%>';
                cli.valorJurosSupervisor = '<%=pgto1.getConhecimento().getCliente().getPagamentoComissaoJurosSupervisor()%>';
                cli.valorDescontoSupervisor = '<%=pgto1.getConhecimento().getCliente().getPagamentoComissaoDescontoSupervisor()%>';
                
                if (<%=pgto1.getConhecimento().getCliente().getVendedor().isVendedor() ==  true%>) {
                    cli.tipoVendedor = "vendedor";    
                }else{
                    cli.tipoVendedor = "supervisor";                    
                }
                
                v.cliente = cli;
                
                v.permissaoCombinado = <%=(nivelCombinado == 4)%>;

                addVenda(v);
                
                visualizarComissao($("idfornecedor").value);
                
            <%}%>
                esconderCampos();
            <%
            } else {
            %>
                $("tipoComissao").value = "v";
                alteraTipo("v")
            <%}%>

            }

            function abrirCtrc(idmovimento, categoria) {
                tryRequestToServer(function () {
                    if (categoria == "ns") {
                        window.open("./cadvenda.jsp?acao=editar&id=" + idmovimento, "menuLan", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                    } else if (categoria == "ct") {
                        window.open("./frameset_conhecimento?acao=editar&id=" + idmovimento, "menuLan", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                    }

                });
            }

            function habilitaSalvar(opcao) {
                $("salvar").disabled = !opcao;
                $("salvar").value = (opcao ? "Salvar" : "Enviando...");
            }

            function voltar() {
                document.location.replace('./consulta_pagamento_comissao.jsp?acao=iniciar');
            }

            //Consulta fonecedor
            function localizaFornecedorCgc(campo, valor) {
                //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                function e(transport) {
                    var resp = transport.responseText;
                    espereEnviar("", false);
                    //se deu algum erro na requisicao...
                    if (resp == 'null') {
                        alert('Erro ao localizar fornecedor.');
                        return false;
                    } else if (resp == '') {
                        $('idfornecedor').value = '0';
                        $('fornecedor').value = '';
                        $('cpf_cnpj').value = '';

                        if (confirm("Fornecedor não encontrado, deseja cadastrá-lo agora?")) {
                            window.open('./cadfornecedor?acao=iniciar', 'Fornecedor', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                        }
                        return false;
                    } else {
                        $('idfornecedor').value = resp.split('!=!')[0];
                        $('fornecedor').value = resp.split('!=!')[1];
                        $('cpf_cnpj').value = resp.split('!=!')[2];
                    }

                }//funcao e()
                if (valor != '') {
                    espereEnviar("", true);
                    tryRequestToServer(function () {
                        var acao = "localizaVendedor";
                        if ($("tipoComissao").value == "r") {
                            acao = "localizaRedespachante";
                        }
                        new Ajax.Request("./cadpagamento_comissao.jsp?acao=" + acao + "&valor=" + valor + "&campo=" + campo, {method: 'post', onSuccess: e, onError: e});
                    });
                }
            }

            function formatDateJSON(objeto) {
                dataBR = "";
                var data = "";

                if (objeto != undefined) {
                    data = objeto.$;
                    if (data != undefined) {
                        dia = data.split("-")[2];
                        mes = data.split("-")[1];
                        ano = data.split("-")[0];

                        dataBR = dia + "/" + mes + "/" + ano;
                    }
                }

                return dataBR;
            }

            function respostaLocalizarCTRCAjax(transport, localiza) {
                try {
                    var no_alert = (no_alert != null || no_alert != undefined ? no_alert : false);
                    $("totalValor").innerHTML = "0.00";
                    $("totalComissao").innerHTML = "0.00";
                    $("totalParcela").innerHTML = "0.00";
                    $("totalPeso").innerHTML = "0.00";
                    $("totalPago").innerHTML = "0.00";
                    
                    esconderCampos();
                    
                    espereEnviar("", false);

                    var maxVenda = $("countVenda").value;
                    for (var qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++) {
                        if($("ctrcHidden_"+qtdVenda) != null){
                            if($("ctrcHidden_"+qtdVenda).value == $("numCtrc").value){
                                alert("O CT-e "+ $("numCtrc").value +" já foi adicionado.");
                                return false;
                            }
                        }
                    }
                    
                    var lista = jQuery.parseJSON(transport.responseText);
//                    console.log(lista);
                    if(lista.list[0].length == "0" && localiza != true){
                        alert("O CT-e "+ $("numCtrc").value +" não pertence a esse REPRESENTANTE: " + $("fornecedor").value + " , está cancelado ou é do tipo Substituído/Anulado!");
                    }

                    var vend = lista.list[0].venda;
                    if (vend != undefined && vend != null) {
                        var venda;
                        var length = (vend.length == undefined ? 1 : vend.length);
                        $("tipoConsultaPrinc").value = $("tipoConsulta").value;
                        $("dtemissao1Princ").value = $("dtemissao1").value;
                        $("dtemissao2Princ").value = $("dtemissao2").value;
                        $("filialIdPrinc").value = $("filialId").value;
                        $("tipoVendedorPrinc").value = $("tipoVendedor").value;
                        $("calcularComissaoPrinc").value = $("calcularComissao").value;
                        $("tipoCalculoRepresentantePrinc").value = $("tipoCalculoRepresentante").value;

                        for (var i = 0; i < length; i++) {
                            if (length > 1) {
                                venda = vend[i];
                            } else {
                                venda = vend;
                            }

                            var v = new Venda();

                            v.idVenda = venda.conhecimento.id;

                            v.idParcelaComissao = venda.id;
                            v.ctrc = venda.conhecimento.numero;

                            v.filial = venda.conhecimento.filial.abreviatura;
                            v.emissao = formatDateJSON(venda.conhecimento.emissao_em);
                            v.consignatario = venda.conhecimento.cliente.razaosocial;

                            var tipoBaseComissao = (venda.conhecimento.cliente.tipoBaseComissao);

                            if (tipoBaseComissao == "t") {
                                v.valorParcela = formatoMoeda(venda.conhecimento.duplicatas[0].duplicata.vlduplicata);
                            } else if (tipoBaseComissao == "f") {
                                v.valorParcela = formatoMoeda(venda.conhecimento.valor_peso);
                                v.tipoBaseComissao = "<br> Frete Peso";
                            }
                            
                            v.valorCtrc = formatoMoeda(venda.conhecimento.totalReceita);
                            v.valorPago = formatoMoeda(venda.conhecimento.duplicatas[0].duplicata.vlpago);
                            
                            v.percComissao = formatoMoeda(venda.conhecimento.comissaoVendedor);
                            v.vlComissao = formatoMoeda(venda.conhecimento.comissaoVendedorValor);
//                                v.categoria = venda.conhecimento.categoria;
                            v.dtPagto = formatDateJSON(venda.conhecimento.duplicatas[0].duplicata.dtpago);
                            v.dtEntrega = formatDateJSON(venda.conhecimento.baixa_em);
                            v.isReadOnly = true;
                            v.selecionado = true;
                            v.tipoCalculoComissao = venda.conhecimento.tipoCalculoComissao;
                            v.categoria = venda.conhecimento.categoria;

                            //novos campos
                            v.peso = formatoMoeda(venda.conhecimento.totalPeso);
                            v.vlSobPeso = formatoMoeda(venda.conhecimento.redespacho_valor);
                            v.freteMinimo = formatoMoeda(venda.conhecimento.redespachante.vlfreteminimo);
                            v.idFornecedor = venda.conhecimento.redespachante.idfornecedor;
                            v.tipoRepre = venda.conhecimento.tipoRepre;

                            v.vlKgAte = venda.conhecimento.redespachante.vlKgAte;
                            v.vlPrecoFaixa = venda.conhecimento.redespachante.vlPrecoFaixa;

                            v.permissaoCombinado = <%=(nivelCombinado == 4)%>;
                            
                            var cli = new Cliente();
                            
                            cli.utilizaCriterioPagtComissaoVendedor = venda.conhecimento.cliente.utilizarCriterioPagamentoComissaoVendedor;
                            cli.icmsVendedor = venda.conhecimento.cliente.impostoFederalIcmsVendedor;
                            cli.pisVendedor = venda.conhecimento.cliente.impostoFederalPisVendedor;
                            cli.cofinsVendedor = venda.conhecimento.cliente.impostoFederalCofinsVendedor;
                            cli.csslVendedor = venda.conhecimento.cliente.impostoFederalCsslVendedor;
                            cli.irVendedor = venda.conhecimento.cliente.impostoFederalIrVendedor;
                            cli.inssVendedor = venda.conhecimento.cliente.impostoFederalInssVendedor;
                            
                            cli.calcularComissaoVendedor = venda.conhecimento.cliente.calcularComissaoVendedor;
                            cli.valorJurosVendedor = venda.conhecimento.cliente.pagamentoComissaoJurosVendedor;
                            cli.valorDescontoVendedor = venda.conhecimento.cliente.pagamentoComissaoDescontoVendedor;
                            
                            cli.utilizaCriterioPagtComissaoSupervisor = venda.conhecimento.cliente.utilizarCriterioPagamentoComissaoSupervisor;
                            cli.icmsSupervisor = venda.conhecimento.cliente.impostoFederalIcmsSupervisor;
                            cli.pisSupervisor = venda.conhecimento.cliente.impostoFederalPisSupervisor;
                            cli.cofinsSupervisor = venda.conhecimento.cliente.impostoFederalCofinsSupervisor;
                            cli.csslSupervisor = venda.conhecimento.cliente.impostoFederalCsslSupervisor;
                            cli.irSupervisor = venda.conhecimento.cliente.impostoFederalIrSupervisor;
                            cli.inssSupervisor = venda.conhecimento.cliente.impostoFederalInssSupervisor;
                            
                            cli.calcularComissaoSupervisor = venda.conhecimento.cliente.calcularComissaoSupervisor;
                            cli.valorJurosSupervisor = venda.conhecimento.cliente.pagamentoComissaoJurosSupervisor;
                            cli.valorDescontoSupervisor = venda.conhecimento.cliente.pagamentoComissaoDescontoSupervisor;
                            if (venda.conhecimento.cliente.vendedor != null && venda.conhecimento.cliente.vendedor.vendedor == true) {
                                cli.tipoVendedor = "vendedor";    
                            }else{
                                cli.tipoVendedor = "supervisor";
                            }
                            
                            v.cliente = cli;

                            if ($('tipoComissao').value == 'v' || $('tipoComissao').value == 's' || ((!no_alert && venda.conhecimento.baixadoNoDia != null) || v.tipoRepre == "C")) {
                                addVenda(v);
                            } else {
                                if (venda.conhecimento.comissaoRepresentanteLiberada == false) {
                                    alert("O Conhecimento (" + v.ctrc + ") Não Possui Comprovante de Entrega!");
                                } else {
                                    addVenda(v);
                                }
                            }

                            desabilitar();
                            visualizarComissao($("idfornecedor").value);
                        }
                        esconderCampos();
                    }                    
                    
                } catch (e) {
                    console.log(e);
                    alert(e);
                }

                //usado apenas na hora de carregar um ctrc especifico

            }

            function checaTodos() {
                try{

                    var isChecado = $("chk_todos").checked;
                    $("totalValor").innerHTML = "0.00";
                    $("totalComissao").innerHTML = "0.00";
                    $("totalParcela").innerHTML = "0.00";
                    $("totalPeso").innerHTML = "0.00";
                    $("totalPago").innerHTML = "0.00";

                    esconderCampos();

//                    var i = 1;
//                    while ($("trVenda_" + i) != null) {
//                        $("selecionado_" + i).checked = isChecado;
//                        if (isChecado) {
//                            calculaTotal(i);
//                        }
//                        i++;
//                    }
                    var maxVenda = $("maxVenda").value;
                    
                    for (var qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++) {
                        if($("selecionado_" + qtdVenda) != null){
                            $("selecionado_" + qtdVenda).checked = isChecado;                            
                            if (isChecado) {
                                calculaTotal(qtdVenda);    
                            }
                        }
                    }

                        

                }catch(e){
                    console.log(e);
                }
            }

            function getPosicoesMarcadas(vendaId){
                var posicoes = Array();
                var idx = 0;
                for (var i = 0; i <= countVenda; i++) {
                    if($("selecionado_" + i) != null){
                        if ($("selecionado_" + i).checked && $("idVenda_"+i).value == vendaId) {
                            posicoes[idx++] = i;
                        }
                    }
                }
                return posicoes;
            }

            function calculaTotal(posicao) {
                var totalValor = parseFloat($("totalValor").innerHTML);
                var totalComissao = parseFloat($("totalComissao").innerHTML);
                var totalParcela = parseFloat($("totalParcela").innerHTML);
                var totalPeso = parseFloat($("totalPeso").innerHTML);
                var totalPago = parseFloat($("totalPago").innerHTML);
                var vendaId = $("idVenda_"+posicao).value;
                
                if ($("selecionado_" + posicao).checked) {
                    if (getPosicoesMarcadas(vendaId) != undefined && getPosicoesMarcadas(vendaId).length < 2) {
                        totalPeso += parseFloat($("lbPesoCtrc_" + posicao).innerHTML);
                        totalValor += parseFloat($("valorCtrcHidden_" + posicao).value);
                    }
                    
                    totalComissao += parseFloat($("comissao_" + posicao).value);
                    totalParcela += parseFloat($("valorParcela_" + posicao).innerHTML);
                    totalPago += parseFloat($("valorPago_" + posicao).innerHTML);
                } else {
                    if (getPosicoesMarcadas(vendaId) != undefined && getPosicoesMarcadas(vendaId).length < 1) {
                        totalPeso -= parseFloat($("lbPesoCtrc_" + posicao).innerHTML);
                        totalValor -= parseFloat($("valorCtrcHidden_" + posicao).value);
                    }
                    totalComissao -= parseFloat($("comissao_" + posicao).value);
                    totalParcela -= parseFloat($("valorParcela_" + posicao).innerHTML);
                    totalPago -= parseFloat($("valorPago_" + posicao).innerHTML);
                }

                $("totalValor").innerHTML = formatoMoeda(totalValor);
                $("totalComissao").innerHTML = formatoMoeda(totalComissao);
                $("totalParcela").innerHTML = formatoMoeda(totalParcela);
                $("totalPeso").innerHTML = formatoMoeda(totalPeso);
                $("totalPago").innerHTML = formatoMoeda(totalPago);
                
                esconderCampos();
            }

            function limparTRsVenda() {                
                var maxVenda = ($("countVenda") != null ? $("countVenda").value : 0); 
                for (var qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++) {
                    if($("trVenda_"+qtdVenda) != null){
                        jQuery("#trVenda_"+qtdVenda).remove();
                    }
                }
            }

            function carregarCtrc(campo) {
                function e(transport) {
                    respostaLocalizarCTRCAjax(transport);
                    campo.value = "";
                    campo.focus();
                    recalcula();
                }//funcao e()
                var conh = "";

                if (!validaData($("dtemissao1").value) || $("dtemissao1").value.length != 10)
                    return alertMsg("A Data do Período de Pesquisa é Inválida!\nO formato correto é: dd/mm/aaaa");

                if (!validaData($("dtemissao2").value) || $("dtemissao2").value.length != 10)
                    return alertMsg("A Data do Período de Pesquisa é Inválida!\nO formato correto é: dd/mm/aaaa");

                if ($('idfornecedor').value == 0)
                    return alertMsg("Informe o Vendedor/Representante Corretamente!");

                if (wasNull("tipoConsulta,dtemissao1,dtemissao2,tipoComissao,tipoVendedor,calcularComissao,idfornecedor,filialId"))
                    return alertMsg("Preencha os Campos de Pesquisa Corretamente!");

                /*
                 if($("tipoConsultaPrinc").value != "" && !confirm("Deseja alterar os parametros de pesquisa?")){
                 return false;
                 }
                 */
                //limparTRsVenda();

                var tipoConsulta = $("tipoConsulta").value;
                var dtIni = $("dtemissao1").value;
                var dtFim = $("dtemissao2").value;
                var tipoComissao = $("tipoComissao").value;
                var tipoVendedor = $("tipoVendedor").value;
                var calcularComissao = $("calcularComissao").value;
                var idForne = $("idfornecedor").value;
                var idFilial = $("filialId").value;

                var tipoCalculoRepresentante = $("tipoCalculoRepresentante").value;
                var id = $("id").value;

                //----------------------------------------
                var numCtrc = campo.value;
                
                

                if (numCtrc == "")
                    return alertMsg("Informe o Número Corretamente!");

                var count = 1;
                while ($("selecionado_" + count) != null) {
                    conh += (count != 1 ? "," : "") + "'" + $("ctrcHidden_" + count).value + "'";
                    count++;
                }

                espereEnviar("", true);
                tryRequestToServer(function () {
                    var acao = "carregarCtrc";

                    if ($("tipoComissao").value == "v") {
                        return false;
                    }
                    
                        new Ajax.Request("./cadpagamento_comissao.jsp?acao=" + acao
                            + "&numCtrc=" + numCtrc
                            + "&conh=" + conh
                            + "&tipoConsulta=" + tipoConsulta
                            + "&dtIni=" + dtIni
                            + "&dtFim=" + dtFim
                            + "&tipoComissao=" + tipoComissao
                            + "&tipoVendedor=" + tipoVendedor
                            + "&calcularComissao=" + calcularComissao
                            + "&tipoCalculoRepresentante=" + tipoCalculoRepresentante
                            + "&idForne=" + idForne
                            + "&id=" + id
                            + "&idFilial=" + idFilial,
                            {method: 'post', onSuccess: e, onError: e});
                });
            }

            function getTiposMarcados() {
                var tipos = "";

                if ($("tpNormal").checked) {
                    tipos += "'n'"
                }
                if ($("tpComplementar").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'c'";
                }
                if ($("tpReentrega").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'r'";
                }
                if ($("tpDevolucao").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'d'";
                }

                if ($("tpSubstituicao").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'s'";
                }
                if ($("tpCortesia").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'b'";
                }
                if ($("tpPallets").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'p'";
                }
                if ($("tpDiarias").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'i'";
                }
                if ($("tpEntrega").checked) {
                    tipos += (tipos == "" ? "" : ",") + "'l'";
                }

                return tipos;
            }

            function localizarCTRC() {
                
                function e(transport){
                        var localizaRepresentante = true;
                        respostaLocalizarCTRCAjax(transport, localizaRepresentante);
                    }//funcao e()

                if (!validaData($("dtemissao1").value) || $("dtemissao1").value.length != 10)
                    return alertMsg("A Data do Período de Pesquisa é Inválida!\nO formato correto é: dd/mm/aaaa");

                if (!validaData($("dtemissao2").value) || $("dtemissao2").value.length != 10)
                    return alertMsg("A Data do Período de Pesquisa é Inválida!\nO formato correto é: dd/mm/aaaa");

                if ($('idfornecedor').value == 0)
                    return alertMsg("Informe o Vendedor/Representante Corretamente.");

                if (wasNull("tipoConsulta,dtemissao1,dtemissao2,tipoComissao,tipoVendedor,calcularComissao,idfornecedor,filialId"))
                    return alertMsg("Preencha os Campos de Pesquisa Corretamente!");
                
                    if ((isPrimeiro || $("tipoConsultaPrinc").value != "") && !confirm("Deseja Alterar os Parametros de Pesquisa?")) {
                        limparTRsVenda();
                        return false;
                    }                    
                
                limparTRsVenda();
                
                var tipoConsulta = $("tipoConsulta").value;
                var dtIni = $("dtemissao1").value;
                var dtFim = $("dtemissao2").value;
                var tipoComissao = $("tipoComissao").value;
                var tipoVendedor = $("tipoVendedor").value;
                var calcularComissao = $("calcularComissao").value;                
                var idForne = $("idfornecedor").value;
                var idFilial = $("filialId").value;
                var tipoCalculoRepresentante = $("tipoCalculoRepresentante").value;
                var id = $("id").value;
                
                var impostoIcms = ($("icms").checked ? true : false);
                var impostoPis = ($("pis").checked ? true : false);
                var impostoCofins = ($("cofins").checked ? true : false);
                var impostoCssl = ($("cssl").checked ? true : false);
                var impostoIr = ($("ir").checked ? true : false);
                var impostoInss = ($("inss").checked ? true : false);                
                
                var retirarContratoFreteBaseCalculo = ($("retirarContratoFreteBaseCalculo").checked ? true : false);
                var pagarComissaoJuros =  "rj";
                var pagarComissaoDesconto = "rd";
                
                if($("tipoConsulta").value == "pa"){
                    pagarComissaoJuros = ($("valorRecebidoJuros").checked ? "rj" : "oj");
                    pagarComissaoDesconto = ($("valorRecebidoDesconto").checked ? "rd" : "od");
                }

                espereEnviar("", true);
                tryRequestToServer(function () {
                    var acao = "localizarCTRCVendedor";
                    if ($("tipoComissao").value == "r") {
                        acao = "localizarCTRCRedespachante";
                    }

                    new Ajax.Request("./cadpagamento_comissao.jsp?acao=" + acao
                            + "&tipoConsulta=" + tipoConsulta + "&dtIni=" + dtIni
                            + "&dtFim=" + dtFim + "&tipoComissao=" + tipoComissao
                            + "&tipoVendedor=" + tipoVendedor
                            + "&calcularComissao=" + calcularComissao
                            + "&tipoCalculoRepresentante=" + tipoCalculoRepresentante
                            + "&idForne=" + idForne
                            + "&id=" + id
                            + "&idFilial=" + idFilial
                            + "&tiposConhecimento=" + getTiposMarcados()
                            + "&isIcms="+impostoIcms
                            + "&isPis="+impostoPis
                            + "&isCofins="+impostoCofins
                            + "&isCssl="+impostoCssl
                            + "&isIr="+impostoIr
                            + "&isInss="+impostoInss                            
                            + "&pagarComissaoJuros="+pagarComissaoJuros
                            + "&pagarComissaoDesconto="+pagarComissaoDesconto                    
                            + "&isRetirarContratoFreteBaseCalculo="+retirarContratoFreteBaseCalculo,
                            {method: 'post', onSuccess: e, onError: e});
                });
                
                
            }

                
            function aoClicarNoLocaliza(idjanela) {
                function indiceJanela(initPos, finalPos) {
                    return idjanela.substring(initPos, finalPos);
                }
                
                isPrimeiro = true;
                
                if (idjanela.indexOf("redespachante") > -1) {
                    if ($("idfornecedor").value == 0 || ($("idfornecedor").value == $("idredespachante").value)) {
                        isPrimeiro = false;
                    }
                    $("idfornecedor").value = $("idredespachante").value;
                    $("fornecedor").value = $("redspt_rzs").value;
                    $("cpf_cnpj").value = $("redspt_cnpj").value;
                    $("id_und").value = $("unidade_custo_id_comissao").value;
                    $("sigla_und").value = $("unidade_custo_sigla_comissao").value;
                    $("idplanocusto_despesa").value = $("idplcustopadrao_comissao").value;
                    $("plcusto_conta_despesa").value = $("conta_plano_comissao").value;
                    $("plcusto_descricao_despesa").value = $("descricao_plano_comissao").value;
                    $("redspt_vlkgate").value = $("vlkgate").value;
                    $("redspt_vlprecofaixa").value = $("vlprecofaixa").value;
                    $("")
                    if(isPrimeiro){
                         setTimeout(function () {localizarCTRC()}, 100);                     
                    }
                } else if (idjanela.indexOf("Vendedor") > -1) {                    
                    if ($("idfornecedor").value == 0 || ($("idfornecedor").value == $("idvendedor").value)) {
                        isPrimeiro = false;
                    }                    
                    $("idfornecedor").value = $("idvendedor").value;
                    $("fornecedor").value = $("ven_rzs").value;
                    $("cpf_cnpj").value = $("cgc_vendedor").value;
                    $("id_und").value = $("unidade_custo_id_comissao").value;
                    $("sigla_und").value = $("unidade_custo_sigla_comissao").value;
                    $("idplanocusto_despesa").value = $("idplcustopadrao_comissao").value;
                    $("plcusto_conta_despesa").value = $("conta_plano_comissao").value;
                    $("plcusto_descricao_despesa").value = $("descricao_plano_comissao").value;
                    if(isPrimeiro){
                        
                        setTimeout(function () {localizarCTRC()}, 100);                        
                    }
                }
            }

            function alteraTipo(valor) {
//                console.log(valor);
                if (valor == "v") {
                    $("lbVendedor").style.display = "";
                    $("lbSupervisor").style.display = "none";
                    $("trConsultaCTRC").style.display = "none";
                    $("lbRepresentante").style.display = "none";
                    $("localiza_vendedor").style.display = "";
                    $("localiza_redespachante").style.display = "none";
                    $("tipoConsultaEntrega").style.display = "none";
                    $("tipoConsultaPagamento").style.display = "";
                    $("tipoCalculoRepresentante").style.display = "none";
                    $("tipoVendedor").style.display = "";
                    $("tipoVendedor").value = "L";
                    $("tipoVendedor").disabled = false;
                    $("tdValorParcela").innerHTML = "Valor Parcela";
                    $("totalParcela").innerHTML = "0.00";
                    $("tdValorPago").innerHTML = "Valor Pago";
                    $("totalPago").innerHTML = "0.00";
                } else
                if (valor == "s") {
                    $("lbSupervisor").style.display = "";
                    $("tipoConsultaPagamento").style.display = "";
                    $("lbVendedor").style.display = "none";
                    $("trConsultaCTRC").style.display = "none";
                    $("lbRepresentante").style.display = "none";
                    $("localiza_vendedor").style.display = "";
                    $("localiza_redespachante").style.display = "none";
                    $("tipoConsultaEntrega").style.display = "none";
                    $("tipoCalculoRepresentante").style.display = "none";
                    $("tipoVendedor").style.display = "";
                    $("calcularComissao").style.display = "";
                    $("lbCalc").style.display = "";
                    $("tipoVendedor").value = "C";
                    $("tipoVendedor").disabled = true;
                    $("tdValorParcela").innerHTML = "Valor Parcela";
                    $("totalParcela").innerHTML = "0.00";
                    $("tdValorPago").innerHTML = "Valor Pago";
                    $("totalPago").innerHTML = "0.00";
                } else if (valor == "r") {
                    $("tipoCalculoRepresentante").style.display = "none";
                    $("calcularComissao").style.display = "none";
                    $("lbCalc").style.display = "none";

                    $("lbVendedor").style.display = "none";
                    $("lbSupervisor").style.display = "none";
                    $("trConsultaCTRC").style.display = "none";
                    $("lbRepresentante").style.display = "";
                    $("localiza_vendedor").style.display = "none";
                    $("localiza_redespachante").style.display = "";
                    $("tipoConsultaEntrega").style.display = "";
                    $("tipoConsultaPagamento").style.display = "none";
                    $("tipoVendedor").style.display = "";
                    $("trConsultaCTRC").style.display = "";
                    $("tdValorParcela").innerHTML = "";
                    $("totalParcela").innerHTML = "";
                    $("tdValorPago").innerHTML = "";
                    $("totalPago").innerHTML = "";

                } else {
                    $("lbVendedor").style.display = "none";
                    $("lbSupervisor").style.display = "none";
                    $("trConsultaCTRC").style.display = "";
                    $("lbRepresentante").style.display = "";
                    $("localiza_vendedor").style.display = "none";
                    $("localiza_redespachante").style.display = "";
                    $("tipoConsultaEntrega").style.display = "";
                    $("tipoConsultaPagamento").style.display = "none";
                    $("tipoCalculoRepresentante").style.display = "";
                    $("tipoVendedor").style.display = "none";
                    $("calcularComissao").style.display = "";
                    $("lbCalc").style.display = "";
                }

                $("idfornecedor").value = "0";
                $("cpf_cnpj").value = "";
                $("fornecedor").value = "";
                $("idvendedor").value = "0";
                $("ven_rzs").value = "";
                $("ven_rzs").value = "";
                $("idredespachante").value = "0";
                $("redspt_rzs").value = "";
                $("redspt_cnpj").value = "";
                $("cgc_vendedor").value = "";

                limparTRsVenda();
            }

            function localizaredespachante() {
                post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE2%>', 'redespachante',
                        'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
            }

            function Venda(idVenda, idParcelaComissao, ctrc, filial, emissao, consignatario,
                    valorCtrc, percComissao, vlComissao, dtPagto, dtEntrega, isReadOnly,
                    selecionado, tipoCalculoComissao, peso, vlSobPeso, freteMinimo, idFornecedor,
                    vlKgAte, vlPrecoFaixa, tipoBaseComissao, tipoRepre, categoria, permissaoCombinado, cliente, valorParcela, valorPago) {
                this.idVenda = (idVenda != undefined ? idVenda : 0);
                this.idParcelaComissao = (idParcelaComissao != undefined ? idParcelaComissao : 0);
                this.ctrc = (ctrc != undefined ? ctrc : "");
                this.filial = (filial != undefined ? filial : "");
                this.emissao = (emissao != undefined ? emissao : "");
                this.consignatario = (consignatario != undefined ? consignatario : "");
                this.valorCtrc = (valorCtrc != undefined ? valorCtrc : "0.00");
                this.percComissao = (percComissao != undefined ? percComissao : "0.00");
                this.vlComissao = (vlComissao != undefined ? vlComissao : "0.00");
                this.dtPagto = (dtPagto != undefined ? dtPagto : "");
                this.dtEntrega = (dtEntrega != undefined ? dtEntrega : "");
                this.isReadOnly = (isReadOnly != undefined ? isReadOnly : true);
                this.selecionado = (selecionado != undefined ? selecionado : true);
                this.tipoCalculoComissao = (tipoCalculoComissao != undefined ? tipoCalculoComissao : "");
                this.peso = (peso != undefined ? peso : "0.00");
                this.vlSobPeso = (vlSobPeso != undefined ? vlSobPeso : "0.00");
                this.freteMinimo = (freteMinimo != undefined ? freteMinimo : "0.00");
                this.idFornecedor = (idFornecedor != undefined ? idFornecedor : "0");
                this.vlKgAte = (vlKgAte != undefined ? vlKgAte : "0");
                this.vlPrecoFaixa = (vlPrecoFaixa != undefined ? vlPrecoFaixa : "0");
                this.tipoBaseComissao = (tipoBaseComissao != undefined ? tipoBaseComissao : "");
                this.tipoRepre = (tipoRepre != undefined ? tipoRepre : "");
                this.categoria = (categoria != undefined ? categoria : "");
                this.permissaoCombinado = (permissaoCombinado != undefined ? permissaoCombinado : false);
                this.cliente = (cliente != null || cliente != undefined ? cliente : null);
                this.valorParcela = (valorParcela != undefined ? valorParcela : "0.00");
                this.valorPago = (valorPago != undefined ? valorPago : "0.00");
            }
            
            function Cliente(utilizaCriterioPagtComissaoVendedor, calcularComissaoVendedor, icmsVendedor, pisVendedor, cofinsVendedor, csslVendedor, irVendedor, inssVendedor,
                retirarContratoFreteBaseCalculoVendedor, valorJurosVendedor, valorDescontoVendedor, utilizaCriterioPagtComissaoSupervisor, 
                calcularComissaoSupervisor, icmsSupervisor, pisSupervisor, cofinsSupervisor, csslSupervisor, irSupervisor, inssSupervisor, retirarContratoFreteBaseCalculoSupervisor, 
                valorJurosSupervisor, valorDescontoSupervisor, tipoVendedor){
                    
                //FILTROS DO VENDEDOR    
                this.utilizaCriterioPagtComissaoVendedor = (utilizaCriterioPagtComissaoVendedor != null || utilizaCriterioPagtComissaoVendedor != undefined ? utilizaCriterioPagtComissaoVendedor : false)
                this.calcularComissaoVendedor = (calcularComissaoVendedor != null || calcularComissaoVendedor != undefined ? calcularComissaoVendedor : "");                
                this.icmsVendedor = (icmsVendedor != null || icmsVendedor != undefined ? icmsVendedor : false);
                this.pisVendedor = (pisVendedor != null || pisVendedor != undefined ? pisVendedor : false);
                this.cofinsVendedor = (cofinsVendedor != null || cofinsVendedor != undefined ? cofinsVendedor : false);
                this.csslVendedor = (csslVendedor != null || csslVendedor != undefined ? csslVendedor : false);
                this.irVendedor = (irVendedor != null || irVendedor != undefined ? irVendedor : false);
                this.inssVendedor = (inssVendedor != null || inssVendedor != undefined ? inssVendedor : false);
                this.retirarContratoFreteBaseCalculoVendedor = (retirarContratoFreteBaseCalculoVendedor != null || retirarContratoFreteBaseCalculoVendedor != undefined ? retirarContratoFreteBaseCalculoVendedor : false);
                
                this.valorJurosVendedor = (valorJurosVendedor != null || valorJurosVendedor != undefined ? valorJurosVendedor : "");
                this.valorDescontoVendedor = (valorDescontoVendedor != null || valorDescontoVendedor != undefined ? valorDescontoVendedor : "");
                
                //FILTROS DO SUPERVISOR
                this.utilizaCriterioPagtComissaoSupervisor = (utilizaCriterioPagtComissaoSupervisor != null || utilizaCriterioPagtComissaoSupervisor != undefined ? utilizaCriterioPagtComissaoSupervisor : false)
                this.calcularComissaoSupervisor = (calcularComissaoSupervisor != null || calcularComissaoSupervisor != undefined ? calcularComissaoSupervisor : "");                
                this.icmsSupervisor = (icmsSupervisor != null || icmsSupervisor != undefined ? icmsSupervisor : false);
                this.pisSupervisor = (pisSupervisor != null || pisSupervisor != undefined ? pisSupervisor : false);
                this.cofinsSupervisor = (cofinsSupervisor != null || cofinsSupervisor != undefined ? cofinsSupervisor : false);
                this.csslSupervisor = (csslSupervisor != null || csslSupervisor != undefined ? csslSupervisor : false);
                this.irSupervisor = (irSupervisor != null || irSupervisor != undefined ? irSupervisor : false);
                this.inssSupervisor = (inssSupervisor != null || inssSupervisor != undefined ? inssSupervisor : false);
                this.retirarContratoFreteBaseCalculoSupervisor = (retirarContratoFreteBaseCalculoSupervisor != null || retirarContratoFreteBaseCalculoSupervisor != undefined ? retirarContratoFreteBaseCalculoSupervisor : false);
                
                this.valorJurosSupervisor = (valorJurosSupervisor != null || valorJurosSupervisor != undefined ? valorJurosSupervisor : "");
                this.valorDescontoSupervisor = (valorDescontoSupervisor != null || valorDescontoSupervisor != undefined ? valorDescontoSupervisor : "");
                
                this.tipoVendedor = (tipoVendedor != null || tipoVendedor != undefined ? tipoVendedor : "");
                
            }

            var countVenda = 0;
            var criterioPagtCliente = "";
            function createElement(element,attribute,inner){
                if(typeof(element) === "undefined"){
                    return false;
                }if(typeof(inner) === "undefined"){
                    inner = "";
                }
                var el = document.createElement(element);
                if(typeof(attribute) === 'object'){
                    for(var key in attribute){
                        el.setAttribute(key,attribute[key]);
                    }
                }
                if(!Array.isArray(inner)){
                    inner = [inner];
                }
                for(var k = 0;k < inner.length;k++){
                    if(inner[k].tagName){
                        el.appendChild(inner[k]);
                    }else{
                        el.appendChild(document.createTextNode(inner[k]));
                    }
                }return el;
            }
            
            function addVenda(venda) {
                if (venda == undefined) {
                    venda = new Venda();
                }

//                if(venda.idFornecedor != "0" && venda.idFornecedor != $("idfornecedor").value){
//                    if(!confirm("O Conhecimento Informado Possui outro Representante, Deseja Alterar?"))
//                        return false;
//                }

//                if(venda.idFornecedor == "0" || venda.idFornecedor != $("idfornecedor").value){
//                    venda.vlSobPeso = $("redspt_vlsobpeso").value;
//                    venda.freteMinimo = $("redspt_vlfreteminimo").value;
//                    venda.percComissao = $("redspt_vlsobfrete").value;
//                    venda.vlPrecoFaixa = $("redspt_vlprecofaixa").value;
//                    venda.vlFreteMinimo = $("redspt_vlfreteminimo").value;
//                }
                countVenda++;
                    
                var _tr1 = createElement("tr", {
                    name: "trVenda_" + countVenda, id: "trVenda_" + countVenda, class: "CelulaZebra2"});

                //Check
                var _td1 = createElement("td");
                var _ip1 = createElement("input", {
                    name: "selecionado_" + countVenda,
                    id: "selecionado_" + countVenda,
                    onClick: "calculaTotal(" + countVenda + ")",
                    type: "checkbox"
                });
                
                if (venda.selecionado || venda.selecionado == "true") {
                    _ip1.checked = true;
                }

                var _ip1_2 = createElement("input", {
                    name: "idVenda_" + countVenda,
                    id: "idVenda_" + countVenda,
                    type: "hidden",
                    value: venda.idVenda
                });
                var _ip1_3 = createElement("input", {
                    name: "idParcelaComissao_" + countVenda,
                    id: "idParcelaComissao_" + countVenda,
                    type: "hidden",
                    value: venda.idParcelaComissao
                });

                var _ip1_4 = createElement("input", {
                    name: "valorCtrcHidden_" + countVenda,
                    id: "valorCtrcHidden_" + countVenda,
                    type: "hidden",
                    value: venda.valorCtrc
                });


                var _ip1_5 = createElement("label", {
                    id: "tipoBaseComiss_" + countVenda
                });

                _ip1_5.innerHTML = venda.tipoBaseComissao;


                var _ip1_6 = createElement("input", {
                    name: "ctrcHidden_" + countVenda,
                    id: "ctrcHidden_" + countVenda,
                    type: "hidden",
                    value: venda.ctrc
                });

                var _ip1_7 = createElement("input", {
                    name: "percComissaoHidden_" + countVenda,
                    id: "percComissaoHidden_" + countVenda,
                    type: "hidden",
                    value: venda.percComissao
                });

                var _ip1_8 = createElement("input", {
                    name: "vlSobPesoHidden_" + countVenda,
                    id: "vlSobPesoHidden_" + countVenda,
                    type: "hidden",
                    value: venda.vlSobPeso
                });

                var _ip1_9 = createElement("input", {
                    name: "freteMinimoHidden_" + countVenda,
                    id: "freteMinimoHidden_" + countVenda,
                    type: "hidden",
                    value: venda.freteMinimo
                });

                var _ip1_10 = createElement("input", {
                    name: "vlKgAteHidden_" + countVenda,
                    id: "vlKgAteHidden_" + countVenda,
                    type: "hidden",
                    value: venda.vlKgAte
                });

                var _ip1_11 = createElement("input", {
                    name: "vlPrecoFaixaHidden_" + countVenda,
                    id: "vlPrecoFaixaHidden_" + countVenda,
                    type: "hidden",
                    value: venda.vlPrecoFaixa
                });
                var _ip1_12 = createElement("input", {
                    name: "tipoRepresentante_" + countVenda,
                    id: "tipoRepresentante_ " + countVenda,
                    type: "hidden",
                    value: venda.tipoRepre
                });
                var _ip1_13 = createElement("input", {
                    name: "categoriaHidden",
                    id: "categoriaHidden",
                    type: "hidden",
                    value: venda.categoria
                });
                var _div1 = createElement("div", {
                    align: "center"
                });
                _div1.appendChild(_ip1);
                _div1.appendChild(_ip1_2);
                _div1.appendChild(_ip1_3);
                _div1.appendChild(_ip1_4);
                _div1.appendChild(_ip1_6);
                _div1.appendChild(_ip1_7);
                _div1.appendChild(_ip1_8);
                _div1.appendChild(_ip1_9);
                _div1.appendChild(_ip1_10);
                _div1.appendChild(_ip1_11);
                _div1.appendChild(_ip1_12);
                _div1.appendChild(_ip1_13);
                _td1.appendChild(_div1);

                //numero
                var _divNumeroCtrc = createElement("div", {class: "linkEditar", onClick: "abrirCtrc(" + venda.idVenda + ",'" + venda.categoria + "')"});
                _divNumeroCtrc.innerHTML = venda.ctrc;
                var _td2 = createElement("td");
                _td2.appendChild(_divNumeroCtrc);
                //Filial
                var _td3 = createElement("td", venda.filial);
                _td3.innerHTML = venda.filial;
                //Filial
                var _tdTipoRepre = createElement("td", {align: "center"});
                _tdTipoRepre.innerHTML = venda.tipoRepre;
                //consignatario
                var _td4 = createElement("td");
                var _ip4 = createElement("input", {
                    name: "consignatario_" + countVenda, id: "consignatario_" + countVenda,
                    type: "text", value: venda.consignatario, size: "28", class: "inputtexto"});

                _ip4.readOnly = venda.isReadOnly;
                _ip4.className = 'inputReadOnly';
            
                _td4.appendChild(_ip4); // Atualiza

                //emissao
                var _td5 = createElement("td", {align: "right"});
                _td5.innerHTML = venda.emissao;
                //dt pgto
                var _td6 = createElement("td", {align: "right"});
                _td6.innerHTML = venda.dtPagto;
                //dt entrega
                var _td7 = createElement("td", {align: "right"});
                _td7.innerHTML = venda.dtEntrega;
                //peso
                var _td8 = createElement("td", {align: "right"});
                var _ip8 = createElement("label", {name: "lbPesoCtrc_" + countVenda, id: "lbPesoCtrc_" + countVenda});
                _ip8.innerHTML = venda.peso;
                _td8.appendChild(_ip8); // Atualiza

                //valor
                var _td9 = createElement("td", {align: "right"});
                var _ip9 = createElement("label", {name: "lbValorCtrc_" + countVenda, id: "lbValorCtrc_" + countVenda});
                _ip9.innerHTML = venda.valorCtrc;
                _td9.appendChild(_ip9); // Atualiza
                _td9.appendChild(_ip1_5);

                //calc
                var _td10 = createElement("td", {align: "right"});

                var _ip10 = createElement("label", {name: "lbPercComissao_" + countVenda, id: "lbPercComissao_" + countVenda});
                var _ip10_1 = createElement("select", {
                    name: "tipoCalculoItem_" + countVenda,
                    readOnly: true,
                    id: "tipoCalculoItem_" + countVenda,
                    //onChange:"alterarCalculo("+countVenda+");recalcula();",
                    onChange: "recalcula();",
                    class: "inputtexto"});
                
                //                var _ip10_1c = Builder.node("option", {value: 'com'},'Combinado');
                var _ip10_1a = createElement("option", {value: 'por'}, '%');
                var _ip10_1b = createElement("option", {value: 'pes'}, 'R$/Kg');

                _ip10_1.appendChild(_ip10_1a); // Atualiza
                _ip10_1.appendChild(_ip10_1b); // Atualiza
                
                if (venda.tipoCalculoComissao == "%") {
                    _ip10_1.value = "por";
                } else {
                    _ip10_1.value = "pes";
                }
                _ip10_1.style.width = "60px";

                if ($('tipoComissao').value == "r" && $('tipoCalculoRepresentantePrinc').value != "utiliz") {
                    _ip10.innerHTML = venda.percComissao;
                    _ip10_1.style.display = "";
                    //alterarCalculo(countVenda);
                } else if ($('tipoComissao').value == "r" && $('tipoCalculoRepresentantePrinc').value == "utiliz") {
                    _ip10.innerHTML = "";
                    _ip10_1.style.display = "none";
                } else if ($('tipoComissao').value != "r") {
                    _ip10.innerHTML = venda.percComissao;
                    _ip10_1.style.width = "40px";
                    _ip10_1.disabled = "true";
                    _ip10_1.className = 'inputReadOnly';
                }
                
//              _ip10_1.appendChild(_ip10_1c); // Atualiza  NÃO SE USA MAIS ESSA FUNCIONALIDADE NO PAGAMENTO DE COMISSÃO
                var _chk10 = createElement("input", {type: "checkbox", name: "chkCombinado_" + countVenda, id: "chkCombinado_" + countVenda, onclick: "alterarComissaoCombinado(" + countVenda + ")"});
                var _lb10 = createElement("label", {name: "lbCombinado_" + countVenda, id: "lbCombinado_" + countVenda}, 'Alterar Comissão');
                
                //Validando a permissão para alterar o valor da comissao;
                if ($('tipoComissao').value == "r" && venda.permissaoCombinado) {
                    _chk10.style.display = '';
                    _lb10.style.display = '';
                } else {
                    _chk10.style.display = 'none';
                    _lb10.style.display = 'none';
                }
                
                
                
                _td10.appendChild(_chk10); // Atualiza
                _td10.appendChild(_lb10); // Atualiza
                _td10.appendChild(_ip10); // Atualiza
                _td10.appendChild(_ip10_1); // Atualiza

                //comissao
                var _td11 = createElement("td", {align: "right"});//novo elemento campo
                var _ip11 = createElement("input", {
                    name: "comissao_" + countVenda,
                    id: "comissao_" + countVenda,
                    type: "text", value: venda.vlComissao,
                    size: "8",
                    maxLength: "10",
                    onchange: 'seNaoFloatReset(this,\'0.00\');recalcula();',
                    class: "inputtexto",
                    style:"text-align:right"
                });
                if (venda.isReadOnly) { 
                    _ip11.readOnly = venda.isReadOnly;
                    _ip11.className = 'inputReadOnly';
                }
                
                var _ip11_b = createElement("input", {
                    name: "comissaoHidden_" + countVenda,
                    id: "comissaoHidden_" + countVenda,
                    type: "hidden", value: venda.vlComissao
                });                
                
                var _tdInfCliente = createElement("td",{
                    id:"infCliente_" + countVenda,
                    id:"infCliente_" + countVenda
                });
                
                var _divInfCliente = createElement("div",{
                    id:"divInfCliente_" + countVenda,
                    name:"divInfCliente_" + countVenda,
                    align:"center"
                });
                
                var _imgInfCliente = createElement("img",{
                    class:"imagemLink",
                    width:"20px",
                    height:"20px",                    
                    src:"img/atencao.gif",
                    title:"Verificar critério de pagamento da comissão",
                    onclick:"mostrarCriterioPagtComissao('"+venda.cliente.utilizaCriterioPagtComissaoVendedor+"','"+venda.cliente.calcularComissaoVendedor+"','"+venda.cliente.icmsVendedor
                            +"','"+venda.cliente.pisVendedor+"','"+venda.cliente.cofinsVendedor+"','"+venda.cliente.csslVendedor+"','"+venda.cliente.irVendedor+"','"+venda.cliente.inssVendedor
                            +"','"+venda.cliente.valorJurosVendedor+"','"+venda.cliente.valorDescontoVendedor
                            +"','"+venda.cliente.retirarContratoFreteBaseCalculoVendedor+"','"+venda.cliente.utilizaCriterioPagtComissaoSupervisor+"','"+venda.cliente.calcularComissaoSupervisor
                            +"','"+venda.cliente.icmsSupervisor+"','"+venda.cliente.pisSupervisor+"','"+venda.cliente.cofinsSupervisor+"','"+venda.cliente.csslSupervisor+"','"+venda.cliente.irSupervisor
                            +"','"+venda.cliente.inssSupervisor+"','"+venda.cliente.valorJurosSupervisor+"','"+venda.cliente.valorDescontoSupervisor
                            +"','"+venda.cliente.retirarContratoFreteBaseCalculoSupervisor+"','"+venda.cliente.tipoVendedor
                            +"')"
                });                
                
                if(venda.cliente.utilizaCriterioPagtComissaoVendedor || venda.cliente.utilizaCriterioPagtComissaoSupervisor){
                    _divInfCliente.appendChild(_imgInfCliente);
                }
                
                var _tdValorParcela = createElement("td",{
                    id:"tdValorParcela_"+countVenda,
                    name:"tdValorParcela_"+countVenda,
                    align:"right"
                });
                
                var _lblValorParcela = createElement("label",{
                    id:"valorParcela_"+countVenda,
                    name:"valorParcela_"+countVenda,
                });
                if($("tipoComissao").value != "r"){
                    _lblValorParcela.innerHTML = venda.valorParcela;                    
                }
                
                var _tdValorPago = createElement("td",{
                    id:"tdvalorPago_" + countVenda,
                    name:"tdvalorPago_" + countVenda,
                    align:"right"
                });
                
                var _lblValorPago = createElement("label",{
                    id:"valorPago_"+countVenda,
                    name:"valorPago_"+countVenda
                });
                
                if($("tipoComissao").value != "r"){
                    _lblValorPago.innerHTML = venda.valorPago;
                }
                
                _tdInfCliente.appendChild(_divInfCliente);
                _tdValorParcela.appendChild(_lblValorParcela);
                _tdValorPago.appendChild(_lblValorPago);

                //var _ip11 = Builder.node("label", {name: "comissao_"+countVenda , id:"comissao_"+countVenda });
                _td11.appendChild(_ip11_b); // Atualiza
                _td11.appendChild(_ip11); // Atualiza


                _tr1.appendChild(_td1);
                _tr1.appendChild(_tdInfCliente);
                _tr1.appendChild(_td2);
                _tr1.appendChild(_td3);
                if ($("tipoComissao").value == "r") {
                    visivel($("tdTipoRepre"));
                    $("tdColspanAdd").colSpan = 2;
                    _tr1.appendChild(_tdTipoRepre);
                } else {
                    invisivel($("tdTipoRepre"));
                    $("tdColspanAdd").colSpan = "1";
                }
                _tr1.appendChild(_td4);
                _tr1.appendChild(_td5);
                _tr1.appendChild(_td6);
                _tr1.appendChild(_td7);
                _tr1.appendChild(_td8);
                _tr1.appendChild(_td9);
                _tr1.appendChild(_tdValorParcela);
                _tr1.appendChild(_tdValorPago);
                _tr1.appendChild(_td10);
                _tr1.appendChild(_td11);

                //implementa
                $("vendaBody").appendChild(_tr1);

                $("countVenda").value = countVenda;

                applyFormatter();
                
                //$('comissao_'+countVenda).innerHTML = venda.vlComissao;
                if (venda.selecionado) {
                    calculaTotal(countVenda);
                }
                if (venda.idFornecedor == "0") {
                    //alterarCalculo(countVenda);
                }
                
                $("maxVenda").value = countVenda;
            }

            function alterarComissaoCombinado(idxA) {
                if ($('chkCombinado_' + idxA).checked) {
                    $('comissao_' + idxA).readOnly = false;
                    $('comissao_' + idxA).className = 'inputtexto';
                } else {
                    $('comissao_' + idxA).readOnly = true;
                    $('comissao_' + idxA).className = 'inputReadOnly';
                    $('comissao_' + idxA).value = $('comissaoHidden_' + idxA).value;
                    recalcula();
                }
            }

            function editarDespesa(id, podeExcluir) {
                window.open("./caddespesa?acao=editar&id=" + id + "&podeExcluir=" + podeExcluir, "Despesa", "height=500,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1");
            }

            function alterarCalculo(indice) {
                var tipoComissao = $("tipoComissao").value;
                var idfornecedor = $("idfornecedor").value;

                if (tipoComissao == "r" && idfornecedor != "0") {
                    if ($("tipoCalculoItem_" + indice).value == "com") {
                        $("comissao_" + indice).readOnly = false;
                        $("comissao_" + indice).className = "inputtexto";
                        $("lbPercComissao_" + indice).innerHTML = "";
                    } else {
                        $("comissao_" + indice).readOnly = "true";
                        $("comissao_" + indice).className = "inputReadOnly";

                        var comissaoValor = 0;
                        var percentcomissaoValor = parseFloat($("percComissaoHidden_" + indice).value);
                        var vlfreteminimo = parseFloat($("freteMinimoHidden_" + indice).value);

                        var vlkgate = parseFloat($("vlKgAteHidden_" + indice).value);
                        var vlprecofaixa = parseFloat($("vlPrecoFaixaHidden_" + indice).value);

                        var totalPeso = parseFloat($("lbPesoCtrc_" + indice).innerHTML);
                        var vlsobpeso = parseFloat($("vlSobPesoHidden_" + indice).value);
                        var totalprestacao = parseFloat($("lbValorCtrc_" + indice).innerHTML);
                        if ($("tipoCalculoItem_" + indice).value == "pes") { // por peso
                            if (vlkgate < totalPeso) {
                                //totalPeso -= vlkgate;
                                comissaoValor = (totalPeso * vlsobpeso) + vlprecofaixa;
                            } else {
                                comissaoValor = vlprecofaixa;
                            }

                            //comissaoValor = totalPeso * vlsobpeso;
                            $("lbPercComissao_" + indice).innerHTML = formatoMoeda(vlsobpeso);
                        } else {
                            // porcento
                            comissaoValor = totalprestacao * percentcomissaoValor / 100;
                            $("lbPercComissao_" + indice).innerHTML = formatoMoeda(percentcomissaoValor);
                        }

                        if ($("tipoComissao").value == "r") {
                            comissaoValor = (comissaoValor < vlfreteminimo ? vlfreteminimo : comissaoValor);
                        }
                        $("comissao_" + indice).value = formatoMoeda(comissaoValor);
                    }
                }
            }

            function recalcula() {
                //var isChecado = $("chk_todos").checked;
                $("totalValor").innerHTML = "0.00";
                $("totalComissao").innerHTML = "0.00";
                $("totalParcela").innerHTML = "0.00";
                $("totalPeso").innerHTML = "0.00";
                $("totalPago").innerHTML = "0.00";

                esconderCampos();
                var maxVenda = $("countVenda").value;
                for (var qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++) {                    
                    if ($("selecionado_" + qtdVenda) != null && $("selecionado_" + qtdVenda).checked) {
                        calculaTotal(qtdVenda);    
                    }
                }
//                var i = 1;
//                while ($("trVenda_" + i) != null) {
//                    //$("selecionado_"+i).checked = isChecado;
//                    if ($("selecionado_" + i).checked) {
//                        calculaTotal(i);
//                    }
//                    i++;
//                }
            }

            function validaTipoDate(campoData) {
                if ((campoData.value == "en" && $("tipoComissao").value == "r")) {
                    campoData.value = "en";
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
                var rotina = "pagamento_comissao";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregaComissao ? cadCom.getComissao().getId() : 0)%>;
                //console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);

            }

            function setDataAuditoria() {
                $("dataDeAuditoria").value = "<%=carregaComissao ? Apoio.getDataAtual() : ""%>";
                $("dataAteAuditoria").value = "<%=carregaComissao ? Apoio.getDataAtual() : ""%>";

            }
            
            function marcarTodosImpostos(){
//                $("icms").checked = $("impostoFederais").checked;
                $("pis").checked = $("impostoFederais").checked;
                $("cofins").checked = $("impostoFederais").checked;
                $("cssl").checked = $("impostoFederais").checked;
                $("ir").checked = $("impostoFederais").checked;
                $("inss").checked = $("impostoFederais").checked;
            }
            
            function pagarComissao(tipoPagamento){
                if(tipoPagamento == 'pa'){
                    $("pagarComissao").style.display = "";
                }else{ 
                    $("pagarComissao").style.display = "none";                    
                }
            }
            function criterioCalculoComissao(calculoComissao){
                if(calculoComissao == 'l'){
                    $("trImpostos").style.display = "";                    
                }else if(calculoComissao == 'b'){
                    $("trImpostos").style.display = "none";
                }
            }
            var criterioPagamentoComissaoCliente = "";
            function mostrarCriterioPagtComissao(utilizaCriterioPagtComissaoVendedor,calcularComissaoVendedor,icmsVendedor,pisVendedor,cofinsVendedor,csslVendedor,irVendedor,inssVendedor,
                valorJurosVendedor, valorDescontoVendedor,retirarContratoFreteBaseCalculoVendedor,utilizaCriterioPagtComissaoSupervisor,
                calcularComissaoSupervisor,icmsSupervisor,pisSupervisor,cofinsSupervisor,csslSupervisor,irSupervisor,inssSupervisor,valorJurosSupervisor, valorDescontoSupervisor,
                retirarContratoFreteBaseCalculoSupervisor, tipoVendedor){
                criterioPagamentoComissaoCliente = "O critério de pagamento da comissão que foi definido no cadastro do cliente:";
                if(utilizaCriterioPagtComissaoVendedor=="true" && tipoVendedor == 'vendedor'){
                    criterioPagamentoComissaoCliente += "\r\n";                    
                    if(calcularComissaoVendedor == 'l'){
                        criterioPagamentoComissaoCliente += "* Valor Líquido";                        
                    }else if(calcularComissaoVendedor == 'b'){
                        criterioPagamentoComissaoCliente += "* Valor Bruto";
                    }
                    criterioPagamentoComissaoCliente += "\r\n";
                    
                    if(retirarContratoFreteBaseCalculoVendedor=="true"){                        
                        criterioPagamentoComissaoCliente += "* Retirar contrato frete da base de cálculo";
                        criterioPagamentoComissaoCliente += "\r\n";
                    }                    
                    
                    if(icmsVendedor=="true"){
                        criterioPagamentoComissaoCliente += "* ICMS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(pisVendedor=="true"){                        
                        criterioPagamentoComissaoCliente += "* PIS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(cofinsVendedor=="true"){                        
                        criterioPagamentoComissaoCliente += "* COFINS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(csslVendedor=="true"){                                                
                        criterioPagamentoComissaoCliente += "* CSSL";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(irVendedor=="true"){                        
                        criterioPagamentoComissaoCliente += "* IR";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(inssVendedor=="true"){                        
                        criterioPagamentoComissaoCliente += "* INSS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }                   
                    
                    if($("tipoConsulta").value=="pa"){                        
                        if(valorJurosVendedor == 'rj'){                        
                            criterioPagamentoComissaoCliente += "* Valor Recebido (Juros)";                        
                        }else if(valorJurosVendedor == 'oj'){                                                
                            criterioPagamentoComissaoCliente += "* Valor Original (Juros)";                        
                        }
                        criterioPagamentoComissaoCliente += "\r\n";  

                        if(valorDescontoVendedor == 'rd'){                        
                            criterioPagamentoComissaoCliente += "* Valor Recebido (Desconto)";                        
                        }else if(valorDescontoVendedor == 'od'){                        
                            criterioPagamentoComissaoCliente += "* Valor Original (Desconto)";                        
                        }
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    
                }else if(utilizaCriterioPagtComissaoSupervisor=="true" && tipoVendedor == 'supervisor'){
                    
                    criterioPagamentoComissaoCliente += "\r\n";
                    if(calcularComissaoSupervisor == "l"){
                        criterioPagamentoComissaoCliente += "* Valor Líquido";                        
                    }else if(calcularComissaoSupervisor == "b"){
                        criterioPagamentoComissaoCliente += "* Valor Bruto";
                    }                    
                    criterioPagamentoComissaoCliente += "\r\n";
                    
                    if(retirarContratoFreteBaseCalculoSupervisor=="true"){                        
                        criterioPagamentoComissaoCliente += "* Retirar contrato frete da base de cálculo";
                        criterioPagamentoComissaoCliente += "\r\n";
                    }                    
                    
                    if(icmsSupervisor=="true"){
                        criterioPagamentoComissaoCliente += "* ICMS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(pisSupervisor=="true"){                        
                        criterioPagamentoComissaoCliente += "* PIS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(cofinsSupervisor=="true"){                        
                        criterioPagamentoComissaoCliente += "* COFINS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(csslSupervisor=="true"){                                                
                        criterioPagamentoComissaoCliente += "* CSSL";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(irSupervisor=="true"){                        
                        criterioPagamentoComissaoCliente += "* IR";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }
                    if(inssSupervisor=="true"){                        
                        criterioPagamentoComissaoCliente += "* INSS";                        
                        criterioPagamentoComissaoCliente += "\r\n";
                    }                    
                    
                    if($("tipoConsulta").value=="pa"){
                        if(valorJurosSupervisor == 'rj'){                        
                            criterioPagamentoComissaoCliente += "* Valor Recebido (Juros)";                        
                        }else if(valorJurosSupervisor == 'oj'){                                                
                            criterioPagamentoComissaoCliente += "* Valor Original (Juros)";                        
                        }
                        criterioPagamentoComissaoCliente += "\r\n";  

                        if(valorDescontoSupervisor == 'rd'){                        
                            criterioPagamentoComissaoCliente += "* Valor Recebido (Desconto)";                        
                        }else if(valorDescontoSupervisor == 'od'){                        
                            criterioPagamentoComissaoCliente += "* Valor Original (Desconto)";                        
                        }
                        criterioPagamentoComissaoCliente += "\r\n";                        
                    }
                }
                
                alert(criterioPagamentoComissaoCliente);
            }
            
            
            function esconderCampos(){
                if ($("tipoComissao").value == "r") {
                    $("totalPago").innerHTML = "";
                    $("totalParcela").innerHTML = "";
                }
            }
            
            function visualizarComissao(idVendedor){
                var isVisualizarComissao = false;
                <%if(!Apoio.getUsuario(request).isIsVendedor()) {%>
                    isVisualizarComissao = true;
                <%}else{
                    for (UsuarioVendedor vend : Apoio.getUsuario(request).getItens()) {%>
                        if(idVendedor == '<%=vend.getVendedor().getIdfornecedor()%>'){
                            isVisualizarComissao = true;
                        }
                    <%}
                }%>
                    
                var maxVenda = $("maxVenda").value;
                
                for (var qtdVenda = 1; qtdVenda <= maxVenda; qtdVenda++) {
                    if($("trVenda_"+qtdVenda) != null){
                        if(isVisualizarComissao){
                           $("lbPercComissao_"+qtdVenda).style.display = ""; 
                           $("tipoCalculoItem_"+qtdVenda).style.display = ""; 
                        }else{
                           $("lbPercComissao_"+qtdVenda).style.display = "none"; 
                           $("tipoCalculoItem_"+qtdVenda).style.display = "none";                         
                        }                        
                    }
                }
            }
            
        </script>
        <style type="text/css">
            <!--
            .styleNum {text-align: right}
            -->
        </style>
    </head>

    <body onLoad="aoCarregar();applyFormatter();setDataAuditoria();AlterneAb('tdAbaInfoPesq', 'divAbaInfoPesq');">
        <img src="img/banner.gif" >
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr>
                <td width="613" align="left">
                    <b>Lan&ccedil;amento de Pagamento de Comiss&atilde;o</b>
                </td>
                <td width="56" >
                    <input  name="bt_consultar" type="button" class="inputbotao" id="bt_consultar" onClick="javascript:tryRequestToServer(function(){voltar();});" value=" Voltar para Consulta ">
                </td>
            </tr>
        </table>
        <br>
        <form method="post" action="./cadpagamento_comissao.jsp" id="formulario" target="pop">
            <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td colspan="7"  class="tabela">
                        <div align="center">Dados Principais</div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="5%">Data:</td>
                    <td class="CelulaZebra2" width="12%">
                        <input type="hidden" id="redspt_vlsobpeso" name="redspt_vlsobpeso" value="0">
                        <input type="hidden" id="redspt_vlfreteminimo" name="redspt_vlfreteminimo" value="0">
                        <input type="hidden" id="redspt_vlsobfrete" name="redspt_vlsobfrete" value="0">
                        <input type="hidden" id="redspt_vlprecofaixa" name="redspt_vlprecofaixa" value="0">
                        <input type="hidden" id="redspt_vlkgate" name="redspt_vlkgate" value="0">
                        <input type="hidden" id="vlkgate" name="vlkgate" value="0">
                        <input type="hidden" id="vlprecofaixa" name="vlprecofaixa" value="0">
                        <input type="hidden" id="id" name="id" value="0">
                        <input type="hidden" name="acao" id="acao" value="<%=acao%>">
                        <input type="hidden" id="despesaId" name="despesaId" value="0">
                        <input type="hidden" id="valorTotal" name="valorTotal" value="0">
                        <input type="hidden" id="maxVenda" name="maxVenda" value="0">                        
                        <input name="dtLancamento" type="text" id="dtLancamento" size="10" maxlength="10" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" class="fieldDate" >
                    </td>
                    <td class="TextoCampos" width="12%">Tipo Comiss&atilde;o:</td>
                    <td class="CelulaZebra2" width="15%">
                        <select name="tipoComissao" id="tipoComissao" style="font-size:8pt;" class="fieldMin" onchange="javascript:alteraTipo(this.value);">
                            <option value="v">Vendedor</option>
                            <option value="s">Supervisor</option>
                            <option value="r">Representante</option>
                        </select>
                    </td>
                    <td class="TextoCampos" width="12%">
                        <div id="lbVendedor" >*Vendedor:</div>
                        <div id="lbRepresentante" >*Representante:</div>
                        <div id="lbSupervisor" >*Supervisor:</div>
                    </td>
                    <td class="CelulaZebra2" width="44%">
                        <input type="hidden" id="idvendedor" name="idvendedor" value="0">
                        <input type="hidden" id="ven_rzs" name="ven_rzs" value="">
                        <input type="hidden" name="idredespachante" id="idredespachante" value="0">
                        <input type="hidden" name="redspt_rzs" id="redspt_rzs" value="">
                        <input type="hidden" name="redspt_cnpj" id="redspt_cnpj" value="">
                        <input type="hidden" name="cgc_vendedor" id="cgc_vendedor" value="">

                        <input type="hidden" name="unidade_custo_id_comissao" id="unidade_custo_id_comissao" value="">
                        <input type="hidden" name="unidade_custo_sigla_comissao" id="unidade_custo_sigla_comissao" value="">
                        <input type="hidden" name="idplcustopadrao_comissao" id="idplcustopadrao_comissao" value="">
                        <input type="hidden" name="conta_plano_comissao" id="conta_plano_comissao" value="">
                        <input type="hidden" name="descricao_plano_comissao" id="descricao_plano_comissao" value="">

                        <input type="hidden" id="idfornecedor" value="" name="idfornecedor">
                        <input name="cpf_cnpj" type="text" class="inputReadOnly" id="cpf_cnpj" size="15" value="" onKeyPress="javascript:if (event.keyCode == 13)
                                    localizaFornecedorCgc('f.cpf_cnpj', this.value)">
                        <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" size="30" value="" readonly>
                        <input name="localiza_redespachante" type="button" class="inputbotao" id="localiza_redespachante" value="..." onClick="javascript:localizaredespachante();">
                        <input name="localiza_vendedor" type="button" class="inputbotao" id="localiza_vendedor" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Vendedor')">
                    </td>
                </tr>
            </table>
            <br/>
            <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td>        
                        <table align="center"  width="100%">
                            <tr>
                                <td width="20%" id="tdAbaInfoPesq" class="menu" onclick="AlterneAb('tdAbaInfoPesq', 'divAbaInfoPesq')"> Informações Pesquisa CT-e(s) </td>
                                <td width="20%" id="tdAbaInfoFinan" class="menu-sel" onclick="AlterneAb('tdAbaInfoFinan', 'divAbaInfoFinan')"> Informações Financeiras </td>                                
                                <!--<td width="20%" id="tdAbaCriterioCalculoComissao" class="menu" onclick="AlterneAb('tdAbaCriterioCalculoComissao', 'divCriterioCalculoComissao')"> Critérios de cálculo de comissão </td>-->                                
                                <td style='display: <%= carregaComissao && nivelUser == 4 ? "" : "none"%>' width="20%" id="tdAbaAuditoria" class="menu" onclick="AlterneAb('tdAbaAuditoria', 'divAbaAuditoria')"> Auditoria</td>
                                <td width="20%" style='display: "none"'></td>
                            </tr>
                        </table>
                    <div id="divAbaInfoFinan">
                        <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">

                            <tr>
                                <td class="TextoCampos" width="9%">
                                    Série:
                                </td>
                                <td class="CelulaZebra2" width="10%">
                                    <input name="serie" type="text" id="serie" size="2" maxlength="3" value="<%= carregaComissao ? comissao.getDespesa().getSerie() : "" %>" class="inputtexto">
                                </td>
                                <td class="TextoCampos" width="12%">
                                    Nota Fiscal:
                                </td>
                                <td class="CelulaZebra2" width="13%">
                                    <input name="notafiscal" type="text" id="notafiscal" size="8" maxlength="8" value="<%= carregaComissao && comissao.getDespesa().getNFiscal() != null ? comissao.getDespesa().getNFiscal() : "" %>" class="inputtexto">
                                </td>
                                <td class="TextoCampos" width="9%">
                                    Espécie:
                                </td>
                                <td class="CelulaZebra2" width="10%">
                                    <select name="especie" id="especie" class="inputtexto" style="width: 140px">
                                        <option value="">Nenhuma</option>
                                        <% for (Especie indicadorEspecie : Especie.mostrarTodos(Apoio.getUsuario(request).getConexao()) ) {%>                                        
                                            <option value="<%=indicadorEspecie.getEspecie()%>" <%= ((carregaComissao && indicadorEspecie.getEspecie().equals(comissao.getDespesa().getEspecie_().getEspecie())) ? "selected" : "") %> ><%=indicadorEspecie.getEspecie()+ " - " +indicadorEspecie.getDescricao()%> </option>
                                        <% }%>
                                    </select>
                                </td>
                                <td class="CelulaZebra2" width="10%">

                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" width="12%">*Plano de Custo:</td>
                                <td class="CelulaZebra2" width="33%">
                                    <input type="hidden" name="idplanocusto_despesa" id="idplanocusto_despesa" value="">
                                    <input name="plcusto_conta_despesa" type="text" id="plcusto_conta_despesa" class="inputReadOnly" value="" size="9" maxlength="25" readonly="true">
                                    <input type="text" value="" readonly="" size="20" id="plcusto_descricao_despesa" class="inputReadOnly" name="plcusto_descricao_despesa">
                                    <strong>
                                        <input name="localiza_plano_cartafrete" type="button" class="inputbotao" id="localiza_plano_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=20', 'Plano_custo_comissao')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Plano de Custo" onClick="javascript:getObj('idplanocusto_despesa').value = 0;
                                                javascript:getObj('plcusto_conta_despesa').value = '';
                                                javascript:getObj('plcusto_descricao_despesa').value = '';">
                                    </strong>
                                </td>
                                <td class="TextoCampos" width="12%">Unidade de Custo:</td>
                                <td class="CelulaZebra2" width="13%">
                                    <input name="id_und" type="hidden" id="id_und" value="0">
                                    <input name="sigla_und" type="text" id="sigla_und" class="inputReadOnly" value="" size="4" maxlength="25" readonly="true">
                                    <strong>
                                        <input name="localiza_unidade_cartafrete" type="button" class="inputbotao" id="localiza_unidade_cartafrete" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=39', 'und_custo')">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Unid. de Custo" onClick="javascript:getObj('id_und').value = 0;
                                                javascript:getObj('sigla_und').value = '';">
                                    </strong>
                                </td>
                                <td class="TextoCampos" width="9%">
                                    Vencimento:
                                </td>
                                <td class="CelulaZebra2" width="10%">
                                    <input name="dtVencimento" type="text" id="dtVencimento" size="10" maxlength="10" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" class="fieldDate" >
                                </td>
                                <td class="TextoCampos" width="11%">
                                    <%if (carregaComissao) {%>
                                    <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function () {
                                                editarDespesa(<%=comissao.getDespesa().getIdmovimento()%>,<%=comissao.getDespesa().isPodeExluir()%>);
                                            });">
                                        Despesa: <%=comissao.getDespesa().getIdmovimento()%>
                                    </div>
                                    <%}%>
                                </td>
                            </tr>
                        </table>
                    </div>          

                    <div id="divAbaInfoPesq">  
                        <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                            <tr>
                                <td colspan="6"  class="tabela">
                                    <input type="hidden" name="countVenda" id="countVenda" value="0"/>
                                    <input type="hidden" id="tipoConsultaPrinc" name="tipoConsultaPrinc" value="">
                                    <input type="hidden" id="dtemissao1Princ" name="dtemissao1Princ" value="">
                                    <input type="hidden" id="dtemissao2Princ" name="dtemissao2Princ" value="">
                                    <input type="hidden" id="filialIdPrinc" name="filialIdPrinc" value="">
                                    <input type="hidden" id="tipoVendedorPrinc" name="tipoVendedorPrinc" value="">
                                    <input type="hidden" id="calcularComissaoPrinc" name="calcularComissaoPrinc" value="">
                                    <input type="hidden" id="tipoCalculoRepresentantePrinc" name="tipoCalculoRepresentantePrinc" value="">
                                </td>
                            </tr>
                            <tr>
                                <td class="CelulaZebra2" width="15%">
                                    <select name="tipoConsulta" id="tipoConsulta" class="inputtexto" onchange="validaTipoDate(this);pagarComissao(this.value);">
                                        <option value="em" selected>Data de Emiss&atilde;o</option>
                                        <option value="pa" id="tipoConsultaPagamento">Data de Pagamento</option>
                                        <option value="en" id="tipoConsultaEntrega">Data de Entrega</option>
                                    </select>
                                </td>
                                <td class="CelulaZebra2" width="15%">
                                    <input name="dtemissao1" type="text" id="dtemissao1" size="11" maxlength="10"
                                           value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" class="fieldDate">
                                    <input name="dtemissao2" type="text" id="dtemissao2" size="11" maxlength="10"
                                           value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)" class="fieldDate">
                                </td>
                                <td class="TextoCampos" width="20%">Filial:</td>
                                <td class="CelulaZebra2" width="15%">
                                    <select name="filialId" id="filialId" style="font-size:8pt;" class="fieldMin">
                                        <option value="0" selected="selected">TODAS</option>
                                        <%BeanFilial fl = new BeanFilial();
                                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                                            while (rsFl.next()) {
                                                if (nivelUserFl > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                                        <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                                        <%}%>
                                        <%}%>
                                    </select>
                                </td>
                                <td class="TextoCampos" width="10%">
                                    <!--<label id="lbCalc"> Calcular Comiss&atilde;o:</label>-->
                                </td>
                                <td class="CelulaZebra2" width="20%">
<!--                                    <select name="calcularComissao" id="calcularComissao" class="inputtexto" onchange="criterioCalculoComissao(this.value);">
                                        <option value="l" selected>Valor L&iacute;quido</option>
                                        <option value="b">Valor Bruto</option>
                                    </select>-->
                                </td>
                            </tr>
                            <tr>
                                <td class="CelulaZebra2">
<!--                                    <select name="tipoVendedor" id="tipoVendedor" class="inputtexto">
                                        <option value="L" selected>Utilizar V&iacute;nculo do Vendedor nos Lan&ccedil;amentos de CTs/NFS</option>
                                        <option value="C">Utilizar V&iacute;nculo do Vendedor no Cadastro de Clientes</option>
                                    </select>-->
                                    <select style="width: 150px" name="tipoCalculoRepresentante" id="tipoCalculoRepresentante" class="inputtexto">
                                        <option value="recalc">Calcular Comiss&atilde;o</option>
                                        <option value="utiliz" selected>N&atilde;o Calcular Comiss&atilde;o (Utiliza Valores Informados nos CT-e(s))</option>
                                    </select>
                                </td>
                                <td class="TextoCampos" >
                                    Tipos de Conhecimento:
                                </td>
                                <td class="CelulaZebra2"colspan="6" >
                                    <table>
                                            <td class="TextoCampos">
                                                <div align="left">
                                                    <input name="tpNormal" type="checkbox" id="tpNormal" value="n" checked title="Normal"/>Normal &nbsp;&nbsp;
                                                </div>
                                                <div>
                                                    <input name="tpComplementar" type="checkbox" id="tpComplementar" value="c" checked title="Complementar"/>Complementar&nbsp;&nbsp;
                                                </div>
                                            </td>
                                            <td class="TextoCampos">
                                                <div align="left">
                                                    <input name="tpReentrega" type="checkbox" id="tpReentrega" value="r" checked title="Reentrega"/>Reentrega&nbsp;&nbsp;
                                                </div>
                                                <div>
                                                    <input name="tpDevolucao" type="checkbox" id="tpDevolucao" value="d" checked title="Devolução"/>Devolu&ccedil;&atilde;o&nbsp;&nbsp;
                                                </div>
                                            </td>
                                            <td class="TextoCampos">
                                                <div align="left">  
                                                    <input name="tpCortesia" type="checkbox" id="tpCortesia" value="b" checked title="Cortesia"/>Cortesia
                                                </div>
                                                <div align="left">
                                                    <input name="tpPallets" type="checkbox" id="tpPallets" value="p" checked title="Pallets"/>Pallets
                                                </div>
                                            </td>
                                            <td class="TextoCampos">
                                                <div align="left">
                                                    <input name="tpDiarias" type="checkbox" id="tpDiarias" value="i" checked title="Diárias"/>Diárias
                                                </div>
                                                <div>
                                                    <input name="tpEntrega" type="checkbox" id="tpEntrega" value="l" checked title="Entrega Local (Cobrança)"/>Entrega Local (Cobrança)
                                                    <input name="tpSubstituicao" type="checkbox" id="tpSubstituicao" checked value="s" title="Substituição"/>Substitui&ccedil;&atilde;o&nbsp;&nbsp;
                                                </div>
                                            </td>    

                                    </table>
                                    
                                </td>
                            </tr>
                            <tr style="display: none" id="trConsultaCTRC">
                                <td colspan="6">
                                    <table width="100%" align="center" cellspacing="1" class="bordaFina">
                                        <tr>
                                            <td class="TextoCampos" width="50%">
                                                Apenas o CT-e:
                                            </td>
                                            <td class="CelulaZebra2" width="50%" >
                                                <input id="numCtrc" name="numCtrc" type="text" size="11" maxlength="10" value="" class="inputtexto" onkeypress="if (event.keyCode == 13)
                                                            carregarCtrc(this)">
                                                (Informe o N&uacute;mero do CT-e e tecle "Enter")
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr class="celula">
                                <td colspan="6">Critérios de Pagamento de Comissão</td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">
                                    <label id="lbCalc"> Calcular Comiss&atilde;o:</label>
                                </td>
                                <td class="CelulaZebra2" colspan="2">
                                    <select name="calcularComissao" id="calcularComissao" class="inputtexto" onchange="criterioCalculoComissao(this.value);">
                                        <option value="l" selected>Valor L&iacute;quido</option>
                                        <option value="b">Valor Bruto</option>
                                    </select>
                                </td>
                                <td class="CelulaZebra2" colspan="3">
                                    <select name="tipoVendedor" id="tipoVendedor" class="inputtexto">
                                        <option value="L" selected>Utilizar V&iacute;nculo do Vendedor nos Lan&ccedil;amentos de CTs/NFS</option>
                                        <option value="C">Utilizar V&iacute;nculo do Vendedor no Cadastro de Clientes</option>
                                    </select>
                                </td>
                            </tr>
                            <tr class="CelulaZebra2" id="trImpostos" style="display: ">
                                <td class="TextoCamposNoAlign">
                                    <div align="center">
                                        <label>
                                            <input type="checkbox" id="icms" name="icms" value="checked" checked/>
                                            ICMS
                                        </label>                                
                                    </div>
                                </td>
                                <td colspan="5" class="TextoCamposNoAlign">
                                    <div align="center">
                                        <label>
                                            <input type="checkbox" id="impostoFederais" name="impostoFederais" value="false" onclick="marcarTodosImpostos()"/>
                                            Impostos federais
                                        </label>
                                        <label>
                                            <input type="checkbox" id="pis" name="pis" value="checked"/>
                                            PIS
                                        </label>
                                        <label>
                                            <input type="checkbox" id="cofins" name="cofins" value="checked"/>
                                            COFINS
                                        </label>
                                        <label>
                                            <input type="checkbox" id="cssl" name="cssl" value="checked"/>
                                            CSSL
                                        </label>
                                        <label>
                                            <input type="checkbox" id="ir" name="ir" value="checked"/>
                                            IR
                                        </label>
                                        <label>
                                            <input type="checkbox" id="inss" name="inss" value="checked"/>
                                            INSS
                                        </label>                                                                  
                                    </div>
                                </td>
                            </tr>
                            <tr class="CelulaZebra2">
                                <td class="TextoCamposNoAlign" colspan="6">
                                    <div align="center">
                                        <label>
                                            <input type="checkbox" id="retirarContratoFreteBaseCalculo" name="retirarContratoFreteBaseCalculo" value="checked"/>
                                            Retirar contrato frete base de cálculo
                                        </label>                                
                                    </div>
                                </td>
                            </tr>
                            <tr class="CelulaZebra2" id="pagarComissao" style="display: none">
                                <td class="TextoCampos" colspan="2">
                                    <label>
                                        Em caso de recebimentos com juros, pagar comissão sobre:
                                    </label>
                                </td>
                                <td class="TextoCamposNoAlign">
                                    <label>
                                        <input type="radio" name="valorJuros" id="valorRecebidoJuros" value="rj" checked/>
                                        Valor Recebido
                                    </label>
                                    <label>
                                        <input type="radio" name="valorJuros" id="valorOriginalJuros" value="oj"/>
                                        Valor Original
                                    </label>
                                </td>
                                <td class="TextoCampos" colspan="2">
                                    <label>
                                        Em caso de recebimentos com desconto, pagar comissão sobre:
                                    </label>
                                </td>
                                <td class="TextoCamposNoAlign">
                                    <label>
                                        <input type="radio" name="valorDesconto" id="valorRecebidoDesconto" value="rd" checked/>
                                        Valor Recebido
                                    </label>
                                    <label>
                                        <input type="radio" name="valorDesconto" id="valorOriginalDesconto" value="od"/>
                                        Valor Original
                                    </label>
                                </td>                                
                            </tr>
                            <tr>
                                <td colspan="6"  class="CelulaZebra2">
                                    <div align="center">
                                        <input name="pesquisar" type="button" class="inputbotao" id="pesquisar" value=" Pesquisar " title="Faz a Pesquisa com os Dados Informados"
                                               onClick="javascript:tryRequestToServer(function () {localizarCTRC();});">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6">
                                    <table width="100%" align="center" cellspacing="1" class="bordaFina">
                                        <tbody id="vendaBody" name="vendaBody" onload="applyFormatter();">
                                            <tr>
                                                <td width="2%" class="CelulaZebra1">
                                                    <div align="center">
                                                        <input name="chk_todos" type="checkbox" id="chk_todos" value="true" checked onClick="javascript:tryRequestToServer(function () {checaTodos();});"/>                                                
                                                    </div>
                                                </td>
                                                <td class="CelulaZebra1" width="2%"></td>
                                                <td class="CelulaZebra1" width="4%">CT-e/NFS-e</td>
                                                <td class="CelulaZebra1" width="8%">Filial</td>
                                                <td class="CelulaZebra1" id="tdTipoRepre" style="display: none" width="2%"></td>
                                                <td class="CelulaZebra1" width="15%">Consignat&aacute;rio</td>
                                                <td class="CelulaZebra1" width="6%">Emiss&atilde;o</td>
                                                <td class="CelulaZebra1" width="6%">Data Pgto</td>
                                                <td class="CelulaZebra1" width="7%" >Data Entr.</td>
                                                <td class="CelulaZebra1 styleNum" width="8%" align="right">Peso</td>
                                                <td class="CelulaZebra1 styleNum" width="8%" align="right">Valor CT-e</td>
                                                <td class="CelulaZebra1 styleNum" width="8%" align="right" id="tdValorParcela" style="display: ">Valor Parcela</td>
                                                <td class="CelulaZebra1 styleNum" width="8%" align="right" id="tdValorPago" style="display: ">Valor Pago</td>
                                                <td class="CelulaZebra1 styleNum" width="10%" align="right"></td>
                                                <td class="CelulaZebra1 styleNum" width="8%" align="right">Comiss&atilde;o</td>
                                            </tr>
                                        </tbody>
                                        <tr>
                                            <td width="3%" class="CelulaZebra1"></td>
                                            <td class="CelulaZebra1" ></td>
                                            <td class="CelulaZebra1" ></td>
                                            <td class="CelulaZebra1" id="tdColspanAdd" ></td>
                                            <td class="CelulaZebra1" ></td>
                                            <td class="CelulaZebra1" ></td>
                                            <td class="CelulaZebra1" ></td>
                                            <td class="CelulaZebra1" >
                                                <div align="right">
                                                    <b>Total:</b>
                                                </div>
                                            </td>
                                            <td class="CelulaZebra1">
                                                <div align="right">
                                                    <b>
                                                        <label name="totalPeso" id="totalPeso">0.00</label>
                                                    </b>
                                                </div>
                                            </td>
                                            <td class="CelulaZebra1">
                                                <div align="right">
                                                    <b>
                                                        <label name="totalValor" id="totalValor">0.00</label>
                                                    </b>
                                                </div>
                                            </td>
                                            <td class="CelulaZebra1">
                                                <div align="right">
                                                    <b>
                                                        <label name="totalParcela" id="totalParcela">0.00</label>
                                                    </b>
                                                </div>
                                            </td>                                            
                                            <td class="CelulaZebra1">
                                                <div align="right">
                                                    <b>
                                                        <label name="totalPago" id="totalPago">0.00</label>
                                                    </b>
                                                </div>
                                            </td>                                            
                                            <td class="CelulaZebra1" colspan="2">
                                                <div align="right">
                                                    <b>
                                                        <label name="totalComissao" id="totalComissao">0.00</label>
                                                    </b>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>              
                    <%if (nivelUser >= 2 && !(carregaComissao && nivelUserFl < 2 && comissao.getFilial().getIdfilial() != idFilialUser)) {%>

                    <%}%>
                    <div id="divAbaAuditoria">
                        <table width="100%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: <%= carregaComissao && nivelUser == 4 ? "" : "none" %>'>
                            <tr>
                                <td> 
                                    <table width="100%" align="center" cellspacing="1" class="bordaFina">
                                        <tr>
                                            <td> <%@include file="/gwTrans/template_auditoria.jsp" %></td>
                                            <td colspan="6">
                                                <table width="100%" border="0">
                                                    <tr>
                                                        <td width="10%" class="TextoCampos">Incluso:</td>
                                                        <td width="40%" class="CelulaZebra2">
                                                            Em:<%=fmt.format(comissao.getCriadoEm())%>
                                                            <br>
                                                            Por: <%=comissao.getCriadoPor().getNome()%> 
                                                        </td>
                                                        <td width="10%" class="TextoCampos">Alterado:</td>
                                                        <td width="40%" class="CelulaZebra2">
                                                            Em:<%=(comissao.getAlteradoEm() != null ? fmt.format(comissao.getAlteradoEm()) : "")%>
                                                            <br>
                                                            Por:<%=comissao.getAlteradoPor().getNome()%> 
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>                    
                </td>
            </tr> 
        </table>
        <br/>                                
        <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">                   
            <tr class="CelulaZebra2">
                <td colspan="6" align="center">
                    <%if (!carregaComissao || !baixado) {%>
                        <input name="salvar" type="button" class="inputbotao" id="salvar" value=" Salvar " onClick="javascript:tryRequestToServer(function (){salva();});">
                    <%} else {%>
                        <b>Pagamento J&aacute; Efetuado, Altera&ccedil;&atilde;o N&atilde;o Permitida.</b>
                    <%}%>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
