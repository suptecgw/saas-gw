<%@ page contentType="text/html; charset=iso-8859-1" language="java"
   import="nucleo.BeanAlteraAliq,
           nucleo.*,
           java.util.Vector" errorPage="" %>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("altaliquota") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);
   //fim da MSA
%>
<%String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  BeanAlteraAliq beanaliquota = null;

  if (acao.equals("editar") || acao.equals("atualizar") || acao.equals("mostrar"))
  {     //instanciando o bean de cadastro
        beanaliquota = new BeanAlteraAliq();
        beanaliquota.setConexao(Apoio.getUsuario(request).getConexao());
        beanaliquota.setExecutor(Apoio.getUsuario(request));
        beanaliquota.LoadAllPropertys((acao.equals("mostrar")?Integer.parseInt(request.getParameter("idfilial")):Apoio.getUsuario(request).getFilial().getIdfilial()));
  }

  if ((nivelUser >= 2) && (acao.equals("atualizar")))
  {
	  Vector VUF = new Vector();
      //populando o JavaBean
      int qtd = request.getParameter("dados").split("@@").length;
      for (int k = 0; k < qtd; ++k)
      {
        UfIcms UI = new UfIcms();
        UI.getFilial().setIdfilial(Integer.parseInt(request.getParameter("idfilial")));
        UI.setUf(request.getParameter("dados").split("@@")[k].split("!@")[0]);
        UI.setAliq(Float.parseFloat(request.getParameter("dados").split("@@")[k].split("!@")[1]));
        UI.setAliqCpf(Double.parseDouble(request.getParameter("dados").split("@@")[k].split("!@")[3]));
        UI.getObs().setId(Integer.parseInt(request.getParameter("dados").split("@@")[k].split("!@")[2]));
        UI.setReducaoBaseIcms(Double.parseDouble(request.getParameter("dados").split("@@")[k].split("!@")[4]));
        UI.setAliquotaAereo(Double.parseDouble(request.getParameter("dados").split("@@")[k].split("!@")[5]));
        UI.setAliquotaAereoCpf(Double.parseDouble(request.getParameter("dados").split("@@")[k].split("!@")[6]));
        UI.getCidade().setIdcidade(Integer.parseInt(request.getParameter("dados").split("@@")[k].split("!@")[7]));
        VUF.add(UI);
      }
      beanaliquota.setAltAliq(VUF);
      
      boolean erro = !beanaliquota.Atualiza(Integer.parseInt(request.getParameter("idfilial")));

      //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
      %><script language="javascript" type=""><%
            if (erro)
            {
                %>alert('<%=(beanaliquota.getErros())%>');
           <%}%>
            window.close();
       </script>

 <%}%>


