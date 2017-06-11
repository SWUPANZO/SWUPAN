//
//  SignInViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 14..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "SignInViewController.h"
#import "ViewController.h"
#import "imageCollecitonViewController.h"

@interface SignInViewController (){}

@end

@implementation SignInViewController

@synthesize students;
@synthesize ref;
@synthesize signInId;
@synthesize signInPasswd;

- (void)viewDidLoad {
    [super viewDidLoad];
    students = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    
    [self configureDatabase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}


- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    // Listen for new messages in the Firebase database

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButton:(UIButton *)sender {
    
        if([[self.signInId text] isEqualToString:@""] ||
           [[self.signInPasswd text] isEqualToString:@""] ) {
        }
        else {
            [[[ref child:@"Students"] child:[signInId text]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                if (snapshot.value == [NSNull null]) {
                    // The value is null
                }
                else{
                    NSMutableDictionary *dict = snapshot.value;
                    NSString *textPassword = [signInPasswd text];
                    NSString *password = [dict valueForKey:@"passwd"];
                    if(textPassword == password){
                        [self performSegueWithIdentifier:@"toLoginSuccess" sender:self];
                    }
                }
            } withCancelBlock:^(NSError * _Nonnull error) {
                NSLog(@"%@", error.localizedDescription);
            }];
            
        }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toLoginSuccess"])
    {
        ViewController *imgVC = [segue destinationViewController];
        imgVC.loginId = [signInId text];
        
//        ViewController *collectionVC = [[ViewController alloc] initWithNib:@"imageCollectionViewController" bundle:nil];
//        collectionVC.loginId = [signInId text];

    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

@end
