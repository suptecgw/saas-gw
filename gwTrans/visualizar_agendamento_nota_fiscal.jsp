<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>

<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    var ctrcAux = '0';
    var zebraAux = '1'
    var idxOco = 0;

    shortcut.add("Alt+V",function() {visualizarNF();});
  
    function localizaRemetenteCodigo(campo, valor){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if(resp == ''){
                $('idremetente').value = '0';
                $('rem_cnpj').value = '';
                $('rem_rzs').value = '';

                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');
                $('idremetente').value = cliControl.idcliente;
                $("idclienteV").value  = $("idremetente").value;
                $('rem_cnpj').value = cliControl.cnpj;
                $('rem_rzs').value = cliControl.razao;
            }
        }//funcao e()
        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
    }
  
    function aoClicarNoLocaliza(idJanela)  {
        if (idJanela == "Remetente") {
            $("idclienteV").value  = $("idremetente").value;
        }
    }
  
    function visualizarNF(){
        try {
            var form = $("formulario");
            
            tryRequestToServer(function(){
                form.submit();
            });   
        } catch (e) { 
            alert(e);
        }

    }
    
    function localizaRemetenteCodigo(campo, valor){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if(resp == ''){
                $('idremetente').value = '0';
                $('rem_cnpj').value = '';
                $('rem_rzs').value = '';

                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');
                $('idremetente').value = cliControl.idcliente;
                $('rem_cnpj').value = cliControl.cnpj;
                $('rem_rzs').value = cliControl.razao;
            }
        }//funcao e()
        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
    }

    function localizaDestinatarioCodigo(campo, valor){
        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport){
            var resp = transport.responseText;
            espereEnviar("",false);
            //se deu algum erro na requisicao...
            if (resp == 'null'){
                alert('Erro ao localizar cliente.');
                return false;
            }else if(resp == ''){
                $('iddestinatario').value = '0';
                $('dest_cnpj').value = '';
                $('dest_rzs').value = '';
                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")){
                    window.open('./cadcliente?acao=iniciar','Cliente','top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            }else{
                var cliControl = eval('('+resp+')');
                $('iddestinatario').value = cliControl.idcliente;
                $('dest_cnpj').value = cliControl.cnpj;
                $('dest_rzs').value = cliControl.razao;
            }
        }//funcao e()
        if (valor != ''){
            espereEnviar("",true);
            tryRequestToServer(function(){
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor="+valor+"&idfilial=0&campo="+campo,{method:'post', onSuccess: e, onError: e});
            });
        }
    }

    function setValorConsulta(obj, tamanhoPadrao){
        if (obj.value == null || obj.value == ""){
            obj.value = tamanhoPadrao;
        }
    }

    function setDefault(){
        $("dtInicial").value = '${param.dataDe}';
        $("dtFinal").value = '${param.dataAte}';  
      
        var tipoFiltro = '<%=(request.getParameter("campoConsulta") != null ? request.getParameter("campoConsulta").trim() : "0")%>';

        if (tipoFiltro == "c.idcliente"){
            $("campoConsulta4").checked = true;
        }else if (tipoFiltro == "s.numero"){
            $("campoConsulta3").checked = true;
        }else if (tipoFiltro == "n.numero"){
            $("campoConsulta2").checked = true;
        }else{
            $("campoConsulta1").checked  = true;
        }
    }

    function fechar(){
        window.close();
    }

    function validaDatas(dtEmissao,id){
        var dataAtual = '${param.dataDe}';
        dataAtual = new Date(dataAtual.substring(6,10),dataAtual.substring(3,5)-1,dataAtual.substring(0,2));
        var dataEmissao = new Date(dtEmissao.substring(6,10),dtEmissao.substring(3,5)-1,dtEmissao.substring(0,2));
        var dataEntrega = new Date($('dtfechamento_'+id).value.substring(6,10),$('dtfechamento_'+id).value.substring(3,5)-1,$('dtfechamento_'+id).value.substring(0,2));
        var dataChegada = new Date($('dtchegada_'+id).value.substring(6,10),$('dtchegada_'+id).value.substring(3,5)-1,$('dtchegada_'+id).value.substring(0,2));

        if ($('dtchegada_'+id).value != ''){
            if (dataChegada.getTime() < dataEmissao.getTime()){
                alert('A data de chegada não pode ser inferior a data de emissão.');
                $('dtchegada_'+id).value = '';
            }else if(dataChegada.getTime() > dataAtual.getTime()){
                alert('A data de chegada não pode ser superior a data atual.');
                $('dtchegada_'+id).value = '';
            }
        }
        if ($('dtfechamento_'+id).value != ''){
            if (dataEntrega.getTime() < dataEmissao.getTime()){
                alert('A data de entrega não pode ser inferior a data de emissão.');
                $('dtfechamento_'+id).value = '';
            }else if (dataEntrega.getTime() < dataChegada.getTime()){
                alert('A data de entrega não pode ser inferior a data de chegada.');
                $('dtfechamento_'+id).value = '';
            }else if (dataEntrega.getTime() > dataAtual.getTime()){
                alert('A data de entrega não pode ser superior a data atual.');
                $('dtfechamento_'+id).value = '';
            }
        }
    }
    
    function Agendar(i, tipo){
        var dt = $("dtAgendamento_" + i).value;
        var h = $("hAgendamento_" + i).value;
        var id = $("idnotafiscal_" + i).value;
        var obs = $("observacao_" + i).value;
        var nomec = $("nomeContato_" + i).value;
        var fonec = $("foneContato_" + i).value;
      
      
        function sucesso(transport){
            var textoResposta = transport.responseText;
            if(textoResposta == "true" ){
                alert('Agendamento realizado com sucesso!');
                $('visualizar').click();
            }else{
                alert('Something went wrong...');
            }    
        }
      
        function fracasso(){
            alert('Something went wrong...');
        }
      
        if(dt.length != 0 && h.length != 0){
            var t = "AgendamentoControlador?acao=cadastrar&tipo="+tipo+"&idnotafiscal=" + id + "&dtAgendamento=" + dt +
                "&hAgendamento=" + h + "&observacao=" + obs + "&foneContato=" + fonec + "&nomeContato=" + nomec;
         
         
            tryRequestToServer(function(){
                new Ajax.Request(t, {method:'get',onSuccess: sucesso,onError: fracasso});
            });               
        }else{
            alert("Para lançar um Agendamento é necessário informar Data e Hora!");
        }
    }
  
    function excluirAgendamento(index){
        var id = $("idnotafiscal_" + index).value;
        var data = $("dtAgendamento_"+index).value;
        var hora = $("hAgendamento_"+index).value;
        var obs = $("observacao_"+index).value; 
        var nomec = $("nomeContato_" + index).value;
        var fonec = $("foneContato_" + index).value;
        
        if(confirm("Deseja excluir esse agendamento ?")){
            if(confirm("Tem certeza?")){
                    
                if (index != 0) {
                    tryRequestToServer(function(){new Ajax.Request("AgendamentoControlador?acao=excluir&idnotafiscal="+id+"&dtAgendamento=" + data + "&hAgendamento=" + hora + "&observacao=" + obs + "&nomeContato=" + nomec + "&foneContato=" + fonec,
                        {
                            method:'get',
                            onSuccess: function(){ alert('Agendamento removido com sucesso!') 
                                $("hAgendamento_" + index).value = ""
                                $("dtAgendamento_" + index).value = ""
                                $("observacao_" + index).value = ""
                                $("nomeContato_" + index).value = ""
                                $("foneContato_" + index).value = ""},
                            onFailure: function(){ alert('Something went wrong...') }
                        });     
                    });}
                     
            }
        }
    }
  
  
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Agendamento Nota Fiscal</title>
        <LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
        <style type="text/css">
            <!--
            .styleVermelho {color: #FF0000}
            .styleAzul {color: #0000FF}
            -->
        </style>
    </head>

    <body onLoad="setDefault()">
        <div align="center">
            <img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idnotafiscal" id="idnotafiscal" value="">
        </div>
        <table width="100%" height="28" align="center" class="bordaFina" >
            <tr>
                <td width="86%" height="22">
                    <b>Agendamento Nota Fiscal</b>
                </td>
                <td width="14%">
                    <b>
                        <input  name="idremetente" id="idremetente" type="hidden" value="Fechar" >
                        <input  name="Button" type="button" class="botoes" value="Fechar" onClick="fechar()">
                    </b>
                </td>
            </tr>
        </table>

        <br>
        <form action="AgendamentoControlador?acao=listar" id="formulario" name="formulario" method="post">

            <table width="100%" border="0" class="bordaFina" align="center">
                <tr class="tabela">
                    <td height="18" colspan="10">
                        <div align="center">Filtros</div>
                    </td>
                </tr>
                <tr>
                    <td width="12%" class="TextoCampos">
                        <input name="campoConsulta" type="radio" id="campoConsulta1" value="emissao">
                        <label>Emiss&atilde;o Entre</label>
                    </td>
                    <td width="18%" class="CelulaZebra2">
                        <strong>
                            <input name="dtInicial" type="text" id="dtInicial" value="" size="11" maxlength="10"
                                   class="fieldDateMin" onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event); if (event.keyCode==13) visualizarNF()" />
                        </strong>
                        e
                        <strong>
                            <input name="dtFinal" type="text" id="dtFinal" value="" size="11" maxlength="10"
                                   class="fieldDateMin" onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event); if (event.keyCode==13) visualizarNF()" />
                        </strong>
                    </td>
                    <td width="7%" class="TextoCampos">
                        <input name="campoConsulta" type="radio" id="campoConsulta2" value="n.numero">
                        N&ordm; NF:
                    </td>
                    <td width="7%" class="CelulaZebra2">
                        <strong>
                            <input name="numero" type="text" id="numero" value="" class="fieldMin"
                                   size="8" maxlength="13" onKeyPress="javascript:if (event.keyCode==13) visualizarNF()">
                        </strong>
                    </td>
                    <td width="11%" class="TextoCampos">
                        <input name="campoConsulta" type="radio" id="campoConsulta3" value="s.numero">
                        N&ordm; CT/NFS:
                    </td>
                    <td width="6%" class="CelulaZebra2">
                        <strong>
                            <input name="ctrc" type="text" id="ctrc" value="" size="8" class="fieldMin" maxlength="12">
                        </strong>
                    </td>
                    <td class="TextoCampos">
                        <input name="campoConsulta" type="radio" id="campoConsulta4" value="c.idcliente">    
                        Remetente:
                    </td>
                    <td colspan="3" class="CelulaZebra2">
                        <strong>
                            <input name="idclienteV" type="hidden" id="idclienteV" size="10" value="<%=(request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "")%>"
                                   onKeyUp="javascript:localizaRemetenteCodigo('idcliente', this.value)" class="inputReadOnly8pt">


                            <input name="rem_cnpj" type="text" id="rem_cnpj" size="10" value="<%=(request.getParameter("rem_cnpj") != null ? request.getParameter("rem_cnpj") : "")%>"
                                   onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('cnpj', this.value)" class="inputReadOnly8pt" readonly="">

                            <input name="rem_rzs" type="text" id="rem_rzs" value="<%=(request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "")%>" 
                                   size="16" maxlength="80" onKeyUp="javascript:if (event.keyCode==13) localizaRemetenteCodigo('c.razaosocial', this.value)" class="inputReadOnly8pt" readonly="">

                            <input name="localiza_rem2" type="button" class="botoes" id="localiza_rem2" value="..." onClick="launchPopupLocate('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Remetente')">

                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar cliente" onClick="javascript:getObj('rem_rzs').value = '';getObj('idremetente').value = '0';getObj('rem_cnpj').value = '';">
                        </strong>
                    </td>
                </tr>
                <tr>
                    <td colspan="10" class="TextoCampos">
                        <div align="center">
                            <input name="visualizar" type="button" class="botoes" id="visualizar" value="   Visualizar [Alt+V]  " onClick="visualizarNF();">
                        </div>
                    </td>
                </tr>
            </table>
        </form>
        <form method="post" id="formBx" >
            <table width="100%" border="0" class="bordaFina">
                <tr class="tabela">
                    <td width="10%"></td>
                    <td width="35%"><strong></strong></td>
                    <td width="17%">Agendamento</td>
                    <td width="24%">Observa&ccedil;&atilde;o</td>
                    <td width="2%"><strong></strong></td>
                    <td width="17%"><strong></strong></td>
                </tr>
                <c:forEach var="notas" varStatus="status" items="${listaAgendamento}">
                    <tr class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}">
                        <td align="left">
                            <b>NF:</b>${notas.nota}/${notas.serie}<br>
                            <b>${notas.categoriaConhecimento}</b>${notas.numeroConhecimento}<br>
                            <b>Peso:</b><script>document.write(colocarVirgula(${notas.peso}))</script><br>
                            <b>Vol(s):</b><script>document.write(colocarVirgula(${notas.volume}))</script>
                        </td>
                        <td style="display: none"><input type="hidden" name="idnotafiscal_${status.count}" id="idnotafiscal_${status.count}" value='${notas.id}'></td> 
                        <td><b>Remetente:</b>${notas.remetente.razaosocial}<br>
                            <b>Destinatário:</b>${notas.destinatario.razaosocial}<br>
                            <b>Endereço:</b>${notas.destinatario.endereco}<br>
                            ${notas.destinatario.bairro} - ${notas.destinatario.cidade.descricaoCidade}-${notas.destinatario.cidade.uf}<br>
                            ${notas.destinatario.cnpj}<br>
                            ${notas.destinatario.fone}
                        </td>
                        <td class="${(status.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}" align="center">
                            <font size="1">Data:
                                <input name="dtAgendamento_${status.count}" id="dtAgendamento_${status.count}"
                                       class="fieldDateMin" value='${notas.agenda}' type="text" size="9" style="font-size:8pt;"  maxlength="10" align="Right"
                                       onblur="alertInvalidDate(this, true);validaDatas();" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />

                                <br>Hora:
                                <input name="hAgendamento_${status.count}" type="text" id="hAgendamento_${status.count}" style="font-size:8pt;" class="fieldMin"
                                       onkeyup="mascaraHora(this)" size="4" maxlength="5"  value='${notas.hora}'/>
                                <br>
                                Contato:
                                <input name="nomeContato_${status.count}" type="text" id="nomeContato_${status.count}" style="font-size:8pt;"
                                       size="12" maxlength="50"  value='${notas.nomeContato}' class="fieldDateMin"/>
                                <br>
                                Fone:
                                <input name="foneContato_${status.count}" type="text" id="foneContato_${status.count}" style="font-size:8pt;"
                                       size="12" maxlength="12"  value='${notas.foneContato}' class="fieldDateMin" />
                            </font>
                        </td>
                        <td>
                            <textarea name="observacao_${status.count}" id="observacao_${status.count}" style="font-size:8pt;" class="fieldMin" cols="35" rows="3" ><c:out value="${notas.observacao}"/></textarea>
                        </td>    
                        <td>
                            <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Agendamento" onClick="excluirAgendamento(${status.count});"></strong>  
                        </td>
                        <td align="center">
                            <input align="center" name="agendar" type="button" class="botoes" id="agendar" value="Agendar NF" onClick="Agendar(${status.count},'nf')">
                            <br><br>
                            <input align="center" name="agendar" type="button" class="botoes" id="agendar" value="Agendar CT" onClick="Agendar(${status.count},'ct')">
                        </td>
                    </tr>
                </c:forEach>
            </table>
            <br>
        </form>
    </body>
</html>