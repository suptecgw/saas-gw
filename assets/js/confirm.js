/*
 * SimpleModal desconectar Modal Dialog
 * http://simplemodal.com
 *
 * Copyright (c) 2013 Eric Martin - http://ericmmartin.com
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 */

jQuery(function ($) {
	$('#desconectar-dialog input.desconectar, #desconectar-dialog a.desconectar').click(function (e) {
		e.preventDefault();

		// example of calling the desconectar function
		// you must use a callback function to perform the "yes" action
		chamarConfirm("Deseja mesmo sair ?", 'efetuarLogOff();');
                
	});
});

function efetuarLogOff(){
    location.replace("./menu?acao=sair");
}

function desconectar(message, callback) {
	$('#desconectar').modal({
		closeHTML: "<a href='#' title='Close' class='modal-close'>x</a>",
		position: ["20%",],
		overlayId: 'desconectar-overlay',
		containerId: 'desconectar-container',
		onShow: function (dialog) {
			var modal = this;

			$('.message', dialog.data[0]).append(message);

			// if the user clicks "yes"
			$('.yes', dialog.data[0]).click(function () {
				// call the callback
				if ($.isFunction(callback)) {
					callback.apply();
				}
				// close the dialog
				modal.close(); // or $.modal.close();
			});
		}
	});
}