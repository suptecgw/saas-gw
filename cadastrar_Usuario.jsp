<%-- 
    Document   : cadastrar_Usuario
    Created on : 11/05/2012, 15:30:27
    Author     : ricardo
--%>


<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<link REL="stylesheet" HREF="estilo.css" TYPE="text/css">
<link REL="stylesheet" HREF="protoloading.css" TYPE="text/css">
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/scriptaculous.js?load=effects"></script>
<script language="javascript" type="text/javascript" src="script/protoloading.js"></script>
<script language="javascript" type="text/javascript" src="script/sessao.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="JavaScript" src="script/jquery.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script type="text/javascript">
    jQuery.noConflict();
    function direcionaAjax(bol){
        if(bol){
            carregarPermissoes();
        }else{
            carregarPermissoesGrupo();
        }
    }
    var listaNat = new Array();
    <c:forEach items="${listaDeNats}" var="nats" varStatus="status">
            listaNat['${status.index}'] = new Option("${nats.id}", "${nats.descricao}");
    </c:forEach>
        
    function setDefault(){
        var formu = document.formulario;
        $("trVendedor").style.display = "none";
        $("trContasBancarias").style.display = "none";
        $("dataDeAuditoria").value = '<c:out value="${param.dataAtual}" />';
        $("dataAteAuditoria").value = '<c:out value="${param.dataAtual}"/>';
        var action = '<c:out value="${param.acao}"/>';
        if(action == 2){           
            formu.nome.value = '<c:out value="${usuarioCadUsuario.nome}"/>';
            formu.email.value = '<c:out value="${usuarioCadUsuario.email}"/>';
            if ('<c:out value="${usuarioCadUsuario.isRecebeEmailBackup}" />' == "true") {formu.isRecebeEmailBackup.checked = true;}
            formu.login.value = '<c:out value="${usuarioCadUsuario.login}"/>';
            formu.agencia.value = '<c:out value="${usuarioCadUsuario.agencia.id}"/>';
            formu.isVendedor.checked = ('<c:out value="${usuarioCadUsuario.isVendedor}"/>' == "true");
            formu.isAtivo.checked = ('<c:out value="${usuarioCadUsuario.isAtivo}"/>' == "true");
            formu.isOcultarMenuSemPermissao.checked = ('<c:out value="${usuarioCadUsuario.isOcultarMenuSemPermissao}"/>' == "true");
            
            formu.rod.checked = ('<c:out value="${usuarioCadUsuario.emiteRodoviario}"/>' == "true");
            formu.aer.checked = ('<c:out value="${usuarioCadUsuario.emiteAereo}"/>' == "true");
            formu.aqu.checked = ('<c:out value="${usuarioCadUsuario.emiteAquaviario}"/>' == "true");
            formu.isLimitarUsuarioVisualizarContas.checked = ('<c:out value="${usuarioCadUsuario.limitarUsuarioVisualizarConta}"/>' == "true");
            formu.isEmiteCobranca.checked = ('<c:out value="${usuarioCadUsuario.emiteCteCobranca}"/>' == "true");
            formu.isEmiteNormal.checked = ('<c:out value="${usuarioCadUsuario.emiteCteNormal}"/>' == "true");
            formu.isEmiteDiaria.checked = ('<c:out value="${usuarioCadUsuario.emiteCteDiaria}"/>' == "true");
            formu.isEmitePallets.checked = ('<c:out value="${usuarioCadUsuario.emiteCtePallet}"/>' == "true");
            formu.isEmiteComplementar.checked = ('<c:out value="${usuarioCadUsuario.emiteCteComplementar}"/>' == "true");
            formu.isEmiteReentrega.checked = ('<c:out value="${usuarioCadUsuario.emiteCteReentrega}"/>' == "true");
            formu.isEmiteDevolucao.checked = ('<c:out value="${usuarioCadUsuario.emiteCteDevolucao}"/>' == "true");
            formu.isEmiteCortesia.checked = ('<c:out value="${usuarioCadUsuario.emiteCteCortesia}"/>' == "true");
            formu.isEmiteSubstituicao.checked = ('<c:out value="${usuarioCadUsuario.emiteCteSubstituicao}"/>' == "true");
            formu.isEmiteAnulacao.checked = ('<c:out value="${usuarioCadUsuario.emiteCteAnulacao}"/>' == "true");
            formu.isUsuarioGwMobile.checked = ('<c:out value="${usuarioCadUsuario.isUsuarioGwMobile}"/>' == "true");
            showfuncionario();
            formu.isUsuarioGWi.checked = ('<c:out value="${usuarioCadUsuario.usuarioGWi}"/>' == "true");
            formu.acessoNat.checked = ('<c:out value="${usuarioCadUsuario.isUtilizaNat}"/>' == "true");
            formu.renovarSenha.checked = ('<c:out value="${usuarioCadUsuario.renovarSenha}"/>' == "true");
            formu.funcionario.value = '<c:out value="${usuarioCadUsuario.funcionario.idfornecedor}"/>' ;
            
            visualizarDomNat();
            
            if (formu.isVendedor.checked.value == true){
                $("trVendedor").style.display = " ";
            }
            if (formu.isLimitarUsuarioVisualizarContas.checked){
                $("trContasBancarias").style.display = "";
            }

            var grupo = '<c:out value="${usuarioCadUsuario.grupo.id}"/>';
            formu.grupo.value = grupo;

            if(grupo > 0 && action != 2){
                carregarPermissoesGrupo();
            }

            var usua;

    <c:forEach var="item" varStatus="status" items="${usuarioCadUsuario.itens}">
            $("trVendedor").style.display = "";
            usua = new UsuarioVendedor();
            usua.idItens = "${item.id}"
            usua.idUsuario = "${item.usuario.id}";
            usua.idVendedor = "${item.vendedor.idfornecedor}";
            usua.nomeVendedor = '${item.vendedor.razaosocial}';

            addUsuario(usua);

    </c:forEach>
        
    <c:forEach items="${carregarListaNats}" var="nats" varStatus="status">
        nat = new Nat();
        nat.id = "${nats.nat.id}";
        nat.idUsuNat = "${nats.usuario.id}";
        nat.idUsuarioNat = ${nats.id};
        nat.excluir = ${nats.excluir};
        
        addNatUsuario(nat);     
    </c:forEach>
          
    //Primeiro forEach carregarContaBancarias, vai trazer todas as contas.
    <c:forEach var="contasBancarias" varStatus="statusCarregar" items="${carregarContasBancarias}">
        //Segundo forEach listarContaUsuario, vai trazer todas as contas que estão cadastradas para o usuario.
        <c:forEach var="carregarContaUsuario" varStatus="statusListar" items="${usuarioCadUsuario.listaUsuarioConta}">
            <c:if test="${contasBancarias.conta.idConta == carregarContaUsuario.conta.idConta}">
                $("contaUsuario_${statusCarregar.count}").checked = true;
            </c:if>
        </c:forEach>        
    </c:forEach>
            
            var operacaoGWiUsuario;

            <c:forEach var="operacaoUsuarioGWi" items="${usuarioCadUsuario.clientesGWi}">
                operacaoGWiUsuario = new OperacaoGWiUsuario();
                operacaoGWiUsuario.id = "${operacaoUsuarioGWi.id}";
                operacaoGWiUsuario.clienteId = "${operacaoUsuarioGWi.clienteId}";
                operacaoGWiUsuario.nomeOperacao = '${operacaoUsuarioGWi.razaoSocialCliente}';
                operacaoGWiUsuario.cnpjOperacao = '${operacaoUsuarioGWi.cnpjCliente}';

                addOperacaoGwiUsuario(operacaoGWiUsuario);
            </c:forEach>
        }else{
            formu.login.value = "";
            formu.senha.value = "";
        }
    }

    function aoClicarNoLocaliza(idJanela)  {
        var index = $("indexAux").value;
        if (idJanela == "Vendedor") {
            $("idUsuario_" + index).value = $("idUsuario").value;
            $("idVendedor_"+ index).value  = $("idvendedor").value;
            $("nomeVendedor_"+ index).value  = $("ven_rzs").value;
        } else if (idJanela == "Cliente") {
            $("idOperacaoGWi_" + index).value = $("idconsignatario").value;
            $("nomeOperacaoGWi_" + index).value = $("con_rzs").value;
            $("cnpjOperacaoGWi_" + index).value = $("con_cnpj").value;
        }
    }

    function localizarVendedor(index){
        if($("indexAux") != null){
            $("indexAux").value = index;
        }
        popLocate(27, "Vendedor","");
    }

    function voltar(){
        // validaSession(function(){(
            window.location="ConsultaControlador?codTela=62";
        // )});
    }

    function carregarPermissoes(){   
        var idFilial = document.formulario.filial.value;

        new Ajax.Request('UsuarioControlador?acao=carregarPermissoes&idFilial=' + idFilial,
                {
            method:'get',
            onSuccess: function(transport){

                        var response = transport.responseText;
                        var splitResp = response.split("!!");

                        respostaCombo = splitResp[0];
                        respostaTabela = splitResp[1];

                        carregaAjax(respostaTabela, respostaCombo);
                        $("usuarioPermissao").selectedIndex = 0;

                    },
            onFailure: function(){ alert('Something went wrong...') }
                });
    }

    function carregarPermissoesGrupo(){   
        var idGrupo = document.getElementById("grupo").value;

        var idFilial = document.formulario.filial.value;

        new Ajax.Request('UsuarioControlador?acao=carregarPermissoesGrupo&idGrupo='+idGrupo+'&idFilial='+idFilial,
                {
           method:'get',
           onSuccess: function(transport){
                        var response = transport.responseText;
                        carregaAjaxGrupo(response);
                        $("usuarioPermissao").selectedIndex = 0;
                    },
           onFailure: function(){ alert('Something went wrong...') }
                });
    }
    
    function carregaAjax(respostaTabela, respostaCombo){
        var tabela = $("tdConteudo");
        var combo = $("grupo");

        Element.update(tabela, respostaTabela);
        //  Element.update(combo, respostaCombo);
    }

    function carregaAjaxGrupo(response){
        var tabela = document.getElementById("tdConteudo");
        tabela.innerHTML = response;
        jQuery(tabela).find('select').attr('disabled',true);
          
        let grupoUser = $('grupo_usuario').value;
        if (grupoUser !== null && grupoUser !== '' && grupoUser !== 'null') {
            alert("O usuário que deseja copiar não possui permissão(ões) própria(s), sua(s) permissão(ões) vem do grupo " + grupoUser + ".");
            carregarPermissoes();
            $('usuarioPermissao').value = '--';
        }
    }

    function getGrupo(){
        var filial = $("filial").value;

        function e(transport){
            var textoresposta = transport.responseText;

            var acao = '${param.acao}';

            //se deu algum erro na requisicao...
            if (textoresposta == "-1"){
                alert('Houve algum problema.');
                return false;
            }else{

                var lista = jQuery.parseJSON(textoresposta);

                var listGrupo = lista.list[0].grupo;
                var grupo;
                var slct = $("grupo");

                var valor = $("grupo").value;
                var desc = "       ";

                removeOptionSelected("grupo");
                if(listGrupo== null || listGrupo== undefined){
                    slct.appendChild(Builder.node('OPTION', {value:valor}, desc));
                }
                var length = (listGrupo != undefined && listGrupo.length != undefined ? listGrupo.length : 1);
                slct.appendChild(Builder.node('OPTION', {value: 0}, "      "));
                for(var i = 0; i < length; i++){

                    if(length > 1){
                        grupo = listGrupo[i];
                        if(i == 0){
                            valor = listGrupo[i].id;
                        }
                    }else{
                        grupo = listGrupo;
                    }
                    if(grupo != null && grupo != undefined){
                        slct.appendChild(Builder.node('OPTION', {value: grupo.id}, grupo.descricao));
                    }
                }
                slct.selectedIndex = 0;


            }
        }//funcao e()
        tryRequestToServer(function(){
            new Ajax.Request("UsuarioControlador?acao=carregarGrupoAjax&filial="+filial,{method:'post', onSuccess: e, onError: e});
        });
    }

    function checaSenha(){
        if(document.formulario.senha.value == document.formulario.repetir.value)
            return true;

        return false;
    }

    function checaPerms(){
//        if(document.formulario.ultimoId == null)
//            return false;
        var max = jQuery('[id^=hd]').length;
        var nivel;
        var perms = false;
        for(var i = 1; i <= max; i++){  
            if(document.getElementById("hd"+i) != null){
                nivel = document.getElementById("nv"+i).value;
                if(nivel > 0 ){
                    perms = true;
                    return perms;
                }
            }
        }
        return perms;

    }

    function salvar(){
        var formu = document.formulario;


        if(formu.nome.value == ""){
            alert("O campo 'Nome' não pode ficar em branco!");
            formu.nome.focus();
            return false;
        }
        if(formu.login.value == ""){
            alert("O campo 'Login' não pode ficar em branco!");
            formu.login.focus();
            return false;
        }

        if(formu.senha.value == ""){
            alert("O campo 'Senha' não pode ficar em branco!");
            formu.senha.focus();
            return false;
        }
        if(formu.repetir.value == ""){
            alert("favor confirme sua senha!");
            formu.repetir.focus();
            return false;
        }

        if(!checaSenha()){
            alert("Senhas não conferem!");
            return false;
        }

        if(!checaPerms()){
            alert("Selecione no mínimo uma permissão!");
            return false;
        }
        console.log(formu.funcionario.value);
        if(formu.funcionario.value != 0){
            alert("ATENÇÃO! Ao informar um funcionário, o sistema irá copiar o login e senha do usuário para o cadastro do funcionário.");
        }
        
        // Reativar selects, pois um select disabled não envia em um form.
        jQuery("#tdConteudo").find('select').attr('disabled', false);

        setEnv();
        window.open('about:blank', 'pop', 'width=210, height=100');

        formu.submit();

    }

    function borracha(index){
        $("idVendedor_" + index).value = 0;
        $("nomeVendedor_" + index).value = ' ';
    }

    function UsuarioVendedor(idItens,idUsuario, idVendedor, nomeVendedor){
        this.idItens = (idItens != undefined ? idItens : 0);
        this.idUsuario = (idUsuario != undefined ? idUsuario : 0);
        this.idVendedor = (idVendedor != undefined ? idVendedor : 0);
        this.nomeVendedor = (nomeVendedor != undefined ? nomeVendedor : "");
    }

    function removerVendedor(index){
        var idItens = $("idItens_" + index).value;
        var idVendedor = $("idVendedor_"+index).value;
        var nomeVendedor = $("nomeVendedor_"+index).value;

             if(confirm("Deseja excluir esse vendedor ?")){
                if(confirm("Tem certeza?")){
                    Element.remove($("trUsuario_"+index));
                if (index != 0) {
                        tryRequestToServer(function(){new Ajax.Request("UsuarioControlador?acao=excluirVendedor&idItens="+idItens+"&idVendedor=" + idVendedor + "&nomeVendedor=" + nomeVendedor,
                                {
                            method:'get',
                            onSuccess: function(){ alert('Vendedor removido com sucesso!') 
                                        $("nomeVendedor_" + index).value = ""
                                        $("idVendedor_" + index).value = ""
                                                   $("idItens_" + index).value = ""},
                            onFailure: function(){ alert('Something went wrong...') }
                                });
                    });}

            }
        }
    }

    function visualizarVendedores(){
       if($("isVendedor").checked){
            $("trVendedor").style.display = "";
       }else{
            $("trVendedor").style.display = "none";
        }
    }


    var countUsuario = 0;
  function addUsuario(itensUsuario){
        countUsuario++;
try{
        if(itensUsuario == null || itensUsuario == undefined){
                itensUsuario = new UsuarioVendedor();
            }

            //campos
        var hid1_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idUsuario_"+countUsuario,
            name:"idUsuario_"+countUsuario,
                value: itensUsuario.idUsuario});

        var hid2_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idVendedor_"+countUsuario,
            name:"idVendedor_"+countUsuario,
                value: itensUsuario.idVendedor});

        var hid3_ = Builder.node("INPUT",{
            type:"hidden",
            id:"idItens_"+countUsuario,
            name:"idItens_"+countUsuario,
                value: itensUsuario.idItens});


            // nome Vendedor
        var inp1_ = Builder.node("INPUT",{
            type:"text",
            id:"nomeVendedor_"+countUsuario,
            name:"nomeVendedor_"+countUsuario,
                value: itensUsuario.nomeVendedor,
                size: "30",
            className:"inputtexto"});
            readOnly(inp1_);

        var _img0 = Builder.node("IMG",{
            src:"img/lixo.png",
            onClick:"removerVendedor("+countUsuario+");"});

        var _img1 = Builder.node("IMG",{
            src:"img/borracha.gif",
            className:"imagemLink",
            onClick:"borracha("+countUsuario+");"});


       var bot0_ = Builder.node("INPUT",{className:"inputBotaoMin",
            id:"localizaVendedor_"+countUsuario,
            name:"localizaVendedor_"+countUsuario,
            type:"button", value:"...",
            onClick:"localizarVendedor("+ countUsuario +");"});


        var td0_ = Builder.node("TD",{
            width:"2%",
            align:"center"});
        var td1_ = Builder.node("TD",{
            width:"20%",
            align:"left"});


            td0_.appendChild(_img0);

            td1_.appendChild(hid1_);
            td1_.appendChild(inp1_);
            td1_.appendChild(bot0_);
            td1_.appendChild(_img1);
            td1_.appendChild(hid2_);
            td1_.appendChild(hid3_);

        var tr1_ = Builder.node("TR",{
            className:"CelulaZebra2",
            id:"trUsuario_"+countUsuario});



            tr1_.appendChild(td0_);
            tr1_.appendChild(td1_);


            //inserindo outra tabela que possuirá a tabela com os tipos de veiculos

            $("tbUsuario").appendChild(tr1_);

            $("max").value = countUsuario;

        }catch(e){
            alert(e)
        }

    }
