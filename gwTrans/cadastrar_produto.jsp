<%--
    Document   : cadastrar_Produto
    Created on : 17/12/2008, 09:36:23
    Author     : Vladson Pontes
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript" language="JavaScript">
    
    jQuery.noConflict();
        
    arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdPrincipal','divPrincipal');
    arAbasGenerico[1] = new stAba('tdPalet','divPalet');
    arAbasGenerico[2] = new stAba('tdAbaAuditoria','divAuditoria');
    contProdutoDest = 0;
    //Função que instancia um objeto javascript do tipo ProdutoDestinatario
    function ProdutoDestinatario(id, idProduto,descricaoProduto,idDestinatario, descricaoDestinatario,
        basePaletizacao,alturaPaletizacao){
        this.id = (id != undefined)? id : 0;//Caso não tenha nenhum valor atribuir 0
        this.idProduto = (idProduto != undefined) ? idProduto : 0;
        this.descricaoProduto = (descricaoProduto != undefined) ? descricaoProduto : "";//Caso não tenha nenhum valor atribuir """
        this.idDestinatario = (idDestinatario != undefined) ? idDestinatario : 0;
        this.descricaoDestinatario = (descricaoDestinatario != undefined) ? descricaoDestinatario : "";
        this.basePaletizacao = (basePaletizacao != undefined) ? basePaletizacao : $("basePaletizacao").value;
        this.alturaPaletizacao = (alturaPaletizacao != undefined) ?  alturaPaletizacao : $("alturaPaletizacao").value;
    }
    
    function addProdutoDestinatario(produtoDestinatario){///Função que adiciona uma linha na tbody tbProdutoDest 
        if(produtoDestinatario == undefined | produtoDestinatario == null ){//Caso o objeto não esteja instanciado.
            produtoDestinatario = new ProdutoDestinatario();
        }
        contProdutoDest++;//Aumentar a contidade de ProdutoDestinatarios
        var tbProdutoDest = $("tbProdutoDest");//Tabela que vai ser gerada a linha.
        //
        
        var novaLinha =  Builder.node("tr",{id:"produtoDest"+contProdutoDest,name:"produtoDest"+contProdutoDest});
        
        //---------------------- TD Excluir ---------------
        var tdExcluir = Builder.node("td",{
            id:"excluir"+contProdutoDest, name:"excluir"+contProdutoDest,
            className: "CelulaZebra2NoAlign",
            align:"center"
        });
        var imgExcluir =  Builder.node("img",{//Imagem para ser visualizada na tela
            name: "imgExcluir"+contProdutoDest,
            id: "imgExcluir"+contProdutoDest,
            src: "img/lixo.png",
            className: "imagemLink",
            onClick: "excluirProdutoDestinatario(" + contProdutoDest + ");"//Função para Excluir uma linha passando o número da linha.
        });
        tdExcluir.appendChild(imgExcluir);//Adicionando a imagem a TD
        novaLinha.appendChild(tdExcluir);//Adicionando a td a nova linha.
        //---------------------------------------------
        
        //---------------- Id ProdutoDestinatario -----
        var hiddenProdutoDestinatario = Builder.node("input",{//Id do Destinatario
            type:"hidden", name:"idProdDest"+contProdutoDest, id:"idProdDest" + contProdutoDest,
            value: produtoDestinatario.id
        });
        novaLinha.appendChild(hiddenProdutoDestinatario);
        //----------------------------------------------
        //----------------------- TD Destinatário ------
        var tdDestinatario = Builder.node("td",{//Td do Destinatário
            id:"tdDestinatario"+contProdutoDest, name:"tdDestinatario"+contProdutoDest,
            className: "CelulaZebra2NoAlign",
            align: "center"
        });
        var hiddenDestinatario = Builder.node("input",{//Id do Destinatario
            type:"hidden", name:"idDestinatario"+contProdutoDest, id:"idDestinatario"+contProdutoDest,
            value: produtoDestinatario.idDestinatario
        });
        
        var inputProduto = Builder.node("input",{//Descrição do Destiinatário
            type:"text",
            id:"descricaoDestinatario"+contProdutoDest,
            name:"descricaoDestinatario"+contProdutoDest,
            size:"55",
            className:"inputReadOnly8pt2",
            readonly:"true", 
            value: produtoDestinatario.descricaoDestinatario
        });

        var buttonDestinatario = Builder.node("input",{//Botão que chamará à função
            type:"button",
            id:"btnDestinatario"+ contProdutoDest,
            name:"btnDestinatario"+ contProdutoDest,
            value:"...",
            className:"inputBotaoMin",
            onclick: "localizarDestinatario("+contProdutoDest+")"//Função que chama o localizar destinatário.
        })
        var imgBorrachaDestinatario =  Builder.node("img",{
            name: "imgBorrachaDestinatario"+contProdutoDest,
            id: "imgBorrachaDestinatario"+contProdutoDest,
            src: "img/borracha.gif",
            title: "Limpar Destinatário",
            className: "imagemLink",
            style: "margin-left: 5px;",
            onClick:"limparDestinatario("+contProdutoDest+");"
        });
        
        tdDestinatario.appendChild(hiddenDestinatario);//Adicionando hidden idDestinatario na TD
        tdDestinatario.appendChild(inputProduto);//Adicionando o input descricaoDestinatario na TD
        tdDestinatario.appendChild(buttonDestinatario);//Adicionando o botão btnDestinatario na TD
        tdDestinatario.appendChild(imgBorrachaDestinatario);//Adicionando idBorrachaDestinatário
        novaLinha.appendChild(tdDestinatario);//Adicionando a tdDestinatario  na nova linha
        // ---------------------------------------------
        
        //--------------------------- TD  Base Paletização ------------
        var tdPaletizacao = Builder.node("td",{//Td do Palet
            id:"tdPaletizacao"+contProdutoDest, name:"tdPaletizacao"+contProdutoDest,
            className: "CelulaZebra2NoAlign",
            align: "center"
        });
        var inputPaletizacao = Builder.node("input",{//Descrição do Destiinatário
            type:"text",
            id:"basePaletizacao"+contProdutoDest,
            name:"basePaletizacao"+contProdutoDest,
            size:"12",
            className:"fieldMin styleValor",
            value: produtoDestinatario.basePaletizacao,
            onkeypress: "mascara(this, reais)"//Função que só permite digitar números  inteiros.
        });
        tdPaletizacao.appendChild(inputPaletizacao)//Adicionando o input basePaletizacao na tdPaletizacao
        novaLinha.appendChild(tdPaletizacao);//Adicionando a tdBasePaletizacao na nova linha
        //-------------------------------------------------------------
        
        //--------------------------- TD  Altura ------------
        var tdAltura = Builder.node("td",{//Td da Altura
            id:"tdAltura"+contProdutoDest, name:"tdAltura"+contProdutoDest,
            className: "CelulaZebra2NoAlign",
            align: "center"
        });
        var inputAltura = Builder.node("input",{//número da altura
            type:"text",
            id:"alturaPaletizacao"+contProdutoDest,
            name:"alturaPaletizacao"+contProdutoDest,
            size:"12",
            className:"fieldMin styleValor",
            value: produtoDestinatario.alturaPaletizacao,
            onChange: "mascara(this, reais)"//Função que só permite digitar números  inteiros.
        });
        
        tdAltura.appendChild(inputAltura)//Adicionando o input basePaletizacao na tdPaletizacao
        novaLinha.appendChild(tdAltura);//Adicionando a tdAltura na nova linha
        //-------------------------------------------------------------
        
        //Adicionando na tabela.
        tbProdutoDest.appendChild(novaLinha);
        $("quantidadeProdutoDestinatario").value = contProdutoDest;
    }
    
    function limparProduto(index){
        $("idProduto"+index).value =   0;
        $("descricaoProduto"+index).value = "";
    }
    
    function limparDestinatario(index){
        $("idDestinatario"+index).value =   0;
        $("descricaoDestinatario"+index).value = "";
    }
    
    
    function limparCliente(){
        document.formulario.cliente.value = "";
        document.formulario.idCliente.value = "0";
        $("clienteCnpj").value = "";
    }

    function limparFabricante(){
        document.formulario.fabricante.value = "";
        document.formulario.idFabricante.value = "0";
        $("fabricanteCnpj").value = "";
    }
    
    function limparNcm(){
     //   $("ncm").value = " ";
        $("idNcm").value = "0";
    }

    function limparPicking(){
        document.formulario.picking.value = '';
        document.formulario.idPicking.value = '0';
    }
    
    function localizarPicking(){
        var tipoMercadoria = document.formulario.tipoMercadoria.value;
        abrirLocaliza("${homePath}/EnderecamentoControlador?acao=localizarPicking&tipoMercadoria=" + tipoMercadoria, "localizaPickingProd")
    }
    
    function localizarEnderecamentoAuto(){
        var tipoMercadoria = $("tipoMercadoria").value;
        tryRequestToServer(abrirLocaliza("${homePath}/EnderecamentoControlador?acao=localizarEnderecamentoAuto&tipoMercadoria=" + tipoMercadoria + "&campos=idEnderecoAuto!!enderecoAuto", "localizaEnderecamentoAuto"))
    }
    
    function localizarCliente(){
        popLocate(3, "Cliente","");
    }
    
    function localizarDestinatario(index){
        $("indexDoom").value = index;
        popLocate(4, "Destinatario","");
    }
    function localizarProduto(index){
        $("indexDoom").value = index;
        popLocate(50, "Produto","");
    }
    
    function localizarFabricante(){
        popLocate(67, "Fabricante","");
    }
    
    function localizarNcm(){
        abrirLocaliza("${homePath}/NCMControlador?acao=localizarNCM&modulo=gwLogis", "localizaNcm")
    }

    function igualarEntrada(valor){
        document.formulario.unidadeVenda.value = valor;
        var lb = document.getElementById("lbUndE");
        var hdOp = document.getElementById("hdOp"+valor);
        Element.update(lb, hdOp.value);
        Element.update($("lbUndESec"), hdOp.value);
        $("unidadeSecundaria").value = valor + "!!" + $("hdOp" + valor).value;
    }

    function igualarSaida(valor){
        var lb = document.getElementById("lbUndS");
        var hdOp = document.getElementById("hdOp"+valor);
        Element.update(lb, hdOp.value);
    }

    function calcularCubagem(){
        var altura = parseFloat(colocarPonto(document.getElementById("altura").value));
        var largura =  parseFloat(colocarPonto(document.getElementById("largura").value));
        var comprimento = parseFloat(colocarPonto(document.getElementById("comprimento").value));
        var cubagem = document.getElementById("cubagem");
        var cubagemC = (altura * largura * comprimento);
        Element.update(cubagem, colocarVirgula(cubagemC, 4) + " ");
    }

    function carregar(){
        try {
            var action = '<c:out value="${param.acao}"/>';
            var form = document.formulario;
             $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}"/>';
             $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
            
            
            if(action == 2){
                
                <c:forEach var="codImportacao" varStatus="status" items="${produtoCadProduto.codigoImportacao}">                
                    if (${status.count >= 2}) {
                        form.codigoImportacao.value += "," + '${codImportacao}';
                    }else{
                        form.codigoImportacao.value = '${codImportacao}';                    
                    }
                </c:forEach>
                
                form.codigo.value = '<c:out value="${produtoCadProduto.codigo}"/>';
//                form.codigoImportacao.value = '< c:out value="$ {produtoCadProduto.codigoImportacao}"/>';
                form.referencia.value = '<c:out value="${produtoCadProduto.referencia}"/>';
                form.descricao.value = '<c:out value="${produtoCadProduto.descricao}"/>';
                form.liquido.value =  colocarVirgula(<c:out value="${produtoCadProduto.pesoLiquido}"/>);
                form.bruto.value = colocarVirgula(<c:out value="${produtoCadProduto.pesoBruto}"/>);
                form.idProduto.value = '<c:out value="${produtoCadProduto.id}"/>';
                form.fatorConversao.value = colocarVirgula(<c:out value="${produtoCadProduto.fatorConversao}"/>);
                form.altura.value = colocarVirgula('<c:out value="${produtoCadProduto.altura}"/>',4);
                form.largura.value = colocarVirgula('<c:out value="${produtoCadProduto.largura}"/>',4);
                form.comprimento.value = colocarVirgula('<c:out value="${produtoCadProduto.comprimento}"/>',4);
                form.basePaletizacao.value = '<c:out value="${produtoCadProduto.basePaletizacao}"/>';
                form.alturaPaletizacao.value = '<c:out value="${produtoCadProduto.alturaPaletizacao}"/>';
                form.idCliente.value = '<c:out value="${produtoCadProduto.cliente.id}"/>';
                form.cliente.value = '<c:out value="${produtoCadProduto.cliente.razaosocial}"/>';
                form.clienteCnpj.value = '<c:out value="${produtoCadProduto.cliente.cnpj}"/>';
                form.idFabricante.value = '<c:out value="${produtoCadProduto.fabricante.id}"/>';
                form.fabricante.value = '<c:out value="${produtoCadProduto.fabricante.razaosocial}"/>';
                form.fabricanteCnpj.value = '<c:out value="${produtoCadProduto.fabricante.cnpj}"/>';
                
                document.getElementById("lbUndE").innerHTML = '<c:out value="${produtoCadProduto.unidadeMedidaEstoque.sigla}"/>'
                document.getElementById("lbUndS").innerHTML = '<c:out value="${produtoCadProduto.unidadeMedidaVenda.sigla}"/>';
                form.idPlano.value = '<c:out value="${produtoCadProduto.planoCusto.id}"/>';
                form.unidadeCustoId.value = '<c:out value="${produtoCadProduto.unidadeCusto.id}"/>';
                Element.update($("lbUndESec"), '${produtoCadProduto.unidadeMedidaEstoque.sigla}' );
                Element.update($("lbUndSec"), '${produtoCadProduto.unidadeSecundaria.sigla}' );
                $("fatorConversaoSec").value = colocarVirgula('${produtoCadProduto.fatorConversaoSecundaria}', 3);
                $("casasDecimais").value = '${produtoCadProduto.quantidadeCasasDecimais}';
                $("casasDecimaisValor").value = '${produtoCadProduto.quantidadeCasasDecimaisValor}';
                $("codigoBarras").value = '${produtoCadProduto.codigoBarras}';
                $("qtdVolumesEmbalagem").value = '${produtoCadProduto.qtdVolumesEmbalagem}';

                form.unidadeEstoque.value = '<c:out value="${produtoCadProduto.unidadeMedidaEstoque.id}"/>'
                igualarEntrada(form.unidadeEstoque.value);
                form.unidadeVenda.value = '<c:out value="${produtoCadProduto.unidadeMedidaVenda.id}"/>'
                igualarSaida(form.unidadeVenda.value);
                form.unidadeSecundaria.value = '<c:out value="${produtoCadProduto.unidadeSecundaria.id}"/>';
                alterarLabelSecundaria(form.unidadeSecundaria.value);
                calcularCubagem();
                "<c:forEach  var="prodDest" items='${produtoCadProduto.produtoDestinatario}'>"
                    var pd = new ProdutoDestinatario();
                    pd.id = "${prodDest.id}";
                    pd.idDestinatario = "${prodDest.destinatario.id}";
                    pd.descricaoDestinatario = "${prodDest.destinatario.razaosocial}";
                    pd.basePaletizacao = "${prodDest.basePaletizacao}";
                    pd.alturaPaletizacao = "${prodDest.alturaPaletizacao}";
                    addProdutoDestinatario(pd);
                 "</c:forEach>"
            }else{
                $("idCliente").value = '${param.idCliente}';
                $("cliente").value = '${param.cliente}';
                form.codigo.focus();
                
            }
        } catch (e) { 
            alert(e);
        }

    }

    function voltar(){
        tryRequestToServer(function(){(window.location = "ConsultaControlador?codTela=39")});
    }
    
    function aoClicarNoLocaliza(idJanela){
        try {
            var index = $("indexDoom").value;
            if (idJanela == "Fabricante") {
                $("fabricante").value = $("fab_rzs").value;
                $("fabricanteCnpj").value = $("fab_cnpj").value;
                $("idFabricante").value = $("fabricante_id").value;
            }else if(idJanela == "Cliente"){
                $("cliente").value = $("rem_rzs").value;
                $("clienteCnpj").value = $("rem_cnpj").value;
                $("idCliente").value = $("idremetente").value;
            }else if(idJanela == "Destinatario"){
                $("idDestinatario"+index).value = $("iddestinatario").value;
                $("descricaoDestinatario"+index).value = $("dest_rzs").value;
            }else if(idJanela == "Produto"){
                $("idProduto"+index).value = $("id").value;
                $("descricaoProduto"+index).value = $("descricao_produto").value;
            }
        } catch (e) { 
            alert(e);
        }
    }

    function alterarLabelSecundaria(unidade){
        Element.update($("lbUndSec"), unidade.split("!!")[1]);
    }

    function salvar(){
        var formu = document.formulario;
        if(formu.idCliente.value == "0"){
            return showErro("Informe o cliente!", $("cliente"), $("cliente_cnpj"));
        }

        if(formu.codigo.value == ""){
            alert("O campo 'Código' não pode ficar em branco!");
            formu.codigo.focus();
            return false;
        }

        if(formu.descricao.value == ""){
            alert("O campo 'Descrição' não pode ficar em branco!");
            formu.descricao.focus();
            return false;
        }
        
        if(!validarProdutoDestinatario()){
            return false;
        }
        
        setEnv();
        var pop = window.open('about:blank', 'pop', 'width=210, height=100');

        addProgressBar(pop);
        formu.submit();
        return true;

    }

    function enviarImagem(){
        var arquivo = $("arquivo");
        if(arquivo.value == ""){
            alert("Favor, selecionar uma imagem antes.");
            arquivo.focus();
        }else{
            var idProduto= $("idProduto").value;
            var formulario = $("formularioAnexar");
            formulario.action = formulario.action + "&idProduto=" + idProduto;
            formulario.submit();
        }

    }
    /*
     *Função: ecluir uma linha que do Doom referente ao ProdutoDestinatario.
     *@param Parametro: o index da linha que se encontra o ProdutoDestinatario que deseja Excluir.
     **/
    function excluirProdutoDestinatario(index){
        var linha = $("produtoDest"+index);
        var id = $("idProdDest"+index).value;
        var descricao = $("descricaoDestinatario"+index).value;
        if(confirm("Deseja excluir " + descricao +"?")){
            if(confirm("Tem certeza?")){
                if (id != 0) {
                    new Ajax.Request("ProdutoControlador?acao=excluirProdutoDestinatairio&modulo=gwTrans&idProdDest="+id,{
                        method:'get',
                        onSuccess: function(){Element.remove($(linha)); alert('Paletização removida com sucesso!'); },
                        onFailure: function(){ alert('Erro ao excluir a paletização...');return false }
                    });     
                 }else{
                    Element.remove($(linha));
                 }
            }
       }
    }
    
    function excluirImagem(){
        var idProduto= $("idProduto").value;
        var formulario = $("formularioExcluir");
        formulario.action = formulario.action + "&idProduto=" + idProduto;
        formulario.submit();

    }

    function visualizaImagem(imagem){
        abrirLocaliza("${homePath}/gwLogis/visualizar_imagem.jsp?imagem=" + imagem, "visualizaImagem");
    }
    /*
     * Função para verifica que todos os campos do ProdutoDestinatario foram informados corretamente
     *@event Se tiver campos não preenchidos ele mostrar uma alert com os campos que faltam.
     *@return Caso todos os campos tenham sido preenchido corretamente ele retorna "true" caso falte 
     *Algum campo ser preenchido ele retorna "false".
     */
    function validarProdutoDestinatario(){
        var res = true;//Já retorna verdadeiro se nada der errado.
        var msg = "";//variável que vai acumular as mensagens.
        var cont = 0;//Contador de campos que não foram preenchidos.
        var qtd = parseInt(contProdutoDest);//Quantidade de linhas adicionadas
        var linha = 0;
        if(parseInt(contProdutoDest) > 0){// Se tiver alguma linha adicionada.
            for(var i = 1; i <= qtd;i++){
               if($("produtoDest"+i) != null){//Caso a linha não foi excluida.
                   linha++;//Na do loop saber em qual linha está acontecendo o erro..
                    if($("idDestinatario"+i).value == "0"){
                        cont++;
                        msg += cont+"- Informe o destinatário da paletização na linha " + linha+"!\n" ;
                        res = false;
                    }
                }
            }
        }
        if(cont > 0){
            alert(msg);
        }
        return res;
    }
    
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
                var rotina = "produto";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = '<c:out value="${produtoCadProduto.id}"/>';
                console.log(rotina, id);
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
</script>

