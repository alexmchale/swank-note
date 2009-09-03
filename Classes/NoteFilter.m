#import "NoteFilter.h"
#import "SwankNoteAppDelegate.h"

@implementation NoteFilter

@synthesize context, searchTerm;

- (NoteFilter *)initWithContext
{
  [super init];
  
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
  
  if (coordinator != nil)
  {
    self.context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: coordinator];
    [context setRetainsRegisteredObjects:YES];
  }
  
  return self;
}

- (Note *)newNote
{
  Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
  note.swankId = [NSNumber numberWithInt:0];
  note.createdAt = [NSDate date];
  note.dirty = [NSNumber numberWithBool:YES];
  return note;
}

- (void)cancelChanges
{
  [context rollback];
}

- (NSFetchRequest *)request
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note" 
                                                       inManagedObjectContext:context];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
  
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  [request setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  if (self.searchTerm != nil && [self.searchTerm length] > 0)
  {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"text CONTAINS[cd] %@", searchTerm];
    [request setPredicate:pred];
  }
  else
  {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(text != nil) && (text != '')"];
    [request setPredicate:pred];
  }
  
  [sort release];
  
  return request;
}

- (Note *)findBySwankId:(NSNumber *)swankId
{
  if (swankId == nil)
    return nil;
  
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"swankId=%@", swankId]];
  NSArray *res = [self.context executeFetchRequest:req error:nil];
  
  if (res == nil || [res count] == 0)
    return nil;
  
  return [res objectAtIndex:0];
}

- (NSDate *)swankSyncTime
{
  NSFetchRequest *req = [self request];
  
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
  [req setSortDescriptors:[NSArray arrayWithObject:sort]];
  [req setPredicate:[NSPredicate predicateWithFormat:@"dirty=0 AND swankId>0"]];
  [req setFetchLimit:1];
  NSArray *res = [self.context executeFetchRequest:req error:nil];
  
  [sort release];
  
  if (res == nil || [res count] == 0)
    return nil;
  
  Note *note = [res objectAtIndex:0];
  
  return note.updatedAt;
}

- (void)searchText:(NSString *)newSearchTerm
{
  self.searchTerm = newSearchTerm;
}

- (void)resetContext
{
  [context reset];
}

- (NSInteger)count
{
  return [self.context countForFetchRequest:[self request] error:nil];
}

- (NSArray *)fetchDirtyNotes:(bool)dirty
{
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"dirty=%@", [NSNumber numberWithBool:dirty]]];
  
  return [self.context executeFetchRequest:req error:nil];
}

- (NSArray *)fetchAll
{
  return [self.context executeFetchRequest:[self request] error:nil];
}

- (Note *)atIndex:(NSInteger)index
{
  NSFetchRequest *request = [self request];
  [request setFetchOffset:index];
  [request setFetchLimit:1];

  NSArray *result = [self.context executeFetchRequest:request error:nil];
  
  if ([result count] > 0)
    return [result objectAtIndex:0];
    
  return nil;
}

- (NSInteger)indexOf:(Note *)note
{
  NSArray *result = [self.context executeFetchRequest:[self request] error:nil];
  return [result indexOfObject:note];
}

- (void)dealloc
{
  [context release];
  [super dealloc];
}

@end
