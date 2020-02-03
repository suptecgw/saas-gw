<%@page import="br.com.gwsistemas.eutil.NivelAcessoUsuario"%>
<%@page import="br.com.gwsistemas.eutil.AcaoUsuario"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="filial.BeanFilial"%>
<%@page import="cliente.ClienteLayoutEDI"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDIBO"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDI"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDI"%>
<%@page import="nucleo.exportacao.LayoutExcel"%>
<%@page import="java.util.Collection"%>
<%@page import="nucleo.exportacao.ExportacaoBO"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.ExporterTextData,
         nucleo.BeanLocaliza,
         nucleo.BeanConfiguracao,
         java.text.*,
         java.text.SimpleDateFormat,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>

<% boolean temacesso = (Apoio.getUsuario(request) != null && Apoio.getUsuario(request).getAcesso("exportacao") > 0);
//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    
//Carregando as configuraões independente da ação
    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
//Carregando as configurações
    cfg.CarregaConfig();
    ExportacaoBO exportacaoBO = new ExportacaoBO();
    Collection<LayoutExcel> layoutsAverbacaoExcel = exportacaoBO.mostrarTodosLayoutsAverbacaoExcel(Apoio.getUsuario(request));
    Collection<LayoutExcel> layoutsDocCobExcel = exportacaoBO.mostrarTodosLayoutsDocCobExcel(Apoio.getUsuario(request));
    Collection<LayoutEDI> listaLayoutCONEMB = LayoutEDIBO.mostrarLayoutEDI("c", Apoio.getUsuario(request));
    Collection<LayoutEDI> listaLayoutDOCCOB = LayoutEDIBO.mostrarLayoutEDI("f", Apoio.getUsuario(request));
    Collection<LayoutEDI> listaLayoutOCOREN = LayoutEDIBO.mostrarLayoutEDI("o", Apoio.getUsuario(request));
