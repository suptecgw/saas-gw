<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="java.sql.ResultSet,
           java.util.Arrays,
		   venda.BeanConsultaAgencia,
           permissao.BeanPermissao,
           nucleo.Apoio,
           usuario.BeanCadUsuario,
           usuario.grupo.BeanConsultaGrupo,
           filial.BeanConsultaFilial" errorPage="" %>

<% //Versao da MSA: 2.0 ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadusuario") : 0);
   boolean souadm = Apoio.getUsuario(request).getAcesso("cadusuario") == 4;
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(response.SC_FORBIDDEN);
   //fim da MSA
%>

<%
  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  boolean carregaUser = false;
  BeanPermissao  perm  = null;
  BeanCadUsuario cadusu = null;
  BeanConsultaFilial listafilial = null;
  BeanConsultaGrupo conGru = null;

  //instrucoes incomuns entre as acoes
  if ((nivelUser > 0) && (acao.equals("editar") || acao.equals("carregapermissao") || acao.equals("iniciar")))
  {
       perm = new BeanPermissao();
       perm.setConexao(Apoio.getUsuario(request).getConexao());

       //se for um administrador, vai ser carregado as filiais cadastradas
       if (souadm)
       {
          listafilial = new BeanConsultaFilial();
          listafilial.setConexao(Apoio.getUsuario(request).getConexao());
          listafilial.setCampoDeConsulta("uf");
          listafilial.setLimiteResultados(100);
          listafilial.setOperador(listafilial.TODAS_AS_PARTES);
          listafilial.setValorDaConsulta("");
          if (!listafilial.Consultar())
          {%>
            <script type="javascript">
              alert("Erro ao tentar carregar as filiais cadastradas!");
              window.close();
            </script>
          <%}
       }//souadm
  }

  //executando a acao desejada
  if ((acao.equals("editar")) && (request.getParameter("id") != null))
  {
	 //instanciando o bean de cadastro
     cadusu = new BeanCadUsuario();
     cadusu.setConexao(Apoio.getUsuario(request).getConexao());

     int idusuario = Integer.parseInt(request.getParameter("id"));
     cadusu.setIdusuario(idusuario);
     //protecao contra usuario malicioso
     if (!souadm)
         cadusu.setRestricaoidfilial(Apoio.getUsuario(request).getFilial().getIdfilial());
     //carregando o usuario por completo(atributos, permissoes)
     cadusu.LoadAllPropertys();
  }

if (acao.equals("carregaGrupo")){
	conGru = new BeanConsultaGrupo();
	conGru.setConexao(Apoio.getUsuario(request).getConexao());
	if (conGru.CarregaPermissao(Integer.parseInt(request.getParameter("idGrupo")))){
		ResultSet rs = conGru.getResultado();
		int row = 0;
		String resultado = "";
		while (rs.next()){
			resultado += (resultado.equals("") ? "" : "-!") + rs.getString("permissao_id")+ ","+rs.getString("nivel");
			row++;
		}
		rs.close();
		response.getWriter().append(resultado); 
	}else{
		response.getWriter().append("load=0"); 
	}
	response.getWriter().close();
}
  
   //variavel usada para saber se o usuario esta editando o cadastro
   carregaUser = ((cadusu != null) && (cadusu.getIdpermissoes() != null)
                && (!acao.equals("incluir") || !acao.equals("atualizar")));
 %>

 <script language="javascript" type="text/javascript">
  function check() {
    var i = 1;
    if (!wasNull('idfi,nom,lo,sh,senha2') &&
       (document.getElementById("senha2").value == document.getElementById("sh").value) )
    {
       while (document.getElementById("cb"+i) != null)
       {
           if (document.getElementById("cb"+i).value != "0")
              return true;
           i++;
       }
       return false;
    }else
      return false;
  }

  function voltar(){
     document.location.replace("./consultausuario?acao=iniciar");
  }

  function envia(acao, qtde_permissoes){
     if (check()) {
		  document.getElementById("salvar").disabled = true;
		  document.getElementById("salvar").value = "Enviando...";

		  var idps = "";
		  var idni = "";

    	  if (acao == "atualizar")
  		    acao += "&id=<%=( carregaUser ? cadusu.getIdusuario() : 0)%>";
		  post_cad = window.open('./pops/post_cadusuario.jsp?acao=ini&acao2='+acao,'',
                     'height=150,width=220,resizable=yes,status=1');
	}else
	   alert("Preencha os campos corretamente!");
  }

  function excluirusuario(idusuario){
       if (confirm("Deseja mesmo excluir este usuário?"))
	   {
	       location.replace("./consultausuario?acao=excluir&id="+idusuario);
	   }
  }

  function carregapermissao(idfilial)
  {
          document.getElementById("salvar").disabled = true;
          document.getElementById("salvar").value = "Enviando...";
          location.replace("./cadusuario?acao=carregapermissao&id="+idfilial);
  }

