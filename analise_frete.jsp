<%@page import="java.util.ArrayList"%>
<%@page import="filial.BeanConsultaFilial"%>
<%@page import="filial.BeanConsultaFilial"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.Collection"%>
<%@page import="filial.BeanFilial"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="java.sql.ResultSet,
         conhecimento.*,
         nucleo.BeanLocaliza,
         conhecimento.duplicata.fatura.*,
         conhecimento.manifesto.BeanConsultaManifesto,
         conhecimento.romaneio.BeanConsultaRomaneio,
         cliente.BeanCadCliente,
         tipo_veiculos.ConsultaTipo_veiculos,
         conhecimento.ocorrencia.*,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>
<%@page import="java.util.Map"%>
<%@page import="cliente.tipoProduto.TipoProduto"%>

<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="JavaScript" src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/prototype.js" type="text/javascript"></script>
<script language="JavaScript" src="script/shortcut.js" type="text/javascript"></script>
<jsp:useBean id="conCtrc" class="conhecimento.BeanConsultaConhecimento" />
<jsp:useBean id="cfg" class="nucleo.BeanConfiguracao" />
<jsp:useBean id="conColeta" class="conhecimento.coleta.BeanConsultaColeta" />


<% 
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
   String idFilial = request.getParameter("idFiliaisSelecionadas") == null ? String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()) : request.getParameter("idFiliaisSelecionadas");
