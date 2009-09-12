#import <Foundation/Foundation.h>

@interface NoteDownloader : NSObject
{
  NSMutableData *dataCache;
  NSURLConnection *connection;
}

@property (nonatomic, retain) NSMutableData *dataCache;
@property (nonatomic, retain) NSURLConnection *connection;

- (void) startRequest;

@end
