/* 
 * ----------------Autor MATEUS------------------------------
 * ----------------------------------------------------------
 ***************ELEMENTOS JA CRIADOS*************************
 *
 *jQuery('table').tabelaGwDraggable();
 *jQuery('input').inputMultiploGw();
 *jQuery('input').selectExcetoApenasGw();
 *jQuery('input').selectMultiploGrupoGw();
 */
//----------------  TABELA GW   -----------------------------
var podeOrdenar = true;
var idOrderImg = null;
var caminhoImgUp = null;
var caminhoImgDown = null;
var tdAlvoTopo = null;
var img_order = null;

var tdAntes = null;
var tdDepois = null;
var tabelaInicial = null;
var $inputHidden = null;

(function ($) {

    var param = {
        "aumentandoTD": false,
        "inicialX": null,
        "finalX": null,
        "iniciouAumentar": false,
        "movimento": null,
        "widthInicial": null,
        "widthInicialTabela": null,
        "alvo": null,
        "podeOrdenar": true
    };

    $.fn.tabelaGwDraggable = function (options) {
        tabelaInicial = jQuery(this);
        var idTabela = tabelaInicial.attr("id");

        var opcoesDefaults = {
            'redimensionavel': false,
            'draggable': false,
            'ordenacao': false,
            'notResizableClass': null,
            'notDraggableClass': null,
            'notOrderClass': null,
            'idImgOrder': null,
            'caminhoImagemUp': null,
            'caminhoImagemDown': null,
            'armazenarValoresWidth': false,
            'callBackResize': null,
            'callBackDraggable': null,
            'setaOrdemClass': null
        };

        var settings = $.extend({}, opcoesDefaults, options);

        idOrderImg = settings.idImgOrder;
        caminhoImgUp = settings.caminhoImagemUp;
        caminhoImgDown = settings.caminhoImagemDown;

        //Caso o draggable esteja true ele ativa na tabela.
        if (settings.draggable) {
            draggableGw(this, settings);
        }
        //Caso o redimensionavel esteja true ele chama a funcao pra ativar o mesmo.
        if (settings.redimensionavel) {
            aumentarDiminuirTabela(this, settings);
        }
        //Ordenação ( \/ /\ )            

        if (settings.ordenacao) {
            $("#" + idTabela).table_cresc_desc();
        }
    };

    /*
     * @author Mateus
     * @description Função responsavel por ordenar a tabela
     * @param {type} sortFns
     * @returns {ElementsGWL#26.$.fn.table_cresc_desc@call;each}
     */
    $.fn.table_cresc_desc = function (sortFns) {
        return this.each(function () {
            var $table = $(this);
            sortFns = sortFns || {};

            sortFns = $.extend({}, $.fn.table_cresc_desc.default_sort_fns, sortFns);

            var sort_map = function (arr, sort_function) {
                var map = [], index = 0, sorted = arr.slice(0).sort(sort_function), arr_length = arr.length;

                for (var i = 0; i < arr_length; i++) {
                    index = $.inArray(arr[i], sorted);

                    while ($.inArray(index, map) != -1) {
                        index++;
                    }
                    map.push(index);
                }

                return map;
            };

            var apply_sort_map = function (arr, map) {
                var clone = arr.slice(0),
                        newIndex = 0,
                        map_length = map.length;
                for (var i = 0; i < map_length; i++) {
                    newIndex = map[i];
                    clone[newIndex] = arr[i];
                }
                return clone;
            };

            // ==================================================== //
            // ==================================================== //
            $table.on("click.table_cresc_desc", "thead th", function (e) {
                var tdAlvo = e.target.nodeName == "TH" ? e.target : jQuery(e.target).parent('TH')[0];
                if (!tdAlvo) {
                    return;
                }

                if (jQuery(tdAlvo).hasClass('nao-ordenar')) {
                    return;
                }


                if (!podeOrdenar) {
                    return;
                }

                var trs = $table.children("tbody").children("tr");
                var $this = $(this);
                var th_index = 0;
                var dir = $.fn.table_cresc_desc.dir;

                $table.find("thead th").slice(0, $this.index()).each(function () {
                    var cols = $(this).attr("colspan") || 1;
                    th_index += parseInt(cols, 10);
                });

                var sort_dir = $this.data("sort-default") || dir.ASC;
                if ($this.data("sort-dir"))
                    sort_dir = $this.data("sort-dir") === dir.ASC ? dir.DESC : dir.ASC;

                // Verifica o tipo que foi escolhido
                var type = $this.data("sort") || null;

                // Previne para que o tipo nao seja null
                if (type === null) {
                    type = "string";
                }

                $table.trigger("beforetablesort", {column: th_index, direction: sort_dir});
                $table.css("display");

                setTimeout(function () {
                    var column = [];
                    var sortMethod = sortFns[type];

                    trs.each(function (index, tr) {
                        var $e = $(tr).children().eq(th_index);
                        var sort_val = $e.data("sort-value");
                        var order_by = typeof (sort_val) !== "undefined" ? sort_val : $e.text();
                        column.push(order_by);
                    });
                    var theMap;
                    if (sort_dir == dir.ASC)
                        theMap = sort_map(column, sortMethod);
                    else
                        theMap = sort_map(column, function (a, b) {
                            return -sortMethod(a, b);
                        });

                    $table.find("thead th").data("sort-dir", null).removeClass("sorting-desc sorting-asc");
                    $this.data("sort-dir", sort_dir).addClass("sorting-" + sort_dir);

                    var sortedTRs = $(apply_sort_map(trs, theMap));
                    //explicando: o código abaixo não vai ADICIONAR linhas pois as linhas já existem na table.
                    //    vi que se o elemento já tem o que está em APPEND, ele não é criado e sim atualizado.
                    //    dessa forma ele atualiza as TRs já reordenadas.
                    $table.children("tbody").append(sortedTRs);

                    $table.trigger("aftertablesort", {column: th_index, direction: sort_dir});
                    $table.css("display");
                }, 10);
            });
        });
    };

    $.fn.table_cresc_desc.dir = {ASC: "asc", DESC: "desc"};

    $.fn.table_cresc_desc.default_sort_fns = {
        "int": function (a, b) {
            return parseInt(a, 10) - parseInt(b, 10);
        },
        "float": function (a, b) {
            return parseFloat(a) - parseFloat(b);
        },
        "string": function (a, b) {
            /* Verificação via regex se a string é uma data, se for, trata para fazer verificação. */
            if (/(\d{1,2})\/(\d{1,2})\/(\d{4})/.test(a) && /(\d{1,2})\/(\d{1,2})\/(\d{4})/.test(b)) {

                var diab = b.split('/')[0];
                var mesb = b.split('/')[1];
                var anob = b.split('/')[2];
                var diaa = a.split('/')[0];
                var mesa = a.split('/')[1];
                var anoa = a.split('/')[2];

                var datea = new Date(anoa, mesa, diaa);
                var dateb = new Date(anob, mesb, diab);
                if (datea < dateb)
                    return -1;
                if (datea > dateb)
                    return +1;
                return 0;
                /* valida valores do tipo float ou double */
            } else if (/[\d.]+[\d,]+/.test(a) && /[\d.]+[\d,]+/.test(b)) {
                a = a.replace(/\./g, '').replace(/\,/g, '');
                b = b.replace(/\./g, '').replace(/\,/g, '');
                a = parseInt(a);
                b = parseInt(b);
                if (a < b)
                    return -1;
                if (a > b)
                    return +1;
                return 0;

            } else {
                if (a < b)
                    return -1;
                if (a > b)
                    return +1;
                return 0;
            }
        },
        "string-ins": function (a, b) {
            a = a.toLowerCase();
            b = b.toLowerCase();
            if (a < b)
                return -1;
            if (a > b)
                return +1;
            return 0;
        }
    };

    /*
     * @author Mateus
     * @description Funcao responsavel por alterar a posição das tds no soltar do click
     * @param {type} options
     * @returns {Boolean}
     */
    function draggableGw(tabela, settings) {
        var tdNotSortable = "";
        if (settings.notDraggableClass !== null && settings.notDraggableClass.split(" ") !== undefined) {
            for (var i = 0; i <= settings.notDraggableClass.split(" ").length; i++) {
                if (settings.notDraggableClass.split(" ")[i] !== undefined) {
                    tdNotSortable += "." + settings.notDraggableClass.split(" ")[i] + " ";
                }
            }
        }


        jQuery(tabela).on("mousedown mouseup", function (e) {

            jQuery(tabela).sortable({
                helper: "clone",
                tolerance: "pointer",
                items: "thead th:not(" + tdNotSortable + ")",
                cursor: "move",
//            placeholder: ".tabela-draggable",
                revert: 3,
                opacity: 1.0,
                start: function (event, ui) {
                    ui.item.startPos = ui.item.index();
                },
                placeholder: "td-sortable",
                axis: "x",
                stop: function (event, ui) {
                    var posicaoInicial = ui.item.startPos + 1;
                    var posicaoFinal = ui.item.context.cellIndex + 1;

                    var thtb = jQuery(tabela).children();

                    //Codigo responsavel por setar a ordem das colunas
                    var index = 0;
                    var ths = jQuery('.' + settings.setaOrdemClass);
                    while (ths[index] !== null && ths[index] !== undefined) {
                        jQuery(ths[index]).attr('ordem', index + 1);
                        index++;
                    }
                    //------------------------------------------------
                    var col1 = null;
                    var col2 = null;

                    if (posicaoInicial < posicaoFinal) {
                        for (var i = posicaoInicial; i < posicaoFinal; i++) {
                            col1 = thtb.find('> tr > td:nth-child(' + i + ')').add(thtb.find('> tr > th:nth-child(' + i + ')'));
                            col2 = thtb.find('> tr > td:nth-child(' + (i + 1) + ')').add(thtb.find('> tr > th:nth-child(' + (i + 1) + ')'));
                            for (var j = 0; j < col1.length; j++) {
                                if (j !== 0) {
                                    swapNodes(col1[j], col2[j]);
                                }
                            }
                        }
                    } else {
                        for (var i = posicaoInicial; i > posicaoFinal; i--) {
                            col1 = thtb.find('> tr > td:nth-child(' + i + ')').add(thtb.find('> tr > th:nth-child(' + i + ')'));
                            col2 = thtb.find('> tr > td:nth-child(' + (i - 1) + ')').add(thtb.find('> tr > th:nth-child(' + (i - 1) + ')'));
                            for (var j = 0; j < col1.length; j++) {
                                if (j !== 0) {
                                    swapNodes(col1[j], col2[j]);
                                }
                            }
                        }
                    }
                    //Chama o callback
                    settings.callBackDraggable(ui);
                }

            }).disableSelection();

            if (param.aumentandoTD) {
                sortableDisable(tabela);
            } else {
                sortableEnable(tabela);
            }

            ativarDesativaSelect(tabela, true);
            if (e.type == "mouseup") {
                ativarDesativaSelect(tabela, false);
            }

        });

    }

    /*
     * @author Mateus
     * @description Funcao responsavel por seleciona a td na borda e aumentar o seu tamanho.
     * @param {type} options
     * @returns {Boolean}
     */
    function aumentarDiminuirTabela(tabela, settings) {

        jQuery("html body").on("mousemove mousedown mouseup", function (e) {

            var tdAlvo = e.target.nodeName == "TH" ? e.target : jQuery(e.target).parents('TH')[0];

            if (settings.idImgOrder !== null && e.target.nodeName == "IMG" && jQuery(e.target).context.id == settings.idImgOrder) {
                var img = jQuery(e.target);
                jQuery(img).css('cursor', 'pointer');
            }
            if (e.type === "mouseup" && jQuery(tabela).css("cursor") === "col-resize") {
                jQuery(tabela).css("cursor", "default");
                param.iniciouAumentar = false;
            }

            var classBlock = false;
            var classResizeBlock = false;

            //Pode parecer que não + se retirar essas condições em alguns navegadores o codigo ira da erro de javascript.
            if (tdAlvo !== null && tdAlvo !== undefined && jQuery(tdAlvo).context !== null
                    && jQuery(tdAlvo).context !== undefined && jQuery(tdAlvo).context.attributes !== null
                    && jQuery(tdAlvo).context.attributes !== undefined && jQuery(tdAlvo).context.attributes.class !== null
                    && jQuery(tdAlvo).context.attributes.class !== undefined) {
                var className = jQuery(tdAlvo).context.attributes.class.value;
                if (className.split(" ") !== null && className.split(" ") !== undefined) {
                    for (var i = 0; i <= className.split(" ").length; i++) {
                        if (settings.notDraggableClass !== null && settings.notDraggableClass.split(" ") != undefined
                                && settings.notDraggableClass.split(" ").indexOf(className.split(" ")[i]) >= 0) {
                            classBlock = true;
                        }
                    }
                }
            }

            if (tdAlvo !== null && tdAlvo !== undefined && jQuery(tdAlvo).context !== null
                    && jQuery(tdAlvo).context !== undefined && jQuery(tdAlvo).context.attributes !== null
                    && jQuery(tdAlvo).context.attributes !== undefined && jQuery(tdAlvo).context.attributes.class !== null
                    && jQuery(tdAlvo).context.attributes.class !== undefined) {
                var classNameResize = jQuery(tdAlvo).context.attributes.class.value;
                if (classNameResize.split(" ") !== null && classNameResize.split(" ") !== undefined) {
                    for (var i = 0; i <= classNameResize.split(" ").length; i++) {
                        if (settings.notResizableClass !== null && settings.notResizableClass.split(" ") !== undefined
                                && settings.notResizableClass.split(" ").indexOf(classNameResize.split(" ")[i]) >= 0) {
                            classResizeBlock = true;
                        }
                    }
                }
            }
            if (tdAlvo !== null && tdAlvo !== undefined) {
                var offset = jQuery(tdAlvo).offset();
                var nLength = jQuery(tdAlvo).innerWidth();
                if (Math.abs(e.pageX - Math.round(offset.left + nLength)) <= 5 || param.iniciouAumentar) {
                    if (!classResizeBlock) {
                        jQuery(tabela).removeAttr('cursor');
                        jQuery(tabela).css({'cursor': 'col-resize'});
                        ativarDesativaSelect(tabela, true);
                        param.aumentandoTD = true;
                        param.podeOrdenar = false;
                        podeOrdenar = false;
                    }
//                    Nao permitir copiar texto durante o aumentar
                } else {
                    jQuery(tabela).removeAttr('cursor');
                    jQuery(tabela).css({'cursor': 'default'});
                    //Permitir copiar texto durante o aumentar
                    ativarDesativaSelect(tabela, false);
                    if (classBlock) {
                        param.aumentandoTD = true;
                    } else {
                        param.aumentandoTD = false;
                    }
                    param.podeOrdenar = true;
                    podeOrdenar = true;
                }

                if (param.iniciouAumentar) {
                    var alvo = param.alvo;
                    //Onde o mouse ta menos onde iniciou
                    var moveLength = e.pageX - param.inicialX;
                    //Incrementa o width do alvo
                    alvo.width(param.widthInicial + moveLength);

                    jQuery(tabela).width(param.widthInicialTabela + moveLength);
                }

                if (e.type === "mousedown" && jQuery(tdAlvo).css('cursor') === 'col-resize') {
                    param.inicialX = e.pageX;
                    param.alvo = jQuery(tdAlvo);
                    param.iniciouAumentar = true;
                    param.widthInicial = jQuery(param.alvo).width();
                    param.widthInicialTabela = jQuery(tabela).width();
                    var tdsTopo = jQuery(tabela).children('thead').find('th');
                    var i = 0;
                    while (tdsTopo[i] != null) {
                        var indexAlvo = jQuery(param.alvo).context.cellIndex;
                        var indexTd = jQuery(tdsTopo[i]).context.cellIndex;
                        if (indexAlvo !== indexTd) {
                            var w = jQuery(tdsTopo[i]).width();
                            jQuery(tdsTopo[i]).css("width", w);
                            jQuery(tdsTopo[i]).css("min-width", w);
//                            jQuery(tdsTopo[i]).css("max-width",w);
                        }
                        i++;
                    }
                    jQuery(param.alvo).css("min-width", "30px");
                }

                if (e.type === "mousemove" && jQuery(tdAlvo).css('cursor') === 'col-resize') {
//                    jQuery(param.alvo).css("min-width",e.pageX - param.inicialX+"px");
                }


                if (e.type == "mouseup") {
                    param.finalX = e.pageX;

                    param.iniciouAumentar = false;

                    var index = 0;
                    var ths = jQuery('#' + jQuery(tabela).attr('id') + ' thead tr th:not(' + settings.notResizableClass + ')');
                    if (param.alvo !== null && param.alvo !== undefined) {
                        jQuery(param.alvo.context).attr('largura', jQuery(param.alvo).width());
                    }
                    while (ths[index] !== null && ths[index] !== undefined) {
                        if (jQuery(ths[index]).attr('largura') === null || jQuery(ths[index]).attr('largura') === undefined || jQuery(ths[index]).attr('largura').trim() === "") {
                            jQuery(ths[index]).attr('largura', "");
                        }
                        index++;
                    }

                    if (settings.callBackResize && settings.callBackResize !== null) {
                        settings.callBackResize(param.alvo);
                    }
                }
            }
        });

    }

    function swapNodes(a, b) {
        var aparent = a.parentNode;
        var asibling = a.nextSibling === b ? a : a.nextSibling;
        b.parentNode.insertBefore(a, b);
        aparent.insertBefore(b, asibling);
    }

    //Ativar ou Desativar o select de textos da tabela
    function ativarDesativaSelect(element, ativa) {
        if (ativa) {
            jQuery(element).css({'-webkit-touch-callout': ''});
            jQuery(element).css({'-webkit-touch-callout': ''});
            jQuery(element).css({'-webkit-user-select': ''});
            jQuery(element).css({'-khtml-user-select': ''});
            jQuery(element).css({'-moz-user-select': ''});
            jQuery(element).css({'-ms-user-select': ''});
            jQuery(element).css({'--user-select': ''});
        } else {
            jQuery(element).css({'-webkit-touch-callout': 'none'});
            jQuery(element).css({'-webkit-touch-callout': 'none'});
            jQuery(element).css({'-webkit-user-select': 'none'});
            jQuery(element).css({'-khtml-user-select': 'none'});
            jQuery(element).css({'-moz-user-select': 'none'});
            jQuery(element).css({'-ms-user-select': 'none'});
            jQuery(element).css({'--user-select': 'none'});
        }

    }
    //Ativa a funcao sortable enquanto arrasta
    function sortableEnable(element) {
        jQuery(element).sortable();
        jQuery(element).sortable("option", "disabled", false);
        // ^^^ this is required otherwise re-enabling sortable will not work!
        jQuery(element).disableSelection();
        return false;
    }
    //Desativa a funcao sortable enquanto arrasta
    function sortableDisable(element) {
        jQuery(element).sortable("disable");
        return false;
    }
})(jQuery);

