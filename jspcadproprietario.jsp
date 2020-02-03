<%@page import="fornecedor.CategoriaCNH"%>
<%@page import="conhecimento.ocorrencia.BeanOcorrenciaCtrc"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="conhecimento.ocorrencia.Ocorrencia"%>
<%@page import="java.util.Date"%>
<%@page import="br.com.gwsistemas.contratodefrete.pedagio.SolucoesPedagio"%>
<%@page import="br.com.gwsistemas.contratodefrete.pedagio.SolucoesPedagioBO"%>
<%@page import="cidade.BeanConsultaCidade"%>
<%@page import="com.thoughtworks.xstream.XStream"%>
<%@page import="com.thoughtworks.xstream.io.json.JettisonMappedXmlDriver"%>
<%@page import="mov_banco.banco.BeanConsultaBanco"%>
<%@page import="nucleo.Apoio"%>
<%@page import="nucleo.BeanConfiguracao"%>
<%@page import="nucleo.BeanLocaliza"%>
<%@page import="nucleo.webservice.WebServiceCep"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri = "http://java.sun.com/jsp/jstl/functions" prefix = "fn" %>
<%@ page contentType="text/html" language="java"
         import="proprietario.BeanCadProprietario,
         proprietario.BeanProprietario,
         java.sql.ResultSet,
         java.text.SimpleDateFormat,
         java.util.Collection" errorPage="" %>
<%@ page import="fornecedor.TipoControleContaCorrente" %>


<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/builder.js"></script>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<!--<script language="javascript" type="text/javascript" src="script/jquery.js"></script>-->
<script type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<!--<script language="javascript" type="text/javascript" src="script/prototype_1_7_2.js"></script>-->
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoesTelaCadProprietario.js"></script>
<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
// privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadproprietario") : 0);
//testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
//fim da MSA
%>
<%            }
    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy");
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    BeanCadProprietario cadprop = null;
    SolucoesPedagioBO solucoesPedagioBO = null;

    BeanConfiguracao cfg = new BeanConfiguracao();
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();

    if (!acao.equals("")) {
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar")) {    //instanciando o bean de cadastro
            cadprop = new BeanCadProprietario();
            cadprop.setConexao(Apoio.getUsuario(request).getConexao());
            cadprop.setExecutor(Apoio.getUsuario(request));
        }

//executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int idproprietario = Integer.parseInt(request.getParameter("id"));
            cadprop.getProp().setIdfornecedor(idproprietario);
            //carregando o proprietario por completo
            cadprop.LoadAllPropertys();
        } else if ((nivelUser >= 2) && (acao.equals("atualizar") || acao.equals("incluir"))) {
            //populando o JavaBean
            cadprop.getProp().setRazaosocial(request.getParameter("nom"));
            cadprop.getProp().setBairro(request.getParameter("bairro"));
            cadprop.getProp().getCidade().setIdcidade(Integer.parseInt(request.getParameter("idCidade")));
            cadprop.getProp().setEndereco(request.getParameter("en"));
            cadprop.getProp().setCep(request.getParameter("cep"));
            cadprop.getProp().setFone1(request.getParameter("fone"));
            cadprop.getProp().setTipoCgc(request.getParameter("tipocgc"));
            cadprop.getProp().setDdd(Apoio.parseInt(request.getParameter("ddd")));
            cadprop.getProp().setCpfCnpj(request.getParameter("cpf"));
            cadprop.getProp().setCelular(request.getParameter("celular"));
            cadprop.getProp().setContato(request.getParameter("contato"));
            cadprop.getProp().setIdentInscest(request.getParameter("rg"));
            cadprop.getProp().setOrgaoInscmu(request.getParameter("orgaoemissor"));
            cadprop.getProp().setPisPasep(request.getParameter("pispasep"));
            cadprop.getProp().setContaBancaria(request.getParameter("conta_bancaria"));
            cadprop.getProp().setAgenciaBancaria(request.getParameter("agencia_bancaria"));
            cadprop.getProp().getSolucaoPedagio().setId(Apoio.parseInt(request.getParameter("solucaoPedagio")));

                    if(request.getParameter("banco_id") != null && request.getParameter("banco_id") != ""){
                cadprop.getProp().getBanco().setIdBanco(Integer.parseInt(request.getParameter("banco_id")));
            }
            cadprop.getProp().setNumeroRntrc(Apoio.parseLong(request.getParameter("numeroRntrc")));
            cadprop.getProp().setFavorecido(request.getParameter("favorecido"));
            cadprop.getProp().setPercentualDescontoSaldoFrete(Double.parseDouble(request.getParameter("percentualDesconto")));
            cadprop.getProp().setPercentualCtrcContratoFrete(Double.parseDouble(request.getParameter("percentualCTRC")));
            cadprop.getProp().setEmail(request.getParameter("email"));
            //O proprietario só sera optante pelo simples nacional se for pessoa juridica

                    
            cadprop.getProp().setOptanteSimplesNacional(request.getParameter("tipocgc").equals("J") && Apoio.parseBoolean(request.getParameter("isOptanteSimplesNacional")));

            if (request.getParameter("qtddependentes").equals("")) {
                cadprop.getProp().setQuantidadeDependentes(0);
            } else {
                cadprop.getProp().setQuantidadeDependentes(Integer.parseInt(request.getParameter("qtddependentes")));
            }

                    
            cadprop.getProp().setContaBancaria2(request.getParameter("conta_bancaria2"));
            cadprop.getProp().setAgenciaBancaria2(request.getParameter("agencia_bancaria2"));
                    if(request.getParameter("banco_id") != null && request.getParameter("banco_id2") != ""){
                cadprop.getProp().getBanco2().setIdBanco(Integer.parseInt(request.getParameter("banco_id2")));
            }

            cadprop.getProp().setFavorecido2(request.getParameter("favorecido2"));
            cadprop.getProp().setTac(Boolean.parseBoolean(request.getParameter("isTac")));
            cadprop.getProp().setCartaoPamcard(request.getParameter("cartaopamcard"));
            cadprop.getProp().setCartaoNdd(Apoio.parseLong(request.getParameter("cartaondd")));
            // o campo de cartão de ticket não é mais utilizada
            //cadprop.getProp().setCartaoTicketFrete(Long.parseLong((request.getParameter("cartaoticketfrete").equals("")? "0":request.getParameter("cartaoticketfrete"))));
            cadprop.getProp().setDataNascimento(Apoio.getFormatData(request.getParameter("datanascimentos")));
            cadprop.getProp().setNumeroLogradouro(request.getParameter("logradouro"));

            cadprop.getProp().setCriadoPor(Apoio.getUsuario(request));
            cadprop.getProp().setAlteradoPor(Apoio.getUsuario(request));

                    
                    
            cadprop.getProp().setTituloEleitor(request.getParameter("tituloeleitor"));
            cadprop.getProp().setZonaEleitoral(Apoio.parseInt(request.getParameter("zonaeleitoral")));
            cadprop.getProp().setSecaoEleitoral(Apoio.parseInt(request.getParameter("secaoeleitoral")));

            cadprop.getProp().setCartaoRepom(request.getParameter("cartaorepom"));

            cadprop.getProp().setCartaoExpers(request.getParameter("cartaoexpers"));
            //Mesmo com o nome de expers, o campo é comum a todos, independente de expers ou não.
            cadprop.getProp().setCartaoPagBem(request.getParameter("cartaopagBem"));
            cadprop.getProp().setTipoContaAdiantamentoExpers(request.getParameter("tipoContaAdiantamentoExpers"));
            cadprop.getProp().setTipoContaSaldoExpers(request.getParameter("tipoContaSaldoExpers"));
            cadprop.getProp().setCooperativa(Apoio.parseBoolean(request.getParameter("isCooperativa")));

            //Campos Aba responsável legal
            cadprop.getProp().setRespCpf(request.getParameter("respCpf"));
            cadprop.getProp().setRespNome(request.getParameter("respNome"));
            cadprop.getProp().setRespRG(request.getParameter("respRG"));
            cadprop.getProp().setRespRgOrgao(request.getParameter("respRgOrgao"));
            cadprop.getProp().setRespRgUf(request.getParameter("respRgUf"));
            cadprop.getProp().setRespRgEmissao(Apoio.getFormatData(request.getParameter("respRgEmissao")));
            cadprop.getProp().setRespDtNasc(Apoio.getFormatData(request.getParameter("respDtNasci")));
            cadprop.getProp().setRespEmail(request.getParameter("respEmail"));
            cadprop.getProp().setRespNomeMae(request.getParameter("respNomeMae"));
            cadprop.getProp().setRespNomePai(request.getParameter("respNomePai"));

                        cadprop.getProp().setNomeMae(request.getParameter("nomemae"));
                        cadprop.getProp().setNomePai(request.getParameter("nomepai"));
                        //19/07/2016
                        cadprop.getProp().setNumeroCNH(request.getParameter("cnh"));
                        cadprop.getProp().setCategoriaCNH(CategoriaCNH.getCategoriaCNH(request.getParameter("categoriaCnh")));
            cadprop.getProp().setEmissaoCNH(Apoio.getFormatData(request.getParameter("dataEmissaoCnh")));
            cadprop.getProp().setExpedicaoRG(Apoio.getFormatData(request.getParameter("dataExpedicaoRg")));
            cadprop.getProp().setPrimeiraCNH(Apoio.getFormatData(request.getParameter("dataPrimeiraCnh")));
            if (acao.equals("atualizar")) {
                cadprop.getProp().setIdfornecedor(Integer.parseInt(request.getParameter("id")));
                //-Está sendo executada 3 acoes aqui. 1º teste de acao, 2º teste de nivel,
                //3º teste de erro naquela acao executada.
            }
            cadprop.getProp().setNacionalidade(request.getParameter("nacionalidade"));
            cadprop.getProp().getCidadeNaturalidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeNaturalidade")));
            cadprop.getProp().setCartaoTarget(request.getParameter("cartaoTarget"));

            // 08/07/2018
            cadprop.getProp().setTipoDescontoContaCorrente(Apoio.parseInt(request.getParameter("tipoDescontoContaCorrente")));
            cadprop.getProp().setDataValidadeRntrc(Apoio.paraDate(request.getParameter("dataValidadeRntrc")));
            cadprop.getProp().setTipoControleContaCorrente(TipoControleContaCorrente.getTipoControleContaCorrente(request.getParameter("tipoControleContaCorrenteSelect")));

            cadprop.getProp().setIdsOcorrenciaExcluir(request.getParameter("ocorrenciaExcluir"));

            int maxOcorrencia = Apoio.parseInt(request.getParameter("maxOcorrencia"));

            if (maxOcorrencia != 0) {
                Ocorrencia ocorrenciaProp;
                for (int i = 0; i < maxOcorrencia; i++) {
                    if (request.getParameter("idOcorrencia_" + i) != null) {
                        ocorrenciaProp = new Ocorrencia();
                        BeanOcorrenciaCtrc ocorrencia = new BeanOcorrenciaCtrc();
                        ocorrencia.setId(Apoio.parseInt(request.getParameter("idOcorrenciaCTRC_" + i)));
                        ocorrenciaProp.setOcorrencia(ocorrencia);

                        ocorrenciaProp.setId(Apoio.parseInt(request.getParameter("idOcorrencia_" + i)));
                        ocorrenciaProp.setOcorrenciaEm(Apoio.getFormatData(request.getParameter("dataOcorrencia_" + i)));
                        ocorrenciaProp.setOcorrenciaAs(Apoio.getFormatTime(request.getParameter("horaOcorrencia_" + i)));
                        ocorrenciaProp.setObservacaoOcorrencia(request.getParameter("descricaoOcorrencia_" + i));
                        BeanUsuario usuarioOcorrencia = new BeanUsuario();
                        int idUsuarioOcorrencia = Apoio.parseInt(request.getParameter("idUsuarioInclusao_" + i));
                        usuarioOcorrencia.setIdusuario(idUsuarioOcorrencia);
                        ocorrenciaProp.setUsuarioOcorrencia(usuarioOcorrencia);
                        ocorrenciaProp.setResolvido(Apoio.parseBoolean(request.getParameter("resolvido_" + i)));
                        ocorrenciaProp.setResolucaoAs(Apoio.getFormatTime(request.getParameter("horaResolucao_" + i)));
                        ocorrenciaProp.setResolucaoEm(Apoio.getFormatData(request.getParameter("dataResolucao_" + i)));
                        ocorrenciaProp.setObservacaoResolucao(request.getParameter("descricaoResolucao_" + i));
                        BeanUsuario usuarioResolucao = new BeanUsuario();
                        int idUsuarioResolucao = Apoio.parseInt(request.getParameter("idUsuarioResolucao_" + i));
                        usuarioResolucao.setIdusuario(idUsuarioResolucao);
                        ocorrenciaProp.setUsuarioResolucao(usuarioResolucao);
                        cadprop.getProp().getOcorrenciaFornecedor().add(ocorrenciaProp);
                    }
                }
            }

            boolean erro = !((acao.equals("incluir") && nivelUser >= 3)
                    ? cadprop.Inclui() : cadprop.Atualiza());

            //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%><script language="javascript" type=""><%
                    if (erro) {
        acao = (acao.equals("atualizar") ? "editar" : "iniciar");%>

    //Tratamento de exeção, quando for cadastrado um proprietario que já tenha no banco
                        <%if(cadprop.getErros().indexOf("fornecedor_cpf_cnpj_key") > -1){
            cadprop.setErros("CNPJ/CPF já cadastrado como fornecedor! Para ativar esse mesmo "
                    + "como proprietário deverá ir em ' Cadastro/Financeiro/Fornecedor ' e marcar a opção de proprietário ");
        }%>

    //Mostra a mensagem de erro que vem do beanCadastro
    alert('<%=(cadprop.getErros())%>');
    <%} else {%>
    location.replace("ConsultaControlador?codTela=55");
    <%}%>
</script>
<%}

        if (acao.equals("getEnderecoByCep")) {
            WebServiceCep webServiceCep = WebServiceCep.searchCep(request.getParameter("cep"));
            String resposta = "";
            BeanConsultaCidade daoCidade = new BeanConsultaCidade();
            daoCidade.setConexao(Apoio.getUsuario(request).getConexao());
            int idCidade = daoCidade.localizarIdCidade(webServiceCep.getCidade(), webServiceCep.getUf());

            if (webServiceCep.wasSuccessful()) {
                String bairro = webServiceCep.getBairro().length() < 25 ? webServiceCep.getBairro().toUpperCase() : webServiceCep.getBairro().toUpperCase().substring(0, 24);

                resposta = "@@" + webServiceCep.getLogradouroFull().toUpperCase() + "@@"
                        + bairro + "@@"
                        + (idCidade != 0 ? webServiceCep.getCidade().toUpperCase() : "") + "@@"
                        + (idCidade != 0 ? idCidade : "0") + "@@"
                        + webServiceCep.getUf().toUpperCase();

                out.println(resposta);
                out.close();
            } else {
                resposta = "@@" + "@@" + "@@" + "@@" + "0@@";
                out.println(resposta);
                out.close();
            }
        }

                if(acao.equals("buscarResp")){
            String cpfResp = request.getParameter("respCpf");
            BeanProprietario resp = new BeanProprietario();
            cadprop = new BeanCadProprietario();
            cadprop.setConexao(Apoio.getUsuario(request).getConexao());
            cadprop.setExecutor(Apoio.getUsuario(request));

                    
                    try{
                resp = cadprop.buscarRespCpf(cpfResp);

                XStream xstream = XStream.getInstance(new JettisonMappedXmlDriver());
                xstream.setMode(XStream.NO_REFERENCES);
                xstream.alias("representante", resp.getClass());

                String json = xstream.toXML(resp);

                        
                response.getWriter().append(json);
                response.getWriter().close();

                    }catch(Exception e){
                e.printStackTrace();
            }

        }

    }
