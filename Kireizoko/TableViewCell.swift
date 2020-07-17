//
//  TableViewCell.swift
//  Kireizoko
//
//  Created by 佐々木瑠唯 on 2020/06/17.
//  Copyright © 2020 Rui.Sasaki. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewCell: UITableViewCell {

    @IBOutlet weak var cellimageView: UIImageView!
    @IBOutlet weak var konyubiLabel: UILabel!
    @IBOutlet weak var zannissuLabel: UILabel!
    @IBOutlet weak var suryoSlider: UISlider!
    @IBOutlet weak var suryoLabel: UILabel!
    @IBOutlet weak var nokoriLabel: UILabel!
    
    // スライダーを動かした際にその位置の値をラベルに設定
    @IBAction func suryoSliderAction(_ sender: Any) {
        let value = Int(suryoSlider.value)
        self.suryoLabel.text = String(value)
        
        try! realm.write {
            self.task.suryoValue = value
        }
        // valueの値が0になった時に削除アラートを出す
        if task.suryoValue == 0 {
            //アラート生成
            let alert: UIAlertController = UIAlertController(title: "商品の削除", message:  "商品を削除してもよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            // 削除ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "削除する", style: UIAlertAction.Style.default, handler:{
                // 削除ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                //実際の処理
                // ローカル通知をキャンセルする
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [String(self.task.id)])
                // データベースから削除する
                try! self.realm.write {
                    self.realm.delete(self.task)
                    //self.vc.tableView.deleteRows(at: [indexPath], with: .fade)
                    // 未通知のローカル通知一覧をログ出力
                    center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                        for request in requests {
                            print("/---------------")
                            print(request)
                            print("---------------/")
                        }
                    }
                }
                // tableViewをリロードする
                self.tableView.reloadData()
                print("削除")
            })
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                //実際の処理
                print("キャンセル")
            })
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            //実際にAlertを表示する
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    var task: Task!
    
    var vc:UIViewController!
    var tableView:UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTaskData(_ taskData: Task, vc:UIViewController , tableView:UITableView) {
        
        self.vc = vc
        self.tableView = tableView
        // 画像の設定
        self.cellimageView.image = UIImage(data: taskData.image)
        
        // 購入日ラベルに追加した日時を
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString:String = formatter.string(from: taskData.konyubi)
        self.konyubiLabel.text = dateString
        
        // 残日数の設定(賞味期限 - 購入日)
        let interval = taskData.shomikigen.timeIntervalSince(taskData.konyubi)
        let zannissu: Int = Int(interval/60/60/24+1)
        // 残日数をStringに変換してラベルに設定
        let zannissuString: String = String(zannissu)
        self.zannissuLabel.text = zannissuString
        
        // 残日数が0以下になったら賞味期限切れと表示する
        if zannissu <= 0 {
            zannissuLabel.text = ""
            nokoriLabel.text = "賞味期限切れ"
        }
        
        // 数量スライダーの設定
        suryoSlider.minimumValue = 0;
        suryoSlider.maximumValue = Float(taskData.suryo);
        suryoSlider.value = Float(taskData.suryoValue);
        let value = Int(suryoSlider.value)
        self.suryoLabel.text = String(value)
        
        self.task = taskData
    }
}