<script language="javascript" type="">
  function voltar(){
     document.location.replace("./menu");
  }

  function localizafilial(){
      post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','Filial',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }

  function salva(){
     if (!false/*wasNull('desc')*/)
     {
         document.getElementById("salvar").disabled = true;
         document.getElementById("salvar").value = "Enviando...";

         var i = 0;
         var url = "./alteraaliquota?acao=atualizar&idfilial="+document.getElementById("idfilial").value + "&dados=";
         while (document.getElementById("uf_"+i) != null)
         {
            url += document.getElementById("uf_"+i).value+"!@"+document.getElementById("aliq_"+i).value+"!@"+document.getElementById("idobs_"+i).value+"!@"+document.getElementById("aliq_cpf_"+i).value+"!@"+document.getElementById("reducao_"+i).value+"!@"+document.getElementById("aliqAereo_"+i).value+"!@"+document.getElementById("aliqAereoCpf_"+i).value+"!@"+document.getElementById("idCid_"+i).value+"@@";
            ++i;
         }
         document.location.replace(url);
     }else
	   alert("Preencha os campos corretamente!");
  }

  function mostrar(){
    var url = "./alteraaliquota?acao=mostrar&idfilial="+document.getElementById("idfilial").value+
	   	      "&filial="+document.getElementById("fi_abreviatura").value;
    document.location.replace(url);
  }

  function localizaobs(obj,linha){
    document.getElementById("linha").value = linha;
    post_cad = window.open('./localiza?acao=consultar&idlista=28','Observacao',
                        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
  }

  function aoClicarNoLocaliza(idjanela)
  {          
    if ((idjanela == "Observacao"))
    {
      var campo = "descobs_"+document.getElementById("linha").value;
      var campo2 = "idobs_"+document.getElementById("linha").value;
      getObj(campo).value = getObj("obs_desc").value
      getObj(campo2).value = getObj("id").value
    }else if (idjanela == "Filial"){
        tryRequestToServer(function(){mostrar();});
    }
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

<title>WebTrans - Alíquotas ICMS</title>
<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>

<body>
    <img src="img/banner.gif">
    <br>
    <input type="hidden" name="idfilial" id="idfilial" value="<%=(acao.equals("editar")?Apoio.getUsuario(request).getFilial().getIdfilial() : Integer.parseInt(request.getParameter("idfilial")))%>">
    <input type="hidden" name="obs_desc" id="obs_desc" value="0">
    <input type="hidden" name="id" id="id" value="0">
    <input type="hidden" name="linha" id="linha" value="">
    <table width="90%" align="center" class="bordaFina" >
        <tr>
            <td width="613">
                <div align="left">
                    <b>Al&iacute;quotas de ICMS por estado </b>
                </div>
            </td>
        </tr>
    </table>
    <br>
    <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr class="tabela"> 
            <td colspan="2">
                <div align="center">Filial selecionada</div>
            </td>
        </tr>
        <tr class="CelulaZebra2"> 
            <td width="258"> 
                <div align="center">
                    <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="<%=(acao.equals("editar")?Apoio.getUsuario(request).getFilial().getAbreviatura():request.getParameter("filial"))%>" size="35" readonly>
                    <input  name="localiza_filial" type="button" class="botoes" id="localiza_filial" onClick="javascript:localizafilial();" value="...">
                </div>
            </td>
            <td width="229">
                <div align="center">
                    <input name="mostrar" type="button" class="botoes" id="mostrar" value="Mostrar" onClick="javascript:tryRequestToServer(function(){mostrar();});">
                </div>
            </td>
        </tr>
    </table>
    <br>
    <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr>
            <td class="tabela">&nbsp;</td>
            <td colspan="3" class="tabela">Frete Rodovi&aacute;rio, Mar&iacute;timo, Fluvial</td>
            <td colspan="2" class="tabela">Frete A&eacute;reo</td>
            <td class="tabela">&nbsp;</td>
        </tr>
        <tr>
            <td width="12%" class="tabela">UF</td>
            <td width="10%" class="tabela">Al&iacute;q. c/ IE</td>
            <td width="10%" class="tabela">Al&iacute;q. s/ IE</td>
            <td width="10%" class="tabela">Redu&ccedil;&atilde;o ICMS</td>
            <td width="10%" class="tabela">Al&iacute;q. c/ IE</td>
            <td width="10%" class="tabela">Al&iacute;q s/ IE</td>
            <td width="38%" class="tabela">Observa&ccedil;&atilde;o para lan&ccedil;amentos</td>
        </tr>
        <tr>
            <td colspan="7">
                <% if (acao.equals("editar") || acao.equals("mostrar")){
                    int i = 0;
                    //Percorrendo o vetor
                    for (i = 0; i <= beanaliquota.getAltAliq().size() - 1; ++i){
                 %>
                        <tr class="<%=((i % 2) == 0 ? "CelulaZebra2" : "CelulaZebra1")%>">
                            <td>
                                <%=((UfIcms) beanaliquota.getAltAliq().get(i)).getUf()%>:&nbsp;&nbsp;
                                <%if (((UfIcms) beanaliquota.getAltAliq().get(i)).getCidade().getIdcidade() != 0){%>
                                    <br>
                                    <%=((UfIcms) beanaliquota.getAltAliq().get(i)).getCidade().getDescricaoCidade()%>
                                <%}%>
                                <input type="hidden" name="idCid_<%=i%>" id="idCid_<%=i%>" value="<%=(((UfIcms) beanaliquota.getAltAliq().get(i)).getCidade().getIdcidade()==0?0:((UfIcms) beanaliquota.getAltAliq().get(i)).getCidade().getIdcidade())%>"/>
                                <input type="hidden" name="uf_<%=i%>" id="uf_<%=i%>" value="<%=(((UfIcms) beanaliquota.getAltAliq().get(i)).getUf())%>" maxlength="8" size="8"/>
                            </td>
                            <td>
                                <input type="text" class="fieldMin" name="aliq_<%=i%>" id="aliq_<%=i%>" value="<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getAliq()%>" onChange="seNaoFloatReset(this,'0.00')" maxlength="8" size="6"/>
                                %
                            </td>
                            <td>
                                <input type="text" class="fieldMin" name="aliq_cpf_<%=i%>" id="aliq_cpf_<%=i%>" value="<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getAliqCpf()%>" onChange="seNaoFloatReset(this,'0.00')" maxlength="8" size="6"/>
                                %
                            </td>
                            <td>
                                <input type="text" class="fieldMin" name="reducao_<%=i%>" id="reducao_<%=i%>" value="<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getReducaoBaseIcms()%>" onChange="seNaoFloatReset(this,'0.00')" maxlength="8" size="6"/>
                                %
                            </td>
                            <td>
                                <input type="text" class="fieldMin" name="aliqAereo_<%=i%>" id="aliqAereo_<%=i%>" value="<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getAliquotaAereo()%>" onChange="seNaoFloatReset(this,'0.00')" maxlength="8" size="6"/>
                                %
                            </td>
                            <td>
                                <input type="text" class="fieldMin" name="aliqAereoCpf_<%=i%>" id="aliqAereoCpf_<%=i%>" value="<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getAliquotaAereoCpf()%>" onChange="seNaoFloatReset(this,'0.00')" maxlength="8" size="6"/>
                                %
                            </td>
                            <td> 
                                <div align="left">
                                    <input type="hidden" style="font-size:8pt;" name="idobs_<%=i%>" id="idobs_<%=i%>" value="<%=(((UfIcms) beanaliquota.getAltAliq().get(i)).getObs().getId()==0?0:((UfIcms) beanaliquota.getAltAliq().get(i)).getObs().getId())%>" maxlength="8" size="8"/>
                                    <input name="descobs_<%=i%>" type="text" id="descobs_<%=i%>" value="<%=(((UfIcms) beanaliquota.getAltAliq().get(i)).getObs().getDescricao()==null?"":((UfIcms) beanaliquota.getAltAliq().get(i)).getObs().getDescricao())%>" size="45" maxlength="300" class="inputReadOnly8pt" readonly="true">
                                    <input name="pesobs_<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getUf()%>" type="button" class="botoes" id="pesobs_<%=((UfIcms) beanaliquota.getAltAliq().get(i)).getUf()%>" onClick="javascript:localizaobs(this,<%=i%>);" value="...">
                                    <img src="img/borracha.gif" align="absbottom" class="imagemLink" title="Limpar Observa&ccedil;&atilde;o" onClick="$('descobs_<%=i%>').value='';$('idobs_<%=i%>').value='0';">
                                </div>
                            </td> 
                        </tr>
                 <%
                    }
                }
                 %>

                <%if (nivelUser >= 2) {%>
                    <tr class="CelulaZebra2">
                        <td colspan="7">
                            <center>
                                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva();});">
                            </center>
                        </td>
                    </tr>
                <%}%>
           </td>
        </tr>
    </table>
   <br>

