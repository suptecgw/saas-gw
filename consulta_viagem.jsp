<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="viagem.*,
         nucleo.Apoio,
         nucleo.impressora.*,
         java.sql.ResultSet,
         java.text.SimpleDateFormat, 
         nucleo.BeanLocaliza,
         java.util.Date" %>
<%
    BeanUsuario autenticado = Apoio.getUsuario(request);
    int nivelUser = (autenticado != null ? autenticado.getAcesso("lanviagem") : 0);
    int nivelUserDesconto = (autenticado != null ? autenticado.getAcesso("lanviagemdescontomotorista") : 0);
    String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
//testando se a sessao é válida e se o usuário tem acesso
    if ((autenticado == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
//Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String finalizada = "";
    String filial = "";
    String operadorConsulta = "";
    String limiteResultados = "";
    String idMotorista = "0";
    String motorista = "";
    String idVeiculo = "0";
    String veiculo = "";
    String idCarreta = "0";
    String carreta = "";
    String ordenacao = "";
    String tipoOrdenacao = "";
    String isMostrarAdvCriadoPorMim = "false";
    String isMostrarApenasAdvNaoImpressos = "false";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;
    String tipoBeneficiario = "0";
    String idAjudante = "0";
    String idFuncionario = "0";
    String nomeAjudante = "";
    String nomeFuncionario = "";

    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaViagem")) {
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
            consulta = new Cookie("consultaViagem", "");
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
        String fin = (consulta.getValue().equals("") ? "todas" : consulta.getValue().split("!!")[4]);
        String fl = (consulta.getValue().equals("") ? "0" : consulta.getValue().split("!!")[5]);
        String idMot = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 7 ? "0" : consulta.getValue().split("!!")[6]);
        String mot = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 8 ? "" : consulta.getValue().split("!!")[7]);
        String idVeic = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 9 ? "0" : consulta.getValue().split("!!")[8]);
        String veic = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 10 ? "" : consulta.getValue().split("!!")[9]);
        String ord = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 12 ? "numviagem" : consulta.getValue().split("!!")[10]);
        String tipoOrd = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 12 ? "" : consulta.getValue().split("!!")[11]);
        String idcar = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 13 ? "0" : consulta.getValue().split("!!")[12]);
        String car = (consulta.getValue().equals("") || consulta.getValue().split("!!").length < 14 ? "" : consulta.getValue().split("!!")[13]);
        String isAdvCriadoPorMim = (consulta.getValue().equals("") ? "false" : (consulta.getValue().split("!!").length < 15 ? "false" : consulta.getValue().split("!!")[14]));
        String isApenasAdvNaoImpressos = (consulta.getValue().equals("") ? "false" : (consulta.getValue().split("!!").length < 16 ? "false" : consulta.getValue().split("!!")[15]));
        String tpBenef = (consulta.getValue().equals("") ? "0" : (consulta.getValue().split("!!").length < 17 ? "0" : consulta.getValue().split("!!")[16]));
        String idAjud = (consulta.getValue().equals("") ? "0" : (consulta.getValue().split("!!").length < 18 ? "0" : consulta.getValue().split("!!")[17]));
        String idFun = (consulta.getValue().equals("") ? "0" : (consulta.getValue().split("!!").length < 19 ? "0" : consulta.getValue().split("!!")[18]));
        String ajud = (consulta.getValue().equals("") ? "" : (consulta.getValue().split("!!").length < 20 ? "" : consulta.getValue().split("!!")[19]));
        String func = (consulta.getValue().equals("") ? "" : (consulta.getValue().split("!!").length < 21 ? "" : consulta.getValue().split("!!")[20]));
        
        
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : (fin));
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "saida_em" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : (idMot));
        motorista = request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : (mot);
        idCarreta = (request.getParameter("idcarreta") != null ? request.getParameter("idcarreta") : idcar);
        carreta = (request.getParameter("car_placa") != null ? request.getParameter("car_placa") : car);
        idVeiculo = (request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : (idVeic));
        veiculo = (request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : (veic));
        ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : (ord));
        tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : (tipoOrd));
        isMostrarAdvCriadoPorMim = (request.getParameter("isMostrarAdvCriadoPorMim") != null ? request.getParameter("isMostrarAdvCriadoPorMim") : (isAdvCriadoPorMim));
        isMostrarApenasAdvNaoImpressos = (request.getParameter("isMostrarApenasAdvNaoImpressos") != null ? request.getParameter("isMostrarApenasAdvNaoImpressos") : (isApenasAdvNaoImpressos));
        tipoBeneficiario = (request.getParameter("selectBeneficiario") != null ? request.getParameter("selectBeneficiario") : (tpBenef));
        idAjudante = (request.getParameter("idAjudante1") != null ? request.getParameter("idAjudante1") : (idAjud));
        idFuncionario = (request.getParameter("idFuncionario") != null ? request.getParameter("idFuncionario") : (idFun));
