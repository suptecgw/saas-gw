<%-- 
    Document   : produtos
    Created on : 25/05/2016, 10:17:12
    Author     : Mateus
--%>
<%@page import="br.com.gwsistemas.eutil.NivelAcessoUsuario"%>
<%@page import="java.util.TreeMap"%>
<%@page import="java.util.Map"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="nucleo.Apoio"%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>GW Sistemas - Produtos</title>
	<link rel="stylesheet" href="assets/css/style.css">
	<link href='http://fonts.googleapis.com/css?family=Didact+Gothic' rel='stylesheet' type='text/css'>
</head>
<body>

<header role="banner" class="header-top">
    <% 
        boolean userConnected = false;
        //opções GAMBI
        BeanUsuario user = Apoio.getUsuario(request); 
        userConnected = (user != null);
        if (!userConnected) {
            response.sendRedirect("./login");
        }
        //Carregando as configuraões independente da ação
    Map<String, String> permissoes = new TreeMap<String, String>();
    if (userConnected) {
        permissoes = (Map<String, String>) getServletContext().getAttribute("todasPermissoes");
        request.setAttribute("versaoAtual",Apoio.WEBTRANS_VERSION);
    }
        
    %>
	<div class="line"></div>

	<div class="header-logos">
		<h1><a href="./menu"><img src="assets/img/gw-sistemas.png" alt=""></a></h1>
                <a href="./menu"><img src="assets/img/infraero.png" alt="" id="imgMacro"  width="81px" height="50px"></a>
                <a class="openWindow" id="configuracao_logoMacro" href="./config?acao=editar" style="display: none">selecione uma logo</a>
	</div>


	<div class="header-nav-tablet header-nav-tablet--frota header-nav-tablet--closed">
		<a href="#" class="header-nav-tablet__btn"><i class="i-inicio"></i><img src="assets/img/inicio_mobile.png" alt=""></a>
		<nav class="header-nav-tablet-list">
			<ul>
				<li class="header-nav-tablet-list-inicio--active"><a href="index.html"><img src="assets/img/inicio_mobile_white.png" alt=""></a></li>
				<li><a href="gw-trans.html"><img src="assets/img/gw-trans.png" alt=""></a></li>
				<li><a href="gw-finan.html"><img src="assets/img/gw-finan.png" alt=""></a></li>
				<li><a href="gw-logis.html"><img src="assets/img/gw-logis.png" alt=""></a></li>
				<li><a href="gw-frota.html"><img src="assets/img/gw-frota.png" alt=""></a></li>
				<li><a href="gw-loc.html"><img src="assets/img/gw-loc.png" alt=""></a></li>
				<li><a href="gw-crm.html"><img src="assets/img/gw-crm.png" alt=""></a></li>
			</ul>
		</nav>
	</div>

	<nav class="menu-top-sub menu-top-sub--fixed">
		<ul>
			<li class="dropdown">
				<a href="">Cadastros <span class="caret"></span></a>
				<ul>
					<li><a href="#">Cidades <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
					<li><a href="#">CFOP</a></li>
					<li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
					<li><a href="#">Grupo de usuários</a></li>
					<li><a href="#">Filiais</a></li>
				</ul>
			</li>

			<li class="dropdown">
				<a href="">Ferramentas <span class="caret"></span></a>
				<ul>
					<li><a href="#">Configurações</a></li>
					<li><a href="#">Configurar e-mail</a></li>
					<li><a href="#">Layout para EDI</a></li>
					<li><a href="#">Impressoras matriciais</a></li>
					<li><a href="#">Auditoria</a></li>
				</ul>
			</li>

			<li class="dropdown">
				<a href="">Ajuda <span class="caret"></span></a>
				<ul>
					<li><a href="#">Novidades da versão</a></li>
					<li><a href="#">Downloads</a></li>
					<li><a href="#">Ajuda DO GWeb</a></li>
					<li><a href="#">Sobre a GWeb</a></li>
				</ul>
			</li>
		</ul>
	</nav>

	<nav class="menu-top" class="desktop">
		<ul>
			<li class="menu-top__item menu-top__item--trans">
				<a href="gw-trans.html"></a>
				<nav class="menu-top-sub">
					<ul>
				        <li class="dropdown">
							<a href="">Cadastros <span class="caret"></span></a>
							<ul>
								<li><a href="gw-trans.html">Cidades</a></li>
								<li><a href="#">CFOP</a></li>
								<li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
								<li><a href="#">Grupo de usuários</a></li>
								<li><a href="#">Filiais</a></li>
							</ul>
						</li>

				        <li class="dropdown">
				          <a href="#">Lançamentos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Relatorios <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
							<a href="">Ferramentas <span class="caret"></span></a>
							<ul>
								<li><a href="#">Configurações</a></li>
								<li><a href="#">Configurar e-mail</a></li>
								<li><a href="#">Layout para EDI</a></li>
								<li><a href="#">Impressoras matriciais</a></li>
								<li><a href="#">Auditoria</a></li>
							</ul>
						</li>
					</ul>
				</nav>
			</li>

			<li class="menu-top__item menu-top__item--finan">
				<a href="gw-finan.html"></a>
				<nav class="menu-top-sub">
					<ul>
				        <li class="dropdown">
				          <a href="#">Cadastro <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Cidades <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
				            <li><a href="#">CFOP</a></li>
				            <li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
				            <li><a href="#">Grupo de Usuários</a></li>
				            <li><a href="#">Filiais</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Ferramentas <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Configurações</a></li>
				            <li><a href="#">Configurar E-mails</a></li>
				            <li><a href="#">layout para EDI</a></li>
				            <li><a href="#">Impressoras Matriciais</a></li>
				            <li><a href="#">Auditoria</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Ajuda <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>
					</ul>
				</nav>
			</li>

			<li class="menu-top__item menu-top__item--logis">
				<a href="gw-logis.html"></a>
				<nav class="menu-top-sub">
					<ul>
				        <li class="dropdown">
							<a href="">Cadastros <span class="caret"></span></a>
							<ul>
								<li><a href="gw-trans.html">Cidades</a></li>
								<li><a href="#">CFOP</a></li>
								<li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
								<li><a href="#">Grupo de usuários</a></li>
								<li><a href="#">Filiais</a></li>
							</ul>
						</li>

				        <li class="dropdown">
				          <a href="#">Lançamentos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da VersÃ£o</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Relatorios <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Processos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
							<a href="">Ferramentas <span class="caret"></span></a>
							<ul>
								<li><a href="#">Configurações</a></li>
								<li><a href="#">Configurar e-mail</a></li>
								<li><a href="#">Layout para EDI</a></li>
								<li><a href="#">Impressoras matriciais</a></li>
								<li><a href="#">Auditoria</a></li>
							</ul>
						</li>
					</ul>
				</nav>
			</li>

			<li class="menu-top__item menu-top__item--frota">
				<a href="gw-frota.html"></a>
				<nav class="menu-top-sub">
					<ul>
				        <li class="dropdown">
							<a href="">Cadastros <span class="caret"></span></a>
							<ul>
								<li><a href="gw-trans.html">Cidades</a></li>
								<li><a href="#">CFOP</a></li>
								<li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
								<li><a href="#">Grupo de usuários</a></li>
								<li><a href="#">Filiais</a></li>
							</ul>
						</li>

				        <li class="dropdown">
				          <a href="#">Lançamentos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Processos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Relatorios <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>
					</ul>
				</nav>
			</li>

			<li class="menu-top__item menu-top__item--loc">
				<a href="gw-loc.html"></a>
				<nav class="menu-top-sub">
					<ul>
				        <li class="dropdown">
							<a href="">Cadastros <span class="caret"></span></a>
							<ul>
								<li><a href="gw-trans.html">Cidades</a></li>
								<li><a href="#">CFOP</a></li>
								<li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
								<li><a href="#">Grupo de usuários</a></li>
								<li><a href="#">Filiais</a></li>
							</ul>
						</li>

				        <li class="dropdown">
				          <a href="#">Lançamentos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Processos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Relatorios <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>
					</ul>
				</nav>
			</li>

			<li class="menu-top__item menu-top__item--crm">
				<a href="gw-crm.html"></a>
				<nav class="menu-top-sub">
					<ul>
				        <li class="dropdown">
							<a href="">Cadastros <span class="caret"></span></a>
							<ul>
								<li><a href="gw-trans.html">Cidades</a></li>
								<li><a href="#">CFOP</a></li>
								<li><a href="#">Usuários <span class="caret-submenu"></span> <span class="more"  data-href="login.html"></span></a></li>
								<li><a href="#">Grupo de usuários</a></li>
								<li><a href="#">Filiais</a></li>
							</ul>
						</li>

				        <li class="dropdown">
				          <a href="#">Lançamentos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Processos <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				            <li><a href="#">lorem</a></li>
				          </ul>
				        </li>

				        <li class="dropdown">
				          <a href="#">Relatorios <span class="caret"></span></a>
				          <ul role="menu" class="dropdown-menu">
				            <li><a href="#">Novidades da Versão</a></li>
				            <li><a href="#">Downloads</a></li>
				            <li><a href="#">Ajuda do GWeb</a></li>
				            <li><a href="#">Sobre a GWeb</a></li>
				          </ul>
				        </li>
					</ul>
				</nav>
			</li>
		</ul><!--menu-top do desktop-->
	</nav>

