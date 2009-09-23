#import <Foundation/Foundation.h>

@interface AccountImageView : UIView
{
  UIColor *color;
}

@property (nonatomic, retain) UIColor *color;

+ (id) forIndex:(NSUInteger)index;

- (id) initWithColor:(UIColor *)color;

@end
