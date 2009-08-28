#import "NoteSync.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NoteFilter.h"

@implementation NoteSync
@synthesize data, delegate, uploadConnection;

- (void)updateNotes
{
  NSString *url = @"http://swankdb.com:3000/entries/download?frob=91eb85ae181114313fdf441d3a02d7a4a02a0e13&mode=json";
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
  [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)postNotes:(NSArray *)notes
{
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
  
  NSURL *url = [NSURL URLWithString:@"http://swankdb.com:3000/entries/batch?frob=91eb85ae181114313fdf441d3a02d7a4a02a0e13"];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
  [req setHTTPMethod:@"POST"];
  [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [req setHTTPBody:postData];
  
  // Post to SwankDB.
  
  NSURLResponse *response;
  [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
  
  [noteList release];
}

- (void)syncNotes:(NSArray *)notes
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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

  // Scan the notes in the local database for ones that are still dirty.
  NSArray *notesToPost = [noteFilter fetchDirtyNotes:YES];
      
  NSString *msg = [[NSString alloc] initWithFormat:@"Found %d notes to post.", [notesToPost count]];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Complete"
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"Okay"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
  [msg release];

  [self postNotes:notesToPost];

  [dateFormatter release];
  [noteFilter release];
  [pool release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  self.data = nil;
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Connection Failed"
                                                  message:nil 
                                                 delegate:nil
                                        cancelButtonTitle:@"Okay"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData
{
  [self.data appendData:newData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSArray *notes = [[CJSONDeserializer deserializer] deserialize:self.data error:nil];
  
  NSString *msg = [[NSString alloc] initWithFormat:@"Received %d notes.", [notes count]];

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Complete"
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"Okay"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
  [msg release];
  
  //[self syncNotes:notes];
  [NSThread detachNewThreadSelector:@selector(syncNotes:) toTarget:self withObject:notes];
  self.data = nil;  
}

- (void)dealloc
{
  [data release];
  [super dealloc];
}

@end
