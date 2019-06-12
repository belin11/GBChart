//
//  GBLineChart.m
//  GBChartDemo
//
//  Created by midas on 2018/12/10.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBLineChart.h"
#import "GBLineChartData.h"

@interface GBLineChart ()

@property(nonatomic) NSMutableArray *chartLineArrayArray;  // Array Array[CAShapeLayer] save the line layer
@property(nonatomic) NSMutableArray *chartPointArrayArray; // Array Array[CAShapeLayer] save the point layer

@property(nonatomic) NSMutableArray *linePathArrayArray; // Array of line path, one for each line.
@property(nonatomic) NSMutableArray *pointPathArrayArray;// Array of point path, one for each point.

@property (nonatomic) NSMutableArray *pointValueArrayArray;
@property (nonatomic) NSMutableArray *pointLabelArrayArray;
@property (nonatomic) NSMutableArray *yValueLabelArray;
@property (nonatomic) NSMutableArray *xValueLabelArray;
@property (nonatomic) NSMutableArray *gradientLayerArray;

@property (nonatomic, assign) CGFloat xStep;
@property (nonatomic, assign) CGFloat yStep;

@property (nonatomic) CGFloat yValueMax;
@property (nonatomic) CGFloat yValueMin;
@property (nonatomic) NSInteger yLabelNum;

@property (nonatomic, assign) CGPoint targetPoint;

@property (nonatomic, strong) CAAnimation *strokeEndAnimation;

/**
 坐标轴的高度
 */
@property (nonatomic) CGFloat chartCavanHeight;

/**
 坐标轴的宽度
 */
@property (nonatomic) CGFloat chartCavanWidth;

@end

@implementation GBLineChart

#pragma mark - 初始化
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self configDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self configDefaultValues];
    }
    return self;
}

#pragma mark - 设置默认属性
- (void)configDefaultValues {
    
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.chartLineArrayArray = [NSMutableArray new];
    self.chartPointArrayArray = [NSMutableArray new];
    self.pointPathArrayArray = [NSMutableArray new];
    self.linePathArrayArray = [NSMutableArray new];
    self.pointLabelArrayArray = [NSMutableArray new];
    self.pointValueArrayArray = [NSMutableArray new];
    self.yValueLabelArray = [NSMutableArray new];
    self.xValueLabelArray = [NSMutableArray new];
    self.gradientLayerArray = [NSMutableArray new];
    
    _displayAnimated = YES;
    _showCoordinateAxis = YES;
    _showYGridsLineDash = YES;
    _showYLabels = YES;
    _coordinateAxisLineWidth = 1;
    _coordinateAxisColor = [UIColor darkGrayColor];
    _xAxisColor = _coordinateAxisColor;
    _yAxisColor = _coordinateAxisColor;
    _showYGridsLine = YES;
    _yGridsLineColor = [UIColor lightGrayColor];
    _yGridsLineWidth = 1;
    
    _chartMarginLeft = 25.0;
    _chartMarginRight = 25.0;
    _chartMarginTop = 0.0;
    _chartMarginBottom = 25.0;
    
    _xLabelColor = [UIColor grayColor];
    _xLabelFont = [UIFont systemFontOfSize:10];
    
    _yLabelFont = [UIFont systemFontOfSize:10];
    _yLabelColor = [UIColor grayColor];
    _yLabelFormat = @"%.0f";
    
    _verticalLineXValue = 0;
    _showVerticalLine = NO;
    _verticalLineWidth = 1;
    _verticalLineColor = [UIColor blackColor];
    
    _chartCavanWidth = self.frame.size.width - _chartMarginLeft - _chartMarginRight;
    _chartCavanHeight = self.frame.size.height - _chartMarginBottom - _chartMarginTop;
}

#pragma mark - setter方法
- (void)setCoordinateAxisColor:(UIColor *)coordinateAxisColor {
    _coordinateAxisColor = coordinateAxisColor;
    _xAxisColor = coordinateAxisColor;
    _yAxisColor = coordinateAxisColor;
}

#pragma mark - Public Method
#pragma mark - 画图表
- (void)strokeChart {
    
    [self calcuateChart];
    [self setXLabel];
    if (_showYLabels) {
        [self setYLabel];
    }
    [self setGradientLayer];

    [self populateChartLines];
    
    if (_displayAnimated) {
        [self addAnimationIfNeeded];
    }
    [self createPointLabel];
    
    [self strokeVerticalLine];
 
    [self setNeedsDisplay];
}

