<%-- 
    Document   : imagem-cliente
    Created on : 28/11/2016, 16:47:04
    Author     : Mateus
--%>

<%@page import="nucleo.imagem.MotoristaImagem"%>
<%@page import="java.util.Collection"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
    <head>
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${param.tema}.css?v=${random.nextInt()}">
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${param.nome}"/>
        </jsp:include>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <title>GW Trans - Visualiza��o de Documentos de Motorista</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <script src="${homePath}/assets/js/material.js" type="text/javascript"></script>
        <link href="${homePath}/assets/css/material.css" rel="stylesheet" type="text/css"/>
        <script src="${homePath}/script/validarSessao.js" type="text/javascript"></script>
        <link href="${homePath}/css/cadastrar_imagem_motorista_3x4.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <script>
            var idmotorista = '${param.idmotorista}';
            var nome = '${param.nome}';
            var cpf = '${param.cpf}';

            jQuery(document).ready(function () {
                jQuery('#marcarTodos').click(function () {
                    if (jQuery(this).prop('checked')) {
                        jQuery('input[type=checkbox]').prop('checked', true);
                        jQuery('.bt-excluir').removeClass('bt-disabled');
                        jQuery('.bt-excluir').attr('disabled', false);
                    } else {
                        var i = 0;
                        var algumMarcado = false;
                        while (jQuery(jQuery('input[type=checkbox]')[i]).prop('checked')) {
                            algumMarcado = true;
                            break;
                        }
                        if (!algumMarcado) {
                            jQuery('input[type=checkbox]').prop('checked', false);
                            jQuery('.bt-excluir').addClass('bt-disabled');
                            jQuery('.bt-excluir').attr('disabled', true);
                        }
                    }
                });

                jQuery('input[type=checkbox]').not('#marcarTodos').click(function () {
                    if (jQuery(this).prop('checked')) {
                        jQuery('.bt-excluir').removeClass('bt-disabled');
                        jQuery('.bt-excluir').attr('disabled', false);
                    } else {
                        jQuery('.bt-excluir').addClass('bt-disabled');
                        jQuery('.bt-excluir').attr('disabled', true);
                    }
                });
            });

            function fecharVisualizarCliente() {
                if (window.opener) {
                    window.close();
                } else {
                    parent.fecharVisualizarCliente();
                }
            }

            function visualizaImagem(imagem) {
                window.open("${homePath}/ImagemControlador?acao=imgpdf&imagem=" + imagem.trim() + "&idmotorista=" + idmotorista, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }

            function createFormAndSubmit() {

                var arqImg01 = jQuery('#input-perfil-upload').val();

                if (arqImg01 == "") {
                    alert("Selecione a Imagem!");
                    return false;
                }

                var extensoesOk = ",.gif,.jpg,.pdf,.xml,.doc,.docx,.png,";
                var extensao = "," + arqImg01.substr(arqImg01.length - 4).toLowerCase() + ",";

                //valida��o para aceitar documento com a extensao .docx
                if (extensao == ",docx,") {
                    extensao = "," + arqImg01.substr(arqImg01.length - 5).toLowerCase() + ",";
                }

                if (extensoesOk.indexOf(extensao) == -1) {
                    return alert("Extens�o de Arquivo Inv�lida!");
                }

                var descricao = jQuery('#descricao').val();

                var action = '${homePath}/ImagemControlador?acao=cadastrar&idmotorista=' + idmotorista + '&nome=' + nome + '&cpf=' + cpf + '&isFoto=true&descricao=Foto motorista';

                jQuery('body').append(jQuery('<form id="formImg" target="pop" method="POST" enctype="multipart/form-data" action="' + action + '">'));

                jQuery('#formImg').append(jQuery('#input-perfil-upload'));

                window.open('about:blank', 'pop', 'width=210, height=100');

                jQuery('#formImg').submit();
            }



            function excluir() {
                location.replace("${homePath}/ImagemControlador?acao=excluir&idImagem=" + getValueCheckMarcados() + "&idmotorista=" + idmotorista + '&nome=' + nome + '&cpf=' + cpf);
            }



            function getValueCheckMarcados() {
                var values = '';

                var i = 0;
                while (jQuery('input[name*=check]:checked')[i] != undefined) {
                    values += jQuery(jQuery('input[name*=check]:checked')[i]).val() + ',';
                    i++;
                }


                return values.substring(0, values.length - 1);
            }



        </script>
    </head>
    <body>
        <div class="gw-img-geral">
            <div class="gw-img-geral-A">
                <img src="${homePath}/assets/img/trans_white.png" class="gw-img-geral-A-modulo">

                <div class="gw-img-geral-A-titulo">Foto 3x4 Motorista</div>

                <img src="${homePath}/assets/img/sair.png" class="gw-img-geral-A-sair" onclick="fecharVisualizarCliente();">
            </div>
            <div class="gw-img-geral-B">

                <input type="file" class="input-perfil-upload" id="input-perfil-upload" accept=".png,.jpg,.jpge,.gif" name="input-perfil-upload" onchange="readURL(this);">
                <div class="container-upload" id="container-upload">
                    <center>
                        <div style="margin-top: 5px;float: left;margin-top: 15px;margin-left: 65px;">
                            <label style="font-size: 12px;font-weight: bold;margin-top:10px;color:#999;">Arraste uma imagem para c�</label>
                            <br>
                            <label style="font-size: 12px;font-weight: bold;margin-top: 10px;color: #999;">- ou -</label>
                            <br>
                            <div class="div-input-file">Selecionar uma imagem</div>
                            <label id="arquivo-nome" style="font-size: 12px;color: #666;/* max-width: 42px; */float: left;width: 165px;overflow: hidden;text-overflow: ellipsis;white-space: nowrap;"></label>
                        </div>
                    </center>
                </div>
                <div class="container-descricao">
                    <label style="width: 100%;text-align: center;float: left;margin-top: 5px;margin-bottom: 5px;color: #777;font-size: 15px;font-weight: bold;margin-left: 14px;">Imagem Selecionada</label>
                    <center>
                        <c:forEach var="mot" varStatus="status" items="${listaListImagem}">
                            <c:if test="${mot.foto == 'true'}">
                                <img src="${homePath}/img/motorista/${mot.motoristaId}_${mot.id}.${mot.extensao}" width="60" height="80" id="img-escolhida">
                            </c:if>
                        </c:forEach>
                    </center>
                </div>
                <div class="container-salvar">
                    <center>
                        <button class="bt-salvar" onclick="createFormAndSubmit();">Salvar</button>
                    </center>
                </div>

            </div>

        </div>
        <form id="formularioDeTeste" name="formularioDeTeste" target="pop" action="ImagemControlador?acao=cadastrar" method="post" enctype="multipart/form-data">

        </form>
    </body>
    <script>
        var div = document.getElementById("container-upload");
        var input = document.getElementById("input-perfil-upload");

        div.addEventListener("click", function () {
            input.click();
        });

        jQuery(document).ready(function () {

            function FileFrame(fileArea, fileTitle) {
                var self = this;
                this.fileArea = fileArea;
                this.fileTitle = fileTitle;
                this.init = function () {
                    // Registrando eventos de drag and drop
                    self.fileArea.addEventListener("dragleave", self.dragHover, false);
                    self.fileArea.addEventListener("dragover", self.dragHover, false);
                    self.fileArea.addEventListener("drop", self.drop, false);
                };
                this.dragHover = function (e) {
                    // Impede poss�veis tratamentos dos arquivos
                    // arrastados pelo navegador, por exemplo, exibir
                    // o conteudo do mesmo.
                    e.stopPropagation();
                    e.preventDefault();
                    // Quando o arquivo est� sobre �rea alteramos o seu estilo
                    self.fileArea.className = (e.type == "dragover" ? "hover" : "");
                };
                this.drop = function (e) {
                    readFile(e.dataTransfer.files[0]);
                };
                this.read = function (file) {
                    readFile(file.dataTransfer.files[0]);
                };
            }

            var area = document.getElementById("container-upload");
            var fileFrameArea = new FileFrame(area, jQuery('#arquivo-nome'));
            fileFrameArea.init();
            function gtEl(id) {
                return document.getElementById(id);
            }

            function readFile(f) {
                if (this.files && this.files[0]) {
                    var FR = new FileReader();
                    jQuery('#arquivo-nome').html(this.files[0].name);
                    FR.readAsDataURL(this.files[0]);
                } else {
                    var FR = new FileReader();
                    jQuery('#arquivo-nome').html(this.files[0].name);
                    FR.readAsDataURL(this.files[0]);
                }
            }

            gtEl("input-perfil-upload").addEventListener("change", readFile, false);
        });

        function readURL(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    $('#img-escolhida').attr('src', e.target.result);
                };
                reader.readAsDataURL(input.files[0]);
            } else {
                var img = input.value;
                $('#img-escolhida').attr('src', img);
            }
        }
    </script>
</html>
