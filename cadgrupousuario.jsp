<%@page import="br.com.gwsistemas.filial.permissao.Permissao"%>
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@page import="br.com.gwsistemas.filial.usuario.grupo.GrupoUsuario"%>
<%@ page contentType="text/html" language="java"
         import="java.sql.ResultSet,
         java.util.Arrays,
         permissao.BeanPermissao,
         nucleo.Apoio,
         usuario.grupo.*,
         usuario.BeanCadUsuario,
         filial.BeanConsultaFilial" errorPage="" %>

<script language="javascript" type="text/javascript" src="script/prototype.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0 ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadgrupousuario") : 0);
    boolean souadm = Apoio.getUsuario(request).getAcesso("cadgrupousuario") == 4;
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
%>

<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaUser = false;
    BeanPermissao perm = null;
    BeanGrupo gru = null;
    BeanCadGrupo cadGru = null;
    BeanConsultaFilial listafilial = null;

    //instrucoes incomuns entre as acoes
    if ((nivelUser > 0) && (acao.equals("editar") || acao.equals("carregapermissao") || acao.equals("iniciar"))) {
        perm = new BeanPermissao();
        perm.setConexao(Apoio.getUsuario(request).getConexao());

        //se for um administrador, vai ser carregado as filiais cadastradas
        if (souadm) {
            listafilial = new BeanConsultaFilial();
            listafilial.setConexao(Apoio.getUsuario(request).getConexao());
            listafilial.setCampoDeConsulta("uf");
            listafilial.setLimiteResultados(100);
            listafilial.setOperador(listafilial.TODAS_AS_PARTES);
            listafilial.setValorDaConsulta("");
            if (!listafilial.Consultar()) {%>
<script type="javascript">
    alert("Erro ao tentar carregar as filiais cadastradas!");
    window.close();
</script>
<%}
        }//souadm
    }

    if (acao.equals("incluir") || acao.equals("atualizar")) {
        perm = new BeanPermissao();
        perm.setConexao(Apoio.getUsuario(request).getConexao());
        cadGru = new BeanCadGrupo();
        cadGru.setConexao(Apoio.getUsuario(request).getConexao());
        cadGru.setExecutor(Apoio.getUsuario(request));
        gru = new BeanGrupo();
        gru.setId((request.getParameter("id") != null ? Integer.parseInt(request.getParameter("id")) : 0));
        gru.setDescricao(request.getParameter("descricao"));
        gru.getFilial().setIdfilial(request.getParameter("idfi") != null ? Integer.parseInt(request.getParameter("idfi")) : 0);
        String ps = "";
        String ni = "";
        int i = 1;
        while (request.getParameter("cb" + i) != null) {
            if (!request.getParameter("cb" + i).equals("0")) {
                ps += (ps != "" ? "," : "") + request.getParameter("cb" + i).split(",")[0];
                ni += (ni != "" ? "," : "") + request.getParameter("cb" + i).split(",")[1];
            }
            i++;
        }
        cadGru.setGrupo(gru);
        cadGru.setIdpermissoes(ps.split(","));
        cadGru.setNiveis(ni.split(","));
        boolean erro = !((acao.equals("incluir"))
                ? cadGru.Inclui() : cadGru.Atualiza());
//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%
if (erro) {%>
    alert('<%=(cadGru.getErros())%>');
    window.opener.document.getElementById("salvar").disabled = false;
    window.opener.document.getElementById("salvar").value = "Salvar";
    <%} else {%>
    window.opener.document.location.replace("ConsultaControlador?codTela=61");
    <%}%>
    window.close();
</script>
<%}

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        //instanciando o bean de cadastro
        gru = new BeanGrupo();
        cadGru = new BeanCadGrupo();
        cadGru.setConexao(Apoio.getUsuario(request).getConexao());

        int idGrupo = Integer.parseInt(request.getParameter("id"));
        gru.setId(idGrupo);
        cadGru.setGrupo(gru);
        //carregando o usuario por completo(atributos, permissoes)
        cadGru.LoadAllPropertys();
    }

    //variavel usada para saber se o usuario esta editando o cadastro
    carregaUser = ((cadGru != null) && (cadGru.getIdpermissoes() != null)
            && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>

<script language="javascript" type="text/javascript">
    jQuery.noConflict();

var arAbasGU = new Array();
    arAbasGU[0] = new setAba('tdPrincipal','divPermissoes');
    arAbasGU[1] = new setAba('tdAbaAuditoria','divAuditoria');


function setAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

   function AlterneAba(menu, conteudo) {
    try {
        if (arAbasGU != null) {
            for (i = 0; i < arAbasGU.length; i++) {
                if (arAbasGU[i] != null && arAbasGU[i] != undefined) {
                    m = document.getElementById(arAbasGU[i].menu);
                    m.className = 'menu';
                    for (var j = 0, max = arAbasGU[i].conteudo.split(",").length; j < max; j++) {
                        c = document.getElementById(arAbasGU[i].conteudo.split(",")[j]);
                        if (c != null) {
                            invisivel(c, false);
                        } else if ($(arAbasGU[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                            invisivel($(arAbasGU[i].conteudo.split(",")[j].replace("div", "tr")), false);
                        }
                    }
                }
            }
            m = document.getElementById(menu);
            m.className = 'menu-sel';
            for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                c = document.getElementById(conteudo.split(",")[i]);
                if (c != null) {
                    visivel(c, false);
                } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                    visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                }
            }
        } else {
            alert("Inicialize a variavel arAbasGenerico!");
        }
    } catch (e) {
        alert(e);
    }
}


function check() {
    var i = 1;
    while ($("cb" + i) != null) {
        if ($("cb" + i).value != "0")
            return true;
        i++;
    }
    return false;
}

function voltar() {
    document.location.replace("ConsultaControlador?codTela=61");
}

function envia(acao) {
    if (check() && !wasNull("descricao")) {

        var idps = "";
        var idni = "";

        if (acao == "atualizar")
            acao += "&id=<%=(carregaUser ? cadGru.getGrupo().getId() : 0)%>";

        $('formGrupo').action = "./cadgrupousuario.jsp?acao=" + acao;
        $("salvar").disabled = true;
        $("salvar").value = "Enviando...";
        //submitPopupForm($('formGrupo'));

        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formGrupo").submit();
    } else
        alert("Preencha os campos corretamente!");
}

function excluir(id) {
    if (confirm("Deseja mesmo excluir este grupo de usuário?")) {
        location.replace("./consulta_grupousuario.jsp?acao=excluir&id=" + id);
    }
}

function carregapermissao(idfilial) {
    $("salvar").disabled = true;
    $("salvar").value = "Enviando...";
    location.replace("./cadgrupousuario.jsp?acao=carregapermissao&id=" + idfilial);
}

function atribuicombo() {
    <%if (acao.equals("carregapermissao") && request.getParameter("id") != null) {%>
    $("idfi").value = "<%=request.getParameter("id")%>";
    <%}%>
}

function onChangeIdFi(id) {
    if (id != '0')
        tryRequestToServer(function () {
            carregapermissao(id);
        });
}


function onChangeGrupo(idfilial, idgrupo) {
    $("salvar").disabled = true;
    $("salvar").value = "Enviando...";
    var descricao = document.getElementById("descricao").value;
    location.replace("./cadgrupousuario.jsp?acao=carregapermissao&id=" + idfilial + "&idGrupo=" + idgrupo + "&descricao=" + descricao);
}


function carregarPermissoesGrupo() {
    var idGrupo = $("grupoUsuario").value;

    new Ajax.Request('UsuarioControlador?acao=carregarPermissoesGrupoToGrupo&idGrupo=' + idGrupo,
            {
                method: 'get',
                onSuccess: function (transport) {
                    var response = transport.responseText;
                    var lista = jQuery.parseJSON(response);
                    var permissoes = lista.list[0].Permissao;
                    var length = (permissoes != undefined && permissoes.length != undefined ? permissoes.length : 1);
                    var perm;

                    var total = $("ultimaPerm").value;


                    if (length > 1) {

                        for (var i = 1; i <= length; i++) {
                            perm = permissoes[i];

                            for (var p = 0; p <= total; p++) {
                                console.log("AAAAAAAAAAAAAAAAA chega aqui " + i)

                            }


                            console.log("chega aqui " + i)


                        }
                    } else if (length == 1) {
                        perm = permissoes;

                    }


                },
                onFailure: function () {
                    alert('Something went wrong...')
                }
            });
}
function pesquisarAuditoria() {
    if (countLog != null && countLog != undefined) {
        for (var i = 1; i <= countLog; i++) {
            if ($("tr1Log_" + i) != null) {
                Element.remove(("tr1Log_" + i));
            }
            if ($("tr2Log_" + i) != null) {
                Element.remove(("tr2Log_" + i));
            }
        }
    }
    countLog = 0;
    var rotina = "grupo_usuarios";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=(carregaUser ? cadGru.getGrupo().getId() : 0)%>;
    consultarLog(rotina, id, dataDe, dataAte);
}

function setAuditoria() {
    $("dataDeAuditoria").value = "<%=carregaUser ? Apoio.getDataAtual() : ""%>";
    $("dataAteAuditoria").value = "<%=carregaUser ? Apoio.getDataAtual() : ""%>";

}


</script>
<%@page import="java.text.SimpleDateFormat"%>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onLoad="javascript:atribuicombo();
            setAuditoria();
              AlterneAba('tdPrincipal','divPermissoes')">
        <img src="img/banner.gif" >
        <br>
        <table width="65%" align="center" class="bordaFina" >
            <tr>
                <td width="613">
                    <div align="left">
                        <b>Cadastro de grupos de usu&aacute;rios </b>
                    </div>
                </td>
                <%if ((acao.equals("editar")) && (nivelUser >= 4)) //se o paramentro vier com valor entao nao pode excluir
          {%>
                <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:tryRequestToServer(function () {
                            excluir(<%=(carregaUser ? cadGru.getGrupo().getId() : 0)%>);
                        });"></td>
                    <%}%>
                <td width="56" ><input  name="voltar" type="button" class="botoes" id="voltar" onClick="javascript:voltar();" value="Consulta"></td>
            </tr>
        </table>
        <form method="post" id="formGrupo" name="formGrupo" target="pop">
            <table width="65%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela">
                    <td  colspan="7" align="center">Dados principais</td>
                </tr>
                <tr>
                    <td width="88" class="TextoCampos">Filial:</td>
                    <td width="267" class="CelulaZebra2">
                        <%if ((souadm) && !(carregaUser) && (listafilial != null)) {%>
                        <select class="inputtexto" id="idfi" name="idfi" onChange="javascript:onChangeIdFi(this.value)">
                            <%=(!listafilial.getResultado().wasNull() && !acao.equals("carregapermissao")
                    ? "<option value=\"0\">-- Selecione a filial --</option>" : "")%>
                            <%while (listafilial.getResultado().next()) {
                    int idfi = listafilial.getResultado().getInt("idfilial");
                    String desc = listafilial.getResultado().getString("abreviatura");%>
                            <option value="<%=idfi%>">
                                <%=desc%></option>
                                <%}%>
                        </select>
                        <%} else {%>
                        <b><%=(carregaUser ? cadGru.getGrupo().getFilial().getAbreviatura() : Apoio.getUsuario(request).getFilial().getAbreviatura())%></b>
                        <%}%>
                    </td>
                    <td class="TextoCampos">Descri&ccedil;&atilde;o :</td>
                    <td width="280" class="CelulaZebra2"><input name="descricao" type="text" id="descricao" value="<%=(carregaUser ? cadGru.getGrupo().getDescricao() : (request.getParameter("descricao") != null && request.getParameter("descricao") != "null" ? request.getParameter("descricao") : ""))%>" size="45" maxlength="50" class="inputtexto"></td>
                </tr>
            </table>
             <table width="65%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdPrincipal" class="menu-sel" onclick="AlterneAba('tdPrincipal', 'divPermissoes')"> Dados Principais </td>
                                               
                                  <td  style='display: <%=carregaUser && nivelUser ==4 ? "" : "none" %>' id="tdAbaAuditoria" class="menu" onclick="AlterneAba('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                            
                               </tr>
                            </table>
                        </td> 
                    </tr>
               </table>  
           <div id='divPermissoes'>                       
            <table width="65%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">    
                <%
                    //contador de permissoes
                    int i = 0;

      //se estiver editando entao carregue as permissoes do cadastro.
                    //senao carregue o da filial do usuario logado OU se ADM carregue a escolhida
                    int idfilial = 0;
                    if ((souadm) && (acao.equals("carregapermissao")) && (request.getParameter("id") != null)) {
                        idfilial = Integer.parseInt(request.getParameter("id"));
                    } else {
                        idfilial = (carregaUser
                                ? cadGru.getGrupo().getFilial().getIdfilial() : Apoio.getUsuario(request).getFilial().getIdfilial());
                    }

                    //se for um adm e estiver apenas iniciando um cadastro...
                    idfilial = (souadm && acao.equals("iniciar") ? 0 : idfilial);
                    perm.ConsultarGruposFilial(idfilial);
                %>

                <% if (!acao.equals("editar")) {%>
                <tr >
                    <td class="TextoCampos" colspan="2">
                        Copiar permissões de outro Grupo de Usuário.
                    </td>
                    <td class="CelulaZebra2" colspan="2">
                        <select id="grupoUsuario" name="grupoUsuario" onchange="javaScript:onChangeGrupo($('idfi').value, this.value);" class="inputTexto">
                            <option value="--">Selecione um grupo</option>
                            <%for (GrupoUsuario grupo : perm.getGrupos()) {%>
                            <option value="<%= grupo.getId()%>" <%= (request.getParameter("idGrupo") != null && Apoio.parseInt(request.getParameter("idGrupo")) == grupo.getId() ? "selected" : "")%>><%= grupo.getDescricao()%></option>
                            <%}%>
                        </select>
                    </td>
                </tr>
                <%}%>
                <tr>
                    <td class="tabela" colspan="4" align="center">Hierarquia de acesso</td>
                </tr>
                <TD height="23" colspan="6">
                    <table width="100%" border="1" align="center" cellpadding="1" cellspacing="1">
                        <!-- INICIO -->
                        <%
                        //o codigo que era aqui, foi preciso ser antes, para carregar os grupos ja existentes da filial escolhida.

                            //se é p/ carregar as perrmissoes(o id da filial estiver alimentado)
                            if ((idfilial > 0)
                                    && (perm.Consultar(perm.PEMISSOES_DA_FILIAL, idfilial))) {    //declarando essa variavel  por conveniencia de codigo
                                ResultSet rs = perm.getResultSet();
                                String categ = "";
                                boolean fimRs = false;
                                //agora ele vai listar as permissoes e testar se o usuario tem aquela permissao
                                fimRs = !rs.next();
                                if (request.getParameter("idGrupo") != null) {
                                    perm.carregarPermissoesGrupoToGrupo(request);
                                }
                                while (!fimRs) {
                                    int nivel = 0;
                                    if (carregaUser) {
                                                          //procurando no array de idpermissoes se o usuarrio tem aquela permissao
                                        //se tiver ele retorna o nivel da permissao
                                        int posicao_nivel = Apoio.pesquisaArray(cadGru.getIdpermissoes(), rs.getString("idpermissao"));
                                        nivel = (posicao_nivel >= 0 ? Integer.parseInt(cadGru.getNiveis()[posicao_nivel]) : 0);
                                    }

                                    if (request.getParameter("idGrupo") != null && request.getParameter("idGrupo") != "0") {
                                        int posicao_nivel = Apoio.pesquisaArray(perm.getIdPermissao(), rs.getString("idpermissao"));
                                        nivel = (posicao_nivel >= 0 ? Integer.parseInt(perm.getNiveisPermissao()[posicao_nivel]) : 0);
                                    }
                                    i++;
                                    if (!categ.equals(rs.getString("categoria"))) {
                                        categ = rs.getString("categoria");
                      if (categ.equals("0ca")) {%>
                        <tr class="celula"><td colspan="5"><b>Cadastros</b></td></tr>
                        <%} else if (categ.equals("1la")) {%>
                        <tr class="celula"><td colspan="5"><b>Lançamentos</b></td></tr>
                        <%} else if (categ.equals("2pr")) {%>
                        <tr class="celula"><td colspan="5"><b>Processos</b></td></tr>
                        <%} else if (categ.equals("3re")) {%>
                        <tr class="celula"><td colspan="5"><b>Relatórios</b></td></tr>
                        <%} else if (categ.equals("4co")) {%>
                        <tr class="celula"><td colspan="5"><b>Configurações</b></td></tr>
                        <%} else if (categ.equals("5ou")) {%>
                        <tr class="celula"><td colspan="5"><b>Outras permissões</b></td></tr>
                        <%}
                        }%>
                        <tr>
                            <td colspan="2" class="TextoCampos"><%=rs.getString("descricao")%>:</td>
                            <td  class="CelulaZebra2">
                                <select name="cb<%=i%>" id="cb<%=i%>" class="inputtexto"> 
                                    <%if (rs.getString("tipo").equals("NV")) {%>
                                    <option <%=(nivel == 0 ? "selected" : "")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                                    <option <%=(nivel == 1 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,1" style="background-color:#E5E5E5">Ler</option>
                                    <option <%=(nivel == 2 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,2" style="background-color:#CDCDCD">Ler, altera</option>
                                    <option <%=(nivel == 3 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,3" style="background-color:#A7A7A7">Ler, altera, inclui</option>
                                    <option <%=(nivel == 4 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Controle total</option>
                                    <%} else {%>	
                                    <option <%=(nivel <= 0 ? "selected" : "")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                                    <option <%=(nivel == 4 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Com acesso</option>
                                    <%} %>	
                                </select>
                            </td>
                            <% //chamando outro next() para a segunda coluna de permissoes
                        if (rs.next()) {
                            if (!categ.equals(rs.getString("categoria"))) {%>
                            <td colspan="2" width="50%" class="CelulaZebra2">&nbsp;</td>
                            <%} else {
                                if (carregaUser) {
                                    int posicao_nivel = Apoio.pesquisaArray(cadGru.getIdpermissoes(), rs.getString("idpermissao"));
                                    nivel = (posicao_nivel >= 0 ? Integer.parseInt(cadGru.getNiveis()[posicao_nivel]) : 0);
                                }
                                if (request.getParameter("idGrupo") != null && request.getParameter("idGrupo") != "0") {
                                    int posicao_nivel = Apoio.pesquisaArray(perm.getIdPermissao(), rs.getString("idpermissao"));
                                    nivel = (posicao_nivel >= 0 ? Integer.parseInt(perm.getNiveisPermissao()[posicao_nivel]) : 0);

                                                    }
                                                    i++;%>
                            <td class="TextoCampos"><%=rs.getString("descricao")%>:</td>
                            <td class="CelulaZebra2">
                                <select name="cb<%=i%>" id="cb<%=i%>" class="inputtexto">
                                    <%if (rs.getString("tipo").equals("NV")) {%>
                                    <option <%=(nivel == 0 ? "selected" : "")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                                    <option <%=(nivel == 1 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,1" style="background-color:#E5E5E5">Ler</option>
                                    <option <%=(nivel == 2 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,2" style="background-color:#CDCDCD">Ler, altera</option>
                                    <option <%=(nivel == 3 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,3" style="background-color:#A7A7A7">Ler, altera, inclui</option>
                                    <option <%=(nivel == 4 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Controle total</option>
                                    <%} else {%>	
                                    <option <%=(nivel <= 0 ? "selected" : "")%> value="0" style="background-color:#FFFFFF">Sem acesso</option>
                                    <option <%=(nivel == 4 ? "selected" : "")%> value="<%=rs.getString("idpermissao")%>,4" style="background-color:#808080; color:#FFFFFF">Com acesso</option>
                                    <%} %>	
                                </select>
                            </td>
                            <%fimRs = !rs.next();
                                            }
                                        } else {
                                            fimRs = true;%>
                            <td colspan="2" class="CelulaZebra2">&nbsp;
                                <input type="hidden" id="ultimaPerm" name="ultimaPerm" value="<%=i%>">
                            </td>
                            <%}//if-else%>
                        </tr>
                        <%}//while%>
                        <%}else{%>
                        <div align="center" style=" text-align:center; color:#804000; font-size: 12px ">(Selecione uma Filial para carregar as permissões)</div>
                        <%}%>
                        <!-- FIM -->
                    </table>
                </TD>
                <%if (acao.equals("editar")){%>
            </table>
           </div>
           <div id='divAuditoria'> 
            <table width="65%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td>
                        <%@include file="/gwTrans/template_auditoria.jsp" %>
                    </td>
                    <td colspan="10"><table width="100%"  border="0">
                            <tr>
                                <td width="12%" class="TextoCampos">Incluso : </td>
                                <td width="38%" class="CelulaZebra2">Em: <%=(carregaUser ? new SimpleDateFormat("dd/MM/yyyy").format(cadGru.getGrupo().getCreatedAt()) : "")%><br>Por: <%=(carregaUser ? cadGru.getGrupo().getCreatedBy() : "")%></td>
                                <td width="12%" class="TextoCampos">Alterado : </td>
                                <td width="38%" class="CelulaZebra2">Em: <%=(carregaUser && cadGru.getGrupo().getUpdatedAt() != null ? new SimpleDateFormat("dd/MM/yyyy").format(cadGru.getGrupo().getUpdatedAt()) : "")%><br>Por: <%=(carregaUser ? cadGru.getGrupo().getUpdatedBy() : "")%></td>
                            </tr>
                        </table></td>
                </tr>
            </table>
           </div>                
                            <br/>
            <%}
      if (nivelUser >= 2) {%>
            <table width="65%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="CelulaZebra2">
                    <td colspan="10">
                <center>
                    <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" style="width:88 "
                           onClick="javascript:tryRequestToServer(function () {
                                       envia('<%=(acao.equals("iniciar") || acao.equals("carregapermissao") ? "incluir" : "atualizar")%>');
                                   });">
                </center></td>
                </tr>
                <%}%>
            </table>
        </form>
        <br> 

