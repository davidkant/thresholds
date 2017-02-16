VoltageDivider {

    *ar { |vin = 1, r1 = 0, r2 = 0.5|

        ^( vin * ( r2 / (r1 + r2) ))

    }
}

// { VoltageDivider.ar(r1: LinLin.ar()) }.scope()
//
// { [SinOsc.ar(120, mul:0.5, add:0.5), VoltageDivider.ar(r1: SinOsc.ar(120, mul:0.5, add:0.5))] }.plot()
//
// { [Line.ar(), VoltageDivider.ar(r1: Line.ar())] }.plot(1)

