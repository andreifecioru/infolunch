#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <GHUnitIOS/GHUnit.h>
#import "Signal.h"

#define SAMPLE_RATE     8000
#define AMPLITUDE       1
#define LENGTH          100
#define FREQUENCY       100

@interface TestOfflineToneGeneration : GHTestCase {
    Signal *testSignal;
    NSMutableArray *referenceSamples;
}
@end

@implementation TestOfflineToneGeneration

// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// Run at start of all tests in the class
- (void)setUpClass {
    testSignal = [Signal createWithSineWaveOfAmplitude:AMPLITUDE andFrequency:FREQUENCY andSampleRate:SAMPLE_RATE andLength:LENGTH];

    referenceSamples = [NSMutableArray arrayWithCapacity:LENGTH];
    for (NSUInteger i = 0; i < LENGTH; i++) {
        NSNumber *sample = [NSNumber numberWithDouble:AMPLITUDE* sin(2*M_PI*FREQUENCY/SAMPLE_RATE*i)];
        [referenceSamples setObject:sample atIndexedSubscript:i];
    }
}

// Run at end of all tests in the class
- (void)tearDownClass {
}

// Run before each test method
- (void)setUp {
}

// Run after each test method
- (void)tearDown {
}

#pragma mark - Unit tests
- (void)testProperGenerationOf100HzThoneInOneShot {
    assertThat([testSignal.samples componentsJoinedByString:@","], is([referenceSamples componentsJoinedByString:@","]));
}

- (void)testProperGenerationOf100HzThoneSampleBySample {
    for (NSUInteger i = 0; i < testSignal.sampleCount; i++) {
        assertThat([testSignal.samples objectAtIndex:i],
                   describedAs([NSString stringWithFormat:@"Sample %d was supposed to be %g", i, [[testSignal.samples objectAtIndex:i] doubleValue]],
                               equalTo([referenceSamples objectAtIndex:i]), nil));
    }
}

@end