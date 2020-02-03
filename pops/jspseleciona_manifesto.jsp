<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanLocaliza,
         nucleo.*,
         conhecimento.cartafrete.*,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio" %>

<%  //ATENCAO! A MSA está abaixo 
    // DECLARANDO e inicializando as variaveis usadas no JSP
    BeanConsultaCartaFrete selcarta = null;
    String acao = request.getParameter("acao");
    int nivelUser = Apoio.getUsuario(request).getAcesso("repetirmanifestocontrato");
    int linha = 0;
    // -- INICIO DO MSA
    if (Apoio.getUsuario(request) == null) {
        response.sendError(response.SC_FORBIDDEN, "É preciso estar logado no sistema para ter acesso a esta página.");
    }

    acao = ((acao == null) ? "" : acao);
    // -- FIM DO MSA

    BeanConfiguracao cfg = null;
    //Carregando as configuraões independente da ação
    cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    //Carregando as configurações
    cfg.CarregaConfig();


    //Instanciando o bean pra trazer os CTRC's
    selcarta = new BeanConsultaCartaFrete();
    selcarta.setConexao(Apoio.getUsuario(request).getConexao());

    selcarta.setData(request.getParameter("data") == null ? new Date() : Apoio.paraDate(request.getParameter("data")));
    selcarta.setData2(request.getParameter("data2") == null ? new Date() : Apoio.paraDate(request.getParameter("data2")));
    boolean mostraManifestos = (request.getParameter("mostrarManifestos") == null ? cfg.isGerarCartaFreteManifesto() : Boolean.parseBoolean(request.getParameter("mostrarManifestos")));
    boolean mostraRomaneios = (request.getParameter("mostrarRomaneios") == null ? cfg.isGerarCartaFreteRomaneio() : Boolean.parseBoolean(request.getParameter("mostrarRomaneios")));
    boolean mostraColetas = (request.getParameter("mostrarColetas") == null ? cfg.isGerarCartaFreteColeta() : Boolean.parseBoolean(request.getParameter("mostrarColetas")));
    int idMotorista = request.getParameter("idmotorista") == null ? 0 : Integer.parseInt(request.getParameter("idmotorista"));
    String motorista = request.getParameter("motor_nome") == null ? "" : request.getParameter("motor_nome");
    boolean travarMotorista = Apoio.parseBoolean(request.getParameter("travarMotorista"));
    boolean jaTemContrato = Apoio.parseBoolean(request.getParameter("jaTemContrato"));

    double debito_prop = Apoio.parseDouble(request.getParameter("debito_prop"));
    double percentual_desconto_prop = Apoio.parseDouble(request.getParameter("percentual_desconto_prop"));

    selcarta.setMostrarManifestos(mostraManifestos);
    selcarta.setMostrarColetas(mostraColetas);
    selcarta.setMostrarRomaneios(mostraRomaneios);
    selcarta.setMotoristaId(idMotorista);
    String marcados = request.getParameter("marcados");
    String marcados2 = request.getParameter("marcados2");
    boolean mostraTudo = Boolean.parseBoolean(request.getParameter("mostratudo"));

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

%>
<script language="JavaScript" src="script/contrato_frete_documento.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>

