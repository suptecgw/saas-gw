<%@page import="nucleo.BeanLocaliza"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.*,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio" %>

<%  //ATENCAO! A MSA está abaixo
    // DECLARANDO e inicializando as variaveis usadas no JSP

    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null) {
        response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
    }
    // -- FIM DO MSA
    int nivelUserCTRC = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);

    BeanConsultaConhecimento conCon = null;
    String acao = request.getParameter("acao");
    String marcados = (request.getParameter("marcados").equals("") ? "0" : request.getParameter("marcados"));

    acao = ((acao == null) ? "" : acao);

    //Instanciando o bean pra trazer os CTRC's
    conCon = new BeanConsultaConhecimento();
    conCon.setConexao(Apoio.getUsuario(request).getConexao());

    String serie = (request.getParameter("serie") != null ? request.getParameter("serie") : "");
    String manifesto = (request.getParameter("manifesto") != null ? request.getParameter("manifesto") : "");
    String romaneio = (request.getParameter("romaneio") != null ? request.getParameter("romaneio") : "");
    String numeroCarga = (request.getParameter("numeroCarga") != null ? request.getParameter("numeroCarga") : "");
    String telaChamada = (request.getParameter("telaChamada") != null ? request.getParameter("telaChamada") : "ct");
    boolean isNormal = Boolean.parseBoolean(request.getParameter("ct_normal") == null ? "true" : request.getParameter("ct_normal"));
    boolean isLocal = Boolean.parseBoolean(request.getParameter("ct_local") == null ? "true" : request.getParameter("ct_local"));
    boolean isDiaria = Boolean.parseBoolean(request.getParameter("ct_diaria") == null ? "true" : request.getParameter("ct_diaria"));
    boolean isPaletizacao = Boolean.parseBoolean(request.getParameter("ct_paletizacao") == null ? "true" : request.getParameter("ct_paletizacao"));
    boolean isComplementar = Boolean.parseBoolean(request.getParameter("ct_complementar") == null ? "true" : request.getParameter("ct_complementar"));
    boolean isReentrega = Boolean.parseBoolean(request.getParameter("ct_reentrega") == null ? "true" : request.getParameter("ct_reentrega"));
    boolean isDevolucao = Boolean.parseBoolean(request.getParameter("ct_devolucao") == null ? "true" : request.getParameter("ct_devolucao"));
    boolean isCortesia = Boolean.parseBoolean(request.getParameter("ct_cortesia") == null ? "true" : request.getParameter("ct_cortesia"));
    String destinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "");
    String razaoDestinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "");
    String ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : "numeroCTRC");
