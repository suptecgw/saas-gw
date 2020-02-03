<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="java.sql.ResultSet,
           java.text.*,
           despesa.especie.Especie,
           conhecimento.manifesto.*,
           despesa.apropriacao.BeanApropDespesa,
           mov_banco.conta.*,
           mov_banco.banco.*,
           despesa.duplicata.*,
           despesa.BeanDespesa,
           fpag.*,
           nucleo.*,
           rota.*,
           mov_banco.talaocheque.ConsultaTalaoCheque,
           mov_banco.talaocheque.TalaoCheque,
           java.util.Collection,
           java.util.ArrayList,
           java.util.Date,
           rota.tipoVeiculo.TipoVeiculoRota,
           tipo_veiculos.Tipo_veiculos,
           conhecimento.cartafrete.*" errorPage="" %>

<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<%
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
  // privilégio de permissao. Ex.: if (nivelUser == 4) <usuario pode excluir
  int nivelUser = Apoio.getUsuario(request).getAcesso("lancartafrete");
  int nivelUserBaixarDespesa = Apoio.getUsuario(request).getAcesso("bxpagarviagem");
  int nivelAlterarFrete = Apoio.getUsuario(request).getAcesso("alttabprecolanccontrfrete");
  int cartaFl = Apoio.getUsuario(request).getAcesso("lancartafl");
  int nivelImpostos = Apoio.getUsuario(request).getAcesso("alteraimpostoscartafrete");
  int nivelCiot = Apoio.getUsuario(request).getAcesso("alteraciot");
  int nivelManifesto = Apoio.getUsuario(request).getAcesso("cadmanifesto");
  int nivelColeta = Apoio.getUsuario(request).getAcesso("cadcoleta");
  int nivelRomaneio = Apoio.getUsuario(request).getAcesso("cadromaneio");
  int nivelUserDespesa = Apoio.getUsuario(request).getAcesso("caddespesa");
  int nivelAlteraValor = Apoio.getUsuario(request).getAcesso("modificavalorcontrato");
  int nivelVeiculoProprio = Apoio.getUsuario(request).getAcesso("visualizarpropriocartafrete");
  int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
           ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
  int nivelUserAdiantamento = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("alterapercadiant") : 0);
  //testando se a sessao é válida e se o usuário tem acesso
  if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA
   boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
   int idUsuario = Apoio.getUsuario(request).getIdusuario();
  //ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregacarta = false;
  BeanCartaFrete       carta = null;
  BeanConsultaFPag fpag = null;
  BeanConsultaConta cta = null;
  TipoVeiculoRota tipoVeiculoRota = null;
  BeanConsultaBanco bancoAd = null;
  BeanConsultaCartaFrete mostracarta = null;
  ConsultaRota mostrarota = null;
  BeanConfiguracao cfg = null;
  float pesoTotalRota = 0;
  double percAdiantamentoMotorista = 0;
  ConsultaTalaoCheque tc = null;

  BeanCadCartaFrete cadcarta = new BeanCadCartaFrete();
  cadcarta.setConexao(Apoio.getUsuario(request).getConexao());
  
  // Instanciando o Bean de Forma de pagamento
  fpag = new BeanConsultaFPag();
  
  fpag.setConexao(Apoio.getUsuario(request).getConexao());
  
  //Instanciando o Bean conta
  cta = new BeanConsultaConta();
  cta.setConexao(Apoio.getUsuario(request).getConexao());

  //Instanciando o Bean de banco
  bancoAd = new BeanConsultaBanco();
  bancoAd.setConexao(Apoio.getUsuario(request).getConexao());
  //instanciando um formatador de simbolos
  DecimalFormatSymbols dfs = new DecimalFormatSymbols();
  dfs.setDecimalSeparator('.');
  DecimalFormat vlrformat = new DecimalFormat("0.00",dfs);
  vlrformat.setDecimalSeparatorAlwaysShown(true);
  double valorAdiantamentoCarreteiro = 0;
  double valorSaldoCarreteiro = 0;
  
  //Variáveis que servirão para armazenar os valores do loop dos manifestos
  int linha = 0;
  //Variável que receberá o valor do teto para calculo do INSS
  float tetoInss = 0;  
  //Variável que irá informar se será calculado os impostos ou não, caso o proprietario do cavalo
  //seja pessoa física ou jurídica
  boolean calculaimpostos = true;
  boolean podeExcluirOutraFl = true;
  boolean podeAlterarOutraFl = true;
  //Instaciando variável para formatação de datas
  SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
  String hora = new SimpleDateFormat("HH:mm").format(new Date());
  
  //Carregando as configuraões independente da ação
  cfg = new BeanConfiguracao();
  cfg.setConexao(Apoio.getUsuario(request).getConexao());
  //Carregando as configurações
  cfg.CarregaConfig();

  double pesoTotal = 0;
  double freteTotal = 0;
  
  //instrucoes em comum entre as acoes
  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("carrega") || acao.equals("excluibaixa"))
  {    //instanciando o bean de cadastro 3 
    cadcarta.setExecutor(Apoio.getUsuario(request));
    mostracarta = new BeanConsultaCartaFrete();
    mostracarta.setConexao(Apoio.getUsuario(request).getConexao());
    tetoInss = cfg.getTetoInss();
    //executando a acao desejada
    //ao solicitar alteração o bean será carregado com todos os dados do id atual
    if ((acao.equals("editar")) && (request.getParameter("idcartafrete") != null || request.getParameter("id") != null))
    {
      int idcartafrete = Integer.parseInt(request.getParameter("idcartafrete") == null ? request.getParameter("id") : request.getParameter("idcartafrete"));
      cadcarta.getCFrete().setIdcartafrete(idcartafrete);
      //carregando o conhecimento por completo
      cadcarta.LoadAllPropertys();
      carta = cadcarta.getCFrete();
      calculaimpostos = false; //essa linha servirá para informar que não será calculado os impostos na alteração e sim na inclusão
      //Verificando se o usuário poderá excluir a caratafrete lançada por outra filial
      podeExcluirOutraFl = !((carta.getFilial().getIdfilial() != Apoio.getUsuario(request).getFilial().getIdfilial()) && (cartaFl <= 3));
      //Verificando se o usuário poderá alterar a caratafrete lançada por outra filial
      podeAlterarOutraFl = !((carta.getFilial().getIdfilial() != Apoio.getUsuario(request).getFilial().getIdfilial()) && (cartaFl <= 1));
      percAdiantamentoMotorista = carta.getPercentualAdiantamento();
    }
    else
      //ao clicar no salvar dessa tela     
      if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))){
        //Instanciando o objeto
        carta = new BeanCartaFrete();
        //populando o JavaBean
        carta.setIdcartafrete(Integer.parseInt(request.getParameter("idcartafrete")));
        carta.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
        carta.setData(Apoio.paraDate(request.getParameter("data")));
        carta.setVldependentes(Apoio.parseFloat(request.getParameter("vldependentes")));
        carta.setVlbaseir(Apoio.parseFloat(request.getParameter("vlbaseir")));
        carta.setAliqir(Apoio.parseFloat(request.getParameter("aliqir")));
        carta.setVlir(Apoio.parseFloat(request.getParameter("vlir")));
        carta.setVlJaRetido(Apoio.parseFloat(request.getParameter("vlinssjaretido")));
        carta.setVlOutrasEmpresas(Apoio.parseFloat(request.getParameter("vlretidoempresas")));
        carta.setVlbaseinss(Apoio.parseFloat(request.getParameter("vlbaseinss")));
        carta.setAliqinss(Apoio.parseFloat(request.getParameter("aliqinss")));
        carta.setVlinss(Apoio.parseFloat(request.getParameter("vlinss")));
        carta.setBaseSestSenat(Apoio.parseFloat(request.getParameter("vlbasesestsenat")));
        carta.setAliqsestsenat(Apoio.parseFloat(request.getParameter("aliqsestsenat")));
        carta.setVlsestsenat(Apoio.parseFloat(request.getParameter("vlsestsenat")));
        carta.setVlAvaria(Apoio.parseFloat(request.getParameter("vlavaria")));
        //carta.setVlFreteMotorista(Apoio.parseFloat(request.getParameter("vlfretemotorista")));
        carta.setVlFreteMotorista(Apoio.parseFloat(request.getParameter("vlfretecontrato")));
        carta.setOutrosdescontos(Apoio.parseFloat(request.getParameter("vloutros")));
        carta.setObsoutrosdescontos(request.getParameter("obsoutros"));
        carta.setVlImpostos(Apoio.parseFloat(request.getParameter("vlimpostos")));
        carta.setValorPedagio(Double.parseDouble(request.getParameter("vlpedagio")));
        carta.setValorDiaria(Double.parseDouble(request.getParameter("vldiaria")));
        carta.setValorDescarga(Double.parseDouble(request.getParameter("vldescarga")));
        carta.setVlLiquido(Apoio.parseFloat(request.getParameter("vlliquido")));
        carta.setVlOutrasDeducoes(Apoio.parseFloat(request.getParameter("vloutrasretencoes")));
        carta.getVeiculo().setIdveiculo(Integer.parseInt(request.getParameter("veiculo_id")));
        carta.getContratado().getPlanoCustoPadrao().setIdconta(Integer.parseInt(request.getParameter("plano_proprietario")));
        carta.getContratado().getUnidadeCusto().setId(Integer.parseInt(request.getParameter("und_proprietario")));
        carta.getCarreta().setIdveiculo(Integer.parseInt(request.getParameter("idcarreta")));
        carta.getContratado().setIdfornecedor(Integer.parseInt(request.getParameter("idproprietarioveiculo")));
        carta.getMotorista().setIdmotorista(Integer.parseInt(request.getParameter("idmotorista")));
        carta.getMotorista().setNome(request.getParameter("motor_nome"));
        carta.setObservacao(request.getParameter("obscartafrete"));
        carta.setValorTonelada(Apoio.parseFloat(request.getParameter("valorTonelada")));
        //carta.setCancelada(Boolean.parseBoolean(request.getParameter("cancelada")));
        carta.setCancelada(request.getParameter("cancelada") != null ? true : false );
        //carta.setReterImpostos(Boolean.parseBoolean(request.getParameter("reterImpostos")));
        carta.setReterImpostos(request.getParameter("chkReterImpostos") != null ? true : false );
        carta.getRota().setId(Integer.parseInt(request.getParameter("rota")));
        carta.setCiot(Apoio.parseLong(request.getParameter("ciot")));
        carta.setCiotCodVerificador(Apoio.parseInt(request.getParameter("ciotCodVerificador")));
        
        //Preenchendo o array dos pagamentos da carta frete
        if (! request.getParameter("pagamentos").equals("")){
          int qtdPagamentos = request.getParameter("pagamentos").split("!!").length;
         // if (request.getParameter("cartaValorCC") != null) {
          BeanPagamentoCartaFrete[] arrayPags = new BeanPagamentoCartaFrete[qtdPagamentos+1];
           int l= arrayPags.length;
          String pagtos = "";
          
          for (int k = 0; k < qtdPagamentos; ++k){
            BeanPagamentoCartaFrete pg = new BeanPagamentoCartaFrete();
            pagtos = request.getParameter("pagamentos").split("!!")[k];
            pg.setId(Apoio.parseInt(pagtos.split("!-")[0]));
            pg.setTipoPagamento(pagtos.split("!-")[1]);
            pg.setValor(Apoio.parseDouble(pagtos.split("!-")[2]));
            pg.setData(Apoio.paraDate(pagtos.split("!-")[3]));
            pg.getFpag().setIdFPag(Apoio.parseInt(pagtos.split("!-")[4].equals("") ? "0" : pagtos.split("!-")[4]));
            pg.setDocumento(pagtos.split("!-")[5]);
            pg.getAgente().setIdfornecedor(Apoio.parseInt(pagtos.split("!-")[6]));
            pg.setPercAbastecimento(Apoio.parseDouble(pagtos.split("!-")[7]));
            pg.getDespesa().setIdmovimento(Apoio.parseInt(pagtos.split("!-")[8]));
            pg.setBaixado(Apoio.parseBoolean(pagtos.split("!-")[9]));
            if (pagtos.split("!-")[10] != null && !pagtos.split("!-")[10].equals("")){
                pg.getConta().setIdConta(Apoio.parseInt(pagtos.split("!-")[10]));
            }    
            pg.setSaldoAutorizado(Apoio.parseBoolean(pagtos.split("!-")[11]));
            pg.getAgente().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(pagtos.split("!-")[12]));
            pg.setTipoFavorecido(pagtos.split("!-")[13]);
            pg.setContaBancaria(pagtos.split("!-")[14]);
            pg.setAgenciaBancaria(pagtos.split("!-")[15]);
            pg.setFavorecido(pagtos.split("!-")[16]);
            pg.getBanco().setIdBanco(Apoio.parseInt(pagtos.split("!-")[17]));
            pg.getAgente().getUnidadeCusto().setId(Apoio.parseInt(pagtos.split("!-")[18]));
            arrayPags[k] = pg;
          }
          if (Apoio.parseFloat(request.getParameter("cartaValorCC")) > 0 && acao.equals("incluir")){
            BeanPagamentoCartaFrete pgCarta = new BeanPagamentoCartaFrete();
            pgCarta.setId(Apoio.parseInt(request.getParameter("idPgtoCC")));
            pgCarta.setTipoPagamento("a");
            pgCarta.setValor(Apoio.parseFloat(request.getParameter("cartaValorCC")));
            pgCarta.setData(Apoio.paraDate(request.getParameter("cartaDataCC")));
            pgCarta.getFpag().setIdFPag(Apoio.parseInt(request.getParameter("cartaFPagCC")));
            pgCarta.setDocumento("");
            pgCarta.getAgente().setIdfornecedor(0);
            pgCarta.getAgente().getPlanoCustoPadrao().setIdconta(0);
            pgCarta.getAgente().getUnidadeCusto().setId(0);
            pgCarta.setPercAbastecimento(0);
            pgCarta.getDespesa().setIdmovimento(Apoio.parseInt(request.getParameter("idDespesaCC")));
            pgCarta.setBaixado(false);
            if (request.getParameter("contaCC") != null && !request.getParameter("contaCC").equals("")) {
                pgCarta.getConta().setIdConta(Apoio.parseInt(request.getParameter("contaCC")));
            }
            pgCarta.setSaldoAutorizado(false);
            pgCarta.setTipoFavorecido("m");
            pgCarta.setContaBancaria("");
            pgCarta.setAgenciaBancaria("");
            pgCarta.setFavorecido("");
            pgCarta.getBanco().setIdBanco(1); 
            arrayPags[arrayPags.length-1] = pgCarta;   
          }
          carta.setPagamento(arrayPags);           
        }
                       
        //Preenchendo o array dos manifestos
        if (!request.getParameter("manifestos").equals("")){
          int qtdManif = request.getParameter("manifestos").split(",").length;
          BeanManifesto[] arrayManifs = new BeanManifesto[qtdManif];
      
          for (int k = 0; k < qtdManif; ++k)
          {
            BeanManifesto mnf = new BeanManifesto();
            mnf.setIdmanifesto(Integer.parseInt(request.getParameter("manifestos").split(",")[k].split("!!!")[0]));
            mnf.getMotorista().setNome(request.getParameter("nome_motorista"));
            mnf.setTipo(request.getParameter("manifestos").split(",")[k].split("!!!")[1]);
            mnf.setNmanifesto(request.getParameter("manifestos").split(",")[k].split("!!!")[2]);
            arrayManifs[k] = mnf;
          }
          carta.setManif(arrayManifs);
        } 
        //Apenas para ação incluir
        if (acao.equals("incluir")){
          carta.setDtlancamento(Apoio.paraDate(Apoio.getDataAtual()));
          carta.setUsuariolancamento(Apoio.getUsuario(request));
        }//Apenas para ação atualizar
        else if (acao.equals("atualizar")){
          carta.setDtalteracao(Apoio.paraDate(Apoio.getDataAtual()));
          carta.setUsuarioalteracao(Apoio.getUsuario(request));
        }
        
        int qtdNotas = Integer.parseInt(request.getParameter("qtdNotas"));
        BeanDespesa[] dp = new BeanDespesa[qtdNotas];
        for (int x = 0; x < qtdNotas; ++x){
             if (request.getParameter("tipoDesp"+x) != null && request.getParameter("idNota"+x).equals("0")){
               dp[x] = new BeanDespesa();
               dp[x].getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));

               dp[x].setAVista(request.getParameter("tipoDesp"+x).equals("a")?true:false);
               dp[x].getEsp().setId(Apoio.parseInt(request.getParameter("especie"+x)));
               dp[x].setSerie(request.getParameter("serie"+x));
               dp[x].setNfiscal(request.getParameter("nf"+x));
               dp[x].setDtEmissao(Apoio.paraDate(request.getParameter("dataNota"+x)));
               dp[x].setDtEntrada(Apoio.paraDate(request.getParameter("dataNota"+x)));
               dp[x].setCompetencia(request.getParameter("dataNota"+x).substring(3,10));
               dp[x].getFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor"+x)));
               dp[x].getHistorico().setIdHistorico(Integer.parseInt(request.getParameter("idhistoricoNota"+x)));
               dp[x].setDescHistorico(request.getParameter("historicoNota"+x));
               dp[x].setValor(Apoio.parseFloat(request.getParameter("valorNota"+x)));
               //atribuindo as parcelas
               BeanDuplDespesa[] du = new BeanDuplDespesa[1];
               du[0] = new BeanDuplDespesa();
               du[0].setDtvenc(Apoio.paraDate(request.getParameter("dataNota"+x)));
               du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("valorNota"+x)));
               //Caso o lançamento seja a vista
               if (dp[x].isAVista()){

                   du[0].setBaixado(true);
                   du[0].setVlduplicata(Apoio.parseFloat(request.getParameter("valorNota"+x)));
                   du[0].setVlacrescimo(0);
                   du[0].setVldesconto(0);
                   du[0].getFpag().setIdFPag( request.getParameter("chqDespCarta_"+x) == null ? 1 : 3 );
                   du[0].setVlpago(Apoio.parseFloat(request.getParameter("valorNota"+x)));
                   du[0].setDtpago(Apoio.paraDate(request.getParameter("dataNota"+x)));
                   //movimentacao bancaria
                   du[0].getMovBanco().setConciliado(false);
                   du[0].getMovBanco().getConta().setIdConta(Integer.parseInt(request.getParameter("contaDespesa_"+x)));
                   du[0].getMovBanco().setValor(Apoio.parseFloat(request.getParameter("valorNota"+x)));
                   du[0].getMovBanco().setDtEntrada(Apoio.paraDate(request.getParameter("dataNota"+x)));
                   du[0].getMovBanco().setDtEmissao(Apoio.paraDate(request.getParameter("dataNota"+x)));
                   du[0].getMovBanco().getHistorico_id().setIdHistorico(Integer.parseInt(request.getParameter("idhistoricoNota"+x)));
                   du[0].getMovBanco().setHistorico(request.getParameter("historicoNota"+x));
                   du[0].getMovBanco().setCheque(true);

                   if (cfg.isControlarTalonario() && (request.getParameter("isCheque_"+x)!=null?true:false)){
                       du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_cb_"+x));
                   }else{
                       du[0].getMovBanco().setDocum(request.getParameter("docDespCarta_"+x));
                   }
                   du[0].getMovBanco().setNominal("");
               }
               dp[x].setDuplicatas(du);

               //atribuindo as apropriacoes
               int qtdApp = Integer.parseInt(request.getParameter("qtdApp"));
               BeanApropDespesa[] ap = new BeanApropDespesa[qtdApp];
               int j = 0; //Não posso utilizar o y pois o array do jsp não está na ordem correta da despesa.
               for (int y = 0; y < qtdApp; ++y){
                  if (request.getParameter("idApropriacao_"+x+"_"+y) != null){
                     ap[j] = new BeanApropDespesa();
                     ap[j].getPlanocusto().setIdconta(Integer.parseInt(request.getParameter("idApropriacao_"+x+"_"+y)));
                         ap[j].getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
                         ap[j].getVeiculo().setIdveiculo(Integer.parseInt(request.getParameter("idVeiculo_"+x+"_"+y)));
                         ap[j].getUndCusto().setId(Integer.parseInt(request.getParameter("idUnd_"+x+"_"+y)));
                         ap[j].setValor(Apoio.parseFloat(request.getParameter("valorApp_"+x+"_"+y)));
                         j++;
                  }
               }
               dp[x].setApropriacoes(ap);
            }
         }
         carta.setDespesa(dp);

        //Instanciando o BeanCadCartafrete
        cadcarta.setCFrete(carta);

        //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadcarta.Inclui() : cadcarta.Atualiza());

        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        %><script language="JavaScript" type="text/javascript"><%
        if (erro){
          String suggestId = "";	
          acao = (acao.equals("atualizar") ? "editar" : "iniciar");
      	  if (cadcarta.getErros().indexOf("pk_idcartafrete") > 0 && cfg.getIdentidicadorCartafrete() == 0){
			suggestId = cadcarta.getProximaCartaFrete();
    		%>if (confirm("A contrato de frete <%=cadcarta.getCFrete().getIdcartafrete()%> já existe.\n"+
                      "Deseja que o sistema crie com o número <%=suggestId%>?")){								
					window.opener.document.getElementById("idcartafrete").value = "<%=suggestId%>";
					window.opener.document.getElementById("salvar").onclick();
			  }
      	  <%}else if (cadcarta.getErros().indexOf("pk_idcartafrete") > 0 && cfg.getIdentidicadorCartafrete() == 1){
			suggestId = cadcarta.getProximaCartaFrete();
    		%>
                    if (confirm("A contrato de frete <%=cadcarta.getCFrete().getIdcartafrete()%> já existe.\n"+
                      "Deseja que o sistema crie com o número <%=suggestId%>?")){								
					window.opener.document.getElementById("idcartafrete").value = "<%=suggestId%>";
					window.opener.document.getElementById("salvar").onclick();
			  }
      	  <%}else if (cadcarta.getErros().indexOf("nf_fornecedor_duplicada") > 0){%>
    		alert('A despesa dessa contrato de frete já foi gerada anteriormente, não pode ser duplicada.');
          <%}else if (cadcarta.getErros().equals("Um resultado foi retornado quando nenhum era esperado.")){%>
	          window.opener.parent.document.location.replace("./consultacartafrete?acao=iniciar");
                  
          <%}else{%>
          	alert('<%=(cadcarta.getErros())%>');
		  <%}%>
          window.opener.habilitaSalvar(true);
          <%
          carta = cadcarta.getCFrete();
        }else{%>
          if (window.opener != null)
	          window.opener.parent.document.location.replace("./consultacartafrete?acao=iniciar");
        <%}%>
        window.close();
        </script>   
 <%   }
  } 
    
   if (acao.equals("carrega")){
      //Instanciando variáveis
      carta = new BeanCartaFrete();
      carta.setConfig(cfg);
      carta.setIdcartafrete((request.getParameter("idcartafrete").equals("")?0:Integer.parseInt(request.getParameter("idcartafrete"))));
      carta.setData(Apoio.paraDate(request.getParameter("data")));
      carta.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
      carta.getFilial().setAbreviatura(request.getParameter("fi_abreviatura"));
      carta.setObsoutrosdescontos(request.getParameter("obsoutros"));
      carta.setValorTonelada(Apoio.parseFloat(request.getParameter("valorTonelada")));
      carta.setObservacao(request.getParameter("obscartafrete"));
      //Preenchendo o array dos pagamentos da carta frete
      if (! request.getParameter("pagamentos").equals("")){
        int qtdPagamentos = request.getParameter("pagamentos").split("!!").length;
          BeanPagamentoCartaFrete[] arrayPags = new BeanPagamentoCartaFrete[qtdPagamentos];
		  String pagtos = "";
        for (int k = 0; k < qtdPagamentos; ++k)
        {
          BeanPagamentoCartaFrete pg = new BeanPagamentoCartaFrete();
          pagtos = request.getParameter("pagamentos").split("!!")[k];
          pg.setId(Apoio.parseInt(pagtos.split("!-")[0]));
          pg.setTipoPagamento(pagtos.split("!-")[1]);
          pg.setValor(Apoio.parseDouble(pagtos.split("!-")[2]));
          pg.setData(Apoio.paraDate(pagtos.split("!-")[3]));
          pg.getFpag().setIdFPag(Apoio.parseInt(pagtos.split("!-")[4]));
          pg.setDocumento(pagtos.split("!-")[5]);
          pg.getAgente().setIdfornecedor(Apoio.parseInt(pagtos.split("!-")[6]));
          pg.setPercAbastecimento(Apoio.parseDouble(pagtos.split("!-")[7]));
          pg.getDespesa().setIdmovimento(Apoio.parseInt(pagtos.split("!-")[8]));
          pg.setBaixado(Boolean.parseBoolean(pagtos.split("!-")[9]));
          if (pagtos.split("!-")[10] != null && !pagtos.split("!-")[10].equals("")){
              pg.getConta().setIdConta(Apoio.parseInt(pagtos.split("!-")[10]));
          }    
          pg.setSaldoAutorizado(Boolean.parseBoolean(pagtos.split("!-")[11]));
          pg.getAgente().getPlanoCustoPadrao().setIdconta(Apoio.parseInt(pagtos.split("!-")[12]));
          pg.setTipoFavorecido(pagtos.split("!-")[13]);
          pg.setContaBancaria(pagtos.split("!-")[14]);
          pg.setAgenciaBancaria(pagtos.split("!-")[15]);
          pg.setFavorecido(pagtos.split("!-")[16]);
          pg.getBanco().setIdBanco(Apoio.parseInt(pagtos.split("!-")[17]));
          arrayPags[k] = pg;
        }
        carta.setPagamento(arrayPags);
      }

      // Resgatando todos os manifestos selecionados
      if (mostracarta.MostraManifesto(request.getParameter("manifestos"))){
          
        int qtds = request.getParameter("manifestos").split(",").length;
        BeanManifesto[] arrayManif = new BeanManifesto[qtds];
        //rotas = new ArrayList<Rota>();
        Rota rota = null;
        int k = 0;
        ResultSet rs = mostracarta.getResultado();
        float valorCarreteiro = 0;
        double rotaValor = 0;
        String rotaTipoValor = "";
        float valorCarreteiroColeta = 0;
            
        while (rs.next()){
          //Dados veículo
          carta.getVeiculo().setIdveiculo(rs.getInt("idveiculo"));
          carta.getVeiculo().setPlaca(rs.getString("cavalo"));
          carta.getContratado().setIdfornecedor(rs.getInt("idpcav"));
          carta.getContratado().setRazaosocial(rs.getString("propcavalo"));
          carta.getContratado().setCpfCnpj(rs.getString("cgcpcav"));
          carta.getContratado().setQuantidadeDependentes(rs.getInt("qtddependentes"));
          carta.getContratado().getPlanoCustoPadrao().setIdconta(rs.getInt("plano_proprietario"));
          carta.getContratado().getUnidadeCusto().setId(rs.getInt("und_proprietario"));
          carta.getContratado().setContaBancaria(rs.getString("prop_conta1"));
          carta.getContratado().setAgenciaBancaria(rs.getString("prop_agencia1"));
          carta.getContratado().setFavorecido(rs.getString("prop_favorecido1"));
          carta.getContratado().getBanco().setIdBanco(rs.getInt("prop_banco1"));
          carta.getContratado().setContaBancaria2(rs.getString("prop_conta2"));
          carta.getContratado().setAgenciaBancaria2(rs.getString("prop_agencia2"));
          carta.getContratado().setFavorecido2(rs.getString("prop_favorecido2"));
          carta.getContratado().getBanco2().setIdBanco(rs.getInt("prop_banco2"));
          carta.getContratado().setDebitoProp(rs.getDouble("debito_prop"));
          carta.getContratado().setPercentualDescontoProp(rs.getDouble("percentual_desconto_prop"));
          carta.getVeiculo().getTipo_veiculo().setId(rs.getInt("cavalo_tipo_veiculo_id"));
          carta.getCarreta().setIdveiculo(rs.getInt("idcarreta"));
          carta.getCarreta().setPlaca(rs.getString("carreta"));
          carta.getCarreta().getTipo_veiculo().setId(rs.getInt("carreta_tipo_veiculo_id"));
          carta.getCarreta().getProprietario().setRazaosocial(rs.getString("propcarreta"));
          carta.getCarreta().getProprietario().setCpfCnpj(rs.getString("cgcpcar"));
          //Dados motorista
          carta.getMotorista().setIdmotorista(rs.getInt("idmotorista"));
          carta.getMotorista().setNome(rs.getString("motorista"));
          carta.getMotorista().setCpf(rs.getString("cpfmot"));
          carta.getMotorista().setCnh(rs.getString("cnh"));
          carta.getMotorista().setConta1(rs.getString("motor_conta1"));
          carta.getMotorista().setAgencia1(rs.getString("motor_agencia1"));
          carta.getMotorista().setFavorecido1(rs.getString("motor_favorecido1"));
          carta.getMotorista().getBanco1().setIdBanco(rs.getInt("motor_banco1"));
          carta.getMotorista().setConta2(rs.getString("motor_conta2"));
          carta.getMotorista().setAgencia2(rs.getString("motor_agencia2"));
          carta.getMotorista().setFavorecido2(rs.getString("motor_favorecido2"));
          carta.getMotorista().getBanco2().setIdBanco(rs.getInt("motor_banco2"));
          carta.getMotorista().setPercentualDescontoContrato(rs.getFloat("percentual_desconto_contrato"));
          carta.setObservacao(carta.getObservacao().trim().equals("") ? rs.getString("obscartafrete") : carta.getObservacao());
          carta.getRota().setId(Integer.parseInt(request.getParameter("rota")));
          //Dados do manifesto
          BeanManifesto mnf = new BeanManifesto();
          mnf.setIdmanifesto(rs.getInt("idmanifesto"));
          mnf.setNmanifesto(rs.getString("nmanifesto"));
          mnf.setTipo(rs.getString("tipo"));
          if (rs.getString("tipocgc").equals("F") || rs.getBoolean("is_tac")){
              calculaimpostos = true;
              carta.setReterImpostos(true);
          }else{
              calculaimpostos = false;
              carta.setReterImpostos(false);
          }

          mnf.getCavalo().getProprietario().getCidade().setDescricaoCidade(rs.getString("cidpcav"));
          mnf.getCavalo().getProprietario().getCidade().setUf(rs.getString("ufpcav"));
          mnf.getCavalo().getProprietario().setQuantidadeDependentes(rs.getInt("qtddependentes"));
          mnf.getCavalo().getMarca().setDescricao(rs.getString("marcacav"));
          mnf.getCavalo().setCidadeemplac(rs.getString("cidadecav"));
          mnf.getCarreta().setPlaca(rs.getString("carreta"));
          mnf.getCidadeorigem().setIdcidade(rs.getInt("idcidadeorigem"));
          mnf.getCidadeorigem().setCidade(rs.getString("origem"));
          mnf.getCidadedestino().setIdcidade(rs.getInt("id_cidade_destino_contrato"));
          mnf.getCidadedestino().setCidade(rs.getString("cidade_destino_contrato"));
          mnf.setDtsaida(rs.getDate("dtsaida"));
          mnf.setTotalPeso(rs.getFloat("peso")); //Usando esse campo apenas para auxiliar no carregamento do campo peso.
          mnf.setTotalPrestacao(rs.getFloat("total_frete")); //Usando esse campo apenas para auxiliar no carregamento do campo frete.
		  freteTotal += rs.getFloat("total_frete");
                  pesoTotalRota += rs.getFloat("peso");
          carta.setPercentualAdiantamento(rs.getFloat("percentual_adiantamento"));
          percAdiantamentoMotorista = rs.getDouble("percentual_adiantamento");
          valorCarreteiroColeta += rs.getFloat("valor_carreteiro");
          valorAdiantamentoCarreteiro += rs.getDouble("adiantamento_carreteiro");
          valorSaldoCarreteiro += rs.getDouble("saldo_carreteiro");
          
            mostrarota = new ConsultaRota();
            mostrarota.setConexao(Apoio.getUsuario(request).getConexao());
            int idCidadeOrigem = mnf.getCidadeorigem().getIdcidade();
            int idCidadeDestino = mnf.getCidadedestino().getIdcidade();
            int idCarretaTipoVeiculo = carta.getCarreta().getTipo_veiculo().getId();
            int idCavaloTipoVeiculo = carta.getVeiculo().getTipo_veiculo().getId();
            
            
            if(mostrarota.mostarRota(idCidadeOrigem, idCidadeDestino, idCarretaTipoVeiculo, idCavaloTipoVeiculo)){
                ResultSet rsRota = mostrarota.getResultado();
                while (rsRota.next()){
                    rota = new Rota();
                    tipoVeiculoRota = new TipoVeiculoRota();
                    rota.setId(rsRota.getInt("id"));
                    rota.setDescricao(rsRota.getString("descricao"));
                    
                    tipoVeiculoRota.setValor(rsRota.getDouble("valor"));
                    tipoVeiculoRota.setValorMaximo(rsRota.getDouble("valor_maximo"));
                    tipoVeiculoRota.setTipoValor(rsRota.getString("tipo_valor"));
                    
                    rota.getListaTipoVeiculo().add(tipoVeiculoRota);
                    //rotas.add(rota);
                    carta.getRotas().add(rota);
                    
                    rotaValor = rsRota.getDouble("valor");
                    rotaTipoValor = rsRota.getString("tipo_valor");
                }
            }
            
          arrayManif[k] = mnf;
          k++;
        }
            
        if (!request.getParameter("acaoanterior").equals("iniciar"))
        {
          carta.setDtlancamento(Apoio.paraDate(request.getParameter("dtlancamento")));
          carta.getUsuariolancamento().setNome(request.getParameter("usulancamento"));
          carta.setDtalteracao(Apoio.paraDate(request.getParameter("dtalteracao")));
          carta.getUsuarioalteracao().setNome(request.getParameter("usualteracao"));
        }
        carta.setManif(arrayManif);
        //carta.setVlFreteMotorista(Apoio.parseFloat(request.getParameter("vlfretemotorista")));
        carta.setVlFreteMotorista(Apoio.parseFloat(request.getParameter("vlfretecontrato")));
        if (carta.getVlFreteMotorista() == 0){
            //carta.setVlFreteMotorista(valorCarreteiro);
            if(rotaTipoValor.equals("p")){
                valorCarreteiro = (float)((pesoTotalRota/1000.0)*rotaValor);
            } else if(rotaTipoValor.equals("f")){
                valorCarreteiro = (float) rotaValor;
            }else if(rotaTipoValor.equals("c")){
                valorCarreteiro = (float)(freteTotal * (rotaValor/100));
            }else{
                valorCarreteiro = valorCarreteiroColeta;
            }
            carta.setVlFreteMotorista(valorCarreteiro);
        }
        carta.setOutrosdescontos(Apoio.parseFloat(request.getParameter("vloutros")));
        carta.setValorPedagio(Double.parseDouble(request.getParameter("vlpedagio")));
        carta.setValorDiaria(Double.parseDouble(request.getParameter("vldiaria")));
        carta.setValorDescarga(Double.parseDouble(request.getParameter("vldescarga")));
        float vlDeducoes = 0;
        if (cfg.getVlConMotor() == 0 && carta.getMotorista().getPercentualDescontoContrato() == 0){
            vlDeducoes = Apoio.parseFloat(request.getParameter("vloutrasretencoes"));
        }else{
            if (cfg.getTipoVlConMotor().equals("f")){
                vlDeducoes = cfg.getVlConMotor();
            }else{
                vlDeducoes = carta.getVlFreteMotorista() * cfg.getVlConMotor() / 100;
            }
            vlDeducoes += (carta.getVlFreteMotorista() * carta.getMotorista().getPercentualDescontoContrato() / 100);
        }
        
        carta.setVlOutrasDeducoes(vlDeducoes);
        carta.setVlAvaria(Apoio.parseFloat(request.getParameter("vlavaria")));
        carta.setVlJaRetido(cadcarta.getVLJaRetido(carta.getData(),carta.getContratado().getIdfornecedor(),carta.getIdcartafrete()));
        carta.setBaseINSSJaRetida(cadcarta.getVlBaseINSSJaRetida(carta.getData(),carta.getContratado().getIdfornecedor(),carta.getIdcartafrete()));
        carta.setVlIRJaRetido(cadcarta.getVLIRJaRetido(carta.getData(),carta.getContratado().getIdfornecedor(),carta.getIdcartafrete()));
        carta.setBaseIRJaRetida(cadcarta.getVlBaseIRJaRetida(carta.getData(),carta.getContratado().getIdfornecedor(),carta.getIdcartafrete()));
        //Recuperando os valores na tela 
        acao = request.getParameter("acaoanterior");
      }  
   }
   //Variavel usada para saber se o usuario esta editando
   carregacarta = ((carta != null) &&  (!acao.equals("incluir") && !acao.equals("atualizar")));
   int nivelEdicao = !acao.equals("iniciar") ? Apoio.getUsuario(request).getAcesso("alterarcontratofreteimpresso") : 4;

   if (acao.equals("recibo")) {
      //Preenchendo o array dos conhecimentos
      String condicao = "";
      //recebendo valor do primeiro cheque
      condicao = " where idmovimento = " + request.getParameter("id");

      java.util.Map param = new java.util.HashMap(1);
      param.put("CONDICAO", condicao);

    request.setAttribute("map", param);
    request.setAttribute("rel", "recibodespesacontratofrete");

    RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
    dispatcher.forward(request, response);
   }

 %>