<script language="javascript" type="text/javascript" >
    shortcut.add("Ctrl+P",function() {
        javascript:tryRequestToServer(function(){consultar('<%=request.getParameter("acaoDoPai")%>','<%=request.getParameter("marcados")%>','<%=request.getParameter("mostratudo")%>','<%=request.getParameter("filial")%>');});
    });
    function limpaMotor(){
        $('idmotorista').value = '0';
        $('motor_nome').value='';
    }

    function fechar(){
        window.close();
    }

    function seleciona(qtdlinha){
        var retorno = "";
        var deuCerto = true;
        var cavalo = 0;
        var motorista = 0;
        var valorFreteCarreteiro = 0;
        var isRomaneio = false;
        
        if(window.opener.addDocumentoContratoFrete != null){
            
            
            if ($("idmotorista").value == window.opener.document.getElementById("idmotorista").value) {
                
                window.opener.removeAllDocum();
                for (i = 0; i <= qtdlinha - 1; ++i){
                    if ($("chk-"+i).checked){
                        var documento = new ContratoFreteDocumento();
                        documento.id = $("chk-"+i).value;
                        documento.tipo = $("hd-"+i).value;
                        documento.data = $("labData_"+i).innerHTML;
                        documento.numero = $("labNumero_"+i).innerHTML;
                        documento.origem = $("labOrigem_"+i).innerHTML;
                        documento.origemId = $("OrigemId_"+i).value;
                        documento.destino = $("labDestino_"+i).innerHTML;
                        documento.destinoId = $("DestinoId_"+i).value;
                        documento.peso = $("labPeso_"+i).innerHTML;
                        documento.valorFrete = $("idValorFrete"+i).value;                   
                        documento.valorNota = $("valorNota"+i).value;                   
                        documento.volumes = $("volume"+i).value;                   
                        documento.clienteId = $("ClienteId_"+i).value;
                        documento.qtdEntregas = $("qtdEntregas"+i).value;                   
                        documento.isMostraRotaCliente = $("ClienteIsRota_"+i).value;
                        documento.valorFreteCte = $("valorFreteCte_"+i).value;
                        documento.valorPesoCte = $("valorPesoCte_"+i).value;
                        documento.clienteNegociacao = $("ClienteNegociacaoId_"+i).value;
                        
                        documento.totalCteCIF = $("valorTotalCif_"+i).value;
                        documento.totalCteFOB = $("valorTotalFob_"+i).value;
                        documento.totalCteTerceiro = $("valorTotalTerceiro_"+i).value;
                        documento.filialDestino = $("descFilialDestino_"+i).value;
                        documento.idFilialDestino = $("filialDestino_"+i).value;
                        
                        var e = window.opener.document.getElementById("filial");
                        var itemSelecionado = e.options[e.selectedIndex].text;
                        
                        documento.filialOrigem = itemSelecionado;

                        documento.valorPedagio = $('valorPedagio_' + i).value;
                        
                        window.opener.addDocumentoContratoFrete(documento);
                        
                        valorFreteCarreteiro += parseFloat($("idValorContrato"+i).value);
                        
                        if (documento.tipo == "ROMANEIO") {
                            isRomaneio = true;
                        }
                    }
                }
                window.opener.document.getElementById("vlFreteMotorista").value = colocarVirgula(formatoMoeda(valorFreteCarreteiro));
                window.opener.validarNegociacao();
                window.opener.calculaImpostos();
                window.opener.getRota();
                fechar();
            }else{
                alert('Para gerar o contrato de frete deverá ser selecionado manifestos do mesmo motorista e do mesmo veículo.');
                fechar();
            }
            window.opener.document.getElementById("vlFreteMotorista").value = colocarVirgula(formatoMoeda(valorFreteCarreteiro));
            window.opener.calculaImpostos();

            if (isRomaneio) {
                if (<%=!cfg.isRomaneioAutorizacaoPagamento()%>) {
                    window.opener.getRota();
                }else{
                    window.opener.$("rota").style.display = "none";
                    window.opener.$("carregaRota").style.display = "none";
                    window.opener.$("lblPercuso").style.display = "none";
                    window.opener.$("percurso").style.display = "none";
                    window.opener.$("tdRota").innerHTML = "determinada através do Romaneio";
                }
            }else{
                if (parseFloat(window.opener.$('percentual_valor_cte_calculo_cfe').value) != 0) {
                    window.opener.calcularTabelaMotorista();
                    window.opener.calculaDiaria();
                    window.opener.calculaImpostos();
                }

                window.opener.getRota();
            }
            
        }else{
           
            for (i = 0; i <= qtdlinha - 1; ++i){
                if ($("chk-"+i).checked){
                    if (retorno == ""){
                        retorno += $("chk-"+i).value + '!!!' + $("hd-"+i).value;
                        cavalo = $("idcav"+i).value;
                        motorista = $("idmot"+i).value;
                    }  
                    else{
                        retorno += ","+$("chk-"+i).value + '!!!' + $("hd-"+i).value;
                        if (cavalo != $("idcav"+i).value)
                            deuCerto = false;
                        if (motorista != $("idmot"+i).value)
                            deuCerto = false;
                    }  
                }
            }
            
            if (!deuCerto){
                alert('Para gerar o contrato de frete deverá ser selecionado manifestos do mesmo motorista e do mesmo veículo.');
            }  
            else if (retorno == ""){
                alert('Escolha no mínimo um documento');
            }  
            else if(window.opener.carrega != null){
                window.opener.carrega(retorno,0,'<%=request.getParameter("acaoDoPai")%>',true);  
                fechar();                
            }
                           
        }       
        
    }

    function consultar(acaoDoPai,marcados,mostraTudo,filial,marcados2){
      
        document.location.replace("./selecionamanifesto?acao=iniciar&acaoDoPai="+acaoDoPai+"&marcados="+marcados+
            "&mostrarManifestos="+$('mostrarManifestos').checked+
            "&mostrarRomaneios="+$('mostrarRomaneios').checked+
            "&mostrarColetas="+$('mostrarColetas').checked+
            "&idmotorista="+$('idmotorista').value+
            "&motor_nome="+$('motor_nome').value+
            "&travarMotorista="+$('travarMotorista').value+
            "&jaTemContrato="+$('jaTemContrato').checked+
            "&debito_prop="+$('debito_prop').value+
            "&percentual_desconto_prop="+$('percentual_desconto_prop').value+
            "&mostratudo="+mostraTudo+
            "&filial="+filial+
            "&marcados2="+marcados2+
            "&"+concatFieldValue("data,data2"));
    }
      
    jQuery(document).ready(function(){
        jQuery("#selecionarTodos").click(function(){
            if(jQuery("#selecionarTodos").prop("checked")){
                jQuery(".documentos").prop("checked",true);
            }else{
                jQuery(".documentos").removeProp("checked");
            }
        });
    });
    
