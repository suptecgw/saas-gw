<%@page import="nucleo.BeanConfiguracao"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="motorista.BeanConsultaMotorista"%>
<%@page import="motorista.BeanCadMotorista"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="nucleo.Apoio"%>

<script language="JavaScript" src="script/<%=Apoio.noCacheScript("prototype_1_7_2.js")%>" type="text/javascript"></script>


<% //Versao da MSA: 2.0 ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
// privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
        int nivelUser = (Apoio.getUsuario(request) != null
                ? Apoio.getUsuario(request).getAcesso("cadmotorista") : 0);     
        
        int nivelFrotaPropria = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadMotoristaFrotaPropria") : 0);        
//testando se a sessao é válida e se o usuário tem acesso
        if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
            response.sendError(response.SC_FORBIDDEN);
        }
//fim da MSA
        BeanConfiguracao cfg = new BeanConfiguracao();
        cfg.setConexao(Apoio.getUsuario(request).getConexao());
        cfg.CarregaConfig();

        String campoConsulta = "";
        String valorConsulta = "";
        String operadorConsulta = "";
        String limiteResultados = "";
        Cookie consulta = null;
        Cookie operador = null;
        Cookie limite = null;

        Cookie cookies[] = request.getCookies();
        if (cookies != null) {
            for (int i = 0; i < cookies.length; i++) {
                if (cookies[i].getName().equals("consultaMotorista")) {
                    consulta = cookies[i];
                } else if (cookies[i].getName().equals("operadorConsulta")) {
                    operador = cookies[i];
                } else if (cookies[i].getName().equals("limiteConsulta")) {
                    limite = cookies[i];
                }
                if (consulta != null && operador != null && limite != null) { //se já encontrou os cookies então saia
                    break;
                }
            }
            if (consulta == null) {//se não achou o cookieu então inclua
                consulta = new Cookie("consultaMotorista", "");
            }
            if (operador == null) {//se não achou o cookieu então inclua
                operador = new Cookie("operadorConsulta", "");
            }
            if (limite == null) {//se não achou o cookieu então inclua
                limite = new Cookie("limiteConsulta", "");
            }
            consulta.setMaxAge(60 * 60 * 24 * 90);
            operador.setMaxAge(60 * 60 * 24 * 90);
            limite.setMaxAge(60 * 60 * 24 * 90);

            String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
            String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
            valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
            campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                    ? request.getParameter("campo")
                    : (campo.equals("") ? "nome" : campo));
            operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                    ? request.getParameter("ope")
                    : (operador.getValue().equals("") ? "1" : operador.getValue()));
            limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                    ? request.getParameter("limite")
                    : (limite.getValue().equals("") ? "10" : limite.getValue()));
            consulta.setValue(valorConsulta + "!!" + campoConsulta);
            operador.setValue(operadorConsulta);
            limite.setValue(limiteResultados);
            response.addCookie(consulta);
            response.addCookie(operador);
            response.addCookie(limite);
        } else {
            campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("") ? request.getParameter("campo") : "nome");
            valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("") ? request.getParameter("valor") : "");
            operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("") ? request.getParameter("ope") : "1");
            limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("") ? request.getParameter("limite") : "10");
        }

%>

<jsp:useBean id="bMotor" class="motorista.BeanConsultaMotorista" />
<%  // DECLARANDO e inicializando as variaveis usadas no JSP
        //BeanConsultaMotorista bMotor = null;

        String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
        acao = (acao == null ? "" : acao);
//variavel responsavel pela paginacao. Pega o ultimo titulo
        String ultimotitulo = request.getParameter("ultimo");
        String pag = (request.getParameter("pag") != null ? request.getParameter("pag") : "1");
        
//Logo quando entra na página, carrega variáveis com os dados default para pesquisa
        if (acao.equals("iniciar")) {
            acao = "consultar";
            pag = "1";
        }

