<%@page import="br.com.gwsistemas.configuracoesTecnicas.ConfiguracaoTecnica"%>
<%@page import="br.com.gwsistemas.configuracoesTecnicas.ConfiguracaoTecnicaDAO"%>
<%@page import="br.com.gwsistemas.anuncio.AnuncioBO"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.video.VideoBO"%>
<%@page import="br.com.gwsistemas.video.Video"%>
<%@page import="br.com.gwsistemas.eutil.NivelAcessoUsuario"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="usuario.BeanUsuario"%>
<%@page import="nucleo.Apoio"%>
<%@page import="java.util.ArrayList"%>
<%@page import="br.com.gwsistemas.gwi.UsuarioGWi"%>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<c:set var='userConnected' value='false'/>
<%
    //Carregando as configuraões independente da ação - teste fork
    BeanUsuario user = Apoio.getUsuario(request);
    if (user != null) {
        if (getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS") != null && !getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS").equals("" + HttpServletResponse.SC_OK)) {
            request.setAttribute("mensagemErroLicense", "STATUS " + getServletContext().getAttribute("WEBTRANS_LICENSE_STATUS") + " - " + getServletContext().getAttribute("WEBTRANS_MESSAGE"));
        }

        request.setAttribute("configTecnica", getServletContext().getAttribute("configTecnica"));
        request.setAttribute("user", user);
        request.setAttribute("cfg", Apoio.getConfiguracao(request));
        request.setAttribute("permissoes", getServletContext().getAttribute("todasPermissoes"));

        //iniciando a parte de validação de licenças:
        request.setAttribute("isLicencaFinan", user.isIsLicencaFinan());
        request.setAttribute("isLicencaLogis", user.isIsLicencaLogis());
        request.setAttribute("isLicencaFrota", user.isIsLicencaFrota());
        request.setAttribute("isLicencaLoc", user.isIsLicencaLoc());
        request.setAttribute("isLicencaCRM", user.isIsLicencaCRM());
        request.setAttribute("isLicencaMobile", user.isIsLicencaMobile());
        request.setAttribute("isModuloReduzido", user.isIsModuloReduzido());

        //setando o nivelacessousuario
        request.setAttribute("nivelSemAcesso", NivelAcessoUsuario.SEM_ACESSO.getNivel());
        request.setAttribute("nivelLerAlterar", NivelAcessoUsuario.LER_ALTERAR.getNivel());
        request.setAttribute("nivelLerAlterarIncluir", NivelAcessoUsuario.LER_ALTERAR_INCLUIR.getNivel());
        request.setAttribute("nivelLer", NivelAcessoUsuario.LER.getNivel());

        VideoBO vbo = new VideoBO();
        Collection<Video> listVideosTela = vbo.carregarVideosTela(user, 4);
        request.setAttribute("videosTela", listVideosTela);

        if (user.isIsLicencaMobile() && user != null && user.getFilial() != null) {
            request.setAttribute("linkMobile", "http://gwmobile" + (user.getFilial().getTipoUtilizacaoGWMobile().equalsIgnoreCase("p") ? "" : "-homolog") + ".gwcloud.com.br/signin/" + user.getFilial().getTokenGwMobile());
        } else {
            request.setAttribute("linkMobile", "#");
        }

        AnuncioBO anuncioBO = new AnuncioBO();
        request.setAttribute("anuncio", anuncioBO.buscarAnuncios(4, user.getId()));

        Collection<String> cnpjClientesGWi = new ArrayList<>();
        
        for (UsuarioGWi usuarioGWi : user.getClientesGWi()) {
            cnpjClientesGWi.add(usuarioGWi.getCnpjCliente());
        }
        
        request.setAttribute("cnpjClientesGWi", String.join(",", cnpjClientesGWi));        
        request.setAttribute("versao", Apoio.WEBTRANS_VERSION);
    }
%>
<c:if test="${user == null}">
    <c:redirect url="/login"/>