</header>


    <div class="show-mobile">

	  <nav class="header-mobile-top">
                <a href="#" class="header-mobile-top__btn"></a>
		<ul>
			<li><a href="./menu"><img src="assets/img/gw-sistemas.png" alt="" width="90px"></a></li>
                        <li><a href="./menu"><img src="assets/img/infraero.png" alt=""  width="81px" height="50px" id="imgMobile"></a></li>
                        <a class="openWindow" id="configuracao_logoMobile" href="./config?acao=editar" style="display: none">selecione uma logo</a>
		</ul>
	</nav>
        
	<div class="line"></div>

	<div class="start-secion-page-mobile">

		<a href="sub_operacional.jsp" class="voltar"><</a>
		<h1 class="mobile-title-page">Produtos</h1>

	</div>

	<div class="content-mobile">

		<nav class="btn-menu-mobile">
			<ul class="btn-menu-mobile-list-top">
                            <!--PRODUTOS-->
                            <%if (user != null && user.getAcesso("cadprodutotrans") > NivelAcessoUsuario.SEM_ACESSO.getNivel()) {%>
                            <li>
                                <a class="openWindow" href="./ProdutoControlador?acao=listar" id="produto_listar">Produtos 
                                    <%if (user != null && user.getAcesso("cadprodutotrans") > NivelAcessoUsuario.LER_ALTERAR.getNivel()) {%>
                                    <span id="produto_cadastro" class="more" data-href="./ProdutoControlador?acao=novoCadastro"></span>
                                    <%}%>
                                </a>
                            </li>
                            <%} else if (user != null && !user.isIsOcultarMenuSemPermissao()) {%>
                            <li style=" cursor: pointer;" title="Você não tem privilégios suficientes para executar essa ação." class="showTitle">
                                 <a style="background-color: silver;color: black;" class="openWindow" href="" id="" onclick="javascript: semPrivilegio('<%= permissoes.get("cadprodutotrans")%>')" >
                                    Produtos    
                                </a>
                            </li> 
                            <%}%>

                            <!--UNIDADES DE MEDIDA -->
                            <%if (user != null && user.getAcesso("cadundtrans") > NivelAcessoUsuario.SEM_ACESSO.getNivel()) {%>
                            <li>
                                <a class="openWindow" href="./UnidadeMedidaControlador?acao=listar" id="unidadeMedida_listar">Unidades de medida 
                                    <%if (user != null && user.getAcesso("cadundtrans") > NivelAcessoUsuario.LER_ALTERAR.getNivel()) {%>
                                    <span id="unidadeMedida_cadastro" class="more" data-href="./UnidadeMedidaControlador?acao=novoCadastro"></span>
                                    <%}%>
                                </a>
                            </li>
                            <%} else if (user != null && !user.isIsOcultarMenuSemPermissao()) {%>
                            <li style=" cursor: pointer;" title="Você não tem privilégios suficientes para executar essa ação." class="showTitle">
                                 <a style="background-color: silver;color: black;" class="openWindow" href="" id="" onclick="javascript: semPrivilegio('<%= permissoes.get("cadundtrans")%>')" >
                                    Unidades de medida    
                                </a>
                            </li> 
                            <%}%>

                            <!--EMBALAGEM-->
                            <%if (user != null && user.getAcesso("cadEmbalagem") > NivelAcessoUsuario.SEM_ACESSO.getNivel()) {%>
                            <li>
                                <a class="openWindow" href="./EmbalagemControlador?acao=listar" id="embalagem_listar">Embalagem 
                                    <%if (user != null && user.getAcesso("cadEmbalagem") > NivelAcessoUsuario.LER_ALTERAR.getNivel()) {%>
                                    <span id="embalagem_cadastro" class="more" data-href="./EmbalagemControlador?acao=novoCadastro"></span>
                                    <%}%>
                                </a>
                            </li>
                            <%} else if (user != null && !user.isIsOcultarMenuSemPermissao()) {%>
                            <li style=" cursor: pointer;" title="Você não tem privilégios suficientes para executar essa ação." class="showTitle">
                                 <a style="background-color: silver;color: black;" class="openWindow" href="" id="" onclick="javascript: semPrivilegio('<%= permissoes.get("cadEmbalagem")%>')" >
                                    Embalagem    
                                </a>
                            </li> 
                            <%}%>

			</ul>
		</nav>

	</div><!--content-mobile-->

	<div class="bottom-mobile" style="display: none">
		<img src="assets/img/bottom-mobile.png" alt="">
	</div>
