<%-- 
    Document   : cadastrar_carta_correcao
    Created on : 06/01/2014, 18:27:08
    Author     : amanda
--%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@ taglib uri='http://java.sun.com/jsp/jstl/core' prefix='c'%>
<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>    
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>

<script type="text/javascript" language="JavaScript">
    jQuery.noConflict();
    
    var countItem = 0;
    
    function enviarC(){
        
        var mensErro = "Informe o(s) motivo(s) da carta de correção.";
        if($("maxItem").value == "0"){
            return alert(mensErro);
        }
        
        var maxItem = parseInt($("maxItem").value);
        var possuiItens = false;
        for(var i = 0; i <= maxItem; i++){
            if($("campo_"+i) != null){
                possuiItens = true;
            }
        }
        if (!possuiItens){
            return alert(mensErro);
        }
        
        setEnv('enviar');
        window.open('about:blank', 'pop', 'width=450, height=450');
        $("formulario").submit();
        window.opener.location.reload(false);
        return true;
//        window.close();
    }
    
    function Item(campo,texto, grupo) {
        this.grupo =  grupo;
        this.campo = campo;
        this.texto = texto;
        
    }
    
       
    function addItem(item){
        
        
        if(document.getElementById("campo").value == "0" || document.getElementById("descricaoCampo").value == ""){
            return alert("Informe corretamente os campos 'Grupo' e 'Texto'.");
        }
       
        if (item == undefined){
            item = new Item(document.getElementById("campo").value,document.getElementById("descricaoCampo").value,document.getElementById("grupo").value);
        }
        
        countItem++;
        
        var tr1_ = Builder.node("tr", {name: "tr_"+countItem, id: "tr_"+countItem,className:(countItem % 2 ? "CelulaZebra1" : "CelulaZebra2")});
        
        var td0_ = Builder.node("TD",{});
        var td1_ = Builder.node("TD",{colspan:"2"});
        var td2_ = Builder.node("TD",{colspan:"2"});      
        var td3_ = Builder.node("TD",{colspan:"2"});      

        // Descricao Rota
        var inp1_ = Builder.node("INPUT",{
            type:"text", 
            id:"campo_"+countItem,
            name:"campo_"+countItem,
            value: item.campo,
            size: "15",
            colspan: "3",
            className:"inputtexto"});   
        
        var inp2_ = Builder.node("INPUT",{
            type:"text",
            id:"texto_"+countItem,
            name:"texto_"+countItem,
            value: item.texto,
            size: "80",
            className:"inputtexto"});   
       
        var inp3_ = Builder.node("INPUT",{
            type:"text",
            id:"grupo_"+countItem,
            name:"grupo_"+countItem,
            value: item.grupo,
            size: "15",           
            className:"inputtexto"});   
       
        
        var _img0 = Builder.node("IMG",{
            src:"img/lixo.png",
            onClick:"removerItem("+countItem+");"});
               
        td0_.appendChild(_img0);        
        td1_.appendChild(inp1_);  
        td2_.appendChild(inp2_);
        td3_.appendChild(inp3_);
       

        tr1_.appendChild(td0_);
        tr1_.appendChild(td3_);
        tr1_.appendChild(td1_);
        tr1_.appendChild(td2_);
        
                
        document.getElementById("tJust").appendChild(tr1_);
        
        document.getElementById("maxItem").value = countItem;
        $("alterarCampo").value = "";
        $("descricaoCampo").value = "";
        $("alterarCampo").focus();

    }    
    
    function removerItem(index){    
        var descricaoCampo = $("texto_"+index).value;     
        if(confirm("Deseja excluir o campo \'"+descricaoCampo+"\'?")){
            if(confirm("Tem certeza?")){
                Element.remove($("tr_"+index));
            }
        }        
    }
    

    
    function getCampos(){
        var grupo = $("grupo").value; 
            function e(transport){
                var textoresposta = transport.responseText;
                //se deu algum erro na requisicao...
                if (textoresposta == "-1"){
                    alert('Houve algum problema ao requistar oa campos, favor tente novamente. ');
                    return false;
                }else{                    
                    var campos =jQuery.parseJSON(textoresposta).list[0].CamposAutorizados;
             
                    var listCampo = campos;
                    var campoY;
                    var slct = $("campo");
                    var rotaIdAnt = slct.value;

                    removeOptionSelected("campo");
                    var length = (listCampo != undefined && listCampo.length != undefined ? listCampo.length : 1);

                    for(var i = 0; i < length; i++){
//
                        if(length > 1){
                            campoY = listCampo[i];
                            if(i == 0){
                                slct.value = listCampo[i].campoTag; 
                            }
                        }else{
                            campoY = listCampo;
                        }
                        if(campoY != null && campoY != undefined){
                            slct.appendChild(Builder.node('OPTION', {value: campoY.campoTag}, campoY.campo));                             
                        }
                    }
                }
            }//funcao e()
            tryRequestToServer(function(){
                new Ajax.Request("CTeControlador?acao=camposAutorizados&grupo="+ grupo,{method:'post', onSuccess: e, onError: e});
            });
        }

    
        
</script>

