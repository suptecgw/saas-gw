<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  mov_banco.conta.*,
                  mov_banco.*,
                  mov_banco.banco.*,
                  mov_banco.talaocheque.ConsultaTalaoCheque,
                  mov_banco.talaocheque.TalaoCheque,
                  conhecimento.duplicata.*,
                  nucleo.BeanConfiguracao,
                  nucleo.BeanLocaliza,
                  java.text.*,
                  java.util.Date,
                  java.util.Hashtable,
                  java.util.Enumeration,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>

<% 

 BeanConfiguracao cfg = null;
            cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("conbancaria") : 0);
   int nivelUserConta = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);
   int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
           ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser==0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  
  boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
  int idUsuario = Apoio.getUsuario(request).getIdusuario();

  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  BeanCadMovBanco cadBanco = null;
  BeanMovBanco mBanco = null;
  if (!acao.equals("iniciar")){
      cadBanco = new BeanCadMovBanco();
      cadBanco.setConexao( Apoio.getUsuario(request).getConexao() );
      cadBanco.setExecutor(Apoio.getUsuario(request));
      mBanco = new BeanMovBanco();
  }
  if (acao.equals("salvar")){
      
    //Preenchendo o array dos mov_banco
    BeanMovBanco[] arBanco = new BeanMovBanco[1];
    //Preechendo os dados do débito
    BeanMovBanco mb = new BeanMovBanco();
    mb.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
    mb.setValor(Double.parseDouble(request.getParameter("valor"))*(request.getParameter("tipolanc").equals("cre")?1:-1));
    mb.setDtEntrada(formatador.parse(request.getParameter("data")));
    mb.setDtEmissao(formatador.parse(request.getParameter("data")));
    mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
    mb.getHistorico_id().setIdHistorico(Apoio.parseInt(request.getParameter("idhist")));
    mb.setHistorico(request.getParameter("descricao_historico"));
    mb.setCheque(Boolean.parseBoolean(request.getParameter("isCancelado")));
    mb.setChequeCancelado(Boolean.parseBoolean(request.getParameter("isCancelado")));
    mb.setConciliado(Boolean.parseBoolean(request.getParameter("isConciliado")));
    mb.getAdiantamentoFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor")));
    mb.setDocum(request.getParameter("docum"));
    mb.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
    if(request.getParameter("isCancelado").equals("true") ){
        mb.setConciliado(Boolean.parseBoolean(request.getParameter("isCancelado")));
        mb.getMotivoCancelaCheque().setId(Integer.parseInt(request.getParameter("idMotivo")));
    }else {
        mb.getMotivoCancelaCheque().setId(0);
    }
    mb.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
    mb.setTipo("n");
    arBanco[0] = mb;
    cadBanco.setArrayBMovBanco(arBanco);

    boolean erroSalvar = cadBanco.Inclui();
    //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
    if(erroSalvar) {
      response.getWriter().append("err<=>"+cadBanco.getErros());
    }else{
      response.getWriter().append("err<=>");
    }
    
    response.getWriter().close();
  }
  
%>


