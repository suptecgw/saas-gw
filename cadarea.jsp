<%@page import="nucleo.Auditoria.Auditoria"%>
<%@ page contentType="text/html" language="java"
         import="area.*,
         cidade.*,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript" type="text/javascript" src="script/builder.js"></script>
<script language="JavaScript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="JavaScript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="JavaScript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadarea") : 0);
    boolean souadm = Apoio.getUsuario(request).getSouAdm();
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
%>

<%

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaarea = false;
    CadArea cadarea = null;
    Area area = null;

    if (acao.equals("removerAreaCidadeAjax")) {
        //quando for colocar no gweb, use o controlador da nota
        
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Remover Area Cidade");
        auditoria.setRotina("Alterar Area Cidade");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans Areas");        
        
        CadArea.removerAreaCidade(Apoio.parseInt(request.getParameter("areaCidadeId")),
                Apoio.getUsuario(request).getConexao(), auditoria);
    }
    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {     //instanciando o bean de cadastro
        area = new Area();
        cadarea = new CadArea();
        cadarea.setConexao(Apoio.getUsuario(request).getConexao());
        cadarea.setExecutor(Apoio.getUsuario(request));
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int idarea = Apoio.parseInt(request.getParameter("id"));
        area.setId(idarea);
        cadarea.setAr(area);
        //carregando completo
        cadarea.LoadAllPropertys();
    } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        area.setDescricao(request.getParameter("descricao"));
        area.setSigla(request.getParameter("sigla"));
        area.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idremetente")));
        area.setCriadoPor(Apoio.getUsuario(request));
        area.setAlteradoPor(Apoio.getUsuario(request));
        //adicionando as cidades
        int maxCid = Apoio.parseInt(request.getParameter("maxCidade"));
        
        
        AreaCidade ac;
        for (int i = 0; i <= maxCid; i++){
            if(request.getParameter("areaCidadeId_"+i) != null){
                ac = new AreaCidade();
                ac.setId(Apoio.parseInt(request.getParameter("areaCidadeId_"+i)));
                ac.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idcidade_"+i)));
                area.getCidades().add(ac);
            }
        }
        
        
        if (acao.equals("atualizar")) {
            area.setId(Apoio.parseInt(request.getParameter("id")));
        }
        //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        cadarea.setAr(area);
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadarea.Inclui() : cadarea.Atualiza());

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        %><script language="javascript" type="text/javascript"><%
          if (erro) {
              acao = (acao.equals("atualizar") ? "editar" : "iniciar");
        %>alert('<%=(cadarea.getErros())%>');
           window.opener.document.getElementById("salvar").disabled = false;
           window.opener.document.getElementById("salvar").value = "Salvar";
            
    <%} else {%>
    window.opener.document.location.replace("./consulta_area.jsp?acao=iniciar");
    <%}%>
        window.close();
</script>

