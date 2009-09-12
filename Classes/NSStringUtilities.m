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

- (NSArray *)splitForTags
{
  NSMutableArray *cleanArray = [[[NSMutableArray alloc] init] autorelease];
  NSString *cleanString = [self lowercaseString];
  NSArray *tagsArray = [cleanString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
  
  for (NSString *tag in tagsArray)
  {    
    if ([tag length] > 0 && ![cleanArray containsObject:tag])
      [cleanArray addObject:tag];
  }
  
  return cleanArray;
}

@end
