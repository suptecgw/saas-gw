<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=ISO-8859-1" %>
<html>
<head>
    <title>Status ${requestScope['javax.servlet.error.status_code']} - GW Sistemas</title>

    <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,700,900|Lato:100,300,400,700,900"
          rel="stylesheet">
    <link href="${homePath}/assets/css/micromodal.css?v=${random.nextInt()}" rel="stylesheet">
    <link href="${homePath}/assets/css/erro.css?v=${random.nextInt()}" rel="stylesheet">
    <script>
        var codigoErro = "${requestScope['javax.servlet.error.status_code']}";
        var temExcecao = "${stacktrace != null}";
        var javax_servlet_error_message = "${requestScope['javax.servlet.error.message']}"; // esse é um campo de mensagem que é passado na requisição de erro response.sendError(numero, MENSAGEM);
    </script>
    <script defer src="${homePath}/script/jQuery/jquery.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/assets/js/erro.js?v=${random.nextInt()}"></script>
    <script defer src="${homePath}/assets/js/micromodal-0.3.2.min.js?v=${random.nextInt()}"></script>
</head>
<body>
<header class="cabecalho"></header>
<main class="conteudo">
    <div class="conteudo-topo noselect">
        <h1 class="codigo-erro">${requestScope['javax.servlet.error.status_code']}</h1>
        <p class="erro-cabecalho">Ops! Ocorreu algum problema e essa ação não pôde ser completada.</p>
    </div>
    <div class="msg-erro noselect">
        ${configuracaoTecnica.mensagemErro}
    </div>
</main>
<c:if test="${stacktrace != null}">
    <div class="modal micromodal-slide" id="modal-erro" aria-hidden="true">
        <div class="modal__overlay" tabindex="-1" data-micromodal-close>
            <div class="modal__container" role="dialog" aria-modal="true" aria-labelledby="modal-erro-title">
                <header class="modal__header">
                    <h2 class="modal__title" id="modal-erro-title">
                        Informações Técnicas
                    </h2>
                    <button class="modal__close" aria-label="Close modal" data-micromodal-close></button>
                </header>
                <main class="modal__content" id="modal-erro-content">
                    <pre>${stacktrace}</pre>
                </main>
            </div>
        </div>
    </div>
</c:if>
</body>
</html>
