//
//  InputViewController.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/05/26.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource  {
    
    @IBOutlet weak var addButtonOutlet: UIButton!
    // 撮影/選択した写真
    @IBOutlet weak var imageView: UIImageView!
    // 賞味期限ピッカー
    @IBOutlet weak var shomikigenDatepicker: UIDatePicker!
    // 数量ピッカー
    @IBOutlet weak var suryoPicker: UIPickerView!
    // カテゴリーピッカー
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    // 追加ボタンを押したら在庫一覧画面に遷移
    @IBAction func addButton(_ sender: Any) {
        // 数量PickerViewで選択した値の計算
        let sen = self.suryoPicker.selectedRow(inComponent: 0)
        let hyaku = self.suryoPicker.selectedRow(inComponent: 1)
        let ju = self.suryoPicker.selectedRow(inComponent: 2)
        let ichi = self.suryoPicker.selectedRow(inComponent: 3)
        let total = sen * 1000 + hyaku * 100 + ju * 10 + ichi
        // カテゴリーPickerViewで選択した値
        let category = self.categoryPicker.selectedRow(inComponent: 0)
        let categoryString = String(category)
        // 画像をData型に変換
        let data = image.jpegData(compressionQuality: 0.25)!
        
        self.performSegue(withIdentifier: "toCell", sender: nil)
        
        try! realm.write {
            if isnew {
                self.task.konyubi = Date()
            }
            self.task.category = categoryString
            self.task.suryo = total
            self.task.suryoValue = total
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
    
    let category:[String] = ["野菜","肉","魚","乳製品","飲料","果物","デザート","調味料","その他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suryoPicker.delegate = self
        suryoPicker.dataSource = self
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // 在庫一覧のセルをタップした時
        if  !isnew {
            // 追加ボタンを変更ボタンに変更
            addButtonOutlet.setTitle("変更", for: .normal)
            
            imageView.image = UIImage(data: task.image)
            image = UIImage(data: task.image)
            shomikigenDatepicker.date = task.shomikigen
           
        } else {
            // CameraViewControllerで選んだ画像をImageViewに設定する
            imageView.image = image
        }
    }
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == suryoPicker {
            return 4
        } else {
            return 1
        }
    }
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if pickerView == suryoPicker {
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
        } else {
            switch component {
            case 0:
                return category.count
            default:
                return 0
            }
        }
    }
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if pickerView == suryoPicker {
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
        } else {
            switch component {
            case 0:
                return category[row]
            default:
                return "error"
            }
        }
    }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    // タスクのローカル通知を登録する 
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        let interval = task.shomikigen.timeIntervalSince(task.konyubi)
        let zannissu: Int = Int(interval/60/60/24+1)
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if zannissu <= 1 {
            content.title = "あと1日で賞味期限が切れます"
        } else if zannissu <= 2 {
            content.title = "あと2日で賞味期限が切れます"
        } else if zannissu <= 3 {
            content.title = "あと3日で賞味期限が切れます"
        }
        
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.konyubi)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