function carregaGrupo(id){

	function e(transport){
		var textoresposta = transport.responseText;
		//se deu algum erro na requisicao...
		if (textoresposta == "load=0") {
			return false;
		}else{
			//Limpando permissoes
			var i = 1;
			while ($("cb"+i) != null){
				$("cb"+i).value = "0";
				i++;
			}
			//Carregando as permissoes do grupo de usuário
			var permissao = '';
			var combo = '';
			for(x=0; x < textoresposta.split('-!').length; x++){
				permissao = textoresposta.split('-!')[x];
                combo = 'cb'+$(permissao.split(',')[0]).value;
				$(combo).value = permissao.split(',')[0]+","+permissao.split(',')[1];
			}
		}
	}//funcao e()
     
	new Ajax.Request("./cadusuario?acao=carregaGrupo&idGrupo="+id,{method:'post', onSuccess: e, onError: e});
}

  function atribuicombo(){
    <%if (acao.equals("carregapermissao")  && request.getParameter("id") != null)
    {%>
          document.getElementById("idfi").value = "<%=request.getParameter("id")%>";
  <%}%>
  }

  function onChangeIdFi(id){
  if(id != '0') 
     tryRequestToServer(function(){carregapermissao(id);});
  }
</script>
<html>
<head>
<script language="javascript" src="script/funcoes.js" type=""></script>
<script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="content-language" content="pt">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="pragma" content="no-store">
<meta http-equiv="expires" content="0">
<meta name="language" content="pt-br">

<title>WebTrans - Cadastro</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body onLoad="javascript:atribuicombo();">
<img src="img/banner.gif" >
<br>
<table width="700" align="center" class="bordaFina" >
  <tr >
    <td width="613"><div align="left"><b>Cadastro de usu&aacute;rio </b></div></td>
      <%if ((acao.equals("editar")) && (nivelUser >= 4)) //se o paramentro vier com valor entao nao pode excluir
	{%>
	   <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:tryRequestToServer(function(){excluirusuario(<%=(carregaUser ? cadusu.getIdusuario() : 0)%>);});"></td>
       <%}%>
    <td width="56" ><input  name="voltar" type="button" class="botoes" id="voltar" onClick="javascript:voltar();" value="Consulta"></td>
  </tr>
