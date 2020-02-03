<%@page import="filial.BeanFilial"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@page import="conhecimento.coleta.BeanConsultaColeta"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.ArrayList"%>
<%@page import="nucleo.*"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.json.simple.* "%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="conhecimento.orcamento.Cubagem"%>

<% 
    int nivelUserFl = Apoio.getUsuario(request).getAcesso("lanconhfl");
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    BeanConsultaColeta con_col = new BeanConsultaColeta();
	con_col.setConexao(Apoio.getConnectionFromUser(request));
	String acao = (request.getParameter("acao") != null? request.getParameter("acao") : "");
	ResultSet rs = null;
	
	if (acao.equals("loadNotes")){
            
		rs = con_col.loadNotes(request);
	
		String notas_readonly = "var prefix_cub = '';"; 
		int idNota = 0;
		int countCub = 0;
		while (rs.next()) {
                    
                    if(rs.getInt("idnota_fiscal") != idNota){
                        countCub = 0;
                        idNota = rs.getInt("idnota_fiscal");
                        
                        notas_readonly += "addReadOnlyNote('0','tableNotes','"+
                                rs.getInt("idnota_fiscal")+"','"+rs.getString("numero")+
                                "','"+rs.getString("serie")+"',"+"'"+fmt.format(rs.getDate("emissao"))+"','"+
                                rs.getDouble("valor")+"','"+rs.getFloat("vl_base_icms")+"','"+
                                rs.getFloat("vl_icms")+"','"+rs.getFloat("vl_icms_st")+"','"+
                                rs.getFloat("vl_icms_frete")+"','"+rs.getFloat("peso")+"','"+
                                rs.getFloat("volume")+"', '"+rs.getString("embalagem")+
                                "','"+rs.getString("conteudo")+"','"+rs.getString("pedido")+"','"+
                                rs.getString("idmarca")+"','"+rs.getString("desc_marca")+"','"+
                                rs.getString("modelo_veiculo")+"','"+rs.getString("ano_veiculo")+"','"+
                                rs.getString("cor_veiculo")+"','"+rs.getString("chassi_veiculo") + "','"+
                                rs.getString("cfop_id") + "','"+rs.getString("cfop") + "','"+
                                rs.getString("chave_acesso") + "','"+(rs.getBoolean("is_agendado") ? "true" : "false") +"','"+
                                (rs.getDate("data_agenda") == null ? "" : fmt.format(rs.getDate("data_agenda"))) +
                                "','"+rs.getString("hora_agenda") +"','"+rs.getString("obs_agenda") + "','"+
                                (rs.getDate("previsao_entrega_em") == null ? "" : fmt.format(rs.getDate("previsao_entrega_em"))) +
                                "','"+rs.getString("previsao_entrega_as")+"','"+rs.getString("iddestinatario")+"','"+rs.getString("destinatario")+"','"+rs.getString("is_importada_edi")+
                                "','"+rs.getString("altura")+"','"+rs.getString("largura")+
                                "','"+rs.getString("comprimento")+"','"+rs.getString("metro_cubico")+"','"+rs.getString("tipo_documento")+"', undefined, undefined, undefined, undefined, '" + rs.getBoolean("con_is_trava_campos_import") + "');";
                    }
                    if(rs.getInt("cub_id") != 0){
                        notas_readonly += "var prefix_cub = getLastIndexFromTableRoot('0','tableNotes');"; 
                        notas_readonly += "addUpdateNotaFiscal3("
                                +"'trNote'+prefix_cub+'_id0'"+","
                                +"'"+rs.getInt("idnota_fiscal")+"'"+","
                                +"'"+rs.getInt("cub_id")+"'"+","
                                +"prefix_cub+'_id0'"+","
                                +"'"+rs.getDouble("cub_metro_cubico")+"'"+","
                                +"'"+rs.getDouble("cub_altura")+"'"+","
                                +"'"+rs.getDouble("cub_largura")+"'"+","
                                +"'"+rs.getDouble("cub_comprimento")+"'"+","
                                +"'"+rs.getDouble("cub_volumes")+"'"+","
                                +"'"+rs.getString("cub_etiqueta")+"'"+","
                                +"'"+countCub+"'"
                                + ");";
                        countCub++;
                    }
                    
		}
		rs.close();
		response.getWriter().append((notas_readonly.equals("")? "alert('Erro ao tentar obter as notas!');" : notas_readonly));
	    response.getWriter().close();
	}else if (acao.equals("loadColeta")) {
		rs = con_col.loadColeta(request);
			
                String retorno_javascript = "";
        
                JSONObject hs = new JSONObject();
		
                //atribuindo o id(sempre vai ser o 1º campo)
                for (int co = 1; co <= rs.getMetaData().getColumnCount(); co++){
                    if (rs.getString(co) != null ){
        		String campo = rs.getMetaData().getColumnName(co);
		        String valor = rs.getString(co).replace("\r","<BR>").replace('\n',' ');
        		hs.put(campo, valor);		        
                    }
                }    
     	

        retorno_javascript = hs.toString();//" if (window.opener.aoClicarNoLocaliza != null) window.opener.aoClicarNoLocaliza(window.name); window.close();";
	        
		rs.close();
		response.getWriter().append(retorno_javascript);
	    response.getWriter().close();
	} else if (acao.equals("obter_cubagens")) {
                //String resultado = "";
                BeanConsultaColeta con_col1 = new BeanConsultaColeta();
                
                con_col1.setConexao(Apoio.getConnectionFromUser(request));
                Collection lista = con_col1.consultarCubagensNota(request);
                if (lista != null) {
                    XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
                    xstream.setMode(XStream.NO_REFERENCES);
                    xstream.alias("cubagem", Cubagem.class);
                    String json = xstream.toXML(lista);
                    response.getWriter().append(json);
                } else {
                    response.getWriter().append("load=0");
                }
                response.getWriter().close();
        }else{
		rs = con_col.localizaColeta(request);
	}