//variavel usada para saber se o usuario esta editando
    boolean carregaprop = (cadprop != null && (!acao.equals("incluir") || !acao.equals("atualizar")));

            
%>



<script language="javascript" type="text/javascript">

jQuery.noConflict();

arAbasGenerico = new Array();
arAbasGenerico[0] = new stAba('tdPrincipal', 'divInformacoes');
arAbasGenerico[1] = new stAba('tdAbaFinanceira', 'divInformacoesFinanceiras');
arAbasGenerico[2] = new stAba('tdAbaRespLegal', 'divResponsavelLegal');
arAbasGenerico[3] = new stAba('tdAbaAuditoria', 'divAuditoria');
arAbasGenerico[4] = new stAba('tdAbaOcorrencia', 'divOcorrencia');

    function validaRepom(){

    repom = document.getElementById("cartaorepom").value;

        if(isNaN(repom)){
            alert ("Digite Somente Números no Campo do Cartão Repom!");
        return false;
    }
//        else if((repom.length != 0) && (repom.length < 16)){
//            alert ("Digite Corretamente os 16 Dígitos do Cartão Repom!");
//            return false;
//        }

    return true;

}

    function getEnderecoByCep(cep){
        espereEnviar("",true);	  		
        new Ajax.Request("./jspcadproprietario.jsp?acao=getEnderecoByCep&cep="+ cep,
            {
            method:"get",
            onSuccess: function(transport){
                    var response = transport.responseText;
                    carregaCepAjax(response);
                },
            onFailure: function(){alert("Erro ao consultar o cep!");espereEnviar("",false);}
            });
}

    function carregaCepAjax(resposta){
    var rua = resposta.split("@@")[1];
        var bairro = resposta.split("@@")[2].replace('\u00A0','');
    var cidade = resposta.split("@@")[3];
    var idCidade = resposta.split("@@")[4];
    var uf = resposta.split("@@")[5];

        if(rua != "" && $("en").value.trim() == ""){
        $("en").value = rua;
        $("bairro").value = bairro;
        $("cidade").value = cidade;
        $("uf").value = uf;
        $("idCidade").value = idCidade;
        $("fone").focus();
        }else 
            if ($("en").value.trim() != rua){
        $("en").value = rua;
        $("bairro").value = bairro;
        $("cidade").value = cidade;
        $("uf").value = uf;
        $("idCidade").value = idCidade;
        $("fone").focus();
            }else{
        //Não faz nada por que o endereço é o mesmo.
    }

        espereEnviar("",false);	  		
}