<html>
    <head>
        <LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
        <style  type="text/css" >
            <!--
            .style3 {color: #333333}
            .style4 {
                font-size: 14px;
                font-weight: bold;
            }

            .style5 {
                color:red;
            }
            -->
        </style>


        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Incluir Carta de Correção Eletrônica (CC-e)</title>
    </head>
    <body>
        <img src="img/banner.gif"  alt=""><br>
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td align="left"> 
                    <span class="style4">Incluir Carta de Correção Eletrônica (CC-e)</span>
                </td>               
            </tr>
        </table>
        <br>
        <form action="./CTeControlador?acao=enviarCCe" id="formulario" name="formulario" method="post" target="pop">
            <table class="bordaFina" width="80%" align="center">
                <tr>
                    <td class="TextoCampos" width="20%">
                        <input name="evento" id="evento" value="${param.evento}" type="hidden">
                        <input type="hidden" name="maxItem" id="maxItem" value="0"/>
                        <input type="hidden" name="ids" id="ids" value="<c:out value='${param.id}'/>"/>
                        <input type="hidden" name="ctrcs" id="ctrcs" value="<c:out value='${param.ctrcID}'/>"/>
                        <input type="hidden" name="botao" id="botao" value="enviar"/>
                      CTRC:
                    </td>
                    <td width="60%" class="CelulaZebra2" height="20">
                        ${param.ctes}
                    </td>

                    <td width="20%" class="TextoCampos">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" ></td>
                    <td class="TextoCampos" colspan="3" >                    
                        <table class="bordaFina" width="60%" align="left">
                            <tr>
                                <td class="TextoCampos" colspan="2">
                                    <div align="left" style="font-family: Verdana">
                                        <p>&nbsp;&nbsp;Art. 58-B Fica permitida a utilização de carta de correção, para regularização de erro ocorrido na
                                            emissão de documentos fiscais relativos à prestação de serviço de transporte, desde que o erro não
                                            utilizada para regularização de erro ocorrido na emissão de
                                            esteja relacionado com: </p>
                                        <p>&nbsp;&nbsp;I - as variáveis que determinam o valor do imposto tais como: base de cálculo, alíquota, diferença de
                                            preço, quantidade, valor da prestação;</p>
                                        <p>&nbsp;&nbsp;II - a correção de dados cadastrais que implique mudança do emitente, tomador, remetente ou do
                                            destinatário;</p>
                                        <p>&nbsp;&nbsp;III - A data de emissão ou de saída.</p> 
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <table width="100%" class="bordaFina">
                            <tr>
                                <td >
                                    <div class="limite">
                                        <table width="100%" class="bordaFina">
                                            <tr>
                                                <td class="TextoCampos"  align="center"> 
                                                   <div align="center"> <img onclick="javascript:addItem();" src="./img/novo.gif"/></div>
                                                </td>   
                                                <td class="TextoCampos" align="left" ><div align="left">Grupo:</div></td>
                                                
                                            
                                                <td  class="CelulaZebra2" >
                                                        <div align ="left">
                                                            <select name="grupo" id="grupo" class="inputtexto" onchange="javascript:getCampos();" >
                                                                <option value="0">Selecione</option>
                                                                <c:forEach var="grupos" items="${gruposAutorizados}">
                                                                    <option value="${grupos.grupoTag}">${grupos.grupo}</option>
                                                                </c:forEach>
                                                            </select>
                                                            </div>
                                                </td>
                                                
                                                
                                                <td class="TextoCampos" align="left" ><div align ="left">Campo:</div></td>
                                                <td  class="CelulaZebra2" >
                                                    <div align ="left">
                                                            <select name="campo" id="campo" class="inputtexto" >
                                                                <option value="0">Selecione</option>
                                                                <c:forEach var="campos" items="${camposAutorizados}">
                                                                    <option value="${campos.campoTag}">${campos.campo}</option>
                                                                </c:forEach>
                                                            </select>
                                                    </div>
                                                       
                                                </td>
                                                <td class="TextoCampos" align="left" ><div align ="left">Justificativa:</div></td>
                                                <td class="CelulaZebra2"  ><div align="left"><div align ="left">
                                                    <input name="descricaoCampo" id="descricaoCampo" type="text" class="inputtexto" size="70" maxlength="1000" value="" /></div>
                                                    </div>
                                                </td>
                                                <td class="TextoCampos" colspan="3"></td>
                                                
                                            </tr>
                                            <tr>
                                                <td class="tabela" align="left">

                                                </td>
                                                <td class="tabela" colspan="2" align="left">
                                                    Grupo
                                                </td>
                                                <td class="tabela" colspan="2" align="left">
                                                    Campo
                                                </td>
                                                
                                                <td class="tabela" colspan="2" align="left">
                                                    Justificativa
                                                </td>
                                            </tr>
                                            <tbody id="tJust"></tbody>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>

                <tr class="CelulaZebra2">
                    <td align="center" colspan="3">
                        <input id="enviar" name="enviar" type="button" class="inputbotao" value="  Estou ciente dos termos e solicito envio de Carta de Correção.  " onclick="javascript:tryRequestToServer(function(){enviarC();});" />                        
                    </td>

                </tr>
            </table>
        </form>
    </body>
</html>
