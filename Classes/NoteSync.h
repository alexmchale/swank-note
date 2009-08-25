#import <Foundation/Foundation.h>
#import "Note.h"

@protocol NoteSyncDelegate

- (void)noteUpdated:(Note *)note;

@end


@interface NoteSync : NSObject
{
  NSMutableData *data;
  id<NoteSyncDelegate> delegate;
}

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) id<NoteSyncDelegate> delegate;

- (void)updateNotes;

@end
