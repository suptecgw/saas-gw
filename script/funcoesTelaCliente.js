/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var listaTipoTabelaAutomaticas = new Array();
var countTipoTabela = 0;
var listaTabelaRemAutomaticas = new Array();
var countTabelaRem = 0;

listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('-1', '-- Selecione --');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('0', 'Peso/Kg');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('1', 'Peso/Cubagem');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('2', '% Nota Fiscal');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('3', 'Combinado');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('4', 'Por volume');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('5', 'Por km');
listaTipoTabelaAutomaticas[++countTipoTabela] = new Option('6', 'Por pallet');

listaTabelaRemAutomaticas[++countTabelaRem] = new Option('n', 'Nunca');
listaTabelaRemAutomaticas[++countTabelaRem] = new Option('s', 'Sempre');

function limparBorrachaBairro() {
    $("bairro").readOnly = false;
    $("bairro").className = "inputtexto";
    $("bairro").value = "";
    $("idLocalizaBairro").value = 0;
}
function limparBorrachaBairroCob() {
    $("bairroCob").readOnly = false;
    $("bairroCob").className = "inputtexto";
    $("bairroCob").value = "";
    $("idBairroCob").value = 0;
}
function limparBorrachaBairroCol() {
    $("bairroCol").readOnly = false;
    $("bairroCol").className = "inputtexto";
    $("bairroCol").value = "";
    $("idBairroCol").value = 0;
}
function limparBairroEntrega(index) {
    $("bairroEndEntrga_" + index).readOnly = false;
    $("bairroEndEntrga_" + index).className = "inputtexto";
    $("bairroEndEntrga_" + index).value = "";
    $("idBairroEndEntrga_" + index).value = 0;
}

function abrirLocalizaRedespacho(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(6, "Redespacho_Importacao", "", "");
}

function abrirLocalizaDestinatario(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }

    popLocate(4, "Destinatario_Importacao", "", "");
}

function abrirLocalizaRemetente(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(3, "Remetente_Importacao", "", "");
}

function abrirLocalizaConsignatario(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(5, "Consignatario_Importacao", "", "");
}

function abrirLocalizaRepresentante(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(23, "Representante_Importacao", "", "");
}

function abrirLocalizaRecebedor(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(79, "Recebedor_Importacao", "", "");
}

function abrirLocalizaExpedidor(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(78, "Expedidor_Importacao", "", "");
}

function abrirLayoutRemetente(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(03, "Remetente_Layout", "", "");
}

function limparBorrachaRedespacho(index) {
    $("LocalizaRedespacho_" + index).value = "";
    $("LocalizaIdRedespacho_" + index).value = "0";
}
function limparBorrachaDestinatario(index) {
    $("LocalizaDestinatario_" + index).value = "";
    $("LocalizaIdDestinatario_" + index).value = "0";
}
function limparBorrachaRemetente(index) {
    $("LocalizaRemetente_" + index).value = "";
    $("LocalizaIdRemetente_" + index).value = "0";
}
function limparBorrachaConsignatario(index) {
    $("LocalizaConsignatario_" + index).value = "";
    $("LocalizaIdConsignatario_" + index).value = "0";
}
function limparBorrachaRepresentante(index) {
    $("LocalizaRepresentante_" + index).value = "";
    $("LocalizaIdRepresentante_" + index).value = "0";
}
function limparBorrachaRecebedor(index) {
    $("LocalizaRecebedor_" + index).value = "";
    $("LocalizaIdRecebedor_" + index).value = "0";
}
function limparBorrachaExpedidor(index) {
    $("LocalizaExpedidor_" + index).value = "";
    $("LocalizaIdExpedidor_" + index).value = "0";
}

function limparBorrachaLayoutRemetente(index) {
    $("layoutRemetente_" + index).value = "";
    $("layoutIdRemetente_" + index).value = "0";
}

function mostrarFiltroPedido(index) {
    if ($("slcLayout_" + index).value != "58" && $("slcLayout_" + index).value != "62" && $("slcLayout_" + index).value != "87" && $("slcLayout_" + index).value !="88") {
        if ($("inpRadNotaFiscalSim_" + index).checked) {
            $("trImport_Pedido_" + index).style.display = "";
            visivel($('spanAgruparNFeDataEmissao_' + index));
        } else {
            $("trImport_Pedido_" + index).style.display = "none";
            invisivel($('spanAgruparNFeDataEmissao_' + index));
        }
    }
}

function criterioLayout(layout, index) {
    $("trImport_Redespacho_" + index).style.display = "none";//1
    $("trImport_Destinatario_" + index).style.display = "none";//2
    $("trImport_Remetente_" + index).style.display = "none";//13
    $("trImport_Consignatario_" + index).style.display = "none";//3
    $("trImport_Representante_" + index).style.display = "none";//4
    $("trImport_Recebedor_" + index).style.display = "none";//5
    $("trImport_Expedidor_" + index).style.display = "none";//6
    $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
    $("trImport_NotaFiscal_" + index).style.display = "none";//8
    $("trImport_Pedido_" + index).style.display = "none";//9
    $("trImport_Cliente_" + index).style.display = "none";//10
    $("trImport_Filial_" + index).style.display = "none";//11
    $("trImport_Veiculo_" + index).style.display = "none";//12
    $("trImport_Mercadoria_" + index).style.display = "none";//14
    $("trImport_ItemNota_" + index).style.display = "none";//15
    $("trImport_CadDestinatario_" + index).style.display = "none";//16
    $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
    $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
    $("trLayoutRemetente_" + index).style.display = "none"; // Remetente Nota Fiscal
    $("trSubContratacao_" + index).style.display = "none";
    $("trImport_UfDestino_" + index).style.display = "none";
    $("trImportacao_Responsavel_" + index).style.display = "none";
    $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";
    $("trImport_ConsiderarVolumeTabela_" + index).style.display = "none";
    $("trImportacao_TagsPersonalizadas_" + index).style.display = "none";
    switch (layout) {
        case "1"://NF-e (XML)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImportacao_Responsavel_" + index).style.display = "";//25
            $("trImport_ConsiderarVolumeTabela_" + index).style.display = "";
            $("trImportacao_TagsPersonalizadas_" + index).style.display = "";
            break;
        case "2"://NF-e (Chave de Acesso)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17            
            $("trImport_AgrupVeiculo_" + index).style.display = "";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImportacao_Responsavel_" + index).style.display = "";//25
            $("trImport_ConsiderarVolumeTabela_" + index).style.display = "";
            $("trImportacao_TagsPersonalizadas_" + index).style.display = "";
            break;
        case "3"://CT-e Redespacho (XML) 
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "4"://CT-e confirmado por outra aplicação (XML)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "5"://GSM (gwLogis)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "6"://Gw Conferencia
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "7"://SETCESP-COTIN (eFacil)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "8"://SETCESP-COTIN (Mobly)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "9"://SETCESP-COTIN (Ricardo Eletro)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "10"://Ipiranga
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "11"://Itatiaia
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "12"://JetClass(Maxxi)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "13"://JAMEF
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "14"://Terphane
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "15"://NeoGrid
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "16"://Alpargatas
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "17"://Proceda (3.0A)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "18"://Proceda (3.0B)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "19"://Proceda (3.0A - Displan)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "20"://Proceda (3.0A - Hermes)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "21"://Proceda (3.1)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "22"://Proceda (3.1 - Chave de Acesso)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "23"://Proceda (3.1 - Aliança)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "24"://Proceda (3.1 - Cia de Tecidos Santo Antônio)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "25"://Proceda (3.1 - Café 3 Corações)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "26"://Proceda (3.1 - DIST.MED.SANTA CRUZ)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "27"://Proceda (3.1 - Danone)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "28"://Proceda (3.1 - Fujioka)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "29"://Proceda (3.1 - Del Vale)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "30"://Proceda (3.1 - Masterfoods)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "31"://Proceda (3.1 - M. Dias)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "32"://Proceda (3.1 - Melhoramento CPNC)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "33"://Proceda (3.1 - Lojas Americanas)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "34"://Proceda (QUERO)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "35"://Redespacho (Rapidão Cometa)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "36"://Padrão Hermes (Excel)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "37"://Tavex
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "38"://Tivit (5.0)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trSubContratacao_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_basePadraoCubagem_" + index).style.display = "";//18
            $("trImport_CadRemetente_" + index).style.display = "none";//19
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//20
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "";//21
            $("trImport_UfDestino_" + index).style.display = "none";//22
            break;
        case "39"://Whirlpool
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//21
            $("trImport_UfDestino_" + index).style.display = "none";//22
            break;
        case "40"://Avon (Web Service)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "41"://Proceda (3.1 - Philips)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "42"://Proceda (5.0 CONEMB - RAMTHUN)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "43"://Proceda (3.1 Jequiti)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "44"://Quatro Estações
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "45"://Privalia
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "46"://Samsung
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "47"://Proceda (3.1 - Coteminas)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "48"://Proceda (3.0A - DHL)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "49": //(Cimento Nacional)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "50": //(Odorata Cosméticos)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "51":  //  TIVIT (Bellapratica Cosméticos)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "52"://Proceda (3.1 - SIMPRESS COMERCIO E LOCAÇÃO)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7 - esse campo Deivid pediu para deixar INVISIVEL.
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "53":  //  Nota Fiscal
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "54":  //  CT-e Chave Acesso
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "55":  //  Arquivos Iimportados XML
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "";//18
            $("trLayoutRemetente_" + index).style.display = ""; // 19 Remetente Nota Fiscal
            $("trSubContratacao_" + index).style.display = "none"; //20
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//21
            $("trImport_CadRemetente_" + index).style.display = "none";//22
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//23
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//24
            $("trImport_UfDestino_" + index).style.display = "none";//25
            break;
        case "56" : // Proceda (3.1 - SAN REMO, PINCEIS ATLAS, BETTANIN)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "57" : // Proceda (3.1 - Regina Industria e Comercio S/A)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trSubContratacao_" + index).style.display = "none";//18
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//19
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "58" : // Proceda - (Magazine Luiza)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "59"://SETCESP-COTIN (CNova Comércio Eletrônicos S/A)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "";//9
            $("trImport_Cliente_" + index).style.display = "";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "60"://Proceda (3.1 - Univar do Brasil)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//21
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "61"://Proceda (3.0A - Gw Padrão)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            escondeMostraAtualizarDestinatario(index);
            break;
        case "62"://Proceda (3.1 - Redespacho Celistics Barueri Transportadora LTDA)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "";//24
            break;

        case "63"://Tambasa (XML)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "64"://Proceda (3.1 ? Nativas Varejo e Distribuição LTDA)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_UfDestino_" + index).style.display = "none";//23
            break;
        case "65":// Unilever (Excel)
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Remetente_" + index).style.display = "";//13
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23    
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "66"://Proceda (3.1 - Proceda (3.0A) BUAIZ
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23            
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "68"://Proceda (3.1 - Flor Arte)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23            
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "69"://Proceda (3.1 - Redespacho Sist Global)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23            
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "70"://Proceda (3.1 - Faber Castel)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23            
            $("trImport_UfDestino_" + index).style.display = "";//24
            break;
        case "71"://Proceda (5.0 - Editora Abril)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23            
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "72"://Proceda (3.1 - Madeira Madeira)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "73"://Proceda (3.1 - Supporte Armaz Vendas Logist Int LTDA)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "74"://Start Química (Excel)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "75"://TIVIT (5.0 - Itatiaia)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "";//25
            break;
        case "76":// Grupo Farrapos (Transportadora)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "";//25
            break;
        case "77"://Proceda (3.1 - CIAMOB)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            break;
        case "78"://SETCESP-COTIN (Redespacho)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24
            break;
        case "79"://Proceda (3.0A - MEXICHEM BRASIL)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24            
            break;
        case "80"://SETCESP-COTIN (Rico Transportes)
           $("trImport_Redespacho_" + index).style.display = "";//1
           $("trImport_Destinatario_" + index).style.display = "";//2
           $("trImport_Remetente_" + index).style.display = "none";//13
           $("trImport_Consignatario_" + index).style.display = "";//3
           $("trImport_Representante_" + index).style.display = "";//4
           $("trImport_Recebedor_" + index).style.display = "";//5
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_Pedido_" + index).style.display = "none";//9
           $("trImport_Cliente_" + index).style.display = "none";//10
           $("trImport_Filial_" + index).style.display = "none";//11
           $("trImport_Veiculo_" + index).style.display = "none";//12
           $("trImport_Mercadoria_" + index).style.display = "none";//14
           $("trImport_ItemNota_" + index).style.display = "none";//15
           $("trImport_CadDestinatario_" + index).style.display = "";//16
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
           $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
           $("trSubContratacao_" + index).style.display = "none";//19
           $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
           $("trImport_CadRemetente_" + index).style.display = "";//21
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
           $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
           $("trImport_UfDestino_" + index).style.display = "none";//24
           $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24
           break;    
        case "81"://Proceda (3.0A ? GROUPE SEB)
           $("trImport_Redespacho_" + index).style.display = "";//1
           $("trImport_Destinatario_" + index).style.display = "";//2
           $("trImport_Remetente_" + index).style.display = "none";//13
           $("trImport_Consignatario_" + index).style.display = "";//3
           $("trImport_Representante_" + index).style.display = "";//4
           $("trImport_Recebedor_" + index).style.display = "";//5
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_Pedido_" + index).style.display = "none";//9
           $("trImport_Cliente_" + index).style.display = "none";//10
           $("trImport_Filial_" + index).style.display = "none";//11
           $("trImport_Veiculo_" + index).style.display = "none";//12
           $("trImport_Mercadoria_" + index).style.display = "none";//14
           $("trImport_ItemNota_" + index).style.display = "none";//15
           $("trImport_CadDestinatario_" + index).style.display = "";//16
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
           $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
           $("trSubContratacao_" + index).style.display = "none";//19
           $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
           $("trImport_CadRemetente_" + index).style.display = "";//21
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
           $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
           $("trImport_UfDestino_" + index).style.display = "none";//24
           $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24
           break;    
        case "82"://Proceda (3.1 - Santher)
           $("trImport_Redespacho_" + index).style.display = "";//1
           $("trImport_Destinatario_" + index).style.display = "";//2
           $("trImport_Remetente_" + index).style.display = "none";//13
           $("trImport_Consignatario_" + index).style.display = "";//3
           $("trImport_Representante_" + index).style.display = "";//4
           $("trImport_Recebedor_" + index).style.display = "";//5
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_Pedido_" + index).style.display = "none";//9
           $("trImport_Cliente_" + index).style.display = "none";//10
           $("trImport_Filial_" + index).style.display = "none";//11
           $("trImport_Veiculo_" + index).style.display = "none";//12
           $("trImport_Mercadoria_" + index).style.display = "none";//14
           $("trImport_ItemNota_" + index).style.display = "none";//15
           $("trImport_CadDestinatario_" + index).style.display = "";//16
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
           $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
           $("trSubContratacao_" + index).style.display = "none";//19
           $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
           $("trImport_CadRemetente_" + index).style.display = "";//21
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
           $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
           $("trImport_UfDestino_" + index).style.display = "none";//24
           $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24
           break;
       case "83"://Proceda (3.1 - Kimberly Clark)
           $("trImport_Redespacho_" + index).style.display = "";//1
           $("trImport_Destinatario_" + index).style.display = "";//2
           $("trImport_Remetente_" + index).style.display = "none";//13
           $("trImport_Consignatario_" + index).style.display = "";//3
           $("trImport_Representante_" + index).style.display = "";//4
           $("trImport_Recebedor_" + index).style.display = "";//5
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_Pedido_" + index).style.display = "none";//9
           $("trImport_Cliente_" + index).style.display = "none";//10
           $("trImport_Filial_" + index).style.display = "none";//11
           $("trImport_Veiculo_" + index).style.display = "none";//12
           $("trImport_Mercadoria_" + index).style.display = "none";//14
           $("trImport_ItemNota_" + index).style.display = "none";//15
           $("trImport_CadDestinatario_" + index).style.display = "";//16
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
           $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
           $("trSubContratacao_" + index).style.display = "none";//19
           $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
           $("trImport_CadRemetente_" + index).style.display = "";//21
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
           $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
           $("trImport_UfDestino_" + index).style.display = "none";//24
           $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24
           break;
        case "85": // Proceda (3.0A - O. V. D. IMPORTADORA E DISTRIBUIDORA LTDA)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24            
            break;
        case "86": // Proceda (3.0A ? LEROY MERLIN)
            $("trImport_Redespacho_" + index).style.display = "";//1
            $("trImport_Destinatario_" + index).style.display = "";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "";//3
            $("trImport_Representante_" + index).style.display = "";//4
            $("trImport_Recebedor_" + index).style.display = "";//5
            $("trImport_Expedidor_" + index).style.display = "";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24            
            break;
        case "87"://Proceda (3.1 - Tambasa)
           $("trImport_Redespacho_" + index).style.display = "none";//1
           $("trImport_Destinatario_" + index).style.display = "none";//2
           $("trImport_Remetente_" + index).style.display = "";//13
           $("trImport_Consignatario_" + index).style.display = "";//3
           $("trImport_Representante_" + index).style.display = "none";//4
           $("trImport_Recebedor_" + index).style.display = "";//5
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_Pedido_" + index).style.display = "none";//9
           $("trImport_Cliente_" + index).style.display = "none";//10
           $("trImport_Filial_" + index).style.display = "none";//11
           $("trImport_Veiculo_" + index).style.display = "none";//12
           $("trImport_Mercadoria_" + index).style.display = "none";//14
           $("trImport_ItemNota_" + index).style.display = "none";//15
           $("trImport_CadDestinatario_" + index).style.display = "";//16
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
           $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
           $("trSubContratacao_" + index).style.display = "none";//19
           $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
           $("trImport_CadRemetente_" + index).style.display = "none";//21
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
           $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
           $("trImport_UfDestino_" + index).style.display = "none";//24
           $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24           
           $("spanAgruparNFeDataEmissao_" + index).style.display = "none";           
           break; 
       case "88": //Proceda (3.1 - Marilan Alimentos S/A)
           $("trImport_Redespacho_" + index).style.display = "";//1
           $("trImport_Destinatario_" + index).style.display = "";//2
           $("trImport_Consignatario_" + index).style.display = "";//2
           $("trImport_Representante_" + index).style.display = "";//4
           $("trImport_Recebedor_" + index).style.display = "";//5
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_CadDestinatario_" + index).style.display = "";//16
           $("trImport_CadRemetente_" + index).style.display = "";//21  
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "";//22
           $("trImport_CadRemetente_" + index).style.display = "";//21
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//23
           $("spanAgruparNFeDataEmissao_" + index).style.display = "none";  
            break;
        case "89": // Proceda (3.1 - DHL)
           $("trImport_Redespacho_" + index).style.display = "";//1
           $("trImport_Destinatario_" + index).style.display = "none";//2
           $("trImport_Remetente_" + index).style.display = "none";//13
           $("trImport_Consignatario_" + index).style.display = "";//3
           $("trImport_Representante_" + index).style.display = "none";//4
           $("trImport_Recebedor_" + index).style.display = "none";//5
           $("trImport_Expedidor_" + index).style.display = "";//6
           $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
           $("trImport_NotaFiscal_" + index).style.display = "";//8
           $("trImport_Pedido_" + index).style.display = "";//9
           $("trImport_Cliente_" + index).style.display = "none";//10
           $("trImport_Filial_" + index).style.display = "none";//11
           $("trImport_Veiculo_" + index).style.display = "none";//12
           $("trImport_Mercadoria_" + index).style.display = "none";//14
           $("trImport_ItemNota_" + index).style.display = "none";//15
           $("trImport_CadDestinatario_" + index).style.display = "none";//16
           $("trImport_CadDestinatarioTabela_" + index).style.display = "";//17
           $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
           $("trSubContratacao_" + index).style.display = "none";//19
           $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
           $("trImport_CadRemetente_" + index).style.display = "none";//21
           $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
           $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
           $("trImport_UfDestino_" + index).style.display = "none";//24
           $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24           
           $("spanAgruparNFeDataEmissao_" + index).style.display = "none";           
       break;
        default:
            $("trImport_Redespacho_" + index).style.display = "none";//1
            $("trImport_Destinatario_" + index).style.display = "none";//2
            $("trImport_Remetente_" + index).style.display = "none";//13
            $("trImport_Consignatario_" + index).style.display = "none";//3
            $("trImport_Representante_" + index).style.display = "none";//4
            $("trImport_Recebedor_" + index).style.display = "none";//5
            $("trImport_Expedidor_" + index).style.display = "none";//6
            $("trImport_ConsiderarFrete_" + index).style.display = "none";//7
            $("trImport_NotaFiscal_" + index).style.display = "none";//8
            $("trImport_Pedido_" + index).style.display = "none";//9
            $("trImport_Cliente_" + index).style.display = "none";//10
            $("trImport_Filial_" + index).style.display = "none";//11
            $("trImport_Veiculo_" + index).style.display = "none";//12
            $("trImport_Mercadoria_" + index).style.display = "none";//14
            $("trImport_ItemNota_" + index).style.display = "none";//15
            $("trImport_CadDestinatario_" + index).style.display = "none";//16
            $("trImport_CadDestinatarioTabela_" + index).style.display = "none";//17
            $("trImport_AgrupVeiculo_" + index).style.display = "none";//18
            $("trSubContratacao_" + index).style.display = "none";//19
            $("trImport_basePadraoCubagem_" + index).style.display = "none";//20
            $("trImport_CadRemetente_" + index).style.display = "none";//21
            $("trImport_AtualizaEndDestinatario_" + index).style.display = "none";//22
            $("trImport_basePadraoCubagemAereo_" + index).style.display = "none";//23
            $("trImport_UfDestino_" + index).style.display = "none";//24
            $("trImport_CalcularPrazoTabelaPreco_" + index).style.display = "none";//24
            return false;
            break;
    }

}

function criterioLayoutLimparCampos(index) {
    if ($("slcLayout_" + index).value != "4") {
        if (confirm("Atenção: Com a alteração do layout, deseja manter os filtros?")) {
            $("chkRedespacho_" + index).checked = false;
            $("LocalizaRedespacho_" + index).value = "";
            $("LocalizaIdRedespacho_" + index).value = 0;
            $("chkDestinatario_" + index).checked = false;
            $("LocalizaDestinatario_" + index).value = "";
            $("LocalizaIdDestinatario_" + index).value = 0;
            $("chkRemetente_" + index).checked = false;
            $("LocalizaRemetente_" + index).value = "";
            $("LocalizaIdRemetente_" + index).value = 0;
            $("chkConsignatario_" + index).checked = false;
            $("LocalizaConsignatario_" + index).value = "";
            $("LocalizaIdConsignatario_" + index).value = 0;
            $("chkRepresentante_" + index).checked = false;
            $("LocalizaRepresentante_" + index).value = "";
            $("LocalizaIdRepresentante_" + index).value = 0;
            $("chkRecebedor_" + index).checked = false;
            $("LocalizaRecebedor_" + index).value = "";
            $("LocalizaIdRecebedor_" + index).value = 0;
            $("chkExpedidor_" + index).checked = false;
            $("LocalizaExpedidor_" + index).value = "";
            $("LocalizaIdExpedidor_" + index).value = 0;
            $("inpRadTabelaArquivoT_" + index).checked = true;
            $("inpRadNotaFiscalSim_" + index).checked = true;
            $("inpRadPedidoNao_" + index).checked = true;
            $("inpRadClienteSim_" + index).checked = true;
            $("inpRadFilialNao_" + index).checked = true;
            $("inpRadVeiculoNao_" + index).checked = true;
            $("inpRadVeiculoSim_" + index).checked = false;
            $("inpRadMercadoriaNao_" + index).checked = true;
            $("inpRadItemNotaNao_" + index).checked = true;
//            $("inpRadCadDestinatarioNao_"+index).checked = true; comentei por que esta linha estava quebrando a validação da configuração - Atualizar o cadastro do cliente ao importar EDI/XML/DANFE, caso o cliente já esteja cadastrado. 
            $("slcTipoTabela_" + index).value = -1;
            $("slcTipoTabelaRemetente_" + index).value = "n";
            $("inpSubContratacaoSim_" + index).checked = false;
            $("inpSubContratacaoNao_" + index).checked = true;
            $("inpRadAtualizaEndDestinatarioSim_" + index).checked = true;
        }
    }
}

function excluirImportacaoLote(index) {
    try {
        var id = $("inpHidIdLayoutEdi_" + index).value;
        var descricao = getTextSelect($("slcLayout_" + index));
        if (confirm("Deseja excluir o layout '" + descricao + "'?")) {
            if (confirm("Tem certeza?")) {
                Element.remove($("trLayoutPrincipal_" + index));
                Element.remove($("trLayout_" + index));
                Element.remove($("trImport_Principal_" + index));
                Element.remove($("trImport_Redespacho_" + index));
                Element.remove($("trImport_Destinatario_" + index));
                Element.remove($("trImport_Remetente_" + index));
                Element.remove($("trImport_Consignatario_" + index));
                Element.remove($("trImport_Representante_" + index));
                Element.remove($("trImport_Recebedor_" + index));
                Element.remove($("trImport_Expedidor_" + index));
                Element.remove($("trImport_ConsiderarFrete_" + index));
                Element.remove($("trImport_NotaFiscal_" + index));
                Element.remove($("trImport_Pedido_" + index));
                Element.remove($("trImport_Cliente_" + index));
                Element.remove($("trImport_Filial_" + index));
                Element.remove($("trImport_Veiculo_" + index));
                Element.remove($("trImport_Mercadoria_" + index));
                Element.remove($("trImport_ItemNota_" + index));
                Element.remove($("trImport_CadDestinatario_" + index));
                Element.remove($("trImport_CadDestinatarioTabela_" + index));
                Element.remove($("trImport_AgrupVeiculo_" + index));
                Element.remove($("trLayoutRemetente_" + index));
                Element.remove($("trSubContratacao_" + index));
                Element.remove($("trImport_CalcularPrazoTabelaPreco_" + index));
                if (id > 0) {
                    new Ajax.Request("LayoutEDIControlador?acao=ajaxRemoverClienteLayoutEDI&idClienteLayoutEDI=" + id,
                            {
                                method: 'get',
                                onSuccess: function () {
                                    alert('Layout removido com sucesso!')
                                },
                                onFailure: function () {
                                    alert('Something went wrong...')
                                }
                            });
                }
            }
        }
    } catch (e) {
        alert(e);
    }
}

function mostrarLocalizaRedespacho(index) {
    if ($("chkRedespacho_" + index).checked) {
        $("divRedespachoLocaliza_" + index).style.display = "";
    } else {
        $("divRedespachoLocaliza_" + index).style.display = "none";
        limparBorrachaRedespacho(index);
    }
}
function mostrarLocalizaDestinatario(index) {
    if ($("chkDestinatario_" + index).checked) {
        $("divDestinatarioLocaliza_" + index).style.display = "";
    } else {
        $("divDestinatarioLocaliza_" + index).style.display = "none";
        limparBorrachaDestinatario(index);
    }
}
function mostrarLocalizaRemetente(index) {
    if ($("chkRemetente_" + index).checked) {
        $("divRemetenteLocaliza_" + index).style.display = "";
    } else {
        $("divRemetenteLocaliza_" + index).style.display = "none";
        limparBorrachaRemetente(index);
    }
}
function mostrarLocalizaConsignatario(index) {
    if ($("chkConsignatario_" + index).checked) {
        $("divConsignatarioLocaliza_" + index).style.display = "";
    } else {
        $("divConsignatarioLocaliza_" + index).style.display = "none";
        limparBorrachaConsignatario(index);
    }
}
function mostrarLocalizaRepresentante(index) {
    if ($("chkRepresentante_" + index).checked) {
        $("divRepresentanteLocaliza_" + index).style.display = "";
    } else {
        $("divRepresentanteLocaliza_" + index).style.display = "none";
        limparBorrachaRepresentante(index);
    }
}
function mostrarLocalizaRecebedor(index) {
    if ($("chkRecebedor_" + index).checked) {
        $("divRecebedorLocaliza_" + index).style.display = "";
    } else {
        $("divRecebedorLocaliza_" + index).style.display = "none";
        limparBorrachaRecebedor(index);
    }
}
function mostrarLocalizaExpedidor(index) {
    if ($("chkExpedidor_" + index).checked) {
        $("divExpedidorLocaliza_" + index).style.display = "";
    } else {
        $("divExpedidorLocaliza_" + index).style.display = "none";
        limparBorrachaExpedidor(index);
    }
}

function ImportacaoLote(idLayoutEdi, codigoLayoutEdi, isAtribuirRedespacho, idRedespacho, nomeRedespacho, isAtribuirDestinatario, idDestinatario, nomeDestinatario,
        isAtribuirRemetente, idRemetente, nomeRemetente, isAtribuirConsignatario, idConsignatario, nomeConsignatario, isAtribuirRepresentante, idRepresentante,
        nomeRepresentante, isAtribuirRecebedor, idRecebedor, nomeRecebedor, isAtribuirExpedidor, idExpedidor, nomeExpedidor, considerarFrete, isAgruparNFRemDest, isAgruparNfUfDestino,
        isAgruparNfNumeroPedido, isConsiderarGrupoCliProd, isImportarFilialSelecionada, isUtilizarDadosVeiculo, isCadastrarMercadoria, isImportarItemNf, isAtualizarDestinatario,
        tipoTabelaDestinatario, utilizarTabelaRemetente, isAgruparPorVeiculo, idRemetenteNf, nomeRemetenteNf, isSubContratacao, basePadraoCubagem, isAtualizarRemetente, isAtualizarEndDestinario,
        basePadraoCubagemAereo, isAtribuirResponsavelPagamento, tipoResponsavelPagamento, isCalcularPrazoTabelaPreco, considerarVolume, agruparNFeEmissao) {
    this.idLayoutEdi = (idLayoutEdi == "null" || idLayoutEdi == undefined ? 0 : idLayoutEdi);
    this.codigoLayoutEdi = (codigoLayoutEdi == "null" || codigoLayoutEdi == undefined ? 0 : codigoLayoutEdi);
    this.isAtribuirRedespacho = (isAtribuirRedespacho == "null" || isAtribuirRedespacho == undefined ? false : isAtribuirRedespacho);
    this.idRedespacho = (idRedespacho == "null" || idRedespacho == undefined ? 0 : idRedespacho);
    this.nomeRedespacho = (nomeRedespacho == "null" || nomeRedespacho == undefined ? "" : nomeRedespacho);
    this.isAtribuirDestinatario = (isAtribuirDestinatario == "null" || isAtribuirDestinatario == undefined ? false : isAtribuirDestinatario);
    this.idDestinatario = (idDestinatario == "null" || idDestinatario == undefined ? 0 : idDestinatario);
    this.nomeDestinatario = (nomeDestinatario == "null" || nomeDestinatario == undefined ? "" : nomeDestinatario);
    this.isAtribuirRemetente = (isAtribuirRemetente == "null" || isAtribuirRemetente == undefined ? false : isAtribuirRemetente);
    this.idRemetente = (idRemetente == "null" || idRemetente == undefined ? 0 : idRemetente);
    this.nomeRemetente = (nomeRemetente == "null" || nomeRemetente == undefined ? "" : nomeRemetente);
    this.isAtribuirConsignatario = (isAtribuirConsignatario == "null" || isAtribuirConsignatario == undefined ? false : isAtribuirConsignatario);
    this.idConsignatario = (idConsignatario == "null" || idConsignatario == undefined ? 0 : idConsignatario);
    this.nomeConsignatario = (nomeConsignatario == "null" || nomeConsignatario == undefined ? "" : nomeConsignatario);
    this.isAtribuirRepresentante = (isAtribuirRepresentante == "null" || isAtribuirRepresentante == undefined ? false : isAtribuirRepresentante);
    this.idRepresentante = (idRepresentante == "null" || idRepresentante == undefined ? 0 : idRepresentante);
    this.nomeRepresentante = (nomeRepresentante == "null" || nomeRepresentante == undefined ? "" : nomeRepresentante);
    this.isAtribuirRecebedor = (isAtribuirRecebedor == "null" || isAtribuirRecebedor == undefined ? false : isAtribuirRecebedor);
    this.idRecebedor = (idRecebedor == "null" || idRecebedor == undefined ? 0 : idRecebedor);
    this.nomeRecebedor = (nomeRecebedor == "null" || nomeRecebedor == undefined ? "" : nomeRecebedor);
    this.isAtribuirExpedidor = (isAtribuirExpedidor == "null" || isAtribuirExpedidor == undefined ? false : isAtribuirExpedidor);
    this.idExpedidor = (idExpedidor == "null" || idExpedidor == undefined ? 0 : idExpedidor);
    this.nomeExpedidor = (nomeExpedidor == "null" || nomeExpedidor == undefined ? "" : nomeExpedidor);
    this.considerarFrete = (considerarFrete == "null" || considerarFrete == undefined ? "t" : considerarFrete);
    this.isAgruparNFRemDest = (isAgruparNFRemDest == "null" || isAgruparNFRemDest == undefined ? false : isAgruparNFRemDest);
    this.isAgruparNfUfDestino = (isAgruparNfUfDestino == "null" || isAgruparNfUfDestino == undefined ? false : isAgruparNfUfDestino);
    this.isAgruparNfNumeroPedido = (isAgruparNfNumeroPedido == "null" || isAgruparNfNumeroPedido == undefined ? false : isAgruparNfNumeroPedido);
    this.isConsiderarGrupoCliProd = (isConsiderarGrupoCliProd == "null" || isConsiderarGrupoCliProd == undefined ? false : isConsiderarGrupoCliProd);
    this.isImportarFilialSelecionada = (isImportarFilialSelecionada == "null" || isImportarFilialSelecionada == undefined ? false : isImportarFilialSelecionada);
    this.isUtilizarDadosVeiculo = (isUtilizarDadosVeiculo == "null" || isUtilizarDadosVeiculo == undefined || isUtilizarDadosVeiculo == "" ? false : isUtilizarDadosVeiculo);
    this.isCadastrarMercadoria = (isCadastrarMercadoria == "null" || isCadastrarMercadoria == undefined ? false : isCadastrarMercadoria);
    this.isImportarItemNf = (isImportarItemNf == "null" || isImportarItemNf == undefined ? false : isImportarItemNf);
    this.isAtualizarDestinatario = (isAtualizarDestinatario == "null" || isAtualizarDestinatario == undefined ? false : isAtualizarDestinatario);
    this.isAgruparPorVeiculo = (isAgruparPorVeiculo == "null" || isAgruparPorVeiculo == undefined ? false : isAgruparPorVeiculo);
    this.tipoTabelaDestinatario = (tipoTabelaDestinatario == "null" || tipoTabelaDestinatario == undefined ? 0 : tipoTabelaDestinatario);
    this.utilizarTabelaRemetente = (utilizarTabelaRemetente == "null" || utilizarTabelaRemetente == undefined ? "n" : utilizarTabelaRemetente);
    this.idRemetenteNf = (idRemetenteNf == "null" || idRemetenteNf == undefined ? 0 : idRemetenteNf);
    this.nomeRemetenteNf = (nomeRemetenteNf == "null" || nomeRemetenteNf == undefined ? "" : nomeRemetenteNf);
    this.isSubContratacao = (isSubContratacao == "null" || isSubContratacao == undefined ? false : isSubContratacao);
    this.basePadraoCubagem = (basePadraoCubagem == "null" || basePadraoCubagem == undefined ? 0 : basePadraoCubagem);
    this.basePadraoCubagemAereo = (basePadraoCubagemAereo == "null" || basePadraoCubagemAereo == undefined ? 0 : basePadraoCubagemAereo);
    this.isAtualizarRemetente = (isAtualizarRemetente == "null" || isAtualizarRemetente == undefined ? false : isAtualizarRemetente);
    this.isAtualizarEndDestinario = (isAtualizarEndDestinario == "null" || isAtualizarEndDestinario == undefined ? false : isAtualizarEndDestinario);
    this.isAtribuirResponsavelPagamento = (isAtribuirResponsavelPagamento == "null" || isAtribuirResponsavelPagamento == undefined ? false : isAtribuirResponsavelPagamento);
    this.tipoResponsavelPagamento = (tipoResponsavelPagamento == "null" || tipoResponsavelPagamento == undefined ? 'cif' : tipoResponsavelPagamento);
    this.isCalcularPrazoTabelaPreco = (tipoResponsavelPagamento == "null" || tipoResponsavelPagamento == undefined ? true : isCalcularPrazoTabelaPreco);
    this.considerarVolume = (considerarVolume == "null" || considerarVolume == undefined ? 0 : considerarVolume);
    this.agruparNFeEmissao = (agruparNFeEmissao == "null" || agruparNFeEmissao == undefined ? false : (agruparNFeEmissao === 'true' || agruparNFeEmissao === 't'));
}

var countImportacaoLote = 0;
function addImportacaoLote(listaNotfisAutomaticas, importacaoLote) {

    if (importacaoLote == null || importacaoLote == undefined) {
        importacaoLote = new ImportacaoLote();
    }

    countImportacaoLote++;
    var classe = (countImportacaoLote % 2 == 1 ? "CelulaZebra1" : "CelulaZebra2");

    var _trLayoutPrincipal = Builder.node("tr", {id: "trLayoutPrincipal_" + countImportacaoLote, className: "tabela"});
    var _trLayout = Builder.node("tr", {id: "trLayout_" + countImportacaoLote, className: classe});
    var _trImportPrincipal = Builder.node("tr", {id: "trImport_Principal_" + countImportacaoLote, name: "trImport_Principal_" + countImportacaoLote, className: classe});
    var _trImportRedespacho = Builder.node("tr", {id: "trImport_Redespacho_" + countImportacaoLote, name: "trImport_Redespacho_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportDestinatario = Builder.node("tr", {id: "trImport_Destinatario_" + countImportacaoLote, name: "trImport_Destinatario_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportRemetente = Builder.node("tr", {id: "trImport_Remetente_" + countImportacaoLote, name: "trImport_Remetente_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportConsignatario = Builder.node("tr", {id: "trImport_Consignatario_" + countImportacaoLote, name: "trImport_Consignatario_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportRepresentante = Builder.node("tr", {id: "trImport_Representante_" + countImportacaoLote, name: "trImport_Representante_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportRecebedor = Builder.node("tr", {id: "trImport_Recebedor_" + countImportacaoLote, name: "trImport_Recebedor_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportExpedidor = Builder.node("tr", {id: "trImport_Expedidor_" + countImportacaoLote, name: "trImport_Expedidor_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportConsiderarFrete = Builder.node("tr", {id: "trImport_ConsiderarFrete_" + countImportacaoLote, name: "trImport_ConsiderarFrete_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportNotaFiscal = Builder.node("tr", {id: "trImport_NotaFiscal_" + countImportacaoLote, name: "trImport_NotaFiscal_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportUfDestino = Builder.node("tr", {id: "trImport_UfDestino_" + countImportacaoLote, name: "trImport_UfDestino_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportPedido = Builder.node("tr", {id: "trImport_Pedido_" + countImportacaoLote, name: "trImport_Pedido_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportCliente = Builder.node("tr", {id: "trImport_Cliente_" + countImportacaoLote, name: "trImport_Cliente_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportFilial = Builder.node("tr", {id: "trImport_Filial_" + countImportacaoLote, name: "trImport_Filial_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportVeiculo = Builder.node("tr", {id: "trImport_Veiculo_" + countImportacaoLote, name: "trImport_Veiculo_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportMercadoria = Builder.node("tr", {id: "trImport_Mercadoria_" + countImportacaoLote, name: "trImport_Mercadoria_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportItemNota = Builder.node("tr", {id: "trImport_ItemNota_" + countImportacaoLote, name: "trImport_ItemNota_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportCadDestinatario = Builder.node("tr", {id: "trImport_CadDestinatario_" + countImportacaoLote, name: "trImport_CadDestinatario_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportCadDestinatarioTabela = Builder.node("tr", {id: "trImport_CadDestinatarioTabela_" + countImportacaoLote, name: "trImport_CadDestinatarioTabela_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportAgrupVeiculo = Builder.node("tr", {id: "trImport_AgrupVeiculo_" + countImportacaoLote, name: "trImport_AgrupVeiculo_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trLayoutRemetente = Builder.node("tr", {id: "trLayoutRemetente_" + countImportacaoLote, className: classe});
    var _trSubContratacao = Builder.node("tr", {id: "trSubContratacao_" + countImportacaoLote, name: "trSubContratacao_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportBasePadraoCubagem = Builder.node("tr", {id: "trImport_basePadraoCubagem_" + countImportacaoLote, name: "trImport_basePadraoCubagem_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportBasePadraoCubagemAereo = Builder.node("tr", {id: "trImport_basePadraoCubagemAereo_" + countImportacaoLote, name: "trImport_basePadraoCubagemAereo_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportCadRemetente = Builder.node("tr", {id: "trImport_CadRemetente_" + countImportacaoLote, name: "trImport_CadRemetente_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportAtualizaEndDestinatario = Builder.node("tr", {id: "trImport_AtualizaEndDestinatario_" + countImportacaoLote, name: "trImport_AtualizaEndDestinatario_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportResponsavel = Builder.node("tr", {id: "trImportacao_Responsavel_" + countImportacaoLote, name: "trImportacao_Responsavel_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportCalcularPrazoTabelaPreco = Builder.node("tr", {id: "trImport_CalcularPrazoTabelaPreco_" + countImportacaoLote, name: "trImport_CalcularPrazoTabelaPreco_" + countImportacaoLote, className: classe, style: "display:none"});
    var _trImportConsiderarVolume = Builder.node("tr", {id: "trImport_ConsiderarVolumeTabela_" + countImportacaoLote, name: "trImport_ConsiderarVolumeTabela_" + countImportacaoLote, className: classe, style:"display:none"});
    
    var _tdLayoutPrincipal = Builder.node("td", {id: "tdLayoutPrincipal_" + countImportacaoLote, className: "tabela", colspan: "3"});
    var _tdExcluir = Builder.node("td", {id: "tdExcluir_" + countImportacaoLote, name: "tdExcluir_" + countImportacaoLote, className: classe, width: "2%"});
    var _tdLayoutLbl = Builder.node("td", {id: "tdLayoutLbl_" + countImportacaoLote, name: "tdLayoutLbl_" + countImportacaoLote, className: classe, width: "48%"});
    var _tdLayoutSlc = Builder.node("td", {id: "tdLayoutSlc_" + countImportacaoLote, name: "tdLayoutSlc_" + countImportacaoLote, className: classe, width: "50%"});
    var _tdImportPrincipal = Builder.node("td", {id: "tdImportPrincipal_" + countImportacaoLote, name: "tdImportPrincipal_" + countImportacaoLote, className: "tabela", colspan: "3"});
    var _tdRedespacho = Builder.node("td", {id: "tdRedespacho_" + countImportacaoLote, name: "tdRedespacho_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdRedespachoLocaliza = Builder.node("td", {id: "tdRedespachoLocaliza_" + countImportacaoLote, name: "tdRedespachoLocaliza_" + countImportacaoLote, className: classe});
    var _tdDestinatario = Builder.node("td", {id: "tdDestinatario_" + countImportacaoLote, name: "tdDestinatario_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdDestinatarioLocaliza = Builder.node("td", {id: "tdDestinatarioLocaliza_" + countImportacaoLote, name: "tdDestinatarioLocaliza_" + countImportacaoLote, className: classe});
    var _tdRemetente = Builder.node("td", {id: "tdRemetente_" + countImportacaoLote, name: "tdRemetente_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdRemetenteLocaliza = Builder.node("td", {id: "tdRemetenteLocaliza_" + countImportacaoLote, name: "tdRemetenteLocaliza_" + countImportacaoLote, className: classe});
    var _tdConsignatario = Builder.node("td", {id: "tdConsignatario_" + countImportacaoLote, name: "tdConsignatario_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdConsignatarioLocaliza = Builder.node("td", {id: "tdConsignatarioLocaliza_" + countImportacaoLote, name: "tdConsignatarioLocaliza_" + countImportacaoLote, className: classe});
    var _tdRepresentante = Builder.node("td", {id: "tdRepresentante_" + countImportacaoLote, name: "tdRepresentante_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdRepresentanteLocaliza = Builder.node("td", {id: "tdRepresentanteLocaliza_" + countImportacaoLote, name: "tdRepresentanteLocaliza_" + countImportacaoLote, className: classe});
    var _tdRecebedor = Builder.node("td", {id: "tdRecebedor_" + countImportacaoLote, name: "tdRecebedor_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdRecebedorLocaliza = Builder.node("td", {id: "tdRecebedorLocaliza_" + countImportacaoLote, name: "tdRecebedorLocaliza_" + countImportacaoLote, className: classe});
    var _tdExpedidor = Builder.node("td", {id: "tdExpedidor_" + countImportacaoLote, name: "tdExpedidor_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdExpedidorLocaliza = Builder.node("td", {id: "tdExpedidorLocaliza_" + countImportacaoLote, name: "tdExpedidorLocaliza_" + countImportacaoLote, className: classe});
    var _tdConsiderarFrete = Builder.node("td", {id: "tdConsiderarFrete_" + countImportacaoLote, name: "tdConsiderarFrete_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdTabelaArquivo = Builder.node("td", {id: "tdTabelaArquivo_" + countImportacaoLote, name: "tdTabelaArquivo_" + countImportacaoLote, className: classe});
    var _tdNotaFiscal = Builder.node("td", {id: "tdNotaFiscal_" + countImportacaoLote, name: "tdNotaFiscal_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdNotaFiscalSimNao = Builder.node("td", {id: "tdNotaFiscalSimNao_" + countImportacaoLote, name: "tdNotaFiscalSimNao_" + countImportacaoLote, className: classe});
    var _tdUfDestino = Builder.node("td", {id: "tdUfDestino_" + countImportacaoLote, name: "tdUfDestino_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdUfDestinoSimNao = Builder.node("td", {id: "tdUfDestinoSimNao_" + countImportacaoLote, name: "tdUfDestinoSimNao_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdPedido = Builder.node("td", {id: "tdPedido_" + countImportacaoLote, name: "tdPedido_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdPedidoSimNao = Builder.node("td", {id: "tdPedidoSimNao_" + countImportacaoLote, name: "tdPedidoSimNao_" + countImportacaoLote, className: classe});
    var _tdCliente = Builder.node("td", {id: "tdCliente_" + countImportacaoLote, name: "tdCliente_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdClienteSimNao = Builder.node("td", {id: "tdClienteSimNao_" + countImportacaoLote, name: "tdClienteSimNao_" + countImportacaoLote, className: classe});
    var _tdFilial = Builder.node("td", {id: "tdFilial_" + countImportacaoLote, name: "tdFilial_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdFilialSimNao = Builder.node("td", {id: "tdFilialSimNao_" + countImportacaoLote, name: "tdFilialSimNao_" + countImportacaoLote, className: classe});
    var _tdVeiculo = Builder.node("td", {id: "tdVeiculo_" + countImportacaoLote, name: "tdVeiculo_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdVeiculoSimNao = Builder.node("td", {id: "tdVeiculoSimNao_" + countImportacaoLote, name: "tdVeiculoSimNao_" + countImportacaoLote, className: classe});
    var _tdMercadoria = Builder.node("td", {id: "tdMercadoria_" + countImportacaoLote, name: "tdMercadoria_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdMercadoriaSimNao = Builder.node("td", {id: "tdMercadoriaSimNao_" + countImportacaoLote, name: "tdMercadoriaSimNao_" + countImportacaoLote, className: classe});
    var _tdItemNota = Builder.node("td", {id: "tdItemNota_" + countImportacaoLote, name: "tdItemNota_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdItemNotaSimNao = Builder.node("td", {id: "tdItemNotaSimNao_" + countImportacaoLote, name: "tdItemNotaSimNao_" + countImportacaoLote, className: classe});
    var _tdCadDestinatario = Builder.node("td", {id: "tdCadDestinatario_" + countImportacaoLote, name: "tdCadDestinatario_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdCadDestinatarioSimNao = Builder.node("td", {id: "tdCadDestinatarioSimNao_" + countImportacaoLote, name: "tdCadDestinatarioSimNao_" + countImportacaoLote, className: classe});
    var _tdCadDestinatarioTabela = Builder.node("td", {id: "tdCadDestinatarioTabela_" + countImportacaoLote, name: "tdCadDestinatarioTabela_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdCadDestinatarioTipoTabela = Builder.node("td", {id: "tdCadDestinatarioTipoTabela_" + countImportacaoLote, name: "tdCadDestinatarioTipoTabela_" + countImportacaoLote, className: classe});
    var _tdCadRemetente = Builder.node("td", {id: "tdCadRemetente_" + countImportacaoLote, name: "tdCadRemetente_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdCadRemetenteSimNao = Builder.node("td", {id: "tdCadRemetenteSimNao_" + countImportacaoLote, name: "tdCadRemetenteSimNao_" + countImportacaoLote, className: classe});
    var _tdAtualizaEndDestinatario = Builder.node("td", {id: "tdAtualizaEndDestinatario_" + countImportacaoLote, name: "tdAtualizaEndDestinatario_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdAtualizaEndDestinatarioSimNao = Builder.node("td", {id: "tdAtualizaEndDestinatarioSimNao_" + countImportacaoLote, name: "tdAtualizaEndDestinatarioSimNao_" + countImportacaoLote, className: classe});

    var _tdAgruparPorVeiculo = Builder.node("td", {id: "tdAgruparPorVeiculo_" + countImportacaoLote, name: "tdAgruparPorVeiculo_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdAgruparPorVeiculoSimNao = Builder.node("td", {id: "tdAgruparPorVeiculoSimNao_" + countImportacaoLote, name: "tdAgruparPorVeiculoSimNao_" + countImportacaoLote, className: classe});

    var _tdLayoutLblRemetente = Builder.node("td", {id: "tdLayoutLblRemetente_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdLayoutInpRemetente = Builder.node("td", {id: "tdLayoutInpRemetente_" + countImportacaoLote, className: classe});

    var _tdSubContratacao = Builder.node("td", {id: "tdSubContratacao_" + countImportacaoLote, name: "tdSubContratacao_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdSubContratacaoSimNao = Builder.node("td", {id: "tdSubContratacaoSimNao_" + countImportacaoLote, name: "tdSubContratacaoSimNao_" + countImportacaoLote, className: classe});
    var _tdBasePadraoCubagemLabel = Builder.node("td", {id: "tdBasePadraoCubagemLabel_" + countImportacaoLote, name: "tdBasePadraoCubagemLabel_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdBasePadraoCubagemImput = Builder.node("td", {id: "tdBasePadraoCubagemImput_" + countImportacaoLote, name: "tdBasePadraoCubagemImput_" + countImportacaoLote, className: classe});
    var _tdBasePadraoCubagemAereoLabel = Builder.node("td", {id: "tdBasePadraoCubagemAereoLabel_" + countImportacaoLote, name: "tdBasePadraoCubagemAereoLabel_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdBasePadraoCubagemAereoImput = Builder.node("td", {id: "tdBasePadraoCubagemAereoImput_" + countImportacaoLote, name: "tdBasePadraoCubagemAereoImput_" + countImportacaoLote, className: classe});

    var _tdResponsavel = Builder.node("td", {id: "tdResponsavel_" + countImportacaoLote, name: "tdResponsavel_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdResponsavelRadio = Builder.node("td", {id: "tdResponsavelRadio_" + countImportacaoLote, name: "tdResponsavelRadio_" + countImportacaoLote, className: classe});

    var _tdCalcularPrazoTabelaPreco = Builder.node("td", {id: "tdCalcularPrazoTabelaPreco_" + countImportacaoLote, name: "tdCalcularPrazoTabelaPreco_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdCalcularPrazoTabelaPrecoSimNao = Builder.node("td", {id: "tdCalcularPrazoTabelaPrecoSimNao_" + countImportacaoLote, name: "tdCalcularPrazoTabelaPrecoSimNao_" + countImportacaoLote, className: classe});
    
    var _tdConsiderarVolume = Builder.node("td", {id: "tdConsiderarVolume_" + countImportacaoLote, name: "tdConsiderarVolumeTabela_" + countImportacaoLote, className: classe, colspan: "2"});
    var _tdConsiderarVolumeTag = Builder.node("td", {id: "tdConsiderarVolumeTag_" + countImportacaoLote, name: "tdConsiderarVolumeTag_" + countImportacaoLote, className: classe, colspan: "2"}); 
    //***************LABEL**********************
    var _lblLayoutPrincipal = Builder.node("label", {id: "lblLayoutPrincipal_" + countImportacaoLote, name: "lblLayoutPrincipal_" + countImportacaoLote});
    _lblLayoutPrincipal.innerHTML = "Seleção do Layout";

    var _lblLayout = Builder.node("label", {id: "lblLayout_" + countImportacaoLote, name: "lblLayout_" + countImportacaoLote});
    _lblLayout.innerHTML = "Escolha o Layout:";

    var _lblImportacao = Builder.node("label", {id: "lblInfImportacao_" + countImportacaoLote, name: "lblInfImportacao_" + countImportacaoLote});
    _lblImportacao.innerHTML = "Parametros de Importação";

    var _lblRedespacho = Builder.node("label", {id: "lblRedespacho_" + countImportacaoLote, name: "lblRedespacho_" + countImportacaoLote});
    _lblRedespacho.innerHTML = "  Atribuir o redespacho para todos os CT-e(s)";

    var _lblEspacoRedespacho = Builder.node("label", {id: "lblEspacoRedespacho_" + countImportacaoLote, name: "lblEspacoRedespacho_" + countImportacaoLote});
    _lblEspacoRedespacho.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoRedespachoBorracha = Builder.node("label", {id: "lblEspacoRedespachoBorracha_" + countImportacaoLote, name: "lblEspacoRedespachoBorracha_" + countImportacaoLote});
    _lblEspacoRedespachoBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblDestinatario = Builder.node("label", {id: "lblDestinatario_" + countImportacaoLote, name: "lblDestinatario_" + countImportacaoLote});
    _lblDestinatario.innerHTML = "  Atribuir o destinatário para todos os CT-e(s)";

    var _lblEspacoDestinatario = Builder.node("label", {id: "lblEspacoDestinatario_" + countImportacaoLote, name: "lblEspacoDestinatario_" + countImportacaoLote});
    _lblEspacoDestinatario.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoDestinatarioBorracha = Builder.node("label", {id: "lblEspacoDestinatarioBorracha_" + countImportacaoLote, name: "lblEspacoDestinatarioBorracha_" + countImportacaoLote});
    _lblEspacoDestinatarioBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblRemetente = Builder.node("label", {id: "lblRemetente_" + countImportacaoLote, name: "lblRemetente_" + countImportacaoLote});
    _lblRemetente.innerHTML = "  Atribuir o remetente para todos os CT-e(s)";

    var _lblEspacoRemetente = Builder.node("label", {id: "lblEspacoRemetente_" + countImportacaoLote, name: "lblEspacoRemetente_" + countImportacaoLote});
    _lblEspacoRemetente.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoRemetenteBorracha = Builder.node("label", {id: "lblEspacoRemetenteBorracha_" + countImportacaoLote, name: "lblEspacoRemetenteBorracha_" + countImportacaoLote});
    _lblEspacoRemetenteBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblConsignatario = Builder.node("label", {id: "lblConsignatario_" + countImportacaoLote, name: "lblConsignatario_" + countImportacaoLote});
    _lblConsignatario.innerHTML = "  Atribuir o consignatário para todos os CT-e(s)";

    var _lblEspacoConsignatario = Builder.node("label", {id: "lblEspacoConsignatario_" + countImportacaoLote, name: "lblEspacoConsignatario_" + countImportacaoLote});
    _lblEspacoConsignatario.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoConsignatarioBorracha = Builder.node("label", {id: "lblEspacoConsignatarioBorracha_" + countImportacaoLote, name: "lblEspacoConsignatarioBorracha_" + countImportacaoLote});
    _lblEspacoConsignatarioBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblRepresentante = Builder.node("label", {id: "lblRepresentante_" + countImportacaoLote, name: "lblRepresentante_" + countImportacaoLote});
    _lblRepresentante.innerHTML = "  Atribuir o representante para todos os CT-e(s)";

    var _lblEspacoRepresentante = Builder.node("label", {id: "lblEspacoRepresentante_" + countImportacaoLote, name: "lblEspacoRepresentante_" + countImportacaoLote});
    _lblEspacoRepresentante.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoRepresentanteBorracha = Builder.node("label", {id: "lblEspacoRepresentanteBorracha_" + countImportacaoLote, name: "lblEspacoRepresentanteBorracha_" + countImportacaoLote});
    _lblEspacoRepresentanteBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblRecebedor = Builder.node("label", {id: "lblRecebedor_" + countImportacaoLote, name: "lblRecebedor_" + countImportacaoLote});
    _lblRecebedor.innerHTML = "  Atribuir o recebedor para todos os CT-e(s)";

    var _lblEspacoRecebedor = Builder.node("label", {id: "lblEspacoRecebedor_" + countImportacaoLote, name: "lblEspacoRecebedor_" + countImportacaoLote});
    _lblEspacoRecebedor.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoRecebedorBorracha = Builder.node("label", {id: "lblEspacoRecebedorBorracha_" + countImportacaoLote, name: "lblEspacoRecebedorBorracha_" + countImportacaoLote});
    _lblEspacoRecebedorBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblExpedidor = Builder.node("label", {id: "lblExpedidor_" + countImportacaoLote, name: "lblExpedidor_" + countImportacaoLote});
    _lblExpedidor.innerHTML = "  Atribuir o expedidor para todos os CT-e(s)";

    var _lblEspacoExpedidor = Builder.node("label", {id: "lblEspacoExpedidor_" + countImportacaoLote, name: "lblEspacoExpedidor_" + countImportacaoLote});
    _lblEspacoExpedidor.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoExpedidorBorracha = Builder.node("label", {id: "lblEspacoExpedidorBorracha_" + countImportacaoLote, name: "lblEspacoExpedidorBorracha_" + countImportacaoLote});
    _lblEspacoExpedidorBorracha.innerHTML = "&nbsp;&nbsp;";

    var _lblConsiderarFrete = Builder.node("label", {id: "lblConsiderarFrete_" + countImportacaoLote, name: "lblConsiderarFrete_" + countImportacaoLote});
    _lblConsiderarFrete.innerHTML = "Ao importar considerar o valor do frete:";

    var _lblTabela = Builder.node("label", {id: "lblTabela_" + countImportacaoLote, name: "lblTabela_" + countImportacaoLote});
    _lblTabela.innerHTML = "&nbsp;O cálculo da tabela preço&nbsp;&nbsp;";

    var _lblArquivo = Builder.node("label", {id: "lblArquivo_" + countImportacaoLote, name: "lblArquivo_" + countImportacaoLote});
    _lblArquivo.innerHTML = "&nbsp;O valor informado no arquivo";

    var _lblNotaFiscal = Builder.node("label", {id: "lblNotaFiscal_" + countImportacaoLote, name: "lblNotaFiscal_" + countImportacaoLote});
    _lblNotaFiscal.innerHTML = "Caso existe notas fiscais para o mesmo remetente e destinatário, deseja agrupa-las no mesmo CT-e?";

    var _lblNotaFiscalSim = Builder.node("label", {id: "lblNotaFiscalSim_" + countImportacaoLote, name: "lblNotaFiscalSim_" + countImportacaoLote});
    _lblNotaFiscalSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblNotaFiscalNao = Builder.node("label", {id: "lblNotaFiscalNao_" + countImportacaoLote, name: "lblNotaFiscalNao_" + countImportacaoLote});
    _lblNotaFiscalNao.innerHTML = "&nbsp;Não&nbsp;";
    
    var _lblUfDestino = Builder.node("label", {id: "lblNotaFiscal_" + countImportacaoLote, name: "lblNotaFiscal_" + countImportacaoLote});
    _lblUfDestino.innerHTML = "Caso existam notas fiscais para a mesma UF de destino, deseja agrupa-las no mesmo CT-e?";

    var _lblUfDestinoSim = Builder.node("label", {id: "lblNotaFiscalSim_" + countImportacaoLote, name: "lblNotaFiscalSim_" + countImportacaoLote});
    _lblUfDestinoSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblUfDestinoNao = Builder.node("label", {id: "lblNotaFiscalNao_" + countImportacaoLote, name: "lblNotaFiscalNao_" + countImportacaoLote});
    _lblUfDestinoNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblPedido = Builder.node("label", {id: "lblPedido_" + countImportacaoLote, name: "lblPedido_" + countImportacaoLote});
    _lblPedido.innerHTML = "Gerar um CT-e para cada número de pedido?";

    var _lblPedidoSim = Builder.node("label", {id: "lblPedidoSim_" + countImportacaoLote, name: "lblPedidoSim_" + countImportacaoLote});
    _lblPedidoSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblPedidoNao = Builder.node("label", {id: "lblPedidoNao_" + countImportacaoLote, name: "lblPedidoNao_" + countImportacaoLote});
    _lblPedidoNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblCliente = Builder.node("label", {id: "lblCliente_" + countImportacaoLote, name: "lblCliente_" + countImportacaoLote});
    _lblCliente.innerHTML = "Considerar o grupo de clientes no localizar produto?";

    var _lblClienteSim = Builder.node("label", {id: "lblClienteSim_" + countImportacaoLote, name: "lblClienteSim_" + countImportacaoLote});
    _lblClienteSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblClienteNao = Builder.node("label", {id: "lblClienteNao_" + countImportacaoLote, name: "lblClienteNao_" + countImportacaoLote});
    _lblClienteNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblFilial = Builder.node("label", {id: "lblFilial_" + countImportacaoLote, name: "lblFilial_" + countImportacaoLote});
    _lblFilial.innerHTML = "Importar arquivo apenas da filial selecionada?";

    var _lblFilialSim = Builder.node("label", {id: "lblFilialSim_" + countImportacaoLote, name: "lblFilialSim_" + countImportacaoLote});
    _lblFilialSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblFilialNao = Builder.node("label", {id: "lblFilialNao_" + countImportacaoLote, name: "lblFilialNao_" + countImportacaoLote});
    _lblFilialNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblVeiculo = Builder.node("label", {id: "lblVeiculo_" + countImportacaoLote, name: "lblVeiculo_" + countImportacaoLote});
    _lblVeiculo.innerHTML = "Utilizar os dados do veículo do XML?";

    var _lblVeiculoSim = Builder.node("label", {id: "lblVeiculoSim_" + countImportacaoLote, name: "lblVeiculoSim_" + countImportacaoLote});
    _lblVeiculoSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblVeiculoNao = Builder.node("label", {id: "lblVeiculoNao_" + countImportacaoLote, name: "lblVeiculoNao_" + countImportacaoLote});
    _lblVeiculoNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblMercadoria = Builder.node("label", {id: "lblMercadoria_" + countImportacaoLote, name: "lblMercadoria_" + countImportacaoLote});
    _lblMercadoria.innerHTML = "Cadastrar mercadoria?";

    var _lblMercadoriaSim = Builder.node("label", {id: "lblMercadoriaSim_" + countImportacaoLote, name: "lblMercadoriaSim_" + countImportacaoLote});
    _lblMercadoriaSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblMercadoriaNao = Builder.node("label", {id: "lblMercadoriaNao_" + countImportacaoLote, name: "lblMercadoriaNao_" + countImportacaoLote});
    _lblMercadoriaNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblItemNota = Builder.node("label", {id: "lblItemNota_" + countImportacaoLote, name: "lblItemNota_" + countImportacaoLote, });
    _lblItemNota.innerHTML = "Importar os itens da nota?";

    var _lblItemNotaSim = Builder.node("label", {id: "lblItemNotaSim_" + countImportacaoLote, name: "lblItemNotaSim_" + countImportacaoLote, });
    _lblItemNotaSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblItemNotaNao = Builder.node("label", {id: "lblItemNotaNao_" + countImportacaoLote, name: "lblItemNotaNao_" + countImportacaoLote, });
    _lblItemNotaNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblCadDestinatario = Builder.node("label", {id: "lblCadDestinatario_" + countImportacaoLote, name: "lblCadDestinatario_" + countImportacaoLote, });
    _lblCadDestinatario.innerHTML = "Atualizar o cadastro do destinatário ao importar o arquivo?";

    var _lblCadDestinatarioSim = Builder.node("label", {id: "CadDestinatarioSim_" + countImportacaoLote, name: "lblCadDestinatarioSim_" + countImportacaoLote, });
    _lblCadDestinatarioSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblCadDestinatarioNao = Builder.node("label", {id: "lblCadDestinatarioNao_" + countImportacaoLote, name: "lblCadDestinatarioNao_" + countImportacaoLote, });
    _lblCadDestinatarioNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblCadDestinatarioTabela = Builder.node("label", {id: "lblCadDestinatarioTabela_" + countImportacaoLote, name: "lblCadDestinatarioTabela_" + countImportacaoLote, });
    _lblCadDestinatarioTabela.innerHTML = "Ao cadastrar o Destinatário:";

    var _lblCadDestinatarioUtiliza = Builder.node("label", {id: "lblCadDestinatarioUtiliza_" + countImportacaoLote, name: "lblCadDestinatarioUtiliza_" + countImportacaoLote, });
    _lblCadDestinatarioUtiliza.innerHTML = "Utilizar:";

    var _lblCadDestinatarioTipoTabela = Builder.node("label", {id: "lblCadDestinatarioTipoTabela_" + countImportacaoLote, name: "lblCadDestinatarioTipoTabela_" + countImportacaoLote, });
    _lblCadDestinatarioTipoTabela.innerHTML = "Tipo tabela:";

    var _lblCadDestinatarioTabelaRemetente = Builder.node("label", {id: "lblCadDestinatarioTabelaRemetente_" + countImportacaoLote, name: "lblCadDestinatarioTabelaRemetente_" + countImportacaoLote, });
    _lblCadDestinatarioTabelaRemetente.innerHTML = "Utiliza tabela do remetente:";

    var _lblCadRemetente = Builder.node("label", {id: "lblCadRemetente_" + countImportacaoLote, name: "lblCadRemetente_" + countImportacaoLote, });
    _lblCadRemetente.innerHTML = "Atualizar o cadastro do remetente ao importar o arquivo?";

    var _lblCadRemetenteSim = Builder.node("label", {id: "CadRemetenteSim_" + countImportacaoLote, name: "CadRemetenteSim_" + countImportacaoLote, });
    _lblCadRemetenteSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblCadRemetenteNao = Builder.node("label", {id: "lblCadRemetenteNao_" + countImportacaoLote, name: "lblCadRemetenteNao_" + countImportacaoLote, });
    _lblCadRemetenteNao.innerHTML = "&nbsp;Não&nbsp;";

    var _lblAtualizaEndDestinatario = Builder.node("label", {id: "lblAtualizaEndDestinatario_" + countImportacaoLote, name: "lblAtualizaEndDestinatario_" + countImportacaoLote, });
    _lblAtualizaEndDestinatario.innerHTML = "Atualizar o endereço do destinatário ao importar o arquivo?";

    var _lblAtualizaEndDestinatarioSim = Builder.node("label", {id: "AtualizaEndDestinatarioSim_" + countImportacaoLote, name: "AtualizaEndDestinatarioSim_" + countImportacaoLote, });
    _lblAtualizaEndDestinatarioSim.innerHTML = "Atualizar";

    var _lblAtualizaEndDestinatarioNao = Builder.node("label", {id: "lblAtualizaEndDestinatarioNao_" + countImportacaoLote, name: "lblAtualizaEndDestinatarioNao_" + countImportacaoLote, });
    _lblAtualizaEndDestinatarioNao.innerHTML = "Adicionar como um novo endereço de entrega";

    var _lblAgruparPorVeiculo = Builder.node("label", {id: "lblAgruparPorVeiculo_" + countImportacaoLote, name: "lblAgruparPorVeiculo_" + countImportacaoLote, });
    _lblAgruparPorVeiculo.innerHTML = "Caso Exista Notas Fiscais para o mesmo veículo, deseja agrupa-las no mesmo CT-e? O destinatário do CT-e será o da primeira nota.";

    var _lblAgruparPorVeiculoSim = Builder.node("label", {id: "lblAgruparPorVeiculoSim_" + countImportacaoLote, name: "lblAgruparPorVeiculoSim_" + countImportacaoLote, });
    _lblAgruparPorVeiculoSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblAgruparPorVeiculoNao = Builder.node("label", {id: "lblAgruparPorVeiculoNao_" + countImportacaoLote, name: "lblAgruparPorVeiculoNao_" + countImportacaoLote, });
    _lblAgruparPorVeiculoNao.innerHTML = "&nbsp;Nao&nbsp;";
    //AgrupVeiculo

    var _lblLayoutRemetente = Builder.node("label", {id: "lblLayoutRemetente_" + countImportacaoLote, name: "lblLayoutRemetente_" + countImportacaoLote});
    _lblLayoutRemetente.innerHTML = "Remetente:";

    var _lblEspacoLayoutRemetenteBtn = Builder.node("label", {id: "lblEspacoLayoutRemetente_" + countImportacaoLote, name: "lblEspacoLayoutRemetente_" + countImportacaoLote});
    _lblEspacoLayoutRemetenteBtn.innerHTML = "&nbsp;&nbsp;";

    var _lblEspacoLayoutRemetenteImg = Builder.node("label", {id: "lblEspacoLayoutRemetenteImg_" + countImportacaoLote, name: "lblEspacoLayoutRemetenteImg_" + countImportacaoLote});
    _lblEspacoLayoutRemetenteImg.innerHTML = "&nbsp;&nbsp;";

    var _lblSubContratacao = Builder.node("label", {id: "lblSubContratacao_" + countImportacaoLote, name: "lblSubContratacao_" + countImportacaoLote, });
    _lblSubContratacao.innerHTML = "Serviço de Subcontratação? ";

    var _lblSubContratacaoSim = Builder.node("label", {id: "lblSubContratacaoSim_" + countImportacaoLote, name: "lblSubContratacaoSim_" + countImportacaoLote, });
    _lblSubContratacaoSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblSubContratacaoNao = Builder.node("label", {id: "lblSubContratacaoNao_" + countImportacaoLote, name: "lblSubContratacaoNao_" + countImportacaoLote, });
    _lblSubContratacaoNao.innerHTML = "&nbsp;Nao&nbsp;";

    var _lblBasePadraoCubagem = Builder.node("label", {id: "lblBasePadraoCubagem_" + countImportacaoLote, name: "lblBasePadraoCubagem_" + countImportacaoLote, });
    _lblBasePadraoCubagem.innerHTML = "Base Padrão para Cubagem Rodoviário:";

    var _lblBasePadraoCubagemAereo = Builder.node("label", {id: "lblBasePadraoCubagemAereo_" + countImportacaoLote, name: "lblBasePadraoCubagemAereo_" + countImportacaoLote, });
    _lblBasePadraoCubagemAereo.innerHTML = "Base Padrão para Cubagem Aéreo:";

    var _lblResponsavel = Builder.node("label", {id: "lblResponsavel_" + countImportacaoLote, name: "lblResponsavel_" + countImportacaoLote});
    _lblResponsavel.innerHTML = "  Atribuir o responsável pelo pagamento";

    var _lblResponsavelCIF = Builder.node("label", {id: "lblResponsavelCIF_" + countImportacaoLote, name: "lblResponsavelCIF_" + countImportacaoLote});
    _lblResponsavelCIF.innerHTML = "&nbsp;CIF&nbsp;";

    var _lblResponsavelFOB = Builder.node("label", {id: "lblResponsavelFOB_" + countImportacaoLote, name: "lblResponsavelFOB_" + countImportacaoLote});
    _lblResponsavelFOB.innerHTML = "&nbsp;FOB&nbsp;";

    var _lblResponsavelTerceiro = Builder.node("label", {id: "lblResponsavelTerceiro_" + countImportacaoLote, name: "lblResponsavelTerceiro_" + countImportacaoLote});
    _lblResponsavelTerceiro.innerHTML = "&nbsp;Terceiro&nbsp;";

    var _lblCalcularPrazoTabelaPreco = Builder.node("label", {id: "lblCalcularPrazoTabelaPreco_" + countImportacaoLote, name: "lblCalcularPrazoTabelaPreco_" + countImportacaoLote});
    _lblCalcularPrazoTabelaPreco.innerHTML = "&nbsp;Calcular o prazo de entrega pela tabela de preço?";

    var _lblCalcularPrazoTabelaPrecoSim = Builder.node("label", {id: "lblCalcularPrazoTabelaPrecoSim_" + countImportacaoLote, name: "lblCalcularPrazoTabelaPrecoSim_" + countImportacaoLote, });
    _lblCalcularPrazoTabelaPrecoSim.innerHTML = "&nbsp;Sim&nbsp;";

    var _lblCalcularPrazoTabelaPrecoNao = Builder.node("label", {id: "lblCalcularPrazoTabelaPrecoNao_" + countImportacaoLote, name: "lblCalcularPrazoTabelaPrecoNao_" + countImportacaoLote, });
    _lblCalcularPrazoTabelaPrecoNao.innerHTML = "&nbsp;Nao&nbsp;";
    
    var _lblConsiderarVolume = Builder.node("label", {id: "lblConsiderarVolumeTabela_" + countImportacaoLote, name: "lblConsiderarVolumeTabela_" + countImportacaoLote, });
    _lblConsiderarVolume.innerHTML = "Considerar o volume:";
    
    var _lblTagTransportadora = Builder.node("label", {id: "lblTagTransportadora_" + countImportacaoLote, name: "lblTagTransportadora_" + countImportacaoLote, });
    _lblTagTransportadora.innerHTML = "&nbsp;Da tag de transportadora&nbsp;";
    
    var _lblTagZeroTransportadora = Builder.node("label", {id: "lblTagTransportadora_" + countImportacaoLote, name: "lblTagTransportadora_" + countImportacaoLote, });
    _lblTagZeroTransportadora.innerHTML = "&nbsp;Se a tag transportadora vier zero então carregar a quantidade total dos produtos&nbsp;";

    //***************LABEL**********************

    //***************DIV************************
    var _divLayoutPrincipal = Builder.node("div", {id: "divLayoutPrincipal_" + countImportacaoLote, name: "divLayoutPrincipal_" + countImportacaoLote, align: "center"});
    var _divImportacao = Builder.node("div", {id: "divImportacao_" + countImportacaoLote, name: "divImportacao_" + countImportacaoLote, align: "center"});
    var _divLayout = Builder.node("div", {id: "divLayout_" + countImportacaoLote, name: "divLayout_" + countImportacaoLote, align: "right"});
    var _divRedespacho = Builder.node("div", {id: "divRedespacho_" + countImportacaoLote, name: "divRedespacho_" + countImportacaoLote, align: "right"});
    var _divRedespachoLocaliza = Builder.node("div", {id: "divRedespachoLocaliza_" + countImportacaoLote, name: "divRedespachoLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divDestinatario = Builder.node("div", {id: "divDestinatario_" + countImportacaoLote, name: "divDestinatario_" + countImportacaoLote, align: "right"});
    var _divDestintarioLocaliza = Builder.node("div", {id: "divDestinatarioLocaliza_" + countImportacaoLote, name: "divDestinatarioLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divRemetente = Builder.node("div", {id: "divRemetente_" + countImportacaoLote, name: "divRemetente_" + countImportacaoLote, align: "right"});
    var _divRemetenteLocaliza = Builder.node("div", {id: "divRemetenteLocaliza_" + countImportacaoLote, name: "divRemetenteLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divConsignatario = Builder.node("div", {id: "divConsignatario_" + countImportacaoLote, name: "divConsignatario_" + countImportacaoLote, align: "right"});
    var _divConsignatarioLocaliza = Builder.node("div", {id: "divConsignatarioLocaliza_" + countImportacaoLote, name: "divConsingatarioLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divRepresentante = Builder.node("div", {id: "divRepresentante_" + countImportacaoLote, name: "divRepresentante_" + countImportacaoLote, align: "right"});
    var _divRepresentanteLocaliza = Builder.node("div", {id: "divRepresentanteLocaliza_" + countImportacaoLote, name: "divRepresentanteLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divRecebedor = Builder.node("div", {id: "divRecebedor_" + countImportacaoLote, name: "divRecebedor_" + countImportacaoLote, align: "right"});
    var _divRecebedorLocaliza = Builder.node("div", {id: "divRecebedorLocaliza_" + countImportacaoLote, name: "divRecebedorLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divExpedidor = Builder.node("div", {id: "divExpedidor_" + countImportacaoLote, name: "divExpedidor_" + countImportacaoLote, align: "right"});
    var _divExpedidorLocaliza = Builder.node("div", {id: "divExpedidorLocaliza_" + countImportacaoLote, name: "divExpedidorLocaliza_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divConsiderarFrete = Builder.node("div", {id: "divConsiderarFrete_" + countImportacaoLote, name: "divConsiderarFrete_" + countImportacaoLote, align: "right"});
    var _divNotaFiscal = Builder.node("div", {id: "divNotaFiscal_" + countImportacaoLote, name: "divNotaFiscal_" + countImportacaoLote, align: "right"});
    var _divUfDestino = Builder.node("div", {id: "divUfDestino_" + countImportacaoLote, name: "divUfDestino_" + countImportacaoLote, align: "right"});
    var _divPedido = Builder.node("div", {id: "divPedido_" + countImportacaoLote, name: "divPedido_" + countImportacaoLote, align: "right"});
    var _divCliente = Builder.node("div", {id: "divCliente_" + countImportacaoLote, name: "divCliente_" + countImportacaoLote, align: "right"});
    var _divFilial = Builder.node("div", {id: "divFilial_" + countImportacaoLote, name: "divFilial_" + countImportacaoLote, align: "right"});
    var _divVeiculo = Builder.node("div", {id: "divVeiculo_" + countImportacaoLote, name: "divVeiculo_" + countImportacaoLote, align: "right"});
    var _divMercadoria = Builder.node("div", {id: "divMercadoria_" + countImportacaoLote, name: "divMercadoria_" + countImportacaoLote, align: "right"});
    var _divItemNota = Builder.node("div", {id: "divItemNota_" + countImportacaoLote, name: "divItemNota_" + countImportacaoLote, align: "right"});
    var _divCadDestinatario = Builder.node("div", {id: "divCadDestinatario_" + countImportacaoLote, name: "divCadDestinatario_" + countImportacaoLote, align: "right"});
    var _divCadDestinatarioTabela = Builder.node("div", {id: "divCadDestinatarioTabela_" + countImportacaoLote, name: "divCadDestinatarioTabela_" + countImportacaoLote, align: "right"});
    var _divCadDestinatarioUtiliza = Builder.node("div", {id: "divCadDestinatarioUtiliza_" + countImportacaoLote, name: "divCadDestinatarioUtiliza_" + countImportacaoLote, align: "right"});
    var _divCadDestinatarioTipoTabela = Builder.node("div", {id: "divCadDestinatarioTipoTabela_" + countImportacaoLote, name: "divCadDestinatarioTipoTabela_" + countImportacaoLote, align: "left"});
    var _divCadDestinatarioTabelaRemetente = Builder.node("div", {id: "divCadDestinatarioTabelaRemetente_" + countImportacaoLote, name: "divCadDestinatarioTabelaRemetente_" + countImportacaoLote, align: "left"});
    var _divAgruparPorVeiculo = Builder.node("div", {id: "divAgruparPorVeiculo_" + countImportacaoLote, name: "divAgruparPorVeiculo_" + countImportacaoLote, align: "right"});
    var _divLblLayoutRemetente = Builder.node("div", {id: "divLblLayoutRemetente_" + countImportacaoLote, name: "divLblLayoutRemetente_" + countImportacaoLote, align: "right"});
    var _divSubContratacao = Builder.node("div", {id: "divSubContratacao_" + countImportacaoLote, name: "divSubContratacao_" + countImportacaoLote, align: "right"});
    var _divBasePadraoCubagem = Builder.node("div", {id: "divBasePadraoCubagem_" + countImportacaoLote, name: "divBasePadraoCubagem_" + countImportacaoLote, align: "right"});
    var _divBasePadraoCubagemAereo = Builder.node("div", {id: "divBasePadraoCubagemAereo_" + countImportacaoLote, name: "divBasePadraoCubagemAereo_" + countImportacaoLote, align: "right"});
    var _divCadRemetente = Builder.node("div", {id: "divCadRemetente_" + countImportacaoLote, name: "divCadRemetente_" + countImportacaoLote, align: "right"});
    var _divAtualizaEndDestinatario = Builder.node("div", {id: "divAtualizaEndDestinatario_" + countImportacaoLote, name: "divAtualizaEndDestinatario_" + countImportacaoLote, align: "right"});
    var _divResponsavel = Builder.node("div", {id: "divResponsavel_" + countImportacaoLote, name: "divResponsavel_" + countImportacaoLote, align: "right"});
    var _divResponsavelRadio = Builder.node("div", {id: "divResponsavelRadio_" + countImportacaoLote, name: "divResponsavelRadio_" + countImportacaoLote, align: "left", style: "display: none"});
    var _divCalcularPrazoTabelaPreco = Builder.node("div", {id: "divCalcularPrazoTabelaPreco_" + countImportacaoLote, name: "divCalcularPrazoTabelaPreco_" + countImportacaoLote, align: "right"});
    var _divConsiderarVolume = Builder.node("div", {id: "divConsiderarVolumeTabela_" + countImportacaoLote, name: "divConsiderarVolumeTabela_" + countImportacaoLote, align: "right"});

    //***************DIV************************

    //***************SELECT*********************
    var _slcLayout = Builder.node("select", {
        id: "slcLayout_" + countImportacaoLote,
        name: "slcLayout_" + countImportacaoLote,
        className: "inputtexto",
        style: "width:200px",
        onchange: "criterioLayout(this.value," + countImportacaoLote + ");criterioLayoutLimparCampos(" + countImportacaoLote + ");"
    });

    povoarSelect(_slcLayout, listaNotfisAutomaticas);

    var _slcTipoTabela = Builder.node("select", {
        id: "slcTipoTabela_" + countImportacaoLote,
        name: "slcTipoTabela_" + countImportacaoLote,
        className: "inputtexto",
        style: "width:100px"
    });

    povoarSelect(_slcTipoTabela, listaTipoTabelaAutomaticas);
    
    _slcLayout.value = importacaoLote.codigoLayoutEdi;

    var _slcTabelaRemetente = Builder.node("select", {
        id: "slcTipoTabelaRemetente_" + countImportacaoLote,
        name: "slcTipoTabelaRemetente_" + countImportacaoLote,
        className: "inputtexto",
        style: "width:100px"
    });

    povoarSelect(_slcTabelaRemetente, listaTabelaRemAutomaticas);

    //***************SELECT*********************

    //***************INPUT**********************
    var _inpHidIdLayoutEdi = Builder.node("input", {
        id: "inpHidIdLayoutEdi_" + countImportacaoLote,
        name: "inpHidIdLayoutEdi_" + countImportacaoLote,
        type: "hidden",
        className: "inputtexto",
        value: importacaoLote.idLayoutEdi
    });

    var _inpChkRedespacho = Builder.node("input", {
        id: "chkRedespacho_" + countImportacaoLote,
        name: "chkRedespacho_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaRedespacho(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirRedespacho == "true") {
        _inpChkRedespacho.checked = true;
    }

    var _inpLocalizaRedespacho = Builder.node("input", {
        id: "LocalizaRedespacho_" + countImportacaoLote,
        name: "LocalizaRedespacho_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeRedespacho == "null" ? "" : importacaoLote.nomeRedespacho)
    });

    var _inpHidLocalizaIdRedespacho = Builder.node("input", {
        id: "LocalizaIdRedespacho_" + countImportacaoLote,
        name: "LocalizaIdRedespacho_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idRedespacho
    });

    var _inpBtnLocalizaIdRedespacho = Builder.node("input", {
        id: "LocalizaBtnRedespacho_" + countImportacaoLote,
        name: "LocalizaBtnRedespacho_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaRedespacho(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaRedespacho = Builder.node("img", {
        id: "imgBorrachaRedespacho_" + countImportacaoLote,
        name: "imgBorrachaRedespacho_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaRedespacho(" + countImportacaoLote + ");"
    });

    var _inpChkDestinatario = Builder.node("input", {
        id: "chkDestinatario_" + countImportacaoLote,
        name: "chkDestinatario_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaDestinatario(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirDestinatario == "true") {
        _inpChkDestinatario.checked = true;
    }

    var _inpLocalizaDestinatario = Builder.node("input", {
        id: "LocalizaDestinatario_" + countImportacaoLote,
        name: "LocalizaDestinatario_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeDestinatario == "null" ? "" : importacaoLote.nomeDestinatario)
    });

    var _inpHidLocalizaIdDestinatario = Builder.node("input", {
        id: "LocalizaIdDestinatario_" + countImportacaoLote,
        name: "LocalizaIdDestinatario_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idDestinatario
    });

    var _inpBtnLocalizaIdDestinatario = Builder.node("input", {
        id: "LocalizaBtnDestinatario_" + countImportacaoLote,
        name: "LocalizaBtnDestinatario_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaDestinatario(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaDestinatario = Builder.node("img", {
        id: "imgBorrachaDestinatario_" + countImportacaoLote,
        name: "imgBorrachaDestinatario_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaDestinatario(" + countImportacaoLote + ");"
    });

    var _inpChkRemetente = Builder.node("input", {
        id: "chkRemetente_" + countImportacaoLote,
        name: "chkRemetente_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaRemetente(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirRemetente == "true") {
        _inpChkRemetente.checked = true;
    }

    var _inpLocalizaRemetente = Builder.node("input", {
        id: "LocalizaRemetente_" + countImportacaoLote,
        name: "LocalizaRemetente_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeRemetente == "null" ? "" : importacaoLote.nomeRemetente)
    });

    var _inpHidLocalizaIdRemetente = Builder.node("input", {
        id: "LocalizaIdRemetente_" + countImportacaoLote,
        name: "LocalizaIdRemetente_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idRemetente
    });

    var _inpBtnLocalizaIdRemetente = Builder.node("input", {
        id: "LocalizaBtnRemetente_" + countImportacaoLote,
        name: "LocalizaBtnRemetente_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaRemetente(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaRemetente = Builder.node("img", {
        id: "imgBorrachaRemetente_" + countImportacaoLote,
        name: "imgBorrachaRemetente_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaRemetente(" + countImportacaoLote + ");"
    });

    var _inpChkConsignatario = Builder.node("input", {
        id: "chkConsignatario_" + countImportacaoLote,
        name: "chkConsignatario_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaConsignatario(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirConsignatario == "true") {
        _inpChkConsignatario.checked = true;
    }

    var _inpLocalizaConsignatario = Builder.node("input", {
        id: "LocalizaConsignatario_" + countImportacaoLote,
        name: "LocalizaConsignatario_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeConsignatario == "null" ? "" : importacaoLote.nomeConsignatario)
    });

    var _inpHidLocalizaIdConsignatario = Builder.node("input", {
        id: "LocalizaIdConsignatario_" + countImportacaoLote,
        name: "LocalizaIdConsignatario_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idConsignatario
    });

    var _inpBtnLocalizaIdConsignatario = Builder.node("input", {
        id: "LocalizaBtnConsignatario_" + countImportacaoLote,
        name: "LocalizaBtnConsignatario_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaConsignatario(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaConsignatario = Builder.node("img", {
        id: "imgBorrachaConsignatario_" + countImportacaoLote,
        name: "imgBorrachaConsignatario_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaConsignatario(" + countImportacaoLote + ");"
    });

    var _inpChkRepresentante = Builder.node("input", {
        id: "chkRepresentante_" + countImportacaoLote,
        name: "chkRepresentante_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaRepresentante(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirRepresentante == "true") {
        _inpChkRepresentante.checked = true;
    }

    var _inpLocalizaRepresentante = Builder.node("input", {
        id: "LocalizaRepresentante_" + countImportacaoLote,
        name: "LocalizaRepresentante_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeRepresentante == "null" ? "" : importacaoLote.nomeRepresentante)
    });

    var _inpHidLocalizaIdRepresentante = Builder.node("input", {
        id: "LocalizaIdRepresentante_" + countImportacaoLote,
        name: "LocalizaIdRepresentante_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idRepresentante
    });

    var _inpBtnLocalizaIdRepresentante = Builder.node("input", {
        id: "LocalizaBtnRepresentante_" + countImportacaoLote,
        name: "LocalizaBtnRepresentante_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaRepresentante(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaRepresentante = Builder.node("img", {
        id: "imgBorrachaRepresentante_" + countImportacaoLote,
        name: "imgBorrachaRepresentante_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaRepresentante(" + countImportacaoLote + ");"
    });

    var _inpChkRecebedor = Builder.node("input", {
        id: "chkRecebedor_" + countImportacaoLote,
        name: "chkRecebedor_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaRecebedor(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirRecebedor == "true") {
        _inpChkRecebedor.checked = true;
    }

    var _inpLocalizaRecebedor = Builder.node("input", {
        id: "LocalizaRecebedor_" + countImportacaoLote,
        name: "LocalizaRecebedor_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeRecebedor == "null" ? "" : importacaoLote.nomeRecebedor)
    });

    var _inpHidLocalizaIdRecebedor = Builder.node("input", {
        id: "LocalizaIdRecebedor_" + countImportacaoLote,
        name: "LocalizaIdRecebedor_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idRecebedor
    });

    var _inpBtnLocalizaIdRecebedor = Builder.node("input", {
        id: "LocalizaBtnRecebedor_" + countImportacaoLote,
        name: "LocalizaBtnRecebedor_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaRecebedor(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaRecebedor = Builder.node("img", {
        id: "imgBorrachaRecebedor_" + countImportacaoLote,
        name: "imgBorrachaRecebedor_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaRecebedor(" + countImportacaoLote + ");"
    });

    var _inpChkExpedidor = Builder.node("input", {
        id: "chkExpedidor_" + countImportacaoLote,
        name: "chkExpedidor_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "javascript:mostrarLocalizaExpedidor(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirExpedidor == "true") {
        _inpChkExpedidor.checked = true;
    }

    var _inpLocalizaExpedidor = Builder.node("input", {
        id: "LocalizaExpedidor_" + countImportacaoLote,
        name: "LocalizaExpedidor_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: (importacaoLote.nomeExpedidor == "null" ? "" : importacaoLote.nomeExpedidor)
    });

    var _inpHidLocalizaIdExpedidor = Builder.node("input", {
        id: "LocalizaIdExpedidor_" + countImportacaoLote,
        name: "LocalizaIdExpedidor_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idExpedidor
    });

    var _inpBtnLocalizaIdExpedidor = Builder.node("input", {
        id: "LocalizaBtnExpedidor_" + countImportacaoLote,
        name: "LocalizaBtnExpedidor_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLocalizaExpedidor(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorracaExpedidor = Builder.node("img", {
        id: "imgBorracaExpedidor_" + countImportacaoLote,
        name: "imgBorracaExpedidor_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaExpedidor(" + countImportacaoLote + ");"
    });

    var _inpRadTabela = Builder.node("input", {
        id: "inpRadTabelaArquivoT_" + countImportacaoLote,
        name: "inpRadTabelaArquivo_" + countImportacaoLote,
        type: "radio",
        value: "t"
    });


    var _inpRadArquivo = Builder.node("input", {
        id: "inpRadTabelaArquivoA_" + countImportacaoLote,
        name: "inpRadTabelaArquivo_" + countImportacaoLote,
        type: "radio",
        value: "a"
    });

    if (importacaoLote.considerarFrete == "t") {
        _inpRadTabela.checked = true;
    } else if (importacaoLote.considerarFrete == "a") {
        _inpRadArquivo.checked = true;
    } else {
        _inpRadTabela.checked = true;
    }

    var _inpRadNotaFiscalSim = Builder.node("input", {
        id: "inpRadNotaFiscalSim_" + countImportacaoLote,
        name: "inpRadNotaFiscal_" + countImportacaoLote,
        type: "radio",
        value: "s",
        onclick: "javascript:validaRadioUF(" + countImportacaoLote + ");mostrarFiltroPedido(" + countImportacaoLote + ");"
    });

    var _inpRadNotaFiscalNao = Builder.node("input", {
        id: "inpRadNotaFiscalNao_" + countImportacaoLote,
        name: "inpRadNotaFiscal_" + countImportacaoLote,
        type: "radio",
        value: "n",
        onclick: "javascript:validaRadioUF(" + countImportacaoLote + ");mostrarFiltroPedido(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAgruparNFRemDest == "true") {
        _inpRadNotaFiscalSim.checked = true;
    } else if (importacaoLote.isAgruparNFRemDest == "false") {
        _inpRadNotaFiscalNao.checked = true;
    } else {
        _inpRadNotaFiscalSim.checked = true;
    }
    
    var _inpRadUfDestinoSim = Builder.node("input", {
        id: "inpRadUfDestinoSim_" + countImportacaoLote,
        name: "inpRadUfDestino_" + countImportacaoLote,
        type: "radio",
        value: "s",
        onclick: "javascript:validaRadioNF(" + countImportacaoLote + ");"
    });

    var _inpRadUfDestinoNao = Builder.node("input", {
        id: "inpRadUfDestinoNao_" + countImportacaoLote,
        name: "inpRadUfDestino_" + countImportacaoLote,
        type: "radio",
        value: "n",
        onclick: "javascript:validaRadioNF(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAgruparNfUfDestino == "true") {
        _inpRadUfDestinoSim.checked = true;
    } else if (importacaoLote.isAgruparNfUfDestino == "false") {
        _inpRadUfDestinoNao.checked = true;
    } else {
        _inpRadUfDestinoNao.checked = true;
    }

    var _inpRadPedidoSim = Builder.node("input", {
        id: "inpRadPedidoSim_" + countImportacaoLote,
        name: "inpRadPedido_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadPedidoNao = Builder.node("input", {
        id: "inpRadPedidoNao_" + countImportacaoLote,
        name: "inpRadPedido_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isAgruparNfNumeroPedido == "true") {
        _inpRadPedidoSim.checked = true;
    } else if (importacaoLote.isAgruparNfNumeroPedido == "false") {
        _inpRadPedidoNao.checked = true;
    } else {
        _inpRadPedidoNao.checked = true;
    }

    var _inpRadClienteSim = Builder.node("input", {
        id: "inpRadClienteSim_" + countImportacaoLote,
        name: "inpRadCliente_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadClienteNao = Builder.node("input", {
        id: "inpRadClienteNao_" + countImportacaoLote,
        name: "inpRadCliente_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isConsiderarGrupoCliProd == "true") {
        _inpRadClienteSim.checked = true;
    } else if (importacaoLote.isConsiderarGrupoCliProd == "false") {
        _inpRadClienteNao.checked = true;
    } else {
        _inpRadClienteSim.checked = true;
    }

    var _inpRadFilialSim = Builder.node("input", {
        id: "inpRadFilialSim_" + countImportacaoLote,
        name: "inpRadFilial_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadFilialNao = Builder.node("input", {
        id: "inpRadFilialNao_" + countImportacaoLote,
        name: "inpRadFilial_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isImportarFilialSelecionada == "true") {
        _inpRadFilialSim.checked = true;
    } else if (importacaoLote.isImportarFilialSelecionada == "false") {
        _inpRadFilialNao.checked = true;
    } else {
        _inpRadFilialNao.checked = true;
    }

    var _inpRadVeiculoSim = Builder.node("input", {
        id: "inpRadVeiculoSim_" + countImportacaoLote,
        name: "inpRadVeiculo_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadVeiculoNao = Builder.node("input", {
        id: "inpRadVeiculoNao_" + countImportacaoLote,
        name: "inpRadVeiculo_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isUtilizarDadosVeiculo == "true") {
        _inpRadVeiculoSim.checked = true;
    } else if (importacaoLote.isUtilizarDadosVeiculo == "false") {
        _inpRadVeiculoNao.checked = true;
    } else {
        _inpRadVeiculoNao.checked = true;
    }

    var _inpRadMercadoriaSim = Builder.node("input", {
        id: "inpRadMercadoriaSim_" + countImportacaoLote,
        name: "inpRadMercadoria_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadMercadoriaNao = Builder.node("input", {
        id: "inpRadMercadoriaNao_" + countImportacaoLote,
        name: "inpRadMercadoria_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isCadastrarMercadoria == "true") {
        _inpRadMercadoriaSim.checked = true;
    } else if (importacaoLote.isCadastrarMercadoria == "false") {
        _inpRadMercadoriaNao.checked = true;
    } else {
        _inpRadMercadoriaNao.checked = true;
    }

    var _inpRadItemNotaSim = Builder.node("input", {
        id: "inpRadItemNotaSim_" + countImportacaoLote,
        name: "inpRadItemNota_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadItemNotaNao = Builder.node("input", {
        id: "inpRadItemNotaNao_" + countImportacaoLote,
        name: "inpRadItemNota_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isImportarItemNf == "true") {
        _inpRadItemNotaSim.checked = true;
    } else if (importacaoLote.isImportarItemNf == "false") {
        _inpRadItemNotaNao.checked = true;
    } else {
        _inpRadItemNotaNao.checked = true;
    }

    var _inpRadCadDestinatarioSim = Builder.node("input", {
        id: "inpRadCadDestinatarioSim_" + countImportacaoLote,
        name: "inpRadCadDestinatario_" + countImportacaoLote,
        type: "radio",
        value: "s",
        onclick: "javascript:tryRequestToServer(function(){escondeMostraAtualizarDestinatario(" + countImportacaoLote + ")});"
    });

    var _inpRadCadDestinatarioNao = Builder.node("input", {
        id: "inpRadCadDestinatarioNao_" + countImportacaoLote,
        name: "inpRadCadDestinatario_" + countImportacaoLote,
        type: "radio",
        value: "n",
        onclick: "javascript:tryRequestToServer(function(){escondeMostraAtualizarDestinatario(" + countImportacaoLote + ")});"
    });
    
    var _inpTagTransportadora = Builder.node("input", {
        id: "inpTagTransportadora_" + countImportacaoLote,
        name: "inpTag_" + countImportacaoLote,
        type: "radio",
        value:"1"
    });
    
    var _inpTagZeroTransportadora = Builder.node("input", {
        id: "inpTagZeroTransportadora_" + countImportacaoLote,
        name: "inpTag_" + countImportacaoLote,
        type: "radio",
        value:"2"
    });
    
    if (importacaoLote.considerarVolume == "1") {
        _inpTagTransportadora.checked = true;
    } else if (importacaoLote.considerarVolume == "2") {
        _inpTagZeroTransportadora.checked = true;
    }

    if (importacaoLote.isAtualizarDestinatario == "true") {
        _inpRadCadDestinatarioSim.checked = true;
    } else if (importacaoLote.isImportarItemNf == "false") {
        _inpRadCadDestinatarioNao.checked = true;
    } else {
        _inpRadCadDestinatarioNao.checked = true;
    }


    var _inpRadCadRemetenteSim = Builder.node("input", {
        id: "inpRadCadRemetenteSim_" + countImportacaoLote,
        name: "inpRadCadRemetente_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadCadRemetenteNao = Builder.node("input", {
        id: "inpRadCadRemetenteNao_" + countImportacaoLote,
        name: "inpRadCadRemetente_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isAtualizarRemetente == "true") {
        _inpRadCadRemetenteSim.checked = true;
    } else {
        _inpRadCadRemetenteNao.checked = true;
    }

    var _inpRadAtualizaEndDestinatarioSim = Builder.node("input", {
        id: "inpRadAtualizaEndDestinatarioSim_" + countImportacaoLote,
        name: "inpRadAtualizaEndDestinatario_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpRadAtualizaEndDestinatarioNao = Builder.node("input", {
        id: "inpRadAtualizaEndDestinatarioNao_" + countImportacaoLote,
        name: "inpRadAtualizaEndDestinatario_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isAtualizarEndDestinario == "true") {
        _inpRadAtualizaEndDestinatarioSim.checked = true;
    } else {
        _inpRadAtualizaEndDestinatarioNao.checked = true;
    }

    var _inpAgruparPorVeiculoSim = Builder.node("input", {
        id: "inpAgruparPorVeiculoSim_" + countImportacaoLote,
        name: "inpAgruparPorVeiculo_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpAgruparPorVeiculoNao = Builder.node("input", {
        id: "inpAgruparPorVeiculoNao_" + countImportacaoLote,
        name: "inpAgruparPorVeiculo_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if (importacaoLote.isAgruparPorVeiculo == "true") {
        _inpAgruparPorVeiculoSim.checked = true;
    } else if (importacaoLote.isAgruparPorVeiculo == "false") {
        _inpAgruparPorVeiculoNao.checked = true;
    } else {
        _inpAgruparPorVeiculoNao.checked = true;
    }

    var _inpExcluirImportacaoLote = Builder.node("img", {
        id: "inpExcluirImportacaoLote_" + countImportacaoLote,
        name: "inpExcluirImportacaoLote_" + countImportacaoLote,
        type: "button",
        className: "imagemLink",
        src: "img/lixo.png",
        onclick: "javascript:tryRequestToServer(function(){excluirImportacaoLote(" + countImportacaoLote + ")});"
    });

    var _inpLayoutRemetente = Builder.node("input", {
        id: "layoutRemetente_" + countImportacaoLote,
        name: "layoutRemetente_" + countImportacaoLote,
        type: "text",
        className: "inputReadOnly",
        size: "50",
        readonly: "true",
        value: importacaoLote.nomeRemetenteNf
    });

    var _inpHidLayoutIdRemetente = Builder.node("input", {
        id: "layoutIdRemetente_" + countImportacaoLote,
        name: "layoutIdRemetente_" + countImportacaoLote,
        type: "hidden",
        value: importacaoLote.idRemetenteNf
    });

    var _inpBtnLocalizaRemetente = Builder.node("input", {
        id: "layoutBtnRemetente_" + countImportacaoLote,
        name: "layoutBtnRemetente_" + countImportacaoLote,
        type: "button",
        className: "botoes",
        value: "...",
        onclick: "tryRequestToServer(function(){abrirLayoutRemetente(" + countImportacaoLote + ");})"
    });

    var _imgBtnBorrachaLayoutRemetente = Builder.node("img", {
        id: "imgBorrachaLayoutRemetente_" + countImportacaoLote,
        name: "imgBorrachaLayoutRemetente_" + countImportacaoLote,
        className: "imagemLink",
        src: "img/borracha.gif",
        onclick: "limparBorrachaLayoutRemetente(" + countImportacaoLote + ");"
    });

    var _inpSubContratacaoSim = Builder.node("input", {
        id: "inpSubContratacaoSim_" + countImportacaoLote,
        name: "inpSubContratacao_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpSubContratacaoNao = Builder.node("input", {
        id: "inpSubContratacaoNao_" + countImportacaoLote,
        name: "inpSubContratacao_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    var _inpBasePadraoCubagem = Builder.node("input", {
        id: "inpBasePadraoCubagem_" + countImportacaoLote,
        name: "inpBasePadraoCubagem_" + countImportacaoLote,
        className: "inputtexto",
        maxlength: "10",
        size: "10",
        type: "text",
        value: importacaoLote.basePadraoCubagem
    });

    var _inpBasePadraoCubagemAereo = Builder.node("input", {
        id: "inpBasePadraoCubagemAereo_" + countImportacaoLote,
        name: "inpBasePadraoCubagemAereo_" + countImportacaoLote,
        className: "inputtexto",
        maxlength: "10",
        size: "10",
        type: "text",
        value: importacaoLote.basePadraoCubagemAereo
    });

    if (importacaoLote.isSubContratacao == "true") {
        _inpSubContratacaoSim.checked = true;
    } else if (importacaoLote.isSubContratacao == "false") {
        _inpSubContratacaoNao.checked = true;
    } else {
        _inpSubContratacaoNao.checked = true;
    }

    var _inpChkResponsavel = Builder.node("input", {
        id: "chkResponsavel_" + countImportacaoLote,
        name: "chkResponsavel_" + countImportacaoLote,
        type: "checkbox",
        className: "inputtexto",
        value: "true",
        onclick: "mostrarRadioResponsavel(" + countImportacaoLote + ");"
    });

    if (importacaoLote.isAtribuirResponsavelPagamento == "true") {
        _inpChkResponsavel.checked = true;
        _divResponsavelRadio.style.display = "";
    }

    var _inpRadResponsavelCIF = Builder.node("input", {
        id: "inpRadResponsavel_" + countImportacaoLote,
        name: "inpRadResponsavel_" + countImportacaoLote,
        type: "radio",
        value: "0"
    });

    var _inpRadResponsavelFOB = Builder.node("input", {
        id: "inpRadResponsavelFOB_" + countImportacaoLote,
        name: "inpRadResponsavel_" + countImportacaoLote,
        type: "radio",
        value: "1"
    });

    var _inpRadResponsavelTerceiro = Builder.node("input", {
        id: "inpRadResponsavelTerceiro_" + countImportacaoLote,
        name: "inpRadResponsavel_" + countImportacaoLote,
        type: "radio",
        value: "2"
    });

    if (importacaoLote.tipoResponsavelPagamento == "0") {
        _inpRadResponsavelCIF.checked = true;
    } else if (importacaoLote.tipoResponsavelPagamento == "1") {
        _inpRadResponsavelFOB.checked = true;
    } else if (importacaoLote.tipoResponsavelPagamento == "2") {
        _inpRadResponsavelTerceiro.checked = true;
    } else {
        _inpRadResponsavelCIF.checked = true;
    }

    var _inpCalcularPrazoTabelaPrecoSim = Builder.node("input", {
        id: "inpCalcularPrazoTabelaPrecoSim_" + countImportacaoLote,
        name: "inpCalcularPrazoTabelaPreco_" + countImportacaoLote,
        type: "radio",
        value: "s"
    });

    var _inpCalcularPrazoTabelaPrecoNao = Builder.node("input", {
        id: "inpCalcularPrazoTabelaPrecoNao_" + countImportacaoLote,
        name: "inpCalcularPrazoTabelaPreco_" + countImportacaoLote,
        type: "radio",
        value: "n"
    });

    if(importacaoLote.isCalcularPrazoTabelaPreco == true || importacaoLote.isCalcularPrazoTabelaPreco == 'true'){
        _inpCalcularPrazoTabelaPrecoSim.checked = true;
    }else{
         _inpCalcularPrazoTabelaPrecoNao.checked = true;
    }

    //*****************INPUT*******************

    //******************DIV********************
    _divLayoutPrincipal.appendChild(_lblLayoutPrincipal);
    _divLayout.appendChild(_lblLayout);
    _divLblLayoutRemetente.appendChild(_lblLayoutRemetente);
    _divImportacao.appendChild(_lblImportacao);
    _divRedespacho.appendChild(_inpChkRedespacho);
    _divRedespacho.appendChild(_lblRedespacho);
    _divRedespachoLocaliza.appendChild(_inpLocalizaRedespacho);
    _divRedespachoLocaliza.appendChild(_inpHidLocalizaIdRedespacho);
    _divRedespachoLocaliza.appendChild(_lblEspacoRedespacho);
    _divRedespachoLocaliza.appendChild(_inpBtnLocalizaIdRedespacho);
    _divRedespachoLocaliza.appendChild(_lblEspacoRedespachoBorracha);
    _divRedespachoLocaliza.appendChild(_imgBtnBorrachaRedespacho);
    _divDestinatario.appendChild(_inpChkDestinatario);
    _divDestinatario.appendChild(_lblDestinatario);
    _divDestintarioLocaliza.appendChild(_inpLocalizaDestinatario);
    _divDestintarioLocaliza.appendChild(_inpHidLocalizaIdDestinatario);
    _divDestintarioLocaliza.appendChild(_lblEspacoDestinatario);
    _divDestintarioLocaliza.appendChild(_inpBtnLocalizaIdDestinatario);
    _divDestintarioLocaliza.appendChild(_lblEspacoDestinatarioBorracha);
    _divDestintarioLocaliza.appendChild(_imgBtnBorrachaDestinatario);
    _divRemetente.appendChild(_inpChkRemetente);
    _divRemetente.appendChild(_lblRemetente);
    _divRemetenteLocaliza.appendChild(_inpLocalizaRemetente);
    _divRemetenteLocaliza.appendChild(_inpHidLocalizaIdRemetente);
    _divRemetenteLocaliza.appendChild(_lblEspacoRemetente);
    _divRemetenteLocaliza.appendChild(_inpBtnLocalizaIdRemetente);
    _divRemetenteLocaliza.appendChild(_lblEspacoRemetenteBorracha);
    _divRemetenteLocaliza.appendChild(_imgBtnBorrachaRemetente);
    _divConsignatario.appendChild(_inpChkConsignatario);
    _divConsignatario.appendChild(_lblConsignatario);
    _divConsignatarioLocaliza.appendChild(_inpLocalizaConsignatario);
    _divConsignatarioLocaliza.appendChild(_inpHidLocalizaIdConsignatario);
    _divConsignatarioLocaliza.appendChild(_lblEspacoConsignatario);
    _divConsignatarioLocaliza.appendChild(_inpBtnLocalizaIdConsignatario);
    _divConsignatarioLocaliza.appendChild(_lblEspacoConsignatarioBorracha);
    _divConsignatarioLocaliza.appendChild(_imgBtnBorrachaConsignatario);
    _divRepresentante.appendChild(_inpChkRepresentante);
    _divRepresentante.appendChild(_lblRepresentante);
    _divRepresentanteLocaliza.appendChild(_inpLocalizaRepresentante);
    _divRepresentanteLocaliza.appendChild(_inpHidLocalizaIdRepresentante);
    _divRepresentanteLocaliza.appendChild(_lblEspacoRepresentante);
    _divRepresentanteLocaliza.appendChild(_inpBtnLocalizaIdRepresentante);
    _divRepresentanteLocaliza.appendChild(_lblEspacoRepresentanteBorracha);
    _divRepresentanteLocaliza.appendChild(_imgBtnBorrachaRepresentante);
    _divRecebedor.appendChild(_inpChkRecebedor);
    _divRecebedor.appendChild(_lblRecebedor);
    _divRecebedorLocaliza.appendChild(_inpLocalizaRecebedor);
    _divRecebedorLocaliza.appendChild(_inpHidLocalizaIdRecebedor);
    _divRecebedorLocaliza.appendChild(_lblEspacoRecebedor);
    _divRecebedorLocaliza.appendChild(_inpBtnLocalizaIdRecebedor);
    _divRecebedorLocaliza.appendChild(_lblEspacoRecebedorBorracha);
    _divRecebedorLocaliza.appendChild(_imgBtnBorrachaRecebedor);
    _divExpedidor.appendChild(_inpChkExpedidor);
    _divExpedidor.appendChild(_lblExpedidor);
    _divExpedidorLocaliza.appendChild(_inpLocalizaExpedidor);
    _divExpedidorLocaliza.appendChild(_inpHidLocalizaIdExpedidor);
    _divExpedidorLocaliza.appendChild(_lblEspacoExpedidor);
    _divExpedidorLocaliza.appendChild(_inpBtnLocalizaIdExpedidor);
    _divExpedidorLocaliza.appendChild(_lblEspacoExpedidorBorracha);
    _divExpedidorLocaliza.appendChild(_imgBtnBorracaExpedidor);
    _divConsiderarFrete.appendChild(_lblConsiderarFrete);
    _divNotaFiscal.appendChild(_lblNotaFiscal);
    _divUfDestino.appendChild(_lblUfDestino);
    _divPedido.appendChild(_lblPedido);
    _divCliente.appendChild(_lblCliente);
    _divFilial.appendChild(_lblFilial);
    _divVeiculo.appendChild(_lblVeiculo);
    _divMercadoria.appendChild(_lblMercadoria);
    _divItemNota.appendChild(_lblItemNota);
    _divCadDestinatario.appendChild(_lblCadDestinatario);
    _divCadDestinatarioTabela.appendChild(_lblCadDestinatarioTabela);
    _divCadDestinatarioUtiliza.appendChild(_lblCadDestinatarioUtiliza);
    _divCadDestinatarioTipoTabela.appendChild(_lblCadDestinatarioTipoTabela);
    _divCadDestinatarioTipoTabela.appendChild(_slcTipoTabela);
    _divCadDestinatarioTabelaRemetente.appendChild(_lblCadDestinatarioTabelaRemetente);
    _divCadDestinatarioTabelaRemetente.appendChild(_slcTabelaRemetente);
    _divAgruparPorVeiculo.appendChild(_lblAgruparPorVeiculo);
    _divAgruparPorVeiculo.appendChild(_lblAgruparPorVeiculo);
    _divSubContratacao.appendChild(_lblSubContratacao);
    _divSubContratacao.appendChild(_lblSubContratacaoSim);
    _divSubContratacao.appendChild(_lblSubContratacaoNao);
    _divBasePadraoCubagem.appendChild(_lblBasePadraoCubagem);
    _divBasePadraoCubagemAereo.appendChild(_lblBasePadraoCubagemAereo);
    _divCadRemetente.appendChild(_lblCadRemetente);
    _divAtualizaEndDestinatario.appendChild(_lblAtualizaEndDestinatario);
    _divResponsavel.appendChild(_inpChkResponsavel);
    _divResponsavel.appendChild(_lblResponsavel);
    _divResponsavelRadio.appendChild(_inpRadResponsavelCIF);
    _divResponsavelRadio.appendChild(_lblResponsavelCIF);
    _divResponsavelRadio.appendChild(_inpRadResponsavelFOB);
    _divResponsavelRadio.appendChild(_lblResponsavelFOB);
    _divResponsavelRadio.appendChild(_inpRadResponsavelTerceiro);
    _divResponsavelRadio.appendChild(_lblResponsavelTerceiro);
    _divCalcularPrazoTabelaPreco.appendChild(_lblCalcularPrazoTabelaPreco);
    _divConsiderarVolume.appendChild(_lblConsiderarVolume);
    //******************DIV********************

    //******************TD*********************    
//    _tdLayoutPrincipal.appendChild(_inpExcluirImportacaoLote);
    _tdLayoutPrincipal.appendChild(_divLayoutPrincipal);
    _tdExcluir.appendChild(_inpExcluirImportacaoLote);
    _tdLayoutLbl.appendChild(_divLayout);
    _tdLayoutSlc.appendChild(_slcLayout);
    _tdLayoutSlc.appendChild(_inpHidIdLayoutEdi);
    _tdLayoutLblRemetente.appendChild(_divLblLayoutRemetente);
    _tdLayoutInpRemetente.appendChild(_inpLayoutRemetente);
    _tdLayoutInpRemetente.appendChild(_inpHidLayoutIdRemetente);
    _tdLayoutInpRemetente.appendChild(_lblEspacoLayoutRemetenteBtn);
    _tdLayoutInpRemetente.appendChild(_inpBtnLocalizaRemetente);
    _tdLayoutInpRemetente.appendChild(_lblEspacoLayoutRemetenteImg);
    _tdLayoutInpRemetente.appendChild(_imgBtnBorrachaLayoutRemetente);
    _tdImportPrincipal.appendChild(_divImportacao);

    //----------------REDESPACHO----------------
    _tdRedespacho.appendChild(_divRedespacho);
    _tdRedespachoLocaliza.appendChild(_divRedespachoLocaliza);
//    _tdRedespachoLocaliza.appendChild(_inpHidLocalizaIdRedespacho);
//    _tdRedespachoLocaliza.appendChild(_lblEspacoRedespacho);
//    _tdRedespachoLocaliza.appendChild(_inpBtnLocalizaIdRedespacho);
//    _tdRedespachoLocaliza.appendChild(_lblEspacoRedespachoBorracha);
//    _tdRedespachoLocaliza.appendChild(_imgBtnBorrachaRedespacho);
    //----------------REDESPACHO----------------

    //----------------DESTINATÁRIO--------------
    _tdDestinatario.appendChild(_divDestinatario);
    _tdDestinatarioLocaliza.appendChild(_divDestintarioLocaliza);
//    _tdDestinatarioLocaliza.appendChild(_inpLocalizaDestinatario);
//    _tdDestinatarioLocaliza.appendChild(_inpHidLocalizaIdDestinatario);
//    _tdDestinatarioLocaliza.appendChild(_lblEspacoDestinatario);
//    _tdDestinatarioLocaliza.appendChild(_inpBtnLocalizaIdDestinatario);
//    _tdDestinatarioLocaliza.appendChild(_lblEspacoDestinatarioBorracha);
//    _tdDestinatarioLocaliza.appendChild(_imgBtnBorrachaDestinatario);
    //----------------DESTINATÁRIO--------------

    //----------------REMETENTE-----------------
    _tdRemetente.appendChild(_divRemetente);
    _tdRemetenteLocaliza.appendChild(_divRemetenteLocaliza);
//    _tdRemetenteLocaliza.appendChild(_inpLocalizaRemetente);
//    _tdRemetenteLocaliza.appendChild(_inpHidLocalizaIdRemetente);
//    _tdRemetenteLocaliza.appendChild(_lblEspacoRemetente);
//    _tdRemetenteLocaliza.appendChild(_inpBtnLocalizaIdRemetente);
//    _tdRemetenteLocaliza.appendChild(_lblEspacoRemetenteBorracha);
//    _tdRemetenteLocaliza.appendChild(_imgBtnBorrachaRemetente);
    //----------------REMETENTE-----------------

    //----------------CONSIGNATARIO-------------
    _tdConsignatario.appendChild(_divConsignatario);
    _tdConsignatarioLocaliza.appendChild(_divConsignatarioLocaliza);
//    _tdConsignatarioLocaliza.appendChild(_inpLocalizaConsignatario);
//    _tdConsignatarioLocaliza.appendChild(_inpHidLocalizaIdConsignatario);
//    _tdConsignatarioLocaliza.appendChild(_lblEspacoConsignatario);
//    _tdConsignatarioLocaliza.appendChild(_inpBtnLocalizaIdConsignatario);
//    _tdConsignatarioLocaliza.appendChild(_lblEspacoConsignatarioBorracha);
//    _tdConsignatarioLocaliza.appendChild(_imgBtnBorrachaConsignatario);
    //----------------CONSIGNATARIO--------------

    //----------------REPRESENTANTE--------------
    _tdRepresentante.appendChild(_divRepresentante);
    _tdRepresentanteLocaliza.appendChild(_divRepresentanteLocaliza);
//    _tdRepresentanteLocaliza.appendChild(_inpLocalizaRepresentante);
//    _tdRepresentanteLocaliza.appendChild(_inpHidLocalizaIdRepresentante);
//    _tdRepresentanteLocaliza.appendChild(_lblEspacoRepresentante);
//    _tdRepresentanteLocaliza.appendChild(_inpBtnLocalizaIdRepresentante);
//    _tdRepresentanteLocaliza.appendChild(_lblEspacoRepresentanteBorracha);
//    _tdRepresentanteLocaliza.appendChild(_imgBtnBorrachaRepresentante);
    //----------------REPRESENTANTE--------------

    //----------------RECEBEDOR------------------
    _tdRecebedor.appendChild(_divRecebedor);
    _tdRecebedorLocaliza.appendChild(_divRecebedorLocaliza);
//    _tdRecebedorLocaliza.appendChild(_inpLocalizaRecebedor);
//    _tdRecebedorLocaliza.appendChild(_inpHidLocalizaIdRecebedor);
//    _tdRecebedorLocaliza.appendChild(_lblEspacoRecebedor);
//    _tdRecebedorLocaliza.appendChild(_inpBtnLocalizaIdRecebedor);
//    _tdRecebedorLocaliza.appendChild(_lblEspacoRecebedorBorracha);
//    _tdRecebedorLocaliza.appendChild(_imgBtnBorrachaRecebedor);
    //----------------RECEBEDOR------------------

    //----------------EXPEDIDOR------------------
    _tdExpedidor.appendChild(_divExpedidor);
    _tdExpedidorLocaliza.appendChild(_divExpedidorLocaliza);
//    _tdExpedidorLocaliza.appendChild(_inpLocalizaExpedidor);
//    _tdExpedidorLocaliza.appendChild(_inpHidLocalizaIdExpedidor);
//    _tdExpedidorLocaliza.appendChild(_lblEspacoExpedidor);
//    _tdExpedidorLocaliza.appendChild(_inpBtnLocalizaIdExpedidor);
//    _tdExpedidorLocaliza.appendChild(_lblEspacoExpedidorBorracha);
//    _tdExpedidorLocaliza.appendChild(_imgBtnBorracaExpedidor);
    //----------------RECEBEDOR------------------

    _tdConsiderarFrete.appendChild(_divConsiderarFrete);
    _tdTabelaArquivo.appendChild(_inpRadTabela);
    _tdTabelaArquivo.appendChild(_lblTabela);
    _tdTabelaArquivo.appendChild(_inpRadArquivo);
    _tdTabelaArquivo.appendChild(_lblArquivo);
    _tdNotaFiscal.appendChild(_divNotaFiscal);
    _tdNotaFiscalSimNao.appendChild(_inpRadNotaFiscalSim);
    _tdNotaFiscalSimNao.appendChild(_lblNotaFiscalSim);
    _tdNotaFiscalSimNao.appendChild(_inpRadNotaFiscalNao);
    _tdNotaFiscalSimNao.appendChild(_lblNotaFiscalNao);
    jQuery(_tdNotaFiscalSimNao).append(
        jQuery('<span>', {'id': 'spanAgruparNFeDataEmissao_' + countImportacaoLote})
            .append(jQuery('<input>', {
                'id': 'agruparNFeDataEmissao_' + countImportacaoLote,
                'name': 'agruparNFeDataEmissao_' + countImportacaoLote,
                'type': 'checkbox',
                'checked': (importacaoLote.agruparNFeEmissao ? 'checked' : '')
            })).append(jQuery('<label>', {'for': 'agruparNFeDataEmissao_' + countImportacaoLote}).text('Ao agrupar considerar as notas com a mesma data de emissão'))
    );
    
    if (importacaoLote.isAgruparNFRemDest == "false") {
        jQuery(_tdNotaFiscalSimNao).find('#spanAgruparNFeDataEmissao_' + countImportacaoLote).hide();
    }

    _tdUfDestino.appendChild(_divUfDestino);
    _tdUfDestinoSimNao.appendChild(_inpRadUfDestinoSim);
    _tdUfDestinoSimNao.appendChild(_lblUfDestinoSim);
    _tdUfDestinoSimNao.appendChild(_inpRadUfDestinoNao);
    _tdUfDestinoSimNao.appendChild(_lblUfDestinoNao);
    _tdPedido.appendChild(_divPedido);
    _tdPedidoSimNao.appendChild(_inpRadPedidoSim);
    _tdPedidoSimNao.appendChild(_lblPedidoSim);
    _tdPedidoSimNao.appendChild(_inpRadPedidoNao);
    _tdPedidoSimNao.appendChild(_lblPedidoNao);
    _tdCliente.appendChild(_divCliente);
    _tdClienteSimNao.appendChild(_inpRadClienteSim);
    _tdClienteSimNao.appendChild(_lblClienteSim);
    _tdClienteSimNao.appendChild(_inpRadClienteNao);
    _tdClienteSimNao.appendChild(_lblClienteNao);
    _tdFilial.appendChild(_divFilial);
    _tdFilialSimNao.appendChild(_inpRadFilialSim);
    _tdFilialSimNao.appendChild(_lblFilialSim);
    _tdFilialSimNao.appendChild(_inpRadFilialNao);
    _tdFilialSimNao.appendChild(_lblFilialNao);
    _tdVeiculo.appendChild(_divVeiculo);
    _tdVeiculoSimNao.appendChild(_inpRadVeiculoSim);
    _tdVeiculoSimNao.appendChild(_lblVeiculoSim);
    _tdVeiculoSimNao.appendChild(_inpRadVeiculoNao);
    _tdVeiculoSimNao.appendChild(_lblVeiculoNao);
    _tdMercadoria.appendChild(_divMercadoria);
    _tdMercadoriaSimNao.appendChild(_inpRadMercadoriaSim);
    _tdMercadoriaSimNao.appendChild(_lblMercadoriaSim);
    _tdMercadoriaSimNao.appendChild(_inpRadMercadoriaNao);
    _tdMercadoriaSimNao.appendChild(_lblMercadoriaNao);
    _tdItemNota.appendChild(_divItemNota);
    _tdItemNotaSimNao.appendChild(_inpRadItemNotaSim);
    _tdItemNotaSimNao.appendChild(_lblItemNotaSim);
    _tdItemNotaSimNao.appendChild(_inpRadItemNotaNao);
    _tdItemNotaSimNao.appendChild(_lblItemNotaNao);
    _tdCadDestinatario.appendChild(_divCadDestinatario);
    _tdCadDestinatarioSimNao.appendChild(_inpRadCadDestinatarioSim);
    _tdCadDestinatarioSimNao.appendChild(_lblCadDestinatarioSim);
    _tdCadDestinatarioSimNao.appendChild(_inpRadCadDestinatarioNao);
    _tdCadDestinatarioSimNao.appendChild(_lblCadDestinatarioNao);
    _tdCadDestinatarioTabela.appendChild(_divCadDestinatarioTabela);
    _tdCadDestinatarioTabela.appendChild(_divCadDestinatarioUtiliza);
    _tdCadDestinatarioTipoTabela.appendChild(_divCadDestinatarioTipoTabela);
    _tdCadDestinatarioTipoTabela.appendChild(_divCadDestinatarioTabelaRemetente);
    _tdCadRemetente.appendChild(_divCadRemetente);
    _tdCadRemetenteSimNao.appendChild(_inpRadCadRemetenteSim);
    _tdCadRemetenteSimNao.appendChild(_lblCadRemetenteSim);
    _tdCadRemetenteSimNao.appendChild(_inpRadCadRemetenteNao);
    _tdCadRemetenteSimNao.appendChild(_lblCadRemetenteNao);
    _tdAtualizaEndDestinatario.appendChild(_divAtualizaEndDestinatario);
    _tdAtualizaEndDestinatarioSimNao.appendChild(_inpRadAtualizaEndDestinatarioSim);
    _tdAtualizaEndDestinatarioSimNao.appendChild(_lblAtualizaEndDestinatarioSim);
    _tdAtualizaEndDestinatarioSimNao.appendChild(_inpRadAtualizaEndDestinatarioNao);
    _tdAtualizaEndDestinatarioSimNao.appendChild(_lblAtualizaEndDestinatarioNao);
    _tdAgruparPorVeiculo.appendChild(_divAgruparPorVeiculo);
    _tdAgruparPorVeiculoSimNao.appendChild(_inpAgruparPorVeiculoSim);
    _tdAgruparPorVeiculoSimNao.appendChild(_lblAgruparPorVeiculoSim);
    _tdAgruparPorVeiculoSimNao.appendChild(_inpAgruparPorVeiculoNao);
    _tdAgruparPorVeiculoSimNao.appendChild(_lblAgruparPorVeiculoNao);
    _tdSubContratacao.appendChild(_divSubContratacao);
    _tdSubContratacaoSimNao.appendChild(_inpSubContratacaoSim);
    _tdSubContratacaoSimNao.appendChild(_lblSubContratacaoSim);
    _tdSubContratacaoSimNao.appendChild(_inpSubContratacaoNao);
    _tdSubContratacaoSimNao.appendChild(_lblSubContratacaoNao);
    _tdBasePadraoCubagemLabel.appendChild(_divBasePadraoCubagem);
    _tdBasePadraoCubagemImput.appendChild(_inpBasePadraoCubagem);
    _tdBasePadraoCubagemAereoLabel.appendChild(_divBasePadraoCubagemAereo);
    _tdBasePadraoCubagemAereoImput.appendChild(_inpBasePadraoCubagemAereo);
    _tdResponsavel.appendChild(_divResponsavel);
    _tdResponsavelRadio.appendChild(_divResponsavelRadio);
    _tdCalcularPrazoTabelaPreco.appendChild(_divCalcularPrazoTabelaPreco);
    _tdCalcularPrazoTabelaPrecoSimNao.appendChild(_inpCalcularPrazoTabelaPrecoSim);
    _tdCalcularPrazoTabelaPrecoSimNao.appendChild(_lblCalcularPrazoTabelaPrecoSim);
    _tdCalcularPrazoTabelaPrecoSimNao.appendChild(_inpCalcularPrazoTabelaPrecoNao);
    _tdCalcularPrazoTabelaPrecoSimNao.appendChild(_lblCalcularPrazoTabelaPrecoNao);
    _tdConsiderarVolume.appendChild(_divConsiderarVolume);
    _tdConsiderarVolumeTag.appendChild(_inpTagTransportadora);
    _tdConsiderarVolumeTag.appendChild(_lblTagTransportadora);
    _tdConsiderarVolumeTag.appendChild(_inpTagZeroTransportadora);
    _tdConsiderarVolumeTag.appendChild(_lblTagZeroTransportadora);
    //******************TD*********************


    //******************TR*********************    
    _trLayoutPrincipal.appendChild(_tdLayoutPrincipal);
    _trLayout.appendChild(_tdExcluir);
    _trLayout.appendChild(_tdLayoutLbl);
    _trLayout.appendChild(_tdLayoutSlc);
    _trLayoutRemetente.appendChild(_tdLayoutLblRemetente);
    _trLayoutRemetente.appendChild(_tdLayoutInpRemetente);
    _trImportPrincipal.appendChild(_tdImportPrincipal);
    _trImportRedespacho.appendChild(_tdRedespacho);
    _trImportRedespacho.appendChild(_tdRedespachoLocaliza);
    _trImportDestinatario.appendChild(_tdDestinatario);
    _trImportDestinatario.appendChild(_tdDestinatarioLocaliza);
    _trImportRemetente.appendChild(_tdRemetente);
    _trImportRemetente.appendChild(_tdRemetenteLocaliza);
    _trImportConsignatario.appendChild(_tdConsignatario);
    _trImportConsignatario.appendChild(_tdConsignatarioLocaliza);
    _trImportRepresentante.appendChild(_tdRepresentante);
    _trImportRepresentante.appendChild(_tdRepresentanteLocaliza);
    _trImportRecebedor.appendChild(_tdRecebedor);
    _trImportRecebedor.appendChild(_tdRecebedorLocaliza);
    _trImportExpedidor.appendChild(_tdExpedidor);
    _trImportExpedidor.appendChild(_tdExpedidorLocaliza);
    _trImportConsiderarFrete.appendChild(_tdConsiderarFrete);
    _trImportConsiderarFrete.appendChild(_tdTabelaArquivo);
    _trImportNotaFiscal.appendChild(_tdNotaFiscal);
    _trImportNotaFiscal.appendChild(_tdNotaFiscalSimNao);
    _trImportUfDestino.appendChild(_tdUfDestino);
    _trImportUfDestino.appendChild(_tdUfDestinoSimNao);
    _trImportPedido.appendChild(_tdPedido);
    _trImportPedido.appendChild(_tdPedidoSimNao);
    _trImportCliente.appendChild(_tdCliente);
    _trImportCliente.appendChild(_tdClienteSimNao);
    _trImportFilial.appendChild(_tdFilial);
    _trImportFilial.appendChild(_tdFilialSimNao);
    _trImportVeiculo.appendChild(_tdVeiculo);
    _trImportVeiculo.appendChild(_tdVeiculoSimNao);
    _trImportMercadoria.appendChild(_tdMercadoria);
    _trImportMercadoria.appendChild(_tdMercadoriaSimNao);
    _trImportItemNota.appendChild(_tdItemNota);
    _trImportItemNota.appendChild(_tdItemNotaSimNao);
    _trImportAgrupVeiculo.appendChild(_tdAgruparPorVeiculo);
    _trImportAgrupVeiculo.appendChild(_tdAgruparPorVeiculoSimNao);
    _trImportCadDestinatario.appendChild(_tdCadDestinatario);
    _trImportCadDestinatario.appendChild(_tdCadDestinatarioSimNao);
    _trImportCadDestinatarioTabela.appendChild(_tdCadDestinatarioTabela);
    _trImportCadDestinatarioTabela.appendChild(_tdCadDestinatarioTipoTabela);
    _trImportCadRemetente.appendChild(_tdCadRemetente);
    _trImportCadRemetente.appendChild(_tdCadRemetenteSimNao);
    _trImportAtualizaEndDestinatario.appendChild(_tdAtualizaEndDestinatario);
    _trImportAtualizaEndDestinatario.appendChild(_tdAtualizaEndDestinatarioSimNao);
    _trSubContratacao.appendChild(_tdSubContratacao);
    _trSubContratacao.appendChild(_tdSubContratacaoSimNao);
    _trImportBasePadraoCubagem.appendChild(_tdBasePadraoCubagemLabel);
    _trImportBasePadraoCubagem.appendChild(_tdBasePadraoCubagemImput);
    _trImportBasePadraoCubagemAereo.appendChild(_tdBasePadraoCubagemAereoLabel);
    _trImportBasePadraoCubagemAereo.appendChild(_tdBasePadraoCubagemAereoImput);
    _trImportResponsavel.appendChild(_tdResponsavel);
    _trImportResponsavel.appendChild(_tdResponsavelRadio);
    _trImportCalcularPrazoTabelaPreco.appendChild(_tdCalcularPrazoTabelaPreco);
    _trImportCalcularPrazoTabelaPreco.appendChild(_tdCalcularPrazoTabelaPrecoSimNao);
    _trImportConsiderarVolume.appendChild(_tdConsiderarVolume);
    _trImportConsiderarVolume.appendChild(_tdConsiderarVolumeTag);
    //******************TR*********************

    //****************TABELA*******************
    $("tbImportacaoLote").appendChild(_trLayoutPrincipal);
    $("tbImportacaoLote").appendChild(_trLayout);
    $("tbImportacaoLote").appendChild(_trLayoutRemetente);
    $("tbImportacaoLote").appendChild(_trImportPrincipal);
    $("tbImportacaoLote").appendChild(_trImportRedespacho);
    $("tbImportacaoLote").appendChild(_trImportDestinatario);
    $("tbImportacaoLote").appendChild(_trImportRemetente);
    $("tbImportacaoLote").appendChild(_trImportConsignatario);
    $("tbImportacaoLote").appendChild(_trImportRepresentante);
    $("tbImportacaoLote").appendChild(_trImportRecebedor);
    $("tbImportacaoLote").appendChild(_trImportExpedidor);
    $("tbImportacaoLote").appendChild(_trImportResponsavel);
    $("tbImportacaoLote").appendChild(_trImportConsiderarFrete);
    $("tbImportacaoLote").appendChild(_trImportCalcularPrazoTabelaPreco);
    $("tbImportacaoLote").appendChild(_trImportNotaFiscal);
    $("tbImportacaoLote").appendChild(_trImportUfDestino);
    $("tbImportacaoLote").appendChild(_trImportPedido);
    $("tbImportacaoLote").appendChild(_trImportCliente);
    $("tbImportacaoLote").appendChild(_trImportFilial);
    $("tbImportacaoLote").appendChild(_trImportVeiculo);
    $("tbImportacaoLote").appendChild(_trImportMercadoria);
    $("tbImportacaoLote").appendChild(_trImportItemNota);
    $("tbImportacaoLote").appendChild(_trImportAgrupVeiculo);
    $("tbImportacaoLote").appendChild(_trSubContratacao);
    $("tbImportacaoLote").appendChild(_trImportCadDestinatario);
    $("tbImportacaoLote").appendChild(_trImportCadDestinatarioTabela);
    $("tbImportacaoLote").appendChild(_trImportCadRemetente);
    $("tbImportacaoLote").appendChild(_trImportAtualizaEndDestinatario);
    $("tbImportacaoLote").appendChild(_trImportBasePadraoCubagem);
    $("tbImportacaoLote").appendChild(_trImportBasePadraoCubagemAereo);
    $("tbImportacaoLote").appendChild(_trImportConsiderarVolume);
    
    let trTagsPersonalizadas = jQuery('<tr>', {'id': 'trImportacao_TagsPersonalizadas_' + countImportacaoLote, 'class': classe, 'style': 'display: none;'});
    trTagsPersonalizadas.append(jQuery('<td>', {'class': classe, 'colspan': '2'}).append(jQuery('<div>', {'align': 'right'}).append(jQuery('<label>').text('Utilizar tags personalizadas na importação do XML:'))));
    trTagsPersonalizadas.append(jQuery('<td>', {'class': classe, 'colspan': '2'})
            .append(jQuery('<table>', {'width': '100%'})
                .append(jQuery('<thead>')
                    .append(jQuery('<tr>', {'class': 'tabela'})
                        .append(jQuery('<td>', {'width': '1%'})
                            .append(jQuery('<div>', {'align': 'center'})
                                .append(jQuery('<img>', {'src': 'img/add.gif', 'class': 'imagemLink btnAdicionarTags', 'data-index': countImportacaoLote, 'data-class': classe}))
                                .append(jQuery('<input>', {'type': 'hidden', 'id': 'qtdDomTagsPersonalizadas_' + countImportacaoLote, 'name': 'qtdDomTagsPersonalizadas_' + countImportacaoLote, 'value': '0'})))
                            )
                            .append(jQuery('<td>', {'width': '5%'}).text('Nome da TAG'))
                            .append(jQuery('<td>', {'width': '5%'}).text('Campo'))
                        )
                    ).append(jQuery('<tbody>', {'id': 'tbodyTagsPersonalizadas_' + countImportacaoLote}))
                )
            );
    
    
    jQuery('#tbImportacaoLote').append(trTagsPersonalizadas);

    //****************TABELA*******************

    $("maxLayEDI_n").value = countImportacaoLote;

    //Caso seja editar vai pegar o código do layout do banco.
    if (importacaoLote.codigoLayoutEdi > 0) {
        jQuery('#slcLayout_' + countImportacaoLote + ' option[value=' + importacaoLote.codigoLayoutEdi + ']').attr("selected", true);
    }
    if (importacaoLote.tipoTabelaDestinatario > 0) {
        jQuery('#slcTipoTabela_' + countImportacaoLote + ' option[value=' + importacaoLote.tipoTabelaDestinatario + ']').attr("selected", true);
    }

    jQuery('#slcTipoTabelaRemetente_' + countImportacaoLote + ' option[value=' + importacaoLote.utilizarTabelaRemetente + ']').attr("selected", true);

    criterioLayout(_slcLayout.value, countImportacaoLote);
}

function validaRadioNF(index) {
    var radioImportNF = jQuery('input:radio[name=inpRadNotaFiscal_' + index + ']:checked').val();
    if (radioImportNF == 's') {
        alert("O agrupamento por UF de destino só pode ser utilizado caso o agrupamento por remetente e destinatário esteja desabilitado");
        jQuery('#inpRadUfDestinoNao_' + index + '').attr("checked", true);
    }
}

function validaRadioUF(index) {
    var radioUfDestino = jQuery('input:radio[name=inpRadUfDestino_' + index + ']:checked').val();
    if (radioUfDestino == 's') {
        alert("O agrupamento por remetente e destinatário de destino só pode ser utilizado caso o agrupamento por UF esteja desabilitado");
        jQuery('#inpRadNotaFiscalNao_' + index + '').attr("checked", true);
    }
}

var listGrupo = new Array();
var listPermissao = new Array();
function Contato(id, contato, email, setor, fone, ramal, celular, recebeEmailCobranca,
        recebeEmailEntrega, isUsuario, login, senha, listPermissaoCont, listGrupoCont, tipo) {

    this.id = (id != undefined ? id : 0);
    this.contato = (contato != undefined || contato != null ? contato : '');
    this.email = (email != undefined ? email : '');
    this.setor = (setor != undefined ? setor : '');
    this.fone = (fone != undefined ? fone : '');
    this.celular = (celular != undefined ? celular : '');
    this.ramal = (ramal != undefined ? ramal : '');
    this.recebeEmailCobranca = (recebeEmailCobranca != undefined ? recebeEmailCobranca : 'false');
    this.recebeEmailEntrega = (recebeEmailEntrega != undefined ? recebeEmailEntrega : 'false');
    this.isUsuario = (isUsuario != undefined ? isUsuario : 'false');
    this.login = (login != undefined || login != null ? login : '');
    this.senha = (senha != undefined || senha != null ? senha : '');
    this.listPermissaoCont = (listPermissaoCont != undefined && listPermissaoCont != null ? listPermissaoCont : listPermissao);
    this.listGrupoCont = (listGrupoCont != undefined && listGrupoCont != null ? listGrupoCont : listGrupo);
    this.tipo = (tipo != undefined ? tipo : 'NORMAL');//NORMAL e PROSPECTO
}

function Grupo(id, descricao, isSelecionado, idContatoGrupo) {
    this.id = (id != undefined ? id : 0);
    this.descricao = (descricao != undefined ? descricao : '');
    this.isSelecionado = (isSelecionado != undefined ? isSelecionado : 'false');
    this.idContatoGrupo = (idContatoGrupo != undefined ? idContatoGrupo : 0);
}

function Permissao(id, descricao, nivel, isPossuiGrupo, idPermGwCli) {
    this.id = (id != undefined && id != null ? id : 0);
    this.descricao = (descricao != undefined && descricao != null ? descricao : '');
    this.nivel = (nivel != undefined && nivel != null ? nivel : "0");
    this.isPossuiGrupo = (isPossuiGrupo != undefined && isPossuiGrupo != null ? isPossuiGrupo : 'false');
    this.idPermGwCli = (idPermGwCli != undefined && idPermGwCli != null ? idPermGwCli : "0");
}

function escEspDivCont(idDivAtual, imgAtual) {
    var divAtual = document.getElementById(idDivAtual);
    if (divAtual.style.display == '') {
        divAtual.style.display = 'none';
        if (imgAtual != null) {
            imgAtual.src = "img/plus.jpg";
        }
    } else {
        divAtual.style.display = '';
        if (imgAtual != null) {
            imgAtual.src = "img/minus.jpg";
        }
    }
}



var idxCont = 0;
function addContato(contato) {
    if (contato == null || contato == undefined) {
        contato = new Contato();
    }

    idxCont++;
    var classTr = idxCont % 2 == 1 ? "CelulaZebra2" : "CelulaZebra1";

    var _tr1 = new Element("tr", {
        name: "trCont_" + idxCont,
        id: "trCont_" + idxCont,
        className: classTr
    });

    var _td1a = new Element("td");
//Adicionando esse campo para enganar o firefox, estava colocando a senha e login do sistema no primeiro password que encontrava.
//do mesmo jeito que cassimiro fez na tela de fornecedor.
    var _ipt2_gambi = new Element("input", {
        name: "login_" + idxCont,
        id: "login_" + idxCont,
        type: "password",
        value: contato.senha,
        maxlength: "13",
        size: "13",
        className: "inputtexto"
    });
    _ipt2_gambi.style.display = "none";
    _td1a.appendChild(_ipt2_gambi);

    var _ip1a = Builder.node("img", {
        src: "img/plus.jpg",
        onclick: "escEspDivCont('tr2Senha_" + idxCont + "',this);escEspDivCont('tr3Perm_" + idxCont + "',this)"
    });


    if (contato.isUsuario == "true" && contato.tipo != 'PROSPECTO') {
        _td1a.appendChild(_ip1a);
    }

    //excluir
    var _td1 = new Element("td", {
        className: classTr
    });

    var _ip1_2 = new Element("input", {
        name: "idGeralCont_" + idxCont,
        id: "idGeralCont_" + idxCont,
        type: "hidden",
        value: contato.id
    });

    var _div1 = new Element("div", {
        align: "center"
    });

    var _ip1 = Builder.node("img", {
        src: "img/lixo.png",
        onclick: "removerContato(null," + idxCont + ");"
//        onclick:"mensagemExcluir('trCont_"+ idxCont +"!!tr2Senha_" + idxCont+"!!tr3Perm_" + idxCont+"','Deseja apagar realmente o contato?');"
    });

    _div1.appendChild(_ip1);
    _td1.appendChild(_div1);
    _td1.appendChild(_ip1_2);

    //contato
    var _td2 = new Element("td", {
        className: classTr
    });

    var _ip2 = new Element("input", {
        name: "contato_" + idxCont,
        id: "contato_" + idxCont,
        type: "text",
        value: contato.contato,
        size: "14",
        maxLength: "20",
        className: "inputtexto"
    });
    _td2.appendChild(_ip2); // Atualiza

    //Setor
    var _td3 = new Element("td", {
        className: classTr
    });

    var _ip3 = new Element("input", {
        name: "setorCont_" + idxCont,
        id: "setorCont_" + idxCont,
        type: "text",
        value: contato.setor,
        size: "10",
        maxLength: "30",
        className: "inputtexto"
    });
    _td3.appendChild(_ip3); // Atualiza

    //fone
    var _td4 = new Element("td", {
        className: classTr
    });

    var _ip4 = new Element("input", {
        name: "foneCont_" + idxCont,
        id: "foneCont_" + idxCont,
        type: "text",
        value: contato.fone,
        size: "12",
        maxLength: "13",
        className: "inputtexto"
    });
    _td4.appendChild(_ip4); // Atualiza

    //Ramal
    var _td5 = new Element("td", {
        className: classTr
    });

    var _ip5 = new Element("input", {
        name: "ramalCont_" + idxCont,
        id: "ramalCont_" + idxCont,
        type: "text",
        value: contato.ramal,
        size: "5",
        maxLength: "6",
        className: "inputtexto"
    });
    _td5.appendChild(_ip5); // Atualiza

    //Celular
    var _td6 = new Element("td", {
        className: classTr
    });

    var _ip6 = new Element("input", {
        name: "celularCont_" + idxCont,
        id: "celularCont_" + idxCont,
        type: "text",
        value: contato.celular,
        size: "12",
        maxLength: "13",
        className: "inputtexto"
    });
    _td6.appendChild(_ip6); // Atualiza

    //e-mail
    var _td7 = new Element("td", {
        className: classTr
    });

    var _ip7 = new Element("input", {
        name: "emailCont_" + idxCont,
        id: "emailCont_" + idxCont,
        type: "text",
        value: contato.email,
        size: "35",
        maxLength: "150",
        className: "inputtexto"
    });
    _td7.appendChild(_ip7); // Atualiza

    //Entrega
    var _td8 = new Element("td", {
        className: classTr
    });

    var _div8 = new Element("div", {
        align: "center"
    });

    var _ip8 = new Element("input", {
        name: "recebeEntrega_" + idxCont,
        id: "recebeEntrega_" + idxCont,
        type: "checkbox"
    });
    _div8.appendChild(_ip8);
    _td8.appendChild(_div8);

    //cobrança
    var _td9 = new Element("td", {
        className: classTr
    });

    //edi
    var _td10 = new Element("td", {
        className: classTr
    });

    var _div9 = new Element("div", {
        align: "center"
    });
    
    var _div10 = new Element("div", {
        align: "center"
    });
    
    var _ip9 = new Element("input", {
        name: "recebeCobranca_" + idxCont,
        id: "recebeCobranca_" + idxCont,
        type: "checkbox"
    });
    
    var _ipContatoEdi = new Element("input", {
        name: "recebeEdi_" + idxCont,
        id: "recebeEdi_" + idxCont,
        type: "checkbox"
    });
    
    _div9.appendChild(_ip9);
    
    _td9.appendChild(_div9);
    
    _div10.appendChild(_ipContatoEdi);

    _td10.appendChild(_div10);

    _tr1.appendChild(_td1);
    _tr1.appendChild(_td1a);
    _tr1.appendChild(_td2);
    _tr1.appendChild(_td3);
    _tr1.appendChild(_td4);
    _tr1.appendChild(_td5);
    _tr1.appendChild(_td6);
    _tr1.appendChild(_td7);

    //Entrega e Cobrança
    if (contato.tipo != "PROSPECTO") {
        _tr1.appendChild(_td8);
        _tr1.appendChild(_td9);
    }
    _tr1.appendChild(_td10);


    if (contato.isUsuario == "true") {
        //--------------------------------------------------linha 2---------------------------------------------
        var _tr2 = new Element("tr", {
            name: "tr2Senha_" + idxCont,
            id: "tr2Senha_" + idxCont,
            style: "display=none"
        });

        var _td2_1 = new Element("td", {
            name: "td2_1_" + idxCont,
            id: "td2_1_" + idxCont,
            colSpan: "10"
        });

        var _table2 = new Element("table", {
            name: "table2_" + idxCont,
            id: "table2_" + idxCont,
            width: "100%",
            cellSpacing: "0",
            cellPadding: "0"
        });

        var _tr_table2 = new Element("tr", {
            name: "tr_table2_" + idxCont,
            id: "tr_table2_" + idxCont
        });

        //label Login
        var _tdt2_1 = new Element("td", {
            className: classTr,
            width: "13,33"
        });

        var _tdt2_1_1 = new Element("div", {
            align: "right"
        });

        var _ipt2_1 = new Element("label", {
            name: "linha2_1_" + idxCont,
            id: "linha2_1_" + idxCont
        });
        _tdt2_1_1.appendChild(_ipt2_1);
        _tdt2_1.appendChild(_tdt2_1_1); // Atualiza

        //Login
        var _tdt2_2 = new Element("td", {
            className: classTr,
            width: "20%"
        });

        var _ipt2_2 = new Element("input", {
            name: "contLogin_" + idxCont,
            id: "contLogin_" + idxCont,
            type: "text",
            value: contato.login,
            maxlength: "18",
            size: "19",
            className: "inputtexto"
        });
        _tdt2_2.update(_ipt2_2);

        //label Senha
        var _tdt2_3 = new Element("td", {
            className: classTr,
            width: "13,33%"
        });

        var _tdt2_3_1 = new Element("div", {
            align: "right"
        });

        var _ipt2_3 = new Element("label", {
            name: "linha2_4_" + idxCont,
            id: "linha2_4_" + idxCont
        });
        _tdt2_3_1.appendChild(_ipt2_3);
        _tdt2_3.appendChild(_tdt2_3_1); // Atualiza

        //Senha
        var _tdt2_4 = new Element("td", {
            className: classTr,
            width: "20%"
        });

        var _ipt2_4 = new Element("input", {
            name: "contSenha_" + idxCont,
            id: "contSenha_" + idxCont,
            type: "password",
            value: contato.senha,
            maxlength: "18",
            size: "19",
            className: "inputtexto"
        });
        _tdt2_4.update(_ipt2_4);

        //label Repetir
        var _tdt2_5 = new Element("td", {
            className: classTr,
            width: "13,33%"
        });

        var _tdt2_5_1 = new Element("div", {
            align: "right"
        });

        var _ipt2_5 = new Element("label", {
            name: "linha2_6_" + idxCont,
            id: "linha2_6_" + idxCont
        });
        _tdt2_5_1.appendChild(_ipt2_5);
        _tdt2_5.appendChild(_tdt2_5_1); // Atualiza

        //Repetir
        var _tdt2_6 = new Element("td", {
            className: classTr,
            width: "20%"
        });

        var _ipt2_6 = new Element("input", {
            name: "contRepetir_" + idxCont,
            id: "contRepetir_" + idxCont,
            type: "password",
            value: contato.senha,
            maxlength: "18",
            size: "19",
            className: "inputtexto"
        });
        _tdt2_6.update(_ipt2_6);

        _tr_table2.appendChild(_tdt2_1);
        _tr_table2.appendChild(_tdt2_2);
        _tr_table2.appendChild(_tdt2_3);
        _tr_table2.appendChild(_tdt2_4);
        _tr_table2.appendChild(_tdt2_5);
        _tr_table2.appendChild(_tdt2_6);

        var _tbodyLog = Builder.node("tbody", {
            id: "tBody2_" + idxCont,
            name: "tBody2_" + idxCont,
            onload: "applyFormatter()"
        });

        _table2.appendChild(_tbodyLog);
        _tbodyLog.appendChild(_tr_table2);
        _td2_1.appendChild(_table2);
        _tr2.appendChild(_td2_1);

        //-------------------------------------------------- linha 3 ---------------------------------------------
        var _tr3 = new Element("tr", {
            name: "tr3Perm_" + idxCont,
            id: "tr3Perm_" + idxCont,
            style: "display=none"
        });

        var _td2_2 = new Element("td", {
            name: "td2_1_" + idxCont,
            id: "td2_1_" + idxCont,
            colSpan: "10"
        });

        var _tbodyPerm = Builder.node("tbody", {
            id: "tBody3_" + idxCont,
            name: "tBody3_" + idxCont,
            onload: "applyFormatter()"
        });

        var _table2_2 = new Element("table", {
            name: "table2_" + idxCont,
            id: "table2_" + idxCont,
            cellPadding: "0",
            width: "100%"
        });

        var coluna = 1;

        var _tr_table2_2 = new Element("td", {
            className: "tabela",
            colspan: 6,
            align: "center"
        });

        var _lb2_2_1_top = Builder.node("label", "Permissões");
        _tr_table2_2.appendChild(_lb2_2_1_top);
        _tbodyPerm.appendChild(_tr_table2_2);

        var _tdt2_2_2 = new Element("td", {
            className: classTr,
            width: "33%",
            colSpan: 2
        });

        var idxPerm = 1;
        for (var i = 0; i < contato.listPermissaoCont.length; i++) {
            if (i == 3) {
                _tdt2_2_1 = new Element("td", {
                    className: classTr,
                    width: "5%"
                });

                _tr_table2_2 = new Element("tr", {
                    name: "tr_grupos_" + idxCont,
                    id: "tr_grupos_" + idxCont,
                    style: "display:none"
                });

                var idxGrup = 1;
                _tr_table2_2.appendChild(_tdt2_2_1);

                var _tdt2_2_1a = new Element("td", {
                    className: classTr,
                    width: "25%"
                });

                var _tdt2_2_1b = new Element("td", {
                    className: classTr,
                    colSpan: 4
                });

                for (var j = 0; j < contato.listGrupoCont.length; j++) {
                    var _dv2_2_1 = Builder.node("div", {
                        id: "divGrup_" + idxCont + "_" + idxGrup,
                        name: "divGrup_" + idxCont + "_" + idxGrup
                    });

                    var _ip2_2_1b = new Element("input", {
                        name: "grupChk_" + idxCont + "_" + idxGrup,
                        id: "grupChk_" + idxCont + "_" + idxGrup,
                        type: "checkbox",
                        checked: (contato.listGrupoCont[j].isSelecionado == "false" ? false : true)
                    });

                    var _ip2_2_1ab = new Element("input", {
                        name: "grupId_" + idxCont + "_" + idxGrup,
                        id: "grupId_" + idxCont + "_" + idxGrup,
                        type: "hidden",
                        value: contato.listGrupoCont[j].id
                    });

                    var _ip2_2_1IdContGrupo = new Element("input", {
                        name: "grupIdContato_" + idxCont + "_" + idxGrup,
                        id: "grupIdContato_" + idxCont + "_" + idxGrup,
                        type: "hidden",
                        value: contato.listGrupoCont[j].idContatoGrupo
                    });

                    var _lb2_2_1b = Builder.node("label", contato.listGrupoCont[j].descricao + "");

                    _dv2_2_1.appendChild(_ip2_2_1b);
                    _dv2_2_1.appendChild(_ip2_2_1ab);
                    _dv2_2_1.appendChild(_ip2_2_1IdContGrupo);
                    _dv2_2_1.appendChild(_lb2_2_1b);

                    _tdt2_2_1a.appendChild(_dv2_2_1);
                    idxGrup++;
                }
                _tr_table2_2.appendChild(_tdt2_2_1a);
                _tr_table2_2.appendChild(_tdt2_2_1b);
                _tbodyPerm.appendChild(_tr_table2_2);
            }

            var _tdt2_2_1 = new Element("td", {
                className: classTr,
                width: "33%",
                colSpan: 2
            });

            if (coluna == 1) {
                _tr_table2_2 = new Element("tr", {
                    name: "tr_table2_" + idxCont,
                    id: "tr_table2_" + idxCont
                });
            }

            var _ip2_2_1 = new Element("input", {
                name: "permChk_" + idxCont + "_" + idxPerm,
                id: "permChk_" + idxCont + "_" + idxPerm,
                type: "checkbox",
                onClick: "mostrarEstoqueGrupos(" + idxCont + "," + idxPerm + ");",
                checked: (contato.listPermissaoCont[i].nivel == "0" ? false : true)
            });

            var _ip2_2_1a = new Element("input", {
                name: "permId_" + idxCont + "_" + idxPerm,
                id: "permId_" + idxCont + "_" + idxPerm,
                type: "hidden",
                value: contato.listPermissaoCont[i].id
            });

            var _ip2_2_1GwCli = new Element("input", {
                name: "permGwCliId_" + idxCont + "_" + idxPerm,
                id: "permGwCliId_" + idxCont + "_" + idxPerm,
                type: "hidden",
                value: contato.listPermissaoCont[i].idPermGwCli
            });

            var _lb2_2_1 = Builder.node("label", contato.listPermissaoCont[i].descricao + "");

            _tdt2_2_1.appendChild(_ip2_2_1);
            _tdt2_2_1.appendChild(_ip2_2_1a);
            _tdt2_2_1.appendChild(_ip2_2_1GwCli);
            _tdt2_2_1.appendChild(_lb2_2_1);

            _tr_table2_2.appendChild(_tdt2_2_1);
            if (coluna == 1) {
                if (i == contato.listPermissaoCont.length - 1) {
                    _tr_table2_2.appendChild(_tdt2_2_2);
                    _tdt2_2_2 = new Element("td", {
                        className: classTr,
                        width: "33%",
                        colSpan: 2
                    });
                    _tr_table2_2.appendChild(_tdt2_2_2);
                }
                coluna = 2;
            } else if (coluna == 2) {
                if (i == contato.listPermissaoCont.length - 1) {
                    _tr_table2_2.appendChild(_tdt2_2_2);
                }
                coluna = 3;
            } else {
                coluna = 1;
            }
            _tbodyPerm.appendChild(_tr_table2_2);

            idxPerm++;
        }

        if (contato.listPermissaoCont.length <= 3) {
            _tdt2_2_1 = new Element("td", {
                className: classTr,
                width: "5%"
            });
            _tr_table2_2 = new Element("tr", {
                name: "tr_grupos_" + idxCont,
                id: "tr_grupos_" + idxCont,
                style: "display:none"
            });

            var idxGrup = 1;
            _tr_table2_2.appendChild(_tdt2_2_1);

            var _tdt2_2_1a = new Element("td", {
                className: classTr,
                width: "25%"
            });

            var _tdt2_2_1b = new Element("td", {
                className: classTr,
                colSpan: 4
            });

            for (var j = 0; j < contato.listGrupoCont.length; j++) {
                var _dv2_2_1 = Builder.node("div", {
                    id: "divGrup_" + idxCont + "_" + idxGrup,
                    name: "divGrup_" + idxCont + "_" + idxGrup
                });

                var _ip2_2_1b = new Element("input", {
                    name: "grupChk_" + idxCont + "_" + idxGrup,
                    id: "grupChk_" + idxCont + "_" + idxGrup,
                    type: "checkbox",
                    checked: (contato.listGrupoCont[j].isSelecionado == "false" ? false : true)
                });

                var _ip2_2_1ab = new Element("input", {
                    name: "grupId_" + idxCont + "_" + idxGrup,
                    id: "grupId_" + idxCont + "_" + idxGrup,
                    type: "hidden",
                    value: contato.listGrupoCont[j].id
                });

                var _lb2_2_1b = Builder.node("label", contato.listGrupoCont[j].descricao + "");

                _dv2_2_1.appendChild(_ip2_2_1b);
                _dv2_2_1.appendChild(_ip2_2_1ab);
                _dv2_2_1.appendChild(_lb2_2_1b);

                _tdt2_2_1a.appendChild(_dv2_2_1);
                idxGrup++;
            }
            _tr_table2_2.appendChild(_tdt2_2_1a);
            _tr_table2_2.appendChild(_tdt2_2_1b);
            _tbodyPerm.appendChild(_tr_table2_2);
        }

        _table2_2.appendChild(_tbodyPerm);
        _td2_2.appendChild(_table2_2);
        _tr3.appendChild(_td2_2);

        //------
    }

    //implementa
    $("TbContato").appendChild(_tr1);
    if (contato.isUsuario == "true") {
        $("TbContato").appendChild(_tr2);
        $("TbContato").appendChild(_tr3);
    }

//    //o for foi criado por causa do IE
//    for(var i = 0; i < contato.listPermissaoCont.length; i++){
//        if (i == 3) {
//            var idxGrup = 1;
//            for(var j = 0; j < contato.listGrupoCont.length; j++){
//                if($("grupChk_"+idxCont+"_"+idxGrup) != null && $("grupChk_"+idxCont+"_"+idxGrup) != undefined){
//                    $("grupChk_"+idxCont+"_"+idxGrup).checked = (contato.listGrupoCont[j].isSelecionado == "false" ? false : true );
//                    idxGrup++;
//                    
//                }
//            }
//            var idxPerm = 1;
//             if($("permId_" + idxCont + "_" + idxPerm).value == 0 && $("permChk_" +  idxCont + "_" + idxPerm).checked ){
//                escEspDivCont('tr_grupos_'+ idxCont,$("permChk_" +  idxCont + "_" + idxPerm));
//            } 
//            for(var l = 0; l < contato.listPermissaoCont.length; l++){
//                if($("permChk_" +  idxCont + "_" + idxPerm) != null && $("permChk_" +  idxCont + "_" + idxPerm) != undefined && $("permId_" + idxCont + "_" + idxPerm).value == 0  ){
//               $("permChk_" +  idxCont + "_" + idxPerm).onclick = function(){
//                    escEspDivCont('tr_grupos_'+ idxCont,$("permChk_" +  idxCont + "_" + idxPerm));
//                } 
//                $("permChk_" +  idxCont + "_" + idxPerm).checked = (contato.listPermissaoCont[l].nivel == "0" ? false : true );
//                idxPerm++;
//                }
//            }
//        }
//    }

    $("maxContato").value = idxCont;

    //checks
    if (contato.recebeEmailCobranca == "true") {
        $("recebeCobranca_" + idxCont).checked = true
    }

    if (contato.recebeEmailEntrega == "true") {
        $("recebeEntrega_" + idxCont).checked = true
    }
    
    if (contato.receberEmailEdi == "true") {
        $("recebeEdi_" + idxCont).checked = true
    }

    //label's
    $("linha2_1_" + idxCont).innerHTML = "Login:";
    $("linha2_4_" + idxCont).innerHTML = "Senha:";
    $("linha2_6_" + idxCont).innerHTML = "Repetir:";

    if (contato.isUsuario == "true") {
        $("tr2Senha_" + idxCont).style.display = "none";
        $("tr3Perm_" + idxCont).style.display = "none";
    }
    applyFormatter();

//    if(contato.listPermissaoCont[0].nivel != "0"){
//        escEspDivCont("tr_grupos_"+ idxCont,$("permChk_" +  idxCont + "_1"));
//    }

}
function escondeMostraAtualizarDestinatario(index) {
    if ($("inpRadCadDestinatarioSim_" + index).checked && $("slcLayout_" + index).value == '61') {
        visivel($("trImport_AtualizaEndDestinatario_" + index));
    } else {
        invisivel($("trImport_AtualizaEndDestinatario_" + index));
    }
}
function mostrarCamposEmbarcador(campo) {
    if (campo == null) {
        campo = $("tipoSeguroCarga").value;
    }
    if (campo == "c") {
        $("trEmbarcador1").style.display = "";
        $("trEmbarcador2").style.display = "";
        $("trEmbarcador3").style.display = "";
        $("trEmbarcador4").style.display = "";
        $("trEmbarcador5").style.display = "";
        $("trEmbarcador6").style.display = "";
        alterarAverbacao(null);
        alterarAverbacaoNfs(null);
    } else {
        $("trEmbarcador1").style.display = "none";
        $("trEmbarcador2").style.display = "none";
        $("trEmbarcador3").style.display = "none";
        $("trEmbarcador4").style.display = "none";
        $("trEmbarcador5").style.display = "none";
        $("trEmbarcador6").style.display = "none";

        $("statusAverbacaoCte").value = "N";
        $("statusAverbacaoNfs").value = "N";
    }
}


function alterarAverbacao(e) {
    if (e == null) {
        e = $("statusAverbacaoCte").value;
    }

    if (e != "N") {
        $("txFormaTransmissaoCte").style.display = "";
        $("divFormaTransmissaoCte").style.display = "";
        $("trEmbarcador2").style.display = "";
        $("trCaixaPostal").style.display = "";
        $("trEmbarcador3").style.display = "";
    } else {
        $("txFormaTransmissaoCte").style.display = "none";
        $("divFormaTransmissaoCte").style.display = "none";
        $("trEmbarcador2").style.display = "none";
        $("trCaixaPostal").style.display = "none";
        $("trEmbarcador3").style.display = "none";
    }

}

function alterarAverbacaoNfs(e) {
    if (e == null) {
        e = $("statusAverbacaoNfs").value;
    }

    if (e != "N") {
        $("trEmbarcador5").style.display = "";
        $("divRadioNfs").style.display = "";
        $("formaNfs").style.display = "";
    } else {
        $("trEmbarcador5").style.display = "none";
        $("divRadioNfs").style.display = "none";
        $("formaNfs").style.display = "none";
    }

}


function validarConsumidorFinal() {
    //    Se o TIPO DO CGC do cliente for "CPF", então o novo campo deverá receber true automaticamente;
    //    Se o TIPO DO CGC do cliente for "CNPJ" e a inscrição estadual for "ISENTO", então o novo campo deverá receber true automaticamente;
    //    Se o TIPO DO CGC do cliente for "CNPJ" e a inscrição estadual for diferente de ISENTO, então o novo campo deverá receber false automaticamente; 
    if ($("tipocgc").value == "F") {
        $("consumidorFinal").checked = true;
    } else if ($("tipocgc").value == "J" && $("IE").value == "ISENTO") {
        $("consumidorFinal").checked = true;
    } else if ($("tipocgc").value == "J" && $("IE").value != "ISENTO") {
        $("consumidorFinal").checked = false;
    }
}

function criterioCalculoComissao(calculoComissao, tipoVendedor) {
    if (tipoVendedor == "Vendedor") {
        if (calculoComissao == "l") {
            $("divIcmsVendedor").style.display = "";
            $("divImpostosVendedor").style.display = "";
//                $("divDeduzirVendedor").style.display = "";
        } else if (calculoComissao == "b") {
            $("divIcmsVendedor").style.display = "none";
            $("divImpostosVendedor").style.display = "none";
//                $("divDeduzirVendedor").style.display = "none";
        }
    } else if (tipoVendedor == "Supervisor") {
        if (calculoComissao == "l") {
            $("divIcmsSupervisor").style.display = "";
            $("divImpostosSupervisor").style.display = "";
//                $("divDeduzirSupervisor").style.display = "";
        } else if (calculoComissao == "b") {
            $("divIcmsSupervisor").style.display = "none";
            $("divImpostosSupervisor").style.display = "none";
//                $("divDeduzirSupervisor").style.display = "none";
        }
    }
}

function marcarTodosImpostos(tipoPagamento) {
    if (tipoPagamento == 'Vendedor') {
//            $("icmsVendedor").checked = $("impostoFederaisVendedor").checked;
        $("pisVendedor").checked = $("impostoFederaisVendedor").checked;
        $("cofinsVendedor").checked = $("impostoFederaisVendedor").checked;
        $("csslVendedor").checked = $("impostoFederaisVendedor").checked;
        $("irVendedor").checked = $("impostoFederaisVendedor").checked;
        $("inssVendedor").checked = $("impostoFederaisVendedor").checked;
    } else if (tipoPagamento == 'Supervisor') {
//            $("icmsSupervisor").checked = $("impostoFederaisSupervisor").checked;
        $("pisSupervisor").checked = $("impostoFederaisSupervisor").checked;
        $("cofinsSupervisor").checked = $("impostoFederaisSupervisor").checked;
        $("csslSupervisor").checked = $("impostoFederaisSupervisor").checked;
        $("irSupervisor").checked = $("impostoFederaisSupervisor").checked;
        $("inssSupervisor").checked = $("impostoFederaisSupervisor").checked;

    }
}

function limparBorrachaBairro() {
    $("bairro").readOnly = false;
    $("bairro").className = "inputtexto";
    $("bairro").value = "";
    $("idLocalizaBairro").value = 0;
}
function limparBorrachaBairroCob() {
    $("bairroCob").readOnly = false;
    $("bairroCob").className = "inputtexto";
    $("bairroCob").value = "";
    $("idBairroCob").value = 0;
}
function limparBorrachaBairroCol() {
    $("bairroCol").readOnly = false;
    $("bairroCol").className = "inputtexto";
    $("bairroCol").value = "";
    $("idBairroCol").value = 0;
}
function limparBairroEntrega(index) {
    $("bairroEndEntrga_" + index).readOnly = false;
    $("bairroEndEntrga_" + index).className = "inputtexto";
    $("bairroEndEntrga_" + index).value = "";
    $("idBairroEndEntrga_" + index).value = 0;
}

function abrirLocalizaBairro() {
    var idCidade = $("idcidade").value;
    abrirLocaliza("./BairroControlador?acao=localizarBairro&idCidade=" + idCidade, "LocalizarBairro");
}
function abrirLocalizaBairroCobranca() {
    var idCidade = $("cidadeCobId").value;
    abrirLocaliza("./BairroControlador?acao=localizarBairro&idCidade=" + idCidade, "LocalizarBairroCobranca");
}
function abrirLocalizaBairroColeta() {
    var idCidade = $("cidadeColId").value;
    abrirLocaliza("./BairroControlador?acao=localizarBairro&idCidade=" + idCidade, "LocalizarBairroColeta");
}

function carregaCepAjaxDom(resposta, isIgnoraEndereco, index) {
    var rua = resposta.split("@@")[1];
    var bairro = resposta.split("@@")[2];
    var idbairro = resposta.split("@@")[3];
    var cidade = resposta.split("@@")[4];
    var idCidade = resposta.split("@@")[5];
    var uf = resposta.split("@@")[6];
    if (rua == "") {
        verificarEndereco(index);
    }
    if (!isIgnoraEndereco) {
        if (rua != "" && $("logradouroEndEntrga_" + index).value.trim() == "") {
            $("logradouroEndEntrga_" + index).value = rua;
            $("bairroEndEntrga_" + index).value = bairro;
            $("idBairroEndEntrga_" + index).value = idbairro;
            $("cidadeEndEntrga_" + index).value = cidade;
            $("ufEndEntrga_" + index).value = uf;
            $("idCidadeEndEntrga_" + index).value = idCidade;
        }
    } else {
        $("endereco").value = rua;
        $("bairroEndEntrga_" + index).value = bairro;
        $("idBairroEndEntrga_" + index).value = idbairro;
        $("cidadeEndEntrga_" + index).value = cidade;
        $("ufEndEntrga_" + index).value = uf;
        $("idCidadeEndEntrga_" + index).value = idCidade;
    }
    espereEnviar("", false);
}
function getEnderecoByCep(cep, isIgnoraEndereco, tipoEndereco) {
    espereEnviar("", true);
    new Ajax.Request("./jspcadcliente.jsp?acao=getEnderecoByCep&cep=" + cep, {method: "get",
        onSuccess: function (transport) {
            var response = transport.responseText;
            carregaCepAjax(response, isIgnoraEndereco, tipoEndereco);
        },
        onFailure: function () { }
    });
}
function localizacid_origem() {
    post_cad = window.open('./localiza?acao=consultar&idlista=11', 'Cidade',
            'top=80,left=150,height=400,width=700,resizable=yes,status=1,scrollbars=1');
}
function abrirLocalizarCidadeEntrega(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(11, "Cidade_Entrega", "");
}
function abrirLocalizarBairroEntrega(index, idCidade) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    var cidadeId = (idCidade == 0 ? "" : "&paramaux=" + idCidade);
    popLocate(88, "Bairro_Entrega", "", cidadeId);
//             popLocate(88, "Bairro_Entrega","");
}
function abrirLocalizarCron(elementoId) {
    try {
        tryRequestToServer(function () {
            abrirJanela("AgendamentoTarefasCrontrolador?acao=localizarCron"
                    + "&elemento=" + elementoId, "locCron", 50, 30);
        });
    } catch (e) {
        alert(e);
    }
}
function responsabilidadeAverbacao() {
    if ($("tipoSeguroCarga").value == "c") {
        $("spvalidadeDDR").style.display = "";
        $("trXmlCteVcarga").style.display = "";
    } else {
        $("spvalidadeDDR").style.display = "none";
        $("trXmlCteVcarga").style.display = "none";
    }
}
function repetirDadosPrincipaisCol() {
    $('enderecoCol').value = $('endereco').value + ($('numeroLogradouro').value == '' ? '' : ', ' + $('numeroLogradouro').value);
    $('complCol').value = $('compl').value;
    $('bairroCol').value = $('bairro').value;
    $('cepCol').value = $('cep').value;
    $('cidadeColId').value = $('idcidade').value;
    $('cidadeCol').value = $('cidade').value;
    $('ufCol').value = $('uf').value;
}
function mostrarCampos(imgElement) {
    if (imgElement != null && imgElement != undefined) {
        var idx = imgElement.id.split("_")[1];
        var estado = imgElement.src;
        if (estado.indexOf("plus.jpg") > -1) {
            visivel($("tr2Log_" + idx));
            imgElement.src = "img/minus.jpg";
        } else if (estado.indexOf("minus.jpg") > -1) {
            invisivel($("tr2Log_" + idx));
            imgElement.src = "img/plus.jpg";
        }
    }
}
function limpaVendedor() {
    getObj("idven").value = "0";
    getObj("vendedor").value = "";
}
function limpaOrigem() {
    getObj("origem_captacao_id").value = "0";
    getObj("origem_captacao").value = "";
}
function limpaSupervisor() {
    getObj("idsupervisor").value = "0";
    getObj("supervisor").value = "";
}
function limparEndereco() {
    $("endereco").value = "";
    $("bairro").value = "";
    $("cidade").value = "";
    $("idcidade").value = "0";
    $("uf").value = "";
}
function limparEnderecoCob() {
    $("enderecoCob").value = "";
    $("bairroCob").value = "";
    $("cidadeCob").value = "";
    $("idcidadeCob").value = "0";
    $("ufCob").value = "";
}
function limparEnderecoCol() {
    $("enderecoCol").value = "";
    $("bairroCol").value = "";
    $("cidadeCol").value = "";
    $("idcidadeCol").value = "0";
    $("ufCol").value = "";
}
function limparEnderecoEntrega(index) {
    $("logradouroEndEntrga_" + index).value = "";
    $("bairroEndEntrga_" + index).value = "";
    $("cidadeEndEntrga_" + index).value = "";
    $("idCidadeEndEntrga_" + index).value = 0;
    $("ufEndEntrga_" + index).value = "";
}
function escEspDiv(idDivAtual, imgAtual) {
    var divAtual = $(idDivAtual);
    if (divAtual.style.display == '') {
        divAtual.style.display = 'none';
        imgAtual.src = "img/plus.jpg";
    } else {
        divAtual.style.display = '';
        imgAtual.src = "img/minus.jpg";
    }
}
function validarConsumidorFinal() {
    //    Se o TIPO DO CGC do cliente for "CPF", então o novo campo deverá receber true automaticamente;
    //    Se o TIPO DO CGC do cliente for "CNPJ" e a inscrição estadual for "ISENTO", então o novo campo deverá receber true automaticamente;
    //    Se o TIPO DO CGC do cliente for "CNPJ" e a inscrição estadual for diferente de ISENTO, então o novo campo deverá receber false automaticamente; 
    if ($("tipocgc").value == "F") {
        $("consumidorFinal").checked = true;
    } else if ($("tipocgc").value == "J" && $("IE").value == "ISENTO") {
        $("consumidorFinal").checked = true;
    } else if ($("tipocgc").value == "J" && $("IE").value != "ISENTO") {
        $("consumidorFinal").checked = false;
    }
}
function label() {
    if ($("tipoComissao").value == "1") {
        $("sobre2").style.display = "";
        $("sobre3").style.display = "none";
        $("tipoBaseComissao").style.display = "none";
    } else {
        $("sobre2").style.display = "none";
        $("sobre3").style.display = "";
        $("tipoBaseComissao").style.display = "";
    }
    if ($("tipoComissao2").value == "1") {
        $("sobre2_sup").style.display = "";
        $("sobre3_sup").style.display = "none";
    } else {
        $("sobre2_sup").style.display = "none";
        $("sobre3_sup").style.display = "";
    }
}
//*************  ENDEREOS DE ENTREGA  *********************  FIM
function alteraTabelaRemetente() {
    $('trTabelaRemetente').style.display = 'none';
    $('imgTabelaRemetente').style.display = 'none';
    if ($('tipoTabelaRemetente').value == 'q') {
        $('trTabelaRemetente').style.display = '';
        $('imgTabelaRemetente').style.display = '';
    }
}
function criterioCalculoComissao(calculoComissao, tipoVendedor) {
    if (tipoVendedor == "Vendedor") {
        if (calculoComissao == "l") {
            $("divIcmsVendedor").style.display = "";
            $("divImpostosVendedor").style.display = "";
//                $("divDeduzirVendedor").style.display = "";
        } else if (calculoComissao == "b") {
            $("divIcmsVendedor").style.display = "none";
            $("divImpostosVendedor").style.display = "none";
//                $("divDeduzirVendedor").style.display = "none";
        }
    } else if (tipoVendedor == "Supervisor") {
        if (calculoComissao == "l") {
            $("divIcmsSupervisor").style.display = "";
            $("divImpostosSupervisor").style.display = "";
//                $("divDeduzirSupervisor").style.display = "";
        } else if (calculoComissao == "b") {
            $("divIcmsSupervisor").style.display = "none";
            $("divImpostosSupervisor").style.display = "none";
//                $("divDeduzirSupervisor").style.display = "none";
        }
    }
}
function alterarDefaultTipoFrete() {
    if ($("utilizartipofretetabela").checked) {
        $("tipotabela").disabled = true;
    } else {
        $("tipotabela").disabled = false;
    }
}
function alterarTipoPgtoContaCorrente() {
    if ($("pagtoFrete").value == 'c') {
        $("tipoPgtoContaCorrente").style.display = "";
    } else {
        $("tipoPgtoContaCorrente").style.display = "none";
        $("lbCom").style.display = "";
        $("condicaopgt").style.display = "";
        $("tipoDiasVencimento").style.display = "";
        $("tdDiasSemana").style.display = "";
        $("FaixaVencimento").style.display = "none";
        $("tipoCobrancaTemp").style.display = "";
    }
    alterarFaixaVencimento();
}
function alterarFaixaVencimento() {
    if ($("pagtoFrete").value == 'c' && $("tipoPgtoContaCorrente").value == 'v') {
        $("lbCom").style.display = "none";
        $("condicaopgt").style.display = "none";
        $("tipoDiasVencimento").style.display = "none";
        $("tipoCobrancaTemp").style.display = "";
        $("tdDiasSemana").style.display = "";
        $("FaixaVencimento").style.display = "";
    } else if ($("tipoPgtoContaCorrente").value == 'q') {
        $("lbCom").style.display = "";
        $("condicaopgt").style.display = "";
        $("tipoDiasVencimento").style.display = "";
        $("FaixaVencimento").style.display = "none";
        $("tipoCobrancaTemp").style.display = "";
    }
}
function alterarTipoComissaoVendedor() {
    var valor = $("tipoComissaoVendedor").value
    if (valor == 1) {
        $("lbRodoFracVendedor").style.display = "none";
        $("ComissaoRodoviarioFracionadoVendedor").style.display = "none";
        $("lbRodLotVendedor").style.display = "none";
        $("ComissaoRodoviarioLotacaoVendedor").style.display = "none";
        $("lbAereoVendedor").style.display = "none";
        $("sobre3").style.display = "";
    } else if (valor == 2) {
        $("lbRodoFracVendedor").style.display = "";
        $("ComissaoRodoviarioFracionadoVendedor").style.display = "";
        $("lbRodLotVendedor").style.display = "";
        $("ComissaoRodoviarioLotacaoVendedor").style.display = "";
        $("lbAereoVendedor").style.display = "";
        $("sobre3").style.display = "none";
    }
    label();
}
function alterarTipoComissaoSupervisor() {
    var valor = $("tipoComissaoSupervisor").value;
    if (valor == 1) {
        $("lbRodoFracSupervisor").style.display = "none";
        $("ComissaoRodoviarioFracionadoSupervisor").style.display = "none";
        $("lbRodoLotSupervisor").style.display = "none";
        $("ComissaoRodoviarioLotacaoSupervisor").style.display = "none";
        $("tdAereo2").style.display = "none";
    } else if (valor == 2) {
        $("lbRodoFracSupervisor").style.display = "";
        $("ComissaoRodoviarioFracionadoSupervisor").style.display = "";
        $("lbRodoLotSupervisor").style.display = "";
        $("ComissaoRodoviarioLotacaoSupervisor").style.display = "";
        $("tdAereo2").style.display = "";
    }
}
function tipoClienteA() {
    var tipo = $('tipoCliente').value;
    if (tipo == 'true') {
        //                Element.show($('trInfo'));
        //                Element.show($('tbInfo'));
        Element.show($('tdInfoFinan'));
        Element.show($('tdInfoCom'));
        Element.show($('tdInfoOpe'));
        Element.show($('tdInfoCont'));
        Element.show($('tdRastrCarga'));
        if ($('tdTabPreco') != null) {
            Element.show($('tdTabPreco'));
        }
        Element.show($('tdAbaEdi'));
    } else {
        //                Element.hide($('trInfo'));
        //              Element.hide($('tbInfo'));
        Element.hide($('tdInfoFinan'));
        Element.hide($('tdInfoCom'));
        Element.hide($('tdInfoOpe'));
        Element.hide($('tdInfoCont'));
        Element.hide($('tdRastrCarga'));
        if ($('tdTabPreco') != null) {
            Element.hide($('tdTabPreco'));
        }
        Element.hide($('tdAbaEdi'));
    }
}

function mostrarInfoRepresentante() {
    if ($('chkCobrarTde').checked == true) {
        visivel($("trAltera"));
    } else {
        invisivel($("trAltera"));
    }
}

function localizarContaContabil(conta) {
    jQuery.ajax({
        url: "./PlanoContaControlador?",
        dataType: "text",
        method: "post",
        async: false,
        data: {
            conta: conta,
            acao: "localizarContaContabil"
        },
        success: function (data) {
            var conta = jQuery.parseJSON(data);
            espereEnviar("", false);
            if (conta == null) {
                alert("Plano de contas não encontrado!");
                return false;
            } else if (conta == '') {
                alert("Plano de contas não encontrado!");
                return false;
            } else if (conta.erro == 'true') {
                alert("Plano de contas não encontrado!");
                return false;
            } else {
                $('plano_contas_id').value = conta.id;
                $('cod_conta').value = conta.codigo;
                $('plano_conta_descricao').value = conta.descricao;
            }
        }, error: function () {
            alert("Erro inesperado, favor refazer a operação.");
        }
    });
}

function getHoraValida() {
    var qtd = $("qtdColetasAutomaticas").value;
    var i = 0;
    for (i = 1; i <= qtd; i++) {
        if ($("hora_" + i) != null) {
            if ($("hora_" + i).value == null || $("hora_" + i).value == "") {
                alert("A hora da coleta automática não pode ficar em branco!");
                return true;
            }
        }
    }
}

function ckDataNull() {
    var qtdColetas = $("qtdColetasAutomaticas").value;
    var i = 1;
    for (i = 1; i <= qtdColetas; i++) {
        if ($("dtInicio_" + i) != null && $("dtInicio_" + i) != undefined) {
            if ($("dtInicio_" + i).value == "null" || $("dtInicio_" + i).value == "") {
                alert("Data nula!");
                return false;
            }
        }
    }
}

function mostrarEstoqueGrupos(indexCont, indexPerm) {

    if ($("permId_" + indexCont + "_" + indexPerm).value == 0) {
        if ($("permChk_" + indexCont + "_" + indexPerm).checked) {
            $("tr_grupos_" + indexCont).style.display = "";
        } else {
            $("tr_grupos_" + indexCont).style.display = "none";
        }
    }

}

//Quando o usuário clica em voltar
function voltar() {
    parent.document.location.replace("ConsultaControlador?codTela=10");
}

function verificaCGC() {
    //objeto funcao usado na requisicao Ajax(uma espécie de evento)
    function e(transport) {
        var textoresposta = transport.responseText;
        espereEnviar("", false);
        //se deu algum erro na requisicao...
        if (textoresposta == "-1") {
            abrirConsultarCliente();
            //                    $('rzs').focus();
            return false;
        } else {
            if (confirm("Cliente já cadastrado no código " + textoresposta + ". Deseja visualizá-lo ?")) {
                location.replace("./cadcliente?acao=editar&id=" + textoresposta + "&ex=false");
            }
        }
    }//funcao e()          
    if (!isCpf($("cnpj").value) && $("tipocgc").value == "F" && $("uf_origem").value != "EX") {
        alert("Cpf Inválido.");
        $("cnpj").focus();
        return false;
    } else if (!isCnpj($("cnpj").value) && $("tipocgc").value == "J" && $("uf_origem").value != "EX") {
        alert("Cnpj Inválido.");
        $("cnpj").focus();
        return false;
    }
    var cgc = ''
    if ($("tipocgc").value == 'J')
        cgc = formatCpfCnpj($('cnpj').value, false, true);
    else
        cgc = formatCpfCnpj($('cnpj').value, false, false);
    espereEnviar("", true);
    tryRequestToServer(function () {
        new Ajax.Request("./cadcliente?acao=verificar_cgc&cnpj=" + cgc, {method: 'post', onSuccess: e, onError: e});
    });
}

function Endereco(id, logradouro, cep, numeroLogradouro, complemento, cidadeId, cidadeDesc, bairro, uf, idBairro, descBairro) {
    this.id = (id == undefined || id == null ? 0 : id);
    this.cidadeId = (cidadeId == undefined || cidadeId == null ? 0 : cidadeId);
    this.logradouro = (logradouro == undefined || logradouro == null ? "" : logradouro);
    this.cidadeDesc = (cidadeDesc == undefined || cidadeDesc == null ? "" : cidadeDesc);
    this.bairro = (bairro == undefined || bairro == null ? "" : bairro);
    this.uf = (uf == undefined || uf == null ? "" : uf);
    this.complemento = (complemento == undefined || complemento == null ? "" : complemento);
    this.cep = (cep == undefined || cep == null ? "" : cep);
    this.numeroLogradouro = (numeroLogradouro == undefined || numeroLogradouro == null ? "0" : numeroLogradouro);
    this.idBairro = (idBairro == undefined || idBairro == null ? "0" : idBairro);
    this.descBairro = (descBairro == undefined || descBairro == null ? "0" : descBairro);
}
function ColetasAutomaticas(id, filial_resp_id, filial_resp, diaSemana, hora, dtInicio) {
    this.id = (id == undefined || id == null ? 0 : id);
    this.filial_resp_id = (filial_resp_id == undefined || filial_resp_id == null ? 0 : filial_resp_id);
    this.filial_resp = (filial_resp == undefined || filial_resp == null ? "" : filial_resp);
    this.diaSemana = (diaSemana == undefined || diaSemana == null ? 0 : diaSemana);
    this.hora = (hora == undefined || hora == null ? "" : hora);

}
function DiasVencimentoFatura(id, diaInicial, diaFinal, diaVencimento, mes) {
    this.id = (id == undefined || id == null ? 0 : id);
    this.diaInicial = (diaInicial == undefined || diaInicial == null ? 0 : diaInicial);
    this.diaFinal = (diaFinal == undefined || diaFinal == null ? 0 : diaFinal);
    this.diaVencimento = (diaVencimento == undefined || diaVencimento == null ? 0 : diaVencimento);
    this.mes = (mes == undefined || mes == null ? "" : mes);
}
function Cliente(cnpj, tipoCgc, razaoSocial, inscest, nomeFantasia, endereco, bairro, uf, cidade, codIbge, bacen, pais, cep, complemento, fone) {
    this.cnpj = (cnpj == undefined || cnpj == null ? "" : cnpj);
    this.tipoCgc = (tipoCgc == undefined || tipoCgc == null ? "" : tipoCgc);
    this.razaoSocial = (razaoSocial == undefined || razaoSocial == null ? "" : razaoSocial);
    this.inscest = (inscest == undefined || inscest == null ? "" : inscest);
    this.nomeFantasia = (nomeFantasia == undefined || nomeFantasia == null ? "" : nomeFantasia);
    this.endereco = (endereco == undefined || endereco == null ? "" : endereco);
    this.bairro = (bairro == undefined || bairro == null ? "" : bairro);
    this.uf = (uf == undefined || uf == null ? "" : uf);
    this.cidade = (cidade == undefined || cidade == null ? "" : cidade);
    this.codIbge = (codIbge == undefined || codIbge == null ? "" : codIbge);
    this.bacen = (bacen == undefined || bacen == null ? "" : bacen);
    this.pais = (pais == undefined || pais == null ? "" : pais);
    this.cep = (cep == undefined || cep == null ? "" : cep);
    this.complemento = (complemento == undefined || complemento == null ? "" : complemento);
    this.fone = (fone == undefined || fone == null ? "" : fone);
}


/*
 * CHAMADA QUE REMETE AO CLIENTECONTROLADOR PARA APENAS CRIAR A IMAGEM E SUA RESPECTIVA PASTA
 */

function carregarImagemCliente() {
    jQuery('input[type=file]').each(function (index) {
        if (jQuery('input[type=file]').eq(index).val() != "") {
            readURL(this);
            jQuery('#LOGO_IMG').show();
        }
    });
    salvarImg();
    jQuery("#nomeImagem").val(document.getElementById("carregarImg").files[0].name);
}

function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            jQuery(input).next()
                    .attr('src', e.target.result)
        };
        reader.readAsDataURL(input.files[0]);
    } else {
        var img = input.value;
    }
}

function salvarImg() {
    var idCliente = $("id").value;
    var descricao = "Logomarca cliente : " + idCliente;
    var carregarImg = document.getElementById("carregarImg").files[0].name;
    var logomarcaCliente = ($("logomarcaCliente") != null ? $("logomarcaCliente").value : "0");
    var imagem = new Image();
    imagem.src = carregarImg;
    var tamanhoImagem = imagem.fileSize;

    if (carregarImg == "") {
        alert("Selecione a Imagem!");
        return false;
    }
    var extensoesOk = ",.gif,.jpg,.png,.jpeg,";
    var extensao = "," + carregarImg.substr(carregarImg.length - 4).toLowerCase() + ",";
    if (extensoesOk.indexOf(extensao) == -1) {
        $('carregarImg').value = '';
        $('nomeImagem').value = '';
        $('LOGO_IMG').style.display = 'none';
        return  alert("Extensão de Arquivo de imagem Inválida!.");
    }
    if (tamanhoImagem > 100000) {
        return alert("O tamanho máximo do arquivo foi alcançado! Favor utilizar arquivos menores que 100Kb.");
    }


    var reader = new FileReader();
    if (confirm("Deseja anexar a imagem: " + carregarImg)) {
        reader.onload = function (e) {
            jQuery('#LOGO_IMG').attr('src', e.target.result);
        }
        reader.readAsDataURL(document.getElementById("carregarImg").files[0]);
        //$("LOGO_IMG").value = carregarImg;
        $("logomarcaCliente").value = carregarImg;
        $("descricaoLogomarcaCliente").value = descricao;
        $("extensaoLogomarcaCliente").value = extensao;
        

        window.open('about:blank', 'pop', 'width=400, height=300');
        var j = 0;
        while (jQuery("#formularioImg2").find('input[type=file]')[j]) {
            jQuery(jQuery("#formularioImg2").find('input[type=file]')[j]).remove();
            j++;
        }
        //foi retirado o metodo clone, pois não pega as funções iniciais do objeto, condição que podemos passar o objeto diretamente. historia 3246 = Daniel Cassimiro
        jQuery("#formularioImg2").append(jQuery('#carregarImg'));
        jQuery("#formularioImg2").hide();
        var formulario = $("formularioImg2");
        formulario.action = "./ClienteControlador?acao=cadastrarLogomarcaCliente&idcliente=" + idCliente + "&descricao=" + descricao + "&logomarcaCliente=" + logomarcaCliente;
        formulario.target = "pop";
        formulario.method = "post";
        formulario.enctype = "multipart/form-data";
        formulario.submit();


    }
}
function carregarIMG() {
    var idCliente = $("id").value;
    jQuery.ajax({
        url: "./ClienteControlador?",
        dataType: "text",
        method: "post",
        async: false,
        data: {
            acao: "carregarLogomarcaCliente",
            idCliente: idCliente

        },
        success: function (data) {
            if (data !== '') {
                var propObj = jQuery.parseJSON(data);
                if (propObj != null) {
                    var clienteImagem = propObj.clienteImagem;
                    $("idLogomarcaCliente").value = clienteImagem.id;
                    $("descricaoLogomarcaCliente").value = clienteImagem.descricao;
                    $("extensaoLogomarcaCliente").value = clienteImagem.extensao;
                    $("logomarcaCliente").value = idCliente + "_" + clienteImagem.id + "." + clienteImagem.extensao;
                    $("LOGO_IMG").style.display = "";
                    $("LOGO_IMG").src = "./img/logoCliente/" + $("logomarcaCliente").value;
                }
            }
        },
        falure: function () {

        }
    });
}
function limparLogomarca() {
    if (jQuery("#LOGO_IMG").attr("src") != undefined && jQuery("#LOGO_IMG").attr("src") != "") {
        // coloquei em outro if pois ele sempre colocava o alert, mesmo se a logo não tem SRC.
        if (!(confirm("Deseja excluir a logomarca do cliente?"))) {
            return false;
        }
    } else {
        return false;
    }
    var idCliente = $("id").value;
    var imagemId = $("idLogomarcaCliente").value;
    var extensao = $("extensaoLogomarcaCliente").value;
    if (imagemId != 0 && imagemId != "") {
        jQuery.ajax({
            url: "./ClienteControlador?",
            dataType: "text",
            method: "post",
            async: false,
            data: {
                acao: "deletarLogomarcaCliente",
                idCliente: idCliente,
                idImagem: imagemId,
                extensao: extensao
            },
            success: function (e) {
                alert("Logomarca do cliente removida com sucesso!");
            },
            falure: function () {
                alert("Erro ao processar a remoção!");
            }
        });

    }
    $("idLogomarcaCliente").value = "0";
    $("descricaoLogomarcaCliente").value = "";
    $("extensaoLogomarcaCliente").value = "";
    $("logomarcaCliente").value = "";
    $("LOGO_IMG").style.display = "none";
    $("LOGO_IMG").src = "";
}

function negociacaoAdiantamento(idMotorista, nomeMotorista, idNegociacao, descricaoNegociacao, idExcecao) {
    this.idMotorista = idMotorista == null || idMotorista == undefined ? "0" : idMotorista;
    this.nomeMotorista = nomeMotorista == null || nomeMotorista == undefined ? "" : nomeMotorista;
    this.idNegociacao = idNegociacao == null || idNegociacao == undefined ? "0" : idNegociacao;
    this.descricaoNegociacao = descricaoNegociacao == null || descricaoNegociacao == undefined ? "" : descricaoNegociacao;
    this.idExcecao = idExcecao == null || idExcecao == undefined ? "0" : idExcecao;
}

function abrirLocalizaTipoProduto() {
    window.open('./localiza?acao=consultar&idlista=37','Tipo_Produto_Destinatario','top=80,left=150,height=400,width=500,resizable=yes,status=1,scrollbars=1');
}

function limparLocalizaTipoProduto() {
    $("tipoProdutoDestinatarioId").value = "0";
    $("tipoProdutoDestinatario").value = "";
}

function abrirLocalizaMotorista(index) {
    abrirLocaliza('./localiza?acao=consultar&paramaux=carta&idlista=10&fecharJanela=true', 'Motorista');
    $("apontadorMotor").value = index;
    $("idMotorista_" + index).value = $("idmotorista").value;
    $("nomeMotorista_" + index).value = $("motor_nome").value;
}

function limparLocalizaMotorista(index) {
    $("idMotorista_" + index).value = "0";
    $("nomeMotorista_" + index).value = "";
}

function removerNegociacao(index) {
    var idNegociacao = $("idExcecaoCli_" + index).value;
    var idCliente = $("id").value;
    if (confirm("Deseja remover a negociacao?")) {
        if (idNegociacao != 0) {
            jQuery.ajax({
                url: "./ClienteControlador?",
                dataType: "text",
                method: "post",
                async: false,
                data: {
                    acao: "deletarNegociacaoCliente",
                    idCliente: idCliente,
                    idNegociacao: idNegociacao
                },
                success: function (e) {
                    Element.remove($("trNegociacao_" + index));
                },
                falure: function () {
                    alert("Erro ao processar a remoção!");
                }
            });
        } else {
            Element.remove($("trNegociacao_" + index));
        }
    }
}
var contador = 0;

function mostrarDOMNegociacao() {
    var id = $("negociacaoAdiantamentoSlc").value;
    if (id != 0) {
        $("tabelaNegociacao").style.display = "";
    } else {
        $("tabelaNegociacao").style.display = "none";
    }
}

function montarDomNegociacaoAdtMotorista(negoAdiantamento) {
    var negociacao = null;
    negociacao = negoAdiantamento == null || negoAdiantamento == undefined ? new negociacaoAdiantamento() : negoAdiantamento;
    var classtyle = (contador % 2 === 0 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign");
    var trNegociacao = Builder.node("tr", {
        id: "trNegociacao_" + contador,
        name: "trNegociacao_" + contador
    });
    var tdlblMotorista = Builder.node("td", {
        class: classtyle,
        align: "right"
    });

    var tdlocalMotorista = Builder.node("td", {
        class: classtyle,
        align: "left"
    });

    var inpthidmotorista = Builder.node("input", {
        type: "hidden",
        id: "idMotorista_" + contador,
        name: "idMotorista_" + contador
    });
    inpthidmotorista.value = negociacao.idMotorista;

    var lblMotorista = Builder.node("label", {style: "text-align: right"});
    lblMotorista.innerHTML = "Motorista : ";

    var inputIdExcecao = Builder.node("input", {
        id: "idExcecaoCli_" + contador,
        name: "idExcecaoCli_" + contador,
        type: "hidden"
    });
    inputIdExcecao.value = negociacao.idExcecao;

    var inptLocNomeMotorista = Builder.node("input", {
        class: "inputReadOnly",
        id: "nomeMotorista_" + contador,
        name: "nomeMotorista_" + contador,
        readonly: ""
    });
    inptLocNomeMotorista.value = negociacao.nomeMotorista;
    var inpLocMotorista = Builder.node("input", {
        id: "localizaMotorista_" + contador,
        name: "localizaMotorista_" + contador,
        type: "button",
        class: "inputbotao",
        onclick: "tryRequestToServer(function(){abrirLocalizaMotorista(" + contador + ");})",
        value: "..."
    });

    var imglixoMotor = Builder.node("img", {
        src: "img/borracha.gif",
        onclick: "limparLocalizaMotorista(" + contador + ");",
        class: "imagemLink"
    });
    var tdSelectNegociacao = Builder.node("td", {
        class: classtyle
    });
    var tdlblSelectNegociacao = Builder.node("td", {
        class: classtyle,
        align: "right"
    });
    var labelSelect = Builder.node("label", {});
    labelSelect.innerHTML = "Negociação de Adiantamento: ";
    var inpSelectNegociacao = Builder.node("select", {
        id: "negociacaoMotorCliente_" + contador,
        name: "negociacaoMotorCliente_" + contador,
        class: "inputtexto"
    });
    var lblEspaco = Builder.node("label", {});
    lblEspaco.innerHTML = "&nbsp; ";
    var lblEspaco2 = Builder.node("label", {});
    lblEspaco2.innerHTML = "&nbsp; ";
    var inpSelectNegociacaoOptDft = Builder.node("option", {
        value: "0"
    });

    var tdRemoveElement = Builder.node("td", {
        class: classtyle
    });
    var imgElementRemove = Builder.node("img", {
        src: "img/lixo.png",
        class: "imagemLink",
        onclick: "removerNegociacao(" + contador + ")"
    });
    tdRemoveElement.appendChild(imgElementRemove);
    inpSelectNegociacaoOptDft.innerHTML = "Não Informado";
    inpSelectNegociacao.appendChild(inpSelectNegociacaoOptDft);
    povoarSelect(inpSelectNegociacao, listaNegociacoes);
    inpSelectNegociacao.value = negociacao.idNegociacao;
    tdSelectNegociacao.appendChild(inpSelectNegociacao);

    tdlblSelectNegociacao.appendChild(labelSelect);
    tdlblMotorista.appendChild(lblMotorista);
    tdlocalMotorista.appendChild(inputIdExcecao);
    tdlocalMotorista.appendChild(inpthidmotorista);
    tdlocalMotorista.appendChild(lblEspaco);
    tdlocalMotorista.appendChild(inptLocNomeMotorista);
    tdlocalMotorista.appendChild(lblEspaco2);
    tdlocalMotorista.appendChild(inpLocMotorista);
    tdlocalMotorista.appendChild(lblEspaco);
    tdlocalMotorista.appendChild(imglixoMotor);
    trNegociacao.appendChild(tdRemoveElement);
    trNegociacao.appendChild(tdlblMotorista);
    trNegociacao.appendChild(tdlocalMotorista);
    trNegociacao.appendChild(tdlblSelectNegociacao);
    trNegociacao.appendChild(tdSelectNegociacao);

    $("tabelaNegociacao").appendChild(trNegociacao);

    contador++;
    $("maxExcecoes").value = contador;
}

function abrirLocalizarOcorrencia(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(40, "Ocorrencia", "");
}

function abrirLocalizarOcorrenciaAutomatica(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(40, "Ocorrencia_Automatica", "");

}

var index = 0;
var listLayoutEDI_OCOREN_ENV = new Array();
listLayoutEDI_OCOREN_ENV[++index] = new Option("3", "Enviar Autom.");

var listLayoutEDI_OCOREN_ALL = new Array();
listLayoutEDI_OCOREN_ALL[++index] = new Option("1", "Manual");
listLayoutEDI_OCOREN_ALL[++index] = new Option("2", "Automática (FTP)");
listLayoutEDI_OCOREN_ALL[++index] = new Option("4", "Automática (E-mail)");

function escolherLayout(element, idLayout, index, tipo) {

    if (tipo == "o") {
        let select = jQuery("#tipoGeracao_o_" + index);

        if ((getLayout(idLayout) != undefined && getLayout(idLayout).extensao == "env") || idLayout == "sap-webservice") {
            visivel(element);
            select.html('');
            povoarSelect($("tipoGeracao_o_" + index), listLayoutEDI_OCOREN_ENV);
            // Irá chamar o evento change do select, para mostrar ou ocultar as opções de login, cron, etc
            select.trigger('change');
        } else {
            invisivel(element);
            select.html('');
            povoarSelect($("tipoGeracao_o_" + index), listLayoutEDI_OCOREN_ALL);
            // Irá chamar o evento change do select, para mostrar ou ocultar as opções de login, cron, etc
            select.trigger('change');
        }
    }
}

function handlerEnviarElement(_elemento, tipo, trCron) {
    if (tipo == 3) {
        visivel(trCron);
        visivel(_elemento);
    } else {
        if (tipo == 1) {
            invisivel(trCron);
        }
        invisivel(_elemento);
    }
}
function definirTipoGeracaoEdi(tipo,index){
    if($("versao_"+tipo+"_"+index).value == 'webserviceClaro'){
        jQuery("#tipoGeracao_"+tipo+"_"+index).html('<option value="1">Manual</option>');
    }else if($("versao_"+tipo+"_"+index).value == 'sap-webservice'){
        jQuery("#tipoGeracao_"+tipo+"_"+index).html('<option value="3">Enviar Autom.</option>');
    }else{
        jQuery("#tipoGeracao_"+tipo+"_"+index).html('<option value="1">Manual</option><option value="2">Automática (FTP)</option><option value="4">Automática (E-mail)</option>');
    }
}
function addClienteLayoutEDI(tipo, layout, id, tipoGeracao, listCron, login, senha, chave, extensao) {
    try {
        layout = (layout == null || layout == undefined ? "" : layout);
        tipoGeracao = (tipoGeracao == null || tipoGeracao == undefined ? "1" : tipoGeracao);
        id = (id == null || id == undefined ? 0 : id);
        listCron = (listCron != null && listCron != undefined ? listCron : new Array());
        var count = parseInt($("maxLayEDI_" + tipo).value, 10);
        var lista = null;
        switch (tipo) {
            case "c":
                lista = listLayoutEDI_c;
                break;
            case "f":
                lista = listLayoutEDI_f;
                break;
            case "o":
                lista = listLayoutEDI_o;
                break;
        }
        count++;
        var classe = count % 2 == 1 ? "CelulaZebra2NoAlign" : "CelulaZebra1NoAlign";
        var _tr = Builder.node("tr", {id: "trEDI1_" + tipo + "_" + count, className: classe});

        var _trEnviAuto = Builder.node("tr", {id: "trEDIEnviAuto_" + tipo + "_" + count, style: "display:none"});

        var _trEnviLogin = Builder.node("tr", {id: "trEnviLogin_" + tipo + "_" + count, colSpan: "4", width: "100%", className: classe});

        var _tableLogin = Builder.node("table", {id: "tableLogin_" + tipo + "_" + count, width: "100%"});

        var _tdLogin = Builder.node("td", {id: "tdLogin_" + tipo + "_" + count, width: "10%"});

        var _labelLogin = Builder.node("label", "Login: ");

        var _tdLoginInput = Builder.node("td", {id: "tdSenha_" + tipo + "_" + count, width: "15%"});

        var _LoginInput = Builder.node('input', {
            type: "text",
            id: "loginEdi_" + tipo + "_" + count,
            name: "loginEdi_" + tipo + "_" + count,
            className: 'inputtexto',
            size: "10",
            value: (login ? login : "")
        });
        //---------- Senha
        var _tdSenha = Builder.node("td", {id: "tdLogin_" + tipo + "_" + count, width: "10%"});

        var _labelSenha = Builder.node("label", "Senha: ");

        var _tdSenhaInput = Builder.node("td", {id: "tdSenha_" + tipo + "_" + count, width: "15%"});

        var _SenhaInput = Builder.node('input', {
            type: "text",
            id: "senhaEdi_" + tipo + "_" + count,
            name: "senhaEdi_" + tipo + "_" + count,
            className: 'inputtexto',
            size: "10",
            value: (senha ? senha : "")
        });
        //---------- Chave
        var _tdChave = Builder.node("td", {id: "tdLogin_" + tipo + "_" + count, width: "20%"});

        var _labelChave = Builder.node("label", "Chave/TOKEN: ");

        var _tdChaveInput = Builder.node("td", {id: "tdSenha_" + tipo + "_" + count, width: "35%"});

        var _chaveInput = Builder.node('input', {
            type: "text",
            id: "chaveEdi_" + tipo + "_" + count,
            name: "chaveEdi_" + tipo + "_" + count,
            className: 'inputtexto',
            size: "20",
            value: (chave ? chave : "")
        });

        var _tr2 = Builder.node("tr", {id: "trEDI2_" + tipo + "_" + count});

        var _td2 = Builder.node("td", {id: "tdEDI2_" + tipo + "_" + count, colSpan: "4", width: "100%"});

        var _tdEnviAuto = Builder.node("td", {id: "tdEDIEnvia_" + tipo + "_" + count, colSpan: "4", width: "100%", style: "display:none"});

        var _table = Builder.node("table", {id: "tableEDI2_" + tipo + "_" + count, width: "100%"});

        var _tableEnviAuto = Builder.node("table", {id: "tableEDI2EnviAuto_" + tipo + "_" + count, width: "100%"});

        var _tbody = Builder.node("tbody", {id: "tbodyEDI2_" + tipo + "_" + count});

        var _tbodyEnviauto = Builder.node("tbody", {id: "tbodyEDI2EnviAuto_" + tipo + "_" + count});

        var _tdLixo = Builder.node("td", {align: "center"});
        var _tdSlc = Builder.node("td", {id: "tdEDI_" + tipo + "_" + count, align: "left"});
        var _tdTipoDesc = Builder.node("td", {id: "tdEDIDesc_" + tipo + "_" + count, align: "rigth"});
        var _tdTipoValor = Builder.node("td", {id: "tdEDIValor_" + tipo + "_" + count, align: "left"});

        var _labelTp = Builder.node("label", "Forma Ger.");

        var _slcEdi = Builder.node("select", {id: "versao_" + tipo + "_" + count, name: "versao_" + tipo + "_" + count, className: "fieldMin", onChange: "escolherLayout(" + _trEnviAuto.id + ", this.value" + ", " + count + ",'" + tipo + "');definirTipoGeracaoEdi('"+tipo+"',"+count+");"});
        _slcEdi.style.width = "100px";

        var _slcTipo = Builder.node("select", {id: "tipoGeracao_" + tipo + "_" + count, name: "tipoGeracao_" + tipo + "_" + count,
            className: "fieldMin",
            onChange: "handlerElement("+_tr2.id+", this.value"+");handlerEnviarElement("+_tdEnviAuto.id+", this.value"+", "+_tr2.id+");"
        });
        var _imgLIxo = Builder.node('IMG', {
            src: 'img/lixo.png',
            title: 'Apagar Layout',
            className: 'imagemLink',
            onClick: "removerLayout(" + count + ",'" + tipo + "')"
        });
        var _idLayout = Builder.node('input', {
            type: "hidden",
            id: "idLayout_" + tipo + "_" + count,
            name: "idLayout_" + tipo + "_" + count,
            value: id
        });
        var _extensaoLayout = Builder.node('input', {
            type: "hidden",
            id: "extensaoLayout_" + tipo + "_" + count,
            name: "extensaoLayout_" + tipo + "_" + count,
            value: (extensao == null || extensao == undefined ? '' : extensao)
        });
        var _qtdCron = Builder.node('input', {
            type: "hidden",
            id: "qtdCron_" + tipo + "_" + count,
            name: "qtdCron_" + tipo + "_" + count,
            value: 0
        });
        var optLayout = null;
        if (lista != null) {
            for (var i = 0; i < lista.length; i++) {
                optLayout = Builder.node("option", {
                    value: lista[i].valor
                });
                Element.update(optLayout, lista[i].descricao);
                _slcEdi.appendChild(optLayout);
            }
        }

        _slcEdi.value = layout;

        if ((getLayout(layout) === undefined || getLayout(layout).extensao !== 'env') && layout !== "sap-webservice" && layout !== "webserviceClaro") {
            // Se o layout for undefined, ou a extensão não é "env", irá mostrar as opções "manual", "email" e "ftp"
            optLayout = Builder.node("option", {value: "1"});// manual
            Element.update(optLayout, "Manual");
            _slcTipo.appendChild(optLayout);

            optLayout = Builder.node("option", {value: "2"});// automática
            Element.update(optLayout, "Automática (FTP)");
            _slcTipo.appendChild(optLayout);

            optLayout = Builder.node("option", {value: "4"});// automática
            Element.update(optLayout, "Automática (E-mail)");
            _slcTipo.appendChild(optLayout);

        } else if(layout == "sap-webservice"){
            // Se o layout não for undefined e a extensão é "env", irá somente mostrar a opção "enviar autom";
            optLayout = Builder.node("option", {value: "3"});//Envio para webservice
            Element.update(optLayout, "Enviar Autom.");
            _slcTipo.appendChild(optLayout);
        } else if(layout == "webserviceClaro"){
            optLayout = Builder.node("option", {value: "1"});// manual
            Element.update(optLayout, "Manual");
            _slcTipo.appendChild(optLayout);
        }

        _slcTipo.value = tipoGeracao;
        _tdSlc.appendChild(_slcEdi);//Criando o select EDI

        _tdLixo.appendChild(_idLayout);
        _tdLixo.appendChild(_imgLIxo);
        _tdLixo.appendChild(_qtdCron);

        _tdTipoDesc.appendChild(_labelTp);
        _tdTipoValor.appendChild(_slcTipo);
        _tdTipoValor.appendChild(_extensaoLayout);

        //Primeira TR
        _tr.appendChild(_tdLixo);//lixeira
        _tr.appendChild(_tdSlc);
        _tr.appendChild(_tdTipoDesc);
        _tr.appendChild(_tdTipoValor);


        _table.appendChild(_tbody);
        _td2.appendChild(_table);
        _tr2.appendChild(_td2);

        //Só adicionar esses campos quando for o EDI ocoren 
        if (tipo == "o") {
            _tdLogin.appendChild(_labelLogin);
            _trEnviLogin.appendChild(_tdLogin);
            _tdLoginInput.appendChild(_LoginInput);
            _trEnviLogin.appendChild(_tdLoginInput);

            _tdSenha.appendChild(_labelSenha);
            _trEnviLogin.appendChild(_tdSenha);
            _tdSenhaInput.appendChild(_SenhaInput);
            _trEnviLogin.appendChild(_tdSenhaInput);

            _tdChave.appendChild(_labelChave);
            _trEnviLogin.appendChild(_tdChave);
            _tdChaveInput.appendChild(_chaveInput);
            _trEnviLogin.appendChild(_tdChaveInput);


            _tableLogin.appendChild(_trEnviLogin);
            _tableEnviAuto.appendChild(_tbodyEnviauto);

            _tdEnviAuto.appendChild(_tableLogin);
            _tdEnviAuto.appendChild(_tableEnviAuto);
            _trEnviAuto.appendChild(_tdEnviAuto);

        }

        $("maxLayEDI_" + tipo).value = count;
        $("tb_" + tipo).appendChild(_tr);
        $("tb_" + tipo).appendChild(_tr2);
        $("tb_" + tipo).appendChild(_trEnviAuto);

        addCronRotulo(_tbody, classe);


        if (tipoGeracao == "1") {
            invisivel(_tr2);
        } else
        if (tipoGeracao == "3") {
            visivel(_trEnviAuto);
            if ($("acao").value == "editar") {
                handlerEnviarElement(_tdEnviAuto, 3, _tr2);
            }
        }

        if (tipoGeracao != "1") { // Se não for por geração MANUAL, não deve ser montada a TR de CRON
            if (listCron != null && listCron.size() > 0) {
                for (var i = 0; i <= listCron.size(); i++) {
                    if (listCron[i] != null) {
                        addCron(_tbody.id, classe, listCron[i]);
                    }
                }   
                
                _tdSlc.appendChild(_slcEdi);//Criando o select EDI
                
                _tdLixo.appendChild(_idLayout);
                _tdLixo.appendChild(_imgLIxo);
                _tdLixo.appendChild(_qtdCron);
                
                _tdTipoDesc.appendChild(_labelTp);
                _tdTipoValor.appendChild(_slcTipo);
                _tdTipoValor.appendChild(_extensaoLayout);
                
                //Primeira TR
                _tr.appendChild(_tdLixo);//lixeira
                _tr.appendChild(_tdSlc);
                _tr.appendChild(_tdTipoDesc);
                _tr.appendChild(_tdTipoValor);    
                
                
                _table.appendChild(_tbody);
                _td2.appendChild(_table);
                _tr2.appendChild(_td2);
                
                //Só adicionar esses campos quando for o EDI ocoren 
                if (tipo == "o") {  
                    _tdLogin.appendChild(_labelLogin);
                    _trEnviLogin.appendChild(_tdLogin);
                    _tdLoginInput.appendChild(_LoginInput);
                    _trEnviLogin.appendChild(_tdLoginInput);

                    _tdSenha.appendChild(_labelSenha);
                    _trEnviLogin.appendChild(_tdSenha);
                    _tdSenhaInput.appendChild(_SenhaInput);
                    _trEnviLogin.appendChild(_tdSenhaInput);

                    _tdChave.appendChild(_labelChave);
                    _trEnviLogin.appendChild(_tdChave);
                    _tdChaveInput.appendChild(_chaveInput);
                    _trEnviLogin.appendChild(_tdChaveInput);


                    _tableLogin.appendChild(_trEnviLogin);
                    _tableEnviAuto.appendChild(_tbodyEnviauto);

                    _tdEnviAuto.appendChild(_tableLogin);
                    _tdEnviAuto.appendChild(_tableEnviAuto);
                    _trEnviAuto.appendChild(_tdEnviAuto);
                    
                }
                
                $("maxLayEDI_"+tipo).value = count;
                $("tb_"+tipo).appendChild(_tr);
                $("tb_"+tipo).appendChild(_tr2);        
                $("tb_"+tipo).appendChild(_trEnviAuto);        
                
//                addCronRotulo(_tbody, classe);
//                
//                
//                if (tipoGeracao == "1") {
//                    invisivel(_tr2);
//                }else
//                if(tipoGeracao == "3") {
//                    visivel(_trEnviAuto);
//                    if ($("acao").value == "editar") {
//                        handlerEnviarElement(_tdEnviAuto.id, 3, _tr2.id);
//                    }
//                }
//            
//                if(tipoGeracao != "1"){ // Se não for por geração MANUAL, não deve ser montada a TR de CRON
//                    if (listCron != null && listCron.size() > 0) {
//                        for (var i = 0; i <= listCron.size(); i++) {
//                            if (listCron[i] != null) {
//                                addCron(_tbody.id, classe, listCron[i]);
//                            }
//                        }
//                    }
//                }
            }
        }
            } catch (e) { 
                alert(e);
                console.log(e);
            }
        }

function addCronRotulo(_tabela, classe){
            var tipo = _tabela.id.split("_")[1];
            var idxLayout = _tabela.id.split("_")[2];
            var sufixo = "_"+tipo+"_"+idxLayout;
            var _tr = Builder.node("tr",{id:"trCronRotulo" + sufixo, className: classe});
            var _tdImgAddCron = Builder.node("td",{id:"tdCronDesc" + sufixo, className: classe, width: "10%", align: "center"});
            var _tdRotulo = Builder.node("td",{id:"tdCronValor" + sufixo, className: classe, width: "90%", colSpan: "2"});            
            var _labelCron = Builder.node("label", "Adicionar Momento de Execução");            
            var _imgAdd = Builder.node('IMG',{src:'img/add.gif',title:'Adicionar Momento de Execução',className:'imagemLink',onClick: "addCron('"+_tabela.id + "','" + classe + "')"});            
            _tdImgAddCron.appendChild(_imgAdd);
            _tdRotulo.appendChild(_labelCron);            
            _tr.appendChild(_tdImgAddCron);
            _tr.appendChild(_tdRotulo);           
            _tabela.appendChild(_tr);
        }


function addCronRotulo(_tabela, classe) {
    var tipo = _tabela.id.split("_")[1];
    var idxLayout = _tabela.id.split("_")[2];
    var sufixo = "_" + tipo + "_" + idxLayout;
    var _tr = Builder.node("tr", {id: "trCronRotulo" + sufixo, className: classe});
    var _tdImgAddCron = Builder.node("td", {id: "tdCronDesc" + sufixo, className: classe, width: "10%", align: "center"});
    var _tdRotulo = Builder.node("td", {id: "tdCronValor" + sufixo, className: classe, width: "90%", colSpan: "2"});
    var _labelCron = Builder.node("label", "Adicionar Momento de Execução");
    var _imgAdd = Builder.node('IMG', {src: 'img/add.gif', title: 'Adicionar Momento de Execução', className: 'imagemLink', onClick: "addCron('" + _tabela.id + "','" + classe + "')"});
    _tdImgAddCron.appendChild(_imgAdd);
    _tdRotulo.appendChild(_labelCron);
    _tr.appendChild(_tdImgAddCron);
    _tr.appendChild(_tdRotulo);
    _tabela.appendChild(_tr);
}

function removerContato(idContato, index) {
    if (idContato == null || idContato == undefined) {
        idContato = $("idGeralCont_" + index).value;
    }
    if (!confirm("Realmente deseja excluir o contato?")) {
        return false;
    } else {
        //CRIAR AJAX
        jQuery.ajax({
            url: './jspcadcliente.jsp?',
            dataType: "text",
            method: "post",
//                    async : false,
            data: {
                acao: "removerContatoCliente",
                idContato: idContato
            },
            success: function (data) {
                Element.remove("trCont_" + index);
                Element.remove("tr2Senha_" + index);
                Element.remove("tr3Perm_" + index);
                alert("Contato excluido com sucesso!.")
            },
            error: function (data) {
                console.log(data)
            }
        });
    }
}

function mostrarNormativaGoias(contador) {
    var number = 0;
    if ($("reducaoIcms_" + contador) != null) {
        number = $("stIcms_" + contador).value;

        $("reducaoIcms_" + contador).style.display = "none";
        $("isNormativa598_" + contador).style.display = "none";
        $("labelNormativaIcms_" + contador).style.display = "none";
        $("isNormativa129816go_" + contador).style.display = "none";
        $("labelNormativa129816go_" + contador).style.display = "none";
        $("labelPercentCredito_" + contador).style.display = "none";
        $("inputCreditoFiscal_" + contador).style.display = "none";

    }

    if (number == 3) {
        $("reducaoIcms_" + contador).style.display = "";
        $("isNormativa598_" + contador).style.display = "";
        $("labelNormativaIcms_" + contador).style.display = "";
    } else if (number == 9) {
        $("labelPercentCredito_" + contador).style.display = "";
        $("inputCreditoFiscal_" + contador).style.display = "";
        $("isNormativa129816go_" + contador).style.display = "";
        $("labelNormativa129816go_" + contador).style.display = "";
    }
}

var countCampoDiaria = 0;
function addCampoDiarias(campoDiaria) {
    countCampoDiaria++;
    var listaVeiculo = listaCampoVeiculo;
    var listaTipoProduto = listaCampoTipoProduto;
    if (campoDiaria == null || campoDiaria == undefined) {
        campoDiaria = new CamposDiarias();
    }
    var callLocCidadeDiaria = "abrirLocalizarCidadeDiaria(" + countCampoDiaria + ");"
    var _tdImagemLixo = Builder.node("TD", {});
    var _tdDiaria = Builder.node("TD", {});
    var _tdValorDiaria = Builder.node("TD", {});
    var _tdVeiculo = Builder.node("TD", {});
    var _tdCidade = Builder.node("TD", {});
    var _selectVeiculo = Builder.node("select", {
        id: "camposVeiculo_" + countCampoDiaria,
        name: "camposVeiculo_" + countCampoDiaria,
        className: "fieldMin"});
    var _hidRemoverDiaria = Builder.node("INPUT", {
        type: "hidden",
        id: "idDiaria_" + countCampoDiaria,
        name: "idDiaria_" + countCampoDiaria,
        value: campoDiaria.idDiaria});
    var _inpValorDiaria = Builder.node("INPUT", {
        type: "text",
        id: "descricaoTags_" + countCampoDiaria,
        name: "descricaoTags_" + countCampoDiaria,
        value: colocarVirgula(campoDiaria.valorDiaria),
        size: "8",
        onChange: "seNaoFloatReset(this, '0.00');",
        className: "inputtexto"});
    var _selectTipoProduto = Builder.node("select", {id: "camposTipoProduto_" + countCampoDiaria, name: "camposTipoProduto_" + countCampoDiaria, className: "fieldMin"});
    var _inpCampoVeiculo = null;
    if (listaVeiculo != null) {
        for (var qtdVeiculo = 1; qtdVeiculo < listaVeiculo.length; qtdVeiculo++) {
            _inpCampoVeiculo = Builder.node("option", {
                value: listaVeiculo[qtdVeiculo].valor
            });
            Element.update(_inpCampoVeiculo, listaVeiculo[qtdVeiculo].descricao);
            _selectVeiculo.appendChild(_inpCampoVeiculo);
        }
    }
    if (campoDiaria.idVeiculoDiaria == undefined || campoDiaria.idVeiculoDiaria == "") {
        _selectVeiculo.selectedIndex = 0;
    } else {
        _selectVeiculo.value = campoDiaria.idVeiculoDiaria == 0 ? "" : campoDiaria.idVeiculoDiaria;
    }

    var _inpTipoProdutos = null;
    if (listaTipoProduto != null) {
        for (var qtdProduto = 0; qtdProduto < listaTipoProduto.length; qtdProduto++) {
            _inpTipoProdutos = Builder.node("option", {value: listaTipoProduto[qtdProduto].valor});
            Element.update(_inpTipoProdutos, listaTipoProduto[qtdProduto].descricao);
            _selectTipoProduto.appendChild(_inpTipoProdutos);
        }
    }
    _selectTipoProduto.value = campoDiaria.idDiariaTipoProduto == 0 ? "" : campoDiaria.idDiariaTipoProduto;
    var _imagemExlcuir = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerCampoDiaria(" + countCampoDiaria + ");"});
    var _inpIdCidadeDiaria = Builder.node("input", {
        id: "idCidadeDiaria_" + countCampoDiaria,
        name: "idCidadeDiaria_" + countCampoDiaria,
        type: "hidden",
        className: "inputTexto",
        value: campoDiaria.idCidadeDiarias
    });
    var _inpCidadeDiaria = Builder.node("input", {
        id: "cidadeDiaria_" + countCampoDiaria,
        name: "cidadeDiaria_" + countCampoDiaria,
        type: "text",
        size: "20",
        maxLength: "60",
        className: "inputReadOnly",
        readonly: "",
        value: campoDiaria.descCidadeDiarias
    });
    var _inpUFDiaria = Builder.node("input", {
        id: "ufDiaria_" + countCampoDiaria,
        name: "ufDiaria_" + countCampoDiaria,
        type: "text",
        size: "2",
        maxLength: "2",
        className: "inputReadOnly",
        readonly: "",
        value: campoDiaria.ufCidadeDiarias
    });
    var _inpBotLocCidadeDiaria = Builder.node("input", {
        id: "btLocCidadeDiaria_" + countCampoDiaria,
        type: "button",
        className: "botoes",
        onClick: callLocCidadeDiaria,
        value: "..."
    });
    _tdImagemLixo.appendChild(_imagemExlcuir);
    _tdDiaria.appendChild(_hidRemoverDiaria);
    _tdValorDiaria.appendChild(_inpValorDiaria);
    _tdDiaria.appendChild(_selectVeiculo);
    _tdVeiculo.appendChild(_selectTipoProduto);
    _tdCidade.appendChild(_inpIdCidadeDiaria);
    _tdCidade.appendChild(_inpCidadeDiaria);
    _tdCidade.appendChild(_inpUFDiaria);
    _tdCidade.appendChild(_inpBotLocCidadeDiaria);
    var _tableDiaria = Builder.node("TABLE", {align: "center"});
    var _tr0CampoDiaria = Builder.node("TR", {className: "CelulaZebra2", id: "trCampoDiaria_" + countCampoDiaria});
    _tr0CampoDiaria.appendChild(_tdImagemLixo);
    _tr0CampoDiaria.appendChild(_tdDiaria);
    _tr0CampoDiaria.appendChild(_tdVeiculo);
    _tr0CampoDiaria.appendChild(_tdValorDiaria);
    _tr0CampoDiaria.appendChild(_tdCidade);
    _tableDiaria.appendChild(_tr0CampoDiaria);
    $("tbCampoDiarias").appendChild(_tr0CampoDiaria);
    $("maxCampoDiaria").value = countCampoDiaria;

}

function addColetasAutomaticas(coletasAutomatica, table) {
    var apelido = "ColAuto";
    try {
        if (coletasAutomatica == null || coletasAutomatica == undefined) {
            coletasAutomatica = new ColetasAutomaticas();
        }
        countColAuto++;
        var classe = "CelulaZebra2NoAlign";
        var callRemoverColetas = "removerColetasAutomaticas(" + countColAuto + ");"
        var _tr = Builder.node("tr", {id: "trColetaAuto_" + countColAuto, className: classe});
        var _tdRemove = Builder.node("td", {id: "tdRemove_" + countColAuto, align: "center"});
        var _tdFilialResp = Builder.node("td", {id: "tdFilialResp_" + countColAuto, width: "20%", colspan: "2"});
        var _tdDiaSemana = Builder.node("td", {id: "tdDiaSemana_" + countColAuto});
        var _tdHora = Builder.node("td", {id: "tdHora_" + countColAuto});
        var _tdDtInicio = Builder.node("td", {id: "tdDtInicio_" + countColAuto});
        var _tdBlank = Builder.node("td", {id: "tdBlank_" + countColAuto});
        var _slc = Builder.node("select", {id: "filial_" + countColAuto, name: "filial_" + countColAuto, className: "fieldMin"});
        var _selectDiaSemana = Builder.node("select", {id: "diaSemana_" + countColAuto, name: "diaSemana_" + countColAuto, className: "fieldMin"});
        var _inpId = Builder.node("input", {
            id: "id_" + countColAuto,
            name: "id_" + countColAuto,
            type: "hidden",
            className: "inputTexto",
            value: coletasAutomatica.id
        });
        var _inpImg = Builder.node("img", {
            id: "imgRemove_" + countColAuto,
            name: "imgRemove_" + countColAuto,
            src: "img/lixo.png",
            onclick: callRemoverColetas
        });
        var _inpFilialResp;
        var lista = listaColetasAutomaticas;
        if (lista != null) {
            for (var i = 1; i < lista.length; i++) {
                _inpFilialResp = Builder.node("option", {
                    value: lista[i].valor
                });
                Element.update(_inpFilialResp, lista[i].descricao);
                _slc.appendChild(_inpFilialResp);
            }

        }
        ;
        if (coletasAutomatica.filial_resp_id == "") {
            _slc.selectedIndex = 0;
        } else {
            _slc.value = coletasAutomatica.filial_resp_id;
        }
        var _inpDiaSemana = Builder.node("input", {
            id: "diaSemana" + apelido + "_" + countColAuto,
            name: "diaSemana" + apelido + "_" + countColAuto,
            type: "text",
            size: "30",
            maxLength: "60",
            className: "inputTexto",
            value: coletasAutomatica.diaSemana
        });
        var _optTipoProduto1 = Builder.node("option", {value: "1"}, 'Domingo');
        var _optTipoProduto2 = Builder.node("option", {value: "2"}, 'Segunda-Feira');
        var _optTipoProduto3 = Builder.node("option", {value: "3"}, 'Terça-Feira');
        var _optTipoProduto4 = Builder.node("option", {value: "4"}, 'Quarta-Feira');
        var _optTipoProduto5 = Builder.node("option", {value: "5"}, 'Quinta-Feira');
        var _optTipoProduto6 = Builder.node("option", {value: "6"}, 'Sexta-Feira');
        var _optTipoProduto7 = Builder.node("option", {value: "7"}, 'Sábado');
        _selectDiaSemana.appendChild(_optTipoProduto1);
        _selectDiaSemana.appendChild(_optTipoProduto2);
        _selectDiaSemana.appendChild(_optTipoProduto3);
        _selectDiaSemana.appendChild(_optTipoProduto4);
        _selectDiaSemana.appendChild(_optTipoProduto5);
        _selectDiaSemana.appendChild(_optTipoProduto6);
        _selectDiaSemana.appendChild(_optTipoProduto7);
        if (coletasAutomatica.diaSemana == "") {
            _selectDiaSemana.selectedIndex = 0;
        } else {
            _selectDiaSemana.value = coletasAutomatica.diaSemana;
        }
        var _inpHora = Builder.node("input", {
            id: "hora_" + countColAuto,
            name: "hora_" + countColAuto,
            type: "text",
            size: "5",
            maxLength: "5",
            className: "inputTexto",
            value: coletasAutomatica.hora,
            onkeyup: "mascaraHora(this)"
        });
        _tdRemove.appendChild(_inpId);
        _tdRemove.appendChild(_inpImg);
        _tdFilialResp.appendChild(_slc);
        _tdDiaSemana.appendChild(_inpDiaSemana);
        _tdHora.appendChild(_inpHora);
        _tr.appendChild(_tdRemove);
        _tr.appendChild(_tdFilialResp);
        _tr.appendChild(_selectDiaSemana);
        _tr.appendChild(_tdHora);
        _tr.appendChild(_tdDtInicio);
        _tr.appendChild(_tdBlank);
        table.appendChild(_tr);
        $("qtdColetasAutomaticas").value = countColAuto;
        visivel(table);
    } catch (ex) {
        alert(ex);
    }
}

function CamposXcarac(idCampo, tipoTag, valorTag, tipoConhecimento, tipoServico, modal) {
    this.idCampo = (idCampo != undefined && idCampo != null ? idCampo : 0);
    this.tipoTag = (tipoTag != undefined && tipoTag != null ? tipoTag : "a");
    this.valorTag = (valorTag != undefined && valorTag != null ? valorTag : "");
    this.tipoConhecimento = (tipoConhecimento != undefined && tipoConhecimento != null ? tipoConhecimento : "n");
    this.tipoServico = (tipoServico != undefined && tipoServico != null ? tipoServico : "n");
    this.modal = (modal != undefined && modal != null ? modal : 0);
}
var listModal = new Array();
listModal[0] = new Option(0, "Todos");
listModal[1] = new Option(1, "Rodoviário");
listModal[2] = new Option(2, "Aéreo");
listModal[3] = new Option(3, "Aquaviario");

var countxcarac = 1;

function addXcarac(Xcarac) {
    var callRemoverXcarac = "removerXCarac(" + countxcarac + ");";
    try {
        if (Xcarac == null || Xcarac == undefined) {
            Xcarac = new CamposXcarac();
        }

        var _selectTipoTag = Builder.node("select", {
            id: "tipoXcaracTag_" + countxcarac,
            name: "tipoXcaracTag_" + countxcarac,
            className: "inputtexto",
            onchange: "alternarXCarac(" + countxcarac + ");"
        });
        var _selectModal = Builder.node("select", {
            id: "modalXcarac_" + countxcarac,
            name: "modalXcarac_" + countxcarac,
            className: "inputtexto"
        });
        povoarSelect(_selectModal, listModal);
        _selectModal.value = Xcarac.modal;
        var _opt_tipoTagA = Builder.node("option", {value: "a"});
        _opt_tipoTagA.innerHTML = "xCaracAd";
        var _opt_tipoTagS = Builder.node("option", {value: "s"});
        _opt_tipoTagS.innerHTML = "xCaracSer";

        _selectTipoTag.appendChild(_opt_tipoTagA);
        _selectTipoTag.appendChild(_opt_tipoTagS);

        _selectTipoTag.value = Xcarac.tipoTag;

        var _selectTipoConhecimento = Builder.node("select", {
            id: "tipoXcaracCon_" + countxcarac,
            name: "tipoXcaracCon_" + countxcarac,
            className: "inputtexto"
        });

        var _opt_tipoConN = Builder.node("option", {value: "n"});
        _opt_tipoConN.innerHTML = "Normal";
        var _opt_tipoConL = Builder.node("option", {value: "l"});
        _opt_tipoConL.innerHTML = "Entrega Local (Cobrança)";
        var _opt_tipoConI = Builder.node("option", {value: "i"});
        _opt_tipoConI.innerHTML = "Diárias";
        var _opt_tipoConP = Builder.node("option", {value: "p"});
        _opt_tipoConP.innerHTML = "Pallets";
        var _opt_tipoConC = Builder.node("option", {value: "c"});
        _opt_tipoConC.innerHTML = "Complementar";
        var _opt_tipoConR = Builder.node("option", {value: "r"});
        _opt_tipoConR.innerHTML = "Reentrega";
        var _opt_tipoConD = Builder.node("option", {value: "d"});
        _opt_tipoConD.innerHTML = "Devolução";
        var _opt_tipoConB = Builder.node("option", {value: "b"});
        _opt_tipoConB.innerHTML = "Cortesia";
        var _opt_tipoConS = Builder.node("option", {value: "s"});
        _opt_tipoConS.innerHTML = "Substituição";
        var _opt_tipoConA = Builder.node("option", {value: "a"});
        _opt_tipoConA.innerHTML = "Anulação";
        var _opt_tipoConT = Builder.node("option", {value: "t"});
        _opt_tipoConT.innerHTML = "Substituído";

        _selectTipoConhecimento.appendChild(_opt_tipoConN);
        _selectTipoConhecimento.appendChild(_opt_tipoConL);
        _selectTipoConhecimento.appendChild(_opt_tipoConI);
        _selectTipoConhecimento.appendChild(_opt_tipoConP);
        _selectTipoConhecimento.appendChild(_opt_tipoConC);
        _selectTipoConhecimento.appendChild(_opt_tipoConR);
        _selectTipoConhecimento.appendChild(_opt_tipoConD);
        _selectTipoConhecimento.appendChild(_opt_tipoConB);
        _selectTipoConhecimento.appendChild(_opt_tipoConS);
        _selectTipoConhecimento.appendChild(_opt_tipoConT);

        _selectTipoConhecimento.value = Xcarac.tipoConhecimento;

        var _selectTipoServico = Builder.node("select", {
            id: "tipoXcaracServ_" + countxcarac,
            name: "tipoXcaracServ_" + countxcarac,
            className: "inputtexto"
        });

        var _opt_tipoServN = Builder.node("option", {value: "n"});
        _opt_tipoServN.innerHTML = "Normal";
        var _opt_tipoServS = Builder.node("option", {value: "s"});
        _opt_tipoServS.innerHTML = "SubContratação";
        var _opt_tipoServR = Builder.node("option", {value: "r"});
        _opt_tipoServR.innerHTML = "Redespacho";
        var _opt_tipoServI = Builder.node("option", {value: "i"});
        _opt_tipoServI.innerHTML = "Redespacho Intermediário";
        var _opt_tipoServM = Builder.node("option", {value: "m"});
        _opt_tipoServM.innerHTML = "Serviço Vinculado a Multimodal";

        _selectTipoServico.appendChild(_opt_tipoServN);
        _selectTipoServico.appendChild(_opt_tipoServS);
        _selectTipoServico.appendChild(_opt_tipoServR);
        _selectTipoServico.appendChild(_opt_tipoServI);
        _selectTipoServico.appendChild(_opt_tipoServM);

        _selectTipoServico.value = Xcarac.tipoServico;

        var _valorTag = Builder.node("input", {
            id: "valorXcaracTag_" + countxcarac,
            name: "valorXcaracTag_" + countxcarac,
            value: Xcarac.valorTag,
            type: "text",
            className: "inputtexto",
            maxLength: "15",
            size: "15"
        });

        var _deletar = Builder.node("input", {
            id: "isDeletarXcarac_" + countxcarac,
            name: "isDeletarXcarac_" + countxcarac,
            type: "hidden"
        });

        var _idCampoXcarac = Builder.node("input", {
            id: "idXcarac_" + countxcarac,
            name: "idXcarac_" + countxcarac,
            type: "hidden",
            value: Xcarac.idCampo
        });

        var _inpImg = Builder.node("img", {
            id: "imgRemove_" + countColAuto,
            name: "imgRemove_" + countColAuto,
            src: "img/lixo.png",
            onclick: callRemoverXcarac
        });

        var tr = Builder.node("tr", {id: "trXcarac_" + countxcarac, name: "trXcarac_" + countxcarac, className: "CelulaZebra2"});
        var tdTag = Builder.node("td", {align: "center"});
        var tdModal = Builder.node("td", {align: "left"});
        var tdConhServ = Builder.node("td", {align: "left"});
        var tdValor = Builder.node("td", {align: "center"});
        var tdLixo = Builder.node("td", {align: "center"});

        _selectTipoConhecimento.style="width: 120px";
        _selectTipoServico.style="width: 120px";

        tdLixo.appendChild(_inpImg);
        tdTag.appendChild(_selectTipoTag);
        tdTag.appendChild(_deletar);
        tdTag.appendChild(_idCampoXcarac);
        tdConhServ.appendChild(_selectTipoConhecimento);
        tdConhServ.appendChild(_selectTipoServico);
        tdValor.appendChild(_valorTag);
        tdModal.appendChild(_selectModal);

        tr.appendChild(tdLixo);
        tr.appendChild(tdTag);
        tr.appendChild(tdValor);
        tr.appendChild(tdConhServ);
        tr.appendChild(tdModal);

        $("tbCampoXcarac").appendChild(tr);
        $("maxCampoXcarac").value = countxcarac;
        alternarXCarac(countxcarac);

        countxcarac++;
    } catch (ex) {
        alert(ex);
    }
}

function removerXCarac(index) {
    try {
        if ($("trXcarac_" + index) != null) {

            if (confirm("Deseja excluir a Tag xCarac?")) {
                if (confirm("Tem certeza?")) {
                    $("isDeletarXcarac_" + index).value = "true";
                    Element.hide($("trXcarac_" + index));
                    alert('Campo removido com sucesso!');
                }
            }
        }
    } catch (e) {
        alert(e);
    }
}

function alternarXCarac(index) {
    if ($("trXcarac_" + index) != null) {
        if ($("tipoXcaracTag_" + index).value == 's') {
            $("tipoXcaracServ_" + index).style.display = "";
            $("tipoXcaracCon_" + index).style.display = "none";
        } else {
            $("tipoXcaracServ_" + index).style.display = "none";
            $("tipoXcaracCon_" + index).style.display = "";
        }
    }

}

function CamposOcorrAuto(idCampoOcorr, idOcorrencia, descOcorrencia, codigo, observacaoOcorrencia, tipoInclusao, tipoCte) {
    this.idCampoOcorr = (idCampoOcorr != undefined && idCampoOcorr != null ? idCampoOcorr : 0);
    this.idOcorrencia = (idOcorrencia != undefined && idOcorrencia != null ? idOcorrencia : 0);
    this.codigo = (codigo != undefined && codigo != null ? codigo : '');
    this.descOcorrencia = (descOcorrencia != undefined && descOcorrencia != null ? descOcorrencia : "");
    this.observacaoOcorrencia = (observacaoOcorrencia != undefined && observacaoOcorrencia != null ? observacaoOcorrencia : "");
    this.tipoInclusao = (tipoInclusao != undefined && tipoInclusao != null ? tipoInclusao : "c");
    this.tipoCte = (tipoCte != undefined && tipoCte != null && tipoCte != '' ? tipoCte : " ");
 }

var countOcorr = 1;

function addOcorrenciaAutomatica(ocorrencia) {
    
    try {

        if (ocorrencia == null || ocorrencia == undefined) {
            ocorrencia = new CamposOcorrAuto();
        }

        var callRemoverOcorr = "removerOcorrenciaAuto(" + countOcorr + ");";

        var _inpImg = Builder.node("img", {
            id: "imgRemoveOcorr_" + countOcorr,
            name: "imgRemoveOcorr_" + countOcorr,
            src: "img/lixo.png",
            onclick: callRemoverOcorr
        });

        var _id_registro = Builder.node("input", {
            id: "idOcorrAuto_" + countOcorr,
            name: "idOcorrAuto_" + countOcorr,
            type: "hidden"
        });
        var _id_ocorrencia = Builder.node("input", {
            id: "idOcorr_" + countOcorr,
            name: "idOcorr_" + countOcorr,
            type: "hidden"
        });

        var _codigo_ocorrencia = Builder.node("input", {
            id: "codOcorr_" + countOcorr,
            name: "codOcorr_" + countOcorr,
            type: "text",
            size: "4",
            maxLength: "4",
            className: "inputReadOnly8pt"
        });

        var _desc_ocorrencia = Builder.node("input", {
            id: "descOcorr_" + countOcorr,
            name: "descOcorr_" + countOcorr,
            type: "text",
            className: "inputReadOnly8pt",
            size: "40"
        });

        var _tipo_inclusao = Builder.node("select", {
            id: "tipoInclusao_" + countOcorr,
            name: "tipoInclusao_" + countOcorr,
            className: "inputtexto"
        });

        var _texto_padrao = Builder.node("textarea", {
            id: "obsOcorr" + countOcorr,
            name: "obsOcorr" + countOcorr,
            rows: "4",
            cols: "30"
        });

        var _deletar = Builder.node("input", {
            id: "deletarOcorrencia_" + countOcorr,
            name: "deletarOcorrencia_" + countOcorr,
            type: "hidden"
        });

        var _tipo_cte = Builder.node("select", {
            id: "tipocte_" + countOcorr,
            name: "tipocte_" + countOcorr,
            className: "inputtexto"
        });

        var _opt_tipo_incluC = Builder.node("option", {value: "c"});
        _opt_tipo_incluC.innerHTML = "Ao incluir o CT-e";
        var _opt_tipo_incluR = Builder.node("option", {value: "r"});
        _opt_tipo_incluR.innerHTML = "Ao incluir o Romaneio";
        var _opt_tipo_incluPR = Builder.node("option", {value: "pr"});
        _opt_tipo_incluPR.innerHTML = "Ao incluir o Pré Romaneio";
        var _opt_tipo_incluM = Builder.node("option", {value: "m"});
        _opt_tipo_incluM.innerHTML = "Ao incluir o Manifesto";
        var _opt_tipo_incluPM = Builder.node("option", {value: "pm"});
        _opt_tipo_incluPM.innerHTML = "Ao incluir o Pré Manifesto";
        var _opt_tipo_incluMR = Builder.node("option", {value: "mr"});
        _opt_tipo_incluMR.innerHTML = "Ao incluir o Manifesto para um Representante";
        var _opt_tipo_incluD = Builder.node("option", {value: "d"});
        _opt_tipo_incluD.innerHTML = "Ao informar a data de chegada do CT-e";

        _tipo_inclusao.appendChild(_opt_tipo_incluC);
        _tipo_inclusao.appendChild(_opt_tipo_incluR);
        _tipo_inclusao.appendChild(_opt_tipo_incluPR);
        _tipo_inclusao.appendChild(_opt_tipo_incluM);
        _tipo_inclusao.appendChild(_opt_tipo_incluPM);
        _tipo_inclusao.appendChild(_opt_tipo_incluMR);
        _tipo_inclusao.appendChild(_opt_tipo_incluD);
        
        var _opt_tipo_cte = Builder.node("option", {value: " "});
        _opt_tipo_cte.innerHTML = "Todos os Tipos";
        var _opt_tipo_cteN = Builder.node("option", {value: "n"});
        _opt_tipo_cteN.innerHTML = "Normal";
        var _opt_tipo_cteL = Builder.node("option", {value: "l"});
        _opt_tipo_cteL.innerHTML = "Entrega Local";
        var _opt_tipo_cteI = Builder.node("option", {value: "i"});
        _opt_tipo_cteI.innerHTML = "Diárias";
        var _opt_tipo_cteP = Builder.node("option", {value: "p"});
        _opt_tipo_cteP.innerHTML = "Pallets";
        var _opt_tipo_cteC = Builder.node("option", {value: "c"});
        _opt_tipo_cteC.innerHTML = "Complementar";
        var _opt_tipo_cteR = Builder.node("option", {value: "r"});
        _opt_tipo_cteR.innerHTML = "Reentrega";
        var _opt_tipo_cteD = Builder.node("option", {value: "d"});
        _opt_tipo_cteD.innerHTML = "Devolução";
        var _opt_tipo_cteB = Builder.node("option", {value: "b"});
        _opt_tipo_cteB.innerHTML = "Cortesia";
        var _opt_tipo_cteS = Builder.node("option", {value: "s"});
        _opt_tipo_cteS.innerHTML = "Substituição";
        var _opt_tipo_cteA = Builder.node("option", {value: "a"});
        _opt_tipo_cteA.innerHTML = "Anulação";
        var _opt_tipo_cteT = Builder.node("option", {value: "t"});
        _opt_tipo_cteT.innerHTML = "Substituído";
        
        _tipo_cte.appendChild(_opt_tipo_cte);
        _tipo_cte.appendChild(_opt_tipo_cteN);
        _tipo_cte.appendChild(_opt_tipo_cteL);
        _tipo_cte.appendChild(_opt_tipo_cteI);
        _tipo_cte.appendChild(_opt_tipo_cteP);
        _tipo_cte.appendChild(_opt_tipo_cteC);
        _tipo_cte.appendChild(_opt_tipo_cteR);
        _tipo_cte.appendChild(_opt_tipo_cteD);
        _tipo_cte.appendChild(_opt_tipo_cteB);
        _tipo_cte.appendChild(_opt_tipo_cteS);
        _tipo_cte.appendChild(_opt_tipo_cteA);
        _tipo_cte.appendChild(_opt_tipo_cteT);

        var _trOcorr = Builder.node("tr", {
            id: "trOcorrAuto_" + countOcorr,
            name: "trOcorrAuto_" + countOcorr,
            className: "CelulaZebra2"
        });

        var _tdDeleta = Builder.node("td", {align: "center"});
        var _tdOcorr = Builder.node("td", {align: "center"});
        var _tdtextoPadrao = Builder.node("td", {align: "center"});
        var _tdtipoInclusao = Builder.node("td", {align: "center"});
        var _labelBranca = Builder.node("label");
        var _tdtipoCte = Builder.node("td", {align: "center"});
        _labelBranca.innerHTML = " ";

        _id_registro.value = ocorrencia.idCampoOcorr;
        _id_ocorrencia.value = ocorrencia.idOcorrencia;
        _codigo_ocorrencia.readOnly = true;
        _codigo_ocorrencia.value = ocorrencia.codigo;
        _desc_ocorrencia.readOnly = true;
        _desc_ocorrencia.value = ocorrencia.descOcorrencia;
        _texto_padrao.value = ocorrencia.observacaoOcorrencia;
        _tipo_inclusao.value = ocorrencia.tipoInclusao;
        _tipo_cte.value =  ocorrencia.tipoCte;

        _tdDeleta.appendChild(_inpImg);
        _tdOcorr.appendChild(_codigo_ocorrencia);
        _tdOcorr.appendChild(_labelBranca);
        _tdOcorr.appendChild(_desc_ocorrencia);
        _tdOcorr.appendChild(_deletar);
        _tdOcorr.appendChild(_id_registro);
        _tdOcorr.appendChild(_id_ocorrencia);
        _tdtextoPadrao.appendChild(_texto_padrao);
        _tdtipoInclusao.appendChild(_tipo_inclusao);
        _tdtipoCte.appendChild(_tipo_cte);

        _trOcorr.appendChild(_tdDeleta);
        _trOcorr.appendChild(_tdOcorr);
        _trOcorr.appendChild(_tdtextoPadrao);
        _trOcorr.appendChild(_tdtipoInclusao);
        _trOcorr.appendChild(_tdtipoCte);

        $("tbOcorrAuto").appendChild(_trOcorr);
        $("maxOcorrAuto").value = countOcorr;
        countOcorr++;
    } catch (ex) {
        alert(ex);
    }
}

function removerOcorrenciaAuto(index) {
    try {
        if ($("trOcorrAuto_" + index) != null) {

            if (confirm("Deseja excluir a Ocorrência automática?")) {
                if (confirm("Tem certeza?")) {
                    $("deletarOcorrencia_" + index).value = "true";
                    Element.hide($("trOcorrAuto_" + index));
                    alert('Campo removido com sucesso!');
                }
            }
        }
    } catch (e) {
        alert(e);
    }
}

function Cron(id, cronExpressao) {
    this.id = (id == null || id == undefined ? 0 : id);
    this.cronExpressao = (cronExpressao == null || cronExpressao == undefined ? "" : cronExpressao);
}
function addCron(_tabelaId, classe, cron) {
    try {
        cron = (cron == null || cron == undefined ? new Cron() : cron);
        var tipo = _tabelaId.split("_")[1];
        var idxLayout = _tabelaId.split("_")[2];
        var obQtd = $("qtdCron_" + tipo + "_" + idxLayout);
        var countCron = parseInt(obQtd.value, 10) + 1;
        var sufixo = "_" + tipo + "_" + idxLayout + "_" + countCron;
        var _labelCron = Builder.node("label", "Momento:");
        var _labelExplicacao = Builder.node("label", "O momento esta apresentado em forma de expressão cron, para visualizar e/ou informar clique no botão ao lado");
        var _br = Builder.node("br");
        var _tr = Builder.node("tr", {id: "trCron" + sufixo, className: classe});
        var _tdDesc = Builder.node("td", {id: "tdCronDesc" + sufixo, className: classe, width: "20%", align: "rigth"});
        var _tdValor = Builder.node("td", {id: "tdCronValor" + sufixo, className: classe, width: "70%"});
        var _tdLixo = Builder.node("td", {id: "tdCronValor" + sufixo, className: classe, width: "10%", align: "center"});
        var _imgLixo = Builder.node('IMG', {src: 'img/lixo.png', title: 'Apagar Momento', className: 'imagemLink', onClick: "removerMomentoLayoutEDI('" + tipo + "','" + idxLayout + "','" + countCron + "');"});
        var _idLayout = Builder.node('input', {type: "hidden", id: "idCron" + sufixo, name: "idCron" + sufixo, value: cron.id});
        var _inpCron = Builder.node('input', {type: "text", size: "10", id: "cron" + sufixo, className: "fieldMin", name: "cron" + sufixo, value: cron.cronExpressao});
        readOnly(_inpCron, "inputReadOnly8pt");
        var _btLocalizarCron = Builder.node('input', {type: "button", id: "btCron" + sufixo, onClick: "abrirLocalizarCron('" + _inpCron.id + "')", className: "inputBotaoMin", value: "..."});
        _tdDesc.appendChild(_labelCron);
        _tdValor.appendChild(_inpCron);
        _tdValor.appendChild(_idLayout);
        _tdValor.appendChild(_btLocalizarCron);
        _tdValor.appendChild(_br);
        _tdValor.appendChild(_labelExplicacao);
        _tdLixo.appendChild(_imgLixo);
        _tr.appendChild(_tdLixo);
        _tr.appendChild(_tdDesc);
        _tr.appendChild(_tdValor);
        $(_tabelaId).appendChild(_tr);
        obQtd.value = countCron;
    } catch (e) {
        console.log(e);
    }
}

//Chamar o cadastro de cliente
function cadtabcliente() {
    var idCli = $("id").value;
    var descCliente = $("rzs").value;
    var utilizartipofretetabela = $("utilizartipofretetabela").checked;
    window.open('./cadtabela_preco.jsp?acao=iniciar&id=' + idCli + "&descCliente=" + descCliente + "&utilizartipofretetabela=" + utilizartipofretetabela, "Cadastrar Tabela de Preco", 'top=80, left=150, height=700, width=800,resizable=yes,status=1,scrollbars=1');
}

function verificarEndereco(index) {
    if (document.getElementById("logradouroEndEntrga_" + index).value == "") {
        alert("Não foi localizado endereço para este CEP!");
    }
}

function verificarEndereco() {
    if (document.getElementById("endereco").value == "" || document.getElementById("enderecoCob").value == "" || document.getElementById("enderecoCol").value == "") {
        alert("Não foi localizado endereço para este CEP!");
    }
}

function carregaCepAjax(resposta, isIgnoraEndereco, tipoEndereco) {
    var rua = resposta.split("@@")[1];
    var bairro = resposta.split("@@")[2];
    var idbairro = resposta.split("@@")[3];
    var cidade = resposta.split("@@")[4];
    var idCidade = resposta.split("@@")[5];
    var uf = resposta.split("@@")[6];
    var nomeCidade = resposta.split("@@")[7];

    if (idCidade == 0){
        alert("A cidade " + nomeCidade + " não foi encontrada no sistema.");
        espereEnviar("", false);
        return false;
    }
    if (rua == "") {
        verificarEndereco();
    }
    if (!isIgnoraEndereco) {
        if (rua != "" && $("endereco").value.trim() == "" && tipoEndereco == "enderecoPrincipal") {
            $("endereco").value = rua;
            $("bairro").value = bairro;
            $("idLocalizaBairro").value = idbairro;
            $("cidade").value = cidade;
            $("uf").value = uf;
            $("idcidade").value = idCidade;
        } else if (rua != "" && $("enderecoCob").value.trim() == "" && tipoEndereco == "enderecoCobranca") {
            $("enderecoCob").value = rua;
            $("bairroCob").value = bairro;
            $("idBairroCob").value = idbairro;
            $("cidadeCob").value = cidade;
            $("ufCob").value = uf;
            $("cidadeCobId").value = idCidade;
        } else if (rua != "" && $("enderecoCol").value.trim() == "" && tipoEndereco == "enderecoColeta") {
            $("enderecoCol").value = rua;
            $("bairroCol").value = bairro;
            $("idBairroCol").value = idbairro;
            $("cidadeCol").value = cidade;
            $("ufCol").value = uf;
            $("cidadeColId").value = idCidade;
        }
    } else {
        if (tipoEndereco == "enderecoPrincipal") {
            $("endereco").value = rua;
            $("bairro").value = bairro;
            $("idLocalizaBairro").value = idbairro;
            $("cidade").value = cidade;
            $("uf").value = uf;
            $("idcidade").value = idCidade;
        } else if (tipoEndereco == "enderecoCobranca") {
            $("enderecoCob").value = rua;
            $("bairroCob").value = bairro;
            $("idBairroCob").value = idbairro;
            $("cidadeCob").value = cidade;
            $("ufCob").value = uf;
            $("cidadeCobId").value = idCidade;
        } else if (tipoEndereco == "enderecoColeta") {
            $("enderecoCol").value = rua;
            $("bairroCol").value = bairro;
            $("idBairroCol").value = idbairro;
            $("cidadeCol").value = cidade;
            $("ufCol").value = uf;
            $("cidadeColId").value = idCidade;
        }
    }
    espereEnviar("", false);
}
function carregarCidadeAjax(textResposta) {
    try {
        var lista = jQuery.parseJSON(textResposta);
        var cidade = null;
        var length = (lista.cidade != undefined && lista.cidade.length != undefined ? lista.cidade.length : 1);
        if (length > 1) {
            cidade = lista.cidade[0];
        } else {
            cidade = lista.cidade;
        }
        $("cidade").value = cidade.cidade;
        $("uf").value = cidade.uf;
        $("idcidade").value = cidade.idcidade;
    } catch (e) {
        alert(e);
    }
}

function getCidadeAjax(cidDesc, ufDesc) {
    espereEnviar("", true);
    jQuery.ajax({
        url: "ConsultaSituacaoControlador?",
        dataType: "text",
        method: "post",
        async: false,
        data: {
            cidDesc: cidDesc,
            cidUf: ufDesc,
            acao: "carregarCidadeAjax"
        },
        success: function (data) {
            espereEnviar("", false);
            carregarCidadeAjax(data);
        }, error: function () {
            alert("Erro inesperado ao buscar cidade, favor refazer a operação.");
        }
    });
}

function mostraObservacao() {
    $("inativo").style.display = ($('chkativo').checked ? "none" : "");
}
function ativaOcorrencia() {
    $("tabelaOcorrencia").style.display = ($('chkOcorrenciasCliente').checked ? "" : "none")
}

function excluirOcorrenciaEdi(index) {
    try {
        var id = $("clienteOcorrenciaId_" + index).value;
        if (confirm("Deseja excluir esta ocorrencia")) {
            if (confirm("Tem Certeza ?")) {
                Element.remove($("idLinhaOcorrencia_" + index));
                if (id != 0) {
                    new Ajax.Request("./jspcadcliente.jsp?acao=excluirOcorrenciaCliente&id=" + id, {method: 'get',
                        onSuccess: function () {
                            alert('Ocorrencia removida com sucesso!')
                        },
                        onFailure: function () {
                            alert('Something went wrong...')
                        }
                    });
                }
            }
        }
    } catch (e) {
        alert(e);
    }
}




function removerTaxa(index) {
    try {
        var id = $("idTaxas_" + index).value;
        var idCliente = $("id").value;
        var descricao = ($("descricaoTaxas_" + index).value);
        if (id != 0) {
            if (confirm("Deseja excluir o campo '" + descricao + "'?")) {
                if (confirm("Tem certeza?")) {
                    new Ajax.Request("./jspcadcliente.jsp?acao=removerTaxaXML&id=" + id + "&idCliente=" + idCliente, {method: 'get',
                        onSuccess: function () {
                            Element.remove($("trCampoTaxas_" + index));
                            $("maxTaxas").value = parseFloat($("maxTaxas").value) - 1;
                            alert('Campo removido com sucesso!')
                        },
                        onFailure: function () {
                            alert('Something went wrong...')
                        }});
                }
            }
        } else {
            Element.remove($("trCampoTaxas_" + index));
            $("maxTaxas").value = parseFloat($("maxTaxas").value) - 1;
        }
    } catch (e) {
        alert(e);
    }
}

function removerCampoDiaria(index) {
    try {
        var idCampoDiaria = $("idDiaria_" + index).value;
        var idClienteDiaria = $("id").value;
        var descricaoDiaria = ($("descricaoTags_" + index).value);
        if (confirm("Deseja excluir o campo '" + descricaoDiaria + "'?")) {
            if (confirm("Tem certeza?")) {
                new Ajax.Request("./jspcadcliente.jsp?acao=removerCamposDiaria&idCampoDiaria=" + idCampoDiaria + "&idCliente=" + idClienteDiaria, {method: 'get',
                    onSuccess: function () {
                        Element.remove($("trCampoDiaria_" + index));
                        alert('Campo removido com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
            }
        }
    } catch (erro) {
        alert(erro);
    }
}

function removerColetasAutomaticas(index) {
    try {
        var id = $("id_" + index).value;
        var idCliente = $("id").value;
        if (confirm("Tem certeza que deseja remover a Parametrização de Coleta?")) {
            if (confirm("Tem certeza?")) {
                new Ajax.Request("./jspcadcliente.jsp?acao=removerColetas&id=" + id + "&idCliente=" + idCliente, {method: 'get',
                    onSuccess: function () {
                        Element.remove($("trColetaAuto_" + index));
                        alert('Parametrização removida com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }});
            }
        }
    } catch (e) {
        alert(e);
    }
}

var countStICMS = 0;
function addStICMS(sticms) {
    countStICMS++;
    var normativa = "mostrarNormativaGoias(" + countStICMS + ")";
    var lista = listaStICMS;
    var listaFilial = listaFiliais;
    if (sticms == null || sticms == undefined) {
        sticms = new StICMS();
    }
    var td0_ = Builder.node("TD", {});
    var td1_ = Builder.node("TD", {});
    var td2_ = Builder.node("TD", {});
    var td3_ = Builder.node("TD", {id: "tdReducaoIcms_" + countStICMS, name: "tdReducaoIcms_" + countStICMS});
    var td4_ = Builder.node("TD", {id: "tdNormativaIcms_" + countStICMS, name: "tdNormativaIcms_" + countStICMS});
    var td5_ = Builder.node("TD", {id: "tdCreditoFiscal_" + countStICMS, name: "tdCreditoFiscal_" + countStICMS});
    var _slcICMS = Builder.node("select", {id: "stIcms_" + countStICMS, name: "stIcms_" + countStICMS, className: "fieldMin", onchange: normativa});
    var _slcFilial = Builder.node("select", {id: "filialICMS_" + countStICMS, name: "filialICMS_" + countStICMS, className: "fieldMin", style: "width:180px"});
    var checkIcms_ = Builder.node("INPUT", {type: "checkbox", id: "isNormativa598_" + countStICMS, name: "isNormativa598_" + countStICMS});
    var reduBaseIcms_ = Builder.node("INPUT", {type: "text", id: "reducaoIcms_" + countStICMS, name: "reducaoIcms_" + countStICMS, className: "inputtexto", size: "8", maxlength: "6", onkeypress: "mascara(this, reais)", value: sticms.reducaoBase});
    var labelIcms_ = Builder.node("LABEL", {id: "labelNormativaIcms_" + countStICMS, name: "labelNormativaIcms_" + countStICMS});
    labelIcms_.innerHTML = " Aplicar redução na base de cálculo conforme instrução normativa GSF nº 598 de 16/04/2003 ";

    var isNormativa129816go_ = Builder.node("INPUT", {type: "checkbox", id: "isNormativa129816go_" + countStICMS, name: "isNormativa129816go_" + countStICMS});
    var labelNormativa129816go_ = Builder.node("LABEL", {id: "labelNormativa129816go_" + countStICMS, name: "labelNormativa129816go_" + countStICMS});
    labelNormativa129816go_.innerHTML = " Ao utilizar CST 060 o XML do CT-e e o DACTE deverão ir com a alíquota de ICMS zerados conforme instrução normativa GSF 1298/16 GO ";

    var inputPercentCredito = Builder.node("input", {
        type: "text",
        id: "inputCreditoFiscal_" + countStICMS,
        name: "inputCreditoFiscal_" + countStICMS,
        size: "8",
        onChange: "seNaoFloatReset(this, '0.00')",
        maxLength: "8",
        class: "inputtexto",
        value: sticms.percentualCreditoPresumido
    });

    var labelPercentCredito = Builder.node("label", {
        id: "labelPercentCredito_" + countStICMS,
        name: "labelPercentCredito_" + countStICMS
    });
    labelPercentCredito.innerHTML = "%";


    //campos
    var hid1_ = Builder.node("INPUT", {type: "hidden", id: "idStCliente_" + countStICMS, name: "idStCliente_" + countStICMS, value: sticms.idClienteICMS});
    var inp2_ = null;
    var inp1_ = null;
    if (lista != null) {
        for (var i = 1; i < lista.length; i++) {
            inp2_ = Builder.node("option", {
                value: lista[i].valor
            });
            Element.update(inp2_, lista[i].descricao);
            _slcICMS.appendChild(inp2_);
        }
        if (sticms.idStICMS == 0) {
            _slcICMS.selectedIndex = 0;
        } else {
            _slcICMS.value = sticms.idStICMS;
        }
    }
    ;
    if (sticms.idStICMS != 3) {
        labelIcms_.style.display = "none";
        reduBaseIcms_.style.display = "none";
        checkIcms_.style.display = "none";
    } else {
        labelIcms_.style.display = "";
        reduBaseIcms_.style.display = "";
        checkIcms_.style.display = "";
    }
    if (sticms.idStICMS.toString() !== "9") {
        labelPercentCredito.style.display = "none";
        inputPercentCredito.style.display = "none";
        isNormativa129816go_.style.display = "none";
        labelNormativa129816go_.style.display = "none";
    } else {
        labelPercentCredito.style.display = "";
        inputPercentCredito.style.display = "";
        isNormativa129816go_.style.display = "";
        labelNormativa129816go_.style.display = "";
    }

    var inp1_ = null;
    if (listaFilial != null) {
        for (var i = 0; i < listaFilial.length; i++) {
            if (listaFilial[i]) {
                inp1_ = Builder.node("option", {
                    value: listaFilial[i].valor
                });
                Element.update(inp1_, listaFilial[i].descricao);
                _slcFilial.appendChild(inp1_);
            }
        }
    }
    _slcFilial.value = (sticms.filial == 0 ? "" : sticms.filial);
    var _img0 = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerStICMS(" + countStICMS + ");"});
    td0_.appendChild(_img0);
    td1_.appendChild(hid1_);
    td1_.appendChild(_slcICMS);
    td2_.appendChild(_slcFilial);
    td3_.appendChild(reduBaseIcms_);
    td4_.appendChild(checkIcms_);
    td4_.appendChild(labelIcms_);
    td4_.appendChild(isNormativa129816go_);
    td4_.appendChild(labelNormativa129816go_);
    td5_.appendChild(inputPercentCredito);
    td5_.appendChild(labelPercentCredito);
    var tr1_ = Builder.node("TR", {className: "CelulaZebra2", id: "trClienteStICMS_" + countStICMS});
    tr1_.appendChild(td0_);
    tr1_.appendChild(td1_);
    tr1_.appendChild(td2_);
    tr1_.appendChild(td3_);
    tr1_.appendChild(td4_);
    tr1_.appendChild(td5_);
    $("tbStICMS").appendChild(tr1_);
    $("maxClienteICMS").value = countStICMS;
    if (sticms.usarNormativa398) {
        $("isNormativa598_" + countStICMS).checked = true;
    }
    if (sticms.isNormativa129816go) {
        $("isNormativa129816go_" + countStICMS).checked = true;
    }
}
function removerStICMS(index) {
    try {
        var id = $("idStCliente_" + index).value;
        var idCliente = $("id").value;
        if (confirm("Deseja excluir a Situação Tributária?")) {
            if (confirm("Tem certeza?")) {
                new Ajax.Request("./jspcadcliente.jsp?acao=removerStICMS&id=" + id + "&idCliente=" + idCliente, {method: 'get',
                    onSuccess: function () {
                        Element.remove($("trClienteStICMS_" + index));
                        alert('Campo removido com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }});
            }
        }
    } catch (e) {
        alert(e);
    }
}
function getLayout(idLayout) {
    var layoutObj = null;
    for (var i = 1; i < listLayoutEDI_obj.length; i++) {
        layoutObj = listLayoutEDI_obj[i];
        if (idLayout == layoutObj.id) {
            return listLayoutEDI_obj[i];
        }
    }
}
function LayoutEdi(id, cod, descricao, extensao) {
    this.id = (id == null || id == undefined ? 0 : id);
    this.cod = (cod == null || cod == undefined ? 0 : cod);
    this.descricao = (descricao == null || descricao == undefined ? "" : descricao);
    this.extensao = (extensao == null || extensao == undefined ? "" : extensao);
}

var campoCodUni = 0;
var campoBanco = 0;
var listaCamposInfqUnd = null;
var listaCamposInfqBanco = null;
function carregarInfqUniBanco() {
    listaCamposInfqUnd = new Array();
    listaCamposInfqBanco = new Array();
    listaCamposInfqUnd[++campoCodUni] = new Option("00", "M³");
    listaCamposInfqUnd[++campoCodUni] = new Option("01", "KG");
    listaCamposInfqUnd[++campoCodUni] = new Option("02", "TON");
    listaCamposInfqUnd[++campoCodUni] = new Option("03", "UND");
    listaCamposInfqUnd[++campoCodUni] = new Option("04", "LITROS");
    listaCamposInfqUnd[++campoCodUni] = new Option("05", "MMBTU");
    listaCamposInfqBanco[++campoBanco] = new Option("peso_total_mercadorias", "PESO BRUTO");
    listaCamposInfqBanco[++campoBanco] = new Option("peso_cubado", "PESO CUBADO");
    listaCamposInfqBanco[++campoBanco] = new Option("volume_total_mercadorias", "VOLUMES");
    listaCamposInfqBanco[++campoBanco] = new Option("metro_cubico", "CUBAGEM");
}

function CamposInfq(idCampo, descricao, unidade, banco, descricaoUnidade) {
    if (listaCamposInfqUnd == null) {
        carregarInfqUniBanco();
    }
    this.idCampo = (idCampo != undefined && idCampo != null ? idCampo : 0);
    this.descricao = (descricao != undefined && descricao != null ? descricao : "");
    this.unidade = (unidade != undefined && unidade != null ? unidade : "");
    this.banco = (banco != undefined && banco != null ? banco : "");
    for (var i = 0; i < listaCamposInfqUnd.length; i++) {
        if (listaCamposInfqUnd[i] != null) {
            if (this.unidade == listaCamposInfqUnd[i].valor) {
                this.unidade = listaCamposInfqUnd[i].valor;
                this.descricaoUnidade = listaCamposInfqUnd[i].descricao;
            }
        }
    }
    for (var i = 0; i < listaCamposInfqBanco.length; i++) {
        if (listaCamposInfqBanco[i] != null) {
            if (this.banco == listaCamposInfqBanco[i].valor) {
                this.banco = listaCamposInfqBanco[i].descricao;
            }
        }
    }
}

var countOcorrenciasEdi = 0;
function addOcorrenciaEdi(ocorrencias) {
    if (ocorrencias == null || ocorrencias == undefined) {
        ocorrencias = new OcorrenciaEdi();
    }
    countOcorrenciasEdi++;
    var estiloMinReadOnly = "inputReadOnly8pt";
    var callLocOcorrencia = "abrirLocalizarOcorrencia(" + countOcorrenciasEdi + ");"
    var tbOcorrenciaEdi = $("tb_ocorrencia");
    var tr_ocorrencia = Builder.node("tr", {
        className: "CelulaZebra2",
        id: "idLinhaOcorrencia_" + countOcorrenciasEdi,
        name: "idLinhaOcorrencia_" + countOcorrenciasEdi,
        colspan: "5"
    });
    var td_ocorrencia_1 = Builder.node("td", {
        align: "center"
    });
    var td_ocorrencia_2 = Builder.node("td", {
        align: "left"
    });
    var td_ocorrencia_3 = Builder.node("td", {
        align: "left"
    });
    var inpClienteId = Builder.node("input", {
        type: "hidden",
        name: "clienteId_" + countOcorrenciasEdi,
        id: "clienteId_" + countOcorrenciasEdi,
        value: ocorrencias.idcliente
    });
    var imgLixoOcorrencia = Builder.node("img", {
        className: "imagemLink",
        src: "img/lixo.png",
        onclick: "excluirOcorrenciaEdi(" + countOcorrenciasEdi + ");"
    });
    var inpIdOcorrencia = Builder.node("input", {
        id: "idOcorrencia_" + countOcorrenciasEdi,
        name: "idOcorrencia_" + countOcorrenciasEdi,
        type: "hidden",
        value: ocorrencias.ocorrenciaid
    });
    var inpOcorrencia = Builder.node("input", {
        id: "clienteOcorrenciaId_" + countOcorrenciasEdi,
        name: "clienteOcorrenciaId_" + countOcorrenciasEdi,
        type: "hidden",
        value: ocorrencias.id
    });
    var codigoEdi = Builder.node("input", {
        id: "codigoEdi_" + countOcorrenciasEdi,
        name: "codigoEdi_" + countOcorrenciasEdi,
        type: "text",
        class: "inputtexto",
        maxLengtDefault: "5",
        size: "5",
        value: ocorrencias.codigoEspecificoEdi
    });
    var inpDescricaoOcorrencia = Builder.node("input", {
        id: "descricaoOcorrencia_" + countOcorrenciasEdi,
        name: "descricaoOcorrencia_" + countOcorrenciasEdi,
        type: "text",
        size: "50",
        className: "inputReadOnly8pt",
        value: ocorrencias.descricaoOcorrencia
    });
    readOnly(inpDescricaoOcorrencia, estiloMinReadOnly);
    var td_localizaOcorrencia = Builder.node("input", {
        id: "localiza_ocorrencia" + countOcorrenciasEdi,
        type: "button",
        className: "inputBotaoMin",
        value: "...",
        onClick: callLocOcorrencia
    });
    td_ocorrencia_1.appendChild(inpOcorrencia);
    td_ocorrencia_1.appendChild(inpIdOcorrencia);
    td_ocorrencia_1.appendChild(inpClienteId);
    td_ocorrencia_1.appendChild(imgLixoOcorrencia);
    td_ocorrencia_2.appendChild(inpDescricaoOcorrencia);
    td_ocorrencia_2.appendChild(td_localizaOcorrencia);
    td_ocorrencia_3.appendChild(codigoEdi);
    tr_ocorrencia.appendChild(td_ocorrencia_1);
    tr_ocorrencia.appendChild(td_ocorrencia_2);
    tr_ocorrencia.appendChild(td_ocorrencia_2);
    tr_ocorrencia.appendChild(td_ocorrencia_3);
    tbOcorrenciaEdi.appendChild(tr_ocorrencia);
    $("maxOcorrencia").value = countOcorrenciasEdi;
}

function abrirConsultarCliente() {
    try {
        tryRequestToServer(function () {
            abrirLocaliza("ConsultaSituacaoControlador?acao=iniciarConsultarPessoaJuridica&cnpj=" + $("cnpj").value + "&campos=" + encodeURI(camposConsultaCliente.toStr()), "conSitPessoa");
        });
    } catch (e) {
        alert(e);
    }
}

function removerEndereco(index) {
    var endereco = $("logradouroEndEntrga_" + index).value;
    var id = $("idEndEntrga_" + index).value;
    if (confirm("Tem certeza que deseja remover o endereço \'" + endereco + "\' ?")) {
        if (id != 0) {
            new Ajax.Request("./jspcadcliente.jsp?acao=removerEnderecoEntrega&idEndereco=" + id, {method: 'get',
                onSuccess: function (transport) {
                    var response = transport.responseText;
                    alert(response);
                    if (response == 'Removido com sucesso!') {
                        Element.remove($("trEndereco_" + index));
                    }
                },
                onFailure: function () {
                    alert('Something went wrong...')
                }
            });
        } else {
            Element.remove($("trEndereco_" + index));
        }
        var existe = false;
        for (i = 1; i <= countEndereco; i++) {
            if ($("trEndereco_" + i) != null) {
                existe = true;
            }
        }
        if (!existe) {
            invisivel($('tbodyEnderecosEntrega'));
        }
    }
}

function removerFaixaVencimento(index) {
    var id = $("idFaixaVenc_" + index).value;
    if (confirm("Tem certeza que deseja remover a Faixa de Vencimento?")) {
        Element.remove($("trFaixaVencimento_" + index));
        if (id != 0) {
            new Ajax.Request("./jspcadcliente.jsp?acao=removerFaixaVencimento&idFaixa=" + id, {method: 'get',
                onSuccess: function () {
                    alert('Faixa de Vencimento removido com sucesso!')
                },
                onFailure: function () {
                    alert('Something went wrong...')
                }
            });
        }
        var existe = false;
        for (i = 1; i <= countFaixaVencimento; i++) {
            if ($("trFaixaVencimento_" + i) != null) {
                existe = true;
            }
        }
        if (!existe) {
            invisivel($('tbodyFaixaVencimento'));
        }
    }
}

function removerXmlAutorizado(index) {
    try {
        var id = $("idXml_" + index).value;
        var idCliente = $("id").value;
        var descricao = ($("xmlAut_" + index).value);
        if (id != 0) {
            if (confirm("Deseja excluir o campo '" + descricao + "'?")) {
                if (confirm("Tem certeza?")) {
                    new Ajax.Request("./jspcadcliente.jsp?acao=removerXmlAutorizadores&id=" + id + "&idCliente=" + idCliente, {method: 'get',
                        onSuccess: function () {
                            Element.remove($("trXmlAut_" + index));
                            $("maxXmlAut").value = parseFloat($("maxXmlAut").value) - 1;
                            alert('Campo removido com sucesso!')
                        },
                        onFailure: function () {
                            alert('Something went wrong...')
                        }});
                }
            }
        } else {
            Element.remove($("trXmlAut_" + index));
            $("maxXmlAut").value = parseFloat($("maxXmlAut").value) - 1;
        }
    } catch (e) {
        alert(e);
    }
}

function XmlAutorizados(id, xml, tpAut) {
    this.id = (id != undefined ? id : "0");
    this.xml = (xml != undefined ? xml : "");
    this.tpAut = (tpAut != undefined ? tpAut : "");
}
var countXml = 0;
function addXmlAutorizado(xmlAut) {
    if (countXml < 10) {
        countXml++;
        if (xmlAut == null || xmlAut == undefined) {
            xmlAut = new XmlAutorizados();
        }
        var td0_ = Builder.node("TD", {align: "center"});
        var td1_ = Builder.node("TD", {align: "center"});
        var td2_ = Builder.node("TD", {align: "center"});
        var _slc = Builder.node("select", {id: "tpAut_" + countXml, name: "tpAut_" + countXml, className: "fieldMin", value: xmlAut.tpAut});
        var optionTp = Builder.node("option", {value: 'CPF'}, 'CPF');
        var optionTp1 = Builder.node("option", {value: 'CNPJ'}, 'CNPJ');
        var hid1_ = Builder.node("INPUT", {type: "hidden", id: "idXml_" + countXml, name: "idXml_" + countXml, value: xmlAut.id});
        var inp1_ = Builder.node("INPUT", {type: "text", id: "xmlAut_" + countXml, name: "xmlAut_" + countXml, value: formatCpfCnpj(xmlAut.xml,true,true), size: "20", maxlength: "15", className: "inputtexto", onkeypress: "mascara(this, soNumeros);digitaCnpj();", onBlur: "this.value=formatCpfCnpj(this.value,false,true)"});
        var _img0 = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerXmlAutorizado(" + countXml + ");"});
        _slc.appendChild(optionTp);
        _slc.appendChild(optionTp1);
        td0_.appendChild(_img0);
        td1_.appendChild(hid1_);
        td1_.appendChild(inp1_);
//            /td2_.appendChild(_slc);  
        var tr1_ = Builder.node("TR", {className: "CelulaZebra2", id: "trXmlAut_" + countXml});
        tr1_.appendChild(td0_);
        tr1_.appendChild(td1_);
        tr1_.appendChild(td2_);
        $("tbXmlAut").appendChild(tr1_);
        $("maxXmlAut").value = countXml;
    } else {
        alert("Limite de 10!");
    }

}
function addTipoProduto(tipoProduto, idTipoProduto) {
    countTipo++;
    if (countTipo == 1 || (countTipo - 1) % 5 == 0) {
        if (countTipo == 1) {
            var _tr = Builder.node("tr", {name: "trTipo", id: "tdTipo"});
            var _td = Builder.node("td", {colSpan: '4'});
            var _table = Builder.node("table", {width: '100%'});
            var _tbody = Builder.node("tbody", {name: 'tbPro', id: 'tbPro'});
        }
        var _trB = Builder.node("tr");
        _trB.appendChild(Builder.node("td", {name: "tdTipo_" + countTipo, id: "tdTipo_" + countTipo, className: "CelulaZebra2", width: '20%'}));
        _trB.appendChild(Builder.node("td", {name: "tdTipo_" + (parseFloat(countTipo) + 1), id: "tdTipo_" + (parseFloat(countTipo) + 1), className: "CelulaZebra2", width: '20%'}));
        _trB.appendChild(Builder.node("td", {name: "tdTipo_" + (parseFloat(countTipo) + 2), id: "tdTipo_" + (parseFloat(countTipo) + 2), className: "CelulaZebra2", width: '20%'}));
        _trB.appendChild(Builder.node("td", {name: "tdTipo_" + (parseFloat(countTipo) + 3), id: "tdTipo_" + (parseFloat(countTipo) + 3), className: "CelulaZebra2", width: '20%'}));
        _trB.appendChild(Builder.node("td", {name: "tdTipo_" + (parseFloat(countTipo) + 4), id: "tdTipo_" + (parseFloat(countTipo) + 4), className: "CelulaZebra2", width: '20%'}));
        if (countTipo == 1) {
            _tbody.appendChild(_trB);
            _table.appendChild(_tbody);
            _td.appendChild(_table);
            _tr.appendChild(_td);
            $("tbTipoProduto").appendChild(_tr);
        } else {
            $("tbPro").appendChild(_trB);
        }
    }
    //id tabela
    var _ip1_1 = Builder.node("input", {
        name: "idTipoProduto_" + countTipo,
        id: "idTipoProduto_" + countTipo,
        type: "hidden",
        value: idTipoProduto});
    var _ip1_2 = Builder.node("img", {
        src: "img/lixo.png",
        onclick: "mensagemExcluir('tdTipo_" + countTipo + "','Realmente deseja excluir o tipo do produto?');"});
    $('tdTipo_' + countTipo).appendChild(_ip1_1);
    $('tdTipo_' + countTipo).appendChild(_ip1_2);
    //tipo produto
    var _ip2 = Builder.node("label", {
        name: "tipoProdutoDesc_" + countTipo,
        id: "tipoProdutoDesc_" + countTipo});
    $('tdTipo_' + countTipo).appendChild(_ip2);
    document.getElementById("maxTipoProduto").value = countTipo;
    $('tipoProdutoDesc_' + countTipo).innerHTML = '. ' + tipoProduto;
}

function imprimiContratos(idTabela) {
    var ids = '';
    jQuery(".idContrato_" + idTabela).each(function () {
        ids = ids + jQuery(this).val() + ",";
    });
    ids = ids.substring(0, (ids.length - 1));

    if (!ids || ids == '') {
        alert('Não existe contrato comercial pra essa tabela de preço!');
    } else {
        launchPDF('ContratoComercialControlador?acao=exportar&id=' + ids);
    }
}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}

function exibiQtdMaximaElayoutImpressao() {
    if ($("chkGerarNumeroEtiquetaIncluirNota").checked) {
        document.getElementById('qtdMaximaElayoutImpressao').style.display='block';
    } else {
        document.getElementById('qtdMaximaElayoutImpressao').style.display='none';
    }
}

function getEnderecoByCepDom(cep, isIgnoraEndereco, index) {
    espereEnviar("", true);
    new Ajax.Request("./jspcadcliente.jsp?acao=getEnderecoByCep&cep=" + cep, {
        method: "get",
        onSuccess: function (transport) {
            var response = transport.responseText;
            carregaCepAjaxDom(response, isIgnoraEndereco, index);
        },
        onFailure: function () {
        }
    });
}

var countFaixaVencimento = 0;

function addFaixaVencimento(faixaVencimento, table) {
    var apelido = "FaixaVenc";
    try {
        if (faixaVencimento == null || faixaVencimento == undefined) {
            faixaVencimento = new DiasVencimentoFatura();
        }
        countFaixaVencimento++;
        var classe = "CelulaZebra2NoAlign";
        var callRemoverFaixaVencimento = "removerFaixaVencimento(" + countFaixaVencimento + ");";
        var _tr = Builder.node("tr", {
            id: "trFaixaVencimento_" + countFaixaVencimento,
            className: classe,
            align: "center"
        });
        var _tdRemove = Builder.node("td", {id: "tdRemove_" + countFaixaVencimento, align: "center"});
        var _tdDiaInicial = Builder.node("td", {id: "tdDiaInicial_" + countFaixaVencimento, align: "center"});
        var _tdDiaFinal = Builder.node("td", {id: "tdDiaFinal_" + countFaixaVencimento, align: "center"});
        var _tdDiaVencimento = Builder.node("td", {id: "tdDiaVencimento_" + countFaixaVencimento, align: "center"});
        var _tdMes = Builder.node("td", {id: "tdMes_" + countFaixaVencimento, align: "center"});
        var _inpId = Builder.node("input", {
            id: "id" + apelido + "_" + countFaixaVencimento,
            name: "id" + apelido + "_" + countFaixaVencimento,
            type: "hidden",
            className: "inputTexto",
            value: faixaVencimento.id
        });
        var _inpImg = Builder.node("img", {
            id: "imgRemove_" + countFaixaVencimento,
            name: "imgRemove_" + countFaixaVencimento,
            src: "img/lixo.png",
            class: "imagemLink",
            onclick: callRemoverFaixaVencimento
        });
        var _inpDiaInicial = Builder.node("input", {
            id: "diaInicial" + apelido + "_" + countFaixaVencimento,
            name: "diaInicial" + apelido + "_" + countFaixaVencimento,
            type: "text",
            className: "inputTexto",
            size: "2",
            value: faixaVencimento.diaInicial
        });
        var _inpDiaFinal = Builder.node("input", {
            id: "diaFinal" + apelido + "_" + countFaixaVencimento,
            name: "diaFinal" + apelido + "_" + countFaixaVencimento,
            type: "text",
            maxLength: "10",
            className: "inputTexto",
            size: "2",
            value: faixaVencimento.diaFinal
        });
        var _inpDiaVencimento = Builder.node("input", {
            id: "diaVencimento" + apelido + "_" + countFaixaVencimento,
            name: "diaVencimento" + apelido + "_" + countFaixaVencimento,
            type: "text",
            maxLength: "60",
            className: "inputTexto",
            size: "2",
            value: faixaVencimento.diaVencimento
        });
        var _inpMes = Builder.node("select", {
            id: "mes" + apelido + "_" + countFaixaVencimento,
            name: "mes" + apelido + "_" + countFaixaVencimento,
            className: "fieldMin"
        });
        var optTpMes1_ = Builder.node("option", {value: 'a'}, 'Atual');
        var optTpMes2_ = Builder.node("option", {value: 's'}, 'Seguinte');
        _inpMes.appendChild(optTpMes1_);
        _inpMes.appendChild(optTpMes2_);
        if (faixaVencimento.mes != null || faixaVencimento.mes != "") {
            _inpMes.value = faixaVencimento.mes;
        }
        _tdRemove.appendChild(_inpId);
        _tdRemove.appendChild(_inpImg);
        _tdDiaInicial.appendChild(_inpDiaInicial);
        _tdDiaFinal.appendChild(_inpDiaFinal);
        _tdDiaVencimento.appendChild(_inpDiaVencimento);
        _tdMes.appendChild(_inpMes);
        _tr.appendChild(_tdRemove);
        _tr.appendChild(_tdDiaInicial);
        _tr.appendChild(_tdDiaFinal);
        _tr.appendChild(_tdDiaVencimento);
        _tr.appendChild(_tdMes);
        table.appendChild(_tr);
        $("qtdFaixas").value = countFaixaVencimento;
        visivel(table);
    } catch (ex) {
        alert(ex);
    }
}

function exibirEtiquetaLayoutImpressao(objx) {
    if(objx.value == 'Padrão'){
        objx.value = '';
    }
    var promp = document.createElement("DIV");
    promp.id = "promptFormula";
    document.body.appendChild(promp);
    var obj = document.getElementById("promptFormula").style;
    obj.zIndex = "3";
    obj.position = "absolute";
    obj.backgroundColor = "#FFFFFF";
    obj.left = "30%";
    obj.top = "90%";
    obj.width = "40%";
    var cmdHtml = "";
    cmdHtml = "<table width='100%' class='bordaFina'>" +
            "<tr class='tabela'>" +
            "<td align='center'>" +
            "Editar Etiqueta Layout Impressao" +
            "</td>" +
            "</tr>" +
            "<tr class='celula'>" +
            "<td align='center'>" +
            "Variáveis" +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td align='center'>" +
            "<table width='100%' class='bordaFina'>" +
            "<tr>" +
            "<td width='20%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@cnpj_remetente\")'>@@cnpj_remetente</label></td>" +
            "<td width='80%' class='TextoCampos' style='text-align: left;'>Imprimir o CNPJ do emissor da nota no código de barras da etiqueta com 14 dígitos.</td>" +
            "</tr>" +
            "<tr>" +
            "<td width='20%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@nota\")'>@@nota</label></td>" +
            "<td width='80%' class='TextoCampos' style='text-align: left;'>Imprimir o número da nota fiscal no código de barras da etiqueta com 8 dígitos.</td>" +
            "</tr>" +
            "<tr>" +
            "<td width='20%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@qtd\")'>@@qtd</label></td>" +
            "<td width='80%' class='TextoCampos' style='text-align: left;'>Imprimir o número do volume no código de barras da etiqueta com 4 dígitos.</td>" +
            "</tr>" +
            "<tr>" +
            "<td width='20%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@total_vol\")'>@@total_vol</label></td>" +
            "<td width='80%' class='TextoCampos' style='text-align: left;'>Imprimir o total de volumes no código de barras da etiqueta com 4 dígitos.</td>" +
            "</tr>" +
            "<tr>" +
            "<td width='20%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@serie\")'>@@serie</label></td>" +
            "<td width='80%' class='TextoCampos' style='text-align: left;'>Imprimir a série da nota fiscal no código de barras da etiqueta com 2 dígitos.</td>" +
            "</tr>" +
            "<tr>" +
            "<td width='20%' class='CelulaZebra2'><label class='linkEditar' onclick='setVariavelFormula(\"@@pedido\")'>@@pedido</label></td>" +
            "<td width='80%' class='TextoCampos' style='text-align: left;'>Imprimir o número do pedido da nota fiscal no código de barras da etiqueta com 8 dígitos</td>" +
            "</tr>" +
            "<tr>" +
            "<td colspan='2' class='TextoCampos' style='text-align: left;'>A T E N Ç Ã O! Para determinar a quantidade de dígitos de uma variável deverá preencher entre parênteses. Exemplo: @@pedido(9), @@serie(2), @@nota(6). Se não colocar a quantidade de dígitos o sistema irá gerar com a quantidade default de cada campo. </td>" +
            "</tr>" +
            "</tr>" +
            "</table>" +
            "</td>" +
            "</tr>" +
            "<tr>" +
            "<td class='CelulaZebra2NoAlign' align='center'>" +
            "<textarea cols='70' rows='13' name='ed_formula' type='text' id='ed_formula' style='font-size:8pt;'>" + objx.value + "</textarea>" +
            "</td>" +
            "</tr>" +
            "<tr class='CelulaZebra2'>" +
            "<td align='center'>" +
            "<input name='btSalvaFormula' id='btSalvaFormula' type='button' class='botoes' value='Confirmar' alt='Salvar as alterações na fórmula'>" +
            "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" +
            "<input name='btFechaFormula' id='btFechaFormula' type='button' class='botoes' value='Cancelar' alt='Cancelar as alterações na fórmula'>" +
            "</td>" +
            "</tr>" +
            "</table>";
    document.getElementById("promptFormula").innerHTML = cmdHtml;
    document.getElementById("promptFormula").style.display = "";
    document.getElementById("btSalvaFormula").onclick = function () {
        if($('ed_formula').value == '' || $('ed_formula').value == null){
            $('ed_formula').value = 'Padrão';
        }
        objx.value = $('ed_formula').value;
        document.getElementById("promptFormula").style.display = "none";//
        isFormulaReadOnly(objx.id);
    }
    document.getElementById("btFechaFormula").onclick = function () {
        document.getElementById("promptFormula").style.display = "none";
    }
}

function setVariavelFormula(variavel) {
    $("ed_formula").value += variavel;
}

function mostrarRadioResponsavel(index) {
    if (jQuery('#chkResponsavel_' + index).is(":checked")) {
        $("divResponsavelRadio_" + index).style.display = "";
    } else {
        $("divResponsavelRadio_" + index).style.display = "none";
    }
}

function validarPermissaoUsuario(permissao, tipo, disable) {
    if (tipo == 'operacional') {
        if (permissao == '0') {
            jQuery('#tab5').find('input,select,img').each(function (key, element) {
                if (element.tagName == 'IMG') {
                    element.style.display = (disable ? 'none' : '');
                } else {
                    element.readonly = disable;
                    element.disabled = disable;
                }
            });
        }
    }
}

function OcorrenciaEdi(id, idcliente, ocorrenciaid, descricaoOcorrencia, codigoEspecificoEdi) {
    this.id = (id == null || id == undefined ? 0 : id);
    this.idcliente = (idcliente == null || idcliente == undefined ? 0 : idcliente);
    this.ocorrenciaid = (ocorrenciaid == null || ocorrenciaid == undefined ? 0 : ocorrenciaid);
    this.descricaoOcorrencia = (descricaoOcorrencia == null || descricaoOcorrencia == undefined ? "" : descricaoOcorrencia);
    this.codigoEspecificoEdi = (codigoEspecificoEdi == null || codigoEspecificoEdi == undefined ? "" : codigoEspecificoEdi);
}

function handlerElement(_elemento, tipo) {
    if (tipo == 2 || tipo == 4) {
        visivel(_elemento);
    } else {
        invisivel(_elemento);
    }
}

function removerLayout(index, tipo) {
    try {
        var id = $("idLayout_" + tipo + "_" + index).value;
        var descricao = getTextSelect($("versao_" + tipo + "_" + index));
        if (confirm("Deseja excluir o layout '" + descricao + "'?")) {
            if (confirm("Tem certeza?")) {
                // Irá pegar todos os IDs dos crons do layout, se existir, desconsiderando IDs em branco ou zerado.
                let idsCron = jQuery('[id^=trCron_' + tipo + '_' + index + '_]').find('[id^="idCron"]').map((i, e) => e.value).toArray().filter(idCr => idCr !== '' && idCr !== '0');
                
                let podeExcluirLayout = true;

                // Se existir os IDs dos crons, irá excluir antes de excluir o layout
                if (idsCron.length > 0) {
                    // Irá fazer um loop dos IDs
                    idsCron.forEach(idCr => {
                        // Irá executar um AJAX síncrono para excluir o CRON
                        jQuery.ajax({
                            url: "./jspcadcliente.jsp?acao=ajaxRemoverMomentoLayoutEDI&idMomentoLayoutEDI=" + idCr,
                            async: false,
                            success: function (result) {
                                podeExcluirLayout = true;
                            },
                            failure: function (result) {
                                podeExcluirLayout = false;
                            }
                        });
                    });
                }
                
                // Se não houve erro ao excluir os CRONs, ou se não tinha CRON a ser excluido, irá apagar o layout
                if (podeExcluirLayout) {
                    // Realizando requisição AJAX para apagar o layout.
                    new Ajax.Request("LayoutEDIControlador?acao=ajaxRemoverClienteLayoutEDI&idClienteLayoutEDI=" + id, {
                        method: 'get',
                        onSuccess: function () {
                            alert('Layout removido com sucesso!');
                            Element.remove($("trEDI1_" + tipo + "_" + index));
                            Element.remove($("trEDI2_" + tipo + "_" + index));

                            if ($("trEDIEnviAuto_" + tipo + "_" + index) != null) {
                                Element.remove($("trEDIEnviAuto_" + tipo + "_" + index));
                            }

                            if ($("tableLogin_" + tipo + "_" + index) != null) {
                                Element.remove($("tableLogin_" + tipo + "_" + index));
                            }
                        },
                        onFailure: function () {
                            alert('Something went wrong...');
                        }
                    });
                }
            }
        }
    } catch (e) {
        alert(e);
    }
}

function removerMomentoLayoutEDI(tipo, idxLayout, countCron) {
    try {
        var sufixo = "_" + tipo + "_" + idxLayout + "_" + countCron;
        var id = $("idCron" + sufixo).value;
        if (confirm("Deseja excluir o momento do layout ?")) {
            if (confirm("Tem certeza?")) {
                Element.remove($("trCron" + sufixo));
                new Ajax.Request("./jspcadcliente.jsp?acao=ajaxRemoverMomentoLayoutEDI&idMomentoLayoutEDI=" + id, {
                    method: 'get',
                    onSuccess: function () {
                        alert('Layout removido com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
            }
        }


    } catch (e) {
        alert(e);
    }
}

function Campos(idCampo, descricao, campoCte) {
    this.idCampo = (idCampo != undefined ? idCampo : 0);
    this.descricao = (descricao != undefined ? descricao : "");
    this.campoCte = (campoCte != undefined ? campoCte : "");
}

var countCampo = 0;

function addCampos(campo) {
    countCampo++;
    var lista = listaCampoXml;
    if (campo == null || campo == undefined) {
        campo = new Campos();
    }
    var td0_ = Builder.node("TD", {align: "center"});
    var td1_ = Builder.node("TD", {align: "center"});
    var td2_ = Builder.node("TD", {align: "center"});
    var _slc = Builder.node("select", {
        id: "campos_" + countCampo,
        name: "campos_" + countCampo,
        className: "fieldMin"
    });
    _slc.style.width = "95%";
    //campos
    var hid1_ = Builder.node("INPUT", {
        type: "hidden",
        id: "idCampo_" + countCampo,
        name: "idCampo_" + countCampo,
        value: campo.idCampo
    });
    // Descricao Rota
    var inp1_ = Builder.node("INPUT", {
        type: "text",
        id: "descricaoTag_" + countCampo,
        name: "descricaoTag_" + countCampo,
        value: campo.descricao,
        size: "15",
        maxlength: "20",
        className: "inputtexto"
    });
    var inp2_ = null;
    if (lista != null) {
        if (campo.campoCte == null || campo.campoCte == "") {
            for (var i = 1; i < lista.length; i++) {
                inp2_ = Builder.node("option", {value: lista[i].valor});
                Element.update(inp2_, lista[i].descricao);
                _slc.appendChild(inp2_);
            }
        } else {
            inp2_ = Builder.node("option", {value: campo.campoCte});
            Element.update(inp2_, campo.campoCte);
            _slc.appendChild(inp2_);
        }
    }
    ;
    var _img0 = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerItem(" + countCampo + ");"});
    td0_.appendChild(_img0);
    td1_.appendChild(hid1_);
    td1_.appendChild(inp1_);
    td2_.appendChild(_slc);
    var tr1_ = Builder.node("TR", {className: "CelulaZebra2", id: "trCampo_" + countCampo});
    tr1_.appendChild(td0_);
    tr1_.appendChild(td1_);
    tr1_.appendChild(td2_);
    $("tbCampo").appendChild(tr1_);
    $("maxCampo").value = countCampo;
}

var countCampoInfQ = 0;

function addCampoInfQ(camposInfq) {
    countCampoInfQ++;
    if (listaCamposInfqUnd == null || listaCamposInfqBanco == null) {
        carregarInfqUniBanco();
    }
    if (camposInfq == null || camposInfq == undefined) {
        camposInfq = new CamposInfq();
    }
    var td0_ = Builder.node("TD", {align: "center"});
    var td1_ = Builder.node("TD", {align: "center"});
    var td2_ = Builder.node("TD", {align: "center"});
    var td3_ = Builder.node("TD", {align: "center"});
    var _slc_cod = Builder.node("select", {
        id: "codUndInfQ_" + countCampoInfQ,
        name: "codUndInfQ_" + countCampoInfQ,
        className: "fieldMin"
    });
    _slc_cod.style.width = "95%";
    var _slc_banco = Builder.node("select", {
        id: "campoBanco_" + countCampoInfQ,
        name: "campoBanco_" + countCampoInfQ,
        className: "fieldMin"
    });
    _slc_banco.style.width = "95%";
    var hid1_ = Builder.node("INPUT", {
        type: "hidden",
        id: "idCampoInfQ_" + countCampoInfQ,
        name: "idCampoInfQ_" + countCampoInfQ,
        value: camposInfq.idCampo
    });
    var inp1_ = Builder.node("INPUT", {
        type: "text",
        id: "descricaoTagInfQ_" + countCampoInfQ,
        name: "descricaoTagInfQ_" + countCampoInfQ,
        value: camposInfq.descricao,
        size: "20",
        className: "inputtexto"
    });
    var inp2_ = null;
    var inp3_ = null;
    if (listaCamposInfqUnd != null && listaCamposInfqBanco != null) {
        if (camposInfq.unidade == null || camposInfq.unidade == "") {
            for (var i = 1; i < listaCamposInfqUnd.length; i++) {
                inp2_ = Builder.node("option", {
                    value: listaCamposInfqUnd[i].valor
                });
                Element.update(inp2_, listaCamposInfqUnd[i].descricao);
                _slc_cod.appendChild(inp2_);
            }
        } else {
            inp2_ = Builder.node("option", {value: camposInfq.unidade});
            Element.update(inp2_, camposInfq.descricaoUnidade);
            _slc_cod.appendChild(inp2_);
        }
        if (camposInfq.banco == null || camposInfq.banco == "") {
            for (var i = 1; i < listaCamposInfqBanco.length; i++) {
                inp3_ = Builder.node("option", {
                    value: listaCamposInfqBanco[i].valor
                });
                Element.update(inp3_, listaCamposInfqBanco[i].descricao);
                _slc_banco.appendChild(inp3_);
            }
        } else {
            inp3_ = Builder.node("option", {value: camposInfq.banco});
            Element.update(inp3_, camposInfq.banco);
            _slc_banco.appendChild(inp3_);
        }
    }
    var _img0 = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerItemInfQ(" + countCampoInfQ + ");"});
    td0_.appendChild(_img0);
    td1_.appendChild(hid1_);
    td1_.appendChild(inp1_);
    td2_.appendChild(_slc_cod);
    td3_.appendChild(_slc_banco);
    var tr1_ = Builder.node("TR", {className: "CelulaZebra2", id: "trCampoInfQ_" + countCampoInfQ});
    tr1_.appendChild(td0_);
    tr1_.appendChild(td1_);
    tr1_.appendChild(td2_);
    tr1_.appendChild(td3_);
    $("tbCampoInfQ").appendChild(tr1_);
    $("maxCampoInfQ").value = countCampoInfQ;
}

function removerItemInfQ(index) {
    try {
        var id = $("idCampoInfQ_" + index).value;
        var idCliente = $("id").value;
        var descricao = ($("descricaoTagInfQ_" + index).value);
        if (confirm("Deseja excluir o campo '" + descricao + "'?")) {
            if (confirm("Tem certeza?")) {
                new Ajax.Request("./jspcadcliente.jsp?acao=removerCamposInfq&id=" + id + "&idCliente=" + idCliente, {
                    method: 'get',
                    onSuccess: function () {
                        Element.remove($("trCampoInfQ_" + index));
                        alert('Campo removido com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
            }
        }
    } catch (e) {
        alert(e);
    }
}

function removerItem(index) {
    try {
        var id = $("idCampo_" + index).value;
        var idCliente = $("id").value;
        var descricao = ($("descricaoTag_" + index).value);
        if (confirm("Deseja excluir o campo '" + descricao + "'?")) {
            if (confirm("Tem certeza?")) {
                new Ajax.Request("./jspcadcliente.jsp?acao=removerCamposXML&id=" + id + "&idCliente=" + idCliente, {
                    method: 'get',
                    onSuccess: function () {
                        Element.remove($("trCampo_" + index));
                        alert('Campo removido com sucesso!')
                    },
                    onFailure: function () {
                        alert('Something went wrong...')
                    }
                });
            }
        }
    } catch (e) {
        alert(e);
    }
}

function Taxas(id, descricao, idtaxa, nomeTaxa, ignorarXml) {
    this.id = (id != undefined ? id : 0);
    this.idtaxa = (idtaxa != undefined ? idtaxa : 0);
    this.descricao = (descricao != undefined ? descricao : "");
    this.nomeTaxa = (nomeTaxa != undefined ? nomeTaxa : "");
    this.ignorarXml = (ignorarXml != undefined ? ignorarXml : false);
}

var countCampoTaxas = 0;

function addCamposTaxas(taxa) {
    countCampoTaxas++;
    var lista = listaCampoTaxas;
    if (taxa == null || taxa == undefined) {
        taxa = new Taxas();
    }
    var td0_ = Builder.node("TD", {align: "center"});
    var td1_ = Builder.node("TD", {align: "center"});
    var td2_ = Builder.node("TD", {align: "center"});
    var td3_ = Builder.node("TD", {align: "center"});
    var _slc = Builder.node("select", {
        id: "taxas_" + countCampoTaxas,
        name: "taxas_" + countCampoTaxas,
        className: "fieldMin"
    });
    //campos
    var hid1_ = Builder.node("INPUT", {
        type: "hidden",
        id: "idTaxas_" + countCampoTaxas,
        name: "idTaxas_" + countCampoTaxas,
        value: taxa.id
    });
    // Descricao Rota
    var inp1_ = Builder.node("INPUT", {
        type: "text",
        id: "descricaoTaxas_" + countCampoTaxas,
        name: "descricaoTaxas_" + countCampoTaxas,
        value: taxa.descricao,
        size: "20",
        maxlength: "15",
        className: "inputtexto"
    });
    var inp2_ = null;
    var inp3_ = Builder.node("INPUT", {
        type: "checkbox",
        id: "isIgnorar_" + countCampoTaxas,
        name: "isIgnorar_" + countCampoTaxas,
    });
    if (taxa.ignorarXml == "true") {
        inp3_.checked = true;
    }
    if (lista != null) {
        for (var i = 1; i < lista.length; i++) {
            inp2_ = Builder.node("option", {
                value: lista[i].valor
            });
            Element.update(inp2_, lista[i].descricao);
            _slc.appendChild(inp2_);
        }
        if (taxa.idtaxa == 0) {
            _slc.selectedIndex = 0;
        } else {
            _slc.value = taxa.idtaxa;
        }
    }
    ;
    var _img0 = Builder.node("IMG", {src: "img/lixo.png", onClick: "removerTaxa(" + countCampoTaxas + ");"});
    td0_.appendChild(_img0);
    td1_.appendChild(hid1_);
    td1_.appendChild(inp1_);
    td2_.appendChild(_slc);
    td3_.appendChild(inp3_);
    var tr1_ = Builder.node("TR", {className: "CelulaZebra2", id: "trCampoTaxas_" + countCampoTaxas});
    tr1_.appendChild(td0_);
    tr1_.appendChild(td3_);
    tr1_.appendChild(td1_);
    tr1_.appendChild(td2_);
    $("tbTaxas").appendChild(tr1_);
    $("maxTaxas").value = countCampoTaxas;
}

function abrirLocalizarCidadeDiaria(index) {
    if ($("indexAux") != null) {
        $("indexAux").value = index;
    }
    popLocate(11, "Cidade_Diaria", "");
}

function CamposDiarias(idDiaria, idClienteDiaria, valorDiaria, idVeiculoDiaria, diariaVeiculo, idDiariaTipoProduto, diariaProduto, idCidadeDiarias, descCidadeDiarias, ufCidadeDiarias) {
    this.idDiaria = (idDiaria != undefined ? idDiaria : 0);
    this.idClienteDiaria = (idClienteDiaria != undefined && idClienteDiaria != "null" ? idClienteDiaria : 0);
    this.valorDiaria = (valorDiaria != undefined && valorDiaria != "null" ? valorDiaria : "0.00");
    this.idVeiculoDiaria = (idVeiculoDiaria != undefined ? idVeiculoDiaria : 0);
    this.diariaVeiculo = (diariaVeiculo != undefined && diariaVeiculo != "null" ? diariaVeiculo : "");
    this.idDiariaTipoProduto = (idDiariaTipoProduto != undefined && idDiariaTipoProduto != "null" ? idDiariaTipoProduto : 0);
    this.campoProduto = (diariaProduto != undefined && diariaProduto != "null" ? diariaProduto : "");
    this.idCidadeDiarias = (idCidadeDiarias != undefined && idCidadeDiarias != "null" ? idCidadeDiarias : 0);
    this.descCidadeDiarias = (descCidadeDiarias != undefined && descCidadeDiarias != "null" ? descCidadeDiarias : "");
    this.ufCidadeDiarias = (ufCidadeDiarias != undefined && ufCidadeDiarias != "null" ? ufCidadeDiarias : "");
}

var contExcecaoCliente = 0;

function addExcecaoCliente(tipoCliente, numeroRespseg, idClienteRespseg, idCliente, razaoCliente) {
    //a tabela na qual será inserido
    var tabelaBase = $("excecaoClientes");
    //a tr na qual será inserido as TDs
    var trBaseExcecao = Builder.node("tr", {
        class: "celulaZebra2",
        id: 'trClienteExcecao_' + contExcecaoCliente,
        name: 'trClienteExcecao_' + contExcecaoCliente
    });
    //secao de criacao das TDs //TD base
    var tdBaseExcecao = Builder.node("td", {});
    //TD do icone de excluir
    var tdExcluir = Builder.node("td", {width: "2%"});
    //td do campo de Cliente //fim secao de criacao de TDs //secao de criacao de HIDDENS //hidden do id do cliente respseg
    var hiddenIdClienteRespseg = Builder.node("input", {
        type: 'hidden',
        id: 'idClienteRespseg_' + contExcecaoCliente,
        name: 'idClienteRespseg_' + contExcecaoCliente,
        value: (idClienteRespseg == undefined ? "0" : idClienteRespseg)
    });
    //hidden do id do cliente
    var hiddenIdClienteExcecao = Builder.node("input", {
        type: "hidden",
        id: "idClienteExcecao_" + contExcecaoCliente,
        name: "idClienteExcecao_" + contExcecaoCliente,
        value: (idCliente == undefined ? "0" : idCliente)
    });
    //fim secao de hiddens  //secao de o que sera apresentado na tela //label que escreverá "para o"
    var label_SE = Builder.node("label", {name: 'labelParaO', id: 'labelParaO'});
    label_SE.innerHTML = 'Se o ';
    var label_For = Builder.node("label", {name: 'labelQuandoFor', id: 'labelQuandoFor'});
    label_For.innerHTML = '  for   ';
    //label que escreverá "sempre considerar o tipo de seguro"
    var label_Sempre_Considerar = Builder.node("label", {name: 'labelSempreConsiderar', id: 'labelSempreConsiderar'});
    label_Sempre_Considerar.innerHTML = '  considerar o tipo de seguro do   ';
    //tipos de cliente : Remetente, Destinatário, Consignatário(Tomador do serviço), redespacho, expedidor, recebedor
    var selectTipoCliente = Builder.node("select", {
        id: "tipoClienteExcecao_" + contExcecaoCliente,
        name: "tipoClienteExcecao_" + contExcecaoCliente,
        class: "fieldMin"
    });
    for (var i = 0; i < listaTipoCliente.length; i++) {
        var optionTipoCliente = Builder.node("option", {value: i});
        Element.update(optionTipoCliente, listaTipoCliente[i]);
        selectTipoCliente.appendChild(optionTipoCliente);
    }
    if (tipoCliente == undefined) {
        selectTipoCliente.selectedIndex = 0;
    } else {
        selectTipoCliente.value = tipoCliente;
    }
    //select com os tipos de seguro(de acordo com a documentacao do portalCTE)
    var selectResponsavelSerguro = Builder.node("select", {
        id: "responsavelSeguro_" + contExcecaoCliente,
        name: "responsavelSeguro_" + contExcecaoCliente,
        class: "fieldMin"
    });
    for (var r = 0; r < listaResponsavelSeguro.length; r++) {
        var optionResponsavelSeguro = Builder.node("option", {value: r});
        Element.update(optionResponsavelSeguro, listaResponsavelSeguro[r]);
        selectResponsavelSerguro.appendChild(optionResponsavelSeguro);
    }
    if (numeroRespseg == undefined) {
        selectResponsavelSerguro.selectedIndex = 0;
    } else {
        selectResponsavelSerguro.value = numeroRespseg;
    }
    //imagem de eexcluir a excecao
    var excluirExcecao = Builder.node("IMG", {
        src: "img/lixo.png",
        onClick: "removerExcecaoCliente(" + contExcecaoCliente + ");"
    });
    //campo onde aparecera o nome do cliente escolhido
    var razaoCliente = Builder.node("input", {
        id: "razaoClienteExcecao_" + contExcecaoCliente,
        name: "razaoClienteExcecao_" + contExcecaoCliente,
        class: "inputReadOnly8pt",
        value: (razaoCliente == undefined ? "Todos os Clientes" : razaoCliente),
        size: "25"
    });
    razaoCliente.readOnly = 'true';
    //campo de localizar o cliente
    var botaoLocalizaClienteExcecao = Builder.node("input", {
        type: "button",
        onclick: "abrirLocalizaClienteExcecao(" + contExcecaoCliente + ");",
        class: "botoes",
        value: "..."
    });
    //campo de limpar o nome do cliente e o ID também.
    var botaoLimparCliente = Builder.node("img", {
        src: "img/borracha.gif",
        onClick: 'limparClienteExcecao(' + contExcecaoCliente + ');'
    });
    //fim da secao de o que aparecerá na tela.
    //parte de hiddens com ids.
    tdBaseExcecao.appendChild(hiddenIdClienteRespseg);
    //tdCliente.appendChild(hiddenIdClienteExcecao);//id
    //povoando as TDs.
    tdBaseExcecao.appendChild(label_SE);
    tdBaseExcecao.appendChild(selectTipoCliente);
    tdBaseExcecao.appendChild(label_For);
    tdBaseExcecao.appendChild(hiddenIdClienteExcecao);
    tdBaseExcecao.appendChild(razaoCliente);
    tdBaseExcecao.appendChild(botaoLocalizaClienteExcecao);
    tdBaseExcecao.appendChild(botaoLimparCliente);
    //razaoCliente botaoLocalizaClienteExcecao botaoLimparCliente
    tdBaseExcecao.appendChild(label_Sempre_Considerar);
    tdBaseExcecao.appendChild(selectResponsavelSerguro);
//            tdCliente.appendChild(razaoCliente);//nome
//            tdCliente.appendChild(botaoLocalizaClienteExcecao);//botao
//            tdCliente.appendChild(botaoLimparCliente);//borracha//
    tdExcluir.appendChild(excluirExcecao);
    //povoando a TR.
    trBaseExcecao.appendChild(tdExcluir);
    //trBaseExcecao.appendChild(tdCliente);
    trBaseExcecao.appendChild(tdBaseExcecao);
    //incluindo a TR na tabela.
    tabelaBase.appendChild(trBaseExcecao);
    contExcecaoCliente++;
    $("contExcecaoCliente").value = contExcecaoCliente;
}

function abrirLocalizaClienteExcecao(index) {
    $("indexClienteExcecao").value = index;
    launchPopupLocate('./localiza?&acao=consultar&idlista=3', 'ClienteExcecao');
}

function limparClienteExcecao(index) {
    $("idClienteExcecao_" + index).value = '0';
    $("razaoClienteExcecao_" + index).value = 'Todos os Clientes';
}

function removerExcecaoCliente(index) {
    try {
        var idClienteRespseg = $("idClienteRespseg_" + index).value;
        if (confirm("Deseja mesmo excluir ?")) {
            if (confirm("Tem certeza?")) {
                new Ajax.Request("./jspcadcliente.jsp?acao=removerClienteRespseg&idClienteRespseg=" + idClienteRespseg, {
                    method: 'get',
                    onSuccess: function () {
                        alert('removido com sucesso!');
                    },
                    onFailure: function () {
                        alert('não foi possivel excluir o campo selecionado!');
                    }
                });
                Element.remove($("trClienteExcecao_" + index));
            }
        }
    } catch (erro) {
        alert(erro);
    }
}

function Campos(idCampo, descricao, campoCte) {
    this.idCampo = (idCampo != undefined ? idCampo : 0);
    this.descricao = (descricao != undefined ? descricao : "");
    this.campoCte = (campoCte != undefined ? campoCte : "");
}

function StICMS(idClienteICMS, idStICMS, filial, usarNormativa398, reducaoBase, percentualCreditoPresumido, isNormativa129816go) {
    this.idClienteICMS = (idClienteICMS != undefined ? idClienteICMS : 0);
    this.idStICMS = (idStICMS != undefined ? idStICMS : 0);
    this.filial = (filial != undefined ? filial : 0);
    this.usarNormativa398 = (usarNormativa398 != undefined ? usarNormativa398 : false);
    this.reducaoBase = (reducaoBase != undefined ? reducaoBase : "0.00");
    this.percentualCreditoPresumido = (percentualCreditoPresumido != undefined ? percentualCreditoPresumido : "0.00");
    this.isNormativa129816go = (isNormativa129816go != undefined ? isNormativa129816go : false);
}

function mostrarBloq() {
    if (jQuery("#chkAnaliseCredito").attr("checked")) {
        jQuery("#divAnalise").removeAttr("colspan");//Remove o colspan
        jQuery("#permitirBloqNotas").css("display", "");
    } else {
        jQuery("#divAnalise").attr("colspan", 2);//Atribui o colspan

        jQuery("#permitirBloqNotas").css("display", "none");
    }
}

function mostrarFTP() {
    if ($("isEnviaFtp").checked) {
        $("enviaXmlFtp").show();
    } else {
        $("enviaXmlFtp").hide();
    }
}

function checkEnvioEmailMDF(valor) {
    if (valor === 1 || valor === 0){
        $('envioMDFDAM').checked = true;//valor padrão
    } if (valor ===  2){
        $('envioMDFDAC').checked = true;
    } if (valor === 3){
        $('envioMDFCTE').checked = true;
    } if (valor ===  4){
        $('envioMDFALL').checked = true;
    }
}
function pesquisarAuditoria() {
    for (var i = 1; i <= countLog; i++) {
        if ($("tr1Log_" + i) != null) {
            Element.remove(("tr1Log_" + i));
        }
        if ($("tr2Log_" + i) != null) {
            Element.remove(("tr2Log_" + i));
        }
    }
    countLog = 0;
    var rotina = "cliente";
    var dataDe = $("dataDeAuditoria").value;
    var dataAte = $("dataAteAuditoria").value;
    var id = clienteAuditoriaId;
    consultarLog(rotina, id, dataDe, dataAte);
}

var countEDI_c = 0;
var countEDI_f = 0;
var countEDI_o = 0;
var listLayoutEDI_c = new Array();
var listLayoutEDI_f = new Array();
var listLayoutEDI_o = new Array();
var listLayoutEDI_obj = new Array();
var idxO = 0;
var idxObj = 0;
var idxC = 0;
var idxF = 0;

listLayoutEDI_c[idxC] = new Option("", "----SELECIONE----");
listLayoutEDI_c[++idxC] = new Option("bpcs-cremer", "BPCS (Cremer S/A)");
listLayoutEDI_c[++idxC] = new Option("docile-conemb", "EMS Datasul/Totvs (Docile Ltda)");
listLayoutEDI_c[++idxC] = new Option("docile-conemb", "EMS Datasul/Totvs (Docile Ltda)");
listLayoutEDI_c[++idxC] = new Option("gerdau", "Gerdau");
listLayoutEDI_c[++idxC] = new Option("mercador", "Mercador");
listLayoutEDI_c[++idxC] = new Option("neogrid_conemb", "NeoGrid");
listLayoutEDI_c[++idxC] = new Option("nestle", "Nestle");
listLayoutEDI_c[++idxC] = new Option("pro3.0a", "Proceda 3.0a");
listLayoutEDI_c[++idxC] = new Option("pro3.0aTramontina", "Proceda 3.0a (Tramontina)");
listLayoutEDI_c[++idxC] = new Option("pro3.1", "Proceda 3.1");
listLayoutEDI_c[++idxC] = new Option("pro3.1betta", "Proceda 3.1 (Bettanin)");
listLayoutEDI_c[++idxC] = new Option("pro3.1gko", "Proceda 3.1 (GKO)");
listLayoutEDI_c[++idxC] = new Option("pro3.1kimberly", "Proceda 3.1 (Kimberly)");
listLayoutEDI_c[++idxC] = new Option("pro4.0", "Proceda 4.0 (Aliança)");
listLayoutEDI_c[++idxC] = new Option("pro5.0", "Proceda 5.0");
listLayoutEDI_c[++idxC] = new Option("santher3.1-conemb", "Santher 3.1");
listLayoutEDI_c[++idxC] = new Option("ricardo-conemb", "Ricardo Eletro");
listLayoutEDI_c[++idxC] = new Option("terphane", "Terphane");
listLayoutEDI_c[++idxC] = new Option("tivit3.1-conemb", "Tivit 3.0 (GDC)");
listLayoutEDI_c[++idxC] = new Option("usiminas", "Soluções Usiminas");
listLayoutEDI_c[++idxC] = new Option("webserviceAvon", "Avon (Web Service)");
listLayoutEDI_c[++idxC] = new Option("webserviceClaro", "Claro S/A (XML CTE - Web Service)");


listLayoutEDI_f[idxF] = new Option("", "----SELECIONE----");
listLayoutEDI_f[++idxF] = new Option("intral", "EMS Datasul/Totvs (Intral S/A)");
listLayoutEDI_f[++idxF] = new Option("neogrid_doccob", "NeoGrid");
listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob", "Proceda 3.0a");
listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-alianca", "Proceda 3.0a (Aliança)");
listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-betta", "Proceda 3.0a (Bettanin)");
listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-dhl", "Proceda 3.0a (DHL)");
listLayoutEDI_f[++idxF] = new Option("pro3.0a-doccob-paulus", "Proceda 3.0a (Paulus)");
listLayoutEDI_f[++idxF] = new Option("ricardo-doccob", "Ricardo Eletro");
listLayoutEDI_f[++idxF] = new Option("roca-doccob", "Roca Brasil");
listLayoutEDI_f[++idxF] = new Option("santher3.0a-doccob", "Santher 3.0a");
listLayoutEDI_f[++idxF] = new Option("tivit3.0a-doccob", "Tivit 3.0a");
listLayoutEDI_f[++idxF] = new Option("pro5.0-doccob", "Proceda 5.0");
listLayoutEDI_f[++idxF] = new Option("webserviceAvon_env", "Avon (Web Service Envio)");
listLayoutEDI_f[++idxF] = new Option("webserviceAvon_con", "Avon (Web Service Consulta)");


listLayoutEDI_o[idxO] = new Option("", "----SELECIONE----");
listLayoutEDI_o[++idxO] = new Option("bpcs-cremer-ocoren", "BPCS (Cremer S/A)");
listLayoutEDI_o[++idxO] = new Option("docile-ocoren", "EMS Datasul/Totvs (Docile Ltda)");
listLayoutEDI_o[++idxO] = new Option("electrolux", "Electrolux");
listLayoutEDI_o[++idxO] = new Option("neogrid_ocoren", "NeoGrid");
listLayoutEDI_o[++idxO] = new Option("pro3.0a-ocoren", "Proceda 3.0a");
listLayoutEDI_o[++idxO] = new Option("pro3.0a-ocoren-alianca", "Proceda 3.0a (Aliança)");
listLayoutEDI_o[++idxO] = new Option("pro3.0a-ocoren-hyper", "Proceda 3.0a (Hypermarcas)");
listLayoutEDI_o[++idxO] = new Option("pro3.1-ocoren", "Proceda 3.1");
listLayoutEDI_o[++idxO] = new Option("pro3.1-ocoren-betta", "Proceda 3.1 (Bettanin)");
listLayoutEDI_o[++idxO] = new Option("pro5.0-ocoren", "Proceda 5.0");
listLayoutEDI_o[++idxO] = new Option("ricardo-ocoren", "Ricardo Eletro");
listLayoutEDI_o[++idxO] = new Option("roca-ocoren", "Roca Brasil");
listLayoutEDI_o[++idxO] = new Option("santher3.1-ocoren", "Santher 3.1");
listLayoutEDI_o[++idxO] = new Option("tivit3.0a-ocoren", "Tivit 3.0a (GDC)");
listLayoutEDI_o[++idxO] = new Option("sap-webservice", "SAP (Web Service)");

function isExibirSerieMinuta(slc) {
    if (slc.value === '2') {
        visivel($('div-serie-minuta'));
    } else {
        invisivel($('div-serie-minuta'));
    }
}

function aoClicarAdicionarTags(index, classe, tagAdicional) {
    if (tagAdicional === undefined) {
        tagAdicional = {
            'nome_tag': '',
            'campo': 'pedido_nfe',
            'id': '0'
        }
    }
    
    if (classe === undefined) {
        classe = (index % 2 === 1 ? "CelulaZebra1" : "CelulaZebra2");
    }

    let tbodyAdicionarTags = jQuery('#tbodyTagsPersonalizadas_' + index);

    let qtdTag = parseInt($('qtdDomTagsPersonalizadas_' + index).value) + 1;

    $('qtdDomTagsPersonalizadas_' + index).value = qtdTag;

    let tr = jQuery('<tr>', {'class': classe});

    let select = jQuery('<select>', {'class': 'inputtexto', 'id': 'campoTag_' + index + '_' + qtdTag, 'name': 'campoTag_' + index + '_' + qtdTag});

    select.append(jQuery('<option>', {'value': 'pedido_nfe'}).text('Pedido da NF'));
    select.append(jQuery('<option>', {'value': 'pedido_cte'}).text('Pedido do CT-e'));
    select.append(jQuery('<option>', {'value': 'carga_cte'}).text('Nº da carga do CT-e'));
    select.append(jQuery('<option>', {'value': 'obs_cte'}).text('Observação do CT-e'));

    select.val(tagAdicional['campo']);

    tr.append(jQuery('<td>').append(jQuery('<div>', {'align': 'center'}).append(jQuery('<img>', {'src': 'img/lixo.png', 'class': 'excluirTagAdicional imagemLink'}))));
    tr.append(jQuery('<td>').append(jQuery('<input>', {'type': 'text', 'class': 'inputtexto', 'id': 'nomeTag_' + index + '_' + qtdTag, 'name': 'nomeTag_' + index + '_' + qtdTag, 'value': tagAdicional['nome_tag']})));
    tr.append(jQuery('<td>').append(select).append(jQuery('<input>', {'type': 'hidden', 'id': 'id_' + index + '_' + qtdTag, 'name': 'idTag_' + index + '_' + qtdTag, 'value': tagAdicional['id']})));

    tbodyAdicionarTags.append(tr);
}

function aoClicarExcluirTag(btnExcluir) {
    let tr = btnExcluir.parent().parent().parent();
    
    let id = tr.find('input[name^="idTag_"]').val();

    if (confirm('Tem certeza que deseja excluir essa TAG?')) {
        if (confirm('Tem certeza?')) {
            if (id !== '0') {
                jQuery.post('jspcadcliente.jsp', {
                    'acao': 'excluirTagPersonalizada',
                    'id': id
                }, function aoExecutarAjax() {
                    tr.remove();

                    alert('Removido com sucesso!');
                });
            } else {
                tr.remove();

                alert('Removido com sucesso!');
            }
        }
    }
}