#pragma mark - 画竖线
- (void)strokeVerticalLine {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat x = [self getXPointWithXValue:_verticalLineXValue];
    [path moveToPoint:CGPointMake(x, _chartMarginTop+_chartCavanHeight)];
    [path addLineToPoint:CGPointMake(x, _chartCavanHeight/_yLabelNum)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = _verticalLineColor.CGColor;
    layer.lineWidth = _verticalLineWidth;
    layer.path = path.CGPath;
    [self.layer addSublayer:layer];
}

#pragma mark - 获取x方向的坐标
- (CGFloat)getXPointWithXValue:(CGFloat)xValue {
    
    CGFloat xMaxValue = [_xLabelTitles.lastObject floatValue];
    CGFloat xMinValue = [_xLabelTitles.firstObject floatValue];
    
    CGFloat x;
    if (_xLabelAlignmentStyle == GBXLabelAlignmentStyleFullXAxis) {
        CGFloat position = (xValue-xMinValue) / (xMaxValue-xMinValue)* _chartCavanWidth;
        x = _chartMarginLeft + position;
    } else {
        CGFloat position = (xValue-xMinValue) / (xMaxValue-xMinValue)* _xStep*(_xLabelTitles.count-1);
        x = _chartMarginLeft  + _xStep/2 + position;
    }
    
    return x;
}

#pragma mark - 更新图表
- (void)updateChartDatas:(NSArray <GBLineChartData *> *)data {
    
    [self removeAllLayers];
    [self removeAllSubviews];
    [self removeAllObjects];
    _lineChartDatas = data;
    [self strokeChart];
}

#pragma mark - 创建点Label
- (void)createPointLabel {
    
    for (int i = 0; i < _lineChartDatas.count; i++) {
        
        GBLineChartData *chartData = _lineChartDatas[i];
        NSArray <NSValue *> *pointValueArray = _pointValueArrayArray[i];
        if (chartData.showPointLabel) {//显示点
            
            NSInteger item = 0;
            NSMutableArray *pointLabelArray = [NSMutableArray array];
            for (NSValue *value in pointValueArray) {
                UILabel *label = [UILabel new];
                label.font = chartData.pointLabelFont;
                label.textColor = chartData.pointLabelColor;
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [NSString stringWithFormat:chartData.pointLabelFormat, chartData.dataGetter(item).y];
                CGPoint position = value.CGPointValue;
                CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName : label.font}];
                label.frame = CGRectMake(position.x - size.width/2, position.y - size.height-chartData.inflexionPointWidth, size.width, size.height);
                [self addSubview:label];
                [pointLabelArray addObject:label];
                item++;
            }
            [self.pointLabelArrayArray addObject:pointLabelArray];
        }
    }
}
#pragma mark - 添加动画
- (void)addAnimationIfNeeded {
    
    for (int i = 0; i < _chartLineArrayArray.count; i++) {
        
        NSArray <CAShapeLayer *> *chartLineArr = _chartLineArrayArray[i];
        for (CAShapeLayer *line in chartLineArr) {
            [line addAnimation:self.strokeEndAnimation forKey:@"ss"];
        }
    }
    for (int i = 0; i < _chartPointArrayArray.count; i++) {
        NSArray <CAShapeLayer *> *chartPointArr = _chartPointArrayArray[i];
        for (CAShapeLayer *point in chartPointArr) {
            [point addAnimation:self.strokeEndAnimation forKey:@"11"];
        }
    }
}
#pragma mark - strokeEndAnimation
- (CAAnimation *)strokeEndAnimation {
    
    if (!_strokeEndAnimation) {
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 1;
        _strokeEndAnimation= ani;
    }
    return _strokeEndAnimation;
}

