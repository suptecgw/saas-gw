<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="usuario.BeanUsuario"%>
<%@page import="br.com.gwsistemas.categoriacarga.CategoriaCargaDAO"%>
<%@page import="br.com.gwsistemas.categoriacarga.CategoriaCarga"%>
<%@page import="nucleo.autorizacao.tipoautorizacao.TipoAutorizacao"%>
<%@page import="conhecimento.romaneio.BeanCtrcRomaneio"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.text.SimpleDateFormat,java.text.DecimalFormat,mov_banco.*,mov_banco.conta.*,conhecimento.orcamento.Cubagem,java.text.DecimalFormatSymbols,java.util.Locale,conhecimento.coleta.tipoContainer.*,nucleo.*,filial.BeanFilial,fpag.*,cliente.*,cidade.*,veiculo.BeanVeiculo,cfop.BeanCfop,conhecimento.*,viagem.BeanViagem,despesa.BeanDespesa,         despesa.duplicata.*,despesa.apropriacao.BeanApropDespesa,conhecimento.duplicata.BeanDuplicata,conhecimento.apropriacao.BeanApropriacao,planocusto.BeanPlanoCusto,com.sagat.bean.*,tipo_veiculos.ConsultaTipo_veiculos,java.sql.ResultSet,javax.script.*,cliente.tipoProduto.TipoProduto,org.json.simple.JSONObject,conhecimento.manifesto.BeanManifesto,conhecimento.manifesto.BeanCadManifesto,java.util.Date,conhecimento.cartafrete.BeanCartaFrete,conhecimento.cartafrete.BeanPagamentoCartaFrete"%>
<%
if (Apoio.getUsuario(request) == null)
    getServletContext().getRequestDispatcher("/login").forward(request, response);
%><%
int nvUser = Apoio.getUsuario(request).getAcesso("cadconhecimento");
int nvAlFrete = Apoio.getUsuario(request).getAcesso("alttabprecolanccontrfrete");
int nvCli = Apoio.getUsuario(request).getAcesso("cadcliente");
int nvRom = Apoio.getUsuario(request).getAcesso("cadromaneio");
int nvMan = Apoio.getUsuario(request).getAcesso("cadmanifesto");
int nvFinCli = Apoio.getUsuario(request).getAcesso("altclifinan");
int nvAltCt = Apoio.getUsuario(request).getAcesso("altnumctrc");
int nvCom = Apoio.getUsuario(request).getAcesso("vercomissao");
int nvCarta = Apoio.getUsuario(request).getAcesso("lancartafrete");
int nvADV = Apoio.getUsuario(request).getAcesso("lanviagem");
int nvAWB = Apoio.getUsuario(request).getAcesso("cadawb");
int nvVenda = Apoio.getUsuario(request).getAcesso("cadvenda");
int nvCancCT = Apoio.getUsuario(request).getAcesso("lancancelamentoctrc");
int nivelUserAdiantamento = (Apoio.getUsuario(request) != null? Apoio.getUsuario(request).getAcesso("alterapercadiant") : 0);
int nivelAverbacaoManual = Apoio.getUsuario(request).getAcesso("lanaverbacaoCTeManual");
int nivelImprimirDacte = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("imprimirdactes") : 0);
int nivelCte = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("altnfefilial") : 0);
String acao = (request.getParameter("acao") == null || Apoio.getUsuario(request) == null ? "" : request.getParameter("acao"));
boolean alteraPreco = (Apoio.getUsuario(request).getAcesso("alteraprecocte") == 4);
boolean alteraIcms = (Apoio.getUsuario(request).getAcesso("alterainffiscal") == 4);
boolean alteraTipoFrete = (Apoio.getUsuario(request).getAcesso("alteratipofretecte") == 4);
boolean nivelAlteraImpostos = (Apoio.getUsuario(request).getAcesso("alteraimpostoscartafrete")==4);
boolean carregaconh   = false;
boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
boolean limitarUsuarioVisualizarContas = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
int idUsuario = Apoio.getUsuario(request).getIdusuario();
int xFilialUsuario = Apoio.getUsuario(request).getFilial().getIdfilial();
boolean isAtivaDivisaoIcmsUFDestino = Apoio.getUsuario(request).getFilial().isAtivaDivisaoIcms();
Collection<SituacaoTributavel> listaStIcms = SituacaoTributavelICMS.mostrarTodos(Apoio.getUsuario(request).getConexao());
Collection<CategoriaCarga> listaCategoriaCarga = CategoriaCargaDAO.mostrarTodos(Apoio.getUsuario(request).getConexao());
BeanCadConhecimento cadconh = new BeanCadConhecimento();
BeanConhecimento    conh    = new BeanConhecimento();
BeanConfiguracao cfg = null;
BeanPlanoCusto plcustopadrao = null;
String obs = "";
String nfiscal = "";
String nSelo = "";
String fpagCartaFrete = "";
String fpagCartaFreteExtra1 = "";
String fpagCartaFreteExtra2 = "";
SimpleDateFormat formatDate = new SimpleDateFormat("dd/MM/yyyy");
SimpleDateFormat formatTime = new SimpleDateFormat("HH:mm");
DecimalFormatSymbols dfs = new DecimalFormatSymbols(new Locale("pt","BR"));
dfs.setDecimalSeparator('.');
DecimalFormat fmt  = new DecimalFormat("0.00", dfs);
fmt.setDecimalSeparatorAlwaysShown(true);
String driverImpressao = "CTRC";
String impressora = "LPT1";//dados padros de conhecimento de transporte(preenchidos na configuracao)
int idCfopComercioDentro = 0, idPlanoCfopComercioDentro = 0 ,idCfopComercioFora = 0, idPlanoCfopComercioFora = 0, idCfopIndDentro = 0, idPlanoCfopIndDentro = 0, idCfopIndFora = 0;
String cfopComercioDentro = "", cfopComercioFora = "", cfopIndDentro = "", cfopIndFora = "";
int idPlanoCfopIndFora = 0;
int idCfopPFDentro = 0;
String cfopPFDentro = "";
int idPlanoCfopPFDentro = 0;
int idCfopPFFora = 0;
String cfopPFFora = "";
int idPlanoCfopPFFora = 0;
int idCfopOutroEstado = 0;
String cfopOutroEstado = "";
int idPlanoCfopOutroEstado = 0;
int idCfopOutroEstadoFora = 0;
String cfopOutroEstadoFora = "";
int idPlanoCfopOutroEstadoFora = 0;
int idCfopTransporteDentro = 0;
String cfopTransporteDentro = "";
int idPlanoCfopTransporteDentro = 0;
int idCfopTransporteFora = 0;
String cfopTransporteFora = "";
int idPlanoCfopTransporteFora = 0;
int idCfopPrestacaoServicoDentro = 0;
String cfopPrestacaoServicoDentro = "";
int idPlanoCfopPrestacaoServicoDentro = 0;
int idCfopPrestacaoServicoFora = 0;
String cfopPrestacaoServicoFora = "";
int idPlanoCfopPrestacaoServicoFora = 0;
int idCfopProdutorRuralDentro = 0;
String cfopProdutorRuralDentro = "";
int idPlanoCfopProdutorRuralDentro = 0;
int idCfopProdutorRuralFora = 0;
String cfopProdutorRuralFora = "";
int idPlanoCfopProdutorRuralFora = 0;
int idCfopExteriorDentro = 0;
String cfopExteriorDentro = "";
int idPlanoCfopExteriorDentro = 0;
int idCfopExteriorFora = 0;
String cfopExteriorFora = "";
int idPlanoCfopExteriorFora = 0;
int idCfopSubContratacaoDentro = 0;
String cfopSubContratacaoDentro = "";
int idPlanoCfopSubContratacaoDentro = 0;
int idCfopSubContratacaoFora = 0;
String cfopSubContratacaoFora = "";
int idPlanoCfopSubContratacaoFora = 0;
  cfg = Apoio.getConfiguracao(request); //obtendo o cfop padrao alterado na configuracao
  idCfopComercioDentro = cfg.getCfopDefault().getIdcfop();
  cfopComercioDentro = cfg.getCfopDefault().getCfop();
  idPlanoCfopComercioDentro = cfg.getCfopDefault().getPlanoCusto().getIdconta();
  idCfopComercioFora = cfg.getCfopDefault2().getIdcfop();
  cfopComercioFora = cfg.getCfopDefault2().getCfop();
  idPlanoCfopComercioFora = cfg.getCfopDefault2().getPlanoCusto().getIdconta();
  idCfopIndDentro = cfg.getCfopIndustriaDentro().getIdcfop();
  cfopIndDentro = cfg.getCfopIndustriaDentro().getCfop();
  idPlanoCfopIndDentro = cfg.getCfopIndustriaDentro().getPlanoCusto().getIdconta();
  idCfopIndFora = cfg.getCfopIndustriaFora().getIdcfop();
  cfopIndFora = cfg.getCfopIndustriaFora().getCfop();
  idPlanoCfopIndFora = cfg.getCfopIndustriaFora().getPlanoCusto().getIdconta();
  idCfopPFDentro = cfg.getCfopPessoaFisicaDentro().getIdcfop();
  cfopPFDentro = cfg.getCfopPessoaFisicaDentro().getCfop();
  idPlanoCfopPFDentro = cfg.getCfopPessoaFisicaDentro().getPlanoCusto().getIdconta();
  idCfopPFFora = cfg.getCfopPessoaFisicaFora().getIdcfop();
  cfopPFFora = cfg.getCfopPessoaFisicaFora().getCfop();
  idPlanoCfopPFFora = cfg.getCfopPessoaFisicaFora().getPlanoCusto().getIdconta();
  idCfopOutroEstado = cfg.getCfopOutroEstado().getIdcfop();
  cfopOutroEstado = cfg.getCfopOutroEstado().getCfop();
  idPlanoCfopOutroEstado = cfg.getCfopOutroEstado().getPlanoCusto().getIdconta();
  idCfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getIdcfop();
  cfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getCfop();
  idPlanoCfopOutroEstadoFora = cfg.getCfopOutroEstadoFora().getPlanoCusto().getIdconta();
  idCfopTransporteDentro = cfg.getCfopTransporteDentro().getIdcfop();
  cfopTransporteDentro = cfg.getCfopTransporteDentro().getCfop();
  idPlanoCfopTransporteDentro = cfg.getCfopTransporteDentro().getPlanoCusto().getIdconta();
  idCfopTransporteFora = cfg.getCfopTransporteFora().getIdcfop();
  cfopTransporteFora = cfg.getCfopTransporteFora().getCfop();
  idPlanoCfopTransporteFora = cfg.getCfopTransporteFora().getPlanoCusto().getIdconta();
  idCfopPrestacaoServicoDentro = cfg.getCfopPrestadorServicoDentro().getIdcfop();
  cfopPrestacaoServicoDentro = cfg.getCfopPrestadorServicoDentro().getCfop();
  idPlanoCfopPrestacaoServicoDentro = cfg.getCfopPrestadorServicoDentro().getPlanoCusto().getIdconta();
  idCfopPrestacaoServicoFora = cfg.getCfopPrestadorServicoFora().getIdcfop();
  cfopPrestacaoServicoFora = cfg.getCfopPrestadorServicoFora().getCfop();
  idPlanoCfopPrestacaoServicoFora = cfg.getCfopPrestadorServicoFora().getPlanoCusto().getIdconta();
  idCfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getIdcfop();
  cfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getCfop();
  idPlanoCfopProdutorRuralDentro = cfg.getCfopProdutorRuralDentro().getPlanoCusto().getIdconta();
  idCfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getIdcfop();
  cfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getCfop();
  idPlanoCfopProdutorRuralFora = cfg.getCfopProdutorRuralFora().getPlanoCusto().getIdconta();  
  idCfopExteriorDentro = cfg.getCfopExteriorDentro().getIdcfop();
  cfopExteriorDentro = cfg.getCfopExteriorDentro().getCfop();
  idPlanoCfopExteriorDentro = cfg.getCfopExteriorDentro().getPlanoCusto().getIdconta();
  idCfopExteriorFora = cfg.getCfopExteriorFora().getIdcfop();
  cfopExteriorFora = cfg.getCfopExteriorFora().getCfop();
  idPlanoCfopExteriorFora = cfg.getCfopExteriorFora().getPlanoCusto().getIdconta();  
  idCfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getIdcfop();
  cfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getCfop();
  idPlanoCfopSubContratacaoDentro = cfg.getCfopSubContratacaoDentro().getPlanoCusto().getIdconta();
  idCfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getIdcfop();
  cfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getCfop();
  idPlanoCfopSubContratacaoFora = cfg.getCfopSubContratacaoFora().getPlanoCusto().getIdconta();
  plcustopadrao = cfg.getPlanoDefault();
if (acao.equals("iniciar") || acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("localizarPesoContainer")){
  cadconh = new BeanCadConhecimento();
  cadconh.setExecutor(Apoio.getUsuario(request));
  cadconh.setConexao(Apoio.getUsuario(request).getConexao());  
 if (acao.equals("localizarPesoContainer")){
        if (request.getParameter("idContainer") != null) {
            String resposta = cadconh.pesoContainer(Integer.parseInt(request.getParameter("idContainer")));
            response.getWriter().println(resposta);}}}
if (acao.equals("iniciar")){//obtendo a proxima nota fiscal da filial do usuario isCte se for Homologação, Produção, Servidor de Contigencia do Rio Grande do Sul e SP
  String statusCte = String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte());
  boolean isCte = statusCte.equals("H") || statusCte.equals("P") || statusCte.equals("R") || statusCte.equals("S");
  String especieSequencia = (isCte ? "CTE" : "CTR"); String serieSequencia = ""; 
    if (isCte) {if (!Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAereo().equals("") || !Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAquaviario().equals("") || !Apoio.getUsuario(request).getFilial().getSeriePadraoCTeRodoviario().equals("") ) {
            if (cadconh.getConhecimento().getTipoTransporte().equals("r")) {serieSequencia = (String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeRodoviario()).equals("") ? cfg.getSeriePadraoCtrc() : String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeRodoviario()));
            }else if(cadconh.getConhecimento().getTipoTransporte().equals("a")){serieSequencia = (String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAereo()).equals("") ? cfg.getSeriePadraoCtrc() : String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAereo()));
               }else if(cadconh.getConhecimento().getTipoTransporte().equals("q")){serieSequencia = (String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAquaviario()).equals("") ? cfg.getSeriePadraoCtrc() : String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAquaviario()));}
          }else{serieSequencia = cfg.getSeriePadraoCtrc();}
      }else{serieSequencia = String.valueOf(Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAquaviario());}
  cadconh.getConhecimento().setFilial(Apoio.getUsuario(request).getFilial());
  nfiscal = cadconh.getProximaNFiscal(serieSequencia, especieSequencia, xFilialUsuario, Apoio.getUsuario(request).getAgencia().getId(),String.valueOf(cadconh.getConhecimento().getFilial().isSequenciaCtMultiModal()));  
  nSelo = cadconh.getProximoSelo(cfg.getSeriePadraoCtrc(),xFilialUsuario,String.valueOf(Apoio.getUsuario(request).getFilial().isControlaSequenciaSelo()));
}else if ((acao.equals("editar")) && (request.getParameter("id") != null)){
  int idmovimento = Integer.parseInt(request.getParameter("id"));
  cadconh.getConhecimento().setId(idmovimento); cadconh.loadAll(); conh = cadconh.getConhecimento();
}else if ((nvUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))){}//acao de atualizar ou incluir variavel usada para saber se o usuario esta editando
   carregaconh = (((conh != null) && (conh.getFilial() != null)) && acao.equals("editar"));   //estou usando atalho de objeto p/ ficar mais compreensível
   request.setAttribute("carregaconh", carregaconh);
   BeanFilial fi = (carregaconh ? conh.getFilial() : Apoio.getUsuario(request).getFilial());
   BeanCliente rem = (carregaconh ? conh.getRemetente() : null);
   BeanCliente des = (carregaconh ? conh.getDestinatario() : null);
   BeanCliente con = (carregaconh ? conh.getCliente() : null);
   BeanCliente red = (carregaconh ? (conh.getRedespacho().getIdcliente() > 0 ? conh.getRedespacho() : null) : null);
   BeanVeiculo vei = (carregaconh ? conh.getVeiculo() : null);
   BeanCliente exp = (carregaconh ? conh.getExpedidor(): null);
   BeanCliente rec = (carregaconh ? conh.getRecebedor(): null);
   float cub_metro = conh.getCubagemMetro();
   float cub_base = (carregaconh? conh.getCubagemBase() : 0); %> 
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("builder.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/jQuery/<%=Apoio.noCacheScript("jquery.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("impostos.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/<%=Apoio.noCacheScript("aliquotaIcmsCtrc.js")%>" type="text/javascript"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoesTelaCtrc.js")%>"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("tabelaFrete.js")%>"></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("notaFiscal-util.js")%>"></script>
<script language="JavaScript" src="script/beans/<%=Apoio.noCacheScript("beans/CTRC.js")%>" type="text/javascript"></script>
<script language="JavaScript" src="script/funcoesTelaCadConhecimento.js?v=${random.nextInt()}" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
var homePath= '${homePath}';
var isBloqueaAlteracao = <%=(conh.isQuitado() || conh.isCteBloqueado())%>;
var ufRecebedorAnterior ;
var windowRecebedor;
var ufExpedidorAnterior ;
var windowExpedidor;
var dataAtual = "<%=Apoio.getDataAtual()%>";
var objetoFoco;
var countIdxNotes = 0;
var indexNotes = 0;
var totalCtrcAnaliseCredito = 0;
function check() {
    var isCtrcCancelado = $("cancelado").checked;if (wasNull("especie,serie,nfiscal,dtemissao,idcfop_ctrc,idremetente,iddestinatario,idconsignatario"+($("ck_redespacho").checked? ",idredespacho" : "")+","+"valor_taxa_fixa,valor_itr,valor_peso,valor_frete,valor_despacho,valor_ademe"))return alertMsg("Preencha os campos corretamente!");        
	if ($('aliquota').value < 0){
		return alertMsg(getMensagemAliquota($('uf_origem').value, $('uf_destino').value));
	}if (!validaData($("dtemissao").value)) 
        return alertMsg("Data de emissão inválida!");//se o tipo de taxa for cubagem, e o metro ou a base estiver "0"...
	if ($("tipotaxa").value == "1" && (parseFloat($("cub_base").value) == 0 || parseFloat($("cub_metro").value) == 0))return  alertMsg("Para a opção de frete \"Cubagem\", vc deve obrigatoriamente preencher os campos \"Metro\" e \"Base\"!");
    //se o usuario nao clicou em nenhuma opcao de fretepago(sim ou nao)
    if (!document.getElementById("fretepago_sim").checked && !document.getElementById("fretepago_nao").checked)
       return alertMsg("Você deve selecionar \"CIF\" ou \"FOB\" no campo \"Pago\"");//se o usuario nao selecionou um tipo de taxa
    if ($("tipotaxa").value == "-1")
        return  alertMsg("É preciso selecionar um tipo de taxa.");//se o frete for a vista e se o usuario não informou a filial recebedora
    if ($('filialRecebedora').value == '')
        return  alertMsg("Informe a filial recebedora corretamente.");
    if ( <%=cfg.isObrigaRotaCTRC()%> && parseInt(getObj("id_rota_viagem").value)==0)
        return  alertMsg("O Campo Rota é de preenchimento Obrigatório.");
    if ( <%=cfg.isObrigaColetaCTRC()%> && parseInt(getObj("idcoleta").value)==0)
        return  alertMsg("O Campo Coleta é de preenchimento Obrigatório.");
    if ( <%=cfg.isObrigaMotoristaCTRC()%> && parseInt(getObj("idmotorista").value)==0)
        return  alertMsg("O Campo Motorista é de preenchimento Obrigatório.");
    if ( <%=cfg.isObrigaVeiculoCTRC()%> && parseInt(getObj("idveiculo").value)==0)
        return  alertMsg("O Campo Veículo é de preenchimento Obrigatório.");
    if (getObj("is_obriga_carreta").value =='t' && parseInt(getObj("idcarreta").value)==0)
        return  alertMsg("O Campo Carreta é de preenchimento Obrigatório.");
	if (parseFloat($("total").value) == 0 && $("tipoConhecimento").value != "c")
       return alertMsg("O valor total do CT-e não pode ser zero");//se deu erro nas parcelas 
    if(!parent.frames[1].checkDuplicatas() &&!<%=conh.isCancelado()%> && $("tipoConhecimento").value != "c" && $("tipoConhecimento").value != "t"){return  alertMsg("Verifique os sequintes problemas: -> O valor de uma duplicata não pode ser 0. -> A soma das duplicatas não pode ser diferente do total do CT-e. -> O valor total das apropriações não pode ser diferente do total do CT-e.");}
	//se deu erro nas apropriacoes     
      if ((parent.frames[1].checkApropriacoes()==false && $("tipoConhecimento").value != "c")){return alertMsg("Preencha as Apropriações corretamente!  -> O campo \"Valor\" não pode ser 0. -> A soma das Apropriações não pode ser diferente do total do CT-e.");}
      if (<%=acao.equals("iniciar")%> && <%=cfg.isCartaFreteAutomatica()%> && $('chk_carta_automatica').checked){
            if (($('idmotorista').value=='0' || $('idveiculo').value=='0')){
				return alertMsg("Informe o motorista e/ou veículo corretamente para que a geração do contrato de frete automática funcione."); }if ( <%=cfg.isObrigaAgenteCargaCTRC()%> && parseInt(getObj("idagente_carga").value)==0 && $('tipo').value == 'c')return  alertMsg("O Campo Agente de carga é de preenchimento Obrigatório.");
            if ((parseFloat($('cartaLiquido').value) !=  parseFloat(parseFloat($('cartaValorAdiantamento').value) + parseFloat($('cartaValorAdiantamentoExtra1').value) + parseFloat($('cartaValorAdiantamentoExtra2').value) + parseFloat($('cartaValorSaldo').value) + parseFloat($('cartaValorCC').value)).toFixed(2)) || parseFloat($('cartaLiquido').value) <= 0){
				return alertMsg("Informe o valor do frete carreteiro corretamente."); }//Verificando se o percentual de adiantamento está dentro do permitido no cadastro do motorista.
			if (<%=nivelUserAdiantamento == 0%>){
				var percPermitido = $('perc_adiant').value;
				var totalAdtmo = $('cartaValorAdiantamento').value;
                                if($('cartaValorAdiantamentoExtra1').value != '0.00'){
                                    totalAdtmo += $('cartaValorAdiantamentoExtra1').value
                                }
                                if($('cartaValorAdiantamentoExtra2').value != '0.00'){
                                    totalAdtmo += $('cartaValorAdiantamentoExtra2').value
                                }                
				var xTotalLiquido = $('cartaLiquido').value;
				var percAdtmo = parseFloat(totalAdtmo) * 100 / parseFloat(xTotalLiquido);
				if (parseFloat(percAdtmo) > parseFloat(percPermitido)){
					return alertMsg('Para esse motorista só é permitido ' + percPermitido + '% de adiantamento!');
				}}
			/*if (parseFloat($('cartaValorFrete').value) > parseFloat($('total').value)){
                if (<//%=!cfg.isPermiteContratoMaiorCtrc()%>){ 
                   return alertMsg('O contrato de frete não poderá ser salvo. O valor do contrato de frete é maior que o valor do CT-e!');
                }
				if (!confirm("O valor do frete carreteiro é maior que o total do CT-e, Deseja salvar mesmo assim?")){
                   return alertMsg('Operação cancelada!');
				}}*/
                            ControlarTalonario(<%=cfg.isControlarTalonario()%>);
			if ($('motor_liberacao').value == ''){
					return alertMsg("Informe a liberação do motorista corretamente.");}//Validação das despesas
			for(var dd = 0; dd <= parseInt(countDespesaCarta); dd++){
				if ($('trDespCarta_'+dd) != null){
					if (parseFloat($('vlDespCarta_'+dd).value) <= 0 || $('idFornDespCarta_'+dd).value == '0' || $('idPlanoDespCarta_'+dd).value == '0'){
						return alertMsg("Para gerar a despesa de viagem do contrato de frete é necessário informar o 'Valor', 'Fornecedor' e o 'Plano de Custo'.");
					}
					if ($('DespPago_'+dd).checked && $('chqDespCarta_'+dd).checked){if (<%=cfg.isControlarTalonario()%>){if($('docDespCarta_cb_'+dd).value == ''){
								return alertMsg("Informe o número do cheque corretamente para a despesa de viagem.");
							}}else{if($('docDespCarta_'+dd).value == ''){return alertMsg("Informe o número do cheque corretamente para a despesa de viagem.");}}}}} }
        if (<%=acao.equals("iniciar")%> && <%=cfg.isCartaFreteAutomatica()%> && $('chk_adv_automatica').checked){//Validação dos adiantamentos
			for(var di = 0; di <= parseInt(countADV); di++){
				if ($('trADV_'+di) != null){
					if (parseFloat($('vlADV_'+di).value) <= 0){
						return alertMsg("Informe o valor do adiantamento de viagem corretamente.");
					}
					if (parseFloat($('contaADV_'+di).value) == ''){
						return alertMsg("Informe a conta do adiantamento de viagem corretamente.");
					}
					if ($('chqADV_'+di).checked){
						if (<%=cfg.isControlarTalonario()%>){
							if($('docADV_cb_'+di).value == ''){return alertMsg("Informe o número do cheque corretamente para o adiantamento de viagem.");
							}}else{if($('docADV_'+di).value == ''){return alertMsg("Informe o número do cheque corretamente para o adiantamento de viagem.");}}}}}
			for(var dd = 0; dd <= parseInt(countDespesaADV); dd++){//Validação das despesas
				if ($('trDespADV_'+dd) != null){
					if (parseFloat($('vlDespADV_'+dd).value) <= 0 || $('idFornDespADV_'+dd).value == '0' || $('idPlanoDespADV_'+dd).value == '0'){
						return alertMsg("Para gerar a despesa de viagem do adiantamento é necessário informar o 'Valor', 'Fornecedor' e o 'Plano de Custo'.");}}}
			if(<%=cfg.isImpedeViagemMotorista()%> && $('impedir_viagem_motorista').value == 't'){
				return alertMsg("O motorista informado possui alguma viagem em aberto, finalize a viagem anterior antes de criar uma nova.");
			}}
        if (($('contabelaproduto').value == 't' || $('contabelaproduto').value == 'true') && $('tipoproduto').value == '0' ){
            return alertMsg("Para esse cliente é obrigado informar o tipo de produto/operação."); }
        if (isCalculaPauta() && parseFloat($('valor_pauta_fiscal').value) <= 0){
            return alertMsg("Pauta fiscal para cálculo do ICMS não encontrada, possíveis causas:\n - O KM não foi informado corretamente no CT-e de transporte; \n - A pauta fiscal não foi cadastrada;");}                           
        for (var i = 0; i <= countIdxNotes; i++) {      
            if($("nf_tipoDocumento"+i+"_id0") != null){
           if ($('especie').value == 'CTE' && !isNaN($('serie').value)  && $("nf_tipoDocumento"+i+"_id0").value == "NE" && ( $("nf_chave_nf"+i+"_id0").value == "" || $("nf_chave_nf"+i+"_id0").value == null)) {
                return alertMsg("Para a nota " + $("nf_numero"+i+"_id0").value + " do tipo NFe é obrigado informar a chave de acesso."); }} }       
        for(var i=1; i <= countIdxNotes; i++){
            if($("nf_tipoDocumento"+i+"_id0") != null){
            if(($("serie").value>=0 && $("serie").value<=899) && $("nf_tipoDocumento"+i+"_id0").value == "NE"){
                var chave =  $("nf_chave_nf"+i+"_id0").value;
                if(chave.length<44){return alertMsg("O campo 'Chave de Acesso' da nota " + $("nf_numero"+i+"_id0").value + " deve conter 44 dígitos quando for Nf-e!");} }  }         
        }//se chegou aqui entao esta td ok
    return true;}
function aoCarregar(){//if($("obs_lin1").value == "" || $("obs_lin2").value == "" || $("obs_lin3").value == "" || $("obs_lin4").value == ""){getStIcmsConsig();}
$("perm_altera_icms").value = '<%=alteraIcms%>';//Armazenando o valor da permisão para que possamos usá-la em qualquer js externo.
escondeMostraCancelamento(<%=conh.isCancelado()%>);
escondeCTeCancelar(<%=conh.isCancelado()%>);
   <%-- Adicionando um plano custo padrao --%>
   <%if (acao.equals("iniciar") && plcustopadrao != null)
   {%> //se estiver incluindo um conh. e na configuracao existir uma aproprriacao default, crie uma apropriacao nesse conhecimento...
      if (parent.frameAbaixo.document.getElementById("idplanocusto1") == null){
	      var doc = parent.frameAbaixo.document;
		  doc.getElementById("idplanocusto").value 		= "<%=plcustopadrao.getIdconta()%>";
		  doc.getElementById("plcusto_conta").value 	= "<%=plcustopadrao.getConta()%>";
		  doc.getElementById("plcusto_descricao").value = "<%=plcustopadrao.getDescricao()%>";
          parent.frameAbaixo.aoClicarNoLocaliza();
      } //tryRequestToServer(function(){nextCtrc()});
   <%}%>
   getObj('rem_cnpj').focus();
   getObj('rem_cnpj').select();
   <%  if (!carregaconh){%> 
        $("isCalculaSecCat").checked = true;
   <%}%>     
   redespacho(<%=(red != null ? "true" : "false")%>,false);
   recalcular(true);
   totalCtrcAnaliseCredito = parseFloat($('total').value);
<%  if (carregaconh){%> //atribuindo o tipo de taxa
      $("tipotaxa").value = "<%=conh.getTipoTaxa()%>";
      if("<%=conh.getTipo()%>"=='t'){
           $("subs").style.display ="";
           $("tipoConhecimento").value = "<%=conh.getTipo()%>";      
//           $("tipoConhecimento").disabled = true;
      }else{
           $("tipoConhecimento").value = "<%=conh.getTipo()%>";      
      }     
      $("tipoTransporte").value = "<%=conh.getTipoTransporte()%>";
      $("tipofpag").value = "<%=conh.getTipoFpag()%>";
      $("modalConhecimento").value = "<%=conh.getModalCte()%>";
      $("slTipoCombinado").value = "<%=conh.getTipoUnitarioCombinado()%>";
      $("tipoServico").value = "<%=conh.getTipoServico()%>";
      $("tpDocAnt").value = "<%=conh.getTpDocAnt()%>";   
      tipoDocAnt("<%=conh.getTpDocAnt()%>");
      $("tipoDocRed").value = "<%=conh.getTpDocRedespacho()%>";
      $("red_serie").value = "<%=conh.getSerieRedespacho()%>";
      $("red_subserie").value = "<%=conh.getSubSerieRedespacho()%>";
      $("red_dtemissao").value = "<%=conh.getDtEmissaoRedespacho()%>";
            var chavesAcesso = '<%=conh.getChaveAcessoRedespacho().toString().replace("[", "").replace("]", "")%>';
            var agrupador = "";
            var countChaveAcesso = (chavesAcesso != "" ? 1 : 0);
//            chavesAcesso = chavesAcesso.replace("[", "").replace("]","");
            $("red_chave_acesso").value = chavesAcesso.split(",")[0].replace("\"","").replace("\"","");
                for(var i = countChaveAcesso; i <= chavesAcesso.split(",").length; i++){
                    if(chavesAcesso.split(",")[i] != undefined && chavesAcesso.split(",")[i] != ""){
                      countChaveAcesso++;
                      agrupador = agrupador + chavesAcesso.split(",")[i].trim() + ","; 
                    }
                }
            $("chaveAcessoExtraAll").value = agrupador;    
            $("maxChavesAcesso").value = countChaveAcesso;
            $("lblChavesAcesso").innerHTML = "QTD chaves: "+countChaveAcesso;
      var idDespesa = "<%=conh.getPagamentoComissao().getDespesa().getIdmovimento()%>";
      var idPagamentoComissao = "<%=conh.getPagamentoComissao().getId()%>";
      var tipoComissao = "<%=conh.getPagamentoComissao().getTipoComissao()%>";
      if(idDespesa != "0" && idPagamentoComissao != "0"){
          if(tipoComissao == "r"){
            tipoComissaoR();
          } else if(tipoComissao == "v" && $("localiza_vendedor") != null){
            tipoComissaoV();
        }}
      if("<%=conh.getExpedidor().getIdcliente()%>" !=0){
        if("<%=conh.getExpedidor().getIdcliente()%>" == "<%=conh.getRedespacho().getIdcliente()%>"){
            $("exp").checked = true;
            $("rec").checked = false;}}
      if("<%=conh.getExpedidor().getIdcliente()%>" !=0){
        if("<%=conh.getRecebedor().getIdcliente()%>" == "<%=conh.getRedespacho().getIdcliente()%>"){
            $("rec").checked = true;
            $("exp").checked = false;
        }}    
      alteraTipoTransporte();
      getAliquotasIcmsAjax(<%=conh.getFilial().getIdfilial()%>);
      if(<%=conh.getStatusCte().equals("C") %>){
          $("respseg").disabled = 'true';
      if(<%=nivelAverbacaoManual==4 %>){
            $("averbacao").style.display="";
      }}
      $("stIcms").value = '<%=conh.getStIcms().getId()%>';
<%  }else{%>  
          if ($('especie').value == 'CTE'){$("descricao_historico").value = 'Frete CT-e: ' + $("nfiscal").value;}else{$("descricao_historico").value = 'Frete CTRC: ' + $("nfiscal").value;}
  	  if (<%=cfg.isCartaFreteAutomatica()%>){
		alteraFpag('a');
		alteraFpagExtra1('a');
		alteraFpagExtra2('a');
	  }//atribuindo o cfop padrao
          getAliquotasIcmsAjax(<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>);
          $("modalConhecimento").value = "<%=Apoio.getUsuario(request).getFilial().getModalCTE()%>";
<%  }%>
	pagtoAvista();
    alteraTipoConhecimento();
	isMostraSelo();
	showFields($("tipotaxa").value);
<%		 // adicioonando as notas fiscais
	if (conh.getNotasfiscais() != null)
		 for (int b = 0; b < conh.getNotasfiscais().size(); ++b){
        	NotaFiscal n = (NotaFiscal)conh.getNotasfiscais().get(b);                
%>
            if ('<%= b %>' === '0') { colocarReadOnly('<%= n.isImportadaEdi() %>'); }
            countIdxNotes++;//
            var prefixo = addNote('0','tableNotes0','<%=n.getIdnotafiscal()%>','<%=n.getNumero()%>','<%=n.getSerie()%>','<%=(n.getEmissao() != null? new SimpleDateFormat("dd/MM/yyyy").format(n.getEmissao()) : "")%>',
                        '<%=n.getValor()%>','<%=n.getVl_base_icms()%>','<%=n.getVl_icms()%>','<%=n.getVl_icms_st()%>','<%=n.getVl_icms_frete()%>','<%=n.getPeso()%>','<%=n.getVolume()%>','<%=n.getEmbalagem()%>',
                        '<%=n.getConteudo()%>',<%=n.getIdconhecimento()%>,'<%=n.getPedido()%>',isBloqueaAlteracao,'<%=n.getLargura()%>','<%=n.getAltura()%>','<%=n.getComprimento()%>','<%=n.getMetroCubico()%>',
                        '<%=n.getMarcaVeiculo().getIdmarca()%>','<%=n.getMarcaVeiculo().getDescricao()%>','<%=n.getModeloVeiculo()%>','<%=n.getAnoVeiculo()%>','<%=n.getCorVeiculo()%>','<%=n.getChassiVeiculo()%>',
                        '0','false','<%=n.getCfop().getIdcfop()%>','<%=n.getCfop().getCfop()%>','<%=n.getChaveNFe()%>','<%=n.isAgendado()%>','<%=n.getDataAgenda() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getDataAgenda()) : ""%>',
                        '<%=n.getHoraAgenda()%>','<%=n.getObservacaoAgenda()%>','<%=cfg.isBaixaEntregaNota()%>','<%=n.getPrevisaoEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(n.getPrevisaoEm()) : ""%>',
                        '<%=n.getPrevisaoAs()%>','<%=n.getDestinatario().getIdcliente()%>','<%=n.getDestinatario().getRazaosocial()%>','<%=n.isImportadaEdi()%>','<%=n.getCubagens().length%>',
                        '<%=n.getMinutaId()%>','<%=n.getTipoDocumento()%>'
                        ,'<%=n.getPlacaVeiculo()%>','<%=n.isVeiculoNovo()%>','<%=n.getCorFabVeiculo()%>','<%=n.getMarcaModeloVeiculo()%>'
                        , '<%=conh.getRemetente().isTravaCamposImportacao()%>'
                        );
                    <%
                    for (int c = 0; c < n.getCubagens().length; ++c) {
                          Cubagem cub = n.getCubagens()[c];
                        %>
                            addUpdateNotaFiscal3('trNote'+prefixo,'<%=n.getIdnotafiscal()%>','<%=cub.getId()%>',prefixo,'<%=cub.getMetroCubico()%>','<%=cub.getAltura()%>','<%=cub.getLargura()%>','<%=cub.getComprimento()%>','<%=cub.getVolume()%>','<%=cub.getEtiqueta()%>', <%=c%>);
                        <%
                  }//for
                %>//atualizando a soma das notas
		    updateSum(false);
            $('cub_metro').value = <%=conh.getCubagemMetro()%>;
            <%}%>//for
                <%if(conh.getMinutas() != null){
                    for(BeanConhecimento bc : conh.getMinutas()){
                %>addCTRC('<%= bc.getId()%>','<%= bc.getNumero()%>','<%=bc.getEmissaoEmS()%>','<%=bc.getTotalReceita()%>','<%=bc.getDestinatario().getRazaosocial()%>','<%=bc.getDestinatario().getBairro()%>'
                          ,'<%= bc.getDestinatario().getCidade().getDescricaoCidade()%>','<%= bc.getNota().getNumero()%>',true,false,false);
            <%}}%> calculaPesoTaxadoCtrc();escondeCalculaSecCat($("calculaSecCat").value);
<% if (!alteraPreco){%>
	   disableFields("incluirIcms,incluirFederais,valor_taxa_fixa,cobrarTde,valor_tde,valor_itr,valor_peso,valor_frete,valor_despacho,valor_ademe,valor_outros,valor_sec_cat,valor_gris,valor_pedagio,valor_desconto", true, "isCalculaSecCat, calculaSecCat");
<%}%>
<% if (!alteraIcms){%>
	   disableFields("aliquota,base_calculo,vlicmsbarreira,stIcms", true);
<%}%>
<% if (!alteraTipoFrete){%>
        disableFields("tipotaxa", true);
<%}%>
	applyFormatter(document, $("dtemissao"));//bloquando o botão de salvar quando o CTE for um substituto
        if($("tipoConhecimento").value == "t"){
           // parent.frames[1].salvar.style.display = "none";
            parent.frames[1].btcriar_duplicata.disabled = true;
            parent.frames[1].nova_aprop.disabled = true;
        }
var permissao_alteraPreco = <%=alteraPreco%>;
modalAlterarTipoTranporte();
<% if(conh.isQuitado() || conh.isIsConfirmadoOutraAplicacao() || conh.isCteBloqueado() ){alteraTipoFrete = false; }%>
bloquearTipoTaxa(<%=alteraTipoFrete%>);if ($("con_tabela_remetente").value != "n"){$("utilizatipofretetabelaconsig").value = ($("utilizatipofretetabelarem").value);}
var mostrarLabelFiscal = "";
var labelFederais = "";
if (<%=cfg.isEmbutirPis()%>){mostrarLabelFiscal += "/PIS";}if (<%=cfg.isEmbutirCofins()%>){mostrarLabelFiscal += "/COFINS";}if (<%=cfg.isEmbutirIR()%>){mostrarLabelFiscal += "/IR";}
if (<%=cfg.isEmbutirCssl()%>){mostrarLabelFiscal += "/CSSL";}if (<%=cfg.isEmbutirInss()%>){mostrarLabelFiscal += "/INSS";}var label = mostrarLabelFiscal.lastIndexOf("/");if (label > -1) { labelFederais = mostrarLabelFiscal.replace("/","").replace(" ","/").replace(" ","/").replace(" ","/");}
$("lbPisCofins").innerHTML = labelFederais; $("lbpis").innerHTML = labelFederais;
$("ufInicio").value = ("<%=conh.getUfInicioPercCompl()%>" == null ? "" : "<%=conh.getUfInicioPercCompl()%>");
$("ufFim").value = ("<%=conh.getUfFimPercCompl()%>" == null ? "" : "<%=conh.getUfFimPercCompl()%>");
$("modalConhecimentoAverbacao").value = ("<%=conh.getModalPercentualComplementar()%>" == null ? 0 : "<%=conh.getModalPercentualComplementar()%>");
}//aoCaregar()
  function salva(acao, imprimir, incluirOutro){
    if(($("is_ativar_valor").value == "t" || $("is_ativar_valor").value == "true") && $("chk_carta_automatica").checked == true && $("vlmercadoria").value > $("valor_max").value){
            alert("Atenção : o valor do(s) total(is) da(s) NF(s) é maior que o valor limite da filial de origem.");
            return null;
    }
    if ($("filialRecebedora").value == "0") {return alert("Selecione uma filial Recebedora!");}
    var acaoBotao = (imprimir?"true":(incluirOutro?"outro":"false"));//obtendo notas devidamente concatenadas
    var notes = getNotes("0");
    habilitar($("stIcms"));
    habilitaSalvar(false);
    if (notes == null){
        habilitaSalvar(true);
    	return null;
	}
    if (<%= cfg.isObrigaNotaFiscalCtrc()%> && notes == ""){
        alert("Informe no mínimo uma nota fiscal.");
        habilitaSalvar(true);
        return null;
    } /*Bloco de instrucoes da funcao*/
    if (check()) {// Tipo de Fpag...
	    if (($('contipofpag').value != $('tipofpag').value) && !confirm("Modalidade do frete diferente do cadastro do cliente. Deseja continuar ?")){
           habilitaSalvar(true);
           return null;
    	}
        habilitaSalvar(false); //carrega o array de duplicatas que o usuário criou
		var arraydups = parent.frames[1].getArrayDuplicatas();
                arraydups = (arraydups == null ? "" : arraydups);
        if (!$("cancelado").checked && arraydups == '' && $("tipoConhecimento").value != "t"){
            alert('Informe no mínimo uma duplicata.');
            habilitaSalvar(true);
            return null;
        } //carrega o array de apropriacoes que o usuário criou
        var arrayaprops = parent.frames[1].getArrayApropriacoes();
        arrayaprops = (arrayaprops == null ? "" : arrayaprops);
        if (!$("cancelado").checked && arrayaprops == '' && $("tipoConhecimento").value != "c" && $("tipoConhecimento").value != "t"){
            alert('Informe no mínimo uma apropriação.');
            habilitaSalvar(true);
            return null;
        }
//      Comentando essa validação por que esta validando agora pela trigger validacao_sales.        if (!$("cancelado").checked && ($('con_analise_credito').value == 't' || $('con_analise_credito').value == 'true')){//            var alterouCliente = ($('idconsignatario').value != < %=(carregaconh ? con.getIdcliente() : "0")%>);//            var msg = getAnaliseCredito(< %=carregaconh%>,$('con_is_bloqueado').value,$('con_valor_credito').value,$('total').value,(< %=carregaconh%>?totalCtrcAnaliseCredito:0),alterouCliente);//            if (msg != ''){//                alert(msg);//                habilitaSalvar(true);//                return null;//            }//        }
        if ($("cancelado").checked){
            if (parent.frameAbaixo.nao_recarregar){
                alert('Existe 1 ou mais duplicatas quitadas ou com fatura gerada. Antes de cancelar o CT-e deverá excluir a fatura.');
                habilitaSalvar(true);
                return null;
            }
            <% if(nvCancCT == 0){ %>
                if ($("lbManifesto").innerHTML.trim() != ''){
                    alert('Esse CTRC está vinculado ao manifesto ' + $('lbManifesto').innerHTML + '! O CT-e devera ser desvinculado do manifesto para ser cancelado.');
                    habilitaSalvar(true);
                    return null;
                }
            <%}%>
            if ($("motivoCancelamento").value.trim() == ''){
                alert('Informe o motivo do cancelamento.');
                habilitaSalvar(true);
                return null;
            }}
        var tipoConhecimento = $("tipoConhecimento").value;       
            if($("id_dev_reen").value=='0' ){  //&& $("id_ctrcs_sub").value=='0' && $("id_ctrcs_anulado").value=='0'
                if(tipoConhecimento=='c' ){
                    alert("É obrigatória a escolha de um CTRC para ser Complementado!"); return null;
                }else if(tipoConhecimento=='s' && $("id_ctrcs_sub").value=='0'){
                    alert("É obrigatória a escolha de um CTRC para ser Substituído!"); return null;
                }else if(tipoConhecimento=='a' && acao == "incluir"){
                     alert("É obrigatória a escolha de um CTRC para ser Anulado!");return null;
                }}
        if($("ck_redespacho").checked == true){
            if($("exp").checked == false  && $("rec").checked == false){
                alert("É obrigatória a escolha de um tipo de redespachante!");
                habilitaSalvar(true);
                return null;
            }
            if($("tpDocAnt").value=="p"){
            if($("red_serie").value==""){
                alert("A série do documento de redespacho deverá ser preenchida!");
                habilitaSalvar(true);
                return null;
            }
            if($("red_dtemissao").value==""){
                alert("A emissão do documento do redespacho deve ser preenchida!");
                habilitaSalvar(true);
                return null;
            }
        }else{
            if(($("red_chave_acesso").value=="") && (($("tipoServico").value == "r" || $("tipoServico").value == "i") && $("exp").checked)){
                alert("Chave de acesso do Redespacho não pode ser nula!");
                habilitaSalvar(true);
                return false;}}}
        if ((<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()== 'H' %> || <%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()== 'P' %>) && <%=xFilialUsuario%> == $('idfilial').value && (!isNaN($("serie").value) && parseInt($('serie').value, 10) >= 0 && parseInt($('serie').value, 10) <= 899)){
            if($('dtprevisao').value == ''){
                alert('Atenção: A data de previsão de entrega é um campo obrigatório para o lançamento do CT-e.');
                habilitaSalvar(true);
                return null;}
            if($('modalConhecimento').value == 'l' && $('idveiculo').value == 0){
                alert('Atenção: Para o modal LOTAÇÂO, o veículo é um campo obrigatório para o lançamento do CT-e.');
                habilitaSalvar(true);
                return null;}
            if(notes == ""){
                alert('Atenção: É obrigatório informar no mínimo 1 nota fiscal para o lançamento do CT-e.');
                habilitaSalvar(true);
                return null;}}
        if(!isNaN($("serie").value)){
            for(var qtdNotas = 1; qtdNotas <= countIdxNotes; qtdNotas++){
                if($("nf_tipoDocumento"+qtdNotas+"_id0") != null){
                    if($("nf_tipoDocumento"+qtdNotas+"_id0").value == 'NF'){
                        if($("nf_cfopId"+qtdNotas+"_id0") != null){
                            if($("nf_cfopId"+qtdNotas+"_id0").value == 0){
                                alert("O 'CFOP' da nota não pode ficar em branco!");                    
                                habilitaSalvar(true);
                                return null;
                            }}}}}}
        if (acao == "atualizar") {acao += "&id=<%=( carregaconh ? conh.getId() : 0)%>";acao += "&dups_baixadas="+parent.frameAbaixo.document.getElementById("dups_baixadas").value;}
        var driver = '';
        if (parent.frameAbaixo.document.getElementById("driverImpressora") != null){
            driver = parent.frameAbaixo.document.getElementById("driverImpressora").value;
        }        
        if ($("repr_entrega_tipo_taxa").disabled == true) {
            $("repr_entrega_tipo_taxa").disabled = false;
        } 
        if ($("repr_coleta_tipo_taxa").disabled == true) {
            $("repr_coleta_tipo_taxa").disabled = false;
        }
        var isRetencaoImpostoOpeCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "t" ? true :false);
        if ($("chk_carta_automatica").checked && isRetencaoImpostoOpeCFe) {
            let totSaldo = parseFloat($("cartaValorSaldo").value);
            let ir = parseFloat($("valorIRInteg").value);
            let inss = parseFloat($("valorINSSInteg").value);
            let sest = parseFloat($("valorSESTInteg").value);
            if (totSaldo < (ir + inss + sest)) {
                alert("ATENÇÃO: Não é possivel salvar o contrato pois a provisão dos impostos ("
                            +colocarVirgula((ir + inss + sest))+") é maior que o saldo ("+colocarVirgula(totSaldo)+").");
                    return null;
            }
        }
        disableFields("redespacho_valor,redespacho_valor_icms,incluirIcms,incluirFederais,cobrarTde,redespacho_valor,valor_taxa_fixa,valor_itr,valor_despacho,valor_ademe,valor_peso,valor_frete,valor_outros,valor_sec_cat,valor_gris,valor_pedagio,valor_desconto,valor_tde,aliquota,base_calculo,vlicmsbarreira,stIcms,tipoveiculo,tipotaxa,tipoproduto,modalConhecimento,tipoConhecimento,tipoServico,tipofpag,respseg,chk_reter_impostos", false);
        var vlcampos = "acao="+acao + "&" + arraydups + arrayaprops +
                      "&filialRecebedora="+$('filialRecebedora').value+"&tipotaxa="+$("tipotaxa").value+"&tipoproduto="+$("tipoproduto").value+"&tipoveiculo="+$("tipoveiculo").value+"&tipoTransporte="+$("tipoTransporte").value+"&tipo_container="+$("tipo_container").value+"&fretepago="+$("fretepago_sim").checked+"&motivoCancelamento="+$("motivoCancelamento").value+"&cancelado="+$("cancelado").checked+
                      "&driver="+driver+"&is_carta_automatica="+$('chk_carta_automatica').checked+"&is_adv_automatica="+$('chk_adv_automatica').checked+"&imprimir="+acaoBotao + "&countNotes="+countIdxNotes+"&countADV="+countADV+"&countMin="+countCTRC+"&countDespesaADV="+countDespesaADV+"&countDespesaCarta="+countDespesaCarta+"&tipoServico="+$("tipoServico").value+"&tipoDocRed="+$("tipoDocRed").value+
                      "&red_serie="+$("red_serie").value+"&red_subserie="+$("red_subserie").value+"&red_dtemissao="+$("red_dtemissao").value+"&red_chave_acesso="+$("red_chave_acesso").value+"&protocoloAverbacao="+$("protocoloAverbacao").value+"&ckprotocoloAverbacao="+$("ckprotocoloAverbacao").checked+"&tpDocAnt="+$("tpDocAnt").value+"&ckRecebedorRetira="+$("ckRecebedorRetira").checked+"&chaveSubTomador="+$("chaveSubTomador").value+"&respseg="+$("respseg").value+"&obs_desc="+encodeURI(replaceAll(getObservacao(),"\"",""))+"&calculaSecCat="+$("calculaSecCat").value+"&isCalculaSecCat="+$("isCalculaSecCat").checked
                +"&ufInicio="+$("ufInicio").value + "&ufFim="+$("ufFim").value + "&modalConhecimentoAverbacao="+$("modalConhecimentoAverbacao").value+"&isRetencaoImpostoOpeCFe="+isRetencaoImpostoOpeCFe;
                $('form1').action = './ConhecimentoControlador?'+vlcampos;
                window.open('about:blank', 'pop', 'width=210, height=100');
                $("form1").submit();                
	}//if (check()...     
  }
  var windowRemetente = null;  var ufRemetenteAnterior = '';
  function localizaOrcamento(idOrcamento){
        if($("orcamento_id").value != "0"){
            return false;
        }
      <%if(acao.equals("iniciar")){%>
              $("orcamento_id").value = "0";
      function e(transport){
          espereEnviar("",false);
          var possuiOrcamento = transport.responseText;
          if(possuiOrcamento.trim() == "true" && confirm("Existe(m) orçamento(s) pendente(s) para o cliente " + $("con_rzs").value + " \n\rDeseja visualiza-lo?")){
                 window.open('./pops/localiza_orcamento.jsp?idconsignatario='+$("idconsignatario").value+'&idfilial='+$("idfilial").value+'&con_rzs='+$("con_rzs").value+'&iddestinatario='+$("iddestinatario").value+'&dest_rzs='+$("dest_rzs").value+'&idcidadedestino='+$("idcidadedestino").value+"&idColeta="+$("idcoleta").value+"&numeroColeta="+$("numcoleta").innerHTML+"&orcamento_id="+(idOrcamento == undefined ? "0" : idOrcamento),'LocalizaOrc','top=80,left=50,height=400,width=900,resizable=yes,status=1,scrollbars=1');
          }
      }//funcao e()
     espereEnviar("",true);tryRequestToServer(function(){new Ajax.Request("ConhecimentoControlador?acao=consignatarioPossuiOrcamento&idconsignatario="+$("idconsignatario").value+"&idfilial="+$("idfilial").value+'&iddestinatario='+$("iddestinatario").value+'&idcidadedestino='+$("idcidadedestino").value+"&idOrcamento="+$("orcamento_id").value+"&isCancelados="+(idOrcamento != undefined && idOrcamento != null && idOrcamento != '0'),{method:'post', onSuccess: e, onError: e});});
     <%}%>
  }
var windowCidade = null;
  function recalcular(carregando) {
      try {
          var valor_taxa_fixa    = parseFloat($("valor_taxa_fixa").value);
            var valor_itr    = parseFloat($("valor_itr").value);
            if (carregando == false){
                if ($('tipotaxa').value == '3' && parseFloat($('valor_peso_unitario').value) > 0){
                    var tpComb = $('slTipoCombinado').value;
                    if (tpComb == 'k'){
                        $('valor_peso').value = formatoMoeda(parseFloat($('valor_peso_unitario').value) * parseFloat($('peso_taxado').value));
                    }else if (tpComb == 't'){
                        $('valor_peso').value = formatoMoeda(parseFloat($('valor_peso_unitario').value) * (parseFloat($('peso_taxado').value)/1000));
                    }else if (tpComb == 'v'){
                        $('valor_peso').value = formatoMoeda(parseFloat($('valor_peso_unitario').value) * parseFloat($('volume').value));
                    }}}
            var fretepeso  = parseFloat($("valor_peso").value);
            var fretevalor = parseFloat($("valor_frete").value);
            var adicionais = parseFloat($("valor_despacho").value);
            var aceme      = parseFloat($("valor_ademe").value);
            var outros     = parseFloat($("valor_outros").value);
            var aliqfrete  = parseFloat($("aliquota").value);
            var valor_gris     = parseFloat($("valor_gris").value);
            var valor_pedagio  = parseFloat($("valor_pedagio").value);
            var valor_desconto = parseFloat($("valor_desconto").value);
            var valor_sec_cat = 0;
            var aliqTabela = $('aliquota').value;
                if ($("isCalculaSecCat").checked) {
                   if (tarifas != undefined){
                        if (tarifas.calcula_sec_cat != undefined){
                            $("calculaSecCat").value = tarifas.calcula_sec_cat;
                            escondeCalculaSecCat(tarifas.calcula_sec_cat);
                            if ($('fi_uf').value == 'MG' && $('con_uf').value == 'MG' && $('idconsignatario').value == $('idremetente').value && ($('rem_st_mg').value == 'true' || $('rem_st_mg').value == 't')){ aliqTabela = 14.4;
                            $("valor_sec_cat").value = getValorSecCat(tarifas.valor_sec_cat, tarifas.formula_sec_cat, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,$("cub_base").value,$("cub_metro").value,$('qtde_entregas').value,$('tipoTransporte').value, tarifas.peso_limite_sec_cat, tarifas.valor_excedente_sec_cat, tarifas.tipo_inclusao_icms, aliqTabela,$("tipo_arredondamento_peso_con").value);}
                        }} valor_sec_cat = parseFloat($('valor_sec_cat').value);
                }
            var total = (valor_taxa_fixa + valor_itr + fretepeso + fretevalor + adicionais + aceme + outros + valor_gris + valor_pedagio + valor_sec_cat) - valor_desconto;
            var basecalculo = $("base_calculo").value;//calculando a diferença do valor de icms pelo total
            var stIcms = ("<%=(conh != null ? conh.getStIcms().getId() : 555)%>");
            stIcms = (stIcms == "555" ? $("st_icms").value : stIcms);
            if (adicionouIcms() && carregando){
		if ($('fi_uf').value == 'MG' && $('con_uf').value == 'MG' && $('idconsignatario').value == $('idremetente').value && ($('rem_st_mg').value == 'true' || $('rem_st_mg').value == 't')){
                    total += parseFloat((basecalculo * aliqfrete / 100) * 80 / 100);
		}else if ($('fi_uf').value == 'AM' && $('con_uf').value == 'AM' && $('idconsignatario').value == $('idremetente').value && $('con_tipo_cfop').value == 'i' && (parseFloat($("st_credito_presumido").value)==0) && ($('stIcms').value == "9")){
                    total += parseFloat(roundABNT(((basecalculo * aliqfrete / 100) * 20 / 100), 2));
                }else if(parseFloat($("reducao_base_icms").value)>0 && stIcms == "3" && ($("is_in_gsf_598_03_go").value == "true" || $("is_in_gsf_598_03_go").value == "t")){
                    var indiceIcms = parseFloat((100 - aliqfrete) / 100);
                    total = (parseFloat(total) / indiceIcms);
		}else{
                    total += parseFloat(basecalculo * aliqfrete / 100);
		}}
            if ($('incluirFederais').checked && carregando){
                total = total + parseFloat($('pisCofins').value);                
            }  //o metodo isNaN() retorna se o valor NAO eh um numero. (Not a Number)
            if (!isNaN(total)){
                $("total").value = roundABNT(total,2);
                var ts = $("total").value;
                $("total").value = formatoMoeda(ts);//passando a flag que nao recalcula
                if(verificaFreteMinimo()){
                    return null;
                }
                var resultado = $("total").value;
                if ($('cobrarTde').checked){
                    if (tarifas != undefined){
                        if (tarifas.formula_tde != undefined && tarifas.formula_tde != ''){
                            $('valor_tde').value = getTDE(tarifas.formula_tde, $('tipotaxa').value, $('peso').value, $('vlmercadoria').value, $('volume').value, $('qtdPallets').value, $('distancia_km').value, $('tipoveiculo').value,tarifas.is_considerar_maior_peso,$("cub_base").value,$("cub_metro").value,$('qtde_entregas').value,$('tipoTransporte').value, resultado, fretepeso, fretevalor,$("tipo_arredondamento_peso_con").value,tarifas.tipo_inclusao_icms, $('aliquota').value);
                        }else if (tarifas.tipo_tde == 'v'){
                                $('valor_tde').value = formatoMoeda((tarifas.valor_dificuldade_entrega == "0.00" ? $('valor_tde_orcamento').value : tarifas.valor_dificuldade_entrega));
                            if (tarifas.tipo_inclusao_icms == 'i' && $('aliquota').value != 0) {
                                $('valor_tde').value = formatoMoeda(parseFloat($('valor_tde').value) / (1 - parseFloat($("aliquota").value)/100));
                            }
                        }else if (tarifas.tipo_tde == 'p'){
                            $('valor_tde').value = formatoMoeda((parseFloat(resultado) * (tarifas.valor_dificuldade_entrega == "0.00" ? $('valor_tde_orcamento').value : tarifas.valor_dificuldade_entrega) / 100));
                            if (tarifas.tipo_inclusao_icms == 'i' && $('aliquota').value != 0) {
                                $('valor_tde').value = formatoMoeda(parseFloat($('valor_tde').value) / (1 - parseFloat($("aliquota").value)/100));
                            }
                        }}
                    resultado = parseFloat(resultado) + parseFloat($('valor_tde').value);
                }else{
                    $('valor_tde').value = "0.00";
                }
                $("total").value = formatoMoeda(resultado);
                if (!carregando){
                    if (parseFloat(resultado) > 0){
                        calculaBaseIcms();
                    }else{
                            if ($("tipoConhecimento").value != "c") {$("base_calculo").value = "0.00";}
                        }
                }
                basecalculo = $("base_calculo").value;//calculando o valor do icms
		var txICMS = parseFloat((basecalculo * aliqfrete)/100);
                //		txICMS = txICMS.toFixed(3);
                $("icms").value = roundABNT(txICMS, 2);//atualizando a parcelas(somente se existir uma)
                var icms = txICMS;//apenas troquei o valor do icms que estava formatado para abnt, isso influentcia no valor por conta das casas decimais, pegando o valor bruto da taxa - historia 3339
                var doc = parent.frameAbaixo.document;if (doc.getElementById("vlr2") == null && doc.getElementById("vlr1") != null)//apenas com o codigo 60
                var utilizarNormativaGSF598GO = ($("is_in_gsf_598_03_go").value == "true" || $("is_in_gsf_598_03_go").value == "t" ? true: false);
                var totParcelas = 0;
                if (utilizarNormativaGSF598GO && $("stIcms").value == "3" && $("incluirIcms").checked && parseFloat($('reducao_base_icms').value) > 0) {
                    totParcelas = $('totalParcelas').value;
                }else if(parseFloat($("st_credito_presumido").value)>0 && $('stIcms').value == "9"){
                    var percentual = parseFloat($("st_credito_presumido").value)/100;
                    icms = (icms*percentual);
                    totParcelas = parseFloat($("total").value);
                }else {
                    totParcelas = $("total").value;
                    $('totalParcelas').value = "";
                }
                var qtdParcelasCte = parseFloat(doc.getElementById("qtd_parcela").value); var acumulado = 0;
                if(!carregando && qtdParcelasCte != null && qtdParcelasCte != '' && qtdParcelasCte > 0){
                    var valorRatear = ($("stIcms").value != "9" ? totParcelas : parseFloat(totParcelas) - icms);
                    var totalizador = 0;
                    for (var i = 1; i <= qtdParcelasCte; i++) {
                           totalizador += parseFloat(doc.getElementById("vlr"+i).value);
                    }
                    if (totalizador != valorRatear) {
                        for (var i = 1; i <= qtdParcelasCte; i++) {
                            if(i < qtdParcelasCte){
                                doc.getElementById("vlr"+i).value = formatoMoeda(roundABNT(valorRatear/qtdParcelasCte));
                                acumulado += roundABNT(valorRatear/qtdParcelasCte);
                            }else{
                                doc.getElementById("vlr"+i).value  = formatoMoeda(roundABNT(valorRatear - acumulado));
                            }
                        }
                    }
                }
                //atualizando a apropriacao(somente se existir uma)
                if (doc.getElementById("aprop_vlr2") == null && doc.getElementById("aprop_vlr1") != null)parent.frameAbaixo.document.getElementById("aprop_vlr1").value  = $("total").value;
                //recalculado os valores do redespachante
                if (!carregando){calculaVlRedespachante();}if (<%=acao.equals("iniciar")%> && <%=cfg.isCartaFreteAutomatica()%>){calcularFreteCarreteiro();}
            }
    } catch (e) { 
        console.trace();
        console.log(e);
        console.log(e.stack);
        alert(e);
    } 
  }//recalcular
  function calculaBaseIcms(){
                        $('totalParcelas').value = "";
			var aliquota = parseFloat($("aliquota").value);
			var baseCalculo = parseFloat($("base_calculo").value);
			var totalAntesICMS = parseFloat($("total").value);
			baseCalculo = parseFloat($("total").value);
			if ($('fi_deduzir_pedagio').value == 'true'){
				baseCalculo = parseFloat($("total").value) - parseFloat($("valor_pedagio").value);
			}//Verificando se precisará reduzir a base de calculo
			var reducaoBase = parseFloat($('reducao_base_icms').value);
                        var stIcms = parseInt($("stIcms").value, 10);
                        var utilizarNormativaGSF598GO = ($("is_in_gsf_598_03_go").value == "true" || $("is_in_gsf_598_03_go").value == "t" ? true: false);
			if (parseFloat(reducaoBase) > 0 && stIcms == 3){//Caso o st seja 20 (3 é o id)
			    if (adicionouIcms() && (aliquota != 0)){
                                    if (utilizarNormativaGSF598GO) {
                                        var indiceIcms  = ((100 - aliquota) / 100);
                                        var aliquotaReduzida = aliquota * reducaoBase / 100;
                                        var indiceReduzido = ((100 - aliquotaReduzida) / 100);
                                        var totalFrete = parseFloat($('total').value);
                                        var totalPrestacao = (totalFrete / indiceIcms * indiceReduzido);
                                        var totalPrestacao2 = (totalFrete / indiceIcms);
                                        $('total').value = formatoMoeda(totalPrestacao2);
                                        $('totalParcelas').value = formatoMoeda(totalPrestacao);
                                        baseCalculo = totalPrestacao2 * reducaoBase / 100;
                                    } else {
                                        var indice = parseFloat((100 - (aliquota - (aliquota * parseFloat(reducaoBase) / 100)))/100);
                                        //var indice = parseFloat((100 - aliquota)/100);
                                        var diferencaIcms = (baseCalculo / indice)-baseCalculo;
                                        //diferencaIcms = arredondar(diferencaIcms,3);
                                        $('total').value = formatoMoeda(parseFloat($('total').value) + roundABNT(diferencaIcms,2));
					baseCalculo = (parseFloat(baseCalculo) + parseFloat(roundABNT(diferencaIcms,2)));
                                        baseCalculo = parseFloat(baseCalculo) - (parseFloat(baseCalculo) * parseFloat(reducaoBase) / 100);
                                    }
                                }else if ((aliquota != 0)){
                                    baseCalculo = parseFloat(baseCalculo) - roundABNT(parseFloat(baseCalculo) * parseFloat(reducaoBase) / 100);   
				}
			}else{//calculando a diferença do valor de icms pelo total
                                var PautaTotalFrete = 0;
				var federais = parseFloat(<%=cfg.getCalcularEmbutirImpostosFederais()%>);
                                var mostrarLabelFiscal = "";
                                    if (<%=cfg.isEmbutirPis()%>) {mostrarLabelFiscal += "/PIS";}
                                    if (<%=cfg.isEmbutirCofins()%>) {mostrarLabelFiscal += "/COFINS";}
                                    if (<%=cfg.isEmbutirIR()%>) {mostrarLabelFiscal += "/IR";}
                                    if (<%=cfg.isEmbutirCssl()%>) {mostrarLabelFiscal += "/CSSL";}
                                    if (<%=cfg.isEmbutirInss()%>) {mostrarLabelFiscal += "/INSS";}
                                    var label = mostrarLabelFiscal.lastIndexOf("/");
                                    if (label > -1) {
                                        var labelFederais = mostrarLabelFiscal.replace("/","").replace(" ","/").replace(" ","/").replace(" ","/");
                                    }
				$("lbpis").innerHTML = labelFederais;
				$("pisCofins").style.display = "";
				if (adicionouIcms() && $("incluirFederais").checked && (aliquota != 0)){
                                        PautaTotalFrete = baseCalculo;var aliquotaICMS = aliquota;var aliquotaPISCOFINS = aliquota;aliquotaPISCOFINS += parseFloat(formatoMoeda(federais)); 
					var indice = parseFloat((100 - aliquotaPISCOFINS)/100);
					var diferencaIcms = parseFloat(formatoMoeda((baseCalculo / indice) - baseCalculo)) ;
					$('total').value = formatoMoeda(parseFloat($('total').value) + diferencaIcms);
					baseCalculo +=  diferencaIcms;
					var valorIcms = ((baseCalculo * aliquotaICMS)/100);//valorIcms = valorIcms.toFixed(3);
					valorIcms = roundABNT(valorIcms,2);
					$("pisCofins").value = formatoMoeda(parseFloat(diferencaIcms) - parseFloat(valorIcms));
				}else if (adicionouIcms() && (aliquota != 0)){
					var indice = parseFloat((100 - aliquota)/100);//Apenas para o estado de MG
					if ($('uf_destino').value != 'MG' && $('fi_uf').value == 'MG' && $('con_uf').value == 'MG' && $('idconsignatario').value == $('idremetente').value
					    && ($('rem_st_mg').value == 'true' || $('rem_st_mg').value == 't')){
						indice = 0.856;
					}
					var diferencaIcms = parseFloat((baseCalculo - (baseCalculo / indice))*-1);
                                        diferencaIcms = roundABNT(diferencaIcms, 2); //alterei para toFixed(2) porque estava dando erro na velox conforme e-mail de André em 20-03-2012
					if ($('fi_uf').value == 'AM' && $('con_uf').value == 'AM' && $('idconsignatario').value == $('idremetente').value && $('con_tipo_cfop').value == 'i' && (parseFloat($("st_credito_presumido").value)==0) && ($('stIcms').value == "9")){
                                            var credFiscal = roundABNT((diferencaIcms * 20 / 100), 2);
						$('total').value = formatoMoeda(parseFloat($('total').value) + parseFloat(credFiscal));
					}else{//Antes estava do jeito que está abaixo alterei por causa do erro que aconteceu na REAL. Exemplo está no e-mail de andre em 01-03-2012 as 15:17
						//$('total').value = formatoMoeda(parseFloat($('total').value) + parseFloat(arredondar(diferencaIcms,2)));
						$('total').value = formatoMoeda(parseFloat($('total').value) + parseFloat(diferencaIcms));
					}
					baseCalculo = parseFloat(baseCalculo) + parseFloat(diferencaIcms);
					$("pisCofins").value = "0.00";
					$("lbpis").innerHTML = "";
					$("pisCofins").style.display = "none";
				}else if ($("incluirFederais").checked){
					var indice = parseFloat((100 - federais)/100);
					var diferencaFed = roundABNT(parseFloat((baseCalculo - (baseCalculo / indice))*-1), 2);
					$('total').value = formatoMoeda(parseFloat($('total').value) + parseFloat(diferencaFed));
					baseCalculo = parseFloat(baseCalculo) + parseFloat(diferencaFed);
					$("pisCofins").value = roundABNT(formatoMoeda((parseFloat($("total").value) - parseFloat($('fi_deduzir_pedagio').value == 'true' ? parseFloat($("valor_pedagio").value) : 0)) * parseFloat(federais) / 100), 2);
				}else{
					$("pisCofins").value = "0.00";
					$("lbpis").innerHTML = "";
					$("pisCofins").style.display = "none";
				}//Verificando se precisará utilizar a pauta fiscal
				var isUtilizaPautaFiscal = false;
				var xTON = 0;
				var xVLTON = 0;
				var xVLTONPAUTA = 0;
				if (isCalculaPauta()){
					var xPeso = parseFloat($('peso').value);
					var xPesoCubado = parseFloat($('cub_metro').value) * parseFloat(300); //Segundo a Lei a base sempre deverá ser 300
					if (parseFloat(xPeso) >= parseFloat(xPesoCubado)){
						xTON = parseFloat(xPeso) / 1000;
					}else{
						xTON = parseFloat(xPesoCubado) / 1000;
					}
					xVLTON = parseFloat(baseCalculo) / parseFloat(xTON);
					xVLTONPAUTA = parseFloat($('valor_pauta_fiscal').value);
					if (xVLTON < xVLTONPAUTA){
						isUtilizaPautaFiscal = true;
					}
					if (isUtilizaPautaFiscal){
						var xVLTONsemICMS = formatoMoeda(parseFloat(totalAntesICMS) / parseFloat(xTON));
						var xVLTONcomICMS = formatoMoeda(parseFloat(xVLTONsemICMS) + (parseFloat(xVLTONPAUTA) * parseFloat(aliquota) / 100));
						baseCalculo = roundABNT(parseFloat(xVLTONPAUTA) * parseFloat(xTON),2);
						if (adicionouIcms() && $("incluirFederais").checked && (aliquota != 0)){
							var aliquotaPIS = parseFloat(formatoMoeda(federais));
							var indicePIS = parseFloat((100 - aliquotaPIS)/100);
                                                        var pautaComFed = roundABNT((parseFloat(PautaTotalFrete) / parseFloat(indicePIS)),2);
                                                        var pautaVlIcms = roundABNT((parseFloat(baseCalculo) * parseFloat(aliquota) / 100),2);
                                                        var baseFedComPauta = roundABNT(parseFloat(pautaComFed) + parseFloat(pautaVlIcms),2);
                                                        var pautaVlFed = roundABNT((parseFloat(baseFedComPauta) * parseFloat(aliquotaPIS) / 100), 2);                                                                
							$('total').value = formatoMoeda(parseFloat(PautaTotalFrete) + parseFloat(pautaVlIcms) + parseFloat(pautaVlFed));
							$("pisCofins").value = formatoMoeda(parseFloat(pautaVlFed));
						}else if (adicionouIcms() && (aliquota != 0)){var xICMS = (parseFloat(baseCalculo) * parseFloat(aliquota) / 100);$('total').value = formatoMoeda(roundABNT(roundABNT(parseFloat(totalAntesICMS),2) + roundABNT(parseFloat(xICMS),2), 2));}}}}$('base_calculo').value = formatoMoeda(baseCalculo);
  }

var waitClosingRemetente = true;/*constantes de controle para o localizador*/
var waitClosingDestinatario = true;
var waitClosingConsignatario = true;
var waitClosingCidade = true;
var windowDestinatario = null;//começando os itens para o DOM
  var windowConsignatario = null;//espécie de "evento" da janela de localizar
function aoClicarNoLocaliza(idjanela, isAlteraTipoTaxa){
    isAlteraTipoTaxa = (isAlteraTipoTaxa == null || isAlteraTipoTaxa == undefined ? true : isAlteraTipoTaxa);
    try{
    var objFoco = "";    
    if (idjanela == "marca"){
        $('inIdMarcaVeiculo').value = $('idmarca').value;
        $('inMarcaVeiculo').value = $('descricao').value;
    }else if (idjanela == "Cfop_Nota_fiscal"){
        $('inCfopId').value = $('idcfop').value;
        $('inCfop').value = $('cfop').value;
    }else if (idjanela.split("__")[0] == "Cfop_Nota_fiscal_nfe"){
        var idxCfopNfe = idjanela.split("__")[1];      
        $('nf_cfop'+idxCfopNfe).value = $('cfop').value;
        $('nf_cfopId'+idxCfopNfe).value = $('idcfop').value;
    }else if (idjanela == "cfop"){
        $('idcfop_ctrc').value = $('idcfop').value;
        $('cfop_ctrc').value = $('cfop').value;
        parent.frameAbaixo.atualizarPlanoCusto($('idcfop').value);
    }else if (idjanela == "Endereço_Entrega"){
        $('idcfop_ctrc').value = $('idcfop').value;
        $('cfop_ctrc').value = $('cfop').value;
    }else if (idjanela == "Endereco_Coleta"){
        $('idcfop_ctrc').value = $('idcfop').value;
        $('cfop_ctrc').value = $('cfop').value;
    }else if (idjanela == "Porto_Embarque"){
        $('porto_embarque_id').value = $('porto_id').value;
        $('porto_embarque').value = $('desc_porto').value;
    }else if (idjanela == "Porto_Destino"){
        $('porto_destino_id').value = $('porto_id').value;
        $('porto_destino').value = $('desc_porto').value;
    }else if (idjanela == "Porto_Transbordo"){
        $('porto_transbordo_id').value = $('porto_id').value;
        $('porto_transbordo').value = $('desc_porto').value;
    }else if(idjanela.split("__")[0] == "Produto_ctrcs_nf"){
        var idxProdNF = idjanela.split("__")[1];    
        $('nf_conteudo'+idxProdNF).value = $('desc_prod').value;
        $('produtoId'+idxProdNF).value = $('id_produto').value;
    }
    if ((idjanela == "Destinatario") || (idjanela == "Filial") || (idjanela == "Coleta")){$("codigo_ibge_destino").value = $("cod_ibge").value;
        if(idjanela == "Destinatario" && $("dest_endereco_completo").value != ''){$("dest_endereco").value = $("dest_endereco_completo").value;}    
        atribuiCfopPadrao();
        $("comissao_vendedor").value = getValorComissaoVendedor($("des_unificada_modal_vendedor").value, $("tipoTransporte").value, $("modalConhecimento").value == "f", 
                $("vlvendestinatario").value, $("vlvendestinatario").value, $("des_comissao_rodoviario_fracionado_vendedor").value, $("des_comissao_rodoviario_lotacao_vendedor").value);
        if($("obs_lin1").value == "" || $("obs_lin2").value == "" || $("obs_lin3").value == "" || $("obs_lin4").value == ""){getStIcmsConsig();}  }
    if (idjanela == "Filial"){
          if ($('especie').value == 'CTE'){$("descricao_historico").value = 'Frete CT-e: ' + $("nfiscal").value;
          }else{$("descricao_historico").value = 'Frete CTRC: ' + $("nfiscal").value;       }
          isMostraSelo();
          if ($('st_utilizacao_cte').value != 'N'){$('especie').value = 'CTE';$('serie').value = '1';
	  }else{$('especie').value = 'CTR';$('serie').value = 'U';}
	  getAliquotasIcmsAjax($('idfilial').value);
	  if ($('uf_origem').value != '' && $('uf_destino').value != ''){alert('Ao alterar a filial a cidade de origem deverá ser escolhida novamente para que o ICMS seja atualizado!');  }                
          $('modalConhecimento').value = $('modal').value;     
          if($("obs_lin1").value == "" || $("obs_lin2").value == "" || $("obs_lin3").value == "" || $("obs_lin4").value == ""){getStIcmsConsig();}
          modalAlterarTipoTranporte();
    }
    if (idjanela == "Remetente" || idjanela == "Coleta"){$("codigo_ibge_origem").value = $("cod_ibge").value; $("lbRemetenteIE").innerHTML = $("rem_insc_est").value;     
        if(idjanela == "Remetente" && $("rem_endereco_completo").value != ''){
            $("rem_endereco").value = $("rem_endereco_completo").value; }
        if(idjanela == "Remetente"){$("tipoPadraoDocumento").value = $("tipo_documento_padrao").value; }        
            if ($('cliente_coleta_id').value == '0' && $('contipoorigem').value != 'f'){
                $("cid_origem").value = $("rem_cidade").value;
                $("uf_origem").value = $("rem_uf").value;
                $("remidcidade").value = $("idcidadeorigem").value;                
            }else if($('cliente_coleta_id').value != '0' && $('contipoorigem').value != 'f'){
                $("cid_origem").value = $("cidade_coleta").value;
                $("uf_origem").value = $("uf_coleta").value;
                $("remidcidade").value = $("cidade_coleta_id").value;}
            var objFoco = "des_codigo";
            getStIcmsConsig();
            getAliquotasIcmsAjax($('idfilial').value);} //Comparação para quando importar mais de um xml 
    if (idjanela == "Remetente"){ $("utilizatipofretetabelarem").value = $("is_utilizar_tipo_frete_tabela").value; $("rem_st_icms").value = $("st_icms").value;
        if ($('rem_rzs').value != '' && $('rem_rzs').value != $('rem_rzs_anterior').value && $('dest_uf').value != '' && $('rem_rzs_anterior').value != '' || $('dest_rzs').value != '' && $('dest_rzs').value != $('dest_rzs_anterior').value && $('dest_uf').value != '' && $('dest_rzs_anterior').value != ''){
    alert('ATENÇÃO: O cliente informado da nova Nota é diferente do(s) selecionado(s) anteriormente. Favor verificar se a alíquota do ICMS foi calculada corretamente! ');}} 
    $("rem_rzs_anterior").value = $("rem_rzs").value;//Adcionando o remetente edestinatarios atuais aos anteriores para comparar a próxima importação    
    $("dest_rzs_anterior").value = $("dest_rzs").value;
    if (idjanela == "Destinatario" || idjanela == "Coleta"){
        $("cobrarTde").checked = ($("des_inclui_tde").value == 't' || $("des_inclui_tde").value == 'true');$("lbDestinatarioIE").innerHTML = $("dest_insc_est").value;
        var objFoco = "fretepago_sim";
        $('aliquota_rodoviario').value = $('aliquota').value;
        if ($('tipoTransporte').value == 'a'){$('aliquota').value = $('aliquota_aereo').value;
        }else{$('aliquota').value = $('aliquota_rodoviario').value;}
        $("comissao_vendedor").value = getValorComissaoVendedor($("rem_unificada_modal_vendedor").value, $("tipoTransporte").value, $("modalConhecimento").value == "f", 
        $("vlvenremetente").value, $("vlvenremetente").value, $("rem_comissao_rodoviario_fracionado_vendedor").value, $("rem_comissao_rodoviario_lotacao_vendedor").value);
        getStIcmsConsig();}//se selecionou um consignatario entao calcule os dias para condicao de pgt
    if ((idjanela == "Consignatario") || (idjanela == "Coleta")){ $("con_st_icms").value = $("st_icms").value; $("con_insc_est").innerHTML = $("con_insc_est").value;
        if ($("con_tabela_remetente").value == "n") {    $("utilizatipofretetabelaconsig").value = $("is_utilizar_tipo_frete_tabela").value;
         }else{   $("utilizatipofretetabelaconsig").value = ($("utilizatipofretetabelarem").value);   }
         if($("mensagem_usuario_cte").value != null && $("mensagem_usuario_cte").value != ""){setTimeout(function(){alert("Mensagem importante para emissão de CT-e do cliente "+ $("con_rzs").value+": "+$("mensagem_usuario_cte").value);}),100}
        getCidadeOrigem(); parent.frameAbaixo.refazerDtsVenc();  getTipoProdutos(); localizaOrcamento(); getStIcmsConsig();
    }
    if(idjanela == "Consignatario"){mudarSerieCliente();}
    //se selecionou um remetente entao recalcule o icms
	if ($("idremetente") != "" && idjanela != "representante_entrega" && idjanela != "representante_coleta")
	   recalcular(false);//calculadoate deve receber a cidade do destinatario escolhido(por padrao)
	if (idjanela == "Destinatario"){
            $("idcidadedestino").value = $("cidade_destino_id").value;
            $("cid_destino").value = $("dest_cidade").value;
            $("uf_destino").value = $("dest_uf").value;
            $("calculadoate").value = $("dest_cidade").value;
            $("endereco_id").value = '0';
            $("utilizatipofretetabeladest").value = $("is_utilizar_tipo_frete_tabela").value;
            $("des_st_icms").value = $("st_icms").value;
    }//procedimentos para coleta
	if (idjanela == "Coleta"){
           if ($('tipotaxa').value == '3' && $('valor_frete').value == '0.00'){ $("tipoveiculo").style.display = "";}
           if ($('is_urbano').value == 'true' || $('is_urbano').value == 't' || $('is_urbano').value == true){  $('is_urbano2').checked = true;
           }else{ $('is_urbano2').checked = false; }
           if ($("clientepagador").value == "d"){
              $("fretepago_nao").checked = true;
              $("fretepago_sim").checked = false;
           }else{
              $("fretepago_nao").checked = false;
              $("fretepago_sim").checked = true;
           }
           $("calculadoate").value = $("dest_cidade").value;
           $("numeroCarga").value = $("numero_carga_col").value;
           $("con_tabela_remetente").value = (($("fretepago_sim").checked == true)?$("rem_tabela_remetente").value:$("des_tabela_remetente").value);
    if ($("con_tabela_remetente").value == "n") {$("utilizatipofretetabelaconsig").value = (($("fretepago_sim").checked == true)? $("utilizatipofretetabelarem").value : $("utilizatipofretetabeladest").value);  
     }else{$("utilizatipofretetabelaconsig").value = ($("utilizatipofretetabelarem").value);  }//tipo da taxa da coleta
           if (isAlteraTipoTaxa) {
               alteraTipoTaxa($("tipotaxa").value);
           }   //se jah tem uma condicao de pagt
            if ($("fretepago_sim").checked == true || $("fretepago_nao").checked == true){
           	   var prefixo = ($("fretepago_sim").checked ? "rem" : "dest");
	     	   if ($(prefixo+"_pgt") != null && !wasNull($(prefixo+"_pgt").value)) {
					$("con_pgt").value = $(prefixo+"_pgt").value;
                                        $("con_insc_est").innerHTML = $(prefixo+"_insc_est").value;
					parent.frameAbaixo.refazerDtsVenc();
	     	   }
			}
			getPrevisaoEntrega();
			getPautaFiscalConhecimento();
			calculaPesoTaxadoCtrc();
            atribuiCfopPadrao();
			getDadosIcms();
    }//se localizar redespachante para coleta
	if (idjanela == "representante_coleta"){
            $('repr_coleta_id').value = $('idredespachante').value;
            $('repr_coleta').value = $('redspt_rzs').value;
            $('repr_coleta_vlsobfrete').value = $('redspt_vlsobfrete').value;
            $('repr_coleta_vlfreteminimo').value = $('redspt_vlfreteminimo').value;
            $('repr_coleta_vlsobpeso').value = $('redspt_vlsobpeso').value;
            $('repr_coleta_vlkgate').value = $('vlkgate').value;
            $('repr_coleta_vlprecofaixa').value = $('vlprecofaixa').value;
	    calculaVlRedespachante();
        }//se localizar redespachante para entrega
	if (idjanela == "representante_entrega"){
            $('repr_entrega_id').value = $('idredespachante').value;
            $('repr_entrega').value = $('redspt_rzs').value;
            $('repr_entrega_vlsobfrete').value = $('redspt_vlsobfrete').value;
            $('repr_entrega_vlfreteminimo').value = $('redspt_vlfreteminimo').value;
            $('repr_entrega_vlsobpeso').value = $('redspt_vlsobpeso').value;
            $('repr_entrega_vlkgate').value = $('vlkgate').value;
            $('repr_entrega_vlprecofaixa').value = $('vlprecofaixa').value;
	    calculaVlRedespachante();
        }
	if (idjanela == "representante_coleta2"){
            $('repr_coleta2_id').value = $('idredespachante').value;
            $('repr_coleta2').value = $('redspt_rzs').value;
	    calculaVlRedespachante();
        }//se localizar redespachante para entrega
	if (idjanela == "representante_entrega2"){
            $('repr_entrega2_id').value = $('idredespachante').value;
            $('repr_entrega2').value = $('redspt_rzs').value;
	    calculaVlRedespachante();
        }
	getObs();//se alterou algum cliente, recarregue a tabela de preco do cliente
	if ((idjanela == "Remetente") || (idjanela == "Destinatario") ||
                (idjanela == "Consignatario") || (idjanela == "Cidade") || (idjanela == "Cidade_Destino")){
            $("con_st_icms").value = $("st_icms").value;
                if (<%=carregaconh%>) {
                    if(idjanela == "Cidade"){
                        validacaoAlterarLoginSupervisor('<%=(carregaconh ? conh.getCidadeOrigem().getIdcidade() : 0)%>',$("idcidadeorigem").value);    
                         getStIcmsConsig();
                    }else if(idjanela == "Cidade_Destino"){
                        validacaoAlterarLoginSupervisor('<%=(carregaconh ? conh.getCidadeDestino().getIdcidade() : 0)%>',$("idcidadedestino").value);                      
                    }
                }
                    getObj('vlmercadoria').focus();
                    if (isAlteraTipoTaxa) {
                       alteraTipoTaxa($("tipotaxa").value);
                   }
		getPrevisaoEntrega();
		getPautaFiscalConhecimento();
	    atribuiCfopPadrao();            
		getDadosIcms();
                getStIcmsConsig();
	}        
        if (idjanela == "Endereço_Entrega"){
            try {
                $("dest_endereco").value = $("end_logradouro").value + " "+ $("end_num_log").value + ", "+ $("end_bairro").value;
                $("dest_cidade").value = $("end_cidade").value;
                $("dest_uf").value = $("end_uf").value;
                $("cid_destino").value = $("end_cidade").value;
                $("uf_destino").value = $("end_uf").value;
                $("idcidadedestino").value = $("end_cidade_id").value;                
                getObj('vlmercadoria').focus();
                alteraTipoTaxa($("tipotaxa").value);
                getPrevisaoEntrega();
                getPautaFiscalConhecimento();
                atribuiCfopPadrao();
                getDadosIcms();
            } catch (e) {
                console.log(e.stack);
                alert(e);
            }
        }
        if (idjanela == "Endereco_Coleta"){
            try {
                $("rem_endereco").value = $("endc_logradouro").value + " "+ $("endc_num_log").value + ", "+ $("endc_bairro").value;
                $("rem_cidade").value = $("endc_cidade").value;
                $("rem_uf").value = $("endc_uf").value;
                $("cid_origem").value = $("endc_cidade").value;
                $("uf_origem").value = $("endc_uf").value;
                $("idcidadeorigem").value = $("endc_cidade_id").value;                
                getObj('vlmercadoria').focus();
                alteraTipoTaxa($("tipotaxa").value);
                getPrevisaoEntrega();
                getPautaFiscalConhecimento();
                atribuiCfopPadrao();
                getDadosIcms();
            } catch (e) {
                console.log(e.stack);
                alert(e);
            }
        }
	if ((idjanela == "Motorista") || idjanela == "Coleta" || idjanela == "Veiculo" || idjanela == "Carreta" || idjanela == "Bitrem"){
        if ($("bloqueado").value == 't' && idjanela == "Motorista") {
            setTimeout(function(){
            alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
            $("motor_nome").value = '';
            $("idmotorista").value = '0';
            },100);
        }else{
            carregarAbastecimentos();
            if (idjanela == "Motorista") {abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.CTE_VEICULO_MANUTECAO.ordinal()%>,$("idcidadeorigem").value,$("idcidadedestino").value)}
            if($('tipo').value == 'f'){
                $('chk_adv_automatica').checked = true;
                $('chk_carta_automatica').checked = false;
                if ($('percentual_ctrc_contrato_frete').value > 0){$('chk_carta_automatica').checked = true;}
                if (countADV == 0){incluiADV();}
            }else{
                $('chk_carta_automatica').checked = true;
                $('chk_adv_automatica').checked = false;
            }
			if ($('vei_prop_cgc').value.length == 14 || ($('is_tac').value == 't' || $('is_tac').value == 'true' || $('is_tac').value == true )){
				$('chk_reter_impostos').checked = true;
			}else{
				$('chk_reter_impostos').checked = false;
			}
			var cartaValorFrete = 0;

            if (parseFloat($('percentual_valor_cte_calculo_cfe').value) <= 0) {
                if ($('tipo_valor_rota').value == 'f') {
                    cartaValorFrete = $('valor_rota').value;
                } else if ($('tipo_valor_rota').value == 'p') {
                    cartaValorFrete = roundABNT(parseFloat(parseFloat($('valor_rota').value) * (parseFloat($('peso').value) / 1000)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'c') {
                    var totalPrestacao = 0;
                    if($("considerar_campo_cte").value == 'tp' || $("considerar_campo_cte").value == ''){
                        totalPrestacao = parseFloat($('total').value) - parseFloat($('icms').value);
                    }else if ($("considerar_campo_cte").value == 'fp'){
                        totalPrestacao = parseFloat($('valor_peso').value);
                    }else if ($("considerar_campo_cte").value == 'fv'){
                        totalPrestacao = parseFloat($('valor_frete').value);
                    }
                    cartaValorFrete = roundABNT(parseFloat(parseFloat(totalPrestacao) * (parseFloat($('valor_rota').value) / 100)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'n') {
                    cartaValorFrete = roundABNT(parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('valor_rota').value) / 100)), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                } else if ($('tipo_valor_rota').value == 'k') {
                    cartaValorFrete = roundABNT(parseFloat(parseFloat($('distancia_km').value) * (parseFloat($('valor_rota').value))), 2);
                    $('valor_maximo_rota').value = formatoMoeda($('cartaValorFrete').value);
                }

                if (cartaValorFrete < parseFloat($('rota_valor_minimo').value)) {
                    cartaValorFrete = parseFloat($('rota_valor_minimo').value);
                }
            } else {
                cartaValorFrete = calcularTabelaMotorista();
            }

            var valorPedagio = 0;

            if ($('is_carregar_pedagio_ctes').value == 'true') {
                valorPedagio = $('valor_pedagio').value;
            } else {
                valorPedagio = $('valor_pedagio_rota').value;
            }

            $('cartaPedagio').value = valorPedagio;

            var qtdEntregasRota = parseFloat($('qtd_entregas_rota').value);
            var qtdEntregasMontagem = parseFloat($('qtde_entregas').value);
            if (qtdEntregasMontagem >= qtdEntregasRota) {
                cartaValorFrete = parseFloat(cartaValorFrete) + parseFloat($('valor_entrega_rota').value) * (parseFloat(qtdEntregasMontagem - qtdEntregasRota + 1));
            }

            if (cartaValorFrete > 0 && $('is_deduzir_pedagio').value === 'true') {
                cartaValorFrete -= valorPedagio;
            }
            var tipoVeiculoMotorista = $("tipo_veiculo_motorista");
            var tipoVeiculoVeiculo = $("tipo_veiculo_veiculo").value;
            var tipoVeiculoCarreta = $("tipo_veiculo_carreta").value;

            if(idjanela == "Carreta" && tipoVeiculoCarreta != 0) {
                tipoVeiculoMotorista.value = tipoVeiculoCarreta;
            } else if (idjanela == "Veiculo" && tipoVeiculoVeiculo != 0 && $('idcarreta').value == '0') {
                tipoVeiculoMotorista.value = tipoVeiculoVeiculo;
            }

            var valortaxa = jsonTaxasCtrc();
            $('cartaValorFrete').value = formatoMoeda(cartaValorFrete + parseFloat(valortaxa));
            calcularFreteCarreteiro();
        }
        
                if(idjanela == "Veiculo" || idjanela == "Carreta" || idjanela == "Bitrem"){
                    validarBloqueioVeiculo("veiculo,carreta,bitrem");
                }
                if(idjanela == "Motorista"){
                    validarBloqueioVeiculoMotorista("veiculo_motorista,carreta_motorista,bitrem_motorista");
                }
	}
	if (idjanela.substring(0,25) == 'Fornecedor_Contrato_Frete'){
	    var idxForn = idjanela.split('_')[3];
		$('idFornDespCarta_'+idxForn).value = $('idfornecedor').value;
		$('fornDespCarta_'+idxForn).value = $('fornecedor').value;
		$('idPlanoDespCarta_'+idxForn).value = $('idplcustopadrao').value;
		$('planoDespCarta_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
	}
	if (idjanela.substring(0,14) == 'Fornecedor_ADV'){
	    var idxForn = idjanela.split('_')[2];
		$('idFornDespADV_'+idxForn).value = $('idfornecedor').value;
		$('fornDespADV_'+idxForn).value = $('fornecedor').value;
		$('idPlanoDespADV_'+idxForn).value = $('idplcustopadrao').value;
		$('planoDespADV_'+idxForn).value = $('contaplcusto').value + '-' + $('descricaoplcusto').value;
	}
	if (idjanela.substring(0,9) == 'Plano_ADV'){
	    var idxPlano = idjanela.split('_')[2];
		$('idPlanoDespADV_'+idxPlano).value = $('idplanocusto_despesa').value;
		$('planoDespADV_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
	}
	if (idjanela.substring(0,20) == 'Plano_Contrato_Frete'){
	    var idxPlano = idjanela.split('_')[3];
		$('idPlanoDespCarta_'+idxPlano).value = $('idplanocusto_despesa').value;
		$('planoDespCarta_'+idxPlano).value = $('plcusto_conta_despesa').value + '-' + $('plcusto_descricao_despesa').value;
	}
//         preencheRedespacho();
    if (objFoco != ''){
        $(objFoco).focus();
        $(objFoco).select();
    }
    if(idjanela == "Aeroporto_Origem"){       
        $("aeroporto_id_origem").value = $("aeroporto_id_orig").value;
        $("aeroporto_origem").value = $("aeroporto_orig").value;
    }
    if(idjanela == "Aeroporto_Destino"){
        $("aeroporto_id_destino").value = $("aeroporto_id_dest").value;
        $("aeroporto_destino").value = $("aeroporto_dest").value;
    } 
    if(idjanela == "Observacao"){//Se a tela de localizar chamada for de observação
        var obs = $("obs_desc").value != undefined ? $("obs_desc").value : "";
        obs = replaceAll(obs, "<br>", "<BR>"); //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
         $("obs_lin1").value = obs.split("<BR>")[0]; $("obs_lin2").value = obs.split("<BR>")[1];
         $("obs_lin3").value = obs.split("<BR>")[2]; $("obs_lin4").value = obs.split("<BR>")[3];
         $("obs_lin5").value = obs.split("<BR>")[4];
        if($("obs_lin1").value == "" && $("obs_lin2").value == "" && $("obs_lin3").value == "" && $("obs_lin4").value == ""){getStIcmsConsig();}}
    if(idjanela == "Terminal"){
        $("terminal").value = $("descricao").value;
    }
    if(idjanela == "Veiculo"){abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.CTE_VEICULO_MANUTECAO.ordinal()%>,$("idcidadeorigem").value,$("idcidadedestino").value)}
    if(idjanela == "Cidade_Destino"){
        localizaOrcamento();
        getAliquotasIcmsAjax(<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>);        
        if (<%=carregaconh%>) {
            validacaoAlterarLoginSupervisor('<%=(carregaconh ? conh.getCidadeDestino().getIdcidade() : 0)%>',$("idcidadedestino").value); }
       getStIcmsConsig();
    }
    if(idjanela == "Expedidor"){
        validarCidadeOrigemExpedidor(isAlteraTipoTaxa);
    } if(idjanela == "Recebedor"){
        validarCidadeDestinoRecebedor(isAlteraTipoTaxa);
    } if(idjanela == "Redespacho"){
        $("red_insc_est").innerHTML = $("red_insc_est").value;
            if ($("rec").checked) {
                validarCidadeDestinoRecebedorRedespacho(true);
            } if ($("exp").checked) {
                validarCidadeOrigemExpedidorRedespacho(true);
            } pagouRedespacho($("is_redespacho_pago").checked);
        }
    
    if(idjanela == "LocalizaOrc"){
        if ($("obs_lin1").value == "" && $("obs_lin2").value == "" && $("obs_lin3").value == "" && $("obs_lin4").value == "") {
            $("obs_lin1").value = $("obs_orcamento_hidden").value;
        }
    } else if (idjanela == "Observacao_Fisco") {
        var obsFisco = $("obs_desc").value != undefined ? $("obs_desc").value : "";
        obsFisco = replaceAll(obsFisco, "<br>", "<BR>"); //Adcionando mais uma condição para quando o split("<BR>") vinher tanto em maiusculo quanto em minusculo ele poder tratar.
        $("obs_fisco_lin1").value = obsFisco.split("<BR>")[0];
        $("obs_fisco_lin2").value = obsFisco.split("<BR>")[1];
        $("obs_fisco_lin3").value = obsFisco.split("<BR>")[2];
        $("obs_fisco_lin4").value = obsFisco.split("<BR>")[3];
        $("obs_fisco_lin5").value = obsFisco.split("<BR>")[4];
    }
    //if($("obs_lin1").value == "" || $("obs_lin2").value == "" || $("obs_lin3").value == "" || $("obs_lin4").value == ""){getStIcmsConsig();}
    }catch(e){console.log(e.stack);alert(e)}
}//aoClicarNoLocaliza
function validacaoAlterarLoginSupervisor(idCidadeCarregado, idCidadeLocalizada){
    if (idCidadeCarregado != idCidadeLocalizada) 
        abrirLoginSupervisor('<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>',<%=TipoAutorizacao.CTE_VEICULO_MANUTECAO.ordinal()%>,$("idcidadeorigem").value,$("idcidadedestino").value);
}
function getTipoProdutos(){
    tipoAtual = $('tipoproduto').value;
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);//se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao carregar os tipos de produtos.');
                return false;
            }else{
                var tipoProd = document.getElementById("divTipoProduto");
                var selectTipo = "<select name='tipoproduto' id='tipoproduto' class='fieldMin' style='width:110px;' onChange='alteraTipoProduto();' <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>";
                tipoProd.innerHTML = selectTipo+resp+"</select>";
                
                if ($("tipo_produto_destinatario_id").value != "" && $("tipo_produto_destinatario_id").value != "0") {
                    $('tipoproduto').value = $("tipo_produto_destinatario_id").value;
                }else if ($('tipoproduto').value == 0 || $('tipoproduto').value == '') {$('tipoproduto').value = tipoAtual;}
                if ($('tipoproduto').value == ''){$('tipoproduto').value = '0';}
            }
        }//funcao e()
        if ($('idconsignatario').value != ''){
            var isFreteDirigido = false;
            if($("idremetente").value != $("idconsignatario").value && $("iddestinatario").value != $("idconsignatario").value){isFreteDirigido = false; }else if($("iddestinatario").value == $("idconsignatario").value && ($("is_frete_dirigido").value == "t" || $("is_frete_dirigido").value == "true")){ isFreteDirigido = true; }else{ isFreteDirigido = false; }
            var idClienteTipoProduto = 0;
            if (isFreteDirigido && ($('remtabelaproduto').value == 't' || $('remtabelaproduto').value == 'true')) {
                idClienteTipoProduto = $("idremetente").value;
            } else {idClienteTipoProduto = $('idconsignatario').value;}
                   //if ($('contabelaproduto').value == 't' || $('contabelaproduto').value == 'true'){idClienteTipoProduto = $('idconsignatario').value;}
            espereEnviar("",true);
            tryRequestToServer(function(){new Ajax.Request("./cadtipoproduto.jsp?acao=carregaTipos&cliente="+idClienteTipoProduto,{method:'post', onSuccess: e, onError: e});});
        }
}
/**Fechando as possiveis janelas de selecao de clientes**/
//Variaveis globais para o armazenamento das taxas Obs.: Se nao houve nenhuma requisicao desde o carregamento da pag, o valor vai ser nulo
  var tarifas = {}; //Soh pra saber se jah fez uma busca da tabela de taxa do cliente(-1 = nao, 0 = sim mas n tem nenhuma para este cli, 1 = tudo ok)
  var buscouTaxas = "-1";
  function alteraTipoTaxa(idtaxa){//if($("obs_lin1").value == "" || $("obs_lin2").value == "" || $("obs_lin3").value == "" || $("obs_lin4").value == ""){getStIcmsConsig();}
      getCarregarObs(); //objeto funcao usado na requisicao Ajax(uma espécie de evento)
      function e(transport){
	     var textoresposta = transport.responseText;
	     espereEnviar("",false);      //se deu algum erro na requisicao...
	     if (textoresposta == "load=0") {
                       buscouTaxas = "0";
                       fechaClientesWindow();
		       if ($("tipotaxa").value != 5){
                            if (!(($('contabelaproduto').value == 't' || $('contabelaproduto').value == 'true') && $('tipoproduto').value == '0')){
                                if (<%=!carregaconh%>) {
                                    alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino, a composição do frete será zerada.");
                                    limparComposicaoFrete();
                                    $("tipotaxa").value = $("con_tipotaxa").value;
                                }else{
                                    alert("Não foi encontrada nenhuma tabela de preço para essa origem e esse destino.");
                                    $("tipotaxa").value = <%=conh.getTipoTaxa()%>;
                                }
                                if(<%=alteraTipoFrete%>){
                                      $("tipotaxa").disabled = false;
                                }else{
                                    $("tipotaxa").disabled = true;
                                }
                                $("tipotaxa").value = ($("tipotaxa").value == '' || $("tipotaxa").value == 'undefined' || $("tipotaxa").value == undefined ? '-1' : $("tipotaxa").value);
                                tarifas = {};
				$('client_tariff_id').value = '0';
                            }
		       }
                       if (objetoFoco != null && objetoFoco != ''){
                            $(objetoFoco).focus();
                            $(objetoFoco).select();
                            objetoFoco = '';
                       }                       
                       return false;
	     } //tudo ok na busca
             buscouTaxas = "1";  //obtendo o objeto JSON com a tabela de preço
             tarifas = eval('('+textoresposta+')');
             $("isCalculaSecCat").checked = true;
         if(tarifas.cliente_id == undefined){
            alert('O Cliente ' + $('con_rzs').value + ' não possui tabela de preço. Será usada a tabela principal para esse frete.');
         }else{            
            var utiliza = false;
            var utilizaTabelaRemetente = (($("con_tabela_remetente").value == "s" && ($("utilizatipofretetabelarem").value == 't' || $("utilizatipofretetabelarem").value == 'true')) 
                || ($("con_tabela_remetente").value == "q" && ($("utilizatipofretetabelarem").value == 't' || $("utilizatipofretetabelarem").value == 'true') && tarifas.tipo_frete_remetente != '-1'));
            if(($("utilizatipofretetabelaconsig").value == 't' || $("utilizatipofretetabelaconsig").value == 'true') || utilizaTabelaRemetente ){utiliza = true; }
            if (utiliza && tarifas.tipo_taxa != $("tipoTaxaTabela").value && tarifas.tipo_frete_peso == 'f') {
                $("tipoTaxaTabela").value = tarifas.tipo_taxa;
                alteraTipoTaxa(tarifas.tipo_taxa);return;
            }
            $("tipoTaxaTabela").value = tarifas.tipo_taxa; 
            var tp = $("tipoTaxaTabela").value;
            if($("tipoTaxaTabela").value!= null && $("tipoTaxaTabela").value!=undefined && (tp!='-1') && utiliza){
                if(($("tipotaxa").value=='0' || $("tipotaxa").value=='1') && ($("tipoTaxaTabela").value== '1' || $("tipoTaxaTabela").value=='0') && tarifas.is_considerar_maior_peso){
                }else if(($("tipotaxa").value=='0' || $("tipotaxa").value=='1'|| $("tipotaxa").value=='2') 
                        && ($("tipoTaxaTabela").value== '1' || $("tipoTaxaTabela").value=='0'|| $("tipoTaxaTabela").value=='2') && tarifas.is_considerar_valor_maior_peso_nota){
                }else{
                    $("tipotaxa").value= $("tipoTaxaTabela").value;
                    idtaxa = $("tipoTaxaTabela").value;}
                $("tipotaxa").disabled = 'true';
            }else if (tarifas.cliente_id == undefined && (tp!='-1') && utiliza){
                $("tipotaxa").value= $("tipoTaxaTabela").value;
            }else{
                if(<%=alteraTipoFrete%>){$("tipotaxa").disabled = false;}else{$("tipotaxa").disabled = true;}
            }
            if ($("id_tabela_preco_validade").value != tarifas.id) {
                if (tarifas.valida_ate != undefined && tarifas.valida_ate != ''){
                    $("id_tabela_preco_validade").value = tarifas.id;
                     var dataEmissao = new Date($('dtemissao').value.substring(6,10),$('dtemissao').value.substring(3,5),$('dtemissao').value.substring(0,2));
                     var dataValidade = new Date(tarifas.valida_ate.substring(0,4),tarifas.valida_ate.substring(5,7),tarifas.valida_ate.substring(8,10));
                     
                    if (dataValidade.getTime() < dataEmissao.getTime()){
                        alert('Atenção: A tabela de preço número '+tarifas.id+' do cliente '+ $('con_rzs').value +' esta vencida! Favor comunicar ao setor comercial.');
                    }else{
                        var qtdDiasVencer = incDias($('dtemissao').value, tarifas.valida_ate.substring(8,10)+'/'+tarifas.valida_ate.substring(5,7)+'/'+tarifas.valida_ate.substring(0,4));
                        if (qtdDiasVencer > 0 && qtdDiasVencer <= 30){
                           alert('Atenção: A tabela de preço número '+tarifas.id+' do cliente '+ $('con_rzs').value +' ira vencer em '+qtdDiasVencer+' dias! Favor comunicar ao setor comercial.');
                        }
                    }
                }
            }
            if ($('con_tabela_remetente').value == 'q' && ($("utilizatipofretetabelaconsig").value == 'f' || $("utilizatipofretetabelaconsig").value == 'false')){
                if (tarifas.tipo_frete_remetente != '-1'){if (idtaxa != tarifas.tipo_frete_remetente){ $("tipotaxa").value = tarifas.tipo_frete_remetente; alteraTipoTaxa($("tipotaxa").value);}}
            }            
         } //faz o calculo da taxa escolhida e atribui aos respectivos campos
             atribuiVlrsDaTaxa(true, idtaxa);
		 fechaClientesWindow();
            if (objetoFoco != null && objetoFoco != ''){
	        $(objetoFoco).focus();
	        $(objetoFoco).select();
	        objetoFoco = '';
	    }
            mostrarCamposComposicaoFrete(<%=alteraPreco%>);
      }      
	  var only_show_fields = ( (idtaxa == 3 && !Element.visible("tipoveiculo")) ||  (idtaxa == 1 && !Element.visible("cub_base")) || (idtaxa == 5 && !Element.visible("tipoveiculo")) );
          if (idtaxa == 3){
  	     fechaClientesWindow();
	  }else{
	     $('incluirIcms').checked = false;
	     $('incluirFederais').checked = false;
          }	  //se naum selecionou nenhum tipo de taxa...
          if(idtaxa == 3 && $("tipoveiculo").value == '-1'){
              limparComposicaoFrete();
              return false;
          }
	  if (idtaxa == -1 && $("utilizatipofretetabelaconsig").value == "false") {
             limparComposicaoFrete();
	     fechaClientesWindow();
	     return false;
	  }	  //se o usuario nao selecionou um consignatario e um destinatario...
	  if (wasNull("idremetente,idconsignatario,iddestinatario,idcidadeorigem,idcidadedestino")) {
	      alert("É preciso selecionar um cliente remetente ou cidade de origem, consignatário e um cliente destinatário para esta ação.");
              $("tipotaxa").value = -1;
              fechaClientesWindow();
              limparComposicaoFrete();
	      return false;
	  }	  //se a opcao eh "Peso/kg" e o usuario nao preencheu o peso e o valor da mercadoria...
	  if ((idtaxa == 0) && (parseFloat($("peso").value) == 0 || parseFloat($("vlmercadoria").value) == 0)) {
	      //alert("É preciso prencher os campos \"Peso(Kg)\" e \"Vl.Mercadoria\".");
		  fechaClientesWindow();
                  limparComposicaoFrete();
		  return false;
	  }      //se a opcao eh "Sobre nota fiscal" ou "Peso/Cubagem" e o usuario nao preencheu o valor da mercadoria...
	  if (((idtaxa == "1" && !only_show_fields) || idtaxa == "2")  && (parseFloat($("vlmercadoria").value) == 0)) {
	      //alert("É preciso prencher o campo \"Vl.Mercadoria\".");
		  fechaClientesWindow();
                  limparComposicaoFrete();
		  return false;
	  }      //Os procedimentos para o tipo de taxa "Cubagem" sao diferentes.
	  if (idtaxa == "1" && !only_show_fields){
	     if (/*parseFloat($("cub_base").value) <= 0 ||*/ parseFloat($("cub_metro").value) <= 0 || parseFloat($("vlmercadoria").value) <= 0){
                  alert("Para a opção de frete \"Cubagem\", vc deve obrigatoriamente preencher os campos \"Metro\", \"Base\", \"Vl.Mercadoria\"!");
                  limparComposicaoFrete();
                  fechaClientesWindow();
                  return false;
         }
      }	  //Mostrando/Ocultando campospara o tipo de taxa selecionado
  	  showFields(idtaxa);          
	  if (!only_show_fields) {
	  	 var peso_para_calculo = 0;
	  	 if (idtaxa == "0"){
            peso_para_calculo = $("peso").value;
			if ($('con_inclui_peso_container').value == true || $('con_inclui_peso_container').value == 't' || $('con_inclui_peso_container').value == 'true'){
				peso_para_calculo = parseFloat($("peso").value) + parseFloat($('peso_container').value);
			}
         }else if (idtaxa == "1"){
			if ($('tipoTransporte').value == 'a'){
				peso_para_calculo = (parseFloat($("cub_metro").value) * parseFloat(1000000)) / parseFloat($("cub_base").value);
			}else{
				peso_para_calculo = $("cub_base").value * $("cub_metro").value;
			}
         }
         
        if($("tipo_arredondamento_peso_con").value == 'a'){
            peso_para_calculo = Math.round(peso_para_calculo);
        }else if($("tipo_arredondamento_peso_con").value == 'c'){
            peso_para_calculo = Math.ceil(peso_para_calculo);
        }
    
	 espereEnviar("",true);
         var isFreteDirigido = false;
         if($("idremetente").value != $("idconsignatario").value && $("iddestinatario").value != $("idconsignatario").value){isFreteDirigido = false; }else if($("iddestinatario").value == $("idconsignatario").value && ($("is_frete_dirigido").value == "t" || $("is_frete_dirigido").value == "true")){ isFreteDirigido = true; }else{ isFreteDirigido = false; }
         tryRequestToServer(function(){new Ajax.Request("./ConhecimentoControlador?acao=carregar_taxascli&"+concatFieldValue("idcidadeorigem,idcidadedestino,idconsignatario,idremetente,iddestinatario,tipoveiculo,tipoproduto,tipoTransporte,dtemissao")+
                                       "&peso="+peso_para_calculo+"&idTaxa="+idtaxa+"&distancia_km="+$('distancia_km').value+"&con_tabela_remetente="+( isFreteDirigido ? "s" : $("con_tabela_remetente").value)+"&idDestinatario="+$("iddestinatario").value,{method:'post', onSuccess: e});});
	}
        mostrarCamposComposicaoFrete(<%=alteraPreco%>);
  }// alteraTipoTaxa()

  /*Faz o cálculo do icms e retorna a soma com o total.*/
  function getDiferencaIcms() {
     var podeCalcularIcms = ($("total").value > 0);	 
	 return formatoMoeda((podeCalcularIcms ? $("total").value /((100 - $("aliquota").value)/100) : 0));}
function atribuiCfopPadrao(){
       var idCfopComDentro = '<%=(idCfopComercioDentro != 0 ? idCfopComercioDentro : 0)%>';
       var cfopComDentro = '<%=(idCfopComercioDentro != 0 ? String.valueOf(cfopComercioDentro) : "")%>';
	   var idPlanoCustoComDentro = '<%=(idCfopComercioDentro != 0 ? String.valueOf(idPlanoCfopComercioDentro) : 0)%>';
       var idCfopComFora = '<%=(idCfopComercioFora != 0 ? idCfopComercioFora : 0)%>';
       var cfopComFora = '<%=(idCfopComercioFora != 0 ? String.valueOf(cfopComercioFora) : "")%>';
	   var idPlanoCustoComFora = '<%=(idCfopComercioFora != 0 ? String.valueOf(idPlanoCfopComercioDentro) : 0)%>';
       var idCfopInduDentro = '<%=(idCfopIndDentro != 0 ? idCfopIndDentro : 0)%>';
       var cfopInduDentro = '<%=(idCfopIndDentro != 0 ? String.valueOf(cfopIndDentro) : "")%>';
	   var idPlanoCustoInduDentro = '<%=(idCfopIndFora != 0 ? String.valueOf(idPlanoCfopIndDentro) : 0)%>';
       var idCfopInduFora = '<%=(idCfopIndFora != 0 ? idCfopIndFora : 0)%>';
       var cfopInduFora = '<%=(idCfopIndFora != 0 ? String.valueOf(cfopIndFora) : "")%>';
	   var idPlanoCustoInduFora = '<%=(idCfopIndFora != 0 ? String.valueOf(idPlanoCfopIndFora) : 0)%>';
       var idCfopCPFDentro = '<%=(idCfopPFDentro != 0 ? idCfopPFDentro : 0)%>';
       var cfopCPFDentro = '<%=(idCfopPFDentro != 0 ? String.valueOf(cfopPFDentro) : "")%>';
	   var idPlanoCustoCPFDentro = '<%=(idCfopPFDentro != 0 ? String.valueOf(idPlanoCfopPFDentro) : 0)%>';
       var idCfopCPFFora = '<%=(idCfopPFFora != 0 ? idCfopPFFora : 0)%>';
       var cfopCPFFora = '<%=(idCfopPFFora != 0 ? String.valueOf(cfopPFFora) : "")%>';
	   var idPlanoCustoCPFFora = '<%=(idCfopPFFora != 0 ? String.valueOf(idPlanoCfopPFFora) : 0)%>';
       var idCfopUF = '<%=(idCfopOutroEstado != 0 ? idCfopOutroEstado : 0)%>';
       var cfopUF = '<%=(idCfopOutroEstado != 0 ? String.valueOf(cfopOutroEstado) : "")%>';
	   var idPlanoCustoUF = '<%=(idCfopOutroEstado != 0 ? String.valueOf(idPlanoCfopOutroEstado) : 0)%>';
       var idCfopUFFora = '<%=(idCfopOutroEstadoFora != 0 ? idCfopOutroEstadoFora : 0)%>';
       var cfopUFFora = '<%=(idCfopOutroEstadoFora != 0 ? String.valueOf(cfopOutroEstadoFora) : "")%>';
	   var idPlanoCustoUFFora = '<%=(idCfopOutroEstadoFora != 0 ? String.valueOf(idPlanoCfopOutroEstadoFora) : 0)%>';
  var idCfopTraFora = '<%=(idCfopTransporteFora != 0 ? idCfopTransporteFora : 0)%>';
  var cfopTraFora = '<%=(idCfopTransporteFora != 0 ? String.valueOf(cfopTransporteFora) : "")%>';
	   var idPlanoCustoTraFora = '<%=(idCfopTransporteFora != 0 ? String.valueOf(idPlanoCfopTransporteFora) : 0)%>';
  var idCfopTraDentro = '<%=(idCfopTransporteDentro != 0 ? idCfopTransporteDentro : 0)%>';
  var cfopTraDentro = '<%=(idCfopTransporteDentro != 0 ? String.valueOf(cfopTransporteDentro) : "")%>';
	   var idPlanoCustoTraDentro = '<%=(idCfopTransporteDentro != 0 ? String.valueOf(idPlanoCfopTransporteDentro) : 0)%>';
  var idCfopServFora = '<%=(idCfopPrestacaoServicoFora != 0 ? idCfopPrestacaoServicoFora : 0)%>';
  var cfopServFora = '<%=(idCfopPrestacaoServicoFora != 0 ? cfopPrestacaoServicoFora : "")%>';
	   var idPlanoCustoServFora = '<%=(idCfopPrestacaoServicoFora != 0 ? String.valueOf(idPlanoCfopPrestacaoServicoFora) : 0)%>';
  var idCfopServDentro = '<%=(idCfopPrestacaoServicoDentro != 0 ? idCfopPrestacaoServicoDentro : 0)%>';
  var cfopServDentro = '<%=(idCfopPrestacaoServicoDentro != 0 ? cfopPrestacaoServicoDentro : "")%>';
	   var idPlanoCustoServDentro = '<%=(idCfopPrestacaoServicoDentro != 0 ? String.valueOf(idPlanoCfopPrestacaoServicoDentro) : 0)%>';
  var idCfopRuralFora = '<%=(idCfopProdutorRuralFora != 0 ? idCfopProdutorRuralFora : 0)%>';
  var cfopRuralFora = '<%=(idCfopProdutorRuralFora != 0 ? cfopProdutorRuralFora : "")%>';
	   var idPlanoCustoRuralFora = '<%=(idCfopProdutorRuralFora != 0 ? String.valueOf(idPlanoCfopProdutorRuralFora) : 0)%>';
  var idCfopRuralDentro = '<%=(idCfopProdutorRuralDentro != 0 ? idCfopProdutorRuralDentro : 0)%>';
  var cfopRuralDentro = '<%=(idCfopProdutorRuralDentro != 0 ? cfopProdutorRuralDentro : "")%>';
	   var idPlanoCustoRuralDentro = '<%=(idCfopProdutorRuralDentro != 0 ? String.valueOf(idPlanoCfopProdutorRuralDentro) : 0)%>';
  var idCfopExtFora = '<%=(idCfopExteriorFora != 0 ? idCfopExteriorFora : 0)%>';
  var cfopExtFora = '<%=(idCfopExteriorFora != 0 ? cfopExteriorFora : "")%>';
	   var idPlanoCustoExtFora = '<%=(idCfopExteriorFora != 0 ? String.valueOf(idPlanoCfopExteriorFora) : 0)%>';
  var idCfopExtDentro = '<%=(idCfopExteriorDentro != 0 ? idCfopExteriorDentro : 0)%>';
  var cfopExtDentro = '<%=(idCfopExteriorDentro != 0 ? cfopExteriorDentro : "")%>';
	   var idPlanoCustoExtDentro = '<%=(idCfopExteriorDentro != 0 ? String.valueOf(idPlanoCfopExteriorDentro) : 0)%>';
  var idCfopSubDentro = '<%=(idCfopSubContratacaoDentro != 0 ? idCfopSubContratacaoDentro : 0)%>';
  var cfopSubDentro = '<%=(idCfopSubContratacaoDentro != 0 ? cfopSubContratacaoDentro : "")%>';
           var idPlanoCustoSubDentro = '<%=(idCfopSubContratacaoDentro != 0 ? String.valueOf(idPlanoCfopSubContratacaoDentro) : 0)%>';
  var idCfopSubFora = '<%=(idCfopSubContratacaoFora != 0 ? idCfopSubContratacaoFora : 0)%>';
  var cfopSubFora = '<%=(idCfopSubContratacaoFora != 0 ? cfopSubContratacaoFora : "")%>';
           var idPlanoCustoSubFora = '<%=(idCfopSubContratacaoFora != 0 ? String.valueOf(idPlanoCfopSubContratacaoFora) : 0)%>'; 
       var filial_uf = $("fi_uf").value;
       var remetente_uf = $("uf_origem").value;
       var destinatario_uf = $("uf_destino").value;
       var cnpjConsig = $('con_cnpj').value;
       var consigIe = $("con_insc_est").innerHTML;
//       var cnpjConsig = formatCpfCnpj($ ('con_cnpj').value,true,true); comentei esta linha, pois estava formatando cpf/cnpj sempre fotmato cnpj e os valores ja chegam no formato correta
       //cnpjConsig = (cnpjConsig.replace(/\D/g,""));     
       if($("tipoServico").value == 's'){//SubContratação 
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopSubDentro : idCfopSubFora);
           $("cfop_ctrc").value = (filial_uf == destinatario_uf ? cfopSubDentro : cfopSubFora);
           $("cfop_plano_custo_id").value = (filial_uf == destinatario_uf ? idPlanoCustoSubDentro : idPlanoCustoSubFora);
       } else if (destinatario_uf == 'EX'){ //Fretes com destinatario para fora do pais           
           $("idcfop_ctrc").value = (filial_uf == remetente_uf ? idCfopExtDentro : idCfopExtFora);
           $("cfop_ctrc").value   = (filial_uf == remetente_uf ? cfopExtDentro : cfopExtFora);
           $("cfop_plano_custo_id").value   = (filial_uf == remetente_uf ? idPlanoCustoExtDentro : idPlanoCustoExtFora);
       }else if (filial_uf != remetente_uf /*&& !$('ck_redespacho').checked   COMENTADO NA STORY  PROB 3641 - POIS A REGRA DE CFOP NA SEFAZ NÃO LEVA EM CONSIDERAÇÃO CASOS DE REDESPACHO - MARCOS  */ ){ //Fretes originados em outra UF                      
           $("idcfop_ctrc").value = (remetente_uf == destinatario_uf ? idCfopUF : idCfopUFFora);
           $("cfop_ctrc").value   = (remetente_uf == destinatario_uf ? cfopUF : cfopUFFora);
           $("cfop_plano_custo_id").value   = (remetente_uf == destinatario_uf ? idPlanoCustoUF : idPlanoCustoUFFora);
       }else if (cnpjConsig.length == 14 && consigIe == "ISENTO"){//pessoa fisica   
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopCPFDentro : idCfopCPFFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopCPFDentro : cfopCPFFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoCPFDentro : idPlanoCustoCPFFora);
       }else if ($('con_tipo_cfop').value == 'c'){//COMÉRCIO           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopComDentro : idCfopComFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopComDentro : cfopComFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoComDentro : idPlanoCustoComFora);
       }else if ($('con_tipo_cfop').value == 'i'){//industria           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopInduDentro : idCfopInduFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopInduDentro : cfopInduFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoInduDentro : idPlanoCustoInduFora);
       }else if ($('con_tipo_cfop').value == 't'){//transporte           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopTraDentro : idCfopTraFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopTraDentro : cfopTraFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoTraDentro : idPlanoCustoTraFora);
       }else if ($('con_tipo_cfop').value == 'p'){//Prestador de serviço           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopServDentro : idCfopServFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopServDentro : cfopServFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoServDentro : idPlanoCustoServFora);
       }else if ($('con_tipo_cfop').value == 'r'){//Produtor Rural           
           $("idcfop_ctrc").value = (filial_uf == destinatario_uf ? idCfopRuralDentro : idCfopRuralFora);
           $("cfop_ctrc").value   = (filial_uf == destinatario_uf ? cfopRuralDentro : cfopRuralFora);
           $("cfop_plano_custo_id").value   = (filial_uf == destinatario_uf ? idPlanoCustoRuralDentro : idPlanoCustoRuralFora);
       }
       parent.frameAbaixo.atualizarPlanoCusto($("idcfop_ctrc").value);
}
function nextCtrc(){
    try{
    //evento 
        escondeCTeCancelar(null);
        habilitaSalvar(false);
	function ev(resp, st){
            if (st == 200){
                if (resp.split("<=>")[0] == "000000"){
                	alert("Número de CT-e máximo excedido pela agência");
					return false;
                }
                if (resp.split("<=>")[0] == "-1"){
                	alert("Erro interno");
					return false;
                }
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
                else{
                    getObj("nfiscal").value = resp.split("<=>")[0];
                      if ($('especie').value == 'CTE'){
                            $('descricao_historico').value = 'Frete CT-e: ' + $('nfiscal').value;
                      }else{
                            $('descricao_historico').value = 'Frete CTRC: ' + $('nfiscal').value;
                      }
					nextSelo();
                }
            }else
            alert("Status "+st+"\n\nNão conseguiu acessar o servidor!");
	}
    if ((<%=carregaconh%> && ($('especie').value == 'CTE' || $('tipoTransporte').value == '<%=conh.getTipoTransporte()%>') && $('serie').value == '<%=conh.getSerie()%>')){
       $('nfiscal').value = '<%=conh.getNumero()%>';
       $('numero_selo').value = '<%=conh.getNumeroSelo()%>';
    }else{
		var seriectrc = getObj("serie").value;
		if (seriectrc == "")
			alert("Digite uma série válida!");
		else
			requisitaAjax("./ConhecimentoControlador?acao=obter_prox_ctrc&seriectrc="+seriectrc+"&especie="+$('especie').value+"&idfilial="+$('idfilial').value+"&agency_id="+$('agency_id').value+"&sequenciaModal="+$('sequencia_modal').value, ev);
	}
    }finally{
        habilitaSalvar(true);
    }
}

function applyEventInNote() {
   try{
        var lastIndex = (getNextIndexFromTableRoot('0', 'tableNotes0') - 1);    
    //aplicando o evento ao ultimo nf_numero
//aplicando o evento ao ultimo nf_serie
    var lastSerie = $("nf_serie"+lastIndex+"_id0");
    lastSerie.onkeyup = function(e){
                              if (!e){
                                 e = window.event;
                              }
                              if (e.keyCode==13){
                                $("nf_emissao"+lastIndex+"_id0").focus();
                                $("nf_emissao"+lastIndex+"_id0").select();
                              }
                          };
    //aplicando o evento ao ultimo nf_emissao
    var lastNoteEmissao = $("nf_emissao"+lastIndex+"_id0");
    lastNoteEmissao.onkeyup = function(e){
                              if (!e){
                                 e = window.event;
                              }
                              if (e.keyCode==13){
                                $("nf_valor"+lastIndex+"_id0").focus();
                                $("nf_valor"+lastIndex+"_id0").select();
                              }
                          };
    //aplicando o evento ao ultimo nf_valor adicionado
    var lastVlNote = $("nf_valor"+lastIndex+"_id0");
    lastVlNote.onchange = function(){
                              seNaoFloatReset(lastVlNote,"0.00");
                              objetoFoco = $("nf_peso"+lastIndex+"_id0").name;
                              //atualizando totais
                              getObj("vlmercadoria").value = sumValorNotes('0');
                              alterouCampoDependente("vlmercadoria");
                              $("nf_peso"+lastIndex+"_id0").focus();
                              $("nf_peso"+lastIndex+"_id0").select();
                              if (<%=acao.equals("iniciar")%> && <%=cfg.isCartaFreteAutomatica()%>){
                                 calcularFreteCarreteiro();
                              }
                          };
    lastVlNote.onkeyup = function(e){
                              if (!e){
                                 e = window.event;
                              }
                              if (e.keyCode==13){
                                seNaoFloatReset(lastVlNote,"0.00");
                                objetoFoco = $("nf_peso"+lastIndex+"_id0").name;
                                //atualizando totais
                                getObj("vlmercadoria").value = sumValorNotes('0');
                                alterouCampoDependente("vlmercadoria");
                                $("nf_peso"+lastIndex+"_id0").focus();
                                $("nf_peso"+lastIndex+"_id0").select();
                              }
                          };
	//aplicando o evento ao ultimo nf_peso adicionado
    var lastVlPeso = getObj("nf_peso"+lastIndex+"_id0");
    lastVlPeso.onchange = function(){
    			      seNaoFloatReset(lastVlPeso,"0.00");
                              objetoFoco = $("nf_volume"+lastIndex+"_id0").name;
                              //atualizando totais
                              $("peso").value = sumPesoNotes('0');
                              alterouCampoDependente("peso");
                              calculaVlRedespachante();
             		      calculaPesoTaxadoCtrc();
                          };
    lastVlPeso.onkeyup = function(e){
                              if (!e){
                                 e = window.event;
                              }
                              if (e.keyCode==13){
                                  seNaoFloatReset(lastVlPeso,"0.00");
                                  objetoFoco = $("nf_volume"+lastIndex+"_id0").name;
                                  //atualizando totais
                                  $("peso").value = sumPesoNotes('0');
                                  alterouCampoDependente("peso");
                                  calculaVlRedespachante();
                                  $("nf_volume"+lastIndex+"_id0").focus();
                                  $("nf_volume"+lastIndex+"_id0").select();
                              }
                          };
    var lastVlVolume = $("nf_volume"+lastIndex+"_id0");
    lastVlVolume.onchange = function(){
    			      seNaoFloatReset(lastVlVolume,"0.00");
                              $("volume").value = sumVolumeNotes('0');
                              alterouCampoDependente("volume");
                          };
    lastVlVolume.onkeyup = function(e){
                              if (!e){
                                 e = window.event;
                              }
                              if (e.keyCode==13){
                                  seNaoFloatReset(lastVlVolume,"0.00");
                                  //atualizando totais
                                  $("volume").value = sumVolumeNotes('0');
                                  alterouCampoDependente("volume");
                                  $("nf_embalagem"+lastIndex+"_id0").focus();
                                  $("nf_embalagem"+lastIndex+"_id0").select();
                              }
                          };
    var lastNoteEmb = $("nf_embalagem"+lastIndex+"_id0");
    lastNoteEmb.onkeyup = function(e){
                              if (!e){
                                 e = window.event;
                              }
                              if (e.keyCode==13){
                                $("nf_conteudo"+lastIndex+"_id0").focus();
                                $("nf_conteudo"+lastIndex+"_id0").select();
                              }
                          };
                       // qtdNF();
                          }catch(e){
                                console.log(e.stack);
                                alert(e);
                          }
 } 

function pagtoAvista(){
	if ($('tipofpag').value == 'v'){//se o pagamento for à vista
		<%if (!carregaconh){%>parent.frameAbaixo.document.getElementById("dtvenc1").value = $('dtemissao').value;<%}%>
		$('trRedespachoVazia').style.display = "";$('trFilialRecebedora').style.display = "";
		if (!<%=carregaconh%> && $('qtdFiliais').value > 1){$('filialRecebedora').value = '';}
                <%if (!carregaconh){%>$("filialRecebedora").value = $("idFilialFreteAvista").value;<%}%>    
	}else{<%if (!carregaconh){%>parent.frameAbaixo.refazerDtsVenc();<%}%>$('trRedespachoVazia').style.display = "none";$('trFilialRecebedora').style.display = "none";
		<%if (!carregaconh){%>$('filialRecebedora').value = $('idfilial').value;<%}%>}}
function mostrarOcorrencias(){
	//objeto funcao usado na requisicao Ajax(uma espécie de evento)
	function e(transport){
		var textoresposta = transport.responseText;
		espereEnviar("",false);
		//se deu algum erro na requisicao...
		if (textoresposta == "-1"){
			alert('Houve algum problema ao requistar as ocorrências, favor informar manualmente.');
			return false;
		}else{Element.show("trOcorrencia");$("tdOcorrencia").innerHTML = textoresposta;}
	}//funcao e()
            $('mostrarOcor').style.display = 'none';espereEnviar("",true);
            tryRequestToServer(function(){new Ajax.Request("./ConhecimentoControlador?acao=carregarOcorrencia&ctrcId=<%=(carregaconh ? conh.getId() : 0)%>",{method:'post', onSuccess: e, onError: e});});
}
function alteraTipoTransporte(){
    if ($('tipoTransporte').value == 'r'){
       $('especie').value = 'CTE';$('lbFretePeso').innerHTML = "Frete Peso:";
       $('lbFreteValor').innerHTML = "Frete Valor:";$('lbTaxaFixa').innerHTML = "Taxa Fixa:";
       $('lbSecCat').innerHTML = "SEC/CAT:";$('aliquota').value = $('aliquota_rodoviario').value;
       $('labMotorista').innerHTML = "Motorista";$('labVeiculo').innerHTML = "Veículo";
       $('labCarreta').innerHTML = "Carreta";$('labBiTrem').innerHTML = "Bi-Trem";       
    }else if ($('tipoTransporte').value == 'a'){
	   if (<%=Apoio.getUsuario(request).getFilial().isSequenciaCtMultiModal()%>){$('especie').value = 'CTE';              
	   }else{$('especie').value = 'CTE';}
       $('lbFretePeso').innerHTML = "Frete Nacional:";$('lbFreteValor').innerHTML = "AD Valorem:";
       $('lbTaxaFixa').innerHTML = "Taxa Origem:";$('lbSecCat').innerHTML = "Taxa Destino:";
       $('aliquota').value = $('aliquota_aereo').value;$('labMotorista').innerHTML = "Motorista";
       $('labVeiculo').innerHTML = "Veículo";$('labCarreta').innerHTML = "Carreta";
       $('labBiTrem').innerHTML = "Bi-Trem";$("serie").value = $("serie_padrao_cte_aereo").value;
    }else if ($('tipoTransporte').value == 'f'){
        $('especie').value = 'CTE';
//       $('especie').value = 'CTF';
       $('lbFretePeso').innerHTML = "Frete Peso:";$('lbFreteValor').innerHTML = "Frete Valor:";
       $('lbTaxaFixa').innerHTML = "Taxa Fixa:";$('lbSecCat').innerHTML = "SEC/CAT:";
       $('aliquota').value = $('aliquota_rodoviario').value;
   }else if ($('tipoTransporte').value == 'm'){
//       $('especie').value = 'CTM';
       $('especie').value = 'CTE';$('lbFretePeso').innerHTML = "Frete Peso:";
       $('lbFreteValor').innerHTML = "Frete Valor:";$('lbTaxaFixa').innerHTML = "Taxa Fixa:";
       $('lbSecCat').innerHTML = "SEC/CAT:";$('aliquota').value = $('aliquota_rodoviario').value;
    }else if ($('tipoTransporte').value == 'q'){
//       $('especie').value = 'CTQ';
       $('especie').value = 'CTE';$('lbFretePeso').innerHTML = "Frete Peso:";
       $('lbFreteValor').innerHTML = "Frete Valor:";$('lbTaxaFixa').innerHTML = "Taxa Fixa:";
       $('lbSecCat').innerHTML = "SEC/CAT:";$('labMotorista').innerHTML = "Comandante";
       $('labVeiculo').innerHTML = "Navio";$('labCarreta').innerHTML = "Balsa";
       $('labBiTrem').innerHTML = "Balsa2";$('aliquota').value = $('aliquota_rodoviario').value;
       $("serie").value = $("serie_padrao_cte_aquaviario").value;}
//foi me passado que se estiver carregando, nao ha motivo para executar a funcao abaixo,entao criei o if a seguir.
if (!<%=carregaconh%>) {definirComissaoVendedor();}
	var xSituacaoCte = '<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()%>';
    if ((xSituacaoCte == 'H' || xSituacaoCte== 'P')&& <%=xFilialUsuario%> == $('idfilial').value && $('serie').value == '1'){$('especie').value = 'CTE';}
	var xNotaAtual = '<%=conh.getNumero()%>';var xNumeroSelo = '<%=conh.getNumeroSelo()%>';var xEspecieAtual = '<%=conh.getEspecie()%>';
	if (<%=carregaconh%>){
	    if (<%=Apoio.getUsuario(request).getFilial().isSequenciaCtMultiModal()%>){
			$('nfiscal').value = xNotaAtual;$('numero_selo').value = xNumeroSelo;$('especie').value = xEspecieAtual;
		}else if ($('tipoTransporte').value == '<%=conh.getTipoTransporte()%>' && $('serie').value == '<%=conh.getSerie()%>'){
			$('nfiscal').value = xNotaAtual;$('numero_selo').value = xNumeroSelo;$('especie').value = xEspecieAtual;
		}else{tryRequestToServer(function(){nextCtrc()});}
	}else{tryRequestToServer(function(){nextCtrc()});}}
function validarFreteCarreteiro(){
    var freteCarreteiroX = parseFloat($('cartaValorFrete').value);
    var freteMaximoCarreteiroX = parseFloat($('valor_maximo_rota').value);
    if (<%=nvAlFrete < 4%>){
		if (parseFloat(freteCarreteiroX) > parseFloat(freteMaximoCarreteiroX)){
			alert('Você não tem privilégio suficiente para aumentar o valor do frete');$('cartaValorFrete').value = formatoMoeda(freteMaximoCarreteiroX);
		}}}
function addNoteLocalizarConhecimento(idnotafiscal, numero, serie, emissao, valor, vl_base_icms, vl_icms, vl_icms_st, vl_icms_frete, peso, volume, embalagem,
        descricao_produto, idconhecimento, pedido, largura, altura, comprimento, metroCubico, marcaVeiculoId, marcaVeiculoDescricao, modeloVeiculo,
        anoVeiculo, corVeiculo, chassiVeiculo, cfopId, cfopDescricao, chaveNFe, isAgendado, dataAgenda, horaAgenda, observacaoAgenda, previsaoEm,
        previsaoAs, idDestinatario, destinatario, isEdi, maxItensCubagens, tpDoc) {
    countIdxNotes++;
   // incrementa contador de notas quando o usuário reaproveitar CTE cancelado.
    var prefix = addNote('0', 'tableNotes0', idnotafiscal, numero, serie, emissao, valor, vl_base_icms, vl_icms, vl_icms_st, vl_icms_frete, peso, volume, embalagem,
            descricao_produto, idconhecimento, pedido, false, largura, altura, comprimento, metroCubico, marcaVeiculoId, marcaVeiculoDescricao, modeloVeiculo,
            anoVeiculo, corVeiculo, chassiVeiculo, '0', 'false', cfopId, cfopDescricao, chaveNFe, isAgendado, dataAgenda, horaAgenda, observacaoAgenda, '<%=cfg.isBaixaEntregaNota()%>',
            previsaoEm, previsaoAs, idDestinatario, destinatario, isEdi, maxItensCubagens, null, tpDoc);
    updateSum(false);
    return prefix;
}
    function calculaInss(){
        var isRetencaoImpostoOpeCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "t" ? true :false);
        var valorFrete = parseFloat($("cartaValorFrete").value);

        if (<%= cfg.isDeduzirImpostosOutrasRetencoesCfe() %>) {
            var valor = parseFloat($('cartaRetencoes').value);

            if (isNaN(valor)) {
                valor = 0;
            }

            valorFrete -= valor;
        }
        
        var percentualBase = parseFloat(<%=cfg.getInssAliqBaseCalculo()%>);
        var valorJaRetido = parseFloat($("inss_prop_retido").value);
        var teto = parseFloat(<%=cfg.getTetoInss()%>);var faixas = new Array();
        faixas[0] = new Faixa(0, <%=cfg.getInssAte()%>, <%=cfg.getInssAliqAte()%>);
        faixas[1] = new Faixa(<%=cfg.getInssDe1()%>, <%=cfg.getInssAte1()%>, <%=cfg.getInssAliq1()%>);
        faixas[2] = new Faixa(<%=cfg.getInssDe2()%>, <%=cfg.getInssAte2()%>, <%=cfg.getInssAliq2()%>);
        faixas[3] = new Faixa(<%=cfg.getInssDe3()%>, <%=cfg.getInssAte3()%>, <%=cfg.getInssAliq3()%>);
        var baseINSSJaRetida = $('base_inss_prop_retido').value;
        var valorINSSJaRetido = $('inss_prop_retido').value;
        var inss = new Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseINSSJaRetida);
        if (isRetencaoImpostoOpeCFe) {
            $("valorINSSInteg").value = formatoMoeda(inss.valorFinal);
        }else{
            $("baseINSS").value = formatoMoeda(inss.baseCalculo);$("aliqINSS").value = formatoMoeda(inss.aliquota);$("valorINSS").value = formatoMoeda(inss.valorFinal);return inss;
        }
        return inss;
    }
    function calculaSest(baseCalculo){
        var isRetencaoImpostoOpeCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "t" ? true :false);
        var aliquota = parseFloat(<%=cfg.getSestSenatAliq()%>);
        var sest = new Sest(baseCalculo, aliquota);
        if (isRetencaoImpostoOpeCFe) {
            $("valorSESTInteg").value = formatoMoeda(sest.valorFinal);
        } else {
            $("baseSEST").value = formatoMoeda(sest.baseCalculo);
            $("aliqSEST").value = formatoMoeda(sest.aliquota);
            $("valorSEST").value = formatoMoeda(sest.valorFinal);
        }
        return sest;
    }
    function calculaIR(inss){
        var isRetencaoImpostoOpeCFe = ($("is_retencao_impostos_operadora_cfe").value === "true" || $("is_retencao_impostos_operadora_cfe").value === "t" ? true :false);
        var percentualBase = parseFloat(<%=cfg.getIrAliqBaseCalculo()%>);
        var isDeduzirInssIr = '<%=cfg.isDeduzirINSSIR()%>';
        var faixas = new Array();
        faixas[0] = new Faixa(0, parseFloat(<%=cfg.getIrDe1()%>), 0, 0);
        faixas[1] = new Faixa(parseFloat(<%=cfg.getIrDe1()%>), parseFloat(<%=cfg.getIrAte1()%>), parseFloat(<%=cfg.getIrAliq1()%>), parseFloat(<%=cfg.getIrdeduzir1()%>));
        faixas[2] = new Faixa(parseFloat(<%=cfg.getIrDe2()%>), parseFloat(<%=cfg.getIrAte2()%>), parseFloat(<%=cfg.getIrAliq2()%>), parseFloat(<%=cfg.getIrDeduzir2()%>));
        faixas[3] = new Faixa(parseFloat(<%=cfg.getIrDe3()%>), parseFloat(<%=cfg.getIrAte3()%>), parseFloat(<%=cfg.getIrAliq3()%>), parseFloat(<%=cfg.getIrDeduzir3()%>));
        faixas[4] = new Faixa(parseFloat(<%=cfg.getIrAte3()%>), 99999999, parseFloat(<%=cfg.getIrAliqAcima()%>), parseFloat(<%=cfg.getIrdeduzirAcima()%>));
        var baseIRJaRetida = $('base_ir_prop_retido').value;
        var valorIRJaRetido = $('ir_prop_retido').value;
      	var ir = new IR(inss.valorFrete, percentualBase, faixas, inss.valorFinal, baseIRJaRetida, valorIRJaRetido, 0, 0, false, isDeduzirInssIr);
        if (isRetencaoImpostoOpeCFe) {
            $("valorIRInteg").value = formatoMoeda(ir.valorFinal);
        } else {
            $("valorIR").value = formatoMoeda(ir.valorFinal);
            $("baseIR").value = formatoMoeda(ir.baseCalculo);
            $("aliqIR").value = formatoMoeda(ir.aliquota);
       }
    }
    function calcularAdiantamento(){
        if (<%=nivelUserAdiantamento == 0%>){
                var percPermitido = $('perc_adiant').value;
                var totalAdtmo = $('cartaValorAdiantamento').value;
                if($('cartaValorAdiantamentoExtra1').value != '0.00'){
                    totalAdtmo += $('cartaValorAdiantamentoExtra1').value
                }
                if($('cartaValorAdiantamentoExtra2').value != '0.00'){
                    totalAdtmo += $('cartaValorAdiantamentoExtra2').value
                }                
                var xTotalLiquido = $('cartaLiquido').value;
                var percAdtmo = parseFloat(totalAdtmo) * 100 / parseFloat(xTotalLiquido);
                if (parseFloat(percAdtmo) > parseFloat(percPermitido)){
                    alertMsg('Para esse motorista só é permitido ' + percPermitido + '% de adiantamento!');
                    $('cartaValorAdiantamento').value = (formatoMoeda(parseFloat($("cartaLiquido").value) * $('perc_adiant').value / 100));
                    $("cartaValorSaldo").value = formatoMoeda(parseFloat($("cartaLiquido").value) - parseFloat($("cartaValorAdiantamento").value) - parseFloat($("cartaValorAdiantamentoExtra1").value) - parseFloat($("cartaValorAdiantamentoExtra2").value));
                return false;
            }else{$("cartaValorSaldo").value = formatoMoeda(parseFloat($("cartaLiquido").value) - parseFloat($("cartaValorAdiantamento").value) - parseFloat($("cartaValorAdiantamentoExtra1").value) - parseFloat($("cartaValorAdiantamentoExtra2").value));}
        }else{$("cartaValorSaldo").value = formatoMoeda(parseFloat($("cartaLiquido").value) - parseFloat($("cartaValorAdiantamento").value) - parseFloat($("cartaValorAdiantamentoExtra1").value) - parseFloat($("cartaValorAdiantamentoExtra2").value))    ;}
    }
    function calcularFreteCarreteiro(){
	 var PercFreteCadastroProp = parseFloat($('percentual_ctrc_contrato_frete').value);
	 if (PercFreteCadastroProp > 0){
		var totalFreteCadastroProp = 0;
		var totalSeguroProp = 0;
		if ($('is_urbano2').checked){
		   totalSeguroProp = parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('taxa_roubo_urbano').value) + parseFloat($('taxa_tombamento_urbano').value)) / 100);
		}else{
		   totalSeguroProp = parseFloat(parseFloat($('vlmercadoria').value) * (parseFloat($('taxa_roubo').value) + parseFloat($('taxa_tombamento').value)) / 100);
		}
		var totalDespViagemProp = 0;
		for(var di = 0; di <= parseInt(countADV); di++){
			if ($('trADV_'+di) != null){
				totalDespViagemProp += parseFloat($('vlADV_'+di).value);
			}
		}
		for(var dd = 0; dd <= parseInt(countDespesaADV); dd++){
			if ($('trDespADV_'+dd) != null){
				totalDespViagemProp += parseFloat($('vlDespADV_'+dd).value);
			}
		}
		for(var dc = 0; dc <= parseInt(countDespesaCarta); dc++){
			if ($('trDespCarta_'+dc) != null){
				totalDespViagemProp += parseFloat($('vlDespCarta_'+dc).value);
			}
		}
		var totalLiquidoProp = parseFloat(parseFloat($('total').value) - parseFloat($('icms').value) - parseFloat(totalSeguroProp) - parseFloat(totalDespViagemProp));
		totalFreteCadastroProp = parseFloat(totalLiquidoProp * parseFloat(PercFreteCadastroProp) / 100);
		$('cartaValorFrete').value = formatoMoeda(totalFreteCadastroProp);
		$('valor_maximo_rota').value = formatoMoeda(totalFreteCadastroProp);
	 }
    var freteTonelada = parseFloat($('cartaValorTonelada').value);
    var valorPeso = parseFloat($('peso').value / 1000);
    var totalPesoTonelada = parseFloat(valorPeso * freteTonelada);
    if(totalPesoTonelada != '0.00'){$('cartaValorFrete').value = formatoMoeda(parseFloat(totalPesoTonelada));}
    var freteCarreteiro = parseFloat($('cartaValorFrete').value);
    var freteOutros = parseFloat($('cartaOutros').value);
    var fretePedagio = parseFloat($('cartaPedagio').value);
    var freteLiquido = 0;
	calculaImpostos();
        freteLiquido = parseFloat(freteCarreteiro + freteOutros + fretePedagio - parseFloat($('cartaImpostos').value) - parseFloat(colocarPonto($('cartaRetencoes').value)) - parseFloat($("abastecimentos").value));
         $('cartaLiquido').value = formatoMoeda(freteLiquido);
        if ($('tipo_desconto_prop').value == '2' && parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0) {
            // ^--- Sobre o valor do frete
            var vlCC = (freteCarreteiro * parseFloat(colocarVirgula($('percentual_desconto_prop').value))) / 100;

            if (vlCC > parseFloat($('debito_prop').value)) {
                vlCC = $('debito_prop').value;
            }

            freteLiquido = freteLiquido - vlCC;
        }
         $('cartaValorAdiantamento').value = formatoMoeda(parseFloat(freteLiquido) * parseFloat($('perc_adiant').value) / 100);
    var sld = parseFloat(freteLiquido) - parseFloat($('cartaValorAdiantamento').value) - parseFloat($('cartaValorAdiantamentoExtra1').value) - parseFloat($('cartaValorAdiantamentoExtra2').value);
	 sld = parseFloat(sld) < 0 ? 0 : sld;
	 //Verificando se vai descontar do conta corrente
	 if (parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0 ){
		$('trCartaCC').style.display = '';
         if ($('tipo_desconto_prop').value != '2') {
             // ^--- Se não for sobre o valor do frete
             var percentual_desconto = parseFloat($('percentual_desconto_prop').value);
             var vlCC = (sld == 0 ? 0 : parseFloat(parseFloat(percentual_desconto) * parseFloat(sld) / 100));
             if (parseFloat(vlCC) > parseFloat($('debito_prop').value)) {
                 vlCC = $('debito_prop').value;
             }
             sld = parseFloat(parseFloat(formatoMoeda(sld)) - parseFloat(formatoMoeda(vlCC)));
         }
		$('cartaValorCC').value = formatoMoeda(vlCC);
	 }else{
		$('trCartaCC').style.display = 'none';
		$('cartaValorCC').value = '0.00';
	 }
	 $('cartaValorSaldo').value = formatoMoeda(parseFloat(sld));
	 alteraFpag('s');
	 alteraFpagExtra1('s');
	 alteraFpagExtra1('s');
}
function executarAtalhos(event){
    if(event > 118 && event < 122){
        $("dtemissao").click();
        $("dtemissao").focus();
    }
    if (event == 113){
        incluiNF();
    }else if (event == 119){
            setTimeout(function(){
                salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>',false,false);
            },2000);
    }else if (event == 120 && <%=acao.equals("iniciar")%>){
            setTimeout(function(){
                salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>',false,true);
            },2000);
    }else if (event == 121 && <%=acao.equals("iniciar")%>){
            setTimeout(function(){
                salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>',true,false);
            },2000);
    }else if (event == 115){
        setFretePago(true);
    }else if (event == 118){
        setFretePago(false);
    }
}
function incluiNF(){
    if ((<%=conh.isCteBloqueado()%>)){
        alert('Inclusão de nota fiscal não permitida! Para incluir uma nota fiscal, o CT-e deverá estar PENDENTE ou NEGADO!');
    }else{
        countIdxNotes++;
       
        addNewNote('0', 'tableNotes0', 'true', '<%=cfg.isBaixaEntregaNota()%>',$("tipoPadraoDocumento"));
        applyEventInNote();
    }    
}
function alteraTipoConhecimento(){
    var tpConh = $('tipoConhecimento').value;
        $('localiza_ctrc').style.display = 'none';
	$('lbNFDistribuicao').style.display = 'none';
	$('lbNFDistribuicao2').style.display = 'none';
        if ((tpConh == 'd' || tpConh == 'r' || tpConh == 'c'|| tpConh =='s' || tpConh =='a' || tpConh == 'i' || tpConh == 'p') && (<%=!conh.isQuitado() && !conh.isCteBloqueado()%>)){$('localiza_ctrc').style.display = '';}
	if ($('lbNFDistribuicao').innerHTML != ''){$('lbNFDistribuicao').style.display = '';$('lbNFDistribuicao2').style.display = '';
	}
        if(tpConh =='s'){$("tableSub").style.display='';}else{$("tableSub").style.display='none';}
        $("divMinCobradas").style.display = 'none';$("tdMinCobradas").style.display = 'none';
        if('<%=conh.isCteBloqueado() && (conh.getTipo().equals("t")) %>' && tpConh == 'n'){
            parent.frameAbaixo.btcriar_duplicata.disabled = false;
            parent.frameAbaixo.nova_aprop.disabled = false;
        }
        if(tpConh == 't' && '<%=conh.getTipo().equals("t")%>'){
            parent.frameAbaixo.btcriar_duplicata.disabled = true;
            parent.frameAbaixo.nova_aprop.disabled = true;
        }
       //AlternarAbas('tdInfoConhecimento','divInfoConhecimento'); Ao TENTAR escrever o protocolo de averbação de um CTE CONFIRMADO, sempre mudava para primeira ABA.
         if('<%=conh.isCteBloqueado() && (conh.getTipo().equals("t")) %>' && tpConh == 'n'){
            parent.frameAbaixo.btcriar_duplicata.disabled = false;
            parent.frameAbaixo.nova_aprop.disabled = false;
        }
        if(tpConh == 't' && '<%=conh.getTipo().equals("t")%>'){
            parent.frameAbaixo.btcriar_duplicata.disabled = true;
            parent.frameAbaixo.nova_aprop.disabled = true;
        }
        if(tpConh == 'l'){$("tdMinCobradas").style.display = '';}}

function alteraFpag(tipo){
	if (tipo == 'a'){
		$('agente').style.display = 'none';
		$('localiza_agente_adiantamento').style.display = 'none';
		$('contaAdt').style.display = 'none';
                $('contaAdtFavorecido').style.display = 'none';
		if ($('cartaFPagAdiantamento').value == '8'){ //Carta frete
			$('agente').style.display = '';
			$('localiza_agente_adiantamento').style.display = '';
		}else if($('cartaFPagAdiantamento').value == '11' 
                        || $('cartaFPagAdiantamento').value == '12' || $('cartaFPagAdiantamento').value == '13' 
                        || $('cartaFPagAdiantamento').value == '14' || $('cartaFPagAdiantamento').value == '16' 
                        || $('cartaFPagAdiantamento').value == '17' || $('cartaFPagAdiantamento').value == '18' || $('cartaFPagAdiantamento').value == '20' ){
                   $('contaAdt').style.display = '';
                   $('contaAdtFavorecido').style.display = '';
               }
                else if((($('cartaFPagAdiantamento').value == '3') || ($('cartaFPagAdiantamento').value == '16')
                        || $('cartaFPagAdiantamento').value == '13' || $('cartaFPagAdiantamento').value == '14' 
                        || ($('cartaFPagAdiantamento').value == '17') || ($('cartaFPagAdiantamento').value == '18')
                        || ($('cartaFPagAdiantamento').value == '20') || ($('cartaFPagAdiantamento').value == '12')
                        ||($('cartaFPagAdiantamento').value == '14')||($('cartaFPagAdiantamento').value == '11')) && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){
                    $('contaAdt').style.display = '';
                    $('contaAdtFavorecido').style.display = '';
			if(<%=cfg.isControlarTalonario()%>){function e(transport){var textoresposta = transport.responseText;carregarAjaxTalaoCheque(textoresposta, $('cartaDocAdiantamento_cb'));}//funcao e()
				$('cartaDocAdiantamento_cb').style.display = "";
				tryRequestToServer(function(){new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaAdt').value,{method:'post', onSuccess: e, onError: e});});}}}else{$('agentesaldo').style.display = 'none';$('localiza_agente_saldo').style.display = 'none';if ($('cartaFPagSaldo').value == '8'){$('agentesaldo').style.display = '';$('localiza_agente_saldo').style.display = '';}}
}
function alteraFpagExtra1(tipo){
	if (tipo == 'a'){
		$('agente').style.display = 'none';
		$('localiza_agente_adiantamento').style.display = 'none';
		$('contaAdtExtra1').style.display = 'none';
                $('contaAdtFavorecido1').style.display = 'none';
		if ($('cartaFPagAdiantamentoExtra1').value == '8'){ //Carta frete
			$('agente').style.display = '';
			$('localiza_agente_adiantamento').style.display = '';
		}else if($('cartaFPagAdiantamentoExtra1').value == '11' 
                        || ($('cartaFPagAdiantamentoExtra1').value == '12') || $('cartaFPagAdiantamentoExtra1').value == '13' 
                        || $('cartaFPagAdiantamentoExtra1').value == '14' || $('cartaFPagAdiantamentoExtra1').value == '16' 
                        || $('cartaFPagAdiantamentoExtra1').value == '17' || $('cartaFPagAdiantamentoExtra1').value == '18' 
                        || $('cartaFPagAdiantamentoExtra1').value == '20' ){
                   $('contaAdtExtra1').style.display = '';
                   $('contaAdtFavorecido1').style.display = '';
               }else if((($('cartaFPagAdiantamentoExtra1').value == '3')||($('cartaFPagAdiantamentoExtra1').value == '12')
                        || $('cartaFPagAdiantamentoExtra1').value == '13' || $('cartaFPagAdiantamentoExtra1').value == '14' 
                        ||($('cartaFPagAdiantamentoExtra1').value == '16') ||($('cartaFPagAdiantamentoExtra1').value == '17')
                        ||($('cartaFPagAdiantamentoExtra1').value == '18') ||($('cartaFPagAdiantamentoExtra1').value == '20')
                        ||($('cartaFPagAdiantamentoExtra1').value == '11')) && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){//cheque, NDD ou PAMCARD
			$('contaAdtExtra1').style.display = '';
                        $('contaAdtFavorecido1').style.display = '';
			if(<%=cfg.isControlarTalonario()%>){
				function e(transport){
					var textoresposta = transport.responseText;
					carregarAjaxTalaoCheque(textoresposta, $('cartaDocAdiantamento_cbExtra1'));
				}//funcao e()
				$('cartaDocAdiantamento_cbExtra1').style.display = "";
				tryRequestToServer(function(){
					new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaAdtExtra1').value,{method:'post', onSuccess: e, onError: e});
				});}
		}
	}else{
		$('agentesaldo').style.display = 'none';
		$('localiza_agente_saldo').style.display = 'none';
		if ($('cartaFPagSaldo').value == '8'){
			$('agentesaldo').style.display = '';
			$('localiza_agente_saldo').style.display = '';
		}
	}
}
function alteraFpagExtra2(tipo){
	if (tipo == 'a'){
		$('agente').style.display = 'none';
		$('localiza_agente_adiantamento').style.display = 'none';
		$('contaAdtExtra2').style.display = 'none';
                $('contaAdtFavorecido2').style.display = 'none';
		if ($('cartaFPagAdiantamentoExtra2').value == '8'){ //Carta frete
			$('agente').style.display = '';
			$('localiza_agente_adiantamento').style.display = '';
		}else if($('cartaFPagAdiantamentoExtra2').value == '11'
                        || ($('cartaFPagAdiantamentoExtra2').value == '12') || $('cartaFPagAdiantamentoExtra2').value == '13' 
                        || $('cartaFPagAdiantamentoExtra2').value == '14' || $('cartaFPagAdiantamentoExtra2').value == '16' 
                        || $('cartaFPagAdiantamentoExtra2').value == '17' || $('cartaFPagAdiantamentoExtra2').value == '18' 
                        || $('cartaFPagAdiantamentoExtra2').value == '20' ){
                   $('contaAdtExtra2').style.display = '';
                   $('contaAdtFavorecido2').style.display = '';
               }else if((($('cartaFPagAdiantamentoExtra2').value == '3')||($('cartaFPagAdiantamentoExtra2').value == '12')
                        || $('cartaFPagAdiantamentoExtra2').value == '13' || $('cartaFPagAdiantamentoExtra2').value == '14' 
                        ||($('cartaFPagAdiantamentoExtra2').value == '16')||($('cartaFPagAdiantamentoExtra2').value == '17')
                        ||($('cartaFPagAdiantamentoExtra2').value == '18') ||($('cartaFPagAdiantamentoExtra2').value == '20')
                        ||($('cartaFPagAdiantamentoExtra2').value == '11')) && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){
			$('contaAdtExtra2').style.display = '';
                        $('contaAdtFavorecido2').style.display = '';
			if(<%=cfg.isControlarTalonario()%>){
				function e(transport){
					var textoresposta = transport.responseText;
					carregarAjaxTalaoCheque(textoresposta, $('cartaDocAdiantamento_cbExtra2'));
				}//funcao e()
				$('cartaDocAdiantamento_cbExtra2').style.display = "";
				tryRequestToServer(function(){
					new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaAdtExtra2').value,{method:'post', onSuccess: e, onError: e});
				});
			}
		}
	}else{
		$('agentesaldo').style.display = 'none';
		$('localiza_agente_saldo').style.display = 'none';
		if ($('cartaFPagSaldo').value == '8'){
			$('agentesaldo').style.display = '';
			$('localiza_agente_saldo').style.display = '';
		}
	}
}
var countADV = 0;
function incluiADV(){
	var descricaoClassNameADV = ((countADV % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
    var trADV = Builder.node("TR",{name:"trADV_"+countADV, id:"trADV_"+countADV, className:descricaoClassNameADV});
    var tdADVLixo = Builder.node("TD");
	var imgADVLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerADV("+countADV+");"});
    tdADVLixo.appendChild(imgADVLixo);
	var tdADVValor = Builder.node("TD");
    var vlADV = Builder.node("INPUT",{type:"text",id:"vlADV_"+countADV, name:"vlADV_"+countADV, size:"10", maxLength:"12", value: "0.00", className:"fieldmin", onchange: "seNaoFloatReset($('vlADV_"+countADV+"'), 0.00);calcularFreteCarreteiro();"});
    tdADVValor.appendChild(vlADV);
	var tdADVConta = Builder.node("TD");
    var contaADV = Builder.node("SELECT",{id:"contaADV_"+countADV, name:"contaADV_"+countADV, className:"fieldMin", style:"width:120px;", onChange:"getFpagADV("+countADV+");"});
	<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
		BeanConsultaConta contaAd = new BeanConsultaConta();
		contaAd.setConexao(Apoio.getUsuario(request).getConexao());
		contaAd.mostraContasViagem(0, limitarUsuarioVisualizarContas, idUsuario);
		ResultSet rsCADV = contaAd.getResultado();
		while (rsCADV.next()){
            if (rsCADV.getInt("idconta") != cfg.getConta_adiantamento_viagem_id().getIdConta()) {%>
				var optionContaADV = Builder.node("OPTION",{value:"<%=rsCADV.getString("idconta")%>"},"<%=rsCADV.getString("numero") +"-"+ rsCADV.getString("digito_conta") +" / "+ rsCADV.getString("banco")%>");
				contaADV.appendChild(optionContaADV);
		  <%}
		}rsCADV.close();
	}%>
    tdADVConta.appendChild(contaADV);
	var tdADVChq = Builder.node("TD");
	var chqADV = Builder.node("INPUT",{type:"checkbox", id:"chqADV_"+countADV, name:"chqADV_"+countADV, onClick:"getFpagADV("+countADV+");"});
    var lbChqADV = Builder.node("LABEL",{id:"lbChqADV_"+countADV, name:"lbChqADV_"+countADV});
    tdADVChq.appendChild(chqADV);
    tdADVChq.appendChild(lbChqADV);
	var tdADVDoc = Builder.node("TD");
    var docADV = Builder.node("INPUT",{type:"text",id:"docADV_"+countADV, name:"docADV_"+countADV, size:"8", maxLength:"12", value: "", className:"fieldmin"});
    var docADV_cb = Builder.node("SELECT",{id:"docADV_cb_"+countADV, name:"docADV_cb_"+countADV, className:"fieldMin",style:"display:none;"});
    tdADVDoc.appendChild(docADV);
    tdADVDoc.appendChild(docADV_cb);
    trADV.appendChild(tdADVLixo);
    trADV.appendChild(tdADVValor);
    trADV.appendChild(tdADVConta);trADV.appendChild(tdADVChq);trADV.appendChild(tdADVDoc);tbADV.appendChild(trADV);$('lbChqADV_'+countADV).innerHTML = 'Em Cheque';countADV++;}
var countDespesaCarta = 0;
function incluiDespesaCarta(){
    $("trDespesaCarta").style.display = "";
    var descricaoClassName = ((countDespesaCarta % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1");
    var trDespCarta = Builder.node("TR",{name:"trDespCarta_"+countDespesaCarta, id:"trDespCarta_"+countDespesaCarta, className:descricaoClassName});
    var tdDespLixo = Builder.node("TD",{width:"2%"});
	var imgDespLixo = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerDespCarta("+countDespesaCarta+",true);"});
    tdDespLixo.appendChild(imgDespLixo);
    var tdDespValor = Builder.node("TD",{width:"8%"});
    var vlDespCarta = Builder.node("INPUT",{type:"text",id:"vlDespCarta_"+countDespesaCarta, name:"vlDespCarta_"+countDespesaCarta, size:"5", maxLength:"12", value: "0.00", className:"fieldmin", onchange: "seNaoFloatReset($('vlDespCarta_"+countDespesaCarta+"'), 0.00);calcularFreteCarreteiro();"});
    tdDespValor.appendChild(vlDespCarta);
    var tdDespForn = Builder.node("TD",{width:"45%"});
    var idFornDespCarta = Builder.node("INPUT",{type:"hidden",id:"idFornDespCarta_"+countDespesaCarta, name:"idFornDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
    var fornDespCarta = Builder.node("INPUT",{type:"text",id:"fornDespCarta_"+countDespesaCarta, name:"fornDespCarta_"+countDespesaCarta, size:"27", maxLength:"60", value: "Fornecedor", className:"inputReadOnly8pt", readOnly:true});
    var btFornDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaFornecedorDesp_"+countDespesaCarta, name:"localizaFornecedorDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=21','Fornecedor_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespForn.appendChild(idFornDespCarta);
    tdDespForn.appendChild(fornDespCarta);
    tdDespForn.appendChild(btFornDespCarta);
    var tdDespPlano = Builder.node("TD",{width:"45%"});
    var idPlanoDespCarta = Builder.node("INPUT",{type:"hidden",id:"idPlanoDespCarta_"+countDespesaCarta, name:"idPlanoDespCarta_"+countDespesaCarta, size:"10", maxLength:"60", value: "0", className:"inputReadOnly8pt", readOnly:true});
    var planoDespCarta = Builder.node("INPUT",{type:"text",id:"planoDespCarta_"+countDespesaCarta, name:"planoDespCarta_"+countDespesaCarta, size:"27", maxLength:"60", value: "Plano Custo", className:"inputReadOnly8pt", readOnly:true});
    var btPlanoDespCarta = Builder.node("INPUT",{className:"botoes", id:"localizaPlanoDesp_"+countDespesaCarta, name:"localizaPlanoDesp_"+countDespesaCarta, type:"button", value:"...", onClick:"javascript:window.open('./localiza?acao=consultar&idlista=20','Plano_Contrato_Frete_"+countDespesaCarta+"','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');"});
    tdDespPlano.appendChild(idPlanoDespCarta);
    tdDespPlano.appendChild(planoDespCarta);
    tdDespPlano.appendChild(btPlanoDespCarta);
    trDespCarta.appendChild(tdDespLixo);
    trDespCarta.appendChild(tdDespValor);
    trDespCarta.appendChild(tdDespForn);
    trDespCarta.appendChild(tdDespPlano);
	$("tbDespesaCarta").appendChild(trDespCarta);
	//Adicionando a segunda linha
    var trDespCarta2 = Builder.node("TR",{name:"trDespCarta2_"+countDespesaCarta, id:"trDespCarta2_"+countDespesaCarta});
	var tdDespCarta2 = Builder.node("TD",{colSpan:"4"});
	var tblDespCarta2 = Builder.node("TABLE",{width:"100%"});
	var tbdDespCarta2 = Builder.node("TBODY");
    var trDespCarta2_1 = Builder.node("TR",{className:descricaoClassName});
	//TD isPago
    var tdDespPago = Builder.node("TD",{width:"29%"});
    var DespPago = Builder.node("INPUT",{type:"radio", id:"DespPago_"+countDespesaCarta, name:"DespPago_"+countDespesaCarta, onClick:"$('DespPagar_"+countDespesaCarta+"').checked = !this.checked;getFpagDespCarta("+countDespesaCarta+");"});
    var lbDespPago = Builder.node("LABEL",{id:"lbDespPago_"+countDespesaCarta, name:"lbDespPago_"+countDespesaCarta});
    var DespPagar = Builder.node("INPUT",{type:"radio", id:"DespPagar_"+countDespesaCarta, name:"DespPagar_"+countDespesaCarta, checked:"true", onClick:"$('DespPago_"+countDespesaCarta+"').checked = !this.checked;getFpagDespCarta("+countDespesaCarta+");"});
    var lbDespPagar = Builder.node("LABEL",{id:"lbDespPagar_"+countDespesaCarta, name:"lbDespPagar_"+countDespesaCarta});
    tdDespPago.appendChild(DespPago);
    tdDespPago.appendChild(lbDespPago);
    tdDespPago.appendChild(DespPagar);
    tdDespPago.appendChild(lbDespPagar);
	//TD vencimento
    var tdDespVencimento = Builder.node("TD",{width:"71%"});
    var lbDespVencimento = Builder.node("LABEL",{id:"lbDespVencimento_"+countDespesaCarta, name:"lbDespVencimento_"+countDespesaCarta});
    var vlDespVencimento = Builder.node("INPUT",{type:"text",id:"vlDespVencimento_"+countDespesaCarta, name:"vlDespVencimento_"+countDespesaCarta, size:"9", maxLength:"10", value: "<%=(Apoio.getDataAtual())%>", className:"fieldDate", style:"font-size:8pt;", onBlur:"javascript:alertInvalidDate(this);"});
    var contaDespCarta = Builder.node("SELECT",{id:"contaDespCarta_"+countDespesaCarta, name:"contaDespCarta_"+countDespesaCarta, className:"fieldMin", style:"width:120px;", onChange:"getFpagDespCarta("+countDespesaCarta+");"});
	<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
		BeanConsultaConta contaAd = new BeanConsultaConta();
		contaAd.setConexao(Apoio.getUsuario(request).getConexao());
		contaAd.mostraContas(0, true,limitarUsuarioVisualizarContas, idUsuario);
		ResultSet rsCDespCarta = contaAd.getResultado();
		while (rsCDespCarta.next()){%>
			var optionContaDespCarta = Builder.node("OPTION",{value:"<%=rsCDespCarta.getString("idconta")%>"},"<%=rsCDespCarta.getString("numero") +"-"+ rsCDespCarta.getString("digito_conta") +" / "+ rsCDespCarta.getString("banco")%>");
			contaDespCarta.appendChild(optionContaDespCarta);
		<%}rsCDespCarta.close();
	}%>
	var chqDespCarta = Builder.node("INPUT",{type:"checkbox", id:"chqDespCarta_"+countDespesaCarta, name:"chqDespCarta_"+countDespesaCarta, onClick:"getFpagDespCarta("+countDespesaCarta+");", checked:"true"});
    var lbChqDespCarta = Builder.node("LABEL",{id:"lbChqDespCarta_"+countDespesaCarta, name:"lbChqDespCarta_"+countDespesaCarta});
    var docDespCarta = Builder.node("INPUT",{type:"text",id:"docDespCarta_"+countDespesaCarta, name:"docDespCarta_"+countDespesaCarta, size:"10", maxLength:"12", value: "", className:"fieldmin"});
    var docDespCarta_cb = Builder.node("SELECT",{id:"docDespCarta_cb_"+countDespesaCarta, name:"docDespCarta_cb_"+countDespesaCarta, className:"fieldMin"});
	tdDespVencimento.appendChild(lbDespVencimento);
	tdDespVencimento.appendChild(vlDespVencimento);
	tdDespVencimento.appendChild(contaDespCarta);
	tdDespVencimento.appendChild(chqDespCarta);
	tdDespVencimento.appendChild(lbChqDespCarta);
	tdDespVencimento.appendChild(docDespCarta);
	tdDespVencimento.appendChild(docDespCarta_cb);
    trDespCarta2_1.appendChild(tdDespPago);
    trDespCarta2_1.appendChild(tdDespVencimento);
    tbdDespCarta2.appendChild(trDespCarta2_1);
    tblDespCarta2.appendChild(tbdDespCarta2);
    tdDespCarta2.appendChild(tblDespCarta2);
    trDespCarta2.appendChild(tdDespCarta2);
	$("tbDespesaCarta").appendChild(trDespCarta2);
	$("lbDespPago_"+countDespesaCarta).innerHTML = "Pago";
	$("lbDespPagar_"+countDespesaCarta).innerHTML = "A Pagar";
	$("lbDespVencimento_"+countDespesaCarta).innerHTML = "Vencimento:";
	$("lbChqDespCarta_"+countDespesaCarta).innerHTML = "Cheque    ";
	applyFormatter(document, $("vlDespVencimento_"+countDespesaCarta));
	getFpagDespCarta(countDespesaCarta);
	countDespesaCarta++;
}

function getFpagDespCarta(idxCarta){
	var isPago = $('DespPago_'+idxCarta).checked;
	$('vlDespVencimento_'+idxCarta).style.display = 'none';
	$("lbDespVencimento_"+idxCarta).style.display = 'none';
	$('contaDespCarta_'+idxCarta).style.display = 'none';
	$("chqDespCarta_"+idxCarta).style.display = 'none';
	$("lbChqDespCarta_"+idxCarta).style.display = 'none';
	$('docDespCarta_'+idxCarta).style.display = 'none';
	$('docDespCarta_cb_'+idxCarta).style.display = 'none';
	if (isPago){
		$('contaDespCarta_'+idxCarta).style.display = '';
		$("chqDespCarta_"+idxCarta).style.display = '';
		$("lbChqDespCarta_"+idxCarta).style.display = '';if (<%=cfg.isControlarTalonario()%> && $("chqDespCarta_"+idxCarta).checked){$('docDespCarta_cb_'+idxCarta).style.display = '';function e(transport){var textoresposta = transport.responseText;
				carregarAjaxTalaoCheque(textoresposta, $('docDespCarta_cb_'+idxCarta));
			}//funcao e()
			tryRequestToServer(function(){new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaDespCarta_'+idxCarta).value,{method:'post', onSuccess: e, onError: e});});
		}else{$('docDespCarta_'+idxCarta).style.display = '';}
	}else{$('vlDespVencimento_'+idxCarta).style.display = '';$("lbDespVencimento_"+idxCarta).style.display = '';}}
function getFpagADV(idxADV){
	var isCheque = $('chqADV_'+idxADV).checked;
	$('docADV_'+idxADV).style.display = 'none';
	$('docADV_cb_'+idxADV).style.display = 'none';
	if (isCheque){
		if (<%=cfg.isControlarTalonario()%>){
			$('docADV_cb_'+idxADV).style.display = '';
			function e(transport){
				var textoresposta = transport.responseText;
                                carregarAjaxTalaoCheque(textoresposta, $('docADV_cb_'+idxADV));
                            }//funcao e()
			tryRequestToServer(
				function(){
					new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaADV_'+idxADV).value,{method:'post', onSuccess: e, onError: e});
				}
			);
		}else{$('docADV_'+idxADV).style.display = '';
		}}else{$('docADV_'+idxADV).style.display = '';}
}

        
        var arAbas = new Array();
        arAbas[0] = new stAba('tdInfoConhecimento','divInfoConhecimento');
        arAbas[1] = new stAba('tdInfoContainer','divInfoContainer');
        arAbas[2] = new stAba('tdInfoCTE','divInfoCTE');
        arAbas[3] = new stAba('tdInfoGM','divInfoGM');
        arAbas[4] = new stAba('tdInfoCusto','divInfoCusto');
        arAbas[5] = new stAba('tdMinCobradas','divMinCobradas');
        arAbas[6] = new stAba('tdEntradaCategoria','divEntradaCategoria');
            function modalAlterarTipoTranporte(){var carregar = '<%=carregaconh%>';if (carregar == 'false') {if ($("tipoTransporte").value == "a") {
                    $("serie").value = $("serie_padrao_cte_aereo").value;}else if ($("tipoTransporte").value == "q") {$("serie").value = $("serie_padrao_cte_aquaviario").value;
                }else if ($("tipoTransporte").value == "r") {$("serie").value = $("serie_padrao_cte_rodoviario").value;}}
        }
        
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        function abrirLocalizaNatureza() {
            launchPopupLocate('./localiza?acao=consultar&idlista=64&fecharJanela=true', 'Natureza')
        }
    </script>
<html>
<head>
<!--<link rel="stylesheet" href="css/aba/css/tab-view.css" type="text/css" media="screen">-->
<style type="text/css"><!--.style1 {color: #FF0000}--></style>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"><meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache"><meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0"><meta name="language" content="pt-br">
<title>Lançamento de CT-e - WebTrans</title><link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css"><!-- .textfieldsObs{font-size:9px;clear: both;border: 0.3;padding: 1px;} .style1{color: #990000} --></style>
</head><body onLoad="javascript:aoCarregar();applyFormatter();AlternarAbas('tdInfoConhecimento','divInfoConhecimento');" onKeyUp="javascript:executarAtalhos(event.keyCode);alteraTipoConhecimento();">
<br>
 <form id="form1"  method="post" target="pop"><div align="center" id="divTeste" name="divTeste">
<!-- CAMPOS OCULTOS -->
  <input name="id_janela" id="id_janela" type="hidden" value="jspcadconhecimento"><input name="idmarca" id="idmarca" type="hidden" value="0"><input name="descricao" id="descricao" type="hidden" value="">
  <input name="idcfop" id="idcfop" type="hidden" value="0"><input name="cfop" id="cfop" type="hidden" value=""><input type="hidden" name="modal" id="modal" value=""><input type="hidden" name="rem_rzs_anterior" id="rem_rzs_anterior" value="">
  <input type="hidden" name="dest_rzs_anterior" id="dest_rzs_anterior" value=""><input type="hidden" id="is_IN_GSF_1298_16_GO" value="<%=Apoio.getUsuario(request).getFilial().isAtivarICMSGoias()%>">
  <input type="hidden" name="idveiculo" id="idveiculo" value="<%=(carregaconh?String.valueOf(conh.getVeiculo().getIdveiculo()):"0")%>">
  <input type="hidden" name="is_ativar_valor" id="is_ativar_valor" value="<%=Apoio.getUsuario(request).getFilial().isIsAtivaControleValorManifesto()%>">
  <input type="hidden" name="valor_max" id="valor_max" value="<%=Apoio.getUsuario(request).getFilial().getValorMaximo()%>">
  <input type="hidden" name="is_obriga_carreta" id="is_obriga_carreta" value="<%=(carregaconh && conh.getVeiculo().getTipo_veiculo().isObrigaCarreta()? "t":"f")%>">
  <input type="hidden" name="idcarreta" id="idcarreta" value="<%=(carregaconh?String.valueOf(conh.getCarreta().getIdveiculo()):"0")%>">
  <input type="hidden" name="idbitrem" id="idbitrem" value="<%=(carregaconh?String.valueOf(conh.getBiTrem().getIdveiculo()):"0")%>">
  <input type="hidden" name="idmotorista" id="idmotorista" value="<%=(carregaconh?String.valueOf(conh.getMotorista().getIdmotorista()):"0")%>">
  <input type="hidden" name="bloqueado" id="bloqueado" value=""><input type="hidden" name="motivobloqueio" id="motivobloqueio" value=""><input type="hidden" name="tipo" id="tipo" value="">
  <input type="hidden" name="idcoleta" id="idcoleta" value="<%=(carregaconh ? conh.getColeta().getId() : 0)%>"><input type="hidden" name="idfilial" id="idfilial" value="<%=(carregaconh ? String.valueOf(conh.getFilial().getIdfilial()) : (!acao.equals("")? String.valueOf(xFilialUsuario) : ""))%>">
  <input type="hidden" name="tipoUtilizacaoApisul" id="tipoUtilizacaoApisul" value="<%=(carregaconh?(conh.getFilial().getTipoUtilizacaoApisul()): 'N')%>"> <input type="hidden" name="isAverbacao" id="isAverbacao" value="<%=(carregaconh?(conh.isAverbacao()): false)%>">
  <input type="hidden" name="modDacte" id="modDacte" value="<%=Apoio.getUsuario(request).getFilial().getModeloDacte()%>">
  <%--Guarda a uf da filial selecionada para o lançamento do conheciemto. Usada na comparacao: (uf_consignatario == uf_filial ? cfoppadrao1 : cfoppadrao2)--%>
<input type="hidden" name="fi_uf" id="fi_uf" value="<%=(carregaconh ? conh.getFilial().getCidade().getUf() : (acao.equals("iniciar") ? Apoio.getUsuario(request).getFilial().getCidade().getUf() : ""))%>">
<input type="hidden" name="fi_cidade" id="fi_cidade" value="<%=(carregaconh ? conh.getFilial().getCidade().getDescricaoCidade() : (acao.equals("iniciar") ? Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade() : ""))%>">
<input type="hidden" name="fi_deduzir_pedagio" id="fi_deduzir_pedagio" value="<%=(carregaconh ? conh.getFilial().isDeduzirPedagioIcms() : Apoio.getUsuario(request).getFilial().isDeduzirPedagioIcms())%>">
<input type="hidden" name="fi_idcidade" id="fi_idcidade" value="<%=(carregaconh ? conh.getFilial().getCidade().getIdcidade() : (acao.equals("iniciar") ? Apoio.getUsuario(request).getFilial().getCidade().getIdcidade() : "0"))%>">
<input type="hidden" name="idcfop_ctrc" id="idcfop_ctrc" value="<%=(carregaconh ? String.valueOf(conh.getCfop().getIdcfop()) : "")%>">
<%-- Dados do Remetente --%>
<input type="hidden" name="remidcidade" id="remidcidade" value="<%=(carregaconh ? String.valueOf(rem.getCidade().getIdcidade()) : "")%>"><input type="hidden" name="idremetente" id="idremetente" value="<%=(carregaconh ? String.valueOf(rem.getIdcliente()) : "")%>">
<input type="hidden" name="idvenremetente" id="idvenremetente" value="<%=(carregaconh ? rem.getVendedor().getIdfornecedor() : 0)%>"><input type="hidden" name="venremetente" id="venremetente" value="<%=(carregaconh && rem.getVendedor().getRazaosocial() != null ? rem.getVendedor().getRazaosocial() : "")%>">
<input type="hidden" id="vlvenremetente" value="<%=(carregaconh ? rem.getVlcomissaoVendedor() : "")%>"><input type="hidden" id="rem_unificada_modal_vendedor" value="<%=(carregaconh ? rem.getTipoComissaoVendedor() : "")%>">
<input type="hidden" id="rem_comissao_rodoviario_fracionado_vendedor" value="<%=(carregaconh ? rem.getComissaoRodoviarioFracionadoVendedor() : "")%>"><input type="hidden" id="rem_comissao_rodoviario_lotacao_vendedor" value="<%=(carregaconh ? rem.getComissaoRodoviarioLotacaoVendedor() : "")%>">
<input type="hidden" name="remtipofpag" id="remtipofpag" value="<%=(carregaconh ? rem.getTipoPagtoFrete() : "n")%>"><input type="hidden" name="remtipoorigem" id="remtipoorigem" value="<%=(carregaconh ? rem.getTipoOrigemFrete() : "r")%>">
<input type="hidden" name="remtabelaproduto" id="remtabelaproduto" value="<%=(carregaconh ? rem.isTabelaTipoProduto() : "f")%>"><input type="hidden" name="cliente_coleta_id" id="cliente_coleta_id" value="0"><input type="hidden" name="cidade_coleta_id" id="cidade_coleta_id" value="0"><input type="hidden" name="cidade_coleta" id="cidade_coleta" value="">
<input type="hidden" name="uf_coleta" id="uf_coleta" value=""><input type="hidden" name="rem_st_icms" id="rem_st_icms" value="<%=(carregaconh ? rem.getStIcms().getId() : "1")%>"><input type="hidden" name="rem_reducao_icms" id="rem_reducao_icms" value="<%=(carregaconh ? rem.getReducaoIcms() : "0")%>"><input type="hidden" name="rem_is_in_gsf_598_03_go" id="rem_is_in_gsf_598_03_go" value="<%=(carregaconh ? rem.isUtilizarNormativaGSF598GO() : "f")%>">
<input type="hidden"id="rem_obs" value="<%=(carregaconh ? rem.getObservacao() : "")%>"><input type="hidden"id="tipo_documento_padrao" value="">
<%-- Dados do Destinatário --%>
<input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=(carregaconh ? String.valueOf(des.getIdcliente()) : "")%>"><input type="hidden" name="idvendestinatario" id="idvendestinatario" value="<%=(carregaconh ? des.getVendedor().getIdfornecedor() : 0)%>">
<input type="hidden" name="vendestinatario" id="vendestinatario" value="<%=(carregaconh && des.getVendedor().getRazaosocial() != null ? des.getVendedor().getRazaosocial() : "")%>">
<input type="hidden" id="vlvendestinatario" value="<%=(carregaconh ? des.getVlcomissaoVendedor() : "")%>"><input type="hidden" name="desttipofpag" id="desttipofpag" value="<%=(carregaconh ? des.getTipoPagtoFrete() : "n")%>">
<input type="hidden" name="desttipoorigem" id="desttipoorigem" value="<%=(carregaconh ? des.getTipoOrigemFrete() : "r")%>"><input type="hidden" name="desttabelaproduto" id="desttabelaproduto" value="<%=(carregaconh ? des.isTabelaTipoProduto() : "f")%>">
<input type="hidden" name="endereco_id" id="endereco_id" value="<%=(carregaconh ? conh.getEnderecoEntrega().getId() : "0")%>"><input type="hidden" id="des_unificada_modal_vendedor" value="<%=(carregaconh ? des.getTipoComissaoVendedor() : "")%>">
<input type="hidden" id="des_comissao_rodoviario_fracionado_vendedor" value="<%=(carregaconh ? des.getComissaoRodoviarioFracionadoVendedor() : "")%>"><input type="hidden" id="des_comissao_rodoviario_lotacao_vendedor" value="<%=(carregaconh ? des.getComissaoRodoviarioLotacaoVendedor() : "")%>">
<input type="hidden" id="end_num_log" value="<%=(carregaconh ? conh.getEnderecoEntrega().getNumeroLogradouro() : "0")%>"><input type="hidden" id="end_logradouro" value="<%=(carregaconh ? conh.getEnderecoEntrega().getLograoduro() : "")%>">
<input type="hidden" id="end_complemento" value="<%=(carregaconh ? conh.getEnderecoEntrega().getComplemento() : "")%>"><input type="hidden" id="end_cep" value="<%=(carregaconh ? conh.getEnderecoEntrega().getCep() : "")%>">
<input type="hidden" id="end_bairro" value="<%=(carregaconh ? conh.getEnderecoEntrega().getBairro() : "")%>"><input type="hidden" id="end_cidade" value="<%=(carregaconh ? conh.getEnderecoEntrega().getCidade().getDescricaoCidade() : "")%>">
<input type="hidden" id="end_cidade_id" value="<%=(carregaconh ? conh.getEnderecoEntrega().getCidade().getIdcidade() : "0")%>"><input type="hidden" id="end_uf" value="<%=(carregaconh ? conh.getEnderecoEntrega().getCidade().getUf() : "")%>">
<input type="hidden" name="endereco_coleta_id" id="endereco_coleta_id" value="<%=(carregaconh ? conh.getEnderecoColeta().getId() : "0")%>"><input type="hidden" id="endc_num_log" value="<%=(carregaconh ? conh.getEnderecoColeta().getNumeroLogradouro() : "0")%>">
<input type="hidden" id="endc_logradouro" value="<%=(carregaconh ? conh.getEnderecoColeta().getLograoduro() : "")%>"><input type="hidden" id="endc_complemento" value="<%=(carregaconh ? conh.getEnderecoColeta().getComplemento() : "")%>">
<input type="hidden" id="endc_cep" value="<%=(carregaconh ? conh.getEnderecoColeta().getCep() : "")%>"><input type="hidden" id="endc_bairro" value="<%=(carregaconh ? conh.getEnderecoColeta().getBairro() : "")%>">
<input type="hidden" id="endc_cidade" value="<%=(carregaconh ? conh.getEnderecoColeta().getCidade().getDescricaoCidade() : "")%>"><input type="hidden" id="endc_cidade_id" value="<%=(carregaconh ? conh.getEnderecoColeta().getCidade().getIdcidade() : "0")%>">
<input type="hidden" id="endc_uf" value="<%=(carregaconh ? conh.getEnderecoColeta().getCidade().getUf() : "")%>"><input type="hidden" name="des_st_icms" id="des_st_icms" value="<%=(carregaconh ? des.getStIcms().getId() : "1")%>">
<input type="hidden" name="des_reducao_icms" id="des_reducao_icms" value="<%=(carregaconh ? des.getReducaoIcms() : "0")%>"><input type="hidden" name="des_is_in_gsf_598_03_go" id="des_is_in_gsf_598_03_go" value="<%=(carregaconh ? des.isUtilizarNormativaGSF598GO() : "f")%>">
<input type="hidden"id="dest_obs" value="<%=(carregaconh ? des.getObservacao() : "")%>">
<%-- Dados do Consignatario --%>
<input type="hidden" id="con_unificada_modal_vendedor" value="<%=(carregaconh ? con.getTipoComissaoVendedor() : "")%>"><input type="hidden" id="con_comissao_rodoviario_fracionado_vendedor" value="<%=(carregaconh ? con.getComissaoRodoviarioFracionadoVendedor() : "")%>">
<input type="hidden" id="con_comissao_rodoviario_lotacao_vendedor" value="<%=(carregaconh ? con.getComissaoRodoviarioLotacaoVendedor() : "")%>"><input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(carregaconh ? String.valueOf(con.getIdcliente()) : "")%>">
<input type="hidden" name="contipofpag" id="contipofpag" value="<%=(carregaconh ? con.getTipoPagtoFrete() : "n")%>"><input type="hidden" name="contipoorigem" id="contipoorigem" value="<%=(carregaconh ? con.getTipoOrigemFrete() : "r")%>">
<input type="hidden" name="contabelaproduto" id="contabelaproduto" value="<%=(carregaconh ? con.isTabelaTipoProduto() : "f")%>"><input type="hidden" name="con_st_icms" id="con_st_icms" value="<%=(carregaconh ? con.getStIcms().getId() : "1")%>">
<input type="hidden" name="con_reducao_icms" id="con_reducao_icms" value="<%=(carregaconh ? con.getReducaoIcms() : "0")%>"><input type="hidden" name="con_is_in_gsf_598_03_go" id="con_is_in_gsf_598_03_go" value="<%=(carregaconh ? con.isUtilizarNormativaGSF598GO() : "f")%>">
<input type="hidden"id="con_obs" value="<%=(carregaconh ? con.getObservacao() : "")%>">
<%-- Dados do Redespacho --%>
<input type="hidden" id="red_unificada_modal_vendedor" value="<%=(carregaconh  && red != null? red.getTipoComissaoVendedor() : "")%>"><input type="hidden" id="red_comissao_rodoviario_fracionado_vendedor" value="<%=(carregaconh  && red != null? red.getComissaoRodoviarioFracionadoVendedor() : "")%>">
<input type="hidden" id="red_comissao_rodoviario_lotacao_vendedor" value="<%=(carregaconh && red != null? red.getComissaoRodoviarioLotacaoVendedor() : "")%>"><input type="hidden" name="idredespacho" id="idredespacho" value="<%=(carregaconh ? (red != null ? String.valueOf(red.getIdcliente()) : "") : "")%>">
<input type="hidden" name="idvenredespacho" id="idvenredespacho" value="<%=(carregaconh  && red != null ? red.getVendedor().getIdfornecedor() : 0)%>"><input type="hidden" name="venredespacho" id="venredespacho" value="<%=(carregaconh  && red != null ? red.getVendedor().getRazaosocial() : "")%>">
<input type="hidden" id="vlvenredespacho" value="<%=(carregaconh  && red != null ? red.getVlcomissaoVendedor() : "")%>"><input type="hidden" name="redtipofpag" id="redtipofpag" value="n"><input type="hidden" name="red_st_icms" id="red_st_icms" value=""><input type="hidden" name="red_reducao_icms" id="red_reducao_icms" value="<%=(carregaconh  && red != null ? red.getReducaoIcms() : "0")%>">
<input type="hidden" name="red_is_in_gsf_598_03_go" id="red_is_in_gsf_598_03_go" value="<%=(carregaconh  && red != null ? red.isUtilizarNormativaGSF598GO() : "f")%>"><input type="hidden" name="redtipoorigem" id="redtipoorigem" value="<%=(carregaconh ? (red != null ? red.getTipoOrigemFrete() : "r") : "r")%>">
<input type="hidden" name="redtabelaproduto" id="redtabelaproduto" value="<%=(carregaconh ? (red != null ? red.isTabelaTipoProduto() : "f") : "f")%>">
<%-- Dados do Redespachante --%>
<input type="hidden" name="idredespachante" id="idredespachante" value="0"><input name="redspt_rzs" type="hidden" id="redspt_rzs" value="" size="25" readonly class="inputReadOnly8pt">
<%-- Dados do Expedidor --%>
<input type="hidden" name="idexpedidor" id="idexpedidor" value="<%=(carregaconh ? String.valueOf(exp.getIdcliente()) : "")%>">
<%-- Dados do Recebedor --%>
<input type="hidden" name="idrecebedor" id="idrecebedor" value="<%=(carregaconh ? String.valueOf(rec.getIdcliente()) : "")%>">
<%-- Dados da Análise de crédito --%>
<input type="hidden" name="rem_analise_credito" id="rem_analise_credito" value="<%=(carregaconh ? rem.isAnaliseCredito() : "f")%>"><input type="hidden" name="des_analise_credito" id="des_analise_credito" value="<%=(carregaconh ? des.isAnaliseCredito() : "f")%>">
<input type="hidden" name="con_analise_credito" id="con_analise_credito" value="<%=(carregaconh ? con.isAnaliseCredito() : "f")%>"><input type="hidden" name="red_analise_credito" id="red_analise_credito" value="<%=(carregaconh ? (red != null ? red.isAnaliseCredito() : "f") : "f")%>">
<input type="hidden" name="rem_valor_credito" id="rem_valor_credito" value="<%=(carregaconh ? rem.getCreditoDisponivel() : 0)%>"><input type="hidden" name="des_valor_credito" id="des_valor_credito" value="<%=(carregaconh ? des.getCreditoDisponivel() : 0)%>">
<input type="hidden" name="con_valor_credito" id="con_valor_credito" value="<%=(carregaconh ? con.getCreditoDisponivel() : 0)%>"><input type="hidden" name="red_valor_credito" id="red_valor_credito" value="<%=(carregaconh ? (red != null ? red.getCreditoDisponivel() : 0) : 0)%>">
<input type="hidden" name="rem_is_bloqueado" id="rem_is_bloqueado" value="<%=(carregaconh ? rem.isCreditoBloqueado() : "f")%>"><input type="hidden" name="des_is_bloqueado" id="des_is_bloqueado" value="<%=(carregaconh ? des.isCreditoBloqueado() : "f")%>">
<input type="hidden" name="con_is_bloqueado" id="con_is_bloqueado" value="<%=(carregaconh ? con.isCreditoBloqueado() : "f")%>"><input type="hidden" name="red_is_bloqueado" id="red_is_bloqueado" value="<%=(carregaconh ? (red != null ? red.isCreditoBloqueado() : "f") : "f")%>">
<input type="hidden" name="rem_tabela_remetente" id="rem_tabela_remetente" value="<%=(carregaconh ? rem.getUtilizaTabelaRemetente() : "n")%>"><input type="hidden" name="des_tabela_remetente" id="des_tabela_remetente" value="<%=(carregaconh ? des.getUtilizaTabelaRemetente() : "n")%>">
<input type="hidden" name="con_tabela_remetente" id="con_tabela_remetente" value="<%=(carregaconh ? con.getUtilizaTabelaRemetente() : "n")%>"><input type="hidden" name="red_tabela_remetente" id="red_tabela_remetente" value="<%=(carregaconh ? (red != null ? red.getUtilizaTabelaRemetente() : "n") : "n")%>">
<%-- Cliente pagador da coleta, se vai ser o dest. ou o rem. --%>
<input type="hidden" name="clientepagador" id="clientepagador" value="">
<%-- Dias do prazo de pagamento do cliente --%>
<input type="hidden" id="rem_pgt" name="rem_pgt"><input type="hidden" id="dest_pgt" name="dest_pgt"><input type="hidden" id="con_pgt" name="con_pgt"><input type="hidden" id="red_pgt" name="red_pgt"><input type="hidden" name="vlvenconsignatario" id="vlvenconsignatario" value="<%=(carregaconh  ? con.getVlcomissaoVendedor() : "")%>">
<%-- Referente ao Redespachante --%>
<input type="hidden" id="redspt_vlsobfrete" name="redspt_vlsobfrete" value="0"><input type="hidden" id="redspt_vlfreteminimo" name="redspt_vlfreteminimo" value="0"><input type="hidden" id="redspt_vlsobpeso" name="redspt_vlsobpeso"  value="0"><input type="hidden" id="vlkgate" name="vlkgate"  value="0">
<input type="hidden" id="vlprecofaixa" name="vlprecofaixa" value="0"><input type="hidden" id="repr_coleta_vlsobfrete" name="repr_coleta_vlsobfrete" value="<%=(carregaconh? conh.getRepresentante2().getVlsobfrete() : 0)%>">
<input type="hidden" id="repr_coleta_vlfreteminimo" name="repr_coleta_vlfreteminimo" value="<%=(carregaconh? conh.getRepresentante2().getVlfreteminimo() : 0)%>"><input type="hidden" id="repr_coleta_vlsobpeso" name="repr_coleta_vlsobpeso"  value="<%=(carregaconh? conh.getRepresentante2().getVlsobpeso() : 0)%>">
<input type="hidden" id="repr_coleta_vlkgate" name="repr_coleta_vlkgate"  value="<%=(carregaconh? conh.getRepresentante2().getVlKgAte() : 0)%>"><input type="hidden" id="repr_coleta_vlprecofaixa" name="repr_coleta_vlprecofaixa" value="<%=(carregaconh? conh.getRepresentante2().getVlPrecoFaixa() : 0)%>">
<input type="hidden" id="repr_entrega_vlsobfrete" name="repr_entrega_vlsobfrete" value="<%=(carregaconh? conh.getRedespachante().getVlsobfrete() : 0)%>"><input type="hidden" id="repr_entrega_vlfreteminimo" name="repr_entrega_vlfreteminimo" value="<%=(carregaconh? conh.getRedespachante().getVlfreteminimo() : 0)%>">
<input type="hidden" id="repr_entrega_vlsobpeso" name="repr_entrega_vlsobpeso"  value="<%=(carregaconh? conh.getRedespachante().getVlsobpeso() : 0)%>"><input type="hidden" id="repr_entrega_vlkgate" name="repr_entrega_vlkgate"  value="<%=(carregaconh? conh.getRedespachante().getVlKgAte() : 0)%>">
<input type="hidden" id="repr_entrega_vlprecofaixa" name="repr_entrega_vlprecofaixa" value="<%=(carregaconh? conh.getRedespachante().getVlPrecoFaixa() : 0)%>"><input type="hidden" id="idvendedor" name="idvendedor" value="<%=(carregaconh?conh.getVendedor().getIdfornecedor():0)%>">
<input type="hidden" id="obs_desc" name="obs_desc" value="">
<%-- Tipo de taxa padrao  --%>
<input type="hidden" id="rem_tipotaxa" name="rem_tipotaxa" value="<%=(carregaconh? rem.getTipo_tabela()+"" : "") %>"><input type="hidden" id="dest_tipotaxa" name="dest_tipotaxa" value="<%=(carregaconh? des.getTipo_tabela()+"" : "") %>">
<input type="hidden" id="con_tipotaxa" name="con_tipotaxa" value="<%=(carregaconh? con.getTipo_tabela()+"" : "-1") %>"><input type="hidden" id="red_tipotaxa" name="red_tipotaxa" value="<%=(carregaconh? (red != null ? red.getTipo_tabela() : "-1") : "-1") %>">
<%-- Cubagem padrao para o cliente  --%>
<input type="hidden" id="rem_cub_base" name="rem_cub_base"><input type="hidden" id="dest_cub_base" name="dest_cub_base" ><input type="hidden" id="red_cub_base" name="red_cub_base"><input type="hidden" id="idcidadeorigem" name="idcidadeorigem" value="<%=(carregaconh? conh.getCidadeOrigem().getIdcidade() : 0)%>">
<input type="hidden" id="idcidadedestino" name="idcidadedestino" value="<%=(carregaconh? conh.getCidadeDestino().getIdcidade() : 0)%>"><input type="hidden" id="cidade_destino_id" name="cidade_destino_id" value="0">
<input type="hidden" id="exp_idcidade" name="exp_idcidade" value="0"><input type="hidden" id="rec_idcidade" name="rec_idcidade" value="0"><input type="hidden" id="red_cidade_id" name="red_cidade_id" value="<%=(carregaconh? (red != null ? red.getCidade().getIdcidade() : 0) : 0 ) %>">
<input type="hidden" id="red_rota_viagem_id" name="red_rota_viagem_id" value="0"><input type="hidden" id="red_rota_viagem" name="red_rota_viagem" value="0"><input type="hidden" id="red_rota_taxas" name="red_rota_taxas" value="0"><input type="hidden" id="porto_id" value="0">
<input type="hidden" id="desc_porto" value="">
<!-- Conteudo -->
<input type="hidden" id="desc_prod" name="desc_prod" value=""><input type="hidden" id="id_produto" name="id_produto" value="0">
<%-- no caso de uso de frames, eh preciso criar uma div com o login do usuario --%>
<div id="usuarioLogado" style="display:none;"><%=(!acao.equals("") ? Apoio.getUsuario(request).getLogin() : "")%></div>
<%-- Informa se deve ser adicionado ao total a diferenca de icms --%>
<input type="hidden" name="addicms" id="addicms" value="<%=(carregaconh ? conh.isAddedIcms() : false)%>"><input type="hidden" name="aliquota_aereo" id="aliquota_aereo" value="<%=Apoio.to_curr(conh.getAliquota())%>">
<input type="hidden" name="aliquota_rodoviario" id="aliquota_rodoviario" value="<%=Apoio.to_curr(conh.getAliquota())%>"><input type="hidden" name="st_utilizacao_cte" id="st_utilizacao_cte" value=""><input name="aeroporto_id_origem" type="hidden" id="aeroporto_id_origem" value="<%=(carregaconh ? String.valueOf(conh.getAeroportoOrigem().getId()) : "")%>">
<input name="aeroporto_id_orig" type="hidden" id="aeroporto_id_orig" value="<%=(carregaconh ? String.valueOf(conh.getAeroportoOrigem().getId()) : "")%>"><input name="aeroporto_orig" type="hidden" id="aeroporto_orig" value="<%=(carregaconh ? String.valueOf(conh.getAeroportoOrigem().getId()) : "")%>">
<input name="aeroporto_id_dest" type="hidden" id="aeroporto_id_dest" value="<%=(carregaconh ? String.valueOf(conh.getAeroportoDestino().getId()) : "")%>"><input name="aeroporto_dest" type="hidden" id="aeroporto_dest" value="<%=(carregaconh ? String.valueOf(conh.getAeroportoDestino().getId()) : "")%>">
<input name="aeroporto_id_destino" type="hidden" id="aeroporto_id_destino" value="<%=(carregaconh ? String.valueOf(conh.getAeroportoDestino().getId()) : "")%>"><input type="hidden" id="countAdiantamento" name="countAdiantamento" value="0"><input type="hidden" id="idConhecimento" name="idConhecimento" value="<%=(carregaconh ? conh.getId() : 0)%>">
<%-- serie padrão cte, aereo, aquaviario e rodoviario --%>
<input type="hidden" id="serie_padrao_cte_aereo" name="serie_padrao_cte_aereo" value="<%=(carregaconh ? conh.getSerie() : Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAereo())%>">
<input type="hidden" id="serie_padrao_cte_aquaviario" name="serie_padrao_cte_aquaviario" value="<%=(carregaconh ? conh.getSerie() : Apoio.getUsuario(request).getFilial().getSeriePadraoCTeAquaviario())%>">
<input type="hidden" id="serie_padrao_cte_rodoviario" name="serie_padrao_cte_rodoviario" value="<%=(carregaconh ? conh.getSerie() : Apoio.getUsuario(request).getFilial().getSeriePadraoCTeRodoviario())%>">
<input type="hidden" id="idFilialFreteAvista" name="idFilialFreteAvista" value="<%=(carregaconh ? fi.getUtilizaFilialFreteAvistaCTe().getIdfilial() : Apoio.getUsuario(request).getFilial().getUtilizaFilialFreteAvistaCTe().getIdfilial())%>">
<input type="hidden" name="utilizatipofretetabelarem" id="utilizatipofretetabelarem" value="<%=(carregaconh ? conh.getRemetente().isUtilizarTipoFreteTabela() : false)%>"><input type="hidden" name="utilizatipofretetabeladest" id="utilizatipofretetabeladest" value="<%=(carregaconh ? conh.getDestinatario().isUtilizarTipoFreteTabela() : false)%>">
<input type="hidden" name="utilizatipofretetabelared" id="utilizatipofretetabelared" value="<%=(carregaconh ? conh.getRedespacho().isUtilizarTipoFreteTabela() : false)%>"><input type="hidden" name="utilizatipofretetabelaconsig" id="utilizatipofretetabelaconsig" value="<%=(carregaconh ? conh.getCliente().isUtilizarTipoFreteTabela() : false)%>">
<input type="hidden" name="is_utilizar_tipo_frete_tabela" id="is_utilizar_tipo_frete_tabela" value=""><input type="hidden" name="tipoTaxaTabela" id="tipoTaxaTabela" value=""><input type="hidden" name="os_aberto_veiculo" id="os_aberto_veiculo" value="<%=(carregaconh && conh.getVeiculo().isOsAbertoVeiculo() ? "t" : "f")%>">
<input type="hidden" name="codigo_ibge_origem" id="codigo_ibge_origem" value="<%=(carregaconh ? conh.getCidadeOrigem().getCod_ibge() : "")%>"><input type="hidden" name="codigo_ibge_destino" id="codigo_ibge_destino" value="<%=(carregaconh ? conh.getCidadeDestino().getCod_ibge() : "")%>">
<input type="hidden" name="miliSegundos" id="miliSegundos" value=""><input type="hidden" name="cod_ibge" id="cod_ibge" value=""><input type="hidden" name="cfgPermitirLancamentoOSAbertoVeiculo"  id="cfgPermitirLancamentoOSAbertoVeiculo" value="<%=cfg.getPermitirLancamantoOSAbertoVeiculo()%>">
<%--St ICMS vindo do cliente--%>
<input type="hidden" name="st_icms" id="st_icms" value="0"><input type="hidden" name="stIcmsConfig" id="stIcmsConfig" value="0"><input type="hidden" name="layout" id="layout" value="0">
<%--Endereço do destinatario--%>
<input type="hidden" name="dest_cep" id="dest_cep" value=""><input type="hidden" name="dest_bairro" id="dest_bairro" value=""><input type="hidden" name="motivo_bloqueio" id="motivo_bloqueio"><input type="hidden" name="is_bloqueado" id="is_bloqueado">    
<input type="hidden" name="moto_veiculo_bloq_motivo" id="moto_veiculo_bloq_motivo"><input type="hidden" name="is_moto_veiculo_bloq" id="is_moto_veiculo_bloq"><input type="hidden" name="moto_carreta_bloq_motivo" id="moto_carreta_bloq_motivo"><input type="hidden" name="is_moto_carreta_bloq" id="is_moto_carreta_bloq">   
<input type="hidden" name="moto_bitrem_bloq_motivo" id="moto_bitrem_bloq_motivo"><input type="hidden" name="is_moto_bitrem_bloq" id="is_moto_bitrem_bloq"><input type="hidden" name="mensagem_usuario_cte" id="mensagem_usuario_cte" value="<%= carregaconh && conh.getCliente().getMsgClienteCte() != null ? conh.getCliente().getMsgClienteCte() : ""%>">
<input type="hidden" name="mensagem_usuario_cte_rem" id="mensagem_usuario_cte_rem" value="<%= carregaconh && conh.getRemetente().getMsgClienteCte() != null ? conh.getRemetente().getMsgClienteCte() : ""%>"><input type="hidden" name="mensagem_usuario_cte_des" id="mensagem_usuario_cte_des" value="<%= carregaconh && conh.getDestinatario().getMsgClienteCte() != null ? conh.getDestinatario().getMsgClienteCte() : ""%>">
<input type="hidden" name="mensagem_usuario_cte_con_orc" id="mensagem_usuario_cte_con_orc" value=""><input type="hidden" name="tipo_arredondamento_peso_rem" id="tipo_arredondamento_peso_rem" value="<%=(carregaconh  ? conh.getRemetente().getTipoArredondamentoPeso(): "n")%>">
<input type="hidden" name="tipo_arredondamento_peso_dest" id="tipo_arredondamento_peso_dest" value="<%=(carregaconh  ? conh.getDestinatario().getTipoArredondamentoPeso() : "n")%>"><input type="hidden" name="tipo_arredondamento_peso_con" id="tipo_arredondamento_peso_con" value="<%=(carregaconh  ? conh.getCliente().getTipoArredondamentoPeso() : "n")%>">
<input type="hidden" name="tipo_arredondamento_peso_red" id="tipo_arredondamento_peso_red" value="<%=(carregaconh  ? conh.getRedespacho().getTipoArredondamentoPeso() : "n")%>"><input type="hidden" name="id_tabela_preco_validade" id="id_tabela_preco_validade" value=""><input type="hidden" name="perm_altera_icms" id="perm_altera_icms" value=""><input type="hidden" name="obs_orcamento_hidden" id="obs_orcamento_hidden" value=""> 
<input type="hidden" name="isConfirmadoOutraAplicacao" id="isConfirmadoOutraAplicacao" value="<%=(carregaconh  ? conh.isIsConfirmadoOutraAplicacao() : false)%>"><input type="hidden" id="is_frete_dirigido" name="is_frete_dirigido" value="<%=( carregaconh ? conh.getRemetente().isFreteDirigido() : false )%>">
<input type="hidden" name="" id="st_rem_credito_presumido" value="<%=(carregaconh  ? conh.getRemetente().getPercentualCreditoPresumido() : "0,00")%>"> 
<input type="hidden" name="" id="st_des_credito_presumido" value="<%=(carregaconh  ? conh.getDestinatario().getPercentualCreditoPresumido() : "0,00")%>"> 
<input type="hidden" name="" id="st_cli_credito_presumido" value="<%=(carregaconh  ? conh.getCliente().getPercentualCreditoPresumido() : "0,00")%>"> 
<input type="hidden" name="" id="st_red_credito_presumido" value="<%=(carregaconh  ? conh.getRedespacho().getPercentualCreditoPresumido() : "0,00")%>"> 
<input type="hidden" name="" id="st_exp_credito_presumido" value="<%=(carregaconh  ? conh.getExpedidor().getPercentualCreditoPresumido() : "0,00")%>"> 
<input type="hidden" name="" id="st_rec_credito_presumido" value="<%=(carregaconh  ? conh.getRecebedor().getPercentualCreditoPresumido() : "0,00")%>">
<input type="hidden" name="" id="rem_is_in_gsf_1298_16_go" value="<%= (carregaconh ? conh.getRemetente().isUtilizarNormativaGSF129816GO() : "false" )%>">
<input type="hidden" name="" id="des_is_in_gsf_1298_16_go" value="<%= (carregaconh ? conh.getDestinatario().isUtilizarNormativaGSF129816GO() : "false" )%>">
<input type="hidden" name="" id="con_is_in_gsf_1298_16_go" value="<%= (carregaconh ? conh.getCliente().isUtilizarNormativaGSF129816GO() : "false" )%>">
<input type="hidden" name="" id="red_is_in_gsf_1298_16_go" value="<%= (carregaconh ? conh.getRedespacho().isUtilizarNormativaGSF129816GO() : "false" )%>">
<input type="hidden" name="is_retencao_impostos_operadora_cfe" id="is_retencao_impostos_operadora_cfe" value="<%=fi.isRetencaoImpostoOperadoraCFe()%>">
<input type="hidden" name="is_in_gsf_1298_16_go" id="is_in_gsf_1298_16_go" value="<%= (carregaconh ? conh.isUtilizarNormativaGSF129816GO() : "false") %>">
<input type="hidden" name="st_credito_presumido" id="st_credito_presumido" value="<%= (carregaconh ? conh.getPercentualCreditoPresumido() : "0,00") %>">
<input type="hidden" name="tipo_produto_destinatario_id" id="tipo_produto_destinatario_id" value="">
<input type="hidden" name="rem_tipo_tributacao" id="rem_tipo_tributacao" value="<%=(carregaconh ? conh.getRemetente().getTipoTributacao() : "") %>"><input type="hidden" name="dest_tipo_tributacao" id="dest_tipo_tributacao" value="<%=(carregaconh ? conh.getDestinatario().getTipoTributacao() : "") %>">
<input type="hidden" name="con_tipo_tributacao" id="con_tipo_tributacao" value="<%=(carregaconh ? conh.getConsignatario().getTipoTributacao() : "") %>"><input type="hidden" name="red_tipo_tributacao" id="red_tipo_tributacao" value="<%=(carregaconh ? conh.getRedespacho().getTipoTributacao() : "") %>">
<input type="hidden" id="rem_obs_fisco">
<input type="hidden" id="dest_obs_fisco">
<input type="hidden" id="con_obs_fisco">
<input type="hidden" id="obs_desc_fisco">
<input type="hidden" id="red_obs_fisco">
<input type="hidden" id="rem_is_especie_serie_modal"><input type="hidden" id="rem_especie_cliente"><input type="hidden" id="rem_serie_cliente"><input type="hidden" id="rem_modal_cliente">
<input type="hidden" id="dest_is_especie_serie_modal"><input type="hidden" id="dest_especie_cliente"><input type="hidden" id="dest_serie_cliente"><input type="hidden" id="dest_modal_cliente">
<input type="hidden" id="con_is_especie_serie_modal"><input type="hidden" id="con_especie_cliente"><input type="hidden" id="con_serie_cliente"><input type="hidden" id="con_modal_cliente">
<input type="hidden" id="red_is_especie_serie_modal"><input type="hidden" id="red_especie_cliente"><input type="hidden" id="red_serie_cliente"><input type="hidden" id="red_modal_cliente">
<input type="hidden" id="calculo_valor_contrato_frete" name="calculo_valor_contrato_frete" readonly="true">
<table width="94%" align="center" class="bordaFina">  <tr>
    <td width="570"><div align="left"><b>Conhecimento de Transporte (CT-e)</b></div></td>
    <td width="55" ><input type="button" class="botoes" style="display:<%=conh.getId() == 0 ? "none" : ""%>"value="Visualizar Auditoria" id="bt_auditoria" name="bt_auditoria"  onClick="javascript:abrirPopAuditoria();"></td>
    <td width="55" ><input type="button" class="botoes" style="display:<%=conh.isCancelado() ? "none" : ""%>" value="Importar XML/DANFE" id="bt_import" name="bt_import"  onClick="javascript:abrirPopImport();"></td>
    <% if ((acao.equals("editar")) && (nvUser >= 4) && (request.getParameter("ex") == null)){%>
	   <td width="59"><input name="excluir" style="display:<%=conh.isCancelado() ? "none" : ""%>" type="button"  class="botoes" id="excluir" value="Excluir" onClick="javascript:excluirconhecimento(<%=(carregaconh ? conh.getId() : 0)%>)"></td><%}%>
    <%if (acao.equals("iniciar")) {%><td width="59"><input name="reaproveitarCancelado" type="button" class="botoes" id="reaproveitarCancelado" value="Reaproveitar um CT cancelado" onClick="javascript:localizaCtrc(true);"></td><%}%>
    <td width="55" ><input type="button" class="botoes" value="Voltar para Consulta" id="bt_consultar" name="bt_consultar"  onClick="javascript:consulta();"></td>
  </tr>
</table><br>    
<table width="94%" align="center" class="bordaFina">
  <tr><td colspan="10" class="tabela"> <div align="center">Dados Principais do CT-e</div></td></tr>
  <tr style="display:<%=(carregaconh && conh.getDescricaoStatusCte() != null && !conh.getDescricaoStatusCte().equals(""))?"":"none"%>;">
      <td colspan="10" class="CelulaZebra2"><div align="center"><b><font size="3"><%=conh.getDescricaoStatusCte()%></font></b></div></td>
  </tr>
  <tr><td width="7%" class="TextoCampos">Filial:</td>
      <td width="13%" class="CelulaZebra2"><input name="fi_abreviatura" id="fi_abreviatura" type="text" size="9" style="font-size:8pt; clear:both;" readonly value="<%=(carregaconh ? fi.getAbreviatura() : (!acao.equals("")? Apoio.getUsuario(request).getFilial().getAbreviatura() : ""))%>" class="inputReadOnly8pt">
        <input type="hidden" id="sequencia_modal" name="sequencia_modal" value="<%=(carregaconh ? String.valueOf(fi.isSequenciaCtMultiModal()) : (!acao.equals("")? String.valueOf(Apoio.getUsuario(request).getFilial().isSequenciaCtMultiModal()) : "f"))%>">
        <%if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 2){%>
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();" <%=(conh.isQuitado() || conh.isCteBloqueado() ?"disabled":"")%>>
        <%}%></td><td width="7%" class="TextoCampos">CFOP:</td>
      <td width="10%" class="CelulaZebra2"><input name="cfop_ctrc" type="text" id="cfop_ctrc" size="3" maxlength="5" style="font-size:8pt;" class="inputReadOnly8pt" readonly value="<%=(carregaconh ? conh.getCfop().getCfop() : "")%>">
            <input name="localiza_cfop" type="button" class="botoes" id="localiza_cfop" value="..." onClick="javascript:localizacfop();" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
	    <input name="cfop_plano_custo_id" type="hidden" id="cfop_plano_custo_id" size="3" maxlength="5" style="font-size:8pt;" class="inputReadOnly8pt" readonly value="0"></td>
      <td width="11%" class="TextoCampos">Espécie / Série:</td><td width="10%" class="CelulaZebra2">
            <input name="especie" type="text" id="especie"
                   value="<%=(carregaconh ? conh.getEspecie() : (String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("H") || String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("P") || String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("R")  || String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("S") ? "CTE" : "CTR"))%>"
                   onChange="this.value=this.value.toUpperCase(); tryRequestToServer(function(){nextCtrc()});" size="2" maxlength="3" style="font-size:8pt;" <%=(nvAltCt == 0 ?"readonly":"")%> <%=(conh.isQuitado() || conh.isCteBloqueado() ?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>" >
            /<input name="serie" type="text" id="serie" value="<%=(carregaconh? conh.getSerie() : ((Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()== 'H' || Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()== 'P')|| String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("R")  || String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()).equals("S") ? "1" : cfg.getSeriePadraoCtrc()))%>" size="2" onChange="this.value=this.value.toUpperCase();" onBlur="getObj('rem_rzs').focus();escondeCTeCancelar(null);tryRequestToServer(function(){nextCtrc()});" maxlength="3" style="font-size:8pt;" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">
      </td><td width="7%" class="TextoCampos">Emissão:</td>
      <td width="15%" class="CelulaZebra2"><input name="dtemissao" type="text" id="dtemissao" value="<%=(carregaconh ? Apoio.fmt(conh.getEmissaoEm()) : Apoio.getDataAtual())%>" style="font-size:8pt;" class="fieldDate" onBlur="javascript:if (alertInvalidDate(this)) parent.frameAbaixo.refazerDtsVenc();" size="9" maxlength="10" <%=(nvAltCt == 0 ?"readonly":"")%>>
            <input name="hremissao" type="text" id="hremissao" value="<%=(carregaconh ? formatTime.format(conh.getEmissao_as()) : "")%>" style="font-size:8pt;" class="inputReadOnly" readOnly size="3" maxlength="5" <%=(nvAltCt == 0 ?"readonly":"")%>></td>
      <td width="10%" rowspan="2" class="TextoCampos"><b><font size="2">Número CT:<br><label id="lbSelo" name="lbSelo">Nº Selo:</label></font></b></td>
      <td width="10%" rowspan="2" class="CelulaZebra2"><input name="nfiscal" type="text" id="nfiscal" style="font-size:11pt;" onChange="javascript:seNaoIntReset(this,'0');$('descricao_historico').value = 'Frete CTRC: ' + $('nfiscal').value" value="<%=(carregaconh ? conh.getNumero() : nfiscal)%>" size="6" maxlength="6" <%=(nvAltCt == 0 || conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"inputtexto")%>"><br>
	<input name="numero_selo" type="text" id="numero_selo" style="font-size:8pt;" onChange="javascript:seNaoIntReset(this,'0');" value="<%=(carregaconh ? conh.getNumeroSelo() : nSelo)%>" size="10" maxlength="10" <%=(nvAltCt == 0 || conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">
        <input type="hidden"  id="is_controla_sequencia_selo" name="is_controla_sequencia_selo"  value="<%=(carregaconh? conh.getFilial().isControlaSequenciaSelo() : Apoio.getUsuario(request).getFilial().isControlaSequenciaSelo()) %>"  size="5"/></td>
  </tr><tr><td class="TextoCampos">Agência:</td>
      <td class="CelulaZebra2"><input type="text" size="9"  id="ag_abreviatura" name="ag_abreviatura" readonly="readonly" class="inputReadOnly" style=""
	           value="<%=Apoio.coalesce((carregaconh? conh.getAgencia().getAbreviatura() : Apoio.getUsuario(request).getAgencia().getAbreviatura()),"")%>" />
            <input type="hidden"  id="agency_id" name="agency_id"  value="<%=(carregaconh? conh.getAgencia().getId() : Apoio.getUsuario(request).getAgencia().getId()) %>" /></td>
      <td class="TextoCampos"><div align="center"><select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:50px;" onChange="alteraTipoTransporte();modalAlterarTipoTranporte();getDadosIcms();atribuiVlrsDaTaxa(true, $('tipotaxa').value);recalcular(false);"
                  <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>  class="fieldMin">
                  <!--acrescentei as duas funções para carregar getDados e recalcular-->
            <%= emiteRodoviario ? "<option value='r' >CTR - Transp. Rodoviário</option>" : ""  %>
            <%= emiteAereo ? "<option value='a' >CTA - Transp. A&eacute;reo</option>" : ""  %>
            <%= emiteAquaviario ? "<option value='q' >CTQ - Transp. Aquavi&aacute;rio</option>" : ""  %>
          </select></div></td>
      <td class="TextoCampos" ><div align="center"><select name="modalConhecimento" onchange="definirComissaoVendedor();" 
        class="fieldMin" id="modalConhecimento" style="font-size:8pt;" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
          <option value="f" selected>Fracionado</option>
          <option value="l">Lotação</option></select></div></td>
      <td class="TextoCampos">Tipo:</td>
      <td class="CelulaZebra2"><select name="tipoConhecimento" id="tipoConhecimento" style="font-size:8pt;width:75px;" onChange="javascript:alteraTipoConhecimento();minutaCortesia();" class="fieldMin" <%=(conh.isQuitado() ?" disabled":"")%>>
				<option value="n" selected>Normal</option><option value="l">Entrega Local (Cobrança)</option>
				<option value="i">Diárias</option><option value="p">Pallets</option> <option value="c">Complementar</option><option value="r">Reentrega</option>
				<option value="d">Devolução</option><option value="b">Cortesia</option> <option value="s">Substituição</option><option value="a">Anulação</option>
                                <option value="t" id="subs" name="subs" style="display: none">Substituído</option></select>
			<input name="id_dev_reen" type="hidden" id="id_dev_reen" value="<%=(carregaconh ? conh.getVendaAproveitada().getId() : 0)%>">
                        <input name="id_ctrcs_sub" type="hidden" id="id_ctrcs_sub" value="<%=(carregaconh ? conh.getVendaSubstituido().getId() : 0)%>">
                        <input name="id_ctrcs_anulado" type="hidden" id="id_ctrcs_anulado" value="<%=(carregaconh ? conh.getVendaAnulada().getId() : 0)%>">
			<input name="localiza_ctrc" type="button" class="botoes" id="localiza_ctrc" value="..." onClick="javascript:localizaCtrc(false);" style="font-size:8pt;display:none;">
			<%if (acao.equals("editar")){
				if (nvVenda > 0 && conh.getNotaFiscalDistribuicao().getCategoria().equals("NFS")){%>
                                    <br><label id="lbNFDistribuicao2" name="lbNFDistribuicao2"><%=(carregaconh && (conh.getNotaFiscalDistribuicao().getId() != 0) ? conh.getNotaFiscalDistribuicao().getCategoria() : "")%> Cobrança:</label><label id="lbNFDistribuicao" name="lbNFDistribuicao" onclick="window.open('./cadvenda.jsp?acao=editar&id=<%=conh.getNotaFiscalDistribuicao().getId()%>&ex=false', 'NFS' , 'top=0,resizable=yes,status=1,scrollbars=1')" class="linkEditar"><%=(carregaconh && (conh.getNotaFiscalDistribuicao().getId() != 0) ? conh.getNotaFiscalDistribuicao().getNumero() : "")%></label>
				<%}else if (nvUser > 0 && conh.getNotaFiscalDistribuicao().getCategoria().equals("CT-e")){%>
                                    <br><label id="lbNFDistribuicao2" name="lbNFDistribuicao2"><%=(carregaconh && (conh.getNotaFiscalDistribuicao().getId() != 0) ? conh.getNotaFiscalDistribuicao().getCategoria() : "")%> Cobrança:</label><label id="lbNFDistribuicao" name="lbNFDistribuicao" onclick="window.open('./frameset_conhecimento?acao=editar&id=<%=conh.getNotaFiscalDistribuicao().getId()%>&ex=false', 'AWB' , 'top=0,resizable=yes,status=1,scrollbars=1')" class="linkEditar"><%=(carregaconh && (conh.getNotaFiscalDistribuicao().getId() != 0) ? conh.getNotaFiscalDistribuicao().getNumero() : "")%></label>
				<%}else{%>
                                    <br><label id="lbNFDistribuicao2" name="lbNFDistribuicao2"><%=(carregaconh && (conh.getNotaFiscalDistribuicao().getId() != 0) ? conh.getNotaFiscalDistribuicao().getCategoria() : "")%> Cobrança:</label><label id="lbNFDistribuicao" name="lbNFDistribuicao"><%=(carregaconh && (conh.getNotaFiscalDistribuicao().getId() != 0) ? conh.getNotaFiscalDistribuicao().getNumero() : "")%></label>
				<%}%>
				<label id="lbNFAproveitada" name="lbNFAproveitada"><%=(carregaconh && (conh.getVendaAproveitada().getId() != 0) ? "CT-E Copiado:"+conh.getVendaAproveitada().getNumero() + "-" + conh.getVendaAproveitada().getSerie() : "")%></label>
			<%}else{%>
				<label id="lbNFDistribuicao2" name="lbNFDistribuicao2"></label>
				<label id="lbNFDistribuicao" name="lbNFDistribuicao"></label>
				<label id="lbNFAproveitada" name="lbNFAproveitada"></label>
			<%}%></td>
      <td class="TextoCampos">Tipo Serviço:</td>
      <td class="CelulaZebra2"><select name="tipoServico" id="tipoServico" style="font-size:8pt;width:120px;" class="fieldMin" onchange="javascript:atribuiCfopPadrao();"  <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>>
              <option value="n" selected>Normal</option><option value="s">SubContratação</option> <option value="r">Redespacho</option><option value="i">Redespacho Intermediário</option>
              <option value="m">Serviço Vinculado a Multimodal</option></select></td></tr>
  <tr><td class="TextoCampos" colspan="2"><div id="mostrarCancelado" name="mostrarCancelado" align="center" style="display: none"><b><input name="cancelado" type="checkbox" id="cancelado" value="true" <%=(conh.isCancelado()? " checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%> onclick="escondeMostraCancelamento(this.checked)">
          CT cancelado</b></div></td>
      <td class="TextoCampos"><label id="lbTitleCancelado" name="lbTitleCancelado">Motivo:</label></td>
      <td class="CelulaZebra2" colspan="5"><textarea name="motivoCancelamento" id="motivoCancelamento" class="inputtexto" style="width:450px"><%=conh.getMotivoCancelamento()%></textarea></td>
      <td class="TextoCampos"><label id="lbDataCancelado" name="lbDataCancelado">Cancelado em:</label></td>
      <td class="CelulaZebra2"><label id="dataCancelado" name="dataCancelado"><%=(carregaconh && conh.getCanceladoEm() != null ? formatDate.format(conh.getCanceladoEm()) : "")%></label></td>
  </tr>
</table>
<table width="94%" align="center">
    <tr><td width="12%" class="menu" id="tdInfoConhecimento" onClick="AlternarAbas('tdInfoConhecimento','divInfoConhecimento')">Dados Principais</td>
        <td width="12%" class="menu" id="tdEntradaCategoria" onClick="AlternarAbas('tdEntradaCategoria','divEntradaCategoria')">Dados da Entrada da Carga</td>
        <td width="12%" class="menu" id="tdInfoContainer" onClick="AlternarAbas('tdInfoContainer','divInfoContainer')"> Container/Importação</td>
        <td width="12%" class="menu" id="tdInfoCTE" onClick="AlternarAbas('tdInfoCTE','divInfoCTE')">Dados do CT-e</td>
        <td width="14%" class="menu" id="tdInfoGM" onClick="AlternarAbas('tdInfoGM','divInfoGM')">Dados da Entrega (Ocorrências)</td>
        <td width="12%" class="menu" id="tdInfoCusto" onClick="AlternarAbas('tdInfoCusto','divInfoCusto')">Custos</td>
        <td width="12%" class="menu" id="tdMinCobradas" onClick="AlternarAbas('tdMinCobradas','divMinCobradas')">Minuta(s) Cobradas</td>
        <td width="16%"></td></tr></table>
<div id="divInfoConhecimento">
        <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td class="tabela" colspan="8"><div align="center">Dados da Coleta/Orçamento</div></td></tr>    
            <tr><td width="9%" class="TextoCampos">Nº Coleta:</td>
                <td width="16%" class="CelulaZebra2"><label id="numcoleta"></label> 
                    <strong>&nbsp;<b><%=(conh.getColeta().getNumero() == null? "&nbsp;" : conh.getColeta().getNumero())%></b>&nbsp;&nbsp;</strong>
                    <input name="localiza_coleta" type="button" class="botoes" id="localiza_coleta" value="..." onClick="javascript:(getNotes(0)==''?launchPopupLocate('./localiza_coleta.jsp?idfilial='+$('idfilial').value, 'Coleta'):alert('Inclusão/Alteração da coleta não permitida, pois já existe, no mínimo, 1 nota fiscal lançada.'));" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
                    <img src="img/borracha.gif" border="0" class="imagemLink" onClick="(getNotes(0)==''?limpaColeta():alert('Alteração da coleta não permitida, pois já existe, no mínimo, 1 nota fiscal lançada.'));">
                </td>
                <td width="9%" class="TextoCampos">Orçamento:</td>
                <td width="16%" class="CelulaZebra2"><input type="text" name="numero_orcamento" id="numero_orcamento" value="<%=(carregaconh ? conh.getOrcamento().getNumero():"")%>" size="10" class="inputReadOnly" style="font-size:8pt;" readonly="readonly" />
                    <input type="hidden" id="orcamento_id" name="orcamento_id" value="<%=(carregaconh ? conh.getOrcamento().getId():0)%>">
                    <input type="hidden" id="peso_orcamento" name="peso_orcamento" value="<%=(carregaconh ? conh.getOrcamento().getPeso():0)%>">
                    <input type="hidden" id="volume_orcamento" name="volume_orcamento" value="<%=(carregaconh ? conh.getOrcamento().getVolume():0)%>">
                    <input type="hidden" id="mercadoria_orcamento" name="mercadoria_orcamento" value="<%=(carregaconh ? conh.getOrcamento().getVlMercadorias():0)%>">
                    <input type="hidden" id="cubagem_orcamento" name="cubagem_orcamento" value="<%=(carregaconh ? conh.getOrcamento().getCubagemMetro():0)%>"></td>
                <td width="9%" class="TextoCampos">Nº Pedido:</td>
                <td width="16%" class="CelulaZebra2"><input name="pedido_cliente" type="text" id="pedido_cliente" value="<%=(carregaconh ? conh.getPedidoCliente():"")%>" style="font-size:8pt;" size="10" maxlength="20" class="fieldMin"></td>
                <td width="9%" class="TextoCampos">Nº Carga:</td>
                <td width="16%" class="CelulaZebra2">
                    <input name="numeroCarga" type="text" id="numeroCarga" value="<%=(carregaconh ? conh.getNumeroCarga():"")%>" style="font-size:8pt;" size="10" maxlength="20" class="fieldMin">
                    <input name="numero_carga_col" type="hidden" id="numero_carga_col" value="" style="font-size:8pt;" >
                </td></tr>
            <tr><td class="TextoCampos">Local Coleta:</td>
                <td class="CelulaZebra2"><input name="coleta" type="text" id="coleta" size="20" maxlength="50" style="font-size:8pt;" value="<%=(conh.getLocalColeta() == null? "" : conh.getLocalColeta())%>" class="fieldMin"></td>
                <td class="TextoCampos">Local Entrega:</td>
                <td class="CelulaZebra2"><input name="entrega" type="text" id="entrega" size="20" maxlength="30" style="font-size:8pt;" value="<%=conh.getEntrega()%>" class="fieldMin"></td>
                <td class="TextoCampos">Calculado Até:</td>
                <td class="CelulaZebra2"><input name="calculadoate" type="text" id="calculadoate" value="<%=(carregaconh ? conh.getCalculadoAte():"")%>" style="font-size:8pt;" size="20" maxlength="30" class="fieldMin"></td>
                <td class="TextoCampos" colspan="2">
                    <div align="center"><input type="hidden" name="is_urbano" id="is_urbano" value="false">
                        <input type="checkbox" name="is_urbano2" id="is_urbano2" <%=(carregaconh && conh.isUrbano()? "checked" : "")%>> Entrega Urbana
                        <input name="taxa_roubo" type="hidden" id="taxa_roubo"  value="<%=(carregaconh ? conh.getTaxaSeguroRoubo() : 0)%>" class="inputReadOnly8pt" size="4" maxlength="12">
                        <input name="taxa_roubo_urbano" type="hidden" id="taxa_roubo_urbano"  value="<%=(carregaconh ? conh.getTaxaSeguroRouboUrbano() : 0)%>" class="inputReadOnly8pt" size="4" maxlength="12">
                        <input name="taxa_tombamento" type="hidden" id="taxa_tombamento"  value="<%=(carregaconh ? conh.getTaxaSeguroTombamento() : 0)%>" class="inputReadOnly8pt" size="4" maxlength="12">
                        <input name="taxa_tombamento_urbano" type="hidden" id="taxa_tombamento_urbano"  value="<%=(carregaconh ? conh.getTaxaSeguroTombamentoUrbano() : 0)%>" class="inputReadOnly8pt" size="4" maxlength="12">
                    </div></td></tr></table>
        <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td width="50%"><table width="100%" border="0" cellpadding="0" cellspacing="1">
                        <tr class="Celula"><td colspan="4"><div align="center">Remetente</div></td></tr>
                        <tr class="CelulaZebra2">
                  		<td class="CelulaZebra2"><div align="right">R.Social:</div></td>
				<td colspan="3" class="CelulaZebra2"><input name="rem_codigo" type="text" id="rem_codigo" size="4" value="<%=(carregaconh ? String.valueOf(rem.getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('idcliente', this.value)" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="fieldMin">
                  			<input name="rem_rzs" type="text" id="rem_rzs" size="40" value="<%=(carregaconh ? rem.getRazaosocial() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('c.razaosocial', this.value)" onFocus="this.select();" class="inputReadOnly8pt">
                                        <strong><input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaremetente();" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
                                        </strong>
                                        <input type="hidden" id="tipoPadraoDocumento" value="<%= carregaconh ? rem.getTipoDocumentoPadrao() : "NE" %>">
                                        <%if (nvCli > 0){%>
                                            <img src="img/page_edit.png" border="0" onClick="javascript:verClienteCtrc('R');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                        <%} %>
					<input type="hidden" name="pauta_remetente" id="pauta_remetente" value="<%=(carregaconh ? String.valueOf(rem.isUtilizaPautaFiscal()) : "f")%>">
					<input type="hidden" name="rem_st_mg" id="rem_st_mg" value="<%=(carregaconh ? String.valueOf(rem.isSubstituicaoTributariaMinasGerais()) : "f")%>">
					<input type="hidden" name="rem_inclui_peso_container" id="rem_inclui_peso_container" value="<%=(carregaconh ? String.valueOf(rem.isIncluiContainerFretePeso()) : "f")%>">
					<input type="hidden"  id="rem_tipo_cfop" name="rem_tipo_cfop"  value="<%=(carregaconh ? rem.getTipoCfop() : "c")%>"/>
				</td></tr>
                        <tr class="CelulaZebra2" style="display:<%=cfg.isMostraEnderecoClienteCtrc()?"":"none"%>">
                            <td class="CelulaZebra2"><div align="right">Endere&ccedil;o:</div></td>
                            <td colspan="3" class="CelulaZebra2"><input name="rem_endereco" type="text" id="rem_endereco" size="65"  class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? rem.getEndereco() : "")%>">
                                <input name="localiza_endereco_coleta" type="button" class="botoes" id="localiza_endereco_coleta" value="..." onClick="javascript:localizaEnderecoColeta();" <%=(conh.isQuitado() || conh.isCteBloqueado() ?"disabled":"")%>>
                                <input type="hidden" name="rem_endereco_completo" id="rem_endereco_completo">
                            </td></tr>
                        <tr class="CelulaZebra2">
                            <td width="13%" class="CelulaZebra2"><div align="right">Cidade:</div></td>
                            <td width="45%" class="CelulaZebra2"><input name="rem_cidade" type="text" id="rem_cidade" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? rem.getCidade().getDescricaoCidade() : "")%>">
                                <input name="rem_uf" type="text" id="rem_uf" size="1" readonly value="<%=(carregaconh ? rem.getCidade().getUf() : "")%>" class="inputReadOnly8pt"></td>
                            <td width="9%" class="TextoCampos">CNPJ:</td>
                            <td width="33%" class="CelulaZebra2"><input name="rem_cnpj" type="text" id="rem_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaconh ? rem.getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj',this.value)"><input name="rem_insc_est" type="hidden" id="rem_insc_est" size="20" class="inputReadOnly8pt" value="<%=(carregaconh ? rem.getInscest() : "")%>" >IE:<label id="lbRemetenteIE" name="lbRemetenteIE"><%=(rem != null ? rem.getInscest() : "")%></label></td>
                        </tr></table></td>
                <td width="50%"><table border="0" cellpadding="0" cellspacing="1" width="100%">
                        <tr class="Celula"><td colspan="4"><div align="center">Destinat&aacute;rio</div></td></tr>
                        <tr class="CelulaZebra2">
                        <td class="CelulaZebra2"><div align="right">R.Social:</div></td>
                            <td colspan="3" class="CelulaZebra2"><input name="des_codigo" type="text" id="des_codigo" size="4" value="<%=(carregaconh ? String.valueOf(des.getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('idcliente', this.value)" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="fieldMin">
                                <input name="dest_rzs" type="text" id="dest_rzs" size="40" value="<%=(carregaconh ? des.getRazaosocial() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('c.razaosocial', this.value)" onFocus="this.select();" class="inputReadOnly8pt">
                                <input type="hidden" name="pauta_destinatario" id="pauta_destinatario" value="<%=(carregaconh ? String.valueOf(des.isUtilizaPautaFiscal()) : "f")%>">
                                <strong>
                                <input name="localiza_dest" type="button" class="botoes" id="localiza_dest" value="..." onClick="javascript:localizadestinatario();" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
                                <input type="hidden"  id="des_inclui_tde" name="des_inclui_tde"  value="f"/>
                                <input type="hidden"  id="des_tipo_cfop" name="des_tipo_cfop"  value="<%=(carregaconh ? des.getTipoCfop() : "c")%>"/>
                                <input type="hidden" name="des_inclui_peso_container" id="des_inclui_peso_container" value="<%=(carregaconh ? String.valueOf(des.isIncluiContainerFretePeso()) : "f")%>">
                                <%if (nvCli > 0){%>
                                    <img src="img/page_edit.png" border="0" onClick="javascript:verClienteCtrc('D');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "> </strong>
                                <%} %>
                                <% if (carregaconh && isAtivaDivisaoIcmsUFDestino) { %>
                                    <label><b>Consumidor Final: <% if (conh.isDestinatarioConsumidorFinal()) {%> SIM <%}else{%> NÃO</b></label> <%}%> 
                                <%}%>
                            </td>
                        </tr>
                    <tr class="CelulaZebra2" style="display:<%=cfg.isMostraEnderecoClienteCtrc()?"":"none"%>">
                        <td class="CelulaZebra2"><div align="right">Endere&ccedil;o:</div></td>
                        <td colspan="3" class="CelulaZebra2"><input name="dest_endereco" type="text" id="dest_endereco" size="65" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? des.getEndereco() : "")%>">
                            <input name="localiza_endereco" type="button" class="botoes" id="localiza_endereco" value="..." onClick="javascript:localizaEndereco();" <%=(conh.isQuitado() || conh.isCteBloqueado() ?"disabled":"")%>>
                            <input type="hidden" name="dest_endereco_completo" id="dest_endereco_completo"></td></tr>
                    <tr class="CelulaZebra2">
                        <td width="13%" class="CelulaZebra2"><div align="right">Cidade:</div></td>
                        <td width="45%" class="CelulaZebra2"><input name="dest_cidade" type="text" id="dest_cidade" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? des.getCidade().getDescricaoCidade() : "")%>">
                            <input name="dest_uf" type="text" id="dest_uf" size="1" class="inputReadOnly8pt" readonly value="<%=(carregaconh ? des.getCidade().getUf() : "")%>"></td>
                        <td width="9%" class="TextoCampos">CNPJ:</td>
                        <td width="33%" class="CelulaZebra2"><input name="dest_cnpj" type="text" id="dest_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaconh ? des.getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaDestinatarioCodigo('cnpj', this.value)">
                            <input name="dest_insc_est" type="hidden" id="dest_insc_est" size="20" class="inputReadOnly8pt" value="<%=(carregaconh ? des.getInscest() : "")%>" >IE:<label id="lbDestinatarioIE" name="lbDestinatarioIE"><%=(des!= null ? des.getInscest() : "")%></label></td>
                    </tr></table></td></tr>
            <tr><td style="vertical-align: top"><table width="100%" border="0" height="41%" cellpadding="0" cellspacing="1">
                        <tr class="Celula"><td colspan="4"> <div align="center">Tomador do Serviço (Consignat&aacute;rio)</div></td></tr>
                        <tr>
                            <td class="CelulaZebra2"><div align="right">Frete:</div></td>
                            <td class="CelulaZebra2"><label><input name="fretepago_sim" id="fretepago_sim" type="radio" value="sim" onClick="javascript:setFretePago(true);atribuiCfopPadrao();"
		                <%=(carregaconh && conh.isPago() ? " checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>>
                                <font size="1">CIF [F4] </font></label>
                                <label><input id="fretepago_nao" name="fretepago_nao" type="radio" value="nao" onClick="javascript:setFretePago(false);atribuiCfopPadrao();"
    		                <%=(carregaconh && !conh.isPago() ? " checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>>
                                <font size="1">FOB [F7] </font></label></td>
                            <td class="CelulaZebra2"><div align="right">Pagto:</div></td>
                            <td class="CelulaZebra2"><input type="hidden" name="pauta_consignatario" id="pauta_consignatario" value="<%=(carregaconh ? String.valueOf(con.isUtilizaPautaFiscal()) : "f")%>">
				<input type="hidden" name="con_inclui_peso_container" id="con_inclui_peso_container" value="<%=(carregaconh ? String.valueOf(con.isIncluiContainerFretePeso()) : "f")%>">
				<input type="hidden"  id="con_tipo_cfop" name="con_tipo_cfop"  value="<%=(carregaconh ? con.getTipoCfop() : "c")%>"/>
                                <select name="tipofpag" id="tipofpag" class="fieldMin" onChange="javascript:pagtoAvista();" <%=(nvFinCli == 4 ? "":" disabled ") %> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled":"")%>>
                                    <option value="v">&Agrave; vista</option>
                                    <option value="p" selected>&Agrave; prazo</option>
                                    <option value="c">Conta Corrente</option>
                                </select></td></tr>
                        <tr id="trFilialRecebedora" name="trFilialRecebedora" class="CelulaZebra2">
                            <td colspan="2" class="CelulaZebra2"><div align="right">Filial respons&aacute;vel pelo recebimento:</div>            </td>
                            <td colspan="2" class="CelulaZebra2">
                            <select name="filialRecebedora" id="filialRecebedora" class="fieldMin" onChange="">
                                <%if(!carregaconh){%>
                                    <option value="0">Selecione</option>
                                <%}%>
                            <%BeanFilial fl = new BeanFilial();
                            int qtdFiliais = 0;
                            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                            while (rsFl.next()){
                                qtdFiliais = rsFl.getInt("qtd_filiais");%>
                                  <option value="<%=rsFl.getString("idfilial")%>" <%=(carregaconh ? (conh.getFilialRecebedora().getIdfilial()==rsFl.getInt("idfilial")?"selected":"") : (xFilialUsuario == rsFl.getInt("idfilial") ? "selected":""))%> ><%=rsFl.getString("abreviatura")%></option>
                            <%} %>
                            </select><input type="hidden" name="qtdFiliais" id="qtdFiliais" value="<%=qtdFiliais%>"></td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td class="CelulaZebra2"><div align="right">R.Social:</div></td>
                            <td colspan="3" class="CelulaZebra2"><input name="con_codigo" type="text" id="con_codigo" size="4" class="fieldMin" value="<%=(carregaconh ? String.valueOf(con.getIdcliente()) : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('idcliente', this.value)" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="fieldMin">
                                <input name="con_rzs" type="text" id="con_rzs" size="40" class="inputReadOnly8pt" value="<%=(carregaconh ? con.getRazaosocial() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('c.razaosocial', this.value)" onFocus="this.select();">
                                <strong>
                                <input name="localiza_con" type="button" class="botoes" id="localiza_con" value="..." onClick="javascript:localizaconsignatario();" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
                                <%if (nvCli > 0){%>
                                <img src="img/page_edit.png" border="0" onClick="javascript:verClienteCtrc('C');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "> </strong>
                                <%} %>
                            </td>
                        </tr>
                        <tr><td width="13%" class="CelulaZebra2"><div align="right">Cidade:</div></td>
                            <td width="45%" class="CelulaZebra2"><input name="con_cidade" type="text" id="con_cidade" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? con.getCidade().getDescricaoCidade() : "")%>">
                                <input name="con_uf" type="text" id="con_uf" size="1" class="inputReadOnly8pt" readonly value="<%=(carregaconh ? con.getCidade().getUf() : "")%>"></td>
                            <td width="9%" class="TextoCampos">CNPJ:</td>
                            <td width="33%" class="CelulaZebra2"><input name="con_cnpj" type="text" id="con_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaconh ? con.getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaConsignatarioCodigo('cnpj', this.value)">IE: <label id="con_insc_est" name="con_insc_est"><%=(con != null ? con.getInscest() : "")%></label></td>
                        </tr>
                        <tr id="trConsigVazia" name="trConsigVazia"><td colspan="4" class="CelulaZebra2">&nbsp;</td></tr>
                    </table>
                </td>
                <td><table width="100%" height="100%" border="0" cellpadding="0" cellspacing="1">
                        <tr class="Celula"><td colspan="8"><div align="center"><label>Redespacho</label></div></td></tr>
                        <tr>
                            <td class="CelulaZebra2" colspan="4">
                                <input name="ck_redespacho" type="checkbox" id="ck_redespacho" onClick="javascript:redespacho(this.checked,true);" <%=(carregaconh && red != null? "checked" : "")%>>
                                Redespacho:
                                CT:<input name="ctoredespacho" type="text" disabled id="ctoredespacho" style="background-color:#EEEEEE;" class="fieldMin" size="7" maxlength="9" value="<%=(carregaconh? conh.getRedespachoCtrc() : "")%>">
                                Valor:<input name="redespacho_valor" id="redespacho_valor" type="text" disabled style="background-color:#EEEEEE;" class="fieldMin" size="9" value="<%=(carregaconh? Apoio.to_curr(conh.getRedespachoValor()) : "0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');">
                                R$ ICMS:<input name="redespacho_valor_icms" id="redespacho_valor_icms" type="text" disabled style="background-color:#EEEEEE;" class="fieldMin" size="6" value="<%=(carregaconh? Apoio.to_curr(conh.getRedespachoValorIcms()) : "0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');">
                                <input name="tiporedesp" id="exp" type="radio" value="exp" checked onclick="javascript:validarCidadeOrigemExpedidorRedespacho(true);preencheRedespacho();">Exped.
                                <input name="tiporedesp" id="rec" type="radio" value="rec" onclick="javascript:validarCidadeDestinoRecebedorRedespacho(true);preencheRedespacho();">Receb.
                                <select id="tpDocAnt" style="width:50px;" class="fieldMin" onchange="javascript:tipoDocAnt(this.value)">
                                    <option value="c">CT-e (DACTE)</option> 
                                    <option value="p">Formulário Contínuo</option>                                                                                                     
                                </select></td></tr>
                        <tr id="trChaveRedesp" style="display: none;"><td colspan="3" class="CelulaZebra2">Chave de acesso do CT-e Expedidor:<input name="red_chave_acesso" type="text" id="red_chave_acesso" size="44" maxlength="44" class="fieldMin" value="<%=(carregaconh ? (red != null ? red.getCnpj() : "") : "")%>" onKeyUp="javascript:if (event.keyCode==13)"></td>
                            <td  class="CelulaZebra2" style="text-align: center">
                                <img src="img/add.gif" class="imagemLink" onclick="montarDivChaveAcesso()" align="left">
                                    <b><label id="lblChavesAcesso" align="center" name="lblChavesAcesso" style="text-align: right"></label></b>
                                <input type="hidden" id="maxChavesAcesso" name="maxChavesAcesso"><input type="hidden" id="chaveAcessoExtraAll" name="chaveAcessoExtraAll" value="">
                            </td></tr>
                        <tr>
                        <tr id="trOutrosAnt" style="display: none;"> 
                                <td colspan="4" class="CelulaZebra2">Tipo Doc.:<select id="tipoDocRed" name="tipoDocRed" style="width:80px;" class="fieldMin">
                                        <option value="00">CTRC</option><option value="01">CTAC</option>
                                        <option value="02">ACT</option><option value="03">NF Modelo 7</option>
                                        <option value="04">NF Modelo 27</option><option value="05">Conhecimento Aéreo Nacional</option> 
                                        <option value="06">CTMC</option><option value="07">ATRE</option> 
                                        <option value="08">DTA (Despacho de Transito Aduaneiro)</option><option value="09">Conhecimento Aéreo Internacional</option> 
                                        <option value="10">Conhecimento - Carta de Porte Internacional</option><option value="11">Conhecimento Avulso</option> 
                                        <option value="12">TIF (Transporte Internacional Ferroviário)</option><option value="99">Outros</option>
                                    </select>                                
                                    &nbsp;Série:<input name="red_serie" type="text" id="red_serie" size="5" class="fieldMin">
                                    &nbsp;Sub-Série:<input name="red_subserie" type="text" id="red_subserie" size="5" class="fieldMin">
                                    &nbsp;Emissão:<input name="red_dtemissao" type="text" id="red_dtemissao" size="10" style="font-size:8pt;" class="fieldDate"  onBlur="javascript:if (alertInvalidDate(this)) parent.frameAbaixo.refazerDtsVenc();" size="9" maxlength="10" ></td>
                        </tr>                                                                        
                        <tr><td class="CelulaZebra2"><div align="right">R.Social:</div></td>
                            <td colspan="3" class="CelulaZebra2"><input name="red_codigo"  type="text" id="red_codigo" size="4" onblur ="javascript:preencheRedespacho();" style="background-color:#FFFFF1;" class="fieldMin" value="<%=(carregaconh ? (red != null ? String.valueOf(red.getIdcliente()) : "") : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRedespachoCodigo('idcliente', this.value)">
                                <input type="hidden"  id="red_tipo_cfop" name="red_tipo_cfop"  value="<%=(carregaconh && red != null ? red.getTipoCfop() : "c")%>"/>
                                <input name="red_rzs" type="text" id="red_rzs"  size="40" class="inputReadOnly8pt" value="<%=(carregaconh ? (red != null ? red.getRazaosocial() : ""): "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRedespachoCodigo('c.razaosocial', this.value)" onFocus="this.select();" onblur ="javascript:preencheRedespacho();">
                                <input type="hidden" name="pauta_redespacho" id="pauta_redespacho" value="<%=(carregaconh && red != null ? String.valueOf(red.isUtilizaPautaFiscal()) : "f")%>">
                                <input type="hidden" name="red_inclui_peso_container" id="red_inclui_peso_container" value="<%=(carregaconh && red != null ? String.valueOf(red.isIncluiContainerFretePeso()) : "f")%>">
                                <strong>
                                <input name="localiza_red" type="button" class="botoes" id="localiza_red" value="..." disabled onClick="javascript:localizaredespacho();" >
                                <%if (nvCli > 0){%>
                                <img src="img/page_edit.png" border="0" onClick="javascript:verClienteCtrc('RD');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "> </strong>
                                <%} %>
                                <input type="checkbox" name="is_redespacho_pago" id="is_redespacho_pago" onClick="javascript:pagouRedespacho(this.checked);" disabled <%=(carregaconh && conh.isRedespachoPago()? "checked" : "")%>>
                                Tomador do Serviço</td>
                        </tr>
                        <tr><td width="13%" class="TextoCampos">Cidade:</td>
                            <td width="45%" class="CelulaZebra2"><input name="red_cidade" type="text" id="red_cidade" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? (red != null ? red.getCidade().getDescricaoCidade() : "") : "")%>">
                                <input name="red_uf" type="text" id="red_uf" size="1" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? (red != null ? red.getCidade().getUf() : "") : "")%>"></td>
                            <td width="9%" class="TextoCampos">CNPJ:</td>
                            <td width="33%" class="CelulaZebra2"><input name="red_cnpj" type="text" id="red_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaconh ? (red != null ? red.getCnpj() : "") : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRedespachoCodigo('cnpj', this.value)" onblur ="javascript:preencheRedespacho();">IE:<label id="red_insc_est" name="red_insc_est"><%=(red != null ? red.getInscest() : "")%></label></td>
                        </tr>                            
                        <tr id="trRedespachoVazia" name="trRedespachoVazia"><td colspan="4" class="CelulaZebra2">&nbsp;</td></tr>
                    </table>
                </td></tr></table></div><div id="divEntradaCategoria">
            <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina"><tr><td class="tabela" colspan="10"><div align="center">Dados da Entrada da Carga</div></td></tr>
            <tr><td width="25%" class="TextoCampos">Categoria da Carga:</td>
                <td width="25%" class="CelulaZebra2">
                    <select class="fieldMin" id="categoriaCarga" name="categoriaCarga">
                        <option value="0">Selecione</option>
                        <%for (CategoriaCarga cc : listaCategoriaCarga) {%>
                            <option value="<%=cc.getId()%>" <%=(carregaconh && cc.getId() == conh.getCatCarga().getId() ? "selected" : "")%>><%=cc.getDescricao()%></option>
                        <%}%>
                    </select>
                </td>
                <td width="25%" class="TextoCampos">Conferente:</td>
                <td width="25%" class="CelulaZebra2"><input type="hidden" name="id_funcionario" id="id_funcionario" value="<%= ( carregaconh ? conh.getConferente().getId() : "0") %>"><input type="text" class="inputReadOnly8pt" readonly="true" name="nome_funcionario" id="nome_funcionario" value="<%= ( carregaconh ? conh.getConferente().getNome() : "") %>"><input type="button" value="..." class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=93','Conferente')"><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Conferente" onClick="javascript:getObj('id_funcionario').value = '0';javascript:getObj('nome_funcionario').value = '';"></td></table></div>   
<div id="divInfoContainer"><table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td class="tabela" colspan="10"><div align="center">Dados do Container</div></td></tr>
            <tr><td width="10%" class="TextoCampos">Nº Container:</td>
                <td width="15%" class="CelulaZebra2"><input name="numero_container" type="text" id="numero_container" value="<%=(carregaconh ? conh.getNumeroContainer() : "")%>" size="18" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
                <td width="15%" class="TextoCampos">Tipo:</td>
                <td width="10%" class="CelulaZebra2"><select name="tipo_container" id="tipo_container" style="font-size:8pt;width:'80px';" class="fieldMin" onchange="localizaPesoContainer(this.value);">
                        <option value="0" selected>Selecione</option>
                        <%ConsultaTipoContainer tpContainer = new ConsultaTipoContainer();
                        tpContainer.setConexao(Apoio.getUsuario(request).getConexao());
                        tpContainer.MostrarTudo();
                        ResultSet rsTp = tpContainer.getResultado();
                        while (rsTp.next()) {%>
                            <option value="<%=rsTp.getString("id")%>" style="background-color:#FFFFFF" <%=(carregaconh && rsTp.getInt("id") == conh.getTipoContainer().getId() ? "Selected" : "")%>><%=rsTp.getString("descricao")%></option>
                        <%}rsTp.close();%>
                    </select></td>
                <td width="10%" class="TextoCampos">Valor:</td>
                <td width="15%" class="CelulaZebra2"><input name="valor_container" type="text" id="valor_container" style="font-size:8pt;" value="<%=Apoio.to_curr(conh.getValorContainer())%>" size="8" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');" class="fieldMin" ></td>
                <td width="10%" class="TextoCampos">Peso:</td>
                <td width="15%" class="CelulaZebra2"><input name="peso_container" type="text" id="peso_container" style="font-size:8pt;" value="<%=Apoio.to_curr(conh.getPesoContainer())%>" size="8" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.000');" class="fieldMin" ></td>
            </tr>    
            <tr><td class="TextoCampos">Nº GENSET:</td>
                <td class="CelulaZebra2"><input name="genset" type="text" id="genset" value="<%=(carregaconh ? conh.getNumeroGenset() : "")%>" size="12" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
                <td class="TextoCampos">Valor:</td>
                <td class="CelulaZebra2"><input name="valor_genset" type="text" id="valor_genset" style="font-size:8pt;" value="<%=Apoio.to_curr(conh.getValorGenset())%>" size="8" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');" class="fieldMin" ></td>
                <td class="TextoCampos">Horímetro Inicial:</td>
                <td class="CelulaZebra2"><input name="horimetro_inicial" type="text" id="horimetro_inicial" value="<%=(carregaconh ? conh.getGensetHorimetroInicial() : "0")%>" size="8" maxlength="30" style="font-size:8pt;" class="fieldMin" onBlur="javascript:seNaoIntReset(this,'0');"></td>
                <td class="TextoCampos">Horímetro Final:</td>
                <td class="CelulaZebra2"><input name="horimetro_final" type="text" id="horimetro_final" value="<%=(carregaconh ? conh.getGensetHorimetroFinal() : "0")%>" size="8" maxlength="30" style="font-size:8pt;" class="fieldMin" onBlur="javascript:seNaoIntReset(this,'0');"></td>
            </tr> 
            <tr><td class="TextoCampos">Nº Booking:</td>
                <td class="CelulaZebra2"><input name="booking" type="text" id="booking" value="<%=(carregaconh ? conh.getNumeroBooking() : "")%>" size="13" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
                <td class="TextoCampos">Nº Lacre:</td>
                <td class="CelulaZebra2"><input name="lacre_container" type="text" id="lacre_container" value="<%=(carregaconh ? conh.getNumeroLacre() : "")%>" size="10" maxlength="30" style="font-size:8pt;" class="fieldMin"></td>
                <td class="TextoCampos">Nº Viagem:</td>
                <td class="CelulaZebra2"><input name="viagem_container" type="text" id="viagem_container" value="<%=(carregaconh ? conh.getNumeroViagemNavio() : "")%>" size="7" maxlength="10" style="font-size:8pt;" class="fieldMin"></td>
                <td class="TextoCampos"></td>
                <td class="CelulaZebra2"></td>
            </tr>
            <tr><td class="TextoCampos">Navio:</td>
                <td class="CelulaZebra2" colspan="3"><input name="navio" type="text" class="inputReadOnly" id="navio" size="30" value="<%=(carregaconh  ? conh.getNavio().getDescricao() : "")%>" style="font-size:8pt;">
                    <input name="idnavio" type="hidden" class="inputReadOnly" id="idnavio" value="<%=(carregaconh ? conh.getNavio().getId() : 0)%>">
                    <input name="button5" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=53','Navio')" value="...">
                    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Navio" onClick="javascript:getObj('idnavio').value = '0';javascript:getObj('navio').value = '';"></strong>
                </td>
                <td class="TextoCampos">Porto Embarque:</td>
                <td class="CelulaZebra2" colspan="3"><input name="porto_embarque" type="text" class="inputReadOnly" id="porto_embarque" size="30" value="<%=(carregaconh ? conh.getPortoEmbarque().getDescricao() : "")%>" style="font-size:8pt;">
                    <input name="porto_embarque_id" type="hidden" class="inputReadOnly" id="porto_embarque_id" value="<%=(carregaconh ? conh.getPortoEmbarque().getId() : 0)%>">
                    <input name="button5" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=75','Porto_Embarque')" value="...">
                    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Porto Embarque" onClick="javascript:getObj('porto_embarque_id').value = '0';javascript:getObj('porto_embarque').value = '';"></strong>
                </td>
            </tr>    
            <tr><td class="TextoCampos">Armador:</td>
                <td class="CelulaZebra2" colspan="3"><input name="armador" type="text" class="inputReadOnly" id="armador" size="30" value="<%=(carregaconh ? conh.getArmador().getRazaosocial() : "")%>" style="font-size:8pt;">
                    <input name="idarmador" type="hidden" class="inputReadOnly" id="idarmador" value="<%=(carregaconh ? conh.getArmador().getIdcliente() : 0)%>">
                    <input name="button2" type="button" class="botoes" onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=52','Armador')" value="...">
                    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Armador" onClick="javascript:getObj('idarmador').value = '0';javascript:getObj('armador').value = '';"></strong>
                </td>
                <td class="TextoCampos">Porto Destino:</td>
                <td class="CelulaZebra2" colspan="3"><input name="porto_destino" type="text" class="inputReadOnly" id="porto_destino" size="30" value="<%=(carregaconh ? conh.getPortoDestino().getDescricao() : "")%>" style="font-size:8pt;">
                    <input name="porto_destino_id" type="hidden" class="inputReadOnly" id="porto_destino_id" value="<%=(carregaconh ? conh.getPortoDestino().getId() : 0)%>">
                    <input name="button6" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=75','Porto_Destino')" value="...">
                    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Porto Destino" onClick="javascript:getObj('porto_destino_id').value = '0';javascript:getObj('porto_destino').value = '';"></strong>
                </td>
            </tr>    
            <tr><td class="TextoCampos">Terminal:</td>
                <td class="CelulaZebra2" colspan="3"><input name="terminal" type="text" class="inputReadOnly" id="terminal" size="30" value="<%=(carregaconh ? conh.getTerminal().getDescricao() : "")%>" style="font-size:8pt;">
                    <input name="idterminal" type="hidden" class="inputReadOnly" id="idterminal" value="<%=(carregaconh ? conh.getTerminal().getId() : 0)%>">
                    <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=54','Terminal')" value="...">
                    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Armador" onClick="javascript:getObj('idterminal').value = '0';javascript:getObj('terminal').value = '';"></strong>
                </td>
                <td class="TextoCampos">Porto Transbordo:</td>
                <td class="CelulaZebra2" colspan="3"><input name="porto_transbordo" type="text" class="inputReadOnly" id="porto_transbordo" size="30" value="<%=(carregaconh ? conh.getPortoTransbordo().getDescricao() : "")%>" style="font-size:8pt;">
                    <input name="porto_transbordo_id" type="hidden" class="inputReadOnly" id="porto_transbordo_id" value="<%=(carregaconh ? conh.getPortoTransbordo().getId() : 0)%>">
                    <input name="button7" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=75','Porto_Transbordo')" value="...">
                    <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Porto Transbordo" onClick="javascript:getObj('porto_transbordo_id').value = '0';javascript:getObj('porto_transbordo').value = '';"></strong>
                </td>
            </tr>    
            <tr><td class="TextoCampos">Direção:</td>
                <td class="CelulaZebra2" ><select id="direcaoAquaviario" name="direcaoAquaviario" class="inputTexto">
                        <option value="-" <%=(carregaconh && conh.getDirecaoAquaviario() != null && conh.getDirecaoAquaviario().equals("-") ? "selected" :"" )%> >Não Selecionado</option>
                        <option value="N" <%=(carregaconh && conh.getDirecaoAquaviario() != null && conh.getDirecaoAquaviario().equals("N") ? "selected" :"" )%> >Norte</option>
                        <option value="S" <%=(carregaconh && conh.getDirecaoAquaviario() != null && conh.getDirecaoAquaviario().equals("S") ? "selected" :"" )%>>Sul</option>
                        <option value="L" <%=(carregaconh && conh.getDirecaoAquaviario() != null && conh.getDirecaoAquaviario().equals("L") ? "selected" :"" )%>>Leste</option>
                        <option value="O" <%=(carregaconh && conh.getDirecaoAquaviario() != null && conh.getDirecaoAquaviario().equals("O") ? "selected" :"" )%>>Oeste</option>
                    </select></td>
                <td class="TextoCampos">Tipo de Navegação:</td>
                <td class="CelulaZebra2" ><select id="tipoNavegacao" name="tipoNavegacao" class="inputTexto">
                        <option value="-1" <%=(carregaconh && conh.getTipoNavegacaoAquaviario() == (-1) ? "selected" :"" )%>>Não Informado</option>
                        <option value="0" <%=(carregaconh && conh.getTipoNavegacaoAquaviario() == 0 ? "selected" :"" )%>>Interior</option>
                        <option value="1" <%=(carregaconh && conh.getTipoNavegacaoAquaviario() == 1 ? "selected" :"" )%>>Cabotagem</option></select></td>
                <td class="CelulaZebra2" colspan="4" ></td>
            </tr>
        </table>    
        <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td class="tabela" colspan="10"><div align="center">Dados referente a importação de cargas via aéreo</div></td></tr>
            <tr>
                <td width="10%" class="TextoCampos">House AWB:</td>
                <td width="15%" class="CelulaZebra2"><input name="house_awb" type="text" id="house_awb" value="<%=(carregaconh ? conh.getHouseAwb() : "")%>" size="13" maxlength="15" style="font-size:8pt;" class="fieldMin"></td>
                <td width="10%" class="TextoCampos">Master AWB:</td>
                <td width="15%" class="CelulaZebra2"><input name="master_awb" type="text" id="master_awb" value="<%=(carregaconh ? conh.getMasterAwb() : "")%>" size="13" maxlength="15" style="font-size:8pt;" class="fieldMin"></td>
                <td width="10%" class="TextoCampos"></td>
                <td width="15%" class="CelulaZebra2"></td>
                <td width="10%" class="TextoCampos"></td>
                <td width="15%" class="CelulaZebra2"></td>
            </tr>    
        </table>    
</div>    
<div id="divInfoCTE">
        <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td class="tabela" colspan="10"><div align="center">Dados do CT-e</div></td></tr>
            <tr><td width="12%" class="TextoCampos">Status:</td>
                <td width="25%" class="CelulaZebra2"><%=conh.getDescricaoStatusCte()%></td>
                <td width="10%" class="TextoCampos">Nº Recibo:</td>
                <td width="10%" class="CelulaZebra2"><%=conh.getNumeroReciboCte()%></td>
                <td width="15%" class="TextoCampos"><input name="ckRecebedorRetira" type="checkbox" id="ckRecebedorRetira" <%=(carregaconh && conh.isRecebedorRetiraCargaDestino()? "checked" : "")%>>Recebedor retira a carga no destino</td>
                <td width="10%" class="TextoCampos">Responsável Seguro:</td>
                <td width="10%" class="CelulaZebra2"><select id="respseg" name="respseg" class="inputTexto">
                        <option value="-1" <%=(carregaconh && conh.getRespSeg().equals("-1") ? "selected" :"" )%>>Não Informado</option>
                        <option value="0" <%=(carregaconh && conh.getRespSeg().equals("0") ? "selected" :"" )%>>Remetente</option>
                        <option value="1" <%=(carregaconh && conh.getRespSeg().equals("1") ? "selected" :"" )%>>Expedidor</option>
                        <option value="2" <%=(carregaconh && conh.getRespSeg().equals("2") ? "selected" :"" )%>>Recebedor</option>
                        <option value="3" <%=(carregaconh && conh.getRespSeg().equals("3") ? "selected" :"" )%>>Destinatário</option>
                        <option value="4" <%=(carregaconh && conh.getRespSeg().equals("4") ? "selected" :"" )%>>Transportadora</option>
                        <option value="5" <%=(carregaconh && conh.getRespSeg().equals("5") ? "selected" :"" )%>>Tomador de Serviço</option></select></td>            
            </tr>    
            <tr><td class="TextoCampos">Chave de Acesso:</td>
                <td class="CelulaZebra2">
                    <%=conh.getChaveAcessoCte()%>
                    <input type="hidden" id="chaveAcesso" name="chaveAcesso" value="<%=conh.getChaveAcessoCte()%>">
                    <img align="center" class="imagemLink" alt="" title="Consultar chave de acesso" id="img_consultar_cte" onClick="javascript:tryRequestToServer(function(){submeterConsulta('<%=conh.getChaveAcessoCte()%>')})" width="30px" src="img/pesquisar_cte.png">
                    <%if ((nivelImprimirDacte == 4 || nivelCte > 0) && (conh.getStatusCte().equals("C") || conh.getStatusCte().equals("L"))) {%>
                        <img class="imagemLink" alt="" title="Imprimir DACTE" id="img_imprimir_dacte" onClick="javascript:tryRequestToServer(function(){popCTe('<%=conh.getId()%>');});" src="img/pdf.gif">
                    <%}%>
                    <%if (!conh.getStatusCte().equals("E")) {%>
                        <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  href="./<%=conh.getChaveAcessoCte() + "-" + (conh.getStatusCte().equals("L") ? "can" : conh.getStatusCte().equals("C") ? "cte" : "neg")%>.xml?acao=gerarXmlCliente&idCte=<%=conh.getId()%>&status=<%=conh.getStatusCte()%>" target="pop3">
                            <img class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml" width="25px" src="img/xml.png"></a>
                    <%}%>
                </td>
                <td class="CelulaZebra2" colspan="2">
                    <label><b>Alíq. interna UF destino diferencial: <%=(conh.getAliquotaInternaUfFim() == 0 ? "0" : Apoio.to_curr(conh.getAliquotaInternaUfFim()))%> % <%=conh.getAliquotaInternaUfFim() == 0 ? "" : "("+Apoio.to_curr2(Math.abs(conh.getAliquotaInternaUfFim() - conh.getAliquota()) * conh.getBaseCalculo() / 100)+")" %> </b></label> <img width="15px" heigth="30px" src="img/ajuda.png" title="Verificar Cálculo" onclick="verificarCalculoAliquotaInterna()" className="imagemLink" align="absbottom"/>
                </td>
                <td class="CelulaZebra2" colspan="2">
                    <label><b>Alíq. combate a pobreza: <%=(conh.getAliquotaIcmsPobreza() == 0 ? "0" : Apoio.to_curr(conh.getAliquotaIcmsPobreza()))%> % <%=conh.getAliquotaIcmsPobreza() == 0 ? "" : "("+Apoio.to_curr2(conh.getAliquotaIcmsPobreza() * conh.getBaseCalculo() / 100)+")" %></b></label> <img width="15px" heigth="30px" src="img/ajuda.png" title="Verificar Cálculo" onclick="verificarCalculoAliquotaPobreza()" className="imagemLink" align="absbottom"/>
                </td>
                <td width="10%" class="CelulaZebra2"><label <c:if test="${!carregaconh}"> style="display:none;"</c:if>><input type="checkbox" id="isGlobalizado" name="isGlobalizado" <%= (carregaconh && conh.isIsGlobalizado() ? "checked='true'" : "") %>>CT-e Globalizado</label></td></tr>
                    <% if(conh.isIsConfirmadoOutraAplicacao()){%>
            <tr>
                <td class="CelulaZebra2" colspan="6">
                    CTE importado e confirmado por outra aplicação
                </td>
            </tr>
                        <% } %>
        </table> 
        <% 
            /* 
             * Verifica se o status de utilização não é não utiliza (0) e se 
             * o gerenciador de risco é Atlas (id = 3)
             * Caso for, mostrar uma tabela com os dados do gerenciador de risco do CTe.
             */
            if (fi.getFilialGerenciadorRisco() != null && fi.getFilialGerenciadorRisco().getStUtilizacao() != 0 && 
                fi.getFilialGerenciadorRisco().getGerenciadorRisco() != null && fi.getFilialGerenciadorRisco().getGerenciadorRisco().getId() == 3) { %>
            <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
                <tr><td class="tabela" colspan="10"><div align="center">Dados de Gerenciamento de Risco</div></td>
                </tr><tr>
                    <td width="5%" class="TextoCampos">Status:</td>
                    <td width="5%" class="CelulaZebra2"><div align="center"><%=conh.getDescricaoStatusMonitoramento()%></div></td>
                    <td width="10%" class="TextoCampos">Código monitoramento:</td>
                    <td width="5%" class="CelulaZebra2"><div align="center"><%=conh.getCodigoMonitoramento()%></div></td>
                    <td width="75%" class="CelulaZebra2"></td></tr></table> 
        <% } %>
        <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td width="50%"><table width="100%" border="0" cellpadding="0" cellspacing="1">
                        <tr class="Celula"><td colspan="4"><div align="center">Expedidor</div></td></tr>
                        <tr class="CelulaZebra2">
                  		<td width="13%" class="CelulaZebra2"><div align="right">R.Social:</div></td>
				<td colspan="3" class="CelulaZebra2"><input name="exp_codigo" type="text" id="exp_codigo" size="4" value="<%=(carregaconh && exp.getIdcliente() != 0 ? String.valueOf(exp.getIdcliente()) : "")%>"  <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> onKeyUp="javascript:if (event.keyCode==13) localizaExpedidorCodigo('idcliente', this.value)" class="fieldMin">
                  			<input name="exp_rzs" type="text" id="exp_rzs" size="50" value="<%=(carregaconh && exp.getRazaosocial() != null ? exp.getRazaosocial() : "")%>" onFocus="this.select();" class="inputReadOnly8pt" onKeyUp="javascript:if (event.keyCode==13) localizaExpedidorCodigo('c.razaosocial', this.value)">
                                        <strong><input name="localiza_exp" type="button" class="botoes" id="localiza_exp" value="..." onClick="javascript:localizaexpedidor();">                                        
                                        <%if (nvCli > 0){%>
                                            <img src="img/page_edit.png" border="0" onClick="javascript:verClienteCtrc('E');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                                        <%} %>
                                          <img id="botao_exp" src="img/borracha.gif" border="0" class="imagemLink" onClick="limpaExpedidor()">
					<input type="hidden" name="pauta_expedidor" id="pauta_expedidor" value="<%=(carregaconh && exp.isUtilizaPautaFiscal() != false ? String.valueOf(exp.isUtilizaPautaFiscal()) : "f")%>">
					<input type="hidden" name="exp_st_mg" id="exp_st_mg" value="<%=(carregaconh && exp.isSubstituicaoTributariaMinasGerais() != false ? String.valueOf(exp.isSubstituicaoTributariaMinasGerais()) : "f")%>">
					<input type="hidden" name="exp_inclui_peso_container" id="exp_inclui_peso_container" value="<%=(carregaconh && exp.isIncluiContainerFretePeso() != false ? String.valueOf(exp.isIncluiContainerFretePeso()) : "f")%>">
					<input type="hidden"  id="exp_tipo_cfop" name="exp_tipo_cfop"  value="<%=(carregaconh && exp.getTipoCfop()  != null ? exp.getTipoCfop() : "c")%>"/></strong>
				</td></tr>                        
                        <tr class="CelulaZebra2">
                            <td class="CelulaZebra2"><div align="right">Cidade:</div></td>
                            <td width="45%" class="CelulaZebra2"><input name="exp_cidade" type="text" id="exp_cidade" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh && exp.getCidade().getDescricaoCidade() != null ? exp.getCidade().getDescricaoCidade() : "")%>">
                                <input name="exp_uf" type="text" id="exp_uf" size="1" readonly value="<%=(carregaconh && exp.getCidade().getUf() != null ? exp.getCidade().getUf() : "")%>" class="inputReadOnly8pt"></td>
                            <td width="9%" class="TextoCampos">CNPJ:</td>
                            <td width="33%" class="CelulaZebra2"><input name="exp_cnpj" type="text" id="exp_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaconh && exp.getCnpj() != null ? exp.getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaExpedidorCodigo('cnpj',this.value)"></td>
                        </tr>
                    </table></td>
                <td width="50%">
                    <table border="0" cellpadding="0" cellspacing="1" width="100%">
                        <tr class="Celula"><td colspan="4"><div align="center">Recebedor</div></td></tr>
                        <tr class="CelulaZebra2">
                        <td width="63" class="CelulaZebra2"><div align="right">R.Social:</div></td>
                        <td colspan="3" class="CelulaZebra2"><input name="rec_codigo" type="text" id="rec_codigo" size="4" style="font-size:8pt" value="<%=(carregaconh && rec.getIdcliente() != 0 ? String.valueOf(rec.getIdcliente()) : "")%>" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> onKeyUp="javascript:if (event.keyCode==13) localizaRecebedorCodigo('idcliente', this.value)" class="fieldMin">
                            <input name="rec_rzs" type="text" id="rec_rzs" size="50" value="<%=(carregaconh && rec.getRazaosocial() != null ? rec.getRazaosocial() : "")%>" onFocus="this.select();" class="inputReadOnly8pt" onKeyUp="javascript:if (event.keyCode==13) localizaRecebedorCodigo('c.razaosocial', this.value)">
                            <input type="hidden" name="pauta_recebedor" id="pauta_recebedor" value="<%=(carregaconh && rec.isUtilizaPautaFiscal() != false ? String.valueOf(rec.isUtilizaPautaFiscal()) : "f")%>">
                            <strong>
                            <input name="localiza_rec" type="button" class="botoes" id="localiza_rec" value="..." onClick="javascript:localizarecebedor();">
                            <input type="hidden"  id="rec_inclui_tde" name="rec_inclui_tde"  value="f"/>
                            <input type="hidden"  id="rec_tipo_cfop" name="rec_tipo_cfop"  value="<%=(carregaconh && rec.getTipoCfop() != null ? rec.getTipoCfop() : "c")%>"/>
                            <input type="hidden" name="rec_inclui_peso_container" id="rec_inclui_peso_container" value="<%=(carregaconh && rec.isIncluiContainerFretePeso() != false ? String.valueOf(rec.isIncluiContainerFretePeso()) : "f")%>">
                            <%if (nvCli > 0){%>
                                <img src="img/page_edit.png" border="0" onClick="javascript:verClienteCtrc('REC');" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "> 
                            <%} %>
                              <img id="botao_rec" src="img/borracha.gif" border="0" class="imagemLink" onClick="limpaRecebedor()"></strong></td></tr>                    
                    <tr class="CelulaZebra2">
                        <td class="CelulaZebra2"><div align="right">Cidade:</div></td>
                        <td width="205" class="CelulaZebra2"><input name="rec_cidade" type="text" id="rec_cidade" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh && rec.getCidade().getDescricaoCidade() != null ? rec.getCidade().getDescricaoCidade() : "")%>">
                            <input name="rec_uf" type="text" id="rec_uf" size="1" class="inputReadOnly8pt" readonly value="<%=(carregaconh && rec.getCidade().getUf() != null ? rec.getCidade().getUf() : "")%>"></td>
                        <td width="41" class="TextoCampos">CNPJ:</td>
                        <td width="108" class="CelulaZebra2"><input name="rec_cnpj" type="text" id="rec_cnpj" size="20" class="inputReadOnly8pt" value="<%=(carregaconh && rec.getCnpj() != null ? rec.getCnpj() : "")%>" onKeyUp="javascript:if (event.keyCode==13) localizaRecebedorCodigo('cnpj', this.value)"></td>
                    </tr></table></td></tr></table>   
 <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina" id="tableSub" name="tableSub">
            <tr><td width="100%"><table width="100%" border="0" cellpadding="0" cellspacing="1">
                        <tr class="Celula"><td colspan="4"><div align="center">Dados da Substituição do CT-e</div></td></tr>
                        <tr class="CelulaZebra2"><td width="40%" class="CelulaZebra2"><div align="right">Chave de acesso do CT-e ou NF-e emitida pelo tomador:</div></td><td colspan="3" class="CelulaZebra2"><input name="chaveSubTomador" type="text" id="chaveSubTomador" size="44"  class="fieldMin" value="<%=(carregaconh && conh.getChaveCteNfeEmitidaTomador() != null ? conh.getChaveCteNfeEmitidaTomador() : "")%>">
				</td></tr></table></td>
               </tr></table>
    <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
        <tr>
            <td class="CelulaZebra2" width="10%">
                <div align="right">
                    <label for="obs_fisco_lin1" class="textoCampos">OBS Reservado ao Fisco:</label>
                </div>
            </td>
            <td class="CelulaZebra2" width="90%">
                <div style="padding-left: 5px; padding-top: 5px">
                    <input name="obs_fisco_lin1" type="text" class="fieldMin" id="obs_fisco_lin1" value="<%=conh.getObservacaoFisco()[0]%>" size="99" maxlength="99" >
                </div>
                <div style="padding-left: 5px; padding-top: 5px">
                    <input name="obs_fisco_lin2" type="text" class="fieldMin" id="obs_fisco_lin2" value="<%=conh.getObservacaoFisco()[1]%>" size="99" maxlength="99">
                </div>
                <div style="padding-left: 5px; padding-top: 5px">
                    <input name="obs_fisco_lin3" type="text" class="fieldMin" id="obs_fisco_lin3" value="<%=conh.getObservacaoFisco()[2]%>" size="99" maxlength="99">
                </div>
                <div style="padding-left: 5px; padding-top: 5px">
                    <input name="obs_fisco_lin4" type="text" class="fieldMin" id="obs_fisco_lin4" value="<%=conh.getObservacaoFisco()[3]%>" size="99" maxlength="99">
                </div>
                <div style="padding-left: 5px; padding-top: 5px; padding-bottom: 5px">
                    <input name="obs_fisco_lin5" type="text" class="fieldMin" id="obs_fisco_lin5" value="<%=conh.getObservacaoFisco()[4]%>" size="99" maxlength="99">
                    <input type="button" class="botoes" value="..." onclick="launchPopupLocate('./localiza?acao=consultar&amp;idlista=28', 'Observacao_Fisco');">
                </div>
            </td>
        </tr>
    </table>
    <table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
        <tr><td class="tabela" colspan="10"><div align="center">Dados da Averbação</div></td></tr>
        <tr id="averbacao">
            <td class="TextoCampos">Protocolo de Averbação:</td>
            <td class="CelulaZebra2">
                <input type="checkbox" name="ckprotocoloAverbacao" id ="ckprotocoloAverbacao" onclick="javascript:averbacao();">
                <input type="text" name="protocoloAverbacao" id ="protocoloAverbacao" size="40" maxlength="40" class="fieldMin" value="<%=conh.getAverbacaoFile().getProtocolo()%>" onkeypress="javascript: console.trace();"></td>
            <td class="CelulaZebra2" style="width: 50%;">Seguradora: <%=conh.getXsegCte()%> </td>
        </tr>
        <tr><td class="TextoCampos"><label>Percurso complementar em modal diferente:</label></td>
            <td style="margin-left: 20px;" class="CelulaZebra2" colspan="2"> 
                UF Início: 
                <select name="ufInicio" id="ufInicio" class="fieldMin">
                    <option value="" selected>Selecione</option>
                    <option value="AC">AC</option>
                    <option value="AL">AL</option>
                    <option value="AM">AM</option>
                    <option value="AP">AP</option>
                    <option value="BA">BA</option>
                    <option value="CE">CE</option>
                    <option value="DF">DF</option>
                    <option value="ES">ES</option>
                    <option value="GO">GO</option>
                    <option value="MA">MA</option>
                    <option value="MG">MG</option>
                    <option value="MS">MS</option>
                    <option value="MT">MT</option>
                    <option value="PA">PA</option>
                    <option value="PB">PB</option>
                    <option value="PE">PE</option>
                    <option value="PI">PI</option>
                    <option value="PR">PR</option>
                    <option value="RJ">RJ</option>
                    <option value="RN">RN</option>
                    <option value="RO">RO</option>
                    <option value="RR">RR</option>
                    <option value="RS">RS</option>
                    <option value="SC">SC</option>
                    <option value="SE">SE</option>
                    <option value="SP">SP</option>
                    <option value="TO">TO</option>
                    <option value="EX">EX</option>
                </select>  
                UF Fim: 
                <select name="ufFim" id="ufFim" class="fieldMin">
                    <option value="" selected>Selecione</option>
                    <option value="AC">AC</option>
                    <option value="AL">AL</option>
                    <option value="AM">AM</option>
                    <option value="AP">AP</option>
                    <option value="BA">BA</option>
                    <option value="CE">CE</option>
                    <option value="DF">DF</option>
                    <option value="ES">ES</option>
                    <option value="GO">GO</option>
                    <option value="MA">MA</option>
                    <option value="MG">MG</option>
                    <option value="MS">MS</option>
                    <option value="MT">MT</option>
                    <option value="PA">PA</option>
                    <option value="PB">PB</option>
                    <option value="PE">PE</option>
                    <option value="PI">PI</option>
                    <option value="PR">PR</option>
                    <option value="RJ">RJ</option>
                    <option value="RN">RN</option>
                    <option value="RO">RO</option>
                    <option value="RR">RR</option>
                    <option value="RS">RS</option>
                    <option value="SC">SC</option>
                    <option value="SE">SE</option>
                    <option value="SP">SP</option>
                    <option value="TO">TO</option>
                    <option value="EX">EX</option>
                </select>  
                Modal: <select name="modalConhecimentoAverbacao"  class="fieldMin" id="modalConhecimentoAverbacao" style="font-size:8pt;">
                    <option value="0" selected>Selecione</option>
                    <option value="1">Rodoviário</option>
                    <option value="2">Marítimo</option>
                    <option value="3">Fluvial</option>
                    <option value="4">Ferroviário</option>
                    <option value="5">Aéreo</option>
                </select>
            </td>
    </tr>
    </table>
</div>
<div id="divInfoGM"><table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
    <tr><td class="tabela" colspan="5"><div align="center">Ocorrências</div></td></tr>
    <%if (carregaconh){%>
        <tr >
            <td class="CelulaZebra2NoAlign"  align="right" colspan="5">
                <input type="button" class="botoes" value="Pontos de Controle" onclick="javascript: verPontosControle('<%=Apoio.getDataAtual()%>')" >
            </td>
        </tr>
    <%}%>
    <tr><td class="TextoCampos" width="13%">Ocorrência Principal:</td>
      <td class="CelulaZebra2" width="25%"><%=(carregaconh && conh.getOcorrencia().getCodigo() != null? conh.getOcorrencia().getCodigo() + " - " + conh.getOcorrencia().getDescricao() : "&nbsp") %></td>
      <td class="TextoCampos" width="13%">Observação Principal:</td>
      <td class="CelulaZebra2" width="25%"><%=(carregaconh && conh.getObservacaoBaixa() != null? conh.getObservacaoBaixa() : "&nbsp") %></td>
      <td class="CelulaZebra2" width="24%"><%if (carregaconh){%><div align="center" id="mostrarOcor" name="mostrarOcor" class="linkEditar" onClick="mostrarOcorrencias();">Mostrar todas ocorrências</div><%}%></td>
    </tr>
    <tr id="trOcorrencia" style="display:none;"><td colspan="5" id="tdOcorrencia">--</td></tr>
  </table>
  </div>
<div id="divInfoCusto"><table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
            <tr><td class="tabela" colspan="8"><div align="center">Informações dos Custos desse CT-e</div></td></tr>
            <tr><td width="12%" class="TextoCampos">Custo Extra Coleta:</td>
                <td width="13%" class="CelulaZebra2"><input name="valor_custo_coleta" type="text" id="valor_custo_coleta" value="<%=conh.getValorOutrosCustosColeta()%>" size="6" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');" class="fieldMin"></td>
                <td width="12%" class="TextoCampos">Custo Extra Entrega:</td>
                <td width="13%" class="CelulaZebra2"><input name="valor_custo_entrega" type="text" id="valor_custo_entrega" value="<%=conh.getValorOutrosCustosEntrega()%>" size="6" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');" class="fieldMin"></td>
                <td width="12%" class="TextoCampos"></td>
                <td width="13%" class="CelulaZebra2"></td>
                <td width="12%" class="TextoCampos"></td>
                <td width="13%" class="CelulaZebra2"></td>
            </tr>
        </table></div>
<div id="divMinCobradas">
   <table width="94%" border="0" class="bordaFina" align="center">
     <tr id="trTituloDistribuicao" name="trTituloDistribuicao"><td class="tabela"><div align="center">Rela&ccedil;&atilde;o das entregas locais (Minutas)</div></td> </tr>
     <tr id="trAddTituloDistribuicao" name="trAddTituloDistribuicao"><td><table border="0" cellpadding="1" cellspacing="1" width="100%"><tbody id="tbDistribuicao" name="tbDistribuicao">
         <tr>
            <td width="1%" class="celula"><img src="img/add.gif" border="0" title="Adicionar um novo CT-e de distribuição local" class="imagemLink" id="botAdd" onClick="javascript:tryRequestToServer(function(){selecionaCTRC();});"></td>
            <td width="10%" class="celula"><div align="left">CT-e</div></td>
            <td width="8%" class="celula"><div align="left">NF</div></td>
            <td width="10%" class="celula"><div align="left">Emiss&atilde;o</div></td>
            <td width="10%" class="celula"><div align="right">Valor</div></td>
            <td width="27%" class="celula"><div align="left">Destinat&aacute;rio</div></td>
            <td width="15%" class="celula"><div align="left">Bairro</div></td>
            <td width="20%" class="celula"><div align="left">Cidade</div></td>
          </tr>
        </tbody></table></td></tr>
      <tr id="trTotalTituloDistribuicao" name="trTotalTituloDistribuicao">
        <td colspan="10">
        <table border="0" cellpadding="1" cellspacing="1" width="100%">
        <tbody id="tbDistribuicao" name="tbDistribuicao">
          <tr><td width="12%" class="celula"><div align="right"><label id="lbQtdDistribuicao" name="lbQtdDistribuicao">0 CT-e(s)</label></div></td>
            <td width="10%" class="celula"><div align="right">TOTAL:</div></td>
            <td width="10%" class="celula"><div align="right"><label id="lbTotalDistribuicao" name="lbTotalDistribuicao">0.00</label></div></td>
            <td width="68%" class="celula"></td>
          </tr></tbody></table></td></tr></table></div>      
<table width="94%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
  <tr class="tabela"><td colspan="2"><div align="center">Notas Fiscais / Tabela de pre&ccedil;o&nbsp;</div></td></tr>
  <tr><td colspan="2"><table width="100%" border="0" align="center" cellpadding="2" cellspacing="1"><tr>
        <td width="100%"><table  id="tableNotes0" width="100%" border="0" align="center" cellpadding="2" cellspacing="1">
          <tr class="colorClear"><td><img src="img/add.gif" border="0" onClick="incluiNF();" title="Adicionar uma nova Nota fiscal [F2]" class="imagemLink"></td>
            <td colspan="2"></td>
            <td>N&uacute;mero</td><td>S&eacute;rie</td><td>Emiss&atilde;o</td><td>Valor</td><td>Peso(kg)</td><td>Volume</td><td>Embalagem</td><td>Conte&uacute;do</td>
            <td>BC Icm </td><td>Vl. Icm</td><td>Icm ST </td>
          </tr>
        </table></td> </tr></table></td></tr>
  <tr>	<td colspan="2"><table width="100%" border="0" cellpadding="2" cellspacing="1">							
              <tr><td width="10%" class="TextoCampos" align="left"><b>TOTAIS NF:</b></td>
				<td width="2%" class="TextoCampos"><label id="contadorNF" name="contadorNF"></label></td>
                                <td width="4%" class="TextoCampos">Valor:</td>
				<td width="8%" class="CelulaZebra2"><input name="vlmercadoria" type="text" readonly  class="inputReadOnly8pt" id="vlmercadoria" size="7" style="font-size:8pt;" value="0.00"></td>
				<td width="4%" class="TextoCampos">Peso:</td>
				<td width="8%" class="CelulaZebra2"><input name="peso" type="text" id="peso" size="7" readonly  class="inputReadOnly8pt" style="font-size:8pt;" value="0.00"></td>
				<td width="5%" class="TextoCampos">Vol(s):</td>
				<td width="8%" class="CelulaZebra2"><input name="volume" type="text" id="volume" size="7" readonly  class="inputReadOnly8pt" style="font-size:8pt;" value="0.00"></td>
				<td width="6%" class="TextoCampos"><b>CUBAGEM</b></td>
				<td width="29%" class="CelulaZebra2">
				C:<input name="cub_comprimento" type="text" id="cub_comprimento" onChange="seNaoFloatReset(this,'0.00');alterouCampoDependente(this.id);"
                         value="<%=conh.getCubagem_comprimento()%>" size="4" maxlength="8" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"/>
				L:<input name="cub_largura" type="text" id="cub_largura" onChange="seNaoFloatReset(this,'0.00');alterouCampoDependente(this.id);"
                         value="<%=conh.getCubagem_largura()%>" size="4" maxlength="8" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"/>
				A:<input name="cub_altura" type="text" id="cub_altura" onChange="seNaoFloatReset(this,'0.00');alterouCampoDependente(this.id);"
                         value="<%=conh.getCubagem_altura()%>" size="4" maxlength="8" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"/>
				=<input name="cub_metro" type="text" id="cub_metro" onChange="seNaoFloatReset(this,'0.00');alterouCampoDependente(this.id);"
                         value="<%=cub_metro%>" size="4" maxlength="8" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"/>M³
				</td>
				<td width="4%" class="TextoCampos">Base:</td>
				<td width="14%" class="CelulaZebra2">
                    <input name="cub_base" type="text" id="cub_base" size="3" style="font-size:8pt;" value="<%=cub_base%>" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly8pt":"fieldMin")%>" onChange="calculaPesoTaxadoCtrc();">
                    =<input name="cub_peso" type="text" id="cub_peso" size="7" readonly="readonly" value="" class="inputReadOnly8pt">kg
				</td></tr></table></td></tr>
  <tr><td colspan="2"><table width="100%" border="0" cellpadding="2" cellspacing="1">
			<tr><td width="14%" class="TextoCampos"><b><label id="calculado_entre" name="calculado_entre">Calculado entre</label></b></td>
				<td width="6%" class="TextoCampos"><label id="lbCidadeOrigem" name="lbCidadeOrigem">Origem:</label></td>
				<td width="25%" class="CelulaZebra2">
					<input name="cid_origem" type="text" id="cid_origem" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getCidadeOrigem().getDescricaoCidade() : "")%>">
                    <input name="uf_origem" type="text" id="uf_origem" size="3" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getCidadeOrigem().getUf() : "")%>">
                    <input name="btn_origem"  type="button" class="botoes" id="btn_origem" onClick="localizaCidadeOrigem();" value="..." <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>></td>
				</td>
				<td width="6%" class="TextoCampos"><label id="lbCidadeDestino" name="lbCidadeDestino">Destino:</label></td>
				<td width="25%" class="CelulaZebra2">
                    <input name="cid_destino" type="text" id="cid_destino" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getCidadeDestino().getDescricaoCidade() : "")%>">
                    <input name="uf_destino" type="text" id="uf_destino" size="3" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getCidadeDestino().getUf() : "")%>">
                    <input name="btn_destino"  type="button" class="botoes" id="btn_destino" onClick="localizaCidadeDestino();" value="..." <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
				</td>
				<td width="4%" class="TextoCampos"><label id="lbRota" name="lbRota">Rota:</label></td>
				<td width="10%" class="CelulaZebra2">
                    <input name="rota_viagem" type="text" id="rota_viagem" size="15" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getRota().getDescricao() : "")%>">
                    <input name="id_rota_viagem" type="hidden" id="id_rota_viagem" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getRota().getId() : "0")%>">
                    <input name="considerar_campo_cte" type="hidden" id="considerar_campo_cte" size="25" class="inputReadOnly8pt" readonly="true" value="tp">
                    <input name="prazo_rota" type="hidden" id="prazo_rota" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getRota().getPrazoEntrega() : "0")%>">
                    <input name="tipo_prazo_rota" type="hidden" id="tipo_prazo_rota" size="25" class="inputReadOnly8pt" readonly="true" value="<%=(carregaconh ? conh.getRota().getTipoPrevisao() : "U")%>">
                    <input name="json_taxas" type="hidden" id="json_taxas" readonly="true">
				</td>
				<td width="10%" class="TextoCampos">
					<input name="distancia_km" type="text" id="distancia_km" value="<%=conh.getDistanciaOrigemDestino()%>" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoIntReset(this,'0.00');" onChange="getPautaFiscalConhecimento();alteraTipoTaxa($('tipotaxa').value);recalcular(false);">
					<label id="lbKm" name="lbKm">Km</label></td></tr></table></td></tr>
  <tr><td colspan="2"><table width="100%" border="0" cellpadding="2" cellspacing="1">
			<tr><td width="6%" class="TextoCampos">Entregas:</td>
				<td width="3%" class="CelulaZebra2">
                                    <input name="qtde_entregas" type="text" id="qtde_entregas" class="fieldMin" value="<%=conh.getQtde_entregas()%>" size="2" maxlength="5" onBlur="javascript:seNaoIntReset(this,'0');" onchange="alteraTipoTaxa($('tipotaxa').value);">
				</td>
				<td width="5%" class="TextoCampos">Pallets:</td>
				<td width="3%" class="CelulaZebra2">
					<input name="qtdPallets" type="text" id="qtdPallets" class="fieldMin" value="<%=conh.getQuantidadePallets()%>" size="2" maxlength="12" onBlur="javascript:seNaoIntReset(this,'0.00');recalcular(false);" onChange="alteraTipoTaxa($('tipotaxa').value);">
				</td>
				<td width="10%" class="TextoCampos">Tipo Produto:</td>
				<td width="12%" class="CelulaZebra2">
					<div id="divTipoProduto" name="divTipoProduto">
						<select name="tipoproduto" onChange="getObj('vlmercadoria').focus();alteraTipoProduto();" id="tipoproduto" class="fieldMin" style="width:110px;" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
                            <option value="0">Nenhum</option>
                            <% ResultSet product_types = TipoProduto.all(Apoio.getConnectionFromUser(request),(carregaconh?conh.getCliente().getIdcliente():0),(carregaconh?conh.getCliente().isTabelaTipoProduto():false),conh.getTipoProduto().getId());
							while (product_types.next()) {%>
								<option value="<%=product_types.getString("id")%>" style="background-color:#FFFFFF" <%=(carregaconh && product_types.getInt("id") == conh.getTipoProduto().getId() ? "Selected":"")%>> <%=product_types.getString("descricao") %> </option>
                            <%}%></select></div>
				</td>
				<td width="10%" class="TextoCampos">Tipo Frete:</td>
				<td width="11%" class="CelulaZebra2">
                    <select name="tipotaxa" id="tipotaxa" <%=!alteraTipoFrete ? "disabled='disabled'" : "" %> onChange="getObj('vlmercadoria').focus();alteraTipoTaxa(this.value);showFields(this.value);mostrarCamposComposicaoFrete(<%=alteraPreco%>)" class="fieldMin" <%=(conh.isQuitado() || conh.isCteBloqueado() || conh.isIsConfirmadoOutraAplicacao()?"disabled":"")%>>
                        <option value="-1">--Selecione--</option>
                        <option value="0">Peso/Kg</option>
                        <option value="1">Peso/Cubagem</option>
                        <option value="2">% Nota Fiscal</option>
                        <option value="3">Combinado</option>
                        <option value="4">Por Volume</option>
                        <option value="5">Por Km</option>
                        <option value="6">Por Pallet</option>
                    </select></td>
				<td width="10%" class="TextoCampos">Tipo Veículo:</td>
				<td width="9%" class="CelulaZebra2">
                                    <select name="tipoveiculo" style="width:80px;" id="tipoveiculo" class="fieldMin" onChange="if(this.value != -1){alteraTipoTaxa($('tipotaxa').value);} else if(this.value == '-1' && $('tipotaxa').value == '3'){ limparComposicaoFrete();}calcularFreteCarreteiro();" <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%>>
						<option value="-1">Nenhum</option>
                        <%ConsultaTipo_veiculos tipo = new ConsultaTipo_veiculos();
						tipo.setConexao( Apoio.getUsuario(request).getConexao() );
						tipo.mostraTipos(true, conh.getTipoveiculo().getId());
						ResultSet rs = tipo.getResultado();
						while (rs.next()) {%>
                            <option value="<%=rs.getString("id")%>" style="background-color:#FFFFFF" <%=(carregaconh && rs.getInt("id") == conh.getTipoveiculo().getId() ?"Selected":"")%>><%=rs.getString("descricao")%></option>
                        <%}%>
                    </select></td>
				<td width="11%" class="TextoCampos">Tabela utilizada:</td>
				<td width="5%" class="CelulaZebra2">
					<input type="text" name="client_tariff_id" id="client_tariff_id" value="<%=(carregaconh? String.valueOf(conh.getTabelaCliente().getId()) : "0")%>" size="4" class="inputReadOnly" style="font-size:8pt;" readonly="readonly" />
				</td></tr></table></td> </tr>
  <tr class="tabela"><td colspan="2"><div align="center">Composi&ccedil;&atilde;o do frete </div></td>
  </tr><tr><td colspan="2"><table width="100%" border="0" cellpadding="2" cellspacing="1"><tr>
				<td class="TextoCampos">Peso Taxado:</td>
				<td class="CelulaZebra2" colspan="2">
                    <input name="peso_taxado" type="text" id="peso_taxado" size="10" readonly="readonly" value="0" class="inputReadOnly8pt">&nbsp;kg</td>
				<td class="TextoCampos" colspan="9">
					<div align="center"><b>
					<label for="incluirIcms">Embutir no total da prestação:</label>
                    <input type="checkbox" id="incluirIcms" name="incluirIcms" onclick="$('addicms').value = this.checked; recalcular(false);" <%=(carregaconh && conh.isAddedIcms()? " checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>>ICMS
                    <input type="checkbox" id="incluirFederais" name="incluirFederais" onclick="recalcular(false);" <%=(carregaconh && conh.isIncluirFederais()? " checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>>
                    <label id="lbPisCofins">PIS/COFINS/IR/CSSL/INSS </label></b></div></td></tr>
              <tr>
                <td width="12%" class="TextoCampos" ><label id="lbTaxaFixa" name="lbTaxaFixa">Taxa Fixa:</label></td>
                <td width="6%" class="CelulaZebra2" ><input name="valor_taxa_fixa" type="text" id="valor_taxa_fixa" value="<%=conh.getValorTaxaFixa()%>" style="font-size:8pt;" size="6"
			                                     maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">                  </td>
                <td width="8%" class="TextoCampos" >ITR:</td>
                <td width="6%" class="CelulaZebra2" ><input name="valor_itr" type="text" id="valor_itr" style="font-size:8pt;" value="<%=Apoio.to_curr(conh.getValorITR())%>" size="6" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td width="8%" class="TextoCampos" >Despacho:</td>
                <td width="8%" class="CelulaZebra2" ><span class="CelulaZebra2">
                  <input name="valor_despacho" type="text" id="valor_despacho" value="<%=Apoio.to_curr(conh.getValorDespacho())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">
                </span></td>
                <td width="7%" class="TextoCampos" >ADEME:</td>
                <td width="8%" class="CelulaZebra2" ><input name="valor_ademe" type="text" id="valor_ademe" value="<%=Apoio.to_curr(conh.getValorAdeme())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td width="12%" class="TextoCampos" >
                    <div id="divLbCombinado" name="divLbCombinado">
                        <select id="slTipoCombinado" name="slTipoCombinado" class="fieldMin" onchange="javascript:recalcular(false);">
                            <option value="k" selected>R$/KG</option>
                            <option value="t">R$/TON</option>
                            <option value="v">R$/VOL</option>
                        </select>
                        <br>
                    </div>
                    <img src="img/calculadora.png" border="0" align="absbottom" class="imagemLink" title="Detalhar Cálculo Frete Peso" id="imgCombinado" name="imgCombinado" onClick="javascript:mostraCalculoCombinado(true);">
                    <b>
                        <label id="lbFretePeso" name="lbFretePeso">Frete Peso:</label>
                    </b>
                </td>
                <td width="7%" class="CelulaZebra2" >
                    <div id="divCombinado" name="divCombinado">
                        <input name="valor_peso_unitario" type="text" id="valor_peso_unitario" value="<%=Apoio.to_curr(conh.getValorUnitarioCombinado())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">
                        <br>
                    </div>
                    <input name="valor_peso" type="text" id="valor_peso" value="<%=Apoio.to_curr(conh.getValorPeso())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">
                </td>
                <td width="10%" class="TextoCampos" ><b><label id="lbFreteValor" name="lbFreteValor">Frete Valor:</label></b></td>
                <td width="8%" class="CelulaZebra2" ><input name="valor_frete" type="text" id="valor_frete" style="font-size:8pt;" value="<%=Apoio.to_curr(conh.getValorFrete())%>" size="6" maxlength="12" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
              </tr>
              <tr>
                <td class="TextoCampos" ><input name="calculaSecCat" id="calculaSecCat" type="hidden"  value="<%=conh.getCalculaSecCat()%>"><input name="isCalculaSecCat" type="checkbox" id="isCalculaSecCat" onclick="recalcular(false);limpaSecCat();" value="<%=conh.isIsCalculaSecCat()%>"<%=(carregaconh && conh.isIsCalculaSecCat() ? "checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>><label id="lbCalculaSecCat" name="lbCalculaSecCat">Cobrar </label><label id="lbSecCat" name="lbSecCat">SEC/CAT:</label></td>
                <td class="CelulaZebra2" ><input name="valor_sec_cat" type="text" id="valor_sec_cat" value="<%=Apoio.to_curr(conh.getValor_sec_cat())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td class="TextoCampos" >Outros:</td>
                <td class="CelulaZebra2" ><input name="valor_outros" type="text" id="valor_outros" value="<%=Apoio.to_curr(conh.getValorOutros())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td class="TextoCampos" >GRIS:</td>
                <td class="CelulaZebra2" ><input name="valor_gris" type="text" id="valor_gris" value="<%=Apoio.to_curr(conh.getValor_gris())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td class="TextoCampos" >Ped&aacute;gio:</td>
                <td class="CelulaZebra2" ><input name="valor_pedagio" type="text" id="valor_pedagio" value="<%=Apoio.to_curr(conh.getValor_pedagio())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td class="TextoCampos" ><input type="hidden" name="valor_tde_orcamento" id="valor_tde_orcamento" value="0.00"><input name="cobrarTde" type="checkbox" id="cobrarTde"
					       onclick="recalcular(false);" <%=(carregaconh && conh.isTde()? " checked " : "")%> <%=(conh.isQuitado() || conh.isCteBloqueado()?" disabled ":"")%>>
                  Cobrar TDE:</td>
                <td class="CelulaZebra2" ><input name="valor_tde" type="text" id="valor_tde" value="<%=Apoio.to_curr(conh.getValorTde())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td class="TextoCampos style1" >Desconto:</td>
                <td class="CelulaZebra2" ><input name="valor_desconto" type="text" id="valor_desconto" value="<%=Apoio.to_curr(conh.getValor_desconto())%>" size="6" maxlength="12" style="font-size:8pt;color:#FF0000" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
              </tr>
              <tr>
                <td class="TextoCampos" ><b>TOTAL PREST.:</b></td>
                <td class="CelulaZebra2" >
                    <input name="total" type="text" id="total" value="0.00" size="6" style="font-size:8pt;" class="inputReadOnly" readonly>
                    <input name="totalParcelas" id="totalParcelas" type="hidden" id="total" value="<%=Apoio.to_curr(conh.getTotalParcelas())%>">
                </td>
                <td class="TextoCampos" >Base c&aacute;lc.:</td>
                <td class="CelulaZebra2" >
					<input name="base_calculo" type="text" id="base_calculo" value="<%=Apoio.to_curr(conh.getBaseCalculo())%>" size="6" maxlength="12" style="font-size:8pt;" onBlur="javascript:seNaoFloatReset(this,document.getElementById('total').value);recalcular(false);" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado() || conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>">
					<input name="reducao_base_icms" type="hidden" id="reducao_base_icms" value="<%=conh.getReducaoBaseIcms()%>" size="8" maxlength="12" style="font-size:8pt;">
					<input type="hidden" id="config_reducao_base_icms" value="" size="8" maxlength="12" style="font-size:8pt;">
					<input name="is_in_gsf_598_03_go" type="hidden" id="is_in_gsf_598_03_go" value="<%=conh.isUtilizarNormativaGSF598GO()%>" size="8" maxlength="12" style="font-size:8pt;">
					<input name="valor_pauta_fiscal" type="hidden" id="valor_pauta_fiscal" value="<%=Apoio.to_curr(conh.getValorToneladaPautaFiscal())%>" size="8" maxlength="12" style="font-size:8pt;">
				</td>
                <td class="TextoCampos" >Al&iacute;q.(%):</td>
                <td class="CelulaZebra2" ><input name="aliquota" type="text" id="aliquota" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" style="font-size:8pt;" size="6" maxlength="5" value="<%=Apoio.to_curr(conh.getAliquota())%>" <%=(conh.isQuitado() || conh.isCteBloqueado()?"readonly":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>"></td>
                <td class="TextoCampos" >ICMS:</td>
                <td class="CelulaZebra2" ><input name="icms" type="text" id="icms" value="0.00" size="6" maxlength="12" style="font-size:8pt;" class="inputReadOnly" readonly></td>
                <td class="TextoCampos" ><label id="lbpis" name="lbpis">PIS/COFINS:</label></td>
                <td class="CelulaZebra2" ><input name="pisCofins" type="text" id="pisCofins" onBlur="javascript:seNaoFloatReset(this,'0.00');recalcular(false);" style="font-size:8pt;" size="6" maxlength="5" value="<%=Apoio.to_curr(conh.getValorFederaisImbutidos())%>"  class="inputReadOnly" readonly></td>
                <td class="TextoCampos" >ICMS Barreira:</td>
                <td class="CelulaZebra2" ><input type="text" id="vlicmsbarreira" name="vlicmsbarreira" class="fieldMin" size="6" maxlength="11" value="<%=Apoio.to_curr(conh.getIcmsBarreira())%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" style="font-size:8pt;"></td>
              </tr>
              <tr>
                  <td class="TextoCampos" >Situação ICMS:</td>
                  <td class="CelulaZebra2 <%=conh.getStIcms().getId()%>" colspan="11">
                      <select <%=(conh.isQuitado() || conh.isCteBloqueado()?"disabled":"")%> class="<%=(conh.isQuitado()|| conh.isCteBloqueado()?"inputReadOnly":"fieldMin")%>" <%=(((carregaconh && conh != null && conh.getCliente().getStIcms().getId() != 0) && !alteraIcms) ? " disabled " : ""  )%>  style="width: 200px" name="stIcms" id="stIcms" onchange="recalcular(false);">
                          <%for(SituacaoTributavel st: listaStIcms){%>
                          <option <%=(st.getId() == conh.getStIcms().getId() ? "selected" : "")%> value="<%=st.getId()%>"><%=st.getCodigo()+ " - "+ st.getDescricao()%></option>
                          <%}%>
                      </select></td></tr></table></td></tr>
  <tr><td colspan="12" class="tabela"><div align="center">Outras informa&ccedil;&otilde;es </div></td></tr>
  <tr>
    <td height="94" colspan="2" >
	  <table width="100%" border="0" cellpadding="1" cellspacing="1">
        <tr>
          <td width="3%" rowspan="7" class="TextoCampos">OBS:</td>
   	      <td width="34%" rowspan="7" class="CelulaZebra2">
	        <input name="obs_lin1" type="text" class="textfieldsObs" id="obs_lin1" value="<%=conh.getObservacao()[0]%>" size="99" maxlength="99">
            <input name="obs_lin2" type="text" class="textfieldsObs" id="obs_lin2" value="<%=conh.getObservacao()[1]%>" size="99" maxlength="99">
            <input name="obs_lin3" type="text" class="textfieldsObs" id="obs_lin3" value="<%=conh.getObservacao()[2]%>" size="99" maxlength="99">
            <input name="obs_lin4" type="text" class="textfieldsObs" id="obs_lin4" value="<%=conh.getObservacao()[3]%>" size="99" maxlength="99">
            <input name="obs_lin5" type="text" class="textfieldsObs" id="obs_lin5" value="<%=conh.getObservacao()[4]%>" size="99" maxlength="99">
		  </td>
   	      <td width="3%" rowspan="7"  class="CelulaZebra2"> <div align="left">
              <input type="button" class="botoes" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.OBSERVACAO%>', 'Observacao');">
          </div></td>

          <td width="13%"  class="TextoCampos">Hist&oacute;rico:  </td>
          <td width="50%" class="CelulaZebra2">
	    <input name="descricao_historico" type="text" id="descricao_historico" size="70" class="fieldMin" value="<%=(carregaconh ? conh.getHistorico() : "Frete")%>">
            <input type="button" class="botoes" id="model_hist" value="..." onClick="javascript:localizahistorico()">
	  </td>
          </div></td>
        </tr><tr><td  class="TextoCampos">Vendedor:</td><td class="CelulaZebra2"><input name="ven_rzs" type="text" id="ven_rzs" size="25" readonly class="inputReadOnly8pt" value="<%=(conh.getVendedor().getRazaosocial() != null? conh.getVendedor().getRazaosocial() : "")%>"><%if (conh.getPagamentoComissaoVendedor().getDespesa().getIdmovimento() == 0){%><input name="localiza_vendedor" type="button" class="botoes" id="localiza_vendedor" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VENDEDOR%>', 'Vendedor')"><img id="botao_vendedor" src="img/borracha.gif" border="0" class="imagemLink" onClick="limpaVendedor()"><%}%><label style="display:<%=(nvCom == 0 ? "none" : "")%>;"> %: </label><input name="comissao_vendedor" type="text" style="display:<%=(nvCom == 0 ? "none" : "")%>;" <%=conh.getPagamentoComissaoVendedor().getDespesa().getIdmovimento() == 0 ? "" : "readonly"%> id="comissao_vendedor"  value="<%=Apoio.to_curr(conh.getComissaoVendedor())%>" class="<%=conh.getPagamentoComissaoVendedor().getDespesa().getIdmovimento() == 0 ? "fieldMin" : "inputReadOnly8pt"%>" size="4" maxlength="12" onChange="javascript:seNaoFloatReset(this,'0.00');"><%if ( conh.getPagamentoComissaoVendedor().getId() != 0){%><label class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarPgtoComissao(<%=conh.getPagamentoComissaoVendedor().getId()%>,true);});">
                        Comissão Na despesa:<%=conh.getPagamentoComissaoVendedor().getDespesa().getIdmovimento()%></label><%}%></td></tr><tr><td class="TextoCampos">Representante Coleta:</td><td  class="CelulaZebra2">
                                <input type="hidden" name="repr_coleta_id" id="repr_coleta_id" value="<%=(carregaconh ? String.valueOf(conh.getRepresentante2().getIdfornecedor()) : "0")%>"><input name="repr_coleta" type="text" id="repr_coleta" value="<%=(conh.getRepresentante2().getRazaosocial() == null? "" : conh.getRepresentante2().getRazaosocial())%>" size="25" readonly class="inputReadOnly8pt"><%if ( conh.getPagamentoComissaoRepresentanteColeta().getDespesa().getIdmovimento() == 0){%><input name="localiza_repr_coleta" type="button" class="botoes" id="localiza_repr_coleta" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>&paramaux='+$('repr_coleta2_id').value, 'representante_coleta')"><img id="botao_redspt" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaRedespachante('c');"><%}%>
				Tabela:
				<select name="repr_coleta_tipo_taxa" id="repr_coleta_tipo_taxa" class="fieldMin" <%=conh.getPagamentoComissaoRepresentanteColeta().getDespesa().getIdmovimento() == 0 ? "" : "disabled" %> onChange="calculaVlRedespachante();">
					<option value="2" <%=(carregaconh && conh.getRepresentante2TipoTaxa() == 2 ? "selected" : "")%>>% sob Frete</option>  
					<option value="1" <%=(carregaconh && conh.getRepresentante2TipoTaxa() == 1 ? "selected" : "")%>>Sob peso</option>
					<option value="3" <%=(carregaconh && conh.getRepresentante2TipoTaxa() == 3 ? "selected" : "")%>>Combinado</option>
				</select> Valor:
                                <input name="repr_coleta_valor" type="text" class="inputReadOnly8pt" id="repr_coleta_valor" value="<%=Apoio.to_curr(conh.getRepresentante2Valor())%>" size="6" maxlength="12" onChange="javascript:seNaoFloatReset(this,'0');calculaVlRedespachante();" readonly>
                                <input type="hidden" name="comissaoBaixadaColeta" id="comissaoBaixadaColeta" value="<%=conh.getPagamentoComissaoRepresentanteColeta().getDespesa().getIdmovimento()%>">
                                <%if(conh.getPagamentoComissaoRepresentanteColeta().getDespesa().getIdmovimento() == 0){%>
                                    <input name="calc_repre_coleta" type="checkbox" class="inputReadOnly8pt" id="calc_repre_coleta" style="display: <%=conh.getId() > 0 ? "" : "none"%> ">
                                    <label style="display: <%=conh.getId() > 0 ? "" : "none"%>">Calcular ao salvar</label>
                                <%}%>
                                <%if ( conh.getPagamentoComissaoRepresentanteColeta().getDespesa().getIdmovimento() != 0 && conh.getPagamentoComissaoRepresentanteColeta().getId() != 0 ){%>
                                <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarPgtoComissao(<%=conh.getPagamentoComissaoRepresentanteColeta().getId()%>,true);});">Comissão na despesa: <%=conh.getPagamentoComissaoRepresentanteColeta().getDespesa().getIdmovimento()%></div>
                                <%}%></td></tr>
                                <tr><td class="TextoCampos">Representante Entrega:</td><td  class="CelulaZebra2">
                                <input type="hidden" name="repr_entrega_id" id="repr_entrega_id" value="<%=(carregaconh ? String.valueOf(conh.getRedespachante().getIdfornecedor()) : "0")%>">
				<input name="repr_entrega" type="text" id="repr_entrega" value="<%=(conh.getRedespachante().getRazaosocial() == null? "" : conh.getRedespachante().getRazaosocial())%>" size="25" readonly class="inputReadOnly8pt">
                                <%if ( conh.getPagamentoComissao().getDespesa().getIdmovimento() == 0 ){%>
                                    <input name="localiza_repr_entrega" type="button" class="botoes" id="localiza_repr_entrega" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>&paramaux='+$('repr_entrega2_id').value, 'representante_entrega')">
                                    <img id="botao_redspt" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaRedespachante('e');">
                                <%}%> Tabela:
				<select name="repr_entrega_tipo_taxa" id="repr_entrega_tipo_taxa" <%=conh.getPagamentoComissao().getDespesa().getIdmovimento() == 0 ? "" : "disabled"%> class="fieldMin" onChange="calculaVlRedespachante();">
					<option value="2" <%=(carregaconh && conh.getRedespachanteTipoTaxa() == 2 ? "selected" : "")%>>% sob Frete</option>
					<option value="1" <%=(carregaconh && conh.getRedespachanteTipoTaxa() == 1 ? "selected" : "")%>>Sob peso</option>
					<option value="3" <%=(carregaconh && conh.getRedespachanteTipoTaxa() == 3 ? "selected" : "")%>>Combinado</option>
				</select> Valor:
                                        <input name="repr_entrega_valor" type="text" readonly="true" class="inputReadOnly8pt" id="repr_entrega_valor" value="<%=Apoio.to_curr(conh.getRedespachanteValor())%>" size="6" maxlength="12" onChange="javascript:seNaoFloatReset(this,'0');calculaVlRedespachante();">
                                        <input type="hidden" name="comissaoBaixada" id="comissaoBaixada" value="<%=conh.getPagamentoComissao().getDespesa().getIdmovimento()%>">
                                <%if(conh.getPagamentoComissao().getDespesa().getIdmovimento() == 0){%>
                                    <input name="calc_repre_entrega" type="checkbox" class="inputReadOnly8pt" id="calc_repre_entrega" style="display: <%=conh.getId() > 0 ? "" : "none"%>" ><label style="display: <%=conh.getId() > 0 ? "" : "none"%>">Calcular ao salvar</label><%}%>
                                <%if(conh.getPagamentoComissao().getDespesa().getIdmovimento() != 0){%>
                                    <div class="linkEditar" align="center" onclick="javascript:tryRequestToServer(function(){editarPgtoComissao(<%=conh.getPagamentoComissao().getId()%>,true);});">Comissão na despesa: <%=conh.getPagamentoComissao().getDespesa().getIdmovimento()%></div><%}%>
                                
        <tr id='img_rep2'>
                <td class="CelulaZebra2NoAlign" colspan="2">
                    <img src="img/plus.jpg" id="plus_rep2" name="plus_rep2" title="Mostrar duplicatas" class="imagemLink" style="<%= conh.getRepresentanteColeta2().getIdfornecedor() != 0 ||  conh.getRepresentanteEntrega2().getIdfornecedor() != 0 ? "display:none" : "" %>"
                         onclick="javascript:mostrarEsconde('plus_rep2');" align="left" >
                    <img src="img/minus.jpg" id="minus_rep2" name="minus_rep2" title="Mostrar duplicatas" class="imagemLink" style="<%= conh.getRepresentanteColeta2().getIdfornecedor() != 0 ||  conh.getRepresentanteEntrega2().getIdfornecedor() != 0 ? "" : "display:none" %>"
                         onclick="javascript:mostrarEsconde('minus_rep2');" align="left" >
                    Mostrar Representantes de coleta2 e entrega2
                </td>
        </tr>
          <tr id="repColeta2" style="<%= conh.getRepresentanteColeta2().getIdfornecedor() != 0 ||  conh.getRepresentanteEntrega2().getIdfornecedor() != 0 ? "" : "display:none" %>">
            <td class="textoCampos">
                Representante Coleta2:
            </td>
            <td class="celulaZebra2">
                <input type="hidden" name="repr_coleta2_id" id="repr_coleta2_id" value="<%=(carregaconh ? String.valueOf(conh.getRepresentanteColeta2().getIdfornecedor()) : "0")%>">
                <input name="repr_coleta2" type="text" id="repr_coleta2" value="<%=(conh.getRepresentanteColeta2().getRazaosocial() == null? "" : conh.getRepresentanteColeta2().getRazaosocial())%>" size="25" readonly class="inputReadOnly8pt">
                <%if ( conh.getPagamentoComissaoRepresentanteColeta2().getDespesa().getIdmovimento() == 0){%>
                    <input name="localiza_repr_coleta" type="button" class="botoes" id="localiza_repr_coleta" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>&paramaux='+$('repr_coleta_id').value, 'representante_coleta2')">
                    <img id="botao_redspt" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaRedespachante('c2');">
                <%}%>
                Valor: <input name="repr_coleta2_valor" type="text" class="<%=conh.getPagamentoComissaoRepresentanteColeta2().getDespesa().getIdmovimento() == 0 ? "inputTexto" : "inputReadOnly8pt"%>" id="repr_coleta2_valor" value="<%=Apoio.to_curr(conh.getRepresentanteColeta2Valor())%>" size="6" <%=conh.getPagamentoComissaoRepresentanteColeta2().getDespesa().getIdmovimento() == 0 ? "" : "readonly"%> maxlength="12" onChange="javascript:seNaoFloatReset(this,'0');calculaVlRedespachante();">
                <%if(conh.getPagamentoComissaoRepresentanteColeta2().getDespesa().getIdmovimento() != 0){%>
                <div class="linkEditar" align="center" onclick="javascript:tryRequestToServer(function(){editarPgtoComissao(<%=conh.getPagamentoComissaoRepresentanteColeta2().getId()%>,true);});">Comissão na despesa: <%=conh.getPagamentoComissaoRepresentanteColeta2().getDespesa().getIdmovimento()%></div>
                <%}%>
            </td>
        </tr>
          <tr id="repEntrega2" style="<%= conh.getRepresentanteColeta2().getIdfornecedor() != 0 ||  conh.getRepresentanteEntrega2().getIdfornecedor() != 0 ? "" : "display:none" %>">
            <td class="textoCampos">
                Representante Entrega2:
            </td>
            <td class="celulaZebra2">
                <input type="hidden" name="repr_entrega2_id" id="repr_entrega2_id" value="<%=(carregaconh ? String.valueOf(conh.getRepresentanteEntrega2().getIdfornecedor()) : "0")%>">
                <input name="repr_entrega2" type="text" id="repr_entrega2" value="<%=(conh.getRepresentanteEntrega2().getRazaosocial() == null? "" : conh.getRepresentanteEntrega2().getRazaosocial())%>" size="25" readonly class="inputReadOnly8pt">
                <%if ( conh.getPagamentoComissaoRepresentante2().getDespesa().getIdmovimento() == 0 ){%>
                    <input name="localiza_repr_entrega2" type="button" class="botoes" id="localiza_repr_entrega2" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>&paramaux='+$('repr_entrega_id').value, 'representante_entrega2')">
                    <img id="botao_redspt" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaRedespachante('e2');">
                <%}%>
                Valor: <input name="repr_entrega2_valor" type="text" class="<%=conh.getPagamentoComissaoRepresentante2().getDespesa().getIdmovimento() == 0 ? "inputTexto" : "inputReadOnly8pt"%>" id="repr_entrega2_valor" value="<%=Apoio.to_curr(conh.getRepresentanteEntrega2Valor())%>" size="6" <%=conh.getPagamentoComissaoRepresentante2().getDespesa().getIdmovimento() == 0 ? "" : "readonly"%>  maxlength="12" onChange="javascript:seNaoFloatReset(this,'0');calculaVlRedespachante();">
                <%if(conh.getPagamentoComissaoRepresentante2().getDespesa().getIdmovimento() != 0){%>
                    <div class="linkEditar" align="center" onclick="javascript:tryRequestToServer(function(){editarPgtoComissao(<%=conh.getPagamentoComissaoRepresentante2().getId()%>,true);});">Comissão na despesa: <%=conh.getPagamentoComissaoRepresentante2().getDespesa().getIdmovimento()%></div>
                <%}%>
            </td>
          </tr><%if ( conh.getPagamentoComissao().getDespesa().getIdmovimento() != 0 && conh.getPagamentoComissao().getId() != 0 ){%><%-- retirei tava carregando na aba abaixo de outras informações<div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarPgtoComissao(<%=conh.getPagamentoComissao().getId()%>,true);});">Comissão na despesa: <%=conh.getPagamentoComissao().getDespesa().getIdmovimento()%></div>--%><%}%></td></tr></table></td></tr>
  <tr><td colspan="2"><div align="center" class="tabela">Dados do embarque/entrega </div></td></tr>
  <tr style="display:<%=acao.equals("editar")?"":"none"%>;">
	<td colspan="2">
		<table width="100%"  border="0" cellspacing="1" cellpadding="2">
			<tr><td width="8%" class="TextoCampos">Manifesto:</td><td width="11%" class="CelulaZebra2"><%if (acao.equals("editar")){if (nvMan > 0){%>
							<label id="lbManifesto" name="lbManifesto" onclick="window.open('./cadmanifesto?acao=editar&id=<%=conh.getManifesto().getIdmanifesto()%>&ex=false', 'Manifesto' , 'top=0,resizable=yes,status=1,scrollbars=1')" class="linkEditar"> <%=(carregaconh && (conh.getManifesto().getNmanifesto() != null) ? conh.getManifesto().getNmanifesto() : "")%> </label>
						<%}else{%>
							<label id="lbManifesto" name="lbManifesto"><%=(carregaconh && (conh.getManifesto().getNmanifesto() != null) ? conh.getManifesto().getNmanifesto() : "")%></label>
						<%}
					}else{%>
						<label id="lbManifesto" name="lbManifesto"></label>
					<%}%>
				</td>
				<td width="12%" class="TextoCampos">Contrato de frete:</td>
				<td width="9%" class="CelulaZebra2">
					<%if (acao.equals("editar")){
						if (nvCarta > 0){%>
							<label id="lbCarta" name="lbCarta" onclick="verCarta(<%=conh.getManifesto().getIdCartaFrete()%>, '<%=conh.getFilial().getStUtilizacaoCfe()%>');" class="linkEditar"> <%=(carregaconh && (conh.getManifesto().getIdCartaFrete() != 0) ? conh.getManifesto().getIdCartaFrete() : "")%></label>
						<%}else{%>
							<label id="lbCarta" name="lbCarta"><%=(carregaconh && (conh.getManifesto().getIdCartaFrete() != 0) ? conh.getManifesto().getIdCartaFrete() : "")%></label>
						<%}
					}else{%><label id="lbCarta" name="lbCarta"></label><%}%>
				</td>
				<td width="5%" class="TextoCampos">ADV:</td>
				<td width="7%" class="CelulaZebra2">
					<%if (acao.equals("editar")){
						if (nvADV > 0){%><label id="lbADV" name="lbADV" onclick="window.open('./cadviagem.jsp?acao=editar&id=<%=conh.getViagem().getId()%>&ex=false', 'Adiantamento_Viagem' , 'top=0,resizable=yes,status=1,scrollbars=1')" class="linkEditar"> <%=(carregaconh && (conh.getViagem().getId() != 0) ? conh.getViagem().getNumViagem() : "")%> </label>
						<%}else{%><label id="lbADV" name="lbADV"> <%=(carregaconh && (conh.getViagem().getId() != 0) ? conh.getViagem().getNumViagem() : "")%> </label><%}
					}else{%><label id="lbADV" name="lbADV"></label><%}%>
				</td>
				<td width="7%" class="TextoCampos">Romaneio:</td>
				<td width="7%" class="CelulaZebra2">
				<%if (acao.equals("editar")){
					if (nvRom > 0){%>
						<label onclick="window.open('./cadromaneio?acao=editar&id=<%=conh.getRomaneio().getIdRomaneio()%>&ex=false', 'Manifesto' , 'toolbar=no,left=0,top=0,location=no,status=no,menubar=no,scrollbars=yes,resizable=no')" class="linkEditar"> <%=(carregaconh && (conh.getRomaneio().getNumRomaneio() != null) ? conh.getRomaneio().getNumRomaneio() : "")%> </label>
					<%}else{%>
						<label> <%=(carregaconh && (conh.getRomaneio().getNumRomaneio() != null) ? conh.getRomaneio().getNumRomaneio() : "")%> </label>
					<%}
				}%>
				</td>
				<td width="7%" class="TextoCampos">Nº AWB:</td>
				<td width="7%" class="CelulaZebra2">
					<%if (acao.equals("editar")){
						if (nvAWB > 0){%>
							<label id="lbAWB" name="lbAWB" onclick="window.open('./cadawb.jsp?acao=editar&id=<%=conh.getAwb().getId()%>&ex=false', 'AWB' , 'top=0,resizable=yes,status=1,scrollbars=1')" class="linkEditar"><%=(carregaconh && (conh.getAwb().getId() != 0) ? conh.getAwb().getNumero() : "")%></label>
						<%}else{%>
							<label id="lbAWB" name="lbAWB"><%=(carregaconh && (conh.getAwb().getId() != 0) ? conh.getAwb().getNumero() : "")%></label>
						<%}
					}else{%>
						<label id="lbAWB" name="lbAWB"></label>
					<%}%>
				</td>
				<td width="7%" class="TextoCampos">Nº Vôo:</td>
				<td width="8%" class="CelulaZebra2">
				<%if (acao.equals("editar")){
                                if (nvAWB > 0){%>
					<label id="lbVoo" name="lbVoo"> <%=(carregaconh && (conh.getAwb().getId() != 0) ? conh.getAwb().getNumeroVoo() : "")%> </label>
					<%}else{%><label id="lbVoo" name="lbVoo"> <%=(carregaconh && (conh.getAwb().getId() != 0) ? conh.getAwb().getNumeroVoo() : "")%> </label><%}
					}else{%><label id="lbVoo" name="lbVoo"></label><%}%>
				</td>
				<td width="5%" class="TextoCampos"></td>
				</td></tr></table></td>
  </tr>
  <tr>
	<td colSpan="2">
        <div id="tbAeroporto" name="tbAeroporto">
            <table  width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
                <tr><td width="50%"><table width="100%" border="0" cellpadding="0" cellspacing="1">
                            <tr class="CelulaZebra2">
                  		<td width="15%" class="CelulaZebra2"><div align="right">Aeroporto de Origem:</div></td>
				<td width="35%" class="CelulaZebra2">
                                   <input name="aeroporto_origem" type="text" id="aeroporto_origem" size="40" value="<%=(carregaconh ? conh.getAeroportoOrigem().getNome(): "")%>"  class="inputReadOnly8pt">
                                   <strong><input name="localiza_aer" type="button" class="botoes" id="localiza_aer" value="..." onClick="javascript:localizaaeroportoorigem();"></strong>                                        
				</td>
                                <td width="15%" class="CelulaZebra2"><div align="right">Aeroporto de Destino:</div></td>
                                <td width="35%" class="CelulaZebra2">                                
                                    <input name="aeroporto_destino" type="text" id="aeroporto_destino" size="40" value="<%=(carregaconh ? conh.getAeroportoDestino().getNome(): "")%>"  class="inputReadOnly8pt">
                                    <strong><input name="localiza_aerdest" type="button" class="botoes" id="localiza_aerdest" value="..." onClick="javascript:localizaaeroportodestino();"></strong> 
                                </td></tr></table></td></tr></table></div>
		<table width="100%">
			<tr class="celula">
				<td width="12%">Prev. entrega</td>
				<td width="15%">Saída</td>
				<td width="15%">Chegada</td>
				<td width="28%">Entrega</td>
				<td width="10%">Avaria</td>
				<td width="20%"></td>
			</tr>
			<tr>
				<td class="CelulaZebra2"><input name="dtprevisao" type="text" id="dtprevisao" value="<%=(carregaconh ? Apoio.fmt(conh.getPrevisaoEntrega()) : "")%>" style="font-size:8pt;" class="fieldDate" size="10" maxlength="10" onBlur="javascript:(alertInvalidDate(this,true));" onBlur="javascript:compareDate();"></td>
				<td class="CelulaZebra2"><%=(carregaconh? (conh.getManifesto().getDtsaida() != null? formatDate.format(conh.getManifesto().getDtsaida()) + " às " + conh.getManifesto().getHrsaida() : "") : "")%></td>
                                <td class="CelulaZebra2"><%=(carregaconh? (conh.getChegadaEm() != null? formatDate.format(conh.getChegadaEm()) + " às " + conh.getChegadaAs() : "") : "")%></td>
				<td class="CelulaZebra2"><%=(carregaconh && conh.getBaixaEm() != null? formatDate.format(conh.getBaixaEm()) + " às " + conh.getEntregaAs() + " por " + conh.getBaixadoPor().getLogin() : "") %></td>
				<td class="CelulaZebra2"><%=(carregaconh ? (conh.getValorAvaria() == 0 ? "" : Apoio.to_curr(conh.getValorAvaria())) + (conh.getFaturaAvaria().getId() == 0 ? "" : " paga na fatura " + conh.getFaturaAvaria().getNumero() + "/" + conh.getFaturaAvaria().getAnoFatura()):"")%></td>
				<td class="CelulaZebra2"></td>
			</tr>
		</table>
	</td>
  </tr>
  <tr>
	<td colspan="2">
		<table width="100%"  border="0" cellspacing="1" cellpadding="2">
			<tr><td width = "7%" class="TextoCampos">
                                    <label id="labMotorista">Motorista</label>:
                                </td>
				<td width = "30%" class="CelulaZebra2">
					<input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" value="<%=(carregaconh?conh.getMotorista().getNome():"")%>" size="33"  readonly="true">
                                        <%if (conh.getManifesto().getNmanifesto()  == null || acao.equals("iniciar")){%>
                                                <%if (!(conh.getStatusCte().equals("C") && conh.getModalCte().equals("l") && Apoio.isApenasNumeros(conh.getSerie()))){ %>
                                                    <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&paramaux=carta&paramaux2='+($('tipoproduto').value == 0 ? ' is null ' : ' = ' + $('tipoproduto').value )+'&paramaux3='+$('id_rota_viagem').value+'&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista');" style="font-size:8pt;">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
                                                <% } %>
					<%}%>
					<input type="hidden" id="impedir_viagem_motorista" name="impedir_viagem_motorista" value="f">
					<input type="hidden" name="idproprietarioveiculo" id="idproprietarioveiculo" value="0">
					<input type="hidden" name="perc_adiant" id="perc_adiant" value="0">
					<input type="hidden" name="is_tac" id="is_tac" value="f">
                    <input type="hidden" id="percentual_valor_cte_calculo_cfe" name="percentual_valor_cte_calculo_cfe">
                    <input type="hidden" id="tipo_calculo_percentual_valor_cfe" name="tipo_calculo_percentual_valor_cfe">
				</td><td width = "6%" class="TextoCampos" ><label id="labVeiculo">Veículo</label>:
                                </td>
				<td width = "15%" class="CelulaZebra2">
					<input name="tipo_veiculo_motorista" type="hidden" id="tipo_veiculo_motorista" class="inputReadOnly8pt" value="0" size="9" readonly="true">
                                        <input name="tipo_veiculo_veiculo" type="hidden" id="tipo_veiculo_veiculo" class="inputReadOnly8pt" value="0" size="9" readonly="true">
                                        <input name="tipo_veiculo_carreta" type="hidden" id="tipo_veiculo_carreta" class="inputReadOnly8pt" value="0" size="9" readonly="true">
					<input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" value="<%=(carregaconh?conh.getVeiculo().getPlaca():"")%>" size="9" readonly="true">
					<%if (conh.getManifesto().getNmanifesto()  == null || acao.equals("iniciar")){%>
						<%if (!(conh.getStatusCte().equals("C") && conh.getModalCte().equals("l") && Apoio.isApenasNumeros(conh.getSerie()))){ %>
                                                    <input name="localiza_cavalo" type="button" class="botoes" id="localiza_cavalo" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&paramaux2='+($('tipoproduto').value == 0 ? ' is null ' : ' = ' + $('tipoproduto').value )+'&paramaux3='+$('id_rota_viagem').value+'&idlista=<%=BeanLocaliza.VEICULO%>', 'Veiculo');" style="font-size:8pt;">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Veículo" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';$('is_obriga_carreta').value = 'false';validarTipoVeiculo('v');">
                                                <%} %>
					<%} %>
				</td>
				<td width = "6%" class="TextoCampos">
                                    <label id="labCarreta">Carreta</label>:
                                </td>
				<td width = "15%" class="CelulaZebra2">
					<input name="car_placa" type="text" id="car_placa" class="inputReadOnly8pt" value="<%=(carregaconh && conh.getCarreta().getPlaca() != null ? conh.getCarreta().getPlaca():"")%>" size="9" readonly="true">
					<%if (conh.getManifesto().getNmanifesto() == null || acao.equals("iniciar")){%>
						<%if (!(conh.getStatusCte().equals("C") && conh.getModalCte().equals("l") && Apoio.isApenasNumeros(conh.getSerie()))){ %>
                                                    <input name="localiza_carreta" type="button" class="botoes" id="localiza_carreta" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&paramaux2='+($('tipoproduto').value == 0 ? ' is null ' : ' = ' + $('tipoproduto').value )+'&paramaux3='+$('id_rota_viagem').value+'&idlista=<%=BeanLocaliza.CARRETA%>', 'Carreta');" style="font-size:8pt;">
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="javascript:getObj('idcarreta').value = 0;javascript:getObj('car_placa').value = '';validarTipoVeiculo('c');">
                                                <%} %>
					<%} %>
				</td>
				<td width = "6%" class="TextoCampos">
                                    <label id="labBiTrem">Bi-trem</label>:
                                </td>
				<td width = "15%" class="CelulaZebra2">
					<input name="bi_placa" type="text" id="bi_placa" class="inputReadOnly8pt" value="<%=(carregaconh && conh.getBiTrem().getPlaca() != null ? conh.getBiTrem().getPlaca():"")%>" size="9" readonly="true">
					<%if (conh.getManifesto().getNmanifesto() == null || acao.equals("iniciar")){%>
                                            <%if (!(conh.getStatusCte().equals("C") && conh.getModalCte().equals("l") && Apoio.isApenasNumeros(conh.getSerie()))){ %>
                                                <input name="localiza_bitrem" type="button" class="botoes" id="localiza_bitrem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.BITREM%>', 'BiTrem');" style="font-size:8pt;">
                                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Remetente" onClick="javascript:getObj('idbitrem').value = 0;javascript:getObj('bi_placa').value = '';">
                                            <%} %>
					<%} %></td></tr></table></td></tr>
  <tr>
    <td colspan="2" >
		<table width="100%" border="0" cellpadding="0" cellspacing="1">
     <tr style="display:<%=cfg.isCartaFreteAutomatica() && acao.equals("iniciar") ? "" : "none" %>">
		<td width="100%" colspan="6" >
			<table width="100%"  border="0" cellspacing="1" cellpadding="2">
				<tr>
					<td colspan="2" class="tabela">
						<div align="center">
							<input name="chk_carta_automatica" type="checkbox" id="chk_carta_automatica" value="checkbox"> Gerar Contrato de Frete com o Proprietário
						</div>
					</td>
					<td colspan="2" class="tabela">
						<div align="center">
							<input name="chk_adv_automatica" type="checkbox" id="chk_adv_automatica" value="checkbox"> Gerar Adiantamento de viagem para o motorista da casa
						</div>
					</td>
				</tr>
				<tr>
					<td width="10%" class="TextoCampos">Proprietário:</td>
					<td width="40%" class="CelulaZebra2">
						<input name="vei_prop" type="text" id="vei_prop" class="inputReadOnly8pt" size="40" readonly="true" value="">
						<input name="vei_prop_cgc" type="text" id="vei_prop_cgc" class="inputReadOnly8pt" size="20" readonly="true" value="">
						<input name="plano_proprietario" type="hidden" id="plano_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="und_proprietario" type="hidden" id="und_proprietario" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_rota" type="hidden" id="valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_maximo_rota" type="hidden" id="valor_maximo_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="tipo_valor_rota" type="hidden" id="tipo_valor_rota" class="inputReadOnly8pt" size="20" readonly="true" value="f">
						<input name="debito_prop" type="hidden" id="debito_prop" size="10" value="0">
						<input name="percentual_desconto_prop" type="hidden" id="percentual_desconto_prop" size="10" value="0">
						<input name="percentual_ctrc_contrato_frete" type="hidden" id="percentual_ctrc_contrato_frete" size="10" value="0">
						<input name="valor_rota_viagem_2" type="hidden" id="valor_rota_viagem_2" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_pedagio_rota" type="hidden" id="valor_pedagio_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="valor_entrega_rota" type="hidden" id="valor_entrega_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="qtd_entregas_rota" type="hidden" id="qtd_entregas_rota" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="base_ir_prop_retido" type="hidden" id="base_ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="ir_prop_retido" type="hidden" id="ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="base_inss_prop_retido" type="hidden" id="base_inss_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
						<input name="inss_prop_retido" type="hidden" id="inss_prop_retido" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
						<input name="tipo_desconto_prop" type="hidden" id="tipo_desconto_prop" value="0.00">
						<input name="is_deduzir_pedagio" type="hidden" id="is_deduzir_pedagio" value="false">
						<input name="is_carregar_pedagio_ctes" type="hidden" id="is_carregar_pedagio_ctes" value="false">
                        <input name="motorista_valor_minimo" type="hidden" id="motorista_valor_minimo" value="0.00">
                        <input name="rota_valor_minimo" type="hidden" id="rota_valor_minimo" value="0.00">
					</td>
					<td width="50%" colspan="2" rowspan="5" style="vertical-align:top;">
						<table width="100%" border="0" cellspacing="1" cellpadding="2">
                                                    <tbody id="tbADV">
							<tr class="celula">
								<td width="3%" ><img src="img/add.gif" border="0" onClick="incluiADV();" title="Adicionar um adiantamento para o motorista" class="imagemLink"></td>
								<td width="19%" ><div align="center">Valor</div></td>
								<td width="35%" ><div align="center">Conta</div></td>
								<td width="23%" ></td>
								<td width="20%" ><div align="center">Doc</div></td>
							</tr>
                                                    </tbody>
							<tr>
                                                                <td colspan="4" class="TextoCampos">
									Valor Previsto para as Despesas de Viagem: 
								</td>
                                                                <td class="CelulaZebra2">
									<input name="valorPrevistoViagem" type="text" class="fieldmin" id="valorPrevistoViagem" value="0.00" size="8" maxlength="12" onchange="seNaoFloatReset(this, '0.00');">
								</td>
							</tr>
							<tr class="celula">
								<td ><img src="img/add.gif" border="0" onClick="incluiDespesaADV();" title="Adicionar despesa a prazo para o adiantamento de viagem" class="imagemLink"></td>
								<td colspan="4">Despesas de viagem</td>
							</tr>
							<tr>
								<td colspan="5">
									<table width="100%" border="0" cellspacing="1" cellpadding="2">
										<tbody id="tbDespesaADV">
										</tbody></table></td></tr></table></td></tr>
				<tr>
					<td class="TextoCampos">Seguradora:</td>
					<td class="CelulaZebra2">
						<input name="nome_seguradora" type="text" id="nome_seguradora" class="inputReadOnly8pt" size="27" readonly="true" value="">
						<input name="localiza_seguradora" type="button" class="botoes" id="localiza_seguradora" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=57','Seguradora','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
						Liberação:<input name="motor_liberacao" type="text" id="motor_liberacao" class="fieldMin" size="15" value="">
						<input name="seguradora_id" type="hidden" id="seguradora_id" class="inputReadOnly8pt" size="20" readonly="true" value="0">
					</td>
				</tr>
				<tr><td colSpan="2"><table width="100%" border="0" cellspacing="1" cellpadding="2"><tr>
								<td class="TextoCampos" width="25%">Agente de carga:</td>
								<td class="CelulaZebra2" width="75%">
									<input name="nome_agente_carga" type="text" id="nome_agente_carga" class="inputReadOnly8pt" value="<%=(carregaconh?conh.getMotorista().getNome():"")%>" size="40"  readonly="true">
									<input name="localiza_agente_carga" type="button" class="botoes" id="localiza_agente_carga" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.AGENTE_CARGA%>', 'Agente_carga');" style="font-size:8pt;">
									<img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Agente de Carga" onClick="javascript:getObj('idagente_carga').value = 0;javascript:getObj('nome_agente_carga').value = '';">
									<input type="hidden" id="idagente_carga" name="idagente_carga" value="0">
								</td></tr>
							<tr><td class="TextoCampos">Observação:</td><td class="CelulaZebra2"><input name="obs_carta_frete" type="text" id="obs_carta_frete" class="fieldMin" value="" size="60" >
                                                            </td></tr></table></td>
                                <tr>
                                    <td colspan="2">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                        <tr>
                                            <td class="TextoCampos" width="25%">Natureza da Carga: </td>
                                            <td class="CelulaZebra2" width="75%">
                                                <input type="text"class="inputReadOnly8pt" name="natureza_cod_desc" id="natureza_cod_desc" readonly size="4">
                                                <input type="text"class="inputReadOnly8pt" name="natureza_desc" id="natureza_desc" size="23" readonly >
                                                <input type="hidden" name="natureza_cod" id="natureza_cod"/>
                                                <input type="button" class="inputBotaoMin" id="botaoCarreta" onclick="abrirLocalizaNatureza()" value="..." />
                                            </td>
                                        <tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="1" cellpadding="2">
							<tr class="Celula">
                                                                <td width="8%" >Vl. Ton</td>
								<td width="8%" >Frete</td>
								<td width="8%" >Outros</td>
								<td width="8%" >Pedágio</td>
                                                                <td width="15%" class="style1"><input name="chk_reter_impostos" type="checkbox" id="chk_reter_impostos" value="checkbox" onClick="calcularFreteCarreteiro();" <%=nivelAlteraImpostos  ? "" : "disabled =true" %> >Impostos</td>
								<td width="16%" class="style1" >Desconto</td>
                                <td width="8%" class="style1" ${(not configuracao.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}><label for="abastecimentos">Abast.</label></td>
								<td width="15%" >Líquido</td>
							</tr>
							<tr>
                                                            <td class="CelulaZebra2"><input name="cartaValorTonelada" type="text" id="cartaValorTonelada" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');validarFreteCarreteiro();calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2"><input name="cartaValorFrete" type="text" id="cartaValorFrete" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');validarFreteCarreteiro();calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2"><input name="cartaOutros" type="text" id="cartaOutros" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2"><input name="cartaPedagio" type="text" id="cartaPedagio" value="0.00" size="8" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();"></td>
								<td class="CelulaZebra2"><input name="cartaImpostos" type="text" id="cartaImpostos" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" onBlur="javascript:seNaoFloatReset(this,'0.00');" readOnly>
                                                                    <img src="img/calculadora.png" border="0" align="absbottom" class="imagemLink" title="Detalhar Impostos" onClick="$('trImpostosCarta').style.display = '';"></td>
                                <td class="CelulaZebra2">
                                    <input id="percentualRetencao" name="percentualRetencao" type="text"
                                           class="fieldMin style1" size="5" maxlength="9" value="0"
                                           onchange="seNaoFloatReset(this, '0.00'); calcularFreteCarreteiro();">&nbsp;%
                                    <input name="cartaRetencoes" type="text" id="cartaRetencoes"
                                                                value="0.00" size="8" maxlength="12"
                                                                class="fieldMin style1"
                                                                onBlur="javascript:seNaoFloatReset(this,'0.00');calcularFreteCarreteiro();">
									<input name="mot_outros_descontos_carta" type="hidden" id="mot_outros_descontos_carta" value="0.00" size="8" maxlength="12">
                                    <c:set var="cfg" value="<%=cfg%>" />
                                    <c:choose>
                                        <c:when test="${param.acao eq 'iniciar' && cfg.tipoVlConMotor eq 'f' && cfg.vlConMotor != 0}">
                                            <script>
                                                $('cartaRetencoes').value = colocarVirgula(parseFloat('${cfg.vlConMotor}'));
                                                readOnly($('percentualRetencao'), 'inputReadOnly8pt');
                                            </script>
                                        </c:when>
                                        <c:when test="${param.acao eq 'iniciar' && cfg.tipoVlConMotor eq 'p' && cfg.vlConMotor != 0}">
                                            <script>
                                                $('percentualRetencao').value = parseFloat('${cfg.vlConMotor}');
                                                readOnly($('cartaRetencoes'), 'inputReadOnly8pt');
                                            </script>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td class="celulaZebra2 style1" ${(not cfg.descontoAutomaticoAbastecimento) ? "style='display: none;'" : ""}>
                                    <input id="abastecimentos" name="abastecimentos" type="text"
                                           class="fieldMin style1 inputReadOnly" size="9" maxlength="9" value="0,00"
                                           onchange="seNaoFloatReset(this, '0,00')" readonly>
                                    <input type="hidden" name="ids_abastecimentos" id="ids_abastecimentos">
                                </td>
								<td class="CelulaZebra2"><input name="cartaLiquido" type="text" id="cartaLiquido" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt" readonly onBlur="javascript:seNaoFloatReset(this,'0.00');"></td>
							</tr>
							<tr id="trImpostosCarta" name="trImpostosCarta" style="display:none;">
								<td class="TextoCampos">INSS:</td>
								<td class="CelulaZebra2"><input name="valorINSS" type="text" id="valorINSS" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                                    <input name="valorINSSInteg" type="hidden" id="valorINSSInteg" value="0.00" size="8" maxlength="12">
                                                                    <input name="baseINSS" type="hidden" id="baseINSS" value="0.00" size="8" maxlength="12">
                                                                    <input name="aliqINSS" type="hidden" id="aliqINSS" value="0.00" size="8" maxlength="12"></td>
								<td class="TextoCampos">SEST:</td>
								<td class="CelulaZebra2"><input name="valorSEST" type="text" id="valorSEST" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                                    <input name="valorSESTInteg" type="hidden" id="valorSESTInteg" value="0.00" size="8" maxlength="12">
                                                                    <input name="baseSEST" type="hidden" id="baseSEST" value="0.00" size="8" maxlength="12">
                                                                    <input name="aliqSEST" type="hidden" id="aliqSEST" value="0.00" size="8" maxlength="12"></td>
								<td class="TextoCampos">IR:</td>
								<td class="CelulaZebra2"><input name="valorIR" type="text" id="valorIR" value="0.00" size="8" maxlength="12" class="inputReadOnly8pt style1" readonly>
                                                                    <input name="valorIRInteg" type="hidden" id="valorIRInteg" value="0.00" size="8" maxlength="12">
                                                                    <input name="baseIR" type="hidden" id="baseIR" value="0.00" size="8" maxlength="12">
                                                                    <input name="aliqIR" type="hidden" id="aliqIR" value="0.00" size="8" maxlength="12"></td>
                                                                <td class="TextoCampos"></td>
							</tr></table></td></tr>
				<tr><td colspan="2">
						<table width="100%" border="0" cellspacing="1" cellpadding="2">
							<tr class="Celula">
								<td width="10%"><img src="img/add.gif" border="0" onClick="adicionarAdiantamento();" title="Adicionar Adiantamento" class="imagemLink"></td>
								<td width="12%">Valor</td>
								<td width="18%">Data</td>
								<td width="17%">F. Pag</td>
								<td width="28%">Conta/Ag.Pag.</td>
								<td width="15%">Doc</td>
							</tr>
							<tr>
								<td class="TextoCampos">Adiant.:</td>
                                                                <td class="TextoCampos"><input name="cartaValorAdiantamento" type="text" id="cartaValorAdiantamento" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('a');calcularAdiantamento();"></td>
								<td class="TextoCampos"><input name="cartaDataAdiantamento" type="text" id="cartaDataAdiantamento" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onBlur="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos">
									<select name="cartaFPagAdiantamento" id="cartaFPagAdiantamento" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('a');">
            
                                                                                <%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
                                                                                        BeanUsuario autenticado = Apoio.getUsuario(request);
                                                                                        for(BeanFPag fp: BeanConsultaFPag.mostrarTudoCartaFrete(autenticado.getConexao(), String.valueOf(autenticado.getFilial().getStUtilizacaoCfe()))){
                                                                                            fpagCartaFrete += "<option value='"+fp.getIdFPag()+"' " + (fp.getIdFPag() == cfg.getFpag().getIdFPag() ? "selected" : "") +" >"+fp.getDescFPag()+"</option>";
                                                                                }}%>
										<%=fpagCartaFrete%>
                                                                                
									</select>
                                                                        <select id="formaPagamentoAdiantamento" name="formaPagamentoAdiantamento" class="fieldMin" style="width:70px;" >
                                                                            <option value="M">Manual</option>
                                                                            <option value="A">Automática</option>
                                                                        </select>
                                                                        </td>
                                                                    <td class="TextoCampos">
									<select name="contaAdt" id="contaAdt" class="fieldMin" style="width:120px;display:none;" onChange="javascript:alteraFpag('a');">
										<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
											BeanConsultaConta contaAd = new BeanConsultaConta();
											contaAd.setConexao(Apoio.getUsuario(request).getConexao());
											contaAd.mostraContas(0, true, limitarUsuarioVisualizarContas, idUsuario);
											ResultSet rsC = contaAd.getResultado();
											while (rsC.next()){%>
												<option value="<%=rsC.getString("idconta")%>"><%=rsC.getString("numero") +"-"+ rsC.getString("digito_conta") +" / "+ rsC.getString("banco")%></option>
											<%}rsC.close();
										}%>
									</select>
                                                                        <select name="contaAdtFavorecido" id="contaAdtFavorecido" class="fieldMin" style="width:70px;display:none;">
                                                                            <option value="t">Terceiro</option>
                                                                            <option value="m">Motorista</option>
                                                                            <option value="p">Propietário</option>
                                                                        </select>
									<input name="agente" type="text" id="agente" class="inputReadOnly8pt" size="15" readonly="true" value="" style="display:none;">
									<input name="localiza_agente_adiantamento" type="button" class="botoes" id="localiza_agente_adiantamento" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=16','Agente','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" style="display:none;">
									<input name="idagente" type="hidden" id="idagente" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="plano_agente" type="hidden" id="plano_agente" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="und_agente" type="hidden" id="und_agente" class="inputReadOnly8pt" size="15" readonly="true" value="0">
								</td>
								<td class="CelulaZebra2">
									<%if (cfg.isControlarTalonario()){%>
										<select name="cartaDocAdiantamento_cb" id="cartaDocAdiantamento_cb" class="fieldMin">
										</select>
									<%}else{%>
										<input name="cartaDocAdiantamento" type="text" id="cartaDocAdiantamento" size="6" maxlength="12" class="fieldMin">
									<%}%>
								</td>
							</tr>
                                                        <tr id="cartaAdiantamentoExtra1" style="display: none">
								<td class="TextoCampos">Adiant.:</td>
                                                                <td class="TextoCampos"><input name="cartaValorAdiantamentoExtra1" type="text" id="cartaValorAdiantamentoExtra1" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpagExtra1('a');calcularAdiantamento();"></td>
								<td class="TextoCampos"><input name="cartaDataAdiantamentoExtra1" type="text" id="cartaDataAdiantamentoExtra1" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onBlur="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos">
									<select name="cartaFPagAdiantamentoExtra1" id="cartaFPagAdiantamentoExtra1" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpagExtra1('a');">
										<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
											BeanConsultaFPag fpagExtra1 = new BeanConsultaFPag();
											fpagExtra1.setConexao(Apoio.getUsuario(request).getConexao());
											fpagExtra1.MostrarTudoCartaFrete(String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()));
											ResultSet rsFpagExtra1 = fpagExtra1.getResultado();
											while (rsFpagExtra1.next()){
												fpagCartaFreteExtra1 += "<option value='"+rsFpagExtra1.getString("idfpag")+"' " + (rsFpagExtra1.getInt("idfpag") == cfg.getFpag().getIdFPag() ? "selected" : "") +" >"+rsFpagExtra1.getString("descfpag")+"</option>";
											}
											rsFpagExtra1.close();
                						}%>
										<%=fpagCartaFreteExtra1%>
									</select>
                                                                </td>
                                                                <td class="TextoCampos">
 									<select name="contaAdtExtra1" id="contaAdtExtra1" class="fieldMin" style="width:120px;display:none;" onChange="javascript:alteraFpagExtra1('a');">
										<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
											BeanConsultaConta contaAdExtra1 = new BeanConsultaConta();
											contaAdExtra1.setConexao(Apoio.getUsuario(request).getConexao());
											contaAdExtra1.mostraContas(0, true, limitarUsuarioVisualizarContas, idUsuario);
											ResultSet rsCExtra1 = contaAdExtra1.getResultado();
											while (rsCExtra1.next()){%>
												<option value="<%=rsCExtra1.getString("idconta")%>"><%=rsCExtra1.getString("numero") +"-"+ rsCExtra1.getString("digito_conta") +" / "+ rsCExtra1.getString("banco")%></option>
											<%}rsCExtra1.close();
										}%>
									</select>
                                                                         <select name="contaAdtFavorecido1" id="contaAdtFavorecido1" style="width:70px; display:none;" class="fieldMin">
                                                                            <option value="t">Terceiro</option>
                                                                            <option value="m">Motorista</option>
                                                                            <option value="p">Propietário</option>
                                                                        </select>
                                                                </td>
								<td class="CelulaZebra2">
									<%if (cfg.isControlarTalonario()){%>
										<select name="cartaDocAdiantamento_cbExtra1" id="cartaDocAdiantamento_cbExtra1" class="fieldMin"></select>
									<%}else{%>
										<input name="cartaDocAdiantamentoExtra1" type="text" id="cartaDocAdiantamentoExtra1" size="6" maxlength="12" class="fieldMin">
									<%}%></td></tr>
                                                        <tr id="cartaAdiantamentoExtra2" style="display: none">
								<td class="TextoCampos">Adiant.:</td>
                                                                <td class="TextoCampos"><input name="cartaValorAdiantamentoExtra2" type="text" id="cartaValorAdiantamentoExtra2" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpagExtra2('a');calcularAdiantamento();"></td>
								<td class="TextoCampos"><input name="cartaDataAdiantamentoExtra2" type="text" id="cartaDataAdiantamentoExtra2" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onBlur="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos">
									<select name="cartaFPagAdiantamentoExtra2" id="cartaFPagAdiantamentoExtra2" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpagExtra2('a');">
										<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
											BeanConsultaFPag fpagExtra2 = new BeanConsultaFPag();
											fpagExtra2.setConexao(Apoio.getUsuario(request).getConexao());
											fpagExtra2.MostrarTudoCartaFrete(String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()));
											ResultSet rsFpagExtra2 = fpagExtra2.getResultado();
											while (rsFpagExtra2.next()){
												fpagCartaFreteExtra2 += "<option value='"+rsFpagExtra2.getString("idfpag")+"' " + (rsFpagExtra2.getInt("idfpag") == cfg.getFpag().getIdFPag() ? "selected" : "") +" >"+rsFpagExtra2.getString("descfpag")+"</option>";
											}
											rsFpagExtra2.close();
                						}%>
										<%=fpagCartaFreteExtra2%></select></td>
                                                                    <td class="TextoCampos">
									<select name="contaAdtExtra2" id="contaAdtExtra2" class="fieldMin" style="width:120px;display:none;" onChange="javascript:alteraFpagExtra2('a');">
										<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){
											BeanConsultaConta contaAdExtra2 = new BeanConsultaConta();
											contaAdExtra2.setConexao(Apoio.getUsuario(request).getConexao());
											contaAdExtra2.mostraContas(0, true, limitarUsuarioVisualizarContas, idUsuario);
											ResultSet rsCExtra2 = contaAdExtra2.getResultado();
											while (rsCExtra2.next()){%>
												<option value="<%=rsCExtra2.getString("idconta")%>"><%=rsCExtra2.getString("numero") +"-"+ rsCExtra2.getString("digito_conta") +" / "+ rsCExtra2.getString("banco")%></option>
											<%}rsCExtra2.close();
										}%>
									</select>
                                                                         <select name="contaAdtFavorecido2" id="contaAdtFavorecido2" class="fieldMin" style="width:70px;display:none;">
                                                                            <option value="t">Terceiro</option>
                                                                            <option value="m">Motorista</option>
                                                                            <option value="p">Propietário</option>
                                                                        </select>
                                                                    </td>
								<td class="CelulaZebra2">
									<%if (cfg.isControlarTalonario()){%>
										<select name="cartaDocAdiantamento_cbExtra2" id="cartaDocAdiantamento_cbExtra2" class="fieldMin"></select>
									<%}else{%>
										<input name="cartaDocAdiantamentoExtra2" type="text" id="cartaDocAdiantamentoExtra2" size="6" maxlength="12" class="fieldMin">
									<%}%>
								</td>
							</tr>
							<tr>
								<td class="TextoCampos">Saldo:</td>
								<td class="TextoCampos"><input name="cartaValorSaldo" type="text" id="cartaValorSaldo" value="0.00" size="6" maxlength="12" class="fieldMin" onBlur="javascript:seNaoFloatReset(this,'0.00');alteraFpag('s');alteraFpagExtra2(s);alteraFpagExtra2('s');"></td>
								<td class="TextoCampos"><input name="cartaDataSaldo" type="text" id="cartaDataSaldo" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onBlur="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos">
									<select name="cartaFPagSaldo" id="cartaFPagSaldo" class="fieldMin" style="width:70px;" onChange="javascript:alteraFpag('s');alteraFpagExtra1('s');alteraFpagExtra2('s');alteraFpagSaldo()">
										<%if (cfg.isCartaFreteAutomatica() && acao.equals("iniciar")){%>
											<%=fpagCartaFrete%>
                						<%}%>
									</select>
								</td>
								<td class="TextoCampos">
                                                                    <span class="TextoCampos" name="lblfavorecido" id="lblfavorecido" style="display:none">Favorecido:</span>
                                                                        <select name="cartaFPagSaldoFavorecido" id="cartaFPagSaldoFavorecido" class="fieldMin" style="width:70px;display:none;">
                                                                            <option value="t">Terceiro</option>
                                                                            <option value="m">Motorista</option>
                                                                            <option value="p">Propietário</option>
                                                                        </select>
									<input name="agentesaldo" type="text" id="agentesaldo" class="inputReadOnly8pt" size="15" readonly="true" value="" style="display:none;">
									<input name="localiza_agente_saldo" type="button" class="botoes" id="localiza_agente_saldo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=19','Agente_Saldo','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" style="display:none;">
									<input name="idagentesaldo" type="hidden" id="idagentesaldo" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="plano_agente_saldo" type="hidden" id="plano_agente_saldo" class="inputReadOnly8pt" size="15" readonly="true" value="0">
									<input name="und_agente_saldo" type="hidden" id="und_agente_saldo" class="inputReadOnly8pt" size="15" readonly="true" value="0">
								</td>
								<td class="CelulaZebra2"><input name="cartaDocSaldo" type="text" id="cartaDocSaldo" size="6" maxlength="12" class="fieldMin"></td>
							</tr>
							<tr name="trCartaCC" id="trCartaCC" style="display:none;">
								<td class="TextoCampos">C/C.:</td>
								<td class="TextoCampos"><input name="cartaValorCC" type="text" id="cartaValorCC" value="0.00" size="6" maxlength="12" class="fieldMin" readonly></td>
								<td class="TextoCampos"><input name="cartaDataCC" type="text" id="cartaDataCC" value="<%=(Apoio.getDataAtual())%>" class="fieldDate" onBlur="javascript:alertInvalidDate(this);" size="9" maxlength="10" style="font-size:8pt;"></td>
								<td class="TextoCampos"><input name="cartaFPagCC" type="hidden" id="cartaFPagCC" value="2"></td>
								<td class="TextoCampos"><input name="contaCC" type="hidden" id="contaCC" value="<%=(cfg.getContaAdiantamentoFornecedor().getIdConta())%>"></td>
								<td class="CelulaZebra2"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="1" cellpadding="2">
							<tr class="celula">
								<td width="5%">
									<img src="img/add.gif" border="0" onClick="incluiDespesaCarta();" title="Adicionar uma despesa" class="imagemLink">
								</td>
								<td colspan="5" width="95%">Despesas de viagem</td>
							</tr>
							<tr id="trDespesaCarta" name="trDespesaCarta" style="display:none;" >
								<td colspan="6">
									<input name="fornecedor" type="hidden" id="fornecedor" class="inputReadOnly8pt" size="15" readonly="true" value="Fornecedor">
									<input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
									<input name="idplanocusto_despesa" type="hidden" id="idplanocusto_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="0">
									<input name="plcusto_descricao_despesa" type="hidden" id="plcusto_descricao_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
									<input name="plcusto_conta_despesa" type="hidden" id="plcusto_conta_despesa" class="inputReadOnly8pt" size="25" readonly="true" value="">
									<input name="idplcustopadrao" type="hidden" id="idplcustopadrao" class="inputReadOnly8pt" size="25" readonly="true" value="0">
									<input name="descricaoplcusto" type="hidden" id="descricaoplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
									<input name="contaplcusto" type="hidden" id="contaplcusto" class="inputReadOnly8pt" size="25" readonly="true" value="">
									<table width="100%"><tbody id="tbDespesaCarta"></tbody>
									</table></td></tr></table></td></tr></table></td>
     </tr>
    </table></td></tr><tr>
  <%if (carregaconh){%>
    <tr><td colspan="2"><div align="center" class="tabela">Auditoria</div></td></tr>
	<tr><td colspan="2" >
      <table width="100%" border="0"><tr>
          <td class="TextoCampos">Lan&ccedil;ado em: </td>
          <td class="CelulaZebra2"> <input name="dtlancamento" type="text" id="dtlancamento" value="<%=(conh.getCreatedAt() != null? formatDate.format(conh.getCreatedAt()) : "")%>" size="10" readonly class="inputReadOnly8pt"></td>
          <td class="TextoCampos">Por:</td>
          <td class="CelulaZebra2"><input name="usuariolancamento" type="text" id="usuariolancamento" value="<%=(conh.getCreatedBy() != null? conh.getCreatedBy().getNome() : "")%>" size="30" readonly class="inputReadOnly8pt"></td>
          <td class="TextoCampos">Alterado em:</td>
          <td class="CelulaZebra2"><input name="dtalteracao" type="text" id="dtalteracao" value="<%=(conh.getUpdatedAt() != null ? formatDate.format(conh.getUpdatedAt()) : "")%>" size="10" maxlength="10" readonly class="inputReadOnly8pt"></td>
          <td class="TextoCampos">Por:</td>
          <td class="CelulaZebra2"><input name="usuarioalteracao" type="text" id="usuarioalteracao" value="<%=conh.getUpdatedBy().getNome()%>" size="30" readonly class="inputReadOnly8pt"></td>
        </tr></table>
	</td></tr>
  <%}%>
</table><br></div>   
<input type="hidden" id="is_importado_edi" name="is_importado_edi" value="false">
<input type="hidden" id="is_travar_campos" name="is_travar_campos" value="<%= conh.getCliente().isTravaCamposImportacao() %>">
</form>
</body>
</html>
