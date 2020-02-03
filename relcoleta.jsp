<%@page import="br.com.gwsistemas.sistematiporelatorio.SistemaTipoRelatorio"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="groovy.lang.Script"%>
<%@page import="usuario.BeanUsuario"%>
<%@ page contentType="text/html; charset=iso-8859-1" language="java"
         import="nucleo.BeanConfiguracao,
         java.text.*,
         nucleo.BeanLocaliza,
         java.util.Date,
         nucleo.Apoio" errorPage="" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script language="javascript" type="text/javascript" src="script/jsRelatorioDinamico.js"></script>
<script language="JavaScript" src="script/jquery-1.11.2.min.js" type="text/javascript"></script>
<script language="JavaScript"  src="script/grupo-util.js" type=""></script>
<script language="JavaScript"  src="script/funcoes.js" type="text/javascript"></script>
<script language="javascript" src="script/prototype_1_6.js" type=""></script>
<script language="JavaScript"  src="script/builder.js"   type="text/javascript"></script>
<script language="JavaScript" src="script/grupo-util.js" type="text/javascript"></script>

<%          BeanUsuario autenticado = Apoio.getUsuario(request);
            boolean temacesso = (autenticado != null && autenticado.getAcesso("relcoleta") > 0);
            boolean temacessofiliais = (autenticado != null && autenticado.getAcesso("reloutrasfiliais") > 0);
            boolean temacessofiliaisDestino = (autenticado != null && autenticado.getAcesso("coletaoutrafilial") > 0);
            BeanConfiguracao cfg = new BeanConfiguracao();
            cfg.setConexao(Apoio.getUsuario(request).getConexao());
            cfg.CarregaConfig();
            boolean isFranquia = (cfg != null && cfg.getMatrizFilialFranquia().equals("f"));
            //testando se a sessao é válida e se o usuário tem acesso
            if (!temacesso) {
                response.sendError(response.SC_FORBIDDEN);
            }
            //fim da MSA

            String acao = (temacesso && request.getParameter("acao") != null ? request.getParameter("acao") : "");

            //exportacao da Cartafrete para arquivo .pdf
            if (acao.equals("exportar")) {
                SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");
                Date dtinicial = formatador.parse(request.getParameter("dtinicial"));
                Date dtfinal = formatador.parse(request.getParameter("dtfinal"));
                String mes = request.getParameter("mes");
                String ano = request.getParameter("ano");
                String modelo = request.getParameter("modelo");
                String motoristaAjudante = "";
                String regraCtrc = "";
                String situacao = "";
                String remetente = "";
                String destinatario = "";
                String consignatario = "";
                String programada = "" ;
                String idServico = "" ;
                String baixada = request.getParameter("baixado");
                StringBuilder filtros = new StringBuilder();
                String tipoData = request.getParameter("tipodata");
                String idFilialDestino = request.getParameter("idfilialDest");
                
                String veiculo = (!request.getParameter("idveiculo").equals("0") ? " and veiculo_id=" + request.getParameter("idveiculo") : "");
                if (modelo.equals("1") || modelo.equals("5") || modelo.equals("6")||modelo.equals("7")||modelo.equals("11")||modelo.equals("12")) { //verificando se vai filtrar o motorista ou o ajudante.
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and idmotorista=" + request.getParameter("idmotorista") : "");
                }else if (modelo.equals("4")||modelo.equals("17")) {
                    idServico = (!request.getParameter("type_service_id").equals("0") ? request.getParameter("type_service_id") : "");
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and vrc.motorista_id=" + request.getParameter("idmotorista") : "");
                    veiculo = (!request.getParameter("idveiculo").equals("0") ? " and vrc.veiculo_id=" + request.getParameter("idveiculo") : "");
                }else if(modelo.equals("9")){
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and pc.motorista_id=" + request.getParameter("idmotorista") : "");
                    veiculo = (!request.getParameter("idveiculo").equals("0") ? " and c.veiculo_id=" + request.getParameter("idveiculo") : "");
                }
                else if (modelo.equals("10")){
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and pc.motorista_id=" + request.getParameter("idmotorista") : "");                    
                    veiculo = (!request.getParameter("idveiculo").equals("0") ? " and pc.veiculo_id=" + request.getParameter("idveiculo") : "");
                    filtros.append(request.getParameter("idmotorista").equals("0")?"Todos os motoristas":"Apenas o motorista: "+request.getParameter("motor_nome")).append(". ");
                    filtros.append(request.getParameter("idveiculo").equals("0")?"Todos os veículos":"Apenas o veículo: "+request.getParameter("placa")).append(". ");
                }else if(modelo.equals("15")){
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and pc.motorista_id=" + request.getParameter("idmotorista") : "");
                    veiculo = (!request.getParameter("idveiculo").equals("0") ? " and pc.veiculo_id=" + request.getParameter("idveiculo") : "");
                }if(modelo.equals("3")){
                    veiculo = (!request.getParameter("idveiculo").equals("0") ? " and vrc.veiculo_id=" + request.getParameter("idveiculo") : "");
                }
                else if(modelo.equals("18") || modelo.equals("11")){
                    motoristaAjudante=(!request.getParameter("idmotorista").equals("0") ? " and idmotorista=" + request.getParameter("idmotorista") : "");
                }//else {
                  //  motoristaAjudante = (!request.getParameter("idajudante").equals("0") ? " and idajudante=" + request.getParameter("idajudante") : "");
                //}
                situacao = request.getParameter("situacao");
                if (modelo.equals("10")){
                    if (!situacao.equals("todas")){
                        regraCtrc = "AND (CASE WHEN c.categoria IN ('co','am') THEN "
                                + " (SELECT nf2.idconhecimento FROM nota_fiscal nf2 WHERE nf2.idcoleta = c.id AND nf2.idconhecimento is not null LIMIT 1) is not null "
                                + " ELSE true END "
                                + " AND "
                                + " CASE WHEN c.categoria IN ('os','am') THEN "
                                + " (SELECT ss2.sale_id FROM sale_services ss2 WHERE ss2.coleta_id = c.id AND ss2.sale_id is not null LIMIT 1) is not null "
                                + " ELSE true END) ";
                        if (situacao.equals("true")){
                            regraCtrc += " = true ";
                        }else if (situacao.equals("false")){
                            regraCtrc += " = false ";
                        }
                    }
                }else if (modelo.equals("11")){
                    if (!situacao.equals("todas")){
                        regraCtrc = "AND (CASE WHEN vc.categoria IN ('co','am') THEN "
                                + " (SELECT nf2.idconhecimento FROM nota_fiscal nf2 WHERE nf2.idcoleta = vc.idcoleta AND nf2.idconhecimento is not null LIMIT 1) is not null "
                                + " ELSE true END "
                                + " AND "
                                + " CASE WHEN vc.categoria IN ('os','am') THEN "
                                + " (SELECT ss2.sale_id FROM sale_services ss2 WHERE ss2.coleta_id = vc.idcoleta AND ss2.sale_id is not null LIMIT 1) is not null "
                                + " ELSE true END) ";
                        if (situacao.equals("true")){
                            regraCtrc += " = true ";
                        }else if (situacao.equals("false")){
                            regraCtrc += " = false ";
                        }
                    }
                }else{
                    if (situacao.equals("true")){
                        regraCtrc = " AND finalizada  ";
                    }else if (situacao.equals("false")){
                        regraCtrc = " AND (NOT finalizada) ";
                    }
                }                
               if(modelo.equals("12")){
                   remetente = (!request.getParameter("idremetente").equals("0")?"and idremetente"+request.getParameter("apenasRemetente")+request.getParameter("idremetente"):"");
                   destinatario = (!request.getParameter("iddestinatario").equals("0") ? " and destinatario_id"+ request.getParameter("apenasDestinatario")  + request.getParameter("iddestinatario") : "");
               }
               else if(modelo.equals("10")){
                  remetente  = (!request.getParameter("idremetente").equals("0") ? " and rem.idcliente"+request.getParameter("apenasRemetente") + request.getParameter("idremetente") : "");
                  destinatario = (!request.getParameter("iddestinatario").equals("0") ? " and des.idcliente "+ request.getParameter("apenasDestinatario")  + request.getParameter("iddestinatario") : "");
               }else if(modelo.equals("9")){
                    remetente  = (!request.getParameter("idremetente").equals("0") ? " and rem.idcliente "+request.getParameter("apenasRemetente") + request.getParameter("idremetente") : "");
                    destinatario = (!request.getParameter("iddestinatario").equals("0") ? " and pc.destinatario_id"+ request.getParameter("apenasDestinatario")  + request.getParameter("iddestinatario") : "");
               }else if(modelo.equals("14")){
                  remetente = (!request.getParameter("idremetente").equals("0")?" and idremetente"+request.getParameter("apenasRemetente")+ request.getParameter("idremetente"):"");
                  destinatario = (!request.getParameter("iddestinatario").equals("0")?" and iddestinatario"+ request.getParameter("apenasDestinatario") + request.getParameter("iddestinatario"):"");
                }else if(modelo.equals("11")||modelo.equals("7")||modelo.equals("4")||modelo.equals("6")||modelo.equals("16")||modelo.equals("17")){
//                  motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and idmotorista=" + request.getParameter("idmotorista") : "");
                  remetente = (!request.getParameter("idremetente").equals("0")?" and idremetente"+request.getParameter("apenasRemetente")+ request.getParameter("idremetente"):"");
                  destinatario = (!request.getParameter("iddestinatario").equals("0")?" and iddestinatario"+ request.getParameter("apenasDestinatario") + request.getParameter("iddestinatario"):"");
                }else if(modelo.equals("15")){
                    remetente = (!request.getParameter("idremetente").equals("0")?" and co.cliente_id"+request.getParameter("apenasRemetente")+ request.getParameter("idremetente"):"");
                }else{
                    remetente  = (!request.getParameter("idremetente").equals("0") ? " and c.cliente_id"+request.getParameter("apenasRemetente") + request.getParameter("idremetente") : "");
                    destinatario = (!request.getParameter("iddestinatario").equals("0") ? " and iddestinatario"+ request.getParameter("apenasDestinatario")  + request.getParameter("iddestinatario") : "");
                }
                //novo filtro filtro para consignatario
                if (modelo.equals("4") || modelo.equals("6")||modelo.equals("16")||modelo.equals("17")){
                    consignatario = (!request.getParameter("idconsignatario").equals("0")?" and cliente_consignatario_id"+ request.getParameter("apenasConsignatario") + request.getParameter("idconsignatario"):"");
                }else if(modelo.equals("14")||modelo.equals("12")||modelo.equals("11")||modelo.equals("10")||modelo.equals("9")||modelo.equals("7")||modelo.equals("6")){
                    consignatario = (!request.getParameter("idconsignatario").equals("0")?" and cc.idcliente"+ request.getParameter("apenasConsignatario") + request.getParameter("idconsignatario"):"");
                }
                StringBuilder condicaoBaixado = new StringBuilder();
                if (modelo.equals("10")){
                    condicaoBaixado.append("");
                    if (baixada.equals("true")){
                        condicaoBaixado.append(" and pc.coleta_em is not null ");
                    }else if (baixada.equals("false")){
                        condicaoBaixado.append(" and pc.coleta_em is null ");
                    }else if (baixada.equals("false2")){
                        condicaoBaixado.append(" and pc.coleta_em is null and c.id NOT IN (SELECT coleta_id FROM romaneio_ctrc WHERE coleta_id is not null) ");
                    }
                }else{
                    condicaoBaixado.append("");
                    if (baixada.equals("true")){
                        condicaoBaixado.append(" and baixada ");
                    }else if (baixada.equals("false")){
                        condicaoBaixado.append(" and NOT baixada ");
                    }else if (baixada.equals("false2")){
                        condicaoBaixado.append(" and NOT baixada and idcoleta NOT IN (SELECT coleta_id FROM romaneio_ctrc WHERE coleta_id is not null) ");
                    }
                }
                //filtros escolhidos
                filtros.append("Usuario: ").append(autenticado.getNome()).append(".\n");
                filtros.append("Realizadas entre " + request.getParameter("dtinicial") + " e " + request.getParameter("dtfinal")).append(".");
                if(!baixada.equals("")){
                    filtros.append(baixada.equals("true")?"Apenas as baixadas":"Apenas as em aberto").append(".");
                }

                //Tipo Data
                if (modelo.equals("1") || modelo.equals("2") || modelo.equals("6")){               
                    tipoData = (tipoData.equals("coleta_em") ? "dtcoleta" : tipoData);
                }else if (modelo.equals("3") || modelo.equals("4") || modelo.equals("8") || modelo.equals("11")||modelo.equals("12")||modelo.equals("14")||modelo.equals("16")||modelo.equals("17")){
                    tipoData = (tipoData.equals("solicitada_em")?"dtsolicitacao" : (tipoData.equals("entrega_em")?"entrega_em":"dtcoleta"));
                 
                }else if (modelo.equals("7") ){
                   tipoData = (tipoData.equals("entrega_em")? "vc.entrega_em" : (tipoData.equals("solicitada_em")? "dtsolicitacao" : tipoData));
                }else if(modelo.equals("13")){
                    String dti = request.getParameter("dtinicial");
                    String dtf = request.getParameter("dtfinal");
                                          
                }else if(modelo.equals("15")){//relatorio 15 tem como parametro dia e mês
                     mes = request.getParameter("mes");
                     ano = request.getParameter("ano");
                  
                }else if(modelo.equals("18")){
                      tipoData = (tipoData.equals("coleta_em") ? "dtcoleta" : tipoData);
                }
                                
                if (modelo.equals("1") || modelo.equals("2") || modelo.equals("6") || modelo.equals("18")){
                     programada = (request.getParameter("programada").equals("") ? "" : request.getParameter("programada").equals("true")? " AND ((coleta_programada_em || ' ' || coleta_programada_as) :: TIMESTAMP) >= ((dtcoleta || ' ' || coleta_as) :: TIMESTAMP) " : " AND ((coleta_programada_em || ' ' || coleta_programada_as) :: TIMESTAMP) < ((dtcoleta || ' ' || coleta_as) :: TIMESTAMP) ");
                }else if (modelo.equals("9") || modelo.equals("10") || modelo.equals("13") || modelo.equals("15")){
                     programada = (request.getParameter("programada").equals("") ? "" : request.getParameter("programada").equals("true")? " AND ((coleta_programada_em || ' ' || coleta_programada_as) :: TIMESTAMP) >= ((coleta_em || ' ' || coleta_as) :: TIMESTAMP) " : " AND ((coleta_programada_em || ' ' || coleta_programada_as) :: TIMESTAMP) < ((coleta_em || ' ' || coleta_as) :: TIMESTAMP) ");     
                }else if (modelo.equals("3") || modelo.equals("4") || modelo.equals("8") || modelo.equals("12") || modelo.equals("14")||modelo.equals("17")){
                     programada = (request.getParameter("programada").equals("") ? "" : request.getParameter("programada").equals("true")? " AND ((coleta_programada_em || ' ' || coleta_programada_as) :: TIMESTAMP) >= ((dtcoleta || ' ' || coleta_as) :: TIMESTAMP) " : " AND ((coleta_programada_em || ' ' || coleta_programada_as) :: TIMESTAMP) < ((dtcoleta || ' ' || coleta_as) :: TIMESTAMP) ");
                }else if (modelo.equals("7") || modelo.equals("11")){
                     programada = (request.getParameter("programada").equals("") ? "" : request.getParameter("programada").equals("true")? " AND ((prog_data || ' ' || prog_hora) :: TIMESTAMP) >= ((dtcoleta || ' ' || vc.coleta_as) :: TIMESTAMP) " : " AND ((prog_data || ' ' || prog_hora) :: TIMESTAMP) < ((dtcoleta || ' ' || vc.coleta_as) :: TIMESTAMP) ");
                }
                
                if(modelo.equals("2") || modelo.equals("8")){
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and motorista_id=" + request.getParameter("idmotorista") : "");
                }
                
                if(modelo.equals("3")){
                    motoristaAjudante = (!request.getParameter("idmotorista").equals("0") ? " and vrc.motorista_id=" + request.getParameter("idmotorista") : "");
                }
                
                
                java.util.Map param = new java.util.HashMap(25);
                //Apenas o modelo personalizado
                if (modelo.equals("P")) {
                   param.put("TIPO_DATA", tipoData);
                   param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
                   param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
                   param.put("IDFILIAL", request.getParameter("idfilial"));
                   param.put("IDMOTORISTA", motoristaAjudante);
                   param.put("IDAJUDANTE", request.getParameter("idajudante"));
                   param.put("IDVEICULO", request.getParameter("idveiculo"));
                   param.put("IDREMETENTE", request.getParameter("idremetente"));
                   param.put("OPERADOR_REMETENTE", request.getParameter("apenasRemetente"));
                   param.put("IDDESTINATARIO", request.getParameter("iddestinatario"));
                   param.put("OPERADOR_DESTINATARIO", request.getParameter("apenasDestinatario"));
                   param.put("IDCONSIGNATARIO", request.getParameter("idconsignatario"));
                   param.put("OPERADOR_CONSIGNATARIO", request.getParameter("apenasConsignatario"));
                   param.put("CTRC", request.getParameter("situacao"));
                   param.put("BAIXADA", request.getParameter("baixado"));
                   param.put("CANCELADA", request.getParameter("cancelada"));
                   param.put("PROGRAMADA", request.getParameter("programada"));
                   param.put("BAIRRO", request.getParameter("bairroOrigem"));
                   param.put("BOOKING", request.getParameter("booking"));
                   param.put("GRUPOS", request.getParameter("grupos"));
                   param.put("OPCOES", filtros.toString());
                   param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                   param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));

                   request.setAttribute("map", param);
                   request.setAttribute("rel", request.getParameter("personalizado"));
                } else {
                    String booking = "";// (request.getParameter("booking").equals("") ? "" : " and numero_booking = " + Apoio.SqlFix(request.getParameter("booking")) + " ");
                    
                        param.put("DATA_INI", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtinicial) + "'");
                        param.put("DATA_FIM", "'" + new SimpleDateFormat("MM/dd/yyyy").format(dtfinal) + "'");
                        param.put("TIPO_DATA", tipoData);
                        param.put("MES", mes);
                        param.put("ANO", ano); 
                        param.put("IDCONSIGNATARIO", consignatario);
                        param.put("IDMOTORISTA", motoristaAjudante);
                        param.put("IDVEICULO", veiculo);
                        param.put("IDREMETENTE", remetente);
                        param.put("IDDESTINATARIO", destinatario);
                        param.put("PROGRAMADA", programada);
                        param.put("BAIXADA", condicaoBaixado.toString());
                        param.put("IDSERVICO", idServico);

                        if (modelo.equals("1") || modelo.equals("2") || modelo.equals("3") || modelo.equals("6") || modelo.equals("7") || modelo.equals("11") || modelo.equals("14")) {
                            param.put("CANCELADA", (Boolean.parseBoolean(request.getParameter("cancelada")) ? " AND is_cancelada " : " AND NOT is_cancelada "));
                            param.put("CTRC", regraCtrc);
                        }
                        if(modelo.equals("8")){
                            param.put("CANCELADA", (Boolean.parseBoolean(request.getParameter("cancelada")) ? " AND is_cancelada " : " "));
                        }
                        if (modelo.equals("4") || modelo.equals("17")) {
                            param.put("CANCELADA", (Boolean.parseBoolean(request.getParameter("cancelada")) ? " AND vrc.is_cancelada " : "AND NOT vrc.is_cancelada"));
                            param.put("CTRC", regraCtrc);
                        }
                        if (modelo.equals("10")) {
                            param.put("CANCELADA", (Boolean.parseBoolean(request.getParameter("cancelada")) ? " AND c.is_cancelada " : "AND NOT c.is_cancelada"));
                            param.put("CTRC", regraCtrc);
                        }
                        if (modelo.equals("11")) {
                            param.put("CANCELADA", (Boolean.parseBoolean(request.getParameter("cancelada")) ? " AND vc.is_cancelada " : "AND NOT vc.is_cancelada"));
                            param.put("CTRC", regraCtrc);
                        }
                        if (modelo.equals("5")) {
                            param.put("IDFILIAL", String.valueOf(Apoio.getUsuario(request).getFilial().getIdfilial()));
                        } else if (modelo.equals("9")){
                            param.put("IDFILIAL", request.getParameter("idfilial"));
                        } else if (modelo.equals("10")) {
                            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and filial_id=" + request.getParameter("idfilial") : ""));
                        } else if (modelo.equals("14")) {
                            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and idfilial=" + request.getParameter("idfilial") : ""));
                        } else if (modelo.equals("17")) {
                            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and fi.idfilial=" + request.getParameter("idfilial") : ""));
                        } else {
                            param.put("IDFILIAL", (!request.getParameter("idfilial").equals("0") ? " and idfilial=" + request.getParameter("idfilial") : ""));
                        }
                        String grupos = "";
                        if (modelo.equals("4") || modelo.equals("17")) {
                            grupos = (request.getParameter("grupos").equals("") ? "" : " and vrc.grupo_id IN(" + request.getParameter("grupos") + ")");
                        } else {
                            grupos = (request.getParameter("grupos").equals("") ? "" : " and grupo_id IN(" + request.getParameter("grupos") + ")");
                        }

                        if (modelo.equals("7")) {
                            if (!request.getParameter("numero_fatura").trim().equals("")) {
                                param.put("FATURA", " AND idcoleta IN (SELECT ct2.coleta_id FROM ctrcs ct2 JOIN parcels p2 ON (ct2.sale_id = p2.sale_id) JOIN faturas f2 ON (p2.fatura_cobranca_id = f2.id) WHERE f2.numero = '" + request.getParameter("numero_fatura") + "' AND f2.ano_fatura = '" + request.getParameter("ano_fatura") + "')");
                                param.put("VIEW_FATURA", (request.getParameter("numero_fatura").trim().equals("") ? "" : request.getParameter("numero_fatura") + "/" + request.getParameter("ano_fatura")));
                            }                          
                            
                           param.put("IDFILIAL", request.getParameter("idfilial"));
                          
                        }

                        String bairroOrigem = request.getParameter("bairroOrigem");
                        if (modelo.equals("10")) {
                            param.put("BAIRRO", (bairroOrigem.equals("") ? "" : " AND UPPER(CASE WHEN c.cliente_id is null THEN c.bairro_coleta ELSE rem.bairro END) = UPPER('" + bairroOrigem + "')"));
                        }
                        //NOVO PADRÃO DE FILTROS
                        if(modelo.equals("1") || modelo.equals("2") || modelo.equals("3") || modelo.equals("18")){
                            param.put("IDAJUDANTE", (request.getParameter("idajudante") != null ? request.getParameter("idajudante") : "0"));
                        }
                        
                        if(modelo.equals("2")){
                            param.put("IDVEICULO", (request.getParameter("idveiculo") != null ? request.getParameter("idveiculo") : "0"));
                        }
                        
                        if(modelo.equals("11")){
                            param.put("BAIXADO", (request.getParameter("baixado") != null ? request.getParameter("baixado") : ""));
                        }                       
                        
                        if(modelo.equals("18")){
                            param.put("CANCELADA", request.getParameter("cancelada"));
                        }
                         
                        booking = request.getParameter("booking");
                        if (!idFilialDestino.equals("") && !idFilialDestino.equals("0")) {
                            param.put("FILIAL_DESTINO", " and STRING_TO_ARRAY(filiais_destino,',')::INTEGER[] @> ARRAY["+idFilialDestino+"] ");
                        }
                        
                        param.put("GRUPOS", grupos);                       
                        param.put("BOOKING", booking);
                        param.put("VIEW_BOOKING", (request.getParameter("booking").trim().equals("") ? "" : request.getParameter("booking")));
                        param.put("OPCOES", filtros.toString());
                        param.put("USUARIO",Apoio.getUsuario(request).getNome());     
                        param.put("CLIENTE_LICENCA",(Apoio.getRazaoSocialContratante(this.getServletConfig()) != null ? Apoio.getRazaoSocialContratante(this.getServletConfig()) : "LICENÇA NAO AUTORIZADA LIGUE PARA 81 2125-3752 PARA REGULARIZAR A SITUACAO"));
                        
                        request.setAttribute("map", param);
                        request.setAttribute("rel", "relcoletamod" + modelo);
                        
                        
                        /*modelo 14 precisa de usar o calendario 
                        para resolver o bug do mês de fevereiro*/
                        GregorianCalendar calendar = new GregorianCalendar();
                        calendar.set(Integer.parseInt(ano), Integer.parseInt(mes) - 1, 1);
                        int qtdDias = calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
                        Apoio.funcMes(qtdDias);

                }
                
    RequestDispatcher dispacher = request.getRequestDispatcher("./ExporterReports?impressao=" + request.getParameter("impressao"));
    dispacher.forward(request, response);
            }else if (acao.equals("iniciar")){
                request.setAttribute("rotinaRelatorio", SistemaTipoRelatorio.WEBTRANS_COLETA_RELATORIO.ordinal());
            }