//   int idFilial = request.getParameter("filialId") == null ? Apoio.getUsuario(request).getFilial().getIdfilial() : Integer.parseInt(request.getParameter("filialId")); 
   String tipoVeiculo = request.getParameter("tipoVeiculo") == null ? "todos" : request.getParameter("tipoVeiculo"); 
   String tipoProduto = request.getParameter("tipoproduto") == null ? "0" : request.getParameter("tipoproduto"); 
   String tipoMotorista = request.getParameter("tipoMotorista") == null ? "todos" : request.getParameter("tipoMotorista"); 
   String considerar = request.getParameter("considerar") == null ? "V" : request.getParameter("considerar");
   int idVendedor = request.getParameter("idvendedor") == null ? 0 : Integer.parseInt(request.getParameter("idvendedor")); 
   int idProprietario = request.getParameter("idproprietario") == null ? 0 : Integer.parseInt(request.getParameter("idproprietario"));
   String valorParaImpressao = request.getParameter("impressao");

   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null))
       response.sendError(HttpServletResponse.SC_FORBIDDEN);

  String acao = (request.getParameter("acao") == null ? "" : request.getParameter("acao") );
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
  DecimalFormat formatador_valor = new DecimalFormat("#,##0.00");
  DecimalFormat formatador_peso = new DecimalFormat("#,##0");
  SimpleDateFormat formatadorHora = new SimpleDateFormat("HH:mm");
  String dataInicial = formatador.format(new Date());
  String dataFinal = formatador.format(new Date());
  String apenasManifesto = "";
  String apenasContratoFrete = "";
  boolean apenasComContratoADV = false;
  boolean apenasComContainer = false;
  boolean isMostrarNFS = false;
  ArrayList<String> listaIdGrupo = new ArrayList<String>();
  ArrayList<String> listaDescricaoGrupo = new ArrayList<String>();

  cfg.setConexao(Apoio.getUsuario(request).getConexao());
  cfg.CarregaConfig();

  if (acao.equals("consultar")) {
                conCtrc.setConexao(Apoio.getUsuario(request).getConexao());
                dataInicial = request.getParameter("dtemissao1");
                dataFinal = request.getParameter("dtemissao2");
                conCtrc.setCampoDeConsulta(request.getParameter("tipoData"));
                conCtrc.setDtEmissao1(Apoio.paraDate(dataInicial));
                conCtrc.setDtEmissao2(Apoio.paraDate(dataFinal));
                apenasManifesto = (request.getParameter("manifesto") == null ? "" : request.getParameter("manifesto"));
                apenasContratoFrete = (request.getParameter("contratoFrete") == null ? "" : request.getParameter("contratoFrete"));

                apenasComContratoADV = (request.getParameter("comContratoADV") != null ? true : false );
                apenasComContainer = (request.getParameter("comContainer") != null ? true : false );
                isMostrarNFS = (request.getParameter("mostrarNFS") != null ? true : false );
                
                
                int i = 1;
                while(request.getParameter("grupo_id"+i) != null && request.getParameter("descricao"+i) != null){
                    listaIdGrupo.add(request.getParameter("grupo_id"+i));
                    listaDescricaoGrupo.add(request.getParameter("descricao"+i));
                    i++;
                }
                
  } else if (acao.equals("imprimir")) {
                String agrupamento = "";
                String agruparPor = request.getParameter("agruparPor");
                int idCliente = Integer.parseInt(request.getParameter("idCliente"));
                int idMotorista = Integer.parseInt(request.getParameter("idMotorista"));
                int idVeiculo = Integer.parseInt(request.getParameter("idveiculo"));
                String motorista = request.getParameter("motorista");
                String cliente = request.getParameter("cliente");
                String proprietario = request.getParameter("proprietario");
                String vendedor = request.getParameter("vendedor");
                idFilial = request.getParameter("idFilial");
                String grupoCliente = request.getParameter("grupoCliIds");
                String opcaoGrupoCliente = (request.getParameter("opcaoGrupoCli") == null ? "": request.getParameter("opcaoGrupoCli"));
                String emissaoDe = request.getParameter("emissaoDe");
                String emissaoAte = request.getParameter("emissaoAte");
                boolean condicaoComContratoADV = Apoio.parseBoolean(request.getParameter("apenasComContratoFreteADV"));

                if (agruparPor.equals("Filial")) {
                    agrupamento = "s.filial_id";
                } else if (agruparPor.equals("Motorista")) {
                    agrupamento = "ct.motorista_id";
                } else if (agruparPor.equals("Manifesto")) {
                    agrupamento = "m.idmanifesto";
                } else if (agruparPor.equals("Cliente")) {
                    agrupamento = "s.consignatario_id";
                } else {
                    agrupamento = "v.idproprietario";
                }
                String condicaoTipoProduto = tipoProduto.equals("0") ? "" :
                    " and ct.product_type_id = " + tipoProduto + " ";
                String condicaoTipoVeiculo = tipoVeiculo.equals("todos") ? "" :
                    " and v.tipofrota = '" + tipoVeiculo + "'";
                String condicaoTipoMotorista = tipoMotorista.equals("todos") ? "" :
                    " and mot.tipo = '" + tipoMotorista + "'";
                String condicaoGruposClientes = "";
                String condicaoFilial = idFilial == "" ? "" : " and s.filial_id in (" + idFilial + " ) ";
                
                if(opcaoGrupoCliente.equals("IN")){
                   condicaoGruposClientes = (grupoCliente == null || grupoCliente == "" ? "" : "and cli.grupo_id in ( "+grupoCliente+" )");
                }else{
                   condicaoGruposClientes = (grupoCliente == null || grupoCliente == "" ? "" : "and cli.grupo_id not in ( "+grupoCliente+" )"); 
                }
                String condicaoRemetente = idCliente == 0 ? "" : " and s.consignatario_id = " + idCliente;
                String condicaoMotorista = idMotorista == 0 ? "" : " and ct.motorista_id = " + idMotorista;
                String condicaoVeiculo = idVeiculo == 0 ? "" : " and ct.veiculo_id = " + idVeiculo;
                String condicaoProprietario = idProprietario == 0 ? "" : " and v.idproprietario = " + idProprietario;
                String condicaoVendedor = idVendedor == 0 ? "" : " and s.vendedor_id = " + idVendedor;
                String condicao_dtemissao = " and (" + request.getParameter("tipoData") + " BETWEEN '" + formatador.parse(emissaoDe) + "'" + " AND '" + formatador.parse(emissaoAte) + "')";
                String condicaoContratoFreteADV = "";

                String join = "";
                if (request.getParameter("tipoData").equals("dd.dtpago") || request.getParameter("tipoData").equals("dd.dtvenc")){
                    join = " left join pagamento_carta_frete pcf on cf.idcartafrete = pcf.carta_frete_id "
                           + " left join dupldespesa dd ON (pcf.despesa_id = dd.idmovimento) ";
                }

                Map param = new java.util.HashMap(17);

                
                param.put("FILIAL", condicaoFilial);
                param.put("GRUPO_CLIENTE", condicaoGruposClientes);
                param.put("CATEGORIA_SALES", (Apoio.parseBoolean(request.getParameter("mostrarNFS")) ? "" : " AND s.categoria = 'ct' "));
                param.put("CLIENTE", condicaoRemetente);
                param.put("MOTORISTA", condicaoMotorista);
                param.put("VEICULO", condicaoVeiculo);
                param.put("DATA", condicao_dtemissao);
                param.put("TIPO_VEICULO", condicaoTipoVeiculo);                
                param.put("TIPO_PRODUTO", condicaoTipoProduto);                
                param.put("TIPO_MOTORISTA", condicaoTipoMotorista);                
                param.put("VENDEDOR", condicaoVendedor);                
                param.put("PROPRIETARIO", condicaoProprietario);                
                param.put("AGRUP", agrupamento);
                param.put("JOIN", join);
                param.put("MANIFESTO", (request.getParameter("apenasManifesto").trim().equals("") ? "" : " AND m.nmanifesto = " + Apoio.SqlFix(request.getParameter("apenasManifesto"))));
                param.put("CONTRATO_FRETE", (request.getParameter("apenasContratoFrete").trim().equals("") ? "" : " AND cf.idcartafrete = " + Apoio.SqlFix(request.getParameter("apenasContratoFrete"))));
                param.put("CONSIDERAR_CALCULO", (considerar.equals("P") ? "peso":"valor"));
                param.put("OPCOES", "Periodo: "+emissaoDe+ " à " + emissaoAte + ". " + 
                        (!condicaoMotorista.equals("") ? "Apenas o motorista:"+motorista +". ":"") +
                        (!condicaoRemetente.equals("") ? "Apenas o cliente: "+cliente + ". ":"") +
                        (!condicaoVendedor.equals("") ? "Apenas o vendedor: "+vendedor + ". ":"") +
                        (!condicaoProprietario.equals("") ? "Apenas o proprietário: "+proprietario+ ". ":"") +
                        (!condicaoTipoVeiculo.equals("") ? "Apenas os veículos: "+
                                (tipoVeiculo.equals("pr") ? "Próprios" : 
                                 tipoVeiculo.equals("ag") ? "Agregados" :
                                 "Carreteiros") + ". ":"")+
                        (!condicaoTipoMotorista.equals("") ? "Apenas os motoristas: "+
                                (tipoMotorista.equals("c") ? "Carreteiros" : 
                                 tipoMotorista.equals("a") ? "Agregados" :
                                 "Funcionários") + ". ":"") +
                                 "Rateio do CT-e feito por "+ (considerar.equals("P") ? "peso":"valor") + ". "
                                 );
                if(!considerar.equals("P")){
                    param.put("SQL_RATEIO_UNITARIO", " (s.total_receita) ");
                    
                    param.put("SQL_RATEIO_TOTAL_COLETA", " COALESCE((select se_zero_null(sum(s1.total_receita))  "
                    + " from nota_fiscal nf  "
                    + " join sales s1 on nf.idconhecimento = s1.id "
                    + "where nf.idcoleta = ct.coleta_id),COALESCE((select se_zero_null(sum(s1.total_receita))  "
                    + " from sales s1 JOIN ctrcs ct2 ON (s1.id = ct2.sale_id) "
                    + " where ct2.coleta_id = ct.coleta_id),1)) ");
                    
                    param.put("SQL_RATEIO_TOTAL_CARTA_FRETE", "(SELECT se_zero_null(sum(sl1.total_receita)) "
                    + " FROM carta_frete cf  "
                    + " left join cartafrete_manifesto cfm on cf.idcartafrete = cfm.idcartafrete "
                    + " join manifesto_conhecimento mc on mc.idmanifesto = cfm.idmanifesto "
                    + " join sales sl1 on sl1.id = mc.idconhecimento "
                    + " where cf.idcartafrete in (select cfm.idcartafrete "
                    + " from cartafrete_manifesto cfm "
                    + " join manifesto_conhecimento mc on mc.idmanifesto = cfm.idmanifesto  "
                    + " where mc.idconhecimento = s.id)) ");
                    
                    param.put("SQL_RATEIO_TOTAL_VIAGEM",  "(select se_zero_null(sum(s2.total_receita)) "
                    + " from trips vi  "
                    + " join  trip_ctrcs vi_ct on vi_ct.trip_id = vi.id  "
                    + " join sales s2 on vi_ct.sale_id = s2.id  "
                    + " where vi.id in(select trip_id from trip_ctrcs where sale_id = s.id)) ");
                    
                    param.put("SQL_RATEIO_TOTAL_ROMANEIO",  " (select se_zero_null(sum(s2.total_receita)) from romaneio rom  "+
                " join  romaneio_ctrc rom_ct on rom_ct.idromaneio = rom.idromaneio "+
                " join sales s2 on rom_ct.idctrc = s2.id "+
                " where rom.idromaneio in(select idromaneio from romaneio_ctrc where idctrc = s.id)) ");
                }
                if(condicaoComContratoADV){

                condicaoContratoFreteADV = " AND ( (s.id IN (SELECT tc.sale_id  FROM  trip_ctrcs tc "
                                 + " LEFT JOIN sales s5 ON(tc.sale_id=s5.id) WHERE s5.emissao_em BETWEEN '" + formatador.parse(emissaoDe) + " ' AND '" + formatador.parse(emissaoAte) + "') )"
                                 + "  OR ("
                   + " s.id IN (SELECT idconhecimento FROM manifesto_conhecimento mc3 "
                   + " JOIN cartafrete_manifesto cfm3 ON (mc3.idmanifesto = cfm3.idmanifesto)"
                   + " LEFT JOIN sales s6 ON (mc3.idconhecimento = s6.id) WHERE s6.emissao_em BETWEEN '" + formatador.parse(emissaoDe) + "' AND '" + formatador.parse(emissaoAte) + "') ) )" ;

                    param.put("CONTRATO_FRETE_ADV",condicaoContratoFreteADV);
                }
                param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                request.setAttribute("map", param);
                request.setAttribute("rel", "analise_fretemod1" );
                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
                dispacher.forward(request, response);
            } else if (acao.equals("imprimirCarta")) {
                
                Map param = new java.util.HashMap(1);

                param.put("ID", request.getParameter("idCarta"));
                param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                
                request.setAttribute("map", param);
                request.setAttribute("rel", "analise_fretemod2" );
                RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports");
                dispacher.forward(request, response);
            }
%>

