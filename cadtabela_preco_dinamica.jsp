<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@page import="cidade.BeanCidade"%>
<%@page import="area.CadArea"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="nucleo.*,
           java.text.DecimalFormat,
           java.text.SimpleDateFormat,
           tipo_veiculos.*,
           java.sql.ResultSet,
           java.util.Vector,
           cliente.BeanCadTabelaCliente, cliente.BeanTabelaCliente" errorPage="" %>

  <script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
  <script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
  <script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>

  <%
  //Permissao do usuário nessa página
  int nivelUser = Apoio.getUsuario(request).getAcesso("cadcliente");
  int nivelUserTabela = (Apoio.getUsuario(request) != null
          ? Apoio.getUsuario(request).getAcesso("cadtabelacliente") : 0);

  //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = request.getParameter("acao");
  BeanTabelaCliente tab = null;
  BeanCadTabelaCliente cadTab = null;
  CadArea areaOrigem = null;
  CadArea areaDestino = null;
  BeanCidade cidOrigem = null;
  BeanCidade cidDestino = null;
  SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
  Collection<BeanTabelaCliente> listaTabela = new ArrayList<BeanTabelaCliente>();
  Iterator iListaTabela = null;
  FaixaPeso fxx = new FaixaPeso();
  ResultSet rsFaixa = fxx.all(Apoio.getUsuario(request).getConexao());
  fxx = null;
  FaixaPeso fxp = null;
  BeanCadTabelaCliente allA = new BeanCadTabelaCliente();
  allA.allAereo();


  if (acao != null){
    //instrucoes incomuns entre as acoes
    if (acao.equals("incluir") || acao.equals("atualizar") || acao.equals("carregarTabelaAjax"))
    { //instanciando o bean de cadastro
      cadTab = new BeanCadTabelaCliente();
      cadTab.setConexao(Apoio.getUsuario(request).getConexao());
      cadTab.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if (acao.equals("visualizar")){

      tab = new BeanTabelaCliente();
      tab.getCliente().setIdcliente((request.getParameter("remetenteId") == null ? 0 : Integer.parseInt(request.getParameter("remetenteId"))));
      tab.getCidadeOrigem().setIdcidade((request.getParameter("idcidadeorigem_loc") == null ? 0 : Integer.parseInt(request.getParameter("idcidadeorigem_loc"))));
      tab.getCidadeDestino().setIdcidade((request.getParameter("idcidadedestino_loc") == null ? 0 : Integer.parseInt(request.getParameter("idcidadedestino_loc"))));
      tab.getAreaOrigem().setId((request.getParameter("idareaorigem_loc") == null ? 0 : Integer.parseInt(request.getParameter("idareaorigem_loc"))));
      tab.getAreaDestino().setId((request.getParameter("idareadestino_loc") == null ? 0 : Integer.parseInt(request.getParameter("idareadestino_loc"))));
      tab.getTipoProduto().setId((request.getParameter("tipo_produto_id_loc") == null ? 0 : Integer.parseInt(request.getParameter("tipo_produto_id_loc"))));
      if(request.getParameter("tipoPesq") != null && request.getParameter("tipoPesq").equals("grupo")){
        tab.getCliente().getGcf().setId((request.getParameter("grupo_id") == null ? 0 : Integer.parseInt(request.getParameter("grupo_id"))));
      }
      cadTab = new BeanCadTabelaCliente();
      cadTab.setConexao(Apoio.getUsuario(request).getConexao());
      cadTab.setExecutor(Apoio.getUsuario(request));
      cadTab.setTabela(tab);
      listaTabela = cadTab.LoadAllPropertysVarias();
    } else if (acao.equals("carregarTabelaAjax")){

        cadTab.getTabela().getCliente().setIdcliente(Integer.parseInt(request.getParameter("idCliente")));
        cadTab.getTabela().getCidadeOrigem().setIdcidade(Apoio.parseInt(request.getParameter("idcidadeorig")));
        cadTab.getTabela().getCidadeDestino().setIdcidade(Apoio.parseInt(request.getParameter("idcidadedest")));
        cadTab.getTabela().getTipoProduto().setId(Apoio.parseInt(request.getParameter("tp_prod_id")));
        cadTab.getTabela().getAreaOrigem().setId(Apoio.parseInt(request.getParameter("idareaorig")));
        cadTab.getTabela().getAreaDestino().setId(Apoio.parseInt(request.getParameter("idareadest")));

        response.getWriter().append(cadTab.AjaxLoadAllVarias());
        response.getWriter().close();
        
    } else if (acao.equals("atualizar") || acao.equals("incluir")){
			//Buscando os tipos de veiculos
			Tipo_veiculos tipoVei = new Tipo_veiculos();
			Vector tipos = new Vector();
			ResultSet rsTpVei = tipoVei.all(Apoio.getUsuario(request).getConexao());
			while (rsTpVei.next()){
				tipos.add(rsTpVei.getInt("id"));
			}
			rsTpVei.close();
                        /*
			//Buscando os tipos de veiculos
			FaixaPeso faixa = new FaixaPeso();
			Vector fPeso = new Vector();
			rsFaixa = faixa.all(Apoio.getUsuario(request).getConexao());
			while (rsFaixa.next()){
				fPeso.add(rsFaixa.getInt("id"));
			}
			rsFaixa.close();
			*/
			//Preenchendo o array das tabelas
			int qtdTabelas = Integer.parseInt(request.getParameter("qtdTabelas"));
			BeanTabelaCliente[] arTabela = new BeanTabelaCliente[qtdTabelas];
                        //- Airton - / - Data - 12/08/2016
			BeanTabelaCliente[] arTabelaClonado = new BeanTabelaCliente[qtdTabelas];
                        BeanCadTabelaCliente cadTabClonado = null; 
                        BeanTabelaCliente tabClonado = null;
                        BeanTabelaCliente tb = null;
			int xy = 0;
			for (int x = 0; x < qtdTabelas; x++){
				if(request.getParameter("tipo"+x) != null){
					tb = new BeanTabelaCliente();
					tb.setId(acao.equals("atualizar") ? Integer.parseInt(request.getParameter("tabela"+x)) : 0);
					tb.getCliente().setIdcliente(Integer.parseInt(request.getParameter("remetenteId")));
					tb.getTipoProduto().setId(Integer.parseInt(request.getParameter("idProduto"+x))); 
                	tb.setTipoRota(request.getParameter("tipo"+x)); 
                	tb.getCidadeOrigem().setIdcidade(Integer.parseInt(request.getParameter("idOrigem"+x)));
	                tb.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("idDestino"+x)));
	                tb.getAreaOrigem().setId(Integer.parseInt(request.getParameter("idOrigem"+x)));
	                tb.getAreaDestino().setId(Integer.parseInt(request.getParameter("idDestino"+x)));
	                tb.setValorPeso(Float.parseFloat(request.getParameter("valorPeso_"+x)));
	                tb.setBaseCubagem(Float.parseFloat(request.getParameter("baseCub_"+x)));
	                tb.setValorVolume(Float.parseFloat(request.getParameter("valorVolume_"+x)));
	                tb.setPercentualNf(Float.parseFloat(request.getParameter("percentualNf_"+x)));
	                tb.setBaseNfPercentual(Float.parseFloat(request.getParameter("basePercentual_"+x)));
	                tb.setValorPercentualNf(Float.parseFloat(request.getParameter("valorPercentual_"+x)));
	                tb.setPercentualGris(Float.parseFloat(request.getParameter("valorGris_"+x)));
	                tb.setPercentualAdValorEm(Float.parseFloat(request.getParameter("valorSeguro_"+x)));
	                tb.setValorDespacho(Float.parseFloat(request.getParameter("valorDespacho_"+x)));
	                tb.setValorOutros(Float.parseFloat(request.getParameter("valorOutros_"+x)));
	                tb.setValorTaxaFixa(Float.parseFloat(request.getParameter("valorTaxa_"+x)));
                        tb.setValorExcedente(Float.parseFloat(request.getParameter("valor_excedente_"+x)));//Campo adcionado dia 30-01-2014
                        tb.setValorExcedenteAereo(Float.parseFloat(request.getParameter("valor_excedente_aereo_"+x)));//Campo adcionado dia 30-01-2014
                        //novos campos
                        tb.setTipoFretePeso(request.getParameter("tipoPeso_"+x));
                        tb.setIncluirFederais(request.getParameter("IncluiPisCofins_"+x).equals("S"));
                        tb.setValorMinimoGris(Double.parseDouble(request.getParameter("valorMinimoGris_"+x)));
                        tb.setValorPedagio(Float.parseFloat(request.getParameter("valorPedagio_"+x)));
                        tb.setQtdQuiloPedagio(Apoio.parseInt(request.getParameter("qtdQuiloPedagio_"+x), "#0"));
                        tb.setValorDificuldadeEntrega(Double.parseDouble(request.getParameter("valorTde_"+x)));
                        tb.setTipoTde(request.getParameter("tipoTde_"+x));
                        tb.setCalculaSecCat(request.getParameter("calculaSecCat_"+x));
                        tb.setDataVigencia((request.getParameter("dataVigenciaLote_"+x).trim().equals("")?null:Apoio.paraDate(request.getParameter("dataVigenciaLote_"+x))));
                        tb.setPrazoEntrega(Integer.parseInt(request.getParameter("prazoEntrega_"+x)));
                        tb.setPrazoEntregaAereo(Integer.parseInt(request.getParameter("prazoEntregaAereo_"+x)));
                        tb.setTipoDiasEntrega(request.getParameter("tipoDiasEntrega_"+x));
                        tb.setTipoTaxa(Apoio.parseInt(request.getParameter("tipoTaxa_"+x)));
                        tb.setTipoDiasEntregaAereo(request.getParameter("tipoDiasEntregaAereo_"+x));
                        tb.setValidaAte((request.getParameter("validaAte_"+x).trim().equals("")?null:Apoio.paraDate(request.getParameter("validaAte_"+x))));
                        tb.setPercentualDevolucao(Double.parseDouble(request.getParameter("percentualDevolucao_"+x)));
                        tb.setPercentualReentrega(Double.parseDouble(request.getParameter("percentualReentrega_"+x)));
                        tb.setValorSecCat(Double.parseDouble(request.getParameter("valorSecCat_"+x)));
                        tb.setDesconsideraIcmsMinimo(Boolean.parseBoolean(request.getParameter("desconsideraIcmsPisCofins_"+x)));
                        tb.setDesconsideraDespachoMinimo(Boolean.parseBoolean(request.getParameter("desconsideraDespacho_"+x)));
                        tb.setDesconsideraGrisMinimo(Boolean.parseBoolean(request.getParameter("desconsideraGris_"+x)));
                        tb.setDesconsideraOutrosMinimo(Boolean.parseBoolean(request.getParameter("desconsideraOutros_"+x)));
                        tb.setDesconsideraPedagioMinimo(Boolean.parseBoolean(request.getParameter("desconsideraPedagio_"+x)));
                        tb.setDesconsideraSeguroMinimo(Boolean.parseBoolean(request.getParameter("desconsideraSeguro_"+x)));
                        tb.setDesconsideraSeccatMinimo(Boolean.parseBoolean(request.getParameter("desconsideraSecCat_"+x)));
                        tb.setDesconsideraTaxaMinimo(Boolean.parseBoolean(request.getParameter("desconsideraTaxaFixa_"+x)));
	                tb.setValorFreteMinimo(Float.parseFloat(request.getParameter("freteMinimo_"+x)));
	                tb.setIncluiIcms(request.getParameter("IncluiIcms_"+x).equals("S"));
	                tb.setPrecoTonelada(request.getParameter("ton"+x).equals("S"));
                        tb.setTipoImpressaoFreteMinimo(request.getParameter("tipoImpressaoFreteMinimo_"+x));
                        tb.setTaxaApartirEntrega(Apoio.parseInt(request.getParameter("entregaMontagem_"+ x)));
                        tb.setValorExcedenteTaxaFixa(Apoio.parseDouble(request.getParameter("valorExcedenteTaxaFixa_"+ x)));
                        tb.setPesoLimiteTaxaFixa(Apoio.parseDouble(request.getParameter("pesoLimiteTaxaFixa_"+ x)));
                        tb.setValorExcedenteSecCat(Apoio.parseDouble(request.getParameter("valorExcedenteSecCat_"+ x)));
                        tb.setPesoLimiteSecCat(Apoio.parseDouble(request.getParameter("pesoLimiteSecCat_"+ x)));
                        tb.setTipoInclusaoIcms(request.getParameter("tipoInclusaoIcms_"+ x));
                        tb.setConsiderarMaiorPeso(Apoio.parseBoolean(request.getParameter("chkConsiderarPeso_" + x)));
                        tb.setConsiderarValorMaiorPesoNota(Apoio.parseBoolean(request.getParameter("chkConsiderarMaiorValor_" + x)));
                        //Novo campo - Airton - / - Data - 11/08/2016
                        tb.setFreteIdaVolta(Apoio.parseBoolean(request.getParameter("chkFreteIdaVolta_" + x)));
                        
                        //formulas
                        tb.setFormulaDespacho(request.getParameter("formulaDespacho_"+x).trim());
                        tb.setFormulaGris(request.getParameter("formulaGris_"+x).trim());
                        tb.setFormulaMinimo(request.getParameter("formulaFreteMinimo_"+x).trim());
                        tb.setFormulaOutros(request.getParameter("formulaOutros_"+x).trim());
                        tb.setFormulaSecCat(request.getParameter("formulaSecCat_"+x).trim());
                        tb.setFormulaSeguro(request.getParameter("formulaSeguro_"+x).trim());
                        tb.setFormulaTaxaFixa(request.getParameter("formulaTaxaFixa_"+x).trim());
                        tb.setFormulaTDE(request.getParameter("formulaTDE_"+x).trim());
                        tb.setFormulaFretePeso(request.getParameter("formulaFretePeso_"+x).trim());
                        tb.setValorPallet(Apoio.parseFloat(request.getParameter("valorPallets_"+x).trim()));
                        //tb.setformula

                        //Tipos de veículos
	                Tipo_veiculos tipo[] = new Tipo_veiculos[ tipos.size() ];
	                for (int i = 0; i < tipos.size(); i++) {
	    				Tipo_veiculos tp = new Tipo_veiculos();
	    				tp.setId(Integer.parseInt(tipos.get(i).toString()));
	    				tp.setValorCombinado(Float.parseFloat(request.getParameter("valorCombinado_"+x)));
	    				tipo[i] = tp;
	                }
	                tb.setTipoVeiculo(tipo);

                        //faixa de peso
                        //gambiarra
                        String teste = request.getParameter("maxFaixaTFM_"+x);
                        if(!teste.equals("")){
                            int maxFaixa = Integer.parseInt(teste);
                            FaixaPeso faixaPeso[] = new FaixaPeso[maxFaixa+1];
                            for (int i = 0; i <= maxFaixa; i++) {
                                            FaixaPeso fx = new FaixaPeso();
                                            fx.setId(Integer.parseInt(request.getParameter("idFaixa_"+x+"_tfm_"+i)));
                                            fx.setPesoInicial(Float.parseFloat(request.getParameter("pesoInicio_"+x+"_tfm_"+i)));
                                            fx.setPesoFinal(Float.parseFloat(request.getParameter("pesoFinal_"+x+"_tfm_"+i)));
                                            fx.setValorFaixa(Float.parseFloat(request.getParameter("valorPeso_"+x+"_tfm_"+i)));
                                            fx.setTipoValor(request.getParameter("slc_"+x+"_tfm_"+i));

                                            faixaPeso[i] = fx;
                            }
                            tb.setFaixasPeso(faixaPeso);
                        }
                        
                        //faixa de peso
                        teste = request.getParameter("maxFaixaAerea_"+x);
                            
                        if(!teste.equals("")){
                            int maxFaixaAe = Integer.parseInt(teste);
                            FaixaPeso faixaPesoAe[] = new FaixaPeso[maxFaixaAe+1];
                            for (int i = 0; i <= maxFaixaAe; i++) {
                                            FaixaPeso fx = new FaixaPeso();
                                            fx.setId(Integer.parseInt(request.getParameter("idFaixa_"+x+"_a_"+i)));
                                            fx.setPesoInicial(Float.parseFloat(request.getParameter("pesoInicio_"+x+"_a_"+i)));
                                            fx.setPesoFinal(Float.parseFloat(request.getParameter("pesoFinal_"+x+"_a_"+i)));
                                            fx.setValorFaixa(Float.parseFloat(request.getParameter("valorPeso_"+x+"_a_"+i)));
                                            fx.setTipoValor(request.getParameter("slc_"+x+"_a_"+i));
                                            faixaPesoAe[i] = fx;
                            }
                            
                            tb.setFaixasPesoAereo(faixaPesoAe);
                        }
                        
                        String max = request.getParameter("maxTVeiculo") != null ? request.getParameter("maxTVeiculo") : "0";
                        int maxTipoVeiculo = Apoio.parseInt(max);

                        //Só entrará no for se tiver tipo de veiculos
                        if(maxTipoVeiculo > 0){
                            Tipo_veiculos tVeiculo[] = new Tipo_veiculos[maxTipoVeiculo+1];
                            for (int i = 0; i <= maxTipoVeiculo; i++) {
                                            Tipo_veiculos tp = new Tipo_veiculos();
                                            
                                            tp.setId(Integer.parseInt(request.getParameter("idtveiculo_"+x+"_"+i) != null ? request.getParameter("idtveiculo_"+x+"_"+i) : "0"));
                                            tp.setValorPedagio(Apoio.parseFloat(request.getParameter("valorPedagio_"+x+"_"+i) != null ? request.getParameter("valorPedagio_"+x+"_"+i) : "0"));
                                            tp.setLimitePedagio(Apoio.parseInt(request.getParameter("limitePedagio_"+x+"_"+i) != null ? request.getParameter("limitePedagio_"+x+"_"+i) : "0"));
                                            tp.setValorCombinado(Float.parseFloat(request.getParameter("valorCombinado_"+x+"_"+i) != null ? request.getParameter("valorCombinado_"+x+"_"+i) : "0"));
                                            tp.setTipoTaxa(Apoio.parseInt(request.getParameter("tipoTaxa_"+x+"_"+i) != null ? request.getParameter("tipoTaxa_"+x+"_"+i) : "1"));
                                            tVeiculo[i] = tp;
                            }
                            tb.setTipoVeiculo(tVeiculo);
                        }
	                
                        if (tb.isFreteIdaVolta()) {
                
                            cadTabClonado = new BeanCadTabelaCliente();
                            cadTabClonado.setConexao(Apoio.getUsuario(request).getConexao());
                            cadTabClonado.setExecutor(Apoio.getUsuario(request));


                            tabClonado = tb.getClone();

                            if (tb.getTipoRota().equals("c")) {
                                tabClonado.setCidadeOrigem(tb.getCidadeDestino());
                                tabClonado.setCidadeDestino(tb.getCidadeOrigem());
                            } else if (tb.getTipoRota().equals("a")) {
                                tabClonado.setAreaOrigem(tb.getAreaDestino());
                                tabClonado.setAreaDestino(tb.getAreaOrigem());
                            }

                            arTabelaClonado[xy] = tabClonado;
                            cadTabClonado.setArrayTab(arTabelaClonado);
                            
                        }                       
                        
	                arTabela[xy] = tb;
	        	    xy++;
				}				        	   
			}

			cadTab = new BeanCadTabelaCliente();
			cadTab.setConexao(Apoio.getUsuario(request).getConexao());
			cadTab.setExecutor(Apoio.getUsuario(request));
			cadTab.setArrayTab(arTabela);
                        
			boolean erro = false;
			if (acao.equals("atualizar")){
				erro =!cadTab.AtualizaVarias();
			}else if (acao.equals("incluir") && nivelUser >= 3){
				erro = !cadTab.IncluiVarias();
                                if (!erro && cadTabClonado != null) {
                                    erro = !cadTabClonado.IncluiVarias();
                                }
			}
		
			String scr = "";
                        
			if (erro){
				scr = "<script>" +
				      "window.opener.document.getElementById('gravar').disabled = false;" +
				      "window.opener.document.getElementById('gravar').value = 'Salvar';" +
				      "alert('"+cadTab.getErros()+"');" +
				      "window.close();"+
                                      "</script>";
			}else{// <-- Se nao teve erro redirecione para a consulta
				scr = "<script>" +
				      "window.opener.document.location.replace('./consulta_tabelacliente.jsp?acao=iniciar');"+
				      "window.close();"+
				      "</script>";
			}
			response.getWriter().append(scr);
			response.getWriter().close();
		}
	if (acao.equals("excluir") && request.getParameter("id") != null){
		cadTab = new BeanCadTabelaCliente();
		cadTab.setConexao(Apoio.getUsuario(request).getConexao());
		cadTab.setExecutor(Apoio.getUsuario(request));
		cadTab.getTabela().setId(Integer.parseInt(request.getParameter("id")));
		String scr = "";
		if (!cadTab.Deleta()){ //Se deu erro
			scr = "<script>" +
			      "alert('"+cadTab.getErros()+"');";
			scr += "window.close();"+
  		           "</script>";
		}else{
			scr = "<script>" +
		          "window.opener.document.getElementById('visualizar').click();"+
		          "window.close();"+
		          "</script>";
		}
		response.getWriter().append(scr);
		response.getWriter().close();
	}
  }
  
  boolean carregaTab = (tab != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="JavaScript" type="text/javascript">
//Não sei bem o porque mas tenho que abrir uma tag do javascript com o src e fechá-la,
//para usar as funções do arquivo .js tenho que abrir uma nova tag <script>

var indexTabela = 0;
//@@@@@@@@@ carregando as tabelas defaults  -   INICIO
var iTabTFM = 0;
var iTabAe = 0;
var arryTabTFM = new Array();
var arryTabAe = new Array();
var objTFM = null;
var objAe = null;
<%while(rsFaixa.next()){%>
    //povoando o objeto
    objTFM = new TabelaPeso();
    objTFM.id = <%=rsFaixa.getInt("id")%>;
    objTFM.pesoInicial = <%=rsFaixa.getInt("peso_inicial")%>;
    objTFM.pesoFinal = <%=rsFaixa.getInt("peso_final")%>;
    arryTabTFM[iTabTFM++] = objTFM;
    //inserindo uma linha
    
<%}%>

<%for (int u = 0; u < allA.getTabela().getFaixasPesoAereo().length; ++u) {
    fxp = allA.getTabela().getFaixasPesoAereo()[u];%>
    objAe = new TabelaPeso();
    objAe.id = <%=fxp.getId()%>;
    objAe.pesoInicial = <%=fxp.getPesoInicial()%>;
    objAe.pesoFinal = <%=fxp.getPesoFinal()%>;
    arryTabAe[iTabAe++] = objAe;
<%}%>

//@@@@@@@@@ carregando as tabelas defaults  -   FIM

function habilitaSalvar(opcao){
	$("gravar").disabled = !opcao;
	$("gravar").value = (opcao ? "Baixar" : "Enviando...");
}

//Quando o usuário clica em voltar
function voltar(){
	location.replace("./consulta_tabelacliente.jsp?acao=iniciar");
}

function validaOrigem(){
   for (x=0; x < indexTabela; x++){
      if($('idOrigem'+x) != null && $('idOrigem'+x).value == '0'){
         return false;
      }
   }
   return true;
}

function validaDestino(){
   for (x=0; x < indexTabela; x++){
      if($('idDestino'+x) != null && $('idDestino'+x).value == '0'){
         return false;
      }
   }
   return true;
}

function validaDataVigencia(){
   for (x=0; x < indexTabela; x++){
      if($('dataVigenciaLote_'+x) != null && $('dataVigenciaLote_'+x).value == ''){
         return false;
      }
   }
   return true;
}
//Salva as informações digitadas
function salva(acao){

    //Validando campos em branco
    var freteIdaVolta = false;
    
    if ($("chkFreteIdaVolta") != null && $("chkFreteIdaVolta").checked) {
        freteIdaVolta = true;
    }
    if (!validaOrigem()) {
      alert ("Informe a origem corretamente.");
    }else if (!validaDestino()){
      alert ("Informe o destino corretamente.");
    }else if (!validaDataVigencia()){
      alert ("Informe a data de vigência corretamente.");
    }else if (acao!="atualizar" &&($("remetenteId").value =="0" || $("remetenteId").value=="" || $("remetenteId").value==0)){
      alert ("Informe o 'Cliente'.");
    }else if(!validaDataVigencia()){
                        alert("Atenção! O campo data de vigência é de preenchimento obrigatório");
                }else{

	  //salvando
      $('formTabela').action = "./cadtabela_preco_dinamica.jsp?acao="+acao+"&qtdTabelas="+indexTabela+"&chkFreteIdaVolta="+freteIdaVolta+"&"+
								concatFieldValue("remetenteId");

      habilitaSalvar(false);
      window.open("", "pop2", "top=10,left=20,height=20,width=70");
      $('formTabela').submit();
    }
}

function visualizar(){
    var tipo = $("tipoPesq").value;
    if(tipo=="grupo" && $("grupo_id").value==0){
        alert("Escolha um grupo.");
        return false;
    }
	location.replace("./cadtabela_preco_dinamica.jsp?acao=visualizar&" + 
            concatFieldValue("remetenteId,remetente_rzs,remetente_cnpj,idcidadeorigem_loc,idcidadedestino_loc,cid_origem_loc,uf_origem_loc"
            +",cid_destino_loc,uf_destino_loc,idareaorigem_loc,area_ori_loc,idareadestino_loc,area_des_loc,tipo_produto_id_loc,tipo_produto_loc,utilizaTipoFreteTabelaRem, tipotaxaRem")+
       "&grupo="+$("grupo").value+"&grupo_id="+$("grupo_id").value+"&tipoPesq="+ tipo);
}

function sltTipoPeso(idx){
    if($("tipoPeso_"+idx).value=="f"){
        $("valorPeso_"+idx).className = "inputReadOnly8pt";
        $("valorPeso_"+idx).readOnly = true;
        $("trFaixaPeso_"+idx).style.display="";
    }else{
        $("valorPeso_"+idx).className = "fieldMin2";
        $("valorPeso_"+idx).readOnly = false;
        $("trFaixaPeso_"+idx).style.display="none";
    }


}
//@@@@@@@@@@@@@  tipo peso
function TabelaPeso(id,pesoInicial, pesoFinal, valor,tipoValor){
    this.id = (id==null||id==undefined?"0":id);
    this.pesoInicial = (pesoInicial == null || pesoInicial == undefined?"0" : pesoInicial);
    this.pesoFinal = (pesoFinal == null || pesoFinal == undefined?"0" : pesoFinal);
    this.valor = (valor == null || valor == undefined?"0.00" : valor);
    this.tipoValor = (tipoValor == null || tipoValor == undefined?"f" : tipoValor);
}

function tabelaTipoViculo(id,valorCombinado, valorPedagio, limitePedagio,tipoTaxa){
    this.id = (id==null||id==undefined?"0":id);
    this.valorCombinado = (valorCombinado == null || valorCombinado == undefined?"0" : valorCombinado);
    this.valorPedagio = (valorPedagio == null || valorPedagio == undefined?"0" : valorPedagio);
    this.limitePedagio= (limitePedagio == null || limitePedagio == undefined?"0.00" : limitePedagio);
    this.tipoTaxa = (tipoTaxa == null || tipoTaxa == undefined?"f" : tipoTaxa);
}

function Tabela(id,pesoInicial, pesoFinal, valor,tipoValor){
    this.id = (id==null||id==undefined?"0":id);
    this.pesoInicial = (pesoInicial == null || pesoInicial == undefined?"0" : pesoInicial);
    this.pesoFinal = (pesoFinal == null || pesoFinal == undefined?"0" : pesoFinal);
    this.valor = (valor == null || valor == undefined?"0.00" : valor);
    this.tipoValor = (tipoValor == null || tipoValor == undefined?"f" : tipoValor);
}

function addListaTipoTFM(lista, linha, incluindo){

    var indexAnterior = indexTabela-1;
    var idx = (incluindo?indexTabela:indexAnterior);
    var classe = ((idx % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');

    if(lista==null || lista==undefined){
        lista = new Tabela();
    }
    var _tr_tTFM = Builder.node("TR",{
        className:classe
    });//tr do tipo terrestre, fluvial e maritimo
    
    //td do peso inicial
    var td_1_1 = Builder.node("td",{
        className:classe
    });
    
    var inp_1_1 = Builder.node("input",{
        type:"text", className:"fieldMin2", size:"6",
        value: lista.pesoInicial,
        maxlength:"10", 
        name:"pesoInicio_"+idx+"_tfm_"+linha, 
        id:"pesoInicio_"+idx+"_tfm_"+linha,
        onchange:'seNaoFloatReset($(\'pesoInicio_'+idx+'_tfm_'+linha+'\'), 0.00);'
    });
        td_1_1.appendChild(inp_1_1);
        
    //td do peso final
    var td_1_2 = Builder.node("td",{
        className:classe
    });
    
    var inp_1_2 = Builder.node("input",{
        type:"text",className:"fieldMin2", size:"6", 
        value:lista.pesoFinal,
        maxlength:"10", 
        name:"pesoFinal_"+idx+"_tfm_"+linha, 
        id:"pesoFinal_"+idx+"_tfm_"+linha,
        onchange:'seNaoFloatReset($(\'pesoFinal_'+idx+'_tfm_'+linha+'\'), 0.00);'
    });
        td_1_2.appendChild(inp_1_2);
        
    //td do peso final
    var td_1_3 = Builder.node("td",{
        className:classe
    });
    
    var inp_1_3 = Builder.node("input",{
        type:"text",className:"fieldMin2", 
        value: formatoMoeda(lista.valor),
        name:"valorPeso_"+idx+"_tfm_"+linha, 
        size:"6", 
        maxlength:"10", 
        id:"valorPeso_"+idx+"_tfm_"+linha,
        onchange:'seNaoFloatReset($(\'valorPeso_'+idx+'_tfm_'+linha+'\'), 0.00);'
    });
    
    var inp_1_h = Builder.node("input",{
        type:"hidden", 
        value: lista.id,
        name:"idFaixa_"+idx+"_tfm_"+linha,
        id:"idFaixa_"+idx+"_tfm_"+linha  
    });
    
    var inp_1_h2 = Builder.node("input",{
        type:"hidden", 
        value: lista.valor,
        id:"hi_valorPeso_"+idx+"_tfm_"+linha, 
        name:"hi_valorPeso_"+idx+"_tfm_"+linha
    });
    var inp_1_formulaPeso = Builder.node("input",{
        type:"hidden", 
        value: lista.valor,
        id:"hi_valorPeso_"+idx+"_tfm_"+linha, 
        name:"hi_valorPeso_"+idx+"_tfm_"+linha
    });
    
    td_1_3.appendChild(inp_1_h2);
    td_1_3.appendChild(inp_1_h);
    td_1_3.appendChild(inp_1_3);
    
    //td do tipo do valor
    var td_1_4 = Builder.node("td",{
        className:classe
    });
    var slc_1 = Builder.node("select", {
        name:"slc_"+idx+"_tfm_"+linha,
        className:"fieldMin2", 
        id:"slc_"+idx+"_tfm_"+linha
    },
    [
        Builder.node('OPTION', {value:'f'}, 'FIXO'),
        Builder.node('OPTION', {value:'k'}, 'KG'),
        Builder.node('OPTION', {value:'t'}, 'TON')
    ]);
    
    slc_1.value = lista.tipoValor;
    td_1_4.appendChild(slc_1);

    _tr_tTFM.appendChild(td_1_1);
    _tr_tTFM.appendChild(td_1_2);
    _tr_tTFM.appendChild(td_1_3);
    _tr_tTFM.appendChild(td_1_4);

    $('maxFaixaTFM_'+idx).value = linha;
    $('tbTpFRM_'+idx).appendChild(_tr_tTFM);

}

//<!--********* DOM para adcionar mais campos nas tabelas de preço. **********-->

function addTipoTFM(lista, idx, linha ){

    var indexAnterior = indexTabela-1;
    //var idx = (incluindo?indexTabela:indexAnterior);
    var classe = ((idx % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
    
    var sair = false;
    var index = linha;
    do {
        if ($("pesoInicio_"+idx+"_tfm_" + index) == null || $("pesoInicio_"+idx+"_tfm_" + index) == undefined) {
            sair = true;
            linha = index;
        }else{
            index++;
        }
    }while(!sair);
    
    if(lista==null || lista==undefined){
        lista = new Tabela();
    }
    var _tr_tTFM = Builder.node("TR",{
        className:classe
    });//tr do tipo terrestre, fluvial e maritimo
    
    //td do peso inicial
    var td_1_1 = Builder.node("td",{
        className:classe
    });
    
    var inp_1_1 = Builder.node("input",{
        type:"text", className:"fieldMin2", size:"6",
        value: lista.pesoInicial,
        maxlength:"10", 
        name:"pesoInicio_"+idx+"_tfm_"+linha, 
        id:"pesoInicio_"+idx+"_tfm_"+linha,
        onchange:'seNaoFloatReset($(\'pesoInicio_'+idx+'_tfm_'+linha+'\'), 0.00);'
    });
        td_1_1.appendChild(inp_1_1);
        
    //td do peso final
    var td_1_2 = Builder.node("td",{
        className:classe
    });
    
    var inp_1_2 = Builder.node("input",{
        type:"text",className:"fieldMin2", size:"6", 
        value:lista.pesoFinal,
        maxlength:"10", 
        name:"pesoFinal_"+idx+"_tfm_"+linha, 
        id:"pesoFinal_"+idx+"_tfm_"+linha,
        onchange:'seNaoFloatReset($(\'pesoFinal_'+idx+'_tfm_'+linha+'\'), 0.00);'
    });
        td_1_2.appendChild(inp_1_2);
        
    //td do peso final
    var td_1_3 = Builder.node("td",{
        className:classe
    });
    
    var inp_1_3 = Builder.node("input",{
        type:"text",className:"fieldMin2", 
        value: formatoMoeda(lista.valor),
        name:"valorPeso_"+idx+"_tfm_"+linha, 
        size:"6", 
        maxlength:"10", 
        id:"valorPeso_"+idx+"_tfm_"+linha,
        onchange:'seNaoFloatReset($(\'valorPeso_'+idx+'_tfm_'+linha+'\'), 0.00);'
    });
    
    var inp_1_h = Builder.node("input",{
        type:"hidden", 
        value: lista.id,
        name:"idFaixa_"+idx+"_tfm_"+linha,
        id:"idFaixa_"+idx+"_tfm_"+linha
    });
    
    var inp_1_h2 = Builder.node("input",{
        type:"hidden", 
        value: lista.valor,
        id:"hi_valorPeso_"+idx+"_tfm_"+linha, 
        name:"hi_valorPeso_"+idx+"_tfm_"+linha
    });
    var inp_1_formulaPeso = Builder.node("input",{
        type:"hidden", 
        value: lista.valor,
        id:"hi_valorPeso_"+idx+"_tfm_"+linha, 
        name:"hi_valorPeso_"+idx+"_tfm_"+linha
    });
    
    td_1_3.appendChild(inp_1_h2);
    td_1_3.appendChild(inp_1_h);
    td_1_3.appendChild(inp_1_3);
    
    //td do tipo do valor
    var td_1_4 = Builder.node("td",{
        className:classe
    });
    var slc_1 = Builder.node("select", {
        name:"slc_"+idx+"_tfm_"+linha,
        className:"fieldMin2", 
        id:"slc_"+idx+"_tfm_"+linha
    },
    [
        Builder.node('OPTION', {value:'f'}, 'FIXO'),
        Builder.node('OPTION', {value:'k'}, 'KG'),
        Builder.node('OPTION', {value:'t'}, 'TON')
    ]);
    
    slc_1.value = lista.tipoValor;
    td_1_4.appendChild(slc_1);

    _tr_tTFM.appendChild(td_1_1);
    _tr_tTFM.appendChild(td_1_2);
    _tr_tTFM.appendChild(td_1_3);
    _tr_tTFM.appendChild(td_1_4);

    $('maxFaixaTFM_'+idx).value = linha;
    $('tbTpFRM_'+idx).appendChild(_tr_tTFM);

}

function addTipoVeiculo(lista,linha, incluindo){
    try {
        if(lista==null || lista==undefined){
            lista = new tabelaTipoViculo();
        }

        var indexAnterior = indexTabela-1;
        var idx = (incluindo?indexTabela:indexAnterior);

        var tr_TipoVeiculo = Builder.node("TR",{
        });

        var td_1_1 = Builder.node("td",{
        });

        var td_1_2 = Builder.node("td",{
        }); 

        var td_1_3 = Builder.node("td",{
        });

        var td_1_4 = Builder.node("td",{
        });

        var td_1_5 = Builder.node("td",{
        });

        var inp_1 = Builder.node("input",{
            type:"hidden", 
            value: lista.id,
            maxlength:"10",
            name:"idtveiculo_"+idx+"_"+linha,
            id:"idtveiculo_"+idx+"_"+linha,
        });
        td_1_1.appendChild(inp_1);


        var inp_2 = Builder.node("input",{
           type:"hidden",
           size:"6", 
           value: lista.valorPedagio,
           maxlength:"10", 
           name:"valorPedagio_"+idx+"_"+linha, 
           id:"valorPedagio_"+idx+"_"+linha,
        });
        td_1_1.appendChild(inp_2);

        var inp_3 = Builder.node("input",{
           type:"hidden",
           value: lista.limitePedagio,
           name:"limitePedagio_"+idx+"_"+linha, 
           id:"limitePedagio_"+idx+"_"+linha,
           size:"6", 
           maxlength:"10", 
        });
        td_1_1.appendChild(inp_3);

        var inp_4 = Builder.node("input",{
           type:"hidden",
           value: lista.valorCombinado,
           name:"valorCombinado_"+idx+"_"+linha, 
           id:"valorCombinado_"+idx+"_"+linha,
           size:"6", 
           maxlength:"10", 
        });
        td_1_1.appendChild(inp_4);

        var td_5 = Builder.node("input",{
           type:"hidden", 
           value: lista.tipoTaxa,
           name:"tipoTaxa_"+idx+"_"+linha,
           id:"tipoTaxa_"+idx+"_"+linha
        });
        td_1_1.appendChild(td_5);

        tr_TipoVeiculo.appendChild(td_1_1);
//        tr_TipoVeiculo.appendChild(td_1_2);
//        tr_TipoVeiculo.appendChild(td_1_3);
//        tr_TipoVeiculo.appendChild(td_1_4);
//        tr_TipoVeiculo.appendChild(td_1_5);


        $('maxTVeiculo').value = linha;
        $('tbodyTipoVeiculo').appendChild(tr_TipoVeiculo);
    } catch (e) {
        alert(e);
    }
}

function addListaTipoAereo(lista, linha, incluindo){
    var indexAnterior = indexTabela-1;
    var idx = (incluindo?indexTabela:indexAnterior);
    var classe = ((idx % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');

    if(lista==null || lista==undefined){
        lista = new Tabela();
    }
    
    var _tr_tA = Builder.node("TR",{
        className:classe
    });//tr do tipo aereo
    
    var tdImgAereo = Builder.node("td",{
        id : "tdImg_"+linha
    });
    
    //td do peso inicial
    var td_2_1 = Builder.node("td",{
        className:classe
    });
    var inp_2_1 = Builder.node("input",{
        type:"text", 
        className:"fieldMin2", 
        value: lista.pesoInicial,
        size:"6", 
        maxlength:"10", 
        name:"pesoInicio_"+idx+"_a_"+linha, 
        id:"pesoInicio_"+idx+"_a_"+linha,
        onchange:'seNaoFloatReset($(\'pesoInicio_'+idx+'_a_'+linha+'\'), 0.00);'
    });
    
    td_2_1.appendChild(inp_2_1);
    //td do peso final
    var td_2_2 = Builder.node("td",{
        className:classe
    });
    var inp_2_2 = Builder.node("input",{
        type:"text",
        className:"fieldMin2", 
        value: lista.pesoFinal,
        size:"6", 
        maxlength:"10", 
        name:"pesoFinal_"+idx+"_a_"+linha, 
        id:"pesoFinal_"+idx+"_a_"+linha,
        onchange:'seNaoFloatReset($(\'pesoFinal_'+idx+'_a_'+linha+'\'), 0.00);'
    });
    td_2_2.appendChild(inp_2_2);

    //td do peso final
    var td_2_3 = Builder.node("td",{
        className:classe
    });
    
    var inp_2_3 = Builder.node("input",{
        type:"text",
        className:"fieldMin2", 
        name:"valorPeso_"+idx+"_a_"+linha,
        size:"6", 
        maxlength:"10", 
        id:"valorPeso_"+idx+"_a_"+linha, 
        value: formatoMoeda(lista.valor),
        onchange:'seNaoFloatReset($(\'valorPeso_'+idx+'_a_'+linha+'\'), 0.00);'
    });
    
    var inp_2_h = Builder.node("input",{
        type:"hidden", 
        value: lista.id,
        name:"idFaixa_"+idx+"_a_"+linha, 
        id:"idFaixa_"+idx+"_a_"+linha
    });
    
    var inp_2_h2 = Builder.node("input",{
        type:"hidden", 
        value: lista.valor,
        id:"hi_valorPeso_"+idx+"_a_"+linha, 
        name:"hi_valorPeso_"+idx+"_a_"+linha
    });
    
    td_2_3.appendChild(inp_2_h2);
    td_2_3.appendChild(inp_2_h);
    td_2_3.appendChild(inp_2_3);
    
    //td do tipo do valor
    var td_2_4 = Builder.node("td",{
        className:classe
    });
    
    var slc_2 = Builder.node("select", {
        name:"slc_"+idx+"_a_"+linha,
        className:"fieldMin2", id:"slc_"+idx+"_a_"+linha},
        [
            Builder.node('OPTION', {value:'f'}, 'FIXO'),
            Builder.node('OPTION', {value:'k'}, 'KG')
        ]);
        
    slc_2.value = lista.tipoValor;
    td_2_4.appendChild(slc_2);

    _tr_tA.appendChild(tdImgAereo);
    _tr_tA.appendChild(td_2_1);
    _tr_tA.appendChild(td_2_2);
    _tr_tA.appendChild(td_2_3);
    _tr_tA.appendChild(td_2_4);

    $('maxFaixaAerea_'+idx).value = linha;
    $('tbTpAereo_'+idx).appendChild(_tr_tA);

}

function addTipoAereo(lista, idx, linha){
    var indexAnterior = indexTabela-1;
//    var idx = (incluindo?indexTabela:indexAnterior);
    var classe = ((idx % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
    
    var sair = false;
    var index = linha;
    do {
        if ($("pesoInicio_"+idx+"_a_" + index) == null || $("pesoInicio_"+idx+"_a_" + index) == undefined) {
            sair = true;
            linha = index;
        }else{
            index++;
        }
    }while(!sair);
    
    if(lista==null || lista==undefined){
        lista = new Tabela();
    }
    
    var _tr_tA = Builder.node("TR",{
        className:classe
    });//tr do tipo aereo
    
    var tdImgAereo = Builder.node("td",{
        id : "tdImg_"+linha
    });
    
    //td do peso inicial
    var td_2_1 = Builder.node("td",{
        className:classe
    });
        
    var inp_2_1 = Builder.node("input",{
        type:"text", 
        className:"fieldMin2", 
        value: lista.pesoInicial,
        size:"6", 
        maxlength:"10", 
        name:"pesoInicio_"+idx+"_a_"+linha, 
        id:"pesoInicio_"+idx+"_a_"+linha,
        onchange:'seNaoFloatReset($(\'pesoInicio_'+idx+'_a_'+linha+'\'), 0.00);'
    });
    
    td_2_1.appendChild(inp_2_1);
    //td do peso final
    var td_2_2 = Builder.node("td",{
        className:classe
    });
    var inp_2_2 = Builder.node("input",{
        type:"text",
        className:"fieldMin2", 
        value: lista.pesoFinal,
        size:"6", 
        maxlength:"10", 
        name:"pesoFinal_"+idx+"_a_"+linha, 
        id:"pesoFinal_"+idx+"_a_"+linha,
        onchange:'seNaoFloatReset($(\'pesoFinal_'+idx+'_a_'+linha+'\'), 0.00);'
    });
    td_2_2.appendChild(inp_2_2);

    //td do peso final
    var td_2_3 = Builder.node("td",{
        className:classe
    });
    
    var inp_2_3 = Builder.node("input",{
        type:"text",
        className:"fieldMin2", 
        name:"valorPeso_"+idx+"_a_"+linha,
        size:"6", 
        maxlength:"10", 
        id:"valorPeso_"+idx+"_a_"+linha, 
        value: formatoMoeda(lista.valor),
        onchange:'seNaoFloatReset($(\'valorPeso_'+idx+'_a_'+linha+'\'), 0.00);'
    });
    
    var inp_2_h = Builder.node("input",{
        type:"hidden", 
        value: lista.id,
        name:"idFaixa_"+idx+"_a_"+linha, 
        id:"idFaixa_"+idx+"_a_"+linha
    });
    
    var inp_2_h2 = Builder.node("input",{
        type:"hidden", 
        value: lista.valor,
        id:"hi_valorPeso_"+idx+"_a_"+linha, 
        name:"hi_valorPeso_"+idx+"_a_"+linha
    });
    
    
    //td do tipo do valor
    var td_2_4 = Builder.node("td",{
        className:classe
    });
    
    var slc_2 = Builder.node("select", {
        name:"slc_"+idx+"_a_"+linha,
        className:"fieldMin2", id:"slc_"+idx+"_a_"+linha},
        [
            Builder.node('OPTION', {value:'f'}, 'FIXO'),
            Builder.node('OPTION', {value:'k'}, 'KG')
        ]);

        
    td_2_3.appendChild(inp_2_h2);
    td_2_3.appendChild(inp_2_h);
    td_2_3.appendChild(inp_2_3); 
        
    slc_2.value = lista.tipoValor;
    td_2_4.appendChild(slc_2);

    _tr_tA.appendChild(tdImgAereo);
    _tr_tA.appendChild(td_2_1);
    _tr_tA.appendChild(td_2_2);
    _tr_tA.appendChild(td_2_3);
    _tr_tA.appendChild(td_2_4);
    
    $('maxFaixaAerea_'+idx).value = linha;
    $('tbTpAereo_'+idx).appendChild(_tr_tA);

}


function aoClicarNoLocaliza(idjanela){          

	var indice = 0;
        
	if (idjanela == "Cidade_Origem"){
                $('idcidadeorigem_loc').value = $('idcidadeorigem').value;
                $('cid_origem_loc').value = $('cid_origem').value;
                $('uf_origem_loc').value = $('uf_origem').value;
        }else if (idjanela == "Cidade_Destino"){
                $('idcidadedestino_loc').value = $('idcidadedestino').value;
                $('cid_destino_loc').value = $('cid_destino').value;
                $('uf_destino_loc').value = $('uf_destino').value;
        }else if (idjanela == "Area_Origem"){
                $('idareaorigem_loc').value = $('area_id').value;
                $('area_ori_loc').value = $('sigla_area').value;
        } else if (idjanela == "Area_Destino"){
                $('idareadestino_loc').value = $('area_id').value;
                $('area_des_loc').value = $('sigla_area').value;
        } else if (idjanela == "Tipo_Produto"){
                $('tipo_produto_id_loc').value = $('tipo_produto_id').value;
                $('tipo_produto_loc').value = $('tipo_produto').value;
        }else if (idjanela.substring(0,13) == "Cidade_Origem"){
		indice = idjanela.split("_")[2];
		$('idOrigem'+indice).value = $('idcidadeorigem').value;
		$('origem'+indice).innerHTML = $('cid_origem').value + ' - ' + $('uf_origem').value + ' ';
	}else if (idjanela.substring(0,14) == "Cidade_Destino"){
		indice = idjanela.split("_")[2];
		$('idDestino'+indice).value = $('idcidadedestino').value;
		$('destino'+indice).innerHTML = $('cid_destino').value + ' - ' + $('uf_destino').value + ' ';
	}else if (idjanela.substring(0,12) == "Tipo_Produto"){
		indice = idjanela.split("_")[2];
		$('idProduto'+indice).value = $('tipo_produto_id').value;
		$('produto'+indice).innerHTML = $('tipo_produto').value + ' ';
	}else if (idjanela.substring(0,11) == "Area_Origem"){
		indice = idjanela.split("_")[2];
		$('idOrigem'+indice).value = $('area_id').value;
		$('origem'+indice).innerHTML = $('sigla_area').value + ' ';
	}else if (idjanela.substring(0,12) == "Area_Destino"){
		indice = idjanela.split("_")[2];
		$('idDestino'+indice).value = $('area_id').value;
		$('destino'+indice).innerHTML = $('sigla_area').value + ' ';
	
	}else if (idjanela == "Cliente"){
		$('cli_cop_id').value= $('idremetente').value;
		$('cli_cop_rzs').value= $('rem_rzs').value;
                $('utilizaTipoFreteTabelaCliCop').value = $('is_utilizar_tipo_frete_tabela').value;
	}else if (idjanela == "Remetente"){
		$('remetenteId').value= $('idremetente').value;
		$('remetente_rzs').value= $('rem_rzs').value;
		$('remetente_cnpj').value= $('rem_cnpj').value;
		$('utilizaTipoFreteTabelaRem').value = $('is_utilizar_tipo_frete_tabela').value;
		$('tipotaxaRem').value = $('rem_tipotaxa').value;
	}else if (idjanela == "Area_de_Origem"){
                $('idareaorig').value = $('area_id').value;
                $('origem').value = $('sigla_area').value;
        } else if (idjanela == "Area_de_Destino"){
                $('idareadest').value = $('area_id').value;
                $('destino').value = $('sigla_area').value;
                }
}

function aplicarReajuste(){
    var campo = $("campoReajuste").value;
    var campoReajuste = "";
    var tipo = $("tipoReajuste").value;
    var valor = $("valorReajuste").value;
    var valorAdicional= 0;
    var maxLinha = 0;
    tipo.disabled = false;
    
    
    if (campo.split("_")[0] == "valorSeguro" && tipo == "real") {
        var atualiza = limitarCampo($("valorReajuste"),"valor do reajuste para AdValorEm");
        if (atualiza == false) {
            return false;
        }
    };
    
    if (campo.split("_")[0] == "valorGris" && tipo == "real") {
        var atualiza = limitarCampo($("valorReajuste"),"valor do reajuste para GRIS");
        if (atualiza == false) {
            return false;
        }
    };
    for(var i = 0; i< indexTabela; i++){
        if(campo.split("_")[0]=="validaAte"){
           valor = $("validaAte").value;
           $(campo+"_"+i).value = valor;
        }else if(campo=="tipoTaxaCliente"){
            $("tipoTaxa_"+i).value = $("tipoTxCliente").value; 
        }else if(campo.split("_")[0]!="valorPesoFaixa"){
            valorAdicional = (tipo=="real"?parseFloat(valor) : (1+(parseFloat(valor)/100)) * parseFloat($("hi_"+campo+"_"+i).value));
            $(campo+"_"+i).value = formatoMoeda(valorAdicional);
        }else{
            //caso seja por faixa de peso, ele tera que reajudatar cada valor da
            //faixa de peso, de todas tabelas de preço
            //vendo qual tabela terá o valor reajustado
            switch (campo.split("_")[1]){
                case "Terrestre":
                    campoReajuste = "valorPeso_"+i+"_tfm_";
                    maxLinha = $("maxFaixaTFM_"+i).value;
                    for(var j = 0; j<= maxLinha; j++){
                        //sempre será reajustado por percentual
                        if ($(campoReajuste+j) != null) {
                            valorAdicional = (1+(parseFloat(valor)/100)) * parseFloat($("hi_"+campoReajuste+j).value);
                            $(campoReajuste+j).value = formatoMoeda(valorAdicional);
                        }
                    }
                    break;

                case "Aereo":
                    campoReajuste = "valorPeso_"+i+"_a_";
                    maxLinha = $("maxFaixaAerea_"+i).value;
                    for(var j = 0; j<= maxLinha; j++){
                        //sempre será reajustado por percentual
                        if ($(campoReajuste+j) != null) {
                            valorAdicional = (1+(parseFloat(valor)/100)) * parseFloat($("hi_"+campoReajuste+j).value);
                            $(campoReajuste+j).value = formatoMoeda(valorAdicional);
                        }
                    }
                    break;
            }
        }
    }

    isTipoReajuste();
}

function isTipoReajuste(){
    var campo = $("campoReajuste").value;
    var tipo = $("tipoReajuste");
    var valor = $("valorReajuste");
    var data = $("validaAte");
        if(campo.split("_")[0]=="valorPesoFaixa"){
            tipo.value="percentual";
            tipo.disabled = true;
            valor.style.display = "";
            data.style.display = "none";
        }else if(campo.split("_")[0]=="validaAte"){
            tipo.disabled = true;
            valor.style.display = "none";
            data.style.display = "";
            data.value = "<%= Apoio.getDataAtual() %>";
        }else{
            tipo.disabled = false;
            valor.style.display = "";
            data.style.display = "none";
        }
    if(campo == "tipoTaxaCliente"){
        $("valorReajuste").style.display = "none";
        $("tipoReajuste").style.display = "none";
        $("tipoTxCliente").style.display = "";
    }else{
        $("valorReajuste").style.display = "";
        $("tipoReajuste").style.display = "";
        $("tipoTxCliente").style.display = "none";
    }
              
}

function desconsideraTodos(index){
    var checado = $("desconsiderarTodos_"+index).checked;
    $("desconsideraGris_"+index).checked = checado;
    $("desconsideraSeguro_"+index).checked = checado;
    $("desconsideraDespacho_"+index).checked = checado;
    $("desconsideraOutros_"+index).checked = checado;
    $("desconsideraPedagio_"+index).checked = checado;
    $("desconsideraTaxaFixa_"+index).checked = checado;
    $("desconsideraSecCat_"+index).checked = checado;

}

function tipoConsulta(){
    var tipo = ($("tipoPesq")!=null && $("tipoPesq") != undefined ? $("tipoPesq").value:"");
    //tipo = (tipo== null || tipo == undefined?"cliente":tipo);
    switch (tipo){
        case "cliente":
            $("tdCliente_1").style.display="";
            $("tdCliente_2").style.display="";
            $("tdCliente_3").style.display="";
            $("tdCliente_4").style.display="";
            $("tdGrupo_1").style.display="none";
            $("tdGrupo_2").style.display="none";
            break;
        case "grupo":
            $("tdCliente_1").style.display="none";
            $("tdCliente_2").style.display="none";
            $("tdCliente_3").style.display="none";
            $("tdCliente_4").style.display="none";
            $("tdGrupo_1").style.display="";
            $("tdGrupo_2").style.display="";
            $("tdGrupo_2").colSpan="3";
            break;
    }
}

function exibirFormula(objx){
                var promp = document.createElement("DIV");
                promp.id = "promptFormula";
                document.body.appendChild(promp);
                var obj = document.getElementById("promptFormula").style;
                obj.zIndex = "3";
                obj.position = "absolute";
                obj.backgroundColor = "#FFFFFF";
                obj.left = "24%";
                obj.top = "20%";
                obj.width = "52%";
//                obj.height = "52%";
                var cmdHtml = "";
                //Criando a tabela
    cmdHtml = "<table width='100%' class='bordaFina'>"+
                        "<tr class='tabela'>" +
                        "<td align='center'>" +
                        "Editar fórmula" +
                        "</td>" +
                        "</tr>" +
                        "<tr class='Celula'>" +
                        "<td align='center'>" +
                        "Variáveis" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td align='center'>" +
                        "<table width='100%' class='bordaFina'>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Peso:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@peso\")'>@@peso</label></td>" +
                        "<td width='25%' class='TextoCampos'>Valor Mercadoria:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@mercadoria\")'>@@mercadoria</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Volumes:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@volume\")'>@@volume</label></td>" +
                        "<td width='25%' class='TextoCampos'>Tipo Frete:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@tipoFrete\")'>@@tipoFrete</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Quantidade KM:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@km\")'>@@km</label></td>" +
                        "<td width='25%' class='TextoCampos'>Paletts:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@pallets\")'>@@pallets</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Tipo de veículo:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@tipoVeiculo\")'>@@tipoVeiculo</label></td>" +
                        "<td width='25%' class='TextoCampos'>Qtd de Entregas</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@entregas\")'>@@entregas</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Peso Cubado:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@cubado\")'>@@cubado</label></td>" +
                        "<td width='25%' class='TextoCampos'>CIF = 0, FOB = 1 ou CON = 2: </td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@pagador_frete\")'>@@pagador_frete</label></td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td width='25%' class='TextoCampos'>Valor Frete Redespacho:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@frete_redespacho\")'>@@frete_redespacho</label></td>" +
                        "<td width='25%' class='TextoCampos'>ICMS Frete Redespacho:</td>" +
                        "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@icms_redespacho\")'>@@icms_redespacho</label></td>";

                
                if (objx.name == 'formula_tde') {
                    cmdHtml += "</tr>"
                            "<tr>" +
                            "<td width='25%' class='TextoCampos'>Frete Peso:</td>" +
                            "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@fretePeso\")'>@@fretePeso</label></td>" +
                            "<td width='25%' class='TextoCampos'>Frete Valor:</td>" +
                            "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@freteValor\")'>@@freteValor</label></td>" +
                            "</tr>"+
                            "<tr><td width='25%' class='TextoCampos'>Total Frete sem TDE:</td>" +
                            "<td width='25%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@totalFrete\")'>@@totalFrete</label></td>" +
                            "<td width='25%' class='CelulaZebra2'></td>" +
                            "<td width='25%' class='CelulaZebra2'></td>";
                }
                cmdHtml += "</tr>";
                cmdHtml += "</table>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td class='CelulaZebra2NoAlign' align='center'>" +
                    "<textarea cols='70' rows='13' name='ed_formula' type='text' id='ed_formula' style='font-size:8pt;'>"+objx.value+"</textarea>" +
                        "</td>" +
                        "</tr>" +
                        "<tr class='CelulaZebra2'>" +
                        "<td align='center'>" +
                        "<input name='btSalvaFormula' id='btSalvaFormula' type='button' class='botoes' value='Confirmar' alt='Salvar as alterações na fórmula'>" +
                    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+
                        "<input name='btFechaFormula' id='btFechaFormula' type='button' class='botoes' value='Cancelar' alt='Cancelar as alterações na fórmula'>" +
                        "</td>" +
                        "</tr>" +
                        "</table>";
                document.getElementById("promptFormula").innerHTML = cmdHtml;
                document.getElementById("promptFormula").style.display = "";
    document.getElementById("btSalvaFormula").onclick = function(){
    objx.value=$('ed_formula').value;
        document.getElementById("promptFormula").style.display = "none";
                    isFormulaReadOnly(objx.id);
                }
    document.getElementById("btFechaFormula").onclick = function(){
                    document.getElementById("promptFormula").style.display = "none";
                }
            }

function isFormulaReadOnly(campo){
    var valor = replaceAll($(campo).value," ", "\r\n");
    var idx = campo.split("_")[1];
    var formula = campo.split("_")[0];


    if(valor.trim().length > 0){
        switch (formula){
            case "formulaGris":
                readOnly($("valorGris_"+idx, "inputReadOnly8pt2"));
                readOnly($("valorMinimoGris_"+idx), "inputReadOnly8pt2");
                break;
            case "formulaOutros":
                readOnly($("valorOutros_"+idx), "inputReadOnly8pt2");
                break;
            case "formula_pallet":                
                break;
            case "formula_volumes":
                break;
            case "formula_percentual":
                break;
            case "formulaSeguro":
                readOnly($("valorSeguro_"+idx), "inputReadOnly8pt2");
                break;
            case "formulaTaxaFixa":
                readOnly($("valorTaxa_"+idx), "inputReadOnly8pt2");
                break;
            case "formulaDespacho":
                readOnly($("valorDespacho_"+idx), "inputReadOnly8pt2");
                break;
            case "formulaSecCat":
                readOnly($("valorSecCat_"+idx), "inputReadOnly8pt2");
                break;
            case "formulaFreteMinimo":
                readOnly($("freteMinimo_"+idx), "inputReadOnly8pt2");
                break;
            case "formula_icms":
                break;
            case "formula_frete_peso":
                break;
            case "formulaPedagio":
                readOnly($("valorPedagio_"+idx), "inputReadOnly8pt2");
                readOnly($("qtdQuiloPedagio_"+idx), "inputReadOnly8pt2");
                break;
            case "formulaTDE":
                readOnly($("valorTde_"+idx), "inputReadOnly8pt2");
                break;
        }
    }else{
        switch (formula){
            case "formulaGris":
                notReadOnly($("valorGris_"+idx, "fieldMin2"));
                notReadOnly($("valorMinimoGris_"+idx), "fieldMin2");
                break;
            case "formulaOutros":
                notReadOnly($("valorOutros_"+idx), "fieldMin2");
                break;
            case "formula_pallet":
                break;
            case "formula_volumes":
                break;
            case "formula_percentual":
                break;
            case "formulaSeguro":
                notReadOnly($("valorSeguro_"+idx), "fieldMin2");
                break;
            case "formulaTaxaFixa":
                notReadOnly($("valorTaxa_"+idx), "fieldMin2");
                break;
            case "formulaDespacho_":
                noReadOnly($("valorDespacho_"+idx), "fieldMin2");
                break;
            case "formulaSecCat":
                notReadOnly($("valorSecCat_"+idx), "fieldMin2");
                break;
            case "formulaFreteMinimo":
                notReadOnly($("freteMinimo_"+idx), "fieldMin2");
                break;
            case "formula_icms":
                break;
            case "formula_frete_peso":
                break;
            case "formulaPedagio":
                notReadOnly($("valorPedagio_"+idx), "fieldMin2");
                notReadOnly($("qtdQuiloPedagio_"+idx), "fieldMin2");
                break;
            case "formulaTDE":
                notReadOnly($("valorTde_"+idx), "fieldMin2");
                break;
        }
    }
}

function setVariavelFormula(variavel){
    $("ed_formula").value +=variavel;
}

function AjaxCarregaTabela(){
    var idCliente = $("cli_cop_id").value;
    
    var idcidadeorig = $("idcidadeorig").value;
    var idcidadedest = $("idcidadedest").value;
    var idareaorig = $("idareaorig").value;
    var idareadest = $("idareadest").value;
    var tp_prod_id = $("tp_prod_id").value;
    //var idCliente = $("cli_cop_id").value;
   // var idCliente = $("cli_cop_id").value;
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport){
        var textoresposta = transport.responseText;
        espereEnviar("",false);
        //se deu algum erro na requisicao...
        if (textoresposta == "-1"){
            alert('Houve algum problema ao requistar as ocorrências, favor informar manualmente.');
            return false;
        }else{
            var tabela = "";
            var listFaixaPeso = "";
            //variaveis que serao usadas para função o DOM
            var tabPeso = "";
            var tabPesoA = "";
            //essas serao usadas pra receber o 'objeto' vindo da lista
            var tabPeso_ = "";
            var tabPesoA_ = "";
            var tabTipoVei_ = "";
            

            var listFaixaPesoA = "";
            var listTipoVeiculo = "";
            var c = 0; // apontador da tabela
            var r = 0; // apontador da faixa de peso
            var s = 0; // apontador da faixa de peso aerea
            for (i = 1; i <= textoresposta.split('@@99@@').length - 1; i++){
                c = 0;
                tabela = textoresposta.split("@@99@@")[i];

                addTabela(tabela.split("!!99!!")[c++],
                true,
                true,
                false,
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],
                false,
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++],//add
                ($("utilizaTipoFreteTabelaRem").value == "t"),
                tabela.split("!!99!!")[c++],
                tabela.split("!!99!!")[c++]
            );
                
                listFaixaPeso = tabela.split("!!99!!")[c++];
                for(var q = 1; q<= listFaixaPeso.split("!!11!!").length - 1; q++){
                    tabPeso_ = listFaixaPeso.split("!!11!!")[q];
                    r = 0;
                    tabPeso = new TabelaPeso();
                    tabPeso.id = tabPeso_.split("!!88!!")[r++];
                    tabPeso.pesoInicial = tabPeso_.split("!!88!!")[r++];
                    tabPeso.pesoFinal = tabPeso_.split("!!88!!")[r++];
                    tabPeso.valor = tabPeso_.split("!!88!!")[r++];
                    tabPeso.tipoValor = tabPeso_.split("!!88!!")[r++];
                    //passo false pois a tabela da faixa de preço sera inserinda fora do DOM da tabela
                    addListaTipoTFM(tabPeso, q-1, false);
                }


                listFaixaPesoA = tabela.split("!!99!!")[c++];
                for(var q = 1; q<= listFaixaPesoA.split("!!22!!").length - 1; q++){
                    tabPesoA_ = listFaixaPesoA.split("!!22!!")[q];
                    r = 0;
                    tabPesoA = new TabelaPeso();
                    tabPesoA.id = tabPesoA_.split("!!77!!")[r++];
                    tabPesoA.pesoInicial = tabPesoA_.split("!!77!!")[r++];
                    tabPesoA.pesoFinal = tabPesoA_.split("!!77!!")[r++];
                    tabPesoA.valor = tabPesoA_.split("!!77!!")[r++];
                    tabPesoA.tipoValor = tabPesoA_.split("!!77!!")[r++];
                    //passo false pois a tabela da faixa de preço sera inserinda fora do DOM da tabela
                    addListaTipoAereo(tabPesoA, q-1, false);
                }
                
                listTipoVeiculo = tabela.split("!!99!!")[c++];
                for(var q = 1; q <= listTipoVeiculo.split("!!33!!").length - 1; q++){
                    tabTipoVei_ = listTipoVeiculo.split("!!33!!")[q];
                    r = 0;
                    tabTipoV = new tabelaTipoViculo();
                    tabTipoV.id = tabTipoVei_.split("!!55!!")[r++];
                    tabTipoV.valorPedagio = tabTipoVei_.split("!!55!!")[r++];
                    tabTipoV.limitePedagio = tabTipoVei_.split("!!55!!")[r++];
                    tabTipoV.valorCombinado = tabTipoVei_.split("!!55!!")[r++];
                    tabTipoV.tipoTaxa = tabTipoVei_.split("!!55!!")[r++];
                    addTipoVeiculo(tabTipoV,q-1, false);
                }

            }
        }
    }//funcao e()
    espereEnviar("",true);
    tryRequestToServer(function(){

        new Ajax.Request("./cadtabela_preco_dinamica.jsp?acao=carregarTabelaAjax&idCliente="+idCliente+"&tp_prod_id="+tp_prod_id+"&idcidadeorig="+idcidadeorig+"&idcidadedest="+idcidadedest+"&idareaorig="+idareaorig+"&idareadest="+idareadest,{method:'post', onSuccess: e, onError: e});});
}

function verCopTabCliente(){
    if($("isCopTabCliente").checked==true){
        $("trCopTabCliente").style.display = "";
    }else{
        $("trCopTabCliente").style.display = "none";
    }
}

function addTabela( 
                idTabela,//0
                incluindo,//1
                isAjax, //2
                isIncluiFaixa,//3 
                tipo, //4
                idOrigem,//5 
                origem, //6
                idDestino, //7
                destino, //8
                idProduto, //9
                produto,//10
                valorPeso, //11
                ton, //12
                baseCub, //13
                valorVolume, //14
                percentualNf, //15
                basePercentual, //16
                valorPercentual, //17
                valorCombinado, //18
                valorGris, //19
                valorSeguro, //20
                valorTaxa, //21
                valorOutros, //22
                valorDespacho, //23
                freteMinimo, //24
                incluiIcms, //25
                incluirPisConfins, //26 
                valorPedagio, //27
                qtdQuiloPedagio, //28
                valorMinimoGris, //29
                valorTde, //30
                tipoTde, //31
                prazoEntrega, //32 
                prazoEntregaAereo,//33
                tipoDiasEntrega, //34
                tipoDiasEntregaAereo,//35 
                validaAte, //36
                percentualReentrega, //37
                percentualDevolucao,  //38
                valorSecCat, //39
                desconsideraIcmsPisCofins, //40
                desconsiderarGris, //41
                desconsiderarPedagio, //42
                desconsiderarSeguro, //43
                desconsiderarDespacho, //44
                desconsiderarOutros, //45
                desconsiderarTaxa, //46
                desconsiderarSecCat, //47
                formulaGris, //48
                formulaSeguro, //49
                formulaDespacho, //50
                formulaOutros, //51
                formulaTaxaFixa, //52
                formulaSecCat, //53
                formulaFreteMinimo, //54
                tipoFretePeso, //55
                tipoImpressaoFreteMinimo, //56
                formulaTDE, //57
                formulaPedagio, //58
                formulaFretePeso, //59
                tipoInclusaoIcms, //60
                pesoLimiteSecCat, //61
                valorExcedenteSecCat, //62
                valorExcedente, //63
                valorExcedenteAereo,//64 
                pesoLimiteTaxaFixa, //65
                valorExcedenteTaxaFixa, //66
                entregaMontagem,//67
                valorPallets, //68
                tipoTaxa, //69
                isUtilizaTipoTaxa, //70
                isConsiderarMaiorValor, //71
                isConsiderarMaiorPeso, //72
                isFreteIdaVolta, //73
                calculaSecCat, //74
                dataVigenciaLote//75
               ){
           
/////// teste
//validando os parametros de entrada
incluirPisConfins = (incluirPisConfins== null || incluirPisConfins== undefined?"N":incluirPisConfins);
valorPedagio = (valorPedagio== null || valorPedagio== undefined?"0.00": valorPedagio);
qtdQuiloPedagio = (qtdQuiloPedagio== null || qtdQuiloPedagio== undefined?"0": qtdQuiloPedagio);
valorMinimoGris= (valorMinimoGris== null || valorMinimoGris== undefined?"0.00": valorMinimoGris);
valorTde= (valorTde== null || valorTde== undefined?"0.00": valorTde);
tipoTde= (tipoTde== null || tipoTde== undefined?"v": tipoTde);
calculaSecCat = (calculaSecCat == null || calculaSecCat == undefined? "c": calculaSecCat);
prazoEntrega= (prazoEntrega== null || prazoEntrega== undefined?"0": prazoEntrega);
prazoEntregaAereo= (prazoEntregaAereo== null || prazoEntregaAereo== undefined?"0": prazoEntregaAereo);
tipoDiasEntrega= (tipoDiasEntrega== null || tipoDiasEntrega== undefined?"u": tipoDiasEntrega);
tipoDiasEntregaAereo= (tipoDiasEntregaAereo== null || tipoDiasEntregaAereo== undefined?"u": tipoDiasEntregaAereo);
tipoImpressaoFreteMinimo= (tipoImpressaoFreteMinimo== null || tipoImpressaoFreteMinimo== undefined?"v": tipoImpressaoFreteMinimo);
validaAte= (validaAte== "null" || validaAte== undefined?"": validaAte);
percentualReentrega= (percentualReentrega== null || percentualReentrega== undefined?"0.00": percentualReentrega);
percentualDevolucao= (percentualDevolucao== null || percentualDevolucao== undefined?"0.00": percentualDevolucao);
valorSecCat= (valorSecCat== null || valorSecCat== undefined?"0.00": valorSecCat);
desconsideraIcmsPisCofins= (desconsideraIcmsPisCofins== null || desconsideraIcmsPisCofins== undefined|| desconsideraIcmsPisCofins =="false"? false: desconsideraIcmsPisCofins);
desconsiderarGris= (desconsiderarGris== null || desconsiderarGris== undefined || desconsiderarGris =="false"? false: desconsiderarGris);
desconsiderarPedagio= (desconsiderarPedagio== null || desconsiderarPedagio== undefined || desconsiderarPedagio =="false"? false: desconsiderarPedagio);
desconsiderarSeguro= (desconsiderarSeguro== null || desconsiderarSeguro== undefined || desconsiderarSeguro =="false"? false: desconsiderarSeguro);
desconsiderarDespacho= (desconsiderarDespacho== null || desconsiderarDespacho== undefined || desconsiderarDespacho =="false" ? false: desconsiderarDespacho);
desconsiderarOutros= (desconsiderarOutros== null || desconsiderarOutros== undefined || desconsiderarOutros =="false"? false: desconsiderarOutros);
desconsiderarTaxa= (desconsiderarTaxa== null || desconsiderarTaxa== undefined || desconsiderarTaxa =="false"? false: desconsiderarTaxa);
desconsiderarSecCat = (desconsiderarSecCat == null || desconsiderarSecCat == undefined || desconsiderarSecCat =="false"? false: desconsiderarSecCat);
formulaGris = (formulaGris == null || formulaGris == undefined ? "": formulaGris);
formulaDespacho = (formulaDespacho == null || formulaDespacho == undefined? "": formulaDespacho);
formulaFreteMinimo = (formulaFreteMinimo == null || formulaFreteMinimo == undefined? "": formulaFreteMinimo);
formulaOutros = (formulaOutros == null || formulaOutros == undefined? "": formulaOutros);
formulaSecCat = (formulaSecCat == null || formulaSecCat == undefined? "": formulaSecCat);
formulaSeguro = (formulaSeguro == null || formulaSeguro == undefined? "": formulaSeguro);
formulaTaxaFixa = (formulaTaxaFixa == null || formulaTaxaFixa == undefined? "": formulaTaxaFixa);
formulaTDE = (formulaTDE == null || formulaTDE == undefined? "": formulaTDE);
formulaPedagio = (formulaPedagio == null || formulaPedagio == undefined? "": formulaPedagio);
formulaFretePeso = (formulaFretePeso == null || formulaFretePeso == undefined? "": formulaFretePeso);
tipoFretePeso = (tipoFretePeso == null || tipoFretePeso == undefined? "p": tipoFretePeso);

tipoTaxa = (tipoTaxa == null || tipoTaxa == undefined? "-1": tipoTaxa);


isUtilizaTipoTaxa = (isUtilizaTipoTaxa == null || isUtilizaTipoTaxa == undefined ? ($("utilizaTipoFreteTabelaRem").value == "t") : isUtilizaTipoTaxa);
isConsiderarMaiorPeso = (isConsiderarMaiorPeso == null || isConsiderarMaiorPeso == undefined || isConsiderarMaiorPeso =="false"? false : isConsiderarMaiorPeso);
isConsiderarMaiorValor  = (isConsiderarMaiorValor  == null || isConsiderarMaiorValor  == undefined || isConsiderarMaiorValor =="false" ? false : isConsiderarMaiorValor);
isFreteIdaVolta  = (isFreteIdaVolta  == null || isFreteIdaVolta  == undefined || isFreteIdaVolta =="false" ? false : isFreteIdaVolta);

tipoInclusaoIcms = (tipoInclusaoIcms == null || tipoInclusaoIcms == tipoInclusaoIcms? "t": tipoInclusaoIcms);
pesoLimiteSecCat= (pesoLimiteSecCat== null || pesoLimiteSecCat== undefined?"0.00": pesoLimiteSecCat);
entregaMontagem= (entregaMontagem== null || entregaMontagem== undefined?"0": entregaMontagem);
valorExcedenteSecCat= (valorExcedenteSecCat== null || valorExcedenteSecCat== undefined?"0.00": valorExcedenteSecCat);

valorExcedente= (valorExcedente== null || valorExcedente== undefined?"Digite aqui": valorExcedente);//excedente
valorExcedenteAereo= (valorExcedenteAereo== null || valorExcedenteAereo== undefined?"Digite aqui": valorExcedenteAereo);//aereo

pesoLimiteTaxaFixa= (pesoLimiteTaxaFixa== null || pesoLimiteTaxaFixa== undefined?"0.00": pesoLimiteTaxaFixa);
valorExcedenteTaxaFixa= (valorExcedenteTaxaFixa== null || valorExcedenteTaxaFixa== undefined?"0.00": valorExcedenteTaxaFixa);
//validando as quebras de linha
formulaSecCat = (formulaSecCat.indexOf("&@&")>=0?replaceAll(formulaSecCat,"&@&", "\r\n"):formulaSecCat);
formulaGris = (formulaGris.indexOf("&@&")>=0?replaceAll(formulaGris,"&@&", "\r\n"): formulaGris);
formulaTaxaFixa = (formulaTaxaFixa.indexOf("&@&")>=0?replaceAll(formulaTaxaFixa,"&@&", "\r\n"): formulaTaxaFixa);
formulaOutros = (formulaOutros.indexOf("&@&")>=0?replaceAll(formulaOutros,"&@&", "\r\n"): formulaOutros);
formulaDespacho = (formulaDespacho.indexOf("&@&")>=0?replaceAll(formulaDespacho,"&@&", "\r\n"): formulaDespacho);
formulaSeguro = (formulaSeguro.indexOf("&@&")>=0?replaceAll(formulaSeguro,"&@&", "\r\n"): formulaSeguro);
formulaFreteMinimo = (formulaFreteMinimo.indexOf("&@&")>=0?replaceAll(formulaFreteMinimo,"&@&", "\r\n"): formulaFreteMinimo);
formulaTDE = (formulaTDE.indexOf("&@&")>=0?replaceAll(formulaTDE,"&@&", "\r\n"): formulaTDE);
formulaPedagio = (formulaPedagio.indexOf("&@&")>=0?replaceAll(formulaPedagio,"&@&", "\r\n"): formulaPedagio);
formulaFretePeso = (formulaFretePeso.indexOf("&@&")>=0?replaceAll(formulaFretePeso,"&@&", "\r\n"): formulaFretePeso);
valorPallets = (valorPallets == null || valorPallets == undefined ? "0.00": valorPallets);
dataVigenciaLote= (dataVigenciaLote== "null" || dataVigenciaLote== undefined)?"": dataVigenciaLote;

//Campos da tabela de aereo e faixa de peso
/*
pesoInicial = (pesoInicio == null || pasoInicio == undefined ? "0.00" : pesoInicio);
pesoFinal = (pesoFinal == null || pesoFinal == undefined ? "0.00" : pesoFinal);
id = (id == null || id == undefined ? "0.00" : id);
valor = (valor == null || valor == undefined ? "0.00" : valor);
tipoValor = (tipoValor == null || tipoValor == undefined ? "0.00" : tipoValor); */

    var _tr = '';
    var _td = '';
    var listaTFL= null;
    var listaAe = null;
    var classe = ((indexTabela % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');

	if (incluindo && indexTabela > 0 && $('tipo'+(indexTabela-1)) != null && !isAjax){
		var indexAnterior = indexTabela-1;
		tipo = $('tipo'+indexAnterior).value;
		idOrigem = $('idOrigem'+indexAnterior).value;
		origem = $('origem'+indexAnterior).innerHTML;
		idProduto = $('idProduto'+indexAnterior).value;
		produto = $('produto'+indexAnterior).innerHTML;
		valorPeso = $('valorPeso_'+indexAnterior).value;
		ton = $('ton'+indexAnterior).value;
		baseCub = $('baseCub_'+indexAnterior).value;
		valorVolume = $('valorVolume_'+indexAnterior).value;
		percentualNf = $('percentualNf_'+indexAnterior).value;
		basePercentual = $('basePercentual_'+indexAnterior).value;
		valorPercentual = $('valorPercentual_'+indexAnterior).value;
		valorCombinado = $('valorCombinado_'+indexAnterior).value;
		valorGris = $('valorGris_'+indexAnterior).value;
		valorSeguro = $('valorSeguro_'+indexAnterior).value;
		valorTaxa = $('valorTaxa_'+indexAnterior).value;
		valorOutros = $('valorOutros_'+indexAnterior).value;
		valorDespacho = $('valorDespacho_'+indexAnterior).value;
                freteMinimo = $('freteMinimo_'+indexAnterior).value;
		incluiIcms = $('IncluiIcms_'+indexAnterior).value;
		tipoFretePeso = $('tipoPeso_'+indexAnterior).value;
                valorExcedente = $('valor_excedente_'+indexAnterior).value;
                valorExcedenteAereo = $('valor_excedente_aereo_'+indexAnterior).value;
                
                //novos campos
		incluirPisConfins = $('IncluiPisCofins_'+indexAnterior).value;
		valorMinimoGris = $('valorMinimoGris_'+indexAnterior).value;
                valorPedagio = $('valorPedagio_'+indexAnterior).value;
                qtdQuiloPedagio = $('qtdQuiloPedagio_'+indexAnterior).value;
                valorTde= $('valorTde_'+indexAnterior).value;
                tipoTde= $('tipoTde_'+indexAnterior).value;
                prazoEntrega= $('prazoEntrega_'+indexAnterior).value;
                prazoEntregaAereo= $('prazoEntregaAereo_'+indexAnterior).value;
                tipoDiasEntrega= $('tipoDiasEntrega_'+indexAnterior).value;
                tipoTaxa = $('tipoTaxa_'+indexAnterior).value;
                tipoDiasEntregaAereo= $('tipoDiasEntregaAereo_'+indexAnterior).value;
                validaAte= $('validaAte_'+indexAnterior).value;
                percentualReentrega= $('percentualReentrega_'+indexAnterior).value;
                percentualDevolucao= $('percentualDevolucao_'+indexAnterior).value;
                valorSecCat= $('valorSecCat_'+indexAnterior).value;
                calculaSecCat = $('calculaSecCat_'+indexAnterior).value;
                dataVigenciaLote = $('dataVigenciaLote_'+indexAnterior).value;
                //aos checks
                desconsideraIcmsPisCofins = $('desconsideraIcmsPisCofins_'+indexAnterior).checked;
                desconsiderarGris = $('desconsideraGris_'+0).checked;
                desconsiderarDespacho = $('desconsideraDespacho_'+indexAnterior).checked;
                desconsiderarOutros =  $('desconsideraOutros_'+indexAnterior).checked;
                desconsiderarPedagio = $('desconsideraPedagio_'+indexAnterior).checked;
                desconsiderarSeguro = $('desconsideraSeguro_'+indexAnterior).checked;
                desconsiderarSecCat = $('desconsideraSecCat_'+indexAnterior).checked;
                desconsiderarTaxa = $('desconsideraTaxaFixa_'+indexAnterior).checked;
                isConsiderarMaiorValor = $("chkConsiderarMaiorValor_"+indexAnterior).checked;
                isConsiderarMaiorPeso = $("chkConsiderarPeso_"+indexAnterior).checked;
                isFreteIdaVolta = $("chkFreteIdaVolta_"+indexAnterior).checked;
//                
                //formulas
                formulaDespacho = $('formulaDespacho_'+indexAnterior).value;
                formulaFreteMinimo = $('formulaFreteMinimo_'+indexAnterior).value;
                formulaGris = $('formulaGris_'+indexAnterior).value;
                formulaOutros = $('formulaOutros_'+indexAnterior).value;
                formulaSecCat = $('formulaSecCat_'+indexAnterior).value;
                formulaSeguro = $('formulaSeguro_'+indexAnterior).value;
                formulaTaxaFixa = $('formulaTaxaFixa_'+indexAnterior).value;
                formulaTDE = $('formulaTDE_'+indexAnterior).value;
                formulaPedagio = $('formulaPedagio_'+indexAnterior).value;
                valorPallets = $('valorPallets_'+indexAnterior).value;
                
                arryTabAe = new Array();
                var maxFaixaAe = $("maxFaixaAerea_"+indexAnterior).value;
                objAe = 0;
                iTabAe = 0;
                for (var j = 0; j <= maxFaixaAe; j++) {
                    
                    if ($("idFaixa_"+indexAnterior+"_a_" + j) != null && $("idFaixa_"+indexAnterior+"_a_" + j) != undefined) {
                        objAe = new TabelaPeso();        
                        objAe.id = $("idFaixa_"+indexAnterior+"_a_" + j).value;
                        objAe.pesoInicial = $("pesoInicio_"+indexAnterior+"_a_" + j).value;
                        objAe.pesoFinal = $("pesoFinal_"+indexAnterior+"_a_" + j).value;
                        objAe.valor = $("valorPeso_"+indexAnterior+"_a_" + j).value;
                        objAe.tipoValor = $("slc_"+indexAnterior+"_a_" + j).value;
                        arryTabAe[iTabAe++] = objAe;
                    }
                }

                
                arryTabTFM = new Array();
                var maxFaixaTFM = $("maxFaixaTFM_"+indexAnterior).value;
                objTFM = 0;
                iTabTFM = 0;
                for (var k = 0; k <= maxFaixaTFM; k++) {
                    if ($("idFaixa_"+indexAnterior+"_tfm_" + k) != null && $("idFaixa_"+indexAnterior+"_tfm_" + k) != undefined) {
                        objTFM = new TabelaPeso();
                        objTFM.id = $("idFaixa_"+indexAnterior+"_tfm_" + k).value;
                        objTFM.pesoInicial = $("pesoInicio_"+indexAnterior+"_tfm_" + k).value;
                        objTFM.pesoFinal = $("pesoFinal_"+indexAnterior+"_tfm_" + k).value;
                        objTFM.valor = $("valorPeso_"+indexAnterior+"_tfm_" + k).value;
                        objTFM.tipoValor = $("slc_"+indexAnterior+"_tfm_" + k).value;
                        arryTabTFM[iTabTFM++] = objTFM;
                    }
                }
            }

     //Criando a tr
    _tr = Builder.node('TBODY', {id:'tabela'+indexTabela},
	       [Builder.node('TR', {id:'tr'+indexTabela, className:classe},
                 [Builder.node('TD', 
                     [Builder.node('SELECT', {
                                name:'tipo'+indexTabela, 
                                id:'tipo'+indexTabela, 
                                className:'fieldMin2', 
                                onChange:'javascript:alteraTipoRota('+indexTabela+');'
                            },
                     [Builder.node('OPTION', {
                                value:'c'
                            }, 'Cidade'
                            ),
                     Builder.node('OPTION', {
                                value:'a'
                             }, 'Área'
                            )
                            ]),
                     Builder.node('LABEL', {
                                name:'idTabela'+indexTabela, 
                                id:'idTabela'+indexTabela, 
                                className:'linkEditar',
                                onClick:'javascript:alteraTabela('+idTabela+');'
                            }),
                     Builder.node('INPUT', {
                                name:'tabela'+indexTabela, 
                                id:'tabela'+indexTabela, 
                                value:idTabela, 
                                type:'hidden'
                             })
                   ]),
                Builder.node('TD', 
                      [Builder.node('LABEL', {
                                name:'origem'+indexTabela, 
                                id:'origem'+indexTabela
                        }),
			
                      Builder.node('INPUT', {
                            name:'idOrigem'+indexTabela, 
                            id:'idOrigem'+indexTabela, 
                            value:idOrigem, 
                            type:'hidden'
                        }),
                      Builder.node('INPUT', {
                            type:'button', 
                            name:'localizaOrigem_'+indexTabela, 
                            id:'localizaOrigem_'+indexTabela, 
                            value:'...', className:'botoes',
                            onClick:'javascript:localizaOrigem('+indexTabela+');'
                      })
                 ]),
                       
               Builder.node('TD', 
                     [Builder.node('LABEL', {
                            name:'destino'+indexTabela, 
                            id:'destino'+indexTabela
                        }),
                     Builder.node('INPUT', {
                            name:'idDestino'+indexTabela, 
                            id:'idDestino'+indexTabela, 
                            value:idDestino, 
                            type:'hidden'
                        }),
                     Builder.node('INPUT', {
                            type:'button', 
                            name:'localizaDestino_'+indexTabela, 
                            id:'localizaDestino_'+indexTabela, 
                            value:'...', className:'botoes',
                            onClick:'javascript:localizaDestino('+indexTabela+');'
                            })
                     ]),
                     
               Builder.node('TD',
                   [Builder.node('LABEL', {
                            name:'produto'+indexTabela, 
                            id:'produto'+indexTabela
                     }),
                     Builder.node('INPUT', {
                            name:'idProduto'+indexTabela, 
                            id:'idProduto'+indexTabela, 
                            value:idProduto, 
                            type:'hidden'
                     }),
                     Builder.node('INPUT', {
                            type:'button', 
                            name:'localizaProduto_'+indexTabela, 
                            id:'localizaProduto_'+indexTabela, 
                            value:'...', className:'botoes',
                            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=37\',\'Tipo_Produto_'+indexTabela+'\');'
                     }),
                     Builder.node('IMG', {
                            src:'img/borracha.gif', 
                            id:'limpaProduto_'+indexTabela, 
                            name:'limpaProduto_'+indexTabela, 
                            border:'0', 
                            align:'absbottom', 
                            className:'imagemLink', 
                            title:'Limpar tipo de produto', 
                            onClick:'javascript:limparProduto('+indexTabela+')'
                        })
                   ]),
                   
              Builder.node('TD',
                    [Builder.node('SELECT', {
                             name:'tipoPeso_'+indexTabela, 
                             style:'width:50px', 
                             id:'tipoPeso_'+indexTabela, 
                             className:'fieldMin2', 
                             onchange:"sltTipoPeso("+indexTabela+")" 
                         },
                     [Builder.node('OPTION', {
                             value:'p'
                     }, 'Peso'),
                     Builder.node('OPTION', {
                         value:'f'
                     }, 'Faixa Peso')
                     ])
                     ]),
             Builder.node('TD',
                   [Builder.node('INPUT', {
                           type:'text', 
                           name:'valorPeso_'+indexTabela, 
                           id:'valorPeso_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(valorPeso), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'valorPeso_'+indexTabela+'\'), \'0.00\');'
                   }),
                   Builder.node('INPUT', {
                          type:'hidden', 
                          name:'hi_valorPeso_'+indexTabela, 
                          id:'hi_valorPeso_'+indexTabela, 
                          value: formatoMoeda(valorPeso)
                      }),
                   ]),
             Builder.node('TD',
                   [Builder.node('SELECT', {
                           name:'ton'+indexTabela, 
                           id:'ton'+indexTabela, 
                           className:'fieldMin2'
                       },
                   [Builder.node('OPTION', {
                           value:'S'
                       }, 'Sim'),
                   Builder.node('OPTION', {
                          value:'N'
                      }, 'Não')
                     ])
                   ]),
             
             Builder.node('TD',
                   [Builder.node('INPUT', {
                          type:'text', 
                          name:'baseCub_'+indexTabela, 
                           id:'baseCub_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(baseCub), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'baseCub_'+indexTabela+'\'), \'0.00\');'
                       }),
                   Builder.node('INPUT', {
                       type:'hidden', 
                       name:'hi_baseCub_'+indexTabela, 
                       id:'hi_baseCub_'+indexTabela,
                       size:'7', 
                       maxLength:'12', 
                       value:formatoMoeda(baseCub)
                    })
                  ]),
             Builder.node('TD',
                   [Builder.node('INPUT', {
                           type:'text', 
                           name:'valorVolume_'+indexTabela, 
                           id:'valorVolume_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(valorVolume), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'valorVolume_'+indexTabela+'\'), \'0.00\');'}),
                   Builder.node('INPUT', {
                       type:'hidden', 
                       name:'hi_valorVolume_'+indexTabela, 
                       id:'hi_valorVolume_'+indexTabela,
                       size:'7', 
                       maxLength:'12', 
                       value:formatoMoeda(valorVolume)
                   })
                   ]),
             Builder.node('TD',
                   [Builder.node('INPUT', {
                           type:'text', 
                           name:'percentualNf_'+indexTabela, 
                           id:'percentualNf_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(percentualNf), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'percentualNf_'+indexTabela+'\'), \'0.00\');'
                       })
                   ]),
             Builder.node('TD',
                   [Builder.node('INPUT', {
                           type:'text', 
                           name:'basePercentual_'+indexTabela, 
                           id:'basePercentual_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(basePercentual), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'basePercentual_'+indexTabela+'\'), \'0.00\');'
                        }),
                   Builder.node('INPUT', {
                           type:'hidden', 
                           name:'hi_basePercentual_'+indexTabela, 
                           id:'hi_basePercentual_'+indexTabela,
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(basePercentual), 
                           className:'fieldMin2'
                       })
                  ]),
             Builder.node('TD',
                   [Builder.node('INPUT', {
                           type:'text', 
                           name:'valorPercentual_'+indexTabela, 
                           id:'valorPercentual_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(valorPercentual), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'valorPercentual_'+indexTabela+'\'), \'0.00\');'
                        }),
                   Builder.node('INPUT', {
                           type:'hidden', 
                           name:'hi_valorPercentual_'+indexTabela, 
                           id:'hi_valorPercentual_'+indexTabela,
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(valorPercentual), 
                           className:'fieldMin2'
                       })
                  ]),
                  
             Builder.node('TD',
                   [Builder.node('INPUT', {
                           type:'text', 
                           name:'valorCombinado_'+indexTabela, 
                           id:'valorCombinado_'+indexTabela, 
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(valorCombinado), 
                           className:'fieldMin2',
                           onchange:'seNaoFloatReset($(\'valorCombinado_'+indexTabela+'\'), \'0.00\');'
                       }),
                   Builder.node('INPUT', {
                           type:'hidden', 
                           name:'hi_valorCombinado_'+indexTabela, 
                           id:'hi_valorCombinado_'+indexTabela,
                           size:'7', 
                           maxLength:'12', 
                           value:formatoMoeda(valorCombinado), 
                           className:'fieldMin2'
                      })
                ]),
               
                Builder.node('TD',  
                      [Builder.node('IMG', {
                           src:'img/lixo.png', 
                           title:'Excluir tabela da lista', 
                           className:'imagemLink', 
                           onClick:'excluirTabela('+incluindo+','+indexTabela+');'
                       })])
                ]),
               
                Builder.node('TR', {
                    id:'trFaixaPeso_'+indexTabela,  
                    className:classe
                 },

                [Builder.node('TD', {
                      width:'100%',
                      colSpan:'14'
                 },
           
                [Builder.node('TABLE', {
                       width:'60%', 
                       border:'1', 
                       cellPadding:"0", 
                       cellSpacing:"0", 
                       id:'tbFaixaPeso'+indexTabela
                   },
                [Builder.node('TBODY', {
                       id:'tbbFaixaPeso'+indexTabela
                 }),
                 
                  Builder.node('TD', {className:classe, align:"center", width:"25%"},['Excedente ',
                            Builder.node('input',{
                                name:"valor_excedente_"+indexTabela,
                                id:"valor_excedente_"+indexTabela,
                                className:'fieldMin2',
                                value:formatoMoeda(valorExcedente),
                                onchange:'seNaoFloatReset($(\'valor_excedente_'+indexTabela+'\'), \'0.00\');'
                            })// Fim input
                            ,Builder.node('input',{
                                name:"hi_valor_excedente_"+indexTabela,
                                id:"hi_valor_excedente_"+indexTabela,
                                type: "hidden",
                                className:'fieldMin2',
                                value:formatoMoeda(valorExcedente)
                                
                            })// Fim input
                         ]),//fim td 

                  Builder.node('TD', {className:classe, align:"center", width:"25%"},['Excedente ',
                            Builder.node('input',{
                                name:"valor_excedente_aereo_"+indexTabela,
                                id:"valor_excedente_aereo_"+indexTabela,
                                className:'fieldMin2',
                                value:formatoMoeda(valorExcedenteAereo),
                                onchange:'seNaoFloatReset($(\'valor_excedente_aereo_'+indexTabela+'\'), \'0.00\');'
                            })// Fim input
                            ,Builder.node('input',{
                                name:"hi_valor_excedente_aereo_"+indexTabela,
                                id:"hi_valor_excedente_aereo_"+indexTabela,
                                type: "hidden",
                                className:'fieldMin2',
                                value:formatoMoeda(valorExcedenteAereo)
                            })// Fim input
                         ])//fim td 
                      ])
                ])
                ]),
                Builder.node('TR', {
                       id:'trG'+indexTabela
                   },
                [Builder.node('TD', {
                       width:'100%',
                       colSpan:'14'
                   },
                [Builder.node('TABLE', {
                       width:'100%', 
                       border:'0', 
                       id:'tbG'+indexTabela
                   },
                [Builder.node('TBODY', {
                        id:'tbG2'+indexTabela
                })])
                ])
                ])
                ]);
    $('tabelaP').appendChild(_tr);
    
    _tr_fp = Builder.node('TR',{},
                [
                Builder.node('TD',
                {className:classe,  align:"left"}, 
<!--                    [Builder.node('b',['Terrestre, Fluvial, Marítimo'])],-->
                    [Builder.node('IMG',{
                        border:'0',
                        src:'./img/add.gif',
                        width: '4%',
                        style:'cursor:pointer;',
                        align:'center',
                        onclick:'addTipoTFM('+listaTFL+','+indexTabela+','+linha+');'
                     }),Builder.node('b',['Terrestre, Fluvial, Marítimo'])]
                ),
                    Builder.node('TD',
                    {className:classe,  align:"left"}, 
                    [ Builder.node('IMG',{
                        border:'0',
                        src:'./img/add.gif',
                        width: '4%',
                        style:'cursor:pointer;',
                        align:'center',
                        onclick:'addTipoAereo('+listaAe+','+indexTabela+','+linha+');'
                    }),Builder.node('b',['Aéreo'])]
                       <!--[Builder.node('b',['Aéreo'])]-->
                    )
              ]);
                
    $('tbbFaixaPeso'+indexTabela).appendChild(_tr_fp);

   _tr_fp_2 = Builder.node('TR',{},
                    [Builder.node("TD",{
                            id:"tdR_"+indexTabela
                        },
                    [Builder.node("TABLE",{
                            border:'1', 
                            cellPadding:"0", 
                            cellSpacing:"0", 
                            width:"100%"
                        },
                    [Builder.node("TBODY",{
                            name:"tbTpFRM_"+indexTabela, 
                            id:"tbTpFRM_"+indexTabela
                        },
                    [Builder.node("TR",{},
                           [<!--Builder.node('TD', {className:classe, align:"center", width:"4%"},['  ']),-->
                           Builder.node('TD', {
                               className:classe, 
                               align:"center", 
                               width:"25%"
                           },
                           ['De (Kg)',
                           Builder.node('input',{
                               type: "hidden", 
                               name:"maxFaixaTFM_"+indexTabela, 
                               id:"maxFaixaTFM_"+indexTabela
                           })
                    ]),
                    Builder.node('TD', {
                            className:classe, 
                            align:"center", 
                            width:"25%"
                        },['Até (Kg)']),
                    Builder.node('TD', {
                            className:classe, 
                            align:"center", 
                            width:"25%"
                        },['Valor (Kg)']),
                    Builder.node('TD', {
                            className:classe, 
                            align:"center", 
                            width:"25%"
                        })
                    ])
                ])
            ])
                            ]),
                    Builder.node("TD",{
                            id:"tdA_"+indexTabela
                    },
                    [Builder.node("TABLE",{
                            border:'1', 
                            cellPadding:"0", 
                            cellSpacing:"0", 
                            width:"100%"
                    },
                    [Builder.node("TBODY",{
                            name:"tbTpAereo_"+indexTabela, 
                            id:"tbTpAereo_"+indexTabela
                    },
                    [Builder.node("TR",{},
                        [
                            Builder.node('TD', {className:classe, align:"center", width:"4%"},[' ']),
                            Builder.node('TD', {className:classe, align:"center", width:"25%"},['De (Kg)',
                            Builder.node('input',{type: "hidden", name:"maxFaixaAerea_"+indexTabela, id:"maxFaixaAerea_"+indexTabela})
                            ]),
                            Builder.node('TD', {className:classe, align:"center", width:"25%"},['Até (Kg)']),
                            Builder.node('TD', {className:classe, align:"center", width:"25%"},['Valor (Kg)']),
                            Builder.node('TD', {className:classe, align:"center", width:"25%"})
                        ])
                        ])
                    ])
                ])
        ]);
    //variaveis usadas na tabela de tipo de peso
    //$('texte2'+indexTabela).style.verticalAlign = "top";
    $('tbbFaixaPeso'+indexTabela).appendChild(_tr_fp_2);
    $('tdR_'+indexTabela).style.verticalAlign = "top";
    $('tdA_'+indexTabela).style.verticalAlign = "top";

    //variaveis usadas na tabela de tipo terrestre, fluvial e maritimo
    var linhaTFL = 0;
    var linhaAereo = 0;
    var _tr_fp = '';
    var _tr_fp_2 = '';
    
    
    
    if(isIncluiFaixa){
        linhaTFL= 0;
        linhaAereo = 0;

        //<while(rsFaixa.next()){%>
        for(var tfm = 0; tfm < arryTabTFM.size(); tfm++){
            //povoando o objeto
                        //inserindo um linha
            if (arryTabTFM[tfm] != null && arryTabTFM[tfm]!= undefined) {
                addListaTipoTFM(arryTabTFM[tfm], linhaTFL, incluindo);
                linhaTFL++;
            }
        }
        for(var ae = 0; ae < arryTabAe.size(); ae++){
            //povoando o objeto
                        //inserindo um linha
            if (arryTabAe[ae] != null && arryTabAe[ae]!= undefined) {
                addListaTipoAereo(arryTabAe[ae], linhaAereo, incluindo);
                linhaAereo++;
            }
        }
        
    }


    _tr =	Builder.node('TR', {className:classe}, 
    [Builder.node('TD',{width:'25%', className:classe, colSpan:"2"},
    [Builder.node('B',
    [Builder.node('DIV', {align:'right'}, 'Generalidades:')]),
    Builder.node('INPUT',{type:'hidden', name:'formulaSeguro_'+indexTabela, id:'formulaSeguro_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaFretePeso_'+indexTabela, id:'formulaFretePeso_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaDespacho_'+indexTabela, id:'formulaDespacho_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaFreteMinimo_'+indexTabela, id:'formulaFreteMinimo_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaGris_'+indexTabela, id:'formulaGris_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaOutros_'+indexTabela, id:'formulaOutros_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaSecCat_'+indexTabela, id:'formulaSecCat_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaTaxaFixa_'+indexTabela, id:'formulaTaxaFixa_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaTDE_'+indexTabela, id:'formulaTDE_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'formulaPedagio_'+indexTabela, id:'formulaPedagio_'+indexTabela}),
    Builder.node('INPUT',{type:'hidden', name:'valorPallets_'+indexTabela, id:'valorPallets_'+indexTabela})
    ]),
    Builder.node('TD',{width:'8%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'AdValorEm:')]),
    Builder.node('TD',{width:'7%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorSeguro_'+indexTabela, id:'valorSeguro_'+indexTabela, 
    size:'7', maxLength:'12', value:formatoMoeda(valorSeguro), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorSeguro_'+indexTabela+'\'), \'0.00\');limitarCampo(this,\'AdValorEm\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorSeguro_'+indexTabela, id:'hi_valorSeguro_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorSeguro)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:"javascript:exibirFormula($('formulaSeguro_"+indexTabela+"'))"})
    ])
    ]),
    Builder.node('TD',{width:'6%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'GRIS:')]),
    Builder.node('TD',{width:'6%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorGris_'+indexTabela, id:'valorGris_'+indexTabela, 
    size:'7', maxLength:'12', value:formatoMoeda(valorGris), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorGris_'+indexTabela+'\'), \'0.00\');limitarCampo(this,\'GRIS\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorGris_'+indexTabela, id:'hi_valorGris_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorGris)})
    ]),
    Builder.node('TD',{width:'6%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'Mín. GRIS:')]),
    Builder.node('TD',{width:'7%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorMinimoGris_'+indexTabela, id:'valorMinimoGris_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorMinimoGris), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorMinimoGris_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorMinimoGris_'+indexTabela, id:'hi_valorMinimoGris_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorMinimoGris)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaGris_'+indexTabela+'\'));'})
    ])
    ]),
    Builder.node('TD',{width:'5%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'Outros:')]),
    Builder.node('TD',{width:'7%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorOutros_'+indexTabela, id:'valorOutros_'+indexTabela, 
    size:'7', maxLength:'12', value:formatoMoeda(valorOutros), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorOutros_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorOutros_'+indexTabela, id:'hi_valorOutros_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorOutros)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaOutros_'+indexTabela+'\'));'})
    ])
    ]),
    Builder.node('TD',{width:'5%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'Taxa Origem:'),
        Builder.node('BR'),
    Builder.node('DIV', {align:'right'}, 'Excedente:')]),
    Builder.node('TD',{width:'7%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorTaxa_'+indexTabela, id:'valorTaxa_'+indexTabela, 
    size:'7', maxLength:'12', value:formatoMoeda(valorTaxa), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorTaxa_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorTaxa_'+indexTabela, id:'hi_valorTaxa_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorTaxa)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaTaxaFixa_'+indexTabela+'\'));'})
    ])
    ,Builder.node('input', {name:'entregaMontagem_'+indexTabela, id:'entregaMontagem_'+indexTabela, value: entregaMontagem, type:'hidden'})
    ,Builder.node('input', {name:'pesoLimiteTaxaFixa_'+indexTabela, id:'pesoLimiteTaxaFixa_'+indexTabela, value: pesoLimiteTaxaFixa, type:'hidden'})
    ,Builder.node('input', {name:'valorExcedenteTaxaFixa_'+indexTabela, id:'valorExcedenteTaxaFixa_'+indexTabela, 
        value: formatoMoeda(valorExcedenteTaxaFixa), type:'text', className:'fieldMin2', size:'7', maxLength:'12', 
        onchange:'seNaoFloatReset($(\'valorExcedenteTaxaFixa_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('input', {name:'hi_valorExcedenteTaxaFixa_'+indexTabela, id:'hi_valorExcedenteTaxaFixa_'+indexTabela, 
        value: formatoMoeda(valorExcedenteTaxaFixa), type:'hidden', className:'fieldMin2'})
    ]),
    Builder.node('TD',{width:'5%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'Despacho')]),
    Builder.node('TD',{width:'7%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorDespacho_'+indexTabela, id:'valorDespacho_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorDespacho), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorDespacho_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorDespacho_'+indexTabela, id:'hi_valorDespacho_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorDespacho)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaDespacho_'+indexTabela+'\'));'})

    ])
    ])
    ]
    );
    _tr_1 =	Builder.node('TR', {className:classe},
    [Builder.node('TD',{width:'9%', className:classe},
    [Builder.node('DIV', {align:'right'}, 'SEC/CAT (Destino):'),
        Builder.node('BR'),
        Builder.node('DIV', {align:'right'}, 'Excedente:')
    ]),
    Builder.node('TD',{width:'7%', className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorSecCat_'+indexTabela, id:'valorSecCat_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorSecCat), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorSecCat_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorSecCat_'+indexTabela, id:'hi_valorSecCat_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorSecCat)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaSecCat_'+indexTabela+'\'));'})
    ])
    ,Builder.node('input', {name:'pesoLimiteSecCat_'+indexTabela, id:'pesoLimiteSecCat_'+indexTabela, value: pesoLimiteSecCat, type:'hidden'})
    ,Builder.node('input', {name:'valorExcedenteSecCat_'+indexTabela, id:'valorExcedenteSecCat_'+indexTabela, 
        value: formatoMoeda(valorExcedenteSecCat), type:'text', className:'fieldMin2', size:'7', maxLength:'12', 
        onchange:'seNaoFloatReset($(\'valorExcedenteSecCat_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('input', {name:'hi_valorExcedenteSecCat_'+indexTabela, id:'hi_valorExcedenteSecCat_'+indexTabela, 
        value: formatoMoeda(valorExcedenteSecCat), type:'hidden'})
    ]),
    Builder.node('TD',{ className:classe},
    [Builder.node('DIV', {align:'left'},
    [Builder.node('SELECT', {name:'calculaSecCat_'+indexTabela, id:'calculaSecCat_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'c'}, 'Sempre calcular'),
    Builder.node('OPTION', {value:'p'}, 'Perguntar')
    ])])]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Incluir Icms:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('SELECT', {name:'IncluiIcms_'+indexTabela, id:'IncluiIcms_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'S'}, 'Sim'),
    Builder.node('OPTION', {value:'N'}, 'Não')
    ])
    ,Builder.node('input', {name:'tipoInclusaoIcms_'+indexTabela, id:'tipoInclusaoIcms_'+indexTabela, value: tipoInclusaoIcms, type:'hidden'})

    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Pis/Cof.:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('SELECT', {name:'IncluiPisCofins_'+indexTabela, id:'IncluiPisCofins_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'S'}, 'Sim'),
    Builder.node('OPTION', {value:'N'}, 'Não')
    ])
    ]),
    Builder.node('TD',{colSpan: '8'},
    
    [
    [Builder.node('DIV', {align:'right'}, ''),
            Builder.node('INPUT',{type:'checkbox', name:'desconsideraIcmsPisCofins_'+indexTabela,value:"true",
            id:'desconsideraIcmsPisCofins_'+indexTabela}),
            'Desconsiderar inclusão de ICMS e PIS/COFINS em caso de frete mínimo.'
        ]
    ,
    [Builder.node('DIV', {align:'right'}, ''),
        Builder.node('INPUT',{type:'checkbox', name:'chkConsiderarMaiorValor_'+indexTabela,value:'checked',
        id:'chkConsiderarMaiorValor_'+indexTabela}),
        ' Considerar o valor de frete maior entre Peso/kg e % Nota Fiscal. '
    ]
    ,
    [Builder.node('DIV', {align:'right'}, ''),
        Builder.node('INPUT',{type:'checkbox', name:'chkConsiderarPeso_'+indexTabela,value:'checked',
        id:'chkConsiderarPeso_'+indexTabela}),
        'Considerar Peso/Cubagem caso o peso da mercadoria seja inferior ao peso cubado.'   
    ] 
    ,
    [Builder.node('DIV', {align:'right'}, ''),
        Builder.node('INPUT',{type:'checkbox', name:'chkFreteIdaVolta_'+indexTabela,value:'checked',
        id:'chkFreteIdaVolta_'+indexTabela}),
        ' Frete Ida e Volta '
    ]
    ])
    
    ]);


    _tr_2 =	Builder.node('TR', {className:classe},
    [Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Frete mínimo:')]),
    Builder.node('TD',{ className:classe},
    [Builder.node('INPUT', {type:'text', name:'freteMinimo_'+indexTabela, id:'freteMinimo_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(freteMinimo), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'freteMinimo_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_freteMinimo_'+indexTabela, id:'hi_freteMinimo_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(freteMinimo)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaFreteMinimo_'+indexTabela+'\'));'})
    ])
    ]),
    Builder.node('TD',{className:classe },
    [Builder.node('DIV', {align:'right'}, 'Calcular em:')]),
    Builder.node('TD',{className:classe},[
    Builder.node('SELECT', {name:'tipoImpressaoFreteMinimo_'+indexTabela, id:'tipoImpressaoFreteMinimo_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'v'}, 'Frete Valor'),
    Builder.node('OPTION', {value:'p'}, 'Frete Peso')
    ])
    ]),
    Builder.node('TD',{className:classe, colSpan:"3"},
    [Builder.node('DIV', {align:'right'}, 'Desconsiderar cálc. fre. mínimo:')]),
    Builder.node('TD',{className:classe, colSpan:"7"},
    [Builder.node('TABLE',{width:'100%', id: 'tbDesc_'+indexTabela},
    [   Builder.node('tbody', {width:'100%', id: 'tbbDesc_'+indexTabela},[

    Builder.node('TR',{className:classe},
    [Builder.node('TD',{width:'12%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsiderarTodos_', value:"true",
    id:'desconsiderarTodos_'+indexTabela, onclick:'desconsideraTodos('+indexTabela+')'}),Builder.node('b','Todos')
    ]
    ),
    Builder.node('TD',{width:'10%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraGris_'+indexTabela,value:"true",
    id:'desconsideraGris_'+indexTabela}),'GRIS'
    ]
    ),
    Builder.node('TD',{width:'12%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraSeguro_'+indexTabela,value:"true",
    id:'desconsideraSeguro_'+indexTabela}),'Seguro'
    ]
    ),
    Builder.node('TD',{width:'12%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraDespacho_'+indexTabela,value:"true",
    id:'desconsideraDespacho_'+indexTabela}),'Desp.'
    ]
    )
    ]),
    Builder.node('TR',{className:classe},
    [Builder.node('TD',{width:'12%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraPedagio_'+indexTabela,value:"true",
    id:'desconsideraPedagio_'+indexTabela}),'Pedágio'
    ]
    ),
    Builder.node('TD',{width:'12%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraTaxaFixa_'+indexTabela,value:"true",
    id:'desconsideraTaxaFixa_'+indexTabela}),'T. Fixa'
    ]
    ),
    Builder.node('TD',{width:'14%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraSecCat_'+indexTabela,value:"true",
    id:'desconsideraSecCat_'+indexTabela}),'SEC/CAT'
    ]
    ),
    Builder.node('TD',{width:'12%'},
    [Builder.node('INPUT',{type:'checkbox', name:'desconsideraOutros_'+indexTabela,value:"true",
    id:'desconsideraOutros_'+indexTabela}),'Outros'
    ]
    )
    ])

    ])

    ]

    )]
    )
    ]);
    _tr_3 =	Builder.node('TR', {className:classe},
    [Builder.node('TD',{ className:classe},
    [Builder.node('DIV', {align:'right'}, 'TDE:')]),
    Builder.node('TD',{ className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorTde_'+indexTabela, id:'valorTde_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorTde), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorTde_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorTde_'+indexTabela, id:'hi_valorTde_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorTde)}),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaTDE_'+indexTabela+'\'));'})
    ])
    ]),
    Builder.node('TD',{ className:classe, colSpan:"2"},
    [Builder.node('DIV', {align:'left'},
    [Builder.node('SELECT', {name:'tipoTde_'+indexTabela, id:'tipoTde_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'v'}, 'R$ sobre o total do frete'),
    Builder.node('OPTION', {value:'p'}, '% sobre o total do frete')
    ])
    ])
    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Reentrega:')]),
    Builder.node('TD',{ className:classe},
    [Builder.node('INPUT', {type:'text', name:'percentualReentrega_'+indexTabela, id:'percentualReentrega_'+indexTabela,
    size:'5', maxLength:'8', value:formatoMoeda(percentualReentrega), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'percentualReentrega_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_percentualReentrega_'+indexTabela, id:'hi_percentualReentrega_'+indexTabela, value:formatoMoeda(percentualReentrega)}),"%"
    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Devolução:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('INPUT', {type:'text', name:'percentualDevolucao_'+indexTabela, id:'percentualDevolucao_'+indexTabela,
    size:'5', maxLength:'10', value:formatoMoeda(percentualDevolucao), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'percentualDevolucao_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_percentualDevolucao_'+indexTabela, id:'hi_percentualDevolucao_'+indexTabela, value:formatoMoeda(percentualDevolucao)}),"%"
    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Pedágio:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('INPUT', {type:'text', name:'valorPedagio_'+indexTabela, id:'valorPedagio_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorPedagio), className:'fieldMin2',
    onchange:'seNaoFloatReset($(\'valorPedagio_'+indexTabela+'\'), \'0.00\');'}),
    Builder.node('INPUT', {type:'hidden', name:'hi_valorPedagio_'+indexTabela, id:'hi_valorPedagio_'+indexTabela,
    size:'7', maxLength:'12', value:formatoMoeda(valorPedagio)})
    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'a cada')]),
    Builder.node('TD',{className:classe, colSpan:"3"},
    [Builder.node('INPUT', {type:'text', name:'qtdQuiloPedagio_'+indexTabela, id:'qtdQuiloPedagio_'+indexTabela,
    size:'4', maxLength:'5', className:'fieldMin2', value:qtdQuiloPedagio,
    onchange:'seNaoIntReset($(\'qtdQuiloPedagio_'+indexTabela+'\'), 0);'}),'Kg ou fração',
    Builder.node('INPUT',{type:'hidden', name:'hi_qtdQuiloPedagio_'+indexTabela, id:'hi_qtdQuiloPedagio_'+indexTabela,
    size:'4', maxLength:'5', value:qtdQuiloPedagio }),
    Builder.node('strong',{href:'#topo'},[
    Builder.node('img',{src:'img/formula.png', className:'imagemLink',  onclick:'javascript:exibirFormula($(\'formulaPedagio_'+indexTabela+'\'));'})
    ])
    ])

    ]
    );
    _tr_4 =	Builder.node('TR', {className:classe},
    [

    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Prazo Ent.:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Rodoviario:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('INPUT', {type:'text', name:'prazoEntrega_'+indexTabela, id:'prazoEntrega_'+indexTabela,
    size:'4', maxLength:'5', value: prazoEntrega, className:'fieldMin2', onchange:'seNaoIntReset($(\'prazoEntrega_'+indexTabela+'\'), 0);'})]),

    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'left'},
    [Builder.node('SELECT', {name:'tipoDiasEntrega_'+indexTabela,id:'tipoDiasEntrega_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'u'}, 'Dias Úteis'),
    Builder.node('OPTION', {value:'c'}, 'Dias Corridos'),
    Builder.node('OPTION', {value:'e'}, 'Dias Corridos c/ entrega em dia útil')
    ])
    ])
    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Aéreo:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('INPUT', {type:'text', name:'prazoEntregaAereo_'+indexTabela, id:'prazoEntregaAereo_'+indexTabela,
    size:'4', maxLength:'5', value: prazoEntregaAereo, className:'fieldMin2', onchange:'seNaoIntReset($(\'prazoEntregaAereo_'+indexTabela+'\'), 0);'})]),

    Builder.node('TD',{className:classe, colSpan:"1"},
    [Builder.node('DIV', {align:'left'},
    [Builder.node('SELECT', {name:'tipoDiasEntregaAereo_'+indexTabela,id:'tipoDiasEntregaAereo_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'u'}, 'Dias Úteis'),
    Builder.node('OPTION', {value:'c'}, 'Dias Corridos'),
    Builder.node('OPTION', {value:'e'}, 'Dias Corridos c/ entrega em dia útil')
    ])
    ])
    ]),
    Builder.node('TD',{className:classe, colSpan:"1"},
    [Builder.node('DIV', {align:'right'},
    [Builder.node('LABEL', {id:"labTipoTaxa_" + indexTabela}, 'Tipo Taxa:')])
    ]),
    Builder.node('TD',{className:classe, colSpan:"2"},
    [Builder.node('DIV', {align:'left'},
    [Builder.node('SELECT', {name:'tipoTaxa_'+indexTabela,id:'tipoTaxa_'+indexTabela, className:'fieldMin2'},
    [Builder.node('OPTION', {value:'-1'}, 'Selecione'),
    Builder.node('OPTION', {value:'0'}, 'Peso/Kg'),
    Builder.node('OPTION', {value:'1'}, 'Peso/Cubagem'),
    Builder.node('OPTION', {value:'2'}, '% Nota Fiscal'),
    Builder.node('OPTION', {value:'3'}, 'Combinado'),
    Builder.node('OPTION', {value:'4'}, 'Por Volume'),
    Builder.node('OPTION', {value:'5'}, 'Por Km'),
    Builder.node('OPTION', {value:'6'}, 'Por Pallet')
    ])
    ])
    ]),
     Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Data vigência:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('INPUT', {type:'text', name:'dataVigenciaLote_'+indexTabela, id:'dataVigenciaLote_'+indexTabela,
    size:'10', maxLength:'10', value: dataVigenciaLote, className:'fieldDateMin', onblur: "alertInvalidDate($('dataVigenciaLote_"+indexTabela+"'), true)"})
    ]),
    Builder.node('TD',{className:classe},
    [Builder.node('DIV', {align:'right'}, 'Validade:')]),
    Builder.node('TD',{className:classe},
    [Builder.node('INPUT', {type:'text', name:'validaAte_'+indexTabela, id:'validaAte_'+indexTabela,
    size:'10', maxLength:'10', value: validaAte, className:'fieldDateMin', onblur: "alertInvalidDate($('validaAte_"+indexTabela+"'), true)"})
    ])
    
    ]);
    $('tbG2'+indexTabela).appendChild(_tr);
    $('tbG2'+indexTabela).appendChild(_tr_1);
    $('tbG2'+indexTabela).appendChild(_tr_2);
    $('tbG2'+indexTabela).appendChild(_tr_3);
    $('tbG2'+indexTabela).appendChild(_tr_4);


    
    //atribuindo o valor das labels
    $('origem'+indexTabela).innerHTML=origem+'&nbsp;'; 
    $('origem'+indexTabela).style.fontSize ="9px";
    $('destino'+indexTabela).innerHTML=destino+'&nbsp;'; 
    $('destino'+indexTabela).style.fontSize ="9px";
    $('produto'+indexTabela).innerHTML=produto+'&nbsp;'; 
    $('produto'+indexTabela).style.fontSize ="9px";
    $('tipo'+indexTabela).value = tipo;
    $('ton'+indexTabela).value = ton;
    //aos selects'
    $('IncluiIcms_'+indexTabela).value = incluiIcms;
    $('IncluiPisCofins_'+indexTabela).value = incluirPisConfins;
    $('tipoDiasEntrega_'+indexTabela).value = tipoDiasEntrega;
    $('tipoDiasEntrega_'+indexTabela).style.width = "70px";
    $('tipoDiasEntregaAereo_'+indexTabela).value = tipoDiasEntregaAereo;
    $('tipoTaxa_'+indexTabela).value = tipoTaxa;
    $('tipoTaxa_'+indexTabela).style.display = (isUtilizaTipoTaxa ? "" : "none");
    $('labTipoTaxa_'+indexTabela).style.display = (isUtilizaTipoTaxa ? "" : "none");
    $('tipoDiasEntregaAereo_'+indexTabela).style.width = "70px";
    $('tipoTde_'+indexTabela).value = tipoTde;
    $('calculaSecCat_'+indexTabela).value = calculaSecCat;
    $('dataVigenciaLote_'+indexTabela).value = dataVigenciaLote;
    $('tipoPeso_'+indexTabela).value = tipoFretePeso;
    $('tipoImpressaoFreteMinimo_'+indexTabela).value = tipoImpressaoFreteMinimo;
    //aos checks
    $('desconsideraIcmsPisCofins_'+indexTabela).checked = desconsideraIcmsPisCofins;
    $('desconsideraGris_'+indexTabela).checked = desconsiderarGris;
    $('desconsideraDespacho_'+indexTabela).checked = desconsiderarDespacho;
    $('desconsideraOutros_'+indexTabela).checked = desconsiderarOutros;
    $('desconsideraPedagio_'+indexTabela).checked = desconsiderarPedagio;
    $('desconsideraSeguro_'+indexTabela).checked = desconsiderarSeguro;
    $('desconsideraSecCat_'+indexTabela).checked = desconsiderarSecCat;
    $('desconsideraTaxaFixa_'+indexTabela).checked = desconsiderarTaxa;
    
    $('chkConsiderarMaiorValor_'+indexTabela).checked = isConsiderarMaiorValor;
    $('chkConsiderarPeso_'+indexTabela).checked = isConsiderarMaiorPeso;
    $('chkFreteIdaVolta_'+indexTabela).checked = isFreteIdaVolta;
    
    readOnly($("valorCombinado_"+ indexTabela), "inputReadOnly8pt");
    if (!incluindo){
            $('tipo'+indexTabela).style.display = "none";
            $('idTabela'+indexTabela).innerHTML = idTabela;
            $('localizaOrigem_'+indexTabela).style.display = "none";
            $('localizaDestino_'+indexTabela).style.display = "none";
            $('localizaProduto_'+indexTabela).style.display = "none";
            $('limpaProduto_'+indexTabela).style.display = "none";
    }
    sltTipoPeso(indexTabela);
    
    $("formulaDespacho_"+indexTabela).value = formulaDespacho.replace(/"/g, "\"");
    $("formulaSeguro_"+indexTabela).value = formulaSeguro.replace(/"/g, "\"");
    $("formulaFretePeso_"+indexTabela).value = formulaFretePeso.replace(/"/g, "\"");
    $("formulaFreteMinimo_"+indexTabela).value = formulaFreteMinimo.replace(/"/g, "\"");
    $("formulaGris_"+indexTabela).value = formulaGris.replace(/"/g, "\"");
    $("formulaOutros_"+indexTabela).value = formulaOutros.replace(/"/g, "\"");
    $("formulaSecCat_"+indexTabela).value = formulaSecCat.replace(/"/g, "\"");
    $("formulaTaxaFixa_"+indexTabela).value = formulaTaxaFixa.replace(/"/g, "\"");
    $("formulaTDE_"+indexTabela).value = formulaTDE.replace(/"/g, "\"");
    $("formulaPedagio_"+indexTabela).value = formulaPedagio.replace(/"/g, "\"");
    $("valorPallets_"+indexTabela).value = valorPallets.replace(/"/g, "\"");
    
    isFormulaReadOnly("formulaSeguro_"+indexTabela);
    isFormulaReadOnly("formulaDespacho_"+indexTabela);
    isFormulaReadOnly("formulaFreteMinimo_"+indexTabela);
    isFormulaReadOnly("formulaGris_"+indexTabela);
    isFormulaReadOnly("formulaOutros_"+indexTabela);
    isFormulaReadOnly("formulaSecCat_"+indexTabela);
    isFormulaReadOnly("formulaTaxaFixa_"+indexTabela);
    isFormulaReadOnly("formulaTDE_"+indexTabela);
    isFormulaReadOnly("formulaPedagio_"+indexTabela);

    indexTabela++;
}

