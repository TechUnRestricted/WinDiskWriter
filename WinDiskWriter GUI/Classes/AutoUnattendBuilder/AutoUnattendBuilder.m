//
//  AutoUnattendBuilder.m
//  windiskwriter
//
//  Created by Macintosh on 14.09.2023.
//

#import "AutoUnattendBuilder.h"

@implementation AutoUnattendBuilder

NSString * const PUBLIC_KEY_TOKEN = @"31bf3856ad364e35";
NSString * const XMLNS_WCM = @"http://schemas.microsoft.com/WMIConfig/2002/State";
NSString * const XMLNS_XSI = @"http://www.w3.org/2001/XMLSchema-instance";
NSString * const TRUE_STRING = @"true";

- (NSXMLElement *)buildXML {
    NSXMLElement *rootXMLElement = [[NSXMLElement alloc] initWithName:@"unattend"]; {
        [rootXMLElement addAttribute: [NSXMLNode attributeWithName:@"xmlns" stringValue:@"urn:schemas-microsoft-com:unattend"]];
        
        NSXMLElement *settingsXMLElement = [[NSXMLElement alloc] initWithName:@"settings"]; {
            [rootXMLElement addChild:settingsXMLElement];
            
            [settingsXMLElement addAttribute: [NSXMLNode attributeWithName:@"pass" stringValue:@"windowsPE"]];
            
            NSXMLElement *componentMicrosoftWindowsSetupXMLElement = [self createComponentMicrosoftWindowsSetupXMLElement]; {
                [settingsXMLElement addChild:componentMicrosoftWindowsSetupXMLElement];
            }
            
            NSXMLElement *componentMicrosoftWindowsShellSetup = [self createComponentMicrosoftWindowsShellSetup]; {
                [settingsXMLElement addChild:componentMicrosoftWindowsShellSetup];
            }
        }
        
    }
    
    return rootXMLElement;
}

+ (NSXMLElement *)defaultComponent {
    NSXMLElement *defaultComponent = [[NSXMLElement alloc] initWithName: @"component"];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"name"
                                                     stringValue: @"Microsoft-Windows-Setup"]];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"processorArchitecture"
                                                     stringValue: @"amd64"]];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"publicKeyToken"
                                                     stringValue: PUBLIC_KEY_TOKEN]];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"language"
                                                     stringValue: @"neutral"]];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"versionScope"
                                                     stringValue: @"nonSxS"]];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"xmlns:wcm"
                                                     stringValue: XMLNS_WCM]];
    
    [defaultComponent addAttribute: [NSXMLNode attributeWithName: @"xmlns:xsi"
                                                     stringValue: XMLNS_XSI]];
    
    return defaultComponent;
}

- (NSXMLElement *)createComponentMicrosoftWindowsShellSetup {
    NSXMLElement *componentMicrosoftWindowsShellSetup = [AutoUnattendBuilder defaultComponent];
    
    NSXMLElement *OOBEXMLElement = [NSXMLElement elementWithName: @"OOBE"]; {
        [componentMicrosoftWindowsShellSetup addChild: OOBEXMLElement];
        
        if (self.hideOnlineAccountScreens) {
            NSXMLElement *hideOnlineAccountScreensXMLElement = [NSXMLElement elementWithName: @"HideOnlineAccountScreens"
                                                                                 stringValue: TRUE_STRING]; {
                [OOBEXMLElement addChild: hideOnlineAccountScreensXMLElement];
            }
        }
        
        if (self.hideWirelessSetup) {
            NSXMLElement *hideWirelessSetupXMLElement = [NSXMLElement elementWithName: @"HideWirelessSetupInOOBE"
                                                                                 stringValue: TRUE_STRING]; {
                [OOBEXMLElement addChild: hideWirelessSetupXMLElement];
            }
        }
        
    }
    
    return componentMicrosoftWindowsShellSetup;
}

- (NSXMLElement *)createComponentMicrosoftWindowsSetupXMLElement {
    NSXMLElement *componentMicrosoftWindowsSetupXMLElement = [AutoUnattendBuilder defaultComponent]; {
        
        NSXMLElement *runSynchronousXMLElement = [self createRunSynchronousXMLElement]; {
            [componentMicrosoftWindowsSetupXMLElement addChild:runSynchronousXMLElement];
        }
        
        NSXMLElement *userDataXMLElement = [self createUserDataXMLElement]; {
            [componentMicrosoftWindowsSetupXMLElement addChild:userDataXMLElement];
        }
        
    }
    
    return componentMicrosoftWindowsSetupXMLElement;
}

