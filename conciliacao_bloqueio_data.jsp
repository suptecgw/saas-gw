<%@page import="java.io.PrintWriter"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" 
         import="nucleo.Apoio,java.text.*,mov_banco.*,java.util.Date,mov_banco.conta.*,
         java.sql.ResultSet,java.util.*"
         errorPage="" %>

<% 
//---------------------------------- Permissões ------------------------------
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("conbancaria") : 0);
            int nivelUserDespesaFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);

//---------------------------------- Permissões ------------------------------ fim
            int contaDefault = Apoio.parseInt(request.getParameter("conta"));

            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }

            String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
            SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
            boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
            int idUsuario = Apoio.getUsuario(request).getIdusuario();

            //Classes
            BeanBloqueioContaData bloqueioContaData = null;
            BeanCadMovBanco cadMovBanco = null;

            String scr = "";
            //----------------------------- Ação de Incluir --------------------------------
            boolean erroBaixar = false;
            Date dtinicial = new Date();
            Date dtfinal = new Date();
            Date dtBloqueio = new Date();
            if (acao.equals("incluir") || acao.equals("excluir")) {
                if (acao.equals("incluir") && nivelUser == 4) {
                    dtinicial = formatador.parse(request.getParameter("dtinicial"));
                    dtfinal = formatador.parse(request.getParameter("dtfinal"));
                    dtBloqueio = dtinicial;
                    Collection listBloqueio = new ArrayList();

                    while (dtBloqueio.getTime() <= dtfinal.getTime()){
                        cadMovBanco = new BeanCadMovBanco();
                        cadMovBanco.setConexao( Apoio.getUsuario(request).getConexao() );
                        cadMovBanco.setExecutor(Apoio.getUsuario(request));

                        bloqueioContaData = new BeanBloqueioContaData();
                        bloqueioContaData.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
                        bloqueioContaData.setDtBloqueio(dtBloqueio);
                        bloqueioContaData.setUsuarioBloqueio(Apoio.getUsuario(request));

                        listBloqueio.add(bloqueioContaData);

                        dtBloqueio = Apoio.somaData(dtBloqueio,1); // mais um dia
                    }

                    erroBaixar = !cadMovBanco.incluirListBloqueioDataConta(listBloqueio);


                    //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
                    if (erroBaixar) {
                        scr = "<script>alert('" + cadMovBanco.getErros() + "');</script>";
                        scr += "<script>window.opener.location= 'conciliacao_bloqueio_data.jsp?acao=iniciar&conta="+request.getParameter("conta")+"';window.close();</script>";
                    } else {
                        scr += "<script>alert('Período bloqueado com sucesso.');</script>";
                        scr += "<script>window.opener.location= 'conciliacao_bloqueio_data.jsp?acao=iniciar&conta="+request.getParameter("conta")+"';window.close();</script>";
                    }
                    //response.getWriter().close();


                    //----------------------------- Ação de Baixa -------------------------------- fim
                    
                    
                    
                    
                    
                    

                    // ---------------------------- Excluir---------- ---------------------------- inicio
                } else if (acao.equals("excluir") && nivelUser == 4) {
                    dtinicial = formatador.parse(request.getParameter("dtinicial"));
                    dtfinal = formatador.parse(request.getParameter("dtfinal"));
                    dtBloqueio = dtinicial;
                    Collection listBloqueio = new ArrayList();

                    while (dtBloqueio.getTime() <= dtfinal.getTime()){
                        cadMovBanco = new BeanCadMovBanco();
                        cadMovBanco.setConexao( Apoio.getUsuario(request).getConexao() );
                        cadMovBanco.setExecutor(Apoio.getUsuario(request));

                        bloqueioContaData = new BeanBloqueioContaData();
                        bloqueioContaData.getConta().setIdConta(Integer.parseInt(request.getParameter("conta")));
                        bloqueioContaData.setDtBloqueio(dtBloqueio);
                        bloqueioContaData.setUsuarioBloqueio(Apoio.getUsuario(request));

                        listBloqueio.add(bloqueioContaData);

                        dtBloqueio = Apoio.somaData(dtBloqueio,1); // mais um dia
                    }

                    cadMovBanco.excluirListBloqueioDataConta(listBloqueio);

                    if (erroBaixar) {
                        scr = "<script>alert('" + cadMovBanco.getErros() + "');</script>";
                        scr += "<script>window.opener.location= 'conciliacao_bloqueio_data.jsp?acao=iniciar&conta="+request.getParameter("conta")+"';window.close();</script>";
                    } else {
                        scr += "<script>alert('Período desbloqueado com sucesso.');</script>";
                        scr += "<script>window.opener.location= 'conciliacao_bloqueio_data.jsp?acao=iniciar&conta="+request.getParameter("conta")+"';window.close();</script>";
                    }
                }else if (nivelUser < 4){
                    scr = "<script>alert('Você não tem permissão para executar está ação.');window.close();</script>";
                }
                response.getWriter().append(scr);
                response.getWriter().close();
            }else if(acao.equals("bloqueio")){
               int id = Apoio.parseInt(request.getParameter("id"));
               
               response.getWriter().append(BeanCadMovBanco.bloqueio(id));
               response.getWriter().close();
                                                               
            }
            
            

