#import <GHUnitIOS/GHUnit.h>

@interface TestTemplate : GHTestCase
@end

@implementation TestTemplate

// By default NO, but if you have a UI test or test dependent on running on the main thread return YES
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
    GHAssertTrue(true, @"Test passed!.");
}

- (void)testMySecondTestCase {
    GHAssertTrue(false, @"This was supposed to fail.");
}

@end