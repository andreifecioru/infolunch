#import <UIKit/UIKit.h>
#import <GHUnitIOS/GHUnitIOSViewController.h>

#import "AppDelegate.h"

int main(int argc, char *argv[]) {
    int retVal;
    @autoreleasepool {
        if (getenv("GHUNIT_CLI")) {
            retVal = [GHTestRunner run];
        } else {
            retVal = UIApplicationMain(argc, argv, nil, @"GHUnitIOSAppDelegate");
        }
    }
    
    return retVal;
}
