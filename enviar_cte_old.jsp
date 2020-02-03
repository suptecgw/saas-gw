<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.BeanConsultaConhecimento,
         conhecimento.BeanCadConhecimento,
         nucleo.Apoio,
         nucleo.BeanConfiguracao,
         nucleo.impressora.*,
         usuario.BeanUsuario,
         java.text.SimpleDateFormat,
         java.util.Vector "%>
<% 
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
            
            /*
            int nivelMontagem = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("montagemcarga") : 0);
            int nivelUserManifesto = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadmanifesto") : 0);
            int nivelUserCartaFrete = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("lancartafrete") : 0);
            int nivelUserViagem = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("lanviagem") : 0);
            int nivelUserToFilial = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
 */
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }

            SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

// Iniciando Cookie
            String campoConsulta = "";
            String valorConsulta = "";
            String dataInicial = "";
            String dataFinal = "";
//            String agencia = "";
            String statusCte = (request.getParameter("statusCte") != null ? request.getParameter("statusCte") : "P");
            String filial = "";
            /*
            String impressos = "";
            
            String idRemetente = "";
            String remetente = "";
            String idDestinatario = "";
            String destinatario = "";
            String idConsignatario = "";
            String consignatario = "";
            String serie = "";
 */
            String operadorConsulta = "";
            String limiteResultados = "";
            Cookie consulta = null;
            Cookie operador = null;
            Cookie limite = null;

            Cookie cookies[] = request.getCookies();
            if (cookies != null) {
                for (int i = 0; i < cookies.length; i++) {
                    if (cookies[i].getName().equals("consultaCtrc_cte")) {
                        consulta = cookies[i];
                    } else if (cookies[i].getName().equals("operadorConsulta")) {
                        operador = cookies[i];
                    } else if (cookies[i].getName().equals("limiteConsulta")) {
                        limite = cookies[i];
                    }
                    if (consulta != null && operador != null && limite != null) { //se já encontrou os cookies então saia
                        break;
                    }
                }
                if (consulta == null) {//se não achou o cookieu então inclua
                    consulta = new Cookie("consultaCtrc_cte", "");
                }
                if (operador == null) {//se não achou o cookieu então inclua
                    operador = new Cookie("operadorConsulta", "");
                }
                if (limite == null) {//se não achou o cookieu então inclua
                    limite = new Cookie("limiteConsulta", "");
                }
                consulta.setMaxAge(60 * 60 * 24 * 90);
                operador.setMaxAge(60 * 60 * 24 * 90);
                limite.setMaxAge(60 * 60 * 24 * 90);

                String valor = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[0]);
                String campo = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[1]);
                String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[2]);
                String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : consulta.getValue().split("!!")[3]);
//                String ag = (consulta.getValue().equals("") ? "false" : consulta.getValue().split("!!")[4]);
                String fl = (consulta.getValue().equals("") ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : consulta.getValue().split("!!")[4]);
                /*
                String imp = (consulta.getValue().equals("") ? "false" : consulta.getValue().split("!!")[6]);
                String ser = (consulta.getValue().equals("") ? "" : consulta.getValue().split("!!")[7]);
                String rem = (consulta.getValue().equals("") ? "Todos os remetentes" : consulta.getValue().split("!!")[8]);
                String idRem = (consulta.getValue().equals("") ? "0" : consulta.getValue().split("!!")[9]);
                String des = (consulta.getValue().equals("") ? "Todos os destinatarios" : consulta.getValue().split("!!")[10]);
                String idDes = (consulta.getValue().equals("") ? "0" : consulta.getValue().split("!!")[11]);
                String con = (consulta.getValue().equals("") ? "Todos os consignatarios" : consulta.getValue().split("!!")[12]);
                String idCon = (consulta.getValue().equals("") ? "0" : consulta.getValue().split("!!")[13]);
                */
                valorConsulta = (request.getParameter("valor") != null ? request.getParameter("valor") : (valor));
                dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
                dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
