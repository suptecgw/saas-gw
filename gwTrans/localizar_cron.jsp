<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
        <link href="estilo.css" rel="stylesheet" type="text/css"></link>
        <link href="css/cron/jquery-cron.css" rel="stylesheet" type="text/css"></link>
        <link href="css/cron/jquery-gentleSelect.css" rel="stylesheet" type="text/css"></link>
        <!--<script language="JavaScript" src="script/cron/jquery-cron-min.js" type="text/javascript"></script>-->
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
        <script language="JavaScript" src="script/cron/jquery-cron.js"   type="text/javascript"></script>
        <script language="JavaScript" src="script/cron/jquery-gentleSelect-min.js"   type="text/javascript"></script>
        <!--<script language="JavaScript" src="script/cron/jquery-gentleSelect.js"   type="text/javascript"></script>-->
        <script type="text/javascript">
            try {
                $(document).ready(function() {
                    $('#selector-cron').cron({
                        initial: (window.opener.document.getElementById("${param.elemento}").value == "" ? "42 3 * * *" : window.opener.document.getElementById("${param.elemento}").value),
                        onChange: function() {
                            $('#selector-cron-val').val($(this).cron("value"));
                        }
                    });
                });
            } catch (e) { 
                console.log(e);
            }
            
            function retornaPai(){
                var pai = window.opener.document;
                
                if (pai.getElementById("${param.elemento}") != null) {
                    pai.getElementById("${param.elemento}").value = window.document.getElementById("selector-cron-val").value;
                }
                window.close();
            }

            if('${param.isRelatorio}' == 'true'){
            jQuery(document).ready(function(){
            var i = 0;
                    while(jQuery(jQuery(document.getElementsByName('cron-period')).find('option')[i]).val() != undefined && jQuery(jQuery(document.getElementsByName('cron-period')).find('option')[i]).val() != null){
                        if (jQuery(jQuery(document.getElementsByName('cron-period')).find('option')[i]).val() == 'minuto' ) {
                            jQuery(jQuery(document.getElementsByName('cron-period')).find('option')[i]).remove();
                        }
                        if (jQuery(jQuery(document.getElementsByName('cron-period')).find('option')[i]).val() == 'hora' ) {
                            jQuery(jQuery(document.getElementsByName('cron-period')).find('option')[i]).remove();
                        }
                        i++;
                    }
                });
            }
        </script>

        <title>Webtrans - Gerador de Momento de Execução</title>
    </head>
    <body>
        <img src="img/banner.gif" >
        <table class="bordaFina" width="50%" align="center">
            <tr>
                <td width="100%" align="left"><b>Gerador Cron</b></td>
                </td>
            </tr>
        </table>
        <br/>
        <table width="50%" align="center" class="bordaFina">
            <tbody>
                <tr class="CelulaZebra2NoAlign">
                    <td width="100%">
                        <div id='selector-cron'></div>
                    </td>
                </tr>
                <tr class="CelulaZebra2NoAlign">
                    <td>
                        <input type="hidden" value="" id="selector-cron-val" name="selector-cron-val" />
                        <input type="button" value="SELECIONAR" onclick="retornaPai();" class="botoes" />
                    </td>
                </tr>
            </tbody>
        </table>

    </body>

</html>