</div><!--show mobile-->

<header class="header-nav-mobile header-nav-mobile--closed">

            <nav class="header-nav-mobile-list">

                <div class="title-header-mobile">
                    <h2>Gweb</h2>
                    <h3>Versão <p id="versaoWebtransMobile" style="display: inline"></p></h3>
                </div>

                <ul class="main-menu-mobile">

                    <li>
                        <a largura="100px" altura="100px" class="openWindow" id="pop_redirect_gerencial" href="./UsuarioControlador?acao=redirecionaProjeto&modulo=inicio" >
                            <img src="assets/img/inicio_mobile1.png" alt="">
                        </a>
                    </li>
                    <li  class="main-menu-mobile-active">
                        <a href="#">
                            <img src="assets/img/trans-mobile.png" alt="">
                        </a>
                    </li>
                    <li>
                        <a largura="100px" altura="100px" class="openWindow" id="pop_redirect_finan" href="./UsuarioControlador?acao=redirecionaProjeto&modulo=finan">
                            <img src="assets/img/finan-mobile.png" alt="">
                        </a>
                    </li>
                    <li>
                        <a largura="100px" altura="100px" class="openWindow" id="pop_redirect_logis" href="./UsuarioControlador?acao=redirecionaProjeto&modulo=logis">
                            <img src="assets/img/logis-mobile.png" alt="">
                        </a>
                    </li>
                    <li>
                        <a largura="100px" altura="100px" class="openWindow" id="pop_redirect_frota" href="./UsuarioControlador?acao=redirecionaProjeto&modulo=frota">
                            <img src="assets/img/frota-mobile.png" alt="">
                        </a>
                    </li>
                    <li>
                        <a largura="100px" altura="100px" class="openWindow" id="pop_redirect_loc" href="./UsuarioControlador?acao=redirecionaProjeto&modulo=loc">
                            <img src="assets/img/loc-mobile.png" alt="">
                        </a>
                    </li>
                    <li>
                        <%= user != null && user.isUsuarioCrm() ? "<a largura='100px' altura='100px' class='openWindow' id='pop_redirect_crm' href='./UsuarioControlador?acao=redirecionaProjeto&modulo=crm'>":"<a href='#'>" %>
                            <img src="assets/img/crm-mobile.png" alt="">
                        </a>
                    </li>
                </ul>

                <ul class="sub-menu-mobile">
                    <li><a href="./meucadastro?acao=iniciar"><img src="assets/img/icon-password.png" alt="">Alterar Senha</a></li>
                    <li>
                        <div id='desconectar-dialog'>
                            <a target="_blank" class="marca_flutuante__btn marca_flutuante__btn--logout desconectar" href="javascript: sair();">
                                <img src="assets/img/icon-logout.png" alt="">Sair
                            </a>
                        </div>
                        <strong style="color:white">Usuário: <%= (user == null ? "" : user.getNome()) %></strong>
                        <strong style="color:white">IP: <%= (user == null ? "" : user.getIp()) %></strong>
                        <strong style="color:white">Filial: <%= (user == null ? "" : user.getFilial().getAbreviatura()) %></strong>
                    </li>
                    <!-- modal content -->
                    <div id='desconectar'>
                        <div class='header'><span>Desconectar</span></div>
                        <div class='message'></div>
                        <div class='buttons'>
                            <div class='yes'>Sim</div>
                            <div class='no simplemodal-close'>Não</div>
                        </div>
                    </div>
                    <!-- preload the images -->
                    <div style='display:none'>
                        <img src='assets/img/header.gif' alt='' />
                        <img src='assets/img/button.gif' alt='' />
                    </div>
                </ul>
            </nav>
        </header>