//----------------     INPUT MULTIPLO    -----------------------------
var input = null;
var valorInput = null;
//------------------------------------------------------------------
var qtdInput = 1;
(function ($) {
    $.fn.inputMultiploGw = function (options) {
        input = jQuery(this);
        valorInput = jQuery(this).val();
        var opcoesDefaults = {
            width: '200px',
            height: 'auto',
            overflow: 'auto',
            classes: null,
            atributos: null,
            readOnly: 'false',
            isSimples: false,
            is_old: false,
            callBack: null
        };
        var settings = $.extend({}, opcoesDefaults, options);
        var divAlpha = {
            class: 'alpha ' + (settings.classes ? settings.classes : '') + (settings.readOnly === true || settings.readOnly === 'true' ? ' alpha-readonly ':'') + (settings.is_old ? ' alpha-old ' : ''),
            style: 'height:' + settings.height + ';width:' + settings.width + ';overflow:' + settings.overflow + ';',
            id: 'divAlpha' + qtdInput,
            'data-notx': settings.notX
        };
        var ulBeta = {
            class: 'beta-ul'
        };
        var containerChaves = {
            class: 'container-chaves'
        };
        var containerInput = {
            class: 'container-input'
        };
        var deltaInput = {
            class: (settings.is_old ? 'delta-input-old':'delta-input'),
            type: 'text',
            style: 'color:#555555;font-size:14px;width:100%;',
            id: 'deltaInput' + qtdInput
        };
        var inputHidden = {
            type: 'hidden',
            id: jQuery(input[0]).attr('id'),
            name: jQuery(input[0]).attr('name')
        };

        var atributes = input.prop("attributes");

        if (atributes) {
            $.each(atributes, function () {
                if (this.name.includes('data')) {
                    var name = this.name;
                    var val = this.value;
                    jQuery(inputHidden).attr(name, val);
                }
            });
        }


        //Criando elementos
        var $divAlpha = jQuery('<div>', divAlpha);
        var $ulBeta = jQuery('<ul>', ulBeta);
        var $containerChaves = jQuery('<div>', containerChaves);
        var $containerInput = jQuery('<div>', containerInput);
        var $deltaInput = jQuery('<input>', deltaInput);
        $inputHidden = jQuery('<input>', inputHidden);

        $containerInput.html($deltaInput);
        $ulBeta.append($containerChaves);
        $ulBeta.append($containerInput);
        $divAlpha.append($ulBeta);

        $divAlpha.append($inputHidden);

        jQuery(input).replaceWith($divAlpha);

        var idDivAlpha = jQuery('#divAlpha' + qtdInput);
        var idDeltaInpt = jQuery('#deltaInput' + qtdInput);

        if (settings.readOnly === 'true') {
            jQuery(idDeltaInpt).attr('readOnly', 'true');
            jQuery(idDeltaInpt).css('width', '1px');
            jQuery(idDivAlpha).attr('readOnly', 'true');
        }

        jQuery(idDivAlpha).click(function () {
            jQuery(idDeltaInpt).focus();
        });



        jQuery(idDivAlpha).focusout(function () {
            if (jQuery(idDeltaInpt).val().trim() !== '') {
                    var inputHidden = jQuery(this).find('input[type=hidden]').attr('id');
                    addValorAlphaInput(inputHidden, jQuery(idDeltaInpt).val());
                    jQuery(idDeltaInpt).val('');
            } 
        });
        jQuery(idDeltaInpt).on("keyup", function (e) {
            if (jQuery(this).val().trim() === "" && e.which === 13) {
                console.log(settings.callBack);
                if (settings.callBack && settings.callBack !== null) {
                    settings.callBack(this);
                }
            }
        });
        jQuery(idDeltaInpt).on('keydown', function (e) {
            if ((e.which === 13 || e.which === 9) && jQuery(this).val().trim() === '') {
                // Pegar o atributo ID do botão de pesquisar
                var pesquisarId = jQuery(this).parent().parent().parent().find('input[type=hidden]').attr('data-pesquisar-id');

                if (pesquisarId) {
                    // Dar um pesquisar.
                    jQuery(pesquisarId).click();
                }
            }
        });

        jQuery(idDeltaInpt).on("change paste keyup keydown", function (e) {
            if (jQuery(this).val().trim() !== "") {
                if (settings.isSimples === true) {
                    var inputHidden = jQuery(this).parent().parent().parent().find('input[type=hidden]').attr('id');
                    addValorAlphaSimples(inputHidden, jQuery(this).val());
                    return;
                }
                if (e.which === 13 || e.which === 9) {
                    var inputHidden = jQuery(this).parent().parent().parent().find('input[type=hidden]').attr('id');
                    if (jQuery(this).val() !== null && jQuery(this).val() !== undefined && jQuery(this).val().trim() !== "") {
                        if (settings.isSimples === null || settings.isSimples === undefined || settings.isSimples === false) {
                            addValorAlphaInput(inputHidden, jQuery(this).val());
                        }
                    }
                    jQuery(this).val('');
                } else {
                    return;
                }
            } 
        });

        if (valorInput !== null && valorInput !== undefined && valorInput.trim() !== "") {
            var nome = valorInput.split("#@#")[0];
            var id = valorInput.split("#@#")[1];
            var inputHidden = jQuery(this).attr('id');
            addValorAlphaInput(inputHidden, nome, id);
        }
        qtdInput++;
    };
})(jQuery);