//Se clicar em pesquisar ou clicar em proxima página
        if ((acao.equals("consultar")) || (acao.equals("proxima")) || (acao.equals("anterior"))) {   //instanciando o bean
            bMotor = new BeanConsultaMotorista();
            bMotor.setConexao(Apoio.getUsuario(request).getConexao());
            bMotor.setCampoDeConsulta(campoConsulta);
            bMotor.setOperador(Apoio.parseInt(operadorConsulta));
            bMotor.setValorDaConsulta(valorConsulta);
            bMotor.setLimiteResultados(Apoio.parseInt(limiteResultados));
            bMotor.setPaginaResultados(Apoio.parseInt(pag));
            bMotor.setNivelFrotaPropria(nivelFrotaPropria);
        // a chamada do método Consultar() está lá em mbaixo
        }

//Se clicar em excluir
        if (acao.equals("excluir") && request.getParameter("id") != null) {
            BeanCadMotorista cadMotor = new BeanCadMotorista();
            cadMotor.setConexao(Apoio.getUsuario(request).getConexao());
            cadMotor.setExecutor(Apoio.getUsuario(request));
            cadMotor.setIdmotorista(Apoio.parseInt(request.getParameter("id")));
%>
<html>
    <head>
<script language="javascript"> <%
    if (!cadMotor.Deleta()) {
           %>alert("Erro ao tentar excluir!");<%    }
     %>location.replace("./consultamotorista?acao=iniciar");
</script>
<%
        }
