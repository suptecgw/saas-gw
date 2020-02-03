var abaAjudaAtiva = false;
const velocidade = 250;
const labelAbaAjudaAberta = 'Ocultar Ajuda';
const labelAbaAjudaFechada = 'Exibir Ajuda';
const tamanhaAbaAjudaAberta = '25%';
const tamanhoAbaFechada = '1%';
const caminhoIconAbaAjudaAberta = homePath + '/gwTrans/cadastros/img/icon-seta-ajuda2.png';
const caminhoIconAbaAjudaFechada = homePath + '/gwTrans/cadastros/img/icon-seta-ajuda.png';
const arrElements = ['.section-container', '.section-botoes'];
//dados auditoria
const labelAbaAuditoriaAberta = 'Ocultar Auditoria';
const labelAbaAuditoriaFechada = 'Exibir Auditoria';
const tamanhaAbaAuditoriaAberta = '40%';
const caminhoIconAbaAuditoriaAberta = homePath + '/gwTrans/cadastros/img/icon-seta-auditoria-down.png';
const caminhoIconAbaAuditoriaFechada = homePath + '/gwTrans/cadastros/img/icon-seta-auditoria.png';
var abaAuditoriaAtiva = false;

$('.btn-ajuda').click(function () {
    gerenciarAba('.coluna-ajuda', arrElements, 'ajuda')
});
$('.btn-auditoria').click(function () {
    gerenciarAba('.coluna-auditoria', arrElements, 'auditoria')
});

$('.bt-voltar').click(function(){
    location.replace("ConsultaControlador?codTela=72");
});

//function voltar(){
//        location.replace("ConsultaControlador?codTela=72");
//    }

function abrirAba(coluna, arrEl, aba) {
    let abaAtiva;
    if (!$(coluna).is(':visible')) {
        $(coluna).show();
    }
    $('.container-botoes').animate({
        'left': (aba == 'ajuda' ? tamanhaAbaAjudaAberta : aba == 'auditoria' ? tamanhaAbaAuditoriaAberta : '')
    }, velocidade);
    $(coluna).animate({
        'width': (aba == 'ajuda' ? tamanhaAbaAjudaAberta : aba == 'auditoria' ? tamanhaAbaAuditoriaAberta : '')
    }, velocidade);
    abrirFecharArrElements(arrEl, '40%', '18%');
    
    switch (aba) {
        case 'ajuda':
            abaAjudaAtiva = true;
            abaAtiva = true;
            break;
        case 'auditoria':
            abaAuditoriaAtiva = true;
            abaAtiva = true;
            break;
    }
    alterarIconeLabelAbaAjuda(abaAtiva, aba);
}

function fecharAba(coluna, arrEl, aba) {
    let abaAtiva;
    $('.container-botoes').animate({
        'left': tamanhoAbaFechada
    }, velocidade);
    $(coluna).animate({
        'width': tamanhoAbaFechada
    }, velocidade);
    abrirFecharArrElements(arrEl, '60%', '20%');
    
    switch (aba) {
        case 'ajuda':
            abaAjudaAtiva = false;
            abaAtiva = false;
            break;
        case 'auditoria':
            abaAuditoriaAtiva = false;
            abaAtiva = false;
            break;
    }
    alterarIconeLabelAbaAjuda(abaAtiva, aba);
}

function gerenciarAba(coluna, arrEl, aba) {
    
    if ($(coluna).is(':visible') && $(coluna).width() > 70) {
        fecharAba(coluna, arrEl, aba);
    } else {
        switch (aba) {
            case 'ajuda':
                if ($('.coluna-auditoria').is(':visible')) {
                    $('.coluna-auditoria').hide();
                }
                break;
            case 'auditoria':
                if ($('.coluna-ajuda').is(':visible')) {
                    $('.coluna-ajuda').hide();
                }
                break;
        }
        abrirAba(coluna, arrEl, aba);
    }
}

