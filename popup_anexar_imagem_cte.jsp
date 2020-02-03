<%-- 
    Document   : anexar_imagem_cte_pop
    Created on : 15/11/2015, 18:06:55
    Author     : paulo
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<script language="JavaScript" type="text/javascript">
    
    function carregar(){
        var dataAtual = '${param.dataAtual}';
        var horaAtual = '${param.horaAtual}';        
        var index = '${param.index}';        
        var pai = window.opener;        
        pai.$("isChaveAcesso").value = '${param.isChaveAcesso}';
        var numeroNfe = "";
        <c:forEach var="imagem" items="${anexarImagem.listaCte}">
            var imagemCte = new pai.ImagemCte();
            if(index == '0'){

                imagemCte.msnErro = '${imagem.mensagemRetornoAnexarImagem}';

                imagemCte.emissao = dataAtual;
                imagemCte.dataEntrega = dataAtual;
                imagemCte.horaEntrega = horaAtual;
                imagemCte.idRemetente = '${imagem.remetente.idcliente}';
                imagemCte.remetente = '${imagem.remetente.razaosocial}';
                imagemCte.idCidadeOrigem = '${imagem.remetente.cidade.idcidade}';
                imagemCte.cidadeOrigem = '${imagem.remetente.cidade.descricaoCidade}';
                imagemCte.ufOrigem = '${imagem.remetente.cidade.uf}';
                imagemCte.idDestinatario = '${imagem.destinatario.idcliente}';
                imagemCte.destinatario = '${imagem.destinatario.razaosocial}';
                imagemCte.idCidadeDestino = '${imagem.destinatario.cidade.idcidade}';
                imagemCte.cidadeDestino = '${imagem.destinatario.cidade.descricaoCidade}';
                imagemCte.ufDestino = '${imagem.destinatario.cidade.uf}';
                imagemCte.idConsignatario = '${imagem.cliente.idcliente}';
                imagemCte.consignatario = '${imagem.cliente.razaosocial}';
                imagemCte.idOcorrencia = '${imagem.ocorrencia.id}';
                imagemCte.codigoOcorrencia = '${imagem.ocorrencia.codigo}';
                imagemCte.descricaoOcorrencia = '${imagem.ocorrencia.descricao}';
                imagemCte.descricaoImagem = '${anexarImagem.descricaoImagem}';
                imagemCte.numeroCte = '${imagem.numero}';
                imagemCte.chaveAcessoCte = '${imagem.chaveAcessoCte}';
                imagemCte.nomeArquivo = '${imagem.nomeArquivoImagem}';
                imagemCte.baixaEm = '${imagem.baixaEm}';
                imagemCte.idCte = '${imagem.id}';
                
                <c:forEach var="nota" items="${imagem.notas}">
                    imagemCte.numeroNFs += '${nota.numero}'+ ",";
                </c:forEach>
                
                imagemCte.filial = '${imagem.filial.razaosocial}';
                    
                pai.addImagemCte(imagemCte);
                
            }else{
                
                pai.$("inpNumeroCte_"+index).value = '${imagem.numero}';
                pai.$("inpFilial_"+index).value = '${imagem.filial.razaosocial}';
                pai.$("inpEmissao_"+index).value = dataAtual;
                pai.$("inpChaveAcessoCte_"+index).value = '${imagem.chaveAcessoCte}';
//                pai.$("inpNumeroNfs_"+index).value = '$ {imagem.nota.chaveNFe}';
                pai.$("inpRemetente_"+index).value = '${imagem.remetente.razaosocial}';
                pai.$("inpHidIdRemetente_"+index).value = '${imagem.remetente.idcliente}';
                pai.$("inpHidIdOrigem_"+index).value = '${imagem.remetente.cidade.idcidade}';
                pai.$("inpOrigem_"+index).value = '${imagem.remetente.cidade.descricaoCidade}';
                pai.$("inpUfOrigem_"+index).value = '${imagem.remetente.cidade.uf}';
                pai.$("inpDestinatario_"+index).value = '${imagem.destinatario.razaosocial}';
                pai.$("inpHidIdDestinatario_"+index).value = '${imagem.destinatario.idcliente}';
                pai.$("inpHidIdDestino_"+index).value = '${imagem.destinatario.cidade.idcidade}';
                pai.$("inpDestino_"+index).value = '${imagem.destinatario.cidade.descricaoCidade}';
                pai.$("inpUfDestino_"+index).value = '${imagem.destinatario.cidade.uf}';
                pai.$("inpConsignatario_"+index).value = '${imagem.cliente.razaosocial}';
                pai.$("inpHidIdConsignatario_"+index).value = '${imagem.cliente.idcliente}';
                pai.$("txtADescricaoImagem_"+index).value = '${anexarImagem.descricaoImagem}';
                pai.$("inpIdCte_"+index).value = '${imagem.id}';
                
                <c:forEach var="nota" items="${imagem.notas}">
                    numeroNfe += '${nota.numero}'+ ",";
                </c:forEach>
                    
                    
                pai.$("inpNumeroNfs_"+index).value = numeroNfe;
            }
            
        </c:forEach>
        
        window.close();
    }
    
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <title>Webtrans - Anexar Imagem CT-e</title>
    </head>
    <body onload="carregar();"></body>
</html>
    
