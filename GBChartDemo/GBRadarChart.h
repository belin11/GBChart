//
//  GBRadarChart.h
//  GBChartDemo
//
//  Created by midas on 2018/12/11.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBRadarChartDataItem;

@interface GBRadarChart : UIView

/**
 初始化图表

 @param frame frame
 @param items 模型数组
 @param unitValue 均分值
 @return 对象
 */
- (id)initWithFrame:(CGRect)frame items:(NSArray <GBRadarChartDataItem *> *)items valueDivider:(CGFloat)unitValue;

/** 绘制图表 */
- (void)strokeChart;

/**
 更新图表

 @param chartData <#chartData description#>
 */
- (void)updateChartWithChartData:(NSArray *)chartData;

/** Array of `RadarChartDataItem` objects, one for each corner. */
@property (nonatomic) NSArray <GBRadarChartDataItem *> *chartData;
/** The unit of this chart ,default is 1 */
@property (nonatomic) CGFloat valueDivider;
/** The maximum for the range of values to display on the chart */
@property (nonatomic) CGFloat maxValue;
/** Default is gray. */
@property (nonatomic) UIColor *webColor;
/** Default is green , with an alpha of 0.7 */
@property (nonatomic) UIColor *plotFillColor;

@property (nonatomic) UIColor *plotStrokeColor;
/** Default is black */
@property (nonatomic) UIColor *fontColor;
/** Default is orange 刻度颜色*/
@property (nonatomic) UIColor *graduationColor;
/** Default is 12 */
@property (nonatomic) CGFloat fontSize;
/** Controls the labels display style that around chart */
//@property (nonatomic, assign) PNRadarChartLabelStyle labelStyle;
/** Tap the label will display detail value ,default is YES. */
@property (nonatomic, assign) BOOL isLabelTouchable;
/** is show graduation on the chart ,default is NO. */
@property (nonatomic, assign) BOOL isShowGraduation;
/** 是否有动画 */
@property (nonatomic, assign) BOOL displayAnimated;

@end