/**
 * se o tipo em settings for simples.
 * @param {type} input
 * @param {type} valor
 * @returns {undefined}
 */
function addValorAlphaSimples(input, valor){
    // validar se input é objeto ou string do id;
    if (typeof input == 'object') {
        input = input;
    } else {
        input = jQuery('#' + input);
    }
    
    var valorExistente = jQuery(input).val();
    if (valorExistente === undefined) {
        valorExistente = '';
    }
    jQuery(input).val(valor);
//    console.log(jQuery(input));
    
}

/*@author Mateus
 * @description Funcao responsavel por adicionar valor ao input multiplo
 * @param {type} inputHidden
 * @param {type} recarregar
 * @returns {undefined}
 */

function addValorAlphaInput(input, valor, valorIds, notActiveX) {
    if (typeof input == 'object') {
        input = input;
    } else {
        input = jQuery('#' + input);
    }


    var divContainerChaves = jQuery(jQuery(input).parent('div').find('div')[0]);
    if (valor === null || valor === undefined || parseInt(valor.trim().length) == 0) {
        console.info('Valor nulo ou undefinido não pode ser adicionado');
        return false;
    }

    if (valor !== null && valor !== undefined) {
        var valorExistente = jQuery(input).val();
        var chaves = jQuery(divContainerChaves).parent().parent();

        if ((chaves.attr('data-notx') !== undefined) && (chaves.attr('data-notx') === 'true')) {
            notActiveX = true;
        }
        if (chaves.attr('readOnly') !== undefined) {
            if (valorIds != null && valorIds != undefined) {
                divContainerChaves.append("<li class='gamma-li-chaves gamma-li-chaves-readonly'>" + (notActiveX ? "" : "<a class='gamma-li-chaves-a' onclick='removeChaveComIds(this)'></a>") + "<div>" + valor + "</div></li>");
            } else {
                divContainerChaves.append("<li class='gamma-li-chaves gamma-li-chaves-readonly'>" + (notActiveX ? "" : "<a class='gamma-li-chaves-a' onclick='removeChave(this)'></a>") + "<div>" + valor + "</div></li>");
            }
        } else {
            if (valorIds != null && valorIds != undefined) {
                divContainerChaves.append("<li class='gamma-li-chaves' >" + (notActiveX ? "" : "<a class='gamma-li-chaves-a' onclick='removeChaveComIds(this)'></a>") + "<div>" + valor + "</div></li>");
            } else {
                divContainerChaves.append("<li class='gamma-li-chaves' >" + (notActiveX ? "" : "<a class='gamma-li-chaves-a' onclick='removeChave(this)'></a>") + "<div>" + valor + "</div></li>");
            }
        }

        if (notActiveX) {
            divContainerChaves.find('.gamma-li-chaves').css('background', 'rgba(182,182,182,0.5)');
            divContainerChaves.find('.gamma-li-chaves').css('padding', '1px 5px 1px 5px');
        }

        if (valorExistente !== undefined && valorExistente.trim() !== "") {
            if (valorIds != null && valorIds != undefined) {
                valor = valorExistente.trim() + '!@!' + valor.trim() + '#@#' + valorIds.trim();
            } else {
                valor = valorExistente.trim() + '!@!' + valor.trim();
            }
        } else {
            if (valorIds != null && valorIds != undefined) {
                valor = valor.trim() + '#@#' + valorIds.trim();
            }
        }
        jQuery(input).val(valor.trim());
    } else {
        return;
    }
}

