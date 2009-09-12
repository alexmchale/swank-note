#import <Foundation/Foundation.h>

@interface AppSettings : NSManagedObject
{
}

+ (bool) sync;
+ (void) setSync:(bool)sync;

+ (NSInteger) defaultAccountSwankId;
+ (void) setDefaultAccountSwankId:(NSInteger)swankId;

@end
