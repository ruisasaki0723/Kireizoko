//
//  InputViewController.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/05/26.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource  {
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    // 撮影/選択した写真
    @IBOutlet weak var imageView: UIImageView!
    // 賞味期限
    @IBOutlet weak var shomikigenDatepicker: UIDatePicker!
    // 数量
    @IBOutlet weak var suryoPicker: UIPickerView!
    
    
    // 追加・更新ボタンを押したら在庫一覧画面に遷移
    @IBAction func addButton(_ sender: Any) {
        // 数量のPickerViewで入力した値の計算
        let sen = self.suryoPicker.selectedRow(inComponent: 0)
        let hyaku = self.suryoPicker.selectedRow(inComponent: 1)
        let ju = self.suryoPicker.selectedRow(inComponent: 2)
        let ichi = self.suryoPicker.selectedRow(inComponent: 3)
        let total = sen * 1000 + hyaku * 100 + ju * 10 + ichi
        
        // 画像をData型に変換
        let data = image.jpegData(compressionQuality: 0.25)!
        
        self.performSegue(withIdentifier: "toCell", sender: nil)
        
        try! realm.write {
            if isnew {
                self.task.konyubi = Date()
            }
            self.task.suryo = total
            self.task.image = data
            self.task.shomikigen = self.shomikigenDatepicker.date
            self.realm.add(self.task, update: .modified)
        }
        print(self.task.id)
    }
    // 撮り直しボタンを押したらカメラ画面に遷移
    @IBAction func backCameraButton(_ sender: Any) {
        self.performSegue(withIdentifier: "backCamera", sender: nil)
    }
    
    let realm = try! Realm()
    var task: Task!
    var image: UIImage!
    var date: Date!
    var isnew = false
    
    // 1000の位
    let thousand:[String] = ["0","1","2","3","4","5","6","7","8","9"]
    // 100の位
    let hundred:[String] = ["0","1","2","3","4","5","6","7","8","9"]
    // 10の位
    let ten:[String] = ["0","1","2","3","4","5","6","7","8","9"]
    // 1の位
    let one:[String] = ["0","1","2","3","4","5","6","7","8","9"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suryoPicker.delegate = self
        suryoPicker.dataSource = self
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
       
        // 在庫一覧のセルをタップした時
        if  !isnew {
            imageView.image = UIImage(data: task.image)
            shomikigenDatepicker.date = task.shomikigen
            
            let data = image.jpegData(compressionQuality: 0.25)!
            
            try! realm.write {
                self.task.image = data
                self.task.shomikigen = self.shomikigenDatepicker.date
            }
       } else {
            // CameraViewControllerで選んだ画像をImageViewに設定する
            imageView.image = image
        }
        
        // 在庫一覧のセルがタップされたら追加ボタンを"変更"に、撮り直しボタンを"選び直し"に変える
        if shouldPerformSegue(withIdentifier: "cellsegue", sender: nil) {
            addButtonOutlet.setTitle("変更", for: .normal)
        }
        
    }
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return thousand.count
        case 1:
            return hundred.count
        case 2:
            return ten.count
        case 3:
            return one.count
        default:
            return 0
        }
    }
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        switch component {
        case 0:
            return thousand[row]
        case 1:
            return hundred[row]
        case 2:
            return ten[row]
        case 3:
            return one[row]
        default:
            return "error"
        }
    }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
