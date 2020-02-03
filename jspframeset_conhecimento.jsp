<%@ page contentType="text/html; charset=iso-8859-1" language="java"
               import="nucleo.Apoio" errorPage="" %>


<% //Versao da MSA: 2.0, ATENCAO! Esta variável vai ser usada em todo o JSP para o teste de
   // privilégio de permissao. Ex.: if (nivelUser == 4) <-usuario pode excluir
   int nivelUser = (Apoio.getUsuario(request) != null
                    ? Apoio.getUsuario(request).getAcesso("cadconhecimento") : 0);
   //testando se a sessao é válida e se o usuário tem acesso
   if ((Apoio.getUsuario(request) == null) || (nivelUser == 0))
       this.getServletContext().getRequestDispatcher("/menu").forward(request, response);
   //fim da MSA
   
  String acao   = (request.getParameter("acao") == null ? "" : "?acao="+request.getParameter("acao") );
  //no caso de edicao
  String id = (request.getParameter("id") == null ? "" : "&id="+request.getParameter("id") );
  String ex    = (request.getParameter("ex") == null ? "" : "&ex="+request.getParameter("ex") );
%>
<script src="assets/js/jquery-1.9.1.min.js"></script>
<link href="estilo.css" rel="stylesheet">
<script language="javascript">
jQuery.noConflict();

jQuery(document).ready(function () {
    jQuery('html').append(jQuery('<div class="cobre-tudo">'));
    jQuery('html').append(jQuery('<div class="container-detalhes-ocorrencia">'));
});

//removendo parametros do session
    window.onbeforeunload = function(e) {
        sessionStorage.removeItem('parametros');
    };

//aualizando a numeracao das parcelas
function atualizaParcelas(){
  var i = 1;
  while (parent.frameAbaixo.document.getElementById("parcela"+i) != null)
  {
     var ob = parent.frameAbaixo.document.getElementById("parcela"+i);
     ob.value = parent.framePrincipal.document.getElementById("nfiscal").value + ob.value.substring(ob.value.indexOf("/"));
     ++i;
  }
}

var lastScroll;

function montarDetalhesOcorrencia(idCte, idOcorrencia, idOcorrenciaCtrc) {
    lastScroll = jQuery('body').scrollTop();
    jQuery('body').scrollTop(0);

    var object = jQuery('<object>').attr('width', '950').attr('height', '700').attr('data', 'gwTrans/modals/modal-detalhes-ocorrencia.jsp?idCte=' + idCte + '&idOcorrencia=' + idOcorrencia + '&idOcorrenciaCtrc=' + idOcorrenciaCtrc);
    jQuery('.container-detalhes-ocorrencia').html(object);

    jQuery('.cobre-tudo').show();
    jQuery('.container-detalhes-ocorrencia').show();
    jQuery("body").css("overflow", "hidden");

}

function finalizarOcorrencia() {
    jQuery('body').scrollTop(lastScroll);
    jQuery("body").css("overflow", "");
    jQuery('.cobre-tudo').hide();
    jQuery('.container-detalhes-ocorrencia').hide();
    jQuery('.container-detalhes-ocorrencia').html('');
}

function launchPDF(url, idname) {
    var cf = 'top=0,left=0,height=600,width=800,resizable=yes,status=1,scrollbars=1';
    var pdf = window.open(url, idname, cf);
    pdf.window.resizeTo(screen.width, screen.height - 20);
    pdf.focus();
}

function baixarRelatorioOcorrencia(idOcorrencia) {
    launchPDF('./RelatorioControlador?acao=imprimirRelatorioOcorrencia&modelo=1&id=' + idOcorrencia, 'ocorrencia' + idOcorrencia);
}
</script>


<title>Lançamento de CT-e - WebTrans</title>
<frameset onload="javascript:atualizaParcelas();" rows="5*,148" cols="*" framespacing="4" frameborder="YES" border="4" bordercolor="#9D4F00">
  <frame src="./cadconhecimento<%=(acao + id + ex)%>" name="framePrincipal" scrolling="yes">
  <frame src="./editor_parcela?acao=refazer&acao_conhecimento=<%=request.getParameter("acao")+id%>" name="frameAbaixo" scrolling="yes">
</frameset>
<noframes></noframes>