//                agencia = (request.getParameter("minhaagencia") != null ? request.getParameter("minhaagencia") : (ag));

                filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
                /*
                impressos = (request.getParameter("isNotImpresso") != null ? request.getParameter("isNotImpresso") : (imp));

                               idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : (idRem));
                remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : (rem));
                idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : (idDes));
                destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : (des));
                idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : (idCon));
                consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : (con));
                serie = (request.getParameter("serie") != null ? request.getParameter("serie") : (ser));
 */
                campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                        ? request.getParameter("campo")
                        : (campo.equals("") ? "emissao_em" : campo));
                operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                        ? request.getParameter("ope")
                        : (operador.getValue().equals("") ? "1" : operador.getValue()));
                limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                        ? request.getParameter("limite")
                        : (limite.getValue().equals("") ? "10" : limite.getValue()));
                consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" +filial);
                operador.setValue(operadorConsulta);
                limite.setValue(limiteResultados);
                response.addCookie(consulta);
                response.addCookie(operador);
                response.addCookie(limite);
            } else {
                campoConsulta = (request.getParameter("campo") != null && !request.getParameter("campo").trim().equals("")
                        ? request.getParameter("campo") : "emissao_em");
                dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                        : Apoio.incData(fmt.format(new Date()), -30));
                dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
//                agencia = (request.getParameter("minhaagencia") != null ? request.getParameter("minhaagencia") : "false");
                filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
                /*
                impressos = (request.getParameter("isNotImpresso") != null ? request.getParameter("isNotImpresso") : "false");
                idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0");
                remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "Todos os remetentes");
                idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0");
                destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "Todos os destinatários");
                idConsignatario = (request.getParameter("idconsignatario") != null ? request.getParameter("idconsignatario") : "0");
                consignatario = (request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "Todos os consignatários");
                serie = (request.getParameter("serie") != null ? request.getParameter("serie") : "");
                */
                valorConsulta = (request.getParameter("valor") != null && !request.getParameter("valor").trim().equals("")
                        ? request.getParameter("valorDaConsulta") : "");
                operadorConsulta = (request.getParameter("ope") != null && !request.getParameter("ope").trim().equals("")
                        ? request.getParameter("ope") : "1");
                limiteResultados = (request.getParameter("limite") != null && !request.getParameter("limite").trim().equals("")
                        ? request.getParameter("limite") : "10");


            }

//   Finalizando Cookie

%>

<%  BeanConsultaConhecimento beanconh = null;
            String acao = request.getParameter("acao");
            acao = ((acao == null) || (nivelUser == 0) ? "" : acao);
            BeanConfiguracao cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
//Carregando as configurações
            cfg.CarregaConfig();

            int pag = Integer.parseInt((request.getParameter("pag") != null ? request.getParameter("pag") : "1"));

            if (acao.equals("iniciar")) {
                acao = "consultar";
                pag = 1;
            }

            if (acao.equals("consultar") || acao.equals("proxima")) {
                beanconh = new BeanConsultaConhecimento();
                beanconh.setStatusCte(statusCte);
                beanconh.setConexao(Apoio.getUsuario(request).getConexao());
                beanconh.setExecutor(Apoio.getUsuario(request));
                beanconh.setCampoDeConsulta(campoConsulta);
                beanconh.setOperador(Integer.parseInt(operadorConsulta));
                beanconh.setValorDaConsulta(valorConsulta);
                beanconh.setLimiteResultados(Integer.parseInt(limiteResultados));
                //beanconh.setIsNotImpresso(Boolean.parseBoolean(impressos));
                BeanUsuario usu = Apoio.getUsuario(request);
                //Se o usuario tiver permissao para lancar conh para outras filiais entao
                //ele pode visualizar os conh. das outras(quando for 0 vai mostrar todas)
                beanconh.setIdFilialConhecimento(Integer.parseInt(filial));
                //beanconh.setAgency((Boolean.parseBoolean(agencia) ? Apoio.getUsuario(request).getAgencia().getId() : -1));
                beanconh.setDtEmissao1(Apoio.paraDate(dataInicial));
                beanconh.setDtEmissao2(Apoio.paraDate(dataFinal));

                beanconh.setPaginaResultados(pag);
                //beanconh.setIdRemetente(Integer.parseInt(idRemetente));
                //beanconh.setIdDestinatario(Integer.parseInt(idDestinatario));
                //beanconh.setIdConsignatario(Integer.parseInt(idConsignatario));
                //beanconh.setSerie(serie);
                // a chamada do método Consultar() está lá em mbaixo
            }
            //se o usuario tiver permissao de excluir
            //Obs.: O teste de permissao para outras filiais esta na instrucao sql.
