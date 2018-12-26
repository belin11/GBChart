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
    GBLineChartPointStyleCircle = 1,
    GBLineChartPointStyleSquare = 3,
    GBLineChartPointStyleTriangle = 4
};

@interface GBLineChartDataItem : NSObject

@property (nonatomic, assign) CGFloat y;

+ (id)dataItemWithY:(CGFloat)Y;

@end

typedef GBLineChartDataItem * (^GBLineChartDataGetter)(NSInteger item);

@interface GBLineChartData : NSObject

@property (nonatomic, copy) GBLineChartDataGetter dataGetter;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) BOOL showPointLabel;
@property (nonatomic, strong) UIColor *pointLabelColor;
@property (nonatomic, strong) UIFont *pointLabelFont;
@property (nonatomic, strong) NSString *pointLabelFormat;


@property (nonatomic, assign) GBLineChartPointStyle lineChartPointStyle;
@property (nonatomic, assign) CGFloat inflexionPointWidth;
@property (nonatomic, strong) UIColor *inflexionPointFillColor;
@property (nonatomic, strong) UIColor *inflexionPointStrokeColor;


@end
