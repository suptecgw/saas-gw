<%@page import="br.com.gwsistemas.filial.usuario.Usuario"%>
<%@page import="conhecimento.ocorrencia.Ocorrencia"%>
<%@page import="conhecimento.ocorrencia.BeanOcorrenciaCtrc"%>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.NegociacaoAdiantamentoFreteBO"%>
<%@page import="br.com.gwsistemas.contratodefrete.negociacao.NegociacaoAdiantamentoFrete"%>
<%@page import="usuario.BeanUsuario"%>
<%@page import="nucleo.Auditoria.Auditoria"%>
<%@page import="java.util.List"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="motorista.MotoristaSalario"%>
<%@page import="java.util.Collection"%>
<%@ page contentType="text/html" language="java"
         import="motorista.BeanConsultaMotorista,
         motorista.BeanCadMotorista,
         java.util.Date,
         java.text.SimpleDateFormat,
         nucleo.Apoio,
         mov_banco.banco.*,
         nucleo.webservice.WebServiceCep,
         nucleo.*,
         nucleo.imagem.ImagemBO,
         nucleo.imagem.MotoristaImagem,
         java.util.Vector,
         java.io.File,
         funcao.*,
         java.sql.ResultSet,
         cidade.*,
         java.net.*,
         java.io.PrintWriter" errorPage="" %>
<%@ page import="br.com.gwsistemas.motorista.TipoCalculoPercentualValorCFe" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<script language="javascript" type="text/javascript" src="script/prototype_1_6.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoes_gweb.js"></script>
<script language="JavaScript"  type="text/javascript" src="script/fabtabulous.js"></script>
<script language="JavaScript" src="script/mascaras.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js" type="text/javascript"></script>
<script language="Javascript" type="text/javascript" src="script/jquery-1.11.2.min.js"></script>
<script language="javascript" type="text/javascript" src="script/LogAcoesAuditoria.js"></script>
<script language="javascript" type="text/javascript" src="script/funcoesTelacadMotorista.js"></script>

