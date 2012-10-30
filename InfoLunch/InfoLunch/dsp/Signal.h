#import <Foundation/Foundation.h>

@protocol SignalEventsDelegate <NSObject>
-(void)onFFTComplete:(double *)data;
@end

@interface Signal : NSObject {
    __weak id <SignalEventsDelegate> delegate;

@private
    double *samples;
    UInt32 sampleCount;
    UInt32 sampleRate;
}

@property (weak) id <SignalEventsDelegate> delegate;

+(Signal *)createWithSineWaveOfAmplitude:(double)amplitude andFrequency:(double)frequency andSampleRate:(UInt32)sampleRate andLength:(UInt32)length;

-(double *)computeFFTAtPosition:(UInt32)position andWindowLength:(UInt32)windowLength;
-(void)computeFFTAsyncAtPosition:(UInt32)position andWindowLength:(UInt32)windowLength;
-(BOOL)addSignal:(Signal *)signal;

@end