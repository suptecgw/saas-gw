<%@page import="usuario.BeanUsuario"%>
<%@page import="despesa.apropriacao.BeanApropDespesa"%>
<%@page import="despesa.duplicata.BeanDuplDespesa"%>
<%@page import="conhecimento.BeanConhecimento"%>
<%@page import="java.util.Date"%>
<%@page import="conhecimento.awb.BeanConsultaAWB"%>
<%@page import="conhecimento.awb.BeanAWB"%>
<%@page import="conhecimento.awb.BeanCadAWB"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collection"%>
<%@page import="conhecimento.ocorrencia.Ocorrencia"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         java.text.*,
         nucleo.*,
         java.util.Date.*" errorPage="" %>

<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/beans/CTRC.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/mascaras.js"></script>

<%
            // privilégio de permissao. Ex.: if (nivelUser == 4) <usuario pode excluir
            BeanUsuario usu = Apoio.getUsuario(request);
            int nivelUser = usu.getAcesso("cadawb");
            int nivelImpresso = usu.getAcesso("alterarawbimpresso");
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
%>
<%//ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de

            
            String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
            String acaoanterior = (request.getParameter("acaoanterior") == null ? "" : request.getParameter("acaoanterior"));
            boolean iscarregaawb = false;
            BeanCadAWB cadawb = null;
            BeanAWB awb = null;
            BeanConsultaAWB carregaAwb = null;
            BeanConfiguracao cfg = null;

            //instanciando um formatador de simbolos
            DecimalFormatSymbols dfs = new DecimalFormatSymbols();
            SimpleDateFormat fmtMesAno = new SimpleDateFormat("MM/yyyy");
            SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
            dfs.setDecimalSeparator('.');
            DecimalFormat vlrformat = new DecimalFormat("0.00", dfs);
            vlrformat.setDecimalSeparatorAlwaysShown(true);

            //Variáveis que servirão para armazenar os valores do loop dos conhecimentos
            int linha = 0;
            int linhaOco = 0;
            float qtd = 0;
            float peso = 0;
            float notas = 0;
            float frete = 0;
            boolean baixado = false;
            //Instaciando variável para formatação de datas
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
            SimpleDateFormat formatoHora = new SimpleDateFormat("HH:mm");
            String hora = formatoHora.format(new Date());

            //Carregando as configuraões independente da ação
            cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();

            //instrucoes em comum entre as acoes
            if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("calcula")) {    //instanciando o bean de cadastro
                cadawb = new BeanCadAWB();
                cadawb.setExecutor(Apoio.getUsuario(request));
                cadawb.setConexao(Apoio.getUsuario(request).getConexao());
                carregaAwb = new BeanConsultaAWB();
                carregaAwb.setConexao(Apoio.getUsuario(request).getConexao());

                //executando a acao desejada
                //ao solicitar alteração o bean será carregado com todos os dados do id atual
                if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
                    int idAWB = Integer.parseInt(request.getParameter("id"));
                    
                    cadawb.getAwb().setId(idAWB);
                    //carregando o conhecimento por completo
                    cadawb.LoadAllPropertys();
                    awb = cadawb.getAwb();
                } else //ao clicar no salvar dessa tela
                if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
                    Collection listaOco = new ArrayList();
                    Ocorrencia oco = null;

                    int pp = 0;
                    //Instanciando o objeto

                    awb = new BeanAWB();
                    BeanConhecimento ctrc = null;
                    Collection listaCtrc = new ArrayList<BeanConhecimento>();
                    //populando o JavaBeanidmanifesto
                    awb.setId(request.getParameter("id"));
                    awb.setNumero(request.getParameter("nAWB"));
                    awb.setNumeroAWB(request.getParameter("numeroAWB"));
                    awb.setNumeroVoo(request.getParameter("numeroVoo"));
                    awb.setValorFrete(Double.parseDouble(request.getParameter("valorFrete")));
                    awb.getCidadeDestino().setIdcidade(Integer.parseInt(request.getParameter("idcidadedestino")));
                    awb.getCidadeOrigem().setIdcidade(Integer.parseInt(request.getParameter("idcidadeorigem")));
                    awb.getCompanhiaAerea().setIdfornecedor(Integer.parseInt(request.getParameter("idcompanhia")));
                    awb.getCompanhiaAerea().setRazaosocial(request.getParameter("companhia_aerea"));
                    awb.setEmissaoEm(Apoio.paraDate(request.getParameter("emissaoEm")));
                    awb.setEmissaoAs(request.getParameter("emissaoAs"));
                    awb.setPrevisaoEmbarqueEm(request.getParameter("previsaoEmbarqueEm").equals("")?null:Apoio.paraDate(request.getParameter("previsaoEmbarqueEm")));
                    awb.setPrevisaoEmbarqueAs(request.getParameter("previsaoEmbarqueAs"));
                    //capturando a quantidade de conhecimentos
                    int qtdCtrc = Integer.parseInt(request.getParameter("qtdCtrc"));
                    //carregando a lista de conhecimentos
                    for (int i = 1; i<= qtdCtrc;i++){
                        ctrc = new BeanConhecimento();
                        ctrc.setId(Integer.parseInt(request.getParameter("ctrcId_"+i)));
                        ctrc.setValorPesoReal(Float.parseFloat(request.getParameter("pesoReal_"+i)));
                        listaCtrc.add(ctrc);
                    }
                    
                    //inserindo a lista ao awb
                    awb.setConhecimentos(listaCtrc);

                    //Instanciando o BeanCadManifesto
                    cadawb.setAwb(awb);

                    //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
                    //3º teste de erro naquela acao executada.
                    boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                            ? cadawb.Inclui() : cadawb.Atualiza());


                    //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="JavaScript" type="text/javascript"><%
                    if (erro) {
                        acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(cadawb.getErros())%>');
        window.opener.habilitaSalvar(true);
    <%
                            awb = cadawb.getAwb();
                        } else {
    %>
        if (window.opener != null)
    <%// O parametro 'aosalvar' receberá 0 para salvar e sair ou 1 para salvar e incluir outro
                            String irPara = "./consulta_awb.jsp?acao=iniciar";
                            String scr = "";
                            scr = "<script>";
                            if (request.getParameter("idmovs") != null) {
                                scr += "window.open('./matricidectrc.ctrc?&idmovs=" + request.getParameter("idmovs") + "&driverImpressora=" + request.getParameter("driverImpressora") + "');";
                            }
                            ;

                            scr += "window.opener.document.location.replace('" + irPara + "');"
                                    + " window.close();"
                                    + "</script>";


                            response.getWriter().append(scr);
                            response.getWriter().close();

                        }%>
                            window.close();
