<%-- 
    Document   : cadastro-ftp(icescrum history 29)
    Created on : 27/04/2018, 12:01:19
    Author     : manasses
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html>
<head>
    <meta charset="ISO-8859-1">
    <link defer rel="stylesheet" href="${homePath}/assets/css/tema-cor-${tema}.css?v=${random.nextInt()}">
    <script src="${homePath}/gwTrans/cadastros/js/cadastro.js?v=${random.nextInt()}" type="text/javascript"></script>
    <script src="${homePath}/assets/js/ElementsGW.js?v=${random.nextInt()}" type="text/javascript"></script>
    <link href="${homePath}/assets/css/select-multiplo-gw.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <link href="${homePath}/assets/css/select-multiplo-grupo-gw.css" rel="stylesheet" type="text/css">
    <link href="${homePath}/gwTrans/cadastros/css/cadastro-ftp.css?v=${random.nextInt()}" rel="stylesheet" type="text/css">
    <script defer src="${homePath}/script/validarSessao.js?v=${random.nextInt()}" type="text/javascript"></script>
     <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css"   rel="stylesheet">
</head>
<body>
    <div class="container-form">
        <div class="col-md-12 celula-zebra">
            <div class="container-campos">
                <div class="col-md-4 descricao-ftp">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Descrição</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input type="hidden" id="acao" name="acao" value="cadastrar" data-serialize-campo="acao">
                        <input type="hidden" id="idConfTransf" name="idConfTransf" value="0" data-serialize-campo="idConfTransf">
                        <input class="input-form-gw input-width-100 ativa-helper" id="descricao" name="descricao"
                               required="required" type="text" maxlength="50"
                               placeholder="Descrição do FTP" data-validar="true" data-type="text"
                               data-erro-validacao="O campo Descrição é de preenchimento obrigatório!" data-serialize-campo="descricao">
                    </span>
                </div>
                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Tipo de Protocolo</div>
                    </div>
                    <select name="tipoProtocolo" id="tipoProtocolo" class="ativa-helper" data-serialize-campo="tipoProtocolo">
                        <option value="ftp" selected>FTP</option>
                        <option value="sftp">SFTP</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Tipo de Criptografia</div>
                    </div>
                    <select name="tipoCriptografia" id="tipoCriptografia" class="ativa-helper2" 
                            data-serialize-campo="tipoCriptografia">
                        <option value="1">Use FTP explícito sobre TLS se disponível</option>
                        <option value="2">Requer FTP sobre TLS explícito</option>
                        <option value="3">Requer FTP sobre TLS implícito</option>
                        <option value="4" selected>Usar somente FTP simples (inseguro)</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Host</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="host" name="host"
                               required="required" type="text" maxlength="50"
                               placeholder="Host FTP" data-validar="true" data-type="text"
                               data-erro-validacao="Endereço FTP que deverá ser realizado a conexão."
                               data-serialize-campo="host">
                    </span>
                </div>  
                <div class="col-md-1">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Porta</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="porta" name="porta"
                               required="required" type="text" min="1" maxlength="50"
                               placeholder="Porta FTP" data-validar="true" data-type="text"
                               data-erro-validacao="Porta de conexão com o host." 
                               data-serialize-campo="porta">
                    </span>
                </div>
            </div>
        </div>
        <div class="col-md-12">
            <div class="container-campos">
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Login</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" autocomplete="off" id="login" name="login"
                               required="required" type="text" maxlength="50"
                               placeholder="Login FTP" data-validar="true" data-type="text"
                               data-erro-validacao="Login para conexão com o FTP." 
                               data-serialize-campo="login">
                    </span>
                </div>
                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Senha</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="senha" name="senha"
                               required="required" type="password" maxlength="50" autocomplete="new-password"
                               placeholder="Senha FTP" data-validar="true" data-type="text"
                               data-erro-validacao="Senha para conexão com o FTP." 
                               data-serialize-campo="senha">
                    </span>
                </div>
                <div class="col-md-3">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Caminho Remoto</div>
                    </div>
                    <span class="container-input-form-gw input-width-100">
                        <input class="input-form-gw input-width-100 ativa-helper" id="caminhoRemoto" name="caminhoRemoto"
                               required="required" type="text" maxlength="50"
                               placeholder="Caminho Remoto" data-validar="true" data-type="text"
                               data-erro-validacao="Deve ser informado a pasta de destino que o sistema irá acessar dentro do host informado." 
                               data-serialize-campo="caminhoRemoto">
                    </span>
                </div>
                <div class="col-md-2">
                    <div class="identificacao-campo">
                        <div class="label-campo-identificacao">Chave de segurança</div>
                    </div>
                    <div class="container-input-file-layout">
                        <input type="file" id="chave_seguranca" class="input-file-layout form_oferta" >
                        <label for="chave_seguranca" id='' class="btn btn-tertiary js-labelFile">
                            <i class="icon fa fa-check"></i>
                            <span class="js-fileName">Importar Chave</span>
                        </label>
                        <input type="hidden" name="chave_seguranca" id="chave_segurancaHidden" value=""
                               data-serialize-campo="chave_seguranca">
                        <input type="hidden" name="nome_chave_seguranca" id="nome_chave_seguranca" value=""
                               data-serialize-campo="nome_chave_seguranca">
                        <input type="hidden" name="is_excluir_chave_seguranca" id="is_excluir_chave_seguranca" value="false"
                               data-serialize-campo="is_excluir_chave_seguranca">
                    </div>
                    <a href="#" id="baixar_chave_seguranca"><i class="fa fa-download"></i></a>
                    <a href="#" id="excluir_chave_seguranca" class="btnDelete"></a>
                </div>
                <div class="col-md-2">
                    <button data-label="" class="bt-testar ativa-helper" id="botTestar" name="botTestar" style="width: 70%">Testar Conexão</button>
                </div>
            </div>
        </div>
        <div class="col-md-12">
            <div class="identificacao-campo">
                <div class="label-campo-identificacao">Observação</div>
            </div>
            <div class="container-dom ativa-helper2" id="observacao">
                <div contenteditable="true" class="obs"></div>
            </div>
        </div>
        <input type="hidden" name="observacao" data-serialize-campo="observacao">
    </div>
    <script src="${homePath}/gwTrans/cadastros/js/cadastro-ftp.js?v=${random.nextInt()}"
    type="text/javascript"></script>
</body>