/*
 * @author Mateus
 * @description Funcao para remover o valor do input
 * @param {type} inputHidden
 * @param {type} recarregar
 * @returns {undefined}
 */
function removerValorInput(inputHidden, recarregar) {
    if (typeof inputHidden == 'string') {
        inputHidden = jQuery('input[name="' + inputHidden + '"]');
    }

    var divContainerChaves = jQuery(jQuery(inputHidden).parent('div').find('div')[0]);
    divContainerChaves.html('');
    jQuery(inputHidden).val('');
}

function removerValorAlphaInput(input, valor, colocarId) {
    if (typeof input == 'string') {
        input = jQuery('input[name="' + input + '"]');
    }

    var i = 0;
    while (jQuery('.gamma-li-chaves')[i]) {
        if (jQuery(jQuery('.gamma-li-chaves')[i]).find('div').text() == valor) {
            jQuery(jQuery('.gamma-li-chaves')[i]).remove();
        }
        i++;
    }

    var divAlpha = jQuery(input).parents('.alpha');
    jQuery(input).val(valueChaves(divAlpha[0], colocarId));
}

function removerValorAlphaInputSelectMultiplo(input, valor, colocarId) {
    if (typeof input == 'string') {
        input = jQuery('input[name="' + input + '"]');
    }

    var i = 0;
    while (jQuery('.gamma-li-chaves')[i]) {
        if (jQuery(jQuery('.gamma-li-chaves')[i]).find('div').text() == valor) {
            jQuery(jQuery('.gamma-li-chaves')[i]).remove();
        }
        i++;
    }

    var divAlpha = jQuery(input).parents('.alpha');
    var checksMarcados = divAlpha.parent().find('.a-a-div-menu').find('.check-marcado');


    var newValue = '';
    var i = 0;
    while (checksMarcados[i]) {
        newValue += jQuery(checksMarcados[i]).parent('[labelsub]').text() + '#@#' + jQuery(checksMarcados[i]).parent('[labelsub]').attr('view') + '!@!';
        i++;
    }

    jQuery(input).val(newValue);
}
/**
 * @description Funcao para remover o li do input multiplo
 * @param {type} e
 * @returns {undefined}
 */
function removeChave(e) {

    var divAlpha = jQuery(e).parents('.alpha');
    var hidden = jQuery(e).parents('.alpha').find(':hidden');
    jQuery(e).offsetParent().remove();
    jQuery(hidden).val(valueChaves(divAlpha[0]));
}

function valueChaves(divAlpha, colocarId) {
    var liChaves = jQuery(divAlpha).find('.gamma-li-chaves');
    var value = '';
    for (var i = 0; i < jQuery(liChaves).length; i++) {
        if (jQuery(liChaves)[i] !== null && jQuery(liChaves)[i] !== undefined) {
            if (jQuery(jQuery(liChaves)[i]).find('div').html() !== 'undefined' && jQuery(jQuery(liChaves)[i]).find('div').html() !== undefined) {
                if (colocarId) {
                    value += jQuery(jQuery(liChaves)[i]).find('div').text() + "#@#" + removerAcentos(jQuery(jQuery(liChaves)[i]).find('div').text()).toLowerCase() + "!@!";
                } else {
                    value += jQuery(jQuery(liChaves)[i]).find('div').html() + "!@!";
                }
            }
        }
    }

    return value;

}

function removeChaveComIds(e) {
    var hidden = jQuery(e).parents('.alpha').find(':hidden');

    //Caso o input multiplo seja chamado por um select multiplo
    //Ele mesmo remove o valor e trata o select
    try {
        if (jQuery(e).parents('.a-a')[0]) {
            var i = 0;
            while (jQuery(jQuery(e).parents('.a-a')[0]).find('[labelSub]')[i]) {
                if (jQuery(jQuery(e).parents('.a-a').find('[labelSub]')[i]).text() == jQuery(e).offsetParent().find('div').text()) {
                    var li = jQuery(jQuery(jQuery(e).parents('.a-a').find('[labelSub]')[i]).parents('li')[0]);
                    var idInput = li.attr('idinput');
                    marcarDesmarcarLiGrupoMultiplo(li, idInput);
                    return false;
                }
                i++;
            }
        }
    } catch (err) {
        console.error('Erro ao tentar remover o valor do select multiplo grupo gw.');
    }
    //---------------------------------------------------------

    var valores = jQuery(hidden).val().split('!@!');
    var newValor = '';

    for (var i = 0; i < valores.length; i++) {
        if (valores[i].split('#@#').indexOf(jQuery(e).parent().find('div').html()) === -1) {
            if (valores[i] != undefined && valores[i] != '') {
                newValor += valores[i] + '!@!';
            }
        }
    }

    jQuery(e).offsetParent().remove();
    jQuery(hidden).val(newValor);

}
//---------------- FIM DAS FUNCOES DE INPUT MULTIPLO ----------------------------