<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    
  function habilitaSalvar(opcao){
     getObj("salvar").disabled = !opcao;
     getObj("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }

  function salvar(linhas)
  {          

    function ev(resp, codstatus) {
      if (codstatus==200 && resp=="err<=>"){
        alert('Cadastro realizado com sucesso.');
        window.close();
      }  
      else
        alert(resp.split("<=>")[1]);
    }
    
    if ($('conta').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%> && $("idfornecedor").value == "0"){
        alert('Informe o Fornecedor corretamente.');
    }else if (! validaData(getObj("data").value)){
      alert('Informe a data corretamente.');
    //else if (parseFloat(getObj("valor").value) == 0)
      //alert('Valor não pode ser igual a 0,00');
    }else if($("conta").value == ""){
        alert("ATENÇÃO: Escolha uma conta para baixar");
        return false;
    }else if ($('conta').value == <%=cfg.getContaAdiantamentoCliente().getIdConta()%> && $("idconsignatario").value == "0"){
        alert('Informe o Cliente corretamente.');
    }else if($("tipo_controle_conta_corrente").value == 's' && $("idveiculo").value == 0){
        alert('Para esse proprietário/fornecedor o campo veículo é de preenchimento obrigatório.');
    } else{
        var docum = $("docum").value;
        if(<%=cfg.isControlarTalonario()%> && $("chk_cheque_cancelado").checked){
            docum = $("docum_cb").value;
        }
    
      requisitaAjax("./cadmovbanco?acao=salvar&"
          +concatFieldValue("valor,data,conta,descricao_historico,tipolanc,idfornecedor,idhist")
          +"&isCancelado="+$('chk_cheque_cancelado').checked
          +"&isConciliado="+$('chk_conciliado').checked
          +"&docum="+docum+"&idMotivo="+$("motivoCancelamentoCheque").value+"&idconsignatario="+$("idconsignatario").value
          +"&idveiculo="+$("idveiculo").value  ,ev);
  
    }
  }

  function localizahist(){
    post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  
  function getUltimoCheque(){
        if(<%=cfg.isControlarTalonario()%> && !$("chk_cheque_cancelado").checked){
            $('docum_cb').style.display = "none";
            $('docum').style.display = "";
        }

        if (<%=cfg.isControlarTalonario()%> && $("chk_cheque_cancelado").checked){
        
        function e(transport){
            var textoresposta = transport.responseText;
            
            
            
            //se deu algum erro na requisicao...
            if (textoresposta == "-1"){
                alert('Houve algum problema ao requistar o novo cheque, favor informar manualmente.');
                return false;
            }else{
                    $('docum').style.display = "none";
                    $('docum_cb').style.display = "";
                
                    //var lista = JSON.parse(textoresposta);
                    var lista = jQuery.parseJSON(textoresposta);
                
                    var listCheque = lista.list[0].documento;
            
                    var documento;
                    var isPrimeiro = true;
                    
                    var slct = $("docum_cb");

                    var opt = null;

                    Element.update(slct);
                    opt = new Element("option", {
                        value: ""
                    })
                               

                    Element.update(opt, " ---- ");
                    slct.appendChild(opt);
                    
                    var length = (listCheque.length == undefined ? 1 : listCheque.length);

                    for(var i = 0; i < length; i++){
                        
                        if(length > 1){
                            documento = listCheque[i];
                        }else{
                            documento = listCheque;
                        }
                    
                        if(documento != null && documento != undefined){
                            
                            if(isPrimeiro){
                                opt = new Element("option", {
                                    value: documento,
                                    selected: isPrimeiro+""
                                })
                            }else{
                                opt = new Element("option", {
                                    value: documento
                                })
                            }

                            Element.update(opt, documento);
                            slct.appendChild(opt);
                            isPrimeiro = false;
                        }
                    }
            }
        }//funcao e()
        

            new Ajax.Request("TalaoChequeControlador?acao=proxCheque&idConta="+$('conta').value+'&setor=',
            {method:'post', onSuccess: e, onError: e});
        }
    } 
    
    
  function alterandoConta(){
            if ($('conta').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%>){
               $('tr_forn').style.display = "";
            }else{
               $('tr_forn').style.display = "none";		   
            }
            
            if($('conta').value ==  <%=cfg.getContaAdiantamentoCliente().getIdConta()   %>){
                $("trCliente").style.display = "" ;
            }else{
                $("trCliente").style.display = "none" ;
            }
    }
  function mostraMotivos(){
      if($("chk_cheque_cancelado").checked){
          $("lbMotivo").style.display = '';
      }else {
          $("lbMotivo").style.display = 'none';
      }
  }  
  
    function localizaConsignatario(){
        launchPopupLocate('./localiza?acao=consultar&idlista=5','Cliente');
    }

    function aoClicarNoLocaliza(idjanela) {
        if (idjanela.indexOf('Fornecedor') > -1) {
            //  console.log("forne: "+("tipo_controle_conta_corrente").value);
            if ($('tipo_controle_conta_corrente').value == 's') {
                jQuery('.td_veiculo_prop').show();
            } else {
                jQuery('.td_veiculo_prop').hide();
            }
        }
    }

    function abrirLocalizarVeiculoProp() {
        launchPopupLocate('./localiza?acao=consultar&paramaux4=' + $("idfornecedor").value + '&idlista=<%=BeanLocaliza.TODOS_VEICULOS%>', 'Veiculo_Prop');
    }

    function limparVeiculo() {
        $('idveiculo').value = 0;
        $('vei_placa').value = '';
        $('vei_tipofrota').value = '';
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

<title>Webtrans - Novo Lan&ccedil;amento banc&aacute;rio/caixa</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="applyFormatter();alterandoConta()">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
</div>
<table width="70%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Novo Lan&ccedil;amento banc&aacute;rio/caixa</b></td>
  </tr>
</table>

<br>

<table width="70%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td colspan="6"><div align="center">Dados da Transfer&ecirc;ncia/suprimento</div>
      <div align="center"></div></td>
  </tr>
  <tr> 
    <td class="TextoCampos" width="10%" >Conta:</td>
    <td class="CelulaZebra2" width="15%" ><strong> 
        <select name="conta" id="conta" class="inputtexto" onchange="getUltimoCheque();alterandoConta();" >
            <option value="">Selecione</option>
            <% //variaveis da paginacao
            //Carregando todas as contas cadastradas
            BeanConsultaConta conta = new BeanConsultaConta();
            conta.setConexao(Apoio.getUsuario(request).getConexao());
            conta.mostraContas((nivelUserDespesaFilial > 1? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()),false, limitarUsuarioVisualizarConta, idUsuario);
            ResultSet rsconta = conta.getResultado();
            while (rsconta.next()){%>
              <option value="<%=rsconta.getString("idconta")%>" <%=(request.getParameter("idconta")!=null && request.getParameter("idconta").equals(rsconta.getString("idconta"))?"selected":"")%>><%=rsconta.getString("numero")%></option>
            <%}%>
      </select>
      </strong></td>
    <td class="TextoCampos" width="5%" >Tipo lan&ccedil;amento:</td>
    <td class="CelulaZebra2" width="10%" ><strong> 
      <select name="tipolanc" id="tipolanc" class="inputtexto">
        <option value="cre" selected>Crédito</option>
        <option value="deb">Débito</option>
      </select>
      </strong></td>
    <td class="CelulaZebra2" width="10%" ><div align="center">
            <input name="chk_cheque_cancelado" type="checkbox" id="chk_cheque_cancelado" value="checkbox" onclick="getUltimoCheque();mostraMotivos();">
      Cheque cancelado 
    </div></td>
    <td class="CelulaZebra2" width="20%" >
        <div id="lbMotivo" style="display: none ; text-align: left " >Motivo:
        
            <select name="motivoCancelamentoCheque" id="motivoCancelamentoCheque" class="inputtexto" style="width: 80px;" >
           <% 
        BeanCadMovBanco movBanco = new BeanCadMovBanco();
        movBanco.setConexao(Apoio.getUsuario(request).getConexao());
        ResultSet rsMotivos = movBanco.mostraMotivosCancelamentoCheque();
        while (rsMotivos.next()){%>
        <option value="<%=rsMotivos.getInt("id")%>" <%=(request.getParameter("idMotivo")!=null && request.getParameter("idMotivo").equals(rsMotivos.getInt("id"))?"selected":"")%>><%=rsMotivos.getString("descricao")%></option>
        <%}%>
        </select></div>
    </td>
  </tr>
  <tr id="trCliente" style="display: none">
      <td width="61" height="25" class="TextoCampos">Cliente:</td>
                    <td colspan="5" class="CelulaZebra2">
                        <div align="left">
                            <input name="con_cnpj" type="text" id="con_cnpj" size="20" class="inputReadOnly8pt" value="" >
                            <input name="con_rzs" type="text" id="con_rzs" value="" size="40" maxlength="50" readonly="true" class="inputReadOnly8pt">
                            <input name="idconsignatario" type="hidden" id="idconsignatario" value="0" >
                            <strong>                               
                                <input name="button3" type="button" class="botoes" onClick="localizaConsignatario();" value="...">                                
                            </strong>
                        </div>
                    </td>
      </tr>
  <tr id="tr_forn" style="display: none"> 
    <td height="24" class="TextoCampos">Fornecedor:</td> 
    <td class="CelulaZebra2" colspan="3">
        <input type="hidden" id="idfornecedor" name="idfornecedor" value="0">
        <input type="hidden" id="tipo_controle_conta_corrente" name="tipo_controle_conta_corrente" value="">
        <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" size="35" value="" readonly />
        <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>','Fornecedor')" value="..." />        
    </td>
      <td height="24" class="TextoCampos">
          <div class="td_veiculo_prop" style="display: none;">Veículo:</div>
      </td>
      <td colspan="1" class="CelulaZebra2">
          <div class="td_veiculo_prop" style="display: none;">
              <input type="hidden" id="idveiculo" name="idveiculo" value="0">
              <input name="vei_placa" type="text" class="inputReadOnly" id="vei_placa" value="" size="10" readonly>
              <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="abrirLocalizarVeiculoProp();" value="...">
              <strong>
                  <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Veículo" onClick="limparVeiculo();">
              </strong>
          </div>
      </td>
  </tr>
  <tr> 
    <td width="17%" height="24" class="TextoCampos">Valor:</td>
    <td width="16%" class="CelulaZebra2"><strong> 
      <input name="valor" type="text" id="valor" class="inputtexto" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00"  size="7" align="right">
      </strong></td>
    <td width="17%" class="TextoCampos">Data:</td>
    <td width="16%" class="CelulaZebra2"><strong> 
      <input name="data" type="text" id="data" style="font-size:8pt;" value="<%=Apoio.getDataAtual()%>" size="9" maxlength="10" 
      		 onblur="alertInvalidDate(this)" class="fieldDate" >
      </strong></td>
    <td width="17%" class="TextoCampos">Documento:</td>
    <td width="17%" class="CelulaZebra2" style="font-size:8pt;"><input name="docum" type="text" id="docum" style="font-size:8pt;" size="7" maxlength="15" class="inputtexto">
    
                  <%if(cfg.isControlarTalonario()){%>
<select name="docum_cb" id="docum_cb" class="fieldMin" style="display: none">
    <option value="" > ---- </option>          
          <%
          ConsultaTalaoCheque tc = new ConsultaTalaoCheque();
    	  //ResultSet rsCT = tc.ConsultarDoc(Apoio.getUsuario(request).getConexao(),request.getParameter("conta"));
          tc.setConexao(Apoio.getUsuario(request).getConexao());
           
          int idConta = request.getParameter("conta") != null ? Integer.parseInt(request.getParameter("conta")): cfg.getConta_padrao_id().getIdConta();
          Collection<String> cheques = tc.consultarDocDisponivel(idConta,Apoio.getUsuario(request).getFilial().getIdfilial(),"f",Apoio.getUsuario(request));
              boolean isPrimeiro = true;
            for(String doc: cheques){
                
      %>
                <option value="<%=doc%>" <%=(isPrimeiro ? "selected" : "")%>><%=doc%></option>          
          <%
          isPrimeiro = false;
            } %>
        </select>
        <%
          
        }%>
    
    
    
    </td>
    
  </tr>
  <tr> 
    <td class="TextoCampos">Hist&oacute;rico:</td>
    <td colspan="5" class="CelulaZebra2"><strong> </strong><strong> 
      <input name="descricao_historico" type="text" id="descricao_historico" style="font-size:8pt;" size="60" class="inputtexto" maxlength="100">
      <input name="idhist" type="hidden" id="idhist" style="font-size:8pt;" size="60" class="inputtexto" maxlength="100">
      <input name="model_hist" type="button" class="botoes" id="model_hist2" value="..." onClick="javascript:localizahist()">
      </strong></td>
  </tr>
            <tr>
                <td class="TextoCampos" colspan="6" >
                    <div align="center">
                        <input name="chk_conciliado" id="chk_conciliado" type="checkbox" checked>
                        Ao salvar conciliar o movimento
                    </div>
                </td>
            </tr>
</table>
<table width="70%" border="0" class="bordaFina" align="center">
  <tr> 
    <td width="100%" class="TextoCampos"> <div align="center"> 
        <% if (nivelUser >= 2){%>
        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salvar();});">
        <%}%>
      </div></td>
  </tr>
</table>
</body>
</html>