<%}
    //variavel usada para saber se o usuario esta editando
    carregaarea = (cadarea != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">
    
    jQuery.noConflict(); 
     
    var arAbasArea = new Array();
    
    arAbasArea[0] = new stAba('tdPrincipal','divCidades');
    arAbasArea[1] = new stAba('tdAbaAuditoria','divAuditoria');

    //Em caso de alteração, o combo UF recebe o valor do BD
    //Está sendo utilizado no onload do body
    var indexesForCidade = new Array(); 
    var ultLinha = 0; //Ultima linha cadastrada 

    function aoCarregar(){
    <%  if (carregaarea) {
       //adicioonando os ajudantes
       for (AreaCidade cid : area.getCidades()) {

    %>           addCidade("<%=cid.getCidade().getIdcidade()%>", 
       'node_cidades', 
        "<%=cid.getCidade().getDescricaoCidade()%>", 
       "<%=cid.getCidade().getUf()%>",
       "<%=cid.getId()%>");
    <%       }
   }
    %> 
   }

   function voltar(){
       location.replace("./consulta_area.jsp?acao=iniciar");
   }

   function removerAreaCidadeAjax(id){
        tryRequestToServer(function(){
            new Ajax.Request("cadarea.jsp?acao=removerAreaCidadeAjax&areaCidadeId="+id,{
                method:'post', 
                onSuccess: "alert('Cidade removida com sucesso!');"
                ,
                onError: "alert('Erro ao tentar remover a cidade!');"
            });
        });
    }

   function salva(acao){
       var formulario = document.getElementById("formulario");
       if (!wasNull('descricao,sigla'))
       {
           document.getElementById("salvar").disabled = true;
           document.getElementById("salvar").value = "Enviando...";
            if (acao == "atualizar")
               acao += "&id=<%=(carregaarea ? cadarea.getAr().getId() : 0)%>";
           formulario.action = "./cadarea.jsp?acao="+acao+"&maxCidade="+ultLinha;
           window.open('about:blank', 'pop', 'width=210, height=100');
           formulario.submit();
       }else
           alert("Preencha os campos corretamente!");
   }

   function Excluir(idarea){
       if (confirm("Deseja mesmo excluir esta área?")){
           location.replace("./consulta_area.jsp?acao=excluir&id="+idarea);
       }
   }

   function aoClicarNoLocaliza(idjanela)
   {          
       if (idjanela == "Cidade_Area"){
           addCidade(getObj('idcidade').value,'node_cidades', getObj('cidade').value,getObj('uf').value)
       }
   }

   function addCidade(idCidade, idTableRoot, cidade, uf, idAreaCidade)
   {
       var tableRoot = getObj(idTableRoot);
       var indice = getNextIndexFromTableRoot(idTableRoot);

       //simplificando na hora da chamada    
       var nameTR = "trCidade_id" + indice;
	  	  
       var trCidade = makeElement("TR", "class=colorClear&id="+nameTR);

       //fabricando campos e strings de comando
       var commonObj = "type=text&class=fieldMin";
	  
       //fabricando o botão de excluir	
       appendObj(trCidade, makeWithTD("IMG","src=img/cancelar.png&border=0&onclick=removeCidade('"+nameTR+"',"+idAreaCidade+")&class=imagemLink&title=Remover esta cidade"));

       appendObj(trCidade, makeElement("INPUT","type=hidden&id=idcidade"+indice+"&name=idcidade_"+indice+"&value="+idCidade));
       appendObj(trCidade, makeWithTD("INPUT", commonObj + "&id=cidade"+indice+"&name=cidade_"+indice+"&maxLength=40&size=40&value="+cidade+"&readOnly=true"));
       appendObj(trCidade, makeWithTD("INPUT", commonObj + "&id=uf"+indice+"&name=uf_"+indice+"&maxLength=2&size=3&value="+uf+"&readOnly=true"));
       appendObj(trCidade, makeElement("INPUT", "type=hidden&id=areaCidadeId_"+indice+"&name=areaCidadeId_"+indice+"&maxLength=2&size=3&value="+idAreaCidade+"&readOnly=true"));
			  
       //adicionando a linha na tabela
       tableRoot.lastChild.appendChild(trCidade);	  	  
       markFlagCidade(idCidade, indice, true);
	  
       ultLinha++;
	  
       //chamando um possivel metodo que aplica eventos em alguns campos da nota adicionada
       if (window.applyEventInNote != null)
           applyEventInGrupo();
   }

   /**Retorna o próximo ID da table*/
   function getNextIndexFromTableRoot(idTableRoot) {
       if (getObj("trCidade_id1") == null)
           return 1;

       var r = 2;
       while (getObj("trCidade_id"+r) != null)
           ++r;
		
       return 	r;
   }

   /**Remove uma cidade de uma lista*/
   function removeCidade(nameObj, id) {
       if (confirm("Deseja mesmo excluir esta cidade ?")){
           getObj(nameObj).parentNode.removeChild(getObj(nameObj));
           if (id != 0) {
                removerAreaCidadeAjax(id);    
            }
       }
       
   }

   /**Marca a cidade como ativa ou inativa*/
   function markFlagCidade(idCidade, cidadeIndex, flagBool)
   {
       if (indexesForCidade["id"+idCidade] == null)
           indexesForCidade["id"+idCidade] = new Array();
 
       indexesForCidade["id"+idCidade][cidadeIndex] = flagBool;
   }

   function abrirLocalizarCidadeArea(){
       var paramAux = "";
       if ($("idremetente").value == "0" || $("idremetente").value == "") {
            paramAux = "is null";
       }else{
            paramAux = " = "+$("idremetente").value;
       }
       launchPopupLocate('./localiza?acao=consultar&idlista=35&paramaux='+paramAux+'&fecharJanela=false','Cidade_Area');
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
            }
        }
        countLog = 0;
        var rotina = "areas";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = <%=(carregaarea ? cadarea.getAr().getId() : 0)%>;
        consultarLog(rotina, id, dataDe, dataAte);
                
    }
    
    function setAuditoria(){
        $("dataDeAuditoria").value="<%=carregaarea ? Apoio.getDataAtual() :  "" %>" ;   
        $("dataAteAuditoria").value="<%=carregaarea ? Apoio.getDataAtual() : "" %>" ;           
    }
    
    function AlternarAbasGenericoArea(menu, conteudo) {
        try {
            if (arAbasArea != null) {
                for (var i = 0; i < arAbasArea.length; i++) {
                    if (arAbasArea[i] != null && arAbasArea[i] != undefined) {
                        var max = arAbasArea[i].conteudo.split(",").length;
                        
                        m = document.getElementById(arAbasArea[i].menu);
                        m.className = 'menu';
                        
                        for (var j = 0; j < max; j++) {
                            
                            
                            c = document.getElementById(arAbasArea[i].conteudo.split(",")[j]);
                            
                            if (c != null) {
                                console.log("1" + $(arAbasArea[i].conteudo.split(",")[j]));
                                console.log($(arAbasArea[i].conteudo.split(",")[j]));
                                invisivel(c, false);
                            } else if ($(arAbasArea[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                                invisivel($(arAbasArea[i].conteudo.split(",")[j].replace("div", "tr")), false);
                            }   
                        }
                    }
                }
                m = document.getElementById(menu);
                m.className = 'menu-sel';
                for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                    c = document.getElementById(conteudo.split(",")[i]);
                    if (c != null) {
                        visivel(c, false);
                    } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                        visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                    }
                }
            } else {
                alert("Inicialize a variavel arAbasArea!");
            }
        } catch (e) {
            alert(e);
        }
    }

