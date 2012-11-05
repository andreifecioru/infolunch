#import "Spectrum.h"

@implementation Spectrum
@synthesize fftData;
@synthesize sampleRate;

#pragma mark - Public API
- (NSUInteger)resolution {
    return fftData.count;
}

- (NSNumber *)frequencyWithMaxValue {
    return [NSNumber numberWithDouble:1.0f*binWithMaxValue*self.sampleRate/self.resolution];
}

- (NSNumber *)maxValue {
    return (NSNumber *) fftData[binWithMaxValue];
}

+ (Spectrum *) spectrumWithFFTData:(NSArray *)fftData andSampleRate:(NSUInteger)sampleRate {
    Spectrum *spectrum = [[Spectrum alloc] init];
    spectrum->fftData = [NSArray arrayWithArray:fftData];
    spectrum->sampleRate = sampleRate;

    double _max = 0;
    for (NSUInteger i = 0; i < fftData.count/2; i++) {
        if ([fftData[i] doubleValue] > _max) {
            _max = [fftData[i] doubleValue];
            spectrum->binWithMaxValue = i;
        }
    }

    return spectrum;
}

@end