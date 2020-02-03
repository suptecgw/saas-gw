<%@page import="java.util.Collection"%>
<%@page import="mov_banco.talaocheque.ConsultaTalaoCheque"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
          import="java.sql.ResultSet,
                  mov_banco.conta.*,
                  nucleo.BeanLocaliza,          
                  mov_banco.*,
                  mov_banco.banco.*,
                  conhecimento.duplicata.*,
                  java.text.*,
                  java.util.Date,
                  java.util.Hashtable,
                  java.util.Enumeration,
                  nucleo.BeanConfiguracao,
                  nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>


<% 
  int nivelUser = (Apoio.getUsuario(request) != null
                   ? Apoio.getUsuario(request).getAcesso("transferencia") : 0);
  int nivelUserConta = (Apoio.getUsuario(request) != null
                   ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);

  boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
  int idUsuario = Apoio.getUsuario(request).getIdusuario();
   
  BeanConfiguracao cfg = null;
  cfg = new BeanConfiguracao();
  cfg.setConexao(Apoio.getUsuario(request).getConexao());
  //Carregando as configurações
  cfg.CarregaConfig();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || ( nivelUser==0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );

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
    BeanMovBanco[] arBanco = new BeanMovBanco[2];
    //Preechendo os dados do débito
    BeanMovBanco mb = new BeanMovBanco();
    mb.getConta().setIdConta(Integer.parseInt(request.getParameter("idcontadeb")));
    mb.setValor(Double.parseDouble(request.getParameter("valor"))*-1);
    mb.setDtEntrada(formatador.parse(request.getParameter("data")));
    mb.setDtEmissao(formatador.parse(request.getParameter("data")));
    mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
    mb.setHistorico(request.getParameter("historicodeb"));
    mb.getHistorico_id().setIdHistorico(Integer.parseInt(request.getParameter("id_historicodeb")));
    mb.setDocum(request.getParameter("docum"));
    mb.setTipo("t");
    mb.setCheque(Boolean.parseBoolean(request.getParameter("isCheque")));
    mb.getAdiantamentoFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor_deb")));
    mb.setConciliado(Apoio.parseBoolean(request.getParameter("isConciliado")));
    mb.setCheque(Apoio.parseBoolean(request.getParameter("isCheque")));
    mb.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario_deb")));
    arBanco[0] = mb;
    //Preechendo os dados do crédito
    mb = new BeanMovBanco();
    mb.getConta().setIdConta(Integer.parseInt(request.getParameter("idcontacre")));
    mb.setValor(Double.parseDouble(request.getParameter("valor")));
    mb.setDtEntrada(formatador.parse(request.getParameter("data")));
    mb.setDtEmissao(formatador.parse(request.getParameter("data")));
    mb.getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
    mb.setHistorico(request.getParameter("historicocre"));
    mb.getHistorico_id().setIdHistorico(Integer.parseInt(request.getParameter("id_historicocre")));
    mb.setDocum(request.getParameter("docum"));
    mb.setTipo("t");
    mb.getAdiantamentoFornecedor().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor_cred")));
    mb.setConciliado(Apoio.parseBoolean(request.getParameter("isConciliado")));
    mb.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario_cred")));
    // idconsignatario_cred  idconsignatario_deb
    
    arBanco[1] = mb;
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

