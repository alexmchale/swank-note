#import "NoteFilter.h"
#import "SwankNoteAppDelegate.h"

@implementation NoteFilter

- (NSManagedObjectContext *)context
{
  SwankNoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  return [appDelegate managedObjectContext];
}

- (NSFetchRequest *)request
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note" 
                                                       inManagedObjectContext:[self context]];
  
  NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO] autorelease];
  
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  [request setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  return request;
}

- (Note *)findBySwankId:(NSNumber *)swankId
{
  if (swankId == nil)
    return nil;
  
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"swankId=%@", swankId]];
  NSArray *res = [[self context] executeFetchRequest:req error:nil];
  
  if (res == nil || [res count] == 0)
    return nil;
  
  return [res objectAtIndex:0];
}

- (NSInteger)count
{
  return [[self context] countForFetchRequest:[self request] error:nil];
}

- (NSArray *)fetchDirtyNotes:(bool)dirty
{
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"dirty=%@", [NSNumber numberWithBool:dirty]]];
  
  return [[self context] executeFetchRequest:req error:nil];
}

- (Note *)atIndex:(NSInteger)index
{
  NSFetchRequest *request = [self request];
  [request setFetchOffset:index];
  [request setFetchLimit:1];

  NSArray *result = [[self context] executeFetchRequest:request error:nil];
  Note *note = nil;
  
  if ([result count] > 0)
  {
    note = [result objectAtIndex:0];

//    note.identity = [[note valueForKey:@"identity"] intValue];
//    note.createdAt = [note valueForKey:@"createdAt"];
//    note.updatedAt = [note valueForKey:@"updatedAt"];
//    note.text = [note valueForKey:@"text"];
  }
    
  return note;
}

- (NSInteger)indexOf:(Note *)note
{
  NSArray *result = [[self context] executeFetchRequest:[self request] error:nil];
  return [result indexOfObject:note];
}

@end
