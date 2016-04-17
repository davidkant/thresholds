//--|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

/*

 Chaotic oscillator from David Dunn's "Thresholds and Fragile States" (2010)
 
 Oscillator designed by Julian Sprott [] and built by David Dunn [].
 
 Numerical solution by a modified Euler method. One of the integration stages
 is replaced with a discrete time filter in order to better model a passive RC
 integrator used in the physical implementation of the built circuitry.
 
   :: w = -Az - y - Bx + Csgn(x)
   
      where x, y, z, w = x, x', x'', x''' = signal, 1st, 2nd, 3rd derivatives
 
 "Thresholds and Fragile States" is an analog circuit network of 8 oscillators.
 
 deets
    
    params:
      * r: variable resistance controls oscillator state 0.0-inf
      * freq: 0.0-1.0 resonant frequency unnamed units
      * error: amount of error in the numerical approximation.
 
    output: 
      * x,y,z signal outputs +/- 1.0 reperesents +/- 9.0 volts
 
 dk, 2016
 
 
 TOOD
   -> better name / explanation for ratio + R2C
   ?? mul float (defines) double precision?
   ** internally runs in terms 9v but outputs digital 1.0
   -> combine zmul and saturation level / un-hard code saturation level
   ?? do we need local copies for computation?
   ?? is ZXP inefficient double incrememnt cuz already counting numsamples?
   -> more intelligent oversampling interpolation please
 
*/

#include "SC_PlugIn.h"

// constants + macros
#define A_COEFF 0.005     // A
#define B_COEFF 1.f       // B
#define INIT_X 0.f        // initial value x
#define INIT_Y 1.f        // initial value y
#define INIT_Z 0.f        // initial value z
#define RC_COEFF 0.0006   //
#define R2C 20.f          //
#define Z_MUL 6.f         //
#define RATIO 0.00636698  //
#define SGN(x) ((x) < (0) ? (-1) : (1)) // signum function
#define SATURATE(n) ( n < -6.f ? -6.f : n > 6.f ? 6.f : n ) // amp saturation

// #define SATURATION_LEVEL = 6.f

// i-table pointer
static InterfaceTable *ft;

// uGen state variables
struct DunnOsc : public Unit {
    double x0, y0, z0, xn, yn, zn, xnm1, ynm1, znm1;
};

// uGen functions
extern "C" {
    void DunnOsc_Ctor(DunnOsc *unit);
    void DunnOsc_next(DunnOsc *unit, int inNumSamples);
}

// constructor -------------------------------------------------------------- //
void DunnOsc_Ctor(DunnOsc* unit){
    
    // set calc function
    SETCALC(DunnOsc_next);
    
    // init state variables
    unit->x0 = unit->xn = unit->xnm1 = INIT_X;
    unit->y0 = unit->yn = unit->ynm1 = INIT_Y;
    unit->z0 = unit->zn = unit->znm1 = INIT_Z;
    
    // calc one sample of output
    DunnOsc_next(unit, 1);
}

// calc --------------------------------------------------------------------- //
void DunnOsc_next(DunnOsc *unit, int inNumSamples) {
    
    // output buffers
    float *outX = ZOUT(0);
    float *outY = ZOUT(1);
    float *outZ = ZOUT(2);
    
    // input buffers
    double r = ZIN0(0);      // variable resistance value   
    double freq = ZIN0(1);   // oscillator frequency
    double error = ZIN0(2);  // numerical solution error
    
    // internals
    double h;          // h timestep
    int itersPerSamp;  // calc iterations per sample output
    double c;          // c coefficient
    double alpha;      // passive inegrator coefficient
    double w;          // 3rd deriviative

    // local copies for computation
    double xn = unit->xn;
    double yn = unit->yn;
    double zn = unit->zn;
    double xnm1 = unit->xnm1;
    double ynm1 = unit->ynm1;
    double znm1 = unit->znm1;
    
    // calc time step h from error
    h = RATIO * error;
    
    // calc itersPerSamp from h
    itersPerSamp = (int)round((100 * RATIO / h) * freq);
    
    // calc c from r
    c = R2C/r;

    // calc alpha (accurate on sample rate change)
    alpha = (1.0/SAMPLERATE/itersPerSamp) /
        (RC_COEFF+(1.0/SAMPLERATE/itersPerSamp));
    
    // calc samples (oversample to maintain frequency for small time step h)
    for (int i=0; i<inNumSamples; ++i) {
        for (int j=0; j<itersPerSamp; j++) {
            
            // ---- modified Euler + discrete time filter ---- //
            
            // previous state
            xnm1 = xn;
            ynm1 = yn;
            znm1 = zn;
            
            // w third deriv
            w = -A_COEFF*znm1 - ynm1 - B_COEFF*xnm1 + c*SGN(xnm1);
            
            // z second deriv
            zn = SATURATE(zn + h * w * Z_MUL);
            
            // y first deriv (passive integrator by discrete time filter)
            yn = ynm1 + alpha * (zn - ynm1);
            
            // x signal
            xn = SATURATE(xn + h * ynm1);
        }
        
        // write output buffers one sample and increment index
        ZXP(outX) = xn / 9.0;
        ZXP(outY) = yn / 9.0;
        ZXP(outZ) = zn / 9.0;
    }
    
    // update state variables
    unit->xn = xn;
    unit->yn = yn;
    unit->zn = zn;
    unit->xnm1 = xnm1;
    unit->ynm1 = ynm1;
    unit->znm1 = znm1;
}


// load --------------------------------------------------------------------- //
PluginLoad(DunnOsc)
{
    ft = inTable;
    DefineSimpleUnit(DunnOsc);
}