%>


<script language="javascript" type="text/javascript">

    function modelos(modelo){
        $("trData").style.display = "";
        $("trFilial").style.display = "";
        $("trAjudante").style.display = "";
        $("trVeiculo").style.display = "";
        $("trcliente").style.display = "none";
        $("trconsignatario").style.display = "none";
        $("trDestinatario").style.display = "none";
        $("trSituacao").style.display = "none";
        $("trCancelada").style.display = "none";
        $("trBooking").style.display = "";
        $("trMesAno").style.display = "none";
        $("trFatura").style.display = "none";
        $("trBairro").style.display = "none";
        

        $("modelo1").checked = false;
        $("modelo2").checked = false;
        $("modelo3").checked = false;
        $("modelo4").checked = false;
        $("modelo5").checked = false;
        $("modelo6").checked = false;
        $("modelo7").checked = false;
        $("modelo8").checked = false;
        $("modelo9").checked = false;
        $("modelo10").checked = false;
        $("modelo11").checked = false;
        $("modelo12").checked = false;
        $("modelo13").checked = false;
        $("modelo14").checked = false;
        $("modelo15").checked = false;
        $("modelo16").checked = false;
        $("modelo17").checked = false;
        $("modelo18").checked = false;
        $("modeloP").checked = false;
        
        $("modelo"+modelo).checked = true;

        if ($("modelo1").checked){
            $("trCancelada").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modelo2").checked){
            $("trCancelada").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "none";
            $("trBooking").style.display = "";
        }
        if ($("modelo3").checked){
            $("trCancelada").style.display = "";
            $("trProgramada").style.display = "";
            $("trSituacao").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }

        if ($("modelo4").checked){
            $("trCancelada").style.display = "";
            $("trcliente").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trSituacao").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }

        if ($("modelo5").checked){
            $("trCancelada").style.display = "none";
            $("trMotorista").style.display = "";
            $("trProgramada").style.display = "none";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }

        if ($("modelo6").checked){
            $("trCancelada").style.display = "";
            $("trcliente").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trFilial").style.display = "none";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";  
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modelo7").checked){
            $("trCancelada").style.display = "";
            $("trcliente").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trFilial").style.display = "";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("trBooking").style.display = "";
            $("trProgramada").style.display = "";
            $("trFatura").style.display = "";
            $("trMotorista").style.display = "";
        }
        if ($("modelo8").checked){
            $("trCancelada").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modelo9").checked){
            $("trCancelada").style.display = "none";
            $("trcliente").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trFilial").style.display = "";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modelo10").checked){
            $("trCancelada").style.display = "";
            $("trSituacao").style.display = "";
            $("trcliente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trconsignatario").style.display = "";
            $("trProgramada").style.display = "";
            $("trBairro").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modelo11").checked){
            $("trCancelada").style.display = "";
            $("trSituacao").style.display = "";
            $("trconsignatario").style.display = "";
            $("trcliente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trFilial").style.display = "";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";      
            $("trBooking").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
        }
        if ($("modelo12").checked){
            $("trconsignatario").style.display = "";
            $("trcliente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trFilial").style.display = "";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("trBooking").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
        }
        if($("modelo13").checked){
            $("trFilial").style.display = "none";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("trcliente").style.display = "none";
            $("trDestinatario").style.display = "none";
            $("trSituacao").style.display = "none";
            $("trCancelada").style.display = "none";
            $("trBooking").style.display = "";
            $("trMotorista").style.display = "none";
            $("dv_titulo_filtros").style.display = "none";
            $("trGroupos").style.display = "none";
            $("trProgramada").style.display = "";
        }
        if($("modelo14").checked){
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("trSituacao").style.display = "none";
            $("trCancelada").style.display = "";
            $("trBooking").style.display = "";
            $("trMotorista").style.display = "none";
            $("dv_titulo_filtros").style.display = "none";
            $("trGroupos").style.display = "none";
            $("trcliente").style.display = "";
            $("trDestinatario").style.display = "";
            $("trconsignatario").style.display = "";
            $("trProgramada").style.display = "";
        }
        if($("modelo15").checked){
            $("trFilial").style.display = "none";
            $("trAjudante").style.display = "none";
            $("trMotorista").style.display = "";
            $("trVeiculo").style.display = "";
            $("trProgramada").style.display = "";
            $("trData").style.display = "none";
            $("trMesAno").style.display = "";
            $("trGroupos").style.display = "none";
            $("trcliente").style.display = "";
            $("trBooking").style.display = "";
        }
        if($("modelo16").checked){
            $("trcliente").style.display = "";
            $("trData").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trFilial").style.display = "none";
            $("trAjudante").style.display = "none";
            $("trVeiculo").style.display = "none";
            $("trSituacao").style.display = "none";
            $("trCancelada").style.display = "none";
            $("trBooking").style.display = "";
            $("trMotorista").style.display = "none";
            $("dv_titulo_filtros").style.display = "none";
            $("trGroupos").style.display = "none";
            $("trProgramada").style.display = "none";
        }if($("modelo17").checked){
            $("trCancelada").style.display = "";
            $("trcliente").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trSituacao").style.display = "";
            $("trProgramada").style.display = "";
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modelo18").checked){
            $("trCancelada").style.display = "";
            $("trProgramada").style.display = "";            
            $("trMotorista").style.display = "";
            $("trBooking").style.display = "";
        }
        if ($("modeloP").checked){
            $("trData").style.display = "";
            $("trFilial").style.display = "";
            $("trAjudante").style.display = "";
            $("trVeiculo").style.display = "";
            $("trcliente").style.display = "";
            $("trconsignatario").style.display = "";
            $("trDestinatario").style.display = "";
            $("trSituacao").style.display = "";
            $("trCancelada").style.display = "";
            $("trBooking").style.display = "";
            $("trMesAno").style.display = "none";
            $("trFatura").style.display = "none";
            $("trBairro").style.display = "";
            $("trMotorista").style.display = "";
        }


    }

    function localizamotorista(){
        post_cad = window.open('./localiza?acao=consultar&idlista=10','Motorista',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    
    function localizaServico(){
        post_cad = window.open('./localiza?acao=consultar&idlista=36','Serviços',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaveiculo(){
        post_cad = window.open('./localiza?acao=consultar&idlista=7','Veiculo',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizaajudante(){
        post_cad = window.open('./localiza?acao=consultar&idlista=25','Ajudante',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function localizafilial(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','Filial',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }
    
    function localizafilialDest(){
        post_cad = window.open('./localiza?acao=consultar&idlista=8','FilialDestino',
        'top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
    }

    function popRel(){
        var modelo;
        var grupos = getGrupos();
        if (! validaData($("dtinicial").value) || ! validaData($("dtfinal").value))
            alert ("Informe o intervalo de datas corretamente.");
        else if (($("modelo5").checked) && ($("idmotorista").value=='0'))
            alert ("Informe o motorista corretamente.");
        
        else{
            if (getObj("modelo1").checked)
                modelo = '1';
            else if (getObj("modelo2").checked)
                modelo = '2';
            else if (getObj("modelo3").checked)
                modelo = '3';
            else if (getObj("modelo4").checked)
                modelo = '4';
            else if ($("modelo5").checked)
                modelo = '5';
            else if ($("modelo6").checked)
                modelo = '6';
            else if ($("modelo7").checked)
                modelo = '7';
            else if ($("modelo8").checked)
                modelo = '8';
            else if ($("modelo9").checked)
                modelo = '9';
            else if ($("modelo10").checked)
                modelo = '10';  
            else if ($("modelo11").checked)
                modelo = '11';
            else if ($("modelo12").checked)
                modelo = '12';
            else if($("modelo13").checked)
                modelo = "13";
            else if($("modelo14").checked)
                modelo = "14";
             else if($("modelo15").checked)
                modelo = "15";
            else if($("modelo16").checked)
                modelo = "16"
            else if($("modelo17").checked)
                modelo = "17";
            else if($("modelo18").checked)
                modelo = "18";
            else if($("modeloP").checked)
                if($("personalizado").value == ""){
                    alert("Selecione um modelo personalizado primeiro ");
                    return false;
                }else{
                    modelo = "P";
                }
            var impressao;
            if ($("pdf").checked)
                impressao = "1";
      else if ($("excel").checked)
        impressao = "2";
      else
        impressao = "3";
    
            launchPDF('./relcoleta?acao=exportar&modelo='+modelo+
                '&impressao='+impressao+'&'+
                    concatFieldValue("dtinicial,dtfinal,idmotorista,motor_nome,idajudante,idveiculo,booking,vei_placa,idremetente,idconsignatario,idfilialDest,iddestinatario,tipodata,apenasDestinatario,apenasRemetente,apenasConsignatario,numero_fatura,ano_fatura,bairroOrigem,personalizado,placa,idfilialDest")+
                '&idfilial='+$("idfilialOrigem").value+
                '&grupos='+grupos+'&situacao='+$('situacao').value+'&baixado='+$('baixado').value+'&programada='+$('programada').value+'&mes='+mes.value+'&ano='+ano.value+
                '&cancelada='+$('cancelada').checked+"&type_service_id="+$("type_service_id").value);
        }
    }

    function localizaremet(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=3','Remetente_',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }
  
    function localizaconsignatario(){
        post_cad = window.open('./localiza?categoria=loc_cliente&acao=consultar&idlista=5','Consignatario_',
        'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
    }

    function aoClicarNoLocaliza(idjanela)
    {   
        if(idjanela == "Consignatario_"){
            getObj("consig").value = getObj("con_rzs").value;
            getObj("idconsignatario").value = getObj("idconsignatario").value;
        }else if (idjanela == "Veiculo" ){
            $("placa").value = $("vei_placa").value;
        }else if (idjanela == "Motorista"){
             $("placa").value = $("vei_placa").value;
        }else if (idjanela == "Remetente_"){
            getObj("remet").value = getObj("rem_rzs").value;
            getObj("idremetente").value = getObj("idremetente").value;
        }else if (idjanela == "Grupo"){
            addGrupo(getObj('grupo_id').value,'node_grupos', getObj('grupo').value)
        }else if (idjanela === "FilialDestino") {
            $("idfilialDest").value = $("idfilial").value;
            $("fi_dest_abreviatura").value = $("fi_abreviatura").value;
        }else if (idjanela === "Filial") {
            $("idfilialOrigem").value = $("idfilial").value;
            $("fi_abreviatura_origem").value = $("fi_abreviatura").value;
        }
    }
    
    function limparMotorista(){
        getObj('idmotorista').value = "0";
        getObj('motor_nome').value = "";
//        getObj('idveiculo').value = "0";
//        getObj('vei_placa').value = "";
    }
    
    function limparServico(){
        getObj('type_service_id').value = "0";
        getObj('type_service_descricao').value = "";
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

        <title>Webtrans - Relat&oacute;rio de Coletas</title>
        <link href="estilo.css" rel="stylesheet" type="text/css">
    </head>

    <body onLoad="applyFormatter();AlternarAbasGenerico('tdAbaPrincipal','tabPrincipal');aoCarregarTabReport(<c:out value="${rotinaRelatorio}"/>,'<c:out value="${param.modulo}"/>');modelos(1)">
        <div align="center"><img src="img/banner.gif"  alt="banner"> <br>
            <input type="hidden" name="idfilial" id="idfilial" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="idfilialOrigem" id="idfilialOrigem" value="<%=(temacessofiliais ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="idfilialDest" id="idfilialDest" value="<%=(((!isFranquia && temacessofiliais) || (isFranquia && temacessofiliaisDestino)) ? 0 : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="fi_abreviatura" id="fi_abreviatura" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getIdfilial())%>">
            <input type="hidden" name="con_rzs" id="con_rzs" value="">
            <input type="hidden" name="idconsignatario" id="idconsignatario" value="0">
            <input type="hidden" name="rem_rzs" id="rem_rzs" value="">
            <input type="hidden" name="idmotorista" id="idmotorista" value="0">
            <input type="hidden" name="idajudante" id="idajudante" value="0">
            <input type="hidden" name="idveiculo" id="idveiculo" value="0">
            <input type="hidden" name="idremetente" id="idremetente" value="0">
            <input type="hidden" name="grupo_id" id="grupo_id" value="0">
            <input type="hidden" name="grupo" id="grupo" value="">
            <input type="hidden" name="iddestinatario" id="iddestinatario" value="0">
            <input type="hidden" name="vei_placa" id="vei_placa" value="0">
            <input type="hidden" name="type_service_id" id="type_service_id" value="0">
        </div>
        <table width="90%" height="28" align="center" class="bordaFina" >
            <tr>
                <td height="22"><b>Relat&oacute;rio de Coletas</b></td>
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
                <td width="50%" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo1" id="modelo1" value="1" checked onClick="javascript:modelos(1);">
                        Modelo 1 
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    coletas por motorista (Anal&iacute;tico).
                </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo2" id="modelo2" value="2" onClick="javascript:modelos(2);">
                        Modelo 2
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    coletas por ajudante (Sint&eacute;tico).
                </td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo3" id="modelo3" value="3" onClick="javascript:modelos(3);">
                        Modelo 3
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    coletas por ve&iacute;culo.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo4" id="modelo4" value="4" onClick="javascript:modelos(4);">
                        Modelo 4
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de
                    coletas por cliente (Remetente).</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo5" id="modelo5" value="5" onClick="javascript:modelos(5);">
                        Modelo 5
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Recibo de coletas realizadas.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo6" id="modelo6" value="6" onClick="javascript:modelos(6);">
                        Modelo 6
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Coletas em aberto por motorista</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo7" id="modelo7" value="7" onClick="javascript:modelos(7);">
                        Modelo 7
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Controle de carregamento de container.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo8" id="modelo8" value="8" onClick="javascript:modelos(8);">
                        Modelo 8
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Relat&oacute;rio de coletas por tipo de frota.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo9" id="modelo9" value="9" onClick="javascript:modelos(9);">
                        Modelo 9
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Relat&oacute;rio de coletas urbanas entregues.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo10" id="modelo10" value="10" onClick="javascript:modelos(10);">
                        Modelo 10
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Relat&oacute;rio de listagem de coletas.</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo11" id="modelo11" value="11" onClick="javascript:modelos(11);">
                        Modelo 11
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o das coletas com Container.</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo12" id="modelo12" value="12" onClick="javascript:modelos(12);">
                        Modelo 12
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Averba&ccedil;&atilde;o das coletas.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo13" id="modelo13" value="13"  onClick="javascript:modelos(13);">
                        Modelo 13 
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de coletas por &aacute;rea de destino.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo14" id="modelo14" value="14"  onClick="javascript:modelos(14);">
                        Modelo 14 
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de coletas.</td>
            </tr>
            <tr>
                <td width="99" height="24" class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo15" id="modelo15" value="15"  onClick="javascript:modelos(15);">
                        Modelo 15 
                    </div>
                </td>
                <td width="378" colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de coletas por dias.</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo16" id="modelo16" value="16"  onClick="javascript:modelos(16);">
                        Modelo 16 
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Rela&ccedil;&atilde;o de OS(s).</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo17" id="modelo17" value="17"  onClick="javascript:modelos(17);">
                        Modelo 17
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Relação de Coletas com Custos</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modelo18" id="modelo18" value="18"  onClick="javascript:modelos(18);">
                        Modelo 18
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">Relação de Coletas Realizadas</td>
            </tr>
            <tr>
                <td class="TextoCampos"> 
                    <div align="left">
                        <input type="radio" name="modeloP" id="modeloP" value="P"  onClick="javascript:modelos('P');">
                        Personalizado
                    </div>
                </td>
                <td colspan="2" class="CelulaZebra2">
                        <select name="personalizado" id="personalizado" class="inputtexto">
                            <option value="">Escolha o modelo personalizado</option>
                            <%for (String rel : Apoio.listRelatorioColeta(request)) {%>
                                <option value="relatorio_coleta_personalizado_<%=rel%>"><%=rel.toUpperCase()%></option>
                            <%}%>
                        </select>
                </td>
            </tr>
            <tr class="tabela">
                <td colspan="3">
                    <div align="center">Crit&eacute;rio de datas</div>
                </td>
            </tr>
            <tr id="trData">
                <td class="TextoCampos">
                    <select name="tipodata" id="tipodata" class="fieldMin">
                        <option value="solicitada_em" selected>Solicitadas entre:</option>
                        <option value="coleta_em">Realizadas entre:</option>
                        <option value="entrega_em">Data de Entrega(Coleta Urbana):</option>
                    </select>
                </td>
                <td colspan="2" class="CelulaZebra2"> 
                    <strong>
                        <input name="dtinicial" type="text" id="dtinicial" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>e
                    <strong>
                        <input name="dtfinal" type="text" id="dtfinal" value="<%=Apoio.getDataAtual()%>" size="10" maxlength="10"
                               onblur="alertInvalidDate(this)" class="fieldDate" />
                    </strong>
                </td>
            </tr>
            <tr id="trMesAno" style="display: none;">
                <td  class="CelulaZebra2"> 
                       Mes/Ano:
                </td>
                <td colspan="2" class="CelulaZebra2"> <strong>
                        <select name="mes" id="mes" class="inputtexto">
                            <option value="01">Janeiro</option>
                            <option value="02">Fevereiro</option>
                            <option value="03">Março</option>
                            <option value="04">Abril</option>
                            <option value="05">Maio</option>
                            <option value="06">Junho</option>
                            <option value="07">Julho</option>
                            <option value="08">Agosto</option>
                            <option value="09">Setembro</option>
                            <option value="10">Outubro</option>
                            <option value="11">Novembro</option>
                            <option value="12">Dezembro</option>
                        </select> /
                        <select name="ano" id="ano" class="inputtexto">
                            <option value="2000">2000</option>
                            <option value="2001">2001</option>
                            <option value="2002">2002</option>
                            <option value="2003">2003</option>
                            <option value="2004">2004</option>
                            <option value="2005">2005</option>
                            <option value="2006">2006</option>
                            <option value="2007">2007</option>
                            <option value="2008">2008</option>
                            <option value="2009">2009</option>
                            <option value="2010">2010</option>
                            <option value="2011">2011</option>
                            <option value="2012" selected>2012</option>
                            <option value="2013">2013</option>
                            <option value="2014">2014</option>
                            <option value="2015">2015</option>
                            <option value="2016">2016</option>
                            <option value="2017">2017</option>
                            <option value="2018">2018</option>
                            <option value="2019">2019</option>
                            <option value="2020">2020</option>
                            <option value="2021">2021</option>
                            <option value="2022">2022</option>
                            <option value="2023">2023</option>
                            <option value="2024">2024</option>
                            <option value="2025">2025</option>
                            <option value="2026">2026</option>
                            <option value="2027">2027</option>
                            <option value="2028">2028</option>
                            <option value="2029">2029</option>
                            <option value="2030">2030</option>
                        </select>
                    </strong></td>
                    <!-- INFORMEI A DEIVID SOBRE O SELECT, ELE ME PEDIU PARA APENAS ADICIONAR MAIS 10 ANOS POIS AS TELAS DE RELATÓRIO SERÃO REFEITAS -->
            </tr>
            <tr class="tabela">
                <td height="18" colspan="3">
                    <div align="center" id="dv_titulo_filtros">Filtros</div>
                </td>
            </tr>
            <tr>
                <td colspan="3"> 
                    <table width="100%" border="0">
                        <tr id="trFilial">
                             <td width="50%" class="TextoCampos">Apenas a filial: </td>
                             <td class="CelulaZebra2" colspan="2">
                                  <strong>
                                     <input name="fi_abreviatura_origem" type="text" id="fi_abreviatura_origem" value="<%=(temacessofiliais ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="20" maxlength="60" readonly="true" class="inputReadOnly">
                                         <% if (temacessofiliais) {%>
                                              <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizafilial();">
                                              <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial" onClick="javascript:getObj('idfilialOrigem').value = 0;javascript:getObj('fi_abreviatura_origem').value = '';">
                                         <%}%>
                                  </strong>
                             </td>
                        </tr>
                        
                        <tr id="trFilialDestino">
                             <td width="50%" class="TextoCampos">Apenas a filial de destino: </td>
                             <td class="CelulaZebra2" colspan="2">
                                  <strong>
                                     <input name="fi_dest_abreviatura" type="text" id="fi_dest_abreviatura" value="<%=(((!isFranquia && temacessofiliais) || (isFranquia && temacessofiliaisDestino)) ? "" : Apoio.getUsuario(request).getFilial().getAbreviatura())%>" size="20" maxlength="60" readonly="true" class="inputReadOnly">
                                         <% if (((!isFranquia && temacessofiliais) || (isFranquia && temacessofiliaisDestino))) {%>
                                              <input name="localiza_filial" type="button" class="botoes" id="localiza_filial_destino" value="..." onClick="javascript:localizafilialDest();">
                                              <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Filial Destino" onClick="javascript:getObj('idfilialDest').value = 0;javascript:getObj('fi_dest_abreviatura').value = '';">
                                         <%}%>
                                  </strong>
                             </td>
                        </tr>
                        <tr id="trMotorista">
                             <td class="TextoCampos">Apenas o motorista:</td>
                             <td width="50%" class="CelulaZebra2" colspan="2">
                                 <strong>
                                     <input name="motor_nome" type="text" id="motor_nome" class="inputReadOnly" value="" size="30" maxlength="80" readonly="true">
                                     <input name="localiza_filial" type="button" class="botoes" id="localiza_filial" value="..." onClick="javascript:localizamotorista();aoClicarNoLocaliza();">
                                     <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onclick="javascript:limparMotorista();"/>
                                 </strong>
                             </td>
                        </tr>
                        <tr id="trServico">
                             <td class="TextoCampos">Apenas o servico:</td>
                             <td width="50%" class="CelulaZebra2" colspan="2">
                                 <strong>
                                     <input name="type_service_descricao" type="text" id="type_service_descricao" class="inputReadOnly" value="" size="30" maxlength="80" readonly="true">
                                     <input name="localiza_servico" type="button" class="botoes" id="localiza_servico" value="..." onClick="javascript:localizaServico();">
                                     <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Motorista" onclick="javascript:limparServico();"/>
                                 </strong>
                             </td>
                        </tr>
                        <tr id="trAjudante">
                            <td class="TextoCampos">Apenas o ajudante:</td>
                            <td width="50%" class="CelulaZebra2" colspan="2">
                                <strong>
                                    <input name="nome" type="text" id="nome" class="inputReadOnly" value="" size="30" maxlength="80" readonly="true">
                                    <input name="localiza_ajud" type="button" class="botoes" id="localiza_ajud" value="..." onClick="javascript:localizaajudante();">
                                    <img src="img/borracha.gif" border="0" align="absbottom" class="imagemLink" title="Limpar Ajudante" onClick="javascript:getObj('idajudante').value = '0';javascript:getObj('nome').value = '';">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trVeiculo">
                            <td class="TextoCampos">Apenas o ve&iacute;culo:</td>
                            <td class="CelulaZebra2" colspan="2">
                                <strong>
                                  <input name="placa" type="text" id="placa" class="inputReadOnly" value="" size="30" maxlength="80" readonly="true">
                                  <input name="localiza_vei" type="button" class="botoes" id="localiza_vei" value="..." onClick="javascript:localizaveiculo();">
                                  <img src="img/borracha.gif" name="limpavei" border="0" align="absbottom" class="imagemLink" id="limpavei" title="Limpar Veículo" onClick="javascript:getObj('idveiculo').value = '0';javascript:getObj('placa').value = '';">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trcliente" name="trcliente" style="display:none;">
                            <td class="TextoCampos">
                                <select name="apenasRemetente" id="apenasRemetente" class="inputtexto">
                                    <option value="=" selected>Apenas o Remetente</option>
                                    <option value="&lt;&gt;">Exceto o Remetente</option>
                                </select></td>
                            <td class="CelulaZebra2" colspan="2">
                                <strong>
                                  <input name="remet" type="text" id="remet" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                  <input name="localiza_rem" type="button" class="botoes" id="localiza_rem" value="..." onClick="javascript:localizaremet();">
                                  <img name="img_remet" id="img_remet" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink"  title="Limpar Remetente" onClick="javascript:getObj('idremetente').value = 0;javascript:getObj('remet').value = '';">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trDestinatario" name="trDestinatario" style="display:none;">
                           <td class="TextoCampos">
                                <select name="apenasDestinatario" id="apenasDestinatario" class="inputtexto">
                                    <option value="=" selected>Apenas o Destinatário</option>
                                    <option value="&lt;&gt;">Exceto o Destinatário</option>
                                </select></td>
                           <td class="CelulaZebra2" colspan="2">
                               <strong>
                                  <input name="dest_rzs" type="text" id="dest_rzs" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                  <input name="localiza_rem2" type="button" class="botoes" id="localiza_rem2" value="..." onClick="javascript:launchPopupLocate('./localiza?acao=consultar&idlista=<%=BeanLocaliza.DESTINATARIO_DE_CONHECIMENTO%>', 'Destinatario_');">
                                  <img name="img_remet" id="img_remet2" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink"  title="Limpar Destinatário" onClick="javascript:getObj('iddestinatario').value = 0;getObj('dest_rzs').value = '';">
                               </strong>
                           </td>
                        </tr>
                         <tr id="trconsignatario" name="trconsignatario" style="display:none;">
                            <td class="TextoCampos">
                                <select name="apenasConsignatario" id="apenasConsignatario" class="inputtexto">
                                    <option value="=" selected>Apenas o Consign.</option>
                                    <option value="&lt;&gt;">Exceto o Consign.</option>
                                </select>
                            </td>
                            <td class="CelulaZebra2" colspan="2">
                                <strong>
                                    <input name="consig" type="text" id="consig" class="inputReadOnly" size="30" maxlength="80" readonly="true">
                                    <input name="localiza_rem3" type="button" class="botoes" id="localiza_rem3" value="..." onClick="javascript:localizaconsignatario();">
                                    <img name="img_con" id="img_con" src="img/borracha.gif" border="0" align="absbottom" class="imagemLink"  title="Limpar Consignatário" onClick="javascript:getObj('idconsignatario').value = '0';getObj('consig').value = '';">
                                </strong>
                            </td>
                        </tr>
                        <tr id="trSituacao" style="display: none">
                            <td class="TextoCampos" >Mostrar coleta(s):</td>
                            <td class="TextoCampos" >
                                <div align="left">
                                    <select name="situacao" id="situacao" class="fieldMin">
                                        <option value="todas" selected>Todas</option>
                                        <option value="true">Finalizadas (Faturadas)</option>
                                        <option value="false">N&atilde;o finalizadas</option>
                                    </select>
                                </div>
                            </td>
                            <td id="td" class="TextoCampos" >
                                <div align="left">
                                    <select name="baixado" id="baixado" class="fieldMin" style="width:140px;">
                                        <option value="" selected>Todas</option>
                                        <option value="false">Apenas em aberto</option>
                                        <option value="false2">Apenas em aberto (Sem romaneio)</option>
                                        <option value="true">Apenas baixadas</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr id="trCancelada">
                            <td class="TextoCampos" colspan="3">
                                <div align="center" id="divCancelada">
                                    <label>
                                        <input type="checkbox" name="cancelada" id="cancelada" value="checkbox">
                                        Apenas as coletas Canceladas                                        
                                    </label>
                                </div>
                            </td>
                        </tr>
                        <tr id="trProgramada">
                            <td class="TextoCampos" >Coleta(s) Realizada(s):</td>
                            <td class="TextoCampos" colspan="3">
                                <div id="divProgramada" align="left">
                                    <select name="programada" id="programada" class="fieldMin">
                                       <option value="" selected>Todas</option>
                                       <option value="true">No Prazo</option>
                                       <option value="false">Em Atraso</option>
                                    </select>
                                </div>
                            </td>
                        </tr>
                        <tr id="trBairro" style="display: none;">
                            <td class="TextoCampos" >Apenas o Bairro da Coleta:</td>
                            <td class="CelulaZebra2" colspan="3">
                                <input type="text" size="30" name="bairroOrigem" id="bairroOrigem" value="" class="fieldMin">
                            </td>
                        </tr>
                        <tr id="trBooking" style="display: none;">
                            <td class="TextoCampos" >
                                    Apenas o booking:
                            </td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="text" size="20" name="booking" id="booking" value="" class="fieldMin">
                            </td>
                        </tr>
                        <tr id="trFatura" style="display: none;">
                            <td class="TextoCampos" >
                                    Apenas a fatura:
                            </td>
                            <td class="CelulaZebra2" colspan="2">
                                <input type="text" size="10" name="numero_fatura" id="numero_fatura" value="" class="fieldMin">
                                &nbsp;/&nbsp;
                                <input type="text" size="4" name="ano_fatura" id="ano_fatura" value="" class="fieldMin">
                            </td>
                        </tr>
                    </table>
              </td>
            </tr>
            <!--<tr id="trGroupos">
                <td colspan="9">
                    <table id="node_grupos" border="0" style="width:100%; height:100%; border: 1 solid #000">
                        <tr class="cellNotes">
                            <td width="24%" class="CelulaZebra2">
                                <div align="center">
                                    <img src="img/add.gif" border="0" title="Adicionar um novo Grupo" class="imagemLink" onClick="launchPopupLocate('./localiza?acao=consultar&idlista=33','Grupo')">          
                                </div>
                            </td>
                            <td width="76%" class="CelulaZebra2" >
                                <div align="center">Apenas os grupos</div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>-->
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
                             <input name="imprimir" type="button" class="botoes" id="imprimir" value="Imprimir" onClick="javascript:tryRequestToServer(function(){popRel();});">
                        <%}%>
                    </div>
                </td>
            </tr>
        </table>
            
        </div>
        <div id="tabDinamico"> </div>

        
    </body>
</html>