//---------------- SELECT EXCETO APENAS ----------------------------
var qtdInputSelectExcetoApenas = 1;
(function ($) {
    $.fn.selectExcetoApenasGw = function (options) {
        var input = jQuery(this);
        var inputClone = input.clone();

        jQuery(input).parent().append(inputClone);
        jQuery(inputClone).hide();

        var idInput = jQuery(input).attr('id');

        var opcoesSelect = [];

        jQuery(inputClone).find("option").each(function () {
            var elemento = jQuery(this);

            opcoesSelect.push({'valor': elemento.attr('value'), 'texto': elemento.text()});
        });

        var opcoesDefaults = {
            width: '150px',
            height: 'auto',
            readOnly: false
        };

        var settings = $.extend({}, opcoesDefaults, options);

        var valorEscolhido = jQuery('#' + idInput + ' option:selected').html();

        var divAlphaExcetoApenas = jQuery('<div class="div-alpha-exceto-apenas">');
        divAlphaExcetoApenas.css("position", "relative");
        var divBetaExcetoApenas = jQuery('<div class="div-beta-exceto-apenas">');
        var divGammaExcetoApenas = jQuery('<div class="div-gamma-exceto-apenas">');

        var spTitulo = jQuery('<span>').html(valorEscolhido);
        var spanExcetoApenas = jQuery('<span class="span-escolha-gw" id="span-escolha-gw-' + qtdInputSelectExcetoApenas + '">');
        var imgExcetoApenas = jQuery('<img src="' + homePath + '/img/ordenar_with_down01.png" width="10px" style="margin-left: 5px;margin-bottom: 1px;opacity: 0.8;">');
        spanExcetoApenas.append(spTitulo);
        spanExcetoApenas.append(imgExcetoApenas);
        divBetaExcetoApenas.append(spanExcetoApenas);

        var containerLiValores = jQuery('<div class="container-li-valores" id="container-li-valores-' + qtdInputSelectExcetoApenas + '">');
        var ul = jQuery('<ul style="width:' + settings.width + ';">');

        for (var i = 0; i < opcoesSelect.length; i++) {
            var opcao = opcoesSelect[i];
            var span = jQuery('<span>').text(opcao.texto);
            var li = jQuery('<li>', {
                'data-valor': opcao.valor
            }).append(span);
            ul.append(li);
        }

        containerLiValores.append(ul);
        divGammaExcetoApenas.append(containerLiValores);
        divAlphaExcetoApenas.append(divBetaExcetoApenas);
        divAlphaExcetoApenas.append(divGammaExcetoApenas);

        jQuery(input).replaceWith(divAlphaExcetoApenas);

        jQuery(spanExcetoApenas).click(function () {
            if (!settings.readOnly) {
                if (jQuery(containerLiValores).css('display') == 'block') {
                    jQuery(divBetaExcetoApenas).find('img').css('-webkit-transform', 'rotate(0deg)');
                    jQuery(divBetaExcetoApenas).find('img').css('transform', 'rotate(0deg)');

                    jQuery(containerLiValores).hide(250);
                } else {
                    jQuery(divBetaExcetoApenas).find('img').css('-webkit-transform', 'rotate(180deg)');
                    jQuery(divBetaExcetoApenas).find('img').css('transform', 'rotate(180deg)');
                    jQuery(containerLiValores).show(250);
                }
            }
        });


        jQuery(containerLiValores).find('ul').find('li').click(function () {

            var elemento = jQuery(this);
            var valor = elemento.attr('data-valor');

            jQuery(inputClone).val(valor);

            jQuery(divBetaExcetoApenas).find('img').css('-webkit-transform', 'rotate(0deg)');
            jQuery(divBetaExcetoApenas).find('img').css('transform', 'rotate(0deg)');
            jQuery(containerLiValores).hide();
            var vl = jQuery(this).find('span').html();
            jQuery(spanExcetoApenas).hide(250, function () {
                jQuery(spanExcetoApenas).find('span').html(vl);
                jQuery(spanExcetoApenas).show(250);
            });
        });

        qtdInputSelectExcetoApenas++;
    };

})(jQuery);

//------------ SELECT MULTIPLO GW -----------------
var select = null;
var qtdSelect = 1;
(function ($) {
    $.fn.selectMultiploGw = function (options) {
        var select = jQuery(this);
        var selectClone = select.clone();

        jQuery(select).parent().append(selectClone);
        jQuery(selectClone).hide();

        var opcoesDefaults = {
            titulo: '',
            width: '150px',
            idInputHidden: 'id-tipos-escolhidos',
            idInputHiddenTiposEscolhidos: 'tipos-escolhidos'
        };
        var settings = $.extend({}, opcoesDefaults, options);

        var divContainerSelect = jQuery('<div class="container-select-multiplo-gw">');
        var divContainerSelectA1 = jQuery('<div class="container-select-multiplo-gw-A">');
//        var spanTitulo = jQuery('<span>').html(settings.titulo);

        var inputEscolhidos = jQuery('<input type="text" placeholder="Selecione os Tipos" readonly="true" id="' + settings.idInputHiddenTiposEscolhidos + '" name="' + settings.idInputHiddenTiposEscolhidos + '">');
        var idsInputEscolhidos = jQuery('<input type="hidden" id="' + settings.idInputHidden + '" name="' + settings.idInputHidden + '" >');
//        divContainerSelectA1.append(selectTitulo);
        divContainerSelectA1.append(idsInputEscolhidos);
        divContainerSelectA1.append(inputEscolhidos);

        divContainerSelect.append(divContainerSelectA1);

        var divContainerSelectA2 = jQuery('<div class="container-select-multiplo-gw-A">');
        var ul = jQuery('<ul>');

        jQuery(selectClone).find('option');

        var index = 0;
        while (jQuery(selectClone).find('option')[index] != undefined) {
            var html = jQuery(selectClone).find('option')[index].innerText;
            var value = jQuery(jQuery(selectClone).find('option')[index]).val();


            var li = jQuery('<li>');
            var img = jQuery('<img src="' + homePath + '/assets/img/chk.png">');
            var label = jQuery('<label id="' + value + '">').html(html);

            li.append(img);
            li.append(label);

            ul.append(li);

            index++;
        }
        var i = 0;

        divContainerSelectA2.append(ul);

        divContainerSelect.append(divContainerSelectA2);

        jQuery(select).replaceWith(divContainerSelect);

        var campoComFoco = false;

        jQuery(inputEscolhidos).focusin(function () {
            if (sessionStorage.getItem('nao_mostrar_opcoes_select_multiplo') !== 'true') {
                jQuery(ul).show(250);
                campoComFoco = true;
            }
        }).focusout(function () {
            if (sessionStorage.getItem('nao_mostrar_opcoes_select_multiplo') !== 'true') {
                campoComFoco = false;
                setTimeout(function () {
                    if (!campoComFoco) {
                        jQuery(ul).hide(250);
                    }
                }, 250);
            }
        });

        jQuery(divContainerSelect).click(function () {
            jQuery(inputEscolhidos).focus();
        });

        jQuery(ul).find('li').click(function () {
            var valAtual = jQuery(inputEscolhidos).val();
            if (valAtual.length > 0 && valAtual.charAt(valAtual.length - 1) != ',') {
                valAtual += ',';
            }

            var idsAtual = jQuery(idsInputEscolhidos).val();
            if (idsAtual.length > 0 && idsAtual.charAt(idsAtual.length - 1) != ',') {
                idsAtual += ',';
            }

            if (jQuery(this).find('img').attr('src').indexOf("checked") !== -1) {
                jQuery(this).css('background', '#fff');
                //----------
                if (valAtual.length > 0) {
                    valAtual = valAtual.replace(jQuery(this)[0].innerText + ',', '');
                }
                if (valAtual.charAt(valAtual.length - 1) == ',') {
                    valAtual = valAtual.substr(0, valAtual.length - 1);
                }
                //----------
                if (idsAtual.length > 0) {
                    idsAtual = idsAtual.replace(jQuery(jQuery(this)[0]).find('label').attr('id') + ',', '');
                }
                if (idsAtual.charAt(idsAtual.length - 1) == ',') {
                    idsAtual = idsAtual.substr(0, idsAtual.length - 1);
                }
                //---------
                jQuery(this).find('img').attr('src', homePath + '/assets/img/chk.png');
                jQuery(inputEscolhidos).val(valAtual);
                jQuery(idsInputEscolhidos).val(idsAtual);
            } else {
                jQuery(this).css('background', '#efefef');

                jQuery(this).find('img').attr('src', homePath + '/assets/img/chk_checked.png');

                jQuery(inputEscolhidos).val(valAtual + jQuery(this)[0].innerText);
                jQuery(idsInputEscolhidos).val(idsAtual + jQuery(jQuery(this)[0]).find('label').attr('id'));
            }
        });

    };


})(jQuery);

