//
//  GBRadarChart.h
//  GBChartDemo
//
//  Created by midas on 2018/12/11.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBRadarChartDataItem;

typedef NS_ENUM(NSUInteger, GBRadarChartLabelStyle) {
    GBRadarChartLabelStyleCircle = 0, //圆环
    GBRadarChartLabelStyleHorizontal, //水平
    GBRadarChartLabelStyleHidden, //隐藏
};

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
 @param chartData 模型数组
 */
- (void)updateChartWithChartData:(NSArray <GBRadarChartDataItem *> *)chartData;

/** Array of `RadarChartDataItem` objects, one for each corner. */
@property (nonatomic, strong) NSArray <GBRadarChartDataItem *> *chartDataItems;
/** 展示的样式 */
@property (nonatomic, assign) GBRadarChartLabelStyle labelStyle;
/** The unit of this chart ,default is 1 */
@property (nonatomic, assign) CGFloat valueDivider;
/** The maximum for the range of values to display on the chart */
@property (nonatomic, assign) CGFloat maxValue;
/** Default is gray. */
@property (nonatomic, strong) UIColor *webColor;
/** Default is green , with an alpha of 0.7 */
@property (nonatomic, strong) UIColor *plotFillColor;
/** Default is green*/
@property (nonatomic, strong) UIColor *plotStrokeColor;
/** Default is black */
@property (nonatomic, strong) UIColor *fontColor;
/** Default is orange */
@property (nonatomic, strong) UIColor *graduationColor;
/** Default is 12 */
@property (nonatomic, assign) CGFloat titleFontSize;
/** Tap the label will display detail value ,default is YES. */
@property (nonatomic, assign) BOOL canLabelTouchable;
/** is show graduation on the chart ,default is NO. */
@property (nonatomic, assign) BOOL isShowGraduation;
/** is display animated, default is YES */
@property (nonatomic, assign) BOOL displayAnimated;
/** 是否是顺时针方向绘制，默认是YES*/
@property (nonatomic, assign) BOOL clockwise;

@end
