//
//  ViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 4..
//  Copyright © 2017년  Pan. All rights reserved.
//

//https://www.youtube.com/watch?v=SYonGnMidZw

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize newMedia;
@synthesize ref;
@synthesize storageRef;
@synthesize remoteConfig;
@synthesize loginId;
@synthesize album;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureDatabase];
    [self configureStorage];
    [self configureRemoteConfig];
    // [self fetchConfig];
    
//    FIRDataSnapshot *messageSnapshot = album[indexPath.row];
//    NSDictionary<NSString *, NSString *> *message = messageSnapshot.value;
//    NSString *name = message[MessageFieldsname];
//    NSString *imageURL = message[MessageFieldsimageURL];
}


- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)useCamera:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
    
}

//- (void)saveImage:(NSDictionary *)data {
////    NSMutableDictionary *mdata = [data mutableCopy];
////    mdata[] = ;
////    mdata[imgURL] =
////    NSURL *photoURL = [FIRAuth auth].currentUser.photoURL;
////    if (photoURL) {
////        mdata[MessageFieldsphotoURL] = [photoURL absoluteString];
////    }
//    
//    NSMutableDictionary *imgDiction = [[NSMutableDictionary alloc] init];
//    [imgDiction setObject:@"v1" forKey:@"k1"];
//    
//    
//    [[[ref child:@"Week"] child:loginId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        if (snapshot.value == [NSNull null]) {
//            [ref setValue:@{loginId : @1}];
//            [[[[ref child:@"Week"] child: loginId] child: @"album"] setValue:imgDiction];
//        }
//        else{
//        
//        }
//    } withCancelBlock:^(NSError * _Nonnull error) {
//        NSLog(@"%@", error.localizedDescription);
//    }];
//    
//    
//    // Push data to Firebase Database
//    [[[[ref child:@"Week"] child: loginId] child: @"album"] setValue:mdata];
//}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"data :%i",[UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]);
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [imageView setImage:image];
   
    //image를 imagePicker에 저장하는 부분
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
    NSString *imagePath =
    [NSString stringWithFormat:@"%@/%lld.jpg",
     loginId, (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    [[storageRef child:imagePath] putData:imgData metadata:metadata
                                completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                    if (error) {
                                        NSLog(@"Error uploading: %@", error);
                                        return;
                                    }
                                    NSMutableDictionary *imgDiction = [[NSMutableDictionary alloc] init];
                                    NSString *capturedDate = [NSString stringWithFormat:@"%lld", (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
                                    [imgDiction setObject:[storageRef child:metadata.path].description forKey:capturedDate];
                                    //[self saveImage:@{(long long)([NSDate date].timeIntervalSince1970 * 1000.0):[storageRef child:metadata.path].description}];
                                    [[[ref child:@"Week"] child:loginId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                        if (snapshot.value == [NSNull null]) {
                                            [[[[ref child:@"Week"] child: loginId] child: @"album"] setValue:imgDiction];
                                        }
                                        else{
                                            [[[[ref child:@"Week"] child: loginId] child: @"album"] setValue:imgDiction];
                                        }
                                    } withCancelBlock:^(NSError * _Nonnull error) {
                                        NSLog(@"%@", error.localizedDescription);
                                    }];

                                }];

    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)useCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        newMedia = NO;
    }
}

- (void)configureRemoteConfig {
    remoteConfig = [FIRRemoteConfig remoteConfig];
    // Create Remote Config Setting to enable developer mode.
    // Fetching configs from the server is normally limited to 5 requests per hour.
    // Enabling developer mode allows many more requests to be made per hour, so developers
    // can test different config values during development.
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    self.remoteConfig.configSettings = remoteConfigSettings;
}

- (void)configureStorage {
    self.storageRef = [[FIRStorage storage] reference];
}


-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