%>


<html>
<head>
<script type="text/javascript" src="script/funcoes.js"></script>
<script type="text/javascript" src="script/notaFiscal-util.js"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script type="text/javascript">
jQuery.noConflict();
function loadNotes(qtdLin){

       var idsColetas = "";
       for (var g=0; g <= qtdLin; g++){
           if ($('chk_col_'+g) != null){
                if ($('chk_col_'+g).checked){
                    idsColetas += (idsColetas == '' ? '' : ',') + $('chk_col_'+g).value;
                }
           }
       }

       function ev(resp, st){	
            cleanNotes(document);     
	        //numero_coleta = "<b>"+numero_coleta+"</b>";
	        $('div_coleta').innerHTML = (st == 200 ? "Notas fiscais das coletas selecionadas acima." : "ERRO ao obter as notas fiscais das coletas selecionadas acima. Status: "+st);
                
            eval(resp);
            $('bt_Ok').onclick = new Function("addNotesToCTRC();feedFieldsCTRC('"+idsColetas+"');");
       }

       if (idsColetas == ''){
           alert('Escolha no mínimo uma coleta.');
       }else{
           requisitaAjax("./localiza_coleta.jsp?acao=loadNotes&idcoleta="+idsColetas,ev);
       }
	 
}

function cleanNotes(docum){
    var i = 1;
	while (docum.getElementById('trNote'+i+'_id0') != null){
	    docum.getElementById('trNote'+i+'_id0').parentNode.removeChild(docum.getElementById('trNote'+i+'_id0'));
	    i++;
	}    
}  

function nextPage(){
	$('pag').value = (parseFloat($('pag').value) + 1);
	$('form1').submit();
}

