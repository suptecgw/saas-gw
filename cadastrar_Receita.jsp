<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<LINK REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<LINK REL="stylesheet" HREF="protoloading.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>

<script type="text/javascript" language="JavaScript">
        jQuery.noConflict();
        homePath = "${homePath}"; 
        
    function abrirUnidadeCusto(count){
        var idUnidade = $("unidadeCustoIdApropr_" + count).value;
        if(idUnidade == 0){
            alert("Selecione a Unidade de Custo primeiro!");
        }else{
            abrirMax("${homePath}/UnidadeCustoControlador?acao=iniciarEditar&id=" + idUnidade, "CadVeiculo");
        }
    }

    function abrirLocalizarCliente(){
//        abrirLocaliza("${homePath}/ClienteControlador?acao=localizarFinan&isResultados=true", "locCliFinan");
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=5', 'locCliFinan');
    }
    
    function abrirLocalizarHistorico(){
//        abrirLocaliza("${homePath}/HistoricoControlador?acao=localizarFinan", "locHistFinan");
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=14', 'locHistFinan');
    }
    
    function abrirLocalizarCfop(cfop){
        abrirLocaliza("${homePath}/CfopControlador?acao=localizarFinan&campos=" + cfop, "locCfopClienteFinan");
    }
    
    var u;
    function abrirLocalizarUnidadeCustoApropr(unidade){
        u = unidade;
//        abrirLocaliza("${homePath}/UnidadeCustoControlador?acao=localizarFinan&campos="+unidade, "locUnidadeCustoFinan");
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=39', 'locUnidadeCustoFinan');
    }
    
    function adicionaApropriacao(){
//        abrirLocaliza("${homePath}/PlanoCustoControlador?acao=localizarFinan&tipo=r&modulo=gwFinan", "locCustoFinanR");
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=13', 'locCustoFinanR');
    }
    
    var v;
    function abrirLocalizarVeiculoApropr(veiculo){
        v = veiculo;
//        abrirLocaliza("${homePath}/VeiculoControlador?acao=localizarFinan&veiculo=null&campos=" + veiculo, "locVeiculoFinan");
        javascript:launchPopupLocate('./localiza?acao=consultar&idlista=41', 'locVeiculoFinan');
    }
    

    //  C A L C U L O S ------------------------------------------------- Inicio
    

    function calculaApropr(){
        var valorAprop = 0;
        for (var i = 0; i <= $("maxApropr").value; i++){
            if ($("valorApropr_" + i) != null){
                valorAprop += colocarPonto($("valorApropr_" + i).value);
            }
        }
        return colocarVirgula(colocarPonto($("valor").value) - valorAprop);
    }

    //  C A L C U L O S ------------------------------------------------- Fim
    
    function chkAVista(){
//        limparDuplicatas();
        $('qtdPacelas').value = '1';
        if($('aVista').checked){
            criarDuplicatas(1);
            readOnly($('qtdPacelas'));
        }else{
            notReadOnly($('qtdPacelas'));
        }
        $('fixo').style.display = ($('aVista').checked ? "" : "none");
    }

    function limparDuplicatas(){
        var maxDupl = $("maxDupl").value;        
        for (var j =0; j <= maxDupl; j++){
            if($("parcelaDupl_" +  j) != null){
                Element.remove($("trDupl_"+ j));
            }
        }
    }
    
    function colocarTotal(){
        var valorParcelado = ($("qtdPacelas").value)  * (colocarPonto($("valorParcelas").value));
        if ($("valor").value == "0,00" || $("valor").value == "0" || $("valor").value == "" || $("valor").value != valorParcelado){
           if(parseFloat($("valor").value) < parseFloat(valorParcelado)){
            var total = valorParcelado; 
            $("valor").value = colocarVirgula(parseFloat(total));
            }
        }
    }
    function criarDuplicatas(quantidade){
        if($("qtdDiasParcelas").value == "" ){
            alert("Preencha o campo 'Dias'!");
            $("qtdDiasParcelas").focus();
            return false;
        }
     
        colocarTotal();
        
        var qtdDiasParcela = 0;
        
        if($("aVista")== null){
            //qtdDiasParcela = 30;
            qtdDiasParcela = parseInt($("qtdDiasParcelas").value,10); 
        }else if(!$("aVista").checked && $("qtdDiasParcelas").value == ""){
            qtdDiasParcela = 30;
        }else if($("qtdDiasParcelas").value != ""){
            qtdDiasParcela = parseInt($("qtdDiasParcelas").value,10);            
        }

        var valorParcela = colocarVirgula(parseFloat(colocarPonto($("valor").value)) / quantidade);

        limparDuplicatas();
        
        var emissao = $("emissaoEm").value;
        var diaE = emissao.split("/")[0];
        var mesE = emissao.split("/")[1];
        var anoE = emissao.split("/")[2];
        /* Data atual */
        var data = new Date(anoE, mesE  - 1, diaE );
        /* Ano */ 
        var anoRAux = data.getFullYear();
            
        for (var i = 1 ; i <= quantidade; i++){
            
            var emissao = $("emissaoEm").value;
            var diaE = emissao.split("/")[0];
            var mesE = emissao.split("/")[1];
            var anoE = emissao.split("/")[2];
            /* Data atual */
            var data = new Date(anoE, mesE  - 1, diaE );
            
            
            //informa data + um mes
            if($("tipoDuplicata").value == "com"){
            data.setDate(data.getDate() + qtdDiasParcela * (i));
            
            var diaR = (data.getDate().toString().length == 1 ? "0" + data.getDate() : data.getDate());
            var mesR = (data.getMonth() + 1).toString().length == 1 ? "0" + (data.getMonth() + 1) : (data.getMonth() + 1);
            var anoR = data.getFullYear();
            var novaData = diaR +"/"+mesR+"/"+anoR;
            //informa a quantidade de dias
            var dias  = 0 + i * qtdDiasParcela;
            
            if (i == quantidade){
                valorParcela = colocarVirgula(parseFloat(colocarPonto($("valor").value)) - colocarPonto(valorParcela) * (i-1));
            }
            
            } else {
                /* Valida o dia que o usuário digita */    
                if(qtdDiasParcela>31 || qtdDiasParcela<diaE){
                    if(qtdDiasParcela>31 || qtdDiasParcela <=0 ){
                        alert("Dia Inválido!");
                        $("qtdDiasParcelas").focus();
                        return false;
                    }else{
                        if(qtdDiasParcela<diaE && $("mes").value == "mesAtual"){
                            alert("A 1ª parcela não pode ficar menor que a data de emissão!");
                            $("qtdDiasParcelas").focus();
                            return false;   
                        }
                    }
                }
                /* Dia */
                var diaR = qtdDiasParcela ;
                /* Mês */
                if($("mes").value == "mesAtual" && i==1){
                    mesR = parseFloat(mesE);
                }else{
                    if($("mes").value == "proximoMes" && i==1){
                            mesR = parseFloat(mesE)+1;
                    }
                }
                if(mesR==13){
                    mesR = 1;
                    anoRAux = parseFloat(anoRAux) + 1;
                }
                /* Formatação do mês  */
                if(mesR != 10 && mesR != 11 && mesR != 12 && mesR<13){
                    mesR = "0" + mesR ;   
                }
                if (parseFloat(diaR) > 0 && parseFloat(diaR) <10){
                    diaR = "0" + diaR;
                }
                var novaData = diaR +"/"+mesR+"/"+anoRAux;
                while(!validaData2(novaData)){
                    diaR = diaR - 1;
                    novaData = diaR +"/"+mesR+"/"+anoRAux; 
                }
                mesR = parseFloat(mesR) + 1;
                //informa a quantidade de dias
                var dias  = 0 + i * qtdDiasParcela;

                if (i == quantidade){
                    valorParcela = colocarVirgula(parseFloat(colocarPonto($("valor").value)) - colocarPonto(valorParcela) * (i-1));
                }
             
            }
        
        
            addDuplicata(i, novaData, valorParcela,"0" ,"" ,"0" , "" , "0,00", "" , "","Em aberto","" );
       
        }
        
    }

    function carregar(){
        var action = '<c:out value="${param.acao}"/>';
        if(action == 2){

            if (${param.nivel == 4}) {

                            var data = '${dataAtual}';
                            var form = document.formulario;
                            form.dataDeAuditoria.value = '${param.dataAtual}';
                            form.dataAteAuditoria.value = '${param.dataAtual}';
                        }
            //Dados Principais
            $("id").value = '<c:out value="${venda.id}"/>';
            $("especie").value = '<c:out value="${venda.especie}"/>';
            $("serie").value = '<c:out value="${venda.serie}"/>';
            $("numero").value = '<c:out value="${venda.numero}"/>';
            $("emissaoEm").value = '<fmt:formatDate value="${venda.emissaoEm}" pattern="dd/MM/yyyy"/>';
            $("descricao_historico").value = '<c:out value="${venda.historico}"/>';
            $("filial").value = '<c:out value="${venda.filial.id}"/>';
            $("idconsignatario").value = '<c:out value="${venda.consignatario.id}"/>';
            $("con_rzs").value = '<c:out value="${venda.consignatario.razaosocial}"/>';
            $("valor").value = colocarVirgula('<c:out value="${venda.valor}"/>');
            $("categoria").value = '<c:out value="${venda.categoria}"/>';
            $("cancelado").value = '<c:out value="${venda.cancelado}"/>';
            $("jaContabilizado").checked = ('${venda.jaContabilizado}' == "true" ? true : false);
            $("lbMovimento").innerHTML = '<c:out value="${venda.id}"/>';

            console.log('${duplicata.vlduplicata}');

            //---------------------------Apropriação ---------------------------------------
        <c:forEach var="apropriacao" items="${venda.apropriacoes}">
                addApropriacaoReceita("0",'${apropriacao.planocusto.idconta}', '${apropriacao.planocusto.descricao}','${apropriacao.planocusto.conta}', colocarVirgula(${apropriacao.valor}), '${apropriacao.unidadeCusto.sigla}', '${apropriacao.unidadeCusto.id}', '${apropriacao.veiculo.placa}', '${apropriacao.veiculo.idveiculo}');
                //addApropriacaoReceita (idApro,         planoCustoId,                       planoCusto,                      codigo,                                valor,                            unidadeCusto,                  unidadeCustoId)
    </c:forEach>

                //---------------------------- Duplicata ---------------------------------------
            
        <c:forEach var="duplicata" varStatus="status" items="${venda.duplicatasVenda}">
            console.log('${duplicata.vlduplicata}');
                addDuplicata('${duplicata.duplicata}','<fmt:formatDate value="${duplicata.dtvenc}" pattern="dd/MM/yyyy"/>', colocarVirgula(${duplicata.vlduplicata}), '${duplicata.id}', '${duplicata.fatura.descricaoDesconto}','${duplicata.fatura.id}','<fmt:formatDate value="${duplicata.dtpago}" pattern="dd/MM/yyyy"/>',colocarVirgula(${duplicata.vlpago}),'${duplicata.movBanco.conta.numero}'+'-'+'${duplicata.movBanco.conta.digitoConta}','${duplicata.movBanco.docum}',"${duplicata.baixado ? 'Quitada' : 'Em aberto'}",'${duplicata.usuarioBaixa.login}');
                //addDuplicata(parcela                 , vencimento           ,                            valor  ,            idDupl,  fatura                        , faturaId               ,  dtPago              ,vlPago                                ,conta,                                                                                             documen                          , status                                           , usuario)
                $("qtdPacelas").value = '${status.count}';

                if ('${duplicata.baixado}'=='true'){

                    $("qtdPacelas").className = "inputReadOnly";
                    $("qtdPacelas").readOnly = "true";

                    $("vencimentoDupl_" + ${status.count}).className="inputReadOnly";
                    $("vencimentoDupl_" + ${status.count}).readOnly="true";

                    $("liquidoDupl_" + ${status.count}).className="inputReadOnly";
                    $("liquidoDupl_" + ${status.count}).readOnly="true";

                    $("btDupl").style.display = 'none';
                }
    </c:forEach>

            } else{
                var data = '${param.dataAtual}';
                $("filial").value = '<c:out value="${autenticado.filial.idfilial}"/>';
                $("emissaoEm").value = data;
                //form.entrada.value = data;
                //form.competencia.value = data.split('/')[1] + "/" + data.split('/')[2];
                //validaEspecie();
                $("dtPagamento").value = data;
                $("maxDupl").value = "0";
            }
            
            invisivel($("fixo"));
        }

    function voltar(){
        tryRequestToServer(function(){(window.location = "${homePath}/VendaControlador?acao=listar&modulo=gwFinan")});
    }

    function salvar(){
            //var formu = document.formulario;

            if('${venda}' != null){
                //if($("categoria").value == 'ct'){
                if('${venda.categoria}' == 'ct'){
                    alert("Essa receita é referente a um conhecimento de transporte, \n "+
                        "a alteração deste lancamento deverá ser feita pelo módulo gwTrans.");
                    return false;
                }

                //if($("categoria").value == 'ns'){
                if('${venda.categoria}' == 'ns'){
                    alert("Essa receita é referente a uma nota fiscal de serviço, \n "+
                        "a alteração deste lancamento deverá ser feita pelo módulo gwTrans.");
                    return false;
                }
            }

            if($("idconsignatario").value == '0'){
                alert("O campo 'cliente' não pode ficar em branco!");
                return false;
            }

            if($("numero").value == ''){
                alert("O campo 'número' não pode ficar em branco!");
                $("numero").focus();
                return false;
            }

            var temDuplicada = false;
            for(var d= 0 ; d <= $("maxDupl").value; d++){
                if($("vlPagoDupl_"+ d) != null ){
                    temDuplicada = true;
                    break;
                }
            }
            if(!temDuplicada){
                alert("As duplicatas devem ser informadas antes de salvar!");
                return false;
            }
            
            if(($("contaDesp").value == "") && $("aVista") != null && $("aVista") != undefined && ($("aVista").checked == true)){
                alert("Selecione uma Conta!");
                return false;
            }
                        
            var isAchouPlano = false;
            for(var p = 0; p <= parseInt($("maxApropr").value);p++){
                if($("trApropr_"+p) != null){
                    isAchouPlano = true;
                }
            }
            
            if(isAchouPlano == false){
                alert("Adicione um plano de custo!");
                return false;
            }

            if(parseFloat(colocarPonto(($("valor").value))) <= 0){
                alert("O valor bruto não pode ser 0,00");
                return false;
            }
            

            var soma = 0;
            var ObrigaUnidadeCusto = '${configuracao}';
            for (var i = 0 ; i <= $("maxApropr").value; i++){
                if($("valorApropr_"+ i)!=null){
                    soma += parseFloat(colocarPonto($("valorApropr_"+ i).value));
                    if (ObrigaUnidadeCusto == 'true' && $("unidadeCustoIdApropr_" + i).value == "0"){
                        alert("O campo 'Unidade de custo' não pode ficar em branco!");
                        $("botaoUnidadeCustoApropr_" + i).focus();
                        return false;
                    }
                }
            }
            if(soma.toFixed(2) != colocarPonto($("valor").value)){
                alert("O total da apropriação deve ser igual ao valor da nota fiscal!");
                formu.entrada.focus();
                return false;
            }
            
            //verificando se a soma das duplicatas é igual ao total
            soma=0;
            for(var i = 1; i <= $("maxDupl").value ;i++){
                if ($("liquidoDupl_"+ i) != null){
                    soma += parseFloat(colocarPonto($("liquidoDupl_"+ i).value));
                }
            }

            if (soma.toFixed(2) != parseFloat(colocarPonto($("valor").value))){
                alert("O total das duplicatas deve ser igual ao valor da nota fiscal!");
                return false;
            }
            $("valorLiquido").value = $("valor").value;

            setEnv();

            window.open('about:blank', 'pop', 'width=210, height=100');

            $("formulario").submit();
            return true;
        }

    function carregarFornecedor(campo){

            new Ajax.Request('${homePath}/FornecedorControlador?acao=carregarAjax'+
                '&valor='+ $("cgcFornecedor").value + '&campo='+campo,
            {
                method:'get',
                onSuccess: function(transport){
                    var response = transport.responseText;
                    resposta = response;
                    carregaAjaxForn(resposta);

                },
                onFailure: function(){ alert('Something went wrong...') }
            });
        }

    function carregaAjaxForn(resposta){
            var res = resposta.split("!!");
            $("idFornecedor").value = res[0];
            $("cgcFornecedor").value = res[1];
            $("fornecedorNome").value = res[2];
        }
        
    function carregarNumero(){
            var form = document.formulario;
            var filial = form.filial.value;
            var especie = form.especie.value.toUpperCase();
            var serie = form.serie.value.toUpperCase();
            new Ajax.Request('${homePath}/VendaControlador?acao=carregarNumero'+
                '&idFilial='+ filial +
                '&especie='+ especie +
                '&serie='+ serie,
            {
                method:'get',
                onSuccess: function(transport){
                    var response = transport.responseText;
                    var resposta = response;
                    var form = document.formulario;
                    form.numero.value = resposta;
                },
                onFailure: function(){ alert('Something went wrong...') }
            });
        }
        
    function validaTipo(){
        if( $("tipoDuplicata").value =="com"){
            $("lblDias").style.display = '';
            $("lblaPartirDe").style.display = 'none';
            $("mes").style.display = 'none';
        } else {
            if( $("tipoDuplicata").value =="todoDia")
            $("lblDias").style.display = 'none';
            $("lblaPartirDe").style.display = '';
            $("mes").style.display = '';
        }     
    }

    function excluir(){
        var id = '<c:out value="${venda.id}"/>';
        var nota = '<c:out value="${venda.numero}"/>';

        if(confirm("Deseja excluir a Receita Nº: " + nota + "'?" )){
            if(confirm("Tem certeza?" )){
                window.open("${homePath}/VendaControlador?acao=excluirFinan&modulo=gwFinan&id=" + id + "&numero=" + nota,
                "pop", "width=210, height=100");
            }
        }
    }

           //iniciando asbas ..

    function stAba(menu, conteudo) {
        this.menu = menu;
        this.conteudo = conteudo;
    }


    var arAbasGenerico = new Array();

    arAbasGenerico[0] = new stAba('tdAuditoria', 'divAuditoria');

    
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
        var rotina = "receita";
        var dataDe = $("dataDeAuditoria").value;
        var dataAte = $("dataAteAuditoria").value;
        var id = $("id").value;
        consultarLog(rotina, id, dataDe, dataAte);
        
    }  