</script>

<%   }
            }
            if (acao.equals("carregarOcorrencia")) {
            }

            if (acao.equals("calcula")) {
            }
            //Variavel usada para saber se o usuario esta editando
            iscarregaawb = (awb != null) && (!acao.equals("incluir") && !acao.equals("atualizar"));

%>
<script language="JavaScript" type="text/javascript">
function aoCarregar(){
 var iscarrega = <%=iscarregaawb%>
   
        carregarCtrcs();
        calculaPesoReal();
        
}

function carregarCtrcs(){
    <%
        BeanConhecimento ctrc = null;
        if(awb!=null){
            Iterator iListaCtrc = awb.getConhecimentos().iterator();
            while(iListaCtrc.hasNext()){
                // no java
                ctrc = (BeanConhecimento) iListaCtrc.next();

            %>
            //no javaScript
            var ctrc = new CTRC('<%=ctrc.getId()%>', '<%=ctrc.getNumero()%>', '<%=ctrc.getSerie()%>',
                        '<%=ctrc.getRemetente().getRazaosocial()%>',
                        '<%=ctrc.getDestinatario().getRazaosocial()%>',
                        '<%=ctrc.getValorVolume()%>',
                        '<%=ctrc.getValorPeso()%>', 
                        '<%=ctrc.getBaseCalculo()%>',
                        '<%=ctrc.getValorFrete()%>',
                        '<%=ctrc.getValorPesoReal()%>');
            addCTRC(ctrc);
            <%
            }
        }
        
    %>
}

function check() {

    if (wasNull("idfilial,dtsaida,hrsaida,idcidadeorigem,idcidadedestino")){
        return false;
    }
    if ($('tipo_movimento').value == 'm'){
        if (!wasNull("motor_nome,vei_placa,motor_liberacao")){
            return true;
        }else{
            return false;
        }
    }else if ($('tipo_movimento').value == 'a'){
        if ($('idcompanhia').value == '0'){
            alert('Informe a companhia aérea corretamente');
            return false;
        }else if($('destinatario_awb').value == 'rd' &&  $('idredespachante').value == '0'){
            alert('Informe o redespachante corretamente');
            return false;
        }else{
            return true;
        }
    }else{
        if (wasNull("motor_nome,vei_placa")){
            return false;
        }else{
            return true;
        }
    }
}

function voltar(){
    document.location.replace("./consulta_awb.jsp?acao=iniciar");
}

function getCtrcs(){
//retorna os IDs dos conhecimentos deste manifestoids
    var idsCtrcAwb="0";
    for(var i = 0; i<=idxCtrc;i++){
        if($("ctrcId_"+i)!=null){
            idsCtrcAwb +=(idsCtrcAwb==""?"":",")+ $("ctrcId_"+i).value;
        }
    }
    return idsCtrcAwb;
}

function selecionar_rc(qtdLinhas,acao){
//pegando os conhecimentos ja incluidos no manifesto
    var idsCtrcAwb=getCtrcs();

// chama a tela que inclue conhecimentos neste manifesto
    post_cad = window.open('./pops/jspseleciona_ctrc_awb.jsp?acao=iniciar&idsCtrcAwb='+idsCtrcAwb+'&acaoDoPai='+acao+'&mostratudo='
        +getObj("mostratudo").checked+'&dtinicial=<%=Apoio.getDataAtual()%>&dtfinal=<%=Apoio.getDataAtual()%>&tipo='+ $('tipo_movimento').value,'CtrcAwb',
    'top=50,left=0,height=600,width=950,resizable=yes,status=1,scrollbars=1');
}

function habilitaSalvar(opcao){
    $("salvar").disabled = !opcao;
    $("salvar").value = (opcao ? "Salvar" : "Enviando...");
}

function salva(acao,qtdLinhas,pesoTotal){
    $("acao").value = '<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>';

    if($("idcompanhia").value==0 ){
        alert("Escolha uma Companhia Aérea!");
        $("companhia_aerea").style.background ="#FFE8E8";
        $("localiza_companhia").focus();
        return false;
    }else if($("numeroVoo").value=="" && parseFloat($("valorFrete").value)>0 ){
        alert("Informe o Número do Vôo!");
        $("numeroVoo").style.background ="#FFE8E8";
        $("numeroVoo").focus();
        return false;
    }else if($("valorFrete").value.trim()==""){
        alert("O valor do frete nao pode ser vazio!");
        $("valorFrete").style.background ="#FFE8E8";
        $("valorFrete").focus();
        return false;
    }else if(idxCtrc==0){
        alert("Escolha no minimo um Conhecimento");
        return false;
    }

    for (var i = 1 ; i <= idxCtrc; i++){
        if($("pesoReal_"+i).value == "0.00"){
            alert("O campo \'Peso Real\' não pode ser zero.");
            $("pesoReal_"+i).style.background ="#FFE8E8";
            return false;
        }
    }

    //window.open('', '', 'width=210, height=100');
    $("formulario").action = "./cadawb.jsp?acao="+ acao;
    window.open('about:blank', 'pop', 'width=210, height=100');
    $("formulario").submit();
}

function editarDespesa(id, podeExcluir){
    window.open("./caddespesa?acao=editar&id="+id+"&podeExcluir="+podeExcluir, "Despesa", "height=500,width=1100,resizable=yes, scrollbars=1,top=10,left=0,status=1");
}

//--------------------------- CTRC     -------------------------------
var idxCtrc = 0;

