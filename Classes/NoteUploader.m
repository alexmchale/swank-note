#import "NoteUploader.h"
#import "NoteFilter.h"
#import "NSDictionaryUtilities.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

#define kSwankHost @"swankdb.com:3000"
#define kFrob @"91eb85ae181114313fdf441d3a02d7a4a02a0e13"

@implementation NoteUploader
@synthesize connection, dataCache, noteBeingUploaded;

- (void) startRequest
{
  if (connection != nil)
    return;
  
  Note *note = [NoteFilter fetchFirstDirtyNote];
  self.noteBeingUploaded = note;
  
  if (note == nil)
    return;

  // Allocate the buffer for incoming data.
  
  NSMutableData *newDataCache = [[NSMutableData alloc] init];
  self.dataCache = newDataCache;
  [newDataCache release];
  
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
  
  NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
  
  if (note.swankId == nil || [note.swankId intValue] == 0)
    [req setHTTPMethod:@"POST"];
  else
    [req setHTTPMethod:@"PUT"];
  
  // Post to SwankDB.
  
  NSURLConnection *newConn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
  self.connection = newConn;
  [newConn release];  
  
  [req release];
}

- (void) markNoteInResponse
{
  // This would be an error condition.
  
  if (noteBeingUploaded == nil)
    return;
  
  // Flag the note with the new swank id if we just got one.
  
  id swankEntry = [[CJSONDeserializer deserializer] deserialize:self.dataCache error:nil];
  id swankId = [swankEntry valueForKey:@"id"];
  
  if ([swankId isKindOfClass:[NSNumber class]])
  {
    self.noteBeingUploaded.swankId = swankId;
    [self.noteBeingUploaded save:NO];
    
    // Successfully updated this note.  Start the next update.
    
    [self startRequest];
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
  self.noteBeingUploaded = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
  [self markNoteInResponse];
  self.dataCache = nil;
  self.connection = nil;
  self.noteBeingUploaded = nil;
}

@end
