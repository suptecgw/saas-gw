<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=ISO-8859-1" %>
<link href="${homePath}/assets/css/bootstrap-custom-col.css?v=${random.nextInt()}" rel="stylesheet">
<link rel="stylesheet" href="${homePath}/assets/css/consulta.css?v=${random.nextInt()}">
<link rel="stylesheet" href="${homePath}/assets/css/pops/alterarSenha.css?v=${random.nextInt()}">
<script defer src="${homePath}/assets/js/jquery-1.9.1.min.js?v=${random.nextInt()}"></script>
<script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
<script defer src="${homePath}/assets/js/pops/alterarSenha.js?v=${random.nextInt()}"></script>
<div class="div-mudar-senha" style="background: url('${homePath}/assets/img/pattern_bg.png');">
    <div class="topo-senha">
        <img class="logomarca" src="${homePath}/assets/img/logo.png">
        <label>Alteração de senha</label>
        <img class="img-senha-fechar" src="${homePath}/assets/img/fechar_new.png" alt="Fechar" title="Fechar">
    </div>
    <form id="formSenha">
        <div class="corpo-senha">
            <div class="row">
                <input type="hidden" id="usuarioId" name="usuarioId" data-serialize-campo="usuarioId"
                       value="${param.usuarioId}">
                <input type="hidden" id="statusErro" name="statusErro" value="${param.st}">

                <div class="col-md-12" style="text-align: center">
                    <label class="label-informacao">
                        <c:choose>
                            <c:when test="${param.st == '004'}">
                                Por questões de segurança a sua senha deverá ser renovada.
                            </c:when>
                        </c:choose>
                    </label>
                </div>
                <div class="col-md-12">
                    <div class="col-md-5">
                        <label for="nomeUsuario" class="label-corpo">Nome:</label>
                    </div>
                    <div class="col-md-7">
                        <label id="nomeUsuario">${param.nomeUsuario}</label>
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="col-md-5">
                        <label for="senhaAtual" class="label-corpo">Senha atual:</label>
                    </div>
                    <div class="col-md-7">
                        <input id="senhaAtual" name="senhaAtual" type="password" class="input-dados"
                               data-serialize-campo="senhaAtual">
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="col-md-5">
                        <label for="senhaNova" class="label-corpo">Nova senha:</label>
                    </div>
                    <div class="col-md-7">
                        <input id="senhaNova" name="senhaNova" type="password" class="input-dados"
                               data-serialize-campo="senhaNova">
                    </div>
                </div>
                <div class="col-md-12">
                    <div class="col-md-5">
                        <label for="repetirSenha" class="label-corpo">Repetir nova senha:</label>
                    </div>
                    <div class="col-md-7">
                        <input id="repetirSenha" name="repetirSenha" type="password" class="input-dados"
                               data-serialize-campo="repetirSenha">
                    </div>
                </div>
            </div>
        </div>
        <div class="rodape-senha">
            <button type="submit" name="btnSalvar" class="btnSalvar" style="width: 25%">
                <img class="img-btn" src="${homePath}/assets/img/salvar_new.png"><label>Salvar</label>
            </button>
            <button name="btnCancelar" class="btnSalvar" style="width: 25%">
                <img class="img-btn" src="${homePath}/assets/img/fechar.png"><label>Cancelar</label>
            </button>
        </div>
    </form>

</div>
<div class="div-tela-toda"></div>