<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="org.omg.PortableInterceptor.SYSTEM_EXCEPTION"%>
<%@page import="venda.BeanVenda"%>
<%@page import="conhecimento.BeanConhecimento"%>
<%@page import="conhecimento.orcamento.BeanOrcamento"%>
<%@page import="venda.BeanCadVenda"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="nucleo.Apoio,
         nucleo.impressora.*,
         java.sql.ResultSet,
         java.text.SimpleDateFormat, 
         java.util.Date,
         java.util.Vector" %>
<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
    int nivelUser = (Apoio.getUsuario(request) != null ? 4 : 0);
    //nivel de usuario para lancamento de notas de servico no cadastro
    int nvUser = Apoio.getUsuario(request).getAcesso("cadvenda");
    int nivelUserToFilial = (nivelUser > 0 ? 4 : 0);
    String acao = (nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
    int idFilialVenda = Integer.parseInt(request.getParameter("idFilialVenda") != null ? request.getParameter("idFilialVenda") : "0");
    boolean utilizacaoNFSeG2ka = Apoio.getUsuario(request).getFilial().isUtilizacaoNFSeG2ka();
    char stUtilizacaoNfse = Apoio.getUsuario(request).getFilial().getStUtilizacaoNfse();
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
//Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String filial = "";
    String idCliente = "0";
    String cliente = "";
    String isNaoImpresso = "false";
    String operadorConsulta = "";
    String limiteResultados = "";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;

    BeanVenda beanVenda = new BeanVenda();



    boolean carregaorc = !(acao.equals("incluir") || acao.equals("atualizar") || acao.equals("iniciar") || acao.equals("excluir"));
    if (acao.equals("iniciar")) {
        carregaorc = true;
    }

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaVenda")) {
                consulta = cookies[i];
            } else if (cookies[i].getName().equals("operadorConsultaVenda")) {
                operador = cookies[i];
            } else if (cookies[i].getName().equals("limiteConsultaVenda")) {
                limite = cookies[i];
            }
            if (consulta != null && operador != null && limite != null) { //se já encontrou os cookies então saia
                break;
            }
        }
        if (consulta == null) {//se não achou o cookieu então inclua
            consulta = new Cookie("consultaVenda", "");
        }
        if (operador == null) {//se não achou o cookieu então inclua
            operador = new Cookie("operadorConsultaVenda", "");
        }
        if (limite == null) {//se não achou o cookieu então inclua
            limite = new Cookie("limiteConsultaVenda", "");
        }
        consulta.setMaxAge(60 * 60 * 24 * 90);
        operador.setMaxAge(60 * 60 * 24 * 90);
        limite.setMaxAge(60 * 60 * 24 * 90);

        String valor = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 1 ? "" : consulta.getValue().split("!!")[0]);
        String campo = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 2 ? "" : consulta.getValue().split("!!")[1]);
        String dt1 = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 3 ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
        String dt2 = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 4 ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
        String fl = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 5 ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : consulta.getValue().split("!!")[4]);
        String cli = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 6 ? "" : consulta.getValue().split("!!")[5]);
        String idCli = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 7 ? "0" : consulta.getValue().split("!!")[6]);
        String isNaoImp = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 8 ? "false" : consulta.getValue().split("!!")[7]);
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        idCliente = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : (idCli));
        cliente = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : (cli));
        isNaoImpresso = (request.getParameter("isNaoImpresso") != null ? request.getParameter("isNaoImpresso") : (isNaoImp));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "dtemissao" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        
        if(campoConsulta.trim().equals("") || campoConsulta.trim().equals("dtemissao")  || campoConsulta.trim().equals("s.emissao_em")){
            operadorConsulta = "10";
            campoConsulta = "dtemissao"; // Caso seja uma String Vazia ele quebra a tela no Google Chrome.
        }
        
        
        consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" + filial + "!!" + cliente + "!!" + idCliente + "!!" + isNaoImpresso);
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);

        if (acao.equals("exportar")) {

            //marcando a coleta como impressa
            BeanCadVenda cadVenda = new BeanCadVenda();


            SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
            String condicao = "";
            String usuario = Apoio.getUsuario(request).getNome();
            String modelo = request.getParameter("modelo");

            //Verificando qual campo filtrar


            //Exportando
            java.util.Map param = new java.util.HashMap(3);
            param.put("IDNOTA", request.getParameter("idNota"));
            param.put("CONDICAO", condicao);
            param.put("USUARIO", usuario);
            request.setAttribute("map", param);
             if (modelo.indexOf("personalizado") > -1) {
                   String relatorio =  modelo;
                   request.setAttribute("map", param);
                   request.setAttribute("rel",relatorio);
                }else{
                   request.setAttribute("map", param);
                   request.setAttribute("rel", "documentonotaservicomod" + modelo);
                }

            RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
            dispacher.forward(request, response);
        } else if (acao.equals("desativarNotaFiscalDeServico")) {
            BeanCadVenda cadVenda = null;
            String erroDesativarGWi = null;
            
            int idNota = 0;
            
            try {
                cadVenda = new BeanCadVenda();
                                
                idNota = Apoio.parseInt(request.getParameter("idNota"));
                
                erroDesativarGWi = cadVenda.desativarNotaFiscalDeServico(idNota);
                
                if (!erroDesativarGWi.isEmpty()) {
                    response.getWriter().append(erroDesativarGWi);
                } else {
                    nucleo.Apoio.redirecionaPop(response.getWriter(), "./consulta_venda.jsp?acao=iniciar");
                }
                
                response.getWriter().close();
            } finally {
                cadVenda = null;
                erroDesativarGWi = null;
            }
        }
    } else {
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta") : "dtemissao");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        idCliente = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0");
        cliente = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "");
        isNaoImpresso = (request.getParameter("isNaoImpresso") != null ? request.getParameter("isNaoImpresso") : "false");
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador") : "1");
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados") : "10");
          if(campoConsulta.trim().equals("") || campoConsulta.equals("dtemissao") || campoConsulta.equals("s.emissao_em")){
              operadorConsulta = "10";
            campoConsulta = "dtemissao"; // Caso seja uma String Vazia ele quebra a tela no Google Chrome.
        }
        
    }
