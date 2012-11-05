#import "Signal.h"
#import "Spectrum.h"
#import "SBJson.h"

@interface Signal ()
- (Signal *)init;
- (Signal *)initWithLength:(NSUInteger)length andSampleRate:(NSUInteger)rate;
- (void)computeFFTForFrame:(double *)data withResolution:(NSUInteger)nFFT;
- (void)performFFTComputation:(NSDictionary *)info;
- (NSArray *)samples;
- (void)parseResponseAndGenerate:(NSString *) response;
- (void)dealloc;
@end

@implementation Signal

@synthesize delegate;
@synthesize sampleCount;
@synthesize sampleRate;
@synthesize urlConnection;

- (Signal *)init {
    self = [super init];

    if (self) {
        samples = nil;
        sampleCount = 0;
        sampleRate = 0;
        urlConnection = [NSURLConnection alloc];
    }

    return self;
}

- (Signal *)initWithLength:(NSUInteger)length andSampleRate:(NSUInteger)rate {
    self = [super init];

    if (self) {
        samples = (double *) calloc(length, sizeof(double));
        sampleCount = length;
        sampleRate = rate;
        urlConnection = [NSURLConnection alloc];
    }

    return self;
}

- (void)dealloc {
    if (samples) free(samples);
}

- (NSArray *)samples {
    NSMutableArray *samplesAsArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < sampleCount; i ++) {
        [samplesAsArray addObject:[NSNumber numberWithDouble:samples[i]]];
    }

    return samplesAsArray;
}

- (void)computeFFTForFrame:(double *)data withResolution:(NSUInteger)nFFT {
    UInt32 n, mmax, m, j, istep, i;
    double wtemp, wr, wpr, wpi, wi, theta;
    double tempr, tempi;

    // reverse-binary re-indexing
    n = nFFT << 1;
    j = 1;
    for (i = 1; i < n; i += 2) {
        if (j > i) {
            wtemp = data[j - 1];
            data[j - 1] = data[i - 1];
            data[i - 1] = wtemp;
            wtemp = data[j];
            data[j] = data[i];
            data[i] = wtemp;
        }
        m = nFFT;
        while (m >= 2 && j > m) {
            j -= m;
            m >>= 1;
        }
        j += m;
    };

    // here begins the Danielson-Lanczos section
    mmax = 2;
    while (n > mmax) {
        istep = mmax << 1;
        theta = -(2 * M_PI / mmax);
        wtemp = sin(0.5 * theta);
        wpr = -2.0 * wtemp * wtemp;
        wpi = sin(theta);
        wr = 1.0;
        wi = 0.0;
        for (m = 1; m < mmax; m += 2) {
            for (i = m; i <= n; i += istep) {
                j = i + mmax;
                tempr = wr * data[j - 1] - wi * data[j];
                tempi = wr * data[j] + wi * data[j - 1];

                data[j - 1] = data[i - 1] - tempr;
                data[j] = data[i] - tempi;
                data[i - 1] += tempr;
                data[i] += tempi;
            }

            wtemp = wr;
            wr += wr * wpr - wi * wpi;
            wi += wi * wpr + wtemp * wpi;
        }

        mmax = istep;
    }
}

- (BOOL)addSignal:(Signal *)signal {
    if ((sampleCount != signal.sampleCount) || (sampleRate != signal.sampleRate))
        return NO;

    for (NSUInteger i = 0; i < sampleCount; i++) {
        samples[i] += signal->samples[i];
    }

    return YES;
}

- (void)performFFTComputation:(NSDictionary *)info {
    NSNumber *position = [info objectForKey:@"position"];
    NSNumber *windowLength = [info objectForKey:@"windowLength"];

    Spectrum *spectrum = [self computeFFTAtPosition:[position unsignedIntValue] andWindowLength:[windowLength unsignedIntValue]];
    [delegate onFFTComplete:spectrum];
}

- (void)parseResponseAndGenerate:(NSString *) response {
    NSDictionary *sineWaveParams = (NSDictionary *) [response JSONValue];
    NSNumber *amplitude = [sineWaveParams objectForKey:@"amplitude"];
    NSNumber *frequency = [sineWaveParams objectForKey:@"frequency"];
    NSNumber *length = [sineWaveParams objectForKey:@"length"];
    NSNumber *_sampleRate = [sineWaveParams objectForKey:@"sampleRate"];

    if (amplitude && frequency && length) {
        sampleCount = length.unsignedIntegerValue;
        sampleRate = _sampleRate.unsignedIntegerValue;
        samples = (double *) calloc(sampleCount, sizeof(double));
        if (!samples) {
            [delegate onSineWaveLoadError:@"Failed allocate memory."];
        } else{
            for (NSUInteger i = 0; i < sampleCount; i++) {
                samples[i] = amplitude.doubleValue * sin(2 * M_PI * frequency.doubleValue / sampleRate * i);
            }

            [delegate onSineWaveLoadSuccess];
        }
    } else{
        [delegate onSineWaveLoadError:@"Invalid server response"];
    }
}

#pragma mark - Connection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  {
    responseData = [NSMutableData data];
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    responseData = nil;

    [delegate onSineWaveLoadError:error.description];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *resultAsString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    [self parseResponseAndGenerate:resultAsString];
}

#pragma mark - Public API
- (void)loadSineWaveFromURL:(NSString *)url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    urlConnection = [urlConnection initWithRequest:request delegate:self startImmediately:YES];

    if (!urlConnection) {
        [delegate onSineWaveLoadError:@"Cannot connect to server"];
    }
}

- (Spectrum *)computeFFTAtPosition:(NSUInteger)position andWindowLength:(NSUInteger)windowLength {
    NSMutableArray *fftArray = [NSMutableArray arrayWithCapacity:windowLength*2];
    double *fftBuffer = nil;
    if (samples && sampleCount && (position + windowLength <= sampleCount)) {
        fftBuffer = (double *) calloc(windowLength * 2, sizeof(double));
        if (fftBuffer) {
            for (UInt32 i = 0; i < windowLength; i++) { // prepare data for in-place FFT
                fftBuffer[i * 2] = samples[position + i];
            }
            [self computeFFTForFrame:fftBuffer withResolution:windowLength];

            for (NSUInteger i = 0; i < windowLength * 2; i++) {
                [fftArray setObject:[NSNumber numberWithDouble:fabs(fftBuffer[i])] atIndexedSubscript:i];
            }
        }
    }

    return [Spectrum spectrumWithFFTData:fftArray andSampleRate:sampleRate];
}

- (void)computeFFTAsyncAtPosition:(NSUInteger)position andWindowLength:(NSUInteger)windowLength {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:position] forKey:@"position"];
    [params setObject:[NSNumber numberWithInt:windowLength] forKey:@"windowLength"];

    [NSThread detachNewThreadSelector:@selector(performFFTComputation:)
                             toTarget:self
                           withObject:params];
}

+ (Signal *)createWithSineWaveOfAmplitude:(NSUInteger)amplitude andFrequency:(NSUInteger)frequency andSampleRate:(NSUInteger)sampleRate andLength:(NSUInteger)length {
    Signal *signal = [[Signal alloc] initWithLength:length andSampleRate:sampleRate];
    for (NSUInteger i = 0; i < signal->sampleCount; i++) {
        signal->samples[i] = amplitude * sin(2 * M_PI * frequency / signal->sampleRate * i);
    }

    return signal;
}

+ (Signal *)createWithSilenceUsingSampleRate:(NSUInteger)sampleRate andLength:(NSUInteger)length {
    Signal *signal = [[Signal alloc] initWithLength:length andSampleRate:sampleRate];
    return signal;
}

@end