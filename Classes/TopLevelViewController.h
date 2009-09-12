#import <Foundation/Foundation.h>
#import "EditNoteViewController.h"

@interface TopLevelViewController : UITableViewController 
{
  NSArray *controllers;
  NSArray *recentNotes;
  EditNoteViewController *recentNoteEditor;
}

@property (nonatomic, retain) NSArray *controllers;
@property (nonatomic, retain) NSArray *recentNotes;
@property (nonatomic, retain) EditNoteViewController *recentNoteEditor;

- (void) refreshRecentNotes;

@end
