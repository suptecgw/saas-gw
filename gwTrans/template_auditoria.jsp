<%-- 
    Document   : template_auditoria
    Created on : 22/10/2015, 15:47:51
    Author     : marcos
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>


<tbody id="tbAuditoriaCabecalho">
    
    <tr class="celula">
        <td colspan="5"  align="left">
            <label>Data da Ação:</label>&ApplyFunction;
            <input type="text" onblur="alertInvalidDate(this, true)" class="fieldDate" id="dataDeAuditoria" maxlength="10" size="10" value="" />
            <label> Até  </label>
            <input type="text" onblur="alertInvalidDate(this, true)" class="fieldDate" id="dataAteAuditoria" maxlength="10" size="10" value="" />
        </td>
        <td colspan="">
            <input type="button" class="inputbotao" id="btPesquisarAuditoria" value=" Pesquisar " onclick="javascript:pesquisarAuditoria();" >
        </td>
    </tr>
    <tr class="celula">
        <td width="3%"></td>
        <td width="17%">Usuário</td>
        <td width="15%">Data</td>
        <td width="15%">Ação</td>
        <td width="10%">IP</td>
        <td width="50%"></td>
    </tr>
</tbody>
<tbody id="tbAuditoriaConteudo">
</tbody>