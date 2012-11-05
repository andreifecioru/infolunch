#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <GHUnitIOS/GHUnit.h>
#import "Signal.h"
#import "Spectrum.h"

#define SAMPLE_RATE     8000
#define AMPLITUDE       1
#define LENGTH          512
#define FREQUENCY       2000

@interface TestOfflineFFTComputationAsync : GHAsyncTestCase <SignalDelegate> {
    Signal *testSignal;
    Spectrum *computedSpectrum;
}
@end

@implementation TestOfflineFFTComputationAsync

// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// Run at start of all tests in the class
- (void)setUpClass {
    testSignal = [Signal createWithSineWaveOfAmplitude:AMPLITUDE andFrequency:FREQUENCY andSampleRate:SAMPLE_RATE andLength:LENGTH];
    testSignal.delegate = self; // NOTE: comment this to demo the test time-out feature
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
    // we are starting an asyn. operation.
    [self prepare];

    [testSignal computeFFTAsyncAtPosition:0 andWindowLength:LENGTH];

    // wait for the async. operation to complete.
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];

    assertThat(computedSpectrum.frequencyWithMaxValue, closeTo(FREQUENCY, SAMPLE_RATE/512.0));
}

- (void)onFFTComplete:(Spectrum *)spectrum {
    computedSpectrum = spectrum;

    // let the test know that the async. operation is complete.
    [self notify:kGHUnitWaitStatusSuccess];
}

@end