//        nomeAjudante = (request.getParameter("nomeAjudante") != null ? request.getParameter("nomeAjudante") : (aju));
        nomeAjudante = (request.getParameter("nomeAjudante") != null ? request.getParameter("nomeAjudante") : ajud);
        nomeFuncionario = (request.getParameter("nomeFuncionario") != null ? request.getParameter("nomeFuncionario") : func);

        consulta.setValue(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" + finalizada + "!!" + filial + "!!" + idMotorista + "!!" + motorista
                + "!!" + idVeiculo + "!!" + veiculo + "!!"  + ordenacao + "!!" + tipoOrdenacao + "!!" + idCarreta + "!!" + carreta + "!!"+isMostrarAdvCriadoPorMim+"!!"+isMostrarApenasAdvNaoImpressos
                + "!!" + tipoBeneficiario + "!!" + idAjudante + "!!" + idFuncionario + "!!" + nomeAjudante + "!!" +  nomeFuncionario);
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
    } else {
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta") : "saida_em");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : "todas");
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : "0");
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador") : "1");
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados") : "10");
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0");
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "");
        idVeiculo = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0");
        veiculo = (request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "");
        idCarreta = (request.getParameter("idcarreta") != null ? request.getParameter("idcarreta") : "0");
        carreta = (request.getParameter("car_placa") != null ? request.getParameter("car_placa") : "");
        ordenacao = (request.getParameter("ordenacao") != null ? request.getParameter("ordenacao") : "numviagem");
        tipoOrdenacao = (request.getParameter("tipo_ordenacao") != null ? request.getParameter("tipo_ordenacao") : "");
        isMostrarAdvCriadoPorMim = (request.getParameter("isMostrarAdvCriadoPorMim") != null ? request.getParameter("isMostrarAdvCriadoPorMim") : "false");
        isMostrarApenasAdvNaoImpressos = (request.getParameter("isMostrarApenasAdvNaoImpressos") != null ? request.getParameter("isMostrarApenasAdvNaoImpressos") : "false");
              
    }
    //Finalizando Cookie

%>

<jsp:useBean id="consViag" class="viagem.BeanConsultaViagem" />
<jsp:setProperty  name="consViag" property="paginaResultados"  />
<%

    consViag.setDtEmissao1(Apoio.paraDate(dataInicial));
    consViag.setDtEmissao2(Apoio.paraDate(dataFinal));
    consViag.setFinalizada(finalizada);
    consViag.setCampoDeConsulta(campoConsulta);
    consViag.setLimiteResultados(Integer.parseInt(limiteResultados));
    consViag.setOperador(Integer.parseInt(operadorConsulta));
    consViag.setValorDaConsulta(valorConsulta);
    consViag.setFilial_id(Integer.parseInt(filial));
    consViag.setVeiculo_id(idVeiculo);
    consViag.setMotorista_id(idMotorista);
    consViag.setCarreta_id(idCarreta);
    consViag.setOrdenacao(ordenacao + " " + tipoOrdenacao);
    consViag.setMostrarAdvCriadoPorMim(Apoio.parseBoolean(isMostrarAdvCriadoPorMim));
    consViag.setMostrarApenasAdvNaoImpressos(Apoio.parseBoolean(isMostrarApenasAdvNaoImpressos));
    consViag.setBeneficiarioViagem(BeneficiarioViagem.obterBeneficiarioPorTipoPesquisa(Apoio.parseInt(tipoBeneficiario)));
    consViag.getAjudante().setIdfornecedor(Apoio.parseInt(idAjudante));
    consViag.getFuncionario().setIdfornecedor(Apoio.parseInt(idFuncionario));
    consViag.setUsuarioLogado(autenticado.getId());
//exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) {
        //Exportando  
        java.util.Map param = new java.util.HashMap(1);
       //  String idviagem = request.getParameter("idviagem");
       // idviagem = idviagem.replaceFirst("'", "");
       // idviagem = idviagem.replaceFirst(",", "");
      
        String idviagem = request.getParameter("idviagem");
            idviagem = idviagem.replace("'", "");
            String ids = "";
            for (int x = 0; x <= idviagem.split(",").length - 1; x++) {
                ids += (ids.equals("") ? "" : ",") + "'" + idviagem.split(",")[x] + "'";
            }
        if(request.getParameter("modelo").equals("P6")){
            param.put("IDVIAGEM", (ids));
        }else{
            param.put("IDVIAGEM", (ids));
        }                       
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        String model = request.getParameter("modelo");
        

        if (model.indexOf("personalizado") > -1) {
            String relatorio = "doc_adv_" + model;
            request.setAttribute("map", param);
            request.setAttribute("rel",relatorio);
        }else{
            if (model.equals("9")) {
                request.setAttribute("rel", "viagemmod9");
            } else {
                request.setAttribute("rel", "documento_viagem_modelo_" + request.getParameter("modelo"));
            }
        }
        //para evitar NumberFormatException
        for(String id : ids.split(",")) {
            consViag.atualizaIsImpresso(Apoio.parseInt(id.replaceAll("'", "")));
        }
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }

    if (acao.equals("imprimirRecibo")) {
        //Exportando
        java.util.Map param = new java.util.HashMap(1);
        param.put("ID", request.getParameter("idMovBanco"));
        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        request.setAttribute("map", param);
        request.setAttribute("rel", "reciboadiantamentomod" + request.getParameter("modelo"));

        RequestDispatcher dispatcher = request.getRequestDispatcher("./ExporterReports");
        dispatcher.forward(request, response);
    }
  

%>


