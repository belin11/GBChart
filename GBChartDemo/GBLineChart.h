//
//  GBLineChart.h
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBLineChartData.h"

@interface GBLineChart : UIView

/**
 坐标轴的高度
 */
@property (nonatomic) CGFloat chartCavanHeight;

/**
 坐标轴的宽度
 */
@property (nonatomic) CGFloat chartCavanWidth;

/**
 距四周的边距
 */
@property (nonatomic) CGFloat chartMarginLeft;
@property (nonatomic) CGFloat chartMarginRight;
@property (nonatomic) CGFloat chartMarginTop;
@property (nonatomic) CGFloat chartMarginBottom;

@property (nonatomic) CGFloat xLabelWidth;
@property (nonatomic) UIFont *xLabelFont;
@property (nonatomic) UIColor *xLabelColor;

@property (nonatomic) CGFloat yLabelHeight;
@property (nonatomic) UIFont *yLabelFont;
@property (nonatomic) UIColor *yLabelColor;

/**
 是否显示坐标轴
 */
@property (nonatomic, assign) BOOL showCoordinateAxis;

/**
 坐标轴线宽，默认为1
 */
@property (nonatomic, assign) CGFloat coordinateAxisLineWidth;

/**
 坐标轴颜色，默认black
 */
@property (nonatomic, strong) UIColor *coordinateAxisColor;

/**
 x坐标轴颜色，默认black
 */
@property (nonatomic, strong) UIColor *xAxisColor;

/**
 y坐标轴颜色，默认black
 */
@property (nonatomic, strong) UIColor *yAxisColor;
/**
 是否显示网格线
 */
@property (nonatomic, assign) BOOL showYGridsLine;

/**
 网格线线宽，默认为1
 */
@property (nonatomic, assign) CGFloat yGridsLineWidth;

/**
 网络线颜色，默认是dark
 */
@property (nonatomic, strong) UIColor *yGridsLineColor;

/**
 x轴上的标题
 */
@property (nonatomic, strong) NSArray *XLabelTitles;

/**
 x轴Label旋转角度，默认为0
 */
@property (nonatomic, assign) CGFloat XLabelRotationAngle;

/**
 y轴上的标题
 */
@property (nonatomic, strong) NSArray *YLabelTitles;

/**
 是否显示折线围成的渐变区域
 */
@property (nonatomic, assign) BOOL showGradientArea;

/**
 渐变开始的颜色
 */
@property (nonatomic, strong) UIColor *startGradientColor;

/**
 渐变结束的颜色
 */
@property (nonatomic, strong) UIColor *endGradientColor;

/**
 * y轴label数据的格式，默认是 @"%1.f"
 */
@property (nonatomic, strong) NSString *yLabelFormat;

/**
 * Block formatter for custom string in y-axis labels. If not set, defaults to yLabelFormat
 */
@property (nonatomic, copy) NSString* (^yLabelBlockFormatter)(CGFloat value);

/**
 坐标轴内的数组
 */
@property (nonatomic, strong) NSArray *lineChartDatas;

/**
 是否有动画，默认有
 */
@property (nonatomic, assign) BOOL displayAnimated;

/**
 是否显示Y坐标值，默认显示
 */
@property (nonatomic, assign) BOOL showYLabels;

/**
 是否使线圆滑
 */
@property (nonatomic) BOOL showSmoothLines;
//画折线图
- (void)strokeChart;
//更新折线图
- (void)updateChartDatas:(NSArray *)datas;

@end