function check() {
    var i = 1;
    if (!wasNull('rzs,abrev,cnpj'))
    {
            while (document.getElementById("ck"+i) != null)
        {
                if (document.getElementById("ck"+i).checked == true)
                return true;
            i++;
        }
        return false;
        }else
        return false;
}

    function atribuicombos(){


    <%if (carregaprop) {%>
    document.getElementById("tipocgc").value = "<%=cadprop.getProp().getTipoCgc()%>";
    if (document.getElementById("tipocgc").value == "F")
        //formatando o cpf
        document.getElementById("cpf").value = formatCpfCnpj("<%=(cadprop != null ? cadprop.getProp().getCpfCnpj() : "")%>", true, false);
    else
        //formatando o cnpj
        document.getElementById("cpf").value = formatCpfCnpj("<%=(cadprop != null ? cadprop.getProp().getCpfCnpj() : "")%>", true, true);

    //soluçao de pedagio
    document.getElementById("solucaoPedagio").value = "<%=cadprop.getProp().getSolucaoPedagio().getId()%>";
             if($("tipoContaAdiantamentoExpers")!=null && $("tipoContaAdiantamentoExpers")!= undefined){
        $("tipoContaAdiantamentoExpers").value = '<%=cadprop.getProp().getTipoContaAdiantamentoExpers()%>';
        $("tipoContaSaldoExpers").value = '<%=cadprop.getProp().getTipoContaSaldoExpers()%>';
    }

    <%}%>


}

        function voltar(){
    document.location.replace("ConsultaControlador?codTela=55");
}

        function salva(acao){
    var tipoCgc = $("tipocgc").value;
    var stUtilizacaoCte = '<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCte()%>';
    var isObrigaRNTRC = '<%=cfg.isRntrc()%>';
    var numeroRNTRC = document.getElementById("numeroRntrc").value;
    var respcpf = document.getElementById("respCpf").value;
    var cgc;

            if(isObrigaRNTRC == "true"){
                    if(numeroRNTRC == null || numeroRNTRC == "" || numeroRNTRC == 0){
            showErro("Informe o número do RNTRC!");
            return false;
        }
    }

            if(respcpf != null && respcpf.trim() != ""){
                if( document.getElementById("tipocgc").value == "J" && (!isCpf(respcpf) || respcpf.trim() == "" || respcpf == null)){
                    alert ("Cpf do Representante Legal está Inválido.");
                     AlternarAbasGenerico('tdAbaRespLegal','divResponsavelLegal');
            document.getElementById("respCpf").focus();
            return false;
                }else if(document.getElementById("tipocgc").value == "J" && (document.getElementById("respNome").value == null || document.getElementById("respNome").value.trim() == "" )){
                    alert ("Deve ser informado o nome do Representante Legal!");
                     AlternarAbasGenerico('tdAbaRespLegal','divResponsavelLegal');
            document.getElementById("respNome").focus();
            return false;
        }
    }

            if ( ! isCpf(document.getElementById("cpf").value) && document.getElementById("tipocgc").value == "F")
    {
                alert ("Cpf Inválido.");
        document.getElementById("cpf").focus();
            }
            else if (!isCnpj(document.getElementById("cpf").value) && document.getElementById("tipocgc").value == "J")
    {
                alert ("Cnpj Inválido.");
        document.getElementById("cpf").focus();
            }else 
    //Validação há mais, foi conversado com Daniel e o mesmo me informou que podemos salvar um proprietário sem informações da conta de adiantamento
                if($("banco_id").value != '' && $("conta_bancaria").value == '' || $("banco_id2").value != '' && $("conta_bancaria2").value == '' 
                    || $("banco_id").value == '' && $("conta_bancaria").value != '' || $("banco_id2").value == '' && $("conta_bancaria2").value != ''){
        alert("Informe o banco para pagamento de contrato de frete corretamente.");
            }else if (tipoCgc == 'F' && $("datanascimentos").value == "" && <%=cfg.isProprietarioDataNascimentoObrigatorio()%>){
                showErro("Informe a data de nascimento!",$("datanascimentos"));
            }else if ($("en").value == "" && <%=cfg.isProprietarioEnderecoObrigatorio()%>){
                showErro("Informe o logradouro!",$("en"));
            }else if (<%=cfg.isProprietarioValidaPis()%> && $("pispasep").value !== "" && !ChecaPIS()){
                showErro("Informe o número do pis corretamente!",$("pispasep"));
            }else if ($("logradouro").value == "" && <%=cfg.isProprietarioEnderecoObrigatorio()%>){
                showErro("Informe o número do logradouro!",$("logradouro"));
            }else if ($("idcidadeorigem").value == "" && <%=cfg.isProprietarioEnderecoObrigatorio()%>){
                showErro("Informe a cidade!",$("idcidadeorigem"));
            }else if ($("bairro").value == "" && <%=cfg.isProprietarioEnderecoObrigatorio()%>){
                showErro("Informe o bairro!",$("bairro"));
            }else if ($("fone").value == "" && <%=cfg.isProprietarioTelefoneObrigatorio()%>){
                showErro("Informe o telefone!",$("fone"));
            }else if (tipoCgc == 'F' && $("pispasep").value == "" && <%=cfg.isProprietarioPisPasepObrigatorio()%>){
                showErro("Informe o Pis/Pasep!",$("pispasep"));
            }else if (tipoCgc == 'F' && $("rg").value == "" && <%=cfg.isProprietarioRgOrgaoObrigatorio()%>){
                showErro("Informe o RG!",$("rg"));
            }else if (tipoCgc == 'F' && $("orgaoemissor").value == "" && <%=cfg.isProprietarioRgOrgaoObrigatorio()%>){
                showErro("Informe o Orgão Emissor!",$("orgaoemissor"));
            }else if(!validaRepom()){
        showErro("Número do Cartão Repom Inválido!", $("cartaorepom"));
            }else if($("rg").value.length < 2 || $("rg").value.length > 15){
                if(stUtilizacaoCte != 'N'){
                    if(tipoCgc == 'F'){
                alert("O R.G. Deve ser preenchido corretamente!");
                    }else{
                alert("A I.E. Deve ser preenchida corretamente!");
            }
                }else{
                    if(tipoCgc == 'F'){
                alert("O R.G. Deve ser preenchido corretamente! (Deve conter mais de 2 dígitos e menos de 15)");
                    }else{
                alert("A I.E. Deve ser preenchida corretamente! (Deve conter mais de 2 dígitos e menos de 15)");
            }
        }
            }
            else if (!wasNull('nom,cpf')) {

                   if (countOcorrenciaPropietario > 0) {
                    for (var i = 0; i < countOcorrenciaPropietario; i++) {
                        if ($('dataOcorrencia_'+ i)) {
                            let data = $('dataOcorrencia_'+ i).value;
                            let hora = $('horaOcorrencia_'+ i).value;

                            let resolvido = $('resolvido_'+ i).checked;
                            let dataResolucao = $('dataResolucao_'+ i).value;
                            let horaResolucao = $('horaResolucao_'+ i).value;

                            if (data === '' || hora === '') {
                                showErro('informe a data e hora da ocorrencia corretamente');
                                return false;
                            }

                            if (resolvido) {
                                if (dataResolucao === '' || horaResolucao === '') {
                                    showErro('informe a data e hora da resolução da ocorrencia corretamente');
                                    return false;
                                }
                            }

                            let dataOcorrencia = converterDataUSA(data);
                            let dataResolucaoOcorrencia = converterDataUSA(dataResolucao);
                            let dataAtual = new Date();
                            let horaAtual = dataAtual.getHours() + ':' + dataAtual.getMinutes();

                            if (dataOcorrencia > dataAtual) {
                                showErro('Data da ocorrência maior que a data atual');
                                return false;
                            } else if (data === '<%=Apoio.getDataAtual()%>' && hora > horaAtual) {
                                showErro('Hora da ocorrência maior que a hora atual');
                                return false;
                            } else if (dataOcorrencia > dataResolucaoOcorrencia) {
                                 showErro('Data da Resolução da ocorrência menor que a data da Ocorrência');
                                 return false;
                            } else if (data === dataResolucao && hora > horaResolucao) {
                                showErro('Hora da Resolução da ocorrência menor que a hora da Ocorrência');
                                return false;
                            } else if (dataResolucaoOcorrencia > dataAtual){
                                showErro('Data da Resolução da ocorrência maior que a data atual');
                                return false;
                            } else if (dataResolucao === '<%=Apoio.getDataAtual()%>' && horaResolucao > horaAtual) {
                                showErro('Hora da resolução maior que a hora atual');
                                return false;
                            }
                        }
                    }
                }



        document.getElementById("salvar").disabled = true;
        document.getElementById("salvar").value = "Enviando...";
        if (acao == "atualizar")
            acao += "&id=<%=(carregaprop ? cadprop.getProp().getIdfornecedor() : 0)%>";
        //verificando se é CPF ou CNPJ para formatar
        if (document.getElementById("tipocgc").value == "J")
                    cgc = formatCpfCnpj(document.getElementById("cpf").value,false,true);
        else
                    cgc = formatCpfCnpj(document.getElementById("cpf").value,false,false);
                console.log("text: "+document.getElementById("cartaopagBemText").value);
                console.log("select: "+document.getElementById("cartaopagBemSelect").value);


        var cartaoPagBem = (document.getElementById("cartaopagBemSelect").value == "" ? document.getElementById("cartaopagBemText").value : document.getElementById("cartaopagBemSelect").value);

        let form = document.getElementById('dom-ocorrencias');

        form.action = ("./cadproprietario?acao=" + acao +
                "&nom=" + encodeURIComponent(document.getElementById("nom").value) +
                "&tipocgc=" + document.getElementById("tipocgc").value +
                "&cpf=" + cgc +
                "&fone=" + document.getElementById("fone").value +
                "&email=" + document.getElementById("email").value +
                "&bairro=" + encodeURIComponent(document.getElementById("bairro").value) +
                "&idCidade=" + encodeURIComponent(document.getElementById("idCidade").value) +
                "&en=" + encodeURIComponent(document.getElementById("en").value) +
                "&cep=" + document.getElementById("cep").value +
                "&celular=" + document.getElementById("celular").value +
                "&rg=" + document.getElementById("rg").value +
                "&orgaoemissor=" + document.getElementById("orgaoemissor").value +
                "&pispasep=" + document.getElementById("pispasep").value +
                "&conta_bancaria=" + document.getElementById("conta_bancaria").value +
                "&agencia_bancaria=" + document.getElementById("agencia_bancaria").value +
                "&banco_id=" + document.getElementById("banco_id").value +
                "&numeroRntrc=" + numeroRNTRC +
                "&favorecido=" + document.getElementById("favorecido").value +
                "&contato=" + document.getElementById("contato").value +
                "&favorecido2=" + document.getElementById("favorecido2").value +
                "&conta_bancaria2=" + document.getElementById("conta_bancaria2").value +
                "&agencia_bancaria2=" + document.getElementById("agencia_bancaria2").value +
                "&banco_id2=" + document.getElementById("banco_id2").value +
                "&percentualDesconto=" + document.getElementById("percentualDesconto").value +
                "&percentualCTRC=" + document.getElementById("percentualCTRC").value +
                "&qtddependentes=" + document.getElementById("qtddependentes").value +
                "&isOptanteSimplesNacional=" + document.getElementById("isOptanteSimplesNacional").checked +
                "&isTac=" + document.getElementById("isTac").checked +
                "&cartaopamcard=" + document.getElementById("cartaopamcard").value +
                "&cartaondd=" + document.getElementById("cartaondd").value +
                // o campo de cartão de ticket não é mais utilizada
                //"&cartaoticketfrete=" + document.getElementById("cartaoticketfrete").value +
                "&datanascimentos=" + document.getElementById("datanascimentos").value +
                "&ddd=" + document.getElementById("ddd").value +
                "&logradouro=" + document.getElementById("logradouro").value +
                "&tituloeleitor=" + $("tituloeleitor").value +
                "&zonaeleitoral=" + $("zonaeleitoral").value +
                "&secaoeleitoral=" + $("secaoeleitoral").value +
                "&cartaorepom=" + document.getElementById("cartaorepom").value +
                "&solucaoPedagio=" + document.getElementById("solucaoPedagio").value +
                "&cartaoexpers=" + document.getElementById("cartaoexpers").value +
                "&cartaopagBem=" + (cartaoPagBem) +
                "&tipoContaAdiantamentoExpers=" + document.getElementById("tipoContaAdiantamentoExpers").value +
                "&tipoContaSaldoExpers=" + document.getElementById("tipoContaSaldoExpers").value +
                "&respCpf=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respCpf").value : "") +
                "&respNome=" + (document.getElementById("tipocgc").value == 'J' ? encodeURIComponent(document.getElementById("respNome").value) : "") +
                "&respRG=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respRG").value : "") +
                "&respRgOrgao=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respRgOrgao").value : "") +
                "&respRgUf=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respRgUf").value : "") +
                "&respRgEmissao=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respRgEmissao").value : "") +
                "&respDtNasci=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respDtNasci").value : "") +
                "&respEmail=" + (document.getElementById("tipocgc").value == 'J' ? document.getElementById("respEmail").value : "") +
                "&respNomeMae=" + (document.getElementById("tipocgc").value == 'J' ? encodeURIComponent(document.getElementById("respNomeMae").value) : "") +
                "&respNomePai=" + (document.getElementById("tipocgc").value == 'J' ? encodeURIComponent(document.getElementById("respNomePai").value) : "") +
                "&isCooperativa=" + document.getElementById("isCooperativa").checked +
                "&nomemae=" + encodeURIComponent(document.getElementById("nomemae").value) +
                "&nomepai=" + encodeURIComponent(document.getElementById("nomepai").value) +
                "&cnh=" + (document.getElementById("cnh").value) +
                "&idCidadeNaturalidade=" + (document.getElementById("idCidadeNaturalidade").value) +
                "&nacionalidade=" + (document.getElementById("nacionalidade").value) +
                "&cartaoTarget=" + encodeURIComponent(document.getElementById("cartaoTarget").value) +
                "&tipoDescontoContaCorrente=" + encodeURIComponent(document.getElementById("tipoDescontoContaCorrente").value) +
                "&tipoControleContaCorrenteSelect=" + encodeURIComponent(document.getElementById("tipoControleContaCorrenteSelect").value) +
                "&dataValidadeRntrc=" + encodeURIComponent(document.getElementById("dataValidadeRntrc").value) +
                "&dataEmissaoCnh=" + encodeURIComponent(document.getElementById("dataemissaocnh").value) +
                "&categoriaCnh="+encodeURIComponent(document.getElementById("categoriacnh").value)+
                "&dataPrimeiraCnh=" + encodeURIComponent(document.getElementById("primeiracnh").value) +
                "&dataExpedicaoRg=" + encodeURIComponent(document.getElementById("dataexpedicaorg").value) +
                "&" + jQuery("#form-ocorrencia").serialize()
                );

        form.method = "POST";
        form.submit();

    } else
        alert("Preencha os campos corretamente!");
}

        function excluirproprietario(idproprietario){
    if (confirm("Deseja mesmo excluir este proprietário?"))
    {
                location.replace("./consultaproprietario?acao=excluir&id="+idproprietario);
    }
}

//Localizar o motorista
        function localizamotorista(){
    document.getElementById("tipocgc").value = "F";
            post_cad = window.open('./localiza?acao=consultar&idlista=18','Motorista','top=80,left=10,height=400,width=1000,resizable=yes,status=3,scrollbars=1');
}

        function digitacao(){
    if (document.getElementById("tipocgc").value == "F")
        digitaCpf();
    else
        digitaCnpj();
}
        function changeLabel(valor){
    var lbTpCgc = $("lbTpCgc");
            if(valor == "F"){
        invisivel($("isOptanteSimplesNacional"));
        invisivel($("labOptSimplesNacional"));
                lbTpCgc.innerHTML = "<%=cfg.isProprietarioRgOrgaoObrigatorio()?"*":""%>R.G.:";
        visivel($("trDadosEleitorias"));
        visivel($("trDadosFamilia"));
        visivel($("trCNH"));
        visivel($("trNaturalidadeNacionalidade"));
        visivel($("dataexplabel"));
        visivel($("dataexpedicaorg"));
        visivel($("primeiracnh"));
        visivel($("categoriacnh"));
        visivel($("dataemissaocnh"));
            }else{
        visivel($("isOptanteSimplesNacional"));
        visivel($("labOptSimplesNacional"));
                lbTpCgc.innerHTML = "<%=cfg.isProprietarioRgOrgaoObrigatorio()?"*":""%>I.E.:";
        invisivel($("trDadosEleitorias"));
                $("tituloeleitor").value ="";
                $("zonaeleitoral").value ="";
                $("secaoeleitoral").value ="";
                invisivel($("trDadosFamilia"));
                $("nomemae").value ="";
                $("nomepai").value ="";
                invisivel($("trCNH"));
                $("cnh").value ="";
        invisivel($("trNaturalidadeNacionalidade"));
        limpaCidadeNaturalidade();
        invisivel($("dataexplabel"));
        $("dataexpedicaorg").value = "";
        invisivel($("dataexpedicaorg"));
        $("primeiracnh").value = "";
        invisivel($("primeiracnh"));
        $("categoriacnh").value = "";
        invisivel($("categoriacnh"));
        $("dataemissaocnh").value = "";
        invisivel($("dataemissaocnh"));

    }

}

        function getAjudaPercentual(){
    var mensagem = "Esse campo serve para o sistema calcular o valor do contrato de frete automaticamente ao incluir um CTRC, segue abaixo uma simulação:\n" +
                "1.000,00 = Valor do CTRC\n"+
                "   120,00 = Valor do ICMS\n"+
                "     50,00 = Valor do Seguro\n"+
                "   130,00 = Custo de viagem\n"+
                "   700,00 = Valor líquido\n"+
                "Nesse exemplo vamos utilizar 50%, sendo assim o valor do contrato de frete será 35,00.\n"+
                "Observações:\n"+
                "1) Essa funcionalidade só funcionará caso esteja habilitada em configurações a opção (Gerar contrato de frete automaticamente ao incluir um CTRC). \n"+
            "2) Esse percentual terá prioridade caso o valor do contrato de frete também esteja informado no cadastro de rota. \n";
    alert(mensagem);
}

        function getAjudaTac(){
    var mensagem = "Art. 3º - Equiparam-se ao TAC, a Empresa de Transporte Rodoviário de Cargas - ETC que possuir, em sua frota, até três veículos registrados no Registro Nacional de Transportadores de Cargas - RNTRC, e as Cooperativas de Transportes de Cargas - CTC.";
    alert(mensagem);
}

        function getANTT(){
    //window.open('http://rn3.antt.gov.br/system/Modulos/Transportador/tra00006.aspx', 'pop', '');
//            window.open('http://consultapublicarn3.antt.gov.br/Transportador.aspx', 'pop', '');
    window.open('http://consultapublicarntrc.antt.gov.br/consultapublica', 'pop', '');
}

