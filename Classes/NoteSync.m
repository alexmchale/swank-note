#import "NoteSync.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "SwankNoteAppDelegate.h"
#import "SwankRootViewController.h"
#import "NoteFilter.h"
#import "NSDictionaryUtilities.h"

#define kFrob @"91eb85ae181114313fdf441d3a02d7a4a02a0e13"

@implementation NoteSync
@synthesize delegate;

- (void)updateNotes
{
  [NSThread detachNewThreadSelector:@selector(syncNotes) toTarget:self withObject:nil];
}

- (void)getNotes
{
  NoteFilter *noteFilter = [[NoteFilter alloc] initWithContext];  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  
  // Get the notes that are currently on SwankDB.

  NSString *swankHost = @"swankdb.com:3000";
  
  NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
  [paramDict setValue:kFrob forKey:@"frob"];
  [paramDict setValue:@"json" forKey:@"mode"];
  [paramDict setValue:[dateFormatter stringFromDate:[noteFilter swankSyncTime]] forKey:@"starting_at"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  [paramDict release];
  
  NSString *urlString = [NSString stringWithFormat:@"http://%@/entries/download?%@", swankHost, paramString];
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
    
    NSDate *newSwankTime = [dateFormatter dateFromString:[noteDict valueForKey:@"updated_at"]];
    
    if (note.updatedAt == nil || [note.swankTime compare:newSwankTime] == NSOrderedAscending)
    {
      note.swankId = swankId;
      
      id newContent = [noteDict valueForKey:@"content"];
      if (newContent != [NSNull null])
        note.text = [noteDict valueForKey:@"content"];
      else
        note.text = @"";
      
      id newTags = [noteDict valueForKey:@"tags"];
      if (newTags != [NSNull null])
        note.tags = [noteDict valueForKey:@"tags"];
      else
        note.tags = @"";
      
      note.createdAt = [dateFormatter dateFromString:[noteDict valueForKey:@"created_at"]];
      note.updatedAt = newSwankTime;
      note.swankTime = newSwankTime;
      
      note.dirty = [NSNumber numberWithBool:NO];
      
      [noteFilter save:note isDirty:NO updateTimestamp:NO];
      
      [self.delegate noteUpdated:note];
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
    NSMutableDictionary *noteDict = [[NSMutableDictionary alloc] init];
    
    // Generate data to send to SwankDB.
    
    [noteDict setValue:note.text forKey:@"entry_content"];
    [noteDict setValue:note.tags forKey:@"entry_tags"];
    
    NSString *postString = [noteDict convertDictionaryToURIParameterString];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    // Build the URL to post to.
    
    NSString *swankHost = @"swankdb.com:3000";
    NSString *notePath = [note swankDbPostPath];
    NSString *params = @"frob=91eb85ae181114313fdf441d3a02d7a4a02a0e13&json";
    NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", swankHost, notePath, params];    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Build the post request.
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:postData];
    
    // Post to SwankDB.
    
    NSURLResponse *response;
    NSData *swankData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
    
    // Flag the note with the new swank id if we just got one.
        
    id swankEntry = [[CJSONDeserializer deserializer] deserialize:swankData error:nil];
    id swankId = [swankEntry valueForKey:@"id"];
    
    if ([swankId isKindOfClass:[NSNumber class]])
    {
      note.swankId = swankId;
       
      [noteFilter save:note isDirty:NO updateTimestamp:NO];
    }
    
    [noteDict release];
  }
    
  [noteFilter release];
}

- (void)syncNotes
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  [self getNotes];
  [self postDirtyNotes];
  
	SwankNoteAppDelegate *app = [[UIApplication sharedApplication] delegate];
  [[[app swankRootViewController] indexViewController] reload];
  
  [pool release];
}

- (void)dealloc
{
  [super dealloc];
}

@end
