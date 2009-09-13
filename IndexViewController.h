#import <UIKit/UIKit.h>
#import "NoteFilter.h"
#import "NoteSync.h"
#import "ChildViewController.h"
#import "EditNoteViewController.h"

@interface IndexViewController : ChildViewController <NoteSyncDelegate>
//SwankNavigator <UITableViewDelegate, UITableViewDataSource, NoteSyncDelegate, UISearchBarDelegate>
{
  UISearchBar *searchBar;
  NSArray *notes;
  EditNoteViewController *noteEditor;
  NSString *filterForTag;
  
  bool multipleAccounts;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) EditNoteViewController *noteEditor;
@property (nonatomic, retain) NSString *filterForTag;

- (IBAction)showSearchBar;
- (void)reload;

@end
