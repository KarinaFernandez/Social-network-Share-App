//
//  ViewController.swift
//  Social network Share App
//
//  Created by Karina on 28/12/2017.
//  Copyright © 2017 Karina. All rights reserved.
//

import FBSDKShareKit
import Firebase
import FirebaseAuth
import SafariServices
import TwitterKit
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func shareInFacebook(_ sender: UIButton) {
        let content = FBSDKShareLinkContent.init()
        content.contentURL = NSURL(string: "https://developers.facebook.com")! as URL
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.native
        if !dialog.canShow() {
            // Open Safari in case that not Facebook app is installed
            dialog.mode = FBSDKShareDialogMode.feedBrowser
        }
        dialog.show()
    }
    
    @IBAction func shareInTwitter(_ sender: UIButton) {
        // If session exist and the app has been autorize, create tweet
        let store = TWTRTwitter.sharedInstance().sessionStore
        let lastSession = store.session()
        if lastSession != nil {
            // Create tweet
            self.createTweet()
        } else {
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if session != nil {
                    print("signed in as \(String(describing: session?.userName))")
                    // Create tweet
                    self.createTweet()
                } else {
                    // No user signed. - Login and authorize the app to create tweet
                    print("error: \(String(describing: error?.localizedDescription))")
                    // Twitter login button
                    let twitterLogInButton = TWTRLogInButton { (session, error) in
                        if error != nil {
                            print("error")
                        } else {
                            guard let authToken = session?.authToken else { return }
                            guard let authTokenSecret = session?.authTokenSecret else { return }
                            let credential = TwitterAuthProvider.credential(withToken: authToken, secret: authTokenSecret)
                            Auth.auth().signIn(with: credential, completion: { (user, error) in
                                if error != nil {
                                    print("Failed to login using Firebase: \(String(describing: error?.localizedDescription))")
                                    return
                                }
                                // Create tweet
                                self.createTweet()
                            })
                        }
                    }
                    // Show login button
                    twitterLogInButton.center = self.view.center
                    self.view.addSubview(twitterLogInButton)
                }
            })
        }
    }
    
    // Create tweet
    func createTweet() {
        let composer = TWTRComposer()
        composer.setText("Sharingggg")
        
        // Called from a UIViewController
        composer.show(from: self.navigationController!) { result in
            if result == .done {
                print("Successfully composed Tweet")
            } else {
                print("Cancelled composing")
            }
        }
    }

}
