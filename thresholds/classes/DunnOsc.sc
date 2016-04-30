DunnOsc : MultiOutUGen {

    *ar { arg r=18.6, freq=0.85, error=2.0, mul=1.0, add=0.0;
        ^this.multiNew('audio', r, freq, error).madd(mul, add)
    }

    init { arg ... theInputs;
        inputs = theInputs;
        ^this.initOutputs(3, rate);
    }
}