<script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<script language="javascript">
    shortcut.add("enter",function() {consultar('consultar')});
    
    function consultar(acao){
        if (($("campoDeConsulta").value == "saida_em" || $("campoDeConsulta").value == "chegada_em") && !(validaData($("dtemissao1").value) && validaData($("dtemissao2").value) )) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }
        document.location.replace("./consulta_viagem.jsp?acao="+acao+"&paginaResultados="+ (acao=='proxima'? <%=consViag.getPaginaResultados() + 1%> : (acao=='anterior'? <%=consViag.getPaginaResultados() - 1%> : 1)) +"&isMostrarAdvCriadoPorMim=" + $("chkMostrarAdvCriadoPorMim").checked + "&isMostrarApenasAdvNaoImpressos=" + $("chkMostrarApenasAdvNaoImpressos").checked+ "&"+
            concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,finalizada,filialId,idveiculo,vei_placa,idmotorista,motor_nome,ordenacao,tipo_ordenacao,car_placa,idcarreta,idFuncionario,idAjudante1,nomeFuncionario,nomeAjudante,selectBeneficiario"));
    }   

    function excluir(id,numCte,numDespesa){
        if(numCte != null && numCte != "null" && numCte != ""){
            alert("Existe(m) minuta(s) numero: " + numCte + " atrelada a este ADV!");
            return false;
        }else if(numDespesa != null && numDespesa != "null" && numDespesa != ""){
            alert("Existe(m) despesa(s) numero: " + numDespesa + " atrelada a este ADV!");
            return false;
        }
        if (!confirm("Deseja mesmo excluir esta viagem?"))
            return null;

        document.location.replace("./cadviagem.jsp?acao=excluir&id="+id);
    }    

    function aoCarregar(){
        $("campoDeConsulta").value = "<%=campoConsulta%>";
        $("finalizada").value = "<%=finalizada%>";
        $("operador").value = "<%=operadorConsulta%>";
        $("limiteResultados").value = "<%=limiteResultados%>";
        $("filialId").value = "<%=filial%>";
        $("idveiculo").value = "<%=idVeiculo%>";
        $("vei_placa").value = "<%=veiculo%>";
        $("idmotorista").value = "<%=idMotorista%>";
        $("motor_nome").value = "<%=motorista%>";
        $("car_placa").value = "<%=carreta%>";
        $("idcarreta").value = "<%=idCarreta%>";
        $("ordenacao").value = "<%=ordenacao%>";
        $("selectBeneficiario").value = "<%=tipoBeneficiario%>";
        ocultarBeneficiario("<%=tipoBeneficiario%>");
        $("motor_nome").value = "<%=motorista%>";
        $("nomeAjudante").value = "<%=nomeAjudante%>";
        $("nomeFuncionario").value = "<%=nomeFuncionario%>";
        $("idAjudante1").value = "<%=idAjudante%>";
        $("idFuncionario").value = "<%=idFuncionario%>";
        
        
        $("tipo_ordenacao").value = "<%=tipoOrdenacao%>";
    <%   if (consViag.getCampoDeConsulta().equals("") || consViag.getCampoDeConsulta().equals("saida_em") || consViag.getCampoDeConsulta().equals("chegada_em")) {
    %>        habilitaConsultaDePeriodo(true);
    <%   }
    %>
        }

        function editar(id, baixado){
            if (baixado)
                location.replace("./cadviagem.jsp?acao=baixado&id="+id);
            else
                location.replace("./cadviagem.jsp?acao=editar&id="+id);
    
        }

        function habilitaConsultaDePeriodo(opcao) {
            $("valorDaConsulta").style.display = (opcao ? "none" : "");
            $("operador").style.display = (opcao ? "none" : "");
            $("div1").style.display = (opcao ? "" : "none");
            $("div2").style.display = (opcao ? "" : "none");	  
        }

        function popViagem(id){
            if (id == null){
                
                if(getCheckedCtrcs()==null){
                    return;
                }else{
                    id = getCheckedCtrcs();
                }
            }
            if (id == '') {
                alert('Informe um modelo para impressão!');
                return null;
            }
            if ($('cbmodelo').value == '-'){
                alert('Informe um modelo para impressão!');
                return null;
            }
            launchPDF('./consulta_viagem.jsp?acao=exportar&modelo=' + $('cbmodelo').value + '&idviagem='+id,'viagem'+id);
        }

        function getCheckedsColeta(){
            var ids = "";
            for (i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked)
                    ids += ',' + getObj("ck" + i).value;
	
            return ids.substr(1);
        }

        function baixar(id){
            location.replace("./cadviagem.jsp?acao=iniciarbaixa&id="+id);
        }

        function limpaMotorista(){
            $("idmotorista").value = 0;
            $("motor_nome").value = "";
        }

        function limpaVeiculo(){
            $("idveiculo").value = 0;   
            $("vei_placa").value = "";   
        }
        function limpaCarreta(){
            $("idcarreta").value = 0;   
            $("car_placa").value = "";   
        }

        function localizamotorista(){
            post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>','motorista',
            'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
        }
        
        function localizaCarreta(){
            post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CARRETA%>','carreta',
            'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
        }
        
        

        function abrirLancamentoDesconto(){
            if('<%=nivelUserDesconto%>' != "4"){
                alert("Você Não tem Privilégios Suficientes para Executar esta Ação!");
            }else{
                launchPopupLocate('ViagemDescontoMotoristaControlador?acao=listar');
            }
        }
        
        function getCheckedCtrcs(){
            var ids = "";
            for (var i = 0; getObj("ck_" + i) != null; ++i)
                if (getObj("ck_" + i).checked)
                    ids += "," + getObj("ck_" + i).value;
                  
            return ids.substr(1);
        }


        function checkTodos(){
            //seleciona todos
            var i = 0 , check = false;

            if ($("ckTodos").checked){
                check = true;
            }

            while ($("ck_"+i) != null){
                $("ck_"+i).checked = check;
                i++
            }
        }

    function aoClicarNoLocaliza(idjanela) {
        if (idjanela === 'Funcionario') {
            $('idFuncionario').value = $('idfornecedor').value;
            $('nomeFuncionario').value = $('fornecedor').value;
        } else if (idjanela === 'Ajudante') {
            $('idAjudante1').value = $('idajudante').value;
            $('nomeAjudante').value = $('nome').value;
        }
    }
   
        function ocultarBeneficiario(t){
        document.getElementById('apenas-ajudante-lb').style.display = "none";
        document.getElementById('apenas-ajudante-inp').style.display = "none";
        document.getElementById('apenas-funcionario-lb').style.display = "none";
        document.getElementById('apenas-funcionario-inp').style.display = "none";
        document.getElementById('apenas-motorista-lb').style.display = "none";
        document.getElementById('apenas-motorista-inp').style.display = "none";
        switch(t){
            case "0":
                document.getElementById('apenas-ajudante-lb').style.display = "block";
                document.getElementById('apenas-ajudante-inp').style.display = "block";
                document.getElementById('apenas-funcionario-lb').style.display = "block";
                document.getElementById('apenas-funcionario-inp').style.display = "block";
                document.getElementById('apenas-motorista-lb').style.display = "block";
                document.getElementById('apenas-motorista-inp').style.display = "block";
                break;
            case "1":
                //motorista
                document.getElementById('apenas-motorista-lb').style.display = "block";
                document.getElementById('apenas-motorista-inp').style.display = "block";
                $('nomeAjudante').value='';$('idAjudante1').value='0'
                $('idFuncionario').value = '0'; $('nomeFuncionario').value = '';
                break;
            case "2":
                //ajudante
                document.getElementById('apenas-ajudante-lb').style.display = "block";
                document.getElementById('apenas-ajudante-inp').style.display = "block";
                limpaMotorista();
                $('idFuncionario').value = '0'; $('nomeFuncionario').value = '';
                break;
            case "3":
                document.getElementById('apenas-funcionario-lb').style.display = "block";
                document.getElementById('apenas-funcionario-inp').style.display = "block";
                limpaMotorista();
                $('nomeAjudante').value='';$('idAjudante1').value='0'
                break;
        }
    }

    function sincronizarGWMobile(viagemId, isBaixada, isCancelada){
        var actionImport = "a";
        if(isBaixada){
            actionImport = "b";
        }
        if(isCancelada){
            actionImport = "c";
        }
            window.open("./MobileControlador?acao=sincronizarGWMobileViagem&viagemId="+viagemId+"&actionImport="+actionImport , "pop", 'top=10,left=0,height=50,width=50,resizable=yes,status=1,scrollbars=1');
    }


    function abrirPopAuditoria() {
        tryRequestToServer(function () {
            var url = "ViagemControlador?acao=auditoriaViagem&isExclusao=true&isViagem=true";

            window.open(url, 'auditoriaViagemExclusao', 'toolbar=no,left=0,top=0,location=no,status=no,menubar=no,scrollbars=yes,resizable=no');
        });
    }


