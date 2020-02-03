<%-- 
    Document   : atualizador
    Created on : 28/05/2017, 20:50:51
    Author     : Jean
--%>
<%@page import="nucleo.Apoio"%>
<%
    request.setAttribute("versao", Apoio.WEBTRANS_VERSION);
    request.setAttribute("numeroProjeto", 0);
%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>GW - Atualizador</title>
        <style>
            html,body{
                height: 100%;
                overflow: hidden;
                font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;
                padding: 0;
                margin: 0;
            }

            header{
                width: 100%;
                float: left;
                position: relative;
                height: 70px;
                box-shadow: 0 1px 3px #0c253e;
                z-index: 9;
            }

            .container-nome-page{
                height: 100%;
                width: 28%;
                background: #0c253e url(img/trans_white.png) no-repeat;
                background-size: 80px;
                background-position-x: 95%;
                background-position-y: 20px;
                float: left;
            }

            .nome-tela{
                color: #a0c2e4;
                font-weight: bold;
                font-size: 20px;
                margin-top: 20px;
                margin-left: 10px;
            }

            section{
                position: relative;
                float: left;
                height: calc(100% - 70px);
                width: 100%;
            }


            .coluna-ajuda{
                width: 2%;
                background: #13385c;
                float: left;
                height: 100%;
                position: relative;
            }

            .bt-ajuda{
                font-size: 15px !important;
                background: #13385c url(img/seta-ajuda.png) no-repeat;
                background-position-x: 7px;
                background-position-y: 8px;
                background-size: 19px;
                width: 160px;
                padding-top: 10px;
                padding-bottom: 10px;
                position: absolute;
                color: #FFF;
                transform: rotate(90deg);
                top: 100px;
                right: -90px;
                border-radius: 7px;
                text-align: center;
                cursor: pointer;
            }

            .bt-ajuda:hover{
                right: -85px;
                transition: all .2s ease-in-out;
            }

            .div-principal{
                width: calc(100% - 8%);
                height: 80%;
                top: 10%;
                left: 6%;
                border-radius: 10px;
                box-shadow: 0px 3px 1px 1px #CCC;
                position: absolute;
                background: #e8eced;
                border: 2px solid #ccc;
                margin: 0 auto;
            }

            .topo-div-principal{
                border-radius: 10px 10px 0 0;
                width: 100%;
                height: 50px;
                position: relative;
                background: #FFF;
                float: left;
                z-index: 9;
                box-shadow: 0px 3px 1px 0px rgba(120,120,120,0.3);
            }

            .topo-div-principal > span{
                width: 100%;
                float: left;
                text-align: center;
                color: #555;
                margin-top: 13px;
                font-family: 'Open Sans', Arial, sans-serif;
                font-size: 18px;
            }
            .atualizar{
                width: 40px;
                position: absolute;
                right: 10px;
                top: 5px;
                opacity: 0.7;
                transition: all 0.2s ease-in-out;
            }

            .atualizar:hover{
                cursor: pointer;
                transform: scale(0.9);
            }


            .coluna-direita-div-principal{
                width: 25%;
                height: calc(100% - 50px);
                float: left;
                border-radius: 0 0 0 10px;
                overflow: hidden;
            }

            .ul-menu-coluna-direita{
                overflow-y: auto;
                overflow-x: hidden;
                background: #505d71;
                height: 100%;
                width: 100%;
                float: left;
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .ul-menu-coluna-direita > li{
                color: #bcc3d0;
                padding-top: 15px;
                padding-bottom: 15px;
                border-bottom: 2px solid rgba(188,195,208,0.4);
                text-align: center;
                font-family: 'Open Sans', Arial, sans-serif;
                font-size: 1em;
                /*background: #445166;*/
            }

            .ul-menu-coluna-direita > li:hover{
                background: #445166;
                cursor: pointer;
            }

            .menu-coluna-escolhido{
                color: #FFF !important;
                background: #2d3747 !important;
            }

            .coluna-esquerda-div-principal{
                width: 75%;
                height: calc(100% - 50px);
                float: left;
                border-radius: 0 0 10px 0;
                overflow: hidden;
                position: relative;
            }

            .ul-menu-coluna-esquerda{
                position: absolute;
                overflow-y: auto;
                overflow-x: hidden;
                height: 100%;
                width: 100%;
                float: left;
                list-style: none;
                padding: 0;
                margin: 0;
                overflow-y: auto;
                overflow-x: hidden;
                border-radius: 5px;
            }

            .ul-menu-coluna-esquerda > li{
                width: 100%;
                padding-top: 5px;
                padding-bottom: 5px;
                border-bottom: 2px solid rgba(160,160,160,0.5);
                text-align: left;
                font-family: 'Open Sans', Arial, sans-serif;
                float: left;
                background: #c1c7cc;
            }
            .ul-menu-coluna-esquerda > li:nth-child(even){
                background: #9fa8b1;
            }

            nomeProjeto{
                font-size: 1em;
                font-family: 'Open Sans', Arial, sans-serif;
                width: calc(50% - 10px);
                padding-top: 5px;
                padding-bottom: 5px;
                padding-left: 10px;
                float: left;
                color: #444;
                font-weight: bold;
                border-bottom: 1px dotted #ccc;
            }

            downloadProjeto{
                width: calc(50% - 10px);
                padding-left: 10px;
                padding-top: 5px;
                padding-bottom: 5px;
                float: left;
            }

            dataLancamento{
                font-size: 0.9em;
                font-family: 'Open Sans', Arial, sans-serif;
                width: calc(30% - 10px);
                padding-top: 2px;
                padding-bottom: 2px;
                padding-left: 10px;
                float: left;
                color: #444;
            }

            novidadeVersao{
                font-size: 0.9em;
                font-family: 'Open Sans', Arial, sans-serif;
                width: calc(50% - 10px);
                padding-top: 2px;
                padding-bottom: 2px;
                padding-left: 10px;
                float: left;
                color: #444;
            }

            .img-loader{
                display: none;
                width: 40px;
                margin-right: 30%;
                float: right;
            }

            .bt-baixar{
                margin-left: calc(100% - 210px);
                cursor: pointer;
                width: 140px;
                border-radius: 5px;
                background: #011a3e;
                padding: 5px 0 5px 0;
                text-align: center;
                color: #FFF;
                font-family: 'Yanone Kaffeesatz', sans-serif;
                font-size: 13px;
            }

            .bt-baixar:hover{
                box-shadow: 0px 2px 0px 0px rgba(120,120,120,0.5),inset 0px 2px 1px 0px rgba(255,255,255,0.5);
                transform: scale(0.97);
            }

            .bt-atualizar{
                margin-left: calc(100% - 210px);
                cursor: pointer;
                width: 140px;
                border-radius: 5px;
                background: #011a3e;
                padding: 5px 0 5px 0;
                text-align: center;
                color: #FFF;
                font-family: 'Yanone Kaffeesatz', sans-serif;
                font-size: 13px;
            }

            .bt-atualizar:hover{
                box-shadow: 0px 2px 0px 0px rgba(120,120,120,0.5),inset 0px 2px 1px 0px rgba(255,255,255,0.5);
                transform: scale(0.97);
            }

            versao{
                position: absolute;
                width: auto;
                padding-top: 5px;
                padding-right: 10px;
                padding-bottom: 5px;
                bottom: 6px;
                right: 16px;
                font-size: 15px;
                font-weight: bold;
                color: #13385c;
                font-weight: bold;
            }

            .cobre-tudo{
                display: none;
                position: absolute;
                background: rgba(255,255,255,0.7) url(img/carregando.gif) no-repeat center;
                width: 100%;
                height: 100%;
                z-index: 9999;
                left: 0;
                top: 0;
            }

            .atualizando{
                display: none;
                width: 500px;
                height: 400px;
                overflow-y: auto;
                overflow-x: hidden;
                position: absolute;
                z-index: 99999;
                top: calc(50% - 200px);
                left: calc(50% - 250px);
                background: #FFF;
                border-radius: 10px;
                box-shadow: 0px 1px 3px 2px #CCC;
            }

            .atualizando ul{
                list-style: none;
                margin: 0;
                padding: 0;
                overflow: auto;
            }

            .atualizando ul li{
                color: #AAAAAA;
                display: block;
                position: relative;
                float: left;
                width: 100%;
                height: 100px;
                border-bottom: 1px solid #333;
            }

            .atualizando ul li input[type=radio]{
                position: absolute;
                visibility: hidden;
            }

            .atualizando ul li label{
                display: block;
                position: relative;
                font-weight: 300;
                font-size: 1.35em;
                padding: 25px 25px 25px 80px;
                margin: 10px auto;
                height: 30px;
                z-index: 9;
                cursor: pointer;
                -webkit-transition: all 0.25s linear;
            }

            .atualizando ul li:hover label{
                /*color: #FFFFFF;*/
            }

            .atualizando ul li .check{
                display: block;
                position: absolute;
                border: 5px solid #AAAAAA;
                border-radius: 100%;
                height: 25px;
                width: 25px;
                top: 30px;
                left: 20px;
                z-index: 5;
                transition: border .25s linear;
                -webkit-transition: border .25s linear;
            }

            .atualizando ul li:hover .check {
                /*                border: 5px solid #FFFFFF;*/
            }

            .atualizando ul li .check::before {
                display: block;
                position: absolute;
                content: '';
                border-radius: 100%;
                height: 15px;
                width: 15px;
                top: 5px;
                left: 5px;
                margin: auto;
                transition: background 0.25s linear;
                -webkit-transition: background 0.25s linear;
            }

            .atualizando input[type=radio]:checked ~ .check {
                /*border: 5px solid #00964a;*/
            }

            .atualizando input[type=radio]:checked ~ .check::before{
                /*background: #00964a;*/
            }

            .atualizando input[type=radio]:checked ~ label{
                /*color: #00964a;*/
            }
        </style>
    </head>
    <body>
        <header>
            <div class="container-nome-page">
                <div class="nome-tela">
                    GW - Atualizador
                </div>
            </div>
        </header>
        <section>
            <div class="coluna-ajuda">
                <div class="bt-ajuda">
                    Mostrar Ajuda
                </div>
            </div>
            <div class="div-principal">
                <div class="topo-div-principal"><span></span><img class="atualizar" src="img/atualizar.jpg"></div>
                <div class="coluna-direita-div-principal">
                    <ul class="ul-menu-coluna-direita ">
                        <li class="menu-coluna-escolhido">Projetos Disponíveis</li>
                        <li>Projetos Baixados</li>
                    </ul>
                </div>
                <div class="coluna-esquerda-div-principal">
                    <div projetosDisponiveis>
                        <ul class="ul-menu-coluna-esquerda" ul-projetos-disponiveis>
                        </ul>
                    </div>
                    <div projetosBaixados style="display: none;">
                        <ul class="ul-menu-coluna-esquerda" ul-projetos-baixados></ul>
                    </div>
                </div>
            </div>
        </section>
    <versao>
        Versão atual: ${versao}
    </versao>
    <div class="cobre-tudo"></div>
    <div class="atualizando">
        <ul>
            <li>
                <input type="radio" id="f-option" name="s-ativas">
                <label for="f-option">Removendo sessões ativas</label>
                <div class="check"></div>
            </li>
            <li>
                <input type="radio" id="s-option" name="s-bp-dados">
                <label for="s-option">Fazendo backup da base de dados</label>
                <div class="check"><div class="inside"></div></div>
            </li>
            <li>
                <input type="radio" id="t-option" name="s-atualizando-dados">
                <label for="t-option">Atualizando a base de dados</label>
                <div class="check"><div class="inside"></div></div>
            </li>
            <li>
                <input type="radio" id="t-option" name="s-bp-projetos">
                <label for="t-option">Fazendo backup dos projetos</label>
                <div class="check"><div class="inside"></div></div>
            </li>
            <li>
                <input type="radio" id="t-option" name="s-atualizando-projetos">
                <label for="t-option">Atualizando projetos</label>
                <div class="check"><div class="inside"></div></div>
            </li>
        </ul>
    </div>
    <script src="js/jquery-3.2.1.min.js" type="text/javascript"></script>
    <script src="js/xmlToJson.js" type="text/javascript"></script>
    <script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
    <jsp:include page="/importAlerts.jsp">
        <jsp:param name="caminhoImg" value="${homePath}/assets/img/gw-trans.png"/>
        <jsp:param name="nomeUsuario" value="${user.nome}"/>
    </jsp:include>
    <script>
        "use strict";
        var linkLib = '';
        var versao = '${param.versao != null ? param.versao : "0"}';
        var numero = 0;
        var jsonProjetos = '';
        jQuery(function () {
            jQuery('.ul-menu-coluna-direita > li').click(function (e) {
                alternarMenu(e.target);
            });
            jQuery('.atualizar').click(function () {
                atualizarProjetosDisponiveis();
            });
            atualizarProjetosDisponiveis();
            jQuery.ajax({
                url: "${homePath}/AtualizadorControlador?acao=checkLib",
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.responseText.trim() == 'false') {
                        chamarAlert('Por algum motivo não localizamos a sua biblioteca do atualizador, não se preocupe iremos baixá-la novamente!', baixarLib);
                    }
                }
            });
        });
        function baixarLib() {
            jQuery('.cobre-tudo').show();
            jQuery.ajax({
                url: "https://s3.amazonaws.com/gwVersoes/gwAtualizador/config_xml/lib.json",
                dataType: "jsonp",
                complete: function (jqXHR, textStatus) {
                    jQuery.ajax({
                        url: "${homePath}/AtualizadorControlador?acao=baixarLib&link=" + linkLib,
                        complete: function (jqXHR, textStatus) {
                            if (jqXHR.responseText.trim() == 'true') {
                                chamarAlert('Obrigado por esperar, já baixamos e atualizamos sua biblioteca com sucesso. <br> Agora você pode prosseguir com o processo de atualização.');
                                jQuery('.cobre-tudo').hide(250);
                            } else {
                                chamarAlert('Ops! ouve um problema na tentativa de atualizar a lib, sem ela não conseguimos continuar. <br> A página será fechada.', window.close);
                            }
                        }
                    });
                }
            });
        }

        function getUrlLib(json) {
            linkLib = json["linkDownload"];
        }

        function alternarMenu(target) {
            let i = 0;
            jQuery(".ul-menu-coluna-direita > li").each(function (index, e) {
                (e == target ? i = index : false);
            });
            jQuery('.menu-coluna-escolhido').removeClass('menu-coluna-escolhido');
            jQuery(target).addClass('menu-coluna-escolhido');
            switch (i) {
                case 0:
                    jQuery('[projetosBaixados]').hide(100, function () {
                        jQuery('[projetosDisponiveis]').show(100);
                    });
                    break;
                case 1:
                    jQuery('[projetosDisponiveis]').hide(100, function () {
                        jQuery('[projetosBaixados]').show(100);
                    });
                    break;
            }
        }

        function gwsistemas(json) {
            jsonProjetos = json;
            jQuery('[ul-projetos-disponiveis]').html('');
            var i = 0;
            console.log(json);
            while (json["projetos"][i]) {
                var projeto = json["projetos"][i];
                if (true) {
                    console.log(projeto);
                    let li = jQuery('<li>');
                    let nomeProjeto = jQuery('<nomeProjeto>').text(projeto.versao);
                    li.append(nomeProjeto);
                    let downloadProjeto = jQuery('<downloadProjeto>');
                    let div = jQuery('<div class="bt-baixar" onclick="baixarProjeto(this)">').html('Download');
                    let meter = jQuery('<img class="img-loader" src="img/support-loading.gif">');
                    li.append(downloadProjeto.append(div).append(meter));
                    let dataLancamento = jQuery('<dataLancamento>').text(projeto.lancamento);
                    li.append(dataLancamento);
                    let aNovidades = jQuery('<a>').text('Novidades da versão').attr('href', '#').click(function () {
                        let LeftPosition = (screen.width) ? (screen.width - 400) / 2 : 0;
                        let TopPosition = (screen.height) ? (screen.height - 400) / 2 : 0;
                        window.open(projeto.linkNovidades, "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=" + TopPosition + ",left=" + LeftPosition + ",width=400,height=400");
                    });
                    let novidadeVersao = jQuery('<novidadeVersao>').html(aNovidades);
                    li.append(novidadeVersao);
                    let inputLink = jQuery('<input type="hidden" inpLinkProjeto>').val(projeto.linkProjeto);
                    li.append(inputLink);
                    inputLink = jQuery('<input type="hidden" inpLinkBase>').val(projeto.linkBase);
                    li.append(inputLink);
                    jQuery('[ul-projetos-disponiveis]').append(li);
                }
                i++;
            }
        }

        function atualizarProjetosDisponiveis() {
            jQuery.ajax({
                url: "https://s3.amazonaws.com/gwVersoes/gwAtualizador/config_xml/projetos.json",
                dataType: "jsonp",
                complete: function (jqXHR, textStatus) {
                    projetosBaixados();
                }
            });
        }

        var element = null;
        function atualizarProjetos(e) {
            element = e;
            chamarAlert('Iremos começar o processo de atualização.<br> É de extrema importância que você continue na página para acompanhar o processo.', atualizando);
        }

        function atualizando() {
            jQuery('.atualizando').show();
            jQuery('.cobre-tudo').show();
            jQuery('.atualizando input[name=s-ativas] ~.check').css('border', '5px solid #00964a');
            jQuery('.atualizando input[name=s-ativas] ~.check::before').css('background', '#00964a');
            jQuery('.atualizando input[name=s-ativas] ~ label').css('color', '#00964a');
            //AJAX BP BASE
            jQuery.ajax({
                url: "${homePath}/AtualizadorControlador?acao=bpBase",
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.responseText.trim() === "false") {
                        jQuery('.atualizando input[name=s-bp-dados] ~.check').css('border', '5px solid #00964a');
                        jQuery('.atualizando input[name=s-bp-dados] ~.check::before').css('background', '#00964a');
                        jQuery('.atualizando input[name=s-bp-dados] ~ label').css('color', '#00964a');
                        chamarAlert('Não foi possível realizar o backup da base, click em "ok" para prosseguir', atualizarBase);
                    }
//                        setTimeout(function () {
//                            jQuery('.atualizando input[name=s-atualizando-projetos] ~.check').css('border', '5px solid #00964a');
//                            jQuery('.atualizando input[name=s-atualizando-projetos] ~.check::before').css('background', '#00964a');
//                            jQuery('.atualizando input[name=s-atualizando-projetos] ~ label').css('color', '#00964a');
//                            setTimeout(function () {
//                                window.location = '/WT-ATUALIZADOR';
//                            }, 5000);
//                        }, 10000);
                }
            });
        }

        function atualizarBase() {
            jQuery.ajax({
                url: "${homePath}/AtualizadorControlador?acao=atualizarBase&arquivo=" + $(element).parent().parent().find('nomeProjeto').html().trim(),
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.responseText.trim() === 'true') {
                        jQuery('.atualizando input[name=s-atualizando-dados] ~.check').css('border', '5px solid #00964a');
                        jQuery('.atualizando input[name=s-atualizando-dados] ~.check::before').css('background', '#00964a');
                        jQuery('.atualizando input[name=s-atualizando-dados] ~ label').css('color', '#00964a');
                        criarBackUpProjeto();
                    } else {
                        jQuery('.atualizando input[name=s-atualizando-dados] ~.check').css('border', '5px solid #00964a');
                        jQuery('.atualizando input[name=s-atualizando-dados] ~.check::before').css('background', '#00964a');
                        jQuery('.atualizando input[name=s-atualizando-dados] ~ label').css('color', '#00964a');
                        criarBackUpProjeto();
//                        chamarAlert(jqXHR.responseText.trim(), criarBackUpProjeto);
                    }
                }
            });
        }

        function criarBackUpProjeto() {
            jQuery.ajax({
                url: "${homePath}/AtualizadorControlador?acao=backUpProjeto",
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.responseText.trim() === 'true') {
                        jQuery('.atualizando input[name=s-bp-projetos] ~.check').css('border', '5px solid #00964a');
                        jQuery('.atualizando input[name=s-bp-projetos] ~.check::before').css('background', '#00964a');
                        jQuery('.atualizando input[name=s-bp-projetos] ~ label').css('color', '#00964a');
                        atualizarProjeto();
                    } else {
                        jQuery('.atualizando input[name=s-bp-projetos] ~.check').css('border', '5px solid #00964a');
                        jQuery('.atualizando input[name=s-bp-projetos] ~.check::before').css('background', '#00964a');
                        jQuery('.atualizando input[name=s-bp-projetos] ~ label').css('color', '#00964a');
                        atualizarProjeto();
//                        chamarAlert('Ocorreu um erro ao tentar gerar o backup do projeto, a página será recarregada.', atualizarProjeto);
                    }
                }
            });
        }

        function atualizarProjeto() {
            jQuery.ajax({
                url: "${homePath}/AtualizadorControlador?acao=atualizarProjeto&projeto=" + $(element).parent().parent().find('nomeProjeto').html().trim(),
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.responseText.trim() === 'true') {
                        chamarAlert('Projeto atualizado com sucesso, você vai ser redirecionado.', sucesso);
                    } else {
                        chamarAlert('Ocorreu um erro ao atualizar o projeto, a página será recarregada.', reload);
                    }
                }
            });
        }

        function sucesso() {
            setTimeout(function () {
                jQuery('.atualizando input[name=s-atualizando-projetos] ~.check').css('border', '5px solid #00964a');
                jQuery('.atualizando input[name=s-atualizando-projetos] ~.check::before').css('background', '#00964a');
                jQuery('.atualizando input[name=s-atualizando-projetos] ~ label').css('color', '#00964a');
                window.location = '../index.jsp';
            }, 2500);
        }

        function baixarProjeto(e) {
            jQuery(e).hide();
            jQuery(e).parent().find('.img-loader').show(100);
            let nome = jQuery(e).parent().parent().find('nomeProjeto').text();
            let linkProjeto = jQuery(e).parent().parent().find('[inpLinkProjeto]').val();
            let linkBase = jQuery(e).parent().parent().find('[inpLinkBase]').val();
            jQuery.ajax({
                url: '${homePath}/AtualizadorControlador?acao=baixarProjeto&linkProjeto=' + linkProjeto + '&linkBase=' + linkBase + '&nomeProjeto=' + nome,
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.responseText.trim() == 'true') {
                        setTimeout(function () {
                            chamarAlert('O projeto "' + nome + '" foi baixado com sucesso.');
                            projetosBaixados();
                        }, 1500);
                    } else {
                        projetosBaixados();
                        chamarAlert('Erro no download <br>' + jqXHR.responseText.trim());
                    }
                }
            });
        }

        function projetosBaixados() {
            jQuery.ajax({
                url: '${homePath}/AtualizadorControlador?acao=projetosBaixados',
                complete: function (jqXHR, textStatus) {
                    if (jqXHR.status !== 404) {
                        jQuery('[ul-projetos-baixados]').html('');
                        for (var i = 0; i <= jqXHR.responseText.split(',').length; i++) {
                            if (jqXHR.responseText.split(',')[i] && jqXHR.responseText.split(',')[i].trim() != '') {
                                var i = 0;
                                while (jsonProjetos["projetos"][i]) {
                                    var projeto = jsonProjetos["projetos"][i];
                                    if (projeto.versao === jqXHR.responseText.split(',')[i].trim()) {
                                        let li = jQuery('<li>');
                                        let nomeProjeto = jQuery('<nomeProjeto>').text(projeto.versao);
                                        li.append(nomeProjeto);
                                        let downloadProjeto = jQuery('<downloadProjeto>');
                                        let div = jQuery('<div class="bt-baixar" onclick="atualizarProjetos(this)">').html('Atualizar');
                                        let meter = jQuery('<img class="img-loader" src="img/support-loading.gif">');
                                        li.append(downloadProjeto.append(div).append(meter));
                                        let dataLancamento = jQuery('<dataLancamento>').text(projeto.lancamento);
                                        li.append(dataLancamento);
                                        let aNovidades = jQuery('<a>').text('Novidades da versão').attr('href', '#').click(function () {
                                            let LeftPosition = (screen.width) ? (screen.width - 400) / 2 : 0;
                                            let TopPosition = (screen.height) ? (screen.height - 400) / 2 : 0;
                                            window.open(projeto.linkNovidades, "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=" + TopPosition + ",left=" + LeftPosition + ",width=400,height=400");
                                        });
                                        let novidadeVersao = jQuery('<novidadeVersao>').html(aNovidades);
                                        li.append(novidadeVersao);
                                        let inputLink = jQuery('<input type="hidden" inpLinkProjeto>').val(projeto.linkProjeto);
                                        li.append(inputLink);
                                        inputLink = jQuery('<input type="hidden" inpLinkBase>').val(projeto.linkBase);
                                        li.append(inputLink);
                                        jQuery('[ul-projetos-baixados]').append(li);

                                        jQuery.each(jQuery('[ul-projetos-disponiveis]').find('li'), function (key, value) {
                                            if ($(this).find('nomeProjeto').html().trim() === projeto.versao.trim()) {
                                                $(this).remove();
                                            }
                                        });
                                    }
                                    i++;
                                }
                            }
                        }
                    }
                }
            });
        }

        function soNumeros(str) {
            return str.replace(/[^0-9.]/g, "");
        }

        function reload() {
            window.location.reload();
        }
    </script>
</body>
</html>
