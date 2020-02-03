<%@page import="br.com.gwsistemas.layoutedi.LayoutEDIBO"%>
<%@page import="java.util.Collection"%>
<%@page import="br.com.gwsistemas.layoutedi.LayoutEDI"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.Calendar"%>
<%--<%@page import="sun.util.resources.CalendarData"%>
<%@page import="sun.util.resources.CalendarData_da"%>   OBS-- Comentando essas duas linhas pois estavam dando erro de compilação. (SERÁ TESTADO PARA NÃO DANIFICAR NADA NA TELA.)--%>
<%@ page contentType="text/html; charset=ISO-8859-1" language="java"
         import="conhecimento.coleta.*,
         conhecimento.coleta.BeanConsultaColeta,
         nucleo.Apoio,
         nucleo.BeanLocaliza,
         nucleo.impressora.*,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         nucleo.BeanConfiguracao,
         java.util.Date" %>
        <script language="JavaScript"  src="script/shortcut.js" type="text/javascript"></script>
<%
    int nivelUser = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadcoleta") : 0);
    int nivelColAuto = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadcoletasautomaticas") : 0);
    int nivelUserToFilial = (nivelUser > 0 ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
    int nivelUserCtrc = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
    int nivelNf = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("cadvenda") : 0);
    String acao = (request.getParameter("acao") != null && nivelUser > 0 ? request.getParameter("acao") : "");
    
    Collection<LayoutEDI> listaLayoutOCOREN = LayoutEDIBO.mostrarLayoutEDI("o", Apoio.getUsuario(request));
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");

    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    BeanFilial beanFl = new BeanFilial();
    ResultSet rsFl = beanFl.all(Apoio.getUsuario(request).getConexao());
    

