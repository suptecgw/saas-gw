<%-- 
    Document   : listar_roteirizacao
    Created on : 12/03/2015, 18:14:54
    Author     : amanda
--%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<link href="estilo.css" rel="stylesheet" type="text/css">
<link href="${homePath}/assets/css/inputs-gw.css?v=${random.nextInt()}" rel="stylesheet">
<link href="${homePath}/css/coleta.css?v=${random.nextInt()}" rel="stylesheet">
<script language="javascript" type="text/javascript" src="script/jQuery/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/validarSessao.js"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes.js"></script>
<script language="javascript" type="text/javascript" src="script/jQuery/jquery-ui.js"></script>

<script type="text/javascript" language="JavaScript" charset="ISO-8859-1">
    var homePath = '${homePath}';

    var grupoCliente = '${grupoCliente}';
    var setorEntrega = '${setorEntrega}';

    jQuery.noConflict(); 
    
    var listaRotaLocalizada = new Array();
    var listaRotaPadrao = new Array();
    var listaPercuso = new Array();
    var listaFilial = new Array();
    var listaTipoManifesto = new Array();
    
    listaRotaPadrao[1] = new Option(0,"Rota não informada");
    listaPercuso[1] = new Option(0,"----------");     
    listaTipoManifesto[0] = new Option("m", "Rodoviário");
    listaTipoManifesto[1] = new Option("a", "Aéreo");
    listaTipoManifesto[2] = new Option("f", "Aquaviário");
    
    var tamanhoRota;
    var countRotaLocalizada = 0;
    var countRoteirizador = 0;
    var countVeiculo = 1;
    var countRot = 0;
    var countFilial = 0;
    
    function desativarBotoes() {
        var atual = '<c:out value="${param.paginaAtual}"/>';
        var paginas = '<c:out value="${param.paginas}"/>';


        if (atual == '1') {
            document.formularioAnt.botaoAnt.disabled = true;
        }
        if (parseFloat(atual) >= parseFloat(paginas)) {
            document.formularioProx.botaoProx.disabled = true;
        }
    }

    function setDefault() {
            
            document.formulario.operadorConsulta.value = '<c:out value="${param.operadorConsulta}"/>';
            document.formulario.campoConsulta.value = '<c:out value="${param.campoConsulta}"/>';
            document.formulario.valorConsulta.value = '<c:out value="${param.valorConsulta}"/>';
            document.formulario.dataInicial.value = '<c:out value="${param.dataInicial}"/>';
            document.formulario.dataFinal.value = '<c:out value="${param.dataFinal}"/>';
            document.formulario.ufs.value = '<c:out value="${param.ufs}"/>';
            document.formulario.filial.value = '<c:out value="${param.filial}"/>';
            document.formulario.idremetente.value = '<c:out value="${param.idRemetente}"/>';
            document.formulario.rem_rzs.value = '<c:out value="${param.remetente}"/>';
            document.formulario.iddestinatario.value = '<c:out value="${param.idDestinatario}"/>';
            document.formulario.dest_rzs.value = '<c:out value="${param.destinatario}"/>';
            document.formulario.idconsignatario.value = '<c:out value="${param.idConsignatario}"/>';
            document.formulario.redspt_rzs.value = '<c:out value="${param.representante}"/>';
            document.formulario.idredespachante.value = '<c:out value="${param.idRepresentante}"/>';
            
            document.formulario.con_rzs.value = '<c:out value="${param.consignatario}"/>';
            document.formulario.serie.value = '<c:out value="${param.serie}"/>';
            document.formulario.nmanifesto.value = '<c:out value="${param.manifesto}"/>';
            document.formulario.numero_carga.value = '<c:out value="${param.ncargas}"/>';
            document.formulario.pesomaximo.value = '<c:out value="${param.pesoMax}"/>';
            document.formulario.cubagemMaxima.value = '<c:out value="${param.cubagemMax}"/>';
            document.formulario.qtdEntregas.value = '<c:out value="${param.qtdEntrega}"/>';
            document.formulario.vlNfeMaximo.value = '<c:out value="${param.valorNFeMaximo}"/>';
            document.formulario.vlCteMaximo.value = '<c:out value="${param.valorCteMaximo}"/>';
            document.formulario.qtdVolumeMaximo.value = '<c:out value="${param.qtdVolumeMaximo}"/>';
            document.formulario.idCidade.value = '<c:out value="${param.idCidade}"/>';
            document.formulario.cidade.value = '<c:out value="${param.cidade}"/>';
            document.formulario.uf.value = '<c:out value="${param.uf}"/>';
            document.formulario.tipoRoteirizacao.value = '<c:out value="${param.tipoRoteirizacao}"/>';
            document.formulario.tipoCteEmitidos.value = '<c:out value="${param.tipoCteEmitidos}"/>';

            if ('${param.tipoOperacao}' == 't') {
                jQuery("#transferencia").attr("checked", true);
            }else{
                jQuery("#distribuicao").attr("checked", true);
            }
            mostrarFiltros('${param.tipoOperacao}');
            <c:forEach var="filial" varStatus="statusFilial" items="${listaFiliais}"> 
                    listaFilial[++countFilial] = new Option(${filial.idfilial}, '${filial.abreviatura}');
            </c:forEach>
            //Carregando a fililal do usuário logado
            $("filial").value = ('${param.filial}' ? '${param.filial}' : '${param.filialusuario}');
            
            $("lbFilialFiltroE").innerHTML = '${param.descricaoFilialusuario}';
            $("lbFilialFiltroF").innerHTML = '${param.descricaoFilialusuario}';
            
            mudarFilial();
            
            //Regra para alterar a permissão
            if (${param.permiLancCteManif <= 0}) {
                $("filial").disabled = true;
            }
            var tipoAgru = '<c:out value="${param.cAgrupamento}"/>';
            mudarAgrupamento(tipoAgru);
            
    }
    
    function mudarAgrupamento(tipoAgru){
     if (tipoAgru == "pe") {
                jQuery("#peso").attr("checked", true);
                jQuery("#pesomaximo").checked = true;
                jQuery("#pesomaximo").removeAttr("readOnly");
                jQuery("#pesomaximo").removeClass("inputReadOnly");
                jQuery("#pesomaximo").addClass("inputtexto"); 
            }else
            if (tipoAgru == "en") {
                jQuery("#entrega").attr("checked", true);
                jQuery("#qtdEntregas").checked = true;
                jQuery("#qtdEntregas").removeAttr("readOnly");
                jQuery("#qtdEntregas").removeClass("inputReadOnly");
                jQuery("#qtdEntregas").addClass("inputtexto"); 
            }else
            if (tipoAgru == "cb") {
                jQuery("#cubagem").attr("checked", true);
                jQuery("#cubagemMaxima").checked = true;
                jQuery("#cubagemMaxima").removeAttr("readOnly");
                jQuery("#cubagemMaxima").removeClass("inputReadOnly");
                jQuery("#cubagemMaxima").addClass("inputtexto"); 
            }else
            if (tipoAgru == "nf") {
                jQuery("#vlNf").attr("checked", true);
                jQuery("#vlNfeMaximo").checked = true;
                jQuery("#vlNfeMaximo").removeAttr("readOnly");
                jQuery("#vlNfeMaximo").removeClass("inputReadOnly");
                jQuery("#vlNfeMaximo").addClass("inputtexto"); 
            }else
            if (tipoAgru == "ct") {
                jQuery("#vlCte").attr("checked", true);
                jQuery("#vlCteMaximo").checked = true;
                jQuery("#vlCteMaximo").removeAttr("readOnly");
                jQuery("#vlCteMaximo").removeClass("inputReadOnly");
                jQuery("#vlCteMaximo").addClass("inputtexto");
            } else
            if (tipoAgru == "vlu") {
                jQuery("#volume").attr("checked", true);
                jQuery("#qtdVolumeMaximo").checked = true;
                jQuery("#qtdVolumeMaximo").removeAttr("readOnly");
                jQuery("#qtdVolumeMaximo").removeClass("inputReadOnly");
                jQuery("#qtdVolumeMaximo").addClass("inputtexto");
            }

        }
    
    function getRotaPercurso(indexRot, indexVei){
            
            function e(transport){
                var textoresposta = transport.responseText;

                //se deu algum erro na requisicao...
                if (textoresposta == "-1"){
                    alert('Houve algum problema ao requistar os percursos, favor tente novamente. ');
                    return false;
                }else{
                    
                    removerSelectPercuso(indexRot, indexVei);
                    
                    var rota =jQuery.parseJSON(textoresposta).rota;
                    
                   
                    var listPercurso = rota.percursos[0].percurso;
                    
                    var percurso;
                    var slct = $("percurso_"+indexRot+"_"+indexVei);
                    
                    var valor = "0";
                    var desc = "----------";

                    var length = (listPercurso != undefined && listPercurso.length != undefined ? listPercurso.length : 1);

                    for(var i = 0; i < length; i++){

                        if(length > 1){
                            percurso = listPercurso[i];
                            if(i == 0){
                                valor = listPercurso[i].id;
                            }
                        }else{
                            percurso = listPercurso;
                        }
                        if(percurso != null && percurso != undefined){
                            slct.appendChild(Builder.node('OPTION', {value: percurso.id}, percurso.descricao));
                        }
                    }

                }
            }//funcao e()
            
            tryRequestToServer(function(){
                new Ajax.Request("RoteirizacaoControlador?acao=carregarRotaPercursoAjax&rota="+$('rota_'+indexRot+'_'+indexVei).value ,{method:'post', onSuccess: e, onError: e});
            });
        }
     
    function pesquisa() {
        $("formulario").submit();
    }

    function addVeiculos(linhaRoteirizador) {
        
        console.log("linhaRoteirizador");
        
        var maximoRot = $("maxRot").value;

        countVeiculo++;
        countRot = linhaRoteirizador + 1;


        var countV =parseInt($("maxVeiculo_" + linhaRoteirizador).value) + 1;

        var tr = Builder.node("tr", {
            className: "CelulaZebra2",
            id: "idLinha_" + countV + "_" + linhaRoteirizador
        });

        var td0 = Builder.node("td", {
            align: "center",
            class:"TextoCampos",
            width:"5%"
        });

        var img0 = Builder.node("img", {
            class: "imagemLink",
            src: "img/lixo.png",
            onclick: "excluir(" + countV + ", "+linhaRoteirizador+")"

        });

        var inputCk = Builder.node("input", {
            type: "checkbox",
            id: "ckVei_"+linhaRoteirizador+"_" + countV,
            name: "ckVei_"+linhaRoteirizador+"_" + countV
        });

        td0.appendChild(inputCk);

        var td1 = Builder.node("td", {
            align: "center",
            colspan:"1",
            class:"TextoCampos",
            width:"10%"
        });
        var td1_1 = Builder.node("td", {
            align: "center",
            colspan:"1",
            class:"TextoCampos",
            width:"5%"
        });

        var td2 = Builder.node("td", {
            align: "center",
             colspan:"1",
            class:"TextoCampos",
            width:"10%"

        });
        var td2_1 = Builder.node("td", {
            align: "center",
            colspan:"1",
            class:"TextoCampos",
            width:"10%"

        });
        var td3 = Builder.node("td", {
            align: "center",
            colspan:"3",
            class:"TextoCampos",
            width:"10%"
        });
        var td3_1 = Builder.node("td", {
            align: "center",
            colspan:"1",
            class:"TextoCampos",
            width:"10%"
        });
        var td4 = Builder.node("td", {
            align: "center",
            colspan:"1",
            class:"TextoCampos",
            width:"10%"
        });
        var td4_1 = Builder.node("td", {
            align: "center",
            colspan:"1",
            class:"TextoCampos",
            width:"10%"
        });

        var veiculoId = Builder.node("input", {
            type: "hidden",
            name: "idveiculo_"+linhaRoteirizador+"_" + countV,
            id: "idveiculo_"+linhaRoteirizador+"_" + countV
        });

        var veiculoPlaca = Builder.node("input", {
            id: "veiculo_"+linhaRoteirizador+"_" + countV,
            name: "veiculo_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "6"

        });

        var carretaId = Builder.node("input", {
            type: "hidden",
            name: "idcarreta_"+linhaRoteirizador+"_" + countV,
            id: "idcarreta_"+linhaRoteirizador+"_" + countV
        });

        var carretaPlaca = Builder.node("input", {
            id: "carreta_"+linhaRoteirizador+"_" + countV,
            name: "carreta_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "6"
        });

        var bitremId = Builder.node("input", {
            type: "hidden",
            name: "idbitrem_"+linhaRoteirizador+"_" + countV,
            id: "idbitrem_"+linhaRoteirizador+"_" + countV
        });

        var bitremPlaca = Builder.node("input", {
            id: "bitrem_"+linhaRoteirizador+"_" + countV,
            name: "bitrem_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "6"
        });

        var motoristaId = Builder.node("input", {
            type: "hidden",
            name: "idmotorista_"+linhaRoteirizador+"_" + countV,
            id: "idmotorista_"+linhaRoteirizador+"_" + countV
        });

        var motorista = Builder.node("input", {
            id: "motorista_"+linhaRoteirizador+"_" + countV,
            name: "motorista_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "6"
        });
            
        readOnly(veiculoId);
        readOnly(carretaId);
        readOnly(bitremId);
        readOnly(motoristaId);

        var btnVeic = Builder.node("input", {
            id: "botaoItens_" + countV,
            name: "botaoItens" + countV,
            className: "inputBotaoMin",
            onclick: "javascript:localizaVeiculo("+countV+", "+linhaRoteirizador+")",
            type: "button",
            value: "..."
        });

        var btnCar = Builder.node("input", {
            id: "botaoItens_" + countV,
            name: "botaoItens" + countV,
            className: "inputBotaoMin",
            onclick: "javascript:localizaCarreta("+countV+", "+linhaRoteirizador+")",
            type: "button",
            value: "..."
        });

         var btnlimpCar = Builder.node("img", {
            id: "limparCarreta_" + linhaRoteirizador +"_"+countV,
            name: "limparCarreta_" + linhaRoteirizador+"_"+ countV,
            className: "imagemLink",
            onclick: "javascript:limparCarreta("+linhaRoteirizador+", "+countV+")",               
            border: "0",
            align: "absbottom",
            title :"Limpar Carreta",
            style: "display: ",
            src: "img/borracha.gif"
        });           

        var btnBit = Builder.node("input", {
            id: "botaoItens_" + countV,
            name: "botaoItens" + countV,
            className: "inputBotaoMin",
            onclick: "javascript:localizaBitrem("+countV+", "+linhaRoteirizador+")",
            type: "button",
            value: "..."
        });

        var btnlimpBit = Builder.node("img", {
            id: "limparBitrem_" + linhaRoteirizador +"_"+countV,
            name: "limparBitrem_" +linhaRoteirizador +"_"+countV,
            className: "imagemLink",
            onclick: "javascript:limparBitrem("+linhaRoteirizador+", "+countV+")",               
            border: "0",
            align: "absbottom",
            title :"Limpar Bitrem",
            style: "display: ",
            src: "img/borracha.gif"
        });

        var btnMot = Builder.node("input", {
            id: "botaoItens_" + countV,
            name: "botaoItens" + countV,
            className: "inputBotaoMin",
            onclick: "javascript:localizaMotorista("+countV+", "+linhaRoteirizador+")",
            type: "button",
            value: "..."
        });

        var labelVei = Builder.node("label","Veículo:" );
        var labelCar = Builder.node("label","Carreta:" );
        var labelBit = Builder.node("label","Bitrem:" );
        var labelMot = Builder.node("label","Motorista:" );

        var div1 = Builder.node("div", {id: "div1_" + linhaRoteirizador+"_"+countV , name: "div1_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        var div1_1 = Builder.node("div", {id: "div11_" + linhaRoteirizador+"_"+countV , name: "div11_" + linhaRoteirizador+"_"+countV,
        align:"right"}, [

        ]);
        var div2 = Builder.node("div", {id: "div2_" + linhaRoteirizador+"_"+countV , name: "div2_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        var div2_1 = Builder.node("div", {id: "div21_" + linhaRoteirizador+"_"+countV , name: "div21_" + linhaRoteirizador+"_"+countV,
        align:"right"}, [

        ]);
        var div3 = Builder.node("div", {id: "div3_" + linhaRoteirizador+"_"+countV , name: "div3_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        var div3_1 = Builder.node("div", {id: "div31_" + linhaRoteirizador+"_"+countV , name: "div31_" + linhaRoteirizador+"_"+countV,
        align:"right"}, [

        ]);
        var div4 = Builder.node("div", {id: "div4_" + linhaRoteirizador+"_"+countV , name: "div4_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        var div4_1 = Builder.node("div", {id: "div41_" + linhaRoteirizador+"_"+countV , name: "div41_" + linhaRoteirizador+"_"+countV,
        align:"right"}, [

        ]);

        //Motorista
        div1_1.appendChild(labelMot);
        div1.appendChild(motoristaId);
        div1.appendChild(motorista);
        div1.appendChild(btnMot);
        td1_1.appendChild(div1_1);
        td1.appendChild(div1);
      //Veículo
        div2.appendChild(veiculoId);
        div2.appendChild(veiculoPlaca);
        div2.appendChild(btnVeic);
        div2_1.appendChild(labelVei);
        td2_1.appendChild(div2_1);
        td2.appendChild(div2);
        //Carreta
        div3.appendChild(carretaId);
        div3.appendChild(carretaPlaca);
        div3.appendChild(btnCar);
        div3.appendChild(btnlimpCar);
        div3_1.appendChild(labelCar);
        td3_1.appendChild(div3_1);
        td3.appendChild(div3);
        //Bitrem
        div4.appendChild(bitremId);
        div4.appendChild(bitremPlaca);
        div4.appendChild(btnBit);
        div4.appendChild(btnlimpBit);
        div4_1.appendChild(labelBit);
        td4_1.appendChild(div4_1);
        td4.appendChild(div4);
            
        td1.appendChild(motoristaId);     
        td2.appendChild(veiculoId);
        td3.appendChild(carretaId);
        td4.appendChild(bitremId);

        tr.appendChild(td0);
        tr.appendChild(td1_1);
        tr.appendChild(td1);
        tr.appendChild(td2_1);              
        tr.appendChild(td2);              
        tr.appendChild(td3_1);              
        tr.appendChild(td3);              
        tr.appendChild(td4_1);
        tr.appendChild(td4);

        var idCidade =  $("idCidade").value;
        var cidade =  $("cidade").value;
        var uf =  $("uf").value;
         var cidadeOrigemId = Builder.node("input", {
            type: "hidden",
            name: "idcidadeorigem_"+linhaRoteirizador+"_" + countV,
            id: "idcidadeorigem_"+linhaRoteirizador+"_" + countV,
            value: idCidade
        });

        var cidadeOrigem = Builder.node("input", {
            id: "cid_origem_"+linhaRoteirizador+"_" + countV,
            name: "cid_origem_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "30",
            value: cidade
        });  
        var ufOrigem = Builder.node("input", {
            id: "uf_origem_"+linhaRoteirizador+"_" + countV,
            name: "uf_origem_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "2",
            value: uf
        });
         var cidadeDestinoId = Builder.node("input", {
            type: "hidden",
            name: "idcidadedestino_"+linhaRoteirizador+"_" + countV,
            id: "idcidadedestino_"+linhaRoteirizador+"_" + countV
        });

        var cidadeDestino = Builder.node("input", {
            id: "cid_destino_"+linhaRoteirizador+"_" + countV,
            name: "cid_destino_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "30"
        });
        var ufDestino = Builder.node("input", {
            id: "uf_destino_"+linhaRoteirizador+"_" + countV,
            name: "uf_destino_"+linhaRoteirizador+"_" + countV,
            className: "inputReadOnly",
            readOnly: true,
            type: "text",
            size: "2"
        });
            
        var btnOri = Builder.node("input", {
            id: "localizaCidade_"+linhaRoteirizador+"_" + countV,
            name: "localizaCidade_"+linhaRoteirizador+"_" + countV,
            className: "inputBotaoMin",
            onclick: "javascript:localizarCidadeOri("+countV+", "+linhaRoteirizador+")",
            type: "button",
            value: "..."
        }); 
        var btnDest = Builder.node("input", {
            id: "localizaCidade_"+linhaRoteirizador+"_" + countV,
            name: "localizaCidade_"+linhaRoteirizador+"_" + countV,
            className: "inputBotaoMin",
            onclick: "javascript:localizarCidadeDest("+countV+", "+linhaRoteirizador+")",
            type: "button",
            value: "..."
        });
        
        var labelCidadeOri = Builder.node("label","Cidade de origem: " );
        var labelCidadeDest = Builder.node("label","Cidade de destino: " );

        var divcidO1 = Builder.node("div", {id: "divCidO1_" + linhaRoteirizador+"_"+countV , name: "divCidO1_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        var divcidO2 = Builder.node("div", {id: "divCidO2_" + linhaRoteirizador+"_"+countV , name: "divCidO2_" + linhaRoteirizador+"_"+countV,
        align:"right"}, [

        ]);

        var divcidD1 = Builder.node("div", {id: "divCidD1_" + linhaRoteirizador+"_"+countV , name: "divCidD1_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        var divcidD2 = Builder.node("div", {id: "divCidD2_" + linhaRoteirizador+"_"+countV , name: "divCidD2_" + linhaRoteirizador+"_"+countV,
        align:"right"}, [

        ]);


        var tdCidadeorilabel = Builder.node("td", {
            className: "TextoCampos" ,
            colspan: "2"
        });
        var tdCidadeorigem = Builder.node("td", {
            className: "TextoCampos"      ,
            colspan: "3"
        });
        var tdCidadedeslabel = Builder.node("td", {
            className: "TextoCampos",
            colspan: "2"
        });
        var tdCidadedestino = Builder.node("td", {
            className: "TextoCampos",
            colspan: "6"                
        });

        var trCidade = Builder.node("tr", {
            className: "CelulaZebra2",
            id: "trCidade_"+ linhaRoteirizador + "_" + countV,                             
        });


        divcidO2.appendChild(labelCidadeOri);
        divcidD2.appendChild(labelCidadeDest);

        divcidO1.appendChild(cidadeOrigemId);
        divcidO1.appendChild(cidadeOrigem);
        divcidO1.appendChild(ufOrigem);
        divcidO1.appendChild(btnOri);
        tdCidadeorilabel.appendChild(divcidO2);
        tdCidadeorigem.appendChild(divcidO1);

        divcidD1.appendChild(cidadeDestinoId);
        divcidD1.appendChild(cidadeDestino);
        divcidD1.appendChild(ufDestino);
        divcidD1.appendChild(btnDest);
        tdCidadedestino.appendChild(divcidD1);
        tdCidadedeslabel.appendChild(divcidD2);

        trCidade.appendChild(tdCidadeorilabel);
        trCidade.appendChild(tdCidadeorigem);
        trCidade.appendChild(tdCidadedeslabel);
        trCidade.appendChild(tdCidadedestino);

        var _table = Builder.node("TABLE", {id: "veiculos_" + linhaRoteirizador+"_"+countV , 
            name: "veiculos_" + linhaRoteirizador+"_"+countV,
            width:"100%",
            border:"0", 
            cellpadding:"2",
            cellspacing:"1",
            class:"bordaFina",
            align:"center"
        });

         var trvei = Builder.node("tr", {
            id: "veiculo_setor_" + linhaRoteirizador + "_" + countV
        });

        var tdvei = Builder.node("td", {colspan : "12"});

        var _tablecte = Builder.node("table",{
            name: "ctes_"+ linhaRoteirizador + "_" + countV,
            width:"100%",
            border:"0", 
            cellpadding:"2",
            cellspacing:"1",
//                class:"ctes",
            class:"bordaFina teste",
            align:"center"
        });

        var _tbCte = Builder.node("tbody",{
            id:"tbCte_"+linhaRoteirizador+"_"+countV,
            name:"tbCte_"+linhaRoteirizador+"_"+countV,
            className:"move connect"
        });

        var trcte = Builder.node("tr", {
            id: "cte_veiculo_"+ linhaRoteirizador + "_" + countV
        });
            
            
        var tdcte = Builder.node("td", {colspan : "20"});

        var trCteLabels = Builder.node("tr", {
            className: "CelulaZebra2 naoMove",
            id: "cteLabel"
        });
        var inputCteSize = Builder.node("input", {
           type: "hidden",
           id:"size_"+ linhaRoteirizador + "_" + countV,
           name:"size_"+ linhaRoteirizador + "_" + countV,
           value:"0"
        });

        var _tdCteMove = Builder.node("td", {class:"CelulaZebra1", align:"left", width:"1%"});
        var tdcte1 = Builder.node("td", {class:"CelulaZebra1", align:"left", width:"4%"});
        var tdcte2 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"6%"});
        var tdcte3 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"20%"});
        var tdcte4 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"15%"});
        var tdcte5 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"8%"});
        var tdcte6 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"8%"});
        var tdcte7 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"4%"});
        var tdcte8 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"5%"});
        var tdcte9 = Builder.node("td", {class:"CelulaZebra1", align:"left", width:"5%"});
        var tdcte10 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"5%"});
        var tdcte11 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"4%"});
        var tdcte12 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"10%"});
        var tdcte13 = Builder.node("td", { class:"CelulaZebra1", align:"left", width:"5%"});

        var labelnum = Builder.node("label","Número" );
        var labelemi = Builder.node("label","Emissão" );
        var labeldes = Builder.node("label","Destinatário" );
        var labelend = Builder.node("label","Endereço" );
        var labelbai = Builder.node("label","Bairro" );
        var labelcid = Builder.node("label","Cidade/PE" );
        var labelnot = Builder.node("label","Qtd Notas" );
        var labelpes = Builder.node("label","Peso R." );
        var labelcub = Builder.node("label","Cubagem" );
        var labelmer = Builder.node("label","Valor Merc." );
        var labelvol = Builder.node("label","Volume" );
        var labelval = Builder.node("label","Valor CT-e" );
        var labelVaz = Builder.node("label","" );

        tdcte1.appendChild(labelnum);
        tdcte2.appendChild(labelemi);
        tdcte3.appendChild(labeldes);
        tdcte4.appendChild(labelend);
        tdcte5.appendChild(labelbai);
        tdcte6.appendChild(labelcid);
        tdcte7.appendChild(labelnot);
        tdcte8.appendChild(labelpes);
        tdcte9.appendChild(labelcub);
        tdcte10.appendChild(labelmer);
        tdcte11.appendChild(labelvol);
        tdcte12.appendChild(labelval);
        tdcte13.appendChild(labelVaz);
            
        trCteLabels.appendChild(_tdCteMove);
        trCteLabels.appendChild(tdcte1);
        trCteLabels.appendChild(tdcte2);
        trCteLabels.appendChild(tdcte3);
        trCteLabels.appendChild(tdcte4);
        trCteLabels.appendChild(tdcte5);
        trCteLabels.appendChild(tdcte6);
        trCteLabels.appendChild(tdcte7);
        trCteLabels.appendChild(tdcte8);
        trCteLabels.appendChild(tdcte9);
        trCteLabels.appendChild(tdcte10);
        trCteLabels.appendChild(tdcte11);
        trCteLabels.appendChild(tdcte12);
        trCteLabels.appendChild(tdcte13);
        trCteLabels.appendChild(inputCteSize);

        var tdrota = Builder.node("td", {
            className: "TextoCampos",
            width: "5%"
        });
        var tdrota1 = Builder.node("td", {
            className: "TextoCampos",
            width: "5%"
        });
        var tdpercurso = Builder.node("td", {
            className: "TextoCampos",
            width: "7%"
        });
        var tdpercurso1 = Builder.node("td", {
            className: "TextoCampos",
            width: "7%"
        });
        var tdnliberacao = Builder.node("td", {
            className: "TextoCampos",
            width: "15%"
        });
        var tdnliberacao1 = Builder.node("td", {
            className: "TextoCampos",
            align : "left",
            colspan: "3"
        });
        var tdfilialdestino = Builder.node("td", {
            className: "TextoCampos",
            width: "10%"
        });
        var tdfilialdestino1 = Builder.node("td", {
            className: "TextoCampos",
            width: "5%"
        });
        var tdtipo = Builder.node("td", {
            className: "TextoCampos",
            width: "15%"
        });

        var tdtipoManifesto = Builder.node("td", {
            className: "TextoCampos",
            colspan: "3"
        });
        var divnliberacao = Builder.node("div", {
           align: "left"
        });

        var _tdExcluir = Builder.node("td", {
            width: "2%"
        });

        _tdExcluir.appendChild(img0);

        var rota = Builder.node("select", {
            id: "rota_"+linhaRoteirizador+"_" + countV,
            name: "rota_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "text",
            width: "5%",
            onchange: "getRotaPercurso("+linhaRoteirizador+"," + countV+");"
        });

        var percurso = Builder.node("select", {
            id: "percurso_"+linhaRoteirizador+"_" + countV,
            name: "percurso_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "text"

        });
         var nliberacao = Builder.node("input", {
            id: "nliberacao_"+linhaRoteirizador+"_" + countV,
            name: "nliberacao_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "text",
            size: "10",
            align: "left"

        });
        var filialDestino = Builder.node("select", {
            id: "filialdestino_"+linhaRoteirizador+"_" + countV,
            name: "filialdestino_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "text"

        });
            
        var tipo = Builder.node("select", {
            id: "tipo_"+linhaRoteirizador+"_" + countV,
            name: "tipo_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "text"


        });

        var tipoR = Builder.node("input", {
            id: "romaneio_"+linhaRoteirizador+"_" + countV,
            name: "tipo_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "radio",
            value: "r",
            onclick:"javascript:alterarTipo(this.value,"+linhaRoteirizador+","+countV+");",
            checked: true
        });
        var tipoM = Builder.node("input", {
            id: "manifesto_"+linhaRoteirizador+"_" + countV,
            name: "tipo_"+linhaRoteirizador+"_" + countV,
            className: "fieldMin",
            type: "radio",
            value:"m",
            onclick:"javascript:alterarTipo(this.value,"+linhaRoteirizador+","+countV+");"

        });

        var divTipo = Builder.node("div", {id: "divTipo_" + linhaRoteirizador+"_"+countV , name: "divTipo_" + linhaRoteirizador+"_"+countV,
        align:"left"}, [

        ]);
        
        var labelrota = Builder.node("label","Rota:" );
        var labelpercurso = Builder.node("label","Percurso:" );
        var labelnliberacao = Builder.node("label","Nº Liberação Mot.:" );
        var labelfilialdestino = Builder.node("label","Filial Destino:" );
        var labelRomaneio = Builder.node("label","Romaneio" );
        var labelManifesto = Builder.node("label","Manifesto" );
        var labelTipoManifesto = Builder.node("label","Tipo:" );
        
        var trmanifesto = Builder.node("tr", {
            className: "CelulaZebra2",
            id: "trManifesto_"+ linhaRoteirizador + "_" + countV,
            style: "display: none",
            colspan: "13"

        });
        
        tdrota.appendChild(labelrota);
        tdrota1.appendChild(rota);
        tdpercurso.appendChild(labelpercurso);
        tdpercurso1.appendChild(percurso);
        tdnliberacao.appendChild(labelnliberacao);
        divnliberacao.appendChild(nliberacao);
        tdnliberacao1.appendChild(divnliberacao);
        tdfilialdestino.appendChild(labelfilialdestino);
        tdfilialdestino1.appendChild(filialDestino);
        tdtipoManifesto.appendChild(labelTipoManifesto);
        tdtipoManifesto.appendChild(tipo);
        
        divTipo.appendChild(tipoR);
        divTipo.appendChild(labelRomaneio);
        divTipo.appendChild(tipoM);
        divTipo.appendChild(labelManifesto);
        tdtipo.appendChild(divTipo);
        
        trmanifesto.appendChild(tdrota);
        trmanifesto.appendChild(tdrota1);
        trmanifesto.appendChild(tdpercurso);
        trmanifesto.appendChild(tdpercurso1);
        trmanifesto.appendChild(tdnliberacao);
        trmanifesto.appendChild(tdnliberacao1);
        trmanifesto.appendChild(tdfilialdestino);
        trmanifesto.appendChild(tdfilialdestino1);
        trmanifesto.appendChild(tdtipoManifesto);
        
        tr.appendChild(tdtipo);
        tr.appendChild(_tdExcluir);
        _table.appendChild(tr);
        _table.appendChild(trCidade);
        _table.appendChild(trmanifesto);
        _tbCte.appendChild(trCteLabels);
        _tablecte.appendChild(_tbCte);
        tdcte.appendChild(_tablecte);
        trcte.appendChild(tdcte);
        _table.appendChild(trcte);
        
        tdvei.appendChild(_table);
        trvei.appendChild(tdvei);
        
        $("setores_"+linhaRoteirizador).appendChild(trvei);
        
        $("maxVeiculo_" + linhaRoteirizador).value = countV;
        
        povoarSelect($("rota_"+linhaRoteirizador+"_"+countV), listaRotaPadrao);
        povoarSelect($("percurso_"+linhaRoteirizador+"_"+countV), listaPercuso);
        povoarSelect($("filialdestino_"+linhaRoteirizador+"_"+countV), listaFilial);
        povoarSelect($("tipo_"+linhaRoteirizador+"_"+countV), listaTipoManifesto);
        
        atualizarCTeSetor();
        
        somaQtdVeiculo(linhaRoteirizador);
        
    }
       
    function aoClicarNoLocaliza(idjanela){
        var index =idjanela.split("_")[2];
        var idSetor =idjanela.split("_")[1];
            
        if(idjanela == "Veiculo_"+idSetor+"_"+index){
            $("veiculo_"+idSetor+"_"+index).value = $("vei_placa").value;
            $("idveiculo_"+idSetor+"_"+index).value = $("idveiculo").value;
        }else if(idjanela == "Carreta_"+idSetor+"_"+index){
            $("carreta_"+idSetor+"_"+index).value = $("car_placa").value;
            $("idcarreta_"+idSetor+"_"+index).value = $("idcarreta").value;
        }else if(idjanela == "Bitrem_"+idSetor+"_"+index){
            $("bitrem_"+idSetor+"_"+index).value = $("bi_placa").value;
            $("idbitrem_"+idSetor+"_"+index).value = $("idbitrem").value;
        }else if(idjanela == "Motorista_"+idSetor+"_"+index){
            $("nliberacao_"+idSetor+"_"+index).value = $("motor_liberacao").value;            
            $("motorista_"+idSetor+"_"+index).value = $("motor_nome").value;            
            $("idmotorista_"+idSetor+"_"+index).value = $("idmotorista").value;   
            $("veiculo_"+idSetor+"_"+index).value = $("vei_placa").value;
            $("idveiculo_"+idSetor+"_"+index).value = $("idveiculo").value;
        }else if(idjanela == "CidadeOrigem_"+idSetor+"_"+index){
            var isManifesto = false;            
//            index =idjanela.split("_")[3] ;
//            idSetor =idjanela.split("_")[2] ;
            $("idcidadeorigem_"+idSetor+"_"+index).value = $("idcidadeorigem").value;
            $("cid_origem_"+idSetor+"_"+index).value = $("cid_origem").value;
            $("uf_origem_"+idSetor+"_"+index).value = $("uf_origem").value;            
            isManifesto = $("manifesto_"+idSetor+"_"+index).checked;
            if (isManifesto) {
                getRota(idSetor, index);    
            }
        }else if(idjanela == "CidadeDestino_"+idSetor+"_"+index){
            var isManifesto = false;
//            index =idjanela.split("_")[3] ;
//            idSetor =idjanela.split("_")[2] ;
            $("idcidadedestino_"+idSetor+"_"+index).value = $("idcidadedestino").value;
            $("cid_destino_"+idSetor+"_"+index).value = $("cid_destino").value;
            $("uf_destino_"+idSetor+"_"+index).value = $("uf_destino").value;
            isManifesto = $("manifesto_"+idSetor+"_"+index).checked;
            if (isManifesto) {
                getRota(idSetor, index);    
            }
        }else if(idjanela == "Representante_"+idSetor+"_"+index){
            $("idRepresentanteDestino_"+idSetor+"_"+index).value = $("idredespachante").value;
            $("representanteDestino_"+idSetor+"_"+index).value = $("redspt_rzs").value;
        }
    }
    
    function localizaVeiculo(indexV, countRot){
        launchPopupLocate('./localiza?acao=consultar&idlista=7', 'Veiculo_'+countRot+'_'+indexV);
    }
    function localizaCarreta(indexV, countRot){
        launchPopupLocate('./localiza?acao=consultar&idlista=9', 'Carreta_'+countRot+'_'+indexV);     
    }
    function localizaBitrem(indexV, countRot){
        launchPopupLocate('./localiza?acao=consultar&idlista=51', 'Bitrem_'+countRot+'_'+indexV);
    }
    function localizaMotorista(indexV, countRot){
        console.log("AAAAAAAAA localizar mototorista : " + indexV + " countRot : " + countRot);
        launchPopupLocate('./localiza?acao=consultar&idlista=10', 'Motorista_'+countRot+'_'+indexV);
    }
    
    function localizarCidadeOri(indexV, countRot){
        launchPopupLocate('./localiza?acao=consultar&idlista=11', 'CidadeOrigem_'+countRot+'_'+indexV);
    }

    function localizarCidadeDest(indexV, countRot){
        launchPopupLocate('./localiza?acao=consultar&idlista=12', 'CidadeDestino_'+countRot+'_'+indexV);
    }
    
    function localizarRepresentante(indexV, countRot){
        launchPopupLocate('./localiza?acao=consultar&idlista=23', 'Representante_'+countRot+'_'+indexV);
    }
    
    //OBS.: NÃO COLOCAR O NOME DO RELATORIO COMO Cidade_Destino_countRot_indexV, NA CONDIÇÃO DO LOCALIZAR FAZ O SPLIT 1 E 2.
    //ENTÃO COLOCAR CidadeDestino_countRot_indexV.

    function salvar(){  
        console.log(jQuery("maxRot").val());
        var maxRot = $("maxRot").value;
        var maxVeiculo;
        var isVeiculo = false;

        for(var i=1; i<=maxRot; i++){
            if($("idSetor_"+i).value!="0"){
                maxVeiculo = $("maxVeiculo_" + i).value;
                for (var idVeiculo = 1; idVeiculo <= maxVeiculo; idVeiculo++) {
                    $("filialdestino_"+ i + "_" + idVeiculo).disabled = false;
                    if($("size_" + i + "_" + idVeiculo).value==0){
                            alert("Roteirização não pode ser salva sem CT-e(s)!");
                            return false;
                    }
                    if ($("ckVei_" + i + "_" + idVeiculo).checked) {
                        isVeiculo = true;
                        if ($("tipo_" + i + "_" + idVeiculo).checked == "m") {
                            if($("carreta_" + i + "_" + idVeiculo).value ==""){
                                alert("Carreta não está preenchida!");
                                return false;
                            }
                        } 
                        if($("veiculo_" + i + "_" + idVeiculo).value ==""){
                                alert("Veículo não está preenchido!");
                                return false;
                        }
                        if($("motorista_" + i + "_" + idVeiculo).value ==""){
                                alert("Motorista não está preenchido!");
                                return false;
                        }
                        if($("cid_origem_" + i + "_" + idVeiculo).value ==""){
                                alert("Cidade de origem não está preenchida!");
                                return false;
                        }
                        if($("cid_destino_" + i + "_" + idVeiculo).value ==""){
                                alert("Cidade de destino não está preenchida!");
                                return false;
                        }

                    }
                }
            }
        }

        if (isVeiculo == false) {
            alert("Atenção: Para Roteirizar, é necessário selecionar pelo menos um documento!");
            return false;
        }
        
        $('agruparMDFeUF').value = $('agruparMDFeUF1').checked;

        $("formu").target = "pop";

        window.open('about:blank', 'pop', 'width=250, height=30');
        $("formu").submit(); 
        return true;
        
    }
    
    function alterarTipo(valor, index, indexVei){
        if(valor=='m'){
            $("trManifesto_"+index+"_"+indexVei).style.display = "";  
            $("romaneio_"+index+"_"+indexVei).checked = false;
            $("limparCarreta_"+index+"_"+indexVei).style.display = "none";
            $("limparBitrem_"+index+"_"+indexVei).style.display = "";
        }else if(valor=='r'){
            $("manifesto_"+index+"_"+indexVei).checked = false;
            $("trManifesto_"+index+"_"+indexVei).style.display = "none";
             $("limparCarreta_"+index+"_"+indexVei).style.display = "";
            $("limparBitrem_"+index+"_"+indexVei).style.display = "";
        }
    }
    
    function excluir(indexVei, indexRoteirizador){
        var qtdAtual = jQuery("#qtdVeiculo_"+indexRoteirizador).text();
        if(jQuery("tr[id*=cte_"+indexRoteirizador+"_"+indexVei+"]").length > 1){
            alert("Atenção: Não é possível excluir Setor com um ou mais documentos!");
            return false;
        }
        
        if(confirm("Deseja excluir?")){
            if(confirm("Tem certeza?")){               
                if(jQuery("tr[id*=cte_"+indexRoteirizador+"_"+indexVei+"]").length <= 1){
                    jQuery("#veiculo_setor_"+indexRoteirizador+"_"+indexVei).remove();
                    qtdAtual--;
                    jQuery("#qtdVeiculo_"+indexRoteirizador).text(qtdAtual);
                }                  
            }
        }        
    }

    function checkTodos(indexRoteirizador){
        var i = 1, check=false;
         if ($("ck_"+indexRoteirizador).checked){
            check = true;
        }
        while ($("ckVei_"+indexRoteirizador+"_"+i) != null){
            $("ckVei_"+indexRoteirizador+"_"+i).checked = check;
            i++;
        }                
    }

    function somaPeso(){

        var indexR=1;
        var indexVei =1;
        var indexCte =1;
        var totalPeso =0;
        var maxVei;

        while($("pesoTotal_"+indexR) !== null){
            totalPeso=0;
            maxVei = $("maxVeiculo_"+indexR).value;

            for(indexVei=1; indexVei<=maxVei; indexVei++){

                indexCte = 1;
                while($("pesoCte_" + indexR+"_"+indexVei+"_"+indexCte) !== null){
                   totalPeso+=parseFloat($("pesoCte_" + indexR+"_"+indexVei+"_"+indexCte).value);
                   indexCte= indexCte +1;
                }    
            }
            indexR = indexR+1;

       }     

    }

    function editarconhecimento(idmovimento, podeexcluir){
        window.open("./frameset_conhecimento?acao=editar&id="+idmovimento+(podeexcluir != null ? "&ex="+podeexcluir : ""), "menuLan", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
    }


    function getParseNumero(valor){
        var valorInt = parseInt(valor);
        var valorFloat =  parseFloat(valor);
        if(valorInt == valorFloat){
            return valorInt;
        }else{
            return  colocarVirgula(valorFloat, 2);
        }
    }

    function limparCarreta(indexRot, indexVeic){
        $("carreta_"+indexRot+"_"+indexVeic).value= "";
        $("idcarreta_"+indexRot+"_"+indexVeic).value= "0";            
    }
    function limparBitrem(indexRot, indexVeic){
        $("bitrem_"+indexRot+"_"+indexVeic).value= "";
        $("idbitrem_"+indexRot+"_"+indexVeic).value= "0";            
    }

    function getRota(indexRota, indexVeic){
        var idCidadeOrigem = $("idcidadeorigem_"+indexRota+"_"+indexVeic).value;
        var idCidadeDestino = $("idcidadedestino_"+indexRota+"_"+indexVeic).value;
        var idClienteRota = 0;
        var isRotaEntrega = true;
        var isRotaTrans = true;

        jQuery.ajax({
                url: '<c:url value="/ContratoFreteControlador" />',
                dataType: "text",
                method: "post",
                data: {

                    cidadesOrigem: idCidadeOrigem,
                    cidadesDestino: idCidadeDestino,                        
                    isRotaEntrega: isRotaEntrega,
                    isRotaTransferencia: isRotaTrans,
                    idClienteRota: idClienteRota,
                    acao : "carregarRotaAjax"
                },
                success: function(data) { 

                    var rota = JSON.parse(data).list[0].rota;

                    tamanhoRota = (rota != undefined && rota.length != undefined ? rota.length : 1)


                    if (rota != undefined) {
                        jQuery('#rota_'+indexRota+'_'+indexVeic+ ' option').remove();
                        removerSelectPercuso(indexRota, indexVeic);

                        if (tamanhoRota > 1) {
                            for (var qtdRota = 0; qtdRota < tamanhoRota; qtdRota++) {
                                listaRotaLocalizada[++countRotaLocalizada] = new Option(rota[qtdRota].id,rota[qtdRota].descricao);
                            }
                        }else{
                            listaRotaLocalizada[++countRotaLocalizada] = new Option(rota.id,rota.descricao);
                        }

                        povoarSelect($("rota_"+indexRota+"_"+indexVeic), listaRotaLocalizada);
                        getRotaPercurso(indexRota, indexVeic);

                    }else{

                        jQuery('#rota_'+indexRota+'_'+indexVeic+ ' option').remove();
                        povoarSelect($("rota_"+indexRota+"_"+indexVeic), listaRotaPadrao);                            
                        removerSelectPercuso(indexRota, indexVeic);
                        listaRotaLocalizada = new Array();

                    }

                }

        });

    }

    function removerSelectPercuso(indexRota, indexVeic){
        jQuery('#percurso_'+indexRota+'_'+indexVeic+ ' option').remove();
        povoarSelect($("percurso_"+indexRota+"_"+indexVeic), listaPercuso);        
    }
    
    function atualizarCTeSetor(){
        
          jQuery('.handler2').css('cursor', 'pointer');
          jQuery(".move, .moveDom").sortable({
                placeholder: "soltar",
                connectWith: ".connect",
                items : "tr:not(.naoMove)",
                handle: '.handler2',
                stop: function(event, ui){
                    
                    var id = ui.item[0].id;
                    
                    jQuery("#"+id).find('td.obsr').hide();
                    jQuery("#"+id).find('td.obsn').hide();
                    jQuery("#"+id).find('td.obse').show();
                    
                    
//                    console.log(id);
//                    console.log(this.id);
                    
                    var indexTbodyUm = 0;
                    var indexTbodyDois = 0;
                    var peso = 0;
                    var lengthTbody = jQuery(".teste").find('tbody').length;
                    //Primeiro for percorro todas as tbody(s)
                    for (var qtdTbody = 0; qtdTbody < lengthTbody; qtdTbody++) {
                        indexTbodyUm = jQuery(".teste").find('tbody')[qtdTbody].id.split("_")[1];
                        indexTbodyDois = jQuery(".teste").find('tbody')[qtdTbody].id.split("_")[2];
                        var lengthRows = jQuery(".teste").find('tbody')[qtdTbody].rows.length;
                        //Segundo for percorro todas as tr(s)
                        peso = 0;
                        for (var qtdTr = 0; qtdTr < lengthRows; qtdTr++) {                        
                            var idTr = jQuery(".teste").find('tbody')[qtdTbody].rows[qtdTr].id;
                            if(idTr != ""){
                                //Esse trecho é feito alteração dos ids.
                                var trCte = jQuery("#"+idTr);
                                
                                //tr(s)
                                trCte.attr("id", "cte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                trCte.attr("name", "cte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);                                
                                var inputCTe = jQuery("#cte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                
                                //id Cte
                                inputCTe.find("input[id*=idcte]").attr("id","idcte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=idcte]").attr("name","idcte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                //Peso
                                inputCTe.find("input[id*=pesoCte]").attr("id","pesoCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=pesoCte]").attr("name","pesoCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                //Notas
                                inputCTe.find("input[id*=notasCte]").attr("id","notasCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=notasCte]").attr("name","notasCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                //Cubagem
                                inputCTe.find("input[id*=metroCte]").attr("id","metroCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=metroCte]").attr("name","metroCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                //Volume
                                inputCTe.find("input[id*=volumeCte]").attr("id","volumeCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=volumeCte]").attr("name","volumeCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                //Obs ?
                                inputCTe.find("input[id*=obsEscUsu]").attr("id","obsEscUsu_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=obsEscUsu]").attr("name","obsEscUsu_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                //Obs X
                                inputCTe.find("input[id*=obsnRot]").attr("id","obsnRot_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);
                                inputCTe.find("input[name*=obsnRot]").attr("name","obsnRot_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr);                                
                                
                                jQuery("#size_"+indexTbodyUm+"_"+indexTbodyDois).val(qtdTr);
                                
                            }                            
                        }                    
                    }
                    somaPesoReal();
                }
            });
        
    }
    
    function somaPesoReal(){
        var indexTbodyUm = 0;
        var indexTbodyUmAnterior = 0;
        var indexTbodyDois = 0;
        var peso = 0;
        var notas = 0;        
        var cubagem = 0;        
        var lengthTbody = jQuery(".teste").find('tbody').length;
        for (var qtdTbody = 0; qtdTbody < lengthTbody; qtdTbody++) {
            indexTbodyUm = jQuery(".teste").find('tbody')[qtdTbody].id.split("_")[1];            
            indexTbodyDois = jQuery(".teste").find('tbody')[qtdTbody].id.split("_")[2];
            var lengthRows = jQuery(".teste").find('tbody')[qtdTbody].rows.length;
            if(indexTbodyUm != indexTbodyUmAnterior){
                peso=0;
                notas=0;
                cubagem=0;
                indexTbodyUmAnterior = indexTbodyUm;
            }
            for (var qtdTr = 1; qtdTr < lengthRows; qtdTr++) {
                var idTr = jQuery(".teste").find('tbody')[qtdTbody].rows[qtdTr].id;
                if(idTr != ""){                    
                    peso = parseFloat(peso) + parseFloat(jQuery("#pesoCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr).val());
                    notas = parseInt(notas) + parseInt(jQuery("#notasCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr).val());
                    cubagem = parseFloat(cubagem) + parseFloat(jQuery("#metroCte_"+indexTbodyUm+"_"+indexTbodyDois+"_"+qtdTr).val());
                    
                    jQuery("#peso_total_"+indexTbodyUm).text(colocarVirgula(peso));
                    jQuery("#qtdNota_"+indexTbodyUm).text(notas);                    
                    jQuery("#cubagem_total_"+indexTbodyUm).text(colocarVirgula(cubagem));
                    
                }
            }
            
        }        
    }
    
    function somaQtdVeiculo(linhaRoteirizador){
        var qtdVei = jQuery("#qtdVeiculo_"+linhaRoteirizador).text();
        qtdVei++;
        jQuery("#qtdVeiculo_"+linhaRoteirizador).text(qtdVei);
    }
    
    function abrirSetorEntrega(idSetorEntrega){
        abrirLocaliza('SetorEntregaControlador?acao=carregar&id='+idSetorEntrega, 'Setor_Entrega');
    }
    
    
    function mostrarFiltros(tipo){
        if (tipo == "d") {
            $("lbFiltroTipoCte").style.display = "";
            $("ipFiltroTipoCte").style.display = "";
        }else{
            $("lbFiltroTipoCte").style.display = "none";
            $("ipFiltroTipoCte").style.display = "none";
        }
    }
    
    function mudarFilial(){
        var e = document.getElementById("filial");
        var itemSelecionado = e.options[e.selectedIndex].text;
        
        $("lbFilialFiltroE").innerHTML = itemSelecionado;
        $("lbFilialFiltroF").innerHTML = itemSelecionado;
    }
    
    function liberarAgrupamento(campo){
        jQuery("#pesomaximo").removeAttr("readOnly");
        $("pesomaximo").value = "0,00";
        jQuery("#pesomaximo").attr("readOnly",true);
        jQuery("#pesomaximo").addClass("inputReadOnly");
        
        jQuery("#vlNfeMaximo").removeAttr("readOnly");
        $("vlNfeMaximo").value = "0,00";
        jQuery("#vlNfeMaximo").attr("readOnly",true);
        jQuery("#vlNfeMaximo").addClass("inputReadOnly");
        
        jQuery("#qtdEntregas").removeAttr("readOnly");
        $("qtdEntregas").value = "0";
        jQuery("#qtdEntregas").attr("readOnly",true);
        jQuery("#qtdEntregas").addClass("inputReadOnly");
        
        jQuery("#vlCteMaximo").removeAttr("readOnly");
        $("vlCteMaximo").value = "0,00";
        jQuery("#vlCteMaximo").attr("readOnly",true);
        jQuery("#vlCteMaximo").addClass("inputReadOnly");
        
        jQuery("#cubagemMaxima").removeAttr("readOnly");
        $("cubagemMaxima").value = "0,00";
        jQuery("#cubagemMaxima").attr("readOnly",true);
        jQuery("#cubagemMaxima").addClass("inputReadOnly");
        
        jQuery("#qtdVolumeMaximo").removeAttr("readOnly");
        $("qtdVolumeMaximo").value = "0,00";
        jQuery("#qtdVolumeMaximo").attr("readOnly",true);
        jQuery("#qtdVolumeMaximo").addClass("inputReadOnly");
        
        campo.removeAttr("readOnly");
        campo.removeClass("inputReadOnly");
        campo.addClass("inputtexto");  
    }
    
    function alterarFilialRepresentante(indexi,  indexj){
        if($("tipoFilialRep_"+indexi+"_"+indexj).value == "representante"){
            $("tdRepresentanteDestino_"+indexi+"_"+indexj).style.display = "";
            $("tdFilialDestino_"+indexi+"_"+indexj).style.display = "none";
        }else if($("tipoFilialRep_"+indexi+"_"+indexj).value == "filial"){
            $("tdFilialDestino_"+indexi+"_"+indexj).style.display = "";
            $("tdRepresentanteDestino_"+indexi+"_"+indexj).style.display = "none";
        }
    }
    
    jQuery(document).ready(function() {
        jQuery('#prod_tipo').inputMultiploGw({
            readOnly: 'true',
            is_old: true
        });
        let prod_tipo = '<c:out value="${param.tipoProdutos}"/>';
        if(prod_tipo){
            let inputProd = jQuery('#prod_tipo');
            prod_tipo.split('!@!').forEach(function (elemento) {
                let split = elemento.split('#@#');
                addValorAlphaInput(inputProd, split[0], split[1]);
            });
        }
    });
    
</script>

<html>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        .soltar{ 
            height: 1.5em; 
            line-height: 1.2em; 
            background-color: white; 
            outline-color: black;
            outline-style: dashed;
            outline-width: 2px;
        }
        -->
    </style>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Roteirizar/Montar Cargas de CT-e</title>

    </head>

    <body onload="setDefault();atualizarCTeSetor();"> 

        <img src="img/banner.gif" width="20%" height="44">
        <table class="bordaFina" width="95%" align="center">
            <tr>
                <td width="100%" align="left"> <span class="style4">Roteirizar/Montar Cargas</span></td>
                
            </tr>
        </table>
        <br>
        <form action="RoteirizacaoControlador?acao=listar" id="formulario" name="formulario" method="post">
        <table class="bordaFina" width="95%" align="center">
                <input type="hidden" name="operadorConsulta" value="<c:out value='${param.operadorConsulta}'/>"/>
                <input type="hidden" name="campoConsulta" value="<c:out value='${param.campoConsulta}'/>"/>
                <input type="hidden" name="valorConsulta" value="<c:out value='${param.valorConsulta}'/>"/>
                <input type="hidden" id="idremetente" name="idremetente" value="">
                <input type="hidden" id="iddestinatario" name="iddestinatario" value="">
                <input type="hidden" id="idconsignatario" name="idconsignatario" value="">
                <input type="hidden" id="idveiculo" value="0">
                <input type="hidden" id="vei_placa" value="">
                <input type="hidden" id="idcarreta" value="0">
                <input type="hidden" id="car_placa" value="">
                <input type="hidden" id="idbitrem" value="0">
                <input type="hidden" id="bi_placa" value="">
                <input type="hidden" id="idmotorista" value="0">
                <input type="hidden" id="motor_nome" value="">
                <input type="hidden" id="motor_cpf" value="">
                <input type="hidden" id="mot_outros_descontos_carta" value="">
                <input type="hidden" id="motor_cnh" value="">
                <input type="hidden" id="vei_prop_cgc" value="">
                <input type="hidden" id="inss_prop_retido" value="">
                <input type="hidden" id="vei_prop" value="">
                <input type="hidden" id="perc_adiant" value="">
                <input type="hidden" id="motor_vencimentocnh" value="">
                <input type="hidden" id="motor_categcnh" value="">
                <input type="hidden" id="tipo" value="">
                <input type="hidden" id="car_prop" value="">
                <input type="hidden" id="validade_lib" value="">
                <input type="hidden" id="bloqueado" value="">
                <input type="hidden" id="motivobloqueio" value="">
                <input type="hidden" id="obscartafrete" value="">
                <input type="hidden" id="idproprietarioveiculo" value="">
                <input type="hidden" id="idmotorista_col" value="">
                <input type="hidden" id="idbitrem" value="">
                <input type="hidden" id="bi_placa" value="">
                <input type="hidden" id="bi_prop" value="">
                <input type="hidden" id="plano_proprietario" value="">
                <input type="hidden" id="und_proprietario" value="">
                <input type="hidden" id="motor_conta1" value="">
                <input type="hidden" id="motor_agencia1" value="">
                <input type="hidden" id="motor_favorecido1" value="">
                <input type="hidden" id="motor_banco1" value="">
                <input type="hidden" id="motor_conta2" value="">
                <input type="hidden" id="motor_agencia2" value="">
                <input type="hidden" id="motor_favorecido2" value="">
                <input type="hidden" id="motor_banco2" value="">
                <input type="hidden" id="prop_conta1" value="">
                <input type="hidden" id="prop_agencia1" value="">
                <input type="hidden" id="prop_favorecido1" value="">
                <input type="hidden" id="prop_banco1" value="">
                <input type="hidden" id="prop_conta2" value="">
                <input type="hidden" id="prop_agencia2" value="">
                <input type="hidden" id="prop_favorecido2" value="">
                <input type="hidden" id="prop_banco2" value="">
                <input type="hidden" id="impedir_viagem_motorista" value="">
                <input type="hidden" id="valor_rota" value="">
                <input type="hidden" id="valor_maximo_rota" value="">
                <input type="hidden" id="valor_rota_viagem_2" value="">
                <input type="hidden" id="valor_pedagio_rota" value="">
                <input type="hidden" id="valor_entrega_rota" value="">
                <input type="hidden" id="qtd_entregas_rota" value="">
                <input type="hidden" id="tipo_valor_rota" value="">
                <input type="hidden" id="percentual_desconto_prop" value="">
                <input type="hidden" id="debito_prop" value="">
                <input type="hidden" id="percentual_ctrc_contrato_frete" value="">
                <input type="hidden" id="is_obriga_carreta" value="">
                <input type="hidden" id="tipo_veiculo_motorista" value="">
                <input type="hidden" id="is_tac" value="">
                <input type="hidden" id="base_ir_prop_retido" value="">
                <input type="hidden" id="ir_prop_retido" value="">
                <input type="hidden" id="base_inss_prop_retido" value="">
                <input type="hidden" id="percentual_comissao_frete" value="">
                <input type="hidden" id="km_saida" value="">
                <input type="hidden" id="capacidade_cubagem" value="">
                <input type="hidden" id="capacidade_cubagem2" value="">
                <input type="hidden" id="categoria_pamcard_id" value="">
                <input type="hidden" id="basetac" value="">
                <input type="hidden" id="vei_cap_carga" value="">
                <input type="hidden" id="car_cap_carga" value="">
                <input type="hidden" id="bi_cap_carga" value="">
                <input type="hidden" id="categoria_ndd_id" value="">
                <input type="hidden" id="car_tipo_controle_km" value="">
                <input type="hidden" id="bi_tipo_controle_km" value="">
                <input type="hidden" id="car_km_atual" value="">
                <input type="hidden" id="bi_km_atual" value="">
                <input type="hidden" id="os_aberto_veiculo" value="">
                <input type="hidden" id="qtddependentes" value="">
                <input type="hidden" id="codigo_categoria_ndd" value="">
                <input type="hidden" id="solucao_pedagio" value="">
                <input type="hidden" id="id_rota_viagem" value="">
                <input type="hidden" id="motor_liberacao" name="motor_liberacao" value="">
                <input type="hidden" id="idcidadeorigem" value="0">
                <input type="hidden" id="cid_origem" value="">
                <input type="hidden" id="uf_origem" value="">
                <input type="hidden" id="idcidadedestino" value="0">
                <input type="hidden" id="cid_destino" value="">
                <input type="hidden" id="uf_destino" value="">
                <input type="hidden" id="idCidade" value="0">
                <input type="hidden" id="cidade" value="">
                <input type="hidden" id="uf" value="">
                <!--<input type="hidden" id="idredespachante" name="idredespachante" value="">-->
                <!--<input type="hidden" id="redspt_rzs" name="redspt_rzs" value="">-->
                <tr>
                    <td class="CelulaZebra1" width="8%">
                        <div align="right">Tipo:</div>
                    </td>
                    <td class="CelulaZebra1" colspan="5">
                        <input type="radio" id="distribuicao" checked name="tipoRoteirizacao" value="d" onclick="mostrarFiltros('d')">
                        Distribuição
                        <input type="radio" id="transferencia" name="tipoRoteirizacao" value="t" onclick="mostrarFiltros('t')">
                        Transferência
                    </td>
                </tr>
                <tr>
                    <td  class="CelulaZebra1">
                        <div align="right">Emissão:</div>
                    </td>
                    <td class="CelulaZebra1">
                        <input name="dataInicial" type="text" id="dataInicial" size="10" maxlength="10" value="" class="fieldDate" onBlur="alertInvalidDate(this)" onkeypress="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onkeyup="fmtDate(this, event)" >                    
                        Até:
                        <input name="dataFinal" type="text" id="dataFinal" size="10" maxlength="10" value="" class="fieldDate" onBlur="alertInvalidDate(this)" onkeypress="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onkeyup="fmtDate(this, event)"></div>
                    </td>  
                        <td class="CelulaZebra1" > <div align="right">Apenas as UF(s):</div></td>
                    <td class="CelulaZebra1">
                        <input name="ufs" type="text" class="inputtexto"  id="ufs" size="25">
                    </td>
                    <td class="CelulaZebra1" ><div align="right">Apenas a filial:</div></td>
                    <td  class="CelulaZebra1">                       
                        <select name="filial" type="text" class="inputtexto"  id="filial" onchange="mudarFilial();">
                            <c:forEach var="filial" varStatus="status" items="${listaFiliais}">          
                                <option value="${filial.idfilial}" >${filial.abreviatura}</option>
                            </c:forEach>
                        </select>
                    </td>
                </tr>
                
               <tr>               
                   <td  class="CelulaZebra1" >
                       <div align="right" id="lbFiltroTipoCte" name="lbFiltroTipoCte" >
                            Mostrar Apenas:
                        </div>
                    </td>
                    <td class="CelulaZebra1" colspan="5">
                        <div id="ipFiltroTipoCte" name="ipFiltroTipoCte" >
                            <input type="radio" name="tipoCteEmitidos" checked id="ambasfilial" value="ab">Ambas<br/>
                            <input type="radio" name="tipoCteEmitidos" id="filialEmitida" value="ef">CT-e(s) emitidos pela filial <label id="lbFilialFiltroF"></label><br/>
                            <input type="radio" name="tipoCteEmitidos" id="filialEmitidaOutra" value="epf">CT-e(s) emitidos por outras filiais mas que serão entregues pela filial <label id="lbFilialFiltroE"></label> <br/>
                        </div>
                    </td>
               </tr>
                <tr>
                    <td colspan="1" class="CelulaZebra1">
                        <div align="right">
                        Cliente:</td></div>
                    <td colspan="1" class="CelulaZebra1">
                        <input name="con_rzs" type="text" id="con_rzs" value="" size="25" readonly="true" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=5', 'Consignatario_');">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idconsignatario').value = '0';getObj('con_rzs').value = 'Todos os consignatarios';">
                    </td>
                    <td colspan="1" class="CelulaZebra1">
                        <div align="right">Remetente:</div>
                    </td>
                    <td colspan="1" class="CelulaZebra1">
                        <input name="rem_rzs" type="text" id="rem_rzs" value="" size="25" readonly="true" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=3', 'Remetente_');">
                        <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os remetentes';">
                    </td>
                    <td  colspan="1" class="CelulaZebra1">
                        <div align="right">
                            Destinatário:
                        </div>
                    <td  colspan="1" class="CelulaZebra1">
                        <input name="dest_rzs" type="text" id="dest_rzs" value="" size="25" readonly="true" class="inputReadOnly8pt">
                        <strong>
                            <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=4', 'Destinatario_');">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                        </strong>
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1" colspan="1"  ><div align="right">Apenas a série:</div></td>
                    <td class="CelulaZebra1">
                        <input name="serie" type="text" class="inputtexto"  id="serie" size="5">
                    </td>
                    <td class="CelulaZebra1" colspan="1" ><div align="right">N° Carga:</div></td>
                    <td class="CelulaZebra1">
                        <input name="numero_carga" type="text" class="inputtexto"  id="numero_carga" size="25" onkeypress="mascara(this,soNumeros)">
                    </td>

                        <td class="CelulaZebra1" colspan="" ><div align="right">Apenas os Manifestos:</div></td>
                    <td class="CelulaZebra1" >
                        <input name="nmanifesto" type="text" class="inputtexto"  id="nmanifesto" size="25">
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1" width="10%">
                        <div align="right">Tipo de Produto/Operação:</div>
                    </td>
                    <td class="CelulaZebra1" colspan="1">
                        <div>
                            <input name="prod_tipo" type="text" id="prod_tipo" class="inputReadOnly8pt" value="" size="50" maxlength="10" readonly>
                            <input name="localiza_prod" type="button" class="botoes" id="localiza_prod" value="..." onClick="controlador.acao('abrirLocalizar','localizarTipoProduto');">
                            <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink" id="limpavei" title="Limpar Veículo" onClick="removerValorInput('prod_tipo')">
                        </div>
                    </td>
                    
                    <td class="CelulaZebra1" width="10%">
                        <div align="right">Representante de Entrega:</div>
                    </td>
                    <td class="CelulaZebra1">
                        <input type="hidden" id="idredespachante" name="idredespachante">
                        <input name="redspt_rzs" id="redspt_rzs" type="text" value="" size="25" readonly="true" class="inputReadOnly8pt">
                        <input name="localiza_rem" type="button" class="botoes" value="..." id="localiza_rem" onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=23', 'Representante');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idredespachante').value = '0';getObj('redspt_rzs').value = 'Todos os Representantes';">
                    </td>
                   <td class="CelulaZebra1" width="10%">
                        <div align="right">Apenas os setores de entregas:</div>
                    </td>
                    <td class="CelulaZebra1">
                        <input type="text" name="setorEntrega" id="setorEntrega" class="inputReadOnly8pt" value="" size="20" maxlength="10">
                        <input name="localizarSetorEntrega" type="button" class="botoes" value="..." onClick="controlador.acao('abrirLocalizar','localizarSetorEntrega');">
                        <img src="img/borracha.gif" name="limparSetorEntrega" border="0" align="absbottom" class="imagemLink" id="limparSetorEntrega" title="Limpar Setor de Entrega" onClick="removerValorInput('setorEntrega')">
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1" width="10%">
                        <div align="right">Apenas os grupos de clientes:</div>
                    </td>
                    <td class="CelulaZebra1" colspan="5">
                        <input name="grupoCliente" type="text" id="grupoCliente" class="inputReadOnly8pt" value="" size="20" maxlength="10" readonly>
                        <input name="localizarGrupoCliente" type="button" class="botoes" value="..." onClick="controlador.acao('abrirLocalizar','localizarGrupoCliente');">
                        <img src="img/borracha.gif" name="limparGrupoCliente" border="0" align="absbottom" class="imagemLink" id="limparGrupoCliente" title="Limpar Grupo de Clientes" onClick="removerValorInput('grupoCliente')">
                    </td>
                </tr>
                <tr>
                    <td class="CelulaZebra1" colspan="6" ><div align="center"><b>Critérios de Agrupamento de Cargas</b></div></td>
                </tr>
                <tr id="container-agrupamento">
                    <td class="CelulaZebra1" colspan="1" >
                        <div align="right">
                            <label><input type="radio" name="cAgrupamento" id="peso" value="pe"  onclick="liberarAgrupamento(jQuery('#pesomaximo'))">Peso Máximo:</label>
                        </div>
                    </td>
                    <td class="CelulaZebra1" colspan="1">
                        <input name="pesomaximo" type="text" class="inputReadOnly" size="10" readonly id="pesomaximo" size="10">
                    </td>
                   
                    <td class="CelulaZebra1" colspan="1" >
                        <div align="right">
                            <label><input type="radio" name="cAgrupamento" id="entrega" value="en" onclick="liberarAgrupamento(jQuery('#qtdEntregas'))">Quantidade por Entregas:</label>
                        </div>
                    </td>
                    <td class="CelulaZebra1" colspan="1">
                        <input name="qtdEntregas" type="text" class="inputReadOnly" readonly id="qtdEntregas" size="10">
                    </td>
                        <td class="CelulaZebra1" colspan="1" >
                            <div align="right">
                                <label><input type="radio" name="cAgrupamento" id="cubagem" value="cb" onclick="liberarAgrupamento(jQuery('#cubagemMaxima'))">Cubagem Máxima:</label>
                            </div>
                        </td>
                        <td class="CelulaZebra1" colspan="1">
                        <input name="cubagemMaxima" type="text" class="inputReadOnly" readonly id="cubagemMaxima" size="10">
                    </td>
                </tr>      
                <tr>
                    <td  class="CelulaZebra1">
                        <div align="right"><label><input type="radio" name="cAgrupamento" value="nf" id="vlNf" onclick="liberarAgrupamento(jQuery('#vlNfeMaximo'))">Valor NF-e Máximo</label></div>
                    </td>
                    <td class="CelulaZebra1">
                        <input type="text" id="vlNfeMaximo" name="vlNfeMaximo" value="0.00" size="10" class="inputReadOnly" readonly >
                    </td>
                    <td class="CelulaZebra1" >
                        <div align="right"><label><input type="radio" name="cAgrupamento" value="ct" id="vlCte" onclick="liberarAgrupamento(jQuery('#vlCteMaximo'))">Valor CT-e Máximo</label></div>
                    </td>
                    <td class="CelulaZebra1">
                        <input type="text" id="vlCteMaximo" name="vlCteMaximo" value="0.00" size="10" class="inputReadOnly" readonly >
                    </td>
                    <td class="CelulaZebra1" >
                        <div align="right"><label><input type="radio" name="cAgrupamento" id="volume" value="vlu" onclick="liberarAgrupamento(jQuery('#qtdVolumeMaximo'))">QTD de Volumes Máximo</label></div>
                    </td>
                    <td  class="CelulaZebra1">
                        <input type="text" id="qtdVolumeMaximo" name="qtdVolumeMaximo"  size="10"  class="inputReadOnly" readonly value="0.00" >
                    </td>
                </tr>
            <tr>
                <td class="CelulaZebra1" colspan="6">
                    <input type="checkbox" id="agruparMDFeUF1" name="agruparMDFeUF1">
                    <label for="agruparMDFeUF1">Ao salvar, criar um manifesto para cada UF do agrupamento</label>
                </td>
            </tr>
            <tr>              
                <td colspan="8" class="CelulaZebra1">  <div align="center"><input name="pesquisar" type="button" class="inputbotao" value="  Pesquisar  " onclick="tryRequestToServer(function () {document.formulario.submit();});" /></div></td>
            </tr>
        </table>      
        </form> 
        <table id ="roteirizador" width="95%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">          
            <tr id="setores" colspan="15">
                <td width="100%">
                 <form action="RoteirizacaoControlador?acao=cadastrar" id="formu" name="formu" method="post">
                     
                <c:forEach var="roteirizador" varStatus="status" items="${listaRoteirizador}">     
                    <input type="hidden" id="maxRot" name="maxRot" value="${listaRoteirizador.size()}">
                <table id="setores_${status.count}" width="100%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center"> 
                    <tr>
                        <td class="tabela" width="3%" colspan="1">
                            <c:if test="${roteirizador.setor != 0}" >   
                            <input type="checkbox" id="ck_${status.count}" name="ck_${status.count}" onclick="javascript:checkTodos(${status.count});">
                            </c:if>
                        </td> 
                        <td colspan="${roteirizador.setor != 0 ? '2' : ''}" class="tabela">
                            <legend><label>${param.tipoOperacao == 't' ? "Filial Destino:" : "Setor:"} </label> ${roteirizador.descricaoSetor}</legend> 
                            <input type="hidden" id="idSetor_${status.count}" name="idSetor_${status.count}" value="${roteirizador.setor}"/>
                        </td>                        
                        <c:if test="${roteirizador.setor != 0}">
                            <td class="tabela">
                                <input type="button" id="btnVisualizarSetor" name="btnVisualizarSetor" class="inputbotao" value=" Visualizar Setor " onclick="javascript:tryRequestToServer(function(){abrirSetorEntrega('${roteirizador.setor}')});"/>                                
                            </td>                        
                        </c:if>
                            
                        <td colspan="1" class="tabela">Qtd. Veículos: <span id="qtdVeiculo_${status.count}"><fmt:formatNumber  type="number" value="${roteirizador.roteirizadorCTes.size()}"/></span> </td>
                        <td colspan="2" class="tabela">Notas: <span id="qtdNota_${status.count}"><fmt:formatNumber  type="number" value="${roteirizador.qtdNota}"/></span></td>
                        <td colspan="2" class="tabela">Peso: <span id="peso_total_${status.count}"><script>document.write(colocarVirgula(${roteirizador.peso}, 3))</script></span></td>
                          
                        <td colspan="2" class="tabela">Cubagem: <span id="cubagem_total_${status.count}"><script>document.write(colocarVirgula(${roteirizador.cubagem}, 2))</script></span> </td>
                        
                        <input type="hidden" id="maxVeiculo_${status.count}" name="maxVeiculo_${status.count}" value="${roteirizador.roteirizadorCTes.size()}">
                        <input type="hidden" id="filial_${status.count}" name="filial_${status.count}" value="${roteirizador.filial.idfilial}">
                        <input type="hidden" id="serieMdfe_${status.count}" name="serieMdfe_${status.count}" value="${roteirizador.filial.serieMdfe}">
                        
                        <input type="hidden" id="pesoTotal_${status.count}" name="pesoTotal_${status.count}" value="${roteirizador.peso}">
                        <input type="hidden" id="cubagemTotal_${status.count}" name="cubagemTotal_${status.count}" value="${roteirizador.cubagem}">
                        <input type="hidden" id="totalNotas_${status.count}" name="totalNotas_${status.count}" value="${roteirizador.qtdNota}">
                        
                    </tr>                   
                    
                    <c:forEach var="veiculo" varStatus="statusVei" items="${roteirizador.roteirizadorCTes}">    
                         
                    <tr id="veiculo_setor_${status.count}_${statusVei.count}">
                    <td colspan="12">
                    <table id="veiculos_${status.count}_${statusVei.count}" width="100%" border="0" cellpadding="2" cellspacing="1" class="bordaFina" align="center">    
                         <c:if test="${roteirizador.setor != 0}" >  
                        <tr id="info_veiculo_${status.count}_${statusVei.count}">
                            <td align="left" class="TextoCampos" width="5%">                                
                                <input type="checkbox" id="ckVei_${status.count}_${statusVei.count}" name="ckVei_${status.count}_${statusVei.count}"> 
                                <img onclick="addVeiculos(${status.count})" alt="addCampo" src="${homePath}/img/novo.gif" class="imagemLink"/>
                            </td>        
                            <td class="TextoCampos" colspan="1" width="5%"> <div align="right">Motorista:</div></td>
                            <td class="TextoCampos" colspan="1" width="10%">
                                <div align="left">
                                    <input type="hidden" id="idmotorista_${status.count}_${statusVei.count}" value="0" name="idmotorista_${status.count}_${statusVei.count}">
                                    <input name="motorista_${status.count}_${statusVei.count}" type="text" class="inputReadOnly" id="motorista_${status.count}_${statusVei.count}" value="" size="6" readonly="true" >
                                    <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" onClick="javascript:localizaMotorista(${statusVei.count}, ${status.count})" value="...">                            
                                </div>
                            </td> 
                            <td class="TextoCampos" colspan="1" width="10%"><div align="right"> Veículo:</div></td>
                            <td class="TextoCampos" colspan="1" width="10%">
                                <div align="left">
                                    <input type="hidden" id="idveiculo_${status.count}_${statusVei.count}" value="0" name="idveiculo_${status.count}_${statusVei.count}">
                                    <input name="veiculo_${status.count}_${statusVei.count}" type="text" class="inputReadOnly" id="veiculo_${status.count}_${statusVei.count}" value="" size="6" readonly="true" >
                                    <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="javascript:localizaVeiculo(${statusVei.count}, ${status.count})" value="...">
                                </div>
                            </td> 
                            <td class="TextoCampos" colspan="1" width="10%"><div align="right"> Carreta:</div></td>
                            <td class="TextoCampos" colspan="1" width="11%">
                                <div align="left">
                                    <input type="hidden" id="idcarreta_${status.count}_${statusVei.count}" value="0" name="idcarreta_${status.count}_${statusVei.count}">
                                    <input name="carreta_${status.count}_${statusVei.count}" type="text" class="inputReadOnly" id="carreta_${status.count}_${statusVei.count}" value="" size="6" readonly="true" >
                                    <input name="localiza_carreta" type="button" class="botoes" id="localiza_carreta" onClick="javascript:localizaCarreta(${statusVei.count}, ${status.count})" value="...">
                                    <img src="img/borracha.gif" style="display: " id="limparCarreta_${status.count}_${statusVei.count}" name="limparCarreta_${status.count}_${statusVei.count}" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:limparCarreta(${status.count},${statusVei.count});"> 
                                    </div>

                            </td> 
                            <td class="TextoCampos" colspan="1" width="10%"><div align="right"> Bitrem:</div></td>
                            <td class="TextoCampos" colspan="1" width="12%">
                                <div align="left">
                                     <input type="hidden" id="idbitrem_${status.count}_${statusVei.count}" value="0" name="idbitrem_${status.count}_${statusVei.count}">
                                    <input name="bitrem_${status.count}_${statusVei.count}" type="text" class="inputReadOnly" id="bitrem_${status.count}_${statusVei.count}" value="" size="6" readonly="true" >
                                    <input name="localiza_bitrem" type="button" class="botoes" id="localiza_bitrem" onClick="javascript:localizaBitrem(${statusVei.count}, ${status.count})" value="...">
                                    <img src="img/borracha.gif" style="display: " id="limparBitrem_${status.count}_${statusVei.count}" name="limparBitrem_${status.count}_${statusVei.count}" border="0" align="absbottom" class="imagemLink" title="Limpar Bitrem" onClick="javascript:limparBitrem(${status.count},${statusVei.count});">   
                                    </div>
                            </td>   
                           
                            <td colspan="2" class="TextoCampos" width="16%"> 
                                <div align="left">
                                    <input type="radio" name="tipo_${status.count}_${statusVei.count}" id="romaneio_${status.count}_${statusVei.count}" value="r"  onclick="javascript:alterarTipo(this.value, ${status.count}, ${statusVei.count});" checked> Romaneio
                                    <input type="radio" name="tipo_${status.count}_${statusVei.count}" id="manifesto_${status.count}_${statusVei.count}" value="m" onclick="javascript:alterarTipo(this.value, ${status.count}, ${statusVei.count});" ${param.tipoOperacao == "t" ? "checked" : ""} > Manifesto
                                </div>
                            </td>
                        </tr>
                        <tr id="trCidade_${status.count}_${statusVei.count}">
                            <td  class="TextoCampos" colspan="2">Cidade de origem:</td>
                            <td colspan="3" class="CelulaZebra2">
                                <input type="text" name="cid_origem_${status.count}_${statusVei.count}" id="cid_origem_${status.count}_${statusVei.count}" size="30" class="inputReadOnly" value="${roteirizador.filial.cidade.descricaoCidade}" readonly="true">
                                <input type="text" name="uf_origem_${status.count}_${statusVei.count}" size="2" id="uf_origem_${status.count}_${statusVei.count}" class="inputReadOnly" value="${roteirizador.filial.cidade.uf}">
                                <input type="hidden" name="idcidadeorigem_${status.count}_${statusVei.count}" id="idcidadeorigem_${status.count}_${statusVei.count}" class="inputReadOnly" value="${roteirizador.filial.cidade.idcidade}" >
                                <input type="button" name="localizaCidade_${status.count}_${statusVei.count}" id="localizaCidade_${status.count}_${statusVei.count}" class="inputBotaoMin" value="..." onclick="localizarCidadeOri(${statusVei.count}, ${status.count});">
                            <!--<td class="CelulaZebra2" colspan="1"></td>-->
                                 <td  class="TextoCampos" colspan="2">Cidade de destino:</td>
                                <td colspan="3" class="CelulaZebra2">
                                    <input type="text" name="cid_destino_${status.count}_${statusVei.count}" id="cid_destino_${status.count}_${statusVei.count}" size="30" class="inputReadOnly" value="" readonly="true">
                                    <input type="text" name="uf_destino_${status.count}_${statusVei.count}" size="2" id="uf_destino_${status.count}_${statusVei.count}" class="inputReadOnly" value="" readonly="true">
                                    <input type="hidden" name="idcidadedestino_${status.count}_${statusVei.count}" id="idcidadedestino_${status.count}_${statusVei.count}" class="inputReadOnly" value="0" >
                                    <input type="button" name="localizaCidade_${status.count}_${statusVei.count}" id="localizaCidade_${status.count}_${statusVei.count}" class="inputBotaoMin" value="..." onclick="localizarCidadeDest(${statusVei.count}, ${status.count});">
                                </td>                                
                            </td>
                            <td class="CelulaZebra2" colspan="3"></td>
                        </tr>
                        <tr id="trManifesto_${status.count}_${statusVei.count}" ${param.tipoOperacao == "d" ? "style='display: none'" : ""}>
                            <td class="TextoCampos" colspan="2"><div align="right">Rota:</div></td>
                            <td class="CelulaZebra2" colspan="1">
                                <select name="rota_${status.count}_${statusVei.count}" id="rota_${status.count}_${statusVei.count}" class="fieldMin" onchange="getRotaPercurso(${status.count},${statusVei.count});" >
                                    <option value="0">Rota não informada</option>                                            
                                </select>                                                                                       
                            </td>
                            <td class="TextoCampos"  colspan="1"><div align="right">Percurso:</div></td>
                            <td class="celulaZebra2"  colspan="1"><div align="left">
                                <select name="percurso_${status.count}_${statusVei.count}" id="percurso_${status.count}_${statusVei.count}" class="fieldMin" >
                                    <option value="0">----------</option>
                                </select>
                                    </div>
                            </td>
                            <td colspan="1" class="TextoCampos"><div align="right">Nº Liberação Mot.:</div></td>
                            <td colspan="1" class="CelulaZebra2"><div align="left">
                                <input type="text" class="inputtexto" id="nliberacao_${status.count}_${statusVei.count}" name="nliberacao_${status.count}_${statusVei.count}" size="10"> 
                                </div>
                            </td>
                            <td  class="CelulaZebra2NoAlign" align="right" colspan="1">
                               <select style="width:80px;" id="tipoFilialRep_${status.count}_${statusVei.count}" name="tipoFilialRep_${status.count}_${statusVei.count}" type="text" class="inputtexto" onchange="alterarFilialRepresentante('${status.count}','${statusVei.count}')">
                                   <option value="filial">Filial Destino</option>
                                   <option value="representante">Representante Destino</option>
                               </select>
                           :
                            </td>    
                            <td  class="celulaZebra2"colspan="1" style="display: " id="tdFilialDestino_${status.count}_${statusVei.count}" name="tdFilialDestino_${status.count}_${statusVei.count}">
                                <div align="left">
                                    <select name="filialdestino_${status.count}_${statusVei.count}" ${param.tipoOperacao == 't' ? "disabled = true" :  ""} type="text" class="inputtexto"  id="filialdestino_${status.count}_${statusVei.count}">
                                        <c:forEach var="filial" varStatus="statusFilial" items="${listaFiliais}">
                                            <c:choose >
                                                <c:when test="${filial.idfilial == roteirizador.setor}">
                                                    <option value="${filial.idfilial}" selected >${filial.abreviatura}</option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="${filial.idfilial}"  >${filial.abreviatura}</option>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </select>
                                </div>
                            </td>
                            <td  class="TextoCampos" colspan="1" id="tdRepresentanteDestino_${status.count}_${statusVei.count}" name="tdRepresentanteDestino_${status.count}_${statusVei.count}" style="display: none">
                                <div align="left">
                                    <input type="text" name="representanteDestino_${status.count}_${statusVei.count}" id="representanteDestino_${status.count}_${statusVei.count}" size="13" class="inputReadOnly" value="" readonly="true">
                                    <input type="hidden" name="idRepresentanteDestino_${status.count}_${statusVei.count}" id="idRepresentanteDestino_${status.count}_${statusVei.count}" class="inputReadOnly" value="0" >
                                    <input type="button" name="localizaRepresentanteDestino_${status.count}_${statusVei.count}" id="localizaRepresentanteDestino_${status.count}_${statusVei.count}" class="inputBotaoMin" value="..." onclick="localizarRepresentante(${statusVei.count}, ${status.count});">
                                </div>
                            </td>  
                            <td  colspan="1" class="TextoCampos"><div align="right">Tipo:</div></td>
                            <td  colspan="1" class="CelulaZebra2">
                                <div align="left">
                                    <select name="tipo_${status.count}_${statusVei.count}" id="tipo_${status.count}_${statusVei.count}" class="inputtexto">
                                        <option value="m">Rodoviario</option>
                                        <option value="a">Aéreo</option>
                                        <option value="f">Aquaviario </option>
                                    </select>                           
                                </div>
                            </td>
                        </tr> 
                        </c:if>
                        <tr class="cte_veiculo_${status.count}_${statusVei.count}">
                        <td colspan="12">
                        <table id="ctes_${status.count}_${statusVei.count}" class="bordaFina teste" width="100%" border="0" cellpadding="2" cellspacing="1" align="center">          
                            <tbody id="tbCte_${status.count}_${statusVei.count}" class="move connect">
                            <tr class="cte naoMove">
                                <td class="celulaZebra1" width="1%"></td>
                                <td class="CelulaZebra1" width="4%" ><div align="center"><b>Número</b></div></td>
                                <td class="CelulaZebra1" width="6%" ><div align="center"><b>Emissão</b></div></td>
                                <td class="CelulaZebra1" width="20%" ><div align="center"><b>Remetente/Destinatário</b></div></td>
                                <td class="CelulaZebra1" width="15%" ><div align="center"><b>Endereço</b></div></td>
                                <td class="CelulaZebra1" width="8%" ><div align="center"><b>Bairro</b></div></td>
                                <td class="CelulaZebra1" width="8%" ><div align="center"><b>Cidade/UF</b></div></td>
                                <td class="CelulaZebra1" width="4%" ><div align="center"><b>Qtd Notas</b></div></td>
                                <td class="CelulaZebra1" width="5%" ><div align="center"><b>Peso R.</b></div></td>
                                <td class="CelulaZebra1" width="5%" ><div align="center"><b>Cubagem</b></div></td>
                                <td class="CelulaZebra1" width="5%" ><div align="center"><b>Valor Merc.</b></div></td>
                                <td class="CelulaZebra1" width="4%" ><div align="center"><b>Volume</b></div></td>
                                <td class="CelulaZebra1" width="10%" ><div align="center"><b>Valor CT-e</b></div></td>
                                <td class="CelulaZebra1" width="5%" ></td>
                                <input type="hidden" id="size_${status.count}_${statusVei.count}" name="size_${status.count}_${statusVei.count}" value="${roteirizador.cTe.size()}">
                            </tr>
                            <c:forEach var="cte" varStatus="statusCte" items="${veiculo.cTe}"> 
                                <tr class="${(statusCte.count % 2 == 0 ? 'CelulaZebra1' : 'CelulaZebra2')}"  id="cte_${status.count}_${statusVei.count}_${statusCte.count}" name="cte_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <td width="1%">
                                        <img src="img/ordenar.png" width="13px" heigth="13px" class="handler2">
                                    </td>
                                    <td width="4%"  class="numero"> <div class="linkEditar"  onClick="javascript:tryRequestToServer(function(){editarconhecimento(${cte.id},null);});">  ${cte.numero}</td>
                                    <td width="7%"  class="emissao">${cte.getEmissaoEmS()}</td>
                                    <td width="25%"  class="nome"><span style="white-space: nowrap;">${cte.remetente.razaosocial}</span> <br /> <span style="white-space: nowrap;">${cte.destinatario.razaosocial}</span></td>
                                    <td width="15"  class="endereco">${cte.destinatario.endereco}</td>
                                    <td width="10%"  class="bairro">${cte.destinatario.bairro}</td>
                                    <td width="10%"  class="cidade" >${cte.destinatario.cidade.descricaoCidade}/${cte.destinatario.cidade.uf}</td>
                                    <td width="4%"  class="notas" id="notas_${status.count}_${statusVei.count}_${statusCte.count}" name="notas_${status.count}_${statusVei.count}_${statusCte.count}"><div align="right">${cte.qtdNotas}</div></td>
                                    <td width="5%"  class="peso" id="peso_${status.count}_${statusVei.count}_${statusCte.count}" name="peso_${status.count}_${statusVei.count}_${statusCte.count}"><div align="right"><script>document.write(colocarVirgula(${cte.nota.peso}, 3))</script></div> </td>
                                    <td width="5%"  class="metro" id="metro_${status.count}_${statusVei.count}_${statusCte.count}" name="metro_${status.count}_${statusVei.count}_${statusCte.count}"><div align="right"><script>document.write(colocarVirgula(${cte.nota.metroCubico}))</script></div></td>
                                    <td width="5%"  class="valor"><div align="right"><script>document.write(colocarVirgula(${cte.nota.valor}))</script></div></td>
                                    <td width="4%"  class="volume" id="volume_${status.count}_${statusVei.count}_${statusCte.count}" name="volume_${status.count}_${statusVei.count}_${statusCte.count}"><div align="right"><script>document.write(getParseNumero(${cte.nota.volume}))</script></div></td>
                                    <td width="18%"  class="total"><div align="right"><script>document.write(colocarVirgula(${cte.totalReceita}))</script></div></td>
                                    <td align="left"  class="obsr" id="obsRot_${status.count}_${statusVei.count}_${statusCte.count}" style="${(roteirizador.setor != 0 ? 'display:' : 'display:none')}" > <img src="${homePath}/img/v.png" class="imagemLink" title="CT-e Roteirizado"></td>
                                    <td align="left" class="obsn" id="obsnRot_${status.count}_${statusVei.count}_${statusCte.count}" style="${(roteirizador.setor == 0 ? 'display:' : 'display:none')}" ><img src="${homePath}/img/x.png" class="imagemLink" title="CT-e não possui bairro cadastrado em setor"></td>
                                    <td align="left" width="5%" class="obse" id="obsEscUsu_${status.count}_${statusVei.count}_${statusCte.count}" style="display:none" ><img src="${homePath}/img/ajuda.png" class="imagemLink" title="CT-e movido manualmente"/></td>

                                    <input type="hidden" class="idcte" value="${cte.id}" id="idcte_${status.count}_${statusVei.count}_${statusCte.count}" name="idcte_${status.count}_${statusVei.count}_${statusCte.count}"/>
                                    <input type="hidden" value="${cte.nota.peso}" id="pesoCte_${status.count}_${statusVei.count}_${statusCte.count}" name="pesoCte_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" value="${cte.nota.volume}" id="volumeCte_${status.count}_${statusVei.count}_${statusCte.count}" name="volumeCte_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" value="${cte.qtdNotas}" id="notasCte_${status.count}_${statusVei.count}_${statusCte.count}" name="notasCte_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" value="${cte.nota.metroCubico}" id="metroCte_${status.count}_${statusVei.count}_${statusCte.count}" name="metroCte_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" value="${cte.filial.idfilial}" id="filialCte_${status.count}_${statusVei.count}_${statusCte.count}" name="filialCte_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" class="movido" value="false" id="movido_${status.count}_${statusVei.count}_${statusCte.count}" name="movido_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" value="${cte.destinatario.cidade.uf}" id="uf_destino_${status.count}_${statusVei.count}_${statusCte.count}" name="uf_destino_${status.count}_${statusVei.count}_${statusCte.count}">
                                    <input type="hidden" value="${cte.destinatario.cidade.idcidade}" id="cidade_destino_id_${status.count}_${statusVei.count}_${statusCte.count}" name="cidade_destino_id_${status.count}_${statusVei.count}_${statusCte.count}">
                                </tr>
                            </c:forEach>
                           </tbody>
                            </table> <!-- CTE -->
                        </td>
                        </tr> <!-- CTES -->
                    </table> <!-- VEICULO -->	
                    
                    </td>
                    </tr> <!-- VEICULOS -->
                   </c:forEach> <!--veiculo-->
                </table> <!-- SETOR -->
            </c:forEach> <!--for de Roteirizador-->
                     
                <input type="hidden" name="agruparMDFeUF" id="agruparMDFeUF">
            </form>
            </td>
        </tr><!-- SETORES -->
        </table><!-- ROTEIRIZADOR -->
        <br>
        <table class="bordaFina" width="95%" align="center" >
            <tr class="CelulaZebra1">
                <td colspan="6" class="CelulaZebra2" >
                    <div align="center">
                        <input type="button" value="  SALVAR  " id="botSalvar" class="inputbotao" onClick="javascript:salvar()"/>
                    </div>
                </td>
            </tr>
        </table>

        <div class="cobre-tudo"></div>
        <div class="localiza">
            <iframe id="localizarSetorEntrega" input="setorEntrega" name="localizarSetorEntrega" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarSetorEntrega" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarTipoProduto" input="prod_tipo" name="localizarTipoProduto" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarTipoProduto" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        <div class="localiza">
            <iframe id="localizarGrupoCliente" input="grupoCliente" name="localizarGrupoCliente" src="${homePath}/LocalizarControlador?acao=abrirLocalizar&idLocalizar=localizarGrupoCliente" frameborder="0" marginheight="0" marginwidth="0" scrolling="no" ></iframe>
        </div>
        
        <script defer src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/assets/js/jquery-ui.min.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/gwTrans/localizar/js/LocalizarControladorJS.js?v=${random.nextInt()}"></script>
        <script defer src="${homePath}/script/funcoesTelaRoterizacao.js?v=${random.nextInt()}"></script>
        
    </body>
</html>