function limitarCampo(campo,label){
    var retorno = true;
    var vSplit = campo.value;
    var valorSplit = vSplit.split(".")[0];
    var valorDecimal = vSplit.split(".")[1];

    if (valorSplit < 0 || valorSplit > 9) {
        alert("O campo("+label+") precisa ser entre 0 a 9.99 ");
        campo.value = "0.00";
        retorno = false;
    } else
    if (valorSplit >= 0 || valorSplit <= 9) {
        if (valorDecimal.length > 2) {
            alert("A quantidade das casas decimais não podem ser maior que 2 ");
            campo.value = "0.00";
            retorno = false;
        }
    }
    return retorno;
}

function excluirTabela(incluindo, index){
	if (incluindo){
		if (confirm("Deseja mesmo apagar esta tabela da lista?")){
			Element.remove('tabela'+index);
		}
	}else{
		if (confirm("Deseja mesmo apagar esta tabela da lista?")){
			$('formTabela').action = "./cadtabela_preco_dinamica.jsp?acao=excluir&id="+$('idTabela'+index).innerHTML;
			submitPopupForm($('formTabela'));
		}
	}
}

function localizaOrigem(index){
	if ($('tipo'+index).value == 'c'){
		launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Origem_'+index);
	}else{
		launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Origem_'+index);
	}
}