// 12/07/13 - Função de Validar Pis
        function ChecaPIS(){

            var ftap="3298765432"; //pesos para multiplicar pelos algarismos do Pis
    var pispasep = document.getElementById("pispasep").value;
    if (pispasep.length < 11) { // esse é o tamanho de um numero pis(11 digitos)
        return false;
    }
    var resultado = "";
    var total = 0;
    var resto = 0;
    var numPIS = 0;
    var strResto = "";

    try {

        numPIS = pispasep.trim();

                if (numPIS == null || numPIS == undefined){

            return false;

        }

                for(i=0;i<=9;i++){

                    resultado = (numPIS.slice(i,i+1))*(ftap.slice(i,i+1));
            total = total + resultado;
        }


        resto = (total % 11)

                if (resto != 0){

            resto = 11 - resto;
        }

                if (resto==10 || resto==11){

            strResto = resto + "";
                    resto = strResto.slice(1,2);
        }

                if (resto!=(numPIS.slice(10,11))){

            return false;

        }
            }catch(e){
        alert(e);
    }

    return true;
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
    var rotina = "fornecedores";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = <%=(carregaprop ? cadprop.getProp().getIdfornecedor() : 0)%>;
    console.log(id);
    consultarLog(rotina, id, dataDe, dataAte);

}

        function setDataAuditoria(){


    var data = "<%=Apoio.getDataAtual()%>";
            console.log("data : "+data);
            $("dataDeAuditoria").value="<%=carregaprop ? Apoio.getDataAtual() :  "" %>" ;   
            $("dataAteAuditoria").value="<%=carregaprop ? Apoio.getDataAtual() : "" %>" ;   

}

        function aoClicarNoLocaliza(idjanela){
            if(idjanela == "Motorista") {
                if($("nom").value.length > 20){
                    $("contato").value = $("nom").value.substring(0,20);
                }else{
                    $("contato").value = $("nom").value;
                }
                $('idCidadeNaturalidade').value = $('id_cidade_naturalidade').value;
                $('cidNaturalidade').value = $('cid_naturalidade').value;
                $('ufNaturalidade').value = $('uf_naturalidade').value;
                $('idCidade').value = $('idcidadeorigem').value;
                $('cidade').value = $('cid_origem').value;
                $('uf').value = $('uf_origem').value;
            }
            
            //localizando cidade
            if (idjanela == "Cidade"){
        $('idCidade').value = $('idcidadeorigem').value;
        $('cidade').value = $('cid_origem').value;
        $('uf').value = $('uf_origem').value;
            } else if(idjanela == "Cidade_Naturalidade"){
        $('idCidadeNaturalidade').value = $('idcidadeorigem').value;
        $('cidNaturalidade').value = $('cid_origem').value;
        $('ufNaturalidade').value = $('uf_origem').value;
    } else if (idjanela == "Ocorrencia_Ctrc") {
        let usuario = '<%=Apoio.getUsuario(request).getNome()%>';
        let idUsuario = '<%=Apoio.getUsuario(request).getId()%>';
        let ocorrencia_id = $('ocorrencia_id').value;
        let ocorrencia = $('ocorrencia').value;
        let descricao_ocorrencia = $('descricao_ocorrencia').value;
        let dataAtual = '<%=Apoio.getDataAtual()%>';
        let horaAtual = '<%=Apoio.getHoraAtual()%>';
        let obrigaResolucao = $('obriga_resolucao').value;

        addNovaOcorrencia(idUsuario, usuario, ocorrencia_id, ocorrencia, descricao_ocorrencia, dataAtual, horaAtual, obrigaResolucao);
    }
}

        function importarEfrete(){
//            var cpfCnpj = $("cpf").value;
//            var rntrc = $("numeroRntrc").value;
//            
//            if(cpfCnpj == "" || cpfCnpj.trim() == ""){
//                alert("O campo 'CPF' não pode ficar vazio");
//                return false;
//            }
//            if(rntrc == "" || rntrc.trim() == ""){
//                alert("O campo 'RNTRC' não pode ficar vazio.");
//                return false;
//            }
//            //AJAX BUSCANDO O MOTORISTA NO EFRETE
//            espereEnviar("Aguarde...",true);
//            function e(transport){
//                var textoresposta = transport.responseText;
//                var propObj = jQuery.parseJSON(textoresposta);
//                var prop = propObj.proprietarioRetornado;
//                
//                if(prop.statusRetornoEfrete != null && prop.statusRetornoEfrete == ""){
//                    $("nom").value = prop.razaosocial;
//                    $("cpf").value = prop.cpfCnpj;
//                    $("numeroRntrc").value = prop.numeroRntrc;
//                    $("ddd").value = prop.ddd;
//                    $("fone").value = prop.fone1;
//                    $("celular").value = prop.celular;
//                    $("cep").value = prop.cep;
//                    $("logradouro").value = prop.numeroLogradouro;
//                    $("isTac").checked = prop.tac;                    
//                    getEnderecoByCep($("cep").value);                    
//                    alert("Proprietário importado com sucesso!");
//                    espereEnviar("Aguarde...",false);
//                }else{
//                    alert(prop.statusRetornoEfrete);
//                }
//                
//                
//                espereEnviar("Aguarde...",false);
//
//            }
//            tryRequestToServer(function(){
//                new Ajax.Request('EFreteControlador?acao=carregarProprietarioEFrete&cpfCnpj='+cpfCnpj+'&rntrc='+rntrc,{method:'post', onSuccess: e, onError: e});
//            });

            alert("ATENÇÃO! Na versão de integração 5.0 a opção de importar dados dos proprietários foi descontinuada pela E-Frete.");
        }
        
        
        
         function importarCartao(){
    var cpfCnpj = $("cpf").value;
    var rntrc = $("numeroRntrc").value;

            if(cpfCnpj == "" || cpfCnpj.trim() == ""){
        alert("O campo 'CPF' não pode ficar vazio");
        return false;
    }
            if(rntrc == "" || rntrc.trim() == ""){
        alert("O campo 'RNTRC' não pode ficar vazio.");
        return false;
    }
    //AJAX BUSCANDO O MOTORISTA NO EFRETE
            espereEnviar("Aguarde...",true);
            function e(transport){
        var textoresposta = transport.responseText;
        var propObj = jQuery.parseJSON(textoresposta);
        var prop = propObj.proprietarioRetornado;

                if(prop.statusRetornoEfrete != null && prop.statusRetornoEfrete == ""){
            $("nom").value = prop.razaosocial;

            alert("Cartão importado com sucesso!");
                    espereEnviar("Aguarde...",false);
                }else{
            alert(prop.statusRetornoEfrete);
        }


                espereEnviar("Aguarde...",false);

    }
            tryRequestToServer(function(){
                new Ajax.Request('EFreteControlador?acao=carregarProprietarioEFrete&cpfCnpj='+cpfCnpj+'&rntrc='+rntrc,{method:'post', onSuccess: e, onError: e});
    });
}


        function habiliarAbaRespLegal(){
    var tipocgc = $("tipocgc").value;
            if(tipocgc == "J"){
        visivel($("tdAbaRespLegal"));
        //    visivel($("divResponsavelLegal"));
            }else{
        invisivel($("tdAbaRespLegal"));
        //  invisivel($("divResponsavelLegal"));
    }
}

function formatDateJSON(objeto) {
    var dataBR = "";
    var data = "";

    if (objeto != undefined) {
        data = objeto.$;
        if (data != undefined) {
            var dia = data.split("-")[2];
            var mes = data.split("-")[1];
            var ano = data.split("-")[0];


            dataBR = dia + "/" + mes + "/" + ano;
        }
    }

    return dataBR;
}

        function buscarResp(){

    var respCpf = $("respCpf").value;
            if(respCpf != null || respCpf.trim() != ""){
                    if(isCpf(respCpf)){
            jQuery.ajax({
                url: './jspcadproprietario.jsp?',
                dataType: "text",
                    method : "post",
                data: {
                        acao : "buscarResp",
                        respCpf : respCpf
                },
                    success: function(data) {
                    var propObj = jQuery.parseJSON(data);
                    var representante = propObj.representante;

                    $("respNome").value = representante.respNome == undefined ? "" : representante.respNome;
                    $("respRG").value = representante.respRG == undefined ? "" : representante.respRG;
                    $("respRgOrgao").value = representante.respRgOrgao == undefined ? "" : representante.respRgOrgao;
                    $("respRgUf").value = representante.respRgUf == undefined ? "" : representante.respRgUf;
                    $("respRgEmissao").value = representante.respRgEmissao == undefined ? "" : formatDateJSON(representante.respRgEmissao);
                    $("respDtNasci").value = representante.respDtNasc == undefined ? "" : formatDateJSON(representante.respDtNasc);
                    $("respEmail").value = representante.respEmail == undefined ? "" : representante.respEmail;
                    $("respNomeMae").value = representante.respNomeMae == undefined ? "" : representante.respNomeMae;
                    $("respNomePai").value = representante.respNomePai == undefined ? "" : representante.respNomePai;
                },
                    error : function(data){
                    console.log("falha na requisição");

                }
            });
            }else{
            alert("Favor verificar CPF digitado!");
            $("respCpf").focus();
        }
    }else{
        alert("Favor preencher os 11 números do CPF!");
        $("respCpf").focus();
    }
}


