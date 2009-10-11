#import <Foundation/Foundation.h>

@interface AppSettings : NSManagedObject
{
}

+ (bool) sync;
+ (void) setSync:(bool)sync;

+ (NSInteger) defaultAccountSwankId;
+ (void) setDefaultAccountSwankId:(NSInteger)swankId;

+ (NSArray *) allTags;
+ (void) resetAllTags;

+ (bool) noteInProgress:(Note **)note withText:(NSString **)text withTags:(NSString **)tags;
+ (void) clearNoteInProgress;
+ (void) setNoteInProgress:(Note *)note withText:(NSString *)text withTags:(NSString *)tags;

@end
