<%-- 
    Document   : importar_conferencia_coleta_mobile.jsp
    Created on : 17/06/2016, 15:53:07
    Author     : paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<fmt:setLocale value="pt-BR" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<script language="JavaScript" type="text/javascript" src="script/funcoes.js" ></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="JavaScript" type="text/javascript" src="script/prototype.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/ie.js" ></script>
<script language="JavaScript" type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="JavaScript" type="text/javascript">
    jQuery.noConflict();
    
    var idUsuario;
    var nomeUsuario;
    
    function fechar(){
        window.close();
    }
    
    function atualizar(){
                
        var form = $("formAtualizar");
        var idColeta = $("idColeta").value;
        var tipoOperacao = $("tipoOperacao").value;
        form.action = "ConferenciaControlador?acao=importarArquivoColetaMobile&idColeta="+idColeta+"&tipoOperacao="+tipoOperacao;
        form.submit();

    }
    
    function carregar(){        
                
        var coletor = null;        
            
        <c:forEach var="coletor" varStatus="status" items="${listaColetorManRom}">
            
            coletor = new DadosColetor();
            
            coletor.idColetor = '${coletor.id}';
            coletor.idColeta = '${coletor.coleta.id}';
            coletor.idUsuario = '${coletor.usuario.idusuario}';
            coletor.nomeUsuario = '${coletor.usuario.nome}';
            coletor.codigo = '${coletor.etiqueta}';                    

            addColetor(coletor);

        </c:forEach>
            
        idUsuario = '<c:out value="${param.idUsuario}"/>';
        nomeUsuario = '<c:out value="${param.nomeUsuario}"/>';
        
    }
    
    function getBipagem(){
        
        var codigoBarras = $("codigoBarras").value;          
        var idColeta = $("idColeta").value;
        var tipoOperacao = $("tipoOperacao").value;

        if (codigoBarras == "") {
            showErro("Informe o código de barras",$("codigoBarras"));
            return false;
        }
                
        jQuery.ajax({
            url: '<c:url value="/ConferenciaControlador" />',
            dataType: "text",
            method: "post",
            data: {
                idUsuario : idUsuario,
                tipoOperacao : tipoOperacao,               
                idColeta : idColeta,            
            codigoBarras: codigoBarras,
            acao: "getBipagemColeta"
        },
        success: function (data) {

                var conf = JSON.parse(data);

                console.log(conf);

                var coletor = new DadosColetor();

                if (conf != null && conf != undefined && conf.null != "") {

                    if (conf.Conferencia.id != 0) {
                        coletor.idColetor = conf.Conferencia.id;
                        coletor.idUsuario = idUsuario;
                        coletor.nomeUsuario = nomeUsuario;
                        coletor.idColeta = conf.Conferencia.coleta.id;
                        coletor.codigo = conf.Conferencia.codigoBarras;

                    } else {
                        coletor.idUsuario = 0;
                        coletor.nomeUsuario = conf.Conferencia.mensagemRetorno;
                        coletor.codigo = codigoBarras;
                    }

                } else {
                    coletor.idUsuario = 0;
                    coletor.nomeUsuario = "Código de barras não pertence a essa coleta";
                    coletor.codigo = codigoBarras;
                }

                addColetor(coletor);

                if (coletor.idUsuario == 0) {
                    alert("Atenção: " + coletor.nomeUsuario);
                }

                $("codigoBarras").value = "";
            }
        });
    }
    
    function DadosColetor(idColetor, idColeta, idUsuario, nomeUsuario, codigo){
        this.idColetor = (idColetor != null || idColetor != undefined ? idColetor : 0);
        this.idColeta = (idColeta != null || idColeta != undefined ? idColeta : 0);
        this.idUsuario = (idUsuario != null || idUsuario != undefined ? idUsuario : 0);
        this.nomeUsuario = (nomeUsuario != null || nomeUsuario != undefined ? nomeUsuario : "");
        this.codigo = (codigo != null || codigo != undefined ? codigo : 0);                
    }    
    
    var countColetor=0;
    function addColetor(coletor){

        if(coletor == null || coletor == undefined){
            coletor = new DadosColetor();
        }

        countColetor++;
                
        var _trColetor = Builder.node("tr",{
            id:"trColetor_"+countColetor,
            name:"trColetor_"+countColetor,
            className:"CelulaZebra2"
        });

        var _tdCodigo = Builder.node("td",{
            id:"tdCodigo_"+countColetor,
            name:"tdCodigo_"+countColetor,
            className:"CelulaZebra2"
        });

        var _tdUsuario = Builder.node("td",{
            id:"tdUsuario_"+countColetor,
            name:"tdUsuario_"+countColetor,
            className:"CelulaZebra2"
        });

//        var _tdExcluir = Builder.node("td",{
//            id:"tdExcluir_"+countColetor,
//            name:"tdExcluir_"+countColetor,
//            className:""
//        });

        var _lblCodigo = Builder.node("label",{
            id:"lblCodigo_" + countColetor,
            name:"lblCodigo_" + countColetor
        });                
        _lblCodigo.innerHTML = coletor.codigo;

        if (coletor.idUsuario == 0) {
            _lblCodigo.style.color = "red";
        }

        var _lblUsuario = Builder.node("label",{
            id:"lblUsuario_" + countColetor,
            name:"lblUsuario_" + countColetor
        });                
        _lblUsuario.innerHTML = coletor.nomeUsuario;
                
        if (coletor.idUsuario == 0) {
            _lblUsuario.style.color = "red";
        }

        var _inpIdUsuario = Builder.node("input",{
            id:"idUsuario_"+countColetor,
            name:"idUsuario_"+countColetor,
            type:"hidden",
            valeu:coletor.idUsuario
        });

//        var _imgExcluir = Builder.node("img",{
//            className:"imagemLink",
//            src:"img/lixo.png",
//            width:"20px",
//            ridth:"40px",
//            onclick:"javascript:excluirBipagem("+countColetor+")"
//        });
//                
//        var _divExcluir = Builder.node("div",{
//            align:"center"
//        });

        var _inpIdColetor = Builder.node("input",{
            id:"idColetor_"+countColetor,
            name:"idColetor_"+countColetor,
            type:"hidden",
            value:coletor.idColetor
        });

//        _divExcluir.appendChild(_imgExcluir);

        _tdCodigo.appendChild(_lblCodigo);
        _tdCodigo.appendChild(_inpIdColetor);
        _tdUsuario.appendChild(_lblUsuario);
        _tdUsuario.appendChild(_inpIdUsuario);
//        _tdExcluir.appendChild(_divExcluir);

        _trColetor.appendChild(_tdCodigo);
        _trColetor.appendChild(_tdUsuario);
//        _trColetor.appendChild(_tdExcluir);               

        $("tbColetor").appendChild(_trColetor);
    }
    
    
    