<script src="assets/js/jquery-1.9.1.min.js"></script>
<script type='text/javascript' src='assets/js/main.js'></script>
<script type='text/javascript' src='assets/js/jquery.simplemodal.js'></script>
<script type='text/javascript' src='assets/js/confirm.js'></script>
<script type='text/javascript' src='assets/js/basic.js'></script>
<script>
    
    jQuery(document).ready(function () {
       
        var nomeLogoCliente = '${nomeLogoCliente}';
        console.log("nome = " + nomeLogoCliente);
        if (nomeLogoCliente != '') {
            jQuery("#imgMobile").attr("src", "img/logoCliente/" + nomeLogoCliente);
            jQuery("#imgMacro").attr("src", "img/logoCliente/" + nomeLogoCliente);
        } else {
            jQuery("#imgMobile").hide();
            jQuery("#imgMacro").hide();
            jQuery("#configuracao_logoMobile").show();
            jQuery("#configuracao_logoMacro").show();
        }
        
        
        var versaoWebtrans = '${versaoAtual}';
        jQuery("#versaoWebtransMobile").text(versaoWebtrans);
        
    });
    
        function semPrivilegio(codigo) {
            alert("Você não tem privilégios suficientes para executar essa ação. Para acessar essa rotina você deverá solicitar a permissão '" + codigo + "' ao usuário administrador de sua empresa")
        }
    
</script>
</body>
</html>
