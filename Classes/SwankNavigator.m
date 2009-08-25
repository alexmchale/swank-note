#import "SwankNavigator.h"
#import "SwankRootViewController.h"
#import "SwankNoteAppDelegate.h"

@implementation SwankNavigator

- (SwankRootViewController *)root
{
	SwankNoteAppDelegate *app = [[UIApplication sharedApplication] delegate];
	return [app swankRootViewController];
}

- (void)editNewNote
{
  [[self root] showEditor];
  [[[self root] editNoteViewController] edit];
}

- (void)editNote:(Note *)note
{
  if (note != nil)
  {
    [[self root] showEditor];
    [[[self root] editNoteViewController] edit:note];
  }
}

- (Note *)previousNote:(Note *)current
{
  return [self nextNote:current direction:-1];
}

- (Note *)nextNote:(Note *)current
{
  return [self nextNote:current direction:+1];
}

- (Note *)nextNote:(Note *)current direction:(NSInteger)delta
{
  IndexViewController *index = [[self root] indexViewController];
  NoteFilter *noteFilter = [index noteFilter];
  NSInteger count = [noteFilter count];
  
  if (noteFilter == nil || count == 0)
    return nil;
  
  NSUInteger currentIndex = [noteFilter indexOf:current];
  NSInteger nextIndex = currentIndex + delta;
  
  if (currentIndex == NSNotFound)
    return [noteFilter atIndex:0];
  
  while (nextIndex < 0)
    nextIndex += [noteFilter count];
  
  while (nextIndex >= [noteFilter count])
    nextIndex -= [noteFilter count];
  
  return [noteFilter atIndex:nextIndex];
}

- (void)reloadIndex
{
  [[[self root] indexViewController] reload];
}

@end