</script>
<%@page import="java.util.Vector"%>
<%@page import="filial.BeanFilial"%>
<%@ page import="br.com.gwsistemas.viagem.BeneficiarioViagem" %>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Viagens</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="aoCarregar(); applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <table width="98%" align="center" class="bordaFina" >
            <tr>
                <% if (nivelUser >= 2) {%>
                <td align="left">
                    <b>Consulta de Viagens</b>            
                </td>
                <%}%>
                <td width="18%">
                    <input name="auditoria" type="button" class="inputbotao"  onclick="abrirPopAuditoria();" value="Visualizar Auditoria"/>
                </td>
                <td width="18%">
                    <input name="desconto" type="button" class="inputbotao"  onclick="javascript:tryRequestToServer(function(){abrirLancamentoDesconto();});" value="Lançamento de Descontos Extras para o Motorista"/>
                </td>
                <% if (nivelUser >= 3) {%>
                <td width="98">
                    <input name="novo" type="button" class="botoes" id="novo" 
                           onClick="javascript:tryRequestToServer(function(){document.location.replace('./cadviagem.jsp?acao=iniciar');});" 
                           value="Novo cadastro">
                </td>
                <%}%>
            </tr>
        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <input type="hidden" name="idmotorista" id="idmotorista" value="<%=idMotorista%>">  
            <input type="hidden" name="idveiculo"   id="idveiculo" value="<%=idVeiculo%>">  
            <input type="hidden" id="idfornecedor" value="0">
            <input type="hidden" id="nome_funcionario" value="">
            <input type="hidden" id="id_funcionario">
            <input type="hidden" id="fornecedor" value="">
            <input type="hidden" id="idajudante" value="">
            <input type="hidden" id="nome" value="">
            <tr class="celula"> 
                <td width="15%"  height="20">
                    <select name="campoDeConsulta" class="fieldMin" id="campoDeConsulta"
                            onChange="javascript:habilitaConsultaDePeriodo(this.value=='saida_em' || this.value=='chegada_em');">
                        <option value="numviagem">N&ordm; Viagem</option>
                        <option value="saida_em" selected>Data de Sa&iacute;da</option>
                        <option value="chegada_em">Data de Chegada</option>
                        <option value="ctrc">CTRC</option>
                        <option value="numero_carga">Nº Carga</option>
                        <option value="manifesto">Manifesto</option>
                        <option value="numero_pedido">Nº de Pedido</option>
                        <option value="numero_nota_fiscal">Nº da Nota Fiscal</option>
                    </select> 
                </td>
                <td width="15%"> 
                    <select name="operador" id="operador" class="fieldMin">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="5">Maior que</option>
                        <option value="6">Maior ou igual &aacute;</option>
                        <option value="7">Menor que</option>
                        <option value="8">Menor ou igual &agrave;</option>
                        <option value="9">Igual ao n&uacute;mero</option>
                    </select> 
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div1" style="display:none ">
                        De: 
                        <input name="dtemissao1" type="text" id="dtemissao1" size="10" style="font-size:8pt;" maxlength="10" 
                               value="<%=dataInicial%>" onblur="alertInvalidDate(this)" class="fieldDate" >
                    </div>
                </td>
                <td width="15%">
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">
                        At&eacute;: 
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10" 
                               value="<%=dataFinal%>" onblur="alertInvalidDate(this)" class="fieldDate" >
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" class="fieldMin" value="<%=valorConsulta%>" size="20" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar3').click();">
                </td>
                <td width="15%">
                    <input name="pesquisar" type="button" class="botoes" id="pesquisar3" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                           onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                </td>
                <td width="15%">
                    <div align="center">
                        Mostrar:
                        <select name="finalizada" id="finalizada" class="fieldMin">
                            <option value="todas">Todas</option>
                            <option value="false" selected>Em aberto</option>
                            <option value="true">Baixadas</option>
                            <option value="c">Canceladas</option>
                        </select>
                    </div>      
                    <div align="center">
                    </div>
                </td>
                <td width="25%">
                    <div align="right"> 
                        Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="fieldMin">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <table width="100%" cellspacing="1">
                        <tr class="celula">
                            <td width="4%">Filial:</td>
                            <td width="10%">
                                <select name="filialId" id="filialId" class="fieldMin">
                                    <option value="0" selected="selected">TODAS</option>
                                    <%BeanFilial fl = new BeanFilial();
                                        ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
                                        while (rsFl.next()) {%>
                                    <option value="<%=rsFl.getString("idfilial")%>"><%=rsFl.getString("abreviatura")%></option>
                                    <%}%>
                                </select>
                            </td>
                            <td width="8%"><div id="apenas-motorista-lb">Motorista:</div></td>
                            <td width="24%">
                                <div align="left" id="apenas-motorista-inp">
                                    <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" size="28" readonly="true" value="<%=motorista%>">
                                    <input name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" value="..." onClick="javascript:localizamotorista();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaMotorista();"/>
                                </div>
                            </td>
                            <td width="9%">Ordenação:</td>
                            <td width="24%">
                                <select name="ordenacao" class="fieldMin" id="ordenacao">
                                    <option value="numviagem" selected>N&ordm; Viagem</option>
                                    <option value="saida_em" >Data de Sa&iacute;da</option>
                                    <option value="chegada_em">Data de Chegada</option>
                                </select> 
                                <select name="tipo_ordenacao" class="fieldMin" id="tipo_ordenacao">
                                    <option value="" selected>Crescente</option>
                                    <option value="desc" >Decrescente</option>
                                </select> 
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr class="celula">
                <td width="7%">Apenas o Veículo:</td>
                            <td width="14%">
                                <div align="left">
                                    <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" size="10" readonly="true" value="<%=veiculo%>">
                                    <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=41','Veiculo','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaVeiculo();"/>
                                </div>
                            </td>
                <td width="7%">Apenas a carreta : </td>
                            <td width="14%">
                                <div align="left">
                                    <input name="car_placa" type="text" id="car_placa" class="inputReadOnly8pt" size="10" readonly="true" value="<%=veiculo%>">
                                    <input name="localizaCarreta" type="button" class="botoes" id="localizaCarreta" value="..." onClick="javascript:localizaCarreta();">
                                    <input type="hidden" name="idcarreta"   id="idcarreta" value="<%=idCarreta%>">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="limpaCarreta();"/>
                                </div>
                            </td>
                            <td colspan="2"><input type="checkbox" name="chkMostrarAdvCriadoPorMim" id="chkMostrarAdvCriadoPorMim" <%=isMostrarAdvCriadoPorMim.equals("true") ? "checked" : ""%>> Mostrar ADV(s) criados por mim. <input type="checkbox" name="chkMostrarApenasAdvNaoImpressos" id="chkMostrarApenasAdvNaoImpressos" <%=isMostrarApenasAdvNaoImpressos.equals("true") ? "checked" : ""%>>Mostrar apenas ADV(s) não impressos. </td>
            </tr>
            <tr class="celula">
                <td><div align="center">Mostrar apenas beneficiários:</div></td>
                <td>
                    <div align="center">
                        <select id="selectBeneficiario" name="selectBeneficiario" class="inputtexto" onchange="ocultarBeneficiario(this.value);">
                            <option value="0" ${(empty param['selectBeneficiario'] or param['selectBeneficiario'] eq '0') ? "selected" : ""}>Todos</option>
                            <option value="1" ${param['selectBeneficiario'] eq '1' ? "selected" : ""}>Motoristas</option>
                            <option value="2" ${param['selectBeneficiario'] eq '2' ? "selected" : ""}>Ajudantes</option>
                            <option value="3" ${param['selectBeneficiario'] eq '3' ? "selected" : ""}>Funcionários</option>
                        </select>
                    </div>
                </td>
                <td><div align="center" id="apenas-ajudante-lb">Apenas o ajudante:</div></td>
                <td>
                    <div align="left" id="apenas-ajudante-inp">
                        <input type="hidden" id="idAjudante1" name="idAjudante1" value="">
                        <input name="nomeAjudante" id="nomeAjudante" type="text" class="inputReadOnly8pt" size="13" readonly value="${param['nomeAjudante']}">
                        <input type="button" class="botoes" name="localiza_ajudante" id="localiza_ajudante" value="..."
                               onclick="launchPopupLocate('${homePath}/localiza?acao=consultar&idlista=25&paramaux2=1','Ajudante');">
                        <img src="${homePath}/img/borracha.gif" alt="" class="imagemLink" id="borrachaAj" onclick="$('nomeAjudante').value='';$('idAjudante1').value='0'"/>
                    </div>
                </td>
                <td><div align="center" id="apenas-funcionario-lb">Apenas o funcionário:</div></td>
                <td>
                    <div align="left" id="apenas-funcionario-inp">
                        <input type="hidden" id="idFuncionario" name="idFuncionario" value="${param['idFuncionario']}">
                        <input name="nomeFuncionario" id="nomeFuncionario" type="text" class="inputReadOnly8pt" size="15" readonly value="${param['nomeFuncionario']}">
                        <input type="button" class="botoes" name="localizarFuncionario" id="localizarFuncionario" value="..."
                               onclick="launchPopupLocate('${homePath}/localiza?acao=consultar&idlista=21&paramaux2=1', 'Funcionario');">
                        <img src="${homePath}/img/borracha.gif" alt="" class="imagemLink" id="limparFuncionario" onclick="$('idFuncionario').value = '0'; $('nomeFuncionario').value = '';">
                    </div>
                </td>
            </tr>
        </table>
        <br>
        <table width="98%" border="0" align="center" class="bordaFina">
            <tr class="tabela">
                <td width="2%"><input name="ckTodos" type="checkbox" value="1" id="ckTodos" onClick="checkTodos()"></td>
                <td width="2%"><img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popViagem(null);});"></td>
                <td width="2%"></td>
                <td width="5%">Viagem</td>
                <td width="10%">Filial</td>
                <td width="13%">Sa&iacute;da</td>
                <td width="13%">Chegada</td>
                <td width="20%">Beneficiário</td>
                <td width="7%">Veiculo</td>
                <td width="6%">Carreta</td>
                <td width="16%">Origem/Destino</td>
                <td width="6%">&nbsp;</td>
                <td width="2%">&nbsp;</td>
            </tr>

            <%
                int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;

                if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                    consViag.setConexao(Apoio.getConnectionFromUser(request));
                    if (consViag.Consultar()) {
                        ResultSet r = consViag.getResultado();
                        while (r.next()) {%>
            <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>" <%=(r.getBoolean("is_cancelada") == true ? "style='color: red'" : "")%>>
                 
                <td>
                    <div align="center">
                         <input type="checkbox" id="ck_<%=linha%>" name="ck_<%=linha%>" value="<%=r.getInt("id")%>">
                    </div>
                </td>
                
                <td>
                    <div align="center">
                        <img src="img/pdf.jpg" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popViagem('<%=r.getString("id")%>');});">
                    </div>
                </td>
                <td>
                    <div align="center">

                        <c:if test="<%=r.getBoolean(\"is_sincronizado_mobile\")%>" >
                            <img src="img/smart3.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Sincronizar para GW Mobile" onClick="javascript:sincronizarGWMobile('<%=r.getString("id")%>', <%=r.getBoolean("is_baixada")%>,<%=r.getBoolean("is_cancelada")%>);">
                        </c:if>
                        <c:if test="<%=!r.getBoolean(\"is_sincronizado_mobile\")%>" >
                            <img src="img/smartphone.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Sincronizar para GW Mobile" onClick="javascript:sincronizarGWMobile('<%=r.getString("id")%>', <%=r.getBoolean("is_baixada")%>,<%=r.getBoolean("is_cancelada")%>);">
                        </c:if>

                    </div>
                </td>
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id")%>,<%=r.getBoolean("is_baixada")%>);});">
                        <%=r.getString("numviagem")%>
                    </div>
                </td>
                <td><%=r.getString("filial")%></td>
                <td><%=fmt.format(r.getDate("saida_em")) + (r.getDate("saida_as") == null ? "" : " às " + new SimpleDateFormat("HH:mm").format(r.getTime("saida_as")))%></td>
                <td><%=(r.getBoolean("is_baixada") ? fmt.format(r.getDate("chegada_em")) + " às " + (r.getTime("chegada_as") == null ? "" : new SimpleDateFormat("HH:mm").format(r.getTime("chegada_as"))) : "")%></td>
                <c:set var="beneficiario" value='<%= r.getString("beneficiario") %>'/>
                <c:set var="motorista" value='<%= r.getString("motorista") %>'/>
                <c:set var="ajudante" value='<%= r.getString("ajudante") %>'/>
                <c:set var="funcionario" value='<%= r.getString("funcionario") %>'/>
                <td>
                    <c:choose>
                        <c:when test="${beneficiario eq 'm'}">
                            ${motorista}
                        </c:when>
                        <c:when test="${beneficiario eq 'a'}">
                            ${ajudante}
                        </c:when>
                        <c:when test="${beneficiario eq 'f'}">
                            ${funcionario}
                        </c:when>
                    </c:choose>
                </td>
                <td><%=r.getString("placa_veiculo")%></td>
                <td><%=r.getString("placa_carreta")%></td>
                <td><%=r.getString("origem")%>/<%=r.getString("destino")%></td>
                <td>
                    <%if (!r.getBoolean("is_baixada") && !r.getBoolean("is_cancelada")) {%>
                    <div align="center" class="linkEditar" onClick="javascript:tryRequestToServer(function(){baixar(<%=r.getInt("id")%>);});">
                        Baixar
                    </div>
                    <%} else {
                        if (!r.getBoolean("is_cancelada")) {%>   
                    <div align="center">Baixada</div>
                    <%}
                        }
                    %>   
                </td>
                <td>
                    <%               if ((nivelUser == 4) && (r.getBoolean("podeexcluir"))) {
                    %>                 <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("id")%>,'<%=r.getString("numero_cte")%>', '<%=r.getString("numero_despesa")%>');});">    
                    <%               }%>               
                </td>
            </tr>
            <%           if (r.isLast()) {
                                linhatotal = r.getInt("qtde_linhas");
                            }
                            linha++;
                        }

                        int limit = consViag.getLimiteResultados();
                        qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                    }
                }
            %> 

        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="18%" height="22" rowspan="2">
            <center>
                Ocorr&ecirc;ncias: 
                <b><%=linha%> / <%=linhatotal%></b>
            </center>
        </td>
        <td width="15%" rowspan="2" align="center">
            P&aacute;ginas: 
            <b><%=(qtde_pag == 0 ? 0 : consViag.getPaginaResultados())%> / <%=qtde_pag%></b>
        </td>
        <td width="10%" rowspan="2" align="right">
             <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function() {consultar('anterior');});" <%= consViag.getPaginaResultados() == 1 ? "disabled" : "" %> >
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});" <%= qtde_pag == consViag.getPaginaResultados() ? "disabled" : "" %>>    
        </td>
        <td colspan="5" align="right">
            Modelo de Impress&atilde;o em PDF:
            <select name="cbmodelo" id="cbmodelo" class="inputtexto">
                <option value="A1" selected>Modelo 1 (Acompanhamento)</option>
                <option value="A2" >Modelo 2 (Acompanhamento)</option>
                <option value="A3" >Modelo 3 (Acompanhamento)</option>
                <option value="A4" >Modelo 4 (Acompanhamento)</option>
                <option value="A5" >Modelo 5 (Acompanhamento)</option>
                <option value="A6" >Modelo 6 (Acompanhamento)</option>
                <option value="-">------------------------</option>
                <option value="P1">Modelo 1 (Prestação de contas)</option>
                <option value="P2">Modelo 2 (Prestação de contas)</option>
                <option value="P3">Modelo 3 (Prestação de contas)</option>
                <option value="P4">Modelo 4 (Prestação de contas)</option>
                <option value="P5">Modelo 5 (Prestação de contas)</option>
                <option value="P6">Modelo 6 (Prestação de contas)</option>
                <option value="P7">Modelo 7 (Prestação de contas)</option>
                <option value="P8">Modelo 8 (Prestação de contas)</option>
                <option value="P9">Modelo 9 (Prestação de contas)</option>
                <option value="P10">Modelo 10 (Prestação de contas)</option>
                <option value="P11">Modelo 11 (Prestação de contas)</option>
                <%for (String rel : Apoio.listDocADV(request)) {%>
                    <option value="-">------------------------</option>
                    <option value="personalizado_<%=rel%>" >Modelo <%=rel.toUpperCase() %> (Personalizado)</option>
                <%}%>
            </select>
        </td>
    </tr>
</table>
</body>
</html>