/*TODO: 1)fazer a limpeza de notas npo pai
      2)listar somente as coletas que nao tem alguma nota adicionada 
*/
function addNotesToCTRC(){
   cleanNotes(window.opener.document);
   var pai = window.opener.document;
   var i = 1;
   while ($('nf_numero'+i+'_id0') != null){
   
        var suf = i+'_id0';

        var idNota = $('nf_idnota_fiscal'+suf).value;
        var countCub = 0;
        if ($('ck'+suf).checked){
             window.opener.countIdxNotes++;
             var prefix = window.opener.addNote('0',
                                    'tableNotes0',
                                    $('nf_idnota_fiscal'+suf).value,
                                    $('nf_numero'+suf).innerHTML,
                                    $('nf_serie'+suf).innerHTML,
                                    $('nf_emissao'+suf).innerHTML,
                                    $('nf_valor'+suf).innerHTML,
                                    $('nf_base_icms'+suf).innerHTML,
                                    $('nf_icms'+suf).innerHTML,
                                    $('nf_icms_st'+suf).innerHTML,
                                    $('nf_icms_frete'+suf).innerHTML,
                                    $('nf_peso'+suf).innerHTML,
                                    $('nf_volume'+suf).innerHTML,
                                    $('nf_embalagem'+suf).innerHTML,
                                    $('nf_conteudo'+suf).innerHTML,
                                    '0',
                                    $('nf_pedido'+suf).innerHTML,
                                    false,
                                    $('nf_largura'+suf).value,
                                    $('nf_altura'+suf).value,
                                    $('nf_comprimento'+suf).value,
                                    $('nf_metroCubico'+suf).value,
                                    $('nf_id_marca_veiculo'+suf).value,
                                    $('nf_marca_veiculo'+suf).value,
                                    $('nf_modelo_veiculo'+suf).value,
                                    $('nf_ano_veiculo'+suf).value,
                                    $('nf_cor_veiculo'+suf).value,
                                    $('nf_chassi_veiculo'+suf).value,
                                    '0',
                                    'false',
                                    $('nf_cfopId'+suf).value,
                                    $('nf_cfop'+suf).value,
                                    $('nf_chave_nf'+suf).value,
                                    $('nf_is_agendado'+suf).value,
                                    $('nf_data_agenda'+suf).value,
                                    $('nf_hora_agenda'+suf).value,
                                    $('nf_obs_agenda'+suf).value,
                                    '<%=cfg.isBaixaEntregaNota()%>',
                                    $('nf_previsao_entrega'+suf).value,
                                    $('nf_previsao_as'+suf).value,
                                    $('nf_id_destinatario'+suf).value,
                                    $('nf_destinatario'+suf).value,
                                    $('nf_is_edi'+suf).value,
                                    "0",
                                    "0",
                                    $('nf_tipoDocumento'+suf).value,
                                    undefined, undefined, undefined, undefined,
                                    $('nf_travarCampos'+suf).value
                                );
                                    
                                
            //for (int c = 0; c < n.getCubagens().length; ++c) {
                
                  
                  while($('nf_metroIdNota_'+prefix+countCub) != null){
                      window.opener.addUpdateNotaFiscal3('trNote'+prefix,
                        $('nf_idnota_fiscal'+prefix).value,
                        $('nf_metroId_'+prefix+countCub).value,
                        prefix,
                        $('nf_metroCubico_'+prefix+countCub).value,
                        $('nf_itemAltura_'+prefix+countCub).value,
                        $('nf_metroLargura_'+prefix+countCub).value,
                        $('nf_metroComprimento_'+prefix+countCub).value,
                        $('nf_metroVolume_'+prefix+countCub).value,
                        $('nf_metroEtiqueta_' + prefix + countCub).value,
                        countCub);
                      countCub++;
                  }
          //}  
          if(countCub != 0){
            if (pai.getElementById("maxItensMetro"+suf) != null){
                pai.getElementById("maxItensMetro"+suf).value = countCub + "";
            }
            countCub = 0;
          }          
          
          //localizaCubagens($('nf_idnota_fiscal'+suf).value,prefix);   
         }
      ++i;    
      
   }
   if (window.opener.updateSum != null){
		window.opener.updateSum();
   }
   if (window.opener.totaisNotas != null){
		window.opener.totaisNotas();
   }

    if (($('nf_travarCampos' + 1 + '_id0') !== undefined && $('nf_travarCampos' + 1 + '_id0') !== null) && $('nf_travarCampos' + 1 + '_id0').value === 'true') {
        window.opener.$('is_travar_campos').value = 'true';
        window.opener.colocarReadOnly($('nf_is_edi' + 1 + '_id0').value === 't' ? 'true' : 'false');
    }
      //não é possivel ser feito uma coleta sem remetente e o destinatario como não fecha esta tela o batao fica desabilitado - historia 2155
//    $("bt_Ok").disabled = true;
}

