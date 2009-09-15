#import "NoteDownloader.h"
#import "NoteFilter.h"
#import "NSDictionaryUtilities.h"
#import "CJSONDeserializer.h"
#import "TopLevelViewController.h"

@implementation NoteDownloader
@synthesize dataCache, connection, account;

- (void) startRequest
{
  // Do not start a new request if one is already in progress.
  
  if (connection != nil)
    return;
  
  // Determine what account to request.
  
  self.account = [Account next:account];
  
  if (account == nil || account.frob == nil)
    return;

  // Allocate the buffer for incoming data.
  
  self.dataCache = [[[NSMutableData alloc] init] autorelease];
  
  // Get the date formatter to use in creating our request.
  
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  
  // Build the URL parameters for the query to SwankDB.
  
  NSMutableDictionary *paramDict = [[[NSMutableDictionary alloc] init] autorelease];
  [paramDict setValue:account.frob forKey:@"frob"];
  [paramDict setValue:@"json" forKey:@"mode"];
  [paramDict setValue:[dateFormatter stringFromDate:[NoteFilter swankSyncTime:account]] forKey:@"starting_at"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  
  // Build the URL to request from SwankDB.
  
  NSString *urlString = [NSString stringWithFormat:@"http://%@/entries/download?%@", kSwankHost, paramString];
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Start the connection.

  NSURLRequest *req = [[[NSURLRequest alloc] initWithURL:url] autorelease];
  self.connection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}

- (void) importNotes
{
  // Get the date formatter to use in creating our request.
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];  
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
  
  // Parse the JSON in the response.
  
  NSArray *notes = [[CJSONDeserializer deserializer] deserialize:dataCache error:nil];
  
  // Add notes in SwankDB to the local database.
  
  for (NSDictionary *noteDict in notes)
  {
    NSNumber *swankId = [noteDict valueForKey:@"id"];        
    Note *note = [NoteFilter fetchBySwankId:swankId];
    
    if (note == nil)
      note = [NoteFilter newNote];
    
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
      note.account = account;
      
      note.dirty = [NSNumber numberWithBool:NO];
      
      [note save:NO];
    }
  }  
  
  // Update the root view so that new notes will show in Recent Notes.
  
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  id top = [appDelegate.navController topViewController];
  
  if ([top isKindOfClass:[TopLevelViewController class]])
    [top refreshRecentNotes];
}

#pragma mark NSURLConnection Delegate Methods
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.dataCache appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  self.dataCache = nil;
  self.connection = nil;
  [self startRequest];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
  [self importNotes];
  self.dataCache = nil;
  self.connection = nil;
  [self startRequest];
}

#pragma mark Memory Management
- (void) dealloc
{
  [account release];
  [dataCache release];
  [connection release];
  [super dealloc];
}

@end
