var countOcorrenciaFornecedor = 0;
var idsExcluirOcorrencias = '';

function createElement(element, atributos, val) {
    let retorno;
    retorno = Object.assign(document.createElement(element), atributos);
    if (val && element === 'label'  && val !== 'null') {
        retorno.innerHTML = val;
    } else if (val) {
        retorno.value = val;
    }
    return retorno;
}

function createElementDate(element, atributos, val) {

    let retornoData = createElement(element, atributos, val);

    retornoData.setAttribute('onblur', 'alertInvalidDate(this, true)');
    retornoData.setAttribute('onkeypress', 'fmtDate(this, event)');
    retornoData.setAttribute('onkeyup', 'fmtDate(this, event)');
    retornoData.setAttribute('onkeydown', 'fmtDate(this, event)');

    return retornoData;
}

function createElementHora(element, atributos, val) {
    let retornoHora = createElement(element, atributos, val);
    retornoHora.setAttribute('onkeyup', 'mascaraHora(this)');
    return retornoHora;
}

function addDomOcorrencia(ocorrencia) {

    let _tabelaOcorrencia = document.querySelector('tbody #tbOcorrenciaForn');

    let _labelAs = createElement('label', {}, ' as ');

    let _trOcorrencia = createElement('tr', {
        className: 'celulaZebra2',
        id: 'trOcorrencia_' + countOcorrenciaFornecedor
    });

    let _img0 = createElement('img', {
        className: 'imagemLink',
        name: 'imgLixo',
        id: 'imgLixo',
        src: 'img/lixo.png'
    });

    _img0.setAttribute('onClick', 'excluirOcorrenciaPropietario(' + ocorrencia.idOcorrencia + ', this)');

    let _ocorrencia = createElement('label', {
        id: 'ocorrencia_' + countOcorrenciaFornecedor,
        width: '40%'
    }, ocorrencia.ocorrencia);

    let _idOcorrencia = createElement('input', {
        name: 'idOcorrencia_' + countOcorrenciaFornecedor,
        id: 'idOcorrencia_' + countOcorrenciaFornecedor,
        hidden: true
    }, ocorrencia.idOcorrencia);

    let _idOcorrenciaCTRC = createElement('input', {
        name: 'idOcorrenciaCTRC_' + countOcorrenciaFornecedor,
        id: 'idOcorrenciaCTRC_' + countOcorrenciaFornecedor,
        hidden: true
    }, ocorrencia.idOcorrenciaCTRC);

    let _dataInclusao = createElementDate('input', {
        id: 'dataInclusao_' + countOcorrenciaFornecedor,
        name: 'dataInclusao_' + countOcorrenciaFornecedor,
        className: 'fieldDate inputReadOnly8pt',
        size: '10',
        maxLength: '10'
    }, ocorrencia.dataInclusao);

    let _horaInclusao = createElementHora('input', {
        id: 'horaInclusao_' + countOcorrenciaFornecedor,
        name: 'horaInclusao_' + countOcorrenciaFornecedor,
        className: 'fieldDate inputReadOnly8pt',
        size: '4',
        maxLength: '5'
    }, ocorrencia.horaInclusao);

    let _dataOcorrencia = createElementDate('input', {
        id: 'dataOcorrencia_' + countOcorrenciaFornecedor,
        name: 'dataOcorrencia_' + countOcorrenciaFornecedor,
        className: 'fieldDate',
        onblur: "alertInvalidDate(this, true)",
        size: "10",
        maxlength: "10"
    }, ocorrencia.dataOcorrencia);

    let _horaOcorrencia = createElementHora('input', {
        id: 'horaOcorrencia_' + countOcorrenciaFornecedor,
        name: 'horaOcorrencia_' + countOcorrenciaFornecedor,
        className: 'inputtexto',
        size: "4",
        maxlength: "5"
    }, ocorrencia.horaOcorrencia);

    let _descricaoOcorrencia = createElement('textarea', {
        id: 'descricaoOcorrencia_' + countOcorrenciaFornecedor,
        name: 'descricaoOcorrencia_' + countOcorrenciaFornecedor,
        className: 'inputtexto',
        cols: '26',
        rows: '2'
    }, ocorrencia.descricaoOcorrencia);

    let _usuarioInclusao = createElement('label', {
        id: 'usuarioInclusao_' + countOcorrenciaFornecedor
    }, ocorrencia.usuarioInclusao);

    let _idUsuarioInclusao = createElement('input', {
        id: 'idUsuarioInclusao_' + countOcorrenciaFornecedor,
        name: 'idUsuarioInclusao_' + countOcorrenciaFornecedor,
        hidden: true
    }, ocorrencia.idUsuarioInclusao);

    let _resolvido = createElement('input', {
        id: 'resolvido_' + countOcorrenciaFornecedor,
        name: 'resolvido_' + countOcorrenciaFornecedor,
        className: 'resolvido',
        type: 'checkbox'
    }, ocorrencia.isResolvido);

    _resolvido.setAttribute('onclick', 'resolveuOcorrencia(' + countOcorrenciaFornecedor + ')');
    
    if (ocorrencia.resolvido === 'true') {
        _resolvido.checked = true;
    }
    
    let _dataResolucao = createElementDate('input', {
        className: 'fieldDate',
        id: 'dataResolucao_' + countOcorrenciaFornecedor,
        name: 'dataResolucao_' + countOcorrenciaFornecedor,
        size: "10",
        maxlength: "10"
    }, ocorrencia.resolvidoEm);

    let _horaResolucao = createElementHora('input', {
        className: 'inputtexto',
        id: 'horaResolucao_' + countOcorrenciaFornecedor,
        name: 'horaResolucao_' + countOcorrenciaFornecedor,
        size: "4",
        maxlength: "5"
    }, ocorrencia.resolvidoAs);

    let _descricaoResolucao = createElement('textarea', {
        id: 'descricaoResolucao_' + countOcorrenciaFornecedor,
        name: 'descricaoResolucao_' + countOcorrenciaFornecedor,
        className: 'inputtexto',
        cols: '26',
        rows: '2'
    }, ocorrencia.descricaoResolucao);

    let _usuarioResolucao = createElement('label', {
        id: 'usuarioResolucao_' + countOcorrenciaFornecedor
    }, ocorrencia.usuarioResolucao);

    let _idUsuarioResolucao = createElement('input', {
        id: 'idUsuarioResolucao_' + countOcorrenciaFornecedor,
        name: 'idUsuarioResolucao_' + countOcorrenciaFornecedor,
        hidden: true
    }, ocorrencia.idUsuarioResolucao);

    let _tdOcorrencia = createElement('td', {width: '10%'});
    let _tdDataHoraInclusao = createElement('td', {width: '10%'});
    let _tdDataHoraOcorrencia = createElement('td', {width: '10%'});
    let _tdDescricaoOcorrencia = createElement('td', {width: '10%'});
    let _tdUsuarioInclusao = createElement('td', {width: '10%'});
    let _tdResolvido = createElement('td', {width: '5%'});
    let _tdDataHoraResolucao = createElement('td', {width: '10%'});
    let _tdDescricaoResolucao = createElement('td', {width: '10%'});
    let _tdUsuarioResolucao = createElement('td', {width: '10%'});

    let _td0 = createElement("td", {
        align: "center"
    });

    _td0.appendChild(_img0);
    
    _asHoraResolucao = createElement('label', {}, ' às ');

    _tdOcorrencia.appendChild(_ocorrencia);
    _tdOcorrencia.appendChild(_idOcorrencia);
    _tdOcorrencia.appendChild(_idOcorrenciaCTRC);
    _tdDataHoraInclusao.appendChild(_dataInclusao);
    _tdDataHoraInclusao.appendChild(createElement('label', {}, ' às '));
    _tdDataHoraInclusao.appendChild(_horaInclusao);
    _tdDataHoraOcorrencia.appendChild(_dataOcorrencia);
    _tdDataHoraOcorrencia.appendChild(createElement('label', {}, ' às '));
    _tdDataHoraOcorrencia.appendChild(_horaOcorrencia);
    _tdDescricaoOcorrencia.appendChild(_descricaoOcorrencia);
    _tdUsuarioInclusao.appendChild(_usuarioInclusao);
    _tdUsuarioInclusao.appendChild(_idUsuarioInclusao);
    _tdResolvido.appendChild(_resolvido);
    _tdDataHoraResolucao.appendChild(_dataResolucao);
    _tdDataHoraResolucao.appendChild(_asHoraResolucao);
    _tdDataHoraResolucao.appendChild(_horaResolucao);
    _tdDescricaoResolucao.appendChild(_descricaoResolucao);
    _tdUsuarioResolucao.appendChild(_usuarioResolucao);
    _tdUsuarioResolucao.appendChild(_idUsuarioResolucao);

    _trOcorrencia.appendChild(_td0);
    _trOcorrencia.appendChild(_tdOcorrencia);
    _trOcorrencia.appendChild(_tdDataHoraInclusao);
    _trOcorrencia.appendChild(_tdDataHoraOcorrencia);
    _trOcorrencia.appendChild(_tdDescricaoOcorrencia);
    _trOcorrencia.appendChild(_tdUsuarioInclusao);
    _trOcorrencia.appendChild(_tdResolvido);
    _trOcorrencia.appendChild(_tdDataHoraResolucao);
    _trOcorrencia.appendChild(_tdDescricaoResolucao);
    _trOcorrencia.appendChild(_tdUsuarioResolucao);
    
    if (ocorrencia.obrigaResolucao === "f" || ocorrencia.obrigaResolucao === "false") {
        invisivel(_resolvido);
        invisivel(_dataResolucao);
        invisivel(_horaResolucao);
        invisivel(_descricaoResolucao);
        invisivel(_usuarioResolucao);
        invisivel(_asHoraResolucao);
    }

    _tabelaOcorrencia.appendChild(_trOcorrencia);

    countOcorrenciaFornecedor++;

    document.querySelector("#maxOcorrencia").value = countOcorrenciaFornecedor;
}

