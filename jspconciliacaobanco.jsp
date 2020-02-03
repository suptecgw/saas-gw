<%@page import="conhecimento.BeanConhecimento"%>
<%@page import="filial.BeanConsultaFilial"%>
<%@page import="filial.BeanFilial"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  nucleo.BeanLocaliza,          
                  mov_banco.conta.*,
                  mov_banco.*,
                  java.text.*,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script src="assets/js/jquery-1.9.1.min.js"></script>
<script src="${homePath}/script/funcoesTelaConciliacaoBancaria.js?v=${random.nextInt()}"></script>

<% 
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("conbancaria") : 0);
   int nivelUserFechamento = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("fechamentoconciliacao") : 0);
   int nivelUserFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
   int nivelUserConta = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);
   int nivelUserCtrc = (Apoio.getUsuario(request) != null
           ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
   int nivelUserSale = (Apoio.getUsuario(request) != null
    ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
   int nivelUserDespesa = (Apoio.getUsuario(request) != null ?
           Apoio.getUsuario(request).getAcesso("caddespesa") : 0);
   int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
           ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
   int nivelCopiaCheque = (Apoio.getUsuario(request) != null
           ? Apoio.getUsuario(request).getAcesso("impcopiacheque") : 0);
   
   boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
   int idUsuario = Apoio.getUsuario(request).getIdusuario();
   
   //testando se a sessao é válida e se o usuário tem acesso
   if (Apoio.getUsuario(request) == null || (nivelUser==0 && nivelCopiaCheque==0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  BeanConsultaMov_Banco movBanco = null;
  BeanCadMovBanco cadBanco = null;
  BeanMovBanco mBanco = null;
  
  BeanConfiguracao cfg = null;
  cfg = new BeanConfiguracao();
  cfg.setConexao(Apoio.getUsuario(request).getConexao());
  //Carregando as configurações
  cfg.CarregaConfig();
  if (!acao.equals("iniciar")){
      movBanco = new BeanConsultaMov_Banco();
      movBanco.setConexao( Apoio.getUsuario(request).getConexao() );
      cadBanco = new BeanCadMovBanco();
      cadBanco.setConexao( Apoio.getUsuario(request).getConexao() );
      cadBanco.setExecutor(Apoio.getUsuario(request));
      mBanco = new BeanMovBanco();
  }
  //exportacao da Cartafrete para arquivo .pdf
  if (acao.equals("consultar")){
      movBanco.setTipoData(request.getParameter("tipodata"));
      movBanco.setDtIni(formatador.parse(request.getParameter("dtinicial")));
      movBanco.setDtFim(formatador.parse(request.getParameter("dtfinal")));
      movBanco.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
      movBanco.setTipoLanc(request.getParameter("conciliado"));
      movBanco.setDoc(request.getParameter("doc"));
      movBanco.setDocDe(request.getParameter("docDe"));
      movBanco.setDocAte(request.getParameter("docAte"));
      movBanco.setTipoConsultaCheque(Integer.parseInt(request.getParameter("tipoConsultaCheque")==null?"0":request.getParameter("tipoConsultaCheque")));
      movBanco.setMotorista(Integer.parseInt(request.getParameter("idmotorista")));
      movBanco.setFornecedorContaId(Integer.parseInt(Apoio.coalesce(request.getParameter("idfornecedor"),"0")));
      movBanco.setCreditos(request.getParameter("creditos"));
      movBanco.setValor1(Double.parseDouble(request.getParameter("valor1")));
      movBanco.setValor2(Double.parseDouble(request.getParameter("valor2")));
      movBanco.setIdMotivo(Integer.parseInt(request.getParameter("idMotivo")==null?"0":request.getParameter("idMotivo")));
      movBanco.setChequeCancelado(Boolean.parseBoolean(request.getParameter("isChequeCancelado")));
      movBanco.setFilial(Integer.parseInt(request.getParameter("idfilial")==null?"0":request.getParameter("idfilial")));
      movBanco.getConta().setTipo_conta(request.getParameter("tipo"));
      movBanco.setUsuario(Apoio.getUsuario(request));
      movBanco.getHistorico().setIdHistorico(Apoio.parseInt(request.getParameter("idhist")));
      movBanco.getHistorico().setDescHistorico(request.getParameter("descricao_historico"));
      movBanco.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
      movBanco.getClienteRecebimento().setIdcliente(Apoio.parseInt(request.getParameter("idclienteRecebimento")));
      movBanco.getClienteRecebimento().setRazaosocial(request.getParameter("clienteRecebimento"));
      movBanco.getFornecedorPagamento().setRazaosocial(request.getParameter("fornecedorPagamento"));
      movBanco.getFornecedorPagamento().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedorPagamento")));
      movBanco.setConsiderarDataEntrada(Apoio.parseBoolean(request.getParameter("idfornecedorPagamento")));
      movBanco.setMostrarFiltros(Apoio.parseBoolean(request.getParameter("mostrarFiltros")));
      movBanco.setConsiderarDataEntrada(Apoio.parseBoolean(request.getParameter("considerarData")));
      if(request.getParameter("tipo_controle_conta_corrente").equals("s")){
          movBanco.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
      }
      
      boolean isConsultaBeneficiario = movBanco.getConta().getIdConta() == cfg.getConta_adiantamento_viagem_id().getIdConta() 
              && (Apoio.parseInt(request.getParameter("idFuncionario")) != 0 
                  || Apoio.parseInt(request.getParameter("idajudante"))  != 0 
                  || Apoio.parseInt(request.getParameter("idmotorista")) != 0  );
      if (isConsultaBeneficiario) {
          movBanco.setBeneficiarioViagem(BeneficiarioViagem.obterBeneficiarioPorTipo(request.getParameter("selectBeneficiario")));
          movBanco.getFuncionario().setIdfornecedor(Apoio.parseInt(request.getParameter("idFuncionario")));
          movBanco.getFuncionario().setRazaosocial(request.getParameter("nomeFuncionario"));
          movBanco.getAjudante().setIdfornecedor(Apoio.parseInt(request.getParameter("idajudante")));
          movBanco.getAjudante().setRazaosocial(request.getParameter("nome"));
      }
  }else if (acao.equals("salvar")){
      //Preenchendo o array dos mov_banco
      int qtdMovs = Integer.parseInt(request.getParameter("qtd"));
      BeanMovBanco[] arBanco = new BeanMovBanco[qtdMovs];
         
      for (int k = 0; k < qtdMovs; ++k){
         BeanMovBanco mb = new BeanMovBanco();
         mb.setIdLancamento(Integer.parseInt(request.getParameter("id_"+k)));
         mb.setDtEntrada(formatador.parse(request.getParameter("dtentrada_"+k)));
         mb.setConciliado(request.getParameter("conciliado_"+k).equals("t") ? true : false );
         arBanco[k] = mb;
      }
      
      cadBanco.setArrayBMovBanco(arBanco);

      boolean erroSalvar = !cadBanco.Atualiza();
    
      //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      if(erroSalvar) {
        response.getWriter().append("<script>alert('"+cadBanco.getErros()+"');</script>");
        response.getWriter().append("<script>window.opener.habilitaSalvar(true);window.close();</script>");
      }else{
	String scr = "";
	scr = "<script>";
	scr += "window.opener.document.location.replace(window.opener.document.location);"+
	"window.close();"+
	"</script>";
	response.getWriter().append(scr);
      }
    
     response.getWriter().close();
     
  }else if (acao.equals("excluir")){
    //como no beanmovbanco não esta validando o getctrc quando nulo e fazendo isso la ocasinava no erro na hora de gerar o adiantamento de viagem
    //achei melhor instanciar o objeto aqui para ter menos impacto. Daniel Cassimiro - Retorno da historia 2896
    BeanConhecimento beanCtrc = null;
    if (mBanco.getCtrc() == null) {
        beanCtrc = new BeanConhecimento();
    }
     mBanco.setCtrc(beanCtrc);
     mBanco.setIdLancamento(Integer.parseInt(request.getParameter("id")));
     mBanco.setTipo(request.getParameter("tipo"));
     mBanco.getCtrc().setId(Apoio.parseInt(request.getParameter("idCte")));
     mBanco.setIsCreditoViagemRetorno(Apoio.parseBoolean(request.getParameter("isCreditoViagemRetorno")));
     cadBanco.setBMovBanco(mBanco);

     boolean erroExcluir = !cadBanco.Deleta();
     //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
     if(erroExcluir) {
        response.getWriter().append("<script>alert('"+cadBanco.getErros()+"');window.close();</script>");
        //response.getWriter().append("<script>window.close();</script>");
    }else{
	String scr = "";
	       scr = "<script>";
	       scr += "window.opener.document.location.replace(window.opener.document.location);"+
	              "window.close();"+
	              "</script>";
	response.getWriter().append(scr); 
    }
    response.getWriter().close();
  
  }else if (acao.equals("exportar")){
      String condicao = "";
      String nomeRelatorio = "";
      String idLancamento = "";
      
      if (request.getParameter("idLancamento") != null && !request.getParameter("idLancamento").equals("")) {
          idLancamento = " and idlancamento = (" + request.getParameter("idLancamento") + ")";   
      }
      
      java.util.Map param = new java.util.HashMap(3);
      param.put("IDCONTA", request.getParameter("idconta"));
      param.put("CHEQUE", request.getParameter("docum"));
      param.put("DTENTRADA", "'" +new SimpleDateFormat("MM-dd-yyyy").format(Apoio.paraDate(request.getParameter("dtentrada")))+"'");
      param.put("USUARIO",Apoio.getUsuario(request).getNome());     
      param.put("CAMPOFILTRO",request.getParameter("CAMPOFILTRO"));
      request.setAttribute("map", param);
      
      if(request.getParameter("nome") != null){
          nomeRelatorio = request.getParameter("nome");
      }
      else{
          nomeRelatorio = "copiachequemod";
      }
      
      if (nomeRelatorio.equals("comprovantetransferenciamod")) {
          param.put("IDLANCAMENTO",request.getParameter("idLancamento"));
      }else{
          param.put("IDLANCAMENTO",idLancamento);
      }

      request.setAttribute("rel", ""+nomeRelatorio+request.getParameter("modelo"));
      
      RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
      dispatcher.forward(request, response);
      
  }else if (acao.equals("cancelarCheque")){
      mBanco.setIdLancamento(Integer.parseInt(request.getParameter("id")));
      cadBanco.setBMovBanco(mBanco);
      
      boolean erroCancelar = !cadBanco.CancelarCheque();
      
      if (erroCancelar) {
           response.getWriter().append("<script>alert('" + cadBanco.getErros() + "');window.close();</script>");
           //response.getWriter().append("<script>window.close();</script>");
      } else {
           String scr = "";
                  scr = "<script>";
                  scr += "window.opener.document.location.replace(window.opener.document.location);"
                          + "window.close();"
                          + "</script>";
                  response.getWriter().append(scr);
              }
        response.getWriter().close();
    }
    
  boolean carregaMovBanco = (movBanco != null && (!acao.equals("consultar")));
%>


<script language="javascript" type="text/javascript">
    var homePath = '${homePath}';

    jQuery.noConflict();

/*    //Teclas de atalho
    shortcut.add("enter",function() //Localizar Peça
    {
        visualizar();
    });
*/
  function habilitaSalvar(opcao){
     $("salvar").disabled = !opcao;
     $("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }
  
  function salvar(linhas)
  {          
    
    var deuCerto = true;
    var resultado = "";
    for (i = 0; i <= linhas - 1; ++i){
      //verificando se a data está válida
      if (! validaData($("dtentrada_"+i).value)){
        deuCerto = false;
        $("dtentrada_"+i).style.background ="#FFE8E8";
      }
    }
    if (!deuCerto)
      alert('Informe todos os dados da baixa corretamente');
    else{
      $('formCon').action = "./conciliacaobanco?acao=salvar&qtd="+linhas+"&"+
          concatFieldValue("tipodata,dtinicial,dtfinal,conta,conciliado,doc,idmotorista,idfornecedor,motor_nome,creditos,valor1,valor2,idhist,descricao_historico,codigo_historico");

      submitPopupForm($('formCon'));

    }
  }

  function excluir(id, tipo, index, idmovimento){
    var isCreditoViagemRetorno = false;  
    function ev(resp, codstatus) {
      // habilitaSalvar(true);
      if (codstatus==200 && resp=="err<=>")
        location.replace("./conciliacaobanco?acao=consultar&"+concatFieldValue("tipodata,dtinicial,dtfinal,conta,conciliado,doc,idmotorista,motor_nome,creditos,valor1,valor2,idfornecedor,idhist,descricao_historico,codigo_historico"));
      else{
        alert(resp.split("<=>")[1]);
      }
    }
    
    if ($("credito_viagem_retorno_"+index) != null && $("credito_viagem_retorno_"+index).value != "0") {
        if (confirm("Esse lançamento é referente a crédito de viagem de retorno do ADV " + $("numero_viagem_"+index).value +". Deseja excluir também o lançamento do conhecimento?")){
            isCreditoViagemRetorno = true;
        }
    }
    if (tipo == 'd'){
        alert('Esse crédito foi referente a títulos descontados, primeiro deverá ser excluído o desconto pela rotina de desconto de duplicatas (Factoring).');
    }else if (confirm("Deseja mesmo excluir o lançamento bancário? Fazendo isso a duplicata referente a esse lançamento ficará em aberto.")){
        $('formCon').action= "./conciliacaobanco?acao=excluir&id="+id+"&tipo="+tipo+"&idCte="+idmovimento+"&isCreditoViagemRetorno="+isCreditoViagemRetorno;
        submitPopupForm($('formCon'));
    }
  }

  function cancelarCheque(id,tipo){

    function ev(resp, codstatus) {
      // habilitaSalvar(true);
      if (codstatus==200 && resp=="err<=>")
        location.replace("./conciliacaobanco?acao=consultar&"+concatFieldValue("tipodata,dtinicial,dtfinal,conta,conciliado,doc,idmotorista,motor_nome,creditos,valor1,valor2,idfornecedor,idhist,descricao_historico,codigo_historico"));
      else{
        alert(resp.split("<=>")[1]);
      }
    }

    if (tipo == 'd'){
        alert('Esse crédito foi referente a títulos descontados, primeiro deverá ser excluído o desconto pela rotina de desconto de duplicatas (Factoring).');
    }else if (confirm("Deseja mesmo cancelar o cheque do lançamento bancário? ")){
       $('formCon').action= "./conciliacaobanco?acao=cancelarCheque&id="+id+"&tipo="+tipo;
       submitPopupForm($('formCon'));
    }
  }
  
  function novo()
  {
    if ($("conta").value=="")
      alert ("Informe a conta corretamente.");
    else
      window.open("./cadmovbanco?acao=iniciar&idconta="+getObj("conta").value, "Novo" , "top=0,resizable=yes");
  }

  function alterar(idLanc){
      window.open("./alteramovbanco.jsp?acao=editar&id="+idLanc, "Alterar_Movimento_Bancario" , "top=0,resizable=yes");
  }

    function visualizar(){
        var idFilial = $('idFilial').value;
        if($("tipodata").value == "" && $("doc").value == ""){
            if($("tipoConsultaCheque").value == "0"){
                alert("O campo Apenas o doc/cheque é de preenchimento obrigatório!");
                return false;
            } else if($("tipoConsultaCheque").value == "1"){
                alert("O campo Doc(s)/Cheque(s) entre é de preenchimento obrigatório!");
                return false;
            }else if($("tipoConsultaCheque").value == "2"){
                alert("O campo Vários docs/cheques (separados por vírgula) é de preenchimento obrigatório!");
                return false;
            }else if($("tipoConsultaCheque").value == "3"){
                alert("O campo Apenas o movimento (Despesa) é de preenchimento obrigatório!");
                return false;
            }else if($("tipoConsultaCheque").value == "4"){
                alert("O campo Apenas a viagem é de preenchimento obrigatório!");
                return false;
            }else if($("tipoConsultaCheque").value == "5"){
                alert("O campo Apenas a Nota Fiscal (Despesa) é de preenchimento obrigatório!");
                return false;
            }else if($("tipoConsultaCheque").value == "6"){
                alert("O campo Apenas o CT/NFS é de preenchimento obrigatório!");
                return false;
            }
        }else{
            if (!validaData($("dtinicial").value) || (!validaData($("dtfinal").value)))
              alert ("Informe o intervalo de datas corretamente.");
            else if ($("conta").value=="")
              alert ("Informe a conta corretamente.");
            else
                location.replace("./conciliacaobanco?acao=consultar&"+concatFieldValue("tipodata,dtinicial,dtfinal,conta,conciliado,doc,idmotorista,motor_nome,creditos,valor1,valor2,idhist,descricao_historico,codigo_historico")+
                        "&mostrarTotais="+$('mostrarTotais').checked+"&docDe="+$("docDe").value+"&docAte="+$("docAte").value+"&tipoConsultaCheque="+$("tipoConsultaCheque").value+
                        "&idfornecedor="+$('idfornecedor').value+"&fornecedor="+$("fornecedor").value + "&idMotivo=" + $("motivoCancelarCheque").value + "&isChequeCancelado=" + $("mostrarApenasChequesCancelados").checked +
                        "&idfilial="+idFilial+"&idconsignatario="+$('idconsignatario').value+"&con_rzs="+$('con_rzs').value +"&con_cnpj="+$('con_cnpj').value
                        +"&idclienteRecebimento="+$("idconsignatarioRecebimento").value+"&idfornecedorPagamento="+$("idfornecedorPagamento").value
                        +"&mostrarFiltros="+($("trMaisFiltros").style.display == "" ? true : false)+"&considerarData="+$("considerarDataEntrada").checked
                        +"&clienteRecebimento="+$("con_rzsRecebimento").value+"&fornecedorPagamento="+$("fornecedorPagamento").value
                        +"&idveiculo="+$('idveiculo').value + "&tipo_controle_conta_corrente=" + $('tipo_controle_conta_corrente').value
                        +"&vei_placa="+$('vei_placa').value + '&' + concatFieldValue('selectBeneficiario,idajudante,nome,idFuncionario,nomeFuncionario'));
        }
    }

  function mostraCombos(){
    $("conciliado").value = '<%=(request.getParameter("conciliado") == null?"todos":request.getParameter("conciliado"))%>';
    $("creditos").value = '<%=(request.getParameter("creditos") == null?"ambos":request.getParameter("creditos"))%>';
    $("conta").value = '<%=(request.getParameter("conta") == null?cfg.getConta_padrao_id().getIdConta():request.getParameter("conta"))%>';
    $("tipodata").value = '<%=(request.getParameter("tipodata") == null?"dtentrada":request.getParameter("tipodata"))%>';
    if(<%= request.getParameter("mostrarFiltros")!= null && request.getParameter("mostrarFiltros").equals("true") %>){
        mostrarFiltros();
    }	
    if(<%= request.getParameter("considerarData")!= null && request.getParameter("considerarData").equals("true") %>){
       $("considerarDataEntrada").checked = true;
       considerarMarcados();
    }	
        alterandoConta();
        
  }

  function verMov(id){
      window.open("./caddespesa?acao=editar&id="+id+"&ex=false", "Despesa" , "top=0,resizable=yes");
  }

  function verCtrc(id){
    window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "CTRC" , "top=0,resizable=yes");
  }

  function verSale(id){
    window.open("./cadvenda.jsp?acao=editar&id="+id+"&ex=false", "SERVICO" , "top=0,resizable=yes");
  }
  
    function copiacheque(docum, dtentrada, tipo, valor,idLancamento, idContarel){
        if (tipo == 't' && valor > 0) {
            //comentei esse trecho para ter um backup de como era antes a chamada desse relatório;
//            launchPDF('./conciliacaobanco?acao=exportar&modelo=1&nome=comprovantetransferenciamod&docum='+docum+'&idconta='+$("idcontarel").value+"&dtentrada="+dtentrada
//                    +"&CAMPOFILTRO="+(tipo == 't' ? "vc.idlancamento" : "vc.docum")+"&idLancamento="+idLancamento,
//                      'copiacheque'+docum);

            launchPDF('./conciliacaobanco?acao=exportar&modelo=1&nome=comprovantetransferenciamod&docum='+docum+'&idconta='+idContarel+"&dtentrada="+dtentrada
                    +"&CAMPOFILTRO="+(tipo == 't' ? "vc.idlancamento" : "vc.docum")+"&idLancamento="+idLancamento,
                      'copiacheque'+docum);

        }else{
            //comentei esse trecho para ter um backup de como era antes a chamada desse relatório;
//            launchPDF('./conciliacaobanco?acao=exportar&modelo=1&nome=copiachequemod&docum='+docum+'&idconta='+$("idcontarel").value+"&dtentrada="+dtentrada+"&idLancamento="+(tipo == 't' ? " AND idlancamento = "+idLancamento : idLancamento),
//                      'copiacheque'+docum);
            
            
            if (tipo != 'p' && tipo != 't') {
                alert("ATENÇÃO: Cópia de cheque só pode ser impressa para pagamento e transferência.");
                return false;
            }
            
            launchPDF('./conciliacaobanco?acao=exportar&modelo=1&nome=copiachequemod&docum='+docum+'&idconta='+idContarel+"&dtentrada="+dtentrada+"&idLancamento="+idLancamento,
                      'copiacheque'+docum);
        }
    }

  function marcaConciliado(linha){
    var considerar = $("considerarDataEntrada").checked;
    var dataConsiderar = $("dtConsiderar").value;
    var dataCopia = $("dtCopiaEntrada_"+linha).value;
    
    if ($('chk_'+linha).checked){
        if(considerar){
          $("dtentrada_"+linha).value = dataConsiderar;  
        }
        $('conciliado_'+linha).value = 't';
    }else{
       $('conciliado_'+linha).value = 'f';
       if(considerar){
          $("dtentrada_"+linha).value = dataCopia;  
        }
    }
  }
  
  function considerarMarcados(){
    var considerar = $("considerarDataEntrada").checked;
    var dataConsiderar = $("dtConsiderar").value;
    var i = 0;
    
      while($("chk_" +i) != null){
                if ($("chk_"+i).disabled == false && $("chk_" +i).checked && considerar){
                    $("dtentrada_"+i).value = dataConsiderar;  
                }else{
                     $("dtentrada_"+i).value = $("dtCopiaEntrada_"+i).value;  
                }
                i++;
            }
  }

  function alterandoConta(){
		   

		if ($('conta').value != '0' && $('conta').value == <%=cfg.getConta_adiantamento_viagem_id().getIdConta()%>){
		   $('selectBeneficiario').style.display = "";
		   jQuery('#selectBeneficiario').trigger('change');
                   
                   $('idfornecedor').value = "0";
		   $('fornecedor').value = "";
		   $('fornecedor').style.display = "none";
		   $('localiza_fornecedor').style.display = "none";
		   $('limpa_fornecedor').style.display = "none";
		   $('lbfornecedor').style.display = "none";
                   
                   $('con_rzs').style.display = "none";  
		   $('localiza_cli').style.display = "none";
		   $('limpa_cli').style.display = "none";
		   $('lbcliente').style.display = "none";
		   $('con_cnpj').style.display = "none";
		   $('idconsignatario').value = "0";
                }else if ($('conta').value != '0' && $('conta').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%>){
		   $('fornecedor').style.display = "";
		   $('localiza_fornecedor').style.display = "";
		   $('limpa_fornecedor').style.display = "";
		   $('lbfornecedor').style.display = "";
                   
		   $('selectBeneficiario').style.display = "none";
           jQuery('#selectBeneficiario').trigger('change');
                   
                   $('con_rzs').style.display = "none";  
		   $('localiza_cli').style.display = "none";
		   $('limpa_cli').style.display = "none";
		   $('lbcliente').style.display = "none";
		   $('con_cnpj').style.display = "none";
		   $('idconsignatario').value = "0";
                }else if ($('conta').value != '0' && $('conta').value == <%=cfg.getContaAdiantamentoCliente().getIdConta()%>){
		   $('con_rzs').style.display = "";  //lbcliente   con_cnpj con_rzs idconsignatario limpa_cli  localiza_cli
		   $('localiza_cli').style.display = "";
		   $('limpa_cli').style.display = "";
		   $('lbcliente').style.display = "";
		   $('con_cnpj').style.display = "";
		  // $('idconsignatario').value = "0";
                   
		   $('selectBeneficiario').style.display = "none";
           jQuery('#selectBeneficiario').trigger('change');

                   $('idfornecedor').value = "0";
		   $('fornecedor').value = "";
		   $('fornecedor').style.display = "none";
		   $('localiza_fornecedor').style.display = "none";
		   $('limpa_fornecedor').style.display = "none";
		   $('lbfornecedor').style.display = "none";
                   
		}else{
		   $('selectBeneficiario').style.display = "none";
           jQuery('#selectBeneficiario').trigger('change');
                   
		   $('idfornecedor').value = "0";
		   $('fornecedor').value = "";
		   $('fornecedor').style.display = "none";
		   $('localiza_fornecedor').style.display = "none";
		   $('limpa_fornecedor').style.display = "none";
		   $('lbfornecedor').style.display = "none";
                   
                   $('con_rzs').style.display = "none";  
		   $('localiza_cli').style.display = "none";
		   $('limpa_cli').style.display = "none";
		   $('lbcliente').style.display = "none";
		   $('con_cnpj').style.display = "none";
		   $('idconsignatario').value = "0";
                }
	}

  function slcTipoConsultaCheque(){
        
      if($("tipoConsultaCheque").value=="1"){
          $("divVlTpChq1").style.display = "none";
          $("divVlTpChq2").style.display = "";
      }else{
          $("divVlTpChq1").style.display = "";
          $("divVlTpChq2").style.display = "none";
      }
  }
  
  function mostraMotivo(){
         if($("mostrarApenasChequesCancelados").checked){
             visivel($('lbMotivo'));             
             visivel($('lbMotivos'));             
         }else {
             $("motivoCancelarCheque").value = 0;
             invisivel($('lbMotivo'));
             invisivel($('lbMotivos'));
         }
} 
 
  function setDefault(){
    $("idFilial").value = '<%=request.getParameter("idfilial")==null?"0":request.getParameter("idfilial")%>';
    
    if($("idFilial").value.length == 0 ){
        $("idFilial").value = 0;
    }
    $("mostrarApenasChequesCancelados").checked = '<%=(request.getParameter("isChequeCancelado") == null || Boolean.parseBoolean(request.getParameter("isChequeCancelado")) == false ?"":request.getParameter("isChequeCancelado"))%>';
    $("motivoCancelarCheque").value = '<%=(request.getParameter("idMotivo") == null?"0":request.getParameter("idMotivo"))%>';
        if ($("mostrarApenasChequesCancelados").checked) {
            visivel($('lbMotivo'));  
            visivel($('lbMotivos'));  
        }else{
            invisivel($('lbMotivo'));
            invisivel($('lbMotivos'));
        }
    var isViagem =  $("visualizarViagem").value;
    if(isViagem !=0){
        this.visualizar();
    }
    
    if ($('tipo_controle_conta_corrente').value == 's') {
        jQuery('.td_veiculo_prop').show();
    } else {
        jQuery('.td_veiculo_prop').hide();
        limparVeiculo();
    }
 }
  
  var vlSelecionado = 0;
  function marcaTodos(){
        var i = 0;
        vlSelecionado = 0;
        if($("chkTodos").checked) {
            while($("chk_" +i) != null){
                if ($("chk_"+i).disabled == false){
                    $("chk_" +i).checked = true;
                    marcaConciliado(i);
                }
                i++;
                marcaConciliado(i)
            }
        } else {
            i = 0;
            while($("chk_" +i) != null){
               $("chk_"+i).checked = false;
               marcaConciliado(i);
               i++;  
            }
        }
    }

    function abrirImportacaoArquivo(){
        location.href ="MovimentacaoBancariaControlador?acao=iniciarConciliacaoBancariaLote";
    }

    function localizahist(){
        post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
  
    function verReceita(id){
        window.open("./VendaControlador?acao=iniciarEditarFinan&id="+id, "CTRC" , "top=0,resizable=yes,status=1,scrollbars=1");
    }


 function localizaConsignatario(){
        launchPopupLocate('./localiza?acao=consultar&idlista=5','Cliente');
    }
    
 function localizaFornecedorPagamento(){
        launchPopupLocate('./localiza?acao=consultar&idlista=21&suffix=Pagamento','Fornecedor_Pagamento');
    }
 function localizaClienteRecebimento(){
        launchPopupLocate('./localiza?acao=consultar&idlista=5&suffix=Recebimento','Cliente_Rebecimento');
    }

 function limparFornecedorPagamento(){
        $("idfornecedorPagamento").value = "";
        $("fornecedorPagamento").value = "";
        
    }
 function limparClienteRecebimento(){
        $("idconsignatarioRecebimento").value = "";
        $("con_rzsRecebimento").value = "";
        
    }
    
  function mostrarFiltros(){
        var isOculto = $('trMaisFiltros').style.display == 'none';
        if (isOculto){
            $('trMaisFiltros').style.display = '';
            $('trMaisFiltrosCliente').style.display = '';
            $('lbFiltros').innerHTML = 'Ocultar filtros adicionais';
        }else{
            $('trMaisFiltros').style.display = 'none';
            $('trMaisFiltrosCliente').style.display = 'none';
            $('lbFiltros').innerHTML = 'Mostrar mais filtros';
        }
    }

    function abrirLocalizarVeiculoProp() {
        launchPopupLocate('./localiza?acao=consultar&paramaux4=' + $("idfornecedor").value + '&idlista=<%=BeanLocaliza.TODOS_VEICULOS%>', 'Veiculo_Prop');
    }
    
    function limparVeiculo() {
        $('idveiculo').value = 0;
        $('vei_placa').value = '';
    }
</script>

<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="java.util.Date"%>
<%@ page import="br.com.gwsistemas.viagem.BeneficiarioViagem" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt" />
<meta http-equiv="cache-control" content="no-cache" />
<meta http-equiv="pragma" content="no-store" />
<meta http-equiv="expires" content="0" />
<meta name="language" content="pt-br" />

<title>Webtrans - Concilia&ccedil;&atilde;o banc&aacute;ria</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="javascript:mostraCombos();slcTipoConsultaCheque();setDefault();">
   <div align="center">
       <img src="img/banner.gif"  alt="banner"> 
       <br>
       <input type="hidden" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") != null?request.getParameter("idconsignatario"):"0")%>">
       <input type="hidden" id="idmotorista" value="<%=(request.getParameter("idmotorista") != null?request.getParameter("idmotorista"):"0")%>">
       <input type="hidden" id="visualizarViagem" name="visualizarViagem" value="<%=(request.getParameter("visualizarViagem") != null? request.getParameter("visualizarViagem"):"0")%>">
   </div>

   <table width="95%" height="28" align="center" class="bordaFina" >
       <tr> 
          <td width="46%%" height="22">
              <b>Concilia&ccedil;&atilde;o Banc&aacute;ria</b>
          </td>
          <% if (nivelUser >= 3){%>
            <td height="22" width="18%" align="left">

                <input type="button" class="botoes" value="Importar Extrato Bancário" onclick="abrirImportacaoArquivo();">
            </td>
          <%}%>
          <% if (nivelUserFechamento >= 4 && cfg.isFechamentoDiaConcBanc()){%>
                <td width="18%">
                    <input  name="fechamento" type="button" class="botoes" id="fechamento" onClick="javascript:tryRequestToServer(launchPopupLocate('conciliacao_bloqueio_data.jsp?acao=iniciar&conta='+$('conta').value,'bloqConciliacao'));" value="Fechar movimentações bancárias" alt="Fechar movimentações bancárias ">
                </td>
          <%}%>  
          <% if (nivelUser >= 3){%>
                <td width="18%">
                    <input  name="novo" type="button" class="botoes" id="novo" onClick="javascript:novo();" value="Novo Lan&ccedil;amento" alt="Novo lançamento">
                </td>
          <%}%>
       </tr>
   </table>
   <br>

   <table width="95%" border="0" class="bordaFina" align="center">
       <tr class="tabela"> 
           <td colspan="6">
               <div align="center">Filtros </div>
               <div align="center"></div>
           </td>
       </tr>
       <tr> 
           <td width="20%" height="24" class="TextoCampos">
               <select name="tipodata" id="tipodata" class="inputtexto">
                   <option value="">Não filtrar por data</option>
                   <option value="dtemissao">Por data de emiss&atilde;o entre:</option>
                   <option value="dtentrada" selected>Por data de entrada entre:</option>
               </select>
           </td>
           <td width="18%" class="Celulazebra2">
               <strong> 
                   <input name="dtinicial" type="text" id="dtinicial" style="font-size:8pt;" class="fieldDate" value="<%=(request.getParameter("dtinicial") != null?request.getParameter("dtinicial"):Apoio.getDataAtual())%>" size="9" maxlength="10"
	                  onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
               </strong>e
               <strong> 
                   <input name="dtfinal" type="text" id="dtfinal" class="fieldDate" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null?request.getParameter("dtfinal"):Apoio.getDataAtual())%>" size="9" maxlength="10"
	                  onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
               </strong>
           </td>
           <td width="11%" class="TextoCampos">Apenas a conta:</td>
           <td width="32%" class="TextoCampos">
               <div align="left">
                   <strong> 
                       <select name="conta" id="conta" onChange="javascript:alterandoConta();" class="inputtexto" style="width: 270px;">
                            <option value="0">Todas as contas</option>
                                <% //variaveis da paginacao
                                   //Carregando todas as contas cadastradas
                                   BeanConsultaConta conta = new BeanConsultaConta();
                                   conta.setConexao(Apoio.getUsuario(request).getConexao());
                                   conta.mostraContas((nivelUserDespesaFilial>1?0:Apoio.getUsuario(request).getFilial().getIdfilial()),false, limitarUsuarioVisualizarConta, idUsuario);
                                   ResultSet rsconta = conta.getResultado();
                                   while (rsconta.next()){%>
                                       <option value="<%=rsconta.getString("idconta")%>"><%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " - " + rsconta.getString("banco") + " - Ag:" + rsconta.getString("agencia") %></option>
                                   <%}%>
                      </select>
                  </strong>
               </div>
          </td>
          <td width="6%" class="TextoCampos">Mostrar:</td>
          <td width="13%" class="Celulazebra2" style="font-size:8pt;">
              <select name="conciliado" id="conciliado" class="inputtexto">
                   <option value="todos" selected>Todos</option>
                   <option value="true">Conciliados</option>
                   <option value="false">N&atilde;o Conciliados</option>
              </select>
          </td>
       </tr>
       <tr> 
          <td class="TextoCampos">
              <select class="inputTexto" style="width: 160px" id="tipoConsultaCheque" name="tipoConsultaCheque" onchange="slcTipoConsultaCheque();">
                    <option value="0" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("0")? "selected":"")%>>Apenas o doc/cheque </option>
                    <option value="1" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("1")? "selected":"")%>>Doc(s)/Cheque(s) entre</option>
                    <option value="2" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("2")? "selected":"")%>>Vários docs/cheques (separados por vírgula)</option>
                    <option value="3" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("3")? "selected":"")%>>Apenas o movimento (Despesa)</option>
                    <option value="4" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("4")? "selected":"")%>>Apenas a viagem</option>
                    <option value="5" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("5")? "selected":"")%>>Apenas a Nota Fiscal (Despesa)</option>
                    <option value="6" <%=(request.getParameter("tipoConsultaCheque") != null && request.getParameter("tipoConsultaCheque").equals("6")? "selected":"")%>>Apenas o CT/NFS</option>
             </select>:
          </td>
          <td class="Celulazebra2">
              <strong> 
                    <div id="divVlTpChq1">
                         <input name="doc" type="text" id="doc" class="fieldMin" value="<%=(request.getParameter("doc") != null?request.getParameter("doc"):"")%>" size="35" />
                    </div>
                    <div id="divVlTpChq2" style="display: none">
                         <input name="docDe" type="text" id="docDe" class="inputtexto" value="<%=(request.getParameter("docDe") != null?request.getParameter("docDe"):"")%>" size="9" />&nbsp;a&nbsp;
                         <input name="docAte" type="text" id="docAte" class="inputtexto" value="<%=(request.getParameter("docAte") != null?request.getParameter("docAte"):"")%>" size="9" />
                    </div>
              </strong>
          </td>
          <td class="TextoCampos">
              <label id="lbfornecedor">Fornecedor:</label>
              <label id="lbcliente">Cliente:</label>
              <select id="selectBeneficiario" name="selectBeneficiario" class="inputtexto">
                  <option value="0" hidden>Selecione</option>
                  <option value="m" ${(empty param['selectBeneficiario'] or param['selectBeneficiario'] eq 'm') ? "selected" : ""}>Motorista</option>
                  <option value="a" ${param['selectBeneficiario'] eq 'a' ? "selected" : ""}>Ajudante</option>
                  <option value="f" ${param['selectBeneficiario'] eq 'f' ? "selected" : ""}>Funcionário</option>
              </select>
          </td>
          <td class="Celulazebra2">
              <div style="display: none;" data-beneficiario="m">
                  <input name="motor_nome" type="text" class="inputReadOnly8pt" id="motor_nome" value="<%=(request.getParameter("motor_nome") != null?request.getParameter("motor_nome"):"")%>" size="40" readonly="true">
                  <input name="localiza_motor" type="button" class="botoes" id="localiza_motor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                  <strong>
                      <img src="${homePath}/img/borracha.gif" id="limpa_motor" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
                  </strong>
              </div>
              <div style="display: none;" data-beneficiario="a">
                  <input type="hidden" id="idajudante" name="idajudante" value="${param['idajudante']}">
                  <input name="nome" id="nome" type="text" class="inputReadOnly8pt" size="40" readonly value="${param['nome']}">
                  <input type="button" class="botoes" name="localiza_ajudante" id="localiza_ajudante" value="...">
                  <img src="${homePath}/img/borracha.gif" alt="" class="imagemLink" id="borrachaAj" onclick="$('nome').value=''; $('idajudante').value='0';">
              </div>
              <div style="display: none;" data-beneficiario="f">
                  <input type="hidden" id="idFuncionario" name="idFuncionario" value="${param['idFuncionario']}">
                  <input name="nomeFuncionario" id="nomeFuncionario" type="text" class="inputReadOnly8pt" size="40" readonly value="${param['nomeFuncionario']}">
                  <input type="button" class="botoes" name="localizarFuncionario" id="localizarFuncionario" value="...">
                  <img src="${homePath}/img/borracha.gif" alt="" class="imagemLink" id="limparFuncionario" onclick="$('idFuncionario').value = '0'; $('nomeFuncionario').value = '';">
              </div>

              <input name="fornecedor" type="text" class="inputReadOnly8pt" id="fornecedor" value="<%=(request.getParameter("fornecedor") != null? request.getParameter("fornecedor"):"")%>" size="40" readonly="true">
              <input type="hidden" id="idfornecedor" name="idfornecedor" value="<%=(request.getParameter("idfornecedor") != null?request.getParameter("idfornecedor"):"")%>">
              <input type="hidden" id="tipo_controle_conta_corrente" name="tipo_controle_conta_corrente" value="<%=(request.getParameter("tipo_controle_conta_corrente") != null? request.getParameter("tipo_controle_conta_corrente"):"")%>">
              <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>','Fornecedor')" value="...">
          
              <strong>
                  <img src="img/borracha.gif" id="limpa_fornecedor" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:getObj('idfornecedor').value = 0;javascript:getObj('fornecedor').value = '';">
              </strong>
              
              <input name="con_cnpj" type="text" id="con_cnpj" size="20" class="inputReadOnly8pt" value="<%=(request.getParameter("con_cnpj") != null?request.getParameter("con_cnpj"):"")%>">
              <input name="con_rzs" type="text" id="con_rzs" size="40" maxlength="50" readonly="true" class="inputReadOnly8pt" value="<%=(request.getParameter("con_rzs") != null?request.getParameter("con_rzs"):"")%>">
              
              <strong>                               
                <input name="localiza_cli" id="localiza_cli" type="button" class="botoes" onClick="localizaConsignatario();" value="...">           
                </strong>
               <img src="img/borracha.gif" id="limpa_cli" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:getObj('idconsignatario').value = 0;javascript:getObj('con_cnpj').value = '';javascript:getObj('con_rzs').value = '';">

              <span class="td_veiculo_prop" style="display: none; padding-left: 1vw;">
                  <label>Veículo:</label>
                  <input type="hidden" id="idveiculo" name="idveiculo"
                         value="<%=(request.getParameter("idveiculo") != null? request.getParameter("idveiculo"):"0")%>">
                  <input name="vei_placa" type="text" class="inputReadOnly" id="vei_placa" size="10" readonly
                         value="<%=(request.getParameter("vei_placa") != null? request.getParameter("vei_placa"):"")%>">
                  <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo"
                         onClick="abrirLocalizarVeiculoProp();" value="...">
                  <strong>
                      <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink"
                           title="Limpar Veículo" onClick="limparVeiculo();">
                  </strong>
              </span>
          </td>
    
          <td colspan="2" class="Celulazebra2">
              <div align="center">
                  <input name="mostrarTotais" type="checkbox" id="mostrarTotais" value="checkbox" <%=(request.getParameter("mostrarTotais") == null ? "" : (request.getParameter("mostrarTotais").equals("true")?"checked":""))%>>
                  Mostrar totais di&aacute;rios 
              </div>
          </td>
      </tr>
      <tr>
          <td class="TextoCampos">Visualizar:</td>
          <td class="Celulazebra2">
              <select name="creditos" id="creditos" class="inputtexto">
                  <option value="ambos" selected>Ambos</option>
                  <option value="debitos">Apenas D&eacute;bitos</option>
                  <option value="creditos">Apenas Cr&eacute;ditos</option>
              </select>
          </td>
          <td class="TextoCampos">Filtrar valores: </td>
          <td class="Celulazebra2">Entre 
              <span class="CelulaZebra2">
                    <input name="valor1" id="valor1" value="<%=(request.getParameter("valor1") != null?request.getParameter("valor1"):"0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="8" class="inputtexto" maxlength="12" align="Right">
              </span>&nbsp; e &nbsp;
              <span class="CelulaZebra2">
                    <input name="valor2" id="valor2" value="<%=(request.getParameter("valor2") != null?request.getParameter("valor2"):"0.00")%>" onBlur="javascript:seNaoFloatReset(this,'0.00');" type="text" size="8" class="inputtexto" maxlength="12" align="Right">
              </span>
          </td>
          <td class="TextoCampos">Filial:</td>
          <td class="Celulazebra2">
              <select class="inputtexto"  name="idFilial" id="idFilial">
                   <option value="0">TODAS</option>
                         <% 
                          //Carregando todas as filiais cadastradas
                          BeanConsultaFilial f = new BeanConsultaFilial();
                          f.setConexao(Apoio.getUsuario(request).getConexao());
                                                         
                          for(BeanFilial fl: f.mostrarTodos(Apoio.getUsuario(request).getConexao())){%>
                               <option value="<%=fl.getIdfilial()%>"><%=fl.getAbreviatura()%></option>
                          <%}%>
                                 
              </select>
          </td>
      </tr>
      <tr>
          <td class="TextoCampos" colspan="2"> 
              <div align="center">
                   <input name="mostrarApenasChequesCancelados" id="mostrarApenasChequesCancelados" type="checkbox" onclick="mostraMotivo();">
                   Mostrar apenas cheques cancelados 
              </div>
          </td>
    
          <td width="7%" class="TextoCampos">
              Apenas o Histórico:
          </td>
                                
          <td width="8%" class="CelulaZebra2">
              <input name="idhist" type="hidden" id="idhist" value="<%=request.getParameter("idhist") == null ? "0" : request.getParameter("idhist")%>" onBlur="javascript:seNaoIntReset(this,'0');" style="font-size:8pt;" size="2" maxlength="3">
              <input name="codigo_historico" class="inputReadOnly8pt" type="text" id="codigo_historico" value="<%=request.getParameter("codigo_historico") == null ? "" : request.getParameter("codigo_historico")%>" onBlur="javascript:seNaoIntReset(this,'0');" size="2" maxlength="3" readOnly >
              <input name="descricao_historico" type="text" id="descricao_historico" class="fieldMin" size="40" class="inputtexto" maxlength="100" value="<%=request.getParameter("descricao_historico") == null ? "" : request.getParameter("descricao_historico")%>">
              <input name="model_hist" type="button" class="botoes" id="model_hist2" value="..." onClick="javascript:localizahist()">
              <img src="img/borracha.gif" id="limpa_historico" border="0" align="absbottom" class="imagemLink" title="Limpar Histórico" onClick="javascript:$('idhist').value = '0';$('codigo_historico').value = '';$('descricao_historico').value = '';">
          </td>
                    
          <td class="TextoCampos">
               <div id="lbMotivo" align="right" style="display: none">
                   Motivo:
               </div>
          </td>
          <td class="Celulazebra2">
              <div id="lbMotivos" align="left" style="display: none" >
                   <select name="motivoCancelarCheque" class="inputtexto" id="motivoCancelarCheque" class="inputtexto">
                        <option value="0" selected>Todos os motivos</option>
                              <%BeanCadMovBanco movCadBanco = new BeanCadMovBanco();
                              movCadBanco.setConexao(Apoio.getUsuario(request).getConexao());
                              ResultSet rsMotivos = movCadBanco.mostraMotivosCancelamentoCheque();
                              while (rsMotivos.next()) {%>
                                   <option value="<%=rsMotivos.getInt("id")%>" <%=(request.getParameter("idMotivo")!=null && request.getParameter("idMotivo").equals(rsMotivos.getInt("id"))?"selected":"")%>>
                                         <%=rsMotivos.getString("descricao")%>
                                   </option>
                              <%}%>
                   </select>
              </div>
         </td>
     </tr>
      <tr>
          <td colspan="2" class="Celulazebra2">
              <div align="right"> 
                  <input type="checkbox" id="considerarDataEntrada" name="considerarDataEntrada" value="checkbox" onclick="considerarMarcados()"> Ao Marcar Considerar a Data de Entrada: 
              </div>
          </td>
          <td colspan="2" class="Celulazebra2">
              <div align="left"> 
                    <input name="dtConsiderar" type="text" id="dtConsiderar" style="font-size:8pt;" class="fieldDate" value="<%=(Apoio.getDataAtual())%>" size="9" maxlength="10"
                                onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />        
              </div>
          </td>
          <td align="center" class="CelulaZebra2" colspan="2">
              <div class="linkEditar" onclick="javascript:tryRequestToServer(function(){mostrarFiltros();});" align="center">
                  <label class="linkEditar" id="lbFiltros" name="lbFiltros">Mostrar mais filtros</label>
              </div>
          </td>
      </tr>
      <tr id="trMaisFiltros" name="trMaisFiltros" style="display: none;" class="CelulaZebra2">
          <td align="right">Apenas pagamentos do fornecedor:</td>
          <td colspan="2">
              <input type="text" class="inputReadOnly8pt" name="fornecedorPagamento" id="fornecedorPagamento" value="<%= request.getParameter("fornecedorPagamento") != null ? request.getParameter("fornecedorPagamento") : "" %>" readonly size="30">
              <input type="button" class="botoes" value="..." onclick="localizaFornecedorPagamento();" >
              <input type="hidden" name="idfornecedorPagamento" id="idfornecedorPagamento" value="<%= request.getParameter("idfornecedorPagamento") != null ? request.getParameter("idfornecedorPagamento") : "" %>">
              <img src="${homePath}/img/borracha.gif" class="imagemLink" onclick="limparFornecedorPagamento()">
          </td>
          <td colspan="3">
          </td>
      </tr>
      <tr id="trMaisFiltrosCliente" name="trMaisFiltrosCliente" style="display: none;" class="CelulaZebra2">
          <td align="right">Apenas recebimentos do cliente:</td>
          <td colspan="2">
              <input type="text" class="inputReadOnly8pt" name="con_rzsRecebimento" id="con_rzsRecebimento" value="<%= request.getParameter("clienteRecebimento") != null ? request.getParameter("clienteRecebimento") : "" %>" readonly size="30">
              <input type="button" class="botoes" value="..." onclick="localizaClienteRecebimento();" >
              <input type="hidden" name="idconsignatarioRecebimento" id="idconsignatarioRecebimento" value="<%= request.getParameter("idclienteRecebimento") != null ? request.getParameter("idclienteRecebimento") : "" %>">
              <img src="${homePath}/img/borracha.gif" class="imagemLink" onclick="limparClienteRecebimento()">
          </td>
          <td colspan="3">
          </td>
      </tr>
     <tr> 
         <td colspan="6" class="TextoCampos"> 
              <div align="center"> 
                   <% if (nivelUser >= 1){%>
                        <input name="visualizar" type="button" class="botoes" id="visualizar" value="Visualizar" onClick="javascript:tryRequestToServer(function(){visualizar();});">
                   <%}%>
              </div>
         </td>
     </tr>
  </table>
              
 
  <form method="post" id="formCon">
       <table width="95%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                 <td width="2%"><strong></strong></td>
                 <td width="2%"><strong></strong></td>
                 <td width="6%"><strong>NF/Ctrc</strong></td>
                 <td width="6%"><strong>Docum.</strong></td>
                 <td width="5%"><div align="center"><strong>Conc.</strong></div></td>
                 <td width="9%"><strong>Emiss&atilde;o</strong></td>
                 <td width="9%"><strong>Entrada</strong></td>
                 <td width="9%"><div align="right"><strong>D&eacute;bito</strong></div></td>
                 <td width="9%"><div align="right"><strong>Cr&eacute;dito</strong></div></td>
                 <td width="9%"><div align="right"><strong>Saldo</strong></div></td>
                 <td width="30%"><strong>Hist&oacute;rico</strong></td>
                 <td width="2%"><strong></strong></td>
                 <td width="2%"><strong></strong></td>
            </tr>
            <% //variaveis da paginacao
                 int linha = 0;
                 boolean celulaZebra1 = false;
                 double saldo = 0;
                 boolean fimRs = true;
      
                 // se conseguiu consultar
                 if ( (acao.equals("consultar")) && (movBanco.Consultar()) ){
                     ResultSet rs = movBanco.getResultado();
                     int idatual = 0;
                     String doc = "";
                     String tipoDoc = "";
                     double totalDoc = 0;
                     int qtdDoc = 0;
                     double totalCreditos = 0;
                     double totalDebitos = 0;
                     double totalGeralCreditos = 0;
                     double totalGeralDebitos = 0;
                     Date dataAtual = new Date();
                     String corCancelado = "";
          
                     if (rs.next()){
                        fimRs = false;
                     }
                     
	             while (!fimRs){
                        corCancelado = (rs.getBoolean("is_cheque_cancelado")?"color='red'":"");
            
                        if (linha == 0){
                             saldo =(rs.getString("saldoanterior")==null?0:rs.getDouble("saldoanterior"));
                             doc = rs.getString("docum");
                             tipoDoc = rs.getString("docum")+rs.getString("tipo");
                             dataAtual = rs.getDate("dtentrada");
                        %>
                        
                             <tr class="CelulaZebra2"> 
                                  <td class="TextoCampos" colspan="4"></td>
                                  <td class="textoCampos">
                                       <div align="center">
                                           <div align="center">
                                                <input type="checkbox" name="chkTodos" id="chkTodos" onClick="javascript:marcaTodos();">
                                           </div>
                                       </div>
                                  </td>
                                  <td class="TextoCampos" colspan="2"></td>
                                  <td class="TextoCampos" colspan="2"><strong>Saldo Anterior</strong></td>
                                  <td class="TextoCampos"><font color=<%=(rs.getString("saldoanterior")==null || rs.getFloat("saldoanterior") <= 0?"#CC0000":"#0000FF")%>><%=(rs.getString("saldoanterior")==null?"0,00":new DecimalFormat("#,##0.00").format(rs.getDouble("saldoanterior")*(rs.getDouble("saldoanterior")<=0?-1:1)))%></font></td>
                                  <td class="TextoCampos" colspan="3"></td>
                            </tr>  
                        <%}
                            if (idatual != rs.getInt("idlancamento")){
                               //atribuindo valor ao saldo
                               saldo = saldo + (rs.getBoolean("is_cheque_cancelado") ? 0 : rs.getDouble("valor"));
                            }
                        
                                 //Totalizando o numero do documento
                                 if (!tipoDoc.equals(rs.getString("docum")+rs.getString("tipo"))){
            	                     if (qtdDoc > 1 && !doc.equals("")){
            	              
                            %>
                            
                                        <tr class="<%=(celulaZebra1 ? "CelulaZebra1" : "CelulaZebra2") %>"> 
                                             <td colspan="5"></td>
                                             <td colspan="2">
                                                 <div align="right">
                                                     <strong>Total do doc. <%=doc%> :</strong>
                                                 </div>
                                             </td>
                                             <%if (totalDoc < 0){%>
                                                  <td>
                                                      <strong>
                                                          <div align="right"><%=new DecimalFormat("#,##0.00").format(totalDoc * -1)%></div>
                                                      </strong>
                                                  </td>
                                                  <td colspan="5"></td>
                                            <%}else{%>
                                                  <td></td>
                                                  <td>
                                                      <strong>
                                                          <div align="right"><%=new DecimalFormat("#,##0.00").format(totalDoc)%></div>
                                                      </strong>
                                                  </td>
                                                  <td colspan="4"></td>
                                             <%}%>   
                                       </tr>  
                            <%}
                                     
                           celulaZebra1 = !celulaZebra1;
                           doc = rs.getString("docum");
                           tipoDoc = rs.getString("docum")+rs.getString("tipo");
                           totalDoc = 0;
                           qtdDoc = 1;
                        }else{
                           qtdDoc++;
                        }%>
            
        	        <%//Verificando se mudou a data para criar os totais
        	        if (!new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtentrada")).equals(new SimpleDateFormat("dd/MM/yyyy").format(dataAtual))){
        	              if (request.getParameter("mostrarTotais").equals("true")){%>
			          <tr class="<%=(celulaZebra1 ? "CelulaZebra2" : "CelulaZebra1") %>" > 
    	            	              <td colspan="4"></td>
        		       	      <td colspan="3">
                                          <div align="right">
                                              <b>Totais do dia <%=new SimpleDateFormat("dd/MM/yyyy").format(dataAtual)%>:</b>
                                          </div>
                                      </td>
                	              <td>
                                          <strong>
                                              <div align="right"><%=new DecimalFormat("#,##0.00").format(totalDebitos * (totalDebitos == 0 ? 1 : -1))%></div>
                                          </strong>
                                      </td>
                    	              <td>
                                          <strong>
                                              <div align="right"><%=new DecimalFormat("#,##0.00").format(totalCreditos)%></div>
                                          </strong>
                                      </td>
                		      <td colspan="4"></td>
                	          </tr>	 
        	       <%}
                              
        	        totalCreditos = 0;
        	        totalDebitos = 0;
	                
                        if (rs.getDouble("valor")<0){
                            if (!rs.getBoolean("is_cheque_cancelado")){
                                totalDebitos = rs.getDouble("valor");
                                totalGeralDebitos += rs.getDouble("valor");
                            }
            	       }else{
                            if (!rs.getBoolean("is_cheque_cancelado")){
                                if (idatual != rs.getInt("idlancamento")){
                                     totalCreditos = rs.getDouble("valor");
                                     totalGeralCreditos += rs.getDouble("valor");
                                }
                            }
            	       }
                        
        	       dataAtual = rs.getDate("dtentrada");
        	      
                       }else{
                            if (rs.getDouble("valor")<0){
                                if (!rs.getBoolean("is_cheque_cancelado")){
                                    totalDebitos += rs.getDouble("valor");
                                    totalGeralDebitos += rs.getDouble("valor");
                                }
                            }else{
                                if (!rs.getBoolean("is_cheque_cancelado")){
                                    if (idatual != rs.getInt("idlancamento")){
                                         totalCreditos += rs.getDouble("valor");
                                         totalGeralCreditos += rs.getDouble("valor");
                                    }
                                }
                             }
        	       }%>
            
               <tr class="<%=(celulaZebra1 ? "CelulaZebra1" : "CelulaZebra2") %>" >
                    <td>
                        <%if (nivelCopiaCheque > 0) {%>
                        <img src="img/pdf.jpg" alt="Imprimir cópia de cheque" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:copiacheque('<%=rs.getString("docum")%>',$('dtentrada_<%=linha%>').value, '<%=rs.getString("tipo")%>', '<%=rs.getString("valor")%>','<%=rs.getString("idlancamento")%>','<%=rs.getString("idconta")%>')});"
                                   width="19" height="20" border="0">
                        <input type="hidden" id="idcontarel" name="idcontarel" value="<%=rs.getString("idconta")%>">
                        <%}%>
                    </td>
                    <td>
                        <%if (nivelUser >= 2) {%>
                              <img src="img/page_edit.png" alt="Alterar Movimentação Bancária" style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:alterar('<%=rs.getString("idlancamento")%>');});"
                                   width="19" height="20" border="0">
                       <%}%>
                    </td>
                    <td>
                        <%if (rs.getString("tipo").equals("p") && nivelUserDespesa > 0){%>
                              <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verMov('<%=rs.getString("iddespesa")%>');});">
                                    <font size="1"><%=rs.getString("notafiscal")%></font>
                                    
                              </div>
                        <%}else if(rs.getString("tipo").equals("r")){
                              if(rs.getString("categoria") != null && rs.getString("categoria").equals("ct") && nivelUserCtrc>0){%>
                                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verCtrc('<%=rs.getString("sale_id")%>');});">
                                          <font size="1"><%=rs.getString("doc_fiscal") == null ? "" : rs.getString("doc_fiscal")%></font>
                                    </div>
                        <%}else if(rs.getString("categoria") != null && rs.getString("categoria").equals("ns") && nivelUserSale>0){%>
                              <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verSale('<%=rs.getString("sale_id")%>');});">
                                    <font size="1"><%=rs.getString("doc_fiscal") == null ? "" : rs.getString("doc_fiscal")%></font>
                              </div>
                        <%}else if(rs.getString("categoria") != null && (rs.getString("categoria").equals("fn") || rs.getString("categoria").equals("vv")) && nivelUserSale>0){%>      
                              <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verReceita('<%=rs.getString("sale_id")%>');});">
                                    <font size="1"><%=rs.getString("doc_fiscal") == null ? "" : rs.getString("doc_fiscal")%></font>
                              </div>
                        <%}else{ %>
                              <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){verSale('<%=rs.getString("sale_id")%>');});">
                                    <font size="1"><%=rs.getString("doc_fiscal") == null ? "" : rs.getString("doc_fiscal")%></font>
                              </div>
                        <%}    
                      }%>
                   </td>
                   <td>
                       <font size="1" <%=corCancelado%>><%=rs.getString("docum") == null ? "" : rs.getString("docum")%></font>
                   </td>
                   <td> 
                       <div class="linkEditar" onClick="" align="center"> 
                             <input name="id_<%=linha%>" id="id_<%=linha%>" type="hidden" value="<%=rs.getString("idlancamento")%>">
                             <input name="chk_<%=linha%>" id="chk_<%=linha%>" type="checkbox" <%=(rs.getBoolean("conciliado")?"checked":"")%> value="<%=rs.getString("conciliado")%>"
                                    onClick="javascript:marcaConciliado('<%=linha%>');">
                             <input name="conciliado_<%=linha%>" id="conciliado_<%=linha%>" type="hidden" value="<%=rs.getString("conciliado")%>">
                             <input name="credito_viagem_retorno_<%=linha%>" id="credito_viagem_retorno_<%=linha%>" type="hidden" value="<%=rs.getInt("id_sales_adv_viagem")%>">
                             <input name="numero_viagem_<%=linha%>" id="numero_viagem_<%=linha%>" type="hidden" value="<%=rs.getString("numero_viagem")%>">
                       </div>
                   </td>
                   <td>
                       <font size="1" <%=corCancelado%>><%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtemissao"))%></font>
                   </td>
                   <td>
                       <font size="1" <%=corCancelado%>>
                             <input name="dtCopiaEntrada_<%=linha%>" id="dtCopiaEntrada_<%=linha%>" value="<%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtentrada"))%>" type="hidden" size="9" class="fieldDate" maxlength="12"
			            onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" >
                             <input name="dtentrada_<%=linha%>" id="dtentrada_<%=linha%>" value="<%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("dtentrada"))%>" type="text" size="9" class="fieldDate" maxlength="12"
			            onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" >
                       </font>
                   </td>
                   <%if (idatual != rs.getInt("idlancamento")){%>
                        <td>
                            <font size="1" <%=corCancelado%>>
                                 <div align="right" id="valor1"><%=(rs.getDouble("valor")<0?new DecimalFormat("#,##0.00").format(rs.getDouble("valor")*-1):"")%></div>
                            </font>
                        </td>
                        <td>
                            <font size="1" <%=corCancelado%>>
                                 <div align="right" id="valor2"><%=(rs.getDouble("valor")>=0?new DecimalFormat("#,##0.00").format(rs.getDouble("valor")):"")%></div>
                            </font>
                        </td>
                        <td>
                            <font size="1" color=<%=(saldo <= 0?"#CC0000":"#0000FF")%>>
                                 <div align="right"><%=(saldo<=0?new DecimalFormat("#,##0.00").format(saldo*-1):new DecimalFormat("#,##0.00").format(saldo))%></div>
                            </font>
                        </td>
                     <%
                        totalDoc += rs.getDouble("valor");
                     }else{%>
                        <td>
                            <font size="1">
                                 <div align="right">------</div>
                            </font>
                        </td>
                        <td>
                            <font size="1">
                                 <div align="right">------</div>
                            </font>
                        </td>
                        <td>
                            <font size="1">
                                 <div align="right">------</div>
                            </font>
                        </td>
                    <%}%>
              
                        <td>
                            <font size="1" <%=corCancelado%>> <%=(rs.getBoolean("is_cheque_cancelado") ? rs.getString("historico") + " (Motivo:" + rs.getString("motivo_cancelamento") + ")" : rs.getString("historico"))%></font>
                        </td>
                        <td>
                            <%if (nivelUser == 4 && (rs.getString("tipo").equals("p") || rs.getString("tipo").equals("t"))) {%>
                                 <img src="img/cancelar.png" alt="Cancelar o cheque deste registro" title="Cancelar o cheque desta movimentação." style="cursor:pointer" onClick="javascript:tryRequestToServer(function(){javascript:cancelarCheque('<%=rs.getString("idlancamento")%>','<%=rs.getString("tipo")%>')});">
                            <%}%>
                        </td>
                        <td>
                            <%if(nivelUser==4){%>
                                 <img src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer" title="Excluir movimentação bancaria." onClick="javascript:tryRequestToServer(function(){javascript:excluir('<%=rs.getString("idlancamento")%>','<%=rs.getString("tipo")%>','<%=linha%>', '<%=rs.getString("sale_id")%>');});">
                            <%}%>  
                        </td>
             </tr>
          
             <%idatual = rs.getInt("idlancamento");
                 linha++;
          	 
                 if (rs.isLast() && qtdDoc > 1){%>
                       <tr class="<%=(celulaZebra1 ? "CelulaZebra1" : "CelulaZebra2") %>"> 
                            <td colspan="5"></td>
                            <td colspan="2">
                                <div align="right">
                                    <strong>Total do doc. <%=doc%> :</strong>
                                </div>
                            </td>
                           
                            <%if (totalDoc < 0){%>
                                <td>
                                    <strong>
                                        <div align="right"><%=new DecimalFormat("#,##0.00").format(totalDoc * -1)%></div>
                                    </strong>
                                </td>
                                <td colspan="5"></td>
                           <%}else{%>
                                <td></td>
                                <td>
                                    <strong>
                                        <div align="right"><%=new DecimalFormat("#,##0.00").format(totalDoc)%></div>
                                    </strong>
                                </td>
                                <td colspan="4"></td>
                            <%}%>   
                        </tr>  
                <%}
        	
                 if (rs.isLast()){
                    fimRs = true;
                 }else{   
            	    rs.next(); 
                 }
                 }%>
	        
                 <tr class="<%=(celulaZebra1 ? "CelulaZebra2" : "CelulaZebra1") %>" > 
               	     <td colspan="5"></td>
               	     <td colspan="2">
                         <div align="right">
                             <b>Total do per&iacute;odo:</b>
                         </div>
                     </td>
                     <td>
                         <strong>
                             <div align="right"><%=new DecimalFormat("#,##0.00").format(totalGeralDebitos * (totalGeralDebitos == 0 ? 1 : -1))%></div>
                         </strong>
                     </td>
                     <td>
                         <strong>
                             <div align="right"><%=new DecimalFormat("#,##0.00").format(totalGeralCreditos)%></div>
                         </strong>
                     </td>
               	     <td colspan="4"></td>
                 </tr>	 
                <%}%>
           </table>
      </form>
      <table width="95%" border="0" class="bordaFina" align="center">
        <tr> 
           <td width="100%" class="TextoCampos"> 
               <div align="center"> 
                   <% if (nivelUser >= 2){%>
                       <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar(<%=linha%>);});">
                   <%}%>
               </div>
           </td>
       </tr>
     </table>
  </body>
</html>