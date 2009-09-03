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
@synthesize delegate, running;

- (void)updateNotes
{
  if (!self.running)
    [NSThread detachNewThreadSelector:@selector(syncNotes) toTarget:self withObject:nil];
}

- (void)getNotes
{
  NoteFilter *noteFilter = [[NoteFilter alloc] initWithContext];  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  
  // Get the notes that are currently on SwankDB.
  
  NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
  [paramDict setValue:kFrob forKey:@"frob"];
  [paramDict setValue:@"json" forKey:@"mode"];
  [paramDict setValue:[dateFormatter stringFromDate:[noteFilter swankSyncTime]] forKey:@"starting_at"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  [paramDict release];
  
  NSString *urlString = [NSString stringWithFormat:@"http://%@/entries/download?%@", kSwankHost, paramString];
  NSURL *url = [NSURL URLWithString:urlString];
  
  NSURLRequest *req = [NSURLRequest requestWithURL:url];
  NSURLResponse *response;
  NSData *noteData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
  NSArray *notes = [[CJSONDeserializer deserializer] deserialize:noteData error:nil];
  
  // Add notes in SwankDB to the local database.
  
  for (NSDictionary *noteDict in notes)
  {
    NSNumber *swankId = [noteDict valueForKey:@"id"];        
    Note *note = [noteFilter findBySwankId:swankId];
    
    if (note == nil)
      note = [noteFilter newNote];
    
    NSDate *oldSwankTime = note.swankTime;
    NSDate *newSwankTime = [dateFormatter dateFromString:[noteDict valueForKey:@"updated_at"]];
    
    if (note.updatedAt == nil || oldSwankTime == nil || [oldSwankTime compare:newSwankTime] == NSOrderedAscending)
    {
      note.swankId = swankId;
      
      id newContent = [noteDict valueForKey:@"content"];
      if ([newContent isKindOfClass:[NSString class]])
        note.text = [noteDict valueForKey:@"content"];
      else
        note.text = @"";
      
      id newTags = [noteDict valueForKey:@"tags"];
      if ([newTags isKindOfClass:[NSString class]])
        note.tags = [noteDict valueForKey:@"tags"];
      else
        note.tags = @"";
      
      note.createdAt = [dateFormatter dateFromString:[noteDict valueForKey:@"created_at"]];
      note.updatedAt = newSwankTime;
      note.swankTime = newSwankTime;
      
      note.dirty = [NSNumber numberWithBool:NO];
      
      [note save:NO updateTimestamp:NO];
    }
  }
}

- (void)postDirtyNotes
{
  NoteFilter *noteFilter = [[NoteFilter alloc] initWithContext];
  NSArray *notes = [noteFilter fetchDirtyNotes:YES];
  
  // Upload all dirty notes to SwankDB.
  
  for (Note *note in notes)
  {
    // Generate data to send to SwankDB.
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setValue:kFrob forKey:@"frob"];
    [paramDict setValue:note.text forKey:@"entry_content"];
    [paramDict setValue:note.tags forKey:@"entry_tags"];
    [paramDict setValue:@"true" forKey:@"json"];
    NSString *paramString = [paramDict convertDictionaryToURIParameterString];
    [paramDict release];
    
    // Build the URL to post to.
    
    NSString *notePath = [note swankDbPostPath];
    NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", kSwankHost, notePath, paramString];    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Build the post request.
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    if (note.swankId == nil || [note.swankId intValue] == 0)
      [req setHTTPMethod:@"POST"];
    else
      [req setHTTPMethod:@"PUT"];
    
    // Post to SwankDB.
    
    NSURLResponse *response;
    NSData *swankData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
    
    // Flag the note with the new swank id if we just got one.
        
    id swankEntry = [[CJSONDeserializer deserializer] deserialize:swankData error:nil];
    id swankId = [swankEntry valueForKey:@"id"];
    
    if ([swankId isKindOfClass:[NSNumber class]])
    {
      note.swankId = swankId;
       
      [note save:NO updateTimestamp:NO];
    }
  }
    
  [noteFilter release];
}

- (void)syncNotes
{
  self.running = YES;
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  [self getNotes];
  [self postDirtyNotes];
  
  [self.delegate notesWereUpdated];
  
  [pool release];
  
  self.running = NO;
}

- (void)dealloc
{
  [super dealloc];
}

@end