//------------ SELECT GRUPO MULTIPLO GW -----------------
var select = null;
var qtdSelect = 1;
(function ($) {
    $.fn.selectGrupoMultiploGw = function (options) {
        var select = jQuery(this);
        var selectClone = select.clone();

        jQuery(select).parent().append(selectClone);
        jQuery(selectClone).hide();

        var opcoesDefaults = {
            titulo: '',
            grupos: null,
            width: '150px',
            idInputHidden: 'id-tipos-escolhidos'
        };
        var settings = $.extend({}, opcoesDefaults, options);

        for (var v in settings.grupos) {
            var optGroup = jQuery('<optgroup class="divEl" label="' + v + '" value="">');
            for (var l in settings.grupos[v]) {
                var option = jQuery('<option class="divEl">');
                option.html(settings.grupos[v][l].split('!!')[0]);
                option.attr('value', settings.grupos[v][l].split('!!')[0] + '#@#' + settings.grupos[v][l].split('!!')[1] + '!!' + settings.grupos[v][l].split('!!')[2] + '!!' + settings.grupos[v][l].split('!!')[3]);
                optGroup.append(option);
            }
            selectClone.append(optGroup);
        }

        var divContainerSelect = jQuery('<div class="container-select-multiplo-gw">');
        var divContainerSelectA1 = jQuery('<div class="container-select-multiplo-gw-A">');
//        var spanTitulo = jQuery('<span>').html(settings.titulo);

        var inputEscolhidos = jQuery('<input type="text" placeholder="Selecione os Tipos" readonly="true" id="' + settings.input + '-escolhidos" name="' + settings.input + '-escolhidos">');
        var idsInputEscolhidos = jQuery('<input type="hidden" id="' + settings.input + '" name="' + settings.input + '" >');
//        divContainerSelectA1.append(selectTitulo);
        divContainerSelectA1.append(idsInputEscolhidos);
        divContainerSelectA1.append(inputEscolhidos);

        divContainerSelect.append(divContainerSelectA1);

        var divContainerSelectA2 = jQuery('<div class="container-select-multiplo-gw-A">');
        var ul = jQuery('<ul>');

        jQuery(selectClone).find('option');

        var index = 0;
        while (jQuery(selectClone).find('.divEl')[index] != undefined) {
            var value = jQuery(jQuery(selectClone).find('.divEl')[index]).val();
            if (value != "") {
                var html = jQuery(selectClone).find('.divEl')[index].innerText;
            } else {
                var html = jQuery(jQuery(selectClone).find('.divEl')[index]).attr('label');
            }
            if (value != "") {
                var li = jQuery('<li>');
                var img = jQuery('<img src="' + homePath + '/assets/img/chk.png">');
                var label = jQuery('<label id="' + value + '">').html(html);
                li.append(img);
                li.append(label);
                ul.append(li);
            } else {
                var li = jQuery('<li class="group">');
                var label = jQuery('<label id="' + value + '">').html(html);
                li.append(label);
                ul.append(li);
            }
            index++;
        }
        var i = 0;

        divContainerSelectA2.append(ul);

        divContainerSelect.append(divContainerSelectA2);

        jQuery(select).replaceWith(divContainerSelect);

        var campoComFoco = false;

        jQuery(inputEscolhidos).focusin(function () {
            jQuery(ul).show(250);
            campoComFoco = true;
        }).focusout(function () {
            campoComFoco = false;
            setTimeout(function () {
                if (!campoComFoco) {
                    jQuery(ul).hide(250);
                }
            }, 250);
        });

        jQuery(divContainerSelect).click(function () {
            jQuery(inputEscolhidos).focus();
        });

        jQuery(ul).find('li').click(function () {
            var valAtual = jQuery(inputEscolhidos).val();
            if (valAtual.length > 0 && valAtual.charAt(valAtual.length - 1) != ',') {
                valAtual += ',';
            }

            var idsAtual = jQuery(idsInputEscolhidos).val();
            if (idsAtual.length > 0 && idsAtual.charAt(idsAtual.length - 1) != ',') {
                idsAtual += ',';
            }

            if (jQuery(this).find('img').attr('src').indexOf("checked") !== -1) {
                jQuery(this).css('background', '#fff');
                //----------
                if (valAtual.length > 0) {
                    valAtual = valAtual.replace(jQuery(this)[0].innerText + ',', '');
                }
                if (valAtual.charAt(valAtual.length - 1) == ',') {
                    valAtual = valAtual.substr(0, valAtual.length - 1);
                }
                //----------
                if (idsAtual.length > 0) {
                    idsAtual = idsAtual.replace(jQuery(jQuery(this)[0]).find('label').attr('id') + ',', '');
                }
                if (idsAtual.charAt(idsAtual.length - 1) == ',') {
                    idsAtual = idsAtual.substr(0, idsAtual.length - 1);
                }
                //---------
                jQuery(this).find('img').attr('src', homePath + '/assets/img/chk.png');
                jQuery('#' + settings.input + '-escolhidos').val(valAtual);
                jQuery('#' + settings.input + '').val(idsAtual);
            } else {
                jQuery(this).css('background', '#efefef');

                jQuery(this).find('img').attr('src', homePath + '/assets/img/chk_checked.png');

                jQuery(inputEscolhidos).val(valAtual + jQuery(this)[0].innerText);
                jQuery(idsInputEscolhidos).val(idsAtual + jQuery(jQuery(this)[0]).find('label').attr('id'));
            }
        });

    };


})(jQuery);
//------------------ SELECT MULTPLI COM GRUPO GW --------------
//---------------------- NAO É UTILIZADO ----------------------
(function ($) {

    /**
     * Função responsavel por criar um select com divisoes de grupos
     * Atenção a funcão vai mandar ao input o valor escolhido da seguinte maneira.
     * @example Não Realizada = nao-realizada
     */
    $.fn.selectMultiploGrupoGw = function (options) {
        var opcoesDefaults = {
            container: null,
            titulo: null,
            grupos: null,
            width: '100%',
            idInput: 'input-multiplo-grupo-gw'
        };
        var settings = $.extend({}, opcoesDefaults, options);

        if (!settings.container) {
            console.info('SelectMultiploGrupoGw não pode ser iniciado : "Configure o campo container"');
            return false;
        }

        var inp = jQuery(this);
        inp.hide();
        var containerGeral = jQuery(inp).parent();

        var divTopo = jQuery('<div class="a-a">');
        var span = jQuery('<span class="a-a-1">').html(settings.titulo);
        divTopo.append(span);
        containerGeral.append(divTopo);

        var input = jQuery('<input id="' + settings.idInput + '" name="' + settings.idInput + '" class="a-a-2" readonly="true">');

        divTopo.append(input);



        var divMenu = jQuery('<div class="a-a-div-menu" style="width:' + settings.width + '">');

        var ulGrupo = jQuery('<ul>');

        for (var v in settings.grupos) {
            var liGrupo = jQuery('<li>');
            var label = jQuery('<label>');
            label.html(v);
            liGrupo.append(label);

            var subGrupo = jQuery('<ul>');
            for (var l in settings.grupos[v]) {
                var liSubGrupo = jQuery('<li id="li-list">');
                var labelSub = jQuery('<label labelSub>');
                var divCheck = jQuery('<div class="check-desmarcado" id="check-list">');
                labelSub.html(divCheck);
                labelSub.html(labelSub.html() + settings.grupos[v][l].split('!!')[0]);
                labelSub.attr('view', settings.grupos[v][l].split('!!')[1] + '!!' + settings.grupos[v][l].split('!!')[2] + '!!' + settings.grupos[v][l].split('!!')[3]);
                liSubGrupo.append(labelSub);
                subGrupo.append(liSubGrupo);

                liSubGrupo.attr('onclick', 'marcarDesmarcarLiGrupoMultiplo(this,"' + settings.idInput + '")');
                liSubGrupo.attr('idinput', settings.idInput);
            }

            liGrupo.append(subGrupo);

            ulGrupo.append(liGrupo);

        }

        divMenu.append(ulGrupo);


        divTopo.append(divMenu);

        input.inputMultiploGw({
            width: '96%',
            readOnly: 'true'
        });

        //Clique para abrir menu
        span.click(function () {
            divMenu.toggle(250);
        });

    };
    jQuery(document).click(function (e) {
        if (e.target.className == "a-a-1") {
            return false;
        }

        var tdAlvo = e.target.className == "a-a-div-menu" ? e.target : jQuery(e.target).parents('.a-a-div-menu')[0];
        if (!tdAlvo) {
            jQuery('.a-a-div-menu').hide(250);
        }
        var alvo = e.target.className == "span-escolha-gw" ? e.target : jQuery(e.target).parents('.span-escolha-gw')[0];
        if (!alvo) {
            jQuery('.container-li-valores').hide(250);
            jQuery('.span-escolha-gw').find('img').css('-webkit-transform', 'rotate(0deg)');
            jQuery('.span-escolha-gw').find('img').css('transform', 'rotate(0deg)');
        }
    });


})(jQuery);

/**
 * Remove acentos de strings
 * @param  {String} string acentuada
 * @return {String} string sem acento
 */

var mapCaracteres = {" ": "_", "â": "a", "Â": "A", "à": "a", "À": "A", "á": "a", "Á": "A", "ã": "a", "Ã": "A", "ê": "e", "Ê": "E", "è": "e", "È": "E", "é": "e", "É": "E", "î": "i", "Î": "I", "ì": "i", "Ì": "I", "í": "i", "Í": "I", "õ": "o", "Õ": "O", "ô": "o", "Ô": "O", "ò": "o", "Ò": "O", "ó": "o", "Ó": "O", "ü": "u", "Ü": "U", "û": "u", "Û": "U", "ú": "u", "Ú": "U", "ù": "u", "Ù": "U", "ç": "c", "Ç": "C"};

