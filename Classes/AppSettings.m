#import "AppSettings.h"
#import "SwankNoteAppDelegate.h"

@implementation AppSettings

// Retrieve the current value of the given key.  If a value is specified,
// set the key-value to that value before returning.
+ (NSString *)valueForKey:(NSString *)key newValue:(NSString *)newValue
{
  NSManagedObjectContext *context = [SwankNoteAppDelegate context];
  
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"AppSettings" 
                                                       inManagedObjectContext:context];
  
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];
  [request setFetchLimit:1];
  [request setPredicate:[NSPredicate predicateWithFormat:@"key LIKE %@", key]];

  NSArray *results = [context executeFetchRequest:request error:nil];
  NSManagedObject *appSetting = nil;
  NSString *value = nil;

  if (results != nil && [results count] > 0)
  {
    // An entry already exists for this key.
    appSetting = [results objectAtIndex:0];    
  }
  else if (newValue != nil)
  {
    // No entry exists for this key, and we're setting one.  Create a new AppSetting.
    appSetting = [NSEntityDescription insertNewObjectForEntityForName:@"AppSettings" inManagedObjectContext:context];
  }
  
  if (newValue == nil && appSetting != nil)
  {
    // No value was passed, so load the current one.
    value = [[appSetting valueForKey:@"value"] copy];
  }
  else if (newValue != nil)
  {
    // A value was specified to set.
    [appSetting setValue:key forKey:@"key"];
    [appSetting setValue:newValue forKey:@"value"];
    [context save:nil];
    value = [newValue copy];
  }
  
  [request release];
    
  return value;
}

+ (NSString *)valueForKey:(NSString *)key
{
  return [self valueForKey:key newValue:nil];
}

+ (bool) sync
{
  NSString *trueString = @"true";
  NSString *current = [self valueForKey:@"enableSync"];
  
  if (current == nil)
    return false;
  
  return [trueString compare:current] == NSOrderedSame;
}

+ (void) setSync:(bool)sync
{
  [self valueForKey:@"enableSync" newValue:(sync ? @"true" : @"false")];
}

+ (NSInteger) defaultAccountSwankId
{
  NSString *defaultSwankId = [self valueForKey:@"defaultAccountSwankId"];
  
  if (defaultSwankId == nil)
    return NSNotFound;
  
  return [defaultSwankId intValue];
}

+ (void) setDefaultAccountSwankId:(NSInteger)swankId
{
  [self valueForKey:@"defaultAccountSwankId" newValue:[NSString stringWithFormat:@"%d", swankId]];
}

@end
