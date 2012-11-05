#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <GHUnitIOS/GHUnit.h>
#import "Signal.h"
#import <OCMock/OCMock.h>

#define SAMPLE_RATE     8000
#define AMPLITUDE       1
#define LENGTH          512
#define FREQUENCY       2000

#define URL @"http://127.0.0.1:3000/tone"

@interface TestOfflineToneGenerationFromURL : GHAsyncTestCase <SignalDelegate> {
    Signal *testSignal;
    NSMutableArray *referenceSamples;
    id mockedUrlConnection;
}

@end

@implementation TestOfflineToneGenerationFromURL

// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// Run at start of all tests in the class
- (void)setUpClass {
    // set-up the test object
    testSignal = [[Signal alloc] init];
    testSignal.delegate = self;

    // set-up the mock URL connection
    mockedUrlConnection = [OCMockObject mockForClass:[NSURLConnection class]];
    testSignal.urlConnection = mockedUrlConnection;

    // set-up the reference data
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

#pragma mark - Helper methods
- (void)onSineWaveLoadSuccess {
    // let the test know that the async. operation is complete.
    [self notify:kGHUnitWaitStatusSuccess];
}

- (void)onSineWaveLoadError:(NSString *)errMsg {
    NSLog(@"Failed to load the sine wave data from url %@: %@", URL, errMsg);

    // let the test know that the async. operation failed.
    [self notify:kGHUnitWaitStatusFailure];
}

#pragma mark - Unit tests
- (void)testProperGenerationOf100HzThoneSampleBySample {
    // set expectations on the mock object
    [[[[mockedUrlConnection stub]
            andDo:^(NSInvocation *invocation) {
                NSString *mockedResponse = [NSString stringWithFormat:@"{\"amplitude\":%d, \"frequency\":%d, \"length\":%d, \"sampleRate\": %d}",
                                            AMPLITUDE, FREQUENCY, LENGTH, SAMPLE_RATE];
                [testSignal performSelector:@selector(parseResponseAndGenerate:) withObject:mockedResponse withObject:nil];
            }]

            andReturn:OCMOCK_ANY]
     
            initWithRequest:OCMOCK_ANY
            delegate:OCMOCK_ANY
            startImmediately:YES];

    // we are starting an asyn. operation.
    [self prepare];

    [testSignal loadSineWaveFromURL:URL];

    // wait for the async. operation to complete.
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];

    // check the proper length
    assertThat([NSNumber numberWithUnsignedInteger:testSignal.sampleCount], equalToInt(LENGTH));

    // check the actual sample values
    for (NSUInteger i = 0; i < testSignal.sampleCount; i++) {
        assertThat([testSignal.samples objectAtIndex:i],
                   describedAs([NSString stringWithFormat:@"Sample %d was supposed to be %g", i, [[testSignal.samples objectAtIndex:i] doubleValue]],
                               equalTo([referenceSamples objectAtIndex:i]), nil));
    }
}

@end