#import "NoteSync.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "SwankNoteAppDelegate.h"
#import "SwankRootViewController.h"
#import "NoteFilter.h"
#import "NSDictionaryUtilities.h"

#define kSwankHost @"swankdb.com:3000"
#define kFrob @"91eb85ae181114313fdf441d3a02d7a4a02a0e13"

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
  [self.downloader startRequest];
  [self.uploader startRequest];
}

- (void) dealloc
{
  [downloader release];
  [super dealloc];
}

@end
