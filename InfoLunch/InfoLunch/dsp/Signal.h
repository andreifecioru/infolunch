#import <Foundation/Foundation.h>

@class Signal;
@class Spectrum;

@protocol SignalDelegate <NSObject>
@optional
- (void)onFFTComplete:(Spectrum *)spectrum;
- (void)onSineWaveLoadSuccess;
- (void)onSineWaveLoadError:(NSString *)errMsg;
@end

@interface Signal : NSObject {
@private
    __weak id <SignalDelegate> delegate;
    double *samples;
    NSUInteger sampleCount;
    NSUInteger sampleRate;
    NSURLConnection *urlConnection;
    NSMutableData *responseData;
}

@property(weak) id <SignalDelegate> delegate;
@property(readonly) NSUInteger sampleCount;
@property(readonly) NSUInteger sampleRate;
@property(readonly, nonatomic) NSArray *samples;
@property(readwrite, nonatomic) NSURLConnection *urlConnection;

+ (Signal *)createWithSineWaveOfAmplitude:(NSUInteger)amplitude andFrequency:(NSUInteger)frequency andSampleRate:(NSUInteger)sampleRate andLength:(NSUInteger)length;

+ (Signal *)createWithSilenceUsingSampleRate:(NSUInteger)sampleRate andLength:(NSUInteger)length;

- (void)loadSineWaveFromURL:(NSString *)url;

- (Spectrum *)computeFFTAtPosition:(NSUInteger)position andWindowLength:(NSUInteger)windowLength;

- (void)computeFFTAsyncAtPosition:(NSUInteger)position andWindowLength:(NSUInteger)windowLength;

- (BOOL)addSignal:(Signal *)signal;

@end