/*      
            if (acao.equals("enviarEmail")) {
                //Enviando e-mail para os clientes
                EnviaEmail m = new EnviaEmail();
                m.setCon(Apoio.getUsuario(request).getConexao());
                m.carregaCfg();
                BeanConsultaConhecimento ct = new BeanConsultaConhecimento();
                ct.setConexao(Apoio.getUsuario(request).getConexao());
                ct.consultarCtrcEmail(request.getParameter("idCtrc"), 0);
                ResultSet rsCt = ct.getResultado();
                String msg = "";
                String msgErro = "";
                boolean deuCerto = true;
                while (rsCt.next()) {
                    String texto = cfg.getMensagemCtrc();
                    texto = texto.replaceAll("@@nome_cliente", rsCt.getString("cliente"));
                    texto = texto.replaceAll("@@cnpj_cliente", rsCt.getString("cnpj_cliente"));
                    texto = texto.replaceAll("@@nota_fiscal", rsCt.getString("notas"));
                    texto = texto.replaceAll("@@emissao_ctrc", fmt.format(rsCt.getDate("emissao_em")));
                    texto = texto.replaceAll("@@previsao_entrega", (rsCt.getDate("previsao_entrega_em") == null ? "" : fmt.format(rsCt.getDate("previsao_entrega_em"))));
                    texto = texto.replaceAll("@@nome_transportadora", Apoio.getUsuario(request).getFilial().getRazaosocial());
                    texto = texto.replaceAll("@@ctrc", rsCt.getString("ctrc"));
                    texto = texto.replaceAll("@@remetente", rsCt.getString("remetente"));
                    texto = texto.replaceAll("@@destinatario", rsCt.getString("destinatario"));
                    //Novos a partir 24/09
                    texto = texto.replaceAll("@@volume", rsCt.getString("tot_volume"));
                    texto = texto.replaceAll("@@peso", rsCt.getString("tot_peso"));
                    texto = texto.replaceAll("@@valor_mercadoria", rsCt.getString("tot_valor"));
                    //NOVO CAMPO a partir de 28/01/2009
                    texto = texto.replaceAll("@@valor_frete", rsCt.getString("valor_frete"));

                    msg = texto;
                    m.setAssunto("CTRC Emitido - Mensagem automática da " + Apoio.getUsuario(request).getFilial().getRazaosocial());
                    m.setMensagem(msg);
                    m.setPara(rsCt.getString("email"));
                    deuCerto = m.EnviarEmail();
                    if (!deuCerto) {
                        msgErro += "Ocorreu o seguinte erro ao enviar e-mail: " + m.getErro() + "\r\n"
                                + "Cliente: " + rsCt.getString("cliente") + "\r\n"
                                + "CTRC: " + rsCt.getString("ctrc") + "\r\n";
                    }
                }
                rsCt.close();
                //Fim enviando e-mail

                if (!msgErro.equals("")) {
                    response.getWriter().append(msgErro);
                } else {
                    response.getWriter().append("load=0");
                }
                response.getWriter().close();
            }
*/
            if (acao.equals("exportar")) {
                int idCte = Integer.parseInt(request.getParameter("idCte"));
                //int modelo = Integer.parseInt(request.getParameter("modelo"));
                //Verificando qual campo filtrar


                //Exportando
                java.util.Map param = new java.util.HashMap(3);
                param.put("ID_CTE", idCte);

                request.getSession(false).setAttribute("map", param);
                request.getSession(false).setAttribute("rel", "/CT-e/dacte_mod1");


                response.sendRedirect("./ExporterReports");
            }
%>