function removerAcentos(s) {
    return s.replace(/[\W\[\] ]/g, function (a) {
        return mapCaracteres[a] || a;
    });
}
;

/*
 * O que o input manda ao controlador é o nome minusculo e com "_" no lugar dos espaços
 * @param {type} elemento
 * @param {type} alphaInput
 * @returns {Nada}
 */
function marcarDesmarcarLiGrupoMultiplo(elemento, alphaInput) {
    if (jQuery(elemento).find('div').hasClass('check-desmarcado')) {
        addValorAlphaInput(alphaInput, jQuery(elemento).find('label').text(), jQuery(elemento).find('label').attr('view'), true);
        jQuery(elemento).find('div').switchClass("check-desmarcado", "check-marcado", 250);
    } else {
        jQuery(elemento).find('div').switchClass("check-marcado", "check-desmarcado", 250);
        setTimeout(function () {
            removerValorAlphaInputSelectMultiplo(alphaInput, jQuery(elemento).find('label').text(), true);
        }, 300);
    }
}

function addValorSelectMultiploGrupo(idInput, valor, descricao) {
    if (typeof idInput !== 'object') {
        idInput = jQuery('#' + idInput);
    }
    var a_a = jQuery(idInput).parents('.a-a');
    var i = 0;
    while (a_a.find('[labelsub]')[i]) {
        if (jQuery(a_a.find('[labelsub]')[i]).text() === descricao) {
            marcarDesmarcarLiGrupoMultiplo(jQuery(a_a.find('[labelsub]')[i]).parent('li'), idInput);
        }
        i++;
    }

}

//----------------------------- GW FORM JSON -----------------------------
//---------------------------- Autor : Mateus ----------------------------

/*Array.prototype.__setValueObjectGW__ = function (atributo, nome) {
 this[atributo] = nome;
 };*/

(function ($) {

    $.fn.gwFormToJson = function (options) {
        try {
            //Enviando msg de 
            /*$('input[name]').each(function () {
                if (!$(this)[0].hasAttribute("data-serialize-campo") && !$(this)[0].hasAttribute("data-gw-campo-grupo-serializado")) {
                    console.warn('Atenção o elemento de nome : ' + this.name + ', não está sendo enviado na requesição!');
                }
            });*/
            //Form que vai ser serializado
            var form = $(this);

            var opcoesDefaults = {};

            var settings = $.extend({}, opcoesDefaults, options);
            //Iniciando json
            var json = {};
            //Pegando todos os campos simples
            var campos_simples = form.find('[data-serialize-campo]');

            $.each(campos_simples, function (i, element) {
                //se o campo for um checkbox ele deve pegar o valor do PROP.
                if ($(element).attr("type") === "checkbox") {
                    json[$(element).attr('name')] = $(element).prop('checked');
                } else if ($(element).attr('type') === 'radio') {
                    if ($(element).prop('checked')) {
                        json[$(element).attr('name').replace(/\d+?$/, '')] = $(element).val();
                    }
                } else if ($(element).is('input') || $(element).is('select') || $(element).is('textarea')) {
                    //caso contratio pegar o valor do VAL.
                    // Primeiro procura se tem algum elemento com name igual ao elemento com ID (o datebox remove o nome do elemento e cria um novo input com o mesmo nome)
                    var elementoPorNome = $('input[name="' + $(element).attr('id') + '"]');
                    // Dependendo se encontrar um elemento pelo nome acima, o elemento a ser usado será ele, se não encontrar, o elemento será o que está com o data-serialize-campo
                    var elemento = (elementoPorNome === undefined || elementoPorNome.length <= 0) ? $(element) : elementoPorNome;
                    // Pega o valor do elemento
                    var valor = elemento.val();

                    // Coloca o nome e o valor no json a ser enviado
                    if (valor !== undefined && valor !== null) {
                        json[elemento.attr('name')] = valor.trim().replace(/\n/g, "");
                    } else {
                        console.error('Não foi possível serializar o campo ' + elemento.attr('name') + ' pois tem valor indefinido!');
                        json[elemento.attr('name')] = '';
                    }
                } else {
                    // Provavelmente é uma label...
                    json[$(element).attr('id')] = $(element).clone().children().remove().end().text().trim();
                }
            });


            var grupos_serializados = form.find('[data-gw-grupo-serializado]');
            var elemento_grupo_serializado = form.find('[data-gw-campo-grupo-serializado]');
            var container_grupos = [];
            var container_grupos_name = [];
            var myMap = new Map();
            
            $.each(grupos_serializados, function (i, element) {
                var data = $(element).attr('data-gw-grupo-serializado');
                var name = $(element).attr('data-gw-grupo-name');//Caso tenha mais de um DOM e queira armazenar em listas diferentes
                var grupo_json = {};
                $.each(elemento_grupo_serializado, function (i, element) {
                    var e = $(element);
                    if (e.attr('data-gw-campo-grupo-serializado') === data) {
                        //se o campo for um checkbox ele deve pegar o valor do PROP.
                        if (e.attr("type") === "checkbox") {
                            grupo_json[e.attr('name').replace(/\d+?$/, '')] = e.prop('checked');
                        } else if (e.attr('type') === 'radio') {
                            if (e.prop('checked')) {
                                grupo_json[e.attr('name').replace(/\d+?$/, '')] = e.val();
                            }
                        } else {
                            if (e.attr('data-gw-grupo-objeto') !== undefined && e.attr('data-gw-grupo-objeto') === '') {
                                var nomeLista = e.attr('data-gw-grupo-lista');

                                if (grupo_json[nomeLista] === undefined) {
                                    grupo_json[nomeLista] = [];
                                }
                                
                                var objeto = {};
                                
                                $.each(e.find('input'), function (index, elementoFilho) {
                                    var e1 = $(elementoFilho);

                                    if (e1.attr("type") === "checkbox") {
                                        objeto[e1.attr('name').replace(/((\d)+(_?))+/, '')] = e1.prop('checked');
                                    } else if (e1.attr('type') === 'radio') {
                                        if (e1.prop('checked')) {
                                            objeto[e1.attr('name').replace(/((\d)+(_?))+/, '')] = e1.val();
                                        }
                                    } else {
                                        objeto[e1.attr('name').replace(/((\d)+(_?))+/, '')] = e1.val().trim().replace(/\n/g, "");
                                    }
                                });
                                
                                grupo_json[nomeLista].push(objeto);
                            } else if ($(element).is('input') || $(element).is('select')) {
                                //caso contratio pegar o valor do VAL.
                                // Primeiro procura se tem algum elemento com name igual ao elemento com ID (o datebox remove o nome do elemento e cria um novo input com o mesmo nome)
                                var elementoPorNome = $('input[name="' + e.attr('id') + '"]');
                                // Dependendo se encontrar um elemento pelo nome acima, o elemento a ser usado será ele, se não encontrar, o elemento será o que está com o data-serialize-campo
                                var elemento = (elementoPorNome === undefined || elementoPorNome.length <= 0) ? e : elementoPorNome;
                                // Pega o valor do elemento
                                var valor = elemento.val();

                                // Coloca o nome e o valor no json a ser enviado
                                if (valor !== undefined && valor !== null) {
                                    grupo_json[elemento.attr('name').replace(/\d+?$/, '')] = valor.trim().replace(/\n/g, "");
                                } else {
                                    console.error('Não foi possível serializar o campo ' + elemento.attr('name') + ' pois tem valor indefinido!');
                                    grupo_json[elemento.attr('name').replace(/\d+?$/, '')] = '';
                                }
                            } else {
                                // Provavelmente é uma label...
                                json[$(element).attr('id')] = $(element).clone().children().remove().end().text().trim();
                            }
                        }
                    }
                });
                //se usar nomes personalizados
                if (name) {
                    //verifica se existe algum no mapa
                    container_grupos_name = myMap.get(name);
                    //caso não exista, inicia a variavel
                    if (container_grupos_name == null) {
                        container_grupos_name = [];
                    }
                    //coloca o objeto na lista
                    container_grupos_name.push(grupo_json);
                    //coloca a lista no mapa
                    myMap.set(name,container_grupos_name);
                } else {
                    container_grupos.push(grupo_json);
                }
            });
            //percorre o mapa e cria os conteiners
            myMap.forEach(function (value, key) {
                json[key] = value;
            }, myMap);
            myMap = null;
            //caso container_grupos estaja vazio, não insere
            if (container_grupos.length > 0) {
                json['container-grupos'] = container_grupos;
            }
            return JSON.stringify(json);
        }catch (e){
            console.log(e);
        }
        
    };

})(jQuery);
/*
 * É uma ideia de criar um framework que monitore a pagina e caso algo seja alterado salve apenas aquele campo 
 * evitando assim um update gigantesco. 
 * @param {type} $
 * @returns {undefined}
 * 
 */