function getCartaoContratadoPagBem() {

    function e(transport) {
        var textoresposta = transport.responseText;

        //se deu algum erro na requisicao...
        if (textoresposta == "-1") {
            alert('Houve algum problema ao requistar as rotas, favor tente novamente. ');
            return false;
        } else {

            console.log(jQuery.parseJSON(textoresposta));
            console.log(jQuery.parseJSON(textoresposta).cartao.isSucesso);

                        if(!jQuery.parseJSON(textoresposta).cartao.isSucesso){

                console.log("jQuery.parseJSON(textoresposta).cartao.isSucesso");

                var listErros = jQuery.parseJSON(textoresposta).cartao.erros[0]["br.com.gwsistemas.gwpagbem.excecao.Erros"];
                console.log(listErros);
                var length = (listErros != undefined && listErros.length != undefined ? listErros.length : 1);
                console.log(listErros.length);


                var mensagens = " Atenção! Mensagem do servidor PagBem: \n";
                for (var i = 0; i < length; i++) {
                    if (length > 1) {
                                    mensagens += listErros[i].codigo+ "-"+listErros[i].mensagem;    
                                    mensagens +="\n";
                    } else {
                                    mensagens += listErros[0].codigo+ "-"+listErros[0].mensagem;
                    }
                }

                alert(mensagens);
                return false;
                        }else{

                var listCartao = jQuery.parseJSON(textoresposta).cartao.resultado.cartoes[0]["br.com.gwsistemas.gwpagbem.cartoes.Cartoes"];
//                            var listCartao = jQuery.parseJSON(textoresposta).cartao.resultado.cartoes;

                console.log(jQuery.parseJSON(textoresposta).cartao.resultado.cartoes.length);


                var cartaoY;
                var slct = $("cartaopagBemSelect");

                var length = (listCartao != undefined && listCartao.length != undefined ? listCartao.length : 1);
                var valor;


                var listaTabelaRemAutomaticas = new Array();

                for (var i = 0; i < length; i++) {


                    if (length > 1) {
                        cartaoY = listCartao[i];

                    } else {
                        cartaoY = listCartao[0];
                    }


                                listaTabelaRemAutomaticas[i] = new Option(cartaoY.numeroCartao,cartaoY.numeroCartao);

                    if (cartaoY != null && cartaoY != undefined) {
                                    try{
                            $("cartaopagBemText").style.display = "none";
                                }catch(e){
                                    console.log("e: "+e);
                        }
                        // slct.appendChild(Builder.node('OPTION', {value: cartaoY.numeroCartao}, cartaoY.numeroCartao));
                        //                                if (length >= 1) {
                        //                                    console.log("legnht 1");
                        //                                    var teste = new Array('1','teste');
                        //                                    povoarSelect(slct, listaTabelaRemAutomaticas);
                        //                                    //slct.appendChild(Builder.node('OPTION', {value: cartaoY.numeroCartao}, cartaoY.numeroCartao));
                        //
                        //                                }


                    }
                }


                slct.style.display = "";
                console.log("lista : " + listaTabelaRemAutomaticas.length);
                console.log("lista valor : " + listaTabelaRemAutomaticas[0].valor);
                console.log("lista descricao : " + listaTabelaRemAutomaticas[0].descricao);
                povoarSelect(slct, listaTabelaRemAutomaticas);

            }
        }

    }//funcao e()

    var cpf = $("cpf").value;
                if(cpf==''){
                    if($("tipocgc").value=='J'){
            alert("CNPJ inválido!");
            return false;
                    }else{
            alert("CPF inválido! ");
            return false;

        }
    }

    tryRequestToServer(function () {
        new Ajax.Request("PagBemControlador?acao=carregarCartoesPagBem&cnpj=" + cpf, {method: 'post', onSuccess: e, onError: e});
    });
}


var windowCidade = null;

