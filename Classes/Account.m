#import "Account.h"
#import "WPProgressHUD.h"
#import "CJSONDeserializer.h"

@implementation Account
@dynamic swankId, username, password, frob;

#pragma mark Static Methods
+ (Account *)new
{  
  return [NSEntityDescription insertNewObjectForEntityForName:@"Account" 
                                       inManagedObjectContext:[SwankNoteAppDelegate context]];
}

+ (Account *) create:(NSString *)username withPassword:(NSString *)password
{
  // Generate data to send to SwankDB.
  
  NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
  [paramDict setValue:username forKey:@"username"];
  [paramDict setValue:password forKey:@"password1"];
  [paramDict setValue:password forKey:@"password2"];
  [paramDict setValue:@"true" forKey:@"json"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  [paramDict release];
  
  // Build the URL to post to.
  
  NSString *kSwankHost = @"swankdb.com:3000";
  NSString *userPath = @"/users";
  NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", kSwankHost, userPath, paramString];    
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Build the post request.
  
  NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  [req setHTTPMethod:@"POST"];
  
  // Post to SwankDB.
  
  NSURLResponse *response;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
  
  // Parse the response, if available.
  
  if (responseData == nil || [responseData length] == 0)
    return false;
  
  NSDictionary *responseDict = [[CJSONDeserializer deserializer] deserialize:responseData error:nil];
  
  if (responseDict == nil)
    return false;
  
  id frob = [responseDict valueForKey:@"frob"];
  
  // The frob should be a 40-character SHA-1 hex string.
  
  if ([frob isKindOfClass:[NSString class]] && [frob length] == 40)
  {
    Account *account = [Account new];
    account.username = username;
    account.password = password;
    account.frob = frob;
    return account;
  }
  
  id errorMessage = [responseDict valueForKey:@"error_message"];
  
  if (![errorMessage isKindOfClass:[NSString class]])
    errorMessage = @"There was an error trying to create your account.";
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Account Error" 
                                                  message:errorMessage
                                                 delegate:nil 
                                        cancelButtonTitle:@"Okay"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
  
  return false;
}

+ (NSFetchRequest *)request
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Account" 
                                                       inManagedObjectContext:[SwankNoteAppDelegate context]];
  
  NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES] autorelease];
  
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  [request setSortDescriptors:[NSArray arrayWithObject:sort]];
  
  return request;
}

+ (Account *) fetchBySwankId:(NSInteger)swankId
{
  if (swankId > 0 && swankId != NSNotFound)
    return nil;
  
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"swankId=%d", swankId]];
  [req setFetchLimit:1];
  
  NSArray *res = [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
  
  return (res == nil || [res count] == 0) ? nil : [res objectAtIndex:0];
}

+ (Account *) fetchDefaultAccount
{
  return [self fetchBySwankId:[AppSettings defaultAccountSwankId]];
}

+ (NSArray *) fetchAllAccounts
{
  return [[SwankNoteAppDelegate context] executeFetchRequest:[self request] error:nil];
}

+ (Account *) fetchByUsername:(NSString *)username
{
  if (username == nil || [username length] == 0)
    return nil;
  
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"username=%@", username]];
  [req setFetchLimit:1];
  
  NSArray *res = [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
  
  if (res == nil || [res count] == 0)
    return nil;
  
  return [res objectAtIndex:0];
}

#pragma mark Instance Methods
- (bool) isDefault
{
  if (self.swankId == nil)
    return false;
  
  NSInteger defaultSwankId = [AppSettings defaultAccountSwankId];
  
  if (defaultSwankId == NSNotFound)
    return false;
  
  return [self.swankId isEqualToNumber:[NSNumber numberWithInt:defaultSwankId]];
}

- (bool) authenticateByUsername
{
  // Generate data to send to SwankDB.
  
  NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
  [paramDict setValue:self.username forKey:@"username"];
  [paramDict setValue:self.password forKey:@"password"];
  [paramDict setValue:@"true" forKey:@"json"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  [paramDict release];
  
  // Build the URL to post to.

  NSString *kSwankHost = @"swankdb.com:3000";
  NSString *notePath = @"/users/login";
  NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@", kSwankHost, notePath, paramString];    
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Build the post request.
  
  NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  [req setHTTPMethod:@"POST"];
  
  // Post to SwankDB.
  
  NSURLResponse *response;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];

  // Parse the response, if available.
  
  if (responseData == nil || [responseData length] == 0)
    return false;
  
  NSDictionary *responseDict = [[CJSONDeserializer deserializer] deserialize:responseData error:nil];
  
  if (responseDict == nil)
    return false;
  
  id frob = [responseDict valueForKey:@"frob"];
  
  // The frob should be a 40-character SHA-1 hex string.
  
  if ([frob isKindOfClass:[NSString class]])
    return [(NSString *)frob length] == 40;
  
  return false;
}

- (bool) testConnection:(UIView *)progressViewParent
{
  WPProgressHUD *hud = [[WPProgressHUD alloc] initWithLabel:@"Connecting"];
  bool result;
  
  [hud show];  
  result = [self authenticateByUsername];  
  [hud dismissWithClickedButtonIndex:0 animated:YES];  
  [hud release];
  
  return result;
}

@end
