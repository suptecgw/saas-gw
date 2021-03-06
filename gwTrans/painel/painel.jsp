<!DOCTYPE html>
<html>
    <head>
        <title>GW Sistemas - Painel de Controle</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="author" content="Mateus Veloso">

        <!--<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css'>-->
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.4.1/css/all.css" crossorigin="anonymous">
        <link href="css/painel.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
        <header>
            <div class="logo-title">
                <label>GW Painel</label>
                <img src="img/trans_white.png" class="logo-title-gw">
            </div>
        </header>
        <nav class="nav-menu-lateral">
            <label class="title-filtros">Filtros</label>
            <i class="fechar-menu-lateral fa fa-times"></i>
            <ul class="ul-nav-menu-lateral">
                <li class="li-nav-menu-lateral" id="filtros">
                    <i class="fa fa-search" id="filtros"></i>
                </li>
                <li class="li-nav-menu-lateral" id="ajustes">
                    <i class="fa fa-cogs" id="ajustes"></i>
                </li>
            </ul>
            <div class="container-filtros container-filtros-ajustes">
                <label class="lb-filtros-ajustes">Modo de exibição</label>
                <div class="container-estilo-layout">
                    <input type="radio" class="radio-layout" name="estilo-layout" id="estilo-layout-card" checked value="card"/>
                    <label for="estilo-layout-card"><i class="fa fa-address-card icon-modo-layout" ></i></label>
                    <input type="radio" class="radio-layout" name="estilo-layout" id="estilo-layout-table" value="table"/>
                    <label for="estilo-layout-table"><i class="fa fa-table icon-modo-layout"></i></label>
                    <input type="radio" class="radio-layout" name="estilo-layout" id="estilo-layout-grafico" value="grafico"/>
                    <label for="estilo-layout-grafico"><i class="fa fa-chart-bar icon-modo-layout"></i></label>
                    <!--<label for="tipoImpressaoPendenciaMacroPdf"><img src="assets/img/btn_pdf.png" alt=""></label>-->

                    <!--<select id="estilo-layout">-->
                    <!--<option value="table">Tabela</option>-->
                    <!--<option value="card" selected="">Card</option>-->
                    <!--<option value="grafico">Gráficos</option>-->
                    <!--</select>-->
                </div>
                <label class="lb-tempo-resultados">Tempo de atualização dos Resultados</label>
                <div class="container-estilo-layout">
                    <select class="select-atualizar-resultados" id="select-atualizar-resultados">
                        <option value="0" selected="">Não atualizar</option>
                        <option value="5">5 Minutos</option>
                        <option value="10">10 Minutos</option>
                        <option value="20">20 Minutos</option>
                        <option value="30">30 Minutos</option>
                        <option value="60">60 Minutos</option>
                    </select>
                </div>
            </div>
            <div class="container-filtros container-filtros-filtros">
            </div>
        </nav>
        <section class="section-dica">
            <div class="container-dica">
                <i class="icon-caminhao fa fa-truck"></i><label>Veiculo</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-city"></i><label>Cidade</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-address-card"></i><label>Motorista</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-file-alt"></i><label>Conhecimentos</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-weight-hanging"></i><label>Cap.do Veiculo(Kg) / Peso Total(Kg)</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-percent"></i><label>Porcentagem de ocupação</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-info-circle"></i><label>Mais informação</label>
            </div>
            <div class="container-dica">
                <i class="icon-caminhao fa fa-arrows-alt"></i><label>Mudar posição</label>
            </div>
        </section>
        <section class="section-dados sortable">
            <!--            <div class="container-dados ui-state-default">
                            <i class="details fa fa-info-circle"></i>
                            <i class="move fa fa-arrows-alt"></i>
                            <ul class="">
                                <li class="">
                                    <i class="icon-caminhao fa fa-truck"></i>
                                    <label>OYQ-9171</label>
                                </li>
                                <li>
                                    <i class="icon-caminhao fa fa-city"></i>
                                    <label>Recife-PE</label>
                                </li>
                                <li>
                                    <i class="icon-caminhao fa fa-address-card"></i>
                                    <label>Mateus de Paula Veloso - <span>10212984411</span></label>
                                </li>
                                <li>
                                    <i class="icon-caminhao fa fa-file-alt"></i>
                                    <label>4</label>
                                </li>
                                <li>
                                    <i class="icon-caminhao fa fa-weight-hanging"></i>
                                    <label>0,00 / 15.974,22</label>
                                </li>
                                <li>
                                    <i class="icon-caminhao fa fa-percent"></i>
                                    <label>0,00</label>
                                </li>
                            </ul>
                        </div>-->
        </section>
        <section class="section-grafico">
            <!-- amCharts includes -->
            <script src="https://www.amcharts.com/lib/3/amcharts.js"></script>
            <script src="https://www.amcharts.com/lib/3/serial.js"></script>
            <script src="https://www.amcharts.com/lib/3/plugins/responsive/responsive.min.js"></script>

            <!-- Chart container resizing controls -->


            <!-- Chart container (wrapped in another resizable container) -->
            <div class="resizable">
                <div id="chartdiv"></div>
            </div>
        </section>
        <div class="cobre-tudo" onclick="jQuery('.cobre-tudo').hide(); jQuery('.container-mais-informacao').hide()"></div>
        <div class="container-mais-informacao">
                <div class="container-dados ui-state-default">
                    <i class="details fa fa-info-circle"></i>
                    <i class="move fa fa-arrows-alt"></i>
                    <ul class="">
                        <li class="">
                            <i class="icon-caminhao fa fa-truck"></i>
                            <label>OYQ-9171</label>
                        </li>
                        <li>
                            <i class="icon-caminhao fa fa-city"></i>
                            <label>Recife-PE</label>
                        </li>
                        <li>
                            <i class="icon-caminhao fa fa-address-card"></i>
                            <label>Mateus de Paula Veloso - <span>10212984411</span></label>
                        </li>
                        <li>
                            <i class="icon-caminhao fa fa-file-alt"></i>
                            <label>4</label>
                        </li>
                        <li>
                            <i class="icon-caminhao fa fa-weight-hanging"></i>
                            <label>0,00 / 15.974,22</label>
                        </li>
                        <li>
                            <i class="icon-caminhao fa fa-percent"></i>
                            <label>0,00</label>
                        </li>
                    </ul>
                </div>
        </div>
        <script src="https://code.jquery.com/jquery-3.3.1.min.js" crossorigin="anonymous"></script>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
        <script src="js/painel.js" type="text/javascript"></script>
    </body>
</html>
