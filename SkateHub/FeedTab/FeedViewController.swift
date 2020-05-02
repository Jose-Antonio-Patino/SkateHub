//
//  FeedTableViewController.swift
//  SkateHub
//
//  Copyright © 2020 Jose Patino/Aldo Almeida/Paola Camacho. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    let profileBtn=UIButton(type: .custom)
    var barButton:UIBarButtonItem!
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        profileBtn.frame=CGRect(x: 0, y: 0, width: 40, height: 40)
        profileBtn.addTarget(self, action: #selector(editProfile(_:)), for: .touchUpInside)
        profileBtn.imageView?.contentMode = .scaleAspectFill
        profileBtn.clipsToBounds=true
        profileBtn.widthAnchor.constraint(equalToConstant: 40).isActive=true
        profileBtn.heightAnchor.constraint(equalToConstant: 40).isActive=true
        let image=getImage()
        profileBtn.layer.cornerRadius=20
        profileBtn.af_setImage(for: .normal, url: image)
        barButton=UIBarButtonItem(customView: profileBtn)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        myRefreshControl.addTarget(self, action: #selector(viewDidAppear(_:)), for: .valueChanged)
        tableView.refreshControl = myRefreshControl


        
    }
    
    
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    
    @objc func editProfile(_ sender: UIButton){
        self.performSegue(withIdentifier: "editProfile", sender: nil)
    }
    
    func getImage() -> URL{
        let user = PFUser.current()!
        let image=user["profileImage"] as! PFFileObject
        let urlString=image.url!
        let url=URL(string: urlString)!
        return url
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        let image=getImage()
        profileBtn.af_setImage(for: .normal, url: image)
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }else{
                print("Could not get posts")
            }
            
        }
        
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success{
                print("Comment saved")
            }
            else{
                print("Error saving comment")
            }
        }
        tableView.reloadData()
        
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.contentView.layer.cornerRadius=25
            cell.contentView.layer.borderColor=UIColor.lightGray.cgColor
            cell.contentView.layer.borderWidth=0.85
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.postImage.af_setImage(withURL: url)
            
            let profile = user["profileImage"] as! PFFileObject
            let profileUrl = profile.url!
            let url2 = URL(string: profileUrl)!
            cell.profilePicture.layer.cornerRadius=20.0
            //cell.profilePicture.layer.borderWidth=1.0
            //cell.profilePicture.layer.borderColor=UIColor.black.cgColor
            cell.profilePicture.af_setImage(withURL: url2)
            cell.postID=post.objectId!
            
            return cell
            
        }else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            
            return cell
        }    else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder()
            
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    
    
    
    
}

