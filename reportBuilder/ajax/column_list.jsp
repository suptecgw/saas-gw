<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<link href="estilo.css" rel="stylesheet" type="text/css">
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_7_2.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script type="text/javascript" language="javascript"> 
    var indexColuna;
    var indexOrdem
    var indexOrdenacao = 1;
    
    function addFilterColuna(index){
         indexColuna = index;
    }

    function addOrdemColuna(index){
         indexOrdem = index;
    }
    jQuery(function() {

        window.REPORT_BUILDER_COLUMN_CONTROLLER = {
            
            init : function() {
              
                this.bindEvents();
            },
            
            bindEvents : function() {
                AlternarAbas('tdAbaColunas', 'abaColunas',varAbas);
                mostrarEmail();
                var self = this;
                var idEmail='<c:out value="${relatorio.idRemetente}"/>';
                var destinatario='<c:out value="${relatorio.destinatarioEmail}"/>';
                var assunto='<c:out value="${relatorio.assuntoEmail}"/>';
                var emailCC='<c:out value="${relatorio.emCopiaEmail}"/>';

                jQuery("#emails").val(idEmail == undefined || idEmail == '' ? '0' : idEmail );     
                jQuery("#destinatarioEmail").val(destinatario == undefined || destinatario == '' ? "" : destinatario );     
                jQuery("#assuntoEmail").val(assunto == undefined || assunto == '' ? "" : assunto );     
                jQuery("#ccEmail").val(emailCC == undefined || emailCC == '' ? "" : emailCC );
                    
                var cron = null;
                    
                <c:forEach var="tarefa" items="${relatorio.agenda}" varStatus="status">
                    cron = new Cron('${tarefa.id}','${tarefa.cronExpression}','${tarefa.nomeArquivo}','${tarefa.idAgenda}');
                    addCron(cron);
                </c:forEach>
                
                jQuery('input[name=addFilter]').click(function() {
                    var columnName = jQuery(this).parents('tr').find('.column-selection_'+indexColuna).val();
                    var columnLabel = jQuery(this).parents('tr').find('.column-label_'+indexColuna).text();
                    var columnType = jQuery(this).parents('tr').find(".type_"+indexColuna).val();
                    var operadores = jQuery("#operadores_"+columnName).val();
                    var operadoresArray = (operadores.substr(1,((operadores + "").length-2))).split(",");
                    
                    var columnFiltroObrigatorio = jQuery(this).parents('tr').find('.isFiltroObrigatorio_'+indexColuna).val();
                    
                    
                    var idColuna = 0;
                    self.addFilter(columnName, columnLabel, indexColuna, idColuna, columnType,columnFiltroObrigatorio,operadoresArray);
//                    $(this).attr('disabled', 'disabled');
//                    $(this).removeClass("inputbotao");
//                    $(this).addClass("inputTexto");
//                    $(this).val("filtro já adicionado!");
                });
                
                jQuery('input[name=addOrdem]').click(function() {
                    var columnName = jQuery(this).parents('tr').find('.column-selection_'+indexOrdem).val();
                    var columnLabel = jQuery(this).parents('tr').find('.column-label_'+indexOrdem).text();
                    var idColuna = 0;
                    self.addOrdem(columnName, columnLabel, indexOrdem, idColuna,'');
                });

                jQuery('#reportForm').on("submit", (function(ev) {
                    
                    var reportTitle = jQuery("#report-title").val();
                    var relatorioVisualizar = jQuery("#relatorioVisualizar").val();
                    var idRelatorio = jQuery("#idRelatorio").val();
                    self.doValidate(reportTitle, ev, relatorioVisualizar, idRelatorio);    
                    validarFiltros(ev);
                    
                }));
                <c:if test="${param.acao == 'getColumns'}">
                    <c:forEach items="${columnList}" var="coluna" varStatus="status">
                        if(${coluna.isFiltroObrigatorio}){
                            var operadores = jQuery("#operadores_${coluna.name}").val();
                            var operadoresArray = (operadores.substr(1,((operadores + "").length-2))).split(",");
                            
                            self.addFilter('${coluna.name}', '${coluna.label}', '${status.count}', '${coluna.id}', '${coluna.type}', '${coluna.isFiltroObrigatorio}', operadoresArray);
                        }
                    </c:forEach>
                </c:if>
                    jQuery("#dataDeAuditoria").val('${dataAtualR}');
                    jQuery("#dataAteAuditoria").val('${dataAtualR}');
       
            },
            
            validate : function(reportExists, ev) {
                if (reportExists) {
                    alert("Já existe um relatório cadastrado com este título.");
                    ev.preventDefault();
                    
                } else if (!jQuery('#report-title').val()) {
                    alert("Você deve informar um título para o relatório.");
                    ev.preventDefault();
                    
//                } else if (jQuery('.column-selection:checked').length < 1) {
//                    alert("Selecione pelo menos uma coluna para gerar o relatório.");
//                    ev.preventDefault();                    
                
                }else{
                    var contCheck = 0;
                    for (var i = 1; i <= jQuery('#maxColunas').val(); i++) {
                        if (!(jQuery('.column-selection_'+i+':checked').length < 1)) {
                            contCheck++;
                        }
                    }
                    if (contCheck == 0) {
                        alert("Selecione pelo menos uma coluna para gerar o relatório.");
                        ev.preventDefault();                        
                    }
                }
                
            },
            
            doValidate : function(reportTitle, ev, relatorioVisualizar, idRelatorio) {
                
                var self = this;
                
                jQuery.ajax({
                    url: '<c:url value="/ReportBuilderControlador" />',
                    dataType: "text",
                    method : "post",
                    async : false,
                    data: {
                        reportTitle : reportTitle,
                        relatorioVisualizar : relatorioVisualizar,
                        idRelatorio : idRelatorio,
                        acao : "checkReportExists"
                    },
                    success: function(data) {
                        self.validate(JSON.parse(data).exists, ev);
                    }
                });
            },
            
            addFilter : function(columnName, columnLabel, indexColuna, idColuna, columnType,isFiltroObrigatorio,operadoresArray) {
                
                var options = "<option value='SELECIONE'>Selecione</option>";
                var tipoData = "";
                var isCaseSensitive = "";
                
                for (var i = 0; i < operadoresArray.length; i++) {
                    if (operadoresArray[i].trim() == "IN") {
                        if ((columnType.toUpperCase().indexOf("String".toUpperCase()) != -1)) {//if tipo = String
                            options += "<option value='IN'>Igual a Palavra/Frase</option>";
                        }else {
                            options += "<option value='IN'>Apenas</option>";
                        }
                    }else if (operadoresArray[i].trim() == "NOT_IN") {
                        options += "<option value='NOT_IN'>Exceto</option>";
                    }else if (operadoresArray[i].trim() == "ALL_PARTS") {
                        options += "<option value='ALL_PARTS'>Todas as partes com</option>";
                    }else if (operadoresArray[i].trim() == "ONLY_START") {
                        options += "<option value='ONLY_START'>Apenas inicio</option>";
                    }else if (operadoresArray[i].trim() == "ONLY_END") {
                        options += "<option value='ONLY_END'>Apenas fim</option>";
                    }else if (operadoresArray[i].trim() == "EQUAL_MULTIPLE") {
                        options += "<option value='EQUAL_MULTIPLE'>Igual a palavra/frase(V&aacute;rios por virgula)</option>";
                    }else if (operadoresArray[i].trim() == "MAIOR_QUE") {
                        options += "<option value='MAIOR_QUE'>Maior que</option>";
                    }else if (operadoresArray[i].trim() == "MENOR_QUE") {
                        options += "<option value='MENOR_QUE'>Menor que</option>";
                    }else if (operadoresArray[i].trim() == "BETWEEN") {
                        options += "<option value='BETWEEN'>Entre</option>";
                    }else if (operadoresArray[i].trim() == "BOOLEAN") {
                        options = "<option value='Ambos'>Ambos</option>"
                                 +"<option value='TRUE'>SIM</option>"
                                 +"<option value='FALSE'>NÃO</option>";
                    }
                }
                

                var isDate = (columnType.toUpperCase().indexOf("Date".toUpperCase()) != -1);
                if (columnType.toUpperCase().indexOf("String".toUpperCase()) != -1) {//String
//                    options += "<option value='ALL_PARTS'>Todas as partes com</option>"
//                             +"<option value='IN'>Apenas</option>"
//                             +"<option value='ONLY_START'>Apenas inicio</option>"
//                             +"<option value='ONLY_END'>Apenas fim</option>"
//                             +"<option value='EQUAL_MULTIPLE'>Igual a palavra/frase(V&aacute;rios por virgula)</option>";
//                     
                    isCaseSensitive = "<br> <input type='checkbox' name='isCaseSensitive["+columnName+"]' id='isCaseSensitive_"+indexColuna+"' /> Diferenciar Maiúsculas de minúsculas";
//                }else if (columnType.toUpperCase().indexOf("integer".toUpperCase()) != -1) {//Int
//                    options += "<option value='IN'>Igual</option>"
//                             +"<option value='BETWEEN'>Entre</option>"
//                             +"<option value='MAIOR_QUE'>Maior que</option>"
//                             +"<option value='MENOR_QUE'>Menor que</option>";
//                    
//                }else if (columnType.toUpperCase().indexOf("Double".toUpperCase()) != -1) {//Double, numeric ou float
//                    options += "<option value='IN'>Igual</option>"
//                             +"<option value='BETWEEN'>Entre</option>"
//                             +"<option value='MAIOR_QUE'>Maior que</option>"
//                             +"<option value='MENOR_QUE'>Menor que</option>";
//                
//                }else if (columnType.toUpperCase().indexOf("BigDecimal".toUpperCase()) != -1) {//Double, numeric ou float
//                    options += "<option value='IN'>Igual</option>"
//                             +"<option value='BETWEEN'>Entre</option>"
//                             +"<option value='MAIOR_QUE'>Maior que</option>"
//                             +"<option value='MENOR_QUE'>Menor que</option>";
//                
//                }else if (columnType.toUpperCase().indexOf("boolean".toUpperCase()) != -1) {//boolean
//                    //obs quanto a booleano: não tem SELECIONE é apenas AMBOS, 
//                    //logo, ele não recebe o primeiro option e sim sobrescreve com suas proprias opcoes
//                    options = "<option value='Ambos'>Ambos</option>"
//                             +"<option value='TRUE'>SIM</option>"
//                             +"<option value='FALSE'>NÃO</option>";
//                    
                }else if (columnType.toUpperCase().indexOf("Date".toUpperCase()) != -1) {//Date
//                    options += "<option value='BETWEEN'>Entre</option>"
//                             +"<option value='IN'>Apenas</option>";
//                     
                    tipoData = "<select class='inputtexto' name='padraoValorDataConsulta["+columnName+"]' id='padraoValorDataConsulta_"+indexColuna+"'>"
                              +"<option value='DIA_ATUAL'>Dia Atual</option>"
                              +"<option value='SEMANA_ATUAL'>Semana Atual</option>"
                              +"<option value='QUINZENA_ATUAL'>Quinzena Atual</option>"
                              +"<option value='MES_ATUAL'>Mês atual</option>"
                              +"</select>"
                              +"<input type='hidden' id='hidIsData_"+indexColuna+"' value="+isDate+"name='hidIsData["+indexColuna+"]'>";
                  }
//                    
//                }else if (columnType.toUpperCase().indexOf("Time".toUpperCase()) != -1) {//Time
//                    options += "<option value='BETWEEN'>Entre</option>"
//                             +"<option value='IN'>Apenas</option>";
//    
//                }
                
                var select = "<select name='padraoTipoConsulta["+columnName+"]' id='padraoTipoConsulta_"+indexColuna+"' class='inputtexto' style=' width:150px'>"
                             +options
                             +"</select>";
                
                var filterEntry = 
                    '<tr id="trRemoverFilter_'+indexColuna+'" class="CelulaZebra2" >' +
                    '   <td width="20%" id="filter-' +columnName+ '">' + columnLabel + 
                    '      <input type="hidden" id="hidNomeColuna_'+indexColuna+'" name="filter[' + columnName + ']" value="' + columnName + '" >' + 
                    '      <input type="hidden" id="hidIdColuna_'+indexColuna+'" value="' + idColuna + '" >' + 
                    '   </td>' +
                    '   <td width="10%">'+
                        select+
                        isCaseSensitive+
                    '   </td>' +
                    '   <td>'+
                    (isDate? tipoData :
                    '       <input type="text" name="padraoValorConsulta['+columnName+']" id="padraoValorConsulta_'+indexColuna+'" value="" size="30" class="inputtexto" />')+
                    '   </td>' +
                    '   <td>'+
                    '      <label class="labelAlteravel" id="labelAlteravel_'+indexColuna+'"> <input type="checkbox" checked id="padraoIsConsulta_'+indexColuna+'" name="padraoIsConsulta['+columnName+']"> SIM </label>' +
                    '   </td>' +
                    '   <td width="35%">' +
                    '      <label class="labelObriga" id="labelObrigatorio'+indexColuna+'"> <input type="checkbox"'+(isFiltroObrigatorio == "true" ? "checked" : "" )+' id="checkIsFiltroObrigatorio_'+indexColuna+'" name="isFiltroObrigatorio['+columnName+']" > Campo obrigatório </label>' + 
                    '   </td>' +
                    '   <td width="25%">' +
                    '   <a href="javascript: removerFiltro('+indexColuna+')"><img class="buttonRemoveFilter'+indexColuna+'" id="removerFilter" src="img/lixo.png" title="Remover Filtro"/></a>'+
//                    '      <input type="button" id="removerFilter" class="inputbotao buttonRemoveFilter'+indexColuna+'" value="Remover" onclick="removerFiltro('+indexColuna+')" />'+
                    '   </td>' +
                    '</tr>';
//                        (isFiltroObrigatorio == "true" ? '' : '      <input type="button" id="removerFilter" class="inputbotao" value="Remover" onclick="removerFiltro('+indexColuna+','+filtroObrigatorio+')" />' ) +
                if (jQuery("#filter-" + columnName).length > 0) {
                    alert("Filtro já adicionado!")
                    return;
                }
                
                jQuery("#filters").append(filterEntry);
                    
                if (isFiltroObrigatorio == 'true') {
                    jQuery(".buttonRemoveFilter"+indexColuna).hide();
                }
                
                if (!isDate) {
                    jQuery("#labelObrigatorio"+indexColuna).hide();
                    jQuery("#labelObrigatorio"+indexColuna).switchClass("labelObriga","labelObrigaHIDE");
                }else{
                    
                    
                    
                        if(isFiltroObrigatorio == 'true'){
                            jQuery("#checkIsFiltroObrigatorio_"+indexColuna).attr("disabled","disabled");
                        }
    
                    
                            jQuery("#checkIsFiltroObrigatorio_"+indexColuna).click(function(){
                                console.log("INDEX = " + indexColuna);
                                
                                jQuery("input[id*=checkIsFiltroObrigatorio_]").removeAttr("checked");
                                jQuery("input[id*=checkIsFiltroObrigatorio_]").removeAttr("disabled");
                                jQuery("#checkIsFiltroObrigatorio_"+indexColuna).attr("disabled","disabled");
                                jQuery("#checkIsFiltroObrigatorio_"+indexColuna).prop("checked",true);
                                jQuery("img[class*='buttonRemoveFilter'").show();                        
                                jQuery(".buttonRemoveFilter"+indexColuna).hide();
                                
                            });
                        
                    
                }
                
                
                
                jQuery("#filter-message").remove();
                
//                jQuery("#removerFilter").click(function() {
//                    jQuery(this).parents("#trRemoverFilter_"+columnName).remove();
//                                            
//                    if (jQuery('.filter').length == 0) {
//                        jQuery("#filters").html('<td id="filter-message" class="TextoCampos" ></td>');
//                    }
//                });
            },
            addOrdem : function(columnName, columnLabel, indexOrdem, idOrdem, ordemOrientacao) {
                    var filterEntry = 
                    '<tr id="trRemoverOrdem_'+indexOrdem+'" class="CelulaZebra2 indexOrdens" >' +
                    '<td><span style="cursor:auto"><img src="img/ordenar.png" width="13px" heigth="13px" class="handler"></span></td>'+
                    '   <td width="40%" id="ordem-' +columnName+ '">' + 
                    '<label class="TESTE_ESCRITA_ORDEM">' + indexOrdenacao + '- </label>' + columnLabel +                     
                    '      <input type="hidden" id="hidNomeOrdem_'+indexOrdem+'" name="ordem[' + columnName + ']" value="' + columnLabel + '" >' + 
                    '      <input type="hidden" id="hidlabelOrdem_'+indexOrdem+'" name="ordemLabel[' + columnName + ']" value="' + columnLabel + '" >' + 
                    '      <input type="hidden" id="hidIdOrdem_'+indexOrdem+'" name="ordemId[' + columnName + ']" value="' + idOrdem + '" >' + 
                    '      <input type="hidden" class="hidOrdem_" id="hidOrdem_'+ indexOrdem +'" name="hidOrdem[' + columnName + ']" value="' + indexOrdenacao + '" >' +
                    '   </td>' +
                    '   <td width="20%">' +
                    '       <select id="selectOrdem_'+ columnName +'" name="selectOrdem['+columnName+']" class="inputtexto">' +
                    '           <option value="ASC" ' + (ordemOrientacao != "" && ordemOrientacao != undefined && ordemOrientacao != null? (ordemOrientacao == "ASC" ? 'selected' : '' ) : '') + '> Crescente </option>' + 
                    '           <option value="DESC" ' + (ordemOrientacao != "" && ordemOrientacao != undefined && ordemOrientacao != null? (ordemOrientacao == "DESC" ? 'selected' : '' ) : '') + '> Decrescente </option>' + 
                    '       </select>' +
                    '   </td>' +
                    '   <td width="50%">' +
                    '      <input type="button" id="removerFilter" class="inputbotao" value="Remover" onclick="removerOrdem('+indexOrdem+')" />' +
                    '   </td>' +
                    '</tr>';
                
                if (jQuery("#ordem-" + columnName).length > 0) {
                    alert("ordenação já adicionada!")
                    return;
                }
                indexOrdenacao = indexOrdenacao + 1;
                jQuery("#ordenacoes").append(filterEntry);
                jQuery("#ordem-message").remove();
                reordenando();
                    }
            }
        
        REPORT_BUILDER_COLUMN_CONTROLLER.init();
    });
    
    function validarFiltros(ev){
        //validar se existe algum não alteravel com tipo selecione;
        var arrays = jQuery("[id*=filter-]");
        for (var i = 0; i < arrays.length; i++) {
            var nomeFiltro = arrays[i].id;
            nomeFiltro = nomeFiltro.substring(7,900);
            if (!(jQuery("[name='padraoIsConsulta["+nomeFiltro+"]']").is(":checked")) && (jQuery("[name='padraoTipoConsulta["+nomeFiltro+"]']").val() == "SELECIONE")){
                alert("Atenção: O filtro \""+ ((jQuery("#filter-"+nomeFiltro)).text().trim()) +"\" não pode estar com o tipo \"Selecione\" enquanto estiver como não alterável!");
                ev.preventDefault();
                break;
            }
        }
    }
    
    function removerFiltro(indexColuna,colunaNome){
        var nomeColuna = (jQuery(jQuery("#hidNomeColuna_"+indexColuna).parents()[0]).text().trim());
        var idColuna = jQuery("#hidIdColuna_"+indexColuna).val();
        var idRelatorio = '${param.idRelatorio}';

            if (idColuna != '0') {
                if (confirm("Deseja remover o filtro  \"" + nomeColuna + "\"  ?")) {
                    if (confirm("Tem certeza?")) {
                        
                        jQuery.ajax({
                                url: '<c:url value="/ReportBuilderControlador" />',
                                dataType: "text",
                                method : "post",
                                async : false,
                                data: {
                                    idRelatorio : idRelatorio,
                                    idColuna : idColuna,
                                    acao : "removerFiltro"
                                },
                                success: function(data) {
                                    jQuery("#trRemoverFilter_"+indexColuna).remove();            
                                }
                            });
//                            $("coluna_"+colunaNome).attr('disabled', 'disabled');
//                            $("coluna_"+colunaNome).addClass("inputbotao");
//                            $("coluna_"+colunaNome).removeClass("inputTexto");
//                            $("coluna_"+colunaNome).val("Adicionar Filtro");
    
                    }
                }
            }else{
//                $("#coluna_"+colunaNome).removeAttr('disabled');
//                $("#coluna_"+colunaNome).addClass("inputbotao");
//                $("#coluna_"+colunaNome).removeClass("inputTexto");
//                $("#coluna_"+colunaNome).val("Adicionar Filtro");
                jQuery("#trRemoverFilter_"+indexColuna).remove();            
            }
                
    }
    
    function removerOrdem(indexOrdem){
        var nomeColuna = jQuery("#hidlabelOrdem_"+indexOrdem).val();
        var idOrdem = jQuery("#hidIdOrdem_"+indexOrdem).val();
        var idRelatorio = '${param.idRelatorio}';

            if (idOrdem != '0') {
                if (confirm("Deseja remover a Ordem  " + nomeColuna + "  ?")) {
                    if (confirm("Tem certeza?")) {
                        
                        jQuery.ajax({
                                url: '<c:url value="/ReportBuilderControlador" />',
                                dataType: "text",
                                method : "post",
                                async : false,
                                data: {
                                    idOrdem : idOrdem,
                                    acao : "removerOrdem"
                                },
                                success: function(data) {
                                    jQuery("#trRemoverOrdem_"+indexOrdem).remove();            
                                    alert("Ordem excluida com sucesso!.");
                                    reordenando();
                                }
                            });
    
                    }
                }
            }else{
                jQuery("#trRemoverOrdem_"+indexOrdem).remove();            
                reordenando();
            }
    }
    
    
    function visualizarRelatorio2(){
        window.open('','gerarReport','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }
   
   function stAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }
       //abas
    var varAbas = new Array();
    
    varAbas[0] = new stAba('tdAbaColunas', 'abaColunas');
    varAbas[1] = new stAba('tdAbaFiltros', 'abaFiltros');
    varAbas[2] = new stAba('tdAbaOrdem', 'abaOrdem');
    varAbas[3] = new stAba('tdAbaEmail', 'abaEmail');
    varAbas[4] = new stAba('tdAbaAuditoria','abaAuditoria');
    
    function AlternarAbas(menu,conteudo,array){
        var menuInterno;
        var conteudoInterno;

        var arrayInterno = (array != null && array != undefined ? array : varAbas);
        for (i=0;i<arrayInterno.length;i++)
        {
            if (document.getElementById(arrayInterno[i].conteudo) != null){
                menuInterno = document.getElementById(arrayInterno[i].menu);
                menuInterno.className = 'menu';
                conteudoInterno = document.getElementById(arrayInterno[i].conteudo);
                conteudoInterno.style.display = 'none';
            }
        }

        if(conteudoInterno != null){
            menuInterno = document.getElementById(menu)
            menuInterno.className = 'menu-sel';
            conteudoInterno = document.getElementById(conteudo);
            conteudoInterno.style.display = '';
        }

    }
    function salvarReport(){
        try{
//            var formulario = document.getElementById("reportForm");
//            submitPopupForm(formulario);
            var formulario = jQuery("#reportForm");
            jQuery('input').removeAttr('disabled');
            window.open('about:blank', 'pop', 'width=210, height=100');
            formulario.submit();
        }catch(e){
            console.log(e)
        }
            
    }
    
    jQuery("#selecionarTodos").click(function(){
        if (jQuery(this).prop("checked")) {
            alterarVisualizacao(jQuery("#vizualizarSelecionados").prop("checked"));
            jQuery(".paraOrdenacao").prop('checked',true);
        }else{
            jQuery(".paraOrdenacao").removeProp("checked");
        }  
    });
    
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
                var rotina = "report_builder_relatorio";
                 var dataDe = jQuery("#dataAteAuditoria").val();
                var dataAte = jQuery("#dataAteAuditoria").val();
                var id = jQuery("#idRelatorio").val();
                console.log("id " +id+" rotina " + rotina+" dataDe "+dataDe+" dataAte "+ dataAte);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
        
        function abrirLocalizarCron(elementoId){
            try {
                tryRequestToServer(function(){abrirJanela("AgendamentoTarefasCrontrolador?acao=localizarCron"
                        +"&elemento="+elementoId+"&isRelatorio=true", "locCron", 50, 30);
                    });
            } catch (e) {
                alert(e);
            }
        }
        
        function removerMomentoEnvio(id){
            if(confirm("Deseja remover o momento de envio? ")){
                document.getElementById("trCron"+id).style.display= "none";
                document.getElementById("delCron"+id).value = true;
            }
        }
        
        function Cron(id, cronExpressao, nomeArquivo, idAgenda){
            this.id = (id == null || id == undefined ? 0 : id);
            this.cronExpressao = (cronExpressao == null || cronExpressao == undefined ? "": cronExpressao);
            this.nomeArquivo = (nomeArquivo == null || nomeArquivo == undefined ? "": nomeArquivo);
            this.idAgenda = (idAgenda == null || idAgenda == undefined ? "": idAgenda);
        }        
        function addCron(cron){
            var countCron = parseInt(jQuery("#maxCron").val());               
            var classe = (countCron % 2 == 1 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign");
            try {
                cron = (cron == null || cron == undefined ? new Cron() : cron);
                var _labelCron = Builder.node("label", "Momento:");
                var _labelNomeCron = Builder.node("label", " Nome do arquivo: ");
                var _labelExplicacao = Builder.node("label", "O momento esta apresentado em forma de expressão cron, para visualizar e/ou informar clique no botão ao lado");                
                var _br = Builder.node("br");
                var _br2 = Builder.node("br");
                var _tr = Builder.node("tr",{id:"trCron" + countCron, className: classe});
                var _tdValor = Builder.node("td",{id:"tdCronValor" + countCron, className: classe, width: "90%"});
                
                var _tableValores = Builder.node("table",{className: "bordaFina", width: "100%"});
                var _trNomeArq = Builder.node("tr");
                var _tdNomeArq = Builder.node("td",{className: classe, colspan: "3"});
                var _tdlblNomeArq = Builder.node("td",{className: classe});
                var _labelAno = Builder.node("label",{onclick: "incluirVariavel(this,'"+countCron+"')", className:"linkEditar"}); _labelAno.innerHTML = "@@Ano ";
                var _labelMes = Builder.node("label",{onclick: "incluirVariavel(this,'"+countCron+"')", className:"linkEditar"}); _labelMes.innerHTML = "@@Mes ";
                var _labelDia = Builder.node("label",{onclick: "incluirVariavel(this,'"+countCron+"')", className:"linkEditar"}); _labelDia.innerHTML = "@@Dia ";
                var _labelHora = Builder.node("label",{onclick: "incluirVariavel(this,'"+countCron+"')", className:"linkEditar"}); _labelHora.innerHTML = "@@Hora ";
                var _labelMinuto = Builder.node("label",{onclick: "incluirVariavel(this,'"+countCron+"')", className:"linkEditar"}); _labelMinuto.innerHTML = "@@Minuto ";
                var _labelSegundo = Builder.node("label",{onclick: "incluirVariavel(this,'"+countCron+"')", className:"linkEditar"}); _labelSegundo.innerHTML = "@@Segundo ";
                
                var _trLocaliza = Builder.node("tr");
                var _tdLocaliza = Builder.node("td",{className: classe, colspan: "4"});

                
                var _tdLixo = Builder.node("td",{id:"tdCronValor" + countCron, className: classe, width: "10%", align: "center"});
                var _imgLixo = Builder.node('IMG',{src:'img/lixo.png',title:'Apagar Momento',className:'imagemLink',onClick:"removerMomentoEnvio('"+ countCron+"');"});
                var _idLayout = Builder.node('input',{type : "hidden",id : "idCron"+countCron,name : "idCron"+countCron,value : cron.id});
                var _inpCron = Builder.node('input',{type : "text",size : "20",id : "cron"+countCron,className : "fieldMin",name : "cron"+countCron,value : cron.cronExpressao});
                var _inpDelCron = Builder.node('input',{type : "hidden",id : "delCron"+countCron,name : "delCron"+countCron,value : false});
                var _inpAgendCron = Builder.node('input',{type : "hidden",id : "agendaCron"+countCron,name : "agendaCron"+countCron,value : cron.idAgenda});
                var _inpDescCron = Builder.node('input',{type : "text",id : "descArqCron"+countCron,name : "descArqCron"+countCron,value : cron.nomeArquivo, className : "fieldMin", size: "40"});
                readOnly(_inpCron, "inputReadOnly8pt");                
                var _btLocalizarCron = Builder.node('input',{type:"button",id:"btCron"+countCron,onClick:"abrirLocalizarCron('"+_inpCron.id+"')",className : "inputBotaoMin",value : "..."});
                
                _tdlblNomeArq.appendChild(_labelNomeCron);
                _tdNomeArq.appendChild(_inpDescCron);
                _tdNomeArq.appendChild(_br);
                _tdNomeArq.appendChild(_labelAno);
                _tdNomeArq.appendChild(_labelMes);
                _tdNomeArq.appendChild(_labelDia);
                _tdNomeArq.appendChild(_labelHora);
                _tdNomeArq.appendChild(_labelMinuto);
                _tdNomeArq.appendChild(_labelSegundo);
                _trNomeArq.appendChild(_tdlblNomeArq);
                _trNomeArq.appendChild(_tdNomeArq);
                _tableValores.appendChild(_trNomeArq);
                
                _tdLocaliza.appendChild(_labelCron);
                _tdLocaliza.appendChild(_inpCron);
                _tdLocaliza.appendChild(_inpDelCron);
                _tdLocaliza.appendChild(_inpAgendCron);
                _tdLocaliza.appendChild(_idLayout);
                _tdLocaliza.appendChild(_btLocalizarCron);
                _tdLocaliza.appendChild(_br2);
                _tdLocaliza.appendChild(_labelExplicacao);
                _trLocaliza.appendChild(_tdLocaliza);
                _tableValores.appendChild(_trLocaliza);
                _tdValor.appendChild(_tableValores);

                _tdLixo.appendChild(_imgLixo);                
                _tr.appendChild(_tdLixo);
                _tr.appendChild(_tdValor);                
                document.getElementById("tableCron").appendChild(_tr);
                document.getElementById("maxCron").value = countCron +1;
            } catch (e) {console.log(e);}
        }
        
        function incluirVariavel(elemento,contador){
            document.getElementById("descArqCron"+contador).value += elemento.innerHTML.trim();
        }
        
        function mostrarEmail(){
            if(document.getElementById("isEnviarRelatorioEmail").checked){
                document.getElementById("tableMontagemEmail").style.display = "";
            }else{
                document.getElementById("tableMontagemEmail").style.display = "none";
            }
        }
</script>            
<!--<script type="text/javascript" src="script/tiny_mce/tiny_mce.js"></script>-->
<script type="text/javascript">   
    tinyMCE.init({
    // General options
    mode: "exact",
    elements: "mensagemEmailRelatorio",
    theme: "advanced",
    plugins: "safari,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups",
    // Theme options
    theme_advanced_buttons1: "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect",
    theme_advanced_buttons2: "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
    theme_advanced_buttons3: "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
    theme_advanced_buttons4: "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak",
    theme_advanced_toolbar_location: "top",
    theme_advanced_toolbar_align: "left",
    theme_advanced_statusbar_location: "bottom",
    theme_advanced_resizing: false,
    // Example word content CSS (should be your site CSS) this one removes paragraph margins
    content_css: "css/word.css",
    document_base_url: "",
    // Replace values for the template plugin
    template_replace_values: {
        username: "Some User",
        staffid: "991234"
    }
});
</script>
<c:if test="${!empty columnList}">
    
    <form action="<c:url value="ReportBuilderControlador"/>?acao=${param.carregarAcao == 1 ? 'cadastrar' : 'editar'}&modulo=${param.modulo}" method="post" id="reportForm" target="pop">
        <input type="hidden" id="idRelatorio" name="idRelatorio" value="${param.idRelatorio}" />
        <input type="hidden" id="relatorioVisualizar" name="relatorioVisualizar" value="false" />
        <input type="hidden" id="maxCron" name="maxCron" value="0" />
        <table class="bordaFina" width="100%" align="center">
            <tr>
                <td class="TextoCampos">
                    <label for="report-title" >Nome do relatório</label>
                </td>
                <td class="CelulaZebra2">
                    <input id="report-title" type="text" name="reportTitle" class="inputtexto"/>                    
                </td>
                <td class="TextoCampos" width="25%">Mostrar na tela de :</td>
                <td class="celulaZebra2" width="25%" colspan="2">
                    <select class="inputtexto" id="Rotina" name="Rotina">
                        <c:forEach items="${TipoSistemaEnumWebtrans}" var="report" varStatus="status">
                            <option value="${report.value}" ${report.value == reportSistema ? "selected" : ""}>
                                ${report.key}
                            </option>
                        </c:forEach>
                    </select>
                </td>
            </tr>            
            <tr class="tabela" id="">
                <td id="tdAbaColunas" class="menu-sel" onclick="AlternarAbas('tdAbaColunas', 'abaColunas',varAbas);"> <center> Colunas </center></td>
                <td id="tdAbaFiltros" class="menu" onclick="AlternarAbas('tdAbaFiltros', 'abaFiltros',varAbas);"> Filtros </td>
                <td id="tdAbaOrdem" class="menu" onclick="AlternarAbas('tdAbaOrdem', 'abaOrdem',varAbas);"> Ordenações </td>
                <td id="tdAbaEmail" class="menu" onclick="AlternarAbas('tdAbaEmail', 'abaEmail',varAbas);"> Envio por E-mail </td>
                <td  style='display: ${param.carregarAcao == 2 && nivel == 4 ? "" : "none"}' id="tdAbaAuditoria" class="menu" onclick="AlternarAbas('tdAbaAuditoria', 'abaAuditoria',varAbas);"> Auditoria </td>
            </tr>
        </table>
        
        <div id="abaColunas" class="limiteRel" style="background-color:#FFFFFF;">
            <table class="bordaFina" width="100%" align="center">
                <tbody class="teste">
                    <tr class="naoMove">
                        <td colspan="7" align="center" class="tabela">Colunas</td>
                    </tr>
                    <tr class="CelulaZebra1NoAlign naoMove">
                        <td align="left" colspan="7">
                            <label align="left"> <input type="checkbox"  id="vizualizarSelecionados" onclick="alterarVisualizacao(this);"> Visualizar apenas campos selecionados</label>
                        </td>
                    </tr>
                    <tr class="CelulaZebra1 naoMove">
                        <td></td>
                        <td><input id="selecionarTodos" type="checkbox"></td>
                        <td>Nome</td>
                        <td>Descrição</td>
                        <td></td>                
                        <td></td>
                        <td></td>

                    </tr>
                    <input type="hidden" name="modulo" id="modulo" value="${modulo}">
                    <input type="hidden" name="viewName" id="viewName" value="${viewName}">
                    <input type="hidden" name="viewLabel" id="viewLabel" value="${viewLabel}">
                    
                    <c:forEach items="${operadores}" var="teste" varStatus="status" >
                        <input type="hidden" name="operadores_${teste.key}" id="operadores_${teste.key}" value="${teste.value}">
                    </c:forEach>
                    
                    <c:forEach items="${columnList}" var="column" varStatus="status" >

                        <tr class="CelulaZebra2 esconder_${status.count - 1}">
                            <td>
                                
                                <input type="hidden" name="type[${column.name}]" class="type_${status.count}" id ="type_${status.count}" value="${column.type}"> 
                                <input type="hidden" size="3" class="TESTE_ORDEM_COLUNAS" id="ordemColunas_${status.count}" name="ordemColunas[${column.name}]" value="${column.ordemColuna}">
                                <input type="hidden" name="isFiltroObrigatorio[${column.name}]" id="isFiltroObrigatorio_${status.count}" value="${column.isFiltroObrigatorio}" class="isFiltroObrigatorio_${status.count}">
                                <img src="img/ordenar.png" width="13px" heigth="13px" class="handler2">
                            </td>
                            <td>
                                <input class="column-selection_${status.count} paraOrdenacao" type="checkbox" id="view-${column.name}" name="column[${column.name}]" value="${column.name}" onclick="reordenarColunas();">
                            </td>
                            <td><label class="column-label_${status.count}" for="view-${column.name}">${column.label}</label></td>
                            <td>
                                <input type="text" name="label[${column.name}]" value="${column.label}" class="inputtexto" id="inpTDescricao_${status.count}">
                                <input type="hidden" name="type[${column.name}]" value="${column.type}" class="inputtexto" id="inpHDescricao_${status.count}">
                            </td>
                            <td>
                                <input name="addFilter" type="button" id="coluna_${column.name}" value="Adicionar Filtro" class="inputbotao" onclick="addFilterColuna('${status.count}')"/>
                            </td>
                            <td class="naoSort">
                                <input name="addOrdem" type="button" value="Adicionar Ordenação" class="inputbotao" onclick="addOrdemColuna('${status.count}')"/>
                            </td>
                            <td class="naoSort" width="12%">
                                <c:if test="${column.type == 'java.lang.Integer' || column.type == 'java.math.BigDecimal' || column.type == 'java.lang.Double' || column.type == 'java.lang.Float' }">
                                    <label><input type="checkbox" name="isTotalizador[${column.name}]" id="isTotalizador_${status.count}" value="" />Totalizar</label>
                                </c:if>
                            </td>
                        </tr>
                        <c:if test="${status.last}">
                            <input type="hidden" id="maxColunas" name="maxColunas" value="${status.count}" />
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <div id="abaFiltros" class="limiteRel" style="background-color:#FFFFFF;">
            <table class="bordaFina" width="100%" align="center">
                <tr>
                    <td colspan="6" align="center" class="tabela">Filtros</td>
                </tr>
                <tr class="celulaZebra1">
                    <td class="celulaZebra1" width="10%"><b>Coluna</b></td>
                    <td class="celulaZebra1" width="25%"><b>Tipo padrão</b></td>
                    <td class="celulaZebra1" width="30%"><b>Descrição padrão</b></td>
                    <td class="celulaZebra1" width="10%"><b>Editável</b></td>
                    <td class="celulaZebra1" width="12%"><b>Filtro obrigatório</b></td>
                    <td class="celulaZebra1" width="3%"></td>
                </tr>
                <tbody id="filters">

                </tbody>
            </table> 
        </div>
        <div id="abaOrdem" class="limiteRel" style="background-color:#FFFFFF;">
            <table class="bordaFina" width="100%" align="center">
                <tr>
                    <td colspan="4" align="center" class="tabela">Ordenação</td>
                </tr>
                <tbody id="ordenacoes" class="ordenacoes">

                </tbody>
            </table>
        </div>
        <div id="abaEmail" name="abaEmail" class="limiteRel">
            <table class="bordaFina" width="100%" align="center">
                <tr>
                    <td colspan="4" align="center" class="tabela">Envio de Emails</td>
                </tr>
                <tr>
                    <td class="celulaZebra2" colspan="4">
                        <input type="checkbox" id="isEnviarRelatorioEmail" name="isEnviarRelatorioEmail" class="checkbox" ${relatorio.enivarRelatorioPorEmail ? "checked" : ""} onclick="mostrarEmail()">
                        <b>Enviar esse relatório automaticamente por e-mail</b>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra2" align="center" style="vertical-align:top;" colspan="4">
                        <table class="bordaFina" width="100%" id="tableMontagemEmail" name="tableMontagemEmail">
                            <tr>
                                <td align="center" style="vertical-align:top; width: 60%" colspan="2">
                                    <table class="bordaFina" width="100%" align="left" id="tableEmail" name="tableEmail">
                                        <tr>
                                            <td class="TextoCampos">
                                               * Remetente: 
                                            </td>
                                            <td class="celulaZebra2" colspan="2"> 
                                                <select id="emails" name="emails" class="inputtexto">  
                                                    <option value="0" selected="">Selecione</option>
                                                    <c:forEach var="emails" items="${listaEmails}">
                                                    <option value="${emails.id}">${emails.descricao}</option>
                                                    </c:forEach>    
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">
                                              * Destinatário : 
                                            </td>
                                            <td class="celulaZebra2" colspan="2">
                                                <input type="text" id="destinatarioEmail" name="destinatarioEmail" value="" class="inputtexto" size="60">
                                            </td>
                                        </tr>
                                        <tr>    
                                            <td class="TextoCampos">
                                                C/C : 
                                            </td>
                                            <td class="celulaZebra2" colspan="2">
                                                <input type="text" id="ccEmail" name="ccEmail" class="inputtexto" size="60" value="">
                                            </td>
                                        </tr>
                                        <tr>    
                                            <td class="TextoCampos">
                                                Assunto : 
                                            </td>
                                            <td class="celulaZebra2" colspan="2">
                                                <input type="text" id="assuntoEmail" name="assuntoEmail" class="inputtexto" size="70" value="">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">
                                                Mensagem : 
                                            </td>
                                            <td class="CelulaZebra2" colspan="3" align="center">
                                                <textarea cols="70" rows="15" id="mensagemEmailRelatorio" name="mensagemEmailRelatorio" style="width: 90%">${relatorio.mensagemEmail == undefined || relatorio.mensagemEmail == null ? "" : relatorio.mensagemEmail}</textarea>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="center" style="vertical-align:top;width: 40%" colspan="2">
                                    <table class="bordaFina" width="100%" align="left" id="tableCron" name="tableCron">
                                        <tr>
                                            <td class="celulaZebra2" align="right">
                                                <img class="imagemLink" border="0" onclick="javascript:addCron(null)" src="img/novo.jpg" title="Adicionar momento de envio">
                                            </td>
                                            <td class="celulaZebra2" align="left">    
                                                Momentos de Envio
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>               
         <div id="abaAuditoria" style='display: ${param.carregarAcao == 2 && nivel == 4 ? "" : "none"}'>           
         <table class="limiteReal" width="100%" align="center" id="abaAuditoria" >
            <tr>
                <td><%@include file="/gwTrans/template_auditoria.jsp" %></td>
            </tr>
            <tr>
                <td colspan="8"> 
                    <table width="100%" align="center" class="bordaFina">
                        <td class="TextoCampos" width="15%"> Incluso:</td>

                            <td width="35%" class="CelulaZebra2"> em: <c:out value="${relatorio.criadoEm}"></c:out><br>
                                por: <c:out value="${relatorio.nomeUsuarioCriador}"></c:out>
                            </td>

                            <td width="15%" class="TextoCampos"> Alterado:</td>
                            <td width="35%" class="CelulaZebra2"> em: <c:out value="${relatorio.modificadoEm}"></c:out><br>
                                por: <c:out value="${relatorio.nomeUsuarioModificador}"></c:out>
                            </td>
                    </table>                  
                </td>
            </tr>   
        </table>           
         </div>        
        <table width="100%">
            <tr class="CelulaZebra2" >
                <td align="center">
                <br>
                <c:if test="${temPermissao}">
                    <input type="button" value=" Salvar " class="inputbotao" onclick="javascript: tryRequestToServer(function(){salvarReport();});"/>
    <!--                <button formaction="< c:url value="ReportBuilderControlador"/>?acao=visualizarRelatorio&preview=YES" formtarget="gerarReport" class="inputbotao" onclick="visualizarRelatorio2()" >Visualizar</button>-->
                    </td>
                </c:if>
            </tr>
        </table>
    </form>

</c:if>

<style>
    .soltar{ 
        height: 1.5em; 
        line-height: 1.2em; 
        background-color: white; 
        outline-color: black;
        outline-style: dashed;
        outline-width: 2px;
    }
  </style>
<script type="text/javascript" src="script/jQuery/jquery-ui.js"></script>
<script>
    jQuery(function() {
      jQuery('.handler').css('cursor', 'pointer');
      jQuery('.handler2').css('cursor', 'pointer');
      jQuery("#ordenacoes").sortable({
          cursor: "move",
          placeholder: "soltar",
          handle: '.handler',
              stop : function(event, ui) {
                  reordenando();
              }
              });
      jQuery(".teste").sortable({
          cursor: "move",
          handle: '.handler2',
          placeholder: "soltar",
          items : "tr:not(.naoMove)",
          stop : function(event,ui){
              reordenarColunas();
          }
      });
  });
        
  function reordenando(){
      for(var i = 0; i < jQuery(".indexOrdens").length;i++){
            jQuery(".TESTE_ESCRITA_ORDEM")[i].innerHTML=""+(i+1)+"- ";
            jQuery(jQuery(".hidOrdem_")[i]).val(i+1);
      }
  }
   
  function reordenarColunas(){
            var indice = 1;
    for(var i = 0; i < jQuery(".TESTE_ORDEM_COLUNAS").length;i++){
            if (jQuery(".paraOrdenacao")[i].checked) {
                jQuery(jQuery(".TESTE_ORDEM_COLUNAS")[i]).val(indice);
                indice++;
            }else{
                jQuery(jQuery(".TESTE_ORDEM_COLUNAS")[i]).val(0);
            }
    }
  }
  
    function alterarVisualizacao(check){
        var itens = jQuery(".paraOrdenacao");
        if(check.checked){
            for (var i = 0; i < itens.length; i++) {
                if(itens[(i)].checked){
                    jQuery(jQuery(itens[i]).parents()[1]).show();
                }else{
                    jQuery(jQuery(itens[i]).parents()[1]).hide();
                }
            }
        }else{
            for (var i = 0; i < itens.length; i++) {
                jQuery(".esconder_"+(i)).show();
            }
        }
    }
  </script>
