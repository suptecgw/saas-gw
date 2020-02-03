<%-- 
    Document   : index
    Created on : 14/12/2016, 17:47:12
    Author     : root
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <script src="${homePath}/assets/js/jquery-1.9.1.min.js"></script>
        <link href="${homePath}/assets/css/select-multiplo-gw.css" rel="stylesheet" type="text/css" />
        <script src="${homePath}/assets/js/ElementsGW.js" type="text/javascript"></script>
    </head>
    <body style="background: #13385c;">
        <style>

            .container-select-multiplo-gw{
                float: left;
                width: 300px;

            }

            .container-select-multiplo-gw-A{
                width: 100%;
                float: left;
            }

            .container-select-multiplo-gw-A span{
                width: 100%;
                float: left;
                font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;
                font-size: 14px;
                color: #fff;
                font-weight: bold;
                margin-bottom: 5px;
            }
            .container-select-multiplo-gw-A input{
                width: 100%;
                float: left;
                color: #fff;
                font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;
                font-size: 14px;
                background: transparent;
                padding-bottom: 5px;
                border: 0;
                border-bottom: 1px solid rgba(255,255,255,0.38);
            }

            .container-select-multiplo-gw-A input[type="text"]:focus{
                outline: none;
                border-bottom: 1.3px solid #fff;
            }

            .container-select-multiplo-gw-A ul{
                display: none;
                margin: 0;
                padding: 0;
                list-style: none;
                width: 100%;
                float: left;
                margin-top: 5px;

                max-height: 150px;
                overflow-y: scroll;
                overflow-x: hidden;
            }

            .container-select-multiplo-gw-A ul li{
                float: left;
                font-family: 'Century Gothic', CenturyGothic, AppleGothic, sans-serif;
                color: #666;
                font-size: 13px;
                width: 100%;
                background: #fff;
                border: 0.5px solid rgba(188,188,188,0.5);
                padding-top: 10px;
                padding-bottom: 10px;
                cursor: pointer;
            }

            .container-select-multiplo-gw-A ul li:hover{
                background: #dadada;
            }

            .container-select-multiplo-gw-A ul li img{
                float: left;
                width: 20px;
                margin-left: 10px;
                margin-right: 5px;
            }
            .container-select-multiplo-gw-A ul li label{
                float: left;
                margin-top: 3px;
                cursor: pointer;
            }
        </style>
        <script></script>
        <div>
            <script>
                var homePath = '${homePath}';
                jQuery(document).ready(function () {
                    jQuery('#select-tipo-fornecedor').selectMultiploGw({
                        'titulo': 'Apenas os Tipos de Fornecedor'
                    });
                });
            </script>
            <div class="item_form" style="margin-bottom: 10px;">
                <select id="select-tipo-fornecedor" name="select-tipo-fornecedor">
                    <option value="test01">Teste 01</option>
                    <option value="test02">Teste 02</option>
                    <option value="test03">Teste 03</option>
                    <option value="test04">Teste 04</option>
                </select>
            </div>   
            <script>
//                var homePath


//
//                jQuery(document).ready(function () {
//
//                    jQuery('.container-select-multipla-escolha-gw span').click(function () {
//                        if (jQuery('.container-select-multipla-escolha-gw ul').css('display') == 'none') {
//                            jQuery('.container-select-multipla-escolha-gw ul').show(250);
//                        } else {
//                            jQuery('.container-select-multipla-escolha-gw ul').hide(250);
//
//                        }
//                    });
//
//                    var campoComFoco = false;
//
//                    jQuery('.container-select-multiplo-gw-A input').focusin(function () {
//                        jQuery('.container-select-multiplo-gw-A ul').show(250);
//                        campoComFoco = true;
//                    }).focusout(function () {
//                        campoComFoco = false;
//                        setTimeout(function () {
//                            if (!campoComFoco) {
//                                jQuery('.container-select-multiplo-gw-A ul').hide(250);
//                            }
//                        }, 250);
//                    });
//
//                    jQuery('.container-select-multiplo-gw').click(function () {
//                        jQuery('.container-select-multiplo-gw-A input[type="text"]').focus();
//                    });
//
//                    jQuery('.container-select-multiplo-gw-A ul li').find('input[type="checkbox"]').click(function (event) {
//
//                        jQuery(this).parent('li').trigger('click');
//                        event.preventDefault();
//                    });
//
//                    jQuery('.container-select-multiplo-gw-A ul li').click(function () {
//                        var valAtual = jQuery('#tipos-escolhidos').val();
//                        if (valAtual.length > 0 && valAtual.charAt(valAtual.length - 1) != ',') {
//                            valAtual += ',';
//                        }
//
//                        console.log(jQuery(this).find('img').attr('src'));
//
//                        if (jQuery(this).find('img').attr('src').indexOf("checked") !== -1) {
//                            jQuery(this).css('background', '#fff');
//
//                            if (valAtual.length > 0) {
//                                valAtual = valAtual.replace(jQuery(this)[0].innerText + ',', '');
//                            }
//                            if (valAtual.charAt(valAtual.length - 1) == ',') {
//                                valAtual = valAtual.substr(0, valAtual.length - 1);
//                            }
//                            jQuery(this).find('img').attr('src', '${homePath}/assets/img/chk.png');
//                            jQuery('#tipos-escolhidos').val(valAtual);
//                        } else {
//                            jQuery(this).css('background', '#efefef');
//
//                            jQuery(this).find('img').attr('src', '${homePath}/assets/img/chk_checked.png');
//
//                            jQuery('#tipos-escolhidos').val(valAtual + jQuery(this)[0].innerText);
//                        }
//                    });
//                });
            </script>
            <!--            <div class="container-select-multiplo-gw">
                            <div class="container-select-multiplo-gw-A">
                                <span>Apenas os Tipos de Fornecedor</span>
                                <input type="text" readonly="true" id="tipos-escolhidos">
                            </div>
                            <div class="container-select-multiplo-gw-A">
                                <ul>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_ajudante">Ajudante</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_vendedor">Vendedor</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_agente_pagador">Agente pagador</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_seguradora">Seguradora</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_companhia_aerea">Companhia Aérea</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_fornecedor_combustivel">Fornecedor de Combustível</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_agente_carga">Agente de carga</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_proprietario">Proprietário</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_redespachante">Redespachante</label></li>
                                    <li><img src="${homePath}/assets/img/chk.png"><label id="is_gerenciador_risco">Gerenciador de risco</label></li>
                                </ul>
                            </div>
                        </div>-->


        </div>
    </body>
</html>
