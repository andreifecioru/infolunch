#import "SineWave.h"

const NSUInteger LENGTH = 512;
const NSUInteger SAMPLE_FREQ = 8000;
const NSUInteger AMPLITUDE = 2;

@interface SineWave ()
- (SineWave *)init;
@end

@implementation SineWave

@synthesize signal;
@synthesize maxValue;
@synthesize spectrum;
@synthesize delegate;

#pragma mark - Private methods
- (SineWave *)init {
    self = [super init];

    if (self) {
        signal = nil;
        spectrum = nil;
        maxValue = 0;
    }

    return self;
}

- (void)dealloc {
    signal = nil;
    spectrum = nil;
}

#pragma mark - Public methods
+ (SineWave *)sineWaveWithFrequencies:(NSArray *)frequencies {
    SineWave *sineWave = [[SineWave alloc] init];
    sineWave.signal = [Signal createWithSilenceUsingSampleRate:SAMPLE_FREQ andLength:LENGTH];

    for (NSNumber *frequency in frequencies) {
        BOOL result = [sineWave.signal addSignal:[Signal createWithSineWaveOfAmplitude:AMPLITUDE
                                                                          andFrequency:[frequency unsignedIntegerValue]
                                                                         andSampleRate:SAMPLE_FREQ andLength:LENGTH]];
        if (!result) {
            NSLog(@"Cannot add signal with frequency: %i", [frequency unsignedIntegerValue]);
        }
    }

    sineWave->spectrum = [sineWave.signal computeFFTAtPosition:0 andWindowLength:LENGTH];

    double _max = 0;
    if ([sineWave->signal.samples count] != 0) {
        for (NSUInteger i = 0; i < sineWave->signal.sampleCount; i++) {
            if ([[sineWave->signal.samples objectAtIndex:i] doubleValue] > _max) {
                _max = [[sineWave->signal.samples objectAtIndex:i] doubleValue];
            }
        }
    }
    sineWave->maxValue = _max;

    return sineWave;
}

+ (void)sineWaveWithFrequenciesFromURL:(NSString *)url {

}

@end