<%@page import="nucleo.Auditoria.Auditoria"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Enumeration"%>
<%@page import="cidade.BeanCidadeEDI"%>
<%@page import="java.util.ArrayList"%>
<%@page import="area.Area"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html" language="java"
   import="cidade.BeanCadCidade,
           nucleo.Apoio,
           java.sql.ResultSet,
           cidade.pais.BeanConsultaPais,
           nucleo.BeanConfiguracao" errorPage="" %>

<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   BeanUsuario autenticado = Apoio.getUsuario(request);
   int nivelUser = (autenticado != null
                    ? autenticado.getAcesso("cadcidade") : 0);
   boolean souadm = autenticado.getSouAdm();
   //testando se a sessao é válida e se o usuário tem acesso
   if ((autenticado == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<% 

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregacidade = false;
  cidade.BeanCadCidade cadcidade = null;
  Collection<Area> areas = null;
  Collection<BeanCidadeEDI> listaCidadesEDI = null;

  //Carregando as configuraões independente da ação
  BeanConfiguracao cfg = new BeanConfiguracao();
  cfg.setConexao(Apoio.getUsuario(request).getConexao());
  //Carregando as configurações
  cfg.CarregaConfig();
  
  if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")){
      //instanciando o bean de cadastro
        cadcidade = new BeanCadCidade();
        cadcidade.setConexao(Apoio.getUsuario(request).getConexao());
        cadcidade.setExecutor(Apoio.getUsuario(request));
  }
  
  if(acao.equals("excluirCidadeEDI")){
      int idEDI = Integer.parseInt(request.getParameter("id"));
      if(idEDI != 0){
        
        Auditoria auditoria = new Auditoria();
        auditoria.setIp(request.getRemoteHost());
        auditoria.setAcao("Excluir Cidade EDI");
        auditoria.setRotina("Alterar Cidade");
        auditoria.setUsuario(Apoio.getUsuario(request));
        auditoria.setModulo("WebTrans Cidade");        
        
        cadcidade.excluirCidadeEDI(idEDI,autenticado, auditoria);   
      }
  }
  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null)){
     int idcidade = Integer.parseInt(request.getParameter("id"));
     cadcidade.setIdcidade(idcidade);
     //carregando completo
     cadcidade.LoadAllPropertys();
     areas = cadcidade.getCidadeOb().getAreas();                    
  }else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))){
      //populando o JavaBean
      cadcidade.setCidade( request.getParameter("cidade") );
      cadcidade.setUf( request.getParameter("uf") );
      cadcidade.setCod_municipio( request.getParameter("cod_municipio") );
      cadcidade.setCod_srf( request.getParameter("cod_srf") );
      cadcidade.setCod_ibge( request.getParameter("cod_ibge") );
      cadcidade.setCod_mastermaq( request.getParameter("cod_mastermaq") );
      cadcidade.setSiglaAereo(request.getParameter("sigla"));
      cadcidade.setSiglaViaAereo(request.getParameter("via"));
      cadcidade.getPais().setId(Integer.parseInt(request.getParameter("pais")));
      cadcidade.setCapital(Apoio.parseBoolean(request.getParameter("isCapital")));
      cadcidade.setQtdHorasBaixarComprovanteEntrega(Apoio.parseInt(request.getParameter("qtdHoras")));
      cadcidade.setIsSeguroUrbano(Apoio.parseBoolean(request.getParameter("isUrbana")));
      cadcidade.setCodSiafi(request.getParameter("codSiafi"));
      cadcidade.setCodDipam(request.getParameter("codDipam"));
      BeanCidadeEDI cidadeEDI = null;      
      int maxCidades = Integer.parseInt(request.getParameter("maxCidade"));
       
      if(maxCidades != 0){            
        int i;
        for(i = 1; i <= maxCidades; i++){          
          cidadeEDI = new BeanCidadeEDI();
          cidadeEDI.setId(request.getParameter("id_"+i) == null ? 0 : Integer.parseInt(request.getParameter("id_"+i)));
          cidadeEDI.getCidade().setIdcidade(request.getParameter("cidadeId_"+i) == null ? 0 : Integer.parseInt(request.getParameter("cidadeId_"+i)));
          cidadeEDI.setDescricao(request.getParameter("descricao_" + i) == null ? "" : request.getParameter("descricao_" + i));          
          cadcidade.getListaCidadeEDI().add(cidadeEDI);
        }
        
        //aba de Informações Operacionais.
        
      }
      if (acao.equals("atualizar"))          
          cadcidade.setIdcidade(Integer.parseInt(request.getParameter("id")));
      //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
      //3º teste de erro naquela acao executada.
      boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                      ? cadcidade.Inclui() : cadcidade.Atualiza());
      