</script>

<html>
    <head>
        
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt-br" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - Selecionar documentos para a contrato de frete</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <link href="../estilo.css" rel="stylesheet" type="text/css">   
        <style type="text/css">
            <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                      font-size: 13px;
            }
            -->
        </style>
    </head>

    <body>

        <br>
        <table width="95%" align="center" class="bordaFina" >
            <tr >
                <td width="619"><div align="left"><b>Selecionar documentos para a contrato de frete</b></div></td>
                <td width="69"><input name="cancelar" type="button" class="botoes" id="cancelar" value="Cancelar" onClick="javascript:fechar();"></td>
            </tr>
        </table>
        <br>

        <table width="95%" align="center" cellspacing="1" class="bordaFina">
            <tr>
                <td colspan="10"><table width="100%"  border="0" cellspacing="1" cellpadding="2">
                        <tr class="celula">
                            <td width="19%"><div align="right">Informe o per&iacute;odo:</div></td>
                            <td width="20%"><input name="data" type="text" id="data" size="10" class="fieldDate" maxlength="10"
                                                   value="<%=fmt.format((request.getParameter("data") == null ? new Date() : selcarta.getData()))%>"
                                                   onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                                e
                                <input name="data2" type="text" id="data2" size="10" style="font-size:8pt;" maxlength="10"  class="fieldDate"
                                       value="<%=fmt.format((request.getParameter("data2") == null ? new Date() : selcarta.getData2()))%>"
                                       onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)"></td>
                            <td width="10%"><div align="right">Mostrar:</div></td>
                            <td width="38%"><input name="mostrarManifestos" type="checkbox" id="mostrarManifestos" value="checkbox" <%=(mostraManifestos ? "checked" : "")%> <%=(cfg.isGerarCartaFreteManifesto() ? "" : "disabled")%>>
                                Manifestos
                                <input name="mostrarRomaneios" type="checkbox" id="mostrarRomaneios" value="checkbox" <%=(mostraRomaneios ? "checked" : "")%> <%=(cfg.isGerarCartaFreteRomaneio() ? "" : "disabled")%> >
                                Romaneios
                                <input name="mostrarColetas" type="checkbox" id="mostrarColetas" value="checkbox" <%=(mostraColetas ? "checked" : "")%> <%=(cfg.isGerarCartaFreteColeta() ? "" : "disabled")%>>
                                Coletas</td>
                            <td width="13%" rowspan="2"><div align="center">
                                    <input name="pesquisar" type="button"  class="botoes" id="pesquisar3" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                                           onClick="javascript:tryRequestToServer(function(){consultar('<%=request.getParameter("acaoDoPai")%>','<%=request.getParameter("marcados")%>','<%=request.getParameter("mostratudo")%>','<%=request.getParameter("filial")%>','<%=request.getParameter("marcados2")%>');});">
                                </div></td>
                        </tr>
                        <tr class="celula">
                            <td><div align="right">Apenas o Motorista:</div></td>
                            <td colspan="2"><div align="left" >
                                    <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly"  size="35" readonly="true" value="<%=motorista%>">  

                                    <input name="travarMotorista" type="hidden" id="travarMotorista" class="inputReadOnly8pt" value="<%=travarMotorista%>" >
                                    <input name="idmotorista" type="hidden" id="idmotorista" class="inputReadOnly8pt" value="<%=idMotorista%>" >
                                    <input name="debito_prop" type="hidden" id="debito_prop" class="inputReadOnly"   readonly="true" value="<%=debito_prop%>">
                                    <input name="percentual_desconto_prop" type="hidden" id="percentual_desconto_prop" class="inputReadOnly8pt" value="<%=percentual_desconto_prop%>"> 
                                    <% if (!travarMotorista) {%>
                                    <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista')">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onClick="limpaMotor();">
                                    <% }%>                                        
                                </div></td>
                                <td>
                                    <input name="jaTemContrato" type="checkbox" id="jaTemContrato" value="checkbox" <%=(jaTemContrato ? "checked" : "")%> <%=(nivelUser == 4 ? "" : "disabled")%>>
                                    Mostrar Apenas Manifestos/Romaneios/Coletas que já estão com contrato gerado.
                                </td>    
                        </tr>
                    </table></td>
            </tr>

            <tr>
                <td width="2%" class="tabela"><input type="checkbox" id="selecionarTodos"></td>
                <td width="7%" class="tabela">Tipo</td>
                <td width="9%" class="tabela">Docum.</td>
                <td width="7%" class="tabela">Data</td>
                <td width="15%" class="tabela">Origem</td>
                <td width="15%" class="tabela">Destino</td>
                <td width="7%" class="tabela">Cavalo</td>
                <td width="7%" class="tabela">Carreta</td>
                <td width="23%" class="tabela">Motorista</td>
                <td width="8%" class="tabela">Peso</td>
            </tr>
            <% //variaveis da paginacao


                // se conseguiu consultar
                if (selcarta.SelectManifesto(request.getParameter("filial"), request.getParameter("marcados"), mostraTudo, jaTemContrato,request.getParameter("marcados2"), Apoio.getConfiguracao(request))) {
                    ResultSet rs = selcarta.getResultado();
                    while (rs.next()) {
                        //pega o resto da divisao e testa se é par ou impar
%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td>
                    <%boolean encontrou = false;
                        for (int i = 0; i <= marcados.split(",").length - 1; i++) {
                            if (marcados.split(",")[i].split("!!!")[0].equals(rs.getString("idmanifesto"))) {%>
                    <input name="<%="chk-" + linha%>" class="documentos" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("idmanifesto")%>"checked>
                    <%encontrou = true;
                            }
                        }
                        if (!encontrou) {%>
                    <input name="<%="chk-" + linha%>" class="documentos" type="checkbox" id="<%="chk-" + linha%>" value="<%=rs.getString("idmanifesto")%>">
                    <%}
                        SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
                    %>
                </td>
                <td>
                    <input name="<%="hd-" + linha%>" type="hidden" id="<%="hd-" + linha%>" value="<%=rs.getString("tipo")%>">
                    <%=rs.getString("tipo")%>
                </td>
                <td><b><label id="labNumero_<%=linha%>"><%=rs.getString("nmanifesto")%></label></b></td>
                <td>
                    <label id="labData_<%=linha%>"><%=formato.format(rs.getDate("dtsaida"))%></label>
                </td>
                <td>
                    <label id="labOrigem_<%=linha%>"><%=rs.getString("origem")%></label>
                    <input type="hidden" name="<%="OrigemId_" + linha%>" id="<%="OrigemId_" + linha%>" value="<%=rs.getInt("origem_id")%>">
                </td>
                <td>
                    <input type="hidden" name="<%="idcav" + linha%>" id="<%="idcav" + linha%>" value="<%=rs.getInt("idcavalo")%>">
                    <label id="labDestino_<%=linha%>"><%=rs.getString("destino")%></label>
                    <input type="hidden" name="<%="DestinoId_" + linha%>" id="<%="DestinoId_" + linha%>" value="<%=rs.getInt("destino_id")%>">
                    <input type="hidden" name="<%="ClienteId_" + linha%>" id="<%="ClienteId_" + linha%>" value="<%=rs.getInt("cliente_id")%>">
                    <input type="hidden" name="<%="ClienteIsRota_" + linha%>" id="<%="ClienteIsRota_" + linha%>" value="<%=rs.getBoolean("is_mostrar_rotas_desse_cliente")%>">
                    <input type="hidden" name="<%="ClienteNegociacaoId_" + linha%>" id="<%="ClienteNegociacaoId_" + linha%>" value="<%=rs.getInt("negociacao_contrato_frete_id")%>">
                </td>
                <td><%=rs.getString("cavalo")%></td>
                <td><%=rs.getString("carreta")%></td>
                <td><input type="hidden" name="<%="idmot" + linha%>" id="<%="idmot" + linha%>" value="<%=rs.getInt("idmotorista")%>"><%=rs.getString("motorista")%></td>
                <td>
                    <label id="labPeso_<%=linha%>"><%=rs.getString("peso")%></label>
                    <input type="hidden" name="<%="idValorFrete" + linha%>" id="<%="idValorFrete" + linha%>" value="<%=rs.getString("valor_frete")%>">
                    <input type="hidden" name="<%="valorNota" + linha%>" id="<%="valorNota" + linha%>" value="<%=rs.getString("valor_mercadoria")%>">
                    <input type="hidden" name="<%="volume" + linha%>" id="<%="volume" + linha%>" value="<%=rs.getString("volume")%>">
                    <input type="hidden" name="<%="qtdEntregas" + linha%>" id="<%="qtdEntregas" + linha%>" value="<%=rs.getString("qtd_entregas")%>">
                    <input type="hidden" name="<%="idValorContrato" + linha%>" id="<%="idValorContrato" + linha%>" value="<%=rs.getString("valor_contrato")%>">                    
                    <input type="hidden" name="<%="valorFreteCte_" + linha%>" id="<%="valorFreteCte_" + linha%>" value="<%=rs.getString("valor_frete_cte")%>">
                    <input type="hidden" name="<%="valorPesoCte_" + linha%>" id="<%="valorPesoCte_" + linha%>" value="<%=rs.getString("valor_peso_cte")%>">
                    <input type="hidden" name="<%="valorTotalCif_" + linha%>" id="<%="valorTotalCif_" + linha%>" value="<%=rs.getString("total_cif")%>">
                    <input type="hidden" name="<%="valorTotalFob_" + linha%>" id="<%="valorTotalFob_" + linha%>" value="<%=rs.getString("total_fob")%>">
                    <input type="hidden" name="<%="valorTotalTerceiro_" + linha%>" id="<%="valorTotalTerceiro_" + linha%>" value="<%=rs.getString("total_terceiro")%>">
                    <input type="hidden" name="<%="filialDestino_" + linha%>" id="<%="filialDestino_" + linha%>" value="<%=rs.getString("idfilialdestino")%>">
                    <input type="hidden" name="<%="descFilialDestino_" + linha%>" id="<%="descFilialDestino_" + linha%>" value="<%=rs.getString("abreviaturafilial")%>">
                    <input type="hidden" name="<%="valorPedagio_" + linha%>" id="<%="valorPedagio_" + linha%>" value="<%=rs.getDouble("valor_pedagio")%>">
                </td>
            </tr>
            <%linha++;
                    }//while
                }
            %>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <td colspan="10"><div align="center">
                        <input name="selecionar" type="button" class="botoes" id="selecionar" value="Selecionar" onClick="javascript:seleciona(<%=linha%>);">
                    </div></td>
            </tr>
        </table>

    </body>
</html>