#pragma mark - 获取Y最大值最小值
- (void)getYValueMaxAndYValueMin {
    
    if (_yLabelTitles) {
        _yValueMax = [_yLabelTitles.lastObject floatValue];
        _yValueMin = [_yLabelTitles.firstObject floatValue];
        _yLabelNum = _yLabelTitles.count;
    } else {
        
        for (int i = 0; i < _lineChartDatas.count; i++) {
            GBLineChartData *chartData = _lineChartDatas[i];
            for (int j = 0; j < chartData.itemCount; j++) {
                CGFloat yValue = chartData.dataGetter(j).y;
                _yValueMax = MAX(_yValueMax, yValue);
                _yValueMin = MIN(_yValueMin, yValue);
            }
        }
        _yLabelNum = 6;
    }
}

#pragma mark - 计算
- (void)calcuateChart {
    
    [self getYValueMaxAndYValueMin];

    if (_xLabelAlignmentStyle == GBXLabelAlignmentStyleFullXAxis) {
        _xStep = _chartCavanWidth/(_xLabelTitles.count-1);
    } else {
        _xStep = _chartCavanWidth/_xLabelTitles.count;
    }
    _yStep = _chartCavanHeight/_yLabelNum;
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    for (int i = 0; i < _lineChartDatas.count; i++) {
        
        GBLineChartData *chartData = _lineChartDatas[i];
        //点的数组
        NSMutableArray *pointValueArray = [NSMutableArray array];
        for (NSInteger item = chartData.startIndex; item < chartData.itemCount+chartData.startIndex; item++) {
            ///点的横坐标
            CGFloat center_x = [self getXPointWithXValue:chartData.dataGetter(item).x];
            
            CGFloat yValue1 = chartData.dataGetter(item).y;
            if (yValue1 < _yValueMin || yValue1 > _yValueMax) {
                
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"值只能在最小值与最大值之间" userInfo:nil];
            }
            ///点的纵坐标
            CGFloat center_y =  yAxisMax - (yValue1-_yValueMin)/(_yValueMax-_yValueMin) * (_chartCavanHeight-_yStep);
            NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(center_x, center_y)];
            [pointValueArray addObject:pointValue];
        }
        [_pointValueArrayArray addObject:pointValueArray];
        //点
        NSMutableArray *pointPathArray = [NSMutableArray array];
        for (NSInteger item = chartData.startIndex; item < chartData.itemCount+chartData.startIndex; item++) {
            CGFloat center_x = [self getXPointWithXValue:chartData.dataGetter(item).x];
            CGFloat center_y =  yAxisMax - (chartData.dataGetter(item).y-_yValueMin)/(_yValueMax-_yValueMin) * (_chartCavanHeight-_yStep);
            UIBezierPath *path = [UIBezierPath bezierPath];
            if (chartData.lineChartPointStyle == GBLineChartPointStyleCircle) {//圆
                path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(center_x, center_y) radius:chartData.inflexionPointWidth/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
          
            } else if (chartData.lineChartPointStyle == GBLineChartPointStyleSquare) {//方形
                path = [UIBezierPath bezierPathWithRect:CGRectMake(center_x-chartData.inflexionPointWidth/2, center_y - chartData.inflexionPointWidth/2, chartData.inflexionPointWidth, chartData.inflexionPointWidth)];
            } else if (chartData.lineChartPointStyle == GBLineChartPointStyleTriangle) { //三角形
                path = [UIBezierPath bezierPath];
                CGFloat x1 = center_x;
                CGFloat y1 = center_y - chartData.inflexionPointWidth;
                CGFloat x2 = center_x - chartData.inflexionPointWidth * sinf(M_PI/3);
                CGFloat y2 = center_y + chartData.inflexionPointWidth * cosf(M_PI/3);
                CGFloat x3 = center_x + chartData.inflexionPointWidth * sinf(M_PI/3);
                CGFloat y3 = y2;
                [path moveToPoint:CGPointMake(x1, y1)];
                [path addLineToPoint:CGPointMake(x2, y2)];
                [path addLineToPoint:CGPointMake(x3, y3)];
                [path closePath];
            }
            [pointPathArray addObject:path];
        }
        [_pointPathArrayArray addObject:pointPathArray];
    }
    
    if (_showSmoothLines) { //曲线
        for (int i = 0; i < _pointValueArrayArray.count; i++) {
            NSMutableArray *pointValueArray = _pointValueArrayArray[i];
            if (pointValueArray.count==0) {
                continue;
            }
            CGPoint startPoint = [pointValueArray[0] CGPointValue];
            startPoint = CGPointMake(startPoint.x-_xStep, startPoint.y);
            CGPoint endPoint = [pointValueArray.lastObject CGPointValue];
            endPoint = CGPointMake(endPoint.x+_xStep, endPoint.y);
            [pointValueArray insertObject:[NSValue valueWithCGPoint:startPoint] atIndex:0];
            [pointValueArray addObject:[NSValue valueWithCGPoint:endPoint]];
            
            NSMutableArray *chartLinePathArray = [NSMutableArray array];
            for (int j = 0; j < pointValueArray.count-3; j++) {
                
                CGPoint p0 = [pointValueArray[j] CGPointValue];
                CGPoint p1 = [pointValueArray[j+1] CGPointValue];
                CGPoint p2 = [pointValueArray[j+2] CGPointValue];
                CGPoint p3 = [pointValueArray[j+3] CGPointValue];
                
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:p1];
                if (p1.y == _chartCavanHeight + _chartMarginTop && p2.y == _chartCavanHeight + _chartMarginTop) {
                    [self getLinePathx1:p2.x andy1:p2.y path:path];
                } else {
            
                    [self getControlPointx0:p0.x andy0:p0.y x1:p1.x andy1:p1.y x2:p2.x andy2:p2.y x3:p3.x andy3:p3.y path:path];
                }
                [chartLinePathArray addObject:path];
            }
            
            [pointValueArray removeObjectAtIndex:0];
            [pointValueArray removeLastObject];
            [_linePathArrayArray addObject:chartLinePathArray];

        }
    }
