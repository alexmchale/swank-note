#import "NSArrayUtilities.h"

@implementation NSArray (NSArrayUtilities)

- (id)objectOfClass:(Class)class
{
  for (id obj in self)
  {
    if ([obj isKindOfClass:class])
      return obj;
  }
  
  return nil;
}

@end