function localizaDestino(index){
	if ($('tipo'+index).value == 'c'){
		launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_Destino_'+index);
	}else{
		launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Destino_'+index);
	}
}

function localizaOrigemFiltro(){
	if ($('tipoRotaF').value == 'c'){
		launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_de_Origem');
	}else{
		launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_de_Origem');
	}
}

function localizaDestinoFiltro(){
	if ($('tipoRotaF').value == 'c'){
		launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_de_Destino');
	}else{
		launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_de_Destino');
	}
}

function localizaTipoProduto(){
	launchPopupLocate('./localiza?acao=consultar&idlista=37','Tipos_Produto');	
}

function limparProduto(index){
	$('idProduto'+index).value = '0';
    $('produto'+index).innerHTML = '';
}

function alteraTipoRota(index){
	$('idOrigem'+index).value = '0';
	$('origem'+index).innerHTML = '';
	$('idDestino'+index).value = '0';
	$('destino'+index).innerHTML = '';        
        var tipo = $('tipo'+index).value;
              
        if (tipo == 'c') {
            
            $('tipo'+index).disabled = true;
            } else if (tipo == 'a') {  
                
            $('tipo'+index).disabled = false;
            } else {
                
            $('tipo'+index).disabled = false;     
            } 
}

