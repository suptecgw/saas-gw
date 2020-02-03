<%@page import="nucleo.BeanConfiguracao"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*,usuario.BeanUsuario,nucleo.Apoio" errorPage="" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/tld/custonTagLibrary.tld" prefix="cg" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page import="br.com.gwsistemas.video.Video"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.video.VideoBO"%>
<!DOCTYPE html>
<html>
    <head>	
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <link rel="stylesheet" href="${homePath}/assets/css/altera-user.css?v=${random.nextInt()}">
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-sistemas.png"/>
            <jsp:param name="nomeUsuario" value="<%=Apoio.getUsuario(request).getNome()%>"/>
        </jsp:include>
        <meta charset="ISO-8859-1">
        <% //testando se a sessao é válida...
            if (Apoio.getUsuario(request) == null) {
                response.sendError(response.SC_FORBIDDEN);
            }

            String acao = (request.getParameter("acao") == null || request.getSession().getAttribute("usuario") == null ? "" : request.getParameter("acao"));
            BeanUsuario user = null;
            String nome = "";
            String login = "";
            String email = "";
            
            BeanConfiguracao bConfig = Apoio.getConfiguracao(request);
            if(bConfig != null){
                request.setAttribute("cfg", bConfig);
            }

            if (!acao.equals("")) {
                user = Apoio.getUsuario(request);
                request.setAttribute("user", user);
                if (acao.equals("iniciar")) {
                    nome = user.getNome();
                    login = user.getLogin();
                    email = user.getEmail();
                    VideoBO bo = new VideoBO();
                    Collection<Video> list = bo.carregarTodosVideos(user);
                    Collection<Video> listVidTela = bo.carregarVideosTela(user, 7);
                    request.setAttribute("listVideos", list);
                    request.setAttribute("listVideosTela", listVidTela);
                } else {
                    if (acao.equals("alterar")) {
                        //pegando os dados q o usuario alterrou
                        user.setNome(request.getParameter("nome"));
                        user.setLogin(request.getParameter("login"));
                        user.setEmail(request.getParameter("email"));
                        if (user.AtualizaUsuario()) {
        %>
        <script language="javascript" type="text/javascript">
            jQuery(document).ready(function () {
                chamarAlert('Seus dados foram atualizados corretamente!', closed);
            });
        </script>
        <%
        } else {
        %>
        <script language="javascript" type="text/javascript">
            jQuery(document).ready(function () {
                chamarAlert('Erro ao tentar atualizar seus dados!', closed);
            });
//                        location.replace("./meucadastro?acao=iniciar");
        </script>
        <%
                        }
                    }//if
                }//else
            }
        %>


        <link href="assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <meta name="viewport" content="width=device-width">
        <title>GW Trans - Perfil do usuário</title>
        <script src="${homePath}/script/shortcut.js" type="text/javascript"></script>
        <link rel="stylesheet" href="${homePath}/assets/css/easyui.css">
        <link rel="stylesheet" href="${homePath}/assets/css/consulta.css">
         <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${cfg.getTipoTema().getCor()}.css">
        <script language="javascript" type="text/javascript" src="${homePath}/script/funcoes_gweb.js"></script>
        <script src="${homePath}/assets/js/coluna_ajuda_sem_filtros.js" type="text/javascript"></script>
        <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <script src="${homePath}/script/validarSessao.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript">
            jQuery.noConflict();
            var codigoTela = 'T00007';

            function grava() {
                var nome = document.getElementById('nome');
                var login = document.getElementById('login');
                var email = document.getElementById('email');
                location.replace("./meucadastro?nome=" + nome.value + "&login=" + login.value + "&email=" + email.value + "&acao=alterar");
            }


            function recarregarVideos() {
                var iframes = jQuery(".container-video iframe");
                jQuery(jQuery('.container-video').find('div')).removeClass();
                jQuery(jQuery('.container-video').find('div')).addClass("col-md-6");
                jQuery(jQuery('.container-video').find('img')).css('right', '0');
                jQuery(iframes).css("max-width", "95%");
                jQuery(iframes).css("height", "100px");

            <c:forEach items="${listVideosTela}" var="video" varStatus="videoStatus">
                if (jQuery('#video${videoStatus.count}').prop('src') !== '${video.url}') {
                    jQuery('#video${videoStatus.count}').attr('src', '${video.url}');
                }
            </c:forEach>
            }

            var myConfObj = {
                iframeMouseOver: false
            };

            var containerVideo = null;

            window.addEventListener('blur', function () {
                if (myConfObj.iframeMouseOver) {
                    jQuery(containerVideo).trigger('change');
                }
            });

            window.setTimeout(function () {
                jQuery("#atual").val('');
            }, 1);

        </script>
        <script language="javascript" src="script/funcoes.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">
        <style>
            body,html,head { overflow-y: hidden; }
            body{
                background: url(${homePath}/assets/img/pattern_bg.png);
            }

            #logo{
                -webkit-box-shadow: 0px 1px 1px rgba(50, 50, 50, 0.75);
                -moz-box-shadow:    0px 1px 1px rgba(50, 50, 50, 0.75);
                box-shadow:         0px 1px 1px rgba(50, 50, 50, 0.75);
            }
        </style>
        <link href="assets/css/menu.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <div id="topo">
            <div id="logo">
                <h3>Perfil do Usuário<img src="${homePath}/assets/img/trans_white.png"></h3>
            </div>
            <div id="actions">
                <img id="logoCliente" width="68px" height="44px" src="">
                <ul>
                    <li>
                        <!--<a onclick="alterarSenha();" style="cursor: pointer;background: #135c82;" ><img width="14" height="19" style="" src="${homePath}/assets/img/senha-icon.png">Alterar Senha</a>-->
                        <span class='span-senha' onclick="checkSession(function () {
                    alterarSenha();
                }, false);"><img width="15" height="15" style="" src="${homePath}/assets/img/senha-icon.png">Alterar Senha</span>
                    </li>
                    <li>
                        <span class='span-senha' onclick="checkSession(function () {
                                    limparFiltros();
                                }, false);">
                            <img width="15" height="15" style="left: 173px;" src="${homePath}/assets/img/borracha.png">
                            Limpar Filtros
                        </span>
                    </li>
                </ul>
                <!--<a href="javascript:;"><img src="${homePath}/assets/img/icon-question.png" class="right question"></a>-->
            </div>
        </div>
        <div id="sidebar" class="heightDoc">
            <div class="columnRight">
                <button type="button" data-name="hide" id="toggle" name="toggleAjuda" style="margin-top: 105px !important;min-width: 150px !important;width:150px !important;border-radius: 5px !important;margin-left: -72px !important;" class="toogleOnAjuda">Mostrar Ajuda</button>
            </div>
            <style>#columnLeftAjuda::-webkit-scrollbar{display: none;-ms-overflow-style: none;overflow: auto;}</style>
            <div class="notificacao" style="top: 267px !important;margin-left: 26.2% !important;"><center><label>0</label></center></div>
            <div class="seta-conteudo-notificacao" style="top: 290px !important;margin-left: 26% !important;"></div>
            <div class="conteudo-notificacao" style="top: 300px !important;margin-left: 25.8% !important;">
                <div>
                    <span>Notificação</span>
                    <p>Existem videos novos relacionados a tela.</p>
                </div>
            </div>
            <div class="columnLeft user-column-left-ajuda" id="columnLeftAjuda" style="z-index: 9999;position: absolute;width:0px;">
                <style>
                    .aguarde{
                        display: none;
                        z-index: 999999;
                        position: absolute;
                        top: 15%;
                        margin-top: -70px;
                        left: 50%;
                        margin-left: -107px;
                        background: #E2E2E2;
                        padding: 10px 20px 10px 20px;
                        border-radius: 50px;
                        box-shadow: inset 0px 0px 1px 1px rgba(0,0,0,0.7);
                    }

                    .aguarde img{
                        float: left;
                        width: 50px;
                        margin-top: 5px;
                    }

                    .aguarde label{
                        float: left;
                        margin-left: 10px;
                        margin-top: 20px;
                        font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;
                        color: #666;
                        font-size: 17px;
                        font-weight: bold;
                    }

                </style>
                <div class="aguarde">
                    <img src="${homePath}/img/espere_new.gif" width="70px"><label>Carregando...</label>
                </div>
                <div class="cobre-left" style="width: 100%;height: 100%;background: rgba(0,0,0,0.7);z-index: 9999;position: absolute;display: none;"></div>
                <div class="content">
                    <form action="${homePath}/FilialControlador?acao=listarFilial">
                        <div class="item_form" style="margin-bottom: 5px;margin-top: 30px;">
                            <div class="helper">
                                <div class="corpo_helper">
                                    <label class="campo-helper" style="margin-left: 5px;"><h2>Ajuda</h2></label>
                                    <hr>
                                    <label class="descri-helper"><h3>Passe o mouse sobre o campo que deseja ajuda.</h3></label>
                                </div>
                            </div>
                        </div>
                        <div class="item_form" style="">
                            <div class="permissoes_tela">
                                <h3 class="h3-permissoes" style="">Permissões de acesso desta tela</h3>
                                <hr style="margin:5px;padding:0;">
                                <div class="col-md-12">
                                    <table class="table_permissao" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <th width="10%">Código</th>
                                                <th width="40%">Descrição</th>
                                                <th width="40%">Observação</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <c:if test="${fn:length(listVideosTela) > 0}">
                            <center class="div-lb-videos-ajuda"><h3 class="h3-video" style="">Vídeos de  Ajuda</h3></center>
                            <hr style="margin:5px;padding:0;">
                            <div class="item_form"  style="margin-bottom: 0px;">
                                <style>
                                    .overlay{
                                        position: absolute;
                                        background: transparent;
                                        height: 100px;
                                        width: 200px;
                                        /*margin-left: 60px;*/
                                        background: transparent;
                                        border-radius: 5px;
                                        z-index: 9999;
                                        opacity: 0.1;
                                        -moz-opacity: 0.1;
                                        filter: alpha(opacity=10);
                                        cursor: pointer;
                                        overflow: hidden;
                                    }
                                </style>
                                <div class="conteudo-videos-relacionados">
                                    <c:forEach items="${listVideosTela}" var="video" varStatus="videoStatus">
                                        <div class="container-video" id="container-video">
                                            <div class="col-md-6">
                                                <c:if test="${video.isNovo}">
                                                    <script>
                                                        addNotificacao();
                                                    </script>
                                                    <img src="assets/img/novo_video.png" alt=""/>
                                                </c:if>
                                                <c:if test="${!video.isNovo}">
                                                    <img src="assets/img/ja_visto.png" alt=""/>
                                                </c:if>
                                                <input type="hidden" value="${video.id}" name="idVideo${videoStatus.count}" id="idVideo${videoStatus.count}">
                                                <iframe src="${video.url}" id="video${videoStatus.count}" class="videos-tela" scrolling="no" frameborder="0" allowfullscreen></iframe>
                                            </div>
                                            <div class="col-md-6">
                                                <span class="texto-video">${video.titulo}<p>${video.descricao}</p></span>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                            <hr style="margin:0;padding:0;margin-bottom: 100px;">
                        </c:if>

                    </form>
                </div>
            </div>
        </div>
        <div id="map" class="heightDoc" style="overflow-y: hidden;width: 90%;">
            <div id="contentMap">
                <div class="dados-cadastrais">
                    <div class="topo-dados"><label class="label-topo">Dados do Cadastro</label></div>
                    <!--<div class="container">-->
                    <style>
                        .label-corpo{
                            margin-left: 10px;
                        }
                        .row{
                            background: #ededed;
                            overflow: hidden;
                        }
                    </style>
                    <div class="row">
                        <div class="col-md-12" style="margin-top: 5px;margin-bottom: 5px;padding-top: 12px;">
                            <img id="perfil-icon" src="img/usuario/default-perfil.png" style="border-radius: 50%;width: 45px;box-shadow: 0px 0px 2px 1px rgba(0,0,0,0.75);margin-left: 15px;" >
                            <span class="alt-foto" onclick="jQuery('.alter-foto-perfil').trigger('click');">Alterar foto de perfil</span>
                        </div>
                        <div class="col-md-12" style="border-top: 1px solid #ccc;padding-top: 7px;">
                            <div class="col-md-4">
                                <label class="label-corpo ativa-helper label-input-perfil" id="nomeLabel">Nome:</label>
                                <input name="nome" type="text" id="nome" value="<%=nome%>" size="45" maxlength="30" class="input-dados">
                            </div>
                            <div class="col-md-4">
                                <label class="label-corpo ativa-helper label-input-perfil" id="loginLabel">Login:</label>
                                <input name="login" type="text" id="login" value="<%=login%>" size="21" maxlength="30" class="input-dados">
                            </div>
                            <div class="col-md-4">
                                <label class="label-corpo ativa-helper label-input-perfil" id="emailLabel">E-mail:</label>
                                <input name="email" type="text" id="email" value="<%=email%>" size="50" maxlength="70" class="input-dados">
                            </div>
                        </div>
                        <div class="col-md-12" style="border-top: 1px solid #ccc;padding-bottom: 7px;padding-top: 9px;">
                            <label class="label-corpo ativa-helper label-input-perfil" id="filialLabel">Filial:</label>
                            <label class="label-corpo ativa-helper label-input-perfil" style="padding-left: 0px;margin-left: 10px;"><%=user.getFilial().getAbreviatura()%></label>
                        </div>
                        <div class="col-md-12" style="margin-top: 5px;margin-bottom: 5px;border-top: 1px solid #ccc;padding-top: 12px;padding-bottom: 12px;">
                            <button onClick="checkSession(function () {
                                        grava();
                                    }, false);" id="btnSalvar" style="padding: 0;margin-left:calc(50% - 150px);width: 130px;"><img width="14" height="19" style="" src="${homePath}/assets/img/salvar_new.png"><label>Salvar</label></button>
                        </div>
                    </div>
                    <div class="footer-dados"></div>

                </div>

                <div class="abas" id="tabs-1">
                    <div class="arrow_box"></div>
                    <input id="tab-1-1" name="tabs-group-1" type="radio" checked />
                    <label for="tab-1-1">Vídeos</label>
                    <div class="tab-content" style="overflow-y: scroll !important;max-height: 200px;">
                        <table class="tb-videos" id="tb-videos" name="tb-videos " cellspacing="0" cellpadding="0">
                            <thead style="border-collapse: separate;">
                                <tr>
                                    <td width="20%">Título</td>
                                    <td width="40%">Descrição</td>
                                    <td width="20%">Status</td>
                                    <td width="15%">Assistiu em</td>
                                    <td width="5%">Assistir</td>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${listVideos}" var="video" varStatus="videoStatus">
                                    <tr class='<c:if test="${video.isNovo}"> novo_video </c:if>'>
                                            <td>
                                            ${video.titulo}
                                        </td>
                                        <td>
                                            ${video.descricao}
                                        </td>
                                        <td>
                                            ${video.acaoUsuario != null ? (video.acaoUsuario == "p" ? ("Pulado") : ("Assistido")) : ("Pendente")}
                                        </td>
                                        <td>
                                            <c:if test="${video.acaoUsuario != null && video.acaoUsuario != 'p'}">
                                                <fmt:formatDate pattern="dd/MM/YYYY HH:MM" value="${video.dataHoraAcao}" />
                                            </c:if>
                                        </td>
                                        <td style="position: relative;">
                                            <img src="assets/img/glyphicons-174-play2_20x20.png" style="cursor:pointer;" title="Assistir" onclick="checkSession(function () {
                                                        assistirNovamente('${video.id}', '${video.descricao}', '${video.url}','${cfg.getTipoTema().getCor()}');
                                                    }, false);">
                                            <c:if test="${video.isNovo}">
                                                <img src="assets/img/novo_video.png" class="img-novo-tabela" alt=""/>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                        <div class="footer-dados"></div>
                    </div>
                </div>
            </div>
        </div>
                        
        <div class="div-mudar-senha">
            <div>
                <div class="topo-senha">
                    <img id="" width="110px" height="44px" src="assets/img/logo.png" style="float: left;"><label>Alteração de senha</label>
                    <img width="30px" class="img-senha-fechar" height="30px" src="assets/img/fechar_new.png" alt="" title="Fechar" onclick="checkSession(function () {
                                fecharAlterarSenha();
                            }, false);"/>
                </div>
                <div style="padding: 10px;background-image: url(${homePath}/assets/img/pattern_bg.png)">
                    <div class="dados-cadastrais">
                        <!--<div class="container">-->
                        <div class="row">
                            <form name="form1" method="post" action="./pass?acao=gravar">
                                <div class="col-md-12">
                                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 170px;">
                                        <span style="font-size: 16px;">Nome:</span><input type="hidden" value="Descrição: Nome do usuário cadastrado."></label>
                                    <label><%=user.getNome()%></label>
                                </div>
                                <div class="col-md-12">
                                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 170px;">
                                        <span style="font-size: 16px;">Senha atual:</span><input type="hidden" value="Descrição: Login do usuário cadastrado."></label>
                                    <input name="atual" type="password" id="atual" size="21" maxlength="13" style="height: 20px;width: 50%;" class="input-dados">
                                    <img src="img/mostrar-senha.png" id="mostrarSenhaAtual" class="mostrar-senha" alt=""/>
                                </div>
                                <div class="col-md-12">
                                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 170px;">
                                        <span style="font-size: 16px;">Nova senha:</span><input type="hidden" value="Descrição: E-mail do usuário cadastrado."></label>
                                    <input name="nova" type="password" id="nova" size="21" maxlength="13" style="height: 20px;width: 50%;" class="input-dados">
                                    <img src="img/mostrar-senha.png" id="mostrarSenhaNova" class="mostrar-senha" alt=""/>
                                </div>
                                <div class="col-md-12">
                                    <label class="label-corpo ativa-helper" style="display: inline-block;width: 170px;">
                                        <span style="font-size: 16px;">Repetir Nova senha:</span><input type="hidden" value="Descrição: E-mail do usuário cadastrado.">
                                    </label>
                                    <input name="nova2" type="password" id="nova2" size="21" maxlength="13" style="height: 20px;width: 50%;" class="input-dados">
                                    <img src="img/mostrar-senha.png" id="mostrarRepetirSenhaNova" class="mostrar-senha" alt=""/>
                                </div>
                            </form>
                        </div>
                        <!--</div>-->
                        <div style="padding-top: 10px;width: 100%;text-align: center;">
                            <button id="btnSalvar" name="btnSalvar" style="padding: 0;margin:0;width: 130px;" onclick="checkSession(function () {
                                        gravar();
                                    }, false);"><img width="14" height="19" style="" src="${homePath}/assets/img/salvar_new.png"><label>Gravar</label></button>
                            <button id="btnSalvar" name="btnCancelar" style="padding: 0;margin:0;width: 130px;" onclick="checkSession(function () {
                                        fecharAlterarSenha();
                                    }, false);"><img width="20" height="20" style="" src="${homePath}/assets/img/fechar.png"><label>Cancelar</label></button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footer-senha"></div>
        </div>
        <div class="div-tela-toda"></div>
        <div id="htmlVideo"></div>
        <!--<img class="gif-bloq-tela" src="${homePath}/img/espere_novo.gif" alt=""/>-->
        <div class="bloqueio-tela"></div>
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js"></script>
        <script src="${homePath}/assets/js/jquery-ui.min.js" type="text/javascript"></script>
        <script src="${homePath}/assets/js/jquery.easyui.min.js"></script>
        <script src="${homePath}/assets/js/jquery.mask.min.js"></script>

        <!--<script src="${homePath}/assets/js/sorttable.js" type="text/javascript"></script>-->
        <script type='text/javascript' lang="JavaScript">
                               
                                function alterarSenha() {
                                    $(".div-tela-toda").css("display", "block");
                                    $(".div-mudar-senha").css("display", "block");
                                    $(".div-mudar-senha").animate({
                                        opacity: 1.0
                                    });

                                    $(".div-tela-toda").animate({
                                        opacity: 0.6
                                    });

                                }

                                function fecharAlterarSenha() {
                                    $(".div-mudar-senha").animate({
                                        opacity: 0.0
                                    }, function () {
                                        $(".div-mudar-senha").css("display", "none");
                                    });
                                    $(".div-tela-toda").animate({
                                        opacity: 0.0
                                    }, function () {
                                        $(".div-tela-toda").css("display", "none");
                                    });

                                    $("#atual").value = "";
                                    $("#nova").value = "";
                                    $("#nova2").value = "";

                                }

                                function AdicionarFiltro(tabela, coluna) {
                                    var cols = jQuery("#" + tabela + " thead tr:first-child th").length;
                                    if (jQuery("#" + tabela + " thead tr").length == 1) {
                                        var linhaFiltro = "<tr>";
                                        for (var i = 0; i < cols; i++) {
                                            linhaFiltro += "<th></th>";
                                        }
                                        linhaFiltro += "</tr>";

                                        jQuery("#" + tabela + " thead").append(linhaFiltro);
                                    }

                                    var colFiltrar = jQuery("#" + tabela + " thead tr:nth-child(1) td:nth-child(" + coluna + ")");
                                    jQuery(colFiltrar).html(jQuery(colFiltrar).html() + "<select id='filtroColuna_" + coluna.toString() + "'  class='filtroColuna'> </select><strong class='strong-filtro'>Filtrar por:</strong>");

                                    var valores = new Array();

                                    jQuery("#" + tabela + " tbody tr").each(function () {
                                        var txt = jQuery(this).children("td:nth-child(" + coluna + ")").text();
                                        if (valores.indexOf(txt) < 0) {
                                            valores.push(txt);
                                        }
                                    });
                                    jQuery("#filtroColuna_" + coluna.toString()).append("<option>Todos</option>")
                                    for (elemento in valores) {
                                        jQuery("#filtroColuna_" + coluna.toString()).append("<option>" + valores[elemento] + "</option>");
                                    }

                                    jQuery("#filtroColuna_" + coluna.toString()).change(function () {
                                        var filtro = jQuery(this).val();
                                        jQuery("#" + tabela + " tbody tr").show();
                                        if (filtro != "Todos") {
                                            jQuery("#" + tabela + " tbody tr").each(function () {
                                                var txt = jQuery(this).children("td:nth-child(" + coluna + ")").text();
                                                if (txt.trim() != filtro) {
                                                    jQuery(this).hide();
                                                }
                                            });
                                        }
                                    });

                                }
                                ;

                                jQuery(document).ready(function () {
                                    AdicionarFiltro('tb-videos', 3);


                                    window.alert = function (e) {
                                        chamarAlert(e, null);
                                        return false;
                                    };

                                    $("#atual").focusin(function () {
                                        $("#mostrarSenhaAtual").css("display", "inline");
                                    });
                                    $("#atual").focusout(function () {
                                        $("#mostrarSenhaAtual").css("display", "none");
                                    });

                                    $("#nova").focusin(function () {
                                        $("#mostrarSenhaNova").css("display", "inline");
                                    });
                                    $("#nova").focusout(function () {
                                        $("#mostrarSenhaNova").css("display", "none");
                                    });

                                    $("#nova2").focusin(function () {
                                        $("#mostrarRepetirSenhaNova").css("display", "inline");
                                    });
                                    $("#nova2").focusout(function () {
                                        $("#mostrarRepetirSenhaNova").css("display", "none");
                                    });


                                    $("#mostrarSenhaAtual").mouseenter(function () {
                                        $("#atual").attr("type", "text");
                                    });
                                    $("#mostrarSenhaAtual").mouseout(function () {
                                        $("#atual").attr("type", "password");
                                    });

                                    $("#mostrarSenhaNova").mouseenter(function () {
                                        $("#nova").attr("type", "text");
                                    });
                                    $("#mostrarSenhaNova").mouseout(function () {
                                        $("#nova").attr("type", "password");
                                    });

                                    $("#mostrarRepetirSenhaNova").mouseenter(function () {
                                        $("#nova2").attr("type", "text");
                                    });
                                    $("#mostrarRepetirSenhaNova").mouseout(function () {
                                        $("#nova2").attr("type", "password");
                                    });

                                    $("#btnSalvar").hover(
                                            function () {
                                                $("#img-salvar").attr("src", "${homePath}/assets/img/aceitar_novo_hover.png");
                                            },
                                            function () {
                                                $("#img-salvar").attr("src", "${homePath}/assets/img/aceitar_novo.png");
                                            }
                                    );


                                    var heightDoc = $(window).height();

                                    $("#paneConsulta").css('height', heightDoc - 250);


                                    $(".heightDoc").css('height', heightDoc);
                                    $(".contentMap").css('height', heightDoc - 200);

                                    jQuery('.perfil-user').hide();
                                    setTimeout(function () {
                                        jQuery('#perfil-icon').attr('src', jQuery('.img-perfil-icon').attr('src'));
                                    }, 1000);
                                });


                                var nomeLogoCliente = '';
                                if (nomeLogoCliente !== 'null' && nomeLogoCliente != '') {
                                    jQuery("#logoCliente").attr("src", "img/logoCliente/" + nomeLogoCliente);
                                    jQuery("#logoClienteSenha").attr("src", "img/logoCliente/" + nomeLogoCliente);
                                } else {
                                    jQuery("#logoCliente").attr("src", "assets/img/gw-sistemas.png");
                                    jQuery("#logoClienteSenha").attr("src", "assets/img/gw-sistemas.png");
                                }

                                // parametros:
                                // ação: para abrir o video escolhido
                                // retorno : não tem retorno, apenas irá abrir o video novamente
                                function assistirNovamente(videoId, videoDescricao, urls) {
                                    jQuery.ajax({
                                        url: "layoutVideo.jsp",
                                        dataType: "text",
                                        method: "post",
                                        async: false,
                                        data: {
                                            idVideo: videoId,
                                            descricao: videoDescricao,
                                            url: urls,
                                            nome: '<%=user.getNome()%>',
                                            
                                        },
                                        success: function (data) {
                                            jQuery("#htmlVideo").html(data);
                                            jQuery.noConflict();
                                        },
                                        error: function (e) {
                                            console.log(e);
                                        }
                                    });
                                }

                                function check() {
                                    if (document.form1.atual.value == "" ||
                                            document.form1.nova.value == "" ||
                                            document.form1.nova2.value == "") {
                                        chamarAlert("Preencha os campos corretamente!", null);
                                        return false;
                                    } else {
                                        if (document.form1.nova.value != document.form1.nova2.value) {
                                            chamarAlert('Os campos "Nova senha" e "Repetir nova senha" devem ter valores iguais!', null);
                                            return false;
                                        } else {
                                            return true;
                                        }
                                    }
                                }

                                function gravar() {
                                    if (check()) {
                                        mudarSenha(document.form1.nova.value, document.form1.atual.value);
                                    }
                                }

                                function mudarSenha(nova, atual) {
                                    $.ajax({
                                        url: "UsuarioControlador?acao=mudarSenha&nova=" + nova + "&atual=" + atual,
                                        type: 'GET',
                                        dataType: 'text/html',
                                        beforeSend: function () {
                                            jQuery(".gif-bloq-tela").css("display", "block");
                                            jQuery(".bloqueio-tela").css("display", "block");
                                        },
                                        error: function (e) {
                                            var resposta = e.responseText;
                                            console.log(resposta);

                                            if (e.responseText == 1) {
                                                chamarAlert('Sua senha foi alterada corretamente!', closed);
                                            }
                                            if (e.responseText == 2) {
                                                chamarAlert('Erro ao tentar alterar sua senha!', closed);
                                            }
                                            if (e.responseText == 3) {
                                                chamarAlert('A senha atual não confere!', closed);
                                            }
                                        },
                                        complete: function () {
                                            jQuery(".gif-bloq-tela").css("display", "none");
                                            jQuery(".bloqueio-tela").css("display", "none");
                                        }
                                    });
                                }

                                function closed() {
                                    window.close();
                                }

                                function limparFiltros() {
                                    chamarConfirm('Atenção, essa ação irá remover todos os filtros salvos para o seu usuário nas telas de consultas do sistema. Ao entrar nas telas, novos filtros serão salvos. Deseja continuar ? ',
                                            'confirmarLimparFiltros()', null);
                                }
                                function confirmarLimparFiltros() {
                                    jQuery.ajax({
                                        url: "UsuarioControlador?acao=limparFiltrosUsuario",
                                        dataType: "text",
                                        method: "post",
                                        complete: function (jqXHR, textStatus) {
                                            if (jqXHR.responseText == '1') {
                                                chamarAlert('Filtros apagados com sucesso!', null);
                                            } else {
                                                chamarAlert('Erro ao tentar apagar os filtros', null);
                                            }
                                        }
                                    });
                                }
        </script>
    </body>
    <script type="text/javascript" src="script/validarSessao.js"></script>
    <jsp:include page="/perfil_usuario_model.jsp"></jsp:include>
</html>