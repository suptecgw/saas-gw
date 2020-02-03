let carregado = false;
let telaId = 0;
let blip;
let blipLeft = 0;
let blipTop = 0;

let draggable = false;
let carregarPosicao = false;

// Bubble
const bubbleMessage = "Ol&aacute;, posso te ajudar?";
let bubble;
let bubbleContainer;
let closeIcon;

function displayBubble() {
    bubble.classList.add("display");
    bubble.classList.remove("hide")
}

function hideBubble() {
    bubble.classList.add("hide");
    bubble.classList.remove("display")
}

function changeBubble() {
    if (bubble.classList.contains("display")) {
        hideBubble();
    } else {
        displayBubble()
    }
}

function createBubble() {
    bubbleContainer = document.createElement("div");
    bubbleContainer.id = "bubble-container";
    bubble = document.createElement("div");
    bubble.id = "message-bubble";
    bubble.onclick = function () {
        blip.widget._openChat()
    };
    let triangle = document.createElement("div");
    triangle.id = "triangle";
    let message = document.createElement("div");
    message.id = "message";
    message.innerHTML = bubbleMessage;
    bubble.appendChild(message);
    bubble.appendChild(triangle);
    bubbleContainer.appendChild(bubble);
    document.querySelector('#blip-chat-container').prepend(bubbleContainer);
}

function replaceImageStructure() {
    closeIcon = document.querySelector("#blip-chat-close-icon");
    let oldImage = document.querySelector("#blip-chat-icon");
    let container = document.createElement("div");
    container.id = "blip-chat-icon";
    let img1 = document.createElement("img");
    img1.src = "chatbot/img/sofia.png";
    img1.classList.add("top");
    let img2 = document.createElement("img");
    img2.src = "chatbot/img/sofia.png";
    img2.classList.add("bottom");
    container.appendChild(img1);
    container.appendChild(img2);
    oldImage.parentElement.insertBefore(container, oldImage);
    oldImage.remove()
}

function atualizarPosicaoAjuda() {
    jQuery(bubbleContainer).css('top', (jQuery(window).height() - jQuery('#blip-chat-open-iframe').offset().top - 60 - 50) * -1)
        .css('left', (jQuery(window).width() - jQuery('#blip-chat-open-iframe').offset().left - 60 - 30) * -1);
}

function configurarChatBlip(chaveAppBlip, _telaId, usuario, filial, isDraggable, isCarregarPosicao, parametrosExtra = {}) {
    telaId = _telaId;
    draggable = isDraggable;
    carregarPosicao = isCarregarPosicao;

    var randomId = 2;
    window.setInterval(function(){
        randomId++;
    },1000);
    
    let extra = Object.assign({}, {
        'Empresa': filial['razao_social'],
        'CNPJ': filial['cnpj'],
        'versao': filial['versao']
    }, parametrosExtra);

    blip = new BlipChat()
        .withAppKey(chaveAppBlip)
        .withAuth({
            authType: BlipChat.DEV_AUTH,
            userIdentity: usuario['id'] + '-' + filial['cnpj'],
            userPassword: filial['cnpj'],
        })
        .withAccount({
            fullName: usuario['nome'],
            email: usuario['email'],
            phoneNumber: filial['telefone'],
            city: filial['cidade'],
            extras: extra
        })
        .withButton({
            'color': '#13385C',
            'icon': 'https://s3.amazonaws.com/gwVersoes/gwChatbot/icone_temporario.png'
        }).withEventHandler(BlipChat.ENTER_EVENT, function () {
            closeIcon.classList.add('display');
            closeIcon.classList.remove('hide');
            if (carregado) {
                hideBubble();
            }
        }).withEventHandler(BlipChat.LEAVE_EVENT, function () {
            closeIcon.classList.add('hide');
            closeIcon.classList.remove('display')
        }).withEventHandler(BlipChat.LOAD_EVENT, function () {
            blip.sendCommand({
                "id": randomId,
                "method": "set",
                "uri": "/contacts",
                "type": "application/vnd.lime.contact+json",
                "resource": {
                    "identity": "usuario['id']+'-'+filial['cnpj'].recepcao5@0mn.io",
                    "fullName": usuario['nome'],
                    "email": usuario['email'],
                    "phoneNumber": filial['telefone'],
                    "extras": {
                        "versao": filial['versao']
                    }
                }
            });
            console.log('chat loaded')
        });

    jQuery(window).on('resize', function () {
        if (isOutOfViewport(document.getElementById('blip-chat-open-iframe')).any) {
            // Reiniciando a posição do ícone do chatbot, pois o ícone está fora da janela.
            // Possivelmente por causa da resolução da tela, ou o tamanho da janela.
            jQuery('#blip-chat-open-iframe').css('top', '').css('left', '');
        }

        
        atualizarPosicaoAjuda();
    });
}

