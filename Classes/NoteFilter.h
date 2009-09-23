#import <Foundation/Foundation.h>
#import "Note.h"

@interface NoteFilter : NSObject
{
}

+ (Note *) newNote;

+ (NSDate *) swankSyncTime:(Account *)account;
+ (NSInteger) count;

+ (NSArray *) fetchRecentNotes:(NSInteger)count;
+ (Note *) fetchFirstDirtyNote;
+ (NSArray *) fetchDirtyNotes:(bool)dirty;
+ (NSArray *) fetchAll;
+ (NSArray *) fetchAllWithTag:(NSString *)tag;
+ (NSArray *) fetchAllTags;
+ (NSArray *) fetchWithPhrase:(NSString *)phrase withTag:(NSString *)tag;
+ (Note *) fetchBySwankId:(NSNumber *)swankId;

+ (Note *) atIndex:(NSInteger)index;
+ (NSInteger) indexOf:(Note *)note;

@end
