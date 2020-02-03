!function(a){"use strict";var b=function(a){this.defaultOptions={id:b.newGuid(),type:b.TYPE_PRIMARY,size:b.SIZE_NORMAL,cssClass:"",width:"",footer:"",title:null,message:null,buttons:[],closable:!1,spinicon:b.ICON_SPINNER,data:{},onshow:null,onhide:null,autodestroy:!0,draggable:!1},this.indexedButtons={},this.registeredButtonHotkeys={},this.registeredButtonHotkeysTwo={},this.draggableData={isMouseDown:!1,mouseOffset:{}},this.realized=!1,this.opened=!1,this.initOptions(a),this.holdThisInstance()};b.NAMESPACE="bootstrap-dialog",b.TYPE_DEFAULT="type-primary",b.TYPE_INFO="type-info",b.TYPE_PRIMARY="type-primary",b.TYPE_SUCCESS="type-success",b.TYPE_WARNING="type-warning",b.TYPE_DANGER="type-danger",b.DEFAULT_TEXTS={},b.DEFAULT_TEXTS[b.TYPE_DEFAULT]="Mensagem",b.DEFAULT_TEXTS[b.TYPE_INFO]="Informa��o",b.DEFAULT_TEXTS[b.TYPE_PRIMARY]="Mensagem",b.DEFAULT_TEXTS[b.TYPE_SUCCESS]="Sucesso",b.DEFAULT_TEXTS[b.TYPE_WARNING]="Aten��o",b.DEFAULT_TEXTS[b.TYPE_DANGER]="Error",b.SIZE_NORMAL="size-normal",b.SIZE_LARGE="size-large",b.BUTTON_SIZES={},b.BUTTON_SIZES[b.SIZE_NORMAL]="",b.BUTTON_SIZES[b.SIZE_LARGE]="btn-lg",b.ICON_SPINNER="glyphicon glyphicon-asterisk",b.dialogs={},b.openAll=function(){a.each(b.dialogs,function(a,b){b.open()})},b.closeAll=function(){a.each(b.dialogs,function(a,b){b.close()})},b.prototype={constructor:b,initOptions:function(b){return this.options=a.extend(!0,this.defaultOptions,b),this},holdThisInstance:function(){return b.dialogs[this.getId()]=this,this},initModalStuff:function(){return this.setModal(this.createModal()).setModalDialog(this.createModalDialog()).setModalContent(this.createModalContent()).setModalHeader(this.createModalHeader()).setModalBody(this.createModalBody()).setModalFooter(this.createModalFooter()),this.getModal().append(this.getModalDialog()),this.getModalDialog().append(this.getModalContent()),this.getModalContent().append(this.getModalHeader()).append(this.getModalBody()).append(this.getModalFooter()),this},createModal:function(){var b=a('<div class=" modal fade" tabindex="-1"></div>');return b.prop("id",this.getId()),b},getModal:function(){return this.$modal},setModal:function(a){return this.$modal=a,this},createModalDialog:function(){var b=a('<div class="modal-dialog"></div>');return"lg"==this.options.width?b=a('<div class="modal-dialog modal-lg"></div>'):"sm"==this.options.width&&(b=a('<div class="modal-dialog modal-sm"></div>')),b},getModalDialog:function(){return this.$modalDialog},setModalDialog:function(a){return this.$modalDialog=a,this},createModalContent:function(){return a('<div class="modal-content "></div>')},getModalContent:function(){return this.$modalContent},setModalContent:function(a){return this.$modalContent=a,this},createModalHeader:function(){return a('<div class="modal-header"></div>')},getModalHeader:function(){return this.$modalHeader},setModalHeader:function(a){return this.$modalHeader=a,this},createModalBody:function(){return a('<div class="modal-body "></div>')},getModalBody:function(){return this.$modalBody},setModalBody:function(a){return this.$modalBody=a,this},createModalFooter:function(){var b=a('<div class="modal-footer "></div>');return""!=this.options.footer&&(b=a('<div class="modal-footer ">'+this.options.footer+"</div>")),b},getModalFooter:function(){return this.$modalFooter},setModalFooter:function(a){return this.$modalFooter=a,this},createDynamicContent:function(a){var b=null;return b="function"==typeof a?a.call(a,this):a},formatStringContent:function(a){return a.replace(/\r\n/g,"<br />").replace(/[\r\n]/g,"<br />")},setData:function(a,b){return this.options.data[a]=b,this},getData:function(a){return this.options.data[a]},setId:function(a){return this.options.id=a,this},getId:function(){return this.options.id},getType:function(){return this.options.type},setType:function(a){return this.options.type=a,this},getSize:function(){return this.options.size},setSize:function(a){return this.options.size=a,this},getCssClass:function(){return this.options.cssClass},setCssClass:function(a){return this.options.cssClass=a,this},getTitle:function(){return this.options.title},setTitle:function(a){return this.options.title=a,this.updateTitle(),this},updateTitle:function(){if(this.isRealized()){var a=null!==this.getTitle()?this.createDynamicContent(this.getTitle()):this.getDefaultText();this.getModalHeader().find("."+this.getNamespace("title")).html("").append(a)}return this},getMessage:function(){return this.options.message},setMessage:function(a){return this.options.message=a,this.updateMessage(),this},updateMessage:function(){if(this.isRealized()){var a=this.createDynamicContent(this.getMessage());this.getModalBody().find("."+this.getNamespace("message")).html("").append(a)}return this},isClosable:function(){return this.options.closable},setClosable:function(a){return this.options.closable=a,this.updateClosable(),this},getSpinicon:function(){return this.options.spinicon},setSpinicon:function(a){return this.options.spinicon=a,this},addButton:function(a){return this.options.buttons.push(a),this},addButtons:function(b){var c=this;return a.each(b,function(a,b){c.addButton(b)}),this},getButtons:function(){return this.options.buttons},setButtons:function(a){return this.options.buttons=a,this},getButton:function(a){return"undefined"!=typeof this.indexedButtons[a]?this.indexedButtons[a]:null},getButtonSize:function(){return"undefined"!=typeof b.BUTTON_SIZES[this.getSize()]?b.BUTTON_SIZES[this.getSize()]:""},isAutodestroy:function(){return this.options.autodestroy},setAutodestroy:function(a){this.options.autodestroy=a},getDefaultText:function(){return b.DEFAULT_TEXTS[this.getType()]},getNamespace:function(a){return b.NAMESPACE+"-"+a},createHeaderContent:function(){var b=a("<div></div>");return b.addClass(this.getNamespace("header")),b.append(this.createTitleContent()),b.append(this.createCloseButton()),b},createTitleContent:function(){var b=a("<div></div>");return b.addClass(this.getNamespace("title")),b},createCloseButton:function(){var b=a("<div></div>");b.addClass(this.getNamespace("close-button"));var c=a('<button class="close">X</button>');return b.append(c),b.on("click",{dialog:this},function(a){a.data.dialog.close()}),b},createBodyContent:function(){var b=a("<div></div>");return b.addClass(this.getNamespace("body")),b.append(this.createMessageContent()),b},createMessageContent:function(){var b=a("<div></div>");return b.addClass(this.getNamespace("message")),b},createFooterContent:function(){var b=a("<div></div>");return b.addClass(this.getNamespace("footer")),b.append(this.createFooterButtons()),b},createFooterButtons:function(){var c=this,d=a("<div></div>");return d.addClass(this.getNamespace("footer-buttons")),this.indexedButtons={},a.each(this.options.buttons,function(a,e){e.id||(e.id=b.newGuid());var f=c.createButton(e);c.indexedButtons[e.id]=f,d.append(f)}),d},createButton:function(b){var c=a('<button class="btn"></button>');return c.addClass(this.getButtonSize()),c.prop("id",b.id),void 0!==typeof b.icon&&""!==a.trim(b.icon)&&c.append(this.createButtonIcon(b.icon)),void 0!==typeof b.label&&c.append(b.label),void 0!==typeof b.cssClass&&""!==a.trim(b.cssClass)?c.addClass(b.cssClass):c.addClass("btn-default"),void 0!==typeof b.hotkey&&(this.registeredButtonHotkeys[b.hotkey]=c),void 0!==typeof b.hotkeyTwo&&(this.registeredButtonHotkeysTwo[b.hotkeyTwo]=c),c.on("click",{dialog:this,$button:c,button:b},function(a){var b=a.data.dialog,c=a.data.$button,d=a.data.button;"function"==typeof d.action&&d.action.call(c,b),d.autospin&&c.toggleSpin(!0)}),this.enhanceButton(c),c},enhanceButton:function(a){return a.dialog=this,a.toggleEnable=function(a){var b=this;return b.prop("disabled",!a).toggleClass("disabled",!a),b},a.enable=function(){var a=this;return a.toggleEnable(!0),a},a.disable=function(){var a=this;return a.toggleEnable(!1),a},a.toggleSpin=function(b){var c=this,d=c.dialog,e=c.find("."+d.getNamespace("button-icon"));return b?(e.hide(),a.prepend(d.createButtonIcon(d.getSpinicon()).addClass("icon-spin"))):(e.show(),a.find(".icon-spin").remove()),c},a.spin=function(){var a=this;return a.toggleSpin(!0),a},a.stopSpin=function(){var a=this;return a.toggleSpin(!1),a},this},createButtonIcon:function(b){var c=a("<span></span>");return c.addClass(this.getNamespace("button-icon")).addClass(b),c},enableButtons:function(b){return a.each(this.indexedButtons,function(a,c){c.toggleEnable(b)}),this},updateClosable:function(){return this.isRealized()&&this.getModalHeader().find("."+this.getNamespace("close-button")).toggle(this.isClosable()),this},onShow:function(a){return this.options.onshow=a,this},onHide:function(a){return this.options.onhide=a,this},isRealized:function(){return this.realized},setRealized:function(a){return this.realized=a,this},isOpened:function(){return this.opened},setOpened:function(a){return this.opened=a,this},handleModalEvents:function(){return this.getModal().on("show.bs.modal",{dialog:this},function(a){var b=a.data.dialog;"function"==typeof b.options.onshow&&b.options.onshow(b),b.showPageScrollBar(!0)}),this.getModal().on("hide.bs.modal",{dialog:this},function(a){var b=a.data.dialog;"function"==typeof b.options.onhide&&b.options.onhide(b)}),this.getModal().on("hidden.bs.modal",{dialog:this},function(b){var c=b.data.dialog;c.isAutodestroy()&&a(this).remove(),c.showPageScrollBar(!1)}),this.getModal().on("click",{dialog:this},function(a){a.target===this&&a.data.dialog.isClosable()&&a.data.dialog.close()}),this.getModal().on("keyup",{dialog:this},function(a){27===a.which&&a.data.dialog.isClosable()&&a.data.dialog.close()}),this.getModal().on("keyup",{dialog:this},function(b){var c=b.data.dialog;if("undefined"!=typeof c.registeredButtonHotkeys[b.which]){var d=a(c.registeredButtonHotkeys[b.which]);!d.prop("disabled")&&d.focus().trigger("click")}if("undefined"!=typeof c.registeredButtonHotkeysTwo[b.which]){var d=a(c.registeredButtonHotkeysTwo[b.which]);!d.prop("disabled")&&d.focus().trigger("click")}}),this},makeModalDraggable:function(){return this.options.draggable&&(this.getModalHeader().addClass(this.getNamespace("draggable")).on("mousedown",{dialog:this},function(a){var b=a.data.dialog;b.draggableData.isMouseDown=!0;var c=b.getModalContent().offset();b.draggableData.mouseOffset={top:a.clientY-c.top,left:a.clientX-c.left}}),this.getModal().on("mouseup mouseleave",{dialog:this},function(a){a.data.dialog.draggableData.isMouseDown=!1}),a("body").on("mousemove",{dialog:this},function(a){var b=a.data.dialog;b.draggableData.isMouseDown&&b.getModalContent().offset({top:a.clientY-b.draggableData.mouseOffset.top,left:a.clientX-b.draggableData.mouseOffset.left})})),this},showPageScrollBar:function(b){a(document.body).toggleClass("modal-open",b)},realize:function(){return this.initModalStuff(),this.getModal().addClass(b.NAMESPACE).addClass(this.getType()).addClass(this.getSize()).addClass(this.getCssClass()),this.getModalFooter().append(this.createFooterContent()),this.getModalHeader().append(this.createHeaderContent()),this.getModalBody().append(this.createBodyContent()),this.getModal().modal({backdrop:"static",keyboard:!0,show:!1}),this.makeModalDraggable(),this.handleModalEvents(),this.setRealized(!0),this.updateTitle(),this.updateMessage(),this.updateClosable(),this},open:function(){return!this.isRealized()&&this.realize(),this.getModal().modal("show"),this.setOpened(!0),this},close:function(){return this.getModal().modal("hide"),this.isAutodestroy()&&delete b.dialogs[this.getId()],this.setOpened(!1),this}},b.newGuid=function(){return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(a){var b=16*Math.random()|0,c="x"===a?b:3&b|8;return c.toString(16)})},b.show=function(a){return new b(a).open()},b.alert=function(a,c){return new b({message:a,data:{callback:c},closable:!1,buttons:[{label:"OK",action:function(a){"function"==typeof a.getData("callback")&&a.getData("callback")(!0),a.close()}}]}).open()},b.confirm=function(a,c,d,e,f){return void 0!=e&&null!=e||(e="Cancelar"),void 0!=f&&null!=f||(f="Sim"),void 0!=c&&null!=c||(c="Pergunta"),new b({title:c,message:a,closable:!1,data:{callback:d},keyboard:!1,buttons:[{label:e,hotkey:13,cssClass:"btn-primary",action:function(a){"function"==typeof a.getData("callback")&&a.getData("callback")(!1),a.close()}},{label:f,action:function(a){"function"==typeof a.getData("callback")&&a.getData("callback")(!0),a.close()}}]}).open()},b.init=function(){var a="undefined"!=typeof module&&module.exports;a?module.exports=b:"function"==typeof define&&define.amd?define("bootstrap-dialog",function(){return b}):window.BootstrapDialog=b},b.init()}(window.jQuery);