function addCTRC(ctrc){
    idxCtrc++;
    if (ctrc == undefined){
        ctrc = new CTRC()
    }
    //criando tr
    var tr_ = Builder.node("tr", {
        id:"trCtrc_"+idxCtrc,
        name:"trCtrc_"+idxCtrc,
        className:"CelulaZebra"+(idxCtrc%2==0?1:2)
    });



    // criando td 1
    var td1_ = Builder.node("TD");

    // criando imagem
    var inp1_ = Builder.node("INPUT", {type:"hidden", name:"ctrcId_"+idxCtrc, id:"ctrcId_"+idxCtrc,
        value: ctrc.id});
    var lab1_ = Builder.node("LABEL", {name:"emissaoEm_"+idxCtrc, id:"emissaoEm_"+idxCtrc});
    td1_.appendChild(inp1_);    
    td1_.appendChild(lab1_);
    
    var td2_ = Builder.node("TD");
    var lab2_ = Builder.node("LABEL", {name:"ctrc_"+idxCtrc, id:"ctrc_"+idxCtrc});
    td2_.appendChild(lab2_);

    var td3_ = Builder.node("TD");
    var lab3_ = Builder.node("LABEL", {name:"remetente_"+idxCtrc, id:"remetente_"+idxCtrc});
    td3_.appendChild(lab3_);

    var td4_ = Builder.node("TD");
    var lab4_ = Builder.node("LABEL", {name:"destinatario_"+idxCtrc, id:"destinatario_"+idxCtrc});
    td4_.appendChild(lab4_);

    var div5_ = Builder.node("div",{align: "right"});
    var td5_ = Builder.node("TD");
    var lab5_ = Builder.node("LABEL", {name:"qtd_"+idxCtrc, id:"qtd_"+idxCtrc});
    div5_.appendChild(lab5_);
    td5_.appendChild(div5_);

    var div6_ = Builder.node("div",{align: "right"});
    var td6_ = Builder.node("TD");
    var lab6_ = Builder.node("LABEL", {name:"peso_"+idxCtrc, id:"peso_"+idxCtrc});
    div6_.appendChild(lab6_);
    td6_.appendChild(div6_);

    var div9_ = Builder.node("div",{align: "right"});
    var td9_ = Builder.node("TD");

    var hid9_ = Builder.node("INPUT", {name:"hi_pesoReal_"+idxCtrc, id:"hi_pesoReal_"+idxCtrc,
         value:formatoMoeda(ctrc.pesoReal),type:"hidden"});
    var inp9_ = Builder.node("INPUT", {name:"pesoReal_"+idxCtrc, id:"pesoReal_"+idxCtrc,
        className:"fieldMin", size:"8", maxLength:"10", value:formatoMoeda(ctrc.pesoReal),
        onchange:'seNaoFloatReset($(\'pesoReal_'+idxCtrc+'\'), $(\'hi_pesoReal_'+idxCtrc+'\').value);calculaPesoReal();;', type:"text"});
    div9_.appendChild(hid9_);
    div9_.appendChild(inp9_);
    td9_.appendChild(div9_);

    var div7_ = Builder.node("div",{align: "right"});
    var td7_ = Builder.node("TD");
    var lab7_ = Builder.node("LABEL", {name:"valorNFs_"+idxCtrc, id:"valorNFs_"+idxCtrc});
    div7_.appendChild(lab7_);
    td7_.appendChild(div7_);

    var div8_ = Builder.node("div",{align: "right"});
    var td8_ = Builder.node("TD");
    var lab8_ = Builder.node("LABEL", {name:"valorFrete_"+idxCtrc, id:"valorFrete_"+idxCtrc});
    div8_.appendChild(lab8_);
    td8_.appendChild(div8_);

    
    tr_.appendChild(td1_);
    tr_.appendChild(td2_);
    tr_.appendChild(td3_);
    tr_.appendChild(td4_);
    tr_.appendChild(td5_);
    tr_.appendChild(td6_);
    tr_.appendChild(td9_);
    tr_.appendChild(td7_);
    tr_.appendChild(td8_);


    $('tbCTRC').appendChild(tr_);
        $("emissaoEm_"+idxCtrc).innerHTML= ctrc.emissaoEm;
        $("ctrc_"+idxCtrc).innerHTML=ctrc.numero;
        $("remetente_"+idxCtrc).innerHTML=ctrc.remetente;
        $("destinatario_"+idxCtrc).innerHTML= ctrc.destinatario;
        $("qtd_"+idxCtrc).innerHTML= formatoMoeda(ctrc.qtd);
        $("peso_"+idxCtrc).innerHTML= formatoMoeda(ctrc.peso);
        $("valorNFs_"+idxCtrc).innerHTML= formatoMoeda(ctrc.valorNFs);
        $("valorFrete_"+idxCtrc).innerHTML= formatoMoeda(ctrc.valorFrete);

    //Atribuindo valores nas labels

    $("qtdCtrc").value = idxCtrc;
    calcula();
}

function calcula(){
    var i = idxCtrc;
    var totQtd = $("totQtd").innerHTML;
    var totPeso = $("totPeso").innerHTML;
    var totValor = $("totNotas").innerHTML;
    var totFrete = $("totFrete").innerHTML;

    if($("qtd_"+i)!=null){
       totQtd= formatoMoeda(parseFloat(totQtd)+ parseFloat($("qtd_"+i).innerHTML));
       totPeso= formatoMoeda(parseFloat(totPeso)+ parseFloat($("peso_"+i).innerHTML));
       totValor= formatoMoeda(parseFloat(totValor) + parseFloat($("valorNFs_"+i).innerHTML));
       totFrete= formatoMoeda(parseFloat(totFrete) + parseFloat($("valorFrete_"+i).innerHTML));
    }
           
    $("totCtrc").innerHTML = idxCtrc+" CT(s)";
    $("totQtd").innerHTML= totQtd;
    $("totPeso").innerHTML= totPeso;
    $("totNotas").innerHTML= totValor;
    $("totFrete").innerHTML= totFrete;
    
    
}

function calculaPesoReal(){
    var totPesoReal = 0;
    
    for(var i = 1;i<=idxCtrc; i++){
        totPesoReal= formatoMoeda(parseFloat(totPesoReal)+ parseFloat($("pesoReal_"+i).value));
    }
    $("totPesoReal").innerHTML= totPesoReal;
}

function removerCtrcs(){
    for(var i = 1; i<=idxCtrc;i++){
        Element.remove('trCtrc_'+i);
    }
    idxCtrc = 0;
    $("totCtrc").innerHTML = idxCtrc+" CT(s)";
    $("totQtd").innerHTML= "0.00";
    $("totPeso").innerHTML= "0.00";
    $("totNotas").innerHTML= "0.00";
    $("totFrete").innerHTML= "0.00";
}
//--------------------------- Ocorrência -------------------------------- inicio
var idxOco = 1;
var ctrcAux = '0';
var zebraAux = '1'

