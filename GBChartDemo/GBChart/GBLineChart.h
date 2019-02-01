//
//  GBLineChart.h
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBLineChartData.h"

typedef NS_ENUM(NSInteger, GBXLabelAlignmentStyle) {
    
    GBXLabelAlignmentStyleFitXAxis = 0,
    GBXLabelAlignmentStyleFullXAxis = 1
};

@interface GBLineChart : UIView

/******************* xLabel属性 ***************************/
/** xlabel宽度，默认是根据x轴宽度计算平分或字体最大宽度取最大值 */
@property (nonatomic, assign) CGFloat xLabelWidth;
/** xlabel字体  默认10 */
@property (nonatomic, strong) UIFont *xLabelFont;
/** xlabel颜色 默认是graycolor */
@property (nonatomic, strong) UIColor *xLabelColor;
/** x轴上的标题 */
@property (nonatomic, strong) NSArray *xLabelTitles;
/** xLabel旋转角度，默认为0 */
@property (nonatomic, assign) CGFloat xLabelRotationAngle;
/** xLabel对齐方式 */
@property (nonatomic, assign) GBXLabelAlignmentStyle xLabelAlignmentStyle;

/******************* yLabel属性 ***************************/
/** 是否显示Y坐标值，默认YES */
@property (nonatomic, assign) BOOL showYLabels;
/** ylabel高度，默认根据y轴高度计算平分 */
@property (nonatomic) CGFloat yLabelHeight;
/** ylabel字体 默认10 */
@property (nonatomic) UIFont *yLabelFont;
/** ylabel颜色 默认graycolor */
@property (nonatomic) UIColor *yLabelColor;
/** y轴上的标题 */
@property (nonatomic, strong) NSArray *yLabelTitles;
/** y轴label数据的格式，默认是 @"%1.f" */
@property (nonatomic, strong) NSString *yLabelFormat;
/**Block formatter for custom string in y-axis labels. If not set, defaults to yLabelFormat */
@property (nonatomic, copy) NSString* (^yLabelBlockFormatter)(CGFloat value);

/******************* 坐标轴属性 ***************************/

/** 距左边距，默认25 */
@property (nonatomic, assign) CGFloat chartMarginLeft;
/** 距右边距，默认25 */
@property (nonatomic, assign) CGFloat chartMarginRight;
/** 距上边距，默认0 */
@property (nonatomic, assign) CGFloat chartMarginTop;
/** 距下边距，默认25 */
@property (nonatomic, assign) CGFloat chartMarginBottom;

/** 是否显示x y坐标轴,默认YES */
@property (nonatomic, assign) BOOL showCoordinateAxis;
/** 坐标轴线宽，默认为1 */
@property (nonatomic, assign) CGFloat coordinateAxisLineWidth;
/** 坐标轴颜色，默认darkgray */
@property (nonatomic, strong) UIColor *coordinateAxisColor;
/** x坐标轴颜色，默认darkgray */
@property (nonatomic, strong) UIColor *xAxisColor;
/** y坐标轴颜色，默认darkgray */
@property (nonatomic, strong) UIColor *yAxisColor;

/******************* 横向网格线属性 ***************************/
/** 是否显示网格线，默认YES */
@property (nonatomic, assign) BOOL showYGridsLine;
/** 网格线线宽，默认为1 */
@property (nonatomic, assign) CGFloat yGridsLineWidth;
/** 风格线颜色，默认是lightgray */
@property (nonatomic, strong) UIColor *yGridsLineColor;
/** 风格线是否dash 默认YES */
@property (nonatomic, assign) BOOL showYGridsLineDash;

/******************* 折线属性 ***************************/
/**折线图上的数据*/
@property (nonatomic, strong) NSArray <GBLineChartData *> *lineChartDatas;
/** 是否有动画，默认YES */
@property (nonatomic, assign) BOOL displayAnimated;
/** 是否圆滑曲线，默认NO */
@property (nonatomic) BOOL showSmoothLines;

/******************* Method ***************************/
/** 画折线图 */
- (void)strokeChart;
/** 更新折线图
 @param datas GBLineChart数组
 */
- (void)updateChartDatas:(NSArray <GBLineChartData *> *)datas;

@end