<% //Versao da MSA: 2.0 ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
    // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
    int nivelUser = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("cadmotorista") : 0);
    int nivelUserAdiantamento = (Apoio.getUsuario(request) != null
            ? Apoio.getUsuario(request).getAcesso("alterapercadiant") : 0);
    
    int nivelUserFrotaPropria = (Apoio.getUsuario(request) != null 
            ? Apoio.getUsuario(request).getAcesso("cadMotoristaFrotaPropria") : 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (nivelUser == 0)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    
    String dataAtual = Apoio.getDataAtual();
    //fim da MSA
%>
<%
    String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao"));
    MotoristaSalario salMotorista = new MotoristaSalario();
    BeanCadMotorista motor = null;
    BeanConsultaCidade conCid = null;
    BeanConfiguracao cfg = new BeanConfiguracao();
    Collection<NegociacaoAdiantamentoFrete> negociacaoMotor = null;
    cfg.setConexao(Apoio.getUsuario(request).getConexao());
    cfg.CarregaConfig();
    boolean isObrigatorioPisPasep = cfg.isMotoristaPisPasepObrigatorio();
    boolean isValidaLocalEmissaoCNH = cfg.isMotoristaLocalEmissaoCNH();
    Collection<BeanCadMotorista> listaSalario = null;
    
    if (acao != null) {
        //instrucoes incomuns entre as acoes
        if (acao.equals("editar") || acao.equals("incluir") || acao.equals("atualizar") || acao.equals("excluirMotoristaSalario")) {    //instanciando o bean de cadastro
            motor = new BeanCadMotorista();
            motor.setConexao(Apoio.getUsuario(request).getConexao());
            motor.setExecutor(Apoio.getUsuario(request));
        }
        
        if(acao.equals("excluirMotoristaSalario")){
            BeanUsuario autenticado = Apoio.getUsuario(request);
            int salarioId = Apoio.parseInt(request.getParameter("id"));
           
            Auditoria auditoria = new Auditoria();
            auditoria.setAcao("Excluir Salario do Motorista" + salarioId);
            auditoria.setIp(request.getRemoteHost());
            auditoria.setModulo("WebTrans Motorista");  
            auditoria.setRotina("Alterar Salario");
            auditoria.setUsuario(autenticado);
                  
            motor.excluirMotoristaSalario(salarioId, autenticado, auditoria);
            
        }

        //executando a acao desejada
        if ((acao.equals("editar")) && (request.getParameter("id") != null)) {
            int idmotorista = Apoio.parseInt(request.getParameter("id"));
            motor.setIdmotorista(idmotorista);
            //carregando os dados do cliente por completo(atributos)
            motor.LoadAllPropertys();            
            //Carregando foto 3X4
            String caminhoImagens = request.getAttribute("dir_home") + "img/motorista".replace('/', File.separatorChar);
            MotoristaImagem imagem = null;
            imagem = new MotoristaImagem();
            imagem.setCaminho(caminhoImagens);
            imagem.setMotoristaId(idmotorista);
            ImagemBO imagemBO = null;
            imagemBO = new ImagemBO(Apoio.getUsuario(request), imagem.getCaminho());
            request.setAttribute("imagem", imagemBO.carregar3x4(imagem));

        } else if (acao.equals("atualizar") || acao.equals("incluir")) {
            //Variáveis pra receber a data no formato dd/mm/yyyy
            SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
            Date dataNasc = (request.getParameter("datanasc").equals("") ? null : formatador.parse(request.getParameter("datanasc")));
            Date dataEmissaoRg = (request.getParameter("dataemissaorg").equals("") ? null : formatador.parse(request.getParameter("dataemissaorg")));
            Date dataEmissaoCnh = (request.getParameter("dataemissaocnh").equals("") ? null : formatador.parse(request.getParameter("dataemissaocnh")));
            Date vencimentoCnh = (request.getParameter("vencimentocnh").equals("") ? null : formatador.parse(request.getParameter("vencimentocnh")));
            Date dataValidadeMope = (request.getParameter("dataValidadeMope").equals("") ? null : formatador.parse(request.getParameter("dataValidadeMope")));
            Date primeiraHabilitacaoEm = (request.getParameter("primeiraHabilitacaoEm").equals("") ? null : formatador.parse(request.getParameter("primeiraHabilitacaoEm")));
            Date dataadmissao = (request.getParameter("dataAdmissao").equals("") ? null : formatador.parse(request.getParameter("dataAdmissao")));
            Date datademissao = (request.getParameter("dataDemissao").equals("") ? null : formatador.parse(request.getParameter("dataDemissao")));
            //populando o JavaBean
            motor.setNome(URLDecoder.decode(request.getParameter("nome"), "UTF-8"));
            motor.setApelido(request.getParameter("apelido"));
            motor.setDatanasc(dataNasc);
            motor.setCpf(request.getParameter("cpf"));
            motor.setRg(request.getParameter("rg"));
            motor.setOrgao_rg(request.getParameter("orgao_rg"));
            if (dataEmissaoRg != null) {
                motor.setDataemissaorg(dataEmissaoRg);
            }
            motor.setLocalemissaorg(request.getParameter("localemissaorg"));
            motor.setProntuario(request.getParameter("prontuario"));
            motor.setDataemissaocnh(dataEmissaoCnh);
            motor.setLocalemissaocnh(request.getParameter("localemissaocnh"));
            motor.setVencimentocnh(vencimentoCnh);
            motor.setCategcnh(request.getParameter("categcnh"));
            motor.setNomepai(URLDecoder.decode(request.getParameter("nomepai"), "UTF-8"));
            motor.setNomemae(URLDecoder.decode(request.getParameter("nomemae"), "UTF-8"));
            motor.setEndereco(URLDecoder.decode(request.getParameter("endereco"), "UTF-8"));
            motor.setBairro(URLDecoder.decode(request.getParameter("bairro"), "UTF-8"));
            motor.getCidade().setDescricaoCidade(URLDecoder.decode(request.getParameter("cidade"), "UTF-8"));
            motor.getCidade().setUf(request.getParameter("uf"));
            motor.getCidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidade")));
            motor.setCep(request.getParameter("cep"));
            motor.setComplemento(URLDecoder.decode(request.getParameter("complemento"), "UTF-8"));
            motor.setTelefone(request.getParameter("telefone"));
            motor.setTelefone2(request.getParameter("telefone2"));
            motor.setIdestadocivil(Apoio.parseInt(request.getParameter("idestadocivil")));
            motor.setRefpessoal(URLDecoder.decode(request.getParameter("refpessoal"), "UTF-8"));
            motor.setFonerefpessoal(request.getParameter("fonerefpessoal"));
            motor.setRefpessoal2(URLDecoder.decode(request.getParameter("refpessoal2"), "UTF-8"));
            motor.setFonerefpessoal2(request.getParameter("fonerefpessoal2"));
            motor.setRefpessoal3(URLDecoder.decode(request.getParameter("refpessoal3"), "UTF-8"));
            motor.setFonerefpessoal3(request.getParameter("fonerefpessoal3"));
            motor.setRefcomercial(URLDecoder.decode(request.getParameter("refcomercial"), "UTF-8"));
            motor.setFonerefcomercial(request.getParameter("fonerefcomercial"));
            motor.setRefcomercial2(URLDecoder.decode(request.getParameter("refcomercial2"), "UTF-8"));
            motor.setFonerefcomercial2(request.getParameter("fonerefcomercial2"));
            motor.setRefcomercial3(URLDecoder.decode(request.getParameter("refcomercial3"), "UTF-8"));
            motor.setFonerefcomercial3(request.getParameter("fonerefcomercial3"));
            motor.setTipo(request.getParameter("tipo"));
            if(request.getParameter("tipo").equals("c")){
            //motor.setLiberacao(request.getParameter("liberacao"));
            motor.setLiberacao("");
            motor.setVencimento_lib(null);
            //motor.setVencimento_lib((request.getParameter("vencimento_lib").equals("") ? null : formatador.parse(request.getParameter("vencimento_lib"))));
            }else{
                motor.setLiberacao(request.getParameter("liberacao"));
                motor.setVencimento_lib((formatador.parse(request.getParameter("vencimento_lib"))));
            //motor.setVencimento_lib((request.getParameter("vencimento_lib").equals("") ? null : formatador.parse(request.getParameter("vencimento_lib"))));
            }
            motor.setCnh(request.getParameter("cnh"));
            motor.setBloqueado(Apoio.parseBoolean(request.getParameter("chkbloqueado")));
            motor.setMotivobloqueio(URLDecoder.decode(request.getParameter("motivobloqueio"), "UTF-8"));
            motor.setObsCartaFrete(URLDecoder.decode(request.getParameter("obscartafrete"), "UTF-8"));
            motor.getVeiculo().setIdveiculo(Apoio.parseInt(request.getParameter("idveiculo")));
            motor.getCarreta().setIdveiculo(Apoio.parseInt(request.getParameter("idcarreta")));
            
            motor.getBiTrem().setIdveiculo(Apoio.parseInt(request.getParameter("idbitrem")));
            motor.getTritrem().setIdveiculo(Apoio.parseInt(request.getParameter("idtritrem")));
//            motor.setPercentualAdiantamento(Apoio.parseFloat(request.getParameter("percentualAdiantamento")));
            motor.setPercentualComissaoFrete(Apoio.parseFloat(request.getParameter("percentualComissaoFrete")));
            motor.setTipoComissao(request.getParameter("sobre"));
            motor.setPercentualDescontoContrato(Apoio.parseFloat(request.getParameter("percentualDescontoContrato")));
            motor.setQtdDependentes(Apoio.parseInt(request.getParameter("qtdDependentes")));
            motor.setCartaoBunge(URLDecoder.decode(request.getParameter("cartaoBunge"), "UTF-8"));
            motor.setCategoria(request.getParameter("categoria"));
            motor.getFuncaoTripulante().setId(Apoio.parseInt(request.getParameter("funcao")));
            motor.setConta1(request.getParameter("conta1"));
            motor.setAgencia1(request.getParameter("agencia1"));
            motor.getBanco1().setIdBanco(Apoio.parseInt(request.getParameter("banco1")));
            motor.setFavorecido1(request.getParameter("favorecido1"));
            motor.setConta2(request.getParameter("conta2"));
            motor.setAgencia2(request.getParameter("agencia2"));
            motor.getBanco2().setIdBanco(Apoio.parseInt(request.getParameter("banco2")));
            motor.setFavorecido2(request.getParameter("favorecido2"));

            motor.setQtdVitimaRoubo(Apoio.parseInt(request.getParameter("qtdVitimaRoubo")));
            motor.setQtdVitimaAcidente(Apoio.parseInt(request.getParameter("qtdVitimaAcidente")));
            motor.setVitimaRoubo(Apoio.parseBoolean(request.getParameter("vitimaRoubo")));
            motor.setVitimaAcidente(Apoio.parseBoolean(request.getParameter("vitimaAcidente")));
            motor.getCidadeNaturalidade().setIdcidade(Apoio.parseInt(request.getParameter("idCidadeNaturalidade")));
            motor.setCartaoRepom(request.getParameter("cartaoRepom"));

            motor.setMope(Apoio.parseBoolean(request.getParameter("mope")));
            motor.setDtValidadeMope(dataValidadeMope);
            motor.setPrimeiraHabilitacaoEm(primeiraHabilitacaoEm);
            motor.setCartaoPamcard(request.getParameter("cartaoPamcard"));
            motor.setCartaoNdd(Apoio.parseInt((request.getParameter("cartaoNdd").equals("") ? "0" : request.getParameter("cartaoNdd"))));
            motor.setCartaoTicketFrete(Apoio.parseInt((request.getParameter("cartaoTicketFrete").equals("") ? "0" : request.getParameter("cartaoTicketFrete"))));

            motor.setNumeroLogradouro(request.getParameter("numeroLogradouro"));
            //motor.setNumeroRntrc(request.getParameter("numeroRNTRC").equals("")?0:Long.parseLong(request.getParameter("numeroRNTRC")));
            motor.getCliente().setIdcliente(Apoio.parseInt(request.getParameter("idconsignatario")));
            motor.setPisPasep(request.getParameter("pisPasep"));
            motor.setDdd(Apoio.parseInt(request.getParameter("ddd").equals("") ? "0" : request.getParameter("ddd")));
            motor.setDdd2(Apoio.parseInt(request.getParameter("ddd2").equals("") ? "0" : request.getParameter("ddd2")));
            motor.setApelido(request.getParameter("apelido"));
            motor.setDesligado(Apoio.parseBoolean(request.getParameter("desligado")));
            
            


            motor.setDataAdmissao(dataadmissao);
            motor.setDataDemissao(datademissao);
            
            motor.setTituloEleitor(request.getParameter("tituloEleitor"));
            motor.setZonaEleitoral(Apoio.parseInt(request.getParameter("zonaEleitoral")));
            motor.setSecaoEleitoral(Apoio.parseInt(request.getParameter("secaoEleitoral")));
            
            //01/03/2015
            motor.setSexo(request.getParameter("sexo"));
            //09/03/2016 novos campos
            motor.setGrauEscolaridade(request.getParameter("grauEscolaridade"));
            motor.setQualificacaoProfissional(request.getParameter("qualificacaoProfissional"));
            
            motor.setCartaoExpers(request.getParameter("cartaoExpers"));
            
            motor.setTipoContaAdiantamentoExpers(request.getParameter("tipoContaAdiantamentoExpers"));
            motor.setTipoContaSaldoExpers(request.getParameter("tipoContaSaldoExpers"));
            motor.setCodSegurancaCNH(request.getParameter("codSegurancaCNH"));
            
            motor.setUfEmissaoRg(request.getParameter("uf_rg"));
            motor.setCartaoPagBem(request.getParameter("cartaoPagBem"));
            motor.setNegociacaoAdiantamento(Apoio.parseInt(request.getParameter("negociacaoAdiantamento")));
            
            motor.setNumeroCartaoEcoFrotas(request.getParameter("numeroCartaoEcoFrotas"));
            
            motor.setTokenCompraEfrete(request.getParameter("tokenEfreteCompra"));
            
            int maxSalarios = Apoio.parseInt(request.getParameter("maxSalario"));
            if(maxSalarios != 0 ){
                MotoristaSalario motoristaSalario;
                for(int i = 1; i <= maxSalarios; i++){
                    if (request.getParameter("salarioId_" + i) != null){
                    motoristaSalario = new MotoristaSalario();
                    motoristaSalario.setId(Apoio.parseInt(request.getParameter("salarioId_" + i)));
                    motoristaSalario.getIdMotorista().setIdmotorista(motor.getId());
                    Date dataSalario =  formatador.parse(request.getParameter("competencia_" + i));
                    motoristaSalario.setVigenciaSalarioEm(dataSalario);
                    motoristaSalario.setValorSalario(Apoio.parseDouble(request.getParameter("valor_" + i)));
                    motoristaSalario.setValorCustoAdcional(Apoio.parseDouble(request.getParameter("valorCustoAdcional_" + i)));
                    motor.getListaMotoristaSalario().add(motoristaSalario);
                    }
                }
            }
            
                int maxOcorrencia = Apoio.parseInt(request.getParameter("maxOcorrencia"));
                
                motor.setIdsOcorrenciaExcluir(request.getParameter("ocorrenciaExcluir"));
              
            if (maxOcorrencia != 0) {
                Ocorrencia ocorrenciaMotosita;
                for (int i = 0; i < maxOcorrencia; i++) {
                    if (request.getParameter("idOcorrencia_" + i) != null) {
                        ocorrenciaMotosita = new Ocorrencia();
                        BeanOcorrenciaCtrc ocorrencia = new BeanOcorrenciaCtrc();
                        ocorrencia.setId(Apoio.parseInt(request.getParameter("idOcorrenciaCTRC_" + i)));
                        ocorrenciaMotosita.setOcorrencia(ocorrencia);

                        ocorrenciaMotosita.setId(Apoio.parseInt(request.getParameter("idOcorrencia_" + i)));
                        ocorrenciaMotosita.setOcorrenciaEm(Apoio.getFormatData(request.getParameter("dataOcorrencia_" + i)));
                        ocorrenciaMotosita.setOcorrenciaAs(Apoio.getFormatTime(request.getParameter("horaOcorrencia_" + i)));
                        ocorrenciaMotosita.setObservacaoOcorrencia(request.getParameter("descricaoOcorrencia_" + i));
                        BeanUsuario usuarioOcorrencia = new BeanUsuario();
                        int idUsuarioOcorrencia = Apoio.parseInt(request.getParameter("idUsuarioInclusao_" + i));
                        usuarioOcorrencia.setIdusuario(idUsuarioOcorrencia);
                        ocorrenciaMotosita.setUsuarioOcorrencia(usuarioOcorrencia);
                        ocorrenciaMotosita.setResolvido(Apoio.parseBoolean(request.getParameter("resolvido_" + i)));
                        ocorrenciaMotosita.setResolucaoAs(Apoio.getFormatTime(request.getParameter("horaResolucao_" + i)));
                        ocorrenciaMotosita.setResolucaoEm(Apoio.getFormatData(request.getParameter("dataResolucao_" + i)));
                        ocorrenciaMotosita.setObservacaoResolucao(request.getParameter("descricaoResolucao_" + i));
                        BeanUsuario usuarioResolucao = new BeanUsuario();
                        int idUsuarioResolucao = Apoio.parseInt(request.getParameter("idUsuarioResolucao_" + i));
                        usuarioResolucao.setIdusuario(idUsuarioResolucao);
                        ocorrenciaMotosita.setUsuarioResolucao(usuarioResolucao);
                        motor.getOcorrenciaMotorista().add(ocorrenciaMotosita);
                    }
                }
            }  
                        
            motor.setCartaoTarget(request.getParameter("cartaoTarget"));
            motor.setEmail(request.getParameter("emailMotorista"));
            motor.setNacionalidade(request.getParameter("nacionalidade"));
            
            motor.setPercentualValorCTeCalculoCFe(Apoio.parseDouble(request.getParameter("percentualValorCTeCalculoCFe")));
            motor.setTipoCalculoPercentualValorCFe(TipoCalculoPercentualValorCFe.obterTipoCalculoPercentualValorCFe(request.getParameter("tipoCalculoPercentualValorCFe")));
            motor.setCalculoValorContratoFrete(request.getParameter("calculoValorContratoFrete"));
            motor.setValorMinimoCFe(Apoio.parseDouble(request.getParameter("valorMinimoCFe")));

            if (acao.equals("atualizar")) {
                motor.setIdmotorista(Apoio.parseInt(request.getParameter("id")));
            }
                
            //Verificando se vai incluir ou alterar
            boolean erro = !(acao.equals("incluir") ? motor.Inclui() : motor.Atualiza());
            //EXIBINDO MENSAGEM DE CENÁRIO E REDIRECIONANDO
%>
<script language="javascript" type="">
    <%
        if (erro) {
            acao = (acao.equals("atualizar") ? "editar" : "iniciar");
    %>alert('<%=(motor.getErros())%>');
        window.opener.document.getElementById("gravar").value = "Salvar";
        window.opener.document.getElementById("gravar").disabled = false;
        window.close();
    <%} else {%>
    //location.replace("ConsultaControlador?codTela=60");
    window.opener.document.location.replace("ConsultaControlador?codTela=60");
    window.close();
    <%}%>
</script>
<%}
        if (acao.equals("getEnderecoByCep")) {
            WebServiceCep webServiceCep = WebServiceCep.searchCep(request.getParameter("cep"));
            String resposta = "";
            int idcidade = 0;
            conCid = new BeanConsultaCidade();
            conCid.setConexao(Apoio.getUsuario(request).getConexao());
            conCid.setCampoDeConsulta("cidade");
            conCid.setValorDaConsulta(webServiceCep.getCidade().toUpperCase());
            conCid.setOperador(BeanConsulta.STR_IGUAL);
            //conCid.set
            conCid.getFiltrosAdicionais().append(" and uf =").append(webServiceCep.getUf().toUpperCase()).append(" ");

            if (conCid.Consultar()) {
                ResultSet rsc = conCid.getResultado();
                while (rsc.next()) {
                    idcidade = rsc.getInt("idcidade");
                }

            }
            if (webServiceCep.wasSuccessful()) {
                String bairro = webServiceCep.getBairro().length() < 25 ? webServiceCep.getBairro().toUpperCase() : webServiceCep.getBairro().toUpperCase().substring(0, 24);

                resposta = "@@" + webServiceCep.getLogradouroFull().toUpperCase() + "@@"
                        + bairro + "@@"
                        + idcidade + "@@"
                        + webServiceCep.getCidade().toUpperCase() + "@@"
                        + webServiceCep.getUf().toUpperCase() + "@@";

                //PrintWriter out = response.getWriter();
                out.println(resposta);
                //out.close();
            } else {
                resposta = "@@" + "@@" + "@@" + "@@" + "@@" + "@@";
                //PrintWriter out = response.getWriter();
                out.println(resposta);
                //out.close();
            }
        }
    }
    boolean carregamotorista = (motor != null && (!acao.equals("incluir") || !acao.equals("atualizar")));
%>



<script language="javascript" type="text/javascript">

    jQuery.noConflict();
    
    // objeto salario do motorista
    function SalarioMotorista(id, idMotorista, salarioEm, valorSalario, valorCustoAdcional){
        this.id = (id != undefined)? id : 0;
        this.idMotorista = (idMotorista != undefined ? idMotorista : 0 );
        this.salarioEm = (salarioEm != undefined ? salarioEm : "<%=dataAtual%>" );
        this.valorSalario = (valorSalario != undefined ? valorSalario : "0.00" );
        this.valorCustoAdcional = (valorCustoAdcional != undefined ? valorCustoAdcional : "0.0000");
    }
   
   
    //dom - adiciona novos salarios dos motoristas
    countNovosSalariosMotoristas = 0;
    function addNovosSalariosMotoristas (salariosMotoristas){
        $("trSalarioMotorista_").style.display = "";    
        try{
        if(salariosMotoristas == null || salariosMotoristas == undefined){
                salariosMotoristas = new SalarioMotorista();
            }
            
            countNovosSalariosMotoristas++;
            
            var tbSalarioMotorista = $("tbSalarioMot");
            
            var tr = Builder.node("tr" , {
                className:"CelulaZebra2" ,
                id: "idLinha_" + countNovosSalariosMotoristas
            });
            
            var td0 = Builder.node("td" , {
              align: "center"
            });
                      
            var img0 = Builder.node("img",{
             className:"imagemLink" ,
             name: "imgLixo" ,
             id: "imgLixo" ,
             src: "img/lixo.png" ,
             onClick:"excluirSalariosMotoristas(" + salariosMotoristas.id + "," + countNovosSalariosMotoristas + ");"
            });
            
            td0.appendChild(img0);
            
            var td1 = Builder.node("td" , {
             align: "center" 
            });
            
            var inpSalarioId = Builder.node("input" , {
              type: "hidden" ,
              name: "salarioId_" + countNovosSalariosMotoristas ,
              id: "salarioId_" + countNovosSalariosMotoristas ,
              value: salariosMotoristas.id
            });
            
            var inpMotoristaId = Builder.node("input" , {
              type: "hidden" ,
              name: "motoristaId_" + countNovosSalariosMotoristas ,
              id: "motoristaId_" + countNovosSalariosMotoristas ,
              value: salariosMotoristas.idMotorista
            });
            
            var td2 = Builder.node("td" , {
             align: "center" 
            });
            
            var inpCompetencia = Builder.node("input" , {
            type: "text" ,
            name: "competencia_" + countNovosSalariosMotoristas ,
            className:"fieldDate" ,
            id: "competencia_" + countNovosSalariosMotoristas,
            onblur:"alertInvalidDate(this, true)",
            size:"10" ,
            maxlength:"10",
            onkeypress:"fmtDate(this, event)",
            onkeyup:"fmtDate(this, event)",
            onkeydown:"fmtDate(this, event)", 
            value: salariosMotoristas.salarioEm
            });
            
            var td2 = Builder.node("td" , {
             align: "center" 
            });
            
            var td3 = Builder.node("td", {
            align: "center",
            });
            
            var inpValor = Builder.node("input" , {
            type: "text" ,
            name: "valor_" + countNovosSalariosMotoristas ,
            className: "fieldMin styleValor" ,
            id: "valor_" + countNovosSalariosMotoristas ,
            onkeypress:"mascara(this, reais)" ,
            value: salariosMotoristas.valorSalario
            });
            var inpValorCustoAdcional = Builder.node("input", {
            type: "text",
            name: "valorCustoAdcional_" + countNovosSalariosMotoristas,
            id: "valorCustoAdcional_" + countNovosSalariosMotoristas,
            className: "fieldMin styleValor",
            onkeypress: "mascara(this, reais, 4);",            
            maxlength: "8",
            size: "8",
            value: colocarVirgula(salariosMotoristas.valorCustoAdcional, 4)
            });
            
            td1.appendChild(inpSalarioId);
            td1.appendChild(inpMotoristaId);
            td1.appendChild(inpCompetencia);
            td2.appendChild(inpValor);
            td3.appendChild(inpValorCustoAdcional);
            
            tr.appendChild(td0);
            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            
            tbSalarioMotorista.appendChild(tr);
            
            $("maxSalario").value = countNovosSalariosMotoristas;
        }catch(e){
          alert(e);
      }
  }

    // dom - excluir
    function excluirSalariosMotoristas(id, index){        
        var existe = false;
        if(confirm("Deseja excluir este salário?")){
            if(confirm("Tem Certeza ?")){
                if(id != 0){            
                new Ajax.Request("./cadmotorista?acao=excluirMotoristaSalario&id="+id,
                { 
                    method: 'get',
                    onSuccess: function(){
                        alert('Sálario excluido com sucesso!');
                      Element.remove($("idLinha_"+index));
                    },
                    onFailure: function(){
                        alert('Erro ao atentar excluir o Salário!')
                    }
                });
            }else{
                Element.remove("idLinha_"+index);
            }
            var i;
              for(i = 1; i <= countNovasCidadesEDI; i++){
                    if($("idLinha_"+i) != null){
                        existe = true;
                    }
              }
              if(!existe){
                $("trSalarioMotorista_").style.display = "";
              }
        }
    }   
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

    var windowCidade = null;
    function localizaCidadeNaturalidade(){
        windowCidade = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade_Naturalidade',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
    }
    
    function localizaCidade(){
        windowCidade = window.open('./localiza?acao=consultar&idlista=<%=BeanLocaliza.CIDADE_ORIGEM%>','Cidade',
        'top=80,left=150,height=400,width=600,resizable=yes,status=1,scrollbars=1');
    }

    //Em caso de alteração, o combo UF recebe o valor do BD
    //Está sendo utilizado no onload do body  
    function getEnderecoByCep(cep){
        if(cep.length < 8){
            alert("CEP invalido, digite pelo menos 8 digitos")
        }else{
            espereEnviar("",true);
            // mudei para jQuery para colcoar o timeout, pois estava antes com prototype.
            let ajax = jQuery.ajax("./jspcadmotorista.jsp?acao=getEnderecoByCep&cep="+ cep, {
                    method:"get",
                    timeout: 30000 // 30segundos
            });
            
            ajax.success((data, status, transport)=>{
                let response = transport.responseText;
                carregaCepAjax(response);
            });
            
            ajax.error(()=>{
                alert("Não foi possivel encontrar o endereço.");
                espereEnviar("",false);
            });
        }
    }
    
    function limparEndereco(){
        $("endereco").value = "";
        $("bairro").value = "";
        $("cidade").value = "";
        $("idCidade").value = "0";
        $("uf").value = "";
    }

    function carregaCepAjax(resposta){
        var rua = resposta.split("@@")[1];
        var bairro = resposta.split("@@")[2];
        var idcidade = resposta.split("@@")[3];
        var cidade = resposta.split("@@")[4];
        var uf = resposta.split("@@")[5];

        if(rua != "" && $("endereco").value.trim() == ""){
            $("uf").value = uf.trim();
            $("endereco").value = rua;
            $("bairro").value = bairro;
            $("cidade").value = cidade;
            $("idCidade").value = idcidade;
            $("complemento").focus();
        }
        espereEnviar("",false);	  		
    }
  
    function atribuicombos(){
    <%
        SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy");
        if (motor != null) {%>
                $("uf").value = "<%=motor.getCidade().getUf()%>";
                $("idestadocivil").value = "<%=motor.getIdestadocivil()%>";
                $("categcnh").value = "<%=motor.getCategcnh()%>";
                $("datanasc").value = "<%=(motor.getDatanasc() == null ? "" : formato.format(motor.getDatanasc()))%>";
                $("dataAdmissao").value = "<%=(motor.getDataAdmissao() == null ? "" : formato.format(motor.getDataAdmissao()))%>";
                $("dataDemissao").value = "<%=(motor.getDataDemissao() == null ? "" : formato.format(motor.getDataDemissao()))%>";
                $("dataemissaorg").value = "<%=(motor.getDataemissaorg() == null ? "" : formato.format(motor.getDataemissaorg()))%>";
                $("dataemissaocnh").value = "<%=(motor.getDataemissaocnh() == null ? "" : formato.format(motor.getDataemissaocnh()))%>";
                $("vencimentocnh").value = "<%=(motor.getVencimentocnh() == null ? "" : formato.format(motor.getVencimentocnh()))%>";
                $("vencimento_lib").value = "<%=(motor.getVencimento_lib() == null ? "" : formato.format(motor.getVencimento_lib()))%>";
                $("dataValidadeMope").value = "<%=(motor.getDtValidadeMope() == null ? "" : formato.format(motor.getDtValidadeMope()))%>";
                $("tipo").value = "<%=motor.getTipo()%>";
                $("primeiraHabilitacaoEm").value = "<%=(motor.getPrimeiraHabilitacaoEm() == null ? "" : formato.format(motor.getPrimeiraHabilitacaoEm()))%>";
                if($("tipoContaAdiantamentoExpers")!=null && $("tipoContaAdiantamentoExpers")!= undefined){
                    $("tipoContaAdiantamentoExpers").value = '<%=motor.getTipoContaAdiantamentoExpers()%>';
                    $("tipoContaSaldoExpers").value = '<%=motor.getTipoContaSaldoExpers()%>';
                }
    <%}%>
        }

        //Quando o usuário clica em voltar
        function voltar(){
            tryRequestToServer(function(){location.replace("ConsultaControlador?codTela=60");});
        }
    
        function aoClicarNoLocaliza(idjanela){
            //localizando cidade
            if (idjanela=="Cidade"){
                $('idCidade').value = $('idcidadeorigem').value;
                $('cidade').value = $('cid_origem').value;
                $('uf').value = $('uf_origem').value;
            }else if(idjanela=="Cidade_Naturalidade"){
                $('idCidadeNaturalidade').value = $('idcidadeorigem').value;
                $('cidNaturalidade').value = $('cid_origem').value;
                $('ufNaturalidade').value = $('uf_origem').value;
            }else if(idjanela == "Ocorrencia_Ctrc") {
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

        //Salva as informações digitadas
        function salva(acao){
        var cep = $("cep").value;
            var sob = "";     
            // Validando se o local de emissão da CNH foi informado no caso desta opção estar escolhida como obrigatória em Configurações.
            if($("localemissaocnh").value=="" && <%=cfg.isMotoristaLocalEmissaoCNH()%>){
                alert("Informe o Local de Emissão da CNH.");
                $("localemissaocnh").focus();
                return false;
            }
            
            //if($('tipofrota').value == "pr" || $('vei_tipofrota').value == "pr"){
                
                if(acao == "atualizar" && (<%=nivelUserFrotaPropria < 2%> && <%=motor != null ? motor.getTipo() != null && motor.getTipo().equals("f") : false%>)){
                    alert("Você não tem permissão para alterar motoristas da casa (Funcionário).");
                    return false;
                }else if(acao == "incluir" && (<%=nivelUserFrotaPropria <= 2%> && $("tipo").value == "f" )){
                    alert("Voce não tem permissão para 'Cadastrar' Motorista Frota Propria.");
                    return false;
                }
            
            //}
            
            if($("tipo").value == "f" && <%=isObrigatorioPisPasep%> && $("pisPasep").value == "") {
                alert ("Informe o PIS/PASEP do motorista.");
                $("pisPasep").focus();
                return false;
            }
            if (($("nome").value == null) || ($("nome").value == "")){
                alert ("Informe o nome do motorista corretamente.");
                $("nome").focus();
            }
            //Cpf do cliente
            else if ( ! isCpf($("cpf").value)){
                alert ("Cpf Inválido.");
                $("cpf").focus();
            }
            //Vencimento da liberação
            else if ($("categoria").value == "mo" && $("tipo").value != "c" && !validaData($("vencimento_lib")) ){
                alert ("Informe a data de validade da liberação corretamente. Formato válido: dd/mm/aaaa");
                $("vencimento_lib").focus();
            }
            else if ($("mope").checked && !validaData($("dataValidadeMope")) ){
                alert ("Informe a data de validade do MOPE. Formato válido: dd/mm/aaaa");
                $("dataValidadeMope").focus();
            }else if ($("cep").value == "" && <%=cfg.isMotoristaEnderecoObrigatorio()%>){
                showErro("Informe o Cep!", $("cep"));
            }else if ($("endereco").value == "" && <%=cfg.isMotoristaEnderecoObrigatorio()%>){
                showErro("Informe o Endereço!", $("endereco"));
            }else if ($("bairro").value == "" && <%=cfg.isMotoristaEnderecoObrigatorio()%>){
                showErro("Informe o Bairro!", $("bairro"));
            }else if ($("rg").value == "" && <%=cfg.isMotoristaRGOrgaoObrigatorio()%>){
                showErro("Informe o RG!", $("rg"));
            }else if ($("orgao_rg").value == "" && <%=cfg.isMotoristaRGOrgaoObrigatorio()%>){
                showErro("Informe o Orgão Emissor!",$("orgao_rg"));
            }else if ($("dataemissaorg").value == "" && <%=cfg.isMotoristaDataEmissaoRGObrigatorio()%>){
                showErro("Informe a data de emissão do RG!",$("dataemissaorg"));
            }else if ($("cnh").value == "" && <%=cfg.isMotoristaCNHObrigatorio()%>){
                showErro("Informe o CNH!",$("dataemissaocnh"));
            }else if ($("dataemissaocnh").value == "" && <%=cfg.isMotoristaDataEmissaoCNHObrigatorio()%>){
                showErro("Informe a data de emissão do CNH!",$("dataemissaocnh"));
            }else if ($("vencimentocnh").value == "" && <%=cfg.isMotoristaDataVencimentoCNHObrigatorio()%>){
                showErro("Informe a data de vencimento do CNH!",$("vencimentocnh"));
            }else if ($("idveiculo").value == "0" && <%=cfg.isMotoristaVeiculoObrigatorio()%>){
                showErro("Informe o veículo corretamente!",$("vei_placa"));
            }else if(cep.length < 8){
                getEnderecoByCep(cep);
            }else if($("idCidade").value == "0"){
                showErro("Informe a cidade! ",$("idCidade"));
            }else if($("telefone").value == "" && <%=cfg.isMotoristaTelefoneObrigatorio()%>){
                showErro("Informe o Fone 1!");
            }else if($("telefone2").value == "" && <%=cfg.isMotoristaTelefoneObrigatorio2()%>){    
                showErro("Informe o Fone 2!");
            }else if($("codSegurancaCNH").value == "" && <%=cfg.isCodSegurancaCNH()%>){    
                showErro("Informe o Código de Segurança da CNH!");
            }else if($("chkbloqueado").checked && $("motivobloqueio").value.trim() == ''){    
                showErro("Informe o Motivo do bloqueio do motorista!");
                
            }  
            else
            {
                
                if (countOcorrenciaMotorista > 0) {
                    for (var i = 0; i < countOcorrenciaMotorista; i++) {
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
                        }
                    }
                }
                
                
                try {
                $("gravar").disabled = true;
                $("gravar").value = "Enviando...";
                if (acao == "atualizar"){
                    acao += "&id=<%=(motor == null ? 0 : motor.getIdmotorista())%>";
                }
                if($("sobreB").checked == true){
                    sob = "b";
                }else if ($("sobreL").checked == true){
                    sob = "l";
                }else if ($("sobreP").checked == true){
                    sob = "p";
                }
                    
                    /* location.replace("./cadmotorista?acao="+acao+
                        "&nome="+encodeURIComponent($("nome").value)+
                        "&apelido="+$("apelido").value + 
                        "&datanasc="+$("datanasc").value+
                        "&cpf="+formatCpfCnpj($("cpf").value,false,false)+
                        "&rg="+$("rg").value+
                        "&orgao_rg="+$("orgao_rg").value+
                        "&dataemissaorg="+$("dataemissaorg").value+
                        "&localemissaorg="+$("localemissaorg").value+
                        "&prontuario="+$("prontuario").value+
                        "&dataemissaocnh="+$("dataemissaocnh").value+
                        "&localemissaocnh="+$("localemissaocnh").value+
                        "&vencimentocnh="+$("vencimentocnh").value+
                        "&categcnh="+$("categcnh").value+
                        "&nomepai="+encodeURIComponent($("nomepai").value)+
                        "&nomemae="+encodeURIComponent($("nomemae").value)+
                        "&endereco="+encodeURIComponent($("endereco").value)+
                        "&bairro="+encodeURIComponent($("bairro").value)+
                        "&cidade="+encodeURIComponent($("cidade").value)+
                        "&uf="+$("uf").value+
                        "&idCidade="+$("idCidade").value+
                        "&cep="+$("cep").value+
                        "&complemento="+encodeURIComponent($("complemento").value)+
                        "&telefone="+$("telefone").value+
                        "&telefone2="+$("telefone2").value+
                        "&idestadocivil="+$("idestadocivil").value+
                        "&refpessoal="+encodeURIComponent($("refpessoal").value)+
                        "&fonerefpessoal="+$("fonerefpessoal").value+
                        "&refpessoal2="+encodeURIComponent($("refpessoal2").value)+
                        "&fonerefpessoal2="+$("fonerefpessoal2").value+
                        "&refpessoal3="+encodeURIComponent($("refpessoal3").value)+
                        "&fonerefpessoal3="+$("fonerefpessoal3").value+
                        "&refcomercial="+encodeURIComponent($("refcomercial").value)+
                        "&fonerefcomercial="+$("fonerefcomercial").value+
                        "&refcomercial2="+encodeURIComponent($("refcomercial2").value)+
                        "&fonerefcomercial2="+$("fonerefcomercial2").value+
                        "&refcomercial3="+encodeURIComponent($("refcomercial3").value)+
                        "&fonerefcomercial3="+$("fonerefcomercial3").value+
                        "&tipo="+$("tipo").value+
                        "&isAtivoMobile="+$("isAtivoMobile").checked+
                        "&liberacao="+$("liberacao").value+
                        "&vencimento_lib="+$("vencimento_lib").value+
                        "&cnh="+$("cnh").value+
                        "&bloqueado="+$("chkbloqueado").checked+
                        "&idveiculo="+$("idveiculo").value+
                        "&idcarreta="+$("idcarreta").value+
                        "&idbitrem="+$("idbitrem").value+
                        "&motivobloqueio="+encodeURIComponent($("motivobloqueio").value)+
                        "&percentualAdiantamento="+$("percentualAdiantamento").value+
                        "&percentualComissaoFrete="+$("percentualComissaoFrete").value+
                        "&sobre="+sob+
                        "&obscartafrete="+encodeURIComponent($("obscartafrete").value) +
                        "&cartaoBunge="+encodeURIComponent($("cartaoBunge").value) +
                        "&categoria="+$("categoria").value +
                        "&funcao="+$("funcao").value +
                        "&qtdDependentes="+$("qtdDependentes").value +
                        "&conta1="+$("conta1").value +
                        "&agencia1="+$("agencia1").value +
                        "&cartaoRepom="+$("cartaoRepom").value +
                        "&banco1="+$("banco1").value +
                        "&favorecido1="+$("favorecido1").value +
                        "&conta2="+$("conta2").value +
                        "&agencia2="+$("agencia2").value +
                        "&banco2="+$("banco2").value +
                        "&favorecido2="+$("favorecido2").value +
                        "&cidadeNaturalidadeId="+$("idCidadeNaturalidade").value +
                        "&qtdVitimaAcidente="+$("qtdVitimaAcidente").value +
                        "&qtdVitimaRoubo="+$("qtdVitimaRoubo").value +
                        "&vitimaAcidente="+$("vitimaAcidente").checked+
                        "&percentualDescontoContrato="+$("percentualDescontoContrato").value+
                        "&vitimaRoubo="+$("vitimaRoubo").checked+
                        "&mope="+$("mope").checked +
                        "&primeiraHabilitacaoEm="+$("primeiraHabilitacaoEm").value +
                        "&dataValidadeMope="+$("dataValidadeMope").value +
                        "&numeroLogradouro="+$("numeroLogradouro").value +
                        "&cartaoPamcard=" + $("cartaoPamcard").value +
                        "&cartaoNdd=" + $("cartaoNdd").value +
                        "&cartaoTicketFrete=" + $("cartaoTicketFrete").value +
                        //"&numeroRNTRC=" + $("numeroRNTRC").value +
<!--                        "&idCliente=" + $("idconsignatario").value +-->
                        "&ddd=" + $("ddd").value +
                        "&ddd2=" + $("ddd2").value +
                        "&desligado=" + $("desligado").checked +
                        "&pisPasep=" + $("pisPasep").value +
                        "&dataAdmissao=" + $("dataAdmissao").value +
                        "&dataDemissao=" + $("dataDemissao").value +
                        "&tituloEleitor= " + $("tituloEleitor").value +
                        "&zonaEleitoral= " + $("zonaEleitoral").value + 
                        "&secaoEleitoral= " + $("secaoEleitoral").value +
                        "&maxSalario= " + $("maxSalario").value*/
                        
                    window.open('about:blank', 'pop', 'width=210, height=100');
                    var form = $("formulario");
                    form.action = "./cadmotorista?acao="+acao+"&cpf="+formatCpfCnpj($("cpf").value,false,false)+
                        "&nome="+encodeURIComponent($("nome").value)+
                        "&sobre="+sob+
                        "&nomepai="+encodeURIComponent($("nomepai").value)+
                        "&nomemae="+encodeURIComponent($("nomemae").value)+
                        "&endereco="+encodeURIComponent($("endereco").value)+
                        "&bairro="+encodeURIComponent($("bairro").value)+
                        "&cidade="+encodeURIComponent($("cidade").value)+
                        "&complemento="+encodeURIComponent($("complemento").value)+
                        "&refpessoal="+encodeURIComponent($("refpessoal").value)+
                        "&refpessoal2="+encodeURIComponent($("refpessoal2").value)+
                        "&refpessoal3="+encodeURIComponent($("refpessoal3").value)+
                        "&refcomercial="+encodeURIComponent($("refcomercial").value)+
                        "&refcomercial2="+encodeURIComponent($("refcomercial2").value)+
                        "&refcomercial3="+encodeURIComponent($("refcomercial3").value)+
                        "&motivobloqueio="+encodeURIComponent($("motivobloqueio").value)+
                        "&obscartafrete="+encodeURIComponent($("obscartafrete").value) +
                        "&chkbloqueado="+$("chkbloqueado").checked +
                        "&desligado=" + $("desligado").checked +
                        "&cartaoBunge="+encodeURIComponent($("cartaoBunge").value)+
                        "&cartaoExpers="+encodeURIComponent($("cartaoExpers").value)+
                        "&cartaoPagBem="+encodeURIComponent($("cartaoPagBem").value)+
                        "&tipoContaAdiantamentoExpers="+encodeURIComponent($("tipoContaAdiantamentoExpers").value)+
                        "&tipoContaSaldoExpers="+encodeURIComponent($("tipoContaSaldoExpers").value)+
                        "&codSegurancaCNH="+encodeURIComponent($("codSegurancaCNH").value)+
                        "&cartaoTarget="+encodeURIComponent($("cartaoTarget").value)+
                        "&emailMotorista="+encodeURIComponent($("emailMotorista").value)+
                        "&nacionalidade="+encodeURIComponent($("nacionalidade").value);
                        
     
                    form.submit();
                
                                            
                        
                } catch (e) { 
                    alert(e);
                }

            }
        }

        function excluirmotorista(){        
            //if(($('tipofrota').value == "pr" || $('vei_tipofrota').value == "pr") && (<%=nivelUserFrotaPropria <= 3%> && $("tipo").value == "f")){
            if(<%=nivelUserFrotaPropria <= 3%> && $("tipo").value == "f"){
                  alert("Voce não tem permissão para 'Excluir' Motorista Frota Propria.");
                  return false;
            }else{
                if (confirm("Deseja mesmo excluir este motorista?")){
                    location.replace("./consultamotorista?acao=excluir&id="+<%=(acao.equals("editar") ? motor.getIdmotorista() : 0)%>);
                }
            }
        }

        function alteraTipo(){

            if ($("tipo").value == "c")
            {
                $("liberacao").value = "";
                $("vencimento_lib").value = "";
                $("liberacao").disabled = true;
                $("vencimento_lib").disabled = true;
            }
            else
            {  
                $("liberacao").disabled = false;
                $("vencimento_lib").disabled = false;
            }
            if($("tipo").value == "f"){
                $("divDataAdmissao").style.display="";
                if($("dataAdmissao") != null)
                    $("dataAdmissao").style.display=""
                
                $("divDataDemissao").style.display="";
                if($("dataDemissao") != null)
                    $("dataDemissao").style.display=""
            }else{
                $("divDataAdmissao").style.display="none";
                if($("dataAdmissao") != null)
                    $("dataAdmissao").style.display="none"
                
                $("divDataDemissao").style.display="none";
                if($("dataDemissao") != null)
                    $("dataDemissao").style.display="none";
            }
        }

        function seAlterando(){
    <% //Apenas se tiver em modo de edição
        if (carregamotorista) {%>
                //formatando o cnpj
    <%if (motor.getBloqueado()) {%>
            $("chkbloqueado").checked = true;
    <%} else {%>
            $("chkbloqueado").checked = false;
    <%}%>
            $("funcao").value = '<%=motor.getFuncaoTripulante().getId()%>'
            $("categoria").value = '<%=motor.getCategoria()%>'
            $("sexo").value = '<%= motor.getSexo() %>'
            $("calculoValorContratoFrete").value = ('<%= motor.getCalculoValorContratoFrete() %>' == null ? '' : '<%= motor.getCalculoValorContratoFrete() %>') 
            if('<%= motor.getCalculoValorContratoFrete() %>' == "nf") {
                $("tipoCalculoPercentualValorCFe").hide();
            }
    <%}%>
            alteraCategoria();
        }

        function isMope(){
            var checado = $("mope").checked;

            if (checado){
                //visivel($("divValidadeMope2"));
            }else{
                //invisivel($("divValidadeMope2"));

            }
      
            var s = '<%=(carregamotorista ? (motor.getTipoComissao()) : " ")%>' ;
      
            if(s == "l"){
                $("sobreL").checked = true;
            }else if(s == "b"){
                $("sobreB").checked = true;
            }else if(s == "p"){
                $("sobreP").checked = true;
            }
        }

        function alteraCategoria(){
            if ($('categoria').value == 'tr'){
                $('lbCnh').innerHTML = "CIR:";
                $('prontuario').style.display = "none";
                $('lbLiberacao').innerHTML = "Função:";
                $('lbValidade').innerHTML = "";
                $('liberacao').style.display = "none";
                $('vencimento_lib').style.display = "none";
                //$('trCartaFrete1').style.display = "none";
                //$('trCartaFrete2').style.display = "none";
                //$('trCartaFrete3').style.display = "none";
                $('car_placa').style.display = "none";
                $('localiza_veiculo2').style.display = "none";
                $('imgCarreta').style.display = "none";
                $('funcao').style.display = "";
                $('lbVeiculo').innerHTML = "Embarcação:";
                $('lbCarreta').innerHTML = "";
                $('lbBiTrem').innerHTML = "";
                $('inBiTrem').style.display = "none";
                $('lbTriTrem').innerHTML = "";
                $('inTriTrem').style.display = "none";
            }else{
                $('lbCnh').innerHTML = "<%=cfg.isMotoristaCNHObrigatorio() ? "*" : ""%>CNH:";
                $('prontuario').style.display = "";
                $('lbLiberacao').innerHTML = "Liberação Seguradora:";
                $('lbValidade').innerHTML = "Validade:";
                $('liberacao').style.display = "";
                $('vencimento_lib').style.display = "";
                //$('trCartaFrete1').style.display = "";
                //$('trCartaFrete2').style.display = "";
                //$('trCartaFrete3').style.display = "";
                $('car_placa').style.display = "";
                $('localiza_veiculo2').style.display = "";
                $('imgCarreta').style.display = "";
                $('funcao').style.display = "none";
                $('lbVeiculo').innerHTML = "<%=cfg.isMotoristaVeiculoObrigatorio() ? "*" : ""%>Veículo:";
                $('lbCarreta').innerHTML = "Carreta:";
                $('lbBiTrem').innerHTML = "Bi-Trem:";
                $('inBiTrem').style.display = "";
                $('lbTriTrem').innerHTML = "3º Reboque:";
                $('inTriTrem').style.display = "";
            }
        }

        function popImg(id, nome, cpf){
            window.open('./ImagemControlador?acao=carregar&isFoto=true&nome='+nome+'&cpf='+cpf+'&idmotorista='+id,
            'imagensMoto','top=80,left=70,height=250,width=600,resizable=yes,status=1,scrollbars=1');
        }

//        function alteraPercentualAdiantamento(){
//            if (< %=nivelUserAdiantamento == 0%>){
//                var percConfig = < %=cfg.getPercentualAdiantamentoContratoFrete()%>;
//                var percMotorista = $('percentualAdiantamento').value;
//                if (parseFloat(percMotorista) > parseFloat(percConfig)){
//                    alert('Você não tem permissão para atribuir ' + percMotorista + '% para o adiantamento do motorista!');
//                    $('percentualAdiantamento').value = percConfig;
//                }
//            }
//        }
        function aoCarregar(){
            $("trSalarioMotorista_").style.display = "";
                       
              <%
                negociacaoMotor = new ArrayList<NegociacaoAdiantamentoFrete>();
                Consulta filtros = new Consulta();
                filtros.setCampoConsulta("descricao");
                filtros.setLimiteResultados(10000000);
                filtros.setOperador(Consulta.TODAS_AS_PARTES);
                NegociacaoAdiantamentoFreteBO negoBO = new NegociacaoAdiantamentoFreteBO();
                negociacaoMotor = negoBO.carregarCombo();
            %>          
                       
            <%
            if(carregamotorista){%>
                
                <%for (MotoristaSalario sal : motor.getListaMotoristaSalario()){%>
                   var motoristaSalario = new SalarioMotorista();
                   motoristaSalario = new SalarioMotorista('<%=sal.getId()%>','<%=sal.getIdMotorista().getId()%>','<%=sal.getVigenciaSalarioEm()%>','<%=sal.getValorSalario()%>', '<%=sal.getValorCustoAdcional()%>');
                   addNovosSalariosMotoristas(motoristaSalario);
                <%}
            }
            %>
                    
            $("negociacaoAdiantamento").value = '<%= carregamotorista ? motor.getNegociacaoAdiantamento() : 0 %>';
            
            
            <%
                 if (carregamotorista) {%>
                
                 <%for (Ocorrencia oco : motor.getOcorrenciaMotorista()) {%>
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
                   
                 <%}
                     }
                 %>
                  
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
                var rotina = "motorista";
                var dataDe = $("dataDeAuditoria").value;
                var dataAte = $("dataAteAuditoria").value;
                var id = <%=carregamotorista ? motor.getIdmotorista() : 0 %>;
                consultarLog(rotina, id, dataDe, dataAte);
                
            }
            function setDataAuditoria(){
            var data = "<%=Apoio.getDataAtual()%>";
            if ($("dataDeAuditoria") != null) {
                $("dataDeAuditoria").value="<%=carregamotorista ? Apoio.getDataAtual() :  "" %>" ;   
                $("dataAteAuditoria").value="<%=carregamotorista ? Apoio.getDataAtual() : "" %>" ;   
            }

        }
        
        function importarEfrete(){
//            var cpf = $("cpf").value;
//            var cnh = $("cnh").value;
//            
//            if(cpf == "" || cpf.trim() == ""){
//                alert("O campo 'CPF' não pode ficar vazio");
//                return false;
//            }
//            if(cnh == "" || cnh.trim() == ""){
//                alert("O campo 'CNH' não pode ficar vazio.");
//                return false;
//            }
//            
//            //AJAX BUSCANDO O MOTORISTA NO EFRETE
//            espereEnviar("Aguarde...",true);
//            function e(transport){
//                var textoresposta = transport.responseText;
//               
//                var motoristaObj = jQuery.parseJSON(textoresposta);
//                var motorista = motoristaObj.motoristaRetornado;
//                
//                if(motorista.statusRetornoEfrete != null && motorista.statusRetornoEfrete == ""){
//                    $("cpf").value = motorista.cpf;
//                    $("cnh").value = motorista.cnh;
//                    $("nomemae").value = motorista.nomemae;
//                    $("complemento").value = motorista.complemento;
//
//                    $("ddd").value = motorista.telefone.split("!!")[0];
//                    $("telefone").value = motorista.telefone.split("!!")[1];
//
//                    $("ddd2").value = motorista.telefone2.split("!!")[0];
//                    $("telefone2").value = motorista.telefone2.split("!!")[1];
//
//                    $("nome").value = motorista.nome;
//                    $("cep").value = motorista.cep;
//                    $("complemento").value = motorista.complemento;
//                    $("numeroLogradouro").value = motorista.numeroLogradouro;
//                    $("datanasc").value = motorista.dataNascStr;
//                    
//                    getEnderecoByCep($("cep").value);
//                    alert("Motorista importado com sucesso!");
//                }else{
//                    alert(motorista.statusRetornoEfrete);
//                }
//                
//                
//                espereEnviar("Aguarde...",false);
//
//            }
//            tryRequestToServer(function(){
//                new Ajax.Request('EFreteControlador?acao=carregarMotoristaEFrete&cpf='+cpf+'&cnh='+cnh,{method:'post', onSuccess: e, onError: e});
//            });
           alert("ATENÇÃO! Na versão de integração 5.0 a opção de importar dados dos motoristas foi descontinuada pela E-Frete.");
        }
 
        function verPontosControle(idMotorista, nomeMotorista){
            var data = "<%=Apoio.getDataAtual()%>";
            window.open('./PontoControleControlador?acao=visualizarPontoControle&motoristaId='+idMotorista+'&nomeMotorista='+nomeMotorista+'&tipoPesquisa=motorista&dataDe='+data+'&dataAte='+data, 'pontoControle' , 'top=0,resizable=yes,status=1,scrollbars=1');
        }
    
        function importarCartaoTarget() {
            var cpf = $("cpf").value;
            
            if (cpf == "" || cpf.trim() == ""){
                alert("O campo 'CPF' não pode ficar vazio");
                return false;
            }
            
            // AJAX BUSCANDO O MOTORISTA NO TARGET
            espereEnviar("Aguarde...", true);

            function e(transport) {
                try {
                    var textoresposta = transport.responseText;

                    var motoristaObj = jQuery.parseJSON(textoresposta);
                    var motorista = motoristaObj.motoristaRetornado;

                    if (motorista == undefined || motorista == null) {
                        alert('Ocorreu um erro interno de sistema!');
                    } else if (motorista.erro != null) {
                        alert(motorista.erro.mensagemErro);
                    } else {
                        $("cpf").value = motorista.cpf;
                        $("nomemae").value = motorista.nomeMae;
                        $("nomepai").value = motorista.nomePai;
                        $("rg").value = motorista.numeroRG;
                        $("emailMotorista").value = motorista.email;
                        $("telefone").value = motorista.telefone;
                        $("telefone2").value = motorista.telefoneCelular;
                        $("nacionalidade").value = motorista.nacionalidade;
                        $("bairro").value = motorista.bairro;
                        $("orgao_rg").value = motorista.orgaoEmissorRg;
                        var dataNascimento = new Date(motorista.dataNascimento.replace(/-/g, '/'));

                        $("datanasc").value = (fillZero((dataNascimento.getDate()), 2) + "/" + fillZero(dataNascimento.getMonth() + 1, 2) + "/" + dataNascimento.getFullYear()).toString();

                        $("complemento").value = motorista.enderecoComplemento;

                        $("nome").value = motorista.nome + " " + motorista.sobrenome;
                        $("cep").value = motorista.cep;

                        if (motorista.sexo != 'S') {
                            jQuery('#sexo').val(motorista.sexo);
                        }

                        getEnderecoByCep($("cep").value);

                        $("numeroLogradouro").value = motorista.numeroPorta;
                        $("endereco").value = motorista.endereco;

                        alert("Motorista importado com sucesso!");
                    }

                    espereEnviar("Aguarde...", false);
                } catch (e) {
                    
                    alert("Ocorreu um erro ao importar Motorista do servidor Target!");
                    
                    espereEnviar("Aguarde...", false);
                }
            }

            tryRequestToServer(function() {
                new Ajax.Request('TargetControlador?acao=carregarMotorista&cpf=' + cpf, {
                    method:'post',
                    onSuccess: e,
                    onError: e
                });
            });
        }
        
        function isOcultoOptionValorContrato() {
            var selectCalculoValorContratoFrete = document.getElementById("calculoValorContratoFrete");
            if (selectCalculoValorContratoFrete.selectedIndex == 1) {
                document.getElementById("tipoCalculoPercentualValorCFe").style.display = "none";
            } else {
                document.getElementById("tipoCalculoPercentualValorCFe").style.display = "inline";
            }
        }
        
          
    function resolveuOcorrencia(idx){
        if ($('resolvido_'+idx).checked){            
            $('usuarioResolucao_' + idx).innerHTML = '<%=Apoio.getUsuario(request).getNome()%>';
            $('idUsuarioResolucao_' + idx).value = '<%=Apoio.getUsuario(request).getId()%>';
            $('dataResolucao_' + idx).value = '<%=Apoio.getDataAtual()%>';
            $('horaResolucao_' + idx).value = '<%=new SimpleDateFormat("HH:mm").format(new Date())%>';
        }else{
            $('usuarioResolucao_' + idx).innerHTML = '';
            $('idUsuarioResolucao_' + idx).value = '';
            $('dataResolucao_' + idx).value = '';
            $('horaResolucao_' + idx).value = '';
        }
    }
        
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt">
        <meta http-equiv="cache-control" content="no-cache">
        <meta http-equiv="pragma" content="no-store">
        <meta http-equiv="expires" content="0">
        <meta name="language" content="pt-br">

        <title>WebTrans - Cadastro de Motoristas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="stylesheets/tabs.css" type="text/css" media="all">
    </head>
    <body onLoad="javascript:atribuicombos();javascript:seAlterando();isMope();alteraTipo();aoCarregar();setDataAuditoria()">
        <img src="img/banner.gif" >
        <form method="post" action="" id="formulario" target="pop">
        <input type="hidden" id="idveiculo" name="idveiculo" value="<%=(carregamotorista ? String.valueOf(motor.getVeiculo().getIdveiculo()) : "0")%>">
        <input type="hidden" id="idcarreta" name="idcarreta" value="<%=(carregamotorista ? String.valueOf(motor.getCarreta().getIdveiculo()) : "0")%>">
        <input type="hidden" id="idbitrem"  name="idbitrem"  value="<%=(carregamotorista ? String.valueOf(motor.getBiTrem().getIdveiculo()) : "0")%>">
        <input type="hidden" id="idtritrem"  name="idtritrem"  value="<%=(carregamotorista ? String.valueOf(motor.getTritrem().getIdveiculo()) : "0")%>">
        <input type="hidden" id="idcidadeorigem" value="0">
        <input type="hidden" id="uf_origem" value="0">
        <input type="hidden" id="cid_origem" value="0">
        <input type="hidden" id="vei_tipofrota" value="0">        
        <input type="hidden" id="tipofrota" value="<%=(carregamotorista ? motor.getVeiculo().getTipoFrota() : "")%>">
        <input type="hidden" name="maxSalario" id="maxSalario" value="0"> 
        <input type="hidden" name="ocorrencia_id" id="ocorrencia_id" value="0"> 
        <input type="hidden" name="ocorrencia" id="ocorrencia"> 
        <input type="hidden" name="descricao_ocorrencia" id="descricao_ocorrencia">  
        <input type="hidden" name="maxOcorrencia" id="maxOcorrencia" value="0"> 
        <input type="hidden" name="ocorrenciaExcluir" id="ocorrenciaExcluir">
        <input type="hidden" name="obriga_resolucao" id="obriga_resolucao">
        
        <br>
        <div align="center">
            <table width="70%" align="center" class="bordaFina" >
                <tr>
                    <td width="30%">
                        <div align="left">
                            <b>Cadastro de Motoristas</b>
                        </div>
                    </td>
                    <td>
                        <% if (!acao.equals("iniciar")) { %>
                            <input type="button" class="botoes" value="Pontos de Controle" onclick="javascript: verPontosControle(<%= carregamotorista ? motor.getIdmotorista() : 0 %>,'<%=(motor != null ? motor.getNome() : "")%>')" >
                        <% } %>
                    </td>
                    <td width="148">
                        <%if (!acao.equals("iniciar")) {%>
                        <input  name="consulta_carta" type="button" class="botoes" id="consulta_carta" onClick="javascript:tryRequestToServer(function(){window.open('./consulta_saldo_carta.jsp?acao=consultar&idmotorista=<%=carregamotorista ? motor.getIdmotorista() : 0%>&motor_nome=<%=carregamotorista ? motor.getNome() : ""%>&idproprietario=0&nome=&dtinicial=01/01/2007&dtfinal=31/12/2010&ctrc=&idveiculo=0&vei_placa=', 'Carta_frete' , 'top=0,resizable=yes,status=1,scrollbars=1');});" value="Consultar fretes" alt="Volta para o menu principal">
                    </td>
                    <%}%>   
                    <%if(acao.equals("iniciar") && Apoio.getUsuario(request).getFilial().getStUtilizacaoCfe() == "E".charAt(0)){%>
                    <td width="10%">
                        <div align="right">
                            <input name="importarEFrete" type="button" name="importarEFrete" value="Importar E-Frete" class="botoes" onclick="javascript:importarEfrete();"/>
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
                    <td width="10%">
                        <div align="right">
                            <% if ((nivelUser == 4 && request.getParameter("ex") != null)) //se o paramentro vier com valor diferente de nulo ai pode excluir
                                {%>
                            <input  name="excluir" type="button" class="botoes" value="Excluir" alt="Exclui o Motorista atual" onClick="javascript:excluirmotorista();">
                            <%}%>
                        </div>
                    </td>
                    <td width="10%" >
                        <div align="right">
                            <input  name="Button" type="button" class="botoes" value="Voltar para Consulta" alt="Volta para o menu principal" onClick="javascript:voltar();">
                        </div>
                    </td>
                </tr>
            </table>
            <br>
            <table width="70%" border="0" align="center" cellpadding="2" class="bordaFina">
                <tr class="tabela">
                    <td colspan="5" align="center">
                        <div align="center">
                            <strong>Dados Principais</strong>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos" width="10%">Código(id):</td>
                    <td class="CelulaZebra2" width="40%">
                        <b><%=(motor != null ? motor.getIdmotorista() : "")%></b>
                    </td>
                    <td class="TextoCampos" width="15%">Categoria:</td>
                    <td class="CelulaZebra2" width="25%">
                        <select name="categoria" id="categoria" style="font-size:8pt;width: 140px;" onChange="alteraCategoria();" class="inputtexto">
                            <option value="mo" selected>Motorista (Transporte Rodoviário)</option>
                            <option value="tr">Tripulante (Transporte Marítimo/Fluvial)</option>
                        </select>
                    </td>

                    <td class="TextoCampos" width="10%" rowspan="3">
                        <div align="center">
                            <% if (acao.equals("editar")) {
                                    boolean isAchouFoto = false;
                                    MotoristaImagem imagem = (MotoristaImagem) request.getAttribute("imagem");
        if (imagem != null && imagem.isFoto()) {%>
                                        <img width="60px" height="80px" src="img/motorista/<%=imagem.getMotoristaId() + "_" + imagem.getId()%>.jpg" class="imagemLink" alt="Foto 3X4" onClick="javascript:tryRequestToServer(function(){popImg('<%=(motor != null ? motor.getIdmotorista() : 0)%>','<%=(motor != null ? motor.getNome() : "")%>','<%=(motor != null ? motor.getCpf() : "")%>');});" />
                                    <%}else{%>
                                        <img width="60px" height="80px" src="img/foto3_4.jpg" class="imagemLink" alt="Foto 3X4" onClick="javascript:tryRequestToServer(function(){popImg('<%=(motor != null ? motor.getIdmotorista() : 0)%>','<%=(motor != null ? motor.getNome() : "")%>','<%=(motor != null ? motor.getCpf() : "")%>');});" />
                                    <%}%>
                            <%}%>
                               
                        </div>
                    </td>

                </tr>
                <tr>
                    <td class="TextoCampos">Nome:</td>
                    <td class="CelulaZebra2">
                        <input name="nome" type="text" id="nome" value="<%=(motor != null ? motor.getNome() : "")%>" size="40" maxlength="40" class="inputtexto">
                    </td>
                    <td class="TextoCampos">Apelido:</td>
                    <td class="CelulaZebra2">
                        <input name="apelido" type="text" id="apelido" value="<%=(motor == null || motor.getApelido() == null ? "" : motor.getApelido())%>" size="20" maxlength="20" class="inputtexto"/>
                    </td>
                    <td class="TextoCampos"></td>
                </tr>
                <tr>
                    <td class="TextoCampos" >Telefone Fixo:</td>
                    <td class="CelulaZebra2">
                        <input name="ddd" type="text" id="ddd" value="<%=(motor != null && motor.getDdd() != 0 ? motor.getDdd() : "")%>" size="2" maxlength="2" class="inputtexto">
                        <input name="telefone" type="text" id="telefone" value="<%=(motor != null ? motor.getTelefone() : "")%>" size="15" maxlength="13" class="inputtexto">
                    </td>
                    <td class="TextoCampos" >Telefone Celular:</td>
                    <td class="CelulaZebra2">
                        <input name="ddd2" type="text" id="ddd2" value="<%=(motor != null && motor.getDdd2() != 0 ? motor.getDdd2() : "")%>" size="2" maxlength="2" class="inputtexto">
                        <input name="telefone2" type="text" id="telefone2" value="<%=(motor != null ? motor.getTelefone2() : "")%>" size="15" maxlength="13" class="inputtexto">
                    </td>
                    <td class="TextoCampos"></td>

                </tr>
            </table>
            <br>
      
            <div id="container" style="width: 70%" align="center">
                <div align="center">
                    <ul id="tabs">
                        <li>
                            <a href="#tab1">
                                <strong>Dados Pessoais</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab2">
                                <strong>Documentação</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab3">
                                <strong>Dados Operacionais</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab4">
                                <strong>Ocorr&ecirc;ncias</strong>
                            </a>
                        </li>
                        <li>
                            <a href="#tab5">
                                <strong>Sal&aacute;rios</strong>
                            </a>
                        </li>
                        <%if (carregamotorista && nivelUser == 4 ) {%>                        
                        <li>
                            <a href="#tab6">
                                <strong>Auditoria</strong>
                            </a>
                        </li>
                        <% } %>
                    </ul>
                </div>
                <div class="panel" id="tab1">
                    <fieldset>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="4" align="center">
                                    <div align="center">
                                        <strong>Endereço</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" width="10%">CEP:</td>
                                <td class="CelulaZebra2" width="40%">
                                    <input name="cep" type="text" id="cep" value="<%=(motor != null ? motor.getCep() : "")%>" size="10" maxlength="9" onchange="limparEndereco();" onBlur="getEnderecoByCep(this.value)" class="fieldMin">
                                </td>
                                <td class="TextoCampos" width="10%">Endereço:</td>
                                <td class="CelulaZebra2" width="40%">
                                    <input name="endereco" type="text" id="endereco" value="<%=(motor != null ? motor.getEndereco() : "")%>" size="40" maxlength="50" class="fieldMin">
                                    <input name="numeroLogradouro" type="text" id="numeroLogradouro" value="<%=motor != null ? motor.getNumeroLogradouro() : ""%>"  size="4" maxlength="10" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >Bairro:</td>
                                <td class="CelulaZebra2">
                                    <input name="bairro" type="text" id="bairro" value="<%=(motor != null ? motor.getBairro() : "")%>" size="35" maxlength="25" class="fieldMin">
                                </td>
                                <td class="TextoCampos" >Complem.:</td>
                                <td class="CelulaZebra2">
                                    <input name="complemento" type="text" id="complemento" value="<%=(motor != null ? motor.getComplemento() : "")%>" size="48" maxlength="40" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >*Cidade:</td>
                                <td class="CelulaZebra2">
                                    <input name="cidade" type="text" id="cidade" size="35" class="inputReadOnly8pt" readonly="true" value="<%=(motor != null ? motor.getCidade().getDescricaoCidade() : "")%>">
                                    <input name="uf" type="text" id="uf" size="3" class="inputReadOnly8pt" readonly="true" value="<%=(motor != null ? motor.getCidade().getUf() : "")%>">
                                    <input name="btn"  type="button" class="botoes" id="btn" onClick="localizaCidade();" value="...">
                                    <input type="hidden" id="idCidade" name="idCidade" value="<%=(motor != null ? motor.getCidade().getIdcidade() : "0")%>">
                                </td>
                                <td class="TextoCampos" width="5%">Sexo:</td>
                                <td class="CelulaZebra2" width="10%">
                                    <select name="sexo" id="sexo" class="inputtexto" style="font-size:8pt;width: 140px;">
                                        <option value="M" selected="">Masculino</option>
                                        <option value="F" >Feminino</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >Nascimento:</td>
                                <td class="CelulaZebra2">
                                    <input name="datanasc" type="text" id="datanasc" size="10" maxlength="10" onblur="alertInvalidDate(this,true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="inputtexto"/>
                                </td>
                                <td class="TextoCampos" >Naturalidade:</td>
                                <td class="CelulaZebra2">
                                    <input name="cidNaturalidade" type="text" id="cidNaturalidade" size="30" class="inputReadOnly8pt" readonly="true" value="<%=(motor != null ? motor.getCidadeNaturalidade().getCidade() : "")%>">
                                    <input name="ufNaturalidade" type="text" id="ufNaturalidade" size="3" class="inputReadOnly8pt" readonly="true" value="<%=(motor != null ? motor.getCidadeNaturalidade().getUf() : "")%>">
                                    <input name="btn_origem"  type="button" class="botoes" id="btn_origem" onClick="localizaCidadeNaturalidade();" value="...">
                                    <img src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaCidadeNaturalidade();">
                                    <input type="hidden" id="idCidadeNaturalidade" name="idCidadeNaturalidade" value="<%=(motor != null ? motor.getCidadeNaturalidade().getIdcidade() : "0")%>">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Nacionalidade:</td>
                                <td class="CelulaZebra2">
                                    <input name="nacionalidade" type="text" id="nacionalidade" value="<%=(motor != null ? motor.getNacionalidade() : "")%>" size="40" maxlength="50" class="fieldMin">
                                </td>
                                <td class="TextoCampos" colspan="2"></td>
                            </tr>
                            <tr class="tabela">
                                <td colspan="4" align="center">
                                    <div align="center">
                                        <strong>Outras informações</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >Est. civil:</td>
                                <td class="CelulaZebra2">
                                    <select name="idestadocivil" id="idestadocivil" class="fieldMin">
                                        <option value="1" selected>Solteiro</option>
                                        <option value="2">Casado</option>
                                        <option value="3">Vi&uacute;vo</option>
                                        <option value="4">Divorciado</option>
                                        <option value="5">Desquitado</option>
                                        <option value="10">Outros</option>
                                    </select>
                                </td>
                                <td class="TextoCampos" >QTD Dep.:</td>
                                <td class="CelulaZebra2">
                                    <input name="qtdDependentes" type="text" id="qtdDependentes" onChange="seNaoIntReset(this,'0');"
                                           value="<%=(motor != null ? motor.getQtdDependentes() : "0")%>" size="8" maxlength="4"
                                           class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >Nome Pai:</td>
                                <td class="CelulaZebra2">
                                    <input name="nomepai" type="text" id="nomepai" value="<%=(motor != null ? motor.getNomepai() : "")%>" size="40" maxlength="40" class="fieldMin">
                                </td>
                                <td class="TextoCampos" >Nome Mãe:</td>
                                <td class="CelulaZebra2">
                                    <input name="nomemae" type="text" id="nomemae" value="<%=(motor != null ? motor.getNomemae() : "")%>" size="40" maxlength="40" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >Grau de escolaridade:</td>
                                <td class="CelulaZebra2">
                                    <input name="grauEscolaridade" type="text" id="grauEscolaridade" value="<%=(motor != null ? (motor.getGrauEscolaridade() != null ? motor.getGrauEscolaridade() : "") : "")%>" size="40" maxlength="30" class="fieldMin">
                                </td>
                                <td class="TextoCampos" >Qualificação Profissional:</td>
                                <td class="CelulaZebra2">
                                    <input name="qualificacaoProfissional" type="text" id="qualificacaoProfissional" value="<%=(motor != null ? (motor.getQualificacaoProfissional() != null ? motor.getQualificacaoProfissional() : "") : "")%>" size="40" maxlength="100" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos">Email:</td>
                                <td class="CelulaZebra2">
                                    <input name="emailMotorista" type="text" id="emailMotorista" value="<%=(motor != null ? (motor.getEmail() != null ? motor.getEmail() : "") : "")%>" size="40" maxlength="30" class="fieldMin">
                                </td>
                                <td class="TextoCampos" colspan="2"></td>
                            </tr>
                            <tr class="tabela">
                                <td colspan="4" align="center">
                                    <div align="center">
                                        <strong>Referências</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tr>
                                            <td colspan="2" class="celula">
                                                <div align="center">
                                                    <strong>Pessoais</strong>
                                                </div>
                                            </td>
                                            <td colspan="2" class="celula">
                                                <div align="center">
                                                    <strong>Comerciais</strong>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="34%" bgcolor="#EADEC8" class="CelulaZebra2">
                                                <font size="2">Nome</font>
                                            </td>
                                            <td width="16%" bgcolor="#EADEC8" class="CelulaZebra2">
                                                <font size="2">Telefone</font>
                                            </td>
                                            <td width="34%" bgcolor="#EADEC8" class="CelulaZebra2">
                                                <font size="2">Nome</font>
                                            </td>
                                            <td width="16%" bgcolor="#EADEC8" class="CelulaZebra2">
                                                <font size="2">Telefone</font>
                                            </td>
                                        </tr>
                                        <tr class="CelulaZebra2">
                                            <td>
                                                <input name="refpessoal" type="text" id="refpessoal" value="<%=(motor != null ? motor.getRefpessoal() : "")%>" size="35" maxlength="30" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="fonerefpessoal" type="text" id="fonerefpessoal" value="<%=(motor != null ? motor.getFonerefpessoal() : "")%>" size="15" maxlength="13" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="refcomercial" type="text" id="refcomercial" value="<%=(motor != null ? motor.getRefcomercial() : "")%>" size="35" maxlength="30" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="fonerefcomercial" type="text" id="fonerefcomercial" value="<%=(motor != null ? motor.getFonerefcomercial() : "")%>" size="15" maxlength="13" class="fieldMin">
                                            </td>
                                        </tr>
                                        <tr class="CelulaZebra2">
                                            <td>
                                                <input name="refpessoal2" type="text" id="refpessoal2" value="<%=(motor != null ? motor.getRefpessoal2() : "")%>" size="35" maxlength="30" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="fonerefpessoal2" type="text" id="fonerefpessoal2" value="<%=(motor != null ? motor.getFonerefpessoal2() : "")%>" size="15" maxlength="13" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="refcomercial2" type="text" id="refcomercial2" value="<%=(motor != null ? motor.getRefcomercial2() : "")%>" size="35" maxlength="30" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="fonerefcomercial2" type="text" id="fonerefcomercial2" value="<%=(motor != null ? motor.getFonerefcomercial2() : "")%>" size="15" maxlength="13" class="fieldMin">
                                            </td>
                                        </tr>
                                        <tr class="CelulaZebra2">
                                            <td>
                                                <input name="refpessoal3" type="text" id="refpessoal3" value="<%=(motor != null ? motor.getRefpessoal3() : "")%>" size="35" maxlength="30" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="fonerefpessoal3" type="text" id="fonerefpessoal3" value="<%=(motor != null ? motor.getFonerefpessoal3() : "")%>" size="15" maxlength="13" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="refcomercial3" type="text" id="refcomercial3" value="<%=(motor != null ? motor.getRefcomercial3() : "")%>" size="35" maxlength="30" class="fieldMin">
                                            </td>
                                            <td>
                                                <input name="fonerefcomercial3" type="text" id="fonerefcomercial3" value="<%=(motor != null ? motor.getFonerefcomercial3() : "")%>" size="15" maxlength="13" class="fieldMin">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div class="panel" id="tab2">
                    <fieldset>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="8" align="center">
                                    <div align="center">
                                        <strong>Documentação</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" width="8%">*CPF:</td>
                                <td class="CelulaZebra2" width="17%">
                                    <input name="cpf" type="text" id="cpf" onKeyPress="javascript:digitaCpf();" value="<%=(motor != null ? motor.getCpf() : "")%>" size="18" maxlength="14" class="fieldMin">
                                </td>
                                <td class="TextoCampos" width="10%">PIS/PASEP:</td>
                                <td class="CelulaZebra2" width="15%">
                                    <input name="pisPasep" type="text" id="pisPasep" value="<%=(motor != null && !motor.getPisPasep().equals("") ? motor.getPisPasep() : "")%>" size="15" maxlength="20" class="fieldMin" />
                                </td>
                                <td class="TextoCampos" width="10%"></td>
                                <td class="CelulaZebra2" width="15%"></td>
                                <td class="TextoCampos" width="10%"></td>
                                <td class="CelulaZebra2" width="15%"></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" ><%=cfg.isMotoristaRGOrgaoObrigatorio() ? "*" : ""%>RG:</td>
                                <td class="CelulaZebra2">
                                    <input name="rg" type="text" id="rg" value="<%=(motor != null && motor.getRg() != null ? motor.getRg() : "")%>" size="12" maxlength="15" class="fieldMin">
                                </td>
                                <td class="TextoCampos" >Orgão Emissor:</td>
                                <td class="CelulaZebra2">
                                    <input name="orgao_rg" type="text" id="orgao_rg" value="<%=(motor != null && motor.getOrgao_rg() != null ? motor.getOrgao_rg() : "")%>" size="15" maxlength="10" class="fieldMin">
                                    <input name="uf_rg" type="text" id="uf_rg" value="<%=(motor != null && motor.getUfEmissaoRg()!= null ? motor.getUfEmissaoRg(): "")%>" size="2" maxlength="2" class="fieldMin">
                                </td>
                                <td class="TextoCampos" ><%=cfg.isMotoristaDataEmissaoRGObrigatorio() ? "*" : ""%>Emissão:</td>
                                <td class="CelulaZebra2">
                                    <input name="dataemissaorg" type="text" id="dataemissaorg" size="10" maxlength="10" onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
                                </td>
                                <td class="TextoCampos" >Local de Emissão:</td>
                                <td class="CelulaZebra2">
                                    <input name="localemissaorg" type="text" id="localemissaorg" value="<%=(motor != null ? motor.getLocalemissaorg() : "")%>" size="15" maxlength="10" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" ><label id="lbCnh" name="lbCnh"><%=cfg.isMotoristaCNHObrigatorio() ? "*" : ""%>CNH:</label></td>
                                <td class="CelulaZebra2" >
                                    <input name="cnh" type="text" id="cnh" value="<%=(motor != null ? motor.getCnh() : "")%>" size="15" maxlength="12" class="fieldMin">
                                </td>
                                <td class="TextoCampos" >Prontuário:</td>
                                <td class="CelulaZebra2" >
                                    <input name="prontuario" type="text" id="prontuario" value="<%=(motor != null ? motor.getProntuario() : "")%>" size="15" maxlength="12" class="fieldMin">
                                </td>
                                <td class="TextoCampos" ><%=cfg.isMotoristaDataEmissaoCNHObrigatorio() ? "*" : ""%>Emissão:</td>
                                <td class="CelulaZebra2" >
                                    <input name="dataemissaocnh" type="text" id="dataemissaocnh" size="10" maxlength="10"
                                           onblur="alertInvalidDate(this,true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
                                </td>
                                <td class="TextoCampos" >Local de Emissão:</td>
                                <td class="CelulaZebra2" >
                                    <input name="localemissaocnh" type="text" id="localemissaocnh" value="<%=(motor != null ? motor.getLocalemissaocnh() : "")%>" size="15" maxlength="10" class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" ><%=cfg.isMotoristaVencimentoObrigatorio() ? "*" : ""%>Validade:</td>
                                <td class="CelulaZebra2" >
                                    <input name="vencimentocnh" type="text" id="vencimentocnh" size="10" maxlength="10"
                                           onblur="alertInvalidDate(this,true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
                                </td>
                                <td class="TextoCampos" >Categoria:</td>
                                <td class="CelulaZebra2" >
                                    <select name="categcnh" id="categcnh" class="inputtexto">
                                        <option value="A">A</option>
                                        <option value="B">B</option>
                                        <option value="C" selected>C</option>
                                        <option value="D">D</option>
                                        <option value="E">E</option>
                                        <option value="AB">AB</option>
                                        <option value="AC">AC</option>
                                        <option value="AD">AD</option>
                                        <option value="AE">AE</option>
                                    </select>
                                </td>
                                <td class="TextoCampos" >Emissão 1ª CNH:</td>
                                <td class="CelulaZebra2" >
                                    <input name="primeiraHabilitacaoEm" type="text" id="primeiraHabilitacaoEm" size="10" maxlength="10"
                                           onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)"
                                           onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
                                </td>
                                <td class="TextoCampos" >Cód. Segurança CNH: </td>
                                <td class="CelulaZebra2" ><input type="text" class="fieldMin" id="codSegurancaCNH" name="codSegurancaCNH" size="12" maxlength="11" value="<%= motor != null && motor.getCodSegurancaCNH() != null ? motor.getCodSegurancaCNH() : "" %>"></td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" >Nº Título:</td>
                                <td class="CelulaZebra2" > <input type="text" id="tituloEleitor" name="tituloEleitor" 
                                                                  value="<%=(motor != null && !(motor.getTituloEleitor() == "")? motor.getTituloEleitor() : "")%>"  size="13" maxlength="12" onkeypress="mascara(this,soNumeros)"   class="inputTexto"> </td>
                                <td class="TextoCampos" >Zona Eleitoral:</td> 
                                <td class="CelulaZebra2" > <input type="text" id="zonaEleitoral" name="zonaEleitoral" 
                                    value="<%=(motor != null && (motor.getZonaEleitoral() != 0) ? motor.getZonaEleitoral() : "" ) %>" size="3" maxlength="5" onkeypress="mascara(this,soNumeros)"  class="inputTexto"> </td>
                                <td class="TextoCampos">Seção Eleitoral:</td>
                                <td class="CelulaZebra2"> <input type="text" id="secaoEleitoral" name="secaoEleitoral" 
                                    value="<%=(motor != null && (motor.getSecaoEleitoral() != 0) ? motor.getSecaoEleitoral() : "" )%>" size="3" maxlength="5" onkeypress="mascara(this,soNumeros)" class="inputTexto"> </td>
                                <td class="CelulaZebra2" colspan="2"></td>
                            </tr>
                            <tr style="display:<%=(motor != null ? "" : "none")%>;">
                                <td class="TextoCampos" colspan="8">
                                    <div class="linkEditar" align="center" onClick="javascript:tryRequestToServer(function(){popImg('<%=(motor != null ? motor.getIdmotorista() : 0)%>','<%=(motor != null ? motor.getNome() : "")%>','<%=(motor != null ? motor.getCpf() : "")%>');});">
                                        Visualizar / Anexar Documentos
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                <div class="panel" id="tab3">
                    <fieldset>
                        <table width="100%" border="0" class="bordaFina">
                            <tr class="tabela">
                                <td colspan="5" align="center">
                                    <div align="center">
                                        <strong>Informações do Tipo de Motorista</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" width="5%">Tipo:</td>
                                <td class="CelulaZebra2" width="12%">
                                    <select name="tipo" id="tipo" onChange="javascript:alteraTipo();" class="inputtexto"
                                            <%=((nivelUser < 2) ? "disabled=true" : "")%>>
                                        <option value="f">Funcion&aacute;rio</option>
                                        <option value="a">Agregado</option>
                                        <option value="c" selected>Carreteiro</option>
                                    </select>
                                </td>
                                <td class="TextoCampos" width="15%">
                                    <div align="center">
                                        <input  type="checkbox" id="chkbloqueado" value="checkbox" <%=(carregamotorista && (nivelUser < 4) ? "disabled=true" : "")%>>
                                        Bloqueado
                                        <br>
                                        <input type="checkbox" id="desligado" <%=((motor != null && motor.isDesligado() ? "checked" : ""))%> >
                                        Desligado                                   
                                    </div>
                                </td>
                                <td class="TextoCampos" width="8%">Motivo:</td>
                                <td class="CelulaZebra2" width="60%">
                                    <input name="motivobloqueio" type="text" id="motivobloqueio" value="<%=(motor != null && motor.getMotivobloqueio() != null ? motor.getMotivobloqueio() : "")%>" size="75" maxlength="100"
                                           <%=(carregamotorista && (nivelUser < 4) ? "disabled=true" : "")%> class="fieldMin">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <table width="100%" border="0" cellspacing="1" cellpadding="2">
                                        <tr>
                                            <td width="10%" class="TextoCampos">
                                                <label id="lbVeiculo" name="lbVeiculo">Ve&iacute;culo:</label>
                                            </td>
                                            <td width="15%" class="CelulaZebra2">
                                                <input name="vei_placa" type="text" class="inputReadOnly" id="vei_placa" value="<%=(carregamotorista && motor.getVeiculo().getPlaca() != null ? motor.getVeiculo().getPlaca() : "")%>" size="10" readonly="true">
                                                <input name="localiza_veiculo" type="button" class="botoes" id="localiza_veiculo" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=7','Veiculo')" value="...">
                                                <strong>
                                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ve&iacute;culo" onClick="javascript:$('idveiculo').value = 0;javascript:$('vei_placa').value = '';javascript:$('vei_tipofrota').value='';">
                                                </strong>
                                            </td>
                                            <td width="10%" class="TextoCampos">
                                                <label id="lbCarreta" name="lbCarreta">Carreta:</label>
                                            </td>
                                            <td width="15%" class="CelulaZebra2">
                                                <input name="car_placa" type="text" class="inputReadOnly" id="car_placa" value="<%=(carregamotorista && motor.getCarreta().getPlaca() != null ? motor.getCarreta().getPlaca() : "")%>" size="10" readonly="true">
                                                <input name="localiza_veiculo2" type="button" class="botoes" id="localiza_veiculo2" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=9','Carreta')" value="...">
                                                <strong>
                                                    <img id="imgCarreta" name="imgCarreta" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:$('idcarreta').value = 0;javascript:$('car_placa').value = '';">
                                                </strong>
                                            </td>
                                            <td width="10%" class="TextoCampos">
                                                <label id="lbBiTrem" name="lbBiTrem">Bi-Trem:</label>
                                            </td>
                                            <td width="15%" class="CelulaZebra2">
                                                <label id="inBiTrem" name="inBiTrem">
                                                    <input name="bi_placa" type="text" class="inputReadOnly" id="bi_placa" value="<%=(carregamotorista && motor.getBiTrem().getPlaca() != null ? motor.getBiTrem().getPlaca() : "")%>" size="10" readonly="true">
                                                    <input name="localiza_veiculo3" type="button" class="botoes" id="localiza_veiculo3" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=51','BiTrem')" value="...">
                                                    <strong>
                                                        <img id="imgCarreta2" name="imgCarreta" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Carreta" onClick="javascript:$('idbitrem').value = 0;javascript:$('bi_placa').value = '';">
                                                    </strong>
                                                </label>
                                            </td>
                                            <td width="10%" class="TextoCampos">
                                                <label id="lbTriTrem" name="lbTriTrem">3º Reboque:</label>
                                            </td>
                                            <td width="15%" class="CelulaZebra2">
                                                <label id="inTriTrem" name="inTriTrem">
                                                    <input name="tri_placa" type="text" class="inputReadOnly" id="tri_placa" value="<%=(carregamotorista && motor.getTritrem().getPlaca() != null ? motor.getTritrem().getPlaca() : "")%>" size="10" readonly="true">
                                                    <input name="localiza_veiculo4" type="button" class="botoes" id="localiza_veiculo4" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=92','3º_Reboque')" value="...">
                                                    <strong>
                                                        <img id="imgCarreta3" name="imgCarreta" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar 3º Reboque" onClick="javascript:$('idtritrem').value = 0;javascript:$('tri_placa').value = '';">
                                                    </strong>
                                                </label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos" colspan="4">Motorista Alocado no Cliente:</td>
                                <td class="CelulaZebra2">
                                    <input name="idconsignatario" type="hidden" class="inputReadOnly8pt" id="idconsignatario" value="<%=(carregamotorista && motor.getCliente().getIdcliente() != 0 ? motor.getCliente().getIdcliente() : "0")%>" size="30" readonly="true">
                                    <input name="con_rzs" type="text" class="inputReadOnly8pt" id="con_rzs" value="<%=(carregamotorista && motor.getCliente().getRazaosocial() != null ? motor.getCliente().getRazaosocial() : "")%>" size="50" readonly="true">
                                    <input name="" type="button" class="botoes" id="" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=59','Cliente')" value="...">
                                    <strong>
                                        <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Cliente" onClick="javascript:$('idconsignatario').value = 0;javascript:$('con_rzs').value = '';">
                                    </strong>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" colspan="2" class="textoCampos">
                                    <div id="divDataAdmissao">Data de Admissão</div>
                                </td>
                                <td width="15%" class="CelulaZebra2">
                                    <input name="dataAdmissao" id="dataAdmissao" class="fieldMin" type="text" size="12" maxlength="10" onblur="alertInvalidDate(this, true)" onkeypress="fmtDate(this, event)">
                                </td>
                                <td width="15%" class="textoCampos">
                                    <div id="divDataDemissao">Data de Demissão</div>
                                </td>
                                <td width="15%" class="CelulaZebra2">
                                    <input name="dataDemissao" id="dataDemissao" class="fieldMin" type="text" size="12" maxlength="10" onblur="alertInvalidDate(this, true)" onkeypress="fmtDate(this, event)">
                                </td>
                                <td width="15%" class="textoCampos">
                                </td>

                            </tr>
                            <tr>
                                <td colspan="5" class="TextoCampos">
                                    <div align="center">
                                        % de comiss&atilde;o de frete:
                                        <input name="percentualComissaoFrete" type="text" id="percentualComissaoFrete" onChange="seNaoFloatReset(this,'0.00');" class="inputtexto"size="7" maxlength="10" value="<%=(carregamotorista ? Apoio.to_curr(motor.getPercentualComissaoFrete()) : "0.00")%>">
                                        <input type="radio" name="sobre" id="sobreB" />Sobre valor bruto
                                        <input type="radio" name="sobre" id="sobreL" checked="" />Sobre valor liquido
                                        <input type="radio" name="sobre" id="sobreP"  />Sobre Frete Peso
                                    </div>
                                </td>
                            </tr>
                            <tr class="tabela">
                                <td colspan="5" align="center">
                                    <div align="center">
                                        <strong>Informações Gerenciamento de Risco</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tr>
                                            <td class="TextoCampos" width="20%"><label id="lbLiberacao" name="lbLiberacao">Liberação Seguradora:</label></td>
                                            <td class="CelulaZebra2" width="30%">
                                                <input name="liberacao" type="text" id="liberacao" value="<%=(motor != null && motor.getLiberacao() != null ? motor.getLiberacao() : "")%>" size="20" maxlength="20" class="fieldMin"
                                                       <%=(carregamotorista && (nivelUser < 4 || motor.getTipo().equals("c")) ? "disabled=true" : "")%>>
                                                <%Funcao fn = new Funcao();
                                                    ResultSet rs = fn.all(Apoio.getUsuario(request).getConexao());%>
                                                <select name="funcao" id="funcao" class="fieldMin">
                                                    <option value="0">Nenhuma</option>
                                                    <%while (rs.next()) {%>
                                                    <option value="<%=rs.getString("id")%>"><%=rs.getString("descricao")%></option>
                                                    <%}
                                                        rs.close();%>
                                                </select>
                                            </td>
                                            <td class="TextoCampos" width="20%"><label id="lbValidade" name="lbValidade">Validade:</label></td>
                                            <td class="CelulaZebra2" width="30%">
                                                <input name="vencimento_lib" type="text" id="vencimento_lib" size="10" maxlength="10"
                                                       <%=(carregamotorista && (nivelUser < 4 || motor.getTipo().equals("c")) ? "disabled=true" : "")%>
                                                       onblur="alertInvalidDate(this, true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td  class="TextoCampos" colspan="2">
                                                <div align="center">
                                                    <input name="vitimaRoubo" type="checkbox" id="vitimaRoubo" value="checkbox" <%=(carregamotorista && motor.isVitimaRoubo() ? "checked" : "")%>>
                                                    J&aacute; foi v&iacute;tima de roubo
                                                    <input name="qtdVitimaRoubo" type="text" id="qtdVitimaRoubo" onChange="seNaoIntReset(this,'0');"
                                                           size="3" maxlength="3" value="<%=(carregamotorista ? motor.getQtdVitimaRoubo() + "" : "0")%>" class="fieldMin"> vezes
                                                </div>
                                            </td>
                                            <td class="TextoCampos" colspan="2">
                                                <div align="center">
                                                    <input name="vitimaAcidente" type="checkbox" id="vitimaAcidente" value="checkbox" <%=(carregamotorista && motor.isVitimaAcidente() ? "checked" : "")%>>
                                                    J&aacute; foi v&iacute;tima de acidente
                                                    <input name="qtdVitimaAcidente" type="text" id="qtdVitimaAcidente" onChange="seNaoIntReset(this,'0');"
                                                           size="3" maxlength="3" value="<%=(carregamotorista ? motor.getQtdVitimaAcidente() + "" : "0")%>" class="fieldMin"> vezes
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" colspan="2">
                                                <div align="center">
                                                    <input type="checkbox" id="mope" name="mope" onclick="isMope();" <%=(motor != null && motor.isMope() ? "checked" : "")%>>
                                                    Possui Curso MOPE
                                                </div>
                                            </td>
                                            <td class="TextoCampos">Validade Curso MOPE:</td>
                                            <td class="CelulaZebra2">
                                                <span id="divValidadeMope2">
                                                    <input name="dataValidadeMope"  type="text" id="dataValidadeMope" size="10" maxlength="10"
                                                           onblur="alertInvalidDate(this,true)" onKeyDown="fmtDate(this, event)" onkeyUp="fmtDate(this, event)" onKeyPress="fmtDate(this, event)" class="fieldMin"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr class="tabela">
                                <td colspan="5" align="center">
                                    <div align="center">
                                        <strong>Informações Contrato de Frete</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tr>
                                            <td class="TextoCampos" width="20%">Conta p/ Adiantamento:</td>
                                            <td class="CelulaZebra2" width="30%">
                                                <input name="conta1" type="text" id="conta1" size="13" maxlength="15" value="<%=(motor != null ? motor.getConta1() : "")%>" class="fieldMin">
                                                <select name="tipoContaAdiantamentoExpers" id="tipoContaAdiantamentoExpers" style="width:130px" class="fieldMin">
                                                    <option value="c" <%=(motor != null && motor.getTipoContaAdiantamentoExpers().equals("c") ? "selected" : "")%>>Conta Corrente</option>
                                                    <option value="p" <%=(motor != null && motor.getTipoContaAdiantamentoExpers().equals("p") ? "selected" : "")%>>Conta Poupança</option>
                                                </select>        
                                            </td>
                                            <td class="TextoCampos" width="20%">Agência:</td>
                                            <td class="CelulaZebra2" width="30%">
                                                <input name="agencia1" type="text" id="agencia1" size="5" maxlength="15" value="<%=(motor != null ? motor.getAgencia1() : "")%>" class="fieldMin">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Banco:</td>
                                            <td class="CelulaZebra2">
                                                <select name="banco1" id="banco1" style="width:130px" class="fieldMin">
                                                    <%BeanConsultaBanco banco = new BeanConsultaBanco();
                                                        banco.setConexao(Apoio.getUsuario(request).getConexao());
                                                        banco.MostrarTudo();
                                                        ResultSet rs1 = banco.getResultado();%>
                                                    <option value="0">000-Nenhum</option>
                                                    <%
                                                        while (rs1.next()) {%>
                                                    <option value="<%=rs1.getString("idbanco")%>" <%=(motor != null && rs1.getInt("idbanco") == motor.getBanco1().getIdBanco() ? "selected" : "")%>  ><%=rs1.getString("numero") + "-" + rs1.getString("descricao")%></option>
                                                    <%}
                                                        rs1.close();
                                                    %>
                                                </select>
                                            </td>
                                            <td class="TextoCampos" >Favorecido:</td>
                                            <td class="CelulaZebra2">
                                                <input name="favorecido1" type="text" id="favorecido1" size="20" maxlength="50" value="<%=(motor != null ? motor.getFavorecido1() : "")%>" class="fieldMin">
                                            </td>
                                        </tr>
                                            <td class="TextoCampos" colspan="2"></td>
                                        <tr>
                                            <td class="TextoCampos" >Conta p/ Saldo:</td>
                                            <td class="CelulaZebra2">
                                                <input name="conta2" type="text" id="conta2" size="13" maxlength="15" value="<%=(motor != null ? motor.getConta2() : "")%>" class="fieldMin">
                                                <select name="tipoContaSaldoExpers" id="tipoContaSaldoExpers" style="width:130px" class="fieldMin">
                                                    <option value="c" <%=(motor != null && motor.getTipoContaSaldoExpers().equals("c") ? "selected" : "")%>>Conta Corrente</option>
                                                    <option value="p" <%=(motor != null && motor.getTipoContaSaldoExpers().equals("p") ? "selected" : "")%>>Conta Poupança</option>
                                                </select>
                                            </td>
                                            <td class="TextoCampos" >Agência:</td>
                                            <td class="CelulaZebra2">
                                                <input name="agencia2" type="text" id="agencia2" size="5" maxlength="15" value="<%=(motor != null ? motor.getAgencia2() : "")%>" class="fieldMin">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Banco:</td>
                                            <td class="CelulaZebra2">
                                                <select name="banco2" id="banco2" style="width:130px" class="fieldMin">
                                                    <%BeanConsultaBanco banco2 = new BeanConsultaBanco();
                                                        banco2.setConexao(Apoio.getUsuario(request).getConexao());
                                                        banco2.MostrarTudo();
                                                        ResultSet rs2 = banco2.getResultado();%>
                                                    <option value="0">000-Nenhum</option>
                                                    <%
                                                        while (rs2.next()) {%>
                                                    <option value="<%=rs2.getString("idbanco")%>" <%=(motor != null && rs2.getInt("idbanco") == motor.getBanco2().getIdBanco() ? "selected" : "")%>  ><%=rs2.getString("numero") + "-" + rs2.getString("descricao")%></option>
                                                    <%}
                                                        rs2.close();
                                                    %>
                                                </select>
                                            </td>
                                            <td class="TextoCampos" >Favorecido:</td>
                                            <td class="CelulaZebra2">
                                                <input name="favorecido2" type="text" id="favorecido2" size="20" maxlength="50" value="<%=(motor != null ? motor.getFavorecido2() : "")%>" class="fieldMin">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Negociação do Adiantamento do Contrato de Frete: </td>
                                            <td class="TextoCampos">
                                                <div align="left">
                                                    <select id="negociacaoAdiantamento" name="negociacaoAdiantamento" class="inputtexto">
                                                        <option value="0" selected="">Não Informado</option>
                                                        <% for (NegociacaoAdiantamentoFrete negociacao : negociacaoMotor){
                                                         %>
                                                         <option value="<%= negociacao.getId() %>"><%= negociacao.getDescricao() %></option>
                                                         <%
                                                            }
                                                        %>
                                                    </select>
                                                </div>
                                            </td>
                                            <td class="TextoCampos" colspan="2">
                                                <div align="center">
                                                    % de desconto no contrato de frete:
                                                    <input name="percentualDescontoContrato" type="text" id="percentualDescontoContrato" onChange="seNaoFloatReset(this,'0.00');" class="fieldMin"
                                                           size="7" maxlength="6" value="<%=(carregamotorista ? Apoio.to_curr(motor.getPercentualDescontoContrato()) : "0.00")%>">
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" colspan="2">
                                                <label for="percentualValorCTeCalculoCFe">
                                                    <select name="calculoValorContratoFrete" id="calculoValorContratoFrete" class="fieldMin" onchange="isOcultoOptionValorContrato();">
                                                        <option value="ct" >% sobre o valor do CT-e</option>
                                                        <option value="nf" >% sobre o valor da NF-e</option>
                                                    </select>
                                                    no cálculo do valor do contrato de frete:</label>
                                            </td>
                                            <td class="TextoCampos" colspan="2">
                                                <div align="left">
                                                    <input name="percentualValorCTeCalculoCFe" type="text"
                                                           id="percentualValorCTeCalculoCFe"
                                                           onChange="seNaoFloatReset(this, '0.00');"
                                                           class="fieldMin" size="10" maxlength="9"
                                                           value="<%=(carregamotorista ? Apoio.to_curr(motor.getPercentualValorCTeCalculoCFe()) : "0.00")%>">
                                                    <c:set var="motor" value="<%=motor%>"/>
                                                    <select name="tipoCalculoPercentualValorCFe"
                                                            id="tipoCalculoPercentualValorCFe" class="fieldMin">
                                                        <c:forEach var="tc"
                                                                   items="<%=TipoCalculoPercentualValorCFe.values()%>">
                                                            <option value="${tc.tipoCalculoPercentualValorCFe}" ${(motor != null && tc eq motor.tipoCalculoPercentualValorCFe) ? 'selected' : ''}>
                                                                    ${tc.descricao}
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                    <label>Valor Mínimo</label>
                                                    <input type="text" id="valorMinimoCFe" name="valorMinimoCFe"
                                                           onChange="seNaoFloatReset(this, '0.00');"
                                                           class="fieldMin" size="10" maxlength="9"
                                                           value="<%=(carregamotorista ? Apoio.to_curr(motor.getValorMinimoCFe()) : "0.00")%>">
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos">Observação:</td>
                                            <td class="CelulaZebra2" colspan="3">
                                                <textarea name="obscartafrete" cols="85" rows="3" class="fieldMin" id="obscartafrete"><%=(motor != null && motor.getMotivobloqueio() != null ? motor.getObsCartaFrete() : "")%></textarea>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr class="tabela">
                                <td colspan="5" align="center">
                                    <div align="center">
                                        <strong>Informações Contrato de Frete Eletrônico (CF-e)</strong>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <table width="100%" border="0" class="bordaFina">
                                        <tr>
                                            <td class="TextoCampos" align="20%">Nº Cartão NDD Cargo:</td>
                                            <td class="CelulaZebra2" align="30%">
                                                <input name="cartaoNdd" class="fieldMin" type="text" id="cartaoNdd" size="30" maxlength="16" value="<%=(motor != null && motor.getCartaoNdd() != 0 ? motor.getCartaoNdd() : "")%>"/>
                                            </td>
                                            <td class="TextoCampos" align="20%">Nº Cartão Pamcard:</td>
                                            <td class="CelulaZebra2" align="30%">
                                                <input name="cartaoPamcard" class="fieldMin" type="text" id="cartaoPamcard" size="30" maxlength="16" value="<%=(motor != null && !motor.getCartaoPamcard().equals("") ? motor.getCartaoPamcard() : "")%>"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Nº Cartão REPOM:</td>
                                            <td class="CelulaZebra2">
                                                <input name="cartaoRepom" type="text" id="cartaoRepom" onchange="seNaoIntReset(this,'');" value="<%=(motor != null && motor.getCartaoRepom() != 0 ? motor.getCartaoRepom() : "")%>" size="30" maxlength="20" class="fieldMin"/>
                                            </td>
                                            <td class="TextoCampos" >Nº Cartão Ticket Frete:</td>
                                            <td class="CelulaZebra2">
                                                <input name="cartaoTicketFrete" class="fieldMin" type="text" id="cartaoTicketFrete" size="30" maxlength="16" value="<%=(motor != null && motor.getCartaoTicketFrete() != 0 ? motor.getCartaoTicketFrete() : "")%>"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Nº Cartão Bunge Card:</td>
                                            <td class="CelulaZebra2">
                                                <input name="cartaoBunge" type="text" id="cartaoBunge" value="<%=(motor != null ? motor.getCartaoBunge(): "")%>" size="30" maxlength="20" class="fieldMin">
                                            </td>
                                            <td class="TextoCampos" >Nº Cartão ExpeRS:</td>
                                            <td class="CelulaZebra2">
                                                <input name="cartaoExpers" type="text" id="cartaoExpers" value="<%=(motor != null ? motor.getCartaoExpers(): "")%>" size="30" maxlength="10" class="fieldMin">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Nº Cartão PagBem:</td>
                                            <td class="CelulaZebra2">
                                                <input name="cartaoPagBem" type="text" id="cartaoPagBem" value="<%=(motor != null ? motor.getCartaoPagBem(): "")%>" size="30" maxlength="20" class="fieldMin">
                                            </td>
                                            <td class="TextoCampos" >Nº Cartão EcoFrotas:</td>
                                            <td class="CelulaZebra2">
                                                <input type="text" name="numeroCartaoEcoFrotas" id="numeroCartaoEcoFrotas" value="<%= (motor != null ? motor.getNumeroCartaoEcoFrotas() : "") %>" maxlength="30" size="30" class="fieldMin" >
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Token Compra eFrete:</td>
                                            <td class="CelulaZebra2">
                                                <input name="tokenEfreteCompra" type="text" id="tokenEfreteCompra" value="<%=(motor != null ? motor.getTokenCompraEfrete(): "")%>" size="30" maxlength="20" class="fieldMin">
                                            </td>
                                            <td class="TextoCampos" ></td>
                                            <td class="CelulaZebra2"></td>
                                        </tr>
                                        <tr>
                                            <td class="TextoCampos" >Nº Cartão Target</td>
                                            <td class="CelulaZebra2">
                                                <input name="cartaoTarget" type="text" id="cartaoTarget" value="<%=(motor != null ? motor.getCartaoTarget() : "")%>" size="30" maxlength="20" class="fieldMin">
                                            </td>
                                            <td class="TextoCampos" colspan="2"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                                            <div class="panel" id="tab4">
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
                                                                <tbody  id="tbOcorrenciaMot" name="tbOcorrenciaMot">
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
                                            </div>
                                            <div class="panel" id="tab5">
                                                <table width="100%" align="center" class="bordaFina">
                                                    <tr class="tabela">
                                                        <td>
                                                            <div align="center"
                                                                 <strong>Adicionar Salários</strong>
                                                            </div>
                                                        </td>
                        </tr>
                        <tr name="trSalarioMotorista_" id="trSalarioMotorista_">
                        <td colspan="3">
                            <table align="center" width="100%" class="bordaFina">
                                <tbody  id="tbSalarioMot" name="tbSalarioMot">
                                    <tr class="celulaZebra1">
                                        <td width="10" align="center" class="celula">
                                            <img class="imagemLink" width="20px" src="img/add.gif" alt="addCampo" name="imgLixo" id="imgLixo" onClick="addNovosSalariosMotoristas();">
                                        </td>
                                        <td align="center" width="33%">Compet&ecirc;ncia</td>
                                        <td align="center" width="33%">Sal&aacute;rio</td>
                                        <td align="center" width="33%">% Custo Adcional</td>
                                    </tr>
                                </tbody>
                            </table>
                         </td>
                    </tr>
                    </table>
                </div>
            
                                            
            <div class="panel" id="tab6" >
                <%if (carregamotorista && nivelUser == 4 ) {%>
                    <table width="100%" align="center" class="bordaFina">
                        <tr class="tabela"> 
                        <div>
                            <td colspan="7" align="center">Auditoria </td> 
                        </div>
                       </tr>
                        <%@include file="gwTrans/template_auditoria.jsp" %>

                        </table>
                        <table width="100%" border="0" align="center" cellpadding="2" class="bordaFina">

                            <tr class="CelulaZebra2"> 
                                <td  class="TextoCampos" width="15%">Incluso:</td>
                                <td width="35%">
                                    Em: <%=carregamotorista && motor.getDtLancamento() != null ? formato.format(motor.getDtLancamento()) : ""%> 
                                    <br>
                                    Por: <%=carregamotorista && motor.getDtLancamento() != null ? motor.getUsuarioLancamento().getNome() : ""%>
                                </td>
                                <td class="TextoCampos" width="15%">Alterado:
                                <td width="35%">Em: <%=(carregamotorista && motor.getDtAlteracao() != null) ? formato.format(motor.getDtAlteracao()) : ""%>
                                    <br>
                                    Por: <%=(carregamotorista && motor.getUsuarioAlteracao().getNome() != null) ? motor.getUsuarioAlteracao().getNome() : ""%> 
                                </td>
                            </tr>


                        </table>

                        <%}%>
                   </div>     
                        <br/>
                        <table width="100%" border="0" align="center" cellpadding="2" class="bordaFina">   
                            <tr class="CelulaZebra2">
                             <td colspan="4">
                                    <% if (nivelUser >= 2) {%>
                                    <center>
                                        <input name="gravar" type="button" class="botoes" id="gravar" value="Salvar" onClick="javascript:tryRequestToServer(function(){salva('<%=(acao.equals("iniciar") ? "incluir" : "atualizar")%>');});">
                                    </center>
                                    <%}%>
                                </td>
                            </tr>
                        </table>  
                   </div>   
                                </div>
           </form>                     
    </body>
</html>
