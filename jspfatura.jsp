    <%@page import="usuario.BeanUsuario"%>
<%@page import="conhecimento.BeanConsultaConhecimento"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@page import="conhecimento.duplicata.fatura.HistoricoArquivoRemessa"%>
<%@page import="nucleo.boleto.MovimentacaoArquivoRemessa"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="java.text.DecimalFormatSymbols"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Locale"%>
<%@ page contentType="text/html" language="java"
         import="nucleo.*,
         java.text.DecimalFormat,
         java.text.SimpleDateFormat,
         java.sql.ResultSet" errorPage="" %>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="mov_banco.conta.BeanCadConta"%>
<%@page import="conhecimento.duplicata.fatura.BeanConsultaFatura"%>
<%@page import="conhecimento.duplicata.fatura.BeanFatura"%>
<%@page import="conhecimento.duplicata.fatura.BeanCadFatura"%>
<%@page import="java.util.Date"%>
<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.boleto.BoletoDAO"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg"%>
<script language="javascript" src="script/funcoes_gweb.js"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/beans/HistoricoArquivoRemessa.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_7_2.js" type="text/javascript"></script>
<!--<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>-->
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript" src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/LogAcoesAuditoria.js" type="text/javascript"></script>
<script language="JavaScript" src="script/funcoesTelaFatura.js?v=${random.nextInt()}" type="text/javascript"></script>

<%
//Permissao do usuário nessa página
    int nivelUser = Apoio.getUsuario(request).getAcesso("lanfatura");
    int nivelCtrc = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelCtrcFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelNf = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    int nivelFactoring = Apoio.getUsuario(request).getAcesso("lancamentofactoring");
    int nivelVencimento = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("alteravencfatura") : 0);
    int nivelFaturaBoleto = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("alterarfaturaboleto") : 0);
    boolean limitarVisualizarUsuarioConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();
    Boolean isIncluirFaturasCTeConfirmados = Apoio.getConfiguracao(request).isIncluirFaturasCTeConfirmados();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA

    String acao = request.getParameter("acao");
    String acaoPai = "";
    BeanFatura ft = new BeanFatura();
    BeanCadFatura cadFat = null;
    String proxFatura = "";
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    BeanConsultaConhecimento beanconh = null;
    Locale localFmtValor = new Locale("pt", "BR");
    DecimalFormat fmtValor = new DecimalFormat("#,##0.00", new DecimalFormatSymbols(localFmtValor));
    Collection<MovimentacaoArquivoRemessa> listaMov = null;
    listaMov = MovimentacaoArquivoRemessa.listar(true, true);

    Connection con = null;
    try{
    if (acao != null) {
        //instrucoes incomuns entre as acoes
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("visualizar") || acao.equals("excluir") || acao.equalsIgnoreCase("consultar")) {//instanciando o bean de cadastro
            con = Conexao.getConnection();
            cadFat = new BeanCadFatura(con);
//            cadFat.setConexao(Apoio.getUsuario(request).getConexao());
            cadFat.setExecutor(Apoio.getUsuario(request));            
        }

        if (acao.equals("excluir")) {
            cadFat.getFatura().setId(Apoio.parseInt(request.getParameter("id")));
            cadFat.Deleta();

            response.getWriter().append("err<=>" + cadFat.getErros());
            response.getWriter().close();
        }

        if (acao.equals("iniciar")) {
            cadFat = new BeanCadFatura();
            cadFat.setConexao(Apoio.getUsuario(request).getConexao());
            cadFat.setExecutor(Apoio.getUsuario(request));
            proxFatura = cadFat.getProximaFatura();
            cadFat = null;
        }
        if (acao.equals("carregarMovRemessa")) {
            XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
            xstream.setMode(XStream.NO_REFERENCES);
            xstream.alias("movRemessa", MovimentacaoArquivoRemessa.class);
            String json = xstream.toXML(MovimentacaoArquivoRemessa.listar(true, true));

            response.getWriter().append(json);
            response.getWriter().close();
        }

        //executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int id = Apoio.parseInt(request.getParameter("id"));
            ft.setId(id);
            //carregando os dados do cliente por completo(atributos, permissoes)
            cadFat.setFatura(ft);
            cadFat.LoadAllPropertys();
        } else if (acao.equals("atualizar") || acao.equals("incluir")) {
            //populando o JavaBean
            
            ft.setNumero(Apoio.repeatStr("0", 7 - request.getParameter("numFatura").length()) + request.getParameter("numFatura"));
            ft.setAnoFatura(request.getParameter("anoFatura"));
            ft.setEmissaoEm(Apoio.paraDate(request.getParameter("dtemissao")));
            ft.setVenceEm(Apoio.paraDate(request.getParameter("dtvencimento")));
            ft.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
            ft.getCliente().setRazaosocial(request.getParameter("con_rzs"));
            ft.getCliente().setCnpj(request.getParameter("con_cnpj"));

            ft.setValorDesconto(Apoio.parseDouble((request.getParameter("valorDesconto"))));
            ft.setValorAcrescimo(Apoio.parseDouble((request.getParameter("valorAcrescimo"))));
            ft.setDeduzirDesconto(Apoio.parseBoolean(request.getParameter("chkDesconto")));
            ft.setDescricaoDesconto(request.getParameter("descricaoDesconto"));
            ft.setMultaAcrescimo(Apoio.parseDouble((request.getParameter("multa"))));
            ft.setJurosAcrescimo(Apoio.parseDouble((request.getParameter("juros"))));
            ft.setObservacao(request.getParameter("observacao"));
            ft.setCtrcs(request.getParameter("ctrcs"));
            ft.setCtrcsAvaria(request.getParameter("ctrcs_avaria"));
            ft.getFilialCobranca().setIdfilial(Apoio.parseInt(request.getParameter("filialCobrancaId")));
            ft.setGeraBoleto(request.getParameter("geraBoleto").equals("true"));
            ft.setBoletoNossoNumero(Apoio.parseLong(request.getParameter("nossoNumero")));
            ft.setAceite(request.getParameter("aceite").equals("true"));
            ft.setEspecieBoleto(request.getParameter("especieBoleto"));
            ft.setBoletoInstrucao1(request.getParameter("instrucao1"));
            ft.setBoletoInstrucao2(request.getParameter("instrucao2"));
            ft.setBoletoInstrucao3(request.getParameter("instrucao3"));
            ft.setBoletoInstrucao4(request.getParameter("instrucao4"));
            ft.setBoletoInstrucao5(request.getParameter("instrucao5"));
            ft.setSituacao(request.getParameter("situacao"));
            ft.setNumeroPreFatura(request.getParameter("numeroPreFatura"));
            ft.setNumeroLote(Apoio.parseInt(request.getParameter("numeroLote")));
            ft.setCodProtesto(Apoio.parseInt(request.getParameter("codProtesto")));
            ft.setDiasProtesto(Apoio.parseInt(request.getParameter("diasProtesto")));
            ft.setCodDevolucao(Apoio.parseInt(request.getParameter("codDevolucao")));
            ft.setDiasDevolucao(Apoio.parseInt(request.getParameter("diasDevolucao")));
            ft.setValorLiquido(Apoio.parseDouble(request.getParameter("valorLiquido")));
            ft.getEmpresaCobranca().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor"))); 
            ft.setQtdTaxaRecalculo(Apoio.parseInt(request.getParameter("qtdRecalculo")));
            ft.setValorTaxaRecalculo(Apoio.parseDouble(request.getParameter("valorRecalculo")));

            ft.getOcorrencia().getUsuarioInclusao().setIdusuario(Apoio.getUsuario(request).getIdusuario());
            ft.getOcorrencia().getUsuarioPreferencial().setIdusuario(Apoio.getUsuario(request).getIdusuario());
            ft.getOcorrencia().getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
            ft.getOcorrencia().setData(Apoio.getFormatData(request.getParameter("dataOcorrencia")));
            ft.getOcorrencia().setHora(Apoio.getFormatTime(request.getParameter("horaOcorrencia")));
            ft.getOcorrencia().setDescricao(request.getParameter("descricaoOcorrencia"));
            ft.getOcorrencia().setContato(request.getParameter("contatoOcorrencia"));
            ft.getOcorrencia().setContatoFone(request.getParameter("foneOcorrencia"));
            ft.getConta().setIdConta(Apoio.parseInt(request.getParameter("conta")));
            BeanCadConta cadConta = new BeanCadConta();
            cadConta.setConexao(Apoio.getUsuario(request).getConexao());
            cadConta.getConta().setIdConta(ft.getConta().getIdConta());
            boolean foi = cadConta.LoadAllPropertys();

            if (foi) {
                ft.setConta(cadConta.getConta());
            }

            int maxHistorico = Apoio.parseInt(request.getParameter("maxHistorico"));

            HistoricoArquivoRemessa hist = null;
            for (int i = 1; i <= maxHistorico; i++) {
                if (request.getParameter("mov_" + i) != null) {
                    hist = new HistoricoArquivoRemessa();
                    hist.setId(Apoio.parseInt(request.getParameter("idHist_" + i)));
                    hist.getMovRemessa().setId(Apoio.parseInt(request.getParameter("mov_" + i)));
                    hist.setDtVencimento(Apoio.getFormatData(request.getParameter("dtVenc_" + i)));
                    hist.setQtdDiasBaixaDev(Apoio.parseInt(request.getParameter("qtdDiasBaixaDev_" + i)));
                    hist.setQtdDiasProtesto(Apoio.parseInt(request.getParameter("qtdDiasProtesto_" + i)));
                    hist.setCodProtesto(Apoio.parseInt(request.getParameter("codProtesto_" + i)));

                    ft.getHistoricoArquivoRemessas().add(hist);
                }
            }


            boolean erro = false;
            if (acao.equals("atualizar")) {
                ft.setId(Apoio.parseInt(request.getParameter("id")));
                cadFat.setFatura(ft);
                erro = !cadFat.Atualiza();
            } else if (acao.equals("incluir") && nivelUser >= 3) {                
                cadFat.setFatura(ft);
                erro = !cadFat.Inclui();
            }

            // EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
            if (!acao.equals("excluir")) {
                String scr = "";
                if (erro) {
                    scr = "<script>" + "window.opener.document.getElementById('gravar').disabled = false;" + "window.opener.document.getElementById('gravar').value = 'Salvar';";
                    if (cadFat.getErros().indexOf("unk_fatura") > 0) {
                        String suggestId = cadFat.getProximaFatura();
                        scr += "if (confirm('A fatura " + ft.getNumero() + "/" + ft.getAnoFatura() + " já existe. \\n " + "Deseja que o Sistema Crie Com o Número " + suggestId + "/" + ft.getAnoFatura() + " ?')){" + "window.opener.document.getElementById('numFatura').value = '" + suggestId + "';" + "window.opener.document.getElementById('gravar').onclick();" + "}";

                    } else {
                        scr += "alert('" + cadFat.getErros() + "');";
                    }
                    scr += "window.close();" + "</script>";
                    acao = (acao.equals("atualizar") ? "editar" : "iniciar");
                } else {// <-- Se nao teve erro redirecione para a consulta
                    scr = "<script>" + "window.opener.document.location.replace('./consultafatura?acao=iniciar');" + "window.close();" + "</script>";
                }
                response.getWriter().append(scr);
                response.getWriter().close();
            }
        }
    }
    }finally{
        DAO.fecharConexao(con);
        con = null;
    }

    if (acao.equals("visualizar")) {
        //populando o JavaBean
        ft.setId(Apoio.parseInt(request.getParameter("id")));
        
        cadFat.setFatura(ft);
        cadFat.LoadAllPropertys();
        
        ft.setNumero(Apoio.repeatStr("0", 7 - request.getParameter("numFatura").length()) + request.getParameter("numFatura"));
        ft.setAnoFatura(request.getParameter("anoFatura"));
        ft.setNumeroPreFatura(request.getParameter("numeroPreFatura"));
        ft.setNumeroLote(Apoio.parseInt(request.getParameter("numeroLote")));
        ft.setEmissaoEm(Apoio.getFormatData(request.getParameter("dtemissao")));
        ft.setVenceEm(Apoio.getFormatData(request.getParameter("dtvencimento")));
        ft.getConta().setIdConta(Apoio.parseInt(request.getParameter("conta")));
        ft.getFilialCobranca().setIdfilial(Apoio.parseInt(request.getParameter("filialCobrancaId")));
        ft.setValorDesconto(Apoio.parseDouble((request.getParameter("valorDesconto"))));
        ft.setDeduzirDesconto(Apoio.parseBoolean(request.getParameter("chkDesconto")));
        ft.setDescricaoDesconto(request.getParameter("descricaoDesconto"));
        ft.setMultaAcrescimo(Apoio.parseDouble((request.getParameter("multa"))));
        ft.setJurosAcrescimo(Apoio.parseDouble((request.getParameter("juros"))));
        ft.setObservacao(request.getParameter("observacao"));
        ft.setCtrcs(request.getParameter("ctrcs"));
        ft.setCtrcsAvaria(request.getParameter("ctrcs_avaria"));
        ft.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
        ft.getCliente().setRazaosocial(request.getParameter("con_rzs"));
        ft.getCliente().setCnpj(request.getParameter("con_cnpj"));
        ft.getCliente().setTipoDiasVencimento(request.getParameter("con_tipo_dias_pgt"));
        ft.getCliente().setCondicaoPgt(Apoio.parseInt(request.getParameter("con_pgt")));
        ft.getCliente().setTipoCobranca(request.getParameter("con_tipo_cobranca"));
        ft.getCliente().setTipoPgtoContaCorrente(request.getParameter("tppgto"));
        ft.getCliente().setTipoPagtoFrete(request.getParameter("tipofpag"));
        ft.getCliente().setSegunda(Apoio.parseBoolean(request.getParameter("segunda")));
        ft.getCliente().setTerca(Apoio.parseBoolean(request.getParameter("terca")));
        ft.getCliente().setQuarta(Apoio.parseBoolean(request.getParameter("quarta")));
        ft.getCliente().setQuinta(Apoio.parseBoolean(request.getParameter("quinta")));
        ft.getCliente().setSexta(Apoio.parseBoolean(request.getParameter("sexta")));
        ft.getCliente().setSabado(Apoio.parseBoolean(request.getParameter("sabado")));
        ft.getCliente().setDomingo(Apoio.parseBoolean(request.getParameter("domingo")));
        ft.getCliente().setNuncaProtestar(Apoio.parseBoolean(request.getParameter("isNuncaProtestar")));
        //ft.setGeraBoleto(request.getParameter("con_tipo_cobranca") != null && request.getParameter("con_tipo_cobranca").equals("b") && ft.getId() == 0);
        String tp = request.getParameter("tppgto");
        String dtTemp = (request.getParameter("dataVencTemp"));
        if(tp.equals("v") && request.getParameter("tipofpag").equals("c")){
            ft.setVenceEm(Apoio.getFormatData(dtTemp));
        }   
        acaoPai = acao;
        acao = request.getParameter("acaoDoPai");
        
    }else if (acao.equalsIgnoreCase("consultar")){
        
        ft.setId(Apoio.parseInt(request.getParameter("id")));
        
        cadFat.setFatura(ft);
        cadFat.LoadAllPropertys();
//        
        ft.setNumero(Apoio.repeatStr("0", 7 - request.getParameter("numFatura").length()) + request.getParameter("numFatura"));
        ft.setAnoFatura(request.getParameter("anoFatura"));
        ft.setNumeroPreFatura(request.getParameter("numeroPreFatura"));
        ft.setEmissaoEm(Apoio.paraDate(request.getParameter("dtemissao")));
        ft.setVenceEm(Apoio.paraDate(request.getParameter("dtvencimento")));
        ft.getConta().setIdConta(Apoio.parseInt(request.getParameter("conta")));
        ft.getFilialCobranca().setIdfilial(Apoio.parseInt(request.getParameter("filialCobrancaId")));
        ft.setValorDesconto(Apoio.parseDouble((request.getParameter("valorDesconto"))));
        ft.setDeduzirDesconto(Apoio.parseBoolean(request.getParameter("chkDesconto")));
        ft.setDescricaoDesconto(request.getParameter("descricaoDesconto"));
        ft.setMultaAcrescimo(Apoio.parseDouble((request.getParameter("multa"))));
        ft.setJurosAcrescimo(Apoio.parseDouble((request.getParameter("juros"))));
        ft.setObservacao(request.getParameter("observacao"));
        ft.setGeraBoleto(Apoio.parseBoolean(request.getParameter("geraBoleto")));
        ft.setBoletoInstrucao1(request.getParameter("instrucao1"));
        ft.setBoletoInstrucao2(request.getParameter("instrucao2"));
        ft.setBoletoInstrucao3(request.getParameter("instrucao3"));
        ft.setBoletoInstrucao4(request.getParameter("instrucao4"));
        ft.setBoletoInstrucao5(request.getParameter("instrucao5"));
//        ft.setCtrcsAvaria(request.getParameter("ctrcs_avaria"));
        ft.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
        ft.getCliente().setRazaosocial(request.getParameter("con_rzs"));
        ft.getCliente().setCnpj(request.getParameter("con_cnpj"));
        ft.getCliente().setTipoDiasVencimento(request.getParameter("con_tipo_dias_pgt"));
        ft.getCliente().setCondicaoPgt(Apoio.parseInt(request.getParameter("con_pgt")));
        ft.getCliente().setTipoCobranca(request.getParameter("con_tipo_cobranca"));
        ft.getCliente().setTipoPgtoContaCorrente(request.getParameter("tppgto"));
//        
        
        
        String campoConsulta = "chave_acesso_cte";
        String chaveAcesso = request.getParameter("chaveAcesso");

        beanconh = new BeanConsultaConhecimento();
        beanconh.setConexao(Apoio.getUsuario(request).getConexao());
        beanconh.setExecutor(Apoio.getUsuario(request));
        beanconh.setCampoDeConsulta(campoConsulta);
        beanconh.setValorDaConsulta(chaveAcesso);
        beanconh.setOrdenacaoConsulta("nfiscal");
        beanconh.setTipoCTE("");
        beanconh.setOperador(2);
        
        beanconh.setAgency(-1);
        beanconh.setIdRemetente(0);
        beanconh.setIdDestinatario(0);
        beanconh.setIdConsignatario(0);
        beanconh.setIdMotorista(0);
        beanconh.setSerie("");
        beanconh.setSerieNF("");
        beanconh.setTipoTransporte("false");
        beanconh.setIdRedespachante(0);        
        beanconh.setIdRepresentanteColeta(0);
        beanconh.setIdRepresentanteEntrega(0);
        beanconh.setIsNotImpresso(false);
        
        
        String ctrcs = "";
        String tipo = "";
        String numero = "";
        Boolean isCancelado = false;
        Boolean isPago = false;
        Boolean jaExistEmFatura = false;
        String isConfirmado = "";
        int idconsignatario = 0;
        int idFatura = 0;
        if(beanconh.Consultar()){
            ResultSet rs = beanconh.getResultado();
            boolean exist = false;
            while(rs.next()){
                exist = true;
                tipo = rs.getString("tipo_do_conhecimento");
                numero = rs.getString("numero");
                isCancelado = rs.getBoolean("is_cancelado");
                idconsignatario = rs.getInt("idconsignatario");
                isConfirmado = rs.getString("status");
                isPago = false;
                idFatura = rs.getInt("fatura_id");
                if(rs.getDate("pago_em") != null){
                    isPago = true;
                }
                
                if(idFatura != 0){
                    jaExistEmFatura = true;
                }
                if(!isCancelado || idconsignatario != ft.getCliente().getIdcliente()){
                    ctrcs += rs.getString("id") + ",";
                }
            }
            if(!exist){
                request.setAttribute("erro", "chaveNaoEncontrada");
            }
            
        }
        
        
        if(request.getParameter("ctrcs") != null && request.getParameter("ctrcs") != ""){
            ctrcs += request.getParameter("ctrcs") + "," + ctrcs;
        }
        if(tipo.equalsIgnoreCase("Cortesia")){
            request.setAttribute("erro", "tipoCortesia");
            request.setAttribute("numero", numero);
            ctrcs = request.getParameter("ctrcs" + ",");    
        }
        
        if(isCancelado){
            request.setAttribute("erro", "CtrcCancelado");
            request.setAttribute("numero", numero);
            ctrcs = request.getParameter("ctrcs") + ",";
        }
        
        if(isPago){
            request.setAttribute("erro", "ctePago");
            request.setAttribute("numero", numero);
            ctrcs = request.getParameter("ctrcs") + ",";
        }
        
        if(jaExistEmFatura){
            request.setAttribute("erro", "jaPertence");
            request.setAttribute("numero", numero);
            request.setAttribute("numeroFatura", idFatura);
            ctrcs = request.getParameter("ctrcs") + ",";
        }
        
        if((isConfirmado != null)&&(!isConfirmado.equalsIgnoreCase("C"))){
            request.setAttribute("erro", "NaoConfirmado");
            request.setAttribute("numero", numero);
            ctrcs = request.getParameter("ctrcs") + ",";
        }
        
        if(idconsignatario != ft.getCliente().getIdcliente()){
            request.setAttribute("erro", "ClienteEscolhido");
            request.setAttribute("cliente", ft.getCliente().getRazaosocial());
            request.setAttribute("numero", numero);
            ctrcs = request.getParameter("ctrcs") + ",";
        }
        
        if(ctrcs != "" && ctrcs != null){
            ctrcs = ctrcs.substring(0,ctrcs.length() -1);
        }
        
        ft.setCtrcs(ctrcs);
        
    }
    
    if (acao.equals("consultaChaveAcessoCte")){
        beanconh = new BeanConsultaConhecimento();
        beanconh.setConexao(Apoio.getUsuario(request).getConexao());
        beanconh.setExecutor(Apoio.getUsuario(request));
        String chaveAcesso = request.getParameter("chaveAcessoCte");
        int idCliente = Apoio.parseInt(request.getParameter("idconsignatario"));
        String tipoChaveCTe = request.getParameter("tipo_chave_acesso");
        
        Collection idCte = beanconh.consultaConhecimentoChaveAcesso(chaveAcesso, idCliente, tipoChaveCTe);
        
        XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
        xstream.setMode(XStream.NO_REFERENCES);
        xstream.alias("idCte", String.class);
        String json = xstream.toXML(idCte);

        response.getWriter().append(json);
        response.getWriter().close();
    }

    boolean carregaFat = (cadFat != null && (!acao.equals("incluir") || !acao.equals("atualizar") || acao.equals("visualizar") || acao.equalsIgnoreCase("consultar")));