%>
<script language="javascript" type="text/javascript" src="../script/prototype.js"></script>
<script language="JavaScript" src="../script/jquery.js"	type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
jQuery.noConflict();
    
    var arrayExtencoes = new Array();
    arrayExtencoes[0] = 'CSV' ;
    function fechar(){
        window.close();
    }

    function seleciona(qtdlinha){
        for (i = 0; i <= qtdlinha - 1; ++i){
            if ($("chk_"+i).checked){
                window.opener.addCTRC($('id_ctrc_'+i).value,
                $('numero_ctrc_'+i).innerHTML,
                $('emissao_ctrc_'+i).innerHTML,
                $('valor_ctrc_'+i).innerHTML,
                $('destinatario_ctrc_'+i).innerHTML,
                $('bairro_destino_'+i).innerHTML,
                $('cidade_destino_'+i).innerHTML,
                $('nota_fiscal_'+i).innerHTML,
                false,//esse falso é para o conhecimento
                true,
                true
                );
            }
        }
        fechar();
    }

    function ctrcSelecionado(id){
        var sels = '<%=marcados%>';
        for(x=0; x < sels.split(',').length; x++){
            if (sels.split(',')[x] == id)
                return true;
        }
        return false;  
    }

    function pesquisar(){
        var arq = $("arq05").value;
        
        if (arq != null && arq != undefined && arq.trim() != "") {
            pesquisarNotas();
            //            alert("aaaaaaaaaaaaaaaa");
        }else {
            var formulario = $("formPesquisa");
            formulario.action = ("./seleciona_ctrc_distribuicao.jsp?acao=consultar&idconsignatario="+$("idconsignatario").value+                
                "&con_rzs=<%=request.getParameter("con_rzs")%>"+
                "&ct_normal=" + $("ct_normal").checked +
                "&ct_local=" + $("ct_local").checked +
                "&ct_diaria=" + $("ct_diaria").checked +
                "&ct_paletizacao=" + $("ct_paletizacao").checked +
                "&ct_complementar=" + $("ct_complementar").checked +
                "&ct_reentrega=" + $("ct_reentrega").checked +
                "&ct_devolucao=" + $("ct_devolucao").checked +
                "&ct_cortesia=" + $("ct_cortesia").checked);
            
            formulario.method = "post";
            formulario.submit();
            
            //            location.replace("./seleciona_ctrc_distribuicao.jsp?acao=consultar&marcados=<%=marcados%>&idconsignatario="+$("idconsignatario").value+
            //                "&dtinicial="+$('dtinicial').value+
            //                "&dtfinal="+$('dtfinal').value+
            //                "&ct_normal=" + $("ct_normal").checked +
            //                "&ct_local=" + $("ct_local").checked +
            //                "&ct_diaria=" + $("ct_diaria").checked +
            //                "&ct_paletizacao=" + $("ct_paletizacao").checked +
            //                "&ct_complementar=" + $("ct_complementar").checked +
            //                "&ct_reentrega=" + $("ct_reentrega").checked +
            //                "&ct_devolucao=" + $("ct_devolucao").checked +
            //                "&serie=" + $('serie').value);
        }
    }

    function marcarTodos(check){
        var i = 0;
        while ($("chk_"+i) != null){
            $("chk_"+i).checked = check;
            i++;
        }
    }

    function pesquisarNotas(){
        try {
            var arq = $("arq05").value;
            var formulario = $("formularioImportacao");
            
            if (arq == ""){
                alert("Selecione o arquivo.");
                return false;
                
                var ultimoPonto = arq.lastIndexOf(".");
                
                var extensao = arq.substr(ultimoPonto+1).toUpperCase();
                
                var possuiExtencao = false;
                for(var i=0;i<arrayExtencoes.length;i++){
                    if( arrayExtencoes[i].indexOf( extensao ) != -1 ){
                        possuiExtencao = true;
                    }
                }
                
                if(!possuiExtencao){
                    return  alert( "Extensão de arquivo inválida." );
                }
            }
            formulario.enctype = "multipart/form-data";
            //            formulario.target = "pop";
            formulario.action ="../ConhecimentoControlador?acao=importarConhecimentosNFSe&layoutArquivo="+$("layoutArquivo").value+
                "&marcados=<%=marcados%>&idconsignatario="+$("idconsignatario").value+
                "&dtinicial="+$('dtinicial').value+
                "&dtfinal="+$('dtfinal').value+
                "&con_rzs=<%=request.getParameter("con_rzs")%>"+
                "&ct_normal=" + $("ct_normal").checked +
                "&ct_local=" + $("ct_local").checked +
                "&ct_diaria=" + $("ct_diaria").checked +
                "&ct_paletizacao=" + $("ct_paletizacao").checked +
                "&ct_complementar=" + $("ct_complementar").checked +
                "&ct_reentrega=" + $("ct_reentrega").checked +
                "&ct_devolucao=" + $("ct_devolucao").checked +
                "&ct_cortesia=" + $("ct_cortesia").checked +
                "&serie=" + $('serie').value;
            
            formulario.method = "post";
            formulario.submit();
        } catch (e) { 
            alert(e);
        }
    }

    jQuery(document).ready(function () {
        // Seleciona o select de ordenação
        $('ordenacao').value = '<%= ordenacao %>';
    });
</script>

