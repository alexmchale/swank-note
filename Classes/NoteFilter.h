#import <Foundation/Foundation.h>
#import "Note.h"

@interface NoteFilter : NSObject
{
}

- (Note *)findBySwankId:(NSNumber *)swankId;

- (NSInteger)count;
- (NSArray *)fetchDirtyNotes:(bool)dirty;
- (Note *)atIndex:(NSInteger)index;
- (NSInteger)indexOf:(Note *)note;

@end
