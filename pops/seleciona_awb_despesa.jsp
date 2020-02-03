<%@page import="conhecimento.awb.BeanConsultaAWB"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         conhecimento.manifesto.BeanConsultaManifesto,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio"%>
         
<script language="JavaScript" src="../script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="../script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="../script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="../script/shortcut.js"></script>
<script language="JavaScript" type="text/javascript" src="../script/beans/AWB.js"></script>

<%
            int linha = 0;
            int qtdAWB = request.getParameter("qtdAWB")==null? 0:Integer.parseInt(request.getParameter("qtdAWB"));
            String idsChecados = request.getParameter("idsAwb")==null?"0":request.getParameter("idsAwb");
//ATENCAO! A MSA está abaixo
// DECLARANDO e inicializando as variaveis usadas no JSP
            BeanConsultaAWB selawb = null;
            String acao = request.getParameter("acao");
            String idCidades = "";
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");

            
// -- INICIO DO MSA
            if (Apoio.getUsuario(request) == null) {
                response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
            }
            acao = ((acao == null) ? "" : acao);
// -- FIM DO MSA

//Instanciando o bean pra trazer os CTRC's
            selawb = new BeanConsultaAWB();
            selawb.setConexao(Apoio.getUsuario(request).getConexao());

            String marcados = (request.getParameter("marcados") == null ? "0" : request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados"));
            boolean mostraTudo = Boolean.parseBoolean(request.getParameter("mostratudo"));

            for (int i = 1; i<= qtdAWB ;i++){
                if(request.getParameter("chk-"+i)!=null){
                    idsChecados += (idsChecados==""?"":",")+ request.getParameter("chk-"+i);
                }
            }
%>

<Script language="javascript" type="text/javascript">

    shortcut.add("alt+s",function(){seleciona();});
    shortcut.add("alt+p",function(){pesquisa();});



    function seleciona(){
        var retorno = "";
        var awb = null;
        var pai = window.opener.document;
        //window.opener.removerAllAWB();
        for (var i = 1; i <= quant; ++i){
            if($("chk-"+i).value != null){
                if ($("chk-"+i).checked){
                    awb = new AWB();
                    awb.id = $("chk-"+i).value;
                    awb.movimento = $("numero_"+i).value;
                    awb.numeroAWB  = $("numeroAWB_"+i).value;
                    awb.numeroVoo= $("numeroVoo_"+i).value;
                    awb.dataEmissao = $("dataEmissao_"+i).value;
                    awb.valor = $("valorFrete_"+i).value;
                    awb.cidadeOrigem = $("cidadeOrigem_"+i).value;
                    awb.cidadeDestino = $("cidadeDestino_"+i).value;

                    //adicionando o awb no cadastro de awb
                    if(window.opener.addAWB(awb) != null){
                        window.opener.addAWB(awb);
                    }
                        
                    if (retorno == ""){
                        retorno += $("chk-"+i).value;
                    }else  {
                        retorno += ","+$("chk-"+i).value;
                    }
                }
            }
        }

        if (retorno == ""){
            return alert("Informe no mínimo um AWB.");
        }
        window.opener.adicionarTotalAWB();
        fechar();
    }

    var quant = ""; //Quantidade de resultados
    var indexCid = 0;
    function fechar(){
        window.close();
    }

    function localizacid_origem(){
        post_cad = window.open('../localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','origem_'+countCid,
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
    
     function localizacid_destino(){
        post_cad = window.open('../localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_DESTINO%>','destino_'+countCidDest,
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela){
        //localizando cidade
        if(idjanela == 'origem'){
            addCid($('idcidadeorigem').value, $('cid_origem').value, $('uf_origem').value);
        }else if(idjanela.split('_')[0] == 'origem'){
            $('idCid_'+idjanela.split('_')[1]).value = $('idcidadeorigem').value;
            $('cidade_'+idjanela.split('_')[1]).value = $('cid_origem').value;
            $('uf_'+idjanela.split('_')[1]).value = $('uf_origem').value;
        }
        else if(idjanela.split('_')[0] == 'destino'){
            $('idCidDest_'+idjanela.split('_')[1]).value = $('idcidadedestino').value;
            $('cidadeDest_'+idjanela.split('_')[1]).value = $('cid_destino').value;
            $('ufDest_'+idjanela.split('_')[1]).value = $('uf_destino').value;
        }
        
    }

    function carregar(){
        addCidade();
        addCidadeDestino();
        $("dtinicial").focus();
    }

    function insertLocalizar(){
        addCidade();
        localizacid_origem();
    }
    
     function insertLocalizarDestino(){
        addCidadeDestino();
        localizacid_destino();
    }

    function pesquisa(){
        $("formulario").submit();
    }

    function checkAWB(evento){
        if( evento.keyCode==13 ) {
            if($("hidden_awb_"+$("selAWB").value) != null){
                    $("chk-"+$("hidden_awb_"+$("selAWB").value).value).checked = true;
                    $("selAWB").value = "";
                        //break;
                }else{
                    alert("AWB não encontrado!");
                }

        }
    }

//--------------- cidade ----------------- inicio
    var countCid =0;
    var countCidDest =0;
	
    function Cidade(id, cidade, uf){
	this.id=(id==null || id==undefined?"":id);
	this.cidade=(cidade==null || cidade==undefined?"":cidade);
	this.uf=(uf==null || uf==undefined?"":uf);
    }
    
    function CidadeDestino(id, cidade, uf){
	this.id=(id==null || id==undefined?"":id);
	this.cidade=(cidade==null || cidade==undefined?"":cidade);
	this.uf=(uf==null || uf==undefined?"":uf);
    }
    
    function addCidade(cidade){
	++countCid;
        if(cidade==null ||cidade==undefined){
	    cidade= new Cidade();
	}

	//criando tr
        var tr_ = Builder.node("tr");
   	//criando td
        var td1_ = Builder.node("td");
	var inp0_= Builder.node("input",{type: "hidden", id:"idCid_"+countCid, name: "idCid_"+countCid, value: cidade.id});
	var inp1_= Builder.node("input",{type: "text", id:"cidade_"+countCid, name: "cidade_"+countCid, className:"inputReadOnly", readOnly:true, size: "25", value: cidade.cidade});
        var inp2_= Builder.node("input",{type: "text", id:"uf_"+countCid, name: "uf_"+countCid, className:"inputReadOnly", readOnly:true, size: "3", value: cidade.uf});
	var inp3_= Builder.node("input",{type: "button", id:"localiza_origem_"+countCid, name: "localiza_origem"+countCid, className:"botoes", value: "...", onClick:'javascript:launchPopupLocate(\'../localiza?acao=consultar&idlista=11\',\'origem_'+countCid+'\');'});

        td1_.appendChild(inp0_);
        td1_.appendChild(inp1_);
        td1_.appendChild(inp2_);
        td1_.appendChild(inp3_);

	tr_.appendChild(td1_);

	$("cid").appendChild(tr_);
    }
    
     function addCidadeDestino(cidade){
            ++countCidDest;
            if(cidade==null ||cidade==undefined){
                cidade= new CidadeDestino();
            }

	//criando tr
        var tr_ = Builder.node("tr");
   	//criando td
        var td1_ = Builder.node("td");
	var inp0_= Builder.node("input",{type: "hidden", id:"idCidDest_"+countCidDest, name: "idCidDest_"+countCidDest, value: cidade.id});
	var inp1_= Builder.node("input",{type: "text", id:"cidadeDest_"+countCidDest, name: "cidadeDest_"+countCidDest, className:"inputReadOnly", readOnly:true, size: "25", value: cidade.cidade});
        var inp2_= Builder.node("input",{type: "text", id:"ufDest_"+countCidDest, name: "ufDest_"+countCidDest, className:"inputReadOnly", readOnly:true, size: "3", value: cidade.uf});
	var inp3_= Builder.node("input",{type: "button", id:"localiza_destino_"+countCidDest, name: "localiza_destino"+countCidDest, className:"botoes", value: "...", onClick:'javascript:launchPopupLocate(\'../localiza?acao=consultar&idlista=12\',\'destino_'+countCidDest+'\');'});

        td1_.appendChild(inp0_);
        td1_.appendChild(inp1_);
        td1_.appendChild(inp2_);
        td1_.appendChild(inp3_);

	tr_.appendChild(td1_);

	$("cidDestino").appendChild(tr_);
    }

//--------------- cidade ----------------- fim
</Script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        
        <title>WebTrans - Selecionar AWB para Despesa</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <link href="../estilo.css" rel="stylesheet" type="text/css">
    </head>
    
    <body onLoad="carregar();">
        <form id="formulario" name="formulario" method="post" action="seleciona_awb_despesa.jsp" >
        <input type="hidden" name="tipo" id="tipo" value="a" >
        <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
        <input type="hidden" name="filial" id="filial" value="<%=request.getParameter("filial")%>">
        <input type="hidden" name="idfornecedor" id="idfornecedor" value="<%=request.getParameter("idfornecedor")%>">
        <input name="cid_origem" type="hidden" class="fieldMin" id="cid_origem" style="background-color:#FFFFF1" value="" size="25" readonly="true">
        <input name="uf_origem" type="hidden" class="fieldMin" id="uf_origem" style="background-color:#FFFFF1" value="" size="2" readonly="true">
        <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
        <input name="cid_destino" type="hidden" class="fieldMin" id="cid_destino" style="background-color:#FFFFF1" value="" size="25" readonly="true">
        <input name="uf_destino" type="hidden" class="fieldMin" id="uf_destino" style="background-color:#FFFFF1" value="" size="2" readonly="true">
        <input type="hidden" name="idsAwb" id="idsAwb" value="<%=(request.getParameter("idsAwb") != null ? request.getParameter("idsAwb") : "0")%>">

        
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr >
                <td width="619"><div align="left"><b>Selecionar AWB para Despesa</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick=""></td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr> 
                <td width="189" class="TextoCampos">Informe o intervalo de datas:        </td>
          <td width="185" class="CelulaZebra2"><input name="dtinicial" class="fieldDate" type="text" id="dtinicial" style="font-size:8pt;" size="10" maxlength="10" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>"
                                                                onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                    e 
                    <input name="dtfinal" type="text" id="dtfinal" style="font-size:8pt;" size="10" maxlength="10" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>"
                           onBlur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" ></td>
              <td width="174" class="TextoCampos">Apenas a cidade de origem:<span class="CelulaZebra2">
                      <img src="../img/add.gif" border="0" class="imagemLink "  title="Adicionar uma nova origem" onClick="javascript:insertLocalizar();"></span>

          <td width="244" class="CelulaZebra2">
<table width="100%" border="0">
                        <tbody id="cid">
                            
                        </tbody>
                    </table>
               <td width="174" class="TextoCampos">Apenas a cidade de destino:<span class="CelulaZebra2">
                      <img src="../img/add.gif" border="0" class="imagemLink "  title="Adicionar uma novo destino" onClick="javascript:insertLocalizarDestino();"></span>

          <td width="244" class="CelulaZebra2">
    <table width="100%" border="0">
                        <tbody id="cidDestino">
                            
                        </tbody>
                    </table>
                    
                    
                </td>
                <td width="111" class="CelulaZebra2"><div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="pesquisa();">
                </div></td>
          </tr>
        </table>
        <br>
        
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr> 
                <td width="2%" class="tabela"></td>
                <td width="10%" class="tabela" align="center">Manifesto</td>
                <td width="10%" class="tabela" align="center">Número AWB</td>
                <td width="8%" class="tabela" align="center">Nº Voo</td>
                <td width="10%" class="tabela" align="center">Data</td>
                <td width="18%" class="tabela">Companhia Aérea</td>
                <td width="17%" class="tabela">Cidade Origem</td>
                <td width="17%" class="tabela">Cidade Destino</td>
                <td width="8%" class="tabela" align="right">Vl Frete</td>
            </tr>
            <tr>
                <td class="TextoCampos" colspan="4">Informe o Número do AWB que deseja selecionar:</td>
                <td class="CelulaZebra2" colspan="5">
                      <input name="selAWB" type="text" style="font-size:8pt;" id="selAWB" size="7" value="" class="inputtexto" onKeyPress="checkAWB(event)">
                      <font color="red">(após informar o Número do AWB tecle "Enter")</font>
                </td>
            </tr>
            <% //variaveis da paginacao      

            // se conseguiu consultar
            int x=1;
            String cidades = "";
            while(Apoio.parseInt(request.getParameter("idCid_"+x))!=0){
                cidades +=","+(request.getParameter("idCid_"+x));
                x++;
            }
            
            cidades = cidades.replaceFirst(",", "");
            
            int d=1;
            String cidadeDest = "";
            while(Apoio.parseInt(request.getParameter("idCidDest_"+d))!=0){
                cidadeDest +=","+(request.getParameter("idCidDest_"+d));
                d++;
            }
            
            cidadeDest = cidadeDest.replaceFirst(",", "");
            
            selawb.setDtInicial(Apoio.paraDate(request.getParameter("dtinicial")));
            selawb.setDtFinal(Apoio.paraDate(request.getParameter("dtfinal")));
            selawb.getCompAerea().setIdfornecedor(Integer.parseInt(request.getParameter("idfornecedor")));
            selawb.setIdsAWB(idsChecados);
            selawb.setCidadeOrigemId(cidades);
            selawb.setCidadeDestinoId(cidadeDest);
//            selawb.setCidadeDestinoId(idCidades);
            if (selawb.consultarPorFornecedor()) {
                ResultSet rs = selawb.getResultado();
                while (rs.next()) {
                    //pega o resto da divisao e testa se é par ou impar
%>
            <tr class="<%=((linha++ % 2) == 0 ? "CelulaZebra1NoAlign" : "CelulaZebra2NoAlign")%>" >
                <%boolean encontrou = false;
                                for (int i = 0; i <= marcados.split(",").length - 1; i++) {
                                    if (marcados.split(",")[i].equals(rs.getString("id"))) {%>
                <td><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("id")%>"checked></td>
                <%encontrou = true;
                                    }
                                }
                                if (!encontrou) {%>
                <td><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" <%=(idsChecados.indexOf(rs.getString("id"))>=0?"checked":"")%> value="<%=rs.getString("id")%>"></td>
                <%}
                                
                %>
                <td align="center">
                    <input type="hidden" name="numero_<%=linha%>" id="numero_<%=linha%>"  value="<%=rs.getString("numero_manifesto")%>">
                    
                    <%=rs.getString("numero_manifesto")%>
                </td>
                
                <td>
                   <input type="hidden" name="numeroAWB_<%=linha%>" id="numeroAWB_<%=linha%>"  value="<%=rs.getString("numero_awb")%>">
                   <input type="hidden" name="<%="hidden_awb_" + rs.getString("numero_awb")%>" id="<%="hidden_awb_" + rs.getString("numero_awb")%>" value="<%=linha%>">
                    <%=rs.getString("numero_awb")%>
                </td>
                <td align="center">
                   <input type="hidden" name="numeroVoo_<%=linha%>" id="numeroVoo_<%=linha%>"  value="<%=rs.getString("numero_voo")%>">
                   <%=rs.getString("numero_voo")%>
                </td>
                <td align="center">
                   <input type="hidden" name="dataEmissao_<%=linha%>" id="dataEmissao_<%=linha%>"  value="<%=formato.format(rs.getDate("emissao_em"))%>">
                    <%=formato.format(rs.getDate("emissao_em"))%>
                </td>
                <td>
                
                   <input type="hidden" name="remetente_<%=linha%>" id="remetente_<%=linha%>"  value="<%=rs.getString("companhia_aerea")%>">
                    <%=rs.getString("companhia_aerea")%>
                </td>
                <td>
                   <input type="hidden" name="cidadeOrigem_<%=linha%>" id="cidadeOrigem_<%=linha%>"  value="<%=rs.getString("cidade_origem")%>">
                    <%=rs.getString("cidade_origem")%>
                </td>
                <td>
                   <input type="hidden" name="cidadeDestino_<%=linha%>" id="cidadeDestino_<%=linha%>"  value="<%=rs.getString("cidade_destino")%>">
                    <%=rs.getString("cidade_destino")%>
                </td>
                <td align="right">
                   <input type="hidden" name="valorFrete_<%=linha%>" id="valorFrete_<%=linha%>"  value="<%=rs.getString("valor_frete")%>">
                    <%=rs.getString("valor_frete")%>
                </td>
                
            </tr>
            <%
                }//while
            }
            %>
            <script language="javascript">
                quant = <%=linha%>
            </script>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="11"><div align="center">
                        <input type="hidden" name="qtdAWB" id="qtdAWB"  value="<%=linha%>">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="seleciona();">
                </div></td>
            </tr>
        </table>
        </form>
    </body>
</html>
