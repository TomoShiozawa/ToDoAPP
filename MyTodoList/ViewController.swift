//
//  ViewController.swift
//  MyTodoList
//
//  Created by Shiozawa Tomo on 2016/05/29.
//  Copyright © 2016年 Shiozawa Tomo. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate{

    //taskを格納する配列
    var taskList = [Task]()
    
    //入力用のTextField
    var titleTextField: UITextField?
    var deadlineTextField: UITextField?
    var weightTextField: UITextField?
    
    //UIDatePickerの用意(deadline入力用)
    let datePicker = UIDatePicker()
    
    //UIPickerviewの用意(weight入力用)
    let weightPicker = UIPickerView()
    var weightOption = ["ASAP","Normal","In the future"]
    
    //Pickerのツールバー
    var pickerToolBar = UIToolbar()
    
    //日付データのフォーマット用
    let dateFormatter = NSDateFormatter()
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //taskデータの読み込み処理(ここは勉強不足)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let todoListData = userDefaults.objectForKey("taskList") as? NSData {
            if let storedTodoList = NSKeyedUnarchiver.unarchiveObjectWithData(todoListData) as? [Task] {
                taskList.appendContentsOf(storedTodoList)
            }
        }
        
        //datePickerの設定
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        datePicker.minimumDate = NSDate()
        datePicker.addTarget(self, action: #selector(ViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        //weightPickerの設定
        weightPicker.delegate = self
        
        // 各種Pickerに表示するツールバーの設定
        pickerToolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        pickerToolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        pickerToolBar.barStyle = .BlackTranslucent
        pickerToolBar.tintColor = UIColor.whiteColor()
        pickerToolBar.backgroundColor = UIColor.blackColor()
        
        //各種Pickerのツールバーに完了ボタンを設定
        let okBarBtn = UIBarButtonItem(title: "OK", style: .Done, target: self, action: #selector(ViewController.okBarBtnPush(_:)))
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self,action: Selector())
        pickerToolBar.items = [spaceBarBtn,okBarBtn]
        
        
        //dateFotmatterの設定
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocaleLanguageCode)
        dateFormatter.dateFormat = "yyyy/MM/dd"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    Addボタンをタップした際に呼ばれる処理
    */
    @IBAction func tapAddButton(sender: AnyObject) {
        //アラートダイアログ生成
        let alertController = UIAlertController(title: "task追加", message: "taskを入力してください", preferredStyle: UIAlertControllerStyle.Alert)
        
        //テキストエリアを追加
        //title用
        alertController.addTextFieldWithConfigurationHandler( { (title: UITextField!) -> Void in
            self.titleTextField = title
            title.placeholder = "Title"
        })
        //deadline用
        alertController.addTextFieldWithConfigurationHandler( { (deadline: UITextField!) -> Void in
            self.deadlineTextField = deadline
            deadline.placeholder = "Deadline"
            deadline.inputView = self.datePicker
            deadline.inputAccessoryView = self.pickerToolBar
        })
        //weight用
        alertController.addTextFieldWithConfigurationHandler( { (weight: UITextField!) -> Void in
            self.weightTextField = weight
            weight.placeholder = "weight"
            weight.inputView = self.weightPicker
            weight.inputAccessoryView = self.pickerToolBar
        })
        
        //OKボタンが押された時の処理
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            (action:UIAlertAction) -> Void in
            
            //アラートのUITextFieldsを全部配列として取得
            let textFields:Array<UITextField>? = alertController.textFields as Array<UITextField>?
            
            //入力されたtaskをtaskListに追加
            if textFields != nil {
                let task = Task()
                //textFieldsの１個目がTitle
                task.title = alertController.textFields![0].text!
                //textFieldsの2個目がDeadline
                task.deadline = self.datePicker.date
                //作成日時を取得してcreatedAtに入れる
                task.createdAt = NSDate()
                //重要度を入れる
                let weightText = alertController.textFields![2].text!
                if weightText == "ASAP" {
                    task.weight = 3
                }
                else if weightText == "Normal" {
                    task.weight = 2
                }
                else if weightText == "In the future" {
                    task.weight = 1
                }
                //taskListに追加
                self.taskList.insert(task, atIndex: 0)
            }
            
            //テーブルに行が追加されたことをテーブルに通知
            self.tableView.insertRowsAtIndexPaths(
                [NSIndexPath(forRow: 0, inSection: 0)],
                withRowAnimation: UITableViewRowAnimation.Right)
            
            //保存処理
            //NSData型にシリアライズする
            let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(self.taskList)
            
            //NSUserDefaultsに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "taskList")
            userDefaults.synchronize()
        }
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンを追加
        let cancelAction = UIAlertAction(title: "CANCEL",
            style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        //アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
    PickerのOKボタンを押したらPickerを消す
    */
    func okBarBtnPush(sender: AnyObject?){
        deadlineTextField!.resignFirstResponder()
        weightTextField!.resignFirstResponder()
    }
    
    
    /*
    datePickerが変更されたきの処理
    */
    func datePickerValueChanged(sender:UIDatePicker) {
        //deadline用のTextFieldに日付を入れる
        deadlineTextField!.text = dateFormatter.stringFromDate(sender.date)
    }
    
    
    /*
    weightPickeのために必要な関数4つ
    */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weightOption[row]
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weightOption.count
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        weightTextField!.text = weightOption[row]
    }
    

    /*
    テーブルの行数を返す
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //taskの配列の長さを返す
        return taskList.count
    }
    
    /*
    テーブルの行ごとのセルを返す
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する(メモリを有効活用するための処理らしい、勉強不足)
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath)
        
        //行番号に合ったtaskを取得
        let task = taskList[indexPath.row]
        
        //セルのラベルにtaskのタイトルをセット
        cell.textLabel!.text = task.title
        
        //状態によってチェックマークをつける
        if task.status {
            //完了していたらチェックマーク
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            //未完だったら何もなし
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        /*// ProgressViewを作成する.
        let myProgressView: UIProgressView = UIProgressView(frame: CGRectMake(0, cell.frame.height / 2.0, cell.frame.width, cell.frame.height))
        myProgressView.progressTintColor = UIColor.greenColor()
        
        
        // バーの高さを設定する(横に1.0倍,縦に2.0倍).
        myProgressView.transform = CGAffineTransformMakeScale(1.0, 25.0)
        
        // 進捗具合を設定する(0.0~1.0).
        myProgressView.progress = 0.5
        
        // アニメーションを付ける.
        myProgressView.setProgress(1.0, animated: true)
        
        // Viewに追加する.
        cell.addSubview(myProgressView)
        myProgressView.layer.borderColor = UIColor.blackColor().CGColor
        myProgressView.layer.borderWidth = 0.1
        cell.addSubview(myProgressView)
        
        myProgressView.alpha = 0.4
        
        //cell.addSubview(myLabel)
        //cell.backgroundColor = UIColor.lightGrayColor()*/
        
        return cell
    }
    
    /*
    セルをタップした時の処理
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let task = taskList[indexPath.row]
        
        //完了にするかどうか
        if task.status {
            //完了済みの場合は未完に変更
            task.status = false
        }
        else {
            //未完の場合は完了済みに変更
            task.status = true
            //完了した日付をdoneAtに入れる
            task.doneAt = NSDate()
        }
        
        //セルの状態を更新
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        //データ保存
        //NSData型にシリアライズする
        let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(taskList)
        
        //NSUserDefaultsに保存
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(data, forKey: "taskList")
        userDefaults.synchronize()
    }
    
    /*
    セルの削除許可(セルが編集可能かどうかを判定する、一応書いておいた)
    */
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }

    /*
    セルを削除した時の処理
    */
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //削除処理かどうか
        if editingStyle == .Delete {
            
            //taskListから削除
            taskList.removeAtIndex(indexPath.row)
            
            //セルを削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //データ保存
            //NSData型にシリアライズする
            let data :NSData = NSKeyedArchiver.archivedDataWithRootObject(taskList)
            
            //NSUserDefaultsに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(data, forKey: "taskList")
            userDefaults.synchronize()
        }
    }
}