</c:if>
<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
        <jsp:include page="importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <meta charset="ISO-8859-1">
        <meta name="viewport" content="width=device-width">
        <title>GW Sistemas - Home</title>
        <!-- CSS -->
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${cfg.getTipoTema().getCor()}.css?v=${random.nextInt()}">
        <link href="${homePath}/assets/css/menu.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/assets/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/anuncios/css-anuncios/anuncio.css" rel="stylesheet" type="text/css"/>
        <!-- FIM CSS -->
    </head>
    <body onload="recarregarPendencias();">
        <header class="h-a">
            <div class="menu-mobile"></div>
            <div class="container-menu-mobile">
                <div class="container-menu-mobile-topo">
                    <label>${user.nome}</label>
                    <label>${user.email}</label>
                </div>
                <div class="container-menu-mobile-corpo">
                    <ul class="ul-mod-mobile">
                        <li>
                            <a class="mod-trans-selecionado">
                            </a>
                        </li>
                        <li>
                            <a class="mod-finan" acessoModulo="${isLicencaFinan}">
                            </a>
                        </li>
                        <li>
                            <a class="mod-logis" acessoModulo="${isLicencaLogis}">
                            </a>
                        </li>
                        <li>
                            <a class="mod-frota" acessoModulo="${isLicencaFrota}">
                            </a>
                        </li>
                        <li>
                            <a class="mod-mobile" acessoModulo="${isLicencaMobile && (linkMobile!='#')}" href="${linkMobile}">
                            </a>
                        </li>
                        <li>
                            <a class="mod-loc" acessoModulo="${isLicencaLoc}">
                            </a>
                        </li>
                        <li>
                            <a class="mod-crm" acessoModulo="${isLicencaCRM && user.isIsUsuarioCrm()}">
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="container-menu-mobile-footer">
                    <ul>
                        <li>
                            <strong>Dúvidas, sugestão ou reclamações:</strong>
                            <small>faleconosco@gwsistemas.com.br</small>
                            <small class="small-versao">Versão : ${versaoAtual}</small>
                        </li>
                        <li><img src="${homePath}/assets/img/icon-logout-escuro.png"><label>Desconectar</label></li>
                    </ul>
                </div>
            </div>

            <div class="h-a-logos">
                <a>
                    <span acessoGweb=""></span>
                </a>
                <a href="${nomeLogoCliente == null || nomeLogoCliente == '' ? './config?acao=editar&aba=preferencias' : '#'}">
                    <span nomeLogoCliente="${nomeLogoCliente}"></span>
                    <label class="config-logo">Selecione uma logo</label>
                </a>

            </div>
            <ul class="ul-mod">
                <li>
                    <span class="seta-baixo-modulos"></span>
                    <a class="mod-trans-selecionado">
                    </a>
                </li>
                <li>
                    <a class="mod-finan" acessoModulo="${isLicencaFinan}" >
                    </a>
                </li>
                <li>
                    <a class="mod-logis" acessoModulo="${isLicencaLogis}" >
                    </a>
                </li>
                <li>
                    <a class="mod-frota" acessoModulo="${isLicencaFrota}" >
                    </a>
                </li>
                <li>
                    <a class="mod-mobile" acessoModulo="${isLicencaMobile && (linkMobile!='#')}" href="${linkMobile}">
                    </a>
                </li>
                <li>
                    <a class="mod-loc" acessoModulo="${isLicencaLoc}" >
                    </a>
                </li>
                <li>
                    <a class="mod-crm" acessoModulo="${isLicencaCRM && user.isIsUsuarioCrm()}" >
                    </a>
                </li>
            </ul>
                    <img class="menu-item-link" id="menu-item" src="${homePath}/assets/img/mobile-menu.png" >
            <div class="seta-menu-item"></div>
            <div class="seta-menu-item-sombra"></div>
            <div class="menu-item-container">
                <div class="col-md-12"><label style="font-size: 20px;font-weight: bold;color: #666;" class="lb-modulos"  >- Mais Módulos</label><hr></div>
                <div class="modulos-container">
                    <div class="col-md-4" onclick="abrirGerenciadorGWi('${configTecnica.linkGWi}', '${user.getFilial().getTokenGWi()}', '${cnpjClientesGWi}', '${user.isUsuarioGWi()}')">
                        <center style="padding: 5px;">  
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/gw-gwi-icone.jpg">
                            <label class="descricao-item-parceiro">GW-i</label>
                        </center>
                    </div>
                </div>
                <div class="col-md-12"><label style="font-size: 20px;font-weight: bold;color: #666;" class="lb-parceiros"  >- Parceiros</label><hr></div>
                <div class="modulos-container" style="" >
                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoCfe() == new String("P").toCharArray()[0] ? "openInNewTab('www.roadcard.com.br/sistemapamcard/')" : "openInNewTab('https://www1.roadcard.com.br/')")%>">
                        <center style="padding: 5px;">  
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/logo-pamcard-login.png">
                            <label class="descricao-item-parceiro">Pamcard</label>
                        </center>
                    </div>

                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoCfe() == new String("D").toCharArray()[0] ? "openInNewTab('https://web.nddcargo.com.br/portalnddcargo/')" : "openInNewTab('http://www.nddcargo.com.br/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/nddcargo.png">
                            <label class="descricao-item-parceiro">nddCargo</label>
                        </center>
                    </div>

                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoCfe() == new String("R").toCharArray()[0] ? "openInNewTab('https://www.repom.com.br/repom-login-home/index.html')" : "openInNewTab('http://www.repom.com.br/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/repom.png">
                            <label class="descricao-item-parceiro">Repom</label>
                        </center>
                    </div>

                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoCfe() == new String("E").toCharArray()[0] ? "openInNewTab('https://sistema.efrete.com/Account/LogOn')" : "openInNewTab('http://www.efrete.com/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/efrete.jpg">
                            <label class="descricao-item-parceiro">E-frete</label>
                        </center>
                    </div>

                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoCfe() == new String("D").toCharArray()[0] ? "openInNewTab('https://www.pagbem.com.br/')" : "openInNewTab('https://www.pagbem.com.br/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/logo_Pagbem.png">
                            <label class="descricao-item-parceiro">PagBem</label>
                        </center>
                    </div>

                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoCfe() == 'A'
                            ? (user.getFilial().isHomologacaoCfe()
                                ? "openInNewTab('https://dev.transportesbra.com.br/ssonegocio/Default.aspx')"
                                : "openInNewTab('https://www.transportesbra.com.br/ssonegocio/Default.aspx')")
                            : "openInNewTab('http://targetmp.com.br/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/target.png">
                            <label class="descricao-item-parceiro">Target</label>
                        </center>
                    </div>
                    <div class="col-md-4" onclick="<%=(user.getFilial().getStUtilizacaoFusionTrakRoteirizador() != 'N'
                                ? "openInNewTab('http://www.fusiontrak.com.br/login.html')"
                            : "openInNewTab('http://www.fusiontrak.com.br/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="width: 50px;height: 50px;"
                                 src="${homePath}/assets/img/parceiros/logo_fusion.png">
                            <label class="descricao-item-parceiro">Fusion Trak</label>
                        </center>
                    </div>
                    <div class="col-md-4" onclick="<%=(user.getFilial().getFilialGerenciadorRisco().getStUtilizacao() != 0 && user.getFilial().getFilialGerenciadorRisco().getGerenciadorRisco().getId() == 4
                                ? "openInNewTab('http://sistemauppergr.com.br/singularlog/')"
                            : "openInNewTab('http://www.grupouppergr.com.br/')")%>">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="width: 50px;height: 50px;"
                                 src="${homePath}/assets/img/parceiros/logo_upper.png">
                            <label class="descricao-item-parceiro">UpperGR</label>
                        </center>
                    </div>
                </div>

                <div class="col-md-12"><label style="font-size: 20px;font-weight: bold;color: #666;" class="lb-outros"  >- Outros</label><hr></div>
                <div class="modulos-container">
                    <div class="col-md-4" onclick="openInNewTab('http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=')">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/CTe.png">
                            <label class="descricao-item-parceiro">Consultar CT-e</label>
                        </center>
                    </div>
                    <div class="col-md-4" onclick="openInNewTab('http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=')">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/NFe.png">
                            <label class="descricao-item-parceiro">Consultar NF-e</label>
                        </center>
                    </div>
                    <div class="col-md-4" onclick="openInNewTab('https://mdfe-portal.sefaz.rs.gov.br/')">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/MDF_e.jpg">
                            <label class="descricao-item-parceiro">Consultar MDF-e</label>
                        </center>
                    </div>
                    <div class="col-md-4" onclick="openInNewTab('http://consultapublicarntrc.antt.gov.br/consultapublica')">
                        <center style="padding: 5px;">
                            <img class="item-menu" style="border-radius: 50%;width: 50px;height: 50px;" src="${homePath}/assets/img/parceiros/antt.png">
                            <label class="descricao-item-parceiro">ANTT</label>
                        </center>
                    </div>
                    <!--<div class="col-md-4"><center><img class="item-menu" src="${homePath}/assets/img/gw-crm.png"></center></div>-->
                </div>
            </div>
            <div class="cobre-tudo" id="cobre-tudo-menu-item" style=""></div>
        </header>
        <nav class="nav-a">
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal">
                        <label>Cadastros</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li class="li-sub-menu width-265"  isModuloReduzido="true">
                                <div class="container-label-menu">Financeiro<span class="seta-lado"></span></div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso('cadhist') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadhist") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadhist")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=15" id="historico_listar"><div class="container-label-menu">Histórico<img src="${homePath}/assets/img/add-novo.png" href="./cadhistorico?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadfornecedor') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadfornecedor") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfornecedor")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=14" id="fornecedor_listar"><div class="container-label-menu">Fornecedores<img src="${homePath}/assets/img/add-novo.png" href="./cadfornecedor?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadconta') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadconta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadconta")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=19" id="conta_listar"><div class="container-label-menu">Contas bancárias/caixas<img src="${homePath}/assets/img/add-novo.png" href="./cadconta?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadplanocusto') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadplanocusto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadplanocusto")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=21" id="consulta"><div class="container-label-menu">Plano Centro de Custo<img src="${homePath}/assets/img/add-novo.png" href="./cadplanocusto?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadundcusto') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadundcusto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadundcusto")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=17" id="consulta"><div class="container-label-menu">Unidades de custos<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=123" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadrateio') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadrateio") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadrateio")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=18" id="consulta"><div class="container-label-menu">Rateios<img src="${homePath}/assets/img/add-novo.png" href="RateioControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <c:if test="${cfg.getIsContabil()}">
                                        <li acessoMenu="${user.getAcesso('cadplanocontas') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadplanocontas") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadplanocontas")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=22" id="consulta"><div class="container-label-menu">Plano de contas<img src="${homePath}/assets/img/add-novo.png" href="./cadplano_contas.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            </c:if>
                                    <li acessoMenu="${user.getAcesso('cadespecie') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadespecie") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadespecie")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=23" id="consulta"><div class="container-label-menu">Espécies (Despesas)<img src="${homePath}/assets/img/add-novo.png" href="./cadespecie.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadformapagamento') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadformapagamento") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadformapagamento")}" class="validarSessaoMenu" href="./cadFormaPagamento.jsp?acao=iniciarEditar" id="consulta"><div class="container-label-menu">Forma de Pagamento</div></li>
                                </ul>
                            </li>
                            <li class="li-sub-menu width-265">
                                <div class="container-label-menu">Operacional<span class="seta-lado"></span></div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso('cadmotorista') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadmotorista") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadmotorista")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=60" id="consulta"><div class="container-label-menu">Motoristas<img src="${homePath}/assets/img/add-novo.png" href="./cadmotorista?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li>
                                        <div class="container-label-menu">Veículos<span class="seta-lado"></span></div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso('cadveiculo') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadveiculo") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadveiculo")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=56" id="consulta"><div class="container-label-menu">Cadastro de Veículos<img src="${homePath}/assets/img/add-novo.png" href="./cadveiculo?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadproprietario') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadproprietario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadproprietario")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=55" id="consulta"><div class="container-label-menu">Proprietários<img src="${homePath}/assets/img/add-novo.png" href="./cadproprietario?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadmarca') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadmarca") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadmarca")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=54" id="consulta"><div class="container-label-menu">Marcas<img src="${homePath}/assets/img/add-novo.png" href="ConsultaControlador?codTela=54" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadtipoveiculo') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadtipoveiculo") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipoveiculo")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=53" id="consulta"><div class="container-label-menu">Tipos de Veículos<img src="${homePath}/assets/img/add-novo.png" href="./cadtipo_veiculos.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </ul>
                                    </li>
                                    <li  isModuloReduzido="false"><div class="container-label-menu">Serviços<span class="seta-lado"></span></div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso('cadtipo_servico') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipo_servico") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipo_servico")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=51" id="consulta"><div class="container-label-menu">Cadastro de Serviços<img src="${homePath}/assets/img/add-novo.png" href="./cadservico.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadtipo_servico') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipo_servico") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipo_servico")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=50" id="consulta"><div class="container-label-menu">Grupos de Serviços (NFS-e)<img src="${homePath}/assets/img/add-novo.png" href="GrupoServicoNfseControladador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </ul>
                                    </li>
                                    <li acessoMenu="${user.getAcesso('cadrota') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadrota") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadrota")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=47" id="consulta"><div class="container-label-menu">Rotas<img src="${homePath}/assets/img/add-novo.png" href="./cadrota.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadnegociacaocontrato') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadnegociacaocontrato") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadnegociacaocontrato")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=46" id="consulta"><div class="container-label-menu" style="">Negociações Adiantamentos<p style="margin: 0!important;">de Fretes</p><img src="${homePath}/assets/img/add-novo.png" href="NegociacaoAdiantamentoFreteControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadsetorentrega') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadsetorentrega") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadsetorentrega")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=45" id="consulta"><div class="container-label-menu">Setores de Entregas<img src="${homePath}/assets/img/add-novo.png" href="SetorEntregaControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadocorrencia') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadocorrencia") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadocorrencia")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=44" id="consulta"><div class="container-label-menu">Ocorrências (EDI)<img src="${homePath}/assets/img/add-novo.png" href="./cadocorrencia.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadobservacao') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadobservacao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadobservacao")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=43" id="consulta"><div class="container-label-menu">Observações<img src="${homePath}/assets/img/add-novo.png" href="./cadobservacao.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li isModuloReduzido="false"><div class="container-label-menu"><span class="seta-lado"></span>Container</div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso('cadnavio') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadnavio") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadnavio")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=42" id="consulta"><div class="container-label-menu">Navios<img src="${homePath}/assets/img/add-novo.png" href="./cadnavio.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadterminal') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadterminal") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadterminal")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=41" id="consulta"><div class="container-label-menu">Terminal<img src="${homePath}/assets/img/add-novo.png" href="ConsultaControlador?codTela=41" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadtipocontainer') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipocontainer") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipocontainer")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=40" id="consulta"><div class="container-label-menu">Tipo de container<img src="${homePath}/assets/img/add-novo.png" href="ConsultaControlador?codTela=40" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </ul>
                                    </li>
                                    <li  isModuloReduzido="false"><div class="container-label-menu">Produtos<span class="seta-lado"></span></div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso('cadprodutotrans') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadprodutotrans") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadprodutotrans")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=39" id="consulta"><div class="container-label-menu">Cadastro de Produtos<img src="${homePath}/assets/img/add-novo.png" href="./ProdutoControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadundtrans') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadundtrans") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadundtrans")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=38" id="consulta"><div class="container-label-menu">Unidades de Medida<img src="${homePath}/assets/img/add-novo.png" href="UnidadeMedidaControlador?acao=novoCadastro&modulo=gwFrota" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadEmbalagem') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadEmbalagem") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadEmbalagem")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=37" id="consulta"><div class="container-label-menu">Embalagem<img src="${homePath}/assets/img/add-novo.png" href="./EmbalagemControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </ul>
                                    </li>
                                    <li  isModuloReduzido="false"><div class="container-label-menu">Outros<span class="seta-lado"></span></div>
                                        <ul  class="cima">
                                            <li acessoMenu="${user.getAcesso('cadfuncoes') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadfuncoes") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfuncoes")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=36" id="consulta"><div class="container-label-menu">Funções (Marítimo)<img src="${homePath}/assets/img/add-novo.png" href="./cadfuncao.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadtipopallettransp') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipopallettransp") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipopallettransp")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=35" id="consulta"><div class="container-label-menu">Tipos de Pallets<img src="${homePath}/assets/img/add-novo.png" href="./TipoPalletControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadaeroporto') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadaeroporto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadaeroporto")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=34" id="consulta"><div class="container-label-menu">Aeroportos<img src="${homePath}/assets/img/add-novo.png" href="./AeroportoControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadporto') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadporto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadporto")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=33" id="consulta"><div class="container-label-menu">Portos<img src="${homePath}/assets/img/add-novo.png" href="./PortoControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadcategoriacarga') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadcategoriacarga") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcategoriacarga")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=72" id="consulta"><div class="container-label-menu">Categorias de Cargas<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=76" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadConferente') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadConferente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadConferente")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=73" id="consulta"><div class="container-label-menu">Conferente de Cargas<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=77" class="validarSessaoMenu" id="cadastrar"></div></li>  
                                            <li acessoMenu="${user.getAcesso('cadPontoControle') > nivelSemAcesso && isLicencaMobile}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadPontoControle") > nivelLerAlterar && isLicencaMobile}" codigoPermissao="${permissoes.get("cadPontoControle") && isLicencaMobile}" class="validarSessaoMenu" href="./PontoControleControlador?acao=listar" id="consulta"><div class="container-label-menu">Pontos de Controle<img src="${homePath}/assets/img/add-novo.png" href="./PontoControleControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                            <li acessoMenu="${user.getAcesso('cadiscas') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadiscas") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadiscas")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=138" id="consulta"><div class="container-label-menu">Iscas<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=139" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </ul>
                                    </li>
                                </ul>
                            </li>
                            <li class="li-sub-menu width-265" isModuloReduzido="false">
                                <div class="container-label-menu">Comercial<span class="seta-lado"></span></div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso('cadtabelacliente') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtabelacliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtabelacliente")}" class="validarSessaoMenu" href="./consulta_tabelacliente.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Tabelas de Preços<img src="${homePath}/assets/img/add-novo.png" href="./cadtabela_preco.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadarea') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadarea") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadarea")}" class="validarSessaoMenu" href="./consulta_area.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Áreas<img src="${homePath}/assets/img/add-novo.png" href="./cadarea.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadtipoproduto') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipoproduto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipoproduto")}" class="validarSessaoMenu" href="./consulta_tipoproduto.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Tipos de Produtos/Operações<img src="${homePath}/assets/img/add-novo.png" href="./cadtipoproduto.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadfaixa') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadfaixa") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfaixa")}" class="validarSessaoMenu" href="./consulta_faixapeso.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Faixas de Peso<img src="${homePath}/assets/img/add-novo.png" href="./cadfaixapeso.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadorigemcaptacao') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadorigemcaptacao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadorigemcaptacao")}" class="validarSessaoMenu" href="./OrigemCaptacaoControlador?acao=listar" id="consulta"><div class="container-label-menu">Origem de Captação<img src="${homePath}/assets/img/add-novo.png" href="./cadastrar_origem_captacao_cliente.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('cadtabelacliente') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtabelacliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtabelacliente")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=70" id="consulta"><div class="container-label-menu">Tabelas Adicionais TDE<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=78&modulo=cadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso('contratocomercial') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("contratocomercial") > nivelLerAlterar}" codigoPermissao="${permissoes.get("contratocomercial")}" class="validarSessaoMenu" href="ConsultaControlador?codTela=79" id="consulta"><div class="container-label-menu">Contratos Comerciais<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=80" class="validarSessaoMenu" id="cadastrar"></div></li>
                                </ul>
                            </li>
                            <li acessoMenu="${user.getAcesso('cadcliente') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadcliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcliente")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=10" id="consulta"><div class="container-label-menu">Clientes<img src="${homePath}/assets/img/add-novo.png" href="./cadcliente?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('cadgrupo_cli_for') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadgrupo_cli_for") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadgrupo_cli_for")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=16" id="consulta"><div class="container-label-menu">Grupo Clientes / Fornecedores<img src="${homePath}/assets/img/add-novo.png" href="./cadgrupo_cli_for.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('cadbairro') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadbairro") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadbairro")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=65" id="consulta"><div class="container-label-menu">Bairros<img src="${homePath}/assets/img/add-novo.png" href="BairroControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('cadcidade') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadcidade") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcidade")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=64" id="consulta"><div class="container-label-menu">Cidades<img src="${homePath}/assets/img/add-novo.png" href="${homePath}/CadastroControlador?codTela=102&modulo=cadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('cadusuario') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadusuario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadusuario")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=62" id="consulta"><div class="container-label-menu">Usuários<img src="${homePath}/assets/img/add-novo.png" href="./UsuarioControlador?acao=novocadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('cadgrupousuario') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadgrupousuario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadgrupousuario")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=61" id="consulta"><div class="container-label-menu">Grupos de Usuários<img src="${homePath}/assets/img/add-novo.png" href="GrupoUsuarioControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('cadfilial') > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadfilial") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfilial")}" class="li-sub-menu width-265 validarSessaoMenu" href="ConsultaControlador?codTela=1" id="consulta"><div class="container-label-menu">Filiais<img src="${homePath}/assets/img/add-novo.png" href="./cadfilial?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <!--<li class="li-sub-menu menu-sem-acesso"><div class="container-label-menu">Filiais</div></li>-->
                        </ul>
                    </li>
                </ul>
            </a>
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal">
                        <label>Lançamentos</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li class="li-sub-menu">
                                <div class="container-label-menu"><span class="seta-lado"></span>Financeiro</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("caddespesa") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("caddespesa") > nivelLerAlterar}" codigoPermissao="${permissoes.get("caddespesa")}" class="li-sub-menu validarSessaoMenu" href="./consultadespesa?acao=iniciar" id="consulta"><div class="container-label-menu">Despesas<img src="${homePath}/assets/img/add-novo.png" href="./caddespesa?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("cadpgtocomissao") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadpgtocomissao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadpgtocomissao")}" class="li-sub-menu validarSessaoMenu" href="./consulta_pagamento_comissao.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Comissões<img src="${homePath}/assets/img/add-novo.png" href="./cadpagamento_comissao.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("lanfatura") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("lanfatura") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lanfatura")}" class="li-sub-menu validarSessaoMenu" href="./consultafatura?acao=iniciar" id="consulta"><div class="container-label-menu">Faturas / Boletos<img src="${homePath}/assets/img/add-novo.png" href="./fatura_cliente?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("lancamentofactoring") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancamentofactoring") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancamentofactoring")}" class="li-sub-menu validarSessaoMenu" href="./jspconsulta_factoring.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Descontar duplicatas<img src="${homePath}/assets/img/add-novo.png" href="./cadmovimentacao_factoring.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("fecamentocontratofreteagregado") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("fecamentocontratofreteagregado") > nivelLerAlterar}" codigoPermissao="${permissoes.get("fecamentocontratofreteagregado")}" class="li-sub-menu validarSessaoMenu" href="./ContratoFreteControlador?acao=visualizarFechamentoAgregado" id="consulta"><div class="container-label-menu">Fechamento Agregado</div></li>
                                    <li acessoMenu="${user.getAcesso("cadreceita") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadreceita") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadreceita")}" class="li-sub-menu validarSessaoMenu" href="VendaControlador?acao=listar" id="consulta"><div class="container-label-menu">Receitas Financeiras<img src="${homePath}/assets/img/add-novo.png" href="VendaControlador?acao=novoCadastroFinan&modulo=gwFinan" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("lanorcamentacao") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lanorcamentacao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lanorcamentacao")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=124" id="consulta"><div class="container-label-menu">Orçamentação<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=125" class="validarSessaoMenu" id="cadastrar"></div></li>
                                </ul>
                            </li>
                            <li acessoMenu="${user.getAcesso("lanorcamento") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lanorcamento") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lanorcamento")}" class="li-sub-menu validarSessaoMenu" href="./consulta_orcamento.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Orçamento<img src="${homePath}/assets/img/add-novo.png" href="./cadorcamento.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso("lancnotafiscal") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancnotafiscal") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancnotafiscal")}" class="li-sub-menu validarSessaoMenu" href="./NotaFiscalControlador?acao=listar" id="consulta"><div class="container-label-menu">Notas fiscais (DANFE)<img src="${homePath}/assets/img/add-novo.png" href="./NotaFiscalControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso("cadcoleta") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadcoleta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcoleta")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=24" id="consulta"><div class="container-label-menu">Coletas/O.S<img src="${homePath}/assets/img/add-novo.png" href="./cadcoleta?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso("cadconhecimento") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadconhecimento") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadconhecimento")}" class="li-sub-menu validarSessaoMenu" href="./consultaconhecimento?acao=iniciar" id="consulta"><div class="container-label-menu">Conhecimentos<img src="${homePath}/assets/img/add-novo.png" href="./frameset_conhecimento?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso("cadmanifesto") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadmanifesto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadmanifesto")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=28" id="consulta"><div class="container-label-menu">Manifestos<img src="${homePath}/assets/img/add-novo.png" href="./cadmanifesto?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso("lanviagem") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lanviagem") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lanviagem")}" class="li-sub-menu validarSessaoMenu" href="./consulta_viagem.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">ADV (VIAGEM)<img src="${homePath}/assets/img/add-novo.png" href="./cadviagem.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>

                            <c:choose>
                                <c:when test="${user.getFilial().getStUtilizacaoCfe() == 'N'.charAt(0)}">
                                    <li acessoMenu="${user.getAcesso("lancartafrete") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancartafrete") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancartafrete")}" class="li-sub-menu validarSessaoMenu" href="consultacartafrete?acao=consultar" id="consulta"><div class="container-label-menu">Contratos de fretes<img src="${homePath}/assets/img/add-novo.png" href="./cadcartafrete?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </c:when>
                                        <c:otherwise>
                                    <li acessoMenu="${user.getAcesso("lancartafrete") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancartafrete") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancartafrete")}" class="li-sub-menu validarSessaoMenu" href="./ContratoFreteControlador?acao=listar" id="consulta"><div class="container-label-menu">Contratos de fretes<img src="${homePath}/assets/img/add-novo.png" href="./ContratoFreteControlador?acao=novoCadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                                        </c:otherwise>
                                    </c:choose>

                            <li acessoMenu="${user.getAcesso("cadromaneio") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadromaneio") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadromaneio")}" class="li-sub-menu validarSessaoMenu" href="./consultaromaneio?acao=iniciar" id="consulta"><div class="container-label-menu">Romaneios<img src="${homePath}/assets/img/add-novo.png" href="./cadromaneio?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso("cadvenda") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadvenda") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadvenda")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=75" id="consulta"><div class="container-label-menu">Notas de serviços<img src="${homePath}/assets/img/add-novo.png" href="./cadvenda.jsp?acao=iniciar" class="validarSessaoMenu" id="cadastrar"></div></li>
                            <li acessoMenu="${user.getAcesso('lancamentomovimentacaopallets') > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancamentomovimentacaopallets") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancamentomovimentacaopallets")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=126" id="consulta"><div class="container-label-menu">Movimentação de Pallets<img src="${homePath}/assets/img/add-novo.png" href="${homePath}/CadastroControlador?codTela=128&modulo=cadastro" class="validarSessaoMenu" id="cadastrar"></div></li>
                        </ul>
                    </li>
                </ul>
            </a>
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal">
                        <label>Processos</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li class="li-sub-menu width-265"  isModuloReduzido="true">
                                <div class="container-label-menu"><span class="seta-lado"></span>Financeiro</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("analisecreditocliente") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("analisecreditocliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("analisecreditocliente")}" class="li-sub-menu validarSessaoMenu" href="./analise_credito.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Análise de crédito</div></li>
                                    <li acessoMenu="${user.getAcesso("analisefinanceira") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("analisefinanceira") > nivelLerAlterar}" codigoPermissao="${permissoes.get("analisefinanceira")}" class="li-sub-menu validarSessaoMenu" href="./AnaliseFinanceiraControlador?acao=consultaAnaliseFinanceira" id="consulta"><div class="container-label-menu">Análise financeira</div></li>
                                    <li acessoMenu="${user.getAcesso("bxpagar") > nivelLerAlterarIncluir}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("bxpagar") > nivelLerAlterarIncluir}" codigoPermissao="${permissoes.get("bxpagar")}" class="li-sub-menu validarSessaoMenu" href="./liberacaopagamento?acao=iniciar" id="consulta"><div class="container-label-menu">Liberação de pagamentos</div></li>
                                    <li acessoMenu="${user.getAcesso("bxpagar") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("bxpagar") > nivelLerAlterar}" codigoPermissao="${permissoes.get("bxpagar")}" class="li-sub-menu validarSessaoMenu" href="./bxcontaspagar?acao=iniciar" id="consulta"><div class="container-label-menu">Baixas de contas a pagar</div></li> 
                                    <li acessoMenu="${user.getAcesso("bxpagar") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("bxpagar") > nivelLerAlterar}" codigoPermissao="${permissoes.get("bxpagar")}" class="li-sub-menu validarSessaoMenu" href="./impressaocheques.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Impressão de cheques</div></li> 
                                    <li acessoMenu="${user.getAcesso("geraremessabanco") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("geraremessabanco") > nivelLerAlterar}" codigoPermissao="${permissoes.get("geraremessabanco")}" class="li-sub-menu validarSessaoMenu" href="./jspexporta_boleto.jsp" id="consulta"><div class="container-label-menu">Gerar arquivo de remessa</div></li>                                     
                                    <li acessoMenu="${user.getAcesso("bxreceber") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("bxreceber") > nivelLerAlterar}" codigoPermissao="${permissoes.get("bxreceber")}" class="li-sub-menu validarSessaoMenu" href="./bxcontasreceber?acao=iniciar" id="consulta"><div class="container-label-menu">Baixas de contas a receber</div></li>                                     
                                    <li acessoMenu="${user.getAcesso("bxreceber") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("bxreceber") > nivelLerAlterar}" codigoPermissao="${permissoes.get("bxreceber")}" class="li-sub-menu validarSessaoMenu" href="./bxcontasreceberLote.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Baixas por faturas</div></li>                                     
                                    <li acessoMenu="${user.getAcesso("conbancaria") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("conbancaria") > nivelLerAlterar}" codigoPermissao="${permissoes.get("conbancaria")}" class="li-sub-menu validarSessaoMenu" href="./conciliacaobanco?acao=iniciar" id="consulta"><div class="container-label-menu">Conciliação bancária</div></li>
                                    <li acessoMenu="${user.getAcesso("transferencia") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("transferencia") > nivelLerAlterar}" codigoPermissao="${permissoes.get("transferencia")}" class="li-sub-menu validarSessaoMenu" href="./transferenciabanco?acao=iniciar" id="consulta"><div class="container-label-menu">Transferências / Suprimentos</div></li>                                     
                                    <li acessoMenu="${user.getAcesso("cadtalaocheque") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtalaocheque") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtalaocheque")}" class="li-sub-menu validarSessaoMenu" href="./consulta_talao_cheque.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Talão de Cheque</div></li>                                     
                                </ul>
                            </li>
                            <li acessoMenu="${user.getAcesso("agendamento") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("agendamento") > nivelLerAlterar}" codigoPermissao="${permissoes.get("agendamento")}" class="li-sub-menu width-265 validarSessaoMenu" href="./AgendamentoControlador?acao=listar" id="consulta"><div class="container-label-menu">Agendamento Nota Fiscal</div></li>
                            <li class="li-sub-menu width-265"  isModuloReduzido="false">
                                <div class="container-label-menu"><span class="seta-lado"></span>Baixas de CT-e / Manifesto</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("bxctrc") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("bxctrc") > nivelLerAlterar}" codigoPermissao="${permissoes.get("bxctrc")}" class="li-sub-menu  width-265 validarSessaoMenu" href="./bxctrc?acao=iniciar" id="consulta"><div class="container-label-menu">Baixar CT-e / Manifesto Manualmente</div></li>
                                    <li acessoMenu="${user.getAcesso("bxctrc") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("bxctrc") > nivelLerAlterar}" codigoPermissao="${permissoes.get("bxctrc")}" class="li-sub-menu  width-265 validarSessaoMenu" href="./ConhecimentoControlador?acao=baixarCTeEDI" id="consulta"><div class="container-label-menu">Baixar CT-e por Arquivo EDI</div></li>
                                    <li acessoMenu="${user.licencaGwOCR && user.getAcesso("anexarimgcte") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu="${user.licencaGwOCR && user.getAcesso("anexarimgcte") > nivelLerAlterar}" codigoPermissao="${permissoes.get("anexarimgcte")}" data-tem-permissao="${user.licencaGwOCR}" class="li-sub-menu width-265  validarSessaoMenu" href="./AnexarImagemControlador?acao=novoCadastro" id="consulta-anexar-imagem"><div class="container-label-menu">Anexar Imagens no CT-e</div></li>
                                </ul>
                            </li>
                            <li acessoMenu="${user.getAcesso("cadconhecimento") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadconhecimento") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadconhecimento")}" class="li-sub-menu width-265  validarSessaoMenu" href="ConsultaControlador?codTela=69" id="consulta"><div class="container-label-menu">Consulta mercadoria em depósito</div></li>
                            <li acessoMenu="${user.getAcesso("consultaentrega") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("consultaentrega") > nivelLerAlterar}" codigoPermissao="${permissoes.get("consultaentrega")}" class="li-sub-menu width-265  validarSessaoMenu" href="./consulta_entrega_ctrc.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Consulta entrega (SAC)</div></li>                                     
                            <li acessoMenu="${user.getAcesso("cadcoleta") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadcoleta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcoleta")}" class="li-sub-menu width-265  validarSessaoMenu" href="./planejamentoCargas.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Planejamento de cargas</div></li>                                     
                            <li acessoMenu="${user.getAcesso("analise_frete") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("analise_frete") > nivelLerAlterar}" codigoPermissao="${permissoes.get("analise_frete")}" class="li-sub-menu width-265  validarSessaoMenu" href="./analise_frete.jsp?acao=iniciar&mostrarNFS=true" id="consulta"><div class="container-label-menu">Análise de frete</div></li>                                     
                            <li acessoMenu="${user.getAcesso("consaldocarta") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("consaldocarta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("consaldocarta")}" class="li-sub-menu width-265  validarSessaoMenu" href="./consulta_saldo_carta.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Consulta saldo contrato de frete</div></li>                                     
                            <li acessoMenu="${user.getAcesso("cadcoleta") > nivelLer}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadcoleta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcoleta")}" class="li-sub-menu width-265  validarSessaoMenu" href="./atualiza_diaria_motorista.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Lançar diária motorista</div></li>                                     
                            <li acessoMenu="${user.getAcesso("exportacao") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("exportacao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("exportacao")}" class="li-sub-menu width-265  validarSessaoMenu" href="./exportacao.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Exportação de dados</div></li>                                     
                            <li acessoMenu="${user.getAcesso("enviomaladireta") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("enviomaladireta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("enviomaladireta")}" class="li-sub-menu width-265  validarSessaoMenu" href="./mala_direta.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Envio de mala-direta</div></li>                                     
                            <li acessoMenu="${user.getAcesso("cadinutilizacaocte") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadinutilizacaocte") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadinutilizacaocte")}" class="li-sub-menu width-265  validarSessaoMenu" href="./InutilizacaoControlador?acao=listar" id="consulta"><div class="container-label-menu">Inutilização CT-e</div></li>                                     
                            <li acessoMenu="${user.getAcesso("roteirizadorentrega") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("roteirizadorentrega") > nivelLerAlterar}" codigoPermissao="${permissoes.get("roteirizadorentrega")}" class="li-sub-menu width-265  validarSessaoMenu" href="./RoteirizacaoControlador?acao=listar" id="consulta"><div class="container-label-menu">Roteirização de Entregas</div></li>                                     
                            <li acessoMenu="${user.getAcesso("arquivoImportacaoXML") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("arquivoImportacaoXML") > nivelLerAlterar}" codigoPermissao="${permissoes.get("arquivoImportacaoXML")}" class="li-sub-menu width-265  validarSessaoMenu" href="./ArquivoImportacaoXMLControlador?acao=listar" id="consulta"><div class="container-label-menu">Sincronizar E-mails, XMLs (Sefaz)</div></li>
                            <li acessoMenu="${user.getAcesso("arquivarprotocolo") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("arquivarprotocolo") > nivelLerAlterar}" codigoPermissao="${permissoes.get("arquivarprotocolo")}" class="li-sub-menu width-265  validarSessaoMenu" href="./ArquivarProtocoloControlador?acao=listar" id="consulta"><div class="container-label-menu">Arquivar Protocolo</div></li>                                     
                            <li acessoMenu="${user.getAcesso("visualizarPontoControle") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("visualizarPontoControle") > nivelLerAlterar}" codigoPermissao="${permissoes.get("visualizarPontoControle")}" class="li-sub-menu width-265  validarSessaoMenu" href="./PontoControleControlador?acao=visualizarPontoControle" id="consulta"><div class="container-label-menu">Visualizar Pontos de controle</div></li>                                     
                            <li acessoMenu="${user.getAcesso("inventario") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu="${user.getAcesso("inventario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("inventario")}" class="li-sub-menu width-265  validarSessaoMenu" href="ConsultaControlador?codTela=85" id="consulta"><div class="container-label-menu">Inventário<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=86" class="validarSessaoMenu" id="cadastrar"></div></li>
                        </ul>
                    </li>
                </ul>
            </a>
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal">
                        <label>Painéis</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li acessoMenu="${user.getAcesso("painelEntregas") > nivelSemAcesso}" isModuloReduzido="false" codigoPermissao="${permissoes.get("painelEntregas")}" class="li-sub-menu width-265 validarSessaoMenu" href="PainelControlador?acao=abrirTela&codTela=121" id="consulta"><div class="container-label-menu">Entregas em andamento</div></li>
                        </ul>
                    </li>
                </ul>
            </a>
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal">
                        <label>Relatórios</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li class="li-sub-menu width-180">
                                <div class="container-label-menu"><span class="seta-lado"></span>Cadastrais</div>
                                <ul>
                                    <li  isModuloReduzido="false"><div class="container-label-menu"><span class="seta-lado"></span>Financeiro</div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso("cadinutilizacaocte") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadinutilizacaocte") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadinutilizacaocte")}" class="li-sub-menu validarSessaoMenu" href="./relhistorico.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Históricos</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadfornecedor") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadfornecedor") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfornecedor")}" class="li-sub-menu validarSessaoMenu" href="./relfornecedores.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Fornecedores</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadconta") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadconta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadconta")}" class="li-sub-menu validarSessaoMenu" href="./relcontabancaria.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Conta bancária / caixas</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadplanocusto") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadplanocusto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadplanocusto")}" class="li-sub-menu validarSessaoMenu" href="./relplanocusto.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Plano Centro de Custos</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadundcusto") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadundcusto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadundcusto")}" class="li-sub-menu validarSessaoMenu" href="./relunidadecusto.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Unidade de Custo</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadrateio") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadrateio") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadrateio")}" class="li-sub-menu validarSessaoMenu" href="./relrateio.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Rateio</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadplanocontas") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadplanocontas") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadplanocontas")}" class="li-sub-menu validarSessaoMenu" href="./relplanoconta.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Plano de Contas</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadespecie") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadespecie") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadespecie")}" class="li-sub-menu validarSessaoMenu" href="./relespecie.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Espécies (Despesas)</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadformapagamento") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadformapagamento") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadformapagamento")}" class="li-sub-menu validarSessaoMenu" href="./relformapagamento.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Forma de Pagamento</div></li>                                     
                                        </ul>
                                    </li>
                                    <li isModuloReduzido="false"><div class="container-label-menu"><span class="seta-lado"></span>Operacional</div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso("cadmotorista") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadmotorista") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadmotorista")}" class="li-sub-menu validarSessaoMenu" href="./relmotoristas.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Motoristas</div></li>                                     
                                            <li><div class="container-label-menu">Veículos<span class="seta-lado"></span></div>
                                                <ul>
                                                    <li acessoMenu="${user.getAcesso("cadveiculo") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadveiculo") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadveiculo")}" class="li-sub-menu validarSessaoMenu width-180" href="./relveiculos.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Veículos</div></li>                                     
                                                    <li acessoMenu="${user.getAcesso("cadmarca") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadmarca") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadmarca")}" class="li-sub-menu validarSessaoMenu width-180" href="./relmarca.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Marcas</div></li>                                     
                                                    <li acessoMenu="${user.getAcesso("cadtipoveiculo") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipoveiculo") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipoveiculo")}" class="li-sub-menu validarSessaoMenu width-180" href="./reltipoveiculo.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Tipos de Veículos</div></li>                                     
                                                </ul>
                                            </li>
                                            <li acessoMenu="${user.getAcesso("cadtipo_servico") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipo_servico") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipo_servico")}" class="li-sub-menu validarSessaoMenu" href="./relservico.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Serviços</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadrota") >= nivelLer}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadrota") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadrota")}" class="li-sub-menu validarSessaoMenu" href="./relrotas.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Rotas</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadocorrencia") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadocorrencia") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadocorrencia")}" class="li-sub-menu validarSessaoMenu" href="./relocorrencia.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Ocorrências (EDI)</div></li>                                     
                                            <li acessoMenu="${user.getAcesso("cadobservacao") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadobservacao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadobservacao")}" class="li-sub-menu validarSessaoMenu" href="./relobservacao.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Observações</div></li>                                    
                                            <li><div class="container-label-menu">Container<span class="seta-lado"></span></div>
                                                <ul>
                                                    <li acessoMenu="${user.getAcesso("cadnavio") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadnavio") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadnavio")}" class="li-sub-menu validarSessaoMenu width-180" href="./relnavio.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Navios</div></li>                                                                                                                                                                                    
                                                    <li acessoMenu="${user.getAcesso("cadterminal") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadterminal") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadterminal")}" class="li-sub-menu validarSessaoMenu width-180" href="./relterminal.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Terminal</div></li>                                                                                                                                                                                    
                                                    <li acessoMenu="${user.getAcesso("cadtipocontainer") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipocontainer") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipocontainer")}" class="li-sub-menu validarSessaoMenu width-180" href="./reltipocontainer.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Tipo de Container</div></li>                                                                                                                                                                                    
                                                </ul>                                                
                                            </li>
                                            <li><div class="container-label-menu">Produtos<span class="seta-lado"></span></div>
                                                <ul>
                                                    <li acessoMenu="${user.getAcesso("cadprodutotrans") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadprodutotrans") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadprodutotrans")}" class="li-sub-menu validarSessaoMenu width-180" href="./relprodutos.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Produtos</div></li>                                                                                                                                                                                                                                        
                                                    <li acessoMenu="${user.getAcesso("cadundtrans") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadundtrans") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadundtrans")}" class="li-sub-menu validarSessaoMenu width-180" href="./relunidademedida.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Unidades de Medida</div></li>                                                                                                                                                                                                                                        
                                                    <li acessoMenu="${user.getAcesso("cadEmbalagem") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadEmbalagem") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadEmbalagem")}" class="li-sub-menu validarSessaoMenu width-180" href="./relembalagem.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Embalagem</div></li>                                                                                                                                                                                                                                        
                                                </ul>
                                            </li>
                                            <li><div class="container-label-menu">Outros<span class="seta-lado"></span></div>
                                                <ul>
                                                    <li acessoMenu="${user.getAcesso("cadfuncoes") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadfuncoes") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfuncoes")}" class="li-sub-menu validarSessaoMenu width-180" href="./relfuncaomaritimo.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Funções (Marítimo)</div></li>                                                                                                                                                                                                                                        
                                                    <li acessoMenu="${user.getAcesso("cadtipopallettransp") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipopallettransp") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipopallettransp")}" class="li-sub-menu validarSessaoMenu width-180" href="./reltipopallet.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Tipos de Pallets</div></li>                                                                                                                                                                                                                                        
                                                    <li acessoMenu="${user.getAcesso("cadaeroporto") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadaeroporto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadaeroporto")}" class="li-sub-menu validarSessaoMenu width-180" href="./relaeroporto.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Aeroportos</div></li>                                                                                                                                                                                                                                        
                                                    <li acessoMenu="${user.getAcesso("cadporto") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadporto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadporto")}" class="li-sub-menu validarSessaoMenu width-180" href="./relporto.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Portos</div></li>                                                                                                                                                                                                                                        
                                                </ul>
                                            </li>
                                        </ul>
                                    </li>
                                    <li isModuloReduzido="false"><div class="container-label-menu">Comercial<span class="seta-lado"></span></div>
                                        <ul>
                                            <li acessoMenu="${user.getAcesso("cadtabelacliente") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtabelacliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtabelacliente")}" class="li-sub-menu validarSessaoMenu" href="./reltabelapreco.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Tabelas de preços</div></li>                                                                                                                                                                                                                                        
                                            <li acessoMenu="${user.getAcesso("cadarea") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadarea") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadarea")}" class="li-sub-menu validarSessaoMenu" href="./relareas.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Áreas / Cidades</div></li>                                                                                                                                                                                                                                        
                                            <li acessoMenu="${user.getAcesso("cadtipoproduto") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadtipoproduto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadtipoproduto")}" class="li-sub-menu validarSessaoMenu" href="./reltipoproduto.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Tipo de Produto</div></li>                                                                                                                                                                                                                                        
                                            <li acessoMenu="${user.getAcesso("cadfaixa") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadfaixa") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfaixa")}" class="li-sub-menu validarSessaoMenu" href="./relfaixapeso.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Faixas de peso</div></li>                                                                                                                                                                                                                                        
                                            <li acessoMenu="${user.getAcesso("cadorigemcaptacao") >= nivelLer}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadorigemcaptacao") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadorigemcaptacao")}" class="li-sub-menu validarSessaoMenu" href="./relorigemcaptacao.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Origem de Captação</div></li>                                                                                                                                                                                                                                        
                                        </ul>
                                    </li>
                                    <li acessoMenu="${user.getAcesso("cadcliente") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadcliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcliente")}" class="li-sub-menu validarSessaoMenu" href="./relcliente.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Clientes</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("cadgrupo_cli_for") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadgrupo_cli_for") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadgrupo_cli_for")}" class="li-sub-menu validarSessaoMenu" href="./relgrupoclifor.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Grupo Clientes / Fornecedores</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("cadusuario") >= nivelLer}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadusuario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadusuario")}" class="li-sub-menu validarSessaoMenu" href="./relusuario.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Usuário</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("cadgrupousuario") >= nivelLer}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadgrupousuario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadgrupousuario")}" class="li-sub-menu validarSessaoMenu" href="./relgrupousuario.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Grupo de Usuarios</div></li>                                                                                                                                                                                                          
                                    <li acessoMenu="${user.getAcesso("cadfilial") >= nivelLer}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadfilial") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadfilial")}" class="li-sub-menu validarSessaoMenu" href="./relfilial.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Filiais</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("cadcfop") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadcfop") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcfop")}" class="li-sub-menu validarSessaoMenu" href="./relcfop.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">CFOPs</div></li>                                                                                                                                                                                                                                        
                                </ul>
                            </li>
                            <li class="li-sub-menu width-180">
                                <div class="container-label-menu"><span class="seta-lado"></span>Financeiro</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("relcontasreceber") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("relcontasreceber") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcontasreceber")}" class="li-sub-menu validarSessaoMenu" href="./relcontasreceber?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Contas a receber</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relcontasreceber") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relcontasreceber") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcontasreceber")}" class="li-sub-menu validarSessaoMenu" href="./relcontasrecebidas?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Contas recebidas</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("lanfatura") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("lanfatura") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lanfatura")}" class="li-sub-menu validarSessaoMenu" href="./relfaturas.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Faturas de clientes</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relcontaspagar") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relcontaspagar") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcontaspagar")}" class="li-sub-menu validarSessaoMenu" href="./relcontaspagar?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Contas a pagar</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relcontaspagar") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relcontaspagar") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcontaspagar")}" class="li-sub-menu validarSessaoMenu" href="./relcontaspagas?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Contas pagas</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("reldespesas") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("reldespesas") > nivelLerAlterar}" codigoPermissao="${permissoes.get("reldespesas")}" class="li-sub-menu validarSessaoMenu" href="./reldespesa?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Despesas</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relmovbanco") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relmovbanco") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relmovbanco")}" class="li-sub-menu validarSessaoMenu" href="./relmovbanco?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Movimentação bancária</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("chequecliente") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("chequecliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("chequecliente")}" class="li-sub-menu validarSessaoMenu" href="./relcheques?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Cheques de clientes</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relvendedor") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relvendedor") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relvendedor")}" class="li-sub-menu validarSessaoMenu" href="./relvendedor?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Comissões</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("fecamentocontratofreteagregado") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("fecamentocontratofreteagregado") > nivelLerAlterar}" codigoPermissao="${permissoes.get("fecamentocontratofreteagregado")}" class="li-sub-menu validarSessaoMenu" href="./ContratoFreteControlador?acao=iniciarImprimirFechamentoAgregado&modulo=webtrans" id="consulta"><div class="container-label-menu">Fechamento Agregado</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("lancamentofactoring") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancamentofactoring") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancamentofactoring")}" class="li-sub-menu validarSessaoMenu" href="./reldescontaduplicata.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Descontar duplicata</div></li>                                                                                                                                                                                                                                        
                                </ul>
                            </li>
                            <li class="li-sub-menu width-180">
                                <div class="container-label-menu"><span class="seta-lado"></span>Operacional</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("relcoleta") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relcoleta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcoleta")}" class="li-sub-menu validarSessaoMenu" href="./relorcamento.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Orçamento</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relcoleta") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("relcoleta") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcoleta")}" class="li-sub-menu validarSessaoMenu" href="./relcoleta.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Coletas</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relnfcliente") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relnfcliente") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relnfcliente")}" class="li-sub-menu validarSessaoMenu" href="./relnotafiscalcliente.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Notas fiscais de clientes</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relctrc") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("relctrc") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relctrc")}" class="li-sub-menu validarSessaoMenu" href="./relctrc?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">CTRCs / Notas de serviços</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relmanifesto") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("relmanifesto") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relmanifesto")}" class="li-sub-menu validarSessaoMenu" href="./relmanifesto.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Manifestos</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relcartafrete") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relcartafrete") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relcartafrete")}" class="li-sub-menu validarSessaoMenu" href="./relcartafrete.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Contratos de fretes</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relviagenstrans") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relviagenstrans") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relviagenstrans")}" class="li-sub-menu validarSessaoMenu" href="./relviagens.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Viagens</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relromaneio") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relromaneio") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relromaneio")}" class="li-sub-menu validarSessaoMenu" href="./relromaneio.jsp?acao=iniciar&modulo=webtrans" id="consulta"><div class="container-label-menu">Romaneio</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("lancamentomovimentacaopallets") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("lancamentomovimentacaopallets") > nivelLerAlterar}" codigoPermissao="${permissoes.get("lancamentomovimentacaopallets")}" class="li-sub-menu validarSessaoMenu" href="./ContratoFreteControlador?acao=iniciarImprimirMovimentacaoPallets&modulo=webtrans" id="consulta"><div class="container-label-menu">Pallets</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("inventario") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("inventario") > nivelLerAlterar}" codigoPermissao="${permissoes.get("inventario")}" class="li-sub-menu validarSessaoMenu" href="./InventarioControlador?acao=iniciarRelatorio&modulo=webtrans" id="consulta"><div class="container-label-menu">Inventário</div></li>
                                </ul>
                            </li>
                            <li class="li-sub-menu width-180">
                                <div class="container-label-menu"><span class="seta-lado"></span>Gerencial</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("reldespesas") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("reldespesas") > nivelLerAlterar}" codigoPermissao="${permissoes.get("reldespesas")}" class="li-sub-menu validarSessaoMenu" href="./relapropdespesa?acao=iniciar" id="consulta"><div class="container-label-menu">Análises por P. de Custo</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relanaliseorcamentofinan") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relanaliseorcamentofinan") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relanaliseorcamentofinan")}" class="li-sub-menu validarSessaoMenu" href="./OrcamentacaoControlador?acao=novoRelatorio" id="consulta"><div class="container-label-menu">Análise de orçamentação</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relanalisevenda") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("relanalisevenda") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relanalisevenda")}" class="li-sub-menu validarSessaoMenu" href="./relanalisevendas.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Análises de receitas</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relanaliseentrega") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("relanaliseentrega") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relanaliseentrega")}" class="li-sub-menu validarSessaoMenu" href="./relanaliseentrega.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Análises de entrega</div></li>                                                                                                                                                                                                                                        
                                    <li acessoMenu="${user.getAcesso("relfluxocaixa") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relfluxocaixa") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relfluxocaixa")}" class="li-sub-menu validarSessaoMenu" href="./relfluxocaixa.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Fluxo de caixa</div></li>                                                                                                                                                                                                                                        
                                </ul>
                            </li>
                            <li class="li-sub-menu width-180" isModuloReduzido="false">
                                <div class="container-label-menu"><span class="seta-lado"></span>Comercial</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("relanalisevendasvendedor") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relanalisevendasvendedor") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relanalisevendasvendedor")}" class="li-sub-menu validarSessaoMenu" href="./relanalisevendasvendedor.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Análise Vendas</div></li>                                                                                                                                                                                                                                        
                                </ul>
                            </li>
                            <li class="li-sub-menu width-180" isModuloReduzido="false">
                                <div class="container-label-menu"><span class="seta-lado"></span>Impostos</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("relimpostos") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("relimpostos") > nivelLerAlterar}" codigoPermissao="${permissoes.get("relimpostos")}" class="li-sub-menu validarSessaoMenu" href="./relinss?acao=iniciar" id="consulta"><div class="container-label-menu">INSS / IR</div></li>
                                </ul>
                            </li>
                            <li acessoMenu="true" acessocadmenu="false" isModuloReduzido="false" codigopermissao="0" class="li-sub-menu width-180 validarSessaoMenu" href="./reletiqueta.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Etiquetas</div></li>
                        </ul>
                    </li>
                </ul>
            </a>
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal" isModuloReduzido="true">
                        <label>Configurações</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li acessoMenu="${user.getAcesso("altconfig") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu="${user.getAcesso("altconfig") > nivelLerAlterar}" codigoPermissao="${permissoes.get("altconfig")}" class="li-sub-menu validarSessaoMenu" href="./config?acao=editar" id="consulta"><div class="container-label-menu">Gerais</div></li>
                            <li class="li-sub-menu" isModuloReduzido="false" >
                                <div class="container-label-menu"><span class="seta-lado"></span>Integrações</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("cadastroftp") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadastroftp") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadastroftp")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=71" id="consulta"><div class="container-label-menu">FTP</div></li>
                                </ul>
                            
                            </li>
                                <c:if test="${user != null && user.getId() == 1}">
                                <li class="li-sub-menu validarSessaoMenu" href="./ConfiguracaoTecnicaControlador?acao=carregar" id="consulta" isModuloReduzido="false" ><div class="container-label-menu">Técnicas</div></li>
                                </c:if>
                            <li class="li-sub-menu" isModuloReduzido="false" >
                                <div class="container-label-menu"><span class="seta-lado"></span>Operacionais</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("cadlayoutedi") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadlayoutedi") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadlayoutedi")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=94" id="consulta"><div class="container-label-menu">Layouts para EDI<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=95" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("cadFeriado") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadFeriado") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadFeriado")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=96" id="consulta"><div class="container-label-menu">Feriados<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=97" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("cadcaixapostalseg") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadcaixapostalseg") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcaixapostalseg")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=98" id="consulta"><div class="container-label-menu">Caixas Postais Seguradoras<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=99" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("alttaxa") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("alttaxa") > nivelLerAlterar}" codigoPermissao="${permissoes.get("alttaxa")}" class="li-sub-menu validarSessaoMenu" href="./alterataxa?acao=editar" id="consulta"><div class="container-label-menu">Taxas de Seguro</div></li>
                                    <li acessoMenu="${user.getAcesso("cadimpressora") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadimpressora") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadimpressora")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=100" id="consulta"><div class="container-label-menu">Impressoras Matriciais<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=101" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <!--<li acessoMenu="${user.getAcesso("cadimpressora") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadimpressora") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadimpressora")}" class="li-sub-menu validarSessaoMenu" href="./consulta_impressora.jsp?acao=iniciar" id="consulta"><div class="container-label-menu">Impressoras Matriciais</div></li>-->
                                </ul>
                            </li>
                            <li class="li-sub-menu">
                                <div class="container-label-menu"><span class="seta-lado"></span>Fiscais</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("cadcfop") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadcfop") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcfop")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=92" id="consulta"><div class="container-label-menu">CFOP<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=91" class="validarSessaoMenu" id="cadastrar"></div></li>
                                    <li acessoMenu="${user.getAcesso("altaliquota") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("altaliquota") > nivelLerAlterar}" codigoPermissao="${permissoes.get("altaliquota")}" class="li-sub-menu validarSessaoMenu" href="./UfIcmsControlador?acao=listar" id="consulta"><div class="container-label-menu">Alíquotas de ICMS</div></li>
                                    <li acessoMenu="${user.getAcesso("configpautafiscal") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("configpautafiscal") > nivelLerAlterar}" codigoPermissao="${permissoes.get("configpautafiscal")}" class="li-sub-menu validarSessaoMenu" href="./PautaFiscalControlador?acao=carregar" id="consulta"><div class="container-label-menu">Pauta Fiscal de ICMS</div></li>
                                </ul>
                            </li>
                            <li class="li-sub-menu" isModuloReduzido="true" >
                                <div class="container-label-menu"><span class="seta-lado"></span>E-mails</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("cademails") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cademails") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cademails")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=67" id="consulta"><div class="container-label-menu">Contas de E-mails</div></li>
                                    <li acessoMenu="${user.getAcesso("cadEmailsCaixaSaida") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadEmailsCaixaSaida") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadEmailsCaixaSaida")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=68" id="consulta"><div class="container-label-menu">Caixa de Saída</div></li>
                                </ul>
                            </li>
                            
                            <li class="li-sub-menu" isModuloReduzido="true" >
                                <div class="container-label-menu"><span class="seta-lado"></span>Segurança</div>
                                <ul>
                                    <li acessoMenu="${user.getAcesso("cadnat") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu= "${user.getAcesso("cadnat") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadnat")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=82" id="consulta"><div class="container-label-menu">NAT</div></li>
                                </ul>
                            </li>

                            <li acessoMenu="${user.getAcesso("cadcertificado") > nivelSemAcesso}" isModuloReduzido="true" acessoCadMenu="${user.getAcesso("cadcertificado") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadcertificado")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=129" id="consulta"><div class="container-label-menu">Certificados Digitais<img src="${homePath}/assets/img/add-novo.png" href="CadastroControlador?codTela=130" class="validarSessaoMenu" id="cadastrar"></div></li>

                            <li acessoMenu="${user.getAcesso("cadRelatorioPersonalizado") > nivelSemAcesso}" isModuloReduzido="false" acessoCadMenu= "${user.getAcesso("cadRelatorioPersonalizado") > nivelLerAlterar}" codigoPermissao="${permissoes.get("cadRelatorioPersonalizado")}" class="li-sub-menu validarSessaoMenu" href="ConsultaControlador?codTela=66" id="consulta"><div class="container-label-menu">Relatório Personalizado</div></li>
                        </ul>
                    </li>
                </ul>
            </a>
            <a class="a-menu-principal">
                <ul class="ul-menu-principal">
                    <li class="li-menu-principal">
                        <label>Ajuda</label><span class="seta-baixo"></span>
                        <ul class="ul-sub-menu">
                            <li class="li-sub-menu">
                                <div class="container-label-menu">
                                    <span class="seta-lado"></span>Novidades da versão
                                </div>
                                <ul>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1606" href="http://gwsistemas.com.br/wiki/images/3/31/Novidades_versao_16.06.pdf" id="consulta"><div class="container-label-menu">16.06</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C28H" href="http://gwsistemas.com.br/wiki/images/d/de/Novidades_versao_16.05.C28.H.pdf" id="consulta"><div class="container-label-menu">16.05.C28.H</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C27G" href="http://gwsistemas.com.br/wiki/images/b/b7/Novidades_versao_16.05.C27.G.pdf" id="consulta"><div class="container-label-menu">16.05.C27.G</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C26F" href="http://gwsistemas.com.br/wiki/images/f/fe/Novidades_versao_16.05.C26.F.pdf" id="consulta"><div class="container-label-menu">16.05.C26.F</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C25E" href="http://gwsistemas.com.br/wiki/images/9/9e/Novidades_versao_16.05.C25.E.pdf" id="consulta"><div class="container-label-menu">16.05.C25.E</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C24D" href="http://gwsistemas.com.br/wiki/images/d/d5/Novidades_versao_16.05.C24.D.pdf" id="consulta"><div class="container-label-menu">16.05.C24.D</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C23C" href="http://gwsistemas.com.br/wiki/images/2/20/Novidades_versao_16.05.C23.C.pdf" id="consulta"><div class="container-label-menu">16.05.C23.C</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C22B" href="http://gwsistemas.com.br/wiki/images/b/b2/Novidades_versao_16.05.C22.B.pdf" id="consulta"><div class="container-label-menu">16.05.C22.B</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605C21" href="http://gwsistemas.com.br/wiki/images/9/93/Novidades_versao_16.05.C21.pdf" id="consulta"><div class="container-label-menu">16.05.C21</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1605" href="http://gwsistemas.com.br/wiki/images/9/90/Novidades_Webtrans_versao_16.05.pdf" id="consulta"><div class="container-label-menu">16.05</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1604" href="http://gwsistemas.com.br/wiki/images/5/55/Novidades_Webtrans_versao_16.04.pdf" id="consulta"><div class="container-label-menu">16.04</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1603" href="http://gwsistemas.com.br/wiki/images/4/4f/Novidades_Webtrans_versao_16.03.pdf" id="consulta"><div class="container-label-menu">16.03</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1602" href="http://gwsistemas.com.br/wiki/images/5/5d/Novidades_Webtrans_versao_16.02.pdf" id="consulta"><div class="container-label-menu">16.02</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="1601" href="http://gwsistemas.com.br/wiki/images/6/61/Novidades_Webtrans_versao_16.01.pdf" id="consulta"><div class="container-label-menu">16.01</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" novidade="16" href="http://gwsistemas.com.br/wiki/images/2/27/Novidades_Webtrans_versao_16.00.pdf" id="consulta"><div class="container-label-menu">16.00</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/3/36/Novidades_Webtrans_versao_15.12.pdf" id="consulta"><div class="container-label-menu">15.12</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/c/c7/Novidades_Webtrans_versao_15.11.pdf" id="consulta"><div class="container-label-menu">15.11</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/0/0f/Novidades_Webtrans_versao_15.10.pdf" id="consulta"><div class="container-label-menu">15.10</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/b/b6/Novidades_Webtrans_versao_15.09.pdf" id="consulta"><div class="container-label-menu">15.09</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/4/46/Novidades_Webtrans_versao_15.08.pdf" id="consulta"><div class="container-label-menu">15.08</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/0/0c/Novidades_Webtrans_versao_15.07.pdf" id="consulta"><div class="container-label-menu">15.07</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/3/3f/Novidades_Webtrans_versao_15.05.pdf" id="consulta"><div class="container-label-menu">15.05</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/4/48/Novidades_Webtrans_versao_15.04.pdf" id="consulta"><div class="container-label-menu">15.04</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/8/81/Novidades_Webtrans_versao_15.03.pdf" id="consulta"><div class="container-label-menu">15.03</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/6/6d/Novidades_Webtrans_versao_15.02.pdf" id="consulta"><div class="container-label-menu">15.02</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://gwsistemas.com.br/wiki/images/3/39/Novidades_Webtrans_versao_15.01.pdf" id="consulta"><div class="container-label-menu">15.01</div></li>
                                </ul>
                            </li>
                            <li class="li-sub-menu">
                                <div class="container-label-menu">Comunicados<span class="seta-lado"></span></div>
                                <ul id="lista-comunicados">
                                </ul>
                            </li>
                            <li class="li-sub-menu">
                                <div class="container-label-menu">Downloads<span class="seta-lado"></span></div>
                                <ul>
                                    <li class="li-sub-menu validarSessaoMenu" href="https://s3-sa-east-1.amazonaws.com/utilitariosgw/PrinterModule.zip" id="consulta"><div class="container-label-menu">PrinterModule</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://www.teamviewer.com/pt/download/" id="consulta"><div class="container-label-menu">TeamViewer</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="http://www.beanywhere.com/" id="consulta"><div class="container-label-menu">BeAnyWhere</div></li>
                                    <li class="li-sub-menu validarSessaoMenu" href="${homePath}/assets/downloads/Layout_plano_contas_GW_Sistemas - Exemplo.xlsx" id="consulta"><div class="container-label-menu">Layout GW Sistemas (Excel)</div></li>
                                </ul>
                            </li>
                            <li class="li-sub-menu validarSessaoMenu" href="${configTecnica.linkBaseDeConhecimento}" id="baseConhecimento"><div class="container-label-menu">Base de Conhecimento</div></li>
                            <li class="li-sub-menu validarSessaoMenu" href="#" id="faleComSofia"><div class="container-label-menu">Fale com Sofia</div></li>
                            <li class="li-sub-menu validarSessaoMenu" href="LicencaControlador?acao=quebra_licenca&tela=menu" id="consulta"><div class="container-label-menu">Licença...</div></li>
                        </ul>
                    </li>
                </ul>
            </a>
        </nav>
    <selection class="selection-principal">
        <div class="div-container-pendencias">
            <div class="pendencias-topo">
                <img src="${homePath}/img/espere.gif" title="Atualizar pendências" class="reload-pendencias" >
                <span class="lb-pendencias">Mostrar Pendências</span>
                <span class="span-qtd-pendencias">(0)</span>
            </div>
            <div class="pendencias-corpo">
                <div class="corpo-topo">
                    <center>
                        Selecione o tipo de documento
                    </center>
                    <center>
                        <div>
                            <input type="radio" name="tipoImpressaoPendenciaMacro" id="tipoImpressaoPendenciaMacroPdf" checked="true" value="1"/>
                            <label for="tipoImpressaoPendenciaMacroPdf"><img src="assets/img/btn_pdf.png" alt=""></label>
                            <input type="radio" name="tipoImpressaoPendenciaMacro" id="tipoImpressaoPendenciaMacroWord" value="3" />
                            <label for="tipoImpressaoPendenciaMacroWord"><img src="assets/img/btn_word.png" alt=""></label>
                            <input type="radio" name="tipoImpressaoPendenciaMacro" id="tipoImpressaoPendenciaMacroExcel" value="2" />
                            <label for="tipoImpressaoPendenciaMacroExcel"><img src="assets/img/btn_excel.png  " alt=""></label>
                        </div>
                    </center>
                </div>
                <div class="corpo-b">
                    <ul>
                        <li>
                            <span>CT-e(s) <label id="total-cte"></label></span>
                            <ul>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="CTENegadoAguardandoConfirmacao_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=CTENegadoAguardandoConfirmacao&modelo=1"> CT-e(s) Negados ou Aguardando Confirmação da SEFAZ <label id="ctesNegadosMaior">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="CTEPendenteCincoDias_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=CTEPendenteCincoDias&modelo=1">CT-e(s) Pendentes a mais de 5 dias <label id="ctesPendentesMaior">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="CTEContingenciaFSDASemConfirmacao_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=CTEContingenciaFSDASemConfirmacao&modelo=1">CT-e(s) Enviados em Contigência FS-DA mas sem confirmação <label id="cteContingenciaMaior">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="CTEPendentesTransmissãoFTP" class="validarSessaoMenu" href="./RelatorioControlador?acao=CTEPendentesTransmissãoFTP&modelo=1">CT-e(s) pendentes de transmissão para o FTP <label id="cteEnvioXMLFTP">(  )</label></li>
                            </ul>
                        </li>
                        <li>
                            <span>MDF-e(s) <label id="total-mdfe"></label></span>
                            <ul class="ul-final">
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="MDFENegadoAguardandoConfirmacao_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFENegadoAguardandoConfirmacao&modelo=1">MDF-e(s) Negados ou Aguardando Confirmação da SEFAZ <label id="mdfeNegadoMaior">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="MDFEPendenteCincoDias_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFEPendenteCincoDias&modelo=1">MDF-e(s) Pendentes a mais de 5 dias <label id="mdfePendenteMaior">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="MDFEEmitidoXXDias" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFeNaoEncerradoXDias&modelo=1">MDF-e(s) não encerrados com <label id="total-dias-mdfe"></label> dias de emissão <label id="total-mdfe-nao-encerrados" >(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="qtdMDFeConfirmadoSemAverbar_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFeConfirmadoSemAverbar&modelo=1">MDF-e(s) Confirmados e não averbados <label id="qtdMDFeConfirmadoSemAverbar">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="qtdMDFeCanceladosSemAverbar_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFeCanceladosSemAverbar&modelo=1">MDF-e(s) Cancelados sem comunicar a Seguradora <label id="qtdMDFeCanceladosSemAverbar">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="qtdMDFeEncerradosSemAverbar_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFeEncerradosSemAverbar&modelo=1">MDF-e(s) Encerrados sem comunicar a Seguradora <label id="qtdMDFeEncerradosSemAverbar">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="qtdMDFeCondutorAdicionaisSemAverbar_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=MDFeCondutorAdicionaisSemAverbar&modelo=1">MDF-e(s) com condutores adicionais sem comunicar a Seguradora <label id="qtdMDFeCondutorAdicionaisSemAverbar">(  )</label></li>
                            </ul>
                        </li>
                        <li>
                            <span>Tabela de preço <label id="total-tabela-preco"></label></span>
                            <ul class="ul-final">
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="tabelaPrecoVencida_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=tabelaPrecoVencida&modelo=1">Tabela de preço vencida <label id="tabelaPrecoVencidaMaior">(  )</label><hr></li>
                                <li tipoImpressao="tipoImpressaoPendenciaMacro" id="tabelaPrecoVencer_relatorio" class="validarSessaoMenu" href="./RelatorioControlador?acao=tabelaPrecoVencer&modelo=1">Tabela de preço a vencer em até 30 dias <label id="tabelaprecovencerMaior">(  )</label></li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="quadro-avisos">
            <div class="quadro-avisos-topo">
                <label>ALERTAS</label><span class="seta-down"></span>
            </div>
            <div class="quadro-avisos-conteudo">
                <c:if test="${msgErro != null && msgErro != ''}">
                    <div class="container-erro" id="error">${msgErro}<hr></div>
                    </c:if>
                    <c:if test="${erroBackupAtrasado != null && erroBackupAtrasado != ''}">
                    <div class="container-erro" id="error-backup">${erroBackupAtrasado}<hr></div>
                    </c:if>
                    <c:if test="${mensagemErroLicense != null && mensagemErroLicense != ''}">
                    <div class="container-erro" id="error-license">${mensagemErroLicense}<hr></div>
                    </c:if>
                    <c:if test="${mensagemIrregularidadeMetadata != null && mensagemIrregularidadeMetadata != ''}">
                    <div class="container-erro" id="error-metadata">${mensagemIrregularidadeMetadata}<hr></div>
                    </c:if>
            </div>
        </div>
    </selection>
    <div class="container-iframe-boletos">
        <img class="fechar-iframe-boletos" src="assets/img/fechar_cinza.png">
        <iframe src="${homePath}/SegundaViaBoleto?acao=acessoTelaBoleto&cnpj=${codigoCliente}" class="iframe-boletos" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
    </div>
    <footer>
    </footer>
    <div class="container-botoes">
        <ul>
            <li class="li-botoes-informacoes">
                <div class="botoes-icone">
                    <img src="${homePath}/assets/img/icon-info.png">
                </div>
                <div class="botoes-label">
                    <span>Dúvidas, sugestão ou reclamações:</span>
                    <span>faleconosco@gwsistemas.com.br</span>
                    <span class="small-versao">Versão : ${versaoAtual}</span>
                </div>
            </li>
            <li class="li-botoes-senha validarSessaoMenu" href="./meucadastro?acao=iniciar" id="Alterar Senha">
                <div class="botoes-icone">
                    <img src="${homePath}/assets/img/icon-password.png">
                </div>
                <div class="botoes-label">
                    <label class="lb-senha-perfil">Alterar Senha/Perfil</label>
                </div>
            </li>
            <li class="li-botoes-desconectar validarSessaoMenu">
                <div class="botoes-icone">
                    <img src="${homePath}/assets/img/icon-logout.png">
                </div>
                <div class="botoes-label">
                    <span>Usuário:${user.getNome()}</span>
                    <span>IP:${user.getIp()}</span>
                    <span>Filial:${user.getFilial().getAbreviatura()}</span>
                    <span>Desconectar</span>
                </div>
            </li>
        </ul>
    </div>
    <style>
        .container-teste{
            width: 850px;
            height: 700px;
            position: absolute;
            float: left;
            z-index: 9999999999999999;
            display: none;
        }
    </style>
    <div class="container-teste"></div>
