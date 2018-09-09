//
//  ViewController.m
//  WhereAmI
//
//  Created by Alex Chekodanov on 09.09.2018.
//  Copyright © 2018 MERA. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *previousPoint;
@property (assign, nonatomic) CLLocationDistance totalMovementDistance;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *horizontalAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *verticalAccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTraveledLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSString *latitudeString = [NSString stringWithFormat:@"%g\u00B0",newLocation.coordinate.latitude];
    self.latitudeLabel.text = latitudeString;
    
    NSString *longitudeString = [NSString stringWithFormat:@"%g\u00B0",newLocation.coordinate.longitude];
    self.longitudeLabel.text = longitudeString;
    
    NSString *horizontalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.horizontalAccuracy];
    self.horizontalAccuracyLabel.text = horizontalAccuracyString;
    
    NSString *altitudeString = [NSString stringWithFormat:@"%gm",newLocation.altitude];
    self.altitudeLabel.text = altitudeString;
    
    NSString *verticalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.verticalAccuracy];
    self.verticalAccuracyLabel.text = verticalAccuracyString;
    
    if (newLocation.verticalAccuracy < 0 || newLocation.horizontalAccuracy < 0)
    {
        //invalid accuracy
        return;
    }
    
    if (newLocation.horizontalAccuracy > 100 || newLocation.verticalAccuracy > 50)
    {
        // accuracy radius is so large, we don't want to use it
        return;
    }
    
    if (self.previousPoint == nil)
        self.totalMovementDistance = 0;
    else
        self.totalMovementDistance += [newLocation distanceFromLocation:self.previousPoint];
    
    self.previousPoint = newLocation;
    
    NSString *distanceString = [NSString stringWithFormat:@"%gm", self.totalMovementDistance];
    self.distanceTraveledLabel.text = distanceString;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    
    NSLog(@"%ld",error.code);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error getting Location" message:errorType preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
