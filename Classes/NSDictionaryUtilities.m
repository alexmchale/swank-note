#import "NSDictionaryUtilities.h"
#import "NSStringUtilities.h"

@implementation NSDictionary (NSDictionaryUtilities)

- (NSString *) convertDictionaryToURIParameterString
{
  NSMutableArray *elements = [NSMutableArray array];
  for (NSString *k in [self keyEnumerator]) {
    NSString *escapedK = [k stringByAddingPercentEscapesForURI];
    if (![k isEqualToString: @""]) {
      NSString *escapedV = [[self objectForKey: k] stringByAddingPercentEscapesForURI];
      [elements addObject: [NSString stringWithFormat: @"%@=%@", escapedK, escapedV]];
    }
  }
  return [elements componentsJoinedByString:@"&"];
}

@end