function Ocorrencia(id, ocorrenciaManifestoId, listaIds, idOcoCtrc ,descricao, ocorrenciaEm, ocorrenciaAs, usuarioOcorrencia,idUsuarioOcorrencia, observacaoOcorrencia, isResolvido, resolvidoEm, resolvidoAs, usuarioResolucao, idUsuarioResolucao,observacaoResolucao){
    this.id = id;
    this.ocorrenciaManifestoId = ocorrenciaManifestoId;
    this.listaIds = listaIds;
    this.descricao = descricao;
    this.idOcoCtrc = idOcoCtrc;
    this.ocorrenciaEm = ocorrenciaEm;
    this.ocorrenciaAs = ocorrenciaAs;
    this.usuarioOcorrencia = usuarioOcorrencia;
    this.idUsuarioOcorrencia = idUsuarioOcorrencia;
    this.observacaoOcorrencia = observacaoOcorrencia;
    this.isResolvido = isResolvido;
    this.resolvidoEm = resolvidoEm;
    this.resolvidoAs = resolvidoAs;
    this.usuarioResolucao = usuarioResolucao;
    this.idUsuarioResolucao = idUsuarioResolucao;
    this.observacaoResolucao = observacaoResolucao;
}

function removerOcorrencia(idx){
    var existe = false;
    if (confirm("Deseja mesmo apagar a ocorrência ?")){
        Element.remove('trOco_'+idx);
    }
    for (var i = 1; i <= idxOco; i++){
        if($("ocorrenciaId_"+i)!=null){
            existe = true;
        }
    }
    if(!existe){
        $("trOcorrencia").style.display="none";
    }
}

function resolveuOcorrencia(idx){
    if ($('isResolvido_'+idx).checked){
        $('isResolvido_'+idx).value = true;
        $('usuarioResolucao_'+idx).innerHTML = '<%=Apoio.getUsuario(request).getLogin()%>';
        $('idUsuarioResolucao_'+idx).value = '<%=Apoio.getUsuario(request).getIdusuario()%>';
        $('obsResolucao_'+idx).readOnly = false;
        $('resolvidoEm_'+idx).readOnly = false;
        $('resolvidoEm_'+idx).value = '<%=Apoio.getDataAtual()%>';
        $('resolvidoAs_'+idx).readOnly = false;
        $('resolvidoAs_'+idx).value = '<%=new SimpleDateFormat("HH:mm").format(new Date())%>';
    }else{
        $('isResolvido_'+idx).value = false;
        $('usuarioResolucao_'+idx).innerHTML = '';
        $('idUsuarioResolucao_'+idx).value = 0;
        $('obsResolucao_'+idx).readOnly = true;
        $('resolvidoEm_'+idx).readOnly = true;
        $('resolvidoEm_'+idx).value = '';
        $('resolvidoAs_'+idx).readOnly = true;
        $('resolvidoAs_'+idx).value = '';
    }
}