function alteraTabela(id){
    javascript:tryRequestToServer(function(){
        window.open("./cadtabela_preco.jsp?acao=editar&id="+id+"&ex=false", "Tabela" , "top=0,resizable=yes,status=1,scrollbars=1");});

}

function adicionarTabela(index){
        addTabela(  0, //0
                    true, //1
                    false, //2
                    true, //3
                    'c', //4
                    0,  //5
                    '', //6
                    0,  //7
                    '', //8
                    0,  //9
                    '',  //10
                    0, //11
                    'N', //12
                    0, //13
                    0, //14
                    0, //15
                    0, //16
                    0, //17
                    0, //18
                    0, //19
                    0, //20
                    0, //21
                    0, //22
                    0, //23
                    0, //24
                    'N' //25
//                    'N', //26
//                    0, //27
//                    0, //28
//                    0, //29
//                    0,//30
//                    'v', //31
//                    0, //32
//                    0, //33
//                    'c', //34
//                    'c', //35
//                    '', //36
//                    0, //37
//                    0, //38
//                    0, //39
//                    ($("desconsideraIcmsPisCofins_0").checked), //40        
//                    false, //41
//                    false, //42 
//                    false, //43
//                    false, //44        
//                    false, //45
//                    false, //46
//                    false, //47
//                    '', //48
//                    '', //49
//                    '', //50
//                    '', //51
//                    '', //52
//                    '', //53
//                    '', //54        
//                    'p', //55        
//                    'v', //56
//                    '', //57
//                    '', //58
//                    '', //59
//                    't', //60 
//                    0, //61
//                    0, //62        
//                    0, //63
//                    0, //64
//                    0, //65        
//                    0, //66        
//                    0, //67        
//                    0, //68
//                    0, //69
//                    ($("utilizaTipoFreteTabelaRem").value == "t") //70        
//                    ($("chkConsiderarMaiorValor_0").checked), //71        
//                    ($("chkConsiderarPeso_0").checked) //72       
                     );
}
</script>
<%@page import="cliente.faixaPeso.FaixaPeso"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Cadastro de tabela de preços</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onload="applyFormatter();tipoConsulta();">
<img src="img/banner.gif" >
<br>
<input type="hidden" name="idremetente" id="idremetente" value="">
<input type="hidden" name="rem_rzs" id="rem_rzs" value="">
<input type="hidden" name="rem_cnpj" id="rem_cnpj" value="">
<input type="hidden" name="remetenteId" id="remetenteId" value="<%=(request.getParameter("remetenteId") != null ? request.getParameter("remetenteId") : 0)%>">
<input type="hidden" id="rem_tipotaxa" name="rem_tipotaxa" value="">
<input type="hidden" id="tipotaxaRem" name="tipotaxaRem" value="<%=(request.getParameter("tipotaxaRem") != null ? request.getParameter("tipotaxaRem") : null)%>">
<input type="hidden" name="utilizaTipoFreteTabelaRem" id="utilizaTipoFreteTabelaRem" value="<%=(request.getParameter("utilizaTipoFreteTabelaRem") != null ? request.getParameter("utilizaTipoFreteTabelaRem") : 'f')%>">
<input type="hidden" name="utilizaTipoFreteTabelaCliCop" id="utilizaTipoFreteTabelaCliCop" value="">
<input type="hidden" name="is_utilizar_tipo_frete_tabela" id="is_utilizar_tipo_frete_tabela" value="">
<input type="hidden" id="grupo_id" name="grupo_id" value="<%=(request.getParameter("grupo_id") != null ? request.getParameter("grupo_id") : 0)%>">
<input type="hidden" name="cli_cop_id" id="cli_cop_id" value="0">
<input type="hidden" name="tipo_produto_id" id="tipo_produto_id" value="">
<input name="tipo_produto" type="hidden" id="tipo_produto" value="">
<input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="">
<input type="hidden" name="idcidadeorigem_loc" id="idcidadeorigem_loc" value="<%=(request.getParameter("idcidadeorigem_loc") != null ? request.getParameter("idcidadeorigem_loc") : 0)%>">
<input type="hidden" name="idcidadedestino_loc" id="idcidadedestino_loc" value="<%=(request.getParameter("idcidadedestino_loc") != null ? request.getParameter("idcidadedestino_loc") : 0)%>">
<input type="hidden" name="tipo_produto_id_loc" id="tipo_produto_id_loc" value="<%=(request.getParameter("tipo_produto_id_loc") != null ? request.getParameter("tipo_produto_id_loc") : 0)%>">
<input name="cid_origem" type="hidden" id="cid_origem" value="">
<input name="uf_origem" type="hidden" id="uf_origem" value="">
<input type="hidden" name="idcidadedestino" id="idcidadedestino" value="">
<input name="cid_destino" type="hidden" id="cid_destino" value="">
<input name="uf_destino" type="hidden" id="uf_destino" value="">
<input type="hidden" name="area_id" id="area_id" value="0">
<input type="hidden" name="sigla_area" id="sigla_area" value="0">
<input type="hidden" name="idareaorigem" id="idareaorigem" value="">
<input type="hidden" name="idareadestino" id="idareadestino" value="">
<input type="hidden" name="idareaorigem_loc" id="idareaorigem_loc" value="<%=(request.getParameter("idareaorigem_loc") != null ? request.getParameter("idareaorigem_loc") : 0)%>">
<input type="hidden" name="idareadestino_loc" id="idareadestino_loc" value="<%=(request.getParameter("idareadestino_loc") != null ? request.getParameter("idareadestino_loc") : 0)%>">
<input type="hidden" name="idcidadeorig" id="idcidadeorig" value="">
<input type="hidden" name="idcidadedest" id="idcidadedest" value="">
<input type="hidden" name="tp_prod_id" id="tp_prod_id" value="">
<input type="hidden" name="idareaorig" id="idareaorig" value="">
<input type="hidden" name="idareadest" id="idareadest" value="">