<html>
    <head>
        <script language="javascript" src="../script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Selecionar Minutas de Distribuição</title>
        <link href="../estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body>
        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") == null ? "0" : request.getParameter("idconsignatario"))%>">
        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr>
                <td width="619"><div align="left"><b>Selecionar Minutas de Distribuição</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>
        <form method="post" id="formPesquisa" >
            <input type="hidden" name="marcados" value="<%=marcados%>">
            <table width="95%" align="center" class="bordaFina" >
                <tr>
                    <td width="18%" class="TextoCampos">Emitidos entre:</td>
                    <td width="20%" class="CelulaZebra2"><input name="dtinicial" type="text" id="dtinicial" style="font-size:8pt;" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                                                onblur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                        e
                        <input name="dtfinal" type="text" class="fieldDate" id="dtfinal" style="font-size:8pt;" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                               onBlur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onKeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)"></td>
                    <td width="20%" class="TextoCampos">Cliente:</td>
                    <td width="30%" class="CelulaZebra2"><div align="left"></div>
                        <label id="con_rzs" name="con_rzs"><b><%=(request.getParameter("con_rzs") == null ? "Cliente não informado" : request.getParameter("con_rzs"))%></b></label></td>
                    <td width="10%" class="CelulaZebra2"><table width="100%" border="0">
                            <tbody id="cid">
                            </tbody>
                        </table>
                    </td>
                    <td width="15%" class="CelulaZebra2"><div align="center">
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="6">
                        <table width="100%" border="0">
                            <td width="13%" class="TextoCampos">Apenas a Série:</td>
                            <td width="6%" class="CelulaZebra2">
                                <input type="text" id="serie" name="serie" value="<%=serie%>" class="inputTexto" size="3">
                            </td>
                            <td width="5%" class="TextoCampos">Tipo:</td>
                            <td width="40%" class="CelulaZebra2">
                                <input name="ct_normal" type="checkbox" id="ct_normal" <%=isNormal ? "checked" : ""%>>Normais
                                <input name="ct_local" type="checkbox" id="ct_local" <%=isLocal ? "checked" : ""%>>Distribuições locais
                                <input name="ct_diaria" type="checkbox" id="ct_diaria" <%=isDiaria ? "checked" : ""%>>Diárias
                                <input name="ct_paletizacao" type="checkbox" id="ct_paletizacao" <%=isPaletizacao ? "checked" : ""%>>Pallets
                                <input name="ct_complementar" type="checkbox" id="ct_complementar" <%=isComplementar ? "checked" : ""%>>Complementares
                                <br>
                                <input name="ct_reentrega" type="checkbox" id="ct_reentrega" <%=isReentrega ? "checked" : ""%> >Reentregas
                                <input name="ct_devolucao" type="checkbox" id="ct_devolucao" <%=isDevolucao ? "checked" : ""%> >Devoluções
                                <input name="ct_cortesia" type="checkbox" id="ct_cortesia" <%=isCortesia ? "checked" : ""%> >Cortesias
                            </td>
                            <td width="5%" class="TextoCampos">Destinatário:</td>
                            <td width="31%" class="CelulaZebra2">
                                <input name="dest_rzs" type="text" name="dest_rzs" id="dest_rzs" class="inputReadOnly8pt" size="22" readonly="true" value="<%=razaoDestinatario%>">
                                <strong>
                                    <input name="localiza_dest" type="button" class="inputBotaoMin" id="localiza_dest" value="..." onClick="javascript:launchPopupLocate('../localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario');">
                                    <img src="../img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '';getObj('dest_rzs').value = 'Todos os destinatarios';">
                                </strong>
                                <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=destinatario%>">          
                            </td>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Apenas o Manifesto:</td>
                    <td class="CelulaZebra2">
                        <input type="text" id="manifesto" name="manifesto" value="<%=manifesto%>" class="inputTexto" size="10">
                        <input type="hidden" id="telaChamada" name="telaChamada" value="<%=telaChamada%>">
                    </td>
                    <td class="TextoCampos">Apenas o Romaneio:</td>
                    <td class="CelulaZebra2">
                        <input type="text" id="romaneio" name="romaneio" value="<%=romaneio%>" class="inputTexto" size="10">
                    </td>
                    <td class="TextoCampos" width="5%">Nº da carga:</td>
                    <td class="CelulaZebra2">
                        <input type="text" id="numeroCarga" name="numeroCarga" value="<%=numeroCarga%>" class="inputTexto" size="10">
                    </td>
                    <td class="CelulaZebra2"></td>
                    <td class="CelulaZebra2"></td>
                </tr>
                <tr>
                    <td class="TextoCampos"><label for="ordenacao">Ordenação:</label></td>
                    <td class="CelulaZebra2" colspan="7">
                        <select name="ordenacao" id="ordenacao" class="inputTexto">
                            <option value="numeroCTRC" selected>Nº CTRC</option>
                            <option value="numeroNotaFiscal">Nº Nota Fiscal</option>
                            <option value="dataEmissaoCTRC">Data de Emissão</option>
                            <option value="valorCTRC">Valor</option>
                        </select>
                    </td>
                </tr>
            </table>
        </form>            

        <form method="post" id="formularioImportacao" >
            <table width="95%" align="center" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td colspan="4"><div align="center">Adicionar conhecimentos existentes no arquivo</div>
                    </td>
                </tr>
                <tr class="celulaZebra2">
                    <td width="20%" align="right">
                        <label>Layout do arquivo:</label>                                
                    </td>
                    <td width="20%" align="left">
                        <select name="layoutArquivo" id="layoutArquivo" class="inputTexto" onchange="">
                            <option value="hermes">Hermes</option>
                        </select>
                    </td>
                    <td id="tdInput" width="60%" align="right" colspan="2">
                        <input name="arq05" id="arq05" type="file" class="inputTexto" size="40" />
                    </td>       
                </tr>
            </table>
        </form>
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="CelulaZebra2NoAlign" align="center">
                <td><input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" onClick="javascript:pesquisar();"></td>
            </tr>
        </table>
        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td width="2%"><div align="center">
                        <input type="checkbox" name="chkTodos" value="chkTodos" onClick="javascript:marcarTodos(this.checked);">
                    </div></td>
                <td width="10%">CTRC</td>
                <td width="8%">NF</td>
                <td width="10%">Emissão</td>
                <td width="10%">Valor</td>
                <td width="27%">Destinatário</td>
                <td width="15%">Bairro</td>
                <td width="20%">Cidade</td>
            </tr>
            <% //variaveis da paginacao
                int linha = 0;
                Date data;
                if ((request.getParameter("dtinicial") != null)) {
                    data = Apoio.paraDate(request.getParameter("dtinicial"));
                } else {
                    data = Apoio.paraDate(Apoio.getDataAtual());
                }
                conCon.setDtEmissao1(data);
                if ((request.getParameter("dtfinal") != null)) {
                    data = Apoio.paraDate(request.getParameter("dtfinal"));
                } else {
                    data = Apoio.paraDate(Apoio.getDataAtual());
                }
                conCon.setDtEmissao2(data);
                int clienteID = Integer.parseInt(request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0");
                SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
                // se conseguiu consultar
                if (conCon.loadCtrcDistribuicao(clienteID, marcados, serie, isNormal, isLocal, isDiaria, isPaletizacao, isComplementar, isReentrega, isDevolucao, isCortesia, manifesto, romaneio, numeroCarga, telaChamada, destinatario, ordenacao)) {
                    ResultSet rs = conCon.getResultado();
                    while (rs.next()) {%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td>
                    <input name="<%="chk_" + linha%>" type="checkbox" id="<%="chk_" + linha%>" value="<%=rs.getString("id_ctrc")%>">
                    <Script>$('chk_'+<%=linha%>).checked = ctrcSelecionado(<%=rs.getString("id_ctrc")%>);</Script>
                    <input type="hidden" name="id_ctrc_<%=linha%>" id="id_ctrc_<%=linha%>" value="<%=rs.getString("id_ctrc")%>">
                </td>
                <td>
                    <div align="left">
                        <label id="numero_ctrc_<%=linha%>" name="numero_ctrc_<%=linha%>">
                            <%=rs.getString("numero_ctrc")%>
                        </label>
                    </div>
                </td>
                <td>
                    <div align="left">
                        <label id="nota_fiscal_<%=linha%>" name="nota_fiscal_<%=linha%>">
                            <%=rs.getString("nota_fiscal")%>
                        </label>
                    </div>
                </td>
                <td>
                    <div align="left">
                        <label id="emissao_ctrc_<%=linha%>" name="emissao_ctrc_<%=linha%>">
                            <%=formato.format(rs.getDate("emissao_ctrc"))%>
                        </label>
                    </div>
                <td>
                    <div align="right">
                        <label id="valor_ctrc_<%=linha%>" name="valor_ctrc_<%=linha%>">
                            <%=Apoio.to_curr(rs.getDouble("valor_ctrc"))%>
                        </label>
                    </div>
                </td>
                <td>
                    <div align="left">
                        <label id="destinatario_ctrc_<%=linha%>" name="destinatario_ctrc_<%=linha%>">
                            <%=rs.getString("destinatario")%>
                        </label>
                    </div>
                </td>
                <td>
                    <div align="left">
                        <label id="bairro_destino_<%=linha%>" name="bairro_destino_<%=linha%>">
                            <%=rs.getString("bairro_destino")%>
                        </label>
                    </div>
                </td>
                <td>
                    <div align="left">
                        <label id="cidade_destino_<%=linha%>" name="cidade_destino_<%=linha%>">
                            <%=rs.getString("cidade_destino") + "-" + rs.getString("uf_destino")%>
                        </label>
                    </div>
                </td>
            </tr>
            <%          linha++;

                    }
                }
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="11"><div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
                    </div></td>
            </tr>
        </table>

    </body>
</html>