- (NSXMLElement *)createUserDataXMLElement {
    NSXMLElement *userDataXMLElement = [[NSXMLElement alloc] initWithName: @"UserData"]; {
        if (self.acceptEULA) {
            NSXMLElement *acceptEULAXMLElement = [[NSXMLElement alloc] initWithName: @"AcceptEula"
                                                                        stringValue: TRUE_STRING]; {
                [userDataXMLElement addChild: acceptEULAXMLElement];
            }
        }
        
        /* Needs to be checked */
        if (self.skipProductKeyCheck) {
            NSXMLElement *productKeyXMLElement = [[NSXMLElement alloc] initWithName: @"ProductKey"]; {
                [userDataXMLElement addChild: productKeyXMLElement];
                
                NSXMLElement *keyXMLElement = [[NSXMLElement alloc] initWithName: @"Key"]; {
                    [productKeyXMLElement addChild: keyXMLElement];
                    /* Should be empty */
                }
                
                NSXMLElement *willShowUIXMLElement = [[NSXMLElement alloc] initWithName: @"WillShowUI"
                                                                            stringValue: @"OnError"]; {
                    [productKeyXMLElement addChild: willShowUIXMLElement];
                }
            }
        }
    }
    
    return userDataXMLElement;
}

- (NSXMLElement *)createRunSynchronousXMLElement {
    NSXMLElement *runSynchronousXMLElement = [[NSXMLElement alloc] initWithName: @"RunSynchronous"];
    
    NSUInteger commandsCounter = 0;
    
    if (self.bypassTPMCheck) {
        NSXMLElement *synchronousCommand = [self createRunSynchronousCommandWithParameterName: @"BypassTPMCheck"
                                                                                   orderIndex: ++commandsCounter];
        [runSynchronousXMLElement addChild:synchronousCommand];
    }
    
    if (self.bypassSecureBoot) {
        NSXMLElement *synchronousCommand = [self createRunSynchronousCommandWithParameterName: @"BypassSecureBootCheck"
                                                                                   orderIndex: ++commandsCounter];
        [runSynchronousXMLElement addChild:synchronousCommand];
    }
    
    if (self.bypassRAMCheck) {
        NSXMLElement *synchronousCommand = [self createRunSynchronousCommandWithParameterName: @"BypassRAMCheck"
                                                                                   orderIndex: ++commandsCounter];
        [runSynchronousXMLElement addChild:synchronousCommand];
    }
    
    if (self.bypassCPUCheck) {
        NSXMLElement *synchronousCommand = [self createRunSynchronousCommandWithParameterName: @"BypassCPUCheck"
                                                                                   orderIndex: ++commandsCounter];
        [runSynchronousXMLElement addChild:synchronousCommand];
    }
    
    if (self.bypassStorageCheck) {
        NSXMLElement *synchronousCommand = [self createRunSynchronousCommandWithParameterName: @"BypassStorageCheck"
                                                                                   orderIndex: ++commandsCounter];
        [runSynchronousXMLElement addChild:synchronousCommand];
    }
    
    return runSynchronousXMLElement;
}

- (NSXMLElement *)createRunSynchronousCommandWithParameterName: (NSString *)parameterName
                                                    orderIndex: (NSUInteger)orderIndex {
    
    NSXMLElement *runSynchronousCommandXMLElement = [[NSXMLElement alloc] initWithName: @"RunSynchronousCommand"]; {
        [runSynchronousCommandXMLElement addAttribute: [NSXMLNode attributeWithName: @"wcm:action"
                                                                        stringValue: @"add"]];
        
        NSXMLElement *orderIndexXMLElement = [[NSXMLElement alloc] initWithName: @"Order"
                                                                    stringValue: [NSString stringWithFormat:@"%lu", (unsigned long)orderIndex]]; {
            [runSynchronousCommandXMLElement addChild:orderIndexXMLElement];
        }
        
        NSXMLElement *pathXMLElement = [[NSXMLElement alloc] initWithName: @"Path"
                                                              stringValue: [NSString stringWithFormat: @"CMD /c reg.exe add HKLM\\System\\Setup\\LabConfig /v %@ /t reg_dword /d 0x00000001 /f & exit /b 0", parameterName]]; {
            [runSynchronousCommandXMLElement addChild:pathXMLElement];
        }
        
    }
    
    return runSynchronousCommandXMLElement;
}

@end
