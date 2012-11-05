#import <GHUnitIOS/GHUnit.h>

@interface AsyncTestTemplate : GHAsyncTestCase
@end

@implementation AsyncTestTemplate

// By default NO, but if you have a UI test or test
// dependent on running on the main thread return YES
- (BOOL)shouldRunOnMainThread {
    return NO;
}

// Run at start of all tests in the class
- (void)setUpClass {
    NSLog(@"Setting up all the test cases in the class");
}

// Run at end of all tests in the class
- (void)tearDownClass {
    NSLog(@"Tearing down all the test cases in the class");
}

// Run before each test method
- (void)setUp {
    NSLog(@"Setting up a single test case");
}

// Run after each test method
- (void)tearDown {
    NSLog(@"Tearing down a single test case");
}

#pragma mark - Unit tests
- (void)testMyFirstTestCase {
    // we are starting an async. operation.
    [self prepare];

    // run the test on the test object
    
    // wait for the async. operation to complete.
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:3.0];
    
    GHAssertTrue(true, @"Test passed!.");
}

- (void)callbackTriggeredByObjectUnderTest {
    // let the test know that the async. operation is complete.
    [self notify:kGHUnitWaitStatusSuccess];
}

@end