<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
jQuery.noConflict();
  function habilitaSalvar(opcao){
     getObj("salvar").disabled = !opcao;
     getObj("salvar").value = (opcao ? "Salvar" : "Enviando...");
  }

  function salvar(linhas){          

    function ev(resp, codstatus) {
      if (codstatus==200 && resp=="err<=>"){
        alert('Transferência/suprimento realizado com sucesso.');
        location.replace("./transferenciabanco?acao=iniciar");
      }  
      else
        alert(resp.split("<=>")[1]);
    }
 
    if ($('idcontacre').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%> && $("idfornecedor_cred").value == "0"){
        alert('Informe o Fornecedor do crédito corretamente.');
    }else if ($('idcontadeb').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%> && $("idfornecedor_deb").value == "0"){
        alert('Informe o Fornecedor do débito corretamente.');
       
    }else if ($('idcontacre').value == <%=cfg.getContaAdiantamentoCliente().getIdConta()%> && $("idconsignatario_cred").value == "0"){
        alert('Informe o Fornecedor do crédito corretamente.');
    }else if ($('idcontadeb').value == <%=cfg.getContaAdiantamentoCliente().getIdConta()%> && $("idconsignatario_deb").value == "0"){
        alert('Informe o Fornecedor do débito corretamente.');
    }else if (! validaData(getObj("data").value)){
      alert('Informe a data da transferência/suprimento corretamente.');
    }else if (parseFloat(getObj("valor").value) == 0)
      alert('Valor não pode ser igual a 0,00');
    else{
        var docum = $("docum").value;
        if(<%=cfg.isControlarTalonario()%> && $("chk_cheque").checked){
            docum = $("docum_cb").value;
        }
        requisitaAjax("./transferenciabanco?acao=salvar&"+
          concatFieldValue("valor,data,idcontadeb,idcontacre,historicodeb,historicocre,id_historicodeb,id_historicocre,idfornecedor_cred,idfornecedor_deb")
          +"&isCheque="+$('chk_cheque').checked 
          +"&docum="+docum 
          +"&isConciliado="+$('chk_conciliado').checked
          +"&idconsignatario_cred="+$("idconsignatario_cred").value 
          +"&idconsignatario_deb="+$("idconsignatario_deb").value,ev);
    }
  }

  function aoClicarNoLocaliza(idjanela)
  {         
    if ((idjanela == "Fornecedor_Debito")){
      getObj("fornecedor_deb").value = getObj("fornecedor").value;
      getObj("idfornecedor_deb").value = getObj("idfornecedor").value;
    }else if ((idjanela == "Fornecedor_Credito")){
      getObj("fornecedor_cred").value = getObj("fornecedor").value;
      getObj("idfornecedor_cred").value = getObj("idfornecedor").value;
    }else if ((idjanela == "Historico")){
      getObj("historicodeb").value = getObj("descricao_historico").value;
      getObj("codigo_historicodeb").value = getObj("codigo_historico").value;
      getObj("id_historicodeb").value = getObj("idhist").value;
    }else if(idjanela =="Cliente_Credito"){  
      getObj("con_cnpj_cred").value = getObj("con_cnpj").value;
      getObj("con_rzs_cred").value = getObj("con_rzs").value;
      getObj("idconsignatario_cred").value = getObj("idconsignatario").value;
    }else if(idjanela =="Cliente_Debito"){ 
      getObj("con_cnpj_deb").value = getObj("con_cnpj").value;
      getObj("con_rzs_deb").value = getObj("con_rzs").value;
      getObj("idconsignatario_deb").value = getObj("idconsignatario").value;
    }else{
      getObj("historicocre").value = getObj("descricao_historico").value;
      getObj("codigo_historicocre").value = getObj("codigo_historico").value;
      getObj("id_historicocre").value = getObj("idhist").value;
    }
  }
  
  function localizahistdeb(){
    post_cad = window.open('./localiza?acao=consultar&idlista=14','Historico',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  function localizahistcre(){
    post_cad = window.open('./localiza?acao=consultar&idlista=14','historico',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }
  
  function alterandoConta(){
	if ($('idcontacre').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%>){
		   $('lbFornecedor_cred').style.display = "";
		   $('divFornecedor_cred').style.display = "";
	}else{
		   $('idfornecedor').value = "0";
		   $('fornecedor').value = "";
		   $('idfornecedor_cred').value = "0";
		   $('fornecedor_cred').value = "";
		   $('lbFornecedor_cred').style.display = "none";
		   $('divFornecedor_cred').style.display = "none";
        }
        
	if ($('idcontadeb').value == <%=cfg.getContaAdiantamentoFornecedor().getIdConta()%>){
		   $('lbFornecedor_deb').style.display = "";
		   $('divFornecedor_deb').style.display = "";
	}else{
                   $('idfornecedor_deb').value = "0";
		   $('fornecedor_deb').value = "";
		   $('idfornecedor').value = "0";
		   $('fornecedor').value = "";
		   $('lbFornecedor_deb').style.display = "none";
		   $('divFornecedor_deb').style.display = "none";
        }
   
        if ($('idcontacre').value == <%=cfg.getContaAdiantamentoCliente().getIdConta()%>){
		   $('lbCliente_cred').style.display = "";
		   $('divCliente_cred').style.display = "";
	}else{
		   $('idconsignatario').value = "0";
		   $('con_rzs').value = "";
		   $('con_cnpj').value = "";
		   $('idconsignatario_cred').value = "0";
		   $('con_cnpj_cred').value = "";
		   $('con_rzs_cred').value = "";
		   $('lbCliente_cred').style.display = "none";
		   $('divCliente_cred').style.display = "none";
        }
        
	if ($('idcontadeb').value == <%=cfg.getContaAdiantamentoCliente().getIdConta() %>){
		   $('lbCliente_deb').style.display = "";
		   $('divCliente_deb').style.display = "";
	}else{
                   $('idconsignatario').value = "0";
		   $('con_rzs').value = "";
		   $('con_cnpj').value = "";
		   $('idconsignatario_deb').value = "0";
		   $('con_cnpj_deb').value = "";
		   $('con_rzs_deb').value = "";
		   $('lbCliente_deb').style.display = "none";
		   $('divCliente_deb').style.display = "none";
        }
}
  function carregar(){
	
		   $('idfornecedor').value = "0";
		   $('fornecedor').value = "";
		   $('idfornecedor_cred').value = "0";
		   $('fornecedor_cred').value = "";
	
                   $('idfornecedor_deb').value = "0";
		   $('fornecedor_deb').value = "";
		   $('valor').value = "0.00";
		   $('docum').value = "";
		   $('id_historicodeb').value = "0";
		   $('codigo_historicodeb').value = "";
		   $('historicodeb').value = "";
		   $('id_historicocre').value = "0";
		   $('codigo_historicocre').value = "";
		   $('historicocre').value = "";
		   $('chk_cheque').checked = false;
		   $('chk_conciliado').checked = true;
                   
}

  function getUltimoCheque(){
      
        if ($("chk_cheque").checked){
            $('lbDoc').innerHTML = "Nº Cheque:";
        }else{
            $('lbDoc').innerHTML = "Documento:";
        }    
        
        if(<%=cfg.isControlarTalonario()%> && !$("chk_cheque").checked){
            $('docum_cb').style.display = "none";
            $('docum').style.display = "";
        }else{
            $('docum_cb').style.display = "";
            $('docum').style.display = "none";
        }    

        if (<%=cfg.isControlarTalonario()%> && $("chk_cheque").checked){
        
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
            new Ajax.Request("TalaoChequeControlador?acao=proxCheque&idConta="+$('idcontadeb').value+'&setor=',
            {method:'post', onSuccess: e, onError: e});
        }
    }
    
    function localizaConsignatario(janela){
        launchPopupLocate('./localiza?acao=consultar&idlista=5',janela);
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

<title>Webtrans - Transferência bancária/suprimento de caixa</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="carregar();applyFormatter();alterandoConta()">
<div align="center"><img src="img/banner.gif"  alt="banner"> <br>
  <input type="hidden" name="descricao_historico" id="descricao_historico" value="0">
  <input type="hidden" name="codigo_historico" id="codigo_historico" value="0">
  <input type="hidden" name="idhist" id="idhist" value="0">
</div>
<table width="70%" height="28" align="center" class="bordaFina" >
  <tr>
    <td height="22"><b>Transfer&ecirc;ncia / Suprimento</b></td>
  </tr>
</table>

<br>

<table width="70%" border="0" class="bordaFina" align="center">
  <tr class="tabela"> 
    <td colspan="8">
        <input type="hidden" id="idfornecedor" name="idfornecedor" value="0">    
        <input type="hidden" id="fornecedor" name="fornecedor" value="">    
        
        <input type="hidden" id="idconsignatario" name="idconsignatario" value="0">    
        <input type="hidden" id="con_rzs" name="con_rzs" value="">    
        <input type="hidden" id="con_cnpj" name="con_cnpj" value="">    
        
        <div align="center">Dados da Transfer&ecirc;ncia/suprimento</div>
      <div align="center"></div></td>
  </tr>
  <tr> 
    <td width="10%" height="24" class="TextoCampos">Valor:</td>
    <td width="10%" class="CelulaZebra2"><strong> 
      <input name="valor" type="text" id="valor" class="inputtexto" onBlur="javascript:seNaoFloatReset(this,'0.00');" value="0.00"  size="7" align="right">
      </strong></td>
    <td width="10%" class="TextoCampos">Data:</td>
    <td width="10%" class="CelulaZebra2"><strong> 
      <input name="data" type="text" id="data" style="font-size:8pt;" value="<%=Apoio.getDataAtual()%>" size="9" maxlength="10"
	  		  onblur="alertInvalidDate(this)" class="fieldDate" />
      </strong></td>
    <td width="10%" class="CelulaZebra2" style="font-size:8pt;"><div align="center">
            <label> <input name="chk_cheque" type="checkbox" id="chk_cheque" value="checkbox" onchange="getUltimoCheque();">
      Em cheque
            </label></div>
    </td>
      <td width="10%" class="TextoCampos"><label id="lbDoc">Documento:</label></td>
    <td width="10%" class="CelulaZebra2" style="font-size:8pt;">
        <input name="docum" type="text" id="docum" style="font-size:8pt;" size="8" maxlength="15" class="inputtexto">
        <%if(cfg.isControlarTalonario()){%>
        <select name="docum_cb" id="docum_cb" class="inputtexto" style="display: none">
            <option value="" > ---- </option>          
            <%
            ConsultaTalaoCheque tc = new ConsultaTalaoCheque();
            //ResultSet rsCT = tc.ConsultarDoc(Apoio.getUsuario(request).getConexao(),request.getParameter("conta"));
            tc.setConexao(Apoio.getUsuario(request).getConexao());
           
            int idConta = request.getParameter("conta") != null ? Integer.parseInt(request.getParameter("conta")): cfg.getConta_padrao_id().getIdConta();
            Collection<String> cheques = tc.consultarDocDisponivel(idConta,Apoio.getUsuario(request).getFilial().getIdfilial(),"f",Apoio.getUsuario(request));
            boolean isPrimeiro = true;
            for(String doc: cheques){%>
                <option value="<%=doc%>" <%=(isPrimeiro ? "selected" : "")%>><%=doc%></option>          
            <%isPrimeiro = false;
            }%>
        </select>
        <%}%>
    </td>
    <td width="30%" class="CelulaZebra2" style="font-size:8pt;">
        <div align="center">
           <label> <input name="chk_conciliado" type="checkbox" id="chk_conciliado" value="conciliado"> 
          Ao salvar,conciliar movimento</label>
        </div>
    </td>
  </tr>
  <tr> 
    <td colspan="8" width="100%"> <table width="100%" border="0">
        <tr> 
          <td width="8%" class="TextoCampos"><div align="right">D&eacute;bito:</div></td>
          <td width="8%" class="TextoCampos">Conta:</td>
          <td width="18%" class="CelulaZebra2"><strong>
                  <select name="idcontadeb" id="idcontadeb" class="inputtexto" onChange="javascript:getUltimoCheque(); alterandoConta();" style="width: 120px;">
              <% //variaveis da paginacao
      //Carregando todas as contas cadastradas
      BeanConsultaConta conta = new BeanConsultaConta();
      conta.setConexao(Apoio.getUsuario(request).getConexao());
      conta.mostraContas((nivelUser==4?0:Apoio.getUsuario(request).getFilial().getIdfilial()),false, limitarUsuarioVisualizarConta, idUsuario);
      ResultSet rsconta = conta.getResultado();
      while (rsconta.next()){%>
              <option value="<%=rsconta.getString("idconta")%>"><%=rsconta.getString("numero")%>-<%=rsconta.getString("banco")%></option>
              <%}%>
            </select>
            </strong></td>
          </td>
          <td width="16%" class="TextoCampos">
              Hist&oacute;rico:
              <div id="lbFornecedor_deb">
                Fornecedor:
              </div>
              <div id="lbCliente_deb">
                Cliente:
              </div>
          </td>
          <td width="50%" class="CelulaZebra2" colspan="4"><span class="CelulaZebra2">
            <input name="id_historicodeb" type="hidden" id="id_historicodeb" value="0" onBlur="javascript:seNaoIntReset(this,'0');" style="font-size:8pt;" size="2" maxlength="3">
            <input name="codigo_historicodeb" class="inputtexto" type="text" id="codigo_historicodeb" value="" onBlur="javascript:seNaoIntReset(this,'0');" style="font-size:8pt;" size="2" maxlength="3">
            <input name="model_hist" type="button" class="botoes" id="model_hist" value="..." onClick="javascript:localizahistdeb()">
            <input name="historicodeb" type="text" class="inputtexto" id="historicodeb" style="font-size:8pt;" size="36" maxlength="100">
            <div id="divFornecedor_deb"><strong>
            <input name="fornecedor_deb" type="text" class="inputReadOnly8pt" id="fornecedor_deb" value="" size="35" readonly="true">
            <input type="hidden" id="idfornecedor_deb" name="idfornecedor_deb" value="0">
            <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>','Fornecedor_Debito')" value="..."/>
            </strong>
            </div>
            <div id="divCliente_deb">  
                <div align="left">
                    <input name="con_cnpj_deb" type="text" id="con_cnpj_deb" size="20" class="inputReadOnly8pt" value="">
                    <input name="con_rzs_deb" type="text" id="con_rzs_deb" value="" size="40" maxlength="50" readonly="true" class="inputReadOnly8pt">
                    <input name="idconsignatario_deb" type="hidden" id="idconsignatario_deb" value="0" >
                    <strong>                               
                        <input name="button3" type="button" class="botoes" onClick="localizaConsignatario('Cliente_Debito');" value="...">                                
                    </strong>
                </div>
            </div>
            </span>
          </td>
        </tr>
        <tr> 
          <td class="TextoCampos"><div align="right">Cr&eacute;dito:</div></td>
          <td class="TextoCampos">Conta:</td>
          <td class="CelulaZebra2"><strong> 
            <select name="idcontacre" id="idcontacre" class="inputtexto" onChange="javascript:alterandoConta();" style="width: 120px;">
              <% //variaveis da paginacao
      //Carregando todas as contas cadastradas
      conta.mostraContas((nivelUser==4?0:Apoio.getUsuario(request).getFilial().getIdfilial()),false, limitarUsuarioVisualizarConta, idUsuario);
      rsconta = conta.getResultado();
      while (rsconta.next()){%>
              <option value="<%=rsconta.getString("idconta")%>"><%=rsconta.getString("numero")%>-<%=rsconta.getString("banco")%></option>
              <%}%>
            </select>
            </strong></td>
          <td class="TextoCampos">
              Hist&oacute;rico:
              <div id="lbFornecedor_cred">Fornecedor:</div>
              <div id="lbCliente_cred">Cliente:</div>
          </td>
          <td class="CelulaZebra2"><span class="CelulaZebra2">
            <input name="id_historicocre" type="hidden" id="id_historicocre" value="0" onBlur="javascript:seNaoIntReset(this,'0');" style="font-size:8pt;" size="2" maxlength="3">
            <input name="codigo_historicocre" type="text" id="codigo_historicocre" value="" onBlur="javascript:seNaoIntReset(this,'0');" style="font-size:8pt;" size="2" class="inputtexto" maxlength="3">
            <input name="model_hist2" type="button" class="botoes" id="model_hist2" value="..." onClick="javascript:localizahistcre()">
            <input name="historicocre" type="text" id="historicocre" class="inputtexto" style="font-size:8pt;" size="36" maxlength="100">
            <div id="divFornecedor_cred"><strong>
            <input name="fornecedor_cred" type="text" class="inputReadOnly8pt" id="fornecedor_cred" value="" size="35" readonly="true">
            <input type="hidden" id="idfornecedor_cred" name="idfornecedor_cred" value="0">
            <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>','Fornecedor_Credito')" value="..."/>
            </strong></div>
             <div id="divCliente_cred"> 
                <div align="left">
                    <input name="con_cnpj_cred" type="text" id="con_cnpj_cred" size="20" class="inputReadOnly8pt" value="">
                    <input name="con_rzs_cred" type="text" id="con_rzs_cred" value="" size="40" maxlength="50" readonly="true" class="inputReadOnly8pt">
                    <input name="idconsignatario_cred" type="hidden" id="idconsignatario_cred" value="0" >
                    <strong>                               
                        <input name="button3" type="button" class="botoes" onClick="localizaConsignatario('Cliente_Credito');" value="...">                                
                    </strong>
                </div>
            </div>
            </span>
          </td>
        </tr>
      </table></td>
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
