//
//  ViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 4. 4..
//  Copyright © 2017년  Pan. All rights reserved.
//

//https://www.youtube.com/watch?v=SYonGnMidZw

#import "ViewController.h"

@interface ViewController (){
    FIRDatabaseHandle _refHandle;
    NSUInteger _weekLength;
}

@end

@implementation ViewController

@synthesize imageView;
@synthesize newMedia;
@synthesize ref;
@synthesize storageRef;
@synthesize remoteConfig;
@synthesize loginId;
@synthesize album;
@synthesize week;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    week = [[NSMutableArray alloc] init];
    [self configureDatabase];
    [self configureStorage];
    [self configureRemoteConfig];
    // [self fetchConfig];
}


- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    
    _refHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        
        _weekLength = week.count;
    }];

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


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"data :%i",[UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]);
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [imageView setImage:image];
   
    NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
    NSString *imagePath = [NSString stringWithFormat:@"%@/%lld.jpg", loginId, (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    [[storageRef child:imagePath] putData:imgData metadata:metadata
                                completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                    if (error) {
                                        NSLog(@"Error uploading: %@", error);
                                        return;
                                    }
                                    NSDate *currentDate = [NSDate date];
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                                    NSTimeZone *krTimeZone =[NSTimeZone timeZoneWithName:@"Asia/Seoul"];
                                    [dateFormatter setTimeZone:krTimeZone];
                                    NSString *krDate = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:currentDate]];
                                    
                                    NSMutableDictionary *imgDiction = [[NSMutableDictionary alloc] init];
                                    NSString *capturedDate = [NSString stringWithFormat:@"%@", krDate];
                                    [imgDiction setObject:[storageRef child:metadata.path].description forKey:capturedDate];
                                  
                                    FIRDataSnapshot *beforeWeekSnapshot = nil;
                                    NSString *beforeWeekDate;
                                    for(int i = 0; i < _weekLength; i++){
                                        FIRDataSnapshot *weekSnapshot = week[i];
                                        NSString *weekDate = weekSnapshot.value;
                                        NSString *subString = [krDate substringWithRange:NSMakeRange(0, 8)];
                                        
                                        if(beforeWeekSnapshot != nil){
                                            if([subString integerValue] > [beforeWeekDate integerValue] && [subString integerValue] < [weekDate integerValue]){
                                                [[[[[[ref child:@"Week"] child: loginId] child: weekSnapshot.key] child: @"album"] childByAutoId] setValue:imgDiction];
                                                NSLog(@"week save : %@", weekSnapshot.key);
                                                i = 100;
                                            }
                                        }
                                        beforeWeekSnapshot = weekSnapshot;
                                        beforeWeekDate = beforeWeekSnapshot.value;
                                    }
                                    
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
