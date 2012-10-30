#import "Signal.h"

@interface Signal ()
-(Signal *)initWithLength:(UInt32)length andSampleRate:(UInt32) rate;
-(void)computeFFTForFrame:(double *)data withResolution:(UInt32)nFFT;
@end

@implementation Signal

@synthesize delegate;

-(Signal *)initWithLength:(UInt32)length andSampleRate:(UInt32) rate {
    self = [super init];

    if (self) {
        samples = (double *) calloc(length, sizeof(double));
        sampleCount = length;
        sampleRate = rate;
    }

    return self;
}

-(void)dealloc {
    if (samples) free(samples);
}

-(void)computeFFTForFrame:(double *)data withResolution:(UInt32)nFFT {
    UInt32 n, mmax, m, j, istep, i;
    double wtemp, wr, wpr, wpi, wi, theta;
    double tempr, tempi;

    // reverse-binary re-indexing
    n = nFFT << 1;
    j = 1;
    for (i = 1; i < n; i += 2) {
        if (j > i) {
            wtemp = data[j - 1];
            data[j - 1] = data[i - 1];
            data[i - 1] = wtemp;
            wtemp = data[j];
            data[j] = data[i];
            data[i] = wtemp;
        }
        m = nFFT;
        while (m >= 2 && j > m) {
            j -= m;
            m >>= 1;
        }
        j += m;
    };

    // here begins the Danielson-Lanczos section
    mmax = 2;
    while (n > mmax) {
        istep = mmax << 1;
        theta = -(2 * M_PI / mmax);
        wtemp = sin(0.5 * theta);
        wpr = -2.0 * wtemp * wtemp;
        wpi = sin(theta);
        wr = 1.0;
        wi = 0.0;
        for (m = 1; m < mmax; m += 2) {
            for (i = m; i <= n; i += istep) {
                j = i + mmax;
                tempr = wr * data[j - 1] - wi * data[j];
                tempi = wr * data[j] + wi * data[j - 1];

                data[j - 1] = data[i - 1] - tempr;
                data[j] = data[i] - tempi;
                data[i - 1] += tempr;
                data[i] += tempi;
            }

            wtemp = wr;
            wr += wr * wpr - wi * wpi;
            wi += wi * wpr + wtemp * wpi;
        }

        mmax = istep;
    }
}

-(BOOL)addSignal:(Signal *)signal {
    if ((sampleCount != signal->sampleCount) || (sampleRate != signal->sampleRate))
        return NO;

    for (UInt32 i=0; i<sampleCount; i++) {
        samples[i] += signal->samples[i];
    }

    return YES;
}

-(double *)computeFFTAtPosition:(UInt32)position andWindowLength:(UInt32)windowLength {
    double *fftBuffer = nil;
    if (samples && sampleCount && (position+windowLength<=sampleCount)) {
        fftBuffer = (double *) calloc(windowLength*2, sizeof(double));
        if (fftBuffer) {
            for (UInt32 i=0; i<windowLength; i++) { // prepare data for in-place FFT
                fftBuffer[i*2] = samples[position+i];
            }
            [self computeFFTForFrame:fftBuffer withResolution:windowLength];
            
            for (UInt32 i=0; i<windowLength*2; i++) {
                fftBuffer[i] = fabs(fftBuffer[i]);
            }
        }

    }

    return fftBuffer;
}

-(double *)computeFFTAsyncAtPosition:(UInt32)position andWindowLength:(UInt32)windowLength {

}

+(Signal *)createWithSineWaveOfAmplitude:(double)amplitude andFrequency:(double)frequency andSampleRate:(UInt32)sampleRate andLength:(UInt32)length {
    Signal *signal = [[Signal alloc] initWithLength:length andSampleRate:sampleRate];
    for (UInt32 i=0; i<signal->sampleCount; i++) {
        signal->samples[i] = amplitude*sin(2*M_PI*frequency/signal->sampleRate*i);
    }

    return signal;
}

@end