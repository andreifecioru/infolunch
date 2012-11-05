#import <UIKit/UIKit.h>
#import "SineWave.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    SineWave *sineWave;
}

@property(nonatomic, readonly) SineWave *sineWave;
@property(strong, nonatomic) UIWindow *window;

@end