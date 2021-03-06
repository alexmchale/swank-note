#import <Foundation/Foundation.h>
#import "ChildViewController.h"
#import "Note.h"
#import "NewTagsViewController.h"

@interface EditNoteTagsViewController : ChildViewController
{
  NSMutableArray *allTags;
  NSMutableArray *currentTags;
  
  NewTagsViewController *newTagsController;
}

@property (nonatomic, retain) NSMutableArray *allTags;
@property (nonatomic, retain) NSMutableArray *currentTags;
@property (nonatomic, retain) NewTagsViewController *newTagsController;

- (void) resetForNote:(Note *)note;
- (void) resetForString:(NSString *)tags;

@end
