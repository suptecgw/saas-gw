/*
Arquivo para ser importado nas telas que for gerar Relatórios dinamicos. 

Dicas:
- existe uma parte que deve ser criada no controlador, segue o código de exemplo abaixo:
if(acao.equals("carregar")){
    ReportBuilderBO bo = new ReportBuilderBO();
    Consulta filtro = new Consulta();
    filtro.setCampoConsulta("nome_relatorio");
    filtro.setFiltrosAdicionais(new StringBuilder(" and rotina_relatorio = ").append(SistemaTipoRelatorio.WEBTRANS_CTE_RELATIORIO.ordinal()));
    filtro.setLimiteResultados(100);
    Collection lista = bo.listarRelatorios(filtro);
        
    request.setAttribute("listaRelatorioPersonalizado", lista);
}

ATENÇÃO!! : 
1- essa js precisa de jQuery.
2- quebrando esse JS irá quebrar TODOS os relatórios dinamicos. 
3- ATENÇÃO: AO ALTERAR ESSE JS COLAR O QUE FOI ALTERADO TAMBÉM NO GWEB. MESMO QUE NÃO USE!!.
4- Existe um jsp chamado tabGerarReport.jsp que usa esse JS TAMBÉM.
5- IMPORTANTE!!: nesse js podemos usar tanto o prototype quanto o jQuery. para usar o prototype use: $(""). 
                                                                          para usar o jQuery    use: jQuery("").


-- BOA SORTE!! --
*/




//variaveis globais possiveis:
var dataInicial = new Date();
var dataFormatada = (dataInicial.getDate() < 10 ? "0"+dataInicial.getDate() : dataInicial.getDate())+"/"
                   +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                    +dataInicial.getFullYear();
       




//funcoes:





//Abaixo será criado o trecho onde criará ABAS na tela:
function stAba(menu, conteudo){
        this.menu = menu;
        this.conteudo = conteudo;
}

var arAbas = new Array();

arAbas[0] = new stAba('tdWeb','divWeb');
   
       
       
var arAbasGenerico = new Array();
arAbasGenerico[0] = new stAba('tdAbaPrincipal', 'tabPrincipal');
arAbasGenerico[1] = new stAba('tdAbaDinamico', 'tabDinamico');
function AlternarAbasGenerico(menu,conteudo){
    try {
        if (arAbasGenerico != null) {
            for (i = 0; i < arAbasGenerico.length; i++){
                if (arAbasGenerico[i] != null && arAbasGenerico[i] != undefined) {
                    m = document.getElementById(arAbasGenerico[i].menu);
                    m.className = 'menu';
                    c = document.getElementById(arAbasGenerico[i].conteudo)
                    invisivel(c, true);
                    //invisivel($(c.id.replace("div", "tr")), true); //comentado pois estava quebrando a tela de relanalisevendas, testei outras telas e funcionou sem essa linha.
                }
            }
            m = document.getElementById(menu)
            m.className = 'menu-sel';
            c = document.getElementById(conteudo);
            visivel(c);
            //visivel($(conteudo.replace("div", "tr"))); //comentado pois estava quebrando a tela de relanalisevendas, testei outras telas e funcionou sem essa linha.
        }else{
            alert("Inicialize a variavel arAbasGenerico!")
        }
    } catch (e) { 
        alert(e);
    }
}


