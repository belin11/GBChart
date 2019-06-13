//
//  ViewController.m
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "ViewController.h"
#import "GBChart/GBChart.h"

@interface ViewController ()
{
    GBLineChart *_lineChart;
    GBRadarChart *_radarChart;
    GBCircleChart *_circleChart;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    [self radarChart];
//    [self circleChart];
//    [self lineChart];
}

- (void)circleChart {
    
    GBCircleChart *circleChart = [[GBCircleChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200) total:@100 current:@30 clockwise:YES shadow:YES shadowColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] displayCountingLabel:YES overrideLineWidth:@4];
    [self.view addSubview:circleChart];
    circleChart.strokeColorGradientStart = [UIColor blueColor];
    circleChart.strokeColor = [UIColor redColor];
//    circleChart.shadowColor = [UIColor blueColor];
    circleChart.countingLabel.formatBlock = ^NSString *(CGFloat value) {
      
        return [NSString stringWithFormat:@"%0.0f分\n我的成绩单", value];
    };
    [circleChart strokeChart];
    _circleChart = circleChart;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self updateRadarChart];
}

- (void)updateRadarChart {
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *values = @[@5,@6,@10,@7,@4];
    NSArray *descs = @[@"苹果5",@"香蕉7",@"花生2",@"橙子5",@"车厘子1"];
    for (int i = 0; i < values.count; i++) {
        
        GBRadarChartDataItem *item = [GBRadarChartDataItem dataItemWithValue:[values[i] floatValue] description:descs[i]];
        [items addObject:item];
    }
    [_radarChart updateChartWithChartData:items];
    
}

- (void)updateLineChart {
    
    NSArray *array = @[@"50",@"20",@"74",@"98",@"0",@"15",@"40"];
    
    GBLineChartData *data = [GBLineChartData new];
    data.lineAlpha = 0.7;
    data.lineColor = [UIColor redColor];
    data.lineWidth = 1;
    data.itemCount = array.count;
    data.lineChartPointStyle = GBLineChartPointStyleTriangle;
    data.inflexionPointStrokeColor = [UIColor purpleColor];
    data.inflexionPointFillColor = [UIColor purpleColor];
    data.inflexionPointWidth = 4;
    
    data.showPointLabel = YES;
    data.pointLabelFont = [UIFont systemFontOfSize:10];
    data.pointLabelColor = [UIColor blackColor];
    data.pointLabelFormat = @"%0.1f";
    
    data.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
        
        return [GBLineChartDataItem dataItemWithY:[array[item] floatValue] X:[_lineChart.xLabelTitles[item] floatValue]];
    };
    [_lineChart updateChartDatas:@[data]];
}

- (void)radarChart {
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *values = @[@100,@50,@70,@30,@50,@40,@45,];
    NSArray *descs = @[@"苹果",@"香蕉",@"花生",@"橙子",@"车子",@"奶子",@"房子",];
    for (int i = 0; i < values.count; i++) {
        
        GBRadarChartDataItem *item = [GBRadarChartDataItem dataItemWithValue:[values[i] floatValue] description:descs[i]];
        [items addObject:item];
    }

    GBRadarChart *radarChart = [[GBRadarChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 400) items:items valueDivider:20];
    radarChart.isShowGraduation = YES;
    radarChart.labelStyle = GBRadarChartLabelStyleHorizontal;
    [radarChart strokeChart];
    [self.view addSubview:radarChart];
    _radarChart = radarChart;
}

