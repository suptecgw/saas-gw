<%-- 
    Document   : imagem-cliente
    Created on : 28/11/2016, 16:47:04
    Author     : Mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
    <head>
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${param.nome}"/>
        </jsp:include>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <title>GW Trans - Visualização de Documentos de Contrato Comercial</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <script src="${homePath}/assets/js/material.js" type="text/javascript"></script>
        <link href="${homePath}/assets/css/material.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <script src="${homePath}/script/validarSessao.js" type="text/javascript"></script>
        <link defer rel="stylesheet" href="${homePath}/assets/css/consulta-imagem.css?v=${random.nextInt()}">
        <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${param.tema}.css?v=${random.nextInt()}">
        <script>
            var idcontrato = '${param.idContrato}';
            var numero = '${param.numero}';
            var filial = '${param.filial}';

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

            function fecharVisualizarContrato() {
                parent.fecharVisualizarContrato();
            }

            function visualizaImagem(imagem) {
                window.open("${homePath}/ImagemControlador?acao=imgpdf&imagem=" + imagem.trim() + "&idcontrato=" + idcontrato, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }

            function createFormAndSubmit() {

                var arqImg01 = jQuery('#input-perfil-upload').val();

                if (arqImg01 == "") {
                    alert("Selecione a Imagem!");
                    return false;
                }

                var extensoesOk = ",.gif,.jpg,.pdf,.xml,.doc,.docx,.png,";
                var extensao = "," + arqImg01.substr(arqImg01.length - 4).toLowerCase() + ",";

                //validação para aceitar documento com a extensao .docx
                if (extensao == ",docx,") {
                    extensao = "," + arqImg01.substr(arqImg01.length - 5).toLowerCase() + ",";
                }

                if (extensoesOk.indexOf(extensao) == -1) {
                    return alert("Extensão de Arquivo Inválida!");
                }

                var descricao = jQuery('#descricao').val();
                
                var action = '${homePath}/ImagemControlador?acao=cadastrar&idcontrato=' + idcontrato + '&numero=' + numero + '&descricao=' + descricao + '&isFoto=' + false;

                jQuery('body').append(jQuery('<form id="formImg" target="pop" method="POST" enctype="multipart/form-data" action="' + action + '">'));

                jQuery('#formImg').append(jQuery('#input-perfil-upload'));

                window.open('about:blank', 'pop', 'width=210, height=100');

                jQuery('#formImg').submit();
            }



            function excluir() {
                location.replace("${homePath}/ImagemControlador?acao=excluir&idImagem=" + getValueCheckMarcados() + "&idcontrato=" + idcontrato + "&numero" + numero);
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

                <div class="gw-img-geral-A-titulo">Visualização de Documentos de Contrato</div>

                <img src="${homePath}/assets/img/sair.png" class="gw-img-geral-A-sair" onclick="fecharVisualizarContrato();">
            </div>
            <div class="gw-img-geral-B">

                <input type="file" class="input-perfil-upload" id="input-perfil-upload" name="input-perfil-upload">
                <div class="container-upload" id="container-upload">
                    <center>
                        <div style="margin-top: 5px;float: left;margin-top: 15px;margin-left: 30px;">
                            <label style="font-size: 12px;font-weight: bold;margin-top:10px;color:#999;">Arraste um documento ou imagem para cá</label>
                            <br>
                            <label style="font-size: 12px;font-weight: bold;margin-top: 10px;color: #999;">- ou -</label>
                            <br>
                            <div class="div-input-file">Selecionar um arquivo</div>
                            <label id="arquivo-nome" style="font-size: 12px;color: #666;"></label>
                        </div>
                    </center>
                </div>
                <div class="container-descricao">
                    <label style="width: 100%;float: left;margin-top: 16px;color: #777;font-size: 15px;font-weight: bold;margin-left: 14px;">Descrição do documento</label>
                    <center>
                        <div class="mdl-textfield mdl-js-textfield" style="width: 90%;padding: 5px 0;font-size: 13px;">
                            <textarea class="mdl-textfield__input" type="text" rows= "3" id="descricao" name="descricao" style="font-size: 15px;" ></textarea>
                            <label class="mdl-textfield__label" for="descricao" style="top: 7px;bottom: -15px !important;font-size: 15px;">Descrição</label>
                        </div>
                    </center>
                </div>
                <div class="container-salvar">
                    <center>
                        <button class="bt-salvar" onclick="createFormAndSubmit();">Salvar</button>
                    </center>
                </div>

            </div>
            <div class="gw-img-geral-B-2">
                <div style="width: 100%;max-width: 100%;height: 200px;text-align: center;">
                    <style>

                    </style>
                    <table class="tb-arquivos">
                        <thead>
                            <tr>
                                <th style="width: 10%;">
                        <center>
                            <input type="checkbox" id="marcarTodos">
                        </center>                                    
                        </th>
                        <th style="width: 20%;">
                            Imagem
                        </th>
                        <th style="width: 70%;text-align: left;">
                            <label style="margin-left: 5px;">Descrição</label>
                        </th>
                        </tr>
                        </thead>
                        <tbody style="overflow-y: scroll;">
                            <c:forEach var="imagem" varStatus="status" items="${listaListImagem}">                
                                <tr class="${(status.count % 2 == 0 ? 'tdEscura' : 'tdClara')}" id="tr_${status.count}">
                                    <c:choose>
                                        <c:when test="${status.count == 0 && imagem.isFoto()}">
                                            <td>TEst</td>
                                        </c:when>
                                        <c:when test="${status.count == 0 && !imagem.isFoto()}">
                                            <td>TEst2</td>
                                        </c:when>
                                        <c:otherwise>
                                            <td>
                                    <center>
                                        <input type="checkbox" id="check${status.count}" name="check${status.count}" value="${imagem.getId()}">
                                    </center>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${imagem.getExtensao().trim().equalsIgnoreCase('jpg') || imagem.getExtensao().trim().equalsIgnoreCase('png') || imagem.getExtensao().trim().equalsIgnoreCase('gif')}">
                                                <img width="50px" height="50px" src="${homePath}/img/contrato/${imagem.getContratoId()}_${imagem.getId()}.${imagem.getExtensao().trim()}" class="imagemLink2"
                                                     onclick="visualizaImagem('/img/contrato/${imagem.getContratoId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                                            </c:when>
                                            <c:when test="${imagem.getExtensao().trim().equalsIgnoreCase('pdf')}">
                                                <img width="50px" height="50px" src="${homePath}/assets/img/pdf-icon.png" class="imagemLink2" 
                                                     onclick="visualizaImagem('/img/contrato/${imagem.getContratoId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                                            </c:when>
                                            <c:when test="${imagem.getExtensao().trim().equalsIgnoreCase('xml')}">
                                                <img width="50px" height="50px" src="${homePath}/assets/img/xml-icon.png" class="imagemLink2" 
                                                     onclick="visualizaImagem('/img/contrato/${imagem.getContratoId()}_${imagem.getId()}.${imagem.getExtensao().trim()}');" style="cursor: pointer" alt="Documento">
                                            </c:when>
                                            <c:otherwise>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:out escapeXml="true" value="${imagem.getDescricao()}" />
                                    </td>
                                </c:otherwise>
                            </c:choose>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="gw-img-geral-C">
                <center>
                    <button class="bt-excluir bt-disabled" disabled onclick="parent.excluirImagem();">Excluir</button>
                </center>
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
                    // Impede possíveis tratamentos dos arquivos
                    // arrastados pelo navegador, por exemplo, exibir
                    // o conteudo do mesmo.
                    e.stopPropagation();
                    e.preventDefault();
                    // Quando o arquivo está sobre área alteramos o seu estilo
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
    </script>
</html>
