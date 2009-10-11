#import "NoteFilter.h"
#import "SwankNoteAppDelegate.h"

@implementation NoteFilter

+ (Note *)newNote
{
  NSManagedObjectContext *context = [SwankNoteAppDelegate context];
  Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
  note.swankId = [NSNumber numberWithInt:0];
  note.createdAt = [NSDate date];
  note.dirty = [NSNumber numberWithBool:YES];
  return note;
}

+ (NSFetchRequest *)request
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Note" 
                                                       inManagedObjectContext:[SwankNoteAppDelegate context]];
  
  NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO] autorelease];
  
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  [request setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"(text != nil) && (text != '')"];
  [request setPredicate:pred];
  
  return request;
}

+ (NSArray *) fetchRecentNotes:(NSInteger)count
{
  if (count <= 0)
    return [NSArray arrayWithObjects:nil];
  
  NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO] autorelease];
  
  NSFetchRequest *req = [self request];
  [req setFetchLimit:count];
  [req setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  return [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
}

+ (Note *) fetchBySwankId:(NSNumber *)swankId
{
  if (swankId == nil)
    return nil;
  
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"swankId=%@", swankId]];
  NSArray *res = [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
  
  if (res == nil || [res count] == 0)
    return nil;
  
  return [res objectAtIndex:0];
}

+ (NSDate *)swankSyncTime:(Account *)account
{
  NSFetchRequest *req = [self request];
  
  NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO] autorelease];
  [req setSortDescriptors:[NSArray arrayWithObject:sort]];
  [req setPredicate:[NSPredicate predicateWithFormat:@"dirty=0 AND swankId>0 AND account=%@", account]];
  [req setFetchLimit:1];
  
  NSArray *res = [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
  
  if (res == nil || [res count] == 0)
    return nil;
  
  Note *note = [res objectAtIndex:0];
  NSDate *lastUpdateDate = note.updatedAt;
  
  return lastUpdateDate;
}

+ (NSInteger)count
{
  return [[SwankNoteAppDelegate context] countForFetchRequest:[self request] error:nil];
}

+ (Note *) fetchFirstDirtyNote
{
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"dirty=%@", [NSNumber numberWithBool:YES]]];
  [req setFetchLimit:1];
  
  NSArray *notes = [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
  
  if (notes == nil || [notes count] == 0)
    return nil;
  
  return [notes objectAtIndex:0];
}

+ (NSArray *)fetchDirtyNotes:(bool)dirty
{
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"dirty=%@", [NSNumber numberWithBool:dirty]]];
  
  return [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
}

+ (NSArray *)fetchAll
{
  return [[SwankNoteAppDelegate context] executeFetchRequest:[self request] error:nil];
}

+ (NSPredicate *)tagPredicate:(NSString *)tag
{
  NSString *tag0 = tag;
  NSString *tag1 = [NSString stringWithFormat:@"* %@", tag];
  NSString *tag2 = [NSString stringWithFormat:@"%@ *", tag];
  NSString *tag3 = [NSString stringWithFormat:@"* %@ *", tag];
  
  return [NSPredicate predicateWithFormat:
          @"(tags LIKE %@ || tags LIKE %@ || tags LIKE %@ || tags LIKE %@)", 
          tag0, tag1, tag2, tag3];
}

+ (NSArray *) fetchAllWithTag:(NSString *)tag
{
  return [self fetchWithPhrase:nil withTag:tag];
}

+ (NSArray *) fetchWithPhrase:(NSString *)phrase withTag:(NSString *)tag
{
  NSMutableArray *preds = [[[NSMutableArray alloc] init] autorelease];
  
  if (phrase == nil || [phrase length] == 0)
    [preds addObject:[NSPredicate predicateWithFormat:@"text != nil && text != ''"]];
  else
    [preds addObject:[NSPredicate 
                      predicateWithFormat:@"(text CONTAINS[cd] %@ || tags CONTAINS[cd] %@)", 
                      phrase, phrase]];
  
  if (tag != nil && [tag length] > 0)
    [preds addObject:[self tagPredicate:tag]];
  
  NSPredicate *pred = [NSCompoundPredicate andPredicateWithSubpredicates:preds];
  
  NSFetchRequest *req = [self request];
  [req setPredicate:pred];
  
  return [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
}

+ (NSArray *)fetchAllTags
{
  NSMutableSet *tags = [[[NSMutableSet alloc] init] autorelease];
  
  for (Note *note in [self fetchAll])
  {
    if (note.tags != nil)
    {
      for (NSString *tag in [note.tags componentsSeparatedByString:@" "])
      {
        if ([tag length] > 0)
          [tags addObject:tag];
      }
    }
  }
  
  return [[tags allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

+ (Note *)atIndex:(NSInteger)index
{
  NSFetchRequest *request = [self request];
  [request setFetchOffset:index];
  [request setFetchLimit:1];

  NSArray *result = [[SwankNoteAppDelegate context] executeFetchRequest:request error:nil];
  
  if ([result count] > 0)
    return [result objectAtIndex:0];
    
  return nil;
}

+ (NSInteger)indexOf:(Note *)note
{
  NSArray *result = [[SwankNoteAppDelegate context] executeFetchRequest:[self request] error:nil];
  return [result indexOfObject:note];
}

@end