//Iniciando Cookie
    String campoConsulta = "";
    String valorConsulta = "";
    String dataInicial = "";
    String dataFinal = "";
    String finalizada = "";
    String categoria = "";
    String filial = "";
    String baixada = "";
    String operadorConsulta = "";
    String limiteResultados = "";
    String remetente = "";
    String idRemetente = "0";
    String destinatario = "";
    String idDestinatario = "0";
    String motorista = "";
    String idMotorista = "0";
    String veiculoPlaca = "";
    String veiculoId = "0";
    String isNaoImpresso = "false";
    String descricaoCidadeOrigem = "";
    String idCidadeOrigem = "0";
    String descricaoCidadeDestino = "";
    String idCidadeDestino = "0";
    Cookie consulta = null;
    Cookie operador = null;
    Cookie limite = null;
    
    Cookie cookies[] = request.getCookies();
    if (cookies != null) {
        for (int i = 0; i < cookies.length; i++) {
            if (cookies[i].getName().equals("consultaColeta")) {
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
            consulta = new Cookie("consultaColeta", "");
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

        String[] splitConsulta = URLDecoder.decode(consulta.getValue(), "ISO-8859-1").split("!!");
        String valor = (consulta.getValue().equals("") ? "" : splitConsulta[0]);
        String campo = (consulta.getValue().equals("") ? "" : splitConsulta[1]);
        String dt1 = (consulta.getValue().equals("") ? fmt.format(new Date()) : splitConsulta[2]);
        String dt2 = (consulta.getValue().equals("") ? fmt.format(new Date()) : splitConsulta[3]);
        String fin = (consulta.getValue().equals("") ? "false" : splitConsulta[4]);
        String fl = (consulta.getValue().equals("") ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : splitConsulta[5]);
        String bx = (consulta.getValue().equals("") ? "todas" : splitConsulta[6]);
        String rem = (consulta.getValue().equals("") ? "Todos os clientes" : (splitConsulta.length > 7 ? splitConsulta[7] : "Todos os clientes"));
        String idRem = (consulta.getValue().equals("") ? "0" : (splitConsulta.length > 8 ? splitConsulta[8] : "0"));
        String des = (consulta.getValue().equals("") ? "Todos os destinatarios" : (splitConsulta.length > 9 ? splitConsulta[9] : "Todos os destinatarios"));
        String idDes = (consulta.getValue().equals("") ? "0" : (splitConsulta.length > 10 ? splitConsulta[10] : "0"));
        String mot = (consulta.getValue().equals("") ? "Todos os motoristas" : (splitConsulta.length > 11  ? splitConsulta[11] : "Todos os motoristas"));
        
        String idMot = (consulta.getValue().equals("") ? "0" : (splitConsulta.length > 12 ? splitConsulta[12] : "0" ));
        String isNaoImp = (consulta.getValue().equals("") ? "false" : (splitConsulta.length > 14 ? splitConsulta[14] : "false" ));
        String idVeiculo = (consulta.getValue().equals("") ? "0" : (splitConsulta.length > 13 ? splitConsulta[13] : "false"));
        String veiculo = (consulta.getValue().equals("") ? "Veiculo" : (splitConsulta.length > 15 ? splitConsulta[15] : "Veiculo" ));
        String cat = (consulta.getValue().equals("") ? "am" : (splitConsulta.length > 16 ? splitConsulta[16] : "am"));
        String descriCidade = (consulta.getValue().equals("") ? "Todas as cidades de origem" : (splitConsulta.length > 17 ? splitConsulta[17] : "Todas as cidades de origem"));
        String idCidaOrigem = (consulta.getValue().equals("") ? "0" : (splitConsulta.length > 18 ? splitConsulta[18] : "0"));
        String idCidaDestina = (consulta.getValue().equals("") ? "0" : (splitConsulta.length > 19? splitConsulta[19] : "0"));
        String descriCidadeDesti = (consulta.getValue().equals("") ? "Todas as cidades de destino" : (splitConsulta.length > 20 ? splitConsulta[20] : "Todas as cidades de destino"));
        
        valorConsulta = (request.getParameter("valorDaConsulta") != null ? request.getParameter("valorDaConsulta") : (valor));
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1") : (dt1));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : (dt2));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : (fin));
        
        categoria = (request.getParameter("tipoColeta") != null ? request.getParameter("tipoColeta") : (cat));
        
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : (fl));
        baixada = (request.getParameter("baixada") != null ? request.getParameter("baixada") : (bx));
        remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : (rem));
        idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : (idRem));
        destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : (des));
        idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : (idDes));
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : (mot));
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : (idMot));
        veiculoPlaca = (request.getParameter("vei_placa") != null) ? request.getParameter("vei_placa") : veiculo;
        veiculoId = (request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : (idVeiculo));
        isNaoImpresso = (request.getParameter("isNaoImpresso") != null ? request.getParameter("isNaoImpresso") : (isNaoImp));
        descricaoCidadeOrigem  = (request.getParameter("cid_origem") != null ? request.getParameter("cid_origem") : (descriCidade));
        idCidadeOrigem = (request.getParameter("cidadeId") != null ? request.getParameter("cidadeId") : (idCidaOrigem));
        descricaoCidadeDestino  = (request.getParameter("cid_destino") != null ? request.getParameter("cid_destino") : (descriCidadeDesti));
        idCidadeDestino = (request.getParameter("idcidadedestino") != null ? request.getParameter("idcidadedestino") : (idCidaDestina));

        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta")
                : (campo.equals("") ? "dtsolicitacao" : campo));
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador")
                : (operador.getValue().equals("") ? "1" : operador.getValue()));
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados")
                : (limite.getValue().equals("") ? "10" : limite.getValue()));
        consulta.setValue(URLEncoder.encode(valorConsulta + "!!" + campoConsulta + "!!" + dataInicial + "!!" + dataFinal + "!!" + finalizada + "!!" + filial //0-5
                + "!!" + baixada + "!!" + remetente + "!!" + idRemetente + "!!" + destinatario + "!!" + idDestinatario + "!!" + motorista  //6-11
                + "!!" + idMotorista + "!!" + veiculoId + "!!" + isNaoImpresso + "!!" + veiculoPlaca +"!!" + categoria + "!!" + descricaoCidadeOrigem //12-17
                + "!!" + idCidadeOrigem + "!!" + idCidadeDestino + "!!" + descricaoCidadeDestino, "ISO-8859-1"));//20
        operador.setValue(operadorConsulta);
        limite.setValue(limiteResultados);
        response.addCookie(consulta);
        response.addCookie(operador);
        response.addCookie(limite);
    } else {
        campoConsulta = (request.getParameter("campoDeConsulta") != null && !request.getParameter("campoDeConsulta").trim().equals("")
                ? request.getParameter("campoDeConsulta") : "dtsolicitacao");
        dataInicial = (request.getParameter("dtemissao1") != null ? request.getParameter("dtemissao1")
                : Apoio.incData(fmt.format(new Date()), -30));
        dataFinal = (request.getParameter("dtemissao2") != null ? request.getParameter("dtemissao2") : fmt.format(new Date()));
        finalizada = (request.getParameter("finalizada") != null ? request.getParameter("finalizada") : "false");
        
        categoria = (request.getParameter("tipoColeta") != null ? request.getParameter("tipoColeta") : "am");
        
        filial = (request.getParameter("filialId") != null ? request.getParameter("filialId") : String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
        baixada = (request.getParameter("baixada") != null ? request.getParameter("baixada") : "false");
        remetente = (request.getParameter("rem_rzs") != null ? request.getParameter("rem_rzs") : "Todos os clientes");
        idRemetente = (request.getParameter("idremetente") != null ? request.getParameter("idremetente") : "0");
        destinatario = (request.getParameter("dest_rzs") != null ? request.getParameter("dest_rzs") : "Todos os destinatários");
        idDestinatario = (request.getParameter("iddestinatario") != null ? request.getParameter("iddestinatario") : "0");
        motorista = (request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "Todos os motoristas");
        idMotorista = (request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0");
        veiculoId = (request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : "0");
        isNaoImpresso = (request.getParameter("isNaoImpresso") != null ? request.getParameter("isNaoImpresso") : "false");
        descricaoCidadeOrigem = (request.getParameter("cid_origem") != null ? request.getParameter("cid_origem") : "Todas as cidades de origem");
        idCidadeOrigem = (request.getParameter("cidadeId") != null ? request.getParameter("cidadeId") : "0");
        descricaoCidadeDestino = (request.getParameter("cid_destino") != null ? request.getParameter("cid_destino") : "Todas as cidades de destino");
        idCidadeDestino = (request.getParameter("idcidadedestino") != null ? request.getParameter("idcidadedestino") : "0");
        valorConsulta = (request.getParameter("valorDaConsulta") != null && !request.getParameter("valorDaConsulta").trim().equals("")
                ? request.getParameter("valorDaConsulta") : "");
        operadorConsulta = (request.getParameter("operador") != null && !request.getParameter("operador").trim().equals("")
                ? request.getParameter("operador") : "1");
        limiteResultados = (request.getParameter("limiteResultados") != null && !request.getParameter("limiteResultados").trim().equals("")
                ? request.getParameter("limiteResultados") : "10");
    }
//Finalizando Cookie

%>

<jsp:useBean id="consCol" class="conhecimento.coleta.BeanConsultaColeta" />
<jsp:setProperty  name="consCol" property="paginaResultados"  />
<%
    consCol.setCampoDeConsulta(campoConsulta);
    consCol.setLimiteResultados(Apoio.parseInt(limiteResultados));
    consCol.setOperador(Apoio.parseInt(operadorConsulta));
    consCol.setValorDaConsulta(valorConsulta);
    consCol.setDtEmissao1(Apoio.paraDate(dataInicial));
    consCol.setDtEmissao2(Apoio.paraDate(dataFinal));
    consCol.setFinalizada(finalizada);
    consCol.setCategoria(categoria);
    consCol.setIdFilialColeta(nivelUserToFilial > 0 && request.getParameter("filialId") != null ? Apoio.parseInt(filial) : Apoio.getUsuario(request).getFilial().getIdfilial());
    consCol.setBaixada(baixada);
    consCol.setClienteId(Apoio.parseInt(idRemetente));
    consCol.setDestinatarioId(Apoio.parseInt(idDestinatario));
    consCol.setMotoristaId(Apoio.parseInt(idMotorista));
    consCol.setNaoImpresso(Apoio.parseBoolean(isNaoImpresso));
    consCol.setVeiculoId(Apoio.parseInt(veiculoId));
    consCol.getCidadeOrigem().setIdcidade(Apoio.parseInt(idCidadeOrigem));
    consCol.getCidadeDestino().setIdcidade(Apoio.parseInt(idCidadeDestino));
    
//exportacao da Cartafrete para arquivo .pdf
    if (acao.equals("exportar")) { 
       //marcando a coleta como impressa
        BeanCadColeta col = new BeanCadColeta();
        col.setConexao(Apoio.getUsuario(request).getConexao());
        col.setExecutor(Apoio.getUsuario(request));
        col.coletaImpressa(request.getParameter("valorconsulta"));

        SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
        String condicao = "";
        String usuario = "";
        String campo = request.getParameter("campo");
        String modelo = request.getParameter("modelo");
        //Verificando qual campo filtrar

        if (modelo.equals("9") || modelo.equals("17") || modelo.equals("18") || modelo.lastIndexOf("_WINTER") > -1) {
            condicao = " where c.idcoleta in (" + request.getParameter("valorconsulta") + ") ";
            usuario = Apoio.getUsuario(request).getLogin();
        } else if (modelo.equals("6") || modelo.equals("cr") || modelo.equals("co")) {
            condicao = " where co.id in (" + request.getParameter("valorconsulta") + ") ";
            usuario = Apoio.getUsuario(request).getLogin();
        } else if (modelo.equals("md")) {
            condicao = " where pe.id in (" + request.getParameter("valorconsulta") + ") ";
            usuario = Apoio.getUsuario(request).getLogin();
        } else if (modelo.equals("14")) {
            condicao = " where col.id in (" + request.getParameter("valorconsulta") + ") ";
            usuario = Apoio.getUsuario(request).getLogin();
        } else if (modelo.equals("16") && campo.equals("idcoleta")) {
            condicao = request.getParameter("valorconsulta");
        } else if (campo.equals("idcoleta")) {  //filtrara apenas um id
            condicao = " WHERE IDCOLETA IN (" + request.getParameter("valorconsulta") + ") ";
            usuario = Apoio.getUsuario(request).getLogin();
        }else{
            condicao = " WHERE IDCOLETA IN (" + request.getParameter("valorconsulta") + ") ";
            usuario = Apoio.getUsuario(request).getLogin();
        }
        if (modelo.equals("7")) {
            condicao = " where co.id in (" + request.getParameter("valorconsulta") + ") ";
        }
        else if(campo.equals("idcoleta") && modelo.startsWith("doc_coleta_personalizado")){
          condicao = " where pedido_id in (" + request.getParameter("valorconsulta") + ") ";
        }
        
        //Exportando  
        java.util.Map param = new java.util.HashMap(20);
        param.put("ID_MOVIMENTACAO", condicao);
        param.put("CONDICAO", condicao);
        param.put("USUARIO", Apoio.getUsuario(request).getNome());
        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
        
        request.setAttribute("map", param);
        
        if (modelo.equals("md")) {
            request.setAttribute("rel", "mapa_descargamod1");
        } else if (modelo.equals("cr")) {
            request.setAttribute("rel", "comprovante_recebimentomod1");
        } else if (modelo.equals("co")) {
            request.setAttribute("rel", "controle_ocorrenciamod1");

        } else if (modelo.startsWith("doc_coleta_personalizado")) {//Verificando se o nome começa por "doc_Coleta_personalizado".
            request.setAttribute("rel", modelo);
        } else {
            request.setAttribute("rel", "coletamod" + modelo);
        }
        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispacher.forward(request, response);
    }

    if (acao.equals("obter_sales")) {
        BeanConsultaColeta cols = new BeanConsultaColeta();
        cols.setConexao(Apoio.getUsuario(request).getConexao());
        if (cols.obterSales(Apoio.parseInt(request.getParameter("idcoleta")))) {
            ResultSet co = cols.getResultado();
            int row = 0;
            String resultado = "<table width='100%' border='0' class='bordaFina' id='trid_'" + request.getParameter("id_sale") + ">"
                    + "<tr class='tabela'>"
                    + "<td width='10%'>Número</td>"
                    + "<td width='12%'>Categoria</td>"
                    + "<td width='10%'>Emissão</td>"
                    + "<td width='30%'>Remetente</td>"
                    + "<td width='30%'>Destinatário</td>"
                    + "<td width='9%'></td>"
                    + "</tr>";
            String cor = "";
            while (co.next()) {
                cor = (co.getBoolean("is_cancelado") ? "#CC0000" : "");
                resultado += "<tr class=" + ((row % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2") + ">";
                if (co.getString("categoria").equals("ns") && nivelNf > 0) {
                    resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + co.getString("id_sale") + ",0);});'>";
                } else if (co.getString("categoria").equals("ct") && nivelUserCtrc > 0) {
                    if (co.getInt("filial_id") == Apoio.getUsuario(request).getFilial().getIdfilial()) {
                        resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + co.getString("id_sale") + ",1);});'>";
                    } else if (co.getInt("filial_id") != Apoio.getUsuario(request).getFilial().getIdfilial() && nivelUserToFilial > 0) {
                        resultado += "<td><div class='linkEditar' onclick='javascript:tryRequestToServer(function(){editarSale(" + co.getString("id_sale") + ",1);});'>";
                    } else {
                        resultado += "<td>";
                    }
                } else {
                    resultado += "<td>";
                }
                resultado += co.getString("doc_fiscal") + "-" + co.getString("serie") + "</div></td>";
                resultado += "<td><font color='" + cor + "'>" + (co.getString("categoria").equals("ct") ? "CTRC" : "Nota de serviço") + "</font></td>";
                resultado += "<td><font color='" + cor + "'>" + (co.getDate("dtemissao") != null ? new SimpleDateFormat("dd/MM/yyyy").format(co.getDate("dtemissao")) : "") + "</font></td>";
                resultado += "<td><font color='" + cor + "'>" + co.getString("remetente") + "</font></td>";
                resultado += "<td><font color='" + cor + "'>" + co.getString("destinatario") + "</font></td>";
                resultado += "<td></td>";
                resultado += "</tr>";
                row++;
            }
            resultado += "</table>";
            response.getWriter().append(resultado);
        } else {
            response.getWriter().append("load=0");
        }
        response.getWriter().close();
    }

    
    
%>

<script language="JavaScript"  src="script/funcoes_gweb.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript"  src="script/prototype_1_6.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/jquery.js" type="text/javascript"></script>
<script type="text/javascript"  language="javascript">
    shortcut.add("enter",function() {consultar('consultar')})
    var linha = 0;
    
    function consultar(acao){
        if (($("campoDeConsulta").value == "dtsolicitacao" || $("campoDeConsulta").value =="p.created_at" || $("campoDeConsulta").value == "dtcoleta") && !(validaData(getObj("dtemissao1").value) && validaData(getObj("dtemissao2").value) )) {
            alert("Datas inválidas para consulta. O formato correto é: \"dd/mm/aaaa\"");
            return null;
        }
        document.location.replace("./consultacoleta?acao="+acao+"&paginaResultados="+(acao=='proxima'? <%=consCol.getPaginaResultados() + 1%> : (acao=='anterior'?<%=consCol.getPaginaResultados() - 1%>:1) )+"&isNaoImpresso="+$('chkNaoImpressas').checked+"&"+
            concatFieldValue("campoDeConsulta,operador,valorDaConsulta,limiteResultados,dtemissao1,dtemissao2,finalizada,baixada,"+
            "filialId,idremetente,rem_rzs,iddestinatario,dest_rzs,idmotorista,motor_nome,vei_placa,idveiculo,tipoColeta,cid_origem,cidadeId,cid_destino,idcidadedestino,cid_destino"));
    }
    
    function aoClicarNoLocaliza(idjanela){
        if ((idjanela == "Cidade_Origem")){
            $("cidadeId").value = $("idcidadeorigem").value;
        }
    }
    
    function verMotorista(motoristaId){
        window.open('./cadmotorista?acao=editar&id=' + motoristaId ,'Motorista','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');        
    }

    function verVeiculo (veiculoId){
        window.open('./cadveiculo?acao=editar&id=' + veiculoId ,'Veiculo','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');        

    }

    function excluir(id){
        if (!confirm("Deseja Mesmo Excluir esta Coleta?"))
            return null;

        window.open("./cadcoleta?acao=excluir&idcoleta="+id,'excluirColeta','top=80,left=70,height=200,width=800,resizable=yes,status=1,scrollbars=1');
    }

    function aoCarregar(){
        mostrarTodosLayouts();
        $("campoDeConsulta").value = "<%=(consCol.getCampoDeConsulta().equals("") ? "dtsolicitacao" : consCol.getCampoDeConsulta())%>";
        $("finalizada").value = "<%=(consCol.getFinalizada().equals("") ? "false" : consCol.getFinalizada())%>";
        $("tipoColeta").value = "<%=(consCol.getCategoria().equals("") ? "ambas" : consCol.getCategoria())%>";
        $("baixada").value = "<%=(consCol.getBaixada().equals("") ? "todas" : consCol.getBaixada())%>";
        $("operador").value = "<%=consCol.getOperador()%>";
        $("limiteResultados").value = "<%=consCol.getLimiteResultados()%>";
        
    <%  if (consCol.getCampoDeConsulta().equals("") || consCol.getCampoDeConsulta().equals("dtsolicitacao") || consCol.getCampoDeConsulta().equals("dtcoleta") || consCol.getCampoDeConsulta().equals("p.created_at")) {
    %>       habilitaConsultaDePeriodo(true);
    <%  }
    %>
        }

        function verCtrc(id){
            window.open("./frameset_conhecimento?acao=editar&id="+id+"&ex=false", "CTRC" , "top=0,resizable=yes");
        }

        function editar(id){
            location.replace("./cadcoleta?acao=editar&id="+id);
        }

        function habilitaConsultaDePeriodo(opcao) {
            getObj("valorDaConsulta").style.display = (opcao ? "none" : "");
            getObj("operador").style.display = (opcao ? "none" : "");
            getObj("div1").style.display = (opcao ? "" : "none");
            document.getElementById("div2").style.display = (opcao ? "" : "none");	  
        }

        function popColeta(id){
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";


            if (id == null)
                return null;
            launchPDF('./consultacoleta?acao=exportar&impressao='+impressao+'&modelo=' + getObj('cbmodelo').value + '&campo=idcoleta&valorconsulta='+id,'coleta'+id);
  
        }

        function popColetaGeral(){
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
            else if ($("excel").checked)
                impressao = "2";
            else
                impressao = "3";
    
            launchPDF('./consultacoleta?acao=exportar&modelo=' + getObj('cbmodelo').value + '&campo=idcoleta&valorconsulta='+getCheckedsColeta()+'&impressao='+impressao);
        }

        function getCheckedsColeta(){
            var ids = "";
            for (i = 0; getObj("ck" + i) != null; ++i)
                if (getObj("ck" + i).checked)
                    ids += ',' + getObj("ck" + i).value;
            return ids.substr(1);
        }

        function printMatricideColeta() {
            if (getCheckedsColeta() == "") {
                alert("Selecione pelo menos uma Coleta!");
                return null;
            }

            var url =  "./matricidecoleta.ctrc?idmovs="+getCheckedsColeta()+"&"+concatFieldValue("driverImpressora,caminho_impressora");

            tryRequestToServer(function(){document.location.href = url;});
        }
  
        function alterarImgFormato(elemento){
            var tipo = elemento.id;
            for (i = 0; i < linha; i++) {
                if ($("imgImpRelatorio_"+i) != null) {
                    $("imgImpRelatorio_"+i).src = "img/"+tipo+".gif";     
                }
            }
        }
        
        
        
                var layoutsFunctionAll_c = new Array();
                var layoutsFunctionAll_f = new Array();
                var layoutsFunctionAll_o = new Array();
                var idxAll_c = 0;
                var idxAll_f = 0;
                var idxAll_o = 0;
                
                var idxLayTela = 0;
                var listLayoutEDITela = new Array();
                var idxLay_c = 0;
                var listLayoutEDI_c = new Array();
                var idxLay_o = 0;
                var listLayoutEDI_o = new Array();
            
                var layoutsCliente_c = new Array();
                var layoutsCliente_o = new Array();
                var idxO = 0;
                var idxC = 0;
            
                
            
               
            <%for (LayoutEDI layout : listaLayoutOCOREN) {%>
                listLayoutEDI_o[idxLay_o++] = new Option("<%=layout.getId()%>!!funcEdi", "<%=layout.getDescricao()%>");
                layoutsFunctionAll_o[idxAll_o++] = eval("({id:0, layoutEDI:{id:'<%=layout.getId()%>', descricao:'<%=layout.getDescricao()%>', tipoEdi:'<%=layout.getTipoEdi()%>', nomeArquivo:'<%=layout.getNomeArquivo()%>', extencaoArquivo:'<%=layout.getExtencaoArquivo()%>', funcao:'<%=layout.getFuncao()%>'}, layoutFormatoAntigo:'', tipo:'<%=layout.getTipoEdi()%>'})");
            <%}%>
            
                function removerEDI(elemento, layoutsCliente, listaContainer, tipo){
                    var listaInclusao = new Array();
                    var i = 0;
                
                    try {
                        for (i; i < layoutsCliente.size(); i++) {
                            if (layoutsCliente[i].layoutEDI.id != 0) {
                                listaInclusao[i] = new Option( layoutsCliente[i].layoutEDI.id , layoutsCliente[i].layoutEDI.descricao);
                                listaInclusao[i].valor += "!!funcEdi";
                            }else{
                                for (j = 0; j < listaContainer.size(); j++) {
                                    if (layoutsCliente[i].layoutFormatoAntigo == listaContainer[j].valor && listaContainer[j].valor != "") {
                                        listaInclusao[i] = listaContainer[j];
                                    }
                                }
                            }
                        }
                        povoarSelect(elemento, listaInclusao, true, tipo);
                        elemento.selectedIndex = 0;
                    } catch (e) { 
                        alert(e);
                    }
                }
            
                function carregarLayoutsCliente(clienteId){
                    try {
                        function e(transport){
                            var textoresposta = transport.responseText;
                            var lista = jQuery.parseJSON(textoresposta).list[0];
                            if (lista != "") {
                                var listaEDI = lista.listaClienteLayoutsEDI;
                                var length = (listaEDI != undefined && listaEDI.length != undefined ? listaEDI.length : 1);
                                for(var i = 0; i < length; i++){
                                    if(length > 1){
                                        switch(listaEDI[i].tipo){
                                            case "c":
                                                layoutsCliente_c[idxC++] = (listaEDI[i]);
                                                break;
                                            case "o":
                                                layoutsCliente_o[idxO++] = (listaEDI[i]);
                                                break;
                                        }
                                    }else{
                                        switch(listaEDI.tipo){
                                            case "c":
                                                layoutsCliente_c[idxC++] = (listaEDI);
                                                break;
                                            case "o":
                                                layoutsCliente_o[idxO++] = (listaEDI);
                                                break;
                                        }
                                    
                                    }
                                }
                                removeOptionSelected("cbexportar");
                                removerEDI($("cbexportar"), layoutsCliente_o, listLayoutEDI_o, "o");
                            }else{
                                mostrarTodosLayouts();
                            }
                        
                        }//funcao e()
                        tryRequestToServer(function(){
                            new Ajax.Request("LayoutEDIControlador?acao=ajaxCarregarClienteLayoutEDI&cliente_id="+clienteId,{method:'post', onSuccess: e, onError: e});
                        });
                    } catch (e) { 
                        alert("Erro ao carregar a lista de layouts para EDI do cliente!"+e)
                    }
                
                }
            
                function getFuncLayoutEDI(valor, layoutsCliente){
                    var retorno = null;
                    for (i = 0; i < layoutsCliente.size(); i++) {
                        if (layoutsCliente[i].layoutEDI.id == valor) {
                            retorno =  layoutsCliente[i].layoutEDI;
                            break;
                        }
                    }
                    return retorno;
                }
            
                function povoarSelect(elemento, lista, isDivisao, tipo){
                        try {
                        if (isDivisao && tipo == "o") {
                            optLayout = Builder.node("option", {value: "---"});
                            Element.update(optLayout, "--------------------------------------------------------------");
                            elemento.appendChild(optLayout);
                        }
                        
                        var optLayout = null;
                            if (lista != null) {
                            for(var i = 0; i < lista.length; i++){
                                if (lista[i] != null && lista[i] != undefined) {
                                    optLayout = Builder.node("option", {value: lista[i].valor});
                                    Element.update(optLayout, lista[i].descricao);
                                    elemento.appendChild(optLayout);
                                }
                            }
                            elemento.selectedIndex = 0;
                        }
                    } catch (e) { 
                        alert(e);
                    }
                }
            
                function mostrarTodosLayouts(){
                    //removeOptionSelected("cbexportar");
                    povoarSelect($("cbexportar"), listLayoutEDITela, false, "");
                    povoarSelect($("cbexportar"), listLayoutEDI_c, false, "");
                    povoarSelect($("cbexportar"), listLayoutEDI_o, false, "");
                }
        
        
        
  var dataAtualSistema = '<%=new SimpleDateFormat("dd/MM/yyyy").format(Apoio.paraDate(Apoio.getDataAtual()))%>';
  
        function exportar(){
            var coletas = getCheckedsColeta();
            var modelo = $('cbexportar').value;
        
            if (coletas == "") {
                alert("Selecione Pelo Menos uma Coleta!");
                return null;
            }
            
            if ( modelo == 'ATM'){
                document.location.href = './averbacao.txt4?ids='+coletas + '&modelo=COLETA';
            }else if (modelo == 'APISUL'){
                document.location.href = './averbacao.txt5?ids='+coletas + '&modelo=COLETA';
            }else if(modelo.indexOf("funcEdi") > -1){
                                var layout = getFuncLayoutEDI(modelo.split("!!")[0], layoutsFunctionAll_c);
                                if (layout == null) {
                                    layout = getFuncLayoutEDI(modelo.split("!!")[0], layoutsFunctionAll_o);
                                }                                
                                if (layout != null) {
                                    var nomeArquivo = layout.nomeArquivo;
                                    var horaAtualSistema = new Date();
                                    nomeArquivo = replaceAll(nomeArquivo, "@@dia", dataAtualSistema.split("/")[0]);
                                    nomeArquivo = replaceAll(nomeArquivo, "@@mes", dataAtualSistema.split("/")[1]);
                                    nomeArquivo = replaceAll(nomeArquivo, "@@ano", dataAtualSistema.split("/")[2]);
                                    nomeArquivo = replaceAll(nomeArquivo, "@@hora", horaAtualSistema.getHours());
                                    nomeArquivo = replaceAll(nomeArquivo, "@@minuto", horaAtualSistema.getMinutes());
                                    nomeArquivo = replaceAll(nomeArquivo, "@@segundo", horaAtualSistema.getSeconds());
                                    switch(layout.extencaoArquivo){
                                        case "txt":
                                             document.location.href = "./"+nomeArquivo+".txt3?modelo=funcEDI&ids="+coletas+"&layoutID="+layout.id+
                                             "&dtinicialedi="+$("dtemissao1").value+"&dtfinaledi="+$("dtemissao2").value+"&idconsignatario="+$("idremetente").value+
                                             "&tipoDataEdi="+$("campoDeConsulta").value+"&filial_id="+$("filialId").value;
                                            break;
                                    }
                                }else{
                                }
                            }
            
            
            
        }

        function marcarTodos(){
            var checado = $("marcarTodos").checked;

            for(var i = 0; i< linha ;i++){
                $("ck"+i).checked = checado;
            }
        }

        function viewSales(idCol){
            function e(transport){
                var textoresposta = transport.responseText;
                //se deu algum erro na requisicao...
                if (textoresposta == "load=0") {
                    return false;
                }else{
                    Element.show("col_"+idCol);
                    $("col_"+idCol).childNodes[(isIE()? 1 : 3)].innerHTML = textoresposta;
                }
            }//funcao e()
     
            if (Element.visible("col_"+idCol)){
                Element.toggle("col_"+idCol);
                $('plus_'+idCol).style.display = '';
                $('minus_'+idCol).style.display = 'none';
            }else{
                $('plus_'+idCol).style.display = 'none';
                $('minus_'+idCol).style.display = '';
                new Ajax.Request("./consulta_coleta.jsp?acao=obter_sales&idcoleta="+idCol,{method:'post', onSuccess: e, onError: e});
            }

        }

        function editarSale(id,categ){
            if (categ == 1){
                window.open('./frameset_conhecimento?acao=editar&id='+id+'&ex=false', 'CTRC' , 'top=0,resizable=yes');
            }else{
                window.open('./cadvenda.jsp?acao=editar&id='+id+'&ex=false', 'NF_Servico' , 'top=0,resizable=yes');
            }   
        }
    
        function popImg(id){
            window.open('./ImagemControlador?acao=carregar&idPedidoColeta='+id,
            'imagensMoto','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }
    
        function editarRomaneio(idRomaneio){
            window.open("./cadromaneio?acao=editar&id="+idRomaneio, "LocRomaneio" , 'top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
        }

    //removendo a função envSincronizacao(cpf, chave, id) pois não é mais utilizada.
    
    function popImg(id){
            window.open('./ImagemControlador?acao=carregar&idPedidoColeta='+id,
            'imagensMoto','top=80,left=70,height=500,width=800,resizable=yes,status=1,scrollbars=1');
    }
    
    function visualizarColetasAutomaticas(){
            window.open('./ColetasAutomaticasControlador?acao=visualizar',
            'Processar','top=10,left=0,height=900,width=1200,resizable=yes,status=1,scrollbars=1');
    }
    
    function abrirImportacao(idColeta,tipo){
        
        if (tipo == '0' && screen.width <= 768) {
            launchPopupLocate("./ConferenciaControlador?acao=importarArquivoColetaMobile&idColeta="+idColeta+"&tipoOperacao="+tipo, "Coleta");    
        } else {
            launchPopupLocate("./ConferenciaControlador?acao=importarArquivoColeta&idColeta="+idColeta+"&tipoOperacao="+tipo, "Coleta");
        }
        
    }


</script>
<%@page import="java.util.Vector"%>
<%@page import="filial.BeanFilial"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.net.URLEncoder" %>
<html>
    <head>
        <script type="text/javascript"  language="javascript" src="script/funcoes.js"></script>
        <script language="JavaScript"  src="script/prototype.js" type="text/javascript"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <title>Webtrans - Consulta de Coleta / OS</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="aoCarregar(); applyFormatter();">
        <img src="img/banner.gif">
        <br>
        <table width="98%" align="center" class="bordaFina" >
            <tr>
                <%
                    if (nivelUser >= 2) {
                %>
                <td width="547" align="left">
                    <b>Consulta de Coleta / OS  </b>
                </td>
                
                <td width="99">
                    <input name="bxcoleta" type="button" class="botoes" id="bxcoleta" 
                           onClick="javascript:tryRequestToServer(function(){document.location.replace('./bxcoleta?acao=iniciar');});" 
                           value="Baixar coletas">
                </td>
                <% }
                %>
                <%
                    if (nivelUser >= 3) {
                %>
                <td width="97">
                    <input name="imp_coleta" type="button" class="botoes" id="imp_coleta" 
                           onClick="javascript:tryRequestToServer(function(){document.location.replace('./importar_coleta.jsp?acao=iniciar');});" 
                           value="Importar Coletas (EDI)">
                </td>
                <% }
                %>
                <td width="96">
                    <input name="coletageral" type="button" class="botoes" id="coletageral" onClick="javascript:tryRequestToServer(function(){popColetaGeral();});" value="Imprimir coletas selecionadas">
                </td>
                <%
                   
                    if (nivelUser >= 3 && nivelColAuto >= 3) {                %>
                
                 <td width="50">
                    <input name="coletaAuto" type="button" class="botoes" id="coletaAuto" 
                           onClick="javascript:tryRequestToServer(function(){visualizarColetasAutomaticas();});" 
                           value="Processar Coletas Automáticas">
                </td>
                <% }  if (nivelUser >= 3) {
                %>
                <td width="110">
                    <input name="novo" type="button" class="botoes" id="novo" 
                           onClick="javascript:tryRequestToServer(function(){document.location.replace('./cadcoleta?acao=iniciar');});" 
                           value="Novo cadastro">
                </td>
                <% } %>
            </tr>
        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula"> 
                <td width="154"  height="20">
                    <div align="right">
                        <select name="campoDeConsulta" class="fieldMin" id="campoDeConsulta" 
                                onChange="javascript:habilitaConsultaDePeriodo(this.value=='dtsolicitacao' || this.value=='dtcoleta' || this.value=='p.created_at');">
                            <option value="p.numero">N&ordm; Coleta</option>
                            <option value="p.pedido_cliente">Pedido Cliente</option>
                            <option value="ct.numero">CTRC</option>
                            <option value="nf.numero">NF Cliente</option>
                            <option value="nf.pedido">Pedido NF Cliente</option>
                            <option value="dtsolicitacao">Data de Solicita&ccedil;&atilde;o</option>
                            <option value="dtcoleta">Data da Coleta</option>
                            <option value="p.created_at">Data de Inclusão</option>
                            <option value="cv.placa">Ve&iacute;culo</option>
                            <option value="ca.placa">Carreta</option>
                            <option value="pc.numero_container">N&ordm; Container</option>
                            <option value="pc.numero_booking">N&ordm; Booking</option>
                            <option value="pc.numero_viagem_navio">N&ordm; Viagem Container</option>
                        </select> 
                    </div>
                </td>
                <td width="171"> 
                    <select name="operador" id="operador" class="fieldMin" style="width: 190px;">
                        <option value="1">Todas as partes com</option>
                        <option value="2">Apenas com in&iacute;cio</option>
                        <option value="3">Apenas com o fim</option>
                        <option value="4" selected>Igual &agrave; palavra/frase</option>
                        <option value="10">Igual &agrave; palavra/frase (V&aacute;rios separados por v&iacute;rgula)</option>
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
                               value="<%=fmt.format(consCol.getDtEmissao1())%>" onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                </td>
                <td width="178"> 
                    <!-- Campo somente para consulta de intervalo de datas -->
                    <div id="div2" style="display:none ">At&eacute;: 
                        <input name="dtemissao2" style="font-size:8pt;" type="text" id="dtemissao2" size="10" maxlength="10" 
                               value="<%=fmt.format(consCol.getDtEmissao2())%>" onblur="alertInvalidDate(this)" class="fieldDate">
                    </div>
                    <input name="valorDaConsulta" type="text" id="valorDaConsulta" class="fieldMin" value="<%=consCol.getValorDaConsulta()%>" size="30" onKeyUp="javascript:if (event.keyCode==13) $('pesquisar').click();">    </td>
                <td width="256"> 
                    <div align="center">
                        <select name="filialId" id="filialId" class="fieldMin">
                            
                            <%if (nivelUserToFilial > 0) {%>
                            <option value="0">TODAS AS FILIAIS</option>
                            <%}
                                while (rsFl.next()) {
                                    if (nivelUserToFilial > 0 || Apoio.getUsuario(request).getFilial().getIdfilial() == rsFl.getInt("idfilial")) {%>
                            <option value="<%=rsFl.getString("idfilial")%>" 
                                    <%=(filial.equals(rsFl.getString("idfilial")) ? "selected" : "")%>>APENAS A <%=rsFl.getString("abreviatura")%></option>
                            <%}%>
                            <%}%>
                        </select>
                    </div>
                </td>
                <td width="83" rowspan="2">
                    <div align="center">
                        <input name="pesquisar" type="button" class="botoes" id="pesquisar" value="Pesquisar" title="Faz a pesquisa com os dados informados"
                               onClick="javascript:tryRequestToServer(function(){consultar('consultar');});">
                    </div>
                </td>
                <td width="93" rowspan="2">
                    <div align="center"></div>      
                    <div align="center">
                        Por p&aacute;g.:
                        <select name="limiteResultados" id="limiteResultados" class="fieldMin">
                            <option value="10" selected>10 resultados</option>
                            <option value="20">20 resultados</option>
                            <option value="30">30 resultados</option>
                            <option value="40">40 resultados</option>
                            <option value="50">50 resultados</option>
                        </select>
                    </div>
                    <div align="center"></div>      
                    <div align="center"></div>
                </td>
            </tr>
            <tr>
                <td width="32%" class="celula" >
                    <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly8pt" size="22" readonly="true" value="<%=remetente%>" >
                    <input name="localiza_rem" type="button" class="inputBotaoMin" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');">
                    <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os clientes';" >
                    <input type="hidden" name="idremetente" id="idremetente" value="<%=idRemetente%>">          
                </td>
                <td width="32%" class="celula">
                    <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly8pt" size="22" readonly="true" value="<%=destinatario%>">
                    <strong>
                        <input name="localiza_rem2" type="button" class="inputBotaoMin" id="localiza_rem2" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                    </strong>
                    <input type="hidden" name="iddestinatario" id="iddestinatario" value="<%=idDestinatario%>">          
                    <input type="hidden" name="cidadeId" id="cidadeId">          
                    <input type="hidden" name="idcidadedestino" id="idcidadedestino">          
                </td>
                <td width="34%" class="celula">
                    <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" size="22" readonly="true" value="<%=motorista%>">
                    <strong>
                        <input name="localiza_rem3" type="button" class="inputBotaoMin" id="localiza_rem3" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.MOTORISTA%>', 'Motorista');;">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';getObj('motor_nome').value = 'Todos os motoristas';">
                    </strong>
                    <input type="hidden" name="idmotorista" id="idmotorista" value="<%=idMotorista%>">
                </td>
                <td class="celula">
                    <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" size="8" readonly="true" value="<%=veiculoPlaca%>" style="float:left">
                    <strong>
                        <input name="localiza_vei" type="button" class="inputBotaoMin" id="localiza_vei" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=7', 'Veiculo');">
                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idveiculo').value = '0';getObj('vei_placa').value = 'Veiculo';">
                    </strong>
                    <input type="hidden" name="idveiculo" id="idveiculo" value="<%=veiculoId%>">
                </td>
                <!--<td colspan="4">
                    <table width="100%" border="0" cecfg.getRelDefaultColeta().equalsllspacing="1" cellpadding="2">
                        <tr>
                           <td width="33%" class="celula">
                               <input name="rem_rzs" type="text" id="rem_rzs" class="inputReadOnly8pt" size="28" readonly="true" value="< %=remetente%>">
                               <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=< %=BeanLocaliza.REMETENTE_DE_CONHECIMENTO%>', 'Remetente_');">
                               <img src="img/borracha.gif" border="0" class="imagemLink" align="absbottom" onClick="javascript:getObj('idremetente').value = '0';getObj('rem_rzs').value = 'Todos os clientes';">
                               <input type="hidden" name="idremetente" id="idremetente" value="< %=idRemetente%>">          
                           </td>
                           <td width="33%" class="celula">
                               <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly8pt" size="28" readonly="true" value="< %=destinatario%>">
                                   <strong>
                                        <input name="localiza_rem2" type="button" class="botoes" id="localiza_rem2" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=< %=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');;">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('iddestinatario').value = '0';getObj('dest_rzs').value = 'Todos os destinatarios';">
                                   </strong>
                               <input type="hidden" name="iddestinatario" id="iddestinatario" value="< %=idDestinatario%>">          
                           </td>
                           <td width="34%" class="celula">
                               <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly8pt" size="28" readonly="true" value="< %=motorista%>">
                                   <strong>
                                        <input name="localiza_rem3" type="button" class="botoes" id="localiza_rem3" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=< %=BeanLocaliza.MOTORISTA%>', 'Motorista');;">
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" onClick="javascript:getObj('idmotorista').value = '0';getObj('motor_nome').value = 'Todos os motoristas';">
                                   </strong>
                               <input type="hidden" name="idmotorista" id="idmotorista" value="< %=idMotorista%>">
                           </td>
                       </tr>
                    </table>
                </td>-->
            </tr>
            <tr>
                <td colspan="6">
                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                        <tr class="celula">
                            <td width="17%">
                                <div align="right">Mostrar(Coletas):</div>
                            </td>
                            <td width="10%">
                                <select name="baixada" id="baixada" class="fieldMin">
                                    <option value="todas">Todas</option>
                                    <option value="false"  selected>Em aberto</option>
                                    <option value="atrasada">Em aberto(Atrasadas)</option>
                                    <option value="true">Baixadas</option>
                                </select>
                            </td>
                            <td width="20%">
                                <div align="right">Mostrar(Coletas/OS):</div>
                            </td>
                            <td width="16%">
                                <select name="finalizada" id="finalizada" class="fieldMin">
                                    <option value="todas" selected>Todas</option>
                                    <option value="true">Finalizadas (Faturadas)</option>
                                    <option value="false">N&atilde;o Finalizadas</option>
                                    <option value="canceladas">Canceladas</option>
                                </select>
                            </td>
                            <td width="37%">
                                <input type="checkbox" name="chkNaoImpressas" id="chkNaoImpressas" <%=isNaoImpresso.equals("true") ? "checked" : ""%>>
                                Mostrar Apenas Coletas/OS n&atilde;o Impressas 
                            </td>
                        </tr>
                        <tr>
                            
                            <td class="celula" >
                                <div align="right">Apenas o Tipo:</div>
                            </td>
                            <td width="10%" class="celula">
                               <div align="center"> 
                                   <select name="tipoColeta" id="tipoColeta" class="fieldMin">
                                   <option value="am" selected> Ambas </option>
                                   <option value="co"> Apenas Coleta </option>
                                   <option value="os" > Apenas OS </option>
                                   </select>
                               </div>
                            </td>
                            
                            <td class="celula" width="10%">
                                <input id="cid_origem" class="inputReadOnly8pt" type="text" value="<%=descricaoCidadeOrigem%>" readonly="true" size="22" name="cid_origem">                                
                                <input id="localiza_cidade_origem" class="inputBotaoMin" type="button" onclick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=11', 'Cidade_Origem');" value="..." name="localiza_cidade_origem"/>
                                <img class="imagemLink" border="0" align="absbottom" onclick="javascript:getObj('idcidadeorigem').value = '0';getObj('cid_origem').value = 'Todas as cidades de origem';" src="img/borracha.gif"/>
                                <input type="hidden" id="idcidadeorigem" value="<%=idCidadeOrigem%>" name="idcidadeorigem"/>
                            </td>
                            <td class="celula" width="10%" style="text-align: left">
                                <input id="cid_destino" class="inputReadOnly8pt" type="text" value="<%=descricaoCidadeDestino %>" readonly="true" size="22" name="cid_destino">                                
                                <input id="localiza_cidade_destino" class="inputBotaoMin" type="button" onclick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=12', 'Cidade_Destino');" value="..." name="localiza_cidade_destino"/>
                                <img class="imagemLink" border="0" align="absbottom" onclick="javascript:getObj('idcidadedestino').value = '0';getObj('cid_destino').value = 'Todas as cidades de destino';" src="img/borracha.gif"/>
                                <input type="hidden" id="idcidadedestino" value="<%=idCidadeDestino%>" name="idcidadedesino"/>
                            </td>
                            
                            <td class="celula" colspan="2">
                            </td>
                            
                        </tr>
                        
                    </table>
                </td>
            </tr>
        </table>
        <table width="98%" border="0" align="center" class="bordaFina" cellspacing="1" cellpadding="2">
            <tr class="tabela">
                <td width="2%">
                    <input type="checkbox" name="marcarTodos" id="marcarTodos" onclick="marcarTodos();" title="Marcar Todos">
                </td>
                <td width="2%">&nbsp;</td>
                <td width="2%"></td>
                <td width="2%"></td>
                <td width="1%"></td>
                <td width="1%"></td>
                <td width="1%"></td>
                <td width="6%">Coleta</td>
                <td width="6%">Solicit.</td>
                <td width="19%">Cliente</td>
                <td width="14%">Destino</td>
                <td width="14%">Motorista</td>
                <td width="8%">Ve&iacute;culo</td>
                <td width="7%">Carreta</td>
                <td width="7%">Bi-Trem</td>
                <td width="8%">Filial</td>
                <td width="2%">&nbsp;</td>
            </tr>
            <%int linha = 0;
                int linhatotal = 0;
                int qtde_pag = 0;

                if (acao.equals("iniciar") || acao.equals("consultar") || acao.equals("proxima") || acao.equals("anterior")) {
                    consCol.setConexao(Apoio.getConnectionFromUser(request));
                    if (consCol.Consultar()) {
                        ResultSet r = consCol.getResultado();
                        while (r.next()) {
            %>              <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                <td width="20">
                    <input name="ck<%=linha%>" type="checkbox" value="<%=r.getInt("id_pedido")%>" id="ck<%=linha%>">
                </td>
                <td></td>
                <td>
                    <div align="center">
                        <img src="img/pdf.gif" id="imgImpRelatorio_<%=linha%>" width="19" height="20" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)" onClick="javascript:tryRequestToServer(function(){popColeta('<%=r.getString("id_pedido")%>');});">
                    </div>
                </td>
                <td>
                    <img src="img/jpg.png" width="19" height="19" border="0" align="right" class="imagemLink" title="Imagens de documentos"
                         onClick="javascript:tryRequestToServer(function(){popImg('<%=r.getString("id_pedido")%>');});">
                </td>
                <td>
                    <a href="#"><img src="img/seta-azul.png" width="19" height="19" border="0" onclick="javascript:tryRequestToServer(function(){abrirImportacao('<%=r.getString("id_pedido")%>',0);});"></a>
                </td>
                <td>
                    <a href="#"><img src="img/seta-verde.png" width="19" height="19" border="0" onclick="javascript:tryRequestToServer(function(){abrirImportacao('<%=r.getString("id_pedido")%>',1);});"></a>
                </td>
                <td>
                    <img src="img/plus.jpg" id="plus_<%=r.getString("id_pedido")%>" name="plus_<%=r.getString("id_pedido")%>" title="Mostrar duplicatas" class="imagemLink" align="right" 
                         onclick="javascript:tryRequestToServer(function(){viewSales(<%=r.getString("id_pedido")%>);});">
                    <img src="img/minus.jpg" id="minus_<%=r.getString("id_pedido")%>" name="minus_<%=r.getString("id_pedido")%>" title="Mostrar duplicatas" class="imagemLink" align="right" style="display:none "
                         onclick="javascript:tryRequestToServer(function(){viewSales(<%=r.getString("id_pedido")%>);});">
                </td>
                <td>
                    <div class="linkEditar" onClick="javascript:tryRequestToServer(function(){editar(<%=r.getInt("id_pedido")%>);});">
                        <%=r.getString("numero")%>
                    </div>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>"> <%=fmt.format(r.getDate("solicitada_em"))%></font>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>">
                    <%=r.getString("cliente") + (!r.getString("nome_fantasia_cliente").equals("") && !r.getString("nome_fantasia_cliente").equals(r.getString("cliente")) ? " (" + r.getString("nome_fantasia_cliente") + ")" : "")%>
                    </font>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>"><%=(r.getString("destinatario").equals("") ? "" : r.getString("destinatario") + "<br>") + r.getString("cidade_destino") + (r.getString("uf_destino").equals("") ? "" : "-" + r.getString("uf_destino"))%></font>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>">
                    <%if (r.getInt("motorista_id") != 0) {%>
                    <img src="img/page_edit.png" border="0" onClick="javascript:verMotorista(<%=r.getInt("motorista_id")%>);" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    <%}%>
                    <%=r.getString("motorista")%>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>">

                    <%if (r.getInt("veiculo_id") != 0) {%>
                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo(<%=r.getInt("veiculo_id")%>);" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    <%}%>
                    <%=r.getString("placa_veiculo").equals("") ? "" : r.getString("placa_veiculo")  %></font>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>">

                    <%if (r.getInt("carreta_id") != 0) {%>
                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo(<%=r.getInt("carreta_id")%>);" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    <%}%>
                    <%=r.getString("placa_carreta").equals("") ? "" : r.getString("placa_carreta")  %></font>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>">

                    <%if (r.getInt("bitrem_id") != 0) {%>
                    <img src="img/page_edit.png" border="0" onClick="javascript:verVeiculo(<%=r.getInt("bitrem_id")%>);" title="Ver Cadastro" class="imagemLink" style="vertical-align:middle; ">
                    <%}%>
                    <%=r.getString("placa_bitrem").equals("") ? "" : r.getString("placa_bitrem")  %></font>
                </td>
                <td>
                    <font color="<%=(r.getBoolean("cancelada") ? "red" : "")%>"><%=r.getString("filial")%></font>
                </td>
                <td>
                    <%
                        if ((nivelUser == 4) && (r.getBoolean("pode_excluir"))) {
                    %>                     
                    <img src="img/lixo.png" title="Excluir este registro" class="imagemLink" align="right"
                         onclick="javascript:tryRequestToServer(function(){excluir(<%=r.getString("id_pedido")%>);});">    
                    <%
                        }
                    %>               
                </td>
            </tr>
            <%if ((r.getString("numero_container") != null && !r.getString("numero_container").equals(""))
                                       || (r.getString("pedido_cliente") != null && !r.getString("pedido_cliente").equals(""))
                                       || (r.getString("romaneio") != null && !r.getString("romaneio").equals(""))) {%>
            <tr>
                <td colspan="15">
                    <table width="100%" border="0" align="center" cellspacing="1" cellpadding="2">
                        <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1" : "CelulaZebra2")%>">
                            <td width="9%" align="right">Nº Container:</td>
                            <td width="15%" >
                                <%=r.getString("numero_container")%>
                            </td>
                            <td width="7%" align="right">Nº Pedido:</td>
                            <td width="15%">
                                <%=r.getString("pedido_cliente")%>
                            </td>
                            <td width="9%" align="right">Nº Romaneio:</td>
                            <td width="15%">
                                <div onclick="javascript:tryRequestToServer(function(){editarRomaneio('<%=r.getString("idromaneio")%>');});" class="linkEditar">
                                    <%=r.getString("romaneio")%>
                                </div>
                            </td>
                            <td width="30%"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%}%>
            <tr style="display:none" id="col_<%=r.getString("id_pedido")%>">
                <td rowspan="1" class='CelulaZebra1'></td>
                <td rowspan="1" colspan="15">--</td>
            </tr>
            <%
                if (r.isLast()) {
                    linhatotal = r.getInt("qtde_linhas");
                }
                linha++;
            %>
            <script type="text/javascript" language="javascript" >++linha;</script>
            <%
                        }

                        int limit = consCol.getLimiteResultados();
                        qtde_pag = (linhatotal / limit) + (linhatotal % limit == 0 ? 0 : 1);
                    }
                }
            %> 

        </table>
        <br>
        <table width="98%" align="center" cellspacing="1" class="bordaFina">
            <tr class="celula">
                <td width="15%" height="10">
            <center>
                Ocorr&ecirc;ncias: <b><%=linha%> / <%=linhatotal%></b>
            </center>
        </td>
        <%if (consCol.getPaginaResultados() < qtde_pag) {%>
        <td width="15%" rowspan="2" align="center">
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Anterior"  onClick="javascript:tryRequestToServer(function(){consultar('anterior');});">
            
            <input name="avancar" type="button" class="botoes" id="avancar"
                   value="Pr&oacute;xima"  onClick="javascript:tryRequestToServer(function(){consultar('proxima');});">
        </td>
        <%}%>
        <td width="14%" align="right">
            Exportar para:        
        </td>
        <td  width="19%" align="right">
            <div align="left">
                <select name="cbexportar" id="cbexportar" class="fieldMin">
                    <option value="ATM" Selected>Averba&ccedil;&atilde;o (AT&amp;M)</option>
                    <option value="APISUL">Averba&ccedil;&atilde;o (APISUL)</option>
                </select>
                <input name="exportar" type="button" class="botoes" id="exportar" value="OK"  onClick="javascript:tryRequestToServer(function(){exportar();});">    
            </div>
        <td width="17%">
            <div align="center">
                <input type="radio" name="impressao" id="pdf" value="1" onclick="alterarImgFormato(this)" checked/>
                <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                <input type="radio" name="impressao" id="excel" onclick="alterarImgFormato(this)" value="2" />
                <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                <input type="radio" name="impressao" id="word" onclick="alterarImgFormato(this)" value="3" />
                <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
            </div>
        </td>
        <td colspan="4" align="right">
            Modelo em PDF:
            <select name="cbmodelo" id="cbmodelo" class="fieldMin" style="width: 220px;">
                <option value="1" <%=cfg.getRelDefaultColeta().equals("1") ? "selected" : ""%>>Modelo 1 (Coleta)</option>
                <option value="2" <%=cfg.getRelDefaultColeta().equals("2") ? "selected" : ""%>>Modelo 2 (Coleta)</option>
                <option value="3" <%=cfg.getRelDefaultColeta().equals("3") ? "selected" : ""%>>Modelo 3 (Coleta)</option>
                <option value="4" <%=cfg.getRelDefaultColeta().equals("4") ? "selected" : ""%>>Modelo 4 (Coleta)</option>
                <option value="5" <%=cfg.getRelDefaultColeta().equals("5") ? "selected" : ""%>>Modelo 5 (Coleta)</option>
                <option value="6" <%=cfg.getRelDefaultColeta().equals("6") ? "selected" : ""%>>Modelo 6 (OS)</option>
                <option value="7" <%=cfg.getRelDefaultColeta().equals("7") ? "selected" : ""%>>Modelo 7 (Coleta)</option>
                <option value="8" <%=cfg.getRelDefaultColeta().equals("8") ? "selected" : ""%>>Modelo 8 (Relatório de embarque)</option>
                <option value="9" <%=cfg.getRelDefaultColeta().equals("9") ? "selected" : ""%>>Modelo 9 (Coleta Container)</option>
                <option value="10" <%=cfg.getRelDefaultColeta().equals("10") ? "selected" : ""%>>Modelo 10 (Coleta Container)</option>
                <option value="11" <%=cfg.getRelDefaultColeta().equals("11") ? "selected" : ""%>>Modelo 11 (Coleta Container)</option>
                <option value="12" <%=cfg.getRelDefaultColeta().equals("12") ? "selected" : ""%>>Modelo 12 (Coleta Container)</option>
                <option value="13" <%=cfg.getRelDefaultColeta().equals("13") ? "selected" : ""%>>Modelo 13 (Coleta)</option>
                <option value="14" <%=cfg.getRelDefaultColeta().equals("14") ? "selected" : ""%>>Modelo 14 (Coleta BUNGE)</option>
                <option value="15" <%=cfg.getRelDefaultColeta().equals("15") ? "selected" : ""%>>Modelo 15 (Coleta)</option>
                <option value="16" <%=cfg.getRelDefaultColeta().equals("16") ? "selected" : ""%>>Modelo 16 (Paletização)</option>
                <option value="17" <%=cfg.getRelDefaultColeta().equals("17") ? "selected" : ""%>>Modelo 17 (Declaração das Condições da Carga)</option>
                <option value="18" <%=cfg.getRelDefaultColeta().equals("18") ? "selected" : ""%>>Modelo 18 (Coleta)</option>
                <option value="19" <%=cfg.getRelDefaultColeta().equals("19") ? "selected" : ""%>>Modelo 19 (Coleta Aérea)</option>
                <%
                    if (cfg.isGeraGEMColeta()) {
                %>
                <option value="md" <%=cfg.getRelDefaultColeta().equals("md") ? "selected" : ""%>>Mapa de descarga(gwLogis)</option>
                <option value="cr" <%=cfg.getRelDefaultColeta().equals("cr") ? "selected" : ""%>>Comprovante de Recebimento(gwLogis)</option>
                <option value="co" <%=cfg.getRelDefaultColeta().equals("co") ? "selected" : ""%>>Controle de ocorrências(gwLogis)</option>
                <%
                    }
                %>
                <%
                            for (String rel : Apoio.listDocColeta(request)) {%>
                <option value="doc_coleta_personalizado_<%=rel%>" <%=(cfg.getRelDefaultColeta().startsWith("doc_coleta_personalizado_"+rel) ? "selected" : "")%> >Modelo <%=rel.toUpperCase()%> (Personalizado)</option>
                <%}%>


            </select>            
            </tr>
        <tr class="celula">
            <td height="11">
                <div align="center">
                    P&aacute;ginas: 
                    <b><%=(qtde_pag == 0 ? 0 : consCol.getPaginaResultados())%> / <%=qtde_pag%></b>
                </div>
            </td>
            <td align="right">Impressora:</td>
            <td colspan="3" align="right">
                <div align="right"></div>      
                <div align="left">
                    <span class="CelulaZebra2">
                        <select name="caminho_impressora" id="caminho_impressora" class="fieldMin">
                            <option value="">&nbsp;&nbsp;</option>
                            <%BeanConsultaImpressora impressoras = new BeanConsultaImpressora();
                                impressoras.setConexao(Apoio.getUsuario(request).getConexao());
                                impressoras.setLimiteResultados(50);

                                if (impressoras.Consultar()) {
                                    ResultSet rs = impressoras.getResultado();
                                    while (rs.next()) {%>
                            <option value="<%=rs.getString("descricao")%>" <%=(rs.getString("descricao").equals(Apoio.getUsuario(request).getFilial().getCaminhoImpressora()) ? "selected" : "")%>><%=rs.getString("descricao")%></option>
                            <%}%>
                            <%}%>
                        </select>
                    </span>    
                </div>
            <td>
                <div align="right">
                    Driver:    
                </div>
            </td>
            <td>
                <div align="left">
                    <select name="driverImpressora" id="driverImpressora" class="fieldMin">
                        <option value="">&nbsp;</option>
                        <%Vector drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "col.txt");

                            for (int i = 0; i < drivers.size(); ++i) {
                                String driv = (String) drivers.get(i);
                                driv = driv.substring(0, driv.lastIndexOf("."));
                        %>
                        <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                        <%}

                            drivers = Apoio.listFiles(Apoio.getDirDrivers(request), "prn.txt");
                            for (int i = 0; i < drivers.size(); ++i) {
                                String driv = (String) drivers.get(i);
                                driv = driv.substring(0, driv.lastIndexOf("."));
                        %>
                        <option value="<%=driv%>"><%=driv%>&nbsp;</option>
                        <%}%>
                    </select>
                </div>
            </td>
            <td>
                <img src="img/ctrc.gif" class="imagemLink" title="Imprimir Coletas selecionados" onClick="printMatricideColeta();">
            </td>
        </tr>
    </table>
</body>
</html>