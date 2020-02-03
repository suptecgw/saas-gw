<%-- 
    Document   : seleciona_CtrcProtocolo
    Created on : 27/08/2012, 11:07:49
    Author     : renan
--%>

<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         protocolo.manifesto.BeanConsultaManifesto,
         conhecimento.manifesto.BeanConsultaManifesto,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio"%>
         
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<%
            int linha = 0;
//ATENCAO! A MSA está abaixo
// DECLARANDO e inicializando as variaveis usadas no JSP
            BeanConsultaManifesto selmanif = null;
            String acao = request.getParameter("acao");
            String idCidades = "";
            String pedidoNF = (request.getParameter("pedidoNF") != null ? request.getParameter("pedidoNF"):"");
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
%>

<script language="javascript" type="text/javascript">
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
        location.replace("./selecionactrc?acao=consultar&marcados=<%=marcados%>&acaoDoPai=<%=request.getParameter("acaoDoPai")%>&filial=<%=request.getParameter("filial")%>&mostratudo=<%=request.getParameter("mostratudo")%>"+
        "&tipo=<%=request.getParameter("tipo")%>"
        + "&tipoTransporte="+$('tipoTransporte').value
        + "&dtinicial="+$('dtinicial').value+"&dtfinal="+$('dtfinal').value+"&cidades="+concatCidades() + "&idmotorista="
        + $("idmotorista").value + "&motor_nome=" + $("motor_nome").value+ "&pedidoNF=" + $("pedidoNF").value);
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
            for (var i = 0; i <= quant; ++i){
                $("chk-"+i).checked = true;
            }
        }else{
            for (var i = 0; i <= quant; ++i){
                $("chk-"+i).checked = false;
            }

        }
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
        
        <title>WebTrans - Selecionar CTs para o manifesto</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <link href="../estilo.css" rel="stylesheet" type="text/css">
    </head>
    
    <body onLoad="carregando();">
        <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
        <input name="cid_destino"  type="hidden" class="fieldMin" id="cid_destino" style="background-color:#FFFFF1" value="" size="25" readonly="true">
        <input name="uf_destino"   type="hidden" class="fieldMin" id="uf_destino" style="background-color:#FFFFF1" value="" size="2" readonly="true">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr >
                <td width="619"><div align="left"><b>Selecionar CTs para o manifesto</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr> 
                <td class="TextoCampos">Intervalo de datas:</td>
          <td width="320" class="CelulaZebra2"><input name="dtinicial" class="fieldDate" type="text" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                                                onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)"> 
                    e 
                    <input name="dtfinal" type="text" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                           onBlur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)"></td>
              <td width="205" class="TextoCampos">Apenas o(s) destino(s):<span class="CelulaZebra2">
                      <img src="img/add.gif" border="0" class="imagemLink "  title="Adicionar um novo Destino" onClick="javascript:localizacid_destino();"></span>
              </td>
          <td width="244" class="CelulaZebra2">
<table width="100%" border="0">
                        <tbody id="cid">
                        </tbody>
                    </table>
                    
                    
                </td>
<td width="90" class="CelulaZebra2"><div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="javascript:tryRequestToServer(function(){pesquisar();});">
                </div></td>
          </tr>
            <tr>
              <td width="189" class="TextoCampos">Tipo:</td>
              <td class="CelulaZebra2" >
                        <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:160px;"   class="fieldMin">
                            <%= emiteRodoviario && emiteAereo && emiteAquaviario ? "<option value='false'" + (tipoTransporte != null && tipoTransporte.equals("false") ? "selected" : "") + ">Todos</option>" : ""%>
                            <%= emiteRodoviario ? "<option value='r'" + (tipoTransporte != null && tipoTransporte.equals("r") ? "selected" : "") + ">CTR - Transp. Rodoviário</option>" : ""%>
                            <%= emiteAereo ? "<option value='a'" + (tipoTransporte != null && tipoTransporte.equals("a") ? "selected" : "") + " >CTA - Transp. A&eacute;reo</option>" : ""%>
                            <%= emiteAquaviario ? "<option value='q'" + (tipoTransporte != null && tipoTransporte.equals("q") ? "selected" : "") + ">CTQ - Transp. Aquavi&aacute;rio</option>" : ""%>
                        </select>
              </td>
              <td class="TextoCampos" >
                  <div align="right">Apenas o motorista:</div>
              </td>
              <td class="CelulaZebra2" colspan="3">
                  <input name ="idmotorista" type="hidden" id="idmotorista"  value="<%=(request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0")%>">
                  <input name ="motor_nome"  type="text" class="inputReadOnly" id="motor_nome" size="30" value="<%=(request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "")%>" readonly="true">
                  <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                  <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpa Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
              </td>
            </tr>
            <tr>
                <td class="TextoCampos" >Pedido NF:</td>
                <td class="CelulaZebra2" colspan="4">
                    <input name="pedidoNF" type="text" style="font-size:8pt;" id="pedidoNF" size="12" value="<%=pedidoNF%>" class="inputtexto" >
                </td>
            </tr>
        </table>
        <br>
        
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr> 
                <td width="2%" class="tabela"><input type="checkbox" id="chkTodos" name="chkTodos" onclick="checkTodosCtrcs()"></td>
                <td width="5%" class="tabela">CTRC</td>
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
                                <font color="red">Após digitar o CT tecle "Enter" para selecioná-lo na lista abaixo.</font>
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
            if (selmanif.SelectCtrc(request.getParameter("filial"), marcados, mostraTudo , idMotorista, pedidoNF, tipoTransporte, true, "","" )) {
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
                <td><%=Apoio.to_curr(rs.getFloat("totnf_peso"))%></td>
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
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:tryRequestToServer(function(){seleciona();});">
                </div></td>
            </tr>
        </table>
        
    </body>
</html>