</table>
<br>
<table width="748" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
  <tr class="tabela">
    <td  colspan="9" align="center">Dados principais</td>
  </tr>
    <tr>
      <td width="69" class="TextoCampos">Filial:</td>
      <td colspan="3" class="CelulaZebra2">
        <%if ((souadm) && !(carregaUser) && (listafilial != null))
        {%>
          <select id="idfi" name="idfi" onChange="javascript:onChangeIdFi(this.value)" class="inputtexto">
            <%=(!listafilial.getResultado().wasNull() && !acao.equals("carregapermissao")
                ?"<option value=\"0\">-- Selecione a filial --</option>":"")%>
            <%while (listafilial.getResultado().next())
            {
                 int idfi = listafilial.getResultado().getInt("idfilial");
                 String desc =  listafilial.getResultado().getString("abreviatura");%>
                 <option value="<%=idfi%>">
                <%=desc%></option>
            <%}%>
          </select>
          <%}else{%>
            <b><%=(carregaUser?cadusu.getFilial():Apoio.getUsuario(request).getFilial().getAbreviatura())%></b>
          <%}%>
      </td>
      <td width="70"  class="TextoCampos">Ag&ecirc;ncia:</td>
      <td width="294"  class="CelulaZebra2"><select id="agencia" name="agencia" class="inputtexto">
        <option value="0"></option>
        <%if (acao.equals("carregapermissao") || carregaUser){
        	BeanConsultaAgencia ag = new BeanConsultaAgencia();
            ag.setConexao(Apoio.getUsuario(request).getConexao());
            ag.MostrarAgencias((carregaUser?String.valueOf(cadusu.getIdfilial()):request.getParameter("id")));
            while (ag.getResultado().next()){%>
                <option value="<%=ag.getResultado().getString("id")%>" <%=(carregaUser && cadusu.getAgencia().getId()==ag.getResultado().getInt("id")?"selected":"")%>><%=ag.getResultado().getString("abreviatura")%></option>
            <%}
            }%>
      </select></td>
    </tr>
    <tr>
      <td class="TextoCampos">Nome:</td>
      <td colspan="3" class="CelulaZebra2"><input name="nom" type="text" id="nom" value="<%=(carregaUser?cadusu.getNome():"")%>" size="45" maxlength="30" class="inputtexto"></td>
      <td class="TextoCampos">E-mail : </td>
      <td class="CelulaZebra2"><input name="ema" type="text" id="ema" value="<%=(carregaUser?cadusu.getEmail():"")%>" size="45" maxlength="70" class="inputtexto"></td>
    </tr>
    <tr>
      <td class="TextoCampos">Login:</td>
      <td width="136"  class="CelulaZebra2"><input name="lo" type="text" id="lo" value="<%=(carregaUser?cadusu.getLogin():"")%>" size="15" maxlength="30" class="inputtexto"></td>
      <td width="47"  class="TextoCampos">Senha:</td>
      <td width="99"  class="CelulaZebra2"><input name="sh" type="password" id="sh" value="<%=(carregaUser?cadusu.getSenha():"")%>" size="15" maxlength="13" class="inputtexto"></td>
      <td  class="TextoCampos">Repetir:</td>
      <td  class="CelulaZebra2"><input name="senha2" type="password" id="senha2" value="<%=(carregaUser?cadusu.getSenha():"")%>" size="15" maxlength="13" class="inputtexto"></td>
    </tr>
    <tr>
      <td  class="TextoCampos">Grupo:</td>
      <td width="136"  class="CelulaZebra2"><select id="grupo" name="grupo" onChange="javascript:carregaGrupo(this.value);" class="inputtexto">
        <option value="0">Selecione o grupo</option>
        <%if (acao.equals("carregapermissao") || carregaUser){
        	BeanConsultaGrupo gr = new BeanConsultaGrupo();
            gr.setConexao(Apoio.getUsuario(request).getConexao());
            gr.MostrarGrupos(carregaUser && !souadm ?cadusu.getIdfilial():0);
            while (gr.getResultado().next()){%>
        		<option value="<%=gr.getResultado().getString("id")%>" <%=(carregaUser && cadusu.getGrupo().getId()==gr.getResultado().getInt("id")?"selected":"")%>><%=gr.getResultado().getString("descricao")%></option>
        	<%}
			gr.getResultado().close();
        }%>
      </select></td>
      <td class="TextoCampos" colspan="2">Emitir apenas CTRC: </td>
      <td class="CelulaZebra2" colspan="2"> <div align="center">
         <label id="lbRodoviario" ><input name="rod" type="checkbox" id="rod" <%=(carregaUser ? (cadusu.isEmiteRodoviario() ? "checked" :"") : "" )%> />
              Rodovi&aacute;rio &nbsp; </label>
         <label id="lbAereo">     <input name="aer" type="checkbox" id="aer"  <%=(carregaUser ? (cadusu.isEmiteAereo() ? "checked" :"") : "" )%> />
               A&eacute;reo &nbsp; </label>
         <label id="lbAquaviario">  <input name="aqu" type="checkbox" id="aqu"  <%=(carregaUser ? (cadusu.isEmiteAquaviario() ? "checked" :"") : "" )%> />
             Aquaviário </label>
          </div>
      </td>
      
    </tr>
	<tr>
	  <td class="tabela" colspan="6" align="center">Hierarquia de acesso</td>
	</tr>
  <TD height="23" colspan="8">
   <table width="100%" border="1" align="center" cellpadding="1" cellspacing="1">
      <!-- INICIO -->
      <%
      //contador de permissoes
      int i = 0;

      //se estiver editando entao carregue as permissoes do cadastro.
      //senao carregue o da filial do usuario logado OU se ADM carregue a escolhida
      int idfilial = 0;
      if ( (souadm)&&(acao.equals("carregapermissao"))&&(request.getParameter("id")!=null) )
           idfilial = Integer.parseInt(request.getParameter("id"));
      else
          idfilial = (carregaUser
                      ?cadusu.getIdfilial() : Apoio.getUsuario(request).getFilial().getIdfilial());

      //se for um adm e estiver apenas iniciando um cadastro...
      idfilial = (souadm && acao.equals("iniciar") ? 0 : idfilial);
      //se é p/ carregar as perrmissoes(o id da filial estiver alimentado)
      if ( (idfilial > 0) && (perm.Consultar(perm.PEMISSOES_DA_FILIAL, idfilial)) )
      {    //declarando essa variavel  por conveniencia de codigo
			ResultSet rs = perm.getResultSet();
			String categ = "";
			boolean fimRs = false;
			//agora ele vai listar as permissoes e testar se o usuario tem aquela permissao
			fimRs = !rs.next();
			while (!fimRs){
				int nivel = 0;
				if (carregaUser){
					//procurando no array de idpermissoes se o usuarrio tem aquela permissao
					//se tiver ele retorna o nivel da permissao
					int posicao_nivel = Apoio.pesquisaArray(cadusu.getIdpermissoes(), rs.getString("idpermissao"));
					nivel = (posicao_nivel >= 0 ? Integer.parseInt(cadusu.getNiveis()[posicao_nivel]) : 0);
				}
				i++;
                if (!categ.equals(rs.getString("categoria"))){
					categ = rs.getString("categoria");
                    if (categ.equals("0ca")){%>
						<tr class="celula"><td colspan="5"><b>Cadastros</b></td></tr>
                    <%}else if(categ.equals("1la")){%>
						<tr class="celula"><td colspan="5"><b>Lançamentos</b></td></tr>
                    <%}else if(categ.equals("2pr")){%>
						<tr class="celula"><td colspan="5"><b>Processos</b></td></tr>
                    <%}else if(categ.equals("3re")){%>
						<tr class="celula"><td colspan="5"><b>Relatórios</b></td></tr>
                    <%}else if(categ.equals("4co")){%>
						<tr class="celula"><td colspan="5"><b>Configurações</b></td></tr>
                    <%}else if(categ.equals("5ou")){%>
						<tr class="celula"><td colspan="5"><b>Outras permissões</b></td></tr>
                    <%}
				}%>
				<tr>
					<td colspan="2" class="TextoCampos"><%=rs.getString("descricao")%>:</td>
					<td  class="CelulaZebra2">
						<input type="hidden" id="<%=rs.getString("idpermissao")%>" name="id=<%=rs.getString("idpermissao")%>" value="<%=i%>">
						<select name="cb<%=i%>" id="cb<%=i%>" class="inputtexto">
						    <%if (rs.getString("tipo").equals("NV")){%>
								<option <%=(nivel==0?"selected":"")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                        		<option <%=(nivel==1?"selected":"")%> value="<%=rs.getString("idpermissao")%>,1" style="background-color:#E5E5E5">Ler</option>
                        		<option <%=(nivel==2?"selected":"")%> value="<%=rs.getString("idpermissao")%>,2" style="background-color:#CDCDCD">Ler, altera</option>
                        		<option <%=(nivel==3?"selected":"")%> value="<%=rs.getString("idpermissao")%>,3" style="background-color:#A7A7A7">Ler, altera, inclui</option>
                        		<option <%=(nivel==4?"selected":"")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Controle total</option>
                        	<%}else{%>	
								<option <%=(nivel<=0?"selected":"")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                        		<option <%=(nivel==4?"selected":"")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Com acesso</option>
                        	<%} %>	
						</select>
					</td>
                    <% //chamando outro next() para a segunda coluna de permissoes
					if (rs.next()){
						if (!categ.equals(rs.getString("categoria"))){%>
          					<td colspan="2" width="50%" class="CelulaZebra2">&nbsp;</td>
						<%}else{
							if (carregaUser){
								int posicao_nivel = Apoio.pesquisaArray(cadusu.getIdpermissoes(), rs.getString("idpermissao"));
								nivel = (posicao_nivel >= 0 ? Integer.parseInt(cadusu.getNiveis()[posicao_nivel]) : 0);
							}
							i++; %>
							<td class="TextoCampos"><%=rs.getString("descricao")%>:</td>
							<td class="CelulaZebra2">
								<input type="hidden" id="<%=rs.getString("idpermissao")%>" name="id=<%=rs.getString("idpermissao")%>" value="<%=i%>">
								<select name="cb<%=i%>" id="cb<%=i%>" class="inputtexto">
								    <%if (rs.getString("tipo").equals("NV")){%>
										<option <%=(nivel==0?"selected":"")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
										<option <%=(nivel==1?"selected":"")%> value="<%=rs.getString("idpermissao")%>,1" style="background-color:#E5E5E5">Ler</option>
										<option <%=(nivel==2?"selected":"")%> value="<%=rs.getString("idpermissao")%>,2" style="background-color:#CDCDCD">Ler, altera</option>
										<option <%=(nivel==3?"selected":"")%> value="<%=rs.getString("idpermissao")%>,3" style="background-color:#A7A7A7">Ler, altera, inclui</option>
										<option <%=(nivel==4?"selected":"")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Controle total</option>
		                        	<%}else{%>	
										<option <%=(nivel<=0?"selected":"")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                		        		<option <%=(nivel==4?"selected":"")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Com acesso</option>
                        			<%} %>	
        	                    </select>
							</td>
    	      				<%fimRs = !rs.next();
						}
					}else{
			            fimRs = true;%>
						<td colspan="2" class="CelulaZebra2">&nbsp;</td>
					<%}//if-else%>
				</tr>
			<%}//while%>
		<%}else{%>
			<div align="center" style=" text-align:center; color:#804000; font-size: 12px ">(Selecione uma Filial para carregar as permissões)</div>
		<%}%>
      <!-- FIM -->
    </table>
	</TD>
  <% if (nivelUser >= 2)
  {%>
  <tr class="CelulaZebra2">
    <td colspan="12">
      <center>
        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" style="width:88 "
          onClick="javascript:tryRequestToServer(function(){envia('<%=(acao.equals("iniciar")||acao.equals("carregapermissao")  ? "incluir":"atualizar")%>',<%=i%>);});">
      </center></td>
  </tr>
  <%}%>
</table>

<br> 

