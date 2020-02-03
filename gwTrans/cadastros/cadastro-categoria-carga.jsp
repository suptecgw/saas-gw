<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        
        <script src="${homePath}/script/jQuery/jquery.js" type="text/javascript"></script>
        <link href="${homePath}/gwTrans/cadastros/css/cadastro-categoria-carga.css?v=${random.nextInt()}" rel="stylesheet" type="text/css"/>
        <link href="${homePath}/gwTrans/cadastros/css/bootstrap-custom-col.css" rel="stylesheet" type="text/css"/>
        <script defer>
            var codigo_tela = 72;
            var homePath = '${homePath}';
            </script>
        
    </head>
    <body>
        <section class="section-container">
            <div class="container-topo">
                <div class="col-sm-12 topo bg_color_azul" >Dados Principais</div>
            </div>
            <div class="container-1">
                    <div class="label-descricao">
                        <label class="descricao">Descrição:</label>
                    </div>
                    <div class="input-descricao">
                        <input class="text-descricao" maxlength="50" id="inputDescricao">
                        <h1 id="idInvisivel" style="display: none"></h1>
                    </div>
            </div>
        </section>
        <section class="section-botoes">
            <button id="cadastroCatcarga">Salvar</button>
        </section>
        <script src="${homePath}/gwTrans/cadastros/js/cadastro-categoria-carga.js?v=${random.nextInt()}"></script>
        <script>
            var acao = '${param.acao}';
            if('${param.acao}' == '2'){
                jQuery('#inputDescricao').val('${categoriaCarga.descricao}');
                jQuery('#idInvisivel').val('${categoriaCarga.id}');
                jQuery('#cadastroCatcarga').click(editarCategoriaCarga);
            }else{
                jQuery('#cadastroCatcarga').click(cadastrarCategoriaCarga);
            }
        </script>
    </body>
</html>
