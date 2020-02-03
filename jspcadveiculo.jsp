<%@page import="conhecimento.manifesto.gerenciandorrisco.TipoComunicacaoRastreamento"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.TipoComunicacaoRastreamentoBO"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.TecnologiaRastreamento"%>
<%@page import="java.util.Collection"%>
<%@page import="conhecimento.manifesto.gerenciandorrisco.TecnologiaRastreamentoBO"%>
<%@page import="br.com.gwsistemas.cfe.ndd.CategoriaVeiculoNdd"%>
<%@page import="br.com.gwsistemas.cfe.ndd.CategoriaVeiculoNddBO"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html" language="java"
         import="nucleo.Apoio,
         java.text.SimpleDateFormat,
         tipo_veiculos.*,
         java.sql.ResultSet,
         br.com.gwsistemas.cfe.pamcard.CategoriaVeiculoDAO,
         veiculo.BeanCadVeiculo" errorPage="" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="javascript" type="text/javascript" src="script/jquery.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluirt
    BeanUsuario autenticado = Apoio.getUsuario(request);
    int nivelUser = (autenticado != null
            ? autenticado.getAcesso("cadveiculo") : 0);
    int alteraveiculo = (autenticado != null
            ? autenticado.getAcesso("alteraveiculo") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((autenticado == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
%>
<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    boolean carregaveiculo = false;
    BeanCadVeiculo cadveiculo = null;
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

    //instrucoes incomuns entre as acoes
    if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {
        //instanciando o bean de cadastro
        cadveiculo = new BeanCadVeiculo();
        cadveiculo.setConexao(autenticado.getConexao());
        cadveiculo.setExecutor(autenticado);
    }

    //executando a acao desejada
    if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
        int idveiculo = Apoio.parseInt(request.getParameter("id"));
        cadveiculo.setIdveiculo(idveiculo);
        //carregando a filial por completo(atributos, permissoes)
        cadveiculo.LoadAllPropertys();
    } else //ele so entra aqui se tiver pelo menos permissao de alterar
    if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
        //populando o JavaBean
        cadveiculo.setPlaca(request.getParameter("pl"));
        cadveiculo.setRenavan(request.getParameter("ren"));        
        cadveiculo.setModelo(request.getParameter("mod")!=null && request.getParameter("mod").length()>30 ? request.getParameter("mod").substring(0, 29): request.getParameter("mod"));
        cadveiculo.setCor(Apoio.parseInt(request.getParameter("cor")));
        cadveiculo.setChassi(request.getParameter("chs"));
        cadveiculo.setAno(request.getParameter("ano"));
        cadveiculo.setAnomodelo(request.getParameter("anomodelo"));
        cadveiculo.getCidade().setDescricaoCidade(request.getParameter("cidade"));
        cadveiculo.getCidade().setUf(request.getParameter("uf"));
        cadveiculo.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idcidade")));
        cadveiculo.setIdproprietario(Apoio.parseInt(request.getParameter("idprop")));
        cadveiculo.getAlienado().setIdfornecedor(Apoio.parseInt(request.getParameter("idalienado")));
        cadveiculo.setIdmarca(Apoio.parseInt(request.getParameter("idma")));
        cadveiculo.getTipo_veiculo().setId(Apoio.parseInt(request.getParameter("tip")));
        cadveiculo.setTipoFrota(request.getParameter("tipofrota"));
        cadveiculo.setNumeroFrota(request.getParameter("numeroFrota"));
        cadveiculo.setCapacidadeCarga(Apoio.parseInt(request.getParameter("capacidadeCarga")));
        cadveiculo.setQtdPallets(Apoio.parseInt(request.getParameter("qtdPallets")));
        cadveiculo.setNumeroRastreador(request.getParameter("numero_rastreador"));
        cadveiculo.getMarcaRastreador().setIdmarca(Apoio.parseInt(request.getParameter("idma_rastreador")));
        cadveiculo.setCategoriaVeiculo(request.getParameter("categoria"));
        cadveiculo.setNomeEmbarcacao(request.getParameter("nomeEmbarcacao"));
        cadveiculo.setTelefoneEmbarcacao(request.getParameter("telefoneEmbarcacao"));
        cadveiculo.setQuantidadeTripulantes(Apoio.parseInt(request.getParameter("quantidadeTripulantes")));
        cadveiculo.setQuantidadeCestos(Apoio.parseInt(request.getParameter("quantidadeCestos")));
        cadveiculo.setTaraVeiculo(Apoio.parseDouble(request.getParameter("taraVeiculo")));
        cadveiculo.setCubagemVeiculo(Apoio.parseDouble(request.getParameter("cubagemVeiculo")));
        cadveiculo.getCategoriaPamcard().setId(Apoio.parseInt(request.getParameter("categoriaPamcard")));
        cadveiculo.getCategoriaNdd().setId(Apoio.parseInt(request.getParameter("categoriaNdd")));
        cadveiculo.getProprietario_original().setIdfornecedor(Apoio.parseInt(request.getParameter("idPropOriginal")));
        cadveiculo.getProprietario_original().setRazaosocial(request.getParameter("propOriginal"));
        cadveiculo.setTipo_proprietario(request.getParameter("tipoProp"));
        cadveiculo.setAltura_carroceria(Apoio.parseDouble(request.getParameter("altura_carroceria")));
        cadveiculo.setComprimento_carroceria(Apoio.parseDouble(request.getParameter("comprimento_carroceria")));
        cadveiculo.setLargura_carroceria(Apoio.parseDouble(request.getParameter("largura_carroceria")));
        cadveiculo.setIrin(request.getParameter("irin"));
        cadveiculo.getAlocadoCliente().setIdcliente(Apoio.parseInt(request.getParameter("alocadoCliente")));
        //tecnologiaRastreamento tipoComunicacao  numeroEquipamento
        
        cadveiculo.getTecnologiaRastreamento().setId(Apoio.parseInt(request.getParameter("tecnologiaRastreamento")));
        cadveiculo.getTipoComunicacaoRastreamento().setId(Apoio.parseInt(request.getParameter("tipoComunicacao")));
        cadveiculo.setNumeroEquipamento(request.getParameter("numeroEquipamento"));
        cadveiculo.setVeiculoBloqueado(Apoio.parseBoolean(request.getParameter("isBloqueado")));
        cadveiculo.setMotivoBloqueio(request.getParameter("motivoBloqueio"));

        if (acao.equals("atualizar")) {
            cadveiculo.setIdveiculo(Apoio.parseInt(request.getParameter("id")));
        }
        //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
        //3º teste de erro naquela acao executada.
        boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                ? cadveiculo.Inclui() : cadveiculo.Atualiza());

        //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type="">
    
    <%
    if (erro) {
        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadveiculo.getErros())%>');<%
        cadveiculo.setNomeproprietario(request.getParameter("nomeprop"));
        cadveiculo.setDescmarca(request.getParameter("descmarca"));
    } else {%>
    location.replace("ConsultaControlador?codTela=56");
    <%}%>
