function chamarAlert(a,b){var c={},d="";a=void 0==a||null==a?"":nomeUsuarioParaAlert+",<br>"+a;var e='<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';return void 0==b||null==b?c.func=function(){}:c.func=b,d=new BootstrapDialog({title:e,message:a,draggable:!1,closable:!1,type:"type-default",keyboard:!0,buttons:[{id:"btn-cancel",label:"OK",hotkey:13,hotkeyTwo:27,cssClass:"",autospin:!1,action:function(a){return c.func(),a.close(),!1}}]}),d.realize(),d.open(),d}function chamarConfirmeReLogin(a,b,c){var d="";a=void 0==a||null==a?"":nomeUsuarioParaAlert+",<br>"+a;var e='<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';return d=new BootstrapDialog({title:e,message:a,draggable:!1,closable:!1,type:"type-default",buttons:[{id:"btn-cancel",label:"Ir para p�gina de login",cssClass:"btn-primary",autospin:!1,action:function(a){return a.close(),b(),!1}},{id:"btn-ok",label:"Permanecer na p�gina",cssClass:"btn-primary",keyboard:!0,autospin:!1,action:function(a){return a.close(),c(),!0}}]}),d.realize(),d.open(),d}function chamarPrompt(texto,metodo,tipoInput,metodoNao){texto=void 0==texto||null==texto?"":nomeUsuarioParaAlert+",<br>"+texto;tipoInput=void 0==tipoInput||null==tipoInput?"text":tipoInput;var titulo='<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';texto="<div>"+texto+' <input type="'+ tipoInput + '" class="input-form-gw input-width-70" id="inputChamarPrompt" autocomplete="new-password"></div>';var tm="";return null!=metodo&&void 0!=metodo&&""!=metodo||(metodo="funcaoVaziaParaAlerts"),null!=metodoNao&&void 0!=metodoNao&&""!=metodoNao||(metodoNao="funcaoVaziaParaAlerts"),tm=new BootstrapDialog({title:titulo,message:texto,draggable:!1,closable:!1,type:"type-default",buttons:[{id:"btn-cancel",label:"N�O",cssClass:"",autospin:!1,action:function(a){return eval(metodoNao)(),a.close(),!1}},{id:"btn-ok",label:"SIM",hotkey:13,cssClass:"btn-primary",keyboard:!0,autospin:!1,action:function(dialogRef){return eval(metodo)(document.getElementById("inputChamarPrompt").value),dialogRef.close(),!0}}]}),tm.realize(),tm.open(),tm}function chamarConfirm(texto,metodoSim,metodoNao,qtdTemCerteza,body){var textoBody=void 0==body||null==body||""==body?"":'<div class="texto-alert" style="height:100px;overflow: auto;">'+body+"</div>";texto=void 0==texto||null==texto?"":'<div style="margin-bottom: 10px;">'+nomeUsuarioParaAlert+',</div><div style="margin-bottom: 5px;" >'+texto+"</div>"+textoBody;var titulo='<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';null!=metodoNao&&void 0!=metodoNao&&""!=metodoNao||(metodoNao="funcaoVaziaParaAlerts"),null!=metodoSim&&void 0!=metodoSim&&""!=metodoSim||(metodoSim="funcaoVaziaParaAlerts"),null!=qtdTemCerteza&&void 0!=qtdTemCerteza&&""!=qtdTemCerteza||(qtdTemCerteza=1);var funcao=function(aceitar){aceitar?eval(metodoSim):eval(metodoNao)};BootstrapDialog.confirm(texto,titulo,function(aceitar){aceitar?chamarTemCerteza(titulo,funcao,qtdTemCerteza):eval(metodoNao)},"N�O","SIM")}function chamarTemCerteza(a,b,c){1==c&&BootstrapDialog.confirm("Tem certeza?",a,b,"N�O","SIM")}function funcaoVaziaParaAlerts(){}var caminhoDaImgParaAlert="",nomeUsuarioParaAlert="";