</body>
<div class="tool-sem-acesso">
    <span>
        <strong>Você não tem privilégios suficientes para executar essa ação.</strong>
    </span>
    <!--<img src="assets/img/caminhao-gw.png">-->
</div>
<c:if test="${anuncio != null && anuncio.getLocalArquivoHtml() != ''}">
    <div class="cobre-anuncio"></div>
    <iframe src="anuncios/container-anuncios.jsp?htmlAnuncio=${anuncio.getLocalArquivoHtml()}&idAnuncio=${anuncio.getId()}&tema=${cfg.getTipoTema().getCor()}" class="iframe-anuncio" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
    </c:if>

<div class="cobre-anuncio-escolhido"></div>
<iframe src="anuncios/container-anuncios.jsp?&idAnuncio=${anuncio.getId()}&tema=${cfg.getTipoTema().getCor()}" class="iframe-anuncio-escolhido" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
<!-- JS -->
<script type='text/javascript' src='${homePath}/script/jQuery/jquery-ui.js'></script>
<script type="text/javascript" src="${homePath}/assets/js/validacaoMenus.js?v=${random.nextInt()}"></script>
<script type="text/javascript" src="${homePath}/assets/js/menu.js?v=${random.nextInt()}" ></script>
<script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
<script type="text/javascript" src="script/validarSessao.js"></script>