function localizaCubagens(idNotaFiscal,prefix){
    function e(transport){
        var textoresposta = transport.responseText;
        
        
        if (textoresposta == "load=0") {
            return alert("Erro ao carregar as notas do conhecimento ");
        }else{
            var lista = jQuery.parseJSON(textoresposta);
            
            var cubagens = lista.list[0].cubagem;
            
            if (cubagens != undefined){
        
                var cubagem;
                var length = (cubagens.length == undefined ? 0 : cubagens.length);
        
                $('maxItensMetro'+prefix).value = length+"";
                for(var j = 0; j < length; j++){
                    
                    if(length > 1){
                        cubagem = cubagens[j];
                    }else{
                        cubagem = cubagens;                    
                    }

                    window.opener.addUpdateNotaFiscal3('trNote'+prefix,
                                            idNotaFiscal,
                                            cubagem.id,
                                            prefix,
                                            formatoMoeda(cubagem.metroCubico),
                                            formatoMoeda(cubagem.altura),
                                            formatoMoeda(cubagem.largura),
                                            formatoMoeda(cubagem.comprimento),
                                            formatoMoeda(cubagem.volume),
                                            cubagem.etiqueta,
                                            j
                                        );
                }
            }
        }
    }
    new Ajax.Request("./localiza_coleta.jsp?acao=obter_cubagens&idNotaFiscal="+idNotaFiscal,{method:'post', onSuccess: e, onError: e});
}


/**Alimenta os campos do ctrc com os da coleta.*/
function feedFieldsCTRC(idcoleta){
     function ev(resp, st)
     {	
         if (st == 200){         	 
         	 eval('var hs ='+resp);
	         proc_result_set(hs, window.opener);
             var idColeta = idcoleta;

             if (idColeta.indexOf(',') > -1) {
                 idColeta = idColeta.split(',')[0];
             }

             if (window.opener.$('repr_coleta_id') !== undefined && window.opener.$('repr_coleta_id') !== null) {
                 window.opener.$('repr_coleta_id').value = $('id_representante' + idColeta).value;
                 window.opener.$('repr_coleta').value = $('nome_representante' + idColeta).value;
             }

	         if (window.opener.aoClicarNoLocaliza != null) { 
	         	window.opener.aoClicarNoLocaliza(window.name);
                        //Criei a linha abaixo porque o usuário estava querendo alterar a filial depois de escolher a coleta e com 
                        //isso o sistema não estava refazendo os calculcos do ICMS e da Pauta Fiscal;
                        if (window.opener.document.getElementById("localiza_filial") != null) {
                            window.opener.document.getElementById("localiza_filial").style.display = "none";
                        }
	         	window.close();
	         }	
	 }else{
	      //  window.open("").document.write(resp).document.close();
	        alert("Status "+st+"\n Erro enquanto tentava carregar a coleta selecionada!"+resp);
            }
     }
     if (!validaRemetente($("maxColeta").value)) {
         return false;
    }
     requisitaAjax("./localiza_coleta.jsp?acao=loadColeta&idfilial="+$("filialId").value+"&idcoleta="+idcoleta,ev);
}

function marcarTodos(){
    var iG = 1;
    while ($('ck'+iG+'_id0') != null){
	    $('ck'+iG+'_id0').checked = $('chkTodos').checked;
	    iG++;
    }
}

function validaRemetente(index){
    for (var qtdeColetas = 1; qtdeColetas <= index; qtdeColetas++) {
        if ($("chk_col_"+qtdeColetas).checked) {
            if ($("idremetente"+ qtdeColetas).value == 0) {
                alert("É preciso selecionar um cliente remetente ou cidade de origem, consignatário e um cliente destinatário para esta ação.");
                return false;
            }else{
                return true;
            }
        }
    }
}