function novaOcorrencia(ctrc, zebra){
    ctrcAux = ctrc;
    zebraAux = zebra;
    post_cad = window.open('./localiza?acao=consultar&idlista=40','Ocorrencia_Ctrc',
    'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
}

function addOcorrencia(ocorrencia){
        
    if($("ocorrenciaId_1")==null){
        $("trOcorrencia").style.display="";
    }
    //criando tr
    var tr_ = Builder.node("tr", {
        id:"trOco_"+idxOco,
        name:"trOco_"+idxOco,
        className:"CelulaZebra"+(idxOco%2==0?1:2)
    });



    // criando td 1
    var td1_ = Builder.node("TD");

    // criando imagem
    var img1_ =  Builder.node("IMG", {src:"img/lixo.png", title:"Apagar ocorrência do CTRC.", className:"imagemLink",                onClick:"removerOcorrencia("+idxOco+");"});
    var inp1_ = Builder.node("INPUT", {type:"hidden", name:"ocorrenciaId_"+idxOco, id:"ocorrenciaId_"+idxOco,
        value:ocorrencia.id});
    var inp54_ = Builder.node("INPUT", {type:"hidden", name:"ocorrenciaIdCtrc_"+idxOco, id:"ocorrenciaIdCtrc_"+idxOco,
        value:ocorrencia.idOcoCtrc});
    var inp55_ = Builder.node("INPUT", {type:"hidden", name:"ocorrenciaManifestoId_"+idxOco, id:"ocorrenciaManifestoId_"+idxOco,
        value:ocorrencia.ocorrenciaManifestoId});
    var inp56_ = Builder.node("INPUT", {type:"hidden", name:"listaIds_"+idxOco, id:"listaIds_"+idxOco,
        value:ocorrencia.listaIds});
    td1_.appendChild(img1_);
    td1_.appendChild(inp1_);
    td1_.appendChild(inp54_);
    td1_.appendChild(inp55_);
    td1_.appendChild(inp56_);
    //criando td 2
    var td2_ = Builder.node("TD");
    var lab1_ = Builder.node("LABEL", {name:"ocorrencia_"+idxOco, id:"ocorrencia_"+idxOco});

    td2_.appendChild(lab1_);

    //criando td 3
    var td3_ = Builder.node("TD");
    var inp3_ ;
    var inp4_ ;
        
    if(ocorrencia.id==0){
            
        inp3_= Builder.node("INPUT", {
            type:"text",
            name:"ocorrenciaEm_"+idxOco,
            id:"ocorrenciaEm_"+idxOco,
            value:ocorrencia.ocorrenciaEm,
            className:"inputtexto",
            size:"10",
            maxLength:"10",
            onBlur:"alertInvalidDate($('ocorrenciaEm_"+idxOco+"'));",
            onKeyDown:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
            onKeyUp:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
            onKeyPress:"fmtDate($('ocorrenciaEm_"+ idxOco+"') , event);"});

        inp4_ = Builder.node("INPUT", {type:"text", name:"ocorrenciaAs_"+idxOco, id:"ocorrenciaAs_"+idxOco,
            value:ocorrencia.ocorrenciaAs, className:"fieldMin", size:"5", maxLength:"5"});

    }else{
        inp3_= Builder.node("INPUT", {
            type:"text",
            name:"ocorrenciaEm_"+idxOco,
            id:"ocorrenciaEm_"+idxOco,
            value:ocorrencia.ocorrenciaEm,
            className:"fieldMin",
            size:"10",
            maxLength:"10",
            readOnly: true,
            onBlur:"alertInvalidDate($('ocorrenciaEm_"+idxOco+"'));",
            onKeyDown:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
            onKeyUp:"fmtDate($('ocorrenciaEm_"+idxOco+"') , event);",
            onKeyPress:"fmtDate($('ocorrenciaEm_"+ idxOco+"') , event);"});

        inp4_ = Builder.node("INPUT", {type:"text", readOnly:true,name:"ocorrenciaAs_"+idxOco, id:"ocorrenciaAs_"+idxOco,
            value:ocorrencia.ocorrenciaAs, className:"fieldMin", size:"5", maxLength:"5"});
    }
    td3_.appendChild(inp3_);
    td3_.appendChild(inp4_);

    //criando td 4
    var td4_ = Builder.node("TD");
    var lab2_ = Builder.node("LABEL", {name:"usuarioOcorrencia_"+idxOco, id:"usuarioOcorrencia_"+idxOco});
    var inp44_ = Builder.node("INPUT", {type:"hidden", name:"idUsuarioOcorrencia_"+idxOco, id:"idUsuarioOcorrencia_"+idxOco,
        value:ocorrencia.idUsuarioOcorrencia});
    td4_.appendChild(inp44_);
    td4_.appendChild(lab2_);
    //criando td 5
    var td5_ = Builder.node("TD");

    var inp5_;
    if(ocorrencia.id==0){
        inp5_= Builder.node("INPUT", {type:"text", name:"obsOcorrencia_"+idxOco, id:"obsOcorrencia_"+idxOco,
            value:ocorrencia.observacaoOcorrencia, className:"fieldMin", size:"28", maxLength:""});
    }else{
        inp5_= Builder.node("INPUT", {type:"text", readOnly:true,name:"obsOcorrencia_"+idxOco, id:"obsOcorrencia_"+idxOco,
            value:ocorrencia.observacaoOcorrencia, className:"fieldMin", size:"28", maxLength:""});
    }
    td5_.appendChild(inp5_);

        
    //criando td 6
    var inp6_= Builder.node("INPUT", {type:"checkbox", name:"isResolvido_"+idxOco, id:"isResolvido_"+idxOco,
        value:ocorrencia.isResolvido,  onClick:"resolveuOcorrencia("+idxOco+");"});
    //criando td 7
    var td7_ = Builder.node("TD");
    var inp7_ ;
    if(ocorrencia.isResolvido){
        inp7_ = Builder.node("INPUT", {
            type:"text", name:"resolvidoEm_"+idxOco, id:"resolvidoEm_"+idxOco,
            value: ocorrencia.resolvidoEm, className:"fieldMin", size:"12", maxLength:"10",
            onBlur:"alertInvalidDate($('resolvidoEm_"+idxOco+"'),true);",
            onKeyDown:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
            onKeyUp:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
            onKeyPress:"fmtDate($('resolvidoEm_"+idxOco+"') , event);"});
    }else{
        inp7_ = Builder.node("INPUT", {
            type:"text", name:"resolvidoEm_"+idxOco, id:"resolvidoEm_"+idxOco,
            value: "", className:"fieldMin", size:"12", maxLength:"10",
            onBlur:"alertInvalidDate($('resolvidoEm_"+idxOco+"'),true);",
            onKeyDown:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
            onKeyUp:"fmtDate($('resolvidoEm_"+idxOco+"') , event);",
            onKeyPress:"fmtDate($('resolvidoEm_"+idxOco+"') , event);"});

    }
        
    var inp8_;
    if(ocorrencia.isResolvido){
        inp8_= Builder.node("INPUT", {type:"text", name:"resolvidoAs_"+idxOco, id:"resolvidoAs_"+idxOco,
            value:ocorrencia.resolvidoAs, className:"fieldMin", size:"6", maxLength:"5"});
    }else{
        inp8_= Builder.node("INPUT", {type:"text", name:"resolvidoAs_"+idxOco, id:"resolvidoAs_"+idxOco,
            value:"", className:"fieldMin", size:"6", maxLength:"5"});
    }
    td7_.appendChild(inp6_);
    td7_.appendChild(inp7_);
    td7_.appendChild(inp8_);

    //criando td 8
    var td8_ = Builder.node("TD");
    var lab3_ = Builder.node("LABEL", {name:"usuarioResolucao_"+idxOco, id:"usuarioResolucao_"+idxOco});
    var inp34_ = Builder.node("INPUT", {type:"hidden", name:"idUsuarioResolucao_"+idxOco, id:"idUsuarioResolucao_"+idxOco,
        value:ocorrencia.idUsuarioResolucao});
    td8_.appendChild(inp34_);
    td8_.appendChild(lab3_);
    //criando td 9
    var td9_ = Builder.node("TD");
    var inp9_;
    if(ocorrencia.isResolvido){
        inp9_= Builder.node("INPUT", {
            type:"text",
            name:"obsResolucao_"+idxOco,
            id:"obsResolucao_"+idxOco,
            value:ocorrencia.observacaoResolucao,
            className:"fieldMin",
            size:"28",
            maxLength:""
        });
	
    }else{
        inp9_= Builder.node("INPUT", {
            type:"text",
            name:"obsResolucao_"+idxOco,
            id:"obsResolucao_"+idxOco,
            value:ocorrencia.observacaoResolucao,
            className:"fieldMin",
            size:"28",
            maxLength:""
        });

    }
    td9_.appendChild(inp9_);

    tr_.appendChild(td1_);
    tr_.appendChild(td2_);
    tr_.appendChild(td3_);
    tr_.appendChild(td4_);
    tr_.appendChild(td5_);
        
    tr_.appendChild(td7_);
    tr_.appendChild(td8_);
        
    tr_.appendChild(td9_);

        
    $('tbOcorrencia').appendChild(tr_);

    //Atribuindo valores nas labels
    $('ocorrencia_'+idxOco).innerHTML = ocorrencia.descricao;
    $('usuarioOcorrencia_'+idxOco).innerHTML = ocorrencia.usuarioOcorrencia;
    $('usuarioResolucao_'+idxOco).innerHTML = ocorrencia.isResolvido?ocorrencia.usuarioResolucao:"";
    if (ocorrencia.isResolvido){
        $('isResolvido_'+idxOco).checked = true;
        $('obsResolucao_'+idxOco).readOnly = false;
        $('resolvidoEm_'+idxOco).readOnly = false;
        $('resolvidoAs_'+idxOco).readOnly = false;
    }else{
        $('isResolvido_'+idxOco).checked = false;
        $('obsResolucao_'+idxOco).readOnly = true;
        $('resolvidoEm_'+idxOco).readOnly = true;
        $('resolvidoAs_'+idxOco).readOnly = true;
    }

    if (ocorrencia.id != '0'){
        $('obsOcorrencia_'+idxOco).readOnly = true;
        $('obsOcorrencia_'+idxOco).style.backgroundColor = '#FFFFF1';
        $('ocorrenciaEm_'+idxOco).readOnly = true;
        $('ocorrenciaEm_'+idxOco).style.backgroundColor = '#FFFFF1';
        $('ocorrenciaAs_'+idxOco).readOnly = true;
        $('ocorrenciaAs_'+idxOco).style.backgroundColor = '#FFFFF1';
    }
    $("qtdOco").value = idxOco;
    idxOco++;


}

function carregarOcorrencias(zebra){
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport){
        var textoresposta = transport.responseText;
        espereEnviar("",false);
        //se deu algum erro na requisicao...
        if (textoresposta == "-1"){
            alert('Houve algum problema ao requistar as ocorrências, favor informar manualmente.');
            return false;
        }else{
                
            for (i = 0; i <= textoresposta.split('!!000!!').length - 1; ++i){

                ocor =  textoresposta.split('!!000!!')[i];
                addOcorrencia(ocor.split('!!999!!')[12], ocor.split('!!999!!')[0], ocor.split('!!999!!')[1],
                ocor.split('!!999!!')[2], ocor.split('!!999!!')[3], ocor.split('!!999!!')[4],
                ocor.split('!!999!!')[5],ocor.split('!!999!!')[6],
                (ocor.split('!!999!!')[7]=='f'?false:true), ocor.split('!!999!!')[8],
                ocor.split('!!999!!')[9], ocor.split('!!999!!')[10], ocor.split('!!999!!')[11]);
            }
        }
    }//funcao e()
    espereEnviar("",true);
    $('mostrar').style.display = "none";
    zebraAux = zebra;
    var id = $('id').value;
    tryRequestToServer(function(){
        new Ajax.Request("./cadmanifesto?acao=carregarOcorrencia&manifestoId="+id ,
        {method:'post', onSuccess: e, onError: e});
    });
}

