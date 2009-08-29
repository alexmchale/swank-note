#import "NoteSync.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "SwankNoteAppDelegate.h"
#import "SwankRootViewController.h"
#import "NoteFilter.h"
#import "WPProgressHUD.h"

@implementation NoteSync
@synthesize delegate;

- (void)updateNotes
{
  [NSThread detachNewThreadSelector:@selector(syncNotes) toTarget:self withObject:nil];
}

- (void)getNotes
{
  // Get the notes that are currently on SwankDB.
  
  NSString *url = @"http://swankdb.com:3000/entries/download?frob=91eb85ae181114313fdf441d3a02d7a4a02a0e13&mode=json";
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
  NSURLResponse *response;
  NSData *noteData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
  NSArray *notes = [[CJSONDeserializer deserializer] deserialize:noteData error:nil];
  
  // Prepare to scan the current database for what we've downloaded.
  
  NoteFilter *noteFilter = [[NoteFilter alloc] init];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  
  // Add notes in SwankDB to the local database.
  
  for (NSDictionary *noteDict in notes)
  {
    NSNumber *swankId = [noteDict valueForKey:@"id"];        
    Note *note = [noteFilter findBySwankId:swankId];
    
    if (note == nil)
      note = [Note new];
    
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
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
      
      [note save:NO updateTimestamp:NO];
      
      [self.delegate noteUpdated:note];
    }
  }
}

- (void)postDirtyNotes
{
  NoteFilter *noteFilter = [[NoteFilter alloc] init];
  NSArray *notes = [noteFilter fetchDirtyNotes:YES];
  NSMutableArray *noteList = [[NSMutableArray alloc] init];
  
  // Build the list of dictionaries to post to SwankDB.
  
  for (Note *note in notes)
  {
    NSMutableDictionary *noteDict = [[NSMutableDictionary alloc] init];
    
    [noteDict setValue:[note.swankId stringValue] forKey:@"id"];
    [noteDict setValue:note.text forKey:@"content"];
    [noteDict setValue:note.tags forKey:@"tags"];
    [noteDict setValue:@"unused-field" forKey:@"created_at"];
    [noteDict setValue:@"unused-field" forKey:@"updated_at"];
    
    [noteList addObject:noteDict];
    [noteDict release];
  }
  
  // Generate the data to send to SwankDB.
  
  NSString *postString = [[CJSONSerializer serializer] serializeArray:noteList];    
  NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
  NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

  // Build the request to post.
  
  NSURL *url = [NSURL URLWithString:@"http://swankdb.com:3000/entries/batch?frob=91eb85ae181114313fdf441d3a02d7a4a02a0e13&json"];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
  [req setHTTPMethod:@"POST"];
  [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [req setHTTPBody:postData];
  
  // Post to SwankDB.
  
  NSURLResponse *response;
  NSData *swankData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
  
  // Read the list of IDs sent back from SwankDB, and note them in our database.
    
  NSArray *swankIds = [[CJSONDeserializer deserializer] deserialize:swankData error:nil];
  
  for (int i = 0; i < [swankIds count] && i < [notes count]; ++i)
  {
    Note *note = [notes objectAtIndex:i];
    NSNumber *swankId = [swankIds objectAtIndex:i];
    
    note.swankId = swankId;
    note.dirty = NO;
    
    [note save:NO];
  }
  
  [noteList release];
  [noteFilter release];
}

- (void)syncNotes
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
	SwankNoteAppDelegate *app = [[UIApplication sharedApplication] delegate];
  self.delegate = [[app swankRootViewController] indexViewController];

  [self getNotes];
  [self postDirtyNotes];
  
  [pool release];
}

- (void)dealloc
{
  [super dealloc];
}

@end
