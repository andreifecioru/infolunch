#import "SpectrumViewController.h"
#import "AppDelegate.h"
#import "Spectrum.h"

#define APP_DELEGATE (AppDelegate *) [[UIApplication sharedApplication] delegate]

@interface SpectrumViewController ()
@property(nonatomic, strong) CPTGraphHostingView *hostView;

- (void)initPlot;

- (void)configureHost;

- (void)configureGraph;

- (void)configurePlots;

- (void)configureAxes;
@end

@implementation SpectrumViewController

@synthesize hostView = hostView_;

#pragma mark - UIViewController lifecycle methods
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self initPlot];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Chart behavior
- (void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

- (void)configureHost {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
}

- (void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;

    // 2 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);

    // 3 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];

    // 4 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
}

- (void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;

    // 2 - Create the the plot
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = @"fft";
    CPTColor *aaplColor = [CPTColor greenColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];

    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
    CPTMutablePlotRange *xRange = (CPTMutablePlotRange *) [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = (CPTMutablePlotRange *) [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;

    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = (CPTMutableLineStyle *) [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 2.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
    aaplPlot.plotSymbol = aaplSymbol;
}

- (void)configureAxes {
    SineWave *sineWave = [APP_DELEGATE sineWave];
    Signal *signal = sineWave.signal;

    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;

    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Frequency";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    NSMutableSet *xLabels = [NSMutableSet set];
    NSMutableSet *xLocations = [NSMutableSet set];
    NSUInteger sampleRate = signal.sampleRate;
    NSUInteger signalLength = signal.sampleCount;
    NSUInteger increment = signalLength / 8;
    for (NSInteger i = increment; i <= signalLength; i += increment) {
        NSString *labelText = [NSString stringWithFormat:@"%.1f", (float) i * sampleRate / (signalLength * 2)];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:labelText textStyle:x.labelTextStyle];
        label.tickLocation = CPTDecimalFromInteger(i);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithInteger:i]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;

    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Amplitude";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    double maxAmplitude = sineWave.spectrum.maxValue.doubleValue;
    NSUInteger majorIncrement = (NSUInteger) maxAmplitude / 5;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    for (NSUInteger j = majorIncrement; j <= maxAmplitude + majorIncrement; j += majorIncrement) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
        NSDecimal location = CPTDecimalFromInteger(j);
        label.tickLocation = location;
        label.offset = -y.majorTickLength - y.labelOffset;
        if (label) {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
}

#pragma mark - CPTPlotDataSource methods
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    Signal *signal = [[APP_DELEGATE sineWave] signal];
    return signal.sampleCount;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    SineWave *sineWave = [APP_DELEGATE sineWave];
    Signal *signal = sineWave.signal;

    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < signal.sampleCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;

        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:@"fft"] == YES) {
                if (sineWave.spectrum) {
                    return sineWave.spectrum.fftData[index];
                }
            }
            break;
        default:
            return [NSDecimalNumber zero];
    }
    return [NSDecimalNumber zero];
}

@end