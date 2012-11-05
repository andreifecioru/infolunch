#import <Foundation/Foundation.h>

@interface Spectrum : NSObject {
@private
    NSArray *fftData;
    NSUInteger resolution;
    NSUInteger sampleRate;
    NSUInteger binWithMaxValue;
}

@property (nonatomic, readonly) NSNumber *frequencyWithMaxValue;
@property (nonatomic, readonly) NSNumber *maxValue;
@property (nonatomic, readonly) NSUInteger resolution;
@property (nonatomic, readonly) NSUInteger sampleRate;
@property (nonatomic, readonly) NSArray *fftData;

+ (Spectrum *) spectrumWithFFTData:(NSArray *)fftData andSampleRate:(NSUInteger)sampleRate;

@end