<%@page import="filial.BeanFilial"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="java.util.Date"%>
<%@page import="nucleo.EnviaEmail"%>
<html>
    <head>
        <script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
        <script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
        <script language="javascript" type="text/javascript" >
            
            function seleciona_campos(){
            <% //se for consultar agora, ele seleciona o campo q o usuario escolheu
                        if ((campoConsulta != null) && (operadorConsulta != null) && (valorConsulta != null) && (limiteResultados != null)) {%>
                                $("valor_consulta").value = "<%=valorConsulta%>";
                                $("campo_consulta").value = "<%=campoConsulta%>";
                                $("operador_consulta").value = "<%=operadorConsulta%>";
                                $("limite").value = "<%=limiteResultados%>";
                                $("statusCte").value = "<%=statusCte%>"
            <%}%>
                }

                function consultar(){
                    javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});
                }

                function consulta(campo, operador, valor, limite){

                    var data1 = document.getElementById("dtemissao1").value.trim();
                    var data2 = document.getElementById("dtemissao2").value.trim();
                    var statusCte = $("statusCte").value;
                    if (campo == "emissao_em" && !(validaData(data1) && validaData(data2) )){
                        return alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
                    }

                    location.replace("./enviar_cte.jsp?campo="+campo+"&ope="+operador+"&valor="+valor+
                        "&"+
                        (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&limite="+limite+
                        "&pag=1&acao=consultar&statusCte=" + statusCte);
                }

                function editarconhecimento(idmovimento, podeexcluir){
                    window.open("./frameset_conhecimento?acao=editar&id="+idmovimento+(podeexcluir != null ? "&ex="+podeexcluir : ""), "menuLan", 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }

                function proxima(campo, operador, valor, limite){   
                    var data1 = document.getElementById("dtemissao1").value.trim();
                    var data2 = document.getElementById("dtemissao2").value.trim();
                    var statusCte = $("statusCte").value;

                    location.replace('./enviar_cte.jsp?campo='+campo+'&ope='+operador+'&valor='+valor+
                        (data1 == "" ? "" : "&dtemissao1="+data1+"&dtemissao2="+data2)+"&limite="+limite+"&pag=<%=(pag + 1)%>&acao=proxima"
                        +"&statusCte=" + statusCte);
                }
/*
                function excluirconhecimento(idmovimento){
                    if (confirm("Deseja mesmo excluir este Conhecimento de transporte?"))
                    {
                        location.replace("./consultaconhecimento?acao=excluir&id="+idmovimento);
                    }
                }
*/
                function habilitaConsultaDePeriodo(opcao){
                    document.getElementById("valor_consulta").style.display = (opcao ? "none" : "");
                    document.getElementById("operador_consulta").style.display = (opcao ? "none" : "");
                    document.getElementById("div1").style.display = (opcao ? "" : "none");
                    document.getElementById("div2").style.display = (opcao ? "" : "none");
                }

                function aoCarregar(){
                    seleciona_campos();
                    //bloqueia($('statusCte'));
            <%if ((acao.equals("consultar") || acao.equals("proxima")) && (campoConsulta.equals("emissao_em"))) {%>
                    habilitaConsultaDePeriodo(true);
            <%}%>
                }
/*
                function getCheckedCtrcs(){
                    var ids = "";
                    for (i = 0; getObj("ck" + i) != null; ++i)
                        if (getObj("ck" + i).checked)
                            ids += ',' + getObj("ck" + i).value;

                    return ids.substr(1);
                }

                function printMatricideCtrc() {
                    var ctrcs = getCheckedCtrcs();
                    function e(transport){
                        var textoresposta = transport.responseText;
                        //se deu algum erro na requisicao...
                        if (textoresposta == "load=0"){
                            return false;
                        }else{
                            alert(textoresposta);
                        }
                    }//funcao e()

                    if (ctrcs == "") {
                        alert("Selecione pelo menos um CTRC!");
                        return null;
                    }
                    var url =  "./matricidectrc.ctrc?idmovs="+ctrcs+"&"+concatFieldValue("driverImpressora,caminho_impressora");
                    tryRequestToServer(function(){document.location.href = url;});

                    new Ajax.Request("./consultaconhecimento?acao=enviarEmail&idCtrc="+ctrcs,{method:'post', onSuccess: e, onError: e});

                }
                
                function exportar(){
                    var ctrcs = getCheckedCtrcs();
                    if (ctrcs == "") {
                        alert("Selecione pelo menos um CTRC!");
                        return null;
                    }
                    if ($('cbexportar').value == 'FRONTDIG'){
                        document.location.href = './manifesto.txt2?idctrc='+ctrcs + '&modelo=ctrc';
                    }else if($('cbexportar').value == 'ATM'){
                        document.location.href = './averbacao.txt4?ids='+ctrcs + '&modelo=CTRC';
                    }else if($('cbexportar').value == 'APISUL'){
                        document.location.href = './averbacao.txt5?ids='+ctrcs + '&modelo=CTRC';
                    }else if($('cbexportar').value == 'PORTOSEGURO'){
                        document.location.href = './averbacao.txt8?ids='+ctrcs +'&modelo=CTRC';
                    }
                }
                */

                function enviarCTe(){
                    var ctrcs = getCheckedCtrcs();
                    if(ctrcs == ""){
                        alert("Selecione ao menos um CTRC!");
                        return false;
                    }
                    document.location.href = './CTeControlador?acao=enviar&ctrcs=' + ctrcs;
                }
               
/*
                function viewDups(idMov){
                    if ($("tr_"+idMov).style.display == ''){
                        $('tr_'+idMov).style.display = 'none';
                        $('plus_'+idMov).style.display = '';
                        $('minus_'+idMov).style.display = 'none';
                    }else{
                        $('plus_'+idMov).style.display = 'none';
                        $('minus_'+idMov).style.display = '';
                        $('tr_'+idMov).style.display = '';
                    }
                }
                    

                function mostrarDetalhes(ctrc){
                    var filtros = "tipoFiltro=ctrc&idremetente=0&iddestinatario=0&rem_rzs=&" +
                        "notafiscal=&ctrc="+ctrc+"&dest_rzs=&limite=10&rem_cnpj=&dest_cnpj="+
                        "&chkNaoEntregue=false&chkTrazerColeta=false&dtinicial="+$("dtemissao1").value+
                        "&dtfinal="+$("dtemissao2").value;

                    //Apenas se os filtros estiverem corretos
                    window.open("./consulta_entrega_ctrc.jsp?acao=consultar&"+filtros,
                    "Detalhes" , 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }
*/
                function checkTodos(){
                    //seleciona todos
                    var i = 0 , check = false;

                    if ($("ckTodos").checked){
                        check = true;
                    }

                    while ($("ck"+i) != null){
                        $("ck"+i).checked = check;
                        i++
                    }
                }

                function bloqueia(statusCte){
                    //bloqueiaEnvio(statusCte);
                }

                /*
                function bloqueiaEnvio(statusCte){
                    if(statusCte.value == "P" || statusCte.value == 'N'){
                        $("botEnviar").disabled = false;
                        $("botEnviar").style.display = '';
                    }else{
                        $("botEnviar").disabled = true;
                        $("botEnviar").style.display = 'none';
                    }
                }
                 */

                /*
                function bloqueiaCancelamento(statusCte){
                    if(statusCte.value == "C"){
                        for(var i = 0; i < parseInt($("linhaTotal").value); i++){
                            $("bot_cancelar_" + i).disabled = false;
                            $("bot_cancelar_" + i).style.display = '';
                            
                            $("img_imprimir_" + i).disabled = false;
                            $("img_imprimir_" + i).style.display = '';
                            
                        }
                    }else{
                        for(var i = 0; i < parseInt($("linhaTotal").value); i++){
                            $("bot_cancelar_" + i).disabled = true;
                            $("bot_cancelar_" + i).style.display = 'none';
                            
                            $("img_imprimir_" + i).disabled = true;
                            $("img_imprimir_" + i).style.display = 'none';
                            
                        }
                    }
                       
                }
                 */
                function cancelar(ctrc){

                    if(ctrc == ""){
                        alert("Selecione ao menos um CTRC!");
                        return false;
                    }


            if(confirm("Deseja cancelar a CT-e '" + ctrc  + "'?" )){
                var textoCancelamento = prompt("Qual o motivo do cancelamento?" ,"");

                if(textoCancelamento != null){
                    if(confirm("Deseja Excluir o CT-e?")){
                        if(confirm("Tem certeza?")){
                            window.open("./CTeControlador?acao=cancelar&ctrc=" + ctrc + "&motivo="+textoCancelamento , ctrc, 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
                        }
                    }
                    }

                }
            }

                function abrirDetalheStatus(codigo){
                    alert("Descrição: " +codigo);
                }

                function atualizarRecibo(numeroRecibo, idCte){
                    window.open("./CTeControlador?acao=atualizarRecibo&numeroRecibo=" + numeroRecibo + "&idCte=" + idCte , numeroRecibo, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }

                function popCTe(id){
                    if (id == null)
                        return null;
                    launchPDF('./enviar_cte.jsp?acao=exportar&modelo=1&idCte=' + id,'dacte'+id);
                }

                function popXml(idCte, chaveAcesso, isCanc){
                    if (idCte == null)
                        return null;
                    window.open("./"+chaveAcesso+"-cte.xml?acao=gerarXmlCliente&idCte=" + idCte+"&isCanc=" + isCanc , "xmlCTe" +idCte, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }

                function enviarEmail(idCte, isCanc){
                    if (idCte == null)
                        return null;
                    window.open("./CTeControlador?acao=enviarEmail&idCte=" + idCte+"&isCanc=" + isCanc , idCte, 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
                }

        </script>

        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>WebTrans - CT-e</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style8 {font-size: 11px}
            -->
        </style>
        
    </head>

    <body onLoad="aoCarregar();applyFormatter();">
        <img src="img/banner.gif"  alt=""><br>
        <table width="99%" align="center" class="bordaFina" >
            <tr>
                <td width="590"><div align="left"><b>CT-e</b></div></td>
                <td width="98">
                </td>
                <td width="98">
                </td>
            </tr>
        </table>
        <br>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">

            <tr class="celula">
                <td  >
                    <select name="campo_consulta" id="campo_consulta" onChange="javascript:habilitaConsultaDePeriodo(this.value=='emissao_em');" class="inputtexto">
                        <option value="emissao_em">Data de emiss&atilde;o</option>
                        <!--<option value="baixa_em">Data de entrega</option>-->
                        <option value="nfiscal" selected>CTRC</option>
                        <option value="numero">NF do cliente</option>
                        <option value="pedido">Pedido do cliente</option>
                        <option value="numero_carga">Número da carga</option>
                    </select>      </td>
                <td >
                    <select name="operador_consulta" id="operador_consulta" class="inputtexto">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4">Igual &agrave; palavra/frase</option>
                        <option value="5" selected>Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">De:<input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" value="<%=dataInicial%>"
                                                                   class="fieldDate" onBlur="alertInvalidDate(this)"></div>      </td>
                <td>
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">Até:<input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" value="<%=dataFinal%>"
                                                                    onblur="alertInvalidDate(this)" class="fieldDate"></div>
                    <input name="valor_consulta" type="text" id="valor_consulta" size="10" class="inputtexto">
                </td>
                <td >
                    <label for="statusCte">Status:</label>
                    <select name="statusCte" id="statusCte" onChange="consultar()" class="inputtexto">
                        <option value="P" selected>Pendente</option>
                        <option value="E">Enviado</option>
                        <option value="C">Confirmado</option>
                        <option value="N">Negado</option>
                        <option value="L">Cancelado</option>
                    </select>
                </td>
                <td ><div align="center">Por p&aacute;g.:
                        <select name="limite" id="limite" class="inputtexto">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                </td>
                <td >
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function(){consulta(campo_consulta.value, operador_consulta.value, valor_consulta.value, limite.value);});">

                </td>
            </tr>
            <tr class="celula">
                <td   colspan="2">
                    <label>Filial: </label>
                    <b><label><%=Apoio.getUsuario(request).getFilial().getAbreviatura()%></label></b>
                </td>
                <td   colspan="2">
                </td>
                <td >
                </td>
                <td></td>
            </tr>

        </table>
        <div >
            <form method="post"  action="CTeControlador?acao=enviar" >
                <table width="99%" align="center"  class="bordaFina">
                    <tr class="tabela">

                        <td width="2%">
                            <input name="ckTodos" type="checkbox" value="1" id="ckTodos" onClick="checkTodos()">
                        </td>
                        <td width="3%" align="center"></td>
                        <td width="3%" align="center"></td>
                        <td width="3%" align="center"></td>
                        <td width="4%">CTRC</td>
                        <td width="2%" align="center">Sr.</td>

                        <td width="8%" align="center">Emiss&atilde;o</td>
                        <td width="10%" align="center">N° Recibo</td>
                        <td width="10%" align="center">Dt./Hr. Envio</td>
                        <!--<td width="10%">Filial/Ag.</td>-->
                        <td width="23%">Remetente</td>
                        <td width="23%">Destinat&aacute;rio</td>
                        <td align="right" width="7%">Total</td>
                        <td width="2%" align="center"></td>

                        <td width="2%" align="center"></td>
                    </tr>
                    <% //variaveis da paginacao
                                int linhatotal = 0;
                                int linha = 0;
                                int qtde_pag = 0;
                                String cor = "";

                                // se conseguiu consultar
                                if ((acao.equals("consultar") || acao.equals("proxima")) && (beanconh.ConsultarCte())) {
                                    ResultSet rs = beanconh.getResultado();
                                    while (rs.next()) {
                                        cor = (rs.getBoolean("is_cancelado") ? "#CC0000" : "");
                                        //pega o resto da divisao e testa se é par ou impar
%> <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" >
                        <td >
                            <input name="ck<%=linha%>" type="checkbox" value="<%=rs.getInt("id")%>" id="ck<%=linha%>">
                        </td>
                        <td align="center">
                            <%if (request.getParameter("statusCte").equals("C")) {%>
                            <img class="imagemLink" alt="" title="Imprimir DACTE" id="img_imprimir_<%=linha%>" onClick="javascript:tryRequestToServer(function(){popCTe(<%=rs.getInt("id")%>);});" src="img/pdf.jpg">
                            <%}%>
                        </td>
                        <td align="center">
                            <%if (request.getParameter("statusCte").equals("C")) {%>
                            <%if (rs.getBoolean("is_cte_enviado_cliente")) {%>
                            <img class="imagemLink" alt="" title="Enviar CT-e Cliente já Enviado" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){enviarEmail(<%=rs.getInt("id")%>,  false);})" width="25px" src="img/outc.png">
                            <%} else {%>
                            <img class="imagemLink" alt="" title="Enviar CT-e Cliente " id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){enviarEmail(<%=rs.getInt("id")%>,  false);})" width="25px" src="img/out.png">
                            <%}%>

                            <%}%>
                            <%if (request.getParameter("statusCte").equals("L")) {%>
                            <%if (rs.getBoolean("is_cte_enviado_cliente")) {%>
                            <img class="imagemLink" alt="" title="Enviar CT-e Cliente  já Enviado" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){javascript:enviarEmail(<%=rs.getInt("id")%>,  true);})" width="25px" src="img/outc.png">
                            <%}else {%>
                            <img class="imagemLink" alt="" title="Enviar CT-e Cliente" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){enviarEmail(<%=rs.getInt("id")%>,  true);})" width="25px" src="img/out.png">
                            <%}%>
                            <%}%>
                        </td>
                        <td align="center">
                            <%if (request.getParameter("statusCte").equals("C")) {%>
                            <img class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){popXml(<%=rs.getInt("id")%>, '<%=rs.getString("chave_acesso_cte")%>', false);});" width="25px" src="img/xml.png">
                            <%}%>
                            <%if (request.getParameter("statusCte").equals("L")) {%>
                            <img class="imagemLink" alt="" title="Imprimir XML Cliente" id="img_xml_<%=linha%>" onClick="javascript:tryRequestToServer(function(){popXml(<%=rs.getInt("id")%>, '<%=rs.getString("chave_acesso_cte")%>', true);})" width="25px" src="img/xml.png">
                            <%}%>
                        </td>
                        <td >
                            <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editarconhecimento(<%=rs.getString("id") + ",null"%>);});">
                                <%=rs.getString("numero")%>
                            </div>
                        </td>
                        <td align="center">
                            <font color=<%=cor%>>
                                <%=rs.getString("serie")%>
                            </font>
                        </td>

                        <td align="center">
                            <font color=<%=cor%>>
                                <%=new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("emissao_em"))%>
                            </font>
                        </td>
                        <td align="center">
                            <%if (request.getParameter("statusCte").equals("E")) {%>
                            <a href="javascript:atualizarRecibo('<%=rs.getString("numero_recibo")%>', '<%=rs.getInt("id")%>')">
                                <%=rs.getString("numero_recibo")%>
                            </a>
                            <%} else {%>
                            <%=rs.getString("numero_recibo")%>
                            <%}%>
                        </td>
                        <td align="center">
                            <font color=<%=cor%>>
                                <%Date dtHoraEnv = rs.getTimestamp("data_hora_envio");%>
                                <%String dtHoraEnvS = (dtHoraEnv == null ? "" : new SimpleDateFormat("dd/MM/yyyy hh:mm").format(dtHoraEnv));%>
                                <%=dtHoraEnvS%>
                            </font>
                        </td>
                        <!--
                        <td>
                            <font color=<%=cor%>>
                        <%=rs.getString("abreviatura_emitente")%>
                    </font>
                </td>
                        -->
                        <td>
                            <font color=<%=cor%>>
                                <%=rs.getString("razao_social_remetente")%>
                            </font>
                        </td>
                        <td>
                            <font color=<%=cor%>>
                                <%=rs.getString("razao_social_destinatario")%>
                            </font>
                        </td>
                        <td align="right">
                            <font color=<%=cor%>>
                                <%=rs.getString("total_receita")%>
                            </font>
                        </td>

                        <td width="20" align="center">
                            <a title="<%=rs.getString("descricao_status_cte")%>" href="javascript: abrirDetalheStatus('<%=rs.getString("descricao_status_cte")%>')"><%=rs.getString("status_cte")%></a>
                        </td>

                        <td align="center">
                            <%if (request.getParameter("statusCte").equals("C")) {%>
                            <img class="imagemLink" alt="" title="Cancelar CT-e" src="./img/cancelar.png" id="bot_cancelar_<%=linha%>" onClick="javascript:tryRequestToServer(function(){cancelar(<%=rs.getInt("id")%>);})">
                            <%}%>
                        </td>
                    </tr>
                    <% if (rs.isLast()) {
                                            //Quantidade geral de resultados da consulta
                                            linhatotal = beanconh.getQtdResultados();
                                        }
                                        linha++;
                                    }

                                    //se os resultados forem divididos pelas paginas e sobrar, some mais uma pag
                                    qtde_pag = ((linhatotal % Integer.parseInt(limiteResultados)) == 0
                                            ? (linhatotal / Integer.parseInt(limiteResultados))
                                            : (linhatotal / Integer.parseInt(limiteResultados)) + 1);

                                }//if
                                pag = (qtde_pag == 0 ? 0 : pag);
                    %>
                </table>

            </form>
        </div>


        <br>
        <table width="99%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="20%"><center>
                        Ocorrências: <b><%=linhatotal%></b>
                    </center>
                </td>
            <input type="hidden" name="linhaTotal" id="linhaTotal" value="<%=linhatotal%>">
            <td align="left" width="40%">P&aacute;gina: <b><%=pag%></b></td>

            <td width="20%" align="center">
                <div align="center">
                    <input name="avancar" type="button" class="botoes" id="avancar"
                           value="Próxima"  onClick="javascript:tryRequestToServer(function(){proxima('<%=campoConsulta%>','<%=operadorConsulta%>','<%=valorConsulta%>','<%=limiteResultados%>');});">
                </div>
            </td>

            <td colspan="3" align="center" width="20%">
                <%String statCte = request.getParameter("statusCte");%>

                <%if (statCte != null) {%>
                <% if ((statCte.equals("P")) || statCte.equals("N")) {%>
                <input class="inputbotao" type="button" onClick="javascript:tryRequestToServer(function(){enviarCTe();});" value="Enviar" id="botEnviar">
                <%}%>
                <%}%>
            </td>
        </tr>

    </table>


    <br>
</body>
</html>