#if 1
    else {//直线
        
        for (int i = 0; i < _pointValueArrayArray.count; i++) {
            NSArray *pointValueArray = _pointValueArrayArray[i];
            NSMutableArray *chartLinePathArray = [NSMutableArray array];
            for (int j = 0; j < pointValueArray.count-1; j++) {
                
                CGPoint point0 = [pointValueArray[j] CGPointValue];
                CGPoint point1 = [pointValueArray[j+1] CGPointValue];
                
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:point0];
                [path addLineToPoint:point1];
                [chartLinePathArray addObject:path];
            }
            [_linePathArrayArray addObject:chartLinePathArray];
        }
    }
    
#endif 
}

- (CGFloat)valueForBezierWithP0:(CGFloat)P0 P1:(CGFloat)P1 P2:(CGFloat)P2 P3:(CGFloat)P3 t:(CGFloat)t {
    
    return powf(1-t, 3)*P0 + 3*t*powf((1-t), 2)*P1 + 3*powf(t, 2)*(t-t)*P2 + powf(t, 3)*P3;
}

#pragma mark - 布局折线
- (void)populateChartLines {
    //线
    for (int i = 0; i < _linePathArrayArray.count; i++) {
        
        GBLineChartData *chartData = _lineChartDatas[i];
        NSMutableArray <UIBezierPath *> *linePathArray = _linePathArrayArray[i];
        NSMutableArray *chartLineArray = [NSMutableArray array];
        for (UIBezierPath *path in linePathArray) {
            CAShapeLayer *line = [CAShapeLayer layer];
            line.lineCap = kCALineCapButt;
            line.lineJoin = kCALineJoinMiter;
            line.lineWidth = chartData.lineWidth;
            line.strokeColor = [chartData.lineColor colorWithAlphaComponent:chartData.lineAlpha].CGColor;
            line.path = path.CGPath;
            line.fillColor = [UIColor clearColor].CGColor;
            if (chartData.showDash) {
                line.lineDashPattern = chartData.lineDashPattern;
            }
            [self.layer addSublayer:line];
            [chartLineArray addObject:line];
        }
        [_chartLineArrayArray addObject:chartLineArray];
    }
    //点
    for (int i = 0; i < _pointPathArrayArray.count; i++) {
        GBLineChartData *chartData = _lineChartDatas[i];
        NSMutableArray <UIBezierPath *> *pointPathArray = _pointPathArrayArray[i];
        NSMutableArray *pointLayerArr = [NSMutableArray array];
        for (UIBezierPath *path in pointPathArray) {
            CAShapeLayer *pointLayer = [CAShapeLayer layer];
            pointLayer.strokeColor = chartData.inflexionPointStrokeColor.CGColor;
            pointLayer.fillColor = chartData.inflexionPointFillColor.CGColor;
            pointLayer.path = path.CGPath;
            [self.layer addSublayer:pointLayer];
            [pointLayerArr addObject:pointLayer];
        }
        [_chartPointArrayArray addObject:pointLayerArr];
    }
}

