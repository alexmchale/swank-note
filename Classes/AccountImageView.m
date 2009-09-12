#import "AccountImageView.h"

#define kCircleSize 10.0

@implementation AccountImageView
@synthesize color;

- (id) initWithColor:(UIColor *)circleColor
{
  [super init];
  
  self.color = circleColor;
  
  CGRect bounds = self.bounds;
  
  bounds.size.width = 25;
  bounds.size.height = 25;
  
  self.bounds = bounds;
  self.backgroundColor = [UIColor clearColor];
  
  return self;
}

- (void) dealloc
{
  [color release];
  [super dealloc];
}

- (void) drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  float offset = (self.bounds.size.width - kCircleSize) / 2.0;
  CGRect circleRect = CGRectMake(offset, offset, kCircleSize, kCircleSize);
  
  CGContextSetLineWidth(context, 0.0);
  CGContextSetStrokeColorWithColor(context, [color CGColor]);
  CGContextSetFillColorWithColor(context, [color CGColor]);
  
  CGContextAddEllipseInRect(context, circleRect);
  CGContextDrawPath(context, kCGPathFill);
}

@end
