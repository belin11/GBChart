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
    GBLineChart *_chart;
    GBRadarChart *_radarChart;
    GBCircleChart *_circleChart;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
//    [self radarChart];
    [self circleChart];
}

- (void)circleChart {
    
    GBCircleChart *circleChart = [[GBCircleChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200) total:@100 current:@30 clockwise:YES shadow:YES shadowColor:[[UIColor grayColor] colorWithAlphaComponent:0.4] displayCountingLabel:YES overrideLineWidth:@10];
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
    [_circleChart updateChartByCurrent:@80];
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
    chart.XLabelTitles = @[@"11.2",@"11.3",@"11.4",@"11.5",@"11.6",@"11.7",@"今日",];
    chart.lineChartDatas = @[@"20",@"40",@"25",@"100",@"90",@"50",@"69"];
    [chart strokeChart];
    _chart = chart;
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