%>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();

    var dataAtualSistema = '<%=new SimpleDateFormat("dd/MM/yyyy").format(Apoio.paraDate(Apoio.getDataAtual()))%>';    
    var dataAtual = '<%=new SimpleDateFormat("yyyyMMdd").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
    var dataAtualRoca = '<%=new SimpleDateFormat("yyMM").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
    var dataAtualRicardoEletro = '<%=new SimpleDateFormat("ddMM").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
    var dataAtualMercador = '<%=new SimpleDateFormat("ddMMyyyyHHmm").format(new Date())%>';
    var dataAtualCremer = '<%=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())%>';  
    var horaAtualSistema = new Date();
    function imprimirCTe(){
        var formu = $("formularioCTe");
        
        if($("dataDe").value == ""){
            alert("Favor inserir o período corretamente!");
            $("dataDe").focus();
            return false;
        }
        if($("dataAte").value == ""){
            alert("Favor inserir o período corretamente!");
            $("dataAte").focus();
            return false;
        }
        if ($("rd_pedido").checked && $("numeroPedido").value == "") {
            alert("Favor inserir o número do Pedido");
            return false;
        }
        if ($("rd_romaneio").checked && $("numeroRomaneio").value == "") {
            alert("Favor inserir o número do Romaneio");
            return false;
        }
        if ($("rd_fatura").checked && $("numeroFatura").value == "" && $("anoFatura").value == "") {
            alert("Favor inserir o número ou ano da Fatura");
            return false;
        }
        if ($("rd_carga").checked && $("numeroCarga").value == "") {
            alert("Favor inserir o número da Carga");
            return false;
        }
        if ($("rd_manifesto").checked && $("numeroManifesto").value == "") {
            alert("Favor inserir o número do Manifesto");
            return false;
        }

        janela = window.open ('about:blank', 'pop', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');

        formu.submit();
        
        var mostrarRelatorio = $("mostrarRelatorio").checked;
        if(mostrarRelatorio == true){
            setTimeout("imprimirRelCTe();", 5000);
        }

        return true;

    }
    
    function imprimirMdfe(){
        try {
            var formu = $("formularioMDFe");
            
            if($("dataDeMDFe").value == ""){
                alert("Favor inserir o período corretamente!");
                $("dataDeMDFe").focus();
                return false;
            }
            if($("dataAteMDFe").value == ""){
                alert("Favor inserir o período corretamente!");
                $("dataAteMDFe").focus();
                return false;
            }
            
            janela = window.open ('about:blank', 'pop', 'titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0');
            
            formu.submit();
        } catch (e) { 
            alert(e);
        }
        return true;
    }
    
    function imprimirRelCTe(){
        var formu = $("formularioCTe");
        formu.action = "RelatorioCTe.zip?acao=relatorioAcompanhamentoCTe";
        formu.submit();
        formu.action = "exportacao.zip?acao=CTe";

    }

    function conemb(){
        try {
            var mod = ($('versaoCONEMB').value);                
            $('tipoDataEdi').value = 'dtemissao';
            if ($("idconsignatario").value == '0'){
                alert('Informe o cliente antes de gerar o arquivo.');
            }else if (mod == ''){
                alert('Informe um Layout!');
            }else{
                if (mod == 'mercador'){
                    document.location.href = './' + $('con_fantasia').value + 'CTRC'+dataAtualMercador+'001.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                }else if(mod == 'ricardo-conemb'){
                    document.location.href = './CTO'+dataAtualRicardoEletro+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario");
                }else if(mod == 'bpcs-cremer'){
                    document.location.href = './DAN_'+dataAtualCremer+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                }else if(mod.indexOf("webserviceAvon") > -1){
                    var pop = window.open('about:blank', 'pop', 'width=210, height=100');
                    pop.location.href = "NDDAvonControlador?acao=enviarCTesAvon&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                }else if(mod.indexOf("webserviceClaro") > -1){
                    var pop = window.open('about:blank', 'pop', 'width=210, height=100');
                    pop.location.href = "ExportacaoClaroControlador?acao=exportarClaroXML&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                }else if(mod.indexOf("funcEdi") > -1){
                    var layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_c).layoutEDI;
                    var nomeArquivo = layout.nomeArquivo;
                    horaAtualSistema = new Date();
                    nomeArquivo = replaceAll(nomeArquivo, "@@dia", dataAtualSistema.split("/")[0]);
                    nomeArquivo = replaceAll(nomeArquivo, "@@mes", dataAtualSistema.split("/")[1]);
                    nomeArquivo = replaceAll(nomeArquivo, "@@ano", dataAtualSistema.split("/")[2]);
                    nomeArquivo = replaceAll(nomeArquivo, "@@hora", horaAtualSistema.getHours());
                    nomeArquivo = replaceAll(nomeArquivo, "@@minuto", horaAtualSistema.getMinutes());
                    nomeArquivo = replaceAll(nomeArquivo, "@@segundo", horaAtualSistema.getSeconds());
                    nomeArquivo = replaceAll(nomeArquivo, "@@numero_CTE", "");
                    nomeArquivo = replaceAll(nomeArquivo, "@@data_Emissao_CTE", "");
                    switch(layout.extencaoArquivo){
                        case "txt":
                        var pop = window.open('./'+nomeArquivo+'.txt3?modelo=funcEDI&cliente='+$('con_rzs2').value+"&layoutID="+layout.id+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,idfilial"), 'pop', 'width=210, height=100');
//                            pop.location.href = './'+nomeArquivo+'.txt3?modelo=funcEDI&cliente='+$('con_rzs2').value+"&layoutID="+layout.id+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,idfilial");
                            break;
                        case "csv":
                        var pop = window.open('./'+nomeArquivo+'.csv?modelo=funcEDI&cliente='+$('con_rzs2').value+"&layoutID="+layout.id+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,idfilial"), 'pop', 'width=210, height=100');
                            break;
                    }
                }else{
                    document.location.href = './CONEMB'+dataAtual+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario");
                }
            }        
        } catch (e) { 
            alert(e);
        }
    }
    
    function doccob(){
        try {
            if ($('tipoDataEdi').value == 'data_ocorrencia'){
                $('tipoDataEdi').value = 'dtvenc';
            }
            var mod = $('versaoDOCCOB').value;
            if ($("idconsignatario").value == '0'){
                alert('Informe o cliente antes de gerar o arquivo.');
            }else if(mod=='roca-doccob' && ($('fatura').value=='' ||$('ano_fatura').value=='' )){
                alert('Informe o número da fatura/ano corretamente.');
            }else if (mod == ''){
                alert('Informe um Layout!');
            }else{
                if(mod=='roca-doccob'){
                    document.location.href = './COBRANCA_'+$('fatura').value+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,fatura,ano_fatura");
                }else if(mod=='intral'){
                    document.location.href = './conhec_fatur.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,fatura,ano_fatura");
                }else if(mod=='ricardo-doccob'){
                    document.location.href = './COB'+dataAtualRicardoEletro+'0.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,fatura,ano_fatura");
                }else if(mod.indexOf("excel") > -1){
                    var nomeArquivo = getTextSelect($("versaoDOCCOB")).split(" ")[1];
                    document.location.href = './DOCCOB_'+nomeArquivo+dataAtual+'.xls?acao=doccobExcel&modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,fatura,ano_fatura");
                }else if(mod.indexOf("webserviceAvon") > -1){
                    document.location.href = "NDDAvonControlador?acao=enviarFaturasAvon&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                }else if(mod.indexOf("funcEdi") > -1){
                    var layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_f).layoutEDI;
                    var nomeArquivo = layout.nomeArquivo;
                    horaAtualSistema = new Date();
                    nomeArquivo = replaceAll(nomeArquivo, "@@dia", dataAtualSistema.split("/")[0]);
                    nomeArquivo = replaceAll(nomeArquivo, "@@mes", dataAtualSistema.split("/")[1]);
                    nomeArquivo = replaceAll(nomeArquivo, "@@ano", dataAtualSistema.split("/")[2]);
                    nomeArquivo = replaceAll(nomeArquivo, "@@hora", horaAtualSistema.getHours());
                    nomeArquivo = replaceAll(nomeArquivo, "@@minuto", horaAtualSistema.getMinutes());
                    nomeArquivo = replaceAll(nomeArquivo, "@@segundo", horaAtualSistema.getSeconds());
                    switch(layout.extencaoArquivo){
                        case "txt":
                            document.location.href = './'+nomeArquivo+'.txt3?modelo=funcEDI&cliente='+$('con_rzs2').value+"&layoutID="+layout.id+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi");
                            break;
                    }
                }else{
                    document.location.href = './DOCCOB'+dataAtual+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi,fatura,ano_fatura");
                }
            }
        } catch (e) { 
            alert("Erro ao tentar gerar arquivo!"+e);    
        }

    }

    function ocoren(){
        try {
            if ($('tipoDataEdi').value == 'dtvenc'){
                $('tipoDataEdi').value = 'data_ocorrencia';
            }
            var mod = ($('versaoOCOREN').value);
            if ($("idconsignatario").value == '0'){
                alert('Informe o cliente antes de gerar o arquivo.');
            }else if (mod == ''){
                alert('Informe um Layout!');
            }else{
                if (mod == 'roca-ocoren'){
                    document.location.href = './CE'+dataAtualRoca+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi");
                }else if(mod=='bpcs-cremer-ocoren'){
                    document.location.href = './OCODAN_'+dataAtualCremer+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                }else if(mod=='ricardo-ocoren'){
                    document.location.href = './OCO'+dataAtualRicardoEletro+'0.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi");
                }else 
                    if(mod.indexOf("funcEdi") > -1){
                    var layout = getFuncLayoutEDI(mod.split("!!")[0], layoutsFunctionAll_o).layoutEDI;
                    var nomeArquivo = layout.nomeArquivo;
                        horaAtualSistema = new Date();
                        nomeArquivo = replaceAll(nomeArquivo, "@@dia", dataAtualSistema.split("/")[0]);
                        nomeArquivo = replaceAll(nomeArquivo, "@@mes", dataAtualSistema.split("/")[1]);
                        nomeArquivo = replaceAll(nomeArquivo, "@@ano", dataAtualSistema.split("/")[2]);
                        nomeArquivo = replaceAll(nomeArquivo, "@@hora", horaAtualSistema.getHours());
                        nomeArquivo = replaceAll(nomeArquivo, "@@minuto", horaAtualSistema.getMinutes());
                        nomeArquivo = replaceAll(nomeArquivo, "@@segundo", horaAtualSistema.getSeconds());

                        switch(layout.extencaoArquivo){
                            case "txt":
                                document.location.href = './'+nomeArquivo+'.txt3?modelo=funcEDI&cliente='+$('con_rzs2').value+"&layoutID="+layout.id+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi");
                                break;
                            case "env":
                                enviarHidroall(layout.id,nomeArquivo);
//                                document.location.href = './'+nomeArquivo+'.zip?acao=hidroal&cliente='+$('con_rzs2').value+"&layoutID="+layout.id+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi");
                                break;
                        }
                } else if (mod.indexOf('sap-webservice') != -1) {
                    var acao = "exportarSAP";
                    var docum = window.open('about:blank', 'pop', 'width=510, height=200');

                    docum.location.href = "ExportacaoSAPControlador?acao=" + acao + "&" + concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,idfilial");
                } else{
                    document.location.href = './OCOREN'+dataAtual+'.txt3?modelo='+mod+'&cliente='+$('con_rzs2').value+"&sped="+$('chkSped').checked+"&"+concatFieldValue("dtinicialedi,dtfinaledi,idconsignatario,tipoDataEdi");
                }
            }
        } catch (e) { 
            alert("Erro ao tentar gerar arquivo!"+e);
        }

    }
    
    
    function enviarHidroall(layout,nomeArquivo){
        
        jQuery.ajax({
                    url: './'+nomeArquivo+'.zip',
                    dataType: "text",
                    method: "post",
                    data: {
                        dtinicialedi : $("dtinicialedi").value,
                        dtfinaledi : $("dtfinaledi").value,
                        idconsignatario : $("idconsignatario").value,
                        tipoDataEdi : $("tipoDataEdi").value,
                        layoutID : layout,
                        acao : "hidroal"
                    },
                    success: function(data) {
                        var retorno = JSON.parse(data);
                        alert(retorno.retornoHidroall);
                    }
                });
        
        
    }
    
    
    
    

    function sef(){
        window.location.href = './SEF'+$('dtfinalsef').value.substr(3,2)+$('dtfinalsef').value.substr(6,4)+'.txt1?modelo=sef&'+concatFieldValue("dtinicialsef,dtfinalsef,seriesef,idfilial");
    }
    function sef2(){
        var pop = window.open('about:blank', 'pop', 'width=210, height=500');
        //        pop.setTimeout("window.close();", 20000)
        pop.location.href = './SEF'+$('dtfinalsef').value.substr(3,2) + $('dtfinalsef').value.substr(6,4) + '.txt1?modelo=sef2&' +
            concatFieldValue("dtinicialsef,dtfinalsef,seriesef,idfilial,indicadorsef2,indicadorpropsef2") +
            "&isFrota=" + $("chkEntradasSEFFrota").checked + "&isLogis=" + $("chkEntradasSEFLogis").checked+"&chkAWBSEF="+$("chkAWBSEF").checked+"&chkInventario="+$("chkInventario").checked;
    }
    function eDoc(){
        var pop = window.open('about:blank', 'pop', 'width=210, height=500');
        //        pop.setTimeout("window.close();", 10000)
        pop.location.href = './eDoc'+$('dtfinalsef').value.substr(3,2) + $('dtfinalsef').value.substr(6,4) + '.txt1?modelo=eDoc&' +
            concatFieldValue("dtinicialsef,dtfinalsef,seriesef,idfilial") +
            "&isFrota=" + $("chkEntradasSEFFrota").checked + "&isLogis=" + $("chkEntradasSEFLogis").checked;
    }

    function averbacaoTokioMarine(){
        document.location.href = './AVERBACAO'+$('dtfinalAverb').value.substr(3,2)+$('dtfinalAverb').value.substr(6,4)+'.txt9?modelo=tokioMarine&'+concatFieldValue("dtinicialAverb,dtfinalAverb,idfilial");
    }
    function averbacaoItauSeguros(){
        document.location.href = './AVERBACAO'+$('dtfinalAverb').value.substr(3,2)+$('dtfinalAverb').value.substr(6,4)+'.txt11?acao=itauSeguros&modelo=CTRC&'+concatFieldValue("dtinicialAverb,dtfinalAverb,idfilial,serieAverbacao");
    }

    function sintegra(){
        if (confirm('ATENÇÃO: Os registros 8801, 8802, 8804, 8818 e 8830 serão gerados com os campos de valores zerados, pois essas informações dependem das apurações contábeis e o Webtrans não tem acesso a essas informações. Favor informar ao contador da empresa sobre essas informações. Para saber quais campos serão gerados zerados acesse o link http://legisla.receita.pb.gov.br/LEGISLACAO/REGULAMENTOS/ANEXOSRICMS/A-46/ANEXO-46_.html.\r\n\r\nDeseja gerar o arquivo mesmo assim?')){
            document.location.href = './SINTEGRA'+$('dtfinalsef').value.substr(3,2)+$('dtfinalsef').value.substr(6,4)+'.txt1?modelo=sintegra&gerarEntradas='+$("chkEntradasSintegra").checked+'&'+concatFieldValue("dtinicialsef,dtfinalsef,seriesef,idfilial,seriesefEntrada");
        }
    }
    
    function averbacaoExcel(){        
        var nomeArquivo = getTextSelect($("layoutExcel")).split(" ")[1];
        document.location.href = './'+nomeArquivo+$('dtfinalsef').value.substr(3,2)+$('dtfinalsef').value.substr(6,4)+'.xls?acao=averbacaoExcel&gerarEntradas=&'+concatFieldValue("dtinicialAverb,dtfinalAverb,serieAverbacao,idfilial,layoutExcel");
    }
    
    function validarFiltros(){
        if($("idfilial").value=="0"){
            alert("Informe a filial!");
            return false;
        }
        if($("dtinicialsef").value==""){
            alert("Informe a data inicial!");
            return false;
        }
        if($("dtfinalsef").value==""){
            alert("Informe a data final!");
            return false;
        }
        return true;
    }

    function sped(tipo){
        try {
            if (validarFiltros()) {
//                var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                //pop.setTimeout("window.close();", 23000);
                var dataFinal = $("dtfinalsef").value;
                var competencia = (dataFinal.split("/")[1] != null && dataFinal.split("/")[1] != undefined ? dataFinal.split("/")[1] : "") + (dataFinal.split("/")[2] != null && dataFinal.split("/")[2] != undefined ? dataFinal.split("/")[2] : "");
                switch (tipo){
                    case 1 :
                        downloadArquivoEtiqueta("SpedEFD-"+$("fi_cnpj").value+"-Remessa de arquivo original-"+competencia+".txt12", "?acao=gerarArquivoSpedFiscal&idFilial="
                            +$("idfilial").value+"&dataInicial="+$("dtinicialsef").value+"&dataFinal="+$("dtfinalsef").value+"&serie="+$("seriesef").value
                            +"&isFrota="+$("chkEntradasSPEDFrota").checked+"&isLogis="+$("chkEntradasSPEDLogis").checked+"&isAWB="+$("chkAWB").checked+"&indicadorpropsef2="+$("indicadorpropsef2").value);//chkAWB
                        break;
                    case 2 :
                        downloadArquivoEtiqueta("SPEDPisCofins"+competencia+".txt12","?acao=gerarArquivoSpedPisCofins&idFilial="
                            +$("idfilial").value+"&dataInicial="+$("dtinicialsef").value+
                            "&dataFinal="+$("dtfinalsef").value+"&serie="+$("seriesef").value
                            +"&isEntrada="+$("chkEntradasPisCofins").checked+"&isSaida=true&isContratoFrete="+$("chkContratoFretePisCofins").checked
                            + '&chkEntradasComprasServicos=' + $('chkEntradasComprasServicos').checked);
                        break;
                }
            }
        } catch (e) { 
            alert(e);
        }
    }
    
    /***
     * vai ser gerado um arquivo com o nome do action passado;
     * @param {type} action      -> chamar o controlador.
     * @param {type} param       -> parametros passados por URL
     * @param {type} data        -> exemplo: {rotinaId: id, rotinaParam: 'parametro'}
     * @param {type} nomeArquivo -> nome do arquivo que será baixado.
     * @returns nada...
     */
    function downloadArquivoEtiqueta(action, param, data, nomeArquivo) {
        jQuery.ajax({
            url: action+param,
            data: data,
            success: function (a,b,jqXHR) {
                try {
                    var txt = (jqXHR.responseText);
                    var blob = new Blob([txt], {type: "text/plain"});
                    let link = document.createElement('a');
                    link.href = window.URL.createObjectURL(blob);
                    link.download = (nomeArquivo === null || nomeArquivo === undefined ? action : nomeArquivo);
                    document.body.appendChild(link);
                    link.dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true, view: window}));
                    link.remove();
                    window.URL.revokeObjectURL(link.href);
                } catch (exception) {
                    alert(exception);
                }
           },error: function (a,b,c) {
                  alert("ATENÇÃO! " + a.responseText);
           }
//            complete: function (jqXHR, textStatus) {
//            try {
//                var txt = (jqXHR.responseText);
//                if (txt.indexOf("ERROR") === 0) {
//                    alert(txt);
//                    return false;
//                }
//                var blob = new Blob([txt], {type: "text/plain"});
//                let link = document.createElement('a');
//                link.href = window.URL.createObjectURL(blob);
//                link.download = action;
//                document.body.appendChild(link);
//                link.dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true, view: window}));
//                link.remove();
//                window.URL.revokeObjectURL(link.href);
//            } catch (exception) {
//                alert(exception);
//            }
//            }
        });
    }
    
    function fortes(){
        
        try {
                var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                pop.location.href = ("FORTES.txt13?acao=gerarArquivoFortesFiscal&idFilial="
                            +$("idfilial").value+"&dataInicial="+$("dtinicial").value+
                            "&dataFinal="+$("dtfinal").value+"&serie="+$("serie").value
                            +"&empresa="+$("empresa").value)+"&tipo="+$("apenasTipoFiscal").value; 
        } catch (e) { 
            alert(e);
        }
    }


    function validaParana(){
        document.location.href = './VALIDA'+$('dtfinalsef').value.substr(3,2)+$('dtfinalsef').value.substr(6,4)+'.txt1?modelo=validaparana&'+concatFieldValue("dtinicialsef,dtfinalsef,seriesef,idfilial");
    }
  
    function localizacliente(){
        post_cad = window.open('./localiza?acao=consultar&idlista=5','Consignatario_EDI',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizaclienteXml(){
        post_cad = window.open('./localiza?acao=consultar&idlista=3','Remetente',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FILIAL%>','filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizafornecedor(){
        post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.FORNECEDOR%>&paramaux=1','fornecedor',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela){
        $('fi_abreviatura_sef').value = $('fi_abreviatura').value;
        if ($('fi_abreviatura_mmq') != null)      
            $('fi_abreviatura_mmq').value = $('fi_abreviatura').value;
        if ($('fi_abreviatura_edi') != null)      
            $('fi_abreviatura_edi').value = $('fi_abreviatura').value;
        if ($('fi_abreviatura_ave') != null)
            $('fi_abreviatura_ave').value = $('fi_abreviatura').value;
        //essa validacao da janela e para distinguir os consignatarios de EDI e CTE.
        if (idjanela == "Consignatario_CTe") {
            $("idconsignatario1").value = $("idconsignatario").value;
            carregarLayoutsCliente($("idconsignatario").value);
            $("consigCte1").value = $("idconsignatario").value;
            $("con_rzs1").value = $("con_rzs").value;
        }
        if (idjanela == "Consignatario_EDI") {
            $("idconsignatario2").value = $("idconsignatario").value;
            carregarLayoutsCliente($("idconsignatario").value);
            $("consigCte2").value = $("idconsignatario").value;
            $("con_rzs2").value = $("con_rzs").value;
        }
    }
  
    function mostraContratoFrete(){
        $('divContratoFreteNGFiscal').style.display = "none";
        if (($('apenasTipoFiscal').value == '' || $('apenasTipoFiscal').value == 'E') && $('sistema').value == 'mf') {
            $('divContratoFreteNGFiscal').style.display = "";
        }
    }
    
    function verificaSistema(){
        $('tr_masterFiscal_src').style.display = "none";
        $('tr_masterFiscal_dupls').style.display = "none";
        $('tr_masterFiscal_mater').style.display = "none";
        $('tr_titulo_contabil').style.display = "none";
        $('tr_masterFiscal_fmvim').style.display = "none";
        $('tr_masterFiscal_ctr').style.display = "none";
        $('tr_masterFiscal_fmvi2').style.display = "none";
        $('tr_masterFiscal_fmvi4').style.display = "none";
        $('tr_masterFiscal_fmvi5').style.display = "none";
        $('tr_masterFiscal_fmvi7').style.display = "none";
        $('tr_masterFiscal_fmvi6').style.display = "none";
        $('tr_masterFiscal_fmvi8').style.display = "none";
        $('tr_masterFiscal_data').style.display = "none";
        $('tr_masterContabil').style.display = "none";
        $('tr_contimatic').style.display = "none";
        $('tr_eFiscal').style.display = "none";
        $('tr_g5').style.display = "none";
        $('tr_prosoft_src').style.display = "none";
        $('trTipoFiscal').style.display = "none";
        $('tr_gci_cliente').style.display = "none";
        $('tr_gci_fornecedor').style.display = "none";
        $('tr_gci_fiscals').style.display = "none";
        $('tr_gci_conhint').style.display = "none";
        $('tr_mega_movimentos').style.display = "none";
        $('tr_mega_itens').style.display = "none";
        $('tr_mega_nf_cte').style.display = "none";
        $('tr_mega_cliente').style.display = "none";
        $('tr_ebsContabil').style.display = "none";
        $('tr_sciContabil').style.display = "none";
        $('tr_dominioContabil').style.display = "none";
        $('tr_Alterdata').style.display = "none";
        $('divContCancelados').style.display = "none";
        $('tr_ebsFolha').style.display = "none";
        $('tr_fortes_fiscal').style.display = "none";
        $('tr_fortes_contabil').style.display = "none";
        $('tr_ebsFiscal1').style.display = "none";
        $('tr_ebsFiscal2').style.display = "none";
        $('tr_ebsFiscal3').style.display = "none";
        $('tr_ebsFiscal4').style.display = "none";
        $('tr_fortes_folha').style.display = "none";
        if ($('sistema').value == 'mc'){
            $('tr_masterContabil').style.display = "";
            $('tr_titulo_contabil').style.display = "";
            $('divContCancelados').style.display = "";
        }else if ($('sistema').value == 'mf'){
            $('tr_masterFiscal_src').style.display = "";
            $('tr_masterFiscal_dupls').style.display = "";
            $('tr_masterFiscal_mater').style.display = "";
            $('tr_masterFiscal_ctr').style.display = "";
            $('tr_masterFiscal_fmvim').style.display = "";
            $('tr_masterFiscal_fmvi2').style.display = "";
            $('tr_masterFiscal_fmvi4').style.display = "";
            $('tr_masterFiscal_fmvi5').style.display = "";
            $('tr_masterFiscal_fmvi6').style.display = "";
            $('tr_masterFiscal_fmvi7').style.display = "";
            $('tr_masterFiscal_fmvi8').style.display = "";
            $('tr_masterFiscal_data').style.display = "";
            $('trTipoFiscal').style.display = "";
        }else if ($('sistema').value == 'ef'){
            $('tr_eFiscal').style.display = "";
        }else if ($('sistema').value == 'g5'){
            $('tr_g5').style.display = "";
        }else if ($('sistema').value == 'fc'){
            $('tr_contimatic').style.display = "";
            $('tr_titulo_contabil').style.display = "";
        }else if ($('sistema').value == 'pr'){
            $('tr_prosoft_src').style.display = "";
        }else if ($('sistema').value == 'gc'){
            $('tr_gci_cliente').style.display = "";
            $('tr_gci_fornecedor').style.display = "";
            $('tr_gci_fiscals').style.display = "";
            $('tr_gci_conhint').style.display = "";
        }else if ($('sistema').value == 'me'){
            $('tr_mega_movimentos').style.display = "";
            $('tr_mega_itens').style.display = "";
            $('tr_mega_nf_cte').style.display = "";
            $('tr_mega_cliente').style.display = "";
        }else if ($('sistema').value == 'ebs'){
            $('tr_ebsContabil').style.display = "";
            $('tr_titulo_contabil').style.display = "";
        }else if ($('sistema').value == 'f_ebs'){
            $('tr_ebsFiscal1').style.display = "";
            $('tr_ebsFiscal2').style.display = "";
            $('tr_ebsFiscal3').style.display = "";
            $('tr_ebsFiscal4').style.display = "";
        }else if ($('sistema').value == 'fla_ebs'){
            $('tr_ebsFolha').style.display = "";
            $('tr_serie').style.display = "none";
            $('tr_filial').style.display = "";
        }else if ($('sistema').value == 'ad'){
            $('tr_Alterdata').style.display = "";
            $('tr_titulo_contabil').style.display = "";
        }else if ($('sistema').value == 'sci'){
            $('tr_sciContabil').style.display = "";
            $('tr_titulo_contabil').style.display = "";
        }else if ($('sistema').value == 'dominio'){
            $('tr_dominioContabil').style.display = "";
            $('tr_titulo_contabil').style.display = "";
        }else if ($('sistema').value == 'fortes_c'){
            $('tr_titulo_contabil').style.display = "";
            $('tr_fortes_contabil').style.display = "";
        }else if ($('sistema').value == 'ff'){
            $('tr_fortes_fiscal').style.display = "";
            $('trTipoFiscal').style.display = "";
        }else if ($('sistema').value == 'folha_fortes'){
            $('tr_fortes_folha').style.display = "";
            $('tr_serie').style.display = "none";
            $('tr_filial').style.display = "";
        }

    }
  
    function escolheVersaoConemb(){
        $('tr_filial_edi').style.display = "none";
        $('trEDIFatura').style.display = "none";
        $('trEDIData').style.display = "";
        if ($('versaoCONEMB').value == "mercador" || $("versaoCONEMB").value == "webserviceAvon_env"){
            $('tr_filial_edi').style.display = "";
        }
        if ($('versaoDOCCOB').value == 'roca-doccob'){
            $('trEDIFatura').style.display = "";
            $('trEDIData').style.display = "none";
        }
    }
    
    function visualizarEDOC(){
        if ($("chkEntradasSEFFrota").checked || $("chkEntradasSEFLogis").checked) {
            visivel($("trEDOC"));
        }else{
            invisivel($("trEDOC"));
        }
    }
    //---------------------  EDI DINAMICA -------------------------  INICIO
    var layoutsFunctionAll_c = new Array();
    var layoutsFunctionAll_f = new Array();
    var layoutsFunctionAll_o = new Array();
    var idxAll_c = 0;
    var idxAll_f = 0;
    var idxAll_o = 0;
    
    
    var layoutsCliente_c = new Array();
    var layoutsCliente_f = new Array();
    var layoutsCliente_o = new Array();
    var idxLayout_c = 0;
    var idxLayout_f = 0;
    var idxLayout_o = 0;
    
    var countEDI_c = 0;
    var countEDI_f = 0;
    var countEDI_o = 0;
    var listLayoutEDI_c = new Array();
    var listLayoutEDI_f = new Array();
    var listLayoutEDI_o = new Array();
    var idxO = 0;
    var idxC = 0;
    var idxF = 0;

    listLayoutEDI_c[idxC] = new Option("", "----SELECIONE----");
    listLayoutEDI_c[++idxC] = new Option("bpcs-cremer", "BPCS (Cremer S/A)");
    listLayoutEDI_c[++idxC] = new Option("docile-conemb", "EMS Datasul/Totvs (Docile Ltda)");
    listLayoutEDI_c[++idxC] = new Option("gerdau", "Gerdau");
    listLayoutEDI_c[++idxC] = new Option("mercador", "Mercador");
    listLayoutEDI_c[++idxC] = new Option("neogrid_conemb", "NeoGrid");
    listLayoutEDI_c[++idxC] = new Option("nestle", "Nestle");
    listLayoutEDI_c[++idxC] = new Option("pro3.0a", "Proceda 3.0a");
    listLayoutEDI_c[++idxC] = new Option("pro3.0aTramontina", "Proceda 3.0a (Tramontina)");
    listLayoutEDI_c[++idxC] = new Option("pro3.1", "Proceda 3.1");
    listLayoutEDI_c[++idxC] = new Option("pro3.1betta", "Proceda 3.1 (Bettanin)");
    listLayoutEDI_c[++idxC] = new Option("pro3.1gko", "Proceda 3.1 (GKO)");
    listLayoutEDI_c[++idxC] = new Option("pro3.1kimberly", "Proceda 3.1 (Kimberly)");
    listLayoutEDI_c[++idxC] = new Option("pro4.0", "Proceda 4.0 (Aliança)");
    listLayoutEDI_c[++idxC] = new Option("pro5.0", "Proceda 5.0");
    listLayoutEDI_c[++idxC] = new Option("santher3.1-conemb", "Santher 3.1");
    listLayoutEDI_c[++idxC] = new Option("ricardo-conemb", "Ricardo Eletro");
    listLayoutEDI_c[++idxC] = new Option("terphane", "Terphane");
    listLayoutEDI_c[++idxC] = new Option("tivit3.1-conemb", "Tivit 3.0 (GDC)");
    listLayoutEDI_c[++idxC] = new Option("usiminas", "Soluções Usiminas");
    listLayoutEDI_c[++idxC] = new Option("webserviceAvon_env", "Avon (Web Service)");
    listLayoutEDI_c[++idxC] = new Option("webserviceClaro", "Claro S/A (XML CTE - Web Service)");
    <%for (LayoutEDI layout : listaLayoutCONEMB) {%>
        listLayoutEDI_c[++idxC] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
        layoutsFunctionAll_c[idxAll_c++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
    <%}%>

        listLayoutEDI_f[idxF] = new Option("", "----SELECIONE----");
        listLayoutEDI_f[++idxF] = new Option("intral","EMS Datasul/Totvs (Intral S/A)");
        listLayoutEDI_f[++idxF] = new Option("neogrid_doccob","NeoGrid");
        listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob","Proceda 3.0a");
        listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-alianca","Proceda 3.0a (Aliança)");
        listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-betta","Proceda 3.0a (Bettanin)");
        listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-dhl","Proceda 3.0a (DHL)");
        listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-paulus","Proceda 3.0a (Paulus)");
        listLayoutEDI_f[++idxF] = new Option("ricardo-doccob","Ricardo Eletro");
        listLayoutEDI_f[++idxF] = new Option("roca-doccob","Roca Brasil");
        listLayoutEDI_f[++idxF] = new Option("santher3.0a-doccob","Santher 3.0a");
        listLayoutEDI_f[++idxF] = new Option("tivit3.0a-doccob","Tivit 3.0a");
        listLayoutEDI_f[++idxF] = new Option("pro5.0-doccob","Proceda 5.0");
        listLayoutEDI_f[++idxF] = new Option("webserviceAvon","Avon (Web Service)");
    <%for (LayoutEDI layout : listaLayoutDOCCOB) {%>
        listLayoutEDI_f[++idxF] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
        layoutsFunctionAll_f[idxAll_f++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
    <%}%>
    <%for (LayoutExcel layoutExcel : layoutsDocCobExcel) {%>
        listLayoutEDI_f[++idxF] = new Option("<%=layoutExcel.getView()%>", "<%=layoutExcel.getDescricao()%>");
    <%}%>

        listLayoutEDI_o[idxO] = new Option("", "----SELECIONE----");
        listLayoutEDI_o[++idxO] = new Option("bpcs-cremer-ocoren","BPCS (Cremer S/A)");
        listLayoutEDI_o[++idxO] = new Option("docile-ocoren","EMS Datasul/Totvs (Docile Ltda)");
        listLayoutEDI_o[++idxO] = new Option("electrolux","Electrolux");
        listLayoutEDI_o[++idxO] = new Option("neogrid_ocoren","NeoGrid");
        listLayoutEDI_o[++idxO] = new Option("pro3.0a-ocoren","Proceda 3.0a");
        listLayoutEDI_o[++idxO] = new Option("pro3.0a-ocoren-alianca","Proceda 3.0a (Aliança)");
        listLayoutEDI_o[++idxO] = new Option("pro3.0a-ocoren-hyper","Proceda 3.0a (Hypermarcas)");
        listLayoutEDI_o[++idxO] = new Option("pro3.1-ocoren","Proceda 3.1");
        listLayoutEDI_o[++idxO] = new Option("pro3.1-ocoren-betta","Proceda 3.1 (Bettanin)");
        listLayoutEDI_o[++idxO] = new Option("pro5.0-ocoren","Proceda 5.0");
        listLayoutEDI_o[++idxO] = new Option("ricardo-ocoren","Ricardo Eletro");
        listLayoutEDI_o[++idxO] = new Option("roca-ocoren","Roca Brasil");
        listLayoutEDI_o[++idxO] = new Option("santher3.1-ocoren","Santher 3.1");
        listLayoutEDI_o[++idxO] = new Option("tivit3.0a-ocoren","Tivit 3.0a (GDC)");
        listLayoutEDI_o[++idxO] = new Option("sap-webservice", "SAP (Web Service)");
    <%for (LayoutEDI layout : listaLayoutOCOREN) {%>
        listLayoutEDI_o[++idxO] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
        layoutsFunctionAll_o[idxAll_o++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
    <%}%>
        
        
        function removerEDI(elemento, layoutsCliente, listaContainer){
            var listaInclusao = new Array();
            try {
                removeOptionSelected(elemento.id);
                for (i = 0; i < layoutsCliente.size(); i++) {
                    if (layoutsCliente[i].layoutEDI.id != 0) {
                        listaInclusao[i] = new Option( layoutsCliente[i].layoutEDI.id , layoutsCliente[i].layoutEDI.descricao);
                        listaInclusao[i].valor += "!!funcEdi";
                    }else{
                        for (j = 0; j < listaContainer.size(); j++) {
                            if (layoutsCliente[i].layoutFormatoAntigo == listaContainer[j].valor && listaContainer[j].valor != "") {
                                listaInclusao[i] = listaContainer[j];
                            }
                        }
                    }
                }
                povoarSelect(elemento, listaInclusao);
                elemento.selectedIndex = 0;
            } catch (e) {
                alert(e);
            }
        }
    
        function carregar(){
            try {
                povoarSelect($("versaoCONEMB"), listLayoutEDI_c);
                povoarSelect($("versaoDOCCOB"), listLayoutEDI_f);
                povoarSelect($("versaoOCOREN"), listLayoutEDI_o);
                
            } catch (e) { 
                alert(e);
            }
        }

        function carregarLayoutsCliente(clienteId){
            try {
                function e(transport){
                    var textoresposta = transport.responseText;
                    var lista = jQuery.parseJSON(textoresposta).list[0];
                
                    if (lista != "") {
                        var listaEDI = lista.listaClienteLayoutsEDI;
                        var length = (listaEDI != undefined && listaEDI.length != undefined ? listaEDI.length : 1);
                        
                        for(var i = 0; i < length; i++){
                            if(length > 1){
                                switch(listaEDI[i].tipo){
                                    case "c":
                                        layoutsCliente_c[idxLayout_c++] = (listaEDI[i]);
                                        removerEDI($("versaoCONEMB"), layoutsCliente_c, listLayoutEDI_c);
                                        break;
                                    case "f":
                                        layoutsCliente_f[idxLayout_f++] = (listaEDI[i]);
                                        removerEDI($("versaoDOCCOB"), layoutsCliente_f, listLayoutEDI_f);
                                        break;
                                    case "o":
                                        layoutsCliente_o[idxLayout_o++] = (listaEDI[i]);
                                        removerEDI($("versaoOCOREN"), layoutsCliente_o, listLayoutEDI_o);
                                        break;
                                }
                            }else{
                                switch(listaEDI.tipo){
                                    case "c":
                                        layoutsCliente_c[idxLayout_c++] = (listaEDI);
                                        removerEDI($("versaoCONEMB"), layoutsCliente_c, listLayoutEDI_c);
                                        break;
                                    case "f":
                                        layoutsCliente_f[idxLayout_f++] = (listaEDI);
                                        removerEDI($("versaoDOCCOB"), layoutsCliente_f, listLayoutEDI_f);
                                        break;
                                    case "o":
                                        layoutsCliente_o[idxLayout_o++] = (listaEDI);
                                        removerEDI($("versaoOCOREN"), layoutsCliente_o, listLayoutEDI_o);
                                        break;
                                }
                            }
                        }
                        
//                        removerEDI($("versaoCONEMB"), layoutsCliente_c, listLayoutEDI_c);
//                        removerEDI($("versaoDOCCOB"), layoutsCliente_f, listLayoutEDI_f);
//                        removerEDI($("versaoOCOREN"), layoutsCliente_o, listLayoutEDI_o);
                    }else{
                        removeOptionSelected("versaoCONEMB")
                        povoarSelect($("versaoCONEMB"), listLayoutEDI_c);
                        removeOptionSelected("versaoDOCCOB")
                        povoarSelect($("versaoDOCCOB"), listLayoutEDI_f);
                        removeOptionSelected("versaoOCOREN")
                        povoarSelect($("versaoOCOREN"), listLayoutEDI_o);
                    }
                
                }//funcao e()
                tryRequestToServer(function(){
                    new Ajax.Request("LayoutEDIControlador?acao=ajaxCarregarClienteLayoutEDI&cliente_id="+clienteId,{method:'post', onSuccess: e, onError: e});
                });
            } catch (e) { 
                alert("Erro ao carregar a lista de layouts para EDI do cliente!"+e);
            }

        }
    
        function getFuncLayoutEDI(valor, layoutsCliente){
            for (i = 0; i < layoutsCliente.size(); i++) {
                if (layoutsCliente[i].layoutEDI.id == valor) {
                    return layoutsCliente[i];
                }
            }
        }
    
        function povoarSelect(elemento, lista){
            try {
                var optLayout = null;
                if (lista != null) {
                    for(var i = 0; i < lista.length; i++){
                        if (lista[i] != null && lista[i] != undefined) {
                            optLayout = Builder.node("option", {value: lista[i].valor});
                            Element.update(optLayout, lista[i].descricao);
                            elemento.appendChild(optLayout);
                        }
                    }
                    elemento.selectedIndex = 0;
                }
            } catch (e) { 
                alert(e);
            }
        }
        //---------------------  EDI DINAMICA -------------------------  FIM

    function folha_fortes() {
        try {
            var pop = window.open('about:blank', 'pop', 'width=210, height=500');
            pop.location.href = ("FORTES.txt13?acao=gerarArquivoFortesFolha&idFilial=" + $("idfilial").value + "&dataInicial=" + $("dtinicial").value + "&dataFinal=" + $("dtfinal").value);
        } catch (e) {
            alert(e);
        }
    }
</script>
<%@page import="despesa.especie.Especie"%>
<jsp:useBean id="desp" class="despesa.BeanDespesa" />
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - Exportação de dados</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style4 {
                font-size: 10pt;
                font-weight: bold;
            }
            .style5 {color: #FF0000; font-size: 10pt;}
            .style6 {color: #000066; font-size: 8pt;font-weight: bold;}
            -->
        </style>
    </head>

    <body onLoad="applyFormatter();carregar();">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idfilial" id="idfilial" value="<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>">
            <input type="hidden" name="fi_cnpj" id="fi_cnpj" value="<%=Apoio.getUsuario(request).getFilial().getCnpj()%>">
            <input type="hidden" name="fi_abreviatura" id="fi_abreviatura" value="<%=Apoio.getUsuario(request).getFilial().getAbreviatura()%>">
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="consigCte" id="consigCte" value="">
            <input type="hidden" name="con_rzs" id="con_rzs" value="">
            <input type="hidden" name="idfilialedi" id="idfilialedi" value="<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>">
        </div>
        <table width="60%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Exporta&ccedil;&atilde;o de dados </b></td>
            </tr>
        </table>
        <%if (cfg.getIsFiscal() || cfg.getIsContabil()) {%>
    </p>
    <table width="60%" border="0" class="bordaFina" align="center">
        <tr class="tabela"> 
            <td colspan="4"><div align="center">Exporta&ccedil;&atilde;o Fiscal / Cont&aacute;bil</div></td>
        </tr>
        <tr>
            <td class="TextoCampos">Sistema:</td>
            <td colspan="3" class="CelulaZebra2"><select name="sistema" class="inputtexto" id="sistema" onChange="javascript:verificaSistema();">
                    <option value="mf" selected>NG Fiscal (Mastermaq)</option>
                    <option value="mc">NG Contábil (Mastermaq)</option>
                    <option value="ef">E-Fiscal (FolhaMatic)</option>
                    <option value="g5">G5-Phoenix (ContMatic)</option>
                    <option value="fc">Phoenix Contábil (ContMatic)</option>
                    <option value="pr">Prosoft</option>
                    <option value="gc">Fiscal (GCI)</option>
                    <option value="me">Fiscal (Mega Sistemas)</option>
                    <option value="ebs">Contábil (EBS Sistemas)</option>
                    <option value="f_ebs">Fiscal (EBS Sistemas)</option>
                    <option value="fla_ebs">Folha (EBS Sistemas)</option>
                    <option value="ad">Contábil (Alterdata)</option>
                    <option value="sci">Contábil (SCI)</option>
                    <option value="dominio">Contábil (Domínio)</option>
                    <option value="fortes_c">Contábil (Fortes)</option>
                    <option value="ff">Fiscal (Fortes)</option>
                    <option value="folha_fortes">Folha (Fortes)</option>
                </select></td>
        </tr>
        <tr>
            <td class="TextoCampos">Informe o período:</td>
            <td colspan="3" class="CelulaZebra2">
                <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                       onblur="alertInvalidDate(this)" class="fieldDate">
                e
                <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                       onblur="alertInvalidDate(this)" class="fieldDate">
            </td>
        </tr>
        <tr name="tr_serie" id="tr_serie">
            <td width="25%" class="TextoCampos">Apenas a s&eacute;rie: </td>
            <td width="25%" height="24" class="CelulaZebra2"><span class="CelulaZebra2"><strong>
                        <input name="serie" type="text" class="inputtexto" id="serie" size="3" maxlength="3">
                    </strong></span></td>
            <td width="25%" class="TextoCampos">N&ordm; da empresa no Fiscal: </td>
            <td width="25%" class="CelulaZebra2"><span class="CelulaZebra2"><strong>
                        <input name="empresa" type="text" class="inputtexto" id="empresa" value="001" size="7" maxlength="7">
                    </strong></span></td>
        </tr>
        <tr id="tr_titulo_contabil" name="tr_titulo_contabil" style="display:none;">
            <td class="TextoCampos">Gerar movimentos de:</td>
            <td colspan="3" class="CelulaZebra2">
                    <input name="chvendas" type="checkbox" id="chvendas" value="checkbox" checked>
                    Vendas (CT-e(s) e Notas de servi&ccedil;os)
                    <br>
                    <input name="chcompras" type="checkbox" id="chcompras" value="checkbox" checked>
                    Compras
                    <br><input name="chtransferencias" type="checkbox" id="chtransferencias" value="checkbox" checked>
                    Transferencias/Suprimentos de caixa
                    <div id="divContCancelados" style="display: none;">
                    <input name="chctscancelados" type="checkbox" id="chctscancelados" value="checkbox">
                    CT(s) e/ou NFS(s) canceladas  
                    </div>
            </td>
        </tr>
        <tr name="tr_filial" id="tr_filial">
            <td class="TextoCampos">Apenas a filial: </td>
            <td colspan="3" class="CelulaZebra2">
                <input name="fi_abreviatura_mmq" type="text" class="inputReadOnly" id="fi_abreviatura_mmq" style="" value="<%=Apoio.getUsuario(request).getFilial().getAbreviatura()%>" size="20"
                       readonly>
                <%if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 0 && acao.equals("iniciar")) {%>
                <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial').value = 0;javascript:getObj('fi_abreviatura_mmq').value = '';"></strong>
                <%}%></td>
        </tr>
        <tr name="trTipoFiscal" id="trTipoFiscal">
            <td class="TextoCampos">Apenas o Tipo:</td>
            <td class="CelulaZebra2">
                <select name="apenasTipoFiscal" class="inputtexto" id="apenasTipoFiscal" onClick="javascript:mostraContratoFrete();">
                    <option value="" selected>Ambas</option>
                    <option value="E">Apenas Entradas</option>
                    <option value="S">Apenas Saídas</option>
                </select>
            </td>
            <td class="TextoCampos" colspan="2">
                <div align="left" name="divContratoFreteNGFiscal" id="divContratoFreteNGFiscal"><input name="chkContratoFreteNGFiscal" type="checkbox" id="chkContratoFreteNGFiscal" value="checkbox">Acrescentar contratos de fretes.</div>
            </td>
        </tr>
        <tr> 
            <td colspan="4"> <div align="left">
                    <table width="100%" border="0" cellpadding="1" cellspacing="1">
                        <tr>
                            <td width="58%" class="CelulaZebra2"><strong>Descri&ccedil;&atilde;o do arquivo</strong></td>
                            <td width="22%" class="CelulaZebra2"><strong>Nome</strong></td>
                            <td width="20%" class="CelulaZebra2">&nbsp;</td>
                        </tr>
                        <%if (cfg.getIsFiscal()) {%>
                        <tr class="CelulaZebra2" name="tr_gci_cliente" id="tr_gci_cliente" style="display:none;">
                            <td>Dados dos clientes para o Fiscal (GCI).</td>
                            <td>CLIEINT.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './CLIEINT.txt0?modelo=clieint';});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_gci_fornecedor" id="tr_gci_fornecedor" style="display:none;">
                            <td>Dados dos fornecedores para o Fiscal (GCI).</td>
                            <td>FORALM.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './FORALM.txt0?modelo=foralm';});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_gci_fiscals" id="tr_gci_fiscals" style="display:none;">
                            <td>Dados das saídas (CT, NFS, GSM do gwLogis) para o Fiscal (GCI).</td>
                            <td>FISCALS.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './FISCALS.txt0?modelo=fiscals&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_gci_conhint" id="tr_gci_conhint" style="display:none;">
                            <td>Dados da carga Transportada para o Fiscal (GCI).</td>
                            <td>CONHINT.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './CONHINT.txt0?modelo=conhint&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_mega_movimentos" id="tr_mega_movimentos" style="display:none;">
                            <td>Dados das saídas (CT, NFS) para o Fiscal (MEGA).</td>
                            <td>MOVIMENTO.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './MOVIMENTO.txt0?modelo=movimento_mega&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_mega_itens" id="tr_mega_itens" style="display:none;">
                            <td>Dados dos itens (CT, NFS) para o Fiscal (MEGA).</td>
                            <td>ITENS.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './ITENS.txt0?modelo=itens_mega&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_mega_nf_cte" id="tr_mega_nf_cte" style="display:none;">
                            <td>Dados das NF(s) do(s) CTe(s) para o Fiscal (MEGA).</td>
                            <td>NF_CTE.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './NF_CTE.txt0?modelo=nf_mega&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_mega_cliente" id="tr_mega_cliente" style="display:none;">
                            <td>Dados dos clientes para o Fiscal (MEGA).</td>
                            <td>CLIENTE.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './CLIENTE.txt0?modelo=cliente_mega&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_prosoft_src" id="tr_prosoft_src" style="display:none;">
                            <td>Dados dos clientes para o Prosoft.</td>
                            <td>SRC.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './SRC.txt0?modelo=prosoft';});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_src" id="tr_masterFiscal_src">
                            <td>Dados dos clientes para o NG Fiscal.</td>
                            <td>SRC.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './SRC.txt0?modelo=src&isContrato='+$('chkContratoFreteNGFiscal').checked;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_mater" id="tr_masterFiscal_mater">
                            <td>Dados dos produtos para o NG Fiscal.</td>
                            <td>MATER.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './MATER.txt0?modelo=mater&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_dupls" id="tr_masterFiscal_dupls">
                            <td>Dados das duplicatas para o NG Fiscal.</td>
                            <td>DUPLS.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './dupls'+$('empresa').value+'.txt0?modelo=dupls&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_ctr" id="tr_masterFiscal_ctr">
                            <td rowspan="9">Dados dos Lançamentos para o NG Fiscal.</td>
                            <td >ctr.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './ctr'+$('empresa').value+'.txt0?modelo=ctr&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvim" id="tr_masterFiscal_fmvim">
                            <td>fmvim.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvim'+$('empresa').value+'.txt0?modelo=fmvim&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value + '&isContrato='+$('chkContratoFreteNGFiscal').checked;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvi2" id="tr_masterFiscal_fmvi2">
                            <td>fmvi2.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvi2'+$('empresa').value+'.txt0?modelo=fmvi2&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value+ '&isContrato='+$('chkContratoFreteNGFiscal').checked;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvi4" id="tr_masterFiscal_fmvi4">
                            <td>fmvi4.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvi4'+$('empresa').value+'.txt0?modelo=fmvi4&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvi5" id="tr_masterFiscal_fmvi5">
                            <td>fmvi5.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvi5'+$('empresa').value+'.txt0?modelo=fmvi5&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvi6" id="tr_masterFiscal_fmvi6">
                            <td>fmvi6.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvi6'+$('empresa').value+'.txt0?modelo=fmvi6&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvi7" id="tr_masterFiscal_fmvi7">
                            <td>fmvi7.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvi7'+$('empresa').value+'.txt0?modelo=fmvi7&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_fmvi8" id="tr_masterFiscal_fmvi8">
                            <td>fmvi8.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './fmvi8'+$('empresa').value+'.txt0?modelo=fmvi8&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value+'&tipoFiscal='+$('apenasTipoFiscal').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterFiscal_data" id="tr_masterFiscal_data">
                            <td>data.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './data.txt0?modelo=data&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_eFiscal" id="tr_eFiscal" style="display:none;">
                            <td>Dados dos Lan&ccedil;amentos para o E-Fiscal. </td>
                            <td>eFiscal.txt</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './eFiscal.txt0?modelo=eFiscal&numeroEmpresa='+$('empresa').value+'&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_g5" id="tr_g5" style="display:none; ">
                            <td>Dados dos Lan&ccedil;amentos para o G5 Phoenix. </td>
                            <td>empresa.Nmm</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './'+$('empresa').value+'.Nmm?numeroEmpresa='+$('empresa').value+'&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&serie='+$('serie').value+'&idfilial='+$('idfilial').value;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <%}
                        if (cfg.getIsContabil()) {%>
                        <tr class="CelulaZebra2" name="tr_contimatic" id="tr_contimatic" style="display:none; ">
                            <td>Dados dos Lan&ccedil;amentos contábeis para o Phoenix contábil. </td>
                            <td>empresa.MAA</td>
                            <td>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){document.location.href = './'+$('empresa').value+'.MAA?modelo=ctbil&submodelo=phoenix&numeroEmpresa='+$('empresa').value+'&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    <div align="center">baixar
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_masterContabil" id="tr_masterContabil" style="display:none; ">
                            <td>Dados dos lan&ccedil;amentos para o NG Cont&aacute;bil. </td>
                            <td>CTBIL.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBIL'+$('empresa').value+'.txt14?modelo=ctbil&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt14?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_ebsContabil" id="tr_ebsContabil" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o Cont&aacute;bil (EBS Sistemas).</td>
                            <td>LOTDnnnn.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './LOTDNNNN.txt14?modelo=ctbil&submodelo=ebs&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt14?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_sciContabil" id="tr_sciContabil" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o Cont&aacute;bil (SCI).</td>
                            <td>SCI.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './SCI.txt14?modelo=ctbil&submodelo=sci&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt14?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_dominioContabil" id="tr_dominioContabil" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o Cont&aacute;bil (Domínio).</td>
                            <td>Dominio.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './Dominio.txt14?modelo=ctbil&submodelo=dominio&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked+'&codempresa='+$('empresa').value;});">
                                    baixar</div>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt14?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_Alterdata" id="tr_Alterdata" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o Cont&aacute;bil (EBS Sistemas).</td>
                            <td>LOTDnnnn.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './LOTDNNNN.txt14?modelo=ctbil&submodelo=ad&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt14?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_ebsFiscal" id="tr_ebsFiscal1" style="display:none;">
                            <td>
                                <label>Dados dos lan&ccedil;amentos para o EBS Sistemas (Entradas).</label>
                                <select id="tipoArqEnt" name="tipoArqEnt" class="inputtexto">
                                    <option value="ambos">Ambos</option>
                                    <option value="prods">Produtos</option>
                                    <option value="servs">Serviços</option>
                                </select>
                            </td>
                            <td>NOTAENT.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){
//                                                                                var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                                                                                window.location.href = './NOTAENT.txt0?modelo=ficalESB&submodelo=entrada&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked+'&tipoArqEnt='+$('tipoArqEnt').value;});">
                                    baixar</div>
<!--                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt0?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>-->
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_ebsFiscal" id="tr_ebsFiscal2" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o EBS Sistemas (Saidas).</td>
                            <td>NOTASAI.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){
//                                                                                var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                                                                                window.location.href = './NOTASAI.txt0?modelo=ficalESB&submodelo=saida&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
<!--                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt0?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>-->
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_ebsFiscal" id="tr_ebsFiscal3" style="display:none;">
                            <td>Dados dos itens para o EBS Sistemas.</td>
                            <td>ITEM.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){
//                                                                                var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                                                                                window.location.href = './ITEM.txt0?modelo=ficalESB&submodelo=item&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
<!--                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt0?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>-->
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_ebsFiscal" id="tr_ebsFiscal4" style="display:none;">
                            <td>Dados dos clientes/fornecedores para o EBS Sistemas.</td>
                            <td>CLIFOR.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){
//                                                                                var pop = window.open('about:blank', 'pop', 'width=210, height=500');
                                                                                window.location.href = './CLIFOR.txt0?modelo=ficalESB&submodelo=participante&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    baixar</div>
<!--                                <div class="linkEdi tar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt0?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>-->
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_ebsFolha" id="tr_ebsFolha" style="display:none;">
                            <td>Dados da Folha de Pagamento para o EBS Sistemas.</td>
                            <td>FOLHA.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){
                                    window.location.href = './FOLHA.txt0?modelo=folhaESB&submodelo=saida&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value;});">
                                    baixar</div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_fortes_contabil" id="tr_fortes_contabil" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o Cont&aacute;bil (Fortes).</td>
                            <td>Fortes.txt</td>
                            <td>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './Fortes.txt14?modelo=ctbil&submodelo=fortes&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked+'&codempresa='+$('empresa').value;});">
                                    baixar</div>
                                <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){document.location.href = './CTBILVALIDACAO'+$('empresa').value+'.txt14?modelo=ctbilT&dtinicial='+$('dtinicial').value+'&dtfinal='+$('dtfinal').value+'&idfilial='+$('idfilial').value+'&serie='+$('serie').value+'&vendas='+$('chvendas').checked+'&compras='+$('chcompras').checked+'&transferencias='+$('chtransferencias').checked+'&cancelados='+$('chctscancelados').checked;});">
                                    validar
                                </div>
                            </td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_fortes_fiscal" id="tr_fortes_fiscal" style="display:none;">
                            <td>Dados dos lan&ccedil;amentos para o Fiscal</td>
                            <td>FORTES.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){fortes()});">
                                <div align="center">baixar</div>
                            </div></td>
                        </tr>
                        <tr class="CelulaZebra2" name="tr_fortes_folha" id="tr_fortes_folha" style="display:none;">
                            <td>Dados da folha de pagamento para o sistema Fortes</td>
                            <td>folha.PS</td>
                            <td>
                                <div class="linkEditar" onClick="tryRequestToServer(function(){folha_fortes()});">
                                    <div align="center">baixar</div>
                                </div>
                            </td>
                        </tr>
                        <%}%>
                    </table>
                </div></td>
        </tr><tr>
            <td height="50" colspan="4" class="TextoCampos"><div align="left" class="style5">ATENÇÃO: Ao clicar em baixar será sugerido o nome do arquivo com a extensão <span class="style4">.txt0</span>, o ideal é que seja <strong>.txt</strong>, sendo assim apague o n&uacute;mero <strong>0</strong> no final do nome do arquivo antes de salvar.</div></td>
        </tr>
    </table>
    <%}%><br>
    <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoCte() != 'N') {%>
    <form action="exportacao.zip?acao=CTe" id="formularioCTe" name="formularioCTe" method="post" target="pop">
        <table width="60%" align="center" class="bordaFina" >
            <tr style="display:none">
                <td colspan="3">

                </td>
            </tr>
            <tr>
                <td colspan="3" align="center" class="tabela">Conhecimento de Transporte Eletrônico (XML)</td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <input type="radio" name="tipo" checked id="rd_periodo" value="periodo"/>
                    Período entre : 
                    <input type="text" size="9" maxlength="10" class="fieldDate" name="dataDe" id="dataDe" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)">
                    a
                    <input type="text" size="9" maxlength="10" class="fieldDate" name="dataAte" id="dataAte" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)">
                </td>
                <td class="TextoCampos">
                    <input type="radio" name="tipo" id="rd_pedido" value="pedido"/>Número do Pedido : 
                    <input type="text" id="numeroPedido" name="numeroPedido" class="inputtexto" size="10" maxlength="20"/>
                </td>
                <td class="TextoCampos">
                    <input type="radio" name="tipo" id="rd_romaneio" value="romaneio"/>Número do Romaneio : 
                     <input type="text" id="numeroRomaneio" name="numeroRomaneio" class="inputtexto" size="10" maxlength="20"/>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <input type="radio" name="tipo"  id="rd_fatura" value="fatura"/>
                    Número da Fatura: 
                    <input type="text" size="10" maxlength="20" class="inputtexto" name="numeroFatura" id="numeroFatura">
                    Ano:
                    <input type="text" size="5" maxlength="4" class="inputtexto" name="anoFatura" id="anoFatura">
                </td>
                <td class="TextoCampos">
                    <input type="radio" name="tipo"  id="rd_carga" value="carga"/>
                    Número da Carga: 
                    <input type="text" size="10" maxlength="20" class="inputtexto" name="numeroCarga" id="numeroCarga">
                </td>
                <td class="TextoCampos">
                    <input type="radio" name="tipo" id="rd_manifesto" value="manifesto"/>
                    Número da Manifesto: 
                    <input type="text" size="10" maxlength="20" class="inputtexto" name="numeroManifesto" id="numeroManifesto">
                </td>
            </tr>
            <tr style="display:none">
                <td class="TextoCampos" width="29%">
                    Apenas a série:
                </td>
                <td class="CelulaZebra2" colspan="2" >
                    <input type="text" size="6" class="inputtexto" name="serie" id="serie">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" width="33%">
                    Apenas a filial:
                </td>
                <td class="CelulaZebra2" width="33%">  
                    <%
                        BeanFilial beanFilial = new BeanFilial();
                        ResultSet rsFili = beanFilial.all(Apoio.getUsuario(request).getConexao());
                    %>
                    <select name="idFilial" id="idFilial" class="inputtexto">
                        <%while (rsFili.next()) {%>
                        <option value="<%=rsFili.getInt("idfilial")%>" <%=Apoio.getUsuario(request).getFilial().getIdfilial() == rsFili.getInt("idfilial") ? "SELECTED" : ""%>><%=rsFili.getString("abreviatura")%></option>
                        <%}%>
                    </select>
                </td>
                <td class="CelulaZebra2" width="34%" >
                    <div align="center">
                        <input type="checkbox" name="mostrarRelatorio" id="mostrarRelatorio" >
                        Exibir relação de arquivos.
                    </div>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" >Apenas o Cliente:</td>
                <td class="CelulaZebra2" colspan="2">
                    <input type="hidden" name="idconsignatario1" id="idconsignatario1" value="0">
                    <input type="hidden" name="consigCte1" id="consigCte1" value="">
                    <input name="con_rzs1" type="text" id="con_rzs1" size="40" value="" readonly="true" class="inputReadOnly8pt">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Consignatario_CTe');">
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('consigCte1').value = '0';getObj('con_rzs1').value = 'Todos os consignatarios';">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" >Apenas o grupo de clientes:</td>
                <td class="CelulaZebra2" colspan="2">
                    <input type="hidden" name="grupo_id" id="grupo_id" value="0"/>
                    <input name="grupo" type="text" id="grupo" size="40" value="" readonly="true" class="inputReadOnly8pt"/>
                    <input name="localiza_grupo_cliente" type="button" class="botoes" id="localiza_grupo_cliente" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.GRUPO_CLI_FOR%>', 'Grupo_de_Clientes');"/>
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('grupo_id').value = '0';getObj('grupo').value = 'Todos os Grupos de Clientes';"/>
                </td>
            </tr>
            
            
            <tr>
                <td height="24" class="TextoCampos"> Apenas o Remetente: </td>
                <td colspan="3" class="CelulaZebra2">
                    <strong> 
                        <strong>
                            
                            <input name="rem_rzs" type="text" class="inputReadOnly8pt" id="rem_rzs" size="40" maxlength="80" readonly="true">
                            <input name="rem_fantasia" type="hidden" id="rem_fantasia" value="">
                            <input type="hidden" name="idremetente" id="idremetente">
                        </strong>
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaclienteXml();">
                        <strong>
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:getObj('idremetente').value = 0;javascript:getObj('rem_rzs').value = 'Todos os remetentes';">
                        </strong>
                    </strong>
                </td>
            </tr>
            <tr>
                <td class="TextoCampos">Apenas o Destinatário:</td>
                <td class="CelulaZebra2" colspan="3">
                    <input name="dest_rzs" type="text" id="dest_rzs" value="" size="40" readonly="true" class="inputReadOnly8pt">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                    <input type="hidden" name="iddestinatario" id="iddestinatario" value="">
                </td>
            </tr>