</script>

<script language="javascript" type="text/javascript">
    //--DHTML
    var countAprop = 0;
    function addApropriacaoReceita(idApro, planoCustoId, planoCusto,codigo, valor, unidadeCusto, unidadeCustoId, veiculo, veiculoId ){
        countAprop++;

        if ('${param.acao}' == '1' ){
            //tipo = $("filial").value;
            valor = calculaApropr();
        }

        var _tr1 = new Element("tr", {
            name: "trApropr_" + countAprop, id: "trApropr_" + countAprop, className: "CelulaZebra2"});

        //excluir
        var _td1 = new Element("td");
        var _ip1_2 = new Element("input", {
            name: "idGeralApropr_" + countAprop, id: "idGeralApropr_" + countAprop,
            type: "hidden", value: idApro});
        var _div1 = new Element("div", {align:"center"});
        var _ip1 = Builder.node("img", {
            src: "${homePath}/img/lixo.png",  onclick:"Element.remove('trApropr_"+  countAprop +"');"});
        _div1.appendChild(_ip1);
        _td1.appendChild(_div1);
        _td1.appendChild(_ip1_2);

        //Plano Custo
        var _td2 = new Element("td");
        var _ip2 = new Element("input", {
            name: "planoCodigoApropr_" +  countAprop, id: "planoCodigoApropr_" +  countAprop, type: "text",
            value: codigo, size: "8", className: "inputReadOnly", readOnly:true});
        var _ip2_1 = new Element("input", {
            name: "planoApropr_" +  countAprop, id: "planoApropr_" +  countAprop, type: "text",
            value: planoCusto, size: "35", className: "inputReadOnly", readOnly:true, style:"margin-left:5px"});
        var _ip2_2 = new Element("input", {
            name: "planoIdApropr_" +  countAprop, id: "planoIdApropr_" +  countAprop, type: "hidden", value: planoCustoId});
        //var _ip2_3 = Builder.node("input", {
        //    name: "botaoPlanoApropr_" + countAprop, id: "botaoPlanoApropr_" + countAprop,
        //    type:"button", value: "...", style:"margin-left:5px",className: "inputbotao",
        //    onClick:"validaSession(function(){abrirLocalizarPlanoCusto('planoIdApropr_"+ countAprop +
        //        "!!planoCodigoApropr_"+ countAprop + "!!planoApropr_"+ countAprop + "' )})" });
        _td2.appendChild(_ip2); // Atualiza
        _td2.appendChild(_ip2_1); // Atualiza
        _td2.appendChild(_ip2_2); // Atualiza
        //_td2.appendChild(_ip2_3); // Atualiza

        //Valor
        if(valor == "NaN"){valor = "0,00";}
        var _td3 = new Element("td");//novo elemento campo
        var _ip3 = Builder.node("input", {
            name: "valorApropr_" +  countAprop, id: "valorApropr_" +  countAprop,
            type: "text", value: valor, size: "10", className:"inputtexto",
            onkeypress:"mascara(this,reais)"});
        _td3.appendChild(_ip3); // Atualiza

        //Unidade de custo
        var _td4 = new Element("td");
        var _ip4 = new Element("input", {
            name: "unidadeCustoApropr_" +  countAprop, id: "unidadeCustoApropr_" + countAprop, type: "text",
            value: unidadeCusto, size: "6", className: "inputReadOnly", readOnly:true});
        var _ip4_1 = new Element("input", {
            name: "unidadeCustoIdApropr_" + countAprop, id: "unidadeCustoIdApropr_" + countAprop,
            type: "hidden", value: unidadeCustoId});
        var _ip4_2 = Builder.node("input", {
            name: "botaoUnidadeCustoApropr_" + countAprop, id: "botaoUnidadeCustoApropr_"+ countAprop,
            type:"button", value: "...", style:"margin-left:5px",className: "inputbotao",
            onClick:"tryRequestToServer(function(){abrirLocalizarUnidadeCustoApropr('unidadeCustoIdApropr_"+ countAprop +
                "!!unidadeCustoApropr_"+ countAprop + "' )})" });
        _td4.appendChild(_ip4); // Atualiza
        _td4.appendChild(_ip4_1); // Atualiza
        _td4.appendChild(_ip4_2); // Atualiza

        //------------------ Veiculo -------------------- Inicio
        //Veiculo
        var _td5 = new Element("td");
        var _ip5 = new Element("input", {
            name: "veiculoApropr_" +  countAprop, 
            id: "veiculoApropr_" + countAprop,
            type: "text",
            value: veiculo,
            size: "10", className: "inputReadOnly",
            readOnly:true
        });
        var _ip5_1 = new Element("input", {
            name: "veiculoId" + countAprop, 
            id: "veiculoId" + countAprop,
            type: "hidden",
            value: veiculoId
        });
        var _ip5_2 = Builder.node("input", {
            name: "botaoVeiculoApropr_" + countAprop,
            id: "botaoVeiculoApropr_"+ countAprop,
            type:"button",
            value: "...",
            style:"margin-left:5px",
            className: "inputbotao",
            onClick:"tryRequestToServer(function(){abrirLocalizarVeiculoApropr('veiculoId"+ countAprop +
                "!!veiculoApropr_"+ countAprop + "' )})"
        });
        var _ip5_3 = Builder.node("img", {
            name: "botaoVeiculoLupaApropr_" + countAprop,
            id: "botaoVeiculoLupaApropr_" + countAprop,
            title:"Ver cadastro",
            style:"margin-left:5px",
            className: "imagemLink",
            type:"button",
            src:"${homePath}/img/lupa.gif",
            onClick:"tryRequestToServer(function(){abrirVeiculo("+countAprop+")})"
        });
        _td5.appendChild(_ip5); // Atualiza
        _td5.appendChild(_ip5_1); // Atualiza
        _td5.appendChild(_ip5_2); // Atualiza
        //_td5.appendChild(_ip5_3); // Atualiza

        //------------------ Veiculo -------------------- Fim



        _tr1.appendChild(_td1);
        _tr1.appendChild(_td2);
        _tr1.appendChild(_td5);
        _tr1.appendChild(_td3);
        _tr1.appendChild(_td4);
                
        //implementa
        $("aproprBody").appendChild(_tr1);

        $("maxApropr").value = countAprop;
    }

    var countDupl = 0;

    //------------------------------ Duplicatas a pagar ------------------------
    function addDuplicata(parcela, vencimento, valor,idDupl,fatura,faturaId,dtPago,vlPago,
    conta, documen, status, usuario){
        countDupl++;
        var _tr1 = new Element("tr", {
            name: "trDupl_" + countDupl, id: "trDupl_" + countDupl, className: "CelulaZebra2"});

        //label Parcela
        var _td1 = new Element ("td");
        var _ip1 = new Element("label", {name: "parcelaDupl_" + countDupl,
            id:"parcelaDupl_" + countDupl});
        var _ip1_2 = new Element("input", {
            name: "idGeralDupl_" + countDupl, id: "idGeralDupl_" + countDupl,
            type: "hidden", value: idDupl});
        var _ip1_3 = new Element("input", {
            name: "baixadaDupl_" + countDupl, id: "baixadaDupl_" + countDupl,
            type: "hidden", value: status});
        _td1.appendChild(_ip1);
        _td1.appendChild(_ip1_2);
        _td1.appendChild(_ip1_3);

        //vencimento
        var _td2 = new Element("td");//novo elemento campo
        var _ip2 = Builder.node("input", {name: "vencimentoDupl_" + countDupl,
            id: "vencimentoDupl_" + countDupl,type: "text", value: vencimento,
            size: "10", className:"fieldDate", onblur:"alertInvalidDate(this,true)"  });
        _td2.appendChild(_ip2); // Atualiza

        //Valor
        var _td3 = new Element ("td");
        var _ip3 = new Element("input", {
            name: "liquidoDupl_" + countDupl, id:"liquidoDupl_" + countDupl,
            type: "text", value: valor, size: "7", className:"inputtexto",
            onkeypress : "mascara(this,reais)"
        });
        _td3.update(_ip3);

        //label  Fatura
        var _td4 = new Element ("td");
        var _ip4 = new Element("label", {
            name: "faturaDupl_" + countDupl, id:"faturaDupl_" + countDupl});
        _td4.update(_ip4);

        //label  Dt pago
        var _td5 = new Element ("td",{align:"center"});
        var _ip5 = new Element("label", {
            name: "dtPagoDupl_" + countDupl, id:"dtPagoDupl_" + countDupl});
        _td5.update(_ip5);

        //label  Vl pago
        var _td6 = new Element ("td");
        var _ip6 = new Element("label", {
            name: "vlPagoDupl_" + countDupl, id:"vlPagoDupl_" + countDupl});
        _td6.update(_ip6);

        //label  conta
        var _td7 = new Element ("td",{align:"center"});
        var _ip7 = new Element("label", {
            name: "contaDupl_" + countDupl, id:"contaDupl_" + countDupl});
        _td7.update(_ip7);

        //label  documento
        var _td8 = new Element ("td");
        var _ip8 = new Element("label", {
            name: "documDupl_" + countDupl, id:"documDupl_" + countDupl});
        _td8.update(_ip8);

        //label  status
        var _td9 = new Element ("td",{align:"center"});
        var _ip9 = new Element("label", {
            name: "statusDupl_" + countDupl, id:"statusDupl_" + countDupl});
        _td9.update(_ip9);

        //label  usuario
        var _td10 = new Element ("td",{colSpan : 4});
        var _ip10 = new Element("label", {
            name: "loginDupl_" + countDupl, id:"loginDupl_" + countDupl});
        _td10.update(_ip10);

        _tr1.appendChild(_td1);
        _tr1.appendChild(_td2);
        _tr1.appendChild(_td3);
        _tr1.appendChild(_td4);
        _tr1.appendChild(_td5);
        _tr1.appendChild(_td6);
        _tr1.appendChild(_td7);
        _tr1.appendChild(_td8);
        _tr1.appendChild(_td9);
        _tr1.appendChild(_td10);

        //implementa
        $("duplBody").appendChild(_tr1);

        $("maxDupl").value = countDupl;

        //label's
        $("parcelaDupl_" + countDupl).innerHTML = parcela;
        $("dtPagoDupl_" + countDupl).innerHTML = dtPago;
        $("vlPagoDupl_" + countDupl).innerHTML = "<div align='right'>"+vlPago + "</div>";
        $("contaDupl_" + countDupl).innerHTML = conta;
        $("documDupl_" + countDupl).innerHTML = documen;
        $("statusDupl_" + countDupl).innerHTML = status;
        $("loginDupl_" + countDupl).innerHTML = usuario;

        applyFormatter();
    }

    //------------------------------ Peças -------------------------------------
    var countPeca = 0 ;


    //------------------------------ Servicos -------------------------------------
    var countServico = 0 ;

    function bloquearDuplicatas(checked){
        if(checked){
            $("qtdPacelas").readOnly = true;
            $("qtdPacelas").className = "inputReadOnly";
            $("botaoDupl").disabled = true;
            $("nota").value = "";
            $("nota").readOnly = true;
            $("nota").className = "inputReadOnly";
            gerarPrimeiraProvisao();
        }else{
            $("qtdPacelas").readOnly = false;
            $("qtdPacelas").className = "inputtexto";
            $("botaoDupl").disabled = false;
            $("nota").readOnly = false;
            $("nota").className = "inputtexto";
            limparDuplicatas();
        }
    }
    
    function aoClicarNoLocaliza(janela){
        if (janela == "locCustoFinanR") {
                            //idApro, planoCustoId,                  planoCusto,codigo,                 valor,unidadeCusto,unidadeCustoId,veiculo,veiculoId 
            addApropriacaoReceita("",$("idplanocusto").value,$("plcusto_descricao").value,$("plcusto_conta").value,"","","","","");
        } else if (janela == "locVeiculoFinan"){
            idPlacaVeiculo($("idveiculo").value,$("vei_placa").value);
        } else if (janela == "locUnidadeCustoFinan"){
            popularUnidadeCusto($("id_und").value,$("sigla_und").value);
        }
    }
    
    function idPlacaVeiculo(id,placa){
        $(v.split("!!")[0]).value = id;
        $(v.split("!!")[1]).value = placa;
    }
    
    function popularUnidadeCusto(id,valor){
        $(u.split("!!")[0]).value = id;
        $(u.split("!!")[1]).value = valor;
    }
    
    function tirarLinha(){
            if($("valor").value == "0.00" || $("valor").value == "0"){
                $("lbValor1").innerHTML = 'No valor de ';
                $("valorParcelas").style.display = '';
                $("lbValor2").innerHTML = 'cada.';
            }else{
                $("lbValor1").innerHTML = '';
                $("valorParcelas").style.display = 'none';
                $("valorParcelas").value = "0.00";
                $("lbValor2").innerHTML = '';
            }

        } 
