<link href="${homePath}/gwTrans/cadastros/css/estilo-input-form-gw.css" rel="stylesheet">
<link rel="stylesheet" href="${homePath}/gwTrans/consultas/css/auditoria.css?v=${random.nextInt()}">
<script src="${homePath}/assets/js/mapeamento-auditoria.js?v=${random.nextInt()}"></script>

<div class="detalhes-auditoria">
    <div class="detalhes-auditoria-topo">Auditoria de Exclusão<img src="${homePath}/assets/img/sair.png"
                                                                  onclick="fecharAuditoria()"></div>
    <div class="detalhes-auditoria-corpo">
        <table class="tb-auditoria-detalhes-usuario" cellspacing="0">
            <thead>
                <tr>
                    <th>Usuário</th>
                    <th>Data</th>
                    <th>Ação</th>
                    <th>Ip</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>asdfg</td>
                    <td>asdfg</td>
                    <td>asdfg</td>
                    <td>asdfg</td>
                </tr>
            </tbody>
        </table>
        <table class="tb-auditoria-detalhes">
            <thead>
            <tr>
                <th>Campos</th>
                <th>Antes</th>
                <th>Depois</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td>Teste</td>
                <td>123</td>
                <td>321</td>
            </tr>
            </tbody>
        </table>
    </div>
</div>
<div class="columnLeft column-left-auditoria" id="columnLeftAuditoria"
     style="z-index: 999;position: absolute;width:0px;">
    <div class="content">
        <h1 class="title-auditoria">Auditoria</h1>
        <div class="container-auditoria">
            <table class="tb-auditoria" cellspacing="0">
                <thead>
                <tr>
                    <th>Usuário</th>
                    <th>Data</th>
                    <th>Ação</th>
                    <th>Ip</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                </tbody>
                <tfoot>
                <tr>
                    <td colspan="4">&nbsp;</td>
                </tr>
                </tfoot>
            </table>
        </div>
        <div class="container-bt-auditoria">
            <div style="width: 8vw;margin-top:20px;margin-left: 1vw;margin-right: 2vw;float: left;">
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="dataDeAuditoria" type="text"
                               value="${dataAtual}" data-input-data-auditoria>
                    </span>
            </div>
            <label class="lb-ate" style="margin-right: unset;">até</label>
            <div style="width: 8vw;margin-top:20px;margin-left:1vw;float: left;">
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="dataAteAuditoria" type="text"
                               value="${dataAtual}" data-input-data-auditoria>
                    </span>
            </div>
            <button data-label="Pesquisar" class="bt-pesquisar" name="btn-auditoria" data-exclusao="true"
                    data-rotina-auditoria="filial"
                    style="margin-top: 15px;margin-left: calc(50% - 62px);">Pesquisar
            </button>
        </div>
    </div>
</div>