//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
         if (erro){
             acao = (acao.equals("atualizar") ? "editar" : "iniciar");
             %>alert('<%=(cadcidade.getErros())%>');
             
             window.opener.document.getElementById("salvar").disabled = false;
	     window.opener.document.getElementById("salvar").value = "Salvar"
             
             window.close();
        <%}else{%>
             window.opener.document.location.replace("ConsultaControlador?codTela=64");
             window.close();
        <%}%>
       </script>

 <%}
   //variavel usada para saber se o usuario esta editando
   carregacidade = (cadcidade != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>
 <script language="javascript" type="text/javascript">
     
 arAbasGenerico = new Array();
 arAbasGenerico[0] = new stAba('tbIntegra','tab1');
 arAbasGenerico[1] = new stAba('tbConfigEdi','tab2');
 arAbasGenerico[2] = new stAba('tbInfoOp','tab3');
 arAbasGenerico[3] = new stAba('tbAuditoria','tab4');
 
  //Em caso de alteração, o combo UF recebe o valor do BD
  //Está sendo utilizado no onload do body
  function atribuicombos(){
    <%
    if (cadcidade != null)
    {%>
        document.getElementById("uf").value = "<%=cadcidade.getUf()%>";
        document.getElementById("pais").value = "<%=cadcidade.getPais().getId()%>";
      <%
    }%>
  }


  function voltar(){
     location.replace("ConsultaControlador?codTela=64");
  }

  function salva(acao){      
       try {
            if (!wasNull('cidade')){
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";
//		  if (acao == "atualizar")
//			 acao += "&id=";
//  		     document.location.replace("./cadcidade?acao="+acao+"&"+
//                         concatFieldValue("cidade,uf,cod_municipio,cod_srf,cod_ibge,cod_mastermaq,area_id,sigla,via,pais,isCapital,maxCidade"));
                 window.open('about:blank', 'pop', 'width=210, height=100');
                 var form = $("formulario");
                 form.action = "./cadcidade?acao="+acao+"&id=<%=(carregacidade ? cadcidade.getIdcidade() : 0)%>";
                 form.submit();
         }else{
	   alert("Preencha os campos corretamente!");
         }
    } catch (e) {
        alert(e);
    }
  }

  function excluir(idcidade){
       if (confirm("Deseja mesmo excluir esta cidade?"))
	   {
	       location.replace("./consultacidade?acao=excluir&id="+idcidade);
	   }
  }
  function trocar(){
        if($("isCapital").checked == true){
           $("isCapital").value = "true"; 
        }else{
           $("isCapital").value = "false"; 
        }
        if($("isUrbana").checked == true){
           $("isUrbana").value = "true";
        }else{
           $("isUrbana").value = "false";
        }
    }
  function setDefault(){
      $("isCapital").checked = <%=((carregacidade)?cadcidade.isCapital():false)%>;
      $("isCapital").check = <%=((carregacidade)?cadcidade.isCapital():false)%>;
      $("isCapital").value = <%=((carregacidade)?cadcidade.isCapital():false)%>;
      $("isUrbana").checked = <%=((carregacidade)?cadcidade.isIsSeguroUrbano():false)%>;
      $("isUrbana").check = <%=((carregacidade)?cadcidade.isIsSeguroUrbano():false)%>;
      $("isUrbana").value = <%=((carregacidade)?cadcidade.isIsSeguroUrbano():false)%>;
      $("trCidades").style.display = "none";
      
  }

  function getIBGE(){
      window.open('http://www.ibge.gov.br/home/geociencias/areaterritorial/area.php?nome='+$('cidade').value+'&codigo=&submit.x=43&submit.y=3', 'pop', '');
  }
  
  // Objeto Cidade
  function itemCidadesEDI(id, cidade_id, descricao){
      this.id = (id != undefined && id != null ? id : 0);
      this.cidade_id = (cidade_id != undefined && cidade_id != null ? cidade_id : 0);
      this.descricao = (descricao != undefined && descricao != null ? descricao : "");
  }
  
  // DOM - Excluir
  function excluirCidade(id, index){      
      var existe = false;
      if(confirm("Deseja excluir esta Cidade ?")){
          if(confirm("Tem Certeza ?")){
              if(id != 0){
                new Ajax.Request("./cadcidade?acao=excluirCidadeEDI&id="+id, 
                {
                  method: 'get',
                  onSuccess: function(){
                      alert('Cidade EDI excluida com sucesso!')
                      Element.remove("idLinha_"+index);
                  },
                  onFailure: function(){                      
                      alert('Erro ao tentar Excluir a Cidade EDI!')                      
                  }
                });
              }else{
                Element.remove("idLinha_"+index);
              }
              var i;
              for(i = 1; i <= countNovasCidadesEDI; i++){
                    if($("idLinha_"+i) != null){
                        existe = true;
                    }
              }
              if(!existe){
                $("trCidades").style.display = "";
              }
          }
      }
  }
  
  //DOM - Adicionar novas cidades para EDI.
  var countNovasCidadesEDI = 0;
  function addNovasCidadesEDI(itensCidadesEDI){
      $("trCidades").style.display = "";
      try{
          
          if(itensCidadesEDI == null || itensCidadesEDI == undefined){
              itensCidadesEDI = new itemCidadesEDI();
          }
          
          countNovasCidadesEDI++;
          var tabelaBase = $("tbCidades");
          
          var tr = Builder.node("tr" , {
              className:"CelulaZebra2" ,
              id:"idLinha_" + countNovasCidadesEDI
          });
          
          var td0 = Builder.node("td" , {
              align: "center"
          });
          
          var img0 = Builder.node("img",{
             className:"imagemLink" ,
             src: "img/lixo.png" ,
             onClick:"excluirCidade(" + itensCidadesEDI.id + "," + countNovasCidadesEDI + ");"
          });
          
          td0.appendChild(img0);
          
          var td1 = Builder.node("td" , {
             align: "center" 
          });
          
          var inpId = Builder.node("input" , {
              type: "hidden" ,
              name: "id_" + countNovasCidadesEDI ,
              id: "id_" + countNovasCidadesEDI ,
              value: itensCidadesEDI.id
          });
          
          var inpCidadeId = Builder.node("input" , {
              type: "hidden" ,
              name: "cidadeId_" + countNovasCidadesEDI ,
              id: "cidadeId_" + countNovasCidadesEDI ,
              value: itensCidadesEDI.cidade_id
          });
          
          var text1 = Builder.node("input" , {
              className: "fieldMin" ,
              type: "text" ,
              size: "30" ,
              maxLength : "50" ,
              name: "descricao_" + countNovasCidadesEDI ,
              id: "descricao_" + countNovasCidadesEDI ,
              value: itensCidadesEDI.descricao
          });
          
          td1.appendChild(inpId);
          td1.appendChild(inpCidadeId);
          td1.appendChild(text1);
          
          tr.appendChild(td0);
          tr.appendChild(td1);
          
          tabelaBase.appendChild(tr);
          
          $('maxCidade').value = countNovasCidadesEDI;
          
      }catch(e){
          alert(e);
      }
  }
  // Carregar o DOM
  function aoCarregar(){
      $("trCidades").style.display = "none";
      <%
      if(carregacidade){
          
         for(BeanCidadeEDI edis : cadcidade.getListaCidadeEDI()){%>
           var cidadeEdis = new itemCidadesEDI();
            cidadeEdis = new itemCidadesEDI('<%=edis.getId()%>','<%=edis.getCidade().getIdcidade()%>','<%=edis.getDescricao()%>');
            addNovasCidadesEDI(cidadeEdis);
     
        <%}
          
          
      }
      
      %>
              mostrarDipam();
             
              
  }
  function mostrarDipam(){
      var uf = $("uf").value;
      if(uf == "SP"){
          $("trCodDipam").style.display = "";
      }else{
          $("trCodDipam").style.display = "none";  
          $("codDipam").value = "";
     }
      
  }
  function pesquisarAuditoria() {
            if (countLog != null && countLog != undefined) {
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
            var rotina = "cidade";
            var dataDe = $("dataDeAuditoria").value;
            var dataAte = $("dataAteAuditoria").value;
            var id = <%=(carregacidade ? cadcidade.getIdcidade() : 0)%>;
            console.log(rotina, id, dataDe, dataAte);
            consultarLog(rotina, id, dataDe, dataAte);

        }
  function setDataAuditoria() {

        $("dataDeAuditoria").value = "<%=carregacidade ? Apoio.getDataAtual() : ""%>";
        $("dataAteAuditoria").value = "<%=carregacidade ? Apoio.getDataAtual() : ""%>";

    }      
</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro de Cidades</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
        <!--
        .style1 {font-size: 10px}
        -->
        </style>
    </head>

    <body onLoad="javascript:atribuicombos();setDefault();aoCarregar();AlternarAbasGenerico('tbIntegra','tab1');setDataAuditoria()">
        <img src="img/banner.gif" >
        <form method="post" action="" id="formulario" target="pop">
            <input type="hidden" name="area_id" id="area_id" value="<%=(carregacidade ? cadcidade.getArea().getId() : 0)%>">

            <br>
            <table width="40%" align="center" class="bordaFina" >
                <tr >
                    <td width="613"><div align="left"><b>Cadastro de Cidade</b></div></td>
                    <%  //se o paramentro vier com valor entao nao pode excluir
                    if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                    <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir"
                                          onClick="javascript:excluir(<%=(carregacidade ? cadcidade.getIdcidade() : 0)%>)"></td>
                        <%}%>
                    <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
                </tr>
            </table>
            <br>
            <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td colspan="3" align="center">Dados principais</td>
                </tr>
                <tr>
                    <td class="TextoCampos">*Cidade:</td>
                    <td colspan="2" class="CelulaZebra2"><input name="cidade" type="text" id="cidade" value="<%=(carregacidade ? cadcidade.getCidade() : "")%>" size="45" maxlength="40" class="inputtexto"></td>
                </tr>
                <tr>
                    <td width="52" class="TextoCampos">*UF:</td>
                    <td colspan="2" class="CelulaZebra2"> 
                        <select name="uf" id="uf" class="inputtexto" onchange="javascript:mostrarDipam()">
                            <option value="AC" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("AC") ? "selected" : ""%>>AC</option>
                            <option value="AL" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("AL") ? "selected" : ""%>>AL</option>
                            <option value="AM" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("AM") ? "selected" : ""%>>AM</option>
                            <option value="AP" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("AP") ? "selected" : ""%>>AP</option>
                            <option value="BA" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("BA") ? "selected" : ""%>>BA</option>
                            <option value="CE" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("CE") ? "selected" : ""%>>CE</option>
                            <option value="DF" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("DF") ? "selected" : ""%>>DF</option>
                            <option value="ES" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("ES") ? "selected" : ""%>>ES</option>
                            <option value="GO" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("GO") ? "selected" : ""%>>GO</option>
                            <option value="MA" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("MA") ? "selected" : ""%>>MA</option>
                            <option value="MG" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("MG") ? "selected" : ""%>>MG</option>
                            <option value="MS" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("MS") ? "selected" : ""%>>MS</option>
                            <option value="MT" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("MT") ? "selected" : ""%>>MT</option>
                            <option value="PA" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("PA") ? "selected" : ""%>>PA</option>
                            <option value="PB" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("PB") ? "selected" : ""%>>PB</option>
                            <option value="PE" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("PE") ? "selected" : ""%>>PE</option>
                            <option value="PI" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("PI") ? "selected" : ""%>>PI</option>
                            <option value="PR" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("PR") ? "selected" : ""%>>PR</option>
                            <option value="RJ" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("RJ") ? "selected" : ""%>>RJ</option>
                            <option value="RN" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("RN") ? "selected" : ""%>>RN</option>
                            <option value="RO" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("RO") ? "selected" : ""%>>RO</option>
                            <option value="RR" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("RR") ? "selected" : ""%>>RR</option>
                            <option value="RS" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("RS") ? "selected" : ""%>>RS</option>
                            <option value="SC" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("SC") ? "selected" : ""%>>SC</option>
                            <option value="SE" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("SE") ? "selected" : ""%>>SE</option>
                            <option value="SP" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("SE") ? "selected" : ""%>>SP</option>
                            <option value="TO" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("TO") ? "selected" : ""%>>TO</option>
                            <option value="EX" <%=Apoio.getUsuario(request).getFilial().getCidade().getUf().equalsIgnoreCase("EX") ? "selected" : ""%>>EX</option>
                        </select>
                        <input type="checkbox"  name="isCapital" id="isCapital"  style="margin-left:60px;" onclick=" trocar()" />
                        <span class="TextoCampos">Capital</span>
                    </td>

                </tr>
                <tr>
                    <td class="TextoCampos">Sigla:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="sigla" type="text" id="sigla" size="3" maxlength="3" value="<%=(carregacidade ? cadcidade.getSiglaAereo() : "")%>" class="inputtexto">
                        Esse campo é exclusivo para frete aéreo.
                </tr>
                <tr>
                    <td class="TextoCampos">Via:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <input name="via" type="text" id="via" size="3" maxlength="3" value="<%=(carregacidade ? cadcidade.getSiglaViaAereo() : "")%>" class="inputtexto">
                        Esse campo é exclusivo para frete aéreo.
                </tr>
                <tr>
                    <td class="TextoCampos">País:</td>
                    <td colspan="2" class="CelulaZebra2">
                        <strong>
                            <select name="pais" id="pais" class="inputtexto">
                                <option value="0">Nenhum</option>
                                <%BeanConsultaPais p = new BeanConsultaPais();

                                    ResultSet rsPais = p.listarTodos(Apoio.getUsuario(request).getConexao());
                                    while (rsPais.next()) {
                                %>
                                <option value="<%=rsPais.getString("id")%>"><%=rsPais.getString("cod_bacen")%> - <%=rsPais.getString("pais")%></option>
                                <%}%>
                            </select>
                        </strong>
                    </td>
                </tr>
                <%if (areas != null && areas.size() > 0) {%>
                <tr class="celula">
                    <td colspan="3" >Essa cidade faz parte da(s) seguinte(s) área(s)</td>
                </tr>
                <%for (Area areaCid : areas) {%>
                <tr>
                    <td colspan="3" class="CelulaZebra2NoAlign" style="text-align: center">
                        <input name="area" type="text" id="area" class="inputReadOnly" size="40" maxlength="80" readonly="true" value="<%=(carregacidade ? areaCid.getDescricao() : "")%>">
                    </td>
                </tr>
                <%}
                }%>
                <!--  <%if (cfg.getIsFiscal()) {%>
                    <tr class="tabela">
                      <td colspan="3" align="center">Integra&ccedil;&atilde;o com o Fiscal </td>
                    </tr>
                <%}%>  
                <tr>
                  <td colspan="3">
                  <table width="100%" border="0" >
                    <tr>
                      <td width="45%" class="TextoCampos" >C&oacute;digo municipio: </td>
                      <td width="55%" class="CelulaZebra2" ><input name="cod_municipio" type="text" id="cod_municipio" value="<%=(carregacidade ? cadcidade.getCod_municipio() : "")%>" size="10" maxlength="6" class="inputtexto"></td>
                    </tr>
                    <tr>
                      <td class="TextoCampos">C&oacute;digo SRF: </td>
                      <td class="CelulaZebra2"><input name="cod_srf" type="text" id="cod_srf" value="<%=(carregacidade ? cadcidade.getCod_srf() : "")%>" size="10" maxlength="4" class="inputtexto"></td>
                    </tr>
                    <tr>
                      <td class="TextoCampos">C&oacute;digo IBGE: </td>
                      <td class="CelulaZebra2">
                          <input name="cod_ibge" type="text" id="cod_ibge" value="<%=(carregacidade ? cadcidade.getCod_ibge() : "")%>" size="10" maxlength="7" class="inputtexto">
                          &nbsp;&nbsp;&nbsp;<img height="25" src="img/ibge.jpg" border="0" title="Clique aqui para consultar o código IBGE da cidade." align="absbottom" class="imagemLink" onClick="javascript:getIBGE();">
                      </td>
                    </tr>
                    <tr>
                      <td class="TextoCampos">C&oacute;digo sistema MasterFiscal (Mastermaq): </td>
                      <td class="CelulaZebra2"><input name="cod_mastermaq" type="text" id="cod_mastermaq" value="<%=(carregacidade ? cadcidade.getCod_mastermaq() : "")%>" size="10" maxlength="6" class="inputtexto"></td>
                    </tr>
                  </table></td>
                </tr>  -->
                <!--  <tr class="CelulaZebra2">
                    <td colspan="5">
                <% if (nivelUser >= 2) {%>
                      <center>
                    <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                  </center>
                <%}%>
          </td>
        </tr>-->
            </table>
            <br>
            <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tbody>
                    <tr>
                        <td>
                            <table class="tabela" width="80%">
                                <tbody>
                                    <tr>
                                        <%//if (cfg.getIsFiscal()) {%>
                                        <td id="tbIntegra" class="menu-sel" onclick="AlternarAbasGenerico('tbIntegra','tab1')">Integração com o Fiscal</td>
                                        <%//}%> 
                                        <td id="tbConfigEdi" class="menu" onclick="AlternarAbasGenerico('tbConfigEdi','tab2')">Configuração EDI</td>
                                       
                                        <td id="tbInfoOp" class="menu" onclick="AlternarAbasGenerico('tbInfoOp','tab3')">Informações Operacionais</td>
                                        <td style='display: <%= carregacidade && nivelUser == 4 ? "" : "none" %>' id="tbAuditoria" class="menu" onclick="AlternarAbasGenerico('tbAuditoria','tab4')">Auditoria</td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div id="container" align="center" style="width: 100%">
                <div id="tab1" style="">

                    <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tbody id="tbIntegra" name="tbIntegra">
                            <tr>
                                <td colspan="3">
                                    <table width="100%" border="0">
                                        <tr>
                                            <td width="45%" class="TextoCampos" >C&oacute;digo municipio: </td>
                                            <td width="55%" class="CelulaZebra2" ><input name="cod_municipio" type="text" id="cod_municipio" value="<%=(carregacidade ? cadcidade.getCod_municipio() : "")%>" size="10" maxlength="6" class="inputtexto"></td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">C&oacute;digo SRF: </td>
                                            <td class="CelulaZebra2"><input name="cod_srf" type="text" id="cod_srf" value="<%=(carregacidade ? cadcidade.getCod_srf() : "")%>" size="10" maxlength="4" class="inputtexto"></td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">C&oacute;digo IBGE: </td>
                                            <td class="CelulaZebra2">
                                                <input name="cod_ibge" type="text" id="cod_ibge" value="<%=(carregacidade ? cadcidade.getCod_ibge() : "")%>" size="10" maxlength="7" class="inputtexto">
                                                &nbsp;&nbsp;&nbsp;<img height="25" src="img/ibge.jpg" border="0" title="Clique aqui para consultar o código IBGE da cidade." align="absbottom" class="imagemLink" onClick="javascript:getIBGE();">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">C&oacute;digo sistema MasterFiscal (Mastermaq): </td>
                                            <td class="CelulaZebra2"><input name="cod_mastermaq" type="text" id="cod_mastermaq" value="<%=(carregacidade ? cadcidade.getCod_mastermaq() : "")%>" size="10" maxlength="6" class="inputtexto"></td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos"> Código SIAFI: </td>
                                            <td class="CelulaZebra2">
                                                <input name="codSiafi" type="text" id="codSiafi" value="<%=(carregacidade ? cadcidade.getCidadeOb().getCodSiafi() : "")%>" size="10" maxlength="7" class="inputTexto"/>
                                            </td>
                                        </tr>
                                        <tr id="trCodDipam" style="display: none">
                                            <td class="TextoCampos"> 
                                                <label>
                                                    Código DIPAM:                                                     
                                                </label>
                                            </td>
                                            <td class="CelulaZebra2">
                                                <input name="codDipam" type="text" id="codDipam" value="<%=(carregacidade ? cadcidade.getCidadeOb().getCodDipam() : "")%>" size="10" maxlength="4" class="inputTexto"/>                                           </td>                                            
                                        </tr>                                        
                                    </table>
                                </td>
                            </tr> 
                        </tbody>
                    </table>

                </div>
                <div id="tab2" style="display: none;">
                    <table width="40%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tbody id="tbConfigEdi" name="tbConfigEdi">
                            <tr>
                                <td colspan="3">
                                    <table width="100%">
                                        <tr class="celula">
                                            <td> 
                                                <img src="img/add.gif" border="0" title="Adicionar novas cidades" class="imagemLink" style="vertical-align:middle;" onClick="addNovasCidadesEDI()">
                                            </td>
                                            <td> 
                                                <div align="left">Adicionar Cidades</div>
                                            </td>
                                        </tr>
                                        <tr name="trCidades" id="trCidades">
                                            <td colspan="2">
                                                <table width="100%" border="0" class="bordaFina">
                                                    <input type="hidden" name="maxCidade" id="maxCidade" value="0">                                                    
                                                    <tbody id="tbCidades" name="tbCidades">
                                                        <tr class="CelulaZebra1">
                                                            <td width="14%"></td>
                                                            <td align="center">Cidade</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                   
                    <div id="tab3" style="display: none;">
                    <table width="40%" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                        <tbody id="tbInfoOp" name="tbInfoOp">
                            <tr>
                                <td colspan="3">
                                    <table width="100%">
                                        <tr>
                                            <td class="TextoCampos"> 
                                                Qtd. de Horas para baixar o Comprovante de entrega:
                                            </td>
                                            <td class="celulaZebra2"> 
                                                <input type="text" id="qtdHoras" size="7" name="qtdHoras" onkeypress="mascara(this, soNumeros);" value="<%=(carregacidade ? cadcidade.getQtdHorasBaixarComprovanteEntrega() : 0)%>" class="inputTexto">
                                            </td>
                                        </tr>
                                        <table width="100%">
                                        <tr>
                                            <td class="TextoCampos">
                                                <input type="checkbox"  name="isUrbana" id="isUrbana"  style="margin-left:35px;" onclick=" trocar()" />
                                            </td>
                                            <td class="CelulaZebra2" width="100%">
                                                Área Urbana (Averbação de Carga)
                                            </td>
                                        </tr>
                                        </table>
                                               </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>                     
                 <div id="tab4" >

            <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display: <%=carregacidade && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="/gwTrans/template_auditoria.jsp" %>

            </table>
        </div>                        
                                        
            </div>
            <br>
              <% if (nivelUser >= 2) {%>
            <table width="40%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tbody>
                    
                    <tr class="CelulaZebra2">
                        <td colspan="5">
                          
                <center>
                    <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                </center>
               
                </td>
                </tr>
                </tbody>
            </table>
               <%}%> 
        </form>
    </body>
</html>        