<c:if test="${user != null}">
    <c:forEach items="${videosTela}" var="vid">
        <c:if test="${vid.getAcaoUsuario() != 'p' && vid.getAcaoUsuario() != 'a'}">
            <%--<%@include file="/layoutVideo.jsp?descricao=<%= vid.getDescricao() %>" %>--%>
            <jsp:include page="/layoutVideo.jsp?nome=${user.getNome()}">
                <jsp:param name="idVideo" value="${vid.id}"/>
                <jsp:param name="descricao" value="${vid.descricao}"/>
                <jsp:param name="url" value="${vid.url}"/>
                <jsp:param name="titulo" value="${vid.titulo}"/>
            </jsp:include>
        </c:if>
    </c:forEach>
</c:if>

<jsp:include page="/perfil_usuario_model.jsp"></jsp:include>
<script>
    
    var isOcultarMenuSemPermissao = ${usuario.isOcultarMenuSemPermissao};
    var homePath = '${homePath}';
    var isModuloReduzido = '${isModuloReduzido}';
    let certificadoAtualizado = '${configTecnica.certificadoAtualizadoEm != null}';
    jQuery(document).ready(function () {
        gerarSetarImagemPerfil('${user.isGerarImagem}', '${user.id}', '${user.idImagemPerfil}');
        if (typeof (Storage) !== "undefined") {
            sessionStorage.setItem('ultimoLogin', '${user.login}');
        }
        $('.mod-finan , .mod-logis, .mod-frota, .mod-mobile, .mod-loc, .mod-crm').on('click', function (e) {
            if (e.target.classList.contains('mod-finan')) {
                verificarLink('${configTecnica.linkGweb}/LoginControlador?acao=logar-webtrans-gweb&modulo=menu_gwFinan.jsp&login='+sessionStorage.getItem('ultimoLogin')+'&origem='+origin,${isLicencaFinan},'menu_gwFinan.jsp');
            }else if (e.target.classList.contains('mod-logis')) {
                verificarLink('${configTecnica.linkGweb}/LoginControlador?acao=logar-webtrans-gweb&modulo=menu_gwLogis.jsp&login='+sessionStorage.getItem('ultimoLogin')+'&origem='+origin,${isLicencaLogis},'menu_gwLogis.jsp');
            }else if (e.target.classList.contains('mod-frota')) {
                verificarLink('${configTecnica.linkGweb}/LoginControlador?acao=logar-webtrans-gweb&modulo=menu_gwFrota.jsp&login='+sessionStorage.getItem('ultimoLogin')+'&origem='+origin, ${isLicencaFrota},'menu_gwFrota.jsp');
            }else if (e.target.classList.contains('mod-loc')) {
                verificarLink('${configTecnica.linkGweb}/LoginControlador?acao=logar-webtrans-gweb&modulo=menu_gwLoc.jsp&login='+sessionStorage.getItem('ultimoLogin')+'&origem='+origin, ${isLicencaLoc},'menu_gwLoc.jsp');
            }else if (e.target.classList.contains('mod-crm')) {
                verificarLink('${configTecnica.linkGweb}/LoginControlador?acao=logar-webtrans-gweb&modulo=menu_gwCRM.jsp&login='+sessionStorage.getItem('ultimoLogin')+'&origem='+origin, ${isLicencaCRM && user.isUsuarioCrm},'menu_gwCRM.jsp');
            }else if (e.target.classList.contains('mod-mobile')) {
                if(${isLicencaMobile && (linkMobile!='#') && user.isIsUsuarioGwMobile() }){
                    window.open('${linkMobile}');
                }else if(${isLicencaMobile && (linkMobile!='#') && (!user.isIsUsuarioGwMobile())}){
                    chamarAlert("Você não tem acesso ao módulo gw Mobile.");
                }
            }else{
                verificarLink('${configTecnica.linkGweb}/logar-webtrans-gweb');
            }
        });
    });
    
    function verificarLink(url, temAcesso,modulo) {
        if(temAcesso){
            $.ajax({
            url: 'LoginControlador',
            type: 'POST',
            async: true,
            data: {
                acao: 'validarLink',
                link: url
            },
                complete: function(e){
                    if(e.status === 200){
                        jQuery("#iframe-logar-webtrans").attr("src",url);
                        jQuery('.cobre-logar').show();
                        jQuery('#iframe-logar-webtrans').show();
                        jQuery("#moduloEscolhido").val(modulo);
                    }else if (e.status === 404) {
                       chamarAlert("Servidor não encontrado ou não disponivel. Entre em contato com o suporte técnico caso o problema continue.");
                        jQuery('#iframe-logar-webtrans').hide();
                        jQuery('.cobre-logar').hide();
                    }
                }
            });
        }
    }
    function fecharAnuncio() {
        jQuery('.cobre-anuncio').hide(250);
        jQuery('.iframe-anuncio').hide(250);
        jQuery('.cobre-anuncio-escolhido').hide(250);
        jQuery('.iframe-anuncio-escolhido').hide(250);
        chamarAlert('Você poderá visualizar esse comunicado novamente no menu (Ajuda / Comunicados) ', null);
    }

    function salvarAcao(idAnuncio) {
        if (idAnuncio != '0') {
            jQuery.ajax({
                url: "AnuncioControlador?acao=salvarAcao&idAnuncio=" + idAnuncio,
                dataType: "text",
                method: "post",
                complete: function (jqXHR, textStatus) {
                    fecharAnuncio();
                }
            });
        }
    }

    function clickNovidade(numero) {
        jQuery('[novidade=' + numero + ']').trigger('click');
    }

    function chamarAnuncio(html) {
        jQuery('.iframe-anuncio-escolhido').attr('src', 'anuncios/container-anuncios.jsp?&idAnuncio=${anuncio.getId()}' + '&htmlAnuncio=' + html+'&tema=${cfg.getTipoTema().getCor()}');
        jQuery('.cobre-anuncio-escolhido').show(250, function () {
            jQuery('.iframe-anuncio-escolhido').show(250);
        });
    }
    function redirecionarGweb() {
        if(jQuery("#moduloEscolhido").val() != ""){
            window.location = '${configTecnica.linkGweb}'+'/'+jQuery("#moduloEscolhido").val();
        }
    }

