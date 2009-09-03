#import <Foundation/Foundation.h>
#import "Note.h"

@protocol NoteSyncDelegate

- (void)notesWereUpdated;

@end


@interface NoteSync : NSObject
{
  id<NoteSyncDelegate> delegate;
  bool running;
}

@property (nonatomic, retain) id<NoteSyncDelegate> delegate;
@property bool running;

- (void)updateNotes;
- (void)syncNotes;

@end
