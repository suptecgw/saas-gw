<%-- 
    Document   : layoutVideo
    Created on : 30/06/2016, 11:55:55
    Author     : anderson
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <jsp:include page="importAlerts.jsp">
        <jsp:param name="caminhoImg" value="assets/img/gw-sistemas.png"/>
        <jsp:param name="nomeUsuario" value="${param.nome}"/>
    </jsp:include>
    <head>
        <link href="css/layoutVideo.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <script>
            jQuery(document).ready(function () {
                jQuery('.cobre-video-centro').on('click', function (ev) {
                    jQuery('.cobre-video-centro').css("display", "none");
                    jQuery(".ifram-video")[0].src += "&autoplay=1";
                    gravarAcaoUsuario('a');
                    ev.preventDefault();
                });

                jQuery('.img-topo-sair').on('click', function (ev) {
                    jQuery(".ifram-video")[0].src = "";
                    jQuery('.container-video-centro').css("display", "none");
                    jQuery('.div-aguarde-pagina').css("display", "none");
                });


                jQuery('.img-topo-sair').hover(
                        function () {
                            jQuery('.lb-sair').css('transform', 'scale(1.1)');
                        },
                        function () {
                            jQuery('.lb-sair').css('transform', 'scale(1.0)');
                        }
                );
            });
        </script>

        <div class="div-aguarde-pagina"></div>
        <div class="container-video-centro">
            <div class="topo-container">
                <img src="assets/img/logo.png" class="img-topo-logo" id="logo-gw" title="GW Sistemas"/>
                <label class="lb-sair">Sair</label>
                <img src="assets/img/sair.png" class="img-topo-sair" id="sair" />
            </div>
            <div class="body-container">
                <div class="cobre-video-centro"></div>
                <iframe id="iframe-video" class="ifram-video" style="border-radius: 5px;" src="${param.url}" width="480" height="372" scrolling="no" frameborder="0" allowfullscreen></iframe>
            </div>
            <div class="footer-container">
                <center><div class="nao-assisti-agora" onclick="chamarAlert('<label style=' + 'text-align:right;' + '>Você optou em não assistir esse video, não se preocupe a qualquer momento você podera assisti-lo acessando o seu perfil.</label>', pulou);">Não quero assistir</div></center>
            </div>
        </div>
    </body>
    <script src="assets/js/jquery-1.9.1.min.js"></script>
     <script src="${homePath}/assets/js/ElementsGW.js" type="text/javascript"></script>
    <script type="text/javascript">
               
                    function pulou() {
                        jQuery(".ifram-video")[0].src = "";
                        gravarAcaoUsuario('p');
                    }
                    // parametros:
                    // ação:
                    // retorno :
                    function gravarAcaoUsuario(acao) {
                        jQuery.ajax({
                            url: 'VideoControlador',
                            dataType: "text",
                            method: "post",
                            async: false,
                            data: {
                                acao: "gravarAcaoUsuario",
                                videoId: "${param.idVideo}",
                                acaoNoVideo: acao
                            },
                            success: function (data) {
                                if (acao !== "a") {
                                    jQuery('.container-video-centro').css("display", "none");
                                    jQuery('.div-aguarde-pagina').css("display", "none");
                                }
                            }
                        });
                    }

    </script>
</html>
<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
<script type='text/javascript' src='script/jQuery/jquery-ui.js'></script>