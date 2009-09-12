#import <Foundation/Foundation.h>

@interface NSString (NSStringUtilities)

- (void)alertWithTitle:(NSString *)title;
- (NSString *)stringByAddingPercentEscapesForURI;
- (NSArray *)splitForTags;

@end
