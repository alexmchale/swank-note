#import "NoteUploader.h"
#import "NoteFilter.h"
#import "NSDictionaryUtilities.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@implementation NoteUploader
@synthesize connection, dataCache, note;

// TODO: This will currently retry until a failure occurrs or it's done.
// Weakness: if SwankDB breaks and sends incorrect results, it can loop forever.

- (void) getNextNote
{
  self.note = [NoteFilter fetchFirstDirtyNote];
  
  // Verify that this note has been associated with an account.
  
  if (note != nil && note.account == nil)
  {
    note.account = [Account fetchDefaultAccount];
    [[SwankNoteAppDelegate context] save:nil];
  }
}

- (void) startRequest
{
  if (connection != nil)
    return;

  [self getNextNote];
  
  if (note == nil || note.account == nil || note.account.frob == nil)
    return;

  // Allocate the buffer for incoming data.
  
  self.dataCache = [[[NSMutableData alloc] init] autorelease];
  
  // Generate data to send to SwankDB.
  
  NSMutableDictionary *paramDict = [[[NSMutableDictionary alloc] init] autorelease];
  [paramDict setValue:note.account.frob forKey:@"frob"];
  [paramDict setValue:note.text forKey:@"entry_content"];
  [paramDict setValue:note.tags forKey:@"entry_tags"];
  [paramDict setValue:@"true" forKey:@"json"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  
  // Build the URL to post to.
  
  NSString *notePath = [note swankDbPostPath];
  NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", kSwankHost, notePath, paramString];    
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Build the post request.
  
  NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  
  if (note.swankId == nil || [note.swankId intValue] == 0)
    [req setHTTPMethod:@"POST"];
  else
    [req setHTTPMethod:@"PUT"];
  
  // Post to SwankDB.
  
  self.connection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}

- (void) markNoteInResponse
{
  // This would be an error condition.
  
  if (note == nil)
    return;
  
  // Flag the note with the new swank id if we just got one.
  
  id swankEntry = [[CJSONDeserializer deserializer] deserialize:self.dataCache error:nil];
  id swankId = [swankEntry valueForKey:@"id"];
  
  if ([swankId isKindOfClass:[NSNumber class]])
  {
    note.swankId = swankId;
    [note save:NO];
  }
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
  self.note = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
  [self markNoteInResponse];
  self.dataCache = nil;
  self.connection = nil;
  self.note = nil;
  [self startRequest];
}

#pragma mark Memory Management
- (void) dealloc
{
  [note release];
  [dataCache release];
  [connection release];
  [super dealloc];
}

@end