// ---------------------------- Ações de consulta ---------------------------- fim
%>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">

    function salvar(){
       

        if ($("conta").value == ""){
            alert("Informe a conta.");
            $("conta").focus();
            return false;
        }

        if ($("dtinicial").value == ""){
            alert("Informe a data inicial corretamente.");
            $("dtinicial").focus();
            return false;
        }

        if ($("dtfinal").value == ""){
            alert("Informe a data final corretamente.");
            $("dtfinal").focus();
            return false;
        }

        
        $("formulario").action ="conciliacao_bloqueio_data.jsp";
        $("formulario").target = "pop";
        $("formulario").method = "post";

        //habilitaSalvar(false);
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").submit();
        return true;
    }

    //---------------------- Carregar -- inicio

    function carregar(){
        carregarDataBloqueio($('conta').value);
    }


    //---------------------- Carregar -- fim

    function fechar(){
        window.close();
    }
    
    
    function carregarDataBloqueio(id){
        try {
            function e(response, st){                
                setDataBloqueio(response);
            }
            requisitaAjax("conciliacao_bloqueio_data.jsp?acao=bloqueio&id="+id,e);                
        } catch (e) { 
            alert(e);
        }

     }
    
    
    function setDataBloqueio(data){
        if (data.length == 6) {
            invisivel($("trDataBloqueio"));
        }else{
            visivel($("trDataBloqueio"));
            $("dataBloqueio").innerHTML = data;
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

        <title>Webtrans - Fechamento de movimentações bancárias </title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onload="carregar();">
        <div align="center"><img src="img/banner.gif"  alt="banner">
            <br>
        </div>
        <table width="70%" height="28" align="center" class="bordaFina" >
            <tr>
                <td width="86%" height="22"><b>Fechamento de movimentações bancárias </b></td>
                <td width="14%">
                    <b>
                        <input  name="Button" type="button" class="botoes" value="Fechar" onClick="fechar()">
                    </b>
                </td>
            </tr>
        </table>
        <br>
        <form method="post" id="formulario" target="pop">
            <table width="70%" border="0" class="bordaFina" align="center">

                <tr class="tabela">
                    <td height="18" colspan="2"><div align="center">Dados</div></td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="30%">
                        Conta:
                    </td>
                    <td class="CelulaZebra2" width="70%">
                        <select name="conta" id="conta" class="inputtexto" onchange="carregarDataBloqueio(this.value);">
                            <% //variaveis da paginacao
                              //Carregando todas as contas cadastradas
                              BeanConsultaConta conta = new BeanConsultaConta();
                              conta.setConexao(Apoio.getUsuario(request).getConexao());
                              conta.mostraContas((nivelUserDespesaFilial > 1 ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial()), false, limitarUsuarioVisualizarConta, idUsuario);
                              ResultSet rsconta = conta.getResultado();
                              while (rsconta.next()) {%>
                         <option value="<%=rsconta.getString("idconta")%>" <%= (contaDefault == rsconta.getInt("idconta") ? "selected" : "") %>><%=rsconta.getString("numero") + "-" + rsconta.getString("digito_conta") + " - " + rsconta.getString("banco")%></option>
                            <%}%>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">
                        Data:
                    </td>
                    <td class="CelulaZebra2">
                        <strong>                            
                            <input name="dtinicial" type="text" id="dtinicial" class="fieldDate" value="<%=(request.getParameter("dtinicial") != null ? request.getParameter("dtinicial") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                   onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" />
                        </strong>até<strong>
                            <input name="dtfinal" type="text" id="dtfinal" class="fieldDate" value="<%=(request.getParameter("dtfinal") != null ? request.getParameter("dtfinal") : Apoio.getDataAtual())%>" size="9" maxlength="10"
                                   onblur="alertInvalidDate(this)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                        </strong>
                    </td>
                </tr>
                
                <tr id="trDataBloqueio">
                    <td class="TextoCampos" >
                        Data do último bloqueio:
                    </td>
                    <td class="CelulaZebra2" width="71%" >
                       <label id="dataBloqueio"></label>
                    </td>
                </tr>
                
                
                <tr>
                    <td class="TextoCampos" colspan="2" >
                        <div align="center">
                        <input type="radio" name="acao" id="acao" value="incluir" checked />
                        Bloquear
                        &nbsp;
                        <input type="radio" name="acao" id="acao" value="excluir" />
                        Desbloquear
                        </div>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="TextoCampos">
                        <div align="center">
                            <input name="salva" type="button" class="botoes" id="salva" value="   Salvar  " onClick="javascript:tryRequestToServer(function(){salvar();});">

                        </div>
                    </td>
                </tr>
            </table>
        </form>

    </body>
</html>