</script>
<!-- FIM JS -->
<script>
    function abrir() {
        if (document.getElementById('iframeChat').style.height === '440px') {
            jQuery(document.getElementById('iframeChat')).animate({
                'height': '28px'
            });
        } else {
            jQuery(document.getElementById('iframeChat')).animate({
                'height': '440px'
            });
        }
    }

    var aceitouSair = false;
    function sair() {
        aceitouSair = true;
    }

    function getAceitouSair() {
        return aceitouSair;
    }

    function isAberto() {
        if (document.getElementById('iframeChat').style.height === '440px' || document.getElementById('iframeChat').style.height === '450px') {
            return true;
        } else {
            return false;
        }
    }

    function isMaxminizado() {
        if (document.getElementById('iframeChat').style.height === '450px') {
            return true;
        } else {
            return false;
        }
    }

    function minimizar() {
        jQuery(document.getElementById('iframeChat')).animate({
            'height': '28px',
            'width': '290px'
        });
    }

    function maxminizar() {
        jQuery(document.getElementById('iframeChat')).animate({
            'width': '500px'
        }, 300, function () {
            jQuery(document.getElementById('iframeChat')).animate({
                'height': '450px'
            });
        });
    }

    function restaurar() {
        jQuery(document.getElementById('iframeChat')).animate({
            'width': '290px'
        }, 300, function () {
            jQuery(document.getElementById('iframeChat')).animate({
                'height': '440px'
            });
        });
    }

    function reload() {
        jQuery('#iframeChat').attr('src', jQuery('#iframeChat').attr('src'));
    }
    
    function fecharTela() {
        jQuery('#iframe-logar-webtrans').hide();
        jQuery('.cobre-logar').hide();
    }

    function fecharTela() {
        jQuery('#iframe-logar-webtrans').hide();
        jQuery('.cobre-logar').hide();
    }

