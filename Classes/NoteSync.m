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
    self.downloader = [[[NoteDownloader alloc] init] autorelease];    
    self.uploader = [[[NoteUploader alloc] init] autorelease];
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
  [uploader release];
  [super dealloc];
}

@end