function addNovaOcorrencia(idUsuario, usuario, ocorrencia_id, ocorrencia, descricao_ocorrencia, dataAtual, horaAtual, obrigaResolucao) {
    let ocorrenciaFornecedor = new Ocorrencia;

    ocorrenciaFornecedor.idUsuarioInclusao = idUsuario;
    ocorrenciaFornecedor.usuarioInclusao = usuario;
    ocorrenciaFornecedor.ocorrencia = ocorrencia + ' - ' + descricao_ocorrencia;
    ocorrenciaFornecedor.dataInclusao = dataAtual;
    ocorrenciaFornecedor.horaInclusao = horaAtual;
    ocorrenciaFornecedor.idOcorrenciaCTRC = ocorrencia_id;
    ocorrenciaFornecedor.obrigaResolucao = obrigaResolucao;
    
    addDomOcorrencia(ocorrenciaFornecedor);
}

function excluirOcorrenciaPropietario(id, element) {
    let inputIdsExcluirOcorrencias = document.querySelector('#ocorrenciaExcluir');
    
    if (idsExcluirOcorrencias === '') {
        idsExcluirOcorrencias += id;
    } else {
        idsExcluirOcorrencias += "!!" + id;
    }

    inputIdsExcluirOcorrencias.value = idsExcluirOcorrencias;
    Element.remove(element.parentNode.parentNode.id);
}

function novaOcorrencia() {
    post_cad = window.open('./localiza?acao=consultar&idlista=40&paramaux=2', 'Ocorrencia_Ctrc',
            'top=80,left=150,height=400,width=700,resizable=yes,status=3,scrollbars=1');
}

function Ocorrencia(idOcorrencia, ocorrencia, dataInclusao, horaInclusao, dataOcorrencia, horaOcorrencia, descricaoOcorrencia, usuarioInclusao,
        resolvido, dataResolucao, horaResolucao, descricaoResolucao, UsuarioResolucao, idOcorrenciaCTRC, idUsuarioInclusao, idUsuarioResolucao, obrigaResolucao) {
    this.idOcorrencia;
    this.ocorrencia;
    this.dataInclusao;
    this.horaInclusao;
    this.dataOcorrencia;
    this.horaOcorrencia;
    this.descricaoOcorrencia;
    this.usuarioInclusao;
    this.idUsuarioInclusao;
    this.resolvido;
    this.dataResolucao;
    this.horaResolucao;
    this.descricaoResolucao;
    this.UsuarioResolucao;
    this.idUsuarioResolucao;
    this.idOcorrenciaCTRC;
    this.obrigaResolucao;
}