<script language="JavaScript" type="text/javascript">
    jQuery.noConflict();
var indexPagto = 0;
var isChequeVazio = false;
var indexNotes = 0;
var indexApp = 0;
var nivelBxDespesaViagem = <%=nivelUserBaixarDespesa%>;
var dataAtual = '<%=Apoio.getDataAtual()%>';
//******* Carregando a lsta de contas
var countConta = 0;
var listaConta = new Array();

function Lista(id,descricao){
    this.id = id ;
    this.descricao = descricao;
}

<%cta.setConexao(Apoio.getUsuario(request).getConexao());
  cta.mostraContas((cartaFl>1?0:Apoio.getUsuario(request).getFilial().getIdfilial()),true, limitarUsuarioVisualizarConta, idUsuario);;
  ResultSet rsconta = cta.getResultado();
  while (rsconta.next()){%>
    listaConta[countConta]= new Lista('<%=rsconta.getString("idconta")%>', '<%=rsconta.getString("banco")%>  <%=rsconta.getString("numero")%> - <%=rsconta.getString("digito_conta")%>') ;
    countConta++;
  <%}%>

//******************
function alteraTipoDespesa(index){
    if($("tipoDesp"+index).value=="a"){
        visivel($("trdesp2_"+index));
    }else{
        invisivel($("trdesp2_"+index));
    }
}
function addNotes(id, tipo, especie, serie, nf, data, venc, idfornecedor, fornecedor, idhist, historico, valor, doc, contaId){
            var acao = '<%=acao%>';
            var incluindo = (id == 0 ? true : false);
            var _tr = '';
            var _td = '';
            var _opt1 = Builder.node('OPTION', {value:'a'}, 'Pago');
            var _opt2 = Builder.node('OPTION', {value:'p'}, 'A Pagar');
            contaId = (contaId == 0 ? <%=cfg.getConta_padrao_id().getIdConta()%>: contaId);

            _tr = Builder.node('TR', {id:'trdesp'+indexNotes,name:'trdesp'+indexNotes, className:'CelulaZebra2'},
            [Builder.node('TD',indexNotes+1),
                Builder.node('TD',
                [Builder.node('SELECT', {name:'tipoDesp'+indexNotes, id:'tipoDesp'+indexNotes, className:'fieldMin', onchange:'javascript:alteraTipoDespesa('+indexNotes+');$(\'idTipoDesp'+indexNotes+'\').value = this.value;'},[]),
                    Builder.node('INPUT', {type:'hidden', name:'idTipoDesp'+indexNotes, id:'idTipoDesp'+indexNotes,
                        value:tipo}),
                    Builder.node('LABEL', {name:'despesa_'+indexNotes, 
                        id:'despesa_'+indexNotes, value:id, className:'linkEditar',
                        onClick:'javascript: verDesp('+id+');'})
                ]
            ),
                Builder.node('TD',
                [Builder.node('SELECT', {name:'especie'+indexNotes, id:'especie'+indexNotes, className:'fieldMin'},
                    [
    <%                                    Especie es = new Especie();
            ResultSet rsEsp = es.all(Apoio.getUsuario(request).getConexao());
            while (rsEsp.next()) {%>
                                    Builder.node('OPTION', {value:'<%=rsEsp.getString("id")%>'}, '<%=rsEsp.getString("especie")%>'),
    <%                                    }
            rsEsp.close();
    %>                                 ])]),
                        Builder.node('TD',
                        [Builder.node('INPUT', {type:'text', name:'serie'+indexNotes, id:'serie'+indexNotes,
                                size:'4', maxLength:'3', value:serie, className:'fieldMin'}),
                            Builder.node('INPUT',{type:'hidden', name:'idNota'+indexNotes, id:'idNota'+indexNotes, value:id},'')
                        ]),
                        Builder.node('TD',
                        [Builder.node('INPUT', {type:'text', name:'nf'+indexNotes, id:'nf'+indexNotes,
                                size:'7', maxLength:'10', value:nf, className:'fieldMin'})
                        ]),
                        Builder.node('TD',
                        [Builder.node('INPUT', {type:'text', name:'dataNota'+indexNotes, id:'dataNota'+indexNotes,
                                size:'12', maxLength:'10', value:data, className:'fieldMin',
                                onBlur:'alertInvalidDate($(\'dataNota'+indexNotes+'\'));',
                                onKeyDown:'fmtDate($(\'dataNota'+indexNotes+'\') , event);',
                                onKeyUp:'fmtDate($(\'dataNota'+indexNotes+'\') , event);',
                                onKeyPress:'fmtDate($(\'dataNota'+indexNotes+'\') , event);'})
                        ]),
                        Builder.node('TD',
                        [Builder.node('INPUT', {type:'hidden', name:'idfornecedor'+indexNotes, id:'idfornecedor'+indexNotes,
                                value:idfornecedor}),
                            Builder.node('INPUT', {type:'text', name:'fornecedor'+indexNotes, id:'fornecedor'+indexNotes,
                                size:'30', maxLength:'80', value:fornecedor, className:'inputReadOnly8pt'}),
                            Builder.node('INPUT', {type:'button', name:'localizaForn_'+indexNotes, id:'localizaForn_'+indexNotes,
                                value:'...', className:'botoes',
                                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=21\',\'Fornecedor_'+indexNotes+'\');'
                            })
                        ]),
                        Builder.node('TD',
                        [Builder.node('INPUT', {type:'hidden', name:'idhistoricoNota'+indexNotes, id:'idhistoricoNota'+indexNotes,
                                value:idhist}),
                            Builder.node('INPUT', {type:'text', name:'historicoNota'+indexNotes, id:'historicoNota'+indexNotes,
                                size:'30', maxLength:'200', value:historico, className:'fieldMin'}),
                            Builder.node('INPUT', {type:'button', name:'localizaHist_'+indexNotes, id:'localizaHist_'+indexNotes,
                                value:'...', className:'botoes',
                                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=14\',\'Historico_'+indexNotes+'\');'
                            })
                        ]),
                        Builder.node('TD',
                        [Builder.node('INPUT', {type:'text', name:'valorNota'+indexNotes, id:'valorNota'+indexNotes,
                                size:'8', maxLength:'12', value:formatoMoeda(valor), className:'inputReadOnly8pt',
                                onchange:'seNaoFloatReset($(\'valorNota'+indexNotes+'\'), \'0.00\');'})
                        ]),
                        Builder.node('TD', (!incluindo ?
                            [Builder.node('IMG', {src:'img/pdf.jpg', title:'Imprimir Recibo', className:'imagemLink',
                                onClick:'imprimirRecibo('+id+');', width:'19', height:'19', border:'0'})]
                        :
                            [Builder.node('IMG', {src:'img/lixo.png', title:'Excluir Despesa', className:'imagemLink',
                                onClick:'excluirNota('+indexNotes+');'})
                        ]))
                    ]);

                    $('desp_notes').appendChild(_tr);
                    
                    $('tipoDesp'+indexNotes).appendChild(_opt1);
                    $('tipoDesp'+indexNotes).appendChild(_opt2);
                    
                    tipo = (tipo==""?"p":tipo);

                    $('tipoDesp'+indexNotes).value = tipo;
                    $('idTipoDesp'+indexNotes).value = tipo;
                    $('fornecedor'+indexNotes).readOnly = true;
                    $('valorNota'+indexNotes).readOnly = true;

                    var slc2_ = Builder.node("SELECT",{id:"contaDespesa_"+indexNotes, name:"contaDespesa_"+indexNotes, className:"fieldMin", onChange:"isUsarCheque("+indexNotes+")"});

                    var _opt1 = null;

                    for(var i = 0; i < listaConta.length; i++){
                        slc2_.appendChild(Builder.node("OPTION", {value: listaConta[i].id},listaConta[i].descricao));
                    }

                    var _inp = Builder.node('INPUT', {type:'text', name:'docDespCarta_'+indexNotes, id:'docDespCarta_'+indexNotes, size:'8', maxLength:'10', value: "", className:'fieldMin'});
                    var _chk = Builder.node('INPUT', {type:'checkbox', name:'isCheque_'+indexNotes, id:'isCheque_'+indexNotes ,className:'fieldMin', onClick:"isUsarCheque("+indexNotes+")"});
                    var _lab = Builder.node('LABEL', "Cheque ");

                    var slc1_ = Builder.node("SELECT",{id:"docDespCarta_cb_"+indexNotes, name:"docDespCarta_cb_"+indexNotes, className:"fieldMin"});
                    var _opt = Builder.node('OPTION', {value:''}, '-----');

                    slc1_.appendChild(_opt);

                    var _td0 = Builder.node("TD");
                    var _td1 = Builder.node("TD",{colSpan:"4"});
                    var _td2 = Builder.node("TD",{colSpan:"5"});

                    _td1.appendChild(slc2_);
                    _td2.appendChild(_chk);
                    _td2.appendChild(_lab);
                    _td2.appendChild(_inp);
                    _td2.appendChild(slc1_);

                    var _tr2 = Builder.node('TR', {id:'trdesp2_'+indexNotes,name:'trdesp2_'+indexNotes, className:'CelulaZebra2'});
                    _tr2.appendChild(_td0);
                    _tr2.appendChild(_td1);
                    _tr2.appendChild(_td2);


                    $('desp_notes').appendChild(_tr2);

                    invisivel(slc1_);
                    invisivel(_tr2);

                    //Criando a tabela de Apropriações
                    _tr = Builder.node('TR', {id:'trApropDesp'+indexNotes},
                    [Builder.node('TD',{colSpan:'10'},
                        [Builder.node('TABLE', {id:'TB'+indexNotes, width:'100%', border:'0'},
                            [Builder.node('TBODY', {id:'TBODYNOTES'+indexNotes},
                                [Builder.node('TR', {className:'CelulaZebra1'},
                                    [Builder.node('TD', {width:'2%'}, (!incluindo ? '' :
                                            [Builder.node('IMG', {src:'img/add.gif', title:'Adicionar Apropriação', className:'imagemLink',
                                                onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=20\',\'Plano_'+indexNotes+'\');'})
                                        ])),
                                        Builder.node('TD', {width:'42%'}, 'Plano de custo'),
                                        Builder.node('TD', {width:'14%'}, 'Veículo'),
                                        Builder.node('TD', {width:'9%'}, 'Valor'),
                                        Builder.node('TD', {width:'10%'}, 'Und. custo'),
                                        Builder.node('TD', {width:'3%'}, ''),
                                        Builder.node('TD', {width:'10%'}, 'Vencimento:'),
                                        Builder.node('TD', {width:'10%'},
                                        [Builder.node('INPUT', {type:'text', name:'dataVenc'+indexNotes, id:'dataVenc'+indexNotes,
                                                size:'12', maxLength:'10', value:venc, className:'fieldMin',
                                                onBlur:'alertInvalidDate($(\'dataVenc'+indexNotes+'\'));',
                                                onKeyDown:'fmtDate($(\'dataVenc'+indexNotes+'\') , event);',
                                                onKeyUp:'fmtDate($(\'dataVenc'+indexNotes+'\') , event);',
                                                onKeyPress:'fmtDate($(\'dataVenc'+indexNotes+'\') , event);'})
                                        ])
                                    ])
                                ])
                            ])
                        ])
                    ]);                    
                    $('desp_notes').appendChild(_tr);


                    if (!incluindo){
                        $('contaDespesa_'+indexNotes).value = contaId;
                        $('especie'+indexNotes).disabled = true;
                        $('tipoDesp'+indexNotes).disabled = true;
                        $('contaDespesa_'+indexNotes).disabled = true;
                        $('serie'+indexNotes).readOnly = true;
                        $('nf'+indexNotes).readOnly = true;
                        $('dataNota'+indexNotes).readOnly = true;
                        $('dataVenc'+indexNotes).readOnly = true;
                        $('historicoNota'+indexNotes).readOnly = true;
                        $('docDespCarta_'+indexNotes).readOnly = true;
                        $('isCheque_'+indexNotes).disabled = true;
                        $('localizaForn_'+indexNotes).style.display = "none";
                        $('localizaHist_'+indexNotes).style.display = "none";
                        $('especie'+indexNotes).style.backgroundColor = '#FFFFF1';
                        invisivel($('tipoDesp'+indexNotes));
                        $('tipoDesp'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('isCheque_'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('serie'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('nf'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('docDespCarta_'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('dataNota'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('dataVenc'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('historicoNota'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('contaDespesa_'+indexNotes).style.backgroundColor = '#FFFFF1';
                        $('tipoDesp'+indexNotes).value = tipo;
                        $('docDespCarta_'+indexNotes).value = doc;
                        $('idTipoDesp'+indexNotes).value = tipo;
                    }
//                    $('tipoDesp'+indexNotes).style.display = "none";
                    $('despesa_'+indexNotes).innerHTML = (id == 0 ? '' : id);
                    alteraTipoDespesa(indexNotes);
                    indexNotes++;
                }

function isUsarCheque(i){
        if($("isCheque_"+i).checked){
            verDocDesp(i);
        }else{
            visivel($('docDespCarta_'+i));
            invisivel($('docDespCarta_cb_'+i));
        }
    }

function addApropriacao(indexNota, idApropriacao, conta, apropriacao, idVeiculo, veiculo, valor, incluindo, idUnd, und){
var _tr = '';
_tr = Builder.node('TR', {id:'trApropDesp'+indexNota+'_'+indexApp, className:'CelulaZebra1'},
[Builder.node('TD',''),
    Builder.node('TD',
    [Builder.node('INPUT', {type:'hidden', name:'idApropriacao_'+indexNota+'_'+indexApp, id:'idApropriacao_'+indexNota+'_'+indexApp,
            value:idApropriacao}),
        Builder.node('INPUT', {type:'text', name:'conta_'+indexNota+'_'+indexApp, id:'conta_'+indexNota+'_'+indexApp,
            size:'15', value:conta, className:'inputReadOnly8pt'}),
        Builder.node('INPUT', {type:'text', name:'apropriacao_'+indexNota+'_'+indexApp, id:'apropriacao_'+indexNota+'_'+indexApp,
            size:'40', value:apropriacao, className:'inputReadOnly8pt'}),
        Builder.node('INPUT', {type:'button', name:'localizaApp_'+indexNota+'_'+indexApp, id:'localizaApp_'+indexNota+'_'+indexApp,
            value:'...', className:'botoes',
            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=20\',\'Plano_'+indexNota+'_'+indexApp+'\');'})
    ]),
    Builder.node('TD',
    [Builder.node('INPUT', {type:'hidden', name:'idVeiculo_'+indexNota+'_'+indexApp, id:'idVeiculo_'+indexNota+'_'+indexApp,
            value:idVeiculo}),
        Builder.node('INPUT', {type:'text', name:'veiculo_'+indexNota+'_'+indexApp, id:'veiculo_'+indexNota+'_'+indexApp,
            size:'12', value:veiculo, className:'inputReadOnly8pt'}),
        Builder.node('INPUT', {type:'button', name:'localizaVei_'+indexNota+'_'+indexApp, id:'localizaVei_'+indexNota+'_'+indexApp,
            value:'...', className:'botoes',
            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=24\',\'Veiculo_'+indexNota+'_'+indexApp+'\');'})
    ]),
    Builder.node('TD',
    [Builder.node('INPUT', {type:'text', name:'valorApp_'+indexNota+'_'+indexApp, id:'valorApp_'+indexNota+'_'+indexApp,
            size:'8', maxLength:'12', value:formatoMoeda(valor), className:'fieldMin',
            onchange:'seNaoFloatReset($(\'valorApp_'+indexNota+'_'+indexApp+'\'), \'0.00\');totalNota('+indexNota+')'})
    ]),
    Builder.node('TD',
    [Builder.node('INPUT', {type:'hidden', name:'idUnd_'+indexNota+'_'+indexApp, id:'idUnd_'+indexNota+'_'+indexApp,
            value:idUnd}),
        Builder.node('INPUT', {type:'text', name:'und_'+indexNota+'_'+indexApp, id:'und_'+indexNota+'_'+indexApp,
            size:'5', value:und, className:'inputReadOnly8pt'}),
        Builder.node('INPUT', {type:'button', name:'localizaUnd_'+indexNota+'_'+indexApp, id:'localizaUnd_'+indexNota+'_'+indexApp,
            value:'...', className:'botoes',
            onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=39\',\'Und_'+indexNota+'_'+indexApp+'\');'})
    ]),
    Builder.node('TD', (!incluindo ? '' :
        [Builder.node('IMG', {src:'img/lixo.png', title:'Excluir Apropriação', className:'imagemLink',
            onClick:'excluirApp('+indexNota+','+indexApp+');'})
    ])),
    Builder.node('TD',''),
    Builder.node('TD','')
]);
$('TBODYNOTES'+indexNota).appendChild(_tr);

$('conta_'+indexNota+'_'+indexApp).readOnly = true;
$('apropriacao_'+indexNota+'_'+indexApp).readOnly = true;
$('veiculo_'+indexNota+'_'+indexApp).readOnly = true;
$('und_'+indexNota+'_'+indexApp).readOnly = true;
if (!incluindo){
    $('valorApp_'+indexNota+'_'+indexApp).readOnly = true;
    $('localizaVei_'+indexNota+'_'+indexApp).style.display = "none";
    $('localizaApp_'+indexNota+'_'+indexApp).style.display = "none";
    $('valorApp_'+indexNota+'_'+indexApp).style.backgroundColor = '#FFFFF1';
}
indexApp++;

}

function imprimirRecibo(id){
    launchPDF('./cadcartafrete?acao=recibo&id='+id,'recibo'+id);
}

function totalNota(indexNota){
var total = 0;
for (i = 0; i < indexApp; ++i){
    if ($('valorApp_'+indexNota+'_'+i) != null){
        total += parseFloat($('valorApp_'+indexNota+'_'+i).value);
    }
}
$('valorNota'+indexNota).value = formatoMoeda(total);
//totalDespesasAvista();
//totalAcerto();
}

function excluirApp(indexNota, indexAprop){
if (confirm("Deseja mesmo excluir esta apropriação?")){
    Element.remove('trApropDesp'+indexNota+'_'+indexAprop);
    totalNota(indexNota);
}
}

function excluirNota(indexNota){
if (confirm("Deseja mesmo excluir esta despesa?")){
    Element.remove('trApropDesp'+indexNota);
    Element.remove('trdesp'+indexNota);
    //totalDespesasAvista();
    //totalAcerto();
}
}

  function check(){
    if (!wasNull("idfilial,data,dataadiant,idcartafrete")){
       return true;
    }else
       return false;
  }

  function reterImpostos(){
    
    $('tr_ir').style.display = 'none';
    $('tr_inss').style.display = 'none';
    $('tr_sest').style.display = 'none';
    if (document.getElementById('chkReterImpostos').checked){
        $('tr_ir').style.display = '';
        $('tr_inss').style.display = '';
        $('tr_sest').style.display = '';
    }else{
        $('vlir').value = '0.00'
        $('vlinss').value = '0.00'
        $('vlsestsenat').value = '0.00'
    }
  }

  function voltar(){
     document.location.replace("./consultacartafrete?acao=iniciar");
  }

  function selecionar_manifesto(qtdLinhas,acao){
      var nivelProprio = <%=nivelVeiculoProprio%>;
      try{
           if ($("mostratudo").checked && nivelProprio < 4){
                alert('ATENÇÃO! Você não tem privilégios suficiente para selecionar documentos de veículos próprios.\r\n\r\n\r\nCódigo da permissão: 293');
                return null;
            }
            tryRequestToServer(function(){post_cad = window.open('./selecionamanifesto?acao=iniciar&marcados='+verificaManifs(qtdLinhas)+'&marcados2=' + $("idcartafrete").value + '&acaoDoPai=' + acao + '&filial=' + $("idfilial").value+'&mostratudo='+getObj("mostratudo").checked+'&idlista=','Cidade',
                     'top=80,left=0,height=400,width=1000,resizable=yes,status=1,scrollbars=1')});
      }catch(e){
          alert(e);
      }
  }

  function verificaManifs(qtdLinhas){
    var retorno = "";
    for (i = 0; i <= qtdLinhas - 1; ++i){
      retorno += (retorno == "" ? "" : ",") + $("linha-"+i).value + '!!!' + $("tipo-"+i).value + '!!!' + $("numero-"+i).value;
    }
    return (retorno);
  }
  
  
  function carrega(manifs,qtdLinhas,acao,calculaFrete){
   
      
    var temp = "";
	var pagamentos = concatPagtos();
        
    if ( pagamentos == null){
      alert ("Informe os pagamentos do contrato de frete corretamente.");
      return null;
    }
    if (manifs == '0'){
      manifs = verificaManifs(qtdLinhas);
    }
    
    $("acao").value = "carrega";
    $("acaoanterior").value = acao;
    $("calculaFrete").value = calculaFrete;
    $("manifestos").value = manifs;
    $("pagamentos").value = pagamentos;    
       
    //window.open('about:blank', 'pop', 'width=210, height=100');
    
    $("formulario").target = "";
    $("formulario").submit();
    
    /*
    if (acao == "editar"){
       temp = "&dtlancamento="+$("dtlancamento").value+
              "&usulancamento="+$("usulancamento").value+
              "&dtalteracao="+$("dtalteracao").value+
              "&usualteracao="+$("usualteracao").value
    }
    
    
    document.location.replace("./cadcartafrete?acao=carrega"+
                                "&acaoanterior="+acao+temp+ 
                                "&manifestos="+manifs+
                                "&id="+$("idcartafrete").value+
                                "&idfilial="+$("idfilial").value+
                                "&fi_abreviatura="+$("fi_abreviatura").value+
                                "&obsoutros="+$("obsoutros").value+
                                "&vlavaria="+$("vlavaria").value+
                                "&vlfretemotorista="+$("vlfretecontrato").value+
                                "&calculaFrete="+calculaFrete+
                                "&vloutrasretencoes="+$("vloutrasretencoes").value+
                                "&vloutros="+$("vloutros").value+
                                "&vlpedagio="+$("vlpedagio").value+
                                "&valorTonelada="+$("valorTonelada").value+
                                "&cancelada="+$("cancelada").checked+
                                "&pagamentos="+pagamentos+
                                "&rota="+$("rota").value+
                                "&data="+$("data").value);
        */
     }

  
  function habilitaSalvar(opcao){
     $("salvar").disabled = !opcao;
     $("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }
  
  function salva(qtdLinhas){
    habilitar($("chkReterImpostos"));
    // O parametro 'aosalvar' receberá 0 para salvar e sair ou 1 para salvar e incluir outro

    //Verificando se o percentual de adiantamento está dentro do permitido no cadastro do motorista.
    if (<%=nivelUserAdiantamento == 0%>){
        var percPermitido = <%=percAdiantamentoMotorista%>;
        var totalAdtmo = getTotalAdt();
        var xTotalLiquido = $('vlliquido').value;
        var percAdtmo = parseFloat(totalAdtmo) * 100 / parseFloat(xTotalLiquido);
        if (parseFloat(percAdtmo) > parseFloat(percPermitido)){
            alert('Para esse motorista só é permitido ' + percPermitido + '% de adiantamento!');
            return false;
        }
    }
    var pagamentos = concatPagtos();
    
     if(parseFloat($("vlfretecontrato").value)<='0.00'){
        alert("Valor do Frete não pode ser 0.00 (zero)!");
        return false;
    }
       
    if ( ! validaData($("data").value)){
      alert ("Informe a data de saída corretamente. Formato válido: dd/mm/aaaa");
      $("data").style.background ="#FFE8E8";
    }
    else if ( verificaManifs(qtdLinhas) == '' && <%=!cfg.isSalvaCartaSemManifesto()%>){
      alert ("Escolha pelo menos 1 documento(Manifesto, Coleta ou Romaneio).");
    }
    else if ( $("idmotorista").value == '0'){
      alert ("Informe o motorista corretamente.");
      $("motor_nome").style.background ="#FFE8E8";
    }
    else if ( $("veiculo_id").value == '0'){
      alert ("Informe o veículo corretamente.");
      $("veiculo").style.background ="#FFE8E8";
    }else if ( pagamentos == null){
      alert ("Informe os pagamentos do contrato de frete corretamente.");
    }else if ( isChequeVazio == true){
        alert ("Informe o número do cheque corretamente.");
        return false;
    }else if (check()){
    	if ( <%=!cfg.isSalvaCartaSemManifesto()%> && (parseFloat($('vlliquido').value) > parseFloat($('freteTotal').value))){
                if (<%=!cfg.isPermiteContratoMaiorCtrc()%>){
                   alert('O contrato de frete não poderá ser salvo. O valor do contrato de frete é maior que o valor dos CTRCs!');
  		   return null;
                }
      		if (!confirm("O valor do contrato de frete é maior que o valor dos CTRCs, deseja continuar?")){
      			return null;
      		}
    	}
        for (var i = 0;i <= indexNotes;i++){
            if ($('idfornecedor'+i) != null){
                if ($('idfornecedor'+i).value == "0"){
                    return alert("Informe o fornecedor da despesa.");
                }
                if(parseFloat($('valorNota'+i).value) == 0){
                    return alert("Informe o valor das apropriações corretamente.");
                }
            }
        }
        

        habilitaSalvar(false);
    
    $("pagamentos").value = pagamentos;
    
    
    $("manifestos").value = verificaManifs(qtdLinhas);
    $("qtdApp").value = indexApp;
    $("qtdNotas").value = indexNotes;
    
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").target = "pop";
                        $("formulario").submit();
        
        /*
         acao += "&id=" + $("idcartafrete").value;

        requisitaPost("acao="+ acao + "&" +
                                  "manifs="+verificaManifs(qtdLinhas)+
                                  "&idfilial="+$("idfilial").value+
                                  "&data="+$("data").value+
                                  "&vldependentes="+$("vldependentes").value+
                                  "&vlbaseir="+$("vlbaseir").value+
                                  "&aliqir="+$("aliqir").value+
                                  "&vlir="+$("vlir").value+
                                  "&vlinssjaretido="+$("vlinssjaretido").value+
                                  "&vlretidoempresas="+$("vlretidoempresas").value+
                                  "&vlbaseinss="+$("vlbaseinss").value+
                                  "&aliqinss="+$("aliqinss").value+
                                  "&vlinss="+$("vlinss").value+
                                  "&vlbasesestsenat="+$("vlbasesestsenat").value+
                                  "&aliqsestsenat="+$("aliqsestsenat").value+
                                  "&vlsestsenat="+$("vlsestsenat").value+
                                  "&vlfretemotorista="+$("vlfretecontrato").value+
                                  "&rota="+$("rota").value+
                                  "&vloutros="+$("vloutros").value+
                                  "&vlpedagio="+$("vlpedagio").value+
                                  "&obsoutros="+$("obsoutros").value+
                                  "&vlimpostos="+$("vlimpostos").value+
                                  "&vlavaria="+$("vlavaria").value+
                                  "&vlliquido="+$("vlliquido").value+
                                  "&vloutrasretencoes="+$("vloutrasretencoes").value+
                                  "&idveiculo="+$("idveiculo").value+
                                  "&idproprietarioveiculo="+$('idproprietarioveiculo').value+
                                  "&plano_proprietario="+$('plano_proprietario').value+
                                  "&und_proprietario="+$('und_proprietario').value+
                                  "&idcarreta="+$("idcarreta").value+
                                  "&idmotorista="+$("idmotorista").value+
                                  "&motor_nome="+$("motor_nome").value+
                                  "&idagente="+$("idagente").value+
                                  "&valorTonelada="+$("valorTonelada").value+
                                  "&cancelada="+$("cancelada").checked+
                                  "&reterImpostos="+$("chkReterImpostos").checked+
                                  "&observacao="+$("obscartafrete").value+
                                  "&pagamentos="+pagamentos, "./cadcartafrete");
                              */

    }else
	   alert("Preencha os campos corretamente!");
  }

/*
  function excluibaixa(){
  // O parametro 'aosalvar' receberá 0 para salvar e sair ou 1 para salvar e incluir outro
       if (confirm("Deseja mesmo excluir a baixa do saldo dessa carta frete?")){
          requisitaPost("acao=excluibaixa&id=<%//=(carregacarta ? carta.getIdcartafrete() : 0)%>"+
                                  "&aosalvar="+$("cbacao").value, "./cadcartafrete");
       }
  }
*/

  function localizaagente(){
      if ($("fpagadiantamento").value != 8){
	    $("fpagadiantamento").value = 8;
	  }	
  	    post_cad = window.open('./localiza?acao=consultar&idlista=16','Agente',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function limpaAgente(){
    if (getObj("fpagadiantamento").value != 8){
      getObj("idagente").value=0;
      getObj("agente").value='';  
    }  
  }

  function localizaagentesaldo(){
      if ($("fpagsaldo").value != 8){
	    $("fpagsaldo").value = 8;
	  }	
  	    post_cad = window.open('./localiza?acao=consultar&idlista=19','Agente',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function limpaAgenteSaldo(){
    if (getObj("fpagsaldo").value != 8){
      getObj("idagentesaldo").value=0;
      getObj("agentesaldo").value='';  
    }  
  }
  
  function localizafilial(){
      post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function excluircartafrete(idcartafrete){
    if (confirm("Deseja mesmo excluir este contrato de frete?")){
        location.replace("./consultacartafrete?acao=excluir&id="+idcartafrete);
    }
  }

  function calculaInss(){
    /*var teto,retLanc,jaRetido,retEmpresas;
    teto = %=tetoInss%>;
    retLanc = parseFloat($("vlbaseinss").value) * parseFloat($("aliqinss").value) / 100;
    jaRetido = parseFloat($("vlinssjaretido").value) + parseFloat($("vlretidoempresas").value);
    //Se o valor ja retido for maior ou igual ao teto então retornará 0
    if (jaRetido >= teto)
      $("vlinss").value = formatoMoeda(0);
    //Se a soma do vl do inss do lançamento com o valor ja retido o retorno será o valor do lançamento - a soma - o teto.
    //ou seja, retornará apenas o que falta para atingir o teto.
    else if(retLanc + jaRetido >= teto)
      $("vlinss").value = formatoMoeda(retLanc - (retLanc + jaRetido - teto));    
    else
      $("vlinss").value = formatoMoeda(retLanc);*/
  }

  function calculaSest(){
    $("vlsestsenat").value = formatoMoeda(parseFloat($("vlbasesestsenat").value) * parseFloat($("aliqsestsenat").value) / 100);
  }
  
  function validaRota(altRota){
      
      var id = $("rota").value;

      <% if(carta != null && (carta.getRotas() == null || carta.getRotas().size() != 0)){%>               
        if(id != "0" ){
            var vlfretecontrato = parseFloat($("vlfretecontrato").value);
      
            var valorComPeso = ((parseFloat($("pesoTotalRota").value)/1000.0)*parseFloat($("rotaValor_"+id).value));
      
            var valorComFixo = parseFloat($("rotaValorMaximo_"+id).value);

            var valorComComissao = (parseFloat($("freteTotal").value) * parseFloat($("rotaValor_"+id).value)/100);
      
           if($("rotaTipoValor_"+id).value == "p"){               
      
               if (altRota || vlfretecontrato > valorComPeso){
                    $("vlfretecontrato").value = formatoMoeda(valorComPeso);   
               }
           }
           if($("rotaTipoValor_"+id).value == "f"){
      
               if (altRota || vlfretecontrato > valorComFixo){
                    $("vlfretecontrato").value = formatoMoeda(valorComFixo);     
               }
           }
           if($("rotaTipoValor_"+id).value == "c" ){               
      
               if(altRota || vlfretecontrato > valorComComissao){
                    $("vlfretecontrato").value = formatoMoeda(valorComComissao);     
               }
           }
        }
      <%}%>
  }

  function calcula(calculaAdiant,altRota){  // Calculará o total dos impostos total líquido e o saldo restante

    validaRota(altRota);
    
    var teto,retLanc,jaRetido,retEmpresas;
    var idxAdiant = pagtoLivre('a');
    var idxSaldo = pagtoLivre('s');
    var vlLiquido = parseFloat(colocarPonto($("vlliquido").value));
    var vls;
    var vlCC;
    
       
    //Total dos impostos
    $("vlimpostos").value = formatoMoeda(parseFloat($("vlir").value)+parseFloat($("vlinss").value)+parseFloat($("vlsestsenat").value));
    //Total Liquido
    $("vlliquido").value = formatoMoeda(parseFloat($("vlfretecontrato").value) + parseFloat($("vloutros").value) + parseFloat($("vlpedagio").value) + parseFloat($("vldiaria").value) + parseFloat($("vldescarga").value) - parseFloat($("vlimpostos").value) - parseFloat($("vloutrasretencoes").value) - parseFloat($("vlavaria").value));
    if ($("vlliquido").value == $("vlfretecontrato").value){
        //calculaAdiant = false;
    }
    
    
    
    //Valor Adiantamento
    if (calculaAdiant && idxAdiant != null){
   
	    $('valorPagto'+idxAdiant).value = formatoMoeda(parseFloat($('perc_adiant').value) / 100 * parseFloat($('vlliquido').value));
          
    }
    //Saldo restante
    if (idxSaldo != null && idxAdiant != null){
       
    	var vlSaldo = formatoMoeda(parseFloat($("vlliquido").value) - parseFloat($('valorPagto'+idxAdiant).value));   
     
        if (parseFloat($('debito_prop').value) > 0 && parseFloat($('percentual_desconto_prop').value) > 0 ){
                var percentual_desconto = parseFloat($('percentual_desconto_prop').value);
                vlCC = (vlSaldo == 0 ? 0 : parseFloat(parseFloat(percentual_desconto) * parseFloat(vlSaldo) / 100 ));
               
                if (parseFloat(vlCC) > parseFloat($('debito_prop').value)){
                    vlCC = $('debito_prop').value;
                }
                           
        }
      
         if(vlCC!=undefined){
             $("valorPagto"+ idxSaldo).value =  formatoMoeda(roundABNT(vlSaldo-vlCC, 2), 2);
             if (parseFloat(vlCC) > 0) {
                 visivel($("trCartaCC"));
                 $('cartaValorCC').value = formatoMoeda(vlCC, 2);
                 $('cartaDataCC').value = $("dataPagto"+ idxSaldo).value;
             }else{
                 invisivel($("trCartaCC"));
             }
         }else{                   
                    $("valorPagto"+ idxSaldo).value = formatoMoeda(vlSaldo, 2);
         }         
    }        
  }
  

  function popCarta(id){
     if (id == null)
	    return null;
     launchPDF('./consultacartafrete?acao=exportar&modelo=saldo&id='+id, 'carta'+id);
  }

  function mudouValor(acao,qtdLinhas){
      habilitaSalvar(false);
    if (qtdLinhas != '0'){
	  carrega(verificaManifs(qtdLinhas),qtdLinhas,acao,false);
    }
      habilitaSalvar(true);
  }

  function verDesp(id){
    if (<%=nivelUserDespesa >= 1%>){
    	window.open("./caddespesa?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes,status=1,scrollbars=1");
    }else{
    	alert('Você não tem acesso a tela de despesa, favor entrar em contato com o seu supervisor.');
    }	
  }
  
function verVeiculo(tipo){
         var mostrar = false;
         var idVeiculo = 0;
         if (tipo == 'V' && $('veiculo_id').value != '0'){
            idVeiculo = $('veiculo_id').value;
            mostrar = true;
         }else if (tipo == 'C' && $('idcarreta').value != '0'){
            idVeiculo = $('idcarreta').value;
            mostrar = true;
         }
                 
         if (mostrar)
            window.open('./cadveiculo?acao=editar&id=' + idVeiculo ,'Veículo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
}

function verMotorista(){
         var mostrar = false;
         var idMotorista = 0;
         if ($('idmotorista').value != '0'){
            idMotorista = $('idmotorista').value;
            mostrar = true;
         }
                 
         if (mostrar)
            window.open('./cadmotorista?acao=editar&id=' + idMotorista ,'Motorista','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
}
function localizarMotorista(){
    window.open('./localiza?acao=consultar&paramaux=carta&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
}

function aoCarregar(){
   var contaCC;
   var contaCfg;
   var tipoAdt;
   
   
   reterImpostos();
   <%if (!acao.equals("editar")){%>
       calculaIr();
       calculaInss();
       calculaSest();
    
   
    addPagto(0,'a', <%=(carta!=null && carta.getVlFreteMotorista()!=0? (valorAdiantamentoCarreteiro != 0 ? valorAdiantamentoCarreteiro : 0/*carta.getVlliquido() * percAdiantamentoMotorista / 100*/ ):0)%>, $('data').value, <%=cfg.getFpag().getIdFPag()%>, '', 0, '', 0, true, 0, false, 0, false, 0, '', '', '', 1, 't', 0,'');
       addPagto(0,'s', <%=(carta!=null && carta.getVlFreteMotorista()!=0? (valorSaldoCarreteiro != 0 ? valorSaldoCarreteiro : 0 /*carta.getVlliquido() * (100 - percAdiantamentoMotorista) / 100*/ ) :0)%>, $('data').value, <%=cfg.getFpag().getIdFPag()%>, '', 0, '', 0, true, 0, false, 0, false, 0, '', '', '', 1, 't', 0,'');
      calcula(true,false);
   <%}else{
	   int pp = 0;
          
       for (pp = 0; pp <= carta.getPagamento().length - 1; ++pp){ %>    
       contaCC = <%= carta.getPagamento()[pp].getConta().getIdConta()%>;
       contaCfg = <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%>;

      if(contaCfg != 0 && contaCC !=0 && contaCC == contaCfg && <%=carta.getPagamento()[pp].getValor()%> > 0 && '<%=carta.getPagamento()[pp].getTipoPagamento()%>' == 'a'){
            $('cartaValorCC').value = formatoMoeda(<%=carta.getPagamento()[pp].getValor()%>);
            $('cartaDataCC').value = '<%=new SimpleDateFormat("dd/MM/yyyy").format(carta.getPagamento()[pp].getData())%>';
      }else{ 
           
    	   addPagto(<%=carta.getPagamento()[pp].getId()%> ,'<%=carta.getPagamento()[pp].getTipoPagamento()%>',
    	   <%=carta.getPagamento()[pp].getValor()%>, '<%=new SimpleDateFormat("dd/MM/yyyy").format(carta.getPagamento()[pp].getData())%>',
    	   <%=carta.getPagamento()[pp].getFpag().getIdFPag()%>, '<%=carta.getPagamento()[pp].getDocumento()%>',
    	   <%=carta.getPagamento()[pp].getAgente().getIdfornecedor()%>, '<%=carta.getPagamento()[pp].getAgente().getRazaosocial()%>',
    	   <%=carta.getPagamento()[pp].getDespesa().getIdmovimento()%>, true, <%=carta.getPagamento()[pp].getPercAbastecimento()%>,
    	   <%=carta.getPagamento()[pp].isBaixado()%>, <%=carta.getPagamento()[pp].getConta().getIdConta()%>,
           <%=carta.getPagamento()[pp].isSaldoAutorizado()%>, <%=carta.getPagamento()[pp].getAgente().getPlanoCustoPadrao().getIdconta()%>,
           '<%=carta.getPagamento()[pp].getContaBancaria()%>', '<%=carta.getPagamento()[pp].getAgenciaBancaria()%>', '<%=carta.getPagamento()[pp].getFavorecido()%>', 
           <%=carta.getPagamento()[pp].getBanco().getIdBanco()%>, '<%=carta.getPagamento()[pp].getTipoFavorecido()%>',
           <%=carta.getPagamento()[pp].getAgente().getUnidadeCusto().getId()%>,'<%=carta.getPagamento()[pp].getDespesa().getNfiscal()%>');
       }
       if (parseFloat($('cartaValorCC').value) > 0){
          visivel($("trCartaCC"));
       }else{
          invisivel($("trCartaCC"));
       }    
       <%}
           
       BeanDespesa d = new BeanDespesa();
       BeanApropDespesa ap = new BeanApropDespesa();
       for (int x = 0; x < carta.getDespesa().length; x++) {
                    d = carta.getDespesa()[x];%>
                                addNotes(<%=d.getIdmovimento()%>,'<%=(d.isAVista() ? 'a' : 'p')%>','<%=d.getEsp().getId()%>', '<%=d.getSerie()%>', '<%=d.getNfiscal()%>', '<%=fmt.format(d.getDtEmissao())%>','<%=fmt.format(d.getDuplicatas()[0].getDtvenc())%>',<%=d.getFornecedor().getIdfornecedor()%>,'<%=d.getCompetencia()%>',<%=d.getHistorico().getIdhistorico()%>,'<%=d.getDescHistorico()%>',<%=d.getValor()%>,'<%=d.getDuplicatas()[0].getMovBanco().getDocum()%>', <%=d.getDuplicatas()[0].getMovBanco().getConta().getIdConta()%>);
            <%for (int y = 0; y < carta.getDespesa()[x].getApropriacoes().length; y++) {
                  ap = carta.getDespesa()[x].getApropriacoes()[y];%>
                              addApropriacao(indexNotes - 1, <%=ap.getPlanocusto().getIdconta()%>, '<%=ap.getPlanocusto().getConta()%>', '<%=ap.getPlanocusto().getDescricao()%>', <%=ap.getVeiculo().getIdveiculo()%>, '<%=ap.getVeiculo().getPlaca()%>', <%=ap.getValor()%>, false, <%=ap.getUndCusto().getId()%>, '<%=ap.getUndCusto().getSigla()%>');
            <%}
        }
   }%>
}

function calculaSaldo(index){
    var idxSaldo = 0;
    var totalAdt = 0;
	for (i = 0; i < indexPagto; ++i){
    	if ($("tipoPagto"+i).value == 'a'){
		  totalAdt += parseFloat($("valorPagto"+i).value);
		}else{
		  if ($('baixado'+i).value != 'true')
			  idxSaldo = i;
		}
	}
	if (idxSaldo!=0 && $("tipoPagto"+index).value == 'a')
		$('valorPagto'+idxSaldo).value = formatoMoeda(parseFloat($('vlliquido').value)-parseFloat(totalAdt));
}

function baixar(idx){
    var despesa = $("nFiscal_"+idx).value;
    
          tryRequestToServer(function(){window.open("./bxcontaspagar?acao=consultar&"+
            "idfornecedor="+$('idfornecedor').value+"&fornecedor="+$('fornecedor').value+"&"+
   		    "dtinicial="+dataAtual+"&dtfinal="+dataAtual+"&baixado=false"+"&idfilial="+$('idfilial').value+"&"+
  		    "fi_abreviatura="+$('fi_abreviatura').value+"&mostrarSaldo=true"+"&nf="+despesa+"&valor1=0.00&valor2=0.00&tipoData=dtvenc", "Despesa" , "top=8,resizable=yes,status=1,scrollbars=1")});
}

function addPagto(id, tipo, valor, data, fpag, doc, agente_id, agente, despesa_id, fixo, percAbastec, baixado, contaId, saldoAutorizado, planoAgente, contaAd, agenciaAd, favorecidoAd, bancoAd, tipoFavorecido, undAgente, nfiscal){
    
    _tr = Builder.node('TR', {id:'trPagto'+indexPagto, className:'CelulaZebra2'},
                      [Builder.node('TD',{colSpan:'2'}, 
                                   [Builder.node('SELECT', {name:'tipoPagto'+indexPagto, id:'tipoPagto'+indexPagto, className:'fieldMin', onChange:'alteraFpag('+indexPagto+');verFpag('+indexPagto+')'},
                                        [Builder.node('OPTION', {value:'a'}, 'Adiantamento'),
                                          Builder.node('OPTION', {value:'s'}, 'Saldo')
                                        ]),
                                   Builder.node('INPUT', {type:'hidden', name:'idPagto'+indexPagto, id:'idPagto'+indexPagto, 
                                      value:id}),
                                   ]),
                      Builder.node('TD', 
                                   [Builder.node('INPUT', {type:'text', name:'valorPagto'+indexPagto, id:'valorPagto'+indexPagto, 
                                    size:'8', maxLength:'12', value:formatoMoeda(valor), className:'fieldMin',
	                                onchange:'seNaoFloatReset($(\'valorPagto'+indexPagto+'\'), \'0.00\');calculaSaldo('+indexPagto+');'})
                                   ]),
                      Builder.node('TD', 
                                   [Builder.node('INPUT', {type:'text', name:'dataPagto'+indexPagto, id:'dataPagto'+indexPagto,
                                    size:'12', maxLength:'10', value:data, className:'fieldMin', 
                                    onBlur:'alertInvalidDate($(\'dataPagto'+indexPagto+'\'));',
                                    onKeyDown:'fmtDate($(\'dataPagto'+indexPagto+'\') , event);',                                    
                                    onKeyUp:'fmtDate($(\'dataPagto'+indexPagto+'\') , event);',                      
                                    onKeyPress:'fmtDate($(\'dataPagto'+indexPagto+'\') , event);'})
                                   ]),
                      Builder.node('TD', 
                                   [Builder.node('SELECT', {name:'fpagPagto'+indexPagto, id:'fpagPagto'+indexPagto, className:'fieldMin', onChange:'alteraFpag('+indexPagto+');verFpag('+indexPagto+');'},
										<%fpag.MostrarTudoCartaFrete(String.valueOf(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe()));
                						ResultSet rs = fpag.getResultado();%>
                						[
	            						<%while (rs.next()) {%>
	                                          Builder.node('OPTION', {value:'<%=rs.getString("idfpag")%>'}, '<%=rs.getString("descfpag")%>'),
										<%}	                  
                						rs.close();%>
                                        ])
                                   ]),
                      Builder.node('TD',  
                                   [Builder.node('INPUT', {type:'text', name:'docPagto'+indexPagto, id:'docPagto'+indexPagto, 
                                    size:'8', maxLength:'10', value:doc, className:'fieldMin'})
                                   ],
                                   [Builder.node('SELECT', {name:'docPagto_cb'+indexPagto, id:'docPagto_cb'+indexPagto, className:'fieldMin',onChange:'alteraFpag('+indexPagto+');'},
                                       [
                                       Builder.node('OPTION', {value:doc}, doc)
                                       ]
                                    )
                                   ]
                                 ),
                      Builder.node('TD', 
                                   [Builder.node('INPUT', {type:'hidden', name:'idAgente'+indexPagto, id:'idAgente'+indexPagto, 
                                      value:agente_id}),
                                    Builder.node('INPUT', {type:'hidden', name:'percAbastec'+indexPagto, id:'percAbastec'+indexPagto, 
                                      value:percAbastec}),
                                    Builder.node('INPUT', {type:'hidden', name:'planoAgente'+indexPagto, id:'planoAgente'+indexPagto,
                                      value:planoAgente}),
                                    Builder.node('INPUT', {type:'hidden', name:'undAgente'+indexPagto, id:'undAgente'+indexPagto,
                                      value:undAgente}),
                                    Builder.node('LABEL', {name:'lbFavorecidoAd'+indexPagto, id:'lbFavorecidoAd'+indexPagto},'Favorecido:'),
                                    Builder.node('SELECT', {name:'tipoFavorecido'+indexPagto, id:'tipoFavorecido'+indexPagto, className:'fieldMin', onChange:'alteraTipoFavorecido('+indexPagto+');'},
                                        [Builder.node('OPTION', {value:'t'}, 'Terceiro'),
                                         Builder.node('OPTION', {value:'m'}, 'Motorista'),
                                         Builder.node('OPTION', {value:'p'}, 'Proprietário')
                                        ]),
                                    Builder.node('BR',{name:'br1'+indexPagto, id:'br1'+indexPagto}),
                                    Builder.node('INPUT', {type:'text', name:'favorecidoAd'+indexPagto, id:'favorecidoAd'+indexPagto, className:'fieldMin',
                                      value:favorecidoAd, size:'32', maxLength:'50'}),
                                    Builder.node('BR',{name:'br2'+indexPagto, id:'br2'+indexPagto}),
                                    Builder.node('LABEL', {name:'lbContaAd'+indexPagto, id:'lbContaAd'+indexPagto},'Conta:'),
                                    Builder.node('INPUT', {type:'text', name:'contaAd'+indexPagto, id:'contaAd'+indexPagto, className:'fieldMin',
                                      value:contaAd, size:'10', maxLength:'15'}),
                                    Builder.node('LABEL', {name:'lbAgenciaAd'+indexPagto, id:'lbAgenciaAd'+indexPagto},' Ag:'),
                                    Builder.node('INPUT', {type:'text', name:'agenciaAd'+indexPagto, id:'agenciaAd'+indexPagto, className:'fieldMin',
                                      value:agenciaAd, size:'6', maxLength:'15'}),
                                    Builder.node('BR',{name:'br3'+indexPagto, id:'br3'+indexPagto}),
                                    Builder.node('LABEL', {name:'lbBancoAd'+indexPagto, id:'lbBancoAd'+indexPagto},' Banco:'),
                                    Builder.node('SELECT', {name:'bancoAd'+indexPagto, id:'bancoAd'+indexPagto, className:'fieldMin'},
										<%bancoAd.MostrarTudo();
                						ResultSet rsB = bancoAd.getResultado();%>
                						[
	            						<%while (rsB.next()) {%>
	                                          Builder.node('OPTION', {value:'<%=rsB.getString("idbanco")%>'}, '<%=rsB.getString("numero") + "-" + rsB.getString("descricao")%>'),
										<%}
                						rsB.close();%>
                                        ]),
                                    Builder.node('INPUT', {type:'text', name:'agente'+indexPagto, id:'agente'+indexPagto, 
                                      size:'21', maxLength:'80', value:agente, className:'inputReadOnly8pt'}),
                                    Builder.node('INPUT', {type:'button', name:'localizaAgente_'+indexPagto, id:'localizaAgente_'+indexPagto, 
                                      value:'...', className:'botoes',
                                      onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=16\',\'Agente_'+indexPagto+'\');'}),
                                    Builder.node('IMG', {name:'limpaAgente_'+indexPagto, id:'limpaAgente_'+indexPagto, src:'img/borracha.gif', title:'Limpar agente', className:'imagemLink', align:'absbottom', 
                                      onClick:'javascript:limparAgente('+indexPagto+');'}),
                                    Builder.node('SELECT', {name:'contaPagto'+indexPagto, id:'contaPagto'+indexPagto, className:'fieldMin', onChange:'verFpag('+indexPagto+');'},
										<%cta.mostraContas((nivelUserDespesaFilial>1?0:Apoio.getUsuario(request).getFilial().getIdfilial()),true, limitarUsuarioVisualizarConta, idUsuario);
                						ResultSet rsConta = cta.getResultado();%>
                						[
	            						<%while (rsConta.next()) {%>
	                                          Builder.node('OPTION', {value:'<%=rsConta.getString("idconta")%>'}, '<%=rsConta.getString("numero") +"-"+ rsConta.getString("digito_conta") +" / "+ rsConta.getString("banco")%>'),
										<%}	                  
                						rsConta.close();%>]),
                                   ]),
                      Builder.node('TD', 
                                   [Builder.node('DIV', {align:'center'},
	                                   [Builder.node('LABEL', {name:'idDespesa'+indexPagto, id:'idDespesa'+indexPagto, value:despesa_id, className:'linkEditar',
                                                          onClick:'javascript:verDesp('+despesa_id+');'}),
	                                    Builder.node('INPUT', {type:'hidden', name:'despesa'+indexPagto, id:'despesa'+indexPagto, 
    	                                  value:despesa_id}),
	                                    Builder.node('INPUT', {type:'hidden', name:'nFiscal_'+indexPagto, id:'nFiscal_'+indexPagto,
    	                                  value: nfiscal}),
	                                    Builder.node('INPUT', {type:'hidden', name:'baixado'+indexPagto, id:'baixado'+indexPagto,
    	                                  value:baixado}),
	                                    Builder.node('INPUT', {type:'hidden', name:'saldoAutorizado'+indexPagto, id:'saldoAutorizado'+indexPagto,
    	                                  value:saldoAutorizado})
                                       ])
                                   ]),
                      Builder.node('TD', 
                                   [Builder.node('DIV', {align:'center'},
	                                   [Builder.node('LABEL', {name:'status'+indexPagto, id:'status'+indexPagto})
                                       ])
                                   ]),
                      Builder.node('TD',{id:"td_img_"+indexPagto})]);

    var  _imgLixo = Builder.node('IMG', {src:'img/lixo.png', title:'Excluir Pagamento', className:'imagemLink', onClick:'excluirPagto('+indexPagto+');'});
    var  _imgBaixa = Builder.node('IMG', {id:"imgBaixa_"+indexPagto,src:'img/baixar.gif', title:'Baixar este '+(tipo=="a"?"Adiantamento":"Saldo"), className:'imagemLink',onClick:'baixar('+indexPagto+');'});

    
    $('pagtoCarta').appendChild(_tr);
    $('tipoPagto'+indexPagto).value = tipo;
    $('fpagPagto'+indexPagto).value = fpag;
    $('contaPagto'+indexPagto).value = (contaId == 0 ? $('contaPagto'+indexPagto).value : contaId);
    $('contaPagto'+indexPagto).style.width = '180px';
    $('tipoFavorecido'+indexPagto).value = tipoFavorecido;
    $('tipoFavorecido'+indexPagto).style.width = '100px';
    $('bancoAd'+indexPagto).value = bancoAd;
    $('bancoAd'+indexPagto).style.width = '140px';
    $('agente'+indexPagto).readOnly = true;

    if(!fixo){
        $("td_img_"+indexPagto).appendChild(_imgLixo);
    }else if(!baixado && fpag!=8 && despesa_id!= 0 &&  nivelBxDespesaViagem==4){
        $("td_img_"+indexPagto).appendChild(_imgBaixa);
    }
    
    
    $('idDespesa'+indexPagto).innerHTML = (despesa_id == 0 ? '' : despesa_id);

    alteraFpag(indexPagto);
    verFpag(indexPagto);

    if (fixo){
       $('tipoPagto'+indexPagto).disabled = true;
    }
    if ($('baixado'+indexPagto).value == 'true' || $('saldoAutorizado'+indexPagto).value == 'true'){
        $('valorPagto'+indexPagto).disabled = true;
    	$('valorPagto'+indexPagto).style.backgroundColor = '#FFFFF1';
	$('fpagPagto'+indexPagto).disabled = true;
	$('contaPagto'+indexPagto).disabled = true;
	$('docPagto'+indexPagto).disabled = true;
    	$('docPagto'+indexPagto).style.backgroundColor = '#FFFFF1';
	$('docPagto'+indexPagto).style.display = "";
	$('docPagto_cb'+indexPagto).disabled = true;
    	$('docPagto_cb'+indexPagto).style.backgroundColor = '#FFFFF1';
	$('docPagto_cb'+indexPagto).style.display = "none";
	$('docPagto_cb'+indexPagto).disabled = true;
	$('localizaAgente_'+indexPagto).disabled = true;
	$('limpaAgente_'+indexPagto).style.display = 'none';
	$('dataPagto'+indexPagto).disabled = true;
    	$('dataPagto'+indexPagto).style.backgroundColor = '#FFFFF1';
	$('status'+indexPagto).innerHTML = ($('baixado'+indexPagto).value == 'true'?'Baixado':'Autorizado');
    }else{
	if (despesa_id != 0){
		$('status'+indexPagto).innerHTML = 'Em aberto';
	}	
    }
    indexPagto++;
}


function verFpag(vIndexPagto){

    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    $('docPagto_cb'+vIndexPagto).style.display = "none";
    $('docPagto'+vIndexPagto).style.display = "";

    if ($("tipoPagto"+vIndexPagto).value == "a" && $("fpagPagto"+vIndexPagto).value == "3"){


    <%if(cfg.isControlarTalonario()){%>

    function e(transport){
        var textoresposta = transport.responseText;


        //se deu algum erro na requisicao...
        if (textoresposta == "-1"){
            alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
            return false;
        }else{
            if (<%=!carregacarta%>) {
                removeOptionSelected("docPagto_cb"+vIndexPagto);
            }
            <%if(cfg.isControlarTalonario()){%>
                //var lista = JSON.parse(textoresposta);
                var lista = jQuery.parseJSON(textoresposta);
                var listCheque = lista.list[0].documento;
                var documento;
                var isPrimeiro = true;
                var slct = $("docPagto_cb"+vIndexPagto);

                var valor = "";
                var selectValue = $('docPagto_cb'+vIndexPagto).value;
                removeOptionSelected("docPagto_cb"+vIndexPagto);

                slct.appendChild(Builder.node('OPTION', {value:valor}, valor));
                

                if (selectValue != null && selectValue != undefined && selectValue != "") {
                //Adicionando o valor do parametro ao valor da consulta do ajax para que ele fique em primeiro
                    valor = selectValue;
                    slct.appendChild(Builder.node('OPTION', {value: selectValue}, selectValue));
                    isPrimeiro = false;
                }
                var length = (listCheque.length == undefined ? 1 : listCheque.length);

                for(var i = 0; i < length; i++){
                    if(length > 1){
                        documento = listCheque[i];
                    }else{
                        documento = listCheque;
                    }
                    
                    valor += (isPrimeiro ? documento :"");

                    if(documento != null && documento != undefined){
                        slct.appendChild(Builder.node('OPTION', {value: documento}, documento));
                    }
                    isPrimeiro = false;
                }

                slct.value = valor;
            <%}%>
        }
    }//funcao e()


    $('docPagto_cb'+vIndexPagto).style.display = "";
    $('docPagto'+vIndexPagto).style.display = "none";

        tryRequestToServer(function(){
            new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaPagto'+vIndexPagto).value,{method:'post', onSuccess: e, onError: e});
        });

  <%}%>
      }
}

function verDocDesp(vIndexPagto){
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    $('docDespCarta_cb_'+vIndexPagto).style.display = "none";
    $('docDespCarta_'+vIndexPagto).style.display = "";

    if ($("tipoDesp"+vIndexPagto).value == "a" && $("isCheque_"+vIndexPagto).checked){


    <%if(cfg.isControlarTalonario()){%>

    function e(transport){
        var textoresposta = transport.responseText;

        //se deu algum erro na requisicao...
        if (textoresposta == "-1"){
            alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
            return false;
        }else{
            <%if(cfg.isControlarTalonario()){%>
                //var lista = JSON.parse(textoresposta);
                var lista = jQuery.parseJSON(textoresposta);
                var listCheque = lista.list[0].documento;
                var documento;
                var isPrimeiro = true;
                var slct = $("docDespCarta_cb_"+vIndexPagto);
                

                //removeOptionSelected("docDespCarta_cb_"+vIndexPagto);

                slct.appendChild(Builder.node('OPTION', {value:""}, "-----"));
//                slct.appendChild(Builder.node('OPTION', {value:valor}, valor));
                var length = (listCheque.length == undefined ? 1 : listCheque.length);
                valor = "";
                for(var i = 0; i < length; i++){
                    if(length > 1){
                        documento = listCheque[i];
                    }else{
                        documento = listCheque;
                    }
                    valor += (isPrimeiro ? documento :"");

                    if(documento != null && documento != undefined){
                        slct.appendChild(Builder.node('OPTION', {value: documento}, documento));
                    }
                    isPrimeiro = false;
                }

                slct.value = valor;
            <%}%>
        }
    }//funcao e()


    $('docDespCarta_cb_'+vIndexPagto).style.display = "";
    $('docDespCarta_'+vIndexPagto).style.display = "none";

        tryRequestToServer(function(){
            new Ajax.Request("TalaoChequeControlador?acao=proxCheque&setor=o&idConta="+$('contaDespesa_'+vIndexPagto).value,{method:'post', onSuccess: e, onError: e});
        });

  <%}%>
      }
}

function removeOptionSelected(id){
    var elSel = $(id);

    for (var i = elSel.length - 1; i>=0; i--) {
        elSel.remove(i);
    }
}


function excluirPagto(idx){
   if (confirm("Deseja mesmo excluir este pagamento do contrato de frete?")){
		Element.remove('trPagto'+idx);
   }
}

function aoClicarNoLocaliza(idjanela){
	//localizando fornecedor
    if(idjanela.split('_')[0] == 'Fornecedor'){
        $('fornecedor'+idjanela.split('_')[1]).value = $('fornecedor').value;
        $('idfornecedor'+idjanela.split('_')[1]).value = $('idfornecedor').value;
        $('historicoNota'+idjanela.split('_')[1]).value = $('descricao_historico').value;
        if ($('idplcustopadrao').value != '0'){
            addApropriacao(idjanela.split('_')[1], $('idplcustopadrao').value, $('contaplcusto').value, $('descricaoplcusto').value, $('veiculo_id').value, $('veiculo').value, 0, true, $('id_und_forn').value, $('sigla_und_forn').value);
        }
    }else if(idjanela.split('_')[0] == 'Historico'){
        $('historicoNota'+idjanela.split('_')[1]).value = $('descricao_historico').value;
        $('idhistoricoNota'+idjanela.split('_')[1]).value = $('idhist').value;
    }else if(idjanela.split('_')[0] == 'Agente'){
		$('agente'+idjanela.split('_')[1]).value = $('agente').value; 
		$('idAgente'+idjanela.split('_')[1]).value = $('idagente').value; 
		$('planoAgente'+idjanela.split('_')[1]).value = $('plano_agente').value;
		$('undAgente'+idjanela.split('_')[1]).value = $('und_agente').value;
	}else if(idjanela.split('_')[0] == 'Plano'){
            if (idjanela.split('_')[2] == null){
                addApropriacao(idjanela.split('_')[1], $('idplanocusto_despesa').value, $('plcusto_conta_despesa').value, $('plcusto_descricao_despesa').value, $('veiculo_id').value, $('veiculo').value, 0, true, 0, '');
            }else{
                $('idApropriacao_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('idplanocusto_despesa').value;
                $('conta_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('plcusto_conta_despesa').value;
                $('apropriacao_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('plcusto_descricao_despesa').value;
            }
        }else if(idjanela.split('_')[0] == 'Veiculo'){
            if (idjanela.split('_')[1] == null){
                $('veiculo_id').value = $('idveiculo').value;
                $('veiculo').value = $('vei_placa').value;
            }else{
                $('idVeiculo_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('idveiculo').value;
                $('veiculo_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('vei_placa').value;
            }
        }else if(idjanela.split('_')[0] == 'Und'){
            $('idUnd_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('id_und').value;
            $('und_'+idjanela.split('_')[1]+'_'+idjanela.split('_')[2]).value = $('sigla_und').value;
        }else if(idjanela.split('_')[0] == 'Motorista'){
            $('veiculo_id').value = $('idveiculo').value;
            $('veiculo').value = $('vei_placa').value;
        }
}

function limparAgente(index){
	$('agente'+index).value = ''; 
	$('idAgente'+index).value = '0'; 
}

function concatPagtos(){
	var pg = "";
	var total = 0;
        var docPagto = "";
        isChequeVazio = false;
        for (i = 0; i < indexPagto; ++i){
	   if ($("idPagto"+i) != null && parseFloat($("valorPagto"+i).value) >= 0){
               docPagto = $("docPagto"+i).value;
                    if ($("tipoPagto"+i).value == "a" && $("fpagPagto"+i).value == "3"){
                        <%if(cfg.isControlarTalonario()){%>
                            if ($("baixado"+i).value != true && $("baixado"+i).value != 't' && $("baixado"+i).value != 'true'){
                                docPagto = $("docPagto_cb"+i).value;
                            }
                        <%}%>
                        if (docPagto == "" && <%=cfg.isBaixaAdiantamentoCartaFrete()%>){
                            isChequeVazio = true;
                        }
                    }
               
                pg += $("idPagto"+i).value+"!-"+
                      $("tipoPagto"+i).value+"!-"+
                      $("valorPagto"+i).value+"!-"+
                      $("dataPagto"+i).value+"!-"+
                      $("fpagPagto"+i).value+"!-"+
                      docPagto+"!-"+
                      $("idAgente"+i).value+"!-"+
                      $("percAbastec"+i).value+"!-"+
                      $("despesa"+i).value+"!-"+
                      $("baixado"+i).value+"!-"+
                      $('contaPagto'+i).value+"!-"+
//                      ($('contaPagto'+i).value == ''?0:$('contaPagto'+i).value)+"!-"+
                      $("saldoAutorizado"+i).value+"!-"+
                      $("planoAgente"+i).value+"!-"+
                      $("tipoFavorecido"+i).value+"!-"+
                      $("contaAd"+i).value+"!-"+
                      $("agenciaAd"+i).value+"!-"+
                      $("favorecidoAd"+i).value+"!-"+
                      $("bancoAd"+i).value+"!-"+
                      $("undAgente"+i).value+"!-"+
                      (i == indexPagto - 1? "" : "!!");
              
                total += parseFloat($("valorPagto"+i).value);
	   }
	}
      
         total+=parseFloat($("cartaValorCC").value);
             

	if (formatoMoeda(total) != formatoMoeda($('vlliquido').value)){
           
		return null;
	}else{
    	return pg;
    }
}








function getTotalAdt(){
    var totalAdt = 0;
    for (i = 0; i < indexPagto; ++i){
       if ($("idPagto"+i) != null && parseFloat($("valorPagto"+i).value) >= 0){
          if ($("tipoPagto"+i).value == "a"){
             totalAdt += parseFloat($("valorPagto"+i).value);
          }
       }
    }
    return parseFloat(totalAdt);
}


function pagtoLivre(tipo){
    for (i = 0; i < indexPagto; ++i){
	   if ($("idPagto"+i) != null && $("tipoPagto"+i).value == tipo && $("despesa"+i).value == '0'){
			return i;
	   }
	}
	return null;
}

function alteraFpag(idx){
    $('contaPagto'+idx).style.display = 'none';
    $('agente'+idx).style.display = 'none';
    $('localizaAgente_'+idx).style.display = 'none';
    $('limpaAgente_'+idx).style.display = 'none';
    $('lbContaAd'+idx).style.display = 'none';
    $('contaAd'+idx).style.display = 'none';
    $('lbAgenciaAd'+idx).style.display = 'none';
    $('agenciaAd'+idx).style.display = 'none';
    $('br1'+idx).style.display = 'none';
    $('br2'+idx).style.display = 'none';
    $('br3'+idx).style.display = 'none';
    $('tipoFavorecido'+idx).style.display = 'none';
    $('lbFavorecidoAd'+idx).style.display = 'none';
    $('favorecidoAd'+idx).style.display = 'none';
    $('lbBancoAd'+idx).style.display = 'none';
    $('bancoAd'+idx).style.display = 'none';
    
    if ($('tipoPagto'+idx).value == 'a' && <%=cfg.isBaixaAdiantamentoCartaFrete()%> && 
       ($('fpagPagto'+idx).value == 2 || $('fpagPagto'+idx).value == 3 || $('fpagPagto'+idx).value ==4 || $('fpagPagto'+idx).value ==10)){
            $('contaPagto'+idx).style.display = '';
            $('tipoFavorecido'+idx).style.display = '';
            $('lbFavorecidoAd'+idx).style.display = '';
            $('favorecidoAd'+idx).style.display = '';
            $('br1'+idx).style.display = '';
            $('br2'+idx).style.display = '';
    }else
        if ($('fpagPagto'+idx).value == '8'){
            $('agente'+idx).style.display = '';
            $('localizaAgente_'+idx).style.display = '';
            $('limpaAgente_'+idx).style.display = '';
    }else
    if ($("fpagPagto"+idx).value == '3') {
        
        $("tipoFavorecido"+idx).style.display = '';
        $("agenciaAd"+idx).style.display = 'none';
        $("contaAd"+idx).style.display = 'none';
        $("favorecidoAd"+idx).style.display = '';
        $("bancoAd"+idx).style.display = 'none';
        $("lbFavorecidoAd"+idx).style.display = '';
        $("lbContaAd"+idx).style.display = 'none';
        $("lbAgenciaAd"+idx).style.display = 'none';
        $("lbBancoAd"+idx).style.display = 'none';
        $("contaPagto"+idx).style.display = 'none';
        $("br1"+idx).style.display = '';
        $("br2"+idx).style.display = '';
        $("br3"+idx).style.display = '';
        
    }else if ($('fpagPagto'+idx).value == '8'){
        $('agente'+idx).style.display = '';
        $('localizaAgente_'+idx).style.display = '';
        $('limpaAgente_'+idx).style.display = '';
        
    }
    else if ($("fpagPagto"+idx).value == '3') {
        
        $("tipoFavorecido"+idx).style.display = 'none';
        $("agenciaAd"+idx).style.display = 'none';
        $("contaAd"+idx).style.display = 'none';
        $("favorecidoAd"+idx).style.display = 'none';
        $("bancoAd"+idx).style.display = 'none';
        $("lbFavorecidoAd"+idx).style.display = 'none';
        $("lbContaAd"+idx).style.display = 'none';
        $("lbAgenciaAd"+idx).style.display = 'none';
        $("lbBancoAd"+idx).style.display = 'none';
        $("contaPagto"+idx).style.display = '';
        $("br1"+idx).style.display = '';
        $("br2"+idx).style.display = '';
        $("br3"+idx).style.display = '';
        
    }
    else{
        $('lbContaAd'+idx).style.display = '';
        $('contaAd'+idx).style.display = '';
        $('lbAgenciaAd'+idx).style.display = '';
        $('agenciaAd'+idx).style.display = '';
        $('br1'+idx).style.display = '';
        $('br2'+idx).style.display = '';
        $('br3'+idx).style.display = '';
        $('tipoFavorecido'+idx).style.display = '';
        $('lbFavorecidoAd'+idx).style.display = '';
        $('lbBancoAd'+idx).style.display = '';
        $('bancoAd'+idx).style.display = '';
        $('favorecidoAd'+idx).style.display = '';
//        $('contaPagto'+idx).style.display = '';

    }
}

function alteraTipoFavorecido(idx){
    var tipo = $('tipoFavorecido'+idx).value;
    if (tipo == 'm' && $('tipoPagto'+idx).value == 'a'){
        $('contaAd'+idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_conta1').value : $('motor_conta2').value);
        $('agenciaAd'+idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_agencia1').value : $('motor_agencia2').value);
        $('favorecidoAd'+idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_favorecido1').value : $('motor_favorecido2').value);
        $('bancoAd'+idx).value = ($('motor_conta1').value.trim() != '' ? $('motor_banco1').value : $('motor_banco2').value);
        if ($('favorecidoAd'+idx).value.trim() == ''){
            $('favorecidoAd'+idx).value = $('motor_nome').value;
        }
    }else if (tipo == 'm' && $('tipoPagto'+idx).value == 's'){
        $('contaAd'+idx).value = ($('motor_conta2').value != '' ? $('motor_conta2').value : $('motor_conta1').value);
        $('agenciaAd'+idx).value = ($('motor_conta2').value != '' ? $('motor_agencia2').value : $('motor_agencia1').value);
        $('favorecidoAd'+idx).value = ($('motor_conta2').value != '' ? $('motor_favorecido2').value : $('motor_favorecido1').value);
        $('bancoAd'+idx).value = ($('motor_conta2').value != '' ? $('motor_banco2').value : $('motor_banco1').value);
        if ($('favorecidoAd'+idx).value.trim() == ''){
            $('favorecidoAd'+idx).value = $('motor_nome').value;
        }
    }else if (tipo == 'p' && $('tipoPagto'+idx).value == 'a'){
        $('contaAd'+idx).value = ($('prop_conta1').value != '' ? $('prop_conta1').value : $('prop_conta2').value);
        $('agenciaAd'+idx).value = ($('prop_conta1').value != '' ? $('prop_agencia1').value : $('prop_agencia2').value);
        $('favorecidoAd'+idx).value = ($('prop_conta1').value != '' ? $('prop_favorecido1').value : $('prop_favorecido2').value);
        $('bancoAd'+idx).value = ($('prop_conta1').value != '' ? $('prop_banco1').value : $('prop_banco2').value);
        if ($('favorecidoAd'+idx).value.trim() == ''){
            $('favorecidoAd'+idx).value = $('vei_prop').value;
        }
    }else if (tipo == 'p' && $('tipoPagto'+idx).value == 's'){
        $('contaAd'+idx).value = ($('prop_conta2').value != '' ? $('prop_conta2').value : $('prop_conta1').value);
        $('agenciaAd'+idx).value = ($('prop_conta2').value != '' ? $('prop_agencia2').value : $('prop_agencia1').value);
        $('favorecidoAd'+idx).value = ($('prop_conta2').value != '' ? $('prop_favorecido2').value : $('prop_favorecido1').value);
        $('bancoAd'+idx).value = ($('prop_conta2').value != '' ? $('prop_banco2').value : $('prop_banco1').value);
        if ($('favorecidoAd'+idx).value.trim() == ''){
            $('favorecidoAd'+idx).value = $('vei_prop').value;
        }
    }else{
        $('contaAd'+idx).value = '';
        $('agenciaAd'+idx).value = '';
        $('favorecidoAd'+idx).value = '';
        $('bancoAd'+idx).value = '1';
    }
}
</script>
<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">
<META HTTP-EQUIV="Page-Enter" CONTENT = "RevealTrans (Duration=1, Transition=12)">

<title>WebTrans - Lançamento do Contrato de Frete</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {color: #990000}
.style3 {color: #EADEC8}
-->
</style>
</head>

<body onLoad="aoCarregar();">
<form method="post" action="./cadcartafrete" id="formulario" target="pop">     
<img src="img/banner.gif">
<br>
<!-- CAMPOS OCULTOS -->
<!-- FALTA O CODIGO DA FILIAL-->
<input type="hidden" name="acao" id="acao" value="<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>">
<input type="hidden" name="acaoanterior" id="acaoanterior" value="<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>">
<input type="hidden" name="calculaFrete" id="calculaFrete" value="">
<input type="hidden" name="pagamentos" id="pagamentos" value="">
<input type="hidden" name="manifestos" id="manifestos" value="">
<input type="hidden" name="plano_agente" id="plano_agente" value="0">
<input type="hidden" name="idagente" id="idagente" value="0">
<input type="hidden" name="id_und_forn" id="id_und_forn" value="0">
<input type="hidden" name="sigla_und_forn" id="sigla_und_forn" value="0">
<input type="hidden" name="und_agente" id="und_agente" value="0">
<input type="hidden" name="agente" id="agente" value="">
<input type="hidden" name="percabadiant" id="percabadiant" value="0">
<input type="hidden" name="idfilial" id="idfilial" value="<%=(carregacarta?carta.getFilial().getIdfilial():Apoio.getUsuario(request).getFilial().getIdfilial())%>">
<input type="hidden" name="idmotorista" id="idmotorista" value="<%=(carregacarta?carta.getMotorista().getIdmotorista():0)%>">
<input type="hidden" name="perc_adiant" id="perc_adiant" value="<%=(carregacarta?carta.getPercentualAdiantamento():0)%>">
<input type="hidden" name="idproprietarioveiculo" id="idproprietarioveiculo" value="<%=(carregacarta?carta.getContratado().getIdfornecedor():0)%>">
<input type="hidden" name="idveiculo" id="idveiculo" value="<%=(carregacarta?carta.getVeiculo().getIdveiculo():0)%>">
<input type="hidden" name="veiculo_id" id="veiculo_id" value="<%=(carregacarta?carta.getVeiculo().getIdveiculo():0)%>">
<input type="hidden" name="vei_placa" id="vei_placa" value="<%=(carregacarta?carta.getVeiculo().getPlaca():"")%>">
<input type="hidden" name="idcarreta" id="idcarreta" value="<%=(carregacarta?carta.getCarreta().getIdveiculo():0)%>">
<input type="hidden" id="idhist" value="0">
<input type="hidden" name="idcarreta" id="idcarreta" value="<%=(carregacarta?carta.getCarreta().getIdveiculo():0)%>">
<input type="hidden" id="idfornecedor" value="0">
                <input type="hidden" id="fornecedor" value="">
                <input type="hidden" id="contaplcusto" value="">
                <input type="hidden" id="descricaoplcusto" value="">
<input type="hidden" id="idplcustopadrao" value="0">
<input type="hidden" id="descricao_historico" value="">
<input type="hidden" id="idplanocusto_despesa">
<input type="hidden" id="plcusto_conta_despesa">
<input type="hidden" id="plcusto_descricao_despesa">
                <input type="hidden" id="id_und">
                <input type="hidden" id="sigla_und">
                <input type="hidden" id="idContaAdiant" value="<%=cfg.getConta_adiantamento_viagem_id().getIdConta()%>">
                <input type="hidden" id="qtdApp" name="qtdApp" value="0">
                <input type="hidden" id="qtdNotas" name="qtdNotas" value="0">

                

<!--addApropriacao(idjanela.split('_')[1], $('idplanocusto_despesa').value, $('plcusto_conta_despesa').value, $('plcusto_descricao_despesa').value, $('veiculo_id').value, $('veiculo').value, 0, true, 0, '');-->
<!-- FIM -->
<table width="83%" align="center" class="bordaFina">
  <tr >
    <td width="570"><div align="left"><b>Contrato de Frete</b></div> </td>
    <% if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null) && (podeExcluirOutraFl)) //se o paramentro vier com valor entao nao pode excluir
	{%>
	   <td width="59"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:excluircartafrete(<%=(carregacarta ? carta.getIdcartafrete() : 0)%>)"></td>
	<%}%>
    <td width="55" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
  </tr>
</table>
<br>
<table width="83%" border="0" cellpadding="0" cellspacing="0" class="bordaFina" align="center">
  <tr> 
    <td height="18" colspan="4" class="tabela"> <div align="center"><font size="2">Dados 
        principais</font></div></td>
  </tr>
  <tr> 
    <td height="43" colspan="4"> <table width="100%" border="0" cellpadding="0" cellspacing="1">
        <tr> 
          <td width="16%" height="22" class="TextoCampos">N&ordm; Contrato de frete<font size="1">:</font></td>
          <td width="10%" class="CelulaZebra2">
              <input name="idcartafrete" type="text" id="idcartafrete" class="fieldMin" value="<%=(carregacarta?String.valueOf(carta.getIdcartafrete()):cadcarta.getProximaCartaFrete())%>" size="10" <%=(acao.equals("editar")?"readonly":"") %>>
          </td>
          <td width="8%" height="10" class="TextoCampos">CIOT:</td>
          <td width="18%" class="CelulaZebra2">
              <input type="text"  size="13" maxlength="15" name="ciot" id="ciot"  onkeypress="mascara(this, soNumeros)" value="<%=(carregacarta && carta.getCiot() != 0 ? carta.getCiot(): 0) %>" class="<%= nivelCiot >= 4 ? "fieldMin" : "inputReadOnly8pt" %>" <%=(nivelCiot < 4 ?"readonly":"") %>/>
              /<input type="text"  size="4" maxlength="6" name="ciotCodVerificador" id="ciotCodVerificador" onkeypress="mascara(this,soNumeros)" value="<%=(carregacarta && carta.getCiotCodVerificador() != 0 ? carta.getCiotCodVerificador(): 0 )%>"  class="<%= nivelCiot >= 4 ? "fieldMin" : "inputReadOnly8pt" %>" <%=(nivelCiot < 4 ?"readonly":"") %>/>
          </td>
          <td width="4%" class="TextoCampos">Filial:</td>
          <td width="18%" class="CelulaZebra2"><input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getFilial().getAbreviatura():Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="15"
                                               readonly> 
            <%if (Apoio.getUsuario(request).getAcesso("lancartafl") >= 3 && acao.equals("iniciar"))
          {%>
            <input name="localiza_filial" type="button" class="botoes" id="localiza_filial2" value="..." onClick="javascript:localizafilial();"> 
          <%}%>        
          </td>
          <td width="4%" class="TextoCampos">Data:</td>
          <td width="10%" class="CelulaZebra2"> <input name="data" type="text" id="data" class="fieldDate" value="<%=(carregacarta && carta.getData() != null ?formato.format(carta.getData()):Apoio.getDataAtual())%>" size="10" maxlength="10"
		  onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" /></td>
          <td width="20%" class="CelulaZebra2"><label>
            <div align="center">
              <input name="cancelada" type="checkbox" id="cancelada" value="checkbox" <%=(carregacarta && carta.isCancelada() ? "checked" : "")%>>
              Cancelada</div>
          </label></td>
        </tr>
        <tr> 
          <td height="18" colspan="9" class="tabela"> <div align="center"><font size="2"><strong>Documentos 
          desse contrato de frete (Contrato de Frete) </strong></font></div></td>
        </tr>
      </table></td>
  </tr>
  <tr> 
    <td colspan="4"> <table width="100%" border="0">
        <tr class="Celula"> 
          <td width="27%"><div align="center">Documento n&ordm;</div></td>
          <td width="23%"><div align="center">Cidade/UF Origem</div></td>
          <td width="23%"><div align="center">Cidade/UF Destino</div></td>
          <td width="9%"><div align="center">Data</div></td>
          <td width="9%"><div align="center">Peso</div></td>
          <td width="9%"><div align="center">Frete</div></td>
        </tr>
        <%
        if (carregacarta)
        {
            freteTotal = 0;
          //Percorrendo o vetor
          for (linha = 0; linha <= carta.getBeanmanif().length - 1; ++linha)
          {
            //pega o resto da divisao e testa se é par ou impar
            %>
            
            
		<script>$('perc_adiant').value = <%=carta.getPercentualAdiantamento()%>;</script>
                        
        <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") %>" > 
          <td><div align="center"> 
              <input name="<%="linha-" + linha %>" id="<%="linha-" + linha %>" type="hidden" value="<%=carta.getBeanmanif()[linha].getIdmanifesto()%>">
                    
              <font size="1">
                 <%String tipo = carta.getBeanmanif()[linha].getTipo();
                 if (tipo.equals("MANIFESTO")){
                     if (nivelManifesto > 0){
                     %>
                        <label onClick="window.open('./cadmanifesto?acao=editar&id=<%=carta.getBeanmanif()[linha].getIdmanifesto()%>&ex=false', 'Manifesto' , 'top=0,resizable=yes,status=1,scrollbars=1');" class="linkEditar">
                            <%=tipo + ": " + carta.getBeanmanif()[linha].getNmanifesto()%>
                        </label>
                     <%}else{%>
                        <label>
                            <%=tipo + ": " + carta.getBeanmanif()[linha].getNmanifesto()%>
                        </label>
                     <%}%>
                 <%}else if(tipo.equals("COLETA")){
                     if (nivelColeta > 0){
                     %>
                        <label onClick="window.open('./cadcoleta.jsp?acao=editar&id=<%=carta.getBeanmanif()[linha].getIdmanifesto()%>&ex=false', 'Coleta' , 'top=0,resizable=yes,status=1,scrollbars=1');" class="linkEditar">
                            <%=tipo + ": " + carta.getBeanmanif()[linha].getNmanifesto()%>
                        </label>
                     <%}else{%>
                        <label>
                            <%=tipo + ": " + carta.getBeanmanif()[linha].getNmanifesto()%>
                        </label>
                     <%}%>
                 <%}else if(tipo.equals("ROMANEIO")){
                     if (nivelRomaneio > 0){
                     %>
                        <label onClick="window.open('./cadromaneio.jsp?acao=editar&id=<%=carta.getBeanmanif()[linha].getIdmanifesto()%>&ex=false', 'Romaneio' , 'top=0,resizable=yes,status=1,scrollbars=1');" class="linkEditar">
                            <%=tipo + ": " + carta.getBeanmanif()[linha].getNmanifesto()%>
                        </label>
                     <%}else{%>
                        <label>
                            <%=tipo + ": " + carta.getBeanmanif()[linha].getNmanifesto()%>
                        </label>
                     <%}%>
                 <%}%>
              </font></div>
              
              <input type="hidden" name="tipo-<%=linha%>" id="tipo-<%=linha%>" value="<%=carta.getBeanmanif()[linha].getTipo()%>">
              <input type="hidden" name="numero-<%=linha%>" id="numero-<%=linha%>" value="<%=carta.getBeanmanif()[linha].getNmanifesto()%>">
              <input type="hidden" name="idcidadeorigem-<%=linha%>" id="idcidadeorigem-<%=linha%>" value="<%=carta.getBeanmanif()[linha].getCidadeorigem().getIdcidade()%>">
              <input type="hidden" name="idcidadedestino-<%=linha%>" id="idcidadedestino-<%=linha%>" value="<%=carta.getBeanmanif()[linha].getCidadedestino().getIdcidade()%>">
            
          </td>
          <td><div align="center"><font size="1"><%=carta.getBeanmanif()[linha].getCidadeorigem().getCidade()%></font></div></td>
          <td><div align="center"><font size="1"><%=carta.getBeanmanif()[linha].getCidadedestino().getCidade()%></font></div></td>
          <td><div align="center"><font size="1"><%=(carta.getBeanmanif()[linha].getDtsaida()!=null?formato.format(carta.getBeanmanif()[linha].getDtsaida()):"")%></font></div></td>
          <td><div align="right"><font size="1"><%=Apoio.to_curr(carta.getBeanmanif()[linha].getTotalPeso())%></font></div></td>
          <td><div align="right"><font size="1"><%=Apoio.to_curr(carta.getBeanmanif()[linha].getTotalPrestacao())%></font></div></td>
          <%pesoTotal += carta.getBeanmanif()[linha].getTotalPeso();%>
          <%freteTotal += carta.getBeanmanif()[linha].getTotalPrestacao();%>
        </tr>
        <%
          }//For
        }
        
        if ((nivelUser >= 2) && (podeAlterarOutraFl)){
        %>
        <tr class="TextoCampos"> 
          <td height="22" colspan="4"> <div align="left"> 
              <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar documentos" onClick="javascript:selecionar_manifesto('<%=linha%>','<%=acao%>');">
              <input name="mostratudo" type="checkbox" id="mostratudo" value="checkbox">
              Mostrar, tamb&eacute;m, documentos dos ve&iacute;culos pr&oacute;prios</div></td>
              <td > <div align="right"> <font size="1">
                            <%=Apoio.to_curr(pesoTotal)%>
                            </font>
              </div></td>
          <td > 
              <div align="right"> <font size="1">
                            <%=Apoio.to_curr(freteTotal)%>
                            </font>
              </div>
          </td>
        </tr>
        <%}%>
      </table></td>
  </tr>
  <tr> 
    <td colspan="4"> <table width="100%" border="0">
        <tr class="Celula"> 
          <td colspan="8"><div align="center">Dados do motorista / ve&iacute;culo </div></td>
        </tr>
        <tr> 
          <td width="42" class="TextoCampos">Nome:</td>
          <td width="268" class="CelulaZebra2"><strong> 
            <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getMotorista().getNome():"")%>" size="30" readonly="true">
       
            <input name="localiza_filial222" type="button" class="botoes" id="localiza_filial222" value="..." onClick="localizarMotorista()">
            <strong><img src="img/page_edit.png" border="0"
						onClick="javascript:verMotorista();"
						  title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "></strong> </strong>
							<input type="hidden" name="motor_conta1" id="motor_conta1" value="<%=(carregacarta?carta.getMotorista().getConta1():"")%>">
							<input type="hidden" name="motor_agencia1" id="motor_agencia1" value="<%=(carregacarta?carta.getMotorista().getAgencia1():"")%>">
							<input type="hidden" name="motor_favorecido1" id="motor_favorecido1" value="<%=(carregacarta?carta.getMotorista().getFavorecido1():"")%>">
							<input type="hidden" name="motor_banco1" id="motor_banco1" value="<%=(carregacarta?carta.getMotorista().getBanco1().getIdBanco():"1")%>">
							<input type="hidden" name="motor_conta2" id="motor_conta2" value="<%=(carregacarta?carta.getMotorista().getConta2():"")%>">
							<input type="hidden" name="motor_agencia2" id="motor_agencia2" value="<%=(carregacarta?carta.getMotorista().getAgencia2():"")%>">
							<input type="hidden" name="motor_favorecido2" id="motor_favorecido2" value="<%=(carregacarta?carta.getMotorista().getFavorecido2():"")%>">
							<input type="hidden" name="motor_banco2" id="motor_banco2" value="<%=(carregacarta?carta.getMotorista().getBanco2().getIdBanco():"1")%>">
        						<input type="hidden" name="base_ir_prop_retido" id="base_ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
							<input type="hidden" name="ir_prop_retido" id="ir_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
							<input type="hidden" name="base_inss_prop_retido" id="base_inss_prop_retido" class="inputReadOnly8pt" size="20" readonly="true" value="0">
							<input type="hidden" name="inss_prop_retido" id="inss_prop_retido" value="0" size="10" class="inputtexto" />
                          </td>
                          
          <td width="34" class="TextoCampos">CPF:</td>
          <td width="62" class="CelulaZebra2"><strong> 
            <input name="motor_cpf" type="text" id="motor_cpf" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getMotorista().getCpf():"")%>" size="15" readonly="true">
          </strong></td>
          <td width="82" class="TextoCampos">Habilita&ccedil;&atilde;o:</td>
          <td width="66" class="CelulaZebra2"><strong> 
            <input name="motor_cnh" type="text" id="motor_cnh" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getMotorista().getCnh():"")%>" size="15" readonly="true">
          </strong></td>
          <td width="125" class="TextoCampos">R$ por tonelada: </td>
          <td width="30" class="CelulaZebra2"><strong>
            <input name="valorTonelada" type="text" id="valorTonelada" class="<%=(carregacarta ? "inputReadOnly" : "fieldMin")%>" value="<%=(carregacarta?Apoio.to_curr(carta.getValorTonelada()):"0.00")%>" onChange="javascript:seNaoFloatReset(this,'0.00');calculaPeso();calcula(true,false);mudouValor('<%=(acao.equals("iniciar") ? "iniciar":"editar")%>','<%=linha%>');" size="5" align="right">
          </strong></td>
        </tr>
        <tr>
          <td colspan="8"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
            <tr>
              <td width="17%" class="TextoCampos">Ve&iacute;culo / Cavalo:</td>
              <td width="21%" class="CelulaZebra2"><strong><strong>
                <input name="veiculo" type="text" id="veiculo" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getVeiculo().getPlaca():"")%>" size="9" readonly="true">
                <input name="localiza_filial2" type="button" class="botoes" id="localiza_filial" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.VEICULO%>', 'Veiculo')">
                <strong><img src="img/page_edit.png" border="0"
						onClick="javascript:verVeiculo('V');"
						  title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "></strong></strong></strong></td>
              <td width="12%" class="TextoCampos">Contratado:</td>
              <td width="24%" class="CelulaZebra2"><strong><strong>
                <input name="vei_prop" type="text" id="vei_prop" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getContratado().getRazaosocial():"")%>" size="40" readonly="true">
                <input name="plano_proprietario" type="hidden" id="plano_proprietario" style="font-size:8pt;background-color:#FFFFF1" size="40" readonly="true" value="<%=(carregacarta?carta.getContratado().getPlanoCustoPadrao().getIdconta():"0")%>">
                <input name="und_proprietario" type="hidden" id="und_proprietario" style="font-size:8pt;background-color:#FFFFF1" size="40" readonly="true" value="<%=(carregacarta?carta.getContratado().getUnidadeCusto().getId():"0")%>">
                <input type="hidden" name="prop_conta1" id="prop_conta1" value="<%=(carregacarta?carta.getContratado().getContaBancaria():"")%>">
		<input type="hidden" name="prop_agencia1" id="prop_agencia1" value="<%=(carregacarta?carta.getContratado().getAgenciaBancaria():"")%>">
		<input type="hidden" name="prop_favorecido1" id="prop_favorecido1" value="<%=(carregacarta?carta.getContratado().getFavorecido():"")%>">
		<input type="hidden" name="prop_banco1" id="prop_banco1" value="<%=(carregacarta?carta.getContratado().getBanco().getIdBanco():"1")%>">
		<input type="hidden" name="prop_conta2" id="prop_conta2" value="<%=(carregacarta?carta.getContratado().getContaBancaria2():"")%>">
		<input type="hidden" name="prop_agencia2" id="prop_agencia2" value="<%=(carregacarta?carta.getContratado().getAgenciaBancaria2():"")%>">
		<input type="hidden" name="prop_favorecido2" id="prop_favorecido2" value="<%=(carregacarta?carta.getContratado().getFavorecido2():"")%>">
		<input type="hidden" name="prop_banco2" id="prop_banco2" value="<%=(carregacarta?carta.getContratado().getBanco2().getIdBanco():"1")%>">
                <input type="hidden" name="percentual_desconto_prop"  id="percentual_desconto_prop" value="<%=(carregacarta?carta.getContratado().getPercentualDescontoProp():"0")%>">
                <input type="hidden" name="debito_prop" id="debito_prop" value="<%=(carregacarta?carta.getContratado().getDebitoProp():"0")%>" >
              
              </strong></strong></td>
              <td width="10%" class="TextoCampos">CNPJ/CPF:</td>
              <td width="16%" class="CelulaZebra2"><strong><strong>
                <input name="vei_prop_cgc" type="text" id="vei_prop_cgc" class="inputReadOnly8pt" size="20" readonly="true" value="<%=(carregacarta?carta.getContratado().getCpfCnpj():"")%>">
              </strong></strong></td>
              </tr>
            <tr>
              <td class="TextoCampos">Carreta:</td>
              <td class="CelulaZebra2"><strong><strong>
                <input name="car_placa" type="text" id="car_placa" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getCarreta().getPlaca():"")%>" size="9" readonly="true">
              </strong>
                  <input name="localiza_filial22" type="button" class="botoes" id="localiza_filial22" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CARRETA%>', 'Carreta')">
                  <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" 
			     onClick="javascript:getObj('idcarreta').value = '0';javascript:getObj('car_placa').value = '';javascript:getObj('car_prop').value = '';"><strong><strong><img src="img/page_edit.png" border="0"
						onClick="javascript:verVeiculo('C');"
						  title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; "></strong></strong></strong></strong></td>
              <td class="TextoCampos">Propriet&aacute;rio:</td>
              <td class="CelulaZebra2"><strong><strong><strong><strong>
                <input name="car_prop" type="text" id="car_prop" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getCarreta().getProprietario().getRazaosocial():"")%>" size="40" readonly="true">
              </strong></strong></strong></strong></td>
              <td class="TextoCampos">CNPJ/CPF:</td>
              <td class="CelulaZebra2"><strong><strong><strong><strong>
                <input name="car_prop_cgc" type="text" id="car_prop_cgc" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getCarreta().getProprietario().getCpfCnpj():"")%>" size="20" readonly="true">
              </strong></strong></strong></strong></td>
              </tr>
          </table></td>
        </tr>
      </table></td>
  </tr>
  <tr class="tabela"> 
    <td height="16" colspan="7"> 
      <div align="center">C&aacute;lculos</div></td>
  </tr>
  <tr> 
    <td colspan="7"> 
      <table width="100%" border="0">
        <tr>
          <td colspan="17"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
            <tr>
              <td class="TextoCampos">Rota: </td>
              <td class="CelulaZebra2" colspan="7">
                                    <select name="rota" id="rota" class="fieldMin" onchange="javascript:calcula(true,true);mudouValor('<%=(acao.equals("iniciar") ? "iniciar":"editar")%>','<%=linha%>');">
                      <% if(carta == null || (carta != null && (carta.getRotas() == null || carta.getRotas().size() == 0)) || nivelAlterarFrete != 0){%>
                      <option value="0" selected> Não cadastrada </option>
                    <%}
                    if(carta != null && carta.getRotas() != null){
                    for(Rota rota : carta.getRotas()){
                        
    %>
                    
                        <option value="<%=rota.getId()%>" <%=((carta.getRota().getId() == 0 && nivelAlterarFrete == 0) || carta.getRota().getId() == rota.getId() ? "selected" : "")%>><%=rota.getDescricao()%></option>
                    <%} 
                                       }%>
                    </select>
                    <%
                    if(carta != null && carta.getRotas() != null){
                    for(Rota rota : carta.getRotas()){
                        for(TipoVeiculoRota tipoVeiculo : rota.getListaTipoVeiculo()){%>
                            <input name="rotaValor_<%=rota.getId()%>" type="hidden" id="rotaValor_<%=rota.getId()%>" value="<%=(carregacarta?vlrformat.format(tipoVeiculo.getValor()):"0.00")%>" >
                            <input name="rotaValorMaximo_<%=rota.getId()%>" type="hidden" id="rotaValorMaximo_<%=rota.getId()%>" value="<%=(carregacarta?vlrformat.format(tipoVeiculo.getValorMaximo()):"0.00")%>" >
                            <input name="rotaTipoValor_<%=rota.getId()%>" type="hidden" id="rotaTipoValor_<%=rota.getId()%>" value="<%=(carregacarta?tipoVeiculo.getTipoValor():"")%>">
                                    
            <% }
                        }
            } %>
            <input name="freteTotal" type="hidden" id="freteTotal" value="<%=(carregacarta?freteTotal:"0.0")%>">
            <input name="pesoTotalRota" type="hidden" id="pesoTotalRota" value="<%=(carregacarta?pesoTotalRota:"0.0")%>">
            
              </td>
            </tr>
            <tr>
              <td width="11%" class="TextoCampos"><strong>Valor frete: </strong></td>
              <td width="12%" class="CelulaZebra2"><span class="CelulaZebra2">
                <input name="vlfretecontrato" type="text" id="vlfretecontrato" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" value="<%=(carregacarta?Apoio.to_curr(carta.getVlFreteMotorista()):"0.00")%>" onChange="javascript:seNaoFloatReset(this,'0.00');calcula(true,false);mudouValor('<%=(acao.equals("iniciar") ? "iniciar":"editar")%>','<%=linha%>');" size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
(+)            </span></td>
              <td width="16%" class="CelulaZebra2"><div align="center">
                    <input name="chkReterImpostos"  <%=(nivelImpostos == 4?"":"disabled")%> type="checkbox" id="chkReterImpostos" value="checkbox" onClick="javascript:reterImpostos();calcula(true,false);" <%=(carregacarta && carta.isReterImpostos() ? "checked" : "")%>>
                Reter impostos </div></td>
              <td width="12%" class="CelulaZebra2">&nbsp;</td>
              <td width="12%" class="CelulaZebra2">&nbsp;</td>
              <td width="12%" class="CelulaZebra2">&nbsp;</td>
              <td width="12%" class="CelulaZebra2">&nbsp;</td>
              <td width="13%" class="CelulaZebra2">&nbsp;</td>
            </tr>
            
            <tr name="tr_ir" id="tr_ir" style="display:none;">
              <td class="TextoCampos style1">IR:</td>
              <td class="CelulaZebra2"><strong>
                <input name="vlir" type="text" id="vlir" class="<%=(nivelImpostos == 4?"fieldMin":"inputReadOnly8pt")%>" value="<%=(carregacarta?vlrformat.format(carta.getVlir(calculaimpostos)):"0.00")%>"
                 onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" size="7" align="right" <%=(nivelImpostos == 4 ? "" : "readOnly")%>>
</strong><span class="style1">(-)</span> </td>
              <td colspan="6"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
                <tr>
                  <td width="43%" class="TextoCampos">Valor dependentes: </td>
                  <td width="9%" class="CelulaZebra2"><strong>
                    <input name="vldependentes" type="text" id="vldependentes" class="<%=(nivelImpostos == 4?"fieldMin":"inputReadOnly8pt")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calculaIr();javascript:calcula(true,false);" value="<%=(carregacarta?vlrformat.format(carta.getVldependentes(carta.getContratado().getQuantidadeDependentes(),calculaimpostos)):"0.00")%>" size="7" align="right" <%=(nivelImpostos == 4?"":"readOnly")%>>
                  </strong></td>
                  <td width="19%" class="TextoCampos">Base de c&aacute;lculo: </td>
                  <td width="6%" class="CelulaZebra2"><strong>
                    <input name="vlbaseir" type="text" id="vlbaseir" align="right" class="inputReadOnly8pt" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacarta?vlrformat.format(carta.getVlbaseir(calculaimpostos)):"0.00")%>" size="7"  readonly="true">
                  </strong></td>
                  <td width="15%" class="TextoCampos">Al&iacute;quota (%): </td>
                  <td width="8%" class="CelulaZebra2"><strong>
                    <input name="aliqir" type="text" id="aliqir" class="inputReadOnly8pt" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="<%=(carregacarta?vlrformat.format(carta.getAliqir(calculaimpostos)):"0.00")%>" size="7" readonly="true" align="right">
                  </strong></td>
                </tr>
              </table></td>
              </tr>
            <tr name="tr_inss" id="tr_inss" style="display:none;">
              <td class="TextoCampos style1">INSS:</td>
              <td class="CelulaZebra2"><input name="vlinss" type="text" id="vlinss" class="<%=(nivelImpostos == 4?"fieldMin":"inputReadOnly8pt")%>" value="<%=(carregacarta?vlrformat.format(carta.getVlinss(calculaimpostos)):"0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" size="7" align="right" <%=(nivelImpostos == 4 ? "" : "readOnly")%>>
                <span class="style1">(-)</span> </td>
              <td colspan="6"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
                <tr>
                  <td width="16%" class="TextoCampos">Retido m&ecirc;s: </td>
                  <td width="8%" class="CelulaZebra2"><strong>
                    <input name="vlinssjaretido" type="text" id="vlinssjaretido" class="inputReadOnly8pt" value="<%=(carregacarta?vlrformat.format(carta.getVlJaRetido()):"0.00")%>" size="7" readonly="true" align="right">
                  </strong></td>
                  <td width="19%" class="TextoCampos">Retido empresas: </td>
                  <td width="9%" class="CelulaZebra2"><strong>
                    <input name="vlretidoempresas" type="text" id="vlretidoempresas" class="fieldMin" value="<%=(carregacarta?vlrformat.format(carta.getVlOutrasEmpresas()):"0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calculaInss();javascript:calcula(true,false);" size="7" align="right">
                  </strong></td>
                  <td width="19%" class="TextoCampos">Base de c&aacute;lculo: </td>
                  <td width="6%" class="CelulaZebra2"><strong>
                    <input name="vlbaseinss" type="text" id="vlbaseinss" class="inputReadOnly8pt" onBlur="javascript:seNaoFloatReset(this,'0.00');" onChange="javascript:recalcula();" value="<%=(carregacarta?vlrformat.format(carta.getVlbaseinss(calculaimpostos)):"0.00")%>" size="7" readonly="true" align="right">
                  </strong></td>
                  <td width="15%" class="TextoCampos">Al&iacute;quota (%):</td>
                  <td width="8%" class="CelulaZebra2"><strong>
                    <input name="aliqinss" type="text" id="aliqinss" class="inputReadOnly8pt" onBlur="javascript:seNaoFloatReset(this,'0.00');" onChange="javascript:recalcula();" value="<%=(carregacarta?vlrformat.format(carta.getAliqinss(calculaimpostos)):"0.00")%>" size="7" readonly="true" align="right">
                  </strong></td>
                </tr>
              </table></td>
              </tr>
            <tr name="tr_sest" id="tr_sest" style="display:none;">
              <td class="TextoCampos style1">Sest/Senat:</td>
              <td class="CelulaZebra2"><strong>
                <input name="vlsestsenat" type="text" id="vlsestsenat" class="<%=(nivelImpostos == 4?"fieldMin":"inputReadOnly8pt")%>" value="<%=(carregacarta?vlrformat.format(carta.getVlsestsenat(calculaimpostos)):"0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" size="7" align="right" <%=(nivelImpostos == 4 ? "" : "readOnly")%>>
</strong><span class="style1">(-)</span>              </td>
              <td colspan="6"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
                <tr>
                  <td width="71%" class="TextoCampos">Base de c&aacute;lculo: </td>
                  <td width="6%" class="CelulaZebra2"><strong>
                    <input name="vlbasesestsenat" type="text" id="vlbasesestsenat" class="inputReadOnly8pt" onBlur="javascript:seNaoFloatReset(this,'0.00');" onChange="javascript:recalcula();" value="<%=(carregacarta?vlrformat.format(carta.getBaseSestSenat(calculaimpostos)):"0.00")%>" size="7" readonly="true" align="right">
                  </strong></td>
                  <td width="15%" class="TextoCampos">Al&iacute;quota (%): </td>
                  <td width="8%" class="CelulaZebra2"><strong>
                    <input name="aliqsestsenat" type="text" id="aliqsestsenat" class="inputReadOnly8pt" onBlur="javascript:seNaoFloatReset(this,'0.00');" onChange="javascript:recalcula();" value="<%=(carregacarta?vlrformat.format(carta.getAliqsestsenat(calculaimpostos)):"0.00")%>" size="7" readonly="true" align="right">
                  </strong></td>
                </tr>
              </table></td>
              </tr>
            <tr>
              <td class="TextoCampos style1">Outras ret.: </td>
              <td class="CelulaZebra2"><input name="vloutrasretencoes" type="text" id="vloutrasretencoes" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" value="<%=(carregacarta?vlrformat.format(carta.getVlOutrasDeducoes()):"0.00")%>" size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
                <span class="style1">(-)</span> <strong>
                <input name="vlimpostos" type="hidden" id="vlimpostos" style="font-size:8pt;background-color:#FFFFF1" value="<%=(carregacarta?vlrformat.format(carta.getVlImpostos()):"0.00")%>" size="5" readonly="true" align="right">
                </strong></td>
              <td class="TextoCampos style1">Avaria:</td>
              <td class="CelulaZebra2"><input name="vlavaria" type="text" id="vlavaria" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" value="<%=(carregacarta?vlrformat.format(carta.getVlAvaria()):"0.00")%>" size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
                <span class="style1">(-) </span></td>
              <td class="CelulaZebra2">&nbsp;</td>
              <td class="CelulaZebra2">&nbsp;</td>
              <td class="CelulaZebra2">&nbsp;</td>
              <td class="CelulaZebra2">&nbsp;</td>
            </tr>
            <tr>
              <td class="TextoCampos">Outros:</td>
              <td class="CelulaZebra2"><strong>
                <input name="vloutros" type="text" id="vloutros" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" value="<%=(carregacarta?Apoio.to_curr(carta.getOutrosdescontos() + carta.getOutrosdescontossaldo()):"0.00")%>"  size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
 </strong>(+)             </td>
              <td class="TextoCampos">Descri&ccedil;&atilde;o outros: </td>
              <td colspan="5" class="CelulaZebra2"><input name="obsoutros" type="text" id="obsoutros" class="fieldMin" value="<%=(carregacarta?carta.getObsoutrosdescontos():"")%>" size="60" maxlength="60"></td>
            </tr>
            <tr>
              <td class="TextoCampos">Ped&aacute;gio:</td>
              <td class="CelulaZebra2"><strong>
                <input name="vlpedagio" type="text" id="vlpedagio" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" value="<%=(carregacarta?Apoio.to_curr(carta.getValorPedagio()):"0.00")%>"  size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
              </strong>(+)</td>
              <td class="TextoCampos">
                  Diária:
              </td>
              <td class="CelulaZebra2">
                  <input name="vldiaria" type="text" id="vldiaria" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" value="<%=(carregacarta?Apoio.to_curr(carta.getValorDiaria()):"0.00")%>"  size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
                  (+)
              </td>
              <td class="TextoCampos">
                  Descarga:
              </td>
              <td class="CelulaZebra2">
                  <input name="vldescarga" type="text" id="vldescarga" class="<%=(acao.equals("editar") && nivelAlteraValor != 4 ? "inputReadOnly8pt" : "fieldMin")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');javascript:calcula(true,false);" value="<%=(carregacarta?Apoio.to_curr(carta.getValorDescarga()):"0.00")%>"  size="7" align="right" <%=(acao.equals("editar") && nivelAlteraValor != 4 ? "readOnly" : "")%>>
                  (+)
              </td>
              <td class="CelulaZebra2"></td>
              <td class="CelulaZebra2"></td>
              </tr>
            <tr>
              <td class="TextoCampos"><strong>Valor L&iacute;quido: </strong></td>
              <td class="CelulaZebra2">
                <input name="vlliquido" type="text" id="vlliquido" class="inputReadOnly8pt" value="<%=(carregacarta?vlrformat.format(carta.getVlliquido()):"0.00")%>" size="7" readonly="true" align="right">
              (=)              </td>
              <td colspan="6" class="CelulaZebra2">&nbsp;</td>
              </tr>
          </table></td>
        </tr>
      </table></td>
  </tr>
  <tr class="tabela"> 
    <td height="16" colspan="7"> 
      <div align="center">Dados do pagamento do contrato de frete</div></td>
  </tr>
  <tr>
    <td height="16" colspan="7">
		<table width="100%" border="0">
          <tbody id="pagtoCarta">
      		<tr class="celula">
        		<td width="3%"><span class="CelulaZebra2"><img src="img/add.gif" border="0" class="imagemLink "
						title="Adicionar um novo Adiantamento" onClick="javascript:addPagto(0,'a', 0, $('data').value, <%=cfg.getFpag().getIdFPag()%>, '', 0, '', 0, false, 0, false, 0, false, 0, '', '', '', 1, 't', 0, '');"></span></td>
        		<td width="9%">Tipo</td>
      		    <td width="7%">Valor</td>
      		    <td width="10%">Data</td>
      		    <td width="16%">Forma Pagto </td>
      		    <td width="7%">Docum.</td>
      		    <td width="25%">Agente pagador<%=(cfg.isBaixaAdiantamentoCartaFrete()?"/Conta":"")%> </td>
      		    <td width="8%">Despesa</td>
      		    <td width="12%"><div align="center">Status</div></td>
      		    <td width="3%"></td>
      		</tr>
		  </tbody>
                  <tbody id="bodyContaCorrente"></tbody>
                                <tr name="trCartaCC" id="trCartaCC" style="display: ">
                                    <td class="TextoCampos" colspan="2"><div align="left">C/C.:</div></td>
                                    <td class="TextoCampos"><div align="left"><input name="cartaValorCC" type="text" id="cartaValorCC" value="0.00" size="8" maxlength="12" class="fieldMin" readonly></div></td>
                                    <td class="TextoCampos"><div align="left"><input name="cartaDataCC" type="text" id="cartaDataCC" value="" class="fieldMin" onChange="" size="12" maxlength="10" onkeydown="fmtDate(this);" onkeyup="fmtDate(this)" onkeypress="fmtDate(this)"></div></td>
                                    <td class="TextoCampos"><input name="cartaFPagCC" type="hidden" id="cartaFPagCC" value="2"></td>
                                    <td class="TextoCampos"><input name="contaCC" type="hidden" id="contaCC" value="<%=(cfg.getContaAdiantamentoFornecedor().getIdConta())%>"></td>
                                    <td class="CelulaZebra2"></td>
                                    <td class="CelulaZebra2"></td>
                                    <td class="CelulaZebra2"></td>
                                    <td class="CelulaZebra2"></td>
                                </tr>
    	</table>	</td>
  </tr>
  <tr class="tabela"> 
    <td height="16" colspan="7"> <div align="center">Outros</div></td>
  </tr>
  <tr> 
    <td width="17%" class="TextoCampos">Observação:</td>
    <td width="83%" colspan="3" class="CelulaZebra2"><textarea name="obscartafrete" cols="100" rows="3" id="obscartafrete" class="fieldMin"><%=(carregacarta?carta.getObservacao():"")%></textarea></td>
  </tr>
                  <tr>
                    <td colspan="7" class="tabela"><div align="center"><strong>Despesas dessa viagem</strong></div></td>
                </tr>
                <tr>
                    <td colspan="7"><table border="0" cellpadding="0" cellspacing="1" width="100%">
                            <tbody id="desp_notes">
                                <tr class="celula">
                                    <td width="2%" ><img src="img/add.gif" border="0" class="imagemLink "
                                                                             title="Adicionar uma nova Nota fiscal" onClick="javascript:addNotes(0,'','','','',$('data').value,$('data').value,0,'',0,'',0,'',0);"></td>
                                    <td width="8%" >Despesa</td>
                                    <td width="6%" >Espécie</td>
                                    <td width="4%" >Série</td>
                                    <td width="6%" >NF</td>
                                    <td width="9%" >Emissão</td>
                                    <td width="28%" >Fornecedor</td>
                                    <td width="28%" >Hist&oacute;rico</td>
                                    <td width="7%" >Valor</td>
                                    <td width="2%" ></td>
                                </tr>
                            </tbody>
                             
                        </table>                                    
                    </td>
                </tr>
  <%
  if (! acao.equals("iniciar")){%>
  <tr class="tabela">
    <td height="16" colspan="7"> <div align="center">Auditoria</div></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td colspan="7"> <table width="100%" border="0" cellspacing="1">
        <tr> 
          <td width="10%" height="24" class="TextoCampos">Inclu&iacute;do em:</td>
          <td width="10%" class="CelulaZebra2"><input name="dtlancamento" type="text" id="dtlancamento" class="inputReadOnly8pt" value="<%=(carregacarta && carta.getDtlancamento() != null?formato.format(carta.getDtlancamento()):"")%>" size="11" readonly="true"></td>
          <td width="5%" class="TextoCampos">Por:</td>
          <td width="20%" class="CelulaZebra2"><input name="usulancamento" type="text" id="usulancamento" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getUsuariolancamento().getNome():"")%>" size="25" readonly="true"></td>
          <td width="10%"class="TextoCampos">Alterado em:</td>
          <td width="10%"class="CelulaZebra2"><input name="dtalteracao" type="text" id="dtalteracao" class="inputReadOnly8pt" value="<%=(carregacarta && carta.getDtalteracao() != null?formato.format(carta.getDtalteracao()):"")%>" size="11" readonly="true"></td>
          <td width="5%"class="TextoCampos">Por:</td>
          <td width="20%" class="CelulaZebra2"><input name="usualteracao" type="text" id="usualteracao" class="inputReadOnly8pt" value="<%=(carregacarta?carta.getUsuarioalteracao().getNome():"")%>" size="25" readonly="true"></td>
        </tr>
      </table></td>
  </tr>
  <%}%>
  <tr class="CelulaZebra2"> 
    <td height="24" colspan="7"> <div align="center"> 
        <% if ((nivelUser >= 2) && (podeAlterarOutraFl) && nivelEdicao == 4){
        %>
        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=linha%>');});">
        <%}%>
      </div></td>
  </tr>
</table>
<br>
<script>
function calculaPeso(){  // Calculará o total dos impostos total líquido e o saldo restante
	$("vlfretecontrato").value = formatoMoeda(parseFloat(<%=pesoTotal / 1000%>) * parseFloat($("valorTonelada").value))
}
  function calculaIr(){
    var vlImposto,vlDep,baseIR;
/*    vlImposto = $("vlir").value;
    vlDep = $("vldependentes").value;
    baseIR = parseFloat($("vlbaseir").value);// - parseFloat($('vlinss').value);
    vlImposto = formatoMoeda(parseFloat(baseIR) * parseFloat($("aliqir").value) / 100);
    //$("vlbaseir").value = formatoMoeda(baseIR);
    if (parseFloat($("aliqir").value) > 0)
      vlImposto = formatoMoeda(parseFloat(vlImposto) - parseFloat(//carregacarta?carta.getDeduzirir((acao.equals("editar")?false:true)):0)));

    $("vlir").value = formatoMoeda(parseFloat(vlImposto));*/
  }
</script>
</form>
</body>
