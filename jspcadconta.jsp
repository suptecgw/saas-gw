<%@ page contentType="text/html" language="java"
         import="mov_banco.conta.*,
         mov_banco.banco.*,
         java.sql.ResultSet,
         java.util.Vector,
         nucleo.BeanConfiguracao,
         nucleo.BeanLocaliza,
         nucleo.Apoio" errorPage="" %>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0 ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconta") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
%>
<%

    //Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    BeanConta conta = null;
    BeanCadConta cadConta = null;

    if (acao != null) {
        //instrucoes incomuns entre as acoes
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {    //instanciando o bean de cadastro
            conta = new BeanConta();
            cadConta = new BeanCadConta();
            cadConta.setConexao(Apoio.getUsuario(request).getConexao());
            cadConta.setExecutor(Apoio.getUsuario(request));
        }

        //executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int idconta = Integer.parseInt(request.getParameter("id"));
            conta.setIdConta(idconta);
            cadConta.setConta(conta);
            //carregando os dados do conta por completo(atributos)
            cadConta.LoadAllPropertys();
        } else if (acao.equals("atualizar") || acao.equals("incluir")) {
            //Variáveis pra receber a data no formato dd/mm/yyyy
            conta.setNumero(request.getParameter("numero"));
            conta.setDigito_conta(request.getParameter("digito_conta"));
            conta.setAgencia(request.getParameter("agencia"));
            conta.setDigito_agencia(request.getParameter("digito_agencia"));
            conta.setDescricao(request.getParameter("descricao"));
            conta.setTipo_conta(request.getParameter("tipo_conta"));
            conta.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
            conta.getBanco().setIdBanco(Integer.parseInt(request.getParameter("banco")));
            conta.setDriver_cheque(request.getParameter("driver_cheque"));
            conta.getPlanoConta().setId(Integer.parseInt(request.getParameter("plano_contas_id")));
            conta.getPlanoConta().setDescricao(request.getParameter("plano_contas_descricao"));
            conta.setCarteira(request.getParameter("carteira"));
            conta.setNumeroConvenio(request.getParameter("convenio"));
            conta.setCodigoOperacao(request.getParameter("codigoOperacao"));
            conta.setInstrucao1(request.getParameter("instrucao1"));
            conta.setInstrucao2(request.getParameter("instrucao2"));
            conta.setInstrucao3(request.getParameter("instrucao3"));
            conta.setInstrucao4(request.getParameter("instrucao4"));
            conta.setInstrucao5(request.getParameter("instrucao5"));
            conta.setUltimoNossoNumero(Long.parseLong(request.getParameter("nossoNumero")));
            conta.setEmissaoBoletoPor(request.getParameter("emissaoBoleto"));
            conta.setCobrancaComRegistro(Apoio.parseBoolean(request.getParameter("cobrancaComRegistro")));
            conta.setJurosAcrescimo(Double.parseDouble(request.getParameter("jurosAcrescimo")));
            conta.setMulta(Double.parseDouble(request.getParameter("multa")));
            conta.setCodProtesto(Integer.parseInt(request.getParameter("codProtesto")));
            conta.setDiasProtesto(Integer.parseInt(request.getParameter("diasProtesto")));
            conta.setCodDevolucao(Integer.parseInt(request.getParameter("codDevolucao")));
            conta.setDiasDevolucao(Integer.parseInt(request.getParameter("diasDevolucao")));
            conta.setContaAtiva(Boolean.parseBoolean(request.getParameter("ativo")));
            conta.setUtilizaCartaFrete(Boolean.parseBoolean(request.getParameter("utilizaCarta")));
            conta.setUtilizaAdiantamentoViagem(Boolean.parseBoolean(request.getParameter("utilizaViagem")));
            conta.setLimiteCredito(Apoio.parseDouble(request.getParameter("limiteCredito")));
            conta.setTipoBloqueroCobranca(request.getParameter("tipoBloquetoConta"));
            conta.getBeneficiario().setIdfornecedor(Apoio.parseInt(request.getParameter("factoring_id")));
            conta.getBeneficiario().setRazaosocial(request.getParameter("factoring"));
            conta.getFornecedor().setIdfornecedor(Apoio.parseInt(request.getParameter("idfornecedor")));            
            conta.setAtivarEnvioRemessaPagamentos(Apoio.parseBoolean(request.getParameter("ativarEnvioRemessaPag")));
            conta.setSequencialArquivoRemessa(request.getParameter("sequencialArquivoRemessa"));            
            conta.setLayoutRemessa(request.getParameter("layoutRemessa"));            
            conta.setNumeroConvenioPagamento(request.getParameter("convenioPagamento"));
            conta.setCooperativa(request.getParameter("cooperativa"));
            conta.setValorTaxaRecalculo(Apoio.parseDouble(request.getParameter("valorRecalculoBoleto")));

            if (acao.equals("atualizar")) {
                conta.setIdConta(Integer.parseInt(request.getParameter("id")));
            }

            cadConta.setConta(conta);

            //Verificando se vai incluir ou alterar
            boolean erro = !(acao.equals("incluir") ? cadConta.Inclui() : cadConta.Atualiza());
            //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
            if (erro) {
                response.getWriter().append("err<=>" + cadConta.getErros());
            } else {
                response.getWriter().append("err<=>");
            }
            response.getWriter().close();
        }
    }

    boolean carregaconta = (conta != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">

    jQuery.noConflict(); 
     
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdPrincipal','divIntegracaoContabil');
     arAbasGenerico[1] = new stAba('tdRemessaPagamentos','divRemessaPagamentos');
     arAbasGenerico[2] = new stAba('tdAbaBoleto','divBoleto');
     arAbasGenerico[3] = new stAba('tdAbaAuditoria','divAuditoria');

    var nameimput;
    var valorimput;

    
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
    



    //Quando o usuário clica em voltar
    function voltar(){
        location.replace("ConsultaControlador?codTela=19");
    }

    //Salva as informações digitadas
    function salva(acao){
        
        if (!$('chkAtiva').checked) {
            alert("Aviso: Caso essa 'Conta' esteja vinculada a algum 'Usuario', será excluido esse vínculo!");
        }
        //Validar nosso número quando é a conta HSBC
//        if (!validarNossoNumero()) {
//            
//            return false;
//        }
            //usado apenas para CEF numero = 104
            if ($("tipoBloquetoConta").value == "1" && $("codigoOperacao").value.length < "3" && $("banco").value == "2") {
                alert("ATENÇÃO : Para o bloquetos de cobrança do tipo SICOB o código de operação deve conter 3 caracteres.");
                return false;
            }    
            
            
        function ev(resp, codstatus) {
            habilitaSalvar(true);
            if (codstatus==200 && resp=="err<=>")
                location.replace("ConsultaControlador?codTela=19");
            else
                alert(resp.split("<=>")[1]);
        }
        
        var banco = getTextSelect($("banco"));
        if(banco.split("-")[0]=='756'){
            if (wasNull('convenio')){
                alert("Informe todos os dados obrigatórios corretamente.");
                return false;
            }
        }
        

        if (!wasNull('descricao,fi_abreviatura'))
        {
            habilitaSalvar(false);
            if (acao == "atualizar")
                acao += "&id=<%=(conta != null ? conta.getIdConta() : 0)%>";
            

            requisitaAjax("./cadconta?acao="+acao+"&"+
                concatFieldValue("numero,digito_conta,agencia,digito_agencia,descricao,tipo_conta,idfilial,banco,driver_cheque,plano_contas_id,carteira,convenio,codigoOperacao,instrucao1,instrucao2,instrucao3,instrucao4,instrucao5,nossoNumero,jurosAcrescimo,codProtesto,diasProtesto,codDevolucao,diasDevolucao,multa,emissaoBoleto,limiteCredito,tipoBloquetoConta,factoring_id,valorRecalculoBoleto") +
                "&ativo="+$('chkAtiva').checked +
                "&cobrancaComRegistro="+$('cobrancaComRegistro').checked +
                "&utilizaCarta="+$('chkUtilizaCartaFrete').checked+"&utilizaViagem="+$('chkUtilizaAdiantamentoViagem').checked+"&idfornecedor="+$("idfornecedor").value
                +"&ativarEnvioRemessaPag="+$("ativarEnvioRemessaPag").checked+"&sequencialArquivoRemessa="+$("sequencialArquivoRemessa").value 
                +"&layoutRemessa="+$("layoutRemessa").value 
                +"&convenioPagamento="+$("convenioPagamento").value
                +"&cooperativa="+$("cooperativa").value
                +"&cooperativa="+$("cooperativa").value 
                , ev);
           
        }else{
            alert("Informe todos os dados obrigatórios corretamente.");
        }
        
        
        
    }

    function excluirconta(){

        if (confirm("Deseja mesmo excluir esta conta?"))
        {
            location.replace("./consultaconta?acao=excluir&id="+<%=(acao.equals("editar") ? conta.getIdConta() : 0)%>);
        }
    }

    function habilitaSalvar(opcao){
        document.getElementById("salvar").disabled = !opcao;
        document.getElementById("salvar").value = (opcao ? "Salvar" : "Enviando...");
    }
  
    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    function localizabeneficiario(){
        post_cad = window.open('./localiza?acao=consultar&idlista=43','Beneficiario',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    
    function habilitarBoletoCaixa(){
        var banco = $("banco").value;
        
        $("tipoBloquetoConta").style.display = "none";
        $("bloqueto").style.display = "none";
        $("codOperacao").innerHTML = "Cód. Operação:";
        $("codigoOperacao").maxLength = "3";
        

        switch(banco){
            case "2":
                $("tipoBloquetoConta").style.display = "";
                $("bloqueto").style.display = "";
                break;
            case "7":
                $("codOperacao").innerHTML = "Range Nosso Número:";
                $("codigoOperacao").maxLength = "5";
                break;
        }
        if(banco=='5' || banco =='23'){
            $("tdRemessaPagamentos").style.display = "";
        }else{
            $("tdRemessaPagamentos").style.display = "none";
            
        }
        if(banco=='12'){
            $("trLayoutRemessa").style.display="";
        }else{
            $("trLayoutRemessa").style.display="none";
        }
        var bancoT = getTextSelect($("banco"));
        if(bancoT.split('-')[0]=='756'){
            $("trSicoob").style.display = "";
        }else{
            $("trSicoob").style.display = "none";            
        }
        
    }
    
    function validarNossoNumero(){
        if ($("banco").value == "7" && ($("codigoOperacao") != undefined && $("codigoOperacao").value.length != 5)) {
            alert("ATENÇÃO: O campo Range Nosso Número para essa conta precisa ter 5 dígitos.");
            $("codigoOperacao").focus();
            return false;
        }else{
            return true;
        }
    }
    function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "conta";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregaconta ? cadConta.getConta().getIdConta(): 0)%>;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    function setDataAuditoria(){
            $("dataDeAuditoria").value="<%=carregaconta ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregaconta ? Apoio.getDataAtual() : "" %>" ;   

        }
    
    function atribuicombos(){
    <%if (carregaconta) {%>
            $("tipo_conta").value = "<%=conta.getTipo_conta()%>";
    <%}%>
        }
        
    function localizarContaContabil(conta){
        jQuery.ajax({
            url: "./PlanoContaControlador?",
            dataType: "text",
            method : "post",
            async : false,
            data: {
                conta: conta,
                acao : "localizarContaContabil"
            },
            success: function(data) {
                var conta = jQuery.parseJSON(data);
                espereEnviar("",false);
                if (conta == null){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else if(conta == ''){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else if(conta.erro == 'true'){
                    alert("Plano de contas não encontrado!");
                    return false;
                }else{
                    $('plano_contas_id').value = conta.id;
                    $('cod_conta').value = conta.codigo;
                    $('plano_conta_descricao').value = conta.descricao;
                }
            },error: function(){
                alert("Erro inesperado, favor refazer a operação.");
            }
        });
    }
    
    function limparFornecedor(){
        $("fornecedor").value = "";
        $("idfornecedor").value = "0";
    }
    
    function abrirLocalizaFornecedor(){
        popLocate(21, "Fornecedor","");
    }
    
    function limparContaContabil(){
        $('plano_conta_descricao').value = "";
        $('cod_conta').value = "";
        $('plano_contas_id').value = "0";
    }
        

</script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro de contas bancárias/caixa</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="javascript:atribuicombos();habilitarBoletoCaixa();setDataAuditoria();AlternarAbasGenerico('tdAbaBoleto','divBoleto')">
        <img alt="" src="img/banner.gif" >
        <br>
        <!-- CAMPOS OCULTOS -->
        <!-- FALTA O CODIGO DA FILIAL-->
        <input type="hidden" name="idfilial" id="idfilial" value="<%=(carregaconta ? conta.getFilial().getIdfilial() : 0)%>">
        <input type="hidden" id="plano_contas_id" value="<%=(carregaconta ? conta.getPlanoConta().getId() : 0)%>">


        <table width="50%" align="center" class="bordaFina" >
            <tr >
                <td width="283"><div align="left"><b>Cadastro de contas banc&aacute;rias/caixa</b></div></td>
                <td width="71"><div align="right">
                        <% if (acao.equals("editar") && nivelUser == 4 && Boolean.parseBoolean(request.getParameter("ex"))) //se o paramentro vier com valor diferente de nulo ai pode excluir
                            {%>
                        <input  name="excluir" type="button" class="botoes" value="Excluir" alt="Exclui o cliente atual" onClick="javascript:excluirconta();">
                        <%}%>
                    </div></td>
                <td width="66" ><div align="right">
                        <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:tryRequestToServer(function(){voltar();});">
                    </div></td>
            </tr>
        </table>
        <br>

        <table width="50%" border="0" align="center" cellpadding="2" class="bordaFina">
            <tr class="tabela">
                <td height="21" colspan="4" align="center"><strong>Dados principais</strong>                </td>
            </tr>
            <tr>
                <td width="19%" class="TextoCampos">*Descri&ccedil;&atilde;o
                    <div align="left"> </div></td>
                <td colspan="2" class="celulazebra2"><input name="descricao" type="text" id="descricao" value="<%=(carregaconta ? conta.getDescricao() : "")%>" size="35" maxlength="50" class="inputtexto"></td>
                <td class="celulazebra2">
                    <div align="center">
                        <label>
                            <input type="checkbox" name="chkAtiva" id="chkAtiva" <%=(carregaconta ? (conta.isContaAtiva() ? "checked" : "") : "checked")%>>
                            Conta ativa
                        </label>
                    </div>
                </td>
            </tr>
            <tr>
                <td width="19%" class="TextoCampos">Tipo conta:</td>
                <td width="33%" class="celulazebra2"> <select name="tipo_conta" id="tipo_conta" class="inputtexto">
                        <option value="co">Conta Corrente</option>
                        <option value="ca">Carteira</option>
                    </select>
                </td>
                <td colspan="2" class="celulazebra2"></td>
            </tr>
            <tr>
                <td width="19%" class="TextoCampos">Banco:</td>
                <td colspan="3" class="celulazebra2"> 
                    <select name="banco" id="banco" onchange="habilitarBoletoCaixa()" class="inputtexto">
                        <% BeanConsultaBanco banco = new BeanConsultaBanco();
                            banco.setConexao(Apoio.getUsuario(request).getConexao());
                            banco.MostrarTudo();
                            ResultSet rs = banco.getResultado();
                            while (rs.next()) {%>
                        <option value="<%=rs.getString("idbanco")%>" <%=(carregaconta && rs.getInt("idbanco") == conta.getBanco().getIdBanco() ? "selected" : "")%>  ><%=rs.getString("numero") + "-" + rs.getString("descricao")%></option>
                        <%}%>
                    </select>
                    <div align="center">
                    </div>
                </td>
            </tr>
            <tr>
                <td width="19%" class="TextoCampos">N&ordm; conta-DV:</td>
                <td width="33%" class="celulazebra2"><input name="numero" type="text" id="numero"  value="<%=(carregaconta ? conta.getNumero() : "")%>" size="10" maxlength="20" class="inputtexto">
                    -
                    <input name="digito_conta" type="text" id="digito_conta"  value="<%=(carregaconta ? conta.getDigito_conta() : "")%>" size="1" maxlength="2" class="inputtexto"></td>
                <td width="22%" class="TextoCampos">Ag&ecirc;ncia-DV</td>
                <td width="26%" class="celulazebra2"><input name="agencia" type="text" id="agencia" value="<%=(carregaconta ? conta.getAgencia() : "")%>" size="8" maxlength="6" class="inputtexto">
                    -
                    <input name="digito_agencia" type="text" id="digito_agencia" value="<%=(carregaconta ? conta.getDigito_agencia() : "")%>" size="1" maxlength="2" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">Filial:</td>
                <td colspan="3" class="celulazebra2"><input name="fi_abreviatura" type="text" id="fi_abreviatura"  value="<%=(carregaconta ? conta.getFilial().getAbreviatura() : "")%>" size="40" readonly="true" class="inputReadOnly">
                    <strong>
                        <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                    </strong></td>
            </tr>
            <tr>
                <td class="TextoCampos">Fornecedor:</td>
                <td colspan="3" class="CelulaZebra2">
                    <input type="text" id="fornecedor" name="fornecedor" value="<%=(carregaconta ? conta.getFornecedor().getRazaosocial() : "")%>" size="40" readonly="true" class="inputReadOnly"/>                    
                    <input type="hidden" id="idfornecedor" name="idfornecedor" value="<%=(carregaconta ? conta.getFornecedor().getIdfornecedor() : "0")%>"/>
                    <input type="button" id="btnLocalizaFornecedeor" name="btnLocalizaFornecedor" value="..." class="botoes" onclick="javascript:tryRequestToServer(function(){abrirLocalizaFornecedor()});"/>
                    <img alt="" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onclick="javascript:limparFornecedor();">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Driver cheque:</td>
                <td class="celulazebra2">
                    <select name="driver_cheque" id="driver_cheque" class="inputtexto">
                        <option value="">&nbsp;</option>
                        <%        Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "chq.txt");
                            for (int i = 0; i < drivers.size(); ++i) {
                                String driv = (String) drivers.get(i);
                                driv = driv.substring(0, driv.lastIndexOf("."));
                        %>
                        <option value="<%=driv%>" <%=(carregaconta && driv.equals(conta.getDriver_cheque()) ? "selected" : "")%>><%=driv%>&nbsp;</option>
                        <%}%>
                    </select>	</td>
                <td colspan="2" class="celulazebra2">
                    Limite de Crédito: 
                    <input id="limiteCredito" class="inputtexto" type="text"  maxlength="15" size="10" onchange="seNaoFloatReset(this,'0.00');" name="limiteCredito" value="<%=(carregaconta ? conta.getLimiteCredito() : "0.00")%>">
                </td>
            </tr>
            <tr>
                <td colspan="2" class="celulazebra2">
                    <div align="center">
                        <label>
                            <input type="checkbox" name="chkUtilizaCartaFrete" id="chkUtilizaCartaFrete" <%=(carregaconta ? (conta.isUtilizaCartaFrete() ? "checked" : "") : "checked")%>>
                            Utilizar no contrato de frete
                        </label>
                    </div>
                </td>                            
                <td colspan="2" class="celulazebra2">
                    <div align="center">
                        <label>
                            <input type="checkbox" name="chkUtilizaAdiantamentoViagem" id="chkUtilizaAdiantamentoViagem" <%=(carregaconta ? (conta.isUtilizaAdiantamentoViagem() ? "checked" : "") : "checked")%>>
                            Utilizar no adiantamento de viagem                            
                        </label>
                    </div>
                </td>
            </tr>
        </table>
                <table width="50%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdAbaBoleto" class="menu" onclick="AlternarAbasGenerico('tdAbaBoleto','divBoleto')"> Geração de boletos </td>
                                  <td id="tdRemessaPagamentos" class="menu-sel" onclick="AlternarAbasGenerico('tdRemessaPagamentos','divRemessaPagamentos')"> Remessa para Pagamentos
                                  <td style='display: <%= (cfg.getIsContabil()?"":"none") %>'id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal','divIntegracaoContabil')"> Integração Contábil
                                  <td style='display: <%=carregaconta && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                    
                               </tr>
                            </table>
                        </td> 
                    </tr>
               </table>          
       <div id="divIntegracaoContabil">                    
        <table width="50%" align="center" class="bordaFina" style='display: <%= (cfg.getIsContabil()?"":"none") %>' >                   
             <tr>
                <td class="TextoCampos">Conta cont&aacute;bil:</td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="cod_conta" type="text" id="cod_conta" size="10"  class="inputTexto" value="<%=(carregaconta ? conta.getPlanoConta().getCodigo() : "")%>" onkeypress="if (event.keyCode==13) localizarContaContabil(this.value);">
                    <input type="text" class="inputReadOnly" id="plano_conta_descricao" name="plano_conta_descricao" size="25" value="<%=(carregaconta ? conta.getPlanoConta().getDescricao() : "")%>" />
                    <strong>
                        <input name="localiza_conta" type="button" class="botoes" id="localiza_conta" value="..."
                               onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.PLANO_CONTAS%>', 'Plano_de_contas')">
                        <img alt="" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:limparContaContabil();"></strong></td>
            </tr>
          
        </table>
       </div> 
       <div id="divRemessaPagamentos" style="display: none">                    
        <table width="50%" align="center" class="bordaFina">                   
             <tr>
                <td class="TextoCampos"><input type="checkbox" id="ativarEnvioRemessaPag" name="ativarEnvioRemessaPag" <%=(carregaconta ? (conta.isAtivarEnvioRemessaPagamentos()? "checked" : "") : "checked")%>></td>
                <td colspan="3" class="celulazebra2">
                   Ativar envio de remessa de pagamentos
                    
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Sequencial para arquivo de remessa:</td>
                <td  class="CelulaZebra2">
                    <input name="sequencialArquivoRemessa" type="text" id="sequencialArquivoRemessa" size="7" maxlength="5" class="inputtexto" value="<%=(carregaconta ? conta.getSequencialArquivoRemessa(): "")%>">                
                </td>
            </tr>
            <tr>
                <td  class="TextoCampos">N° Convênio para Pagamento:</td>
                <td class="CelulaZebra2">
                    <input name="convenioPagamento" type="text" id="convenioPagamento" size="20" maxlength="30" class="inputtexto" value="<%=(carregaconta ? conta.getNumeroConvenioPagamento(): "")%>">                </td>
               
            </tr>
          
        </table>
       </div> 
       <div id="divBoleto">
         <table width="50%" align="center" class="bordaFina" >   
                <tr>
                    <td class="textoCampos" >
                        <div id="bloqueto" name="bloqueto" >Bloquetos de Cobrança</div>
                    </td>
                    <td class="celulazebra2">
                        <select name="tipoBloquetoConta" id="tipoBloquetoConta" class="inputtexto">
                            <option value="1" <%=(carregaconta && conta.getTipoBloqueroCobranca().equals("1") ? "SELECTED" : "")%> >  SICOB  </option>
                            <option value="0" <%=(carregaconta && conta.getTipoBloqueroCobranca().equals("0") ? "SELECTED" : "")%> >  SIGCB  </option>
                        </select>
                    </td>
                    <td class="textoCampos">
                    </td>
                    <td class="celulazebra2">
                    </td>
                </tr>
                <td class="TextoCampos">Carteira:</td>
                <td  class="CelulaZebra2">
                    <input name="carteira" type="text" id="carteira" size="7" maxlength="5" class="inputtexto" value="<%=(carregaconta ? conta.getCarteira() : "")%>">                </td>
                <td class="TextoCampos">
                    <label id="codOperacao" >Cód. Operação:</label>
                </td>
                <!-- Segundo Deivid, este campo é utilizado como um curinga, ele sugeriu que para o HSBC este fosse utilziado como o RANGE do NOSSO NUMERO NO HSBC-->
                <td class="CelulaZebra2">
                    <input name="codigoOperacao" type="text" id="codigoOperacao" size="6" maxlength="3" onblur="validarNossoNumero();" class="inputtexto" value="<%=(carregaconta ? conta.getCodigoOperacao() : "")%>">                </td>
            </tr>
            <tr>
                <td  class="TextoCampos">N° Convênio:</td>
                <td class="CelulaZebra2">
                    <input name="convenio" type="text" id="convenio" size="20" maxlength="30" class="inputtexto" value="<%=(carregaconta ? conta.getNumeroConvenio() : "")%>">                </td>
                <td class="TextoCampos">&Uacute;ltimo Nosso N&uacute;mero:</td>
                <td class="CelulaZebra2"><input name="nossoNumero" type="text" id="nossoNumero" size="15" onBlur="seNaoIntReset(this, '0')"  class="inputtexto" value="<%=(carregaconta ? conta.getUltimoNossoNumero() : "0")%>"></td>
            </tr>
            
            <tr>
                <td  class="TextoCampos">Protesto:</td>
                <td class="CelulaZebra2"><select name="codProtesto" id="codProtesto" class="inputtexto" style="width: 160px">
                        <option value="1" <%=(carregaconta && conta.getCodProtesto() == 1 ? "SELECTED" : "")%>>Protestar dias corridos</option>
                        <option value="2" <%=(carregaconta && conta.getCodProtesto() == 2 ? "SELECTED" : "")%>>Protestar dias &uacute;teis</option>
                        <option value="3"<%=(!carregaconta ? "SELECTED" : "")%> <%=(carregaconta && conta.getCodProtesto() == 3 ? "SELECTED" : "")%>>N&atilde;o protestar</option>
                        <option value="4" <%=(carregaconta && conta.getCodProtesto() == 4 ? "SELECTED" : "")%>>Protestar fim falimentar - Dias &uacute;teis</option>
                        <option value="5" <%=(carregaconta && conta.getCodProtesto() == 5 ? "SELECTED" : "")%>>Protestar fim falimentar - Dias corridos</option>
                        <option value="9" <%=(carregaconta && conta.getCodProtesto() == 9 ? "SELECTED" : "")%>>Cancelamento protesto autom&aacute;tico</option>
                    </select></td>
                <td class="TextoCampos">Dias protesto:</td>
                <td class="CelulaZebra2"><input type="text" class="inputtexto" size="7" id="diasProtesto" onChange="seNaoIntReset(this, '0')" name="diasProtesto" value="<%=(carregaconta ? conta.getDiasProtesto() : "0")%>"></td>
            </tr>
            <tr>
                <td  class="TextoCampos">Devolução:</td>
                <td class="CelulaZebra2"><select name="codDevolucao" id="codDevolucao" class="inputtexto" style="width: 160px">
                        <option value="1" <%=(carregaconta && conta.getCodDevolucao() == 1 ? "SELECTED" : "")%>>SIM</option>
                        <option value="2" <%=(carregaconta && conta.getCodDevolucao() == 2 ? "SELECTED" : "")%>>NÃO</option>
                    </select></td>
                <td class="TextoCampos">Dias devolução:</td>
                <td class="CelulaZebra2"><input type="text" class="inputtexto" size="7" id="diasDevolucao" onChange="seNaoIntReset(this, '0')" name="diasDevolucao" value="<%=(carregaconta ? conta.getDiasDevolucao() : "0")%>"></td>
            </tr>
            <tr>
                <td colspan="2"  class="TextoCampos"><div align="center">
                        <select name="emissaoBoleto" id="emissaoBoleto" class="inputtexto">
                            <option value="e" <%=(carregaconta && conta.getEmissaoBoletoPor().equals("e") ? "SELECTED" : "")%>>Os boletos serão emitidos pela empresa</option>
                            <option value="b" <%=(carregaconta && conta.getEmissaoBoletoPor().equals("b") ? "SELECTED" : "")%>>Os boletos serão emitidos pelo banco</option>
                        </select>
                    </div></td>
                <td colspan="2"  class="TextoCampos">
                    <div align="center">
                        <label>
                            <input type="checkbox" name="cobrancaComRegistro" id="cobrancaComRegistro" <%=(carregaconta && conta.isCobrancaComRegistro() ? "checked" :"")%> >
                            Cobrança com Registro                            
                        </label>
                    </div>
                </td>
            </tr>
            <tr>
                <td  class="TextoCampos">% Juros:</td>
                <td class="CelulaZebra2"><input type="text" size="6" class="inputtexto" id="jurosAcrescimo" onChange="seNaoFloatReset(this, '0.00')" name="jurosAcrescimo" value="<%=(carregaconta ? conta.getJurosAcrescimo() : "0.0")%>"></td>
                <td class="TextoCampos">% Multa:</td>
                <td class="CelulaZebra2"><input type="text" size="6" class="inputtexto" id="multa" onChange="seNaoFloatReset(this, '0.00')" name="multa" onBlur="" value="<%=(carregaconta ? conta.getMulta() : "0.0")%>"></td>
            </tr>
            <tr>
                <td  class="TextoCampos" style="width: 160px;">Taxa de recálculo de boleto:</td>
                <td class="CelulaZebra2" colspan="3"><input type="text" size="6" class="inputtexto" id="valorRecalculoBoleto" onChange="seNaoFloatReset(this, '0.00')" name="valorRecalculoBoleto" value="<%=(carregaconta ? conta.getValorTaxaRecalculo(): "0.0")%>"></td>
            </tr>
            <tr>
                <td class="TextoCampos">Beneficiário: </td>
                <td colspan="3" class="celulazebra2">
                    <input name="factoring" type="text" id="factoring"  value="<%=(carregaconta ? conta.getBeneficiario().getRazaosocial() : "")%>" size="40" readonly="true" class="inputReadOnly">
                    <input name="localiza_beneficiario" type="button" class="botoes" id="localiza_beneficiario" value="..." onClick="javascript:tryRequestToServer(function(){localizabeneficiario();})">
                    <input name="factoring_id" type="hidden" id="factoring_id" value="<%=(carregaconta ? conta.getBeneficiario().getIdfornecedor(): "")%>" >
                    <img alt="" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:$('factoring').value='';$('factoring_id').value=0;"></strong></td>
                </td>
            </tr>
            <tr id="trSicoob" style="display: none">
                <td  class="TextoCampos">Cooperativa:</td>
                <td class="CelulaZebra2"><input type="text" size="6" class="inputtexto" id="cooperativa" name="cooperativa" value="<%=(carregaconta ? conta.getCooperativa(): "")%>"></td>
                <td  class="TextoCampos"></td>
                <td class="CelulaZebra2"></td>
            </tr> 
            <tr id="trLayoutRemessa" name="trLayoutRemessa">
                <td class="TextoCampos">Layout Arquivo Remessa: </td>
                <td colspan="3" class="celulazebra2">
                       <select name="layoutRemessa" id="layoutRemessa" class="inputtexto">
                            <option value="240" <%=(carregaconta && conta.getLayoutRemessa().equals("240") ? "SELECTED" : "")%>>240</option>
                            <option value="400" <%=(carregaconta && conta.getLayoutRemessa().equals("400") ? "SELECTED" : "")%>>400</option>
                        </select>
                </td>
            </tr>
            
            <tr class="celula">
                <td colspan="4"><div align="center">Instruções</div></td>
            </tr>
            <tr>
                <td colspan="4">
                    <table width="100%">
                        <tr>
                            <td width="12%" class="TextoCampos">Variáveis:</td>
                            <td width="28%" class="CelulaZebra2">
                                <a style="text-decoration:none" href="javascript:concatInst('@@VALOR_MULTA')">@@VALOR_MULTA</a>
                            </td>
                            <td width="30%" class="CelulaZebra2">
                                <a style="text-decoration:none" href="javascript:concatInst('@@VALOR_JUROS_MES')">@@VALOR_JUROS_MES</a>
                            </td>
                            <td width="30%" class="CelulaZebra2">
                                <a style="text-decoration:none" href="javascript:concatInst('@@VALOR_JUROS_DIA')">@@VALOR_JUROS_DIA</a>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Instrução 1:</td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="instrucao1" type="text" class="inputtexto" id="instrucao1" value="<%=(carregaconta ? conta.getInstrucao1() : "")%>" size="60" maxlength="60" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Instrução 2:</td>
                <td  colspan="3" class="CelulaZebra2">
                    <input name="instrucao2" type="text" class="inputtexto" id="instrucao2" value="<%=(carregaconta ? conta.getInstrucao2() : "")%>" size="60" maxlength="60" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Instrução 3:</td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="instrucao3" type="text" class="inputtexto" id="instrucao3" value="<%=(carregaconta ? conta.getInstrucao3() : "")%>" size="60" maxlength="60" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                 </td>
            </tr>
            <tr>
                <td class="TextoCampos">Instrução 4:</td>
                <td colspan="4" class="CelulaZebra2">
                    <input name="instrucao4" type="text" class="inputtexto" id="instrucao4" value="<%=(carregaconta ? conta.getInstrucao4() : "")%>" size="60" maxlength="60" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                 </td>
            </tr>
            <tr>
                <td class="TextoCampos">Instrução 5:</td>
                <td colspan="5" class="CelulaZebra2">
                    <input name="instrucao5" type="text" class="inputtexto" id="instrucao5" value="<%=(carregaconta ? conta.getInstrucao5() : "")%>" size="60" maxlength="60" onblur="javascript:tryRequestToServer(function(){setImput(id, value)});">                 </td>
            </tr>
    </table>
    </div>
     <div id="divAuditoria" >
        <table width="50%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregaconta && nivelUser == 4 ? "" : "none"%>'>
             <%@include file="/gwTrans/template_auditoria.jsp" %>
        </table>
     </div>

    <br>       
    <%if(nivelUser == 4 ){%>
    <table width="50%" align="center" class="bordaFina" >        
                <tr class="CelulaZebra2">
                    <td colspan="6"> <center>

                    <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                    <%}%>
                </center></td>
        </tr>
    </table>

<br>