function executarChatBlip() {
    if (draggable) {
        let promise;
        if (carregarPosicao) {
            promise = jQuery.when(
                blip.build(),

                // Obter posições do ícone
                jQuery.get(homePath + '/BlipControlador', {
                    'acao': 'obterConfiguracoes',
                    'tela_id': telaId
                }, function (data) {
                    if (data) {
                        if (data['posicao_top'] !== undefined && data['posicao_left'] !== undefined) {
                            let elem = jQuery('#blip-chat-open-iframe');

                            elem.css('top', data['posicao_top']).css('left', data['posicao_left']);

                            if (isOutOfViewport(document.getElementById('blip-chat-open-iframe')).any) {
                                // Reiniciando a posição do ícone do chatbot, pois o ícone está fora da janela.
                                // Possivelmente por causa da resolução da tela, ou o tamanho da janela.
                                elem.css('top', '').css('left', '');
                            } else {
                                atualizarPosicoes(data['posicao_top'], data['posicao_left']);
                            }
                        }
                    }
                }, 'json')
            );
        } else {
            promise = jQuery.when(blip.build());
        }

        promise.then(function () {
            jQuery('#blip-chat-open-iframe').draggable({
                start: function () {
                    hideBubble();
                    document.getElementById('blip-chat-open-iframe').removeEventListener('click', blip.widget._openChat)
                },
                drag: function (e, ui) {
                    atualizarPosicoes(ui.offset.top, ui.offset.left);
                },
                stop: function () {
                    setTimeout(function () {
                        document.getElementById('blip-chat-open-iframe').addEventListener('click', blip.widget._openChat)
                    }, 100);

                    if (carregarPosicao) {
                        // Salvar no banco de dados as novas posições
                        salvarPosicao();
                    }
                }
            });

            var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);

            if (!isMobile) {
                window.setTimeout(() => blip.widget._openChat(), 100);
                window.setTimeout(() => {blip.widget._openChat(); carregado = true}, 300);
            } else {
                window.setTimeout(() => blip.widget._openChat(), 100);
                window.setTimeout(() => {blip.widget._openChat(); carregado = true}, 500);
            }
    
            replaceImageStructure();
            createBubble();
            atualizarPosicaoAjuda();
            displayBubble();
            setTimeout(function () {
                hideBubble()
            }, 20000)
        });
    } else {
        blip.build();
    }
}

function atualizarPosicoes(top, left) {
    let iframeBlip = jQuery('#blip-chat-iframe');

    let screenHeight = (window.outerHeight - 250) + 20;

    if (screenHeight > 610) {
        screenHeight = 610 + 20;
    }

    const screenWidth = 400 - 45;

    if (iframeBlip.length !== 0) {
        // Mover a div container
        blipTop = top;
        blipLeft = left;

        iframeBlip.css('bottom', 0).css('right', 0).css('top', top - screenHeight).css('left', (left) - screenWidth);
    } else {
        // Adicionar estilo CSS
        blipTop = top;
        blipLeft = left;

        jQuery('#posicaoBlip').html('#blip-chat-iframe { bottom: 0 !important; right: 0 !important; top: ' + (top - screenHeight) + 'px; left: ' + ((left) - screenWidth) + 'px; }');
    }
}

const salvarPosicao = _.throttle(function () {
    jQuery.post(homePath + '/BlipControlador', {
        'acao': 'salvarConfiguracoes',
        'tela_id': telaId,
        'posicao_left': blipLeft,
        'posicao_top': blipTop
    });
}, 2000);

/*!
 * Check if an element is out of the viewport
 * https://gomakethings.com/how-to-check-if-any-part-of-an-element-is-out-of-the-viewport-with-vanilla-js/
 * (c) 2018 Chris Ferdinandi, MIT License, https://gomakethings.com
 * @param  {Node}  elem The element to check
 * @return {Object}     A set of booleans for each side of the element
 */
let isOutOfViewport = function (elem) {

    // Get element's bounding
    let bounding = elem.getBoundingClientRect();

    // Check if it's out of the viewport on each side
    let out = {};
    out.top = bounding.top < 0;
    out.left = bounding.left < 0;
    out.bottom = bounding.bottom > (window.innerHeight || document.documentElement.clientHeight);
    out.right = bounding.right > (window.innerWidth || document.documentElement.clientWidth);
    out.any = out.top || out.left || out.bottom || out.right;
    out.all = out.top && out.left && out.bottom && out.right;

    return out;

};
