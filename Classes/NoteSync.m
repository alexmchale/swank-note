#import "NoteSync.h"
#import "CJSONDeserializer.h"
#import "NoteFilter.h"

@implementation NoteSync
@synthesize data, delegate;

- (void)updateNotes
{
  NSString *url = @"http://swankdb.com/entries/download?frob=1c040fa7af887ac9ee97a1ffe72f11eb612e2f31&mode=json";
  NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
  [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)loadNotes:(NSArray *)notes
{
  NoteFilter *noteFilter = [[[NoteFilter alloc] init] autorelease];
  
  for (NSDictionary *noteDict in notes)
  {
    NSNumber *swankId = [noteDict valueForKey:@"id"];        
    
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    Note *note = [noteFilter findBySwankId:swankId];
    
    if (note == nil)
      note = [Note new];
    
    // Version 1 just downloads from SwankDB.  No uploading.
    
    note.swankId = swankId;
    note.text = [noteDict valueForKey:@"content"];
    note.tags = [noteDict valueForKey:@"tags"];
    note.createdAt = [dateFormatter dateFromString:[noteDict valueForKey:@"created_at"]];
    note.updatedAt = [dateFormatter dateFromString:[noteDict valueForKey:@"updated_at"]];
    
    [note save:NO];
    
    [self.delegate noteUpdated:note];
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"note key"
//                                                    message:[field stringValue]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Okay"
//                                          otherButtonTitles:nil];
//    [alert show];
//    [alert release];

//    Note *note = [noteFilter findBySwankId:[noteDict valueForKey:@"id"]];
//    
//    for (NSString *key in note)
//    {
//      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"note key"
//                                                      message:key
//                                                     delegate:nil
//                                            cancelButtonTitle:@"Okay"
//                                            otherButtonTitles:nil];
//      [alert show];
//      [alert release];
//    }
  }
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
  NSArray *notes = [[CJSONDeserializer deserializer] deserialize:data error:nil];
  [self loadNotes:notes];
  self.data = nil;  
}

- (void)dealloc
{
  [data release];
  [super dealloc];
}

@end