function carregarFiltros(idReport){
  function e(transport){
    var resp = transport.responseText;
    espereEnviar("",false);
    //se deu algum erro na requisicao...
    if (resp == 'null'){
        alert('Erro');
        return false;
    }

    var jqueryParse = jQuery.parseJSON(resp);
    var report = jqueryParse.Report;
    var filtro = report.operators[0].entry;
    var length = (filtro != undefined && filtro.length != undefined ? filtro.length : 1)
    //COLUNAS
    $("colunasRelatorioPersonalizado").update("");
    var colunasMap = report.columns[0];
    var colunas = colunasMap["br.com.gwsistemas.util.Column"];

        
    if (colunas.length > 1) {
        for (var i = 0; i < colunas.length; i++) {
            addLabelsColuna(colunas[i].label,colunas[i].isTotalizador);
        }
    }else if(colunas.length == undefined || colunas.length == null ){
        addLabelsColuna(colunas.label,colunas.isTotalizador);
    }

    //ORDENACAO
    $("ordenacaoRelatorio").update("");
    if (report.orders[0] != "") {
        var ordensMap = report.orders[0];
        var ordem = ordensMap["br.com.gwsistemas.util.Order"];

        if (ordem.length > 1) {
            for (var i = 0; i < ordem.length; i++) {
                addOrdenacao(ordem[i].colunaDescricao, ordem[i].ordem, ordem[i].orientacao, ordem[i].colunaNome);
            }
        }else if (ordem.length == null || ordem.length == undefined ){
            addOrdenacao(ordem.colunaDescricao, ordem.ordem, ordem.orientacao, ordem.colunaNome);
        }
    }

    $("tabFiltros").update("");
    $("inputIdHidden").value = report.id;
    $("viewName").value = report.table.name;
    $("viewLabel").value = report.table.label;
    $("reportTitle").value = report.title;
    $("maxFiltro").value = 0;
        
if (length > 1) {
    for (i = 0; i < filtro.length; i++) {
        var map = filtro[i];
        var filtroMap = map["br.com.gwsistemas.util.Filter"];
        var listaMap = map.list[0]; 
        var padraoValoresDataFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoValoresDataFiltro;
        addColunas(filtroMap.column.label,filtroMap.column.name,filtroMap.column.type, listaMap["br.com.gwsistemas.util.Operator"],$("maxFiltro").value,filtroMap.column.isFiltroObrigatorio,padraoValoresDataFiltro);
        var padraoTipoConsultaFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoTipoConsultaFiltro;
        var padraoValorConsultaFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoValorConsultaFiltro;
        var padraoAlteravelConsultaFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoAlteravelConsultaFiltro;
        var padraoCaseSensitiveFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoCaseSensitiveFiltro;
        
        jQuery("#selectOperador_"+$("maxFiltro").value+" option[value="+(padraoTipoConsultaFiltro == "" ? "selecione" : padraoTipoConsultaFiltro )+"]").prop("selected",true);
        jQuery("#argumento_"+$("maxFiltro").value).val(padraoValorConsultaFiltro);
        
        var isDate = (filtroMap.column.type.toUpperCase().indexOf("Date".toUpperCase()) != -1);
        trocarOperador($("selectOperador_"+$("maxFiltro").value),$("maxFiltro").value,isDate,padraoValoresDataFiltro);
        
        if (padraoCaseSensitiveFiltro) {
            jQuery("#isCaseSensitive_"+$("maxFiltro").value).attr("checked",true)
        }
        
        if (!padraoAlteravelConsultaFiltro) {
            try{
                
                jQuery("#selectOperador_"+$("maxFiltro").value).hide();
                jQuery("#labelSelectHidden_"+$("maxFiltro").value).text(jQuery("#selectOperador_"+$("maxFiltro").value + " :selected").text());
                
                jQuery("#isCaseSensitive_"+$("maxFiltro").value).click(function(){return false;});
                jQuery("#isCaseSensitive_"+$("maxFiltro").value).attr("readOnly",true).addClass("inputReadOnly")
                
                jQuery("#argumento_"+$("maxFiltro").value).attr("readonly",true);
                jQuery("#argumento_"+$("maxFiltro").value).removeClass("inputTexto").addClass("inputReadOnly");
                
                jQuery("#input_"+$("maxFiltro").value+"_ate").attr("readOnly",true);
                jQuery("#input_"+$("maxFiltro").value+"_ate").removeClass("inputTexto").addClass("inputReadOnly");
                
            }catch(e){alert(e)}
        }else{
            
        }
      $("maxFiltro").value++;
    }
}else{
    var map = filtro;
    var filtroMap = map["br.com.gwsistemas.util.Filter"];
        var listaMap = map.list[0]; 
        var padraoValoresDataFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoValoresDataFiltro;
        addColunas(filtroMap.column.label,filtroMap.column.name,filtroMap.column.type, listaMap["br.com.gwsistemas.util.Operator"],$("maxFiltro").value,filtroMap.column.isFiltroObrigatorio,padraoValoresDataFiltro);
        var padraoTipoConsultaFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoTipoConsultaFiltro;
        var padraoValorConsultaFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoValorConsultaFiltro;
        var padraoAlteravelConsultaFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoAlteravelConsultaFiltro;
        var padraoCaseSensitiveFiltro = map["br.com.gwsistemas.util.Filter"].column.padraoCaseSensitiveFiltro;
        
        jQuery("#selectOperador_"+$("maxFiltro").value+" option[value="+(padraoTipoConsultaFiltro == "" ? "selecione" : padraoTipoConsultaFiltro )+"]").prop("selected",true);
        jQuery("#argumento_"+$("maxFiltro").value).val(padraoValorConsultaFiltro);
        
        var isDate = (filtroMap.column.type.toUpperCase().indexOf("Date".toUpperCase()) != -1);
        trocarOperador($("selectOperador_"+$("maxFiltro").value),$("maxFiltro").value,isDate,padraoValoresDataFiltro);
        
        if (padraoCaseSensitiveFiltro) {
            jQuery("#isCaseSensitive_"+$("maxFiltro").value).attr("checked",true)
        }
        
        if (!padraoAlteravelConsultaFiltro) {
            try{
                
                jQuery("#selectOperador_"+$("maxFiltro").value).hide();
                jQuery("#labelSelectHidden_"+$("maxFiltro").value).text(jQuery("#selectOperador_"+$("maxFiltro").value + " :selected").text());
                
                jQuery("#isCaseSensitive_"+$("maxFiltro").value).click(function(){return false;});
                jQuery("#isCaseSensitive_"+$("maxFiltro").value).attr("readOnly",true).addClass("inputReadOnly")
                
                jQuery("#argumento_"+$("maxFiltro").value).attr("readonly",true);
                jQuery("#argumento_"+$("maxFiltro").value).removeClass("inputTexto").addClass("inputReadOnly");
                
                jQuery("#input_"+$("maxFiltro").value+"_ate").attr("readOnly",true);
                jQuery("#input_"+$("maxFiltro").value+"_ate").removeClass("inputTexto").addClass("inputReadOnly");
                
            }catch(e){alert(e)}
        }else{
            
        }
      $("maxFiltro").value++;
}


}//funcao e()

    if (idReport != ''){
        espereEnviar("",true);
        tryRequestToServer(function(){
            new Ajax.Request("./ReportBuilderControlador?acao=localizarFiltros&idRelatorio="+idReport,{method:'post', onSuccess: e, onError: e});
        });
    }
}