function localizaCidadeNaturalidade() {
        windowCidade = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade_Naturalidade',
            'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

    function localizaCidade(){
        windowCidade = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade',
            'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
}

    function limpaCidadeNaturalidade(){
    $("idCidadeNaturalidade").value = "0";
    $("cidNaturalidade").value = "";
    $("ufNaturalidade").value = "";
}

    function limpaCidade(){
    $("idCidade").value = "0";
    $("cidade").value = "";
    $("uf").value = "";
}

function resolveuOcorrencia(idx) {
    if ($('resolvido_' + idx).checked) {
        $('usuarioResolucao_' + idx).innerHTML = '<%=Apoio.getUsuario(request).getNome()%>';
        $('idUsuarioResolucao_' + idx).value = '<%=Apoio.getUsuario(request).getIdusuario()%>';
        $('dataResolucao_' + idx).value = '<%=Apoio.getDataAtual()%>';
        $('horaResolucao_' + idx).value = '<%=new SimpleDateFormat("HH:mm").format(new Date())%>';


        console.log($('idUsuarioResolucao_' + idx).value);

    } else {
        $('usuarioResolucao_' + idx).innerHTML = '';
        $('idUsuarioResolucao_' + idx).value = '';
        $('dataResolucao_' + idx).value = '';
        $('horaResolucao_' + idx).value = '';
    }
}

function importarCartaoTarget() {
    var cpf = $("cpf").value;

        if (cpf == "" || cpf.trim() == ""){
        alert("O campo 'CPF/CNPJ' não pode ficar vazio");
        return false;
    }

    // AJAX BUSCANDO O PROPRIETARIO NO TARGET
    espereEnviar("Aguarde...", true);

    function e(transport) {
        try {
            var textoresposta = transport.responseText;

            var proprietarioObj = jQuery.parseJSON(textoresposta);
            var proprietario = proprietarioObj.proprietarioRetornado;

            if (proprietario == undefined || proprietario == null) {
                alert('Ocorreu um erro interno de sistema!');
            } else if (proprietario.erro != null) {
                alert(proprietario.erro.mensagemErro);
            } else if (proprietario.idCliente == 0) {
                alert('Não foi encontrado o proprietário com CPF de ' + cpf + '!');
            } else {
                $("cpf").value = proprietario.cpfCnpj;
                $("nom").value = proprietario.nomeRazaoSocial;
                $("numeroRntrc").value = proprietario.rntrc;

                /*
                 * 1 = Pessoa Física
                 * 2 = Pessoa Jurídica
                 */
                if (proprietario.idDmTipoPessoa == 1) {
                    // Pessoa física
                    jQuery('#tipocgc').val('F');
                } else if (proprietario.idDmTipoPessoa == 2) {
                    // Pessoa jurídica
                    jQuery('#tipocgc').val('J');
                }

                /*
                 * 1 = Transportador Autônomo de Cargas TAC
                 * 2 = Empresa de Transporte Rodoviário de Cargas ETC
                 * 3 = Cooperativa de Transporte de Cargas CTC
                 * 4 = Transportador de Carga Própria TCP
                 * 5 = Embarcador EMB
                 */
                if (proprietario.idDmTipoTransportador == 1) {
                    $('isTac').checked = true;
                } else if (proprietario.idDmTipoTransportador == 3) {
                    $('isCooperativa').checked = true;
                }

                alert("Proprietario importado com sucesso!");
            }

            espereEnviar("Aguarde...", false);
        } catch (e) {
            console.log(e);

            alert("Ocorreu um erro ao importar Proprietário do servidor Target!");

            espereEnviar("Aguarde...", false);
        }
    }

        tryRequestToServer(function() {
        new Ajax.Request('TargetControlador?acao=carregarProprietario&cpf=' + cpf, {
                method:'post',
            onSuccess: e,
            onError: e
        });
    });
}

function aoCarregar() {

    <%
            if (carregaprop) {
                for (Ocorrencia oco : cadprop.getProp().getOcorrenciaFornecedor()) {%>
    var ocorrencia = new Ocorrencia();

    ocorrencia.idOcorrenciaCTRC = '<%=oco.getOcorrencia().getId()%>';
    ocorrencia.idOcorrencia = '<%=oco.getId()%>';
    ocorrencia.ocorrencia = '<%=oco.getOcorrencia().getCodigo()%>' + " - " + '<%=oco.getOcorrencia().getDescricao()%>';
    ocorrencia.dataInclusao = '<%=Apoio.getFormatData(oco.getInclusaEm())%>';
    ocorrencia.horaInclusao = '<%=Apoio.getFormatTimeParent(oco.getInclusaAS())%>';
    ocorrencia.dataOcorrencia = '<%=Apoio.getFormatData(oco.getOcorrenciaEm())%>';
    ocorrencia.horaOcorrencia = '<%=Apoio.getFormatTimeParent(oco.getOcorrenciaAs())%>';
    ocorrencia.descricaoOcorrencia = '<%=oco.getObservacaoOcorrencia()%>';
    ocorrencia.usuarioInclusao = '<%=oco.getUsuarioOcorrencia().getNome()%>';
    ocorrencia.idUsuarioInclusao = '<%=oco.getUsuarioOcorrencia().getIdusuario()%>';
    ocorrencia.resolvido = '<%=oco.isResolvido()%>';
    ocorrencia.resolvidoEm = '<%=Apoio.getFormatData(oco.getResolucaoEm())%>';
    ocorrencia.resolvidoAs = '<%=Apoio.getFormatTimeParent(oco.getResolucaoAs())%>';
    ocorrencia.descricaoResolucao = '<%=oco.getObservacaoResolucao()%>';
    ocorrencia.usuarioResolucao = '<%=oco.getUsuarioResolucao().getNome()%>';
    ocorrencia.idUsuarioResolucao = '<%=oco.getUsuarioResolucao().getIdusuario()%>';
    ocorrencia.obrigaResolucao = '<%=oco.getOcorrencia().isObrigaResolucao()%>';

    addDomOcorrencia(ocorrencia);
    <%
                }
            }
    %>

}

</script>
<html>
    <head>
        <script language="javascript" src="script/funcoes.js" type=""></script>

        <title>WebTrans - Cadastro de Proprietário</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache" />
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <link href="estilo.css" rel="stylesheet" type="text/css">
        <style type="text/css">
            <!--
            .style1 {font-size: 10px}
            -->
        </style>
    </head>  

    <body onLoad="javascript:aoCarregar();atribuicombos();
            document.getElementById('nom').focus();applyFormatter();changeLabel($('tipocgc').value);setDataAuditoria();AlternarAbasGenerico('tdPrincipal', 'divInformacoes');habiliarAbaRespLegal()">
        <form id="dom-ocorrencias" name="dom-ocorrencias">
        </form>
        <img src="img/banner.gif"  alt="">
        <input type="hidden" id="idcidadeorigem" value="0">
        <input type="hidden" id="uf_origem" value="0">
        <input type="hidden" id="cid_origem" value="0">
        <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="0">
        <input type="hidden" name="ocorrencia" id="ocorrencia">
        <input type="hidden" name="descricao_ocorrencia" id="descricao_ocorrencia">
        <input type="hidden" name="obriga_resolucao" id="obriga_resolucao">
        <input type="hidden" id="id_cidade_naturalidade" value="0">
        <input type="hidden" id="uf_naturalidade" value="0">
        <input type="hidden" id="cid_naturalidade" value="0">
        <br>
        <table width="70%" align="center" class="bordaFina" >
            <tr>
                <td width="613"><div align="left"><b>Cadastro de Propriet&aacute;rio </b></div></td>
                <%if(acao.equals("iniciar") && Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
                <td width="10%">
                    <div align="right">
                        <input name="importarEFrete" type="button" name="importarEFrete" value="Importar E-Frete" class="botoes" onclick="javascript:importarEfrete();"/>
                    </div>
                </td>
                <%}%>
                <%if((acao.equals("iniciar")) && Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "G".charAt(0)){%>
                <td width="10%">
                    <div align="right">
                        <input name="importarCartaoPagBem" type="button" name="importarCartaoPagBem" value="Importar PagBem" class="botoes" onclick="javascript:getCartaoContratadoPagBem();"/>
                    </div>
                </td>
                <%}%>
                    <%if((acao.equals("iniciar")) && Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "A".charAt(0)){%>
                <td width="10%">
                    <div align="right">
                        <input name="importarTarget" type="button" name="importarTarget" value="Importar Target" class="botoes" onclick="javascript:importarCartaoTarget();"/>
                    </div>
                </td>
                <%}%>
                <% if ((acao.equals("editar")) && (nivelUser >= 4) && (request.getParameter("ex") == null)) {%>
                <td width="15"><input name="excluir" type="button" class="botoes" id="excluir" value="Excluir" onClick="javascript:excluirproprietario(<%=(carregaprop ? cadprop.getProp().getIdfornecedor() : 0)%>)"></td>
                    <%}%>
                <td width="56" ><input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();"></td>
            </tr>
        </table>
        <br>
        <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
            <tr class="tabela">
                <td colspan="4" align="center">Dados principais </td>
            </tr>
            <tr>
                <td width="75" class="TextoCampos">*Nome:</td>
                <td class="CelulaZebra2"> <input name="nom" type="text" id="nom" value="<%=(carregaprop ? cadprop.getProp().getRazaosocial() : "")%>" size="45" maxlength="50" class="inputtexto"></td>
                <td width="107" class="TextoCampos">*
                    <select name="tipocgc" id="tipocgc" onChange="changeLabel(this.value),habiliarAbaRespLegal()" class="inputtexto">
                        <option value="F" selected>CPF</option>
                        <option value="J">CNPJ</option>
                    </select>
                    :</td>
                <td width="152" class="CelulaZebra2"><input name="cpf" type="text" id="cpf" size="18" maxlength="18" onKeyPress="javascript:digitacao();" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">CEP:</td>
                <td class="CelulaZebra2"><input name="cep" type="text" id="cep" value="<%=(carregaprop ? cadprop.getProp().getCep() : "")%>" onchange="getEnderecoByCep(this.value)"  size="16" maxlength="9" class="inputtexto"></td>
                <td class="TextoCampos"><%=cfg.isProprietarioDataNascimentoObrigatorio()?"*":""%>Data de nascimento:</td>
                <td class="CelulaZebra2">
                    <input value="<%=carregaprop ? cadprop.getProp().getDataNascimento() != null ? fmt.format(cadprop.getProp().getDataNascimento()) : "" : ""%>"   name="datanascimentos" type="text" id="datanascimentos" size="9" maxlength="10" onblur="alertInvalidDate(this,true)" class="fieldDate">
                </td>
            </tr>
            <tr>
                <td class="TextoCampos"><%=cfg.isProprietarioEnderecoObrigatorio()?"*":""%>Endere&ccedil;o:</td>
                <td class="CelulaZebra2">
                    <input name="en" type="text" id="en" value="<%=(carregaprop ? cadprop.getProp().getEndereco() : "")%>" size="35" maxlength="70" class="inputtexto">
                    <input name="logradouro" type="text" id="logradouro" value="<%=(carregaprop ? cadprop.getProp().getNumeroLogradouro() : "")%>" size="5" maxlength="10" class="inputtexto">
                </td>
                <td class="TextoCampos"><%=cfg.isProprietarioEnderecoObrigatorio()?"*":""%>Bairro:</td>
                <td class="CelulaZebra2"><input name="bairro" type="text" id="bairro" value="<%=(carregaprop ? cadprop.getProp().getBairro() : "")%>" size="25" maxlength="30" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos"><%=cfg.isProprietarioEnderecoObrigatorio()?"*":""%>Cidade:</td>
                <td class="CelulaZebra2">
                    <input name="cidade" type="text" id="cidade" size="35" class="inputReadOnly8pt" readonly="true" value="<%=(carregaprop && cadprop.getProp() != null ? cadprop.getProp().getCidade().getDescricaoCidade() : "")%>">
                    <input name="uf" type="text" id="uf" size="3" class="inputReadOnly8pt" readonly="true" value="<%=(carregaprop && cadprop.getProp() != null ? cadprop.getProp().getCidade().getUf() : "")%>">
                    <input name="btn"  type="button" class="botoes" id="btn" onClick="localizaCidade();" value="...">
                    <img src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaCidade();">
                    <input type="hidden" id="idCidade" name="idCidade" value="<%=(carregaprop && cadprop.getProp() != null ? cadprop.getProp().getCidade().getIdcidade() : "0")%>">
                </td>
                <td class="TextoCampos">Contato:</td>
                <td class="CelulaZebra2"><input name="contato" type="text" id="contato" value="<%=(carregaprop ? cadprop.getProp().getContato() : "")%>" size="18" maxlength="13" class="inputtexto"></td>
            </tr>
            <tr>

                <td class="TextoCampos"><%=cfg.isProprietarioTelefoneObrigatorio()?"*":""%>Telefone:</td>

                <td class="CelulaZebra2">
                    <input name="ddd" type="text" id="ddd"
                        value="<%=(carregaprop && cadprop.getProp().getDdd() != 0? cadprop.getProp().getDdd():"")%>" size="2" maxlength="2" class="inputtexto">
                    <input name="fone" type="text" id="fone" value="<%=(carregaprop ? cadprop.getProp().getFone1() : "")%>" size="18" maxlength="13" class="inputtexto">        </td>
                <td class="TextoCampos">Celular:</td>
                <td class="CelulaZebra2"><input name="celular" type="text" id="celular" value="<%=(carregaprop ? cadprop.getProp().getCelular() : "")%>" size="18" maxlength="13" class="inputtexto"></td>
            </tr>
            <tr>
                <td class="TextoCampos">Email:</td>
                <td class="CelulaZebra2"><input name="email" type="text" id="email" value="<%=(carregaprop ? cadprop.getProp().getEmail() : "")%>" size="45" maxlength="50" class="inputtexto"></td>

                <td class="TextoCamposNoAlign" align="left" colspan="2">
                    <input type="checkbox" value="true" id="isOptanteSimplesNacional" name="isOptanteSimplesNacional" <%=(carregaprop && cadprop.getProp().isOptanteSimplesNacional() ? "checked" : "")%> />
                    <label id="labOptSimplesNacional">Empresa optante pelo simples nacional</label>
                </td>
            </tr>
            <tr class="CelulaZebra2">
                <td class="TextoCampos">Dependentes:</td>
                <td><input name="qtddependentes" type="text" id="qtddependentes" value="<%=(carregaprop ? String.valueOf(cadprop.getProp().getQuantidadeDependentes()) : "0")%>" onKeyPress="javascript:digitaValores();" size="18" maxlength="13" class="inputtexto">
                    Apenas para pessoa f&iacute;sica</td>
                <td colspan="2"> <div align="center">
                        <%//executando a acao desejada
                            if (acao.equals("iniciar")) {%>
                        <input  name="localiza_motorista" type="button" class="botoes" id="localiza_motorista" onClick="javascript:localizamotorista();" value="Importar do motorista">
                        <%}%>
                    </div></td>
            </tr>
            <tr class="CelulaZebra2">
                <td class="TextoCampos">
                    <label id="lbTpCgc" ><%=cfg.isProprietarioRgOrgaoObrigatorio()?"*":""%>R.G.:</label><br>
                </td>
                <td class="CelulaZebra2">
                    <input name="rg" type="text" id="rg" value="<%=(carregaprop ? cadprop.getProp().getIdentInscest() : "")%>" size="18" maxlength="20" class="inputtexto">
                    /
                    <input name="orgaoemissor" type="text" id="orgaoemissor" value="<%=(carregaprop ? cadprop.getProp().getOrgaoInscmu() : "")%>" size="18" maxlength="15" class="inputtexto">
                    <label id="dataexplabel" style="padding-left:1em;">Expedição:</label>
                    <input name="dataexpedicaorg" type="text" id="dataexpedicaorg" value="<%=carregaprop ? cadprop.getProp().getExpedicaoRG() != null ? fmt.format(cadprop.getProp().getExpedicaoRG()) : "" : ""%>" size="10" maxlength="10" class="inputtexto" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onblur="alertInvalidDate(this,true);" />
                </td>
                <td class="TextoCampos"><%=cfg.isProprietarioPisPasepObrigatorio()?"*":""%>PIS/PASEP:      </td>
                <td class="CelulaZebra2"><input name="pispasep" type="text" id="pispasep" value="<%=(carregaprop ? cadprop.getProp().getPisPasep() : "")%>" size="18" maxlength="30" class="inputtexto"></td>
            </tr>
            <tr id="trDadosEleitorias" name="dadosEleitorias">
                <td class="TextoCampos" >Titulo de Eleitor:</td>
                <td class="CelulaZebra2" >
                    <input type="text" id="tituloeleitor" name="tituloeleitor" value="<%=(carregaprop && !(cadprop.getProp().getTituloEleitor() == "")? cadprop.getProp().getTituloEleitor() : "")%>"  size="13" maxlength="12" onkeypress="mascara(this,soNumeros)" class="inputTexto"> 
                </td>
                <td class="TextoCampos">Zona/Seção Eleitoral:</td> 
                <td class="CelulaZebra2"> 
                    <input type="text" id="zonaeleitoral" name="zonaeleitoral" value="<%=(carregaprop && (cadprop.getProp().getZonaEleitoral() != 0) ? cadprop.getProp().getZonaEleitoral() : "" ) %>" size="4" maxlength="3" onkeypress="mascara(this,soNumeros)" class="inputTexto"> 
                    /<input type="text" id="secaoeleitoral" name="secaoeleitoral" value="<%=(carregaprop && (cadprop.getProp().getSecaoEleitoral() != 0) ? cadprop.getProp().getSecaoEleitoral() : "" )%>" size="4" maxlength="3" onkeypress="mascara(this,soNumeros)" class="inputTexto"> 
                </td>
            </tr>
            <tr id="trCNH" name="trCNH">
                <td class="TextoCampos"> Número CNH:</td>
                <td class="CelulaZebra2" colspan="3">
                    <input type="text" id="cnh" name="cnh" size="15" maxlength="15"  onkeypress="seNaoIntReset(this, '');" class="inputtexto" value="<%=( carregaprop && cadprop.getProp().getNumeroCNH() != null ? cadprop.getProp().getNumeroCNH() : "") %>">

                    <label id="lbTpCgc" style="padding-left:1em;">Emissão:</label>
                <input name="dataemissaocnh" type="text" id="dataemissaocnh" value="<%=carregaprop ? cadprop.getProp().getEmissaoCNH()!= null ? fmt.format(cadprop.getProp().getEmissaoCNH()) : "" : ""%>" size="15" maxlength="15" class="inputtexto" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onblur="alertInvalidDate(this,true);">
                    <label id="lbTpCgc" style="padding-left:1em;">Primeira CNH: </label>
                <input name="primeiracnh" type="text" id="primeiracnh" value="<%=carregaprop ? cadprop.getProp().getPrimeiraCNH()!= null ? fmt.format(cadprop.getProp().getPrimeiraCNH()) : "" : ""%>" size="15" maxlength="15" class="inputtexto" onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onblur="alertInvalidDate(this,true);">
                    <label id="lbTpCgc" style="padding-left:1em;">Categoria:</label>
                    <select name="categoriacnh" id="categoriacnh" class="inputtexto"  style="width: 154px">
                        <option value=""></option>
                        <c:set var="cadprop" value="<%=cadprop%>" />
                        <c:forEach var="cat"  items="<%=CategoriaCNH.values()%>">
                            <option value="${cat.categoriaCNH}" ${(cadprop != null &&cat eq (cadprop.prop.categoriaCNH))? 'selected' : ''}  >${fn:toUpperCase(cat.categoriaCNH)}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr id="trDadosFamilia" name="dadosFamilia">
                <td class="TextoCampos" >Nome da mãe:</td>
                <td class="CelulaZebra2" >
                    <input type="text" id="nomemae" name="nomemae" value="<%=(carregaprop && cadprop.getProp().getNomeMae() != null? cadprop.getProp().getNomeMae() : "")%>"  size="40" maxlength="40" class="inputTexto">
                </td>
                <td class="TextoCampos">Nome do pai:</td> 
                <td class="CelulaZebra2"> 
                    <input type="text" id="nomepai" name="nomepai" value="<%=(carregaprop && cadprop.getProp().getNomePai() != null? cadprop.getProp().getNomePai() : "" ) %>" size="40" maxlength="40" class="inputTexto">
                </td>
            </tr>
            <tr id="trNaturalidadeNacionalidade" name="trNaturalidadeNacionalidade">
                <td class="TextoCampos" >Naturalidade:</td>
                <td width="277" class="CelulaZebra2">
                    <input name="cidNaturalidade" type="text" id="cidNaturalidade" size="30" class="inputReadOnly8pt" readonly="true" value="<%=(carregaprop && cadprop.getProp() != null ? cadprop.getProp().getCidadeNaturalidade().getDescricaoCidade(): "")%>">
                    <input name="ufNaturalidade" type="text" id="ufNaturalidade" size="3" class="inputReadOnly8pt" readonly="true" value="<%=(carregaprop && cadprop.getProp() != null ? cadprop.getProp().getCidadeNaturalidade().getUf() : "")%>">
                    <input name="btn_origem"  type="button" class="botoes" id="btn_origem" onClick="localizaCidadeNaturalidade();" value="...">
                    <img src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaCidadeNaturalidade();">
                    <input type="hidden" id="idCidadeNaturalidade" name="idCidadeNaturalidade" value="<%=(carregaprop && cadprop.getProp() != null ? cadprop.getProp().getCidadeNaturalidade().getIdcidade() : "0")%>">
                <td class="TextoCampos">Nacionalidade:</td> 
                <td class="CelulaZebra2"> 
                    <input type="text" id="nacionalidade" name="nacionalidade" value="<%=(carregaprop && cadprop.getProp().getNacionalidade() != null ? cadprop.getProp().getNacionalidade() : "")%>" size="40" maxlength="40" class="inputTexto">
                </td>
            </tr>
        </table>
        <table width="70%" align="center" cellpadding="2" cellspacing="1">
            <tr>
                <td width="100%">
                    <table align="left">
                        <tr>
                            <td id="tdPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdPrincipal', 'divInformacoes')"> Informações Operacionais</td>
                            <td id="tdAbaFinanceira" class="menu" onclick="AlternarAbasGenerico('tdAbaFinanceira', 'divInformacoesFinanceiras')"> Informações Financeiras </td>
                            <td id="tdAbaOcorrencia" class="menu" onclick="AlternarAbasGenerico('tdAbaOcorrencia', 'divOcorrencia')">Ocorrências</td>
                            <td style='display: none' id="tdAbaRespLegal" class="menu" onclick="AlternarAbasGenerico('tdAbaRespLegal', 'divResponsavelLegal')"> Representante Legal </td>
                            <td style='display: <%=carregaprop && nivelUser == 4 ? "" : "none"%>' id="tdAbaAuditoria" class="menu" onclick="AlternarAbasGenerico('tdAbaAuditoria', 'divAuditoria')"> Auditoria</td>

                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <div id="divInformacoes" >
            <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td colspan="3">
                        <table width="100%">
                            <tr>
                                <td width="30%" class="TextoCampos">% Desconto conta corrente:</td>
                                <td width="40%" class="CelulaZebra2">
                                    <input name="percentualDesconto" type="text" id="percentualDesconto" size="4"
                                           maxlength="6"
                                           value="<%=(carregaprop ? Apoio.to_curr(cadprop.getProp().getPercentualDescontoSaldoFrete()) : Apoio.to_curr(cfg.getPercentualPadraoDescontoContaCorrente()))%>"
                                       onChange="seNaoFloatReset(this,'0.00')" class="inputtexto">
                                    <select class="inputtexto" id="tipoDescontoContaCorrente" name="tipoDescontoContaCorrente">
                                        <option value="1" <%=(carregaprop && cadprop.getProp().getTipoDescontoContaCorrente() == 1 ? "selected" : !carregaprop && cfg.getTipoDescontoContaCorrente() == 1 ? "selected" : "")%>>
                                            Sobre o saldo do frete
                                        </option>
                                        <option value="2" <%=(carregaprop && cadprop.getProp().getTipoDescontoContaCorrente() == 2 ? "selected" : !carregaprop && cfg.getTipoDescontoContaCorrente() == 2 ? "selected" : "")%>>
                                            Sobre o valor do frete
                                        </option>
                                    </select>
                                </td>
                                <td class="CelulaZebra2" width="30%">
                                    <label>Controlar o conta corrente</label>

                                    <select name="tipoControleContaCorrenteSelect" id="tipoControleContaCorrenteSelect" class="inputtexto">
                                        <c:forEach var="tp"  items="<%=TipoControleContaCorrente.values()%>">
                                            <option value="${tp.tipoControleContaCorrente}" ${(cadprop != null && tp eq cadprop.prop.tipoControleContaCorrente) ? 'selected' : ''}  >
                                                ${fn:toLowerCase(tp)}
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <label>por placa</label>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" colspan='2'>% do valor do CTRC (Valor do frete - ICMS - seguro - custo de viagem) aplicado ao gerar um contrato de frete:</td>
                                <td class="CelulaZebra2">
                                <input name="percentualCTRC" type="text" id="percentualCTRC" size="4" maxlength="6" value="<%=(carregaprop ? Apoio.to_curr(cadprop.getProp().getPercentualCtrcContratoFrete()) : "0.00")%>" onChange="seNaoFloatReset(this,'0.00')" class="inputtexto">
                                    <img src="img/ajuda.png" border="0" title="Clique aqui pra saber a utilidade desse campo." align="absbottom" class="imagemLink" onClick="javascript:getAjudaPercentual();">
                                </td>
                            </tr>

                        </table>
                    </td>
                </tr>
                <tr class="CelulaZebra2">
                    <td colspan="4" class="tabela"><div align="center">Informa&ccedil;&otilde;es CT-e/Contrato de Frete Eletrônico</div></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <table width="100%">
                            <tr>
                                <td width="13%" class="TextoCampos">RNTRC:</td>
                            <td width="9%" class="CelulaZebra2"><input name="numeroRntrc" type="text" id="numeroRntrc" size="10" maxlength="25" value="<%=(carregaprop && cadprop.getProp().getNumeroRntrc() != 0 ? cadprop.getProp().getNumeroRntrc() : "")%>" onChange="seNaoIntReset(this,'')" onkeypress="mascara(this, soNumeros)" class="inputtexto"></td>
                                <td width="17%" class="TextoCampos">Validade RNTRC:</td>
                                <td width="9%" class="CelulaZebra2">
                                    <input name="dataValidadeRntrc" type="text" id="dataValidadeRntrc"
                                           size="10" maxlength="10" class="inputtexto"
                                           value="<%=(carregaprop && cadprop.getProp().getDataValidadeRntrc() != null ? cadprop.getProp().getDataValidadeRntrc() : "")%>"
                                           onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)">
                                </td>
                                <td width="37%" class="TextoCampos" colspan="4"><div align="center">
                                        <input type="checkbox" name="isTac" id="isTac" <%=(carregaprop && cadprop.getProp().isTac() ? "checked" : "")%>>
                                        <label for="isTac">TAC (Transportador Autônomo de Cargas)</label>
                                        &nbsp;&nbsp;&nbsp;<img src="img/ajuda.png" border="0" title="Clique aqui pra saber a utilidade desse campo." align="absbottom" class="imagemLink" onClick="javascript:getAjudaTac();">
                                        &nbsp;&nbsp;&nbsp;<img height="25" src="img/antt.gif" border="0" title="Clique aqui para consultar o transportador no site da ANTT." align="absbottom" class="imagemLink" onClick="javascript:getANTT();">
                                    </div></td>
                                <td width="15%" class="TextoCampos"><div align="center">
                                <input name="isCooperativa" type="checkbox" id="isCooperativa" <%=(carregaprop && cadprop.getProp().isCooperativa()? "checked" : "")%> class="checkbox">
                                        <label for="isCooperativa">É uma cooperativa</label></div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Cart&atilde;o Pamcard:</td>
                                <td class="CelulaZebra2">
                                    <input name="cartaopamcard" type="text" id="cartaopamcard" value="<%=(carregaprop ? cadprop.getProp().getCartaoPamcard() : "")%>" size="10" maxlength="16" class="inputtexto"/>
                                </td>
                                <td class="TextoCampos" style="text-align: right">Cart&atilde;o NDD:
                                </td><td class="CelulaZebra2">
                                <input name="cartaondd" type="text" id="cartaondd" value="<%=(carregaprop && cadprop.getProp().getCartaoNdd() != 0 ? cadprop.getProp().getCartaoNdd() : "")%>" onkeypress="mascara(this,soNumeros)" size="10" maxlength="16" class="inputtexto"/>
                                </td>
                                <td class="TextoCampos">Cartão Repom:</td>
                                <td class="CelulaZebra2" colspan="4">
                                <input type="text" id="cartaorepom" name="cartaorepom" size="16" maxlength="16" class="inputtexto" onkeypress="mascara(this,soNumeros)" value="<%=(carregaprop && !(cadprop.getProp().getCartaoRepom() == null) ? cadprop.getProp().getCartaoRepom() : "")%>" onblur="validaRepom()">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Cartão ExpeRS:</td>
                                <td class="CelulaZebra2">
                                <input type="text" id="cartaoexpers" name="cartaoexpers" size="10" maxlength="10" class="inputtexto" onkeypress="mascara(this,soNumeros)" value="<%=(carregaprop && !(cadprop.getProp().getCartaoExpers()== null) ? cadprop.getProp().getCartaoExpers() : "")%>">
                                </td>
                                <td class="TextoCampos">Cartão PagBem:</td>
                                <td class="CelulaZebra2">
                                <input type="text" id="cartaopagBemText" name="cartaopagBemText" size="10" maxlength="15" class="inputtexto" onkeypress="mascara(this,soNumeros)" value="<%=(carregaprop && !(cadprop.getProp().getCartaoPagBem()== null) ? cadprop.getProp().getCartaoPagBem() : "")%>">
                                <select style="display: none" id="cartaopagBemSelect" name="cartaopagBemSelect" onChange="changeLabel(this.value),habiliarAbaRespLegal()" class="inputtexto">

                                    </select>
                                </td>
                                <td class="TextoCampos">Cartão Target:</td>
                                <td class="CelulaZebra2" colspan="4">
                                    <input type="text" id="cartaoTarget" name="cartaoTarget" size="16"
                                           maxlength="16" class="inputtexto" onkeypress="mascara(this, soNumeros)"
                                       value="<%=(carregaprop && !(cadprop.getProp().getCartaoTarget()== null) ? cadprop.getProp().getCartaoTarget() : "")%>">
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Soluç&atilde;o de ped&aacute;gio:</td>
                                <td class="CelulaZebra2" colspan="8">
                                    <select name="solucaoPedagio" id="solucaoPedagio" class="inputtexto">
                                        <option value="0">Selecione</option>
                                        <%solucoesPedagioBO = new SolucoesPedagioBO();

                                            Collection<SolucoesPedagio> solucoesPedagio = solucoesPedagioBO.mostrarTodos(true, Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe());

                                               for (SolucoesPedagio pedagio : solucoesPedagio){

                                                pedagio.getCodigo();
                                                pedagio.getDescricao();
                                                pedagio.getId();


                                            
                                            
                                        %>
                                        <option value="<%=pedagio.getId()%>"><%=pedagio.getCodigo() + "-" + pedagio.getDescricao()%></option>
                                        <%}%>
                                    </select>
                                </td>
                            </tr>
                        <tr class="CelulaZebra2" style="<%=Apoio.getUsuario(request).getFilial().getStUtilizacaoCfeS().equals("X")? "" :  "display: none"%>" >
                                <td colspan="7" class="tabela"><div align="center">Consulta ANTT</div></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Situação ANTT: </td>
                                <td class="CelulaZebra2" colspan="1"><%=(carregaprop && (cadprop.getProp().isSituacaoAntt()) ? "Ativo" : "Inativo")%></td>
                                <td class="TextoCampos">Data/Hora Última Consulta: </td>
                            <td class="CelulaZebra2" colspan="2"><%=((carregaprop &&  !cadprop.getProp().getDataConsultaExpers().equals(""))? cadprop.getProp().getDataConsultaExpers()+" "+cadprop.getProp().getHoraConsultaExpers(): "")%></td>
                                <td class="TextoCampos">Usuário Consulta: </td>
                            <td class="CelulaZebra2" colspan="3"><%=(carregaprop && (cadprop.getProp().getUsuarioConsultaExpers().getIdusuario()!=0) ? cadprop.getProp().getUsuarioConsultaExpers().getNome() : "")%></td>

                            </tr>


                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <div id="divOcorrencia" name="divOcorrencia">
            <form id="form-ocorrencia" name="form-ocorrencia">
                <input type="hidden" name="maxOcorrencia" id="maxOcorrencia">
                <input type="hidden" name="ocorrenciaExcluir" id="ocorrenciaExcluir">
                <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                    <tr>
                        <td colspan="4">
                            <table width="100%" align="center" class="bordaFina">
                                <tr class="tabela">
                                    <td>
                                        <div align="center"
                                             <strong>Adicionar Ocorr&ecirc;ncia</strong>
                                        </div>
                                    </td>
                                </tr>
                                <tr name="trOcorrencia" id="trOcorrencia">
                                    <td colspan="3">
                                        <table align="center" width="100%" class="bordaFina">
                                            <tbody  id="tbOcorrenciaProp" name="tbOcorrenciaProp">
                                                <tr class="celulaZebra1">
                                                    <td width="10" align="center" class="celula">
                                                        <img class="imagemLink" width="20px" src="img/add.gif" alt="addCampo" name="imgLixo" id="imgLixo" onClick="novaOcorrencia();">
                                                    </td>
                                                    <td align="center" width="20%">Ocorrência</td>
                                                    <td align="center" width="10%">Data/Hora da inclusão</td>
                                                    <td align="center" width="10%">Data/Hora da ocorrência</td>
                                                    <td align="center" width="10%">Descrição da ocorrência</td>
                                                    <td align="center" width="10%">Usuário inclusão</td>
                                                    <td align="center" width="6%">Resolvida</td>
                                                    <td align="center" width="10%">Data/hora da resolução</td>
                                                    <td align="center" width="10%">Descrição da resolução</td>
                                                    <td align="center" width="10%">Usuário resolução</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </form>
        </div>

        <div id="divInformacoesFinanceiras" >
            <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td colspan="4">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr class="CelulaZebra2">
                                <td colspan="6" class="Celula"><div align="center">Dados bancários de adiantamento</div></td>
                            </tr>
                            <tr>
                                <td width="21%" class="TextoCampos">Conta banc&aacute;ria:</td>
                                <td width="14%" class="CelulaZebra2"><input name="conta_bancaria" type="text" id="conta_bancaria" size="13" maxlength="15" value="<%=(carregaprop ? cadprop.getProp().getContaBancaria() : "")%>" class="inputtexto"></td>
                                <td width="11%" class="TextoCampos">Ag&ecirc;ncia:</td>
                                <td width="15%" class="CelulaZebra2"><input name="agencia_bancaria" type="text" id="agencia_bancaria" size="13" maxlength="15" value="<%=(carregaprop ? cadprop.getProp().getAgenciaBancaria() : "")%>" class="inputtexto"></td>
                                <td width="8%" class="TextoCampos">Banco:</td>
                                <td width="31%" class="CelulaZebra2">
                                    <select name="banco_id" id="banco_id" class="inputtexto">
                                        <option value="">Selecione</option>
                                        <% BeanConsultaBanco banco = new BeanConsultaBanco();
                                            banco.setConexao(Apoio.getUsuario(request).getConexao());
                                            banco.MostrarTudo();
                                            ResultSet rs = banco.getResultado();
                                            while (rs.next()) {%>
                                        <option value="<%=rs.getString("idbanco")%>" <%=(carregaprop && rs.getInt("idbanco") == cadprop.getProp().getBanco().getIdBanco() ? "selected" : "")%>  ><%=rs.getString("numero") + "-" + rs.getString("descricao")%></option>
                                        <%}%>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Favorecido:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <input name="favorecido" type="text" id="favorecido" size="50" maxlength="50" value="<%=(carregaprop ? cadprop.getProp().getFavorecido() : "")%>" class="inputtexto"></td>

                                <td class="TextoCampos">Tipo:</td>
                                <td class ="CelulaZebra2">
                                    <select name="tipoContaAdiantamentoExpers" id="tipoContaAdiantamentoExpers" style="width:130px" class="fieldMin">

                                        <option value="c" <%=(carregaprop && cadprop.getProp().getTipoContaAdiantamentoExpers().equals("c") ? "selected" : "")%>>Conta Corrente</option>
                                        <option value="p" <%=(carregaprop && cadprop.getProp().getTipoContaAdiantamentoExpers().equals("p") ? "selected" : "")%>>Conta Poupança</option>
                                    </select>
                                </td>
                            </tr>


                        </table>
                    </td>
                </tr>

                <tr>
                    <td colspan="4">
                        <table width="100%" border="0" cellspacing="1" cellpadding="2">
                            <tr class="CelulaZebra2">
                                <td colspan="6" class="Celula"><div align="center">Dados bancários de saldo</div></td>
                            </tr>
                            <tr>
                                <td width="21%" class="TextoCampos">Conta banc&aacute;ria:</td>
                                <td width="14%" class="CelulaZebra2"><input name="conta_bancaria2" type="text" id="conta_bancaria2" size="13" maxlength="15" value="<%=(carregaprop ? cadprop.getProp().getContaBancaria2() : "")%>" class="inputtexto"></td>
                                <td width="11%" class="TextoCampos">Ag&ecirc;ncia:</td>
                                <td width="15%" class="CelulaZebra2"><input name="agencia_bancaria2" type="text" id="agencia_bancaria2" size="13" maxlength="15" value="<%=(carregaprop ? cadprop.getProp().getAgenciaBancaria2() : "")%>" class="inputtexto"></td>
                                <td width="8%" class="TextoCampos">Banco:</td>
                                <td width="31%" class="CelulaZebra2">
                                    <select name="banco_id2" id="banco_id2" class="inputtexto">
                                        <option value="">Selecione</option>
                                        <% banco = new BeanConsultaBanco();
                                            banco.setConexao(Apoio.getUsuario(request).getConexao());
                                            banco.MostrarTudo();
                                            rs = banco.getResultado();
                                            while (rs.next()) {%>
                                        <option value="<%=rs.getString("idbanco")%>" <%=(carregaprop && rs.getInt("idbanco") == cadprop.getProp().getBanco2().getIdBanco() ? "selected" : "")%>  ><%=rs.getString("numero") + "-" + rs.getString("descricao")%></option>
                                        <%}%>
                                    </select></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Favorecido:</td>
                                <td class="CelulaZebra2" colspan="3">
                                    <input name="favorecido2" type="text" id="favorecido2" size="50" maxlength="50" value="<%=(carregaprop ? cadprop.getProp().getFavorecido2() : "")%>" class="inputtexto">
                                </td>
                                <td class="TextoCampos">Tipo:</td>
                                <td class ="CelulaZebra2" >
                                    <select name="tipoContaSaldoExpers" id="tipoContaSaldoExpers" style="width:130px" class="fieldMin">

                                        <option value="c" <%=(carregaprop && cadprop.getProp().getTipoContaAdiantamentoExpers().equals("c") ? "selected" : "")%>>Conta Corrente</option>
                                        <option value="p" <%=(carregaprop && cadprop.getProp().getTipoContaAdiantamentoExpers().equals("p") ? "selected" : "")%>>Conta Poupança</option>
                                    </select>
                                </td>
                            </tr>

                        </table></td>
                </tr>
            </table>
        </div>
        <div id="divResponsavelLegal">
            <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina">
                <tr>
                    <td class="Celula" colspan="8">
                        <div align="center">Dados Cadastrais</div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" >CPF:</td>
                    <td class="CelulaZebra2" colspan="7">
                        <input name="respCpf" type="text" id="respCpf" size="11" maxlength="11" value="<%=(carregaprop ? cadprop.getProp().getRespCpf() == null ? "" : cadprop.getProp().getRespCpf() : "")%>" class="inputtexto" onkeypress="seNaoIntReset(this, '');" >
                        <img id="btnCPF" name="btnCPF" type="button" class="imagemLink" src="img/lupa.gif" onclick="javascript: buscarResp();" title="Pesquisar CPF"/><label><b>Pesquisar Representante Legal já Cadastrado</b></label>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">RG:</td>
                    <td class="CelulaZebra2">
                        <input name="respRG" type="text" id="respRG" size="15" maxlength="15" value="<%=(carregaprop ? cadprop.getProp().getRespRG()  == null ? "" : cadprop.getProp().getRespRG() : "")%>" class="inputtexto">
                    </td>
                    <td class="TextoCampos" >Orgão emissor do RG:</td>
                    <td class="CelulaZebra2">
                        <input name="respRgOrgao" type="text" id="respRgOrgao" size="5" maxlength="5" value="<%=(carregaprop ? cadprop.getProp().getRespRgOrgao() == null ? "" : cadprop.getProp().getRespRgOrgao() : "")%>" class="inputtexto">
                    </td>
                    <td class="TextoCampos" >UF do RG:</td>
                    <td class="CelulaZebra2">
                        <input name="respRgUf" type="text" id="respRgUf" size="3" maxlength="2" value="<%=(carregaprop ? cadprop.getProp().getRespRgUf()== null ? "" : cadprop.getProp().getRespRgUf() : "")%>" class="inputtexto">
                    </td>
                    <td class="TextoCampos">Data de emissão do RG: </td>
                    <td class="CelulaZebra2">
                        <input name="respRgEmissao" type="text" id="respRgEmissao" size="10" maxlength="10" value="<%=(carregaprop ? cadprop.getProp().getRespRgEmissao() == null ? "" : fmt.format(cadprop.getProp().getRespRgEmissao()) : "")%>" class="inputtexto" 
                               onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onblur="alertInvalidDate(this,true);">
                    </td>
                </tr>    
                <tr>

                    <td class="TextoCampos">Nome:</td>
                    <td class="CelulaZebra2">
                        <input name="respNome" type="text" id="respNome" size="40" maxlength="40" value="<%=(carregaprop ? cadprop.getProp().getRespNome() == null ? "" :  cadprop.getProp().getRespNome() : "")%>" class="inputtexto">
                    </td>
                    <td class="TextoCampos">Data de Nascimento: </td>
                    <td class="CelulaZebra2" colspan="5">
                        <input name="respDtNasci" type="text" id="respDtNasci" size="10" maxlength="10" value="<%=(carregaprop ? cadprop.getProp().getRespDtNasc() == null ? "" : fmt.format(cadprop.getProp().getRespDtNasc()) : "")%>" class="inputtexto" 
                               onkeypress="fmtDate(this, event)" onkeyup="fmtDate(this, event)" onkeydown="fmtDate(this, event)" onblur="alertInvalidDate(this,true);">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">Email:</td>
                    <td class="CelulaZebra2" colspan="7">
                        <input name="respEmail" type="text" id="respEmail" size="45" maxlength="45" value="<%=(carregaprop ? cadprop.getProp().getRespEmail() == null ? "" : cadprop.getProp().getRespEmail() : "")%>" class="inputtexto">
                    </td>

                </tr>
                <tr>
                    <td class="TextoCampos">Nome da Mãe:</td>
                    <td class="CelulaZebra2" >
                        <input name="respNomeMae" type="text" id="respNomeMae" size="45" maxlength="45" value="<%=(carregaprop ? cadprop.getProp().getRespNomeMae() == null ? "" : cadprop.getProp().getRespNomeMae() : "")%>" class="inputtexto">
                    </td>
                    <td class="TextoCampos">Nome do Pai: </td>
                    <td class="CelulaZebra2" colspan="5">
                        <input name="respNomePai" type="text" id="respNomePai" size="45" maxlength="45" value="<%=(carregaprop ? cadprop.getProp().getRespNomePai()== null ? "" : cadprop.getProp().getRespNomePai() : "")%>" class="inputtexto">
                    </td>
                </tr>
            </table>               
        </div>                   
        <div id="divAuditoria" >  

            <table width="70%" border="0" align="center" cellpadding="2" cellspacing="1" class="bordaFina" style='display: <%=carregaprop && nivelUser == 4 ? "" : "none"%>'>
                <%@include file="gwTrans/template_auditoria.jsp" %>

                <tr>
                    <td colspan="6" align="center">
                        <table width="100%" class="bordaFina">
                            <tr>
                                <td width="10%" class="TextoCampos">Incluso:</td>
                                <td width="40%" class="CelulaZebra2">Em: <%=(carregaprop && cadprop.getProp().getCriadoEm() != null ? fmt.format(cadprop.getProp().getCriadoEm()) : "")%><br>
                                    Por: <%=carregaprop && cadprop.getProp().getCriadoPor().getNome() != null ? cadprop.getProp().getCriadoPor().getNome() : ""%> </td>
                                <td width="10%" class="TextoCampos">Alterado:</td>
                                <td width="40%" class="CelulaZebra2">Em:<%=(carregaprop && cadprop.getProp().getAlteradoEm() != null ? fmt.format(cadprop.getProp().getAlteradoEm()) : "")%><br>
                                    Por: <%=carregaprop && cadprop.getProp().getAlteradoPor().getNome() != null ? cadprop.getProp().getAlteradoPor().getNome() : ""%> </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>

        </div> 


        <br/>

        <table width="70%" align="center" cellpadding="2" cellspacing="1" class="bordaFina" id="tableAuditoria">
            <tr class="CelulaZebra2">
                <td colspan="4"> <center>
                <% if (nivelUser >= 2) {%>
                        <input name="salvar" type="button" class="botoes" id="salvar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                <%}%>
            </center></td>
    </tr>
</table>
</div>

<br>
</body>
</html>    
