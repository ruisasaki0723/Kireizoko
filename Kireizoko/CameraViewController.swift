//
//  CameraViewController.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/05/25.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    // 在庫一覧画面に戻るボタン
    @IBAction func backCellButton(_ sender: Any) {
         self.performSegue(withIdentifier: "backCell", sender: nil)
    }
    // ライブラリの写真
    @IBAction func LibraryButon(_ sender: Any) {
        // ライブラリを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    // カメラ起動
    @IBAction func CameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            
            // 入力画面を開く
            let inputViewController = self.storyboard?.instantiateViewController(withIdentifier: "Input") as! InputViewController
            
            inputViewController.isnew = true
            // 入力画面に画像を渡す
            inputViewController.image = image
            // ピッカーを閉じる
            picker.dismiss(animated: true, completion: nil)
            
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
                
            }
            inputViewController.task = task
            
            self.present(inputViewController, animated: true, completion: nil)
        }
    }
}
