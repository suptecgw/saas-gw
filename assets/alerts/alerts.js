/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var caminhoDaImgParaAlert = "";
var nomeUsuarioParaAlert  = "";

    /**
     * exemplo de chamada:
     * chamarAlert('texto a ser exibido',função a ser chamar após o alert(caso não passe parametro, nada será feito));
     */
    function chamarAlert(texto,funcao) {
        var funcaoObj = {} ;
        var tm = "";
        if (texto == undefined || texto == null) {
            texto = "";
        }else{
            texto = nomeUsuarioParaAlert+",<br>"+texto
        }
        var titulo = '<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';
        if (funcao == undefined || funcao== null) {
            funcaoObj.func = function(){};
        }else{
            funcaoObj.func = funcao;
        }
        tm = new BootstrapDialog({
            title: titulo,
            message: texto,
            draggable: false,
            closable: false,
            type: 'type-default',
            keyboard: true,
            buttons: [{
                    id: 'btn-cancel',   
                    label: 'OK',
                    hotkey: 13,
                    hotkeyTwo: 27,
                    cssClass: '', 
                    autospin: false,
                    action: function(dialogRef){    
                        funcaoObj.func();
                        dialogRef.close();
                        return false;
                    }
                }]
            });
            tm.realize();
            
            tm.open();
            
            return tm;
        }
        
        //
        function chamarConfirmeReLogin(texto,funcaoButton1,funcaoButton2) {
        var tm = "";
        if (texto == undefined || texto == null) {
            texto = "";
        }else{
            texto = nomeUsuarioParaAlert+",<br>"+texto
        }
        var titulo = '<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';
        
        tm = new BootstrapDialog({
            title: titulo,
            message: texto,
            draggable: false,
            closable: false,
            type: 'type-default',
            buttons: [{
                    id: 'btn-cancel',   
                    label: 'Ir para página de login',
                    cssClass: 'btn-primary', 
                    autospin: false,
                    action: function(dialogRef){    
                        dialogRef.close();
                        funcaoButton1();
                        return false;
                    }
                },{
                    id: 'btn-ok',   
                    label: 'Permanecer na página',
//                    hotkey: 13,
                    cssClass: 'btn-primary', 
                    keyboard: true,
                    autospin: false,
                    action: function(dialogRef){
                        dialogRef.close();
                        funcaoButton2();
                        return true;
                    }
                }]
            });
            tm.realize();
            
            tm.open();
            
            return tm;
        }
        
        
        /**
         * exemplo de chamada:
         * chamarPrompt('texto a ser exibido', função para receber o valor digitado no prompt)
         */
        function chamarPrompt(texto,metodo,tipoInput,metodoNao) {
            if (texto == undefined || texto == null) {
                texto = "";
            }else{
                texto = nomeUsuarioParaAlert+",<br>"+texto
            }
            if (tipoInput === undefined) {
                tipoInput = "text"
            }
            var titulo = '<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';
            texto = '<div>'+texto+' <input type="' + tipoInput + '" class="input-form-gw input-width-70" id="inputChamarPrompt" autocomplete="new-password"></div>';
            var tm = "";
            
            if (metodo == null || metodo == undefined || metodo == "") {
                metodo = "funcaoVaziaParaAlerts";
            }
            
            if (metodoNao == null || metodoNao == undefined || metodoNao == "") {
                metodoNao = "funcaoVaziaParaAlerts";
            }
        
        tm = new BootstrapDialog({
            title: titulo,
            message: texto,
            draggable: false,
            closable: false,
            type: 'type-default',
            buttons: [{
                    id: 'btn-cancel',   
                    label: 'NÃO',
                    cssClass: '', 
                    autospin: false,
                    action: function(dialogRef){
                        eval(metodoNao)();
                        dialogRef.close();
                        return false;
                    }
                },{
                    id: 'btn-ok',   
                    label: 'SIM',
                    hotkey: 13,
                    cssClass: 'btn-primary', 
                    keyboard: true,
                    autospin: false,
                    action: function(dialogRef){
                        eval(metodo)(document.getElementById("inputChamarPrompt").value);
                        dialogRef.close();
                        return true;
                    }
                }]
            });
            tm.realize();
            
            tm.open();
            
            return tm;
        }
        
        /**
         * exemplo de chamada:
         * chamarConfirm('texto a ser exibido',função a ser chamada caso o usuario click em 'SIM') // OBS: o 2 parametro só precisa passar o nome da função como string.
         */
        function chamarConfirm(texto,metodoSim,metodoNao,qtdTemCerteza,body) {
            var textoBody = (body == undefined || body == null || body == "" ? "" : '<div class="texto-alert" style="height:100px;overflow: auto;">'+body+'</div>' );
            if (texto == undefined || texto == null) {
                texto = "";
            }else{
                texto = '<div style="margin-bottom: 10px;">'+nomeUsuarioParaAlert+",</div>"+
                '<div style="margin-bottom: 5px;" >'+texto+'</div>'+textoBody;
            }
            var titulo = '<div id="teste" style=" cursor: pointer;float: right"><img src="'+caminhoDaImgParaAlert+'"> </div>';
            if (metodoNao == null || metodoNao == undefined || metodoNao == "") {
                metodoNao = "funcaoVaziaParaAlerts";
            }
            if (metodoSim == null || metodoSim == undefined || metodoSim == "") {
                metodoSim = "funcaoVaziaParaAlerts";
            }
            
            if(qtdTemCerteza == null || qtdTemCerteza == undefined || qtdTemCerteza == ""){
                qtdTemCerteza = 1;
        }
        
            var funcao = function(aceitar){if(aceitar){eval(metodoSim);}else{eval(metodoNao);}};
            
            BootstrapDialog.confirm(texto, titulo,function(aceitar){if(aceitar){chamarTemCerteza(titulo,funcao,qtdTemCerteza);}else{eval(metodoNao);}},'NÃO',"SIM");
            
        }
        //Ajustar caso seja maior que 1 a quantidade de tem certeza.
        function chamarTemCerteza(titulo,funcao,quantidadeConfirm){
            if(quantidadeConfirm == 1){
                BootstrapDialog.confirm('Tem certeza?', titulo,funcao,'NÃO',"SIM");
            }
        }
        
        function funcaoVaziaParaAlerts(){}