function addOrdenacao(labelDescricao, ordenacao, orientacao, nomeColuna){
        var tableBase = $("ordenacaoRelatorio");
        var trOrder = Builder.node("TR",{class:"CelulaZebra2"});
        var tdDescOrder = Builder.node("TD",{class:"CelulaZebra2"});
        var tdSelectOrder = Builder.node("TD",{class:"CelulaZebra2"});
        //fim parte tr e td.
        
        //inicio campos:
        var hidNomeOrdem = Builder.node("input",{type:"hidden",value:nomeColuna, name:""});
        var labelsDescricao = Builder.node("label");
            labelsDescricao.innerHTML = labelDescricao;
        var ordemOrdenacao = Builder.node("label");
            ordemOrdenacao.innerHTML = ordenacao + ". ";
        var hidOrdenacao = Builder.node("input",{type:"hidden", value:ordenacao});
        var selectOrientacao = Builder.node("select",{
            id:"selectOperador_",
            name:"selectOrientacao_"+nomeColuna,
            className :"inputTexto"
            
        });
        var optionOrientacao = Builder.node("option", {
                        value: "ASC"
        });
        
        
        var descricao;
        
                optionOrientacao = Builder.node("option", {
                    value: "ASC"
                });
                descricao = "Crescente ";
                Element.update(optionOrientacao, descricao);
                selectOrientacao.appendChild(optionOrientacao);
        
                optionOrientacao = Builder.node("option", {
                    value: "DESC"
                });
                descricao = "Decrescente ";
                Element.update(optionOrientacao, descricao);
                selectOrientacao.appendChild(optionOrientacao);
                
                optionOrientacao = Builder.node("option", {
                    value: "IGNORAR"
                });
                descricao = "IGNORAR ORDENA&Ccedil;&Atilde;O ";
                Element.update(optionOrientacao, descricao);
                selectOrientacao.appendChild(optionOrientacao);
                
        selectOrientacao.options.selectedIndex = (orientacao == "ASC" ? "0" : "1");
        
        //iniciando a setar os atributos de TR e TD
        tdDescOrder.appendChild(hidNomeOrdem);
        tdDescOrder.appendChild(hidOrdenacao);
        tdDescOrder.appendChild(ordemOrdenacao);
        tdDescOrder.appendChild(labelsDescricao);
        tdSelectOrder.appendChild(selectOrientacao);
        trOrder.appendChild(tdDescOrder);
        trOrder.appendChild(tdSelectOrder);
        tableBase.appendChild(trOrder);
        
        
        //campos de ordem = descricao, nome, ordem e orientacao.
    }

    function addLabelsColuna(label, isTotalizador){
        var tableBase = $("colunasRelatorioPersonalizado");
        var tr = Builder.node("TR",{class:"CelulaZebra2"});
        var td = Builder.node("Td",{class:"CelulaZebra2"});
        var labels = Builder.node("label");
        labels.innerHTML = "- " + label + (isTotalizador?" (mostrar total)." : ".");
        td.appendChild(labels);
        tr.appendChild(td);
        tableBase.appendChild(tr);
    }
    
    function addColunas(colunaDescricao, colunaNome, tipoFiltro, operadores, index, isFiltroObrigatorio,padraoData){
        var tabelaBase = $("tabFiltros");
        var isDate = (tipoFiltro.toUpperCase().indexOf("Date".toUpperCase()) != -1);
        var isBoolean = (tipoFiltro.toUpperCase().indexOf("Boolean".toUpperCase()) != -1);
        var isString = (tipoFiltro.toUpperCase().indexOf("String".toUpperCase()) != -1);
        
        var trColuna = Builder.node("TR",{class:"CelulaZebra2"});
        var tdDescricaoFiltro = Builder.node("TD",{class:"CelulaZebra2",width:"25%"});
        var tdDescricaoCampo = Builder.node("TD",{class:"CelulaZebra2",width:"75%"});

        if(isDate){
            var inputFiltro = Builder.node("input",{
                id:"argumento_"+index,
                name:"argumento_"+colunaNome,
                class :"inputReadOnly",
                maxLength:"10",
                size:"10",

                onBlur : "alertInvalidDate(this);",
                onKeyPress:"fmtDate(this, event)",
                onKeyUp:"fmtDate(this, event)",
                onKeyDown:"fmtDate(this, event)"
            });
        }else if(isBoolean){
            var inputFiltro = Builder.node("input",{
                type:"hidden",
                id:"argumento_"+index,
                name:"argumento_"+colunaNome
            });
        }else{
            var inputFiltro = Builder.node("input",{
                id:"argumento_"+index,
                name:"argumento_"+colunaNome,
                class :"inputReadOnly"
            });
        }
        
        inputFiltro.readOnly = "true";
        var selectOperador = Builder.node("select",{
            id:"selectOperador_"+index,
            name:"selectOperador_"+colunaNome,
            class :"inputTexto",
            onChange : "trocarOperador(this,'"+ index +"',"+ isDate +",'"+padraoData+"');"
        });
        var labelSelectHidden = Builder.node("label",{
            id:"labelSelectHidden_"+index,
            name:"labelSelectHidden_"+colunaNome
        });
        selectOperador.style.width="150px";
        
        var optionsOperador = Builder.node("option", {
            value: "selecione"
        });
        if (!isBoolean && !isFiltroObrigatorio) {
            Element.update(optionsOperador, "Selecione");
            selectOperador.appendChild(optionsOperador);
        }
        var espaco = Builder.node("label",{});
        espaco.innerHTML = "&nbsp;";
        var espaco2 = Builder.node("label",{});
        espaco2.innerHTML = "&nbsp;";

        if(!isBoolean){
        //montagem do SELECT de operadores.
            if(Array.isArray(operadores)){
                var arrayOperadores = new Array();
                arrayOperadores = operadores;
                if(arrayOperadores.length > 1){
                    for(var i = 0; i < arrayOperadores.length; i ++){
                        var optionOperador = Builder.node("option", {
                                    value: arrayOperadores[i]
                        });
                        var descricao;
                        switch (arrayOperadores[i]){
                            case "IN":
                                if (!isString) {
                                    descricao = "Apenas ";
                                }else{
                                    descricao = "Igual a Palavra/Frase ";
                                }
    
                                break;
                            case "NOT_IN":
                                descricao = "Exceto ";
                                break;
                            case "ALL_PARTS":
                                descricao = "Todas as partes com ";
                                break;
                            case "ONLY_START":
                                descricao = "Apenas inicio ";
                                break;
                            case "ONLY_END":
                                descricao = "Apenas fim ";
                                break;
                            case "EQUAL_MULTIPLE":
                                descricao = "Igual a palavra/frase(V&aacute;rios por virgula) ";
                                break;
                            case "MAIOR_QUE":
                                descricao = "Maior que ";
                                break;
                            case "MENOR_QUE":
                                descricao = "Menor que ";
                                break;
                            case "BETWEEN":
                                descricao = "Entre ";
                                break;
                            deafult:
                                    descricao = "Apenas";
                        }
                        Element.update(optionOperador, descricao);
                        selectOperador.appendChild(optionOperador);
                    }
                }
            }else{
                var descricao;
                        switch (operadores){
                            case "IN":
                                descricao = "Apenas ";
                                break;
                            case "NOT_IN":
                                descricao = "Exceto ";
                                break;
                            case "ALL_PARTS":
                                descricao = "Todas as partes com ";
                                break;
                            case "ONLY_START":
                                descricao = "Apenas inicio ";
                                break;
                            case "ONLY_END":
                                descricao = "Apenas fim ";
                                break;
                            case "EQUAL_MULTIPLE":
                                descricao = "Igual a palavra/frase(V&aacute;rios por virgula) ";
                                break;
                            case "MAIOR_QUE":
                                descricao = "Maior que ";
                                break;
                            case "MENOR_QUE":
                                descricao = "Menor que ";
                                break;
                            case "BETWEEN":
                                descricao = "Entre ";
                                break;
                            deafult:
                                    descricao = "Apenas";
                        }
                var optionOperador = Builder.node("option", {
                            value: operadores
                });
                Element.update(optionOperador, descricao);
                selectOperador.appendChild(optionOperador);
            }
            selectOperador.options.selectedIndex = 0;
            //fim da montagem do SELECT de operadores.
        }else{
            var descricao;
            var arrayBoolean = new Array();
            arrayBoolean[0] = "Ambos";
            arrayBoolean[1] = "Sim";
            arrayBoolean[2] = "N&atilde;o";
            
            var arrayBooleanValue = new Array();
            arrayBooleanValue[0] = "Ambos";
            arrayBooleanValue[1] = "TRUE";
            arrayBooleanValue[2] = "FALSE";
            
            for(var i = 0; i < arrayBoolean.length; i ++){
                var optionOperador = Builder.node("option", {
                            value: arrayBooleanValue[i]
                });
                var descricao = arrayBoolean[i];
                Element.update(optionOperador, descricao);
                selectOperador.appendChild(optionOperador);
            }
            selectOperador.options.selectedIndex = 0;
        }
        
        var labelDescricaoFiltro = Builder.node("label");
        labelDescricaoFiltro.innerHTML = colunaDescricao;
        
        if(isDate){
            var inputFiltroAte = Builder.node("input",{
                id:"input_"+index+"_ate",
                name:"input_"+colunaNome+"_ate",
                class :"inputTexto",
                maxLength:"10",
                size:"10",

                onBlur : "alertInvalidDate(this);",
                onKeyPress:"fmtDate(this, event)",
                onKeyUp:"fmtDate(this, event)",
                onKeyDown:"fmtDate(this, event)"
            });
        }else{
            var inputFiltroAte = Builder.node("input",{
                id:"input_"+index+"_ate",
                name:"input_"+colunaNome+"_ate",
                class :"inputTexto"
            });
        }
        inputFiltroAte.style.display = 'none';
        
        
        //fim declarando campos
        
        var isData = Builder.node("input",{
            type:"hidden",
            id:"isData_"+index,
            name:"isData_"+colunaNome,
            value:isDate
        });
        

        if(isString){
            var inputCaseSensitive = Builder.node("input",{
                type:"checkbox",
                name:"isCaseSensitive_"+colunaNome,
                id:"isCaseSensitive_"+index
            });

            var labelCaseSensitive = Builder.node("label");
            labelCaseSensitive.innerHTML = " Diferenciar Mai&uacute;sculas de min&uacute;sculas";
        }
        //esse campo spam não será utilizado, a menos que use o chosen da função mais abaixo.
        var span = Builder.node("span",{
            class:"filterValues_"+index 
        });
        
        //inicio montagem de TD e TR na TBODY
        tdDescricaoFiltro.appendChild(labelDescricaoFiltro);
        tdDescricaoFiltro.appendChild(isData);
        tdDescricaoCampo.appendChild(selectOperador);
        tdDescricaoCampo.appendChild(labelSelectHidden);
        tdDescricaoCampo.appendChild(span);
        tdDescricaoCampo.appendChild(espaco);
            tdDescricaoCampo.appendChild(inputFiltro);
        if(isString){
            tdDescricaoCampo.appendChild(inputCaseSensitive);
            tdDescricaoCampo.appendChild(labelCaseSensitive);
        }
        tdDescricaoCampo.appendChild(espaco2);
        tdDescricaoCampo.appendChild(inputFiltroAte);
        
        trColuna.appendChild(tdDescricaoFiltro);
        trColuna.appendChild(tdDescricaoCampo);
    
        tabelaBase.appendChild(trColuna);
        
        trocarOperador($("selectOperador_"+index),index,isDate,padraoData);
        
        //carregarValores(index,colunaNome,tipoFiltro); // para usar a função de chosen, descomentar essa linha também.
    }
    
        //essa função vai no banco e retorna os valores para serem montados num CHOSEN.
    function carregarValores(index,columnName,columnType){
        var self = this;
                    
                    var operator = jQuery(self).find('option:selected').val();
                    var viewName = $("viewName").value;
                    
                    jQuery.ajax({
                        url: '<c:url value="/ReportBuilderControlador" />',
                        dataType: "text",
                        data: {
                            viewName : viewName,
                            columnName : columnName,
                            columnType : columnType,
                            operator : operator,
                            acao : "getFilterValues"
                        },
                                
                        success : function(data) {
                                    
                            console.log(jQuery(".filterValues"));
                            jQuery(".filterValues_"+index).html(data);

                           
                            jQuery('.chosen-select').chosen({
                                width : "300px" 
                            });
                            
                            jQuery('.rb-date-picker').datepicker({
                                dateFormat: "dd/mm/yy",
                                dayNames: [ "Domingo", "Segunda", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado" ],
                                dayNamesMin: [ "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" ],
                                dayNamesShort: [ "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab" ],
                                monthNames: [ "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro" ],
                                monthNamesShort: [ "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" ],
                                changeMonth: true,
                                changeYear: true
                                
                            });
                            
                        }
                    });
    }
    
    function trocarOperador(selected,filtro,isDate,padraoData){
        if(isDate){
            if (padraoData == "DIA_ATUAL") { 
                $("argumento_"+filtro).value = dataFormatada;
                $("input_"+filtro+"_ate").value = dataFormatada;
                
            }else if(padraoData == "SEMANA_ATUAL"){
                
                jQuery.ajax({
                    url: 'ReportBuilderControlador',
                    dataType: "text",
                    method : "post",
                    async : false,
                    data: {
                        acao : 'getDataInicioEFimSemana'
                    },
                    success: function(data) {
                        console.log(data.DataInicioFim);
                        console.log(jQuery.parseJSON(data));
                        console.log(jQuery.parseJSON(data).DataInicioFim);
                        var datas = jQuery.parseJSON(data).DataInicioFim;
                        $("argumento_"+filtro).value = datas.split("!!")[0];
                        $("input_"+filtro+"_ate").value = datas.split("!!")[1];
                    }
                });
            }else if(padraoData == "QUINZENA_ATUAL"){
                var dataSemanaInicio;
                var dataSemanaFim;
                var ultimoDia = RetornaUltimoDiaDoMes(new Date());
                
                if (dataInicial.getDate() < 15) {
                    dataSemanaInicio = "01/"
                                       +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                                       +dataInicial.getFullYear();

                    dataSemanaFim = "15/"
                                    +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                                    +dataInicial.getFullYear();
                }else{
                    dataSemanaInicio = "16/"
                                       +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                                       +dataInicial.getFullYear();

                    dataSemanaFim = ultimoDia+"/"
                                    +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                                    +dataInicial.getFullYear();
                    
                }
                    
                $("argumento_"+filtro).value = dataSemanaInicio;
                $("input_"+filtro+"_ate").value = dataSemanaFim;
            }else if(padraoData == "MES_ATUAL"){
                var ultimoDia = RetornaUltimoDiaDoMes(new Date());
                $("argumento_"+filtro).value = "01/"
                                               +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                                               +dataInicial.getFullYear();
                $("input_"+filtro+"_ate").value = ultimoDia+"/"
                                                +((dataInicial.getMonth()+1) < 10 ? "0"+(dataInicial.getMonth()+1) : (dataInicial.getMonth()+1))+"/"
                                                 +dataInicial.getFullYear();
            }
        }
        console.log("1passou aqui " + selected.id + " - " + padraoData);
        if(selected.value == "BETWEEN"){
            document.getElementById("argumento_"+filtro).className = "inputTexto";
            $("argumento_"+filtro).readOnly = false;
            $("input_"+filtro+"_ate").style.display = "";
        }else if(selected.value == "selecione"){
            document.getElementById("argumento_"+filtro).className = "inputReadOnly";
            $("argumento_"+filtro).readOnly = "true";
            $("argumento_"+filtro).value = "";
            $("input_"+filtro+"_ate").style.display = "none";
            $("input_"+filtro+"_ate").value = "";
        }else{
            document.getElementById("argumento_"+filtro).className = "inputTexto";
            $("argumento_"+filtro).readOnly = false;
            $("input_"+filtro+"_ate").style.display = "none";
            $("input_"+filtro+"_ate").value = "";
        }
    }
    
    
    function RetornaUltimoDiaDoMes(qualquerObjetoDate){
        return (new Date(qualquerObjetoDate.getFullYear(), qualquerObjetoDate.getMonth() + 1, 0) ).getDate();
    }
    
    
    function gerarRelatorio(){
        if(validaGerarVisualizarRelatorio(0)){
            var form = $("formGerarRelatorio");
            form.action = "ReportBuilderControlador?acao=visualizarRelatorioTela&export=yes";
            form.method = "post";
            form.submit();
        }
    }
    
    function previsualizar(){
        if(validaGerarVisualizarRelatorio(1)){
            var form = $("formGerarRelatorio");
            window.open('','gerarReport','top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
            form.action = "ReportBuilderControlador?acao=visualizarRelatorioTela&preview=yes";
            form.method = "post";
            form.target = "gerarReport";
            form.submit();
        }
    }
    
    function validaGerarVisualizarRelatorio(gerarVisualizar){
        if ($("inputIdHidden").value == "0") {
            alert("selecione um Relat\u00f3rio");
            return false;
        }
        
//        gerarVisualizar = 0 é gerar e 1 é visualizar
        
        return true;
    }
    
//    
//    function table(id,table_name){
//        this.id = (id == undefined || id == null ? "" : id)
//        this.table_name = (table_name == undefined || table_name == null ? "" : table_name)
//    }
//    
//    var arrayTables = new Array();
//    
    
    function novoCadastroRelatorioPersonalizado(){
        var modulo = jQuery("#moduloRel").val();
        location.replace('./ReportBuilderControlador?acao=novoCadastro&modulo='+modulo);
    }

    function aoCarregarTabReport(tipoReport, modulo){
//        teste(lista);
        modulo =  (modulo == '' || modulo == undefined || modulo == null ? 'webtrans' : modulo);
        jQuery.ajax({
                    url: 'tabGerarReport.jsp?acao=iniciar&rotinaRelatorio='+tipoReport,
                    dataType: "text",
                    method : "post",
                    async : false,
                    data: {
                    },
                    success: function(data) {
                        //a quem quer entender:
                        //o valor de data será um HTML pronto para ser colocado na tela
                        console.log(data);
                        //em uma variavel div vou colocar o objeto tabdinamico
                        var div = jQuery("#tabDinamico");
                        console.log(div);
                        //nesse objeto será setado o HTML retornado do campo, 
                        //de modo que ele seja interpretado em tempo de execução
                        div.html(data);
                        //além disso será setado o valor do modulo para o botão de novo cadastro.
                        jQuery("#moduloRel").val(modulo);
                    }
                });
    }
//    