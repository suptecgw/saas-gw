<%@page import="java.util.Collection"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         nucleo.BeanConfiguracao,
         conhecimento.duplicata.fatura.*,
         conhecimento.duplicata.*,
         java.text.*,
         java.util.Date,
         java.util.List,
         mov_banco.conta.*,
         nucleo.Apoio,
         nucleo.boleto.retorno.RetornoBO,
         conhecimento.BeanConsultaConhecimento,
         filial.BeanFilial,
         nucleo.BeanLocaliza" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>

<%
//---------------------------------- Permissões ------------------------------
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("bxreceber") : 0);
    int nivelUserCtrc = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelNf = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    int nivelCtrcFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
//---------------------------------- Permissões ------------------------------ fim

    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");

    boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
    int idUsuario = Apoio.getUsuario(request).getIdusuario();

    //Classes
    BeanConsultaFatura dupls = null;
    BeanConsultaFatura dupls1 = null;
    BeanConfiguracao cfg = new BeanConfiguracao();
    BeanAlteraDuplicata altDupls = null;
    BeanDuplicata duplicata = null;
 //BeanFatura fatura = null;

    //----------------------------- Ação de Baixa --------------------------------
    if (acao.equals("baixarFatura")) {
        BeanDuplicata[] arDupls = new BeanDuplicata[Integer.parseInt(request.getParameter("maxDupl"))];
        altDupls = new BeanAlteraDuplicata();
        altDupls.setExecutor(Apoio.getUsuario(request));
        altDupls.setConexao(Apoio.getUsuario(request).getConexao());

        String idfatura = "";
        String dtConciliacao = "";
        int count = 0;
        double parcela = 0;
        double valor = 0;
        double vlPago = 0;
        double valorParcelaFinal = 0;
        double percParcela = 0;
        double valorReal = 0;

        for (int i = 0; i <= Integer.parseInt(request.getParameter("maxFat")); i++) {
            if (request.getParameter("chk_".concat(String.valueOf(i))) != null) {
                idfatura = request.getParameter("idFatura_".concat(String.valueOf(i)));
                valor = Apoio.parseDouble(request.getParameter("valor_".concat(String.valueOf(i))));
                vlPago = Apoio.parseDouble(request.getParameter("vlpago_".concat(String.valueOf(i))));

                double totalDesconto = (valor - vlPago);
                double totalJaPago = 0;
                double totalAcrescimoPago = 0;
                double totalDescrismoPago = 0;
                //dtConciliacao = (request.getParameter("isArquivoRetorno").equals("true") ? request.getParameter("dtpagamento_" +i) : request.getParameter("dtconciliacao"));
                dtConciliacao = request.getParameter("dtconciliacao_".concat(String.valueOf(i)));
                int totDupls = Apoio.parseInt(request.getParameter("maxDupl_".concat(String.valueOf(idfatura))));

//                double acrescimoDuplicataDupli = Apoio.parseDouble(request.getParameter("vlAcrescimo_" + idfatura + "_" + i));
//
//                double acrescimo = acrescimoDuplicataDupli / totDupls;

                for (int j = 0; j < totDupls; j++) {
                    if (request.getParameter("idParcela_".concat(idfatura).concat("_").concat(String.valueOf(j))) != null) {
                        duplicata = new BeanDuplicata();
                        // calculo do valor pago proporcional
                        parcela = Apoio.parseDouble(request.getParameter("vlParcela_".concat(idfatura).concat("_").concat(String.valueOf(j))));
                        parcela = Apoio.roundABNT(parcela, 2);
                        
                        if (vlPago == valor) {
                            valorParcelaFinal = parcela;
                        } else if ((Apoio.parseDouble(request.getParameter("vlAcrescimo_".concat(idfatura).concat("_").concat(String.valueOf(j)))) > 0) && (valor - vlPago) > 0){ 
                            valorParcelaFinal = parcela;
                        }else {
                            if (j == totDupls - 1) {//Ultima posicao do array
                                valorParcelaFinal = (vlPago - totalJaPago);
                            } else {
                                percParcela = Apoio.roundABNT(parcela * 100,2) / valor; //percentual parcela
                                valorParcelaFinal = parcela - Apoio.roundABNT((totalDesconto * (percParcela / 100)),2);
                                totalJaPago += Apoio.roundABNT(valorParcelaFinal, 2);
                            }
                        }
                        duplicata.setId(Integer.parseInt(request.getParameter("idParcela_".concat(idfatura).concat("_").concat(String.valueOf(j)))));
                        duplicata.setIdmovimento(Integer.parseInt(request.getParameter("idMovimento_".concat(idfatura).concat("_").concat(String.valueOf(j)))));
                        duplicata.setVlduplicata(Apoio.parseDouble(request.getParameter("vlParcela_".concat(idfatura).concat("_").concat(String.valueOf(j)))));
                        
                        double valorAcrescimoDuplicata = 0;
                        double valordescontoDuplicata = 0;
                        if (Apoio.parseDouble(request.getParameter("vlAcrescimo_".concat(idfatura).concat("_").concat(String.valueOf(j)))) > 0) {
                            //estou fazendo a divisão aqui, pego o total das duplicatas e divido pelo valor do acrescimo.
                            double acrescimoDuplicata = Apoio.parseDouble(request.getParameter("vlAcrescimo_".concat(idfatura).concat("_").concat(String.valueOf(j))));
                            double descontoDuplicata = (valor - vlPago);
                             valorReal = (valor - acrescimoDuplicata);
                            if (valorReal < 0) {
                                valorReal = valorReal * -1;
                            }
                            //vai fazer o loop na quantidade de faturas, sendo na ultima interação entra no if e pega o restante do valor so para desconto - historia 3209
                            if (descontoDuplicata > 0) {
                                 if (j == totDupls - 1) {
                                    valorAcrescimoDuplicata = (acrescimoDuplicata - totalAcrescimoPago);
                                    valordescontoDuplicata = (descontoDuplicata - totalDescrismoPago);
                                }else{
                                    valorAcrescimoDuplicata = Apoio.roundABNT(((acrescimoDuplicata / valorReal) * parcela),2);
                                    valordescontoDuplicata = Apoio.roundABNT(((descontoDuplicata / valorReal) * parcela),2);
                                    totalAcrescimoPago += Apoio.toFixed(valorAcrescimoDuplicata, 2);
                                    totalDescrismoPago += Apoio.toFixed(valordescontoDuplicata, 2);
                                }
                                duplicata.setVlpago(valorParcelaFinal + (valorAcrescimoDuplicata - valordescontoDuplicata));
                                
                            }else{
                                //vai fazer o loop na quantidade de faturas, sendo na ultima interação entra no if e pega o restante do valor so para acrescimo - historia 3209
                                if (j == totDupls - 1) {
                                    valorAcrescimoDuplicata = (acrescimoDuplicata - totalAcrescimoPago);
                                    
                                }else{
                                    valorAcrescimoDuplicata = ((acrescimoDuplicata / valorReal) * parcela);
                                    totalAcrescimoPago += Apoio.roundABNT(valorAcrescimoDuplicata, 2);
                                }
                                    duplicata.setVlpago(valorParcelaFinal + valorAcrescimoDuplicata);
                            } 
                        } else {
                            duplicata.setVlpago(Apoio.roundABNT(valorParcelaFinal,2));
                        }
                        duplicata.setDtpago(Apoio.getFormatData(request.getParameter("dtpagamento_".concat(String.valueOf(i)))));
                        duplicata.setDtbaixa(Apoio.getFormatData(Apoio.getDataAtual()));
                        duplicata.getFatura().setSituacao(request.getParameter("situacao_".concat(String.valueOf(i))).trim().equals("Descontada") ? "DT" : "");
                        duplicata.setCriaPcs(false);
                        duplicata.setDtNovaPcs(null);
                        duplicata.getFpag().setIdFPag(5);
                        duplicata.getMovBanco().getConta().setIdConta(Integer.parseInt(request.getParameter("contaBaixa").split("!!")[0]));
                        duplicata.getMovBanco().setDocum(request.getParameter("numeroFatura_".concat(String.valueOf(i))).split("/")[0]);
                        duplicata.getMovBanco().setHistorico("RECEBIMENTO DA FATURA: ".concat(request.getParameter("numeroFatura_".concat(String.valueOf(i)))).concat(request.getParameter("cliente_".concat(String.valueOf(i))) == null ? "" : " DO CLIENTE ".concat(request.getParameter("cliente_".concat(String.valueOf(i))))));
                        duplicata.getMovBanco().setDtEmissao(Apoio.getFormatData(dtConciliacao));
                        duplicata.getMovBanco().setDtEntrada(Apoio.getFormatData(dtConciliacao));
                        duplicata.getFatura().setTipoBaixa(request.getParameter("tipoBaixa"));
                        duplicata.getMovBanco().getCliente().setIdcliente(Apoio.parseInt(request.getParameter("clienteID_"+i)));
                        duplicata.getMovBanco().setValor(duplicata.getVlpago());
                        duplicata.getMovBanco().getUsuario().setIdusuario(Apoio.getUsuario(request).getIdusuario());
                        duplicata.getMovBanco().setConciliado(request.getParameter("chkconciliado") != null ? true : false);
                        duplicata.setDescricaoDesconto(request.getParameter("descricaoDesconto_".concat(String.valueOf(i))));

                        arDupls[count] = duplicata;
                        count++;
                    }
                }
            }
        }
        altDupls.setArrayBDupls(arDupls);

        //sem cheque
        cheque[] arChqs = new cheque[10];
        altDupls.setArrayChq(arChqs);
        boolean erroBaixar = !altDupls.Atualiza(1);
        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
        if (erroBaixar) {
            response.getWriter().append("<script>alert('" + altDupls.getErros() + "');");
            response.getWriter().append("window.opener.espereEnviar('', false);window.close();</script>");
        } else {
            response.getWriter().append("<script>window.opener.totalSelecionado();");
            response.getWriter().append("window.opener.location= './bxcontasreceberLote.jsp?acao=iniciar';window.close();</script>");
        }
        response.getWriter().close();

  //----------------------------- Ação de Baixa -------------------------------- fim
        // ---------------------------- Ações de consulta ----------------------------
    } else if (acao.equals("consultarFatura")) {
        RetornoBO retornoBO = new RetornoBO();
        dupls = new BeanConsultaFatura();
        dupls.setConexao(Apoio.getUsuario(request).getConexao());

        int linha = Integer.parseInt(request.getParameter("linha"));
        String tipo = request.getParameter("tipo");
        String campo = request.getParameter("campo");
        String ano = request.getParameter("ano");
        String[] listaIdFaturas = request.getParameter("listaIdFaturas").split("!!");
        
        if (dupls.visualizarLoteItau(tipo, campo, ano, null, 0)) {
            boolean duplicado = false;
//          Comentando variavel por que agora toda fatura é tratada uma por uma 
//          pesquisando separado por virgula, precisamos agora adicionar as que não 
//          estão baixada e validar as que foram quitadas.
//          boolean baixado = false;

            String resultado = "";

            ResultSet fat = dupls.getResultado();
            while (fat.next()) {

                for(String idfatura : listaIdFaturas){
                    if (fat.getString("id").equals(idfatura)) {
                        duplicado = true;
                        resultado = "load=duplicado&&&";
                        break;
                    }
                }
                
                String nFaturasQuitadas = "";
                if (fat.getBoolean("is_baixado")) {
                    nFaturasQuitadas.concat(fat.getString("fatura"));
                    resultado = "load=baixado,numero=".concat(nFaturasQuitadas).concat("&&&");
                //    baixado = true;
                }
                
                
                
                if (!duplicado && !fat.getBoolean("is_baixado")) {
                    duplicata = new BeanDuplicata();
                    duplicata.getFatura().setId(fat.getInt("id"));
                    duplicata.getFatura().setSituacao(fat.getString("situacao"));
                    duplicata.getFatura().setNumero(fat.getString("fatura"));
                    duplicata.getFatura().setValorAcrescimo(fat.getDouble("valor"));
                    duplicata.getFatura().setValorDesconto(fat.getDouble("valor_desconto"));
                    duplicata.setVlpago(fat.getDouble("valor"));
                    duplicata.setDtpago(fat.getDate("vence_em"));
                    duplicata.getMovBanco().setDtEntrada(new Date());
                    duplicata.setDtbaixa(new Date());
                    duplicata.getFatura().setEmissaoEm(fat.getDate("emissao_em"));
                    duplicata.getFatura().setVenceEm(fat.getDate("vence_em"));
                    duplicata.getFatura().getCliente().setRazaosocial(fat.getString("cliente"));
                    duplicata.getFatura().getCliente().setIdcliente(fat.getInt("cliente_id"));
                    duplicata.getFatura().setBoletoNossoNumero(fat.getString("boleto_nosso_numero") == null || fat.getString("boleto_nosso_numero").equals("") ? 0 : fat.getLong("boleto_nosso_numero"));
                    duplicata.getFatura().setStatusSituacaoFatura(fat.getString("situacao_fatura"));
                    duplicata.getFatura().setDescricaoDesconto(fat.getString("descricao_desconto"));
                    
                    
                    //montarFatura() É ONDE MONTAMOS OS VALORES DA BAIXA NA tbody tbFatura
                    resultado = retornoBO.montarFatura(linha, duplicata,
                            Apoio.getUsuario(request).getConexao(),
                            nivelUser, nivelNf, nivelUserCtrc, nivelCtrcFilial,
                            Apoio.getUsuario(request).getFilial().getIdfilial(), false,"");
                    linha++;
                }
                                               
                response.getWriter().append(resultado);
            }
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    }

// ---------------------------- Ações de consulta ---------------------------- fim
%>

<script language="javascript" type="text/javascript">
    
    function mostrarDescricaoDesconto(id) {
        $('vlpago_'+id).value = soNumerosVirgula($("vlpago_"+id).value);
        $('valor_'+id).value = soNumerosVirgula($("valor_"+id).value);
        var isValidando = (parseFloat(colocarPonto($("valor_"+id).value)) > parseFloat(colocarPonto($("vlpago_"+id).value)));
        
        if(isValidando) {
            $("trDescrDescnt_"+id).style.display = '';
        }else {
            $("trDescrDescnt_"+id).style.display = 'none';
        }
    }
    
    var ctrcAux = '0';
    var fatAux = '0';
    var zebraAux = '1';
    var idxOco = 0;

    shortcut.add("Alt+V", function () {
        $('visualizar').click();
    });
    shortcut.add("Alt+B", function () {
        $('baixar').click();
    });

    function baixarfatura() {


        var selecao = false;
        for (var i = 0; i <= $("maxFat").value - 1; i++) {
            if ($('chk_' + i) != null && $('chk_' + i).checked) {
                selecao = true;
                var j = 0;
                var idFatura = $("idFatura_" + i).value;
                while ($("idParcela_" + idFatura + "_" + j) != null) {
                    $('maxDupl').value = parseFloat($('maxDupl').value) + 1;
                    $("maxDupl_" + idFatura).value = parseFloat($("maxDupl_" + idFatura).value) + 1;
                    j++;
                }
            }
        }

        if (!selecao) {
            alert("Selecione no mínimo uma fatura.");
            return false;
        }

        if ($("tipoFiltro3").checked) {
            $("contaBaixa").value = $("contaRet").value;
            $("tipoBaixa").value = "'A'"; //se for tipofiltro3(arq. retorno), tipoBaixa recebe a string  'A' (arquivo de retorno)
        } else {
            $("contaBaixa").value = $("conta").value;
            $("tipoBaixa").value = "'M'"; //se não for tipofiltro3(arq. retorno) tipoBaixa recebe a string 'M' (baixa manual)
        }

        espereEnviar("", true);

        $("formBx").action = "./bxcontasreceberLote.jsp?acao=baixarFatura";
        $("formBx").target = "pop";
        $("formBx").method = "post";

        //habilitaSalvar(false);
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formBx").submit();
        return true;
    }

    function validaTipoConsulta(valor) {
        if (valor == "arquivo_retorno") {
            $("contaRet").style.display = "";
            $("conta").style.display = "none";
            $("divConta").style.display = "none";
            $("contaRet").style.width = "120px";
        } else {
            $("contaRet").style.display = "none";
            $("conta").style.display = "";
            $("divConta").style.display = "";
            $("contaRet").style.width = "120px";
        }
    }

    function mudarConta() {
        if ($("contaRet").value.split("!!")[1] == "carrefour") {
            $("conta").style.display = "";
            $("divConta").style.display = "";
            desabilitar($("conta"));
        } else {
            habilitar($("conta"));
            $("divConta").style.display = "none";
            $("conta").style.display = "none";
        }
    }

//---------------------- Carregar -- inicio
    function carregarDetalhes(faturaId, zebra, botao) {
        if (botao == "minus") {
            $("trCtrc_" + faturaId).style.display = "none";
            $("plus_" + faturaId).style.display = "";
            $("minus_" + faturaId).style.display = "none";
        } else {
            $("plus_" + faturaId).style.display = "none";
            $("minus_" + faturaId).style.display = "";
            $("trCtrc_" + faturaId).style.display = "";
        }
    }

    function carregarFaturas() {
        
        var valorConsulta = "";
        var tipoConsulta = "";
        var ano = "";
        try{
            
        if ($("tipoFiltro3").checked) {
            tipoConsulta = "arquivo_retorno";
            valorConsulta = $("arqRetorno").value;

            if (valorConsulta == '') {
                alert('Informe o arquivo corretamente!');
                return false
            }
            visualisarArquivoRet();
        } else {
            if ($("tipoFiltro1").checked) { //numero fatura
                tipoConsulta = "f.numero";
                valorConsulta = $("fatura").value;
                ano = $("ano").value;
            } else if ($("tipoFiltro2").checked) { //nosso numero
                tipoConsulta = "f.boleto_nosso_numero";
                valorConsulta = $("nossoNumero").value;
            }

            if (valorConsulta == '') {
                alert('Informe o campo a ser consultado!');
                return false
            }

            //objeto funcao usado na requisicao Ajax(uma espécie de evento)
            function j(transport) {
                var textoresposta = transport.responseText;
                espereEnviar("", false);

                //se deu algum erro na requisicao...
                if (textoresposta == "") {
                    alert("A fatura não foi encontrada.");
                    return false;
                } else if (textoresposta == "load=0") {
                    alert("A fatura não foi encontrada.");
                    return false;
                } else if (textoresposta == "load=duplicado") {
                    alert("A fatura já foi inserida.");
                    return false;
                } else if (textoresposta == "load=baixado") {
                    alert("A fatura já foi baixada totalmente ou parcialmente.");
                    return false;
                } else {
                    var a = $("tbFatura");
                    var max = textoresposta.split("&&&").length;
                    var retornoTex = "";
                    var numeroFatquitada = "";
                    //Criando um for para toda vez que for adicionar dados separado por virgula na tela,
                    //listar todos que estiverem no textoresposta. 
                    //Adicionei o operador &&& para ter um breack toda vez que terminar uma linha dos resultados.
                    for (var i = 0; i < parseInt(max); i++) {
                        
                        if (textoresposta.split("&&&")[i].indexOf("load=baixado") > -1) {
                            //Pegando o número da fatura quitada vindo como parametro do Ajax
                            if (retornoTex == "") {
                                numeroFatquitada += textoresposta.split("&&&")[i].split(",")[1].split("=")[1];
                            }else{
                                numeroFatquitada += "," + textoresposta.split("&&&")[i].split(",")[1].split("=")[1];
                            }
                            //Cada vez que existir uma fatura baixada concatena a variavel abaixo para poder validar com o número da fatura logo depois do for.
                            retornoTex = "load=baixado";
                            
                            //Se for uma fatura duplicada mostra um alert que já existe na tela.
                        }else if(textoresposta.split("&&&")[i] == "load=duplicado"){
                            alert("A fatura já foi inserida!");
                        }else{
                            //Ao invés de substituir o HTML toda vez que faz uma requisição ele inseri e deixa todos que foram pesquisado.
                            a.insert(replaceAll(textoresposta.split("&&&")[i], ",!", ";"));
                        }
                        
                    }
                    
                    //Informa ao usuário as faturas que estão baixada.
                    if (retornoTex == "load=baixado") {
                        alert("A(s) fatura(s) " + numeroFatquitada + " já foi(ram) baixada(s) totalmente ou parcialmente.");                        
                    }
                    
//                  a.insert(replaceAll(textoresposta, ",!", ";"));

                    fatAux++;

                    $("maxFat").value = parseFloat($("maxFat").value) + 1;
                    $("fatura").value = "";
                    //$("ano").value = "";
                    $("nossoNumero").value = "";
                    $("arqRetorno").value = "";

                    if ($("tipoFiltro1").checked) {
                        $("fatura").focus();
                    } else if ($("tipoFiltro2").checked) {
                        $("nossoNumero").focus();
                    } else {
                        $("arqRetorno").focus();
                    }

                    totalSelecionado();
                }
            }//funcao j()

            espereEnviar("", true);

            var listaIdFaturas = "";
            var i = 0;
            while ($("idFatura_" + i) != null) {
                listaIdFaturas += (i != 0 ? "!!" : "") + $("idFatura_" + i).value;
                i++;
            }

            
            tryRequestToServer(function () {
                new Ajax.Request("./bxcontasreceberLote.jsp?acao=consultarFatura&tipo=" + tipoConsulta +
                        "&campo=" + valorConsulta + "&ano=" + ano + "&linha=" + fatAux +
                        "&listaIdFaturas=" + listaIdFaturas,
                        {method: 'post', onSuccess: j, onError: j});
            });
        }
        
        }catch(e){
            alert(e);
        }
        
    }

    function visualisarArquivoRet() {
        espereEnviar("", true);

        var conta = $("contaRet").value;
        $("formRet").action = "ArquivoRetornoControlador?conta=" + conta + "&isOcoRetAll=" + $("isOcoRetAll").checked;
        $("formRet").target = "";
        $("formRet").method = "post";

//        window.open('about:blank', 'pop', 'width=210, height=100');
        document.getElementById("formRet").submit();

        return true;
    }

    function setValorConsulta(obj, tamanhoPadrao) {
        if (obj.value == null || obj.value == "") {
            obj.value = tamanhoPadrao;
        }
    }
//---------------------- Carregar -- fim


    function setTipoFiltro() {
        ctrcAux = '0';
        fatAux = '0';
        zebraAux = '1';
        idxOco = 0;

        var tipoFiltro = '<%=(request.getParameter("tipo") != null ? request.getParameter("tipo").trim() : "f.numero")%>';
        var campo = '<%=(request.getParameter("campo") != null ? request.getParameter("campo").trim() : "")%>';
        var ano = '<%=(request.getParameter("ano") != null ? request.getParameter("ano").trim() : Apoio.getDataAtual().split("/")[2])%>';

        if (tipoFiltro == "f.numero") {
            $("tipoFiltro1").checked = true;
            $("fatura").value = campo;
            $("ano").value = ano;
        } else if (tipoFiltro == "f.boleto_nosso_numero") {
            $("tipoFiltro2").checked = true;
            $("nossoNumero").value = campo;
        } else if (tipoFiltro == "arquivo_retorno") {
            $("tipoFiltro3").checked = true;
            $("arqRetorno").value = campo;
        }

        $("fatura").focus();
        totalSelecionado();
        validaTipoConsulta(tipoFiltro);
    }

    function fechar() {
        window.close();
    }

    //-------------------- Calculos -- inicio
    function totalSelecionado() {
        var valorTotal = 0;
        var vlPagoTotal = 0;
        var unidTotal = 0;
        var valor = 0;
        var vlPago = 0;
        if($("maxFat") != null){
            for (var i = 0; i <= $("maxFat").value; i++) {
                if ($("chk_" + i) != null && $("chk_" + i).checked) {

                    valor = parseFloat(virgulaToPonto($("valor_" + i).value));
                    vlPago = parseFloat($("vlpago_" + i).value);

                    unidTotal++;
                    vlPagoTotal += vlPago;
                    valorTotal += valor;

                    selecionado = true;
                }
            }

        $('lbQtd').innerHTML = unidTotal;
        /*
         if (selecionado){
         $('lbQtd').innerHTML = unidTotal + 1;
         }else{
         $('lbQtd').innerHTML = unidTotal ;
         }
         */
        $('lbValorTotal').innerHTML = formatoMoeda(valorTotal);
        $('lbVlPagoTotal').innerHTML = formatoMoeda(vlPagoTotal);
        }

    }
    //-------------------- Calculos -- fim

    //---------------------------------  ------------------------------

    function editarSale(id, categ) {
        if (categ == 1) {
            window.open('./frameset_conhecimento?acao=editar&id=' + id + '&ex=false', 'CTRC', 'top=0,resizable=yes');
        } else {
            window.open('./cadvenda.jsp?acao=editar&id=' + id + '&ex=false', 'NF_Servico', 'top=0,resizable=yes');
        }
    }

    function verFatura(id) {
        window.open("./fatura_cliente?acao=editar&id=" + id, "Romaneio", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }

    //---------------------------------  ------------------------------

    function replaceAll(string, token, newtoken) {
        while (string.indexOf(token) != -1) {
            string = string.replace(token, newtoken);
        }
        return string;
    }

    function marcaTodos() {
        var i = 0;

        while ($("chk_" + i) != null) {
            if ($("chk_" + i).disabled == false) {
                $("chk_" + i).checked = $("chkTodos").checked;
                totalSelecionado();
            }
            i++;
        }
    }

//    function atribuiValores(obj) {
//        var r = 0;
//        while (($(obj + '_' + r).value) != null) {
//            $(obj + '_' + r).value = $(obj).value;
//            ++r;
//        }
//    }

    function atribuiValoresPagamento(){
        var maxFat = $("maxFat").value;
        
        for (var qtdFat = 0; qtdFat <= maxFat; qtdFat++) {
            if($("dtpagamento_"+qtdFat) != null){
                $("dtpagamento_"+qtdFat).value = $("dtpagamento").value;
            }
        }        
    }
    
    function atribuiValoresConciliacao(){
        var maxFat = $("maxFat").value;
        
        for (var qtdFat = 0; qtdFat <= maxFat; qtdFat++) {
            if($("dtconciliacao_"+qtdFat) != null){
                $("dtconciliacao_"+qtdFat).value = $("dtconciliacao").value;
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

        <title>Webtrans - Baixa de contas a receber por fatura</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="setTipoFiltro()">
        <div align="center"><img src="img/banner.gif"  alt="banner">
            <br>
        </div>
        <table width="100%" height="28" align="center" class="bordaFina" >
            <tr>
                <td width="86%" height="22"><b>Baixa de contas a receber por fatura</b></td>
                <td width="14%">
                    <b>
                        <input  name="Button" type="button" class="botoes" value="Fechar" onClick="fechar()">
                    </b>
                </td>
            </tr>
        </table>
        <br>
        <table width="100%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td height="18" colspan="7"><div align="center">Filtros </div></td>
            </tr>
            <tr>
                <td width="7%" class="TextoCampos">
                    <label>
                        <input name="tipoConsulta" type="radio" id="tipoFiltro1" value="f.numero" onClick="validaTipoConsulta(this.value)">
                        Número Fatura
                    </label>
                </td>
                <td width="19%" class="CelulaZebra2">
                    <strong>
                        <input name="fatura" type="text" id="fatura" value="" size="45" 
                               onKeyPress="if (event.keyCode == 13)
                                               $('visualizar').click()" class="inputtexto" />
                        <input name="ano" type="text" id="ano" value="" size="3" maxlength="4" class="inputtexto"
                               onKeyPress="if (event.keyCode == 13)
                                               $('visualizar').click()" />
                    </strong>
                    Exemplo: 000234,000235,000236
                </td>
                <td width="7%" class="TextoCampos">
                    <input type="radio" name="tipoConsulta" id="tipoFiltro2" value="f.boleto_nosso_numero" onClick="validaTipoConsulta(this.value)" >
                    Nosso número</td>
                <td width="7%" class="CelulaZebra2">

                    <input name="nossoNumero" type="text" id="nossoNumero" style="font-size:8pt;" value="" class="inputtexto"
                           size="16" maxlength="20" onKeyPress="javascript:if (event.keyCode == 13)
                                               $('visualizar').click()">

                </td>
                <td width="7%" class="TextoCampos" >
                    <input type="radio" name="tipoConsulta" id="tipoFiltro3" value="arquivo_retorno" onClick="validaTipoConsulta(this.value)">
                    Arquivo retorno</td>
                <td width="25%" class="CelulaZebra2" >
                    <table border="0" width="100%">                            
                        <tr>
                        <form method="post" id="formRet" target="pop" enctype="multipart/form-data">
                            <td>
                                <select name="contaRet" id="contaRet" onchange="mudarConta();" class="fieldMin"  >
                                    <%
                                        //Carregando todas as contas cadastradas
                                        BeanConsultaConta conta = new BeanConsultaConta();
                                        conta.setConexao(Apoio.getUsuario(request).getConexao());
                                        conta.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                                        ResultSet rsconta = conta.getResultado();
                                        //carregando as contas num vetor
                                    while (rsconta.next()) {%>
                                    <option value="<%=rsconta.getString("idconta") + "!!" + rsconta.getString("banco")%>" <%=((request.getParameter("conta") != null && request.getParameter("conta").equals(rsconta.getString("idconta") + "!!" + rsconta.getString("banco")) ? "selected" : rsconta.getInt("idconta") == cfg.getConta_padrao_id().getIdConta() ? "selected" : ""))%>  ><%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " / " + rsconta.getString("banco")%></option>
                                    <%}%>
                                    <option value="000!!carrefour" <%=((request.getParameter("conta") != null && request.getParameter("conta").equals("000!!carrefour") ? "selected" : ""))%>  >Carrefour</option>
                                </select>
                                <input name="arqRetorno" id="arqRetorno" type="file" class="fieldMin" onKeyUp="javascript:if (event.keyCode == 13)
                                                $('visualizar').click();" size="20" />                                
                            <td>
                        </form>
            </tr>

        </table>
    </td>
</tr>
<tr>
    <td colspan="7" class="CelulaZebra2NoAlign" align="center">
        <input name="isOcoRetAll" type="checkbox" id="isOcoRetAll" value="" onClick="">
        Mostrar Todas as Ocorrências de Retorno
    </td>
</tr>
<tr>
    <td colspan="7" class="TextoCampos">
        <div align="center">
            <input name="visualizar" type="button" class="botoes" id="visualizar" value="   Visualizar [Alt+V]  " onClick="javascript:tryRequestToServer(function () {
                                        carregarFaturas();
                                    });">

        </div>
    </td>
</tr>
</table>
<form method="post" id="formBx" target="pop">
    <input type='hidden' name='maxFat' id='maxFat' value="0">
    <input type='hidden' name='maxDupl' id='maxDupl' value="0">
    <input type='hidden' name='contaBaixa' id='contaBaixa' value="0!!0">
    <input type='hidden' name='isArquivoRetorno' id='isArquivoRetorno' value="false">
    <input type='hidden' name="tipoBaixa" id="tipoBaixa" value="">
    <table width="100%" border="0" class="bordaFina">
        <tr>
            <td>
                <table width='100%' border='0' class='bordaFina'>
                    <tbody>
                        <tr align="center" class='tabela'>
                            <td width='2%'><input type="checkbox" id="chkTodos" name="chkTodos" value="chkTodos" onClick="javascript:marcaTodos();" checked></td>
                            <td width='2%'>&nbsp;</td>
                            <td width='5%'>Fat.</td>
                            <td width='5%'>St. da Fat.</td>
                            <td width='6%'>Emissão</td>
                            <td width='5%'>Dt Venc</td>
                            <td width='18%'>Cliente</td>
                            <td width='7%'>Valor</td>
                            <td width='6%'>Vlr. Pago</td>
                            <td width='9%'>Dt Pgto</td>
                            <td width='10%'>Dt Conc</td>
                            <td width='8%'>Nosso Nº</td>
                            <td width='15%'>St.</td>
                        </tr>
                        <tr class="CelulaZebra2">
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td> 
                            <td>
                                <input name="dtpagamento" id="dtpagamento" style="font-size:8pt;"
                                       value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin"  maxlength="12" align="Right"
                                       onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                                <img src="img/add.gif" border="0" title="Atribui a data do pagamento as faturas" class="imagemLink" style="vertical-align:middle;"
                                     onClick="javascript:atribuiValoresPagamento();">
                            </td>
                            <td>
                                <input name="dtconciliacao" id="dtconciliacao" style="font-size:8pt;"
                                       value="<%=Apoio.getDataAtual()%>" type="text" size="9" class="fieldMin"  maxlength="12" align="Right"
                                       onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                                <img src="img/add.gif" border="0" title="Atribui a data da concilia&ccedil;&atilde;o as faturas abaixo" class="imagemLink" style="vertical-align:middle;"
                                     onClick="javascript:atribuiValoresConciliacao();">
                            </td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>                                                                       
                        </tr>
                    </tbody>
                    <tbody id="tbFatura">
                    </tbody>
                    <tr class="CelulaZebra2">
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td><div align="right"><b>Total Selecionado:</b></div></td>
                        <td></td>
                        <td><div align="right"><label id="lbValorTotal" name="lbValorTotal">0.00</label></div></td>
                        <td><div align="right"><label id="lbVlPagoTotal" name="lbVlPagoTotal">0.00</label></div></td>
                        <td colspan="2"><div align="center"><label id="lbQtd" name="lbQtd">0</label>&nbsp;Fatura(s) selecionada(s)</div></td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>

                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <br>

    <table width="100%" border="0" class="bordaFina" align="center" >
        <tr>
            <td width="18%" class="TextoCampos"><div id="divConta">Conta para baixa:</div></td>
            <td width="12%" class="CelulaZebra2">
                <select name="conta" id="conta" class="fieldMin">
                    <%
                        //Carregando todas as contas cadastradas
                        conta = new BeanConsultaConta();
                        conta.setConexao(Apoio.getUsuario(request).getConexao());
                        conta.mostraContas((nivelCtrcFilial >= 2 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                        ResultSet rsconta1 = conta.getResultado();
                        //carregando as contas num vetor
                                while (rsconta1.next()) {%>
                    <option value="<%=rsconta1.getString("idconta") + "!!" + rsconta1.getString("banco")%>" <%=((request.getParameter("conta") != null && request.getParameter("conta").equals(rsconta1.getString("idconta") + "!!" + rsconta1.getString("banco")) ? "selected" : rsconta1.getInt("idconta") == cfg.getConta_padrao_id().getIdConta() ? "selected" : ""))%>  ><%=rsconta1.getString("numero") + "-" + rsconta1.getString("digito_conta") + " / " + rsconta1.getString("banco")%></option>
                    <%}%>
                </select>
            </td>
            <td  width="36%" class="TextoCampos"><div align="center">
                    <input name="chkconciliado" type="checkbox" id="chkconciliado" <%=(request.getParameter("chkconciliado") == null || request.getParameter("chkconciliado").equals("false") ? "" : "checked")%>>
                    Ao baixar, conciliar o movimento bancário.</div></td>
            <td width="16%" class="TextoCampos">

                <div id="divDtConciliacao">
                    <!--Data da concilia&ccedil;&atilde;o:-->
                </div>
            </td>
            <td width="18%" class="CelulaZebra2">
                <!--
                <font size="1">
                    
                <input name="dtconciliacao" id="dtconciliacao" class="fieldDate" value="<%=(request.getParameter("dtconciliacao") == null ? Apoio.getDataAtual() : request.getParameter("dtconciliacao"))%>" type="text" size="9" style="font-size:8pt;" maxlength="12"
                           onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                </font>
                -->
            </td>                

        </tr>
        <tr>
            <td colspan="5" class="TextoCampos"> <div align="center">
                    <% if (nivelUser >= 2) {%>
                    <input name="baixar" type="button" class="botoes" id="baixar" value="Baixar [Alt+B]" onClick="javascript:tryRequestToServer(function () {
                                        baixarfatura();
                                    });">
                    <%}%>
                </div></td>
        </tr>
    </table>
</form>
</body>
</html>
<% if (acao.equals("montarRetorno")) {%>
<script language="JavaScript"  type="text/javascript">

    var retorno = "<%=request.getAttribute("importRelatorio").toString().replaceAll(" \\\"", "\\\\\"")%>";
    //subistitui \" por \\" desta forma quando o mesmo converter não vai solicitar ; antes da hora
    if (retorno != null) {
        var retornoHtml = replaceAll(retorno.split("!!!")[0], ",!", ";");
        var a = $("tbFatura");
        a.insert(retornoHtml);
        $("maxFat").value = parseFloat(retorno.split("!!!")[1]);
        $("isArquivoRetorno").value = "true";

        totalSelecionado();

        espereEnviar("", false);
        validaTipoConsulta("arquivo_retorno");

        //$("dtconciliacao").style.display="none";
        //$("divDtConciliacao").style.display="none";
    }

</script>
<%
                            request.removeAttribute("importRelatorio");
                        }%>