//Task用のクラス
class Task: NSObject, NSCoding {

    //Taskのタイトル
    var title :String?
    
    //Taskを完了したかどうかを表すフラグ
    var status :Bool = false
    
    //Taskの締め切り
    var deadline :NSDate?
    
    //重要度
    var weight :Int32 = 2
    
    //作成した日時    
    var createdAt :NSDate?
    
    //完了した日時
    var doneAt :NSDate?
    
    //コンストラクタ
    override init() {

    }
    
    //デシリアライズ処理(デコード)
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("taskTitle") as? String
        status = aDecoder.decodeBoolForKey("taskStatus")
        deadline = aDecoder.decodeObjectForKey("taskDeadline") as? NSDate
        weight = aDecoder.decodeIntForKey("taskWeight") as Int32
        createdAt = aDecoder.decodeObjectForKey("taskCreatedAt") as? NSDate
        doneAt = aDecoder.decodeObjectForKey("taskDoneAt") as? NSDate
    }
    
    //シリアライズ処理(エンコード)
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "todoTitle")
        aCoder.encodeBool(status, forKey: "todoStatus")
        aCoder.encodeObject(deadline, forKey: "todoDeadline")
        aCoder.encodeInt(weight, forKey: "todoWeight")
        aCoder.encodeObject(createdAt, forKey: "todoCreatedAt")
        aCoder.encodeObject(doneAt, forKey: "todoDoneAT")
    }
}