function alterarIconeLabelAbaAjuda(isAberto, aba) {
    console.log(homePath);
//    let e = $('.btn-ajuda');
    let e = null,caminhoAbaAberta = null,caminhoAbaFechada = null,bg = null, lb = null;
    
    switch (aba) {
        case 'ajuda':
            e = $('.btn-ajuda');
            bg = '#375471';
            caminhoAbaAberta = caminhoIconAbaAjudaAberta;
            caminhoAbaFechada = caminhoIconAbaAjudaFechada;
            if (isAberto) {
                lb = labelAbaAjudaAberta;
            }else{
                lb = labelAbaAjudaFechada;
            }
            break;
        case 'auditoria':
            bg = '#5f81a5';
            e = $('.btn-auditoria');
            caminhoAbaAberta = caminhoIconAbaAuditoriaAberta;
            caminhoAbaFechada = caminhoIconAbaAuditoriaFechada;
            console.log(isAberto);
            if (isAberto) {
                lb = labelAbaAuditoriaAberta;
            }else{
                lb = labelAbaAuditoriaFechada;
            }
            break;
    }
    console.log(e);
    if (isAberto) {
        e.css('background', bg +' url(' + caminhoAbaAberta + ') no-repeat');
        e.css('background-position-x', '7px');
        e.css('background-position-y', '8px');
    } else {
        e.css('background', bg +' url(' + caminhoAbaFechada + ') no-repeat');
        e.css('background-position-x', '7px');
        e.css('background-position-y', '8px');
    }
    $(e).text(lb);
}

function abrirFecharArrElements(arr, tamanho1, tamanho2) {
    arr.forEach(function (e) {
        $(e).animate({
            'width': tamanho1
        }, velocidade);
        $(e).css('margin-left', tamanho2);
    });
}

var chaveCheckboxSalvarSessao = 'chk-ao-salvar';
var clicouBotaoSalvar = false;
var itemExcluir = null;

$(document).ready(function () {
    $("#formCadastro").submit(function (event) {
        event.preventDefault();
    });

    $(document).gwTelaCadastro();

    $('.aba').click(function () {
        $('.aba-selecionada').removeClass('aba-selecionada');
        $(this).addClass('aba-selecionada');
    });

    $('.limpar-pagina').click(function () {
        if (confirm('Deseja limpar todos os dados da tela ? ')) {
            $('input').val('');
        }
    });

//    $('.container-dom').load('./html-dom/tabela-tde.html');
//    $.post('./html-dom/tabela-tde.html', function (html) {
//        //Essa é a função success
//        //O parâmetro é o retorno da requisição 
//        $('#idSuaDiv').html(html);
//    });

    var btnSalvar = $('button[class="bt-salvar"]');
    var checkboxSalvar = $('#chk-ao-salvar');
    var botaoVoltar = $('.bt-voltar');
    var checkboxSalvarSessao = sessionStorage.getItem(chaveCheckboxSalvarSessao);

    if (checkboxSalvarSessao !== undefined && checkboxSalvarSessao === "true") {
        checkboxSalvar.attr('checked', 'checked');
    }

    checkboxSalvar.on('click', function () {
        sessionStorage.setItem(chaveCheckboxSalvarSessao, $(this).is(':checked').toString());
    });

    btnSalvar.on('click', function () {
        clicouBotaoSalvar = true;
    });

    botaoVoltar.on('click', function () {
        limparSessao()
    });

    $(window).on("beforeunload", function () {
        limparSessao();
    });

});

// parametro campoId é o id do input, quando excluir deve colcoar o id no campo de excluidos.
function excluirDom(element, campoId) {
    itemExcluir = element;
    if (campoId !== undefined) {
        chamarConfirm('Deseja excluir? ', 'excluirItemDom("'+campoId+'")', null);
    }else{
        chamarConfirm('Deseja excluir? ', 'excluirItemDom("")', null);
    }
}

function excluirItemDom(campoId) {
    $(itemExcluir).parent().parent().parent().animate({
        'margin-left': '1200px'
    }, 500, function () {
        if (campoId !== "" && campoId !== 'undefined') {
            if (jQuery("#excluidosDOM").val() !== '') {
                jQuery("#excluidosDOM").val(jQuery("#excluidosDOM").val() + ',');
            }
            jQuery("#excluidosDOM").val(jQuery("#excluidosDOM").val() + jQuery("#" + campoId).val());
            jQuery("#excluidosDOM").trigger('change');
        }
        $(this).remove();
    });
}

function limparSessao() {
    if (!clicouBotaoSalvar) {
        sessionStorage.removeItem(chaveCheckboxSalvarSessao);
    }
}

class filtro {
    constructor(tipoLocalizar) {
        this.tipoLocalizar = tipoLocalizar;
    }

    getTipo() {
        return this.tipoLocalizar;
    }

    setTipo(tipoLocalizar) {
        this.tipoLocalizar = tipoLocalizar;
    }

}
