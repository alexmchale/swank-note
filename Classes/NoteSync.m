#import "NoteSync.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "SwankNoteAppDelegate.h"
#import "NoteFilter.h"
#import "NSDictionaryUtilities.h"

@implementation NoteSync
@synthesize downloader, uploader;

- (id) init
{
  if (self = [super init])
  {
    NoteDownloader *newDownloader = [[NoteDownloader alloc] init];
    self.downloader = newDownloader;
    [newDownloader release];
    
    NoteUploader *newUploader = [[NoteUploader alloc] init];
    self.uploader = newUploader;
    [newUploader release];
  }
  
  return self;
}

- (void) updateNotes
{
  if ([AppSettings sync])
  {
    [self.downloader startRequest];
    [self.uploader startRequest];
  }
}

- (void) dealloc
{
  [downloader release];
  [super dealloc];
}

@end