//--------------------------- Ocorrência -------------------------------- fim
// LOCALIZAR  ------------------------ inicio
function localizacid_origem(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','origem',
    'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
}

function localizacid_destino(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_DESTINO%>','destino',
    'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
}

function localizacompanhia(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COMPANHIA_AEREA%>','companhia',
    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
}

function localizaredespachante(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.REDESPACHANTE%>','redespachante',
    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
}

function localizaCompanhiaAerea(){
    post_cad = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.COMPANHIA_AEREA%>','companhia',
    'top=80,left=150,height=400,width=800,resizable=yes,status=1,scrollbars=1');
}

function excluirAWB(){
    if (confirm("Deseja mesmo excluir este AWB?")){
        location.replace("./consulta_awb.jsp?acao=excluir&id="+$("id").value);
    }
}

function aoClicarNoLocaliza(idjanela){
    if (idjanela == "motorista"){
        if ($("tipo").value == "c"){
            $("motor_liberacao").disabled = false;
        }else{
            $("motor_liberacao").disabled = true;
        }
    }
    function indiceJanela(initPos, finalPos) { return idjanela.substring(initPos, finalPos); }
    //localizando ajudante
    if (idjanela.indexOf("motorista") > -1){
        if ($("bloqueado").value == 't'){
            alert('Esse motorista está bloqueado. Motivo: ' + $("motivobloqueio").value);
            $("motor_nome").value = '';
            $("motor_vencimentocnh").value = '';
            $("motor_liberacao").value = '';
            $("idmotorista").value = '';
        }
    }else if (idjanela.indexOf("Tripulante") > -1){
        if ($("bloqueado").value == 't'){
            alert('Esse tripulante está bloqueado. Motivo: ' + $("motivobloqueio").value);
            $("trip_nome").value = '';
            //$("trip_vencimentocnh").value = '';
            $("idtrip").value = '';
            $("trip_funcao").value = '';
        }else{
            var id = $("idtrip").value;
            var descricao = $("trip_nome").value;
            var funcao = $("trip_funcao").value;
            addTripulante(id, descricao, funcao);
        }
    }else if (idjanela == "Observacao"){
        var obs = "" + $("obs_desc").value;
        obs = replaceAll(obs, "<BR>","\n ");
        obs = replaceAll(obs, "<br>","\n ");
        obs = replaceAll(obs, "</br>","\n ");;
        obs = replaceAll(obs, "</BR>","\n ");
        $("obs").value = obs;
    }


    if(idjanela == "Ocorrencia_Ctrc"){
        var ocorrencia = new Ocorrencia(0,0,'',//
        $("ocorrencia_id").value, //2
        $("ocorrencia").value+" - "+$("descricao_ocorrencia").value,//3
        '<%=Apoio.getDataAtual()%>',//4
        '<%=new SimpleDateFormat("HH:mm").format(new Date())%>',//5
        '<%=Apoio.getUsuario(request).getLogin()%>',//6
        '<%=Apoio.getUsuario(request).getIdusuario()%>',//7
        '',//8
        false,//9
        '',//10
        '',//11
        '',//12
        0,//13
        '');//14

        addOcorrencia(ocorrencia);
    }

}

function limpaCompanhiaAerea(){
    $("idcompanhia").value = "0";
    $("companhia_aerea").value = "";
}
// LOCALIZAR  ------------------------ FIM

