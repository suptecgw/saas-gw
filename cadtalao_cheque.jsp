<%@page import="java.util.ArrayList"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.logging.SimpleFormatter"%>
<%@page import="filial.BeanFilial"%>
<%@page import="mov_banco.conta.BeanConsultaConta"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.Iterator"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="mov_banco.talaocheque.*,
   	       java.sql.ResultSet,
               nucleo.BeanConfiguracao,
                        java.util.Date,
         nucleo.Apoio" errorPage="" %>

<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/talaoCheque.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>

<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
            // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
            BeanUsuario usu = Apoio.getUsuario(request);
            BeanConfiguracao cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            //Carregando as configurações
            cfg.CarregaConfig();
            SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
            
            int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadtalaocheque") : 0);
            int nivelUserFilial = (Apoio.getUsuario(request) != null ? Apoio.getUsuario(request).getAcesso("landespfl") : 0);
            int nivelUserToFilial = (nivelUser > 0 ? Apoio.getUsuario(request).getAcesso("lanconhfl") : 0);
            
            boolean limitarUsuarioVisualizarConta = Apoio.getUsuario(request).isLimitarUsuarioVisualizarConta();
            int idUsuario = Apoio.getUsuario(request).getIdusuario();
            
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //testando se a sessao é válida e se o usuário tem acesso
            if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA
            SimpleDateFormat fmtHora = new SimpleDateFormat("HH:mm");
%>

<%

            String acao = (request.getParameter("acao") == null ? "iniciar" : request.getParameter("acao"));
            boolean carregaTabCheque = false;
            CadTalaoCheque cadTC = new CadTalaoCheque();
            TalaoCheque tlCheque = null;
            ResultSet rs = null;
            Collection<TalaoCheque> lista = new ArrayList<TalaoCheque>();
            
            if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {
                //instanciando o bean de cadastro
                tlCheque = new TalaoCheque();
                cadTC.setConexao(Apoio.getUsuario(request).getConexao());
                cadTC.setExecutor(Apoio.getUsuario(request));
            }

            //executando a acao desejada
            if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
                int id = Integer.parseInt(request.getParameter("id"));
                tlCheque.setId(id);
                cadTC.setTalaoCheque(tlCheque);
                //carregando completo
                cadTC.LoadAllPropertys();
                tlCheque = cadTC.getTalaoCheque();
            } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
                //populando o JavaBean
                boolean erro = false;
                int max = Integer.parseInt(request.getParameter("maxTalao"));
                int maxTpVei;

                for(int i = 1;i <=max; i++){
                    if(request.getParameter("id_"+i) != null){
                        tlCheque = new TalaoCheque();
                        tlCheque.setId(Integer.parseInt(request.getParameter("id_"+i)));
                        tlCheque.setNumeroInicial(request.getParameter("numeroInicial_"+i));
                        tlCheque.setNumeroFinal(request.getParameter("numeroFinal_"+i));
                        tlCheque.setSetor(request.getParameter("setor_"+i));
                        tlCheque.getConta().setIdConta(Integer.parseInt(request.getParameter("conta_"+i)));
                        tlCheque.getFilial().setIdfilial(Integer.parseInt(request.getParameter("filial_"+i)));
                        tlCheque.getCriadoPor().setIdusuario(usu.getIdusuario());
                        tlCheque.getAlteradoPor().setIdusuario(usu.getIdusuario());
                        tlCheque.setLiberado((request.getParameter("liberado_"+i)==null?false:true));
                        if(tlCheque.isLiberado()){
                            tlCheque.setDtLiberacao(Apoio.paraDate(request.getParameter("dataLiberacao_"+i)));
                            tlCheque.setHoraLiberacao(request.getParameter("horaLiberacao_"+i));
                            tlCheque.setEntreguePara(request.getParameter("entreguePara_"+i));
                        }
                        cadTC.setTalaoCheque(tlCheque);
                        cadTC.getListTalaoCheque().add(tlCheque);
                    }
                }
                erro = !((acao.equals("incluir") && nivelUser >= 3)? cadTC.Inclui() : cadTC.Atualiza());
                

//EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type="text/javascript"><%
      if (erro) {
          acao = (acao.equals("atualizar") ? "editar" : "iniciar");
      
        String er = cadTC.getErros().replaceAll("\r", "");
          
    %>
        alert("<%=er%>");
        
    <%} else {%>
        window.opener.document.location.replace("./consulta_talao_cheque.jsp?acao=iniciar");
    <%}%>
        
        window.close();
        
</script>

