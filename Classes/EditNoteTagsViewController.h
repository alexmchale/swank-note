#import <Foundation/Foundation.h>
#import "ChildViewController.h"
#import "Note.h"
#import "NewTagsViewController.h"

@interface EditNoteTagsViewController : ChildViewController
{
  NSMutableArray *allTags;
  NSMutableArray *currentTags;
  NSMutableArray *orderedTags;
  
  NewTagsViewController *newTagsController;
}

@property (nonatomic, retain) NSMutableArray *allTags;
@property (nonatomic, retain) NSMutableArray *currentTags;
@property (nonatomic, retain) NSMutableArray *orderedTags;
@property (nonatomic, retain) NewTagsViewController *newTagsController;

- (void)resetForNote:(Note *)note;

@end