(function ($) {
    $.fn.gwMonitoringDOM = function (options) {
        
        var opcoesDefaults = {},
                settings = $.extend({}, opcoesDefaults, options);

        var container = $(this);

        $.each(container.find('input'), function (index, element) {
            var e = $(element);
        });
    };
})(jQuery);

jQuery.extend({
    stringify: function stringify(obj) {
        var t = typeof (obj);
        if (t != "object" || obj === null) {
            // simple data type
            if (t == "string")
                obj = '"' + obj + '"';
            return String(obj);
        } else {
            // recurse array or object
            var n, v, json = [], arr = (obj && obj.constructor == Array);

            for (n in obj) {
                v = obj[n];
                t = typeof (v);
                if (obj.hasOwnProperty(n)) {
                    if (t == "string")
                        v = '"' + v + '"';
                    else if (t == "object" && v !== null)
                        v = jQuery.stringify(v);
                    json.push((arr ? "" : '"' + n + '":') + String(v));
                }
            }
            return (arr ? "[" : "{") + String(json) + (arr ? "]" : "}");
        }
    }
});


(function ($) {

    $.fn.gwReadFile = function (options) {
        var opcoesDefaults = {
            limit: 4000,
            destiny: undefined,
            callback: undefined,
            no_destiny_if_save_fail: false,
            save_file: {
                enable_save_file: false,
                controller: {
                    url: undefined,
                    action: undefined,
                    data: {
                        archive: undefined,
                        description: undefined,
                        extension: undefined,
                        base64: false
                    }
                }
            }
        };

        var settings = $.extend({}, opcoesDefaults, options);
        $(this).on('change', function (event) {
            try {
                if ($(this).prop("files") && $(this).prop("files").length > 0) {
                    var input = event.target;
                    var file = input.files[0];
                    var reader = new FileReader();
                    var txt = null;
                    reader.onload = function () {
                        //lendo o arquivo e colocando o valor no campo passado como destiny
                        txt = reader.result;
                        setDestiny(settings.destiny, txt);
                    };

                    // validar a extenção;
                    var ext = file.name.split(".").pop();
                    try {
                        if (settings.save_file.controller.data.extension !== undefined &&
                                settings.save_file.controller.data.extension.map(a => a.toLowerCase()).indexOf(ext.toLowerCase()) < 0) {
                            chamarAlert("A extensão do arquivo é inválida. <br>As extensões aceitas são: (" + settings.save_file.controller.data.extension.join(", ") + ")");
                            input.value = '';
                            return;
                        }
                    } catch (excetpion) {
                        console.error('Erro: Não foi definida a extensão do arquivo nas configurações do "gwReadFile" ');
                    }

                    // validar o tamanho do arquivo.
                    if (input.files.length > 0) {
                        if (file.size < settings.limit) {
                            if (settings.save_file.controller.data && settings.save_file.controller.data.base64) {
                                reader.readAsDataURL(file);
                            } else {
                                reader.readAsText(file);
                            }

                            if (settings.callback && typeof settings.callback === 'function') {
                                settings.callback(file);
                            }
                        } else {
                            chamarAlert("Tamanho maximo foi excedido!");
                            return;
                        }
                    } else {
                        chamarAlert("Informe um arquivo!");
                        return;
                    }

                    if (settings.save_file.enable_save_file) {
                        var form_data = new FormData();
                        form_data.append("file", file);
                        $.ajax({
                            type: "POST",
                            url: settings.save_file.controller.url,
                            cache: false,
                            contentType: false,
                            processData: false,
                            data: form_data,
                            complete: function (jqXHR, textStatus) {
                                if (settings.no_destiny_if_save_fail && jqXHR.responseText.trim().includes('false')) {
                                    setDestiny(settings.destiny, txt);
                                } else if (settings.no_destiny_if_save_fail && !jqXHR.responseText.trim().includes('false')) {
                                    setDestiny(settings.destiny, null);
                                }
                            }
                        });
                    }
                }
            } catch (e) {
                console.error(e);
            }

        });
    };

})(jQuery);

(function ($) {

    $.fn.gwDatebox = function (options) {
        var opcoesDefaults = {
            'disabled': false,
            'icone_classe': 'combo-arrow',
            'funcao_apos_criacao': undefined
        };

        var settings = $.extend({}, opcoesDefaults, options);

        var carregarEasyUi = true;

        var elementos = this;
        
        if (elementos.length > 0) {
            carregarEasyUi = elementos.first().datebox === undefined;
        }
        
        if (carregarEasyUi) {
            // Carregar o script do easyui.js APÓS carregar a página, e após carregar, montar o datebox
            $.when($.getScript(homePath + '/assets/js/jquery.easyui.min.js')).then(function() {
                carregarDatebox(settings, elementos);
            });
        } else {
            carregarDatebox(settings, elementos);
        }
    };
    
    function carregarDatebox(settings, elementos) {
        elementos.each(function () {
            var elemento = $(this);

            elemento.datebox({
                disabled: settings.disabled,
                formatter: function (date) {
                    var y = date.getFullYear();
                    var m = date.getMonth() + 1;
                    var d = date.getDate();
                    return (String(d).padStart(2, '0')) + '/' + (String(m).padStart(2, '0')) + '/' + y;
                },
                parser: function (s) {
                    if (!s)
                        return new Date();
                    var ss = s.split('/');
                    var y = parseInt(ss[2], 10);
                    var m = parseInt(ss[1], 10);
                    var d = parseInt(ss[0], 10);
                    if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
                        return new Date(y, m - 1, d);
                    } else {
                        return new Date();
                    }
                }
            });

            elemento.parent().find('.textbox-text').mask('00/00/0000');
            elemento.parent().find('.combo-arrow').addClass(settings.icone_classe);
            elemento.datebox('textbox').bind('focusout', function (e) {
                completarDataDatebox(this, e, elemento);
            });

            if (settings.funcao_apos_criacao !== undefined && typeof settings.funcao_apos_criacao === 'function') {
                settings.funcao_apos_criacao(elemento);
            }
        });
    }

})(jQuery);

function setDestiny(d, v) {
    if (typeof d === 'function') {
        d(v);
    } else if (typeof d === 'object' && d) {
        d.val(v);
    }
}

function completarDataDatebox(ob, ev, elemento) {
    var data = new Date();
    var dia = data.getDate();
    var mes = data.getMonth() + 1;
    var ano = data.getFullYear();
    if (ob && ob.value) {
        var valor = ob.value.match(/\/|[0-9]/g).join("");

        if (valor.length === 1) {
            ob.value = String(ob.value).padStart(2, '0') + '/' + (String(mes).padStart(2, '0')) + '/' + ano;
        }

        if (valor.length === 2) {
            ob.value = ob.value + '/' + (String(mes).padStart(2, '0')) + '/' + ano;
        }

        if (valor.length === 4) {
            dia = valor.split("/")[0];
            mes = valor.split("/")[1];
            ob.value = dia + '/' + String(mes).padStart(2, '0') + '/' + ano;
        }

        if (valor.length > 4 && valor.length < 7) {
            if (valor.length === 6) {
                ob.value = ob.value + ano;
            } else {
                ob.value = ob.value + '/' + ano;
            }
        }
    }

    if (!validaDataDatebox(ob.value) && ob.value.length > 0) {
        chamarAlert('A data "' + ob.value + '" é inválida.');
        ob.value = (String(dia).padStart(2, '0')) + '/' + (String(mes).padStart(2, '0')) + '/' + ano;
    }

    elemento.datebox('setValue', ob.value);
}

function validaDataDatebox(data) {
    var barras = data.split("/");

    if (barras.length == 3) {
        var dia = barras[0];
        var mes = barras[1];
        var ano = barras[2];
        if (ano.length == 2) {
            if (ano >= 50 && ano <= 99)
                ano = "19" + ano;
            else
                ano = "20" + ano;
        }

        //Verificando se o dia e o mês é válido
        if ((mes < 1 || mes > 12) || (dia < 1 || dia > 31))
            return false;
        //Verificando se o dia está correto para os meses com 30 dias
        else if ((mes == 4 || mes == 6 || mes == 9 || mes == 11) && dia == 31)
            return false;
        //Verificando se o dia foi digitado corretamente para o mês 02
        else if (mes == 2 && dia > 29)
            return false;
        //Verificando a qtd de dígitos do ano
        else if (ano.length != 2 && ano.length != 4)
            return false;
        else
            return true;
    } else {
        return false;
    }
}
