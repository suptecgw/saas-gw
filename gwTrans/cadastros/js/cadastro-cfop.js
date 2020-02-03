//Cadastro-cfop
//Rodolfo Gomes

$(document).ready(function () {
    // funções e etc aqui
    
        
    //para o localiza mostrar apenas receita 'isReceita':'true'
    // para o lacalizar mostrar apenas despesa'isDespesa': 'true'
    // para mostrar os recceitas e despesas 'isReceita':'false' e 'isDespesa': 'false'
    var parametro = {
            'isReceita':'true',
            'isDespesa': 'false'
    }
    sessionStorage.setItem('parametros', JSON.stringify(parametro));
    console.log("Parametros na CFOP JSP: "+sessionStorage.getItem('parametros'));
     

    $('#planoCusto').inputMultiploGw({
        readOnly: 'true',
        width: '97%'
    });
    
    jQuery("#planoCusto").parent().hover(
        function () {
            var elemento = $($(this).context).find('input[type="hidden"]:first').find('input[type=hidden]');

            jQuery(".campo-helper h2").html(elemento[1].value);
            jQuery(".descri-helper h3").html(elemento[0].value);
        },
        function () {
            jQuery('.campo-helper h2').html('Ajuda');
            jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
        }
    );

    if (qs['modulo'] === 'editar') {
        $('#id').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();

        $.ajax({
            url: 'CfopControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'carregar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                var obj = JSON.parse(jqXHR.responseText);
                $('#cfop').val(obj['cfop']);
                $('#descricao').val(obj['descricao']);

                // plano custo
                if (obj['planoCusto'] && (obj['planoCusto']['idconta'] != '0')) {
                    // primeiro parâmetro é o input, segundo é o que mostrar no input e terceiro é o id
                    addValorAlphaInput('planoCusto', String(obj['planoCusto']['conta']), String(obj['planoCusto']['idconta']));
                }

                criadoAlteradoAuditoria(obj['criadoPor']['nome'], formatarLocalDate(obj['criadoEm']), obj['atualizadoPor']['nome'], formatarLocalDate(obj['atualizadoEm']));

                setTimeout(function () {
                    $('.bloqueio-tela').hide();
                    $('.gif-bloq-tela').hide();
                }, 1000);
            }
        });
    }

});


function toLocalizar(input) {
    if (input == 'localizarPlanoCusto') {
        controlador.acao('abrirLocalizar', 'localizarPlanoCusto', new filtro('localizarPlanoCusto'));
    } else {
        chamarAlert('O localizar não foi configurado! ' + input);
    }
}

   //removendo parametros do session
        window.onbeforeunload = function(e) {
        sessionStorage.removeItem('parametros');
    };