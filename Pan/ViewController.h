//
//  ViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 4..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@import Firebase;
@interface ViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImagePickerController *picker;
    UIImage *image;
}
@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *week;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *album;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@property (strong, nonatomic) NSString *loginId;

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;

@end