#pragma mark - 移除
#pragma mark 移除所有layers
- (void)removeAllLayers {
    
    for (NSArray <CALayer *> *layers in self.chartPointArrayArray) {
        for (CALayer *layer in layers) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
    
    for (NSArray <CALayer *> *layers in self.chartLineArrayArray) {
        for (CALayer *layer in layers) {
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }

    for (CALayer *layer in self.gradientLayerArray) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
    
}

#pragma mark 移除所有subviews
- (void)removeAllSubviews {
    
    for (NSArray <UILabel *> *views in _pointLabelArrayArray) {
        for (UILabel *label in views) {
            [label removeFromSuperview];
        }
    }
    for (UILabel *label in _yValueLabelArray) {
        [label removeFromSuperview];
    }
    for (UILabel *label in _xValueLabelArray) {
        [label removeFromSuperview];
    }
}

#pragma mark 移除所有数据
- (void)removeAllObjects {
    
    [self.pointValueArrayArray removeAllObjects];
    [self.chartPointArrayArray removeAllObjects];
    [self.pointLabelArrayArray removeAllObjects];
    [self.chartLineArrayArray removeAllObjects];
    [self.linePathArrayArray removeAllObjects];
    [self.pointPathArrayArray removeAllObjects];
    [self.yValueLabelArray removeAllObjects];
    [self.xValueLabelArray removeAllObjects];
}

#pragma mark - 创建坐标轴的label
- (void)setYLabel {
    //从下往上布局
    CGFloat divideSeperetor = (_yValueMax - _yValueMin)/(_yLabelNum-1);
    for (int i = 0; i < _yLabelNum; i++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForYLabelAtIndex:i]];
        label.font = _yLabelFont;
        label.textColor = _yLabelColor;
        NSString *value = [NSString stringWithFormat:_yLabelFormat, _yValueMin + divideSeperetor*i];
        if (_yLabelBlockFormatter) {
            value = _yLabelBlockFormatter(_yValueMin + divideSeperetor*i);
        }
        label.text = value;
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
        [self.yValueLabelArray addObject:label];
    }
}

- (void)setXLabel{
    
    //从左到右
    for (int i = 0; i < _xLabelTitles.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:[self frameForXLabelAtIndex:i]];
        label.font = _xLabelFont;
        label.textColor = _xLabelColor;
        label.text = _xLabelTitles[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.transform = CGAffineTransformMakeRotation(_xLabelRotationAngle);
        [self addSubview:label];
        [self.xValueLabelArray addObject:label];
    }
}