</script>
<script type="text/javascript">

    function stAba(menu, conteudo)
    {
        this.menu = menu;
        this.conteudo = conteudo;
    }

    var arAbas = new Array();

    arAbas[0] = new stAba('tdWeb','divWeb');

    function AlternarAbas(menu,conteudo)
    {
        var m;
        var c;

        for (i=0;i<arAbas.length;i++)
        {
            if (document.getElementById(arAbas[i].conteudo) != null){
                m = document.getElementById(arAbas[i].menu);
                m.className = 'menu';
                c = document.getElementById(arAbas[i].conteudo);
                c.style.display = 'none';
            }
        }

        if(c != null){
            m = document.getElementById(menu)
            m.className = 'menu-sel';
            c = document.getElementById(conteudo)
            c.style.display = '';
            if(conteudo == "divCRM"){
                $("divCRM2").style.display = "";
            }else{
                $("divCRM2").style.display = "none";
            }
        }

    }

    var arAbasGenerico = new Array();
    arAbasGenerico[0] = new stAba('tdAba_1', 'tab1');
    arAbasGenerico[1] = new stAba('tdAba_2', 'tab2');
    arAbasGenerico[2] = new stAba('tdAba_3', 'tab3');
    arAbasGenerico[3] = new stAba('tdAba_4', 'tab4');
    
    function visualizarContasUsuario(){
       if($("isLimitarUsuarioVisualizarContas").checked){
          $("trContasBancarias").style.display = "";
       }else{
          $("trContasBancarias").style.display = "none";
          for (var i = 1; i <= $("maxContaUsuario").value; i++) {
              if($("contaUsuario_"+i).checked){
                  $("contaUsuario_"+i).checked = false;
              }
          }
       }
    }
    

    function copiarPermissoes(){
        if($("usuarioPermissao").value != "--"){
        var idFilial = document.formulario.filial.value;

        new Ajax.Request('UsuarioControlador?acao=carregarPermissoesUsuario&idUsuario='+$("usuarioPermissao").value+'&idFilial='+idFilial,
                {
           method:'get',
           onSuccess: function(transport){
                        var response = transport.responseText;
                        carregaAjaxGrupo(response);
                        $("grupo").selectedIndex = 0;
                    },
           onFailure: function(){ alert('Something went wrong...') }
                });
            
            
            
        }
    }
    
    function carregarUsuarios(){
        var idFilial = document.formulario.filial.value;
        new Ajax.Request('UsuarioControlador?acao=carregarUsuarios&idFilial='+idFilial,{
           method:'get',
           onSuccess: 
           
           function(transport) {
            var response = transport.responseText;
            var listUsuarios = jQuery.parseJSON(response).list[0].listaUsuariosCadUsuario;
            var us = null;
                
            var length = (listUsuarios != undefined && listUsuarios.length != undefined ? listUsuarios.length : 1);
            var idx = 0;
            var optLayout = null;
            removeOptionSelected("usuarioPermissao");
            optLayout = Builder.node("option", {value: '--'});
            Element.update(optLayout, "Escolha um usuario" );
            $("usuarioPermissao").appendChild(optLayout);
            
            
            for (var i = 0; i <= length; i++) {
                if (length == 1) {
                    us = listUsuarios;
                }else{
                    us = listUsuarios[i];
                }
                optLayout = Builder.node("option", {value: us.id});
                Element.update(optLayout, us.nome);
                $("usuarioPermissao").appendChild(optLayout);
                $("usuarioPermissao").selectedIndex = 0;
            }
                
        },
           onFailure: function(){ alert('Something went wrong...') }
                });
    }
    function pesquisarAuditoria() {
            if (countLog != null && countLog != undefined) {
                for (var i = 1; i <= countLog; i++) {
                    if ($("tr1Log_" + i) != null) {
                        Element.remove(("tr1Log_" + i));
                    }
                    if ($("tr2Log_" + i) != null) {
                        Element.remove(("tr2Log_" + i));
                    }
                }
            }
            countLog = 0;
            var rotina = "usuario";
            var dataDe = $("dataDeAuditoria").value;
            var dataAte = $("dataAteAuditoria").value;
            var id ='<c:out value="${usuarioCadUsuario.id}"/>';
            console.log(rotina, id, dataDe, dataAte);
            consultarLog(rotina, id, dataDe, dataAte);

        }

    function visualizarOperacoesGwi() {
        if($("isUsuarioGWi").checked){
            $("trOperacoesGWi").style.display = "";
        } else{
            $("trOperacoesGWi").style.display = "none";
        }
    }
    
    function OperacaoGWiUsuario(id, idOperacao, nomeOperacao, cnpjOperacao) {
        this.id = (id != undefined ? id : 0);
        this.idOperacao = (idOperacao != undefined ? idOperacao : 0);
        this.nomeOperacao = (nomeOperacao != undefined ? nomeOperacao : '');
        this.cnpjOperacao = (cnpjOperacao != undefined ? cnpjOperacao : '');
    }

    function localizarOperacaoGWi(index){
        if($("indexAux") != null){
            $("indexAux").value = index;
        }

        popLocate(59, "Cliente","");
    }

    function removerOperacaoGWi(index) {
        var idUsuarioGWi = $("idUsuarioGWi_" + index).value;
        var nomeOperacaoGWi = $("nomeOperacaoGWi_" + index).value;
        var cnpjOperacaoGWi = $("cnpjOperacaoGWi_" + index).value;

        if (confirm("Deseja excluir o acesso ao cliente " + nomeOperacaoGWi + " do GW-i?")) {
            if (confirm("Tem certeza?")) {
                if (index != 0) {
                    Element.remove(("trOperacaoGWi_" + index));

                    tryRequestToServer(function() {
                        new Ajax.Request("UsuarioControlador?acao=excluirOperacaoGWi&idUsuarioGWi=" + idUsuarioGWi + "&nomeOperacaoGWi=" + nomeOperacaoGWi + "&cnpjOperacaoGWi=" + cnpjOperacaoGWi, {
                            method: 'get',
                            onSuccess: function() {
                                alert('Acesso ao cliente ' + nomeOperacaoGWi + ' removido com sucesso!');
                                $("idUsuarioGWi_" + index).value = "";
                                $("idOperacaoGWi_" + index).value = "";
                                $("nomeOperacaoGWi_" + index).value = "";
                                $("cnpjOperacaoGWi_" + index).value = "";
                            },
                            onFailure: function() {
                                alert('Alguma coisa deu errado!');
                            }
                        });
                    });
                }

            }
        }
    }
    
    var countOperacoesGWiUsuario = 0;

    function addOperacaoGwiUsuario(operacaoGWiUsuario) {
        countOperacoesGWiUsuario++;
        if (operacaoGWiUsuario == null || operacaoGWiUsuario == undefined) {
            operacaoGWiUsuario = new OperacaoGWiUsuario();
        }

        //campos
        var hid1_ = Builder.node("INPUT", {
            type: "hidden",
            id: "idUsuarioGWi_" + countOperacoesGWiUsuario,
            name: "idUsuarioGWi_" + countOperacoesGWiUsuario,
            value: operacaoGWiUsuario.id
        });

        var hid2_ = Builder.node("INPUT", {
            type: "hidden",
            id: "idOperacaoGWi_" + countOperacoesGWiUsuario,
            name: "idOperacaoGWi_" + countOperacoesGWiUsuario,
            value: operacaoGWiUsuario.idOperacao
        });

        // nome Vendedor
        var inp1_ = Builder.node("INPUT", {
            type: "text",
            id: "nomeOperacaoGWi_" + countOperacoesGWiUsuario,
            name: "nomeOperacaoGWi_" + countOperacoesGWiUsuario,
            value: operacaoGWiUsuario.nomeOperacao,
            size: "50",
            className: "inputtexto"
        });
        var inp2_ = Builder.node("INPUT", {
            type: "text",
            id: "cnpjOperacaoGWi_" + countOperacoesGWiUsuario,
            name: "cnpjOperacaoGWi_" + countOperacoesGWiUsuario,
            value: operacaoGWiUsuario.cnpjOperacao,
            size: "20",
            className: "fieldMin"
        });
        readOnly(inp1_);
        readOnly(inp2_);

        var _img0 = Builder.node("IMG", {
            src: "img/lixo.png",
            onClick: "removerOperacaoGWi(" + countOperacoesGWiUsuario + ");"
        });

        var bot0_ = Builder.node("INPUT", {
            className: "inputBotaoMin",
            id: "localizaOperacaoGWi_" + countOperacoesGWiUsuario,
            name: "localizaOperacaoGWi_" + countOperacoesGWiUsuario,
            type: "button",
            value: "...",
            onClick: "localizarOperacaoGWi(" + countOperacoesGWiUsuario + ");"
        });

        var td0_ = Builder.node("TD", {
            width: "2%",
            align: "center"
        });

        var td1_ = Builder.node("TD", {
            width: "20%",
            align: "left"
        });

        td0_.appendChild(_img0);

        td1_.appendChild(hid1_);
        td1_.appendChild(inp1_);
        td1_.appendChild(inp2_);
        td1_.appendChild(bot0_);
        td1_.appendChild(hid2_);

        var tr1_ = Builder.node("TR", {
            className: "CelulaZebra2",
            id: "trOperacaoGWi_" + countOperacoesGWiUsuario
        });

        tr1_.appendChild(td0_);
        tr1_.appendChild(td1_);

        $("tbOperacoesGWiUsuario").appendChild(tr1_);

        $("quantidadeOperacoesGwiUsuario").value = countOperacoesGWiUsuario;
    }
    
    // objeto NAt
    function Nat(id, idUsuNat,idUsuarioNat,excluir){
        this.id = (id !== null && id !== undefined) ? id : 0;
        this.idUsuNat = (idUsuNat !== null && idUsuNat !== undefined) ? idUsuNat : 0;
        this.idUsuarioNat = (idUsuarioNat !== null && idUsuarioNat !== undefined) ? idUsuarioNat : 0;
        this.excluir = excluir;
        
    }
    
    
    var countNAT = 0;
    function addNatUsuario(nat){
        countNAT++;
        if (nat === null || nat === undefined) {
            nat = new Nat();
        }

        
        var tabela = jQuery('#tb-nat');
        var classe = (countNAT % 2 === 1 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign");
        var _tdNat = Builder.node("td",{id:"tdNat_"+countNAT, align: "center", width:"10%",className:classe });
        var _tdNatSlc = Builder.node("td",{id:"tdNatSlc_"+countNAT, align: "left", className:classe });
        //var hiddenExcluido = Builder.node("input",{name:"isExcluido_" +countNAT,id:"isExcluido_" + countNAT, type:"hidden",value:false});
        
        var trPrincipal = Builder.node("TR",{
            className: "tabela",
            id: "trPrincipal_" + countNAT,
            name:"trPrincipal_" + countNAT
            
        });
        
        var hiddenExcluido = Builder.node("input",{
            name:"hidIdUsuarioNat_" +countNAT,
            id:"hidIdUsuarioNat_" + countNAT,
            type:"hidden",
            value:nat.idUsuarioNat
        });
        
        
            
            var isExcluir = Builder.node("INPUT",{
            type:"hidden",
            id:"isExcluir_"+countNAT,
            name:"isExcluir_"+countNAT,
            value: 'false'
            });
           
        
        var _inpExcluirNat = Builder.node("img",{
            id:"inpExcluirNat_"+countNAT,
            name:"inpExcluirNat_"+countNAT,
            type:"button",
            className:"imagemLink",
            src:"img/lixo.png",
            width:"20px",                       
            heigth:"20px",
            onclick:"javascript:tryRequestToServer(function(){removerNat("+countNAT+")});",
            value: nat.id
        });
   
       
        
        var _slcNat = Builder.node("select",{
            id:"slcNat_"+countNAT, 
            name:"slcNat_"+countNAT, 
            className:"inputtexto",  
            style:"width:100px",
            value: nat.id
            
        });
        var optSelecione = Builder.node("option", 
            {value: 0},
            'Selecione'
        );
        
        _slcNat.appendChild(optSelecione);
         povoarSelect(_slcNat,listaNat);
        _tdNat.append(hiddenExcluido);
        _tdNat.appendChild(_inpExcluirNat);
        _tdNat.append(isExcluir);
        _tdNatSlc.appendChild(_slcNat);
        trPrincipal.appendChild(_tdNat);
        trPrincipal.appendChild(_tdNatSlc);
        
        tabela.append(trPrincipal);
        
        
        
        jQuery('#quantidadeNatUsuario').val(countNAT); 
        jQuery("#slcNat_"+countNAT).val(nat.id); 
        
    }
    
   // Método em desenvolvimento 
    function removerNat(index){
        var conf = confirm("Tem certeza que deseja excluir esse nat?");
        if (conf) {
            jQuery('#trPrincipal_' + index).hide(); 
            jQuery('#isExcluir_' + index).val('true');  
        }
        
    }
    
    function visualizarDomNat() {
        if($("acessoNat").checked){
            $("tr-dom-nat").style.display = "";
            $("acessoNat").value = "True";
        } else{
        $("tr-dom-nat").style.display = "none";
        $("acessoNat").value = "false";
        }
    }
    
    function checarGrupoUsuario(){
        if (jQuery('#grupo').val() !== "0") {
            jQuery("#tdConteudo").find('select').attr('disabled',true);
        }
    }
    
    function showfuncionario(){
        if(document.getElementById('isUsuarioGwMobile').checked){
            document.getElementById('optionvincular').style.display = 'block';
        }else{
            document.getElementById('optionvincular').style.display = 'none';
            document.getElementById('funcionario').value = '';
        }
    }
</script>
<html>
    <style>

        body, table {
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            color: #000000;
        }

        .menu {

            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-weight: normal;
            color: #000033;
            background-color: #FFFFFF;
            border-right: 1px solid #000000;
            border-left: 1px solid #000000;
            border-top: 1px solid #000000;
            border-bottom: 1px solid #000000;
            padding: 5px;
            cursor: hand;
        }

        .menu-sel {
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-weight: bold;
            color: #000033;
            background-color: #CCCCCC;
            border-right: 1px solid #000000;
            border-left: 1px solid #000000;
            border-top: 1px solid #000000;
            padding: 5px;
            cursor: hand;
        }

        .tb-conteudo {
            border-right: 1px solid #000000;
            border-bottom: 1px solid #000000;
        }

        .conteudo {
            font-family: Verdana, Arial, Helvetica, sans-serif;
            font-size: 10px;
            font-weight: normal;
            color: #000033;
            background-color: #F7F7F7;

            width: 100%;
            height: 100%;

        }
        
        .margEsquerda{
            margin-left: 48px;
            margin-bottom: 10px;
        }
        
        #tb-nat{
            margin-bottom: 10px;
        }

    </style>
    <style type="text/css">
        <!--
        .style3 {color: #333333}
        .style4 {
            font-size: 14px;
            font-weight: bold;
        }
        -->
    </style>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>webtrans - Cadastro de Usu&aacute;rios</title>
    </head>
    <body onload="setDefault(), AlternarAbasGenerico('tdAba_1', 'tab1');visualizarVendedores();visualizarOperacoesGwi();visualizarDomNat();checarGrupoUsuario();">  
        <img src="img/banner.gif" width="40%" height="44" align="middle"> 
        <table class="bordaFina" width="95%" align="center">
            <tr>
                <td width="95%" align="left">
                    <span class="style4">Cadastro de Usu&aacute;rios</span> 
                </td>  
                <td>                                                           
                    <input type="button" value=" Voltar " class="inputbotao" onclick="tryRequestToServer(function() {voltar()})"/>
                </td>
            </tr>
        </table>
        <br>
            <c:choose>
                <c:when test="${param.acao == 2}">               
                    <form action="UsuarioControlador?acao=editar" id="formulario" name="formulario" method="post" target="pop">
                        <table width="95%" align="center" class="bordaFina">
                            <tr>
                                <td colspan="6" align="center" class="tabela" >Dados principais</td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Filial:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <b> 
                                        <input type="hidden" name="idUsuario" id="idUsuario" value="${usuarioCadUsuario.id}"></input>
                                        <c:out value="${usuarioCadUsuario.filial.abreviatura}"/> 
                                    </b> 
                                    <input type="hidden" name="filial" value="${usuarioCadUsuario.filial.idfilial}"></input>                    
                                </td>
                            </c:when>
                            <c:otherwise>
                            <form action="UsuarioControlador?acao=cadastrar" id="formulario" name="formulario" method="post" target="pop">
                                <table width="95%" align="center" class="bordaFina">
                                    <tr>
                                        <td colspan="6" align="center" class="tabela" >Dados principais</td>
                                    </tr>
                                    <tr>
                                        <td class="TextoCampos">Filial:</td>
                                        <td class="CelulaZebra2" colspan="3">
                                            <input type="hidden" name="idUsuario" id="idUsuario" value="${usuarioCadUsuario.id}"></input>
                                            <select name="filial" id="filial" class="inputtexto"  onchange="getGrupo(); carregarPermissoes(); carregarUsuarios();">
                                                <option value="">-Selecione uma Filial-</option>
                                                <c:forEach var="filial" items="${filiaisCadUsuario}">
                                                    <option value="${filial.idfilial}">${filial.abreviatura}</option>
                                                </c:forEach>
                                            </select>                            
                                        </td>
                                    </c:otherwise>
                                </c:choose>
                            <input type="hidden" name="modulo" id="modulo" value="gWeb"/>
                            <td class="TextoCampos">Ag&ecirc;ncia:</td>
                            <td class="CelulaZebra2" >
                                <select   name="agencia" class="inputtexto"  >
                                    <option value="0"> </option>
                                    <c:forEach var="agencia" items="${agenciasCadUsuario}">
                                        <option value="${agencia.id}">${agencia.abreviatura}</option>
                                    </c:forEach>
                                </select>                    
                            </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">*Nome:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <input name="nome" type="text" class="inputtexto" id="nome" size="50" maxlength="30"> </td>
                                <td colspan="2" class="TextoCampos">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">E-mail:</td>
                                <td colspan="3" class="CelulaZebra2">
                                    <input name="email" type="text" class="inputtexto" id="email" size="50" maxlength="70">
                                </td>
                                <td colspan="2" class="celulaZebra2"> <label><input type="checkbox" name="isRecebeEmailBackup" id="isRecebeEmailBackup"> Receber avisos de backup não realizado. </label></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">*Login:</td>
                                <td class="CelulaZebra2">
                                    <input name="login" type="text" class="inputtexto" id="login" maxlength="30"> 
                                </td>
                                <td class="TextoCampos">*Senha:</td>
                                <td class="CelulaZebra2">
                                    <input name="senha" type="password"  class="inputtexto" id="senha" maxlength="13" value="${usuarioCadUsuario.senha}">
                                </td>
                                <td class="TextoCampos">*Repetir:</td>
                                <td class="CelulaZebra2">
                                    <input name="repetir" type="password" class="inputtexto" id="repetir" maxlength="13" value="${usuarioCadUsuario.senha}">
                                </td>
                            </tr>
                            <tr class="celulaZebra2">
                                <td class="TextoCampos">Grupo:</td>
                                <td class="CelulaZebra2">
                                    <%-- Combo alimentado via AJAX no cadastro--%>
                                    <select name="grupo" id="grupo" class="inputtexto" onchange="direcionaAjax(this.value == 0)" style="width: 154px">
                                        <option value="0"></option>
                                        <c:forEach var="grupo" items="${gruposCadUsuario}">
                                            <option value="${grupo.id}" >${grupo.descricao}</option>
                                        </c:forEach>
                                    </select>
                                </td>

                                <td class="TextoCampos" >Emitir apenas CTs: </td>
                                <td class="CelulaZebra2" colspan="2"> 
                                    <div align="center">
                                        <label id="lbRodoviario" >
                                            <input name="rod" type="checkbox" id="rod" value="rod"/>
                                            Rodovi&aacute;rio &nbsp; 
                                        </label>
                                        <label id="lbAereo">     
                                            <input name="aer" type="checkbox" id="aer" value="aer"/>
                                            A&eacute;reo &nbsp; 
                                        </label>
                                        <label id="lbAquaviario">   
                                            <input name="aqu" type="checkbox" id="aqu" value="aqu"/>
                                            Aquavi&aacute;rio
                                        </label> 
                                        
                                    </div>
                                </td>
                                
                                <td class="celulaZebra2" colspan="2">
                                    <label>
                                        <input onclick="" type="checkbox" name="isAtivo" id="isAtivo" value="isAtivo" checked>
                                        Ativo
                                    </label>
                                </td>
                            </tr>
                            </tr>
                        </table>
                        <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                            <tr>
                                <td>
                                <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                                    <tr class="tabela" id="">
                                        <td id="tdAba_1" class="menu-sel" onclick="AlternarAbasGenerico('tdAba_1', 'tab1');"> <center> Dados Principais </center></td>
                                        <td id="tdAba_2" class="menu" onclick="AlternarAbasGenerico('tdAba_2', 'tab2');"> Permissões </td>
                                        <td id="tdAba_3" class="menu" onclick="AlternarAbasGenerico('tdAba_3', 'tab3');"> Segurança </td>
                                        <td style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none" }' id="tdAba_4" class="menu" onclick="AlternarAbasGenerico('tdAba_4', 'tab4');"> Auditoria </td>
                                    </tr>
                                </table>
                                    
                            </tr>
                        </table>
                        <div class="panel" id="tab1">
                                <table width="95%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                                <tr>
                                        
                                    <td class="CelulaZebra2"  colspan="2" width="50%">
                                        <div align="center">
                                            <label>
                                                <input onclick="visualizarVendedores()" type="checkbox" name="isVendedor" id="isVendedor" value="isVendedor">
                                                Visualizar comissões apenas dos vendedores abaixo:                                        
                                            </label>
                                        </div>
                                    </td>
                                    <td class="celulaZebra2" colspan="2" width="50%">
                                        <label>
                                            <input type="checkbox" id="isOcultarMenuSemPermissao" name="isOcultarMenuSemPermissao"/>
                                            Ocultar menu sem permissão
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                        <td class="celulaZebra2" colspan="2">
                                            <label>
                                                <input onclick="visualizarContasUsuario()" type="checkbox" id="isLimitarUsuarioVisualizarContas" name="isLimitarUsuarioVisualizarContas" value="true"/>
                                                Esse usuário só poderá visualizar as seguintes contas bancárias
                                            </label>
                                        </td>
                                        <td class="celulaZebra2" colspan="1">
                                            <label>
                                                <input type="checkbox" id="isUsuarioGwMobile" name="isUsuarioGwMobile" onclick="showfuncionario()"/>
                                                Usuário do gwMobile
                                            </label>
                                            <label id="optionvincular" style="float:right;margin-right: 10px;">
                                                 Vincular a um funcionário: 
                                                  <select name="funcionario" id="funcionario" class="inputtexto"  style="width: 154px">
                                        <option value="0"></option>
                                        <c:forEach var="funcionario" items="${funcionariosCadUsuario}">
                                            <option value="${funcionario.idfornecedor}">${funcionario.razaosocial}</option>
                                        </c:forEach>
                                    </select>
                                            </label>
                                        </td>
                                        <td class="celulaZebra2" colspan="1">
                                            <label>
                                                <input onclick="visualizarOperacoesGwi()" type="checkbox" id="isUsuarioGWi" name="isUsuarioGWi" />
                                                Usuário do GW-i
                                            </label>
                                        </td>
                                </tr>
                                <tr>
                                    <td colspan="14">
                                        <table width="100%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
                                            <tr>
                                                <td class="celulaZebra2" colspan="2">
                                                    <label>
                                                        Esse usuário só poderá incluir CT-e(s) dos tipos:: 
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteNormal" name="isEmiteNormal" value="true" checked=""/>
                                                        Normal
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteCobranca" name="isEmiteCobranca" value="true"  checked="" />
                                                        Cobranca
                                                    </label>
                                                </td> 
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteDiaria" name="isEmiteDiaria" checked=""  value="true"/>
                                                        Diaria
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmitePallets" name="isEmitePallets" checked=""  value="true"/>
                                                        Pallets
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteComplementar" name="isEmiteComplementar" checked=""  value="true"/>
                                                        Complementar
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteReentrega" name="isEmiteReentrega" checked=""  value="true"/>
                                                        Reentrega
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteDevolucao" name="isEmiteDevolucao" checked=""  value="true"/>
                                                        Devolucao
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteCortesia" name="isEmiteCortesia" checked=""  value="true"/>
                                                        Cortesia
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteSubstituicao" name="isEmiteSubstituicao" checked=""  value="true"/>
                                                        Substituicao
                                                    </label>
                                                </td>
                                                <td class="celulaZebra2">
                                                    <label>
                                                        <input type="checkbox" id="isEmiteAnulacao" name="isEmiteAnulacao" checked=""  value="true"/>
                                                        Anulacao
                                                    </label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>    
                                <tr id="trContasBancarias">
                                    <td class="CelulaZebra2" colspan="6">
                                    <fieldset>
                                            <legend align="left">Contas Bancarias</legend>
                                            <table class="tabelaZerada" width="100%" >
                                                <tbody id="tbContasUsuario">
                                                    <c:forEach var="usuarioConta" varStatus="status" items="${carregarContasBancarias}">
                                                        <c:if test="${status.count % 2 == 1}">
                                                            <tr class="celulaZebra2">                                                      
                                                        </c:if>
                                                                <td width="50%" colspan="${status.last && status.count % 2 == 1 ? '2': '0'}">
                                                                <label>
                                                                    <input type="checkbox" id="contaUsuario_${status.count}" name="contaUsuario_${status.count}" value="${usuarioConta.conta.idConta}" />
                                                                    <input type="hidden" id="contaUsuarioId_${status.count}" name="contaUsuarioId_${status.count}" value="${usuarioConta.id}" />
                                                                    ${usuarioConta.conta.numero} - ${usuarioConta.conta.descricao}
                                                                </label>
                                                            </td>
                                                        <c:if test="${status.count % 2 == 0}">
                                                            </tr>
                                                        </c:if>
                                                        <c:if test="${status.last}">
                                                            <input type="hidden" id="maxContaUsuario" name="maxContaUsuario" value="${status.count}"/>
                                                        </c:if>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </fieldset>                
                                    </td>  
                                </tr>
                                <tr id="trVendedor">
                                    <td class="CelulaZebra2" colspan="6">
                                        <fieldset>
                                            <legend align="left">Vendedores</legend>
                                            <table class="tabelaZerada" width="100%" >
                                                <tr class="celula">
                                                <input type="hidden" name="max" id="max" value="0"/>
                                                <td align="center" width="3%">
                                                    <img onclick="addUsuario()" alt="addCampo" src="img/novo.gif" class="imagemLink"/>
                                                </td>
                                                <input type="hidden" id="idItensVendedor"></input>
                                                <input type="hidden" id="indexAux"></input>
                                                <input type="hidden" id="idvendedor"></input>
                                                <input type="hidden" id="ven_rzs"></input>
                                                <td width="60%" align="center">Nome</td>
                                                </tr>
                                                <tbody id="tbUsuario"></tbody>
                                            </table>
                                        </fieldset>                
                                        <input type="hidden" id="homePath" value="${homePath}">
                                    </td>  
                                </tr>
                                <tr id="trOperacoesGWi">
                                    <td class="CelulaZebra2" colspan="6">
                                        <fieldset>
                                            <legend align="left">Clientes do GW-i</legend>
                                            
                                            <table class="tabelaZerada" width="100%">
                                                <tr class="celula">
                                                    <input type="hidden" name="quantidadeOperacoesGwiUsuario" id="quantidadeOperacoesGwiUsuario" value="0">
                                                    
                                                    <td align="center" width="3%">
                                                        <img onclick="addOperacaoGwiUsuario()" alt="addOperacaoGwiUsuario" src="img/novo.gif" class="imagemLink">
                                                    </td>
                                                    
                                                    <input type="hidden" id="idconsignatario">
                                                    <input type="hidden" id="con_rzs">
                                                    <input type="hidden" id="con_cnpj">
                                                    
                                                    <td width="80%" align="center">Cliente</td>
                                                </tr>
                                                <tbody id="tbOperacoesGWiUsuario"></tbody>
                                            </table>
                                        </fieldset>
                                    </td>
                                </tr>
                            </table>  
                        </div>
                                
                        <div class="panel" id="tab2">
                            <table width="95%" align="center" class="bordaFina">
                                <tr>
                                    <td colspan="7" class="tabela">Permiss&otilde;es</td>
                                </tr>
                                <tr>
                                    <c:if test="${param.acao == 1}">
                                        <td colspan="3" class="CelulaZebra2NoAlign" align="right">
                                            selecione um usuário para copiar suas permissões : 
                                        </td>
                                        <td colspan="3" class="celulaZebra2">
                                            <select class="inputtexto" name="usuarioPermissao" id="usuarioPermissao" onchange="copiarPermissoes();">
                                                <option value="--">
                                                    Escolha um usuario
                                                </option>
                                                <c:forEach var="usuario" items="${listaUsuariosCadUsuario}" varStatus="status">
                                                    <option value="${usuario.id}">
                                                        ${usuario.nome}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                    </c:if>
                                </tr>
                                <tr>
                                    <td colspan="6" >
                                        <table  width="100%" class="bordaFina">
                                            <tr>
                                                <td colspan="4">
                                                    <table class="bordaFina" width="100%">
                                                        <tr>
                                                            <td class="tb-conteudo" id="tdConteudo" colspan="7">
                                                                <c:if test="${param.acao == 2}">
                                                                    <div id="divWeb" class="conteudo" >
                                                                        <table class="bordaFina" width="100%">
                                                                            <c:set var="grupo2" value=""/>
                                                                            <c:set var="coluna" value="1"/>
                                                                            <c:forEach var="permissao" items="${permissoesCadUsuario}" varStatus="status">
                                                                                <c:if test="${grupo2 != permissao.categoria}">
                                                                                    <c:if test="${coluna == 2}">
                                                                                        <td class="CelulaZebra2"></td>
                                                                                        <td class="CelulaZebra2"></td>
                                                                                    </c:if>
                                                                                    <c:set var="grupo2" value="${permissao.categoria}"/>
                                                                                    <c:set var="coluna" value="1"/>
                                                                                    <tr class="celula">
                                                                                        <td colspan="6">${grupo2}</td>
                                                                                    </tr>
                                                                                </c:if>
                                                                                <c:choose>
                                                                                    <c:when test="${coluna == 1}">
                                                                                        <tr class="CelulaZebra2">
                                                                                            <td>${permissao.codigoLocalizador} - ${permissao.descricao}<input type="hidden" name="hd${permissao.id}" id="hd${permissao.id}" value="${permissao.id}" /></td>
                                                                                            <td>
                                                                                                <c:if test="${permissao.tipo == 'NV'}">
                                                                                                    <select   name="nv${permissao.id}" class="inputtexto" id="nv${permissao.id}" >
                                                                                                        <option class="opCor0" value="0" ${(permissao.nivel == 0 ? 'selected' : '')}>Sem acesso</option>
                                                                                                        <option class="opCor1" value="1" ${(permissao.nivel == 1 ? 'selected' : '')}>Ler</option>
                                                                                                        <option class="opCor2" value="2" ${(permissao.nivel == 2 ? 'selected' : '')}>Ler, alterar</option>
                                                                                                        <option class="opCor3" value="3" ${(permissao.nivel == 3 ? 'selected' : '')}>Ler, alterar, incluir</option>
                                                                                                        <option class="opCor4" value="4" ${(permissao.nivel == 4 ? 'selected' : '')}>Controle total</option>
                                                                                                    </select>
                                                                                                </c:if>
                                                                                                <c:if test="${permissao.tipo == 'SN'}">
                                                                                                    <select   name="nv${permissao.id}" class="inputtexto" id="nv${permissao.id}" >
                                                                                                        <option class="opCor0" value="0" ${(permissao.nivel == 0 ? 'selected' : '')}>Sem acesso</option>
                                                                                                        <option class="opCor4"value="4" ${(permissao.nivel == 4 ? 'selected' : '' )}>Com acesso</option>
                                                                                                    </select>
                                                                                                </c:if>
                                                                                            </td>
                                                                                            <c:set var="coluna" value="2"/>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <td>${permissao.descricao}<input type="hidden" name="hd${permissao.id}" id="hd${permissao.id}" value="${permissao.id}" /></td>
                                                                                            <td>
                                                                                                <c:if test="${permissao.tipo == 'NV'}">
                                                                                                    <select   name="nv${permissao.id}" class="inputtexto" id="nv${permissao.id}" >
                                                                                                        <option class="opCor0" value="0" ${(permissao.nivel == 0 ? 'selected' : '')}>Sem acesso</option>
                                                                                                        <option class="opCor1" value="1" ${(permissao.nivel == 1 ? 'selected' : '')}>Ler</option>
                                                                                                        <option class="opCor2" value="2" ${(permissao.nivel == 2 ? 'selected' : '')}>Ler, alterar</option>
                                                                                                        <option class="opCor3" value="3" ${(permissao.nivel == 3 ? 'selected' : '')}>Ler, alterar, incluir</option>
                                                                                                        <option class="opCor4" value="4" ${(permissao.nivel == 4 ? 'selected' : '')}>Controle total</option>
                                                                                                    </select>
                                                                                                </c:if>
                                                                                                <c:if test="${permissao.tipo == 'SN'}">
                                                                                                    <select  name="nv${permissao.id}" class="inputtexto" id="nv${permissao.id}" >
                                                                                                        <option class="opCor0" value="0" ${(permissao.nivel == 0 ? 'selected' : '')}>Sem acesso</option>
                                                                                                        <option class="opCor4" value="4" ${(permissao.nivel == 4 ? 'selected' : '')}>Com acesso</option>
                                                                                                    </select>
                                                                                                </c:if>
                                                                                            </td>
                                                                                            <c:set var="coluna" value="1"/>
                                                                                        </tr>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </c:forEach>
                                                                            <c:if test="${coluna == 2}">
                                                                                <td class="CelulaZebra2"></td>
                                                                                <td class="CelulaZebra2"></td>
                                                                            </c:if>
                                                                        </table>
                                                                    </div>
                                                                </c:if>
                                                                <c:if test="${param.acao == 2}">
                                                                    <input type="hidden" name="ultimoId" value="${permissoesCadUsuario[0].ultimoId}" >
                                                                </c:if>
                                                                <input type="hidden" name="grupo_usuario" id="grupo_usuario">
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="7" id="tdTableAjax">
                                        <table></table>
                                    </td>
                                </tr>
<!--                                <tr class="tabela">
                                    <td colspan="7">Relatórios Gw Mobile</td>
                                </tr>-->
<!--                                <tr>
                                    <td colspan="6">
                                        <table width="100%" border="0" cellpadding="1" cellspacing="2" class="bordaFina">
                                            <tr class="celula">
                                                <td >Relatórios</td>
                                            </tr>
                                            <c:forEach var="report" items="${reportsMobile}" varStatus="status">
                                                <tr class="celulaZebra2">
                                                    <c:if test="${status.last}">
                                                    <input type="hidden" name="maxReportMobile" id="maxReportMobile" value="${status.count}">
                                                </c:if>
                                                <td >${report.report.descricao}
                                                    <input type="hidden" name="usuarioPermissaoReportId_${status.count}" id="usuarioPermissaoReportId_${status.count}" value="${report.id}" />
                                                    <input type="hidden" name="reportId_${status.count}" id="reportId_${status.count}" value="${report.report.id}" />
                                                    <input type="checkbox" name="liberado_${status.count}" id="report_${status.count}" ${report.liberado ? "checked" : ""} />
                                                </td>
                                    </tr>
                                </c:forEach>
                            </table>
                            </td>
                            </tr>-->
                            </table>
                        </div>
                        <div class="panel" id="tab3">
                            <table width="95%" align="left" class="bordaFina margEsquerda">
                                <tr>
                                    <td class="celulaZebra2" width="100%">
                                        <input  id="acessoNat" name="acessoNat" onclick="visualizarDomNat();" type="checkbox" value="">
                                        Controlar acesso desse usuário
                                    </td>
                                </tr>
                                <tr id="tr-dom-nat">
                                    <td class="celulaZebra2" width="100%">
                                        <table  id="tb-nat-top" name="tb-nat-top" width="20%" align="left" class="bordaFina">
                                            <tr>
                                                <td colspan="7" class="tabela">Acesso do usuário (NAT)</td>
                                            </tr>
                                            <input type="hidden" name="quantidadeNatUsuario" id="quantidadeNatUsuario" value="0">   
                                            <tr id="trAddNat">
                                                <td class="CelulaZebra2" colspan="6">
                                                    <table class="tabelaZerada" width="100%">                                                       
                                                        <tbody>
                                                            <tr class="celula">
                                                                <td align="center" width="8%">
                                                                    <img onclick="addNatUsuario()" alt="addNatAcesso" src="img/novo.gif" class="imagemLink">
                                                                </td>
                                                                <td width="80%" align="center">Nat</td>
                                                            </tr>
                                                        </tbody>
                                                        <tbody id="tb-nat" name="tb-nat">
                                                        </tbody>
                                                    </table>
                                                </td>   
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="CelulaZebra2">
                                        <input type="checkbox" id="renovarSenha" name="renovarSenha">
                                        <label for="renovarSenha">Renovar senha a cada</label>
                                        <input type="text" class="inputtexto" id="qtdDiasRenovarSenha" name="qtdDiasRenovarSenha" size="3" maxlength="3"
                                               value="${usuarioCadUsuario.qtdDiasRenovarSenha == null ? "90": usuarioCadUsuario.qtdDiasRenovarSenha}">
                                        <label for="renovarSenha">dias</label>
                                    </td>
                                </tr>
                            </table>
                        </div>
                      <div class="panel" id="tab4">            
                        <table width="95%" align="center" class="bordaFina" style='display: ${param.acao == 2 && param.nivel == 4 ? "" : "none" }'>
                                <tr class="tabela">
                                    <td colspan="7"> <%@include file="/gwTrans/template_auditoria.jsp" %> </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <table width="100%" border="0" cellpadding="1" cellspacing="2">
                                            <tr>
                                                <td width="15%" class="TextoCampos">Incluso:</td>
                                                <td width="35%" class="CelulaZebra2"> Em: ${usuarioCadUsuario.criadoEm}<br>
                                                    Por: ${usuarioCadUsuario.criadoPor} </td>
                                                <td width="15%" class="TextoCampos">Alterado:  </td>
                                                <td width="35%" class="CelulaZebra2"> Em: ${usuarioCadUsuario.atualizadoEm}<br>
                                                    Por: ${usuarioCadUsuario.atualizadoPor}</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                        </table>
                      </div>                                                 
                        <br/>
                          <table width="95%" align="center" class="bordaFina">
                            <tr class="CelulaZebra2">
                                <c:if test="${param.nivel >= param.bloq}">
                                    <td class="TextoCampos" colspan="7">
                                        <div align="center">
                                            <input type="button" value="  SALVAR  " class="inputbotao" id="botSalvar" onclick="tryRequestToServer(function(){salvar()})"/>
                                        </div>
                                    </td>
                                </c:if>
                            </tr>
                        </table>
                    </form>
                    </body>
                    </html>

               