</script>
<%@page import="com.sagat.bean.NotaFiscal"%>
<%@page import="java.util.List"%>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language"  content="pt-br">
        <META HTTP-EQUIV="Page-Enter" CONTENT = "RevealTrans (Duration=1, Transition=12)">
        <script language="JavaScript" src="script/notaFiscal-util.js" type="text/javascript"></script>
        <script language="JavaScript" src="script/servicos-util.js" type="text/javascript"></script>

        <title>WebTrans - AWB</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="aoCarregar();applyFormatter();" >
        <form method="post"  id="formulario" target="pop">
            <div align="center"><img src="img/banner.gif"> <br>
                <!-- CAMPOS OCULTOS -->
                <input type="hidden" name="tipo_movimento" id="tipo_movimento" value="a" >
                <input type="hidden" name="obs_desc" id="obs_desc" >
                <input type="hidden" name="acao" id="acao" value="<%=acao%>">
                <input type="hidden" name="id" id="id"  value="<%=(iscarregaawb ? awb.getId() : 0)%>">
                <input type="hidden" id="despesaId" name="despesaId" value="<%=(iscarregaawb ? awb.getDespesa().getIdmovimento() : 0)%>">
                <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="<%=(iscarregaawb? awb.getCidadeOrigem().getIdcidade() : Apoio.getUsuario(request).getFilial().getCidade().getIdcidade())%>">
                <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="<%=(iscarregaawb? awb.getCidadeDestino().getIdcidade() : Apoio.getUsuario(request).getFilial().getCidade().getIdcidade())%>">
                <input type="hidden" name="idcompanhia" id="idcompanhia" value="<%=(iscarregaawb? awb.getCompanhiaAerea().getIdfornecedor() : 0)%>">
                <input type="hidden" name="tipo" id="tipo" value="">
                <input type="hidden" name="bloqueado" id="bloqueado" value="">
                <input type="hidden" name="motivobloqueio" id="motivobloqueio" value="">
                <!-- FIM -->

                <input type="hidden" name="idtrip" id="idtrip" value="0">
                <input type="hidden" name="trip_nome" id="trip_nome" value="">
                <input type="hidden" name="trip_nome" id="trip_nome" value="">
                <input type="hidden" name="trip_funcao" id="trip_funcao" value="">
                <!-- ocorrencia-->
                <input type="hidden" id="ocorrencia" name="ocorrencia" value="">
                <input type="hidden" id="ocorrencia_id" name="ocorrencia_id" value="">
                <input type="hidden" id="descricao_ocorrencia" name="descricao_ocorrencia" value="">
            </div>
            <table width="950" align="center" class="bordaFina">
                <tr >
                    <td width="570"><div align="left"><b>AWB</b></div></td>
                    <% if (!baixado && (acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) //se o paramentro vier com valor entao nao pode excluir
                                {%>
                                <td width="59"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" title="Excluir este AWB" onClick="javascript:excluirAWB()"></td>
                        <%}%>
                    <td width="55" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" title="Voltar a tela de consulta" onClick="javascript:tryRequestToServer(function(){voltar()});"></td>
                </tr>
            </table>
            <br>
            <table width="950" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td>
                        <table class="bordaFina" width="100%">
                            <tr>
                                <td colspan="8" class="tabela"> <div align="center">Dados Principais</div></td>
                            </tr>
                            <tr>
                                <td width="15%"   class="TextoCampos">Movimento:</td>
                                <td width="8%"   class="CelulaZebra2"><span class="CelulaZebra2">
                                        <input name="nAWB" type="text" id="nAWB" class="inputReadOnly" value="<%=(iscarregaawb ? awb.getNumero() : "")%>" size="6" maxlength="6" <%=(iscarregaawb ? "" : "readonly")%>>
                                    </span>
                                </td>
                                <td width="40%"   class="TextoCampos"><div align="left">
                                    <%if(iscarregaawb && awb.getDespesa().getIdmovimento() != 0){%>
                                        Despesa: 
                                        <b><%=awb.getDespesa().getIdmovimento()%></b>
                                    <%}%>
                                    </div></td>

                                <td width="12%" class="TextoCampos">Data Emiss&atilde;o: </td>
                                <td width="25%" class="CelulaZebra2">
                                    <input name="emissaoEm" type="text" id="emissaoEm" value="<%=(iscarregaawb ? formato.format(awb.getEmissaoEm()) : Apoio.getDataAtual())%>" size="9" maxlength="10" class="fieldDate">
                                    &agrave;s
                                    <input name="emissaoAs" type="text" onkeyup="mascaraHora(this)" id="hrEmissao" value="<%=(iscarregaawb ? awb.getEmissaoAs() : hora)%>" size="4" maxlength="8" class="inputtexto">
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" rowspan="5" class="TextoCampos">*Companhia Aérea:</td>
                                <td width="48%" colspan="2" rowspan="5" class="CelulaZebra2" ><input name="companhia_aerea" type="text" id="companhia_aerea" class="inputReadOnly" value="<%=(iscarregaawb ? awb.getCompanhiaAerea().getRazaosocial():"")%>" size="50" readonly="true">
                                    <strong>
                                        <input name="localiza_companhia" type="button" class="botoes" id="localiza_companhia" value="..." onClick="javascript:localizaCompanhiaAerea();"></strong>
                                </td>
                                <td width="12%" class="CelulaZebra2"><div align="right">N&uacute;mero do AWB:</div></td>
                                <td width="25%" class="CelulaZebra2"><input type="text" name="numeroAWB" id="numeroAWB" maxlength="10" size="10" class="inputTexto" value="<%=(iscarregaawb ? awb.getNumeroAWB():"")%>">
                                </td>
                            </tr>
                            <tr>
                                <td width="12%" class="CelulaZebra2"><div align="right">*N&uacute;mero do Vôo:</div></td>
                                <td width="25%" class="CelulaZebra2"><input type="text" name="numeroVoo" id="numeroVoo" maxlength="10" size="10" class="inputTexto" value="<%=(iscarregaawb ? awb.getNumeroVoo():"")%>">
                            </tr>
                            <tr>
                                <td width="12%" class="CelulaZebra2"><div align="right">*Valor do Frete:</div></td>
                                <td width="25%" class="CelulaZebra2"><input type="text" name="valorFrete" id="valorFrete" maxlength="10" size="10" align="right"  class="inputTexto" onchange="seNaoFloatReset(this,'0.00');" value="<%=iscarregaawb ? vlrformat.format(awb.getValorFrete()):"0.00"%>"></td>
                            </tr>
                            <tr>
                                <td width="12%" class="CelulaZebra2"><div align="right">Previsão de Embarque:</div></td>
                                <td width="25%" class="CelulaZebra2">
                                    <input name="previsaoEmbarqueEm" type="text" id="previsaoEmbarqueEm" value="<%=(iscarregaawb && awb.getPrevisaoEmbarqueEm() != null ? formato.format(awb.getPrevisaoEmbarqueEm()) : "")%>" size="9" maxlength="10" class="fieldDate">
                                    &agrave;s
                                    <input name="previsaoEmbarqueAs" type="text" onkeyup="mascaraHora(this)" id="previsaoEmbarqueAs" value="<%=(iscarregaawb && awb.getPrevisaoEmbarqueAs() != null ? awb.getPrevisaoEmbarqueAs() : "")%>" size="4" maxlength="8" class="inputtexto">
                                </td>
                            </tr>
                            <tr>
                                <td width="12%" class="CelulaZebra2"><div align="right">Previsão de Chegada:</div></td>
                                <td width="25%" class="CelulaZebra2">
                                    &agrave;s
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table class="bordaFina" width="100%">
                            <tr class="tabela" >
                                <td colspan="8"> <div align="center"><label id="tit_a" name="tit_a">CTRCs deste AWB</label></div></td>
                            </tr>
                            <tr >
                                <td colspan="8">
                                    <input type="hidden" id="qtdCtrc" name="qtdCtrc">
                                    <table width="100%" class="bordaFina">
                                        <tbody id="tbCTRC" name="tbCTRC" onLoad="applyFormatter();">
                                            <tr class="Celula">
                                                <td width="8%" class="Celula"><div align="center">Emiss&atilde;o</div></td>
                                                <td width="6%" class="Celula"><div align="center">CT</div></td>
                                                <td width="24%" class="Celula"><div align="center">Emitente</div></td>
                                                <td width="24%" class="Celula"><div align="center">Destinat&aacute;rio</div></td>
                                                <td width="6%" class="Celula"><div align="center">QTD</div></td>
                                                <td width="8%" class="Celula"><div align="center">Peso</div></td>
                                                <td width="8%" class="Celula"><div align="center">Peso Real</div></td>
                                                <td width="8%" class="Celula"><div align="center">VL NFs</div></td>
                                                <td width="8%" class="Celula"><div align="center">VL Frete</div></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr >
                            <tr>
                                <td width="40%" class="TextoCampos">
                                    <div align="left" >
                                        <input name="selecionarctrc" type="button" class="botoes" id="selecionarctrc" value="Selecionar CTRC's" onClick="javascript:tryRequestToServer(function(){selecionar_rc(<%=linha%>,'<%=acao%>');});">
                                        <div style=display:none>
                                        <input name="mostratudo" type="checkbox" id="mostratudo" value="checkbox">
                                        <label id="lbmostratudo" name="lbmostratudo">Mostrar CTRCs j&aacute; manifestados</label>
                                        </div>
                                    </div>
                                </td>
                                <td width="12%" class="TextoCampos"><strong>Totais:</strong></td>
                                <td width="10%" class="CelulaZebra2"><div align="right"><strong><label id="totCtrc" name="totCtrc"> CT(s)</label>
                                        </strong></div></td>
                                <td width="6%" class="CelulaZebra2"><div align="right"><strong><label id="totQtd" name="totQtd">0.00</label></strong></div></td>
                                <td width="8%"class="CelulaZebra2"><div align="right"><strong><label id="totPeso" name="totPeso">0.00</label></strong></div></td>
                                <td width="8%"class="CelulaZebra2"><div align="right"><strong><label id="totPesoReal" name="totPesoReal">0.00</label></strong></div></td>
                                <td width="8%"class="CelulaZebra2"><div align="right"><strong><label id="totNotas" name="totalNotas">0.00</label></strong></div></td>
                                <td width="8%" class="CelulaZebra2"><div align="right"><strong><label id="totFrete" name="totFrete">0.00</label></strong></div></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <table class="bordaFina" width="100%">
                            <tr class="Celula">
                                <td colspan="4" width="50%"><div align="center">Cidade de Origem</div></td>
                                <td colspan="4" width="50%"><div align="center">Cidade de Destino</div></td>
                            </tr>
                            <tr class="CelulaZebra2">
                                <td width="49" height="22" class="TextoCampos">Cidade:</td>
                                <td width="248" class="CelulaZebra2"> <strong>
                                        <input name="cid_origem" type="text" id="cid_origem" class="inputReadOnly" value="<%=(iscarregaawb ? awb.getCidadeOrigem().getDescricaoCidade() : Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade())%>" size="30" readonly="true">
                                        <input name="localiza_cid_origem" type="button" class="botoes" id="localiza_cid_origem" value="..." onClick="javascript:localizacid_origem();">
                                    </strong> </td>
                                <td width="28" class="TextoCampos">UF:</td>
                                <td width="63" class="CelulaZebra2"><input name="uf_origem" type="text" id="uf_origem" class="inputReadOnly" value="<%=(iscarregaawb ? awb.getCidadeOrigem().getUf() : Apoio.getUsuario(request).getFilial().getCidade().getUf())%>" size="2" readonly></td>
                                <td width="49" height="22" class="TextoCampos">Cidade:</td>
                                <td width="245" class="CelulaZebra2"> <strong>
                                        <input name="cid_destino" type="text" id="cid_destino" class="inputReadOnly" value="<%=(iscarregaawb ? awb.getCidadeDestino().getDescricaoCidade() : Apoio.getUsuario(request).getFilial().getCidade().getDescricaoCidade())%>" size="30" readonly="true">
                                        <input name="localiza_cid_destino" type="button" class="botoes" id="localiza_cid_destino" value="..." onClick="javascript:localizacid_destino();">
                                    </strong> </td>
                                <td width="30" class="TextoCampos">UF:</td>
                                <td width="66" class="CelulaZebra2"><input name="uf_destino" type="text" id="uf_destino" class="inputReadOnly" value="<%=(iscarregaawb ? awb.getCidadeDestino().getUf() : Apoio.getUsuario(request).getFilial().getCidade().getUf())%>" size="2" readonly="true"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%if(iscarregaawb){%>
                <tr class="tabela">
                    <td colspan="6" align="center">Auditoria</td>
                </tr>
                <tr>
                    <td colspan="6" >
                        <table width="100%" border="0" class="bordaFina">
                            <tr>
                                <td width="10%" class="TextoCampos">Incluso:</td>
                                <td width="40%" class="CelulaZebra2">Em:<%=fmt.format(awb.getEmissaoEm())%><br>
                                    Por: <%=awb.getCriadoPor().getNome()%> </td>
                                <td width="10%" class="TextoCampos">Alterado:</td>
                                <td width="40%" class="CelulaZebra2">Em:<%=(awb.getAtualizadoEm() != null ? fmt.format(awb.getAtualizadoEm()) : "")%><br>
                                    Por:<%=awb.getAlteradoPor().getNome()%> </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%}%>
                <tr class="CelulaZebra2">
                    <td height="24" colspan="6">
                        <table width="950" border="0" cellspacing="1">
                            
                            <tr class="CelulaZebra2">
                                <td width="100%" height="22">
                                    <div align="center">
                                        <%if (!iscarregaawb || !baixado) {
                                                        if (nivelUser >= 2 && (awb == null || awb.getDespesa().getIdmovimento()==0)) {%>
                                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>','<%=linha%>',<%=peso%>);});">
                                        <%}}else{%>
                                        <b>Pagamento já efetuado, alteração não permitida.</b>
                                        <%}%>
                                    </div>
                                    <div align="center"></div>
                                    <div align="left"> </div></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <br>
        </form>
    </body></html>
