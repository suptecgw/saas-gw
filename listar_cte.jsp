<%-- 
    Document   : listar_cte
    Created on : 26/07/2011, 11:07:08
    Author     : jonasb
--%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="br.com.gwsistemas.gwcte.CTe"%>
<%@page import="conhecimento.BeanCadConhecimento"%>
<%@page import="filial.BeanCadFilial"%>
<%@page import="filial.BeanConsultaFilial"%>
<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.Apoio"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.util.Collection,
         java.util.Date"%>
 
<% 


    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("altnfefilial") : 0);
    request.setAttribute("user", Apoio.getUsuario(request));
    request.setAttribute("versao", Apoio.WEBTRANS_VERSION);

    int nivelCancelarCTRC = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lancancelamentoctrc") : 0);
    
    int nivelOutrasFiliais = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    Collection<CTe> ctes = new ArrayList<CTe>();
    boolean emiteRodoviario = Apoio.getUsuario(request).isEmiteRodoviario();
    boolean emiteAereo = Apoio.getUsuario(request).isEmiteAereo();
    boolean emiteAquaviario = Apoio.getUsuario(request).isEmiteAquaviario();
    int nivelCancelarCTe = Apoio.getUsuario(request).getAcesso("cancelacte");
    
    //permissao do usuario
    boolean emiteConhecimentoCobranca = Apoio.getUsuario(request).isEmiteCteCobranca();
    boolean emiteConhecimentoNormal = Apoio.getUsuario(request).isEmiteCteNormal();
    boolean emiteConhecimentoDiaria = Apoio.getUsuario(request).isEmiteCteDiaria();
    boolean emiteConhecimentoPallet = Apoio.getUsuario(request).isEmiteCtePallet();
    boolean emiteConhecimentoComplementar = Apoio.getUsuario(request).isEmiteCteComplementar();
    boolean emiteConhecimentoReentrega = Apoio.getUsuario(request).isEmiteCteComplementar();
    boolean emiteConhecimentoDevolucao = Apoio.getUsuario(request).isEmiteCteDevolucao();
    boolean emiteConhecimentoCortesia = Apoio.getUsuario(request).isEmiteCteCortesia();
    boolean emiteConhecimentoSubstituicao = Apoio.getUsuario(request).isEmiteCteSubstituicao();
    boolean emiteConhecimentoAnulacao = Apoio.getUsuario(request).isEmiteCteAnulacao();
            
    BeanConsultaFilial consultaFilial = new BeanConsultaFilial();
    //BeanConsultaConhecimento beanconh = null;
    String acao = request.getParameter("acao");
    acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
    String campoConsulta = request.getParameter("campoConsulta");
    String operadorConsulta = (request.getParameter("operadorConsulta") == null ? "1" : request.getParameter("operadorConsulta"));
    String valorConsulta = (request.getParameter("valorConsulta") == null ? "" : request.getParameter("valorConsulta"));
    String valorConsulta2 = request.getParameter("valorConsulta2");
    String limiteResultados = request.getParameter("limiteResultados");
    String statusCte = request.getParameter("statusCte");
    int idFilial = Apoio.parseInt(request.getParameter("filial") != null
            && !request.getParameter("filial").equals("null")
            ? request.getParameter("filial") : "0");
    String dataInicial = request.getParameter("dataInicial");
    String dataFinal = request.getParameter("dataFinal");
    String pag = request.getParameter("pag");
    String qtdResultados = request.getParameter("qtdResultados");
    String paginaAtual = request.getParameter("paginaAtual");
    String ordenacao = (request.getParameter("ordenacao") == null ? "s.numero" : request.getParameter("ordenacao"));
    String tipoOrdenacao = (request.getParameter("tipoOrdenacao") == null ? "s.numero" : request.getParameter("tipoOrdenacao"));
    String tipoTransporte = (request.getParameter("tipoTransporte") == null ? "todos" : request.getParameter("tipoTransporte"));
    
    String tipoConhecimento = (request.getParameter("tipo-conhecimento") == null ? "" : request.getParameter("tipo-conhecimento"));
    
    if (acao.equals("exportar")) {
        String modelo = request.getParameter("modelo");
        String relatorio = "";
        if (modelo.indexOf("personalizado") > -1) {
            relatorio = "dacte_" + modelo;
        } else {
            if(modelo.equals("F")){
                relatorio = "dacte_mod_FS-DA";
            }else{
                relatorio = "dacte_mod" + modelo;
            }
        }
        String idCte = request.getParameter("idCte");

        //Exportando
        java.util.Map param = new java.util.HashMap(20);
        param.put("ID_CTE", idCte);
        param.put("USUARIO", Apoio.getUsuario(request).getNome());

        request.setAttribute("map", param);
        request.setAttribute("rel", "/CT-e/" + relatorio);

        //Marcando como impresso
        BeanCadConhecimento ctrc = new BeanCadConhecimento();
        ctrc.setConexao(Apoio.getUsuario(request).getConexao());
        ctrc.setExecutor(Apoio.getUsuario(request));
        ctrc.ctrcImpresso(idCte);

        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    } else if (acao.equals("listar")) {
        ctes = (Collection) request.getAttribute("listaListSaidaMercadoria");
    }else if (acao.equals("exportarCCe")) {
        
        String modelo = request.getParameter("modeloCce");
        String relatorio = "";
        if (modelo.indexOf("personalizado") > -1) {
            relatorio = "cce_" + modelo;
        } else {
            relatorio = "dacte_mod_CC-e";
        }
        String idCte = request.getParameter("idCte");

        //Exportando
        java.util.Map param = new java.util.HashMap(20);
        param.put("ID_CTE", idCte);
        param.put("USUARIO", Apoio.getUsuario(request).getNome());

        request.setAttribute("map", param);
        request.setAttribute("rel", "/CT-e/" + relatorio);

        //Marcando como impresso
        BeanCadConhecimento ctrc = new BeanCadConhecimento();
        ctrc.setConexao(Apoio.getUsuario(request).getConexao());
        ctrc.setExecutor(Apoio.getUsuario(request));
        ctrc.ctrcImpresso(idCte);


        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }


    if (acao.equals("getModeloByFilial")) {

        BeanCadFilial cadfilial = new BeanCadFilial();
        cadfilial.setConexao(Apoio.getUsuario(request).getConexao());
        String modelo = cadfilial.getModeloDacte(Apoio.parseInt(request.getParameter("idfilial")));

        response.getWriter().append(modelo);
        response.getWriter().close();
//        
//        PrintWriter out = response.getWriter();
//        out.println(modelo);
//        out.close();

    }



%>
<script src="assets/js/jquery-1.9.1.min.js" type="text/javascript"></script>
<script src="${homePath}/assets/alerts/alerts-min.js" type="text/javascript"></script>
<jsp:include page="/importAlerts.jsp">
            <jsp:param name="caminhoImg" value="assets/img/gw-trans.png"/>
            <jsp:param name="nomeUsuario" value="${user.nome}"/>
        </jsp:include>
<script>
    var homePath = '${homePath}';
    let certificadoAtualizado = '${configTecnica.certificadoAtualizadoEm != null}';
</script>

<script language="JavaScript" src="script/prototype_1_6.js" type="text/javascript"></script>

<script type="text/javascript" src="${homePath}/script/jQuery/jquery-ui.js?v=${random.nextInt()}"></script>
<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/mascaras.js" type="text/javascript"></script>


<script language="javascript" type="text/javascript" >
    jQuery.noConflict();
    
