#import <Foundation/Foundation.h>
#import "Signal.h"

@class SineWave;

@protocol SineWaveDelegate
@optional
- (void)onSineWaveReady:(SineWave *)sineWave;
@end

@interface SineWave : NSObject {
@private
    __weak id<SineWaveDelegate> delegate;
    Signal *signal;
    Spectrum *spectrum;
    double maxValue;
}

@property(weak) id <SineWaveDelegate> delegate;
@property(nonatomic, retain) Signal *signal;
@property(readonly) Spectrum *spectrum;
@property(readonly) double maxValue;

+ (SineWave *)sineWaveWithFrequencies:(NSArray *)frequencies;
+ (void)sineWaveWithFrequenciesFromURL:(NSString *)url;
@end