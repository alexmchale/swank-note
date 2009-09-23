#import <UIKit/UIKit.h>
#import "EditNoteViewController.h"

@interface IndexViewController : UIViewController 
  <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
  UISearchBar *searchBar;
  UITableView *tableView;
  
  EditNoteViewController *noteEditor;
  
  NSArray *notes;
  NSString *searchPhrase;
  NSString *searchTag;
  
  bool multipleAccounts;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) EditNoteViewController *noteEditor;

@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) NSString *searchPhrase;
@property (nonatomic, retain) NSString *searchTag;

- (void) reload;@end
