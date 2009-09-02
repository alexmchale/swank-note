#import <Foundation/Foundation.h>
#import "Note.h"

@interface NoteFilter : NSObject
{
  NSManagedObjectContext *context;
  NSString *searchTerm;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSString *searchTerm;

- (NoteFilter *)initWithContext;

- (Note *)findBySwankId:(NSNumber *)swankId;

- (Note *)newNote;

- (void)searchText:(NSString *)searchTerm;
- (void)resetContext;
- (NSDate *)swankSyncTime;
- (NSInteger)count;
- (NSArray *)fetchDirtyNotes:(bool)dirty;
- (NSArray *)fetchAll;
- (Note *)atIndex:(NSInteger)index;
- (NSInteger)indexOf:(Note *)note;

@end
