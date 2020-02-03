jQuery(document).ready(function () {

	var heightDoc = jQuery(window).height()-70;
    jQuery(".heightDoc").css('height', heightDoc);

    jQuery("#toggle").click(function () {
        if (jQuery(this).data('name') == 'show') {
            jQuery("#sidebar").animate({
                width: '1%'
            });
            jQuery('#sidebar .content').hide(250);
            jQuery("#map").animate({
                width: '96%'
            });
            jQuery(this).data('name', 'hide');
            jQuery(this).text("Exibir Filtros");
            jQuery(this).removeClass('toogleOn').addClass('toogleOff');
            jQuery('.datagrid-header').css('width', jQuery('.datagrid-body').width());
        } else {
            jQuery("#sidebar").animate({
                width: '28%'
            });
            jQuery('#sidebar .content').show();
            jQuery("#map").animate({
                width: '72%'
            });
            jQuery(this).data('name', 'show');
            jQuery(this).text("Ocultar Filtros");
            jQuery(this).removeClass('toogleOff').addClass('toogleOn');                     
        }
    });

    jQuery('#img_options_details').click(function(){
        var divToogle = jQuery('#options_details');

        if(divToogle.is(":visible")){
            divToogle.hide(250);
            jQuery("#img_options_details img").attr("src", "assets/img/icon-seta-down.png");
            jQuery("#toogle_options_details").html("Exibir opções detalhadas");
        } else {
            divToogle.show(250);
            jQuery("#img_options_details img").attr("src", "assets/img/icon-seta.png");
            jQuery("#toogle_options_details").html("Ocultar opções detalhadas");
        }
    });

    jQuery('#tableInfo').datagrid({
        url:'/gw-front-end/assets/js/datagrid_data.json',
        pagination: true,
        pageSize: 10,
        pageList: [10, 20, 50],
        singleSelect: false,
        fitColumns: true,
        columns:[[
            {
                field: 'numeroCtes',
                title: '<input type="checkbox" name="nCtes" id="nCtes">',
                align: 'center',
                formatter: function(value, row, index) {
                    return '<input type="checkbox" class="numeroCtes'+index+'" value="'+index+'">';
                }
            },
            {
                field: 'numero', title: 'Nº do CT-e'
            },
            {
                field: 'serie', title: 'Série'
            },
            {
                field: 'frete', title: 'Frete'
            },
            {
                field: 'emissao', title: 'Emissão'
            },
            {
                field: 'remetente', title: 'Remetente'
            },
            {
                field: 'destinatario', title: 'Destinatário'
            },
            {
                field: 'total', title: 'Total', align: 'right'
            },
            {
                field: 'remove',
                title: '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',
                align: 'center',
                formatter: function(value, row, index) {
                    return '<a href="javascript:;" onClick="removeCte(\'' + row + '\')"><img src="assets/img/icon-remove.png"></a>';
                }
            }
        ]],
        onSelect: function(index, row){
            jQuery('#removeCte').removeClass("removeCteOff").addClass("removeCteOn");
            jQuery('.numeroCtes'+index).prop('checked', true);
        },
        onUnselect: function(index, row){
            if(jQuery('#tableInfo').datagrid("getSelected") == null || jQuery('#tableInfo').datagrid("getSelected") == undefined){
                jQuery('#removeCte').removeClass("removeCteOn").addClass("removeCteOff");
            }
            jQuery('.numeroCtes'+index).prop('checked', false);
        },
        onLoadSuccess: function(data) {

            if (data !== "" && heightDoc < 635) {
                jQuery('#footerTable').css('position', 'relative');
            }
        }
    });

    jQuery('.pagination td:nth-child(1), .pagination td:nth-child(2), .pagination td:nth-child(3), .pagination td:nth-child(5), .pagination td:nth-child(9), .pagination td:nth-child(11), .pagination td:nth-child(12), .pagination td:nth-child(13)').remove();

    jQuery.each(jQuery(".pagination tr"), function() { 
        jQuery(this).children(":eq(3)").after(jQuery(this).children(":eq(0)"));
    });

    jQuery(".footerTable input[type='radio']").click(function(){
        if(jQuery(this).is(':checked')){
            jQuery(".footerTable input[type='radio']").parent().css("color", "#a9aeb3");
            jQuery(this).parent().css("color", "#13385c");
        } 
    });

    jQuery('#nCtes').click(function(){
        if(jQuery(this).is(':checked')){
            jQuery('#removeCte').removeClass("removeCteOff").addClass("removeCteOn");
            jQuery('.datagrid-body').find("input[type='checkbox']").each(function(index){
                jQuery('.numeroCtes'+index).prop('checked', true);
            });
        } else{
            jQuery('#removeCte').removeClass("removeCteOn").addClass("removeCteOff");
            jQuery('.datagrid-body').find("input[type='checkbox']").each(function(index){
                jQuery('.numeroCtes'+index).prop('checked', false);
            });
        }
    });

    jQuery('.textbox-text').mask('00/00/0000');

    jQuery('.easyui-datebox').datebox({
        formatter : function(date){
            var y = date.getFullYear();
            var m = date.getMonth()+1;
            var d = date.getDate();
            return (d<10?('0'+d):d)+'/'+(m<10?('0'+m):m)+'/'+y;
        },
        parser : function(s){

            if (!s) return new Date();
            var ss = s.split('/');
            var y = parseInt(ss[2],10);
            var m = parseInt(ss[1],10);
            var d = parseInt(ss[0],10);
            if (!isNaN(y) && !isNaN(m) && !isNaN(d)){
                return new Date(y,m-1,d)
            } else {
                return new Date();
            }
        }
    });

    jQuery('.item_form_half1').find(".textbox-text").attr("placeholder", "Início");
    jQuery('.item_form_half2').find(".textbox-text").attr("placeholder", "Término");
});