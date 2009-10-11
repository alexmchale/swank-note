#import "AppSettings.h"
#import "SwankNoteAppDelegate.h"
#import "NoteFilter.h"

@implementation AppSettings

// Retrieve the current value of the given key.  If a value is specified,
// set the key-value to that value before returning.
+ (NSString *)valueForKey:(NSString *)key newValue:(NSString *)newValue setValue:(BOOL)setValue
{
  NSManagedObjectContext *context = [SwankNoteAppDelegate context];
  
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"AppSettings" 
                                                       inManagedObjectContext:context];
  
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
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
  else if (setValue)
  {
    // No entry exists for this key, and we're setting one.  Create a new AppSetting.
    appSetting = [NSEntityDescription insertNewObjectForEntityForName:@"AppSettings" inManagedObjectContext:context];
  }
  
  if (setValue)
  {
    // A value was specified to set.
    [appSetting setValue:key forKey:@"key"];
    [appSetting setValue:newValue forKey:@"value"];
    [context save:nil];
    value = [newValue copy];
  }
  else if (appSetting != nil)
  {
    // We're not setting a new value, so load the current one.
    value = [[appSetting valueForKey:@"value"] copy];
  }
  
  return value;
}

+ (NSString *)valueForKey:(NSString *)key newValue:(NSString *)newValue
{
  return [self valueForKey:key newValue:newValue setValue:true];
}

+ (NSString *)valueForKey:(NSString *)key
{
  return [self valueForKey:key newValue:nil setValue:false];
}

+ (bool) valueAsBool:(NSString *)key
{
  return [@"true" isEqual:[self valueForKey:key]];
}

+ (void) valueForKey:(NSString *)key newBool:(bool)value
{
  [self valueForKey:key newValue:(value ? @"true" : @"false")];
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

+ (NSArray *) allTags
{
  NSArray *tags = [[self valueForKey:@"allTags"] splitForTags];
  
  if (tags == nil)
    return [[[NSArray alloc] init] autorelease];
  
  return tags;
}

+ (void) resetAllTags
{
  NSArray *tags = [NoteFilter fetchAllTags];
  
  if (tags == nil)
    [self valueForKey:@"allTags" newValue:@""];
  else
    [self valueForKey:@"allTags" newValue:[tags componentsJoinedByString:@" "]];
}

+ (bool) noteInProgress:(Note **)note withText:(NSString **)text withTags:(NSString **)tags 
{
  if (![self valueAsBool:@"note_in_progress"])
    return false;

  *note = nil;
  *text = [self valueForKey:@"note_in_progress_text"];
  *tags = [self valueForKey:@"note_in_progress_tags"];
  
  NSString *noteUriString = [self valueForKey:@"note_in_progress_uri"];
  
  if (noteUriString != nil)
  {
    NSManagedObjectContext *context = [SwankNoteAppDelegate context];
    NSPersistentStoreCoordinator *store = [context persistentStoreCoordinator];
    NSURL *noteUrl = [NSURL URLWithString:noteUriString];
    NSManagedObjectID *noteId = [store managedObjectIDForURIRepresentation:noteUrl];
    *note = (Note *)[context objectWithID:noteId];
  }
  
  return true;
}

+ (void) clearNoteInProgress
{
  [self valueForKey:@"note_in_progress" newBool:false];
}

+ (void) setNoteInProgress:(Note *)note withText:(NSString *)text withTags:(NSString *)tags
{
  //NSString *uri;
  
  //if (note != nil && [note isInserted])
  NSString *uri = (note == nil) ? nil : [[[note objectID] URIRepresentation] absoluteString];
  
  [self valueForKey:@"note_in_progress_text" newValue:text];
  [self valueForKey:@"note_in_progress_tags" newValue:tags];
  [self valueForKey:@"note_in_progress_uri" newValue:uri];
  
  [self valueForKey:@"note_in_progress" newBool:true];
}

@end