- (void)lineChart {
    
    GBLineChart *chart = [[GBLineChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 220)];
    [self.view addSubview:chart];
    chart.xLabelTitles = @[@"0",@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100",];
    chart.yLabelTitles = @[@"0", @"20", @"40", @"60", @"80", @"100"];
    chart.xLabelRotationAngle = M_PI/6;
    chart.showCoordinateAxis = YES;
    chart.xLabelAlignmentStyle = GBXLabelAlignmentStyleFitXAxis;
    
    chart.showVerticalLine = YES;
    chart.verticalLineColor = [UIColor cyanColor];
    chart.verticalLineWidth = 1;
    chart.verticalLineXValue = 8.8;
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *array1 = [NSMutableArray array];

//    for (int i = 0; i < chart.xLabelTitles.count; i++) {
//        [array addObject:[NSNumber numberWithInteger:arc4random() % 100]];
////        [array1 addObject:[NSNumber numberWithInteger:arc4random() % 100]];
//    }
    [array addObjectsFromArray:@[@100,@20, @30,@20,@40,@0,@80,@40,@10,@50,@10]];
    
    NSMutableArray *xArray = chart.xLabelTitles.mutableCopy;
    NSInteger index = ceil(chart.verticalLineXValue/10.0);
    
    NSInteger count = 0;
    for (NSString *title in chart.xLabelTitles) {
        if ([title floatValue] != chart.verticalLineXValue) {
            count++;
        }
    }
    
    if (count == chart.xLabelTitles.count) {
        
        //如果是坐标上的端点 就不要insert
        [xArray insertObject:[NSString stringWithFormat:@"%0.0f", chart.verticalLineXValue] atIndex:index];
        
        CGFloat yvalue = ([array[index] floatValue] + [array[index+1] floatValue])/2;
        [array insertObject:[NSNumber numberWithFloat:yvalue] atIndex:index];
    }
   
    GBLineChartData *data = [GBLineChartData new];
    data.lineAlpha = 0.7;
    data.lineColor = [UIColor blueColor];
    data.lineWidth = 1;
    data.startIndex = 0;
    data.itemCount = index+1;
    data.lineChartPointStyle = GBLineChartPointStyleNone;
    data.inflexionPointStrokeColor = [UIColor redColor];
    data.inflexionPointFillColor = [UIColor greenColor];
    data.inflexionPointWidth = 6;
    data.showDash = YES;
    data.showGradientArea = NO;
    data.startGradientColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    data.endGradientColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
    data.lineDashPattern = @[@1,@1];
    
    data.showPointLabel = NO;
    data.pointLabelFont = [UIFont systemFontOfSize:10];
    data.pointLabelColor = [UIColor blackColor];
    data.pointLabelFormat = @"%0.1f";
    
    data.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
      
        return [GBLineChartDataItem dataItemWithY:[array[item] floatValue] X:[xArray[item] floatValue]];
    };
    
    GBLineChartData *data1 = [GBLineChartData new];
    data1.lineAlpha = 1;
    data1.lineColor = [UIColor orangeColor];
    data1.lineWidth = 1;
    data1.startIndex = data.itemCount-1;
    data1.itemCount = array.count-data1.startIndex;
//    data1.startIndex = 0;
//    data1.itemCount = array.count;
    data1.lineChartPointStyle = GBLineChartPointStyleNone;
    data1.inflexionPointStrokeColor = [UIColor cyanColor];
    data1.inflexionPointWidth = 5;
    
    data1.showPointLabel = NO;
    data1.pointLabelFont = [UIFont systemFontOfSize:10];
    data1.pointLabelColor = [UIColor blackColor];
    data1.pointLabelFormat = @"%1.0f";
    data1.showGradientArea = NO;
    data1.startGradientColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6];
    data1.endGradientColor = [[UIColor yellowColor] colorWithAlphaComponent:0.0];
    
    data1.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
        
        return [GBLineChartDataItem dataItemWithY:[array[item] floatValue] X:[xArray[item] floatValue]];
    };
    
    chart.lineChartDatas = @[data, data1];
    chart.chartMarginLeft = 25;

    chart.yLabelBlockFormatter = ^NSString *(CGFloat value) {
      
        return [NSString stringWithFormat:@"%0.0f", value];
    };
    chart.showSmoothLines = YES;
    [chart strokeChart];
    _lineChart = chart;
}


@end