<style type="text/css">
    
    .style3 {color: #333333}
    .style4 {
        font-size: 14px;
        font-weight: bold;
    }
    .styleValor {
        text-align: right;
    }
    
</style>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Consulta de Produtos</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onload="carregar();AlternarAbasGenerico('tdPrincipal','divPrincipal');applyChangeHandler();">
        <img alt="" src="img/banner.gif" />
        <table class="bordaFina" width="80%" align="center">
            <tr>
                <td width="82%" align="left"> 
                    <span class="style4">Cadastro de Produtos</span>
                </td>
                <td>
                    <input type="button" value=" Voltar " class="inputBotao" onclick="voltar()"/>
                    <input type="hidden" id="idremetente" value="0"/>
                    <input type="hidden" id="rem_rzs" value=""/>
                    <input type="hidden" id="rem_cnpj" value="">
                    <input type="hidden" id="fabricante_id" value="0"/>
                    <input type="hidden" id="fab_rzs" value=""/>
                    <input type="hidden" id="fab_cnpj" value="">
                </td>
            </tr>
        </table>
        <br>
        
        <form action="ProdutoControlador?acao=${param.acao == 1 ? "cadastrar" : "editar"}" id="formulario" name="formulario" method="post" target="pop" >
            <!-- Campos de auxílio para serem usados no Doom -->
            <input type="hidden" name="quantidadeProdutoDestinatario" id="quantidadeProdutoDestinatario" value="0"/>
            <input type="hidden" name="indexDoom" id="indexDoom" value="0"/>
            <input type="hidden" name="id" id="id" value="0"/>
            <input type="hidden" name="descricao_produto" id="descricao_produto" value=""/>
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="0"/>
            <input type="hidden" name="dest_rzs" id="dest_rzs" value=""/>
       
                <table width="80%" align="center" class="bordaFina" >
                    <tr>
                        <td colspan="6" align="center" class="CelulaZebra2" >
                            <input type="hidden" name="modulo" id="modulo" value="gwLogis"/>
                            <input type="hidden" name="idMarca" id="idMarca" value="0"/>
                            <input type="hidden" name="idPlano" id="idPlano" value="0"/>
                            <input type="hidden" name="unidadeCustoId" id="unidadeCustoId" value="0"/>
                            <input type="hidden" name="isControlaEstoque" id="isControlaEstoque" value=""/>
                            <input type="hidden" name="estoqueInicial" id="estoqueInicial" value=""/>
                            <input type="hidden" name="estoqueInicialEm" id="estoqueInicialEm" value=""/>

                            <fieldset>
                                <legend>Dados principais</legend>
                                <table width="100%" class="tabelaZerada">
                                    <tr>
                                        <td class="TextoCampos" width="15%">*C&oacute;digo / C&oacute;digo XML:</td>
                                        <td class="CelulaZebra2" width="25%" colspan="2" >
                                            <input name="codigo" id="codigo" type="text" class="fieldMin" size="14" maxlength="60"/> /
                                            <input name="codigoImportacao" id="codigoImportacao" type="text" class="fieldMin" size="14" maxlength="60"/>
                                            <input type="hidden" name="idProduto" id="idProduto"/>                    
                                        </td>
                                        <td class="TextoCampos" width="20%">Refer&ecirc;ncia:</td>
                                        <td class="CelulaZebra2" colspan="2">
                                            <input name="referencia" type="text" class="fieldMin" size="10" maxlength="20"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos" >*Descri&ccedil;&atilde;o:</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            <input name="descricao" id="descricao" type="text" class="fieldMin" size="50" maxlength="120"/>
                                        </td>
                                        <td class="TextoCampos" width="15%"></td>
                                        <td class="CelulaZebra2" width="25%">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Peso Liquido:</td>
                                        <td class="CelulaZebra2" colspan="2">
                                            <input name="liquido" id="liquido"  maxlength="10" type="text" class="fieldMin styleValor" size="10"value="0,00" onkeypress="mascara(this, reais,2)" />
                                            KG
                                        </td>
                                        <td class="TextoCampos" >Peso Bruto:</td>
                                        <td class="CelulaZebra2" colspan="2" >
                                            <input name="bruto" id="bruto" 
                                                   maxlength="10" type="text" class="fieldMin styleValor" size="10" onblur="" value="0,00" onkeypress="mascara(this, reais,2)" />
                                            KG
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos" >Fabricante:</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            <input name="fabricante" id="fabricante" type="text" class="inputReadOnly8pt2" size="30" readonly />
                                            <input name="fabricanteCnpj" id="fabricanteCnpj" type="text" class="inputReadOnly8pt2" size="22" readonly />
                                            <input type="hidden" name="idFabricante" value="0" id="idFabricante"/>
                                            <input type="button" id="locCliente" onclick="tryRequestToServer(function(){localizarFabricante()})" value="..." class="inputBotaoMin"/>
                                            <img alt="" src="img/borracha.gif" id="borracha" onclick="limparFabricante()" class="imagemLink"/>
                                        </td>
                                        <td class="CelulaZebra2" colspan="2"></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                </table>
            <br>
            <table align="center" width="80%" >
                    <tr>
                        <td width="100%">
                            <table align="left">
                                <tr>
                                    <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal','divPrincipal')"> Dados de armazenagem </td>
                                    <td id="tdPalet" class="menu" onclick="AlternarAbasGenerico('tdPalet','divPalet')"> Paletização dos Destinatários</td>
                                    
                                    <td style='display:${param.acao == 2 && param.nivel == 4 ? "" : "none"} ' id="tdAbaAuditoria" name="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                   
                                    </tr>
                            </table>
                        </td> 
                    </tr>
                </table>
            
             <div id="divPrincipal"> 
                           
                    <table width="80%" align="center" class="bordaFina" >
                    <tr>
                        <td colspan="6" align="center" class="CelulaZebra2" >
                            <table width="100%" class="tabelaZerada">
                                    <tr>
                                        <td class="TextoCampos" >Und. Entrada:</td>
                                        <td class="CelulaZebra2" >
                                            <select name="unidadeEstoque" class="fieldMin" onChange="igualarEntrada(this.value)">
                                                <c:forEach var="unidade" items="${unidadesCadProduto}">
                                                    <option value="${unidade.id}">${unidade.sigla}</option>
                                                </c:forEach>
                                            </select>                                
                                        </td>
                                        <td class="TextoCampos" >Und. Sa&iacute;da:</td>
                                        <td class="CelulaZebra2" >
                                            <select name="unidadeVenda" class="fieldMin" onChange="igualarSaida(this.value)">
                                                <c:forEach var="unidade" items="${unidadesCadProduto}">
                                                    <option value="${unidade.id}">${unidade.sigla}</option>
                                                </c:forEach>
                                            </select>
                                            <c:forEach var="unidade" items="${unidadesCadProduto}">
                                                <input type="hidden" value="${unidade.sigla}" id="hdOp${unidade.id}" />
                                            </c:forEach>
                                        </td>
                                        <td class="TextoCampos">Fator de Convers&atilde;o:</td>
                                        <td class="CelulaZebra2">1 
                                            <label id="lbUndE" > ${unidadesCadProduto[0].sigla} </label> 
                                            =
                                            <input name="fatorConversao" id="fatorConversao" value="1"  maxlength="10" type="text" onkeypress="mascara(this, reais)" class="fieldMin styleValor" size="6"  />
                                            <label id="lbUndS"> ${unidadesCadProduto[0].sigla} </label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Quantidade de Volumes por Embalagem:</td>
                                        <td class="CelulaZebra2">
                                            <input name="qtdVolumesEmbalagem" id="qtdVolumesEmbalagem" value=""  maxlength="10" type="text" class="inputtexto" size="6"/>
                                        </td>
                                        <td class="TextoCampos" >Und. Secund&aacute;ria:</td>
                                        <td class="CelulaZebra2" >
                                            <select name="unidadeSecundaria" id="unidadeSecundaria" class="fieldMin" onChange="alterarLabelSecundaria(this.value)">
                                                <c:forEach var="unidade" items="${unidadesCadProduto}">
                                                    <option value="${unidade.id}">${unidade.sigla}</option>
                                                </c:forEach>
                                                <c:forEach var="unidade" items="${unidadesCadProduto}">
                                                    <input type="hidden" value="${unidade.sigla}" id="hdOp${unidade.id}" />
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td class="TextoCampos">Fator de Convers&atilde;o:</td>
                                        <td class="CelulaZebra2">
                                            <input name="fatorConversaoSec" id="fatorConversaoSec" value="1"  maxlength="10" type="text" onkeypress="mascara(this, reais, 3)" class="fieldMin styleValor decimal3" size="6"  />
                                            <label id="lbUndESec" > ${unidadesCadProduto[0].sigla} </label> 
                                            = 1 
                                            <label id="lbUndSec"> ${unidadesCadProduto[0].sigla} </label>
                                        </td>
                                    </tr>                                
                                    <tr>
                                        <td class="TextoCampos" >Cubagem:</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            Alt:
                                            <input name="altura" id="altura" maxlength="7" onkeypress="mascara(this, reais,4)" onblur="calcularCubagem()" type="text" class="fieldMin styleValor decimal4" size="8"  value="0,0000"  />
                                            X Larg:
                                            <input name="largura" id="largura" maxlength="7" onkeypress="mascara(this, reais,4)" onblur="calcularCubagem()" type="text" class="fieldMin styleValor decimal4" size="8"  value="0,0000"  />
                                            X Comp:
                                            <input name="comprimento" id="comprimento" maxlength="7" onkeypress="mascara(this, reais,4)" onblur="calcularCubagem()" type="text" class="fieldMin styleValor decimal4" size="8"  value="0,0000"  />
                                            = <label  id="cubagem"> 0,00 </label> M&sup3;</td>
                                        <td class="TextoCampos">Norma de Paletiza&ccedil;&atilde;o:</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            Base 
                                            <input name="basePaletizacao" id="basePaletizacao" value="0"  maxlength="10" type="text" class="fieldMin styleValor" size="6" onkeypress="mascara(this, reais)"  />
                                            X
                                            <input name="alturaPaletizacao" id="alturaPaletizacao" value="0"  maxlength="10" type="text" class="fieldMin styleValor" size="6" onkeypress="mascara(this, reais)"  /> Altura                             
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos" colspan="3" >Quantidade de casas decimais para controle de estoque</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            <select class="fieldMin" name="casasDecimais" id="casasDecimais">
                                                <option value="0">Zero</option>
                                                <option value="1">Uma</option>
                                                <option value="2" selected>Duas</option>
                                                <option value="3">Tr&ecirc;s</option>
                                                <option value="4">Quatro</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos" colspan="3" >Quantidade de casas decimais para valores</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            <select class="fieldMin" name="casasDecimaisValor" id="casasDecimaisValor">
                                                <option value="2">Duas</option>
                                                <option value="3">Tr&ecirc;s</option>
                                                <option value="4">Quatro</option>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos"  >Código de Barra:</td>
                                        <td class="CelulaZebra2" colspan="2" >
                                            <input name="codigoBarras" id="codigoBarras" type="text" class="fieldMin" size="20" maxlength="14" />
                                        </td>
                                        <td class="TextoCampos" >Cliente:</td>
                                        <td class="CelulaZebra2" colspan="2" >
                                            <input name="cliente" id="cliente" type="text" class="inputReadOnly8pt2" size="30" readonly />
                                            <input name="clienteCnpj" id="clienteCnpj" type="text" class="inputReadOnly8pt2" size="22" readonly />
                                            <input type="hidden" name="idCliente" value="0" id="idCliente"/>
                                            <input type="button" id="locCliente" onclick="tryRequestToServer(function(){localizarCliente()})" value="..." class="inputBotaoMin"/>
                                            <img alt="borracha" src="img/borracha.gif" id="borracha" onclick="limparCliente()" class="imagemLink"/>
                                        </td>
                                    </tr>
                                </table>
                           <input type="hidden" name="tipo" value="T"/>
                        </td>
                    </tr>
                </table>
            </div><!-- Fim da div Principal --->
            <div id="divPalet" >
                <table width="80%" align="center" class="bordaFina">
                    <tr class="tabela">
                        <td>Paletização</td>
                    </tr>
                    <tr>
                        <td width="100%">
                            <table align="center" width="100%" class="bordaFina">
                                <tbody id="tbProdutoDest">
                                    <tr class="celula">
                                        <td width="5" align="center" >
                                            <img class="imagemLink" width="16px" src="img/novo.gif" alt="addCampo" onclick="addProdutoDestinatario();">
                                        </td>
                                        <td align="center" width="45%">Destinatário</td>
                                        <td align="center" width="25%">Base</td>
                                        <td align="center" width="25%">Altura</td>
                                    </tr>
                                </tbody>
                            </table>
                         </td>
                    </tr>
                </table>
            </div>
                   
            <div id="divAuditoria" name="divAuditoria"   >
                
                    <table width="80%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria"  style='display:${param.acao == 2 && param.nivel == 4 ? "" : "none"} ' >
                       
                        <%@include file = "template_auditoria.jsp" %>
                            <tr>
                                <td colspan="8"> 
                                    <table width="100%" align="center" class="bordaFina">
                                        <tr class="CelulaZebra2">
                                            <td class="TextoCampos" width="15%"> Incluso:</td>

                                            <td width="35%" class="CelulaZebra2"> em: ${produtoCadProduto.criadoEm} <br>
                                                por: ${produtoCadProduto.criadoPor.nome} 
                                            </td>

                                            <td width="15%" class="TextoCampos"> Alterado:</td>
                                            <td width="35%" class="CelulaZebra2"> em: ${produtoCadProduto.atualizadoEm} <br>
                                                por: ${produtoCadProduto.atualizadoPor.nome}
                                            </td>
                                        </tr>   
                                    </table>                  
                                </td>
                            </tr>
                           
                      </table>
            </div> 
                        <br/>
                        <table class="bordaFina" width="80%" align="center" style='display: ${param.nivel >= param.bloq ? "" : "none"}'>
                            <tr>
                                <td colspan="6" class="CelulaZebra2" >
                                    <div align="center">
                                        <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onclick="tryRequestToServer(function(){salvar()})"/>
                                    </div>
                                </td>
                            </tr>
                        </table>
                <br/>        
        
        </form>
                       
       
        
          
        
        
    </body>
</html>