<table width="95%" align="center" class="bordaFina" >
  <tr >
    <td height="22">
      <div align="left"><b>Cadastro de tabela de pre&ccedil;os para v&aacute;rias cidades ao mesmo tempo </b></div>    </td>
    <td width="6">&nbsp;</td>
    <td width="66"><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para a telade consulta" onClick="javascript:voltar();"></td>
  </tr>
</table>
<br>
<form method="post" id="formTabela" target="pop2">
<input type="hidden" name="maxTVeiculo" id="maxTVeiculo" value="">
<table width="95%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
  <tr class="tabela">
    <td height="20" colspan="8" align="center">Dados principais </td>
  </tr>
  
 <tr>
     <td colspan="4">
         <table width="100%">
             <tbody>
                <tr>
                <%if(acao.equals("") || acao.equals("visualizar")){%>
                <td class="TextoCampos" width="10%" >Selecionar Por:</td>
                <td class="CelulaZebra2" width="10%">
                    <select style="width: 80px" id="tipoPesq" name="tipoPesq" class="inputtexto" onchange="tipoConsulta(this.value)">
                    <option value="cliente" <%=(request.getParameter("tipoPesq") == null || request.getParameter("tipoPesq").equals("cliente")?"selected":"")%>>Cliente</option>
                    <option value="grupo" <%=(request.getParameter("tipoPesq") != null && request.getParameter("tipoPesq").equals("grupo")?"selected":"")%>>Grupo do Cliente</option>
                    </select>
                </td>
                <%}%>
                <td class="TextoCampos" id="tdCliente_1" width="6%" >Cliente:</td>
                <td  class="CelulaZebra2" id="tdCliente_2" ><input name="remetente_rzs" type="text" id="remetente_rzs" style="font-size:8pt;" value="<%=(request.getParameter("remetente_rzs") != null ? request.getParameter("remetente_rzs") : "Tabela Principal")%>"  size="25" readonly class="inputReadOnly8pt">
                    <span class="Celulazebra2"><strong>
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=3','Remetente')">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('remetente_rzs').value = 'Tabela Principal';javascript:getObj('remetenteId').value = '0';javascript:getObj('remetente_cnpj').value = '';javascript:getObj('utilizaTipoFreteTabelaRem').value = 'f';"></strong></span>
                    <%if(acao.equals("iniciar")){%>
                    <input type="checkbox" name="isCopTabCliente" id="isCopTabCliente" title="Possibilita copiar tabelas de outros clientes." onclick="verCopTabCliente();">
                    Copiar tabela(s) de outro cliente
                    <%}%>
                </td>

                <td class="TextoCampos" id="tdCliente_3" width="5%">CNPJ:</td>
                <td class="CelulaZebra2" id="tdCliente_4" colspan="12" style="fixed"><input name="remetente_cnpj" type="text" id="remetente_cnpj" size="18" readonly="true" value="<%=(request.getParameter("remetente_cnpj") != null ? request.getParameter("remetente_cnpj") : "")%>" class="inputReadOnly"> </td>
                <%if(acao.equals("") || acao.equals("visualizar")){%>
                <td class="TextoCampos" id="tdGrupo_1" width="12%" >Grupo:</td>
                <td class="CelulaZebra2" id="tdGrupo_2" ><input name="grupo" type="text" id="grupo" size="30" readonly class="inputReadOnly" value="<%=(request.getParameter("grupo") != null ? request.getParameter("grupo") : "")%>">
                    <strong>
                    <input name="localiza_grupo" type="button" class="botoes" id="localiza_grupo" value="..."
                    onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo')">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('grupo').value='';getObj('grupo_id').value=0;">
                    </strong>
                </td>
                
                <td class="TextoCampos">Tipo Produto:</td>
                <td class="CelulaZebra2" ><input name="tipo_produto_loc" type="text" id="tipo_produto_loc" style="font-size:8pt;" value="<%=(request.getParameter("tipo_produto_loc") != null ? request.getParameter("tipo_produto_loc") : "")%>"  size="15" readonly class="inputReadOnly8pt">
                    <span class="Celulazebra2" ><strong>
                    <input name="localiza_tipo_produto" type="button" class="botoes" id="localiza_tipo_produto" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=37','Tipo_Produto')">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Tipo Prodtuo" onClick="javascript:getObj('tipo_produto_loc').value = '';javascript:getObj('idTipoProduto').value = '0';"></strong></span>
                </td>
                <%}%>
                </tr>
                <%if(acao.equals("iniciar")){%>
                <tr id="trCopTabCliente" style="display: none">
                <td class="TextoCampos" id="tdCliente_1" width="6%" >Escolha o cliente:</td>
                <td class="CelulaZebra2" id="tdCliente_2" ><input name="cli_cop_rzs" type="text" id="cli_cop_rzs" style="font-size:8pt;" value="<%=(request.getParameter("cli_cop_rzs") != null ? request.getParameter("cli_cop_rzs") : "Tabela Principal")%>"  size="25" readonly class="inputReadOnly8pt">
                    <span class="Celulazebra2"><strong>
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=3','Cliente')">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('cli_cop_rzs').value = 'Tabela Principal';javascript:getObj('cli_cop_id').value = '0';"></strong></span>
                    <input name="copiarTabela" type="button" class="botoes" id="copiarTabela" value="Copiar Tabela do Cliente" onclick="AjaxCarregaTabela();" >
                </td>
                <td class="TextoCampos" id="tdCliente_11">Rota:</td>
                <td class="CelulaZebra2" id="tdCliente_12">
                    <select id="tipoRotaF" class="inputTexto">
                        <option value="a">Área</option>
                        <option value="c">Cidade</option></select>
                   </td>
                <td class="TextoCampos" id="tdCliente_5" >Origem:</td>
                <td class="CelulaZebra2" id="tdCliente_6" width="10%" >
                    <input name="origem" type="text" id="origem" style="font-size:8pt;" value="<%=(request.getParameter("cid_orig") != null ? request.getParameter("origem") : "")%>"  size="10" readonly class="inputReadOnly8pt">
                    <span class="Celulazebra2"><strong>
                    <input name="localiza_origem" type="button" class="botoes" id="localiza_origem" value="..." onClick='javascript:tryRequestToServer(function(){localizaOrigemFiltro();})'>
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar origem" onClick="javascript:getObj('origem').value = '';getObj('idcidadeorig').value = '0';getObj('idareaorig').value = '0';"></strong></span>
                </td>
                <td class="TextoCampos" id="tdCliente_7"  >Destino:</td>
                <td class="CelulaZebra2" id="tdCliente_8" width="10%" >
                    <input name="destino" type="text" id="destino" style="font-size:8pt;" value="<%=(request.getParameter("cid_dest") != null ? request.getParameter("destino") : "")%>"  size="10" readonly class="inputReadOnly8pt">
                    <span class="Celulazebra2"><strong>
                    <input name="localiza_dest" type="button" class="botoes" id="localiza_dest" value="..." onclick='javascript:tryRequestToServer(function(){localizaDestinoFiltro();})'>
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar destino" onClick="javascript:getObj('destino').value = '';getObj('idcidadedest').value = '0';getObj('idareadest').value = '0';"></strong></span>
                </td>
                <td class="TextoCampos" id="tdCliente_9" >Tipo Produto:</td>
                <td class="CelulaZebra2" id="tdCliente_10" width="10%" ><input name="tp_prod" type="text" id="tp_prod" style="font-size:8pt;" value="<%=(request.getParameter("tp_prod") != null ? request.getParameter("tp_prod") : "")%>"  size="10" readonly class="inputReadOnly8pt">
                    <span class="Celulazebra2"><strong>
                    <input name="localiza_tpproduto" type="button" class="botoes" id="localiza_tpproduto" value="..." onclick='javascript:tryRequestToServer(function(){localizaTipoProduto();})'>
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar produto" onClick="javascript:getObj('tp_prod').value = '';javascript:getObj('tp_prod_id').value = '0';"></strong></span>
                </td>
                <%}%>
                </tr>
             </tbody>
         </table>
     </td>
  </tr>
  <% if (acao.equals("") || acao.equals("visualizar")){%>
  <tr>
      <td class="CelulaZebra2" width="25%">
        <input name="cid_origem_loc" type="text" id="cid_origem_loc" class="inputReadOnly8pt" size="23" maxlength="80" readonly="true" value="<%=(request.getParameter("cid_origem_loc")==null ?"Todas as cidade de origem":request.getParameter("cid_origem_loc"))%>">
        <input name="uf_origem_loc" type="text" id="uf_origem_loc" class="inputReadOnly8pt" size="2" maxlength="80" readonly="true" value="<%=(request.getParameter("uf_origem_loc")==null?"":request.getParameter("uf_origem_loc"))%>">
      <span class="Celulazebra2"><strong>
      <input name="localiza_cid_origem" type="button" class="botoes" id="localiza_cid_origem" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=11','Cidade_Origem')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('uf_origem_loc').value='';$('cid_origem_loc').value='Todas as cidade de origem';$('idcidadeorigem_loc').value=0;"></strong></span>
     </td>
     
     <td class="CelulaZebra2" width="25%">
        <input name="cid_destino_loc" type="text" id="cid_destino_loc" class="inputReadOnly8pt" size="23" maxlength="80" readonly="true" value="<%=(request.getParameter("cid_destino_loc")==null?"Todas as cidade de destino":request.getParameter("cid_destino_loc"))%>">
        <input name="uf_destino_loc" type="text" id="uf_destino_loc" class="inputReadOnly8pt" size="2" maxlength="80" readonly="true" value="<%=(request.getParameter("uf_destino_loc")==null?"":request.getParameter("uf_destino_loc"))%>">
      <span class="Celulazebra2"><strong>
      <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=12','Cidade_Destino')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade" onClick="javascript:$('uf_destino_loc').value='';$('cid_destino_loc').value='Todas as cidade de destino';$('idcidadedestino_loc').value=0;"></strong></span>
     </td>
     
     <td class="CelulaZebra2" width="25%"><input name="area_ori_loc" type="text" id="area_ori_loc" size="25" maxlength="80" readonly="true" value="<%=(request.getParameter("area_ori_loc")==null?"Todas as areas de origem":request.getParameter("area_ori_loc"))%>" class="inputReadOnly8pt">
      <span class="Celulazebra2"><strong>
      <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Origem')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade Origem" onClick="javascript:$('area_ori_loc').value='Todas as areas de origem';$('idareaorigem_loc').value=0;"></strong></span>
     </td>
    
     <td class="CelulaZebra2" width="25%"><input name="area_des_loc" type="text" id="area_des_loc" class="inputReadOnly8pt" size="25" maxlength="80" readonly="true" value="<%=(request.getParameter("area_des_loc")==null?"Todas as areas de destino":request.getParameter("area_des_loc"))%>">
      <span class="Celulazebra2"><strong>
      <input name="localiza_area" type="button" class="botoes" id="localiza_area" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=34','Area_Destino')">
      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cidade Destino" onClick="javascript:$('area_des_loc').value='Todas as areas de destino';$('idareadestino_loc').value=0;"></strong></span>
     </td>
  </tr>
<tr>
    <td colspan="4" class="CelulaZebra2">
        <div align="center">
          <input name="visualiza" type="button" class="botoes" id="visualiza" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
        </div>
    </td>
</tr>
<%}%>  
  <tr>
    <td colspan="4">
        <table width="100%" border="0" id="tabelaP" class="bordaFina">
				<tr class="tabela">
                                    <td align="right" >Reajustar:</td>
                                    <td align="right" colspan="13"><div align="left" >
                                            <select id="campoReajuste" name="campoReajuste" class="inputTexto" onchange="isTipoReajuste()">
                                            <option value="valorPeso">Peso/Kg</option>
                                            <option value="baseCub">Peso/Cubagem</option>
                                            <option value="valorPesoFaixa_Terrestre">Peso Faixa/Terrestre</option>
                                            <option value="valor_excedente">Excedente/Terrestre</option>
                                            <option value="valorPesoFaixa_Aereo">Peso Faixa/Aereo</option>
                                            <option value="valor_excedente_aereo">Excedente/Aereo</option>
                                            <option value="valorVolume">Volume</option>
                                            <option value="basePercentual">Base % NF</option>
                                            <option value="valorPercentual">Valor % NF</option>
                                            <option value="valorCombinado">Valor Combinado</option>
                                            <option value="valorSeguro">AdValorEm</option>
                                            <option value="valorGris">GRIS</option>
                                            <option value="valorDespacho">Despacho</option>
                                            <option value="valorOutros">Outros</option>
                                            <option value="valorTaxa">Taxa Fixa</option>
                                            <option value="valorExcedenteTaxaFixa">Taxa Fixa Excedente</option>
                                            <option value="freteMinimo">Frete Mínimo</option>
                                            <option value="valorMinimoGris">Mínimo Gris</option>
                                            <option value="valorSecCat">SEC/CAT</option>
                                            <option value="valorExcedenteSecCat">SEC/CAT Excedente</option>
                                            <option value="valorTde">TDE</option>
                                            <option value="valorPedagio">Pedágio</option>
                                            <option value="qtdQuiloPedagio">Qtd. Quilo Pedágio</option>
                                            <option value="percentualDevolucao">% Devolução</option>
                                            <option value="percentualReentrega">% Reentrega</option>
                                            <option value="validaAte">Validade</option>
                                            <%if ("t".equals(request.getParameter("utilizaTipoFreteTabelaRem")) ){%>
                                            <option value="tipoTaxaCliente">Tipo Taxa Cliente</option>                                         
                                            <%}%>
                                        </select> 
                                            <input type="text" name="valorReajuste" id="valorReajuste" size="10" maxlength="10" value="0.00" onchange="seNaoFloatReset(this, '0.00')" class="inputTexto">
                                            <input id="validaAte" class="fieldDateMin" type="text" onblur="alertInvalidDate($('validaAte'), true)" value="" maxlength="10" size="10" name="validaAte" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" style='display: none'>
                                        <select id="tipoReajuste" name="tipoReajuste" class="inputTexto">
                                            <option value="real">R$</option>
                                            <option value="percentual">%</option>
                                        </select>
                                        <select id="tipoTxCliente" name="tipoTxCliente" class="inputTexto" style="display : none">
                                            <option value="-1">Selecione</option>
                                            <option value="0">Peso/Kg</option>
                                            <option value="1">Peso/Cubagem</option>
                                            <option value="2">% Nota Fiscal</option>
                                            <option value="3">Combinado</option>
                                            <option value="4">Por Volume</option>
                                            <option value="5">Por Km</option>
                                            <option value="6">Por Pallet</option>
                                        </select>
                                        <input type="button" name="btnAplicar" class="botoes" id="btnAplicar" onclick="aplicarReajuste()" value="Aplicar" >
                                        </div>
                                    </td>
                                </tr>
				<tr class="tabela">
					<td>
                                           <%if (!acao.equals("") && !acao.equals("visualizar")){%>
						<span class="CelulaZebra2">
                                                    <img src="img/add.gif" border="0" class="imagemLink "
                                                    title="Adicionar uma nova tabela de preço" 
                                                    onClick="javascript:adicionarTabela();">
						</span>
                                           <%}%>
                                        </td>
					<td colspan="2">&nbsp;</td>
					<td>
                                            <div align="right">
                                                <span style="font-size:11px">Tipos de fretes :</span>
                                            </div>
                                        </td>
					<td colspan="4">
                                            <div align="center">
                                                <span style="font-size:11px">Peso/Cubagem</span>
                                            </div>
                                        </td>
					<td>
                                            <div align="center">
                                                <span style="font-size:11px">Volume</span>
                                            </div>
                                        </td>
                                        <td colspan="3">
                                            <div align="center">
                                                <span style="font-size:11px">% Nota Fiscal</span>
                                            </div>
                                        </td>
                                        <td>
                                            <div align="center">
                                                <span style="font-size:11px">Combin.</span>
                                            </div>
                                        </td>
                                         <td>&nbsp;</td>
                                </tr>
                                <tr class="tabela">
                                        <td width="7%"><span style="font-size:11px"><%=(acao.equals("") || acao.equals("visualizar") ? "Cód." : "Tipo rota")%> </span></td>
                                        <td width="16%"><span style="font-size:11px">Origem</span></td>
                                        <td width="16%"><span style="font-size:11px">Destino</span></td>
                                        <td width="13%"><span style="font-size:11px">Tipo produto</span></td>
                                        <td width="6%"><span style="font-size:11px">Tp.Peso</span></td>
                                        <td width="5%"><span style="font-size:11px">Pr.peso</span></td>
                                        <td width="5%"><span style="font-size:11px">Ton.</span></td>
                                        <td width="5%"><span style="font-size:11px">Cub.</span></td>
                                        <td width="5%"><span style="font-size:11px">Valor</span></td>
                                        <td width="6%"><span style="font-size:11px">%</span></td>
                                        <td width="4%"><span style="font-size:11px">Base</span></td>
                                        <td width="5%"><span style="font-size:11px">Valor</span></td>
                                        <td width="5%"><span style="font-size:11px">Valor</span></td>
                                        <td width="2%"><span style="font-size:11px"></span></td>
                                </tr>
                 </table>
            </td>
    </tr>
  