<script language="javascript" type="text/javascript">
    
    function visualizar(){
        $("idFiliaisSelecionadas").value = getFiliaisSelecionadas();
        $("idsGruposCliSelecionados").value = getGruposCliente();
        $("formBx").submit();
    }

    function setValorConsulta(obj, tamanhoPadrao){
        if (obj.value == null || obj.value == ""){
            obj.value = tamanhoPadrao;
        }
    }

    function fechar(){
        window.close();
  }
  
    function editarconhecimento(idmovimento, podeexcluir){
        window.open("./frameset_conhecimento?acao=editar&id="+idmovimento+(podeexcluir != null ? "&ex="+podeexcluir : ""),
    "Conhecimento" , 'top=10,left=0,height=500,width=1100,resizable=yes,status=1,scrollbars=1');
  }
  
    function limpaConsig(){
    $("idconsignatario").value = "0";
    $("con_rzs").value = "";
  }
  
    function localizaconsignatario(){
    windowConsignatario = window.open('localiza?categoria=loc_cliente&acao=consultar&idlista=<%=BeanLocaliza.CONSIGNATARIO_DE_CONHECIMENTO%>','Consignatario_Fatura',
    'top=80,left=70,height=500,width=700,resizable=yes,status=1,scrollbars=1');
  }

    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=41','Veiculo',
        'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
    }

    function popImpressao(){
      
      var agruparPor;
      if($("agrupar_cli").checked){
        agruparPor = $("agrupar_cli").value;
      }else if($("agrupar_man").checked){
        agruparPor = $("agrupar_man").value;
      }else if($("agrupar_mot").checked){
        agruparPor = $("agrupar_mot").value;
      }else if($("agrupar_prop").checked){
        agruparPor = $("agrupar_prop").value;
      }else{
        agruparPor = $("agrupar_fi").value;
      }
      
      var idCliente = $("idconsignatario").value;
      var cliente = $("con_rzs").value;
      var idVeiculo = $("idveiculo").value;;
      var veiculo = $("vei_placa").value;;
      var idMotorista = $("idmotorista").value;;
      var motorista = $("motor_nome").value;;
      var idFiliais = getFiliaisSelecionadas();
      var idGruposCli = getGruposCliente();
      console.log(">>>"+idGruposCli);
      var opcaoGrupoCli = $("excetoGrupo").value;
      var emissaoDe = $("dtemissao1").value;
      var emissaoAte = $("dtemissao2").value;
      var tipoVeiculo = $("tipoVeiculo").value;
      var tipoMotorista = $("tipoMotorista").value;
      var idVendedor = $("idvendedor").value;
      var vendedor = $("ven_rzs").value;
      var idProprietario = $("idproprietario").value;
      var proprietario = $("nome").value;
      var considerar = $("considerar").value;
      var apenasManifesto = $("manifesto").value;
      var apenasContratoFrete = $("contratoFrete").value;
      var apenasComContratoFreteADV = $("comContratoADV").checked;
      var mostrarNFS = $("mostrarNFS").checked;
      var valorTipoImpressao = $('valorTipoImpressao').value;

    window.open('./analise_frete.jsp?acao=imprimir&agruparPor='+agruparPor+
        '&emissaoDe='+emissaoDe+'&emissaoAte='+emissaoAte+'&idCliente='+idCliente+
        '&cliente='+cliente+'&motorista='+motorista+
        '&idvendedor='+idVendedor +
        '&vendedor='+vendedor+
        '&tipoData='+$("tipoData").value+
        '&idproprietario='+idProprietario+
        '&proprietario='+proprietario+
        '&tipoVeiculo='+tipoVeiculo+
        '&tipoMotorista='+tipoMotorista+
        '&tipoproduto='+$("tipoproduto").value+
        '&considerar='+considerar+
        '&apenasManifesto='+apenasManifesto+
        '&idveiculo='+idVeiculo+
        '&vei_placa='+veiculo+
        '&apenasContratoFrete='+apenasContratoFrete+
        '&idMotorista='+idMotorista+'&idFilial='+idFiliais+'&grupoCliIds='+idGruposCli+'&opcaoGrupoCli='+opcaoGrupoCli+'&modelo=1'+'&apenasComContratoFreteADV='+apenasComContratoFreteADV+
        '&mostrarNFS='+mostrarNFS+
        '&impressao='+valorTipoImpressao
                ,'ctrc',
        'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
  }
  
    function popCarta(idCarta){
      
    window.open('./analise_frete.jsp?acao=imprimirCarta&idCarta='+idCarta,'contrato',
        'top=0,left=0,height=540,width=800,resizable=yes,status=1,scrollbars=1');
  }
  
    function localizaprop(){
        window.open('./localiza?acao=consultar&idlista=1&paramaux=1','Proprietario',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
  }
  function tipoImpressaoSelecionado(valorSelecionado){     
      $('valorTipoImpressao').value = valorSelecionado;
  }
  
  
  var qtdFilial = 0;
  function getFiliaisSelecionadas(){
      qtdFilial = $("qtdFiliais").value + 1;
      var ids = "";
      for(var i = 0; i <= qtdFilial;i++){
          if($("filial_"+i) != null && $("filial_"+i).checked){
              ids += $("filial_"+i).value + ",";
          }
      }
      ids = ids.substring(0,ids.length -1);
      $("idFiliaisSelecionadas").value = ids;
      console.log(ids);
      return ids;
  }
  
  
  function marcarCheckFilialAoCarregar(){
    qtdFilial = $("qtdFiliais").value + 1;
    var filiais = '<%=idFilial%>';
    var filial = filiais.split(",");
    if(filiais != null && filiais != undefined){
        for(var i = 0; i<= qtdFilial; i++){
            for(var e = 0; e <= filial.length; e++){
                if(filial[e] != null && $("filial_"+i) != null && $("filial_"+i).value == filial[e]){
                    $("filial_"+i).checked = true;
                }
            }
        }
    }
        
  }
  
  function marcarTodasFiliais(){
    qtdFilial = $("qtdFiliais").value;
    for(var i = 1; i<= qtdFilial; i++){
        if($("filial_"+i) != null && $("filial_"+i) != undefined){
            if($("filial_0").checked){
                $("filial_"+i).checked = true;
            }else{
                $("filial_"+i).checked = false;
            }
        }
    }
  }
  
  var contGrupoCli = 0;
  function aoClicarNoLocaliza(idjanela){      
        if (idjanela == "Grupo"){
            addGrupo($('grupo_id').value,'node_grupos', getObj('grupo').value);
            contGrupoCli++;
        }
  }
  
  
  
  function getGruposCliente(){
      var gruposCli = "";
      var i = 1;
      while($("grupo_id"+i) != null){
          gruposCli += $("grupo_id"+i).value + ",";
          i++;
      }
      gruposCli = gruposCli.substring(0,gruposCli.length -1);
      $("idsGruposCliSelecionados").value = gruposCli;
      return gruposCli;
  }
  
    function carregarGruposClientes(){
        <%if(acao.equals("consultar")){
            for(int i = 0;i<listaIdGrupo.size();i++){
            String ids = listaIdGrupo.get(i);
            String desc = listaDescricaoGrupo.get(i);%>
                    
            addGrupo(<%=ids%>,'node_grupos','<%=desc%>');
        
            <%}
        }%>
    }

</script>

<html>    
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="content-language" content="pt" />
        <meta http-equiv="cache-control" content="no-cache" />
        <meta http-equiv="pragma" content="no-store" />
        <meta http-equiv="expires" content="0" />
        <meta name="language" content="pt-br" />

        <title>Webtrans - An&aacute;lise de Frete</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="applyFormatter();marcarCheckFilialAoCarregar();carregarGruposClientes();">
        <input type="hidden" name="grupo_id" id="grupo_id" value="0">
        <input type="hidden" name="grupo" id="grupo" value="">
        <div align="center">
            <img src="img/banner.gif"  alt="banner"> 
            <br>
        </div>
        <table width="100%"  align="center" class="bordaFina" >
            <tr>
                <td width="16%" ></td>
                <td width="70%" height="22">
                    <b>An&aacute;lise de Frete</b>
                </td>
                <td width="14%">
                    <b>
                        <input  name="Button" type="button" class="botoes" value="   Fechar   " onClick="fechar()">
                    </b>
                </td>
            </tr>
        </table>
        <br/>
        <form method="post" id="formBx" action="./analise_frete.jsp?acao=consultar">
            <table width="100%" border="0" class="bordaFina" align="center">
                <tr class="tabela">
                    <td colspan="6">
                        <div align="center">Filtros </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos font9" width="12%">
                        <select name="tipoData" id="tipoData" class="fieldMin" style="width: 100px;">
                            <option value="s.emissao_em" selected >Emissão CT</option>
                            <option value="m.dtsaida" <%=conCtrc.getCampoDeConsulta().equals("m.dtsaida") ? "selected" : ""%> >Data do Manifesto</option>
                            <option value="cf_pai.data" <%=conCtrc.getCampoDeConsulta().equals("cf_pai.data") ? "selected" : ""%> >Emissão Contrato de Frete</option>
                            <option value="dd.dtpago" <%=conCtrc.getCampoDeConsulta().equals("dd.dtpago") ? "selected" : ""%>>Pagamento Contrato de Frete</option>
                            <option value="dd.dtvenc" <%=conCtrc.getCampoDeConsulta().equals("dd.dtvenc") ? "selected" : ""%>>Vencimento Contrato de Frete</option>
                        </select>
                    </td>
                    <td class="CelulaZebra2 font9" width="24%">
                            <div id="div1" align="left">De:
                                <input name="dtemissao1" type="text" id="dtemissao1" size="10" maxlength="10" 
                                       value="<%=dataInicial%>"
                                       onblur="alertInvalidDate(this)" class="fieldDate"/>
                                &nbsp;&nbsp;&nbsp;&nbsp;
                                Para:
                                <input name="dtemissao2" type="text" id="dtemissao2" size="10" maxlength="10" 
                                       value="<%=dataFinal%>"
                                       onblur="alertInvalidDate(this)" class="fieldDate">
                            </div>
                    </td>
                    <td class="TextoCampos font9" width="7%">Agrupar por:</td>
                    <td class="TextoCampos font9" width="33%">
                        <div align="left">
                            <input name="agrupar" id="agrupar_cli" type="radio" value="Cliente" <%=(request.getParameter("agrupar") != null && request.getParameter("agrupar").equals("Cliente") ? "checked" : "checked")%> >
                            Cliente
                            <input name="agrupar" id="agrupar_mot" type="radio" value="Motorista" <%=(request.getParameter("agrupar") != null && request.getParameter("agrupar").equals("Motorista") ? "checked" : "")%>>
                            Motorista
                            <input name="agrupar" id="agrupar_prop" type="radio" value="Proprietário" <%=(request.getParameter("agrupar") != null && request.getParameter("agrupar").equals("Proprietário") ? "checked" : "")%>>
                            Proprietário
                            <input name="agrupar" id="agrupar_fi" type="radio" value="Filial" <%=(request.getParameter("agrupar") != null && request.getParameter("agrupar").equals("Filial") ? "checked" : "")%>>
                            Filial
                            <input name="agrupar" id="agrupar_man" type="radio" value="Manifesto" <%=(request.getParameter("agrupar") != null && request.getParameter("agrupar").equals("Manifesto") ? "checked" : "")%>>
                            Manifesto
                        </div>
                    </td>
                    <td  class="TextoCampos font9" width="9%" colspan="2">
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos font9">Cliente:</td>
                    <td class="CelulaZebra2 font9">
                        <input type="hidden" name="idconsignatario" id="idconsignatario" value="<%=(request.getParameter("idconsignatario") == null ? "0" : request.getParameter("idconsignatario"))%>">
                        <input name="con_rzs" type="text" id="con_rzs" size="30" readonly
                                class="inputReadOnly8pt"
                                value="<%=(request.getParameter("con_rzs") != null ? request.getParameter("con_rzs") : "")%>">
                        <strong>
                            <input name="localiza_con" type="button" class="botoes" id="localiza_con" value="..." onClick="javascript:localizaconsignatario();">
                        </strong>
                        <img alt="" src="img/borracha.gif" border="0"  align="absbottom" class="imagemLink" onClick="limpaConsig();"/>
                    </td>
                    <td class="TextoCampos font9">Motorista:</td>
                    <td class="CelulaZebra2 font9">
                        <input type="hidden" name="idmotorista" id="idmotorista" value="<%=(request.getParameter("idmotorista") != null ? request.getParameter("idmotorista") : "0")%>">
                        <strong>
                            <input name="motor_nome" type="text"  class="inputReadOnly8pt font9" id="motor_nome" size="30" value="<%=(request.getParameter("motor_nome") != null ? request.getParameter("motor_nome") : "")%>" readonly="true">
                            <input name="button" type="button" class="botoes" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=10','Motorista')" value="...">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink font9" title="Limpar Motorista" onClick="javascript:getObj('idmotorista').value = 0;javascript:getObj('motor_nome').value = '';">
                        </strong>
                        Placa:
                        <input type="hidden" name="idveiculo" id="idveiculo" value="<%=(request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : "0")%>">
                        <input name="vei_placa" type="text" id="vei_placa" class="inputReadOnly8pt" value="<%=(request.getParameter("vei_placa") != null ? request.getParameter("vei_placa") : "")%>" size="15" maxlength="10" readonly="true">
                        <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..." onClick="javascript:localizaveiculo();">
                        <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink" id="limpavei" title="Limpar Veículo" onClick="javascript:$('idveiculo').value = '0';javascript:$('vei_placa').value = '';">
                    </td>
                    <td  height="20" class="TextoCampos font9" width="9%">
                        <div align="right">Apenas Motoristas:</div>
                    </td>
                    <td class="CelulaZebra2 font9" width="15%">
                        <div align="left">
                            <select name="tipoMotorista" id="tipoMotorista" class="fieldMin">
                                <option value="todos" <%=tipoMotorista.equals("todos") ? "selected" : ""%>>TODOS</option>
                                <option value="c" <%=tipoMotorista.equals("c") ? "selected" : ""%>>Carreteiros</option>
                                <option value="a" <%=tipoMotorista.equals("a") ? "selected" : ""%>>Agregados</option>
                                <option value="f" <%=tipoMotorista.equals("f") ? "selected" : ""%>>Funcionários</option>
                            </select>                        
                        </div>
                    </td>                
                </tr>
                <tr>
                    <td class="TextoCampos font9">Propriet&aacute;rio:</td>
                    <td class="CelulaZebra2 font9">
                        <input type="hidden" name="idproprietario" id="idproprietario" value="<%=(request.getParameter("idproprietario") != null ? request.getParameter("idproprietario") : "0")%>">
                        <strong>
                            <input name="nome" type="text" id="nome" class="inputReadOnly8pt font9" size="30" readonly="true" value="<%=(request.getParameter("nome") != null ? request.getParameter("nome") : "")%>">
                            <input name="localiza_prop" type="button" class="botoes" id="localiza_prop" value="..." onClick="javascript:localizaprop();">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idproprietario').value = '0';javascript:getObj('nome').value = '';">
                        </strong>
                    </td>
                    <td class="TextoCampos font9">Vendedor:</td>
                    <td class="CelulaZebra2 font9">
                        <strong>
                            <input type="hidden" name="idvendedor" id="idvendedor" value="<%=(request.getParameter("idvendedor") != null ? request.getParameter("idvendedor") : "0")%>">
                            <input name="ven_rzs" type="text" id="ven_rzs" class="inputReadOnly8pt font9" size="30"  readonly="true" value="<%=(request.getParameter("ven_rzs") != null ? request.getParameter("ven_rzs") : "")%>">
                            <input name="localiza_vendedor" type="button" class="botoes" id="localiza_vendedor" value="..." onClick="javascript:window.open('./localiza?acao=consultar&idlista=27&paramaux=1','Vendedor','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                            <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:$('idvendedor').value = 0; $('ven_rzs').value = '';">
                        </strong>                    
                    </td>
                    <td  height="20" class="TextoCampos font9" >Apenas Ve&iacute;culos: </td>
                    <td class="CelulaZebra2 font9" >
                        <select name="tipoVeiculo" id="tipoVeiculo" class="fieldMin">
                             <option value="todos" <%=tipoVeiculo.equals("todos") ? "selected" : ""%>>TODOS</option>
                             <option value="pr" <%=tipoVeiculo.equals("pr") ? "selected" : ""%>>Próprios</option>
                             <option value="ag" <%=tipoVeiculo.equals("ag") ? "selected" : ""%>>Agregados</option>
                             <option value="ca" <%=tipoVeiculo.equals("ca") ? "selected" : ""%>>Carreteiros</option>
                        </select>
                    </td>                
                </tr>
                <tr>
                    <td class="TextoCampos font9">Apenas a(s) filial(is):</td>
                    <td class="celulaZebra2" colspan="3">
                        <table class="" width="100%">
                            <tbody id="tbFilais">
                                <tr class="celulaZebra2">
                                <td>
                                    <label><input type="checkbox" id="filial_0" name="filial_0" value="0" onchange="marcarTodasFiliais()"> </label>
                                    <label id="descFilial_0" name="descFilial_0">Marcar todas</label>
                                </td>
                                </tr>
                                <%
                                int cont = 0;
                                Collection<BeanFilial> filiais = BeanConsultaFilial.mostrarTodos(Apoio.getUsuario(request).getConexao());
                                for(BeanFilial f : filiais){
                                cont++;
                                    if(cont % 4 == 1){%>
                                    <tr class="">
                                    <%}%>
                                        
                                    <td class="CelulaZebra2">
                                            <label><input type="checkbox" id="filial_<%=cont%>" name="filial_<%=cont%>" value="<%=f.getIdfilial()%>"> </label>
                                            <label id="descFilial_<%=cont%>" name="descFilial_<%=cont%>"><%=f.getAbreviatura()%></label>
                                            <input id="descricaoFilial_<%=cont%>" name="descricaoFilial_<%=cont%>" value="<%=f.getAbreviatura()%>" type="hidden">
                                        </td>
                                    <%if(cont % 4 == 0){%>
                                        </tr>
                                    <%}%>
                                
                                <%}%>
                                <input id="qtdFiliais" name="qtdFiliais" value="<%=cont%>" type="hidden">
                                <input id="idFiliaisSelecionadas" name="idFiliaisSelecionadas" value="" type="hidden">
                            </tbody>
                        </table>
                    </td>
                    <td colspan="2">
                    <input type="hidden" name="idsGruposCliSelecionados" id="idsGruposCliSelecionados" value="">
                        
                        <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                            <tr class="cellNotes"> 
                                <td width="24%" class="CelulaZebra2" id="imgGrupo" style="display: ">
                                    <div align="center">
                                        <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">
                                    </div>
                                </td>
                                <td width="76%" class="CelulaZebra2" id="selectGrupo" style="display: ">
                                    <div align="center">
                                        <select name="excetoGrupo" id="excetoGrupo" class="inputtexto">
                                            <option value="IN" selected>Apenas os grupos</option>
                                            <option value="NOT IN">Exceto os grupos</option>
                                        </select>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="6">
                        <table width="100%">
                            <tr>
                                <td width="10%" class="TextoCampos font9">Apenas o Manifesto:</td>
                                <td width="6%" class="CelulaZebra2 font9">
                                    <input name="manifesto" type="text" id="manifesto" class="fieldMin2" size="10" value="<%=apenasManifesto%>">
                                </td>
                                <td width="14%" class="TextoCampos font9">Apenas o Contrato de Frete:</td>
                                <td width="6%" class="CelulaZebra2 font9">
                                    <input name="contratoFrete" type="text" id="contratoFrete" class="fieldMin2" size="10" value="<%=apenasContratoFrete%>">
                                </td>
                                <td width="34%" class="TextoCampos font9"> 
                                    <div align="center">
                                        <input name="comContratoADV" type="checkbox" id="comContratoADV" <%=(request.getParameter("comContratoADV") != null ? "checked" : "" )%> >
                                        Mostrar apenas CT-es com Contrato de Frete ou ADV 
                                    </div>
                                </td>
                                <td width="20%" class="TextoCampos font9" colspan="2">Ao ratear o custo do CT-e considerar:</td>
                                <td width="10%" class="TextoCampos font9">
                                    <select name="considerar" id="considerar" class="fieldMin">
                                        <option value="P" <%=considerar.equals("P") ? "selected" : ""%>>Peso</option>
                                        <option value="V" <%=considerar.equals("V") ? "selected" : ""%>>Valor do Frete</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="TextoCampos font9" colspan="4">
                                    <div align="center">
                                        <input name="comContainer" type="checkbox" id="comContainer" <%=(request.getParameter("comContainer") != null ? "checked" : "" )%> >
                                        Mostrar apenas CT-es com Container
                                    </div>
                                </td>
                                <td class="TextoCampos font9">
                                    <div align="center">
                                        Apenas o Tipo de Produto/Operação:
					<select name="tipoproduto" id="tipoproduto" style="width:100px;" class="fieldMin">
                                            <option value="0">-- Todos --</option>
                                            <%ResultSet product_types = TipoProduto.all(Apoio.getConnectionFromUser(request),0,false,0);
                                            while (product_types.next()) {%>
                                                <script>
                                                        listOptTipoProd[idxTpProd++] = new Option("<%=product_types.getInt("id")%>", "<%=product_types.getString("descricao")%>");
                                                </script>
                                                <option value="<%=product_types.getString("id")%>"
                                                                                style="background-color:#FFFFFF"
                                                                                <%=(product_types.getInt("id") == Integer.parseInt(request.getParameter("tipoproduto") == null ? "0" : request.getParameter("tipoproduto"))  ? "Selected" : "")%>> <%=product_types.getString("descricao")%> 
                                                </option>
                                                 
                                            <%}%>
                                        </select>
                                    </div>
                                </td>    
                                <td class="CelulaZebra2 font9" colspan="3">
                                    <div align="center">
                                        <input name="mostrarNFS" type="checkbox" id="mostrarNFS" <%=(request.getParameter("mostrarNFS") != null ? "checked" : "" )%> >
                                        Mostrar Notas de Serviços 
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos font9" colspan="6">
                        <div align="center">
                            <input name="visualiza" type="button" class="botoes" id="visualiza" value="   Visualizar  " onClick="javascript:tryRequestToServer(function(){visualizar();});">
                        </div>
                    </td>
                </tr>
            </table>
            <table width="100%" border="0" class="bordaFina">
                <tr class="tabela font9">
                    <td width="2%" ></td>
                    <td width="5%" >
                        <strong>CT-e/NFS</strong>
                    </td>
                    <td width="4%">
                        <strong>Filial</strong>
                    </td>
                    <td width="5%" >
                        <strong>Data</strong>
                    </td>
                    <td width="7%" align="right">
                        <strong>Valor Frete</strong>
                    </td>
                    <td width="7%" align="right">
                        <strong>
                            Valor Servi&ccedil;os
                            <br>
                            Custo Servi&ccedil;os
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Reten.
                            <br/>
                            Terceiro
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Custo
                            <br/>
                            Terceiro
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Custo
                            <br/>
                            Coleta
                        </strong>
                    </td>
                    <td width="5%" align="right">
                        <strong>
                            ICMS
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Impostos
                            <br>
                            Federais
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Seguro
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Comiss&atilde;o
                            <br>
                            Vendedor
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Custo Viagem
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Custo Entrega
                        </strong>
                    </td>
                    <td width="6%" align="right">
                        <strong>
                            Represen.
                            <br>
                            Motorista
                        </strong>
                    </td>
                    <td width="7%" align="right">
                        <strong>
                            L&iacute;quido
                        </strong>
                    </td>
                    <td width="4%" align="right">
                        <strong>
                            %
                        </strong>
                    </td>
                </tr>
                <% 
             int linha = 1;
             int idGrupo = 0;
             int contadorGrupo = 0;
             int contadorTotal = 0;
             boolean primeiro = true;
             
             int contadorMesmaCartaFrete = 0;
             int idMesmaCartaFrete = 0;
             double totalFreteCartaFrete = 0;
             float totalPesoCartaFrete = 0;
             double totalValorServicoCartaFrete = 0;
             double totalCustoServicoCartaFrete = 0;
             double totalColetaCartaFrete = 0;
             double totalRetMotoCartaFrete = 0;
             double totalRetMotoCartaFreteView = 0;
             double totalMotoCartaFrete = 0;
             double totalReprCartaFrete = 0;
             double totalVendCartaFrete = 0;
             double totalSeguroCartaFrete = 0;
             double totalIcmsCartaFrete = 0;
             double totalImpFedCartaFrete = 0;
             double totalViagemCartaFrete = 0;
             double totalRomaneioCartaFrete = 0;
             double totalLiquidoCartaFrete = 0;
             double totalPercLucroCartaFrete = 0;
             
             double frete = 0;
             double totalFrete = 0;
             double totalGeralFrete = 0;
             float peso = 0;
             float totalPeso = 0;
             float totalGeralPeso = 0;
             double valorServico = 0;
             double totalValorServico = 0;
             double totalGeralValorServico = 0;
             double custoServico = 0;
             double totalCustoServico = 0;
             double totalGeralCustoServico = 0;
             double coleta = 0;
             double totalColeta = 0;
             double totalGeralColeta = 0;
             double moto = 0;
             double totalMoto = 0;
             double totalGeralMoto = 0;
             double retMoto = 0;
             double totalRetMoto = 0;
             double totalGeralRetMoto = 0;
             double retMotoView = 0;
             double totalRetMotoView = 0;
             double totalGeralRetMotoView = 0;
             
             double repr = 0;
             double totalRepr = 0;
             double totalGeralRepr = 0;
             double vend = 0;
             double totalVend = 0;
             double totalGeralVend = 0;
             double seguro = 0;
             double totalSeguro = 0;
             double totalGeralSeguro = 0;
             double icms = 0;
             double totalIcms = 0;
             double totalGeralIcms = 0;
             double impFed = 0;
             double totalImpFed = 0;
             double totalGeralImpFed = 0;
             double viagem = 0;
             double totalViagem = 0;
             double totalGeralViagem = 0;
             double romaneio = 0;
             double totalRomaneio = 0;
             double totalGeralRomaneio = 0;
             double liquido = 0;
             double totalLiquido = 0;
             double totalGeralLiquido = 0;
             double percLucro = 0;
             double totalPercLucro = 0;
             double totalGeralPercLucro = 0;
             double comissao2 = 0;
             String tipoCom = "";
             double perc = 0;
             double sumMoto = 0;
             double totalSumMoto = 0;
             double PercentualMoto = 0;
             double totalPercentualPorc = 0;
             double totalPercentualPorc2 = 0;
             double totalGeralPercentual = 0;
             
             AnaliseFreteCTRC analiseFreteCTRC =  new AnaliseFreteCTRC(request.getParameter("idFiliaisSelecionadas") == null ? "" : request.getParameter("idFiliaisSelecionadas"),
                                 Integer.parseInt(request.getParameter("idconsignatario") == null ? "0" : request.getParameter("idconsignatario")),
                                 Integer.parseInt(request.getParameter("idmotorista") == null ? "0" : request.getParameter("idmotorista")),
                                 request.getParameter("agrupar"),
                                 tipoVeiculo,
                                 idVendedor, 
                                 idProprietario,
                                 tipoMotorista,
                                 considerar, apenasManifesto, apenasContratoFrete , apenasComContratoADV, apenasComContainer,
                                 Integer.parseInt(request.getParameter("tipoproduto") == null ? "0" : request.getParameter("tipoproduto")),
                                 isMostrarNFS,
                                 Integer.parseInt(request.getParameter("idveiculo") == null ? "0" : request.getParameter("idveiculo")),
                     (request.getParameter("idsGruposCliSelecionados") == null ? "" : request.getParameter("idsGruposCliSelecionados")),
                     (request.getParameter("excetoGrupo") == null ? "" : request.getParameter("excetoGrupo"))
             );
                         
             if ((acao.equals("consultar")) && (conCtrc.consultarAnaliseFreteCTRC(analiseFreteCTRC))) {
                             //Apenas as duplicatadas agora
                             ResultSet rs = conCtrc.getResultado();
                while (rs.next()) {
                    if((idGrupo != rs.getInt("id_agrupamento") || idMesmaCartaFrete != rs.getInt("idcartafrete"))  
                            && (request.getParameter("agrupar") != null && !request.getParameter("agrupar").equals("Cliente"))){
                        //if (idMesmaCartaFrete != 0){
                        if (!primeiro){
                                if ((idMesmaCartaFrete == 0 && contadorMesmaCartaFrete > 0) || contadorMesmaCartaFrete > 1){%>
                                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1 font9" : "CelulaZebra2 font9")%>">
                                        <td colspan="4" align="right">
                                            <b><%=contadorMesmaCartaFrete%> CT-es - <%=idMesmaCartaFrete == 0 ? "Totais sem viagem": "Totais da viagem Nº " + idMesmaCartaFrete%></b>
                                        </td>
                                        <td align="right">
                                            <b><%=formatador_valor.format(totalFreteCartaFrete)%><br>
                                               <font style="font-size: 6pt;"><%=formatador_peso.format(totalPesoCartaFrete)%></font> 
                                            </b>
                                        </td>
                                        <td align="right">
                                            <b><%=formatador_valor.format(totalValorServicoCartaFrete)%></b>
                                            <br>
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalCustoServicoCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalRetMotoCartaFreteView)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalMotoCartaFrete)%></b>
                                                <%if(idMesmaCartaFrete !=0){%>
                                                    <br>
                                                    <b title="Total do Percentual de Custo de Terceiro Sobre o Valor do Frete">
                                                        <%=formatador_valor.format(totalPercentualPorc)%>%
                                                    </b>
                                                <%}%>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalColetaCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalIcmsCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalImpFedCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalSeguroCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalVendCartaFrete)%></b>
                                            </font>
                                        </td>                        

                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalViagemCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalRomaneioCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right"> 
                                            <font color="red">
                                                <b><%=formatador_valor.format(totalReprCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color=<%=totalLiquido <= 0 ? "red" : "black"%>>
                                                <b><%=formatador_valor.format(totalLiquidoCartaFrete)%></b>
                                            </font>
                                        </td>
                                        <td align="right">
                                            <font color=<%=totalPercLucro <= 0 ? "red" : "black"%>>
                                                <b><%=formatador_valor.format(totalPercLucroCartaFrete)%></b>
                                            </font>
                                        </td>
                                    </tr>
                <%
                               }
                         contadorMesmaCartaFrete = 0;
                         totalFreteCartaFrete = 0;
                         totalPesoCartaFrete = 0;
                         totalValorServicoCartaFrete = 0;
                         totalCustoServicoCartaFrete = 0;
                         totalColetaCartaFrete = 0;
                         totalRetMotoCartaFrete = 0;
                         totalRetMotoCartaFreteView = 0;
                         totalMotoCartaFrete = 0;
                         totalReprCartaFrete = 0;
                         totalVendCartaFrete = 0;
                         totalSeguroCartaFrete = 0;
                         totalIcmsCartaFrete = 0;
                         totalImpFedCartaFrete = 0;
                         totalViagemCartaFrete = 0;
                         totalRomaneioCartaFrete = 0;
                         totalLiquidoCartaFrete = 0;
                         totalPercLucroCartaFrete = 0;
                         totalPercentualPorc = (totalMoto * 100)/totalFrete;
                         
                        }
                        idMesmaCartaFrete = rs.getInt("idcartafrete");
                        linha++;
                    }
                    if(idGrupo != rs.getInt("id_agrupamento")){
                        if (idGrupo != 0){
                                        %>
                
                            <tr class="CelulaZebra1 font9">
                                <td colspan="4" align="right">
                                    <b><%=contadorGrupo%> CT-es - Totais <%=request.getParameter("agrupar")%></b>
                                </td>
                                <td align="right">
                                    <b><%=formatador_valor.format(totalFrete)%><br>
                                       <font style="font-size: 6pt;"><%=formatador_peso.format(totalPeso)%> Kg</font> 
                                    </b>
                                </td>
                                <td align="right">
                                    <b><%=formatador_valor.format(totalValorServico)%></b>
                                    <br>
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalCustoServico)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalRetMotoView)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalMoto)%></b>
                                        <br>
                                        <b title="Total do Percentual de Custo de Terceiro Sobre o Valor do Frete">
                                            <%=formatador_valor.format(totalPercentualPorc2)%>%
                                        </b>
                                   </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalColeta)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalIcms)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalImpFed)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalSeguro)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalVend)%></b>
                                    </font>
                                </td>                        
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalViagem)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalRomaneio)%></b>
                                    </font>
                                </td>
                                <td align="right"> 
                                    <font color="red">
                                        <b><%=formatador_valor.format(totalRepr)%></b>
                                        <br>
                                        <b><%=formatador_valor.format(sumMoto)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color=<%=totalLiquido <= 0 ? "red" : "black"%>>
                                        <b><%=formatador_valor.format(totalLiquido)%></b>
                                    </font>
                                </td>
                                <td align="right">
                                    <font color=<%=totalPercLucro <= 0 ? "red" : "black"%>>
                                        <b><%=formatador_valor.format(totalPercLucro)%></b>
                                    </font>
                                </td>
                            </tr>
                <%
                        totalFrete = 0;
                        totalPeso = 0;
                        totalValorServico = 0;
                        totalCustoServico = 0;
                        totalColeta = 0;
                        totalRetMoto = 0;
                        totalRetMotoView = 0;
                        totalMoto = 0;
                        totalRepr = 0;
                        totalVend = 0;
                        totalSeguro = 0;
                        totalIcms = 0;
                        totalImpFed = 0;
                        totalViagem = 0;
                        totalRomaneio = 0;
                        totalLiquido = 0;
                        contadorGrupo = 0;
                        sumMoto = 0;
                        totalPercentualPorc = 0;
                    }
                        idGrupo = rs.getInt("id_agrupamento");
                    %>

                    <tr class="CelulaZebra1 font9">
                        <td colspan="4">
                            <div align="right">
                                <b><%=request.getParameter("agrupar")%>:</b>
                            </div>
                        </td>
                        <td colspan="15">
                            <div align="left">
                                <b><%=rs.getString("descricao_agrupamento") == null ? "Sem " + request.getParameter("agrupar") : rs.getString("descricao_agrupamento")%></b>
                            </div>
                        </td>
                    </tr>
                        <%}
                    
            frete = rs.getDouble("total_receita");
            peso = rs.getFloat("peso");
            coleta = rs.getDouble("coleta");
            retMoto = (cfg.isConsideraOutrasRetencoesDespesaAnaliseFrete() ? rs.getDouble("retencoes_motorista") : 0 );
            retMotoView = rs.getDouble("retencoes_motorista");
            moto = rs.getDouble("motorista");
            repr = rs.getDouble("representante");
            vend = rs.getDouble("vl_comissao_vendedor");
            seguro = rs.getDouble("seguro");
            icms = rs.getDouble("vl_icms");
            impFed = rs.getDouble("imp_federais");
            viagem = (rs.getDouble("despesa_viagem")  + rs.getDouble("despesa_carta_frete"));
            romaneio = rs.getDouble("romaneio");
            valorServico = rs.getDouble("valor_servico");
            custoServico = rs.getDouble("custo_servico");
            tipoCom = rs.getString("tipocomissao");
            perc = rs.getDouble("percentual_comissao_frete");
            
            PercentualMoto = (100 * moto)/frete;
            
            if(tipoCom.equals("b")){
                  comissao2 = rs.getDouble("comissao2");
                  liquido = ((frete + valorServico)-coleta-moto-repr-vend-seguro-icms-impFed-viagem-romaneio-retMoto-custoServico) - comissao2;
            }else if(tipoCom.equals("l")){
                  comissao2 = rs.getDouble("comissao2");
                  liquido = ((frete + valorServico)-coleta-moto-repr-vend-seguro-icms-impFed-viagem-romaneio-retMoto-custoServico) - (((((frete + valorServico)-coleta-moto-repr-vend-seguro-icms-impFed-viagem-romaneio-retMoto-custoServico) * perc))/100) ;
            }
            
            percLucro = liquido * 100 / (frete + valorServico);
            
            totalFreteCartaFrete += frete;
            totalPesoCartaFrete += peso;
            totalValorServicoCartaFrete += valorServico;
            totalCustoServicoCartaFrete += custoServico;
            totalColetaCartaFrete += coleta;
            totalRetMotoCartaFrete += retMoto;
            totalRetMotoCartaFreteView += retMotoView;
            totalMotoCartaFrete += moto;
            totalReprCartaFrete += repr;
            totalVendCartaFrete += vend;
            totalSeguroCartaFrete += seguro;
            totalIcmsCartaFrete += icms;
            totalImpFedCartaFrete += impFed;
            totalViagemCartaFrete += viagem;
            totalRomaneioCartaFrete += romaneio;
            totalLiquidoCartaFrete += liquido;
            totalPercLucroCartaFrete = totalLiquidoCartaFrete * 100 / (totalFreteCartaFrete + totalValorServicoCartaFrete);
            
            sumMoto += comissao2;
            totalSumMoto += comissao2;
                    
            totalPeso += peso;
            totalGeralPeso += peso;
            totalFrete += frete;
            totalGeralFrete += frete;
            totalValorServico += valorServico;
            totalGeralValorServico += valorServico;
            totalCustoServico += custoServico;
            totalGeralCustoServico += custoServico;
            totalColeta += coleta;
            totalGeralColeta += coleta;
            totalRetMoto += retMoto;
            totalRetMotoView += retMotoView;
            totalGeralRetMoto += retMoto;
            totalGeralRetMotoView += retMotoView;
            totalMoto += moto;
            totalGeralMoto += moto;
            totalRepr += repr;
            totalGeralRepr += repr;
            totalVend += vend;
            totalGeralVend += vend;
            totalSeguro += seguro;
            totalGeralSeguro += seguro;
            totalIcms += icms;
            totalGeralIcms += icms;
            totalImpFed += impFed;
            totalGeralImpFed += impFed;
            totalViagem += viagem;
            totalGeralViagem += viagem;
            totalRomaneio += romaneio;
            totalGeralRomaneio += romaneio;
            totalLiquido += liquido;
            totalGeralLiquido += liquido;
            totalPercentualPorc = (100 * totalMotoCartaFrete)/totalFreteCartaFrete;
            totalPercentualPorc2 = (100 * totalMoto)/totalFrete;
            totalGeralPercentual = (100 * totalGeralMoto) / totalGeralFrete;
           
            
            totalPercLucro = totalLiquido * 100 / (totalFrete + totalValorServico);
            totalGeralPercLucro = totalGeralLiquido * 100 / (totalGeralFrete + totalGeralValorServico);
             
    %>
                    <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1 font9" : "CelulaZebra2 font9")%>" >
                        <td>
                            <%if(rs.getInt("idcartafrete") != 0 ){%>
                                <div align="center">
                                    <img src="img/pdf.gif" width="19" height="19" border="0" align="right" class="imagemLink" title="Formato PDF(usado para a impressão)"
                                                    onClick="javascript:tryRequestToServer(function(){popCarta('<%=rs.getString("idcartafrete")%>');});">
                                </div>
                            <%}%>
                        </td>
                        <td>
                            <div class="linkEditar font9" onClick="javascript:tryRequestToServer(function(){editarconhecimento(<%=rs.getString("id") + ",null"%>);});">
                                <%=rs.getString("numero_ctrc")+"/"+rs.getString("serie")%>
                            </div>
                        </td>
                        <td>
                            <%=rs.getString("abv_filial")%>
                        </td>
                        <td>
                            <%=(rs.getDate("emissao_em_ctrc") == null ? "" : formatador.format(rs.getDate("emissao_em_ctrc")))%>
                        </td>
                        <td align="right">
                            <%=formatador_valor.format(frete)%><br>
                            <font style="font-size: 6pt;"><%=formatador_peso.format(peso)%> Kg</font>
                        </td>
                        <td align="right">
                            <%=formatador_valor.format(valorServico)%>
                            <br>
                            <font color="red"><%=formatador_valor.format(custoServico)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(retMotoView)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(moto)%></font>
                            <br>
                            <font color="red" title="Percentual do Custo de Terceiro Sobre o Valor do Frete">
                                <%=formatador_valor.format(PercentualMoto)%>%
                            </font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(coleta)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(icms)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(impFed)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(seguro)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(vend)%></font>
                        </td>                        
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(viagem)%></font>
                        </td>
                        <td align="right">
                            <font color="red"><%=formatador_valor.format(romaneio)%></font>
                        </td>
                        <td align="right"> 
                            <font color="red"><%=formatador_valor.format(repr)%></font>
                            <br>
                            <font color="red"><%=formatador_valor.format(comissao2)%></font>
                        </td>
                        <td align="right">
                            <font color=<%=liquido <= 0 ? "red" : "black"%>><%=formatador_valor.format(liquido)%></font>
                        </td>
                        <td align="right">
                            <font color=<%=percLucro <= 0 ? "red" : "black"%>><%=formatador_valor.format(percLucro)%></font>
                        </td>
                    </tr>
                <%
                    
                    contadorGrupo++;
                    contadorTotal++;
                    contadorMesmaCartaFrete++;
                    primeiro = false;
                    if((request.getParameter("agrupar") != null && request.getParameter("agrupar").equals("Cliente"))){
                        linha++;
                    }
                    
                }//fim while(rs.next())
            }//fim consulta
                
       if (contadorMesmaCartaFrete != 0 && (request.getParameter("agrupar") != null && !request.getParameter("agrupar").equals("Cliente"))){
            %>
                <tr class="<%=((linha % 2) == 0 ? "CelulaZebra1 font9" : "CelulaZebra2 font9")%>">
                    <td colspan="4" align="right">
                        <b><%=contadorMesmaCartaFrete%> CT-es - <%=idMesmaCartaFrete == 0 ? "Totais sem viagem": "Totais da viagem Nº " + idMesmaCartaFrete%></b>
                    </td>
                    <td align="right">
                        <b><%=formatador_valor.format(totalFreteCartaFrete)%><br>
                            <font style="font-size: 6pt;"><%=formatador_peso.format(totalPesoCartaFrete)%> Kg</font>
                        </b>
                    </td>
                    <td align="right">
                        <b><%=formatador_valor.format(totalValorServicoCartaFrete)%></b>
                        <br>
                        <font color="red">
                            <b><%=formatador_valor.format(totalCustoServicoCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalRetMotoCartaFreteView)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalMotoCartaFrete)%></b>
                            <br>
                            <b title="Total do Percentual de Custo de Terceiro Sobre o Valor do Frete">
                                <%=formatador_valor.format(totalPercentualPorc)%>%
                            </b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalColetaCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalIcmsCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalImpFedCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalSeguroCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalVendCartaFrete)%></b>
                        </font>
                    </td>                        
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalViagemCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalRomaneioCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right"> 
                        <font color="red">
                            <b><%=formatador_valor.format(totalReprCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color=<%=totalLiquido <= 0 ? "red" : "black"%>>
                            <b><%=formatador_valor.format(totalLiquidoCartaFrete)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color=<%=totalPercLucro <= 0 ? "red" : "black"%>>
                            <b><%=formatador_valor.format(totalPercLucroCartaFrete)%></b>
                        </font>
                    </td>
                </tr>
            <%
                }
            %>
                
                <tr class="CelulaZebra1 font9">
                    <td colspan="4" align="right">
                        <b><%=contadorGrupo%> CT-es - Totais <%=request.getParameter("agrupar") == null ? "Cliente" : request.getParameter("agrupar")%></b>
                    </td>
                    <td align="right">
                        <b><%=formatador_valor.format(totalFrete)%><br>
                           <font style="font-size: 6pt;"><%=formatador_peso.format(totalPeso)%> Kg</font> 
                        </b>
                    </td>
                    <td align="right">
                        <b><%=formatador_valor.format(totalValorServico)%></b>
                        <br>
                        <font color="red">
                            <b><%=formatador_valor.format(totalCustoServico)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalRetMotoView)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalMoto)%></b>
                            <br>
                            <b title="Total do Percentual de Custo de Terceiro Sobre o Valor do Frete">
                                <%=formatador_valor.format(totalPercentualPorc2)%>%
                            </b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalColeta)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalIcms)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalImpFed)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalSeguro)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalVend)%></b>
                        </font>
                    </td>                        
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalViagem)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalRomaneio)%></b>
                        </font>
                    </td>
                    <td align="right"> 
                        <font color="red">
                            <b><%=formatador_valor.format(totalRepr)%></b>
                            <br>
                            <b><%=formatador_valor.format(sumMoto)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color=<%=totalLiquido <= 0 ? "red" : "black"%>>
                            <b><%=formatador_valor.format(totalLiquido)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color=<%=totalPercLucro <= 0 ? "red" : "black"%>>
                            <b><%=formatador_valor.format(totalPercLucro)%></b>
                        </font>
                    </td>
                </tr>         
                <tr class="CelulaZebra2 font9">
                    <td colspan="18" align="right"></td>
                </tr>
                <tr class="CelulaZebra1 font9">
                    <td colspan="4" align="right">
                        <b><%=contadorTotal%> CT-es - Totais gerais</b>
                    </td>
                    <td align="right">
                        <b><%=formatador_valor.format(totalGeralFrete)%><br>
                        <font style="font-size: 6pt;"><%=formatador_peso.format(totalGeralPeso)%> Kg</font> 
                        </b>
                    </td>
                    <td align="right">
                        <b><%=formatador_valor.format(totalGeralValorServico)%></b>
                        <br>
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralCustoServico)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralRetMotoView)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralMoto)%></b>
                            <br>
                            <b title="Total Geral do Percentual de Custo de Terceiro Sobre o Valor do Frete">
                                <%=formatador_valor.format(totalGeralPercentual)%>%
                            </b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralColeta)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralIcms)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralImpFed)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralSeguro)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralVend)%></b>
                        </font>
                    </td>                        
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralViagem)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralRomaneio)%></b>
                        </font>
                    </td>
                    <td align="right"> 
                        <font color="red">
                            <b><%=formatador_valor.format(totalGeralRepr)%></b>
                            <br>
                            <b><%=formatador_valor.format(totalSumMoto)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color=<%=totalGeralLiquido <= 0 ? "red" : "black"%>>
                            <b><%=formatador_valor.format(totalGeralLiquido)%></b>
                        </font>
                    </td>
                    <td align="right">
                        <font color=<%=totalGeralPercLucro <= 0 ? "red" : "black"%>>
                            <b><%=formatador_valor.format(totalGeralPercLucro)%></b>
                        </font>
                    </td>
                 </tr>
            </table>
            <br>
            <table width="100%" align="center" cellspacing="1" class="bordaFina">
                <tr>
                    <td class="tabela" colspan="3">
                        <div align="center">Formato do relatório </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos"> 
                        <div align="center">
                            <input type="radio" name="tipoImpressao" id="impressao_1"  value="1" border="0" onclick="tipoImpressaoSelecionado(this.value)" checked/>
                            <img src="img/pdf.gif" style="vertical-align: middle">
                            <input type="radio" name="tipoImpressao" id="impressao_2"  value="2"  border="0" onclick="tipoImpressaoSelecionado(this.value)"/>
                            <img src="img/excel.gif" style="vertical-align: middle">
                            <input type="radio" name="tipoImpressao"  id="impressao_3" value="3" border="0" onclick="tipoImpressaoSelecionado(this.value)" />
                            <img src="img/word.gif" style="vertical-align: middle">
                            <input type="hidden" id="valorTipoImpressao" value="1"/>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="TextoCampos">
                        <div align="center">
                            <input name="exportar" type="button" class="botoes" id="exportar" value="Imprimir Consulta"  onClick="javascript:tryRequestToServer(function(){popImpressao();});">
                        </div>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>