#pragma mark - 创建渐变图层
- (void)setGradientLayer {
    
    for (int i = 0; i < _pointValueArrayArray.count; i++) {
        
        NSMutableArray *pointValueArray = _pointValueArrayArray[i];
        if (!_lineChartDatas[i].showGradientArea) {
            continue;
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        if (_showSmoothLines) { //曲线
            if (pointValueArray.count==0) {
                continue;
            }
            CGPoint startPoint = [pointValueArray[0] CGPointValue];
            startPoint = CGPointMake(startPoint.x-_xStep, startPoint.y);
            CGPoint endPoint = [pointValueArray.lastObject CGPointValue];
            endPoint = CGPointMake(endPoint.x+_xStep, endPoint.y);
            [pointValueArray insertObject:[NSValue valueWithCGPoint:startPoint] atIndex:0];
            [pointValueArray addObject:[NSValue valueWithCGPoint:endPoint]];
            
            for (int j = 0; j < pointValueArray.count - 3;j++) {
                CGPoint p0 = [pointValueArray[j] CGPointValue];
                CGPoint p1 = [pointValueArray[j+1] CGPointValue];
                CGPoint p2 = [pointValueArray[j+2] CGPointValue];
                CGPoint p3 = [pointValueArray[j+3] CGPointValue];
                if (j == 0) {
                    [path moveToPoint:p1];
                }
                if (p1.y == 0.0 && p2.y == 0.0) {
                    [self getLinePathx1:p2.x andy1:p2.y path:path];
                } else {
                    [self getControlPointx0:p0.x andy0:p0.y x1:p1.x andy1:p1.y x2:p2.x andy2:p2.y x3:p3.x andy3:p3.y path:path];
                }
               
            }
            
            [pointValueArray removeObjectAtIndex:0];
            [pointValueArray removeLastObject];
            
        } else { //直线
            for (int j = 0 ; j < pointValueArray.count; j++) {
                if (j == 0) {
                    [path moveToPoint:[pointValueArray[j] CGPointValue]];
                }
                [path addLineToPoint:[pointValueArray[j] CGPointValue]];
            }
        }
     

        CGPoint point1 = [pointValueArray.firstObject CGPointValue];
        CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
        point1 = CGPointMake(point1.x, yAxisMax);
        
        CGPoint point2 = [pointValueArray.lastObject CGPointValue];
        point2 = CGPointMake(point2.x, yAxisMax);
        [path addLineToPoint:point2];
        [path addLineToPoint:point1];
        [path closePath];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = path.CGPath;
        maskLayer.strokeColor = [UIColor clearColor].CGColor;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        [self.layer addSublayer:gradientLayer];
        gradientLayer.colors = @[(__bridge id)_lineChartDatas[i].startGradientColor.CGColor, (__bridge id)_lineChartDatas[i].endGradientColor.CGColor];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
        gradientLayer.mask = maskLayer;
        gradientLayer.zPosition = -10;
        [self.gradientLayerArray addObject:gradientLayer];
        
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"opacity"];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = 1.5;
        [gradientLayer addAnimation:ani forKey:nil];
    }
}

#pragma mark - YLabel Frame XLabel Frame
- (CGRect)frameForYLabelAtIndex:(NSInteger)index {
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat w = _chartMarginLeft-4;
    _yLabelHeight = _chartCavanHeight / _yLabelNum;
    CGFloat x = 0;
    CGFloat y = yAxisMax - index* _yLabelHeight - _yLabelHeight/2;
    return CGRectMake(x, y, w, _yLabelHeight);
}

- (CGRect)frameForXLabelAtIndex:(NSInteger)index {
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    _xLabelWidth = [self getMaxXLabelWidth];
    CGFloat h = _chartMarginBottom;
    CGFloat x = 0;
    CGFloat y = yAxisMax;
    if (_xLabelAlignmentStyle == GBXLabelAlignmentStyleFullXAxis) {
        x = _chartMarginLeft + index * _xStep - _xStep/2;
    } else{
        x = _chartMarginLeft + index * _xStep;
    }
    return CGRectMake(x, y, _xLabelWidth, h);
}

- (CGFloat)getMaxXLabelWidth {
    
    CGFloat width = _chartCavanWidth/_xLabelTitles.count;
    for (NSString *text in _xLabelTitles) {
        CGFloat tempW = [text sizeWithAttributes:@{NSFontAttributeName : _xLabelFont}].width;
        width = MAX(width, tempW);
    }
    return ceil(width);
}

- (void)getLinePathx1:(CGFloat)x1 andy1:(CGFloat)y1
                 path:(UIBezierPath*)path {
    
    [path addLineToPoint:CGPointMake(x1, y1)];
    
}

