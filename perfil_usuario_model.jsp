<%-- 
    Document   : perfil_usuario_model
    Created on : 29/09/2016, 11:14:28
    Author     : marcus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="assets/css/jquery.Jcrop.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <div class="cobre-tudo"></div>
        <div class="div-alterar-imagem-perfil">
            <div class="topo-img-perfil">
                <label class="topo-label-perfil">Selecionar foto do perfil</label>
                <img src="assets/img/close-boleto.png" style="float: right;cursor: pointer;" id="fechar-img-upload">
            </div>
            <div class="centro-img-perfil">
                <form id="formImg" method="POST" enctype="multipart/form-data" action="">
                    <input type="file" class="input-perfil-upload" id="input-perfil-upload" name="input-perfil-upload">
                </form>
                <input type="hidden" id="x" name="x" />
                <input type="hidden" id="x2" name="x2" />
                <input type="hidden" id="y" name="y" />
                <input type="hidden" id="y2" name="y2" />
                <input type="hidden" id="w" name="w" />
                <input type="hidden" id="h" name="h" />
                <img id="img-resize" style="display: block;" width="1px" height="1px" src="">
                <div class="container-upload" id="container-upload">
                    <center>
                        <img src="assets/img/upload.png" width="300px" height="200px" style="margin-top:10px;opacity: 0.5;">
                        <div style="margin-top: 20px;">
                            <label style="font-size: 30px;font-weight: bold;margin-top:10px;color:#999;">Arraste uma foto de perfil para cá</label>
                            <br>
                            <label style="font-size: 25px;font-weight: bold;margin-top: 10px;color: #999;">- ou -</label>
                            <br>
                            <div class="div-input-file">Selecionar uma foto</div>
                            <span id="testa"></span>
                        </div>
                    </center>
                </div>
            </div>
            <div class="bottom-img-perfil">
                <div class="btn-definir-perfil" onclick="salvarImagemPerfil();">Definir como foto do perfil</div>
                <div class="btn-cancelar-foto-perfil">Cancelar</div>
            </div>
        </div>

        <div class="perfil-user" title="${user.nome}">
            <center>
                <img src="img/usuario/default-perfil.png" class="img-perfil-icon" style="width: 60px;height: 60px;" id="icon-perfil">
            </center>
        </div>
        <div class="seta-perfil"></div>
        <div class="seta-perfil-sombra"></div>
        <div class="opcoes-perfil">
            <div class="mudar-foto">
                <center>
                    <img src="img/usuario/default-perfil.png" class="img-perfil" style="width:90px;height:90px;" id="img-perfil">
                </center>
                <div class="alter-foto-perfil">Alterar Foto</div>
            </div>
            <div class="campos-perfil">
                <div class="nome-user">
                    <label>${user.nome}</label>
                </div>
                <div class="dados-user">
                    <label style="">${user.email}</label>
                </div>
            </div>
            <div class="footer-perfil">
                <div class="btn-edit-perfil" onclick="jQuery('.li-botoes-senha').trigger('click');">Meu perfil</div>
                <div class="btn-sair-perfil" onclick="jQuery('.li-botoes-desconectar').trigger('click');">Desconectar</div>
            </div>
        </div>

    </body>
    <script src="assets/js/jquery.Jcrop.js" type="text/javascript"></script>
    <script>
                jQuery(document).ready(function () {
                    if ('${user.isGerarImagem}' === "true") {
                        jQuery.ajax({
                            url: 'UsuarioControlador?acao=gerarImagemPerfil&idUsuario=' +${user.id} + '&idImagemPerfil=' +${user.idImagemPerfil} + '&modulo=' + '${param.modulo}',
                            dataType: "text",
                            method: "post",
                            complete: function (e, a) {
                                if (e.responseText == 1) {
                                    jQuery('#img-perfil').prop('src', '${homePath}/img/usuario/default-perfil.png');
                                    jQuery('#icon-perfil').prop('src', '${homePath}/img/usuario/default-perfil.png');

                                    jQuery('#icon-perfil').css("width", "60px");
                                    jQuery('#icon-perfil').css("height", "60px");

                                    jQuery('#img-perfil').css("width", "90px");
                                    jQuery('#img-perfil').css("height", "90px");
                                } else {
                                    jQuery('#icon-perfil').prop('src', '${homePath}/img/usuario/usuario${user.id}/perfil_usuario_${user.id}_${user.idImagemPerfil}.png');
                                    jQuery('#icon-perfil').css("width", "75px");
                                    jQuery('#icon-perfil').css("height", "75px");
                                    jQuery('#img-perfil').prop('src', '${homePath}/img/usuario/usuario${user.id}/perfil_usuario_${user.id}_${user.idImagemPerfil}.png');
                                    jQuery('#img-perfil').css("width", "100px");
                                    jQuery('#img-perfil').css("height", "100px");
                                }
                            }
                        });
                    } else {

                        jQuery('#icon-perfil').prop('src', '${homePath}/img/usuario/usuario${user.id}/perfil_usuario_${user.id}_${user.idImagemPerfil}.png');
                        jQuery('#img-perfil').prop('src', '${homePath}/img/usuario/usuario${user.id}/perfil_usuario_${user.id}_${user.idImagemPerfil}.png');

                        jQuery('#icon-perfil').css("width", "75px");
                        jQuery('#icon-perfil').css("height", "75px");

                        jQuery('#img-perfil').css("width", "100px");
                        jQuery('#img-perfil').css("height", "100px");
                    }

                    document.getElementById('icon-perfil').onerror = function () {
                        jQuery('#img-perfil').prop('src', '${homePath}/img/usuario/default-perfil.png');
                        jQuery('#icon-perfil').prop('src', '${homePath}/img/usuario/default-perfil.png');

                        jQuery('#icon-perfil').css("width", "60px");
                        jQuery('#icon-perfil').css("height", "60px");

                        jQuery('#img-perfil').css("width", "90px");
                        jQuery('#img-perfil').css("height", "90px");
                    };


                });

                function salvarImagemPerfil() {
                    var form = $('#formImg');

                    var x = document.getElementById("x").value;
                    var x2 = document.getElementById("x2").value;
                    var y = document.getElementById("y").value;
                    var y2 = document.getElementById("y2").value;
                    var w = document.getElementById("w").value;
                    var h = document.getElementById("h").value;

                    if (document.getElementById('input-perfil-upload').files.length === 0) {
                        chamarAlert('Selecione uma imagem');
                        return false;
                    }

                    form.attr("action", "UsuarioControlador?acao=alterarImagemPerfil&x=" + x + "&y=" + y + "&w=" + w + "&h=" + h + "&x2=" + x2 + "&y2=" + y2 + "&modulo=" + '${param.modulo}');
                    form.submit();
                }
    </script>
</html>