</script>
<script>
    var frame = document.getElementById('iframeChat');
//    frame.contentWindow.postMessage('teste', '*');
    window.addEventListener('message', function (event) {
        if (event.data === 'abrir') {
            abrir();
        }
        if (event.data === 'reload') {
            reload();
        }
        if (event.data === 'maxminizar') {
            maxminizar();
        }
        if (event.data === 'minimizar') {
            minimizar();
        }
        if (event.data === 'restaurar') {
            restaurar();
        }
        if (event.data === 'reloadMenu') {
            reloadMenu();
        }
        if (event.data === 'window.reload') {
            window.location.reload();
        }
        
        if (event.data === 'loguei') {
            redirecionarGweb();
        }
        if (event.data === 'errouSenha') {
            chamarAlert("A senha está incorreta, tente novamente");
        }
        if (event.data === 'errouSenha3x') {
            chamarAlert('Você errou a senha 3 vezes, a tela será fechada.', fecharTela);
        }
        if (event.data === 'fecharIframe') {
            fecharTela();
        }
        if (event.data === 'errouSenha3xcaptcha') {
            chamarAlert('Você errou 3 vezes a senha, você será redirecionado para tela de login.', redirecionarGweb);
        }
        if (event.data === 'isAberto') {
            if (frame) {
                frame.contentWindow.postMessage('isAberto!@!'+isAberto(), '*');
            }
        }
    });

</script>
<jsp:include page="gwTrans/blip/chat_blip.jsp"/>
<script>
    configurarChatBlip('${configTecnica.blipChaveApp}', 4, {
        'id': '${user.id}',
        'nome': '${user.nome}',
        'email': '${user.email}'
    }, {
        'razao_social': '${user.filial.razaosocial}',
        'cnpj': '${user.filial.cnpj}',
        'telefone': '${user.filial.fone}',
        'cidade': '${user.filial.cidade.descricaoCidade}',
        'versao': '${versao}'
    }, true, true, {'tela': 'menu'});

    executarChatBlip();
</script>
<input type="hidden" id="moduloEscolhido" name="moduloEscolhido">
<div class="cobre-logar"></div>
<iframe src="" id="iframe-logar-webtrans" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
<img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
<div class="bloqueio-tela"></div>
</html>
