#import <Foundation/Foundation.h>
#import "Note.h"

@protocol NoteSyncDelegate

- (void)notesWereUpdated;

@end


@interface NoteSync : NSObject
{
  id<NoteSyncDelegate> delegate;
}

@property (nonatomic, retain) id<NoteSyncDelegate> delegate;

- (void)updateNotes;
- (void)syncNotes;

@end
