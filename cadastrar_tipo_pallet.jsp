<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/collection.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">    
     jQuery.noConflict();    
     
      arAbasGenerico = new Array();
      arAbasGenerico[0] = new stAba('tdAbaAuditoria','divAuditoria');
     
    function carregar(){
        var action = '<c:out value="${param.acao}"/>';
        var form = document.formulario;
        
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        
        if(action == 2){  
            //Dados pricipais
            form.id.value = '<c:out value="${cadTipoPallet.id}"/>';
            form.descricao.value = '<c:out value="${cadTipoPallet.descricao}"/>';
            form.area.value = colocarVirgula('<c:out value="${cadTipoPallet.area}"/>');
        }

        form.descricao.focus();
    }
    
    function voltar(){
        location.replace("ConsultaControlador?codTela=35");
    }
    
    function salvar(){
        var form = document.formulario;
        
        if(form.descricao.value == ""){
            alert("O campo 'Descrição' não pode ficar em branco!");            
            form.descricao.focus();
            return false;            
        }   
        if(form.area.value == ""){
            alert("O campo 'Área' não pode ficar em branco!");
            form.area.focus();
            return false;
        }
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        form.submit();
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
                var rotina = "tipo_pallet";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
    
</script> 

<html>
    <style type="text/css">
        <!--
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
		.style5 {
			color: #000000
		}
        -->
    </style>
    
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>webtrans - Cadastro de Tipo de Pallet</title>
    </head>
    <body onLoad="applyFormatter();carregar();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
        <img src="img/banner.gif" width="40%" height="44">
        
        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Tipo de Pallet</span>
                </td>
                <td>
                    <input type="button" value=" Voltar " class="inputbotao" onclick="tryRequestToServer(function(){voltar()})"/>
                </td>
            </tr>
        </table>
        
        <br>
            <form action="TipoPalletControlador?acao=${param.acao==2 ? "editar":"cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
                <table width="50%" align="center" class="bordaFina" >
                     <tr>
                          <td width="100%" align="center" class="tabela" >Dados principais</td>
                     </tr>   
                     <td align="center" >
                          <table  width="100%" border="0" class="bordaFina">
                               <tr>
                                  <td class="TextoCampos" width="30%">*Descri&ccedil;&atilde;o:</td>
                                  <td class="CelulaZebra2"  width="70%">
                                       <input type="hidden" name="id" id="id" value="0"/>
                                       <input name="descricao" id="descricao" type="text" class="inputtexto" size="25" maxlength="25"/>
                                  </td>                       
                               </tr>
                               <tr>
                                  <td class="TextoCampos" width="30%">*&Aacute;rea em m²:</td>
                                  <td class="CelulaZebra2"  width="70%">
                                       <input name="area" id="area" type="text" class="inputtexto" size="10" maxlength="10" value="0,00" onkeypress="mascara(this, reais)"/>
                                  </td>
                               </tr>
                          </table>
                </TABLE>
                         <table align="center" width="50%" >
                                    <tr>
                                        <td width="100%">
                                            <table align="left">
                                                <tr>
                                                   <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>

                                                </tr>
                                            </table>
                                        </td> 
                                    </tr>
                         </table>
               <table align="center"  width="50%" class="bordaFina" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none"}' >
                    <tr>
                        <td>
                              <div id="divAuditoria" width="80%" >
                                    <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                        <%@include file="/gwTrans/template_auditoria.jsp" %>
                                    </table>
                              </div> 
                                
                           </td>   
                            </tr>
                        
                                <tr>
                                
                              
                                  <td colspan="8"> 
                                         <table width="100%" align="center" class="bordaFina">        
                                                                
                                                <tr class="CelulaZebra2">
                                                <td class="TextoCampos" width="15%"> Incluso:
                                                    </td>

                                                    <td width="35%"> em: ${cadTipoPallet.criadoEm} <br>
                                                                     por: ${cadTipoPallet.criadoPor.nome}                                    
                                                    </td>

                                                    <td width="15%" class="TextoCampos"> Alterado:</td>
                                                     <td width="35%" class="CelulaZebra2"> em: ${cadTipoPallet.atualizadoEm} <br>
                                                                     por: ${cadTipoPallet.atualizadoPor.nome}                                    
                                                    </td>
                                                </tr>
                                        </table>
                                    </td>  
                       
                                
                              </tr>  
               </TABLE>   
                      <br/>
                      <c:if test="${param.nivel >= param.bloq}"> 
                      <table align="center"  width="50%" class="bordaFina" >          
                        <tr>
                          
                            <td colspan="6" class="CelulaZebra2" >
                                <div align="center">
                                    <input type="button" value="  SALVAR  " class="inputbotao" id="botSalvar" onclick="salvar()"/>
                                </div>
                            </td>
                               
                        </tr>
                       </table>  
                 </c:if>
               
             </form> 
       </body>
</html>

