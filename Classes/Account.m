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

+ (Account *) create:(NSString *)username withPassword:(NSString *)password error:(NSString **)errorMessage
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
  
  NSString *userPath = @"/users";
  NSString *urlString = [NSString stringWithFormat:@"https://%@%@?%@", kSwankHost, userPath, paramString];    
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Build the post request.
  
  NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  [req setHTTPMethod:@"POST"];
  
  // Post to SwankDB.
  
  NSURLResponse *response;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];
  
  // Parse the response, if available.
  
  if (responseData == nil || [responseData length] == 0)
  {
    *errorMessage = @"Received no response from SwankDB.";
    return nil;
  }
  
  NSDictionary *responseDict = [[CJSONDeserializer deserializer] deserialize:responseData error:nil];
  
  if (responseDict == nil)
  {
    *errorMessage = @"Received an invalid response from SwankDB.";
    return nil;
  }
  
  id swankId = [responseDict valueForKey:@"id"];
  id frob = [responseDict valueForKey:@"frob"];
  *errorMessage = [responseDict valueForKey:@"error_message"];
  
  if (![*errorMessage isKindOfClass:[NSString class]])
  {
    if (!([frob isKindOfClass:[NSString class]] && [frob length] == 40))
      *errorMessage = @"Account key could not be found.";
    else if (!([swankId isKindOfClass:[NSNumber class]] && [swankId intValue] > 0))
      *errorMessage = @"Account identifier could not be found.";
  }

  if (![*errorMessage isKindOfClass:[NSString class]])
  {
    Account *account = [Account new];
    account.swankId = swankId;
    account.username = username;
    account.password = password;
    account.frob = frob;
    return account;
  }
  
  return nil;
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

// Get the account after the given account.
// Returns the first account if the given account is nil.
// Returns nil if there are no more accounts after this one.
+ (Account *) next:(Account *)account1
{
  const NSArray *allAccounts = [self fetchAllAccounts];
  
  if (allAccounts == nil || [allAccounts count] == 0)
    return nil;
  
  if (account1 == nil)
    return [allAccounts objectAtIndex:0];
  
  const NSUInteger index1 = [allAccounts indexOfObject:account1];
  
  if (index1 == NSNotFound)
    return nil;
  
  const NSUInteger index2 = index1 + 1;
  
  if (index2 >= [allAccounts count])
    return nil;
  
  return [allAccounts objectAtIndex:index2];
}

+ (Account *) fetchBySwankId:(NSInteger)swankId
{
  if (swankId == 0 || swankId == NSNotFound)
    return nil;
  
  NSFetchRequest *req = [self request];
  [req setPredicate:[NSPredicate predicateWithFormat:@"swankId=%d", swankId]];
  [req setFetchLimit:1];
  
  NSArray *res = [[SwankNoteAppDelegate context] executeFetchRequest:req error:nil];
  
  return (res == nil || [res count] == 0) ? nil : [res objectAtIndex:0];
}

+ (Account *) fetchDefaultAccount
{
  Account *configured = [self fetchBySwankId:[AppSettings defaultAccountSwankId]];
  
  if (configured != nil)
    return configured;
  
  NSArray *all = [self fetchAllAccounts];
  
  if (all == nil || [all count] == 0)
    return nil;
  
  for (Account *defaulted in all)
  {
    NSInteger swankId = [defaulted.swankId integerValue];
    
    if (swankId > 0)
    {
      [AppSettings setDefaultAccountSwankId:swankId];
      return defaulted;
    }
  }

  return nil;
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
  return self == [Account fetchDefaultAccount];
}

- (bool) authenticateByUsername
{
  // Generate data to send to SwankDB.
  
  NSMutableDictionary *paramDict = [[[NSMutableDictionary alloc] init] autorelease];
  [paramDict setValue:self.username forKey:@"username"];
  [paramDict setValue:self.password forKey:@"password"];
  [paramDict setValue:@"true" forKey:@"json"];
  NSString *paramString = [paramDict convertDictionaryToURIParameterString];
  
  // Build the URL to post to.

  NSString *notePath = @"/users/login";
  NSString *urlString = [NSString stringWithFormat:@"https://%@%@?%@", kSwankHost, notePath, paramString];    
  NSURL *url = [NSURL URLWithString:urlString];
  
  // Build the post request.
  
  NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  [req setHTTPMethod:@"POST"];
  
  // Post to SwankDB.
  
  NSURLResponse *response;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:nil];

  // Parse the response, if available.
  
  if (responseData == nil || [responseData length] == 0)
    return nil;
  
  NSDictionary *responseDict = [[CJSONDeserializer deserializer] deserialize:responseData error:nil];
  
  if (responseDict == nil)
    return false;
  
  id frob = [responseDict valueForKey:@"frob"];
  id swankId = [responseDict valueForKey:@"id"];
  
  // The frob should be a 40-character SHA-1 hex string.
  
  if ([frob isKindOfClass:[NSString class]] && [frob length] == 40)
    self.frob = frob;
  else
    return false;
  
  if ([swankId isKindOfClass:[NSNumber class]] && [swankId intValue] > 0)
    self.swankId = swankId;
  else
    return false;
  
  return true;
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

- (AccountImageView *) imageView
{
  NSUInteger index = [[Account fetchAllAccounts] indexOfObject:self];
  
  return [AccountImageView forIndex:index];
}

@end
