#import "Note.h"
#import "SwankNoteAppDelegate.h"

@implementation Note
@dynamic identity, swankId;
@dynamic text, tags;
@dynamic createdAt, updatedAt, swankTime, dirty;

- (NSString *)swankDbPostPath
{
  if ([self.swankId isKindOfClass:[NSNumber class]] && [self.swankId intValue] > 0)
    return [NSString stringWithFormat:@"/entries/%@", self.swankId];

  return @"/entries";
}

@end