<!--            <tr>
                    <td class="TextoCampos">Número do Pedido:</td>
                    <td class="CelulaZebra2" colspan="3">
                        <input type="text" id="numeroPedido" name="numeroPedido" class="inputtexto" size="10" maxlength="20"/>
                    </td>
            </tr>
            <tr>
                    <td class="TextoCampos">Número do Romaneio:</td>
                    <td class="CelulaZebra2" colspan="3">
                        <input type="text" id="numeroRomaneio" name="numeroRomaneio" class="inputtexto" size="10" maxlength="20"/>
                    </td>
            </tr>-->
            
            <tr>
                <td class="TextoCampos" >
                    Modelo:
                </td>
                <td class="CelulaZebra2" colspan="2" >
                    <select name="modelo" id="modelo" class="inputtexto">
                        <option value="cte" selected>Envio (Recep&ccedil;&atilde;o) / Cancelamento</option>
                        <option value="apenasEnvio" >Apenas Envio (Recep&ccedil;&atilde;o)</option>
                        <option value="apenasCancelados" >Apenas Cancelados</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="CelulaZebra2" >
                    <div align="center">
                        <input type="button" value="  EXPORTAR  " class="inputbotao" onclick="tryRequestToServer(function(){imprimirCTe();})"/>
                    </div>
                </td>
            </tr>
        </table>
    </form>

    <br>        
    <%}%>
    <%if (Apoio.getUsuario(request).getFilial().getStUtilizacaoMDFe() != 'N') {%>
    <form action="exportacao.zip?acao=MDFe" id="formularioMDFe" name="formularioMDFe" method="post" target="pop">
        <table width="60%" align="center" class="bordaFina" >
            <tr style="display:none">
                <td colspan="3">

                </td>
            </tr>
            <tr>
                <td colspan="3" align="center" class="tabela">Manifesto Eletrônico (XML)</td>
            </tr>
            <tr>
                <td class="TextoCampos" width="29%">
                    Informe o período:
                </td>
                <td class="CelulaZebra2" colspan="2" >
                    <input type="text" size="10" maxlength="10" class="fieldDate" name="dataDeMDFe" id="dataDeMDFe" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)">
                    a
                    <input type="text" size="10" maxlength="10" class="fieldDate" name="dataAteMDFe" id="dataAteMDFe" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)">
                </td>
            </tr>
            <tr style="display:none">
                <td class="TextoCampos" width="29%">
                    Apenas a série:
                </td>
                <td class="CelulaZebra2" colspan="2" >
                    <input type="text" size="6" class="inputtexto" name="serieMDFe" id="serieMDFe">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" width="33%">
                    Apenas a Filial de Origem:
                </td>
                <td class="CelulaZebra2" width="33%">  
                    <%
                        BeanFilial beanFilial = new BeanFilial();
                        ResultSet rsFili = beanFilial.all(Apoio.getUsuario(request).getConexao());
                    %>
                    <select name="idFilialOrigemMDFe" id="idFilialOrigemMDFe" class="inputtexto">
                        <%while (rsFili.next()) {%>
                        <option value="<%=rsFili.getInt("idfilial")%>" <%=Apoio.getUsuario(request).getFilial().getIdfilial() == rsFili.getInt("idfilial") ? "SELECTED" : ""%>><%=rsFili.getString("abreviatura")%></option>
                        <%}%>
                    </select>
                </td>
                <td class="CelulaZebra2" width="34%" >
