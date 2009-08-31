#import <Foundation/Foundation.h>
#import "Note.h"

@interface NoteFilter : NSObject
{
  NSManagedObjectContext *context;
}

@property (nonatomic, retain) NSManagedObjectContext *context;

- (NoteFilter *)initWithContext;

- (Note *)findBySwankId:(NSNumber *)swankId;

- (Note *)newNote;
- (void)save:(Note *)note isDirty:(bool)dirty updateTimestamp:(bool)updateTimestamp;
- (void)destroy:(Note *)note;

- (void)resetContext;
- (NSDate *)swankSyncTime;
- (NSInteger)count;
- (NSArray *)fetchDirtyNotes:(bool)dirty;
- (NSArray *)fetchAll;
- (Note *)atIndex:(NSInteger)index;
- (NSInteger)indexOf:(Note *)note;

@end
