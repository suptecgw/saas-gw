var itemExcluir = null;
var qtdDom = 0;

jQuery(document).ready(function () {

    $('.conteudo-aba').hide();
    $('#conteudo-aba1').show(250);

    jQuery("#uf, #idpais").each(function () {
        $(this).selectmenu().selectmenu("option", "position", {
            my: "top+15",
            at: "top center"
        }).selectmenu("menuWidget").addClass("selects-ui");
    });

    $('.aba').click(function () {
        $('.conteudo-aba').hide();
        $('.aba-selecionada').removeClass('aba-selecionada');
        $(this).addClass('aba-selecionada');
        if ($(this).hasClass('aba01')) {
            $('#conteudo-aba1').show(250);
        } else if ($(this).hasClass('aba02')) {
            $('#conteudo-aba2').show(250);
        } else if ($(this).hasClass('aba03')) {
            $('#conteudo-aba3').show(250);
        } else if ($(this).hasClass('aba04')) {
            $('#conteudo-aba4').show(250);
        }
    });

    $('#servico-nfse-padrao').inputMultiploGw({
        readOnly: 'true',
        width: '98%',
        isSimples: 'true',
        notX: 'true'
    });

    if (qs['modulo'] === 'editar') {
        $('#idCidade').val(qs["id"]);
        $('#acao').val('editar');
        $('.bloqueio-tela').show();
        $('.gif-bloq-tela').show();
        $('.aba04').show();

        $.ajax({
            url: 'CidadeControlador',
            async: false,
            dataType: 'text',
            data: {
                'acao': 'iniciarEditar',
                'id': qs['id']
            },
            complete: function (jqXHR, textStatus) {
                try {
                    var obj = JSON.parse(jqXHR.responseText);
                    console.log(obj);

                    $('#idCidade').val(obj.id);
                    $('#cidade').val(obj['cidade']);
                    $('#uf').val(obj['uf']);
                    $('#idpais').val(obj.pais.id);
                    $('#cod-municipio').val(obj['cod_municipio']);
                    $('#cod-srf').val(obj['cod_srf']);
                    $('#cod-ibge').val(obj['cod_ibge']);
                    $('#cod-mastermaq').val(obj['cod_mastermaq']);
                    $('#cod-siafi').val(obj['cod_siafi']);
                    $('#cod-dipam').val(obj['cod_dipam']);
                    $('#qtd-horas').val(obj['qtdHorasBaixarComprovanteEntrega']);
                    $('#aeroporto').val(obj.aeroporto.nome);

                    if (obj['listaCidadeEDI'] !== undefined) {
                        $.each(obj['listaCidadeEDI'], function (index) {
                            addDom(this);
                        });
                    }

                    if (obj['areas'] !== undefined) {
                        $.each(obj['areas'], function (index) {
                            addArea(this.sigla, this.descricao, this.cliente.razaosocial, index);
                        });
                    }

                    // Selectmenu
                    $('select').selectmenu('refresh');

                    criadoAlteradoAuditoria(obj['criadoPor']['nome'], formatarLocalDate(obj['criadoEm']), obj['atualizadoPor']['nome'], formatarLocalDate(obj['atualizadoEm']));

                    setTimeout(function () {
                        $('.bloqueio-tela').hide();
                        $('.gif-bloq-tela').hide();
                    }, 1000);

                    addValorAlphaInput('servico-nfse-padrao', obj['servico']['descricao'], String(obj['servico']['id']), true);
                } catch (exception) {
                    console.error(exception);
                    if (jqXHR.responseText.includes('ERROR:') || jqXHR.responseText.includes('A nome da coluna')) {
                        chamarAlert(jqXHR.responseText, function () {
                            window.location = 'ConsultaControlador?codTela=64';
                        });
                    } else {
                        chamarAlert(exception, function () {
                            window.location = 'ConsultaControlador?codTela=64';
                        });
                    }
                    setTimeout(function () {
                        $('.bloqueio-tela').hide();
                        $('.gif-bloq-tela').hide();
                    }, 1000);
                }
            }
        });
    }

    if (qs['modulo'] === 'cadastro') {
        $('#idCidade').val(0);
        $('#conteudo-aba4').hide();
        $('.aba04').hide();
    }

    jQuery("span[class*='-button'],.ativa-helper2").hover(
            function () {
                jQuery(".campo-helper h2").text($(this).parent().parent().find('.identificacao-campo').text());
                jQuery(".descri-helper h3").html($(this).attr("data-erro-validacao"));
            },
            function () {
                jQuery('.campo-helper h2').html('Ajuda');
                jQuery(".descri-helper h3").html('Passe o mouse sobre o campo que deseja ajuda.');
            }
    );

    jQuery('.header-dom').click(function () {
        var objCidadeEDI = {
            id: 0,
            descricao: ''
        };
        addDom(objCidadeEDI);
    });
});

function getCodigoIBGE() {
    window.open('https://cidades.ibge.gov.br/' + $('#idpais').find(":selected").text().toLowerCase() + '/' + $('#uf').val().toLowerCase() + '/' + $('#cidade').val().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, "").replace(/ /g, '-').replace(/ç/g, 'c') + '/panorama', "_blank", "scrollbars=1,resizable=1,height=768,width=1300");
}

function addDom(cidadeEDI) {
    var container = $('#container-dom-cidade .body');
    var div = $('<div class="container-dom-cidade-edi">');
    $(container).append(div);
    var dados = homePath + "/gwTrans/cadastros/html-dom/dom-cidade-edi2.jsp?qtdDom=" + (++qtdDom) + "&idCidadeEDI=" + cidadeEDI.id + "&valorCampo=" + encodeURI(cidadeEDI.descricao);
    $(div).load(dados);
}

function addArea(sigla, descricao, razasocial, index) {
    var container = $('#conteiner-areas .areas');
    var divSigla = $('<div class="col-md-2">').html(sigla);
    var divDescricao = $('<div class="col-md-5">').html(descricao);
    var divRazaoSocial = $('<div class="col-md-5">').html(razasocial);

    var div = $('<div class="col-md-12">');
    $(div).append(divSigla);
    $(div).append(divDescricao);
    $(div).append(divRazaoSocial);
    if(index && index != 0){
        $(container).append($('<hr>'));
    }
    $(container).append(div);
}

function excluirItemDom(campoId) {
    $(itemExcluir).parent().parent().parent().animate({
        'margin-left': '1200px'
    }, 500, function () {
        if (campoId !== "" && campoId !== 'undefined') {
            if (jQuery("#excluidosDOMCidadeEDI").val() !== '') {
                jQuery("#excluidosDOMCidadeEDI").val(jQuery("#excluidosDOMCidadeEDI").val() + ',');
            }
            jQuery("#excluidosDOMCidadeEDI").val(jQuery("#excluidosDOMCidadeEDI").val() + jQuery("#" + campoId).val());
        }
        $(this).remove();
    });
}