</script>

<%}
    //variavel usada para saber se o usuario esta editando
    carregaveiculo = ((cadveiculo != null) && (cadveiculo.getNomeproprietario() != null)
            && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">
    function atribuicombos(){
    <%if (carregaveiculo) {%>
            document.getElementById("categoria").value = "<%=cadveiculo.getCategoriaVeiculo()%>";
            document.getElementById("cor").value = "<%=cadveiculo.getCor()%>";
            document.getElementById("tipofrota").value = "<%=cadveiculo.getTipoFrota()%>";
            document.getElementById("tipoProp").value = "<%=cadveiculo.getTipo_proprietario()%>";
            document.getElementById("irin").value = "<%=cadveiculo.getIrin() %>";
            document.getElementById("idconsignatario").value = "<%=cadveiculo.getAlocadoCliente().getId() %>";
            document.getElementById("con_rzs").value = "<%=cadveiculo.getAlocadoCliente().getRazaosocial() %>";
            
            document.getElementById("tecnologiaRastreamento").value = "<%=cadveiculo.getTecnologiaRastreamento().getId()%>";
            document.getElementById("tecnologiaRastreamento").onchange();
            document.getElementById("tipoComunicacao").value = "<%=cadveiculo.getTipoComunicacaoRastreamento().getId()%>";
            document.getElementById("numeroEquipamento").value = "<%=(cadveiculo.getNumeroEquipamento()==null? "" : cadveiculo.getNumeroEquipamento())%>";
         //   getTipoComunicacaoRastreamento();
            
    <%}%>
            alteraCategoria();
            alteraProprietario();
        }
        
    jQuery.noConflict();
        
     var arAbasGenerico = new Array();
     arAbasGenerico[0] = new stAba('tdPrincipal','divInformacoes');
     arAbasGenerico[1] = new stAba('tdGerenciador','divGerenciador');
     <% if (acao.equals("editar") || acao.equals("atualizar")) { %>               
        arAbasGenerico[2] = new stAba('tdAbaAuditoria','divAuditoria');
     <%}%>
        
        function voltar(){
            document.location.replace("ConsultaControlador?codTela=56");
        }

        function salva(acao){
            //essa variavel só foi feita para validar a cidade e não ter que mudar na estrutura da função
            if($("idcidade").value == '0'){
                alert("Informe a cidade corretamente!");
                return null;
            }
            if($("nome_prop").value == ""){
                alert("Informe o proprietário corretamente!");
                return null;
            }
            if($("marca").value == ""){
                alert("Informe a marca corretamente!");
                return null;
            }
            if($("isBloqueado").checked && ($("motivoBloqueio").value == "" || $("motivoBloqueio").value == null)){
                alert("Informe o motivo de Bloqueio do Veículo!");
                return null;
            }

            if (!wasNull('pl,idmarca_veiculo,idprop')){
                if((acao == "incluir") && ('<%= alteraveiculo %>' < 3) && ($("tipofrota").value == "pr")){
                    alert("Não tem permissão para incluir um veiculo frota propria.");
                    return null;
                }
                if((acao == "atualizar") && ('<%= alteraveiculo %>' < 2) && ($("tipofrota").value == "pr" )){
                    alert("Não tem permissão para alterar um veiculo frota propria.");
                    return null;
                }
                
                document.getElementById("salvar").disabled = true;
                document.getElementById("salvar").value = "Enviando...";
                
                
                if (acao == "atualizar"){
                    acao += "&id=<%=(carregaveiculo ? cadveiculo.getIdveiculo() : 0)%>";
                }
                document.location.replace("./cadveiculo?acao="+acao+
                    "&pl="+$("pl").value+
                    "&ren="+$("ren").value+
                    "&mod="+$("mod").value+
                    "&cor="+$("cor").value+
                    "&chs="+$("chs").value+
                    "&ano="+$("ano").value+
                    "&anomodelo="+$("anomodelo").value+
                    "&uf="+$("uf_proprietario").value+
                    "&cidade="+$("cidade_proprietario").value+
                    "&idcidade="+$("idcidade").value+
                    "&idprop="+$("idprop").value+
                    "&propOriginal="+$("propOriginal").value+
                    "&idPropOriginal="+$("idPropOriginal").value+
                    "&tipoProp="+$("tipoProp").value+
                    "&idalienado="+$("idalienado").value+
                    "&idma="+$("idmarca_veiculo").value+
                    "&idma_rastreador="+$("idmarca_rastreador").value+
                    "&numero_rastreador="+$("numero_rastreador").value+
                    "&tip="+$("tip").value+
                    "&tipofrota="+$("tipofrota").value+
                    "&capacidadeCarga="+$("capacidadeCarga").value+
                    "&quantidadeCestos="+$("qtdCestos").value+
                    "&taraVeiculo="+$("taraVeiculo").value+
                    "&cubagemVeiculo="+$("cubagemVeiculo").value+
                    "&numeroFrota="+$("numeroFrota").value+
                    "&nomeprop="+$("nome").value+
                    "&qtdPallets="+$("qtdPallets").value+
                    "&descmarca="+$("descricao").value+
                    "&categoria="+$("categoria").value+
                    "&nomeEmbarcacao="+$("nomeEmbarcacao").value+
                    "&telefoneEmbarcacao="+$("telefoneEmbarcacao").value+
                    "&quantidadeTripulantes="+$("quantidadeTripulantes").value+
                    "&categoriaNdd="+$("categoriaNdd").value+
                    "&categoriaPamcard="+$("categoriaPamcard").value +
                    "&altura_carroceria="+$("altura_carroceria").value +
                    "&comprimento_carroceria="+$("comprimento_carroceria").value +
                    "&largura_carroceria="+$("largura_carroceria").value +
                    "&irin="+$("irin").value+
                    "&alocadoCliente="+$("idconsignatario").value+
                    "&tecnologiaRastreamento="+$("tecnologiaRastreamento").value+
                    "&tipoComunicacao="+$("tipoComunicacao").value+
                    "&numeroEquipamento="+$("numeroEquipamento").value+
                    "&isBloqueado="+($("isBloqueado").checked ? true : false )+
                    "&motivoBloqueio="+$("motivoBloqueio").value
                    )
                }else{
                alert("Preencha os campos corretamente!");
            }
        }

        function excluir(id){
        if(('<%= alteraveiculo %>' < 4)&& (<%= (carregaveiculo ? cadveiculo.getTipoFrota().equals("pr"):true) %>)){
            alert("sem permissão para excluir um veiculo de frota propria.");
        }else{
            if (confirm("Deseja mesmo excluir este veículo?")){
                location.replace("./consultaveiculo?acao=excluir&id="+id);
                }
            }
        }

        function localizaprop(tipo){
            if (tipo=='p'){
                post_cad = window.open('./localiza?acao=consultar&idlista=1','proprietario',
                'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
            }else if(tipo=='po'){
                post_cad = window.open('./localiza?acao=consultar&idlista=1','proprietario_original',
                'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
            }else{
                post_cad = window.open('./localiza?acao=consultar&idlista=1','alienado',
                'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
            }
        
        }

        function localizamarca(rotulo){
            post_cad = window.open('./localiza?acao=consultar&idlista=0',rotulo,
            'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
        }

        function verProp(tipo){
            if (tipo == 'p'){
                if ($('idprop').value == '')
                    alert('Escolha um proprietário corretamente.');
                else
                    window.open('./cadproprietario?acao=editar&id=' + $('idprop').value + '&ex=0' ,'Proprietario','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }else if(tipo == 'a'){
                
                if ($('idalienado').value == '')
                    alert('Escolha um alienado corretamente.');
                else
                    window.open('./cadproprietario?acao=editar&id=' + $('idalienado').value + '&ex=0' ,'Proprietario','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }else if(tipo == 'po'){
                
                if ($('idPropOriginal').value == '')
                    alert('Escolha um Proprietario original corretamente.');
                else
                    window.open('./cadproprietario?acao=editar&id=' + $('idPropOriginal').value + '&ex=0' ,'Proprietario','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
            }
        }

        function aoClicarNoLocaliza(idjanela){
            //localizando cidade
            if (idjanela=="marca"){
                $('idmarca_veiculo').value = $('idmarca').value;
                $('marca').value = $('descricao').value;
            }else if(idjanela=="marca_rastreador"){
                $('idmarca_rastreador').value = $('idmarca').value;
                $('marca_rastreador').value = $('descricao').value;
            }else if(idjanela=="proprietario"){
                $('idprop').value = $('idproprietario').value;
                $('nome_prop').value = $('nome').value;
            }else if(idjanela=="alienado"){
                $('idalienado').value = $('idproprietario').value;
                $('alienado').value = $('nome').value;
            }else if(idjanela=="Cidade"){
                $('idcidade').value = $('idcidadeorigem').value;                
                $('cidade_proprietario').value = $('cid_origem').value;
                $('uf_proprietario').value = $('uf_origem').value;
            }
            else if(idjanela=="proprietario_original"){
                $('idPropOriginal').value = $('idproprietario').value;
                $('propOriginal').value = $('nome').value;
            }
        }

        function alteraCategoria(){
            if ($('categoria').value == 'aq'){
                $('lbIrin').innerHTML = "IRIN:";
                $('irin').style.display = ""; 
                $('lbPlaca').innerHTML = "*Abreviatura:";
                $('lbRenavan').innerHTML = "Nº inscrição:";
                $('lbChassi').innerHTML = "TIE:";
                $('lbMarca').innerHTML = "*Construtor:";
                $('lbPallets').innerHTML = "";
                $('qtdPallets').style.display = "none";
                $('trRastreador').style.display = "none";
                $('lbNomeEmbarcacao').innerHTML = "Nome embarcação:";
                $('nomeEmbarcacao').style.display = "";
                $('trAquatico').style.display = "";
                $('lbCestos').innerHTML = "";
                $('qtdCestos').style.display = "none";
                $('con_rzs').style.display = "";
                $('lbAlocadoCliente').innerHTML = "Alocado no cliente:";
                $('trTamanhoBauTitle').style.display = "none";
                $('trTamanhoBau').style.display = "none";
            }else{
                $('lbIrin').innerHTML = "";
                $('irin').style.display = "none";
                $('lbPlaca').innerHTML = "*Placa:";
                $('lbRenavan').innerHTML = "Renavan:";
                $('lbChassi').innerHTML = "Chassi:";
                $('lbMarca').innerHTML = "*Marca:";
                $('lbPallets').innerHTML = "Qtd. Pallets:";
                $('qtdPallets').style.display = "";
                $('trRastreador').style.display = "";
                $('lbNomeEmbarcacao').innerHTML = "";
                $('nomeEmbarcacao').style.display = "none";
                $('trAquatico').style.display = "none";
                $('lbCestos').innerHTML = "Qtd. Cestos:";
                $('qtdCestos').style.display = "";
                $('lbAlocadoCliente').innerHTML = "Alocado no cliente:";
                $('con_rzs').style.display = "";
                $('trTamanhoBauTitle').style.display = "";
                $('trTamanhoBau').style.display = "";
               
            }
        }

        function alteraProprietario(){
            if($('tipoProp').value == 'A'){
              
                $('tipoProprietario').style.display = "";
                    
            }else{
                $('tipoProprietario').style.display = "none";
            }
        }
        
        function limparCliente(){
            $("idconsignatario").value = "0";
            $("con_rzs").value = "";
        }
        function pesquisarAuditoria() {  
        if(countLog!=null  && countLog!=undefined ){
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }}
                countLog = 0;
                var rotina = "veiculo";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=(carregaveiculo ? cadveiculo.getIdveiculo() : 0)%>;
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
    
        function setDataAuditoria(){
            $("dataDeAuditoria").value="<%=carregaveiculo ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregaveiculo ? Apoio.getDataAtual() : "" %>" ;   

        }
        
        function AlternarAbasGenerico(menu, conteudo) {
            try {
                if (arAbasGenerico != null) {
                    for (i = 0; i < arAbasGenerico.length; i++) {
                        if (arAbasGenerico[i] != null && arAbasGenerico[i] != undefined) {
                            m = document.getElementById(arAbasGenerico[i].menu);
                            m.className = 'menu';
                            for (var j = 0, max = arAbasGenerico[i].conteudo.split(",").length; j < max; j++) {
                                c = document.getElementById(arAbasGenerico[i].conteudo.split(",")[j]);
                                if (c != null) {
                                    invisivel(c, false);
                                } else if ($(arAbasGenerico[i].conteudo.split(",")[j].replace("div", "tr")) != null) {
                                    invisivel($(arAbasGenerico[i].conteudo.split(",")[j].replace("div", "tr")), false);
                                }
                            }
                        }
                    }
                    m = document.getElementById(menu);
                    m.className = 'menu-sel';
                    for (var i = 0, max = conteudo.split(",").length; i < max; i++) {
                        c = document.getElementById(conteudo.split(",")[i]);
                        if (c != null) {
                            visivel(c, false);
                        } else if ($(conteudo.split(",")[i].replace("div", "tr")) != null) {
                            visivel($(conteudo.split(",")[i].replace("div", "tr")), false);
                        }
                    }
                } else {
                    alert("Inicialize a variavel arAbasGenerico!");
                }
            } catch (e) {
                alert(e);
            }
        }

        function stAba(menu, conteudo) {
            this.menu = menu;
            this.conteudo = conteudo;
        }


           function getTipoComunicacaoRastreamento() {
              
              
                function e(transport) {
                    var textoresposta = transport.responseText;

                   //se deu algum erro na requisicao...
                    if (textoresposta == "-1") {
                        alert('Houve algum problema ao requistar os percursos, favor tente novamente. ');
                        return false;
                    } else {

                        var tipoComunicacaoRastreamento = jQuery.parseJSON(textoresposta);

                        var slct = $("tipoComunicacao");
                        var valorSelecionada = slct.value;

                        removeOptionSelected("tipoComunicacao");

                        tipoComunicacaoRastreamento.forEach((tipo) => {
                            slct.appendChild(Builder.node('OPTION', {value: tipo.id}, tipo.descricao));
                        });
                        
                        let opcaoEscolhida = jQuery(slct).find('option[value="' + valorSelecionada + '"]');
                        
                        if (opcaoEscolhida.length > 0) {
                            slct.value = valorSelecionada;
                        }
                    }
                }//funcao e()
                tryRequestToServer(function () {
                 var idTecnologia = $("tecnologiaRastreamento").value;
                    new Ajax.Request("TipoComunicaoRastreamentoControlador?acao=tipoComunicacao&idTecnologia=" + idTecnologia, {method: 'post', onSuccess: e, onError: e});
                });
            }

            function calcularMetroCubico(){
                var total = parseFloat($("altura_carroceria").value * $("largura_carroceria").value * $("comprimento_carroceria").value);
                $("cubagemVeiculo").value = roundABNT(total,4);
            }

            function importarEfrete(){
//                var pl = $("pl").value;
//                var nome_prop = $("nome_prop").value;
//                var sl_prop = $("tipoProp").value;
//                
//                
//                if(sl_prop != "P"){
//                    alert("O tipo deve ser Proprietário");
//                    return false;
//                }
//                
//                if(pl == "" || pl.trim() == "f"){
//                    alert("O campo 'Placa' não pode ficar vazio");
//                    return false;
//                }
//                if(nome_prop == "" || nome_prop.trim() == ""){
//                    alert("O campo 'Proprietário' não pode ficar vazio.");
//                    return false;
//                }
//
                //AJAX BUSCANDO O VEICULO NO EFRETE
//                espereEnviar("Aguarde...",true);
//                function e(transport){//
//                    var textoresposta = transport.responseText;

//                    var veiculoObj = jQuery.parseJSON(textoresposta);
//                    var veiculo = veiculoObj.veiculoRetornado;
//                    if(veiculo.statusRetornoEfrete != null && veiculo.statusRetornoEfrete == ""){
//                        $("pl").value = veiculo.placa;
//                        $("chs").value = veiculo.chassi;
//                        $("mod").value = veiculo.modelo;
//                        $("ano").value = veiculo.ano;
//                        $("anomodelo").value = veiculo.anomodelo;
//                        $("capacidadeCarga").value = veiculo.capacidadeCarga;
//                        $("ren").value = veiculo.renavan;
//                        $("taraVeiculo").value = veiculo.taraVeiculo;
//                        $("cor").selectedIndex = veiculo.cor;
//                        $("cubagemVeiculo").value = veiculo.cubagemVeiculo;
//                        $("idmarca").value = veiculo.idmarca;
//                        $("idmarca_veiculo").value = veiculo.idmarca;
//                        $("marca").value = veiculo.descmarca;
//                        $("idmarca_veiculo").value = veiculo.idmarca;
//                        alert("Veículo importado com sucesso!");
//                    }else{
//                        alert(veiculo.statusRetornoEfrete);
//                    }


//                    espereEnviar("Aguarde...",false);

//                }
//                tryRequestToServer(function(){//
//                    new Ajax.Request('EFreteControlador?acao=carregarVeiculoEFrete&placa='+pl+'&proprietario='+nome_prop,{method:'post', onSuccess: e, onError: e});
//                });
                alert("ATENÇÃO! Na versão de integração 5.0 a opção de importar dados dos veículos foi descontinuada pela E-Frete.");
            }

            function abrirMotivoBloq(){
                if($("isBloqueado").checked){
                    $("lblMotivoBloqueio").style.display = "";
                    $("motivoBloqueio").style.display = "";
                }else{
                    $("lblMotivoBloqueio").style.display = "none";
                    $("motivoBloqueio").style.display = "none";
                }
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
        <META HTTP-EQUIV="Page-Enter" CONTENT = "RevealTrans (Duration=1, Transition=12)">

        <title>WebTrans - Cadastro de Ve&iacute;culos</title>
        <link href="./estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onLoad="javascript:atribuicombos();document.getElementById('pl').focus();setDataAuditoria();AlternarAbasGenerico('tdPrincipal','divInformacoes');/*calcularMetroCubico();*/abrirMotivoBloq();">
        <img src="img/banner.gif" >
        <br>
        <table width="80%" align="center" class="bordaFina" >
            <tr>
                <td width="613">
                    <div align="left">
                        <b>Cadastro de Ve&iacute;culo</b>
                    </div>
                </td>
                <%if(acao.equals("iniciar") && Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
                    <td width="10%">
                        <div align="right">
                            <input name="importarEFrete" type="button" name="importarEFrete" value="Importar E-Frete" class="botoes" onclick="javascript:importarEfrete();"/>
                        </div>
                    </td>
                    <%}%>
                <% if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) //se o paramentro vier com valor entao nao pode excluir
                    {%>
                <td width="15">
                    <input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:excluir(<%=(carregaveiculo ? cadveiculo.getIdveiculo() : 0)%>)">
                </td>
                <%}%>
                <td width="56" >
                    <input  name="voltar" type="button" class="botoes" id="voltar" onClick="javascript:voltar();" value="Consulta" alt="Volta para o menu principal">
                </td>
            </tr>
        </table>
        <br>
        <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela"> 
                <td colspan="8" align="center">Dados principais </td>
            </tr>
            <tr>
                <td class="TextoCampos">Categoria:</td>
                <td class="CelulaZebra2" width="20%">
                    <select name="categoria" id="categoria" style="font-size:8pt;" onChange="alteraCategoria();" class="inputtexto">
                        <option value="te" selected>Ve&iacute;culo Terrestre</option>
                        <option value="aq">Ve&iacute;culo Aqu&aacute;tico</option>
                    </select>
                </td>
                <td class="CelulaZebra2" width="10%">&nbsp;</td>
                <td class="TextoCampos" width="20%">
                    <label id="lbNomeEmbarcacao" name="lbNomeEmbarcacao">Nome embarca&ccedil;&atilde;o:</label>
                </td>
                <td colspan="3" class="CelulaZebra2">
                    <input name="nomeEmbarcacao" type="text" id="nomeEmbarcacao" size="20" maxlength="20" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getNomeEmbarcacao() : "")%>" class="inputtexto">
                </td>
                <td class="CelulaZebra2"></td>
            </tr>
            <tr>
                <td class="TextoCampos">
                    <label id="lbPlaca" name="lbPlaca">*Placa:</label>
                </td>
                <td class="CelulaZebra2">
                    <input name="pl" type="text" id="pl" size="8" maxlength="8" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getPlaca() : "")%>" class="inputtexto">
                </td>

                <td class="TextoCampos">Frota N&ordm;: </td>
                <td colspan="5" class="CelulaZebra2">
                    <input name="numeroFrota" type="text" id="numeroFrota" size="8" maxlength="10" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getNumeroFrota() : "")%>" class="inputtexto">
                </td>
            </tr>
            <tr> 
                <!-- FANTASMAS -->
            <input name="idproprietario" id="idproprietario" type="hidden" value="0">
            <input name="idPropOriginal" id="idPropOriginal" type="hidden" value="<%=(carregaveiculo ? String.valueOf(cadveiculo.getProprietario_original().getIdfornecedor()) : "")%>">

            <input name="idprop" id="idprop" type="hidden" value="<%=(carregaveiculo ? String.valueOf(cadveiculo.getIdproprietario()) : "")%>">
            <input name="idalienado" id="idalienado" type="hidden" value="<%=(carregaveiculo ? cadveiculo.getAlienado().getIdfornecedor() : "")%>">
            <input name="idmarca" id="idmarca" type="hidden" value="0">
            <input name="idmarca_veiculo" id="idmarca_veiculo" type="hidden" value="<%=(carregaveiculo ? String.valueOf(cadveiculo.getIdmarca()) : "")%>">
            <input name="idmarca_rastreador" id="idmarca_rastreador" type="hidden" value="<%=(carregaveiculo ? String.valueOf(cadveiculo.getMarcaRastreador().getIdmarca()) : "0")%>">
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
            <input type="hidden" name="idcidade" id="idcidade" value="<%=(carregaveiculo ? String.valueOf(cadveiculo.getCidade().getIdcidade()) : "0")%>">
            <input type="hidden" name="cid_origem" id="cid_origem" value="">
            <input type="hidden" name="uf_origem" id="uf_origem" value="">
            <!-- FIM -->
            <td width="83" class="TextoCampos">
                <label id="lbRenavan" name="lbRenavan">Renavan:</label>
            </td>
            <td width="120" class="CelulaZebra2">
                <input name="ren" type="text" id="ren" size="20" maxlength="20" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getRenavan() : "")%>" class="inputtexto">
            </td>
            <td width="78" class="TextoCampos">Modelo:</td>
            <td width="127" class="CelulaZebra2"> 
                <input name="mod" type="text" id="mod" size="20" maxlength="30" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getModelo() : "")%>" class="inputtexto">
            </td>
            <td width="10%" class="TextoCampos" colspan="3">Ano Mod/Fab: </td>
            <td width="105" class="CelulaZebra2">
                <input name="anomodelo" type="text" id="anomodelo" size="3" maxlength="7" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getAnomodelo() : "")%>" class="inputtexto">
                /
                <input name="ano" type="text" id="ano" size="3" maxlength="7" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getAno() : "")%>" class="inputtexto">
            </td>
        </tr>
        <tr> 
            <td class="TextoCampos">
                <label id="lbChassi" name="lbChassi">Chassi:</label>
            </td>
            <td class="CelulaZebra2">
                <input name="chs" type="text" id="chs" size="20" maxlength="30" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getChassi() : "")%>" class="inputtexto">
            </td>
            <td class="TextoCampos">
                <label id="lbMarca" name="lbMarca">*Marca:</label>
            </td>
            <td colspan="5" class="CelulaZebra2">
                <input type="hidden" value="" name="descricao"  id="descricao">
                <input name="marca" type="text" id="marca" size="25" maxlength="25" readonly value="<%=(carregaveiculo ? cadveiculo.getDescmarca() : "")%>" class="inputReadOnly8pt">
                <input  name="localiza_marca" type="button" class="botoes" id="localiza_marca2" onClick="javascript:localizamarca('marca');" value="...">
            </td>
        </tr>
       
        <tr> 
            <td width="11%" class="TextoCampos">
                <select   name="tipoProp" class="inputtexto" id="tipoProp" onchange="alteraProprietario();" >
                    <option value="P">Proprietário</option>
                    <option value="A">Arrendatário</option>
                </select>
            </td>
            <td colspan="3" class="CelulaZebra2">
                <input name="nome_prop" type="text" readonly id="nome_prop" value="<%=(carregaveiculo ? cadveiculo.getNomeproprietario() : "")%>" size="40" maxlength="50" class="inputReadOnly8pt">
                <input  name="localiza_proprietario" type="button" class="botoes" id="localiza_proprietario" onClick="javascript:localizaprop('p')" value="...">
                <img src="img/page_edit.png" border="0" onClick="javascript:verProp('p');"
                     title="Ver Cadastro" style="vertical-align:middle " class="imagemLink">
                <input name="nome" type="hidden" id="nome" value="<%=(carregaveiculo ? cadveiculo.getNomeproprietario() : "")%>"> 
            </td>
            <td class="TextoCampos">
                <span class="TextoCampos">*Tipo:</span>
            </td>
            <td class="CelulaZebra2" colspan="3">
                <select name="tip" id="tip" style="font-size:8pt;" class="inputtexto">
                    <%ConsultaTipo_veiculos tipo = new ConsultaTipo_veiculos();
                        tipo.setConexao(Apoio.getUsuario(request).getConexao());
                        //alteracao referente a historia 3231
                        tipo.mostraTipos(false, (carregaveiculo ? cadveiculo.getTipo_veiculo().getId() : 0));
                        ResultSet rs = tipo.getResultado();
                        while (rs.next()) {%>
                    <option value="<%=rs.getString("id")%>" style="background-color:#FFFFFF" <%=(carregaveiculo && rs.getInt("id") == cadveiculo.getTipo_veiculo().getId() ? "Selected" : "")%>><%=rs.getString("descricao")%></option>
                    <%}%>
                </select>
            </td>
        </tr>

        <tr display="" id="tipoProprietario">
            <td class="TextoCampos" colspan="1">
                <label id="lbTipoProp">
                    Proprietário:
                </label>
            </td>                         

            <td colspan="5" class="CelulaZebra2">

                <input name="propOriginal" type="text" readonly id="propOriginal" value="<%=(carregaveiculo ? cadveiculo.getProprietario_original().getRazaosocial() : "")%>" size="40" maxlength="50" class="inputReadOnly8pt">
                <input  name="localiza_proprietario1" type="button" class="botoes" id="localiza_proprietario1" onClick="javascript:localizaprop('po')" value="...">
                <img src="img/page_edit.png" border="0" onClick="javascript:verProp('po');"
                     title="Ver Cadastro" style="vertical-align:middle " class="imagemLink">
                
            </td>

            <td class="CelulaZebra2">
            </td>
            <td class="CelulaZebra2">
            </td>
        </tr>


        <tr>
            <td class="TextoCampos">Alienado &agrave;:</td>
            <td colspan="5" class="CelulaZebra2">
                <input name="alienado" type="text" readonly id="alienado" value="<%=(carregaveiculo ? cadveiculo.getAlienado().getRazaosocial() : "")%>" size="40" maxlength="50" class="inputReadOnly8pt">
                <input  name="localiza_proprietario2" type="button" class="botoes" id="localiza_proprietario2" onClick="javascript:localizaprop('a')" value="...">
                <strong>
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar marca do rastreador" onClick="javascript:$('idalienado').value = '';javascript:$('alienado').value = '';">
                </strong>
                <img src="img/page_edit.png" border="0" onClick="javascript:verProp('a');"
                     title="Ver Cadastro" style="vertical-align:middle " class="imagemLink">
            </td>
            <td class="CelulaZebra2" colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td class="TextoCampos">*Cidade:</td>
            <td colspan="3" class="CelulaZebra2">
                <input name="cidade_proprietario" type="text" id="cidade_proprietario" size="33" maxlength="35"  value="<%=(carregaveiculo ? cadveiculo.getCidade().getDescricaoCidade() : "")%>" class="inputReadOnly8pt">
                <input type="text" name="uf_proprietario" id="uf_proprietario"  class="inputReadOnly8pt" size="2" value="<%=(carregaveiculo ? cadveiculo.getCidade().getUf() : "")%>">
                <input name="localiza_cidade" type="button" class="botoes" id="localiza_cidade" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=11','Cidade','top=80,left=150,height=700,width=800,resizable=yes,status=1,scrollbars=1');">
            </td>
            <td class="TextoCampos">Cor:</td>
            <td class="CelulaZebra2" colspan="3">
                <select name="cor" id="cor" class="inputtexto">
                    <option value="0" selected>N&atilde;o Informado</option>
                    <option value="1">BRANCA</option>
                    <option value="2">AMARELA</option>
                    <option value="3">AZUL</option>
                    <option value="4">VERDE</option>
                    <option value="5">VERMELHA</option>
                    <option value="6">LARANJA</option>
                    <option value="7">PRETA</option>
                    <option value="8">PRATA</option>
                    <option value="9">CINZA</option>
                    <option value="10">BEGE</option>
                    <option value="11">ROXO</option>
                    <option value="12">VINHO</option>
                    <option value="13">GREN&Aacute;</option>
                    <option value="14">MARROM</option>
                    <option value="15">ROSA</option>
                    <option value="16">FANTASIA</option>
                    <option value="17">DOURADA</option>
                </select>
            </td>
        </tr>
        <tr> 
            <td class="TextoCampos">Tipo de frota:</td>
            <td class="CelulaZebra2" colspan="7">
                <select name="tipofrota" id="tipofrota" class="inputtexto">
                    <option value="ag" selected>Agregada</option>
                    <option value="pr">Frota Pr&oacute;pria</option>
                    <option value="ca">Carreteiro</option>
                </select>
            </td>
        </tr>
   <tr id="trAquatico" name="trAquatico">
            <td class="TextoCampos" > 
                <label id="lbIrin" name="lbIrin">IRIN:</label>
            </td>     
            <td class="CelulaZebra2">    
                <input type="text" name="irin" id="irin" size="8" maxlength="10" style="font-size:8pt;" class="inputtexto" <%=(carregaveiculo ? cadveiculo.getIrin() : "") %>>
            </td>
            <td class="TextoCampos">Nº Telefone:</td>
            <td class="CelulaZebra2">
                <input name="telefoneEmbarcacao" type="text" id="telefoneEmbarcacao" size="20" maxlength="20" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getTelefoneEmbarcacao() : "")%>" class="inputtexto">
            </td>
            <td class="TextoCampos" colspan="2">QTD de Tripulantes:</td>
            <td class="CelulaZebra2" colspan="2">
                <input name="quantidadeTripulantes" type="text" id="quantidadeTripulantes" onChange="seNaoIntReset(this,'0');"
                       value="<%=(carregaveiculo ? cadveiculo.getQuantidadeTripulantes() : "0")%>" size="8" maxlength="4" class="inputtexto">
            </td>
        </tr>
    </table>  
             <table width="80%" align="center" cellpadding="2" cellspacing="1">
                    <tr>
                        <td width="100%">
                          <table align="left">
                               <tr>
                                  <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal','divInformacoes')"> Informações Operacionais</td>
                                  <td id="tdGerenciador" class="menu" onclick="AlternarAbasGenerico('tdGerenciador','divGerenciador')"> Gerenciador de Risco </td>
                                      <% if (acao.equals("editar") || acao.equals("atualizar")) { %>                 
                                  <td id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria','divAuditoria')"> Auditoria</td>
                                    <% } %> 
                                    
                               </tr>
                            </table>
                        </td> 
                    </tr>
               </table>     
    <div id="divInformacoes" >                              
      <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
        <tr>
            <td class="TextoCampos">Cap. carga:</td>
            <td class="CelulaZebra2">
                <input name="capacidadeCarga" type="text" id="capacidadeCarga" size="8" maxlength="15" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getCapacidadeCarga() : 0)%>" onChange="seNaoIntReset(this,'0');" class="inputtexto">
                Kg
            </td>
            <td class="TextoCampos">Tara:</td>
            <td class="CelulaZebra2" colspan="5">
                <input name="taraVeiculo" type="text" id="taraVeiculo" size="8" maxlength="15" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getTaraVeiculo() : 0)%>" onChange="seNaoIntReset(this,'0');" class="inputtexto">
                Kg
            </td>
        </tr>
        <tr name="trRastreador">
            <td class="TextoCampos">
                <label id="lbPallets" name="lbPallets">Qtd. Pallets:</label>
            </td>
            <td class="CelulaZebra2">
                <input name="qtdPallets" type="text" id="qtdPallets" onChange="seNaoIntReset(this,'0');"
                       value="<%=(carregaveiculo ? cadveiculo.getQtdPallets() : "0")%>" size="8" maxlength="4" class="inputtexto">
            </td>
            <td class="TextoCampos">
                <label id="lbCestos" name="lbCestos">Qtd. Cestos:</label>
            </td>
            <td class="CelulaZebra2">
                <input name="qtdCestos" type="text" id="qtdCestos" onChange="seNaoIntReset(this,'0');"
                       value="<%=(carregaveiculo ? cadveiculo.getQuantidadeCestos() : "0")%>" size="8" maxlength="4" style="font-size:8pt;" class="inputtexto">
            </td>
            <td class="TextoCampos">Cubagem:</td>
            <td class="CelulaZebra2" colspan="3">
                <input name="cubagemVeiculo" type="text" id="cubagemVeiculo" onChange="seNaoFloatReset(this,'0');"
                       value="<%=(carregaveiculo ? cadveiculo.getCubagemVeiculo() : "0")%>" size="8" maxlength="8" style="font-size:8pt;" class="inputtexto">
                m&sup3;
            </td>
        </tr>
        <tr name="trRastreador" id="trRastreador"> 
            <td class="TextoCampos">Rastreador:</td>
            <td class="CelulaZebra2">
                <input name="numero_rastreador" type="text" id="numero_rastreador" size="20" maxlength="30" style="font-size:8pt;" value="<%=(carregaveiculo ? cadveiculo.getNumeroRastreador() : "")%>" class="inputtexto">
            </td>
            <td class="TextoCampos">Marca:</td>
            <td colspan="5" class="CelulaZebra2">
                <input name="marca_rastreador" type="text" id="marca_rastreador" size="25" maxlength="25" readonly class="inputReadOnly8pt" value="<%=(carregaveiculo ? cadveiculo.getMarcaRastreador().getDescricao() : "")%>">
                <input  name="localiza_marca2" type="button" class="botoes" id="localiza_marca" onClick="javascript:localizamarca('marca_rastreador');" value="...">
                <strong>
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar marca do rastreador" onClick="javascript:$('idmarca_rastreador').value = '0';javascript:$('marca_rastreador').value = '';">
                </strong>
            </td>
        </tr>
        <tr id="trIsbloqueado" name="trIsbloqueado">
            <td class="CelulaZebra2"></td>
            <td class="CelulaZebra2" style=" text-align: center<% if(nivelUser <= 3 ){%>;display:none;<%}%>"><input style="text-align: center" id="isBloqueado" name="isBloqueado" type="checkbox" <%= carregaveiculo ? cadveiculo.isVeiculoBloqueado() ? "checked" : "" : "" %> onclick="javascript: abrirMotivoBloq();"><label style="text-align: center">Bloquear o Veículo</label></td>
            <td class="TextoCampos"><label id="lblMotivoBloqueio" nome="lblMotivoBloqueio" style="display: none">Motivo do bloqueio</label></td>
            <td class="CelulaZebra2" id="tdMotivoBloqueio" name="tdMotivoBloqueio" align="left" colspan="7">
                <label style="text-align: left">
                    <textarea style="text-align: left; display: none" id="motivoBloqueio" name="motivoBloqueio" maxlength="100" rows="2" cols="50"><%= carregaveiculo && cadveiculo.getMotivoBloqueio() != null ? cadveiculo.getMotivoBloqueio() : ""  %></textarea>
                </label>
            </td>
        </tr>
         <tr class="CelulaZebra2" name="trTamanhoBauTitle" id="trTamanhoBauTitle">
            <td colspan="8" class="tabela">
                <div align="center">Tamanho do baú </div>
            </td>
        </tr>
        <tr name="trTamanhoBau" id="trTamanhoBau">
            <td class="TextoCampos"> Altura 
               
                <input name="altura_carroceria" type="text" id="altura_carroceria" value="<%=(carregaveiculo ? cadveiculo.getAltura_carroceria() : "0.00")%>" size="6" maxlength="4" onchange="seNaoFloatReset(this,'0.00');calcularMetroCubico();" style="font-size:8pt;" class="inputtexto">
                Mt
            </td>
            <td class="TextoCampos">Largura</td>
            
            <td class="CelulaZebra2"> 
                
                <input name="largura_carroceria" type="text" id="largura_carroceria" value="<%=(carregaveiculo ? cadveiculo.getLargura_carroceria() : "0.00")%>" size="6" maxlength="4" onchange="seNaoFloatReset(this,'0.00');calcularMetroCubico()" style="font-size:8pt;" class="inputtexto">
                Mt
            </td>
            <td class="TextoCampos">Compr. </td>
            <td class="CelulaZebra2" width="10%" colspan="2"><input name="comprimento_carroceria" type="text" id="comprimento_carroceria" value="<%=(carregaveiculo ? cadveiculo.getComprimento_carroceria() : "0.00")%>" size="6" maxlength="4" onchange="seNaoFloatReset(this,'0.00');calcularMetroCubico();" style="font-size:8pt;" class="inputtexto">
            Mt
            </td>
            <td class="CelulaZebra2">
                
            </td>
        </tr>
        <tr class="CelulaZebra2">
            <td colspan="8" class="tabela">
                <div align="center">Informa&ccedil;&otilde;es CF-e</div>
            </td>
        </tr>
        <tr>
            <td colspan="8">
                <table width="100%">
                    <tr>
                        <td class="TextoCampos" width="20%">Categoria Pamcard:</td>  
                        <td class="CelulaZebra2" colspan="6" width="80%">
                            <select name="categoriaPamcard" id="categoriaPamcard" class="fieldMin" style="width:350pt;" >
                                <option value="0">Selecione</option> 
                                <%      // Carregando todas as Categorias tipo PAMCARD
                                    CategoriaVeiculoDAO categoria = new CategoriaVeiculoDAO();
                                    ResultSet rsCategorias = categoria.Carregar();
                                    while (rsCategorias.next()) {%>
                                <option value="<%=rsCategorias.getInt("id")%>" <%=(carregaveiculo && rsCategorias.getInt("id") == cadveiculo.getCategoriaPamcard().getId() ? "Selected" : "")%>> <%=rsCategorias.getString("descricao")%></option> 
                                <%}%>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos" width="20%">Categoria NDD/Target:</td>  
                        <td class="CelulaZebra2" colspan="6" width="80%">
                            <select name="categoriaNdd" id="categoriaNdd" class="fieldMin" style="width:350pt;" >
                                <option value="0">Selecione</option> 
                                <%      // Carregando todas as Categorias tipo PAMCARD
                                    CategoriaVeiculoNddBO categoriaNdd = new CategoriaVeiculoNddBO();
                                    for (CategoriaVeiculoNdd categoriaVeiculo : categoriaNdd.listar(autenticado)) {%>
                                <option value="<%=categoriaVeiculo.getId()%>" <%=(carregaveiculo && categoriaVeiculo.getId() == cadveiculo.getCategoriaNdd().getId() ? "Selected" : "")%>> <%=categoriaVeiculo.getDescricao()%></option> 
                                <%}%>
                            </select>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr class="CelulaZebra2">
            <td colspan="8" class="tabela">
                <div align="center">Outras Informações</div>
            </td>
        </tr>
        <tr>
                <td class="TextoCampos">
                    <label id="lbAlocadoCliente" name="lbAlocadoCliente">Alocado no Cliente:</label>
                </td>
                <td class="CelulaZebra2" colspan="7">
                    <input name="idconsignatario" id="idconsignatario" type="hidden" value="0" value="">
                    <input name="con_rzs" id="con_rzs" size="50" class="inputReadOnly8pt" style="font-size: 8pt" value="" class="inputtexto" readonly >
                    <input name="" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=59','Cliente')" value="...">
                    <strong>
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="limparCliente()">
                    </strong>
                </td>
        </tr>
        <tr class="CelulaZebra2" style="<%=autenticado.getFilial().getStUtilizacaoCfeS().equals("E") || autenticado.getFilial().getStUtilizacaoCfeS().equals("G")? "display:" : "display:none"%>">
            <td colspan="8" class="tabela">
                <div align="center">Situação ANTT(CIOT)</div>
            </td>
        </tr>
        <tr style="<%=autenticado.getFilial().getStUtilizacaoCfeS().equals("E") || autenticado.getFilial().getStUtilizacaoCfeS().equals("G")? "display:" : "display:none"%>">
            <td class="TextoCampos" style="width: 10%;"><div align="right">
                <label>Situação: </label></div>
            </td>
            <td class="TextoCampos" style="width: 20%"><div align="left">
                <label><%=(carregaveiculo ? (cadveiculo.getDataHoraConsultaANTT().equals("") ? "" : (!cadveiculo.isSituacaoANTT()) ? "Veículo inapto para transporte": "Veículo apto para transporte" ) : "")%></label></div>
            </td>
            <td class="TextoCampos" style="width: 15%;"><div align="right">
                <label>Data/Hora última consulta:</label></div>
            </td>
            <td class="TextoCampos" style="width: 20%;"><div align="left">
                <label><%=(carregaveiculo ? cadveiculo.getDataHoraConsultaANTT() : "")%></label></div>
            </td>
            <td class="TextoCampos" style="width: 15%;"><div align="right">
                <label>Usuário última consulta: </label></div>
            </td>
            <td class="TextoCampos" style="width: 20%;" colspan="3"><div align="left">
                <label><%=(carregaveiculo && (cadveiculo.getUsuarioConsultaANTT().getNome()!=null)? cadveiculo.getUsuarioConsultaANTT().getNome() : "")%></label></div>
            </td>
        </tr>
         </table>
    </div>                       
       
       
    <div id="divGerenciador" style="display: none">                              
        <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">  
          <tr class="CelulaZebra2">
              <td colspan="6" class="tabela">
                  <div align="center">Informa&ccedil;&otilde;es do Gerenciador de Risco</div>
              </td>
          </tr>
          <tr>
              <td width="20%" class="TextoCampos">
                      Tecnologia de Rastreamento:
              </td>
              <td width="15%" class="TextoCampos">
                  <select id="tecnologiaRastreamento" name="tecnologiaRastreamento" class="fieldMin" style="width:100pt;" onchange="javascript:getTipoComunicacaoRastreamento();">  
                   
                  
                      <option value="0" selected>Selecione</option>
                <%      // Carregando todas as Categorias tipo PAMCARD
                    TecnologiaRastreamentoBO tecnologiaRastreamentoBO = new TecnologiaRastreamentoBO();
                    Collection<TecnologiaRastreamento> tecnologiaRastreamentos = tecnologiaRastreamentoBO.listar();
                    for (TecnologiaRastreamento tecnologiaRastreamento : tecnologiaRastreamentos) {%>
                                <option value="<%=tecnologiaRastreamento.getId()%>" <%=(carregaveiculo && tecnologiaRastreamento.getId() == cadveiculo.getTecnologiaRastreamento().getId() ? "Selected" : "")%>> <%=tecnologiaRastreamento.getCodigo()+"-"+tecnologiaRastreamento.getDescricao()%></option> 
                                <%}%>
                   </select>
              </td>    
              <td width="20%" class="TextoCampos">
                      Tipo Comunicação de Rastreamento:
              </td>
              <td width="15%" class="TextoCampos" >
                    <select id="tipoComunicacao" name="tipoComunicacao" class="fieldMin" style="width:100pt;">
                        <option value="0" selected>Selecione</option>
                        <%      // Carregando todas as Categorias tipo PAMCARD
                    TipoComunicacaoRastreamentoBO tipoComunicacaoRastreamentoBO = new TipoComunicacaoRastreamentoBO();
                    Collection<TipoComunicacaoRastreamento> tipoComunicacaoRastreamentos = tipoComunicacaoRastreamentoBO.mostrarTodos();
                    for (TipoComunicacaoRastreamento tipoComunicacaoRastreamento : tipoComunicacaoRastreamentos) {%>
                        <option value="<%=tipoComunicacaoRastreamento.getId()%>" <%=(carregaveiculo && tipoComunicacaoRastreamento.getId() == cadveiculo.getTecnologiaRastreamento().getId() ? "Selected" : "")%>> <%=tipoComunicacaoRastreamento.getDescricao()%></option> 
                    <%}%>
                    </select>
              </td>    
              <td width="20%" class="TextoCampos">
                      Número Equipamento:
              </td>
              <td width="15%" class="TextoCampos">
                  <input type="text" class="inputtexto" id="numeroEquipamento" name="numeroEquipamento">
              </td>    
          </tr>
        
        
       
         </table>
    </div>        
             
                  
       
    <% if (acao.equals("editar") || acao.equals("atualizar")) { %>  
    <div id="divAuditoria" >  
            <table width="80%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria">
                       <%@include file="gwTrans/template_auditoria.jsp" %>
           
         <tr> 
            <td colspan="7">
                <table width="100%" border="0" class="bordaFina">
                    <tr> 
                        <td width="11%"  class="TextoCampos">Incluso:</td>
                        <td width="38%" class="CelulaZebra2">
                            Em: <%=carregaveiculo && cadveiculo.getDtLancamento() != null ? fmt.format(cadveiculo.getDtLancamento()) : ""%> 
                            <br>
                            Por: <%=carregaveiculo && cadveiculo.getDtLancamento() != null ? cadveiculo.getUsuarioLancamento().getNome() : ""%> 
                        <td width="11%" class="TextoCampos">
                            Alterado: 
                        <td width="40%" class="CelulaZebra2">
                            Em: <%=(carregaveiculo && cadveiculo.getDtAlteracao() != null) ? fmt.format(cadveiculo.getDtAlteracao()) : ""%>
                            <br>
                            Por: <%=(carregaveiculo && cadveiculo.getUsuarioAlteracao().getNome() != null) ? cadveiculo.getUsuarioAlteracao().getNome() : ""%> 
                </table>
            </td>
        </tr>
      
        
                </table>
                     
    </div> 
         <%}%>
                
                <br>
       <table width="80%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
           <tr class="CelulaZebra2"> 
            <td colspan="7"> 
        <center>
            <% if (nivelUser >= 2 && (carregaveiculo && cadveiculo.getTipoFrota().equals("pr") && alteraveiculo < 2 ? false : true)) {%>
            <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
            <%}%>
        </center>
    </td>
</tr>
           
       </table>
</body>
<br>
</html>
