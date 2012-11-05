#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <GHUnitIOS/GHUnit.h>
#import "Signal.h"

#define SAMPLE_RATE     8000
#define LENGTH          100

@interface TestOfflineSilenceGeneration : GHTestCase {
    Signal *testSignal;
}

@end

@implementation TestOfflineSilenceGeneration

// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// Run at start of all tests in the class
- (void)setUpClass {
    testSignal = [Signal createWithSilenceUsingSampleRate:SAMPLE_RATE andLength:LENGTH];
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
- (void)testSingleSampleCountIsPorperlySet {
    assertThat([NSNumber numberWithUnsignedInteger:testSignal.sampleCount], equalToInt(LENGTH));
}

- (void)testCorrectNumberOfSamplesAreGenerated {
    assertThat(testSignal.samples, hasCountOf(LENGTH));
}

- (void)testAllSamplesAreZero {
    assertThat(testSignal.samples, onlyContains(equalToInt(0), nil));
}

@end