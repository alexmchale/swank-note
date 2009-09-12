#import <Foundation/Foundation.h>

@interface NoteDownloader : NSObject
{
  NSMutableData *dataCache;
  NSURLConnection *connection;
  Account *account;
}

@property (nonatomic, retain) NSMutableData *dataCache;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) Account *account;

- (void) startRequest;

@end