%>
<script language="JavaScript" type="text/javascript">
    //Não sei bem o porque mas tenho que abrir uma tag do javascript com o src e fechá-la,
    //para usar as funções do arquivo .js tenho que abrir uma nova tag <script>

    //Quando o usuário clica em voltar
    
    jQuery.noConflict();
    
    var nameimput;
    var valorimput;
    
    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdCtNfs','trCtNfs');
    arAbasGenerico[1] = new stAba('tdPgto','trPgto');
    arAbasGenerico[2] = new stAba('tdHistorico','trHistorico');
    arAbasGenerico[3] = new stAba('tdRelacionamento','trRelacionamento');
    arAbasGenerico[4] = new stAba('tdAuditoria','trAuditoria');
    
    var listCodProtesto = new Array();
    listCodProtesto[0] = new Option(1, "Protestar dias corridos");
    listCodProtesto[1] = new Option(2, "Protestar dias úteis");
    
    var listCodProtestoFInsFalimentar = new Array();
    listCodProtestoFInsFalimentar[0] = new Option(1, "Protestar fim falimentar - Dias úteis");
    listCodProtestoFInsFalimentar[1] = new Option(2, "Protestar fim falimentar - Dias úteis");

    
    function concatInst(campo){
       
        var texto = valorimput;
        var textoFinal = "";
        var i=0;
       
        if (texto.length == 0){
            textoFinal = campo ;
        }else{
            textoFinal= texto+" " +campo;
        }
        
        $(nameimput).value= textoFinal;
    }
    
    function setImput(id, valor){        
        nameimput = id;  
        valorimput= valor;
    } 
    
    function voltar(){
        clicouBotaoSalvar = false;
        limparSessao();
        parent.document.location.replace("./consultafatura?acao=iniciar");
    }

    //Salva as informações digitadas
    function salva(acao){
        var ctrcs = verificaCtrcs();
        //Validando campos em branco
        if ($("dtvencimento").value == '' && $("chkContraApresentacao").checked == false) {
            alert ("Informe o Vencimento da Fatura Corretamente");
        }else if ($("numFatura").value == '' || $("anoFatura").value == '') {
            alert ("Informe o Número da Fatura Corretamente.");
        }else if (ctrcs == '') {
            alert ("Informe um CTRC ou NF Serviço Antes de Salvar.");
        }else if ($("geraBoleto").checked && $("dtvencimento").value == '' ){
            alert ("Informe o Vencimento da Fatura Corretamente, Para Geração do Boleto.");
        }else{
            //separando 'mes' 'dia' e 'ano' por '/'
            var dtvencimento = $("dtvencimento").value.split("/");
            var dtemissao= $("dtemissao").value.split("/");
            
            var dataVencimento = new Date(parseInt(dtvencimento[2], 10),parseInt(dtvencimento[1], 10)-1,parseInt(dtvencimento[0],10));
            var dataEmissao = new Date(parseInt(dtemissao[2],10),parseInt(dtemissao[1],10)-1,parseInt(dtemissao[0],10));
           
            if ($("chkContraApresentacao").checked == false && dataVencimento < dataEmissao){
                alert('A Data de Vencimento Não Pode Ser Inferior a Data de Emissão.');
                return false;
            }
            if ($('situacao').value == 'CA' && !confirm("Ao Selecionar a Situação 'Cancelada' Todos os CTs/Notas de Serviços Ficarão Disponíveis Para o Próximo Faturamento. Deseja Continuar?")){
                return null;
            }else if ($('situacao').value == 'CO' && !confirm("Ao Selecionar a Situação 'Cortesia' Todos os CTs Dessa Fatura Ficarão Marcados como 'Brinde/Cortesia'. Deseja Continuar?")){
                return null;
            }else if ($('situacao').value == 'DT' && !confirm("Você Escolheu a Situação 'Descontada', o Ideal Seria Lançar Essa Fatura na Rotina de 'Desconto de Duplicatas'. Deseja Continuar?")){
                return null;
            }else if (($('situacao').value == 'CA' || $('situacao').value == 'CO') && $('bordero_id').value != '0'){
                alert ("Essa Fatura Foi Descontada em Factoring, a Situação Não Poderá Ser Alterada.");
                return null;
            }else if ($('geraBoleto').checked && acao != 'incluir' && $('conta').value != <%=ft.getConta().getIdConta()%>){
                if (!confirm("Já Existe Boleto Gerado Para Essa Fatura, ao Alterar a Conta Será Gerado um Novo Nosso Número, Tem Certeza que Deseja Alterar a Conta Bancária?")){
                    return null;
                }
            }
            
            if ($("validarRelacSalvar").value == "true" && ($("dataOcorrencia").value.trim() == "" || $("contatoOcorrencia").value.trim() == "" || $("horaOcorrencia").value.trim() == "" || $("foneOcorrencia").value.trim() == "" || $("descricaoOcorrencia").value.trim() == "")) {
                alert("Preencha os campos do relacionamento corretamente!");
                
                if (jQuery("#dataOcorrencia").val() == "") {
                    jQuery('#dataOcorrencia').css('background','rgb(255, 232, 232)');
                }else{
                    jQuery('#dataOcorrencia').css('background','');
                }
                if (jQuery("#contatoOcorrencia").val() == "") {
                    jQuery('#contatoOcorrencia').css('background','rgb(255, 232, 232)');
                }else{
                    jQuery('#contatoOcorrencia').css('background','');
                }
                if (jQuery("#horaOcorrencia").val() == "") {
                    jQuery('#horaOcorrencia').css('background','rgb(255, 232, 232)');
                }else{
                    jQuery('#horaOcorrencia').css('background','');
                }
                if (jQuery("#foneOcorrencia").val() == "") {
                    jQuery('#foneOcorrencia').css('background','rgb(255, 232, 232)');
                }else{
                    jQuery('#foneOcorrencia').css('background','');
                }
                if (jQuery("#descricaoOcorrencia").val() == "") {
                    jQuery('#descricaoOcorrencia').css('background','rgb(255, 232, 232)');
                }else{
                    jQuery('#descricaoOcorrencia').css('background','');
                }
                
                return false;
            }
            
            $("gravar").disabled = true;
            $("gravar").value = "Enviando...";
            if (acao == "atualizar")
                acao += "&id=<%=(ft != null ? ft.getId() : 0)%>&";
                $('formFat').action = "./fatura_cliente?acao="+acao+"&"+
                concatFieldValue('numFatura,anoFatura,dtemissao,dtvencimento,idconsignatario,idfornecedor,' +
                'conta,valorDesconto,descricaoDesconto,valorAcrescimo,filialCobrancaId,numeroPreFatura,'+
                'multa,juros,observacao,ctrcs_avaria,nossoNumero,'+
                'instrucao1,instrucao2,instrucao3,instrucao4,qtdRecalculo,valorRecalculo,'+
                'instrucao5,especieBoleto,situacao,con_rzs,'+
                'con_cnpj,numeroLote,codProtesto,diasProtesto,valorLiquido,dataOcorrencia,horaOcorrencia,contatoOcorrencia,foneOcorrencia,descricaoOcorrencia')+
                "&chkDesconto="+$('chkDesconto').checked+
                "&geraBoleto="+$('geraBoleto').checked + 
                "&codDevolucao="+$('codDevolucao').value + "&diasDevolucao="+$('diasDevolucao').value+ 
                "&aceite="+ $("aceite").checked;
                
            $('formFat').target = "pop";
            window.open('about:blank', 'pop', 'width=210, height=100');
            $('formFat').submit();
        }
    }

    function excluir(id){
        if (confirm("Deseja Mesmo Excluir esta Fatura?")){
            location.replace("./fatura_cliente?acao=excluir&id="+id);
        }
    }

    var listaMomArquivoRemessa = new Array();
    function seAlterando(){
        var idx = 0;
    <%for (MovimentacaoArquivoRemessa mov : listaMov) {%>
                listaMomArquivoRemessa[idx++] = new Option(<%=mov.getId()%>, "<%=mov.getCodigo()%> - <%=mov.getDescricao()%>");
    <%}%>
        
                carregarAjaxMovRemessa(listaMomArquivoRemessa);
                controlaTrBoleto($("geraBoleto").checked)
                $('situacao').value = '<%=ft.getSituacao()%>';
                calculaVencimento(<%=acao.equals("iniciar")%>);
        
                var carregaFat = <%=carregaFat%>;
                var histRem = null;
                if (carregaFat) {
    <%for (HistoricoArquivoRemessa hist : ft.getHistoricoArquivoRemessas()) {%>
                        histRem = new HistoricoArquivoRemessa();
                        histRem.id = "<%=hist.getId()%>";
                        histRem.dtHrInclusao = "<%=hist.getDtHrInclusao()%>";
                        histRem.codMov = "<%=hist.getMovRemessa().getId()%>";
                        histRem.dtVencimento = "<%=hist.getDtVencimento()%>";
                        histRem.qtdDiasBaixaDevolucao = "<%=hist.getQtdDiasBaixaDev()%>";
                        histRem.qtdDiasProtesto = "<%=hist.getQtdDiasProtesto()%>";
                        histRem.codProtesto = "<%=hist.getCodProtesto()%>";
                        addHistoricoArquivoRemessa(histRem, $('tbHistoricoRemessa'));
    <%}%>
        
                    }
                    //Botão excluir
                }
  
                function selecionar_ctrc(qtdLinhas,acao,isIncluirFaturasCTeConfirmados){
                    if ($('idconsignatario').value == '0'){
                        alert('Informe o Cliente Corretamente!');
                    }else{
                        post_cad = window.open('./selecionactrc_fatura?acao=iniciar&'+concatFieldValue("idconsignatario,con_rzs")+'&marcados='+""+'&acaoDoPai='+acao+"&isSubmit=true"+
                                                "&incluirFaturasCteConfirmados="+isIncluirFaturasCTeConfirmados,'Ctrc',
                                                'top=40,left=40,height=600,width=1000,resizable=yes,status=1,scrollbars=1');
                    }
                }

                function verificaCtrcs(){
                    var retorno = jQuery('[id^=id_]').map(function () {
                        return jQuery(this).val()
                    }).get().join();

                    $("marcados").value = retorno;
                    $("ctrcs").value = retorno;
                    return (retorno);
                }

                function carregaCTRC(ctrcs,qtdLinhas,acao){  
                    try {
                        var form = $("formFat");
                        acao += "&id=<%=(ft != null ? ft.getId() : 0)%>&";
            
                        $("ctrcs").value = ctrcs;
                        form.target = "";
                        form.action = ("jspfatura.jsp?acao=visualizar&acaoDoPai="+acao+"&id=<%=(ft != null ? ft.getId() : 0)%>&"+
                            concatFieldValueUnescape('numFatura,anoFatura,con_tipo_dias_pgt,con_pgt,dtemissao,dtvencimento,idconsignatario,conta,valorDesconto,descricaoDesconto,valorAcrescimo,multa,juros,observacao,con_rzs,con_cnpj,ctrcs_avaria,filialCobrancaId,numeroPreFatura,con_tipo_cobranca')+
                            "&chkDesconto="+$('chkDesconto').checked+"&tppgto="+$('tppgto').value+"&dataVencTemp="+$('dataVencTemp').value+"&tipofpag="+$("tipofpag").value+"&isNuncaProtestar="+$("isNuncaProtestar").value+"&numeroLote="+$("numeroLote").value);
            
                        form.submit();
            
                        //        document.location.replace("./jspfatura.jsp?acao=visualizar&acaoDoPai="+acao+"&id=<=(ft != null ? ft.getId() : 0)%>&"+
                        //            concatFieldValueUnescape('numFatura,anoFatura,con_tipo_dias_pgt,con_pgt,dtemissao,dtvencimento,idconsignatario,conta,valorDesconto,descricaoDesconto,valorAcrescimo,multa,juros,observacao,con_rzs,con_cnpj,ctrcs_avaria,filialCobrancaId,numeroPreFatura,con_tipo_cobranca')+
                        //            "&chkDesconto="+$('chkDesconto').checked+"&ctrcs="+ctrcs);
                    } catch (e) { 
                        console.log("Erro:"+e);
                        console.trace();
                    }
                }

                function editarSale(id,categ){
                    if (categ == 1){
                        window.open('./frameset_conhecimento?acao=editar&id='+id+'&ex=false', 'CTRC' , 'top=0,resizable=yes');
                    }else{
                        window.open('./cadvenda.jsp?acao=editar&id='+id+'&ex=false', 'NF_Servico' , 'top=0,resizable=yes');
                    }
                }

                function editarFactoring(id){
                    window.open('./cadmovimentacao_factoring.jsp?acao=editar&id='+id+'&ex=false', 'Desconto' , 'top=0,resizable=yes');
                }

                function calculaLiquido(){
                    var total = 0;
                    var liquido = 0;
                    total = $("lbtotal").innerHTML.replace('.','');
                    total = total.replace(',','.');
                    liquido = parseFloat(total);
                    if ($('chkDesconto').checked){
                        liquido = parseFloat(total) - parseFloat($('valorDesconto').value);
                    }
                    liquido += parseFloat($('valorAcrescimo').value);
                    
                    liquido = liquido + parseFloat($('valorRecalculo').value);
                    
                    $('lbliq').innerHTML = formatoMoeda(parseFloat(liquido));
                    $("valorLiquido").value = liquido;
                }

                function localizaCtrc(){
                    if ($('idconsignatario').value == 0){
                        alert("Informe o Cliente Corretamente.");
                        return false;
                    }else{
                        post_cad = window.open('./pops/seleciona_ctrc_fatura.jsp?acao=iniciar&idconsignatario='+$('idconsignatario').value,'CTRC',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
                    }
                }
      
                function calculaAvaria(ids, ctrcs, avaria){
                    $('ctrcs_avaria').value = ids;
                    $('descricaoDesconto').value = 'Avaria dos ctrcs: ' + ctrcs;
                    $('valorDesconto').value = formatoMoeda(avaria);
                    calculaLiquido();
                }
    
    
    function limparAvaria(){
     if($("valorDesconto").value != "0.00" && $("valorDesconto").value != "" ){
        if(!confirm("Tem certeza que deseja desvincular os conhecimentos selecionados com avarias ? ")){
            return false;
        }
        else {
            $('ctrcs_avaria').value = 0;
            $('descricaoDesconto').value = "";
            $('valorDesconto').value = formatoMoeda(0);
            calculaLiquido();
            alert("Avarias desvinculadas com sucesso ! ");
        }
      }
    }

                function controlaTrBoleto(checked){
                    if(checked){
                        $("trBoleto").style.display = "";
                        $("tdHistorico").style.display = "";
                    }else{
                        $("trBoleto").style.display = "none";
                        $("tdHistorico").style.display = "none";
                    }
                }

                function valoresDefaultBoleto(idConta){
                    if($("hdInstrucao1_" + idConta) != null){
                        $("instrucao1").value = $("hdInstrucao1_" + idConta).value;
                        $("instrucao2").value = $("hdInstrucao2_" + idConta).value;
                        $("instrucao3").value = $("hdInstrucao3_" + idConta).value;
                        $("instrucao4").value = $("hdInstrucao4_" + idConta).value;
                        $("instrucao5").value = $("hdInstrucao5_" + idConta).value;
                        $("codDevolucao").value = $("hdCodDevolucao_" + idConta).value;
                        $("diasDevolucao").value = $("hdDiasDevolucao_" + idConta).value;
                        if($("codProtesto") != null){
                            $("codProtesto").value = $("hdCodProtesto_" + idConta).value;
                            $("diasProtesto").value = $("hdDiasProtesto_" + idConta).value;
                            $("juros").value = $("hdJuros_" + idConta).value;
                            $("multa").value = $("hdMulta_" + idConta).value;
                        }
            
                    }
                }



                function aoClicarNoLocaliza(idjanela) {
                    //localizando Cliente        
                    if (idjanela == "Consignatario_Fatura") {
                        $("foneOcorrencia").value = $("con_fone").value;
                        $("isNuncaProtestar").value = $("is_nunca_protestar").value;
                        if ($("tppgto").value == 'v' && $("tipofpag").value == 'c') {
                            getDias();
                        } else {             
                            calculaVencimento(true);
                        }
                    }
                }
    
                function getDtVencimento(){
                    if ($("tppgto").value == 'v' && $("tipofpag").value == 'c') {
                        getDias();
                    } else {             
                        calculaVencimento(true);
                    }
                }
    
                function getDias() {
                    $("dtvencimento").disabled = false;
                    var dataEmissao = $('dtemissao').value;
                    var idCliente = $("idconsignatario").value
                    new Ajax.Request("./ClienteControlador?acao=localizaDiasVencimento&idCliente=" + idCliente + "&dataEmissao=" + dataEmissao,
                    {
                        method: "get",
                        onSuccess: function(transport) {
                            var response = transport.responseText;
                            preencheDiasVencimento(response);
                        },
                        onFailure: function() {
                        }
                    });
                }

                function preencheDiasVencimento(resposta) {
                    var dataJson = jQuery.parseJSON(resposta);
                    $("dia_vencimento").value = dataJson.dia_vencimento;
                    $("mes").value = dataJson.mes;
                    
                    var dataVencimento = montaData($('dtemissao').value, $('dia_vencimento').value,$('mes').value);
                    if(validaData(dataVencimento)){
                        $("dtvencimento").value = diaSemana(dataVencimento);
                    $("dataVencTemp").value = $("dtvencimento").value ;
                    }else{
                        alert("Erro ao carregar data de vencimento do cliente, favor preencher manualmente.");
                        $("dtvencimento").value = '';
                        $("dataVencTemp").value = '' ;
                    }
                }
    
                function calculaVencimento(isCalcula){
                    if (isCalcula){
                        var periodo = $('con_pgt').value;
                        var tipoPeriodo = $('con_tipo_dias_pgt').value;
                        var dataEmissao = $('dtemissao').value;
                        var diaSemanaCobranca = "";
                        if (tipoPeriodo == 'f'){
                            if (<%=!acaoPai.equals("visualizar")%>){
                                if (periodo != '0') {
                                    diaSemanaCobranca = diaSemanaPeriodo(incData(dataEmissao, periodo));
                                    $("dtvencimento").value = diaSemanaCobranca;
                                }else if($('idconsignatario').value != 0){
                                    diaSemanaCobranca = diaSemana(dataEmissao);
                                    $("dtvencimento").value = diaSemanaCobranca;
                                }
                            }    
                        }else{
                            var i = 0;
                            var emissao_ctrc = '';
                            var dataA;
                            var dataN;
                            while ($("emissao_cte_"+i) != null){
                                if (emissao_ctrc == ''){
                                    emissao_ctrc = $("emissao_cte_"+i).value;
                                }else{
                                    dataA = new Date(emissao_ctrc.substring(6,10),emissao_ctrc.substring(3,5)-1,emissao_ctrc.substring(0,2));
                                    dataN = new Date($("emissao_cte_"+i).value.substring(6,10),$("emissao_cte_"+i).value.substring(3,5)-1,$("emissao_cte_"+i).value.substring(0,2));
                                    if (dataA.getTime() < dataN.getTime()){
                                        emissao_ctrc = $("emissao_cte_"+i).value;
                                    }
                                }    
                                i++;
                            }
                            if (emissao_ctrc != ''){
                                if($("tipofpag").value != 'c' || ($("tipofpag").value == 'c' && $("tppgto").value == 'q')){
                                    $("dtvencimento").value = incData(emissao_ctrc, periodo);
                                    $("dtvencimento").value = diaSemana($("dtvencimento").value);
                                    if($("chkContraApresentacao").checked){
                                        $("chkContraApresentacao").checked = false;
                                    }
                                 }
                            }    
                        }
                    }
                }    
                
                //vai trazer o dia de cobrançao quando o periodo for igual zero
                function diaSemana(dtVencimento){
                    var dataAmericana = new Date();
                    var dataBr = new Date();
                    dataAmericana = converterDataUSA(dtVencimento);
                    
                    //recebe o dia da semana da emissão
                    var diaPagamento = new Array(7);
                    diaPagamento[0] = ($('domingo').value == 't' || $('domingo').value == 'true');
                    diaPagamento[1] = ($('segunda').value == 't' || $('segunda').value == 'true');
                    diaPagamento[2] = ($('terca').value == 't' || $('terca').value == 'true');
                    diaPagamento[3] = ($('quarta').value == 't' || $('quarta').value == 'true');
                    diaPagamento[4] = ($('quinta').value == 't' || $('quinta').value == 'true');
                    diaPagamento[5] = ($('sexta').value == 't' || $('sexta').value == 'true');
                    diaPagamento[6] = ($('sabado').value == 't' || $('sabado').value == 'true');
                    
                    var isProximaDataPagamento = false;
                    var dataReferencia = dataAmericana;
                    while(!isProximaDataPagamento){
                        if (diaPagamento[dataReferencia.getDay()]) {
                            isProximaDataPagamento = true;
                        } else {
                            dataReferencia = addDays(dataReferencia, 1);
                        }
                    }
                    dataBr = converterDataBR(dataReferencia);
                    return dataBr;
                }
                
                //traz o dia da cobrança quando o periodo for diferente de zero
                function diaSemanaPeriodo(dtVencimento){
                    var dataAmericana = new Date();
                    var dataBr = new Date();
                    dataAmericana = converterDataUSA(dtVencimento);
                
                    //recebe o dia da semana da emissão
                    var diaPagamento = new Array(7);
                    diaPagamento[0] = ($('domingo').value == 't' || $('domingo').value == 'true');
                    diaPagamento[1] = ($('segunda').value == 't' || $('segunda').value == 'true');
                    diaPagamento[2] = ($('terca').value == 't' || $('terca').value == 'true');
                    diaPagamento[3] = ($('quarta').value == 't' || $('quarta').value == 'true');
                    diaPagamento[4] = ($('quinta').value == 't' || $('quinta').value == 'true');
                    diaPagamento[5] = ($('sexta').value == 't' || $('sexta').value == 'true');
                    diaPagamento[6] = ($('sabado').value == 't' || $('sabado').value == 'true');
                    
                    var isProximaDataPagamento = false;
                    var dataReferencia = dataAmericana;
                    while(!isProximaDataPagamento){
                        if (diaPagamento[dataReferencia.getDay()]) {
                            isProximaDataPagamento = true;
                        } else {
                            dataReferencia = addDays(dataReferencia, 1);
                        }
                    }
                    dataBr = converterDataBR(dataReferencia);
                    return dataBr;
                }
        
                //  -- inicio localiza rematente pelo codigo
                function localizaConsignatarioCodigo(campo, valor){

                    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
                    function e(transport){
                        var resp = transport.responseText;
                        espereEnviar("",false);
                        //se deu algum erro na requisicao...
                        if (resp == 'null'){
                            alert('Erro ao Localizar Cliente.');
                            return false;
                        }else if(resp == ''){
                            $('idconsignatario').value = '0';
                            $('con_rzs').value = '';
                            $('con_cnpj').value = '';
                            $('con_pgt').value = '0';
                            $('con_tipo_dias_pgt').value = 'f';
                            alert("Cliente Não Encontrado, Deseja Cadastrá-lo Agora?");
                            return false;
                        }else{
                            var cliControl = eval('('+resp+')');
                            $('idconsignatario').value = cliControl.idcliente;
                            $('con_rzs').value = cliControl.razao;
                            $('con_cnpj').value = cliControl.cnpj;
                            $('con_pgt').value = cliControl.pgt;
                            $('con_tipo_dias_pgt').value = cliControl.tipo_dias_vencimento;
                            $('segunda').value = cliControl.segunda;
                            $('terca').value = cliControl.terca;
                            $('quarta').value = cliControl.quarta;
                            $('quinta').value = cliControl.quinta;
                            $('sexta').value = cliControl.sexta;
                            $('sabado').value = cliControl.sabado;
                            $('domingo').value = cliControl.domingo;
                            aoClicarNoLocaliza('Consignatario_Fatura');
                        }
                    }//funcao e()

                    if (valor != ''){
                        espereEnviar("",true);
                        tryRequestToServer(function(){
                            new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
                        });
                    }
                }

                function alteraSituacao(){
                    $('divEmpresaCobranca').style.display = 'none';
                    if ($('situacao').value == 'DE'){
                        $('divEmpresaCobranca').style.display = '';
                    }
                }
    
                function localizaConsignatario(){
                    launchPopupLocate('./localiza?acao=consultar&idlista=5','Consignatario_Fatura');
                }

                function localizaforn(){
                    post_cad = window.open('./localiza?acao=consultar&idlista=21','Fornecedor',
                    'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
                }

                function limparforn(){
                    document.getElementById("idfornecedor").value = "0";
                    document.getElementById("fornecedor").value = "";
                }
                
                function permissaoAlterarFaturaBoleto(){
                    <%if(carregaFat){%>
                    var nivelFaturaBoleto = '<%=nivelFaturaBoleto%>';
                    var isFaturaImpressao = <%=cadFat.getFatura().isFaturaImpressao()%>;
                    var exportadoEm = '<%=cadFat.getFatura().getExportadoEm()%>'; 
                    if (nivelFaturaBoleto == 0 && (isFaturaImpressao == true || exportadoEm != '')) {
                        //se a validação no fim da pagina não criar o botão não pode dar erro.
                        if ($("gravar") != undefined) {
                            $("gravar").style.display= "none";
                            $("gravar").disabled = true;
                        }
                    }else {
                        //se a validação no fim da pagina não criar o botão não pode dar erro.
                        if ($("gravar") != undefined) {
                            $("gravar").style.display= "";
                            $("gravar").disabled = false;
                        }
                    }
                    <%}%>
                }

        function clienteNuncaProtestar(slcProtesto){
            if(($("is_nunca_protestar").value == "t" || $("is_nunca_protestar").value == "true") && slcProtesto != "3"){
                alert("Atenção: Não está autorizado protestar boleto para o Cliente: " + $("con_rzs").value + "! \nCaso queira protestar boleto para esse cliente, vá em seu cadastro na Aba 'inf. financeiras' \ndesmaque a opção: Não protestar títulos/boletos desse cliente ");
                $("codProtesto").value = "3";
            }
        }
        
        function habilitarNaoProtestar(){
            if($("geraBoleto").checked){
                if(($("isNuncaProtestar").value == "t" || $("isNuncaProtestar").value == "true")){
                    $("codProtesto").value = "3";
                }
            }
        }
        
        function pesquisarAuditoria(){
            if(countLog != null &&  countLog != undefined){
                for(var i = 1; i<= countLog ; i++){
                    if($("tr1Log" + i) != null){
                        Element.remove(("tr1Log " + i));
                    }
                    if($("tr2Log" + i) != null){
                        Element.remove(("tr2Log" + i));
                    }
                }
            }
            countLog = 0;
            var rotina = "faturas";
            var dataDe = $("dataDeAuditoria").value;
            var dataAte = $("dataAteAuditoria").value;
            var id = <%= carregaFat ? cadFat.getFatura().getId() : 0  %>;
            consultarLog(rotina, id, dataDe, dataAte);
         }
         
        function setDataAuditoria(){
            $("dataDeAuditoria").value = "<%= Apoio.getDataAtual() %>";
            $("dataAteAuditoria").value = "<%= Apoio.getDataAtual() %>";
        }
        
        function localizarPelaChaveAcesso(){
            if ($('idconsignatario').value == '0'){
                alert('Informe o Cliente Corretamente!');
            } else if($('chaveAcesso').value.length < 44){
                alert('A chave de acesso do CT-e deve ter 44 digitos!');
            }else{
                
                $('formFat').action = "./fatura_cliente?acao=consultar&"+
                    concatFieldValue('numFatura,anoFatura,dtemissao,dtvencimento,idconsignatario,idfornecedor,' +
                    'conta,valorDesconto,descricaoDesconto,valorAcrescimo,filialCobrancaId,numeroPreFatura,'+
                    'multa,juros,observacao,ctrcs,'+
                    'instrucao1,instrucao2,instrucao3,instrucao4,'+
                    'instrucao5,situacao,con_rzs,'+
                    'con_cnpj,numeroLote,valorLiquido')+
                    "&chkDesconto="+$('chkDesconto').checked+
                    "&geraBoleto="+$('geraBoleto').checked +
                    "&aceite=false";
//                    "&codDevolucao="+$('codDevolucao').value + "&diasDevolucao="+$('diasDevolucao').value+ 


                $("formFat").submit();
            
            
            }
            
        }
        
        function mensagensLocalizaChaveAcesso(){
            var erro = '${erro}';
            
            if(erro != null || erro != undefined){
                if(erro == "chaveNaoEncontrada"){
                    alert("Chave de acesso não encontrada!");
                }else if(erro == "tipoCortesia"){
                    alert("CT-e ${numero} é do tipo cortesia, não poderá ser adicionado na fatura!");
                }else if(erro == "CtrcCancelado"){
                    alert("CT-e ${numero} está cancelado, não poderá ser adicionado na fatura!");
                }else if(erro == "ClienteEscolhido"){
                    alert("CT-e ${numero} não pertence ao cliente ${cliente}!");
                }else if(erro == "ctePago"){
                    alert("CT-e ${numero} já está quitado total ou parcial, não poderá ser adicionado na fatura!");
                }else if(erro == "NaoConfirmado"){
                    alert("CT-e ${numero} não está confirmado na SEFAZ, não poderá ser adicionado na fatura!");
                }else if(erro == "jaPertence"){
                    alert("CT-e ${numero} Já está vinculada a fatura ${numeroFatura}");
                }
            }
        }
        
        function ajaxCarregarCte(chaveAcesso){
            var idConsignatario = $("idconsignatario").value;
            var idMarcados = $("marcados").value;
            var idCte = $("marcados").value;
            var anoFaturamento = "";
            var numeroFatura = "";
            var idFatura = 0;
            var numeroCte = "";
            var numeroCteSubsittuto = "";
            var idCteSubsituto = 0;
            var statusCte = "";
            var cteBaixado = false;

            if (!idConsignatario || idConsignatario == '0' || idConsignatario == '') {
                alert('Informe o Cliente Corretamente!');

                return;
            }

            clicouBotaoSalvar = true;
            sessionStorage.setItem(chaveSessaoSelectBox, $('tipo_chave_acesso').value);

            jQuery.ajax({
                    url: '<c:url value="/jspfatura.jsp" />',
                    dataType: "text",
                    method: "post",
                    data: {
                        chaveAcessoCte : chaveAcesso,
                        idconsignatario : idConsignatario,
                        acao : "consultaChaveAcessoCte",
                        'tipo_chave_acesso': $('tipo_chave_acesso').value
                    },
                    success: function(data) {
                        var ctes = JSON.parse(data).list[0];
                        if (ctes["conhecimento.BeanConhecimento"] != undefined) {
                            if (ctes["conhecimento.BeanConhecimento"].baixa__em != null){
                                cteBaixado = true;
                            }
                            numeroCte = ctes["conhecimento.BeanConhecimento"].numero;
                            numeroCteSubsittuto = ctes["conhecimento.BeanConhecimento"].numeroCTeSubstituto;
                            idCteSubsituto = ctes["conhecimento.BeanConhecimento"].cteSubstituidoId;
                            statusCte = ctes["conhecimento.BeanConhecimento"].statusCte;
                            idFatura = ctes["conhecimento.BeanConhecimento"].duplicatas[0]["conhecimento.duplicata.BeanDuplicata"].fatura.id;
                            anoFaturamento = ctes["conhecimento.BeanConhecimento"].duplicatas[0]["conhecimento.duplicata.BeanDuplicata"].fatura.anoFatura;
                            numeroFatura = ctes["conhecimento.BeanConhecimento"].duplicatas[0]["conhecimento.duplicata.BeanDuplicata"].fatura.numero;
                            idCte = ctes["conhecimento.BeanConhecimento"].duplicatas[0]["conhecimento.duplicata.BeanDuplicata"].id;

                            if (idMarcados != "" && idFatura == 0) {
                               idMarcados += "," + idCte;
                            }else if(idMarcados == ""  && idFatura == 0){
                               idMarcados = idCte;                            
                            }else{
                                 alert("CT-e "+ numeroCte +" Já está vinculada a fatura " + numeroFatura + " / " +  anoFaturamento);
                            }
                            
                            if (idCteSubsituto != 0){
                                alert("CT-e Confirmado e Substituído pelo CT-e Nº " + numeroCteSubsittuto);
                                return false;
                            }else if (statusCte == 'N'){
                                alert("CT-e Negado!");
                                return false;
                            }

                           carregaCTRC(idMarcados,0,'iniciar');
                        }else{
                            switch ($('tipo_chave_acesso').value) {
                                case 'chave_cte_redespacho':
                                    alert("CT-e de Redespacho não encontrado para esta chave de acesso!");
                                    break;
                                case 'chave_cte':
                                default:
                                    alert("CT-e não encontrado para esta chave de acesso!");
                                    break;
                            }
                        }
                    }
                });
        }
        
        function carregarRelacionamento(){
            var id = $("idfatura").value;
            jQuery.ajax({
                    url: "OcorrenciaControladorCrm",
                    dataType: "text",
                    method: "post",
                    data: {
                        id : id,
                        acao : "listarOcorrenciasFatura"
                    },
                    success: function(data) {
                        var ocorrencias = JSON.parse(data);
                        var lista = ocorrencias.list[0]["listaRelacionamento"];
                        if (lista) {
                            var condicao = lista.length == undefined ? 1 : lista.length;
                            for (var i = 0; i < condicao; i++) {
                                var atual = (condicao == 1 ? lista : lista[i]);
                                addRelacionamento(atual.descricao, atual.protocolo, atual.contatoFone, atual.contato, formatDateJSON(atual.data), atual.hora.$, atual.numeroOrcamento, atual.usuarioInclusao.nome, atual.id);
                            }
                         $("btCarregar").disabled = true;
                        }
                    }
                });
        }
        
        function excluirRelacionamento(index){
            if(confirm("Deseja remover o relacionamento Protocolo:"+$("dprotocolo_"+index).innerHTML+" ?")){
                if(confirm("Tem certeza?")){
                    var id = $("idRelacionamento_"+index).value;
                    var idFat = $("idfatura").value;
                    jQuery.ajax({
                            url: "OcorrenciaControladorCrm",
                            dataType: "text",
                            method: "post",
                            data: {
                                id : id,
                                idFat : idFat,
                                acao : "removerOcorrenciasFatura"
                            },
                            success: function() {
                               Element.remove(("tr_"+index));
                               Element.remove(("trContaDespesa_"+index));
                               Element.remove(("trPlanoCusto_"+index));
                            } 
                    });
                }
            }
        }
        
       function escEspDivCont(idDivAtual, imgAtual) {
            var divAtual = $(idDivAtual);
            if (divAtual.style.display == '') {
                divAtual.style.display = 'none';
                imgAtual.src = "img/plus.jpg";
            } else {
                divAtual.style.display = '';
                imgAtual.src = "img/minus.jpg";
            }
        }
 
       function novoRelacionamento(){
           $("novoRelacionamento").style.display = "";
           $("tdCancelar").style.display = "";
           $("validarRelacSalvar").value = "true";
           
       }
       
       function cancelarRelacionamento(){
           $("tdCancelar").style.display = "none";
           $("novoRelacionamento").style.display = "none";
           $("validarRelacSalvar").value = "false";
           $("contatoOcorrencia").value = "";
           $("descricaoOcorrencia").value = "";
       }

       var clicouBotaoSalvar = false;
       var chaveSessaoSelectBox = 'select-tipo-chave-acesso-fatura';
       function carregar(){
        seAlterando();
        alteraSituacao();
        verificaCtrcs();
        permissaoAlterarFaturaBoleto();
        setDataAuditoria();
        mensagensLocalizaChaveAcesso();
        
        $("horaOcorrencia").value = '${cg:getHoraAtual()}';
        $("dataOcorrencia").value = '${cg:getDataAtual()}';

           // Foco
           jQuery('#chaveAcesso').focus();
           // Alterar select guardado na sessionStorage
           var selectBoxSessao = sessionStorage.getItem(chaveSessaoSelectBox);

           if (selectBoxSessao !== undefined && selectBoxSessao !== null && selectBoxSessao !== '') {
               jQuery('#tipo_chave_acesso').val(selectBoxSessao);
           }

           jQuery(window).on("beforeunload", function () {
               limparSessao();
           });
       }

    function limparSessao() {
        if (!clicouBotaoSalvar) {
            sessionStorage.removeItem(chaveSessaoSelectBox);
        }
    }
    
    function visualizarRastreabilidadeEmail(id){
        jQuery.ajax({
            url: "FaturaRastreabilidadeControlador",
            data: {
                acao: "consultar",
                idFatura: id
            },
            complete: function (jqXHR, textStatus ) {
                var t = jqXHR.responseText;
                jQuery('.tr-rastreio').remove();
                jQuery.each(JSON.parse(t),(index, element) => {
                    var tbody = jQuery('#tbody-rastreamento');
                    var tr = jQuery('<tr class="'+(parseInt(index) & 1 ? 'CelulaZebra1' : 'CelulaZebra2')+' tr-rastreio">');
                    var td = jQuery('<td>').text(element.data_hora_acao);
                    tr.append(td);
                    td = jQuery('<td>').text(element.nome_usuario);
                    tr.append(td);
                    td = jQuery('<td>').text(element.acao);
                    tr.append(td);
                    td = jQuery('<td>').text(element.email_destino);
                    tr.append(td);
                    td = jQuery('<td>').text(element.id_mensagem);
                    tr.append(td);
                    td = jQuery('<td>').text(element.descricao);
                    tr.append(td);
                    tbody.append(tr);
                    
                });
                
            }
        });
    }
</script>
<style>
    .block-all-carregando{
        position: absolute;
        top: 0;
        background: rgba(0,0,0,0.5) url(img/loading.gif) no-repeat center;
        width: 100%;
        height: 100%;
    }

    .excluir-cte-fatura {
        cursor: pointer;
    }

    .modal-content {
        text-align: left;
    }
</style>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro de Fatura / Boleto</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">

        <c:set var="autenticado" value="<%= Apoio.getUsuario(request) %>"/>
        <c:set var="nivelUser" value="<%= nivelUser %>"/>
        <c:set var="faturaId" value='<%= Apoio.parseInt(request.getParameter("id")) %>'/>
        <c:set var="is_gera_boleto" value='<%= ft.isGeraBoleto() %>'/>

        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${autenticado.nome}"/>
        </jsp:include>
    </head>

    <body onLoad="javascript:carregar();AlternarAbasGenerico('tdCtNfs','trCtNfs');">
        <div class="block-all-carregando"></div>
        <img src="img/banner.gif" >
        <br>
        <input type="hidden" name="idfatura" id="idfatura" value="<%=(carregaFat ? ft.getId() : 0)%>">
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(carregaFat ? ft.getCliente().getIdcliente() : "0")%>">
        <input type="hidden" name="con_tipo_cobranca" id="con_tipo_cobranca" value="">
        <input type="hidden" name="numeroLote" id="numeroLote" value="<%=(carregaFat ? ft.getNumeroLote() : "0")%>">
        <input type="hidden" id="ctrcs_avaria" name="ctrcs_avaria" value="<%=(carregaFat ? ft.getCtrcsAvaria() : "")%>">
        <input type="hidden" id="con_pgt" name="con_pgt" value="<%=(carregaFat ? ft.getCliente().getCondicaoPgt() : "0")%>">
        <input type="hidden" id="con_tipo_dias_pgt" name="con_tipo_dias_pgt" value="<%=(carregaFat ? ft.getCliente().getTipoDiasVencimento() : "f")%>">
        <input type="hidden" name="tppgto" id="tppgto" value="<%=(carregaFat ? ft.getCliente().getTipoPgtoContaCorrente(): "q")%>">
        <input type="hidden" name="tipofpag" id="tipofpag" value="<%=(carregaFat ? ft.getCliente().getTipoPagtoFrete(): "v")%>">
        <input type="hidden" name="mes" id="mes" value="">
        <input type="hidden" name="dia_vencimento" id="dia_vencimento" value="">
        <input type="hidden" name="dataVencTemp" id="dataVencTemp" value="">
        <input type="hidden" id="dataVencAuxHistorico" value="<%=(carregaFat ? Apoio.getFormatData(ft.getVenceEm()) : "")%>">
        <input type="hidden" id="qtdDiasProtestoAuxHistorico" value="<%=(carregaFat ? ft.getDiasProtesto() : "")%>">
        <input type="hidden" id="codProtestoAuxHistorico" value="<%=(carregaFat ? ft.getCodProtesto() : "")%>">
        <input type="hidden" id="codBaixaDevAuxHistorico" value="<%=(carregaFat ? ft.getCodDevolucao() : "")%>">
        <input type="hidden" id="qtdDiasBaixaDevAuxHistorico" value="<%=(carregaFat ? ft.getDiasDevolucao() : "")%>">
        <input type="hidden" id="is_nunca_protestar" name="is_nunca_protestar" value="<%=(carregaFat ? ft.getCliente().isNuncaProtestar() : false)%>"/>      
        <input type="hidden" id="isNuncaProtestar" name="isNuncaProtestar" value="<%=(carregaFat ? ft.getCliente().isNuncaProtestar() : false)%>"/>
        <input type="hidden" id="con_fone" name="con_fone" value="">
        <input type="hidden" id="validarRelacSalvar" name="validarRelacSalvar" value="false">
        <table width="85%" align="center" class="bordaFina" >

            <tr>
                <td width="532" height="22">
                    <div align="left">
                        <b>Cadastro de Fatura / Boleto </b>
                    </div>
                </td>
                <td width="81">
                    <% if ((acao.equals("editar")) && (nivelUser == 4) && (Apoio.parseBoolean(request.getParameter("ex")))) //se o paramentro vier com valor diferente de nulo ai pode excluir
                        {%>
                    <input  name="excluir" type="button" class="botoes" value="Excluir" alt="Exclui a Fatura Atual" onClick="javascript:excluir(<%=(carregaFat ? ft.getId() : 0)%>);">
                </td>
                <%}%>
                <td width="8">&nbsp;</td>
                <td width="59"><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta Para o Menu Principal" onClick="javascript:tryRequestToServer(function(){voltar()});"></td>
            </tr>
        </table>
        <br>
        <form method="post" id="formFat" target="">
            <input type="hidden" id="marcados" name="marcados" value="">
                    <input type="hidden" id="domingo" name="domingo" value="<%=(carregaFat ? ft.getCliente().isDomingo(): "f")%>">
                    <input type="hidden" id="segunda" name="segunda" value="<%=(carregaFat ? ft.getCliente().isSegunda() : "f")%>">
                    <input type="hidden" id="terca" name="terca" value="<%=(carregaFat ? ft.getCliente().isTerca() : "f")%>">
                    <input type="hidden" id="quarta" name="quarta" value="<%=(carregaFat ? ft.getCliente().isQuarta(): "f")%>">
                    <input type="hidden" id="quinta" name="quinta" value="<%=(carregaFat ? ft.getCliente().isQuinta(): "f")%>">
                    <input type="hidden" id="sexta" name="sexta" value="<%=(carregaFat ? ft.getCliente().isSexta(): "f")%>">
                    <input type="hidden" id="sabado" name="sabado" value="<%=(carregaFat ? ft.getCliente().isSabado(): "f")%>">
            <table width="85%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td height="20" colspan="8" align="center">Dados Principais </td>
                </tr>
                <tr>
                    <td height="25" class="TextoCampos">N&uacute;mero:</td>
                    <td width="139" class="CelulaZebra2">
                        <input name="numFatura" type="text" id="numFatura" value="<%=(carregaFat ? ft.getNumero() : proxFatura)%>" size="8" maxlength="8" class="inputtexto">
                        <input type="hidden" id="ctrcs" name="ctrcs" value="">
                        /
                        <input name="anoFatura" type="text" id="anoFatura" value="<%=(carregaFat ? ft.getAnoFatura() : new SimpleDateFormat("yyyy").format(new Date()))%>" size="3" maxlength="4" class="inputtexto">
                    </td>
                    <td width="110" class="CelulaZebra2"><b>N&ordm; Lote:<%=(carregaFat ? ft.getNumeroLote() : "0")%></b></td>
                    <td width="64" class="TextoCampos">Emiss&atilde;o: </td>
                    <td width="76" class="CelulaZebra2">
                        <strong>
                            <input name="dtemissao" type="text" id="dtemissao" value="<%=(carregaFat && ft.getEmissaoEm() != null ? fmt.format(ft.getEmissaoEm()) : Apoio.getDataAtual())%>" size="9" maxlength="10" class="fieldDate"
                                   onBlur="alertInvalidDate(this);getDtVencimento();" onKeyPress="fmtDate(this, event)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" />
                        </strong>
                    </td>
                    <td width="73" class="TextoCampos">Vencimento:</td>
                    <td width="239" class="CelulaZebra2">
                        <strong>
                            <input name="dtvencimento" type="text" class="<%=(carregaFat && nivelVencimento == 0 && !acao.equals("iniciar") ? "inputReadOnly" : "fieldDate")%>" id="dtvencimento" value="<%=(carregaFat && ft.getVenceEm() != null ? fmt.format(ft.getVenceEm()) : "")%>" size="9" maxlength="10"
                                   onBlur="alertInvalidDate(this,true)" onKeyPress="fmtDate(this, event);if (this.readOnly){alert('Você não tem privilégio suficiente para alterar o vencimento dessa fatura.');}" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)"
                                   <%=(carregaFat && nivelVencimento == 0 && !acao.equals("iniciar") ? "readonly" : "")%>/>
                        </strong>
                        <label>
                            <input name="chkContraApresentacao" type="checkbox" id="chkContraApresentacao" value="checkbox" onClick="javascript:$('dtvencimento').value = '';" <%=(carregaFat && ft.getVenceEm() == null ? "checked" : "")%>>
                            Contra Apresenta&ccedil;&atilde;o 
                        </label>
                    </td>
                </tr>
                <tr>
                    <td width="61" height="25" class="TextoCampos">Cliente:</td>
                    <td colspan="4" class="CelulaZebra2">
                        <div align="left">
                            <input name="con_cnpj" type="text" id="con_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaFat ? ft.getCliente().getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj', this.value)">
                            <input name="con_rzs" type="text" id="con_rzs" value="<%=(carregaFat ? ft.getCliente().getRazaosocial() : "")%>" size="40" maxlength="50" readonly="true" class="inputReadOnly8pt">
                            <strong>
                                <%if (request.getParameter("acao").equals("iniciar") || request.getParameter("acao").equals("consultar")) {%>
                                <input name="button3" type="button" class="botoes" onClick="localizaConsignatario();" value="...">
                                <%}%>
                            </strong>
                        </div>
                    </td>
                    <td colspan="2" class="CelulaZebra2">
                        <div align="center"><b><%=(carregaFat && ft.isBaixado() ? "STATUS: BAIXADA    Usuário: " + ft.getBaixadoPor().getNome() : carregaFat && ft.getSituacao().equals("CA") ? "STATUS: CANCELADO" : "STATUS: EM ABERTO")%></b></div>
                        <div align="center"><b><%=(carregaFat && ft.isBaixado() ? (ft.getTipoBaixa().equals("")? ""  : (ft.getTipoBaixa().equals("M") ? "Tipo da Baixa: Manual": "Tipo da Baixa: Arquivo de Retorno" )):  "")%></b></div>
                    </td>
                </tr>
            </table>                            
                <table width="85%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr id="trAba">
                    <td width="100%" colspan="8">
                        <table align="left">
                            <tr>
                                <td id="tdCtNfs" class="menu-sel" onclick="AlternarAbasGenerico('tdCtNfs','trCtNfs')">Seleção de documentos</td>
                                <td id="tdPgto" class="menu" onclick="AlternarAbasGenerico('tdPgto','trPgto')">Dados para Pagamento</td>
                                <td id="tdHistorico" class="menu" onclick="AlternarAbasGenerico('tdHistorico','trHistorico')">Histórico da Remessa</td>
                                <td id="tdRelacionamento" class="menu" style='display: <%= carregaFat && ft.getId() != 0 ? "" : "none" %>' onclick="AlternarAbasGenerico('tdRelacionamento','trRelacionamento')">Relacionamentos</td>
                                <td style='display: <%= carregaFat && nivelUser == 4 ? "" : "none" %>' id="tdAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAuditoria','trAuditoria')">Auditoria</td>
                            </tr>
                        </table>
                    </td> 
                </tr>
                <tr id="trCtNfs">
                    <td width="100%" colspan="8">
                        <table width="100%" border="0" class="bordaFina">
                            <tr>
                                <td colspan="8" class="tabela"><div align="center">CT-e(s) e/ou NFs desta Fatura/Boleto</div></td>
                            </tr>
                            <%if (acao.equals("iniciar") || (carregaFat && !ft.isBaixado() && !ft.getSituacao().equals("DT"))) {%>
                            <tr class="CelulaZebra2">
                                <td width="19%" colspan="2">
                                    <div align="left">
                                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Adicionar CT-e(s)/NFs" onClick="javascript:tryRequestToServer(function(){selecionar_ctrc(<%=0%>,'<%=acao%>','<%=isIncluirFaturasCTeConfirmados%>');});">
                                    </div>
                                <td width="21%" class="TextoCampos" colspan="1">
                                    <select id="tipo_chave_acesso" name="tipo_chave_acesso" class="fieldMin">
                                        <option value="chave_cte" selected>Localizar pela chave de acesso do CT-e:</option>
                                        <option value="chave_cte_redespacho">Localizar pela chave de acesso do CT-e Redespacho:</option>
                                    </select>
                                </td>
                                <td width="60%" colspan="4">
                                    <div align="left">
                                        <input id="chaveAcesso" name="chaveAcesso" type="text" class="inputtexto" size="44" maxlength="44" onkeypress="mascara(this, soNumeros); if (event.keyCode==13)javascript:tryRequestToServer(function(){ajaxCarregarCte($('chaveAcesso').value);});">
                                        <input id="btnChaveAcesso" name="btnChaveAcesso" type="button" class="botoes" size="10" onClick="javascript:tryRequestToServer(function(){ajaxCarregarCte($('chaveAcesso').value);});" value="Pesquisar">
                                    </div>
                                </td>
                            </tr>
                            <%}%>
                            <tr>
                                <td colspan="7">
                                    <table width="100%" border="0" name="tbDocs" id="tbDocs">
                                        <tr>
                                            <td width="1%" class="celula"></td>
                                            <td width="9%" class="celula">Tipo</td>
                                            <td width="10%" class="celula">Docum.</td>
                                            <td width="3%" class="celula"><div align="center">PC</div></td>
                                            <td width="9%" class="celula">Data</td>
                                            <td width="26%" class="celula">Remetente</td>
                                            <td width="26%" class="celula">Destinatário</td>
                                            <td width="8%" class="celula"><div align="right">Valor</div></td>
                                            <td width="9%" class="celula">Entrega</td>
                                            <c:if test="${nivelUser == 4 and not is_gera_boleto}">
                                                <td width="9%" class="celula"></td>
                                            </c:if>
                                        </tr>
                                        <%double totalParcelas = 0;
                                            int linha = 0;
                                            if (carregaFat) {
                                                BeanConsultaFatura conFat = new BeanConsultaFatura();
                                                conFat.setConexao(Apoio.getUsuario(request).getConexao());
                                                conFat.setCodFatura(ft.getCtrcs());
                                                conFat.getConfiguracao().setIncluirFaturasCTeConfirmados(Apoio.getConfiguracao(request).isIncluirFaturasCTeConfirmados());
                                                int i = 0;
                                                if(acao.equals("consultar")){
                                                    i = 2;
                                                }else{
                                                    i = 1;
                                                }
                                                if (conFat.consultaConhecimentos(i)) {
                                                ResultSet rs = conFat.getResultado();
                                                while (rs.next()) {%>
                                        <c:set var="linha" value="<%= linha %>"/>
                                        <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" id="tr_parcels_${linha}">
                                            <td>
                                                <img src="img/jpg.png" width="20" height="20" border="0" align="right"
                                                     class="imagemLink anexoCTRC" title="Imagens de documentos"
                                                     data-id="<%=(rs.getInt("sale_id"))%>"
                                                     data-filial-id="<%=(rs.getString("filial"))%>"
                                                     data-numero="<%=(rs.getString("doc"))%>"
                                                     data-data="<%=(Apoio.getFormatData(rs.getDate("emissao_em")))%>">
                                            </td>
                                            <td>
                                                <input name="<%="id_" + linha%>" type="hidden" id="<%="id_" + linha%>" value="<%=rs.getString("parcela_id")%>">
                                                <%=rs.getString("categoria").equals("ct") ? "CT-e" : (rs.getString("categoria").equals("fn") ? "Receita financeira" : "NF Serviço")%>                                </td>
                                            <td>
                                                <%if (rs.getString("categoria").equals("ns") && nivelNf > 0) {%>
                                                <div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(<%=rs.getString("sale_id")%>,0);});'>
                                                    <%} else if (rs.getString("categoria").equals("ct") && nivelCtrc > 0) {
                                            if (rs.getInt("filial_id") == Apoio.getUsuario(request).getFilial().getIdfilial()) {%>
                                                    <div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(<%=rs.getString("sale_id")%>,1);});'>
                                                        <%} else if (rs.getInt("filial_id") != Apoio.getUsuario(request).getFilial().getIdfilial() && nivelCtrcFilial > 0) {%>
                                                        <div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(<%=rs.getString("sale_id")%>,1);});'>
                                                            <%} else {%>
                                                            <div>
                                                                <%}
                                                    } else {%>
                                                                <div>
                                                                    <%}%>
                                                                    <%=rs.getString("doc") + "-" + rs.getString("serie")%>
                                                                </div>                                                    
                                                                </td>
                                                                <td><div align="center"><%=rs.getString("parcela")%></div></td>
                                                                <td>
                                                                    <%=(rs.getDate("emissao_em") == null ? "" : fmt.format(rs.getDate("emissao_em")))%>
                                                                    <input type="hidden" id="<%="emissao_cte_" + linha%>" name="<%="emissao_cte_" + linha%>" value="<%=fmt.format(rs.getDate("emissao_em"))%>">
                                                                </td>
                                                                <td><%=rs.getString("remetente")%></td>
                                                                <td><%=rs.getString("destinatario")%></td>
                                                                <td><div align="right" id="td_valor_parcel_${linha}"><%=fmtValor.format(rs.getDouble("valor_parcela"))%></div></td>
                                                                <td><%=(rs.getDate("baixa_em") == null ? "" : fmt.format(rs.getDate("baixa_em")))%></td>
                                                                <c:set var="is_baixado" value='<%= rs.getBoolean("is_baixado") %>' />
                                                                <c:if test="${nivelUser == 4 and not is_gera_boleto}">
                                                                    <td>
                                                                        <img src="${homePath}/img/lixo.png" alt="Excluir CT-e da Fatura" title="Excluir CT-e da Fatura"
                                                                            class="excluir-cte-fatura" ${is_baixado ? "style='visibility: hidden;'" : ""}>
                                                                    </td>
                                                                </c:if> 
                                                                    
                                                                </tr>
                                                                <%linha++;
                                                                    totalParcelas += rs.getDouble("valor_parcela");
                                                                }
                                                                rs.close();
                                                            }
                                                        }%>
                                        <c:if test="${linha eq 0}">
                                            <script>
                                                jQuery('.excluir-cte-fatura').css('visibility', 'hidden');
                                            </script>
                                        </c:if>
                                </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="trPgto" style="display: none">
                    <td width="100%" colspan="8">
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td height="17" colspan="6" align="center">Dados do Pagamento </td>
                            </tr>
                            <tr>
                                <td width="19%" class="TextoCampos">Valor Total Selecionado: </td>
                                <td width="12%" class="CelulaZebra2">
                                    <div align="center">
                                        <b><label name="lbtotal" id="lbtotal"><%=fmtValor.format(totalParcelas)%></label></b>
                                    </div>
                                </td>
                                <td width="13%" class="TextoCampos">Quantidade:</td>
                                <td width="11%" class="TextoCampos">
                                    <div align="center"><b id="lb_qtd"><%=new DecimalFormat("#,##0").format(linha)%></b></div>
                                </td>
                                <td width="12%" class="TextoCampos">Conta para Dep&oacute;sito: </td>
                                <td width="33%" class="CelulaZebra2">
                                    <select name="conta" id="conta" onChange="valoresDefaultBoleto(this.value)" class="fieldMin">
                                        <%
                                            //Carregando todas as contas cadastradas
                                            BeanConsultaConta conta = new BeanConsultaConta();
                                            conta.setConexao(Apoio.getUsuario(request).getConexao());
                                            conta.mostraContasFatura((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarVisualizarUsuarioConta, idUsuario, (carregaFat ? ft.getConta().getIdConta() : 0) );
                                            ResultSet rsconta = conta.getResultado();

                                            //carregando as contas num vetor
                                        %>
                                        <option value="0">N&atilde;o Informar</option>
                                        <%
                                                                                while (rsconta.next()) {%>
                                        <option value="<%=rsconta.getString("idconta")%>" <%=(carregaFat && ft.getConta().getIdConta() == rsconta.getInt("idconta") ? "selected" : "")%>>
                                            <%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%>                                                                            
                                        </option>
                                        <%}%>
                                    </select>
                                </td>
                                <%
                                    conta.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarVisualizarUsuarioConta, idUsuario);
                                    rsconta = conta.getResultado();
                                    while (rsconta.next()) {%>
                            <input type="hidden" name="hdInstrucao1_<%=rsconta.getString("idconta")%>" id="hdInstrucao1_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao1")%>">
                            <input type="hidden" name="hdInstrucao2_<%=rsconta.getString("idconta")%>" id="hdInstrucao2_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao2")%>">
                            <input type="hidden" name="hdInstrucao3_<%=rsconta.getString("idconta")%>" id="hdInstrucao3_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao3")%>">
                            <input type="hidden" name="hdInstrucao4_<%=rsconta.getString("idconta")%>" id="hdInstrucao4_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao4")%>">
                            <input type="hidden" name="hdInstrucao5_<%=rsconta.getString("idconta")%>" id="hdInstrucao5_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("boleto_instrucao5")%>">
                            <input type="hidden" name=",<%=rsconta.getString("idconta")%>" id="hdCodProtesto_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("cod_protesto")%>">
                            <input type="hidden" name="hdDiasProtesto_<%=rsconta.getString("idconta")%>" id="hdDiasProtesto_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("dias_protesto")%>">
                            <input type="hidden" name="hdCodDevolucao_<%=rsconta.getString("idconta")%>" id="hdCodDevolucao_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("cod_devolucao")%>">
                            <input type="hidden" name="hdDiasDevolucao_<%=rsconta.getString("idconta")%>" id="hdDiasDevolucao_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("dias_devolucao")%>">
                            <input type="hidden" name="hdJuros_<%=rsconta.getString("idconta")%>" id="hdJuros_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("juros_acrescimo")%>">
                            <input type="hidden" name="hdMulta_<%=rsconta.getString("idconta")%>" id="hdMulta_<%=rsconta.getString("idconta")%>" value="<%=rsconta.getString("multa")%>">
                            <%}%>
                            </tr>
                            <tr>
                                <td class="TextoCampos"><span class="TextoCampos">Valor Desconto:</span></td>
                                <td class="CelulaZebra2">
                                    <input name="valorDesconto" type="text" id="valorDesconto"  onBlur="javascript:seNaoFloatReset(this,'0.00');calculaLiquido();if(this.value != '0.00'){$('chkDesconto').checked = true;calculaLiquido();}" value="<%=(carregaFat ? Apoio.to_curr(ft.getValorDesconto()) : "0.00")%>" size="6" maxlength="12" class="inputtexto">
                                    <input  name="localiza_ctrc" type="button" class="botoes" id="localiza_ctrc" onClick="javascript:localizaCtrc();" value="...">
                                    <img id="btnLimparAvaria" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Desvincular os conhecimentos selecionados com avarias." onClick="limparAvaria();">
                                </td>
                                <td colspan="2" class="TextoCampos">
                                    <div align="center">
                                        <input name="chkDesconto" type="checkbox" id="chkDesconto" value="checkbox" onClick="javascript:calculaLiquido();" <%=(carregaFat && ft.isDeduzirDesconto() ? "checked" : "")%>>
                                        Deduzir Desconto do Total.
                                    </div>
                                </td>
                                <td class="TextoCampos"><span class="TextoCampos">Descri&ccedil;&atilde;o Desconto:</span></td>
                                <td class="CelulaZebra2"><input name="descricaoDesconto" type="text" id="descricaoDesconto" value="<%=(carregaFat ? ft.getDescricaoDesconto() : "")%>" size="30" class="inputtexto"></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Outros Acr&eacute;scimos: </td>
                                <td class="CelulaZebra2"><input name="valorAcrescimo" type="text" id="valorAcrescimo"  onBlur="javascript:seNaoFloatReset(this,'0.00');calculaLiquido();" value="<%=(carregaFat ? Apoio.to_curr(ft.getValorAcrescimo()) : "0.00")%>" size="6" maxlength="12" class="inputtexto"></td>
                                <td colspan="4" class="CelulaZebra2">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Qtd Recalculo: <%=(carregaFat ? ft.getQtdTaxaRecalculo() : "0")%> no valor de <%=(carregaFat ? Apoio.to_curr(ft.getValorTaxaRecalculo()) : "0.00")%>:</td>
                                <td class="CelulaZebra2"><input name="valorRecalculo" type="text" id="valorRecalculo" value="<%=(carregaFat ? ft.getQtdTaxaRecalculo() * ft.getValorTaxaRecalculo() : 0)%>" size="6" maxlength="12" class="inputReadOnly" readonly></td>
                                <td colspan="4" class="CelulaZebra2">&nbsp;</td>
                                <input type="hidden" name="qtdRecalculo" id="qtdRecalculo" value="<%=(carregaFat ? ft.getQtdTaxaRecalculo() : "0")%>">
                                <input type="hidden" name="valorRecalculo" id="valorRecalculo" value="<%=(carregaFat ? ft.getValorTaxaRecalculo() : "0.0")%>">
                            </tr>
                            <tr>
                                <td class="TextoCampos">Valor L&iacute;quido: </td>
                                <td class="CelulaZebra2">
                                    <input type="hidden" name="valorLiquido" id="valorLiquido" value="0,00"/>
                                    <div align="center">
                                        <b><label name="lbliq" id="lbliq">0,00</label></b>
                                    </div>
                                </td>
                                <td colspan="4" class="CelulaZebra2">
                                    Ap&oacute;s o Vencimento Aplicar Multa De
                                    <input name="multa" type="text" id="multa"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregaFat ? Apoio.to_curr(ft.getMultaAcrescimo()) : "0.00")%>" size="4" maxlength="12" class="inputtexto">
                                    % e Juros de
                                    <input name="juros" type="text" id="juros"  onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregaFat ? Apoio.to_curr(ft.getJurosAcrescimo()) : "0.00")%>" size="4" maxlength="12" class="inputtexto">
                                    % ao M&ecirc;s.
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" class="TextoCampos">Filial Respons&aacute;vel Pela Cobran&ccedil;a: </td>
                                <td colspan="2" class="CelulaZebra2">
                                    <select name="filialCobrancaId" id="filialCobrancaId" class="inputtexto">
                                        <%BeanFilial fl = new BeanFilial();
                                                                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                                        <%while (rsFl.next()) {%>
                                        <option value="<%=rsFl.getString("idfilial")%>" <%=(!carregaFat && Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : (carregaFat && ft.getFilialCobranca().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : ""))%> ><%=rsFl.getString("abreviatura")%></option>
                                        <%}%>
                                    </select>
                                </td>
                                <td class="TextoCampos">Situa&ccedil;&atilde;o da Fatura:</td>
                                <td class="CelulaZebra2">
                                    <select name="situacao" id="situacao" class="inputtexto" onchange="alteraSituacao();">
                                        <option value="NM" selected>Normal</option>
                                        <option value="CA">Cancelada</option>
                                        <option value="CO">Cortesia</option>
                                        <option value="TC">Cartório</option>
                                        <option value="DT">Descontada (Factoring)</option>
                                        <option value="DE">Devedora (Em Cobrança)</option>
                                    </select>
                                    <%if (carregaFat && ft.getDescontoFactoring().getId() != 0 && nivelFactoring > 0) {%>
                                    <label class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarFactoring(<%=ft.getDescontoFactoring().getId()%>);});'> Ver desconto</label>
                                    <%}%>
                                    <input name="bordero_id" type="hidden" id="bordero_id"  value="<%=(carregaFat ? ft.getDescontoFactoring().getId() : "0")%>">
                                    <div id="divEmpresaCobranca" name="divEmpresaCobranca" style="display: none;">
                                        <input type="hidden" name="idfornecedor" id="idfornecedor" value="<%=(carregaFat ? ft.getEmpresaCobranca().getId() : "0")%>">
                                        Empresa Cobrança:
                                        <input name="fornecedor" type="text" id="fornecedor" size="20" maxlength="80" readonly="true" class="inputReadOnly" value="<%=(carregaFat ? ft.getEmpresaCobranca().getRazaosocial() : "")%>">
                                        <input name="localiza_forn" type="button" class="botoes" id="localiza_forn" value="..." onClick="javascript:localizaforn();">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:limparforn();"> 
                                    </div>

                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Observa&ccedil;&atilde;o:</td>
                                <td colspan="5" class="CelulaZebra2">
                                    <textarea name="observacao" cols="70" rows="4" id="observacao" class="inputtexto"><%=(carregaFat ? ft.getObservacao() : "")%></textarea>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Número Pré Fatura:</td>
                                <td colspan="5" class="CelulaZebra2">
                                    <input name="numeroPreFatura" type="text" maxlength="20" id="numeroPreFatura" value="<%=(carregaFat ? ft.getNumeroPreFatura() : "")%>" size="20" class="inputtexto">
                                </td>
                            </tr>
                            <tr>
                                <td align="center" colspan="6" class="CelulaZebra2">
                                    <div align="center">
                                        <input type="checkbox" name="geraBoleto" id="geraBoleto" onClick="controlaTrBoleto(this.checked);valoresDefaultBoleto($('conta').value);habilitarNaoProtestar();clienteNuncaProtestar($('codProtesto').value)" <%=(ft.isGeraBoleto() ? "checked" : "")%>>
                                        Gerar Boleto (Cobrança Bancária)
                                    </div>                                                                    
                                </td>
                            </tr>
                            <tr id="trBoleto">
                                <td colspan="6">
                                    <table class="bordaFina" width="100%">
                                        <%if (carregaFat) {%>
                                        <tr>
                                            <td colspan="2">
                                                <table class="bordaFina" width="100%">
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos">Nosso N°:</td>
                                                        <td class="CelulaZebra2">
                                                            <input type="text" name="nossoNumero" id="nossoNumero" class="inputReadOnly" readonly  value="<%=(carregaFat ? ft.getBoletoNossoNumero() : "")%>" size="10">
                                                        </td>
                                                        <td align="center" >
                                                            <input type="checkbox" name="aceite" id="aceite" value="aceite" <%=(carregaFat && ft.isAceite() ? "checked" : "")%> >
                                                            <label for="aceite">Aceite</label>
                                                        </td>
                                                        <td class="TextoCampos">Espécie Doc.:</td>
                                                        <td class="CelulaZebra2">
                                                            <select name="especieBoleto" id="especieBoleto" class="inputtexto">
                                                                <option value="DM" <%=(carregaFat && ft.getEspecieBoleto().equals("DM") ? "SELECTED" : "")%> >DM</option>
                                                                <option value="DS" <%=(carregaFat && ft.getEspecieBoleto().equals("DS") ? "SELECTED" : "")%>>DS</option>
                                                            </select>                                                                                            
                                                        </td>
                                                    </tr>
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos">Protesto</td>
                                                        <td class="CelulaZebra2">
                                                            <select name="codProtesto" id="codProtesto" class="inputtexto" style="width: 247px" onchange="clienteNuncaProtestar(this.value);">
                                                                <option value="1" <%=(carregaFat && ft.getCodProtesto() == 1 ? "SELECTED" : "")%>>Protestar dias corridos</option>
                                                                <option value="2" <%=(carregaFat && ft.getCodProtesto() == 2 ? "SELECTED" : "")%>>Protestar dias úteis</option>
                                                                <option value="3" <%=(carregaFat && ft.getCodProtesto() == 3 ? "SELECTED" : "")%>>Não protestar</option>
                                                                <option value="4" <%=(carregaFat && ft.getCodProtesto() == 4 ? "SELECTED" : "")%>>Protestar fim falimentar - Dias úteis</option>
                                                                <option value="5" <%=(carregaFat && ft.getCodProtesto() == 5 ? "SELECTED" : "")%>>Protestar fim falimentar - Dias corridos</option>
                                                                <option value="9" <%=(carregaFat && ft.getCodProtesto() == 9 ? "SELECTED" : "")%>>Cancelamento protesto automático</option>
                                                            </select>
                                                        </td>
                                                        <td class="TextoCampos">Dias Protesto</td>
                                                        <td class="CelulaZebra2" colspan="2">
                                                            <input type="text" class="inputtexto" size="7" id="diasProtesto" onChange="seNaoIntReset(this, '0')" name="diasProtesto" value="<%=(carregaFat ? ft.getDiasProtesto() : "")%>">
                                                        </td>
                                                    </tr>
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos">Devolução</td>
                                                        <td class="CelulaZebra2">
                                                            <select name="codDevolucao" id="codDevolucao" class="inputtexto" style="width: 80px" >
                                                                <option value="1" <%=(carregaFat && ft.getCodDevolucao() == 1 ? "SELECTED" : "")%>>SIM</option>
                                                                <option value="2" <%=(carregaFat && ft.getCodDevolucao() == 2 ? "SELECTED" : "")%>>NÃO</option>
                                                            </select>
                                                        </td>
                                                        <td class="TextoCampos">Dias Devolução</td>
                                                        <td class="CelulaZebra2" colspan="2">
                                                            <input type="text" class="inputtexto" size="7" id="diasDevolucao" onChange="seNaoIntReset(this, '0')" name="diasDevolucao" value="<%=(carregaFat ? ft.getDiasDevolucao() : "")%>">
                                                        </td>
                                                    </tr>
                                                </table>                                                                                
                                            </td>
                                        </tr>
                                        <%}%>

                                        <tr>
                                            <td class="TextoCampos">Instrução 1:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao1" id="instrucao1" maxlength="50" class="inputTexto" value="<%=(carregaFat ? ft.getBoletoInstrucao1() : "")%>" size="50" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});"> 
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instrução 2:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao2" id="instrucao2" maxlength="50" class="inputTexto" value="<%=(carregaFat ? ft.getBoletoInstrucao2() : "")%>" size="50" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                                                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instrução 3:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao3" id="instrucao3" maxlength="50" class="inputTexto" value="<%=(carregaFat ? ft.getBoletoInstrucao3() : "")%>" size="50" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                                                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instrução 4:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao4" id="instrucao4" maxlength="50" class="inputTexto" value="<%=(carregaFat ? ft.getBoletoInstrucao4() : "")%>" size="50" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                                                                                
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Instrução 5:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="instrucao5" id="instrucao5" maxlength="50" class="inputTexto" value="<%=(carregaFat ? ft.getBoletoInstrucao5() : "")%>" size="50" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                                                                                
                                            </td>
                                        </tr>
                                    </table>                                                                    
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="trHistorico" style="display: none">
                    <td width="100%" colspan="8">
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td height="17" colspan="6" align="center">Histórico para Arquivo de Remessa</td>
                            </tr>
                            <tr class="Celula">
                                <td height="17" align="center" width="3%">
                                    <img src="img/add.gif" border="0" class="imagemLink"
                                         title="Adicionar um novo Pagamento"
                                         onClick="addHistoricoArquivoRemessa(null, $('tbHistoricoRemessa'))"></span> <input type="hidden"
                                         id="maxHistorico" name="maxHistorico" value="0" />
                                </td>
                                <td colspan="1" align="left" width="17%">
                                    <label>Mov. Remessa</label>
                                </td>
                                <td colspan="1" align="center" width="10%">
                                    <label>Dt. Inclusão</label>
                                </td>
                                <td colspan="3" align="left" width="70%">
                                    <label></label>
                                </td>
                            </tr>
                            <tbody id="tbHistoricoRemessa"></tbody>
                        </table>
                    </td>
                </tr>
                
                <tr id="trRelacionamento" style="display: none">
                   <td>
                    <table>
                    <tr>
                        <td width="5%" class="CelulaZebra2"colspan="3">
                            <input type="button" value="Adicionar novo Relacionamento" id="btAdd" name="btAdd" class="botoes" onclick="novoRelacionamento();">
                        </td>
                        <td class="CelulaZebra2" id="tdCancelar" name="tdCancelar" style="display:none">
                            <input type="button" value="Cancelar" id="btCacelar" name="btCacelar" class="botoes" onclick="cancelarRelacionamento();">
                        </td>
                    <tr>
                        <td width="100%" colspan="8">
                            <table width="100%" border="0"  class="bordaFina" align="center">
                                <tr class="tabela">
                                    <td height="17" colspan="10" align="center">Relacionamentos</td>
                                </tr>
                              <tr>
                                <td id="novoRelacionamento" name="novoRelacionamento" style="display:none">
                                    <table width="100%" border="0"  class="bordaFina" align="center">
                                    <tr>
                                        <td width="2%" class="TextoCampos">Data </td>
                                        <td width="5%" class="CelulaZebra2">
                                            <input name="dataOcorrencia" type="text" id="dataOcorrencia" onblur="alertInvalidDate(this);" onKeyPress="fmtDate(this, event)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)"  value="" size="8"  class="inputtexto">
                                        </td>
                                        <td width="2%" class="TextoCampos">Hora </td>
                                        <td width="25%" class="CelulaZebra2" colspan="7">
                                            <input name="horaOcorrencia" type="text" id="horaOcorrencia" onKeyPress="mascaraHora(this)" onKeyDown="mascaraHora(this)" onKeyUp="mascaraHora(this)"  value="" size="8" class="inputtexto">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="2%" class="TextoCampos">Contato </td>
                                        <td width="10%" class="CelulaZebra2">
                                            <input name="contatoOcorrencia" type="text" id="contatoOcorrencia" class="inputtexto">
                                        </td>
                                        <td width="2%" class="TextoCampos">Fone </td>
                                        <td width="25%" class="CelulaZebra2" colspan="7">
                                            <input name="foneOcorrencia" type="text" id="foneOcorrencia" value="<%=(carregaFat ? ft.getCliente().getFone() : "")%>" class="inputtexto">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="5%" class="TextoCampos" >Descrição </td>
                                        <td width="95%" class="CelulaZebra2" colspan="8">
                                            <textarea name="descricaoOcorrencia" id="descricaoOcorrencia" rows="5" cols="100" class="inputtexto"></textarea>
                                        </td>
                                    </tr>
                                   </table>
                                </td>
                              </tr>
                            </table>
                            <table width="100%" border="0" class="bordaFina" align="center">
                                <td width="5%" class="CelulaZebra2"colspan="10">
                                    <input type="button" value="Visualizar Relacionamento(s)" id="btCarregar" name="btCarregar" class="botoes" onclick="carregarRelacionamento();">
                                </td>
                                <tr class="tabela">
                                     <td height="17" colspan="10" align="center">Relacionamentos antigos</td>
                                </tr>
                                <tr>
                                    <tbody id="bodyRelacionamento"></tbody>
                                </tr>
                            </table>
                            <table width="100%" border="0" class="bordaFina" align="center" id="tb-rastreamento-fatura">
                                <tr>
                                    <td width="5%" class="CelulaZebra2"colspan="10">
                                        <input type="button" value="Visualizar Rastreabilidade" id="btCarregar" name="btCarregar" class="botoes" onclick="visualizarRastreabilidadeEmail('<%=(carregaFat ? ft.getId() : 0)%>');">
                                    </td>
                                </tr>
                                <tr class="tabela">
                                     <td height="17" colspan="10" align="center">Rastreabilidade</td>
                                </tr>
                                <tr>
                                    <td>
                                        <table class="bordaFina" width="100%">
                                            <tbody id="tbody-rastreamento">
                                                <tr class="tabela">
                                                    <td>Data / Hora</td>
                                                    <td>Usuário</td>
                                                    <td>Ação</td>
                                                    <td>E-mail destino</td>
                                                    <td>ID da mensagem</td>
                                                    <td>Descrição</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <input name="maxRelacionamento" type="hidden" id="maxRelacionamento" value="" class="inputtexto">
                        </td>
                    </tr>
                    </tr>
                    </table>
                   </td>
                </tr>
                
                <tr id ="trAuditoria" style='display: none'>
                    <td>
                        <table width="100%" border="0" class="bordaFina">
                            <Tr>
                                
                    <td>
                        <%@include file="/gwTrans/template_auditoria.jsp" %>
                    </td>
                    <td colspan="8">
                        <table width="100%" border="0" class="bordaFina">
                            <tr>
                                <td width="11%" class="TextoCampos">Incluso:</td>
                                <td width="22%" class="CelulaZebra2">
                                    Em: <%=carregaFat && ft.getCreatedAt() != null ? fmt.format(ft.getCreatedAt()) : ""%>
                                    <br>
                                    Por: <%=carregaFat && ft.getCreatedAt() != null ? ft.getCreated_by().getNome() : ""%>
                                </td>
                                <td width="11%" class="TextoCampos">Alterado:</td>
                                <td width="22%" class="CelulaZebra2">
                                    Em: <%=(carregaFat && ft.getUpdatedAt() != null ? fmt.format(ft.getUpdatedAt()) : "")%><br>
                                    Por: <%=(carregaFat ? ft.getUpdated_by().getNome() : "")%>
                                </td>
                                <td width="11%" class="TextoCampos">Exportado:</td>
                                <td width="22%" class="CelulaZebra2">
                                    Em: <%=carregaFat && ft.getExportadoEm() != null ? ft.getExportadoEm() : ""%>                                                                        
                                    <br>
                                    Por: <%=carregaFat && ft.getExportadoPor() != null ? ft.getExportadoPor().getNome() : ""%>
                                </td>
                            </tr>
                        </table>      
                    </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                 
                <tr class="CelulaZebra2">
                    <td height="24" colspan="8">
                <center>
                    <%
                    if (nivelUser >= 2) {
                        if (acao.equals("iniciar") || (carregaFat && !ft.isBaixado())){%>
                        <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : (acao.equalsIgnoreCase("consultar")) ? "incluir" : "atualizar")%>');});">
                        <%} else {%>
                            Fatura Já Baixada, Alteração Não Permitida.
                        <%}
                    }
                    %>
                </center>
                </td>
                </tr>
            </table>
            <script type="text/javascript">
                calculaLiquido();
                jQuery('.block-all-carregando').hide();

                var homePath = '${homePath}';
                var faturaId = '${faturaId}';

                jQuery('#tbDocs').on('click', '.anexoCTRC', function() {
                    var elemento = jQuery(this);

                    window.open('./ImagemControlador?acao=carregar&idconhecimento=' + elemento.attr('data-id')
                        + '&numero=' + elemento.attr('data-numero') + '&data=' + elemento.attr('data-data') + '&filial=' + elemento.attr('data-filial-id')
                        + '&visualizar=true',
                        'imagensConhecimento', 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
                });
            </script>
        </form>
        <br>
    </body>
</html>
