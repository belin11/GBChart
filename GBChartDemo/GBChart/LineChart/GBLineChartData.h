//
//  GBLineChartData.h
//  GBChartDemo
//
//  Created by midas on 2018/12/21.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GBLineChartPointStyle) {
    
    GBLineChartPointStyleNone = 0,
    GBLineChartPointStyleCircle = 1, //圆形
    GBLineChartPointStyleSquare = 2, //方形
    GBLineChartPointStyleTriangle = 3, //三角形
};

@interface GBLineChartDataItem : NSObject

@property (nonatomic, assign) CGFloat y;

@property (nonatomic, assign) CGFloat x;

+ (id)dataItemWithY:(CGFloat)Y X:(CGFloat)X;

@end

typedef GBLineChartDataItem * (^GBLineChartDataGetter)(NSInteger item);

@interface GBLineChartData : NSObject

@property (nonatomic, copy) GBLineChartDataGetter dataGetter;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) BOOL showPointLabel;
@property (nonatomic, strong) UIColor *pointLabelColor;
@property (nonatomic, strong) UIFont *pointLabelFont;
@property (nonatomic, strong) NSString *pointLabelFormat;

@property (nonatomic, assign) BOOL showDash;
@property (nonatomic, strong) NSArray <NSNumber *> *lineDashPattern;

@property (nonatomic, assign) GBLineChartPointStyle lineChartPointStyle;
@property (nonatomic, assign) CGFloat inflexionPointWidth;
@property (nonatomic, strong) UIColor *inflexionPointFillColor;
@property (nonatomic, strong) UIColor *inflexionPointStrokeColor;

//渐变区域
/** 是否显示折线围成的渐变区域, 默认为0*/
@property (nonatomic, assign) BOOL showGradientArea;
/** 渐变开始的颜色 */
@property (nonatomic, strong) UIColor *startGradientColor;
/** 渐变结束的颜色 */
@property (nonatomic, strong) UIColor *endGradientColor;

@end
