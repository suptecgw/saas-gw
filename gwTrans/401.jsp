<%-- 
    Document   : 401
    Created on : 02/12/2016, 18:05:12
    Author     : marcus
--%>

<%@page contentType="text/html" pageEncoding="ISO-8859-9"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-9">
        <title>GW Trans - 401</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <style>

            body,html{
                padding: 0;
                margin: 0;
                overflow: hidden;
            }

            .container-error{
                width: 100%;
                background: #0c253e;
                float: left;
                padding-top: 30px;
                padding-bottom: 30px;
                position: absolute;
                top: 50%;
                margin-top: -168.5px;
                -webkit-box-shadow: 0px 5px 3px 0px rgba(50, 50, 50, 0.75);
                -moz-box-shadow:    0px 5px 3px 0px rgba(50, 50, 50, 0.75);
                box-shadow:         0px 5px 3px 0px rgba(50, 50, 50, 0.75);
            }

            .erro{
                margin-left: 100px;
                color: #fff;
                font-size: 200px;
                width: 100%;
                font-weight: bold;
                text-shadow: 0px 2px 3px black;
                float: left;
                font-family: "Roboto", "Helvetica", "Arial", sans-serif;
            }

            .sem-acesso{
                margin-left: 100px;
                text-shadow: 0px 2px 3px black;
                font-family: "Roboto", "Helvetica", "Arial", sans-serif;
                font-weight: bold;
                font-size: 35px;
                float: left;
                color: #fff;
                width: 100%;
            }


            .container-logo{
                position: absolute;
                top: 10px;
                left: 30px;
            }

            .hr{
                width: 2px;
                height: 300px;
                position: absolute;
                background: #fff;
                top: 50%;
                left: 50%;
                margin-top: -150px;
                -webkit-box-shadow: 1px 0px 3px 0px rgba(255, 255, 255, 0.75);
                -moz-box-shadow:    1px 0px 3px 0px rgba(255, 255, 255, 0.75);
                z-index: 9999;
                box-shadow:         1px 0px 3px 0px rgba(255, 255, 255, 0.75);
            }

            .logo{
                position: absolute;
                top: 33%;
                left: 52%;
            }
        </style>
    </head>
    <body>
        <!--<div class="topo"></div>-->
        <!--        <div class="container-logo">
                    <center>
                        <img src="${homePath}/assets/img/logo.png" width="200px" alt=""/>
                    </center>
                </div>-->

        <div class="container-error">
            <div class="erro">
                401
            </div>
            <div class="sem-acesso">
                Acesso não autorizado
            </div>
        </div>
        <div class="hr"></div>
        <img src="${homePath}/assets/img/logo.png" width="200px" class="logo">
    </body>
</html>