</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes_gweb.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
        </style>
    </head>

    <body onLoad="aoCarregar();AlternarAbasGenericoArea('tdPrincipal','divCidades');setAuditoria();">
        <img src="img/banner.gif" >
        <input type="hidden" name="idcidade" id="idcidade" value="0">
        <input type="hidden" name="cidade" id="cidade" value="">
        <input type="hidden" name="uf" id="uf" value="">
        <br>
        <form method="post"  id="formulario" target="pop">
            <table width="40%" align="center" class="bordaFina" >
                <tr>
                    <td width="268">
                        <div align="left">
                            <b>&Aacute;reas</b>
                        </div>
                    </td>
                    <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                    <td width="63">
                        <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                               onClick="Excluir(<%=(carregaarea ? cadarea.getAr().getId() : 0)%>)">
                    </td>
                    <%}%>
                    <td width="74" >
                        <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();">
                    </td>
                </tr>
            </table>
            <br>
            <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td colspan="3" align="center">Dados principais</td>
                </tr>
                <tr>
                    <td class="TextoCampos">*Sigla:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="sigla" type="text" id="sigla" value="<%=(carregaarea ? cadarea.getAr().getSigla() : "")%>" size="17" maxlength="15" class="inputtexto">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">*Descri&ccedil;&atilde;o:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="descricao" type="text" id="descricao" value="<%=(carregaarea ? cadarea.getAr().getDescricao() : "")%>" size="30" maxlength="20" class="inputtexto">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Cliente:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="idremetente" type="hidden" id="idremetente" value="<%=(carregaarea ? cadarea.getAr().getCliente().getId() : "")%>" >
                        <input name="rem_rzs" type="text" id="rem_rzs" value="<%=(carregaarea ? cadarea.getAr().getCliente().getRazaosocial() : "")%>" style="font-size: smaller" size="25" maxlength="20" class="inputReadOnly8pt">
                        <input name="rem_cnpj" type="text" id="rem_cnpj" value="<%=(carregaarea ? cadarea.getAr().getCliente().getCnpj() : "")%>" style="font-size: smaller" size="17" maxlength="20" class="inputReadOnly8pt">
                        <input type="button" id="botLocCliente" value="..." class="botoes" onclick="popLocate(3, 'Remetente','');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="getObj('idremetente').value = '0';getObj('rem_rzs').value = '';getObj('rem_cnpj').value = '';">
                    </td>
                </tr>
            </table>
            <table width="40%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenericoArea('tdPrincipal','divCidades')"> Dados Principais </td>
                                                     
                                  <td style='display: <%=carregaarea && nivelUser == 4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenericoArea('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                     
                               </tr>
                            </table>
                        </td> 
                    </tr>              
                                         
                </table>  
                <div id="divCidades">
                    <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">                     
                        <tr> 
                            <td colspan="9"> 
                                <table id="node_cidades" border="0" style="width:100%; height:100%; border: 1 solid #000">
                                    <tr class="cellNotes"> 
                                        <td width="24%" class="CelulaZebra2">
                                            <div align="center">
                                                <img src="img/add.gif" border="0" title="Adicionar uma nova cidade" class="imagemLink" onClick="abrirLocalizarCidadeArea();">          
                                            </div>
                                        </td>
                                        <td width="66%" class="CelulaZebra2" >
                                            <div align="center">Cidade</div>
                                        </td>
                                        <td width="10%" class="CelulaZebra2" >
                                            <div align="center">UF</div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>                    
                    </table>
                </div>  
                  <div id="divAuditoria" width="40%" style='display: <%=carregaarea && nivelUser == 4 ? "" : "none"%>' >

                      <table colspan="3" width="40%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria" >
                          <%@include file="./gwTrans/template_auditoria.jsp" %>
                      </table>
                      <table width="40%" border="0" align="center" cellpadding="2" class="bordaFina">
                            <tr class="CelulaZebra2"> 
                                <td  class="TextoCampos" width="10%">Incluso:</td>
                                <td width="30%">
                                    Em: <%=carregaarea && cadarea.getAr().getCriadoEm() != null ? Apoio.getFormatData(cadarea.getAr().getCriadoEm()) : ""%> 
                                    <br>
                                    Por: <%=carregaarea && cadarea.getAr().getCriadoPor().getNome() != null ? cadarea.getAr().getCriadoPor().getNome() : ""%>
                                </td>
                                <td class="TextoCampos" width="10%">Alterado:
                                <td width="30%">Em: <%=(carregaarea && cadarea.getAr().getAlteradoEm() != null) ? Apoio.getFormatData(cadarea.getAr().getAlteradoEm()) : ""%>
                                    <br>
                                    Por: <%=(carregaarea && cadarea.getAr().getAlteradoPor().getNome() != null) ? cadarea.getAr().getAlteradoPor().getNome() : ""%> 
                                </td>
                            </tr>
                        </table>  
                  </div> 
                              <!--                <tr class="tabela">
                                                  <td colspan="3" align="center">Cidades dessa &aacute;rea</td>
                                              </tr>-->
                              <br/>
                  <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">    
                      <tr class="CelulaZebra2">
                         <td colspan="5">
                          <% if (nivelUser >= 2) {%>
                             <center>
                                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                            </center>
                        </td>
                        <%}%>    
                     </tr>
                  </table>
        </form>            
    </body>
</html>

