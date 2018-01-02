//
//  ViewController.swift
//  Social network Share App
//
//  Created by Karina on 28/12/2017.
//  Copyright © 2017 Karina. All rights reserved.
//

import FBSDKShareKit
import Firebase
import SafariServices
import TwitterKit
import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareInFacebook(_ sender: UIButton) {
        let content = FBSDKShareLinkContent.init()
        content.contentURL = NSURL(string: "https://developers.facebook.com")! as URL
        
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        
        dialog.show()
    }
    
    @IBAction func shareInTwitter(_ sender: UIButton) {
        if (TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            // App must have at least one logged-in user to compose a Tweet
            let composer = TWTRComposerViewController.emptyComposer()
            present(composer, animated: true, completion: nil)
        } else {
            // Log in, and then check again
            TWTRTwitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let composer = TWTRComposerViewController.emptyComposer()
                    self.present(composer, animated: true, completion: nil)
                } else {
                    let logInButton = TWTRLogInButton(logInCompletion: { session, error in
                        if session != nil {
                            guard let authToken = session?.authToken else { return }
                            guard let authTokenSecret = session?.authTokenSecret else { return }
                            let credential = TwitterAuthProvider.credential(withToken: authToken, secret: authTokenSecret)
                            
                            Auth.auth().signIn(with: credential) { (user, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                    return
                                }
                            }
                        } else {
                            guard let url = URL(string: "https://twitter.com/") else { return }
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    })
                    logInButton.center = self.view.center
                    self.view.addSubview(logInButton)
                }
            }
        }
        
    }
    
}
