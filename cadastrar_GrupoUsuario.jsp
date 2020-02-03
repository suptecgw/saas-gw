<%-- 
    Document   : cadastrar_GrupoUsuario
    Created on : 19/11/2008, 10:21:10
    Author     : Vladson Pontes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">


<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="${homePath}/gwTrans/cadastros/js/underscore-min.js?v=${random.nextInt()}"></script>


<script type="text/javascript">    
        jQuery.noConflict();
        var homePath = "${homePath}"; 
        
    function setDefault(){
        
        var action = '<c:out value="${param.acao}"/>';
        if(action == 1){
            document.formulario.filial.value = '<c:out value="${autenticado.filial.id}"/>';
            
            carregarPermissoes();
        }else{
            
            if (${param.nivel == 4}) {
                    var form = document.formulario;
                    var data = '${dataAtual}';
                    form.dataDeAuditoria.value = data;
                    form.dataAteAuditoria.value = data;
                }
            
            document.formulario.filial.value = '<c:out value="${grupoCadGrupo.filial.id}"/>';
            document.formulario.descricao.value = '<c:out value="${grupoCadGrupo.descricao}"/>';
        }

        document.formulario.descricao.focus();
        
    }
    
    function carregarPermissoes(){         
        
        var idFilial = document.formulario.filial.value;
        new Ajax.Request('GrupoUsuarioControlador?acao=carregarPermissoes&idFilial=' + idFilial,
        {
            method:'get',
            onSuccess: function(transport){
                var response = transport.responseText;                
                resposta = response;
                carregaAjax(resposta);  
                
            },
            onFailure: function(){ alert('Something went wrong...') }
        });
    }

    function carregaAjax(resposta){
                
        var tabela = document.getElementById("tdConteudo");        
        Element.update(tabela, resposta);
        
    }
    
    
    function checaPerms(){
        if(document.formulario.ultimoId == null)
            return false;
        var max = document.formulario.ultimoId.value;  
        var nivel;
        var perms = false;                
        for(var i = 1; i <= max; i++){  
            if(document.getElementById("hd"+i) != null){
                nivel = document.getElementById("nv"+i).value;
                if(nivel > 0 ){
                    perms = true;
                    return perms;
                }                    
            }              
        }
        return perms;
        
    }

    function voltar(){
        window.location = "ConsultaControlador?codTela=61";
    }
    
    function salvar(){
        var formu = document.formulario;
              
        if(formu.descricao.value == ""){
            alert("O campo 'Descricão' não pode ficar em branco!");            
            formu.descricao.focus();
            return false;          
        }
        
        
        if(!checaPerms()){
            alert("Selecione no mínimo uma permissão!");
            return  false;
        }
       
        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');
        
        formu.submit();  
    }

    function stAba(menu,conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    //carregar os Grupos de usuario desta nova filial escolhida.
    function carregarGrupos(){
    
    }
    
    function carregarPermissoesGrupos(grupo){
        jQuery('#usuariosSemGrupo').val('--');

        if (grupo && grupo !== '--') {
            var idFilial = document.formulario.filial.value;
            new Ajax.Request('GrupoUsuarioControlador?acao=carregarGrupoPermissoes&idGrupo=' + grupo + "&idFilial=" + idFilial,
                {
                    method: 'get',
                    onSuccess: function (transport) {
                        var response = transport.responseText;
                        var resposta = response;
                        carregaAjax(resposta);

                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
        }
    }
    
         //iniciando asbas ..
    function stAbaa(menu, conteudo) {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    var arAbasGenerico = new Array();

    arAbasGenerico[0] = new stAbaa('tdAuditoria', 'divAuditoria');
    
    function pesquisarAuditoria() {
        var countLog;
        for (var i = 1; i <= countLog; i++) {
            if ($("tr1Log_" + i) != null) {
                Element.remove(("tr1Log_" + i));
            }
            if ($("tr2Log_" + i) != null) {
                Element.remove(("tr2Log_" + i));
            }
        }
        countLog = 0;
        var rotina = "grupoUsuario";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = $("idGrupo").value;
        consultarLog(rotina, id, dataDe, dataAte);
    }

        function carregarPermissoesUsuario(usuarioId) {
            jQuery('#gruposUsuario').val('--');

            if (usuarioId && usuarioId !== '--') {
                jQuery.get('${homePath}/GrupoUsuControlador', {
                    'acao': 'carregarPermissoesUsuario',
                    'usuarioId': usuarioId,
                    'filialId': $('filial').value
                }, function (data) {
                    if (data && data.length > 0) {
                        var tabelaConteudo = jQuery('#tdConteudo');

                        tabelaConteudo.empty();

                        var div = jQuery('<div>', {
                            'id': 'webtrans',
                            'class': 'conteudo'
                        });

                        var tabela = jQuery('<table>', {
                            'class': 'bordaFina',
                            'width': '100%'
                        });

                        var tbody = jQuery('<tbody>');

                        // Agrupar por categorias
                        jQuery.each(_.groupBy(data, 'categoria'), function () {
                            tbody.append(jQuery('<tr>', {
                                'class': 'celula'
                            }).append(jQuery('<td>', {'colspan': '4'}).text(this[0].categoria)));

                            var permissoesEmGrupoDeDois = _.chunk(this, 2);

                            jQuery.each(permissoesEmGrupoDeDois, function () {
                                var trPermissao = jQuery('<tr>');
                                var tamanhoTr = this.length;

                                jQuery.each(this, function (index) {
                                    var select = jQuery('<select>', {
                                        'name': 'nv' + this.id,
                                        'id': 'nv' + this.id,
                                        'class': 'inputtexto'
                                    });

                                    var opcoes = [];

                                    if (this.tipo === 'NV') {
                                        opcoes[0] = jQuery('<option>', {
                                            'class': 'opCor0',
                                            'value': '0'
                                        }).text('Sem acesso');
                                        opcoes[1] = jQuery('<option>', {
                                            'class': 'opCor1',
                                            'value': '1'
                                        }).text('Ler');
                                        opcoes[2] = jQuery('<option>', {
                                            'class': 'opCor2',
                                            'value': '2'
                                        }).text('Ler, alterar');
                                        opcoes[3] = jQuery('<option>', {
                                            'class': 'opCor3',
                                            'value': '3'
                                        }).text('Ler, alterar, incluir');
                                        opcoes[4] = jQuery('<option>', {
                                            'class': 'opCor4',
                                            'value': '4'
                                        }).text('Controle total');
                                    } else {
                                        opcoes[0] = jQuery('<option>', {
                                            'class': 'opCor0',
                                            'value': '0'
                                        }).text('Sem acesso');
                                        opcoes[1] = jQuery('<option>', {
                                            'class': 'opCor4',
                                            'value': '4'
                                        }).text('Com acesso');
                                    }

                                    for (var i = 0; i < opcoes.length; i++) {
                                        select.append(opcoes[i]);
                                    }

                                    select.val(this.nivel);

                                    trPermissao.append(jQuery('<td>', {
                                        'class': 'CelulaZebra2',
                                        'width': '35%'
                                    }).text(this.descricao)
                                        .append(jQuery('<input>', {
                                        'type': 'hidden',
                                        'id': 'hd' + this.id,
                                        'name': 'hd' + this.id,
                                        'value': this.id
                                    })));

                                    trPermissao.append(jQuery('<td>', {
                                        'class': 'CelulaZebra2',
                                        'width': '15%'
                                    }).append(select));
                                });

                                if (tamanhoTr == 1) {
                                    trPermissao.append(jQuery('<td>', {
                                        'class': 'CelulaZebra2',
                                        'colspan': '2'
                                    }));
                                }

                                tbody.append(trPermissao);
                            });
                        });

                        tabela.append(tbody);
                        div.append(tabela);
                        tabelaConteudo.append(div);
                        tabelaConteudo.append(jQuery('<input>', {
                            'type': 'hidden',
                            'id': 'ultimoId',
                            'name': 'ultimoId',
                            'value': data[0].ultimoId
                        }));
                    }
                }, 'json');
            }
        }
</script>
<html>
    <style>

        body, table {
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            color: #000000;
        }

        .menu {

            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-weight: normal;
            color: #000033;
            background-color: #FFFFFF;
            border-right: 1px solid #000000;
            border-left: 1px solid #000000;
            border-top: 1px solid #000000;
            border-bottom: 1px solid #000000;
            padding: 5px;
            cursor: hand;
        }

        .menu-sel {
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-weight: bold;
            color: #000033;
            background-color: #CCCCCC;
            border-right: 1px solid #000000;
            border-left: 1px solid #000000;
            border-top: 1px solid #000000;
            padding: 5px;
            cursor: hand;
        }

        .tb-conteudo {
            border-right: 1px solid #000000;
            border-bottom: 1px solid #000000;
        }

        .conteudo {
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-weight: normal;
            color: #000033;
            background-color: #F7F7F7;

            width: 100%;
            height: 100%;

        }

    </style>
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
        <title>gWeb - Cadastro de Grupos de Usuários</title>
    </head>
    <body onload="setDefault();AlternarAbasGenerico('tdAuditoria', 'divAuditoria');carregarPermissoesGrupos(${param.idGrupo})" >        
        <img src="img/banner.gif" width="40%" height="44" align="middle"> 
        <table class="bordaFina" width="95%" align="center">
            <tr>
                <td width="82%" align="left"><span class="style4">Cadastro de Grupos de Usu&aacute;rios</span></td>  
                <td><input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/></td>
            </tr>
        </table>
        <br>

        <c:choose>
            <c:when test="${param.acao == 2}">

                <form action="GrupoUsuarioControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
                    <table width="95%" class="bordaFina" align="center">
                        <tr>
                            <td colspan="4" align="center" class="tabela">Dados principais
                                <input type="hidden" name="modulo" id="modulo" value="gWeb"/>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%" class="TextoCampos">Filial</td>
                            <td width="35%" class="CelulaZebra2"><b> <c:out value="${grupoCadGrupo.filial.abreviatura}"/> </b> <input type="hidden" name="idGrupo" id="idGrupo" value="${grupoCadGrupo.id}"></input></td>
                            <td width="15%" class="TextoCampos">Descri&ccedil;&atilde;o</td>
                            <td width="35%" class="CelulaZebra2"><input name="descricao" type="text" class="inputtexto" id="descricao" maxlength="50"/></td>
                            <input type="hidden" name="filial" id="filial" value="">
                        </tr>


                    </c:when>
                    <c:otherwise>

                        <form action="GrupoUsuarioControlador?acao=cadastrar" id="formulario" name="formulario" method="post" target="pop">


                            <table width="95%" class="bordaFina" align="center">
                                <tr>
                                    <td colspan="4" align="center" class="tabela">Dados principais
                                        <input type="hidden" name="modulo" id="modulo" value="gWeb"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="15%" class="TextoCampos">Filial</td>
                                    <td width="35%" class="CelulaZebra2">
                                        <select   name="filial" class="inputtexto" id="filial"  onblur="carregarPermissoes();" >
                                            <option value="">-Selecione uma Filial-</option>
                                            <c:forEach var="filial" items="${filiaisCadGrupo}">
                                                <option value="${filial.id}">${filial.abreviatura}</option>
                                            </c:forEach>
                                        </select>
                                    </td>
                                    <td width="15%" class="TextoCampos">Descri&ccedil;&atilde;o</td>
                                    <td width="35%" class="CelulaZebra2"><input name="descricao" type="text" class="inputtexto" id="descricao" maxlength="50"/></td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        <tr>
                            <td class="TextoCampos" colspan="2">
                               Copiar permissões de outro grupo de usuário : 
                            </td>            
                            <td class="celulaZebra2" colspan="2" align="left">
                                <SELECT class="inputTexto" onchange="carregarPermissoesGrupos(this.value);" id="gruposUsuario" name="gruposUsuario">
                                    <OPTION value="--">
                                        Escolha um Grupo de Usuario
                                    </OPTION>
                                    <c:forEach items="${listaGrupos}" var="gru" varStatus="status">
                                        <OPTION value="${gru.id}">
                                            ${gru.descricao}
                                        </OPTION>
                                    </c:forEach>
                                </SELECT>
                            </td>            
                        </tr>
                        <tr>
                            <td class="TextoCampos" colspan="2">
                                Copiar permissão de um usuário que não pertence a um grupo:
                            </td>
                            <td class="celulaZebra2" colspan="2" align="left">
                                <select class="inputTexto" onchange="carregarPermissoesUsuario(this.value);"
                                        id="usuariosSemGrupo" name="usuariosSemGrupo">
                                    <option value="--">
                                        Escolha um Usuário
                                    </option>
                                    <c:forEach items="${listaUsuariosSemGrupo}" var="usu" varStatus="status">
                                        <option value="${usu.id}">${usu.nome}</option>
                                    </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4" align="center" class="tabela">Permissões</td>
                        </tr>

                        <tr>
                            <td colspan="6">
                                <table class="bordaFina" width="100%">
                                   <tr>
                                        <td class="tb-conteudo" id="tdConteudo" colspan="8">
                                            
                                        </td>
                                    </tr>


                                </table>
                            </td>
                        </tr>

                          <tr>
                        <td>
                            <table width="10%">

                                <td style='display: ${param.acao == '2' && param.nivel == 4 ? "" : "none"}' class="menu" id="tdAuditoria"
                                    onClick="AlternarAbasGenerico('tdAuditoria', 'divAuditoria')">
                                    Auditoria
                                </td>
                            </table>
                        </td>
                    </tr>
                
                    <c:if test="${param.acao == '2'}">
                        <tr>
                            <td width="100%" class="celulaZebra2" colspan="4">
                                <table width="100%" >
                                    <tr>
                                        <td>
                                            <c:if test="${param.nivel == 4}">
                                                <div id="divAuditoria" width="80%" >
                                                    <table colspan="3" width="100%" align="center" cellpadding="1" cellspacing="1" class="bordaFina" id="tableAuditoria">
                                                        <%@include file="/gwTrans/template_auditoria.jsp" %>
                                                    </table>
                                                </div> 
                                            </c:if>               
                                        </td>    
                                    </tr>

                                    <tr>
                                        <td width="100%" class="celulaZebra2" >
                                            <fieldset >
                                                <table class="tabelaZerada">
                                                    <tr class="CelulaZebra2">
                                                        <td class="TextoCampos" width="14%"> Incluso:</td>
                                                        <td width="35%"> 
                                                            em: ${grupoCadGrupo.criadoEm} <br>
                                                            por: ${grupoCadGrupo.criadoPor}              
                                                        </td>
                                                        <td class="TextoCampos" width="15%"> Alterado:</td>
                                                        <td width="36%"> 
                                                            em: ${grupoCadGrupo.atualizadoEm} <br>
                                                            por: ${grupoCadGrupo.atualizadoPor}                                
                                                        </td>
                                                    </tr>   
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>   
                                </table>
                            </td>
                        </tr>
                    </c:if>
                                <table width="95%" align="center" class="bordaFina"> 
                                    <br>
                                        <c:if test="${param.nivel >= param.bloq}">
                                            <tr>
                                                <td colspan="6" class="CelulaZebra2" >
                                                    <div align="center">
                                                        <input type="button" onclick="salvar()" id="botSalvar" value="  SALVAR  " class="inputbotao" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:if>
                                </table>        
                                                     
                </form>
            </table>
    </body>
</html>
