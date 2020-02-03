var div = document.getElementById("container-upload");
var input = document.getElementById("input-perfil-upload");

div.addEventListener("click", function () {
    input.click();
});

var jcrop_api;
//    set instance to our var
$('#img-resize').Jcrop({
    aspectRatio: 1,
    setSelect: [50, 0, 300, 300],
    allowResize: false
}, function () {
    jcrop_api = this;
});

//change image for instance

jQuery(document).ready(function () {

    function FileFrame(fileArea, fileTitle) {
        var self = this;
        this.fileArea = fileArea;
        this.fileTitle = fileTitle;
        this.init = function () {
            // Registrando eventos de drag and drop
            self.fileArea.addEventListener("dragleave", self.dragHover, false);
            self.fileArea.addEventListener("dragover", self.dragHover, false);
            self.fileArea.addEventListener("drop", self.drop, false);
        };
        this.dragHover = function (e) {
            // Impede possíveis tratamentos dos arquivos
            // arrastados pelo navegador, por exemplo, exibir
            // o conteudo do mesmo.
            e.stopPropagation();
            e.preventDefault();
            // Quando o arquivo está sobre área alteramos o seu estilo
            self.fileArea.className = (e.type == "dragover" ? "hover" : "");
        };
        this.drop = function (e) {
            self.dragHover(e);
            self.file = e.dataTransfer.files[0];
            // Recupera nome do arquivo
            self.fileTitle.innerHTML = self.file.name;
            self.read(self.file);
        };
        this.read = function (file) {
            if (file.type.match('image.*')) {
                var reader = new FileReader();
                reader.onload = function (f) {
                    self.fileArea.innerHTML = "";
                    self.fileArea.setAttribute("style", "padding: 0px !important;");
                    jcrop_api.destroy();
                    var img = document.getElementById("img-resize");
//                        img.setAttribute("height", "400");
//                        img.setAttribute("width", "580");
                    img.setAttribute("src", f.target.result);
                    img.setAttribute("height", "400");
                    img.setAttribute("width", "580");
                    $(img).css("width", "");
                    $(img).css("height", "");
                    $('#img-resize').Jcrop({
                        aspectRatio: 1,
                        setSelect: [50, 0, 300, 300],
                        allowResize: false,
                        allowSelect: false,
                        bgOpacity: 0.3,
                        onSelect: updateCoords
                    }, function () {
                        jcrop_api = this;
                    });
                };
                // Irá ler o arquivo para ser acessado através de uma url
                reader.readAsDataURL(file);
            }
        };
    }

    function updateCoords(c) {
        $('#x').val(c.x);
        $('#y').val(c.y);
        $('#w').val(c.w);
        $('#h').val(c.h);
    }
    ;
    jQuery('.btn-cancelar-foto-perfil').click(function (e) {
        if (jQuery('.div-input-file').size() === 0) {
            montarDivFotoPerfil();
        }
    });
    jQuery('#fechar-img-upload').click(function (e) {
        if (jQuery('.div-input-file').size() === 0) {
            montarDivFotoPerfil();
        }
    });
    function montarDivFotoPerfil() {
        var cont = document.getElementById("container-upload");
        jcrop_api.destroy();
        var img = document.getElementById('img-resize');
        img.setAttribute('src', '');
        img.setAttribute('width', '1px');
        img.setAttribute('height', '1px');
        $(img).css("width", "");
        $(img).css("height", "");
        $(img).css("display", "none");
        $(cont).append('<center><img src="assets/img/upload.png" width="300px" height="200px" style="margin-top:10px;opacity: 0.5;"><div style="margin-top: 20px;"><label style="font-size: 30px;font-weight: bold;margin-top:10px;color:#999;">Arraste uma foto de perfil para cá</label><br><label style="font-size: 25px;font-weight: bold;margin-top: 10px;color: #999;">- ou -</label><br><div class="div-input-file">Selecionar uma foto</div><span id="testa"></span></div></center>');
    }

    var area = document.getElementById("container-upload");
    var title = document.getElementById("testa");
    var fileFrameArea = new FileFrame(area, title);
    fileFrameArea.init();
    function gtEl(id) {
        return document.getElementById(id);
    }

    function readFile() {
        if (this.files && this.files[0]) {
            var f = this.files[0];
            var FR = new FileReader();
            FR.onload = function (e) {
                if (f.type.match('image.*')) {

                    area.innerHTML = "";
                    area.setAttribute("style", "padding: 0px !important;");
                    jcrop_api.destroy();
                    var img = document.getElementById("img-resize");
                    img.setAttribute("src", e.target.result);
                    img.setAttribute("height", "400");
                    img.setAttribute("width", "580");
                    $(img).css("width", "");
                    $(img).css("height", "");
                    $('#img-resize').Jcrop({
                        aspectRatio: 1,
                        setSelect: [50, 0, 300, 300],
                        allowResize: false,
                        allowSelect: false,
                        bgOpacity: 0.3,
                        onSelect: updateCoords
                    }, function () {
                        jcrop_api = this;
                    });
                } else {
                    chamarAlert('Extensão do arquivo de imagem inválida!', null);
                }
            };
            FR.readAsDataURL(this.files[0]);
        }
    }

    gtEl("input-perfil-upload").addEventListener("change", readFile, false);
    jQuery('.mudar-foto').click(function (event) {
        event.preventDefault();
        if (jQuery('.div-alterar-imagem-perfil').css('display') === "none") {
            jQuery('.cobre-tudo').css('display', 'block');
            jQuery('.div-alterar-imagem-perfil').css('display', 'block');
        } else {
            jQuery('.cobre-tudo').css('display', 'none');
            jQuery('.div-alterar-imagem-perfil').css('display', 'none');
        }
    });
    jQuery('.perfil-user').click(function (event) {
        if (jQuery('.opcoes-perfil').css('display') === "none") {
            jQuery('.opcoes-perfil').css('display', 'block');
            jQuery('.seta-perfil').css('display', 'block');
            jQuery('.seta-perfil-sombra').css('display', 'block');
            jQuery('#cobre-tudo-perfil').css('display', 'block');
            jQuery('#cobre-tudo-perfil').css('z-index', '999');
            jQuery('#cobre-tudo-perfil').css('background', 'rgba(255,255,255,0.1)');
        } else {
            jQuery('.opcoes-perfil').css('display', 'none');
            jQuery('.seta-perfil').css('display', 'none');
            jQuery('.seta-perfil-sombra').css('display', 'none');
            jQuery('#cobre-tudo-perfil').css('display', 'none');
        }
    });
    jQuery('#cobre-tudo-perfil').click(function () {
        if (jQuery('.opcoes-perfil').css('display') === "block") {
            jQuery('.opcoes-perfil').css('display', 'none');
            jQuery('.seta-perfil').css('display', 'none');
            jQuery('.seta-perfil-sombra').css('display', 'none');
            jQuery('#cobre-tudo-perfil').css('display', 'none');
        }
    });
    jQuery('.btn-cancelar-foto-perfil').click(function (event) {
        if (jQuery('.div-alterar-imagem-perfil').css('display') === "none") {
            jQuery('.cobre-tudo').css('display', 'block');
            jQuery('.div-alterar-imagem-perfil').css('display', 'block');
        } else {
            jQuery('.cobre-tudo').css('display', 'none');
            jQuery('.div-alterar-imagem-perfil').css('display', 'none');
        }
    });
    jQuery('#fechar-img-upload').click(function () {
        if (jQuery('.div-alterar-imagem-perfil').css('display') === "none") {
            jQuery('.cobre-tudo').css('display', 'block');
            jQuery('.div-alterar-imagem-perfil').css('display', 'block');
        } else {
            jQuery('.cobre-tudo').css('display', 'none');
            jQuery('.div-alterar-imagem-perfil').css('display', 'none');
        }
    });
});