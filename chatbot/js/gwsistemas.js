var changeBubble = null;

document.addEventListener("DOMContentLoaded", function(){

    /*Variável que define se o bot está em manutenção ou desativado*/
    var maintenance = false;
    /*Variável que define a chave de integração com o BlipChat*/
    var key = "Z3djaGF0MzoxNTY3ZTk0My1jYWQ2LTQxZmItYWU4Zi00YTM1NDk5ZjlhNTg=";
    /*Variáveis que definem as imagens que serão exibidas no campo de ícone do chatbot*/
    var imageAvatar = "chatbot/img/logo.png";
    var imageChat = "chatbot/img/icone_chat.png";
    /*Variável que define a mensagem padrão do widget posso ajudar?*/
    var messageHelp = "Olá, posso te ajudar?";
    /*Variável que define o tempo de exibição do widget posso ajudar?*/
    var timeHelp = 10000;
    /*Variáveis que definem o tempo de abertura do chat no computador e os momentos de ativação*/
    var viewPc = true;
    var openPc = 100;
    var closePc = 300;
    var activeStartPc = true;
    var startPc = 10000;
    /*Variáveis que definem o tempo de abertura do chat no celular e os momentos de ativação*/
    var viewMobile = true;
    var openMobile = 100;
    var closeMobile = 500;
    var activeStartMobile = true;
    var startMobile = 10000;
    /*Variável que define a mensagem padrão do widget flutuante*/
    var messageSend = "COMEÇAR";

    var client = new BlipChat();

    var bubble;
    var bubbleContainer;
    var closeIcon;

    const appKey = key;

    const bottomImage = imageAvatar;
    const topImage = imageChat;

    const bubbleMessage = messageHelp;

    const startMessage = {
        type: "text/plain",
        content: messageSend,
        metadata: {
            "#blip.hiddenMessage": true
        }
    }

    const iconId = "blip-chat-icon";
    const closeId = "blip-chat-close-icon";
    const chatContainer = "blip-chat-container";

    const startingColor = "#ffffff";
    const displayClassName = "display";
    const hideClassName = "hide";

    function displayBubble(){
        bubble.classList.add(displayClassName);
        bubble.classList.remove(hideClassName);
    }

    function hideBubble(){
        bubble.classList.add(hideClassName);
        bubble.classList.remove(displayClassName);
    }

    changeBubble = function () {
        if (bubble.classList.contains(displayClassName))
            hideBubble();
        else
            displayBubble();
    }

    function createBubble(){

        bubbleContainer = document.createElement("div");
        bubbleContainer.id = "bubble-container";

        bubble = document.createElement("div");
        bubble.id = "message-bubble";
        bubble.onclick = function(){ client.widget._openChat() }

        var triangle = document.createElement("div");
        triangle.id = "triangle";

        var message = document.createElement("div");
        message.id = "message";
        message.innerHTML = bubbleMessage;

        bubble.appendChild(message);
        bubble.appendChild(triangle);
        bubbleContainer.appendChild(bubble);

        document
        .querySelector(`#${chatContainer}`)
        .prepend(bubbleContainer);

    }

    function replaceImageStructure() {

        closeIcon = document.querySelector(`#${closeId}`);
        var oldImage = document.querySelector(`#${iconId}`);

        var container = document.createElement("div");
        container.id = iconId;

        var img1 = document.createElement("img");
        img1.src = topImage;
        img1.classList.add("top")

        var img2 = document.createElement("img");
        img2.src = bottomImage;
        img2.classList.add("bottom");

        container.appendChild(img1);
        container.appendChild(img2);

        oldImage.parentElement.insertBefore(container, oldImage);
        oldImage.remove();

    }

    client
    .withAppKey(appKey)
    .withButton({ color: startingColor })
    .withEventHandler(BlipChat.CREATE_ACCOUNT_EVENT, function(){
        client.sendMessage(startMessage);
    })
    .withEventHandler(BlipChat.LEAVE_EVENT, function () {
        closeIcon.classList.add(hideClassName);
        closeIcon.classList.remove(displayClassName);
    })
    .build();

    var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
    if(!isMobile){
      window.setTimeout(function() { client.toogleChat() }, openPc);
      window.setTimeout(function() { client.toogleChat() }, closePc);
      if(activeStartPc){
        window.setTimeout(function() { client.toogleChat() }, startPc);
      }
    }
    if(isMobile){
      window.setTimeout(function() { client.toogleChat() }, openMobile);
      window.setTimeout(function() { client.toogleChat() }, closeMobile);
      if(activeStartMobile){
        window.setTimeout(function() { client.toogleChat() }, startMobile);
      }
    }
    if(maintenance){
      client.destroy();
    }

    replaceImageStructure();
    createBubble();

    displayBubble();
    setTimeout(function(){
        hideBubble();
    }, timeHelp);

});