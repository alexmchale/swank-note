#import <Foundation/Foundation.h>
#import "Note.h"

@protocol NoteSyncDelegate

- (void)noteUpdated:(Note *)note;

@end


@interface NoteSync : NSObject
{
  id<NoteSyncDelegate> delegate;
}

@property (nonatomic, retain) id<NoteSyncDelegate> delegate;

- (void)updateNotes;
- (void)syncNotes;

@end
