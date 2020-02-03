<%-- 
    Document   : localizacao_google_maps
    Created on : 22/06/2013, 15:31:20
    Author     : Gleidson
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
        <script type="text/javascript">
           
            var latlang = new Array();
            var infomations = new Array();

            function gMaps() {
                var infowindow = null;

                var myOptions = {
                    zoom: 18,
                    center: latlang[latlang.length - 1],
                    mapTypeId: google.maps.MapTypeId.ROADMAP
                };

                var map = new google.maps.Map(document.getElementById("maps"), myOptions);

                var flightPath = new google.maps.Polyline({
                    path: latlang,
                    strokeColor: "#FF0000",
                    strokeOpacity: 1.0,
                    strokeWeight: 2
                });
                
                var i = 0;
                while (i < latlang.length) {
                    var marker = null;
                    if (i == 0) {
                        marker = new google.maps.Marker({
                            position: latlang[i],
                            map: map,
                            icon: "../imagens/home.png",
                            title: "Início",
                            html: infomations[i]
                        }); 
                    } else if (i == (latlang.length - 1)) {
                        marker = new google.maps.Marker({
                            position: latlang[i],
                            map: map,
                            title: "Fim",
                            html: infomations[i]
                        }); 
                    } else {
                    
                        marker = new google.maps.Marker({
                            position: latlang[i],
                            map: map,
                            icon: "../imagens/circle_red.png",
                            title: "Ver sincronização",
                            html: infomations[i]
                        });
                    }

                    var contentString = "Some content";

                    google.maps.event.addListener(marker, "click", function () {
                        infowindow.setContent(this.html);
                        infowindow.open(map, this);
                    });
                    infowindow = new google.maps.InfoWindow({
                        content: "loading..."
                    });

                    
                    i++;
                }

                flightPath.setMap(map);
            }
            
            function getMapPoints() {
                
                
                var kind = $('input#tipo:checked').val();
                var parametros = "";
                if (kind == 1) {
                    var key = $("#portador").val();
                    if (empty(key)) {
                        alert("Favor selecione ao menos 1 portador!");
                        return;
                    }
                    parametros = "portadorID="+key;
                } else {
                    var key = $("#dispositivo").val();
                    if (empty(key)) {
                        alert("Favor selecione ao menos 1 dispositivo!");
                        return;
                    }
                    parametros = "rastreadorID="+key;
                }
                
                var preciso = true;
                if ($("#preciso").attr("checked") != "checked") {
                    preciso = false;
                }
                
                parametros += "&begin="+$("#calendar").val() + " " + $("#timeBegin").val();
                parametros += "&end="+$("#calendar").val() + " " + $("#timeEnd").val();
                //                parametros += "&preciso=" + preciso;
                $.ajax({
                    type : "POST",
                    url : "getMapPoints",
                    data : parametros,
                    dataType : "json",
                    beforeSend : function (){
                        var ap = "<div style='position: fixed; z-index: 9; width: 120px; "+
                            "height: 30px; background-color: #C80000; color: #FFFFFF; top: 0; "+
                            "left: 50%; margin-left: -60px; text-align: center; line-height: 30px; "+
                            "font-weight: bold; border-radius: 0px 0px 10px 10px' id='alert'>";
                        ap += "Acompanhando...";
                        ap += "</div>";
                        $("body").append(ap);
                    },
                    complete : function (){
                        $("#alert").remove();
                    },
                    success: function(json){
                        
                        if (json.localizacoes != null && json.localizacoes.length > 0) {
                        
                            infomations = null;
                            infomations = new Array();
                            var latitude = "";
                            var longitude = "";
                            latlang = new Array(); // abrir um novo ponteiro (atualizando por data)
                            latlang.length = 0;

                            var size = json.localizacoes.length - 1;
                            for (var i in json.localizacoes) {

                                latitude = json.localizacoes[i].latitude;
                                longitude = json.localizacoes[i].longitude;

                                latlang.push(new google.maps.LatLng(latitude,longitude));

                                var velocidade = parseFloat(json.localizacoes[i].velocidade) * 3.6;
                                velocidade = velocidade.toFixed(0);
                                var precisao = parseFloat(json.localizacoes[i].precisao);
                                precisao = precisao.toFixed(0);
                                if (precisao > 1000) {
                                    precisao = (precisao / 1000).toFixed(1) + "k";
                                }

                                var tempoProvedor = timestampToPtBr(json.localizacoes[i].tempoProvedorGlobal);
                                var html = "";
                                if (i == 0) {
                                    html = "<h1 class='maps'>In&iacute;cio do Trajeto</h1>";
                                } else if (i == size) {
                                    html = "<h1 class='maps'>&Uacute;ltima sincroniza&ccedil;&atilde;o</h1>";
                                } else {
                                    html = "<h1 class='maps'>" + (infomations.length + 1) + "ª sincroniza&ccedil;&atilde;o</h1>";
                                }
                            
                                html += "<p class='maps'>Posi&ccedil;&atilde;o obtidas em: <strong>"+ tempoProvedor +"</strong></p>";
                                html += "<p class='maps'>Provedor: <strong>"+ json.localizacoes[i].provedor +"</strong></p>";
                                html += "<p class='maps'>Precis&atilde;o: <strong>"+ precisao +"m</strong></p>";
                                html += "<p class='maps'>Velocidade: <strong>"+ velocidade +"km/h</strong></p>";
                                html += "<p class='maps'>Posi&ccedil;&atilde;o: <strong>"+ latitude +", "+ longitude +"</strong></p>";
                            
                                infomations.push(html);

                            }
                            gMaps();
                        } else {
                            alert("O sistema não retornou nenhum registro para o filtro informado.\n\nExiste duas razões para isso:\n" + 
                                "1ª Você está procurando fora do expediente programado para o portador.\n" + 
                                "2ª O rastreador possivalmente está sem conexão com internet e por causa disso não sincronizou com o servidor, nesse caso tente mais tarde.");
                        }

                    },
                    error : function (){
                        alert("Erro ao processar a informação");
                        $("#alert").remove();
                    }
                });
            }

            function timestampToPtBr(time) {
                var ano = time.substr(0, 4);
                var mes = time.substr(5, 2);
                var dia = time.substr(8, 2);
                var hora = time.substr(11, 2);
                var minuto = time.substr(14, 2);
                var segundo = time.substr(17, 2);

                return dia + "/" + mes + "/" + ano + " " + hora + ":" + minuto + ":" + segundo;
            }

        </script>
        <style type="text/css">
            #maps {
                width: 100%;
                height: 400px;
            }

            .maps {
                font-size: 12px;
            }

            p.maps {
                padding: 0px;
                margin: 0px 0px 5px 0px;
            }

            .pesquisa {
                font-size: 14px;
                text-shadow: none
            }

            .pesquisa select {
                width: 500px;
            }

            .pesquisa input[type=text], select, button, option {
                font-size: 14px;
            }

            table#tipoPesquisa {
                width: 500px;
                height: auto;
                border-width: 1px;
                border-collapse: collapse;
                margin-bottom: 10px;
            }

            table#tipoPesquisa td {
                width: 500px;
                line-height: 25px;
                border: solid 1px #aaa;
            }

            table#tipoPesquisa td label {
                width: 470px;
                display: block;
            }

            table#tipoPesquisa td label span {
                background-color: #D5D5D5;
                height: 25px;
                width: 25px;
                display: block;
                float: left;
                margin-right: 5px;
                text-align: center;
                line-height: 25px;
            }

        </style>
    </head>
    <body>
        <div id="maps"></div>
    </body>
</html>
