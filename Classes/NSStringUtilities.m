#import "NSStringUtilities.h"

@implementation NSString (NSStringUtilities)

- (void)alertWithTitle:(NSString *)title
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:self
                                                 delegate:nil
                                        cancelButtonTitle:@"Okay"
                                        otherButtonTitles:nil];
  
  [alert show];
  [alert release];
}

- (NSString *)stringByAddingPercentEscapesForURI
{
  NSString *reserved = @":/?#[]@!$&'()*+,;=";
  CFStringRef s = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)reserved, kCFStringEncodingUTF8);
  return [NSMakeCollectable(s) autorelease];
}

@end
