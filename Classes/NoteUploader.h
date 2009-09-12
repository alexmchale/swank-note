#import <Foundation/Foundation.h>

@interface NoteUploader : NSObject 
{
  NSURLConnection *connection;
  NSMutableData *dataCache;
  Note *noteBeingUploaded;
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *dataCache;
@property (nonatomic, retain) Note *noteBeingUploaded;

- (void) startRequest;

@end
