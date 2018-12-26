//
//  ViewController.m
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "ViewController.h"
#import "GBLineChart.h"
#import "GBRadarChart.h"
#import "GBRadarChartDataItem.h"
#import "GBCircleChart.h"

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
//    [self radarChart];
//    [self circleChart];
    [self lineChart];
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
        
        return [GBLineChartDataItem dataItemWithY:[array[item] floatValue]];
    };
    [_lineChart updateChartDatas:@[data]];
}

- (void)radarChart {
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *values = @[@8,@5,@7,@3,@6];
    NSArray *descs = @[@"苹果",@"香蕉",@"花生",@"橙子",@"车厘子"];
    for (int i = 0; i < values.count; i++) {
        
        GBRadarChartDataItem *item = [GBRadarChartDataItem dataItemWithValue:[values[i] floatValue] description:descs[i]];
        [items addObject:item];
    }

    GBRadarChart *radarChart = [[GBRadarChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 400) items:items valueDivider:2];
    radarChart.isShowGraduation = YES;
    [radarChart strokeChart];
    [self.view addSubview:radarChart];
    _radarChart = radarChart;
}

- (void)lineChart {
    
    GBLineChart *chart = [[GBLineChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 220)];
    [self.view addSubview:chart];
    chart.XLabelTitles = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月",@"13月",@"14月",@"15月"];
//    chart.YLabelTitles = @[@"0", @"20", @"40", @"60", @"80", @"100"];
    chart.XLabelRotationAngle = M_PI/6;
    
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *array1 = [NSMutableArray array];

    for (int i = 0; i < chart.XLabelTitles.count; i++) {
        NSNumber *a = [NSNumber numberWithInteger:arc4random() % 100];
        [array addObject:a];
        [array1 addObject:[NSNumber numberWithInteger:arc4random() % 100]];
    }
    
    GBLineChartData *data = [GBLineChartData new];
    data.lineAlpha = 0.7;
    data.lineColor = [UIColor blueColor];
    data.lineWidth = 1;
    data.itemCount = array.count;
    data.lineChartPointStyle = GBLineChartPointStyleCircle;
    data.inflexionPointStrokeColor = [UIColor redColor];
    data.inflexionPointFillColor = [UIColor greenColor];
    data.inflexionPointWidth = 6;
    
    data.showPointLabel = YES;
    data.pointLabelFont = [UIFont systemFontOfSize:10];
    data.pointLabelColor = [UIColor blackColor];
    data.pointLabelFormat = @"%0.1f";
    
    data.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
      
        return [GBLineChartDataItem dataItemWithY:[array[item] floatValue]];
    };
    
    GBLineChartData *data1 = [GBLineChartData new];
    data1.lineAlpha = 1;
    data1.lineColor = [UIColor orangeColor];
    data1.lineWidth = 3;
    data1.itemCount = array1.count;
    data1.lineChartPointStyle = GBLineChartPointStyleSquare;
    data1.inflexionPointStrokeColor = [UIColor cyanColor];
    data1.inflexionPointWidth = 5;
    
    data1.showPointLabel = NO;
    data1.pointLabelFont = [UIFont systemFontOfSize:10];
    data1.pointLabelColor = [UIColor blackColor];
    data1.pointLabelFormat = @"%.0f";
    
    data1.dataGetter = ^GBLineChartDataItem *(NSInteger item) {
        
        return [GBLineChartDataItem dataItemWithY:[array1[item] floatValue]];
    };
    
    chart.lineChartDatas = @[data, ];
    chart.showGradientArea = YES;
    chart.chartMarginLeft = 35;
    
    chart.startGradientColor = [[UIColor yellowColor] colorWithAlphaComponent:0.9];
    chart.endGradientColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    chart.yLabelBlockFormatter = ^NSString *(CGFloat value) {
      
        return [NSString stringWithFormat:@"%1.1f", value];
    };
    chart.showSmoothLines = YES;
    [chart strokeChart];
    _lineChart = chart;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    
////    [_chart updateChartDatas:@[@"30",@"60",@"45",@"100",@"70",@"70",@"65"]];
//    NSMutableArray *items = [NSMutableArray array];
//    NSArray *values = @[@1,@6,@4,@8,@5];
//    for (int i = 0; i < 5; i++) {
//        GBRadarChartDataItem *item = [GBRadarChartDataItem dataItemWithValue:[values[i] floatValue] description:@"我的知识点"];
//        [items addObject:item];
//    }
//    [_radarChart updateChartWithChartData:items];
//}


@end
