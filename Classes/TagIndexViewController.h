#import <Foundation/Foundation.h>
#import "ChildViewController.h"
#import "IndexViewController.h"

@interface TagIndexViewController : ChildViewController
{
  NSArray *tags;
  IndexViewController *indexViewController;
}

@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) IndexViewController *indexViewController;

@end
