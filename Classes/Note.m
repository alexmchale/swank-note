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

- (void)save:(bool)isDirty updateTimestamp:(bool)updateTimestamp
{
  if (updateTimestamp)
    self.updatedAt = [NSDate date];
  
  self.dirty = [NSNumber numberWithBool:isDirty];
  
  [[self managedObjectContext] save:nil];  
}

- (void)destroy
{
  [[self managedObjectContext] deleteObject:self];
  [[self managedObjectContext] save:nil];
  [[self managedObjectContext] reset];
}

@end
