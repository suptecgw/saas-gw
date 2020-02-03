
function Faixa(de, ate, aliquota, deducao){
    this.de = parseFloat(de == null || de == undefined ? 0 : de);
    this.ate = parseFloat(ate == null || ate == undefined ? 0 : ate);
    this.aliquota = parseFloat(aliquota == null || aliquota == undefined ? 0 : aliquota);
    this.deducao = (deducao == null || deducao == undefined ? 0 : deducao);
}

function Inss(valorFrete, percentualBase, faixas, teto, valorJaRetido, baseJaRetida){
    /*
     * Parametros de entrada
     */
    this.valorFrete =  parseFloat(valorFrete == null || valorFrete == undefined ? 0 : valorFrete);
    this.percentualBase =  parseFloat(percentualBase == null || percentualBase == undefined ? 0 : percentualBase);
    this.faixas =  (faixas == null || faixas == undefined ? new Array() : faixas);    
    this.teto = parseFloat(teto == null || teto == undefined ? 0 : teto);
    this.valorJaRetido = parseFloat(valorJaRetido == null || valorJaRetido == undefined ? 0 : valorJaRetido);
    this.baseJaRetida = parseFloat(baseJaRetida == null || baseJaRetida == undefined ? 0 : baseJaRetida);
    /*
     *Calculos
     */
    this.baseCalculo = parseFloat(this.valorFrete * this.percentualBase / 100);
    var baseCalculoReal = parseFloat(this.baseCalculo) + parseFloat(this.baseJaRetida);
    
    var faixa;
    this.aliquota = 0;
    for(var i = 0; i < faixas.length; i++){
        faixa = faixas[i];        
        if(baseCalculoReal >= faixa.de && baseCalculoReal <= faixa.ate){
            this.aliquota = faixa.aliquota;            
            break;
        }
    }

    var valorFinalINSS = (baseCalculoReal * this.aliquota / 100);
    //Retirando do total o que já foi retido em outros contratos de fretes

    this.valorFinal = parseFloat(valorFinalINSS) - parseFloat(this.valorJaRetido);
    if(this.valorJaRetido >= this.teto){
        this.valorFinal = 0;
    }else if(parseFloat(valorFinalINSS) >= this.teto){
        this.valorFinal = this.teto - this.valorJaRetido;
    }
    
}

function Sest(baseCalculo, aliquota){    
    this.baseCalculo = parseFloat(baseCalculo == null || baseCalculo == undefined ? 0 : baseCalculo);    
    this.aliquota = parseFloat(aliquota == null || aliquota == undefined ? 0 : aliquota);    
    this.valorFinal = (this.baseCalculo * this.aliquota / 100);    
}

function IR(valorFrete, percentualBase, faixas, valorInss, baseJaRetida, valorIRJaRetido, qtdDepentendes, valorPorDepentente, isCalculaDependentes, isDeduzirINSSIR){
    this.valorFrete = parseFloat(valorFrete == null || valorFrete == undefined ? 0 : valorFrete);
    this.percentualBase = parseFloat(percentualBase == null || percentualBase == undefined ? 0 : percentualBase);
    this.valorInss = (valorInss == null || valorInss ==undefined ? 0 : valorInss);
    this.baseJaRetida = (baseJaRetida == null || baseJaRetida ==undefined ? 0 : baseJaRetida);
    this.valorIRJaRetido = (valorIRJaRetido == null || valorIRJaRetido ==undefined ? 0 : valorIRJaRetido);
    this.qtdDepentendes = (qtdDepentendes == null || qtdDepentendes ==undefined ? 0 : qtdDepentendes);
    this.valorPorDepentente = (valorPorDepentente == null || valorPorDepentente ==undefined ? 0 : valorPorDepentente);
    this.isCalculaDependentes = (isCalculaDependentes == null || isCalculaDependentes ==undefined ? false : isCalculaDependentes);
    this.faixas = (faixas == null || faixas == undefined ? new Array() : faixas);

    var valorTotalDependente = 0;
    if (isCalculaDependentes) {
        valorTotalDependente = parseFloat(this.qtdDepentendes * this.valorPorDepentente);
    }
    if(isDeduzirINSSIR === 'false') {
        this.baseCalculo = parseFloat(this.valorFrete * this.percentualBase / 100)// - this.valorInss; - valorTotalDependente;
    }else{
        this.baseCalculo = parseFloat(this.valorFrete * this.percentualBase / 100) - this.valorInss; //- valorTotalDependente;
    }
    var baseCalculoReal = parseFloat(this.baseCalculo) + parseFloat(this.baseJaRetida) - parseFloat(valorTotalDependente);
    /**
         * Calculos
         */
    
    var faixa;
    this.aliquota = 0;
    this.deducao = 0;
    for(var i = 0; i < faixas.length; i++){
        faixa = faixas[i];
        if(baseCalculoReal >= faixa.de && baseCalculoReal <= faixa.ate){
            this.aliquota = faixa.aliquota;
            this.deducao = faixa.deducao;
            break;
        }
    }

    var valorFinalIR = (baseCalculoReal * this.aliquota / 100) - this.deducao;
    //Retirando do total o que já foi retido em outros contratos de fretes
    this.valorFinal = parseFloat(valorFinalIR) - parseFloat(this.valorIRJaRetido);
    if (parseFloat(this.valorFinal) < 0){
        this.valorFinal = 0;
    }

}