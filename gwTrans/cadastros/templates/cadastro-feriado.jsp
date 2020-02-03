<%-- 
    Document   : cadastro-feriado
    Created on : 28/12/2017, 12:01:19
    Author     : mateus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-feriado.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
</head>
<body>
    <div class="container-form">
        <div class="col-md-12 celula-zebra">
            <div class="container-campos">
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Descrição</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input type="hidden" name="acao" value="cadastrar" data-serialize-campo="acao">
                        <input type="hidden" name="id" value="0" data-serialize-campo="id">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="30" data-serialize-campo="descricao"
                               placeholder="Descrição" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!">
                    </span>
                </div>
                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Dia</div>
                    </div>
                    <select name="slc-dia" id="slc-dia" class="ativa-helper2" data-serialize-campo="slc-dia">
                        <option value="0" selected>Selecione</option>
                        <option value="1">01</option>
                        <option value="2">02</option>
                        <option value="3">03</option>
                        <option value="4">04</option>
                        <option value="5">05</option>
                        <option value="6">06</option>
                        <option value="7">07</option>
                        <option value="8">08</option>
                        <option value="9">09</option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                        <option value="13">13</option>
                        <option value="14">14</option>
                        <option value="15">15</option>
                        <option value="16">16</option>
                        <option value="17">17</option>
                        <option value="18">18</option>
                        <option value="19">19</option>
                        <option value="20">20</option>
                        <option value="21">21</option>
                        <option value="22">22</option>
                        <option value="23">23</option>
                        <option value="24">24</option>
                        <option value="25">25</option>
                        <option value="26">26</option>
                        <option value="27">27</option>
                        <option value="28">28</option>
                        <option value="29">29</option>
                        <option value="30">30</option>
                        <option value="31">31</option>
                    </select>
                </div>
                <div class="col-md-3 ">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Mês</div>
                    </div>
                    <select name="slc-mes" id="slc-mes" class="ativa-helper" data-serialize-campo="slc-mes">
                        <option value="0" selected>Selecione</option>
                        <option value="1">Janeiro</option>
                        <option value="2">Fevereiro</option>
                        <option value="3">Março</option>
                        <option value="4">Abril</option>
                        <option value="5">Maio</option>
                        <option value="6">Junho</option>
                        <option value="7">Julho</option>
                        <option value="8">Agosto</option>
                        <option value="9">Setembro</option>
                        <option value="10">Outubro</option>
                        <option value="11">Novembro</option>
                        <option value="12">Dezembro</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Ano</div>
                    </div>
                    <select name="slc-ano" id="slc-ano" class="ativa-helper" data-serialize-campo="slc-ano">
                        <option value="0" selected>Todos os anos</option>
                        <option value="2013">2013</option>
                        <option value="2014">2014</option>
                        <option value="2015">2015</option>
                        <option value="2016">2016</option>
                        <option value="2017">2017</option>
                        <option value="2018">2018</option>
                        <option value="2019">2019</option>
                        <option value="2018">2020</option>
                        <option value="2021">2021</option>
                        <option value="2022">2022</option>
                        <option value="2023">2023</option>
                        <option value="2024">2024</option>
                        <option value="2025">2025</option>
                        <option value="2026">2026</option>
                        <option value="2027">2027</option>
                        <option value="2028">2028</option>
                        <option value="2029">2029</option>
                        <option value="2030">2030</option>
                        <option value="2031">2031</option>
                        <option value="2032">2032</option>
                        <option value="2033">2033</option>
                        <option value="2034">2034</option>
                        <option value="2035">2035</option>
                        <option value="2036">2036</option>
                        <option value="2037">2037</option>
                        <option value="2038">2038</option>
                        <option value="2039">2039</option>
                        <option value="2040">2040</option>
                        <option value="2041">2041</option>
                        <option value="2042">2042</option>
                        <option value="2043">2043</option>
                        <option value="2044">2044</option>
                        <option value="2045">2045</option>
                        <option value="2046">2046</option>
                        <option value="2047">2047</option>
                        <option value="2048">2048</option>
                        <option value="2049">2049</option>
                        <option value="2050">2050</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Tipo de Feriado</div>
                    </div>
                    <select name="slc-tipo" id="slc-tipo" class="ativa-helper" data-serialize-campo="slc-tipo">
                        <option value="n" selected>Nacional</option>
                        <option value="e">Estadual</option>
                        <option value="m">Municipal</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                        <div class="section-check-conferente">
                            <input id="ck-finan" name="ck-finan" type="checkbox" data-serialize-campo="ck-finan"
                                   class="chk-save" >
                            <label for="ck-finan">
                                <span></span>
                                Setor Financeiro
                            </label>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="container-input-form-gw input-width-80 ativa-helper1 checkbox-input">
                        <div class="section-check-conferente">
                            <input id="ck-opera" name="ck-opera" type="checkbox" data-serialize-campo="ck-opera"
                                   class="chk-save" >
                            <label for="ck-opera">
                                <span></span>
                                Setor Operacional
                            </label>
                        </div>
                    </div>
                </div>
                <div class="localiza">
                </div>
            </div>
        </div>
        <div class="col-md-2" id="container-dom-estado" hidden>
            <div class="container-campos">
                <div class="top-dom ativa-helper-data-ajuda" data-ajuda="header-dom-estado">
                    <div style="margin-bottom: 0px;width: 45px;float: left;">
                        <div class="header-dom">
                            <img src="${homePath}/gwTrans/cadastros/img/plus-dom.png" alt="Novo Estado"/> 
                        </div>
                    </div>
                    <div class="col-md-2" style="margin-bottom: 0px;">
                        <div class="body-dom" style="">
                            <label class="title-dom">Estado</label>
                        </div>
                    </div>
                </div>
                <div class="body">
                </div>
            </div>
        </div>
        <div class="col-md-2" id="container-dom-municipio" hidden>
            <div class="container-campos">
                <div class="top-dom ativa-helper-data-ajuda" data-ajuda="header-dom-municipio">
                    <div style="margin-bottom: 0px;width: 45px;float: left;">
                        <div class="header-dom">
                            <img src="${homePath}/gwTrans/cadastros/img/plus-dom.png" alt="Novo Municipio"/> 
                        </div>
                    </div>
                    <div class="col-md-2" style="margin-bottom: 0px;">
                        <div class="body-dom" style="">
                            <label class="title-dom">Municipio</label>
                        </div>
                    </div>
                </div>
                <div class="body">
                </div>
            </div>
        </div>
        <!-- Estado -->
        <input type="hidden" id="header-dom-estado" name="header-dom-estado">
        <input type="hidden" id="estado" name="estado"> 
        <input type="hidden" id="icone-excluir-estado" name="icone-excluir-estado">
        <!-- Municipio -->
        <input type="hidden" id="header-dom-municipio" name="header-dom-municipio">
        <input type="hidden" id="icone-excluir-municipio" name="icone-excluir-municipio">

        <input type="hidden" id="excluidosDOMEstado" name="excluidosDOMEstado" data-serialize-campo="excluidosDOMEstado">
        <input type="hidden" id="excluidosDOMCidade" name="excluidosDOMCidade" data-serialize-campo="excluidosDOMCidade">
    </div>
</div>
<img class="gif-bloq-tela" src="${homePath}/img/espere_new.gif" alt=""/>
<div class="bloqueio-tela"></div>
<div class="localiza">
    <iframe id="localizarCidade" name="localizarCidade" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarCidade" frameborder="0" marginheight="0" marginwidth="0" scrolling="no"></iframe>
</div>
<script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}" type="text/javascript"></script>
<script src="${homePath}/gwTrans/cadastros/js/cadastro-feriado.js?v=${random.nextInt()}" type="text/javascript"></script>
</body>