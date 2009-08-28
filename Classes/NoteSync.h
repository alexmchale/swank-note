#import <Foundation/Foundation.h>
#import "Note.h"

@protocol NoteSyncDelegate

- (void)noteUpdated:(Note *)note;

@end


@interface NoteSync : NSObject
{
  NSMutableData *data;
  id<NoteSyncDelegate> delegate;
  NSURLConnection *uploadConnection;
}

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) id<NoteSyncDelegate> delegate;
@property (retain) NSURLConnection *uploadConnection;

- (void)updateNotes;
- (void)syncNotes:(NSArray *)notes;

@end