%>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" >
    var paginaAtual = 0;
    var qtde_pag = 1;
    var linhatotal = 0;

    //Chamar o cadastro de motorista
    function cadmotorista(){
        tryRequestToServer(function(){
            location.replace("./cadmotorista?acao=iniciar");
        });        
    }

    function seleciona_campos(){
   <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
        if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null)) {%>
                $("valor_consulta").focus();
                valor_consulta.value = "<%=valorConsulta%>";
                campo_consulta.value = "<%=campoConsulta%>";
                operador_consulta.value = "<%=operadorConsulta%>";
                limite.value = "<%=limiteResultados%>";
                if(paginaAtual <= 1){
                    desabilitar($("voltar"));
                }
                if(paginaAtual == qtde_pag){
                    desabilitar($("avancar"));
                }
                if(linhatotal <= 10 && qtde_pag <=0){
                    desabilitar($("voltar"));
                    desabilitar($("avancar"));
                }
    <%}%>
        }

    function consulta(campo, operador, valor, limite){
            if (campo == "cpf") valor = unformatNumber(valor);
            tryRequestToServer(function(){
                location.replace("./consultamotorista?campo="+campo+"&ope="+operador+"&valor="+valor+"&limite="+limite+"&pag=1&acao=consultar");
            });
    }

    function editarcliente(idmotorista,podeexcluir){
            //Recebe com oparâmetros o código do cliente e se poderá ser excluído ou não
            location.replace("./cadmotorista?acao=editar&id="+idmotorista+(podeexcluir == true ? "&ex="+podeexcluir : ""));
        }

    function proxima(ultimo_titulo){
     <%     //Somando a pag atual + 1 para a proxima pagina %>
             location.replace("./consultamotorista?pag="+<%=(Apoio.parseInt(pag) + 1)%>+
             "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                 "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=proxima");
         }

    function anterior(ultimo_titulo){
     <%     //Somando a pag atual + 1 para a proxima pagina %>
             location.replace("./consultamotorista?pag="+<%=(Apoio.parseInt(pag) - 1)%>+
             "&valor=<%=valorConsulta%>&limite=<%=limiteResultados%>&campo=<%=campoConsulta%>"+
                 "&ope=<%=operadorConsulta%>&ultimo="+ultimo_titulo+"&acao=anterior");
         }
         
    function enviarMotoristaEfrete(idMotorista){
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('EFreteControlador?acao=enviarMotorista&idmotorista='+idMotorista,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    function enviarMotoristaExpers(idMotorista){
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('ExpersControlador?acao=enviarMotoristaExpers&idmotorista='+idMotorista,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    function enviarMotoristaPagBem(idMotorista){
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('PagBemControlador?acao=enviarMotoristaPagBem&idmotorista='+idMotorista,{method:'post', onSuccess: e, onError: e});
        });
    }
    
    function enviarMotoristaRepom(idMotorista){
        espereEnviar("Aguarde...",true);
        function e(transport){
            espereEnviar("Aguarde...",false);
            var textoresposta = transport.responseText;
            alert(textoresposta);
            
        }
        tryRequestToServer(function(){
            new Ajax.Request('RepomControlador?acao=enviarMotoristaRepom&idmotorista='+idMotorista,{method:'post', onSuccess: e, onError: e});
        });
    }


    function excluircliente(idmotorista){      
        if((<%=nivelFrotaPropria <= 3%> && $("tipo").value == "f")){
               alert("Voce não tem permissão para 'Excluir' Motorista Frota Propria.");
               return false;                 
         }else{
             if (confirm("Deseja mesmo Excluir este Motorista?")){                 
                 location.replace("./consultamotorista?acao=excluir&id="+idmotorista);
             }
         }     
    }

    function popRel(id){
             var modelo = $("modelo").value;
             launchPDF('./relmotoristas?acao=exportar&modelo='+modelo+'&filial=0&desligado=&idmotorista='+id+'&impressao=1&tipoMotorista=todos');
         }
         
    function popImg(id, nome, cpf){
        window.open('./ImagemControlador?acao=carregar&nome='+nome+'&cpf='+cpf+'&idmotorista='+id,
        'imagensMoto','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function getRadioValorMotorista(name){
        var rads = document.getElementsByName(name);

        for(var i = 0; i < rads.length; i++){
            if(rads[i].checked){
                return rads[i].value;
            }

        }
    }

</script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <META HTTP-EQUIV="Page-Enter" CONTENT = "RevealTrans (Duration=1, Transition=12)">
        <title>WebTrans - Consulta de Motoristas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link REL="stylesheet" HREF="protoloading.css" TYPE="text/css">
        <style type="text/css">
            <!--
            .style3 {font-size: 9px}
            .style4 {	font-family: Arial, Helvetica, sans-serif;
                font-size: 13px;
            }
            -->
        </style>
    </head>
    <body onLoad="javascript:seleciona_campos();">
        <img src="img/banner.gif"  alt="">
        <br>
        <table width="100%" align="center" class="bordaFina" >
            <tr>
                <td width="484" height="22"> 
                    <div align="left">
                        <b>Consulta de Motoristas</b>
                    </div>
                </td>
                <td width="49">
                    <% if (nivelUser >= 3) {%>
                          <input name="cadcliente" type="button" class="botoes" id="cadcliente"  onClick="javascript:cadmotorista();" value="Novo cadastro">
                    <%}%>
                </td>
            </tr>
        </table>
        <br>
        <table width="100%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="124"  height="20" class="celula">
                    <select name="campo_consulta" id="campo_consulta" class="inputtexto">
                        <option value="idmotorista" selected>Cód.</option>
                        <option value="nome" selected>Nome</option>
                        <option value="apelido">Apelido</option>
                        <option value="cpf">CPF</option>
                        <option value="prontuario">Prontu&aacute;rio</option>
                        <option value="cnh">CNH</option>
                        <option value="rg">RG</option>
                        <option value="telefone">Telefone</option>
                        <option value="m.cidade">Cidade</option>
                        <option value="m.uf">UF</option>
                        <option value="vei.placa">Ve&iacute;culo</option>
                        <option value="car.placa">Carreta</option>
                        <option value="tpvei.descricao">Tipo de ve&iacute;culo</option>
                    </select>
                </td>
                <td width="158" class="celula">
                    <select name="operador_consulta" id="operador_consulta" class="inputtexto">
                        <option value="1" selected>Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                    </select>
                </td>
                <td colspan="2" class="celula">
                     <input name="valor_consulta" type="text" id="valor_consulta" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();" size="35" class="inputtexto">
                </td>
                <td width="121" class="celula">
                     <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" alt="Faz a pesquisa com os dados informados"
                            onClick="javascript:consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);">
                </td>
                <td width="225" class="celula">
                    <div align="right">
                        Por p&aacute;g.:
                        <select name="limite" id="limite" class="inputtexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                 </td>
              </tr>
          </table>
          <table width="100%" align="center" cellspacing="1" class="bordaFina">
            <tr>
                <td width="2%" class="tabela">&nbsp;</td>
                <td width="2%" class="tabela">&nbsp;</td>
                <td width="2%" class="tabela">&nbsp;</td>
                <td width="4%" class="tabela">C&oacute;d.</td>
                <td width="11%" class="tabela">Nome</td>
                <td width="10%"  class="tabela">CPF</td>
                <td width="8%" class="tabela">Habilita&ccedil;&atilde;o</td>
                <td width="8%" class="tabela">R.G.</td>
                <td width="9%" class="tabela">Telefone</td>
                <td width="11%" class="tabela">Cidade</td>
                <td width="2%" class="tabela">UF</td>
                <td width="12%" class="tabela">Ve&iacute;culo/Carreta</td>
                <td width="7%" class="tabela">Tipo</td>
                <td width="3%" class="tabela">&nbsp;</td>
            </tr>
            <% //variaveis da paginacao
            int linha = 0;
            int linhatotal = 0;
            int qtde_pag = 0;
            String ultima_linha = "";
            // se conseguiu consultar
            if ((acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) && (bMotor.Consultar())) {
                ResultSet rs = bMotor.getResultado();
                while (rs.next()) {
                        //pega o resto da divisao e testa se é par ou impar
        %>
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0) || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)
                                || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0) || Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "R".charAt(0) ){%>
                        <td>
                            <input type="radio" name="idMotoristaEfrete" id="idMotoristaEfrete" value="<%=rs.getString("idmotorista")%>">
                        </td>
                        <%}else{%>
                        <td></td>
                        <%}%>
                        <td>
                            <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                                onClick="javascript:tryRequestToServer(function(){popRel('<%=rs.getString("idmotorista")%>');});">
                        </td>
                        <td>
                            <img src="img/jpg.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Imagens de documentos"
                                onClick="javascript:tryRequestToServer(function(){popImg('<%=rs.getString("idmotorista")%>','<%=rs.getString("nome")%>','<%=rs.getString("cpf")%>');});">
                        </td>
                        <td height="24">
                            <b>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarcliente(<%=rs.getString("idmotorista")%>,<%=rs.getBoolean("podeexcluir")%>);});"><%=rs.getString("idmotorista")%></div>
                        </td>
                        <td height="24">
                            <b>
                                <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarcliente(<%=rs.getString("idmotorista")%>,<%=rs.getBoolean("podeexcluir")%>);});"><%=rs.getString("nome")%></div>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=rs.getString("cpf")%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=rs.getString("cnh")%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=rs.getString("rg")%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=rs.getString("telefone")%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=(rs.getString("cidade") == null ? "" : rs.getString("cidade"))%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=(rs.getString("uf") == null ? "" : rs.getString("uf"))%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=(rs.getString("veiculo").equals("") && rs.getString("carreta").equals("") ? "" : rs.getString("veiculo") + "/" + rs.getString("carreta"))%></font>
                        </td>
                        <td>
                            <font color="<%=rs.getBoolean("bloqueado") ? "red" : "black"%>"><%=rs.getString("tipo_veiculo")%></font>
                        </td>
                        <input type="hidden" id="tipo" name="tipo" value="<%=rs.getString("tipo")%>">
                        <td width="43">
                            <%if ((nivelUser == 4) && (rs.getBoolean("podeexcluir"))) //Verificando se tem permissão de exclusão
                             {%>
                                <img id="imgExcluir<%=rs.getString("idmotorista")%>" src="img/lixo.png" alt="Excluir este registro" style="cursor:pointer"
                                     onClick="javascript:tryRequestToServer(function(){excluircliente(<%=rs.getString("idmotorista")%>);});">
                            <%}%>
                        </td>
                    </tr>
                    <% //se for a ultima linha...
                        if (rs.isLast()) {
                            ultima_linha = rs.getString("nome");
                            //Quantidade geral de resultados da consulta
                            linhatotal = rs.getInt("qtde_linhas");
                        }
                        linha++;
                }//while
                //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
                qtde_pag = ((linhatotal % Apoio.parseInt(limiteResultados)) == 0
                        ? (linhatotal / Apoio.parseInt(limiteResultados))
                        : (linhatotal / Apoio.parseInt(limiteResultados)) + 1);
                pag = (qtde_pag == 0 ? "0" : pag);
            }//if
            %><script type="text/javascript" language="javascript" >paginaAtual= <%=bMotor== null ? 1 :bMotor.getPaginaResultados()%>;qtde_pag = <%=qtde_pag%>;linhatotal = <%=linhatotal%>;</script>
        </table>
        <br>
        <table width="100%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="20%" height="22">
                    <center>
                        Ocorr&ecirc;ncias: 
                        <b><%=linha%> / <%=linhatotal%></b>
                    </center>
                </td>
                <td width="14%">
                    P&aacute;ginas: 
                    <b><%=pag%> / <%=qtde_pag%></b>
                </td>
                <td width="14%">
                    <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
                        <input name="enviarEfrete" type="button" class="botoes" id="enviarEfrete"
                        value="Enviar para e-Frete"  onClick="javascript:tryRequestToServer(function(){enviarMotoristaEfrete(getRadioValorMotorista('idMotoristaEfrete'));});">
                    <%}%>
                </td>
                <td width="14%">
                    <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "X".charAt(0)){%>
                        <input name="enviarExpers" type="button" class="botoes" id="enviarExpers"
                        value="Enviar para ExpeRS"  onClick="javascript:tryRequestToServer(function(){enviarMotoristaExpers(getRadioValorMotorista('idMotoristaEfrete'));});">
                    <%}%>
                    <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)){%>
                        <input name="enviarPagBem" type="button" class="botoes" id="enviarPagBem"
                        value="Enviar para PagBem"  onClick="javascript:tryRequestToServer(function(){enviarMotoristaPagBem(getRadioValorMotorista('idMotoristaEfrete'));});">
                    <%}%>
                    <%if(Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "R".charAt(0)){%>
                        <input name="enviarRepom" type="button" class="botoes" id="enviarRepom"
                        value="Enviar para Repom"  onClick="javascript:tryRequestToServer(function(){enviarMotoristaRepom(getRadioValorMotorista('idMotoristaEfrete'));});">
                    <%}%>
                </td>
                <td width="12%">
                    <div align="center">
                        <input name="voltar" type="button" class="botoes" id="voltar"
                               value="Anterior"  onClick="javascript:tryRequestToServer(function(){anterior('<%=ultima_linha%>');});">
                        <input name="avancar" type="button" class="botoes" id="avancar"
                               value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=ultima_linha%>');});">
                    </div>
                </td>
                <td width="27%" align="right">Modelo de impress&atilde;o em PDF:</td>
                <td width="13%">
                    <select name="modelo" id="modelo" class="inputtexto">
                        <option value="2" <%=cfg.getRelDefaultMotorista().equals("2")?"selected":""%> >Modelo 2</option>
                        <option value="3" <%=cfg.getRelDefaultMotorista().equals("3")?"selected":""%> >Modelo 3</option>
                        <option value="4" <%=cfg.getRelDefaultMotorista().equals("4")?"selected":""%> >Modelo 4</option>
                        <option value="5" <%=cfg.getRelDefaultMotorista().equals("5")?"selected":""%> >Modelo 5</option>
                    
                        //19/08/13 Adição da opção de exibir modelos personalizados dentro do select    
                        <%
                            for (String rel : Apoio.listDocMotorista(request)) {%>
                            <option value="doc_motorista_personalizado_<%=rel%>" <%=(cfg.getRelDefaultMotorista().startsWith("doc_motorista_personalizado_") ? "selected" : "")%> >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                        <%}%>
                        
                        
                    </select>
                </td>
            </tr>
        </table>
    </body>
</html>