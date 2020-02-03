<%@page import="planocusto.BeanPlanoCusto"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
               import="java.text.DecimalFormat,
                       java.text.DecimalFormatSymbols,
                       java.util.Locale,
                       nucleo.Apoio,
                       java.util.Vector,
                       java.text.SimpleDateFormat,
                       conhecimento.duplicata.BeanDuplicata,
                       conhecimento.apropriacao.BeanApropriacao,
                       conhecimento.BeanCadConhecimento" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script language="javascript" src="script/<%=Apoio.noCacheScript("jquery.js")%>" type=""></script>
<% int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
   int nivelUserImpresso = (Apoio.getUsuario(request) != null
        ? Apoio.getUsuario(request).getAcesso("altconhimpresso") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       getServletContext().getRequestDispatcher("/menu").forward(request, response);
   //fim da MSA
   //Pega o plano de custo padrão de configuracao.
   BeanConfiguracao cfg = Apoio.getConfiguracao(request);
   BeanPlanoCusto plcustopadrao = cfg.getPlanoDefault();
%>

<%
  String acao_conhecimento = (request.getParameter("acao_conhecimento") == null ? "" : request.getParameter("acao_conhecimento") );
  String acao   = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  acao = (acao_conhecimento.equals("editar") && request.getParameter("id") != null ? "editar" : acao);      
  
  String nfiscal = (request.getParameter("notafiscal") == null ? "" : request.getParameter("notafiscal") );
  SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
  
  //se a parcela for nula entaum vai ser default 1
  int qtd_parcela = Integer.parseInt((request.getParameter("qtd_parcela") == null ? "1" : request.getParameter("qtd_parcela") ));

   //instanciando um formatador de simbolos
  DecimalFormatSymbols dfs = new DecimalFormatSymbols(new Locale("pt","BR"));
  dfs.setDecimalSeparator('.');
  DecimalFormat vlrformat  = new DecimalFormat("0.00", dfs);
  vlrformat.setDecimalSeparatorAlwaysShown(true);
  
  float total = Float.parseFloat((request.getParameter("total") == null ? "0" : request.getParameter("total") ));
  //campo chaveador
  boolean recria_dup = (request.getParameter("recria_dup") != null ? 
                       request.getParameter("recria_dup").equals("true") : true);
  
  //se a acao for "editar"
  Object[] dups = null;
  Object[] aprops = null;
  boolean duplicata_baixada = false;
  //ids das duplicatas baixadas(vai ser usado para desabilitar 
  //a edicao de dups. que foram baixadas)
  String ids_baixadas = ((request.getParameter("dups_baixadas") == null) || (request.getParameter("dups_baixadas").equals("")) ? 
                         "" : request.getParameter("dups_baixadas"));
  BeanCadConhecimento cadct = new BeanCadConhecimento();
  if (acao.equals("editar") && request.getParameter("id") != null)
  {
      cadct.setConexao(Apoio.getUsuario(request).getConexao());
      cadct.getConhecimento().setId(Integer.parseInt(request.getParameter("id")));
      //carregando todas as parcelas do conhecimento
      if (cadct.loadAllParcel())
      {
          dups =  cadct.getConhecimento().getDuplicatas().toArray();
          qtd_parcela = dups.length;
      } 
      //carregando todas as apropriacoes do conhecimento
      if (cadct.loadAllAppropriation())
          aprops = cadct.getConhecimento().getApropriacoes().toArray();
      cadct.LoadAllPropertys();
  }
  
  //variavel usada p/ saber se o usuaio esta editando uma dup existente
  boolean carregadup = ((dups != null) && (dups.length > 0));
%>

<script language="javascript">
  var nao_recarregar = false;
 
  function criarDuplicatas()
  {
     document.getElementById("recria_dup").value = "true";
     refazer();  
  }

<%-- Refaz as duplicatas(se o campo recria_dup == false) e as apropriacoes --%>      
function refazer(){ 
    //parametro opcional
    var idaprop_exclui = (arguments[0] != null ? arguments[0] : "0");
    //pegando os valores sem formatação de casas decimais para não influenciar no resultado final quando cria mais de uma parcela - historia 3339 
    var basecalculo = parent.frames[0].$("base_calculo").value;
    var aliqfrete = parent.frames[0].$("aliquota").value;
    var txICMS = parseFloat((basecalculo * aliqfrete)/100);
    document.formeditor.action = "./editor_parcela?acao=refazer"+(idaprop_exclui != "0" ? "&idaprop_exclui="+idaprop_exclui : "")+"&idUnd_custo="+"&acao_conhecimento=<%=acao_conhecimento%>";
    <%-- pegando o valor do frame principal e alimentando o campo oculto "notafiscal" --%>
    document.getElementById("notafiscal").value = parent.frames[0].document.getElementById("nfiscal").value;
    var totalCtrc = parent.frames[0].document.getElementById("total").value;
    var valorIcms = txICMS;
    var stIcms = parent.frames[0].document.getElementById("stIcms").value;
            if(parseFloat(parent.frames[0].document.getElementById("st_credito_presumido").value)>0 && stIcms == "9"){
                var percentual = parseFloat(parent.frames[0].document.getElementById("st_credito_presumido").value)/100;
                valorIcms = (valorIcms*percentual);
            }
    document.getElementById("total").value = formatoMoeda(stIcms != 9 ? totalCtrc : parseFloat(totalCtrc) - parseFloat(valorIcms));
    document.formeditor.submit();
}

function localizarplanocusto(){
   if (nao_recarregar){
   	alert('Já existe duplicatas baixadas ou faturadas, inclusão do plano de custo não é permitida.');
   }else{
    var post_cad = window.open('./localiza?acao=consultar&idlista=<%=nucleo.BeanLocaliza.PLANO_CUSTO_RECEITA%>','Plano_Custo',
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
   }                  
}
 
function localizarUndCusto(index){
   if (nao_recarregar){
   	alert('Já existe duplicatas baixadas ou faturadas, inclusão da unidade de custo não é permitida.');
   }else{	
        var post_cad = window.open('./localiza?acao=consultar&idlista=<%=nucleo.BeanLocaliza.UNIDADE_CUSTO%>','Unidade_Custo_'+index,
                     'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
   }	
}    

//esse metodo eh uma espécie de "evento" do localiza
function aoClicarNoLocaliza(idjanela){
   var jan = (idjanela == null ? "" : idjanela);
   if (jan.substring(0,13) == "Unidade_Custo"){
     document.getElementById('idUnd_custo'+jan.substring(14,15)).value = document.getElementById('id_und').value;
     document.getElementById('und_custo'+jan.substring(14,15)).innerHTML = document.getElementById('sigla_und').value;
     document.getElementById('sigla'+jan.substring(14,15)).value = document.getElementById('sigla_und').value;
   }
   	 //inforrmando que a acao eh para apropriacao
   	 document.getElementById("recria_dup").value = "false";
   	 refazer();
   
}

function excluiAprop(idaprop){
   if (nao_recarregar){
   	alert('Já existe duplicatas baixadas ou faturadas, exclusão do plano de custo não é permitida.');
   }else{
       if (confirm("Deseja mesmo excluir essa Apropriação Gerencial?")){
          //informando que a acao eh para apropriacao
          document.getElementById("recria_dup").value = "false";
          refazer(idaprop);
       }
   }
}

function getArrayDuplicatas(){
	//carregando as duplicatas
	var dup_dts = "";
	var dup_vlrs = "";
	var dup_fats = "";
	var dup_ids = "";
	var doc = parent.frames[1].document;//frame de parcelas e apropriacao
	var c = 1;
	var o = 1;
	var total_parcela = 0.00;
	var total_aprop = 0.00;
        var total_a = 0.00;
        var stIcms = parent.frames[0].document.getElementById("stIcms").value;
        var incluirIcms = parent.frames[0].document.getElementById("incluirIcms").checked;
        var valorIcms = parent.frames[0].document.getElementById("icms").value;
        var valorTot = parent.frames[0].document.getElementById("total").value//frame do conhecimento
	var total_conh = parseFloat(stIcms != "9" ? valorTot : parseFloat(valorTot) - parseFloat(valorIcms));
	var qtd_parcela = parseInt(document.getElementById("qtd_parcela").value);
        var utilizarNormativaGSF598GO = (parent.frames[0].document.getElementById("is_in_gsf_598_03_go").value == "true" || parent.frames[0].document.getElementById("is_in_gsf_598_03_go").value == "t" ? true: false);
        var total_ctrc = 0;
        var total_dupli = 0;
        if (incluirIcms && utilizarNormativaGSF598GO && stIcms == "3") {
            total_dupli = parseFloat(parent.frames[0].document.getElementById("totalParcelas").value);
        } else {
            total_dupli = parseFloat(parent.frames[0].document.getElementById("total").value);
        }
        total_ctrc = parseFloat(parent.frames[0].document.getElementById("total").value);
	//somente usada na edicao
	var dups_baix = document.getElementById("dups_baixadas").value.split(",");
	
	while (doc.getElementById("dtvenc"+c) != null){
            total_parcela += parseFloat(doc.getElementById("vlr"+c).value);
            
            while(doc.getElementById("idplanocusto"+o) != null){
		total_aprop = roundABNT(parseFloat(total_aprop),2) + roundABNT(parseFloat(doc.getElementById("aprop_vlr"+o).value),2);
		/*(Se a duplicata tiver valor 0) ou (esta duplicata for a ultima e a soma delas nao coincidirem com o totalPrest)
                ou (se o usuario está tentando excluir a ultima duplicata baixada */
//		if ((parseFloat(getObj("vlr"+c).value) == 0) || (getObj("dtvenc"+(c+1)) == null && 
//			    (formatoMoeda(total_parcela) != formatoMoeda(total_conh)))) {
//			 return null;
//                     }
                //antes era esse if, agora se o CT for do tipo complementar, poderá ser salvo com valor 0.
                //acrescentei a validação stIcms != "9" pois o valor da duplicata poderá ser diferente do valor do cte quando 
                //Situação ICMS for: 60 - ICMS cobrado anteriormente por substituição tributária -Historia 3070 - Daniel Cassimiro
                    if ((parseFloat(getObj("vlr"+c).value) == 0) || (getObj("dtvenc"+(c+1)) == null && (formatoMoeda(total_parcela) != formatoMoeda(total_dupli)) && stIcms != "9")) {
                        if (parent.frames[0].document.getElementById("tipoConhecimento").value != "c") {
                            return null;
                        }
                }
		
		//se a data da duplicata for inválida..
		if (!validaData(getObj("dtvenc"+c).value)) {
		   alert("A data de vencimento da duplicata "+c+" é inválida!");
		   return null;
		}
		
		//vai ser montado um array com separador ',' para depois ser resgatado com split() no jsp
		
                o++;
            }//while
                var separador = (getObj("dtvenc"+(c+1)) != null ? "," : "&");
		dup_dts +=  doc.getElementById("dtvenc" + c).value + separador;
		dup_vlrs += doc.getElementById("vlr" + c).value + separador;
		dup_fats += getObj("fat" + c).value + separador;
		dup_ids += getObj("idParcel" + c).value + separador;

		c++;
            
	}//while
        //Validação para não salvar o conhecimento com valor da apropriação maior do que as duplicatas
        if(total_ctrc != total_aprop){
            alert("O valor total do Conhecimento ("+total_ctrc+") está diferente do valor total de duplicatas ("+total_aprop+")");
            return null;
        }
	//retornando o array carregado com datas e valores de duplicatas
    return (dup_dts == "" ? "" : "dup_dts="+dup_dts + "dup_vlrs=" + dup_vlrs + "dup_fats=" + dup_fats + "dup_ids=" + dup_ids);
}

function getArrayApropriacoes(){
        //se nao tiver criado nenhuma apropriacao
        if (document.getElementById("idplanocusto1") == null)
            return null;
	//carregando as apropriacoes
	var aprop_idplcusto = "";
	var aprop_vlrs = "";
	var aprop_und = "";
	var doc = document;
	var total_aprop = 0.00;
	var total_conh = parseFloat(parent.frames[0].document.getElementById("total").value);<%//frame do conhecimento%>
	var c = 1;
	//laco q percorre as apropiacoes para fazer os testes
	while (getObj("idplanocusto"+c) != null)
	{
		total_aprop += roundABNT(parseFloat(doc.getElementById("aprop_vlr"+c).value),2);
		//Se a ultima apropriacao tiver valor 0, ou esta apropriacao for 
		//a ultima(se eh a ultima a soma terminou) e os valores nao baterem.
		if ((parseFloat(doc.getElementById("aprop_vlr"+c).value) == 0)
			|| (doc.getElementById("idplanocusto"+(c+1)) == null
				&& (total_aprop.toString().substring(0,total_aprop.toString().indexOf("."))
					!= total_conh.toString().substring(0,total_conh.toString().indexOf(".")))))
		{
			 return null;
		}
		
		<%//vai ser montado um array com separador ',' para depois ser resgatado com split() no jsp%>
		var separador = (doc.getElementById("idplanocusto"+(c+1)) != null ? "," : "&");
		
		aprop_idplcusto +=  doc.getElementById("idplanocusto" + c).value + separador;
		aprop_vlrs += doc.getElementById("aprop_vlr" + c).value + separador;
		aprop_und += doc.getElementById("idUnd_custo" + c).value + separador;
		c++;
	}//while

	//retornando o array carregado com os idplanocusto e valores de apropriacao
    return (aprop_idplcusto == "" ? "" : "aprop_idplcusto=" + aprop_idplcusto + "aprop_vlrs=" + aprop_vlrs + "aprop_und=" + aprop_und);
}

function checkDuplicatas(){
   return (getArrayDuplicatas() != null);
}

function checkApropriacoes(){
   return !((getArrayApropriacoes() == null)
                 && (document.getElementById("idplanocusto1") != null));;
}

function aoCarregar() {
   //se existe soh uma apropriacao e esta esta zerada..
   if (getObj("aprop_vlr1") != null && 
       getObj("aprop_vlr2")== null && 
	   getObj("aprop_vlr1").value == 0)
   {
       getObj("aprop_vlr1").value = parent.frames[0].document.getElementById("total").value;
   }   
   
   applyFormatter($("table_duplicatas")); 
}

function refazerDtsVenc(){
   var dataInicial = parent.framePrincipal.getObj("dtemissao").value;
   var numDias = parent.framePrincipal.getObj("con_pgt").value;
   numDias = (numDias == "" ? 30 : parseFloat(numDias));
   var i = 1;
   
   while (getObj("dtvenc" + i) != null) {
      getObj("dtvenc"+i).value = incData(dataInicial, numDias);
	  //a primeira vez, calcula com dtemissao e numDias, depois com a dtemissao anterior e de 30 dias.
	  numDias = 30;
	  dataInicial = incData(dataInicial);
	  i++;
   }	  
}

function executarAtalhos(event){
    if (event == 113){
        //addNewNote('0', 'tableNotes0', true);
        addNewNote('0', 'tableNotes0', 'false');
        applyEventInNote();    
    }else if (event == 119){
        document.getElementById("salvar").onclick();
    }else if (event == 121){
        document.getElementById("salvar2").onclick();
    }
}
var qtdPlanoCusto  = 0;
function atualizarPlanoCusto(idCfop){
    
    jQuery.ajax({
            url: '<c:url value="/ConhecimentoControlador" />',
            dataType: "text",
            method: "post",
            data: {
                idCfop : idCfop,
                acao : "carregarPlanoCustoCfop"
            },
            success: function(data) {

                var planoCusto = JSON.parse(data);                
                if(planoCusto.PlanoCusto.idconta != 0){
                    for (var qtdPlano = 1; qtdPlano <= qtdPlanoCusto+1; qtdPlano++) {
                        if ($("idplanocusto"+qtdPlano) != null) {
                            $("idplanocusto"+qtdPlano).value = planoCusto.PlanoCusto.idconta;
                            $("plcusto_conta"+qtdPlano).value = planoCusto.PlanoCusto.conta;
                            $("plcusto_descricao"+qtdPlano).value = planoCusto.PlanoCusto.descricao;
                        }
                    }                    
                }else{
                    for (var qtdPlano = 1; qtdPlano <= qtdPlanoCusto+1; qtdPlano++) {
                        if ($("idplanocusto"+qtdPlano) != null) {
                            $("idplanocusto"+qtdPlano).value = '<%=plcustopadrao.getIdconta()%>';
                            $("plcusto_conta"+qtdPlano).value = '<%=plcustopadrao.getConta()%>';
                            $("plcusto_descricao"+qtdPlano).value = '<%=plcustopadrao.getDescricao()%>';
                        }
                    }
                }
            }
    });
}

              
</script>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="javascript" src="script/<%=Apoio.noCacheScript("funcoes.js")%>" type=""></script>
<script language="javascript" src="script/<%=Apoio.noCacheScript("prototype.js")%>" type=""></script>
<link href="estilo.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
body { 
	margin-left: 4px;
	margin-top: 4px;
	margin-right: 4px;
	margin-bottom: 4px;
	background: #FFFFFF;
}
-->
</style>

</head>

<body onLoad="aoCarregar()" onKeyUp="javascript:executarAtalhos(event.keyCode);" >

<%-- no caso de uso de frames, eh preciso criar uma div com o login do usuario --%>
<div id="usuarioLogado" style="display:none;"><%=(Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getLogin() : "")%></div>

<form name="formeditor" method="post" action="#">
 <!-- CAMPOS FANTASMAS -->
   <%-- vai ser alimentado quando chamar "refazer()" --%>
   <input name="notafiscal" type="hidden" id="notafiscal" value="">
   <input name="total" type="hidden" id="total" value="">
   
   <%-- 
     Campo "chaveador", usados paran informar se as duplicatas 
     vao ser recriadas ou carregadas com o valor do ultimo request. 

     Se (recria_dup == true) entao as duplicatas vao ser recriadas
       com os valores dos campos criados dinamicamente(se baseando pelo total do conh).
     Se nao 
       as duplicatas vao ser carregadas com os valores do ultimo request.
   --%>
   <input name="recria_dup" type="hidden" id="recria_dup" value="true">
 <!-- FIM DOS CAMPOS FANTASMAS-->
 
  <table width="87%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina" id="table_duplicatas">
    <tr class="tabela">
      <td width="60%" colspan="2"><div align="center">Duplicatas a receber</div></td>
	  <td  width="40%"><div align="center">Apropria&ccedil;&atilde;o gerencial </div></td>
    </tr>
    <tr>
      <td width="8%" class="TextoCampos">Qtd. Parcelas: </td>
      <td width="36%" class="CelulaZebra2"><input name="qtd_parcela" type="text" id="qtd_parcela" class="fieldMin" onBlur="javascript:seNaoIntReset(this, 1);"
                                                  value="<%=qtd_parcela%>" size="2" maxlength="2">
        <input name="btcriar_duplicata" type="button" class="botoes" id="btcriar_duplicata" value=" Criar Duplicatas " style="width:110 " onClick="javascript:tryRequestToServer(function(){refazer()});">
      </td>
      <td class="CelulaZebra2"><div align="right"><input name="nova_aprop" type="button" id="nova_aprop" class="botoes" style=" width:130 "
	                                                     value="Nova Apropriação" title="Cria uma nova apropriação gerencial" onClick="localizarplanocusto();"></div>
	  </td>
    </tr>
    <tr>
      <td colspan="2"> 
        <table width="100%" border="0" cellpadding="1" cellspacing="1" align="center">
          <tr class="CelulaZebra2">
            <td width="15%" align="center">Parcela</td>
            <td width="18%" align="center">Vencimento</td>
            <td width="15%" align="center">Valor</td>
			<td width="20%" align="center">Fatura</td>
			<td width="15%" align="center">Pago em</td>
			<td width="17%" align="center">Status</td>
          </tr>
          <%if (acao.equals("refazer") || acao.equals("editar"))
          {
                String data = Apoio.getDataAtual();
                String dataPago = "";
                String valor = vlrformat.format( total / qtd_parcela );
                String fatura = "";
                String status = "";
                boolean dup_baixada = false;
                int idParcel = 0;
                for (int i = 1; i <= qtd_parcela; ++i)
                {
                    //se nao estiver editando um conhecimento entao faça o incremento
                    if (!carregadup){
                        idParcel = 0;
                        //Reajuste de valor. Se a divisao nao for precisa, entao some ou subtraia 
                        //na ultima duplicata para balancear o valor.
                        if (!((i + 1) <= qtd_parcela ))
                        {    
                            if (!vlrformat.format( Double.parseDouble(valor) * qtd_parcela ).equals(vlrformat.format(total))) 
                            {
                                double totalp = Double.parseDouble(valor) * qtd_parcela;
                                if (totalp < total)
                                    valor = vlrformat.format((total - totalp) + Double.parseDouble(valor));
                                else
                                    valor = vlrformat.format(Double.parseDouble(valor) - (totalp - total));
                            }
                        }
                        
                        //Se o id dessa dup. conter na lista de baixadas ou "recria_dup"==false, entao ele sobrepoe 
                        //os valores das variaveis pelos valores do ultimo request.
                        dup_baixada = (!ids_baixadas.equals("") && Apoio.pesquisaArray(ids_baixadas.split(","),String.valueOf(i)) > -1);
                        valor = (dup_baixada ? request.getParameter("vlr"+i) : (recria_dup ? valor : request.getParameter("vlr"+i)));
                        data = (dup_baixada ? request.getParameter("dtvenc"+i) : (recria_dup ? Apoio.incData(data, 30) : request.getParameter("dtvenc"+i)) );
						fatura = (request.getParameter("fat"+i) != null ? request.getParameter("fat"+i) : "");
                    }else //se estiver carregando um conhecimento
                     {
                    	BeanDuplicata duu = (BeanDuplicata)dups[i - 1];
                        data = fmt.format(duu.getDtvenc());
                        dataPago = (duu.getDtpago() == null ? "" : fmt.format(duu.getDtpago()));
                        status = (duu.isBaixado() ? "Quitada" : "Em aberto");
                        valor = vlrformat.format(duu.getVlduplicata());
			fatura = duu.getFatura().getNumero();
                        dup_baixada = duu.isBaixado() || !fatura.equals("");
                        duplicata_baixada = (dup_baixada?dup_baixada:duplicata_baixada);
                        int lenNumFat = String.valueOf(duu.getFatura()).length();
                        fatura = (duu.getFatura().getId() != 0 ? duu.getFatura().getNumero()+"/"+duu.getFatura().getAnoFatura() : "");
                        //alimentando a lista de ids de dups. baixadas(se a duplicata atual foi baixada...)
                        ids_baixadas += (!ids_baixadas.equals("") && dup_baixada ? ",":"") + (dup_baixada ? String.valueOf(i) : "");
                        idParcel = duu.getId();
                     }                        
                     %>
                     <script>
                     	if (<%=dup_baixada || !fatura.equals("")%>){
                     		$('qtd_parcela').disabled = true;
                     		$('btcriar_duplicata').disabled = true;
                     	}
                     </script>
                     <tr class="CelulaZebra1">
                        <td><div align="center">
                          <input name="idParcel<%=i%>" id="idParcel<%=i%>" type="hidden" size="9" value="<%=idParcel%>">
                          <input name="parcela<%=i%>" id="parcela<%=i%>" type="text" size="8" 
                                               readonly class="fieldMin" value="<%=nfiscal+"/"+i%>">
                        </div></td>
                        <td><div align="center">
                          <input name="dtvenc<%=i%>" type="text" id="dtvenc<%=i%>" size="9" style="font-size:8pt;" maxlength="10"
                                                     <%-- se a duplicata foi baixada, entao ela vai ser "somente leitura"--%> 
                                   value="<%=data%>" <%=(dup_baixada || !fatura.equals("")? "readonly class=\"inputReadOnly\"" : "class=\"fieldDate\"")%> onBlur="alertInvalidDate(this)" >
                        </div></td>
                        <td><div align="center">
                          <input name="vlr<%=i%>" type="text" id="vlr<%=i%>"  size="8"  maxlength="9"     <%-- se a duplicata foi baixada, entao ela vai ser "somente leitura"--%>
                                   value="<%=valor%>" onBlur="javascript:seNaoFloatReset(this, '0.00');" <%=(dup_baixada || !fatura.equals("")? "readonly class=\"inputReadOnly\"" : "class=\"fieldMin\"")%>>
                        </div></td>
                           <td align="center">
						   <input id="fat<%=i%>" name="fat<%=i%>" type="hidden" value="<%=(fatura.equals("")? "" : fatura)%>">
    					   <label class="linkEditar" onClick="launchPopupLocate('./bxcontasreceber?acao=consultar&fatura=<%=(!fatura.equals("") ? fatura.split("/")[0] : "")%>&anofatura=<%=(!fatura.equals("")? fatura.split("/")[1] : "")%>');">
  						      <%=fatura%>
		        		   </label>
						 </td>
                        <td><div align="center">
                          <label><%=dataPago%></label>
                        </div></td>
                        <td><div align="center">
                          <label><%=status%></label>
                        </div></td>
                     </tr><%
                }//for
          }//if%>
      </table></td>
      <td align="top">
	   <table width="100%"  border="0" cellpadding="1" cellspacing="1">
        <tr class="CelulaZebra2">
          <td width="18%"><div align="left">Conta</div></td>
          <td width="35%"><div align="left">Descri&ccedil;&atilde;o</div></td>
          <td width="10%"><div align="left">Valor</div></td>
          <td width="31%"><div align="center">Und Custo</div></td>
          <td width="5%">&nbsp;</td>
        </tr>
      <%if (acao.equals("refazer") || carregadup)
       {   
           /*Excluindo a apropriacao.
             A forma de exclusao eh tentar igualar o indice ao "idaprop_exclui",
             quando for igual ele pula e vai para o proximo indice.
           */
           int idaprop_exclui = (request.getParameter("idaprop_exclui") != null ? 
                                 Integer.parseInt(request.getParameter("idaprop_exclui")) : 0);
           int k = 1;
           //O laco a seguir vale tanto para carregar apropriacoes como 
           //carregar os dados  do ultimo request
           while ((carregadup &&  k <= (aprops != null ? aprops.length : 0)) || 
                  (request.getParameter("idplanocusto" + k) != null))
           {   
               if (idaprop_exclui != k)
               { 
            	  BeanApropriacao aap = null;
            	  if (carregadup)
            	  	aap = (BeanApropriacao)aprops[k - 1];
            	  
                  int idpl = (carregadup ? aap.getPlanocusto().getIdconta() : Integer.parseInt(request.getParameter("idplanocusto" + k)));
                  String conta = (carregadup ? aap.getPlanocusto().getConta() : request.getParameter("plcusto_conta" + k));
                  String desc = (carregadup ? aap.getPlanocusto().getDescricao() : request.getParameter("plcusto_descricao" + k));
                  String valor = (carregadup ? vlrformat.format(aap.getValor()) : request.getParameter("aprop_vlr" + k));
                  int idUnd = (carregadup ? aap.getUnidadeCusto().getId() : Integer.parseInt(request.getParameter("idUnd_custo" + k)));
                  String siglaUnd = (carregadup ? aap.getUnidadeCusto().getSigla() : request.getParameter("sigla" + k));
                  %><tr class="CelulaZebra1">
                      <td><!-- id do plano custo -->
   	                    <div align="left">
	                <input name="idplanocusto<%=k%>" type="hidden" id="idplanocusto<%=k%>" value="<%=idpl%>">
	                <!-- fim -->
 	 	          <input name="plcusto_conta<%=k%>" type="text" id="plcusto_conta<%=k%>" class="inputReadOnly8pt" 
                                 size="8" readonly value="<%=conta%>">
                    </div></td>
	                  <td>
		                <div align="left">
		                  <input name="plcusto_descricao<%=k%>" type="text" id="plcusto_descricao<%=k%>" class="inputReadOnly8pt" 
                                  size="20" readonly value="<%=desc%>">
                        </div></td>
	                  <td>
                        <div align="left">
                          <input name="aprop_vlr<%=k%>" type="text" id="aprop_vlr<%=k%>"  size="7" class="fieldMin" maxlength="9"
	                         onblur="javascript:seNaoFloatReset(this, '0.00');"  value="<%=valor%>">
                        </div></td><td><span class="CelulaZebra2">
							  <input type="hidden" id="idUnd_custo<%=k%>" name="idUnd_custo<%=k%>" value="<%=idUnd%>"/>
							  <input type="hidden" id="sigla<%=k%>" name="sigla<%=k%>" value="<%=siglaUnd%>"/>
							  <label id="und_custo<%=k%>" name="und_custo<%=k%>"><%=siglaUnd%></label>
 	                          <input type="button" class="botoes"  
		          onClick="javascript:localizarUndCusto('<%=k%>');" value="..." />
 	                          </span></td>
	              <td><img src="img/lixo.png" title="Excluir esta apropria&ccedil;&atilde;o" style="cursor:pointer" onClick="javascript:excluiAprop(<%=k%>);"></td>
                  </tr>
              <%} 
                k++;
                %>
                <script>
                    qtdPlanoCusto++;
                </script>
                <%
           }//while (request.getParam...
           
           //Se o usuario tiver escolhido um plano custo ele recupera 
           if ((request.getParameter("idplanocusto") != null) && (!request.getParameter("idplanocusto").equals("")))
           {%>    
               <tr class="CelulaZebra1">
                  <td><!-- id do plano custo -->
   	                <div align="left">
	            <input name="idplanocusto<%=k%>" type="hidden" id="idplanocusto<%=k%>" value="<%=request.getParameter("idplanocusto")%>">
	            <!-- fim -->
 	 	      <input name="plcusto_conta<%=k%>" type="text" id="plcusto_conta<%=k%>" class="inputReadOnly8pt" 
                             size="8" readonly value="<%=request.getParameter("plcusto_conta")%>">
                    </div></td>
	              <td>
		            <div align="left">
		              <input name="plcusto_descricao<%=k%>" type="text" id="plcusto_descricao<%=k%>" class="inputReadOnly8pt" 
                              size="20" readonly value="<%=request.getParameter("plcusto_descricao")%>">
                    </div></td>
	              <td>
                    <div align="left">
                      <input name="aprop_vlr<%=k%>" type="text" id="aprop_vlr<%=k%>"  size="7" class="fieldMin" maxlength="9"
	                     onblur="javascript:seNaoFloatReset(this, 0);" value="0.00">
                    </div></td><td><span class="CelulaZebra2">
							  <input type="hidden" id="idUnd_custo<%=k%>" name="idUnd_custo<%=k%>" value="0"/>
							  <input type="hidden" id="sigla<%=k%>" name="sigla<%=k%>" value=""/>
							  <label id="und_custo<%=k%>" name="und_custo<%=k%>"></label>
 	                      <input type="button" class="botoes"  
		          onClick="javascript:localizarUndCusto('<%=k%>');" value="..." />
 	                      </span></td>
	          <td><img src="img/lixo.png" title="Excluir esta apropria&ccedil;&atilde;o" style="cursor:pointer" onClick="javascript:excluiAprop(<%=k%>);"></td>
               </tr>
         <%}%>
     <%}//if acao.equals("refazer")..%> 
	  <div id="layer_apoio"></div>
      </table></td>
    </tr>
  </table>
  <!-- campos para o localizador alimentar quando o usuario selecionar algum plano custo-->
   <input name="idplanocusto" type="hidden" id="idplanocusto">
   <input name="plcusto_conta" type="hidden" id="plcusto_conta">
   <input name="plcusto_descricao" type="hidden" id="plcusto_descricao">
   <input name="id_und" type="hidden" id="id_und" value="0">
   <input name="sigla_und" type="hidden" id="sigla_und" value="">
  <!-- fim -->
  <!-- campo fantasma p/ armazenar os ids das dups baixadas(se etiver editando) -->
  <input type="hidden" id="dups_baixadas" name="dups_baixadas" value="<%=ids_baixadas%>">
  <input type="hidden" id="maxDuplicatas" name="maxDuplicatas" value="">
  <input type="hidden" id="maxAprop" name="maxAprop" value="">
</form>

<table width="87%" border="0" align="center" cellpadding="0" cellspacing="1" class="bordaFina">
  <tr class="CelulaZebra2">
    <td colspan="6">
        <center>
            <%
            if ((nivelUser >= 2 && !cadct.getConhecimento().isImpresso()) || (acao_conhecimento.equals("editar") && cadct.getConhecimento().isImpresso() && nivelUserImpresso==4)){
            %>
                <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar [F8]" 
                       onClick="javascript:tryRequestToServer(function(){parent.framePrincipal.salva('<%=(acao_conhecimento.equals("iniciar") ? "incluir":"atualizar")%>',false,false);});">
                <%if (acao_conhecimento.equals("iniciar")){%>
                     &nbsp;&nbsp;&nbsp;&nbsp;
                     <input name="salvar3" type="button" class="botoes" id="salvar3" value="Salvar e digitar novo [F9]" 
                            onClick="javascript:tryRequestToServer(function(){parent.framePrincipal.salva('<%=(acao_conhecimento.equals("iniciar") ? "incluir":"atualizar")%>',false,true);});">
                     &nbsp;&nbsp;&nbsp;&nbsp;
                     <input name="salvar2" type="button" class="botoes" id="salvar2" value="Salvar e imprimir [F10]" 
                            onClick="javascript:tryRequestToServer(function(){parent.framePrincipal.salva('<%=(acao_conhecimento.equals("iniciar") ? "incluir":"atualizar")%>',true,false);});">
                     &nbsp;&nbsp;&nbsp;&nbsp;
                     <b>Driver:</b>&nbsp;
                     <select name="driverImpressora" id="driverImpressora" class="inputTexto">
                         <%Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "ctrc.txt");
                         String driverPadrao = Apoio.getUsuario(request).getFilial().getDriverPadraoImpressora();
                         driverPadrao = (driverPadrao == null ? "" : driverPadrao);
                         if (request.getParameter("driver") != null){
                             driverPadrao = request.getParameter("driver");
                         }
			             for (int i = 0; i < drivers.size(); ++i) {
				            String driv = (String)drivers.get(i);
				            driv = driv.substring(0,driv.lastIndexOf("."));%>
                         <option value="<%=driv%>" <%=(driverPadrao.equals(driv) ? "selected" : "")%> ><%=driv%>&nbsp;</option>
                         <%}%>
                     </select>    
                <%}

                }else{
                     if (cadct.getConhecimento().isImpresso()){%>
                         CTRC impresso, você não tem permissão para alterar os dados deste CTRC.
                     <%}
                }%>
    </center></td>
  </tr>
</table>    
</body>
</html>
<script>
    nao_recarregar = <%=duplicata_baixada%>;
</script>