//    var threadTeste = new ThreadGw("consultar();", 5000, true);
    function submeterConsulta(chaveConsulta, linha){
        if($("situacao_"+linha)){
            if($("situacao_"+linha).value == 'H'){
                abrirMax('http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=&cte='+chaveConsulta, 'popConsultaCompleta');
            }else{
                abrirMax("http://hom.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=mCK/KoCqru0=&cte="+chaveConsulta, 'popConsultaCompleta');
            }
        }
    }
    
    function enviarXmlFtp(idCte, index){
        if ($("cliente_envia_ftp"+index).value == "false") {
            alert("Cliente não está habilitado para enviar XML para o FTP!");
            return false;
        }
        window.open("./FTPControlador?acao=enviarFTP&id="+idCte+"&isAutomatico=false",'pop', 'top=10,left=0,height=300,width=300');
    }

    function jDialogChave(chave){
        jQuery("#dgChave").html(chave)
        jQuery("#dialog").dialog();        
    }
    function seleciona_campos(){
    <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
        if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null)) {
    %>
            $("valor_consulta").value = "<%=valorConsulta%>";
            $("valor_consulta2").value = "<%=valorConsulta2%>"; // 11-11-2013 - Paulo
            $("campo_consulta").value = "<%=campoConsulta%>";
            $("operador_consulta").value = "<%=operadorConsulta%>";
            $("limite").value = "<%=limiteResultados%>";            
            $("statusCte").value = "<%=statusCte%>";
            $("ordenacao").value = "<%=ordenacao%>";
            $("tipo_ordenacao").value = "<%=tipoOrdenacao%>";
            $("tipoTransporte").value = "<%=tipoTransporte%>";
            $("tipo-conhecimento").value = "<%=tipoConhecimento%>";
            
            var filial  = "<%=idFilial == 0? Apoio.getUsuario(request).getFilial().getIdfilial() : idFilial%>";
            if($("filial")!=null){
                $("filial").value = filial;
            }
            
            $('meuscts').checked = <%=Apoio.parseBoolean(request.getParameter("mostrarMeusCts"))%>;
            $('apenasNaoImpressos').checked = <%=Apoio.parseBoolean(request.getParameter("apenasNaoImpressos"))%>;
            $("modelo").value = '<%=Apoio.getUsuario(request).getFilial().getModeloDacte()%>';
            $('cteF').checked = <%=Apoio.parseBoolean(request.getParameter("cteF"))%>;
    <%}%> 
            if($("operador_consulta").value == "11" &&  $("campo_consulta").value == "pedido_cliente"){
                $("divIntervalo").style.display = "";
                $("valor_consulta2").style.display = "";
                $("valor_consulta").size = "8";
            }
        
        }
        
        function alterarFilial(elemento){                  
            new Ajax.Request("./listar_cte.jsp?acao=getModeloByFilial&idfilial="+ elemento,
            {
                method:"get",
                onSuccess: function(transport){                   
                    var response = transport.responseText;                    
                    $('modelo').value = response;
                },
                onFailure: function(){ 
                                      
                }
            });
        }

        function consultar(){
            javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value,"pesquisar", ordenacao.value, tipo_ordenacao.value, valor_consulta2.value);});
        }

        function consulta(campo, operador, valor, limite, acao, ordenacao, tipoOrdenacao, valor2){ 
            
            var data1 = $("dtemissao1").value.trim();
            var data2 = $("dtemissao2").value.trim();
            var statusCte = $("statusCte").value;
            var filial = $("filial") != null ? $("filial").value : "<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>";
            
            if (campo == "s.emissao_em" && !(validaData($("dtemissao1")) && validaData($("dtemissao2")) )){
                return alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            } 
            var pagina = parseFloat("<%=paginaAtual%>") + (acao == "proximo" ? 1 :acao == "anterior" ? -1 : 0);
            var remetente = $("rem_rzs").value;
            var idRemetente = $("idremetente").value;
            var destinatario = $("dest_rzs").value;
            var idDestinatario = $("iddestinatario").value;
            var consignatario = $("con_rzs").value;
            var idConsignatario = $("idconsignatario").value;
            var serie = $("serie").value;
            var tipoTransporte = $("tipoTransporte").value;
            var idMotorista = $("idmotorista").value;
            var nomeMotorista = $("motor_nome").value;
            var documentoAverbacao = $("documentoAverbacao").value;
            var idSetor = $("id_setor").value;
            var setorEntrega = $("setor").value;
            var uf= $("uf").value;
            let tipoConhecimento = $("tipo-conhecimento").value;
            
            if (tipoTransporte === '') {
                return alert('O Filtro modal é de preenchimento obrigatório');
            }
            
            if (tipoConhecimento === '') {
                return alert('O filtro Tipo CT-e é de preenchimento obrigatório');
            }

            location.replace("./CTeControlador?campo="+campo+"&ope="+operador+"&valor="+valor+"&operadorConsulta=1"+
                "&"+
                (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&limite="+limite+
                (acao == "proximo" || acao == "anterior" ? "&pag="+pagina : "")
                +"&acao=listar&statusCte=" + statusCte + "&filial=" + filial + 
                "&ordenacao=" + ordenacao +
                "&tipoOrdenacao=" + tipoOrdenacao +
                "&tipoTransporte=" + tipoTransporte +
                "&mostrarMeusCts=" + $('meuscts').checked +
                "&apenasNaoImpressos=" + $('apenasNaoImpressos').checked +
                "&remetente=" + encodeURIComponent(remetente)+ "&idRemetente=" + idRemetente + 
                "&destinatario=" + encodeURIComponent(destinatario) + "&idDestinatario=" + idDestinatario + 
                "&consignatario=" + encodeURIComponent(consignatario) + "&idConsignatario=" + idConsignatario+
                "&serie=" + serie + 
                "&idmotorista="+ idMotorista+ "&motor_nome="+ nomeMotorista+"&valor_consulta2="+valor2+ "&documentoAverbacao="+documentoAverbacao+
                "&idSetor="+idSetor + "&setorEntrega="+encodeURIComponent(setorEntrega)+
                "&uf="+uf + 
                "&cteF=" + $('cteF').checked +
                "&tipo-conhecimento=" + tipoConhecimento); //
                
                    
            if($('filial').value!=null || $('filial').value!=undefined){
                alterarFilial($('filial').value);
            }
        }
        
        function localizamotorista(){
                    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>','motorista',
                    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
                }
        
        function editarconhecimento(idmovimento, podeexcluir){
            window.open("./frameset_conhecimento?acao=editar&id="+idmovimento+(podeexcluir != null ? "&ex="+podeexcluir : ""), "menuLan", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
        }

        function habilitaConsultaDePeriodo(opcao){
            $("valor_consulta2").style.display = "none";
            $("divIntervalo").style.display = "none";
            $("valor_consulta").size = "27";
            $("valor_consulta").style.display = (opcao ? "none" : "");                     
            $("operador_consulta").style.display = (opcao ? "none" : "");
            $("div1").style.display = (opcao ? "" : "none");
            $("div2").style.display = (opcao ? "" : "none"); 
            
            if($("operador_consulta").value == "11" && $("campo_consulta").value == "pedido_cliente"){
                $("divIntervalo").style.display = "";
                $("valor_consulta2").style.display = "";
                $("valor_consulta2").size = "8";
                $("valor_consulta").size = "8";
            }
            
            if($("campo_consulta").value == "ft.numero"){
                $("valor_consulta").size = "8";
                $("valor_consulta2").size = "4";
                $("valor_consulta2").style.display = "";
            }
            if($("operador_consulta").value == "11" && $("campo_consulta").value == "s.numero"){
                $("divIntervalo").style.display = "";
                $("valor_consulta2").style.display = "";
                $("valor_consulta2").size = "8";
                $("valor_consulta").size = "8";
            }
        }
        
        function habilitaPeriodo(){
            if($("operador_consulta").value == "11"){
                $("valor_consulta").style.display = "";
                $("valor_consulta2").style.display = "";
                $("divIntervalo").style.display = "";
                $("valor_consulta").size = "8";
            }
            if($("campo_consulta").value == "ft.numero"){
                $("valor_consulta").size = "8";
                $("valor_consulta2").size = "4";
                $("valor_consulta2").style.display = "";
            }
        }

        function aoCarregar(){
            if(<%=Apoio.getUsuario(request).getFilial().getVersaoUtilizacaoCte().equals("104")  %>){
                alert("Atenção: Identificamos que você ainda está utilizando a versão 1.04 do CT-e, a partir de 01-06-2014, essa versão será descontinuada pela SEFAZ e a transmissão do CT-e só será válida na versão 2.0. Segue abaixo os procedimentos para efetuar essa mudança:\n            1)      No cadastro da filial (Cadastros/Filiais) alterar o campo Versão CT-e para 2.00 depois Salvar;\n            2)      Sair do sistema e entrar novamente; \n\n           Qualquer dúvida favor entrar em contato com o atendimento de sua região. ");
            }
            seleciona_campos();
            if ($('filial') != null && $('filial') != undefined){
                alterarFilial($('filial').value);
            }
            //Motorista
            $("idmotorista").value = "<%= request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0"  %>";
            $("motor_nome").value = "<%= request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "Todos os Motoristas"  %>";
            
            $("id_setor").value = "<%=request.getParameter("idSetor") != null ? request.getParameter("idSetor") : "0"  %>";
            $("setor").value = "<%=request.getParameter("setorEntrega") != null ? request.getParameter("setorEntrega") : "Todos os Setores"  %>";
            $("uf").value = "<%=request.getParameter("uf") != null ? request.getParameter("uf") : ""  %>";
            
             $("documentoAverbacao").value = "<%= request.getParameter("documentoAverbacao") != null ? request.getParameter("documentoAverbacao") : "t"  %>";
    
    <%if (acao.equals("listar") && (campoConsulta.equals("s.emissao_em"))) {%>
            habilitaConsultaDePeriodo(true);            
    <%}else{%>
            habilitaConsultaDePeriodo(false);            
    <%}%>    
   
        }
        
    
        function getCheckedCtrcs(){
            var ids = "";
            for (var i = 0; $("ck" + i) != null; ++i){
//                console.log("averb: "+ $("averbacao_"+i).value);
//                console.log("averb: "+ ($("averbacao_"+i).value == true));
//                console.log("averb: "+ ($("averbacao_"+i).value == "true"));
                if ($("ck" + i).checked ){
                    if ($("statusCte").value === 'E' && $('podeEnviarCTePresoEnviado' + i).value !== 'true') {
                        continue;
                    }
//                    console.log("ok");
                    ids += ',' + $("ck" + i).value;
                }    
            }      
            return ids.substr(1);
        }
        
        
        function getCheckedCtrcsAverbacao(utilizacaoAverbacao){
            var ids = "";
            for (var i = 0; $("ck" + i) != null; ++i){
//                console.log("averb: "+ $("averbacao_"+i).value);
//                console.log("averb: "+ ($("averbacao_"+i).value == true));
//                console.log("averb: "+ ($("averbacao_"+i).value == "true"));
                if ($("ck" + i).checked && ($("averbacao_"+i).value == "false")){
//                    console.log("ok");
                    if(($("averba_"+i).value!='N' && $("seguro_"+i).value=='c') || (utilizacaoAverbacao!='N')){
                   
                        ids += ',' + $("ck" + i).value;
                    }else{
                         alert("Filial e Cliente não possuem Caixa Postal para averbação de NFS-e.");
                         return false;
                    }
                }    
            }      
            return ids.substr(1);
        }
        
        
        //calcular a diferenca entre datas, pega a quantidade de dias.
        function diferenciarData(emissaoEm){
            var dataAtual = '<%=new SimpleDateFormat("yyyy/MM/dd").format(new Date())%>';
            var data1 = new Date(emissaoEm);
            var data2 = new Date(dataAtual);
            var diferenca = Math.abs(data1 - data2);
            var dia = 1000*60*60*24;
            var resultado = Math.round(diferenca/dia);
            return resultado;
        }

        function enviarCTe(){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            var emissaoEm;
            var numeroCTe;
            var idCTe;
            var CTes = "";
            //pega todos os CTe(s) que estão com datas maiores que 10 dias, 
            //valida de acordo com a emissão e a data atual do sistema.
            if (getCheckedCtrcs() != "") {
                for (var qtdCte = 0; qtdCte < $("qtdLinhas").value; qtdCte++) {
                    if ($("ck"+qtdCte).checked) {
                        emissaoEm = $("emissaoEm_"+$("ck"+qtdCte).value).value;
                        numeroCTe = $("numeroCTRC_"+qtdCte).value;
                        idCTe = $("ck"+qtdCte).value;
                        var dias = diferenciarData(emissaoEm);
                        if (dias >= 10) {
                            CTes += "\n" + numeroCTe;
                        }    
                    }
                }    
            }else{
                return alert("Selecione ao menos um CT-e!");
            }
            
            if (CTes != "") {
                var tamanho = CTes.substr(1).split("\n").length;
                var mensagem = "";
                if (tamanho == 1) {
                    mensagem = "A data de Emissao do CTe \n"+CTes.substr(1)+"\né maior que 10 dias, deseja realmente enviar para a SEFAZ?";
                }else{
                    mensagem = "A data de Emissao dos CTe(s) \n"+CTes.substr(1)+"\nsão maiores que 10 dias, deseja realmente enviar para a SEFAZ?";
                }
                if (confirm(mensagem)) {                  
    
                }else{
                    return false;
                }
            }
            
            $("botEnviar").disabled = true;            
            $("img_enviar").disabled = true;            
            $("botEnviar").value = " ENVIANDO... ";   
            var status = $("statusCte").value;
            var ctrcs = getCheckedCtrcs();
            if(ctrcs == ""){
                $("botEnviar").disabled = false;            
                $("botEnviar").value = "Enviar CT-es selecionados para SEFAZ";            
                $("img_enviar").disabled = false;            
                return alert("Selecione ao menos um CT-e!");
            }
            var pop = window.open('','pop','location=1,status=1,width=600,height=600');  
             //window.open('', 'teste', 'width=400, height=400');
            var formu = $("formulario");
            formu.action = './CTeControlador?acao=enviar&ctrcs=' + ctrcs+ "&status="+status;
            formu.submit();
        }
        
         function averbarCTe(utilizacaoAverbacao){
             if (certificadoAtualizado === 'false') {
                 chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                 return;
             }

            //$("botAverbar").disabled = true;            
           // $("img_enviar").disabled = true;            
           // $("botAverbar").value = " AVERBANDO... "
            console.log("utilizacaoAverbacao: "+utilizacaoAverbacao);
            var ctrcs = getCheckedCtrcsAverbacao(utilizacaoAverbacao);
           
            if(ctrcs == ""){
                $("botAverbar").disabled = false;            
             
               // $("img_enviar").disabled = false;            
                return alert("Selecione ao menos um CT-e não averbado!");
            }
            
            if(ctrcs != ""){
            window.open('about:blank', 'pop', 'width=400, height=800');
            var formu = $("formulario");
            formu.action = './CTeControlador?acao=apisulAverbacao&ctrcs=' + ctrcs;
            formu.submit();
            }
        }
        
        
        function cancelarAverbacaoCTe(){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            //$("botAverbar").disabled = true;            
           // $("img_enviar").disabled = true;            
           // $("botAverbar").value = " AVERBANDO... "
            console.log("cancelarAverbacaoCTe");
            var ctrcs = getCheckedCtrcs();
            console.log("ctrcs: "+ctrcs);
            if(ctrcs == ""){
                $("botCancAverb").disabled = false;            
                $("botCancAverb").value = "Cancelar Averbação";            
                $("img_enviar").disabled = false;            
                return alert("Selecione ao menos um CT-e!");
            }
            window.open('about:blank', 'pop', 'width=400, height=800');
            var formu = $("formulario");
            formu.action = './CTeControlador?acao=cancelarAverbar&ctrcs=' + ctrcs;
            formu.submit();
        }

        function checkTodos(){
            //seleciona todos
            var i = 0 , check = false;

            if ($("ckTodos").checked){
                check = true;
            }

            jQuery('input[type="checkbox"][name^="ck"][name!="ckTodos"]:not(:disabled)').prop('checked', check);
        }

        function cancelar(ctrc,numero,isTemFatura,isTemManifesto,isTemRomaneio, evento){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            if(ctrc == ""){
                return alert("Selecione ao menos um CT-e!");
            }else if (isTemFatura == 'true' || isTemFatura == true || isTemFatura == 't'){
                return alert("Esse CT-e não pode ser cancelado, já existe uma fatura gerada!");
            }else if (isTemManifesto == 'true' && <%=(nivelCancelarCTRC < 4) %> || isTemFatura == true || isTemFatura == 't'){
                return alert("Esse CT-e não pode ser cancelado, já existe um manifesto gerado e você não tem permissão para executar essa ação!");
            }else if (isTemRomaneio == 'true' || isTemRomaneio == true || isTemRomaneio == 't'){
                return alert("Esse CT-e não pode ser cancelado, já existe um romaneio gerado!");
            }else if(evento=='110110'){
                return alert("Esse CT-e não pode ser cancelado, já existe uma Carta de Correção!");
            }

            if(confirm("Deseja cancelar o CT-e '" + numero + "'?" )){
                var textoCancelamento = prompt("Qual o motivo do cancelamento?" ,"");

                if(textoCancelamento != null){
                    if(confirm("Deseja cancelar o CT-e?")){
                        if(confirm("Tem certeza?")){
                            window.open("./CTeControlador?acao=cancelar&ctrcs=" + ctrc + "&numero="+numero+"&motivo="+textoCancelamento , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
                        }
                    }
                }
            }
        }

        function abrirDetalheStatus(codigo){
            return alert("Descrição: " +codigo);
        }

        function atualizarRecibo(numeroRecibo, idCte){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            window.open("./CTeControlador?acao=atualizarRecibo&numeroRecibo=" + numeroRecibo + "&ctrcs=" + idCte , numeroRecibo, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
        }
        
        function consultarProtocolo(idCte){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            if(confirm("ATENÇÃO!\r\n A rotina de atualização de protocolo, deve ser usada apenas em \r\n"
                + "casos onde o CT-e encontre-se devidamente confirmado na fazenda e em divergência de 'Status' com o sistema webtrans.\r\n"
                + "O uso incorreto poderá danificar a assinatura do xml.\r\n" +
                "Deseja continuar?")){
                if(confirm("Tem certeza?")){
                    window.open("./CTeControlador?acao=consultarProtocolo&ctrcs="+ idCte, idCte + "consultaProtocolo", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }
            }            
        }

        function popCTe(id, index){
            var idsDactes = "";
            if(id == "0"){
              //  if($("utilizacaoApisul").value!='N'){
               //      id = getCteAverbado();
               // }else{
                    id = getCheckedCtrcs();
               // }
            }
            
            //quando o id da utilização Apsul retornar em branco 
            //quer dizer que não tem nenhum CT-e verbado por isso não pode ser impresso o relatório
            
            if (id == "" || id == null){
                return null;
            }else{
                console.log("id: "+id);
                var emissao;
                var resultado;
                var ctesNaoAverbados="";
            
                if(index == '-1'){
                    for (var i = 0; getObj("ck" + i) != null; ++i){
                             if ($("ck" + i).checked ){

                                
                                    console.log("isaverbado: "+$("imprimirAverbado_"+i).value);
                                  
                                    if(($("imprimirAverbado_"+i)!=null) && $("imprimirAverbado_"+i).value=='false' ){
                                       ctesNaoAverbados+= ","+$("numeroCTRC_"+i).value;
                                    }else{
                                         if(idsDactes==""){
                                             idsDactes+=getObj("ck" + i).value;
                                         }else{
                                             idsDactes+=","+getObj("ck" + i).value;
                                         }
                                    }
                                
                             }
                     }
                 }else{
                    
                        console.log("isaverbado: "+$("imprimirAverbado_"+index).value);

                                    if(($("imprimirAverbado_"+index)!=null) && $("imprimirAverbado_"+index).value=='false' ){

                                       ctesNaoAverbados+= ","+$("numeroCTRC_"+index).value;
                                    }else{
                                             idsDactes+=id;                                         
                                    }
                    
                 }
                
                   console.log("id2: "+idsDactes); 
                   if(ctesNaoAverbados!="" && ctesNaoAverbados!='undefined'){
                        alert("O(s) CT-e(s) "+ctesNaoAverbados.substr(1)+" não está(o) averbado(s)!");
                   }
            
            
                
            }
            
            if (idsDactes != "") {
                var wName = 'dacte';
                launchPDF('./listar_cte.jsp?acao=exportar&modelo='+$('modelo').value+'&idCte=' + idsDactes, wName);
            }
            
        }
        
        
         function popCCe(id){        
           
            if (id == "" || id == null){
                return null;
            }
            var modeloCce = $("modeloCce").value; 


            var wName = 'dacte';
            launchPDF('./listar_cte.jsp?acao=exportarCCe&idCte=' + id+'&modeloCce='+modeloCce, wName);

        }
        
        
        function getCteAverbado(){
            var ids = "";
            for (var i = 0; getObj("ck" + i) != null; ++i){
                if ($("ck" + i).checked ){
                    
                    var emissao;
                    var resultado;
                   for (var i2 = 0; getObj("ck" + i2) != null; ++i2){
                        if ($("ck" + i).checked ){
                            emissao = $("emissaoEm_"+getObj("ck" + i2).value).value;
                            resultado = $("dataAverb").value <= emissao;
                        }
                   }
                    
                    console.log(" isAverbado : " +$("imprimirAverbado_"+i).value);
                    console.log(" resultado : " + resultado);
                    console.log("isvaebrdo?: "+$("imprimirAverbado_"+i).value);

                    if($("imprimirAverbado_"+i)!=null){
                        if($("imprimirAverbado_"+i).value=='true'){
                          
                                if (ids == "") {
                                    ids += getObj("ck" + i).value;
                                }else{
                                    ids += ',' + getObj("ck" + i).value;
                                }
                         
                        }
                    }
                }
            }
            return ids.substr(1);
        }
        
        function popXml(idCte, chaveAcesso, isCanc){
            if (idCte == null)
                return null;
            window.open("./"+chaveAcesso+"-cte.xml?acao=gerarXmlCliente&idCte=" + idCte+"&isCanc=" + isCanc , "xmlCTe" +idCte, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
        }

        function enviarEmail(idCte, isCanc){
           
            if (idCte == null)
                return null;
//            window.open("./CTeControlador?acao=enviarEmail&idCte=" + idCte+"&isCanc=" + isCanc , idCte, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
            window.open("./CTeControlador?acao=enviarEmail&ctrcs="+idCte+"&isCanc="+isCanc,'pop', 'top=10,left=0,height=300,width=300');
        }
        
        function enviarVariosEmails(){
            var check = false,index =0, cont = 0, idCtes = "";
            
            while ($("ck"+index) != null){
                if($("ck"+index).checked){
                     idCtes +=  $("ck"+index).value+","+$("isCancelado_"+index).value +"!!";
                    cont++;
                }
                index++;
            }
            if(cont > 0){
                if(cont > 50){
                    alert("Para evitar que o e-mail seja classificado como span, só é permitido enviar 50 e-mails por vez.");
                }else{
                    window.open("./CTeControlador?acao=enviarVariosEmails&ctrcs=" + idCtes, idCtes, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }
               
            }else{
                alert("Selecione pelo menos um CT-e!");
            }
            
        }

        function desativarBotoes(){
            var atual = "<%=paginaAtual%>";
            var paginas = "<%=pag%>";

            if(atual == '1'){
                $("voltar").disabled = true;
            }
            if(parseFloat(atual) >= parseFloat(paginas)){
                $("avancar").disabled = true;
            }
        }
        
        function limparMotorista(){
            $("idmotorista").value = "0";
            $("motor_nome").value = "Todos os Motoristas";
        }
        
        function getCtes(){
            var ctes = "";
            for (var i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked)
                    ctes += ',' + getObj("numeroCTRC_" + i).value;
                  
            return ctes.substr(1);
        }
        
        function novaCCe(){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            if(confirm("Atenção: Ao fazer uma Carta de Correção, o CT-e não poderá ser cancelado! Tem certeza?")){
            var cts =getCtes();
         
            var ctrcs = getCheckedCtrcs();
            console.log("ctrcs> "+ctrcs);
                if(ctrcs == ""){                          
                    return alert("Selecione ao menos um CT-e!");
                }            
//            window.open("./CTeControlador?acao=novaCCe&ctrc="+ctrcs+"&ctes="+cts, "titlebar=no, menubar=no, scrollbars=yes, status=yes,  resizable=yes, left=0, top=0");
           post_cad = window.open("./CTeControlador?acao=novaCCe&ctrcs="+ctrcs+"&ctes="+cts, 'Carta de Correção', 'height=600,width=1100,resizable=yes, scrollbars=1,top=50,left=500,status=1');
            }
        }

        
        function visualizaImagem(imagem,idCTE,nomeImagem){
                window.open("ImagemControlador?acao=imgpdf&imagem=" + imagem.trim()+nomeImagem.trim() + "&idconhecimento=" + idCTE, "visualizaImagem", 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
        
        function limparSetorEntrega(){
            $("setor").value = "Todos os Setores";
            $("id_setor").value = "0";            
        }
        
        function abrirLocalizarSetorEntrega(){             
             post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.SETOR_ENTREGA%>','motorista','top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
        }
        
//        function consultarStatusServico(){
//            window.open("./CTeControlador?acao=statusServico",'pop', 'top=10,left=0,height=300,width=300');
//        }
        
        function consultarStatusServico(){
            if (certificadoAtualizado === 'false') {
                chamarConfirm(`Foi identificado que será necessário atualizar os vínculos dos certificados digitais cadastrados no sistema. Essa atualização é necessária para que os documentos fiscais (CT-e/MDF-e/NFS-e/NF-e/CIOT) continuem funcionando corretamente. Esse procedimento é muito rápido, deseja fazer isso agora?`, 'usuarioAceitouAtualizarCertificado()', 'usuarioNaoAceitouAtualizarCertificado()');

                return;
            }

            new Ajax.Request("./CTeControlador?acao=statusServico",
            {
                method:"get",
                onSuccess: function(transport){          
                    var response = transport.responseText;                    
                    chamarAlert(response);
                },
                onFailure: function(){ 
                                      
                }
            });
        }
        
        function isExibirNotas(linha) {
            
            let tr = $("tr-notas-fiscais-"+ linha);
            
            if (isVisivel(tr)) { 
                invisivel(tr);
            } else {
                visivel(tr);
            }
        }
             
</script>

<link href="estilo.css" rel="stylesheet" type="text/css">
<style type="text/css">
    <!--
    .style8 {font-size: 11px}
    -->

    .modal-content {
        text-align: left;
    }
</style>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />
        <title>WebTrans - CT-e</title>
    </head>

    <body onLoad="aoCarregar();applyFormatter();desativarBotoes();">
        <img src="img/banner.gif"  alt=""><br>
        <table width="99%" align="center" class="bordaFina" >
            <tr>
                <td width="590">
                    <div align="left">
                        <img src="img/cte.jpg" height="25" class="imagemLink">
                        <b>CT-e</b>
                        <b>( <%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte() == 'H' ? "Homologação" : "Produção"%> )</b>
                        
                    </div>
                </td>
                <td width="98">

                </td>
                <td align="right" width="98">
                    <input type="button" class="inputBotao imagemLink"   
                           onclick="consultarStatusServico();" value="Consultar Status do Serviço">
                </td>
                <td align="right" width="98">
                    <input type="button" class="inputBotao imagemLink"   
                           onclick="abrirMax('<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte() == 'H' ? "http://hom.cte.fazenda.gov.br/portal/disponibilidade.aspx?versao=1.00&tipoConteudo=XbSeqxE8pl8=" : "http://www.cte.fazenda.gov.br/portal/disponibilidade.aspx?versao=1.00&tipoConteudo=XbSeqxE8pl8="%>')" value="Verificar Disponibilidade do Servidor da SEFAZ">
                </td>
                
                <td style="display:none">
                    <form action="<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte() == 'H' ? "http://hom.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa" : "http://www.cte.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa"%>" id="formConsulta" method="post" target="popConsultaCompleta">
                            <!--Esses dois hidden abaixo são responsaveís por enviar as informações para o site da sefaz para poder consultar a nota por chave de acesso
                            Sem precisar digitar a mesma.-->
                            <!--<input type="hidden" name="__VIEWSTATE" value="/wEPDwUKMTUzMzExNTU2NA9kFgJmD2QWAgIDD2QWEAIJDw8WAh4EVGV4dAUOOCw0NzggbWlsaMO1ZXNkZAINDw8WAh8ABQkxLDQ1NiBtaWxkZAIPDw8WAh4LTmF2aWdhdGVVcmwFFWluZm9Fc3RhdGlzdGljYXMuYXNweGRkAhUPDxYCHwEFNH4vUGVyZ3VudGFzRnJlcXVlbnRlcy5hc3B4P3RpcG9Db250ZXVkbz1sNWltT1ZsRHFQVT1kZAIhDzwrABEDAA8WBB4LXyFEYXRhQm91bmRnHgtfIUl0ZW1Db3VudAIEZAEQFgAWABYADBQrAAAWAmYPZBYMZg8PFgIeB1Zpc2libGVoZGQCAQ9kFgJmD2QWAgIBDw8WBh4NQWx0ZXJuYXRlVGV4dAUrTWFuaWZlc3RvIEVsZXRyw7RuaWNvIGRlIERvY3VtZW50b3MgRmlzY2Fpcx4PQ29tbWFuZEFyZ3VtZW50BSRodHRwczovL21kZmUtcG9ydGFsLnNlZmF6LnJzLmdvdi5ici8eCEltYWdlVXJsBR1+L2ltYWdlbnMvYmFubmVyX21kZmVfT2ZmLnBuZ2RkAgIPZBYCZg9kFgICAQ8PFgYfBQUXTm90YSBGaXNjYWwgRWxldHLDtG5pY2EfBgUdaHR0cDovL3d3dy5uZmUuZmF6ZW5kYS5nb3YuYnIfBwUkfi9pbWFnZW5zL2Jhbm5lcnNfVmlzaXRlX05mZV9PZmYucG5nZGQCAw9kFgJmD2QWAgIBDw8WBh8FBSlTaXN0ZW1hIFDDumJsaWNvIGRlIEVzY3JpdHVyYcOnw6NvIEZpc2NhbB8GBSNodHRwOi8vd3d3MS5yZWNlaXRhLmZhemVuZGEuZ292LmJyLx8HBSV+L2ltYWdlbnMvYmFubmVyc19WaXNpdGVfU3BlZF9PZmYucG5nZGQCBA9kFgJmD2QWAgIBDw8WBh8FBSpTdXBlcmludGVuZMOqbmNpYSBkYSBab25hIEZyYW5jYSBkZSBNYW5hdXMfBgUaaHR0cDovL3d3dy5zdWZyYW1hLmdvdi5ici8fBwUgfi9pbWFnZW5zL2Jhbm5lcnNfbWFuYXVzX09mZi5wbmdkZAIFDw8WAh8EaGRkAi0PZBYEAgEPDxYCHwAFCUNvbnN1bHRhc2RkAgMPZBYEAgEPZBYEAgEPZBYCAgEPZBYEAgIPZBYCAgsPEGRkFgBkAgMPZBYCAgsPEGRkFgBkAgMPZBYIAgcPDxYCHg9WYWxpZGF0aW9uR3JvdXAFCGNvbXBsZXRhZGQCCQ8PFgIfCAUIY29tcGxldGFkZAILDw8WAh8IBQhjb21wbGV0YWRkAg8PDxYCHwgFCGNvbXBsZXRhZGQCAw9kFgQCAQ8PFgQfBwWmP2RhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBTFFBQUFBeUNBWUFBQUQxSlBIM0FBQUFBWE5TUjBJQXJzNGM2UUFBQUFSblFVMUJBQUN4and2OFlRVUFBQUFKY0VoWmN3QUFEc01BQUE3REFjZHZxR1FBQUJkQVNVUkJWSGhleloxWnJHYlRFc2ZOeER6RkZQTVFJdVpveER6RVBKTU9ZcDZKb2Mwa3BoYU5GbE9URnQxY2Nla09Jb2E0aUJnU0Z3bmhCYmtQZUdxZWVPdEg5MjNmODF2ZC82MU9uVnJEL3ZvNzNIOVNPZWZzdllaYXRmNVZxOWJhKy92T1NoUG9Tckx6empzdm1URmp4bjltenB6NTc2ZWVlbXJ4eHg5L1BML3J1dGxmZmZYVnZGbXpadjNyNmFlZlhyUnc0Y0ovL3ZycnIzTzVQbTVadW5UcG5PbHNHOTJuVS85SW9qRmhUMnpyZFZxMGFORS9iRGxmUHJwbnBiWGNkTXZiYjcrOUlEY1dLeTFsU3JMU21tdXUrZCtJeUsyeStlYWJkK2VmZjM3M3pqdnZUTFEzSGl4WnNxVDc4Y2NmMCsrMGUvLzk5NmZmaFI5KytLSDc5dHR2bC84MU91aUR0cEh2dnZ0dStkWHBoeDNUWjU5OTFuM3p6VGU5UGVmUG45L3I5TUlMTDZScmp6enlTQ28zUWZaVUIxMVZQckw3MTE5L25YN1d5azBuMFBYbm4zL3VmdnZ0dCs3RER6L3M5WGpwcFplV2w1Z0t4bGdyVThOS0V6TDdwNTkrNmk2KytPSnV3dzAzN0R1T1pPV1ZWdzZ2Vzlsbm4zMjZNODQ0STAwSVJpd1JoUUg4OGNjZnkvOWFCajhKREk2MlJQTHBtaVNSNEsrQXhzUlB4bkhoaFJmMlkzcnV1ZWVXbCtxNjExNTdMVjA3K09DRFUzbnB5TGlqOHNDU29sUnVLQ0NvSEtvRjlILzY2YWNudlpuamlkVTlPV2FwalJkZmZESHArdkRERHkrL01qbTR0U0FSZXRtdnk0RFJMcm5ra203ZGRkZnRqVkdTTmRaWUkwbDB6NG9uK2dNUFBKQ3VNMGdMUHdsNCtPdXZ2OTVmdSt1dXV5YmRId2ZHRVJrRUpvLzJrTnprTVNZY2svdHlWdnBtUEpZNHRIWEhIWGQwbjN6eVNmcmJCZ0NWOXdGQlRnQ0JBT1ZvNC9QUFAwOS9qd3IwTFFVbkQ4WTBrV1lVQXdXNld4dXhVaDF6ekRIOWVFY0pYb25Rdm1IQU5Zd0RDZFdvWlAzMTE1OXlUYkxCQmh0MG0yeXlTYmYxMWxzM09jVk9PKzJVQm5IcnJiZW0vcGcwUDFtVzVEZmZmSE4zNTUxM2RrOCsrZVNVeVJ3Vm5nUWVRNkozS1kxQjN4clpHU3QxUGJBSk92b0E0RUVmTmhMU2wyeEhHLzhQUUVmMHk0MVY4TUVOcUc0RXJpZEMxeG9tb21DazdiZmZ2dThBMldpampib2RkdGloMjNiYmJidUpYSHpTUFN0RVowaDcxbGxucGVWeml5MjJDTXRab2E4amp6d3lSV1NJQm9tUnUrKytPeVRMaXNDVHdFS0VHQWNaeVB0eFhLOC9mYUFEb0o5b0x0Q042MFMrSVpDeklqbUgvYXNodnVYR0NoZ3Zkbm4yMldlbkJMZGNuUlRSSjM3T0xqWHNRWUovN3JubjlrYVNuSERDQ1gzbnBDeTc3YmJibERJU3lEcHo1c3dVL1crNTVaYnUybXV2N2ZiYmI3OHBEaE1KSzhDaGh4N2EzWFRUVFdtQ1N0RnVIS2hGN3lIQXpqZ2tPa3R2cnRIK2pUZmVtRllDcFNORHdHVGJOaTI0OStDREQ2YjUvZVdYWDZiVlZxMFEzNkt4b2k4NmNwMHlmbldzY1RVUmVoUWo1cUkyZnl2YUlUZ0FDaEJ0MTFwcnJVbGxyUngwMEVHSnBDaE16Z3lScUFmcGlmQlJIU3RzYU9sajNFVEh3TG5vRGVoSDBhTUdvaXRqWTF6SUs2KzhrdHJsbEVqallQeERVVHV0NFJyRTRPZlFlUjRuUk00YzM3QUZ6c2RLbkVPdUx0Zkl2ZnNjT3VmaGdHc2xna0JhSXJRbEdPUWxVdnNsa280aEhPbkhwcHR1T3FtT0ZTTHhBUWNja0U1ZjNuenp6ZFEzZFlub1J4eHhSRm9sY0lLb3JoV0lqa1BjZHR0dFk0L29pcTRRZmlqUWc3cTBnZjB2dSt5eWxKYU5TemVoOWNpc0ZZcWdOVkRHbHJQanRXQk9SWFIrNTJUazhzc3ZUMyszNHQxMzMrM0htQWpkNHVIYzgrSGY0NE1QUHZpellTTkUyUysrK0NJMEJOY1V4WEdLMHRFaGFReHRzVHhqSUVWRzlDZmRnZWpISG50c0U5RnhPQi9SV3lPdGdPN29QVFN2QlVSbjlManV1dXRTTzB3MGJiV0EvbHFQc2hnVDR5dXRNa0pMdTdYOWxnQm5MSmVpMUMxeXRsR3loZSsvLzc0Ny92ampVMEJJaEY1MmVTb3dRQ21pWVN6dXE0emRsVjUwMFVWcHc2aS9rZjMzM3orVnJRSERZZ0RJQnVsc0cxNGdPZEdhQ2ZPa3hERFBQLzk4ZDhnaGgzVEhIWGRjYzBTbnoydXV1YVp2czBZRWo1cmpBeWFCQ1dCNVJjL1dpYVNNZE1YZTQwSnJ1OTd4V3NZS3NPR1ZWMTdadmZmZWU3MDlyYk1SOERnQXdQWUljMG8venp6elRFb2xXdnNwRXBwQjBtaXVzU2l5TTJEdFN2bWRsTUduSTd2c3Nzc2tvekhBR21tSXdOUmxRMWpMcVMzSmVkckcrYVlGZW10Vm9OeVFIQjJqTTc2Y1kzS2Q4b280SmJTTTI4TUdEUjFsRVFEb0Y4RXhXc0Q4Mkw2amRpUHc5Ty9xcTY5T3RtTnVLVSthWUNOdmhJZ3I5RW5nYURuMVFscFNrU3loTVk2TmRoRzhVVHhzMUdGQTVOUldRWWpFb0NpamNqbjRKWXZ5TERQWFgzOTlhcmVGNUtRckdKU3hSWHJUcGlWNlMwVFg4U0oxY0RwT01iaHVKNWkrSXFMaGFFUW1BV0lxQWlKRWI0S0JvaFpTT2oyU1FCRHBoSDFwMTRQcjNMZXd3U2dIMm9yNnhBNGxZUE9QUHZvbzVidll0blJBVUJMR1ZrcWZRa0l6TUNwVHNZUTMzbmlqdUNPTndCSkMyNnV0dGxxdkpHU0VTSUpXQkpTVzRoalpEaVNuSTRhRFRDMlJGK05BbU5MRUE0aXVVeGZLdHh3dnNncXBiYUlRVWMyRFBuRUFsdUtOTjk0NGJHZGNBb0ZJNFFRNXppaUkya2R5MEZ3aHE2NjY2cVE2WGdnNnpHbHQ3cmdma1hvU29SVnhFUWFibTJEaGhodHVTQnV4SVJBeGVjSElSMnlpQ21Ua2Q0emdJN2QwMCs4bEhibXZxRWpleHZzQkVLc1dkZTFtRVIxS3VSdEhUSHBmZ1RvdFJHY2l0Rkp3WW5QaWlTZE9jdTdwRm8ybk5XZVB3RmlSd3c4L25MY3h1eDEzM0RHbGdqa3dGNWRlZW1tMyt1cXJUOUZublhYVzZjNDg4OHowS29SZkhkQ1JhL3Z1dSsrVWVraEU2a21FOXNzUWpSUHh0RVR6MDNZNGI5NjhNUElBaUthTm5jZ1I3YUM1eGdSN1pUbWI5UWIzQkMvQlJxQ29IaE5MR1cwOGEwc2d4c01CY1VZdG4ydzRyYjBFN3RNMlI1T1F2RFZISEVWSVFYQlNqamdaeDNiYmJSZVdrekNPRllGNDRJbFVBbHlJVHEvUVdiOWpMd3ZxaUMvY0l4T0lnaEZQcVcxUW0wUm9Td0pnRTNtZTV0R0FsbmdJOGRaYmIvVWJCT1dNREJhaitZNGwybHhSeHhJY3d1SHRVUjByZUMxMUdZaXVxVTI3bVdHUTdJN1JCNkdPVFdzaW9JK2NtblNCVjJOdDMxNXdBZ2lMb1JremovV3BKd05iZXlvNFlDYzVVVFRKSmNFK24zNzZhV3BQd0c2NmorNWFBU0VjL2R2NkVwdmZEd1ZIc3h3MStwV0xmZ2xnTDcvOGN1b2IwUXBKK3VkMXdGN1VRUmZwSy9neGFUWGhxRE1LUE5oU21FVG8zREprendzUE8reXdNT0tJVlA1NlNXeTBZSERqaUdTMGlaR2lxSTlnRU81Qi9seVU0U1JqeXkyM0RPdTN5TnBycjUzU01WNmt1dSsrKzdMOUFEYUZMTWRzY0hrZGdINnBIN1VyVVZwRUNwVjc5VlRRSnRWS2JRT0hZeXNReUNrUmdwZmFPT2VjYy9ycnJGeDc3TEZIZncvSHM4NGNCYmlTVTBGaWxkT1kwSVcvU2ZGMHo0cUN5Q1JDNXdEWjhNcW9vUlVWbEJjd3dxNjc3aHFXbXc0aGNqQTJTemgrYjNrZGRxaEF3RnpxUlNEUnNTVEM4bXJydG9xSVRqOFFoclFvV3ZVZ29BZDJ3QjVEVjQyY1FEQ2lPTzM2ZS9UQjlSS3dFMlJXT1oxeVBmYllZK0ZKRHpiRGprMkVacEpwbklvdEd4Z2lMY3VJWFpaUURDL3pVZGhHYVFIRldMcHRPU3Q4MEdER2pCa3BBakJ4VVFSb2xVY2ZmYlNQSkFLUmozdVFRUk5NV2dGWldqWitrcEpqaUh5c0JqZzFIN0xROHNzbU5xb0RFWEdHb1VlTFhuQWVUeWdJRkpVZFZkUStLWksvaDhNQnl1UldMeHpDT2o1bEdUTzJTZTlzdURaSkQ3bmZSR2dHeTlLRnNYbGpDMkw2RXdvSnUxME8zM09nRFYvSDUyTWcxNzQvOW9ITUltQWtURGk2azByaEtEYjNSdmpiRXhyakthOURHQzgvMFRQblBMbnpZVjRYRlFGeDBsSmFoZk5RUmc4c3ZFU1JWV0R5SVNwUEgxdVBBSEZPbkFyZHlFK1BPdXFvc0p5RXNWTmV3cGh6RDdxVUFseHd3UVZUN21sVjVxZTNQZkE1dE1CMTVwSnhSblo4Ly8zMzJ3aXQ1Y01pZVlOcmtHdDBHdVhoUWhRSklJeEhsQU16QVJDTGwvczlNU1B4T3VlaTBJSUZDM3JTZWpBV3htVlRBaTg0RFhWejBadmwwZ0o3TWxFc2syd2tvNDFPSkpSRlQ0UmpTSWhQRzVDcnR2OWdaZDF6enoyYkhzeGdXOG94YnZUTXphZjJYRkh3RWFGWmVmeEtoUU1RTkppUGlORDBxYkorWDhDbU0zSVNiQWlhQ0IzQnZ2SW9hVUZFS3Y5b0dqQkp2cHcyTXlJWnIyS3laT2Ntay9kSlpGZ0E2YUpvb2xjNm81VkNVTXJsWmJQTk51dWY5dEZYbElQeTRZZklhZTJFRW1GMXpObEN1bEVFeDlNWTc3bm5uclRCMHZzVExibnpYbnZ0MVoraFc2SkhoTGJqalU0NVNLL2tFQkd3RFRiSElaUjZpRHQ3NzczM2xQYXdHUmhNYUR3TFpTTXZhVUZFYUQ3ejVoRkZPeEZhZ0tDSVBZV0poTUZDRk1wRnhyV2t6NEVUQ0Y4UDhkRVh3a1FSbDlkaE5UR3lJWFgxK1RtTHlFYmpGR3pBcDJlOEEyTkw5SUpzSW5vdDhpUFI4YVlsdERaMFZyQVJoQzRCc3FzOERvUitwSERSQXhwMEJUMmhSWTRhbUJROGxDZUV2bEVMbElraVhqUlpYMzc1NWZLN2Z5TGFuUk5kTGVnRGlkb2s0a1RSZUpWVlZwbHlyV2JZbk1QSWlCNTJ5YlNpbEVrMlJLSUlOZDJFUnJReHl3R25FeDkrLy8zM2xON01tVE1uMVd1TjZOaWZpRTdleXhOQmY1OEhUeEhvbHptSlVvL3p6anR2VWhzU2JJa1Q5WVFXT1ZwQkE3NVJ3UktBeWJHSUpzdEhTUFR3WlJBUkNHUGo5VHJFajlvVStURU05MHRIVXR6RFlCQ045akNNSnBPK2VDL0QxeUhDS09KR0lNcjVPZ2hQeHpoT3MzMTQ1QWl0NVo0TksvWEpvM2xhQ2NraTUwVWlJaUYrdGZPQVRQUmxJYUlKc3RVcHA1d1M5dEVpbkdmenNNYUM4YXR2SG9temd0TVhjeDd0blVpbHhJbWUwQkUwQUNuT1Q2RkVhQnJYRVpTdEE2TEpza1lpcXVjaW5BaHQ3N05CalBMYlhQU3NQUnJlYXF1dEVqbklNWEcwNkZRR1lVbkc4YkNMaERGakYwbHV1ZGFHS3hkQWNvVG11cUF5NkNlUXl6L3h4Qk5ONzZ3Z0pZZTBwQktpYXlEU2w0ZEt6TXVRMUlWdkNqanBwSlBTV1RNOHNJRXhTak1RZ3BRQ0lyd3JFbG9Ed1BEOHRDa0VmL3ZHUzVBSE1UaGZUOExMUHZ6RUs4azUvWDJPdElCZmlpSmRQS0hwSCtmeXVUa0dZVk9UTTNqTGwrdU1JbjdKWjFKRXNJZ2dDSFpoRGhnTDU3R2tBYnpreFRWdEpHMjdqQmR5YzdvUnBWbzROL2V4cHdkQnhqc2NPbG9PQ0pHK0VmSFJtMVcxZHF6SW5MQnFSaHp3UWlDeG1FUm9PbFMwd1JpNUFURFlhR2NMaVJBYk5RU002c3Q3S1gwVmdvU2xuajQ0cm9MTTZCd1JHb0p5Sm92SGt3TnFDZldFcGoyaUNQY2hGRkVXeDJuSkVWZFUwQi83MmhSTHIrVGFjbDVJTlJnTHdnbVJQUlVoTGJHQThMWHpaUVE3VUJlZEZQRUU2MndSb2oxR1JHZ0IvbUR6WEpyVUlzd1JwMU1la3dpTjBqSlV0QnhDOHBhbEE3R09RTDMxMWxzdkxEZXEyQWlNY2FJeWtxT1BQcnBmYmFMN0VzZ3MyRldnSm55eERwdFlQbUtHWHVnak95S3NQS1VQQlBQZWgzNm5mTzU5aFFNUFBIQktHbWVkZ1VBRVdWZ0ppYnlXNkZZZ0VnKy9zRWt1RWxLR2NVQWFYWXNpT2FCZld4ZWgveElZQS9Wd09Kd0laL0p0UklKOXFXZWh0dmhaVERrOGFzU1JFQVdKbkJaNHNaMWtCSU9pQ0E4dEdCUXYydmdJR2dsT1pZMGJyUlpXV0lhMWhFYjNKZWdJMEQxeVhCNFE4T25zazA4K09SdkJ1VTcwZ0hneVBPT2NOV3RXdGc1dEVwWFovTkIzdElRakN4Y3VURzBpc2lGRXFMM01aSVh5MWlFQXR1UzVBbllxMlorODJBTjlvdzB3bitIMC9WZ3dGK2h2QXg5dG9Rdk9nUDBoTC9wU0RpZU5naXl3YlEwaU5CL3NKQXBKYVNhWVRtM0hVWXBpVWJzUElpTmRkZFZWUFVFOFdGbTRSelRoSlNwKzhqZkxzWTlvNkVnRTVOaVIzeEdJYkpmWm5PTnkzUUpENG9oRXVkTEtSYzdJdDB4Rjk3eWNkdHBwcWIzbzNvb0tUaE5CcTVjQXFmamFCK2JWdDhFNElaem1BdHZqckw0Y2J3M21DRmdDZFZvNGtzTWdRak5RTy9DaHdBZ01GZ1BXa0k1Z0pzcHk3c2dUUDg0eVM4QUlFQm1pOHNIWUVxSU5ENEQ0akpGODBrNk9oSk1ET1RBU2Jld1lHeFBPZC9aRmJmeFZ3c01PSElQQUlBZXhLWlZGemg2QWU3bVVnRlNGMVlqSTdlL2RmdnZ0eFFnZHdlYmlMUnlKa0NWMHRCSHdudHdDQnFXQjhjNEV5bDV4eFJYOVMwNjVRYk9SNDdOMmxFT1hrdGNPY1pRSVRIUkxxaE1KamhjQi9mM1hPSXhiT0dOR2I5NUY1bDFsVWhhN1VwQ0tRVWhzeUhlWmxBakd2ZEo4QU81aDQ0amNYamhiSGhxaHRUTDdWWFVJUWtLamlCUWpZZ2s1VCtaYWpuRGNVeDEyOEV3eXVUTFJGT2NvMVN2ZHQxQTB6MFdnRWhpVHhqcEVJQTZSajBtd1lDTFljUEgwRS8yUnh4OS9QSzBhRUFaaHdscE9VbGdwZHQ5OTkzUlNJOEpTbjhmV3RHdlRKSUgrN1o2Q1BuS09UbG1SMk5xYk1VblhITEc0VHVTMkwvWkxlQkhLcGlVdG9LeTNwUWQ5TWw4bGhJU0d4RklPcFVzWXh6SWh0Q2djQVVPc2lGZWp0OUlJWHNEUmVEZ2xzQ2NXMkFYRGwzVFVGOXR3Umx3aWc4akNLc2huTThtZG84ZjlYc2ovYTVQUGVDaHJUNVp3SUs5M0xtalVUcnNJSUsxNVBpc0lxUm43R2ZUV3VDMmtMdzdyc3dJTHlxRlRDZG1VZzhxUXVlWTEzQzh0RTF4cklTblJSdWVyZnlmc2VFZ2I3SmlZM05xS3dRdnRQTTdsUzFFc0dXemRISkUwc1h3a2kvdTFLTDdOTnR1a1QxNHJja3RYZmxLZk45VWdrOHJUbGwxeFMyQStLRXM3Ukh5Y3ZiYWlVQTZiTVk0b0xhRSs3MDk3SGREWGZyd3IwcEh4TVo2YS9hdWJRazlJL3BiaFd0RGlWVXl3QmpON2RsR2RhWVVmcXlZVURGbUpmRHV0ZGFsSGZ6NlZJR3F4aEt1Tmt2Q0lHT0x3emdNUGxsZ3BjREQ3ZEE1OUl0QS9LMUx1L0RvbmtOMlB5NDQ1YW85ckJBM3RqN0MxN3Ztc2dMYTVUdmthcW9TbU1ZNTdGQUVnbjQwOE5VamhFdXhnYXFjWk9hQWJNZ1NVdDhSanJOYjU3TisxbGNqQ3R6T2tyZ1gxVkI2Q0tDMXErWEJEU1hnUVJEdm9pRjdNTFE4NFdCR2k4cEdRMjFNM1duM1JtMGh0eDB3NWlKcDd4NFNUTEZJdjNzMmhyZ1gxSTBlUFVDVTBqZkR4SEJvc0VaTWNpUWNrVVk3VUFralFrdUxrTU5UUmdDZWVkejRtWVdpYm9NV0pXMkJYQ0F0dGdpV01BN3R6ZHN6ZmZOQ1lZOFBTMDhraDRsL3NyeEhMNisxdHdRa0lYNHNSUlc2K1ZXRHUzTGtqODZCS2FBQkJFUVlTSmUxMmVXSFRNZ29KY2hnSE1kQW5hcWVGZUJDbFpGenNNcW9UMStBZFRrQWZIcWV6NTdCUlgwUVhzUkhJQlpnM3ZmeUY2Sml5OWJ4Y1QrN0l5UlhWbytnTXJONlVvejdYZ0UrL2VGaEh1M3p5UjljUi9vOFBHOCtoODk5RWFBaGhuK2xMT1FFRGo3S2tDdFNQNm5salJNZzVtZUFONkpIckcxQ2Vlb3dyQjJ6RDVMVWF2cWF2aFY4aGFzN0ZQWFJkdkhoeFAyYWJqOXJVN3RSVFQwMC9tVGRBWDdUUDM0d0hrcldRWFMrTGtlUFROMjJRdmtodmY2UmE0Z3B6QlluOVp4Q1ZiK2NjQ01qK1RZUUd2RWVnRG5pWFlSVGt5SU9oeWRPdHdoaEcvN2RPWHdydWdkR2treUtSUjhtQXdDK1BGcFRubmwxaWM0U2tIM1JHb241QWk3N1VqZHBvY1M0THlrY3BuSzdUZnM0bXdPcEtYaXM3UWJpV2Q2MTVjeEtpODNDTUw5R3gzd3NOU2dIQU9xUVgrc2RKQk5ya0c3eTRsMncwY2EwcFFxdEJYbUpwL1o5M1h1a2NlVkNFVkVYM05IazgzV0tuempFV2Vid0g3VWt2RzRtR2dMNXloTGFBR1ByUHJvZ0lpVUVSU0U0N2lLS1RSNHUrMUtVTmJ6djY0THAxcmh3b3k5UEJVa1Nyb1VWWHhvenpvWmVPOWxRbko1ekE2TFZSNmxBL2doeVBvenBPWHZ5N012eU5RN0tSUFB2c3M5TTFBbGRJYUI5dDdPQWVldWloSmtOUmwvSW9KdVRJUTN0c0ZEU0ptanlXcmxkZmZiWHZXMjB4NlNxcmdmdElaRkdLbnZTZEk2QUZrOGZ4bDNUUkpGTzNwYjdRb3UrS0FuMzRNSUJzelppanNVZEFMOG9oa0dVVVhYbEt5Z0VCL1JOUlc5NTdKcWZISWFpRGpkRFg5NnVVeE5aakplQUR6TlJENTVEUWlqWWNkaXN5MGdsSGF2ZmVlMjl2cUJLVU81RmJzZHlnSUkrRWgwNCtmZHFVb1pZVFIyaUpucTBRSVRuVktTMmJmemVJNU5LUE1UTjJQbUZlSXpYQmk3S01zMldlTFVxQkE2QUh2R0RUMnZxZmlpbkh3eGg0aEQ2MERRZUkydmI5R3lJMjk3SXBSNDQ0MWxBbE1EaFNCbklvbnBybHlGUXlRdFFYNVVzNWNRdHFocytCOHRRZHhhbkdnVnorM2dyc2o1VGFFWkZiNTlsaVNPREE3dW9IdTZwZm9yUWw2aEJKYjBsT3RCMFNlaFRpVUtkVU5pSlNaSVFWbVRqYXJlazd4UEFDQnNkbzJHTVUyNHdDT1JCQVQwMmM4bmNMYk1aTFM5YTJFV3J0NUZLd0hMbWpPUjBYNkZNckJxa0daTSs5Mm91a1IvTVQ5YXFid2xhb2N3OEdpcUZ5UkxLT1VETzRSVVI4NmtjVDBnSjB5RTBNMTlDYlB2VjM2eVNpVHkzYVdSc0E2MEFBVzhndXl0OEZhelB5L0ZKZnBYWnlZSnlVajFhalVZTERVSGpiQVBwQ0w4N1dlYnpQNytucjJpYnVoWVJ1bVFRUExSc2V1ZXVDZFlSV2c5dEo5TVFmcXJkQW0ralJVcisxYkd0NlltMEF2QU1CNm11VFp1ZG5LRWx0T3kySXpwSmJITGtWdEZWcXo5dkd3bkpyNmRLbDNmOEF4Ly80WHdCRmtyTUFBQUFBU1VWT1JLNUNZSUk9HwRnZGQCBQ8WAh8EZ2QCMQ8PFgIfAAU8UG9ydGFsIGRvIENULWUgMjAxNiAtIENvbmhlY2ltZW50byBkZSBUcmFuc3BvcnRlIEVsZXRyw7RuaWNvZGQCNQ8PFgIfAAUZQW1iaWVudGUgZGUgSG9tb2xvZ2HDp8Ojb2RkGAMFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYGBQ9jdGwwMCRpYnRCdXNjYXIFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDIkSW1hZ2VCdXR0b24xBSljdGwwMCRnZHZMaW5rc0Rlc3RhcXVlJGN0bDAzJEltYWdlQnV0dG9uMQUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwNCRJbWFnZUJ1dHRvbjEFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDUkSW1hZ2VCdXR0b24xBSRjdGwwMCRDb250ZW50UGxhY2VIb2xkZXIxJHNvbUNhcHRjaGEFJmN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkbXZ3Q29uc3VsdGFzDw9kAgFkBRZjdGwwMCRnZHZMaW5rc0Rlc3RhcXVlDzwrAAwBCAIBZL3zTwsZFyaf5DwrmkJ+GuFXgspr">-->
                            <!--<input type="hidden" name="__EVENTVALIDATION" value="/wEdAA8XUIqL0e40X3wtWkmKsSGjBGqPhwrln+9PTG+a425C4DQnJFM/mcs/d0VTMpMTYCGeOO0tTX51je1QOUgbhAXiTo1Ol8i+hK4G4Vo+jsDQOY8aEJZjnoPmyZdMj0cTDps02TTrU70chmk+oYZUyBFDMV5rQ02/s0ktp46Gfiy/coJgn06mMihbVjkI1u74QCeCfTspHnKMom4WREfNoQeM7H30DjvuZHqRE05bVtqWSK4WtomhoGXCF4LhXZ/AhS3F8ZLI9es9wT09XJsh63BVkk7aCjzv+b7H1Z/ScSHD8UECwoJkW1gYXPEUT0l3HnsaWPG8UM8hCYYBmaAm6WVJArcVgw==">-->
                            <!--Produção-->
                            <!--<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="/wEPDwUKMTUzMzExNTU2NA9kFgJmD2QWAgIDD2QWEAIJDw8WAh4EVGV4dAULNDA1LDQwOCBtaWxkZAINDw8WAh8ABQkxLDUxNyBtaWxkZAIPDw8WAh4LTmF2aWdhdGVVcmwFFWluZm9Fc3RhdGlzdGljYXMuYXNweGRkAhUPDxYCHwEFNH4vUGVyZ3VudGFzRnJlcXVlbnRlcy5hc3B4P3RpcG9Db250ZXVkbz1sNWltT1ZsRHFQVT1kZAIhDzwrABEDAA8WBB4LXyFEYXRhQm91bmRnHgtfIUl0ZW1Db3VudAIEZAEQFgAWABYADBQrAAAWAmYPZBYMZg8PFgIeB1Zpc2libGVoZGQCAQ9kFgJmD2QWAgIBDw8WBh4NQWx0ZXJuYXRlVGV4dAUrTWFuaWZlc3RvIEVsZXRyw7RuaWNvIGRlIERvY3VtZW50b3MgRmlzY2Fpcx4PQ29tbWFuZEFyZ3VtZW50BSRodHRwczovL21kZmUtcG9ydGFsLnNlZmF6LnJzLmdvdi5ici8eCEltYWdlVXJsBR1+L2ltYWdlbnMvYmFubmVyX21kZmVfT2ZmLnBuZ2RkAgIPZBYCZg9kFgICAQ8PFgYfBQUXTm90YSBGaXNjYWwgRWxldHLDtG5pY2EfBgUdaHR0cDovL3d3dy5uZmUuZmF6ZW5kYS5nb3YuYnIfBwUkfi9pbWFnZW5zL2Jhbm5lcnNfVmlzaXRlX05mZV9PZmYucG5nZGQCAw9kFgJmD2QWAgIBDw8WBh8FBSlTaXN0ZW1hIFDDumJsaWNvIGRlIEVzY3JpdHVyYcOnw6NvIEZpc2NhbB8GBSNodHRwOi8vd3d3MS5yZWNlaXRhLmZhemVuZGEuZ292LmJyLx8HBSV+L2ltYWdlbnMvYmFubmVyc19WaXNpdGVfU3BlZF9PZmYucG5nZGQCBA9kFgJmD2QWAgIBDw8WBh8FBSpTdXBlcmludGVuZMOqbmNpYSBkYSBab25hIEZyYW5jYSBkZSBNYW5hdXMfBgUaaHR0cDovL3d3dy5zdWZyYW1hLmdvdi5ici8fBwUgfi9pbWFnZW5zL2Jhbm5lcnNfbWFuYXVzX09mZi5wbmdkZAIFDw8WAh8EaGRkAi0PZBYEAgEPDxYCHwAFCUNvbnN1bHRhc2RkAgMPZBYEAgEPZBYEAgEPZBYCAgEPZBYEAgIPZBYCAgsPEGRkFgBkAgMPZBYCAgsPEGRkFgBkAgMPZBYIAgcPDxYCHg9WYWxpZGF0aW9uR3JvdXAFCGNvbXBsZXRhZGQCCQ8PFgIfCAUIY29tcGxldGFkZAILDw8WAh8IBQhjb21wbGV0YWRkAg8PDxYCHwgFCGNvbXBsZXRhZGQCAw9kFgQCAQ8PFgQfBwXmQGRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBTFFBQUFBeUNBWUFBQUQxSlBIM0FBQUFBWE5TUjBJQXJzNGM2UUFBQUFSblFVMUJBQUN4and2OFlRVUFBQUFKY0VoWmN3QUFEc01BQUE3REFjZHZxR1FBQUJmUFNVUkJWSGhlN1oxWHFHVkZGb1l2Mm1adFU3ZFoyOVkyWWtKRkZITVd6S2lZYzg0NUs0N2FiV3pzeG9EVE9HTEdSZ3lJSXlLMmlBNG9PZ01pUHFoUGJUTVBDdk1nd3p3NE1BOTd6bGZjZjd2dXVxdHExejduZG84UDg4UGluck4zaFZVcjFhcXFmZllkbXpGanh0L0d4c2FhR2xwdHRkWCt2ZnJxcS84S3JiLysrcjk0bWpsejVqODIyMnl6bnp6Tm1UTm5xYVZaczJiOVBXcS9pOVplZSsxL3paNDllOWtKSjV6d2w2dXZ2dnJQaXhZdGVyRnBtaitzS1ByMjIyL24wK2M1NTV5ejVOQkRELzByWTVrMmJkcC9JbDVGakoreThQdlVVMCs5VFAxbHk1WTlFclhQOWVqK0w3LzhNamRYeHhMbHFGL3FRMVRUWm82ZkZVR3Z2UExLbjZMclhUUTJmZnIwZjBhSytGL1J3R2liOWRaYkQwTm90dDU2NjJiSEhYZHM5dGhqaithQUF3NW9Uai85OU9iZ2d3OXU3cnZ2dm1xNisrNjdtOXR2dnoyOFZ5THEzSHp6elJPdVhYNzU1YzNGRjE4ODRScEV1YlBQUGp2eEJyL3dINDFOeE5qT091dXM1dDU3NzIxZWYvMzE1cE5QUG1tKysrNjc1dXV2djA3dGZmSEZGd1BkL0laMzNua25YZThDYllnbjJpcWhwczBjUHlYOCt1dXZhVHpRd0duR3IvWURkWkhUQ3krOE1INmxIbU40NnNNUFB6eEJDWWNjY2tqejhjY2ZOMmVlZVdaejBFRUhOWGZlZVdmejZLT1BOdWVmZjM1ejdMSEhKc1ZKZVJpZHBVMDIyYVJ0NS84MFBLRUQ2SW9ycm1oT1BQSEVKSGNVdlhUcDBuSFY5WWMxVEl3bFo5QVlwVFZHUHRjYVp4K255Z0ZIUndiWVgxK01EWWhRM2Z6MDAwL05CUmRjTUVHb3A1MTJXdnY1alRmZUdNbnpHSnpxaTU1NzdybTJmYUt2QkpHajg4NDdyOWxycjcwbVJNbGpqam1tVlg1RWNqcC9qVDYzMldhYkNkY3RiYi85OXMwZ2pVcU92c01PT3pSSEhYVlVjL1RSUnplSEgzNTRjOHN0dHlUbkhxUVN6Zjc3NzUvNE9PT01NOXE2VVo4UXM4eHV1KzJXN3RIdVNpdXQxSTYvTDlIZThjY2Yzd3hTbWVhRER6NUlSbGdDOHFhZW9oNzZ6aG1jajk2VUc5WTRoOEhMTDcrY2VIM29vWWZHcjB3RXZQaFpBMGZIbVZxREZoaTRGRzVKQmdUVkRzNTZ1dmQ2Z09EVS9yUFBQanNsMHhXZ3J0cVE0alJnOE41Nzc2VlVwQlR0U2hGTVVZakllY2tsbDB6aW1YYTdwbW54K05sbm42VytMcjMwMG1iTExiZWNJSE5MZy9WTGVOM1N2dnZ1bS9paVhROVNHOG9zV0xCZy9Fb01aSFhQUGZka3gxNEQrcmNPMWxldmxDZHJVRmxyd0Rpdnhpdm5SSWE2TnNtZ0JRWnUwNUJ6enoxM0VqT1Jwd0FOeUhxNlB2dkJ3WlNNZVpUcGlyWXdYdjR1V2JJa3RTSGVhRXZqdVBiYWE5TmZCRlpDTG9MUnZ1UkFHWTJyTDgrVXRUeCs5ZFZYS2VxVGoxOS8vZldKUndMTFlBSGU4bTVwNVpWWERxK0xxTWVzZ1NFalcyOGtFYXl4M0gvLy9lTlgrd0Y5VXQvS0Y3MXEvVkdTa2V6R3d2TDB6RFBQcFB2WXBoMExxWW5LWkEwYW9EQ21kQlVtUDZZRDhPNjc3N2JYNVNuQURvalBLRTNYK1R5SzBaYWc5bTJmZ3AwSm5uamlpWFIvMkZ4MDhlTEZhVXJzZ2pYOEdsZ0Q5OUdVZTZSYnUreXlTMHBYTkJaUDY2Njdibmg5MVZWWGJZMjdoTWhZK29KNlhyN1dLQjkvL1BGMnByU3dkbVB4L2ZmZk54ZGRkRkZLOVQ3NjZLUHhxeFBCaktMMnh3WUNYUERERHorTTM0cEJaM2F4UjY3OTJtdXZwWnpTRDk0T3lFWTVmZVo2TktCaFlHY0hUZlA4WmVCK2VtTU1tZ21HUlRUZFdkQWY0d1NNVldQdml5aWFlbGxpbkRmY2NFUEs3OFdUcDVrelp5Wmp0dGR3Q0l6V3R1MWg1VG9Wa0tOY2Q5MTFMUjhFR1F0ck53TGp6WlVYckU1dytySEJ3dThUcG9NdTBLRmRORzY2NmFacEd1bURHZ1lqV0VNUk1GamFpUXlMZmhUdCtpQ2E4aXk2SWhpODBPL3lCbjJUb2lndzhQM1ZWMTl0OXRsbm4yYWpqVFpxWlZ3aW9qa09ZUTBJbE9RNkt1eE1TWERwUWxTZXNWclplNTJNZmY3NTV3djdLSjZCS3EvRCsybXNCZ2p1NmFlZkxnNklNcm5weUJ1S3BtVld3bmFBdzRJK2FBL0JJQ1FVNjZOOEYrRHAwMDgvSGYvMkc3b2NCWlIwQUErV0YvSmJ5VEVLREpUak9nYkxibzNLNW9pMFVvWWRwVHVqUm14NC8vbm5ueE5meURtYUtYTXk5K1hmZi8vOVlqQnNjK2crU3NUb1dGRkxJT1JubmtGcm5EWXlzeWlMQmxTSzNyVGxoVXA5akk4VkxuVzd3SmhLWStPNnBqejQ1ak5VMHphd0RtR1J1MjRCWDVSaDBlTm5JZ0FQOENJWkxGcTBxSlZWRkJnRU94MGpkd3ljUXlwZDgwUTZ3b0hTbFZkZW1lUmg2M085eGpZOE5IN1NEY1pCL1dpTWtjeTVScCtSSFRFalJXZ051cThTTWFnNzdyaWo3UUJCaVZIYk1jWUo2YnRWQU9Xa0pGK21iMVRJUlhlQnZoaGJsRitEUGc0ZGdUcTByMGduNUs1YktDcXlXbWM3a1RwUWlaZGNwQU9xeThKZGUrZnNnYk4zTFJtTDFsaGpqVW5YSUdaaDl0NlBPKzY0dE1PbDA5WXZ2L3l5NVlrK292NHRLR3ZIRDk5OHo4R2ZoVUJjQTlaR2JydnR0blRObzdqTFVRT1VvUlNFaFNPR0V4bXdWMEMwd0ZLWkR6LzhjTUoxaEpKVExQQU9WSUlNMnp0TVg0ZWVTaUFUSXZnMzMzeVRUbVF4SG1hZWlFK2d5Q1hqUU9FWWEzUiswRVhVSlIwNDVaUlRpZ2M5Yk9FeUUzTnl5YllpZlhPOU5QTUE5R1lqTW9hZEN5cWdaTkJBTnBKenBKRU5HaUIwN1ZtejJHRHFoSjU4OHNrVUpaanFkRm9tNHJTTjdaaWJicnFwZWY3NTU1dVRUam9wUlh5VUZlVngzc2grL1BISFJDQTNBOVRBQzd3TDhPR05EQ1hCQS94RVN1SithZmF3UUdHY0FIS0t5dFNQd2VvMDFKNExUQlhKV0JnWCs4UThTOE4xZGd4S0tjcDIyMjJYMHM0WFgrVDVzRHprZEJiMGxYUFdMb1B1UW1qUUtBWENDL0NrbkRkWm9EVHRrZUxwdzBRTENNTld4Q3IxeVg3d0k0ODhraFNOSStoNUI2Szdud29qSXhRaWdRdStuV2hXb1cyN3BZbEI4TWdBL0ZPZis3cG5ady9HSnJuU0xwR3Z0TWU4dkFpakZUOEVFdkdBVEFVY25uc1lWblNhcVVNY1pPS0RBM2FSazcxQTM2cEhIM3Z2dlhmaWcxMGJIdUs2NnFxcnNudlFIcUZCb3dTb2RocUdJUVkwZmZyMFNZTWRobXFCUVVUMUlRUUpJaU8weUFtY3N0VEJNT1hZT0F1N0tuSTJtMjdWa0owOWtDZHlKY1dJeW81S09KbG1RL3JKUlhkeWF4K0ZLVnVhVVhCTWNuMkNUelIrMmtOR3BFMXNMeUk3eHA2em9WeFFnUWVlWWxTN1huL29RRUZCbUdUUUZMQlJxUWJSTkNIYWZQUE4wMzBZNWdFa1hjOHRScUJhMUJnMFl5bnRIVk11VWg1bDRWbjMrUXhKS2JRWDlSc1JzNGZ5UHQ4ZmdTQ3FVeUtNRmFOaEZ1U3BSdzVYbVA0UE8reXd0Z3ozWk5CMkJpbVJJcTFrbDVPTkJXVndTaDdVNmtxSlNFTWowQWJiblZZL3lKbEFVOUtmZ29JTlNCTU0ya2FsV3FpT3BhMjIyaW9SbjVrNkpDQkFlWlFMY3pEcTZ5S1VXakFnRkxmRkZsdE1hb2ZJVUFMT3dJcGQ1VzA2SUdFS1RJZVVoNGpTUkRYYlZ4ZHhZaGRkL3owUWhvaFJNRFlMWktBeUR6NzRZSnFOS0Vkd3drbUdTWS9XWEhQTlZOLzNCWkEvN1dQQWR0WTY5ZFJUMDNVSVordGE3eVNEbGlmYXFGUUQ2dmdwaDJoQWZUcFdaR0R3M3JzRUg2R1UwOVdDZmhDK1JXNEtveHpDSkYrbEx4N2xWTDhjUUtBb2UrMzNTRGFWaUVqS2gzallpVHJzbXRobmNrU1V4L0ZmZXVtbDFtQ1JEZGVaV1gzNXFhUjExbGtuQlQwZUI1NHpaMDVZSnFJdTJ4eDcrKzIzLzZqQ05rcFo1Sko2ZTdnaVFpZ3Fqd0ZwR21LS2pJd2FqNlFPaG8waDh0MkNPaGd0ZnpIR1hCdmNnNGo2YkN1ZGZQTEpTVEVSajh1TFdKUkdrWXZGamZqRHVHNjg4Y1oyOFNwUzVPR3pydzhob3h4WUo1RFB5cUFsUTR5VXVzZ0VuVWdXT0FXTFBrN2RiQi9MZzlDLzBpMzRZVWFJeXRWU3lhQ3hqYkY1OCtZdFZtRzdhQkVrWUl6TkF5R3Fya2piUGp3R1NWMmVQVllVeHhQdE13ZzFVTFJsUjJQMzNYZFBLY2FNR1RQU3o1ajRhL3V1cGRtelp5ZkR3d0NVMzR1UWdZd013aWt4bUZKK3lEM0tna2dtR0ZJSjlLRWdRRHUrUGdSdkVTS0hWV0RDaUhKckIwQTVYemRIbWhtSTlKSVZUbEZhRkJQdGZkOTZmSGRZS2hrMHRwSlNEajdJaXp5c2x3c3d5Uk42UEhmc094Uk5tell0UFNqRGdvVnB4Vy9hazVmSkNFcGdBT3lQMnJvMXhJNExRbWRzOUNPRFlZd3NUcnlCY0oxeWtGVUNjb25hRitFWTFrR2pCVEpsYUo5MkdZOHQ3M2RoK2hnMGJVVmxNYnBhRUhpaU5qZ2xST2R2dmZYV0pLTmtOb25HS1NKOTgybWdRRnVjWExMWGpvT3dSZWQzV1RpZDFJNlN2UTV4WGZ6d21VTWhJY2xqOERjdENtMlVzSWk4SE1HemNwZW5scnkwaG9odzVNNDU3OHNwdVVRWVVRU2lFa3IwQXNmSU5CN2RVNjZkSTZLalZ6YjFmVG5HUjc4OG5haHJOb3JxZVYvYXlvMlZoU2ozVUtJY01tZFV1YkZIUUpjRUg5OEdENUo1ZVFDT25FdXpGY1NCbXBkTEYrakQ1dm5JWG1zQVMrSUh2dmxPQ21QN1NnYmR0VmZyZ2VFTmN1L1dBZkJZT3RJaWNCU3lHL29XUEpERG5pVDk2T1JNRkIzaTVKVEsrR2lqQkFSRTN1dmJ0TVFXR2RGQmtWZkliZWZScjkyMnRPbWQ1V2tZNS9WRUxsOEwrdVo1RHhrcHNvemtneEh0dlBQT2svb1NvVGNjalhIeCs5TXVHVWVnRDdYSG9qUXlhTW1hdndSVm9ybjY0bG95YUpUQzlJSXl5SG41UGd5b2gwSWdJaEFkUVVjY2NVUmloaHlhWDVHdnRkWmFreGkxWkNPQ1VESkU3dmsyY2dZZDdZcFk4RHhGMTZyN3dnc3ZUTHpnMEJxbkVQRUNzWFpRWlBIcG5lVnBLZ3lhMHpVdE1ydGcrOFlnL1BFOW56SFdxQitJNEtJVWlySlFTVmNSa0FYT1lFOGhtWkhzajZoRk5vdUFkeDZsVlYrTW8wMDVnSlRSWngrNkJqQ3N0RVY5OEp4Qzd0Y1dMS3c4U29ZWUdWR2ZhVmRJQW5IdGVHSVdRb0RNYXZEa2xXZG5PMHUxQytGSWlYMEpZOGdaRkRySUdUdmo1NUVDeVJsbnpjMjZHMjY0WVpzMkNmdzBqYnJTRlRPNUFwd1BrdkJCZms2ZXpLL3ZiZHY3N2JkZm12MGk1L2J3ZGpIQm9Pa0VRZGhjbHNKUmJqMHNZSlI4bVVnSW1CbjhncEZwRDE1cU1WVUdqWUo4TzEyMHdRWWJORHZ0dEZPU0cvVWpYaUNVSTZEY2FIdzVaNENRaWQxaElFRHdOeW83ZCs3Y3JNNjhBM3BRRC8zYmZOWVM2eVhxZXdPVjhkRStiZmcwa0pRRzQ2TmVhZnZPL2dxcXhxQXRVdm5CM3dsSDN4YWwzRnJHRCtNWVQrMkJDRXFIYVhtVi9aMlpKUVRIb3NkSHRzakJJaU5pMHo0WGlVcVF3dG1GWVcvY0syWllRb2tDTXJCR2haSlJCZ3MrWG9zUTFmZnlCOGpDbCtOMUI5N1lMRERXbkxIVFAyMnNzc29xazlxRm1EbXBMMzRoT2FaMnczaFBDUGJnNjBKc3Uvb0ZwZmJFK1RHc1puR2haTkNVcy9wdGJXRHdPV3ZRTUs3YzJrY1VETmgzUm01SkRtWUg2a0hIREpwMjJiTHhiU0EwUDgwUkxUQ0NuSU8xZ3pIRUhyVTFtbEZtR2lrUU9lQmtmcHVwaGxBeWlzTWc0TmZ5Wm5kWWNpbUhIYThGK1RneXcxQklOVmc0RHdQR3g5NSsxRGZCQmVjV2p4eGF6Wm8xS3dXTlhKMFNxVDMwV1VMT29KRWhxWXFWSWZiRzk2eEIwMWpKMDNOYk56eTNnS0UrOE1BRHFRMFJ6T01FcFplcFlDZ0NDdlNlamhCWmtiTjFaQjBtTW1pZTc1QUJsMmFhdmtDWW1qVVlGNDZKa2ZjNWtZUUh6VkFldEptcmt3T3lJSkJFKyt0ZElNcVY5cFNua25pV0EzbmxncDJIbHdVT1pHZWxlZlBtdGZhbE5pY1pORGM0bnFVQ0VjbERrVTZOamtxY0xDSlFJbkFFak5FLzd3RVJ0VFdOUndaTmxOZEFTek5OSDFoaDV2aEZOcm1GbEVoN3loRXZYb21pbkVGVG5vZXNXTXh4MENWSDRmbmhtckZHc2h1VmlNQTRPSC81emt0eENFU2tOSDNnWmNHYkJwQzd2dU84MkNxa2NVOHlhRzVRZ05NNW9wRUZ2MDVRWTdrOHE0WVlLSTg5NnJ0WEZnWW9aVEFvRnBMejU4OXY5dHh6ejdTNjltMXhsRzJ2NlRydm5lT1hGK3huUW93TElVQTRRMG5obGdmQkNwT3BYdWtCTTRrOUZvNW1MMllmOVUwNy9JMVNvRDRHTFdOVTRGRjdhcVBtN1VjbGc4WW90ZGZQMkhoR2huUVIzaGN1WEpqR1QxK1FseFZsYUFOWmNIOFllRmtnWndEUDJ2ckVYaUg2WjdZcDV0QVVsSkQ0ckliNTBTVGJicll6U3h0dnZQR0U3d3dLb1JCcE1TUVlLVVZOS1h6VWMvOHU0alFxQi9IZ0lXSGFOMGZWVU83aExBc1Vna3lpK2l4T1pWelJES0F0VVBqVEFvMjJ1a0NmTWtvZndDeXMvcEdOaDNkT0xhWWpHZElYK3U5Q3pxQWpNTzdrUklQUG9VSDd2Tk5ISjVTRHdHaUVvMDQyODNXZjEyMEJoSVVnZ0NLZWRSSVBlWm1ZMjNYWFhkczJsd2ZSRDN4Sm9mUXZZWXVISE9TUXpBSzFMM2RoMWlDOWtrd0E3ZUJZVTdXYnd0cUZOZ2tVb3h5U2VYajlXOGp3a0JtZ1Q2VWI1UFZXMzVUaGVwVE9lcVEzSVkzM0NlSE1ncmNqbkpIVDY2eEJTMkUyZ3NLTVFqMWdJV0pmSThaOWxNUFBjendRU09ubk5JQnJHSkVjQVlZVmxlekFJRVVwVHZXNHoxRTFDMEgvNml1ZVUrRElscFNEdGhtVEZZVGRZZEFMWEJpemRjWWFvRlIyTWVCRnlzd1JrVVl5cGQrb3pEREVRMkJXVjF5ck1aeGFlUDBMMFl6Z2Q0S2tiL2hqektYWkFFUVBwTW1Sb2tVK3VrclhCcCt6S1VjWE1BRC9PakFacFFmWE1YVHZKQllNTWhlOVBTUkVGaHNlREpoSTZBMExKOERoY29aYUsrd2E4S3d4NzlsZ3JVRCthZE1FUG12OE52TDFJWndYeCtDQUFwbHFUSnBoY21QaE8wN00vVWdIdzREK3ZFNjFyVXRBMFl0cmFzRVkrS1dLSHpOQkJ0QWZidzNnREVQdHRuSWNmRTRHTFVQU2dHdGdEVkFSVlpGTlFoWDZScndTYUpjVk00dVUwcStCNFFIRGozWkpNQWFFN3NkSzJ4SmNEWEx5b2gyT2R2bWhhQmVRbTdiY0lJd0RwZkpUSkhaRUxOK2xBeXlDQm1WeVVSbjVxeDNTUXVsc3FxRVVoRjBKL2lKcjYxaDhabGNHUGpWbXhzWHNGcTBQSU5aVHlNamFsRWNhLytEdkg4UkExenZUY29pbUFPckQ2UElBaXFCdGNxWmE1ME1RdkFORWZGb2lmNlU5Mm9wbUdPK2NNbUpySUY1ZTRySEdZQ1IveVk2K29weWF4VFZwVFE3VW8wOXJQQloyTm1ENjl2MU9GVFI3OHE5TXRPTWpvN1l5cXlIcTI5OFlNdjZTVVNlREZnTThsNnVLUHZFdmdXakplMy90dEJNWnhsUWlNaVlNRHlXeEdDSy85K0ErMC9OZGQ5MlZJbFIwR0xMdHR0dW0vTTA2aW5WTzJ5L0MxZWMrOHZMd09TZ3BpdHJsTS8yWGxCaUI4c2pDMTBNdnlvTjl2NnJETmlrNjVUcXk3TnMzYldNTDZJQ3RQVjQreERpNHpqdnBOTFlTb1J1ZHJFcHZ0RW45a2wwbGd4WURNRzRIREJTTkxPdzF5c01BOVFFS3Q2bEhEZWlycjlBd1NBMWUyMjg4b3NuaWp5TjRwclF1b0R5ZUlVQlkwWEcySXJjOVp2VlJ6c3BybUhFQUszOWtxL2FaK1dwQVBaOG1JWHQ0THMwUXRsK2dPc2lPL1dieWYvdmNUVi9ZOXVnRGVVTzMzbnByZW1iN3dBTVBiSTQ4OHNoVVJzU1k0Y3ZDMnh2bGNpZ3VDbUZJd3VWaEhUcXkxeFE1NklCT285U2pCallDMXNJYTFtT1BQWllFVlhvZm5JY2NrZklZQStQQUlYTEd6WlJKV2NadmpkaGltSEY0TUE3NlkwRXJSRUhGb2t2Skt3SXlXRG1IMXdIOHc2TmthTzlUSjNKSXluaDc2d3FVa3d6YWRtU05CdUlmMjF4MjJXWHRkNVFLSkhBVXJLbEJBNnVCRklKQXZKR1VJTVBpNkpmNk5ZWXN3QjkxU0pYNDY0MkNNVEdXNkxVR1dsRENyOFZVR0paVklJL1llb1ZhU0Y3dzJtZnNVd1ZrS0QzRHAzUWdwMFFlQW55cXJML3Y1V1lEb3oxY2s3MlZNTUdnMVJHclNZSE9tTjdaNU9ZTmxRaVZuNzd3ekMxTWxnUmVDN3pPN2dHUEFpbTVGaklHYnhTTWkrK01pZDJVWE9SbTBjSVdJZmtvT1NQMVJnRks1eGxyMm1acnlnWVZ0ajNGSTNyaDJxanlHZ1dNTlJxdno4MEJOc1RhQlBqN1h2Ym96d1pHeGhyTmlCR1NRY3ZUMUJHQzlJQnhlYUNGRlhpTkI5RVBSc2RmQzc3VFBvUFRkejhOZFdHcWxHd2pCRXF3MFFPZUdHZjB1Z0xTQks3RFIxL2VCZVNzclRxMnNGQWk3VjF6elRWdFA5cSs0dGtVZE9abDJRV3Z3NmtHUE50WjJxZWkvbjR0cUlmdFJQWWpKSU9XcHczYlVSOFB5am1HQjIxYVE2b0JmRnVuR0JhTVF4R0NrMUI0amtCL0dCVDczTnFlc3NSS0hibVU4dDhJT0lNT2hSVEZ4Sk5lUGc0aVdYYkpWYk13OGgwRzlNbFByV3FkZ25Md3pwRzhQUWl4b00ydTl0QXBoMVdNRjhycHBMZ29GR0NveXpPNFYyUFExQysxSS9ocFNPQjZYd05aVVNBU3NlTkNqbTBORytJYTl6Q2tHb2ZUU1J0UjJxTGs2REpXZG1VQU10Wk1vYzhZRm1Ya0tEV1F6dDU4ODgxMlBGQ1hVN0RsMTFYT1JtOW1uc2cyTUY2VjZVcHIyd2p0amNjYU1hdi9rbWZBTUozVlRQWFVwNTJjUjlKZnpqRzZCa2E5TGtkWlVZQlg5bEdqdkJ2Q3dNbTlrVjNrb0RaS28zU0I2NUVPQUcrWFV2dkl4eG8vbi9WYUFMYmoyR3V1aFhUR3FTeE95WTlZbVNXNlpFMVoraXM1RHpyVGJKamJwZXFUMW80TkdudFZoYTBuK1cyV0VoZ1k1VWFkNnJzY28ydGczSWVQM3hzd1FsSVRERGgzdEF0eDlFc1p4b0F6eUtDdFhnUms3ZzJLOTJHb0xlUmpaemsrS3pwRFBGL1JGMzFzQXJESGI1L2p5QVd4R2lDRHJyU1dlMk9EenViS1E3eUFhaEFKZGxqUVRzNHhFQ0FDS1EyTWU4dkRvSE9LZ005aDBoLytCWWNNcStzZEpVUnlLdzlreEN4R05JdU1xaVFmcm5VOThXaWh2b2JWcjYzUDM1bytMZUNYZXJVOG9Jc0pPVFNWbEhONVNLazBib1dGVUx1OFZjWTRMUHdxT1lmU2RHemh4MUJDVGhIMEk1Nmk5S2NFdjdlS3dUSkdwbkcyUiszZU4vdmtGdlNMMHc0clQzVE1LU0JuQ3RIakFSYWo5bVhyYXdlTldhSVdmV2VFcG1tYS93TGZ1YWEvRDZPcWp3QUFBQUJKUlU1RXJrSmdnZz09HwRnZGQCBQ8WAh8EZ2QCMQ8PFgIfAAU8UG9ydGFsIGRvIENULWUgMjAxNiAtIENvbmhlY2ltZW50byBkZSBUcmFuc3BvcnRlIEVsZXRyw7RuaWNvZGQCNQ8PFgIfAAUZQW1iaWVudGUgZGUgSG9tb2xvZ2HDp8Ojb2RkGAMFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYGBQ9jdGwwMCRpYnRCdXNjYXIFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDIkSW1hZ2VCdXR0b24xBSljdGwwMCRnZHZMaW5rc0Rlc3RhcXVlJGN0bDAzJEltYWdlQnV0dG9uMQUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwNCRJbWFnZUJ1dHRvbjEFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDUkSW1hZ2VCdXR0b24xBSRjdGwwMCRDb250ZW50UGxhY2VIb2xkZXIxJHNvbUNhcHRjaGEFJmN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkbXZ3Q29uc3VsdGFzDw9kAgFkBRZjdGwwMCRnZHZMaW5rc0Rlc3RhcXVlDzwrAAwBCAIBZGUrsv98vKrSgGbIp2TBiNbd/kAp" />-->
                            <!--<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="/wEdAA8AueGY+4WrS2U8oTPkH0RNBGqPhwrln+9PTG+a425C4DQnJFM/mcs/d0VTMpMTYCGeOO0tTX51je1QOUgbhAXiTo1Ol8i+hK4G4Vo+jsDQOY8aEJZjnoPmyZdMj0cTDps02TTrU70chmk+oYZUyBFDMV5rQ02/s0ktp46Gfiy/coJgn06mMihbVjkI1u74QCeCfTspHnKMom4WREfNoQeM7H30DjvuZHqRE05bVtqWSK4WtomhoGXCF4LhXZ/AhS3F8ZLI9es9wT09XJsh63BVkk7aCjzv+b7H1Z/ScSHD8UECwoJkW1gYXPEUT0l3HnuOw6NsTdoqKNe529x9Pxf6+/LpYw==" />-->
                            <input type="hidden" id="chaveConsulta" name="ctl00$ContentPlaceHolder1$txtChaveAcessoCompleta" value=""/>                        
                            <input type="hidden" name="__VIEWSTATEGENERATOR" value="" id="__VIEWSTATEGENERATOR">
                            <input type="hidden" name="__EVENTARGUMENT">
                            <input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="" />
                            <input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="" />
                            <input type="hidden" name="ctl00$ContentPlaceHolder1$btnConsultar" value="Continuar">
                            <input type="hidden" name="ctl00$ContentPlaceHolder1$txtCaptcha" value="">
                            <input type="hidden" name="ctl00$txtPalavraChave">
                            <input type="hidden" name="hiddenInputToUpdateATBuffer_CommonToolkitScripts" id="hiddenInputToUpdateATBuffer_CommonToolkitScripts" value="1">

                    </form>
                </td>
            </tr>
        </table>
        <br>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td>
                    <div id="dialog" title="Chave de acesso">
                        <p><label id="dgChave"></label></p>
                    </div>
                    <select name="campo_consulta" id="campo_consulta" onChange="javascript:habilitaConsultaDePeriodo(this.value=='s.emissao_em');" class="inputtexto">
                        <option value="s.emissao_em">Data de Emiss&atilde;o CT-e</option>
                        <option value="s.numero" selected>Número CT-e</option>
                        <option value="pedido_cliente">Número Pedido</option>                        
                        <option value="ft.numero">Número Fatura</option>
                        <option value="numero_carga">Número da Carga</option>
                        <option value="ma.nmanifesto">Número do Manifesto</option>
                        <option value="nf.numero">Número da Nota Fiscal</option>
                    </select>     
                </td>
                <td >
                    <select name="operador_consulta" id="operador_consulta" class="inputtexto" onChange="javascript:habilitaConsultaDePeriodo($('campo_consulta').value=='s.emissao_em')">
                        <option value="1" selected="">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                        <option value="11">Igual &agrave; palavra/frase (Intervalo Entre)</option>
                        <option value="13">Igual &agrave; palavra/frase (Varios Separados por Vírgula)</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De:<input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" value="<%=dataInicial%>"
                                                                   class="fieldDate" onBlur="alertInvalidDate(this)"></div>      </td>
                <td>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">Até:<input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" value="<%=dataFinal%>"
                                                                    onblur="alertInvalidDate(this)" class="fieldDate"></div>
                    <input name="valor_consulta" type="text" id="valor_consulta" size="27" class="inputtexto">
                    <label name="divIntervalo" id="divIntervalo" style="display:none"> e </label>
                    <input name="valor_consulta2" type="text" id="valor_consulta2" size="8" class="inputtexto" style="display:none">	  
                </td>
                <td >
                    <label for="statusCte">Status:</label>
                    <select name="statusCte" id="statusCte" onChange="consultar()" class="inputtexto">
                        <option value="P" selected>Pendente</option>
                        <option value="E">Enviado</option>
                        <option value="C">Confirmado</option>
                        <option value="N">Negado</option>
                        <option value="L">Cancelado</option>
                        <option value="F">FS-DA</option>
                    </select>
                </td>
                <td colspan="2">
                    <div align="center">
                        <input name="apenasNaoImpressos" type="checkbox" id="apenasNaoImpressos">
                        <span class="style8">Mostrar Apenas CT-e(s) Não Impressos</span>
                    </div>
                </td>
            </tr>
            <tr class="celula">
                <td align="center" colspan="2">
                    Rem.:
                    <input name="remetente" type="text" id="rem_rzs" value="<%=request.getParameter("remetente")%>" size="35" readonly="true" class="inputReadOnly8pt">
                    <input type="hidden" name="idRemetente" id="idremetente" value="<%=request.getParameter("idRemetente")%>">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');;"/>
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os remetentes';">
                </td>
                <td align="center" colspan="2">
                    Con.:
                    <input name="consignatario" type="text" id="con_rzs" value="<%=request.getParameter("consignatario")%>" size="35" readonly="true" class="inputReadOnly8pt">
                    <input type="hidden" name="idConsignatario" id="idconsignatario" value="<%=request.getParameter("idConsignatario")%>">                    
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>', 'Consignatario_');">
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idconsignatario').value = '0';getObj('con_rzs').value = 'Todos os consignatarios';">
                </td>                
                <td align="center" colspan="2">
                    Des.:
                    <input name="destinatario" type="text" id="dest_rzs" value="<%=request.getParameter("destinatario")%>" size="35" readonly="true" class="inputReadOnly8pt">
                    <input type="hidden" name="idDestinatario" id="iddestinatario" value="<%=request.getParameter("idDestinatario")%>">
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                </td>
            </tr>    
            <tr class="celula">
                <td align="center" colspan="2">
                    <div align="center">Modal / Tipo CT-e:
                        <select name="tipoTransporte" id="tipoTransporte" style="font-size:8pt;width:90px;" class="fieldMin">
                            <%= emiteRodoviario && emiteAereo && emiteAquaviario ? "<option value='todos'" + (tipoTransporte != null && tipoTransporte.equals("false") ? "selected" : "") + ">Todos</option>" : ""%>
                            <%= emiteRodoviario ? "<option value='r'" + (tipoTransporte != null && tipoTransporte.equals("r") ? "selected" : "") + ">Rodoviário</option>" : ""%>
                            <%= emiteAereo ? "<option value='a'" + (tipoTransporte != null && tipoTransporte.equals("a") ? "selected" : "") + " >A&eacute;reo</option>" : ""%>
                            <%= emiteAquaviario ? "<option value='q'" + (tipoTransporte != null && tipoTransporte.equals("q") ? "selected" : "") + ">Aquaviário</option>" : ""%>
                        </select>
                        <select name="tipo-conhecimento" id="tipo-conhecimento" class="fieldMin" style="font-size:8pt;width:110px;">
                                    <option value='todos'>Todos</option>
                                    <%= emiteConhecimentoNormal ? "<option value='n'>Normal</option>" : ""%>
                                    <%= emiteConhecimentoCobranca ? "<option value='l'>Entrega Local (Cobrança)</option>" : ""%>
                                    <%= emiteConhecimentoDiaria ? "<option value='i'>Diárias</option>" : ""%>
                                    <%= emiteConhecimentoPallet ? "<option value='p'>Pallets</option>" : ""%>
                                    <%= emiteConhecimentoComplementar ? "<option value='c'>Complementar</option>" : ""%>
                                    <%= emiteConhecimentoReentrega ? "<option value='r'>Reentrega</option>" : ""%>
                                    <%= emiteConhecimentoDevolucao ? "<option value='d'>Devolução</option>" : ""%>
                                    <%= emiteConhecimentoCortesia ? "<option value='b'>Cortesia</option>" : ""%>
                                    <%= emiteConhecimentoSubstituicao ? "<option value='s'>Substituição</option>" : ""%>
                                    <%= emiteConhecimentoAnulacao ? "<option value='a'>Anulação</option>" : ""%>
                        </select>
                    </div>
                </td>
                <td colspan="2">
                    <div align="center">
                        Motorista:
                        <input type="hidden" name="idmotorista" id="idmotorista"  value="0"/>
                        <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" value="" size="30" readonly="true">
                        <strong>
                            <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:localizamotorista();">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limparMotorista()">
                        </strong>
                    </div>
                </td>
                 <td align="center" colspan="2">
                    Mostrar Apenas Averbados:
                    <select name="documentoAverbacao" id="documentoAverbacao"  class="inputtexto">                        
                        <option value="t" selected>Todos</option>
                        <option value="s" >Sim</option>
                        <option value="n" >Não</option>
                    </select>   
                    
            </tr>
            <tr class="celula">                
                <td colspan="2" align="left">
                    Setor Entrega:
                    <input name="setor" type="text" id="setor" value="<%=request.getParameter("setorEntrega")%>" size="20" readonly="true" class="inputReadOnly8pt">
                    <input type="hidden" name="id_setor" id="id_setor" value="<%=request.getParameter("idSetor")%>">                    
                    <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:tryRequestToServer(function(){abrirLocalizarSetorEntrega()});">
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="limparSetorEntrega();">
                </td>
                  <td  colspan="2" align="left">
                      Apenas as UF(s) destino do CT-e:
                    <input name="uf" type="text" id="uf" size="15" value="<%=request.getParameter("uf") == null ? "": request.getParameter("uf") %>" class="inputtexto">
                    <label>Ex:PE,MG,AL</label>
                </td>
                  <td align="left">
                    <input id="cteF" name="cteF" type="checkbox">
                    <label>Mostrar apenas CT-es faturados</label>
                </td>
            </tr>
            <tr class="celula">
                <td>
                    <label>Filial: 
                        <% if (nivelOutrasFiliais > 0) {
                                out.write("<select class='inputTexto' id='filial' name='filial' onchange='alterarFilial(this.value);'>");
                                for (BeanFilial filial : consultaFilial.mostrarTodosCTe(Apoio.getUsuario(request).getConexao())) {
                                    out.write("<option value='" + filial.getIdfilial() + "'>" + filial.getAbreviatura() + "</option>");
                                }
                                out.write("</select>");
                            } else {
                                out.write("<b>" + Apoio.getUsuario(request).getFilial().getAbreviatura() + "</b>");
                            }
                        %>

                    </label>
                </td>
                <td align="center">
                    S&eacute;rie:
                    <input name="serie" onkeypress="mascara(this, soNumeros)" type="text" id="serie" size="3" value="<%=request.getParameter("serie")%>" class="inputtexto">                    
                </td>
                <td align="center" colspan="2">
                    <div align="center">
                        <input name="meuscts" type="checkbox" id="meuscts">
                        <span class="style8">Mostrar Apenas CT-e(s) Criado(s) Por Mim</span>
                    </div>
                </td>
                <td align="center" colspan="2">
                    Ordenação:
                    <select name="ordernacao" id="ordenacao"  class="inputtexto">                        
                        <option value="numero" selected>CT-e</option>
                        <option value="nota" >Nota Fiscal</option>
                        <option value="data-emissao">Data de Emissão</option>
                        <option value="remetente">Remetente</option>
                        <option value="destinatario">Destinatário</option>
                        <option value="cosignatario">Consignatário</option>
                        <option value="valor-cte">Valor do CT-e</option>
                    </select>   
                    <select name="tipo_ordenacao" id="tipo_ordenacao"  class="inputtexto">                        
                        <option value="" selected>Crescente</option>
                        <option value="desc" >Decrescente</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td align="center" colspan="6">
                    <table width="100%">
                        <tr class="celula">
                            <td width="30%">Modelo DACTE:
                                <select name="modelo" id="modelo"  class="inputtexto">
                                    <% if( request.getParameter("statusCte") !=null && request.getParameter("statusCte").equals("F")){%>
                                            <option value="F" selected>Modelo FS-DA</option>                                    
                                        <% } else{%>
                                            <option value="1" selected>Modelo 1 (Rodoviário)</option>
                                            <option value="2" >Modelo 2 (Rodoviário)</option>
                                            <option value="3" >Modelo 3 (Aéreo)</option>
                                            <option value="4" >Modelo 4 (Aquaviário)</option>
                                            <option value="5" >Modelo 5 (Rodoviário)</option>
                                            <option value="6" >Modelo 6 (Rodoviário)</option>
                                            <option value="7" >Modelo 7 (Rodoviário Meia Folha)</option>
                                            <option value="8" >Modelo 8 (Redespacho)</option>
                                            <option value="9" >Modelo 9 (Rodoviário 3.00)</option>
                                            <option value="10" >Modelo 10 (Aéreo 3.00)</option>
                                            <option value="11" >Modelo 11 (Aquaviário 3.00)</option>
                                            <option value="12" >Modelo 12 (Multimodal 3.00)</option>
                                            <option value="13">Modelo 13 (Rodoviário QR Code)</option>
                                            <option value="14">Modelo 14 (Aéreo QR Code)</option>
                                            <option value="15">Modelo 15 (Aquaviário QR Code)</option>
                                    <% int contador = 3;
                                    for (String rel : Apoio.listDacte(request)) {%>
                                        <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                    <%} }%>
                                </select>
                            </td>
                            <td width="30%">Modelo CC-e:
                                <select name="modeloCce" id="modeloCce"  class="inputtexto">
                                            <option value="1" selected>Modelo 1 </option>
                                    <%for (String rel : Apoio.listCce(request)) {%>
                                        <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                                    <%} %>
                                </select>
                            </td>
                            <td align="center" width="20%">
                                <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                                       onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value,'pesquisar', ordenacao.value, tipo_ordenacao.value, valor_consulta2.value);});">
                            </td>
                            <td width="20%">
                                <div align="center">Por p&aacute;g.:
                                    <select name="limite" id="limite" class="inputtexto">
                                        <option value="10" selected>10 resultados</option>
                                        <option value="20">20 resultados</option>
                                        <option value="30">30 resultados</option>
                                        <option value="40">40 resultados</option>
                                        <option value="50">50 resultados</option>
                                        <option value="100">100 resultados</option>
                                        <option value="200">200 resultados</option>
                                        <option value="1000">1000 resultados</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

        </table>

        <form method="post" id="formulario" name="formulario" action="CTeControlador?acao=enviar" target="pop">
            <table width="99%" align="center" class="bordaFina" cellspacing="1">
                <tr class="tabela">
                    <td width="2%">
                        <input name="ckTodos" type="checkbox" value="1" id="ckTodos" onClick="checkTodos()">
                    </td>
                    <td width="5%" align="left">
                        <%if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) && statusCte.equals("C")) {%>
                        <img class="imagemLink" alt="" title="Imprimir todos os DACTE's selecionados" id="img_imprimir" onClick="javascript:tryRequestToServer(function(){popCTe('0', '-1');});" src="img/pdf.gif">
                        <img class="imagemLink" alt="" title="Enviar Vários CT-e " id="imgEnviarVariosCTEs" onClick="javascript:tryRequestToServer(function(){enviarVariosEmails();})" width="25px" src="img/out.png">
                        <%}%>
                        <%if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) && statusCte.equals("L")) {%>
                        <img class="imagemLink" alt="" title="Imprimir todos os DACTE's selecionados" id="img_imprimir" onClick="javascript:tryRequestToServer(function(){popCTe('0', '-1');});" src="img/pdf.gif">
                        <%}%>
                        <%if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null) && (statusCte.equals("P") || statusCte.equals("N") || statusCte.equals("F") || statusCte.equals("E"))) {%>
                        <div align="left">
                            <img class="imagemLink" height="20" width="20" alt="" title="Enviar CT-e para SEFAZ" id="img_enviar" name="img_enviar" onClick="javascript:tryRequestToServer(function(){enviarCTe();});" src="img/cte.jpg">
                        </div>
                        <%}%>
                    </td>

                    <td width="5%">CT-e</td>
                    <td width="2%" align="center">Sr.</td>
                    <td width="7%" align="center">Emiss&atilde;o</td>
                    <td width="24%">Remetente</td>
                    <td width="24%">Destinat&aacute;rio</td>
                    <td width="24%">Consignat&aacute;rio</td>
                    <td align="right" width="13%">Valor</td>

                </tr>
                <% //variaveis da paginacao
                    int linha = 0;
                    String cor = "";

                    // se conseguiu consultar
                    if (acao.equals("listar") && ctes.size() > 0) {

                        for (CTe cte : ctes) {
                            cor = (cte.isCancelado() ? "#CC0000" : "");
                            //pega o resto da divisao e testa se é par ou impar
                %> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                <input type="hidden" id="isCancelado_<%=linha%>" value="<%=(cte.isCancelado() ? true : false)%>" />
                <input type="hidden" id="situacao_<%=linha%>" value="<%=cte.getStUtilizacaoCte()%>" />
                
                    <%--<c:choose>
                        <c:when test="<%=cte.getStUtilizacaoCte() == 'H'%>"> 
                            <input type="hidden" id="chaveConsulta" name="ctl00$ContentPlaceHolder1$txtChaveAcessoCompleta" value=""/>                        
                            <input type="hidden" name="__VIEWSTATEGENERATOR" value="" id="__VIEWSTATEGENERATOR">
                            <input type="hidden" name="__EVENTARGUMENT">
                            <input type="hidden" name="__VIEWSTATE_HIDDEN_<%=linha%>" id="__VIEWSTATE_HIDDEN_<%=linha%>" value="/wEPDwUKMTUzMzExNTU2NA9kFgJmD2QWAgIDD2QWEAIJDw8WAh4EVGV4dAULNDA1LDQwOCBtaWxkZAINDw8WAh8ABQkxLDUxNyBtaWxkZAIPDw8WAh4LTmF2aWdhdGVVcmwFFWluZm9Fc3RhdGlzdGljYXMuYXNweGRkAhUPDxYCHwEFNH4vUGVyZ3VudGFzRnJlcXVlbnRlcy5hc3B4P3RpcG9Db250ZXVkbz1sNWltT1ZsRHFQVT1kZAIhDzwrABEDAA8WBB4LXyFEYXRhQm91bmRnHgtfIUl0ZW1Db3VudAIEZAEQFgAWABYADBQrAAAWAmYPZBYMZg8PFgIeB1Zpc2libGVoZGQCAQ9kFgJmD2QWAgIBDw8WBh4NQWx0ZXJuYXRlVGV4dAUrTWFuaWZlc3RvIEVsZXRyw7RuaWNvIGRlIERvY3VtZW50b3MgRmlzY2Fpcx4PQ29tbWFuZEFyZ3VtZW50BSRodHRwczovL21kZmUtcG9ydGFsLnNlZmF6LnJzLmdvdi5ici8eCEltYWdlVXJsBR1+L2ltYWdlbnMvYmFubmVyX21kZmVfT2ZmLnBuZ2RkAgIPZBYCZg9kFgICAQ8PFgYfBQUXTm90YSBGaXNjYWwgRWxldHLDtG5pY2EfBgUdaHR0cDovL3d3dy5uZmUuZmF6ZW5kYS5nb3YuYnIfBwUkfi9pbWFnZW5zL2Jhbm5lcnNfVmlzaXRlX05mZV9PZmYucG5nZGQCAw9kFgJmD2QWAgIBDw8WBh8FBSlTaXN0ZW1hIFDDumJsaWNvIGRlIEVzY3JpdHVyYcOnw6NvIEZpc2NhbB8GBSNodHRwOi8vd3d3MS5yZWNlaXRhLmZhemVuZGEuZ292LmJyLx8HBSV+L2ltYWdlbnMvYmFubmVyc19WaXNpdGVfU3BlZF9PZmYucG5nZGQCBA9kFgJmD2QWAgIBDw8WBh8FBSpTdXBlcmludGVuZMOqbmNpYSBkYSBab25hIEZyYW5jYSBkZSBNYW5hdXMfBgUaaHR0cDovL3d3dy5zdWZyYW1hLmdvdi5ici8fBwUgfi9pbWFnZW5zL2Jhbm5lcnNfbWFuYXVzX09mZi5wbmdkZAIFDw8WAh8EaGRkAi0PZBYEAgEPDxYCHwAFCUNvbnN1bHRhc2RkAgMPZBYEAgEPZBYEAgEPZBYCAgEPZBYEAgIPZBYCAgsPEGRkFgBkAgMPZBYCAgsPEGRkFgBkAgMPZBYIAgcPDxYCHg9WYWxpZGF0aW9uR3JvdXAFCGNvbXBsZXRhZGQCCQ8PFgIfCAUIY29tcGxldGFkZAILDw8WAh8IBQhjb21wbGV0YWRkAg8PDxYCHwgFCGNvbXBsZXRhZGQCAw9kFgQCAQ8PFgQfBwXmQGRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBTFFBQUFBeUNBWUFBQUQxSlBIM0FBQUFBWE5TUjBJQXJzNGM2UUFBQUFSblFVMUJBQUN4and2OFlRVUFBQUFKY0VoWmN3QUFEc01BQUE3REFjZHZxR1FBQUJmUFNVUkJWSGhlN1oxWHFHVkZGb1l2Mm1adFU3ZFoyOVkyWWtKRkZITVd6S2lZYzg0NUs0N2FiV3pzeG9EVE9HTEdSZ3lJSXlLMmlBNG9PZ01pUHFoUGJUTVBDdk1nd3p3NE1BOTd6bGZjZjd2dXVxdHExejduZG84UDg4UGluck4zaFZVcjFhcXFmZllkbXpGanh0L0d4c2FhR2xwdHRkWCt2ZnJxcS84S3JiLysrcjk0bWpsejVqODIyMnl6bnp6Tm1UTm5xYVZaczJiOVBXcS9pOVplZSsxL3paNDllOWtKSjV6d2w2dXZ2dnJQaXhZdGVyRnBtaitzS1ByMjIyL24wK2M1NTV5ejVOQkRELzByWTVrMmJkcC9JbDVGakoreThQdlVVMCs5VFAxbHk1WTlFclhQOWVqK0w3LzhNamRYeHhMbHFGL3FRMVRUWm82ZkZVR3Z2UExLbjZMclhUUTJmZnIwZjBhSytGL1J3R2liOWRaYkQwTm90dDU2NjJiSEhYZHM5dGhqaithQUF3NW9Uai85OU9iZ2d3OXU3cnZ2dm1xNisrNjdtOXR2dnoyOFZ5THEzSHp6elJPdVhYNzU1YzNGRjE4ODRScEV1YlBQUGp2eEJyL3dINDFOeE5qT091dXM1dDU3NzIxZWYvMzE1cE5QUG1tKysrNjc1dXV2djA3dGZmSEZGd1BkL0laMzNua25YZThDYllnbjJpcWhwczBjUHlYOCt1dXZhVHpRd0duR3IvWURkWkhUQ3krOE1INmxIbU40NnNNUFB6eEJDWWNjY2tqejhjY2ZOMmVlZVdaejBFRUhOWGZlZVdmejZLT1BOdWVmZjM1ejdMSEhKc1ZKZVJpZHBVMDIyYVJ0NS84MFBLRUQ2SW9ycm1oT1BQSEVKSGNVdlhUcDBuSFY5WWMxVEl3bFo5QVlwVFZHUHRjYVp4K255Z0ZIUndiWVgxK01EWWhRM2Z6MDAwL05CUmRjTUVHb3A1MTJXdnY1alRmZUdNbnpHSnpxaTU1NzdybTJmYUt2QkpHajg4NDdyOWxycjcwbVJNbGpqam1tVlg1RWNqcC9qVDYzMldhYkNkY3RiYi85OXMwZ2pVcU92c01PT3pSSEhYVlVjL1RSUnplSEgzNTRjOHN0dHlUbkhxUVN6Zjc3NzUvNE9PT01NOXE2VVo4UXM4eHV1KzJXN3RIdVNpdXQxSTYvTDlIZThjY2Yzd3hTbWVhRER6NUlSbGdDOHFhZW9oNzZ6aG1jajk2VUc5WTRoOEhMTDcrY2VIM29vWWZHcjB3RXZQaFpBMGZIbVZxREZoaTRGRzVKQmdUVkRzNTZ1dmQ2Z09EVS9yUFBQanNsMHhXZ3J0cVE0alJnOE41Nzc2VlVwQlR0U2hGTVVZakllY2tsbDB6aW1YYTdwbW54K05sbm42VytMcjMwMG1iTExiZWNJSE5MZy9WTGVOM1N2dnZ1bS9paVhROVNHOG9zV0xCZy9Fb01aSFhQUGZka3gxNEQrcmNPMWxldmxDZHJVRmxyd0Rpdnhpdm5SSWE2TnNtZ0JRWnUwNUJ6enoxM0VqT1Jwd0FOeUhxNlB2dkJ3WlNNZVpUcGlyWXdYdjR1V2JJa3RTSGVhRXZqdVBiYWE5TmZCRlpDTG9MUnZ1UkFHWTJyTDgrVXRUeCs5ZFZYS2VxVGoxOS8vZldKUndMTFlBSGU4bTVwNVpWWERxK0xxTWVzZ1NFalcyOGtFYXl4M0gvLy9lTlgrd0Y5VXQvS0Y3MXEvVkdTa2V6R3d2TDB6RFBQcFB2WXBoMExxWW5LWkEwYW9EQ21kQlVtUDZZRDhPNjc3N2JYNVNuQURvalBLRTNYK1R5SzBaYWc5bTJmZ3AwSm5uamlpWFIvMkZ4MDhlTEZhVXJzZ2pYOEdsZ0Q5OUdVZTZSYnUreXlTMHBYTkJaUDY2Njdibmg5MVZWWGJZMjdoTWhZK29KNlhyN1dLQjkvL1BGMnByU3dkbVB4L2ZmZk54ZGRkRkZLOVQ3NjZLUHhxeFBCaktMMnh3WUNYUERERHorTTM0cEJaM2F4UjY3OTJtdXZwWnpTRDk0T3lFWTVmZVo2TktCaFlHY0hUZlA4WmVCK2VtTU1tZ21HUlRUZFdkQWY0d1NNVldQdml5aWFlbGxpbkRmY2NFUEs3OFdUcDVrelp5Wmp0dGR3Q0l6V3R1MWg1VG9Wa0tOY2Q5MTFMUjhFR1F0ck53TGp6WlVYckU1dytySEJ3dThUcG9NdTBLRmRORzY2NmFacEd1bURHZ1lqV0VNUk1GamFpUXlMZmhUdCtpQ2E4aXk2SWhpODBPL3lCbjJUb2lndzhQM1ZWMTl0OXRsbm4yYWpqVFpxWlZ3aW9qa09ZUTBJbE9RNkt1eE1TWERwUWxTZXNWclplNTJNZmY3NTV3djdLSjZCS3EvRCsybXNCZ2p1NmFlZkxnNklNcm5weUJ1S3BtVld3bmFBdzRJK2FBL0JJQ1FVNjZOOEYrRHAwMDgvSGYvMkc3b2NCWlIwQUErV0YvSmJ5VEVLREpUak9nYkxibzNLNW9pMFVvWWRwVHVqUm14NC8vbm5ueE5meURtYUtYTXk5K1hmZi8vOVlqQnNjK2crU3NUb1dGRkxJT1JubmtGcm5EWXlzeWlMQmxTSzNyVGxoVXA5akk4VkxuVzd3SmhLWStPNnBqejQ1ak5VMHphd0RtR1J1MjRCWDVSaDBlTm5JZ0FQOENJWkxGcTBxSlZWRkJnRU94MGpkd3ljUXlwZDgwUTZ3b0hTbFZkZW1lUmg2M085eGpZOE5IN1NEY1pCL1dpTWtjeTVScCtSSFRFalJXZ051cThTTWFnNzdyaWo3UUJCaVZIYk1jWUo2YnRWQU9Xa0pGK21iMVRJUlhlQnZoaGJsRitEUGc0ZGdUcTByMGduNUs1YktDcXlXbWM3a1RwUWlaZGNwQU9xeThKZGUrZnNnYk4zTFJtTDFsaGpqVW5YSUdaaDl0NlBPKzY0dE1PbDA5WXZ2L3l5NVlrK292NHRLR3ZIRDk5OHo4R2ZoVUJjQTlaR2JydnR0blRObzdqTFVRT1VvUlNFaFNPR0V4bXdWMEMwd0ZLWkR6LzhjTUoxaEpKVExQQU9WSUlNMnp0TVg0ZWVTaUFUSXZnMzMzeVRUbVF4SG1hZWlFK2d5Q1hqUU9FWWEzUiswRVhVSlIwNDVaUlRpZ2M5Yk9FeUUzTnl5YllpZlhPOU5QTUE5R1lqTW9hZEN5cWdaTkJBTnBKenBKRU5HaUIwN1ZtejJHRHFoSjU4OHNrVUpaanFkRm9tNHJTTjdaaWJicnFwZWY3NTU1dVRUam9wUlh5VUZlVngzc2grL1BISFJDQTNBOVRBQzd3TDhPR05EQ1hCQS94RVN1SithZmF3UUdHY0FIS0t5dFNQd2VvMDFKNExUQlhKV0JnWCs4UThTOE4xZGd4S0tjcDIyMjJYMHM0WFgrVDVzRHprZEJiMGxYUFdMb1B1UW1qUUtBWENDL0NrbkRkWm9EVHRrZUxwdzBRTENNTld4Q3IxeVg3d0k0ODhraFNOSStoNUI2Szdud29qSXhRaWdRdStuV2hXb1cyN3BZbEI4TWdBL0ZPZis3cG5ady9HSnJuU0xwR3Z0TWU4dkFpakZUOEVFdkdBVEFVY25uc1lWblNhcVVNY1pPS0RBM2FSazcxQTM2cEhIM3Z2dlhmaWcxMGJIdUs2NnFxcnNudlFIcUZCb3dTb2RocUdJUVkwZmZyMFNZTWRobXFCUVVUMUlRUUpJaU8weUFtY3N0VEJNT1hZT0F1N0tuSTJtMjdWa0owOWtDZHlKY1dJeW81S09KbG1RL3JKUlhkeWF4K0ZLVnVhVVhCTWNuMkNUelIrMmtOR3BFMXNMeUk3eHA2em9WeFFnUWVlWWxTN1huL29RRUZCbUdUUUZMQlJxUWJSTkNIYWZQUE4wMzBZNWdFa1hjOHRScUJhMUJnMFl5bnRIVk11VWg1bDRWbjMrUXhKS2JRWDlSc1JzNGZ5UHQ4ZmdTQ3FVeUtNRmFOaEZ1U3BSdzVYbVA0UE8reXd0Z3ozWk5CMkJpbVJJcTFrbDVPTkJXVndTaDdVNmtxSlNFTWowQWJiblZZL3lKbEFVOUtmZ29JTlNCTU0ya2FsV3FpT3BhMjIyaW9SbjVrNkpDQkFlWlFMY3pEcTZ5S1VXakFnRkxmRkZsdE1hb2ZJVUFMT3dJcGQ1VzA2SUdFS1RJZVVoNGpTUkRYYlZ4ZHhZaGRkL3owUWhvaFJNRFlMWktBeUR6NzRZSnFOS0Vkd3drbUdTWS9XWEhQTlZOLzNCWkEvN1dQQWR0WTY5ZFJUMDNVSVordGE3eVNEbGlmYXFGUUQ2dmdwaDJoQWZUcFdaR0R3M3JzRUg2R1UwOVdDZmhDK1JXNEtveHpDSkYrbEx4N2xWTDhjUUtBb2UrMzNTRGFWaUVqS2gzallpVHJzbXRobmNrU1V4L0ZmZXVtbDFtQ1JEZGVaV1gzNXFhUjExbGtuQlQwZUI1NHpaMDVZSnFJdTJ4eDcrKzIzLzZqQ05rcFo1Sko2ZTdnaVFpZ3Fqd0ZwR21LS2pJd2FqNlFPaG8waDh0MkNPaGd0ZnpIR1hCdmNnNGo2YkN1ZGZQTEpTVEVSajh1TFdKUkdrWXZGamZqRHVHNjg4Y1oyOFNwUzVPR3pydzhob3h4WUo1RFB5cUFsUTR5VXVzZ0VuVWdXT0FXTFBrN2RiQi9MZzlDLzBpMzRZVWFJeXRWU3lhQ3hqYkY1OCtZdFZtRzdhQkVrWUl6TkF5R3Fya2piUGp3R1NWMmVQVllVeHhQdE13ZzFVTFJsUjJQMzNYZFBLY2FNR1RQU3o1ajRhL3V1cGRtelp5ZkR3d0NVMzR1UWdZd013aWt4bUZKK3lEM0tna2dtR0ZJSjlLRWdRRHUrUGdSdkVTS0hWV0RDaUhKckIwQTVYemRIbWhtSTlKSVZUbEZhRkJQdGZkOTZmSGRZS2hrMHRwSlNEajdJaXp5c2x3c3d5Uk42UEhmc094Uk5tell0UFNqRGdvVnB4Vy9hazVmSkNFcGdBT3lQMnJvMXhJNExRbWRzOUNPRFlZd3NUcnlCY0oxeWtGVUNjb25hRitFWTFrR2pCVEpsYUo5MkdZOHQ3M2RoK2hnMGJVVmxNYnBhRUhpaU5qZ2xST2R2dmZYV0pLTmtOb25HS1NKOTgybWdRRnVjWExMWGpvT3dSZWQzV1RpZDFJNlN2UTV4WGZ6d21VTWhJY2xqOERjdENtMlVzSWk4SE1HemNwZW5scnkwaG9odzVNNDU3OHNwdVVRWVVRU2lFa3IwQXNmSU5CN2RVNjZkSTZLalZ6YjFmVG5HUjc4OG5haHJOb3JxZVYvYXlvMlZoU2ozVUtJY01tZFV1YkZIUUpjRUg5OEdENUo1ZVFDT25FdXpGY1NCbXBkTEYrakQ1dm5JWG1zQVMrSUh2dmxPQ21QN1NnYmR0VmZyZ2VFTmN1L1dBZkJZT3RJaWNCU3lHL29XUEpERG5pVDk2T1JNRkIzaTVKVEsrR2lqQkFSRTN1dmJ0TVFXR2RGQmtWZkliZWZScjkyMnRPbWQ1V2tZNS9WRUxsOEwrdVo1RHhrcHNvemtneEh0dlBQT2svb1NvVGNjalhIeCs5TXVHVWVnRDdYSG9qUXlhTW1hdndSVm9ybjY0bG95YUpUQzlJSXl5SG41UGd5b2gwSWdJaEFkUVVjY2NVUmloaHlhWDVHdnRkWmFreGkxWkNPQ1VESkU3dmsyY2dZZDdZcFk4RHhGMTZyN3dnc3ZUTHpnMEJxbkVQRUNzWFpRWlBIcG5lVnBLZ3lhMHpVdE1ydGcrOFlnL1BFOW56SFdxQitJNEtJVWlySlFTVmNSa0FYT1lFOGhtWkhzajZoRk5vdUFkeDZsVlYrTW8wMDVnSlRSWngrNkJqQ3N0RVY5OEp4Qzd0Y1dMS3c4U29ZWUdWR2ZhVmRJQW5IdGVHSVdRb0RNYXZEa2xXZG5PMHUxQytGSWlYMEpZOGdaRkRySUdUdmo1NUVDeVJsbnpjMjZHMjY0WVpzMkNmdzBqYnJTRlRPNUFwd1BrdkJCZms2ZXpLL3ZiZHY3N2JkZm12MGk1L2J3ZGpIQm9Pa0VRZGhjbHNKUmJqMHNZSlI4bVVnSW1CbjhncEZwRDE1cU1WVUdqWUo4TzEyMHdRWWJORHZ0dEZPU0cvVWpYaUNVSTZEY2FIdzVaNENRaWQxaElFRHdOeW83ZCs3Y3JNNjhBM3BRRC8zYmZOWVM2eVhxZXdPVjhkRStiZmcwa0pRRzQ2TmVhZnZPL2dxcXhxQXRVdm5CM3dsSDN4YWwzRnJHRCtNWVQrMkJDRXFIYVhtVi9aMlpKUVRIb3NkSHRzakJJaU5pMHo0WGlVcVF3dG1GWVcvY0syWllRb2tDTXJCR2haSlJCZ3MrWG9zUTFmZnlCOGpDbCtOMUI5N1lMRERXbkxIVFAyMnNzc29xazlxRm1EbXBMMzRoT2FaMnczaFBDUGJnNjBKc3Uvb0ZwZmJFK1RHc1puR2haTkNVcy9wdGJXRHdPV3ZRTUs3YzJrY1VETmgzUm01SkRtWUg2a0hIREpwMjJiTHhiU0EwUDgwUkxUQ0NuSU8xZ3pIRUhyVTFtbEZtR2lrUU9lQmtmcHVwaGxBeWlzTWc0TmZ5Wm5kWWNpbUhIYThGK1RneXcxQklOVmc0RHdQR3g5NSsxRGZCQmVjV2p4eGF6Wm8xS3dXTlhKMFNxVDMwV1VMT29KRWhxWXFWSWZiRzk2eEIwMWpKMDNOYk56eTNnS0UrOE1BRHFRMFJ6T01FcFplcFlDZ0NDdlNlamhCWmtiTjFaQjBtTW1pZTc1QUJsMmFhdmtDWW1qVVlGNDZKa2ZjNWtZUUh6VkFldEptcmt3T3lJSkJFKyt0ZElNcVY5cFNua25pV0EzbmxncDJIbHdVT1pHZWxlZlBtdGZhbE5pY1pORGM0bnFVQ0VjbERrVTZOamtxY0xDSlFJbkFFak5FLzd3RVJ0VFdOUndaTmxOZEFTek5OSDFoaDV2aEZOcm1GbEVoN3loRXZYb21pbkVGVG5vZXNXTXh4MENWSDRmbmhtckZHc2h1VmlNQTRPSC81emt0eENFU2tOSDNnWmNHYkJwQzd2dU84MkNxa2NVOHlhRzVRZ05NNW9wRUZ2MDVRWTdrOHE0WVlLSTg5NnJ0WEZnWW9aVEFvRnBMejU4OXY5dHh6ejdTNjltMXhsRzJ2NlRydm5lT1hGK3huUW93TElVQTRRMG5obGdmQkNwT3BYdWtCTTRrOUZvNW1MMllmOVUwNy9JMVNvRDRHTFdOVTRGRjdhcVBtN1VjbGc4WW90ZGZQMkhoR2huUVIzaGN1WEpqR1QxK1FseFZsYUFOWmNIOFllRmtnWndEUDJ2ckVYaUg2WjdZcDV0QVVsSkQ0ckliNTBTVGJicll6U3h0dnZQR0U3d3dLb1JCcE1TUVlLVVZOS1h6VWMvOHU0alFxQi9IZ0lXSGFOMGZWVU83aExBc1Vna3lpK2l4T1pWelJES0F0VVBqVEFvMjJ1a0NmTWtvZndDeXMvcEdOaDNkT0xhWWpHZElYK3U5Q3pxQWpNTzdrUklQUG9VSDd2Tk5ISjVTRHdHaUVvMDQyODNXZjEyMEJoSVVnZ0NLZWRSSVBlWm1ZMjNYWFhkczJsd2ZSRDN4Sm9mUXZZWXVISE9TUXpBSzFMM2RoMWlDOWtrd0E3ZUJZVTdXYnd0cUZOZ2tVb3h5U2VYajlXOGp3a0JtZ1Q2VWI1UFZXMzVUaGVwVE9lcVEzSVkzM0NlSE1ncmNqbkpIVDY2eEJTMkUyZ3NLTVFqMWdJV0pmSThaOWxNUFBjendRU09ubk5JQnJHSkVjQVlZVmxlekFJRVVwVHZXNHoxRTFDMEgvNml1ZVUrRElscFNEdGhtVEZZVGRZZEFMWEJpemRjWWFvRlIyTWVCRnlzd1JrVVl5cGQrb3pEREVRMkJXVjF5ck1aeGFlUDBMMFl6Z2Q0S2tiL2hqektYWkFFUVBwTW1Sb2tVK3VrclhCcCt6S1VjWE1BRC9PakFacFFmWE1YVHZKQllNTWhlOVBTUkVGaHNlREpoSTZBMExKOERoY29aYUsrd2E4S3d4NzlsZ3JVRCthZE1FUG12OE52TDFJWndYeCtDQUFwbHFUSnBoY21QaE8wN00vVWdIdzREK3ZFNjFyVXRBMFl0cmFzRVkrS1dLSHpOQkJ0QWZidzNnREVQdHRuSWNmRTRHTFVQU2dHdGdEVkFSVlpGTlFoWDZScndTYUpjVk00dVUwcStCNFFIRGozWkpNQWFFN3NkSzJ4SmNEWEx5b2gyT2R2bWhhQmVRbTdiY0lJd0RwZkpUSkhaRUxOK2xBeXlDQm1WeVVSbjVxeDNTUXVsc3FxRVVoRjBKL2lKcjYxaDhabGNHUGpWbXhzWHNGcTBQSU5aVHlNamFsRWNhLytEdkg4UkExenZUY29pbUFPckQ2UElBaXFCdGNxWmE1ME1RdkFORWZGb2lmNlU5Mm9wbUdPK2NNbUpySUY1ZTRySEdZQ1IveVk2K29weWF4VFZwVFE3VW8wOXJQQloyTm1ENjl2MU9GVFI3OHE5TXRPTWpvN1l5cXlIcTI5OFlNdjZTVVNlREZnTThsNnVLUHZFdmdXakplMy90dEJNWnhsUWlNaVlNRHlXeEdDSy85K0ErMC9OZGQ5MlZJbFIwR0xMdHR0dW0vTTA2aW5WTzJ5L0MxZWMrOHZMd09TZ3BpdHJsTS8yWGxCaUI4c2pDMTBNdnlvTjl2NnJETmlrNjVUcXk3TnMzYldNTDZJQ3RQVjQreERpNHpqdnBOTFlTb1J1ZHJFcHZ0RW45a2wwbGd4WURNRzRIREJTTkxPdzF5c01BOVFFS3Q2bEhEZWlycjlBd1NBMWUyMjg4b3NuaWp5TjRwclF1b0R5ZUlVQlkwWEcySXJjOVp2VlJ6c3BybUhFQUszOWtxL2FaK1dwQVBaOG1JWHQ0THMwUXRsK2dPc2lPL1dieWYvdmNUVi9ZOXVnRGVVTzMzbnByZW1iN3dBTVBiSTQ4OHNoVVJzU1k0Y3ZDMnh2bGNpZ3VDbUZJd3VWaEhUcXkxeFE1NklCT285U2pCallDMXNJYTFtT1BQWllFVlhvZm5JY2NrZklZQStQQUlYTEd6WlJKV2NadmpkaGltSEY0TUE3NlkwRXJSRUhGb2t2Skt3SXlXRG1IMXdIOHc2TmthTzlUSjNKSXluaDc2d3FVa3d6YWRtU05CdUlmMjF4MjJXWHRkNVFLSkhBVXJLbEJBNnVCRklKQXZKR1VJTVBpNkpmNk5ZWXN3QjkxU0pYNDY0MkNNVEdXNkxVR1dsRENyOFZVR0paVklJL1llb1ZhU0Y3dzJtZnNVd1ZrS0QzRHAzUWdwMFFlQW55cXJML3Y1V1lEb3oxY2s3MlZNTUdnMVJHclNZSE9tTjdaNU9ZTmxRaVZuNzd3ekMxTWxnUmVDN3pPN2dHUEFpbTVGaklHYnhTTWkrK01pZDJVWE9SbTBjSVdJZmtvT1NQMVJnRks1eGxyMm1acnlnWVZ0ajNGSTNyaDJxanlHZ1dNTlJxdno4MEJOc1RhQlBqN1h2Ym96d1pHeGhyTmlCR1NRY3ZUMUJHQzlJQnhlYUNGRlhpTkI5RVBSc2RmQzc3VFBvUFRkejhOZFdHcWxHd2pCRXF3MFFPZUdHZjB1Z0xTQks3RFIxL2VCZVNzclRxMnNGQWk3VjF6elRWdFA5cSs0dGtVZE9abDJRV3Z3NmtHUE50WjJxZWkvbjR0cUlmdFJQWWpKSU9XcHczYlVSOFB5am1HQjIxYVE2b0JmRnVuR0JhTVF4R0NrMUI0amtCL0dCVDczTnFlc3NSS0hibVU4dDhJT0lNT2hSVEZ4Sk5lUGc0aVdYYkpWYk13OGgwRzlNbFByV3FkZ25Md3pwRzhQUWl4b00ydTl0QXBoMVdNRjhycHBMZ29GR0NveXpPNFYyUFExQysxSS9ocFNPQjZYd05aVVNBU3NlTkNqbTBORytJYTl6Q2tHb2ZUU1J0UjJxTGs2REpXZG1VQU10Wk1vYzhZRm1Ya0tEV1F6dDU4ODgxMlBGQ1hVN0RsMTFYT1JtOW1uc2cyTUY2VjZVcHIyd2p0amNjYU1hdi9rbWZBTUozVlRQWFVwNTJjUjlKZnpqRzZCa2E5TGtkWlVZQlg5bEdqdkJ2Q3dNbTlrVjNrb0RaS28zU0I2NUVPQUcrWFV2dkl4eG8vbi9WYUFMYmoyR3V1aFhUR3FTeE95WTlZbVNXNlpFMVoraXM1RHpyVGJKamJwZXFUMW80TkdudFZoYTBuK1cyV0VoZ1k1VWFkNnJzY28ydGczSWVQM3hzd1FsSVRERGgzdEF0eDlFc1p4b0F6eUtDdFhnUms3ZzJLOTJHb0xlUmpaemsrS3pwRFBGL1JGMzFzQXJESGI1L2p5QVd4R2lDRHJyU1dlMk9EenViS1E3eUFhaEFKZGxqUVRzNHhFQ0FDS1EyTWU4dkRvSE9LZ005aDBoLytCWWNNcStzZEpVUnlLdzlreEN4R05JdU1xaVFmcm5VOThXaWh2b2JWcjYzUDM1bytMZUNYZXJVOG9Jc0pPVFNWbEhONVNLazBib1dGVUx1OFZjWTRMUHdxT1lmU2RHemh4MUJDVGhIMEk1Nmk5S2NFdjdlS3dUSkdwbkcyUiszZU4vdmtGdlNMMHc0clQzVE1LU0JuQ3RIakFSYWo5bVhyYXdlTldhSVdmV2VFcG1tYS93TGZ1YWEvRDZPcWp3QUFBQUJKUlU1RXJrSmdnZz09HwRnZGQCBQ8WAh8EZ2QCMQ8PFgIfAAU8UG9ydGFsIGRvIENULWUgMjAxNiAtIENvbmhlY2ltZW50byBkZSBUcmFuc3BvcnRlIEVsZXRyw7RuaWNvZGQCNQ8PFgIfAAUZQW1iaWVudGUgZGUgSG9tb2xvZ2HDp8Ojb2RkGAMFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYGBQ9jdGwwMCRpYnRCdXNjYXIFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDIkSW1hZ2VCdXR0b24xBSljdGwwMCRnZHZMaW5rc0Rlc3RhcXVlJGN0bDAzJEltYWdlQnV0dG9uMQUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwNCRJbWFnZUJ1dHRvbjEFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDUkSW1hZ2VCdXR0b24xBSRjdGwwMCRDb250ZW50UGxhY2VIb2xkZXIxJHNvbUNhcHRjaGEFJmN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkbXZ3Q29uc3VsdGFzDw9kAgFkBRZjdGwwMCRnZHZMaW5rc0Rlc3RhcXVlDzwrAAwBCAIBZGUrsv98vKrSgGbIp2TBiNbd/kAp" />
                            <input type="hidden" name="__EVENTVALIDATION_HIDDEN_<%=linha%>" id="__EVENTVALIDATION_HIDDEN_<%=linha%>" value="/wEdAA8AueGY+4WrS2U8oTPkH0RNBGqPhwrln+9PTG+a425C4DQnJFM/mcs/d0VTMpMTYCGeOO0tTX51je1QOUgbhAXiTo1Ol8i+hK4G4Vo+jsDQOY8aEJZjnoPmyZdMj0cTDps02TTrU70chmk+oYZUyBFDMV5rQ02/s0ktp46Gfiy/coJgn06mMihbVjkI1u74QCeCfTspHnKMom4WREfNoQeM7H30DjvuZHqRE05bVtqWSK4WtomhoGXCF4LhXZ/AhS3F8ZLI9es9wT09XJsh63BVkk7aCjzv+b7H1Z/ScSHD8UECwoJkW1gYXPEUT0l3HnuOw6NsTdoqKNe529x9Pxf6+/LpYw==" />
                            <input type="hidden" name="ctl00$ContentPlaceHolder1$btnConsultar" value="Continuar">
                            <input type="hidden" name="ctl00$ContentPlaceHolder1$txtCaptcha" value="">
                            <input type="hidden" name="ctl00$txtPalavraChave">
                            <input type="hidden" name="hiddenInputToUpdateATBuffer_CommonToolkitScripts" id="hiddenInputToUpdateATBuffer_CommonToolkitScripts" value="1">
                        </c:when>
                            
                            <c:when test="<%=cte.getStUtilizacaoCte() == 'P'%>">
                                <input type="hidden" id="chaveConsulta" name="ctl00$ContentPlaceHolder1$txtChaveAcessoCompleta" value=""/>                        
                                <input type="hidden" name="__EVENTARGUMENT">
                                <input type="hidden" name="__EVENTVALIDATION_HIDDEN_<%=linha%>" id="__EVENTVALIDATION_HIDDEN_<%=linha%>" value="/wEdAA8Lw8gIJPQz9nCLhzBMCMMBBGqPhwrln+9PTG+a425C4DQnJFM/mcs/d0VTMpMTYCGeOO0tTX51je1QOUgbhAXiTo1Ol8i+hK4G4Vo+jsDQOY8aEJZjnoPmyZdMj0cTDps02TTrU70chmk+oYZUyBFDMV5rQ02/s0ktp46Gfiy/coJgn06mMihbVjkI1u74QCeCfTspHnKMom4WREfNoQeM7H30DjvuZHqRE05bVtqWSK4WtomhoGXCF4LhXZ/AhS3F8ZLI9es9wT09XJsh63BVkk7aCjzv+b7H1Z/ScSHD8UECwoJkW1gYXPEUT0l3HntUs4rKiLVb35B+pLffHbsWUSlMag==" />
                                <input type="hidden" name="__VIEWSTATE_HIDDEN_<%=linha%>" id="__VIEWSTATE_HIDDEN_<%=linha%>" value="/wEPDwUKMTUzMzExNTU2NA9kFgJmD2QWAgIDD2QWDgIJDw8WAh4EVGV4dAUOMSw1NjggYmlsaMO1ZXNkZAINDw8WAh8ABQo3NCwwMzMgbWlsZGQCDw8PFgIeC05hdmlnYXRlVXJsBRVpbmZvRXN0YXRpc3RpY2FzLmFzcHhkZAIVDw8WAh8BBTR+L1Blcmd1bnRhc0ZyZXF1ZW50ZXMuYXNweD90aXBvQ29udGV1ZG89bDVpbU9WbERxUFU9ZGQCIQ88KwARAwAPFgQeC18hRGF0YUJvdW5kZx4LXyFJdGVtQ291bnQCBGQBEBYAFgAWAAwUKwAAFgJmD2QWDGYPDxYCHgdWaXNpYmxlaGRkAgEPZBYCZg9kFgICAQ8PFgYeDUFsdGVybmF0ZVRleHQFK01hbmlmZXN0byBFbGV0csO0bmljbyBkZSBEb2N1bWVudG9zIEZpc2NhaXMeD0NvbW1hbmRBcmd1bWVudAUkaHR0cHM6Ly9tZGZlLXBvcnRhbC5zZWZhei5ycy5nb3YuYnIvHghJbWFnZVVybAUdfi9pbWFnZW5zL2Jhbm5lcl9tZGZlX09mZi5wbmdkZAICD2QWAmYPZBYCAgEPDxYGHwUFF05vdGEgRmlzY2FsIEVsZXRyw7RuaWNhHwYFHWh0dHA6Ly93d3cubmZlLmZhemVuZGEuZ292LmJyHwcFJH4vaW1hZ2Vucy9iYW5uZXJzX1Zpc2l0ZV9OZmVfT2ZmLnBuZ2RkAgMPZBYCZg9kFgICAQ8PFgYfBQUpU2lzdGVtYSBQw7pibGljbyBkZSBFc2NyaXR1cmHDp8OjbyBGaXNjYWwfBgUjaHR0cDovL3d3dzEucmVjZWl0YS5mYXplbmRhLmdvdi5ici8fBwUlfi9pbWFnZW5zL2Jhbm5lcnNfVmlzaXRlX1NwZWRfT2ZmLnBuZ2RkAgQPZBYCZg9kFgICAQ8PFgYfBQUqU3VwZXJpbnRlbmTDqm5jaWEgZGEgWm9uYSBGcmFuY2EgZGUgTWFuYXVzHwYFGmh0dHA6Ly93d3cuc3VmcmFtYS5nb3YuYnIvHwcFIH4vaW1hZ2Vucy9iYW5uZXJzX21hbmF1c19PZmYucG5nZGQCBQ8PFgIfBGhkZAItD2QWBAIBDw8WAh8ABQlDb25zdWx0YXNkZAIDD2QWBAIBD2QWBAIBD2QWAgIBD2QWBAICD2QWAgILDxBkZBYAZAIDD2QWAgILDxBkZBYAZAIDD2QWCAIHDw8WAh4PVmFsaWRhdGlvbkdyb3VwBQhjb21wbGV0YWRkAgkPDxYCHwgFCGNvbXBsZXRhZGQCCw8PFgIfCAUIY29tcGxldGFkZAIPDw8WAh8IBQhjb21wbGV0YWRkAgMPZBYEAgEPDxYEHwcF4kBkYXRhOmltYWdlL3BuZztiYXNlNjQsaVZCT1J3MEtHZ29BQUFBTlNVaEVVZ0FBQUxRQUFBQXlDQVlBQUFEMUpQSDNBQUFBQVhOU1IwSUFyczRjNlFBQUFBUm5RVTFCQUFDeGp3djhZUVVBQUFBSmNFaFpjd0FBRHNNQUFBN0RBY2R2cUdRQUFCZk5TVVJCVkhoZTFaMVp6RzFURXNkUFl1YWFYVE54eFJoRHpIT01NYy9ERFdKMkNYTE5KSWhyYnJSb2M2TXZMY2FFaDNhMW1Ob1ViUWpoQmZHQUozUTY0YzFEUDNqY2ZYN3Jmdit0VG4yMTFsNzdmT2UyOWs4cTN6bDdyMTJyVmxXdHFscHI3N08vd2V6WnN6OGREQWJONzRrMjIyeXo3K2JNbWZNRHRPdXV1MzQxZCs3Y2Y0cHV2LzMyRnhZdVhQZ1V0R2pSb3I5QXp6Nzc3RiticHJuNXQ2SUZDeGI4N1lVWFhuanNoeDkrK0dOMFhqUkpXVC8rK09QNzMzcnJyVDlINThhaHI3NzY2ay96NTg5L0ZaMTdlMnl5eVNiL21qZHYzaitpNi80WFpQVTJsR2V4VVB2dXUyK3ovLzc3TDFFNjVaUlRtcHR1dW1tRXJybm1ta1QzM1hkZjg5NTc3NDNRWlpkZDF1eTU1NTZwM2NNUFA5d3E4TWtubjJ3Ky8venpSQkYrL3ZublJHKzg4Y2JJTmI4RmJybmxsbGFHazA4K09SMzc1Sk5QMGwrTFByS2ltNTkrK2ltTk1RSjZFYStYWG5wcDZ1aGtnR3hYWFhWVjgraWpqK0xJYlQvUVdtdXRsZXdvdVpEemwxOStTWjl6K082Nzc1b2ZmL3h4NnR0aWNMMC9sb1BYMi9EdjRpOFBQdmpnVkpNWTZvUy96ei8vZlBQWlo1OU5uWmtPbks5cklBTEsvK0NERDhJQklDRE9ET0NIc3U2ODg4N20rKysvVDhvcUdSU3kxK1RhTG1rODk5eHpyY0tQUFBMSUpEZWZ2ZE5hV2RGSDVQUmd5bWpOcFpkZW1wM1FPTEg2eFBFbUNSelF5dmJ5eXk4MzIyMjNYZHNmdFB6eXl6Zjc3TE5QK3N4NEJGMkgzTmRlZTIyejFWWmJwVFo4dHJCMjc4S25uMzdhbkhiYWFjMUZGMTJVYkR6a3QxaUlBdzg4Y0twSkRIVXlUSjJwUGFUWkR5TTVETkdXY3llZGRGTDZYb1BjQUhEeXlHZ2NvMzNPNkw4MWNFNGNWNU9POGQxMTExMUorUVFEOUlQelJ1aUsxUEJqN0RpV2hiVUI0RnFjMlFjVzJwU0N3YmhBbnNzdnY3eFpiYlhWV3ZraC9JQnp0OTEyVy9xKzZxcXJqcHlIRGp2c3NDa3VpK0VuVFE1V1Z4QmpIdjVkL0dYWlpaZWRObmpMVkozWWlLUFpqNFBKOFo1NDRvbDA3b1liYmtqZmExQTdnTjhMdnY3NjYrUjBrSitRNkxpVU1XeWt6clhodU05bzFnWVdYcSswV1pMQkFQbHhyUFhXVzYvMWs0Z29RUmtudGdmSXcyZDBWd3Y2dXZ2dXU1dWpqam9xalFtOURIbi8yb2xWU0M0MW5uMzIyZWs0S2VYRkYxK2NOZ202REJhQnRuM2FXOURmbTIrKzJienl5aXU5ZURBK0wvdnZCZGdFQTNZaFo4TUk2R0pjRzFqUUp6Nnl5aXFydEg1bDZZQUREbWkrL2ZiYnFkYUxZZGRIVUs3dVIwYjRNeEZZUTBRWVh2OHJJNXNHYzZtUm1tbkhIWGRzRGo3NDRIVGUxa2dSYWhTVml5NDFZRWFUMXZiZWUrOU9IcEpsS2pWMXlqNFQwTThrSEFSNFhyVVpyYXU4c2NDSm9rbEN2MTBMTkdTNThNSUxtM1hYWFRmMUo2S1daaU9BUmVUMjIyOC9jcHkrNUtEMkdzalcvVGJ3WU90amp6MDJ0V0VORVdGNGJ0QXN0OXh5cVJHZEN6RHBTbnNJcFpTUlEwNVJNd1g5TTFqK1huTEpKYzErKyswM2RTWVB5VklydXdmdHYvamlpOVN2K3M0aG1xVFdPSDB3N29UdnNxRkZGUFhwYzhHQ0JhM09MQitWVlg2blEzN0VaS0ovZUdqeTBZZHR6NktRMHBUUGxBMzMzMzkvYzhVVlZ6U1BQUEpJOC9iYmI0ZUJ4OXVPdjdaTUdiWWZ0S3RVT2dDKzBVemdGZVVWWTFGcmNKVDB6RFBQSkw0b0MwVmNjTUVGVTJmemlJeG1BZC8zMzM4L2xJOXo2QWhpKyszNjY2OXZIbi84OFdtT2pmelI5WkZ4SWxnSEVFbzZteFQ4QXR3dXVIQnF6cjN6emp0cDRiZkREanUwNTBRczdCaWpsVE8zd0VVSFJHbWR3NW01RHA5angwTEhLVVdzODNwWW02aE1HWDRlTkxmZWVtdDdJbXBra1ROWURsNVJmTGJmaFZxRFIwcFNIOTRSa05WR1V5K0xoZVZMV3ZOQUZ6cFBTbFNFZ2l6UFhFYWlmeGxIc25oWUdUQ200SFhteDlrSHViNDkwQjJsQ3ZaZ0k0Q29LOWxFT0RadDRBZmZhSEtMaHovTytzdE9ET3B1blpzL2YzN2FGYkhYUlBBMkFZTlpzMmI5aDMxZG5WaTRjT0cwUmhZNWcrVlFxM3lFbDhFdHZGUHluVDFIMnZJZFFxR2NSMlliQ1hKT0YwSEtweDVuNnpFQ3ZPKzk5OTYwQ00wcG16YVJmbWl2TWVUYXdKY3hzRDVoTHpxQ3hvbU04SUtQN0pVaksydXVidy9zd1A2d3I0dWhndzQ2YUZvR1I3L3dyYkczdGNzNTU1elQ4cVVPUno0K2R3VTJRVGJSSW5Fd2RjdXlUUUVvakVha1ZOS3ZSNjFDUU9Sa2ZlR2RVank1QXdja1Q1OEZrSUNodVVGa2pWT0s0aUJuT09SaVV0anJiZWxtcitONFpQaWFNYWpOb1ljZTJweHh4aG5wYzRtd3F4MlA3OXRPTkVDV29IendmSWpRbEhrNFd1N0dsblRRRitoRi9ieisrdXZwdXc5c0lNZWY4V21NZ3lGeFA3d3QxbkVRZGpMVWdVMTlvTXZnRnVNNFdSYzhUeG1JZ2ZyVTFnVjdXem9xcjJxQnp1Qmhvd282c3J6NUhqbXhSYzBZMUVZM3NMb0l1NWFBWFBDaU52WUxQTDdURnphMzRCby9xU01kOUlIS0R5SjJoSWgvNU9DdFErczJKQmV5a2ljQ2tGcHlxYThHNHppWndDb1hnVDJSbHM4Ly8veTA3OXpsSUYzb0txOEFzbmZKejNrZlZXeDlkL0hGRjdlZjBhOUgzM0hZaU5aRkpZY21lNURtdWFsbXJ5RWFFNm43SU5KQmplNEVaUVhrQWZpT2JBNFBzZ0lUVC94ekU2aDFhTzdjMEVBS2g1SDMvbkhnQmFzQmJhWGNTUkxwbDNGeVUraTQ0NDVMZlRGZW5ObVBWWEt6a3pIdXBCWnZ4azFHaVNhM3h2cllZNDlWNmFlUE0wTjc3TEhIMUpXL2dzbm15NG9WVjF3eDFjemVJU083NVk1N0VNblJIVzNSQTdMclFUVVJrNTNzSURrMGtTZ0ZqemppaU9hc3M4NUtOdUNSQy9oeG5uTDQzWGZmblRhQlFPalFPZThYR0VqWFlBUmZBOWRBWmNXU0pKNE1FMUM0ZDJqa0ppSkFKYmt4R05sa1hHaXM1NTU3YnRKUkNaejM0eEJGZFMrRVhRSGpZMUw1c2dKSDVpKzNrRDJpMGdMa2pnTWNqQ2hMdi82NWppNWlwd05iOE5kbkRVOGJicmpoVkkrTElaOU1EbzJBbTIrK2VXcUlNM01DZ2IzM0M3Ui83YlhYUmhZOExCanNBT0hoYTY5YW9IeDJHL3dnSmtrNzdiUlQ2a3VUbHpMR1QxTEdCZVZndDluZ0U0R3hlTDRXbkNkd2FNODFoNUl6Y3c1SGlNN3hXRENPN0hjcm1BQlhYbmxsaW5ZMVpTRzJoQTk5RVZFVllVVkVkODdwMFlnK3hHMXlzbWEwbzFJaTYxK3kxV0FvNUhPMkVSRUQyS2pGWU8yQTA0VlQ3Vys4OGNiMk15VEQ4cmRrb0M3WXJVUVIwWVhhbVRTRW5NaElUYzIrcGVwcWpsbkNXSjRQcEx1aWpJdWJNang3emE2T3J2TUc1cnMvcnFobkhZSkpMY05qNkMyMjJLTFpZSU1OMG1mYlB3YlUzaXZ3aTIxNFM1YlNBdkR3d3c5UDdXa1huYmMzTVBpTU15b1F2ZnJxcTlrSnkzalFMUk10Ri8xblNqZ3crb25PMVpDM0VSZ01ELzRCQTZ5ODhzcXBFWXBSMUZMSkllOFg3SUtINTZqOUUwK0E2TjUzc1FQa05MdnR0bHZieCt6WnM5UGpyVjIxTEgzS1dQQmdVa1IzdFhpRU1jb2VaQjJlV2VZMk9uZXNiQVRhY3NzdDA3VmtNcjZqTXdzY01PcXJpL3d1a3FCU0RWbWk2eUQwTGgzTFpoR1IrcTF0Z0NZQTF5RzdQM2ZNTWNlTVRJWkpFUHhZdTV4NjZxbnBPejdqMjFoaThpRUwvc1puRzhGemk5MVVjakFZTllRQk5TRUtzQ1VIeHhXeEFZcndpeW40MERucGgrZ0RENjZyTFQxa2xQWFhYNytWNTQ0NzdrZ1JtZFNZaXlhQWM3b0dHZUNWY3dhL280RjhmZE1keHJINndiR2lkaVhpR1JwdUorZUEvcUxySU1abklkMTVZcEpaWndYb1NuZUhtWmpvaXd5RjNYeU5iV25PbkRucC9CcHJyTkhNbWpVcmJGTWl4Z09RaHdlV0NGUTZoejRKb094RHM3dEdTY2huQ3lZL0pSVFpOZWRUS1VMek1JZ1lhNUZpRlNabEtXSmJvQndXQVYzUlNiTlRFVFFDQTlYVFZCQVJxTlMzaGMwYU9DelJObHBZRUYwOU1LcHYxMFcyWEJCeVRtV0puNVJSNHVnN2NrZm80OHp3eUQxL0xDY1NiTjNQT3VXamp6NXFOdDEwMDVGcitoSVRFeDY1UjBaRlZoYTdzd0d4RzZPSmgwL1IxbWI0V2o4WThFTktacWNZNHd6OHRTbVZqdWpBTHhKeC9yNXBTVE14QXM0dWZuS1lYTjhSR0xTeUJncUsrbzRtRkgxUUozYXR5bkVhWkdFQlREa1R3VTRzVDBRayt2S1R6NEx6dVpvWitiWEdBUmljQ1JxMUZWa25RaS9VeGFSOG9pQ1RLN29tUndRdCtvTW5jcE45a1ZlQXYrNW5SR1JsNFhQVXBrU01uMUt3NUF2dExvY3VRaWdjemdvS2FLTVpReHQ3RDk0VGtaaW9YVXJqT0p4M0xqa2hhYzMzYjhFNXIwd0w1UGY5UWRGT2hzQnhwVEVVRnYxVUNDSnI0SkRXT0I2TVBib1cwbVRXNU9NWkJKcytiZlMyaERHMVI0dDg2TmllenpuU3R0dHVtNXhRZ2FLTFZsaGhoZll6dDliUmN5bXJlcFFtTkRyRGQrREp4TkxPMmpoRUFJS1hSM0pvT3FBUkVTcUMzNTd5VVFGbFVkY1FQYnpETUJFd1V1VGNISk5RVmhISVUwS1VrZ1NNSFJtUFJSMTFlSFFOWUZ6V1NaOSsrdWxwUENCMkxMZ0prbk5veGhPTmxRREFOVDY2Mkg1THBRODZKM0lmZmZUUkk4ZlpKWmczYng2dmRoZzVYaUtjZjUxMTFwbDJITG1SUjkrN2ZqanR3ZGhLTlRqalpITHdGNkltanRyVkVqN2prUnhhS1M2M2NzUklLSnZvd2s1RERlTUlrY0dZTFBDWFFkaGxtQWx5S2JobWg4UTdPMHFQZVBFOE5KTXFncThOSVJ3bGx4bHN2K1BzNFhZUkM3a1RUend4M1dtenoyOXJWOHNTemd5WUlIem5FYzVhd0xQa3pKQW1iZ1RrZ3BUOWtKbHIrSFdVcnVkbWlqNUQwVjNRd1hDMStYYzF3Qm1BTFM4OFdBbGJwcnFtQmxIMElyTGJhSWppeDRXTkxwWk9PT0dFb2pJRkZLcU1JZVFtaUYxakNPZ3RhaXRINlVLdXIwa1JkVE42c0wvY3Q0U0RVUDdnbkxUejJTUUNiY25NTlZ1V05UWVFzSU5LWC9SSGVjWXpScFlmaTFwTlVQbnNnTGY1YUdlQkFkazBZQTNCUlZ5ODhjWWJ0K2NoWmozbmF1R2pOT1hCSVljY2tqNTNUWTdJNFFRTUVTM3FpQnFVQ0N4OFM1TkZrMEUxcmdEZktQSWd0eDZnMHZnam8wWmpvcjNxWmxJd2ZYZXRPU1pCeXNESUhKMkhrQ0hLUHJJL2Y1RVpPL2FkZ05haG1TeGtKREthWFVORXdPYm95T3FYblJXMi91QTVVcm9NMjk4c1k5cTZDdSszanNvZ3VkaHVEN0V0Um4yY2krWVJmRnJkYUtPTjJzOTJCZStSY3pqQkw1SkVLUDZlZSs1cHYvUDd3d2lNTlJlVkdOOHl5eXd6d2hkaXZ4eWxjcDZIelAxNW5GNlJBNlBJS2RBdGRXekpnWmRlZXVuMk0wR0V1NkdNL2NzdnYwd0daRkZGU2NBZVBTVmpLZDNURjg0bk82SG5xRjFFMnRuWVpaZGRrcncrb1BVaE9UUTZ0c2NKcEpRYVBsaFJqdUl2MFpySStvRjkzSGxrVVloRDR3QUs5UkU0MTE0OEpGYXF1YWpwWVJlWElzMDZhcm9TbjVMRDVReDAvUEhIcDJ1b2VYVnM3dHk1VTFmbElTZTAwSTg1UFdGc0lvd2U4ckZFZVNiWjJLZGRhcW1scHJXQnlDdzRIWS9zcnIzMjJpUEgvUVNXcmJqaFJEQ0JrRGNYTFdudmdaN1o4ZUY4Ym5la0wrSHNaSm5JeGlJNXRJTFRPRVEvNklReHlFWjhsdCtPT0RTVWN5b2NDc05CZnNad205Uy9hOEdEZ2ZxSVJOcllldXV0MCtmZGQ5ODlPNGxLUUo0bzBuSE04cVBzSUlybjN1Y2dXSU9nZUl0Y0ZvajZYMm1sbGRyYjVaN0lja1FlK0pPK2tVMnZ6aEp4UHRKSGJtTGxDQ2V6R1VLa2lZWWpZSC9HeHFTSW9tRkV0S005KzhLK2xJdmFROHJtUGt2WDBPcXJyOTdlWXdEeVdXK2o1TkFNVUNtVm1XdWhhTVdGbW1IOHRaMkppTGJVUkRnRmtSUUJVRlNrSkk2aFRMYkIrRTRkVDE5OWtWTk9xWHdwQVlYeEtDY0xLTzlRZkI4bm9qSFdiYmJaSnIxa3hmLzRFMTNacUF4L254MHNhbjUyRlJFVFRORWNZcHpZc1JTSXNDR09BeUVuN2ZuTWNjYmc5U05FL1Z0aUp5czZIaEZ2SkdESHcyZG1PeUVGNUVrT3pSY01TQU1XYUlLTlZyd3ZnUVdnd01Dc0lmb1FOUk9SQ2RLeHFKVG9ncFhQRXBOb0pyQ1RWNUFCa2JrbWlySHhqN0pwcit2dDRvZngyb2dQVC9wVUJNbzVOVHg4Tks4bHRrWXRvbkhXUWhNalF0UTNSRWxGV2NERCt6cEdXWVVNNkl1SUQrbFJWSHdzQi9RRUx6dXBHRS9yMFBhZGRUZ0s0Q0tNWXU4SzJoQVBzejdwQTZPcEpvUTNDeDJPTXd2SFFSUXRVWkIxbkhIQTlkNVlNaUJFcFBYOWlzaDAwZVNVOHlneTJrbUJFZVg0QUVOeTNPb2FvRy9PUGZUUVErazhOMW5JYlBDelRoSHR0dXk4ODg3VFNnUGt6RTBjK3RIazZndmZ0d2hmZ1MrRVgwRzVSd2pHQWVOcEhkb2FDcWV3QnBWait4a2hCWk8yS0ZWWWJiT3ZMRWREc2RSd3V1OXZnUUhWampxc0wrZ2JPYVVzaUYwWDVKd1U2RU9UQTc2bGNvTmRCdWpxcTY5TzdUMVFObThndGZVMjdhT2JVbEU2QmRnRXh5V0NrVkhaN2VEN3BKRWkzYkIvQlo4STZBWmlRaUNuSmxWdW5aRWpmQVErazBMcjBBRGphZnNIWnluVmNrQUs5dTJrRU1oSEdZRkpva2NRTWN3NElKTXc2NGxLYkN0MTlla2hvK1FBSHprTWY4V2YvamluYXhsTGlROXkycWpweXdzUGp2dmdZYUhJR21VU3Joa25RM0VkUVllL0VQSkZtUVp3ZksrOTltckhNeE5DTDlLZitwOEpra1BEU01wRldEazFpaDhuNGlHVWJsM21yaWN5YVZDVU94NWRUdUpCZS9yQ0VkakpZRXhRNmZkK09JTjNDSUhqaXhZdGFpY3Jlb0YzWkdUZHJ2V2dmNXhmNDRSS3ovSmFPM1FCT1h5WndyVjJFcUsvV3VmT0JhY0kwZTM5V21KN2x1QkRYK2hOTnU3cXYwWXUwTjc2dHVrRlJiRndreERVWmxaNU5VQzVVWlRoT01yWEUybjhXRFZ5aHB5VFdLQ0VhS0RJeXJYY2RLQ1BVc1NPZU5qRlprMjB0MDRFdU40N01xbVl2a0RVSnp4b1orMlFBOWVMTDNxeTErTG80dTNsc3FoMWtBZ0VESldZakl1eDR1VDBCUkZZc0xHb0pqRGhGN2wyOEdCOE5iWkl0NzRSd2tjZU9yQXprV2hON1ZZalhBbHlOdDF4NHE1WnBOeVNNVUNOMDlsYVZCUEpLampIZzdhSzltcGJVamhSa0xmenMxYndkYloxWkdEN3RLVVd2Q003ZUNDSGYrbDg3dHB2dnZsbUpFTXhkdW1CYTczZUloMUZZRHowTjg2a2dHL0VtekVSZ1B3NVpMcnV1dXVTdk9lZGQxNVJMakJTUTBkZ2NOWkkvQ3FCQjhUSHFkTUVoTlNkdGR4K01meXRJM2pBd3p1ZGdHSFpHdUwyTUlwbmRmL2hoeCttejVENGxuaDQ1RElHZkZuVSt1ZW52U01MOU1uQ2tVWGRPSzgvUUE0aUkyOWN0VGNhSWxpWjlid0RUbVAveTRMTnZBbzJWa2Q5Z0E2NzlBamZpRGR2c2VJbmMzNlNJQlBabktjRzJXM3JraXQwYUpUa0JjUG8vcEZERm1SU1NNMWdPTThFVVlSaFY2THJtcjVnd0pLUFc5NjhDcGJQdVJkazE4Sm1EQ1lNRThFdVJDRVcwbVMxcmlqcmdjeFJ0SXZzZ0J6YXFzdUJhd2dJVm1hY21NQ0VUdmgxTy9xUTNEaitKSkJ6MWhyWUFCYU51eGFoUStlaWtVMTFsbEFVRDgrWGZ2QUpFSmpvc3VhYWE2YnJpR0lXRE1JT3hIK1A0TnNndStRcXBXUEE1Q3BGT0s1VkppSVNjNmN0MnVPRitHVklpWmNIYmVtZnJUeng4Q1VBK2taZkZzakQ3eVZMNlY2T0xDZUpTaXV2SjJHY01xSUxOUTVxMjBUKzUzbjRKeDJGMEtIdHpQWWcxYUhrQng1NFlKcHhxYk54VWhRa1I3REFxWFFOYlgwYlA4UDk5d2hSRytUdlNzZTBRUTVlelJ1QnpIUG1tV2NtUjQyZTFXQVNFNDFKbFRnbERwOHpXbVJRK0JNRVRqLzk5QlExMGJkdlErM0l6Wk1jM3h6UXMzVk0rbzlLSzY4bkhJU3h5ZWtuQmQ0aHlFMjBFcXdUZS85RFpudE1heU15bForQUl3N053QmdVTDZNdS9jTERkbzVoTUd4a2RJZ1ZNR1RyY0p5WnFKRURBK2hyUk5BVmNTM2dyMTBRK3p0QlpQVTNiRVFzWkhFTWxWa0NTbzJpcVJCRkhBQWZqa1BSeENYajZZRWVZUklSTk1jamQwTm5KbUJjMGg5NnlNRTZyREtMd0RtVldaWWZ6OXg0akRoMGw0SUZQNE1FSEFybjFqNTJSRVJvMm5rUVZlUW85RjNxUHdJeXdaOG9GQUgrOU12aUNFZm1BWm11SDJreVNYbVNVTjhqQldxeFJXYkMrU0xrOUZVTEJSb2NqYjdnTnk3Z2srTkJQOUVDbWU5UnhyVkF2emlzbnl3Y2svNXNhZU5CRUdXbktBSzg5WllueTQ5bjBEM1NlemtZSkZRYkZmME1pb0J6eWdnWWsramxGYW5CdzB0Q2xtWnhCSzZsSDE0RFJ1cm1iWlk0TEc5ZTRpR2UwdVN5Uk5ZZ091c1paazJ1a2dMbEhCQXZic25wcEVaZkpTalFkTjJzS2dGWmNWanRjQkI0YXRFMUlhMzlJRDlaK0Y0cUFUblBkYmxnNUZIaU54aW0wWDlqZElpMzFSQkJjUVlja0VGTWltUU1ucmppdTE0SFJTcXhEK0FUT1RtUHdsV3VXRks3Y1lueHdRZkhSWUVZbWdoUWdpWWp6eTFiS0VYcm45NHNhV0JBZGlmNmJQZHhqYklJNDdXN0c5N3hja0EvQ2o2TTA0L1ZUbm95bGIxVFc2TVgybUR6TGp2VVlDakRxTUYvejBTZGpyT2lWRTBrYXZWYXhWclkxSm1yTFhHV0tFWFBCQmhWMlVHZ0g4WlEyaEhKQVdkVGNJSTNOMXNJRmxadU85YW9mNEFNdENjYVI5bkdSazFsRkdnbW1Xa2NESVlyMEtjUVJnSll3akcwbU9NblJJcVNSRG5lTWFidnRhUWREbmlTQmZoTkhtV0I3WU85N1VnV25JbElvNWtQZGRWMWdod0NxbkUrMmxtbkdkZHhmVDNaQlp1NmJla2xCMkZYaEpzeWZXU1JiVDNrb0hhc0xFTFZQNHRjQytTSitQeS9JZHkyczJEUURFVHBnSUV6WUpUYUZ6YlNXV1A3UGlKNEp3TTRRSTNUOUlrWXlLSTZVeEc1dGgrTFNONHUyTlJkV2tEMVFhNStsNE5hbTFDR3FYOG1qMFZ1WXRRZzBoMzZZVko1M1k2amE0dE9oeFlVNVZoOGtjSkt6cGNEUEZDSzNndlJ4OWcrN2VlZXc1Z3BVQ2lyYlVYQmNmdkpsU2xkb0ErY3lmOEhNdWtmUXE2WlFnNEtYNDJWejlpV1h5ZnB0NWNjWjFLTXU3Q05KamFmT2NhN3JhMXUrK3A2dXVNM3pYOEIwUkVJbU80Q3ZsY0FBQUFBU1VWT1JLNUNZSUk9HwRnZGQCBQ8WAh8EZ2QCMQ8PFgIfAAU8UG9ydGFsIGRvIENULWUgMjAxNiAtIENvbmhlY2ltZW50byBkZSBUcmFuc3BvcnRlIEVsZXRyw7RuaWNvZGQYAwUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgYFD2N0bDAwJGlidEJ1c2NhcgUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwMiRJbWFnZUJ1dHRvbjEFKWN0bDAwJGdkdkxpbmtzRGVzdGFxdWUkY3RsMDMkSW1hZ2VCdXR0b24xBSljdGwwMCRnZHZMaW5rc0Rlc3RhcXVlJGN0bDA0JEltYWdlQnV0dG9uMQUpY3RsMDAkZ2R2TGlua3NEZXN0YXF1ZSRjdGwwNSRJbWFnZUJ1dHRvbjEFJGN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkc29tQ2FwdGNoYQUmY3RsMDAkQ29udGVudFBsYWNlSG9sZGVyMSRtdndDb25zdWx0YXMPD2QCAWQFFmN0bDAwJGdkdkxpbmtzRGVzdGFxdWUPPCsADAEIAgFkMj1UgqSNwF03uFLRldNLJAqHxXA=" />
                                <input type="hidden" name="ctl00$ContentPlaceHolder1$btnConsultar" value="Continuar">
                                <input type="hidden" name="ctl00$ContentPlaceHolder1$txtCaptcha" value="">
                                <input type="hidden" name="ctl00$txtPalavraChave">
                                <input type="hidden" name="hiddenInputToUpdateATBuffer_CommonToolkitScripts" value="1">
                            </c:when> 
                            
                        <c:otherwise>
                            
                        </c:otherwise>
                    </c:choose>--%>
                    
                    
                    <td rowspan="2">
                        <input name="ck<%=linha%>" type="checkbox" value="<%=cte.getId()%>" id="ck<%=linha%>"
                               <%= cte.getStatusCte().equals("E") && !cte.isLiberarEnvioCTePreso() ? "disabled" : ""%>
                        >
                        <input type="hidden" id="podeEnviarCTePresoEnviado<%= linha %>" name="podeEnviarCTePresoEnviado<%= linha %>" value="<%= cte.getStatusCte().equals("E") && cte.isLiberarEnvioCTePreso() %>">
                    </td>
                    <td align="left">
                        <%if (cte.getStatusCte().equals("C") || cte.getStatusCte().equals("L") || cte.getStatusCte().equals("F")) {%>
                        <img class="imagemLink" alt="" title="Imprimir DACTE" id="img_imprimir_<%=linha%>" onClick="javascript:tryRequestToServer(function(){popCTe('<%=cte.getId()%>', '<%=linha%>');});" src="img/pdf.gif">
                        
                        <%}%>
                    </td>

                    <td >
                        <input type="hidden"  id="numeroCTRC_<%=linha%>" name="numeroCTRC_<%=linha%>"  value="<%=cte.getNumero()%>">
                        <div class="linkEditar"  onClick="javascript:tryRequestToServer(function(){editarconhecimento('<%=cte.getId()%>',null);});">
                          <%=cte.getNumero()%>
                        </div>
                    </td>
                    <td align="center">
                        <font color="<%=cor%>">
                        <%=cte.getSerie()%>
                        </font>
                    </td>

                    <td align="center">
                        <font color="<%=cor%>">
                        <%=cte.getEmissaoEm() != null ? new SimpleDateFormat("dd/MM/yyyy").format(cte.getEmissaoEm()) : ""%>
                        <input type="hidden" id="emissaoEm_<%=cte.getId()%>" name="emissaoEm_<%=cte.getId()%>" value="<%=cte.getEmissaoEm() != null ? new SimpleDateFormat("yyyy/MM/dd").format(cte.getEmissaoEm()) : ""%>"/>
                        </font>


                    </td>
                    <td>
                        <font color="<%=cor%>">
                        <%=cte.getRemetente().getRazaosocial()%>
                        </font>
                    </td>
                    <td>
                        <font color="<%=cor%>">
                        <%=cte.getDestinatario().getRazaosocial()%>
                        </font>
                    </td>
                    <td>
                        <font color="<%=cor%>">
                        <%=cte.getCliente().getRazaosocial()%>
                        </font>
                        <input type="hidden" id="averba_<%=linha%>" name="averba_<%=linha%>" value="<%=cte.getCliente().getStUtilizacaoAverbacaoCTe()%>">
                        <input type="hidden" id="seguro_<%=linha%>" name="seguro_<%=linha%>" value="<%=cte.getCliente().getSeguroCarga()%>">
                    </td>
                    <td align="right">
                        <font color="<%=cor%>">
                        <%= Apoio.to_curr2(cte.getTotalReceita())%>

                        </font>
                    </td>
                </tr>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                    <td/>
                    <td colspan="7">
                        <a id="ver-notas-cte-<%=linha%>" onclick="isExibirNotas(<%=linha%>)" style="cursor: pointer;">Ver notas</a> 
                    </td>
                </tr>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" style="display: none" id="tr-notas-fiscais-<%=linha%>">
                    <td>
                    <td colspan="8">
                        Notas Fiscais: <%=cte.getNotasFiscais()%>
                    </td>
                </tr>
                <tr>
                    <td colspan="10">
                        <table  width="100%" cellspacing="1" border="0" >
                            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                <td width="3%">
                                    <%if (cte.getStatusCte().equals("C")) {%>
                                    <%if (cte.isCteEnviadoCliente()) {%>
                                            <img class="imagemLink" alt="" title="Enviar CT-e Cliente já Enviado" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){enviarEmail('<%=cte.getId()%>',  false);})" width="25px" src="img/outc.png">
                                    <%} else {%>
                                            <img class="imagemLink" alt="" title="Enviar CT-e Cliente" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){enviarEmail('<%=cte.getId()%>',  false);})" width="25px" src="img/out.png">
                                    <%}%>
                                    <%}%>
                                    <%if (cte.getStatusCte().equals("L")) {%>
                                    <%if (cte.isCteEnviadoCliente()) {%>
                                    <img class="imagemLink" alt="" title="Enviar CT-e Cliente já Enviado" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){javascript:enviarEmail('<%=cte.getId()%>',  true);})" width="25px" src="img/outc.png">
                                    <%} else {%>
                                    <img class="imagemLink" alt="" title="Enviar CT-e Cliente" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){enviarEmail('<%=cte.getId()%>',  true);})" width="25px" src="img/out.png">
                                    <%}%>

                                    <%}%>
                                </td>
                                <td width="3%">
                                    <%if (cte.getStatusCte().equals("C")) {%>
                                        <%if (cte.isXmlEnviadoFtp()){%>
                                            <img class="imagemLink" alt="" title="Enviar FTP já Enviado" id="img_ftp_<%=linha%>" width="25px" src="img/ftpeok.png" onClick="javascript:tryRequestToServer(function(){enviarXmlFtp('<%=cte.getId()%>','<%=linha%>');})">
                                        <%} else {%>
                                            <img class="imagemLink" alt="" title="Enviar FTP" id="img_ftp_<%=linha%>" width="25px" src="img/ftpe.png" onClick="javascript:tryRequestToServer(function(){enviarXmlFtp('<%=cte.getId()%>','<%=linha%>');})">
                                        <%}%>
                                        <input type="hidden" id="cliente_envia_ftp<%=linha%>" name="cliente_envia_ftp<%=linha%>" value="<%=cte.getConsignatario().isXmlEnvioFtp()%>">
                                        <input type="hidden" id="id_ftp<%=linha%>" name="id_ftp<%=linha%>" value="<%=cte.getConsignatario().getConfigFtp().getId()%>">
                                    <%}%>
                                </td>
                                <td  width="3%">
                                    <%if (!cte.getStatusCte().equals("E") && !cte.getStatusCte().equals("L")) {%>
                                    <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  href="./<%=cte.getChaveAcesso() + "-" + (cte.getStatusCte().equals("L") ? "eve" : cte.getStatusCte().equals("C") ? "cte" : "neg")%>.xml?acao=gerarXmlCliente&idCte=<%=cte.getId()%>&status=<%=cte.getStatusCte()%>" target="pop3">
                                        <img class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml_<%=linha%>" width="25px" src="img/xml.png">
                                    </a>
                                    <%}else{%>
                                        <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  href="./<%=cte.getChaveAcesso() + "-" + "cte"%>.xml?acao=gerarXmlCliente&idCte=<%=cte.getId()%>&status=C" target="pop3">
                                            <img class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml_<%=linha%>" width="25px" src="img/xml.png">
                                        </a>
                                    <%}%>
                                </td>
                                    <%if (!cte.getStatusCte().equals("E") && cte.getStatusCte().equals("L") ) {%>
                                        <td  width="3%">
                                            <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  href="./<%=cte.getChaveAcesso() + "-" + "eve"%>.xml?acao=gerarXmlCliente&idCte=<%=cte.getId()%>&status=<%=cte.getStatusCte()%>" target="pop3">
                                                <img class="imagemLink" alt="" title="Imprimir XML Cliente Cancelado" id="img_xml_<%=linha%>" width="25px" src="img/xml.png">
                                            </a>
                                        </td>
                                    <%}%>  
                                <td width="5%">
                                    <img align="center" class="imagemLink" alt="" title="Consultar chave de acesso" id="img_consultar_<%=linha%>" onClick="javascript:tryRequestToServer(function(){submeterConsulta('<%=cte.getChaveAcesso()%>','<%=linha%>')})" width="30px" src="img/pesquisar_cte.png">
                                </td>
                                <td  width="42%" align="left" >
                                    <label class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                        Número do recibo:
                                        <%if (cte.getStatusCte().equals("E") || cte.getStatusCte().equals("F")
                                                    && cte.getFilial().getIdfilial() == Apoio.getUsuario(request).getFilial().getIdfilial()) {%>
                                        <a href="javascript:atualizarRecibo('<%=cte.getNumeroRecibo()%>', '<%=cte.getId()%>')">
                                            <%=cte.getNumeroRecibo()%>
                                        </a>
                                        <%} else {%>
                                        <%=cte.getNumeroRecibo()%>
                                        <%}%>
                                        <br>
                                        Chave Acesso:<%=cte.getChaveAcesso()%>
                                    </label> 
                                </td>
                                <td  width="35%" align="left" >
                                    <label class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                        Data/Hora de Envio:<%=cte.getDtHoraEnvioCte()%><br>
                                        Status:<%=cte.getDescricaoStatus() == null ? "" : cte.getDescricaoStatus()%>
                                        <%= cte.getUsuarioEnvio() == null || cte.getUsuarioEnvio().equals("")? "" : "<br>Usuário " + (cte.getStatusCte().equals("L") ? "Cancelamento: " : "Envio: ") + cte.getUsuarioEnvio() %>
                                    </label>
                                </td>
                                 <td  width="15%" align="left" >
                                     <input type="hidden" id="utilizacaoApisul" name="utilizacaoApisul"  value="<%=cte.getFilial().getTipoUtilizacaoApisul()%>">
                                     <input type="hidden" id="dataAverb" name="dataAverb"  value="<%=new SimpleDateFormat("yyyy/MM/dd").format(cte.getFilial().getDataInicialAverbacao())%>">
                                    
                                    <label class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                                    

                                       <input type="hidden" id="imprimirAverbado_<%=linha%>" name="imprimirAverbado_<%=linha%>"  value="<%=cte.isImprimirAverbacao()%>">
                                       <input type="hidden" id="averbacao_<%=linha%>" name="averbacao_<%=linha%>" value="<%=cte.isAverbado()%>">
                                       <div style="<%=cte.isAverbacaoVisivel()? "display:" : "display:none" %>">
                                        Averbado:                                    
                                         <%if (cte.isAverbado()) {%>
                                        <a href="javascript:alert('<%=cte.getProtocolo()%>')">
                                           <b> Sim </b>
                                        </a>
                                        <%} else {%>
                                        <a href="javascript:alert('<%=cte.getProtocolo()%>')">
                                          <b> Não</b>
                                        </a>
                                        <%}%>
                                        </div>
                                    </label>
                                   
                                    
                                </td>
                                <td  width="2%" align="left" >
                                    <%if (cte.getStatusCte().equals("C") && cte.getEvento()!=0) {%>                                    
                                        <img class="imagemLink" alt="" title="Imprimir CC-e" id="img_imprimir_cce_<%=linha%>" onClick="javascript:tryRequestToServer(function(){popCCe('<%=cte.getId()%>', '<%=linha%>');});" src="img/pdf.gif">
                                    <%}%>    
                                </td>
                                <td  width="2%" align="left" >
                                    <%if (cte.getStatusCte().equals("C") && cte.getEvento()!=0) {%>
                                    <a onClick="javascript:window.open('', 'pop3', 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1')"  href="./<%=cte.getChaveAcesso() + "-" + "cce"%>.xml?acao=gerarXmlEvento&idCte=<%=cte.getId()%>&status=<%=cte.getStatusCte()%>&evento=110110" target="pop3">
                                        <img class="imagemLink" alt="" title="Imprimir XML Carta de Correção" id="img_xml_<%=linha%>" width="20px" src="img/xml.png">
                                    </a>
                                    <%}%>  
                                    
                                </td>

                                <td width="2%">
                                     <%if (!cte.getStatusCte().equals("F")) {%>
                                    <img class="imagemLink" onclick="consultarProtocolo('<%=cte.getId()%>')"
                                         alt="" title="Atualizar protocolo de autorização" src="./img/atualiza.png">
                                    <%}%>
                                </td>
                                <td width="2%">
                                    <%if ((cte.getStatusCte().equals("C") || cte.getStatusCte().equals("F"))
                                                && nivelCancelarCTe == 4) {%>
                                    <img class="imagemLink" alt="" title="Cancelar CT-e" src="./img/cancelar.png" id="bot_cancelar_<%=linha%>" onClick="javascript:tryRequestToServer(function(){cancelar('<%=cte.getId()%>','<%=cte.getNumero()%>','<%=cte.isTemFatura()%>','<%=cte.isTemManifesto()%>','<%=cte.isTemRomaneio()%>', '<%=cte.getEvento()%>');})">
                                    <%} else {%>
                                    &nbsp;
                                    <%}%>
                                </td>
                            </tr>
                            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" <%= cte.getStatusCte().equals("N") && !cte.getPossiveis_solucoes().trim().equals("") ? "" : "style='display:none'" %>>
                                <td colspan="3">
                                    Possível Solução: 
                                </td>
                                <td colspan="6">
                                    <%=cte.getDescricaoStatus() == null ? "" : cte.getPossiveis_solucoes() %>
                                    <%if(cte.getDescricaoStatus() != null){%>
                                </td>
                                <td>
                                      <img width="25px" height="25px" src="img/consulta_48.png" class="imagemLink" 
                                      onclick="visualizaImagem('img/solucao_cte/',<%= cte.getId() %>,'<%= cte.getCaminho_imagem() %>')"
                                      alt="Imagem" <%= !cte.getCaminho_imagem().trim().equals("") ? "" : "style='display:none'" %>/>
                                     <%}%>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%linha++;
                        }
                    }%>
                    <input type="hidden" id="qtdLinhas" name="qdtLinhas" value="<%=linha%>" />
            </table>
        </form>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <%String statCte = request.getParameter("statusCte");%>
                <c:if test="${param['statusCte'] eq 'C'}">
                    <td width="25%" align="center">
                        <button class="inputbotao" type="button" name="btnBaixarXMLs" id="btnBaixarXMLs">
                            Baixar XMLs selecionados
                        </button>
                    </td>
                </c:if>
                <td width="25%" align="center">
                    <%if (statCte != null) {%>
                    <% if ((statCte.equals("P")) || statCte.equals("N")|| statCte.equals("F") || statCte.equals("E")) {%>
                    <input class="inputbotao" type="button" name="botEnviar" id="botEnviar"                                
                           onClick="javascript:tryRequestToServer(function(){enviarCTe();});"
                           <% if ((statCte.equals("P")) || statCte.equals("N") || statCte.equals("E")) {%>
                           value="Enviar CT-e(s) selecionados para SEFAZ" id="botEnviar"
                           <%} else if (statCte.equals("F")) {%>
                           value="Enviar CT-e(s) em FS-DA para SEFAZ" id="botEnviar"
                           />                     
                    <%}}%>
                    <%}%>
                    <%if (statCte != null) {%>
                    <% if ((statCte.equals("C")) ) {%>
                    <input class="inputbotao" type="button" name="botCCe" id="botCCe"
                           onClick="javascript:tryRequestToServer(function(){novaCCe();});"
                           value="Gerar Carta de Correção (CC-e)" id="botCCe"/>    
                    <%}%>
                    <%}%>
                </td>
                <td width="25%" align="center">
                    <%if (statCte != null) {%>
                    <% if ((statCte.equals("C")) ) {%>
                  
                    <input class="inputbotao" type="button" name="botAverbar" id="botAverbar"                                
                           onClick="javascript:tryRequestToServer(function(){averbarCTe('<%=Apoio.getUsuario(request).getFilial().getTipoUtilizacaoApisul()%>');});"
                           value="Averbar CT-e" id="botAverbar"/>    
                    <%}%>
                    <%}%>
                    <%if (statCte != null) {%>
                    <% if ((statCte.equals("L")) ) {%>
                    <input class="inputbotao" type="button" name="botCancAverb" id="botCancAverb"                                
                           onClick="javascript:tryRequestToServer(function(){cancelarAverbacaoCTe();});"
                           value="Cancelar Averbação" id="botCancAverb"/>    
                    <%}%>
                    <%}%>
                </td>
                <c:if test="${not param['statusCte'] eq 'C'}">
                    <td width="25%" align="center"></td>
                </c:if>
                <td width="25%" align="center"></td>
            </tr>
        </table>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="30%"><center>
                Total de Ocorrências: <b><%=qtdResultados%></b>
            </center>
        </td>
        <td align="left" width="20%">P&aacute;gina: <b><%=paginaAtual + "/" + pag%></b></td>
        <td width="25%" align="center">
            <input name="voltar" type="button" class="botoes" id="voltar" value="Anterior"
                   onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value,'anterior', ordenacao.value, tipo_ordenacao.value, valor_consulta2.value);});"/>
            <input name="avancar" type="button" class="botoes" id="avancar" value="Próxima"
                   onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value,'proximo', ordenacao.value, tipo_ordenacao.value, valor_consulta2.value);});"/>
        </td>
        <td width="25%" align="center">
        </td>
         <td width="10%" align="center">   
        </td>
         <td width="10%" align="center">   
        </td>
         <td width="10%" align="center">        
        </td>
       
        
    </tr>
</table>
<br>
<c:if test="${param['statusCte'] eq 'N'}">
    <jsp:include page="gwTrans/blip/chat_blip.jsp"/>
    <script>
        configurarChatBlip('${configTecnica.blipChaveApp}', 0, {
            'id': '${user.id}',
            'nome': '${user.nome}',
            'email': '${user.email}'
        }, {
            'razao_social': '${user.filial.razaosocial}',
            'cnpj': '${user.filial.cnpj}',
            'telefone': '${user.filial.fone}',
            'cidade': '${user.filial.cidade.descricaoCidade}',
            'versao': '${versao}'
        }, true, false, {'tela': 'cte'});

        executarChatBlip();
    </script>
</c:if>
<script defer src="${homePath}/script/funcoesTelaCTeSefaz.js?v=${random.nextInt()}"></script>
</body>
</html>