</script>
<style>
    .btn {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 25px;
        border: 1px solid #003366;
        background-color:#2E76A6;
        color:#FFFFFF;
        cursor: pointer;
        border-radius: 3px;
    }
    
    .inp {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 25px;       
        cursor: pointer;
        border-radius: 3px;
    }
    
    .inpReadOnly8pt{ 
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 25px;
        border: 1px solid #003366;
        background-color: #cccccc;  
        border-radius: 3px;
    }
    
    .bordaFina{
        border: 1px solid #003148;
        border-radius: 3px;
    }
    .tabela {
        margin: 0px;
        font-size: 25px;
        background-color:#cccccc; 
        color:#000000;
        border-radius: 3px;
    }
    
    .CelulaZebra2{
        color: #000000;
        background-color:#DBE9F1;
        text-align:left;
        font:20px Verdana, Arial, Helvetica, sans-serif;        
        border-radius: 3px;
    }
    
    .CelulaZebra1{
        color: #000000;
        background-color:#7FB2CC;
        text-align: left;
        font:20px Verdana, Arial, Helvetica, sans-serif;        
        border-radius: 3px;
    }
    
</style>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <!--<meta name="viewport" content="user-scalable=no">-->
        <meta name="viewport" content="width=device-width, user-scalable=no">
        <!--<link rel="stylesheet" href="estilo.css" type="text/css">-->        
        <title>Importação de conferência (Coleta)</title>
    </head>
    <body onload="carregar();">
        <div align="center">
            <img alt="" src="img/banner.gif" align="middle">            
        </div>
        <br/>
        <table width="100%" align="center" class="bordaFina">
            <tr>
                <td align="center">
                    <b>Conferência Coleta ( Carregamento )</b>
                </td>                
            </tr>
        </table>
        <br/>
        <table width="100%" align="center" class="bordaFina">
            <tr class="tabela">
                <td align="center"> Coleta  </td>
            </tr>
            <tr>
                <td class="CelulaZebra2">
                    Nº Coleta
                </td>                   
            </tr>
            <tr>
                <td class="CelulaZebra2">                    
                    <input type="text" id="numeroColeta" name="numeroColeta" value="${param.numeroColeta}" class="inpReadOnly8pt" size="5" readonly/>
                    <input type="hidden" name="idColeta" id="idColeta" value="${param.idColeta}" />
                    <input type="hidden" name="tipoOperacao" id="tipoOperacao" value="${param.tipoOperacao}" />
                </td>                   
            </tr>
            <tr>
                <td class="CelulaZebra2">
                    Código de Barras
                </td>                   
            </tr>
            <tr>
                <td class="CelulaZebra2">                    
                    <input type="text" id="codigoBarras" name="codigoBarras" value="" class="inp" size="20" onKeyUp="javascript:if (event.keyCode==13) $('btnPesquisar').click();"/>
                </td>                   
            </tr>            
        </table>
        <br/>
        <table width="100%" align="center" class="bordaFina">
            <tr>
                <td class="CelulaZebra2">
                    <div align="center">
                        <input type="button" id="btnPesquisar" name="btnPesquisar" value="Pesquisar" class="btn" onclick="javascript:tryRequestToServer(function(){getBipagem();});"/>
                    </div>
                </td>
            </tr>
        </table>
        <br/>
        <table width="100%" align="center" class="bordaFina">
            <tbody id="tbColetor">
                <tr class="CelulaZebra1">
                    <td>
                        <b>Código</b>
                    </td>
                    <td>                                        
                        <b>Usuário</b> 
                    </td>                                                  
                </tr>
            </tbody>
        </table>
    </body>
</html>
