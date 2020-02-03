<script type="text/javascript" src="./script/prototype.js"> </script>

<script>
function teste(){
    var resultado = "<option value='0'>Nenhum</option>";
        resultado += "<option value='1'>CARGA FRIA</option>";
        resultado += "<option value='2'>CARGA SECA</option>";
        resultado += "<option value='3'>OUTBOND</option>";
    //alert(resultado);
    var select = document.getElementById('slTeste');
    Element.update(select, "<option value=0>Nenhum</option>");
//    $('slTeste').update('kiwi, banana and apple');
   // alert('oi');

    //$('fruits').update("kiwi, banana and apple");
    Element.update($('fruits'), "kiwi, banana and apple");


}
    
</script>

<html>
    <head>
        <title>Ler Arquivo TXT com Javascript</title>
    </head>
    <body>
        <form id="formImagem" name="formImagem" method="post" action="ServletUpload" enctype="multipart/form-data">
          <select name="slTeste" id="slTeste">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
          </select>
          <input type="button" name="Button" value="Button" onClick="teste();">
          <label id="fruits">carrot, eggplant and cucumber</label>
        </form>    
    </body>
</html>