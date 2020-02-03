var countOcorrenciaMotorista = 0;
var idsExcluirOcorrencias = '';

function createElement(element, atributos, val) {
    let retorno;
    retorno = Object.assign(document.createElement(element), atributos, val);
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
    let retornoHota = createElement(element, atributos, val);
    retornoHota.setAttribute('onkeyup', 'mascaraHora(this)');
    return retornoHota;
}

function addDomOcorrencia(ocorrencia) {

    let _tabelaOcorrencia = document.querySelector('tbody #tbOcorrenciaMot');

    let _labelAs = createElement('label', {}, ' as ');

    let _trOcorrencia = createElement('tr', {
        className: 'celulaZebra2',
        id: 'trOcorrencia_' + countOcorrenciaMotorista
    });

    let _img0 = createElement('img', {
        className: 'imagemLink',
        name: 'imgLixo',
        id: 'imgLixo',
        src: 'img/lixo.png'
    });

    _img0.setAttribute('onClick', 'excluirOcorrenciaPropietario(' + ocorrencia.idOcorrencia + ', this)');

    let _ocorrencia = createElement('label', {
        id: 'ocorrencia_' + countOcorrenciaMotorista,
        width: '40%'
    }, ocorrencia.ocorrencia);

    let _idOcorrencia = createElement('input', {
        name: 'idOcorrencia_' + countOcorrenciaMotorista,
        id: 'idOcorrencia_' + countOcorrenciaMotorista,
        hidden: true
    }, ocorrencia.idOcorrencia);

    let _idOcorrenciaCTRC = createElement('input', {
        name: 'idOcorrenciaCTRC_' + countOcorrenciaMotorista,
        id: 'idOcorrenciaCTRC_' + countOcorrenciaMotorista,
        hidden: true
    }, ocorrencia.idOcorrenciaCTRC);

    let _dataInclusao = createElementDate('input', {
        id: 'dataInclusao_' + countOcorrenciaMotorista,
        name: 'dataInclusao_' + countOcorrenciaMotorista,
        className: 'fieldDate inputReadOnly8pt',
        size: '10',
        maxLength: '10'
    }, ocorrencia.dataInclusao);

    let _horaInclusao = createElementHora('input', {
        id: 'horaInclusao_' + countOcorrenciaMotorista,
        name: 'horaInclusao_' + countOcorrenciaMotorista,
        className: 'fieldDate inputReadOnly8pt',
        size: '4',
        maxLength: '5'
    }, ocorrencia.horaInclusao);

    let _dataOcorrencia = createElementDate('input', {
        id: 'dataOcorrencia_' + countOcorrenciaMotorista,
        name: 'dataOcorrencia_' + countOcorrenciaMotorista,
        className: 'fieldDate',
        onblur: "alertInvalidDate(this, true)",
        size: "10",
        maxlength: "10"
    }, ocorrencia.dataOcorrencia);

    let _horaOcorrencia = createElementHora('input', {
        id: 'horaOcorrencia_' + countOcorrenciaMotorista,
        name: 'horaOcorrencia_' + countOcorrenciaMotorista,
        className: 'inputtexto',
        size: "4",
        maxlength: "5"
    }, ocorrencia.horaOcorrencia);

    let _descricaoOcorrencia = createElement('textarea', {
        id: 'descricaoOcorrencia_' + countOcorrenciaMotorista,
        name: 'descricaoOcorrencia_' + countOcorrenciaMotorista,
        className: 'inputtexto',
        cols: '26',
        rows: '2'
    }, ocorrencia.descricaoOcorrencia);

    let _usuarioInclusao = createElement('label', {
        id: 'usuarioInclusao_' + countOcorrenciaMotorista
    }, ocorrencia.usuarioInclusao);

    let _idUsuarioInclusao = createElement('input', {
        id: 'idUsuarioInclusao_' + countOcorrenciaMotorista,
        name: 'idUsuarioInclusao_' + countOcorrenciaMotorista,
        hidden: true
    }, ocorrencia.idUsuarioInclusao);

    let _resolvido = createElement('input', {
        id: 'resolvido_' + countOcorrenciaMotorista,
        name: 'resolvido_' + countOcorrenciaMotorista,
        className: 'resolvido',
        type: 'checkbox'
    }, ocorrencia.isResolvido);

    _resolvido.setAttribute('onclick', 'resolveuOcorrencia(' + countOcorrenciaMotorista + ')');
    
    if (ocorrencia.resolvido === 'true') {
        _resolvido.checked = true;
    }
    
    let _dataResolucao = createElementDate('input', {
        className: 'fieldDate',
        id: 'dataResolucao_' + countOcorrenciaMotorista,
        name: 'dataResolucao_' + countOcorrenciaMotorista,
        size: "10",
        maxlength: "10"
    }, ocorrencia.resolvidoEm);

    let _horaResolucao = createElementHora('input', {
        className: 'inputtexto',
        id: 'horaResolucao_' + countOcorrenciaMotorista,
        name: 'horaResolucao_' + countOcorrenciaMotorista,
        size: "4",
        maxlength: "5"
    }, ocorrencia.resolvidoAs);

    let _descricaoResolucao = createElement('textarea', {
        id: 'descricaoResolucao_' + countOcorrenciaMotorista,
        name: 'descricaoResolucao_' + countOcorrenciaMotorista,
        className: 'inputtexto',
        cols: '26',
        rows: '2'
    }, ocorrencia.descricaoResolucao);

    let _usuarioResolucao = createElement('label', {
        id: 'usuarioResolucao_' + countOcorrenciaMotorista
    }, ocorrencia.usuarioResolucao);

    let _idUsuarioResolucao = createElement('input', {
        id: 'idUsuarioResolucao_' + countOcorrenciaMotorista,
        name: 'idUsuarioResolucao_' + countOcorrenciaMotorista,
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
    
    _asHoraResolucao = createElement('label', {}, ' �s ');

    _tdOcorrencia.appendChild(_ocorrencia);
    _tdOcorrencia.appendChild(_idOcorrencia);
    _tdOcorrencia.appendChild(_idOcorrenciaCTRC);
    _tdDataHoraInclusao.appendChild(_dataInclusao);
    _tdDataHoraInclusao.appendChild(createElement('label', {}, ' �s '));
    _tdDataHoraInclusao.appendChild(_horaInclusao);
    _tdDataHoraOcorrencia.appendChild(_dataOcorrencia);
    _tdDataHoraOcorrencia.appendChild(createElement('label', {}, ' �s '));
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

    countOcorrenciaMotorista++;

    document.querySelector("#maxOcorrencia").value = countOcorrenciaMotorista;
}

function addNovaOcorrencia(idUsuario, usuario, ocorrencia_id, ocorrencia, descricao_ocorrencia, dataAtual, horaAtual, obrigaResolucao) {
    let ocorrenciaMotorista = new Ocorrencia;

    ocorrenciaMotorista.idUsuarioInclusao = idUsuario;
    ocorrenciaMotorista.usuarioInclusao = usuario;
    ocorrenciaMotorista.ocorrencia = ocorrencia + ' - ' + descricao_ocorrencia;
    ocorrenciaMotorista.dataInclusao = dataAtual;
    ocorrenciaMotorista.horaInclusao = horaAtual;
    ocorrenciaMotorista.idOcorrenciaCTRC = ocorrencia_id;
    ocorrenciaMotorista.obrigaResolucao = obrigaResolucao;
    
    addDomOcorrencia(ocorrenciaMotorista);
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
    post_cad = window.open('./localiza?acao=consultar&idlista=40&paramaux=1', 'Ocorrencia_Ctrc',
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
