<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="br.com.gwsistemas.filial.usuario.UsuarioVendedor"%>
<%@page import="java.util.Collection"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>


<% boolean temacesso = (Apoio.getUsuario(request) != null
            && Apoio.getUsuario(request).getAcesso("relanalisevendasvendedor") > 0);
    //testando se a sessao é válida e se o usuário tem acesso
    if ((Apoio.getUsuario(request) == null) || (!temacesso)) {
        response.sendError(response.SC_FORBIDDEN);
    }
    //fim da MSA
    BeanUsuario user = Apoio.getUsuario(request);

    String acao = (temacesso && request.getParameter("acao") == null ? "" : request.getParameter("acao"));

    //exportacao da Cartafrete para arquivo .pdf
if (acao.equals("exportar")) {
        StringBuilder filtros = null;
        StringBuilder tipoData = null;
        SimpleDateFormat formatador = null;
        String tipoVendedor = null;
        String tipoFiltroVendedor = null;
        String modelo = null;
        Date dtinicial = null;
        Date dtfinal = null;
        Collection<UsuarioVendedor> usuarios = null;
        StringBuilder sqlTipoVendedor = new StringBuilder();
        StringBuilder sqlVendedor = new StringBuilder();
        StringBuilder ids = new StringBuilder();
        String[] idsArr = null;
        StringBuilder calcularComissao = null;
        StringBuilder tipoVendedorSupervisor = null;
        String pagarComissaoJuros = null;
        String pagarComissaoDesconto = null;
        String supervisorVendedor = "";
        String tipoPagamento = null;
        int idArea = Apoio.parseInt(request.getParameter("area_id"));
        boolean isIcms = Apoio.parseBoolean(request.getParameter("isIcms"));
        boolean isPis = Apoio.parseBoolean(request.getParameter("isPis"));
        boolean isCofins = Apoio.parseBoolean(request.getParameter("isCofins"));
        boolean isCssl = Apoio.parseBoolean(request.getParameter("isCssl"));
        boolean isIr = Apoio.parseBoolean(request.getParameter("isIr"));
        boolean isInss = Apoio.parseBoolean(request.getParameter("isInss"));
        boolean isRetirarContratoFreteBaseCalculo = Apoio.parseBoolean(request.getParameter("isRetirarContratoFreteBaseCalculo"));
        int idCidadeDestino = Apoio.parseInt(request.getParameter("idcidadeorigem"));
        try {
            filtros = new StringBuilder();
            tipoData = new StringBuilder();
            formatador = new SimpleDateFormat("dd/MM/yyyy");
            tipoVendedor = request.getParameter("tipoVendedor");
            tipoFiltroVendedor = request.getParameter("tipofiltrovendedor");
            modelo = request.getParameter("modelo");
            dtinicial = formatador.parse(request.getParameter("dtinicial"));
            dtfinal = formatador.parse(request.getParameter("dtfinal"));
            
            int idVendedor = Apoio.parseInt(request.getParameter("idvendedor"));

            //usuario recebe a lista de vendedores que foi definida no cadastro de Usuário
            usuarios = user.getItens();
            calcularComissao = new StringBuilder("'").append(request.getParameter("tipocomissao").toLowerCase()).append("'");
            pagarComissaoJuros = "'rj'";
            pagarComissaoDesconto = "'rd'";
            tipoPagamento = "'dtemissao'";
            tipoVendedorSupervisor = new StringBuilder("'").append(tipoVendedor).append("'");
            if (modelo.equals("1")) {
                if (user.isIsVendedor()) {
                    for (UsuarioVendedor str : usuarios) {
                        if (ids.length() == 0) {
                            ids.append(String.valueOf(str.getVendedor().getIdfornecedor()));
                        } else {
                            ids.append("','").append(String.valueOf(str.getVendedor().getIdfornecedor()));
                        }
                    }
                    idsArr = StringUtils.split(ids.toString(), ",");
                    if (ids.toString().trim().equals("")) {
                        supervisorVendedor  = "'vendedor'";
                        sqlTipoVendedor.append(" vendedor ");
                        sqlVendedor.append("");
                    } else if (tipoVendedor.equals("C")) {
                        if (tipoFiltroVendedor.equals("V")) {
                            sqlTipoVendedor.append(" vendedor ");
                            supervisorVendedor  = "'vendedor'";
                            if (idVendedor != 0) {
                                for (int i = 1; i < usuarios.size(); i++) {
                                    String id = idsArr[0].replaceAll("'", "");
                                    String id2 = idsArr[1].replaceAll("'", "");
                                    
                                    if (idVendedor == Apoio.parseInt(id) || idVendedor == Apoio.parseInt(id2)) {
                                        sqlVendedor.append(" AND (vendedor_cliente_id=").append(idVendedor).append(")");
                                        break;
                                    } else {
                                        sqlVendedor.append("");
                                    }
                                }

                            } else {
                                sqlVendedor.append(" AND vendedor_id IN ('").append(ids.toString()).append("') ");
                            }
                        } else if (tipoFiltroVendedor.equals("S")) {//quando for supervisor

                            sqlTipoVendedor.append(" supervisor_cliente AS vendedor ");
                            supervisorVendedor  = ("'supervisor'");
                            if (idVendedor != 0) {
                                for (int i = 0; i <= usuarios.size(); i++) {
                                    String id = idsArr[0].replaceAll("'", "");
                                    String id2 = idsArr[1].replaceAll("'", "");

                                    if (idVendedor == Apoio.parseInt(id) || idVendedor == Apoio.parseInt(id2)) {
                                        sqlVendedor.append(" AND (supervisor_cliente_id=").append(idVendedor).append(")");
                                        break;
                                    } else {
                                        sqlVendedor.append("");
                                    }
                                }
                            } else {
                                sqlVendedor.append(" AND supervisor_cliente_id IN ('").append(ids.toString()).append("') ");
                            }
                        }
                    } else {
                        sqlTipoVendedor.append(" vendedor ");
                        supervisorVendedor  = ("'vendedor'");
                        if (idVendedor != 0) {
                            sqlVendedor.append(" AND vendedor_id IN ('").append(ids).append("')");
                        } else {
                            sqlVendedor = new StringBuilder("");
                        }
                    }
                } else if (tipoVendedor.equals("C")) {

                    if (tipoFiltroVendedor.equals("V")) {
                        sqlTipoVendedor.append(" vendedor ");
                        supervisorVendedor  = ("'vendedor'");
                        if (idVendedor != 0) {
                            sqlVendedor.append(" AND (vendedor_cliente_id=").append(idVendedor).append(")");
                        } else {
                            sqlVendedor = new StringBuilder("");
                        }
                    } else if (tipoFiltroVendedor.equals("S")) {
                        sqlTipoVendedor.append(" supervisor_cliente AS vendedor ");
                        supervisorVendedor  = ("'supervisor'");
                        if (idVendedor != 0) {
                            sqlVendedor.append(" AND (supervisor_cliente_id=").append(idVendedor).append(")");
                        } else {
                            sqlVendedor = new StringBuilder("");
                        }
                    }
                } else {
                    sqlTipoVendedor.append(" vendedor ");
                    supervisorVendedor  = ("'vendedor'");
                    if (idVendedor != 0) {
                        sqlVendedor.append(" AND (vendedor_id=").append(idVendedor).append(")");
                    } else {
                        sqlVendedor = new StringBuilder("");
                    }
                }
            }
        } finally {

        }
        filtros.append("Usuário: ").append(user.getLogin()).append(".\n")
        .append("Período selecionado: ").append(request.getParameter("dtinicial")).append(" até ").append(request.getParameter("dtfinal"));
        java.util.Map param = new java.util.HashMap(10);
        param.put("IDAREA", (idArea == 0 ? "0" : "" + idArea + ""));
        param.put("IDCIDADEDESTINO", (idCidadeDestino == 0 ? "" : " and idcidade_destino=" + idCidadeDestino));
        param.put("IDVENDEDOR", sqlVendedor);
        param.put("DATA_INICIAL", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
        param.put("DATA_FINAL", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
        param.put("TIPOVENDEDOR", sqlTipoVendedor);
        param.put("CALCULAR_COMISSAO", calcularComissao);
        param.put("IS_ICMS", isIcms);
        param.put("IS_PIS", isPis);
        param.put("IS_COFINS", isCofins);
        param.put("IS_CSSL", isCssl);
        param.put("IS_IR", isIr);
        param.put("IS_INSS", isInss);
        param.put("IS_RETIRAR_CONTRATO_FRETE_BASE_CALCULO", isRetirarContratoFreteBaseCalculo);
        param.put("PAGAR_COMISSAO_JUROS", pagarComissaoJuros);
        param.put("PAGAR_COMISSAO_DESCONTO", pagarComissaoDesconto);
        param.put("SUPERVISOR_VENDEDOR", supervisorVendedor);
        param.put("TIPO_PAGAMENTO", tipoPagamento);
        param.put("TIPO_VENDEDOR_SUPERVISOR", tipoVendedorSupervisor);

        param.put("USUARIO", Apoio.getUsuario(request).getNome());
        param.put("CLIENTE_LICENCA", (Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENSA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));

        request.setAttribute("map", param);
        request.setAttribute("rel", "analise_vendas_vendedor_mod" + modelo);

        RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
        dispacher.forward(request, response);

    } else if (acao.equals("iniciar")) {
        request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_ANALISE_VENDAS_RELATORIO.ordinal());

    }

%>


<script language="javascript" type="text/javascript">
    function voltar() {
        location.replace("./menu");
    }

    function popRel() {
        var idvendedor = $("idvendedor").value;
        var idarea = $("area_id").value;
        var idcidade = $("idcidadeorigem").value;
        var impressao;
        if ($("pdf").checked)
            impressao = "1";
        else if ($("excel").checked)
            impressao = "2";
        else
            impressao = "3";

        launchPDF('./relanalisevendasvendedor.jsp?acao=exportar&modelo=1&impressao=' + impressao
                + '&dtinicial=' + $("dtinicial").value
                + '&dtfinal=' + $("dtfinal").value
                + '&tipofiltrovendedor=' + $("tipofiltrovendedor").value
                + '&idvendedor=' + idvendedor
                + '&area_id=' + idarea
                + '&idcidadeorigem=' + idcidade
                + '&tipoVendedor=' + $("tipovendedor").value
                + '&tipocomissao=' + $("tipocomissao").value
                + '&isIcms=' + $("icms").checked
                + '&isPis=' + $("pis").checked
                + '&isCofins=' + $("cofins").checked
                + '&isCssl=' + $("cssl").checked
                + '&isIr=' + $("ir").checked
                + '&isInss=' + $("inss").checked
                + '&isRetirarContratoFreteBaseCalculo=' + $("retirarContratoFreteBaseCalculo").checked);

    }

    function aoClicarNoLocaliza(idjanela) {
        if (idjanela == "Grupo") {
            addGrupo($('grupo_id').value, 'node_grupos', getObj('grupo').value)
        }
    }

    function limparCidade() {
        $("cid_origem").value = "";
        $("idcidadeorigem").value = 0;
    }
    function limparArea() {
        $("area_id").value = 0;
        $("area").value = "";
    }
    function limparVendedor() {

        $("ven_rzs").value = '';
        $("idvendedor").value = 0;

    }

    function desabilitarImposto(calcularComissao) {
        if (calcularComissao == "B") {
            $("impostoFederais").disabled = true;
            $("icms").disabled = true;
            $("pis").disabled = true;
            $("cofins").disabled = true;
            $("cssl").disabled = true;
            $("ir").disabled = true;
            $("inss").disabled = true;
        } else if (calcularComissao == "L") {
            $("impostoFederais").disabled = false;
            $("icms").disabled = false;
            $("pis").disabled = false;
            $("cofins").disabled = false;
            $("cssl").disabled = false;
            $("ir").disabled = false;
            $("inss").disabled = false;
        }
    }

    /**
     * função marcarTodosImpostos
     * irá marcar os filtros de: icms, pis, cofins, cssl, ir e inss
     */
    function marcarTodosImpostos() {
        $("icms").checked = $("impostoFederais").checked;
        $("pis").checked = $("impostoFederais").checked;
        $("cofins").checked = $("impostoFederais").checked;
        $("cssl").checked = $("impostoFederais").checked;
        $("ir").checked = $("impostoFederais").checked;
        $("inss").checked = $("impostoFederais").checked;
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

        <title>Webtrans - Relat&oacute;rio de an&aacute;lise de Vendas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>
    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>);">
        <div align="center">
            <img src="img/banner.gif"  alt="banner"><br>
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="idfilial" id="idfilial" value="0">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22">
                    <b>Relat&oacute;rio de An&aacute;lise de Vendas</b>
                </td>
            </tr>
        </table>
        <br>

        <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="center">
            <tr>
                <td>
                    <table width="90%" border="0" cellspacing="1" cellpadding="2" class="bordaFina" align="left">
                        <tr class="tabela" id="">
                            <td id="tdAbaPrincipal" class="menu-sel" onclick="AlternarAbasGenerico('tdAbaPrincipal', 'tabPrincipal');"> <center> Relatórios Principais </center></td>
                <td id="tdAbaDinamico" class="menu" onclick="AlternarAbasGenerico('tdAbaDinamico', 'tabDinamico');"> Relatórios Personalizados </td>
            </tr>
        </table>
    </td>
</tr>
</table>
<div id="tabPrincipal">    
    <table width="90%" border="0" class="bordaFina" align="center">
        <tr class="tabela"> 
            <td colspan="3">
                <div align="center">Modelos</div>
            </td>
        </tr>
        <tr> 
            <td width="23%" class="TextoCampos"> 
                <div align="left"> 
                    <input name="modelo1" id="modelo1" type="radio" value="1" checked ">
                           Modelo 1
                </div>
            </td>
            <td width="77%" colspan="2" class="CelulaZebra2"> Curva ABC de Clientes por Vendedor </td>
        </tr>
        <tr class="tabela"> 
            <td colspan="3">
                <div align="center">Crit&eacute;rio de datas</div>
            </td>
        </tr>
        <tr> 
            <td class="TextoCampos">Emissão Entre:</td>
            <td colspan="2" class="CelulaZebra2"> 
                <strong>
                    <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                           onblur="alertInvalidDate(this)" class="fieldDate" />
                </strong>
                e
                <strong> 
                    <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10" 
                           onblur="alertInvalidDate(this)" class="fieldDate" />
                </strong>
            </td>
        </tr>
        <tr class="tabela"> 
            <td colspan="3"> 
                <div align="center">Filtros</div>
            </td>
        </tr>
        <tr>
            <td colspan="3"> 
                <table width="100%" border="0" class="bordaFina" >
                    <tr name="trTipoVendedor" id="trTipoVendedor">
                        <td colspan="2" class="TextoCampos">
                            <div align="center">
                                <select name="tipovendedor" id="tipovendedor" onBlur="javascript:if (this.value == 'L')
                                            $('tipofiltrovendedor').value = 'V';" class="inputtexto">
                                    <option value="L" selected>Utilizar V&iacute;nculo do Vendedor nos Lan&ccedil;amentos de CTs/NFS</option>
                                    <option value="C">Utilizar V&iacute;nculo do Vendedor no Cadastro de Clientes</option>
                                </select>
                            </div>
                        </td>
                    </tr>
                    <tr> 
                        <td width="50%" class="TextoCampos">
                            <select name="tipofiltrovendedor" class="inputtexto" id="tipofiltrovendedor" onBlur="javascript:if (this.value == 'S')
                                        $('tipovendedor').value = 'C';">
                                <option value="V" selected>Apenas o Vendedor:</option>
                                <option value="S">Apenas o Supervisor:</option>
                            </select>
                        </td>
                        <td width="50%" class="CelulaZebra2">
                            <strong>
                                <input name="idvendedor" type="hidden" id="idvendedor" class="inputReadOnly" value="0" size="35" maxlength="80" readonly="true">
                                <input name="ven_rzs" type="text" id="ven_rzs" class="inputReadOnly" value="" size="35" maxlength="80" readonly="true">
                                <input name="botaLocalizarVendedor" type="button" class="inputbotao" id="botaLocalizarVendedor" value="..."
                                       onClick="javascript:window.open('./localiza?acao=consultar&idlista=27', 'Vendedor', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');">
                                <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Vendedor" onClick="limparVendedor()">
                            </strong>
                        </td>
                    </tr>
                    <tr> 
                        <td class="TextoCampos">
                            <div align="right">Apenas a Cidade:</div>
                        </td>
                        <td class="CelulaZebra2">
                            <input type="hidden" name="idcidadeorigem" id="idcidadeorigem" value="0"/>
                            <input name="cid_origem" id="cid_origem" type="text" class="inputReadOnly" size="25" readonly/>
                            <input type="button" class="inputbotao" name="botaoCidade" id="botaoCidade"  onclick="javascript:window.open('./localiza?acao=consultar&idlista=11', 'Cidade', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" value="..."/>
                            <img src="img/borracha.gif" alt="" name="borrachaCidade" class="imagemLink" id="borracha2" onclick="limparCidade()"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="TextoCampos">
                            <div align="right">Apenas a Área:</div>
                        </td>
                        <td class="CelulaZebra2">
                            <input name="area" id="area" type="text" class="inputReadOnly" size="25" readonly/>
                            <input type="hidden" name="area_id" id="area_id" value="0"/>
                            <input type="button" class="inputbotao" name="botaoArea" id="botaoArea"  onclick="javascript:window.open('./localiza?acao=consultar&idlista=34', 'Area', 'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');" value="..."/>
                            <img src="img/borracha.gif" alt="" name="borrachaArea" class="imagemLink" id="borracha2" onclick="limparArea()"/>
                        </td>
                    </tr>
                    <tr id="trTipoComissao" name="trTipoComissao">
                        <td class="TextoCampos">Calcular Comiss&atilde;o: </td>
                        <td class="CelulaZebra2">
                            <label>
                                <select name="tipocomissao" id="tipocomissao" class="inputtexto" onclick="desabilitarImposto(this.value)">
                                    <option value="L" selected>Valor L&iacute;quido</option>
                                    <option value="B">Valor Bruto</option>
                                </select>
                            </label>
                        </td>
                    </tr>
                    <tr id="trCriterioPagamentoComissao" style="display: ">
                        <td class="CelulaZebra2">
                            <div align="center">
                                <label><input type="checkbox" id="impostoFederais" name="impostoFederais" value="false" onclick="marcarTodosImpostos('Vendedor')"/>Impostos federais</label>
                                <label><input type="checkbox" id="icms" name="icms" value="checkbox" checked/>ICMS</label>
                                <label><input type="checkbox" id="pis" name="pis" value="checkbox"/>PIS</label>
                                <label><input type="checkbox" id="cofins" name="cofins" value="checkbox"/>COFINS</label>
                                <label><input type="checkbox" id="cssl" name="cssl" value="checkbox"/>CSSL</label>
                                <label><input type="checkbox" id="ir" name="ir" value="checkbox"/>IR</label>
                                <label><input type="checkbox" id="inss" name="inss" value="checkbox"/>INSS</label>                                    
                            </div>
                        </td>
                        <td class="TextoCamposNoAlign">
                            <div align="center">
                                <label>                                    
                                    <input type="checkbox" id="retirarContratoFreteBaseCalculo" name="retirarContratoFreteBaseCalculo" value="checkbox"/>
                                    Retirar contrato frete da base de cálculo
                                </label>                                    
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="3" class="tabela">
                <div align="center">Formato do relat&oacute;rio </div>
            </td>
        </tr>
        <tr>
            <td colspan="3" class="TextoCampos">
                <div align="center">
                    <input type="radio" name="impressao" id="pdf" value="1" checked/>
                    <img src="./img/pdf.gif" width="19" height="20" style="vertical-align: middle">
                    <input type="radio" name="impressao" id="excel" value="2" />
                    <img src="./img/excel.gif" width="20" height="19"  style="vertical-align: middle">
                    <input type="radio" name="impressao" id="word" value="3" />
                    <img src="./img/word.gif" width="20" height="19"  style="vertical-align: middle">
                </div>
            </td>
        </tr>
        <tr> 
            <td colspan="3" class="TextoCampos"> 
                <div align="center"> 
                    <% if (temacesso) {%>
                    <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function () {
                                popRel();
                            });">
                    <%}%>
                </div>
            </td>
        </tr>
    </table>
</div>
<div id="tabDinamico"></div>
</body>
</html>
