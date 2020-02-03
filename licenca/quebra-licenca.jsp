<%-- 
    Document   : quebra-licenca
    Created on : 03/04/2017, 08:44:20
    Author     : Mateus
--%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<jsp:useBean id="random" class="java.util.Random" scope="application" />
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="${homePath}/licenca/quebra-licenca.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js" type="text/javascript"></script>
        <script src="${homePath}/licenca/quebra-licenca.js?v=${random.nextInt()}" type="text/javascript"></script>
        <title>Gw Sistemas - Quebra de licença</title>
        <script>

            var homePath = '${homePath}';
            var codigo_cliente = '${codigoCliente}';
            var servidor_online = false;
            var conectado = false;

            var is_cloud = ${isCloud == null ? false : isCloud};

            $(document).ready(function () {
                $('.iframe-boletos').attr('src', '${param.linkGwBoletos}'+'/SegundaViaBoleto?acao=acessoTelaBoleto&cnpj=' + codigo_cliente);

                verificarConexaoWebService();
                if ('${status}' === '503') {
                    $('.lock-espaco').hide();
                    $('.faixa').css('background', '#8B0000');
                } else if ('${status}' == '402') {
                    var html = $('[motivo-bloqueio]').html().replace('Motivo do bloqueio:', 'Aviso:');
                    $('[motivo-bloqueio]').html(html);
                    $('[titulo-msg]').text('Sistema Liberado');
                    $('.lock-body').css('background', '#FFA500');
                    $('.faixa').css('background', '#FFA500');
                    $('.lock-top-1').css('background', '#FFA500');
                    if (${param.tela == "acesso"}) {
                        setTimeout(function(){
                            this.location = './menu';
                        },2000);
                    }
                } else if ('${status}' == '') {
                    $('.lock-top-1').css('background', '#055005');
                    $('.lock-body').css('background', '#055005');
                    $('.title-section').text('Sistema Desbloqueado');
                    $('.faixa').css('background', '#055005');
                    $('#msgBoleto').hide();
                    $('#linkBoleto').hide();
                    $('[motivo-bloqueio]').hide();
                }


                if ('${nivelBoleto}' != '4') {
                    $.ajax({
                        url: '${param.linkGwBoletos}'+'/SegundaViaBoleto?acao=getUsuariosPermissaoBoleto',
                        success: function (data, textStatus, jqXHR) {
                            $($.parseJSON(data)).each(function () {
                                var li = $('<li>');
                                var img = $('<img src="${homePath}/assets/img/icone-perfil.png">');
                                li.append(img);

                                var divNomeUsuario = $('<div class="nome-usuario">').text(this.nome);
                                var divEmailUsuario = $('<div class="email-usuario">').text(this.email);
                                var divFilialUsuario = $('<div class="filial-usuario">').text(this.filial);

                                divNomeUsuario.append(divEmailUsuario);
                                divNomeUsuario.append(divFilialUsuario);
                                li.append(divNomeUsuario);

                                $('.container-usuario > ul').append(li);

                            });
                        },

                    });
                }

                $('.bloqueio').click(function () {
                    $('.bloqueio').hide(250);
                    $('.container-usuario').hide(250);
                    $('.container-login').hide(250);
                });

            <c:if test="${param.display_alert && msg == ''}">
                window.location = './home';
            </c:if>
            <c:if test="${existemBoletos != null && existemBoletos != 'false'}">
//                efetuarLogin();
            </c:if>
            });

            function usuariosComPermissao() {
                $('.container-usuario').show(250);
                $('.bloqueio').show(250);
            }

            function efetuarLogin() {
                $('.container-login').show(250);
                $('.bloqueio').show(250);
            }

            function logarUsuario() {
                if ($('#usuario').val().trim() === '') {
                    $('#usuario').css('background', '#ffe3e3');
                    return false;
                } else {
                    $('#usuario').css('background', '');
                }

                if ($('#senha').val().trim() === '') {
                    $('#senha').css('background', '#ffe3e3');
                    return false;
                } else {
                    $('#senha').css('background', '');
                }

                $.ajax({
                    url: 'UsuarioControlador',
                    type: 'POST',
                    data: {
                        acao: 'verificarPermissao',
                        login: $('#usuario').val(),
                        senha: $('#senha').val()
                    },
                    complete: function (jqXHR, textStatus) {
                        if (jqXHR.responseText.trim() === '4') {
                            $('.bloqueio').hide(250);
                            $('.container-login').hide(250);
                            
                            jQuery('.cobre-tudo').css('background', 'rgba(0,0,0,1)');
                            jQuery('.cobre-tudo').css('opacity', '0.5');
                            jQuery('.cobre-tudo').show(250, function () {
                                jQuery('.container-iframe-boletos').css('visibility', 'visible');
                            });
                        } else {
                            $('.bloqueio').hide(250);
                            $('.container-login').hide(250);
                            
                            $('#msgBoleto').text('Você não tem permissão para acessar a tela de boletos. Para visualizar os usuários que tem essa permissão ');
                            $('#linkBoleto').text('clique aqui!');
                            $('#linkBoleto').attr('onclick','usuariosComPermissao()');
                        }
                    }
                });
            }

        </script>
    </head>
    <body>
        <header>
            <img src="${homePath}/assets/img/logo.png">
            <div class="dados-cliente">
                <!--<label style="font-size: 14px;"><b>CPF/CNPJ: 102.129.844-11</b></label>-->
            </div>
        </header>
        <div class="bloqueio"></div>
        <div class="container-login">
            <div class="topo-container-login">Login</div>
            <div class="corpo-container-login">
                <div class="cont-label">Usuário :</div>
                <div class="cont-input"><input type="text" name="usuario" id="usuario" value=""></div>
                <div class="cont-label">Senha &nbsp;&nbsp;:</div>
                <div class="cont-input"><input type="password" name="senha" id="senha" value=""></div>
                <div class="cont-button">
                    <input type="button" value="Entrar" onclick="logarUsuario()">
                </div>
            </div>
        </div>
        <div class="container-usuario">
            <ul>
            </ul>
        </div>
        <section>
            <div class="faixa"></div>
            <div class="container-block">
                <div class="container-label" topo-msg>
                    <label class="title-section" titulo-msg>Sistema bloqueado</label>
                </div>
                <div class="icon-lock" style="float: left">
                    <div class="lock-top-1" style="background: #8B0000;"></div>
                    <div class="lock-top-2"></div>
                    <div class="lock-espaco"></div>
                    <div class="lock-body" style="background: #8B0000;"></div>
                    <div class="lock-hole"></div>
                </div>
                <div class="dados-licenca">
                    <p>Contratante : <b>${contratante}</b></p>
                    <p>
                        Ultima verificação online: <b>${ultimaVerificacao != null ? ultimaVerificacao : "Não disponível"}&nbsp;</b>
                        <a href="#" verificar onclick="verificar();">Verificar agora</a>
                    </p>
                    <br>
                    <p motivo-bloqueio>Motivo do bloqueio: <b msg-bloqueio>${msg != null ? msg : "Não disponível"}</b></p>
                    <br>
                    <p id="msgBoleto">Existem boletos disponíveis para pagamento que ainda não foram impressos, <div class="abrir-impressao-boleto" id="linkBoleto">clique aqui para imprimi-los </div></p>
                    <%--<c:if test="${existemBoletos != null && existemBoletos != 'false'}">--%>
                    <%--</c:if>--%>
                    <!--<p id="msgBoleto">Para visualizar os boletos em aberto é necessário efetuar o login.</p>-->
                    <!--<p ><a href="#" onclick="efetuarLogin();">Efetuar Login</a></p>-->
                    <!--<p>Você não tem permissão para acessar a tela de boletos.<br> Para visualizar os usuários que tem essa permissão <a href="#" onclick="usuariosComPermissao();">clique aqui!</a> </p>-->
                </div>
            </div>
        </section>
        <div class="container-iframe-boletos">
            <img class="fechar-iframe-boletos" src="assets/img/fechar_cinza.png">
            <iframe src="" class="iframe-boletos" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
        </div>
        <div class="cobre-tudo" id="cobre-tudo-menu-item" style=""></div>
        <div class="container-cards">
            <div class="card">
                <div class="card-geral" style="display: none;" card-conexao>
                    <div class="container-label">
                        <label class="title-section" style="font-size: 16px;">Conexão com o servidor da GW Sistemas</label>
                    </div>
                    <img src="${homePath}/licenca/conection_stop.gif" class="img-connection">
                    <div class="footer-card">
                        <div class="bt bt-conexao">Testar Conexão</div>
                        <span class="span-aviso" style="">
                            Conectado com sucesso. Para atualizar seu arquivo de configuração clique em "Verificar agora"
                        </span>
                    </div>
                </div>
            </div>
        </div>
        <footer>
        </footer>
    </body>
</html>