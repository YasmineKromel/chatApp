//
//  chattingVC.swift
//  chatApp
//
//  Created by Yasmine on 5/27/19.
//  Copyright © 2019 Yasmine. All rights reserved.
//

import UIKit
import Photos
import Firebase
import MessageKit
import FirebaseAuth
import JSQMessagesViewController
import FirebaseStorage

import MobileCoreServices
import AVKit


class chattingVC: JSQMessagesViewController {
 
//list of  messages
    var messages = [JSQMessage]()
    
    let messageRef = Database.database().reference().child("Messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // ID , and displayname shouldn't be nil
        self.senderId = "1"
        self.senderDisplayName = "Go chatting "
        observeMessages()
    }
   // if any new message stored in database , will notify by this function
    func observeMessages()
    {
        messageRef.observe(.childAdded) { (snapshot) in
            
            if let dict = snapshot.value as? [String:AnyObject]
            {
              
                let senderId = dict["senderId"] as! String
                let displayName = dict["displayName"] as! String
                let mediatype = dict["mediaType"] as! String
                
                
                switch mediatype
                {
               case "TEXT":
                    let text = dict["text"] as! String
                    self.messages.append(JSQMessage.init(senderId: senderId, displayName: displayName,text: text))
                case "PHOTO":
                    let fileUrl = dict["fileUrl"] as! String
                    let url = NSURL(string: fileUrl)
                    let data = NSData(contentsOf: url as! URL)
                    let picture = UIImage(data:data as! Data)
                    let photo = JSQPhotoMediaItem(image: picture)
                    
                    self.messages.append(JSQMessage.init(senderId: senderId, displayName: displayName,media: photo))
                case "VIDEO":
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video as! URL, isReadyToPlay: true)
                    self.messages.append(JSQMessage.init(senderId: senderId, displayName: displayName,media: videoItem))
            default:
                print("Unkown data type")
                }
                
               
               
                self.collectionView.reloadData()
                
               // print(mediatype)
                
            }
           // self.messages.append(<#T##newElement: JSQMessage##JSQMessage#>)
        }
    }
    
    // func handle press send button after text
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        print("send button is pressed")
//        messages.append(JSQMessage.init(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text,"senderId": senderId, "displayName": senderDisplayName, "mediaType": "TEXT"]
        newMessage.setValue(messageData)
    }
    
    // handle accessory button pressed
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("accessory button is pressed")
        
        let sheet = UIAlertController.init(title: "Media Messages", message: "Please select a media", preferredStyle: .actionSheet)
        self.present(sheet, animated: true, completion: nil)
        let cancel = UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel) { (alret:UIAlertAction) in
       
        }
        let photoLibrary = UIAlertAction.init(title: "Photo Library", style: UIAlertAction.Style.default) { (alret:UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        let videoLibrary = UIAlertAction.init(title: "Video Library", style: UIAlertAction.Style.default) { (alret:UIAlertAction) in
            self.getMediaFrom(type:kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        
        // user can press accessory button and select photo
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func getMediaFrom(type: CFString)
    {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    // return message
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        // get the clicked message
        let message = messages[indexPath.item]
        if message.isMediaMessage
        {
            if let mediaItem = message.media as? JSQVideoMediaItem
            {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
            
        }
    }
    //message bubble color
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)
   }
    
    //avatr image
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // collection view
     override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    
    
    func sendMedia(picture:UIImage? ,video :NSURL?)
    {
        print(picture)
        print(video)
        print(Storage.storage().reference())
        if let picture = picture
        {
            let filePath = "\(Auth.auth().currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = picture.jpegData(compressionQuality: 1)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            Storage.storage().reference().child(filePath).putData(data!, metadata:metadata){
                (meta, error) in
                if error != nil
                {
                    print (error?.localizedDescription)
                    return
                }
                
                print(meta)
                
                
                let fileUrl = meta!.path
                let newMessage = self.messageRef.childByAutoId()

                let messageData = ["fileUrl":fileUrl,"senderId":self.senderId, "displayName":self.senderDisplayName, "MediaType":"PHOTO"] as [String : Any]

                newMessage.setValue(messageData)
                
            }
            
            
        }else if let video = video
        {
            let filePath = "\(Auth.auth().currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video as URL)
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            Storage.storage().reference().child(filePath).putData(data! as Data, metadata:metadata){
                (meta, error) in
                if error != nil
                {
                    print (error?.localizedDescription)
                    return
                }

                let fileUrl = meta!.path
                let newMessage = self.messageRef.childByAutoId()

                let messageData = ["fileUrl":fileUrl,"senderId":self.senderId, "displayName":self.senderDisplayName, "MediaType":"VIDEO"] as [String : Any]

                newMessage.setValue(messageData)

            }
            
        }
        
    }
    
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
    }
    

  

}
extension chattingVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    //user need to send photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // get image
        print(info)
        // info is a dictionary contains all information needed about selected media
        if let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
        // now we have the choosen photo in our hands
        let photo = JSQPhotoMediaItem(image:picture)
        messages.append(JSQMessage.init(senderId: senderId, displayName: senderDisplayName, media: photo ))
         sendMedia(picture:picture ,video :nil)
        }
        else if let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        {
            let videoItem = JSQVideoMediaItem .init(fileURL: video, isReadyToPlay: true)
             messages.append(JSQMessage.init(senderId: senderId, displayName: senderDisplayName, media: videoItem ))
            sendMedia(picture:nil ,video: video as NSURL)
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }

}
