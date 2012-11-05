#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <GHUnitIOS/GHUnit.h>
#import "Signal.h"
#import "Spectrum.h"

#define SAMPLE_RATE     8000
#define AMPLITUDE       1
#define LENGTH          512
#define FREQUENCY       2000

@interface TestOfflineFFTComputation : GHTestCase {
    Signal *testSignal;
}
@end

@implementation TestOfflineFFTComputation

// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// Run at start of all tests in the class
- (void)setUpClass {
    testSignal = [Signal createWithSineWaveOfAmplitude:AMPLITUDE andFrequency:FREQUENCY andSampleRate:SAMPLE_RATE andLength:LENGTH];
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
- (void)testMaxFrequncyBinIsCorrect {
   Spectrum *spectrum = [testSignal computeFFTAtPosition:0 andWindowLength:LENGTH];
//    assertThat(spectrum.frequencyWithMaxValue, equalToDouble(FREQUENCY));
    assertThat(spectrum.frequencyWithMaxValue, closeTo(FREQUENCY, SAMPLE_RATE/512.0));
}


@end