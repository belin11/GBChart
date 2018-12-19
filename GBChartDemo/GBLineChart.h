//
//  GBLineChart.h
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <UIKit/UIKit.h>

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

/**
 x轴上的标题
 */
@property (nonatomic, strong) NSArray *XLabelTitles;

/**
 坐标轴内的点的值
 */
@property (nonatomic, strong) NSArray *lineChartDatas;
//画折线图
- (void)strokeChart;
//更新折线图
- (void)updateChartDatas:(NSArray *)datas;

@end
