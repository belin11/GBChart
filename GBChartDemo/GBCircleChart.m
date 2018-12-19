//
//  GBCircleChart.m
//  GBChartDemo
//
//  Created by midas on 2018/12/18.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBCircleChart.h"

@interface GBCircleChart ()

@property (nonatomic) CAShapeLayer *circle;
@property (nonatomic) CAShapeLayer *gradientMask;
@property (nonatomic) CAShapeLayer *circleBackground;

@end

@implementation GBCircleChart

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise {

    return [self initWithFrame:frame total:total current:current clockwise:clockwise shadow:NO shadowColor:[UIColor clearColor]];
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor {
    
    return [self initWithFrame:frame total:total current:current clockwise:clockwise shadow:hasBackgroundShadow shadowColor:backgroundShadowColor displayCountingLabel:YES];
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor displayCountingLabel:(BOOL)displayCountingLabel {
    
    return [self initWithFrame:frame total:total current:current clockwise:clockwise shadow:hasBackgroundShadow shadowColor:backgroundShadowColor displayCountingLabel:displayCountingLabel overrideLineWidth:@8];
}

- (id)initWithFrame:(CGRect)frame total:(NSNumber *)total current:(NSNumber *)current clockwise:(BOOL)clockwise shadow:(BOOL)hasBackgroundShadow shadowColor:(UIColor *)backgroundShadowColor displayCountingLabel:(BOOL)displayCountingLabel overrideLineWidth:(NSNumber *)overrideLineWidth {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        _total = total;
        _current = current;
        _strokeColor = [UIColor blueColor];
        _lineWidth = overrideLineWidth;
        _duration = 1.0;
        _displayAnimated = YES;
        _displayCountingLabel = displayCountingLabel;
        
        CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
        CGFloat r = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))/2 - _lineWidth.floatValue/2;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:r startAngle:-M_PI_2 endAngle:-M_PI_2+2*M_PI clockwise:clockwise];
        
        _circle = [CAShapeLayer layer];
        _circle.lineWidth = _lineWidth.floatValue;
        _circle.lineCap = kCALineCapRound;
        _circle.strokeColor = _strokeColor.CGColor;
        _circle.fillColor = [UIColor clearColor].CGColor;
        _circle.path = path.CGPath;
        [self.layer addSublayer:_circle];
        
        if (hasBackgroundShadow) {
            _circleBackground = [CAShapeLayer layer];
            _circleBackground.lineWidth = _lineWidth.floatValue;
            _circleBackground.lineCap = kCALineCapRound;
            _circleBackground.strokeColor = backgroundShadowColor.CGColor;
            _circleBackground.fillColor = [UIColor clearColor].CGColor;
            _circleBackground.path = path.CGPath;
            [self.layer addSublayer:_circleBackground];
        }
        
        if (_displayCountingLabel) {
            _countingLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(0, 0, 2*(r - 20), 2*(r - 20))];
            _countingLabel.center = center;
            _countingLabel.textColor = [UIColor darkTextColor];
            _countingLabel.font = [UIFont systemFontOfSize:16];
            _countingLabel.textAlignment = NSTextAlignmentCenter;
            _countingLabel.numberOfLines = 0;
//            _countingLabel.backgroundColor = [UIColor lightGrayColor];
            _countingLabel.method = UILabelCountingMethodEaseInOut;
            _countingLabel.format = @"%.1f%%";
            [self addSubview:_countingLabel];
        }
        
    }
    return self;
}

- (void)strokeChart {
    
    if (_shadowColor) {
        _circle.shadowColor = _shadowColor.CGColor;
        _circle.shadowRadius = 3;
        _circle.shadowOpacity = 0.5;
        _circle.shadowOffset = CGSizeMake(0, 0);
    }
    _circle.strokeColor = _strokeColor.CGColor;

    _circle.strokeEnd = _current.floatValue/_total.floatValue;
    if (_displayCountingLabel) {
        CGFloat totalPercentageValue = [_current floatValue]/([_total floatValue]/100.0);
        [_countingLabel countFromZeroTo:totalPercentageValue withDuration:_duration];
    }
    if (_strokeColorGradientStart) {

        self.gradientMask = [CAShapeLayer layer];
        self.gradientMask.fillColor = [[UIColor clearColor] CGColor];
        self.gradientMask.strokeColor = [[UIColor blackColor] CGColor];
        self.gradientMask.lineWidth = _circle.lineWidth;
        self.gradientMask.lineCap = kCALineCapRound;
        CGRect gradientFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.gradientMask.frame = gradientFrame;
        self.gradientMask.path = _circle.path;

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        gradientLayer.colors = @[(id)_strokeColorGradientStart.CGColor, (id)_strokeColor.CGColor];
        gradientLayer.frame = gradientFrame;
        gradientLayer.mask = _gradientMask;

        [_circle addSublayer:gradientLayer];

        _gradientMask.strokeEnd = _current.floatValue/_total.floatValue;
    }
    if (_displayAnimated) {
        [self addAnimationIfNeededWithFromValue:@0 toValue:@(_current.floatValue/_total.floatValue)];
    }
}

- (void)updateChartByCurrent:(NSNumber *)current {
    
    [self updateChartByCurrent:current byTotal:_total];
}

- (void)updateChartByCurrent:(NSNumber *)current byTotal:(NSNumber *)total {
    
    _circle.strokeEnd = current.floatValue/total.floatValue;
    
    if (_strokeColorGradientStart && _gradientMask) {
        _gradientMask.strokeEnd = _circle.strokeEnd;
    }
    
    if (_displayCountingLabel) {
        CGFloat totalPercentageValue = [current floatValue]/([total floatValue]/100.0);
        [_countingLabel countFrom:_current.floatValue to:totalPercentageValue withDuration:_duration];
    }
    [self addAnimationIfNeededWithFromValue:@(_current.floatValue/_total.floatValue) toValue:@(current.floatValue/total.floatValue)];

    _current = current;
    _total = total;
}

- (void)growChartByAmount:(NSNumber *)growAmount {
    
    NSNumber *currrentNumber = @(_current.floatValue + growAmount.floatValue);
    [self updateChartByCurrent:currrentNumber byTotal:_total];
}

- (void)addAnimationIfNeededWithFromValue:(NSNumber *)fromValue toValue:(NSNumber *)toValue{
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    ani.fromValue = fromValue;
    ani.toValue = toValue;
    ani.duration = _duration;
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_circle addAnimation:ani forKey:nil];
    if (_gradientMask && _strokeColorGradientStart) {
        [_gradientMask addAnimation:ani forKey:nil];
    }
}

@end
