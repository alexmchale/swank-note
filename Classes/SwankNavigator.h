#import <UIKit/UIKit.h>
#import "Note.h"

@interface SwankNavigator : UIViewController 
{
}

- (void)editNewNote;
- (void)editNote:(Note *)note;
- (Note *)previousNote:(Note *)current;
- (Note *)nextNote:(Note *)current;
- (Note *)nextNote:(Note *)current direction:(NSInteger)delta;
- (void)reloadIndex;

@end
