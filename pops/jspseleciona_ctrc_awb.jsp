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
<script language="JavaScript" type="text/javascript" src="../script/beans/CTRC.js"></script>

<%
    int linha = 0;
    int qtdCtrc = request.getParameter("qtdCtrc") == null ? 0 : Integer.parseInt(request.getParameter("qtdCtrc"));
    String idsChecados = request.getParameter("idsCtrcAwb") == null ? "0" : request.getParameter("idsCtrcAwb");
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

    for (int i = 1; i <= qtdCtrc; i++) {
        if (request.getParameter("chk-" + i) != null) {
            idsChecados += (idsChecados == "" ? "" : ",") + request.getParameter("chk-" + i);
        }
    }
%>

<Script language="javascript" type="text/javascript">

    shortcut.add("alt+s",function(){seleciona();});
    shortcut.add("alt+p",function(){pesquisa();});



    function seleciona(){
        var retorno = "";
        var ctrc = null;
        window.opener.removerCtrcs();
        for (var i = 1; i <= quant; ++i){
            if($("chk-"+i).value != null){
                if ($("chk-"+i).checked){
                    ctrc = new CTRC($("chk-"+i).value, $("nfiscal_"+i).value, $("serie_"+i).value,
                    $("dtemissao_"+i).value, $("remetente_"+i).value, $("destinatario_"+i).value, $("totnf_volume_"+i).value,
                    $("totnf_peso_"+i).value, $("totnf_valor_"+i).value, $("vlfrete_"+i).value);
                    //adicionando o ctrc no cadastro de awb
                    window.opener.addCTRC(ctrc);
                        
                    if (retorno == ""){
                        retorno += $("chk-"+i).value;
                    }else  {
                        retorno += ","+$("chk-"+i).value;
                    }
                }
            }
        }

        if (retorno == ""){
            return alert("Informe no mínimo um CT.");
        }
        window.opener.calculaPesoReal();
        fechar();
    }

    var quant = ""; //Quantidade de resultados
    var indexCid = 0;
    function fechar(){
        window.close();
    }

    function localizacid_destino(){
        post_cad = window.open('../localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_DESTINO%>','destino_'+countCid,
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela){
        //localizando cidade
        if(idjanela == 'destino'){
            addCid($('idcidadedestino').value, $('cid_destino').value, $('uf_destino').value);
        }else if(idjanela.split('_')[0] == 'destino'){
            $('idCid_'+idjanela.split('_')[1]).value = $('idcidadedestino').value;
            $('cidade_'+idjanela.split('_')[1]).value = $('cid_destino').value;
            $('uf_'+idjanela.split('_')[1]).value = $('uf_destino').value;
        }
    }

    function carregar(){
        addCidade();
        $("dtinicial").focus();
    }

    function insertLocalizar(){
        addCidade();
        localizacid_destino();
    }

    function pesquisa(){
        $("formulario").submit();
    }

    function checkCtrc(evento){
        if( evento.keyCode==13 ) {
            //for (var i = 0; i <= quant; ++i){
            if($("hidden_ctrc_"+$("selCtrc").value) != null){
                $("chk-"+$("hidden_ctrc_"+$("selCtrc").value).value).checked = true;
                $("selCtrc").value = "";
                //break;
            }else{
                alert("CTA não encontrado.");
            }
            //}
        }
    }

    //--------------- cidade ----------------- inicio
    var countCid =0;
	
    function Cidade(id, cidade, uf){
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
        var inp3_= Builder.node("input",{type: "button", id:"localiza_destino_"+countCid, name: "localiza_destino"+countCid, className:"botoes", value: "...", onClick:'javascript:launchPopupLocate(\'../localiza?acao=consultar&idlista=12\',\'destino_'+countCid+'\');'});

        td1_.appendChild(inp0_);
        td1_.appendChild(inp1_);
        td1_.appendChild(inp2_);
        td1_.appendChild(inp3_);

        tr_.appendChild(td1_);

        $("cid").appendChild(tr_);
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

        <title>WebTrans - Selecionar CTs para o AWB</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <link href="../estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="carregar();">
        <form id="formulario" name="formulario" method="post" action="jspseleciona_ctrc_awb.jsp" >
            <input type="hidden" name="tipo" id="tipo" value="a" >
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
            <input type="hidden" name="filial" id="filial" value="<%=request.getParameter("filial")%>">
            <input name="cid_destino" type="hidden" class="fieldMin" id="cid_destino" style="background-color:#FFFFF1" value="" size="25" readonly="true">
            <input name="uf_destino" type="hidden" class="fieldMin" id="uf_destino" style="background-color:#FFFFF1" value="" size="2" readonly="true">

            <br>
            <table width="95%" align="center" class="bordaFina" >
                <tr >
                    <td width="619"><div align="left"><b>Selecionar CTs para o AWB</b></div></td>
                    <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
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
                    <td width="174" class="TextoCampos">Apenas o(s) destino(s):<span class="CelulaZebra2">
                            <img src="../img/add.gif" border="0" class="imagemLink "  title="Adicionar um novo Destino" onClick="javascript:insertLocalizar();"></span>

                    <td width="244" class="CelulaZebra2">
                        <table width="100%" border="0">
                            <tbody id="cid">

                            </tbody>
                        </table>


                    </td>
                    <td width="111" class="CelulaZebra2"><div align="center">
                            <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="pesquisa();">
                        </div></td>
                </tr>
                <tr>
                    <td width="189" colspan="2" class="TextoCampos"> Informe o CTA que deseja marcar:</td>
                    <td class="CelulaZebra2" colspan="3">
                        <input name="selCtrc" type="text" style="font-size:8pt;" id="selCtrc" size="7" value="" class="inputtexto" onKeyPress="checkCtrc(event)">
                        <font color="red"> (após informar o número de CTA tecle "Enter")</font>
                    </td>
                </tr>
                <tr>
                    <td colspan="5" class="celulaZebra2">
                        <input type="checkbox" name="mostrarSemVinculo" id="mostrarSemVinculo" <%=Apoio.parseBoolean(request.getParameter("mostrarSemVinculo")) ? "checked": ""%> />
                        Mostrar CTA vinculado a outro AWB
                    </td>
                </tr>
            </table>
            <br>

            <table width="95%" align="center" cellspacing="1" class="bordaFina">
                <tr> 
                    <td width="2%" class="tabela"></td>
                    <td width="5%" class="tabela">CTA</td>
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
                <% //variaveis da paginacao      

                    // se conseguiu consultar
                    selawb.setDtInicial(Apoio.paraDate(request.getParameter("dtinicial")));
                    selawb.setDtFinal(Apoio.paraDate(request.getParameter("dtfinal")));
                    selawb.setTipo(request.getParameter("tipo"));
                    selawb.setCidadeDestinoId(idCidades);
                    if (selawb.SelectCtrc(request.getParameter("filial"), idsChecados, mostraTudo, Apoio.parseBoolean(request.getParameter("mostrarSemVinculo")))) {
                        ResultSet rs = selawb.getResultado();
                        while (rs.next()) {
                            //pega o resto da divisao e testa se é par ou impar
                %>
                <tr class="<%=((linha++ % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                    <%boolean encontrou = false;
                    for (int i = 0; i <= marcados.split(",").length - 1; i++) {
                        if (marcados.split(",")[i].equals(rs.getString("idmovimento"))) {%>
                    <td><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("idmovimento")%>"checked></td>
                        <%encontrou = true;
                        }
                    }
                    if (!encontrou) {%>
                    <td><input name="<%="chk-" + linha%>" type="checkbox" id="<%="chk-" + linha%>" <%=(idsChecados.indexOf(rs.getString("idmovimento")) >= 0 ? "checked" : "")%> value="<%=rs.getString("idmovimento")%>"></td>
                        <%}

                        %>
                    <td ><%=rs.getString("nfiscal")%>
                        <input type="hidden" name="nfiscal_<%=linha%>" id="nfiscal_<%=linha%>"  value="<%=rs.getString("nfiscal")%>">
                        <input type="hidden" name="<%="hidden_ctrc_" + rs.getString("nfiscal")%>" id="<%="hidden_ctrc_" + rs.getString("nfiscal")%>" value="<%=linha%>">
                    </td>
                    <td ><div align="center">
                            <input type="hidden" name="serie_<%=linha%>" id="serie_<%=linha%>"  value="<%=rs.getString("especie") + "/" + rs.getString("serie")%>">
                            <%=rs.getString("especie") + "/" + rs.getString("serie")%></div></td>
                    <td>
                        <input type="hidden" name="dtemissao_<%=linha%>" id="dtemissao_<%=linha%>"  value="<%=formato.format(rs.getDate("dtemissao"))%>">
                        <%=formato.format(rs.getDate("dtemissao"))%></td>
                    <td>
                        <input type="hidden" name="abreviatura_<%=linha%>" id="abreviatura_<%=linha%>"  value="<%=rs.getString("abreviatura")%>">
                        <%=rs.getString("abreviatura")%></td>
                    <td>
                        <input type="hidden" name="remetente_<%=linha%>" id="remetente_<%=linha%>"  value="<%=rs.getString("remetente")%>">
                        <%=rs.getString("remetente")%></td>
                    <td>
                        <input type="hidden" name="destinatario_<%=linha%>" id="destinatario_<%=linha%>"  value="<%=rs.getString("abreviatura")%>">
                        <%=rs.getString("destinatario")%></td>
                    <td>
                        <input type="hidden" name="totnf_volume_<%=linha%>" id="totnf_volume_<%=linha%>"  value="<%=rs.getString("totnf_volume")%>">
                        <%=rs.getFloat("totnf_volume")%></td>
                    <td>
                        <input type="hidden" name="totnf_peso_<%=linha%>" id="totnf_peso_<%=linha%>"  value="<%=rs.getString("totnf_peso")%>">
                        <%=Apoio.to_curr(rs.getFloat("totnf_peso"))%></td>
                    <td>
                        <input type="hidden" name="totnf_valor_<%=linha%>" id="totnf_valor_<%=linha%>"  value="<%=rs.getString("totnf_valor")%>">
                        <%=Apoio.to_curr(rs.getFloat("totnf_valor"))%></td>
                    <td>
                        <input type="hidden" name="vlfrete_<%=linha%>" id="vlfrete_<%=linha%>"  value="<%=rs.getString("vlfrete")%>">
                        <%=Apoio.to_curr(rs.getFloat("vlfrete"))%></td>
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
                            <input type="hidden" name="qtdCtrc" id="qtdCtrc"  value="<%=linha%>">
                            <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="seleciona();">
                        </div></td>
                </tr>
            </table>
        </form>
    </body>
</html>