- (void)getControlPointx0:(CGFloat)x0 andy0:(CGFloat)y0
                       x1:(CGFloat)x1 andy1:(CGFloat)y1
                       x2:(CGFloat)x2 andy2:(CGFloat)y2
                       x3:(CGFloat)x3 andy3:(CGFloat)y3
                     path:(UIBezierPath*)path{
    CGFloat smooth_value = 0.6;
    CGFloat ctrl1_x;
    CGFloat ctrl1_y;
    CGFloat ctrl2_x;
    CGFloat ctrl2_y;
    CGFloat xc1 = (x0 + x1) / 2.0;
    CGFloat yc1 = (y0 + y1) / 2.0;
    CGFloat xc2 = (x1 + x2) / 2.0;
    CGFloat yc2 = (y1 + y2) / 2.0;
    CGFloat xc3 = (x2 + x3) / 2.0;
    CGFloat yc3 = (y2 + y3) / 2.0;
    CGFloat len1 = sqrt(pow((x1-x0), 2) + pow(y1-y0, 2));
    CGFloat len2 = sqrt(pow((x2-x1), 2) + pow(y2-y1, 2));
    CGFloat len3 = sqrt(pow((x3-x2), 2) + pow((y3-y2), 2));
    CGFloat k1 = len1 / (len1 + len2);
    CGFloat k2 = len2 / (len2 + len3);
    CGFloat xm1 = xc1 + (xc2 - xc1) * k1;
    CGFloat ym1 = yc1 + (yc2 - yc1) * k1;
    CGFloat xm2 = xc2 + (xc3 - xc2) * k2;
    CGFloat ym2 = yc2 + (yc3 - yc2) * k2;
    ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
    ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
    ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
    ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
    [path addCurveToPoint:CGPointMake(x2, y2) controlPoint1:CGPointMake(ctrl1_x, ctrl1_y) controlPoint2:CGPointMake(ctrl2_x, ctrl2_y)];
}
#pragma mark - 绘制
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat yAxisMax = _chartCavanHeight + _chartMarginTop;
    CGFloat xAxisMax = _chartCavanWidth + _chartMarginLeft;
    
    if (_showCoordinateAxis) {
        
        //画坐标轴
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, _coordinateAxisLineWidth);
        
        CGContextSetStrokeColorWithColor(ctx, _yAxisColor.CGColor);
        //画y轴三角形
        CGContextMoveToPoint(ctx, _chartMarginLeft, _chartMarginTop);
        CGContextAddLineToPoint(ctx, _chartMarginLeft-3, _chartMarginTop+5);
        CGContextMoveToPoint(ctx, _chartMarginLeft, _chartMarginTop);
        CGContextAddLineToPoint(ctx, _chartMarginLeft+3, _chartMarginTop+5);

        //画y轴线
        CGContextMoveToPoint(ctx, _chartMarginLeft, _chartMarginTop);
        CGContextAddLineToPoint(ctx, _chartMarginLeft, yAxisMax);
        
        //绘制y轴分割点
        for (int i = 0; i < _yLabelNum; i++) {
            
            CGFloat y = _chartMarginTop + _yStep * i + _yStep;
            CGContextMoveToPoint(ctx, _chartMarginLeft+3, y);
            CGContextAddLineToPoint(ctx, _chartMarginLeft-2, y);
        }
        
        CGContextStrokePath(ctx);

        CGContextSetStrokeColorWithColor(ctx, _xAxisColor.CGColor);
        //画x轴三角形
        CGContextMoveToPoint(ctx, _chartMarginLeft, yAxisMax);
        CGContextAddLineToPoint(ctx, xAxisMax, yAxisMax);
        CGContextAddLineToPoint(ctx, xAxisMax-5, yAxisMax-3);
        //画x轴线
        CGContextMoveToPoint(ctx, xAxisMax, yAxisMax);
        CGContextAddLineToPoint(ctx, xAxisMax-5, yAxisMax+3);
        
        //绘制x轴分割点
        CGFloat y = _chartCavanHeight + _chartMarginTop;
        for (NSInteger i = 0; i < _xLabelTitles.count; i++) {
            CGFloat x = _chartMarginLeft + (_xLabelAlignmentStyle == GBXLabelAlignmentStyleFullXAxis ? 0 : _xStep/2) + i * _xStep;
            CGContextMoveToPoint(ctx, x, y-3);
            CGContextAddLineToPoint(ctx, x, y);
        }
        CGContextStrokePath(ctx);
    }
    
    if (_showYGridsLine) {
        //绘制横线
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(ctx, _yGridsLineColor.CGColor);
        CGContextSetLineWidth(ctx, _yGridsLineWidth);
        if (_showYGridsLineDash) {
            CGFloat dash[] = {3,3};
            
            CGContextSetLineDash(ctx, 0.0, dash, 2  );
        }
    
        NSInteger index= 0;
        if (_showCoordinateAxis) {
            index = 1;
        }
        for (NSInteger i = index; i < _yLabelNum; i++) {
            
            CGContextMoveToPoint(ctx, _chartMarginLeft, yAxisMax - _yStep * i);
            CGContextAddLineToPoint(ctx, xAxisMax, yAxisMax - _yStep * i);
            CGContextStrokePath(ctx);
        }
    }
}
@end
