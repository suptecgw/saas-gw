<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="./estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">   
    jQuery.noConflict();
        
     arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
    
    
    function carregar(){
               
        var action = '<c:out value="${param.acao}"/>';
         $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
         $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        if(action == 2){
            $("idGrupo").value = '<c:out value="${gServico.id}"/>';
            $("descricao").value = '<c:out value="${gServico.descricao}"/>';
            $("cidade_id").value = '<c:out value="${gServico.cidade.idcidade}"/>';
            $("taxa").value = '<c:out value="${gServico.taxa.id}"/>';
            $("descricao_municipal").value = '<c:out value="${gServico.tribMunicipal.descricao}"/>';
            $("descricao_federal").value = '<c:out value="${gServico.tribFederal.descricao}"/>';
            $("codigo_municipal").value = '<c:out value="${gServico.tribMunicipal.cod}"/>';
            $("cod_tributacao_federal").value = '<c:out value="${gServico.tribFederal.cod}"/>';
            $("exigibilidadeISS").value = '<c:out value="${gServico.exigibilidadeISS}"/>';
        }
    }
    
    function abrirLocalizarTributacaoFederal(campos){
        abrirLocaliza("${homePath}/TributacaoControlador?acao=localizarFederalLogis&tipo=r&modulo=gwLogis&campos="+campos, "locTribEstServicoLogis");
    }
    function abrirLocalizarTributacaoMunicipal(campos){
        abrirLocaliza("${homePath}/TributacaoControlador?acao=localizarMunicipalLogis&tipo=r&modulo=gwLogis&campos="+campos, "locTribMunServicoLogis");
    }

    function voltar(){
        tryRequestToServer(function(){(window.location  = "ConsultaControlador?codTela=50")});
    }

    function salvar(){
       
        //var formu = document.formulario;
        
        if($("descricao").value == ""){
            alert("O campo 'Descrição' não pode ficar em branco!");
            $("descricao").focus();
            return false;
        }

        /*if($("cod_tributacao_federal").value == "0"){
            return alert("O campo 'Tribução federal' não pode ficar em branco!");
        }*/
        
        if($("codigo_municipal").value == "0"){
            return alert("O campo 'Tribução Municipal' não pode ficar em branco!");
        }

        window.open('about:blank', 'pop', 'width=210, height=100');
        
        $("formulario").submit();
        
        return true;
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
                }}
                countLog = 0;
                var rotina = "nfse_grupo_servico";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("idGrupo").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
        
</script>

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Cadastro de Grupos de Servi&ccedil;o</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="carregar();applyFormatter();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="65%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Grupos de Servi&ccedil;o</span>
                </td>
                <td>
                    <input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/>
                </td>
            </tr>
        </table>
        <br>
        <!-- codigo de verificaao de acao editar = 2  ou cadastrar = ?? -->
        <form action="GrupoServicoNfseControladador?acao=${param.acao == 2 ? "editar": "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <table width="65%" align="center" class="bordaFina" >
                <tr>
                    <td colspan="6" align="center" class="tabela">
                        Dados Principais
                        <input type="hidden" name="modulo" id="modulo" value="gwTrans"/>
                        <input type="hidden" name="idGrupo" id="idGrupo" value="0"/>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="25%">*Descri&ccedil;&atilde;o:</td>
                    <td class="CelulaZebra2" colspan="4">
                        <input id="descricao" name="descricao" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Taxa:</td>
                    <td class="CelulaZebra2">
                        <select name="taxa"  id="taxa" class="inputtexto" style="width: 150px">
                            <c:forEach var="taxa" items="${taxasCadServico}">
                                <option value="${taxa.id}">${taxa.codigo} - ${taxa.descricao}</option>
                            </c:forEach>
                        </select>
                    </td>
                    <td class="TextoCampos">Exigibilidade ISS: </td>
                    <td class="CelulaZebra2">
                        <select name="exigibilidadeISS" id="exigibilidadeISS" class="inputtexto" style="width: 150px">
                            <option value="1">Exigível</option>
                            <option value="2">Não Incidência</option>
                            <option value="3">Isenção</option>
                            <option value="4">Exportação</option>
                            <option value="5">Imunidade</option>
                            <option value="6">Exigibilidade suspensa por decisão judicial</option>
                            <option value="7">Exigibilidade suspensa por por procedimento administrativo</option>
                        </select>
                    </td>                    
                </tr>
                <tr>
                    <td  class="TextoCampos">Trib. Municipal:</td>
                    <td class="CelulaZebra2" width="35%">
                        <input name="descricao_municipal" id="descricao_municipal" type="text" class="inputReadOnly" size="22" readonly/>
                        <input type="hidden" name="codigo_municipal" id="codigo_municipal" value="0"/>
                        <input type="hidden" name="cidade_id" id="cidade_id" value="0"/>
                        <input type="hidden" name="tributacao_federal" id="tributacao_federal" value="0"/>
                        <input type="button" class="inputBotaoMin"  id="botaoMunicipal"  value="..."
                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.TRIBUTACAO_MUNICIPAL%>&paramaux= ${param.paramaux}', 'Municipal')">
                    </td>
                    <td  class="TextoCampos" width="18%">Trib. Federal:</td>
                    <td class="CelulaZebra2" colspan="2" width="35%">
                        <input name="descricao_federal"  id="descricao_federal" type="text" class="inputReadOnly" size="22" readonly ="false" value=""/>
                        <input type="hidden" name="cod_tributacao_federal" id="cod_tributacao_federal" value="0"/>
                        <input type="button" class="inputBotaoMin"  id="botaoFederal"  value="..."
                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.TRIBUTACAO_FEDERAL%>', 'Federal')">
                    </td>
                </tr>
            </table>
              <table width="65%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>  
                                 <td id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" style='display:${param.acao == 2 && param.nivel == 4 ? "" : "none"}' onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                    
                                </tr>
                            </table>
                        </td> 
                    </tr>
               
                                         
                </table> 
                <div id="divAuditoria" name="divAuditoria" >
              
                    <table width="65%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria" style='display:${param.acao == 2 && param.nivel == 4 ? "" : "none"}'>
                        <%@include file="template_auditoria.jsp" %>
                          <tr>
                            <td colspan="6">
                                <table width="100%" align="center" class="bordaFina">
                                    <tr class="CelulaZebra2">
                                        <td class="TextoCampos" width="15%"> Incluso:</td>

                                        <td width="35%" class="CelulaZebra2"> 
                                            Em: ${gServico.criadoEm} <br>
                                            Por: ${gServico.criadoPor.nome}
                                        </td>

                                        <td width="15%" class="TextoCampos"> Alterado:</td>
                                        <td width="35%" class="CelulaZebra2"> 
                                            Em: ${gServico.alteradoEm} <br>
                                            Por: ${gServico.alteradoPor.nome}
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                 </table>   
              </div>
               
                  <br/>
               <table width="65%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria">
                  <tr>
                    <c:if test="${param.nivel >= param.bloq}">
                        <td colspan="6" class="CelulaZebra2">
                            <div align="center">
                                <input type="button" value="  SALVAR  " class="inputbotao" id="botSalvar" onclick="salvar()"/>
                            </div>
                        </td>
                    </c:if>
                </tr>
            </table>
         </form>
    </body>
</html>