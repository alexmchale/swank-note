#import <Foundation/Foundation.h>

@interface NoteUploader : NSObject 
{
  NSURLConnection *connection;
  NSMutableData *dataCache;
  Note *note;
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *dataCache;
@property (nonatomic, retain) Note *note;

- (void) startRequest;

@end
