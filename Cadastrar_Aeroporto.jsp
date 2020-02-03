<%@page import="nucleo.BeanLocaliza"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"  language="java" import="nucleo.Apoio"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="../estilo.css" TYPE="text/css">
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
               
      
        if(action == 2){
           
            $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            $("id").value = '<c:out value="${aeroporto.id}"/>';
            $("nome").value = '<c:out value="${aeroporto.nome}"/>';
            $("idcidadeorigem_localiza").value = '<c:out value="${aeroporto.cidade.idcidade}"/>';
            $("cid_origem_localiza").value = '<c:out value="${aeroporto.cidade.descricaoCidade}"/>';
            $("iata").value = '<c:out value="${aeroporto.iata}"/>';
            
            //Carregar DOM.
            <c:forEach  var="cidade_atendida" items="${aeroporto.getIdsCidadeAtendida()}">
                cidadeAtendida = new CidadeAtendida();
                cidadeAtendida.id = ${cidade_atendida.idcidade};
                cidadeAtendida.cidade = '${cidade_atendida.descricaoCidade}';
                console.log(cidadeAtendida.cidade)
                if(cidadeAtendida.id != 0){
                    addCidadeAtendida(cidadeAtendida);
                }
            </c:forEach>
            
        }
        
        
    }   

    function voltar(){
        tryRequestToServer(function(){(window.location  = "ConsultaControlador?codTela=34")});
    }


    function salvar(){
       
        //var formu = document.formulario;
        
        if($("nome").value == ""){
            alert("O campo 'Nome' não pode ficar em branco!");  
            $("nome").focus();
            return false;
        }   
        if($("idcidadeorigem_localiza").value == "0"){
            return alert("O campo 'Cidade' não pode ficar em branco!");
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
                var rotina = "aeroporto";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = $("id").value;
                console.log(id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
            
            
    
            

    function excluirCidade(index){
        
        if (confirm("Deseja mesmo excluir esta cidade?")){
            var idCidade = $("inpIdCidade_"+index).value;
            var idsCidadeAtendida="";
            if(idCidade != undefined || idCidade != null){
                if($("idsExcluirCidade").value  == ""){
                    $("idsExcluirCidade").value = idCidade;
                }else{
                    idsCidadeAtendida = $("idsExcluirCidade").value = $("idsExcluirCidade").value + "," + idCidade;
                    $("idsExcluirCidade").value = idsCidadeAtendida;
                }   
            } 
            
            $("trPrincipal_" + index).remove();
            
            
        }
    }        
    


    

    function CidadeAtendida(id,cidade){
        this.id = (id == undefined || id == null ? 0 : id);
        this.cidade = (cidade == undefined || cidade == null ? "":cidade);
    }
    
    var  countCidade=0; 
    function addCidadeAtendida(cidade){
        countCidade++;
        
        if(cidade == undefined || cidade == null){
            cidade = new CidadeAtendida();
        }
        
        var classe = (countCidade % 2 == 1 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign");
        var tabela = $("tbDomCidadeAtendida");
        
        var _trPrincipal = Builder.node("tr",{id:"trPrincipal_"+countCidade, className:"tabela"});
        var _tdCidade = Builder.node("td",{id:"tdCidade_"+countCidade, className:classe, align:"left" });
        var _tdExcluir = Builder.node("td",{id:"tdExcluir_"+countCidade, className:classe, align:"center" });
        
                                
        
       // Id da cidade
        var  inpIdCidade = Builder.node("input",{
            id:"inpIdCidade_"+countCidade,
            name:"inpIdCidade_"+countCidade,
            type:"hidden",
            value: cidade.id
           
        });
        
        
        //Descrição da cidade
        var inputCidade = Builder.node("INPUT",{
            id:"inputCidade_"+countCidade,
            name:"inputCidade_"+countCidade,
            type:"text",
            class:"inputReadOnly",
            size:"17",
            readonly:true,
            value:cidade.cidade
        });
        
        // Botão de localizar.
         var localizaCidade = Builder.node("INPUT",{
            id:"localizaCidade_"+countCidade,
            name:"localizaCidade_"+countCidade,
            className:"inputBotaoMin",
            type:"button",
            value:"...",
            class: "inputBotaoMin",
            onClick:"localizarCidadeAtendidas(" + countCidade + ")"
         });
        
        
         var _inpExcluirCidade = Builder.node("img",{
            id:"inpExcluirCidade_"+countCidade,
            name:"inpExcluirCidade_"+countCidade,
            type:"button",
            className:"imagemLink",
            src:"img/lixo.png",
            width:"20px",                       
            heigth:"20px",
            onclick:"javascript:tryRequestToServer(function(){excluirCidade("+countCidade+")});"
        });
        
        
        
        _tdCidade.appendChild(inputCidade);
        _tdCidade.appendChild(localizaCidade);
        _tdExcluir.appendChild(_inpExcluirCidade);
        _trPrincipal.appendChild(_tdExcluir);
        _tdCidade.appendChild(inpIdCidade);
        _trPrincipal.appendChild(_tdCidade);
        
        tabela.appendChild(_trPrincipal);
        
        
        $("inpQtdCidades").value = countCidade;
        
    }
    
    function localizarCidadeAtendidas(index){
        if($("indexAux") != null){
            $("indexAux").value = index;
        }

        popLocate(11, "Cidade_Atendidas", "");
    }

    function aoClicarNoLocaliza(idJanela){
        var index = $("indexAux").value;

        if (idJanela == 'Cidade') {
            $("idcidadeorigem_localiza").value = $('idcidadeorigem').value;
            $("cid_origem_localiza").value = $('cid_origem').value;
        } else if (idJanela == "Cidade_Atendidas") {
            $("inpIdCidade_" + index).value = $('idcidadeorigem').value;
            $("inputCidade_" + index).value = $('cid_origem').value;
        }
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
        <title> Cadastro de Aeroporto</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="carregar();applyFormatter();AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')">
        <img alt="" src="img/banner.gif" width="30%" height="44" align="middle">
        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="82%" align="left"> <span class="style4">Cadastro de Aeroporto</span></td>
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>
        <!-- codigo de verificaao de acao editar = 2  ou cadastrar = ?? -->
        <form action="AeroportoControlador?acao=${param.acao == 2 ? "editar": "cadastrar"}" id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" id="id" name="id" value="0">
           
                  
            <table width="50%" align="center" class="bordaFina" >
                <tr>
                    <td colspan="6" align="center" class="tabela" >Dados principais</td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="25%">*Nome:</td>
                    <td class="CelulaZebra2" colspan="4">
                        <input id="nome" name="nome" type="text" class="inputtexto" size="50" maxlength="50"  />
                    </td>

                </tr>
                <tr>
                    <td  class="TextoCampos" >Cidade:</td>
                    <td class="CelulaZebra2" width="35%">
                        <input name="cid_origem" id="cid_origem" type="hidden">
                        <input name="cid_origem_localiza" id="cid_origem_localiza" type="text" class="inputReadOnly" size="17" readonly/>
                        <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0"/>
                        <input type="hidden" name="idcidadeorigem_localiza" id="idcidadeorigem_localiza" value="0"/>
                        <input type="hidden" name="dataDeAuditoria" id="dataDeAuditoria" value="0"/>
                        <input type="hidden" name="dataAteAuditoria" id="dataAteAuditoria" value="0"/>
                        <input type="button" class="inputBotaoMin"  id="botaoCidade"  value="..."
                               onClick="launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade')"></td>                   
                </tr>                
                <tr>
                     <td  class="TextoCampos" >IATA:</td>
                    <td class="CelulaZebra2" width="35%">
                        <input name="iata" id="iata" type="text" class="inputtexto" size="5" maxlength="3"/>
                    </td>
                </tr>
                
            </table>
            
            <table width="50%" align="center" class="bordaFina" >
                <tr>
                    <td colspan="6" align="center" class="tabela" >Cidades atendidas</td>
                </tr> 
                 <tr class="celula">
                    <td align="center" >
                         <img align="center"  onClick="addCidadeAtendida();" alt="addCampo" src="img/add.gif" class="imagemLink"/>
                    </td>
                        <td align="left" width="95%">Cidades</td>
                    </td>
                 </tr>
                    <input id="inpQtdCidades" name="inpQtdCidades" value="" type="hidden">
                    <input id="idsExcluirCidade" name="idsExcluirCidade" value="" type="hidden">
                    <input type="hidden" id="indexAux"></input>
                <tbody id="tbDomCidadeAtendida" name="tbDomCidadeAtendida">
                </tbody>
            </table>    
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
            <c:if test="${param.acao == 2 && param.nivel == 4}">
            <table align="center"  width="50%" class="bordaFina" >
                    <tr>
                        <td>
                                 <div id="divAuditoria" width="80%" >
                                            <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                             <%@include file="./gwTrans/template_auditoria.jsp" %>
                                           </table>
                                 </div> 
                        </td>    
                    </tr>
                                             <tr>
                                                <td colspan="6">
                                                    <table width="100%" align="center" class="bordaFina">
                                                        <tr class="CelulaZebra2">
                                                            <td class="TextoCampos" width="15%"> Incluso:</td>

                                                            <td width="35%" class="CelulaZebra2"> em: ${aeroporto.criadoEm} <br>
                                                                por: ${aeroporto.criadoPor.nome}
                                                            </td>

                                                            <td width="15%" class="TextoCampos"> Alterado:</td>
                                                            <td width="35%" class="CelulaZebra2"> em: ${aeroporto.alteradoEm} <br>
                                                                por: ${aeroporto.alteradoPor.nome}
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                            </table>
                            </c:if>             
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