function submitForm(){
    $("form1").action = "./localiza_coleta.jsp?idfilial="+getObj('filialId').value;
    $("form1").submit();
}

</script> 

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Localiza coleta</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
</head>

<body>
<br>
<table width="40%" align="center" class="bordaFina" >
  <tr>
    <td width="888"><div align="left"><b>Localiza Coleta </b></div></td>
    <td width="65"><input type="button" class="botoes" value="Cancelar" onClick="javascript:window.close();"></td>
  </tr>
</table>
<br>

<center>
    <!--Foi retirado esse form devido ao erro de duplo click no botão pesquisar, criei uma função onMouseDown
    que Executa um código JavaScript quando o usuário pressiona um botão do mouse-->
  <!--<form action="./localiza_coleta.jsp" method="post" id="form1" onSubmit="javascript: $('form1').action += '?idfilial='+getObj('filialId').value;">-->
  <form action="" method="post" id="form1">
  
  <input type="hidden" value="<%=Apoio.coalesce(request.getParameter("pag"),"0")%>" id="pag" name="pag">
  <table width="40%" border="0"  class="bordaFina">
    <tr>
      <td width="25%" class="TextoCampos">Filial:</td>
      <td width="75%" class="CelulaZebra2">
        <select name="filialId" id="filialId" class="fieldMin">
          <%BeanFilial fl = new BeanFilial();
            ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
            while (rsFl.next()) {%>
              <%if (nivelUserFl >= 3) {%>
                <option value="<%=rsFl.getString("idfilial")%>"
                  <%=(Integer.parseInt(request.getParameter("idfilial")) == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%>
                </option>
              <%} else if (Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                <option value="<%=rsFl.getString("idfilial")%>"
                  <%=(Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial") ? "selected" : "")%>><%=rsFl.getString("abreviatura")%>
                </option>
              <%}%>
            <%}
          rsFl.close();%>
        </select>
      </td>
    </tr>
    <tr>
      <td class="TextoCampos">N&uacute;mero:</td>
      <td class="CelulaZebra2">
         <input name="numcoleta" type="text" id="numcoleta" size="30" onkeypress="javascript:if (event.keyCode==13) submitForm()" class="inputtexto" value="<%=Apoio.coalesce(request.getParameter("numcoleta"), "") %>">
      </td>
    </tr>
    <tr>
      <td class="TextoCampos">Nº Booking:</td>
      <td class="CelulaZebra2"><input type="text" class="inputtexto" size="30" id="booking" name="booking" value="<%=Apoio.coalesce(request.getParameter("booking"), "") %>"></td>
    </tr>
    <tr>
      <td class="TextoCampos">Motorista: </td>
      <td class="CelulaZebra2"><input  type="text" class="inputtexto" size="30" id="motorista" name="motorista" value="<%=Apoio.coalesce(request.getParameter("motorista"), "") %>"></td>
    </tr>
    <tr>
      <td class="TextoCampos">Veículo:</td>
      <td class="CelulaZebra2"><input  type="text" class="inputtexto" id="cavalo" name="cavalo" value="<%=Apoio.coalesce(request.getParameter("cavalo"), "") %>"></td>
    </tr>
    <tr>
      <td colspan="2" class="TextoCampos"><div align="center">
        <label>
        <input name="semNF" type="checkbox" id="semNF" <%=(request.getParameter("semNF") != null ? "checked" : "")%>>
        </label>
      Mostrar coletas sem nota(s) fiscal(is)</div></td>
      </tr>
    <tr>
      <td colspan="2" class="TextoCampos"><div align="center">
        <input name="pesquisar"  type="submit" class="botoes" id="pesquisar" 
	           value="Pesquisar" title="Faz a pesquisa com os dados informados" onClick="javascript:$('pag').value = '0'; $('pesquisar').disabled = 'true'" onMouseDown="javascript:submitForm();"></div></td>
      </tr>
  </table>
  <br>
  <table width="760"  class="bordaFina">
    <tr class="tabela">
      <td></td>
      <td>N&uacute;mero</td>
      <td>Data</td>
      <td>Cid. coleta </td>
      <td>Cid. entrega </td>
      <td>Cliente</td>
      <td>Motorista</td>      
      <td>Cavalo</td>
      <td>Carreta</td>            
    </tr>
    
<% int qtLinhas = 0;
   while (!acao.equals("loadNotes") && !acao.equals("loadColeta") && rs.next())
   {
	   qtLinhas++; 
%>  <tr class="celulazebra1">
    <td><input type="checkbox" id="chk_col_<%=qtLinhas%>" value="<%=rs.getString("idcoleta")%>"></td>
    <!--<td><input type="checkbox" id="chk_col_< %=qtLinhas%>" value="< %=rs.getString("idcoleta")%>" onclick="javascript:validaRemetente(< %=qtLinhas%>);"></td>-->
      <td class="linkEditar" onClick="alert('Para visualizar a(s) NF(s) marque ao lado e clique no botão abaixo.')"><%=rs.getString("numcoleta") %></td>
      <td><%=fmt.format(rs.getDate("dtcoleta"))%></td>
      <td><%=rs.getString("coleta")%></td>
      <td><%=(rs.getString("entrega") == null? "" : rs.getString("entrega"))%></td>
      <td><%=rs.getString("rem_rzs")%></td>
      <td><%=rs.getString("motorista")%></td>
      <td><%=rs.getString("cavalo")%></td>
      <td><%=rs.getString("carreta")%></td>
      <td style="display: none;">
          <input type="hidden" value="<%=rs.getString("idremetente")%>" name="idremetente<%=qtLinhas%>" id="idremetente<%=qtLinhas%>">
          <input type="hidden" id="id_representante<%=rs.getString("idcoleta")%>" name="id_representante<%=rs.getString("idcoleta")%>" value="<%= rs.getInt("id_representante") %>">
          <input type="hidden" id="nome_representante<%=rs.getString("idcoleta")%>" name="nome_representante<%=rs.getString("idcoleta")%>" value="<%= rs.getString("nome_representante") %>">
      </td>
    </tr>
<% }//while
   rs.close();
%>  
    <tr>
        <td colspan="9" class="TextoCampos">
            <div align="center">
            <input name="btnColeta" type="button" class="botoes" id="btnColeta"
	           value="Mostrar NF(s) das coletas selecionadas" title="Mostra as notas fiscais das coletas selecionadas." onClick="javascript:loadNotes(<%=qtLinhas%>)">
            <input type="hidden" value="<%=qtLinhas%>" name="maxColeta" id="maxColeta">
            </div>
        </td>
    </tr>
   </table>
<!--
    Comentando código abaixo, por conta da tarefa ID 2334 Name 0003172: PROBLEMA BRASITRANS 15.11: 
    O cliente não conseguia selecionar todos as coletas de uma vez.
    Foi definido junto com Deivid que seria tirado o limit e o offset do BeanConsultaColeta
   < %if(!(qtLinhas < 10)){ %><a style="margin-left: 681px" href="javascript:nextPage()" >mais...</a> < % }%>-->
    <br>
  <br><div id="div_coleta"></div>
  </form>
      <table  id="tableNotes"  border="0" align="center" cellpadding="2" cellspacing="1">
          <tr class="tabela">
            <td><label>
                    <input type="checkbox" name="chkTodos" id="chkTodos" onClick="marcarTodos();">
            </label></td>
            <td>N&uacute;mero</td>
            <td>S&eacute;rie</td>
            <td>Emiss&atilde;o</td>
            <td>Valor</td>
            <td>Base Icms</td>
            <td>Vl. Icms</td>
            <td>Icms Subst.Trib.</td>
            <td>Icms Frete</td>
            <td>Peso</td>
            <td>Volume</td>
            <td>Embalagem</td>
            <td>Conte&uacute;do</td>
            <td>Pedido</td>
          </tr>
        </table>
  <br>
  <br>
  <input type="button" value="OK" class="botoes" id="bt_Ok" name="bt_Ok">
</center>
</body>
</html>