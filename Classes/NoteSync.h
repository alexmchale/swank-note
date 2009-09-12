#import <Foundation/Foundation.h>
#import "Note.h"
#import "NoteDownloader.h"
#import "NoteUploader.h"

@protocol NoteSyncDelegate

- (void)notesWereUpdated;

@end


@interface NoteSync : NSObject
{
  NoteDownloader *downloader;
  NoteUploader *uploader;
}

@property (nonatomic, retain) NoteDownloader *downloader;
@property (nonatomic, retain) NoteUploader *uploader;

- (void)updateNotes;

@end