//Finalizando Cookie
    
    BeanConfiguracao configuracaoVenda = new BeanConfiguracao();
    configuracaoVenda.setConexao(Apoio.getUsuario(request).getConexao());
    
    configuracaoVenda.CarregaConfig();

%>
<jsp:useBean id="consVenda" class="venda.BeanConsultaVenda" />

<jsp:setProperty  name="consVenda" property="paginaResultados"  />
<%
    consVenda.setDtEmissao1(Apoio.paraDate(dataInicial));
    consVenda.setDtEmissao2(Apoio.paraDate(dataFinal));
    consVenda.setLimiteResultados(Apoio.parseInt(limiteResultados));
    consVenda.setOperador(Apoio.parseInt(operadorConsulta));
    consVenda.setValorDaConsulta(valorConsulta);
    consVenda.setCampoDeConsulta(campoConsulta);
    consVenda.setIdFilialVenda(Apoio.parseInt(filial));
    consVenda.setIdCliente(Apoio.parseInt(idCliente));
    consVenda.setNaoImpresso(Apoio.parseBoolean(isNaoImpresso));
%>


<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    
    function localizaRemetenteCodigo(campo, valor) {

        //objeto funcao usado na requisicao Ajax(uma espécie de evento)
        function e(transport) {
            var resp = transport.responseText;
            espereEnviar("", false);
            //se deu algum erro na requisicao...
            if (resp == 'null') {
                alert('Erro ao localizar cliente.');
                return false;
            } else if (resp == 'INA') {
                $('idremetente').value = '0';
                $('rem_codigo').value = '';
                $('rem_rzs').value = '';
                $('rem_cidade').value = '';
                $('rem_uf').value = '';
                $('rem_cnpj').value = '';
                $('rem_email').value = '';
                $('remtabelaproduto').value = 'f';
                alert('Cliente inativo.');
                return false;
            } else if (resp == '') {
                $('idremetente').value = '0';
                $('rem_codigo').value = '';
                $('rem_rzs').value = '';
                $('rem_cidade').value = '';
                $('rem_uf').value = '';
                $('rem_cnpj').value = '';
                $('rem_email').value = '';
                $('remtabelaproduto').value = 'f';

                if (confirm("Cliente não encontrado, deseja cadastrá-lo agora?")) {
                    window.open('./cadcliente?acao=iniciar', 'Cliente', 'top=0,left=0,height=700,width=900,resizable=yes,status=1,scrollbars=1');
                }
                return false;
            } else {
                var cliControl = eval('(' + resp + ')');

                $('idremetente').value = cliControl.idcliente;
                $('rem_codigo').value = cliControl.idcliente;
                $('rem_rzs').value = cliControl.razao;
                $('rem_cnpj').value = cliControl.cnpj;

                var filial = $("idfilial").value;

                if (cliControl.tipo_origem_frete == "f" && $("cidadeFilial_" + filial) != null) {
                    var idCidadeFl = ($("cidadeFilial_" + filial).value).split("!!")[0];
                    var cidadeFl = ($("cidadeFilial_" + filial).value).split("!!")[1];
                    var ufFl = ($("cidadeFilial_" + filial).value).split("!!")[2];

                    $("cid_id_origem").value = idCidadeFl;
                    $('cid_nome_origem').value = cidadeFl;
                    $('cid_uf_origem').value = ufFl;

                } else {

                    $("cid_id_origem").value = cliControl.idcidade;
                    $('cid_nome_origem').value = cliControl.cidade;
                    $('cid_uf_origem').value = cliControl.uf;
                }

                $("endereco_col").value = cliControl.endereco_col;
                $("bairro_col").value = cliControl.bairro_col;
                $('cid_nome_coleta').value = cliControl.cidade_col;
                $('cid_uf_coleta').value = cliControl.uf_col;
                $("cid_id_coleta").value = cliControl.idcidade_col;
                $("idvendedor").value = cliControl.idvendedor;
                $("ven_rzs").value = cliControl.vendedor;

                $("tipofrete").value = cliControl.tipotaxa;
                $("rem_email").value = cliControl.email;
                $('remtabelaproduto').value = cliControl.is_tabela_apenas_produto;
                $('remtipofpag').value = cliControl.tipofpag;
                $('rem_pgt').value = cliControl.pgt;

                getTipoProdutos();
                getCondicaoPagto();
            }
        }//funcao e()

        if (valor != '') {
            espereEnviar("", true);
            tryRequestToServer(function() {
                new Ajax.Request("./ClienteControlador?acao=localizaClienteCodigo&valor=" + valor + "&idfilial=0&campo=" + campo, {method: 'post', onSuccess: e, onError: e});
            });
        }
    }

    function launchPopupLocate(url, idname) {
        var wPop = screen.width * 0.80;
        var hPop = screen.height * 0.70;
        var cf = 'top=' + (((screen.height - hPop) / 2) - 15) + ',left=' + ((screen.width - wPop) / 2) +
                ',height=' + hPop + ',width=' + wPop + ',resizable=yes,status=1,scrollbars=1';
        var popup = window.open(url, idname, cf);
        return popup;
//alertando a janela do popup
//	popup.focus();
    }
    function consultar(acao) {
        if ($("campoDeConsulta").value == "dtemissao" && !(validaData($("dtemissao1").value) && validaData(getObj("dtemissao2").value)))
        {
            alert("Datas Inválidas para Consulta. O Formato Correto é: \"dd/mm/aaaa\"");
            return null;
        }

        location.replace("./consulta_venda.jsp?acao=" + acao + "&paginaResultados=" + (acao == 'proxima' ? <%=consVenda.getPaginaResultados() + 1%> : (acao == 'anterior' ?<%=consVenda.getPaginaResultados() - 1%> : 1)) + "&isNaoImpresso=" + $('chkNaoImpressas').checked + "&" +
                concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,filialId,idconsignatario,con_rzs"));
    }

    function excluir(id) {
        function ev(resp, st) {
            if (st == 200)
                if (resp.split("<=>")[1] != "")
                    alert(resp.split("<=>")[1]);
                else
                    consultar('consultar');
            else
                alert("Status " + st + "\n\nNão Conseguiu Realizar o Acesso ao Servidor!");
        }

        if (confirm("Deseja Mesmo Excluir esta Venda?"))
            requisitaAjax("./cadvenda.jsp?acao=excluir&id=" + id, ev);
    }


    function aoCarregar() {
        $("valorDaConsulta").focus();
        $("campoDeConsulta").value = "<%=campoConsulta%>";
        $("operador").value = "<%=operadorConsulta%>";
        $("limiteResultados").value = "<%=limiteResultados%>";
        $("valorDaConsulta").value = "<%=valorConsulta%>";
        $("dtemissao1").value = "<%=dataInicial%>";
        $("dtemissao2").value = "<%=dataFinal%>";
        $("filialId").value = "<%=filial%>";
        $("idconsignatario").value = "<%=idCliente%>";
       $("con_rzs").value = "<%= cliente %>";

     if ($("campoDeConsulta").value == '' || $("campoDeConsulta").value == 'dtemissao') {
            habilitaConsultaDePeriodo(true);
       }
   }
   
    function editar(id) {
        location.replace("./cadvenda.jsp?acao=editar&id=" + id);
    }

    function habilitaConsultaDePeriodo(opcao) {
        $("valorDaConsulta").focus();
        getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
        getObj("operador").style.display = (opcao ? "none" : "");
        getObj("div1").style.display = (opcao ? "" : "none");
        document.getElementById("div2").style.display = (opcao ? "" : "none");
    }
    
    function printMatricideVenda(id) {
        if ($('driverImpressora').value == '') {
            alert("Escolha o Driver de Impressão Corretamente!");
            return null;
        }
        if ($('impresso' + id).value == 'true' && !confirm("Essa Nota Já Foi Impressa, Deseja Imprimi-la Novamente?")) {
            return null
        }
        var url = "./matricidevenda.ctrc?id=" + id + "&" + concatFieldValue("driverImpressora,caminho_impressora");
        tryRequestToServer(function() {
            document.location.href = url;
        });
    }

    function popitup(url) {
        if (navigator.userAgent.indexOf('Chrome/') > 0) {
            if (window.NFSe) {
                window.NFSe.close();
                window.NFSe = null;
            }
        }
        window.NFSe = window.open(url, 'NFSe', '<height=600,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1');
        if (window.focus) {
            window.NFSe.focus()
        }
        return false;
    }

    function abrirNFSe() {
        popitup("./NFSeControlador?acao=listar&statusCte=P");
    }
    
    function abrirNFSeG2ka(){
        popitup("./NFSeG2kaControlador?acao=listar&statusCte=P&idFilial="+$("filialId").value+"&idconsignatario="+$("idconsignatario").value+"&con_rzs="+$("con_rzs").value);
    }
    
    function popNota(id) {
        if (id == null)
            return null;
        launchPDF('./consulta_venda.jsp?acao=exportar&idNota=' + id + "&modelo=" + $('modelo').value);

    }


    function desativarNotaFiscalDeServico(idNota) {   
        if (confirm("Deseja desativar essa Nota Fiscal de Serviço do GW-i?")) {
            window.open("./consulta_venda.jsp?acao=desativarNotaFiscalDeServico&idNota=" + idNota, "pop", "width=210, height=100");
        }
    }
</script>
<%@page import="filial.BeanFilial"%>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js"></script>
        <script language="javascript" type="text/javascript" src="script/builder.js"></script>
        <script language="javascript" src="script/prototype.js" type=""></script>
        <script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <script language="JavaScript" src="script/aliquotaIcmsCtrc.js" type="text/javascript"></script>
        <script language="javascript" src="script/tabelaFrete.js" type=""></script>

        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Venda</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="aoCarregar()">
        <img src="img/banner.gif">
        <br>
        <input type="hidden" id="idconsignatario" name="idconsignatario" value="0">
        <table width="85%" align="center" class="bordaFina" >
            <tr>
                <td width="50%" align="left"><b>Consulta de Venda</b></td>
                <% if (nivelUser >= 3) {%>
                <td width="15%">
                    <% if (utilizacaoNFSeG2ka) {%>
                        <input type="button" onclick="javascript:tryRequestToServer(function(){abrirNFSeG2ka();});" value="Visualizar NFS-e(s) G2KA" class="inputBotao">
                    <%}%>
                    <% if (!utilizacaoNFSeG2ka && stUtilizacaoNfse != 'S') {%>
                        <input type="button" onClick="javascript:tryRequestToServer(function() {abrirNFSe();});" value="Visualizar NFS-e(s)" class="inputBotao">
                    <%}%>
                    <input name="novo" type="button" class="botoes" id="novo" onClick="javascript:tryRequestToServer(function() {document.location.replace('./cadvenda.jsp?acao=iniciar');});" value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="85%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td>
                    <select name="campoDeConsulta" id="campoDeConsulta" style="width: 130px;" onChange="javascript:habilitaConsultaDePeriodo(this.value == 'dtemissao');" class="inputtexto">
                        <option value="s.numero">N&uacute;mero</option>
                        <option value="s.numero_rps">N&uacute;mero RPS (NFS-e)</option>
                        <option value="s.pedido_cliente">Pedido do Cliente</option>
                        <option value="nf.numero">Nota Fiscal do Cliente (Distribuição Local)</option>
                        <option value="dtemissao">Data de emiss&atilde;o</option>
                    </select>    
                </td>
                <td>
                    <select name="operador" id="operador" class="inputtexto" style="width: 190px;">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (Vários separados por vírgula)</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De:
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" 
                               value="<%=fmt.format((consVenda.getCampoDeConsulta().equals("dtemissao") ? consVenda.getDtEmissao1() : new Date()))%>"
                               onblur="alertInvalidDate(this)" class="fieldDate" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </div>	
                </td>
                <td width="190">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">Para:
                        <input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" class="fieldDate"
                               value="<%=fmt.format((consVenda.getCampoDeConsulta().equals("dtemissao") ? consVenda.getDtEmissao2() : new Date()))%>"
                               onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" value="<%=consVenda.getValorDaConsulta()%>" size="25" onKeyUp="javascript:if (event.keyCode == 13)
            $('pesquisar').click();" class="inputtexto">	
                </td>
                <td width="150">
                    <div align="center">
                        <select name="filialId" id="filialId" class="inputtexto">
                            <%BeanFilial fl = new BeanFilial();
                                ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());%>
                            <%if (nivelUserToFilial > 0) {%>
                            <option value="0">TODAS AS FILIAIS</option>
                            <%}
                                while (rsFl.next()) {
                                    if (nivelUserToFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                            <option value="<%=rsFl.getString("idfilial")%>" 
                                    <%=(filial.equals(rsFl.getString("idfilial")) ? "selected" : "")%>>Apenas <%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                            <%}%>
                        </select>
                    </div>
                </td>
                <td rowspan="3">
                    <div align="center">
                        Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="inputtexto">
                            <option value="10" sele0cted>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                            <option value="100">100 resultados</option>
                            <option value="200">200 resultados</option>
                            <option value="1000">1000 resultados</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td  height="20">
                    <div align="right">
                        Apenas o Cliente:
                    </div>
                </td>
                <td colspan="2">
                    <div align="left">
                        <input name="con_rzs" type="text" id="con_rzs" size="35" class="inputReadOnly" readonly>
                        <input  name="localiza_cliente" type="button" class="botoes" id="localiza_cliente" 
                                onClick="javascript:window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Cliente',
                                    'top=80,left=150,height=500,width=700,resizable=yes,status=3,scrollbars=1');" value="...">
                        <strong>
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('con_rzs').value = '';javascript:getObj('idconsignatario').value = '';"></strong>
                    </div>
                </td>
                <td rowspan="2">
                    <div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:tryRequestToServer(function() {
            consultar('consultar');
        });">
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td  height="20" colspan="2">
                    <div align="center">
                        <input type="checkbox" name="chkNaoImpressas" id="chkNaoImpressas" <%=isNaoImpresso.equals("true") ? "checked" : ""%>>
                        Mostrar Apenas as Notas N&atilde;o Impressas
                    </div>
                </td>
                <td  height="20" >
                    <div align="center">
                        <span>

                        </span>
                    </div>
                </td>
            </tr>
        </table>
        <br>
        <table width="85%" border="0" class="bordaFina" align="center">
            <tr class="tabela">
                <td width="1%">&nbsp;</td>
                <td width="1%">&nbsp;</td>
                <td width="1%">&nbsp;</td>
                <td width="8%" align="center">Numero RPS (NFS-e)</td>
                <td width="6%" align="center">Emiss&atilde;o</td>
                <td width="5%" align="center">Valor</td>
                <td width="20%" align="center">Cliente</td>
                <td width="10%" align="center">Nota Fiscal (Dist. Locais)</td>
                <td width="8%" align="center">Servi&ccedil;o</td>
                <td width="6%" align="center">Filial</td>
                <td width="2%">&nbsp;</td>
            </tr>
            <%int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;
                String cor = "";
                if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                    consVenda.setConexao(Apoio.getConnectionFromUser(request));
                    if (consVenda.Consultar()) {
                        ResultSet r = consVenda.getResultado();
                        while (r.next()) {
                            cor = (r.getBoolean("is_cancelado") ? "#CC0000" : "");
            %>           <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td>
                    <div align="center">
                        <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                             onClick="javascript:tryRequestToServer(function() {
            popNota('<%=r.getString("id")%>');
        });">
                    </div>
                </td>
                <td width="20">
                    <img src="img/ctrc.gif" class="imagemLink" title="Imprimir notas selecionadas" width="19" height="19" border="0" onClick="printMatricideVenda('<%=r.getInt("id")%>')">
                </td>
                <td>
                    <% if (r.getInt("created_by") == 8888) { %>
                        <% if (r.getBoolean("is_desativado_gwi")) {%>
                            <img src="img/gwi-desativado.png" width="30" height="30" style="margin-right: 4px; margin-left: 4px;" title="Nota Fiscal de Serviço desativada no GW-i"/>
                        <% } else { %>
                            <img class="imagemLink" src="img/gwi-ativo.png" width="30" height="30" style="margin-right: 4px; margin-left: 4px;" title="Desativar Nota Fiscal de Serviço no GW-i"
                                 onclick="javascript:tryRequestToServer(function() { 
                                    desativarNotaFiscalDeServico('<%= r.getString("id") %>');
                                });"/>
                        <% } %>
                    <% } %>
                </td>
                <td>
                    <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function() {
            editar(<%=r.getInt("id")%>);
        });">
                        <%=r.getString("numero") + "/" + r.getString("serie")%>
                    </div>
                    <input name="impresso<%=r.getInt("id")%>" type="hidden" value="<%=r.getBoolean("is_impresso")%>" id="impresso<%=r.getInt("id")%>">
                </td>
                <td align="center"><font color=<%=cor%>><%=fmt.format(r.getDate("emissao_em"))%></font></td>
                <td><div align="right"><font color=<%=cor%>><%=r.getString("total")%></font></div></td>
                <td><font color=<%=cor%>><%=r.getString("consignatario_razaosocial")%></font></td>
                <td><font color=<%=cor%>><%=r.getString("notas_fiscais")%></font></td>
                <td><font color=<%=cor%>><%=r.getString("servico")%></font></td>
                <td><font color=<%=cor%>><%=r.getString("filial_abreviatura")%></font></td>
                <td>
                    <%    if (nvUser == 4 && true && //podeexcluir 
                                !(!r.getString("filial_abreviatura").equals(Apoio.getUsuario(request).getFilial().getAbreviatura()) && nivelUserToFilial < 4)) {
                    %>        <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function() {
            excluir(<%=r.getString("id")%>);
        });">
                    <%    }
                    %>               
                </td>
            </tr>
            <%           if (r.isLast()) {
                                linhatotal = r.getInt("qtde_linhas");
                            }
                            linha++;
                        }

                        int limit = consVenda.getLimiteResultados();
                        qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                    }
                }
            %> 

        </table>
        <br>
        <table width="85%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="20%" height="22">
            <center>
                Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
            </center>
        </td>
        <td width="15%" align="center">P&aacute;ginas: <b><%=(qtde_pag == 0 ? 0 : consVenda.getPaginaResultados())%> / <%=qtde_pag%></b></td>
        <td width="10%" align="left">
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function() {
            consultar('anterior');
        });">            
       <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function() {consultar('proxima');});">
            <%if (consVenda.getPaginaResultados() < qtde_pag) {%><%}%>
        </td>
        <td width="7%">
            <div align="right">Driver:</div>
        </td>
        <td width="13%">
            <select name="driverImpressora" id="driverImpressora" class="inputtexto">
                <option value="">&nbsp;</option>
                <% Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "ven.txt");
                    for (int i = 0; i < drivers.size(); ++i) {
                        String driv = (String) drivers.get(i);
                        driv = driv.substring(0, driv.lastIndexOf("."));
                %>
                <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                <%}%>
            </select>
        </td>
        <td width="9%" class="celula"><div align="right">Impressora:</div></td>
        <td width="16%">
            <span class="CelulaZebra2">
                <select name="caminho_impressora" id="caminho_impressora" class="inputtexto" style="width: 100px;">
                    <option value="">&nbsp;&nbsp;</option>
                    <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                        impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                        if (impressoras.Consultar()) {
                            ResultSet rs = impressoras.getResultado();
                                    while (rs.next()) {%>
                    <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora()) ? "selected" : "")%>><%=rs.getString("descricao")%></option>
                    <%}%>
                    <%}%>
                </select>
            </span>
        </td>
        <td width="13%">
            <select name="modelo" id="modelo" class="inputtexto">
                <option value="1" <%=configuracaoVenda.getRelDefaultConsultaVenda().equals("1") ? "selected" : "" %>selected>Modelo 1</option>
                <option value="2" <%=configuracaoVenda.getRelDefaultConsultaVenda().equals("2") ? "selected" : "" %>>Modelo 2</option>
                <%for (String rel : Apoio.listNotasServico(request)) {%> 
                        <option value="nota_servico_personalizado_<%=rel%>" <%=(configuracaoVenda.getRelDefaultConsultaVenda().startsWith("nota_servico_personalizado_" + rel) ? "selected" : "")%>>Modelo <%=rel.toUpperCase() %></option>
                    <%}%>
            </select>
        </td>
    </tr>
</table>
</body>
</html>

