<meta http-equiv="pragma" content="no-cache">
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript" src="script/jquery.js"	type="text/javascript"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
    jQuery.noConflict();
    var listaUfs = new Array(29);
    listaUfs[0] = new Option("AC", "Acre");
    listaUfs[1] = new Option("AL", "Alagoas");
    listaUfs[2] = new Option("AP", "Amap�");
    listaUfs[3] = new Option("AM", "Amazonas");
    listaUfs[4] = new Option("BA", "Bahia");
    listaUfs[5] = new Option("CE", "Cear�");
    listaUfs[6] = new Option("DF", "Distrito Federal");
    listaUfs[7] = new Option("ES", "Espirito Santo");
    listaUfs[8] = new Option("GO", "Goi�s");
    listaUfs[9] = new Option("MA", "Maranh�o");
    listaUfs[10] = new Option("MT", "Mato Grosso");
    listaUfs[11] = new Option("MS", "Mato Grosso do Sul");
    listaUfs[12] = new Option("MG", "Minas Gerais");
    listaUfs[13] = new Option("PA", "Par�");
    listaUfs[14] = new Option("PB", "Paraiba");
    listaUfs[15] = new Option("PR", "Paran�");
    listaUfs[16] = new Option("PE", "Pernambuco");
    listaUfs[17] = new Option("PI", "Piau�");
    listaUfs[18] = new Option("RJ", "Rio de Janeiro");
    listaUfs[19] = new Option("RN", "Rio Grande do Norte");
    listaUfs[20] = new Option("RS", "Rio Grande do Sul");
    listaUfs[21] = new Option("RO", "Rond�nia");
    listaUfs[22] = new Option("RR", "Roraima");
    listaUfs[23] = new Option("SC", "Santa Catarina");
    listaUfs[24] = new Option("SP", "S�o Paulo");
    listaUfs[25] = new Option("SE", "Sergipe");
    listaUfs[26] = new Option("TO", "Tocantins");
    listaUfs[27] = new Option("EX", "Exterior");
    listaUfs[28] = new Option("FN", "FN");
    
    function voltar(){
        document.location.replace("./menu");
    }
    
    function excluir(index){
        var id = $("id_"+index).value;
        tryRequestToServer(function(){
            if(confirm("Deseja excluir o item ?")){
                if(confirm("Tem certeza?")){
                    Element.remove("trUfIcms_"+index);
                    if (id != 0) {
                        new Ajax.Request("UfIcmsControlador?acao=excluir&id="+id,
                        {
                            method:'get',
                            onSuccess: function(){ alert('Item removido com sucesso!') 
                                                   var qdt = parseInt(document.getElementById("quantidade").value);
                                                   qdt = qdt - 1;
                                                   document.getElementById("quantidade").value = qdt;
                                                                                    },
                            onFailure: function(){ alert('Something went wrong...') }
                        });     
                     }
                }
            }
        }
      );        
    }
    
    function limparCidade (countAliquotas){
        $("descricaoCidade_"+countAliquotas).value = "";
        $("idCidade_"+countAliquotas).value = 0;
    }
    
    function limparItens (countAliquotas){
        $("descricaoObservacao_"+countAliquotas).value = "";
        $("idObservacao_"+countAliquotas).value = 0;
    }
    
    function ajaxCarregarAliquotas(){
        var aliq;

        function e(transport){
            var lista = jQuery.parseJSON(transport.responseText);
            var listItens = lista.list[0].aliq;
            var length = (listItens != undefined && listItens.length != undefined ? listItens.length : 1);

                if (length > 1) {
                for(var i = 0; i < length; i++){
                    aliq = new Aliquotas();
                    aliq.id = listItens[i].id;
                    aliq.ufOrigem = listItens[i].ufOrigem;
                    aliq.ufDestino = listItens[i].ufDestino;
                    aliq.aliquota = listItens[i].aliquota;
                    aliq.aliquotaPessoaFisica = listItens[i].aliquotaPessoaFisica;
                    aliq.reducao = listItens[i].reducaoBaseIcms;
                    aliq.aliquotaAereo = listItens[i].aliquotaAereo;
                    aliq.aliquotaAereoPessoaFisica = listItens[i].aliquotaAereoPessoaFisica;
                    aliq.idObservacao = listItens[i].obs.id;
                    if(aliq.idObservacao != 0){
                        aliq.descricaoObservacao = listItens[i].obs.descricao;
                    }
                    aliq.idCidade = listItens[i].cidade.idcidade;
                    if(aliq.idCidade != 0){
                        aliq.descricaoCidade = listItens[i].cidade.descricaoCidade;
                    }

                    addAliquotas(aliq);
                }
            }
        }
        tryRequestToServer(function(){new Ajax.Request("UfIcmsControlador?acao=ajaxCarregarAliquotas&idfilial="+
                document.getElementById("idfilial").value,
            {
                method:'get',
                onSuccess: e,
                onFailure: e
            });
        });
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=08','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function salva(){
        if (!false){
            document.getElementById("salvar").disabled = true;
            document.getElementById("salvar").value = "Enviando...";
            
            var formu = document.formulario;
            window.open('about:blank', 'pop', 'width=210, height=100');
            formu.submit(); 
            return true;
        }else
            alert("Preencha os campos corretamente!");
    }

    function mostrar(){
        var url = "UfIcmsControlador?acao=listar&idfilial="+document.getElementById("idfilial").value+
            "&fi_abreviatura="+document.getElementById("fi_abreviatura").value;
        document.location.replace(url);
    }

    function localizaobs(linha){
        document.getElementById("linha").value = linha;
        post_cad = window.open('./localiza?acao=consultar&idlista=28','Observacao',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
    
    function localizacidade(linha){
        document.getElementById("linha").value = linha;
        post_cad = window.open('./localiza?acao=consultar&idlista=12','Cidade_Destino',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela){
      if ((idjanela == "Observacao")){
          var campo = "descricaoObservacao_"+document.getElementById("linha").value;
          var campo2 = "idObservacao_"+document.getElementById("linha").value;
          getObj(campo).value = getObj("obs_desc").value
          getObj(campo2).value = getObj("id").value
      }else if (idjanela == "Filial"){
          tryRequestToServer(function(){mostrar();});
      }else if ((idjanela == "Cidade_Destino")){
          var campo3 = "descricaoCidade_"+document.getElementById("linha").value;
          var campo4 = "idCidade_"+document.getElementById("linha").value;
          getObj(campo3).value = getObj("cid_destino").value
          getObj(campo4).value = getObj("idcidadedestino").value
      }
    }
  
    function Aliquotas(id,ufOrigem,ufDestino,aliquota,aliquotaPessoaFisica, reducao, aliquotaAereo, aliquotaAereoPessoaFisica, idObservacao, descricaoObservacao, idCidade, descricaoCidade){
        this.id = (id != undefined && id != null ? id : 0);
        this.ufOrigem = (ufOrigem != undefined && ufOrigem != null ? ufOrigem : 0);
        this.ufDestino = (ufDestino != undefined && ufDestino != null ? ufDestino : 0);
        this.aliquota = (aliquota != undefined && aliquota!= null ? aliquota : 0);
        this.aliquotaPessoaFisica = (aliquotaPessoaFisica != undefined && aliquotaPessoaFisica!= null ? aliquotaPessoaFisica : 0);
        this.reducao = (reducao != undefined && reducao != null ? reducao : 0);
        this.aliquotaAereo = (aliquotaAereo != undefined && aliquotaAereo!= null ? aliquotaAereo : 0);
        this.aliquotaAereoPessoaFisica = (aliquotaAereoPessoaFisica != undefined && aliquotaAereoPessoaFisica!= null ? aliquotaAereoPessoaFisica : 0);
        this.idObservacao = (idObservacao != undefined && idObservacao != null ? idObservacao : 0);
        this.descricaoObservacao = (descricaoObservacao != undefined && descricaoObservacao != null ? descricaoObservacao : "");
        this.idCidade = (idCidade != undefined && idCidade != null ? idCidade : 0);
        this.descricaoCidade = (descricaoCidade != undefined && descricaoCidade != null ? descricaoCidade : "");
    }      
    
    var countAliquotas = 0;
  
    function addAliquotas(aliquotas){
        if (aliquotas == null || aliquotas == undefined){
            aliquotas = new Aliquotas();
        } 
        countAliquotas++; 

        if(aliquotas.id == 0){
            var qdt = parseInt(document.getElementById("quantidade").value);
            qdt = qdt + 1;
            document.getElementById("quantidade").value = qdt;
        }

        var homePath = $("homePath").value;
        var tabelaBase = $("aliquota");

        var tr = Builder.node ("tr" , {
            className:"CelulaZebra2",
            id:"trUfIcms_" + countAliquotas  
        });

        var td0 = Builder.node ("td" , {
            align: "center"
        });

        var img0 = Builder.node("img",{
            className:"imagemLink",
            src: homePath + "img/lixo.png",
            onclick:"excluir("+countAliquotas+");"

        });

        var td1 = Builder.node ("td" , {
            align :"center"

        });

        var td2 = Builder.node ("td" , {
            align :"center"

        });

        var td3 = Builder.node ("td" , {
            align :"center"

        });

        var td4 = Builder.node ("td" , {
            align :"center"

        });

        var td5 = Builder.node ("td" , {
            align :"center"

        });

        var td6 = Builder.node ("td" , {
            align :"center"

        });

        var td7 = Builder.node ("td" , {
            align :"center"

        });

        var td8 = Builder.node ("td" , {
            align :"center"

        });

        var td9 = Builder.node ("td" , {
            align :"center"

        });

        var inp2 = Builder.node ("input" , {
            type  : "hidden" ,
            name  : "id_" + countAliquotas ,
            id    : "id_" + countAliquotas ,
            value : aliquotas.id
        });

        var slcOri = Builder.node ("select" , {
            name  : "ufOrigem_" + countAliquotas ,
            id    : "ufOrigem_" + countAliquotas,
            className : "fieldMin"
        });

        var optOri = null;
        for(var i = 0; i < listaUfs.length; i++){                
            optOri = Builder.node("option", {
                value: listaUfs[i].valor
            }, listaUfs[i].descricao);

            slcOri.appendChild(optOri);
        }
        slcOri.value = aliquotas.ufOrigem;


        var slcDest = Builder.node ("select" , {
            name  : "ufDestino_" + countAliquotas ,
            id    : "ufDestino_" + countAliquotas ,
            className : "fieldMin"
        });

        var optDest = null;
        for(var i = 0; i < listaUfs.length; i++){                
            optDest = Builder.node("option", {
                value: listaUfs[i].valor
            }, listaUfs[i].descricao);

            slcDest.appendChild(optDest);
        }
        slcDest.value = aliquotas.ufDestino;

        var inp3 = Builder.node ("input" , {
            type  : "text" ,
            size  : "9",
            maxLength : "9" ,
            className: "fieldMin",
            name  : "aliquota_" + countAliquotas ,
            id    : "aliquota_" + countAliquotas ,
            onKeyPress: "mascara(this,reais)",
            value : colocarVirgula(aliquotas.aliquota)
        });

        var inp4 = Builder.node ("input" , {
            type  : "text" ,
            size  : "9",
            maxLength : "9" ,
            className: "fieldMin",
            name  : "aliquotaPessoaFisica_" + countAliquotas ,
            id    : "aliquotaPessoaFisica_" + countAliquotas ,
            onKeyPress: "mascara(this,reais)",
            value : colocarVirgula(aliquotas.aliquotaPessoaFisica)
        });

        var inp5 = Builder.node ("input" , {
            type  : "text" ,
            size  : "9",
            maxLength : "9" ,
            className: "fieldMin",
            name  : "reducao_" + countAliquotas ,
            id    : "reducao_" + countAliquotas ,
            onKeyPress: "mascara(this,reais)",
            value : colocarVirgula(aliquotas.reducao)
        });

        var inp6 = Builder.node ("input" , {
            type  : "text" ,
            size  : "9",
            maxLength : "9" ,
            className: "fieldMin",
            name  : "aliquotaAereo_" + countAliquotas ,
            id    : "aliquotaAereo_" + countAliquotas ,
            onKeyPress: "mascara(this,reais)",
            value : colocarVirgula(aliquotas.aliquotaAereo)
        });

        var inp7 = Builder.node ("input" , {
            type  : "text" ,
            size  : "9",
            maxLength : "9" ,
            className: "fieldMin",
            name  : "aliquotaAereoPessoaFisica_" + countAliquotas ,
            id    : "aliquotaAereoPessoaFisica_" + countAliquotas ,
            onKeyPress: "mascara(this,reais)",
            value : colocarVirgula(aliquotas.aliquotaAereoPessoaFisica)
        });

        var inp8 = Builder.node ("input" , {
            type  : "hidden" ,
            name  : "idObservacao_" + countAliquotas ,
            id    : "idObservacao_" + countAliquotas ,
            value : aliquotas.idObservacao
        });

        var text1 = Builder.node ("input", {
            id : "descricaoObservacao_" + countAliquotas ,
            name : "descricaoObservacao_" + countAliquotas ,
            className:"fieldMin",
            type  : "text" ,
            size  : "15",
            maxLength : "15" ,
            value : aliquotas.descricaoObservacao

        });
        readOnly(text1);

        var btn1 = Builder.node("input" , {
            id : "botaoItens_" + countAliquotas ,
            name : "botaoItens" + countAliquotas ,
            className : "inputBotaoMin" ,    
            onclick:"tryRequestToServer(function(){localizaobs(" + countAliquotas + ")})", 
            type : "button" ,
            value : "..."
        });

        var img2 = Builder.node("img" , {
            id: "borracha" ,
            className:"imagemLink",
            src: homePath + "img/borracha.gif",
            onclick:"limparItens("+ countAliquotas +");"
        });

        var inp9 = Builder.node ("input" , {
            type  : "hidden" ,
            name  : "idCidade_" + countAliquotas ,
            id    : "idCidade_" + countAliquotas ,
            value : aliquotas.idCidade
        });

        var text2 = Builder.node ("input", {
            id : "descricaoCidade_" + countAliquotas ,
            name : "descricaoCidade_" + countAliquotas ,
            className:"fieldMin",
            type  : "text" ,
            size  : "15",
            maxLength : "15" ,
            value : aliquotas.descricaoCidade

        });

        readOnly(text2);

        var btn2 = Builder.node("input" , {
            id : "botaoCidades_" + countAliquotas ,
            name : "botaoCidades" + countAliquotas ,
            className : "inputBotaoMin" ,    
            onclick:"tryRequestToServer(function(){localizacidade(" + countAliquotas + ")})", 
            type : "button" ,
            value : "..."
        });

        var img3 = Builder.node("img" , {
            id: "borracha" ,
            className:"imagemLink",
            src: homePath + "img/borracha.gif",
            onclick:"limparCidade("+ countAliquotas +");"
        });

        td0.appendChild(img0);
        td0.appendChild(img0);
        td0.appendChild(img0);

        td1.appendChild(inp2);

        td1.appendChild(slcOri);

        td8.appendChild(slcDest);

        td2.appendChild(inp3);

        td3.appendChild(inp4);

        td4.appendChild(inp5);

        td5.appendChild(inp6);

        td6.appendChild(inp7);

        td7.appendChild(inp8);
        td7.appendChild(text1);
        td7.appendChild(btn1);
        td7.appendChild(img2);

        td9.appendChild(inp9);
        td9.appendChild(text2);
        td9.appendChild(btn2);
        td9.appendChild(img3);

        tr.appendChild(td0);
        tr.appendChild(td1);
        tr.appendChild(td8);
        tr.appendChild(td2);
        tr.appendChild(td3);
        tr.appendChild(td4);
        tr.appendChild(td5);
        tr.appendChild(td6);
        tr.appendChild(td7);
        tr.appendChild(td9);

        tabelaBase.appendChild(tr);
        $("max").value = countAliquotas;
        slcOri.focus();
    }

</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Al&iacute;quotas ICMS</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>
    <body onload="ajaxCarregarAliquotas();">
        <form action="UfIcmsControlador?acao=atualizar" id="formulario" name="formulario" method="post" target="pop">
            <img src="img/banner.gif">
            <br>
            <input type="hidden" name="idfilial" id="idfilial" value="${param.idfilial}">
            <input type="hidden" name="quantidade" id="quantidade" value="${param.qtdResultados}">
            <input type="hidden" name="obs_desc" id="obs_desc" value="0">
            <input type="hidden" name="id" id="id" value="0">
            <input type="hidden" id="homePath" value="${homePath}">
            <input type="hidden" name="linha" id="linha" value="">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="">
            <input type="hidden" name="cid_destino" id="cid_destino" value="">
            <table width="97%" align="center" class="bordaFina" >
                <tr>
                    <td width="613">
                        <div align="left">
                            <b>Al&iacute;quotas de ICMS por Estado </b>
                        </div>
                    </td>
                </tr>
            </table>
            <br>
            <table width="97%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr class="tabela"> 
                    <td colspan="2">
                        <div align="center">Filial selecionada</div>
                    </td>
                </tr>
                <tr class="CelulaZebra2"> 
                    <td width="258"> 
                        <div align="center">
                            <input name="fi_abreviatura" type="text" id="fi_abreviatura" class="inputReadOnly" value="${param.abreviatura}" size="35" readonly>
                            <input  name="localiza_filial" type="button" class="botoes" id="localiza_filial" onClick="javascript:localizafilial();" value="...">
                        </div>
                    </td>
                    <td width="229">
                        <div align="center">                                                                           
                            <input name="mostrar" type="button" class="botoes" id="mostrar" value="Mostrar" onClick="javascript:tryRequestToServer(function(){mostrar();});">
                        </div>
                    </td>
                </tr>
            </table>
            <br>
            <table width="97%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td class="tabela"></td>
                    <td class="tabela">&nbsp;</td>
                    <td class="tabela">&nbsp;</td>
                    <td colspan="3" class="tabela">Frete Rodovi&aacute;rio, Mar&iacute;timo, Fluvial</td>
                    <td colspan="2" class="tabela">Frete A&eacute;reo</td>
                    <td class="tabela">&nbsp;</td>
                    <td class="tabela">&nbsp;</td>
                </tr>
                <tr>
                    <td class="tabela" align="left" width="1%">
                        <input type="hidden" name="max" id="max" value="0"/>
                        <img onclick="addAliquotas()" alt="addCampo" src="img/novo.gif" class="imagemLink"/>
                    </td>
                    <td width="12%" class="tabela">UF Origem</td>
                    <td width="12%" class="tabela">UF Destino</td>
                    <td width="7%" class="tabela">Al&iacute;q. c/ IE</td>
                    <td width="7%" class="tabela">Al&iacute;q. s/ IE</td>
                    <td width="7%" class="tabela">Redu&ccedil;&atilde;o ICMS</td>
                    <td width="7%" class="tabela">Al&iacute;q. c/ IE</td>
                    <td width="7%" class="tabela">Al&iacute;q s/ IE</td>
                    <td width="20%" class="tabela">Observa&ccedil;&atilde;o para lan&ccedil;amentos</td>
                    <td width="24%" class="tabela">Cidade Destino</td>
                </tr>
                    <tbody id="aliquota"></tbody>
                <tr>
                    <c:if test="${param.nivel >= param.bloq}">
                        <tr class="CelulaZebra2">
                            <td colspan="10">
                                <center>
                                    <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva();});">
                                </center>
                            </td>
                        </tr>
                    </c:if>
                </tr>
            </table>
            <br>
        </form>
    </body>
</html>