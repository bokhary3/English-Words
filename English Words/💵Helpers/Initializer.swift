//
//  Initializer.swift
//  English Words
//
//  Created by Elsayed Hussein on 1/4/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class Initializer {
    
    class func getMainWindow()->UIWindow{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.window!
    }
    
    class func getAppdelegate()->AppDelegate{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate
    }
    
    class func createStoryBoardWith(identifier:String)->UIStoryboard{
        let storyoard = UIStoryboard(name: identifier, bundle: nil)
        return storyoard
    }
    class func createVCWith(identifier:String)->UIViewController{
        let mainStoryboard = createStoryBoardWith(identifier: Constants.StoryboardIds.mainSB)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    class func getMainNavigationController()->UINavigationController{
            return getMainWindow().rootViewController as! UINavigationController
    }
}
