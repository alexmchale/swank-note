#import "AccountImageView.h"

#define kCircleSize 5.0

@implementation AccountImageView
@synthesize color;

static NSArray *colors = nil;

+ (id) forIndex:(NSUInteger)index
{
  if (colors == nil)
  {
    colors = 
      [[NSArray alloc] initWithObjects:
        [UIColor redColor], [UIColor blueColor], 
        [UIColor greenColor], [UIColor yellowColor],
        [UIColor purpleColor], [UIColor orangeColor], 
        nil];
  }
  
  UIColor *color = [colors objectAtIndex:(index % [colors count])];
  
  return [[[AccountImageView alloc] initWithColor:color] autorelease];
}

- (id) initWithColor:(UIColor *)circleColor
{
  if (self = [super init])
  {
    self.color = circleColor;
    
    CGRect bounds = self.bounds;
    
    bounds.size.width = 15;
    bounds.size.height = 15;
    
    self.bounds = bounds;
    self.backgroundColor = [UIColor clearColor];
  }
  
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
