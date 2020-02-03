<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         conhecimento.manifesto.BeanConsultaManifesto,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio"%>

<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<%
            int linha = 0;
//ATENCAO! A MSA está abaixfo
// DECLARANDO e inicializando as variaveis usadas no JSP
            BeanConsultaManifesto selmanif = null;
            String acao = request.getParameter("acao");
            String idCidades = "";
            String pedidoNF = (request.getParameter("pedidoNF") != null ? request.getParameter("pedidoNF"):"");
            String numeroCarga = (request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga"):"");
            String ufsDestino = (request.getParameter("ufsDestino") != null ? request.getParameter("ufsDestino"):"");
            boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
            boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
            boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
            String tipoTransporte = (request.getParameter("tipoTransporte") != null ? request.getParameter("tipoTransporte") : "false");

// -- INICIO DO MSA
            if (Apoio.getUsuario(request) == null) {
                response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
            }
            acao = ((acao == null) ? "" : acao);
            
// -- FIM DO MSA

//Instanciando o bean pra trazer os CTRC's
            selmanif = new BeanConsultaManifesto();
            selmanif.setConexao(Apoio.getUsuario(request).getConexao());

            String marcados = (request.getParameter("marcados") == null ? "0" : request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados"));
            boolean mostraTudo = Boolean.parseBoolean(request.getParameter("mostratudo"));
            String idMotorista = (request.getParameter("idmotorista") == null ? "0" : request.getParameter("idmotorista"));
            String idRemetente = (request.getParameter("idremetente") == null ? "0" : request.getParameter("idremetente"));
            String idDestinatario = (request.getParameter("iddestinatario") == null ? "0" : request.getParameter("iddestinatario"));
            String idConsignatario = (request.getParameter("idconsignatario") == null ? "0" : request.getParameter("idconsignatario"));
            String idRedespacho = (request.getParameter("idredespacho") == null ? "0" : request.getParameter("idredespacho"));
            String idVeiculo = (request.getParameter("idveiculo") == null ? "0" : request.getParameter("idveiculo"));
            String notasFiscais = (request.getParameter("notasFiscais") == null ? "" : request.getParameter("notasFiscais"));
            String condicaoctrc;//não vai mais pegar do request. o campo vai receber o valor dependendo da validação abaixo.
            
            // se em apoio o campo para aceitar apenas CTRC confirmado estiver marcado.
            if(Apoio.getConfiguracao(request).isCtrcsConfirmadosParaManifesto()){
                condicaoctrc = " and (is_cte_confirmado(sl.serie, sl.especie, sl.id) OR sl.especie <> 'CTE' OR sl.serie NOT SIMILAR TO '[0-9]') ";   
            }else{
                condicaoctrc = " and true ";
            }
            
            String serieCte = (request.getParameter("serieCte") == null ? "" : request.getParameter("serieCte"));
            String numeroCTes = (request.getParameter("numeroCTes") == null ? "" : request.getParameter("numeroCTes"));
            String numeroPedidos = (request.getParameter("numeroPedidos") == null ? "" : request.getParameter("numeroPedidos"));
            String tipoDestino = (request.getParameter("tipoDestino") == null ? "" : request.getParameter("tipoDestino"));
            boolean isFilialCidadesAtendidas = Apoio.parseBoolean(request.getParameter("isFilialCidadesAtendidas"));
            String idfilial2 = (request.getParameter("idfilial2") == null ? "0" : request.getParameter("idfilial2"));
            idCidades = (request.getParameter("cidades") == null ? "" : request.getParameter("cidades"));
            String romaneio = (request.getParameter("romaneio") == null ? "" : request.getParameter("romaneio"));
%>          
<script language="javascript" type="text/javascript">
    var homePath = '${homePath}';

    var grupoCliente = '${param["grupoCliente"]}';
    var setorEntrega = '${param["setorEntrega"]}';

    jQuery.noConflict();
    var quant = ""; //Quantidade de resultados
    var indexCid = 0;
    function fechar(){
        window.close();
    }

    function localizacid_destino(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_DESTINO%>','destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function seleciona(){      
        var retorno = "";

        for (var i = 0; i <= quant; ++i){
            if(document.getElementById("chk-"+i) != null){
                if (document.getElementById("chk-"+i).checked){
                    if (retorno == ""){
                        retorno += document.getElementById("chk-"+i).value;         
                    }else  {
                        retorno += ","+document.getElementById("chk-"+i).value
                    }
                }
            }
        }

        if (retorno == ""){
            return alert("Informe no mínimo um CT.");
        }
    
        if (window.opener.calcula != null)
            window.opener.calcula(retorno,0,'<%=request.getParameter("acaoDoPai")%>');
       
            fechar();   
    }

    function pesquisar(){        
        try{
        $("acaoDoPai").value = '<%=request.getParameter("acaoDoPai")%>';
        $("filial").value = '<%=request.getParameter("filial")%>';
        $("mostratudo").value = '<%=request.getParameter("mostratudo")%>';
        $("tipoDestino").value = '<%=request.getParameter("tipoDestino")%>';
        $("idfilial2").value = '<%=request.getParameter("idfilial2")%>';
        $("isFilialCidadesAtendidas").value = '<%=request.getParameter("isFilialCidadesAtendidas")%>';
        $("tipo").value = '<%=request.getParameter("tipo")%>';
        $("cidades").value = concatCidades();
        document.formulario.action = "./selecionactrc?acao=consultar";
        document.formulario.submit();
        }catch(e){
            console.log(e);
        }

    }

    function addCid(id, cidade, uf){
        _tr = Builder.node('TR', {id:'trCid'+indexCid, className:'CelulaZebra2'},
        [Builder.node('TD',{colSpan:'2'}, 
            [Builder.node('INPUT', {type:'text', name:'cidade'+indexCid, id:'cidade'+indexCid, 
                    size:'15', value:cidade, className:'inputReadOnly'}),
                Builder.node('INPUT', {type:'hidden', name:'cidadeId'+indexCid, id:'cidadeId'+indexCid, 
                    value:id, className:'fieldMin'}),
                Builder.node('INPUT', {type:'text', name:'uf'+indexCid, id:'uf'+indexCid, 
                    size:'2', value:uf, className:'inputReadOnly'}),
                Builder.node('INPUT', {type:'button', name:'localizaCid_'+indexCid, id:'localizaCid_'+indexCid, 
                    value:'...', className:'botoes',
                    onClick:'javascript:launchPopupLocate(\'./localiza?acao=consultar&idlista=12\',\'destino_'+indexCid+'\');'}),
                Builder.node('IMG', {name:'limpaCid_'+indexCid, id:'limpaCid_'+indexCid, src:'img/borracha.gif', title:'Limpar agente', className:'imagemLink', align:'absbottom', 
                    onClick:'javascript:limparCidade('+indexCid+');'})
            ])
        ]);   
        $('cid').appendChild(_tr);

        $('cidade'+indexCid).readOnly = true;
        $('uf'+indexCid).readOnly = true;

        indexCid++;      
    }

    function carregando(){
        <%if (request.getParameter("cidades") == null || request.getParameter("cidades").equals("")) {%>
            addCid(0,'','');
        <%}else{
            String cidades = request.getParameter("cidades");
            int qtdCidades = cidades.split("!!").length;
            for (int k = 0; k < qtdCidades; ++k) {%>
                addCid(<%=cidades.split("!!")[k].split("!-")[0]%>,'<%=cidades.split("!!")[k].split("!-")[1]%>','<%=cidades.split("!!")[k].split("!-")[2]%>');
                       <%idCidades += (idCidades.equals("") ? "" : ",") + cidades.split("!!")[k].split("!-")[0];
            }
        }%>
        
    }

    function aoClicarNoLocaliza(idjanela){
        //localizando cidade
        if(idjanela == 'destino'){
            addCid($('idcidadedestino').value, $('cid_destino').value, $('uf_destino').value);
        }else if(idjanela.split('_')[0] == 'destino'){
            $('cidadeId'+idjanela.split('_')[1]).value = $('idcidadedestino').value;
            $('cidade'+idjanela.split('_')[1]).value = $('cid_destino').value;
            $('uf'+idjanela.split('_')[1]).value = $('uf_destino').value;
        }
    }

    function limparCidade(idx){
        $('cidadeId'+idx).value = '0';
        $('cidade'+idx).value = '';
        $('uf'+idx).value = '';
    }

    function concatCidades(){
        var cd = "";
        for (i = 0; i < indexCid; ++i){
            if ($("cidadeId"+i) != null && $("cidadeId"+i).value != '0'){
                cd += $("cidadeId"+i).value+"!-"+$("cidade"+i).value+"!-"+$("uf"+i).value+"!-"+
                    (i == indexCid - 1? "" : "!!");
            }
        }
        return cd;
    }

    function checkCtrc(evento){
        if( evento.keyCode==13 ) {
            //for (var i = 0; i <= quant; ++i){
                if($("hidden_ctrc_"+$("selCtrc").value) != null){
                    $("chk-"+$("hidden_ctrc_"+$("selCtrc").value).value).checked = true;
                    $("selCtrc").value = "";
                        //break;
                }else{
                    alert("CTRC não encontrado.");
                }
            //}
        }
    }
    
    function checkTodosCtrcs(){
        if($("chkTodos").checked){
            for (var j = 0; j < quant; ++j){
                document.getElementById("chk-"+j).checked = true;
            }
        }else{
            for (var i = 0; i <= quant; ++i){
                $("chk-"+i).checked = false;
            }

        }
    }
    
    function retornaPai(){
        try{
        var cteSelecionados = "";
        for (var i = 0; i <= quant -1; ++i){
        //console.log("quantidade : " + i);
        //console.log("quantidade retorna pai : " + $("chk-"+i).checked);
        //console.log("quantidade valor : " + $("chk-"+i).value);
        
            if($("chk-"+i) != null){
                if ($("chk-"+i).checked){
                    if (cteSelecionados == ""){
                        cteSelecionados += $("chk-"+i).value;
                    }else  {
                        cteSelecionados += ","+$("chk-"+i).value;
                    }
                }
            }
        }
        
        if (cteSelecionados == ""){
            return alert("Informe no mínimo um CT.");
        }
        
        if(window.opener.carregarCTeManifestoAjax != null){
                var separador;
                var arrayCte = cteSelecionados.split(",");
                var cteRemover = '0';
                var arrayCteTela =  window.opener.jQuery("input[id^=idCTe_]").length;
                if(arrayCteTela > 0){
                    for (var i = 0; i<= arrayCteTela;i++){
                        if(window.opener.jQuery("#idCTe_"+i) != null && window.opener.jQuery("#idCTe_"+i).val() != undefined){
                            cteRemover += "," + window.opener.jQuery("#idCTe_"+i).val();
                        }
                    }
                }
               
                window.scrollTo({top: 0,left: 0});
                cteRemover = "0," + cteRemover.replace("0,","");
                window.opener.jQuery("#idCTeRemover").val(cteRemover);
                window.opener.removerCTeManifesto(cteRemover);          
                window.opener.espereEnviar("Aguarde", true);

                document.documentElement.style.overflow = 'hidden';  // firefox, chrome
                document.body.scroll = "no"; // ie only
                
                jQuery('.cobre-tudo').show();
                espereEnviar("Aguarde", true);
                window.opener.jQuery('.cobre-tudo').show();
                
                while (arrayCte.length > 0) {
                    separador = arrayCte.splice(0,200); //separando o CTE em blocos de 200 (Evita erro 400 - Bad Request)
                    window.opener.carregarCTeManifestoAjax(separador.toString(),"localiza","");
                }
                window.opener.espereEnviar("Aguarde", false);
                window.opener.jQuery('.cobre-tudo').hide();
                jQuery('.cobre-tudo').hide();
                espereEnviar("Aguarde", false);
            }
        } catch (e){
            console.log(e);
        }    
        
        window.close();
            
    }
    function abrirLocalizaSetorEntrega(){
            launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.SETOR_ENTREGA%>', 'Setor_Entrega');
        }
</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        
        <title>WebTrans - Selecionar CT-e(s) para o manifesto</title>
        <link href="${homePath}/estilo.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
        <link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
        <link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">

        <style>
            .alpha-old {
                margin-right: 3px !important;
            }
        </style>
    </head>
    
    <body onLoad="carregando();">
        <form method="post" id="formulario" name="formulario">
        <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
        <input name="cid_destino"  type="hidden" class="fieldMin" id="cid_destino" style="background-color:#FFFFF1" value="" size="25" readonly="true">
        <input name="uf_destino"   type="hidden" class="fieldMin" id="uf_destino" style="background-color:#FFFFF1" value="" size="2" readonly="true">
        <input name="marcados"   type="hidden" class="fieldMin" id="marcados" style="background-color:#FFFFF1" value="<%=request.getParameter("marcados")%>" >
        <input name="acaoDoPai"   type="hidden" class="fieldMin" id="acaoDoPai" style="background-color:#FFFFF1" value="">
        <input name="filial"   type="hidden" class="fieldMin" id="filial" style="background-color:#FFFFF1" value="">
        <input name="mostratudo"   type="hidden" class="fieldMin" id="mostratudo" style="background-color:#FFFFF1" value="">
        <input name="tipoDestino"   type="hidden" class="fieldMin" id="tipoDestino" style="background-color:#FFFFF1" value="">
        <input name="idfilial2"   type="hidden" class="fieldMin" id="idfilial2" style="background-color:#FFFFF1" value="">
        <input name="isFilialCidadesAtendidas"   type="hidden" class="fieldMin" id="isFilialCidadesAtendidas" style="background-color:#FFFFF1" value="">
        <input name="tipo"   type="hidden" class="fieldMin" id="tipo" style="background-color:#FFFFF1" value="">
        <input name="cidades"   type="hidden" class="fieldMin" id="cidades" style="background-color:#FFFFF1" value="">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr >
                <td width="619"><div align="left"><b>Selecionar CT-e(s) para o manifesto</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr> 
                <td class="TextoCampos" width="25%">Intervalo de datas:</td>
                <td width="25%" class="CelulaZebra2"><input name="dtinicial" class="fieldDate" type="text" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                                                onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)"> 
                    e 
                    <input name="dtfinal" type="text" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                           onBlur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                
              <td width="20%" class="TextoCampos">Apenas o(s) destino(s):<span class="CelulaZebra2">
                      <img src="img/add.gif" border="0" class="imagemLink "  title="Adicionar um novo Destino" onClick="javascript:localizacid_destino();"></span>
              </td>
          <td width="30%" class="CelulaZebra2">
<table width="100%" border="0">
                        <tbody id="cid">
                        </tbody>
                    </table>
                    
                    
                </td>
          </tr>
            <tr>
              <td width="189" class="TextoCampos">Tipo:</td>
              <td class="CelulaZebra2" >
                        <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:160px;"   class="fieldMin">
                            <%= emiteRodoviario && emiteAereo && emiteAquaviario? "<option value='false'" + (tipoTransporte != null && tipoTransporte.equals("false") ? "selected" : "r,a,q") + ">Todos</option>" : ""%>
                            <%= emiteRodoviario ? "<option value='r'" + (tipoTransporte != null && tipoTransporte.equals("r") ? "selected" : "") + ">CTR - Transp. Rodoviário</option>" : ""%>
                            <%= emiteAereo ? "<option value='a'" + (tipoTransporte != null && tipoTransporte.equals("a") ? "selected" : "") + " >CTA - Transp. A&eacute;reo</option>" : ""%>
                            <%= emiteAquaviario ? "<option value='q'" + (tipoTransporte != null && tipoTransporte.equals("q") ? "selected" : "") + ">CTQ - Transp. Aquavi&aacute;rio</option>" : ""%>
                        </select>
              </td>
                <td class="TextoCampos">Apenas a(s) UF(s) Destino:</td>
                <td class="CelulaZebra2">
                    <input name="ufsDestino" type="text" style="font-size:8pt;" id="ufsDestino" size="20" value="<%=ufsDestino%>" class="inputtexto" >
                    Exemplo: PE,PB,SP
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" >Pedido NF:</td>
                <td class="CelulaZebra2" >
                    <input name="pedidoNF" type="text" style="font-size:8pt;" id="pedidoNF" size="12" value="<%=pedidoNF%>" class="inputtexto" >
                </td>
                <td class="TextoCampos">Apenas os CT-e(s) das Notas:</td>
                <td class="CelulaZebra2">
                    <div align="left">
                        <input type="text" name="notasFiscais" id="notasFiscais" value="<%=notasFiscais%>" class="inputtexto" size="40" style="font-size:8pt;">
                        Exemplo: 1234,1235,1236
                    </div>    
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas o Remetente:</td>
                <td class="CelulaZebra2">
                    <div align="left">
                        <input name="rem_rzs" type="text" id="rem_rzs" value="<%=(request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "")%>" size="30" readonly="true" class="inputReadOnly8pt">
                        <input type="hidden" name="idremetente" id="idremetente" value="<%=idRemetente%>">                     
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');;">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';javascript:getObj('rem_rzs').value = '';">
                    </div>
                </td>              
              <td class="TextoCampos">Nº da(s) Carga(s):</td>
                <td class="CelulaZebra2">
                    <input name="numeroCarga" type="text" style="font-size:8pt;" id="numeroCarga" size="40" value="<%=numeroCarga%>" class="inputtexto" >
                    Exemplo: 60001,65431,78541
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas o Destinatário:</td>
                <td class="CelulaZebra2">
                    <div align="left">
                        <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=idDestinatario%>">
                        <input name="dest_rzs" type="text" id="dest_rzs" value="<%=(request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "")%>" size="30" readonly="true" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';javascript:getObj('dest_rzs').value = '';">
                    </div>
                </td>
             <!-- <td class="TextoCampos" >Apenas o veiculo:</td>
              <td class="CelulaZebra2" colspan="1">
                  <input name ="idveiculo" type="hidden" id="idveiculo"  value="< %=idVeiculo%>">
                  <input name ="vei_placa"  type="text" class="inputReadOnly8pt" id="vei_placa" size="30" value="< %=(request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "")%>" readonly="true">
                  <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
                  <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpa Veiculo" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';">
              </td>-->
             <td class="TextoCampos">Apenas a Série do CT-e:</td>                
                <td class="CelulaZebra2">
                    <input name="serieCte" type="text" style="font-size:8pt;" id="serieCte" size="12" value="<%=serieCte%>" class="inputtexto" >
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas o Consignatário:</td>
                <td class="CelulaZebra2">
                    <div align="left">
                        <input name="con_rzs" type="text" id="con_rzs" value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>" size="30" readonly="true" class="inputReadOnly8pt">
                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=idConsignatario%>">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Consignatario_');">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idconsignatario').value = '0';javascript:getObj('con_rzs').value = '';">
                    </div>
                </td> 
                <td class="TextoCampos" >
                    <div align="right">Apenas o motorista:</div>
                </td>
                <td class="CelulaZebra2" colspan="2">
                    <input name ="idmotorista" type="hidden" id="idmotorista"  value="<%=idMotorista%>">
                    <input name ="motor_nome"  type="text" class="inputReadOnly8pt" id="motor_nome" size="30" value="<%=(request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "")%>" readonly="true">
                    <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpa Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
                </td>               
            </tr>
            <tr>
                <td class="TextoCampos">Apenas o Redespacho:</td>
                <td class="CelulaZebra2">
                    <div align="left">
                        <input type="hidden" name="idredespacho" id="idredespacho" value="<%=idRedespacho%>">
                        <input name="red_rzs" type="text" id="red_rzs" size="30" class="inputReadOnly8pt"  value="<%=(request.getParameter("red_rzs") != null ? request.getParameter("red_rzs") : "")%>" readonly  onFocus="this.select();">
                        <input name="localiza_red" type="button" class="botoes" id="localiza_red" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Redespacho" onClick="javascript:getObj('idredespacho').value = '0';javascript:getObj('red_rzs').value = '';">
                    </div>
                </td>                
              <td class="TextoCampos" >Apenas o veiculo:</td>
              <td class="CelulaZebra2" colspan="1">
                  <input name ="idveiculo" type="hidden" id="idveiculo"  value="<%=idVeiculo%>">
                  <input name ="vei_placa"  type="text" class="inputReadOnly8pt" id="vei_placa" size="30" value="<%=(request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "")%>" readonly="true">
                  <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
                  <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpa Veiculo" onClick="javascript:getObj('idveiculo').value = 0;javascript:getObj('vei_placa').value = '';">
              </td>
            </tr>
            <tr>
                <td width="15%" class="TextoCampos">Apenas os setores de entregas:</td>
                <td class="CelulaZebra2">
                    <input name="setorEntrega" type="text" id="setorEntrega" class="inputReadOnly8pt" value="" size="20" maxlength="10" readonly>
                    <input name="localizarSetorEntrega" type="button" class="botoes" value="..." onClick="controlador.acao('abrirLocalizar','localizarSetorEntrega');">
                    <img src="img/borracha.gif" name="limparSetorEntrega" border="0" align="absbottom" class="imagemLink" id="limparSetorEntrega" title="Limpar Setor de Entrega" onClick="removerValorInput('setorEntrega')">
                </td>
                <td class="TextoCampos">Apenas os grupos de clientes:</td>
                <td class="CelulaZebra2">
                    <input name="grupoCliente" type="text" id="grupoCliente" class="inputReadOnly8pt" value="" size="20" maxlength="10" readonly>
                    <input name="localizarGrupoCliente" type="button" class="botoes" value="..." onClick="controlador.acao('abrirLocalizar','localizarGrupoCliente');">
                    <img src="img/borracha.gif" name="limparGrupoCliente" border="0" align="absbottom" class="imagemLink" id="limparGrupoCliente" title="Limpar Grupo de Clientes" onClick="removerValorInput('grupoCliente')">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    Romaneio:
                </td>
                <td class="CelulaZebra2" colspan="3">
                    <input type="text" class="inputtexto" name="romaneio" id="romaneio" size="8" maxlength="6" value="<%=romaneio%>">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas os Nº dos CT-e(s):</td>
                <td class="CelulaZebra2" colspan="3">
                    <input id="numeroCTes" class="inputtexto" type="text" size="40" value="<%=numeroCTes%>" name="numeroCTes"/>
                    Exemplo: 000232,120354,521369
                </td>
            </tr>
            <tr>
<!--                Procurar a coluna que o numero do pedido é salva no banco-->
                <td class="TextoCampos">Apenas os Nº dos Pedidos:</td>
                <td class="CelulaZebra2" colspan="3">
                    <input id="numeroPedidos" class="inputtexto" type="text" size="40" value="<%=numeroPedidos%>" name="numeroPedidos"/>
                    Exemplo: AG0342334-6,16343234-54, HGE521369
                </td>
            </tr>
            <tr>
            <td class="CelulaZebra2" colspan="4">
                <div align="center">
                   <input type="checkbox" id="chkOutraFilial" name="chkOutraFilial" <%=(request.getParameter("chkOutraFilial")!=null && Boolean.parseBoolean(request.getParameter("chkOutraFilial")) ? "checked" : "")%> >
                     Visualizar CT-e(s) emitidos por outra filial e destinado(s) a minha filial.
                </div>
            </td>
            </tr>
            <tr>
                <td colspan="4" class="CelulaZebra2">
                    <div align="center">
                        <input name="btPesquisar" type="button" class="botoes" id="btPesquisar" value="Pesquisar" onClick="pesquisar();">
                    </div>
                </td>
            </tr>
                
        </table>
        <br>
        </form>
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr> 
                <td width="2%" class="tabela"><input type="checkbox" id="chkTodos" name="chkTodos" onclick="checkTodosCtrcs()"></td>
                <td width="5%" class="tabela">CT-e</td>
                <td width="5%" class="tabela"><div align="center">Série</div></td>
                <td width="8%" class="tabela">Data</td>
                <td width="10%" class="tabela">Filial</td>
                <td width="22%" class="tabela">Remetente</td>
                <td width="22%" class="tabela">Destinatário</td>
                <td width="6%" class="tabela">QTD</td>
                <td width="6%" class="tabela">Peso</td>
                <td width="7%" class="tabela">Valor NF</td>
                <td width="7%" class="tabela">Vl Frete</td>
            </tr>
            <tr>
                <td colspan="11">
                    <table width="100%">
                        <tr>
                          <td width="15%" class="TextoCampos">Informe o CT:</td>
                          <td width="85%" class="CelulaZebra2" >
                                <input name="selCtrc" type="text" style="font-size:8pt;" id="selCtrc" size="7" value="" class="inputtexto" onKeyPress="checkCtrc(event)">
                                <font color="red">Após digitar o CT-e tecle "Enter" para selecioná-lo na lista abaixo.</font>
                          </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <% //variaveis da paginacao      

            // se conseguiu consultar
            selmanif.setDtSaida1(Apoio.paraDate(request.getParameter("dtinicial")));
            selmanif.setDtsaida2(Apoio.paraDate(request.getParameter("dtfinal")));
            selmanif.setTipo(request.getParameter("tipo"));
            selmanif.setCidadeDestinoId(idCidades);
            selmanif.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
            
            if (selmanif.SelectCtrc(request.getParameter("filial"), marcados, mostraTudo , idMotorista, pedidoNF, tipoTransporte, (request.getParameter("chkOutraFilial")!=null ? Boolean.parseBoolean(request.getParameter("chkOutraFilial")) : false),
                    ufsDestino,numeroCarga,idRemetente, idDestinatario, idConsignatario, idRedespacho, notasFiscais, condicaoctrc, serieCte, numeroCTes, numeroPedidos, tipoDestino, isFilialCidadesAtendidas, idfilial2, romaneio,
                    request.getParameter("setorEntrega"), request.getParameter("grupoCliente"))) {

                ResultSet rs = selmanif.getResultado();
                while (rs.next()) {
                    //pega o resto da divisao e testa se é par ou impar
%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <%boolean encontrou = false;
                                for (int i = 0; i <= marcados.split(",").length - 1; i++) {
                                    if (marcados.split(",")[i].equals(rs.getString("idmovimento"))) {%>
                <td><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("idmovimento")%>"checked></td>
                <%encontrou = true;
                                    }
                                }
                                if (!encontrou) {%>
                <td><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("idmovimento")%>"></td>
                <%}%>
                <td><%=rs.getString("nfiscal")%>
                    <input type="hidden" name="<%="hidden_ctrc_" + rs.getString("nfiscal")%>" id="<%="hidden_ctrc_" + rs.getString("nfiscal")%>" value="<%=linha%>">
                </td>
                <td><div align="center"><%=rs.getString("especie")+"/"+rs.getString("serie")%></div></td>
                <td><%=formato.format(rs.getDate("dtemissao"))%></td>
                <td><%=rs.getString("abreviatura")%></td>
                <td><%=rs.getString("remetente")%></td>
                <td><%=rs.getString("destinatario")%></td>
                <td><%=rs.getFloat("totnf_volume")%></td>
                <td><%=Apoio.to_curr(rs.getFloat("totnf_peso"),3)%></td>
                <td><%=Apoio.to_curr(rs.getFloat("totnf_valor"))%></td>
                <td><%=Apoio.to_curr(rs.getFloat("vlfrete"))%></td>
            </tr>
            <%linha++;
                }//while
            }
            %>
            <script language="javascript">
                quant = <%=linha++%>
            </script>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="11"><div align="center">
                    <!--    <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:tryRequestToServer(function(){seleciona();});">-->
                    <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:tryRequestToServer(function(){retornaPai();});">
                </div></td>
            </tr>
        </table>
        
        <div class="cobre-tudo"></div>
        <div class="localiza">
            <iframe id="localizarSetorEntrega" input="setorEntrega" name="localizarSetorEntrega" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarSetorEntrega" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarGrupoCliente" input="grupoCliente" name="localizarGrupoCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarGrupoCliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>

        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/script/funcoesTelaSelecionarCTRC.js?v=${random.nextInt()}"></script>
    </body>
</html>
