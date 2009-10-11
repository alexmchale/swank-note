#import "Note.h"
#import "SwankNoteAppDelegate.h"

@implementation Note
@dynamic identity, swankId;
@dynamic text, tags;
@dynamic createdAt, updatedAt, swankTime, dirty;
@dynamic account;

- (NSString *)swankDbPostPath
{
  if ([self.swankId isKindOfClass:[NSNumber class]] && [self.swankId intValue] > 0)
    return [NSString stringWithFormat:@"/entries/%@", self.swankId];

  return @"/entries";
}

- (void)save:(bool)isDirty
{
  if (isDirty)
    self.updatedAt = [NSDate date];
  
  self.dirty = [NSNumber numberWithBool:isDirty];
  
  [[self managedObjectContext] save:nil];
  
  [AppSettings resetAllTags];
}

- (void) destroy
{
  self.text = @"";
  [self save:YES];
  
  [AppSettings resetAllTags];
}

- (NSString *) changedDelta
{
  if (self.updatedAt == nil)
    return @"";
  
  NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.updatedAt];
  NSTimeInterval minutes = seconds / 60.0;
  NSTimeInterval hours = minutes / 60.0;
  NSTimeInterval days = hours / 24.0;
  NSTimeInterval weeks = days / 7.0;
  NSTimeInterval months = (weeks * 12.0) / 52.0;
  NSTimeInterval years = months / 12.0;
  
  if (years >= 2.0)
    return [NSString stringWithFormat:@"%d years", (int)years];
  else if (months >= 2.0)
    return [NSString stringWithFormat:@"%d months", (int)months];
  else if (weeks >= 2.0)
    return [NSString stringWithFormat:@"%d weeks", (int)weeks];
  else if (days >= 2.0)
    return [NSString stringWithFormat:@"%d days", (int)days];
  else if (hours >= 2.0)
    return [NSString stringWithFormat:@"%d hours", (int)hours];
  else if (minutes >= 2.0)
    return [NSString stringWithFormat:@"%d minutes", (int)minutes];
  else if (seconds >= 2.0)
    return [NSString stringWithFormat:@"%d seconds", (int)seconds];
  
  return @"";
}

@end
