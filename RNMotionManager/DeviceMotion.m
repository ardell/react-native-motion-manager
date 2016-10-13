//
//  DeviceMotion.m
//
//  Created by Jason Ardell.
//

#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "DeviceMotion.h"

@implementation DeviceMotion

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (id) init {
  self = [super init];
  NSLog(@"DeviceMotion");

  if (self) {
    self->_motionManager = [[CMMotionManager alloc] init];
    //DeviceMotion
    if([self->_motionManager isDeviceMotionAvailable])
    {
      NSLog(@"DeviceMotion available");
      /* Start the DeviceMotion sensor if it is not active already */
      if([self->_motionManager isDeviceMotionActive] == NO)
      {
        NSLog(@"DeviceMotion sensor active");
      } else {
        NSLog(@"DeviceMotion sensor not active");
      }
    }
    else
    {
      NSLog(@"DeviceMotion sensor not available!");
    }
  }
  return self;
}

RCT_EXPORT_METHOD(setDeviceMotionUpdateInterval:(double) interval) {
  NSLog(@"setDeviceMotionUpdateInterval: %f", interval);

  [self->_motionManager setDeviceMotionUpdateInterval:interval];
}

RCT_EXPORT_METHOD(getDeviceMotionUpdateInterval:(RCTResponseSenderBlock) cb) {
  double interval = self->_motionManager.deviceMotionUpdateInterval;
  NSLog(@"getDeviceMotionUpdateInterval: %f", interval);
  cb(@[[NSNull null], [NSNumber numberWithDouble:interval]]);
}

RCT_EXPORT_METHOD(getDeviceMotionData:(RCTResponseSenderBlock) cb) {
  double roll  = self->_motionManager.deviceMotion.attitude.roll;
  double pitch = self->_motionManager.deviceMotion.attitude.pitch;
  double yaw   = self->_motionManager.deviceMotion.attitude.yaw;
  double timestamp = self->_motionManager.deviceMotionData.timestamp;

  NSLog(@"getDeviceMotionData: %f, %f, %f, %f", roll, pitch, yaw, timestamp);

  cb(@[[NSNull null], @{
         @"attitude": @{
             @"roll":      [NSNumber numberWithDouble:roll],
             @"pitch":     [NSNumber numberWithDouble:pitch],
             @"yaw":       [NSNumber numberWithDouble:yaw],
             @"timestamp": [NSNumber numberWithDouble:timestamp]
             }
         }]
     );
}

RCT_EXPORT_METHOD(startDeviceMotionUpdates) {
  NSLog(@"startDeviceMotionUpdates");
  [self->_motionManager startDeviceMotionUpdates];

  /* Receive the ccelerometer data on this block */
  [self->_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMDeviceMotion *deviceMotionData, NSError *error)
   {
     double roll  = deviceMotionData.attitude.roll;
     double pitch = deviceMotionData.attitude.pitch;
     double yaw   = deviceMotionData.attitude.yaw;
     double timestamp = deviceMotionData.timestamp;
     NSLog(@"startDeviceMotionUpdates: %f, %f, %f, %f", roll, pitch, yaw, timestamp);

     [self.bridge.eventDispatcher sendDeviceEventWithName:@"DeviceMotionData" body:@{
                                                                                     @"attitude": @{
                                                                                         @"roll":      [NSNumber numberWithDouble:roll],
                                                                                         @"pitch":     [NSNumber numberWithDouble:pitch],
                                                                                         @"yaw":       [NSNumber numberWithDouble:yaw],
                                                                                         @"timestamp": [NSNumber numberWithDouble:timestamp]
                                                                                     }
                                                                                     }];
   }];

}

RCT_EXPORT_METHOD(stopDeviceMotionUpdates) {
  NSLog(@"stopDeviceMotionUpdates");
  [self->_motionManager stopDeviceMotionUpdates];
}

@end