<%}

            //variavel usada para saber se o usuario esta editando
            carregaTabCheque= (cadTC != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>
<script language="javascript" type="text/javascript">
    
    //-------------  Tipo Veiculo Km ------------ Inicio
    var countTpVeiKm = 0;
    function TalaoCheque(id, idConta, numeroInicial, numeroFinal, idFilial, setor, isLiberado, dataLiberacao, horaLiberacao, entreguePara){
    //validação
    this.id=(id==null || id==undefined?"0":id);
    this.idConta=(idConta==null || idConta==undefined? '<%=cfg.getConta_padrao_id().getIdConta()%>':idConta);
    this.idFilial=(idFilial==null || idFilial==undefined?'<%=Apoio.getUsuario(request).getFilial().getIdfilial()%>': idFilial);
    this.numeroInicial=(numeroInicial==null || numeroInicial==undefined?"": numeroInicial);
    this.numeroFinal=(numeroFinal==null || numeroFinal==undefined?"": numeroFinal);
    this.setor=(setor==null || setor==undefined?"": setor);
    this.entreguePara=(entreguePara==null || entreguePara==undefined?"": entreguePara);
    this.isLiberado=(isLiberado==null || isLiberado==undefined? false: isLiberado);
    this.dataLiberacao=(dataLiberacao==null || dataLiberacao==undefined? "": dataLiberacao);
    this.horaLiberacao=(horaLiberacao==null || horaLiberacao==undefined? "": horaLiberacao);
    

}
    
    //-------------  Tipo Veiculo Km ------------ Fim
    // @@@@@@@@@ TALAO CHEQUE @@@@@@@@@@@ INICIO
    var countTalao = 0;
    var countConta = 0;
    var countFilial = 0;
    var listaConta = new Array();
    var listaFilial = new Array();
    function Lista(id,descricao){
            this.id = id ;        
            this.descricao = descricao;
        }
      <%
      //Carregando todas as contas cadastradas
      BeanConsultaConta conta = new BeanConsultaConta();
      conta.setConexao(Apoio.getUsuario(request).getConexao());
      conta.mostraContas((nivelUserFilial>=3?0:Apoio.getUsuario(request).getFilial().getIdfilial()),false, limitarUsuarioVisualizarConta, idUsuario);
      ResultSet rsconta = conta.getResultado();
      while (rsconta.next()){%>
	listaConta[countConta]= new Lista('<%=rsconta.getString("idconta")%>', '<%=rsconta.getString("banco")%>  <%=rsconta.getString("numero")%> - <%=rsconta.getString("digito_conta")%>') ;
        countConta++;
      <%}%>

      <%BeanFilial fl = new BeanFilial();
        ResultSet rsFl = fl.all(Apoio.getUsuario(request).getConexao());
        while (rsFl.next()){%>
	listaFilial[countFilial]= new Lista('<%=rsFl.getString("idfilial")%>', '<%=rsFl.getString("abreviatura")%>');
        countFilial++;
      <%}%>
        

    function addTalaoCheque(talaoCheque, iscarrega){
        countTalao++;
        iscarrega =(iscarrega==null || iscarrega==undefined?false:iscarrega);
        
        if(talaoCheque == null || talaoCheque == undefined){
            talaoCheque = new TalaoCheque();
        }
        if(!iscarrega && $("id_"+(countTalao - 1)) != null){
            var conuntAnt = countTalao - 1;
            talaoCheque.idConta = $("conta_"+conuntAnt).value;
            talaoCheque.idFilial = $("filial_"+conuntAnt).value;
            talaoCheque.setor = $("setor_"+conuntAnt).value;
        }

        
        //campos
        var hid1_ = Builder.node("INPUT",{type:"hidden",id:"id_"+countTalao, name:"id_"+countTalao, value: talaoCheque.id});
        var hid2_ = Builder.node("INPUT",{type:"hidden",id:"idFilial"+countTalao, name:"idFilial_"+countTalao, value: talaoCheque.idFilial});
        var inp1_ = Builder.node("INPUT",{type:"text",id:"numeroInicial_"+countTalao, name:"numeroInicial_"+countTalao, size:"10", maxLength:"20", value: talaoCheque.numeroInicial, className:"inputtexto"});
        var inp2_ = Builder.node("INPUT",{type:"text",id:"numeroFinal_"+countTalao, name:"numeroFinal_"+countTalao, size:"10", maxLength:"20", value: talaoCheque.numeroFinal, className:"inputtexto"});
        var inp3_ = Builder.node("INPUT",{type:"checkbox",id:"liberado_"+countTalao, name:"liberado_"+countTalao, size:"10", maxLength:"20", className:"inputtexto", onClick:"isLiberado(this);"});
        var inp4_ = Builder.node("INPUT",{type:"text",id:"dataLiberacao_"+countTalao, name:"dataLiberacao_"+countTalao, size:"10", maxLength:"20", value: talaoCheque.dataLiberacao, size:"9", maxLength:"10", className:"inputReadOnly", readOnly:true, onblur:"alertInvalidDate(this)", onKeyDown:"fmtDate(this, event)", onkeyUp:"fmtDate(this, event)", onKeyPress:"fmtDate(this, event)"});
        var inp5_ = Builder.node("INPUT",{type:"text",id:"horaLiberacao_"+countTalao, name:"horaLiberacao_"+countTalao, size:"5", maxLength:"5", value: talaoCheque.horaLiberacao, className:"inputReadOnly", readOnly:true, onkeyup:"mascaraHora(this)"});
        var inp6_ = Builder.node("INPUT",{type:"text",id:"entreguePara_"+countTalao, name:"entreguePara_"+countTalao, size:"20", maxLength:"20", value: talaoCheque.entreguePara, className:"inputReadOnly", readOnly:true});
        var img3_ = Builder.node("IMG",{src:"img/lixo.png", onClick:"removerTalaoCheque("+countTalao+");"});
        var img4_ = Builder.node("IMG",{src:"img/plus.jpg", id:"img_"+countTalao});
        var lab1_ = Builder.node("LABEL","Dias ");
        var slc1_ = Builder.node("SELECT",{id:"setor_"+countTalao, name:"setor_"+countTalao, className:"inputtexto"},[
            Builder.node('OPTION', {value:'a'}, 'Ambos'),
            Builder.node('OPTION', {value:'f'}, 'Financeiro (Contas a pagar)'),
            Builder.node('OPTION', {value:'o'}, 'Operacional (Contrato de Frete)')
        ]);
        //criando o select que terá as contas
	var slc2_ = Builder.node("SELECT",{id:"conta_"+countTalao, name:"conta_"+countTalao, className:"inputtexto"});
	//colocando os options
	var _opt1 = null;
        for(var i = 0; i < listaConta.length; i++){
            _opt1 = Builder.node("OPTION", {
                value: listaConta[i].id
                
            },listaConta[i].descricao);
            slc2_.appendChild(_opt1);
        }
	//criando o select que terá as filiais
	var slc3_ = Builder.node("SELECT",{id:"filial_"+countTalao, name:"filial_"+countTalao, className:"inputtexto"});
	//colocando os options
	var _opt2 = null;
        for(var i = 0; i < listaFilial.length; i++){
            _opt2 = Builder.node("option", {value: listaFilial[i].id}, listaFilial[i].descricao);
            slc3_.appendChild(_opt2);
        }

        
        var _img1 = Builder.node("IMG",{src:"img/borracha.gif", onClick:"javascript:$('ufOrigem_"+countTalao+"').value='';$('cidadeOrigem_"+countTalao+"').value='';$('cidadeOrigemId_"+countTalao+"').value=0;"});
        //tds
        
        
        var td0_ = Builder.node("TD",{width:"4%", align:"center"});
        var td1_ = Builder.node("TD",{width:"10%"});
        var td2_ = Builder.node("TD",{width:"10%"});
        var td3_ = Builder.node("TD",{width:"10%"});
        var td4_ = Builder.node("TD",{width:"11%"});
        var td5_ = Builder.node("TD",{width:"12%"});
        var td6_ = Builder.node("TD",{width:"8%", align:"center"});
        var td7_ = Builder.node("TD",{width:"10%"});
        var td8_ = Builder.node("TD",{width:"5%"});
        var td9_ = Builder.node("TD",{width:"18%"});
        


        //inserindo os campos nas tds
        if(!iscarrega){
            td0_.appendChild(img3_);
        }
        td1_.appendChild(hid1_);
        td1_.appendChild(hid2_);
        td1_.appendChild(slc2_);
        td2_.appendChild(inp1_);
        td3_.appendChild(inp2_);
        td4_.appendChild(slc3_);
        td5_.appendChild(slc1_);
        td6_.appendChild(inp3_);
        td7_.appendChild(inp4_);
        td8_.appendChild(inp5_);
        td9_.appendChild(inp6_);
        
        //trs
        var classe = ((countTalao % 2) != 0 ? 'CelulaZebra2' : 'CelulaZebra1');
        var classeOposta = ((countTalao % 2) == 0 ? 'CelulaZebra2' : 'CelulaZebra1');
        var tr1_ = Builder.node("TR",{className:classe, id:"trTalao_"+countTalao});
        var tr2_ = Builder.node("TR",{id:"trTalao2_"+countTalao});
        

        //inserindo as tds nas determinadas trs
        tr1_.appendChild(td0_);
        tr1_.appendChild(td1_);
        tr1_.appendChild(td2_);
        tr1_.appendChild(td3_);
        tr1_.appendChild(td4_);
        tr1_.appendChild(td5_);
        tr1_.appendChild(td6_);
        tr1_.appendChild(td7_);
        tr1_.appendChild(td8_);
        tr1_.appendChild(td9_);

        //inserindo outra tabela que possuirá a tabela com os tipos de veiculos

        $("tabTalao").appendChild(tr1_);
        

        //tr2_.style.display = "none";
        slc1_.value= talaoCheque.setor;
        slc2_.value= talaoCheque.idConta;
        slc3_.value= talaoCheque.idFilial;
        inp3_.checked= talaoCheque.isLiberado;
        slc2_.style.width="115px";
        slc1_.style.width="100px";
        isLiberado(inp3_);
        $("maxTalao").value = countTalao;
        
    }
    function isLiberado(elemento){
        var linha = elemento.id.split("_")[1];
        var checado = elemento.checked;

        $("entreguePara_"+linha).readOnly = !checado;
        $("horaLiberacao_"+linha).readOnly = !checado;
        $("dataLiberacao_"+linha).readOnly = !checado;
        if(checado){
            $("entreguePara_"+linha).className = "inputtexto";
            $("horaLiberacao_"+linha).className = "inputtexto";
            $("dataLiberacao_"+linha).className = "fieldDate";
        }else{
            $("entreguePara_"+linha).className = "inputReadOnly";
            $("horaLiberacao_"+linha).className = "inputReadOnly";
            $("dataLiberacao_"+linha).className = "inputReadOnly";
        }
        
    }
    function removerTalaoCheque(idx){
        if (confirm("Deseja mesmo apagar o talão do cheque?")){
            Element.remove('trTalao_'+idx);
        }
    }

    // @@@@@@@@@ Talao  @@@@@@@@@@@ FIM

    function aoClicarNoLocaliza(idjanela){
        
    }

    function voltar(){
        location.replace("./consulta_talao_cheque.jsp?acao=iniciar");
    }

    function salva(acao){
        var deucerto = true;
        for(var i = 0; i<=countTalao; i++){
            if($("numeroInicial_"+i)!=null){
                if($("numeroInicial_"+i).value.trim()==""){
                    $("numeroInicial_"+i).style.background ="#FFE8E8";
                    deucerto = false;
                }
                if($("numeroFinal_"+i).value.trim()==""){
                    $("numeroFinal_"+i).style.background ="#FFE8E8";
                    deucerto = false;
                }
                if($("liberado_"+i).checked){
                    if($("dataLiberacao_"+i).value.trim()==""){
                        $("dataLiberacao_"+i).style.background ="#FFE8E8";
                        deucerto = false;
                    }
                    if($("horaLiberacao_"+i).value.trim()==""){
                        $("horaLiberacao_"+i).style.background ="#FFE8E8";
                        deucerto = false;
                    }
                    if($("entreguePara_"+i).value.trim()==""){
                        $("entreguePara_"+i).style.background ="#FFE8E8";
                        deucerto = false;
                    }
                }
            }
        }
        if(!deucerto){
            alert("Informe os campos corretamente!");
            return false;
        }
        
        $("formulario").action = "./cadtalao_cheque.jsp?acao="+ acao;
        window.open('about:blank', 'pop', 'width=210, height=100');
        $("formulario").submit();
    }

    function excluir(id){
       if (confirm("Deseja mesmo excluir este talão de cheque?")){
	       location.replace("consulta_talao_cheque.jsp?acao=excluir&id="+id);
	   }
  }

    function setDefault(){
        var talao = new TalaoCheque();
    
        <%if(acao.equals("editar")){%>
                $("trNovo").style.display="none";
                
                talao.id = '<%=tlCheque.getId()%>';
                talao.idConta = '<%=tlCheque.getConta().getIdConta()%>';
                talao.idFilial= '<%=tlCheque.getFilial().getIdfilial()%>';
                talao.numeroInicial= '<%=tlCheque.getNumeroInicial()%>';
                talao.numeroFinal= '<%=tlCheque.getNumeroFinal()%>';
                talao.setor= '<%=tlCheque.getSetor()%>';
                talao.isLiberado= <%=tlCheque.isLiberado()%>;
                if(talao.isLiberado){
                    talao.dataLiberacao = '<%=Apoio.fmt(tlCheque.getDtLiberacao())%>';
                    talao.horaLiberacao = '<%=tlCheque.getHoraLiberacao()%>';
                    talao.entreguePara = '<%=tlCheque.getEntreguePara()%>';
                }
                addTalaoCheque(talao, true);

        <%}else{%>
            addTalaoCheque();
        <%}%>
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

        <title>WebTrans - Cadastro de Talões de Cheque</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>

    <body onLoad="setDefault();">
        <form method="post"  id="formulario" target="pop">
            <img src="img/banner.gif" >
            <input type="hidden" name="linhaRota" id="linhaRota" value="0">
            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0">
            <input type="hidden" name="idcidadedestino" id="idcidadedestino" value="0">
            <input type="hidden" name="cid_origem" id="cid_origem" value="">
            <input type="hidden" name="uf_origem" id="uf_origem" value="">
            <input type="hidden" name="cid_destino" id="cid_destino" value="">
            <input type="hidden" name="uf_destino" id="uf_destino" value="">
        <br>
        <table width="90%" align="center" class="bordaFina" >
            <tr >
                <td width="80%"><div align="left"><b>Cadastro de Talões de Cheque</b></div></td>
                <%  //se o paramentro vier com valor entao nao pode excluir
                if ((acao.equals("editar")) && (nivelUser >= 4) && (Boolean.parseBoolean(request.getParameter("ex")))) {%>
                <td width="10%"><input name="exclui" type="button" class="botoes" id="exclui" value="Excluir" onclick="tryRequestToServer(function(){excluir(<%=cadTC.getTalaoCheque().getId()%>);});"></td>
                    <%}%>
                <td width="10%" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:tryRequestToServer(function(){voltar();});"></td>
            </tr>
        </table>
        <br>
        <table width="90%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="4" align="center">Dados principais</td>
            </tr>
            <tr class="celulaZebra2" id="trNovo">
                <td>
                    <span class="CelulaZebra2">
                        <img src="img/add.gif" border="0" class="imagemLink " title="Adicionar um novo talão" onClick="addTalaoCheque();">
                        Adicione um Talão de Cheque
                    </span>
                </td>
            </tr>
            <tr>
                <td colspan="4">
                    <table width="100%" class="bordaFina">
                        <tbody id="tabTalao">
                            <tr>
                                <td class="CelulaZebra1" width="4%" ><input type="hidden" id="maxTalao"name="maxTalao" value="0"></td>
                                <td class="CelulaZebra1" width="14%" >Conta</td>
                                <td class="CelulaZebra1" width="10%" >Número Inicial</td>
                                <td class="CelulaZebra1" width="10%" >Número Final</td>
                                <td class="CelulaZebra1" width="11%" >Filial</td>
                                <td class="CelulaZebra1" width="12%" >Setor</td>
                                <td class="CelulaZebra1" align="center" width="5%" ><div align="center">Liberado</div></td>
                                <td class="CelulaZebra1" width="10%" >Data Liberação</td>
                                <td class="CelulaZebra1" width="5%" >Hora</td>
                                <td class="CelulaZebra1" width="17%" >Entregue Para</td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
                    <%if(acao.equals("editar")){%>
            <tr >
                    <td colspan="4"  class="tabela"><div align="center">Auditoria</div></td>
                </tr>
                <tr>
                    <td colspan="4">
                        <table width="100%"  border="0" class="bordaFina">
                            <tr>
                                <td width="15%" class="TextoCampos">Incluso:</td>
                                <td width="35%" class="CelulaZebra2">Em: <%=(tlCheque.getCriadoEm() != null ? fmt.format(tlCheque.getCriadoEm()) : "")%><br>Por: <%=tlCheque.getCriadoPor() != null ? tlCheque.getCriadoPor().getNome() : ""%></td>
                                <td width="15%" class="TextoCampos">Alterado:</td>
                                <td width="35%" class="CelulaZebra2">Em: <%=(tlCheque.getAlteradoEm() != null ? fmt.format(tlCheque.getAlteradoEm()) : "")%><br>Por: <%=tlCheque.getAlteradoPor().getNome() != null ? tlCheque.getAlteradoPor().getNome() : ""%></td>
                            </tr>
                        </table>

                    </td>
                </tr>
            <%}%>
            <tr class="CelulaZebra2">
                <td colspan="4"><center>
                    <% if (nivelUser >= 2){%>
                    <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir":"atualizar")%>');});">
                    <%}%>
                </center></td>
            </tr>
        </table>

        <br>
    </form>
    </body>
</html>