<%
  if (!acao.equals("iniciar")){%><%}%>
  <tr class="CelulaZebra2">
        <td height="24" colspan="4"><center>
            <% if (nivelUser >= 2){%>
            <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
            <%}%>
        </center></td>
  </tr>
    <tr>
      <td>
          <tbody id="tbodyTipoVeiculo" style="display: none" name="tbodyTipoVeiculo"></tbody>                
      </td>
    </tr>
</table>
</form>
</body>
<script>
    var linha = 0;
    var listaTFL= null;
    var listaAe = null;

	<%if (acao.equals("visualizar")){
                iListaTabela = listaTabela.iterator();
		while(iListaTabela.hasNext()){
                tab = (BeanTabelaCliente) iListaTabela.next();%>
                    
			  addTabela(<%=tab.getId()%>,//0
                                    false,//1
                                    false, //2
                                    false,//3
                                    '<%=tab.getTipoRota()%>',//4
                                    <%=tab.getCidadeOrigem().getIdcidade()%>,//5 
                                    '<%=tab.getCidadeOrigem().getCidade()%>',//6
                                    <%=tab.getCidadeDestino().getIdcidade()%>, //7
                                    '<%=tab.getCidadeDestino().getCidade()%>',//8
                                    <%=tab.getTipoProduto().getId()%>,//9
                                    '<%=tab.getTipoProduto().getDescricao()%>',//10 
                                    <%=tab.getValorPeso()%>,//11
                                    '<%=(tab.isPrecoTonelada()?'S':'N')%>',//12
                                    <%=tab.getBaseCubagem()%>,//13
                                    <%=tab.getValorVolume()%>, //14
                                    <%=tab.getPercentualNf()%>,//15
                                    <%=tab.getBaseNfPercentual()%>,//16 
                                    <%=tab.getValorPercentualNf()%>,//17
                                    <%=tab.getValorCombinado()%>, //18
                                    <%=tab.getPercentualGris()%>,//19
                                    <%=tab.getPercentualAdValorEm()%>, //20
                                    <%=tab.getValorTaxaFixa()%>,//21
                                    <%=tab.getValorOutros()%>, //22
                                    <%=tab.getValorDespacho()%>,//23
                                    <%=tab.getValorFreteMinimo()%>, //24
                                    '<%=(tab.isIncluiIcms()?'S':'N')%>',//25
                                    '<%=(tab.isIncluirFederais()?'S':'N')%>',//26 
                                    <%=tab.getValorPedagio()%>,//27
                                    <%=tab.getQtdQuiloPedagio()%>,//28
                                    <%=tab.getValorMinimoGris()%>,//29
                                    <%=tab.getValorDificuldadeEntrega()%>,//30
                                    '<%=tab.getTipoTde()%>',//31
                                    <%=tab.getPrazoEntrega()%>,//32
                                    <%=tab.getPrazoEntregaAereo()%>,//33
                                   '<%=tab.getTipoDiasEntrega()%>',//34
                                   '<%=tab.getTipoDiasEntregaAereo()%>',//35
                                   '<%=(tab.getValidaAte()==null?null:fmt.format(tab.getValidaAte()))%>',//36
                                    <%=tab.getPercentualReentrega()%>,//37
                                    <%=tab.getPercentualDevolucao()%>,//38
                                    <%=tab.getValorSecCat()%>,//39
                                    <%=tab.isDesconsideraIcmsMinimo()%>,//40
                                    <%=tab.isDesconsideraGrisMinimo()%>,//41
                                    <%=tab.isDesconsideraPedagioMinimo()%>,//42
                                    <%=tab.isDesconsideraSeguroMinimo()%>,//43
                                    <%=tab.isDesconsideraDespachoMinimo()%>,//44
                                    <%=tab.isDesconsideraOutrosMinimo()%>,//45
                                    <%=tab.isDesconsideraTaxaMinimo()%>,//46
                                    <%=tab.isDesconsideraSeccatMinimo()%>,//47
                                    '<%=tab.getFormulaGris()%>',//48
                                    '<%=tab.getFormulaSeguro()%>',//49
                                    '<%=tab.getFormulaDespacho()%>',//50
                                    '<%=tab.getFormulaOutros()%>',//51
                                    '<%=tab.getFormulaTaxaFixa()%>',//52
                                    '<%=tab.getFormulaSecCat()%>',//53
                                    '<%=tab.getFormulaMinimo()%>',//54
                                    '<%=tab.getTipoFretePeso()%>',//55
                                    '<%=tab.getTipoImpressaoFreteMinimo()%>',//56
                                    '<%=tab.getFormulaTDE()%>',//57
                                    '<%=tab.getFormulaPedagio()%>',//58 
                                    '<%=tab.getFormulaFretePeso()%>',//59
                                    '<%=tab.getTipoInclusaoIcms()%>',//60
                                    '<%=tab.getPesoLimiteSecCat()%>',//61
                                    '<%=tab.getValorExcedenteSecCat()%>',//62
                                    '<%=tab.getValorExcedente()%>',//63
                                    '<%=tab.getValorExcedenteAereo()%>',//64
                                    '<%=tab.getPesoLimiteTaxaFixa()%>',//65
                                    '<%=tab.getValorExcedenteTaxaFixa()%>',//66
                                    '<%=tab.getTaxaApartirEntrega()%>',//67
                                    '<%=tab.getValorPallet()%>',//68
                                    <%=tab.getTipoTaxa()%>, //69
                                    ($("utilizaTipoFreteTabelaRem").value == "t"),//70
                                    '<%=tab.isConsiderarValorMaiorPesoNota()%>',//71
                                    '<%=tab.isConsiderarMaiorPeso()%>',//72
                                    '<%=tab.isFreteIdaVolta()%>',//73
                                    '<%=tab.getCalculaSecCat()%>',//74
                                    '<%=(tab.getDataVigencia()==null?null:fmt.format(tab.getDataVigencia()))%>'//75
                                    );
                      //carregando a faixa de peso terreestre
                      linha = 0;
                      <%for (int u = 0; u < tab.getFaixasPeso().length; ++u) {

                            FaixaPeso fxpr = tab.getFaixasPeso()[u];%>
                              listaTFL = new TabelaPeso();
                              listaTFL.id = '<%=fxpr.getId()%>';
                              listaTFL.pesoInicial = '<%=fxpr.getPesoInicial()%>';
                              listaTFL.pesoFinal = '<%=fxpr.getPesoFinal()%>';
                              listaTFL.valor = '<%=fxpr.getValorFaixa()%>';
                              listaTFL.tipoValor = '<%=fxpr.getTipoValor()%>';
                          addListaTipoTFM(listaTFL, linha, false);
                          linha++;
                      <%}%>
                      //carregando a faixa de peso aerea
                      linha = 0;
                      <%for (int u = 0; u < tab.getFaixasPesoAereo().length; ++u) {

                            FaixaPeso fxpa = tab.getFaixasPesoAereo()[u];%>
                              listaAe = new TabelaPeso();
                              listaAe.id = '<%=fxpa.getId()%>';
                              listaAe.pesoInicial = '<%=fxpa.getPesoInicial()%>';
                              listaAe.pesoFinal = '<%=fxpa.getPesoFinal()%>';
                              listaAe.valor = '<%=fxpa.getValorFaixa()%>';
                              listaAe.tipoValor = '<%=fxpa.getTipoValor()%>';
                              addListaTipoAereo(listaAe, linha, false);
                          linha++;
                      <%}%>

		<%}
	}%>



</script>

