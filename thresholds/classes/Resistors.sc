/*--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

 Utility to calculate total resistance of resistor array topologies.

 Parallel:

   :: Rt =  (R1 * R2) / (R1 + R2)

 Series:

   :: Rt =  (R1 + R2)

 from "Thresholds" library  -dkant, 2016


 TOOD
 -> variable number of resistors [R1, R2, R3, ... ]
 -> note: removed vactrolGate b/c foldover need better way to implement logic
 -> write .schelp file

*/

ResistorsParallel {

    *ar { |r1, r2|

        ^((r1 * r2) / (r1 + r2))
    }
}

ResistorsSeries {

    *ar { |r1, r2|

        ^(r1 + r2)
    }
}

Resistors {

    *ar { |r1, r2, seriesVParallel = 0|

        ^(this.series(r1, r2) * (1-seriesVParallel) + this.parallel(r1, r2) * seriesVParallel)
    }


    *parallel { |r1, r2|

        ^((r1 * r2) / (r1 + r2))
    }


    *series { |r1, r2|

        ^(r1 + r2)
	}
}