</script>

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
    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }
</style>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>gwFinan - Cadastro de Receita</title>
    </head>
    <body onload="carregar() ; applyFormatter();AlternarAbasGenerico('tdAuditoria', 'divAuditoria');">
        <img src="img/banner.gif" align="middle">
        <table class="bordaFina" width="95%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Receita </span>
                </td>
                <c:if test="${param.acao == 2 && param.nivel >= 4}">
                    <td>
                        <input type="button" value=" Excluir " class="inputbotao" onclick="excluir()"/>
                    </td>
                </c:if>
                <td>
                    <input type="button" value=" Voltar " class="inputbotao" onclick="voltar()"/>
                </td>
            </tr>
        </table>
        <br>
        <form action="VendaControlador?acao=${param.acao == 2 ? 'editar' : 'cadastrar'}&modulo=gwFinan" id="formulario" name="formulario" method="post" target="pop">
            <input type="hidden" name="id" id="id" value="0"/>
            <input type="hidden" name="categoria" id="categoria" value="fn"/>
            <input type="hidden" name="cancelado" id="cancelado" value="false"/>
            <input type="hidden" name="modulo" id="modulo" value="gwFinan"/>

            <input type="hidden" name="maxServ" id="maxServ" value="0"/>
            <input type="hidden" name="maxPeca" id="maxPeca" value="0"/>
            <input type="hidden" name="maxApropr" id="maxApropr" value="0"/>
            <input type="hidden" name="maxDupl" id="maxDupl" value="0"/>
            <input type="hidden" name="valorLiquido" id="valorLiquido" value="0"/>
            
            <input type="hidden" name="idplanocusto" id="idplanocusto" value="0"/>
            <input type="hidden" name="plcusto_descricao" id="plcusto_descricao" value="0"/>
            <input type="hidden" name="plcusto_conta" id="plcusto_conta" value="0"/>
            <input type="hidden" name="vei_placa" id="vei_placa" value="0"/>
            <input type="hidden" name="idveiculo" id="idveiculo" value="0"/>
            <input type="hidden" name="sigla_und" id="sigla_und" value="0"/>
            <input type="hidden" name="id_und" id="id_und" value="0"/>

            <table width="95%" align="center" class="bordaFina" >
                <tr>
                    <td width="100%"  align="center" class="tabela" >Dados principais</td>
                </tr>
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="1" cellpadding="1">
                            <tr>
                                <td class="TextoCampos">Movimento:</td>
                                <td class="CelulaZebra2">
                                    <b>
                                        <label id="lbMovimento" name="lbMovimento">

                                        </label>
                                    </b>
                                </td>
                                <td colspan="8" class="TextoCampos"></td>
                            </tr>
                            <tr>
                                <td width="11%" class="TextoCampos">Filial:</td>

                                <td width="18%" class="CelulaZebra2">
                                    <select name="filial" class="inputtexto" id="filial" onchange="carregarNumero()">
                                        <c:forEach var="filialItem" varStatus="status" items="${listaFilial}">
                                            <option value=${filialItem.id}>${filialItem.abreviatura}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td width="7%" class="TextoCampos">Esp&eacute;cie:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <input name="especie" type="text" class="inputtexto" id="especie" value="" size="4" maxlength="3" onchange="carregarNumero()" style="text-transform: uppercase">
                                </td>
                                <td width="6%" class="TextoCampos">S&eacute;rie:</td>
                                <td width="8%" class="CelulaZebra2">
                                    <input name="serie" type="text" class="inputtexto" id="serie" value="" size="4" maxlength="3" onchange="carregarNumero()" style="text-transform: uppercase">
                                </td>
                                <td width="8%" class="TextoCampos">N&uacute;mero:</td>
                                <td width="12%" class="CelulaZebra2">
                                    <input name="numero" type="text" class="inputtexto" id="numero" value="" size="10" onkeypress="mascara(this, soNumeros);" maxlength="6">
                                </td>
                                <td width="8%" class="TextoCampos">Emiss&atilde;o:</td>
                                <td width="14%" class="CelulaZebra2">
                                    <input name="emissaoEm" type="text" id="emissaoEm" size="10" maxlength="10" value="" onblur="alertInvalidDate(this,true)" class="fieldDate" />
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Cliente:</td>
                                <td colspan="9" class="CelulaZebra2">
                                    <input name="con_rzs" type="text" id="con_rzs" size="50" readonly="true" class="inputReadOnly">
                                    <input name="localiza_clifor" type="button" class="inputbotao" id="localiza_clifor" value="..." onClick="tryRequestToServer(function(){abrirLocalizarCliente();})">
                                    <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Hist&oacute;rico:</td>
                                <td colspan="9" class="CelulaZebra2">
                                    <input type="hidden" name="idhist" id="idhist" value="0"/>
                                    <input name="descricao_historico" type="text" class="inputtexto" id="descricao_historico" size="80"/>
                                    <input type="button" class="inputbotao" name="botaoHistorico" id="botaoHistorico"  onClick="tryRequestToServer(function(){abrirLocalizarHistorico()})" value="..."/>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Valor bruto:</td>
                                <td class="CelulaZebra2">
                                    <input name="valor" type="text" class="inputtexto" id="valor"
                                           value="0,00" size="10" maxlength="12" onkeypress="mascara(this, reais);" onblur="tirarLinha()" />
                                </td>
                                <td class="CelulaZebra2" colspan="4">
                                    <DIV align="center">
                                        <input name="jaContabilizado" type="checkbox" id="jaContabilizado" value="checkbox">Lan&ccedil;amento já contabilizado
                                    </DIV>
                                </td>
                                <td class="CelulaZebra2" colspan="4">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="10">
                                    <table class="bordaFina" width="100%">
                                        <tr>
                                            <td class="tb-conteudo" id="tdConteudo" colspan="6">
                                                <div id="divFinanceiro" class="conteudo" >
                                                    <table width="100%">
                                                        <tr>
                                                            <td width="11%" class="TextoCampos">Qtd parcelas:</td>
                                                            <td width="64%" class="CelulaZebra2">
                                                                <input name="qtdPacelas" type="text" class="inputtexto" id="qtdPacelas" onkeypress="mascara(this, soNumeros);" onblur="setUm(this);" value="1" size="3" maxlength="3">
                                                                <label id="lbValor1" name="lbValor1">No valor de</label>
                                                                <input type="text"  class="inputtexto" size="8" onkeypress="mascara(this, reais)" name="valorParcelas" id="valorParcelas" value="0,00" onblur="setZero(this);colocarTotal();">
                                                                <label id="lbValor2" name="lbValor2">cada.</label>
                                                                Vencimento:
                                                                <select id="tipoDuplicata" name="tipoDuplicata" class="inputtexto" onchange="validaTipo();">
                                                                    <option value="com" selected>a cada</option>
                                                                    <option value="todoDia">todo dia</option>
                                                                </select>
                                                                <input name="qtdDiasParcelas" type="text" id="qtdDiasParcelas" class="inputtexto" onkeypress="mascara(this, soNumeros);" value="30" size="2" maxlength="3">
                                                                <label id="lblDias" name="lblDias">Dias</label>
                                                                <label id="lblaPartirDe" name="lblaPartirDe" style="display: none">A partir do m&ecirc;s: </label>
                                                                <select id="mes" name="mes" class="inputtexto" style="display: none">
                                                                    <option value="mesAtual">Atual</option>
                                                                    <option value="proximoMes">Seguinte</option>
                                                                </select>
                                                            </td>
                                                            <td class="TextoCampos" colspan="2">
                                                                <div id="btDupl" align="center">
                                                                    <input type="button" class="inputbotao" name="botaoDupl" id="botaoDupl"  onclick="criarDuplicatas($('qtdPacelas').value)" value="  Criar Duplicatas  "/>
                                                                    <c:if test="${param.acao == 1}">
                                                                         <br>
                                                                         <input name="aVista" type="checkbox" id="aVista" value="checkbox" onClick="javascript:chkAVista();">Lan&ccedil;amento &agrave; vista
                                                                    </c:if>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="5">
                                                                <table width="100%">
                                                                    <tbody id="duplBody" name="duplBody" onload="applyFormatter();">
                                                                        <tr>
                                                                            <td colspan="12" class="tabela">Duplicatas a pagar</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="tabela" width="7%">Parc</td>
                                                                            <td class="tabela" width="9%">Vencimento</td>
                                                                            <td class="tabela" width="10%">Valor</td>
                                                                            <td class="tabela" width="10%">Fatura</td>
                                                                            <td class="tabela" width="9%">Dt. Pago</td>
                                                                            <td class="tabela" width="10%">Vl. Pago</td>
                                                                            <td class="tabela" width="10%">Conta</td>
                                                                            <td class="tabela" width="10%">Docum</td>
                                                                            <td class="tabela" width="10%">Status</td>
                                                                            <td class="tabela" width="15%" colspan="3">Usu&aacute;rio</td>
                                                                        </tr>
                                                                    </tbody>
                                                                    
                                                                    <tr id="fixo" >
                                                                        <td class="textoCampos" colspan="2">Conta:</td>
                                                                        <td class="CelulaZebra2" colspan="5">
                                                                            <select id="contaDesp" name="contaDesp" class="inputTexto">
                                                                                <option value="1">Escolha conta para baixa</option>
                                                                                <c:forEach varStatus="status"  var="conta" items="${listaConta}">
                                                                                    <option value="${conta.idConta}">${conta.numero} - ${conta.digito_conta} / ${conta.descricao}</option>
                                                                                </c:forEach>
                                                                            </select>
                                                                        </td>
                                                                        <td class="textoCampos">Data Pag.:</td>
                                                                        <td class="CelulaZebra2">
                                                                            <input name="dtPagamento" type="text" id="dtPagamento" size="10" maxlength="10" value="" onblur="alertInvalidDate(this,true)" class="fieldDate" />
                                                                        </td>
                                                                        <td class="textoCampos">Docum.:</td>
                                                                        <td class="CelulaZebra2" colspan="2">
                                                                            <input name="docum" type="text" id="docum" size="6" maxlength="7" value="" class="inputTexto" />
                                                                        </td>
                                                                    </tr>
                                                                    
                                                                    
                                                                    
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td  colspan="7">
                                                                <table width="100%">
                                                                    <tbody id="aproprBody" name="duplBody" onload="applyFormatter();">
                                                                        <tr>
                                                                            <td class="tabela" align="center" colspan="6">
                                                                                Apropria&ccedil;&atilde;o gerencial
                                                                            </td>
                                                                        </tr>
                                                                        <tr class="tabela">
                                                                            <td width="2%">
                                                                                <a href="javascript: tryRequestToServer(function(){adicionaApropriacao();})">
                                                                                    <img src="${homePath}/img/novo.gif" alt="" class="imagemLink" title="Nova apropriação"/>
                                                                                </a>
                                                                            </td>
                                                                            <td width="40%">
                                                                                Plano centro de custo
                                                                            </td>
                                                                            <td width="15%">
                                                                                Ve&iacute;culo
                                                                            </td>
                                                                            <td width="10%">
                                                                                Valor
                                                                            </td>
                                                                            <td width="15%">
                                                                                Und. Custo
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                
                    <tr>
                        <td>
                            <table width="20%">

                                <td style='display: ${param.acao == '2' && param.nivel == 4 ? "" : "none"}' class="menu" id="tdAuditoria"
                                    onClick="AlternarAbasGenerico('tdAuditoria', 'divAuditoria')">
                                    Auditoria
                                </td>
                            </table>
                        </td>
                    </tr>
                    
                    
                    <tr>
                        <td>
                            <table width="100%" id="divAuditoria">
                                <tr>
                                    <td>
                                        <c:if test="${param.acao == '2'}">
                                             <table width="100%" align="center" class="bordaFina">   
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
                                                                                    em: ${param.criadoEm} <br>
                                                                                    por: ${param.criadoPor}              
                                                                                </td>
                                                                                <td class="TextoCampos" width="15%"> Alterado:</td>
                                                                                <td width="36%"> 
                                                                                    em: ${param.alteradoEm} <br>
                                                                                    por: ${param.alteradoPor}                                
                                                                                </td>

                                                                            </tr>   
                                                                        </table>
                                                                    </fieldset>
                                                                </td>
                                                            </tr>   
                                                        </table>
                                                    </td>
                                                </tr>
                                                </table>
                                            </c:if>
                                         </td>    
                                    </tr>
                                </table>
                            </td>
                        </tr>
                
            </table>
                                <table width="95%" align="center" class="bordaFina">                   
                                    <br>                                
                                        <c:if test="${param.nivel >= param.bloq}">
                                            <tr>
                                                <td colspan="6" class="CelulaZebra2" >
                                                    <div align="center">
                                                        <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:if>
                                </table>
        </form>
    </body>
</html>