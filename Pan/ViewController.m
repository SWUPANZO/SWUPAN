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
    FIRDatabaseHandle _lectureRefHandle;
    FIRDatabaseHandle _imgRefHandle;
    NSUInteger _weekLength;
    NSUInteger _lectureLength;
    NSUInteger _imageLength;
    int lectureBool;
}

@end

@implementation ViewController

@synthesize imageView;
@synthesize newMedia;
@synthesize ref;
@synthesize storageRef;
@synthesize remoteConfig;
@synthesize loginId;
@synthesize week;
@synthesize lecture;
@synthesize imageArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    week = [[NSMutableArray alloc] init];
    lecture = [[NSMutableArray alloc] init];
    imageArr = [[NSMutableArray alloc] init];
    
    [self configureDatabase];
    [self configureStorage];
    [self configureRemoteConfig];
    // [self fetchConfig];
}

- (void)configureDatabase {
    ref = [[FIRDatabase database] reference];
    
    _lectureRefHandle = [[[[ref child:@"Students"] child:loginId] child:@"lecture"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [lecture addObject:snapshot];

        _lectureLength = lecture.count;
    }];
    
    _refHandle = [[ref child:@"AcademicCalendar"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [week addObject:snapshot];
        
        _weekLength = week.count;
    }];
    
    _imgRefHandle = [[[[[[ref child:@"Week"] child:loginId] child:@"경건회"] child:@"week13"] child: @"album"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [imageArr addObject:snapshot];
        NSLog(@"%@", snapshot);
        
        _imageLength = imageArr.count;
    }];

    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)getServerImg:(id)sender {
    FIRDataSnapshot *imageSnapshot = imageArr[0];
    NSString *imageURL = imageSnapshot.value;
    [[[FIRStorage storage] referenceForURL:imageURL] dataWithMaxSize:INT64_MAX
                                                          completion:^(NSData *data, NSError *error) {
                                                              if (error) {
                                                                  NSLog(@"Error downloading: %@", error);
                                                                  return;
                                                              }
                                                              imageView.image = [UIImage imageWithData:data];
                                                          }];

}

- (IBAction)useCamera:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [imageView setImage:image];

    NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
    NSString *imagePath = [NSString stringWithFormat:@"%@/images/%lld.jpg", loginId, (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
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
                                    
                                    
                                    
                                    NSCalendar *calendar = [NSCalendar currentCalendar];
                                    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday
                                                                         fromDate:currentDate];
                                    NSInteger weekday = [comp weekday];
                                    
                                    NSString *subDateString = [krDate substringWithRange:NSMakeRange(0, 8)];
                                    NSString *subTimeString = [krDate substringWithRange:NSMakeRange(8, 4)];

                                    for(int i = 0; i < _lectureLength; i++){
                                        FIRDataSnapshot *lectureSnapshot = lecture[i];
                                        
                                        FIRDatabaseReference *snapshotRef = lectureSnapshot.ref;
                                        [[snapshotRef child:@"time"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                            FIRDatabaseReference *tempSnapshot = snapshot.ref;
                                            [[tempSnapshot child:@"week"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot2) {
                                                if([snapshot2.value integerValue] == weekday){
                                                    [[tempSnapshot child:@"start"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot3){
                                                        if([subTimeString integerValue] > [snapshot3.value integerValue]){
                                                            [[tempSnapshot child:@"end"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot4){
                                                                if([subTimeString integerValue] < [snapshot4.value integerValue]){
                                                                    [[tempSnapshot.parent child:@"name"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull nameSnapshot) {
                                                                       
                                                                        FIRDataSnapshot *beforeWeekSnapshot = nil;
                                                                        NSString *beforeWeekDate;
                                                                        for(int i = 0; i < _weekLength; i++){
                                                                            FIRDataSnapshot *weekSnapshot = week[i];
                                                                            NSString *weekDate = weekSnapshot.value;
                                                                            
                                                                            if(beforeWeekSnapshot != nil){
                                                                                if([subDateString integerValue] > [beforeWeekDate integerValue] && [subDateString integerValue] < [weekDate integerValue]){
 //                                                                                   [[[[[[[ref child:@"Week"] child: loginId] child: nameSnapshot.value] child: weekSnapshot.key] child: @"album"] childByAutoId] setValue:imgDiction];
                                                                                    [[[[[[ref child:@"Week"] child: loginId] child: weekSnapshot.key] child: nameSnapshot.value] child: @"album"] updateChildValues:imgDiction];

                                                                                    NSLog(@"week save : %@", weekSnapshot.key);
                                                                                    i = 100;
                                                                                }
                                                                            }
                                                                            beforeWeekSnapshot = weekSnapshot;
                                                                            beforeWeekDate = beforeWeekSnapshot.value;
                                                                        }

                                                                    }];
                                                                }
                                                                
                                                            }];
                                                        }
                                                    }];

                                                }
                                            }];
                                            
                                        }];
                                        if((i == _lectureLength-1)&&(i != 100)){
                
                                            [[[[[ref child:@"Week"] child: loginId] child: @"etc"] child: @"album"] updateChildValues:imgDiction];
                                            
                                        }
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