<!--                    <div align="center">
                        <input type="checkbox" name="mostrarRelatorio" id="mostrarRelatorio" >
                        Exibir relação de arquivos.
                    </div>-->
                </td>
            </tr>
            <tr>
                <td colspan="3" class="CelulaZebra2" >
                    <div align="center">
                        <input type="button" value="  EXPORTAR  " class="inputbotao" onclick="tryRequestToServer(function(){imprimirMdfe()})"/>
                    </div>
                </td>
            </tr>
        </table>
    </form>

    <br>        
    <%}%>
    <%if (Apoio.getUsuario(request).getAcesso("caddespesa") >= NivelAcessoUsuario.LER.getNivel()) {%>
    <form action="exportacao.zip?acao=imgdespesas" id="formulario_imgdespesas" name="formulario_mgdespesas" method="post" target="pop">
        <table width="60%" border="0" class="bordaFina" align="center">

            <tr>
                <td colspan="3" align="center" class="tabela"> Exportar imagens das Despesas</td>
            </tr>

            <tr>
                <td class="TextoCampos">
                    Informe o período:
                </td>
                <td class="CelulaZebra2" colspan="2" >
                    <input type="text" size="10" maxlength="10" class="fieldDate" name="dataDe" id="dataDe" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)">
                    a
                    <input type="text" size="10" maxlength="10" class="fieldDate" name="dataAte" id="dataAte" value="<%=Apoio.getDataAtual()%>" onblur="alertInvalidDate(this)">
                </td>
            </tr>

            <tr>
                <td class="TextoCampos" width="29%">
                    Apenas a Filial :
                </td>
                <td class="CelulaZebra2" width="30%" >  
                    <%
                        BeanFilial beanFilial = new BeanFilial();
                        ResultSet rsFili = beanFilial.all(Apoio.getUsuario(request).getConexao());
                    %>
                    <select name="idFilial" id="idFilial" class="inputtexto">
                        <option value="0" selected="true"> Todas </option>
                        <%while (rsFili.next()) {%>
                        <option value="<%=rsFili.getInt("idfilial")%>" ><%=rsFili.getString("abreviatura")%></option>
                        <%}%>
                    </select>
                </td>
            </tr><tr>
                <td class="TextoCampos" width="29%">
                    Apenas o Fornecedor :
                </td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="fornecedor" type="text" class="inputReadOnly" id="fornecedor" size="30" maxlength="80" readonly="true">
                    <input type="hidden" name="idfornecedor" id="idfornecedor" value="0">
                    <input name="localiza_fornecedor" type="button" class="botoes" id="localiza_fornecedor" onClick="javascript:localizafornecedor();" value="...">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Fornecedor" onClick="javascript:getObj('idfornecedor').value = 0;javascript:getObj('fornecedor').value = '';">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos" width="29%">
                    Apenas as séries :
                </td>
                <td colspan="3" class="CelulaZebra2">
                    <span class="CelulaZebra2"><strong>
                        <input name="imgserie" type="text" class="inputtexto" id="imgserie" size="5" maxlength="3">
                    </strong></span>
                </td>                
            </tr>
            <tr>
                <td class="TextoCampos" width="29%">
                    Apenas a espécie :
                </td>
                <td colspan="3" class="CelulaZebra2" width="29%">
                     <%Especie es = new Especie();
                      ResultSet rs = es.all(Apoio.getUsuario(request).getConexao());%>
                    <select name="especieimg" id="especieimg" class="inputtexto">
                        <option value="">Nenhuma</option>
                        <%while (rs.next()) {%>
                        <option value="<%=rs.getString("especie")%>" <%=(desp.getEspecie_().getEspecie().equals(rs.getString("especie")) ? "selected" : "")%> ><%=rs.getString("especie") + " - " + rs.getString("descricao")%></option>
                        <%}%>  
                    </select>
                </td>
            </tr>
            <tr>
                <td class="celulaZebra2" colspan="3">
                    <div align="center">
                        <input type="submit" class="inputBotao" value="  EXPORTAR  "> 
                    </div>
                </td>
            </tr>
        </table>
    </form> 
    <br>
    <%}%>

    <table width="60%" border="0" class="bordaFina" align="center">
        <td width="149"></tr>  <tr class="tabela"> 
            <td colspan="4"><div align="center">SEF / SINTEGRA/ SPED</div></td>
        </tr>
        <tr>
            <td height="24" class="TextoCampos">Informe o per&iacute;odo: </td>
            <td width="328" colspan="3" class="CelulaZebra2"><strong>
                    <input name="dtinicialsef" type="text" id="dtinicialsef" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                           onblur="alertInvalidDate(this)" class="fieldDate">
                </strong>e<strong>
                    <input name="dtfinalsef" type="text" id="dtfinalsef" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                           onblur="alertInvalidDate(this)" class="fieldDate">
                </strong></td>
        </tr>
        <tr> 
            <td height="24" class="TextoCampos">Apenas a(s) s&eacute;rie(s):  </td>
            <td class="CelulaZebra2">
                <span class="CelulaZebra2">
                    <input name="seriesef" type="text" class="inputtexto" id="seriesef" size="5" maxlength="10">(Saidas)                        
                </span>
            </td>
            <td colspan="2" class="CelulaZebra2">
                <span class="CelulaZebra2">
                    <input name="seriesefEntrada" type="text" class="inputtexto" id="seriesefEntrada" size="5" maxlength="10">(Entradas)                        
                </span>
            </td>
        </tr>
        <tr>
            <td height="24" class="TextoCampos">Apenas a filial:</td>
            <td height="24" colspan="3" class="CelulaZebra2">
                <input name="fi_abreviatura_sef" type="text" class="inputReadOnly" id="fi_abreviatura_sef" value="<%=Apoio.getUsuario(request).getFilial().getAbreviatura()%>" size="20" readonly>
                <%if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 0 && acao.equals("iniciar")) {%>
                <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                <%}%></td>
        </tr>
        <tr>
            <td height="56" colspan="4"><div align="left">
                    <table width="100%" height="50" border="0" cellpadding="1" cellspacing="1">
                        <tr>
                            <td width="71%" class="CelulaZebra2"><strong>Descri&ccedil;&atilde;o do arquivo </strong></td>
                            <td width="17%" class="CelulaZebra2"><strong>Nome</strong></td>
                            <td width="12%" class="CelulaZebra2">&nbsp;</td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td>Arquivo SEF (Apenas para o estado de PE).</td>
                            <td>SEF.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){sef()});">
                                    <div align="center">baixar </div>
                                </div></td>
                        </tr> 
                        <tr class="CelulaZebra2">
                            <td>
                                <label>Arquivo SEF 2.0 (Apenas para o estado de PE).</label><br/>
                                <input name="chkEntradasSEFFrota" type="checkbox" id="chkEntradasSEFFrota" onclick="visualizarEDOC();" value="checkbox">Acrescentar entradas (gwFrota).<br/>
                                <input name="chkEntradasSEFLogis" type="checkbox" id="chkEntradasSEFLogis" onclick="visualizarEDOC();" value="checkbox">Acrescentar entradas/saidas (gwLogis).<br/>
                                <input name="chkAWBSEF" type="checkbox" id="chkAWBSEF" >Acrescentar AWB (Entradas)<br/>
                                <input name="chkInventario" type="checkbox" id="chkInventario" >Acrescentar Inventário<br/>
                                Indicador da data do inventário:
                                <select id="indicadorsef2" name="indicadorsef2" class="inputtexto" style="width:200pt;">
                                    <option value="0">Levantado no último dia do ano civil, coincidente com a data do balanço</option>
                                    <option value="1">Levantado no último dia do ano civil, divergente da data do balanço</option>
                                    <option value="2">Levantado na data do balanço, divergente do último dia do ano civil</option>
                                    <option value="3">Levantado em data divergente da data do último balanço e divergente do último dia do ano civil</option>
                                </select><br/>
                                Indicador de propriedade/posse do item: 
                                <select id="indicadorpropsef2" name="indicadorpropsef2" class="inputtexto" style="width:200pt;"> 
                                    <option value="0">Item de propriedade do informante e em sua posse</option>
                                    <option value="1">Item de propriedade do informante em posse de terceiros</option>
                                    <option value="2">Item de propriedade de terceiros em posse do informante</option>
                                </select><br/>
                            </td>
                            <td>SEF.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){sef2()});">
                                    <div align="center">baixar </div>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra2" id="trEDOC" style="display: none">
                            <td>
                                <label>Arquivo eDOC (Apenas para o estado de PE).</label>                            
                            </td>
                            <td>eDoc.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){eDoc()});">
                                    <div align="center">baixar </div>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td>Arquivo SINTEGRA.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <input name="chkEntradasSintegra" type="checkbox" id="chkEntradasSintegra" value="checkbox">Acrescentar entradas (gwFrota).
                            </td>
                            <td>SINTEGRA.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){sintegra()});">
                                    <div align="center">baixar</div>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td>Arquivo Valida Paran&aacute; (Apenas para o estado do PR). </td>
                            <td>VALIDA.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){validaParana()});">
                                    <div align="center">baixar</div>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra2">
                        <label><td>Arquivo SPED Fiscal.</label><br/>
                        <input name="chkEntradasSPEDFrota" type="checkbox" id="chkEntradasSPEDFrota" >Acrescentar entradas (gwFrota).<br/>
                        <input name="chkEntradasSPEDLogis" type="checkbox" id="chkEntradasSPEDLogis" >Acrescentar entradas/saidas (gwLogis).<br/>
                        <input name="chkAWB" type="checkbox" id="chkAWB" >Acrescentar AWB (Entradas)
                        </td>
                        <td>SPEDFiscal.txt</td>
                        <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){sped(1)});">
                                <div align="center">baixar</div>
                            </div></td>
                        </tr>
                        <tr class="CelulaZebra2">
                        <label><td>Arquivo SPED PIS/COFINS.</label><br/>
                                <input name="chkEntradasPisCofins" type="checkbox" id="chkEntradasPisCofins" value="checkbox">Acrescentar entradas (gwFrota).<br/>
                            <div style="padding-left: 15px;">
                                <input type="checkbox" id="chkEntradasComprasServicos" name="chkEntradasComprasServicos" checked><label for="chkEntradasComprasServicos">Acrescentar entradas de compras de serviços</label>
                            </div>
                                <input name="chkContratoFretePisCofins" type="checkbox" id="chkContratoFretePisCofins" value="checkbox">Acrescentar Contratos de Fretes (GWTrans).<br/>
                            </td>
                            <td>SPEDPisCofins.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){sped(2)});">
                                    <div align="center">baixar</div>
                                </div></td>
                        </tr>
                    </table>
                </div></td>
        </tr>  
        <tr>
            <td height="50" colspan="4" class="TextoCampos"><div align="left" class="style5">ATENÇÃO: Ao clicar em baixar será sugerido o nome do arquivo com a extensão <span class="style4">.txt1</span>, o ideal é que seja <strong>.txt</strong>, sendo assim apague o n&uacute;mero <strong>1</strong> no final do nome do arquivo antes de salvar.</div></td>
        </tr>
    </table>
    <br>
    <table width="60%" border="0" class="bordaFina" align="center">
        <td width="308">    </tr>
        <tr class="tabela">
            <td colspan="4"><div align="center">EDI</div></td>
        </tr>
        <tr id="trEDIFatura" name="trEDIFatura" style="display:none">
            <td height="24" class="TextoCampos">N&uacute;mero da fatura/ano:</td>
            <td colspan="3" class="CelulaZebra2"><input name="fatura" type="text" class="inputtexto" id="fatura" size="8">
                /
                <input name="ano_fatura" type="text" class="inputtexto" id="ano_fatura" size="3"></td>
        </tr>
        <tr id="trEDIData" name="trEDIData">
            <td height="24" class="TextoCampos">Per&iacute;odo de
                <select name="tipoDataEdi" id="tipoDataEdi" class="inputtexto">
                    <option value="dtemissao" selected>Emiss&atilde;o(CONEMB ou DOCCOB)</option>
                    <option value="dtvenc">Vencimento(DOCCOB)</option>
                    <option value="data_ocorrencia">Entrega(OCOREN)</option>
                </select>
                : </td>
            <td width="266" colspan="3" class="CelulaZebra2"><strong>
                    <input name="dtinicialedi" type="text" id="dtinicialedi" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                           onblur="alertInvalidDate(this)" class="fieldDate">
                </strong>e<strong>
                    <input name="dtfinaledi" type="text" id="dtfinaledi" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                           onblur="alertInvalidDate(this)" class="fieldDate">
                </strong></td>
        </tr>
        <tr>
            <td height="24" class="TextoCampos"> Informe o cliente : </td>
            <td colspan="3" class="CelulaZebra2"><strong> <strong>
                        <input type="hidden" name="idconsignatario2" id="idconsignatario2" value="0">
                        <input type="hidden" name="consigCte2" id="consigCte2" value="">
                        <input name="con_rzs2" type="text" class="inputReadOnly" id="con_rzs2" size="30" maxlength="80" readonly="true">
                        <input name="con_fantasia" type="hidden" id="con_fantasia" value="">
                    </strong>
                    <input name="localiza_cli" type="button" class="botoes" id="localiza_cli" value="..." onClick="javascript:localizacliente();">
                </strong></td>
        </tr>
        <tr name="tr_filial_edi" id="tr_filial_edi" style="display:none; ">
            <td height="24" class="TextoCampos">Apenas a filial:</td>
            <td colspan="3" class="CelulaZebra2"><input name="fi_abreviatura_edi" type="text" class="inputReadOnly" id="fi_abreviatura_edi" value="<%=Apoio.getUsuario(request).getFilial().getAbreviatura()%>" size="20"
                                                        readonly>
                <%if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 0 && acao.equals("iniciar")) {%>
                <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                <%}%>
                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial').value = 0;javascript:getObj('fi_abreviatura_edi').value = '';"></strong></td>
        </tr>
        <tr>
            <td height="24" colspan="4" class="TextoCampos"><div align="center">
                    <input name="chkSped" type="checkbox" id="chkSped" value="checkbox">
                    Gerar o campo nota fiscal com 9 d&iacute;gitos (SPED). </div></td>
        </tr>
        <tr>
            <td height="56" colspan="4"><div align="left">
                    <table width="100%" height="92" border="0" cellpadding="1" cellspacing="1">
                        <tr>
                            <td class="CelulaZebra2"><strong>Descri&ccedil;&atilde;o do arquivo </strong></td>
                            <td class="CelulaZebra2"><strong>Layout </strong></td>
                            <td width="17%" class="CelulaZebra2"><strong>Nome</strong></td>
                            <td width="12%" class="CelulaZebra2">&nbsp;</td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td>Conhecimentos embarcados (CT-e(s)). <span class="TextoCampos">
                                </span></td>
                            <td class="CelulaZebra2">
                                <select name="versaoCONEMB" class="inputtexto" id="versaoCONEMB" onChange="escolheVersaoConemb();">
                                    <!--<option value="bpcs-cremer">BPCS (Cremer S/A)</option>
                                    <option value="docile-conemb">EMS Datasul/Totvs (Docile Ltda)</option>
                                    <option value="gerdau">Gerdau</option>
                                    <option value="mercador">Mercador</option>
                                    <option value="neogrid_conemb">NeoGrid</option>
                                    <option value="nestle">Nestle</option>
                                    <option value="pro3.0a">Proceda 3.0a</option>
                                    <option value="pro3.0aTramontina">Proceda 3.0a (Tramontina)</option>
                                    <option value="pro3.1" selected>Proceda 3.1</option>
                                    <option value="pro3.1betta">Proceda 3.1 (Bettanin)</option>
                                    <option value="pro3.1gko">Proceda 3.1 (GKO)</option>
                                    <option value="pro3.1kimberly">Proceda 3.1 (Kimberly)</option>
                                    <option value="pro4.0">Proceda 4.0 (Aliança)</option>
                                    <option value="pro5.0">Proceda 5.0</option>
                                    <option value="santher3.1-conemb">Santher 3.1</option>
                                    <option value="ricardo-conemb">Ricardo Eletro</option>
                                    <option value="terphane">Terphane</option>
                                    <option value="tivit3.1-conemb">Tivit 3.0 (GDC)</option>
                                    <option value="usiminas">Soluções Usiminas</option>
                                    <option value="webserviceAvon">Avon (Web Service)</option>-->

                                </select>                        
                            </td>
                            <td>CONEMB.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){conemb()});">
                                    <div align="center">baixar </div>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td width="49%">Documentos de cobran&ccedil;as (Faturas). </td>
                            <td width="22%"><select name="versaoDOCCOB" class="inputtexto" id="versaoDOCCOB" onChange="escolheVersaoConemb();">
                                    <!--<option value="intral">EMS Datasul/Totvs (Intral S/A)</option>
                                    <option value="neogrid_doccob">NeoGrid</option>
                                    <option value="pro3.0a-doccob" selected>Proceda 3.0a</option>
                                    <option value="pro3.0a-doccob-alianca">Proceda 3.0a (Aliança)</option>
                                    <option value="pro3.0a-doccob-betta">Proceda 3.0a (Bettanin)</option>
                                    <option value="pro3.0a-doccob-dhl">Proceda 3.0a (DHL)</option>
                                    <option value="pro3.0a-doccob-paulus">Proceda 3.0a (Paulus)</option>                          
                                    <option value="ricardo-doccob">Ricardo Eletro</option>
                                    <option value="roca-doccob">Roca Brasil</option>
                                    <option value="santher3.0a-doccob">Santher 3.0a</option>
                                    <option value="tivit3.0a-doccob">Tivit 3.0a</option>
                                    <option value="pro5.0-doccob">Proceda 5.0</option>
                                    <option value="webserviceAvon">Avon (Web Service)</option>-->
                                </select></td>
                            <td>DOCCOB.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){doccob()});">
                                    <div align="center">baixar</div>
                                </div></td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td height="26">Ocorr&ecirc;ncias de entregas.</td>
                            <td><select name="versaoOCOREN" class="inputtexto" id="versaoOCOREN" onChange="">
                                    <!--<option value="bpcs-cremer-ocoren">BPCS (Cremer S/A)</option>
                                    <option value="docile-ocoren">EMS Datasul/Totvs (Docile Ltda)</option>
                                    <option value="electrolux">Electrolux</option>
                                    <option value="neogrid_ocoren">NeoGrid</option>
                                    <option value="pro3.0a-ocoren">Proceda 3.0a</option>
                                    <option value="pro3.0a-ocoren-alianca">Proceda 3.0a (Aliança)</option>
                                    <option value="pro3.0a-ocoren-hyper">Proceda 3.0a (Hypermarcas)</option>
                                    <option value="pro3.1-ocoren" selected>Proceda 3.1</option>
                                    <option value="pro3.1-ocoren-betta">Proceda 3.1 (Bettanin)</option>
                                    <option value="pro5.0-ocoren">Proceda 5.0</option>
                                    <option value="ricardo-ocoren">Ricardo Eletro</option>
                                    <option value="roca-ocoren">Roca Brasil</option>
                                    <option value="santher3.1-ocoren">Santher 3.1</option>
                                    <option value="tivit3.0a-ocoren">Tivit 3.0a (GDC)</option>-->
                                </select>
                            </td>
                            <td>OCOREN.txt</td>
                            <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){ocoren()});">
                                    <div align="center">baixar</div>
                                </div></td>
                        </tr>
                    </table>
                </div></td>
        </tr>
        <tr>
            <td height="50" colspan="4" class="TextoCampos"><div align="left" class="style5">ATEN&Ccedil;&Atilde;O: Ao clicar em baixar ser&aacute; sugerido o nome do arquivo com a extens&atilde;o <span class="style4">.txt3</span>, o ideal &eacute; que seja <strong>.txt</strong>, sendo assim apague o n&uacute;mero <strong>3</strong> no final do nome do arquivo antes de salvar.</div></td>
        </tr>
    </table>
    <br>
    <table width="60%" border="0" class="bordaFina" align="center">
        <tr class="tabela">
            <td colspan="4"><div align="center">AVERBAÇÃO</div></td>
        </tr>
        <tr>
            <td height="24" class="TextoCampos">Informe o per&iacute;odo: </td>
            <td width="328" colspan="3" class="CelulaZebra2"><strong>
                    <input name="dtinicialAverb" type="text" id="dtinicialAverb" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                           onblur="alertInvalidDate(this)" class="fieldDate">
                </strong>e<strong>
                    <input name="dtfinalAverb" type="text" id="dtfinalAverb" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                           onblur="alertInvalidDate(this)" class="fieldDate">
                </strong></td>
        </tr>    
        <tr>
        <tr>
            <td class="TextoCampos">Apenas a s&eacute;rie: </td>
            <td height="24" class="CelulaZebra2"><span class="CelulaZebra2"><strong>
                        <input name="serieAverbacao" type="text" class="inputtexto" value="U" id="serieAverbacao" size="3" maxlength="3">
                    </strong></span>
            </td>

        </tr>
        <tr>
            <td height="24" class="TextoCampos">Apenas a filial: </td>
            <td height="24" colspan="3" class="CelulaZebra2">
                <input name="fi_abreviatura_ave" type="text" class="inputReadOnly" id="fi_abreviatura_ave"
                       value="<%=Apoio.getUsuario(request).getFilial().getAbreviatura()%>" size="20" readonly>
                <%if (Apoio.getUsuario(request).getAcesso("lanconhfl") > 0 && acao.equals("iniciar")) {%>
                <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                <strong><img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilial').value = 0;javascript:getObj('fi_abreviatura_ave').value = '';"></strong>
                    <%}%>
            </td>
        </tr>
        <td height="56" colspan="4"><div align="left">
                <table width="100%" height="50" border="0" cellpadding="1" cellspacing="1">
                    <tr>
                        <td width="71%" class="CelulaZebra2"><strong>Descri&ccedil;&atilde;o do arquivo </strong></td>
                        <td width="17%" class="CelulaZebra2"><strong>Nome</strong></td>
                        <td width="12%" class="CelulaZebra2">&nbsp;</td>
                    </tr>
                    <tr class="CelulaZebra2">
                        <td>Averbação Tokio Marine.</td>
                        <td>MARINE.txt</td>
                        <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){averbacaoTokioMarine()});">
                                <div align="center">baixar </div>
                            </div></td>
                    </tr>                    
                    <tr class="CelulaZebra2">
                        <td>Averbação Itau Seguros.</td>
                        <td>ITAUSEGUROS.txt</td>
                        <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){averbacaoItauSeguros()});">
                                <div align="center">baixar </div>
                            </div></td>
                    </tr>                    
                    <tr class="CelulaZebra2">
                        <td>
                            <select name="layoutExcel" id="layoutExcel" class="inputTexto">
                                <%for (LayoutExcel layoutExcel : layoutsAverbacaoExcel) {%>
                                <option value="<%=layoutExcel.getView()%>">Averbação <%=layoutExcel.getDescricao()%></option>  
                                <%}%>
                            </select>
                        </td>
                        <td>layout.xls</td>
                        <td><div class="linkEditar" onClick="javascript:tryRequestToServer(function(){averbacaoExcel()});">
                                <div align="center">baixar</div>
                            </div></td>
                    </tr>                    
                </table>
            </div></td>
    </tr>
    <tr>
        <td height="50" colspan="4" class="TextoCampos"><div align="left" class="style5">ATENÇÃO: Ao clicar em baixar será sugerido o nome do arquivo com a extensão <span class="style4">.txt9</span>, o ideal é que seja <strong>.txt</strong>, sendo assim apague o n&uacute;mero <strong>9</strong> no final do nome do arquivo antes de salvar.</div></td>
    </tr>
</table>
<br>
</body>
</html>
